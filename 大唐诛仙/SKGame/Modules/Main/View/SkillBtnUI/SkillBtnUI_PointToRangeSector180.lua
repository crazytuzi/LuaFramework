--指向扇形180°
SkillBtnUI_PointToRangeSector180 =BaseClass(SkillBtnUI_PointToSectorBase)
function SkillBtnUI_PointToRangeSector180:__init(skillBtn, skill)
	self.type = PreviewType.PointToRangeSector180
	self.skDir = nil
end
