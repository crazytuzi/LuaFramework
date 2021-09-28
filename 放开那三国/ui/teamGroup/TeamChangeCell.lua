-- Filename：	TeamChangeCell.lua
-- Author：		zhz
-- Date：		2013-2-19
-- Purpose：		组队得网络层

module("TeamChangeCell", package.seeall)

require "script/utils/BaseUI"
require "script/ui/teamGroup/TeamGruopService"
require "script/ui/teamGroup/TeamGroupData"
require "script/ui/teamGroup/TeamGroupLayer"

local function upAction( tag, item)


	local targetIndex= tonumber(tag)-1
	local sourceIndex= tonumber(targetIndex) -1

	local function callbackFunc( )

		require "script/ui/teamGroup/TeamChangeLayer"
		TeamGroupLayer.createTableView()
		TeamChangeLayer.refreshTableView()
	end
	TeamGruopService.adjustTeam(callbackFunc ,sourceIndex , targetIndex)
end


local function downAction(tag, item)

	local sourceIndex= tonumber(tag)-1
	local targetIndex= tonumber(sourceIndex) +1

	local function callbackFunc( )

		require "script/ui/teamGroup/TeamChangeLayer"
		TeamGroupLayer.createTableView()
		TeamChangeLayer.refreshTableView()
	end
	TeamGruopService.adjustTeam(callbackFunc,sourceIndex,targetIndex)
	
end

--
function createCell( cellValues , index , memberNum, touchPority)

	local tCell = CCTableViewCell:create()

	local cellBg= nil 
	local fullRect = CCRectMake(0, 0, 578, 158)
    local insetRect = CCRectMake(100, 60, 10, 10)
	if( 1==index ) then
		cellBg= CCScale9Sprite:create("images/copy/guildcopy/team_frame_3.png",fullRect, insetRect)
	else
		cellBg= CCScale9Sprite:create("images/copy/guildcopy/team_frame_4.png",fullRect, insetRect)

	end
	cellBg:setPreferredSize(CCSizeMake(578,170) )
	tCell:addChild(cellBg)

	local nameBgFile= "images/common/bg/bg_9s_blue.png"
	
	local nameBg1= CCScale9Sprite:create(nameBgFile)
	nameBg1:setContentSize(CCSizeMake( 301, 33))
	nameBg1:setPosition(120, 77)
	nameBg1:setAnchorPoint(ccp(0,0))
	cellBg:addChild(nameBg1)

	local nameBg2 = CCScale9Sprite:create(nameBgFile)
	nameBg2:setContentSize(CCSizeMake( 301, 33))
	nameBg2:setPosition(120, 36)
	nameBg2:setAnchorPoint(ccp(0,0))
	cellBg:addChild(nameBg2)

	-- 军团名
	if(index ==1) then
		local titleLabel = CCRenderLabel:create( cellValues.uname .. "", g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		titleLabel:setColor(ccc3(0xff,0xff,0xff))
		-- 
		local numLabel= CCLabelTTF:create(GetLocalizeStringBy("key_2339") .. memberNum .. "/" .. TeamGroupData.getCopyInfo().max , g_sFontName, 23)
		numLabel:setColor(ccc3(0x00,0xff,0x18))
		local titleNode= BaseUI.createHorizontalNode({titleLabel, numLabel})
		titleNode:setAnchorPoint(ccp(0.5,1))
		titleNode:setPosition(cellBg:getContentSize().width/2, cellBg:getContentSize().height-6)
		cellBg:addChild(titleNode)
	end

	local vip= cellValues.vip or 0

	-- 头像
	local headIcon = HeroUtil.getHeroIconByHTID(cellValues.utid , cellValues.dressId, nil, vip)  --= HeroPublicCC.getCMISHeadIconFullByHtid(cellValues.utid)
	headIcon:setPosition(9,37)
	cellBg:addChild(headIcon)	


	-- 队伍中第几号位
	local indexSp = CCSprite:create("images/common/round.png")
	indexSp:setPosition(0, cellBg:getContentSize().height)
	indexSp:setAnchorPoint(ccp(0.1,1))
	cellBg:addChild(indexSp)
	local indexLabel = CCRenderLabel:create("" .. index, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	indexLabel:setColor(ccc3(0xff,0xff,0xff))
	indexLabel:setAnchorPoint(ccp(0.5,0.5))
	indexLabel:setPosition(ccp(indexSp:getContentSize().width/2, indexSp:getContentSize().height/2 ))
	indexSp:addChild(indexLabel)

	-- 名字
	local nameLabel= CCRenderLabel:create( cellValues.uname , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setAnchorPoint(ccp(0,0))
	nameLabel:setPosition(139,81)
	cellBg:addChild(nameLabel)

	-- 军团名
	if( cellValues.guildName) then
		local guildNameLabel = CCRenderLabel:create( " [" .. cellValues.guildName .. "]" , g_sFontName, 24,1, ccc3(0x00,0x00,0x00), type_stroke)
		guildNameLabel:setColor(ccc3(0xff,0xf6,0x00) )
		guildNameLabel:setPosition(ccp(290, 81))
		guildNameLabel:setAnchorPoint(ccp(0,0))
		cellBg:addChild(guildNameLabel)
	end

	-- 等级
	local lvSp= CCSprite:create("images/common/lv.png")
	local levelLabel = CCRenderLabel:create(tostring(cellValues.level),  g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	levelLabel:setColor(ccc3(0xff,0xf6,0x00))
	local levelNode =BaseUI.createHorizontalNode({lvSp,levelLabel})
	levelNode:setPosition(headIcon:getContentSize().width/2 ,2)
	levelNode:setAnchorPoint(ccp(0.5,1))
	headIcon:addChild(levelNode)

	local fightSp= CCSprite:create("images/common/fight_value.png")
	local fightForceLabel = CCRenderLabel:create( tostring(cellValues.fightForce) , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	fightForceLabel:setColor(ccc3(0x00,0xff,0x18))
	local fightNode= BaseUI.createHorizontalNode({fightSp,fightForceLabel})
	fightNode:setPosition(139,36)
	fightNode:setAnchorPoint(ccp(0,0))
	cellBg:addChild(fightNode)


	local menu= CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(touchPority)
	cellBg:addChild(menu)

	local upItem = CCMenuItemImage:create("images/common/btn/btn_up_n.png", "images/common/btn/btn_up_h.png")
	upItem:setPosition(410, cellBg:getContentSize().height/2)
	upItem:setAnchorPoint(ccp(0,0.5))
	upItem:registerScriptTapHandler(upAction)
	menu:addChild(upItem,1, index)

	local downItem = CCMenuItemImage:create("images/common/btn/btn_down_n.png", "images/common/btn/btn_down_h.png")
	downItem:setPosition(485, cellBg:getContentSize().height/2)
	downItem:setAnchorPoint(ccp(0,0.5))
	downItem:registerScriptTapHandler(downAction)
	menu:addChild(downItem,1,index)

	if(index ==1 or index== memberNum) then
		downItem:setVisible(false)
	end

	if(index ==1 or index == 2) then
		upItem:setVisible(false)
	end

	return tCell
end


