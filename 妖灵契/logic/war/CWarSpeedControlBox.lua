local CWarSpeedControlBox = class("CWarSpeedControlBox", CBox)
CWarSpeedControlBox.OverlayIdx = 7

function CWarSpeedControlBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_AvatarBoxClone = self:NewUI(1, CWarSpeedAvatarBox)
	self.m_BgSpr = self:NewUI(2, CWidget)
	self.m_GuideTipsBg = self:NewUI(3, CSprite, false)
	
	self.m_BoxList = {}
	self.m_ActBox = nil --当前行动box
	self.m_AvatarBoxClone:SetActive(false)
	-- local height = self.m_AvatarBoxClone:GetHeight()
	local height = 48
	self.m_BoxHeight = height
	self.m_MaxY = self.m_BgSpr:GetHeight() - height - 5
	self.m_MinY = -height*1.5-20
	-- self.m_MaxStep = height / (self.m_BgSpr:GetHeight() -height) + 0.01
	self.m_Factor = 1
	self.m_ShiftSequence = 0
	self.m_ShiftTargetWid = nil
	self.m_IsAlly = nil
	self.m_MaxOffset = 20
	if self.m_GuideTipsBg then
		g_GuideCtrl:AddGuideUI("war_speed_tips_bg", self.m_GuideTipsBg)
	end
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID() ,callback(self, "OnCtrlEvent"))
	self:RefreshSpeedList()
end

function CWarSpeedControlBox.SetAlly(self, bAlly)
	self.m_IsAlly = bAlly
	self:RefreshSpeedList()
end

function CWarSpeedControlBox.SetFactor(self, i)
	self.m_Factor = i
	self:RefreshSpeedList()
end

function CWarSpeedControlBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.CommandStart then
		local wid = oCtrl.m_EventData
		if not self.m_ActBox or self.m_ActBox.m_Wid ~= wid then
			local oWarrior = g_WarCtrl:GetWarrior(wid)
			if oWarrior and oWarrior:IsAlive() and ((not self.m_IsAlly) or self.m_IsAlly == oWarrior:IsAlly()) then
				local oBox = self:GetBoxByWid(wid)
				if oBox and not oBox:IsDone() then
					self:SetShiftTarget(wid)
				end
			else
				self:CommandDone(wid)
			end
		end
	elseif oCtrl.m_EventID == define.War.Event.AliveChange then
		local oBox = self:GetBoxByWid(oCtrl.m_EventData)
		if oBox then
			oBox:CheckColor()
		end
	elseif oCtrl.m_EventID == define.War.Event.CommandDone then
		-- self:CommandDone(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.War.Event.SpeedChange then
		self:RefreshSpeedList()
	elseif oCtrl.m_EventID == define.War.Event.SectionEnd then
		self:CheckOrderEffect()
	elseif oCtrl.m_EventID == define.War.Event.SectionStart then
		self:CheckOrderEffect()
		if g_WarOrderCtrl.m_CurOrderWid then
			self:SetShiftTarget(g_WarOrderCtrl.m_CurOrderWid)
		end
	end
end

function CWarSpeedControlBox.GetBoxByWid(self, wid)
	for i, oBox in ipairs(self.m_BoxList) do
		if oBox.m_Wid == wid then
			oBox.m_Idx = i
			return oBox
		end
	end
end

function CWarSpeedControlBox.SetShiftTarget(self, wid)
	self.m_ShiftTargetWid = wid
	if not self.m_IsAniming then
		self:ShiftLeft()
	end
end

function CWarSpeedControlBox.ActShiftDone(self)
	self.m_IsAniming = false
	if not self.m_ShiftTargetWid or (self.m_ActBox and self.m_ShiftTargetWid == self.m_ActBox.m_Wid) then
		if self.m_LastDoneWid then
			if g_WarOrderCtrl:GetOrderWid() ~= self.m_ActBox.m_Wid then
				self:CheckCommandDone(self.m_LastDoneWid)
				self.m_LastDoneWid = nil
			end
			self.m_ActBox:SetShiftDone(true)
		end
	else
		self:ShiftLeft()
	end
end

function CWarSpeedControlBox.NextToActBox(self, iCur)
	local iMoveIdx = 1
	if self.m_ActBox then
		for i, oBox in pairs(self.m_BoxList) do
			if self.m_ActBox == oBox then
				iMoveIdx = i + 1
				break
			end
		end
	end
	if iCur ~= iMoveIdx then
		local oBox = self.m_BoxList[iCur]
		table.remove(self.m_BoxList, iCur)
		table.insert(self.m_BoxList, iMoveIdx, oBox)
		self:ResetDepth()
		self:ResetPos()
	end
end

function CWarSpeedControlBox.Clear(self)
	for i, oBox in pairs(self.m_BoxList) do
		oBox:Destroy()
	end
	self.m_BoxList = {}
	self.m_ActBox = nil
end

function CWarSpeedControlBox.Recycle(self)
	for i, oBox in pairs(self.m_BoxList) do
		DOTween.DOKill(oBox.m_Transform, false)
		oBox:SetWid(nil)
		oBox:SetLocalScale(Vector3.New(1, 1, 1))
		oBox.m_AvatarSpr:SetGrey(false)
		oBox:SetShiftDone(false)
		oBox.m_TypeSpr:SetGrey(false)
		oBox:ClearEffect()
		g_ResCtrl:PutObjectInCache(oBox:GetCacheKey(), oBox, {wid=oBox.m_Wid})
	end
	self.m_BoxList = {}
	self.m_ActBox = nil
	self.m_IsAniming = false
end

function CWarSpeedControlBox.GetAvatarBoxCacheKey(self)
	-- local sKey
	-- if self.m_AvatarBoxClone:GetPivot() ==  enum.UIWidget.Pivot.Left then
	-- 	sKey = "CWarSpeedControlBox.AvatarBoxL"
	-- else
	-- 	sKey = "CWarSpeedControlBox.AvatarBoxR"
	-- end
	return "CWarSpeedControlBox.AvatarBox"
end

function CWarSpeedControlBox.NewBoxByWid(self, wid)
	local iKey = self:GetAvatarBoxCacheKey()
	local oBox = g_ResCtrl:GetObjectFromCache(iKey, {wid=wid})
	if not oBox then
		oBox = self.m_AvatarBoxClone:Clone()
		oBox:SetCacheKey(iKey)
		oBox:SetActive(true)
	end
	oBox:SetLocalScale(Vector3.New(1, 1, 1))
	oBox:SetWid(wid)
	return oBox
end

function CWarSpeedControlBox.CheckOrderEffect(self)
	-- local wid = g_WarOrderCtrl:GetOrderWid()
	-- for i, oBox in ipairs(self.m_BoxList) do
	-- 	if wid and (oBox.m_Wid == wid) then
	-- 		-- oBox:AddEffect("Rect")
	-- 		-- oBox:AddEffect("Rect")
	-- 		oBox:SetState(CWarSpeedAvatarBox.ACT)
	-- 	else
	-- 		-- oBox:DelEffect("Rect")
	-- 	end
	-- end
end

function CWarSpeedControlBox.RefreshSpeedList(self)
	local list = g_WarCtrl:GetWillActWids(self.m_IsAlly)
	if self.m_CurList and table.equal(self.m_CurList, list) then
		-- self:CheckOrderEffect()
		return
	end
	self:Recycle()
	self.m_CurList = list
	-- if g_WarOrderCtrl:IsCanOrder() then
	-- 	--战斗前	
	-- 	g_WarOrderCtrl:UpdateSpeedOrderWids()
	-- 	list = g_WarOrderCtrl.m_SpeedOrderWids
	-- else
	-- 	--战斗中
	-- 	g_WarOrderCtrl:UpdateWaitOrderWids()
		-- list = g_WarCtrl:GetWillActWids(self.m_IsAlly)
	-- end
	for i, info in ipairs(list) do
		local wid = info.wid
		local oBox = self:NewBoxByWid(wid)
		oBox:SetName(tostring(i))
		oBox.m_Idx = i
		oBox:SetParent(self.m_BgSpr.m_Transform)
		if i == 1 then
			g_GuideCtrl:AddGuideUI("war_first_speed_box", oBox)
		elseif i== 2 then
			g_GuideCtrl:AddGuideUI("war_two_speed_box", oBox)
		end
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior and oWarrior:IsActionDone() then
			oBox:SetState(CWarSpeedAvatarBox.DONE)
		end
		table.insert(self.m_BoxList, oBox)
	end
	self:CheckOrderEffect()
	self:ResetPos()
	self:ResetDepth()
end

--把i后面的向左移动, 没有则整体左移动
function CWarSpeedControlBox.ShiftLeft(self)
	local oLastActBox = self.m_ActBox
	local oNextBox
	if oLastActBox then
		local oBox = self.m_BoxList[2]
		if oBox and not oBox:IsDone() then
			oNextBox = oBox
		end
		local i = #self.m_BoxList
		local vEndPos = self.m_BoxList[i]:GetLocalPos()
		if i >= self.OverlayIdx then
			if i == self.OverlayIdx then
				vEndPos.y = vEndPos.y + self.m_MaxOffset
			end
			oLastActBox:SetShowCircle(true)
		else
			if not oBox then
				vEndPos.y = vEndPos.y + self.m_BoxHeight * self.m_Factor
			end
		end
		oLastActBox:SetLocalPos(vEndPos)
		oLastActBox:SetState(CWarSpeedAvatarBox.DONE)
		table.remove(self.m_BoxList, 1)
		table.insert(self.m_BoxList, oLastActBox)
	else
		local oBox = self.m_BoxList[1]
		if oBox and not oBox:IsDone() then
			oNextBox = oBox
		end
	end
	if oNextBox then
		oNextBox:SetState(CWarSpeedAvatarBox.ACT)
	end
	self.m_ActBox = oNextBox
	self:ResetDepth()
	local iAnimTime = 0.7
	self.m_IsAniming = true
	local oPrePos
	local iNotMove = self.OverlayIdx+1
	for i, oBox in ipairs(self.m_BoxList) do
		DOTween.DOComplete(oBox.m_Transform, false)
		if i > iNotMove then
			return
		end
		local pos = oBox:GetLocalPos()
		oBox:SetShowCircle(false)
		if oBox == self.m_ActBox then
			local iScale = 1.32
			local tweenPos = DOTween.DOLocalMoveY(oBox.m_Transform, pos.y-self.m_BoxHeight*iScale*1.17, iAnimTime)
			DOTween.SetEase(tweenPos, enum.DOTween.Ease.OutCirc)
			local tweenScale = DOTween.DOScale(oBox.m_Transform, Vector3.New(iScale,iScale,iScale), iAnimTime)
			DOTween.OnComplete(tweenScale, callback(self, "ActShiftDone"))
		elseif oBox == oLastActBox then
			local iScale = 0.7
			oBox:SetLocalScale(Vector3.New(iScale, iScale, iScale))
			DOTween.DOScale(oBox.m_Transform, Vector3.New(1, 1, 1), iAnimTime)
		else
			if oPrePos then
				local tweenPos = DOTween.DOLocalMoveY(oBox.m_Transform, oPrePos.y, iAnimTime)
				DOTween.SetEase(tweenPos, enum.DOTween.Ease.OutCirc)
			end
		end
		oPrePos = oBox:GetLocalPos()
	end
end

function CWarSpeedControlBox.CheckCommandDone(self, wid)
	if self.m_ActBox and self.m_ActBox.m_Wid == wid then
		local i = #self.m_BoxList
		local pos =  self.m_BoxList[i]:GetLocalPos()
		if i > self.OverlayIdx then
			self.m_ActBox:SetShowCircle(true)
			if i == (self.OverlayIdx+1) then
				pos.y = pos.y +self.m_MaxOffset
			end
			self.m_ActBox:SetLocalPos(pos)
		else
			self.m_ActBox:SetShowCircle(false)
			pos.y = pos.y + self.m_BoxHeight * self.m_Factor
			self.m_ActBox:SetLocalPos(pos)
		end
		self.m_ActBox:SetState(CWarSpeedAvatarBox.DONE)
		-- self.m_ActBox:Refresh()
		table.remove(self.m_BoxList, 1)
		table.insert(self.m_BoxList, self.m_ActBox)
		self.m_ActBox = nil
		self:ResetDepth()
	end
end

function CWarSpeedControlBox.CommandDone(self, wid)
	if self.m_IsAniming then
		self.m_LastDoneWid = wid
		return
	else
		self:CheckCommandDone(wid)
	end
end

function CWarSpeedControlBox.ResetDepth(self)
	local iLen = #self.m_BoxList
	for i = iLen, 1, -1 do
		local oBox = self.m_BoxList[i]
		oBox:SetDepth(i, iLen)
	end
end

function CWarSpeedControlBox.ResetPos(self)
	local iStart, iEnd = 1, #self.m_BoxList
	if self.m_ActBox then
		iStart = 2
	end
	-- local iStep = math.min(1/(iEnd-iStart), self.m_MaxStep)
	-- self.m_BoxHeight = math.min(self.m_BoxHeight,self.m_MaxY / (iEnd-iStart))
	local lastY = 0
	for i, oBox in ipairs(self.m_BoxList) do
		if self.m_ActBox == oBox then
			oBox:SetLocalPos(Vector3.New(0, self.m_MinY, 0))
		else
			local ii = (i-iStart)
			if ii >= self.OverlayIdx then
				oBox:SetShowCircle(true)
				oBox:SetLocalPos(Vector3.New(0, lastY+self.m_MaxOffset, 0))
			else
				oBox:SetShowCircle(false)
				local y = self.m_BoxHeight * ii * self.m_Factor
				lastY = y
				oBox:SetLocalPos(Vector3.New(0, y, 0))
			end
		end
	end
end

function CWarSpeedControlBox.InsertBoxByWid(self, wid)
	local oNewBox = self:NewBoxByWid(wid)
	oNewBox:SetParent(self.m_BgSpr.m_Transform)
	local idx
	for i, oBox in ipairs(self.m_BoxList) do
		-- printc(string.format("new: %d old: %d", oBox.m_Speed, oNewBox.m_Speed))
		if oBox.m_Speed < oNewBox.m_Speed then
			idx = i
		elseif oBox.m_Speed == oNewBox.m_Speed then
			if oBox.m_CampPos < oBox.m_CampPos then
				idx = i
			end
		end
	end
	if not idx then
		idx = next(self.m_BoxList) and #self.m_BoxList or 1
	end
	table.insert(self.m_BoxList, idx, oNewBox)
	self:ResetDepth()
	self:ResetPos()
end

function CWarSpeedControlBox.SpeedChange(self)

end

return CWarSpeedControlBox