--圆(具有施法表现技能的基类)
SkillBtnUI_AngleRangeBase =BaseClass(SkillBtnUI_Base)

function SkillBtnUI_AngleRangeBase:__init(skillBtn, skill)
	self.type = PreviewType.Nothing
	self.sceneCtrl = SceneController:GetInstance()
	-- self.mouseDownTime = 0
	self.circleMonList = {}

	self.needTargetForShortTouch = false --短按触发是否需要有范围目标
end

function SkillBtnUI_AngleRangeBase:SkillPreView()
	if self.sceneCtrl:GetScene().skillPreview then
		return self.sceneCtrl:GetScene().skillPreview
	else
		return nil
	end
end

function SkillBtnUI_AngleRangeBase:MySkillPreView()
	if self:SkillPreView() then
		return self:SkillPreView():GetSkillPre(self._skillId)
	else
		return nil
	end
end

function SkillBtnUI_AngleRangeBase:PreViewShowing()
	if self:SkillPreView() then
		return self:SkillPreView():IsShowing(self._skillId)
	else
		return false
	end
end

function SkillBtnUI_AngleRangeBase:ShowPreView()
	if self:SkillPreView() then
		self:SkillPreView():ShowSkillPre(self._skillId)
	end
end

function SkillBtnUI_AngleRangeBase:HidePreView()
	if self:SkillPreView() then
		self:SkillPreView():HideSkillPre()
	end
end

function SkillBtnUI_AngleRangeBase:ShowPreViewHandler()

end

function SkillBtnUI_AngleRangeBase:CancelSkill()
	SkillBtnUI_Base.CancelSkill(self)
	if self._skill and
	   self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector360 and
	   self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector60 and
	   self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector90 and
	   self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector180 then
		self:ResetSkillJoystick(false)
	end
	self:HidePreView()
	self.usejoystickEvent = false
	self.circleMonList = {}
end

function SkillBtnUI_AngleRangeBase:OnSkillState()
	-- self._player = self.sceneCtrl:GetScene():GetMainPlayer()
	-- self.scene = self.sceneCtrl:GetScene()

	self:AutoSelectTarget()
	if self:IsDown() then --显示技能辅助特效
		-- self.mouseDownTime = Time.time
		if self:IsCDing() then return end
		
		if self._skill:GetSkillVo().previewType == PreviewType.ArrowSmall or self._skill:GetSkillVo().previewType == PreviewType.PointToRangeSector60 or 
		   self._skill:GetSkillVo().previewType == PreviewType.PointToRangeSector90 or self._skill:GetSkillVo().previewType == PreviewType.PointToRangeSector180 or 
		   self._skill:GetSkillVo().previewType == PreviewType.PointToCenterSector90 or self._skill:GetSkillVo().previewType == PreviewType.ArrowBig then
			self.joystickUi.useInner = true --使用摇杆内圈
		else
			self.joystickUi.useInner = false --不使用摇杆内圈
		end
		if self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector360 and
		   self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector60 and
		   self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector90 and
		   self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector180 then
			self:ResetSkillJoystick(true) --显示摇杆
		end
		self:ShowPreViewHandler()
		self:ShowPreView()
		self.usejoystickEvent = true
		self:OnTouchDownHandler()
	else -- 使用技能
		self:TriggerUseSkill()

		if self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector360 and
		   self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector60 and
		   self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector90 and
		   self._skill:GetSkillVo().previewType ~= PreviewType.RangeSector180 then
			self:ResetSkillJoystick(false)
		end
		self:HidePreView()
		self.usejoystickEvent = false
		self.circleMonList = {}
	end
end

--触发使用技能
function SkillBtnUI_AngleRangeBase:TriggerUseSkill()
	if not self.isLongTouch then --1.长按为确认释放逻辑
		if self.needTargetForShortTouch and #self.circleMonList == 0 then --2.短按为判定范围内是否需要目标才能释放逻辑
			Message:GetInstance():TipsMsg(SkillTipsConst.NoAttackTarget)
			return
		end
	end

	if self.magicState == 1 then
		self:BeforeUseSkill()
		self:UseSkill()
	end
	
	if self.scene and self.scene.monList then
		for i = 1, #self.scene.monList do
			local mon = self.scene.monList[i]
			if mon.beHitEffect then
				EffectTool.RemoveEffect(mon.beHitEffect, true)
				mon.beHitEffect = nil
			end
		end
	end
end

function SkillBtnUI_AngleRangeBase:AutoSelectTarget()
	self.circleMonList = {}
	if self._skill then
		local lockKey = BattleManager.FindAttackTarget(self.type, self._skill:GetSkillVo().fReleaseDist / 100)
		if lockKey then
			table.insert(self.circleMonList, lockKey)
		end
	end
end

function SkillBtnUI_AngleRangeBase:BeforeUseSkill()
end

function SkillBtnUI_AngleRangeBase:_update()
	-- self:CreateAttackPromptEffect(10000)
	SkillBtnUI_Base._update(self)
end

function SkillBtnUI_AngleRangeBase:Release()
	self:ResetSkillJoystick(false)
	SkillBtnUI_Base.Release(self)
end
