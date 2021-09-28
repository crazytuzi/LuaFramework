-- Filename：	FOfficerCell.lua
-- Author：		Cheng Liang
-- Date：		2013-7-12
-- Purpose：		装备Cell

module("FOfficerCell", package.seeall)


require "script/model/utils/HeroUtil"
require "script/ui/common/CheckBoxItem"
require "script/model/hero/HeroModel"

local Tag_CellBg = 10001
local _curCallbackFunc = nil

local checkedBtn = nil


local clickOnFormationCallback = nil


function checkedAction( tag, itemMenu )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(clickOnFormationCallback ~= nil) then
		clickOnFormationCallback()
	end
	print("hid == ", tag)
	---------------------新手引导---------------------------------
	--add by lichenyang 2013.08.29
	require "script/guide/NewGuide"
	if(NewGuide.guideClass ==  ksGuideFormation) then
	    require "script/guide/FormationGuide"
	    FormationGuide.changLayer()
	    print("changeLayer")
	end
    ---------------------end-------------------------------------			
	if (_curCallbackFunc) then
		_curCallbackFunc(tag)
	end
end

-- 获得英雄的信息
local function getHeroData( hid)
	value = {}
	local heroInfo = HeroModel.getHeroByHid(hid)
	value.htid = heroInfo.htid
	value.hid = hid
	local db_hero = DB_Heroes.getDataById(value.htid)
	value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
    local bIsAvatar = HeroModel.isNecessaryHero(value.htid)
	if bIsAvatar then
		value.name = UserModel.getUserName()
	else
		value.name = HeroModel.getHeroName(heroInfo)
	end
	value.level = db_hero.lv
	value.star_lv = db_hero.star_lv
	value.hero_cb = menu_item_tap_handler
	value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
    value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
	value.quality_h = "images/hero/quality/highlighted.png"
	value.type = "HeroFragment"
	value.isRecruited = false
	value.evolve_level = heroInfo.evolve_level
	value.turned_id = heroInfo.turned_id

	return value
end

local function heroCb(exchange_hero_id,itemBtn)
	require "script/ui/shop/HeroExchange"
	-- HeroExchange.closeCb()
	local data = getHeroData(exchange_hero_id)
	require "script/ui/main/MainScene"
	require "script/ui/hero/HeroInfoLayer"
	-- local tArgs = {}
	-- tArgs.sign = "shopLayer"
	-- tArgs.fnCreate = ShopLayer.createLayer
	-- tArgs.reserved =  {index= 10001}
	-- MainScene.changeLayer(HeroInfoLayer.createLayer(data, tArgs), "HeroInfoLayer")
	HeroInfoLayer.createLayer(data, {isPanel=true})
	-- CCDirector:sharedDirector():getRunningScene():addChild(HeroInfoLayer.createLayer(data, tArgs),1111)
end

--[[
	@desc	officerCell的创建
	@para 	heroInfo
	@return CCTableViewCell
--]]
function createOfficerCell(heroInfo, addUnionProfitCount, callbackFunc)
	_curCallbackFunc = callbackFunc

	local tCell = CCTableViewCell:create()

	-- 背景
	local cellBg = CCSprite:create("images/formation/changeofficer/cellbg.png")
	tCell:addChild(cellBg, 1, Tag_CellBg)
	local cellBgSize = cellBg:getContentSize()
	tCell:setContentSize(cellBgSize)
	local officer_data = HeroUtil.getHeroInfoByHid(heroInfo.hid)

	-- 国家
	local countryStr = HeroModel.getCiconByCidAndlevel(officer_data.localInfo.country, officer_data.localInfo.potential)
	if(countryStr)then
		local countrySp = CCSprite:create(countryStr)
		countrySp:setAnchorPoint(ccp(0, 1))
		countrySp:setPosition((ccp(cellBgSize.width*0.02, cellBgSize.height*0.95)))
		cellBg:addChild(countrySp)
	end

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	cellBg:addChild(menu)

	local heroSprite = HeroPublicCC.createHeroHeadIcon({hid=heroInfo.hid,turned_id=heroInfo.turned_id})
	heroSprite:setPosition(ccp(12,16))
	menu:addChild(heroSprite, 1, heroInfo.hid)
	heroSprite:registerScriptTapHandler(heroCb)

	-- 等级
	-- local levelLabel = CCRenderLabel:create( "LV." .. heroInfo.level, g_sFontName,21, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
   	local levelLabel = CCLabelTTF:create( "LV." .. heroInfo.level, g_sFontName,21)
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    levelLabel:setAnchorPoint(ccp(0, 1))
    levelLabel:setPosition(cellBgSize.width*0.1, cellBgSize.height*0.86)
    cellBg:addChild(levelLabel)

    local realHeroInfo = HeroModel.getHeroByHid(heroInfo.hid)
    local nameStr = HeroModel.getHeroName(realHeroInfo)
	-- 名称
	local nameColor = HeroPublicLua.getCCColorByStarLevel(officer_data.localInfo.potential)
	local nameLabel = CCLabelTTF:create(nameStr, g_sFontName, 22)
	nameLabel:setAnchorPoint(ccp(0.5, 0.5))
	nameLabel:setColor(nameColor)
	nameLabel:setPosition(ccp(cellBgSize.width*210/640, cellBgSize.height*0.78))
    cellBg:addChild(nameLabel)
    if(HeroModel.isNecessaryHeroByHid(heroInfo.hid)) then
		nameLabel:setString(UserModel.getUserName())
	end
    -- stars
    for i=1, officer_data.localInfo.potential do
    	local starSprite = CCSprite:create("images/hero/star.png")
    	starSprite:setAnchorPoint(ccp(0.5, 0.5))
    	starSprite:setPosition(ccp( cellBgSize.width * 300/640 + starSprite:getContentSize().width*1.2 * (i-1) , cellBgSize.height * 0.8))
    	cellBg:addChild(starSprite)
    end

    -- 战斗力
    local fightNumLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3083") .. officer_data.localInfo.heroQuality, g_sFontName, 24)
	fightNumLabel:setAnchorPoint(ccp(0, 0.5))
	fightNumLabel:setColor(ccc3(0x48, 0x1b, 0x00))
	fightNumLabel:setPosition(ccp(cellBgSize.width*115/640, cellBgSize.height*0.39))
    cellBg:addChild(fightNumLabel)

    -- 按钮
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	cellBg:addChild(menuBar,9,9)
	-- 复选框
	checkedBtn = LuaMenuItem.createItemImage("images/formation/changeofficer/btn_onformation_n.png",  "images/formation/changeofficer/btn_onformation_h.png", checkedAction)
	checkedBtn:setAnchorPoint(ccp(0.5, 0.5))
    checkedBtn:setPosition(ccp(cellBgSize.width*0.75, cellBgSize.height*0.4))
    -- checkedBtn:registerScriptTapHandler(checkedAction)

	menuBar:addChild(checkedBtn, 1, heroInfo.hid)

	if addUnionProfitCount > 0 then
		checkedBtn:setPosition(ccp(cellBgSize.width*0.75, cellBgSize.height*0.5))
		local addUnionProfitCountLabel =  CCRenderLabel:create(string.format("可激活羁绊+%d", addUnionProfitCount), g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	    addUnionProfitCountLabel:setColor(ccc3(0x8a, 0xff, 0x00))
	    addUnionProfitCountLabel:setAnchorPoint(ccp(0.5, 0.5))
    	addUnionProfitCountLabel:setPosition(ccpsprite(0.75, 0.2, tCell))
	    tCell:addChild(addUnionProfitCountLabel, 10)
	end

	return tCell
end

-- 新手引导
function getGuideChangeBtn( )
	return checkedBtn
end

--add by lichenyang

function registerClickOnFormationCallback( p_callback )
	clickOnFormationCallback = p_callback
end






