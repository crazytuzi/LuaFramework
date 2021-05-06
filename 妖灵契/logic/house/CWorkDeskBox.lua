local CWorkDeskBox = class("CWorkDeskBox", CBox)

function CWorkDeskBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_WorkBtn = self:NewUI(1, CButton)
	self.m_RewardBtn = self:NewUI(2, CBox)
	self.m_CountDownBox = self:NewUI(3, CBox)
	self.m_ProcessSlider = self:NewUI(4, CSlider)
	self.m_ItemSprite = self:NewUI(5, CSprite)
	self.m_ModelTexture = self:NewUI(6, CSpineTexture)
	self.m_EffectSprite = self:NewUI(7, CSprite)
	self.m_Effect = self:NewUI(8, CUIEffect)
	self.m_SpeedBtn = self:NewUI(9, CButton)
	self.m_CostLabel = self:NewUI(11, CLabel)
	self.m_Effect:Above(self.m_EffectSprite)
	self:InitContent()
end

function CWorkDeskBox.SetParentView(self, oParentView)
	self.m_ParentView = oParentView
end

function CWorkDeskBox.InitContent(self)
	-- self:SetActive(false)
	self:SetLocalScale(Vector3.zero)
	self.m_DeskPos = 0
	self.m_SpeedUpCost = 0
	self.m_SpeedBtn:AddUIEvent("click", callback(self, "OnClickSpeed"))
	self.m_WorkBtn:AddUIEvent("click", callback(self, "OnModel"))
	self.m_ModelTexture:AddUIEvent("click", callback(self, "OnModel"))
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
end

function CWorkDeskBox.OnClickSpeed(self)
	nethouse.C2GSWorkDeskSpeedFinish(self.m_DeskPos ,self.m_SpeedUpCost)
end

function CWorkDeskBox.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.WorkDeskRefresh then
		if oCtrl.m_EventData == self.m_DeskPos then
			self:RefeshDesk()
		end
	end
end

function CWorkDeskBox.SetPos(self, pos)
	self.m_DeskPos = pos
	self.m_ModelTexture:ShapeHouse("CHIHO" .. pos, callback(self, "RefeshDesk"))
	if pos == 1 then
		self.m_GuideCookerBtn = self:NewUI(10, CButton)
		self.m_GuideCookerBtn.m_IgnoreCheckEffect = true
		self.m_GuideCookerBtn:AddUIEvent("click", callback(self, "OnModel"))
		g_GuideCtrl:AddGuideUI("house_cooker_idx_1_btn", self.m_GuideCookerBtn)
		g_GuideCtrl:AddGuideUI("house_cooker_work_1_btn", self.m_WorkBtn)
	end
end

function CWorkDeskBox.RefeshDesk(self)
	-- self:SetActive(true)
	self:SetLocalScale(Vector3.one)
	self.m_Info = g_HouseCtrl:GetWorkDeskInfo(self.m_DeskPos)
	local iLeft = self:GetLeftWorkTime()
	self.m_WorkBtn:SetActive(self.m_Info.status == 1 and self.m_Info.lock_status == 1)
	self.m_RewardBtn:SetActive(false)
	self.m_CountDownBox:SetActive(false)
	self.m_SpeedBtn:SetActive(self.m_Info.status == 2)
	-- self.m_ModelTexture:SetActive(self.m_Info.lock_status == 1)
	self.m_playing = false
	--可领取
	if self.m_Info.status == 3 then
		local itemData = DataTools.GetItemData(self.m_Info.item_sid)
		if itemData then
			self.m_ItemSprite:SpriteItemShape(itemData.icon)
		end
		self.m_RewardBtn:SetActive(true)
		self.m_ModelTexture:SetAnimation(0, "idle_2", true)
	--制作中
	elseif self.m_Info.status == 2 then
		local iMax = data.housedata.HouseDefine.talent_show_time.value
		if iLeft > 0 then
			if not self.m_Timer then
				self.m_Timer = Utils.AddTimer(callback(self, "RefreshTime"), 0.5, 0)
			end
			self.m_playing = self.m_ModelTexture:SetAnimation(0, "idle_1", true)
		else
			self.m_ProcessSlider:SetValue(0)
			self.m_ProcessSlider:SetSliderText("00:00:00")
			self.m_ModelTexture:SetAnimation(0, "idle_2", true)
		end
		self.m_CountDownBox:SetActive(true)
		self.m_SpeedUpCost = string.eval(data.globaldata.GLOBAL.house_teaart_speed_cost.value, {n = self.m_Info.speed_num + 1})
		local maxCost = tonumber(data.globaldata.GLOBAL.house_worddesk_max_cost.value)
		if self.m_SpeedUpCost > maxCost then
			self.m_SpeedUpCost = maxCost
		end
		self.m_CostLabel:SetText(self.m_SpeedUpCost)
	--空闲
	else
		self.m_ModelTexture:SetAnimation(0, "idle_2", true)
	end
end

function CWorkDeskBox.RefreshTime(self)
	local iLeft = self:GetLeftWorkTime()
	if self.m_Info.status ~= 2 then
		iLeft = 0
	end
	local iMax = data.housedata.HouseDefine.talent_show_time.value
	if iLeft > 0 then
		if not self.m_playing then
			self.m_playing = self.m_ModelTexture:SetAnimation(0, "idle_1", true)
		end
		local sText = string.format("%02d:%02d:%02d", math.modf(iLeft / 3600), math.modf((iLeft % 3600) /60), (iLeft % 60))
		self.m_ProcessSlider:SetSliderText(sText)
		if iLeft > iMax then
			self.m_ProcessSlider:SetValue(0)
		else
			self.m_ProcessSlider:SetValue((iMax - iLeft)/iMax)
		end
		return true
	else
		self.m_ProcessSlider:SetValue(0)
		self.m_ProcessSlider:SetSliderText("00:00:00")
		self.m_ModelTexture:SetAnimation(0, "idle_2", true)
		self.m_Timer = nil
		return false
	end
end

function CWorkDeskBox.GetLeftWorkTime(self)
	local iEnd = self.m_Info.create_time + self.m_Info.talent_time
	local iLeft = iEnd - g_TimeCtrl:GetTimeS()
	return iLeft
end


function CWorkDeskBox.OnWork(self)
	nethouse.C2GSTalentShow(self.m_DeskPos)
	if self.m_DeskPos == 1 then
		g_GuideCtrl:TargetGuideStepContinu("HouseTeaartView", 2)
	end
end

function CWorkDeskBox.OnModel(self)
	if self.m_Info.status == 1 then
		-- self.m_ParentView:OnHideBox()
		self:OnWork()
		-- self.m_WorkBtn:SetActive(true)
	elseif self.m_Info.status == 2 then
		g_NotifyCtrl:FloatMsg("到底在做什么东西呢，再等等吧！")
	elseif self.m_Info.status == 3 then
		self.m_ParentView:ShowReward(self.m_Info)
		nethouse.C2GSTalentDrawGift(self.m_DeskPos)
	end
	if self.m_DeskPos == 1 then
		g_GuideCtrl:TargetGuideStepContinu("HouseTeaartView", 2)
	end
end

-- function CWorkDeskBox.HideBox(self)
-- 	self.m_WorkBtn:SetActive(false)
-- end


return CWorkDeskBox