--指向扇形90°
SpPointToRangeSector60 =BaseClass(SpPointToRangeSectorBase)
function SpPointToRangeSector60:__init( player, skillVo )
	self.aimBlueType = "aim_blue_2"
	self._dirEffect = "SpPointToRangeSector60_"..self._skillVo.un32SkillID
end
