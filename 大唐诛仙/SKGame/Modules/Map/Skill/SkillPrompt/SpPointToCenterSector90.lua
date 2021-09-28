--指向扇形中心线单选(90°)
SpPointToCenterSector90 =BaseClass(SpPointToRangeSectorBase)
function SpPointToCenterSector90:__init( player, skillVo )
	self.aimBlueType = "aim_blue_3"
	self._dirEffect.name = "SpPointToRangeSector90_"..self._skillVo.un32SkillID
end