local CFurnitureUpgradeView = class("CFurnitureUpgradeView", CViewBase)

function CFurnitureUpgradeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/House/FurnitureUpgradeView.prefab", cb)

	self.m_ExtendClose = "ClickOut"
end

function CFurnitureUpgradeView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_NameLabel = self:NewUI(2, CLabel)
	
	self.m_DescBox = self:NewUI(3, CBox)
	self.m_UpdateBox = self:NewUI(4, CBox)
	self.m_SpeedUpBox = self:NewUI(5, CBox)
	self.m_Icon = self:NewUI(6, CSprite)
	self.m_TotalTimeLabel = self:NewUI(7, CLabel)

	self.m_TotalTime = 0
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self:InitBox()
end

function CFurnitureUpgradeView.InitBox(self)
	self.m_DescLabel = self.m_DescBox:NewUI(1, CLabel)
	self.m_UpDescLabel = self.m_DescBox:NewUI(2, CLabel)
	
	self.m_UpgradeBtn = self.m_UpdateBox:NewUI(1, CButton)
	self.m_CoinSpr = self.m_UpdateBox:NewUI(2, CSprite)
	self.m_CoinLabel = self.m_UpdateBox:NewUI(3, CLabel)
	self.m_ItemSpr = self.m_UpdateBox:NewUI(4, CSprite)
	self.m_ItemLabel = self.m_UpdateBox:NewUI(5, CLabel)

	self.m_SpeedUpBtn = self.m_SpeedUpBox:NewUI(1, CButton)
	self.m_Slider = self.m_SpeedUpBox:NewUI(2, CSlider)
	self.m_TimeLabel = self.m_SpeedUpBox:NewUI(3, CLabel)
	self.m_TimeLabel:SetText("")

	self.m_UpgradeBtn:AddUIEvent("click", callback(self, "OnUpgrade"))
	self.m_SpeedUpBtn:AddUIEvent("click", callback(self, "OnSpeedUp"))
end

function CFurnitureUpgradeView.SetFurniture(self, oFurniture)
	self.m_Type = oFurniture:GetValue("upgrade_type")
	local iLevel = oFurniture:GetValue("level")
	local sTitle = string.format("%s升级至%d级", oFurniture:GetValue("name"), iLevel+ 1)
	self.m_NameLabel:SetText(sTitle)
	self.m_TotalTime = oFurniture:GetValue(iLevel)["up_level_time"]
	self.m_TotalTimeLabel:SetText(string.format("时间:%.2fH", self.m_TotalTime/3600))
	self.m_DescLabel:SetText(oFurniture:GetValue(iLevel)["desc"])
	self.m_UpDescLabel:SetText(oFurniture:GetValue(iLevel)["effect_desc"])
	self:UpdateDesc(oFurniture)
end

function CFurnitureUpgradeView.UpdateDesc(self, oFurniture)
	local bUpgrading = oFurniture:GetLeftUpgradeTime() > 0
	self.m_UpdateBox:SetActive(not bUpgrading)
	self.m_SpeedUpBox:SetActive(bUpgrading)
	if bUpgrading then
		self:ShowSpeedUpBox(oFurniture)
	else
		self:ShowUpdateBox(oFurniture)
	end
end

function CFurnitureUpgradeView.ShowSpeedUpBox(self, oFurniture)
	if not self.m_SliderTimer then
		local function update()
			if Utils.IsNil(self) then
				return false
			end
			local iLeft = oFurniture:GetLeftUpgradeTime()
			if iLeft < 0 then
				self:UpdateDesc(oFurniture)
				return false
			end
			self.m_Slider:SetValue(iLeft/ self.m_TotalTime)
			self.m_Slider:SetSliderText(os.date("%H:%M:%S", iLeft))
			local iGoldCnt = math.ceil(iLeft / 15)
			self.m_SpeedUpBtn:SetText(tostring(iGoldCnt))
			return true
		end
		self.m_SliderTimer = Utils.AddTimer(update, 0.5, 0)
	end
end

function CFurnitureUpgradeView.ShowUpdateBox(self, oFurniture)
	local iLevel = oFurniture:GetValue("level")
	local dTypeNeed = oFurniture:GetValue(iLevel)
	self.m_CoinLabel:SetText(tostring(dTypeNeed.gold))
	self.m_ItemLabel:SetText(tostring(dTypeNeed.item_cnt))
end

function CFurnitureUpgradeView.OnUpgrade(self)
	nethouse.C2GSHousePromoteFurniture(self.m_Type)
	self:CloseView()
end

function CFurnitureUpgradeView.OnSpeedUp(self)
	nethouse.C2GSHouseSpeedFurniture(self.m_Type)
	self:CloseView()
end

return CFurnitureUpgradeView