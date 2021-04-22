--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogReplayInfo = class("QUIDialogReplayInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIWidgetReplayInfo = import("..widgets.QUIWidgetReplayInfo")

function QUIDialogReplayInfo:ctor(options)
 	local ccbFile = "ccb/Dialog_BattleInformationShow.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerReplay", callback = handler(self, QUIDialogReplayInfo._onTriggerReplay)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogReplayInfo._onTriggerClose)},
    }
    QUIDialogReplayInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
 
    self._onTriggerReplayImpl = function ( ... )
        -- body
    end

    -- 宗门信息
    local isUnion = false
    if options.replayType == REPORT_TYPE.DRAGON_WAR then
        isUnion = true
    end
    QReplayUtil:getReplayInfo(options.replayId, function (data)
            if self._closed then return end
            
            self._replayInfo = data
            local hero1 = QUIWidgetReplayInfo.new({heroes = data.fighter1, name = data.team1Name, level = data.team1Level, 
                avatar = data.team1Icon, result = data.result == 1 and 1 or 2, isUnion = isUnion })
            local hero2 = QUIWidgetReplayInfo.new({heroes = data.fighter2, name = data.team2Name, level = data.team2Level, 
                avatar = data.team2Icon, result = data.result == 2 and 1 or 2, isUnion = isUnion, isUnionAvatar = isUnion })

            self._ccbOwner.fighter1:addChild(hero1)
            self._ccbOwner.fighter2:addChild(hero2)

            self._onTriggerReplayImpl = function ( ... )
                app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
                QReplayUtil:downloadReplay(options.replayId, function (replay)
                    QReplayUtil:play(replay)
                end, nil, options.replayType)
            end
        end, nil, options.replayType)
end

function QUIDialogReplayInfo:viewDidAppear()
    QUIDialogReplayInfo.super.viewDidAppear(self)
end

function QUIDialogReplayInfo:viewWillDisappear()
    QUIDialogReplayInfo.super.viewWillDisappear(self)
end

function QUIDialogReplayInfo:_onTriggerReplay(e)
    if e ~= nil then
        app.sound:playSound("common_common")
    end
    self._onTriggerReplayImpl()
end

-- 关闭对话框
function QUIDialogReplayInfo:_onTriggerClose(e)
    if e ~= nil then
        app.sound:playSound("common_cancel")
    end
    self._closed = true
    self:playEffectOut()
end

function QUIDialogReplayInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogReplayInfo:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogReplayInfo