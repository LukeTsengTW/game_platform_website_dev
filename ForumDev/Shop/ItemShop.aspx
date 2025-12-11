<%@ Page Title="積分商城" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ItemShop.aspx.cs" Inherits="ForumDev.Shop.ItemShop" %>
<%@ Import Namespace="System.Web" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <!-- 頁面標題與用戶積分 -->
        <div class="row mb-4">
            <div class="col-md-8">
                <h1 class="display-5 fw-bold">
                    <i class="bi bi-shop text-primary"></i> 積分商城
                </h1>
                <p class="lead text-muted">使用積分兌換精美商品與道具！</p>
            </div>
            <div class="col-md-4 text-end">
                <div class="card bg-gradient-primary text-white shadow">
                    <div class="card-body">
                        <h6 class="mb-1">我的積分</h6>
                        <h2 class="mb-0">
                            <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon" />
                            <asp:Label ID="lblUserPoints" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- 商品分類篩選 -->
        <div class="card mb-4 shadow-sm">
            <div class="card-body">
                <div class="row g-3 align-items-center">
                    <div class="col-md-4">
                        <label class="form-label fw-bold">
                            <i class="bi bi-funnel-fill"></i> 商品類別
                        </label>
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select" 
                                          AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                            <asp:ListItem Value="" Text="全部商品"></asp:ListItem>
                            <asp:ListItem Value="Booster" Text="加速道具"></asp:ListItem>
                            <asp:ListItem Value="Coupon" Text="優惠券"></asp:ListItem>
                            <asp:ListItem Value="Physical" Text="實體商品"></asp:ListItem>
                            <asp:ListItem Value="Ticket" Text="抽獎券"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label fw-bold">
                            <i class="bi bi-sort-down"></i> 排序方式
                        </label>
                        <asp:DropDownList ID="ddlSort" runat="server" CssClass="form-select" 
                                          AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                            <asp:ListItem Value="default" Text="預設排序"></asp:ListItem>
                            <asp:ListItem Value="price_asc" Text="價格 (低到高)"></asp:ListItem>
                            <asp:ListItem Value="price_desc" Text="價格 (高到低)"></asp:ListItem>
                            <asp:ListItem Value="popular" Text="最受歡迎"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">&nbsp;</label>
                        <asp:HyperLink ID="lnkMyItems" runat="server" NavigateUrl="~/Profile/MyItems.aspx"
                                       CssClass="btn btn-outline-primary w-100">
                            <i class="bi bi-box-seam"></i> 我的道具
                        </asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>

        <!-- 訊息顯示 -->
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
            <asp:Label ID="lblMessage" runat="server"></asp:Label>
        </asp:Panel>

        <!-- 商品列表 -->
        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
            <asp:Repeater ID="rptItems" runat="server" OnItemCommand="rptItems_ItemCommand">
                <ItemTemplate>
                    <div class="col">
                        <div class="card item-card h-100 shadow-sm">
                            <div class="card-header bg-white border-0 pt-3">
                                <div class="d-flex justify-content-between align-items-start">
                                    <span class="badge bg-<%# GetTypeColor(Eval("Type").ToString()) %>">
                                        <%# GetTypeName(Eval("Type").ToString()) %>
                                    </span>
                                    <span class="badge bg-light text-dark">
                                        <%# GetStockText(Eval("Stock")) %>
                                    </span>
                                </div>
                            </div>
                            
                            <div class="card-body text-center">
                                <!-- 商品圖示 -->
                                <div class="item-icon mb-3 position-relative">
                                    <%# GetItemIcon(Eval("IconUrl").ToString()) %>
                                    <button type="button" class="btn btn-light btn-sm zoom-btn" title="放大查看" onclick="openShopItemIconZoom(this)">
                                        <i class="bi bi-zoom-in"></i>
                                    </button>
                                    <span class="d-none item-icon-src" data-iconurl='<%# Eval("IconUrl") %>' data-itemtype='<%# Eval("Type") %>'></span>
                                </div>

                                <!-- 商品名稱 -->
                                <h5 class="card-title mb-2"><%# Eval("ItemName") %></h5>
                                
                                <!-- 商品描述 -->
                                <p class="card-text text-muted small">
                                    <%# Eval("Description") %>
                                </p>

                                <!-- 價格 -->
                                <div class="price-section mb-3">
                                    <h3 class="text-primary mb-0">
                                        <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon" />
                                        <%# Eval("Price") %> 積分
                                    </h3>
                                </div>

                                <!-- 購買按鈕 -->
                                <div class="d-grid gap-2">
                                    <asp:Button ID="btnPurchase" runat="server" 
                                                CommandName="Purchase" 
                                                CommandArgument='<%# Eval("ItemID") %>'
                                                Text="立即兌換" 
                                                CssClass="btn btn-primary"
                                                Visible='<%# User.Identity.IsAuthenticated && IsInStock(Eval("Stock")) %>' />
                                
                                    <!-- 庫存不足提示 -->
                                    <div class="alert alert-warning mb-0" 
                                         visible='<%# !IsInStock(Eval("Stock")) %>' runat="server">
                                        <i class="bi bi-exclamation-triangle-fill"></i> 庫存不足
                                    </div>

                                    <!-- 未登入提示 -->
                                    <asp:HyperLink ID="lnkLoginToPurchase" runat="server" 
                                                   NavigateUrl="~/Account/Login.aspx"
                                                   CssClass="btn btn-outline-primary"
                                                   Visible='<%# !User.Identity.IsAuthenticated %>'>
                                        登入後購買
                                    </asp:HyperLink>
                                </div>
                            </div>

                            <!-- 卡片底部：查看詳情 -->
                            <div class="card-footer bg-light text-center">
                                <small>
                                    <a href="#" 
                                       class="text-decoration-none shop-item-detail-link"
                                       data-itemid='<%# Eval("ItemID") %>'
                                       data-itemname='<%# HttpUtility.HtmlAttributeEncode(Eval("ItemName").ToString()) %>'
                                       data-itemtype='<%# Eval("Type") %>'
                                       data-typename='<%# HttpUtility.HtmlAttributeEncode(GetTypeName(Eval("Type").ToString())) %>'
                                       data-iconurl='<%# Eval("IconUrl") %>'
                                       data-description='<%# HttpUtility.HtmlAttributeEncode(Eval("Description").ToString()) %>'
                                       data-price='<%# Eval("Price") %>'
                                       data-stock='<%# Eval("Stock") == null || Eval("Stock") == DBNull.Value ? "" : Eval("Stock").ToString() %>'>
                                        <i class="bi bi-info-circle"></i> 查看詳情
                                    </a>
                                </small>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- 空狀態 -->
        <asp:Panel ID="pnlNoItems" runat="server" Visible="false" CssClass="text-center py-5">
            <i class="bi bi-inbox fs-1 text-muted"></i>
            <p class="mt-3 text-muted">目前沒有符合條件的商品</p>
        </asp:Panel>
    </div>

    <!-- 購買確認 Modal -->
    <div class="modal fade" id="confirmModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-cart-check-fill text-success"></i> 兌換成功
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center py-4">
                    <i class="bi bi-check-circle-fill text-success" style="font-size: 4rem;"></i>
                    <h4 class="mt-3">恭喜！兌換成功</h4>
                    <p class="text-muted">商品已加入您的道具庫存</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">關閉</button>
                    <a href="/Profile/MyItems.aspx" class="btn btn-primary">查看我的道具</a>
                </div>
            </div>
        </div>
    </div>

    <!-- 商品詳情 Modal -->
    <div class="modal fade" id="shopItemDetailModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-gradient-primary text-white">
                    <h5 class="modal-title">
                        <i class="bi bi-info-circle-fill"></i> 商品詳情
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <asp:HiddenField ID="hfSelectedItemID" runat="server" />
                    <div class="row">
                        <!-- 左側：圖示 -->
                        <div class="col-md-5 text-center border-end">
                            <div id="shopModalIconHolder" class="item-detail-icon mb-3">
                                <i id="shopModalItemIcon" class="fa-solid fa-box fa-5x text-primary"></i>
                                <button type="button" class="btn btn-light btn-sm zoom-btn" title="放大查看" onclick="openShopIconZoom()">
                                    <i class="bi bi-zoom-in"></i>
                                </button>
                            </div>
                            <h4 id="shopModalItemName" class="mb-2">商品名稱</h4>
                            <span id="shopModalItemType" class="badge bg-primary mb-3">類別</span>
                            
                            <!-- 庫存狀況 -->
                            <div class="alert alert-success mt-3">
                                <i class="bi bi-box-seam"></i>
                                <strong>庫存狀況：</strong>
                                <br />
                                <span id="shopModalStock" class="badge bg-success">充足</span>
                            </div>
                        </div>

                        <!-- 右側：詳細資訊 -->
                        <div class="col-md-7">
                            <h6 class="text-muted mb-3">
                                <i class="bi bi-card-text"></i> 商品說明
                            </h6>
                            <p id="shopModalItemDescription" class="mb-4">商品描述...</p>

                            <!-- 價格資訊 -->
                            <div class="card mb-3 border-primary">
                                <div class="card-body text-center">
                                    <h6 class="card-title text-muted">
                                        <i class="bi bi-coin"></i> 兌換所需積分
                                    </h6>
                                    <h2 class="text-primary mb-0">
                                        <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon" />
                                        <span id="shopModalItemPrice">0</span> 積分
                                    </h2>
                                </div>
                            </div>

                            <!-- 商品特色 -->
                            <div class="card bg-light">
                                <div class="card-body">
                                    <h6 class="card-title">
                                        <i class="bi bi-star-fill text-warning"></i> 商品特色
                                    </h6>
                                    <ul id="shopModalFeatures" class="mb-0 small">
                                        <li>高品質商品</li>
                                        <li>兌換後立即生效</li>
                                        <li>物超所值</li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="bi bi-x-circle"></i> 關閉
                    </button>
                    <asp:Button ID="btnPurchaseInModal" runat="server" 
                                Text="立即兌換" 
                                CssClass="btn btn-primary" 
                                OnClick="btnPurchaseInModal_Click" />
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
        .bg-gradient-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .item-card {
            border: none;
            transition: all 0.3s ease;
        }

        .item-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.15) !important;
        }

        .price-section {
            padding: 1rem;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            border-radius: 10px;
        }

        .hover-lift {
            transition: transform 0.3s ease;
        }

        .hover-lift:hover {
            transform: translateY(-5px);
        }

        .item-image {
            width: 100px;
            height: 100px;
            object-fit: contain;
            transition: transform 0.3s ease;
        }

        .item-image:hover {
            transform: scale(1.1);
        }

        .item-icon {
            min-height: 120px;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .item-detail-icon {
            position: relative;
            padding: 30px;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            border-radius: 15px;
            margin: 20px auto;
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

        // 如果有成功訊息，顯示 Modal
        function showSuccessModal() {
            var modal = new bootstrap.Modal(document.getElementById('confirmModal'));
            modal.show();
        }

        // 附加「查看詳情」事件（避免 DOMContentLoaded 註冊時機問題）
        (function attachShopDetailHandler() {
            function clickHandler(e) {
                e = e || window.event;
                var target = e.target || e.srcElement;
                var link = closestByClass(target, 'shop-item-detail-link');
                if (!link) return;
                if (e.preventDefault) e.preventDefault(); else e.returnValue = false;

                var itemId = parseInt(link.getAttribute('data-itemid'));
                var itemName = link.getAttribute('data-itemname');
                var itemType = link.getAttribute('data-itemtype');
                var itemTypeName = link.getAttribute('data-typename');
                var iconUrl = link.getAttribute('data-iconurl');
                var description = link.getAttribute('data-description');
                var price = parseInt(link.getAttribute('data-price'));
                var stockStr = link.getAttribute('data-stock');
                var stock = stockStr === '' ? null : parseInt(stockStr);
                
                showShopItemDetail(itemId, itemName, itemType, itemTypeName, iconUrl, description, price, stock);
            }

            if (document.addEventListener) {
                document.addEventListener('click', clickHandler, false);
            } else if (document.attachEvent) {
                document.attachEvent('onclick', clickHandler);
            }
        })();

        // 顯示商品詳情
        function showShopItemDetail(itemId, itemName, itemType, itemTypeName, iconUrl, description, price, stock) {
            try {
                // 設定 HiddenField
                var hidden = document.getElementById('<%= hfSelectedItemID.ClientID %>');
                if (hidden) hidden.value = itemId;
                
                // 設定圖示 - 支援本地圖片和 Font Awesome 圖示
                var holder = document.getElementById('shopModalIconHolder');
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
                    img.alt = '商品圖標';
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
                var nameEl = document.getElementById('shopModalItemName'); if (nameEl) nameEl.textContent = itemName || '';
                var typeEl = document.getElementById('shopModalItemType');
                if (typeEl) {
                    typeEl.textContent = itemTypeName || '';
                    typeEl.className = 'badge bg-' + getTypeColor(itemType) + ' mb-3';
                }
                
                // 設定庫存
                var stockText = stock === null ? '無限供應' : (stock > 0 ? '庫存充足' : '暫時缺貨');
                var stockClass = stock === null || stock > 0 ? 'success' : 'danger';
                var stockEl = document.getElementById('shopModalStock');
                if (stockEl) {
                    stockEl.textContent = stockText;
                    stockEl.className = 'badge bg-' + stockClass;
                }
                
                // 設定描述
                var descEl = document.getElementById('shopModalItemDescription');
                if (descEl) descEl.textContent = description || '此商品暫無詳細說明';
                
                // 設定價格
                var priceEl = document.getElementById('shopModalItemPrice');
                if (priceEl) priceEl.textContent = isNaN(price) ? '0' : price;
                
                // 設定特色
                var features = getItemFeatures(itemType);
                var featuresList = document.getElementById('shopModalFeatures');
                if (featuresList) {
                    featuresList.innerHTML = '';
                    for (var idx = 0; idx < features.length; idx++) {
                        var li = document.createElement('li');
                        li.textContent = features[idx];
                        featuresList.appendChild(li);
                    }
                }
                
                // 控制購買按鈕
                var btnPurchase = document.getElementById('<%= btnPurchaseInModal.ClientID %>');
                if (btnPurchase) {
                    if (stock !== null && stock <= 0) {
                        btnPurchase.disabled = true;
                        btnPurchase.textContent = '暫時缺貨';
                    } else {
                        btnPurchase.disabled = false;
                        btnPurchase.textContent = '立即兌換';
                    }
                }
                
                // 開啟 Modal
                var modalEl = document.getElementById('shopItemDetailModal');
                if (modalEl && window.bootstrap && bootstrap.Modal) {
                    var modal = new bootstrap.Modal(modalEl);
                    modal.show();
                }
            } catch (error) {
                if (window.console && console.error) console.error('顯示商品詳情時發生錯誤:', error);
                alert('無法顯示商品詳情，請稍後再試。');
            }
        }

        // 放大鏡：卡片上的放大（從卡片項目取 icon 資訊）
        function openShopItemIconZoom(btn) {
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
                    img.alt = '商品圖標放大';
                    zoom.appendChild(img);
                }

                var modalEl = document.getElementById('iconZoomModal');
                if (modalEl) {
                    var modal = new bootstrap.Modal(modalEl);
                    modal.show();
                }
            } catch (ex) {
                if (window.console && console.error) console.error('openShopItemIconZoom error:', ex);
            }
        }

        // 放大鏡：從詳情 Modal 的 holder 取得資料
        function openShopIconZoom() {
            try {
                var holder = document.getElementById('shopModalIconHolder');
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
                    img.alt = '商品圖標放大';
                    zoom.appendChild(img);
                }

                var modalEl = document.getElementById('iconZoomModal');
                if (modalEl) {
                    var modal = new bootstrap.Modal(modalEl);
                    modal.show();
                }
            } catch (ex) {
                if (window.console && console.error) console.error('openShopIconZoom error:', ex);
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
        
        function getItemFeatures(type) {
            switch (type) {
                case 'Booster':
                    return ['立即獲得 50 點經驗值','使用後即時生效','快速提升等級'];
                case 'Coupon':
                    return ['立即獲得 100 積分','可用於商城消費','可參與抽獎活動','永久有效'];
                case 'Ticket':
                    return ['可參與指定抽獎活動','中獎機率高','豐富獎品等你拿','到抽獎中心使用'];
                case 'Physical':
                    return ['精美實體商品','需聯繫客服兌換','全新正品保證','限量供應'];
                default:
                    return ['高品質商品','兌換後立即生效','物超所值','值得擁有'];
            }
        }
    </script>
</asp:Content>
