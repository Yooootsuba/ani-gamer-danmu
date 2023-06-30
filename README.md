#  ani-gamer-danmu

在 MPV 觀看巴哈姆特動畫瘋時，可以支援彈幕列表

## 下載

將專案下載至電腦後解壓縮

https://github.com/Yooootsuba/ani-gamer-danmu/archive/refs/heads/main.zip

## 安裝

將 bin/ 放到你的 MPV 資料夾

將 scripts/ani-gamer-danmu.lua 放到你的 MPV scripts 資料夾

將 script-opts/ani-gamer-danmu.conf 放到你的 MPV script-opts 資料夾（非必要）

此時你的 MPV 資料夾結構會像是：

```
.
├── bin
│   ├── danmu-get
│   └── danmu-get.exe
├── input.conf
├── mpv.conf
├── script-opts
│   └── ani-gamer-danmu.conf
├── scripts
│   └── ani-gamer-danmu.lua
└── shaders
```

## 設定快捷鍵（非必要）

將以下設定寫入 MPV 資料夾的 input.conf

之後即可使用 Ctrl + a 更改彈幕位置，Ctrl + d 開關彈幕，可自行更換快捷鍵

```
CTRL+a script-message danmu-anchor
CTRL+d script-message danmu-hidden
```

## 修改設定檔（非必要）

請確認你已經將 script-opts/ani-gamer-danmu.conf 放到你的 MPV script-opts 資料夾

```
color=yes
font-size=16
danmu-duration=10000
danmu-gap=0
anchor=1
danmu-hidden-default=no
```