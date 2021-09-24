-- @Author hj
-- @Description 好友系统改版第三个页签屏蔽列表
-- @Date 2018-04-18

friendShieldDialog = {}

function friendShieldDialog:new(layer)
    local nc = {
        layerNum = layer,
        limit = G_blackListNum
    }
    setmetatable(nc,self)
    self.__index = self
    return nc
end

function friendShieldDialog:doUserHandler( ... )
    
    local tipLabel = GetTTFLabel(getlocal("friend_newSys_shield_desc",{#friendInfoVo.shieldTb,self.limit}),25)
    self.bgLayer:addChild(tipLabel)
    tipLabel:setAnchorPoint(ccp(0,0))
    tipLabel:setPosition(ccp(25,80))
    self.tipLabel = tipLabel

    local noShieldLabel = GetTTFLabel(getlocal("friend_newSys_shield_tip"),25)
    self.bgLayer:addChild(noShieldLabel,3)
    noShieldLabel:setAnchorPoint(ccp(0.5,0.5))
    noShieldLabel:setPosition(ccp(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-158-120)/2+120))
    noShieldLabel:setColor(G_ColorGray)
    if #friendInfoVo.shieldTb == 0 then
        noShieldLabel:setVisible(true)
    else
        noShieldLabel:setVisible(false)
    end
    self.noShieldLabel = noShieldLabel

    -- 一键删除
    local function allDeleteCallBack( ... )

    local function confirmHandler( ... )
        local function callBack( ... )
            self.tv:reloadData()
        end
        local requestList = {}
        for k,v in pairs(friendInfoVo.shieldTb) do
            table.insert(requestList,v.uid)
        end
        G_removeMemberInBlackListByUid(requestList,callBack,true)
    end
    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("friend_newSys_delshieldAllConfirm"),false,confirmHandler)
    end


    -- 查找玩家
    local function searchCallback( ...  )
        require "luascript/script/game/scene/gamedialog/friendInfo/friendInfoSmallDialog"
        friendInfoSmallDialog:showResearchDialog("newSmallPanelBg",CCSizeMake(550,600),CCRect(170,80,22,10),nil,getlocal("friend_newSys_shield_b2"),30,self.layerNum+1,self.tv,"shield")
    end

    local strSize = 25
    if G_isAsia() == false then
        strSize = 20
    end
    local deleteButton = G_createBotton(self.bgLayer,ccp((G_VisibleSizeWidth-40)/3+20-30,45),{getlocal("friend_newSys_shield_b1"),strSize},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",allDeleteCallBack,0.8,-(self.layerNum-1)*20-4)
    self.deleteButton = deleteButton
    local searchButton = G_createBotton(self.bgLayer,ccp((G_VisibleSizeWidth-40)/3*2+20+30,45),{getlocal("friend_newSys_shield_b2"),strSize},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",searchCallback,0.8,-(self.layerNum-1)*20-4)

    self.tipLabel:setString(getlocal("friend_newSys_shield_desc",{#friendInfoVo.shieldTb,self.limit}))
    if #friendInfoVo.shieldTb == 0 then
        self.deleteButton:setEnabled(false)
    else
        self.deleteButton:setEnabled(true)
    end

end

function friendShieldDialog:initTableView( ... )

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

function friendShieldDialog:init()
    self.bgLayer=CCLayer:create()
    self:doUserHandler()
    self:initTableView()
    return self.bgLayer
end

function friendShieldDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return #friendInfoVo.shieldTb
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

function friendShieldDialog:initCell(idx,cell)

    local tempSize = CCSizeMake(G_VisibleSizeWidth-40,105)
    cell:setContentSize(tempSize)
    local function deleteCallBack( ... )
        local function confirmHandler( ... )
            local function callBack( ... )
                self.tv:reloadData()
            end
            G_removeMemberInBlackListByUid(friendInfoVo.shieldTb[idx+1].uid,callBack)
        end
    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("friend_newSys_delshieldConfirm"),false,confirmHandler) 
    end
    -- 删除屏蔽按钮
    local deleteShield = G_createBotton(cell,ccp((G_VisibleSizeWidth-40)/3*2+150,cell:getContentSize().height/2),nil,"yh_BtnNo.png","yh_BtnNo_Down.png","yh_BtnNo.png",deleteCallBack,1,-(self.layerNum-1)*20-2)

    -- 军衔
    local rankStr = playerVoApi:getRankIconName(tonumber(friendInfoVo.shieldTb[idx+1].rank))
    local mIcon=CCSprite:createWithSpriteFrameName(rankStr)
    mIcon:setScale(65/mIcon:getContentSize().width)
    mIcon:setAnchorPoint(ccp(0,0.5))
    mIcon:setPosition(ccp(15,cell:getContentSize().height/2))   
    cell:addChild(mIcon)
    -- 头像和头像框
    local function playerDetail( ... )
        
        local function nilfunc( ... )
            self.tv:reloadData()
        end
        local function sendEmailCallback( ... )
            if friendInfoVo and friendInfoVo.shieldTb and friendInfoVo.shieldTb[idx+1] then
                require "luascript/script/game/scene/gamedialog/emailDetailDialog"
                emailVoApi:showWriteEmailDialog(self.layerNum+1,getlocal("email_write"),friendInfoVo.shieldTb[idx+1].nickname,nil,nil,nil,nil,friendInfoVo.shieldTb[idx+1].uid)
            end
        end
        local function chatCallback( ... )
            chatVoApi:showChatDialog(self.layerNum+1,nil,friendInfoVo.shieldTb[idx+1].uid,friendInfoVo.shieldTb[idx+1].nickname,true)
        end
        local nameContent = friendInfoVo.shieldTb[idx+1].nickname
        local levelContent = getlocal("alliance_info_level").." Lv."..friendInfoVo.shieldTb[idx+1].level
        local fcContent=getlocal("player_message_info_power")..": "..FormatNumber(tonumber(friendInfoVo.shieldTb[idx+1].fc))
        local allianceContent
        if friendInfoVo.shieldTb[idx+1].alliancename then
            allianceContent=getlocal("player_message_info_alliance")..": "..friendInfoVo.shieldTb[idx+1].alliancename
        else
            allianceContent=getlocal("player_message_info_alliance")..": "..getlocal("alliance_info_content")
        end
        local content={{nameContent,28,G_ColorYellowPro},{levelContent,22},{fcContent,22},{allianceContent,27}}

        local vipPicStr = nil
        -- 日本平台特殊处理，不展示VIP的具体等级
        local isShowVip = chatVoApi:isJapanV()
        if friendInfoVo.shieldTb[idx+1].vip then
            if isShowVip then
                vipPicStr = "vipNoLevel.png"
            else
                vipPicStr = "Vip"..friendInfoVo.shieldTb[idx+1].vip..".png"
            end
        end
        local function shieldCallback( ... )
            -- body
        end
        smallDialog:showPlayerInfoSmallDialog("newSmallPanelBg.png",CCSizeMake(550,530),nil,CCRect(170,80,22,10),"email",sendEmailCallback,"chat",chatCallback,getlocal("player_message_info_title"),content,nil,self.layerNum+1,1,nil,nil,nil,friendInfoVo.shieldTb[idx+1].pic,getlocal("shield"),shieldCallback,getlocal("delFriend"),nilfunc,friendInfoVo.shieldTb[idx+1].rank,nil,nil,friendInfoVo.shieldTb[idx+1].title,friendInfoVo.shieldTb[idx+1].nickname,vipPicStr,nil,nil,friendInfoVo.shieldTb[idx+1].bpic,friendInfoVo.shieldTb[idx+1].uid)
        do return end
    end 
    local personPhotoName=playerVoApi:getPersonPhotoName(friendInfoVo.shieldTb[idx+1].pic)
    local playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName,playerDetail,nil,nil,nil,friendInfoVo.shieldTb[idx+1].bpic)
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
    local levelStr=friendInfoVo.shieldTb[idx+1].level
    local levelLabel=GetTTFLabelWrap(getlocal("fightLevel",{levelStr}),20,CCSizeMake(70,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
    levelLabel:setAnchorPoint(ccp(0.5,0))
    levelLabel:setPosition(playerPic:getContentSize().width/2,2)
    playerPic:addChild(levelLabel)

    -- 玩儿家名称
    local nameStr=friendInfoVo.shieldTb[idx+1].nickname
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

    local valueStr=friendInfoVo.shieldTb[idx+1].fc
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

function friendShieldDialog:tick( ... )
    self.tipLabel:setString(getlocal("friend_newSys_shield_desc",{#friendInfoVo.shieldTb,self.limit}))
    if #friendInfoVo.shieldTb == 0 then
        self.deleteButton:setEnabled(false)
    else
        self.deleteButton:setEnabled(true)
    end
     if #friendInfoVo.shieldTb == 0 then
        self.noShieldLabel:setVisible(true)
    else
        self.noShieldLabel:setVisible(false)
    end
end

function friendShieldDialog:dispose( ... )
end

