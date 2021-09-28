-- Filename：	GrowthFundLayer.lua
-- Author：		zhz
-- Date：		2013-9-29
-- Purpose：		成长基金

module("GrowthFundLayer", package.seeall)

require "script/ui/shop/RechargeLayer"
require "script/ui/shop/GiftsPakLayer"
require "script/ui/rechargeActive/GrowthFundCell"
require "script/network/RequestCenter"
require "db/DB_Growth_fund"
require "script/ui/rechargeActive/ActiveCache"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/utils/BaseUI"

			
local _fundBackground			-- 背景
local _myTableViewSp
local _myTableView 				-- 
local _needGold
local _vipDesc2 

local IMG_PATH = "images/recharge/fund/"

-- 
local function init( )
	_myTableViewSp = nil
	_myTableView = nil
	_fundBackground = nil
	_needGold = 0
	_vipDesc2 = nil
end 

-- 充值按钮的回调函数
local function rechargeCallBack(tag, menuItem)
	print(" ================  rechargeCallBack ====== ")
	local layer = RechargeLayer.createLayer()
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(layer,1111)
end

-- 
local function getGrowUpInfo( cbFlag, dictData, bRet  )

	if (dictData.err == "ok") then
		-- 将数据缓存器起来数据
		print_t(dictData.ret)
		ActiveCache.setPrizeInfo(dictData.ret)     
    end
end
-- 购买的网络回调事件
function activationAction(cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		UserModel.addGoldNumber(-tonumber(_needGold))
		AnimationTip.showTip(GetLocalizeStringBy("key_2898"))
		
		RequestCenter.growUp_getInfo(getGrowUpInfo)
	end
end

-- 购买按钮的回调函数
local function buyItemCallBack(tag, menuItem)
	print(" ================  buyItemCallBack ====== ")
	local growthData = DB_Growth_fund.getDataById(1)
	-- 
	if(tonumber(UserModel.getVipLevel()) < tonumber(growthData.need_vip) ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2751") .. growthData.need_vip .. GetLocalizeStringBy("key_2856") )
		return 
	end

	if(tonumber(UserModel.getGoldNumber())< tonumber(growthData.need_gold)) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1092") )
		return 
	end

	if(ActiveCache.getPrizeInfo() ~= "unactived") then
		AnimationTip.showTip(GetLocalizeStringBy("key_1502"))
		return
	end
	menuItem:setVisible(false)
	_vipDesc2:removeFromParentAndCleanup(true)
	_vipDesc2 = nil
	_disabledReceiveSprite:setVisible(true)
	-- 网络函数，购买
	RequestCenter.growUp_activation(activationAction)

end


 -- 创建layer
function createLayer(  )
	init()
	local layer  = CCLayer:create()

	-- 背景图
	_fundBackground = CCScale9Sprite:create(IMG_PATH .. "fund_bg.png")
	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
	require "script/ui/rechargeActive/RechargeActiveMain"
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local height = g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height )*g_fScaleX  -- RechargeActiveMain.getBgWidth()

	_fundBackground:setContentSize(CCSizeMake(g_winSize.width,height))
	_fundBackground:setPosition(ccp(0,menuLayerSize.height*g_fScaleX))
	layer:addChild(_fundBackground)

	-- 
	local bgSize = _fundBackground:getContentSize()

	-- 显示成长基金的描述
	local fundDescBg = CCSprite:create( IMG_PATH .. "fund_desc.png")
	fundDescBg:setScale(MainScene.elementScale)
	local height =  _fundBackground:getContentSize().height  - fundDescBg:getContentSize().height*g_fScaleX - RechargeActiveMain.getBgWidth() --menuLayerSize.height*g_fScaleX
	fundDescBg:setPosition(ccp(_fundBackground:getContentSize().width*0.5, height))
	fundDescBg:setAnchorPoint(ccp(0.5,0))
	_fundBackground:addChild(fundDescBg) 

	local alert ={}
	alert[1] = CCSprite:create(IMG_PATH .. "fund_plan.png") --CCRenderLabel:create(GetLocalizeStringBy("key_1972") , g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
	-- alert[1]:setColor(ccc3(0xff,0xf6,0x00))
	alert[1]:setPosition(ccp(fundDescBg:getContentSize().width/2, fundDescBg:getContentSize().height*46/201))
	alert[1]:setAnchorPoint(ccp(0.5,0))
	fundDescBg:addChild(alert[1])

	--local height = alert[1]:getPositionY() - alert[1]:getContentSize().height*MainScene.elementScale-3*MainScene.elementScale
	-- alert[2] = CCRenderLabel:create(GetLocalizeStringBy("key_3387") , g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
	-- alert[2]:setColor(ccc3(0xff,0xf6,0x00))
	-- alert[2]:setPosition(ccp(fundDescBg:getContentSize().width/2, height))
	-- alert[2]:setAnchorPoint(ccp(0.5,0))
	-- fundDescBg:addChild(alert[2])

	  -- VIP对应级别
	local vipContent = {}
	require "script/libs/LuaCC"
	vipContent[1]= CCSprite:create ("images/common/vip.png")--:setPosition(_topBg:getContentSize().width*0.372, _topBg:getContentSize().height*0.43)
    vipContent[2]= LuaCC.createSpriteOfNumbers("images/main/vip", 2 , 23)
    vipContent[3]=  CCRenderLabel:create(GetLocalizeStringBy("key_1546") , g_sFontName,21,1,ccc3(0x00,0x00,0x0),type_stroke)
    vipContent[3]:setColor(ccc3(0x70,0xff,0x18))
    local vipNode = BaseUI.createHorizontalNode(vipContent)
    vipNode:setPosition(fundDescBg:getContentSize().width/2, 20)
    vipNode:setAnchorPoint(ccp(0.5,0))

    fundDescBg:addChild(vipNode)

	-- 按钮菜单
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	_fundBackground:addChild(menu)
	local image_n = "images/common/btn/btn1_d.png"
    local image_h = "images/common/btn/btn1_n.png"
    local rect_full   = CCRectMake(0,0,150,74)
    local rect_inset  = CCRectMake(25,20,13,3)
    -- local btn_size_n    = CCSizeMake(164, 73)
    -- local btn_size_h    = CCSizeMake(164, 73) 
    local btn_size_n    = CCSizeMake(150, 73)
    local btn_size_h    = CCSizeMake(150, 73)     
    local text_color_n  = ccc3(0xfe, 0xdb, 0x1c) 
    local text_color_h  = ccc3(0xfe, 0xdb, 0x1c) 
    local font          = g_sFontPangWa
    
    --兼容东南亚英文版
    local font_size 
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	font_size = 25
    else
    	font_size = 35
    end
    
    local strokeCor_n   = ccc3(0x00, 0x00, 0x00) 
    local strokeCor_h   = ccc3(0x00, 0x00, 0x00)  
    local stroke_size   = 1

    -- 充值按钮
    local height = fundDescBg:getPositionY() - 10*g_fScaleY 
    local rechargeItem = LuaCCMenuItem.createMenuItemOfRender( image_n, image_h, rect_full, rect_inset, rect_full, rect_inset, btn_size_n, btn_size_h, GetLocalizeStringBy("key_1170"), text_color_n, text_color_h, font, font_size, strokeCor_n, strokeCor_h, stroke_size )
    rechargeItem:setPosition(ccp(127/640*bgSize.width,height))
    rechargeItem:setScale(MainScene.elementScale)
    rechargeItem:setAnchorPoint(ccp(0,1))
    rechargeItem:registerScriptTapHandler(rechargeCallBack)
    menu:addChild(rechargeItem)


     -- 若是已购买，则按钮置灰. 这里省事，直接显示一个灰色的精灵
	_disabledReceiveSprite = BTGraySprite:create("images/common/btn/btn1_d.png")
	_disabledReceiveSprite:setScale(MainScene.elementScale)
	--兼容东南亚英文版
local disabledLabel
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
	disabledLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1502"), g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
else
	disabledLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1502"), g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
end
	disabledLabel:setColor(ccc3(0xab,0xab,0xab))
	disabledLabel:setAnchorPoint(ccp(0.5,0.5))
	disabledLabel:setPosition(ccp(_disabledReceiveSprite:getContentSize().width/2,_disabledReceiveSprite:getContentSize().height/2))
	_disabledReceiveSprite:addChild(disabledLabel,0,101)
	_disabledReceiveSprite:setPosition(ccp(331/640*bgSize.width,height))
	_disabledReceiveSprite:setAnchorPoint(ccp(0,1))
	_fundBackground:addChild(_disabledReceiveSprite)
	
	if(ActiveCache.getPrizeInfo() == "unactived") then
	    -- 购买按钮
	    local buyItem = LuaCCMenuItem.createMenuItemOfRender( image_n, image_h, rect_full, rect_inset, rect_full, rect_inset, btn_size_n, btn_size_h, GetLocalizeStringBy("key_1523"), text_color_n, text_color_h, font, font_size, strokeCor_n, strokeCor_h, stroke_size )
	    buyItem:setPosition(ccp(331/640*bgSize.width,height))
	    buyItem:setAnchorPoint(ccp(0,1))
	    buyItem:setScale(MainScene.elementScale)
	    buyItem:registerScriptTapHandler(buyItemCallBack)
	    menu:addChild(buyItem)

		 -- 显示需要的金币
	    local growthData = DB_Growth_fund.getDataById(1)
	    _needGold = growthData.need_gold
	    local alertContent = {}
	    alertContent[1] = CCRenderLabel:create("" .. _needGold .. " ", g_sFontName,25,1,ccc3(0x00,0x00,0x0),type_stroke)
	    alertContent[1]:setColor(ccc3(0xff,0xf6,0x00))
	    alertContent[1]:setAnchorPoint(ccp(0,0))
	    alertContent[2] = CCSprite:create("images/common/gold.png")
	    _vipDesc2 = BaseUI.createHorizontalNode(alertContent)
	    _vipDesc2:setAnchorPoint(ccp(0,1))
	    local goldHeight = height - 18*g_fScaleY
	    _vipDesc2:setPosition(ccp(516/640*bgSize.width,goldHeight))
	    _vipDesc2:setScale(MainScene.elementScale)
	    _fundBackground:addChild(_vipDesc2)
		_disabledReceiveSprite:setVisible(false)
	end

    -- local args = CCArray:create()
   -- RequestCenter.growUp_getInfo(getGrowUpInfo,args)
	-- 创建 TableView
	local height = height - rechargeItem:getContentSize().height*MainScene.elementScale -- 5*g_fScaleY
	createTableView(height)

	return layer 
end

-- 获得 成长基金的数据
function getGrowthData( )
	local growthData = DB_Growth_fund.getDataById(1)
	local goldInfo =  string.split(growthData.golds_array, ",")
	local goldArrays = {}
	local i =0 
	for k ,v in pairs(goldInfo) do
		local tempStrTable = string.split(v, "|")
		local item = {}
		item.index = i
		i = i+ 1
		item.level = tempStrTable[1]
		item.num = tempStrTable[2]
		table.insert(goldArrays, item)
	end

	print("=============== ")
	print_t(goldArrays)
	return goldArrays
end

-- 创建 tableView
function createTableView( height )
	_myTableViewSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	-- local height = _fundBackground:getContentSize().height - height - 5*g_fScaleY
	print("the height is :" .. height)
	_myTableViewSp:setContentSize(CCSizeMake(_fundBackground:getContentSize().width/MainScene.elementScale- 35*g_fScaleX ,height/MainScene.elementScale -   15*g_fScaleY))
	_myTableViewSp:setScale(MainScene.elementScale)
	_myTableViewSp:setPosition(ccp(_fundBackground:getContentSize().width/2, height))
	_myTableViewSp:setAnchorPoint(ccp(0.5,1))
	_fundBackground:addChild(_myTableViewSp)

	local cellSize = CCSizeMake(602, 121)           --计算cell大小

    local myScale = MainScene.elementScale

    local goldArrays = getGrowthData()

    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width , cellSize.height)
        elseif fn == "cellAtIndex" then
            a2 = GrowthFundCell.createCell(goldArrays[a1+1])
           -- a2:setScale(myScale)
            r = a2
        elseif fn == "numberOfCells" then
            r = #goldArrays
        elseif fn == "cellTouched" then
            print("cellTouched", a1:getIdx())

        elseif (fn == "scroll") then
            
        end
        return r
    end)
    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(582,height/MainScene.elementScale - 30*g_fScaleY))
    _myTableView:setBounceable(true)
    local width = (_myTableViewSp:getContentSize().width- _myTableView:getContentSize().width)/2
    _myTableView:setPosition(ccp(width,7))
    -- _myTableView:setAnchorPoint(ccp(0.5,0))
    _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _myTableViewSp:addChild(_myTableView)

end

function updataTableView( ... )
    local offset = _myTableView:getContentOffset()
    _myTableView:reloadData()
    _myTableView:setContentOffset(offset)
end
