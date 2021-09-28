-- FileName: UseGiftLayer.lua 
-- Author: licong 
-- Date: 14-8-6 
-- Purpose: 使用后选择一个物品领取 


module("UseGiftLayer", package.seeall)

require "script/utils/BaseUI"
require "script/ui/item/ItemUtil"

local _bgLayer                  = nil
local _backGround 				= nil
local _second_bg  				= nil
local _giftInfo 				= nil
local _curMenuItem 				= nil
local _curMenuTag 				= nil
local _itemTab 					= nil
local _bgSize 					= nil
local _touchPriority            = -560
local _cbFunc                   = nil
local _curNumber 				= nil
local _maxLimitNum 				= nil
local _secondHeight 			= nil
local _numberLabel 				= nil
local _isNeedAdd 				= false

local _oneCallNum 				= 5 		-- 一次请求使用多少物品
local _limitNum 				= 50 		-- 批量使用限制最大次数
local _useGoodsNum 				= 0  		-- 已经使用的数量
local _isFirst 					= true 		-- 是否第一次发请求

function init( ... )
	_bgLayer                    = nil
	_backGround 				= nil
	_second_bg  				= nil
	_giftInfo 					= nil
	_curMenuItem 				= nil
	_curMenuTag 				= nil
	_itemTab 					= nil
	_bgSize 					= nil
	_cbFunc                     = nil
	_curNumber 					= 1
	_maxLimitNum 				= 1
	_secondHeight 				= 0
	_numberLabel 				= nil
	_isNeedAdd 					= false
	_useGoodsNum 				= 0  
	_isFirst 					= true
end

--[[
	@des 	:查看物品信息返回回调 为了显示上方和下方按钮
	@param 	:
	@return :
--]]
function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, true, true)
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
	@des 	:关闭面板  add by yangrui 15-11-13
	@param 	:
	@return :
--]]
function closeGiftLayer( ... )
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des 	:关闭按钮回调  modified by yangrui 15-11-13
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	closeGiftLayer()
end

--[[
	@des 	:选择按钮回调
	@param 	:
	@return :
--]]
function menuItemCallBack( tag, itemBtn )
 	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	itemBtn:selected()
	if(itemBtn ~= _curMenuItem) then
		if(tolua.cast(_curMenuItem,"CCMenuItemImage") ~= nil)then
			_curMenuItem:unselected()
		end
		_curMenuItem = itemBtn
		_curMenuTag = tag

		print("_curMenuTag == ",_curMenuTag)
	end
end

--[[
	@des 	:领取按钮回调
	@param 	:
	@return :
--]]
function yesCallBack( tag, itemBtn )
 	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(_curMenuTag == nil)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1197"))
	else
		-- 关闭
		closeGiftLayer()  -- modified by yangrui 15-11-13  因为点领取按钮后 音效重叠
		-- 使用回调
		if (_giftInfo) then
			-- 发请求
			sendService( _curNumber )
		else
			_cbFunc(_curMenuTag)
		end
	end
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
		if(dictData.err == "ok") then
			if(dictData.ret == "ok")then
				-- 已经使用次数
				_useGoodsNum = _useGoodsNum + sendNum
				-- 剩余请求次数
				sendServiceNum = sendServiceNum - sendNum
				-- 继续发
				sendService( sendServiceNum )
			end
		end
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
		-- local args = Network.argsHandler(_giftInfo.gid, _giftInfo.item_id, _curMenuTag-1, sendNum, mark)

		local args = CCArray:create()
		args:addObject(CCInteger:create(tonumber(_giftInfo.gid)))
		args:addObject(CCInteger:create(tonumber(_giftInfo.item_id)))
		args:addObject(CCInteger:create(_curMenuTag-1))
		args:addObject(CCInteger:create(sendNum))
		if(mark)then
			args:addObject(CCInteger:create(mark))
		end
		Network.rpc(useCallback, "bag.useGift" .. sendServiceNum , "bag.useGift", args, true)
	else
		-- 请求发完 显示获得的物品
		local itemDataTab = {}
		_itemTab[_curMenuTag].num = _itemTab[_curMenuTag].num * _useGoodsNum
		table.insert(itemDataTab,_itemTab[_curMenuTag])
		-- 展示
		require "script/ui/item/ReceiveReward"
		ReceiveReward.showRewardWindow( itemDataTab, showDownMenu, 1000 )
		-- 修改本地数据
		ItemUtil.addRewardByTable(itemDataTab)
	end
end

--[[
	@des 	:选择数量
	@param 	:p_data cell数据, p_index 第几次召唤
	@return :
--]]
function changeNumberAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(_curMenuTag == nil)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1197"))
		return
	end

	print("tag 的值:")
	print(tag)
	if(tag == 10001) then
		-- -10
		_curNumber = _curNumber - 10
	elseif(tag == 10002) then
		-- -1
		_curNumber = _curNumber - 1 
	elseif(tag == 10003) then
		-- +1
		_curNumber = _curNumber + 1 
	elseif(tag == 10004) then
		-- +10
		_curNumber = _curNumber + 10 
	end
	-- 限购次数
	if(_curNumber<=0)then
		_curNumber = 1
	end
	if(_curNumber > _maxLimitNum) then
		_curNumber = _maxLimitNum
	end
	print("_curNumber", _curNumber)

	-- 个数
	_numberLabel:setString(_curNumber)
end

--[[
	@des 	:创建展示tableView的cell
	@param 	:p_data cell数据, p_index 第几个
	@return :
--]]
function createCell( p_data, p_index )
	print("p_data p_index",p_index)
	print_t(p_data)
	local iconSprite = ItemUtil.createGoodsIcon(p_data, _touchPriority, 1000, _touchPriority, showDownMenu ,true)

	local menu = CCMenu:create()
	menu:setTouchPriority(_touchPriority)
	menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	iconSprite:addChild(menu,1,10)

	local menuItem = CCMenuItemImage:create("images/common/btn/radio_normal.png","images/common/btn/radio_selected.png")
	menuItem:setAnchorPoint(ccp(0.5, 1))
	menuItem:setPosition(ccp(iconSprite:getContentSize().width*0.5, -27))
	menu:addChild(menuItem, 1, tonumber(p_index))
	menuItem:registerScriptTapHandler(menuItemCallBack)

	return iconSprite
end

--[[
	@des 	:创建展示tableView
	@param 	:
	@return :
--]]
function createTableView( ... )
	local cellSize = CCSizeMake(550, 190)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.14,0.38,0.62,0.86}
			for i=1,4 do
				if(_itemTab[a1*4+i] ~= nil)then
					local item_sprite = createCell(_itemTab[a1*4+i],a1*4+i)
					item_sprite:setAnchorPoint(ccp(0.5,1))
					item_sprite:setPosition(ccp(550*posArrX[i],180))
					a2:addChild(item_sprite)
					if(a1*4+i == _curMenuTag)then
						tolua.cast(item_sprite:getChildByTag(10):getChildByTag(_curMenuTag),"CCMenuItemImage"):selected()
						_curMenuItem = item_sprite:getChildByTag(10):getChildByTag(_curMenuTag)
					end
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #_itemTab
			r = math.ceil(num/4)
		else
		end
		return r
	end)

	local tableView = LuaTableView:createWithHandler(h, CCSizeMake(550, _secondHeight-10))
	tableView:setBounceable(true)
	tableView:setTouchPriority(_touchPriority)
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setAnchorPoint(ccp(0.5,0.5))
	tableView:setPosition(ccp(_second_bg:getContentSize().width*0.5,_second_bg:getContentSize().height*0.5))
	_second_bg:addChild(tableView)
	-- 设置单元格升序排列
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableView:setTouchEnabled(false)
end


--[[
	@des 	:创建提示框
	@param 	:
	@return :
--]]
function createTipLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,_touchPriority,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(_bgSize)
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1194"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(_touchPriority)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

 	-- 提示
	local fontTip = CCLabelTTF:create(GetLocalizeStringBy("lic_1196"), g_sFontPangWa, 25)
    fontTip:setAnchorPoint(ccp(0.5,1))
    fontTip:setColor(ccc3(0x78, 0x25, 0x00))
    fontTip:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-56))
    _backGround:addChild(fontTip)

	-- 二级背景
	_second_bg = BaseUI.createContentBg(CCSizeMake(556,_secondHeight))
 	_second_bg:setAnchorPoint(ccp(0.5,1))
 	_second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-98))
 	_backGround:addChild(_second_bg)

    -- 确定按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn1_d.png")
    normalSprite:setContentSize(CCSizeMake(198,73))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    selectSprite:setContentSize(CCSizeMake(198,73))
    local yesMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    yesMenuItem:setAnchorPoint(ccp(0.5,0))
    yesMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.5, 35))
    yesMenuItem:registerScriptTapHandler(yesCallBack)
    menu:addChild(yesMenuItem)
    local  itemfont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1195"), g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
    itemfont1:setAnchorPoint(ccp(0.5,0.5))
    itemfont1:setColor(ccc3(0xfe,0xdb,0x1c))
    itemfont1:setPosition(ccp(yesMenuItem:getContentSize().width*0.5,yesMenuItem:getContentSize().height*0.5))
    yesMenuItem:addChild(itemfont1)

    -- 创建tableView
    createTableView()

    if(_isNeedAdd)then
	    -- 提示2
		local fontTip = CCLabelTTF:create(GetLocalizeStringBy("lic_1762"), g_sFontPangWa, 25)
	    fontTip:setAnchorPoint(ccp(0.5,1))
	    fontTip:setColor(ccc3(0x78, 0x25, 0x00))
	    fontTip:setPosition(ccp(_backGround:getContentSize().width*0.5,_second_bg:getPositionY()-_second_bg:getContentSize().height-10))
	    _backGround:addChild(fontTip)

		---- 加减道具的按钮
		local changeNumBar = CCMenu:create()
		changeNumBar:setPosition(ccp(0,0))
		changeNumBar:setTouchPriority(_touchPriority)
		_backGround:addChild(changeNumBar)

		-- -10
		local posY = fontTip:getPositionY()-fontTip:getContentSize().height-50
		local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce10_n.png", "images/shop/prop/btn_reduce10_h.png")
		reduce10Btn:setAnchorPoint(ccp(0,0.5))
		reduce10Btn:setPosition(ccp(50, posY))
		reduce10Btn:registerScriptTapHandler(changeNumberAction)
		changeNumBar:addChild(reduce10Btn, 1, 10001)

		-- -1
		local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
		reduce1Btn:setAnchorPoint(ccp(0,0.5))
		reduce1Btn:setPosition(ccp(170, posY))
		reduce1Btn:registerScriptTapHandler(changeNumberAction)
		changeNumBar:addChild(reduce1Btn, 1, 10002)

		-- 数量背景
		local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
		numberBg:setContentSize(CCSizeMake(100, 65))
		numberBg:setAnchorPoint(ccp(0.5, 0.5))
		numberBg:setPosition(ccp(_backGround:getContentSize().width*0.5, posY))
		_backGround:addChild(numberBg)
		-- 数量数字
		_numberLabel = CCRenderLabel:create("1", g_sFontPangWa, 36, 1, ccc3(0x49, 0x00, 0x00), type_stroke)
		_numberLabel:setAnchorPoint(ccp(0.5,0.5))
	    _numberLabel:setColor(ccc3(0xff, 0xff, 0xff))
	    _numberLabel:setPosition(ccp(numberBg:getContentSize().width*0.5,numberBg:getContentSize().height*0.5))
	    numberBg:addChild(_numberLabel)

		-- +1
		local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png", "images/shop/prop/btn_addition_h.png")
		reduce1Btn:setAnchorPoint(ccp(1,0.5))
		reduce1Btn:setPosition(ccp(_backGround:getContentSize().width-170, posY))
		reduce1Btn:registerScriptTapHandler(changeNumberAction)
		changeNumBar:addChild(reduce1Btn, 1, 10003)

		-- +10
		local reduce10Btn = CCMenuItemImage:create("images/shop/prop/btn_addition10_n.png", "images/shop/prop/btn_addition10_h.png")
		reduce10Btn:setAnchorPoint(ccp(1,0.5))
		reduce10Btn:setPosition(ccp(_backGround:getContentSize().width-50, posY))
		reduce10Btn:registerScriptTapHandler(changeNumberAction)
		changeNumBar:addChild(reduce10Btn, 1, 10004)   
	end 
end


--[[
	@des 	:名将好感交换成功后提示框
	@param 	:p_giftInfo 使用的礼包信息, p_isNeedAdd 是否需要加号
	@return :
--]]
function showTipLayer( p_giftInfo,rewardData,callBackFunc, p_isNeedAdd )
	-- 初始化
	init()
	
	-- gid
	_giftInfo = p_giftInfo
	_maxLimitNum = _giftInfo and tonumber(_giftInfo.item_num) or 1
	if( _maxLimitNum > _limitNum )then
		_maxLimitNum = _limitNum
	end

	_isNeedAdd = p_isNeedAdd or false

	print("_giftInfo==>","_maxLimitNum",_maxLimitNum,"_isNeedAdd",_isNeedAdd)
	print_t(_giftInfo)
	-- 兼容欢乐签到单选
	if not(rewardData) then
		_itemTab = ItemUtil.getItemsDataByStr(_giftInfo.itemDesc.choose_items)
	else
		_itemTab = ItemUtil.getItemsDataByStr(rewardData)
		_cbFunc = callBackFunc
	end

	if( table.count(_itemTab) <= 4 )then
		if(_isNeedAdd)then
			_bgSize = CCSizeMake(605, 550)
			_secondHeight = _bgSize.height - 350
		else
			_bgSize = CCSizeMake(605, 400)
			_secondHeight = _bgSize.height - 208
		end
	elseif(  table.count(_itemTab) > 4 and table.count(_itemTab) <= 8 )then
		if(_isNeedAdd)then
			_bgSize = CCSizeMake(605, 750)
			_secondHeight = _bgSize.height - 350
		else
			_bgSize = CCSizeMake(605, 600)
			_secondHeight = _bgSize.height - 208
		end
	else
		if(_isNeedAdd)then
			_bgSize = CCSizeMake(605, 920)
			_secondHeight = _bgSize.height - 350
		else
			_bgSize = CCSizeMake(605, 780)
			_secondHeight = _bgSize.height - 208
		end
	end

	-- 创建ui
	createTipLayer()
end





































