-- Filename：	TeamGroupCell.lua
-- Author：		zhz
-- Date：		2013-2-17
-- Purpose：		

module("TeamGroupCell", package.seeall)

require "script/ui/teamGroup/TeamGroupData"
require "script/ui/hero/HeroPublicCC"
require "script/ui/teamGroup/TeamGruopService"
require "script/model/user/UserModel"

local _touchProperty= nil

-- 加入按钮得回调函数
local function joinMenuAction( tag , item )
	print("tag is : ",tag )
	require "script/ui/teamGroup/TeamGroupLayer"
	TeamGruopService.joinTeam( TeamGroupLayer.rfcAftJoin , tonumber(tag))
	
end

-- 开战的按钮
local function startAction( tag, item)

	require "script/ui/teamGroup/TeamGroupLayer"
	TeamGruopService.start(TeamGroupLayer.closeCb,tonumber(tag) )
end

-- 踢人
local function kickAction( tag, item )
	TeamGruopService.kick(nil , tonumber(tag) )
end

local function addFriendCb( tag, item)
	local uid = tonumber(tag)
	if(uid== UserModel.getUserUid()) then
		return
	end

	local memberInfo = TeamGroupData.getMemberInfoByUid(uid)
	local htid =  memberInfo.utid 
	local uname =  memberInfo.uname
	local power =  memberInfo.fightForce
	local ulevel =  memberInfo.level or 0
	local dressId =  memberInfo.dressId
	local vip = memberInfo.vip or 0
	require "script/ui/guild/AddAndChat"
    require "script/model/utils/HeroUtil"
    local heroIcon = HeroUtil.getHeroIconByHTID(htid, dressId ,nil ,vip)
    AddAndChat.showAddAndChatLayer(uname,ulevel,power,heroIcon,uid, nil, 1200)
end



--groupType:1表示创建队伍界面，2表示队长开战(即玩家为队长)，3表示加入队伍（玩家为队员）界面
function createCell( cellValues, index , cellNum,groupType, touchPriority)
	local tCell = CCTableViewCell:create()

	local fullRect = CCRectMake(0, 0, 578, 158)
    local insetRect = CCRectMake(100, 60, 10, 10)

    local nameBgFile= nil 

	local cellBg= nil --CCSprite:create("images/common/team_bg.png")
	if(groupType ==1  ) then
		cellBg= CCScale9Sprite:create("images/copy/guildcopy/team_frame_1.png",fullRect, insetRect )
		nameBgFile= "images/common/bg/bg_9s_red.png"
	elseif(groupType~= 1 and index==1) then
		cellBg= CCScale9Sprite:create("images/copy/guildcopy/team_frame_3.png",fullRect, insetRect )
		nameBgFile= "images/common/bg/bg_9s_blue.png"
	elseif(groupType~=1 and index>1) then
		cellBg= CCScale9Sprite:create("images/copy/guildcopy/team_frame_4.png", fullRect, insetRect )
		nameBgFile= "images/common/bg/bg_9s_blue.png"
	else
		cellBg= CCScale9Sprite:create("images/copy/guildcopy/team_frame_2.png",fullRect, insetRect )
		nameBgFile= "images/common/bg/bg_9s_red.png"
	end
	--cellBg:setPreferredSize(CCSizeMake(578,170) )
	cellBg:setPreferredSize(CCSizeMake(578,213) )

	tCell:addChild(cellBg)

	local nameBg1 = CCScale9Sprite:create(nameBgFile)
	nameBg1:setContentSize(CCSizeMake( 301, 33))
	nameBg1:setPosition(120, 118)
	nameBg1:setAnchorPoint(ccp(0,0))
	cellBg:addChild(nameBg1)

	local nameBg2= CCScale9Sprite:create(nameBgFile)
	nameBg2:setContentSize(CCSizeMake( 301, 33))
	nameBg2:setPosition(120, 77)
	nameBg2:setAnchorPoint(ccp(0,0))
	cellBg:addChild(nameBg2)

	local nameBg3 = CCScale9Sprite:create(nameBgFile)
	nameBg3:setContentSize(CCSizeMake( 301, 33))
	nameBg3:setPosition(120, 36)
	nameBg3:setAnchorPoint(ccp(0,0))
	cellBg:addChild(nameBg3)


	local nameStr= nil
	local htid = nil
	local level = nil
	local dressId= nil
	local fightForce= nil
	local guildName= nil
	local limitNum = nil
	local uid = nil
	local headIco= nil
	local vip = nil 
	if(groupType ==1 ) then
		nameStr = cellValues.members[1].uname
		htid = tonumber(cellValues.members[1].utid)
		dressId= tonumber(cellValues.members[1].dressId)
		level= cellValues.members[1].level
		fightForce = cellValues.members[1].fightForce
		limitNum= table.count(cellValues.members)
		uid = cellValues.members[1].uid
		guildName= cellValues.members[1].guildName
		vip = cellValues.members[1].vip or 0
	else
		nameStr = cellValues.uname
		htid = tonumber(cellValues.utid )
		dressId= tonumber(cellValues.dressId)
		level= cellValues.level
		fightForce= cellValues.fightForce
		uid= cellValues.uid
		guildName= cellValues.guildName
		vip = cellValues.vip or 0
	end	

	if( groupType == 2 or groupType== 3) then
		-- 队伍中第几号位
		local indexSp = CCSprite:create("images/common/round.png")
		indexSp:setPosition(0, cellBg:getContentSize().height)
		indexSp:setAnchorPoint(ccp(0.1,1))
		cellBg:addChild(indexSp,12)
		local indexLabel = CCRenderLabel:create("" .. index, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		indexLabel:setColor(ccc3(0xff,0xff,0xff))
		indexLabel:setAnchorPoint(ccp(0.5,0.5))
		indexLabel:setPosition(ccp(indexSp:getContentSize().width/2, indexSp:getContentSize().height/2 ))
		indexSp:addChild(indexLabel)
	end

	if(groupType ==1 ) then
		local titleLabel = CCRenderLabel:create( nameStr .. GetLocalizeStringBy("key_2190"), g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		titleLabel:setColor(ccc3(0xff,0xff,0xff))
		titleLabel:setAnchorPoint(ccp(0.5,1))
		titleLabel:setPosition(cellBg:getContentSize().width/2, cellBg:getContentSize().height-6)
		cellBg:addChild(titleLabel)
	end

	if( groupType~= 1 and index==1) then
		local titleLabel = CCRenderLabel:create( nameStr .. "", g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		titleLabel:setColor(ccc3(0xff,0xff,0xff))
		-- 
		local numLabel= CCLabelTTF:create(GetLocalizeStringBy("key_1161") .. cellNum .. "/" .. TeamGroupData.getCopyInfo().max , g_sFontName, 23)
		numLabel:setColor(ccc3(0x00,0xff,0x18))
		local titleNode= BaseUI.createHorizontalNode({titleLabel, numLabel})
		titleNode:setAnchorPoint(ccp(0.5,1))
		titleNode:setPosition(cellBg:getContentSize().width/2, cellBg:getContentSize().height-6)
		cellBg:addChild(titleNode)
	end

	local menuBar= CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(touchPriority)
	cellBg:addChild(menuBar)
	_touchProperty= touchPriority
	-- 头像
	-- local headIcon = HeroUtil.getHeroIconByHTID(htid , dressId) 

	-- if(groupType ==1) then

	-- local headItem = CCMenItemSprite:create(headIcon,headIcon)
	-- headItem:setPosition(9,25)
	-- menuBar:addChild(headIcon,1,uid)

	-- 名字
	local nameLabel = CCRenderLabel:create( nameStr , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setPosition(139,122)
	nameLabel:setAnchorPoint(ccp(0,0))
	cellBg:addChild(nameLabel)

	-- 军团名
	if(guildName ) then
		local guildNameLabel = CCRenderLabel:create( " [" .. guildName .. "]" , g_sFontName, 24,1, ccc3(0x00,0x00,0x00), type_stroke)
		guildNameLabel:setColor(ccc3(0xff,0xf6,0x00) )
		guildNameLabel:setPosition(ccp(139, 81))
		guildNameLabel:setAnchorPoint(ccp(0,0))
		cellBg:addChild(guildNameLabel)
	end


	-- 战斗力
	if(groupType ==2 or groupType==3) then

		local fightSp= CCSprite:create("images/common/fight_value.png")
		local fightForceLabel = CCRenderLabel:create(tostring(fightForce) , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		fightForceLabel:setColor(ccc3(0x00,0xff,0x18))
		local fightNode= BaseUI.createHorizontalNode({fightSp,fightForceLabel})
		fightNode:setPosition(139,36)
		fightNode:setAnchorPoint(ccp(0,0))
		cellBg:addChild(fightNode)

		local headSprite = HeroUtil.getHeroIconByHTID(htid , dressId, nil , vip ) 
		headIcon = CCMenuItemSprite:create(headSprite,headSprite)
		headIcon:setPosition(9,57)
		headIcon:registerScriptTapHandler(addFriendCb)
		menuBar:addChild(headIcon,1,uid)
	end

	if(groupType ==1) then
		local limitNumLabel = CCRenderLabel:create( GetLocalizeStringBy("key_2339") .. tostring(limitNum) .. "/" .. TeamGroupData.getCopyInfo().max  , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		limitNumLabel:setPosition(139,41)
		limitNumLabel:setColor(ccc3(0x00,0xff,0x18))
		limitNumLabel:setAnchorPoint(ccp(0,0))
		cellBg:addChild(limitNumLabel)

		-- 
		headIcon = HeroUtil.getHeroIconByHTID(htid, dressId,nil,vip ) 
		headIcon:setPosition(9,57)
		cellBg:addChild(headIcon)
	end


	-- 等级
	local lvSp= CCSprite:create("images/common/lv.png")
	local levelLabel = CCRenderLabel:create(tostring(level),  g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	levelLabel:setColor(ccc3(0xff,0xf6,0x00))
	local levelNode =BaseUI.createHorizontalNode({lvSp,levelLabel})
	levelNode:setPosition(headIcon:getContentSize().width/2 ,2)
	levelNode:setAnchorPoint(ccp(0.5,1))
	headIcon:addChild(levelNode)


	if( groupType==1) then
		local teamId= tonumber(cellValues.members[1].uid)
		print(" teamId is : ", teamId)
		local joinBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue2_n.png","images/common/btn/btn_blue2_h.png",CCSizeMake(119,83),GetLocalizeStringBy("key_1627"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		joinBtn:setPosition(445, 58)
		menuBar:addChild(joinBtn,1,teamId)
		joinBtn:registerScriptTapHandler(joinMenuAction)
	elseif(groupType == 2) then
		
		if(cellValues.uid == TeamGroupData.getLeaderId() ) then
			local startBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red2_n.png","images/common/btn/btn_red2_h.png",CCSizeMake(119,83),GetLocalizeStringBy("key_2563"),ccc3(0xfe, 0xdb, 0x1c),32,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			menuBar:addChild(startBtn,1, cellValues.uid)
			startBtn:registerScriptTapHandler(startAction)
			startBtn:setPosition(445, 58)

		else
			local kickBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue2_n.png","images/common/btn/btn_blue2_h.png",CCSizeMake(119,83),GetLocalizeStringBy("key_1410"),ccc3(0xfe, 0xdb, 0x1c),32,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			menuBar:addChild(kickBtn,1, cellValues.uid)
			kickBtn:registerScriptTapHandler(kickAction)
			kickBtn:setPosition(445, 58)
		end
	elseif(groupType == 3) then
		if(tonumber(cellValues.uid) == TeamGroupData.getOwnTeamId()) then
			-- local waitBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_grey.png","images/common/btn/btn_grey.png",CCSizeMake(160,83),GetLocalizeStringBy("key_3034"),ccc3(0xfe, 0xdb, 0x1c),32,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			-- menuBar:addChild(waitBtn,1)
			-- waitBtn:setPosition(410, 38)
			local waitGraySp = BTGraySprite:create("images/common/btn/btn_grey.png")
			waitGraySp:setPosition(408, 58)
			cellBg:addChild(waitGraySp)
			local waitLabel= CCRenderLabel:create(GetLocalizeStringBy("key_3034"), g_sFontPangWa , 32, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			waitLabel:setAnchorPoint(ccp(0.5,0.5))
			waitLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
			waitLabel:setPosition(waitGraySp:getContentSize().width/2, waitGraySp:getContentSize().height/2)
			waitGraySp:addChild(waitLabel)
		end

	else
		print(" error , groupType is ", groupType)	
		
	end
	return tCell
end




