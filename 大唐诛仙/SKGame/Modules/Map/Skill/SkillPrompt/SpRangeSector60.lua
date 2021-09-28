--范围扇形60°
SpRangeSector60 =BaseClass(SpBase)
function SpRangeSector60:__init( player, skillVo )
	self.aimBlueTypeReplace = "aim_blue_2"
	self.eftRoot.name = "SpRangeSector60"..self._skillVo.un32SkillID
end
