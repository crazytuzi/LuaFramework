-- @Author hj
-- @Description 好友系统改版第一个页签好友列表
-- @Date 2018-04-18

friendListDialog = {}

function friendListDialog:new(layer)
	local nc = {
		layerNum = layer,
		limit = friendInfoVoApi:getfriendCfg(2)
	}
	setmetatable(nc,self)
	self.__index = self
	return nc
end

function friendListDialog:doUserHandler( ... )
	
	local tipLabel = GetTTFLabel(getlocal("friend_newSys_desc1",{#friendInfoVo.friendTb,self.limit}),25)
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

	-- 申请列表
	local function applyCallback( ... )
		require "luascript/script/game/scene/gamedialog/friendInfo/friendInfoSmallDialog"
		friendInfoSmallDialog:showApplyListDialog("newSmallPanelBg",CCSizeMake(550,600),CCRect(170,80,22,10),nil,getlocal("friend_newSys_list_b1"),30,self.layerNum+1,self.tv)
	end

	-- 添加好友
	local function addFriendCallback( ... )
		require "luascript/script/game/scene/gamedialog/friendInfo/friendInfoSmallDialog"
		friendInfoSmallDialog:showResearchDialog("newSmallPanelBg",CCSizeMake(550,600),CCRect(170,80,22,10),nil,getlocal("addFriends_title"),30,self.layerNum+1,self.tv,"add")
	end
	local strSize = 25
	if G_isAsia() == false then
		strSize = 20
	end
    local applyButton = G_createBotton(self.bgLayer,ccp((G_VisibleSizeWidth-40)/3+20-30,45),{getlocal("friend_newSys_list_b1"),strSize},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",applyCallback,0.8,-(self.layerNum-1)*20-4)
    local addFriendButton = G_createBotton(self.bgLayer,ccp((G_VisibleSizeWidth-40)/3*2+20+30,45),{getlocal("addFriends_title"),strSize},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",addFriendCallback,0.8,-(self.layerNum-1)*20-4)

    local function touchClick( ... )
    	do return end
    end 
	local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17, 17, 1, 1),touchClick)
	newsIcon:setContentSize(CCSizeMake(36,36))
	newsIcon:ignoreAnchorPointForPosition(false)
	newsIcon:setAnchorPoint(ccp(1,0.5))
	newsIcon:setPosition(ccp((G_VisibleSizeWidth-40)/3+80,72))
	newsIcon:setVisible(false)
	newsIcon:setScale(0.7)
	self.bgLayer:addChild (newsIcon)
	self.newsIcon = newsIcon
	self:refreshRedPoint()
end

function friendListDialog:initTableView( ... )

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

function friendListDialog:init()
	self.bgLayer=CCLayer:create()
	self:doUserHandler()
	self:initTableView()
	return self.bgLayer
end

function friendListDialog:eventHandler(handler,fn,idx,cel)
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

function friendListDialog:initCell(idx,cell)
	local tempSize = CCSizeMake(G_VisibleSizeWidth-40,105)
	cell:setContentSize(tempSize)

	local function sendEmailCallback( ... )
		if friendInfoVo and friendInfoVo.friendTb and friendInfoVo.friendTb[idx+1] then
			require "luascript/script/game/scene/gamedialog/emailDetailDialog"
		    emailVoApi:showWriteEmailDialog(self.layerNum+1,getlocal("email_write"),friendInfoVo.friendTb[idx+1].nickname,nil,nil,nil,nil,friendInfoVo.friendTb[idx+1].uid)
		end
	end
	local function chatCallback( ... )
      	chatVoApi:showChatDialog(self.layerNum+1,nil,friendInfoVo.friendTb[idx+1].uid,friendInfoVo.friendTb[idx+1].nickname,true)
	end
	-- 邮件按钮
    local emailButton = G_createBotton(cell,ccp((G_VisibleSizeWidth-40)/3*2+80,cell:getContentSize().height/2),nil,"emailToPlayer_2.png","emailToPlayer_1.png","emailToPlayer_2.png",sendEmailCallback,1,-(self.layerNum-1)*20-2)
   
    local touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,5,5), chatCallback)
   	touchSp:setContentSize(CCSizeMake(90,105))
	cell:addChild(touchSp)
	touchSp:setAnchorPoint(ccp(1,1))
	touchSp:setPosition(ccp(cell:getContentSize().width,cell:getContentSize().height))
	touchSp:setTouchPriority(-(self.layerNum-1)*20-1)
	touchSp:setVisible(false)

    -- 聊天按钮
    local chatButton = G_createBotton(cell,ccp((G_VisibleSizeWidth-40)/3*2+150,cell:getContentSize().height/2),nil,"newChatBtn.png","newChatBtn_Down.png","newChatBtn.png",chatCallback,1,-(self.layerNum-1)*20-2)
	-- 军衔
 	local rankStr = playerVoApi:getRankIconName(tonumber(friendInfoVo.friendTb[idx+1].rank))
	local mIcon=CCSprite:createWithSpriteFrameName(rankStr)
    mIcon:setScale(65/mIcon:getContentSize().width)
    mIcon:setAnchorPoint(ccp(0,0.5))
    mIcon:setPosition(ccp(15,cell:getContentSize().height/2))	
    cell:addChild(mIcon)
    -- 头像和头像框
    local function playerDetail( ... )

    	-- 加入黑名单
		local function 	shieldCallback()
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
	
	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
	lineSp:setAnchorPoint(ccp(0.5,0))
	lineSp:setPosition(ccp(cell:getContentSize().width/2,0))
	lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-70,2))
	cell:addChild(lineSp)
end

function friendListDialog:tick( ... )
	self.tipLabel:setString(getlocal("friend_newSys_desc1",{#friendInfoVo.friendTb,self.limit}))
	if #friendInfoVo.friendTb == 0 then
		self.noFriendLabel:setVisible(true)
	else
		self.noFriendLabel:setVisible(false)
	end
	if friendInfoVo.friendChanegFlag == 1 then
		self.tv:reloadData()
		friendInfoVo.friendChanegFlag = 0
	end
	self:refreshRedPoint()
end

function friendListDialog:refreshRedPoint( ... )
	if friendInfoVoApi:isHasInvite() == true then
		self.newsIcon:setVisible(true)
	else
		self.newsIcon:setVisible(false)
	end
end

function friendListDialog:dispose( ... )
end

