MallPanel = BaseClass(LuaUI)

function MallPanel:__init(...)
	self.URL = "ui://z5rl8hw3kt6kx";
	self:__property(...)
	self:Config()
end

function MallPanel:SetProperty(...)
	
end

function MallPanel:Config()
	
end

function MallPanel:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Mall","MallPanel");

	self.bg = self.ui:GetChild("bg")
	self.contentList = self.ui:GetChild("contentList")

	self.contentItemList = {}
	self.selectTabId = nil
	self.selectMarketId = nil

	self.isDestroy = false

	self:AddEvents()
	self:UpdateView()
end

function MallPanel.Create(ui, ...)
	return MallPanel.New(ui, "#", {...})
end

function MallPanel:AddEvents()
	self.handler = MallModel:GetInstance():AddEventListener(MallConst.MallItemSelect, function ( data ) self:OnMallItemSelectHandler(data) end)
end

function MallPanel:RemoveEvents()
	MallModel:GetInstance():RemoveEventListener(self.handler)
end

function MallPanel:OnMallItemSelectHandler(data)
	local mallBuyPanel = MallBuyPanel.New()
	mallBuyPanel:Update(data)
	UIMgr.ShowCenterPopup(mallBuyPanel, function()  end)
end

function MallPanel:UpdateView()
	self:InitTabs()
end

function MallPanel:InitTabs()
	-- 标签
	local res0 = UIPackage.GetItemURL("Common","btnBg_001")
	local res1 = UIPackage.GetItemURL("Common","btnBg_002")
	local x = 20
	local y = 5
	local tabType = 0
	local yInternal = 66
	local defaultIndex = 0
	local redW = 180
	local redH = 60
	local tabData = {}
	local tabCfgData = MallModel:GetInstance():GetTabCfgData()


	local createTime , closeTime , _ , _ = EquipmentStoreTipsModel:GetInstance():GetStartEndTime()
	local formatCreateTime = TimeTool.getYMD3(createTime)
	local formatEndTime = TimeTool.getYMD3(closeTime)
	local startTime = TimeTool.GetTimeByYYMMDD_HHMMSS(formatCreateTime)
	local endTime = TimeTool.GetTimeByYYMMDD_HHMMSS(formatEndTime)
	local curTime = TimeTool.GetCurTime()
	local formatCurTime = TimeTool.getYMD3(curTime)
	local curTime2 = TimeTool.GetTimeByYYMMDD_HHMMSS(formatCurTime)


	for i = 1, #tabCfgData do
		if ((MallModel:GetInstance():GetTab67State() == false) and (i == 6 or i == 7)) then
			zy("不打开" ,i)
		else
			local strDesc = tabCfgData[i][2]
			if i == 6 or i == 7 then
				if TimeTool.GetTimeD(endTime - curTime2) ~= "" then
					strDesc = tabCfgData[i][2] .. "(" .. TimeTool.GetTimeD(endTime - curTime2) .. ")"
				end
			end
			table.insert(tabData, {label = strDesc, res0 = res0, res1 = res1, id = tabCfgData[i][1], red = false})
		end
	end
	local ctrl, tabs = CreateTabbar(self.ui, tabType, function (idx, id, bar)
		self.selectTabId = id
		self:RefreshContent(id)
		bar:GetChild("title").color = newColorByString("#2e3341")
	end, tabData, x, y, defaultIndex, yInternal, redW, redH)
	self.tabCtrl = ctrl
	self.tabs = tabs
end

function MallPanel:LocationItem(marketId)
	if not marketId then return end
	local tabCfgData = MallModel:GetInstance():GetTabCfgData()
	local contentData = nil
	for i = 1, #tabCfgData do
		contentData = MallModel:GetInstance():GetDataByType(tabCfgData[i][1])
		for j = 1, #contentData do
			if contentData[j].marketId == marketId then
				self.selectMarketId = marketId
				SelectTabbarById(self.tabCtrl, self.tabs, tabCfgData[i][1])
				break
			end
		end
	end
end

function MallPanel:LocationTab(tabId)
	SelectTabbarById(self.tabCtrl, self.tabs, tostring(tabId))
end

function MallPanel:RefreshPage()
	self.selectMarketId = nil
	self.tabCtrl.selectedIndex = 0
	if self.selectTabId then
		self:RefreshContent(self.selectTabId)
	end
end
local renderKey = "MallPanel_RefreshContentInFrame"
function MallPanel:RefreshContent(type)
	RenderMgr.Remove(renderKey)
	self:ClearContent()
	self.data = MallModel:GetInstance():GetDataByType(type)
	self.index = 1
	RenderMgr.Add(function () self:RefreshContentInFrame() end, renderKey)
end

function MallPanel:RefreshContentInFrame()
	if self.isDestroy then
		RenderMgr.Remove(renderKey)
		return
	end
	if self.index <= #self.data then
		local item = self:GetMallItemFromPool()
		item:Reset()
		item:Refresh(self.data[self.index])
		if self.selectMarketId and item.data.marketId == self.selectMarketId then
			item:Select()
			self.selectMarketId = nil
		end
		self.contentList:AddChild(item.ui)
		self.index = self.index + 1
	else
		RenderMgr.Remove(renderKey)
		self.data = nil
		self.index = nil
	end
end

function MallPanel:GetMallItemFromPool()
	for i = 1, #self.contentItemList do
		if self.contentItemList[i].ui.parent == nil then
			return self.contentItemList[i]
		end
	end
	local item = MallItem.New()
	table.insert(self.contentItemList, item)
	return item
end

function MallPanel:DestoryPool()
	for i = 1, #self.contentItemList do
		self.contentItemList[i]:Destroy()
	end
	self.contentItemList = {}
end

function MallPanel:ClearContent()
	MallItem.CurSelectItem = nil
	self.contentList:RemoveChildren()
	for i = 1, #self.contentItemList do
		self.contentItemList[i]:Reset()
	end
end

function MallPanel:__delete()
	self.isDestroy = true
	self:RemoveEvents()
	self:DestoryPool()
end