package main

import (
    "os"
	"fmt"
    "strings"
    "net/url"
	"net/http"
    "io/ioutil"
)

func parseSn() string {
    args := os.Args
    return args[1]
}

func main() {
    api := "https://ani.gamer.com.tw/ajax/danmuGet.php"
    data := url.Values{}
    data.Set("sn", parseSn())

	req, _ := http.NewRequest("POST", api, strings.NewReader(data.Encode()))
    req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Add("User-Agent", "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0")

	client := &http.Client{}
	resp, _ := client.Do(req)
	defer resp.Body.Close()

	body, _ := ioutil.ReadAll(resp.Body)
	fmt.Println(string(body))
}
