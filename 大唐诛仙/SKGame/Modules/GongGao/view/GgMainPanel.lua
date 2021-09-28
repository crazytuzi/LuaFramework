GgMainPanel = BaseClass(CommonBackGround)
function GgMainPanel:__init( ... )
	self.id = "GgMainPanel"
	self.showBtnClose = true
	self.isOnOtherClose = false
	self.parent = layerMgr:GetMSGLayer()
	self.bgUrl = "bg_big1"
end

function GgMainPanel:Layout()
	self.ui = UIPackage.CreateObject("GongGao","GgMainPanel")
	self.lightList = self.ui:GetChild("lightList") --公告列表
	local tabBg = UIPackage.GetItemURL("Common","btn_000")
	local tabSelectedBg = UIPackage.GetItemURL("Common","btn_000")
	local x =150
	local y = 130
	local tabType = 0
	local yInternal = 76
	local redW = 160
	local redH = 60
	local tabData = {}
	self.selectPanel = nil
	self.defaultTabIndex = 0
	local tabCfgData = GgModel:GetInstance():GetPanelTabData()
	for i = 1, #tabCfgData do
		table.insert(tabData, {label = tabCfgData[i][2], res0 = tabBg, res1 = tabSelectedBg, id = tabCfgData[i][1], fontColor=newColorByString("#2e3341"), red = false})
	end

	local ctrl, tabs = CreateTabbar(self.ui, tabType, function (idx, id)
		local cur = nil
		self.id = tonumber(id)
		if self.id ==1 then
			self:SetTitle("公  告")
			if not self.ggOpenServerPanel then
				self.ggOpenServerPanel = GgOpenServerPanel.New(self.container)
			end
			cur = self.ggOpenServerPanel

		elseif self.id ==2 then
			self:SetTitle("实名制")
			if not self.ggRealNamePanel then
				self.ggRealNamePanel = GgRealNamePanel.New(self.container)
			end
			cur=self.ggRealNamePanel
		elseif self.id ==3 then
			self:SetTitle("更新公告")
			if not self.ggUpdatePanel then
			    self.ggUpdatePanel = GgUpadatePanel.New(self.container)
			end
			cur = self.ggUpdatePanel
		
		end
		if self.selectPanel ~= cur then
			if  self.selectPanel then
				self.selectPanel:SetVisible(false)
			end
			self.selectPanel = cur
			if cur then
				cur:SetVisible(true)
			end
		end
	end, tabData, x, y, self.defaultTabIndex, yInternal, redW, redH)
	self.tabCtrl = ctrl
	self.tabs = tabs
	self:AddChouDai()
end
-- function GgMainPanel:Open()
-- 	if self:IsOpen() then -- 已经打开，就切换指定标签		
-- 	else
-- 		CommonBackGround.Open(self)
-- 	end
-- end

function GgMainPanel:__delete()
	if self.ggOpenServerPanel then self.ggOpenServerPanel:Destroy() end
	if self.ggUpdatePanel then self.ggUpdatePanel:Destroy() end
	if self.ggRealNamePanel then self.ggRealNamePanel:Destroy()end
	self.ggOpenServerPanel = nil
	self.ggUpdatePanel = nil
	self.ggRealNamePanel = nil
	self.selectPanel = nil
end


