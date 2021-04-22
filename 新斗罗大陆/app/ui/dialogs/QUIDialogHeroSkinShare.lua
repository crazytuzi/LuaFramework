-- @Author: xurui
-- @Date:   2019-01-16 16:26:08
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-02 18:43:00
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroSkinShare = class("QUIDialogHeroSkinShare", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

local NO_UNION_ERROR = "您未加入宗门"
local NO_CHANNEL_ERROR = "该频道尚未建立"

function QUIDialogHeroSkinShare:ctor(options)
 	local ccbFile = "ccb/Dialog_society_share.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerGlobal", callback = handler(self, self._onTriggerGlobal)},
        {ccbCallbackName = "onTriggerUnion", callback = handler(self, self._onTriggerUnion)},
    }
    QUIDialogHeroSkinShare.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    if options then
    	self._skinInfo = options.skinInfo
    end

    local character = QStaticDatabase:sharedDatabase():getCharacterByID(self._skinInfo.character_id)
    self._str = string.format("##0xA212D8我获得了%s的【%s】皮肤，大家快来围观！", character.name, self._skinInfo.skins_name)
end

function QUIDialogHeroSkinShare:_onTriggerUnion(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_shareToUnion) == false then return end
    app.sound:playSound("common_small")
    if remote.user.userConsortia.consortiaId and remote.user.userConsortia.consortiaId ~= "" then
        if app:getServerChatData():canSendMessage(2) then  
        	app:getServerChatData():sendMessage(self._str, 2, nil, nil, nil, {skinId = self._skinInfo.skins_id, heroId = self._skinInfo.character_id})
            self:_onTriggerClose()
            app.tip:floatTip("分享成功")

            app:getUserOperateRecord():setHeroSkinShareTimes()
        else
            app.tip:floatTip(NO_CHANNEL_ERROR)
        end
    else
        app.tip:floatTip(NO_UNION_ERROR)
    end
end

function QUIDialogHeroSkinShare:_onTriggerGlobal(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_shareToWold) == false then return end
    app.sound:playSound("common_small")
    if app:getServerChatData():canSendMessage(1) then  
        app:getServerChatData():sendMessage(self._str, 1, nil, nil, nil, {skinId = self._skinInfo.skins_id, heroId = self._skinInfo.character_id})
        self:_onTriggerClose()
        app.tip:floatTip("分享成功")

        app:getUserOperateRecord():setHeroSkinShareTimes()
    else
        app.tip:floatTip(NO_CHANNEL_ERROR)
    end
end

function QUIDialogHeroSkinShare:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogHeroSkinShare:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogHeroSkinShare:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogHeroSkinShare
