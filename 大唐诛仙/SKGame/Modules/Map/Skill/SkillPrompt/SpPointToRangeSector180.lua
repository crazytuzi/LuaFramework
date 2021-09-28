--指向扇形90°
SpPointToRangeSector180 =BaseClass(SpPointToRangeSectorBase)
function SpPointToRangeSector180:__init( player, skillVo )
	self.aimBlueType = "aim_blue_4"
	self._dirEffect.name = "SpPointToRangeSector180_"..self._skillVo.un32SkillID
end