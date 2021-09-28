-- FileName: PurgatoryUnionLayer.lua
-- Author: llp
-- Date: 15-6-8
-- Purpose: 武将羁绊

module("PurgatoryUnionLayer", package.seeall)


local _bgLayer                  	= nil
local _backGround 					= nil

local _showAttrTab 					= nil
local _showzOrder 					= nil
local _showLayerPriority 			= nil
local _titleString 					= nil

function init( ... )
	_bgLayer                    	= nil
	_backGround 					= nil

	_showAttrTab 					= nil
	_showzOrder 					= nil
	_showLayerPriority 				= nil
	_titleString 					= nil
end

--[[
	@des 	:touch事件处理
	@param 	:
	@return :
--]]
local function layerTouch(eventType, x, y)
    return true
end

--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des 	:创建阵容羁绊列表
	@param 	:
	@return :
--]]
function createSkillScrollView( ... )
	-- 创建scrollView
	local listScrollView = CCScrollView:create()
	listScrollView:setTouchPriority(_showLayerPriority)
	listScrollView:setViewSize(CCSizeMake(585,406))
    listScrollView:setBounceable(true)
    listScrollView:setDirection(kCCScrollViewDirectionVertical)

	local containerLayer = createContainerLayer()
	listScrollView:setContainer(containerLayer)
	listScrollView:setContentOffset(ccp(0,listScrollView:getViewSize().height-containerLayer:getContentSize().height))
	return listScrollView
end

function createContainerLayer( ... )
	-- 得到阵上武将数据
	local heroData = _showAttrTab

	local heroCount = table.count(heroData)

	local containerLayer = CCSprite:create()
	containerLayer:setContentSize(CCSizeMake(585,0))
		-- 创建列表
	local cellHeight = 10
	for i=heroCount,1,-1  do
		local curHeroData = heroData[i].value
		-- 名字
		local hero_name = nil
		local hero = DB_Heroes.getDataById(heroData[i].htid)
        if(hero==nil)then
            hero = DB_Monsters_tmpl.getDataById(heroData[i].htid)
        end

		hero_name = hero.name

		if( table.count(curHeroData["union_infos"]) == 0)then
			-- 羁绊数据为空
			local link_des = CCLabelTTF:create(GetLocalizeStringBy("key_1341"),g_sFontName,23)
			link_des:setColor(ccc3(0x2f,0x2f,0x2f))
			link_des:setAnchorPoint(ccp(0.5,0))
			link_des:setPosition(ccp(containerLayer:getContentSize().width*0.5,cellHeight))
			containerLayer:addChild(link_des)
			-- 累积高度
			cellHeight = cellHeight+link_des:getContentSize().height+15
		else
			-- 遍历所有的羁绊数据
			local link_num = table.count(curHeroData["union_infos"])
			for k,v in pairs(curHeroData["union_infos"]) do
				local name_color = nil
				local des_color = nil
				if( v.is_active )then
					name_color = ccc3(0x00,0x6d,0x2f)
					des_color = ccc3(0x78,0x25,0x00)
				else
					name_color = ccc3(0x2f,0x2f,0x2f)
					des_color = ccc3(0x2f,0x2f,0x2f)
				end
				-- 羁绊名字
				local name_font = v.union_name or " "
				local link_name = CCLabelTTF:create(name_font .. ":",g_sFontName,23)
				-- 羁绊描述
				local des_font = v.union_desc or " "
				local link_des = CCLabelTTF:create(des_font,g_sFontName,23,CCSizeMake(330,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

				link_des:setColor(des_color)
				link_des:setAnchorPoint(ccp(0,0))
				link_des:setPosition(ccp(183,cellHeight))
				containerLayer:addChild(link_des)
				cellHeight = cellHeight+link_des:getContentSize().height+15

				link_name:setColor(name_color)
				link_name:setAnchorPoint(ccp(1,1))
				link_name:setPosition(ccp(180,link_des:getPositionY() + link_des:getContentSize().height))
				containerLayer:addChild(link_name)
			end
		end

		-- 创建武将名字
		local name_bg = CCSprite:create("images/formation/littlef_line.png")
		name_bg:setAnchorPoint(ccp(0.5,0))
		name_bg:setPosition(containerLayer:getContentSize().width*0.5,cellHeight)
		containerLayer:addChild(name_bg,1,i)

		local name_font = CCRenderLabel:create( hero_name, g_sFontPangWa, 28, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
		name_font:setColor(ccc3(0xff, 0xf6, 0x00))
		name_font:setAnchorPoint(ccp(0.5,0.5))
		name_font:setPosition(ccp(name_bg:getContentSize().width*0.5,name_bg:getContentSize().height*0.5))
		name_bg:addChild(name_font)
		-- 累积高度
		cellHeight = cellHeight+name_font:getContentSize().height+5
	end
	-- 设置containerLayer的size
	containerLayer:setContentSize(CCSizeMake(358,cellHeight))
	return containerLayer
end

--[[
	@des 	:创建提示框
	@param 	:
	@return :
--]]
function createTipLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,_showLayerPriority,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_showzOrder,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(585, 460))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_showLayerPriority-1)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(_titleString, g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 创建羁绊显示列表ScrollView
	local listScrollView = createSkillScrollView()
	listScrollView:setPosition(ccp(0,10))
	_backGround:addChild(listScrollView,3)
end

function showTip( p_htidTable, tip_layer_priority)
	-- 初始化
	init()

	-- 战魂数组
	require "script/model/hero/HeroModel"
	require "script/model/hero/FightForceModel"
	if p_htidTable ~= nil then
		_showAttrTab = p_htidTable
	else
		return
	end

	_titleString = GetLocalizeStringBy("llp_201")

	_showzOrder = 1010
	_showLayerPriority = tip_layer_priority or -420

	-- 创建提示layer
	createTipLayer()
end