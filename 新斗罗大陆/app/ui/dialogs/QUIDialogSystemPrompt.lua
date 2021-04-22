
local QUIDialog = import(".QUIDialog")
local QUIDialogSystemPrompt = class("QUIDialogSystemPrompt", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogSystemPrompt:ctor(options)
    local ccbFile = "ccb/Dialog_SystemPrompt.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSystemPrompt._onTriggerClose)},
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogSystemPrompt._onTriggerConfirm)}
    }
    QUIDialogSystemPrompt.super.ctor(self, ccbFile, callBacks, options)
    
    if options then
        if options.string ~= nil then
            -- 同一错误提示用
            self._string = options.string
            self._ccbOwner.label_line1:setString(options.string)
            self._ccbOwner.label_line2:setVisible(false)
        elseif options.buyFlag ~= nil then
            self._buyFlag = options.buyFlag
            local good = QStaticDatabase:sharedDatabase():getTokenConsume("flag", remote.user.buyFlagCount + 1)
            local str = nil
            if good ~= nil then
                str = string.format("是否花费%d购买%d战旗", good.money_num, good.return_count)
            else
                str = "物品不存在"
            end
            self._ccbOwner.label_line1:setString(str)
            self._ccbOwner.label_line2:setVisible(false)
        else
            self._options = options.zone
            local s = {"A", "B", "C", "D"}
            local str = string.format("确实选择“赛区 %s”进行这一周的斗魂场角逐么？", s[self._options])
            self._ccbOwner.label_line2:setVisible(true) 
            self._ccbOwner.label_line1:setString(str)
            self._ccbOwner.label_line2:setString("选择后直到下周一凌晨3点斗魂场刷新前无法变更")
        end
    end
end

function QUIDialogSystemPrompt:_onTriggerClose(tag, menuItem)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSystemPrompt:_onTriggerConfirm(tag, menuItem)
    if self._string ~= nil then
        app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
    elseif self._buyFlag ~= nil then
        --todo
        app:getClient():buyFlag()
    else
        --用于加入赛区
        app:getClient():pvpZoneJoin(self._options, 
        function() 
                app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                app:getClient():pvpZonePkList()
        end )
    end
end

return QUIDialogSystemPrompt