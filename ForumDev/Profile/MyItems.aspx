<%@ Page Title="我的道具" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyItems.aspx.cs" Inherits="ForumDev.Profile.MyItems" %>
<%@ Import Namespace="System.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <!-- 頁面標題 -->
        <div class="row mb-4">
            <div class="col-md-8">
                <h1 class="display-5 fw-bold">
                    <i class="bi bi-box-seam text-primary"></i> 我的道具
                </h1>
                <p class="lead text-muted">管理您擁有的道具與商品</p>
            </div>
            <div class="col-md-4 text-end">
                <asp:HyperLink ID="lnkShop" runat="server" NavigateUrl="~/Shop/ItemShop.aspx"
                               CssClass="btn btn-primary">
                    <i class="bi bi-shop"></i> 前往商城
                </asp:HyperLink>
            </div>
        </div>

        <!-- 統計卡片 -->
        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="card stats-card shadow">
                    <div class="card-body text-center">
                        <h6 class="card-title text-muted">道具總數</h6>
                        <h2 class="mb-0 text-primary">
                            <asp:Label ID="lblTotalItems" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stats-card shadow">
                    <div class="card-body text-center">
                        <h6 class="card-title text-muted">道具種類</h6>
                        <h2 class="mb-0 text-success">
                            <asp:Label ID="lblItemTypes" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stats-card shadow">
                    <div class="card-body text-center">
                        <h6 class="card-title text-muted">總價值</h6>
                        <h2 class="mb-0 text-warning">
                            <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon" />
                            <asp:Label ID="lblTotalValue" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- 訊息顯示 -->
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
            <asp:Label ID="lblMessage" runat="server"></asp:Label>
        </asp:Panel>

        <!-- 道具列表 -->
        <asp:Panel ID="pnlNoItems" runat="server" Visible="false" CssClass="text-center py-5">
            <i class="bi bi-inbox fs-1 text-muted"></i>
            <p class="mt-3 text-muted fs-5">您還沒有任何道具</p>
            <p class="text-muted">前往商城購買道具吧！</p>
            <asp:HyperLink ID="lnkGoToShop" runat="server" NavigateUrl="~/Shop/ItemShop.aspx"
                           CssClass="btn btn-primary mt-2">
                前往積分商城
            </asp:HyperLink>
        </asp:Panel>

        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
            <asp:Repeater ID="rptMyItems" runat="server" OnItemCommand="rptMyItems_ItemCommand">
                <ItemTemplate>
                    <div class="col">
                        <div class="card item-card h-100 shadow-sm">
                            <div class="card-header bg-white border-0 pt-3">
                                <div class="d-flex justify-content-between align-items-start">
                                    <span class="badge bg-<%# GetTypeColor(Eval("Item.Type").ToString()) %>">
                                        <%# GetTypeName(Eval("Item.Type").ToString()) %>
                                    </span>
                                    <span class="badge bg-primary">
                                        數量: <%# Eval("Quantity") %>
                                    </span>
                                </div>
                            </div>
                            

                            <div class="card-body text-center">
                                <!-- 道具圖示 -->
                                <div class="item-icon mb-3 position-relative">
                                    <%# GetItemIcon(Eval("Item.IconUrl").ToString()) %>
                                    <button type="button" class="btn btn-light btn-sm zoom-btn" title="放大查看" onclick="openMyItemIconZoom(this)">
                                        <i class="bi bi-zoom-in"></i>
                                    </button>
                                    <span class="d-none item-icon-src" data-iconurl='<%# Eval("Item.IconUrl") %>' data-itemtype='<%# Eval("Item.Type") %>'></span>
                                </div>

                                <!-- 道具名稱 -->
                                <h5 class="card-title mb-2"><%# Eval("Item.ItemName") %></h5>
                                
                                <!-- 道具描述 -->
                                <p class="card-text text-muted small">
                                    <%# Eval("Item.Description") %>
                                </p>

                                <!-- 價值資訊 -->
                                <div class="value-section mb-3">
                                    <small class="text-muted">單價:</small>
                                    <h5 class="text-primary mb-0">
                                        <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon" />
                                        <%# Eval("Item.Price") %> 積分
                                    </h5>
                                </div>

                                <!-- 取得時間 -->
                                <small class="text-muted d-block mb-3">
                                    <i class="bi bi-calendar-fill"></i>
                                    取得於 <%# Eval("ObtainDate", "{0:yyyy/MM/dd}") %>
                                </small>

                                <!-- 操作按鈕 -->
                                <div class="d-grid gap-2">
                                    <!-- 一般道具的使用按鈕 -->
                                    <asp:Button ID="btnUse" runat="server" 
                                                CommandName="Use" 
                                                CommandArgument='<%# Eval("UserItemID") %>'
                                                Text="使用道具" 
                                                CssClass="btn btn-success"
                                                Visible='<%# CanUseItem(Eval("Item.Type").ToString()) && Eval("Item.Type").ToString() != "Ticket" %>' />
                                    
                                    <!-- 抽獎券的特殊按鈕 -->
                                    <asp:HyperLink ID="lnkGoToLottery" runat="server" 
                                                   NavigateUrl="~/LotteryPages/LotteryList.aspx"
                                                   CssClass="btn btn-danger"
                                                   Visible='<%# Eval("Item.Type").ToString() == "Ticket" %>'>
                                        <i class="bi bi-gift-fill"></i> 前往抽獎中心使用
                                    </asp:HyperLink>
                                </div>
                            </div>

                            <!-- 卡片底部：查看詳情 -->
                            <div class="card-footer bg-light text-center">
                                <small>
                                    <a href="#" 
                                       class="text-decoration-none item-detail-link"
                                       data-useritemid='<%# Eval("UserItemID") %>'
                                       data-itemname='<%# HttpUtility.HtmlAttributeEncode(Eval("Item.ItemName").ToString()) %>'
                                       data-itemtype='<%# Eval("Item.Type") %>'
                                       data-typename='<%# HttpUtility.HtmlAttributeEncode(GetTypeName(Eval("Item.Type").ToString())) %>'
                                       data-iconurl='<%# Eval("Item.IconUrl") %>'
                                       data-description='<%# HttpUtility.HtmlAttributeEncode(Eval("Item.Description").ToString()) %>'
                                       data-price='<%# Eval("Item.Price") %>'
                                       data-quantity='<%# Eval("Quantity") %>'
                                       data-obtaindate='<%# Eval("ObtainDate", "{0:yyyy/MM/dd HH:mm}") %>'>
                                        <i class="bi bi-info-circle"></i> 查看詳情
                                    </a>
                                </small>
                            </div>

                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <!-- 道具詳情 Modal -->
    <div class="modal fade" id="itemDetailModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-gradient-primary text-white">
                    <h5 class="modal-title">
                        <i class="bi bi-info-circle-fill"></i> 道具詳情
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfSelectedItemID" runat="server" />
                    <div class="row">
                        <!-- 左側：圖示 -->
                        <div class="col-md-5 text-center border-end">
                            <div id="myModalIconHolder" class="item-detail-icon mb-3">
                                <i id="modalItemIcon" class="fa-solid fa-box fa-5x text-primary"></i>
                                <button type="button" class="btn btn-light btn-sm zoom-btn" title="放大查看" onclick="openMyIconZoom()">
                                    <i class="bi bi-zoom-in"></i>
                                </button>
                            </div>
                            <h4 id="modalItemName" class="mb-2">道具名稱</h4>
                            <span id="modalItemType" class="badge bg-primary mb-3">類別</span>
                            
                            <!-- 數量和取得時間 -->
                            <div class="alert alert-info mt-3">
                                <div class="mb-2">
                                    <i class="bi bi-stack"></i>
                                    <strong>擁有數量：</strong>
                                    <span id="modalItemQuantity" class="badge bg-primary">0</span>
                                </div>
                                <div>
                                    <i class="bi bi-calendar-event"></i>
                                    <strong>取得時間：</strong>
                                    <br />
                                    <span id="modalObtainDate" class="text-muted">2024/01/01</span>
                                </div>
                            </div>
                        </div>

                        <!-- 右側：詳細資訊 -->
                        <div class="col-md-7">
                            <h6 class="text-muted mb-3">
                                <i class="bi bi-card-text"></i> 道具說明
                            </h6>
                            <p id="modalItemDescription" class="mb-4">道具描述...</p>

                            <!-- 價值資訊 -->
                            <div class="card mb-3">
                                <div class="card-body">
                                    <h6 class="card-title">
                                        <i class="bi bi-coin"></i> 價值資訊
                                    </h6>
                                    <div class="row text-center">
                                        <div class="col-6">
                                            <small class="text-muted">單價</small>
                                            <h5 class="text-primary mb-0">
                                                <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon-small" />
                                                <span id="modalItemPrice">0</span>
                                            </h5>
                                        </div>
                                        <div class="col-6">
                                            <small class="text-muted">總價值</small>
                                            <h5 class="text-success mb-0">
                                                <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon-small" />
                                                <span id="modalTotalValue">0</span>
                                            </h5>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- 使用說明 -->
                            <div class="card bg-light">
                                <div class="card-body">
                                    <h6 class="card-title">
                                        <i class="bi bi-lightbulb-fill"></i> 使用說明
                                    </h6>
                                    <p id="modalUsageInfo" class="mb-0 small">使用說明...</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle"></i> 關閉
                    </button>
                    <asp:Button ID="btnUseInModal" runat="server" 
                                Text="立即使用" 
                                CssClass="btn btn-success" 
                                OnClick="btnUseInModal_Click"
                                style="display:none;" />
                    <a id="btnGoToLotteryInModal" href="/LotteryPages/LotteryList.aspx" 
                       class="btn btn-danger" style="display:none;">
                        <i class="bi bi-gift-fill"></i> 前往抽獎中心
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- 圖標放大 Modal -->
    <div class="modal fade" id="iconZoomModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-zoom-in"></i> 圖標放大</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center">
                    <div id="zoomIconHolder" class="zoom-holder"></div>
                </div>
            </div>
        </div>
    </div>

    <style>
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

        .bg-gradient-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .bg-gradient-success {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
        }

        .bg-gradient-info {
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
        }

        /* ========== 統計卡片暗色主題樣式 ========== */
        .stats-card {
            border: 1px solid rgba(108, 92, 231, 0.3);
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.9) 0%, rgba(22, 33, 62, 0.9) 100%);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .stats-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(108, 92, 231, 0.3);
            border-color: rgba(108, 92, 231, 0.5);
        }

        .stats-card .card-title {
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .stats-card h2 {
            font-size: 2.5rem;
            font-weight: bold;
            text-shadow: 0 0 10px currentColor;
        }

        .item-card {
            border: none;
            transition: all 0.3s ease;
        }

        .item-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.15) !important;
        }

        .value-section {
            padding: 10px;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            border-radius: 8px;
        }

        .item-detail-icon {
            position: relative;
            padding: 30px;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            border-radius: 15px;
            margin: 20px auto;
        }

        /* 統一道具圖片大小（與商城一致） */
        .item-image {
            width: 100px;
            height: 100px;
            object-fit: contain;
            transition: transform 0.3s ease;
        }

        .item-image:hover {
            transform: scale(1.05);
        }

        .item-icon {
            min-height: 120px;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .zoom-btn {
            position: absolute;
            top: 8px;
            right: 8px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        }

        .zoom-holder img {
            max-width: 100%;
            width: 320px;
            height: 320px;
            object-fit: contain;
        }
        .zoom-holder i.bi, .zoom-holder i.fa-solid, .zoom-holder i.fas, .zoom-holder i.far {
            font-size: 8rem;
            color: #6752d1;
        }

        .modal-header.bg-gradient-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
    </style>

    <script>
        function hasPrefix(s, prefix) { return typeof s === 'string' && s.indexOf(prefix) === 0; }
        function containsStr(s, needle) { return typeof s === 'string' && s.indexOf(needle) >= 0; }
        function isFaIcon(s) { return containsStr(s, 'fa-') || hasPrefix(s, 'fa ') || containsStr(s, 'fa-solid') || hasPrefix(s, 'far ') || hasPrefix(s, 'fas '); }
        function isBiIcon(s) { return containsStr(s, 'bi-'); }
        function closestByClass(el, className) {
            var node = el;
            while (node) {
                if (node.classList && node.classList.contains(className)) return node;
                node = node.parentNode;
            }
            return null;
        }

        // 使用事件委託處理查看詳情點擊（立即附加，避免 DOMContentLoaded 已觸發時未綁定）
        (function attachMyItemDetailHandler() {
            function clickHandler(e) {
                e = e || window.event;
                var target = e.target || e.srcElement;
                var link = closestByClass(target, 'item-detail-link');
                if (!link) return;
                if (e.preventDefault) e.preventDefault(); else e.returnValue = false;
                
                var userItemId = parseInt(link.getAttribute('data-useritemid'));
                var itemName = link.getAttribute('data-itemname');
                var itemType = link.getAttribute('data-itemtype');
                var itemTypeName = link.getAttribute('data-typename');
                var iconUrl = link.getAttribute('data-iconurl');
                var description = link.getAttribute('data-description');
                var price = parseInt(link.getAttribute('data-price'));
                var quantity = parseInt(link.getAttribute('data-quantity'));
                var obtainDate = link.getAttribute('data-obtaindate');
                
                showItemDetail(userItemId, itemName, itemType, itemTypeName, iconUrl, description, price, quantity, obtainDate);
            }

            if (document.addEventListener) {
                document.addEventListener('click', clickHandler, false);
            } else if (document.attachEvent) {
                document.attachEvent('onclick', clickHandler);
            }
        })();

        // 顯示道具詳情
        function showItemDetail(userItemId, itemName, itemType, itemTypeName, iconUrl, description, price, quantity, obtainDate) {
            try {
                // 設定 HiddenField
                var hidden = document.getElementById('<%= hfSelectedItemID.ClientID %>');
                if (hidden) hidden.value = userItemId;
                
                // 設定圖示 - 支援本地圖片和 Font Awesome 圖示
                var holder = document.getElementById('myModalIconHolder');
                if (holder) holder.innerHTML = '';
                
                if (isFaIcon(iconUrl)) {
                    var i = document.createElement('i');
                    var cls = iconUrl;
                    if (hasPrefix(iconUrl, 'fa-')) cls = 'fa-solid ' + iconUrl;
                    i.className = cls + ' fa-5x text-primary';
                    holder && holder.appendChild(i);
                    holder.setAttribute('data-icontype', 'fa');
                    holder.setAttribute('data-iconclass', i.className);
                    holder.removeAttribute('data-image');
                } else if (isBiIcon(iconUrl)) {
                    var bi = document.createElement('i');
                    var cls2 = iconUrl;
                    if (hasPrefix(iconUrl, 'bi-')) cls2 = 'bi ' + iconUrl;
                    bi.className = cls2 + ' text-primary';
                    bi.style.fontSize = '4rem';
                    holder && holder.appendChild(bi);
                    holder.setAttribute('data-icontype', 'bi');
                    holder.setAttribute('data-iconclass', bi.className);
                    holder.removeAttribute('data-image');
                } else {
                    var img = document.createElement('img');
                    var imagePath = iconUrl || '';
                    
                    if (hasPrefix(imagePath, '~/')) {
                        imagePath = imagePath.substring(1);
                    } else if (imagePath && !hasPrefix(imagePath, '/') && !hasPrefix(imagePath, 'http://') && !hasPrefix(imagePath, 'https://')) {
                        imagePath = '/Images/Items/' + imagePath;
                    }
                    
                    img.src = imagePath || '/Images/Items/default.png';
                    img.alt = '道具圖標';
                    img.className = 'item-image';
                    img.style.width = '120px';
                    img.style.height = '120px';
                    img.style.objectFit = 'contain';
                    holder && holder.appendChild(img);
                    holder.setAttribute('data-icontype', 'img');
                    holder.setAttribute('data-image', img.src);
                    holder.removeAttribute('data-iconclass');
                }
                
                // 設定基本資訊
                var nameEl = document.getElementById('modalItemName'); if (nameEl) nameEl.textContent = itemName || '';
                var typeEl = document.getElementById('modalItemType');
                if (typeEl) {
                    typeEl.textContent = itemTypeName || '';
                    typeEl.className = 'badge bg-' + getTypeColor(itemType) + ' mb-3';
                }
                
                // 設定數量和時間
                var qEl = document.getElementById('modalItemQuantity');
                if (qEl) qEl.textContent = isNaN(quantity) ? '0' : quantity;
                var dEl = document.getElementById('modalObtainDate');
                if (dEl) dEl.textContent = obtainDate || '';
                
                // 設定描述
                var descEl = document.getElementById('modalItemDescription');
                if (descEl) descEl.textContent = description || '此道具暫無詳細說明';
                
                // 設定價格
                var priceEl = document.getElementById('modalItemPrice');
                if (priceEl) priceEl.textContent = isNaN(price) ? '0' : price;
                var totalEl = document.getElementById('modalTotalValue');
                if (totalEl) totalEl.textContent = isNaN(price) || isNaN(quantity) ? '0' : (price * quantity).toLocaleString();
                
                // 設定使用說明
                var usageInfo = getUsageInfo(itemType);
                var usageEl = document.getElementById('modalUsageInfo');
                if (usageEl) usageEl.textContent = usageInfo;
                
                // 顯示/隱藏按鈕
                var btnUse = document.getElementById('<%= btnUseInModal.ClientID %>');
                var btnLottery = document.getElementById('btnGoToLotteryInModal');
                
                if (btnUse) btnUse.style.display = 'none';
                if (btnLottery) btnLottery.style.display = 'none';
                
                if (itemType === 'Ticket') {
                    if (btnLottery) btnLottery.style.display = 'inline-block';
                } else if (itemType !== 'Physical') {
                    if (btnUse) btnUse.style.display = 'inline-block';
                }
                
                // 開啟 Modal
                var modalEl = document.getElementById('itemDetailModal');
                if (modalEl && window.bootstrap && bootstrap.Modal) {
                    var modal = new bootstrap.Modal(modalEl);
                    modal.show();
                }
            } catch (error) {
                if (window.console && console.error) console.error('顯示道具詳情時發生錯誤:', error);
                alert('無法顯示道具詳情，請稍後再試。');
            }
        }

        // 放大鏡：卡片上的放大（從卡片項目取 icon 資訊）
        function openMyItemIconZoom(btn) {
            try {
                var container = btn && btn.parentNode;
                var hidden = container && container.querySelector('.item-icon-src');
                var zoom = document.getElementById('zoomIconHolder');
                if (!hidden || !zoom) return;
                zoom.innerHTML = '';

                var iconUrl = hidden.getAttribute('data-iconurl') || '';
                if (isFaIcon(iconUrl)) {
                    var i = document.createElement('i');
                    var cls = iconUrl;
                    if (hasPrefix(iconUrl, 'fa-')) cls = 'fa-solid ' + iconUrl;
                    i.className = cls + ' fa-8x text-primary';
                    zoom.appendChild(i);
                } else if (isBiIcon(iconUrl)) {
                    var bi = document.createElement('i');
                    var cls2 = iconUrl;
                    if (hasPrefix(iconUrl, 'bi-')) cls2 = 'bi ' + iconUrl;
                    bi.className = cls2 + ' text-primary';
                    bi.style.fontSize = '8rem';
                    zoom.appendChild(bi);
                } else {
                    var img = document.createElement('img');
                    var imagePath = iconUrl;
                    if (hasPrefix(imagePath, '~/')) imagePath = imagePath.substring(1);
                    else if (imagePath && !hasPrefix(imagePath, '/') && !hasPrefix(imagePath, 'http://') && !hasPrefix(imagePath, 'https://')) {
                        imagePath = '/Images/Items/' + imagePath;
                    }
                    img.src = imagePath || '/Images/Items/default.png';
                    img.alt = '道具圖標放大';
                    zoom.appendChild(img);
                }

                var modalEl = document.getElementById('iconZoomModal');
                if (modalEl) {
                    var modal = new bootstrap.Modal(modalEl);
                    modal.show();
                }
            } catch (ex) {
                if (window.console && console.error) console.error('openMyItemIconZoom error:', ex);
            }
        }

        // 放大鏡：從詳情 Modal 的 holder 取得資料
        function openMyIconZoom() {
            try {
                var holder = document.getElementById('myModalIconHolder');
                var zoom = document.getElementById('zoomIconHolder');
                if (!holder || !zoom) return;
                zoom.innerHTML = '';

                var type = holder.getAttribute('data-icontype');
                if (type === 'fa' || type === 'bi') {
                    var i = document.createElement('i');
                    var cls = holder.getAttribute('data-iconclass') || '';
                    i.className = cls;
                    if (type === 'fa') {
                        i.className += ' fa-8x';
                    } else {
                        i.style.fontSize = '8rem';
                    }
                    zoom.appendChild(i);
                } else {
                    var img = document.createElement('img');
                    img.src = holder.getAttribute('data-image') || '/Images/Items/default.png';
                    img.alt = '道具圖標放大';
                    zoom.appendChild(img);
                }

                var modalEl = document.getElementById('iconZoomModal');
                if (modalEl) {
                    var modal = new bootstrap.Modal(modalEl);
                    modal.show();
                }
            } catch (ex) {
                if (window.console && console.error) console.error('openMyIconZoom error:', ex);
            }
        }
        
        function getTypeColor(type) {
            switch (type) {
                case 'Booster': return 'warning';
                case 'Coupon': return 'success';
                case 'Physical': return 'primary';
                case 'Ticket': return 'danger';
                default: return 'secondary';
            }
        }
        
        function getUsageInfo(type) {
            switch (type) {
                case 'Booster':
                    return '使用後立即獲得 50 點經驗值，幫助您快速升級！';
                case 'Coupon':
                    return '使用後立即獲得 100 積分，可用於購買商品道具與參與活動。';
                case 'Ticket':
                    return '請前往「抽獎活動」使用此抽獎券，可參與各種精彩抽獎活動，有機會獲得稀有獎勵！';
                case 'Physical':
                    return '這是實體商品，請聯繫客服人員安排取貨與配送事宜。';
                default:
                    return '點擊使用按鈕即可使用此道具。';
            }
        }
    </script>
</asp:Content>
