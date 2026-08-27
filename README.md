# 🛠️ My Dotfiles

Bộ cấu hình cá nhân tối ưu trải nghiệm làm việc trên Linux (Ubuntu / Debian), bao gồm Terminal (**Kitty**), Shell (**Zsh** / **Bash**), Theme (**Oh My Posh**), Quản lý file (**Yazi**), cùng widget Desktop (**Eww**).

---

## ✨ Thành phần & Tính năng chính

- **Shell:** 
  - `Zsh` kết hợp **Oh My Zsh** cùng các plugin tiện ích (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-vi-mode`, `fzf`).
  - `Bash` tích hợp **Oh My Posh** (theme `paradox`).
- **Terminal:** **Kitty** (theme đẹp mắt, hiệu ứng con trỏ beam mượt mà, hỗ trợ ligature với Nerd Font).
- **Công cụ CLI:**
  - `eza` / `lsd`: Thay thế `ls` hiển thị icon và màu sắc trực quan.
  - `batcat`: Thay thế `cat` với syntax highlighting.
  - `fastfetch`: Hiển thị thông tin hệ thống đẹp mắt khi mở terminal.
  - `yazi`: Trình duyệt file phím tắt cực nhanh trong terminal (mở nhanh bằng `Alt + O` hoặc gõ lệnh `y`).
- **Widgets:** **Eww** (đồng hồ desktop & desktop note nhanh).

---

## 🚀 Cài đặt tự động (Khuyên dùng)

Chỉ cần clone repo và chạy file script cài đặt tự động:

```bash
# 1. Di chuyển vào thư mục dotfiles
cd ~/my-dotfile

# 2. Cấp quyền & chạy script cài đặt
chmod +x install.sh
./install.sh
```

> **Script sẽ tự động:**
> - Cài đặt các gói công cụ cần thiết qua `apt`.
> - Tải và cài đặt `eza`, `oh-my-posh`, `yazi`, `oh-my-zsh` và các plugin liên quan.
> - Tự động tải & cài đặt font **FantasqueSansMono Nerd Font**.
> - Tự động sao lưu cấu hình cũ và tạo symlink vào `~/.bashrc`, `~/.zshrc`, `~/.config/`.

---

## ⚙️ Sau khi cài đặt

1. **Đổi shell mặc định sang Zsh (nếu muốn):**
   ```bash
   chsh -s $(which zsh)
   ```
2. **Áp dụng cấu hình ngay:**
   - Đối với Zsh: `source ~/.zshrc` (hoặc gõ `zsh`)
   - Đối với Bash: `source ~/.bashrc`
3. **Mở terminal Kitty** và tận hưởng không gian làm việc mới!

---

## ⌨️ Phím tắt & Alias hữu ích

| Lệnh / Phím tắt | Chức năng |
| :--- | :--- |
| `Alt + O` (hoặc `y`) | Mở nhanh trình quản lý file **Yazi** |
| `ls`, `ll`, `la`, `lt` | Liệt kê file kèm icon và định dạng cây thư mục (`eza` / `lsd`) |
| `cls` | Xóa màn hình terminal (`clear`) |
| `Ctrl + S` | Tự động thêm `sudo` vào đầu dòng lệnh hiện tại |
