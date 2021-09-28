-- Filename：	ReceiveInviteCell.lua
-- Author：		zhz
-- Date：		2013-3-18
-- Purpose：		接受其他玩家的layer


module ("ReceiveInviteCell", package.seeall)

require "db/DB_Copy_team"


local function receiveMenuAction(tag, item)
	
	print("............................ tag is ", tag)
	local index= tonumber(tag)
	ReceiveInviteLayer.closeBtnCb()

	-- local teamId= nil
	-- local copyId= nil
	-- require "script/ui/guild/copy/GuildTeamData"

	-- local function callbackFn(  teamId, copyId )
		

	-- 	teamId= tonumber(teamId)
	-- 	copyId= tonumber(copyId)
	-- 	local limitType =GuildTeamData.getTeamLimitById(tonumber(copyId) )

	-- 	TeamGroupLayer.showLayer(copyId,limitType,nil,nil, nil , function ( )
	-- 		TeamGruopService.joinTeamDelegate(  teamId, copyId)
	-- 	end)
	-- end

	--require "script/ui/teamGroup/TeamGruopService"
	--TeamGruopService.receiveInvite(callbackFn, index)

	--[[
	    替代上面被注释的代码(重复调用, TeamGruopService.joinTeamDelegate已经
        在TeamGruopService.receiveInvite中调用)
    --]]
	require "script/ui/teamGroup/TeamGruopService"
	TeamGruopService.receiveInvite(nil, index)
end


function createCell(  cellValues, touchPriority,index)

	local tCell = CCTableViewCell:create()
	--cellBg= CCSprite:create("images/copy/guildcopy/team_frame_1.png")
	local fullRect = CCRectMake(0, 0, 578, 158)
    local insetRect = CCRectMake(100, 60, 10, 10)
	cellBg= CCScale9Sprite:create("images/copy/guildcopy/team_frame_1.png",fullRect, insetRect)
	cellBg:setPreferredSize(CCSizeMake(578,213) )
	tCell:addChild(cellBg)

	print("cellValues  is : ")
	print_t(cellValues)


	local nameBgFile= "images/common/bg/bg_9s_red.png"
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


	local nameStr= cellValues[1].uname
	local htid = tonumber( cellValues[1].htid)
	local level =  cellValues[1].level
	local fightForce=  cellValues[1].fight_force
	local dressId= nil
	local guildName= cellValues[1].guild_name or nil
	local uid= tonumber(cellValues[1].uid)
	local vip = cellValues[1].vip or 0
	if(cellValues.dress and cellValues.dress[1]) then
		dressId = tonumber(cellValues.dress[1]) 
	end

	local teamCopyId= tonumber(cellValues[2])
	local teamId= tonumber(cellValues[3])

	-- 	-- -- 头像
	
	local headIcon = HeroUtil.getHeroIconByHTID(htid, dressId,nil, vip) 
	headIcon:setPosition(9,57)
	cellBg:addChild(headIcon)

	-- 副本名
	copyName= DB_Copy_team.getDataById(teamCopyId).name
	local copyNameLabel = CCRenderLabel:create( copyName, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	copyNameLabel:setColor(ccc3(0xff,0xff,0xff))
	copyNameLabel:setAnchorPoint(ccp(0.5,1))
	copyNameLabel:setPosition(cellBg:getContentSize().width/2, cellBg:getContentSize().height-6)
	cellBg:addChild(copyNameLabel)

	
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

	-- 等级
	local lvSp= CCSprite:create("images/common/lv.png")
	local levelLabel = CCRenderLabel:create("" .. level,  g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	levelLabel:setColor(ccc3(0xff,0xf6,0x00))
	local levelNode =BaseUI.createHorizontalNode({lvSp,levelLabel})
	levelNode:setPosition(headIcon:getContentSize().width/2 ,2)
	levelNode:setAnchorPoint(ccp(0.5,1))
	headIcon:addChild(levelNode)

	-- -- 战斗力
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

	local receiveBtn = LuaCC.create9ScaleMenuItem("images/level_reward/receive_btn_n.png","images/level_reward/receive_btn_h.png",CCSizeMake(119,83),GetLocalizeStringBy("key_2608"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	receiveBtn:setPosition(445, 58)
	menuBar:addChild(receiveBtn,1, index)
	receiveBtn:registerScriptTapHandler(receiveMenuAction)


	return tCell

end
