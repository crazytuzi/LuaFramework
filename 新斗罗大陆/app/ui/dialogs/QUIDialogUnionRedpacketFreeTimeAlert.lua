--
-- Author: Kumo
-- 获得宗门红包免费特权
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionRedpacketFreeTimeAlert = class("QUIDialogUnionRedpacketFreeTimeAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogUnionRedpacketFreeTimeAlert:ctor(options)
	local ccbFile = "ccb/Dialog_Society_Redpacket_tequan.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
    QUIDialogUnionRedpacketFreeTimeAlert.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._callBackFun = options.callBack or options.callback
    self._isGo = options.isGo
    self._isDailyTask = options.isDailyTask

    if remote.oldUser ~= nil and remote.oldUser.level < remote.user.level then
    	self._ccbOwner.node_btn:setVisible(false)
    else
    	self._ccbOwner.node_btn:setVisible(true)
    end

    app:getUserOperateRecord():recordeCurrentTime(remote.union.FREE_TOKEN_REDPACKET_TIPS)
end

function QUIDialogUnionRedpacketFreeTimeAlert:viewDidAppear()
	QUIDialogUnionRedpacketFreeTimeAlert.super.viewDidAppear(self)

    self:updateInfo()
end

function QUIDialogUnionRedpacketFreeTimeAlert:viewWillDisappear()
  	QUIDialogUnionRedpacketFreeTimeAlert.super.viewWillDisappear(self)
end

function QUIDialogUnionRedpacketFreeTimeAlert:updateInfo()
    local num = 0
    if self._isGo and remote.user.userConsortia.free_red_packet_count and remote.user.userConsortia.free_red_packet_count > 0 then
        num = 188
    elseif remote.user.userConsortia.free_red_packet4_count and remote.user.userConsortia.free_red_packet4_count > 0 then
        num = 588
    elseif remote.user.userConsortia.free_red_packet3_count and remote.user.userConsortia.free_red_packet3_count > 0 then
        num = 588
    elseif remote.user.userConsortia.free_red_packet2_count and remote.user.userConsortia.free_red_packet2_count > 0 then
        num = 288
    elseif remote.user.userConsortia.free_red_packet_count and remote.user.userConsortia.free_red_packet_count > 0 then
        num = 188
    end  

    if self._isDailyTask then
        num = 188
    end

    if self._isGo then
        self._ccbOwner.tf_ok:setString("前往")
    else
        self._ccbOwner.tf_ok:setString("确定")
    end

    local str = string.format("恭喜魂师大人，获得了%d钻石福袋免费发放特权，免费福袋不消耗钻石发放次数，快去给宗门的小伙伴发福利吧~", num)
    self._ccbOwner.tf_desc:setString(str)
end

function QUIDialogUnionRedpacketFreeTimeAlert:_onTriggerGo(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_go) == false then return end
    if self._isGo then
        remote.union:openDialog(function()
            remote.redpacket:openDialog(remote.redpacket.SEND)
        end)
    else
        self:playEffectOut()
    end
end

function QUIDialogUnionRedpacketFreeTimeAlert:_backClickHandler()
    self:_close()
end

function QUIDialogUnionRedpacketFreeTimeAlert:_close()
	local callback = self._callBackFun
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if callback ~= nil then
    	callback()
    end
end

return QUIDialogUnionRedpacketFreeTimeAlert