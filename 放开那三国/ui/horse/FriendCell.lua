-- Filename：	FriendCell.lua
-- Author：		llp
-- Date：		2016-4-7
-- Purpose：		邀请其他玩家的cell

module ("FriendCell", package.seeall)

require "script/ui/teamGroup/TeamGruopService"


-- 邀请人的按钮
function inviteMenuAction( tag,item)
	local uid= tonumber(tag)

	require "script/ui/horse/HorseInviteDialog"
	require "script/ui/horse/HorseData"

	local function callBackFunc( pRet )
		local uname = HorseData.removeInviteByUid(uid)
		HorseInviteDialog.rfcTableView()
	    require "script/ui/tip/SingleTip"
		if pRet ~= "fail" then
			SingleTip.showSingleTip(GetLocalizeStringBy("key_3418"))
		end
	end

	HorseController.inviteFriend(uid,callBackFunc )
end


function createCell( cellValues, touchPriority)

	local tCell = CCTableViewCell:create()

	local fullRect = CCRectMake(0, 0, 578, 158)
    local insetRect = CCRectMake(100, 60, 10, 10)
	cellBg= CCScale9Sprite:create("images/copy/guildcopy/team_frame_4.png",fullRect, insetRect)
	cellBg:setPreferredSize(CCSizeMake(578,213) )
	tCell:addChild(cellBg)


	local nameBgFile= "images/common/bg/bg_9s_blue.png"
	local nameBg1= CCScale9Sprite:create(nameBgFile)
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

	local nameStr= cellValues.uname
	local htid = tonumber(cellValues.htid.htid)
	local level = cellValues.level
	local fightForce= cellValues.fight_force
	local guildName= cellValues.guild_name or nil

	local dressId= nil
	local uid= tonumber(cellValues.uid)
	if(cellValues.dress and cellValues.dress[1]) then
		dressId = tonumber(cellValues.dress[1]) 
	end

	-- -- 头像
	local vip = cellValues.vip or 0
	local headIcon = HeroUtil.getHeroIconByHTID(htid, dressId, nil, vip) 
	-- local headItem = CCMenItemSprite:create(headIcon,headIcon)
	headIcon:setPosition(9,57)
	cellBg:addChild(headIcon)

	
	-- -- 名字
	local nameLabel = CCRenderLabel:create( nameStr , g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setPosition(139,122)
	nameLabel:setAnchorPoint(ccp(0,0))
	cellBg:addChild(nameLabel)

	-- 军团名
	if(guildName) then
		local guildNameLabel = CCRenderLabel:create( " [" .. guildName .. "]" , g_sFontName, 24,1, ccc3(0x00,0x00,0x00), type_stroke)
		guildNameLabel:setColor(ccc3(0xff,0xf6,0x00) )
		guildNameLabel:setPosition(ccp(139, 81))
		guildNameLabel:setAnchorPoint(ccp(0,0))
		cellBg:addChild(guildNameLabel)
	end

	-- 等级
	local lvSp= CCSprite:create("images/common/lv.png")
	local levelLabel = CCRenderLabel:create(tostring(level),  g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	levelLabel:setColor(ccc3(0xff,0xf6,0x00))
	local levelNode =BaseUI.createHorizontalNode({lvSp,levelLabel})
	levelNode:setPosition(headIcon:getContentSize().width/2 ,2)
	levelNode:setAnchorPoint(ccp(0.5,1))
	headIcon:addChild(levelNode)

	-- 战斗力
	local fightSp= CCSprite:create("images/common/fight_value.png")
	local fightForceLabel = CCRenderLabel:create(tostring(fightForce) , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	fightForceLabel:setColor(ccc3(0x00,0xff,0x18))
	local fightNode= BaseUI.createHorizontalNode({fightSp,fightForceLabel})
	fightNode:setPosition(139,36)
	fightNode:setAnchorPoint(ccp(0,0))
	cellBg:addChild(fightNode)

	-- 邀请按钮
	local menuBar= CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(touchPriority)
	cellBg:addChild(menuBar)

	local inviteBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue2_n.png","images/common/btn/btn_blue2_h.png",CCSizeMake(119,83),GetLocalizeStringBy("key_3263"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	inviteBtn:setPosition(445, 58)
	menuBar:addChild(inviteBtn,1,uid)
	inviteBtn:registerScriptTapHandler(inviteMenuAction)
	

	return tCell
end


