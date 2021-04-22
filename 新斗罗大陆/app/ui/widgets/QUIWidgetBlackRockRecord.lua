-- @Author: liaoxianbo
-- @Date:   2019-10-31 20:14:21
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-10-31 20:28:13
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetBlackRockRecord = class("QUIWidgetBlackRockRecord", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetBlackRockRecord:ctor(options)
	local ccbFile = "ccb/Widget_Black_mountain_jiangli.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
    }
    QUIWidgetBlackRockRecord.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

-- data is message BlackRockTeamFightReportmessage BlackRockTeamFightReport
-- optional int32 chapterId = 1;                                               // 邀请的队伍所在的章节
-- optional bool success = 2;                                                  // 是否通关
-- optional int32 starCnt = 3;                                                 // 对应星级
-- optional int64 happenedAt = 4;                                              // 交战时间
-- optional string progressId = 5;                                             // 战斗进度ID
function QUIWidgetBlackRockRecord:setInfo(data)
    -- isWin
    self._subData = data
    self._ccbOwner.sprite_win:setVisible(not not data.success)
    self._ccbOwner.sprite_lose:setVisible(not data.success)
    -- date & time
    -- q.date("%Y-%m-%dT%H:%M:%SZ")
    self._ccbOwner.label_date:setString(tostring(q.date("%m-%d", data.happenedAt / 1000)))
    self._ccbOwner.label_time:setString(tostring(q.date("%H:%M", data.happenedAt / 1000)))
    -- dungeon name
    self._ccbOwner.label_dungeon:setString(tostring(remote.blackrock:getChapterById(data.chapterId)[1].name))
    -- scoreList
    local star = data.starCnt
    self._ccbOwner.sprite_star_on_1:setVisible(star >= 1)
    -- owner.sprite_star_off_1:setVisible(star < 1)
    self._ccbOwner.sprite_star_on_2:setVisible(star >= 2)
    -- owner.sprite_star_off_2:setVisible(star < 2)
    self._ccbOwner.sprite_star_on_3:setVisible(star >= 3)
    -- owner.sprite_star_off_3:setVisible(star < 3)
end

function QUIWidgetBlackRockRecord:_onTriggerInfo( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_info) == false then return end
    remote.blackrock:blackRockGetMemberFightReportList(self._subData.progressId, function(data)
            if self:safeCheck() then
                local list = data.blackRockGetMemberFightReportListResponse.blackRockMemberFightReports
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockRecordDetail",
                    options = {data = self._subData, list = list or {}}})
            end
        end)
end
function QUIWidgetBlackRockRecord:onEnter()
end

function QUIWidgetBlackRockRecord:onExit()
end

function QUIWidgetBlackRockRecord:getContentSize()
	 return CCSizeMake(664, 110)
end

return QUIWidgetBlackRockRecord
