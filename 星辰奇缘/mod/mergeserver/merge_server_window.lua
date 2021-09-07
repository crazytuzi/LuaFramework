-- @author 黄耀聪
-- @date 2016年6月13日

MergeServerWindow = MergeServerWindow or BaseClass(BaseWindow)

function MergeServerWindow:__init(model)
    self.model = model
    self.name = "MergeServerWindow"
	self.windowId = WindowConfig.WinID.merge_server

	self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
	self.title = TI18N("合服活动")

    self.resList = {
        {file = AssetConfig.open_server_window, type = AssetType.Main}
    }

	self.panelList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MergeServerWindow:__delete()
    self.OnHideEvent:Fire()
	if self.panelList ~= nil then
		for k, v in pairs(self.panelList) do
			if v ~= nil then
				v:DeleteMe()
			end
		end
		self.panelList = nil
	end
    if self.model.giftPreview ~= nil then
        self.model.giftPreview:DeleteMe()
        self.model.giftPreview = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MergeServerWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_window))
	self.gameObject.name = self.name
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
	local transform = self.gameObject.transform
	self.transform = transform

	self.mainPanel = self.transform:Find("Main")

    self.closeBtn = self.mainPanel:Find("Close"):GetComponent(Button)
    self.tabListPanel = self.mainPanel:Find("TabListPanel")
    self.titleText = self.mainPanel:Find("Title/Text"):GetComponent(Text)

    self.titleText.text = self.title

    self.tabListPanel.gameObject:SetActive(false)
    self.closeBtn.onClick:AddListener(function() self:OnClose() end)
end

function MergeServerWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MergeServerWindow:OnOpen()
    self:RemoveListeners()

	if self.panelList[1] == nil then
		self.panelList[1] = MergeServerPanel.New(self.model, self.mainPanel)
	end
	self.panelList[1]:Show()
end

function MergeServerWindow:OnHide()
    self:RemoveListeners()
end

function MergeServerWindow:RemoveListeners()
end

function MergeServerWindow:OnClose()
	self.model:CloseWindow()
end
