
local QBattleDialog = import(".QBattleDialog")
local QBattleDialogMissions = class("QBattleDialogMissions", QBattleDialog)

local QUserData = import("...utils.QUserData")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBattleDialogMissions:ctor(isPassedMissions, owner, options)
	self._isPassedMissions = isPassedMissions
	if self._isPassedMissions == nil then
		self._isPassedMissions = false
	end

	local ccbFile = "Battle_AchieveStar.ccbi"
	if owner == nil then
		owner = {}
	end

	QBattleDialogMissions.super.ctor(self, ccbFile, owner)

	local dungeonConfig = app.battle:getDungeonConfig()
    self._dungeonTargetInfo = QStaticDatabase.sharedDatabase():getDungeonTargetByID(dungeonConfig.id)
	assert(self._dungeonTargetInfo ~= nil, "dungeon target infomation with dungeon id:" .. tostring(dungeonConfig.id) .. " is not exist!")

	self:_setBattleMissionInfo(1)
	self:_setBattleMissionInfo(2)
	self:_setBattleMissionInfo(3)

end

function QBattleDialogMissions:_setBattleMissionInfo(index)
	if index == nil or index <= 0 or index > 3 then
		return 
	end

	local missionInfo = self._dungeonTargetInfo[index]
	if missionInfo == nil then
		self._ccbOwner["label_starOn" .. tostring(index)]:setVisible(false)
		self._ccbOwner["label_starOff" .. tostring(index)]:setVisible(false)
		self._ccbOwner["sprite_starOn" .. tostring(index)]:setVisible(false)
		self._ccbOwner["sprite_starOff" .. tostring(index)]:setVisible(false)
		return
	end

	self._ccbOwner["label_starOn" .. tostring(index)]:setString(missionInfo.target_text)
	self._ccbOwner["label_starOff" .. tostring(index)]:setString(missionInfo.target_text)

	if self._isPassedMissions == true or (app.missionTracer ~= nil and app.missionTracer:isMissionComplete(index) == true) then
		self._ccbOwner["sprite_starOn" .. tostring(index)]:setVisible(true)
		self._ccbOwner["sprite_starOff" .. tostring(index)]:setVisible(false)
		self._ccbOwner["label_starOn" .. tostring(index)]:setVisible(true)
		self._ccbOwner["label_starOff" .. tostring(index)]:setVisible(false)
	else
		self._ccbOwner["sprite_starOn" .. tostring(index)]:setVisible(false)
		self._ccbOwner["sprite_starOff" .. tostring(index)]:setVisible(true)
		self._ccbOwner["label_starOn" .. tostring(index)]:setVisible(false)
		self._ccbOwner["label_starOff" .. tostring(index)]:setVisible(true)
	end
end

return QBattleDialogMissions