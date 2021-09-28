-- Filename: NewTreasInfoLayer.lua
-- Author: Zhang zihang
-- Date: 2014-2-17
-- Purpose: 该文件用于: 含宝物羁绊信息的

module("NewTreasInfoLayer", package.seeall)

require "script/ui/item/ItemUtil"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "script/ui/treasure/evolve/TreasureEvolveMainView"
require "script/ui/treasure/evolve/TreasureEvolveUtil"
require "script/ui/item/EquipCardSprite"
require "script/ui/formation/ChangeEquipLayer"
require "script/ui/item/TreasReinforceLayer"
require "script/ui/item/TreasCardSprite"
require "script/ui/treasure/TreasureData"
require "script/ui/bag/RuneData"
require "script/audio/AudioUtil"
require "script/model/affix/TreasAffixModel"
require "script/ui/treasure/develop/TreasureDevelopData"

local Tag_Water 	= 9001
local Tag_Enforce	= 9002
local Tag_Change 	= 9003
local Tag_Remove 	= 9004

local _bgLayer 				= nil
local _item_tmpl_id 		= nil
local _item_id 				= nil
local _isEnhance 			= false
local _isWater 				= false 
local _isChange 			= false 
local _itemDelegateAction	= nil
local _hid					= nil
local _pos_index			= nil	
local _menu_priority 		= nil	
local enhanceBtn 			= nil
local _treasData 			= {}
local _showType 			= nil    
local _isShowRobTreasure 	= nil

local _comfirmBtn 			= nil

local _jinlianBtn			= nil  	 

local bgSprite 				= nil

local bulletinLayerSize		= nil
local bottomBgSize			= nil
local bottomBgSize			= nil
local _zOrderNum 		 	= nil

local _xiangBg 				= nil
local _runeSpTab 			= {}
local _treasInfoGot        --从参数接收的宝物信息 用于创建对方阵容中得宝物弹板
local _viewOther           --是否是查看别人的阵容中得宝物界面
local _posX = {0.12,0.37,0.62,0.87}

--------------------------------------------------------------
-- 重新计算属性
local _curAttrTab 			= nil --当前属性

local function init()
	_bgLayer 			= nil
	_item_tmpl_id 		= nil
	_item_id 			= nil
	_isEnhance 			= false
	_isWater 			= false 
	_isChange 			= false 
	_itemDelegateAction	= nil
	_hid				= nil
	_pos_index			= nil	
	_menu_priority		= nil
	enhanceBtn 			= nil
	_treasData 			= {}
	_showType 			= nil    
	_comfirmBtn 		= nil
	_jinlianBtn			= nil 
	bgSprite 			= nil
	bulletinLayerSize 	= nil
	bottomBgSize		= nil
	topSpriteSize 		= nil
	_zOrderNum 		 	= nil
	_xiangBg 			= nil
	_runeSpTab 			= {}
	_curAttrTab 		= nil
	_treasInfoGot       = {}
	_viewOther = nil
end 

local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    	print("moved")
    else
        print("end")
	end
end

local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _menu_priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

local function closeAction( ... )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil
	end
end

local function closeAction_2( ... )
	closeAction()
	if(_itemDelegateAction)then
		_itemDelegateAction(_item_id)
	end
end

-- 卸装回调
local function removeArmingCallback( cbFlag, dictData, bRet )
	require "script/ui/hero/HeroFightForce"

	if(dictData.err == "ok")then
		--战斗力信息
		--added by Zhang Zihang
		local _lastFightValue = HeroFightForce.dealParticularValues(_hid)

		closeAction_2()
		HeroModel.removeTreasFromHeroBy(_hid, _pos_index)
		FormationLayer.refreshEquipAndBottom()

		--战斗力信息
		--added by Zhang Zihang
		local _nowFightValue = HeroFightForce.dealParticularValues(_hid)

		require "script/model/utils/UnionProfitUtil"
		UnionProfitUtil.refreshUnionProfitInfo()

		ItemUtil.showAttrChangeInfo(_lastFightValue,_nowFightValue)
	end
end

local function menuAction( tag, itemBtn )
	if(tag == 12345)then
		closeAction_2()
		return
	end
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(tag == Tag_Water) then
		-- TODO
		if not DataCache.getSwitchNodeState(ksSwitchTreasureFixed,true) then
        	return
   		end
		-- 精炼装备
		print(GetLocalizeStringBy("key_2584"))
		closeAction()
		local treaEvolveLayer = TreasureEvolveMainView.createLayer(_item_id)
		if(MainScene.getOnRunningLayerSign() == "formationLayer") then
			TreasureEvolveMainView.setFromLayerTag(TreasureEvolveMainView.kFormationListTag)
		end
		MainScene.changeLayer(treaEvolveLayer, "treaEvolveLayer")
	elseif(tag == Tag_Enforce)then
		-- 强化宝物
		local isShow = nil 
		if(_isChange == true)then
			isShow = false
		else
			isShow = true
		end
		local enforceLayer = TreasReinforceLayer.createLayer(_item_id, _itemDelegateAction, isShow)
		local onRunningLayer = MainScene.getOnRunningLayer()
		onRunningLayer:addChild(enforceLayer, 10)
		closeAction()
	elseif(tag == Tag_Change)then
		-- 更换装备
		local changeEquipLayer = ChangeEquipLayer.createLayer( nil, tonumber(_hid), tonumber(_pos_index), true)
		MainScene.changeLayer(changeEquipLayer, "changeEquipLayer")
		closeAction_2()
	elseif(tag == Tag_Remove)then
		if(ItemUtil.isTreasBagFull(true, closeAction_2))then
			return
		end
		local args = Network.argsHandler(_hid, _pos_index)
		RequestCenter.hero_removeTreasure(removeArmingCallback,args )
	end
end

--[[
	@des   :进阶
--]]
function developMenuItemmCallback( )
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	closeAction()

	require "script/ui/treasure/develop/TreasureDevelopLayer"
	TreasureDevelopLayer.showLayer(_treasData.item_id)
	if(_isChange == true)then 
		-- 设置界面记忆
		TreasureDevelopLayer.setChangeLayerMark( TreasureDevelopLayer.kTagFormation )
	else
		-- 设置界面记忆
		TreasureDevelopLayer.setChangeLayerMark( TreasureDevelopLayer.kTagBag )
	end
end

local function createBottomPanel()
	local bg = CCSprite:create("images/common/sell_bottom.png")
	bg:setAnchorPoint(ccp(0.5,0))
	bg:setPosition(ccp(bgSprite:getContentSize().width/2,bulletinLayerSize.height*g_fScaleY))
	bg:setScale(g_fScaleX)
	bgSprite:addChild(bg)

	bottomBgSize = bg:getContentSize()

	local actionMenuBar = CCMenu:create()
	actionMenuBar:setPosition(ccp(0, 0))	
	actionMenuBar:setTouchPriority(_menu_priority - 4)
	bg:addChild(actionMenuBar)

	-- 更换
	local changeBtn = nil
	local removeBtn = nil
	if(_isChange == true) then
		--兼容东南亚英文版
 		if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
 			changeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_1543"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 		else
 			changeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_1543"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 		end
		changeBtn:setAnchorPoint(ccp(0.5, 0.5))
	    changeBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.1))
	    changeBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(changeBtn, 1, Tag_Change)

		--兼容东南亚英文版
 		if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
 			removeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_2933"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 		else
 			removeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_2933"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 		end
		removeBtn:setAnchorPoint(ccp(0.5, 0.5))
	    removeBtn:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height*0.1))
	    removeBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(removeBtn, 1, Tag_Remove)

	end
	-- 强化
	if(_isEnhance == true) then
		--兼容东南亚英文版
 		if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
 			enhanceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_3391"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 		else
 			enhanceBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_3391"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 		end
		enhanceBtn:setAnchorPoint(ccp(0.5, 0.5))
	    enhanceBtn:setPosition(ccp(bgSprite:getContentSize().width*0.8, bgSprite:getContentSize().height*0.1))
	    enhanceBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(enhanceBtn, 1, Tag_Enforce)
	end

	-- 精炼
	if(_isWater == true  and tonumber(_treasData.itemDesc.isUpgrade) ==1) then
		--兼容东南亚英文版
 		if (Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
 			_jinlianBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_3227"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
 		else
			_jinlianBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_3227"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		end
		_jinlianBtn:setAnchorPoint(ccp(0.5, 0.5))
		_jinlianBtn:registerScriptTapHandler(menuAction)
	    _jinlianBtn:setPosition(ccp(bgSprite:getContentSize().width*0.25, bgSprite:getContentSize().height*0.1))
		actionMenuBar:addChild(_jinlianBtn, 1, Tag_Water)
	end

	if(_isChange == true)then
		changeBtn:setPosition(ccp(bg:getContentSize().width*0.2, bg:getContentSize().height*0.5))
		enhanceBtn:setPosition(ccp(bg:getContentSize().width*0.8, bg:getContentSize().height*0.5))
		removeBtn:setPosition(ccp(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5))
		-- 当可以精炼时
		if(_isWater == true  and tonumber(_treasData.itemDesc.isUpgrade) ==1) then
			changeBtn:setPosition(ccp(bg:getContentSize().width*0.15, bg:getContentSize().height*0.5))
			enhanceBtn:setPosition(ccp(bg:getContentSize().width*0.615, bg:getContentSize().height*0.5))
			removeBtn:setPosition(ccp(bg:getContentSize().width*0.38, bg:getContentSize().height*0.5))
			_jinlianBtn:setPosition(ccp(bg:getContentSize().width*0.85,bg:getContentSize().height*0.5))
		end
	elseif(_isEnhance == true) then
		enhanceBtn:setPosition(ccp(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5))
		if(_isWater == true  and tonumber( _treasData.itemDesc.isUpgrade)==1) then
			enhanceBtn:setPosition(ccp(bg:getContentSize().width*0.75, bg:getContentSize().height*0.5))
			_jinlianBtn:setPosition(ccp(bg:getContentSize().width*0.25, bg:getContentSize().height*0.5))
		end
	end
	if(_showType == 2 or _showType == 99)then
		-- 确定按钮
		_comfirmBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		_comfirmBtn:setAnchorPoint(ccp(0.5, 0.5))
		_comfirmBtn:setPosition(ccp(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5))
		_comfirmBtn:registerScriptTapHandler(menuAction)
		actionMenuBar:addChild(_comfirmBtn,1, 12345)
	end

	if(_isShowRobTreasure == true) then
		-- 确定按钮
		_comfirmBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_2988"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		_comfirmBtn:setAnchorPoint(ccp(0.5, 0.5))
		_comfirmBtn:setPosition(ccp(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5))
		_comfirmBtn:registerScriptTapHandler(function ( ... )
			closeAction_2()
			if(DataCache.getSwitchNodeState( ksSwitchRobTreasure ) ~= true) then
				return
			end
			require "script/ui/treasure/TreasureMainView"
			local treasureLayer = TreasureMainView.create()
			MainScene.changeLayer(treasureLayer,"treasureLayer")
		end)
		actionMenuBar:addChild(_comfirmBtn,1, 12345)
	end
end

local function createBackGround()
	bulletinLayerSize = BulletinLayer.getLayerContentSize()

	local bgYPosition = g_winSize.height*0.5-bulletinLayerSize.height*g_fScaleY

	local fullRect = CCRectMake(0,0,196, 198)
	local insetRect = CCRectMake(50,50,96,98)
	bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	bgSprite:setContentSize(CCSizeMake(g_winSize.width, g_winSize.height))
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, bgYPosition))
	--bgSprite:setScale(g_fScaleX)
	_bgLayer:addChild(bgSprite, 1)

	local topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height))
	topSprite:setScale(g_fScaleX)
	bgSprite:addChild(topSprite, 2)

	topSpriteSize = topSprite:getContentSize()

	--根据不同情况标题名称不同
	if(_showType == 2)then
		-- 好运
		local goodluck = CCSprite:create("images/common/luck.png")
		goodluck:setPosition(ccp(topSprite:getContentSize().width/2,topSprite:getContentSize().height*0.5))
		goodluck:setAnchorPoint(ccp(0.5,0.5))
		topSprite:addChild(goodluck)
	else
		-- 正常
		local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2072"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	    titleLabel:setAnchorPoint(ccp(0.5,0.5))
	    titleLabel:setPosition(ccp( ( topSprite:getContentSize().width)/2, topSprite:getContentSize().height*0.5))
	    topSprite:addChild(titleLabel)
	end

	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	topSprite:addChild(closeMenuBar)
	
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(topSprite:getContentSize().width*1.01, topSprite:getContentSize().height*0.54))
    closeBtn:registerScriptTapHandler(closeAction_2)
	closeMenuBar:addChild(closeBtn)
	closeMenuBar:setTouchPriority(_menu_priority-4)

	createBottomPanel()
end

local function getEvolveDiamondSp(limitLv, curWasterLv )
	local diamondBg= CCScale9Sprite:create("images/hero/transfer/bg_ng_orange.png")
	diamondBg:setContentSize(CCSizeMake(275, 30))
	require "script/ui/treasure/TreasureUtil"
	for i=1, 10 do
		local sprite = nil
		if(i <= (curWasterLv)%10) then
			sprite 	= TreasureUtil.getFixedLevelSprite(curWasterLv)
		else
			sprite 	= CCSprite:create("images/common/big_gray_gem.png")
		end

		if math.floor(tonumber(curWasterLv)/10) >= 1 and tonumber(curWasterLv)%10==0  then
			sprite 	= TreasureUtil.getFixedLevelSprite(curWasterLv)
		end
		
		sprite:setAnchorPoint(ccp(0.5, 0.5))
		local dis  	= 27
		local x    	= dis/2 + dis * (i-1)
		local y 	= diamondBg:getContentSize().height/2
		sprite:setPosition(ccp(x , y))
		diamondBg:addChild(sprite)
		sprite:setScale(0.8)
	end
	return diamondBg
end

local function createUnionCell(heroTempId,unionId)
	local attrBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
	attrBg:setPreferredSize(CCSizeMake(590, 140))

	local lineSprite = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite:setAnchorPoint(ccp(0.5, 0.5))
	lineSprite:setScaleX(5)
	lineSprite:setPosition(ccp(attrBg:getContentSize().width*0.5, attrBg:getContentSize().height*0.5+20))
	attrBg:addChild(lineSprite)

	require "script/ui/item/ItemSprite"
	local heroImage
	require "script/model/user/UserModel"
	local userInfo = UserModel.getUserInfo()
	-- print("玩家信息")
	-- print_t(userInfo)
	require "script/model/utils/HeroUtil"
	if tonumber(heroTempId) == 1 then
		--这里要判断是否有时装
		-- local genderId = HeroModel.getSex(userInfo.htid)
		-- local fashionInfo = HeroModel.getNecessaryHero().equip.dress
		-- if (table.count(fashionInfo) == 0 or tonumber(fashionInfo["1"]) == 0) then
		-- 	heroImage = HeroUtil.getHeroIconByHTID(userInfo.htid,nil,nil)
		-- else
		-- 	heroImage = HeroUtil.getHeroIconByHTID(userInfo.htid,userInfo.dress["1"].item_template_id,genderId, UserModel.getVipLevel())
		-- end
		local genderId = HeroModel.getSex(userInfo.htid)
		if UserModel.getDressIdByPos(1) == nil then
			heroImage = HeroUtil.getHeroIconByHTID(userInfo.htid,nil,nil)
		else
			heroImage = HeroUtil.getHeroIconByHTID(userInfo.htid,UserModel.getDressIdByPos(1),genderId, UserModel.getVipLevel())
		end
	else
		heroImage = HeroUtil.getHeroIconByHTID(heroTempId,nil,nil,nil )
	end

	heroImage:setPosition(ccp(10, attrBg:getContentSize().height-10))
	heroImage:setAnchorPoint(ccp(0,1))
	attrBg:addChild(heroImage)

	local heroName
	if tonumber(heroTempId) == 1 then 
		heroName = CCRenderLabel:create(userInfo.uname, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	else
		require "db/DB_Heroes"
		local heroInfo = DB_Heroes.getDataById(heroTempId)
		heroName = CCRenderLabel:create(heroInfo.name, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	end
    heroName:setColor(ccc3(0xff, 0xf6, 0x00))
    heroName:setAnchorPoint(ccp(0.5, 1))
    heroName:setPosition(ccp( heroImage:getContentSize().width*0.5, -5))
    heroImage:addChild(heroName)

    require "db/DB_Union_profit"

    local unionInfo = DB_Union_profit.getDataById(unionId)
    local unionName = CCRenderLabel:create(unionInfo.union_arribute_name, g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    unionName:setColor(ccc3(0x2c, 0xdb, 0x23))
    unionName:setAnchorPoint(ccp(0.5, 0.5))
    unionName:setPosition(ccp( attrBg:getContentSize().width*0.5, attrBg:getContentSize().height*2/3+20))
    attrBg:addChild(unionName)

    local unionScribe = CCLabelTTF:create(unionInfo.union_arribute_desc, g_sFontName, 20)
    unionScribe:setColor(ccc3(0x78, 0x25, 0x00))
    unionScribe:setAnchorPoint(ccp(0.5, 0.5))
    unionScribe:setPosition(ccp( attrBg:getContentSize().width*0.5, attrBg:getContentSize().height/3))
    attrBg:addChild(unionScribe)

	return attrBg
end

local function fnCreateDetailContentLayer(equip_desc,attr_arr,score_t,ext_active,enhanceLv)
	--创建ScrollView
	local contentScrollView = CCScrollView:create()
	contentScrollView:setTouchPriority(_menu_priority-3 or -703)
	local scrollViewHeight = g_winSize.height - (topSpriteSize.height + bulletinLayerSize.height + bottomBgSize.height)*g_fScaleY
	contentScrollView:setViewSize(CCSizeMake(g_winSize.width, scrollViewHeight))
	contentScrollView:setDirection(kCCScrollViewDirectionVertical)
	local layer = CCLayer:create()
	contentScrollView:setContainer(layer)

	layer:setScale(g_fScaleX)

	--羁绊数
	local unionNum = 0

	local firstTable = {}

	if _treasData.itemDesc.union_info and (_treasData.itemDesc.union_info ~= nil) then
		firstTable = string.splitByChar(_treasData.itemDesc.union_info,",")
		print(GetLocalizeStringBy("key_2905"))
		print_t(firstTable)

		unionNum = table.count(firstTable)
		print(unionNum)
	end

	local layerHeight = 600 + 150*unionNum 
	if(_isWater == true  and tonumber(_treasData.itemDesc.isUpgrade) ==1) then
		if( _treasData.item_id and tonumber(_treasData.itemDesc.can_evolve) == 1)then
			layerHeight = layerHeight + table.count(attr_arr)*30 + table.count(ext_active)*30+110
		else
			layerHeight = layerHeight + table.count(attr_arr)*30 + table.count(ext_active)*30 -100
		end
	end
	if(_viewOther and tonumber(_treasData.itemDesc.can_evolve) == 1)then
		--如果是在查看对方阵容中看宝物的弹板
		layerHeight = layerHeight + table.count(attr_arr)*30 + table.count(ext_active)*30+100
	end

	layer:setContentSize(CCSizeMake(640,layerHeight))
	layer:setPosition(ccp(0,scrollViewHeight-layerHeight*g_fScaleX))

	contentScrollView:setPosition(ccp(0,(bulletinLayerSize.height + bottomBgSize.height)*g_fScaleY))

	bgSprite:addChild(contentScrollView)

	--描述数据处理
	local descString = ""
	for k_id,v_num in pairs(attr_arr) do
        local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(k_id, v_num)
	    descString = descString .. affixDesc.sigleName .. " +"
		descString = descString .. displayNum .. "\n"
	end

	local beginLine = 0

	--主内容
	if(_showType == 2)then
		--好运
		local explainLabel1 = CCRenderLabel:create(GetLocalizeStringBy("key_1682"), g_sFontPangWa,33,1,ccc3(0x00,0x00,0x00),type_shadow)
		explainLabel1:setPosition(ccp(layer:getContentSize().width/2-100, layer:getContentSize().height-50))
		explainLabel1:setColor(ccc3(0xff,0xf0,0x00))
		explainLabel1:setAnchorPoint(ccp(0.5,0.5))
		layer:addChild(explainLabel1)
		
		local explainLabel2 = CCRenderLabel:create(equip_desc.name, g_sFontPangWa,33,1,ccc3(0x00,0x00,0x00),type_shadow)
		explainLabel2:setPosition(ccp(layer:getContentSize().width/2+20, layer:getContentSize().height-50))
		explainLabel2:setColor(ccc3(0x0b,0xe5,0x00))
		explainLabel2:setAnchorPoint(ccp(0,0.5))
		layer:addChild(explainLabel2)
	end

	-- 卡牌
	local cardSprite = nil
	if(not _viewOther)then
		cardSprite = TreasCardSprite.createSprite(_item_tmpl_id, _item_id)
	else
		cardSprite = TreasCardSprite.createSprite(_item_tmpl_id, _item_id,_treasData)
	end
	cardSprite:setAnchorPoint(ccp(0.5, 1))
	cardSprite:setPosition(ccp(layer:getContentSize().width*0.25, layer:getContentSize().height))
	layer:addChild(cardSprite)

	-- 属性背景
	local fullRect_attr = CCRectMake(0,0,61,47)
	local insetRect_attr = CCRectMake(10,10,41,27)
	local attrBg = CCScale9Sprite:create("images/copy/fort/textbg.png", fullRect_attr, insetRect_attr)
	local attrBgHight = table.count(attr_arr)*30 + table.count(ext_active)*30 + 320
	attrBg:setPreferredSize(CCSizeMake(282, attrBgHight))
	attrBg:setAnchorPoint(ccp(0.5, 1))
	attrBg:setPosition(ccp(layer:getContentSize().width*0.75, layer:getContentSize().height))
	layer:addChild(attrBg)
	local deltaHeight = attrBgHight
    if(cardSprite:getContentSize().height > attrBgHight)then
    	deltaHeight = cardSprite:getContentSize().height
    end

	beginLine = layer:getContentSize().height-deltaHeight-30

	-- 名称
	local quality = ItemUtil.getTreasureQualityByItemInfo( _treasData )
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameStr = ItemUtil.getTreasureNameByItemInfo( _treasData )
	local nameLabel = CCRenderLabel:create(nameStr, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameLabel:setAnchorPoint(ccp(0,0))
    nameLabel:setColor(nameColor)
    attrBg:addChild(nameLabel)
    local enhanceLv = 0
    if(not table.isEmpty(_treasData.va_item_text))then
    	enhanceLv = _treasData.va_item_text.treasureLevel
    end
    -- 强化
    local enhanceLvLabel = CCRenderLabel:create("+" .. enhanceLv, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    enhanceLvLabel:setAnchorPoint(ccp(0,0))
    enhanceLvLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
    attrBg:addChild(enhanceLvLabel)
    -- 算宽度
    local temp_length = nameLabel:getContentSize().width + enhanceLvLabel:getContentSize().width + 10
    nameLabel:setPosition(ccp((attrBg:getContentSize().width-temp_length)/2, attrBg:getContentSize().height*0.9))
    enhanceLvLabel:setPosition(ccp((attrBg:getContentSize().width-temp_length)/2 + nameLabel:getContentSize().width+5, attrBg:getContentSize().height*0.9))
	-- 简介
	local infoTitleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2371"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
    infoTitleLabel:setColor(ccc3(0x8a, 0xff, 0x00))
    infoTitleLabel:setAnchorPoint(ccp(0, 0))
    infoTitleLabel:setPosition(ccp( attrBg:getContentSize().width*0.08, attrBg:getContentSize().height*0.84))
    attrBg:addChild(infoTitleLabel)
    -- 分割线
	local lineSprite_0 = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite_0:setAnchorPoint(ccp(0, 1))
	lineSprite_0:setScaleX(2)
	lineSprite_0:setPosition(ccp(attrBg:getContentSize().width*0.02, attrBg:getContentSize().height*0.83))
	attrBg:addChild(lineSprite_0)
	-- 描述
	local noLabel = CCLabelTTF:create(equip_desc.info, g_sFontName, 23, CCSizeMake(245, 100), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	noLabel:setColor(ccc3(0x78, 0x25, 0x00))
	noLabel:setAnchorPoint(ccp(0, 1))
	noLabel:setPosition(ccp(attrBg:getContentSize().width*0.07, attrBg:getContentSize().height*0.81))
	attrBg:addChild(noLabel)
    -- 当前属性
	local attrLabelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1293"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	attrLabelTitle:setColor(ccc3(0x8a, 0xff, 0x00))
	attrLabelTitle:setAnchorPoint(ccp(0, 1))
	attrLabelTitle:setPosition(ccp(attrBg:getContentSize().width*0.08, noLabel:getPositionY()-noLabel:getContentSize().height-3 ))
	attrBg:addChild(attrLabelTitle)
	-- 分割线
	local lineSprite = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite:setAnchorPoint(ccp(0, 1))
	lineSprite:setScaleX(2)
	lineSprite:setPosition(ccp(attrBg:getContentSize().width*0.02, attrLabelTitle:getPositionY()-attrLabelTitle:getContentSize().height-5))
	attrBg:addChild(lineSprite)
	--经验金银书马经验信息
	local treasureExp= 0
	if(not table.isEmpty(_treasData.va_item_text))then
    	treasureExp = _treasData.va_item_text.treasureExp
    end
	if _treasData.itemDesc.isExpTreasure and (tonumber(_treasData.itemDesc.isExpTreasure) == 1) then
		local add_exp = (tonumber(_treasData.itemDesc.base_exp_arr) + tonumber(treasureExp))
		local descLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3242") .. add_exp , g_sFontName, 23, CCSizeMake(225, 80), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
		descLabel:setColor(ccc3(0x78, 0x25, 0x00))
		descLabel:setAnchorPoint(ccp(0, 0.5))
		descLabel:setPosition(ccp(attrBg:getContentSize().width*0.07, attrBg:getContentSize().height*0.4))
		attrBg:addChild(descLabel)
	end
	-- 描述
	local descLabel = CCLabelTTF:create(descString, g_sFontName, 23, CCSizeMake(225, table.count(attr_arr)*25 ), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	descLabel:setColor(ccc3(0x78, 0x25, 0x00))
	descLabel:setAnchorPoint(ccp(0, 1))
	descLabel:setPosition(ccp(attrBg:getContentSize().width*0.07, lineSprite:getPositionY()-lineSprite:getContentSize().height-2))
	attrBg:addChild(descLabel)
	-- 解锁属性
	local enchanceLabelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1422"), g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
	enchanceLabelTitle:setColor(ccc3(0x8a, 0xff, 0x00))
	enchanceLabelTitle:setAnchorPoint(ccp(0, 1))
	enchanceLabelTitle:setPosition(ccp(attrBg:getContentSize().width*0.08,descLabel:getPositionY()-descLabel:getContentSize().height-5))
	attrBg:addChild(enchanceLabelTitle)
	-- 分割线
	local lineSprite2 = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite2:setAnchorPoint(ccp(0, 1))
	lineSprite2:setScaleX(2)
	lineSprite2:setPosition(ccp(attrBg:getContentSize().width*0.02, enchanceLabelTitle:getPositionY()-enchanceLabelTitle:getContentSize().height-2))
	attrBg:addChild(lineSprite2)
	local posY = lineSprite2:getPositionY()-lineSprite2:getContentSize().height-2
	local desArr = {}
	for key, active_info in pairs(ext_active) do
        local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(active_info.attId, active_info.num)
	    local t_descString = affixDesc.sigleName .. " +" .. displayNum 
		local ccc3_c = nil
		if(active_info.isOpen)then
			ccc3_c = ccc3(0x78, 0x25, 0x00)
		else
			ccc3_c = ccc3(100,100,100)
			if( active_info.needDevelopLv )then
				t_descString = t_descString .. "\n" .. GetLocalizeStringBy("lic_1560",active_info.needDevelopLv,active_info.openLv)
			else
				t_descString = t_descString .. "(" .. active_info.openLv .. GetLocalizeStringBy("key_1066")
			end
		end
		-- 描述
		local descLabel_PL = CCLabelTTF:create(t_descString, g_sFontName, 23)
		descLabel_PL:setColor(ccc3_c)
		descLabel_PL:setAnchorPoint(ccp(0, 0))
		local tem = 25
		if(active_info.needDevelopLv and active_info.isOpen == false)then
			tem = 50
		end
		posY = posY-tem
		descLabel_PL:setPosition(ccp(attrBg:getContentSize().width*0.07, posY))
		attrBg:addChild(descLabel_PL)
		desArr[key] = descLabel_PL
	end

	-- 对可以洗练进行特殊处理
	if(_isWater == true  and tonumber(_treasData.itemDesc.isUpgrade) ==1) then
		
		local baseInfo = {}
		local treasureAffixInfo = TreasureEvolveUtil.getOldAffix(_treasData.item_id)
		local affix= treasureAffixInfo.affix
		local lockAffix= treasureAffixInfo.lockAffix

		if(not  table.isEmpty( affix)  ) then
			for i=1, #affix do
				local tempTable= {}
				local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(affix[i].id, tonumber(affix[i].num))
				tempTable.desc=  affix[i].name .. "+" .. displayNum
				tempTable.isOpen = true
				affix[i].isOpen = true
				table.insert(baseInfo ,affix[i])
			end
		end

		if(not table.isEmpty(lockAffix)) then
			for i=1, #lockAffix do
				local tempTable= {}
				local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(lockAffix[i].id, tonumber(lockAffix[i].num))
				tempTable.desc=  lockAffix[i].name .. "+" .. displayNum .. "(" .. lockAffix[i].level .. GetLocalizeStringBy("key_3229")
				tempTable.isOpen = false
				lockAffix[i].isOpen = false
				table.insert(baseInfo ,lockAffix[i])
			end
		end

		attrBgHight = attrBgHight + table.count(baseInfo)*30+60
		attrBg:setPreferredSize(CCSizeMake(283, attrBgHight ))

		-- 名称
		local height = attrBg:getContentSize().height-nameLabel:getContentSize().height -10
		local temp_length = nameLabel:getContentSize().width + enhanceLvLabel:getContentSize().width + 10
   		nameLabel:setPosition(ccp((attrBg:getContentSize().width-temp_length)/2, height))
    	enhanceLvLabel:setPosition(ccp((attrBg:getContentSize().width-temp_length)/2 + nameLabel:getContentSize().width+5, height))

    	height = height - infoTitleLabel:getContentSize().height
    	-- 简介
    	infoTitleLabel:setPosition(ccp( attrBg:getContentSize().width*0.08, height))
    	lineSprite_0:setPosition(attrBg:getContentSize().width*0.02, height -4)
    	noLabel:setPosition(attrBg:getContentSize().width*0.07, height- 6)

    	-- 当前属性
    	attrLabelTitle:setPosition(ccp(attrBg:getContentSize().width*0.08, noLabel:getPositionY()-noLabel:getContentSize().height-3 ))
    	lineSprite:setPosition(ccp(attrBg:getContentSize().width*0.02, attrLabelTitle:getPositionY()-attrLabelTitle:getContentSize().height-5))
		descLabel:setPosition(ccp(attrBg:getContentSize().width*0.07, lineSprite:getPositionY()-lineSprite:getContentSize().height-2))

		-- 进阶下一层增加属性
		local posY = descLabel:getPositionY()-descLabel:getContentSize().height
		if(tonumber(_treasData.itemDesc.can_evolve) == 1)then
			local curDevelopNum = tonumber(_treasData.va_item_text.treasureDevelop) or -1
			local addAttrTab = TreasureDevelopData.getDevelopAttrTab(_treasData.item_template_id, curDevelopNum+1 )
			for k,v in pairs(addAttrTab) do
				local str = v.name .. "+" .. v.showNum .. GetLocalizeStringBy("lic_1562",curDevelopNum+1)
				local addAttrFont = CCLabelTTF:create(str, g_sFontName, 23)
				addAttrFont:setColor(ccc3(100,100,100))
				addAttrFont:setAnchorPoint(ccp(0,1))
				addAttrFont:setPosition(ccp(attrBg:getContentSize().width*0.07, posY))
				attrBg:addChild(addAttrFont)
				posY = posY - 30
			end
		end

		-- 精炼属性
		local waterLabelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_2155"),  g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x0d), type_stroke)
		waterLabelTitle:setAnchorPoint(ccp(0,1))
		waterLabelTitle:setPosition(attrBg:getContentSize().width*0.08, posY)
		waterLabelTitle:setColor(ccc3(0x8a, 0xff, 0x00))
		attrBg:addChild(waterLabelTitle)
		-- 分割线
		local lineSprite3 = CCSprite:create("images/item/equipinfo/line.png")
		lineSprite3:setAnchorPoint(ccp(0, 1))
		lineSprite3:setScaleX(2)
		lineSprite3:setPosition(ccp(attrBg:getContentSize().width*0.02, waterLabelTitle:getPositionY()-waterLabelTitle:getContentSize().height-2))
		attrBg:addChild(lineSprite3)
		local diamondBg= getEvolveDiamondSp(tonumber(_treasData.itemDesc.max_upgrade_level ), tonumber(_treasData.va_item_text.treasureEvolve) )
		diamondBg:setAnchorPoint(ccp(0,1))
		diamondBg:setPosition(4, lineSprite3:getPositionY()-lineSprite3:getContentSize().height-2)
		attrBg:addChild(diamondBg)

		local posY = diamondBg:getPositionY()-diamondBg:getContentSize().height-2
		for i=1 , #baseInfo do
			local vInfo = baseInfo[i]

			posY  = posY -30
			-- 描述
			local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(vInfo.id, tonumber(vInfo.num))
			local descLabel_PL = CCLabelTTF:create(vInfo.name .. "+" .. displayNum, g_sFontName, 23)
			if(vInfo.isOpen)then
			 	ccc3_c = ccc3(0x00, 0x70, 0xae)

				descLabel_PL:setColor(ccc3_c)
				descLabel_PL:setAnchorPoint(ccp(0, 0))
				descLabel_PL:setPosition(ccp(attrBg:getContentSize().width*0.07, posY))
				attrBg:addChild(descLabel_PL)
			else
				ccc3_c = ccc3(100,100,100)
				descLabel_PL:setColor(ccc3_c)
				descLabel_PL:setString(vInfo.name .. "+" .. displayNum)
				local gemSprite 	= CCSprite:create("images/common/small_gem.png")
				local affixLabel 	= CCLabelTTF:create(vInfo.level .. GetLocalizeStringBy("key_3229"),g_sFontName, 23)
				affixLabel:setColor(ccc3_c)
				local desNode       = BaseUI.createHorizontalNode({descLabel_PL})--, gemSprite, affixLabel})
				desNode:setAnchorPoint(ccp(0, 0))
				desNode:setPosition(ccp(attrBg:getContentSize().width*0.07, posY))
				attrBg:addChild(desNode)
			end
		end

		-- 解锁属性
		enchanceLabelTitle:setPosition(attrBg:getContentSize().width*0.08, posY-10)
		lineSprite2:setPosition(ccp(attrBg:getContentSize().width*0.02, enchanceLabelTitle:getPositionY()-enchanceLabelTitle:getContentSize().height-3))
		local posY = lineSprite2:getPositionY()-lineSprite2:getContentSize().height-2
		for key, desLab in pairs(desArr) do
			local tem = 25
			if(ext_active[key].needDevelopLv and ext_active[key].isOpen == false)then
				tem = 50
			end
			posY = posY-tem
			desLab:setPosition(ccp(attrBg:getContentSize().width*0.07, posY))
		end
		local deltaHeight = attrBgHight
	    if(cardSprite:getContentSize().height > attrBgHight)then
	    	deltaHeight = cardSprite:getContentSize().height
	    end

		beginLine = layer:getContentSize().height-deltaHeight-30
	end

	if( _treasData.item_id and tonumber(_treasData.itemDesc.can_evolve) == 1)then
        if(not _viewOther)then
        	--如果不是查看对方阵容中得宝物弹板  才有进阶按钮
			-- 进阶按钮
			local menu = BTSensitiveMenu:create()
			menu:setPosition(ccp(0, 0))
			layer:addChild(menu)
			menu:setTouchPriority(_menu_priority - 2)
			-- 进阶按钮
			local developMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(170, 73), GetLocalizeStringBy("lic_1559"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			developMenuItem:setAnchorPoint(ccp(0.5, 0))
			developMenuItem:setPosition(ccp( layer:getContentSize().width*0.25, beginLine+10 ))
			menu:addChild(developMenuItem)
			developMenuItem:registerScriptTapHandler(developMenuItemmCallback)
		end

		-- 若可以镶嵌
		local flower1 = CCSprite:create("images/copy/herofrag/cutFlower.png")
		flower1:setPosition(ccp(layer:getContentSize().width*0.5, beginLine))
		flower1:setAnchorPoint(ccp(0.5,0.5))
		layer:addChild(flower1)
		-- 战马印 兵书符
		local typeName = {GetLocalizeStringBy("lic_1538"),GetLocalizeStringBy("lic_1539")}
		local titleFont = CCRenderLabel:create(typeName[tonumber(_treasData.itemDesc.type)], g_sFontPangWa,30,2,ccc3(0xff,0xff,0xff),type_shadow)
		titleFont:setPosition(ccp(layer:getContentSize().width*0.5, beginLine))
		titleFont:setColor(ccc3(0x78,0x25,0x00))
		titleFont:setAnchorPoint(ccp(0.5,0.5))
		layer:addChild(titleFont)

		-- 镶嵌背景
		_xiangBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
		_xiangBg:setContentSize(CCSizeMake(590, 180))
		_xiangBg:setAnchorPoint(ccp(0.5,1))
		_xiangBg:setPosition(ccp(layer:getContentSize().width*0.5, beginLine-30))
		layer:addChild(_xiangBg)

		for i=1,4 do
			local runeBg = nil
			if(_viewOther)then
				--看对方阵容中得宝物弹板 获得sprite
				runeBg = getRuneSprite(i)
			else
				--看自己的 获得button 
				runeBg = getRuneButton(i)
			end

			runeBg:setAnchorPoint(ccp(0.5,0.5))
			runeBg:setPosition(ccp(_xiangBg:getContentSize().width*_posX[i], _xiangBg:getContentSize().height*0.5))
			_xiangBg:addChild(runeBg)
			-- 保存
			table.insert(_runeSpTab,runeBg)
		end

		beginLine = beginLine-_xiangBg:getContentSize().height-60
	end

	--若存在羁绊
	if tonumber(unionNum) ~= 0 then
		local flower = CCSprite:create("images/copy/herofrag/cutFlower.png")
		flower:setPosition(ccp(layer:getContentSize().width*0.5, beginLine))
		flower:setAnchorPoint(ccp(0.5,0.5))
		layer:addChild(flower)

		local unionScribe = CCRenderLabel:create(GetLocalizeStringBy("key_2449"), g_sFontPangWa,30,2,ccc3(0xff,0xff,0xff),type_shadow)
		unionScribe:setPosition(ccp(layer:getContentSize().width*0.5, beginLine))
		unionScribe:setColor(ccc3(0x78,0x25,0x00))
		unionScribe:setAnchorPoint(ccp(0.5,0.5))
		layer:addChild(unionScribe)

		local beginCellLine = beginLine-40

		for i = 1,unionNum do
			local secondTable = string.splitByChar(firstTable[i],"|")
			-- print("二级table")
			-- print_t(secondTable)
			local cell = createUnionCell(secondTable[1],secondTable[2])
			cell:setAnchorPoint(ccp(0.5,1))
			cell:setPosition(ccp(layer:getContentSize().width*0.5,beginCellLine-150*(i-1)))
			layer:addChild(cell)
		end
	end
end

local function createUI()
	--数据处理
	local equip_desc = ItemUtil.getItemById(_item_tmpl_id)
	local attr_arr, score_t, ext_active, enhanceLv = {}, {}, {}, 0
	if(_item_id) then
		attr_arr, score_t, ext_active, enhanceLv, _treasData = ItemUtil.getTreasAttrByItemId(_item_id)

		-- 当前属性
		_curAttrTab = TreasAffixModel.getIncreaseAffixByInfo(_treasData)
	elseif(table.isEmpty(_treasInfoGot) == false)then
		_treasData = _treasInfoGot
		attr_arr, score_t, ext_active, enhanceLv, itemDesc = ItemUtil.getTreasAttrByTmplId(_item_tmpl_id)
		-- 当前属性
		_curAttrTab = TreasAffixModel.getTreasureBaseAffix( _item_tmpl_id )
	else
		local itemDesc = nil
		attr_arr, score_t, ext_active, enhanceLv, itemDesc = ItemUtil.getTreasAttrByTmplId(_item_tmpl_id)
		_treasData = {}
		_treasData.item_template_id = _item_tmpl_id
		_treasData.itemDesc = itemDesc
		print_t(itemDesc)
		-- 当前属性
		_curAttrTab = TreasAffixModel.getTreasureBaseAffix( _item_tmpl_id )
	end
	print("_treasData==>")
	print_t(_treasData)
	--创建底层
	createBackGround()

	--创建滑动信息
	fnCreateDetailContentLayer(equip_desc,_curAttrTab,score_t,ext_active,enhanceLv)
end

function createLayer( template_id,  item_id, isEnhance, isWater, isChange, itemDelegateAction, hid_c, pos_index, menu_priority, showType, isShowRobTreasure,p_zOrderNum,p_treasInfoGot,p_viewOther)
	init()
	_menu_priority		= menu_priority
	_item_tmpl_id 		= template_id
	_item_id 			= item_id
	_isEnhance			= isEnhance
	_isWater 			= isWater
	_isChange 			= isChange
	_itemDelegateAction = itemDelegateAction
	_hid				= hid_c
	_pos_index 			= pos_index
	_showType			= showType or 1
	_isShowRobTreasure 	= isShowRobTreasure or nil
	_zOrderNum 			= p_zOrderNum
	_treasInfoGot       = p_treasInfoGot
	_viewOther          = p_viewOther or false
	print("_viewOther",_viewOther)
	print("itemDelegateAction-----", template_id,  item_id, isEnhance, isWater, isChange, itemDelegateAction, menu_priority, _showType)
	if(_menu_priority == nil) then
		_menu_priority = -434
	end
	if(_showType == 2)then
		_menu_priority = -520
	end
	
	_bgLayer = CCLayer:create()

	_bgLayer:registerScriptHandler(onNodeEvent)
	
	--创建UI
	createUI()

	return _bgLayer
end

-- 新手引导
function getGuideObject()
	return enhanceBtn
end

-- 新手引导
function getGuideObject_2()
  	return _comfirmBtn
end  

-------------------------------------------------------------------- 镶嵌相关 ----------------------------------------------------
--[[
	@des 	: 得到符印图标
	@param 	: $p_index 		:第几个符印位置
	@return : sprite
--]]
function getRuneButton(p_index)
	local iconBg = CCSprite:create("images/common/rune_bg_b.png")
	local menuBar = BTSensitiveMenu:create()
	menuBar:setPosition(ccp(0, 0))
	iconBg:addChild(menuBar)
	menuBar:setTouchPriority(_menu_priority - 2)
	local normalSp = CCSprite:create()
	normalSp:setContentSize(CCSizeMake(98,96))
	local selectSp = CCSprite:create()
	selectSp:setContentSize(CCSizeMake(98,96))
	local menuItem = CCMenuItemSprite:create(normalSp, selectSp)
	menuItem:setAnchorPoint(ccp(0.5,0.5))
	menuItem:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
	menuBar:addChild(menuItem,1,p_index)
	menuItem:registerScriptTapHandler(runeMenuItemCallBack)

	if(_treasData.va_item_text and _treasData.va_item_text.treasureInlay and _treasData.va_item_text.treasureInlay[tostring(p_index)])then
		-- 有符印
		local runeInfo =  _treasData.va_item_text.treasureInlay[tostring(p_index)]
		local runeIcon = ItemSprite.getItemSpriteByItemId(runeInfo.item_template_id)
		runeIcon:setAnchorPoint(ccp(0.5,0.5))
		runeIcon:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5))
		menuItem:addChild(runeIcon)

		-- 符印名字
		local dbData = ItemUtil.getItemById(runeInfo.item_template_id)
	 	local runeName = CCRenderLabel:create(dbData.name,  g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		runeName:setColor(HeroPublicLua.getCCColorByStarLevel(dbData.quality))
		runeName:setAnchorPoint(ccp(0.5,0))
		runeName:setPosition(ccp(runeIcon:getContentSize().width/2,runeIcon:getContentSize().height+15))
		runeIcon:addChild(runeName)
		-- 符印属性
	    local attrTab = RuneData.getRuneAbilityByItemId(runeInfo.item_id)
		if(not table.isEmpty(attrTab) )then
			for i=1,#attrTab do
				local attrLabel = CCLabelTTF:create(attrTab[i].name .. "+" .. attrTab[i].showNum ,g_sFontName,20)
				attrLabel:setColor(ccc3(0x78, 0x25, 0x00))
				attrLabel:setAnchorPoint(ccp(0.5, 1))
				attrLabel:setPosition(ccp(runeIcon:getContentSize().width*0.5,-15-(i-1)*30))
				runeIcon:addChild(attrLabel)
			end
		end
	else
		-- 没有符印
		local isOpen,needNum,isUseLv = TreasureData.getRunePosIsOpen(_item_tmpl_id,_item_id,_treasData,p_index)
		print("isOpen",isOpen,"needNum",needNum,"isUseLv",isUseLv)
		if(isOpen)then
			-- 开启 加号
			local addSprite = ItemSprite.createLucencyAddSprite()
			addSprite:setAnchorPoint(ccp(0.5,0.5))
			addSprite:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5))
			menuItem:addChild(addSprite)
		else
			-- 没开启 锁
			local lockSp = CCSprite:create("images/common/rune_lock_b.png")
			lockSp:setAnchorPoint(ccp(0.5,0.5))
			lockSp:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.4))
			menuItem:addChild(lockSp)
			if(isUseLv == true)then
				local tipStr1 = GetLocalizeStringBy("lic_1540")
				local tipStr2 = needNum
				local tipStr3 = GetLocalizeStringBy("lic_1542")
				local tipStrFont1 = CCRenderLabel:create(tipStr1, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont1:setColor(ccc3(0xff, 0x7e, 0x00))
			    tipStrFont1:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont1:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.7))
			    menuItem:addChild(tipStrFont1,2)
			    local tipStrFont2 = CCRenderLabel:create(tipStr2, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont2:setColor(ccc3(0x00, 0xff, 0x18))
			    tipStrFont2:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont2:setPosition(ccp(menuItem:getContentSize().width*0.3,menuItem:getContentSize().height*0.3))
			    menuItem:addChild(tipStrFont2,2)
			    local tipStrFont3 = CCRenderLabel:create(tipStr3, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont3:setColor(ccc3(0xff, 0xff, 0xff))
			    tipStrFont3:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont3:setPosition(ccp(tipStrFont2:getContentSize().width+tipStrFont2:getPositionX()+5,tipStrFont2:getPositionY()))
			    menuItem:addChild(tipStrFont3,2)
			else
				local tipStr1 = GetLocalizeStringBy("lic_1541")
				local tipStr2 = "+" .. needNum
				local tipStr3 = GetLocalizeStringBy("lic_1542")
				local tipStrFont1 = CCRenderLabel:create(tipStr1, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont1:setColor(ccc3(0xff, 0x7e, 0x00))
			    tipStrFont1:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont1:setPosition(ccp(menuItem:getContentSize().width*0.3,menuItem:getContentSize().height*0.7))
			    menuItem:addChild(tipStrFont1,2)
			    local tipStrFont2 = CCRenderLabel:create(tipStr2, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont2:setColor(ccc3(0x00, 0xff, 0x18))
			    tipStrFont2:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont2:setPosition(ccp(tipStrFont1:getContentSize().width+tipStrFont1:getPositionX()+5,menuItem:getContentSize().height*0.7))
			    menuItem:addChild(tipStrFont2,2)
			    local tipStrFont3 = CCRenderLabel:create(tipStr3, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont3:setColor(ccc3(0xff, 0xff, 0xff))
			    tipStrFont3:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont3:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.3))
			    menuItem:addChild(tipStrFont3,2)
			end
			
		end
	end
	return iconBg
end
--[[
	@des 	: 得到符印图标 by DJN
	@param 	: $p_index 		:第几个符印位置
	@return : sprite
--]]
function getRuneSprite(p_index)
	local iconBg = CCSprite:create("images/common/rune_bg_b.png")

	if(_treasData.va_item_text and _treasData.va_item_text.treasureInlay and _treasData.va_item_text.treasureInlay[tostring(p_index)])then
		-- 有符印
		local runeInfo =  _treasData.va_item_text.treasureInlay[tostring(p_index)]
		print("runeInfo")
		print_t(runeInfo)
		local runeIcon = ItemSprite.getItemSpriteByItemId(runeInfo.item_template_id)
		runeIcon:setAnchorPoint(ccp(0.5,0.5))
		runeIcon:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
		iconBg:addChild(runeIcon)

		-- 符印名字
		local dbData = ItemUtil.getItemById(runeInfo.item_template_id)
	 	local runeName = CCRenderLabel:create(dbData.name,  g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		runeName:setColor(HeroPublicLua.getCCColorByStarLevel(dbData.quality))
		runeName:setAnchorPoint(ccp(0.5,0))
		runeName:setPosition(ccp(runeIcon:getContentSize().width/2,runeIcon:getContentSize().height+15))
		runeIcon:addChild(runeName)
		-- 符印属性
	    local attrTab = RuneData.getRuneAbilityByTid(runeInfo.item_template_id)
		if(not table.isEmpty(attrTab) )then
			for i=1,#attrTab do
				local attrLabel = CCLabelTTF:create(attrTab[i].name .. "+" .. attrTab[i].showNum ,g_sFontName,20)
				attrLabel:setColor(ccc3(0x78, 0x25, 0x00))
				attrLabel:setAnchorPoint(ccp(0.5, 1))
				attrLabel:setPosition(ccp(runeIcon:getContentSize().width*0.5,-15-(i-1)*30))
				runeIcon:addChild(attrLabel)
			end
		end
	else
		-- 没有符印
		local isOpen,needNum,isUseLv = TreasureData.getRunePosIsOpen(_item_tmpl_id,_item_id,_treasData,p_index)
		print("isOpen",isOpen,"needNum",needNum,"isUseLv",isUseLv)
		if(isOpen)then
		else
			-- 没开启 锁
			local lockSp = CCSprite:create("images/common/rune_lock_b.png")
			lockSp:setAnchorPoint(ccp(0.5,0.5))
			lockSp:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.4))
			iconBg:addChild(lockSp)
			if(isUseLv == true)then
				local tipStr1 = GetLocalizeStringBy("lic_1540")
				local tipStr2 = needNum
				local tipStr3 = GetLocalizeStringBy("lic_1542")
				local tipStrFont1 = CCRenderLabel:create(tipStr1, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont1:setColor(ccc3(0xff, 0x7e, 0x00))
			    tipStrFont1:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont1:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.7))
			    iconBg:addChild(tipStrFont1,2)
			    local tipStrFont2 = CCRenderLabel:create(tipStr2, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont2:setColor(ccc3(0x00, 0xff, 0x18))
			    tipStrFont2:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont2:setPosition(ccp(iconBg:getContentSize().width*0.3,iconBg:getContentSize().height*0.3))
			    iconBg:addChild(tipStrFont2,2)
			    local tipStrFont3 = CCRenderLabel:create(tipStr3, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont3:setColor(ccc3(0xff, 0xff, 0xff))
			    tipStrFont3:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont3:setPosition(ccp(tipStrFont2:getContentSize().width+tipStrFont2:getPositionX()+5,tipStrFont2:getPositionY()))
			    iconBg:addChild(tipStrFont3,2)
			else
				local tipStr1 = GetLocalizeStringBy("lic_1541")
				local tipStr2 = "+" .. needNum
				local tipStr3 = GetLocalizeStringBy("lic_1542")
				local tipStrFont1 = CCRenderLabel:create(tipStr1, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont1:setColor(ccc3(0xff, 0x7e, 0x00))
			    tipStrFont1:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont1:setPosition(ccp(iconBg:getContentSize().width*0.3,iconBg:getContentSize().height*0.7))
			    iconBg:addChild(tipStrFont1,2)
			    local tipStrFont2 = CCRenderLabel:create(tipStr2, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont2:setColor(ccc3(0x00, 0xff, 0x18))
			    tipStrFont2:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont2:setPosition(ccp(tipStrFont1:getContentSize().width+tipStrFont1:getPositionX()+5,iconBg:getContentSize().height*0.7))
			    iconBg:addChild(tipStrFont2,2)
			    local tipStrFont3 = CCRenderLabel:create(tipStr3, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			    tipStrFont3:setColor(ccc3(0xff, 0xff, 0xff))
			    tipStrFont3:setAnchorPoint(ccp(0.5,0.5))
			    tipStrFont3:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.3))
			    iconBg:addChild(tipStrFont3,2)
			end
			
		end
	end
	return iconBg
end

--[[
	@des 	: 符印位置按钮回调
--]]
function runeMenuItemCallBack(tag,itemBtn)
	print("runeMenuItemCallBack tag==>",tag)
	local isOpen,needNum = TreasureData.getRunePosIsOpen(_item_tmpl_id,_item_id,_treasData,tag)
	if(isOpen == false)then
		return
	end

	if(_treasData.va_item_text and _treasData.va_item_text.treasureInlay and _treasData.va_item_text.treasureInlay[tostring(tag)])then
		-- 位置上有符印显示详细信息
		require "script/ui/bag/RuneInfoLayer"
		RuneInfoLayer.showLayer( _treasData.va_item_text.treasureInlay[tostring(tag)].item_id, _item_id, tag, refreshRuneSp, _menu_priority-30, _zOrderNum+1 )
	else
		-- 没有直接选择
		require "script/ui/treasure/ChooseRuneLayer"
		ChooseRuneLayer.showChooseLayer( _item_id, tag, refreshRuneSp, _menu_priority-30, _zOrderNum+1 )
	end
end

--[[
	@des 	: 符印刷新方法
	@param  : p_index 第几个位置
--]]
function refreshRuneSp( p_index )
	if( table.isEmpty(_runeSpTab) )then
		return
	end
	if( tolua.cast(_runeSpTab[p_index], "CCSprite") == nil )then
		return
	end
	_runeSpTab[p_index]:removeFromParentAndCleanup(true)
	local runeBg = getRuneButton(p_index)
	runeBg:setAnchorPoint(ccp(0.5,0.5))
	runeBg:setPosition(ccp(_xiangBg:getContentSize().width*_posX[p_index], _xiangBg:getContentSize().height*0.5))
	_xiangBg:addChild(runeBg)
	_runeSpTab[p_index] = runeBg
end















