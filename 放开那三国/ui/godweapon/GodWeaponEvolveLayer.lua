-- Filename：	GodWeaponEvolveLayer.lua
-- Author：		Zhang zihang
-- Date：		2014-12-17
-- Purpose：		神兵进化界面

module("GodWeaponEvolveLayer", package.seeall)

require "script/ui/shop/RechargeLayer"
require "script/ui/item/GodWeaponItemUtil"
require "script/ui/godweapon/GodWeaponService"
require "script/model/user/UserModel"
require "script/utils/BaseUI"

local _bgLayer					--背景层
local _itemInfo 				--物品信息
local _hid 						--武将hid
local _silverNum				--银币数量
local _DBInfo 					--db数据信息
local _quality 					--品质
local _allEvolveNum				--总进化次数
local _showNum					--显示的进化次数
local _attrInfo 				--属性信息
local _touchPriority 			--触摸优先级
local _zOrder 					--Z轴
local _isMax 					--是否达到进化上限
local _envolveInfo 				--进化消耗信息
local _isEnough 				--进化材料是否充足
local _paramAttrTable 			--作为参数的属性表
local _itemId 					--物品id
local _tag 						--上级界面的tag值
local _returnMenuItem  			--返回按钮
local _evolveMenuItem 			--进化按钮

--返回背包的tag值
kBagTag = 1000
--返回阵容的tag值
kFormationTag = 2000

--==================== Init ====================

--[[
	@des 	:初始化函数
--]]
function init()
	_quality = 0
	_allEvolveNum = 0
	_showNum = 0
	_bgLayer = nil
	_itemInfo = nil
	_hid = nil
	_DBInfo = nil
	_attrInfo = nil
	_touchPriority = nil
	_zOrder = nil
	_envolveInfo = nil
	_itemId = nil
	_isMax = false
	_isEnough = false
	_paramAttrTable = {}
end


--[[
	@des 	:点击事件函数
--]]
function onTouchesHandler()
	return true
end

--[[
	@des 	:事件函数
	@param 	:事件
--]]
function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif eventType == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--==================== CallBack ====================

--[[
	@des 	:关闭回调
--]]
function returnCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")

	if _tag == kBagTag then
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_GodWeapon)
		MainScene.changeLayer(bagLayer,"bagLayer")
	elseif _tag == kFormationTag then
		local formationLayer = FormationLayer.createLayer(_hid,false,false,nil,3)
		MainScene.changeLayer(formationLayer,"formationLayer")
		GodWeaponInfoLayer.showLastLayer()
	end
end

--[[
	@des 	:进化回调
--]]
function evolveCallBack()
	--如果银币不足
	if _silverNum < _envolveInfo.silver then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1225"))
	--如果进化材料不足
	elseif not _isEnough then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1226"))
	--如果强化等级不足
	elseif tonumber(_itemInfo.va_item_text.reinForceLevel) < _envolveInfo.enhanceLv then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1227",_envolveInfo.enhanceLv))
	--主角等级不足
	elseif UserModel.getHeroLevel() < _envolveInfo.heroLv then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1228",_envolveInfo.heroLv))
	else
		local serverCallBack = function(retNum,retLv,retExp)
			_returnMenuItem:setEnabled(false)
			_evolveMenuItem:setEnabled(false)

			if _hid ~= nil then
				HeroModel.changeHeroGodWeaponEvolveNumBy(_hid,_itemId,retNum,retLv,retExp)
			else
				--修改本地缓存神兵进化等级
				DataCache.setGodWeaponEvolveNumById(_itemId,retNum,retLv,retExp)
			end
			--减银币
			UserModel.addSilverNumber(-_envolveInfo.silver)

			local successLayerSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/hero/transfer/zhuangchang"),-1,CCString:create(""))
			successLayerSprite:setPosition(ccp((g_winSize.width-320*2*g_fElementScaleRatio)*0.5,g_winSize.height))
			successLayerSprite:setScale(g_fElementScaleRatio)
		    _bgLayer:addChild(successLayerSprite,9999)

		    local animationEnd = function(actionName,xmlSprite)
		   		successLayerSprite:retain()
				successLayerSprite:autorelease()
		        successLayerSprite:removeFromParentAndCleanup(true)

		        require "script/ui/godweapon/EvolveSuccessLayer"
		        EvolveSuccessLayer.showLayer(_hid,_itemInfo,_allEvolveNum + 1,_itemInfo.va_item_text.reinForceLevel,_paramAttrTable,_itemId)
		    end

		    local animationFrameChanged = function(frameIndex,xmlSprite)
		    end

		    local delegate = BTAnimationEventDelegate:create()
		    delegate:registerLayerEndedHandler(animationEnd)
		    delegate:registerLayerChangedHandler(animationFrameChanged)
		    
		    successLayerSprite:setDelegate(delegate)
		end

		GodWeaponService.evolve(_itemId,_envolveInfo.godConsumId,serverCallBack)
	end
end

--==================== UI ====================

--[[
	@des 	:创建背景UI
	@return :名字位置
--]]
function createBgUI()
	--主背景
	local bgSprite = CCSprite:create("images/god_weapon/evolve_bg.jpg")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	--跑马灯大小
	local bulletSize = BulletinLayer.getLayerContentSize()

	--信息条
	local topBgSprite = CCSprite:create("images/hero/avatar_attr_bg.png")
    topBgSprite:setAnchorPoint(ccp(0.5,1))
    topBgSprite:setPosition(g_winSize.width*0.5,g_winSize.height - bulletSize.height*g_fScaleX)
    topBgSprite:setScale(g_fScaleX)
    _bgLayer:addChild(topBgSprite)
    
    local topBgSize = topBgSprite:getContentSize()
    
    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(topBgSize.width*0.13,topBgSize.height*0.43)
    topBgSprite:addChild(powerDescLabel)
    
    local userInfo = UserModel.getUserInfo()

    local powerLabel = CCRenderLabel:create(UserModel.getFightForceValue(),g_sFontName,23,1.5,ccc3(0x00,0x00,0x00),type_stroke)
    powerLabel:setColor(ccc3(0xff,0xf6,0x00))
    powerLabel:setPosition(topBgSize.width*0.23,topBgSize.height*0.66)
    topBgSprite:addChild(powerLabel)
    
    local silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)  -- modified by yangrui at 2015-12-03
    silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    silverLabel:setAnchorPoint(ccp(0,0.5))
    silverLabel:setPosition(topBgSize.width*0.61,topBgSize.height*0.43)
    topBgSprite:addChild(silverLabel)
    
    _silverNum = tonumber(userInfo.silver_num)

    local goldLabel = CCLabelTTF:create(userInfo.gold_num,g_sFontName,18)
    goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    goldLabel:setAnchorPoint(ccp(0,0.5))
    goldLabel:setPosition(topBgSize.width*0.82,topBgSize.height*0.43)
    topBgSprite:addChild(goldLabel)

    local returnPos = g_winSize.height - (bulletSize.height + topBgSize.height + 10)*g_fScaleX

	--标题
	local titleSprite = CCSprite:create("images/god_weapon/weapon_evolve.png")
	titleSprite:setAnchorPoint(ccp(0,1))
	titleSprite:setPosition(ccp(g_winSize.width*0.02,returnPos))
	titleSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(titleSprite)

	return returnPos
end

--[[
	@des 	:创建按钮相关UI
--]]
function createMenuUI()
	--背景menu
	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 1)
	_bgLayer:addChild(bgMenu)

	--下面那个返回按钮
	_returnMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200,75),GetLocalizeStringBy("key_2661"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	_returnMenuItem:setAnchorPoint(ccp(0,0))
	_returnMenuItem:setPosition(ccp(g_winSize.width*0.09,5*g_fElementScaleRatio))
	_returnMenuItem:registerScriptTapHandler(returnCallBack)
	_returnMenuItem:setScale(g_fElementScaleRatio)
	bgMenu:addChild(_returnMenuItem)

	--开始进化按钮
	_evolveMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200,75),GetLocalizeStringBy("zzh_1233"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	_evolveMenuItem:setAnchorPoint(ccp(1,0))
	_evolveMenuItem:setPosition(ccp(g_winSize.width*0.91,5*g_fElementScaleRatio))
	_evolveMenuItem:registerScriptTapHandler(evolveCallBack)
	_evolveMenuItem:setScale(g_fElementScaleRatio)
	_evolveMenuItem:setEnabled(not _isMax)
	bgMenu:addChild(_evolveMenuItem)
end

--[[
	@des 	:创建神兵信息UI
	@param 	: $p_LorR 		:左边还是右边
							 true 	=> 左边
							 false => 右边
	@param 	: $p_yPos 		:名字位置
--]]
function createItemUI(p_LorR,p_yPos)
	local posXRate = p_LorR and 0.22 or 0.78

	-- --星星和名字的位置
	-- local starPosY = g_winSize.height*0.83
	-- local namePosY = g_winSize.height*0.43
	--神兵位置
	-- local itemPosY = (starPosY - namePosY)*0.5 + namePosY
	local quality,showNum,attrInfo,allEvolveNum
	if p_LorR then
		quality = _quality
		showNum = _showNum
		attrInfo = _attrInfo
		allEvolveNum = _allEvolveNum

		_paramAttrTable.old = attrInfo

		--名字位置
		local namePosY = p_yPos
		--神兵位置
		local tempPosY = g_winSize.height*0.49
		local itemPosY = (namePosY - 45*g_fElementScaleRatio - tempPosY)*0.5 + tempPosY

		local shineLayerSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/wuqijinjiehuang/wuqijinjiehuang"),-1,CCString:create(""))
		shineLayerSprite:setPosition(g_winSize.width*0.5,g_winSize.height*0.49 - 30*g_fElementScaleRatio)
		shineLayerSprite:setScale(g_fElementScaleRatio)
		_bgLayer:addChild(shineLayerSprite)

		local animationEnd = function(actionName,xmlSprite)
	    end

	    local animationFrameChanged = function(frameIndex,xmlSprite)
	    end

	    local delegate = BTAnimationEventDelegate:create()
	    delegate:registerLayerEndedHandler(animationEnd)
	    delegate:registerLayerChangedHandler(animationFrameChanged)
	    
	    shineLayerSprite:setDelegate(delegate)

		--神兵图
		local godArmSprite = GodWeaponItemUtil.getWeaponBigSprite(nil,nil,_hid,_itemInfo,allEvolveNum,true)
		godArmSprite:setAnchorPoint(ccp(0.5,0))
		godArmSprite:setPosition(ccp(shineLayerSprite:getContentSize().width*0.5,30))
		shineLayerSprite:addChild(godArmSprite)

		--名称底
		local nameBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
		nameBgSprite:setContentSize(CCSizeMake(200,45))
		nameBgSprite:setAnchorPoint(ccp(0.5,1))
		nameBgSprite:setPosition(ccp(g_winSize.width*0.5,namePosY))
		nameBgSprite:setScale(g_fElementScaleRatio)
		_bgLayer:addChild(nameBgSprite)

		local bgSize = nameBgSprite:getContentSize()

		--名字
		local nameLabel = CCLabelTTF:create(_DBInfo.name,g_sFontPangWa,25)
		nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(quality))
		local plusLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1224",showNum),g_sFontPangWa,25)
		plusLabel:setColor(HeroPublicLua.getCCColorByStarLevel(quality))
		local connectNode = BaseUI.createHorizontalNode({nameLabel,plusLabel})
		connectNode:setAnchorPoint(ccp(0.5,0.5))
		connectNode:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
		nameBgSprite:addChild(connectNode)
	else
		allEvolveNum = _allEvolveNum + 1
		quality,showNum = GodWeaponItemUtil.getDBQualityAndShowNum(_DBInfo.id,_allEvolveNum+1)
		--attrInfo = GodWeaponItemUtil.getAttrTable(_allEvolveNum+1,tonumber(_itemInfo.va_item_text.reinForceLevel),_DBInfo.id)
		attrInfo = GodWeaponItemUtil.getAttrTable(_allEvolveNum+1,_envolveInfo.enhanceLv,_DBInfo.id)

		_paramAttrTable.new = attrInfo
	end

	--属性信息
	local bgWidth = 220
	local bgHeight = 155
	local attrBgSprite = CCScale9Sprite:create(CCRectMake(8,37,12,12),"images/god_weapon/attr_bg.png")
	attrBgSprite:setContentSize(CCSizeMake(bgWidth,bgHeight))
	attrBgSprite:setScale(g_fElementScaleRatio)
	attrBgSprite:setAnchorPoint(ccp(0.5,1))
	attrBgSprite:setPosition(ccp(g_winSize.width*posXRate,g_winSize.height*0.24))
	_bgLayer:addChild(attrBgSprite)

	--红线
	local redSprite = CCSprite:create("images/god_weapon/red_line.png")
	redSprite:setAnchorPoint(ccp(0.5,0.5))
	redSprite:setPosition(ccp(bgWidth*0.5,bgHeight - 25))
	attrBgSprite:addChild(redSprite)
	local redSize = redSprite:getContentSize()

	--名字
	local attrNameLabel = CCRenderLabel:create(_DBInfo.name,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_shadow)
	attrNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(quality))
	local attrPlusLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1224",showNum),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_shadow)
	attrPlusLabel:setColor(HeroPublicLua.getCCColorByStarLevel(quality))
	local attrLabel = BaseUI.createHorizontalNode({attrNameLabel,attrPlusLabel})
	attrLabel:setAnchorPoint(ccp(0.5,0.5))
	attrLabel:setPosition(ccp(redSize.width*0.5,redSize.height*0.5 + 3))
	redSprite:addChild(attrLabel)

	--属性
	for i = 1,#attrInfo do
		local attrNameLabel = CCLabelTTF:create(attrInfo[i].name .. "：",g_sFontName,21)
		attrNameLabel:setColor(ccc3(0xff,0xff,0xff))
		local numLabel = CCLabelTTF:create("+" .. attrInfo[i].showNum,g_sFontName,21)
		if p_LorR then
			numLabel:setColor(ccc3(0xff,0xff,0xff))
		else
			numLabel:setColor(ccc3(0x00,0xff,0x18))
		end

		local attrConnectNode = BaseUI.createHorizontalNode({attrNameLabel,numLabel})
		attrConnectNode:setAnchorPoint(ccp(0,0))
		attrConnectNode:setPosition(ccp(40,85 - (i-1)*25))
		attrBgSprite:addChild(attrConnectNode)
	end
end

--[[
	@des 	:创建中部UI
	@param  :y轴值
--]]
function createMiddleUI(p_yPos)
	--创建左边的UI
	createItemUI(true,p_yPos)
	--创建右边的UI
	--没达到最高级才有右边的UI
	if not _isMax then
		createItemUI(false)
	end

	local arrowSprite = CCSprite:create("images/hero/transfer/arrow.png")
	arrowSprite:setAnchorPoint(ccp(0.5,0.5))
	arrowSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.15))
	arrowSprite:setScale(g_fElementScaleRatio*0.5)
	_bgLayer:addChild(arrowSprite)
end

--[[
	@des 	:创建底部UI
--]]
function createButtomUI()
	--进化没有到最高级，才有奖励预览
	if not _isMax then
		local needSilverLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1223"),g_sFontPangWa,21)
		needSilverLabel:setColor(ccc3(0xff,0xff6,0x00))
		local silverSprite = CCSprite:create("images/common/coin.png")
		local silverNumLabel = CCLabelTTF:create(_envolveInfo.silver,g_sFontPangWa,21)
		silverNumLabel:setColor(ccc3(0xff,0xff,0xff))

		local silverNode = BaseUI.createHorizontalNode({needSilverLabel,silverSprite,silverNumLabel})
		silverNode:setAnchorPoint(ccp(0.5,0))
		silverNode:setScale(g_fElementScaleRatio)
		silverNode:setPosition(ccp(g_winSize.width*0.78,g_winSize.height*0.24))
		_bgLayer:addChild(silverNode)

		local itemNum = #_envolveInfo.item

		local posXTable
		local posYTable

		if itemNum == 0 then
			posXTable = {0.22,0.78,0.5}
			posYTable = {0.36,0.36,0.31}
		elseif itemNum == 1 then
			posXTable = {0.5,0.22,0.78}
			posYTable = {0.31,0.36,0.36}
		elseif itemNum == 2 then
			posXTable = {0.22,0.78,0.5}
			posYTable = {0.36,0.36,0.31}
		else
			posXTable = {0.22,0.78,0.5}
			posYTable = {0.36,0.36,0.31}
		end

		--遍历物品
		for i = 1,3 do
			local shineLayerSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/wuqijinjielan/wuqijinjielan"),-1,CCString:create(""))
			shineLayerSprite:setPosition(g_winSize.width*posXTable[i],g_winSize.height*posYTable[i] + 20*g_fElementScaleRatio)
			shineLayerSprite:setScale(g_fElementScaleRatio)
			_bgLayer:addChild(shineLayerSprite)

			local animationEnd = function(actionName,xmlSprite)
		    end

		    local animationFrameChanged = function(frameIndex,xmlSprite)
		    end

		    local delegate = BTAnimationEventDelegate:create()
		    delegate:registerLayerEndedHandler(animationEnd)
		    delegate:registerLayerChangedHandler(animationFrameChanged)
		    
		    shineLayerSprite:setDelegate(delegate)

			if i <= itemNum then
				local consumeInfo = _envolveInfo.item[i]
				local consumeSprite = itemSpriteWithName(consumeInfo)
				consumeSprite:setAnchorPoint(ccp(0.5,1))
				consumeSprite:setPosition(ccp(g_winSize.width*posXTable[i],g_winSize.height*posYTable[i]))
				consumeSprite:setScale(g_fElementScaleRatio)
				_bgLayer:addChild(consumeSprite)
			else
				shineLayerSprite:setColor(ccc3(125,125,125))
			end
		end
	else
		local posXTable = {0.22,0.78,0.5}
		local posYTable = {0.36,0.36,0.31}

		for i = 1,3 do
			local shineLayerSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/wuqijinjielan/wuqijinjielan"),-1,CCString:create(""))
			shineLayerSprite:setPosition(g_winSize.width*posXTable[i],g_winSize.height*posYTable[i] + 20*g_fElementScaleRatio)
			shineLayerSprite:setScale(g_fElementScaleRatio)
			shineLayerSprite:setColor(ccc3(125,125,125))
			_bgLayer:addChild(shineLayerSprite)

			local animationEnd = function(actionName,xmlSprite)
		    end

		    local animationFrameChanged = function(frameIndex,xmlSprite)
		    end

		    local delegate = BTAnimationEventDelegate:create()
		    delegate:registerLayerEndedHandler(animationEnd)
		    delegate:registerLayerChangedHandler(animationFrameChanged)
		    
		    shineLayerSprite:setDelegate(delegate)
		end

		--已达到最大进化等级
		local needLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1222"),g_sFontPangWa,21)
		needLabel:setColor(ccc3(0xff,0xf6,0x00))
		needLabel:setAnchorPoint(ccp(0.5,0.5))
		needLabel:setScale(g_fElementScaleRatio)
		needLabel:setPosition(ccp(g_winSize.width*0.78,g_winSize.height*0.15))
		_bgLayer:addChild(needLabel)
	end
end

--[[
	@des 	:创建UI
--]]
function createUI()
	--创建背景UI
	local yPos = createBgUI()
	--创建按钮UI
	createMenuUI()
	--创建中部UI
	createMiddleUI(yPos)
	--创建底部UI
	createButtomUI()
end

--==================== Entrance ====================

--[[
	@des 	:入口函数
	@param 	: $p_itemId 			: 神兵itemid
	@param  : $p_priority			: 触摸优先级
	@param  : $p_zOrder 			: Z轴
--]]
function createLayer(p_itemId,p_priority,p_zOrder)
	init()

	--创建层
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	_touchPriority = p_priority or - 550
	_zOrder = p_zOrder or 999

	--根据item_id得到物品信息
	_itemInfo = GodWeaponItemUtil.getGodWeaponInfo(nil,p_itemId)
	--物品id
	_itemId = p_itemId
	--物品db信息
	_DBInfo = _itemInfo.itemDesc
	--hid
	_hid = _itemInfo.hid
	--得到品质和显示的进化次数
	--得到武将品质，总进阶等级，显示的等级
	_quality,_allEvolveNum,_showNum = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil,nil,_itemInfo)
	--属性信息
	_attrInfo = GodWeaponItemUtil.getWeaponAbility(nil,nil,_itemInfo)
	--进化信息
	_isMax,_envolveInfo,_isEnough = GodWeaponItemUtil.getEvolveItemInfo(_DBInfo.id,_allEvolveNum,_itemId)

	--创建UI
	createUI()

	--只显示跑马灯
	MainScene.setMainSceneViewsVisible(false,false,true)
	MainScene.changeLayer(_bgLayer,"GodWeaponEvolveLayer")
end

--[[
	@des 	:设置传入参数的tag值
	@param 	:tag值
--]]
function setChangeLayerMark(p_tag)
	_tag = p_tag
end

--[[
	@des 	:通过消耗信息创建消耗图标
	@param 	:消耗品信息
	@return :创建好的sprite
--]]
function itemSpriteWithName(p_itemInfo)
	--名称底
	local nameBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBgSprite:setContentSize(CCSizeMake(210,30))

	local nameSize = nameBgSprite:getContentSize()

	--物品表信息
	local itemData = ItemUtil.getItemById(p_itemInfo.id)
	local itemNameLabel
	local itemSprite
	local scaleNum
	--如果是神兵，则需要显示进阶等级
	if p_itemInfo.type == "god" then
		local quality,showNum = GodWeaponItemUtil.getDBQualityAndShowNum(itemData.id,p_itemInfo.evolveNum)
		local nameLabel = CCLabelTTF:create(itemData.name,g_sFontPangWa,23)
		nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(quality))
		local addLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1224",showNum),g_sFontName,23)
		addLabel:setColor(ccc3(0x00,0xff,0x18))
		itemNameLabel = BaseUI.createHorizontalNode({nameLabel,addLabel})

		scaleNum = 0.5

	else
		itemNameLabel = CCLabelTTF:create(itemData.name,g_sFontPangWa,23)
		itemNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(itemData.quality))

		scaleNum = 0.3
	end

	itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
	itemNameLabel:setPosition(ccp(nameSize.width*0.5,nameSize.height*0.5))
	nameBgSprite:addChild(itemNameLabel)

	local ratioLabel = CCRenderLabel:create(p_itemInfo.have .. "/" .. p_itemInfo.num,g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_shadow)
	if p_itemInfo.have >= p_itemInfo.num then
		ratioLabel:setColor(ccc3(0x00,0xff,0x18))
	else
		ratioLabel:setColor(ccc3(0xff,0x00,0x00))
	end
	ratioLabel:setAnchorPoint(ccp(0.5,1))
	ratioLabel:setPosition(ccp(nameSize.width*0.5,-5))
	nameBgSprite:addChild(ratioLabel)

	itemSprite = ItemSprite.getItemBigSpriteById(p_itemInfo.id)
	itemSprite:setScale(scaleNum)
	itemSprite:setAnchorPoint(ccp(0.5,0))
	itemSprite:setPosition(ccp(nameSize.width*0.5,nameSize.height + 25))
	nameBgSprite:addChild(itemSprite)

	local arrActions = CCArray:create()
	arrActions:addObject(CCMoveBy:create(1.5,ccp(0,5)))
	arrActions:addObject(CCMoveBy:create(1.5,ccp(0,-5)))
	local sequence = CCSequence:create(arrActions)
	local repeatSequence = CCRepeatForever:create(sequence)
	itemSprite:runAction(repeatSequence)

	return nameBgSprite
end