LoveMatchWindow = LoveMatchWindow or BaseClass(BaseWindow)

function LoveMatchWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.lovematch
    self.name = "LoveMatchWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.resList = {
       {file = AssetConfig.love_match_window,type = AssetType.Main},
       {file = AssetConfig.heads, type = AssetType.Dep},
       {file = AssetConfig.love_texture, type = AssetType.Dep},
       {file = AssetConfig.petevaluation_texture,type = AssetType.Dep},
    --    {file = AssetConfig.basecompress_textures, type = AssetType.Dep}
    }
    self.winLinkType = WinLinkType.Link
    self.holdTime = 60
    self.Mgr = self.model.Mgr

    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)


    -- 记录下拉刷新的次数
    self.refreshTimes = 1

    -- 处理刷新文本的显示
    self.checking = false
    -- 是否执行刷新
    self.refresh = false
    -- 用来区别是宠物还是守护
    self.typeIndex = nil
    -- 存放获得的评论对象数据
    self.currentTargetData = {}
    self.myCurrentEvaluation = nil    -- 存放我当前的评论
    self.appendTab = {}
    self.currentElement = nil
    self.specialIds = {}

    self.onUpdateRefreshPanel = function(data) self:RefreshPanelReply(data) end
end

function LoveMatchWindow:__delete()
    self:RemoveListeners()
    self.scrollRect.onValueChanged:RemoveAllListeners()

    if self.loveEvaluationList ~=nil then
        self.loveEvaluationList:DeleteMe()
    end

    if self.gameObject ~= nil then
      GameObject.DestroyImmediate(self.gameObject)
      self.gameObject = nil
    end
    self.model = nil
    self:AssetClearAll()
end


function LoveMatchWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.love_match_window))
    self.gameObject.name = self.name
    self.transform =self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    self.closeBtn = self.gameObject.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)
    self.MaskCon = self.transform:Find("Main/MainPanel/Mask")
    self.Container = self.transform:Find("Main/MainPanel/Mask/Container")
    self.Boundary = self.transform:Find("Main/MainPanel/Mask/Container/Boundary").gameObject:SetActive(false)

    self.loveEvaluationList = LoveEvaluationListPanel.New(self.Container.gameObject,self,self.assetWrapper)
    self.scrollRect = self.transform:Find("Main/MainPanel/Mask"):GetComponent(ScrollRect)
    self.noEvaluation = self.transform:Find("Main/MainPanel/NoEvaluation")
    self.noEvaluationText = self.transform:Find("Main/MainPanel/NoEvaluation/Text"):GetComponent(Text)
    self.topButton = self.transform:Find("TopButton"):GetComponent(Button)
    self.topButton.onClick:AddListener(function() self:RefreshPanelRequire() end)
    -- 改变输入框的默认显示
    self:OnOpen()
end


function LoveMatchWindow:OnInitCompleted()
    self:ClearMainAsset()
end

function LoveMatchWindow:OnOpen()
    QiXiLoveManager.Instance:send17878()
    self:RefreshPanelReply(QiXiLoveManager.Instance.matchData)
    self:AddListeners()
end

-------------------------
function LoveMatchWindow:OnHide()
    self:RemoveListeners()
end

function LoveMatchWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function LoveMatchWindow:RefreshPanelRequire()
    QiXiLoveManager.Instance:send17879()
end

function LoveMatchWindow:RefreshPanelReply(data)
    self.noEvaluation.gameObject:SetActive(false)
    if #data.list <= 0 then
        self.noEvaluationText.text = "有缘人还在化妆，请稍候再来看看"
        self.noEvaluation.gameObject:SetActive(true)
    else
        self.noEvaluation.gameObject:SetActive(false)
    end
    self.loveEvaluationList:RefreshData(data)
end

function LoveMatchWindow:AddListeners()
    QiXiLoveManager.Instance.onUpdateMatch:RemoveListener(self.onUpdateRefreshPanel)
    QiXiLoveManager.Instance.onUpdateMatch:AddListener(self.onUpdateRefreshPanel)
end

function LoveMatchWindow:RemoveListeners()
  QiXiLoveManager.Instance.onUpdateMatch:RemoveListener(self.onUpdateRefreshPanel)
end
