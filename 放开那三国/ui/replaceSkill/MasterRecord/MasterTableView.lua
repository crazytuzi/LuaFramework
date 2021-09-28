-- Filename: MasterTableView.lua
-- Author: Zhang Zihang
-- Date: 2014-08-07
-- Purpose: 宗师录tableView

module("MasterTableView", package.seeall)

require "script/ui/replaceSkill/ReplaceSkillData"

local _masterInfo

--[[
	@des 	:创建tableView
	@param 	:相应国家的宗师信息
	@return :创建好的tableView
--]]
function createTableView(p_masterInfo)
	require "script/ui/main/MainScene"

	_masterInfo = p_masterInfo

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(600*g_fScaleX, 185*g_fScaleX)
		elseif fn == "cellAtIndex" then
			a2 = createCell((math.ceil(#_masterInfo/4) - 1 - a1)*4)
			a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = math.ceil(#_masterInfo/4)
		else
			print("other function")
		end

		return r
	end)

	require "script/ui/replaceSkill/MasterRecord/MasterRecordLayer"
	return LuaTableView:createWithHandler(h, MasterRecordLayer.getSecondBgSize())
end

--[[
	@des 	:创建Cell
	@param 	:宗师Table开始下标
	@return :创建好的Cell
--]]
function createCell(p_beginIndex)
	local tCell = CCTableViewCell:create()
	local fullRect = CCRectMake(0,0,75, 75)
	local insetRect = CCRectMake(30,30,15,15)
	local cellSpite = CCScale9Sprite:create("images/star/cell9s.png", fullRect, insetRect)
	cellSpite:setContentSize(CCSizeMake(585,175))
	cellSpite:setAnchorPoint(ccp(0,0))
	cellSpite:setPosition(ccp(15/2,15/2))
	tCell:addChild(cellSpite)

	for i = p_beginIndex + 1,p_beginIndex + 4 do
		local needLine = false
		if (i - p_beginIndex) ~= 4 then
			needLine = true
		end
		if i <= #_masterInfo then
			local masterObj = createMasterIcon(_masterInfo[i].star_tid,_masterInfo[i].feel_level,_masterInfo[i].star_id,_masterInfo[i].isFeel,needLine,headCallBack)
			masterObj:setAnchorPoint(ccp(0.5,0.5))
			masterObj:setPosition(ccp(cellSpite:getContentSize().width*(i - p_beginIndex)/4 - 70,cellSpite:getContentSize().height/2))
			cellSpite:addChild(masterObj)
		end
	end

	return tCell
end

--[[
	@des 	:创建宗师头像
	@param 	:
	@return :创建好的宗师头像
--]]
function createMasterIcon(p_sTid,p_feelLv,p_sId,p_isFeel,p_needLine,p_callBack)
	-- 查找名将的信息
	require "db/DB_Star"
	local masterInfo = DB_Star.getDataById(tonumber(p_sTid))
	local bgSprite = CCSprite:create("images/base/potential/officer_" .. masterInfo.quality .. ".png")
	local iconFile = "images/base/hero/head_icon/" .. masterInfo.icon

	-- 按钮Bar
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(menuBar)

	-- 按钮
	local headItemImage = CCMenuItemImage:create(iconFile,iconFile)
	headItemImage:registerScriptTapHandler(p_callBack)
	headItemImage:setAnchorPoint(ccp(0.5, 0.5))
	headItemImage:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height/2))
	menuBar:addChild(headItemImage, 1, tonumber(p_sId))

	--武将名字
	local nameBgSprite = CCSprite:create("images/common/bg/name.png")
	nameBgSprite:setAnchorPoint(ccp(0.5, 1))
	nameBgSprite:setPosition(ccp(headItemImage:getContentSize().width/2,-headItemImage:getContentSize().height*0.1))
	headItemImage:addChild(nameBgSprite)

	-- 名将名称
	require "script/ui/hero/HeroPublicLua"
	local nameColor = HeroPublicLua.getCCColorByStarLevel(masterInfo.quality)
	local nameLabel = CCRenderLabel:create(masterInfo.name, g_sFontName, 23, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
    nameLabel:setPosition(ccp(nameBgSprite:getContentSize().width*0.5, nameBgSprite:getContentSize().height*0.5))
    nameBgSprite:addChild(nameLabel)

    if(p_needLine == true) then
		local lineSprite = CCSprite:create("images/common/line.png")
		lineSprite:setAnchorPoint(ccp(0,0.5))
		lineSprite:setPosition(ccp(bgSprite:getContentSize().width + 22, bgSprite:getContentSize().height*0.5))
		bgSprite:addChild(lineSprite)
	end

	-- 修
	local learnSprite = CCSprite:create("images/replaceskill/awaken_icon.png")

	-- 等级
	local levelLabel = CCLabelTTF:create(p_feelLv, g_sFontName, 25)
	levelLabel:setColor(ccc3(0x00, 0x6d, 0x2f))

	require "script/utils/BaseUI"
	local levelNode = BaseUI.createHorizontalNode({levelLabel,learnSprite})
	levelNode:setAnchorPoint(ccp(0.5,0))
	levelNode:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height))
	bgSprite:addChild(levelNode)

	if p_isFeel == 1 then
		local skillTipSprite = CCSprite:create("images/replaceskill/skill_tip.png")
		skillTipSprite:setAnchorPoint(ccp(1,0))
		skillTipSprite:setPosition(ccp(bgSprite:getContentSize().width,0))
		bgSprite:addChild(skillTipSprite)
	end

	return bgSprite
end

--[[
	@des 	:宗师头像回调
	@param 	:宗师sid
	@return :
--]]
function headCallBack(tag)
	if ReplaceSkillData.isTeacher(tag) then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1088"))
	else
		ReplaceSkillData.setCurMasterInfo(tag)
		require "script/ui/replaceSkill/ReplaceSkillLayer"
		ReplaceSkillLayer.showLayer()
	end
end