package main

import (
    "fmt"
    "time"
    "os"
    "io/ioutil"
    "encoding/json"
    "github.com/dgrijalva/jwt-go"
    "github.com/go-resty/resty"
)

func main() {
    pem, _ := ioutil.ReadAll(os.Stdin)
    key, _ := jwt.ParseRSAPrivateKeyFromPEM(pem)
    t := jwt.New(jwt.GetSigningMethod("RS256"))
    now := time.Now()
    t.Claims = &jwt.StandardClaims{
        // issued at time
        IssuedAt:  now.Unix(),
        // JWT expiration time (10 minute maximum)
		ExpiresAt: now.Add(10 * time.Minute).Unix(),
        // GitHub App's identifier
        Issuer: "49009",
	}
    token, err := t.SignedString(key)
    fmt.Println(err)
    fmt.Println(string(token))

    client := resty.New()
    client.SetHostURL("https://api.github.com/app/installations").
           SetAuthToken(string(token)).
           SetHeader("Accept", "application/vnd.github.machine-man-preview+json")

    var id []struct { id int }
    r := client.R();
    installations, err := r.Get("")
    fmt.Println(err)
    err = json.Unmarshal(installations.Body(), &id)
    fmt.Println(err)
    fmt.Println(id)
}
