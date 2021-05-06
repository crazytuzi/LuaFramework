local CHousePartner = class("CHousePartner", CHouseWalker)

function CHousePartner.ctor(self)
	CHouseWalker.ctor(self)
	self.m_HeadInfo = {
		idleHouse2 = 0.8,
		readtalk = 0.8,
		sleepHouse1 = 0.8,
		sleepHouse2 = 0.8,
		sleepHouse3 = 0.8,
		talkHouse1 = 0.8,
		playHouse = 0.8,
	}
	self.m_TempCmd = {}
	self.m_Type = nil
	self.m_Status = define.House.TrainStatus.None
	self.m_CanGetFriend = false
	self.m_TrainingType = nil
	self.m_IsHousePartner = true
	self:AddInitHud("train")
	self:AddInitHud("houseStatus")
	self:AddInitHud("guideTipsHud")
	self:GetBindTrans("head").localPosition = (Vector3.New(0, 1.2, 0))
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
end

function CHousePartner.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.PartnerRefresh then
		if self.m_Type == oCtrl.m_EventData.type then
			self:SetTrain(true)
		end
	end
end

function CHousePartner.SetTrain(self, bWalk)
	-- printc("SetTrain")
	self.m_TrainingType = nil
	local dInfo = g_HouseCtrl:GetPartnerInfo(self.m_Type)
	self:SetFriendHud(dInfo.coin ~= 0 and g_HouseCtrl:IsInFriendHouse())
	local iTime = dInfo.train_time - g_TimeCtrl:GetTimeS()
	if g_HouseCtrl:IsInFriendHouse() then
		return
	end
	if dInfo.train_type ~= 0 then
		self.m_TrainingType = dInfo.train_type
		local pos = g_HouseCtrl:GetTrainPos(dInfo.train_type)
		if self.m_Status == define.House.TrainStatus.None then
			self.m_TempPos = self:GetLocalPos()
			-- self.m_TempRotate = self:GetLocalRotation().y
		end
		if self.m_Status ~= define.House.TrainStatus.CanGet and self.m_Status ~= define.House.TrainStatus.Training then
			if bWalk and not UITools.CheckInDistanceXY(pos, self:GetLocalPos(), 0.01) then
				self:WalkTo(pos.x, pos.z, callback(self, "BeginTrain"))
			else
				self:SetPos(pos)
				self:BeginTrain()
			end
		end

		--未领取
		if iTime <= 0 then
			self.m_Status = define.House.TrainStatus.CanGet
		else
		--训练中
			self.m_Status = define.House.TrainStatus.Training
		end
		local function func(oHud)
			oHud:SetTrainTime(data.housedata.Train[dInfo.train_type].timeS, iTime, self.m_Status == define.House.TrainStatus.CanGet)
		end
		self:AddHud("train", CHouseTrainHud, self:GetBindTrans("head"), func, true)
	else
		--空闲
		self.m_Actor:StopCrossFadeLoop()
		self:DelHud("train")
		self.m_Status = define.House.TrainStatus.TrainBack
		if self.m_TempPos then
			-- printc("self.m_TempPos")
			-- table.print(self.m_TempPos, "------------->")
			self:WalkTo(self.m_TempPos.x, self.m_TempPos.z, callback(self, "OnTrainBack"))
		else
			-- printc("not self.m_TempPos")
			self:OnTrainBack()
		end
	end
end

function CHousePartner.BeginTrain(self)
	if self.m_TrainingType then
		local trainData = data.housedata.Train[self.m_TrainingType]
		self.m_Actor:SetLocalRotation(Quaternion.Euler(0, trainData.face, 0))
		self:CrossFadeLoop(trainData.motion, 0.1, 0, 1, true)
		-- printc("trainData.motion: " .. trainData.motion)
	else
	end
end

function CHousePartner.OnTrainBack(self)
	-- printc("OnTrainBack")
	self.m_Status = define.House.TrainStatus.None
	
	for k,v in pairs(self.m_TempCmd) do
		if k == "faceto" then
			self:DialogNpcDoAnimation(k, v)
			self.m_TempCmd[k] = nil
		end
	end

	if self.m_TempRotate then
		self.m_Actor:SetLocalRotation(Quaternion.Euler(0, self.m_TempRotate, 0))
	end
	if self.m_TempMotion then
		-- printc("self.m_TempMotion: " .. self.m_TempMotion)
		Utils.AddTimer(function ()
			if not Utils.IsNil(self) and not Utils.IsNil(self.m_Actor) then
				self.m_Actor:Play(self.m_TempMotion)
			end
		end, 0.1, 0.1)
		
	end
end

function CHousePartner.SetFriendHud(self, bCan)
	self.m_CanGetFriend = bCan
	if bCan then
		local function func(oHud)
			oHud:SetTouchCb(callback(self, "OnTouch"))
		end
		self:AddHud("houseStatus", CHouseStatusHud, self:GetBindTrans("head"), func, true)
	else
		self:DelHud("houseStatus")
	end
end

function CHousePartner.SetGuideTipsHud(self, b)
	if b then
		self:AddHud("guideTipsHud", CGuideTipsHud, self.m_BodyTrans, function(oHud)
			oHud:SetLocalPos(Vector3.New(0, 0, 0))
			end, false)
	else
		self:DelBindObj("guideTipsHud")
	end
end

function CHousePartner.OnTouch(self)
	if Utils.IsNil(self) then
		return
	end
	if not g_HouseCtrl:CanTouch() then
		return
	end
	if g_HouseCtrl:IsInFriendHouse() then
		if self.m_CanGetFriend then
			nethouse.C2GSRecieveHouseCoin(g_HouseCtrl.m_OwnerPid)
		end
	elseif self.m_Status == define.House.TrainStatus.CanGet then
		nethouse.C2GSRecievePartnerTrain(self.m_Type)
		local oView = CHouseMainView:GetView()
		if oView then
			oView:PlayTrainEnd()
		end
	else
		g_HouseTouchCtrl:SetRightAngle(nil)
		g_HouseTouchCtrl:SetLeftAngle(nil)
		-- CHouseExchangeView:ShowView()
		g_HouseCtrl:SetPushing(true)
		local oCam = g_CameraCtrl:GetHouseCamera()
		local objPos = self:GetPos() + Vector3.New(0, 1, 0)
		local camPos = oCam:GetPos()
		local diff = objPos - camPos
		local targetQuaternion = Quaternion.LookRotation(diff)
		oCam:Push(objPos, targetQuaternion, callback(self, "AfterPushCamera", oCam), 2)
	end
	
	if self.m_TipsGuideEnum == "house_walker_1001" then
		g_GuideCtrl:ReqForwardTipsGuideFinish("house_walker_1001")
	end
end

function CHousePartner.AfterPushCamera(self, oCam)
	-- self.m_Actor:LookAt(oCam:GetPos(), self.m_Actor:GetUp())
	Utils.AddTimer(function ()
		if g_HouseCtrl:IsInHouse() then
			if g_HouseCtrl:IsHouseOnly() then
				CHouseExchangeTestView:ShowView(function (oView)
					oView:SetPartnerInfo(self.m_Type)
					oView:SetTouchIn(true)
				end)
			else
				CHouseExchangeView:ShowView(function (oView)
					oView:SetPartnerInfo(self.m_Type)
					oView:SetTouchIn(true)
				end)
			end
		end
		g_HouseCtrl:SetPushing(false)
	end, 0.5, 0.5)
	-- CHouseExchangeView:ShowView()
end

function CHousePartner.SetData(self, clientNpc)
	self.m_ClientNpc = clientNpc
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, clientNpc.rotateY or 150, 0))
end

function CHousePartner.Trigger(self)

end

-- function CDialogueNpc.Destroy(self)
-- 	CMapWalker.Destroy(self)	
-- end

function CHousePartner.SetVisible(self, b)
	self.m_Actor:SetActive(b)
	self:SetNeedShadow(b)
	self.m_Actor:SetColliderEnbled(b)
	if b then
		self:SetNameHud(string.format("[FF00FF]%s", self.m_Name))
	else
		self:SetNameHud("")
	end
end

--NPC说话
function CHousePartner.SendMessage(self, msg)
	local oMsg = CChatMsg.New(1,  {channel = 4, text = msg})
	self:ChatMsg(oMsg)
end

function CHousePartner.CanPlayDialogueAni(self)
	return self.m_Status == define.House.TrainStatus.None and not self.m_IsWalking
end

function CHousePartner.SetTempPos(self, pos)
	self.m_TempPos = pos
end

function CHousePartner.SetTempMotion(self, action)
	-- printc("action: " .. action)
	self.m_TempMotion = action
end

function CHousePartner.SetTempRotate(self, rotateY)
	self.m_TempRotate = rotateY
end

function CHousePartner.SetModelInfo(self, dInfo)
	self:SetLocalScale(Vector3.New(0.001, 0.001, 0.001))
	self.m_Type = dInfo.type
	local dData = data.housedata.HousePartner[dInfo.type]
	if not dData then
		print("缺少宅邸伙伴导表", dInfo.type)
		return
	end
	self:ChangeShape(tonumber(dData.face), nil, function ()
		local partInfo = {[1] = 11012, [2] = 11013, [3] = 11014, [4] = 11015,}
		if dData.clothes then
			partInfo = {}
			for i,v in ipairs(dData.clothes) do
				partInfo[i] = v
			end
		end
		self.m_PartCount = table.count(partInfo) or 0
		for k,v in pairs(partInfo) do
			self:ChangePartShape(k, v, nil, callback(self, "OnPartLoadDone"))
		end
	end)
	self:SetParent(self.m_Transform)

	self:SetName(dData.name)
	if not (Utils.IsEditor() and CEditorDialogueNpcAnimView:GetView()) then
		self:SetTrain(false)
	end
end

function CHousePartner.OnPartLoadDone(self)
	self.m_PartCount = self.m_PartCount - 1
	if self.m_PartCount == 0 then
		Utils.AddTimer(callback(self, "CheckModel"), 0, 0)
	end
end

function CHousePartner.CheckModel(self)
	if not self.m_Actor.m_MainModel then
		return true
	end
	self.m_Actor:SetModelOutline(0)
	self.m_Actor:CheckAnim("idleHouse")
	-- self:SetActive(true)
	self:SetLocalScale(Vector3.New(1, 1, 1))
	self:RePlay()
end

function CHousePartner.Play(self, sState, startNormalized, endNormalized, func)
	self:ChangeHeadTrans(sState)
	self.m_Actor:Play(sState, startNormalized, endNormalized, func)
end

function CHousePartner.CrossFade(self, sState, duration, normalizedTime)
	self:ChangeHeadTrans(sState)
	self.m_Actor:CrossFade(sState, duration, normalizedTime)
end

function CHousePartner.CrossFadeLoop(self, sState, duration, startNormalized, endNormalized, isLoop, func)
	self:ChangeHeadTrans(sState)
	self.m_Actor:CrossFadeLoop(sState, duration, startNormalized, endNormalized, isLoop, func)
end

function CHousePartner.ChangeHeadTrans(self, sState)
	if self.m_HeadInfo[sState] then
		self:GetBindTrans("head").localPosition = Vector3.New(0, self.m_HeadInfo[sState], 0)
	else
		self:GetBindTrans("head").localPosition = (Vector3.New(0, 1.2, 0))
	end
end

function CHousePartner.OnStopPath(self)
	if self.classname == "CHero" then
		g_GuideCtrl:CheckTaskNvGuide(true, false)
	end
	self.m_Path = nil
	self.m_IsWalking = false
	self.m_TargetPos = nil
	
	if not self.m_IsWalking and self:GetState() ~= self.m_IdleActionName and self.m_Status ~= define.House.TrainStatus.CanGet and self.m_Status ~= define.House.TrainStatus.Training then
		self:CrossFade(self.m_IdleActionName, define.Walker.CrossFade_Time)
	end
	if self.m_WalkCompleteCb then
		self.m_WalkCompleteCb(self)
		self.m_WalkCompleteCb = nil
	end

	local function stop()
		if Utils.IsNil(self) then
			return
		end
		if not self.m_IsWalking and self:GetState() ~= self.m_IdleActionName then
			self:CrossFade(self.m_IdleActionName, define.Walker.CrossFade_Time)
		end
	end
end

return CHousePartner