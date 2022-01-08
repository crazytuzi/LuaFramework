--[[
    This module is developed by Eason
    2015/10/28
]]

local ChatOperatePanel = class("ChatOperatePanel", BaseLayer)

function ChatOperatePanel:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.chat.OperationPanel")

    self.friendID = nil
end

function ChatOperatePanel:initUI(ui)
	self.super.initUI(self,ui)

    self.applyButton = TFDirector:getChildByPath(ui, "Btn_applyFriend")
    assert(self.applyButton)
    self.Btn_invite = TFDirector:getChildByPath(ui, "Btn_invite")
    self.Btn_jbwj = TFDirector:getChildByPath(ui, "Btn_jbwj")
    self.Btn_jinyan = TFDirector:getChildByPath(ui, "Btn_jinyan")
    self.applyButton.parent = self
    self.Btn_invite.parent = self
end

function ChatOperatePanel:onShow()
    self.super.onShow(self)
end

function ChatOperatePanel:dispose()
    self.super.dispose(self)
end

function ChatOperatePanel:onHide()
end

function ChatOperatePanel:registerEvents()
	self.super.registerEvents(self)

    self.applyButton:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onApply))
    self.Btn_invite:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickFaction))
    self.Btn_jbwj:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickJbwj))
    self.Btn_jinyan:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickJinyan))
    self.Btn_jbwj.logic = self
    self.Btn_jinyan.logic = self
end

function ChatOperatePanel:removeEvents()
    self.super.removeEvents(self)

    self.applyButton:removeMEListener(TFWIDGET_CLICK)
    self.Btn_invite:removeMEListener(TFWIDGET_CLICK)
    self.Btn_jbwj:removeMEListener(TFWIDGET_CLICK)
    self.Btn_jinyan:removeMEListener(TFWIDGET_CLICK)
end

function ChatOperatePanel:setFriendID(friendID,friendLevel)
    self.friendID = friendID
    self.friendLevel = friendLevel
end

function ChatOperatePanel:setCanInvite(canInvite)
    if canInvite then
        self.Btn_invite:setTouchEnabled(true)
        self.Btn_invite:setGrayEnabled(false)
    else
        self.Btn_invite:setTouchEnabled(false)
        self.Btn_invite:setGrayEnabled(true)
    end
end

function ChatOperatePanel:setIsHasFaction(isHas)
    if isHas then
        self.Btn_invite:setTextureNormal("ui_new/chat/btn_yqrb2.png")
    else
        self.Btn_invite:setTextureNormal("ui_new/chat/btn_yqrb.png")
    end
end

function ChatOperatePanel.onApply(sender)
    local level = MainPlayer:getLevel()
    local openLevel = FunctionOpenConfigure:getOpenLevel(1102) 
    if openLevel > level then
        --toastMessage("好友系统将在"..openLevel.."级开放")
        toastMessage(stringUtils.format(localizable.common_function_friend,openLevel))
        return
    end
    
    FriendManager:requestFriend(sender.parent.friendID)
    AlertManager:close()
end

function ChatOperatePanel.onClickFaction(sender)
    local post = FactionManager:getPostInFaction()
    print("post = ",post)
    if (post ~= 1) and (post ~= 2) then
        --toastMessage("没有权限邀请入帮")
        toastMessage(localizable.chatOperatePanel_no_permission)
        return
    end

    if FunctionOpenConfigure:getOpenLevel(1201) <= sender.parent.friendLevel then
        FactionManager:sendGuildInvitation(sender.parent.friendID)
        AlertManager:close()
    else
        --toastMessage("该玩家等级过低")
        toastMessage(localizable.common_play_level_low)
    end
end

function ChatOperatePanel.onClickJbwj(btn)
    -- AlertManager:close()

    local layer = AlertManager:addLayerByFile("lua.logic.chat.ChatReport",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
    layer:setData(btn.logic.playerId) 
    AlertManager:show()
end

function ChatOperatePanel.onClickJinyan(btn)

    -- AlertManager:close()
    local layer = AlertManager:addLayerByFile("lua.logic.chat.ChatBanned",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
    layer:setData(btn.logic.playerId,btn.logic.playerName) 
    AlertManager:show()

end

function ChatOperatePanel:setModelType(guideType,playerId,playerName)
    -- guideType & 2 != 0 管理员

    local flag = bit_and(guideType,2)
    if flag ~= 0 then
        self.Btn_jbwj:setVisible(false)
        self.Btn_jinyan:setVisible(true)
    else
        self.Btn_jbwj:setVisible(true)
        self.Btn_jinyan:setVisible(false) 
    end

    self.playerId = playerId
    self.playerName = playerName

end
return ChatOperatePanel