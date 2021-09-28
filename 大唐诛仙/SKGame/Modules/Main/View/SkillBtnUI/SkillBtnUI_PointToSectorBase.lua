--指向扇形基础类
SkillBtnUI_PointToSectorBase =BaseClass(SkillBtnUI_AngleRangeBase)
function SkillBtnUI_PointToSectorBase:__init(skillBtn, skill)
	self.type = PreviewType.PointToSector90
end

function SkillBtnUI_PointToSectorBase:OnSkillState()
	SkillBtnUI_AngleRangeBase.OnSkillState(self)
end

--使用技能之前做的处理
function SkillBtnUI_PointToSectorBase:BeforeUseSkill()
	if self:MySkillPreView() == nil then return end
	self:GetPlayer().moveDir = self:MySkillPreView():GetDir()
	self:GetPlayer():ChangeDirByMoveDir()
	SkillBtnUI_AngleRangeBase.BeforeUseSkill(self)
end

--显示预警前处理
function SkillBtnUI_PointToSectorBase:ShowPreViewHandler()
	if self.circleMonList and #self.circleMonList > 0 and not self.circleMonList[1]:IsDie() then
		self:SetOrientation2Target()
	end
end

function SkillBtnUI_PointToSectorBase:SetOrientation2Target()
	if self.circleMonList[1] then
		local mons = self.circleMonList[1]
		local pos = self:GetPlayer():GetPosition()
		local monPos = mons:GetPosition()
		local angle = Mathf.Round(Mathf.AngleCompute(pos.x, pos.z, monPos.x, monPos.z) + 90) - Camera.main.transform.localRotation.eulerAngles.y
		self:MySkillPreView():SetAngle(angle)
	else
		self:MySkillPreView():SetAngle(self:GetPlayer().transform.rotation.eulerAngles.y - Camera.main.transform.localRotation.eulerAngles.y)
	end
end

function SkillBtnUI_PointToSectorBase:OnTouchDownHandler()
	self:SetOrientation2Target()
end

function SkillBtnUI_PointToSectorBase:OnJoystickMoveHandler(context)
	if self:MySkillPreView() == nil then return end
	if not context.data then return end
	local angle = tonumber(context.data)
	if angle >= 360 then
		angle = angle - 360
	end

	self:MySkillPreView():SetAngle(angle)
end

function SkillBtnUI_PointToSectorBase:OnJoystickEndHandler(context)
	self:MySkillPreView():SetAngle(self:GetPlayer().transform.rotation.eulerAngles.y - Camera.main.transform.localRotation.eulerAngles.y)
end

