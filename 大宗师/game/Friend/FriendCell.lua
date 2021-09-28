
local FriendCell = class("FriendCell", function()

    return CCTableViewCell:new()		
	 
end)

local MAX_ZORDER = 100000

function FriendCell:getContentSize()
    return CCSizeMake(display.width, self._rootnode["itemBg"]:getContentSize().height) 
end

function FriendCell:ctor(cellType)
    self.cellType = cellType

    local cellPath = "friend/friend_cell.ccbi"
    if cellType == 4 then
        cellPath = "friend/friend_apply_cell.ccbi"
    end

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad(cellPath, proxy, self._rootnode)
    node:setPosition(display.width * 0.5, self._rootnode["itemBg"]:getContentSize().height)
    self:addChild(node)

    if cellType ~= 4 then
        for i = 1,3 do
            if i ==cellType then
                self._rootnode["node_group_"..i]:setVisible(true)
            else
                self._rootnode["node_group_"..i]:setVisible(false)
            end
        end
    end

    self.heroNameTTF =  ResMgr.createShadowMsgTTF({text = "",color = ccc3(255,210,0)})--n
    self._rootnode["heroName"]:getParent():addChild(self.heroNameTTF)  


    if self._rootnode["bubble_node"] ~= nil then

        self.bubble = display.newSprite("#friend_chat_buble.png")
        self._rootnode["bubble_node"]:addChild(self.bubble)
        local expBuble = self._rootnode["chat_bubble"]
        self.bubble:setPosition(expBuble:getPositionX(),expBuble:getPositionY())
    end



end


function FriendCell:refresh(id)
    self:refreshCellData(id)
    self:refreshCellContent()    
end

function FriendCell:initBtnEvent()
    if self.cellType ~= 4 then
        ResMgr.setControlBtnEvent(self._rootnode["send_naili"], function()
            self:onSendNaili()
        end)
        ResMgr.setControlBtnEvent(self._rootnode["apply_btn"], function()
            self:onApply()
        end)
        ResMgr.setControlBtnEvent(self._rootnode["get_naili"], function()
            self:onGetNaili()
        end)
    else
        ResMgr.setControlBtnEvent(self._rootnode["agree_btn"], function()
            self:onAgree()
        end)
        ResMgr.setControlBtnEvent(self._rootnode["reject_btn"], function()
            self:onReject()
        end)
    end
end

function FriendCell:refreshCellData(id)
    local listData = FriendModel.getList(self.cellType)
    local cellData = listData[id]
    self.index = id 

    --基础的
    self.account     = cellData.account
    self.battlepoint = cellData.battlepoint or 0
    self.charm       = cellData.charm       or 0
    self.cls         = cellData.cls         or 1
    self.level       = cellData.level       or 0
    self.name        = cellData.name        or 0
    self.resId       = cellData.resId       or 0

    --除了第三个，其他会用到在线状态
    self.isChat      = cellData.isChat      or 0
    self.isOnline    = cellData.isOnline    or 0

    --1.我的好友 --是否已赠送耐力
    self.isSendNaili = cellData.isSendNaili or 0
    --2.推荐好友 是否申请好友
    self.isApply     = cellData.isApply     or 0
    self.isAdd       = cellData.isAdd       or 0

    --3.领取耐力 几天前 是否已领取耐力 耐力数值
    self.time        = cellData.time        or 0  --几天前送的耐力
    self.nailiNum    = cellData.nailiNum    or 1  --赠送的耐力数值


    --4.申请好友
    self.content     = cellData.content     or "" --申请好友的内容
end

function FriendCell:refreshCellContent()

    self._rootnode["zhanli_num"]:setString(self.battlepoint)
    self._rootnode["charm_num"]:setString(self.charm)

    self._rootnode["level"]:setString(self.level)
    self.heroNameTTF:setString(self.name)
    local heroPosX,heroPosY = self._rootnode["heroName"]:getPosition()
    self.heroNameTTF:setPosition(ccp(heroPosX+self.heroNameTTF:getContentSize().width/2,heroPosY))
    
    -- --更新头像
    ResMgr.refreshIcon({id = self.resId,itemBg = self._rootnode["headIcon"],resType = ResMgr.HERO,cls = self.cls})

    local GREEN = ccc3(0, 215, 52)
    local GRAY  = ccc3(100, 100, 100)
    --除了第3个，其他全是在线状态
    if self.isOnline == 0 then
        self._rootnode["name_status"]:setColor(GRAY)
        self._rootnode["name_status"]:setString("离线")
        -- self._rootnode["name_status"]:setVisible(false)
    else
        self._rootnode["name_status"]:setColor(GREEN)
        self._rootnode["name_status"]:setString("在线")
    end

    if self._rootnode["bubble_node"] ~= nil then

        if self.isChat == 0  then
            self._rootnode["bubble_node"]:setVisible(false)
        else
            self._rootnode["bubble_node"]:setVisible(true)
            self:startBubbleAnim()
        end
    end

    --更新个别的内容
    if self.cellType == 1 then
        self.headIcon:setTouchEnabled(true)
        self._rootnode["name_status"]:setVisible(true)
        if self.isSendNaili == 0 then
            self._rootnode["send_naili"]:setVisible(true)
            self._rootnode["send_ttf"]:setVisible(false)
        else
            self._rootnode["send_naili"]:setVisible(false)
            self._rootnode["send_ttf"]:setVisible(true)
        end
    elseif self.cellType == 2 then
        self._rootnode["apply_btn"]:setVisible(false)
        self._rootnode["apply_ttf"]:setVisible(false)
        self._rootnode["add_ttf"]:setVisible(false)

        if self.isApply == 1 then
            self._rootnode["apply_ttf"]:setVisible(true)
        elseif self.isAdd == 1 then
            self._rootnode["add_ttf"]:setVisible(true)
        else
            self._rootnode["apply_btn"]:setVisible(true)
        end

    elseif self.cellType == 3 then
        self._rootnode["name_status"]:setColor(GREEN)
        -- self.headIcon:setTouchEnabled(true)
        self._rootnode["name_status"]:setVisible(true)
        if self.time > 0 then
            self._rootnode["name_status"]:setString(self.time.."天前")
        else
            self._rootnode["name_status"]:setString("今天")
        end
    elseif self.cellType == 4 then
        self._rootnode["desc_ttf"]:setString(self.content)
    end
end

function FriendCell:startBubbleAnim()

    self.bubble:stopAllActions()
    self.bubble:setOpacity(0)
    local toOut = CCFadeOut:create(FriendModel.REQ_INTERVAL/4)
    local toIn  = CCFadeIn:create(FriendModel.REQ_INTERVAL/4)
    
    local everAct =  CCRepeatForever:create(transition.sequence({toOut,toIn}))
    self.bubble:runAction(everAct)
end

function FriendCell:onSendNaili()
    FriendModel.sendNailiReq({
        account = self.account
        })
end

function FriendCell:onApply()
    if game.player:checkIsSelfByAcc(self.account) then
        ResMgr.showErr(3200009)
    else
        local listData = FriendModel.getList(2)
        local cellData = listData[self.index]
        local applyBox = require("game.Friend.FriendApplyBox").new({
            account = cellData.account
            })
        display.getRunningScene():addChild(applyBox, BOX_ZORDER.BASE)
    end
end

function FriendCell:onGetNaili()

    FriendModel.getNailiReq({
        account = self.account
        })

end

function FriendCell:onAgree()

    FriendModel.acceptReq({
        account = self.account
        })
end

function FriendCell:onReject()
    FriendModel.rejectReq({
        account = self.account
        })
end

function FriendCell:createFriendBox()
    local friendBox = require("game.Friend.FriendManageBox").new(self.index)
    display.getRunningScene():addChild(friendBox, BOX_ZORDER.BASE)
end



function FriendCell:create(param)

    self.tableViewRect = param.tableViewRect
    
    self.headIcon = self._rootnode["headIcon"]
    self:initHeadIcon()

    self:initBtnEvent()
    
    self:refresh(param.id)
    return self

end

function FriendCell:initHeadIcon()
    self.headIcon:setTouchEnabled(false)
    self.headIcon:setTouchSwallowEnabled(false)

    ResMgr.setNodeEvent({
        node = self.headIcon,
        touchFunc = function()
            self:onHeadTouched()
        end,
        tableViewRect = self.tableViewRect
        })

end

function FriendCell:onHeadTouched()
    if self.isChat == 1 then
        self:createChatLayer()
    else
        self:createFriendBox()
    end    
end

function FriendCell:createChatLayer()
    local listData = FriendModel.getList(self.cellType)
    local cellData = listData[self.index]
    cellData.isChat = 0
    self._rootnode["bubble_node"]:setVisible(false)

    local layer = require("game.Chat.ChatLayer").new(nil,1,self.index)
    layer:setPosition(0, 0)
    game.runningScene:addChild(layer, 10000)
end

function FriendCell:createDelMsgBox()

    local msg = require("utility.MsgBoxEx").new({
        resTable = rowAll,
        confirmFunc = function(node) 
            if buyFunc ~= nil then 
                buyFunc()
            end
            if(closeListener ~= nil) then
                closeListener()
            end
            node:removeFromParentAndCleanup(true) 
        end,
        closeListener = closeListener
        })

    game.runningScene:addChild(msg, MAX_ZORDER) 
end





return FriendCell
