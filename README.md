# WifiConnect - ColorBerry Kali Wi-Fi Administrator

**WifiConnect** is a lightweight terminal-based Wi-Fi administrator designed specifically for **Colorberry and Beepy** and other Debian-based distributions that use **NetworkManager**. It provides a simple graphical interface through `whiptail`, which allows users to easily scan, connect and manage wireless networks, all without having to touch command line arguments or graphical desktop environments.

---

## 🎯 What Is It For?

WifiConnect is ideal for:

- 🧪 Small screen devices especially ColorBerry and Beepy using Kali Linux and Debían (Not tested in other environments) in headless or minimal environments.

- 💻 ** Laptop users** who prefer to work on the terminal but want an easy-to-use Wi-Fi connection tool.

- 🔐 **Secure Wi-Fi credentials**, stored in the same format and location that NetworkManager expects.

- ⚙️ **Automated connections** with saved networks for faster access in future sessions.

---

## 🛠 Characteristics

- 📡 Look for nearby Wi-Fi networks and show the strength of your signal.

- 🔑 Request the password entry (it is shown in plain text for greater transparency).

- 💾 Automatically generates `.nmconnection` files in `/etc/NetworkManager/system-connections/`.

- 🧠 Connections are saved using the appropriate permissions and structure (compatible with Kali-Linux defaults).

- ❌ Easily delete saved networks directly from the application.

- 🧭 Simple interactive menu system powered by `whiptail`.

---

## 📋 Requirements

Before using WifiConnect, make sure the following tools are installed and available:

- `bash`

- `whiptail`

- `nmcli` (from NetworkManager)

- Privileges `sudo`

> ✅ Most of these are pre-installed on Kali Linux.

---

## 🚀 Installation and use

1. **Clone this repository:**

```bash

Git clone https://github.com/yourusername/wificonnect.git

Cd wificonnect

```

2. **Make the script executable:**

```bash

Chmod +x wificonnect.sh

```

3. **Run the script as root or using sudo:**

```bash

Sudo ./wificonnect.sh

```

---

## 📌 How it works

### 1. Scan available networks

The script uses `nmcli` to scan and list the Wi-Fi networks in the range. You will see a menu that shows the SSID and the signal strength.

### 2. Connect to a network

Select a network, enter your password (which is displayed in plain text) and the script will try to connect using `nmcli`.

### 3. Save the connection

If successful, WifiConnect generates a `.nmconnection` file under:

```

/etc/NetworkManager/system-connections/<SSID>.nmconnection

```

This file is:

- Formatted as native Kali `.nmconnection` configurations

- Property of `root`

- With permits `600`

- Automatic recharge using `nmcli connection recharge`

### 4. Manage saved networks

From the main menu, you can also directly view and delete any saved network. No need to edit files manually.

---

## 📂 Overview of the file

```

Wi-Fi connection/

Wificonnect.sh # Main script

---

## 🔒 Security

- Passwords are stored **only within `.nmconnection`** files, not in simple configuration files elsewhere.

- All settings are saved using secure permissions and root ownership.

- Requires sudo/root access to modify system connections.

---

## 📞 Support

If you find bugs or want to suggest improvements, feel free to open an issue or send a pull request.

---

## 🧑‍💻 Author

**N@Xs**

UI Terminal Developer | Linux Enthusiast

Computer scientist specialized in Telecommunications.

---

## 📜 License

This project is open source. You are free to use it, modify it and distribute it with the appropriate credit.
