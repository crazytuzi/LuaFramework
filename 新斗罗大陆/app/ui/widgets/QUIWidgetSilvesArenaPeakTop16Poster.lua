--
-- Kumo.Wang
-- 西尔维斯巅峰赛16强展示Cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSilvesArenaPeakTop16Poster = class("QUIWidgetSilvesArenaPeakTop16Poster", QUIWidget)

local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")

function QUIWidgetSilvesArenaPeakTop16Poster:ctor(options)
	local ccbFile = "ccb/Widget_SilvesArena_Peak_TOP16_Notice.ccbi"
	local callBacks = {
		}
	QUIWidgetSilvesArenaPeakTop16Poster.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetSilvesArenaPeakTop16Poster:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSilvesArenaPeakTop16Poster:setInfo(info)
	if not info then return end    
    self._info = info

    self._ccbOwner.tf_team_name:setString(info.teamName)

    self._ccbOwner.tf_force_title:setString("均战：")
    local isMe = remote.silvesArena.myTeamInfo and info.teamId == remote.silvesArena.myTeamInfo.teamId
    local totalForce, totalNumber = remote.silvesArena:getTotalForceAndTotalNumberByTeamInfo(info, isMe)
    if totalForce and totalNumber then
        local num, unit = q.convertLargerNumber(totalForce/totalNumber)
        self._ccbOwner.tf_team_force:setString( num..(unit or "") )
    else
        self._ccbOwner.tf_team_force:setString(0)
    end

    local nodes = {self._ccbOwner.tf_force_title, self._ccbOwner.tf_team_force}
    q.autoLayerNode(nodes, "x", 5) 

    if not q.isEmpty(info.leader) then
        self._ccbOwner.node_head_1:removeAllChildren()
        local head = QUIWidgetAvatar.new()
        self._ccbOwner.node_head_1:addChild(head)
        head:setInfo(info.leader.avatar)
        head:setSilvesArenaPeak(info.leader.championCount)
    end

    if not q.isEmpty(info.member1) then
         self._ccbOwner.node_head_2:removeAllChildren()
        local head = QUIWidgetAvatar.new()
        self._ccbOwner.node_head_2:addChild(head)
        head:setInfo(info.member1.avatar)
        head:setSilvesArenaPeak(info.member1.championCount)
    end

    if not q.isEmpty(info.member2) then
        self._ccbOwner.node_head_3:removeAllChildren()
        local head = QUIWidgetAvatar.new()
        self._ccbOwner.node_head_3:addChild(head)
        head:setInfo(info.member2.avatar)
        head:setSilvesArenaPeak(info.member2.championCount)
    end

    self._ccbOwner.sp_first:setVisible(false)
    self._ccbOwner.sp_second:setVisible(false)
    self._ccbOwner.sp_third:setVisible(false)
    self._ccbOwner.tf_other:setVisible(false)
    if info.teamRank then
        if info.teamRank == 1 then
            self._ccbOwner.sp_first:setVisible(true)
        elseif info.teamRank == 2 then
            self._ccbOwner.sp_second:setVisible(true)
        elseif info.teamRank == 3 then
            self._ccbOwner.sp_third:setVisible(true)
        else
            self._ccbOwner.tf_other:setString(info.teamRank)
            self._ccbOwner.tf_other:setVisible(true)
        end
    else
        self._ccbOwner.tf_other:setString(0)
        self._ccbOwner.tf_other:setVisible(true)
    end
end

return QUIWidgetSilvesArenaPeakTop16Poster