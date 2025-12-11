<%@ Page Title="個人資料" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyProfile.aspx.cs" Inherits="ForumDev.Profile.MyProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <div class="row">
            <!-- 左側個人資訊卡片 -->
            <div class="col-md-4">
                <div class="card profile-card shadow">
                    <div class="card-body text-center">
                        <!-- 頭像 -->
                        <div class="avatar-wrapper mb-2">
                            <asp:Image ID="imgAvatar" runat="server" CssClass="rounded-circle avatar-large" 
                                       ImageUrl="https://i.pravatar.cc/150?img=1" />
                        </div>

                        <!-- 更換頭像按鈕（明顯位置） -->
                        <div class="mb-3">
                            <button type="button" class="btn btn-primary btn-sm" onclick="openAvatarUpload();">
                                <i class="bi bi-camera-fill"></i> 更換頭像
                            </button>
                            <asp:FileUpload ID="fuAvatar" runat="server" 
                                            accept=".png,.jpg,.jpeg,.gif"
                                            onchange="handleAvatarSelect(this);"
                                            Style="display: none;" />
                            <asp:HiddenField ID="hfCroppedImage" runat="server" />
                            <asp:Button ID="btnUploadAvatar" runat="server" 
                                        Text="上傳" 
                                        OnClick="btnUploadAvatar_Click"
                                        Style="display: none;" />
                        </div>

                        <!-- 訊息顯示 -->
                        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-dismissible fade show mb-3" role="alert">
                            <asp:Label ID="lblMessage" runat="server"></asp:Label>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </asp:Panel>

                        <!-- 用戶名稱與等級 -->
                        <h3 class="mb-1">
                            <asp:Label ID="lblUserName" runat="server"></asp:Label>
                        </h3>
                        <div class="level-badge mb-3">
                            <span class="badge bg-gradient-primary fs-5">
                                <i class="bi bi-trophy-fill"></i> Lv.<asp:Label ID="lblLevel" runat="server"></asp:Label>
                            </span>
                        </div>

                        <!-- 個人簡介 -->
                        <p class="text-muted">
                            <asp:Label ID="lblBio" runat="server" Text="這個用戶很懶，什麼都沒留下..."></asp:Label>
                        </p>

                        <hr />

                        <!-- 統計數據 -->
                        <div class="stats-grid">
                            <div class="stat-item">
                                <h4 class="mb-0 text-primary">
                                    <asp:Label ID="lblPoints" runat="server"></asp:Label>
                                </h4>
                                <small class="text-muted">積分</small>
                            </div>
                            <div class="stat-item">
                                <h4 class="mb-0 text-warning">
                                    <asp:Label ID="lblTotalExp" runat="server"></asp:Label>
                                </h4>
                                <small class="text-muted">經驗值</small>
                            </div>
                            <div class="stat-item">
                                <h4 class="mb-0 text-success">
                                    <asp:Label ID="lblTasksCompleted" runat="server"></asp:Label>
                                </h4>
                                <small class="text-muted">完成任務</small>
                            </div>
                            <div class="stat-item">
                                <h4 class="mb-0 text-info">
                                    <asp:Label ID="lblAchievements" runat="server"></asp:Label>
                                </h4>
                                <small class="text-muted">成就數</small>
                            </div>
                        </div>

                        <hr />

                        <!-- 註冊時間 -->
                        <small class="text-muted d-block">
                            <i class="bi bi-calendar-fill"></i>
                            註冊於 <asp:Label ID="lblRegisterDate" runat="server"></asp:Label>
                        </small>
                    </div>
                </div>

                <!-- 快速連結 -->
                <div class="card mt-3 shadow-sm">
                    <div class="card-body">
                        <h6 class="card-title mb-3"><i class="bi bi-link-45deg"></i> 快速連結</h6>
                        <div class="d-grid gap-2">
                            <asp:HyperLink ID="lnkMyTasks" runat="server" NavigateUrl="~/Tasks/MyTasks.aspx"
                                           CssClass="btn btn-outline-primary btn-sm">
                                <i class="bi bi-clipboard-check"></i> 我的任務
                            </asp:HyperLink>
                            <asp:HyperLink ID="lnkMyItems" runat="server" NavigateUrl="~/Profile/MyItems.aspx"
                                           CssClass="btn btn-outline-primary btn-sm">
                                <i class="bi bi-box-seam"></i> 我的道具
                            </asp:HyperLink>
                            <asp:HyperLink ID="lnkAchievements" runat="server" NavigateUrl="~/Profile/Achievements.aspx"
                                           CssClass="btn btn-outline-primary btn-sm">
                                <i class="bi bi-award-fill"></i> 我的成就
                            </asp:HyperLink>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 右側內容區域 -->
            <div class="col-md-8">
                <!-- 等級進度 -->
                <div class="card mb-4 shadow-sm">
                    <div class="card-body">
                        <h5 class="card-title mb-3">
                            <i class="bi bi-graph-up-arrow text-primary"></i> 等級進度
                        </h5>
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span>Lv.<asp:Label ID="lblCurrentLevel" runat="server"></asp:Label></span>
                            <span class="text-muted">
                                <asp:Label ID="lblExpProgress" runat="server"></asp:Label> / 
                                <asp:Label ID="lblExpRequired" runat="server"></asp:Label> EXP
                            </span>
                            <span>Lv.<asp:Label ID="lblNextLevel" runat="server"></asp:Label></span>
                        </div>
                        <div class="progress" style="height: 25px;">
                            <div class="progress-bar bg-gradient-primary" role="progressbar" 
                                 style="width: <%= GetLevelProgressWidth() %>%">
                                <asp:Label ID="lblLevelPercent" runat="server"></asp:Label>%
                            </div>
                        </div>
                        <p class="text-muted mt-2 mb-0">
                            <i class="bi bi-info-circle-fill"></i>
                            還需要 <strong><asp:Label ID="lblExpToNext" runat="server"></asp:Label> EXP</strong> 即可升級！
                        </p>
                    </div>
                </div>

                <!-- 最近活動 -->
                <div class="card shadow-sm">
                    <div class="card-header bg-white">
                        <h5 class="mb-0">
                            <i class="bi bi-clock-history text-primary"></i> 最近活動
                        </h5>
                    </div>
                    <div class="card-body">
                        <asp:Panel ID="pnlNoActivities" runat="server" Visible="false" 
                                   CssClass="text-center text-muted py-4">
                            <i class="bi bi-inbox fs-1"></i>
                            <p class="mt-2">暫無活動記錄</p>
                        </asp:Panel>

                        <asp:Repeater ID="rptRecentActivities" runat="server">
                            <ItemTemplate>
                                <div class="activity-item">
                                    <div class="d-flex">
                                        <div class="activity-icon me-3">
                                            <i class="bi bi-<%# GetActivityIcon(Eval("Type").ToString()) %> 
                                               text-<%# GetActivityColor(Eval("Type").ToString()) %>"></i>
                                        </div>
                                        <div class="flex-grow-1">
                                            <p class="mb-1"><%# Eval("Description") %></p>
                                            <small class="text-muted">
                                                <%# GetTimeAgo(Eval("Timestamp")) %>
                                            </small>
                                        </div>
                                        <div class="activity-value text-end">
                                            <%# GetAmountDisplay(Eval("Amount")) %>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 頭像裁切模態框 -->
    <div class="modal fade" id="avatarCropModal" tabindex="-1" aria-labelledby="avatarCropModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="avatarCropModalLabel">
                        <i class="bi bi-crop"></i> 裁切頭像
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="text-center mb-3">
                        <small class="text-muted">
                            <i class="bi bi-info-circle"></i> 
                            拖曳選擇要裁切的圓形區域
                        </small>
                    </div>
                    <div class="crop-container">
                        <img id="cropImage" style="max-width: 100%;" />
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle"></i> 取消
                    </button>
                    <button type="button" class="btn btn-primary" onclick="confirmCrop();">
                        <i class="bi bi-check-circle"></i> 確定裁切並上傳
                    </button>
                </div>
            </div>
        </div>
    </div>

    <style>
        /* 積分圖標樣式 */
        .coin-icon {
            width: 24px;
            height: 24px;
            vertical-align: middle;
            margin-right: 5px;
        }

        .coin-icon-small {
            width: 18px;
            height: 18px;
            vertical-align: middle;
            margin-right: 3px;
        }

        .coin-icon-inline {
            width: 20px;
            height: 20px;
            vertical-align: middle;
            margin-right: 3px;
        }

        .coin-icon-large {
            width: 32px;
            height: 32px;
            vertical-align: middle;
            margin-right: 8px;
        }
        .profile-card {
            border: none;
        }

        .avatar-wrapper {
            display: inline-block;
            margin-bottom: 1rem;
        }

        .avatar-large {
            width: 150px;
            height: 150px;
            object-fit: cover;
            border: 5px solid #667eea;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }

        .avatar-large:hover {
            transform: scale(1.05);
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            font-weight: 500;
            padding: 0.5rem 1.5rem;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.4);
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.6);
        }

        .bg-gradient-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1rem;
            margin: 1rem 0;
        }

        .stat-item {
            text-align: center;
        }

        .activity-item {
            padding: 1rem;
            border-bottom: 1px solid #e9ecef;
        }

        .activity-item:last-child {
            border-bottom: none;
        }

        .activity-icon {
            font-size: 1.5rem;
        }

        /* 裁切容器樣式 */
        .crop-container {
            max-height: 500px;
            overflow: hidden;
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 20px;
        }

        .modal-lg {
            max-width: 800px;
        }
    </style>

    <!-- Cropper.js CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css" />
    
    <!-- Cropper.js JavaScript -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.js"></script>

    <script type="text/javascript">
        let cropper = null;
        let currentFile = null;

        // 打開檔案選擇對話框
        function openAvatarUpload() {
            document.getElementById('<%=fuAvatar.ClientID%>').click();
        }

        // 處理檔案選擇
        function handleAvatarSelect(input) {
            if (input.files && input.files[0]) {
                currentFile = input.files[0];
                
                // 檢查檔案類型
                var allowedTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/gif'];
                if (!allowedTypes.includes(currentFile.type)) {
                    alert('僅支援 PNG、JPG、JPEG、GIF 格式的圖片檔案！');
                    input.value = '';
                    return;
                }

                // 檢查檔案大小（最大 10MB）
                var maxSize = 10 * 1024 * 1024;
                if (currentFile.size > maxSize) {
                    alert('圖片檔案大小不能超過 10MB！');
                    input.value = '';
                    return;
                }

                // 特殊處理 GIF 檔案
                if (currentFile.type === 'image/gif') {
                    var choice = confirm(
                        '??? 您選擇了 GIF 檔案\n\n' +
                        '【確定】= 保留動畫效果（直接上傳，可能不是完美圓形）\n' +
                        '【取消】= 裁切為圓形（失去動畫效果，變成靜態圖片）\n\n' +
                        '建議：如果是動畫 GIF，請點擊「確定」保留動畫'
                    );
                    
                    if (choice) {
                        // 用戶選擇保留動畫，直接上傳
                        uploadGifDirectly(currentFile);
                        return;
                    }
                    // 用戶選擇裁切，繼續正常流程
                }

                // 讀取圖片並顯示裁切界面
                var reader = new FileReader();
                reader.onload = function(e) {
                    showCropModal(e.target.result);
                };
                reader.readAsDataURL(currentFile);
            }
        }

        // 直接上傳 GIF（不裁切，保留動畫）
        function uploadGifDirectly(file) {
            var reader = new FileReader();
            reader.onload = function(e) {
                // 顯示預覽
                document.getElementById('<%=imgAvatar.ClientID%>').src = e.target.result;
                
                // 詢問確認
                if (confirm('預覽 GIF 動畫頭像。\n\n確定要上傳此頭像嗎？')) {
                    // 直接觸發後端上傳（不使用 HiddenField）
                    document.getElementById('<%=btnUploadAvatar.ClientID%>').click();
                } else {
                    // 取消，重新載入頁面
                    location.reload();
                }
            };
            reader.readAsDataURL(file);
        }

        // 顯示裁切模態框
        function showCropModal(imageData) {
            var image = document.getElementById('cropImage');
            image.src = imageData;

            // 顯示模態框
            var modal = new bootstrap.Modal(document.getElementById('avatarCropModal'));
            modal.show();

            // 初始化裁切器（在模態框完全顯示後）
            document.getElementById('avatarCropModal').addEventListener('shown.bs.modal', function () {
                if (cropper) {
                    cropper.destroy();
                }
                
                cropper = new Cropper(image, {
                    aspectRatio: 1, // 正方形比例
                    viewMode: 2,
                    dragMode: 'move',
                    autoCropArea: 0.8,
                    restore: false,
                    guides: true,
                    center: true,
                    highlight: false,
                    cropBoxMovable: true,
                    cropBoxResizable: true,
                    toggleDragModeOnDblclick: false,
                    // 圓形預覽
                    ready: function () {
                        // 添加圓形遮罩效果
                        var cropBox = document.querySelector('.cropper-crop-box');
                        if (cropBox) {
                            cropBox.style.borderRadius = '50%';
                        }
                        var face = document.querySelector('.cropper-face');
                        if (face) {
                            face.style.borderRadius = '50%';
                        }
                    }
                });
            }, { once: true });
        }

        // 確認裁切並上傳
        function confirmCrop() {
            if (!cropper) {
                alert('請先選擇圖片！');
                return;
            }

            // 獲取裁切後的圖片（圓形）
            var canvas = cropper.getCroppedCanvas({
                width: 300,
                height: 300,
                imageSmoothingEnabled: true,
                imageSmoothingQuality: 'high'
            });

            // 創建圓形遮罩
            var roundedCanvas = getRoundedCanvas(canvas);

            // 將圓形圖片轉換為 Base64
            var croppedImageData = roundedCanvas.toDataURL('image/png', 0.9);

            // 保存到 HiddenField
            document.getElementById('<%=hfCroppedImage.ClientID%>').value = croppedImageData;

            // 更新預覽
            document.getElementById('<%=imgAvatar.ClientID%>').src = croppedImageData;

            // 關閉模態框
            var modal = bootstrap.Modal.getInstance(document.getElementById('avatarCropModal'));
            modal.hide();

            // 清理裁切器
            if (cropper) {
                cropper.destroy();
                cropper = null;
            }

            // 確認上傳
            if (confirm('確定要上傳此頭像嗎？')) {
                document.getElementById('<%=btnUploadAvatar.ClientID%>').click();
            } else {
                // 取消上傳，還原圖片
                location.reload();
            }
        }

        // 創建圓形遮罩
        function getRoundedCanvas(sourceCanvas) {
            var canvas = document.createElement('canvas');
            var context = canvas.getContext('2d');
            var width = sourceCanvas.width;
            var height = sourceCanvas.height;

            canvas.width = width;
            canvas.height = height;

            // 繪製圓形裁切路徑
            context.beginPath();
            context.arc(width / 2, height / 2, Math.min(width, height) / 2, 0, 2 * Math.PI);
            context.closePath();
            context.clip();

            // 繪製圖片
            context.drawImage(sourceCanvas, 0, 0, width, height);

            return canvas;
        }

        // 清理：當模態框關閉時銷毀裁切器
        document.addEventListener('DOMContentLoaded', function() {
            var modal = document.getElementById('avatarCropModal');
            if (modal) {
                modal.addEventListener('hidden.bs.modal', function () {
                    if (cropper) {
                        cropper.destroy();
                        cropper = null;
                    }
                    // 清空檔案輸入
                    var fileInput = document.getElementById('<%=fuAvatar.ClientID%>');
                    if (fileInput) {
                        fileInput.value = '';
                    }
                });
            }
        });
    </script>
</asp:Content>
