
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogLocalBattle = class("QUIDialogLocalBattle", QUIDialog)

function QUIDialogLocalBattle:ctor(options)
    local ccbFile = "ccb/Dialog_Local_Battle_List.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogLocalBattle._onTriggerClose)},
        {ccbCallbackName = "onTriggerCreate", callback = handler(self, QUIDialogLocalBattle._onTriggerCreate)},
        {ccbCallbackName = "onTriggerSearch", callback = handler(self, QUIDialogLocalBattle._onTriggerSearch)},
    }
    QUIDialogLocalBattle.super.ctor(self, ccbFile, callBacks, options)

end

function QUIDialogLocalBattle:_onTriggerClose( ... )
    self:popSelf()
end

function QUIDialogLocalBattle:_onTriggerCreate( ... )
    app.udp:createServer()
end

function QUIDialogLocalBattle:_onTriggerSearch( ... )
    app.udp:createClient()
    app.udp:scanServer()
end

return QUIDialogLocalBattle