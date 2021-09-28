-- Filename：	SellPetLayer.lua
-- Author：		zhz
-- Date：		2014-6-10
-- Purpose：		出售所有未上阵的宠物

module("SellPetLayer", package.seeall)

require "script/ui/item/ItemSprite"
require "script/ui/pet/PetData"
require "script/ui/pet/PetSelectCell"
require "script/ui/pet/PetService"

local  _bgLayer
local _bottomSprite
local _silverLabel
local _goldLabel

local _sellPetIds           -- 要出售宠物的id
local _allSlverNum          --所有的银币数

-- 初始化函数
local function init( )

	_bgLayer	   	=nil
	_bottomSprite  	=nil
	_silverLabel   	=nil
	_goldLabel		=nil
    _sellPetIds     = {}
    _allSlverNum    =nil
end


-- 创建底部面板
local function createBottomSprite()

	_bottomSprite = CCSprite:create("images/common/sell_bottom.png")
	_bottomSprite:setScale(g_fScaleX)
	_bottomSprite:setPosition(ccp(0, 0))
	_bottomSprite:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(_bottomSprite, 10)

	-- 已选择宠物
	local equipLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3300"), g_sFontName, 25)
	equipLabel:setColor(ccc3(0xff, 0xff, 0xff))
	equipLabel:setAnchorPoint(ccp(0, 0.5))
	equipLabel:setPosition(ccp(8 ,_bottomSprite:getContentSize().height*0.4))
	_bottomSprite:addChild(equipLabel)

	--已选择宠物数量背景
	local fullRect = CCRectMake(0,0,34,32)
	local insetRect = CCRectMake(10,10,14,12)
	local itemNumSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	itemNumSprite:setPreferredSize(CCSizeMake(65, 38))
	itemNumSprite:setAnchorPoint(ccp(0,0.5))
	itemNumSprite:setPosition(ccp(144, _bottomSprite:getContentSize().height*0.4))
	_bottomSprite:addChild(itemNumSprite)

	-- 宠物数量
	_itemNumLabel = CCLabelTTF:create("0", g_sFontName, 25)
	_itemNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_itemNumLabel:setAnchorPoint(ccp(0.5, 0.5))
	_itemNumLabel:setPosition(ccp(itemNumSprite:getContentSize().width*0.5, itemNumSprite:getContentSize().height*0.4))
	itemNumSprite:addChild(_itemNumLabel)


	local pointLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1821"), g_sFontName, 25)
	pointLabel:setColor(ccc3(0xff, 0xff, 0xff))
	pointLabel:setAnchorPoint(ccp(0, 0.5))
	pointLabel:setPosition(ccp(235 , _bottomSprite:getContentSize().height*0.4))
	_bottomSprite:addChild(pointLabel)

	-- 技能点数量背景
    local totalSilverBg = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
    totalSilverBg:setPreferredSize(CCSizeMake(142, 36))
    totalSilverBg:setPosition( 345 , _bottomSprite:getContentSize().height*0.4)
    totalSilverBg:setAnchorPoint(ccp(0,0.5))
    _bottomSprite:addChild(totalSilverBg)
    -- 银币图标
    local silverIcon = CCSprite:create("images/common/coin_silver.png")
    silverIcon:setPosition(8, 2)
    totalSilverBg:addChild(silverIcon)

	-- 卖的钱
	_sellNumLabel = CCLabelTTF:create("0", g_sFontName, 25)
	_sellNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_sellNumLabel:setAnchorPoint(ccp(0, 0.5))
	_sellNumLabel:setPosition(silverIcon:getPositionX()+silverIcon:getContentSize().width+2, totalSilverBg:getContentSize().height*0.4)
	totalSilverBg:addChild(_sellNumLabel)

	-- 出售按钮
	local sureMenuBar = CCMenu:create()
	sureMenuBar:setPosition(ccp(0,0))
	_bottomSprite:addChild(sureMenuBar)
	sureMenuBar:setTouchPriority(-452 )
	local sureBtn =  LuaMenuItem.createItemImage("images/tip/btn_confirm_n.png", "images/tip/btn_confirm_h.png" )
	sureBtn:setAnchorPoint(ccp(0.5, 0.5))
    sureBtn:setPosition(ccp(_bottomSprite:getContentSize().width*560/640, _bottomSprite:getContentSize().height*0.4))
    sureBtn:registerScriptTapHandler(sureBtnAction)
	sureMenuBar:addChild(sureBtn)
end

function refreshBottomSprite(  )
    local petNumber= #_sellPetIds

    _allSlverNum= 0
    for i=1, #_sellPetIds do 
        _allSlverNum= _allSlverNum+ PetData.getSoldSliverByPetInfo(tonumber(_sellPetIds[i]))
    end

    _itemNumLabel:setString(tostring(petNumber))
    _sellNumLabel:setString(tostring(_allSlverNum)) 
end


   -- 上标题栏 显示战斗力，银币，金币
function createTopUI()
    _topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0,_layerSize.height )
    _topBg:setScale(g_fScaleX)
    _bgLayer:addChild(_topBg, 10)

    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(_topBg:getContentSize().width*0.13,_topBg:getContentSize().height*0.43)
    _topBg:addChild(powerDescLabel)
    
    _powerLabel = CCRenderLabel:create( UserModel.getFightForceValue(), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerLabel:setPosition(_topBg:getContentSize().width*0.23,_topBg:getContentSize().height*0.66)
    _topBg:addChild(_powerLabel)
    
    -- modified by yangrui at 2015-12-03
    _silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(UserModel.getSilverNumber()),g_sFontName,18)
    _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    _silverLabel:setAnchorPoint(ccp(0,0.5))
    _silverLabel:setPosition(_topBg:getContentSize().width*0.61,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_silverLabel)
    
    _goldLabel = CCLabelTTF:create(UserModel.getGoldNumber()  ,g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(_topBg:getContentSize().width*0.82,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_goldLabel)
end

-- 刷新UI
function refreshTopUI( )
    -- modified by yangrui at 2015-12-03
    _silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))
end

local function createMenuSp( ... )
	_btnFrameSp = CCScale9Sprite:create("images/common/menubg.png")
    _btnFrameSp:setPreferredSize(CCSizeMake(640, 93))
    _btnFrameSp:setAnchorPoint(ccp(0.5, 1))
    _btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _layerSize.height- _topBg:getContentSize().height * g_fScaleX ))
    _btnFrameSp:setScale(g_fScaleX)
    _bgLayer:addChild(_btnFrameSp, 10)

    local descLabel = CCLabelTTF:create(GetLocalizeStringBy("key_4033"), g_sFontName, 24)
    descLabel:setColor(ccc3(0x00,0xff,0x18) )
    descLabel:setPosition(_btnFrameSp:getContentSize().width*0.05, _btnFrameSp:getContentSize().height*0.24 )
    descLabel:setAnchorPoint(ccp(0,0 ))
    _btnFrameSp:addChild(descLabel)

    -- 返回按钮
    local menuBar= CCMenu:create()
    menuBar:setPosition(0,0)
    _btnFrameSp:addChild(menuBar)

    local backItem= CCMenuItemImage:create("images/hero/btn_back_n.png", "images/hero/btn_back_h.png")
    backItem:setPosition(_btnFrameSp:getContentSize().width*0.73, 11)
    menuBar:addChild(backItem)
    backItem:registerScriptTapHandler(backAction)

end



-- 得到售卖宠物的id 数组
function getSellPetIds(  )
    
    return _sellPetIds
end

function setSellPetIds(sellIds )
    _sellPetIds= sellIds
end



-- 创建选择宠物的tableView
local function createTableView( )

	
	_canSellPetInfo = PetData.getCanSellPetInfo()
	print(" ------------------ _canSellPetInfo --------------------------- ")
	print_t(_canSellPetInfo)

	local cellSize = CCSizeMake(640*g_fScaleX,210*g_fScaleX)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif fn == "cellAtIndex" then
            a2 = PetSelectCell.createCell(_canSellPetInfo[a1 + 1],-231 , 2)
            a2:setScale(g_fScaleX)
            r = a2
        elseif fn == "numberOfCells" then
            r = #_canSellPetInfo
        elseif fn == "cellTouched" then
            
        elseif (fn == "scroll") then
            
        end
        return r
    end)
    local height = _layerSize.height- (_btnFrameSp:getContentSize().height)*(_btnFrameSp:getScale()) - _bottomSprite:getContentSize().height* _bottomSprite:getScale()- _topBg:getContentSize().height *g_fScaleX  
    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(_layerSize.width,height))
    _myTableView:setAnchorPoint(ccp(0,0))
    _myTableView:setBounceable(true)
    -- _myTableView:setScale(g_fScaleX)
    _myTableView:setPosition(ccp(0, _bottomSprite:getContentSize().height* _bottomSprite:getScale()))
    -- myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _bgLayer:addChild(_myTableView, 9)
end

-- 刷新 tableView
 function refreshTableView( )
    _canSellPetInfo = PetData.getCanSellPetInfo()
    _myTableView:reloadData()

end



-- 出售所有宠物的
function createLayer( )

	init()
    _bgLayer= CCLayer:create()
    --_bgLayer:registerScriptHandler(onNodeEvent)

    local bg = CCSprite:create("images/main/module_bg.png")
    bg:setScale(g_fBgScaleRatio)
    _bgLayer:addChild(bg)

    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    menuLayerSize = MenuLayer.getLayerContentSize()
    
    MainScene.getAvatarLayerObj():setVisible(false)
    MenuLayer.getObject():setVisible(false)
    BulletinLayer.getLayer():setVisible(true)

  	_layerSize = {width= 0, height=0}
	_layerSize.width= g_winSize.width 
	_layerSize.height =g_winSize.height - (bulletinLayerSize.height)*g_fScaleX

	createTopUI()
    createMenuSp()
    createBottomSprite()
    createTableView()
    
    return _bgLayer
end



-------------------------------------------------------- 回调函数 -----------------------------------------------
-- 刷新后的回调
--[[
    @desc:  刷新后的回调
    @param: pRetData 后端返回的返还物品信息
--]]
function rfcAftSold( pRetData )
    
    -- 判断是否有物品返还, add 20160330 lgx
    local isItemReturn = false
    for k,v in pairs(pRetData.item) do
        if (tonumber(v) > 0) then
            isItemReturn = true
            break
        end
    end

    if (isItemReturn) then
        -- 有返还物品 弹出返还的物品信息和银币板子
        local rewardInfo = {}
        -- 银币
        local silverTab = {}
        silverTab.type = "silver"
        silverTab.num  = tonumber(_allSlverNum)
        silverTab.name = GetLocalizeStringBy("key_8042")
        -- 加入奖励数组
        if(table.isEmpty(silverTab) == false) then
            table.insert(rewardInfo,silverTab)
        end
        -- 物品
        for k,v in pairs(pRetData.item) do
            local itemTab = {}
            itemTab.type = "item"
            itemTab.num  = tonumber(v)
            itemTab.tid  = tonumber(k)
            -- 加入奖励数组
            if(table.isEmpty(itemTab) == false) then
                table.insert(rewardInfo,itemTab)
            end
        end
        require "script/ui/item/ReceiveReward"
        ReceiveReward.showRewardWindow(rewardInfo, nil, 10000, -800, GetLocalizeStringBy("lgx_1013"))
    else
        -- 没有返还物品 提示获得银币
        AnimationTip.showTip(GetLocalizeStringBy("key_2736") .. _allSlverNum .. GetLocalizeStringBy("key_2894") )
    end

    UserModel.addSilverNumber(_allSlverNum) 
    _sellPetIds={}
    refreshTableView()
    refreshTopUI()
    refreshBottomSprite()

end

-- 确定的回调函数
function sureBtnAction( tag,item)
    local function sellCallback( isSold )
        if(isSold == false ) then
            return
        end
        PetService.sellPets( rfcAftSold, _sellPetIds )
    end
    -- 总计出售获得 银币
    local petNumber= #_sellPetIds
    if(petNumber ==0) then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("key_4013"))
        return
    end

    local str= GetLocalizeStringBy("key_3389") .. petNumber .. GetLocalizeStringBy("key_4012") .. _allSlverNum .. GetLocalizeStringBy("key_8042") 
    AlertTip.showAlert(str ,sellCallback, true,nil,nil,nil)
end

-- 返回按钮的回调函数, 返回到宠物背包的回调函数
function backAction( tah, item)
    
    require "script/ui/pet/PetBagLayer"
    local layer= PetBagLayer.createLayer() 
    MainScene.changeLayer( layer,"petBagLayer")
end









