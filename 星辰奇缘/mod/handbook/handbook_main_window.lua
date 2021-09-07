-- -------------------------------------
-- 幻化收藏手册主界面
-- hosr
-- -------------------------------------
HandbookMainWindow = HandbookMainWindow or BaseClass(BaseWindow)

function HandbookMainWindow:__init(model)
	self.model = model
    self.name = "HandbookMainWindow"
    self.windowId = WindowConfig.WinID.handbook_main
    self.cacheMode = CacheMode.Visible

	self.resList = {
		{file = AssetConfig.handbook_main, type = AssetType.Main},
		{file = AssetConfig.handbook_res, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.itemPanel = nil -- 卡片展示
    self.infoPanel = nil -- 信息展示
    self.matchPanel = nil -- 组合展示
    self.shopPanel = nil -- 兑换商店

    self.currIndex = 1
    self.leftList = nil
    self.rightList = nil
    self.selectId = 0 -- 选中图鉴id
end

function HandbookMainWindow:__delete()
    self.OnHideEvent:Fire()
	if self.itemPanel ~= nil then
		self.itemPanel:DeleteMe()
		self.itemPanel = nil
	end
	if self.infoPanel ~= nil then
		self.infoPanel:DeleteMe()
		self.infoPanel = nil
	end
	if self.matchPanel ~= nil then
		self.matchPanel:DeleteMe()
		self.matchPanel = nil
	end
	if self.shopPanel ~= nil then
		self.shopPanel:DeleteMe()
		self.shopPanel = nil
	end
    self:AssetClearAll()
end

function HandbookMainWindow:OnShow()
	local left = self.leftList[self.currIndex]
	if left ~= nil then
		left:Hiden()
	end
	local right = self.rightList[self.currIndex]
	if right ~= nil then
		right:Hiden()
	end

	if self.openArgs ~= nil then
		if self.openArgs[1] ~= nil then
			self.currIndex = self.openArgs[1]
		end
		if self.openArgs[2] ~= nil then
			self.selectId = self.openArgs[2]
		end
	end
	self.tabGroup:ChangeTab(self.currIndex)
end

function HandbookMainWindow:JumpTo(index)
	self.tabGroup:ChangeTab(index)
end

function HandbookMainWindow:OnHide()
	if self.itemPanel ~= nil then
		self.itemPanel:Hiden()
	end
	if self.infoPanel ~= nil then
		self.infoPanel:Hiden()
	end
	if self.matchPanel ~= nil then
		self.matchPanel:Hiden()
	end
	if self.shopPanel ~= nil then
		self.shopPanel:Hiden()
	end
end

function HandbookMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.handbook_main))
    self.gameObject.name = "HandbookMainWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.mainTransform = self.transform:Find("Main")

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self.model:CloseMain() end)

    local tabGroupSetting = {
        notAutoSelect = true,
        isVertical = true,
        noCheckRepeat = true,
    }
    self.tabGroup = TabGroup.New(self.transform:Find("Main/TabButtonGroup"), function(index) self:ChangeTab(index) end, tabGroupSetting)

    self.itemPanel = HandbookItemPanel.New(self)
    self.infoPanel = HandbookInfoPanel.New(self)
    self.matchPanel = HandbookMatchPanel.New(self)
    self.shopPanel = HandbookShopPanel.New(self)
    self.leftList = {self.itemPanel}
    self.rightList = {self.infoPanel, self.shopPanel, self.matchPanel}

    self:OnShow()
end

function HandbookMainWindow:ChangeTab(index)
	local left = self.leftList[self.currIndex]
	if left ~= nil then
		left:Hiden()
	end
	local right = self.rightList[self.currIndex]
	if right ~= nil then
		right:Hiden()
	end

	self.currIndex = index
	left = self.leftList[self.currIndex]
	if left ~= nil then
		left:Show()
	end

	right = self.rightList[self.currIndex]
	if right ~= nil then
		right:Show()
	end
end

function HandbookMainWindow:DefaultSelect()
	if self.itemPanel ~= nil and self.itemPanel.isInit then
		self.itemPanel:DefaultSelect()
	end
end

function HandbookMainWindow:SelectOne(data)
	if self.infoPanel ~= nil and self.infoPanel.isInit then
		self.infoPanel:Update(data)
	end
end