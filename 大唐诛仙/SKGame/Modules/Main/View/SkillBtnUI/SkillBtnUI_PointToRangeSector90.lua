--指向扇形90°
SkillBtnUI_PointToRangeSector90 =BaseClass(SkillBtnUI_PointToSectorBase)
function SkillBtnUI_PointToRangeSector90:__init(skillBtn, skill)
	self.type = PreviewType.PointToRangeSector90
	self.skDir = nil
end
