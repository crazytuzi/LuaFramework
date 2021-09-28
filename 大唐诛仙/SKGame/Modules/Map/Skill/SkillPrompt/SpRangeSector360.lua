--范围扇形60°
SpRangeSector360 =BaseClass(SpBase)
function SpRangeSector360:__init( player, skillVo )
	self.aimBlueTypeReplace = "aim_blue_1"
	self.eftRoot.name = "SpRangeSector360"..self._skillVo.un32SkillID
	if not self._player or ToLuaIsNull(self._player.transform) then return end
	self.eftRoot.transform:SetParent(self._player.transform, false)
end
