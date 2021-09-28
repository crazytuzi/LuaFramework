-- Filename：	SelSwallowPetLayer.lua
-- Author：		zhz
-- Date：		2014-3-4
-- Purpose：		选择吞噬宠物UI

module("SelSwallowPetLayer", package.seeall)

require "script/audio/AudioUtil"
require "script/ui/pet/PetSelectCell"
require "script/ui/pet/PetData"
require "db/DB_Pet"


local _bgLayer
local _selCheckedArr
local _startItemId
local _bottomSprite
local _topTitleSprite
local _touchPriority
local _zOrder
local _petId				-- 吞噬宠物的ID
local _canSwaPetInfo		-- 可以吞噬的宠物信息
local _swallow_pet_id		-- 被吞噬的宠物id
local _preSwallow_id		-- 上次被选中的吞噬宠物


local function init( )
	_bgLayer			=nil
	_selCheckedArr		=nil
	_startItemId		=nil
	_bottomSprite		=nil
	_topTitleSprite		=nil
	_touchPriority		=nil
	_zOrder				=nil
	_petId				=nil
end



-- 创建标题面板
local function createTitleLayer( )
    -- 上面的花边
    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local border_filename = "images/recharge/mystery_merchant/border.png"
    local border_top = CCSprite:create(border_filename)
    _bgLayer:addChild(border_top)
    border_top:setAnchorPoint(ccp(0, 0))
    border_top:setScale(g_fScaleX)
    border_top:setScaleY(-g_fScaleX)
    local border_top_y = g_winSize.height - 75 * g_fScaleX
    border_top:setPosition(0, border_top_y)
	-- 标题背景底图
	local topSprite = CCSprite:create("images/hero/select/title_bg.png")
	topSprite:setAnchorPoint(ccp(0,1))
	topSprite:setPosition(ccp(0,_layerSize.height - 48 * g_fScaleX))
	topSprite:setScale(g_fScaleX)
	_bgLayer:addChild(topSprite)
	local topSpriteSize = CCSizeMake(640,150)
	_topTitleSprite = CCSprite:create()
	_topTitleSprite:setContentSize(topSpriteSize)
	_topTitleSprite:setScale(g_fScaleX)
	-- 标题
	local title = CCSprite:create("images/pet/pet/swallow_sp.png")
    title:setAnchorPoint(ccp(0.5, 1))
    title:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height - 100 * g_fScaleX))
    title:setScale(g_fScaleX)
	_bgLayer:addChild(title)
	-- 吞噬说明文本
	local desLabelSp = CCSprite:create("images/pet/pet/swallow_desc.png")
	desLabelSp:setAnchorPoint(ccp(0.5, 1))
	desLabelSp:setPosition(ccpsprite(0.5,-0.2,title))
	title:addChild(desLabelSp)
	local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 10)
	_bgLayer:addChild(menu)
	local backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	menu:addChild(backItem)
	backItem:setScale(MainScene.elementScale * 0.9)
    backItem:registerScriptTapHandler(closeAction)
    backItem:setScale(MainScene.elementScale)
    backItem:setPosition(ccp(g_winSize.width - 100 * MainScene.elementScale, g_winSize.height - 160 * g_fScaleX))

	_topTitleSprite:setPosition(0, _layerSize.height)
	_topTitleSprite:setAnchorPoint(ccp(0, 1))
	_bgLayer:addChild(_topTitleSprite)
end

-- 创建底部面板
local function createBottomSprite()
	local menuHeight = MenuLayer.getHeight()
	_bottomSprite = CCSprite:create("images/common/sell_bottom.png")
	_bottomSprite:setScale(g_fScaleX)
	_bottomSprite:setPosition(ccp(0, menuHeight))
	_bottomSprite:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(_bottomSprite, 10)

	-- 已选择装备
	local equipLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3300"), g_sFontName, 25)
	equipLabel:setColor(ccc3(0xff, 0xff, 0xff))
	equipLabel:setAnchorPoint(ccp(0, 0.5))
	equipLabel:setPosition(ccp(8 ,_bottomSprite:getContentSize().height*0.4))
	_bottomSprite:addChild(equipLabel)

	-- 物品数量背景
	local fullRect = CCRectMake(0,0,34,32)
	local insetRect = CCRectMake(10,10,14,12)
	local itemNumSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	itemNumSprite:setPreferredSize(CCSizeMake(65, 38))
	itemNumSprite:setAnchorPoint(ccp(0,0.5))
	itemNumSprite:setPosition(ccp(144, _bottomSprite:getContentSize().height*0.4))
	_bottomSprite:addChild(itemNumSprite)

	-- -- 物品数量
	_itemNumLabel = CCLabelTTF:create("0", g_sFontName, 25)
	_itemNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_itemNumLabel:setAnchorPoint(ccp(0.5, 0.5))
	_itemNumLabel:setPosition(ccp(itemNumSprite:getContentSize().width*0.5, itemNumSprite:getContentSize().height*0.4))
	itemNumSprite:addChild(_itemNumLabel)


	local pointLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1342"), g_sFontName, 25)
	pointLabel:setColor(ccc3(0xff, 0xff, 0xff))
	pointLabel:setAnchorPoint(ccp(0, 0.5))
	pointLabel:setPosition(ccp(235 , _bottomSprite:getContentSize().height*0.4))
	_bottomSprite:addChild(pointLabel)

	-- 技能点数量背景
	local fullRect = CCRectMake(0,0,34,32)
	local insetRect = CCRectMake(10,10,14,12)
	local skillNumSprite = CCScale9Sprite:create("images/common/checkbg.png", fullRect, insetRect)
	skillNumSprite:setPreferredSize(CCSizeMake(65, 38))
	skillNumSprite:setAnchorPoint(ccp(0,0.5))
	skillNumSprite:setPosition(ccp(385 , _bottomSprite:getContentSize().height*0.4))
	_bottomSprite:addChild(skillNumSprite)

	-- 物品数量
	_skillNumLabel = CCLabelTTF:create("0", g_sFontName, 25)
	_skillNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
	_skillNumLabel:setAnchorPoint(ccp(0.5, 0.5))
	_skillNumLabel:setPosition(ccp(skillNumSprite:getContentSize().width*0.5, skillNumSprite:getContentSize().height*0.4))
	skillNumSprite:addChild(_skillNumLabel)

	-- 吞噬按钮
	local sureMenuBar = CCMenu:create()
	sureMenuBar:setPosition(ccp(0,0))
	_bottomSprite:addChild(sureMenuBar)
	sureMenuBar:setTouchPriority(_touchPriority-5 )
    sureBtn= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(150,73),GetLocalizeStringBy("key_1921"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    sureBtn:setAnchorPoint(ccp(0.5,0.5))
    sureBtn:setPosition(ccp(_bottomSprite:getContentSize().width*560/640, _bottomSprite:getContentSize().height*0.4))
    sureBtn:registerScriptTapHandler(sureBtnAction)
	sureMenuBar:addChild(sureBtn)
end


function refreshBottomSprite( )
	if(_swallow_pet_id== nil) then
		_itemNumLabel:setString("0")
	else
		_itemNumLabel:setString("1")
	end
	local swallowedPetInfo = PetData.getPetInfoById(tonumber(_swallow_pet_id))
	local petData = DB_Pet.getDataById( tonumber(swallowedPetInfo.pet_tmpl))

	local addPoint , level = PetData.getAddPoint(_petId, _swallow_pet_id)
	_skillNumLabel:setString(addPoint)
	print("curLv is ", level ," addPoint is", addPoint )
	-- local swallowNumber= tonumber(swallowedPetInfo.swallow )* 
	
end

-- 创建选择宠物的tableView
local function createTableView( )

	
	_canSwaPetInfo= PetData.getCanSwallowPetInfoByTid(_petId)
	-- print(" ------------------ _canSwaPetInfo --------------------------- ")
	-- print_t(_canSwaPetInfo)

	local cellSize = CCSizeMake(640*g_fScaleX,210*g_fScaleX)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif fn == "cellAtIndex" then
            a2 = PetSelectCell.createCell(_canSwaPetInfo[a1 + 1], _touchPriority-1 )
            a2:setScale(g_fScaleX)
            r = a2
        elseif fn == "numberOfCells" then
            r = #_canSwaPetInfo
        elseif fn == "cellTouched" then
            
        elseif (fn == "scroll") then
            
        end
        return r
    end)
    local menuHeight = MenuLayer.getHeight()
    local height = _layerSize.height- _topTitleSprite:getContentSize().height*g_fScaleX - _bottomSprite:getContentSize().height* g_fScaleX - menuHeight
    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(_layerSize.width,height))
    _myTableView:setAnchorPoint(ccp(0,0))
    _myTableView:setBounceable(true)
    -- _myTableView:setScale(g_fScaleX)
    _myTableView:setTouchPriority(_touchPriority-1)
    _myTableView:setPosition(ccp(0, (_bottomSprite:getContentSize().height) * g_fScaleX + menuHeight))
    -- myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _bgLayer:addChild(_myTableView, 9)
	
end

function rfcTableView( )

	_canSwaPetInfo= PetData.getCanSwallowPetInfoByTid(_petId)

	local offset = _myTableView:getContentOffset()
	_myTableView:reloadData()
	_myTableView:setContentOffset(offset)
	
end


-- 得到被宠物吞噬的id
function getSwallowPetId(  )
	
	return _swallow_pet_id
end

function setSwalloePetId(swallowedId )
	_swallow_pet_id= swallowedId
end


local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    	
    else
       
	end
end

-- 注册触摸事件
local function onNodeEvent(event)
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- petid:要吞噬别的宠物的petId， 要被吞噬的宠物swallow_pet_id
function showLayer( petid,swallow_pet_id )
	init()
	print("petid")
	print(petid)
	_touchPriority= touchPriority or -380
	_zOrder = zOrder or 600

	_petId =petid
	_swallow_pet_id = swallow_pet_id
	_preSwallow_id = swallow_pet_id
	print( "swallow_pet_id is in showLayer ", swallow_pet_id)

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
   	-- local scene = CCDirector:sharedDirector():getRunningScene()
    -- scene:addChild(_bgLayer,_zOrder,2013)
    MainScene.changeLayer(_bgLayer,"SelSwallowPetLayer")

	local bg = CCSprite:create("images/main/module_bg.png")
	bg:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bg)

	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	
	MenuLayer.getObject():setVisible(true)
	BulletinLayer.getLayer():setVisible(true)
	local topBg = PetUtil.createHeroInfoPanel()
    topBg:setAnchorPoint(ccp(0,1))
    topBg:setPosition(0, _bgLayer:getContentSize().height - BulletinLayer.getLayerHeight()*g_fScaleX)
    topBg:setScale(g_fScaleX)
    _bgLayer:addChild(topBg, 1, 19876)

	_layerSize = {width= 0, height=0}
	_layerSize.width= g_winSize.width 
	_layerSize.height =g_winSize.height - (bulletinLayerSize.height)*g_fScaleX

	createTitleLayer()
	createBottomSprite()
	createTableView()

	-- return _bgLayer
	
end


-----------------------------------------------[[ 按钮的回调事件]]-----------------------------------------------------

-- 关闭按钮的回调函数
function closeAction(tag , item)
	if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil
	end

	-- require "script/ui/pet/PetMainLayer"
	-- PetMainLayer.rfcAftSelect( _preSwallow_id)
    local layer = PetMainLayer.createLayer(PetMainLayer.getCurPetIndex())
    MainScene.changeLayer(layer,"PetMainLayer")
end

-- 确定按钮的回调函数
function sureBtnAction( tag, item)
	if( _swallow_pet_id == nil) then
        AnimationTip.showTip(GetLocalizeStringBy("key_2180"))
        return
    end
    local addPoint , level = PetData.getAddPoint(_petId, _swallow_pet_id)
    local petInfo = PetData.getPetInfoById(_swallow_pet_id)
    local richInfo = {
            elements = {
                {
                    text = petInfo.petDesc.roleName,
                    color = HeroPublicLua.getCCColorByStarLevel(petInfo.petDesc.quality),
                },
                {
                    text = addPoint,
                    color = ccc3(0xbd,0x01,0x01)
                }
            }
        }
    local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("syx_1075"), richInfo)  --“是否消耗%s%s，刷新符印商店”
    local alertCallback = function ( isConfirm )
        if not isConfirm then
            return
        end
        print("_swallow_pet_id is : ,  ", _swallow_pet_id)
		PetController.swallowPet(_swallow_pet_id)
		-- if not tolua.isnull(_bgLayer) then
		-- 	_bgLayer:removeFromParentAndCleanup(true)
		-- 	_bgLayer = nil
		-- end
    end
    require "script/ui/tip/RichAlertTip"
    RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil, nil, nil, true)  --字是“确定”
	-- require "script/ui/pet/PetMainLayer"
	-- print("_swallow_pet_id is : ,  ", _swallow_pet_id)
	-- PetMainLayer.rfcAftSelect(_swallow_pet_id)
end















