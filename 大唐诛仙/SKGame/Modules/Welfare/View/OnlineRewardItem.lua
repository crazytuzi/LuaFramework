OnlineRewardItem = BaseClass(LuaUI)
function OnlineRewardItem:__init(...)
	self.URL = "ui://g35bobp2l1qpe";
	self:__property(...)
	self:Config()
end

function OnlineRewardItem:SetProperty(...)
	
end

function OnlineRewardItem:Config()
	self:InitData()
	self:InitEvent()
end

function OnlineRewardItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Welfare","OnlineRewardItem");

	self.imgBG = self.ui:GetChild("imgBG")
	self.imgArrow = self.ui:GetChild("imgArrow")
	self.imgOnline = self.ui:GetChild("imgOnline")
	self.titleTime = self.ui:GetChild("titleTime")
	self.buttonGet = self.ui:GetChild("buttonGet")
	self.imgGet = self.ui:GetChild("imgGet")
end

function OnlineRewardItem.Create(ui, ...)
	return OnlineRewardItem.New(ui, "#", {...})
end

function OnlineRewardItem:__delete()
	self.data = {}
	self.lastClickId = -1
	self:DisposePkgCellList()
end

function OnlineRewardItem:InitData()
	self.data = {}
	self.lastClickId = -1
	self.pkgCellList = {}
end

function OnlineRewardItem:InitEvent()
	self.buttonGet.onClick:Add(self.OnButtonGetClick, self)
end

function OnlineRewardItem:CleanEvent()
	self.buttonGet.onClick:Clear()
end

function OnlineRewardItem:SetData(data)
	if data then
		self.data = data
	end
end

function OnlineRewardItem:GetData()
	return self.data
end

function OnlineRewardItem:SetUI()
	
	if not TableIsEmpty(self.data) then
		local onlineRewardCfgData = WelfareModel:GetInstance():GetOnlineRewradCfgById(self.data.id)
		if not TableIsEmpty(onlineRewardCfgData) then
			local strTime = onlineRewardCfgData.condition or ""
			self.titleTime.text = StringFormat("{0}分钟", strTime)
		end

		self:SetStateUI()

		self:SetPkgCellUIList()
	end
end

function OnlineRewardItem:OnButtonGetClick()
	
	if not TableIsEmpty(self.data) and self.data.id then
		if self.lastClickId ~= self.data.id then
			WelfareController:GetInstance():C_GetReward(self.data.id)
			self.lastClickId = self.data.id
		end
	end
end

function OnlineRewardItem:SetStateUI()
	self.imgGet.visible = false
	self.buttonGet.visible = true

	if self.data.state == WelfareConst.OnlineRewardState.HasGet then
		self.imgGet.visible = true
		self.buttonGet.visible = false
	elseif self.data.state == WelfareConst.OnlineRewardState.CannotGet then
		self.buttonGet.touchable = false
		self.buttonGet.alpha = 0.5
	elseif self.data.state == WelfareConst.OnlineRewardState.CanGet then
		self.buttonGet.touchable = true
		self.buttonGet.alpha = 1
	end	
end


function OnlineRewardItem:SetPkgCellUIList()
	if not TableIsEmpty(self.data) and self.data.id then
		local onlineRewardCfg = WelfareModel:GetInstance():GetOnlineRewradCfgById(self.data.id)
		if not TableIsEmpty(onlineRewardCfg) then
			local pkgDataList = onlineRewardCfg.reward
			local dist = 18
			local pkgCellWidth = 77
			local pkgCellHeight = 77

			for index = 1, #pkgDataList do
				local curPkgData = pkgDataList[index]
				local pkgCellObj = PkgCell.New(self.ui)
				
				pkgCellObj:SetDataByCfg(curPkgData[1], curPkgData[2], curPkgData[3], curPkgData[4])
				pkgCellObj:SetXY(238 + (pkgCellWidth + dist) * (index -1) , 13)

				pkgCellObj:OpenTips(true , false)
			end
		end
	end
end

function OnlineRewardItem:DisposePkgCellList()
	for index = 1, #self.pkgCellList do
		self.pkgCellList[index]:Destroy()
	end
	self.pkgCellList = {}
end


