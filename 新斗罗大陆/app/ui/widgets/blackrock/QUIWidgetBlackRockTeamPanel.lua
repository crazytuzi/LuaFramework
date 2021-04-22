local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetBlackRockTeamPanel = class("QUIWidgetBlackRockTeamPanel", QUIWidget)
local QUIWidgetBlackRockTeamDungeon = import("...widgets.blackrock.QUIWidgetBlackRockTeamDungeon")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIViewController = import("...QUIViewController")

QUIWidgetBlackRockTeamPanel.EVENT_REFRESH = "EVENT_REFRESH"

function QUIWidgetBlackRockTeamPanel:ctor(options)
	local ccbFile = "ccb/Widget_Black_mountain_chuanjian2.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
        {ccbCallbackName = "onTriggerRefresh", callback = handler(self, self._onTriggerRefresh)},
    }
	QUIWidgetBlackRockTeamPanel.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetBlackRockTeamPanel:update()
	for i=1,3 do
		local progressInfo = remote.blackrock:getProgressByPos(i)
		for j=1,3 do
			local contain = self._ccbOwner["node"..i.."_"..j]
			contain:removeAllChildren()
		end
		for index,stepInfo in ipairs(progressInfo.stepInfo) do
			local widget = QUIWidgetBlackRockTeamDungeon.new()
			local contain = self._ccbOwner["node"..i.."_"..index]
			contain:addChild(widget)
			widget:setDungeonId(stepInfo.stepId, stepInfo.isNpc)
		end
	end
	local teamInfo = remote.blackrock:getTeamInfo()
	local chapters = remote.blackrock:getChapterById(teamInfo.chapterId)
	local chapterName = ""
	if chapters ~= nil and #chapters > 0 then
	    chapterName = chapters[1].name or ""
	end
	self._ccbOwner.tf_name:setString(chapterName)

    self._myInfo = remote.blackrock:getMyInfo()
    local config = QStaticDatabase:sharedDatabase():getConfiguration()
    local freeCount = tonumber(config.blackrock_refresh_free.value)
    local refreshToken = tonumber(config.blackrock_token.value)
    local todayRefreshCount = self._myInfo.refreshRivalsCount or 0

    if todayRefreshCount < freeCount then
        self._ccbOwner.tf_token:setString(" 免费")
    elseif todayRefreshCount >= freeCount then
        self._ccbOwner.tf_token:setString(refreshToken)
    end
end

function QUIWidgetBlackRockTeamPanel:setIsLeader(isLeader)
	self._isLeader = isLeader
	self._ccbOwner.node_leader:setVisible(isLeader)
	self._ccbOwner.node_member:setVisible(not isLeader)
	if isLeader then
		self._ccbOwner.node_root:setPositionY(0)
	else
		self._ccbOwner.node_root:setPositionY(-40)
	end
	-- self._ccbOwner.node_refresh:setVisible(self._isLeader)
end

function QUIWidgetBlackRockTeamPanel:_onTriggerHelp( ... )
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBlackRockRule", options = {index = 7}})
end

function QUIWidgetBlackRockTeamPanel:_onTriggerRefresh( ... )
	self:dispatchEvent({name = QUIWidgetBlackRockTeamPanel.EVENT_REFRESH})
end

return QUIWidgetBlackRockTeamPanel