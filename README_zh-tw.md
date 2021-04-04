# alpinelinux-install-xray

[English](README.md) | [中文(中国)](README_zh-cn.md) | 中文(薹灣)


## 依賴軟體

### 安裝 cURL

```
# apk add curl
```

## 下載

```
$ curl -O https://raw.githubusercontent.com/XTLS/alpinelinux-install-xray/main/install-release.sh
```

## 使用

```
# ash install-release.sh
```

## 管理指令

### 啟用

```
# rc-update add xray
```

### 禁用

```
# rc-update del xray
```

### 啟動

```
# rc-service xray start
```

### 關閉

```
# rc-service xray stop
```

### 重啟

```
# rc-service xray restart
```
