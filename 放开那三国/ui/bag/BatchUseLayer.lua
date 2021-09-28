-- FileName: BatchUseLayer.lua 
-- Author: licong 
-- Date: 14-5-13 
-- Purpose: function description of module 


module("BatchUseLayer", package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemUtil"
require "script/utils/ItemDropUtil"
require "script/ui/item/ReceiveReward"
require "script/ui/bag/UseItemLayer"

------------------- 模块常量 --------------
local kConfirmTag 		= 1001
local kCancelTag		= 1002
local kAddOneTag		= 10001
local kAddTenTag 		= 10002
local kSubOneTag		= 10003
local kSubTenTag		= 10004
local _oneCallNum 		= 5 		-- 一次请求使用多少物品
local limitNum 			= 5000 		-- 批量使用限制最大次数

------------------- 模块变量 ---------------
local _bglayer 			= nil				
local _layerBg			= nil
local _numberLabel 		= nil
local _itemData 		= nil				
local _curNumber 		= 1
local _maxUseNum 		= 1
local _itemsTable 		= {} 		-- 获得物品列表
local _useGoodsNum 		= 0  		-- 直接使用类物品 使用个数 如 体力丹，耐力丹，金币，银币  item_type == 3的
local _isFirst 			= true 		-- 是否第一次发请求

-- 初始化
local function init( )
	_bglayer 			= nil
	_itemData 			= nil
	_layerBg			= nil
	_numberLabel 		= nil
	_curNumber 			= 1
	_maxUseNum 			= 1
	_itemsTable 		= {} 
	_useGoodsNum 		= 0  
	_isFirst 			= true 
end


-- 查看物品信息返回回调 为了显示下排按钮
local function showUpDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, true, true)
end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	return true
end

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bglayer:registerScriptTouchHandler(onTouchesHandler, false, -431, true)
		_bglayer:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bglayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
local function closeAction()
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bglayer)then
		_bglayer:removeFromParentAndCleanup(true)
		_bglayer = nil
	end
end

--[[
 @desc	 返回合并后的item table
 @para 	 p_itemTab 物品table
 @return table
 --]]
function mergeItems( p_itemTab )
	local retTab = {}
	for o_k,o_v in pairs(p_itemTab) do
		local isIn = false
		for n_k,n_v in pairs(retTab) do
			if(n_v.tid == o_v.tid)then
				isIn = true
				retTab[n_k].num = n_v.num + o_v.num
			end
		end
		if(isIn == false)then
			table.insert(retTab,o_v)
		end
	end
	return retTab
end

-- 发请求
function sendService( needSendNum )
	-- 需要请求次数
	local sendServiceNum = needSendNum
	local sendNum = _oneCallNum
	if(sendServiceNum >0 and sendServiceNum < _oneCallNum)then
		sendNum = sendServiceNum
	end

	-- 使用回调
	local function useCallback( cbFlag, dictData, bRet )

		if(dictData.err == "ok" and (not table.isEmpty(dictData.ret)) ) then
			-- 返回数据
			if( not table.isEmpty(dictData.ret.drop) )then
				local itemDataTab = ItemDropUtil.getDropItem(dictData.ret.drop)
				for k,v in pairs(itemDataTab) do
					table.insert(_itemsTable,v)
				end
			else
				-- 加宠物数据
				if( tonumber(_itemData.item_template_id) >= 13001 and tonumber(_itemData.item_template_id) <= 14000 and DataCache.getSwitchNodeState(ksSwitchPet))then
					-- 使用的是宠物蛋
					require "script/ui/pet/PetData"
					if( not table.isEmpty(dictData.ret.pet) )then
						for k,v in pairs(dictData.ret.pet) do
							PetData.addPetInfo(v)
						end
					end
				end
				-- 使用次数
				_useGoodsNum = _useGoodsNum + sendNum
			end
			-- 剩余请求次数
			sendServiceNum = sendServiceNum - sendNum
		else
			-- 请求出错 剩余请求次数为0
			sendServiceNum = 0
		end
		-- 递归
		sendService( sendServiceNum )
	end

	if(sendServiceNum > 0)then
		local mark = nil
		if(_isFirst)then
			-- 第一次请求标识 传给后端
			mark = 1
			_isFirst = false
		else
			mark = nil
		end
		local args = Network.argsHandler(_itemData.gid, _itemData.item_id, sendNum, mark)
		RequestCenter.bag_useItem(useCallback, args, "bag.useItem" .. sendServiceNum )
	else
		-- 请求发完 显示获得的物品
		if( not table.isEmpty(_itemsTable) )then
			print("_itemsTable:30701")
			print_t(_itemsTable)
			local itemsTable = nil
			-- 铸造材料包 特殊处理 合并材料 by 2014.9.18
			if(tonumber(_itemData.item_template_id) == 30701)then
				itemsTable = mergeItems(_itemsTable)
			else
				itemsTable = _itemsTable
			end
			-- 展示
    		ReceiveReward.showRewardWindow( itemsTable, showUpDownMenu, 1000 )
    		-- 修改本地数据
    		ItemUtil.addRewardByTable(_itemsTable)
		else
			if(_itemData.itemDesc.award_item_id ~= nil) then
				-- 使用的得到奖励的物品
				local itemDataTab = UseItemLayer.getGiftInfo(_itemData.item_template_id,_useGoodsNum)
				-- 展示
	    		ReceiveReward.showRewardWindow( itemDataTab, showUpDownMenu, 1000 )
	    		-- 修改本地数据
	    		ItemUtil.addRewardByTable(itemDataTab)
			else
				-- 使用获得物品本身
				local useResult = ItemUtil.getUseResultBy( _itemData.item_template_id, _useGoodsNum, true)
				AnimationTip.showTip(  GetLocalizeStringBy("key_3311") ..  useResult.result_text )
				-- 使用道具获得金币和VIP经验 add by yangrui at 16-01-06
				BagUtil.userProductGoldAndVipExpItem(_itemData,_useGoodsNum)
			end
		end
	end
end


-- 按钮响应
function useAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 4星将魂包 和 5星将魂包 不做判断
	if(_itemData.itemDesc.item_type == 8 and _itemData.itemDesc.id ~= 30021 and _itemData.itemDesc.id ~= 30022) then
		-- 5星武将包
		if(_itemData.itemDesc.id == 30201)then
            if HeroPublicUI.showHeroIsLimitedUI() then
                return
            end
		elseif(ItemUtil.isBagFull() == true)then
			return
		end
	end
	-- 使用宠物蛋限制
	if(_itemData.itemDesc.item_type == 3)then
		if( tonumber(_itemData.item_template_id) >= 13001 and tonumber(_itemData.item_template_id) <= 14000 )then
			-- 功能节点未开启
			if not DataCache.getSwitchNodeState(ksSwitchPet) then
				return
			end
			-- 宠物背包满了
			require "script/ui/pet/PetUtil"
			if PetUtil.isPetBagFull() == true then
				return
			end
		end
	end
	-- 按钮事件
	if(tag == kConfirmTag) then
		-- 关闭自己
		closeAction()
		-- 发请求
		sendService( _curNumber )
	else
		closeAction()
	end
end

-- 改变兑换数量
function changeNumberAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == kSubTenTag) then
		-- -10
		_curNumber = _curNumber - 10
	elseif(tag == kSubOneTag) then
		-- -1
		_curNumber = _curNumber - 1 
	elseif(tag == kAddOneTag) then
		-- +1
		_curNumber = _curNumber + 1 
	elseif(tag == kAddTenTag) then
		-- +10
		_curNumber = _curNumber + 50 
	end
	if(_curNumber < 1)then
		_curNumber = 1
	end
	-- 上限
	if(_maxUseNum > limitNum)then
		if(_curNumber > limitNum)then
			_curNumber = limitNum
		end
	else
		if(_curNumber > _maxUseNum)then
			_curNumber = _maxUseNum
		end
	end
	-- 个数
	_numberLabel:setString(_curNumber)
	_numberLabel:setPosition(ccp( (170 - _numberLabel:getContentSize().width)/2, (65 + _numberLabel:getContentSize().height)/2) )

end

-- create 背景2
local function createInnerBg()
	-- 背景2
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(560, 330))
	innerBgSp:setAnchorPoint(ccp(0.5, 0))
	innerBgSp:setPosition(ccp(_layerBg:getContentSize().width*0.5, 110))
	_layerBg:addChild(innerBgSp)

	local innerSize = innerBgSp:getContentSize()
---- 准备数据
	-- 物品名字
	local itemName = _itemData.itemDesc.name

	-- 一共拥有
	local totalLael = CCRenderLabel:create(GetLocalizeStringBy("key_3204") .. _maxUseNum .. GetLocalizeStringBy("key_2557"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    totalLael:setColor(ccc3(0xff, 0xff, 0xff))
    totalLael:setPosition(ccp( (innerSize.width-totalLael:getContentSize().width)/2, 295) )
    innerBgSp:addChild(totalLael)

    -- 兑换提示
    local buyTipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("key_3181"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_1:setColor(ccc3(0xff, 0xff, 0xff))
    innerBgSp:addChild(buyTipLabel_1)

    -- 物品名称
    local nameLabel = CCRenderLabel:create(itemName, g_sFontPangWa, 30, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    nameLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    nameLabel:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2, 250) )
    innerBgSp:addChild(nameLabel)
    buyTipLabel_1:setPosition(ccp( (innerSize.width-nameLabel:getContentSize().width)/2 -buyTipLabel_1:getContentSize().width , 240) )

    -- 兑换提示2
    local buyTipLabel_2 = CCRenderLabel:create(GetLocalizeStringBy("key_2518"), g_sFontName, 24, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    buyTipLabel_2:setColor(ccc3(0xff, 0xff, 0xff))
    buyTipLabel_2:setPosition(ccp( innerSize.width/2 + nameLabel:getContentSize().width/2, 240) )
    innerBgSp:addChild(buyTipLabel_2)

---- 加减道具的按钮
	local changeNumBar = CCMenu:create()
	changeNumBar:setPosition(ccp(0,0))
	changeNumBar:setTouchPriority(-432)
	innerBgSp:addChild(changeNumBar)

	-- -10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png", "images/shop/prop/btn_reduce10_h.png")
	reduce10Btn:setPosition(ccp(4, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, kSubTenTag)

	-- -1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
	reduce1Btn:setPosition(ccp(123, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, kSubOneTag)

	-- 数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170, 65))
	numberBg:setAnchorPoint(ccp(0.5, 0))
	numberBg:setPosition(ccp(innerBgSp:getContentSize().width*0.5, 110))
	innerBgSp:addChild(numberBg)
	-- 数量数字
	_numberLabel = CCRenderLabel:create("1", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    _numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
    _numberLabel:setPosition(ccp( (numberBg:getContentSize().width - _numberLabel:getContentSize().width)/2, (numberBg:getContentSize().height + _numberLabel:getContentSize().height)/2) )
    numberBg:addChild(_numberLabel)

	-- +1
	local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png", "images/shop/prop/btn_addition_h.png")
	reduce1Btn:setPosition(ccp(370, 110))
	reduce1Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce1Btn, 1, kAddOneTag)

	-- +10
	local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png", "images/shop/prop/btn_addition10_h.png")
	reduce10Btn:setPosition(ccp(445, 110))
	reduce10Btn:registerScriptTapHandler(changeNumberAction)
	changeNumBar:addChild(reduce10Btn, 1, kAddTenTag)

	-- 提示
	local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1004"), g_sFontName, 35, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
    tipLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
    tipLabel:setAnchorPoint(ccp(0.5,0))
    tipLabel:setPosition(ccp(innerBgSp:getContentSize().width*0.5, 32))
    innerBgSp:addChild(tipLabel)

end

local function initBatchUseLayer( )
	_bglayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bglayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bglayer, 1000)
	-- 背景
	_layerBg = CCScale9Sprite:create("images/formation/changeformation/bg.png")
	_layerBg:setContentSize(CCSizeMake(610, 490))
	_layerBg:setAnchorPoint(ccp(0.5, 0.5))
	_layerBg:setPosition(ccp(_bglayer:getContentSize().width*0.5, _bglayer:getContentSize().height*0.5))
	_bglayer:addChild(_layerBg)
	_layerBg:setScale(g_fScaleX)	

	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(_layerBg:getContentSize().width/2, _layerBg:getContentSize().height*0.985))
	_layerBg:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1910"), g_sFontPangWa, 30)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

	-- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	_layerBg:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-432)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(_layerBg:getContentSize().width*0.97, _layerBg:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)

	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-432)
	_layerBg:addChild(menuBar)

	-- 按钮
	local comfirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	comfirmBtn:setAnchorPoint(ccp(0, 0))
	comfirmBtn:setPosition(ccp(125, 35	))
	comfirmBtn:registerScriptTapHandler(useAction)
	menuBar:addChild(comfirmBtn, 1, kConfirmTag)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(140, 70), GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0, 0))
	cancelBtn:setPosition(ccp(350, 35))
	cancelBtn:registerScriptTapHandler(useAction)
	menuBar:addChild(cancelBtn, 1, kCancelTag)

	-- 创建二级背景
	createInnerBg()
end 


-- 参数
-- itemData  物品详细数据包括服务器和配置表数据
-- useNum 	 最大能使用的个数
function showBatchUseLayer( itemData, useNum)
	init()
	-- 使用的物品数据
	_itemData = itemData
	-- 可使用的个数
	_maxUseNum = tonumber(useNum)
	-- 创建背景
	initBatchUseLayer()
end


