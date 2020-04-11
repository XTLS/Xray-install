# alpinelinux-install-v2ray

## 依賴軟體

### 安裝 cURL

```
# apk add curl
```

## 下載

```
$ curl -O https://raw.githubusercontent.com/v2fly/alpinelinux-install-v2ray/master/install-release.sh
```

## 使用

```
# ash install-release.sh
```

## 管理指令

### 啟用

```
# rc-update add v2ray
```

### 禁用

```
# rc-update del v2ray
```

### 啟動

```
# rc-service v2ray start
```

### 關閉

```
# rc-service v2ray stop
```

### 重啟

```
# rc-service v2ray restart
```
