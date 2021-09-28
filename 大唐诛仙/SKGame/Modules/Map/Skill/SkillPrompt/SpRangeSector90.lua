--范围扇形60°
SpRangeSector90 =BaseClass(SpBase)
function SpRangeSector90:__init( player, skillVo )
	self.aimBlueTypeReplace = "aim_blue_3"
	self.eftRoot.name = "SpRangeSector90"..self._skillVo.un32SkillID
end
