-- FileName: ShowFiftyHuntDialog.lua 
-- Author: licong 
-- Date: 14-10-10 
-- Purpose: 猎魂50次展示框


module("ShowFiftyHuntDialog", package.seeall)

local _bgLayer                  	= nil
local _backGround 					= nil
local _second_bg  					= nil
local _three_bg 					= nil

local _showItems 					= nil
local _whiteNum						= nil
local _greenNum						= nil
local _blueNum						= nil
local _purpleNum					= nil
local _allExpNum 					= nil
local _addExpFonutNum 				= nil
local _costCoin 					= nil
function init( ... )
	_bgLayer                    	= nil
	_backGround 					= nil
	_second_bg  					= nil
	_three_bg 						= nil

	_showItems 						= nil
	_whiteNum						= nil
	_greenNum						= nil
	_blueNum						= nil
	_purpleNum						= nil
	_addExpFonutNum 				= nil
	_allExpNum 						= nil
	_costCoin 						= nil
end


--[[
	@des 	:关闭提示框
	@param 	:
	@return :
--]]
function closeTipLayer()
    if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
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

	-- -- 显示快速猎魂
	-- require "script/ui/huntSoul/QuickHuntDialog"
	-- QuickHuntDialog.showTip()
end

--[[
	@des 	:再猎50次按钮回调
	@param 	:
	@return :
--]]
function zaiMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end

	-- 猎50次回调
	require "script/ui/huntSoul/SearchSoulLayer"
	SearchSoulLayer.fiftyHuntCallFun()
end


-- 创建物品图标
function createCell( cellValues )
	-- 物品
	local iconBg =  ItemSprite.getItemSpriteByItemId( tonumber(cellValues.item_template_id), 0, true) -- ItemSprite.getItemSpriteById(tonumber(cellValues.item_template_id), tonumber(cellValues.item_id),nil, nil, -422,11112,nil,nil,nil,nil,nil,nil,nil,nil,true,nil,nil)
	local itemData = ItemUtil.getItemById(tonumber(cellValues.item_template_id))
    local iconName = itemData.name
   	local nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	--- desc 物品名字
	local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	descLabel:setColor(nameColor)
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.2))
	iconBg:addChild(descLabel)

	-- 是经验战魂显示具体的经验值
	if(tonumber(cellValues.item_template_id) == 72004)then
		-- 经验战魂
		local numFont = CCLabelTTF:create(_allExpNum , g_sFontName, 18)
   	 	numFont:setColor(ccc3(0x00,0x00,0x00))
   	 	numFont:setAnchorPoint(ccp(0.5,0.5))
   	 	numFont:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
   	 	iconBg:addChild(numFont,100)
	end

	-- 材料
	if( cellValues.isMaterial )then 
		descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.31))
		-- 物品数量
		if( cellValues.num > 1 )then
			local numberLabel =  CCRenderLabel:create(cellValues.num , g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
			numberLabel:setColor(ccc3(0x00,0xff,0x18))
			numberLabel:setAnchorPoint(ccp(1,0))
			local width = iconBg:getContentSize().width - 10
			numberLabel:setPosition(ccp(width,5))
			iconBg:addChild(numberLabel)
		end
	end

	return iconBg
end

--[[
	@des 	:创建展示tableView
	@param 	:
	@return :
--]]
function createTableView( ... )
	local cellSize = CCSizeMake(495, 140)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			a2 = CCTableViewCell:create()
			local posArrX = {0.13,0.37,0.62,0.87}
			for i=1,4 do
				if(_showItems[a1*4+i] ~= nil)then
					local item_sprite = createCell(_showItems[a1*4+i])
					item_sprite:setAnchorPoint(ccp(0.5,1))
					item_sprite:setPosition(ccp(495*posArrX[i],130))
					a2:addChild(item_sprite)
				end
			end
			r = a2
		elseif fn == "numberOfCells" then
			local num = #_showItems
			r = math.ceil(num/4)
			print("num is : ", num)
		else
		end
		return r
	end)

	local tableView = LuaTableView:createWithHandler(h, CCSizeMake(495, 260))
	tableView:setBounceable(true)
	tableView:setTouchPriority(-423)
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setAnchorPoint(ccp(0.5,0.5))
	tableView:setPosition(ccp(_second_bg:getContentSize().width*0.5,_second_bg:getContentSize().height*0.5))
	_second_bg:addChild(tableView)
	-- 设置单元格升序排列
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
end

--[[
	@des 	:创建提示框
	@param 	:
	@return :
--]]
function createTipLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,-420,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(550, 624))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-421)
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
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1255"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 提示1
	local fontTip = CCLabelTTF:create(GetLocalizeStringBy("lic_1256"), g_sFontPangWa, 23)
    fontTip:setAnchorPoint(ccp(0.5,1))
    fontTip:setColor(ccc3(0x78, 0x25, 0x00))
    fontTip:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-45))
    _backGround:addChild(fontTip)

	-- 二级背景
	_second_bg = BaseUI.createContentBg(CCSizeMake(495,270))
 	_second_bg:setAnchorPoint(ccp(0.5,1))
 	_second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-85))
 	_backGround:addChild(_second_bg)
	
 	-- 获得战魂个数背景
 	_three_bg = CCScale9Sprite:create("images/common/s9_6.png")
 	_three_bg:setContentSize(CCSizeMake(495,130))
 	_three_bg:setAnchorPoint(ccp(0.5,1))
 	_three_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,_second_bg:getPositionY()-_second_bg:getContentSize().height-10))
 	_backGround:addChild(_three_bg)
	
	local desArr = {GetLocalizeStringBy("lic_1270"),GetLocalizeStringBy("lic_1274"),GetLocalizeStringBy("lic_1275"),GetLocalizeStringBy("lic_1276"),GetLocalizeStringBy("lic_1277"),GetLocalizeStringBy("lic_1278")}
	local desColorArr = {ccc3(0xe4, 0x00, 0xff), ccc3(0x00, 0xe4, 0xff), ccc3(0x00, 0xff, 0x18), ccc3(0xff, 0xff, 0xff), ccc3(0xff, 0xff, 0xff),ccc3(0xff, 0xff, 0xff)}
	local posX = {0.25,0.75,0.25,0.75,0.5,0.5}
	local posY = {0.615,0.615,0.385,0.385,0.155,0.845} 
	-- 获得的值
	local desNum = {_purpleNum, _blueNum, _greenNum, _whiteNum, _addExpFonutNum,_costCoin}
	for i=1, #desArr do
		local font = CCRenderLabel:create(desArr[i] .. " " .. desNum[i] , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
   	 	font:setColor(desColorArr[i])
   	 	font:setAnchorPoint(ccp(0.5,0.5))
   	 	font:setPosition(ccp(_three_bg:getContentSize().width*posX[i],_three_bg:getContentSize().height*posY[i]))
   	 	_three_bg:addChild(font)
	end

	-- 提示2
	local fontArr = {}
	fontArr[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1257"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontArr[1]:setColor(ccc3(0x00, 0xff, 0x18))

    fontArr[2] = CCRenderLabel:create(GetLocalizeStringBy("lic_1268"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontArr[2]:setColor(ccc3(0xff, 0xff, 0xff))

    fontArr[3] = CCRenderLabel:create(GetLocalizeStringBy("lic_1269"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontArr[3]:setColor(ccc3(0x00, 0xff, 0x18))

    local fontTip = BaseUI.createHorizontalNode(fontArr)
    fontTip:setAnchorPoint(ccp(0.5, 1))
	fontTip:setPosition(ccp(_backGround:getContentSize().width*0.5,_three_bg:getPositionY()-_three_bg:getContentSize().height-13))
    _backGround:addChild(fontTip)

	-- 确定按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn1_d.png")
    normalSprite:setContentSize(CCSizeMake(160,64))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    selectSprite:setContentSize(CCSizeMake(160,64))
    local yesMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    yesMenuItem:setAnchorPoint(ccp(0.5,0))
    yesMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.3, 20))
    yesMenuItem:registerScriptTapHandler(closeButtonCallback)
    menu:addChild(yesMenuItem)
    local  itemfont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1097"), g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
    itemfont1:setAnchorPoint(ccp(0.5,0.5))
    itemfont1:setColor(ccc3(0xfe,0xdb,0x1c))
    itemfont1:setPosition(ccp(yesMenuItem:getContentSize().width*0.5,yesMenuItem:getContentSize().height*0.5))
    yesMenuItem:addChild(itemfont1)

   -- 在猎魂50次按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn1_d.png")
    normalSprite:setContentSize(CCSizeMake(190,64))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    selectSprite:setContentSize(CCSizeMake(190,64))
    local zaiMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    zaiMenuItem:setAnchorPoint(ccp(0.5,0))
    zaiMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.7, 20))
    zaiMenuItem:registerScriptTapHandler(zaiMenuItemCallback)
    menu:addChild(zaiMenuItem)
    local  itemfont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1289"), g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
    itemfont1:setAnchorPoint(ccp(0.5,0.5))
    itemfont1:setColor(ccc3(0xfe,0xdb,0x1c))
    itemfont1:setPosition(ccp(zaiMenuItem:getContentSize().width*0.5,zaiMenuItem:getContentSize().height*0.5))
    zaiMenuItem:addChild(itemfont1)

    -- 创建列表
    createTableView()
end


--[[
	@des 	:猎魂五十次获得的战魂提示框
	@param 	:p_items 获得的所有战魂,p_whiteNum, p_greenNum, p_blueNum, p_purpleNum:获得的白、绿、蓝、紫战魂个数, p_material:材料
	@return :
--]]
function showTip( p_items, p_whiteNum, p_greenNum, p_blueNum, p_purpleNum, p_exp, p_costCoin, p_material )
	-- 初始化
	init()
	
	-- 猎魂五十次结果
	_showItems = HuntSoulData.getDataForHuntFiftyTip(p_items)
	print("_showItems")
	print_t(_showItems)
	
	_whiteNum = p_whiteNum
	_greenNum = p_greenNum
	_blueNum = p_blueNum
	_purpleNum = p_purpleNum
	_allExpNum = p_exp
	_costCoin = p_costCoin
	_addExpFonutNum = "+0"
	-- 获得的经验
	for k,v in pairs(_showItems) do
		if( tonumber(v.item_template_id) == 72004)then
			-- 经验战魂
			local itemData = ItemUtil.getItemById(v.item_template_id)
			-- print("itemData .. ")
			-- print_t(itemData)
			_allExpNum = tonumber(_allExpNum) + tonumber(itemData.baseExp)
			_addExpFonutNum = "+" .. _allExpNum
			break
		end
	end

	-- 添加材料
	if( not table.isEmpty( p_material ) )then 
		for k,v in pairs(p_material) do
			local tab = {}
			tab.item_template_id = k
			tab.num = tonumber(v)
			tab.isMaterial = true
			table.insert(_showItems,tab)
		end
	end

	-- 创建提示layer
	createTipLayer()
end




























