--范围扇形180°
SpRangeSector180 =BaseClass(SpBase)
function SpRangeSector180:__init( player, skillVo )
	self.aimBlueTypeReplace = "aim_blue_4"
	self.eftRoot.name = "SpRangeSector180"..self._skillVo.un32SkillID
end
