-- FileName: NewForgeViewLayer.lua 
-- Author: licong 
-- Date: 15/7/20 
-- Purpose: 橙装锻造材料显示界面


module("NewForgeViewLayer", package.seeall)

require "script/ui/forge/ForgeData"
require "script/ui/forge/ForgeService"
require "script/ui/item/ItemSprite"

---------------------------[[ 模块变量 ]]--------------------------------
local _bgLayer 				= nil
local _radioMenu			= nil
local _equipIdListData		= nil
local _fragmentContainer	= nil
local _equipType 			= nil
local _selectEquipId  		= nil
local _fuseButton 			= nil
local _itemScrollView 		= nil
local _itemListBg			= nil
local _listItemArray 		= nil
local _moveLayer 			= nil
local _fragmentSetArray 	= nil
local _isPlayerEffect 		= false
local _toucheNode 			= nil
local _costFont 			= nil
local _refreshLabelArr 		= nil
local _forgeNumLabelArr 	= nil
local _methoodListData 		= nil
local _selectShowIndex 		= nil
local _leftArrowSp 			= nil
local _rightArrowSp 		= nil

local _middleTabView 		= nil -- 中间的tableView
local _middleTabViewSize 	= nil -- 中间tableViewSize
local _addMenuItemArr 		= {} -- 加好按钮

local _selectEquipIndex 	= nil -- 选择的装备index
local _lastEpuipIndex 		= nil -- 上次选择的index

local _showMethoodIndex 	= nil -- 显示配方index

local _itemListCellSize 	= nil
local _listTouchLayer 		= nil
local _dragBeganX 			= nil
local _touchBeganX 			= nil
local _nextEquipIndex 		= nil

local _oneKeyBtn 			= nil

local _touchPriority 		= -430

function init()
	_bgLayer 				= nil
	_radioMenu				= nil
	_equipIdListData		= nil
	_fragmentContainer		= nil
	_equipType 				= nil
	_selectEquipId  		= nil
	_fuseButton 			= nil
	_itemScrollView 		= nil
	_itemListBg				= nil
	_listItemArray 			= {}
	_moveLayer 				= nil
	_fragmentSetArray 		= {}
	_isPlayerEffect 		= false
	_toucheNode				= nil
	_costFont 				= nil
	_refreshLabelArr 		= {}
	_forgeNumLabelArr 		= {}
	_methoodListData 		= {}
	_selectShowIndex 		= nil
	_leftArrowSp 			= nil
	_rightArrowSp 			= nil

	_middleTabView 			= nil
	_middleTabViewSize 		= nil
	_addMenuItemArr 		= {}

	_selectEquipIndex 		= nil
	_lastEpuipIndex 		= nil

	_showMethoodIndex 		= nil
	_itemListCellSize 		= nil
	_listTouchLayer 		= nil
	_dragBeganX 			= nil
	_touchBeganX 			= nil
	_nextEquipIndex 		= nil

	_oneKeyBtn 				= nil
end
-------------------------------------------------------------- 按钮事件 --------------------------------------------------------------------
--[[
	@des:	一键兑换回调
	@param:	
	@return: 
]]
function onekeyBtnCallBack( tag, sender )

	local needItemId = _methoodListData[_showMethoodIndex].needItemId
	--判断是否可以合成 材料是否足够
	local isCan = ForgeData.getCanForgeNumByMethoodId(_equipIdListData[_selectEquipIndex].id,needItemId)
	if(isCan)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1853"))
		return
	end
	require "script/ui/forge/OnekeyLayer"
	OnekeyLayer.showView(_touchPriority-100,_equipIdListData[_selectEquipIndex].id,needItemId,function ( ... )
		performWithDelay(_middleTabView, function ( ... )
			_middleTabView:refresh()
			choosedEquipCallFun()
		end, 0.08)
	end)
end

--[[
	@des:	添加装备回调
	@param:	
	@return: 
]]
function addMenuItemAction( tag, sender )
	local needItemId = _methoodListData[_showMethoodIndex].needItemId
	 --  配方数据
    local methoodData = ForgeData.getDBdataByMethoodId(_methoodListData[_showMethoodIndex].methoodId)
	local needItemQuality = methoodData.material_quality
	require "script/ui/forge/ChooseViewLayer"
	ChooseViewLayer.showChooseViewLayer(needItemId,needItemQuality)
end

--[[
	@des:	选择完装备回调
	@param:	
	@return: 
]]
function choosedEquipCallFun( ... )
	local srcTab = ForgeData.getChooseListData()
	local srcMenuItem = _addMenuItemArr[_showMethoodIndex]
	if( srcMenuItem == nil or tolua.cast(srcMenuItem,"CCMenuItemSprite")  == nil)then
		return
	end
	if(table.isEmpty(srcTab))then
		if(srcMenuItem:getChildByTag(110) ~= nil)then
			srcMenuItem:removeChildByTag(110,true)
		end
		return
	end
	-- print("srcItemId",srcTab[1])
	-- 当前页面添加选择装备icon
	if(srcMenuItem:getChildByTag(110) ~= nil)then
		srcMenuItem:removeChildByTag(110,true)
	end
	local srcItemData = ItemUtil.getFullItemInfoByGid(srcTab[1])
	local srcQuality = ItemUtil.getEquipQualityByItemInfo( srcItemData )
	local srcIcon = ItemSprite.getItemSpriteByItemId(srcItemData.item_template_id, nil, nil,nil, srcQuality )
	srcIcon:setAnchorPoint(ccp(0.5, 0.5))
	srcIcon:setPosition(ccp(srcMenuItem:getContentSize().width*0.5, srcMenuItem:getContentSize().height*0.5))
	srcMenuItem:addChild(srcIcon,10,110)
	-- 选择物品名字
    -- local nameColor = HeroPublicLua.getCCColorByStarLevel(srcQuality)
	local srcItemName = ItemUtil.getEquipNameByItemInfo(srcItemData,g_sFontPangWa,18)
	srcItemName:setAnchorPoint(ccp(0.5,1))
	srcItemName:setPosition(ccp(srcIcon:getContentSize().width*0.5 ,0))
	srcIcon:addChild(srcItemName)
	-- 强化等级
	local lvSprite = CCSprite:create("images/base/potential/lv_" .. srcQuality .. ".png")
	lvSprite:setAnchorPoint(ccp(0,1))
	lvSprite:setPosition(ccp(-1, srcIcon:getContentSize().height))
	srcIcon:addChild(lvSprite)
	local lvLabel =  CCRenderLabel:create(srcItemData.va_item_text.armReinforceLevel , g_sFontName, 18, 1, ccc3( 0, 0, 0), type_stroke)
    lvLabel:setColor(ccc3(255,255,255))
    lvLabel:setAnchorPoint(ccp(0.5,0.5))
    lvLabel:setPosition(ccp( lvSprite:getContentSize().width*0.5, lvSprite:getContentSize().height*0.5))
    lvSprite:addChild(lvLabel)
end

--[[
	@des:	铸造按钮回调
	@param:	
	@return: 
]]
function tipCallFun( tag, sender )
  	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 选择的装备
	local itemIdTab = ForgeData.getChooseListData()
	if(table.isEmpty(itemIdTab))then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1074"))
		return
	end
	local srcItemData = ItemUtil.getFullItemInfoByGid(itemIdTab[1])
	-- 返回的费用
	local retCostNum = tonumber(srcItemData.va_item_text.armReinforceCost)

	--是否背包满
	if(ItemUtil.isEquipBagFull(true, nil) == true) then
		return
	end
	--判断是否可以合成 材料是否足够
	local isCan = ForgeData.getCanForgeNumByMethoodId(_equipIdListData[_selectEquipIndex].id,srcItemData.item_template_id)
	if(isCan == false)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1065"))
		return
	end
	-- 费用是否足够
	local costType,costNum = ForgeData.getCostDataByMethoodId(_equipIdListData[_selectEquipIndex].id, srcItemData.item_template_id)
	local isEnough = ForgeData.isEnoughForForge(costType,costNum)
	if(isEnough == false)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1068"))
		return
	end
	if( retCostNum > 0)then
		local methoodData = ForgeData.getDBdataByMethoodId(_equipIdListData[_selectEquipIndex].id)
		local disData = ItemUtil.getItemById( methoodData.orangeId )
		require "script/ui/forge/ForgeTipLayer"
		ForgeTipLayer.showTipLayer(srcItemData,disData,sender,fuseButtonCallback,methoodData.orange_quality)
	else
		fuseButtonCallback( sender )
	end
end

--[[
	@des 	:铸造按钮请求
	@param:	
	@return: 
]]
function fuseButtonCallback( sender )
	-- 选择的装备
	local itemIdTab = ForgeData.getChooseListData()
	if(table.isEmpty(itemIdTab))then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1074"))
		return
	end
	local srcItemData = ItemUtil.getFullItemInfoByGid(itemIdTab[1])
	-- 返回的费用
	local retCostNum = tonumber(srcItemData.va_item_text.armReinforceCost)

	--屏蔽按钮事件
	_isPlayerEffect = true
	sender:setEnabled(false)

	require "script/utils/BaseUI"
	local maskLayer = BaseUI.createMaskLayer(-5000, nil, nil, 0)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(maskLayer, 2000)


	local callbackFunc = function ( isSuccess )
		if(isSuccess == false) then
			--合成失败
			AnimationTip.showTip(GetLocalizeStringBy("key_2635"))
			--放开事件屏蔽
			sender:setEnabled(true)
			_isPlayerEffect = false
		
			maskLayer:removeFromParentAndCleanup(true)
			return
		end

		-- 删除选择的装备icon
		local srcMenuItem =  _addMenuItemArr[_showMethoodIndex]
		if( srcMenuItem ~= nil)then
			srcMenuItem = tolua.cast(srcMenuItem,"CCMenuItemSprite")
			if(srcMenuItem:getChildByTag(110) ~= nil)then
				srcMenuItem:removeChildByTag(110,true)
			end
		end
		
		--合成特效播放
		local lightning = CCLayerSprite:layerSpriteWithNameAndCount("images/base/effect/dzchzh/dzchzh", 1,CCString:create(""))
	    lightning:setAnchorPoint(ccp(0.5, 0.5));
	    lightning:setPosition(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height*0.5)
	    _bgLayer:addChild(lightning,80)
	    lightning:setScale(g_fElementScaleRatio)

		local function lightningEndedCallFunc()
			-- 装备信息板子
			local methoodData = ForgeData.getDBdataByMethoodId(_equipIdListData[_selectEquipIndex].id)
			-- 获取装备数据
			require "db/DB_Item_arm"
			local equip_desc = DB_Item_arm.getDataById(methoodData.orangeId)
			local equipInfoLayer = nil
			if(equip_desc.jobLimit and equip_desc.jobLimit > 0)then
				-- 套装
				equipInfoLayer = SuitInfoLayer.createLayer(methoodData.orangeId ,  nil, nil, nil, nil, showDownMenu,nil, nil, -600,nil,nil,methoodData.orange_quality)
			else
				-- 非套装
				equipInfoLayer = EquipInfoLayer.createLayer(methoodData.orangeId ,  nil, nil, nil, nil, showDownMenu, nil, nil, -600,nil,nil,methoodData.orange_quality)
			end
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:addChild(equipInfoLayer, 1000)
			
			-- 清除选择的装备数据
			ForgeData.cleanChooseListData()
			-- 扣除铸造费用
			local costType,costNum = ForgeData.getCostDataByMethoodId(_equipIdListData[_selectEquipIndex].id, srcItemData.item_template_id)
			ForgeData.deductForgeCost(costType,costNum)

			-- 更新材料数量
			_middleTabView:refresh()

			-- 返回强化费用提示
			if(retCostNum > 0)then 
				-- 加银币
        		UserModel.addSilverNumber(retCostNum)
			end
			
		    --放开事件屏蔽
		    _isPlayerEffect = false
		    sender:setEnabled(true)
		
			maskLayer:removeFromParentAndCleanup(true)
	    end

     	lightning:retain()
        local lightningDelegate = BTAnimationEventDelegate:create()
        lightningDelegate:registerLayerEndedHandler(function ( ... )
    	    lightningEndedCallFunc()
    		-- lightning:release()
        end)
        lightning:setDelegate(lightningDelegate)
	end
	--融合前特效
	local isExcuteService = false
	local goOkFunc = function ( ... )
		if(isExcuteService == false) then
			-- print("send ..")
			
			ForgeService.compose(_equipIdListData[_selectEquipIndex].id,srcItemData.item_id, callbackFunc)
			isExcuteService = true
		end
	end
	-- 开始
	goOkFunc()
end

--[[
	@des 	:装备列表icon按钮
	@param:	
	@return: 
]]
function listItemBtnCallBack( tag, itemBtn )
	print("listItemBtnCallBack==>",tag)
	if( _selectEquipIndex == tag)then
		return
	end
	_lastEpuipIndex = _selectEquipIndex
	_selectEquipIndex = tag
	_itemTableView:updateCellAtIndex(_lastEpuipIndex-1)
	_itemTableView:updateCellAtIndex(_selectEquipIndex-1)
	-- 选择装备的数据
	local selectData = _equipIdListData[_selectEquipIndex]
	-- 配方的id
	for i=1, #_methoodListData do   
		if( _methoodListData[i].methoodId == selectData.id )then
			_showMethoodIndex = _methoodListData[i].showIndex
			break
		end
	end
	-- 刷新中间界面
	refreshMiddleUI()
	-- 刷新费用
	refreshForgeCostNum()
	-- 更新箭头
	refreshMiddleArrowSp()
	-- 更新选择图标
	refreshChooseEquipIcon()
end

-------------------------------------------------------------- 创建ui ----------------------------------------------------------------------
-- 查看物品信息返回回调 为了显示下排按钮
function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, false, true)
end

--[[
	@des 	:得到铸造费用显示
	@param	: 1魂玉，2金币，3银币
	@return:
]]
local function getCostUI( p_type, num )
	local fileTab = {"soul_jade.png","gold.png","coin.png"}
	local sprite = CCSprite:create("images/common/" .. fileTab[p_type])
	local numLabel = CCLabelTTF:create(num,g_sFontName,21)
	numLabel:setColor(ccc3(0xff,0xf6,0x00))
	numLabel:setAnchorPoint(ccp(0,0.5))
	numLabel:setPosition(ccp(sprite:getContentSize().width+2,sprite:getContentSize().height*0.5))
	sprite:addChild(numLabel)
	return sprite
end

--[[
	@des 	:刷新中间左右箭头
	@param	:
	@return:
]]
function refreshMiddleArrowSp()
	-- 箭头
	if(_showMethoodIndex == 1)then 
		_leftArrowSp:setVisible(false)
		_rightArrowSp:setVisible(true)
	elseif(_showMethoodIndex == #_methoodListData)then 
		_leftArrowSp:setVisible(true)
		_rightArrowSp:setVisible(false)
	else
		_leftArrowSp:setVisible(true)
		_rightArrowSp:setVisible(true)
	end
end

--[[
	@des 	:清除数据和选择图标
	@param	:
	@return:
]]
function refreshChooseEquipIcon( ... ) 
	-- 清除选择的数据
	ForgeData.cleanChooseListData()
	-- 清除选择的图标
	for k,v in pairs(_addMenuItemArr) do 
		local srcMenuItem = tolua.cast(v,"CCMenuItemSprite")
		if(srcMenuItem ~= nil)then
			-- 当前页面添加选择装备icon
			if(srcMenuItem:getChildByTag(110) ~= nil)then
				srcMenuItem:removeChildByTag(110,true)
			end
		end
	end
end

--[[
	@des 	:更新铸造费用
	@param	:
	@return:
]]
function refreshForgeCostNum()
	local methoodId = _methoodListData[_showMethoodIndex].methoodId
	local needItemId = _methoodListData[_showMethoodIndex].needItemId
	-- 更新花费费用
	if(_costFont:getChildByTag(121) ~= nil)then
		_costFont:removeChildByTag(121,true)
	end
	local costType,costNum = ForgeData.getCostDataByMethoodId(methoodId,needItemId)
	local  costSp = getCostUI(costType,costNum)
	costSp:setAnchorPoint(ccp(0,0.5))
	costSp:setPosition(ccp(_costFont:getContentSize().width+2,_costFont:getContentSize().height*0.5))
	_costFont:addChild(costSp,1,121)
end

--[[
	@des 	:刷新上边列表界面
	@param	:
	@return:
]]
function refreshEquipListUI()
	print("refreshEquipListUI _selectEquipIndex",_selectEquipIndex)
	local offset = _itemTableView:getContentOffset()
	if( _lastEpuipIndex < _selectEquipIndex and _selectEquipIndex%4 == 1 and _selectEquipIndex < #_equipIdListData )then
		-- 右移动4
		offset.x = offset.x - _itemListCellSize.width*4
	elseif( _lastEpuipIndex > _selectEquipIndex and _selectEquipIndex%4 == 0 )then
		-- 右移动左
		offset.x = offset.x + _itemListCellSize.width*4
	else
	end
	_itemTableView:setContentOffsetInDuration(offset, 0.4)
	_itemTableView:updateCellAtIndex(_lastEpuipIndex-1) 
	_itemTableView:updateCellAtIndex(_selectEquipIndex-1)

end

--[[
	@des 	:刷新中间界面
	@param	:
	@return:
]]
function refreshMiddleUI()
	print("refreshMiddleUI _showMethoodIndex",_showMethoodIndex)
	_middleTabView:showCellByIndex(_showMethoodIndex)
end

--[[
	@des:	滑动提示
	@param:	
	@return: 
]]
function showMoveTip()
    local drag_tip = CCSprite:create("images/forge/drag_tip.png")
    _bgLayer:addChild(drag_tip)
    drag_tip:setAnchorPoint(ccp(1, 0.5))
    drag_tip:setPosition(ccp(_bgLayer:getContentSize().width*0.97, _bgLayer:getContentSize().height*0.7))
    drag_tip:setScale(g_fElementScaleRatio)
    local hand = CCSprite:create("images/forge/shou.png")
    drag_tip:addChild(hand)
    hand:setAnchorPoint(ccp(0.5, 1))
    local begin_point = ccp(140, 0)
    local end_point = ccp(-70, 0)
    local drag_time = 1.5
    hand:setPosition(begin_point)
    local args = CCArray:create()
    args:addObject(CCMoveBy:create(drag_time, end_point))
    args:addObject(CCPlace:create(begin_point))
    args:addObject(CCMoveBy:create(drag_time, end_point))
    local moveEndCallFunc = function()
        drag_tip:removeFromParentAndCleanup(true)
    end
    args:addObject(CCCallFunc:create(moveEndCallFunc))
    hand:runAction(CCSequence:create(args))
end

--[[
	@des:	创建cell
	@param:	
	@return: 
]]
function createMiddleCell( p_data )
	print("p_data") 
	print_t(p_data)
	local cell = STTableViewCell:create()

	local methoodId = p_data.methoodId
	local needItemId = p_data.needItemId

	local moveSprite = CCSprite:create()
	-- local moveSprite = CCLayerColor:create(ccc4(255,0,0,111))
	-- moveSprite:ignoreAnchorPointForPosition(false) 
	-- print("_layerSize --->",_layerSize.width,_layerSize.height)
	moveSprite:setContentSize(CCSizeMake(640, 460))
	-- moveSprite:removeAllChildrenWithCleanup(true)
	moveSprite:setAnchorPoint(ccp(0.5,0.5))
	moveSprite:setPosition(ccp(_middleTabViewSize.width*0.5,_middleTabViewSize.height*0.6))
	cell:addChild(moveSprite)
	moveSprite:setScale(g_fElementScaleRatio*0.9)

	-- 按钮
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0, 0))
    menu:setPosition(ccp(0, 0))
    moveSprite:addChild(menu, 11)
    menu:setTouchPriority(_touchPriority-9)

    --  配方数据
    local methoodData = ForgeData.getDBdataByMethoodId(methoodId)

    -- 需要物品框
	local needMenuItemBg = CCSprite:create("images/forge/src_bg.png")
	needMenuItemBg:setAnchorPoint(ccp(0.5, 0.5))
	needMenuItemBg:setPosition(ccp(moveSprite:getContentSize().width*0.3, moveSprite:getContentSize().height*0.85))
	moveSprite:addChild(needMenuItemBg, 10)
	local needItemData = ItemUtil.getItemById(needItemId)
	local needItemQuality = methoodData.material_quality or needItemData.quality
    local needNameColor = HeroPublicLua.getCCColorByStarLevel(needItemQuality)
	local needItemIcon = ItemSprite.getItemSpriteById(needItemId, nil, showDownMenu, nil, _touchPriority-8, 1010, _touchPriority-20,nil,nil,nil,nil,nil,nil,nil,nil,nil,needItemQuality)
	needItemIcon:setAnchorPoint(ccp(0.5, 0.5))
	needItemIcon:setPosition(ccp(needMenuItemBg:getContentSize().width*0.5, needMenuItemBg:getContentSize().height*0.5))
	needMenuItemBg:addChild(needItemIcon)
	-- 需要物品名字
	local needItemName = CCRenderLabel:create(needItemData.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	needItemName:setColor(needNameColor)
	needItemName:setAnchorPoint(ccp(0.5,1))
	needItemName:setPosition(ccp(needMenuItemBg:getContentSize().width*0.5 ,7))
	needMenuItemBg:addChild(needItemName)

	-- 箭头
	local rightSp = CCSprite:create("images/common/right.png")
	rightSp:setAnchorPoint(ccp(0.5,0.5))
	rightSp:setPosition(ccp(moveSprite:getContentSize().width*0.5, moveSprite:getContentSize().height*0.85))
	moveSprite:addChild(rightSp, 10)

	-- 目标物品框
	local desMenuItemBg = CCSprite:create("images/forge/des_bg.png")
	desMenuItemBg:setAnchorPoint(ccp(0.5, 0.5))
	desMenuItemBg:setPosition(ccp(moveSprite:getContentSize().width*0.7, moveSprite:getContentSize().height*0.85))
	moveSprite:addChild(desMenuItemBg, 10)
	local desItemData = ItemUtil.getItemById(methoodData.orangeId)
	local desItemQuality = methoodData.orange_quality or desItemData.quality
    local nameColor = HeroPublicLua.getCCColorByStarLevel(desItemQuality)
	local desItemIcon = ItemSprite.getItemSpriteById(methoodData.orangeId, nil, showDownMenu, nil, _touchPriority-8, 1010, _touchPriority-20, nil,nil,nil,nil,nil,nil,nil,nil,nil,desItemQuality)
	desItemIcon:setAnchorPoint(ccp(0.5, 0.5))
	desItemIcon:setPosition(ccp(desMenuItemBg:getContentSize().width*0.5, desMenuItemBg:getContentSize().height*0.5))
	desMenuItemBg:addChild(desItemIcon)
	-- 目标物品名字
	local desItemName = CCRenderLabel:create(desItemData.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	desItemName:setColor(nameColor)
	desItemName:setAnchorPoint(ccp(0.5,1))
	desItemName:setPosition(ccp(desMenuItemBg:getContentSize().width*0.5 ,7))
	desMenuItemBg:addChild(desItemName)

	-- 目标特效
	local lightning = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/duanzaoyiguang/duanzaoyiguang"), -1,CCString:create(""))
    lightning:setAnchorPoint(ccp(0.5, 0.5))
    lightning:setPosition(desMenuItemBg:getContentSize().width*0.5,desMenuItemBg:getContentSize().height*0.5)
    desMenuItemBg:addChild(lightning,-1)

	-- 选择物品框
	local srcMenuItemBg = CCSprite:create("images/forge/src_bg.png")
	srcMenuItemBg:setAnchorPoint(ccp(0.5, 0.5))
	srcMenuItemBg:setPosition(ccp(moveSprite:getContentSize().width*0.5, moveSprite:getContentSize().height*0.5))
	moveSprite:addChild(srcMenuItemBg, 10)
	local addIcon = ItemSprite.createAddSprite()
	local addMenuItem = CCMenuItemSprite:create(addIcon,addIcon)
	addMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	addMenuItem:setPosition(ccp(srcMenuItemBg:getPositionX()+2, srcMenuItemBg:getPositionY()-1))
	menu:addChild(addMenuItem)
	-- 注册回调
	addMenuItem:registerScriptTapHandler(addMenuItemAction)

	-- 储存加号按钮
	_addMenuItemArr[ p_data.showIndex ] = addMenuItem

	-- 放入 装备名字
	local font1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1062"), g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	font1:setColor(ccc3(0xff,0xff,0xff))
	font1:setAnchorPoint(ccp(0,0))
	srcMenuItemBg:addChild(font1)
	local font2 = CCRenderLabel:create( needItemData.name,  g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	font2:setAnchorPoint(ccp(0,0))
	font2:setColor(needNameColor)
	srcMenuItemBg:addChild(font2)
	local posX = (srcMenuItemBg:getContentSize().width-font1:getContentSize().width-font2:getContentSize().width)/2
	font1:setPosition(ccp(posX,srcMenuItemBg:getContentSize().height))
	font2:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width,font1:getPositionY()))

	--添加材料
	local fragments = ForgeData.getMaterialsByMethoodIdAndSrcId(methoodId,needItemId)
	local fragmentsCount = table.count(fragments)
	local posX = nil
	local posY = nil
	if(fragmentsCount == 5)then
		posX = {0.15,0.15,0.5,0.85,0.85}
		posY = {0.5,0.2,0.2,0.5,0.2}
	elseif(fragmentsCount == 6)then
		posX = {0.15,0.15,0.385,0.615,0.85,0.85}
		posY = {0.5,0.2,0.2,0.2,0.5,0.2}
	else
		print("fragmentsCount is not 5 or 6")
	end
	for i=1,fragmentsCount do
	    local nx = moveSprite:getContentSize().width*posX[i]
    	local ny = moveSprite:getContentSize().height*posY[i]

    	-- 材料 按钮外框
    	local iconBgSprite  = CCSprite:create("images/everyday/headBg1.png")
    	iconBgSprite:setAnchorPoint(ccp(0.5, 0.5))
    	iconBgSprite:setPosition(ccp(nx, ny))
    	moveSprite:addChild(iconBgSprite, 10)
    	-- 材料icon
    	local iconSprite = ItemSprite.getItemSpriteById(fragments[i].tid, nil, showDownMenu, nil, _touchPriority-8, 1010, _touchPriority-20)
    	iconSprite:setAnchorPoint(ccp(0.5, 0.5))
    	iconSprite:setPosition(ccp(iconBgSprite:getContentSize().width*0.5, iconBgSprite:getContentSize().height*0.5))
    	iconBgSprite:addChild(iconSprite)
    	-- 材料 名字
    	local itemData = ItemUtil.getItemById(fragments[i].tid)
	    local nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
		local itemName = CCRenderLabel:create(itemData.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
		itemName:setColor(nameColor)
		itemName:setAnchorPoint(ccp(0.5,1))
		itemName:setPosition(ccp(iconBgSprite:getContentSize().width*0.5 ,-2))
		iconBgSprite:addChild(itemName)
		-- 材料数量/需要数量
		local needNumberLabel = CCLabelTTF:create( "/" .. fragments[i].needNum, g_sFontPangWa,18)
	    needNumberLabel:setAnchorPoint(ccp(1,0))
	    needNumberLabel:setColor(ccc3(0x00,0xff,0x18))
	    iconBgSprite:addChild(needNumberLabel,10)
	    needNumberLabel:setPosition(ccp(iconBgSprite:getContentSize().width-5,5))

		local numColor = nil
        if( fragments[i].haveNum >= fragments[i].needNum )then
            numColor = ccc3(0x00,0xff,0x18)
        else
            numColor = ccc3(0xff,0x00,0x00)
        end
	    local numberLabel =  CCLabelTTF:create( fragments[i].haveNum, g_sFontPangWa,18)
	    numberLabel:setAnchorPoint(ccp(1,0))
	    numberLabel:setColor(numColor)
	    iconBgSprite:addChild(numberLabel,10)
	    numberLabel:setPosition(ccp(needNumberLabel:getPositionX()-needNumberLabel:getContentSize().width,5))
	end
	
	return cell
end

--[[
	@des 	:创建上边列表cell
	@param 	:p_data, p_selectIndex 当前选择的装备
	@retrun :
]]
function createCell( p_data, p_selectIndex )
	-- print("p_selectIndex==>",p_selectIndex)
	-- print_t(p_data)

	local cell = CCTableViewCell:create()

	local desItemData = ItemUtil.getItemById(tonumber(p_data.orangeId))
	local quality = p_data.orange_quality or desItemData.quality

	local iconSprite = ItemSprite.getItemSpriteByItemId(tonumber(p_data.orangeId),nil, nil,nil, quality )
	iconSprite:setAnchorPoint(ccp(0.5,1))
	iconSprite:setPosition(ccp(65,115))
	cell:addChild(iconSprite,100)

	local menu = BTMenu:create()
	menu:setPosition(ccp(0, 0))
	iconSprite:addChild(menu)
	menu:setTouchPriority(_touchPriority-5)
	menu:setScrollView(_itemTableView)
	local normalSp = CCSprite:create()
	normalSp:setContentSize(iconSprite:getContentSize())
	local selectSp = CCSprite:create()
	selectSp:setContentSize(iconSprite:getContentSize())
	local menuItem = CCMenuItemSprite:create(normalSp,selectSp)
	menuItem:setAnchorPoint(ccp(0.5,0.5))
	menuItem:setPosition(ccp(iconSprite:getContentSize().width*0.5,iconSprite:getContentSize().height*0.5))
	menu:addChild(menuItem,1,p_data.index)
	menuItem:registerScriptTapHandler(listItemBtnCallBack)

	local highlightSprite 	= CCSprite:create("images/hero/quality/highlighted.png")
	highlightSprite:setAnchorPoint(ccp(0.5, 0.5))
	highlightSprite:setPosition(ccpsprite(0.5, 0.5, iconSprite))
	iconSprite:addChild(highlightSprite,101)
	highlightSprite:setVisible(false)

	if( p_data.index == p_selectIndex )then
		highlightSprite:setVisible(true)
	end

	-- 目标物品名字
    local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local desItemName = CCRenderLabel:create(desItemData.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	desItemName:setColor(nameColor)
	desItemName:setAnchorPoint(ccp(0.5,1))
	desItemName:setPosition(ccp(iconSprite:getContentSize().width*0.5 ,0))
	iconSprite:addChild(desItemName,10)

	return cell
end

--[[
	@des 	:创建配方tableView
	@param 	:
	@retrun :
]]
function createMiddleUI( ... )

	local tHeight = _itemListBg:getPositionY()-_itemListBg:getContentSize().height*g_fScaleX
	_middleTabViewSize = CCSizeMake(_bgLayer:getContentSize().width,tHeight)
	print("middHeiht:",_bgLayer:getContentSize().width, tHeight)
	-- 配方数据
	_methoodListData = ForgeData.getShowMethoodDataId(_equipIdListData)
	-- print("_methoodListData==")
	-- print_t(_methoodListData)
	local num = table.count(_methoodListData)
	print("num==>",num)

	-- 默认第一个装备的第一个配方
	_showMethoodIndex = 1

	local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return _middleTabViewSize
		elseif functionName == "cellAtIndex" then
			return createMiddleCell(_methoodListData[index])
		elseif functionName == "numberOfCells" then
			return num
		elseif functionName == "cellTouched" then
			
		elseif functionName == "scroll" then
			
		elseif functionName == "moveEnd" then
			-- 配方id
			_showMethoodIndex = index
			local showMethoodData = _methoodListData[_showMethoodIndex]
			-- 选择装备id
			_lastEpuipIndex = _selectEquipIndex
			for i=1, #_equipIdListData do   
				if( _equipIdListData[i].id == showMethoodData.methoodId )then
					_selectEquipIndex = _equipIdListData[i].index
					break
				end
			end
			-- 刷新上边的UI 
			refreshEquipListUI()
			-- 刷新费用
			refreshForgeCostNum()
			-- 更新箭头
    		refreshMiddleArrowSp()
    		-- 更新选择图标
    		refreshChooseEquipIcon()
		end
	end
	-- 中间tabView
    _middleTabView = STTableView:create()
    _middleTabView:setDirection(kCCScrollViewDirectionHorizontal)
    _middleTabView:setContentSize(_middleTabViewSize)
	_middleTabView:setEventHandler(eventHandler)
	_middleTabView:setPageViewEnabled(true)
	_middleTabView:setTouchPriority(_touchPriority - 10)
	_bgLayer:addChild(_middleTabView)
	_middleTabView:reloadData()

	-- 一键兑换按钮
	local menu1 = CCMenu:create()
	menu1:setAnchorPoint(ccp(0, 0))
	menu1:setPosition(ccp(0, 0))
	_bgLayer:addChild(menu1, 15)
	menu1:setTouchPriority(_touchPriority-10)

	_oneKeyBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(207, 76),GetLocalizeStringBy("lic_1848"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_oneKeyBtn:setAnchorPoint(ccp(0.5, 0.5))
    _oneKeyBtn:setPosition(ccp(_bgLayer:getContentSize().width*0.3, _bgLayer:getContentSize().height*0.115))
    _oneKeyBtn:registerScriptTapHandler(onekeyBtnCallBack)
	menu1:addChild(_oneKeyBtn,15)
	_oneKeyBtn:setScale(g_fElementScaleRatio)

	-- 开始铸造按钮
	local buttonBg = CCSprite:create("images/forge/buttonBg.png")
	buttonBg:setAnchorPoint(ccp(0.5,0.5))
	buttonBg:setPosition(ccp(_bgLayer:getContentSize().width*0.7, _bgLayer:getContentSize().height*0.1))
	_bgLayer:addChild(buttonBg)
	buttonBg:setScale(g_fElementScaleRatio)
	
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0, 0))
	menu:setPosition(ccp(0, 0))
	buttonBg:addChild(menu, 15)
	menu:setTouchPriority(_touchPriority-10)

	_fuseButton =  LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(207, 76),GetLocalizeStringBy("lic_1058"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	_fuseButton:setAnchorPoint(ccp(0.5, 0.5))
    _fuseButton:setPosition(ccp(buttonBg:getContentSize().width*0.5, buttonBg:getContentSize().height*0.6))
    _fuseButton:registerScriptTapHandler(tipCallFun)
	menu:addChild(_fuseButton,15)

	-- 锻造花费
	_costFont = CCLabelTTF:create(GetLocalizeStringBy("lic_1067"),g_sFontName,21)
	_costFont:setAnchorPoint(ccp(1,0.5))
	_costFont:setColor(ccc3(0xff,0xf6,0x00))
	_costFont:setPosition(ccp(_bgLayer:getContentSize().width*0.7, _bgLayer:getContentSize().height*0.04))
	_bgLayer:addChild(_costFont)
	_costFont:setScale(g_fElementScaleRatio)

	-- 箭头
    -- 左箭头
    _leftArrowSp = CCSprite:create( "images/common/left_big.png")
    _leftArrowSp:setAnchorPoint(ccp(0,0.5))
    _leftArrowSp:setPosition(0,_bgLayer:getContentSize().height*0.5)
    _bgLayer:addChild(_leftArrowSp,1, 101)
    _leftArrowSp:setVisible(false)
    _leftArrowSp:setScale(g_fElementScaleRatio)


    -- 右箭头
    _rightArrowSp = CCSprite:create( "images/common/right_big.png")
    _rightArrowSp:setAnchorPoint(ccp(1,0.5))
    _rightArrowSp:setPosition(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height*0.5)
    _bgLayer:addChild(_rightArrowSp,1, 102)
    _rightArrowSp:setVisible(true)
    _rightArrowSp:setScale(g_fElementScaleRatio)

    -- 可滑动提示
    showMoveTip()

    -- 更新费用
    refreshForgeCostNum()
end

--[[
	@des 	:上边列表touch事件
	@param 	:
	@retrun :
]]
function onTouchEvent( event, x, y )
	local position = _itemTableView:convertToNodeSpace(ccp(x, y))
    if event == "began" then
    	local rect =  CCRectMake(0, 0, _listTouchLayer:getContentSize().width, _listTouchLayer:getContentSize().height)
    	-- print("began==>>>>",rect:containsPoint(position))
        if( rect:containsPoint(position) ) then
           	_dragBeganX = _itemTableView:getContentOffset().x
           	_touchBeganX = position.x
           	-- print("began _dragBeganX",_dragBeganX)
           	-- print("began _touchBeganX",_touchBeganX)
        	return true
        else
        	return false
        end
    elseif event == "moved" then
    	-- print("moved==>>>>")
    	-- print("moved _dragBeganX",_dragBeganX)
        -- print("moved _touchBeganX",_touchBeganX)
        local offset = _itemTableView:getContentOffset()
        offset.x = _dragBeganX + position.x - _touchBeganX
        _itemTableView:setContentOffset(offset)
    elseif event == "ended" then
    	-- print("ended==>>>>")
	    local dragEndedX = _itemTableView:getContentOffset().x
	    local dragDistance = dragEndedX - _dragBeganX
	  
	    local offset = _itemTableView:getContentOffset()
	    if dragDistance >= 100 then
	        offset.x = _dragBeganX + _itemListCellSize.width*4
	        -- 上一页第一个
	       	_nextEquipIndex = (math.ceil(_selectEquipIndex/4)-1)*4-3
	    elseif dragDistance <= -100 then
	        offset.x = _dragBeganX - _itemListCellSize.width*4
	       	 -- 下一页第一个
	        _nextEquipIndex = math.ceil(_selectEquipIndex/4)*4+1
	    else
	        offset.x = _dragBeganX
	        _nextEquipIndex = 0
	    end
	    local offsetMaxX = 0
	    if offset.x > offsetMaxX then
	        offset.x = offsetMaxX
	    end
	    local container = _itemTableView:getContainer()
	    local offsetMinX = -container:getContentSize().width + _itemTableView:getViewSize().width
	    if offset.x < offsetMinX then
	        offset.x = offsetMinX
	    end
	    _itemTableView:setContentOffset(offset)

	    -- print("_nextEquipIndex",_nextEquipIndex)
	    if( _nextEquipIndex > 0 and _nextEquipIndex < #_equipIdListData )then
	    	listItemBtnCallBack( _nextEquipIndex )
	    end
    end
end

--[[
	@des 	:创建上边列表
	@param 	:
	@retrun :
]]
function createItemList( ... )
	local fullRect = CCRectMake(0,0,73,75)
	local insetRect = CCRectMake(29,31,20,10)
	_itemListBg = CCScale9Sprite:create("images/forge/top_bg.png", fullRect, insetRect)
	_itemListBg:setContentSize(CCSizeMake(640,145))
	_itemListBg:setAnchorPoint(ccp(0.5, 1))
	_itemListBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height+10*g_fScaleX))
	_bgLayer:addChild(_itemListBg, 15)
	_itemListBg:setScale(g_fScaleX)

	local leftArrow 	= CCSprite:create("images/formation/btn_left.png")
	leftArrow:setAnchorPoint(ccp(0, 0.5))
	leftArrow:setPosition(ccpsprite(0, 0.5, _itemListBg))
	_itemListBg:addChild(leftArrow)

	local rightArrow 	= CCSprite:create("images/formation/btn_right.png")
	rightArrow:setAnchorPoint(ccp(1, 0.5))
	rightArrow:setPosition(ccpsprite(1, 0.5, _itemListBg))
	_itemListBg:addChild(rightArrow)

	-- 装备列表数据
	if( _equipType == NewForgeLayer.kNormalEquipType )then
		_equipIdListData = ForgeData.getFoundryMethodByType(0) 
	elseif( _equipType == NewForgeLayer.kSpecialEquipType )then
		_equipIdListData = ForgeData.getFoundryMethodByType(1) 
	elseif( _equipType == NewForgeLayer.kRedNormalEquipType )then
		_equipIdListData = ForgeData.getFoundryMethodByType(0,7) 
	elseif( _equipType == NewForgeLayer.kRedSpecialEquipType )then
		_equipIdListData = ForgeData.getFoundryMethodByType(1,7)
	else
	end
   
	-- print("_equipIdListData==")
	-- print_t(_equipIdListData)
	local num = table.count(_equipIdListData)

	-- 默认第一个
	_selectEquipIndex = 1
	_lastEpuipIndex = _selectEquipIndex

	_itemListCellSize = CCSizeMake(131, 120)
    require "script/ui/WorldArena/rank/WorldArenaRankCell"
	local cellBg = CCSprite:create("images/match/rank_bg.png")
    local cellSize = cellBg:getContentSize() 
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = _itemListCellSize
		elseif fn == "cellAtIndex" then
			r = createCell(_equipIdListData[a1+1],_selectEquipIndex)
		elseif fn == "numberOfCells" then
			r = num
		elseif fn == "cellTouched" then
		end
		return r
	end)

	_itemTableView = LuaTableView:createWithHandler(h, CCSizeMake(524, 120))
	_itemTableView:setBounceable(true)
	_itemTableView:setDirection(kCCScrollViewDirectionHorizontal)
	_itemTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_itemTableView:setTouchPriority(_touchPriority)
	_itemTableView:ignoreAnchorPointForPosition(false)
	_itemTableView:setAnchorPoint(ccp(0.5,0.5))
	_itemTableView:setPosition(ccp(_itemListBg:getContentSize().width*0.5,_itemListBg:getContentSize().height*0.5))
	_itemListBg:addChild(_itemTableView)
	_itemTableView:setTouchEnabled(false)

	_listTouchLayer = CCLayer:create()
	_listTouchLayer:setContentSize(CCSizeMake(524, 120))
	_listTouchLayer:ignoreAnchorPointForPosition(false)
	_listTouchLayer:setAnchorPoint(ccp(0.5,0.5))
	_itemTableView:addChild(_listTouchLayer)
	_listTouchLayer:setTouchEnabled(true)
	_listTouchLayer:setTouchPriority(_touchPriority-3)
	_listTouchLayer:registerScriptTouchHandler(onTouchEvent)
end


--[[
	@des 	:创建合成界面
	@param 	:p_type 合成物品类型(kNormalEquipType, kSpecialEquipType)
			 p_layerSize  层的大小
	@retrun :CClayer
]]
function createLayer( p_type, p_layerSize )
	
	init()

	_equipType 		= p_type

	_bgLayer 		= CCLayer:create()
	-- _bgLayer = CCLayerColor:create(ccc4(0,255,0,111))
	_bgLayer:setContentSize(p_layerSize)

	-- 数据
	-- 清空选择的装备数据
    ForgeData.cleanChooseListData()

	-- 上边列表
	createItemList()

	-- 创建中间界面
	createMiddleUI()

	return _bgLayer
end
















