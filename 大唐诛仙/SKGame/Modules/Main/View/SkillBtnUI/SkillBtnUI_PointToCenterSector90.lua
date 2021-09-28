--指向扇形中心线单选(90°)
SkillBtnUI_PointToCenterSector90 =BaseClass(SkillBtnUI_PointToSectorBase)
function SkillBtnUI_PointToCenterSector90:__init(skillBtn, skill)
	self.type = PreviewType.PointToCenterSector90
	self.skDir = nil
end
