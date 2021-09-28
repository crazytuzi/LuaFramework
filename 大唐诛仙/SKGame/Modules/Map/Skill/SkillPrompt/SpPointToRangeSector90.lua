--指向扇形90°
SpPointToRangeSector90 =BaseClass(SpPointToRangeSectorBase)
function SpPointToRangeSector90:__init( player, skillVo )
	self.aimBlueType = "aim_blue_3"
	self._dirEffect = "SpPointToRangeSector90_"..self._skillVo.un32SkillID
end
