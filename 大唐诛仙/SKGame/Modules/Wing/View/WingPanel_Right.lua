WingPanel_Right = BaseClass(LuaUI)

function WingPanel_Right:__init(...)
	self.URL = "ui://d3en6n1nigzg17";
	self:__property(...)
	self:Config()
end

function WingPanel_Right:SetProperty(...)
	
end

function WingPanel_Right:Config()
	
end

function WingPanel_Right:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Wing","WingPanel_Right");

	self.bgRare = self.ui:GetChild("bgRare")
	self.powerTxt = self.ui:GetChild("powerTxt")
	self.level = self.ui:GetChild("level")
	self.name = self.ui:GetChild("name")
	self.typeInfo = self.ui:GetChild("typeInfo")
	self.Quality = self.ui:GetChild("Quality")
	self.icon = self.ui:GetChild("icon")
	self.grade = self.ui:GetChild("grade")
	self.line1 = self.ui:GetChild("line1")
	self.line2 = self.ui:GetChild("line2")
	self.proList = self.ui:GetChild("proList")
	self.desc1 = self.ui:GetChild("desc1")
	self.desc2 = self.ui:GetChild("desc2")
	self.upBtn = self.ui:GetChild("upBtn")
	self.putOnBtn = self.ui:GetChild("putOnBtn")
	self.desc3 = self.ui:GetChild("desc3")
	self.ctrMax = self.ui:GetController("ctrMax")-------------------------------
	self.maxBtn = self.ui:GetChild("maxBtn") 
	self.gradeMax = self.ui:GetChild("gradeMax")
	self.proMaxList = self.ui:GetChild("proMaxList")
	self.getText = self.ui:GetChild("getText")

	self.starts = Starts.New()
	self.starts:SetXY(self.grade.x, self.grade.y + 32)
	self.ui:AddChild(self.starts.ui)

	self.ctrMax.selectedIndex = 0
	self.maxBtn:GetChild("icon1").visible = true
	self.maxBtn:GetChild("icon2").visible = false

	self.upbtnKind = 0 --羽翼未获取：类型0，预览功能。 羽翼已获取：类型1 羽化功能 
	self:Empty()

	self.wingUpPanel = nil
	self.curShowData = nil
	self.curShowDynamciData = nil

	self.clickType = 1 --1:装备 2:卸下 3:获得

	self:AddEvent()
end

function WingPanel_Right.Create(ui, ...)
	return WingPanel_Right.New(ui, "#", {...})
end

function WingPanel_Right:AddEvent()
	self.upBtn.onClick:Add(self.OnUpBtnClickHandler, self)
	self.putOnBtn.onClick:Add(self.OnPutOnBtnClickHandler, self)
	self.maxBtn.onClick:Add(self.OnClickMaxBtn, self)---------------------------

	self.selectHandler = WingModel:GetInstance():AddEventListener(WingConst.SelectWingItem, function (data) self:OnSelectItemHandler(data) end)
	self.updateHandler = WingModel:GetInstance():AddEventListener(WingConst.DataUpdateOk, function () self:Update() end)
end

function WingPanel_Right:RemoveEvent()
	self.upBtn.onClick:Remove(self.OnUpBtnClickHandler, self)
	self.putOnBtn.onClick:Remove(self.OnPutOnBtnClickHandler, self)
	self.maxBtn.onClick:Remove(self.OnClickMaxBtn, self)

	WingModel:GetInstance():RemoveEventListener(self.selectHandler)
	WingModel:GetInstance():RemoveEventListener(self.updateHandler)
end

function WingPanel_Right:RefreshGetWayText()
	local data = GetCfgData("wing"):Get(self.curShowData.wingId)
	local isAct = WingModel:GetInstance():IsActive(self.curShowData.wingId)
	if isAct then
		self.getText.visible = false
		self.getText.text = ""
	else
		self.getText.visible = true
		if data then
			if data.Access == 1 then
				self.getText.text = " "
			else
				local str = StringFormat("{0}", data.label)
				self.getText.text = str
			end
		end
	end
end

function WingPanel_Right:OnPutOnBtnClickHandler()
	if self.clickType == 1 then --装备
		WingController:GetInstance():C_PutonWing(self.curShowData.wingId)
	elseif self.clickType == 2 then --卸下
		WingController:GetInstance():C_PutdownWing(self.curShowData.wingId)
	elseif self.clickType == 3 then --获得
		local itemId = nil
		cfg = GetCfgData("market"):Get(self.curShowData.marketId)
		local data = GetCfgData("wing"):Get(self.curShowData.wingId)
		if cfg then
			itemId = cfg.itemId
		end
		if data then
			if data.Access == 1 then
				if itemId and PkgModel:GetInstance():GetTotalByBid(itemId) > 0 then
					UIMgr.Win_Alter("提示", StringFormat("背包已经有[{0}]，无法重复购买！", self.curShowData.name), "确定", function()
					end, nil)		
				else
					MallController:GetInstance():QuickBuy(self.curShowData.marketId)
				end
			elseif data.Access == 2 then
				RechargeController:GetInstance():Open(7)
			elseif data.Access == 3 then
				local str = data.label
				UIMgr.Win_Alter("提示", StringFormat("{0}", str), "确定", function() end)
			end
		end
	end
end

function WingPanel_Right:OnClickMaxBtn()
	if self.ctrMax.selectedIndex == 0 then
		self.ctrMax.selectedIndex = 1
		self.maxBtn:GetChild("icon1").visible = false
		self.maxBtn:GetChild("icon2").visible = true
	else
		self.ctrMax.selectedIndex = 0
		self.maxBtn:GetChild("icon1").visible = true
		self.maxBtn:GetChild("icon2").visible = false
	end
end

function WingPanel_Right:Update()
	if self.curShowData then
		self.curShowDynamciData = WingModel:GetInstance():GetWingDynamicData(self.curShowData.wingId) 
		self:Refresh()
	end
end

function WingPanel_Right:OnSelectItemHandler(data)
	self.curShowData = data
	self.curShowDynamciData = WingModel:GetInstance():GetWingDynamicData(self.curShowData.wingId) 
	local dataMax = WingModel:GetInstance():GetWingMaxData(self.curShowData.wingId)
	self:Refresh(dataMax)
end

function WingPanel_Right:Empty()
	self.starts:SetLevel(0)

	--self.upBtn.grayed = false
	self.upBtn.title = "预览"
	self.upbtnKind = 0
	--self.upBtn.touchable = false

	self.putOnBtn.text = "获得"
	self.clickType = 3
end

function WingPanel_Right:Refresh(data)
	if data then
		local gradeMax, decimals = math.modf(data[1][1][1] / 5)
		self.gradeMax.text = StringFormat("{0}阶", (gradeMax-1))
		self.proMaxList:RemoveChildrenToPool()
		local maxProperty = {}
		for i,v in ipairs(data[1][2]) do
			table.insert(maxProperty, { v[1], tonumber(v[2] * (data[1][1][3]/10000) + v[2])})
		end
		for i = 1, #maxProperty do
			local prop = self.proMaxList:AddItemFromPool()	
			local pName = prop:GetChild("TitleName")
			local pValue = prop:GetChild("TitleValue")
			pName.text = StringFormat( "[color=#6aff66]{0}[/color]" , RoleVo.GetPropDefine(data[1][2][i][1]).name)
			pValue.x = pName.x + pName.textWidth + 4
			pValue.text = StringFormat( "[color=#6aff66]{0}[/color]", math.ceil(maxProperty[i][2]))
		end
	end
	self.icon.url = StringFormat("Icon/Goods/{0}", self.curShowData.icon)
	self.name.text = "[color="..GoodsVo.RareColor[self.curShowData.quality].."]"..self.curShowData.name.."[/color]"
	self.desc1.text = self.curShowData.des
	self.desc2.visible = false
	self.desc3.visible = false

	self.level.text = "1级"
	self.typeInfo.text = "羽翼"
	

	self.Quality.url = "Icon/Common/grid_cell_"..self.curShowData.quality
	self.bgRare.url = "Icon/Common/tipbg_r"..self.curShowData.quality


	local addPercent = 0
	if self.curShowDynamciData then
		local start = self.curShowDynamciData.star
		local integer, decimals = math.modf(start / 5)
		local startLevel = start % 5
		self.starts:SetLevel(startLevel)
		local lv, aa = math.modf((#self.curShowData.upStarStr)/5)
		if integer >= lv then
			integer = integer -1
		end
		self.grade.text = StringFormat("星阶：{0}阶", integer)
		if self.curShowData.upStarStr[start] then
			addPercent = self.curShowData.upStarStr[start+1][3] / 10000
		end
		local starUpCfg = self.curShowData.upStarStr[start+2]
		if not starUpCfg then --最大星阶
			self.starts:SetLevel(5)
		end

		--self.upBtn.grayed = false
		self.upbtnKind = 1
		self.upBtn.title = "羽化"
		--self.upBtn.touchable = true

		if self.curShowDynamciData.dressFlag == 1 then
			self.putOnBtn.text = "卸下"
			self.clickType = 2
		else
			self.putOnBtn.text = "装备"
			self.clickType = 1
		end
	else
		self.grade.text = StringFormat("星阶：0阶")
		self:Empty()
	end

	self.proList:RemoveChildrenToPool()
	for i = 1, #self.curShowData.baseProperty do
		local prop = self.proList:AddItemFromPool()	
		local pName = prop:GetChild("TitleName")
		local pValue = prop:GetChild("TitleValue")
		pName.text = RoleVo.GetPropDefine(self.curShowData.baseProperty[i][1]).name
		pValue.x = pName.x + pName.textWidth + 4
		pValue.text = math.ceil(tonumber(self.curShowData.baseProperty[i][2]) * (1 + addPercent))
	end
	local baseProperty = {}
	for i = 1, #self.curShowData.baseProperty do
		table.insert(baseProperty, { self.curShowData.baseProperty[i][1], tonumber(self.curShowData.baseProperty[i][2]) * (1 + addPercent)})
	end
	self.powerTxt.text = StringFormat("评分 : {0}",CalculateScore(baseProperty))
	self:RefreshGetWayText()
end

function WingPanel_Right:OnUpBtnClickHandler()
	if self.upbtnKind == 0 then
		if not WingActivePanel.isOpen then
			local wingActivePanel = WingActivePanel.New()
			wingActivePanel.activiteIcon.visible = false
			wingActivePanel:SetData(self.curShowData)
			UIMgr.ShowCenterPopup(wingActivePanel)
		end
	else
		if self.wingUpPanel == nil or not self.wingUpPanel.Inited then
			self.wingUpPanel = WingUpPanel.New()
		end
		self.wingUpPanel:Show(self.curShowData)
		self.wingUpPanel:Open()
	end
end

function WingPanel_Right:__delete()
	self:RemoveEvent()
	if self.wingUpPanel and self.wingUpPanel.Inited then
		self.wingUpPanel:Destroy()
	end
	self.wingUpPanel = nil

	self.starts:Destroy()
	self.starts = nil

	self.curShowData = nil
	self.curShowDynamciData = nil
end