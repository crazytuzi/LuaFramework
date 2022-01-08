--[[
    This module is developed by Eason
    2015/10/22
]]

local FriendCell = class("FriendCell", BaseLayer)

local localVars = {
    type = nil,
    pageIndex = {friendsList = 1, addFriend = 2, applicationList = 3},
    parentLayer = nil,
}

function FriendCell:ctor(data)
    self.super.ctor(self, data)

    self.checkPlayerId = nil
    -- init
    self:init("lua.uiconfig_mango_new.friends.FriendCell")
end

function FriendCell:initUI(ui)
    self.super.initUI(self, ui)

    self.playerID = nil
    self.info = nil

    -- left area
    self.head = TFDirector:getChildByPath(ui, "bg")
    assert(self.head)
    self.head.parent = self
    self.head:setTouchEnabled(true)

    self.img_Frame = TFDirector:getChildByPath(ui, "bg_head")
    assert(self.img_Frame)

    self.headIcon = TFDirector:getChildByPath(ui, "Img_icon")
    assert(self.headIcon)

    self.bg_head = TFDirector:getChildByPath(ui, "bg_head")
    assert(self.bg_head)
    self.bg_head:setTouchEnabled(false)
    

    self.levelText = TFDirector:getChildByPath(ui, "txt_level")
    assert(self.levelText)

    self.nameText = TFDirector:getChildByPath(ui, "txt_name")
    assert(self.nameText)

    self.vipText = TFDirector:getChildByPath(ui, "txt_vip")
    assert(self.vipText)

    self.battleScoreText = TFDirector:getChildByPath(ui, "txt_zdl")
    assert(self.battleScoreText)

    self.loginTime = TFDirector:getChildByPath(ui, "txt_dl")
    assert(self.loginTime)

    -- right area
    self.buttonGet = TFDirector:getChildByPath(ui, "Btn_get")
    assert(self.buttonGet)
    self.buttonGet.parent = self

    --召回按钮
    self.Btn_zhaohui = TFDirector:getChildByPath(ui, "Btn_zhaohui")
    assert(self.Btn_zhaohui)
    self.Btn_zhaohui.parent = self

    self.buttonSend = TFDirector:getChildByPath(ui, "Btn_send")
    assert(self.buttonSend)
    self.buttonSend.parent = self

    self.imageHasGot = TFDirector:getChildByPath(ui, "Image_hasGot")
    assert(self.imageHasGot)

    self.imageHasSent = TFDirector:getChildByPath(ui, "Image_hasSent")
    assert(self.imageHasSent)

    self.buttonIngore = TFDirector:getChildByPath(ui, "Btn_ingore")
    assert(self.buttonIngore)
    self.buttonIngore.parent = self

    self.buttonAgree = TFDirector:getChildByPath(ui, "Btn_tongyi")
    assert(self.buttonAgree)
    self.buttonAgree.parent = self

    self.buttonAdd = TFDirector:getChildByPath(ui, "Btn_add")
    assert(self.buttonAdd)
    self.buttonAdd.parent = self

    self.imageHasRequested = TFDirector:getChildByPath(ui, "Image_hasRequested")
    assert(self.imageHasRequested)

    --added by wuqi
    self.path_new_vip = {"ui_new/chat/img_vip_16.png", "ui_new/chat/img_vip_17.png", "ui_new/chat/img_vip_18.png"}
    self.img_vip = TFDirector:getChildByPath(ui, "img_vip")
end

function FriendCell:onShow()
    self.super.onShow(self)
end

function FriendCell:registerEvents()
    self.super.registerEvents(self)

    self.head:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onFriendInfo))
    self.buttonGet:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onGet))
    self.buttonSend:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSend))
    self.buttonAdd:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAddFriend))
    self.buttonIngore:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onIngoreFriend))
    self.buttonAgree:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAgreeFriend))
    self.Btn_zhaohui:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onZhaohui))
end

function FriendCell:removeEvents()
    self.head:removeMEListener(TFWIDGET_CLICK)
    self.buttonGet:removeMEListener(TFWIDGET_CLICK)
    self.buttonSend:removeMEListener(TFWIDGET_CLICK)
    self.buttonAdd:removeMEListener(TFWIDGET_CLICK)
    self.buttonIngore:removeMEListener(TFWIDGET_CLICK)
    self.buttonAgree:removeMEListener(TFWIDGET_CLICK)
    self.Btn_zhaohui:removeMEListener(TFWIDGET_CLICK)

    self.super.removeEvents(self)
end

function FriendCell:dispose()
    self.super.dispose(self)
end

function FriendCell:setParentLayer(layer)
    localVars.parentLayer = layer
end

function FriendCell:hideAllButtons()
    self.buttonGet:setVisible(false)
    self.buttonSend:setVisible(false)
    self.imageHasGot:setVisible(false)
    self.imageHasSent:setVisible(false)
    self.buttonIngore:setVisible(false)
    self.buttonAgree:setVisible(false)
    self.buttonAdd:setVisible(false)
    self.imageHasRequested:setVisible(false)
    self.Btn_zhaohui:setVisible(false)
end

--added by wuqi
function FriendCell:addVipEffect(btn, vipLevel)
    if btn.effect then
        btn.effect:removeFromParent()
        btn.effect = nil
    end

    if vipLevel <= 18 then  --if vipLevel <= 15 or vipLevel > 18 then -- modify by zr 关掉高VIP特效
        return
    end
    local resPath = "effect/ui/vip_" .. vipLevel .. ".xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("vip_" .. vipLevel .. "_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(btn:getContentSize().width / 2, btn:getContentSize().height / 2))
    effect:setVisible(true)
    effect:setScale(0.82)
    effect:playByIndex(0, -1, -1, 1)
    btn:addChild(effect, 200)
    btn.effect = effect
end

function FriendCell:setInfo(type, info)
    localVars.type = type
    self.info = info
    self.playerID = info.playerId

    self.vipText:setVisible(true)
    self.img_vip:setVisible(false)

    local role = RoleData:objectByID(info.icon)                                     --pck change head icon and head icon frame
    if role then
        self.headIcon:setTexture(role:getIconPath())
    end
    Public:addFrameImg(self.headIcon,info.headPicFrame)                            --end
    if localVars.type ~= localVars.pageIndex.friendsList then
        Public:addInfoListen(self.headIcon,true,1,info.playerId)
    else
        Public:addInfoListen(self.headIcon,false)
    end
    self.vipText:setVisible(true)
    self.levelText:setText(info.level .. "d")
    self.nameText:setText(info.name)
    self.vipText:setText("o" .. info.vip)
    -- self.battleScoreText:setText("战斗力：" .. info.power)
    self.battleScoreText:setText(stringUtils.format(localizable.common_CE, info.power))

    --added by wuqi
    if info.vip > 15 then
        self.vipText:setVisible(false)
        self.img_vip:setVisible(true)
        --self.img_vip:setTexture(self.path_new_vip[vipLevel - 15])
        self:addVipEffect(self.img_vip, info.vip)
    end

    if info.online then
         -- self.loginTime:setText('玩家在线')
         self.loginTime:setText(localizable.factionInfo_play_online)
         
    else
        local passTime = MainPlayer:getNowtime() - info.lastLoginTime / 1000
        self.loginTime:setText(FriendManager:formatTimeToString(passTime))
    end

    self:hideAllButtons()

    --local iszhaohui = FriendManager:isShowZhaohuiBtn(MainPlayer:getNowtime() - info.lastLoginTime / 1000)
    -- local iszhaohui = PlayBackManager:isShowZhaohuiBtn(self.playerID)
    local iszhaohui = PlayBackManager:playerNeedBeCallBack(self.playerID, info.level, info.lastLoginTime)
    self.Btn_zhaohui:setVisible(false)
    
    self.Btn_zhaohui.playerId = self.playerID
    --print("self.playerID =",self.playerID)
    -- show or hide buttons
    if type == localVars.pageIndex.friendsList then
        self.buttonGet:setVisible(true)
        self.buttonSend:setVisible(true)
    
        -- 是否在已领取列表中
        if FriendManager:isInDrawPlayers(info.playerId) then
            self.buttonGet:setVisible(false)
            self.imageHasGot:setVisible(true) 
        else
            if not info.give then
                -- 不可以领取
                self.buttonGet:setVisible(false)
            end
        end

        --是否可以召回
        if iszhaohui then
            self.Btn_zhaohui:setVisible(true)
            self.buttonGet:setVisible(false)
            self.imageHasGot:setVisible(false)
        end

        -- 是否在已赠送列表中
        if FriendManager:isInGivePlayers(info.playerId) then
            self.buttonSend:setVisible(false)
            self.imageHasSent:setVisible(true)
        end

    elseif type == localVars.pageIndex.addFriend then
        -- 不是自己
        if info.playerId ~= MainPlayer:getPlayerId() then
            -- 不在好友列表中
            if not FriendManager:isInFriendList(info.playerId) then
                if info.apply then
                    self.imageHasRequested:setVisible(true)
                    self.buttonAdd:setVisible(false)
                else
                    self.buttonAdd:setVisible(true)
                    self.imageHasRequested:setVisible(false)
                end
            end
        end

    elseif type == localVars.pageIndex.applicationList then
        self.buttonIngore:setVisible(true)
        self.buttonAgree:setVisible(true)
    end
end

function FriendCell.onFriendInfo(sender)
    if localVars.type == localVars.pageIndex.friendsList then
        local layer = AlertManager:addLayerToQueueAndCacheByFile(
            "lua.logic.friends.FriendInfoLayer", AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
        layer:setInfo(sender.parent.info)
        AlertManager:show();
    end
end

function FriendCell.onGet(sender)
    FriendManager:get(sender.parent.playerID)
end

function FriendCell.onSend(sender)
    FriendManager:send(sender.parent.playerID)
end

function FriendCell.onAddFriend(sender)
    FriendManager:requestFriend(sender.parent.playerID)
end

function FriendCell.onIngoreFriend(sender)
    FriendManager:excuteFriendApply(3, sender.parent.playerID)
end

function FriendCell.onAgreeFriend(sender)
    FriendManager:excuteFriendApply(1, sender.parent.playerID)
end

--召回按钮回调
function FriendCell.onZhaohui(sender)
    local playerId = sender.playerId
    --local layer  = require("lua.logic.friends.FriendRecall"):new()
    --AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1) 
    local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.friends.FriendRecall");
    layer:setData(playerId)
    AlertManager:show()
end

return FriendCell