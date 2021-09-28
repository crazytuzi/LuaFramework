-- FileName: GodInheritLayer.lua 
-- Author: licong 
-- Date: 15/4/1 
-- Purpose: 神兵洗练属性传承界面


module("GodInheritLayer", package.seeall)

require "script/ui/godweapon/godweaponfix/GodWeaponFixData"
require "script/ui/godweapon/godinherit/GodInheritService"
require "script/ui/tip/AnimationTip"

local _bgLayer 							= nil
local _bgSprite 						= nil
local _disGodSprite 					= nil
local _fixIndexSpArr 					= {}
local _allCostNumFont 					= nil

local _showItemId 						= nil -- 传承原物品itemid
local _showItemInfo 					= nil -- 传承原物品信息
local _isOnHero 						= nil -- 传承原神兵是否装备在英雄上
local _hid 								= nil -- 装备传承原神兵的hid
local _isDisOnHero 						= nil -- 传承目标神兵是否装备在英雄上
local _disHid 							= nil -- 装备传承目标神兵的hid
local _chooseIndexArr 					= {}  -- 选择的传承index
local _allCostNum 						= nil -- 总费用


local _disItemId 						= nil -- 传承目标物品itemid
local _disItemInfo 						= nil -- 传承目标物品信息

local _lastDisItemId 					= nil -- 上一个传承目标神兵id


local _showMark 						= nil -- 界面跳转tag

------------------------------ 常量 -----------------------------------
-- 界面优先级
local _layer_priority 	= -500
-- 传承属性背景y坐标
local _attrSpritePosY = {0.49,0.35,0.21,0.07}

-- 传承选择按钮tag
local _chooseMenuTag = 100

--[[
	@des 	:初始化
--]]
function init()
	_bgLayer 							= nil
	_bgSprite 							= nil
	_disGodSprite 						= nil
	_fixIndexSpArr 						= {}
	_allCostNumFont 					= nil

	_showItemId 						= nil
	_showItemInfo 						= nil 
	_quality 							= nil
	_evolveNum 							= nil
	_evolveShowNum 						= nil
	_isOnHero 							= nil
	_hid 								= nil
	_chooseIndexArr 					= {}
	_allCostNum 						= nil
	_lastDisItemId 						= nil
	_isDisOnHero 						= nil 
	_disHid 							= nil

	_disItemId 							= nil
	_disItemInfo 						= nil

	_showMark 							= nil
end

--[[
	@des 	:初始化数据
--]]
function initData()
	-- 神兵是否在武将上
	_isOnHero = false
	-- 强化神兵的信息
	_showItemInfo = ItemUtil.getItemByItemId(_showItemId)
	if(_showItemInfo == nil)then
		_showItemInfo = ItemUtil.getGodWeaponInfoFromHeroByItemId(_showItemId)
		-- 神兵是装备上的
		_isOnHero = true
		-- 装备神兵的hid
		_hid = _showItemInfo.hid
	end

	print("_showItemInfo==>")
	print_t(_showItemInfo)
	
	-- 清除选择的神兵
	GodWeaponFixData.cleanSelectGodList()

	-- 总费用
	_allCostNum = 0
end

--[[
	@des 	:刷新数据
--]]
function refreshData()
	-- 神兵是否在武将上
	_isOnHero = false
	-- 强化神兵的信息
	_showItemInfo = ItemUtil.getItemByItemId(_showItemId)
	if(_showItemInfo == nil)then
		_showItemInfo = ItemUtil.getGodWeaponInfoFromHeroByItemId(_showItemId)
		-- 神兵是装备上的
		_isOnHero = true
		-- 装备神兵的hid
		_hid = _showItemInfo.hid
	end

	print("_showItemInfo==>")
	print_t(_showItemInfo)
	
	local temp = GodWeaponFixData.getSelectGodList()
	if( not table.isEmpty(temp) )then
		_disItemId = temp[1].item_id
		_disItemInfo = ItemUtil.getItemByItemId(_disItemId)
		if(_disItemInfo == nil)then
			_disItemInfo = ItemUtil.getGodWeaponInfoFromHeroByItemId(_disItemId)
			-- 神兵是装备上的
			_isDisOnHero = true
			-- 装备神兵的hid
			_disHid = _disItemInfo.hid
		end
	else
		_disItemId = nil
		_disItemInfo = nil
		_isDisOnHero = false
		_disHid = nil
	end
	print("_disItemInfo==>",_disItemId)
	print_t(_disItemInfo)

	-- 保存为上一个目标id
	_lastDisItemId = _disItemId

	-- 总费用置0
	_allCostNum = 0

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
---------------------------------------------------------------- 按钮事件 -------------------------------------------------------------------
--[[
	@des 	:返回按钮回调
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")

	require "script/ui/godweapon/godweaponfix/GodWeaponFixLayer"
	GodWeaponFixLayer.showLayer(_showItemId)
	-- 设置界面记忆
	GodWeaponFixLayer.setChangeLayerMark( _showMark )
end

--[[
	@des 	:加号按钮回调
	@param 	:
	@return :
--]]
function addMenuItemCallBack( tag, sender )
	if(tag == tonumber(_showItemId))then
		return
	end
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local addCallBack = function ( ... )
    	local temp = GodWeaponFixData.getSelectGodList()
    	-- print("temp==>",_lastDisItemId,temp[1]) print_t(temp)
    	if( _lastDisItemId == nil or table.isEmpty(temp) or tonumber(_lastDisItemId) ~= tonumber(temp[1].item_id) )then
    		refreshAllUI()
    	end
    end

    require "script/ui/godweapon/godinherit/GodInheritChooseLayer"
    GodInheritChooseLayer.showSelectLayer( _showItemId, addCallBack ) 

end

--[[
	@des 	:传承按钮回调
	@param 	:
	@return :
--]]
function inheritMenuItemCallback( tag, sender )
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    -- 传承不能为空
    if( table.isEmpty(_chooseIndexArr) )then
    	AnimationTip.showTip(GetLocalizeStringBy("lic_1527"))
		return
    end

    -- 金币不足
	if( UserModel.getGoldNumber() < _allCostNum ) then  
		require "script/ui/tip/LackGoldTip"    
		LackGoldTip.showTip()
		return
	end

	local nextCallBack = function ( ... )
		-- 传承成功
		AnimationTip.showTip(GetLocalizeStringBy("lic_1568"))
	
	    -- 修改缓存数据
	    for k,v in pairs(_chooseIndexArr) do
	    	-- 原属性
	    	local srcAtrr = GodWeaponFixData.getGodWeapinConfirmAttr( _showItemId, v )
	    	-- 目标属性
	    	local disAtrr = GodWeaponFixData.getGodWeapinConfirmAttr( _disItemId, v )

	    	-- 修改原属性
	    	if(_isOnHero == true)then 
    			-- 修改英雄身上的数据
	    		HeroModel.changeHeroGodWeaponConfirmedBy(_hid,_showItemId, v, disAtrr)
		    else
		    	-- 修改背包数据
		    	DataCache.changeGodWeaponConfirmedInBag( _showItemId, v, disAtrr )
		    end

		    -- 修改目标属性
		    if(_isDisOnHero == true)then 
    			-- 修改英雄身上的数据
	    		HeroModel.changeHeroGodWeaponConfirmedBy(_disHid,_disItemId, v, srcAtrr)
		    else
		    	-- 修改背包数据
		    	DataCache.changeGodWeaponConfirmedInBag( _disItemId, v, srcAtrr )
		    end
	    end

	    -- 需要修改背包的信息已经过期
		DataCache.setBagStatus(true)

	    -- 扣除金币
	    UserModel.addGoldNumber(-_allCostNum)

	    -- 清空选择的层数
	    _chooseIndexArr = {}

	    -- 刷界面
	    refreshAllUI()
	end
	-- 发请求
	GodInheritService.legend(_showItemId,_disItemId, _chooseIndexArr, nextCallBack )
end

--[[
	@des 	:传承选择按钮回调
	@param 	:
	@return :
--]]
function chooseMenuItemCallback( tag, sender )
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    -- 创建目标为空
    if(_disItemId == nil)then 
		AnimationTip.showTip(GetLocalizeStringBy("lic_1523"))
		return
    end
    -- 得到当前层属性 
	local curIndexAttrId = GodWeaponFixData.getGodWeapinConfirmAttr( _showItemId, tag )
	local disIndexAttrId = GodWeaponFixData.getGodWeapinConfirmAttr( _disItemId, tag )
	-- 传承属性为空
	if(curIndexAttrId == nil and  disIndexAttrId == nil)then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1524"))
		return
	end
	-- 接受传承的神兵是否有该层数
	local curAllNum = GodWeaponFixData.getGodWeapinFixNum(nil,_showItemId)
	local disAllNum = GodWeaponFixData.getGodWeapinFixNum(nil,_disItemId)
	if(tag > curAllNum or tag > disAllNum)then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1526"))
		return
	end
	-- 接受传承属性神兵该层封印是否开启
	-- local isOpen1 = GodWeaponFixData.getGodWeapinFixIsOpneByFixNum(nil, _showItemId, tag)
	-- local isOpen2 = GodWeaponFixData.getGodWeapinFixIsOpneByFixNum(nil, _disItemId, tag)
	-- if( isOpen1 == false or isOpen2 == false)then
	-- 	AnimationTip.showTip(GetLocalizeStringBy("lic_1525"))
	-- 	return
	-- end

    -- 添加数据
    local isIn = false
	local pos = 0
	for k,v in pairs(_chooseIndexArr) do
		if(tonumber(v) == tonumber(tag))then
			isIn = true
			pos = k
			break
		end
	end
	if(isIn)then
		table.remove(_chooseIndexArr,pos)
	else
		table.insert(_chooseIndexArr,tag)
	end
   
  	-- 刷新界面
	refreshChooseUI()
end
----------------------------------------------------------------------- 创建UI -------------------------------------------------------------------------
--[[
	@des 	:刷新全部UI
	@param 	:
	@return :
--]]
function refreshChooseUI()
	-- 刷新按钮
	-- for i=1,#_fixIndexSpArr do
	-- 	local isIn = false
	-- 	for k,v in pairs(_chooseIndexArr) do
	-- 		if(v == i)then
	-- 			isIn = true
	-- 			break
	-- 		end
	-- 	end
	-- 	if(  tolua.cast(_fixIndexSpArr[i],"CCSprite") ~= nil )then
	-- 		if(isIn)then
	-- 			-- 已选择
	-- 			local bgsp = tolua.cast(_fixIndexSpArr[i],"CCSprite")
	-- 			local menu = tolua.cast(bgsp:getChildByTag(_chooseMenuTag),"CCMenu")
	-- 			local menuItem = tolua.cast(menu:getChildByTag(i),"CCMenuItemImage")
	-- 			menuItem:selected()
	-- 		else
	-- 			-- 未选择
	-- 			local bgsp = tolua.cast(_fixIndexSpArr[i],"CCSprite")
	-- 			local menu = tolua.cast(bgsp:getChildByTag(_chooseMenuTag),"CCMenu")
	-- 			local menuItem = tolua.cast(menu:getChildByTag(i),"CCMenuItemImage")
	-- 			menuItem:unselected()
	-- 		end
	-- 	end
	-- end
	-- local offset = _listTabelView:getContentOffset()
	_listTabelView:reloadData()
	-- _listTabelView:setContentOffset(offset)

	-- 刷新费用
	_allCostNum = 0
	for k,v in pairs(_chooseIndexArr) do
		local costNum = GodWeaponFixData.getGodInheritCostBy(v)
		_allCostNum = _allCostNum + costNum
	end

	_allCostNumFont:setString(_allCostNum)
end

--[[
	@des 	:刷新全部UI
	@param 	:
	@return :
--]]
function refreshAllUI()
	-- 先刷新数据
	refreshData()
	-- 刷新右边
	if( tolua.cast(_disGodSprite,"CCSprite") ~= nil )then
		_disGodSprite:removeFromParentAndCleanup(true)
		_disGodSprite = nil
	end
	_disGodSprite = createGodBodyUI(_disItemInfo)
    _disGodSprite:setAnchorPoint(ccp(0.5,0))
    _disGodSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.8,_bgLayer:getContentSize().height*0.61))
    _bgLayer:addChild(_disGodSprite)
    _disGodSprite:setScale(g_fElementScaleRatio)
	-- 刷新属性
	-- for k,v in pairs(_fixIndexSpArr) do
	-- 	if( tolua.cast(v,"CCSprite") ~= nil )then
	-- 		v:removeFromParentAndCleanup(true)
	-- 	end
	-- end
	-- _fixIndexSpArr = {}
	-- 创建每一条洗练属性
	-- for i=1,4 do
	-- 	local attrSprite = createAttrUI(i)
	-- 	attrSprite:setAnchorPoint(ccp(0.5,0))
	-- 	attrSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*_attrSpritePosY[i]))
	-- 	_bgLayer:addChild(attrSprite)
	-- 	attrSprite:setScale(g_fElementScaleRatio)
	-- 	-- 保存
	-- 	table.insert(_fixIndexSpArr,attrSprite)
	-- end
	
	local offset = _listTabelView:getContentOffset()
	_listTabelView:reloadData()
	_listTabelView:setContentOffset(offset)

	-- 刷新费用
	_allCostNumFont:setString(_allCostNum)
end

--[[
	@des 	:创建底部UI
	@param 	:p_fixIndex:洗练属性层id
	@return :sprite
--]]
function createAttrUI(p_fixIndex)
	local retCell = CCTableViewCell:create()
	local retSprite = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
	retSprite:setContentSize(CCSizeMake(588, 97))
	retSprite:setPosition(0,0)
	retCell:addChild(retSprite)

	-- 标题
	local titleArr = {GetLocalizeStringBy("lic_1457"),GetLocalizeStringBy("lic_1458"),GetLocalizeStringBy("lic_1459"),GetLocalizeStringBy("lic_1460"),GetLocalizeStringBy("llp_515")}
	local colorArr = {ccc3(0x00,0xff,0x18),ccc3(0x00,0xe4,0xff),ccc3(0xe4,0x00,0xff),ccc3(0xff,0x8a,0x00),ccc3(0xff,0x00,0x00)}
	local titleFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1456",titleArr[p_fixIndex]) ,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleFont:setColor(colorArr[p_fixIndex])
	titleFont:setAnchorPoint(ccp(0.5,0))
	titleFont:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height))
	retSprite:addChild(titleFont)

	-- 该层的花费
	local costNum = GodWeaponFixData.getGodInheritCostBy(p_fixIndex)
	local goldSp = CCSprite:create("images/common/gold.png")
	goldSp:setAnchorPoint(ccp(0,0.5))
	goldSp:setPosition(ccp( 200,64))
	retSprite:addChild(goldSp)
	-- 金币数量
	local goldCostNumFont =  CCRenderLabel:create(costNum ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	goldCostNumFont:setColor(ccc3(0xff,0xf6,0x00))
	goldCostNumFont:setAnchorPoint(ccp(0,0.5))
	goldCostNumFont:setPosition(ccp(goldSp:getPositionX()+goldSp:getContentSize().width+10,goldSp:getPositionY()))
	retSprite:addChild(goldCostNumFont)

	-- 选择按钮
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_layer_priority-2)
    retSprite:addChild(menu,1,_chooseMenuTag)

    -- 创建传承选择按钮
	local chooseMenuItem = CCMenuItemImage:create("images/common/duigou_n.png","images/common/duigou_h.png")
	chooseMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	chooseMenuItem:setPosition(ccp(302,64))
	menu:addChild(chooseMenuItem,1,p_fixIndex)
	chooseMenuItem:registerScriptTapHandler(chooseMenuItemCallback)
	-- 是否选中
	local isIn = false
	for k,v in pairs(_chooseIndexArr) do
		if(v == p_fixIndex)then
			isIn = true
			break
		end
	end
	if(isIn)then
		-- 已选择
		chooseMenuItem:selected()
	end

	--箭头
	local arrow = CCSprite:create("images/common/arrow1.png")
    arrow:setAnchorPoint(ccp(0.5, 0.5))
    arrow:setPosition(ccp(254,20))
    retSprite:addChild(arrow)

	-- 左边源属性
	if( not table.isEmpty(_showItemInfo) )then 
		-- 接受传承的神兵是否有该层数
		local allNum = GodWeaponFixData.getGodWeapinFixNum(nil,_showItemId)
		if(p_fixIndex <= allNum)then
			-- 得到当前层属性
			local curIndexAttrId = GodWeaponFixData.getGodWeapinConfirmAttr( _showItemId, p_fixIndex )
			if(curIndexAttrId ~= nil)then
				local attrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById(curIndexAttrId)
				local attrColor =  GodWeaponFixData.getGodWeapinFixAttrColor( _showItemId, p_fixIndex, curIndexAttrId )
				local attrNameFont = CCRenderLabel:create(attrInfo.name,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				attrNameFont:setColor(attrColor)
				attrNameFont:setAnchorPoint(ccp(0,0.5))
				attrNameFont:setPosition(ccp(30,67))
				retSprite:addChild(attrNameFont)
				-- 星数
				local starFont = CCRenderLabel:create(attrInfo.star,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				starFont:setColor(attrColor)
				starFont:setAnchorPoint(ccp(0,0.5))
				starFont:setPosition(ccp(140,attrNameFont:getPositionY()))
				retSprite:addChild(starFont)
				-- 星星sp
				local starSprite = CCSprite:create("images/formation/star.png")
				starSprite:setAnchorPoint(ccp(0,0.5))
				starSprite:setPosition(ccp(starFont:getPositionX()+starFont:getContentSize().width,starFont:getPositionY()))
				retSprite:addChild(starSprite)

				local attrDesFont = CCRenderLabel:create(attrInfo.dis,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				attrDesFont:setColor(ccc3(0xff,0xff,0xff))
				attrDesFont:setAnchorPoint(ccp(0,0.5))
				attrDesFont:setPosition(ccp(30,33))
				retSprite:addChild(attrDesFont)
			else
				-- 暂无属性
				local tipFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1522"),g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				tipFont:setColor(ccc3(0xff,0xff,0xff))
				tipFont:setAnchorPoint(ccp(0,0.5))
				tipFont:setPosition(ccp(30,retSprite:getContentSize().height*0.5))
				retSprite:addChild(tipFont)
			end
		end
	end

	-- 右边源属性
	if( not table.isEmpty(_disItemInfo) )then 
		-- 接受传承的神兵是否有该层数
		local allNum = GodWeaponFixData.getGodWeapinFixNum(nil,_disItemId)
		if(p_fixIndex <= allNum)then
			-- 得到当前层属性
			local curIndexAttrId = GodWeaponFixData.getGodWeapinConfirmAttr( _disItemId, p_fixIndex )
			if(curIndexAttrId ~= nil)then
				local attrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById(curIndexAttrId)
				local attrColor =  GodWeaponFixData.getGodWeapinFixAttrColor( _disItemId, p_fixIndex, curIndexAttrId )
				local attrNameFont = CCRenderLabel:create(attrInfo.name,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				attrNameFont:setColor(attrColor)
				attrNameFont:setAnchorPoint(ccp(0,0.5))
				attrNameFont:setPosition(ccp(360,67))
				retSprite:addChild(attrNameFont)
				-- 星数
				local starFont = CCRenderLabel:create(attrInfo.star,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				starFont:setColor(attrColor)
				starFont:setAnchorPoint(ccp(0,0.5))
				starFont:setPosition(ccp(480,attrNameFont:getPositionY()))
				retSprite:addChild(starFont)
				-- 星星sp
				local starSprite = CCSprite:create("images/formation/star.png")
				starSprite:setAnchorPoint(ccp(0,0.5))
				starSprite:setPosition(ccp(starFont:getPositionX()+starFont:getContentSize().width,starFont:getPositionY()))
				retSprite:addChild(starSprite)

				local attrDesFont = CCRenderLabel:create(attrInfo.dis,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				attrDesFont:setColor(ccc3(0xff,0xff,0xff))
				attrDesFont:setAnchorPoint(ccp(0,0.5))
				attrDesFont:setPosition(ccp(360,33))
				retSprite:addChild(attrDesFont)
			else
				-- 暂无属性
				local tipFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1522"),g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
				tipFont:setColor(ccc3(0xff,0xff,0xff))
				tipFont:setAnchorPoint(ccp(0,0.5))
				tipFont:setPosition(ccp(360,retSprite:getContentSize().height*0.5))
				retSprite:addChild(tipFont)
			end
		end
	end

	return retCell
end

--[[
	@des 	: 创建上部分UI
	@param  : p_itemInfo 神兵信息
	@return : sprite
--]]
function createGodBodyUI( p_itemInfo )
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(182,312))

	-- 法阵
	local smallAnimSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/god_weapon/effect/shenbingjinjielan/shenbingjinjielan" ), -1,CCString:create(""))
    smallAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
    smallAnimSprite:setPosition(ccp(retSprite:getContentSize().width*0.5,85))
    retSprite:addChild(smallAnimSprite)
	
	--名称底
	local nameBgSprite = CCScale9Sprite:create("images/common/bg/bg2.png")
	nameBgSprite:setContentSize(CCSizeMake(200,45))
	nameBgSprite:setAnchorPoint(ccp(0.5,0))
	nameBgSprite:setPosition(ccp(retSprite:getContentSize().width*0.5,0))
	retSprite:addChild(nameBgSprite)

	--五行图片
	local fiveSprite = CCSprite:create("images/god_weapon/five/" .. _showItemInfo.itemDesc.type .. ".png")
	fiveSprite:setAnchorPoint(ccp(1,0.5))
	fiveSprite:setPosition(ccp(210,97))
	retSprite:addChild(fiveSprite,5)

	-- 按钮
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_layer_priority-2)
    smallAnimSprite:addChild(menu,10)
    
	local addSprite = ItemSprite.createLucencyAddSprite()
	local normalSp = CCSprite:create()
	normalSp:setContentSize(addSprite:getContentSize())
	local selectSp = CCSprite:create()
	selectSp:setContentSize(addSprite:getContentSize())
	local menuItem = CCMenuItemSprite:create(normalSp,selectSp)
	menuItem:setAnchorPoint(ccp(0.5,0.5))
	menuItem:setPosition(ccp(0,70))

	if(p_itemInfo ~= nil)then
		menu:addChild(menuItem,1,tonumber(p_itemInfo.item_id))
	else
		menu:addChild(menuItem,1,1)
	end

	-- 加号按钮
	addSprite:setAnchorPoint(ccp(0.5,0.5))
	addSprite:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5))
	menuItem:addChild(addSprite)
	addSprite:setVisible(false)

	-- 加号按钮事件
	menuItem:registerScriptTapHandler(addMenuItemCallBack)

	if(p_itemInfo ~= nil)then
		-- 全身像
		local godWeaponBodySprite = GodWeaponItemUtil.getWeaponBigSprite(nil,nil,nil,p_itemInfo)
		godWeaponBodySprite:setAnchorPoint(ccp(0.5,0))
		godWeaponBodySprite:setPosition(ccp(0,0))
		smallAnimSprite:addChild(godWeaponBodySprite,5)
		godWeaponBodySprite:setScale(0.6)


		--名字+阶数
		-- 强化神兵的品质,进阶次数，显示阶数
		local quality,evolveNum,evolveShowNum = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil,nil,p_itemInfo)
		local nameLabel = CCRenderLabel:create(p_itemInfo.itemDesc.name .. GetLocalizeStringBy("lic_1428",evolveShowNum) ,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(quality))
		nameLabel:setAnchorPoint(ccp(0.5,0.5))
		nameLabel:setPosition(ccp(nameBgSprite:getContentSize().width*0.5,nameBgSprite:getContentSize().height*0.5))
		nameBgSprite:addChild(nameLabel)
	else
		addSprite:setVisible(true)
	end

	return retSprite
end


--[[
	@des 	:创建上部分UI
--]]
function createTopUI()
	-- 神兵洗练标题
    local titleSp = CCSprite:create("images/god_weapon/inherit_title.png")
    titleSp:setAnchorPoint(ccp(0.5,1))
    titleSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-13*g_fElementScaleRatio ))
    _bgLayer:addChild(titleSp)
    titleSp:setScale(g_fElementScaleRatio)

    -- 左边神兵
    local srcGodSprite = createGodBodyUI( _showItemInfo )
    srcGodSprite:setAnchorPoint(ccp(0.5,0))
    srcGodSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.2,_bgLayer:getContentSize().height*0.61))
    _bgLayer:addChild(srcGodSprite)
    srcGodSprite:setScale(g_fElementScaleRatio)

    -- 右边神兵
    _disGodSprite = createGodBodyUI()
    _disGodSprite:setAnchorPoint(ccp(0.5,0))
    _disGodSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.8,_bgLayer:getContentSize().height*0.61))
    _bgLayer:addChild(_disGodSprite)
    _disGodSprite:setScale(g_fElementScaleRatio)

    -- 两个箭头
	local arrows1 = CCSprite:create("images/common/arrow1.png")
    arrows1:setAnchorPoint(ccp(0.5, 0.5))
    arrows1:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height*0.83))
    _bgLayer:addChild(arrows1)
    arrows1:setScale(g_fElementScaleRatio*1.2)

    local arrows2 = CCSprite:create("images/common/arrow1.png")
    arrows2:setAnchorPoint(ccp(0.5, 0.5))
    arrows2:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height*0.71))
    _bgLayer:addChild(arrows2)
    arrows2:setScale(g_fElementScaleRatio*1.2)
end

--[[
	@des 	:创建底部UI
--]]
function createBottomUI()
	-- 创建每一条洗练属性
	-- for i=1,4 do
	-- 	local attrSprite = createAttrUI(i)
	-- 	attrSprite:setAnchorPoint(ccp(0.5,0))
	-- 	attrSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*_attrSpritePosY[i]))
	-- 	_bgLayer:addChild(attrSprite)
	-- 	attrSprite:setScale(g_fElementScaleRatio)
	-- 	-- 保存
	-- 	table.insert(_fixIndexSpArr,attrSprite)
	-- end

	-- 列表
	local cellSize = CCSizeMake(588, 130)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = createAttrUI(a1+1)
			r = a2
		elseif fn == "numberOfCells" then
			r = 5
		else
		end
		return r
	end)

	_listTabelView = LuaTableView:createWithHandler(h, CCSizeMake(590, 460))
	_listTabelView:setBounceable(true)
	_listTabelView:setTouchPriority(_layer_priority-3)
	_listTabelView:ignoreAnchorPointForPosition(false)
	_listTabelView:setAnchorPoint(ccp(0.5,0.5))
	_listTabelView:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.35))
	_bgLayer:addChild(_listTabelView)
	-- 设置单元格升序排列
	_listTabelView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_listTabelView:setScale(g_fElementScaleRatio)

	-- 按钮
    local menuBar = CCMenu:create()
    menuBar:setAnchorPoint(ccp(0,0))
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_layer_priority-3)
    _bgLayer:addChild(menuBar)

	-- 创建返回按钮 
	local closeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(146, 73), GetLocalizeStringBy("lic_1512"),ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	closeMenuItem:setAnchorPoint(ccp(0.5, 0))
	closeMenuItem:setPosition(ccp( _bgLayer:getContentSize().width*0.25, 0 ))
	menuBar:addChild(closeMenuItem)
	closeMenuItem:registerScriptTapHandler(closeButtonCallback)
	closeMenuItem:setScale(g_fElementScaleRatio)

	-- 传承按钮
	local inheritMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(146, 73), GetLocalizeStringBy("lic_1521"),ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	inheritMenuItem:setAnchorPoint(ccp(0.5, 0))
	inheritMenuItem:setPosition(ccp( _bgLayer:getContentSize().width*0.75, 0 ))
	menuBar:addChild(inheritMenuItem)
	inheritMenuItem:registerScriptTapHandler(inheritMenuItemCallback)
	inheritMenuItem:setScale(g_fElementScaleRatio)

	-- 总花费
	local goldSp = CCSprite:create("images/common/gold.png")
	goldSp:setAnchorPoint(ccp(0,0.5))
	goldSp:setPosition(ccp( inheritMenuItem:getPositionX()+inheritMenuItem:getContentSize().width*0.5*g_fElementScaleRatio+5*g_fElementScaleRatio,30*g_fElementScaleRatio))
	_bgLayer:addChild(goldSp)
	goldSp:setScale(g_fElementScaleRatio)
	-- 金币数量
	_allCostNumFont =  CCRenderLabel:create(_allCostNum ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_allCostNumFont:setColor(ccc3(0xff,0xf6,0x00))
	_allCostNumFont:setAnchorPoint(ccp(0,0.5))
	_allCostNumFont:setPosition(ccp(goldSp:getPositionX()+goldSp:getContentSize().width*g_fElementScaleRatio+3*g_fElementScaleRatio,goldSp:getPositionY()))
	_bgLayer:addChild(_allCostNumFont)
	_allCostNumFont:setScale(g_fElementScaleRatio)
end

--[[
	@des 	:创建神兵洗练属性传承界面
	@param 	:p_item_id
	@return :
--]]
function createLayer( p_item_id  )
	-- 初始化变量
	init()

	-- 接收参数
	_showItemId = tonumber(p_item_id)

	-- 隐藏下排按钮
	MainScene.setMainSceneViewsVisible(false, false, false)

	_bgLayer = CCLayer:create()

    -- 大背景
    _bgSprite = CCSprite:create("images/god_weapon/evolve_bg.jpg")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)
	
    -- 初始化数据
    initData()

    -- 创建上部分UI
    createTopUI()

    -- 创建下部分UI
    createBottomUI()

    return _bgLayer
end

--[[
	@des 	:显示神兵洗练属性传承界面
	@param 	:p_item_id
	@return :
--]]
function showLayer( p_item_id  )
	local layer = createLayer( p_item_id )
	MainScene.changeLayer(layer, "GodWeaponFixLayer")
end


























































































