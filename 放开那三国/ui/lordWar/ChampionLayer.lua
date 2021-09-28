-- Filename: ChampionLayer.lua
-- Author: lichenyang
-- Date: 2014-08-14
-- Purpose: 个人跨服赛数据层

module("ChampionLayer", package.seeall)

require "script/ui/lordWar/LordWarUtil"
require "script/ui/lordWar/LordWarService"
require "script/ui/lordWar/LordWarData"


local kStationPos 	 = {ccps(0.19, 0.47),ccps(0.5, 0.35),ccps(0.81, 0.47)}
local kStationScale  = {0.75, 1, 0.75}
local kStationZorder = {5, 10, 5}

local _bgLayer 			= nil
local _layerSize 		= nil
local _selectIndex		= nil
local _championArray    = nil
local _moveLayer 		= nil
local _isMove 			= nil
local _updateScheduler 
--[[
	@des 	:初始化
--]]
function init( ... )
	_bgLayer 		= nil
	_layerSize 		= nil
	_selectIndex	= 2
	_championArray  = {}
	_moveLayer 		= nil
	_isMove 		= true
end

--[[
	@des 	:入口函数，用于场景切换
--]]
function show()
    local layer = ChampionLayer.createLayer()
    MainScene.changeLayer(layer, "ChampionLayer")
end

--[[
	@des : 创建layer
--]]
function createLayer( ... )
	init()
	_bgLayer = CCLayer:create()
	
	_moveLayer = CCLayer:create()
	_bgLayer:addChild(_moveLayer, 20)	

	_moveLayer:setTouchEnabled(true)
	_moveLayer:registerScriptTouchHandler(touchCallback, true, -128, false)
	_layerSize = CCSizeMake(g_winSize.width, g_winSize.height)

	MainScene.setMainSceneViewsVisible(false, false, true)
	local bgSprite = CCSprite:create("images/lord_war/worship/worship.jpg")
	bgSprite:setAnchorPoint(ccp(0.5, 0))
	bgSprite:setPosition(ccps(0.5, 0))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	_layerSize.height = g_winSize.height - MainScene.getBulletFactSize().height

	LordWarService.getTempleInfo(function ( ... )
		-- body
		createTopUi()
		createCenterUi()
		crateRole()
	end)
	return _bgLayer
end

--[[
	@des : 顶部ui
--]]
function createTopUi( ... )

	-- 上标题栏 显示战斗力，银币，金币
	local userInfo = UserModel.getUserInfo()
	local topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    topBg:setAnchorPoint(ccp(0,1))
    topBg:setPosition(0,_layerSize.height)
    topBg:setScale(g_fScaleX)
    _bgLayer:addChild(topBg)
    titleSize = topBg:getContentSize()
    _layerSize.height =_layerSize.height - topBg:getContentSize().height*g_fScaleX - 25 * MainScene.elementScale

    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(topBg:getContentSize().width*0.13,topBg:getContentSize().height*0.43)
    topBg:addChild(powerDescLabel)
    
    m_powerLabel = CCRenderLabel:create( tonumber(UserModel.getFightForceValue()), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    m_powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    m_powerLabel:setPosition(topBg:getContentSize().width*0.23,topBg:getContentSize().height*0.66)
    topBg:addChild(m_powerLabel)
    
    -- modified by yangrui at 2015-12-03
	m_silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)
    m_silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    m_silverLabel:setAnchorPoint(ccp(0,0.5))
    m_silverLabel:setPosition(topBg:getContentSize().width*0.61,topBg:getContentSize().height*0.43)
    topBg:addChild(m_silverLabel)
    
    m_goldLabel = CCLabelTTF:create( tonumber(userInfo.gold_num),g_sFontName,18)
    m_goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    m_goldLabel:setAnchorPoint(ccp(0,0.5))
    m_goldLabel:setPosition(topBg:getContentSize().width*0.82,topBg:getContentSize().height*0.43)
    topBg:addChild(m_goldLabel)

	--标题
	local titleSprite = LordWarUtil.createTitleSprite()
	titleSprite:setAnchorPoint(ccp(0.5, 1))
	titleSprite:setPosition(ccp(g_winSize.width * 0.5, _layerSize.height))
	_bgLayer:addChild(titleSprite)
    titleSprite:setScale(g_fScaleX)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(menu)

	--关闭按钮
	local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(closeButtonCallFunc)
	closeButton:setPosition(ccp(_layerSize.width * 0.9 ,_layerSize.height * 0.9))
	menu:addChild(closeButton)
	closeButton:setScale(MainScene.elementScale)

end


--[[
	@des : 中部ui
--]]
function createCenterUi( ... )
	
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(menu)

	--每日膜拜
	local norSprite = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
	norSprite:setContentSize(CCSizeMake(193, 73))
	local norTitle  =  CCRenderLabel:create(GetLocalizeStringBy("lcyx_1900"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	norTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	norTitle:setPosition(ccpsprite(0.5, 0.5, norSprite))
	norTitle:setAnchorPoint(ccp(0.5, 0.5))
	norSprite:addChild(norTitle)
	
	local higSprite = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png")
	higSprite:setContentSize(CCSizeMake(193, 73))
	local higTitle  =  CCRenderLabel:create(GetLocalizeStringBy("lcyx_1900"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	higTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	higTitle:setPosition(ccpsprite(0.5, 0.5, higSprite))
	higTitle:setAnchorPoint(ccp(0.5, 0.5))
	higSprite:addChild(higTitle)
	
	local graySprite = CCScale9Sprite:create("images/common/btn/btn1_g.png")
	graySprite:setContentSize(CCSizeMake(193, 73))
	local grayTitle  =  CCRenderLabel:create(GetLocalizeStringBy("lcyx_1900"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	grayTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	grayTitle:setPosition(ccpsprite(0.5, 0.5, graySprite))
	grayTitle:setAnchorPoint(ccp(0.5, 0.5))
	graySprite:addChild(grayTitle)
	
	local worshipButton = CCMenuItemSprite:create(norSprite, higSprite, graySprite)
	worshipButton:setAnchorPoint(ccp(0.5, 0.5))
	worshipButton:registerScriptTapHandler(worshipButtonCallback)
	worshipButton:setPosition(ccps(0.5 ,0.18))
	menu:addChild(worshipButton)
	worshipButton:setScale(MainScene.elementScale)
	
end


--[[
	@des : 创建 初出茅庐冠军，傲视群雄冠军，傲视群雄亚军 角色
--]]
function crateRole( ... )

	local championInfo = LordWarData.getTempleInfo()
    print("冠军")
    print_t(championInfo)
	local effectPath = {
		"images/base/effect/yinpai/yinpai",
		"images/base/effect/jinpai/jinpai",
		"images/base/effect/tongpai/tongpai",
	}
	for i,v in ipairs({2, 1, 3}) do
		if(championInfo[v].htid ~= nil) then
			local taiZi = CCSprite:create("images/olympic/tai_zi.png")
			taiZi:setPosition(kStationPos[i])
			taiZi:setAnchorPoint(ccp(0.5 ,0.5))
			_moveLayer:addChild(taiZi)
			taiZi:setScale(MainScene.elementScale * kStationScale[i])
			_moveLayer:reorderChild(taiZi,kStationZorder[i])
			_championArray[v] = taiZi

			local kingSprite = HeroUtil.getHeroBodySpriteByHTID(championInfo[v].htid, championInfo[v].dress["1"], HeroModel.getSex(championInfo[v].htid))
			kingSprite:setPosition(ccp(taiZi:getContentSize().width *0.4, taiZi:getContentSize().height * 0.5))
			kingSprite:setAnchorPoint(ccp(0.5, 0))
			taiZi:addChild(kingSprite)
			kingSprite:setScale(0.7)

			local kingHat = CCSprite:create("images/lord_war/worship/hat_" .. i .. ".png")
			kingHat:setPosition(ccp(kingSprite:getContentSize().width *0.55, kingSprite:getContentSize().height * 1))
			kingHat:setAnchorPoint(ccp(0.5, 0))
			kingSprite:addChild(kingHat)
			kingHat:setScale(1.6)

			local animSprite = CCLayerSprite:layerSpriteWithName(CCString:create(effectPath[i]), -1,CCString:create(""))
		    animSprite:setPosition(ccpsprite(0.5,0.5,kingHat))
		    kingHat:addChild(animSprite)

		    if(championInfo[v].title ~= nil) then
			    require "script/ui/title/TitleUtil"
			    local titleSprite = TitleUtil.createTitleNormalSpriteById(championInfo[v].title)
			    titleSprite:setAnchorPoint(ccp(0.5, 0.5))
			    titleSprite:setPosition(ccpsprite(0.55, 0.93, kingSprite))
			    kingSprite:addChild(titleSprite,2)
			else
				kingHat:setPosition(ccpsprite(0.55, 0.9, kingSprite))
			end

	        local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	        taiZi:addChild(nameBg)
	        nameBg:setAnchorPoint(ccp(0.5, 0.5))
	        nameBg:setPosition(ccpsprite(0.5, -0.1, taiZi))
	        nameBg:setContentSize(CCSizeMake(230, 32))
			local nameLabel = CCRenderLabel:create( championInfo[v].uname , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	        if i == 2 then
	            nameLabel:setColor(ccc3(0xe2,0x01,0xff))
	        else
	            nameLabel:setColor(ccc3(0xfa, 0x57, 0xfe))
	        end

			local levelLabel = CCRenderLabel:create( "Lv." .. (championInfo[v].level or 0), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			levelLabel:setColor(ccc3(0xff,0xf6,0x00))

			local desNodeTable = BaseUI.createHorizontalNode({nameLabel,levelLabel})
			desNodeTable:setAnchorPoint(ccp(0.5, 0.5))
			desNodeTable:setPosition(ccpsprite(0.5, 0.5, nameBg))
			nameBg:addChild(desNodeTable)
			desNodeTable:setScale(MainScene.elementScale)
	        
	        local serverNameLabel = CCRenderLabel:create(string.format("(%s)", championInfo[v].serverName), g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	        taiZi:addChild(serverNameLabel)
	        serverNameLabel:setAnchorPoint(ccp(0.5, 0.5))
	        serverNameLabel:setPosition(ccpsprite(0.5, -0.3, taiZi))
	        
	        local fightSp = CCSprite:create("images/lord_war/fight_bg.png")
			fightSp:setAnchorPoint(ccp(0.5,0.5))
			fightSp:setPosition(ccp(taiZi:getContentSize().width * 0.5 + 20, 100))
			taiZi:addChild(fightSp)
			local fightLable = CCRenderLabel:create(championInfo[v].fightForce, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
		    fightLable:setColor(ccc3(0xff,0x00,0x00))
		    fightLable:setAnchorPoint(ccp(0,0.5))
		    fightLable:setPosition(ccp(34, fightSp:getContentSize().height*0.5))
		   	fightSp:addChild(fightLable)
		end
	end

	--箭头
	local arrowLeft = CCSprite:create("images/lord_war/worship/arrow_left.png")
	arrowLeft:setPosition(ccps(0.25 ,0.4))
	arrowLeft:setAnchorPoint(ccp(0.5, 0.5))
	_bgLayer:addChild(arrowLeft)
	arrowLeft:setScale(MainScene.elementScale)

	local arrowRight = CCSprite:create("images/lord_war/worship/arrow_right.png")
	arrowRight:setPosition(ccps(0.75 ,0.4))
	arrowRight:setAnchorPoint(ccp(0.5, 0.5))
	_bgLayer:addChild(arrowRight)
	arrowRight:setScale(MainScene.elementScale)
end

-----------------------------------[[ 更新ui方法 ]]--------------------------------------

function updateRolePos( ... )
	_isMove = false
	local targetIndex = {}
	if(_selectIndex == 1) then
		targetIndex = {2,3,1,}
	elseif(_selectIndex == 2) then
		targetIndex = {1,2,3,}
	elseif(_selectIndex == 3) then
		targetIndex = {3,1,2,}
	else
		error("_selectIndex error = " .. _selectIndex)
	end
	for i,v in ipairs({2, 1, 3}) do
		_moveLayer:stopAllActions()
		local actionArray = CCArray:create()
		actionArray:addObject(CCMoveTo:create(0.5, kStationPos[targetIndex[v]]))
		actionArray:addObject(CCScaleTo:create(0.5, MainScene.elementScale * kStationScale[targetIndex[v]]))
		local spawn = CCSpawn:create(actionArray)
		
		local seqArray = CCArray:create()
		seqArray:addObject(spawn)
		seqArray:addObject(CCCallFuncN:create(function (node)
			_isMove = true
            stopScheduler()
        end))
		local seqAction = CCSequence:create(seqArray)
		_championArray[i]:runAction(seqAction)
        startScheduler()
    end
end

function stopScheduler()
    if _updateScheduler ~= nil then
		_bgLayer:stopAction(_updateScheduler)
		_updateScheduler = nil
	end
end

function startScheduler()
    if _updateScheduler == nil then
        _updateScheduler = schedule(_bgLayer,scheduler, 0.05)
    end
end

--[[
    @des: 定时器
--]]
function scheduler()
    refreshZOrder()
end

--[[
    @des: 刷新Z轴
--]]
function refreshZOrder()
    for i = 1, 3 do
        local champion = _championArray[i]
        _moveLayer:reorderChild(champion, g_winSize.height - champion:getPositionY())
    end
end

function updateTopUi( ... )
	local userInfo = UserModel.getUserInfo()
	-- modified by yangrui at 2015-12-03
	m_silverLabel:setString(string.convertSilverUtilByInternational(tonumber(userInfo.silver_num)))
	m_goldLabel:setString(tonumber(userInfo.gold_num))
end



-----------------------------------[[ 回调事件 ]]-----------------------------------------


local lastMove	 	= 0
function touchCallback(  eventType, pos)
	local x = pos[1]
	local y = pos[2]
	if(_isMove == false) then
 		return
 	end
	if(eventType == "began") then
		lastMove = x
	elseif(eventType == "moved") then

	elseif(eventType == "ended") then
		if(x > lastMove) then
			if(_selectIndex == 1) then
				_selectIndex = 3
			else
				_selectIndex  = _selectIndex - 1
			end
		elseif(x < lastMove) then
			--左划
			if(_selectIndex == 3) then
				_selectIndex = 1
			else
				_selectIndex  = _selectIndex + 1
			end
		else
			print("don't touch move")
		end
		updateRolePos()
	else
		print("cancel")
	end
end


--[[
	@des : 关闭按钮回调事件
--]]
function closeButtonCallFunc( ... )
	require "script/ui/lordWar/LordWarMainLayer"
	local layer = LordWarMainLayer.createLayer()
	MainScene.changeLayer(layer, "LordWarMainLayer",LordWarMainLayer)
end


--[[
	@des : 膜拜按钮回调事件
--]]
function worshipButtonCallback( ... )
	require "script/ui/lordWar/CheersLayer"
	CheersLayer.show()
end



