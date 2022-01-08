
local InviteFriendSendLayer = class("InviteFriendSendLayer", BaseLayer)

--local desc1 = "阔别一十九载，金庸武侠重出江湖。全新横版战斗掌中微操系统， 四大主角，数百名侠客任你挑选，成名绝技，各种武学秘籍千变万化，快来和我一起玩吧！我在"
--local desc2 = "服务器，你可以在奇遇邀请码中，点击受邀有礼，输入并验证我的账号"
--local desc3 = "，即有豪礼相送！"

local desc1 = localizable.InFriendSendLayer_desc1
local desc2 = localizable.InFriendSendLayer_desc2
local desc3 = localizable.InFriendSendLayer_desc3

function InviteFriendSendLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.CodeLayerSend")
end

function InviteFriendSendLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.btn_copy       = TFDirector:getChildByPath(ui, 'btn_fuzhi')
    self.btn_send       = TFDirector:getChildByPath(ui, 'btn_pyquan')
    self.panel_textarea = TFDirector:getChildByPath(ui, 'panel_textarea')


    self.btn_Close              = TFDirector:getChildByPath(ui, 'btn_close')

end

function InviteFriendSendLayer:registerEvents(ui)
    self.super.registerEvents(self)

    ADD_ALERT_CLOSE_LISTENER(self, self.btn_Close)
    self.btn_copy.logic = self
    self.btn_copy:addMEListener(TFWIDGET_CLICK, audioClickfun(self.CopyContent),1)

    self.btn_send.logic = self
    self.btn_send:addMEListener(TFWIDGET_CLICK, audioClickfun(self.sendToFriend),1)
end

function InviteFriendSendLayer:removeEvents()
    self.super.removeEvents(self)
end


function InviteFriendSendLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()
end


function InviteFriendSendLayer:refreshUI()

    local currentServer = SaveManager:getCurrentSelectedServer()
    self.serverName = "[" .. SaveManager:getServerName(currentServer) .. "]"

    self.InviteCodeInfo = QiyuManager:GetInviteCodeData()

    self.InviteCode = self.InviteCodeInfo.myCode

    self:creatRichText()
end

function InviteFriendSendLayer:creatRichText()
    if self.richtext then
        return
    end
    local size = self.panel_textarea:getContentSize()
    self.richtext  = TFRichText:create(size)
    self.richtext:setFontSize(20)
    self.richtext:setPosition(ccp(0, size.height))
    self.richtext:setAnchorPoint(ccp(0.5,1))
    self.panel_textarea:addChild(self.richtext)

    local servername    = self.serverName
    local myInviteCode  = self.InviteCode
    -- <p style="text-align:left;line-height:50px; margin:20px; padding:0">
    local strFormat =[[<p style="text-align:left margin:5px"><font face = "simhei" color="#3d3d3d" fontSize="26">%s</font><font face = "simhei" color="#008030" fontSize="26">%s</font><font face = "simhei" color="#3d3d3d" fontSize="26">%s</font><font face = "simhei" color="#008030" fontSize="26">%s</font><font face = "simhei" color="#3d3d3d" fontSize="26">%s</font></p>]]

    local notifyStr = ""
    notifyStr = string.format(strFormat, desc1, servername, desc2, myInviteCode, desc3)

    self.richtext:setText(notifyStr)

    local textSize = self.richtext:getContentSize()

    -- local x = (size.width - textSize.width) / 2
    local x = size.width / 2

    self.richtext:setPosition(ccp(x, size.height))
end

function InviteFriendSendLayer:copyToPasteBord()
    local servername    = self.serverName
    local myInviteCode  = self.InviteCode
    local content = string.format("%s%s%s%s%s", desc1, servername, desc2, myInviteCode, desc3)
    print("content =  ", content)
    TFDeviceInfo:copyToPasteBord(content)
end

function InviteFriendSendLayer.CopyContent(sender)
    local self = sender.logic

    -- 复制到手机的验证码
    self:copyToPasteBord()
    --toastMessage("复制成功")
    toastMessage(localizable.vipQQLayer_copy_suc)
end


function InviteFriendSendLayer.sendToFriend(sender)
    local self = sender.logic

    self:copyToPasteBord()
    --toastMessage("大侠已复制成功，快去您的微信分享吧！")
    toastMessage(localizable.InFriendSendLayer_share)
end

return InviteFriendSendLayer