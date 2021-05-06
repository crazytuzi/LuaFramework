local CWarTouchCtrl = class("CWarTouchCtrl")

function CWarTouchCtrl.ctor(self)
	self.m_LayerMask = UnityEngine.LayerMask.GetMask("War")
	self.m_SwipeRange = nil
	self.m_IsLock = false
	self.m_IsPathMove = true
	self.m_LockInfo = nil
	self.m_LastLightWarriorRef = nil
end

function CWarTouchCtrl.InitSwipeRange(self)
	if not self.m_SwipeRange then
		self.m_SwipeRange = {
			min_y = g_CameraCtrl:GetCameraInfo("war", "swipe_vmin").pos.y,
			max_y = g_CameraCtrl:GetCameraInfo("war", "swipe_vmax").pos.y,
		}
	end
end

function CWarTouchCtrl.OnTouchDown(self, touchPos)
	if not g_WarCtrl:IsWar() or CArenaWarStartView:GetView() or CTeamPvpWarStartView:GetView() then
		return
	end
	local oWarrior = self:GetTouchWarrior(touchPos.x, touchPos.y)
	if oWarrior then
		if oWarrior:IsOrderTarget() then
			oWarrior:AddBindObj("light")
			oWarrior:StopDelayCall("DelBindObj")
			self.m_LastLightWarriorRef = weakref(oWarrior)
		end
	end
end

--{[1]=gameobj, [2]=point,...}
function CWarTouchCtrl.OnTouchUp(self, touchPos)
	if not g_WarCtrl:IsWar() or CArenaWarStartView:GetView() or CTeamPvpWarStartView:GetView() then
		return
	end

	--新手引导战斗3 点击任意屏幕
	g_GuideCtrl:War3GuideTouchAnyway()

	--长按的抬起不执行以下
	if self.m_IsLong then
		self.m_IsLong = false
		return
	end

	local oWarrior = self:GetTouchWarrior(touchPos.x, touchPos.y)
	if oWarrior then
		if g_WarCtrl:IsAutoWar() and not oWarrior:IsAlly() then
			if not g_TeamCtrl:IsInTeam() or g_TeamCtrl:IsLeader() then
				local iJiHuo = oWarrior:IsJiHuo() and 0 or 1
				g_AudioCtrl:PlaySound(define.Audio.SoundPath.Btn)
				netwar.C2GSWarTarget(g_WarCtrl:GetWarID(), oWarrior.m_ID, iJiHuo)
			end
		elseif g_WarCtrl:IsReplace() then
			--todo
		elseif oWarrior:IsOrderTarget() then
			g_AudioCtrl:PlaySound(define.Audio.SoundPath.Btn)
			g_WarOrderCtrl:SetTargetID(oWarrior.m_ID)
		elseif oWarrior:IsAlly() and g_WarOrderCtrl:IsWaitOrder(oWarrior.m_ID) then
			-- g_AudioCtrl:PlaySound(define.Audio.SoundPath.Btn)
			-- g_WarOrderCtrl:SetCurOrderWid(oWarrior.m_ID)
		end
	end
	g_GuideCtrl.m_IsJiHuo = true
	local oLightWarrior = getrefobj(self.m_LastLightWarriorRef)
	if oLightWarrior then
		oLightWarrior:DelayCall(0.3, "DelBindObj", "light")
	end
	self.m_LastLightWarriorRef = nil
end

function CWarTouchCtrl.OnLongTabStart(self, touchPos)
	if not g_WarCtrl:IsWar() then
		return
	end
	local oWarrior = self:GetTouchWarrior(touchPos.x, touchPos.y)
	if oWarrior then
		CWarTargetDetailView:ShowView(function(oView)
				oView:SetWarrior(oWarrior)
			end)
	end
	self.m_IsLong = true
end

function CWarTouchCtrl.SetLock(self, bLock)
	local oCam = g_CameraCtrl:GetWarCamera()
	if bLock then
		self.m_LockInfo = {pos=oCam:GetLocalPos(), rotate=oCam:GetLocalEulerAngles()}
	else
		if self.m_LockInfo then
			DOTween.DOKill(oCam.m_Transform, true)
			oCam:SetPos(self.m_LockInfo.pos)
			oCam:SetLocalEulerAngles(self.m_LockInfo.rotate)
			self.m_LockInfo = nil
		end
	end
	self.m_IsLock = bLock
end

function CWarTouchCtrl.IsLock(self)
	if not g_WarCtrl:IsWar() or g_WarCtrl:IsPrepare() or 
		g_WarCtrl:IsReplace() or g_WarCtrl:IsGuideBoss() or
		self.m_IsLock then
		return true
	else
		return false
	end
end

function CWarTouchCtrl.GetTouchWarrior(self, x, y)
	local lTouch = C_api.EasyTouchHandler.SelectMultiple(g_CameraCtrl:GetWarCamera().m_Camera, x, y, self.m_LayerMask)
	if not lTouch or #lTouch == 0 then
		return
	end
	local iCnt = #lTouch / 2
	for i=1, iCnt do
		local go, point = lTouch[i*2-1], lTouch[i*2]
		local oWarrior = g_WarCtrl.m_InstanceID2Warrior[go:GetInstanceID()]
		if oWarrior then
			if oWarrior:GetTouchEnabled() then
				return oWarrior
			else
				printc("不可点击", oWarrior:GetName())
			end
		end
	end
end

function CWarTouchCtrl.SetPathMove(self, b)
	self.m_IsPathMove = b
end

function CWarTouchCtrl.OnSwipe(self, swipePos)
	if self:IsLock() then
		return
	end
	if g_WarCtrl:GetWarType() == define.War.Type.Guide3 and g_WarCtrl.m_ProtoBout <= 2 then
		return
	end

	if self.m_IsPathMove then
		local iVal = g_CameraCtrl:GetAnimatorPercent()
		if iVal then
			iVal = iVal + (-swipePos.x/500)
			g_CameraCtrl:SetAnimatorPercent(iVal)
		end
	else
		local oCam = g_CameraCtrl:GetWarCamera()
		local vPos = DataTools.GetLineupPos("Center")
		local oRoot = g_WarCtrl:GetRoot()
		vPos = oRoot:TransformPoint(vPos)
		if math.abs(swipePos.x) > math.abs(swipePos.y) then
			oCam:RotateAround(vPos, Vector3.up, swipePos.x/5)
		else
			self:InitSwipeRange()
			local oriPos = oCam:GetLocalPos()
			local oriRotation = oCam:GetRotation()
			oCam:RotateAround(vPos, oCam:GetRight(), -swipePos.y/10)
			-- local pos = oCam:GetLocalPos()
			-- if pos.y < self.m_SwipeRange.min_y or pos.y > self.m_SwipeRange.max_y then
			-- 	oCam:SetLocalPos(oriPos)
			-- 	oCam:SetRotation(oriRotation)
			-- end
		end
	end
end

return CWarTouchCtrl