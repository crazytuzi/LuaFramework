local CHouseExchangeView = class("CHouseExchangeView", CViewBase)
--伙伴交流界面
function CHouseExchangeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/House/HouseExchangeView.prefab", cb)

	self.m_GroupName = "House"
	
end

function CHouseExchangeView.OnCreateView(self)
	self.m_BackBtn = self:NewUI(1, CButton)
	self.m_LiveTexture = self:NewUI(2, CLive2dTexture)
	self.m_PreBtn = self:NewUI(3, CButton)
	self.m_NextBtn = self:NewUI(4, CButton)
	self.m_GuideBtn = self:NewUI(5, CBox)
	self.m_QuitBtn = self:NewUI(6, CButton)
	self.m_TaskBtn = self:NewUI(7, CButton)
	self.m_TrainBtn = self:NewUI(8, CButton)
	self.m_GiftBtn = self:NewUI(9, CButton)
	self.m_HideBtn = self:NewUI(10, CButton)
	self.m_TouchPart = self:NewUI(11, CBox)
	self.m_PartnerInfoPart = self:NewUI(12, CHouseExchangePartnerPart)
	self.m_TrainPart = self:NewUI(13, CHouseTrainPart)
	self.m_GiftPart = self:NewUI(14, CHouseGiftPart, true, {
		start_delta = {x=5,y=0},
		cb_dragging = callback(self, "OnDragging"),
		cb_dragend = callback(self, "OnDragEnd")
	})
	self.m_ExpInfoBox = self:NewUI(15, CBox)
	self.m_HidePart = self:NewUI(16, CBox)
	self.m_GiftRect = self:NewUI(17, CBox)
	self.m_GiftEffect = self:NewUI(18, CUIEffect)
	self.m_BgTexture = self:NewUI(19, CTexture)
	self.m_SpeakLabel = self:NewUI(20, CLabel)
	-- self.m_SpeakTween = self.m_SpeakLabel:GetComponent(classtype.TweenScale)
	self.m_Mode = nil
	self.m_SoundPlayer = g_AudioCtrl:GetSoundPlayer()
	self:InitTouchPart()
	self:InitExpInfoBox()
	self:InitContent()
	self.m_IsTouchIn = false
	-- g_CameraCtrl:AutoActive()
end

function CHouseExchangeView.InitContent(self)
	self.m_SpeakLabel:SetActive(false)
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	self.m_LiveTexture:AddClickCallback(callback(self, "OnTouchExchange"))
	self.m_PreBtn:AddUIEvent("click", callback(self, "OnClickPre"))
	self.m_NextBtn:AddUIEvent("click", callback(self, "OnClickNext"))
	self.m_GuideBtn:AddUIEvent("click", callback(self, "OnGuide"))
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuit"))
	self.m_TaskBtn:AddUIEvent("click", callback(self, "SetMode", "task"))
	self.m_TrainBtn:AddUIEvent("click", callback(self, "SetMode", "train"))
	self.m_GiftBtn:AddUIEvent("click", callback(self, "SetMode", "gift"))
	self.m_HideBtn:AddUIEvent("click", callback(self, "OnClickHide"))

	self.m_BackBtn.m_IgnoreCheckEffect = true
	g_GuideCtrl:AddGuideUI("house_touch_btn", self.m_GuideBtn)
	g_GuideCtrl:AddGuideUI("house_back_btn", self.m_BackBtn)
	g_GuideCtrl:AddGuideUI("house_train_btn", self.m_TrainBtn)

	g_GuideCtrl:CheckHouseBackGuide()

	local guide_ui = {"house_touch_btn", "house_train_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)


	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
	g_GuideCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlGuideEvent"))

	UITools.ResizeToRootSize(self.m_BgTexture, 4, 4)
	-- local w, h = self.m_BgTexture:GetSize()
	-- local texture = Utils.ScreenShoot(g_CameraCtrl:GetHouseCamera(), w, h)
	-- self.m_BgTexture:SetMainTexture(texture)
	self.m_GiftEffect:Above(self.m_LiveTexture)
	self.m_TouchPart:RefreshTouchCnt()
	self.m_PartnerList = g_HouseCtrl:GetPartnerList()
	self.m_TypeToIdx = {}
	self.m_TrainBtn.m_IgnoreCheckEffect = true
	self.m_GiftBtn.m_IgnoreCheckEffect = true
	for i,v in ipairs(self.m_PartnerList) do
		self.m_TypeToIdx[v.type] = i
	end
	self.m_GiftEffect:SetActive(false)
	self.m_GuideBtn:SetActive(not g_GuideCtrl:IsCustomGuideFinishByKey("HouseExchangeView"))
	self.m_TrainPart:SetTrainCb(callback(self, "OnTrain"))
	self:CheckRedDot()
end

function CHouseExchangeView.CheckRedDot(self)
	if g_HouseCtrl:IsNeedTrainRedDot() then
		self.m_TrainBtn:AddEffect("RedDot")
	else
		self.m_TrainBtn:DelEffect("RedDot")
	end
	if g_HouseCtrl:IsNeedGiftRedDot() then
		self.m_GiftBtn:AddEffect("RedDot")
	else
		self.m_GiftBtn:DelEffect("RedDot")
	end
	if g_HouseCtrl:IsTouchNeedRedDot() then
		self.m_TouchPart.m_TouchSprite:AddEffect("RedDot")
	else
		self.m_TouchPart.m_TouchSprite:DelEffect("RedDot")
	end
end

function CHouseExchangeView.OnClickHide(self)
	self.m_ModelPos = self.m_LiveTexture:GetPos()
	local pos = self.m_ModelPos
	self.m_LiveTexture:SetPos(Vector3.New(0, pos.y, pos.z))
	self.m_HidePart:SetActive(false)
end

function CHouseExchangeView.InitExpInfoBox(self)
	local oExpInfoBox = self.m_ExpInfoBox
	oExpInfoBox.m_LevelLabel = oExpInfoBox:NewUI(1, CLabel)
	oExpInfoBox.m_NameLabel = oExpInfoBox:NewUI(2, CLabel)
	oExpInfoBox.m_Slider = oExpInfoBox:NewUI(3, CSlider)
	oExpInfoBox.m_Effect = oExpInfoBox:NewUI(4, CUIEffect)
	oExpInfoBox.m_FrontSprite = oExpInfoBox:NewUI(5, CSprite)
	oExpInfoBox.m_ExpLabel = oExpInfoBox:NewUI(6, CLabel)
	oExpInfoBox.m_Effect:Above(oExpInfoBox.m_FrontSprite)

	oExpInfoBox.m_ExpLabel:SetActive(false)
	oExpInfoBox.m_Effect:SetActive(false)
	oExpInfoBox.m_ParentView = self
	function oExpInfoBox.Refresh(self, bPlay)
		local dData = data.housedata.HousePartner[oExpInfoBox.m_ParentView.m_CurType]
		local dPartnerInfo = g_HouseCtrl:GetPartnerInfo(oExpInfoBox.m_ParentView.m_CurType)
		oExpInfoBox.m_NameLabel:SetText(dData.name)
		local lastTargetLv = oExpInfoBox.m_TargetLv or oExpInfoBox.m_CurrentLv
		local lastTargetExp = oExpInfoBox.m_TargetExp or oExpInfoBox.m_CurrentExp
		if oExpInfoBox.m_CurrentLv ~= nil and bPlay then
			oExpInfoBox.m_TargetLv = dPartnerInfo.love_level
			oExpInfoBox.m_TargetExp = dPartnerInfo.love_ship
			oExpInfoBox.m_Effect:SetActive(true)
			oExpInfoBox.m_AddCount = 0
			for i = oExpInfoBox.m_CurrentLv, oExpInfoBox.m_TargetLv - 1 do
				oExpInfoBox.m_AddCount = oExpInfoBox.m_AddCount + g_HouseCtrl:GetMaxLove(i)
			end
			oExpInfoBox.m_AddCount = (oExpInfoBox.m_AddCount + oExpInfoBox.m_TargetExp - oExpInfoBox.m_CurrentExp)/ 100
			local iExpText = 0
			for i = lastTargetLv, oExpInfoBox.m_TargetLv - 1 do
				iExpText = iExpText + g_HouseCtrl:GetMaxLove(i)
			end
			iExpText = (iExpText + oExpInfoBox.m_TargetExp - lastTargetExp)
			if iExpText > 0 then
				local expAni = oExpInfoBox.m_ExpLabel:Clone()
				expAni:SetText(iExpText)
				expAni:SetActive(true)
				expAni:SetParent(oExpInfoBox.m_Transform)
				expAni:DelayCall(2, "Destroy")
			end
			
			if oExpInfoBox.m_Timer == nil then
				oExpInfoBox.m_Timer = Utils.AddTimer(callback(oExpInfoBox, "AddExp"), 0, 0)
			end
		else
			if oExpInfoBox.m_Timer ~= nil then
				Utils.DelTimer(oExpInfoBox.m_Timer)
				oExpInfoBox.m_Effect:SetActive(false)
				oExpInfoBox.m_Timer = nil
			end
			oExpInfoBox.m_TargetLv = nil
			oExpInfoBox.m_TargetExp = nil
			oExpInfoBox.m_CurrentLv = dPartnerInfo.love_level
			oExpInfoBox.m_CurrentExp = dPartnerInfo.love_ship
			oExpInfoBox.m_LevelLabel:SetText(dPartnerInfo.love_level)
			local iCur = dPartnerInfo.love_ship
			local iNext = g_HouseCtrl:GetMaxLove(dPartnerInfo.love_level)
			oExpInfoBox.m_Slider:SetSliderText(string.format("%d/%d", iCur, iNext))
			oExpInfoBox.m_Slider:SetValue(iCur/iNext)
		end
	end

	function oExpInfoBox.AddExp(self)
		local iMax = g_HouseCtrl:GetMaxLove(oExpInfoBox.m_CurrentLv)
		local iAdd = oExpInfoBox.m_AddCount
		if iAdd > iMax / 3 then
			iAdd = iMax / 3
		end
		oExpInfoBox.m_CurrentExp = oExpInfoBox.m_CurrentExp + iAdd
		if oExpInfoBox.m_CurrentLv < oExpInfoBox.m_TargetLv then
			if oExpInfoBox.m_CurrentExp > iMax then
				oExpInfoBox.m_CurrentLv = oExpInfoBox.m_CurrentLv + 1
				oExpInfoBox.m_ParentView.m_GiftEffect:SetActive(false)
				oExpInfoBox.m_ParentView.m_GiftEffect:SetActive(true)
				oExpInfoBox.m_LevelLabel:SetText(oExpInfoBox.m_CurrentLv)
				oExpInfoBox.m_CurrentExp = 0
			end
		else
			oExpInfoBox.m_CurrentExp = oExpInfoBox.m_CurrentExp + iAdd
			if oExpInfoBox.m_CurrentExp >= oExpInfoBox.m_TargetExp then
				oExpInfoBox.m_CurrentExp = oExpInfoBox.m_TargetExp
				oExpInfoBox.m_Slider:SetSliderText(string.format("%d/%d", oExpInfoBox.m_CurrentExp, iMax))
				oExpInfoBox.m_Slider:SetValue(oExpInfoBox.m_CurrentExp/iMax)
				oExpInfoBox.m_Timer = nil
				oExpInfoBox.m_Effect:SetActive(false)
				return false
			end
		end
		oExpInfoBox.m_Slider:SetSliderText(string.format("%d/%d", oExpInfoBox.m_CurrentExp, iMax))
		oExpInfoBox.m_Slider:SetValue(oExpInfoBox.m_CurrentExp/iMax)
		return true
	end
end

--宅邸引导
function CHouseExchangeView.OnGuide(self)
	local dData = self.m_LiveTexture.m_LiveModel:CheckTouchPos()
	if self.m_IsTweening then
		return
	end
	self:PlaySpeak(dData)
	if g_HouseCtrl.m_CurTouchCnt > 0 then
		nethouse.C2GSLovePartner(self.m_CurType, 1)
	end
	g_GuideCtrl:ReqForwardTipsGuideFinish("house_touch_btn")
end

function CHouseExchangeView.OnQuit(self)
	g_HouseCtrl:LeaveHouse()
end

function CHouseExchangeView.OnClickPre(self)
	if self.m_PartnerList == nil or #self.m_PartnerList < 2 then
		return
	end
	self.m_CurrentIndex = self.m_CurrentIndex - 1
	if self.m_CurrentIndex < 1 then
		self.m_CurrentIndex = #self.m_PartnerList
	end
	self.m_CurType = self.m_PartnerList[self.m_CurrentIndex].type
	self:RefeshPartnerInfo()
end

function CHouseExchangeView.OnClickNext(self)
	if self.m_PartnerList == nil or #self.m_PartnerList < 2 then
		return
	end
	self.m_CurrentIndex = self.m_CurrentIndex + 1
	if self.m_CurrentIndex > #self.m_PartnerList then
		self.m_CurrentIndex = 1
	end
	self.m_CurType = self.m_PartnerList[self.m_CurrentIndex].type
	self:RefeshPartnerInfo()
end

function CHouseExchangeView.SetPartnerInfo(self, iType)
	self.m_CurType = iType
	self.m_CurrentIndex = self.m_TypeToIdx[iType]
	self:RefeshPartnerInfo()
	self:SetMode("task")
end

function CHouseExchangeView.RefeshPartnerInfo(self)
	local dPartnerInfo = g_HouseCtrl:GetPartnerInfo(self.m_CurType)
	local dData = data.housedata.HousePartner[self.m_CurType]
	self.m_LiveTexture:SetDefaultMotion(g_HouseCtrl:GetCurrentLoveStage(self.m_CurType).motion)
	self.m_LiveTexture:LoadModel(self.m_CurType)
	self.m_ExpInfoBox:Refresh(false)
	self.m_PartnerInfoPart:SetPartnerType(self.m_CurType)
	self.m_SoundPlayer:Stop()
end

function CHouseExchangeView.InitTouchPart(self)
	local oTouchPart = self.m_TouchPart
	oTouchPart.m_TouchSprite = oTouchPart:NewUI(1, CSprite)
	oTouchPart.m_TouchCntLabel = oTouchPart:NewUI(2, CLabel)
	oTouchPart.m_CountDownLabel = oTouchPart:NewUI(3, CCountDownLabel)
	
	function oTouchPart.RefreshTouchCnt(self, OData)
		local sText = string.format("%d/%d", g_HouseCtrl.m_CurTouchCnt, g_HouseCtrl.m_MaxTouchCnt)
		oTouchPart.m_TouchSprite:SetGrey(g_HouseCtrl.m_CurTouchCnt == 0)
		if g_HouseCtrl.m_SuppleLoveTime == 0 then
			oTouchPart.m_CountDownLabel:SetActive(false)
		else
			oTouchPart.m_CountDownLabel:SetActive(true)
			oTouchPart.m_CountDownLabel:BeginCountDown(g_HouseCtrl.m_SuppleLoveTime)
		end
		oTouchPart.m_TouchCntLabel:SetText(sText)
	end

	function oTouchPart.OnCount(self, iValue)
		oTouchPart.m_CountDownLabel:SetText(string.format("%d:%02d", math.modf(iValue / 60), (iValue % 60)))
	end

	function oTouchPart.OnTimeUp(self)
		oTouchPart.m_CountDownLabel:SetActive(false)
	end
	oTouchPart.m_CountDownLabel:SetTickFunc(callback(oTouchPart, "OnCount"))
	oTouchPart.m_CountDownLabel:SetTimeUPCallBack(callback(oTouchPart, "OnTimeUp"))
end

function CHouseExchangeView.SetMode(self, sMode)
	if sMode=="task" then
		self.m_PartnerInfoPart:ShowTask()
	end
	if self.m_Mode == sMode then
		return
	end

	if sMode == "train" then
		g_GuideCtrl:ReqForwardTipsGuideFinish("house_train_btn")
	end

	self.m_Mode = sMode
	self.m_TrainPart:SetActive(false)
	self.m_GiftPart:SetActive(false)
	
	self.m_TrainPart:SetActive(sMode=="train")
	self.m_GiftPart:SetActive(sMode=="gift")
	self.m_PartnerInfoPart:SetActive(sMode=="task")
end

function CHouseExchangeView.OnTouchExchange(self, dData)
	if not self.m_HidePart:GetActive() then
		return
	end
	if self.m_IsTweening then
		return
	end
	self:PlaySpeak(dData)
	if g_HouseCtrl.m_CurTouchCnt > 0 then
		nethouse.C2GSLovePartner(self.m_CurType, dData.part)
		-- g_NotifyCtrl:FloatMsg("部位"..tostring(iPart))
	else
		-- g_NotifyCtrl:FloatMsg("人家害羞的啦")
	end
end

function CHouseExchangeView.PlaySpeak(self, dData)
	if dData then
		self.m_LiveTexture:PlayMotion(dData.motionName)
		if dData.speak_id and #dData.speak_id > 0 then
			local iRan = dData.speak_id[Utils.RandomInt(1, #dData.speak_id)]
			local speakData = data.housedata.Live2d_Speak[iRan]
			if speakData then
				if speakData.word ~= "" then
					self.m_SpeakLabel:SetText(speakData.word)
					self.m_SpeakLabel:SetActive(true)
					-- self.m_SpeakTween:Toggle()
					self.m_SpeakLabel:SetLocalScale(Vector3.New(0.01, 0.01, 0.01))
					self.m_IsTweening = true
					local tween = DOTween.DOScale(self.m_SpeakLabel.m_Transform, Vector3.one, 0.2)
					DOTween.SetEase(tween, enum.DOTween.Ease.OutSine)
					DOTween.OnComplete(tween, function ()
						self.m_IsTweening = false
					end)
					self.m_IsTalking = true
				end
				self.m_SoundPlayer:Play(string.format("Audio/Sound/Live2D/%s/%s.wav", self.m_CurType, speakData.sound))
				self.m_SoundPlayer:SetStopCb(callback(self, "HideTalk"))
			end
		end
	end
end

function CHouseExchangeView.HideTalk(self, oAudioPlayer)
	if self.m_IsTalking then
		oAudioPlayer:SetStopCb(nil)
		-- self.m_SpeakTween:Toggle()
		self.m_IsTweening = true
		self.m_SpeakLabel:SetLocalScale(Vector3.one)
		local tween = DOTween.DOScale(self.m_SpeakLabel.m_Transform, Vector3.zero, 0.2)
		DOTween.SetEase(tween, enum.DOTween.Ease.InSine)
		DOTween.OnComplete(tween, function ()
			self.m_IsTweening = false
		end)
		self.m_IsTalking = false
	end
end

function CHouseExchangeView.OnDragging(self, oDragObj)

end

function CHouseExchangeView.OnDragEnd(self, oDragObj)
	local pos = oDragObj:GetCenterPos()
	if self.m_GiftRect:IsInRect(pos) then
		-- print("赠送礼物", self.m_CurType, oDragObj.m_ID)
		if  g_HouseCtrl.m_RemainGiveGiftCnt <= 0 then
			g_NotifyCtrl:FloatMsg("送礼次数已用尽，请购买次数")
		else
			nethouse.C2GSGivePartnerGift(self.m_CurType, oDragObj.m_ID)
		end
	end
end

function CHouseExchangeView.OnHouseEvent(self, oCtrl)
	self:CheckRedDot()
	if oCtrl.m_EventID == define.House.Event.TouchRefresh then
		self.m_TouchPart:RefreshTouchCnt()
	elseif oCtrl.m_EventID == define.House.Event.PartnerRefresh then
		if self.m_CurType == oCtrl.m_EventData.type then
			self.m_ExpInfoBox:Refresh(true)
			self.m_PartnerInfoPart:SetPartnerType(self.m_CurType)
		end
	elseif oCtrl.m_EventID == define.House.Event.GivePartnerGift then
		self.m_GiftEffect:SetActive(false)
		self.m_GiftEffect:SetActive(true)
	end
end

function CHouseExchangeView.OnCtrlGuideEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Guide.Event.StartGuide then
		self.m_GuideBtn:SetActive(not g_GuideCtrl:IsCustomGuideFinishByKey("HouseExchangeView"))
	elseif oCtrl.m_EventID == define.Guide.Event.EndGuide then
		self.m_GuideBtn:SetActive(not g_GuideCtrl:IsCustomGuideFinishByKey("HouseExchangeView"))
	end
end

function CHouseExchangeView.Destroy(self)
	local cameraPos = g_HouseCtrl:GetCameraPos()
	local targetPos = Vector3.New(cameraPos.pos.x, cameraPos.pos.y, cameraPos.pos.z)
	local targetQuaternion = Quaternion.Euler(Vector3.New(cameraPos.rotate.x, cameraPos.rotate.y, cameraPos.rotate.z))
	local oCam = g_CameraCtrl:GetHouseCamera()
	g_HouseCtrl:SetPushing(true)
	local function cb()
		g_HouseCtrl:LoadCameraPos()
		-- g_HouseCtrl:SetPushing(false)
		g_GuideCtrl:TriggerAll()
	end
	if self.m_IsTouchIn then
		oCam:Push(targetPos, targetQuaternion, cb)
	else
		cb()
	end
	self.m_LiveTexture:Destroy()
	g_GuideCtrl:CheckHouseBackGuide(true)
	CViewBase.Destroy(self)
end

function CHouseExchangeView.OnClickClose(self)
	if self.m_HidePart:GetActive() then
		self:CloseView()
	else
		self.m_LiveTexture:SetPos(self.m_ModelPos)
		self.m_HidePart:SetActive(true)
	end
end

function CHouseExchangeView.SetTouchIn(self, bValue)
	self.m_IsTouchIn = bValue
end

function CHouseExchangeView.OnTrain(self, iType)
	nethouse.C2GSTrainPartner(self.m_CurType, iType)
	self:CloseView()
	local oView = CHouseMainView:GetView()
	if oView then
		oView:PlayTrainStart()
	end
end

return CHouseExchangeView