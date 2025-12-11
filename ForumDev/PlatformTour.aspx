<%@ Page Title="平台功能導覽" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PlatformTour.aspx.cs" Inherits="ForumDev.PlatformTour" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <!-- 導覽標題 -->
        <div class="tour-header text-center mb-5">
            <h1 class="display-4 fw-bold">
                <i class="bi bi-compass-fill text-primary"></i> 平台功能導覽
            </h1>
            <p class="lead text-muted">讓我們一起探索平台的各項精彩功能！</p>
        </div>

        <!-- 進度條 -->
        <div class="tour-progress-section mb-5">
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h5 class="mb-0">
                            <i class="bi bi-bar-chart-fill"></i> 導覽進度
                        </h5>
                        <span class="badge bg-primary" id="progressText">0 / 6</span>
                    </div>
                    <div class="progress" style="height: 25px;">
                        <div class="progress-bar progress-bar-striped progress-bar-animated bg-success" 
                             role="progressbar" 
                             id="tourProgressBar"
                             style="width: 0%;" 
                             aria-valuenow="0" 
                             aria-valuemin="0" 
                             aria-valuemax="100">
                            <span id="progressPercent">0%</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 導覽步驟卡片 -->
        <div class="row g-4" id="tourSteps">
            <!-- 步驟 1: 個人中心 -->
            <div class="col-md-6 col-lg-4">
                <div class="card tour-step-card h-100 shadow" data-step="1" data-visited="false">
                    <div class="card-header bg-primary text-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="bi bi-1-circle-fill"></i> 個人中心
                            </h5>
                            <i class="bi bi-check-circle-fill step-completed-icon" style="display:none;"></i>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="step-icon mb-3 text-center">
                            <i class="bi bi-person-circle" style="font-size: 4rem; color: #667eea;"></i>
                        </div>
                        <h5 class="card-title">探索你的個人檔案</h5>
                        <p class="card-text">查看並編輯你的個人資料、頭像、等級和經驗值。</p>
                        <ul class="list-unstyled mb-3">
                            <li><i class="bi bi-check-circle text-success"></i> 查看個人資料</li>
                            <li><i class="bi bi-check-circle text-success"></i> 上傳頭像</li>
                            <li><i class="bi bi-check-circle text-success"></i> 編輯個人簡介</li>
                        </ul>
                    </div>
                    <div class="card-footer bg-light">
                        <asp:HyperLink ID="lnkProfile" runat="server" NavigateUrl="~/Profile/MyProfile.aspx" 
                                       CssClass="btn btn-primary w-100 visit-btn" data-step="1">
                            <i class="bi bi-arrow-right-circle"></i> 前往個人中心
                        </asp:HyperLink>
                    </div>
                </div>
            </div>

            <!-- 步驟 2: 任務中心 -->
            <div class="col-md-6 col-lg-4">
                <div class="card tour-step-card h-100 shadow" data-step="2" data-visited="false">
                    <div class="card-header bg-success text-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="bi bi-2-circle-fill"></i> 任務中心
                            </h5>
                            <i class="bi bi-check-circle-fill step-completed-icon" style="display:none;"></i>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="step-icon mb-3 text-center">
                            <i class="bi bi-clipboard-check" style="font-size: 4rem; color: #28a745;"></i>
                        </div>
                        <h5 class="card-title">接受並完成任務</h5>
                        <p class="card-text">瀏覽各類任務，選擇並完成挑戰，獲得豐富獎勵。</p>
                        <ul class="list-unstyled mb-3">
                            <li><i class="bi bi-check-circle text-success"></i> 查看任務列表</li>
                            <li><i class="bi bi-check-circle text-success"></i> 了解任務類型</li>
                            <li><i class="bi bi-check-circle text-success"></i> 開始第一個任務</li>
                        </ul>
                    </div>
                    <div class="card-footer bg-light">
                        <asp:HyperLink ID="lnkTasks" runat="server" NavigateUrl="~/Tasks/TaskList.aspx" 
                                       CssClass="btn btn-success w-100 visit-btn" data-step="2">
                            <i class="bi bi-arrow-right-circle"></i> 前往任務中心
                        </asp:HyperLink>
                    </div>
                </div>
            </div>

            <!-- 步驟 3: 積分商城 -->
            <div class="col-md-6 col-lg-4">
                <div class="card tour-step-card h-100 shadow" data-step="3" data-visited="false">
                    <div class="card-header bg-warning text-dark">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="bi bi-3-circle-fill"></i> 積分商城
                            </h5>
                            <i class="bi bi-check-circle-fill step-completed-icon" style="display:none;"></i>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="step-icon mb-3 text-center">
                            <i class="bi bi-shop" style="font-size: 4rem; color: #ffc107;"></i>
                        </div>
                        <h5 class="card-title">兌換精彩商品</h5>
                        <p class="card-text">使用積分購買道具、優惠券和實體商品。</p>
                        <ul class="list-unstyled mb-3">
                            <li><i class="bi bi-check-circle text-success"></i> 瀏覽商城</li>
                            <li><i class="bi bi-check-circle text-success"></i> 查看商品詳情</li>
                            <li><i class="bi bi-check-circle text-success"></i> 了解兌換流程</li>
                        </ul>
                    </div>
                    <div class="card-footer bg-light">
                        <asp:HyperLink ID="lnkShop" runat="server" NavigateUrl="~/Shop/ItemShop.aspx" 
                                       CssClass="btn btn-warning w-100 visit-btn" data-step="3">
                            <i class="bi bi-arrow-right-circle"></i> 前往積分商城
                        </asp:HyperLink>
                    </div>
                </div>
            </div>

            <!-- 步驟 4: 我的道具 -->
            <div class="col-md-6 col-lg-4">
                <div class="card tour-step-card h-100 shadow" data-step="4" data-visited="false">
                    <div class="card-header bg-info text-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="bi bi-4-circle-fill"></i> 我的道具
                            </h5>
                            <i class="bi bi-check-circle-fill step-completed-icon" style="display:none;"></i>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="step-icon mb-3 text-center">
                            <i class="bi bi-box-seam" style="font-size: 4rem; color: #17a2b8;"></i>
                        </div>
                        <h5 class="card-title">管理你的道具</h5>
                        <p class="card-text">查看和使用已購買的道具，提升遊戲體驗。</p>
                        <ul class="list-unstyled mb-3">
                            <li><i class="bi bi-check-circle text-success"></i> 查看道具庫存</li>
                            <li><i class="bi bi-check-circle text-success"></i> 了解道具功能</li>
                            <li><i class="bi bi-check-circle text-success"></i> 使用道具</li>
                        </ul>
                    </div>
                    <div class="card-footer bg-light">
                        <asp:HyperLink ID="lnkMyItems" runat="server" NavigateUrl="~/Profile/MyItems.aspx" 
                                       CssClass="btn btn-info w-100 visit-btn" data-step="4">
                            <i class="bi bi-arrow-right-circle"></i> 前往我的道具
                        </asp:HyperLink>
                    </div>
                </div>
            </div>

            <!-- 步驟 5: 抽獎中心 -->
            <div class="col-md-6 col-lg-4">
                <div class="card tour-step-card h-100 shadow" data-step="5" data-visited="false">
                    <div class="card-header bg-danger text-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="bi bi-5-circle-fill"></i> 抽獎中心
                            </h5>
                            <i class="bi bi-check-circle-fill step-completed-icon" style="display:none;"></i>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="step-icon mb-3 text-center">
                            <i class="bi bi-gift" style="font-size: 4rem; color: #dc3545;"></i>
                        </div>
                        <h5 class="card-title">試試你的手氣</h5>
                        <p class="card-text">參與抽獎活動，有機會獲得豐富大獎。</p>
                        <ul class="list-unstyled mb-3">
                            <li><i class="bi bi-check-circle text-success"></i> 查看抽獎活動</li>
                            <li><i class="bi bi-check-circle text-success"></i> 了解獎品內容</li>
                            <li><i class="bi bi-check-circle text-success"></i> 查看中獎記錄</li>
                        </ul>
                    </div>
                    <div class="card-footer bg-light">
                        <asp:HyperLink ID="lnkLottery" runat="server" NavigateUrl="~/LotteryPages/LotteryList.aspx" 
                                       CssClass="btn btn-danger w-100 visit-btn" data-step="5">
                            <i class="bi bi-arrow-right-circle"></i> 前往抽獎中心
                        </asp:HyperLink>
                    </div>
                </div>
            </div>

            <!-- 步驟 6: 排行榜 -->
            <div class="col-md-6 col-lg-4">
                <div class="card tour-step-card h-100 shadow" data-step="6" data-visited="false">
                    <div class="card-header bg-secondary text-white">
                        <div class="d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="bi bi-6-circle-fill"></i> 排行榜
                            </h5>
                            <i class="bi bi-check-circle-fill step-completed-icon" style="display:none;"></i>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="step-icon mb-3 text-center">
                            <i class="bi bi-trophy" style="font-size: 4rem; color: #6c757d;"></i>
                        </div>
                        <h5 class="card-title">查看競爭排名</h5>
                        <p class="card-text">查看等級、積分和任務完成數的排行榜。</p>
                        <ul class="list-unstyled mb-3">
                            <li><i class="bi bi-check-circle text-success"></i> 查看排行榜</li>
                            <li><i class="bi bi-check-circle text-success"></i> 找到自己的排名</li>
                            <li><i class="bi bi-check-circle text-success"></i> 了解競爭情況</li>
                        </ul>
                    </div>
                    <div class="card-footer bg-light">
                        <asp:HyperLink ID="lnkLeaderboard" runat="server" NavigateUrl="~/Leaderboard.aspx" 
                                       CssClass="btn btn-secondary w-100 visit-btn" data-step="6">
                            <i class="bi bi-arrow-right-circle"></i> 前往排行榜
                        </asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>

        <!-- 完成導覽按鈕 -->
        <div class="text-center mt-5">
            <asp:Button ID="btnCompleteTour" runat="server" 
                        Text="完成導覽並領取獎勵（領取前請先在任務中心接收新手任務）" 
                        CssClass="btn btn-success btn-lg px-5" 
                        OnClick="btnCompleteTour_Click"
                        Style="display:none;" />
            <p class="text-muted mt-3" id="completionHint">
                <i class="bi bi-info-circle"></i> 訪問所有功能區域後即可完成導覽
            </p>
        </div>

        <!-- 提示卡片 -->
        <div class="alert alert-info mt-5" role="alert">
            <h5 class="alert-heading">
                <i class="bi bi-lightbulb-fill"></i> 導覽提示
            </h5>
            <p class="mb-0">
                點擊每個卡片的按鈕前往對應功能頁面。當你訪問一個頁面後返回，該步驟會自動標記為完成。
                完成所有步驟後，你將獲得新手導覽獎勵！
            </p>
        </div>
    </div>

    <asp:HiddenField ID="hfTourProgress" runat="server" Value="0,0,0,0,0,0" />
    <asp:HiddenField ID="hfTaskClaimed" runat="server" Value="false" />

    <style>
        .tour-step-card { 
            transition: all 0.3s ease; 
            border: 2px solid transparent; 
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.95) 0%, rgba(22, 33, 62, 0.95) 100%);
        }
        .tour-step-card:hover { 
            transform: translateY(-5px); 
            box-shadow: 0 10px 30px rgba(0,0,0,0.15) !important; 
        }
        .tour-step-card.completed { 
            border-color: #28a745; 
            background: linear-gradient(135deg, rgba(40, 167, 69, 0.15) 0%, rgba(32, 201, 151, 0.1) 100%);
            box-shadow: 0 0 20px rgba(40, 167, 69, 0.3) !important;
        }
        .tour-step-card.completed .card-body {
            background: transparent;
        }
        .tour-step-card.completed .card-footer {
            background: rgba(40, 167, 69, 0.1) !important;
            border-top: 1px solid rgba(40, 167, 69, 0.3);
        }
        .tour-step-card .card-body {
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.8) 0%, rgba(22, 33, 62, 0.8) 100%);
        }
        .tour-step-card .card-footer {
            background: rgba(31, 31, 56, 0.9) !important;
            border-top: 1px solid rgba(108, 92, 231, 0.2);
        }
        .tour-step-card .card-title,
        .tour-step-card .card-text {
            color: #e8e8f0;
        }
        .tour-step-card .list-unstyled li {
            color: #b8b8c8;
        }
        .tour-step-card.completed .step-completed-icon { 
            display: inline-block !important; 
            font-size: 1.5rem; 
            animation: checkPop 0.5s ease; 
        }
        @keyframes checkPop { 
            0% { transform: scale(0); } 
            50% { transform: scale(1.2); } 
            100% { transform: scale(1); } 
        }
        .progress { box-shadow: inset 0 1px 2px rgba(0,0,0,0.1); }
        .progress-bar { transition: width 0.5s ease; }
        .visit-btn { transition: all 0.3s ease; }
        .visit-btn:hover { transform: scale(1.05); }
        .step-icon i { transition: transform 0.3s ease; }
        .tour-step-card:hover .step-icon i { transform: scale(1.1) rotate(5deg); }
        .pulse-animation { animation: pulse 2s infinite; }
        @keyframes pulse { 
            0% { box-shadow: 0 0 0 0 rgba(40,167,69,0.7);} 
            70% { box-shadow:0 0 0 10px rgba(40,167,69,0);} 
            100% { box-shadow:0 0 0 0 rgba(40,167,69,0);} 
        }
        #btnCompleteTour:disabled { cursor: not-allowed; opacity: 0.7; }
        #btnCompleteTour.btn-secondary:disabled { background-color: #6c757d; border-color: #6c757d; }
    </style>

    <script>
        window.addEventListener('pageshow', function() { checkVisitedPages(); });
        document.addEventListener('DOMContentLoaded', function() {
            loadBackendProgress();
            document.querySelectorAll('.visit-btn').forEach(function(btn) {
                btn.addEventListener('click', function() {
                    var step = this.getAttribute('data-step');
                    sessionStorage.setItem('platformTourStep' + step, 'visited');
                });
            });
            checkVisitedPages();
            checkTaskClaimedStatus();
        });

        function checkTaskClaimedStatus() {
            var backendProgress = document.getElementById('<%= hfTourProgress.ClientID %>').value;
            var taskClaimed = document.getElementById('<%= hfTaskClaimed.ClientID %>').value;
            if (backendProgress === '1,1,1,1,1,1' && taskClaimed === 'true') {
                var btnComplete = document.getElementById('<%= btnCompleteTour.ClientID %>');
                var hintElement = document.getElementById('completionHint');
                btnComplete.style.display = 'inline-block';
                btnComplete.innerText = '你已經領取過該獎勵';
                btnComplete.disabled = true;
                btnComplete.classList.remove('btn-success','pulse-animation');
                btnComplete.classList.add('btn-secondary');
                hintElement.innerHTML = '<i class="bi bi-check-circle-fill text-success"></i> 您已經完成平台導覽並領取過獎勵了！';
            }
        }

        function loadBackendProgress() {
            var backendProgress = document.getElementById('<%= hfTourProgress.ClientID %>').value;
            if (backendProgress && backendProgress !== '0,0,0,0,0,0') {
                var steps = backendProgress.split(',');
                for (var i = 0; i < steps.length; i++) {
                    if (steps[i] === '1') {
                        var stepNum = i + 1;
                        sessionStorage.setItem('platformTourStep' + stepNum, 'visited');
                        markStepCompleted(stepNum);
                    }
                }
            }
        }

        function checkVisitedPages() {
            var completedCount = 0; var totalSteps = 6; var progressArray = [];
            for (var i = 1; i <= totalSteps; i++) {
                var visited = sessionStorage.getItem('platformTourStep' + i);
                if (visited === 'visited') { markStepCompleted(i); completedCount++; progressArray.push('1'); }
                else { progressArray.push('0'); }
            }
            updateProgress(completedCount, totalSteps);
            var currentProgress = progressArray.join(',');
            var savedProgress = document.getElementById('<%= hfTourProgress.ClientID %>').value;
            if (currentProgress !== savedProgress && currentProgress !== '0,0,0,0,0,0') { syncProgressToBackend(currentProgress); }
            if (completedCount === totalSteps) { showCompletionUI(currentProgress); }
        }

        function markStepCompleted(step) {
            var card = document.querySelector('.tour-step-card[data-step="' + step + '"]');
            if (card && card.getAttribute('data-visited') !== 'true') {
                card.classList.add('completed');
                card.setAttribute('data-visited','true');
                var icon = card.querySelector('.step-completed-icon'); if (icon) icon.style.display='inline-block';
            }
        }

        function updateProgress(completed, total) {
            var percentage = (completed / total) * 100;
            var progressBar = document.getElementById('tourProgressBar');
            document.getElementById('progressPercent').textContent = Math.round(percentage) + '%';
            document.getElementById('progressText').textContent = completed + ' / ' + total;
            progressBar.style.width = percentage + '%';
            progressBar.setAttribute('aria-valuenow', percentage);
        }

        function showCompletionUI(progress) {
            var btnComplete = document.getElementById('<%= btnCompleteTour.ClientID %>');
            var hintElement = document.getElementById('completionHint');
            var taskClaimed = document.getElementById('<%= hfTaskClaimed.ClientID %>').value;
            if (btnComplete.style.display === 'none') {
                btnComplete.style.display = 'inline-block';
                if (taskClaimed === 'true') {
                    btnComplete.innerText = '你已經領取過該獎勵'; btnComplete.disabled = true; btnComplete.classList.remove('btn-success','pulse-animation'); btnComplete.classList.add('btn-secondary');
                    hintElement.innerHTML = '<i class="bi bi-check-circle-fill text-success"></i> 您已經完成平台導覽並領取過獎勵了！';
                } else {
                    btnComplete.innerText = '完成導覽並領取獎勵'; btnComplete.disabled = false; btnComplete.classList.remove('btn-secondary'); btnComplete.classList.add('btn-success','pulse-animation');
                    hintElement.innerHTML = '<i class="bi bi-check-circle-fill text-success"></i> 非常棒！您已完成所有導覽步驟，現在可以領取獎勵了！';
                }
                document.getElementById('<%= hfTourProgress.ClientID %>').value = progress;
                syncProgressToBackend(progress);
            }
        }

        function syncProgressToBackend(progress) {
            if (!progress) {
                var arr=[]; for (var i=1;i<=6;i++){ arr.push(sessionStorage.getItem('platformTourStep'+i)==='visited'?'1':'0'); }
                progress = arr.join(',');
            }
            document.getElementById('<%= hfTourProgress.ClientID %>').value = progress;
            if (typeof PageMethods === 'undefined' || !PageMethods.SaveTourProgress) {
                console.warn('[PlatformTour] PageMethods 未就緒，延遲再試');
                setTimeout(function(){ syncProgressToBackend(progress); }, 500);
                return;
            }
            PageMethods.SaveTourProgress(progress, function(result){
                console.log('[PlatformTour] PageMethods 保存結果=', result, 'progress=', progress);
                if (!result) { showAuthWarning(); }
            }, function(err){
                console.warn('[PlatformTour] PageMethods 調用失敗', err.get_message ? err.get_message() : err);
                showAuthWarning();
            });
        }

        function showAuthWarning(){
            if (document.getElementById('authWarning')) return;
            var div=document.createElement('div'); div.id='authWarning'; div.className='alert alert-warning mt-3';
            div.innerHTML='<i class="bi bi-exclamation-triangle-fill"></i> 無法保存導覽進度，請確認已登入或重新整理。';
            var container=document.querySelector('.tour-progress-section .card-body');
            if(container) container.appendChild(div);
        }
    </script>
</asp:Content>
