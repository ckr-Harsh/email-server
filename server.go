// main.go
package main

import (
    "context"
    "encoding/json"
    "log"
    "net/http"
    "os"
    "os/exec"
    "regexp"
    "strings"
    "time"
)

type Response struct {
    Status  string `json:"status"`
    Message string `json:"message"`
}

type CreateUserRequest struct {
    Username string `json:"username"`
    Password string `json:"password"`
}

func createUserHandler(w http.ResponseWriter, r *http.Request) {
    if r.Method != "POST" {
        http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        return
    }

    // Parse JSON request
    var req CreateUserRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        respondJSON(w, http.StatusBadRequest, Response{
            Status:  "error",
            Message: "Invalid JSON: " + err.Error(),
        })
        return
    }

    if req.Username == ""{
        respondJSON(w, http.StatusBadRequest, Response{
            Status:  "error",
            Message: "Missing username",
        })
        return
    }

    validUsername := regexp.MustCompile(`^[a-zA-Z0-9_.-]+$`)
    if !validUsername.MatchString(req.Username) {
        respondJSON(w, http.StatusBadRequest, Response{
            Status:  "error",
            Message: "Invalid username format",
        })
        return
    }

    if req.Password == "" {
        respondJSON(w, http.StatusBadRequest, Response{
            Status:  "error",
            Message: "Missing password",
        })
        return
    }

    ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
    defer cancel()
    cmd := exec.CommandContext(ctx, "/create_user.sh", req.Username, req.Password)
    output, err := cmd.CombinedOutput()
    
    if err != nil {
        respondJSON(w, http.StatusBadRequest, Response{
            Status:  "error",
            Message: strings.TrimSpace(string(output)),
        })
        return
    }

    respondJSON(w, http.StatusOK, Response{
        Status:  "success",
        Message: strings.TrimSpace(string(output)),
    })
}

func testEmailHandler(w http.ResponseWriter, r *http.Request) {
    if r.Method != "GET" {
        http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
        return
    }

    ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
    defer cancel()

    emailTo := r.URL.Query().Get("to")
    if emailTo == "" {
        emailTo = "test"
    }
    email := emailTo + "@mail.example.com"

    cmd := exec.CommandContext(ctx, "mail", "-s", "Test Email", email)
    stdin, _ := cmd.StdinPipe()
    go func() {
        defer stdin.Close()
        stdin.Write([]byte("Hello\n Verification code 343434 \n regards, ExampleCorp"))
    }()
    output, err := cmd.CombinedOutput()
    
    if err != nil {
        respondJSON(w, http.StatusInternalServerError, Response{
            Status:  "error",
            Message: "Failed to send test email: " + strings.TrimSpace(string(output)),
        })
        return
    }

    respondJSON(w, http.StatusOK, Response{
        Status:  "success",
        Message: "Test email sent successfully to " + email + ": " + strings.TrimSpace(string(output)),
    })
}

func respondJSON(w http.ResponseWriter, status int, data interface{}) {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(status)
    json.NewEncoder(w).Encode(data)
}

func main() {
    http.HandleFunc("/create-user", createUserHandler)
    
    // Only register test-email endpoint if ENABLE_TEST_EMAIL environment variable is set
    if os.Getenv("ENABLE_TEST_EMAIL") == "true" {
        http.HandleFunc("/test-email", testEmailHandler)
        log.Println("Test email endpoint enabled")
    } else {
        log.Println("Test email endpoint disabled")
    }
    
    log.Println("Server starting on :8080...")
    log.Fatal(http.ListenAndServe(":8080", nil))
}