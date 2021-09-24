-- @Author hj
-- @Description 好友系统改版第二个页签好友礼物
-- @Date 2018-04-18

friendGiftDialog = {}

function friendGiftDialog:new(layer)
    local nc = {
        layerNum = layer,
        giftNum = 0,
        -- 赠送状态
        sendStatusTb = {},
        -- 领取状态
        receiveStatusTb = {},
        gitfBtnList = {},
        limit = friendInfoVoApi:getfriendCfg(1)
    }
    setmetatable(nc,self)
    self.__index = self
    return nc
end

function friendGiftDialog:doUserHandler( ... )

    self:updateStatus()
    local tipLabel = GetTTFLabel(getlocal("friend_newSys_desc2",{friendInfoVoApi:getGiftNum(),self.limit}),25)
    self.bgLayer:addChild(tipLabel)
    tipLabel:setAnchorPoint(ccp(0,0))
    tipLabel:setPosition(ccp(25,80))
    self.tipLabel = tipLabel

    local noFriendLabel = GetTTFLabel(getlocal("friend_newSys_list_tip"),25)
    self.bgLayer:addChild(noFriendLabel,3)
    noFriendLabel:setAnchorPoint(ccp(0.5,0.5))
    noFriendLabel:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-158-120)/2+120))
    noFriendLabel:setColor(G_ColorGray) 
    if #friendInfoVo.friendTb == 0 then
        noFriendLabel:setVisible(true)
    else
        noFriendLabel:setVisible(false)
    end
    self.noFriendLabel = noFriendLabel

    -- 一键赠送
    local function sendAllCallback( ... )
        local sendRequestList = {}
        for k,v in pairs(friendInfoVo.friendTb) do
            if v.sendFlag == 0 then
               v.sendFlag = 1
               table.insert(sendRequestList,v.uid) 
            end
        end
        
        local function callback(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret == true then
                friendInfoVoApi:updateAllSendStatus()
                self:updateStatus()
                self.tv:reloadData()
                self:flushButton()
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_giftSendSuccess"),30)
            end
        end
        socketHelper:sendFriendGift(sendRequestList,callback)
    end

    -- 一键接受
    local function receiveAllCallback( ... )
        local sendRequestList = {}
        local sum = 0

        for k,v in pairs(friendInfoVo.friendTb) do
            if sum+1 > self.limit - friendInfoVoApi:getGiftNum() then
                break
            end
            if v.receiveFlag == 1 then
                table.insert(sendRequestList,v.uid)
                sum = sum + 1
            end
        end
        if sum == 0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_err_12010"),30)
        else
            local function callback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret == true then
                    if sData.data.friends.rgift and sData.data.reward then
                        local rewardlist = FormatItem(sData.data.reward,nil,true)
                        G_showRewardTip(rewardlist,true)
                        for k,v in pairs(rewardlist) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)  
                        end
                        friendInfoVoApi:updateAllReceiveStatus(sum)
                        self:updateStatus()
                        self.tv:reloadData()
                        self:flushButton()
                        self:updateStr()
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_giftGetSuccess"),30)
                    end
                end
            end
            socketHelper:getFriendNewGift(sendRequestList,callback)
        end
    end
    local strSize = 25
    if G_isAsia() == false then
        strSize = 20
    end
    local sendGiftButton = G_createBotton(self.bgLayer,ccp((G_VisibleSizeWidth-40)/3+20-30,45),{getlocal("friend_newSys_gift_b1"),strSize},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sendAllCallback,0.8,-(self.layerNum-1)*20-4)
    self.sendGiftButton = sendGiftButton
    local acceptGiftButton = G_createBotton(self.bgLayer,ccp((G_VisibleSizeWidth-40)/3*2+20+30,45),{getlocal("friend_newSys_gift_b2"),strSize},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",receiveAllCallback,0.8,-(self.layerNum-1)*20-4)
    self.acceptGiftButton = acceptGiftButton
    self:updateStr()
    self:flushButton()
end

function friendGiftDialog:initTableView( ... )

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    dialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight -158-120))
    dialogBg:setAnchorPoint(ccp(0.5,0))
    dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,120))
    self.bgLayer:addChild(dialogBg)

    local function callBack( ... )
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight -158-120-6),nil)
    self.tv:setPosition(ccp(20,123))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.bgLayer:addChild(self.tv,2)
end

function friendGiftDialog:init()
    self.bgLayer=CCLayer:create()
    self:doUserHandler()
    self:initTableView()
    return self.bgLayer
end

function friendGiftDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return #friendInfoVo.friendTb
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth-40,105)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        self:initCell(idx,cell)
        cell:autorelease()
        return cell
    elseif fn=="ccTouchBegan" then
    elseif fn=="ccTouchMoved" then
    elseif fn=="ccScrollEnable" then
    end
end


function friendGiftDialog:initCell(idx,cell)

    local tempSize = CCSizeMake(G_VisibleSizeWidth-40,105)
    cell:setContentSize(tempSize)

    local function sendGiftCallback( ... )
        local sendRequestList = {}
        table.insert(sendRequestList,friendInfoVo.friendTb[idx+1].uid)
        local function callback(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret == true then
                friendInfoVoApi:updateSendStatus(friendInfoVo.friendTb[idx+1].uid,1)
                self.gitfBtnList[idx+1]:setEnabled(false)
                self:updateStatus()
                self.tv:reloadData()
                self:flushButton()
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_giftSendSuccess"),30)
            end
        end
        socketHelper:sendFriendGift(sendRequestList,callback)
    end
    local function receiveCallback( ... )
        if friendInfoVoApi:getGiftNum()+1 > self.limit then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_err_12010"),30)
        else
            local sendRequestList = {}
            table.insert(sendRequestList,friendInfoVo.friendTb[idx+1].uid)
            local function callback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret == true then 
                    if sData.data.friends.rgift and sData.data.reward then
                        local rewardlist = FormatItem(sData.data.reward,nil,true)
                        G_showRewardTip(rewardlist,true)
                        for k,v in pairs(rewardlist) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)  
                        end
                        friendInfoVoApi:updateReceiveStatus(friendInfoVo.friendTb[idx+1].uid,2)
                        self:updateStatus()
                        self.tv:reloadData()
                        self:flushButton()
                        self:updateStr()
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_giftGetSuccess"),30)
                    end
                end
            end
            socketHelper:getFriendNewGift(sendRequestList,callback)
        end
    end
    local sendGiftButton = G_createBotton(cell,ccp((G_VisibleSizeWidth-40)/3*2+80,cell:getContentSize().height/2),nil,"yh_taskReward.png","yh_taskReward_down.png","yh_taskReward.png",sendGiftCallback,1,-(self.layerNum-1)*20-2)
    self.gitfBtnList[idx+1] = sendGiftButton
    if self.sendStatusTb[idx+1] == 1 then
        -- 我已经送过对方礼物
        sendGiftButton:setEnabled(false)
    end
    if self.receiveStatusTb[idx+1] == 0 then
        -- 对方未送我礼物
        local unSendSp = GraySprite:createWithSpriteFrameName("fr_unGet.png")
        unSendSp:setAnchorPoint(ccp(0.5,0.5))
        unSendSp:setPosition(ccp((G_VisibleSizeWidth-40)/3*2+150,cell:getContentSize().height/2))
        cell:addChild(unSendSp)
    elseif self.receiveStatusTb[idx+1] == 1 then
        -- 对方送我礼物我未领取
        local sendButUnReceiveSp = LuaCCSprite:createWithSpriteFrameName("fr_unGet.png",receiveCallback)
        sendButUnReceiveSp:setTouchPriority(-(self.layerNum-1)*20-2)
        sendButUnReceiveSp:setAnchorPoint(ccp(0.5,0.5))
        sendButUnReceiveSp:setPosition(ccp((G_VisibleSizeWidth-40)/3*2+150,cell:getContentSize().height/2))
        self:giftAction(sendButUnReceiveSp)
        cell:addChild(sendButUnReceiveSp)
    elseif self.receiveStatusTb[idx+1] == 2 then
        -- 对方送我礼物我已领取
        local sendAndReceiveSp = GraySprite:createWithSpriteFrameName("fr_get.png")
        sendAndReceiveSp:setAnchorPoint(ccp(0.5,0.5))
        sendAndReceiveSp:setPosition(ccp((G_VisibleSizeWidth-40)/3*2+150,cell:getContentSize().height/2))
        cell:addChild(sendAndReceiveSp)
    end
    -- 军衔
    local rankStr = playerVoApi:getRankIconName(tonumber(friendInfoVo.friendTb[idx+1].rank))
    local mIcon=CCSprite:createWithSpriteFrameName(rankStr)
    mIcon:setScale(65/mIcon:getContentSize().width)
    mIcon:setAnchorPoint(ccp(0,0.5))
    mIcon:setPosition(ccp(15,cell:getContentSize().height/2))   
    cell:addChild(mIcon)
    -- 头像和头像框
    local function playerDetail( ... )

        local function sendEmailCallback( ... )
            if friendInfoVo and friendInfoVo.friendTb and friendInfoVo.friendTb[idx+1] then
                require "luascript/script/game/scene/gamedialog/emailDetailDialog"
                emailVoApi:showWriteEmailDialog(self.layerNum+1,getlocal("email_write"),friendInfoVo.friendTb[idx+1].nickname,nil,nil,nil,nil,friendInfoVo.friendTb[idx+1].uid)
            end
        end
        local function chatCallback( ... )
            chatVoApi:showChatDialog(self.layerNum+1,nil,friendInfoVo.friendTb[idx+1].uid,friendInfoVo.friendTb[idx+1].nickname,true)
        end

        -- 加入黑名单
        local function  shieldCallback()
            do return end
        end
        local function nilfunc( ... )
            self.tv:reloadData()
        end
        local nameContent = friendInfoVo.friendTb[idx+1].nickname
        local levelContent = getlocal("alliance_info_level").." Lv."..friendInfoVo.friendTb[idx+1].level
        local fcContent=getlocal("player_message_info_power")..": "..FormatNumber(tonumber(friendInfoVo.friendTb[idx+1].fc))
        local allianceContent
        if friendInfoVo.friendTb[idx+1].alliancename then
            allianceContent=getlocal("player_message_info_alliance")..": "..friendInfoVo.friendTb[idx+1].alliancename
        else
            allianceContent=getlocal("player_message_info_alliance")..": "..getlocal("alliance_info_content")
        end
        local content={{nameContent,28,G_ColorYellowPro},{levelContent,22},{fcContent,22},{allianceContent,27}}

        local vipPicStr = nil
        -- 日本平台特殊处理，不展示VIP的具体等级
        local isShowVip = chatVoApi:isJapanV()
        if friendInfoVo.friendTb[idx+1].vip then
            if isShowVip then
                vipPicStr = "vipNoLevel.png"
            else
                vipPicStr = "Vip"..friendInfoVo.friendTb[idx+1].vip..".png"
            end
        end
        smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png",CCSizeMake(550,530),nil,CCRect(170,80,22,10),"email",sendEmailCallback,"chat",chatCallback,getlocal("player_message_info_title"),content,nil,self.layerNum+1,1,nil,nil,nil,friendInfoVo.friendTb[idx+1].pic,getlocal("shield"),shieldCallback,getlocal("delFriend"),nilfunc,friendInfoVo.friendTb[idx+1].rank,nil,nil,friendInfoVo.friendTb[idx+1].title,friendInfoVo.friendTb[idx+1].nickname,vipPicStr,nil,nil,friendInfoVo.friendTb[idx+1].bpic,friendInfoVo.friendTb[idx+1].uid)
        do return end
    end 
    local personPhotoName=playerVoApi:getPersonPhotoName(friendInfoVo.friendTb[idx+1].pic)
    local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName,playerDetail,nil,nil,nil,friendInfoVo.friendTb[idx+1].bpic)
    playerPic:setAnchorPoint(ccp(0,0.5))
    playerPic:setTouchPriority(-(self.layerNum-1)*20-2)
    playerPic:setScale(85/playerPic:getContentSize().width)
    playerPic:setPosition(ccp(15+65+15,cell:getContentSize().height/2))
    cell:addChild(playerPic)

    -- 等级黑条
    local levelBg = LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
    levelBg:setRotation(180)
    levelBg:setContentSize(CCSizeMake(70,20))
    levelBg:setAnchorPoint(ccp(0.5,0))
    levelBg:setPosition(ccp(playerPic:getContentSize().width/2,25))
    playerPic:addChild(levelBg)
    
    -- 等级
    local levelStr=friendInfoVo.friendTb[idx+1].level
    local levelLabel=GetTTFLabelWrap(getlocal("fightLevel",{levelStr}),20,CCSizeMake(70,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
    levelLabel:setAnchorPoint(ccp(0.5,0))
    levelLabel:setPosition(playerPic:getContentSize().width/2,2)
    playerPic:addChild(levelLabel)

    -- 玩儿家名称
    local nameStr=friendInfoVo.friendTb[idx+1].nickname
    local nameLabel=GetTTFLabel(nameStr,24,true)
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(15+65+15+85+10,cell:getContentSize().height/3*2)
    cell:addChild(nameLabel)

    -- 战斗力
    local tankSp=CCSprite:createWithSpriteFrameName("ltzdzTankFight.png")
    tankSp:setAnchorPoint(ccp(0,0.5))
    tankSp:setScale(1.2)
    tankSp:setPosition(15+65+15+85+10,cell:getContentSize().height/3)
    cell:addChild(tankSp)

    local valueStr=friendInfoVo.friendTb[idx+1].fc
    local valueLabel=GetTTFLabelWrap(FormatNumber(tonumber(valueStr)),24,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    valueLabel:setAnchorPoint(ccp(0,0.5))
    valueLabel:setPosition(15+65+15+85+20+tankSp:getContentSize().width*1.2,cell:getContentSize().height/3)
    cell:addChild(valueLabel)
    
    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
    lineSp:setAnchorPoint(ccp(0.5,0))
    lineSp:setPosition(ccp(cell:getContentSize().width/2,0))
    lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-70,2))
    cell:addChild(lineSp)
end

-- 更新礼物赠送状态接收列表
function friendGiftDialog:updateStatus( ... )
    self.sendStatusTb = friendInfoVoApi:getSendStatus()
    self.receiveStatusTb = friendInfoVoApi:getReceiveStatus()
end

function friendGiftDialog:tick( ... )
    self:updateStatus()
    self:flushButton()
    self:updateStr()
    if friendInfoVo.friendGiftFlag == 1 then
        friendInfoVo.friendGiftFlag = 0
        self:updateStatus()
        self:flushButton()
        self:updateStr()
        self.tv:reloadData()
    end
end

function friendGiftDialog:flushButton( ... )
 
    if friendInfoVoApi:isHasUnreceiveNum() == false then
        self.acceptGiftButton:setEnabled(false)
    else
        self.acceptGiftButton:setEnabled(true)
    end
    if friendInfoVoApi:getUnSendNum() == 0 then
        self.sendGiftButton:setEnabled(false)
    else
        self.sendGiftButton:setEnabled(true)
    end
end

function friendGiftDialog:updateStr( ... )
    self.tipLabel:setString(getlocal("friend_newSys_desc2",{friendInfoVoApi:getGiftNum(),self.limit}))
    if #friendInfoVo.friendTb == 0 then
        self.noFriendLabel:setVisible(true)
    else
        self.noFriendLabel:setVisible(false)
    end
end

function friendGiftDialog:giftAction(giftSp)

    local acArr=CCArray:create()
    local time = 0.14
    local leftRotate=CCRotateTo:create(time,30)
    local rightRotate=CCRotateTo:create(time,-30)
    local leftRotate1=CCRotateTo:create(time,20)
    local rightRotate1=CCRotateTo:create(time,-20)
    local midRotate=CCRotateTo:create(time,0)
    local delay=CCDelayTime:create(1)

    acArr:addObject(leftRotate)
    acArr:addObject(rightRotate)
    acArr:addObject(leftRotate1)
    acArr:addObject(rightRotate1)
    acArr:addObject(midRotate)
    acArr:addObject(delay)
    local giftRotate = CCSequence:create(acArr)
    local giftRepeat = CCRepeatForever:create(giftRotate)
    tolua.cast(giftSp,"LuaCCSprite"):runAction(giftRepeat)
end

function friendGiftDialog:dispose( ... )

end

