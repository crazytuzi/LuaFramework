-- Filename：	GodWeaponSweepDialog.lua
-- Author：		LiuLiPeng
-- Date：		2016-2-2
-- Purpose：		过关斩将扫荡面板

module ("GodWeaponSweepDialog", package.seeall)

require "script/libs/LuaCCSprite"
require "db/DB_Explore_long"
require "db/DB_Help_tips"

local _layer
local _dialog
local _curNumber        = 0
local _maxNum           = 0
local _touch_priority   = -600
local _timeLable        = nil
local _chestBgSprite    = nil
local _buffBgSprite     = nil
local _curChooseType    = nil
local _costLabel        = nil
local _goldIcon         = nil
local _goldNumLabel     = nil
local _costNum          = 0
local _isChoose         = false
local kAddOneTag        = 10001
local kSubOneTag        = 10002

function init( ... )
    _curNumber          = 0
    _maxNum             = 0
    _costNum            = 0
    _isChoose           = false
    _goldNumLabel       = nil
    _goldIcon           = nil
    _costLabel          = nil
    _timeLable          = nil
    _chestBgSprite      = nil
    _buffBgSprite       = nil
    _curChooseType      = nil
end

function show()
    create()
    CCDirector:sharedDirector():getRunningScene():addChild(_layer, 100)
end

function create()
    init()
    _copyInfo = GodWeaponCopyData.getCopyInfo()
    _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
    _layer:registerScriptHandler(onNodeEvent)

    local dialog_info = {}
          dialog_info.title = GetLocalizeStringBy("llp_325")
          dialog_info.callbackClose = closeCallback
          dialog_info.size = CCSizeMake(630, 700)
          dialog_info.priority = _touch_priority - 1

    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _dialog:setScale(MainScene.elementScale)
    _layer:addChild(_dialog)

    local costData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
    local tab = string.split(costData.openCost,",")
    local lastTem = string.split(tab[table.count(tab)],"|")
    _maxNum = tonumber(lastTem[1])-tonumber(_copyInfo.luxurybox_num)

    buyChestTimePart()
    buyBuffPart()
    bottomItemMenu()
    createNumLabel()

    return _layer
end

local function changeNumberAction( tag,item )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if(tag == kSubOneTag) then
      -- -1
      _curNumber = _curNumber - 1 
    elseif(tag == kAddOneTag) then
      -- +1
      _curNumber = _curNumber + 1 
    end
    if(_curNumber < 1)then
      _curNumber = 0
    end
    -- 上限
    if(_curNumber > _maxNum)then
      _curNumber = _maxNum
    end

    local lastPassNum = tonumber(_copyInfo.va_pass.sweepInfo.count)
    local canSweepNum = math.floor(lastPassNum*0.7)
    local costData = DB_Overcome.getDataById(tonumber(_copyInfo.cur_base))
    local tab = string.split(costData.openCost,",")
    local cost = 0
    for i=tonumber(_copyInfo.luxurybox_num+1),tonumber(_copyInfo.luxurybox_num)+_curNumber do
      for k,v in pairs(tab) do
        local tem = string.split(v,"|")
        if((i)<=tonumber(tem[1]))then
          cost = cost+tem[2]
          break
        end
      end
    end
    local costNum = math.ceil(canSweepNum/2)*cost
    _costNum = costNum
    _goldNumLabel:setString(costNum)
    -- _goldIcon:setPosition(ccp(_costLabel:getContentSize().width,0))
    -- 个数
    _timeLable:setString(_curNumber)
end

function buyChestTimePart( ... )
    --购买宝箱块
    local bg = _dialog:getChildByTag(1)
          bg = tolua.cast(bg, "CCScale9Sprite")

    local title_bg = bg:getChildByTag(2)
          title_bg = tolua.cast(title_bg,"CCScale9Sprite")

    require "script/utils/BaseUI"
    
    --褐色背景
    _chestBgSprite = BaseUI.createContentBg(CCSizeMake(575,230))
    _chestBgSprite:setAnchorPoint(ccp(0.5,1))
    _chestBgSprite:setPosition(ccp(bg:getContentSize().width*0.5,bg:getContentSize().height - 20 - title_bg:getContentSize().height*0.5))
    _dialog:addChild(_chestBgSprite)
    local bgWidth   = _chestBgSprite:getContentSize().width
    local bgHeight  = _chestBgSprite:getContentSize().height
    
    --选择次数label
    local partNameLable = CCRenderLabel:create(GetLocalizeStringBy("llp_326"),g_sFontPangWa,30,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
          partNameLable:setColor(ccc3(0x00,0xe4,0xff))
          partNameLable:setAnchorPoint(ccp(0.5,1))
          partNameLable:setPosition(ccp(bgWidth*0.5,bgHeight))
    _chestBgSprite:addChild(partNameLable)
    local partNameLableWidth  = partNameLable:getContentSize().width
    local partNameLableHeight = partNameLable:getContentSize().height
    
    --左侧花
    local leftFlower = CCScale9Sprite:create("images/godweaponcopy/longflower.png")
          leftFlower:setAnchorPoint(ccp(0.5,0.5))
          leftFlower:setPosition(ccp(partNameLable:getContentSize().width*0.5,partNameLableHeight*0.5))
    partNameLable:addChild(leftFlower)

    -- --右侧花
    -- local rightFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    --       rightFlower:setScale(-1)
    --       rightFlower:setAnchorPoint(ccp(1,0.5))
    --       rightFlower:setPosition(ccp(partNameLableWidth,partNameLableHeight*0.5))
    -- partNameLable:addChild(rightFlower)

    --次数背景
    local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
          numberBg:setContentSize(CCSizeMake(170, 65))
          numberBg:setAnchorPoint(ccp(0.5, 0.5))
          numberBg:setPosition(ccp(bgWidth*0.5, bgHeight*0.6))
    _chestBgSprite:addChild(numberBg)

    --次数label
    _timeLable = CCLabelTTF:create("0",g_sFontPangWa,30)
    _timeLable:setAnchorPoint(ccp(0.5,0.5))
    _timeLable:setPosition(ccp(numberBg:getContentSize().width*0.5,numberBg:getContentSize().height*0.5))
    numberBg:addChild(_timeLable)

    --加减Menu
    local changeNumMenu = CCMenu:create()
          changeNumMenu:setTouchPriority(_touch_priority - 1)
          changeNumMenu:setPosition(ccp(0,0))
    _chestBgSprite:addChild(changeNumMenu)

    --减号按钮
    local add1Btn = CCMenuItemImage:create("images/shop/prop/btn_addition_n.png", "images/shop/prop/btn_addition_h.png")
          add1Btn:setPosition(ccp(numberBg:getPositionX()+numberBg:getContentSize().width*0.5+20, numberBg:getPositionY()-numberBg:getContentSize().height*0.5))
          add1Btn:registerScriptTapHandler(changeNumberAction)
    changeNumMenu:addChild(add1Btn, 1, kAddOneTag)

    --加号按钮
    local reduce1BtnXPos = add1Btn:getContentSize().width+numberBg:getContentSize().width+20
    local reduce1Btn = CCMenuItemImage:create("images/shop/prop/btn_reduce_n.png", "images/shop/prop/btn_reduce_h.png")
          reduce1Btn:setAnchorPoint(ccp(1,0))
          reduce1Btn:setPosition(ccp(numberBg:getPositionX()-numberBg:getContentSize().width*0.5-20,numberBg:getPositionY()-numberBg:getContentSize().height*0.5))
          reduce1Btn:registerScriptTapHandler(changeNumberAction)
    changeNumMenu:addChild(reduce1Btn, 1, kSubOneTag)

    --提示语
    local tipLable = CCRenderLabel:create(GetLocalizeStringBy("llp_327"),g_sFontName,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
          tipLable:setColor(ccc3(0xff,0xff,0xff))
          tipLable:setAnchorPoint(ccp(0.5,0))
          tipLable:setPosition(ccp(bgWidth*0.5,0))
    _chestBgSprite:addChild(tipLable)

    _costLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_343"),g_sFontName,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    _costLabel:setColor(ccc3(0xff,0xff,0xff))
    _costLabel:setAnchorPoint(ccp(0.5,0))
    _costLabel:setPosition(ccp(bgWidth*0.5,tipLable:getContentSize().height*1.5))
    _chestBgSprite:addChild(_costLabel)

    _goldIcon = CCSprite:create("images/pet/petfeed/gold.png")
    _goldIcon:setAnchorPoint(ccp(0,0))
    _goldIcon:setPosition(ccp(_costLabel:getContentSize().width,0))
    _costLabel:addChild(_goldIcon)

    _goldNumLabel = CCRenderLabel:create(0,g_sFontName,25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    _goldNumLabel:setColor(ccc3(0xff,0xff,0xff))
    _goldNumLabel:setAnchorPoint(ccp(0,0))
    _goldNumLabel:setPosition(ccp(_goldIcon:getContentSize().width,0))
    _goldIcon:addChild(_goldNumLabel)
end

local function chooseAction( tag,itemBtn )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    if(_isChoose)then
        itemBtn:unselected()
        _isChoose = false
    else
        itemBtn:selected()
        _isChoose = true
    end
end

function buyBuffPart( ... )
    --褐色背景
    local bg = _dialog:getChildByTag(1)
          bg = tolua.cast(bg, "CCScale9Sprite")
    local bgYPos = _chestBgSprite:getPositionY()-_chestBgSprite:getContentSize().height-20
    _buffBgSprite = BaseUI.createContentBg(CCSizeMake(575,200))
    _buffBgSprite:setAnchorPoint(ccp(0.5,1))
    _buffBgSprite:setPosition(ccp(bg:getContentSize().width*0.5,_chestBgSprite:getPositionY()-_chestBgSprite:getContentSize().height-40))
    _dialog:addChild(_buffBgSprite)
    local bgWidth   = _buffBgSprite:getContentSize().width
    local bgHeight  = _buffBgSprite:getContentSize().height
    
    --加成label
    local partBuffNameLable = CCRenderLabel:create(GetLocalizeStringBy("llp_328"),g_sFontPangWa,30,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
          partBuffNameLable:setColor(ccc3(255,255,0))
          partBuffNameLable:setAnchorPoint(ccp(0.5,1))
          partBuffNameLable:setPosition(ccp(bgWidth*0.5,bgHeight))
    _buffBgSprite:addChild(partBuffNameLable)
    local partNameLableWidth  = partBuffNameLable:getContentSize().width
    local partNameLableHeight = partBuffNameLable:getContentSize().height
    
    --左侧花
    local leftFlower = CCScale9Sprite:create("images/godweaponcopy/longflower.png")
          leftFlower:setAnchorPoint(ccp(0.5,0.5))
          leftFlower:setPosition(ccp(partBuffNameLable:getContentSize().width*0.5,partNameLableHeight*0.5))
    partBuffNameLable:addChild(leftFlower)

    -- --右侧花
    -- local rightFlower = CCScale9Sprite:create("images/god_weapon/flower.png")
    --       rightFlower:setScale(-1)
    --       rightFlower:setAnchorPoint(ccp(1,0.5))
    --       rightFlower:setPosition(ccp(partNameLableWidth,partNameLableHeight*0.5))
    -- partBuffNameLable:addChild(rightFlower)

    --提示语
    local tipLable = CCLabelTTF:create(GetLocalizeStringBy("llp_329"),g_sFontName,25)
          tipLable:setColor(ccc3(0xff,0xff,0xff))
          tipLable:setHorizontalAlignment(kCCTextAlignmentLeft)
          tipLable:setDimensions(CCSizeMake(bgWidth-190, 0))
          tipLable:setAnchorPoint(ccp(0.5,1))
          tipLable:setPosition(ccp(_buffBgSprite:getContentSize().width*0.5,partBuffNameLable:getPositionY()-15-partNameLableHeight))
    _buffBgSprite:addChild(tipLable)

    --勾选
    local chooseMenu = CCMenu:create()
          chooseMenu:setPosition(ccp(0,0))
          chooseMenu:setTouchPriority(_touch_priority - 1)
    _buffBgSprite:addChild(chooseMenu)
    _chooseMenuItem = CCMenuItemImage:create("images/common/duigou_n.png","images/common/duigou_h.png")
    _chooseMenuItem:setAnchorPoint(ccp(0.5,0))
    _chooseMenuItem:setPosition(ccp(bgWidth*0.5,0))
    _chooseMenuItem:registerScriptTapHandler(chooseAction)
    chooseMenu:addChild(_chooseMenuItem)
end

function afterSweep(pInfo)
    closeCallback()
    GodWeaponCopyData.setHaveSweep()
    require "script/ui/godweapon/godweaponcopy/GodWeaponSweepResultDialog"
    GodWeaponSweepResultDialog.show()
end

function sweepAction( tag,item )
    -- body
    if _costNum > UserModel.getGoldNumber() then
        LackGoldTip.showTip()
        return
    end
    local isBuyBuff = 0
    if(_isChoose)then
        isBuyBuff = 1
    end

    local args = CCArray:create()
          args:addObject(CCInteger:create(tonumber(_curNumber)))
          args:addObject(CCInteger:create(isBuyBuff))
    GodWeaponCopyService.sweep(afterSweep,args)
end

function battleBySelf( ... )
    -- body
    closeCallback()
    GodWeaponCopyData.setHaveSweep()
    GodWeaponCopyData.setCurBase()
    require "script/ui/godweapon/godweaponcopy/ChooseChallengerLayer"
    ChooseChallengerLayer.showLayer()
end

function bottomItemMenu()
    local bg = _dialog:getChildByTag(1)
          bg = tolua.cast(bg, "CCScale9Sprite")
    local menu = CCMenu:create()
          menu:setTouchPriority(_touch_priority - 1)
          menu:setPosition(ccp(0,0))
    bg:addChild(menu)
    --手动按钮
    local personItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png",CCSizeMake(192,65),GetLocalizeStringBy("llp_332"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
          personItem:setAnchorPoint(ccp(0,0))
          personItem:setPosition(ccp(bg:getContentSize().width*0.1,20))
          personItem:registerScriptTapHandler(battleBySelf)
    --扫荡
    local sweepItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png",CCSizeMake(192,65),GetLocalizeStringBy("llp_333"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
          sweepItem:setAnchorPoint(ccp(1,0))
          sweepItem:setPosition(ccp(bg:getContentSize().width*0.9,20))
          sweepItem:registerScriptTapHandler(sweepAction)
    --扫荡上面的三个星星
    for i = 1,3 do
        local starSprite = CCSprite:create("images/common/star.png")
              starSprite:setAnchorPoint(ccp(0.5,0))
              starSprite:setPosition(ccp(sweepItem:getContentSize().width*0.25*i,sweepItem:getContentSize().height))
        sweepItem:addChild(starSprite)
    end
    menu:addChild(personItem)
    menu:addChild(sweepItem)
end

function createNumLabel( ... )
    local bg = _dialog:getChildByTag(1)
          bg = tolua.cast(bg, "CCScale9Sprite")
    local lastPassNum = tonumber(_copyInfo.va_pass.sweepInfo.count)
    local canSweepNum = math.floor(lastPassNum*0.7)
    local canSweepNumStr = GetLocalizeStringBy("llp_331")..canSweepNum
    local canSweepNumLabel = CCRenderLabel:create(canSweepNumStr,g_sFontPangWa,30,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
          canSweepNumLabel:setColor(ccc3(0x00,0xff,0x18))
          canSweepNumLabel:setAnchorPoint(ccp(0.5,0))
          canSweepNumLabel:setPosition(ccp(bg:getContentSize().width*0.46,canSweepNumLabel:getContentSize().height*2.6))
    bg:addChild(canSweepNumLabel)
    local lastPassLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_330")..lastPassNum,g_sFontPangWa,30,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
          lastPassLabel:setColor(ccc3(255,0,0))
          lastPassLabel:setAnchorPoint(ccp(0.5,0))
          lastPassLabel:setPosition(ccp(canSweepNumLabel:getPositionX(),canSweepNumLabel:getPositionY()+canSweepNumLabel:getContentSize().height))
    bg:addChild(lastPassLabel)
end

function onTouchesHandler(event)
    return true
end

function onNodeEvent(event)
    if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, _touch_priority, true)
        _layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function closeCallback()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _layer:removeFromParentAndCleanup(true)
end