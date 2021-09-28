-- FileName: TreasureDevelopLayer.lua 
-- Author: licong 
-- Date: 15/4/22 
-- Purpose: 宝物进阶主界面 


module("TreasureDevelopLayer", package.seeall)

require "script/ui/treasure/develop/TreasureDevelopService"
require "script/ui/treasure/develop/TreasureDevelopData"
require "script/ui/item/TreasCardSprite"
require "script/utils/BaseUI"
require "script/model/affix/TreasAffixModel"


local _bgLayer 							= nil
local _bgSprite 						= nil
local _maskLayer						= nil -- 特效屏蔽层

local _showItemId 						= nil
local _showItemInfo 					= nil
local _isOnHero 						= false
local _hid 								= nil
local _showDevelopNum 					= nil
local _nextDevelopNum 					= nil
local _disItemInfo 						= nil
local _maxDevelopNum 					= nil
local _addAttrTab 						= nil
local _showAddTab 						= nil

local _showMark 						= nil -- 界面跳转tag

-- 页面跳转tag
kTagBag 				= 100
kTagFormation 			= 101

-- 界面优先级
local _layer_priority 	= -500

--[[
	@des 	:初始化
--]]
function init( ... )
	_bgLayer 							= nil
	_bgSprite 							= nil
	_maskLayer							= nil

	_showItemId 						= nil
	_showItemInfo 						= nil
	_isOnHero 							= false
	_hid 								= nil
	_showDevelopNum 					= nil
	_nextDevelopNum 					= nil
	_disItemInfo 						= nil
	_maxDevelopNum 						= nil
	_addAttrTab 						= nil
	_showAddTab 						= nil

	_showMark 							= nil
end

--[[
	@des 	:初始化数据
--]]
function initData( ... )
	-- 物品信息
	_showItemInfo = ItemUtil.getItemByItemId(_showItemId)
	if(_showItemInfo == nil)then
		_showItemInfo = ItemUtil.getTreasInfoFromHeroByItemId(_showItemId)
		_hid = _showItemInfo.hid
		_isOnHero = true
	end
	if( table.isEmpty(_showItemInfo.itemDesc) )then
		_showItemInfo.itemDesc = ItemUtil.getItemById(_showItemInfo.item_template_id)
	end

	-- 显示进阶次数
	_showDevelopNum = tonumber(_showItemInfo.va_item_text.treasureDevelop) or -1
	-- 下次进阶次数
	_nextDevelopNum = _showDevelopNum + 1

	-- 构造进阶后数据
	_disItemInfo = table.hcopy(_showItemInfo,{})
	-- 修改进阶数
	_disItemInfo.va_item_text.treasureDevelop = _nextDevelopNum

	-- 最大进阶次数
	_maxDevelopNum =TreasureDevelopData.getDevelopMaxNum( _showItemInfo.item_template_id )
	print("_maxDevelopNum",_maxDevelopNum)

	-- 计算新增属性
	local oldAttrTab = TreasAffixModel.getIncreaseAffixByInfo(_showItemInfo)
	local newAttrTab = {}
	if(_nextDevelopNum <= _maxDevelopNum)then
		newAttrTab = TreasAffixModel.getIncreaseAffixByInfo(_disItemInfo)
	end
	_addAttrTab = TreasureDevelopData.getDevelopAddAttrTab(oldAttrTab,newAttrTab)

	-- 计算增加值
	_showAddTab = {}
	for k,v in pairs(_addAttrTab) do
		if( oldAttrTab[k] ~= nil )then
			_showAddTab[k] = v - oldAttrTab[k]
		else
			_showAddTab[k] = v
		end
	end
end

---------------------------------------------------------------- 界面跳转记忆 --------------------------------------------------------------------
--[[
	@des 	:设置页面跳转记忆
	@param 	:p_mark:页面跳转mark
	@return :
--]]
function setChangeLayerMark( p_mark )
  	_showMark = p_mark
end

--[[
	@des 	:得到页面跳转记忆
--]]
function getChangeLayerMark()
  	return _showMark 
end

--[[
	@des 	:页面跳转记忆
	@param 	:
	@return :
--]]
function changeLayerMark()
  	if(_showMark == kTagBag)then
  		-- 背包
  		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Treas)
		MainScene.changeLayer(bagLayer, "bagLayer")
  	elseif(_showMark == kTagFormation)then
  		-- 阵容
  		require("script/ui/formation/FormationLayer")
        local formationLayer = FormationLayer.createLayer(_hid)
        MainScene.changeLayer(formationLayer, "formationLayer")
  	else
  		-- 背包
  		require "script/ui/bag/BagLayer"
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Treas)
		MainScene.changeLayer(bagLayer, "bagLayer")
  	end
end

------------------------------------------------------------------- 按钮事件 ----------------------------------------------------------------

--[[
	@des 	:返回按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

	-- 跳转界面
	changeLayerMark()
end

--[[
	@des 	:进阶按钮回调
	@param 	:
	@return :
--]]
function developMenuItemmCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

    if(_nextDevelopNum > _maxDevelopNum)then
    	AnimationTip.showTip(GetLocalizeStringBy("lic_1558"))
		return
    end

    local needLv = TreasureDevelopData.getDevelopNeedHeroLv(_nextDevelopNum)
    -- 人物等级不足
	if( UserModel.getHeroLevel() < needLv )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1555",needLv))
		return
	end	
	-- 材料是否足够
	local materialData = TreasureDevelopData.getDevelopNeedCost( _showItemInfo.item_template_id, _nextDevelopNum )
	local needSilver = 0
	local isCan = true
	for k,v in pairs(materialData) do
		if( v.type == "silver" )then
			local haveNum = UserModel.getSilverNumber()
			needSilver = v.num
			if( haveNum < v.num )then
				isCan = false
				break
			end
		else
			local haveNum = ItemUtil.getCacheItemNumBy(v.tid)
			if( haveNum < v.num )then
				isCan = false
				break
			end
		end
	end
	if( isCan == false )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1556"))
		return
	end	

	

	local nextCallBack = function ( p_retData )
		-- 修改宝物数据
		if(_isOnHero)then
			HeroModel.changeHeroTreasureDevelopBy( _hid,_showItemId, p_retData.va_item_text.treasureDevelop)
		else
			DataCache.changeTreasureDevelopInBag(_showItemId, p_retData.va_item_text.treasureDevelop)
		end
		-- 扣除银币
		UserModel.addSilverNumber(-needSilver)

		-- 特效
		local successLayerSprite = XMLSprite:create("images/base/effect/hero/transfer/zhuangchang")
		successLayerSprite:setPosition(ccp((g_winSize.width-320*2*g_fElementScaleRatio)*0.5,g_winSize.height))
		successLayerSprite:setScale(g_fElementScaleRatio)
	    _bgLayer:addChild(successLayerSprite,9999)

	    local animationEnd = function()
	        successLayerSprite:removeFromParentAndCleanup(true)
	        successLayerSprite = nil
			-- 干掉屏蔽层
			if(_maskLayer ~= nil)then
				_maskLayer:removeFromParentAndCleanup(true)
				_maskLayer = nil
			end
	        -- 弹出成功界面
			require "script/ui/treasure/develop/TDevelopSuccessLayer"
			TDevelopSuccessLayer.showLayer(_showItemInfo,_showAddTab)
	    end
	    successLayerSprite:registerEndCallback( animationEnd )
	end
	-- 添加特效屏蔽层
    if(_maskLayer ~= nil)then
		_maskLayer:removeFromParentAndCleanup(true)
		_maskLayer = nil
	end
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	_maskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
	runningScene:addChild(_maskLayer, 10000)
	-- 发请求
	local needItemIdTab = {}
	for k,v in pairs(materialData) do
		if( v.type ~= "silver" )then
			local findTab = ItemUtil.getCacheItemIdArrByNum( v.tid, v.num )
			for i,v_itemId in pairs(findTab) do
				table.insert(needItemIdTab,tonumber(v_itemId))
			end
		end
	end
	TreasureDevelopService.develop(tonumber(_showItemId), needItemIdTab, nextCallBack)
end


--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
	elseif (event == "exit") then
	end
end

------------------------------------------------------------------- 创建UI ----------------------------------------------------------------
--[[
	@des 	:得到洗练等级图标
	@param 	:p_maxLv 最大洗练等级, p_curWasterLv 当前洗练等级
	@return :sprite
--]]
function getEvolveLvSp(p_maxLv, p_curWasterLv )
	local diamondBg = CCSprite:create()
	diamondBg:setContentSize(CCSizeMake(275, 30))
	require "script/ui/treasure/TreasureUtil"
	for i=1, 10 do
		local sprite = nil
		if(i <= (p_curWasterLv)%10) then
			sprite 	= TreasureUtil.getFixedLevelSprite(p_curWasterLv)
		else
			sprite 	= CCSprite:create("images/common/big_gray_gem.png")
		end

		if math.floor(tonumber(p_curWasterLv)/10) >= 1 and tonumber(p_curWasterLv)%10==0  then
			sprite 	= TreasureUtil.getFixedLevelSprite(p_curWasterLv)
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

--[[
	@des 	:创建材料列表
	@param 	:p_data 材料数据
--]]
function createListCell( p_data )
	local cell = CCTableViewCell:create()
	local iconBg = ItemUtil.createGoodsIcon(p_data, nil, nil, nil, nil ,nil,true,nil,false)
	iconBg:setAnchorPoint(ccp(0,1))
	iconBg:setPosition(ccp(18,120))
	cell:addChild(iconBg)

	local haveNum = nil
	local showStr = nil
	if( p_data.type == "silver")then
		haveNum = UserModel.getSilverNumber()
		showStr = p_data.num
	else
		haveNum = ItemUtil.getCacheItemNumBy(p_data.tid)
		showStr = haveNum .. "/" .. p_data.num
	end
	local numLabel = CCRenderLabel:create(showStr, g_sFontName, 18, 1 , ccc3(0x00,0x00,0x00), type_shadow)
	local labelColor = haveNum >= p_data.num and ccc3(0x00,0xff,0x18) or ccc3(0xff,0x00,0x00)
	numLabel:setColor(labelColor)
	numLabel:setAnchorPoint(ccp(0.5,0))
	numLabel:setPosition(iconBg:getContentSize().width*0.5, 2)
	iconBg:addChild(numLabel)

	return cell
end 

--[[
	@des 	:创建材料列表
	@param 	:p_parent 父节点
--]]
function createMaterialList(p_parent)
	local materialData = TreasureDevelopData.getDevelopNeedCost( _showItemInfo.item_template_id, _nextDevelopNum )
	print("materialData++")
	print_t(materialData)
	if( table.isEmpty(materialData) )then
		return
	end
	local cellSize = CCSizeMake(101, 120)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
           a2 = createListCell(materialData[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			local num = #materialData
			r = num
		else
		end
		return r
	end)
	local listTableView = LuaTableView:createWithHandler(h, CCSizeMake(520, 120))
	listTableView:setBounceable(true)
	listTableView:setTouchEnabled(false)
	listTableView:setTouchEnabled(true)
	listTableView:setDirection(kCCScrollViewDirectionHorizontal)
	listTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	listTableView:ignoreAnchorPointForPosition(false)
	listTableView:setAnchorPoint(ccp(0.5,0.5))
	listTableView:setPosition(ccp(p_parent:getContentSize().width*0.5, p_parent:getContentSize().height*0.5))
	p_parent:addChild(listTableView)
	listTableView:setTouchPriority(_layer_priority-2)
end

--[[
	@des 	: 创建上边ui
	@param  : p_itemInfo 宝物详细信息
--]]
function createCardSpriteUI( p_itemInfo )
	-- 卡牌
	local retCardSp = TreasCardSprite.createSprite(p_itemInfo.item_template_id, nil, p_itemInfo)
	retCardSp:setScale(g_fElementScaleRatio*0.6)

	-- 显示名字
	local quality = ItemUtil.getTreasureQualityByItemInfo( p_itemInfo )
	local nameLabel = ItemUtil.getTreasureNameByItemInfo( p_itemInfo, g_sFontPangWa, 21 )
	nameLabel:setAnchorPoint(ccp(0,0))
    retCardSp:addChild(nameLabel)
    nameLabel:setScale(1/0.6)

    -- 左强化
    local enhanceLvLabel = CCRenderLabel:create("+" .. p_itemInfo.va_item_text.treasureLevel, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    enhanceLvLabel:setColor(ccc3(0x2c, 0xdb, 0x23))
    enhanceLvLabel:setAnchorPoint(ccp(0,0))
    retCardSp:addChild(enhanceLvLabel)
    enhanceLvLabel:setScale(1/0.6)

    -- 左居中
    local l_posX = (retCardSp:getContentSize().width-nameLabel:getContentSize().width*nameLabel:getScale()-enhanceLvLabel:getContentSize().width*enhanceLvLabel:getScale())*0.5
    local l_posY = -40
    nameLabel:setPosition(ccp(l_posX,l_posY))
    enhanceLvLabel:setPosition(ccp(nameLabel:getPositionX()+nameLabel:getContentSize().width*nameLabel:getScale()+3,nameLabel:getPositionY()))

    return retCardSp
end

--[[
	@des 	: 创建属性ui
	@param  : p_itemInfo:宝物详细信息
--]]
function createAttrSpriteUI( p_itemInfo )
	local retBg = CCScale9Sprite:create("images/develop/scroll_bg.png")
	retBg:setContentSize(CCSizeMake(277,340))

	-- scrollView
	local viewSize = CCSizeMake(277,330)
	local scroll = CCScrollView:create()
	scroll:setViewSize(viewSize)
	scroll:setDirection(kCCScrollViewDirectionVertical)
	scroll:setTouchPriority(_layer_priority-1)
	scroll:setBounceable(true)
	scroll:ignoreAnchorPointForPosition(false)
	scroll:setAnchorPoint(ccp(0.5,0.5))
	scroll:setPosition(ccp(retBg:getContentSize().width*0.5, retBg:getContentSize().height*0.5))
	retBg:addChild(scroll)

	-- 计算containerLayer的size
	local containerHight = 0
	-- 当前属性标题
	local curAttrTitle = CCScale9Sprite:create("images/hero/info/title_bg.png")
	curAttrTitle:setContentSize(CCSizeMake(158,40))
	containerHight = containerHight + curAttrTitle:getContentSize().height
	-- 当前属性
	local curAttrTab = TreasAffixModel.getIncreaseAffixByInfo(p_itemInfo)
	containerHight = containerHight + table.count(curAttrTab)*30 + 10
	-- 精炼属性标题
	local jingAttrTitle = CCScale9Sprite:create("images/hero/info/title_bg.png")
	jingAttrTitle:setContentSize(CCSizeMake(158,40))
	containerHight = containerHight + jingAttrTitle:getContentSize().height
	-- 精炼等级
	local washLvSp = getEvolveLvSp(tonumber(p_itemInfo.itemDesc.max_upgrade_level ), tonumber(p_itemInfo.va_item_text.treasureEvolve))
	containerHight = containerHight + washLvSp:getContentSize().height
	-- 精炼属性
	local washTab = TreasAffixModel.getUpgradeAffixByInfo(p_itemInfo)
	containerHight = containerHight + table.count(washTab)*30 + 10
	-- 解锁属性标题
	local jieAttrTitle = CCScale9Sprite:create("images/hero/info/title_bg.png")
	jieAttrTitle:setContentSize(CCSizeMake(158,40))
	containerHight = containerHight + jieAttrTitle:getContentSize().height
	-- 解锁属性
	local jieAttrTab = TreasAffixModel.getExtactiveAffixByInfo(p_itemInfo)
	containerHight = containerHight + table.count(jieAttrTab)*30 + 10

	-- containerLayer
	local containerLayer = CCLayer:create()
	containerLayer:setContentSize(CCSizeMake(viewSize.width,containerHight))
	scroll:setContainer(containerLayer)
	scroll:setContentOffset(ccp(0,scroll:getViewSize().height-containerLayer:getContentSize().height))
	print("containerLayer==>",containerLayer:getContentSize().width,containerLayer:getContentSize().height,containerHight)
	-- 创建
	local curAtrrLeLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1552"), g_sFontName,25)
	curAtrrLeLabel:setColor(ccc3(0x00,0x00,0x00))
	curAtrrLeLabel:setAnchorPoint(ccp(0.5,0.5))
	curAtrrLeLabel:setPosition(curAttrTitle:getContentSize().width*0.5, curAttrTitle:getContentSize().height*0.5)
	curAttrTitle:addChild(curAtrrLeLabel)

	local jingAtrrLeLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1553"), g_sFontName,25)
	jingAtrrLeLabel:setColor(ccc3(0x00,0x00,0x00))
	jingAtrrLeLabel:setAnchorPoint(ccp(0.5,0.5))
	jingAtrrLeLabel:setPosition(jingAttrTitle:getContentSize().width*0.5, jingAttrTitle:getContentSize().height*0.5)
	jingAttrTitle:addChild(jingAtrrLeLabel)

	local jieAtrrLeLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1554"), g_sFontName,25)
	jieAtrrLeLabel:setColor(ccc3(0x00,0x00,0x00))
	jieAtrrLeLabel:setAnchorPoint(ccp(0.5,0.5))
	jieAtrrLeLabel:setPosition(jieAttrTitle:getContentSize().width*0.5, jieAttrTitle:getContentSize().height*0.5)
	jieAttrTitle:addChild(jieAtrrLeLabel)

	-- 当前属性
	local posY = containerHight
	curAttrTitle:setAnchorPoint(ccp(0,1))
	curAttrTitle:setPosition(ccp(0,posY))
	containerLayer:addChild(curAttrTitle)
	local posY = posY - curAttrTitle:getContentSize().height
	-- 排序
	curAttrTab = TreasureDevelopData.getAttrSortTab(curAttrTab)
	for i=1,#curAttrTab do
		local attr_id = curAttrTab[i].attrId
		local attr_value = curAttrTab[i].attrNum
		print("attr_id",attr_id,"attr_value",attr_value)
		local affixInfo,showNum,realNum = ItemUtil.getAtrrNameAndNum(attr_id,attr_value)
		print("showNum",showNum,"realNum",realNum)
		print_t(affixInfo)
		local attrNameLabel = CCRenderLabel:create( affixInfo.sigleName .. "：", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNameLabel:setColor(ccc3(0xff, 0xff, 0xff))
		attrNameLabel:setAnchorPoint(ccp(1, 0))
		posY = posY-30
		attrNameLabel:setPosition(ccp(95,posY))
		containerLayer:addChild(attrNameLabel)

		local attrNumLabel = CCRenderLabel:create("+" .. showNum,g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
		attrNumLabel:setAnchorPoint(ccp(0, 0))
		attrNumLabel:setPosition(ccp(attrNameLabel:getPositionX()+10,attrNameLabel:getPositionY()))
		containerLayer:addChild(attrNumLabel)

		-- 新增属性
		if( _addAttrTab[attr_id] ~= nil and showNum == _addAttrTab[attr_id] )then
			attrNameLabel:setColor(ccc3(0x00, 0xff, 0x18))
			attrNumLabel:setColor(ccc3(0x00, 0xff, 0x18))
		end
	end
	-- 精炼属性
	posY = posY - 10
	jingAttrTitle:setAnchorPoint(ccp(0,1))
	jingAttrTitle:setPosition(ccp(0,posY))
	containerLayer:addChild(jingAttrTitle)
	posY = posY - jingAttrTitle:getContentSize().height
	washLvSp:setAnchorPoint(ccp(0,1))
	washLvSp:setPosition(ccp(0,posY))
	containerLayer:addChild(washLvSp)
	posY = posY - washLvSp:getContentSize().height
	for attr_id,attr_value in pairs(washTab) do
		local affixInfo,showNum,realNum = ItemUtil.getAtrrNameAndNum(attr_id,attr_value)
		local attrNameLabel = CCRenderLabel:create(affixInfo.sigleName .. "：", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNameLabel:setColor(ccc3(0xff, 0xff, 0xff))
		attrNameLabel:setAnchorPoint(ccp(1, 0))
		posY = posY-30
		attrNameLabel:setPosition(ccp(95,posY))
		containerLayer:addChild(attrNameLabel)

		local attrNumLabel = CCRenderLabel:create("+" .. showNum,g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
		attrNumLabel:setAnchorPoint(ccp(0, 0))
		attrNumLabel:setPosition(ccp(attrNameLabel:getPositionX()+10,attrNameLabel:getPositionY()))
		containerLayer:addChild(attrNumLabel)
	end
	-- 解锁属性
	local posY = posY - 10
	jieAttrTitle:setAnchorPoint(ccp(0,1))
	jieAttrTitle:setPosition(ccp(0,posY))
	containerLayer:addChild(jieAttrTitle)
	local posY = posY - jieAttrTitle:getContentSize().height
	for attr_id,attr_value in pairs(jieAttrTab) do
		local affixInfo,showNum,realNum = ItemUtil.getAtrrNameAndNum(attr_id,attr_value)
		local attrNameLabel = CCRenderLabel:create(affixInfo.sigleName .. "：", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNameLabel:setColor(ccc3(0xff, 0xff, 0xff))
		attrNameLabel:setAnchorPoint(ccp(1, 0))
		posY = posY-30
		attrNameLabel:setPosition(ccp(95,posY))
		containerLayer:addChild(attrNameLabel)

		local attrNumLabel = CCRenderLabel:create("+" .. showNum,g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
		attrNumLabel:setAnchorPoint(ccp(0, 0))
		attrNumLabel:setPosition(ccp(attrNameLabel:getPositionX()+10,attrNameLabel:getPositionY()))
		containerLayer:addChild(attrNumLabel)
	end
	return retBg
end

--[[
	@des 	: 创建上边ui
--]]
function createTopUI()

	-- 左卡牌
	local leftCardSprite = createCardSpriteUI( _showItemInfo )
	leftCardSprite:setAnchorPoint(ccp(0.5, 1))
	leftCardSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.25, _bgLayer:getContentSize().height-70*g_fElementScaleRatio))
	_bgLayer:addChild(leftCardSprite)

	local rightCardSprite = nil
	if(_nextDevelopNum <= _maxDevelopNum)then
		-- 右卡牌
		rightCardSprite = createCardSpriteUI( _disItemInfo )
		rightCardSprite:setAnchorPoint(ccp(0.5, 1))
		rightCardSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.75, _bgLayer:getContentSize().height-70*g_fElementScaleRatio))
		_bgLayer:addChild(rightCardSprite)
	else
		rightCardSprite = createCardSpriteUI( _showItemInfo )
		rightCardSprite:setAnchorPoint(ccp(0.5, 1))
		rightCardSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.75, _bgLayer:getContentSize().height-70*g_fElementScaleRatio))
		_bgLayer:addChild(rightCardSprite)
	end

	--箭头
	local arrowSp = CCSprite:create("images/hero/transfer/arrow.png")
	arrowSp:setAnchorPoint(ccp(0.5,0.5))
	arrowSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height-230*g_fElementScaleRatio))
	_bgLayer:addChild(arrowSp)
	arrowSp:setScale(g_fElementScaleRatio*0.7)

end

--[[
	@des 	: 创建中间边ui
--]]
function createMiddleUI()
	-- 左方属性
	local leftAttrSp = createAttrSpriteUI( _showItemInfo )
	leftAttrSp:setAnchorPoint(ccp(0.5, 0.5))
	leftAttrSp:setPosition(ccp(_bgLayer:getContentSize().width*0.23, _bgLayer:getContentSize().height*0.45))
	_bgLayer:addChild(leftAttrSp)
	leftAttrSp:setScale(g_fElementScaleRatio)

	-- 右方属性
	local rightAttrSp = nil
	if(_nextDevelopNum <= _maxDevelopNum)then
		rightAttrSp = createAttrSpriteUI( _disItemInfo )
	else
		rightAttrSp = CCScale9Sprite:create("images/develop/scroll_bg.png")
		rightAttrSp:setContentSize(CCSizeMake(277,340))
	end
	rightAttrSp:setAnchorPoint(ccp(0.5, 0.5))
	rightAttrSp:setPosition(ccp(_bgLayer:getContentSize().width*0.77, _bgLayer:getContentSize().height*0.45))
	_bgLayer:addChild(rightAttrSp)
	rightAttrSp:setScale(g_fElementScaleRatio)

	--箭头
	local arrowSp = CCSprite:create("images/hero/transfer/arrow.png")
	arrowSp:setAnchorPoint(ccp(0.5,0.5))
	arrowSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.45))
	_bgLayer:addChild(arrowSp)
	arrowSp:setScale(g_fElementScaleRatio*0.7)
end

--[[
	@des 	: 创建材料ui
--]]
function createMaterialUI()

	local materialBg = CCScale9Sprite:create("images/star/intimate/bottom9s.png")
	materialBg:setContentSize(CCSizeMake(623,130))
	materialBg:setAnchorPoint(ccp(0.5,0.5))
	materialBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.18))
	_bgLayer:addChild(materialBg)
	materialBg:setScale(g_fElementScaleRatio)

	-- 进化所需材料
	local needLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1550"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    needLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    needLabel:setAnchorPoint(ccp(0,0))
    needLabel:setPosition(ccp(20,materialBg:getContentSize().height+2))
    materialBg:addChild(needLabel)

	-- 左右箭头
	local arrow1 = CCSprite:create("images/pet/petfeed/btn_left.png")
	arrow1:setAnchorPoint(ccp(0,0.5))
	arrow1:setPosition(ccp(10, materialBg:getContentSize().height*0.5))
	materialBg:addChild(arrow1)

	local arrow2 = CCSprite:create("images/pet/petfeed/btn_right.png")
	arrow2:setAnchorPoint(ccp(1,0.5))
	arrow2:setPosition(ccp(materialBg:getContentSize().width-10, materialBg:getContentSize().height*0.5))
	materialBg:addChild(arrow2)

	-- 材料列表
	if(_nextDevelopNum <= _maxDevelopNum)then
		createMaterialList(materialBg)
	end
end

--[[
	@des 	: 创建下边按钮ui
--]]
function createBottomUI()
	-- 按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_layer_priority-2)
    _bgLayer:addChild(menuBar)

	-- 创建返回按钮 
	local closeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(190, 73), GetLocalizeStringBy("lic_1512"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	closeMenuItem:setAnchorPoint(ccp(0.5, 0))
	closeMenuItem:setPosition(ccp( _bgLayer:getContentSize().width*0.3, 10*g_fElementScaleRatio ))
	menuBar:addChild(closeMenuItem)
	closeMenuItem:registerScriptTapHandler(closeButtonCallback)
	closeMenuItem:setScale(g_fElementScaleRatio)

	-- 进阶按钮
	local developMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(190, 73), GetLocalizeStringBy("lic_1549"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	developMenuItem:setAnchorPoint(ccp(0.5, 0))
	developMenuItem:setPosition(ccp( _bgLayer:getContentSize().width*0.7, 10*g_fElementScaleRatio ))
	menuBar:addChild(developMenuItem)
	developMenuItem:registerScriptTapHandler(developMenuItemmCallback)
	developMenuItem:setScale(g_fElementScaleRatio)
end


--[[
	@des 	:创建宝物进阶界面
	@param 	:p_item_id 宝物id
--]]
function createLayer(p_item_id)
	-- 初始化变量
	init()

	-- 接收参数
	_showItemId = p_item_id

	-- 隐藏下排按钮
	MainScene.setMainSceneViewsVisible(false, false, false)

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 

    -- 大背景
    _bgSprite = CCSprite:create("images/develop/main_bg.jpg")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)
	
    -- 初始化数据
    initData()

    -- 创建界面
    -- 标题
    local titleSp = CCSprite:create("images/treasure/develop/title.png")
    titleSp:setAnchorPoint(ccp(0,1))
    titleSp:setPosition(ccp(10,_bgLayer:getContentSize().height-13*g_fElementScaleRatio))
    _bgLayer:addChild(titleSp)
    titleSp:setScale(g_fElementScaleRatio)

    -- 创建上边ui
    createTopUI()
    -- 创建中间ui
    createMiddleUI()
    -- 创建材料ui
	createMaterialUI()
	-- 创建下边按钮
	createBottomUI()
    return _bgLayer
end

--[[
	@des 	:显示宝物进阶界面
	@param 	:
--]]
function showLayer(p_item_id)
	print("p_item_id==>",p_item_id)
	local layer = createLayer( p_item_id )
	MainScene.changeLayer(layer, "TreasureDevelopLayer")
end
















