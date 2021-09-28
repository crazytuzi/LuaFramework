-- Filename：	EnemyCell.lua
-- Author：		Cheng Liang
-- Date：		2013-8-3
-- Purpose：		敌人Cell

module("EnemyCell", package.seeall)

require "script/ui/item/ItemSprite"
require "script/model/utils/HeroUtil"
require "script/utils/LuaUtil"
require "script/libs/LuaCC"

local Tag_CellBg = 10001
local _enemyActionCallback = nil

local function matchAction( tag , itemBtn )
	if(ItemUtil.isBagFull() == true)then
		-- AnimationTip.showTip(GetLocalizeStringBy("key_2094"))
		return
	end
	if(ActiveLayer.costNextRob() > UserModel.getStaminaNumber())then
		AnimationTip.showTip(GetLocalizeStringBy("key_2183"))
		return
	end
	ActiveLayer.oppUid = tag
	local args = Network.argsHandler(tag, 1)
	RequestCenter.star_rob(_enemyActionCallback, args)
end

local function time_str_func( delt_sec )
	local time_str = ""
	if(delt_sec <= 3600)then
		time_str = GetLocalizeStringBy("key_1538")
	elseif(delt_sec <= 36000)then
		time_str = GetLocalizeStringBy("key_2040")
	elseif(delt_sec <= 3600*24)then
		time_str = GetLocalizeStringBy("key_3244")
	elseif(delt_sec <= 3600*24*10)then
		time_str = GetLocalizeStringBy("key_1280")
	else
		time_str = GetLocalizeStringBy("key_1964")
	end
	return time_str
end 

--[[
	@desc	装备Cell的创建
	@para 	table cellValues,
			int animatedIndex, 
			boolean isAnimate
	@return CCTableViewCell
--]]
function createCell(userData, enemyActionCallback)

	_enemyActionCallback = enemyActionCallback

	local tCell = CCTableViewCell:create()
	--print_table("userData", userData)

	-- 背景
	local cellBg = CCSprite:create("images/active/rob/bg_cell_enemy.png")
	tCell:addChild(cellBg, 1, Tag_CellBg)
	local cellBgSize = cellBg:getContentSize()

	local user_info = userData

	local htid = 20001
	if(user_info.utid == "1") then
		htid = 20002
	end
	-- 头像
	local iconSP =  HeroUtil.getHeroIconByHTID( htid )
	iconSP:setAnchorPoint(ccp(0.5, 0.5))
	iconSP:setPosition(ccp(cellBgSize.width*0.1, cellBgSize.height*0.4))
	cellBg:addChild(iconSP)

	-- 等级
	local levelLabel = CCRenderLabel:create(user_info.level, g_sFontName,21, 1, ccc3(0x89, 0x00, 0x1a), type_stroke)
    -- levelLabel:setSourceAndTargetColor(ccc3( 0xf9, 0xff, 0xc8), ccc3(0xff, 0xd7, 0x4e));
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setPosition(cellBgSize.width*0.1, cellBgSize.height*0.86)
    cellBg:addChild(levelLabel)

	-- 名称
	local nameLabel = CCLabelTTF:create(user_info.uname, g_sFontName, 21)
	nameLabel:setAnchorPoint(ccp(0, 1))
	nameLabel:setColor(ccc3(0x36, 0xff, 0x00))
	nameLabel:setPosition(ccp(cellBgSize.width*0.18, cellBgSize.height*0.87))
    cellBg:addChild(nameLabel)

    local cur_sec = os.time()
    local time_str = time_str_func(cur_sec - userData.time)
    -- 时间
    local timeLabel = CCLabelTTF:create(time_str, g_sFontName, 25)
	timeLabel:setAnchorPoint(ccp(0, 1))
	timeLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
	timeLabel:setPosition(ccp(cellBgSize.width*175.0/640, cellBgSize.height*0.58))
    cellBg:addChild(timeLabel)

    local colorCCC3 = ccc3(0x00, 0x6d, 0x2f)
    local desc_1 = GetLocalizeStringBy("key_3202")
    if(userData.isrob == "0") then
    	desc_1 = GetLocalizeStringBy("key_1724")
    end
    local desc_2 = GetLocalizeStringBy("key_2607")
    if(userData.res == "0") then
    	desc_2 = GetLocalizeStringBy("key_2427")
    	colorCCC3 = ccc3(0xbc, 0x00, 0x00)
    end
    -- desc_1 = desc_1 .. desc_2

    -- 描述
    local descLabel = CCLabelTTF:create(desc_1, g_sFontName, 25)
	descLabel:setAnchorPoint(ccp(0, 1))
	descLabel:setColor(ccc3(0x48, 0x1b, 0x00))
	descLabel:setPosition(ccp(cellBgSize.width*120.0/640, cellBgSize.height*0.32))
    cellBg:addChild(descLabel)

    -- 描述
    local descLabel_2 = CCLabelTTF:create(desc_2, g_sFontName, 25)
	descLabel_2:setAnchorPoint(ccp(0, 1))
	descLabel_2:setColor(colorCCC3)
	descLabel_2:setPosition(ccp(cellBgSize.width*120.0/640 + descLabel:getContentSize().width, cellBgSize.height*0.32))
    cellBg:addChild(descLabel_2)

    local matchMenuBar = CCMenu:create()
	matchMenuBar:setPosition(ccp(0, 0))
	cellBg:addChild(matchMenuBar)
	-- 复仇
	local matchBtn = LuaCC.create9ScaleMenuItem("images/active/rob/btn_rob_n.png","images/active/rob/btn_rob_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("key_1125"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontName,1, ccc3(0x00, 0x00, 0x00))
	--print("matchBtn==", matchBtn)
	matchBtn:setAnchorPoint(ccp(0.5, 0.5))
	matchBtn:registerScriptTapHandler(matchAction)
	matchBtn:setPosition(ccp(cellBg:getContentSize().width*530.0/640, cellBg:getContentSize().height*0.5))
	matchMenuBar:addChild(matchBtn, 2, userData.uid)

	
	return tCell
end


