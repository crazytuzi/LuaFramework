local CHouseTrainPart = class("CHouseTrainPart", CBox)

function CHouseTrainPart.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ProcessLabel = self:NewUI(1, CLabel)
	self.m_TrainGrid = self:NewUI(2, CGrid)
	self.m_TrainBox = self:NewUI(3, CBox)
	self:InitContent()
end

function CHouseTrainPart.InitContent(self)
	self.m_TrainCb = nil
	self.m_TrainingCount = 0
	self.m_TrainBox:SetActive(false)
	self.m_Data = data.housedata.Train
	self.m_TrainBoxDic = {}
	for i,v in ipairs(self.m_Data) do
		self.m_TrainBoxDic[v.id] = self:CreateTrainBox()
		self.m_TrainGrid:AddChild(self.m_TrainBoxDic[v.id])
		self.m_TrainBoxDic[v.id]:SetActive(true)
		self.m_TrainBoxDic[v.id]:SetData(v)
		self.m_TrainBoxDic[v.id].m_Idx = i
		if i == 1 then
			g_GuideCtrl:AddGuideUI("house_train_box_1_btn", self.m_TrainBoxDic[v.id])
		end
	end

	local guide_ui = {"house_train_box_1_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)	
	
	self.m_TrainBox:SetActive(false)
	self:Refresh()
end

function CHouseTrainPart.CreateTrainBox(self)
	local oTrainBox = self.m_TrainBox:Clone()
	oTrainBox.m_TimeLabel = oTrainBox:NewUI(1, CLabel)
	oTrainBox.m_DescLabel = oTrainBox:NewUI(2, CLabel)
	oTrainBox.m_LoveLabel = oTrainBox:NewUI(3, CLabel)
	oTrainBox.m_AvatarSprite = oTrainBox:NewUI(4, CSprite)
	oTrainBox.m_GameSprite = oTrainBox:NewUI(5, CSprite)
	oTrainBox:AddUIEvent("click", callback(self, "OnTrain", oTrainBox))

	function oTrainBox.SetData(self, oData)
		oTrainBox.m_Data = oData
		oTrainBox.m_Text = ""
		if oData.time < 60 then
			oTrainBox.m_Text = oData.time .. "分钟"
		else
			oTrainBox.m_Text = math.modf(oData.time/60) .. "小时"
		end
		oTrainBox.m_TimeLabel:SetText(oTrainBox.m_Text)
		oTrainBox.m_DescLabel:SetText(oData.name)
		oTrainBox.m_LoveLabel:SetText("好感度+" .. oData.loveship)
		oTrainBox.m_AvatarSprite:SetSpriteName("")
		oTrainBox.m_GameSprite:SetSpriteName(oData.icon)
	end

	return oTrainBox
end

function CHouseTrainPart.SetTrainCb(self, cb)
	self.m_TrainCb = cb
end

function CHouseTrainPart.OnTrain(self, oTrainBox)
	-- printc("OnTrain: " .. oTrainBox.m_Data.id)
	if self.m_TrainingCount >= g_HouseCtrl.m_MaxTrainCnt then
		g_NotifyCtrl:FloatMsg("您的娱乐位已被占满")
		-- local windowConfirmInfo = {
		-- 	msg = string.format("娱乐位置已占满，是否支付%s水晶增加一个娱乐位？", 100),
		-- 	okStr = "确认",
		-- 	cancelStr = "取消",
		-- 	okCallback = function()
				
		-- 	end
		-- }
		-- g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	elseif oTrainBox.m_IsTraining then
		g_NotifyCtrl:FloatMsg("这个训练位置被霸占了噢")
	elseif self.m_TrainCb ~= nil then
		self.m_TrainCb(oTrainBox.m_Data.id)
	end

	if oTrainBox.m_Idx == 1 then
		g_GuideCtrl:ReqForwardTipsGuideFinish("house_train_box_1_btn")
	end
end

function CHouseTrainPart.Refresh(self)
	if self.m_TimerID == nil then
		self.m_TimerID = Utils.AddTimer(callback(self, "OnUpdate"), 0.2, 0.2)
	end
end

function CHouseTrainPart.OnUpdate(self)
	local count = 0
	for k,v in pairs(self.m_TrainBoxDic) do
		v.m_AvatarSprite:SetSpriteName("")
		v.m_TimeLabel:SetText(v.m_Text)
		v.m_IsTraining = false
	end
	local housePartnerDic = g_HouseCtrl:GetPartnerInfos()
	for k,v in pairs(housePartnerDic) do
		if v.train_type ~= 0 then
			local time = v.train_time - g_TimeCtrl:GetTimeS()
			if time > 0 then
				self.m_TrainBoxDic[v.train_type].m_TimeLabel:SetText(string.format("%02d:%02d:%02d", math.modf(time / 3600), math.modf((time % 3600) /60), (time % 60)))
			else
				self.m_TrainBoxDic[v.train_type].m_TimeLabel:SetText("娱乐完成")
			end
			self.m_TrainBoxDic[v.train_type].m_AvatarSprite:SetSpriteName("" .. data.housedata.HousePartner[v.type].shape)
			self.m_TrainBoxDic[v.train_type].m_IsTraining = true
			count = count + 1
		end
	end
	self.m_TrainingCount = count
	self.m_ProcessLabel:SetText(string.format("娱乐：（%s/%s）", count, g_HouseCtrl.m_MaxTrainCnt))
	if count > 0 then
		return true
	end
	self.m_TimerID = nil
	return false
end

function CHouseTrainPart.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.PartnerRefresh then
		self:Refresh()
	end
end

return CHouseTrainPart