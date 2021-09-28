--基础
SkillBtnUI_Base =BaseClass()


SkillBtnUI_Base.QuickAttackTarget = nil --快速点击目标
SkillBtnUI_Base.SkillPhaseCheck = false --技能阶段状态开启
SkillBtnUI_Base.CurTriggerSkillBtn = nil

function SkillBtnUI_Base:__init(skillBtn, skill)
	self.type = PreviewType.Nothing
	self._skillBtn = skillBtn
	self._skill = skill
	self._skillId = self._skill:GetSkillVo().un32SkillID

	self._player = SceneController:GetInstance():GetScene():GetMainPlayer()
	self._skillManager = self._player.skillManager
	self.scene = SceneController:GetInstance():GetScene()

	self.joystickUi = CustomJoystick.skillJoystick
	self.joystickUi:ResetRes( "Icon/Skill/001", "Icon/Skill/002" )

	self._isNeedActivateEffect = false
	self._noUseCD = false
	self._cdPoint = nil
	self._cdText = nil
	self._cdMaxTime = self._skill:GetSkillVo().n32CoolDown *0.001
	self._skillTime = 0
	self._cdLeftTime = 0

	self._mask = nil
	self._isDown = false
	self._centerPot = nil
	self._centerRadius = 0
	self._lock = nil
	self._canUseLock = nil
	self._canUseLock2 = nil
	self.IsCommonLock = false

	self.role3D = nil
	self.nbSkillRole3D = nil
	self.nbSkillEft = nil
	self.nbSkillEftId = 4600

	self._lastAutoAttackTime = 0
	self._autoAttackInterval = 0.2

	self.touchId = -1
	self.touchDownPos = nil
	self.touchDownTime = 0
	self.triggerOffset = 2 --触发最小向量偏移(即长按后，必须达到最小向量偏移才可以触发技能),暂定2个像素
	self.longTouchLeastTime = 0.5 --最小长按时间
	self.isLongTouchChecking = false --是否长按检测中
	self.isLongTouch = false --是否为长按

	self.isCancelChecking = false

	self.magicState = 2 --施法状态 1:施法 2:取消施法

	self.usejoystickEvent = false
	self.startCheck = false --是否开始检测快速点击
	self.curUseSkilId = -1 --当前触发的技能Id(释放连招时，self.curUseSkilId一直在变)
	self.btnPlayEftId = 0
	self.IsPlayingQuickSkill = false --是否正在播放快速点击触发的技能

	self.isLock = false --是否处于锁定状态(未学习)

	self:Init()
	self:AddEvent()
	self:RecoverCd()
end

function SkillBtnUI_Base:__delete()
	self.joystickUi:SetVisible(false)
	self:RemoveEvent()
	self:RemoveNBSkillEft()

	self._skillBtn = nil
	self._skill = nil
	self._player = nil
	self._skillManager = nil
	self.scene = nil
	self.joystickUi = nil
	self._cdPoint = nil
	self._cdText = nil
	self._mask = nil
	self._centerPot = nil
	self._lock = nil
	self._canUseLock = nil
	self._canUseLock2 = nil
	self.role3D = nil
	self.nbSkillRole3D = nil
	self.nbSkillEft = nil
	self.touchDownPos = nil
end

function SkillBtnUI_Base:Init()
	self._skillBtn.icon = "Icon/Skill/"..self._skill:GetSkillVo().iconID
	self._lock = self._skillBtn:GetChild("lock")
	self._canUseLock2 =  self._skillBtn:GetChild("cantUse2")
	self._canUseLock2.visible = false
	if self._skill:GetSkillVo().bIfNomalAttack == 1 then --普攻
		self._noUseCD = true
		self.btnPlayEftId = "90001"
	else 
		--暂时屏蔽公共Cd,优化再去掉相关代码
		self._canUseLock =  self._skillBtn:GetChild("cantUse")
		self._canUseLock.visible = false

		self._mask = self._skillBtn:GetChild("mask")
		self.btnPlayEftId = "90002"

		self.nbSkillRole3D = self._skillBtn:GetChild("nBrole3D")
	end
	self.role3D = self._skillBtn:GetChild("role3D")

	self._cdText = self._skillBtn:GetChild("cdTxt")
	self._cdText.text = ""

	self._cdPoint = self._skillBtn:GetChild("cdPoint") ~= nil and self._skillBtn:GetChild("cdPoint") or nil
	if self._cdPoint then
		self._cdPoint.visible = false
		self._centerPot = Vector2.New(self._skillBtn.width*0.5, self._skillBtn.height*0.5)
		self._centerRadius = self._skillBtn.width*0.5
	end

	self.joystickUi:SetTouchTarget(self:GetSkillBtn())

	self:CheckUseState()
	self:AddNBSkillEft()
end

function SkillBtnUI_Base:AddEvent()
	self._skillBtn.onTouchBegin:Add(SkillBtnUI_Base.OnDown, self)
	self._skillBtn.onTouchEnd:Add(SkillBtnUI_Base.OnUp, self)

	self.joystickUi.onMove:Add(SkillBtnUI_Base.OnJoystickMove, self)
	self.joystickUi.onEnd:Add(SkillBtnUI_Base.OnJoystickEnd, self)

	self.handler1 = GlobalDispatcher:AddEventListener(EventName.EXECUTE_SKILL, function ( data ) self:ExecuteSkill(data) end)
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.SkillUseBegin, function ( data ) self:OnSkillUseBeginHandler(data) end)
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.SkillUseEnd, function ( data ) self:OnSkillUseEndHandler(data) end)
	self.handler4 = GlobalDispatcher:AddEventListener(EventName.SkillBtnClick, function ( data ) self:OnSkillBtnClickHandler(data) end)
	self.handler5 = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function ( key, value, pre ) self:RefreshPlayerInfo(key, value, pre) end)  --刷新主角信息
end

function SkillBtnUI_Base:RemoveEvent()
	Stage.inst.onTouchMove:Remove(self.onTouchMove)
	Stage.inst.onTouchEnd:Remove(self.onTouchEnd)

	if self._skillBtn ~= nil then
		self._skillBtn.onTouchBegin:Clear()
		self._skillBtn.onTouchEnd:Clear()
		-- self._skillBtn.onTouchBegin:Remove(SkillBtnUI_Base.OnDown, self)
		-- self._skillBtn.onTouchEnd:Remove(SkillBtnUI_Base.OnUp, self)
	end

	self.joystickUi.onMove:Remove(SkillBtnUI_Base.OnJoystickMove, self)
	self.joystickUi.onEnd:Remove(SkillBtnUI_Base.OnJoystickEnd, self)

	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	GlobalDispatcher:RemoveEventListener(self.handler5)
end

function SkillBtnUI_Base:AddNBSkillEft()
	if SkillModel:GetInstance():IsMWSkill(self._skillId) and self.nbSkillRole3D then
		self:RemoveNBSkillEft()
		EffectMgr.AddToUI(self.nbSkillEftId, self.nbSkillRole3D, nil, nil, nil, nil, nil, function(effect)
			effect.transform.localScale = Vector3.New(80, 80, 80)
			self.nbSkillEft = effect

		end)
	else
		self:RemoveNBSkillEft()
	end
end

function SkillBtnUI_Base:RemoveNBSkillEft()
	if self.nbSkillEft then 
		destroyImmediate(self.nbSkillEft.gameObject) 
	end
end

function SkillBtnUI_Base:RefreshPlayerInfo()
	if self.isLock then return end
	self:CheckUseState()
end

function SkillBtnUI_Base:CheckUseState()
	local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
	if not self.isLock and self._skill and self._skill:GetSkillVo() and mainPlayer then
		if mainPlayer.mp < self._skill:GetSkillVo().n32UseMP then
			if self._canUseLock then
				self._canUseLock.visible = true
			end
		else
			if self._canUseLock then
				self._canUseLock.visible = false
			end
		end
	end
end 

--锁定(未学习)
function SkillBtnUI_Base:Lock()
	if not self._canUseLock then return end
	self._lock.visible = true
	self._canUseLock.visible = false
	if self._mask then
		self._mask.fillAmount = 1
	end
	self.isLock = true
end	

--解除锁定(已学习)
function SkillBtnUI_Base:UnLock()
	self._lock.visible = false
	if self._mask then
		self._mask.fillAmount = 0
	end
	self.isLock = false
end	

--恢复Cd
function SkillBtnUI_Base:RecoverCd()
	self._cdLeftTime = BtnSkillView.GetRunningCd(self._skillId)
end

function SkillBtnUI_Base:OnJoystickMove(context)
	if self.isLock then return end
	if not self.usejoystickEvent then return end
	self:OnJoystickMoveHandler(context)
end

function SkillBtnUI_Base:OnJoystickEnd(context)
	if self.isLock then return end
	if not self.usejoystickEvent then return end
	self:OnJoystickEndHandler(context)
end

function SkillBtnUI_Base:OnTouchDownHandler()

end

function SkillBtnUI_Base:OnJoystickMoveHandler(context)

end

function SkillBtnUI_Base:OnJoystickEndHandler(context)

end

function SkillBtnUI_Base:MySkillPreView()
	return nil
end

--开始使用技能
function SkillBtnUI_Base:OnSkillUseBeginHandler(skillId)
	if self.isLock then return end
	if self._skill and skillId ~= self._skill:GetSkillVo().un32SkillID then
		self.IsCommonLock = true
	end
end

--技能结束
function SkillBtnUI_Base:OnSkillUseEndHandler(skillId)
	if self.isLock then return end
	self.IsCommonLock = false

	if skillId == self.curUseSkilId then
		if SkillBtnUI_Base.CurTriggerSkillBtn and SkillBtnUI_Base.CurTriggerSkillBtn._skillId == self._skillId then
			SkillBtnUI_Base.CurTriggerSkillBtn = nil
		end

		self.curUseSkilId = -1
		self.IsPlayingQuickSkill = false
		if SkillBtnUI_Base.QuickAttackTarget == self then
		   SkillBtnUI_Base.QuickAttackTarget = nil
		   self.IsPlayingQuickSkill = true
		   if GameConst.ViewType == 1 then EffectMgr.AddToUI(self.btnPlayEftId, self.role3D, 0.3) end
		   self:UseSkill()
		end
	end
end

function SkillBtnUI_Base:OnSkillBtnClickHandler(data)
	if self.isLock then return end
	if data ~= self then
		self:CancleCheck()
	end
end

--取消连招流程锁定
function SkillBtnUI_Base:CancleCheck()	
	if self._skillManager == nil then return end
	self.startCheck = false
	SkillBtnUI_Base.QuickAttackTarget = nil
	self.IsPlayingQuickSkill = false
	self._skillManager:ComboIndexReset(self._skillId) --连击索引重置
end

--技能按键状态重置
function SkillBtnUI_Base:Reset()
	self:CancleCheck()
end

--按下
function SkillBtnUI_Base:OnDown(context)
	if self.isLock then return end
	GlobalDispatcher:DispatchEvent(EventName.SkillBtnClick, self)
	SceneController:GetInstance():GetScene():StopAutoFight(true)
	if self.isLock then 
		return 
	end
	if SkillBtnUI_Base.QuickAttackTarget then 
		return 
	end
	if self.IsPlayingQuickSkill then 
		return 
	end
	if self.startCheck then
		self.startCheck = false
		if not SkillBtnUI_Base.QuickAttackTarget then
			SkillBtnUI_Base.QuickAttackTarget = self --当前按钮为快速点击对象
		end
	end
	if self:IsCDing() then return end
	if SkillBtnUI_Base.CurTriggerSkillBtn then
		SkillBtnUI_Base.CurTriggerSkillBtn:CancelSkill()
	end
	SkillBtnUI_Base.CurTriggerSkillBtn = self
	GlobalDispatcher:DispatchEvent(EventName.Player_AutoRunEnd)
	GlobalDispatcher:DispatchEvent(EventName.Player_StopWorldNavigation)
	GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity) -- 停止回城动作
	if self._player and self._player:IsLock() then return end
	self._isDown = true
	self.isLongTouch = false
	if self._skill and self._skill:GetSkillVo() and self._skill:GetSkillVo().bIfNomalAttack == 1 then --普攻
		self.magicState = 1
		self:TriggerUseSkill() --释放
		self._lastAutoAttackTime = Time.time --长按自动释放
	else --非普攻
		if self.touchId == -1 then
			local evt = context.data
			self.touchId = evt.touchId
			Stage.inst.onTouchMove:Add(function ()self:onTouchMove(context) end)
			Stage.inst.onTouchEnd:Add(function ()self:onTouchEnd(context) end)

			self.touchDownPos = Vector2.New(evt.x, evt.y)
			self.isLongTouchChecking = true
			self.isCancelChecking = true
			self.touchDownTime = Time.time
			self.magicState = 1
			self:OnSkillState() --弹起释放
		end
	end
end

function SkillBtnUI_Base:CancelSkill()
	self._isDown = false
	self.magicState = 2
end

function SkillBtnUI_Base:onTouchMove(context)
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId and self.touchDownPos then
		if Vector2.Distance(self.touchDownPos, Vector2.New(evt.x, evt.y)) > self.triggerOffset then
			self.isCancelChecking = false --触发释放，取消长按检测
			self.magicState = 1
		end
	end
end

function SkillBtnUI_Base:onTouchEnd(context)	
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		self.touchId = -1
		Stage.inst.onTouchMove:Remove(self.onTouchMove)
		Stage.inst.onTouchEnd:Remove(self.onTouchEnd)
		self.touchDownPos = nil
	end
end

--弹起
function SkillBtnUI_Base:OnUp()		 
	if self.isLock then return end
	if self._isDown then
		self._isDown = false
		if self._skill and self._skill:GetSkillVo() and self.type ~= PreviewType.Nothing and self._skill:GetSkillVo().bIfNomalAttack ~= 1 then
			self:OnSkillState()
		end
	end
end

--普通技能按下释放技能  特殊技能子类重写弹起释放技能
function SkillBtnUI_Base:OnSkillState()
	if self._isDown then
		if self:IsCDing() or self.IsCommonLock then return end
		self:TriggerUseSkill()
	end
end

--释放技能
function SkillBtnUI_Base:TriggerUseSkill()
	if self.magicState == 1 then
		self:UseSkill()
	end
end

--普攻长按自动释放检测
function SkillBtnUI_Base:AutoAttackCheck()
	local dt = Time.time
	if not self._isDown or dt - self._lastAutoAttackTime < self._autoAttackInterval 
		or self:IsCDing() or self._player:IsLock() 
		or not self._skill:GetSkillVo() or self._skill:GetSkillVo().bIfNomalAttack ~= 1 then return end
		self._lastAutoAttackTime = dt
		SkillBtnUI_Base.QuickAttackTarget = self
		self:TriggerUseSkill()
end

--使用技能
function SkillBtnUI_Base:UseSkill(dirs, isAiControl)
	if self._skillManager == nil then return end
	local scene = SceneController:GetInstance():GetScene()
	self._player = scene:GetMainPlayer()
	self.scene = scene

	if scene.monList then
		for i = 1, #scene.monList do
			local mon = scene.monList[i]
			if mon.beHitEffect then
				EffectTool.RemoveEffect(mon.beHitEffect, true)
				mon.beHitEffect = nil
			end
		end
	end
	if self._cdLeftTime > 0 or self.IsCommonLock then 
		self:CancleCheck()
		return 
	end
	self._player:RestoreInput()

	local info = {}
	local skill = nil
	local comboData = self._skillManager:IndexComboId(self._skillId) --连击数据
	if comboData then
		skill = comboData[1]
	else
		skill = self._skill
	end

	if skill == nil then
		logWarn(StringFormat("技能[{0}]数据为空", self._skillId))
		self:CancleCheck()
		return 
	end

	local skillVo = skill:GetSkillVo()
	local oldMp = self._player.vo.mp
	local newMp = oldMp - skillVo.n32UseMP
	if newMp < 0 then
		Message:GetInstance():TipsMsg("魔法不足")
		self:CancleCheck()
		return 
	else
		self._player.vo:SetValue("mp", newMp, oldMp)
	end

	local quickDelay = skillVo.keyInAdvance*0.001 --多少时间后开始检测快速点击
	local quickCheckTime = 0
	local skillTime = skillVo.n32SkillLastTime*0.001
	if comboData then
		quickCheckTime = comboData[2]*0.001 --连击判定时间
	else
		quickCheckTime = skillTime - quickDelay
	end

	self.startCheck = false
	SkillBtnUI_Base.QuickAttackTarget = nil
	DelayCall(function() 
		if SkillBtnUI_Base.QuickAttackTarget then return end
		self.checkTime = quickCheckTime --检测时长
		self.startCheck = true
	end, quickDelay)


	info.skillVo = skillVo
	info.isAiControl = isAiControl
	info.type = self.type
	info.dirAngle =  MapUtil.NoDirMark --方向角度
	info.canAutoAim = true --是否可自动瞄准
	local pre = self:MySkillPreView()
	if pre and pre:GetDir() and not isAiControl then --指向性技能
		info.canAutoAim = false
		info.dirAngle = dirs or pre:GetDir()
		info.monster = self.monsterList and #self.monsterList > 0 and self.monsterList[1] or nil or nil
	end
	info.targetPoint = nil
	if pre and pre:GetTargetPoint() then
		info.targetPoint = pre:GetTargetPoint()
	end

	self._cdMaxTime = skillVo.n32CoolDown *0.001
	self._cdLeftTime = skillVo.n32CoolDown *0.001
	self.curUseSkilId = skillVo.un32SkillID
	self._skillTime = skillVo.n32SkillLastTime *0.001

	if GameConst.ViewType == 1 then EffectMgr.AddToUI(self.btnPlayEftId, self.role3D, 0.3) end
	GlobalDispatcher:DispatchEvent(EventName.GOTOFIGHT, info)
end

--重置技能摇杆
function SkillBtnUI_Base:ResetSkillJoystick(bol)
	self.joystickUi:SetVisible(bol)
	self.joystickUi:SetSkillJoystickPos(self:GetSkillBtn())
end

-- 执行技能
function SkillBtnUI_Base:ExecuteSkill(fightVo)
	if self._skillManager == nil then return end
	if self.isLock then return end
	if not (fightVo and self._skill:GetSkillVo()) then return end
	if fightVo.fightType ~= self._skill:GetSkillVo().un32SkillID then return end
	self._skillManager:UseSkillByFightVo(fightVo)
end

function SkillBtnUI_Base:IsNormalSkill()
	if self._skill and (not TableIsEmpty(self._skill:GetSkillVo())) then
		return self._skill:GetSkillVo().bIfNomalAttack == 1
	else
		return false
	end
	
end

function SkillBtnUI_Base:IsCDing()
	return self._cdLeftTime > 0
end

function SkillBtnUI_Base:GetLeftCD()
	return self._cdLeftTime
end

function SkillBtnUI_Base:GetSkillTIme()
	return self._skillTime
end

function SkillBtnUI_Base:GetMpCost()
	if not self._skill then return 0 end
	return self._skill:GetSkillVo().n32UseMP
end

function SkillBtnUI_Base:_update()
	if self._skillManager == nil then return end
	if self.isLock then return end
	local dt =  Time.deltaTime
	local tt = Time.time
	if self.startCheck then
		self.checkTime = self.checkTime - dt
		if self.checkTime <= 0 then
			self._skillManager:ComboIndexReset(self._skillId) --连击索引重置
			self.startCheck = false
		end
	end

	--长按检测
	if self.isLongTouchChecking and tt - self.touchDownTime > self.longTouchLeastTime then 
		self.isLongTouch = true
		self.isLongTouchChecking = false
	end

	--取消施法检测(默认长按取消施法, 移动摇杆可以继续施法)
	if self.isCancelChecking and tt - self.touchDownTime > self.longTouchLeastTime then
		self.magicState = 2
		self.isCancelChecking = false
	end

	--自动攻击检测
	self:AutoAttackCheck()

	if self._noUseCD then return end
	if self._skill == nil or not self._mask then return end
	if self._cdLeftTime > 0 then
		self._mask.fillAmount = self._cdLeftTime / self._cdMaxTime
		if self._cdPoint then
			if not self._cdPoint.visible then
				self._cdPoint.visible = true
			end
			
			local angel = tonumber(string.format("%0.2f", self._mask.fillAmount*GameConst.PI2 + math.pi))
			self._cdPoint.x = self._centerPot.x + tonumber(string.format("%0.2f", math.sin(angel)*self._centerRadius)) - 10
			self._cdPoint.y = self._centerPot.y + tonumber(string.format("%0.2f", math.cos(angel)*self._centerRadius)) - 10

			self._cdText.text =  math.ceil(self._cdLeftTime)
			self._isNeedActivateEffect = true
		end

		self._cdLeftTime = self._cdLeftTime - dt
		BtnSkillView.RecordRunningCd(self._skillId, self._cdLeftTime)

	elseif self._mask.fillAmount ~= 0 then
		self._mask.fillAmount = 0
		if self._cdPoint then
			if self._cdPoint.visible then
				self._cdPoint.visible = false
				self._cdText.text = ""
				if self._isNeedActivateEffect  then
					self._isNeedActivateEffect = false
					 if GameConst.ViewType == 1 then EffectMgr.AddToUI("90000", self.role3D, 0.3) end	--技能激活
				end
			end
		end
	end
end

function SkillBtnUI_Base:Skill()
	return self._skill
end

function SkillBtnUI_Base:IsDown()
	return self._isDown
end
function SkillBtnUI_Base:GetPlayer()
	return self._player
end

function SkillBtnUI_Base:GetSkillBtn()
	return self._skillBtn
end

function SkillBtnUI_Base:ShowNewMask(isShow)
	self._canUseLock2.visible = isShow
end