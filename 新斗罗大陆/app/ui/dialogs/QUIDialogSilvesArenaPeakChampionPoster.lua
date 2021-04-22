--
-- Kumo.Wang
-- 西尔维斯巅峰赛冠军展示
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilvesArenaPeakChampionPoster = class("QUIDialogSilvesArenaPeakChampionPoster", QUIDialog)

local QRichText = import("...utils.QRichText") 

local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")

function QUIDialogSilvesArenaPeakChampionPoster:ctor(options)
	local ccbFile = "ccb/Dialog_SilvesArena_Peak_Champion.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
	QUIDialogSilvesArenaPeakChampionPoster.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true --是否动画显示

    if options then
        self._callback = options.callback
    end
    
    self:_reset()

    if q.isEmpty(remote.silvesArena.peakTeamInfo) then
        return
    end

    local championTeamInfo = {}
    for _, teamInfo in ipairs(remote.silvesArena.peakTeamInfo) do
        if teamInfo.currRound >= 5 then
            championTeamInfo = teamInfo
            break
        end
    end
	local rt = QRichText.new()
    local tfTbl = {}
    table.insert(tfTbl, {oType = "font", content = "恭喜玩家小队：", size = 22, color = COLORS.a})
    table.insert(tfTbl, {oType = "font", content = championTeamInfo.teamName or "", size = 22, color = COLORS.b})
    table.insert(tfTbl, {oType = "font", content = "获得西尔维斯巅峰赛的冠军", size = 22, color = COLORS.a})
    rt:setString(tfTbl)
    rt:setAnchorPoint(ccp(0.5, 0.5))
    self._ccbOwner.node_rtf:addChild(rt)

    if not q.isEmpty(championTeamInfo.leader) then
        local player = championTeamInfo.leader
        local avatar = QUIWidgetActorDisplay.new( player.defaultActorId, {heroInfo = {skinId = player.defaultSkinId}} )
        self._ccbOwner.node_avatar_1:addChild(avatar)
    end

    if not q.isEmpty(championTeamInfo.member1) then
        local player = championTeamInfo.member1
        local avatar = QUIWidgetActorDisplay.new( player.defaultActorId, {heroInfo = {skinId = player.defaultSkinId}} )
        self._ccbOwner.node_avatar_2:addChild(avatar)
    end

    if not q.isEmpty(championTeamInfo.member2) then
        local player = championTeamInfo.member2
        local avatar = QUIWidgetActorDisplay.new( player.defaultActorId, {heroInfo = {skinId = player.defaultSkinId}} )
        self._ccbOwner.node_avatar_3:addChild(avatar)
    end

    self._ccbOwner.tf_team_name:setString(championTeamInfo.teamName or "")
    self._ccbOwner.tf_team_name:setVisible(true)
end

function QUIDialogSilvesArenaPeakChampionPoster:_reset()
    self._ccbOwner.tf_team_name:setVisible(false)
    self._ccbOwner.node_avatar_1:removeAllChildren()
    self._ccbOwner.node_avatar_2:removeAllChildren()
    self._ccbOwner.node_avatar_3:removeAllChildren()
    self._ccbOwner.node_rtf:removeAllChildren()
end

function QUIDialogSilvesArenaPeakChampionPoster:viewDidAppear()
    QUIDialogSilvesArenaPeakChampionPoster.super.viewDidAppear(self)
end

function QUIDialogSilvesArenaPeakChampionPoster:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogSilvesArenaPeakChampionPoster:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilvesArenaPeakChampionPoster:viewAnimationOutHandler()
    local callback = self._callback

    self:popSelf()

    if callback then
        callback()
    end
end

return QUIDialogSilvesArenaPeakChampionPoster