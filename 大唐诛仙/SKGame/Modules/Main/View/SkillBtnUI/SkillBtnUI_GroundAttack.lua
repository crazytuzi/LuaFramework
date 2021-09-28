--地面施法
SkillBtnUI_GroundAttack =BaseClass(SkillBtnUI_AngleRangeBase)
function SkillBtnUI_GroundAttack:__init(skillBtn, skill)
	self.type = PreviewType.GroundAttack
	self.needTargetForShortTouch = true --短按触发是否需要有范围目标
end

--显示预警前处理
function SkillBtnUI_GroundAttack:ShowPreViewHandler()
end

function SkillBtnUI_GroundAttack:OnSkillState()
	SkillBtnUI_AngleRangeBase.OnSkillState(self)
	
end

--使用技能之前做的处理
function SkillBtnUI_GroundAttack:BeforeUseSkill()
	if self:MySkillPreView() then
		self:GetPlayer():SetDirByTargetRightNow( self:MySkillPreView():GetTargetPoint() )
	end
	SkillBtnUI_AngleRangeBase.BeforeUseSkill(self)
end

function SkillBtnUI_GroundAttack:SetInitTargetPos()
	if self.circleMonList[1] then --智能施法，自动指向目标
		local p =self._player.transform.position
		local p2 = self.circleMonList[1].transform.position
		local direction = (p2 - p):Normalize()
		local distance = Vector3.Distance(p, p2)
		self:MySkillPreView():SetAutoSelect(direction, distance)
	else
		self:MySkillPreView():SetControllPos(Vector2.New(0, 0), 0)
	end
end

function SkillBtnUI_GroundAttack:OnTouchDownHandler()
	self:SetInitTargetPos()
end

function SkillBtnUI_GroundAttack:OnJoystickMoveHandler(context)
	local p= self.joystickUi.posScale
	if p.x ~= 0 and p.y ~= 0 then
		self:MySkillPreView():SetControllPos(p)
	end
end
