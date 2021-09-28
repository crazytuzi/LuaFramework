-- Filename：	MatchCell.lua
-- Author：		Cheng Liang
-- Date：		2013-8-3
-- Purpose：		比武Cell

module("MatchCell", package.seeall)


require "script/ui/item/ItemSprite"
require "script/model/utils/HeroUtil"
require "script/utils/LuaUtil"
require "script/libs/LuaCC"
require "script/network/RequestCenter"

local Tag_CellBg = 10001
local _matchCallbackAction = nil

-- 比武
local matchBtn = nil


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
	local args = Network.argsHandler(tag, 0)
	RequestCenter.star_rob(_matchCallbackAction, args)
end

--[[
	@desc	
	@para 	
	@return 
--]]
function createCell(userData, matchCallbackAction)
	_matchCallbackAction = matchCallbackAction

	local tCell = CCTableViewCell:create()

	-- 背景
	local cellBg = CCSprite:create("images/active/rob/bg_cell_rob.png")
	tCell:addChild(cellBg, 1, Tag_CellBg)
	local cellBgSize = cellBg:getContentSize()

	local htid = 20001
	if(userData.utid == "1") then
		htid = 20002
	end
	-- 头像
	local iconSP =  HeroUtil.getHeroIconByHTID( htid )
	iconSP:setAnchorPoint(ccp(0.5, 0.5))
	iconSP:setPosition(ccp(cellBgSize.width*0.1, cellBgSize.height*0.4))
	cellBg:addChild(iconSP)

	-- 等级
	local levelLabel = CCRenderLabel:create(userData.level, g_sFontName,21, 1, ccc3(0x89, 0x00, 0x1a), type_stroke)
    -- levelLabel:setSourceAndTargetColor(ccc3( 0xf9, 0xff, 0xc8), ccc3(0xff, 0xd7, 0x4e));
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setPosition(cellBgSize.width*0.1, cellBgSize.height*0.86)
    cellBg:addChild(levelLabel)

	-- 名称
	local nameLabel = CCLabelTTF:create(userData.uname, g_sFontName, 21)
	nameLabel:setAnchorPoint(ccp(0, 1))
	nameLabel:setColor(ccc3(0x36, 0xff, 0x00))
	nameLabel:setPosition(ccp(cellBgSize.width*0.18, cellBgSize.height*0.87))
    cellBg:addChild(nameLabel)

    -- 拥有名士
    local starNumLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1511") .. (userData.star_num), g_sFontName, 25)
	starNumLabel:setAnchorPoint(ccp(0, 1))
	starNumLabel:setColor(ccc3(0x48, 0x1b, 0x00))
	starNumLabel:setPosition(ccp(cellBgSize.width*0.18, cellBgSize.height*0.46))
    cellBg:addChild(starNumLabel)

    local matchMenuBar = CCMenu:create()
	matchMenuBar:setPosition(ccp(0, 0))
	cellBg:addChild(matchMenuBar)
	-- 比武
	matchBtn = LuaCC.create9ScaleMenuItem("images/active/rob/btn_rob_n.png","images/active/rob/btn_rob_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("key_2182"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontName,1, ccc3(0x00, 0x00, 0x00))
	matchBtn:setAnchorPoint(ccp(0.5, 0.5))
	matchBtn:setPosition(ccp(cellBg:getContentSize().width*530.0/640, cellBg:getContentSize().height*0.5))
	matchBtn:registerScriptTapHandler(matchAction)
	matchMenuBar:addChild(matchBtn, 2, userData.uid)

	return tCell
end

-- 新手引导用
function getGuideObject()
	return matchBtn
end
