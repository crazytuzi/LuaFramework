StrongPanel = BaseClass(BaseView)
function StrongPanel:__init( ... )
	self.ui = UIPackage.CreateObject("Strong","StrongPanel"); -- self.URL = "ui://vgwyw6jpreao4";
	
	self.title = self.ui:GetChild("title")
	self.list = self.ui:GetChild("list")
	self.btnClose = self.ui:GetChild("btnClose")
	self.id = "StrongPanel"

	self.model = StrongModel:GetInstance()
	self.items = {}

	self:InitEvent()

	self:InitTabsUI()
end

function StrongPanel:_Layout()
	-- body
end

function StrongPanel:InitEvent()
	--[[
		self.openCallback  = function() end
	--]]
	self.btnClose.onClick:Add(function()
		UIMgr.HidePopup(self.ui)
	end)

	-- self.list.scrollPane.onScroll:Remove(self.OnScrollHandler, self)
	-- self.list.scrollPane.onScroll:Add(function ()
	-- 	self:OnScrollHandler()
	-- end)

	self.handler0 = self.model:AddEventListener(StrongConst.CloseStrong, function()
		UIMgr.HidePopup(self.ui)
	end)
end

function StrongPanel:OnScrollHandler()
	self.model:DispatchEvent(StrongConst.HideEffect)
end

function StrongPanel:InitTabsUI()
	local tabBg = UIPackage.GetItemURL("Common","btnBg_001")
	local tabSelectedBg = UIPackage.GetItemURL("Common","btnBg_002")
	local x = 275
	local y = 147
	local tabType = 0
	local yInternal = 60
	local redW = 163
	local redH = 53
	local tabData = {}
	local tabCfgData = self.model:GetTabData()
	
	for i = 1, #tabCfgData do
		table.insert(tabData, {label = tabCfgData[i][2], res0 = tabBg, res1 = tabSelectedBg, id = tabCfgData[i][3], red = false , fontColor = newColorByString("#2e3341") })
	end

	local ctrl, tabs = CreateTabbar(self.ui, tabType, function(idx, id, bar)
		self:RefreshContentUI( idx,id)
		bar:GetChild("title").color = newColorByString("#2e3341")
	end, tabData, x, y, 0, yInternal, redW, redH)

	self.tabCtrl = ctrl
	self.tabs = tabs
end

function StrongPanel:RefreshContentUI(idx,id)
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
	end
	StrongModel:GetInstance():GetKindLevel()
	self.items = {}
	local data = self.model:GetItemData(id)
	if data then
		for i,v in ipairs(data) do
			local itemObj = ItemStrong.New()
			itemObj:SetData(v)
			table.insert(self.items, itemObj)
			self.list:AddChild(itemObj.ui)
		end
	end
end

function StrongPanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.handler0)
	end
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
	end
	self.items = nil

end