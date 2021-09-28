
-- FileName: PetFeedLayer.lua
-- Author: shengyixian
-- Date: 2016-01-29
-- Purpose: 宠物喂养
module("PetFeedLayer",package.seeall)

local _layer = nil
local _layerSize = nil
local _scrollView = nil
local _scrollSize = nil
local _curPetIndex = nil
local _touchBeganPos = nil
-- 玩家信息面板
local _heroInfoPanel = nil
-- 技能底框背景
local _bottomBg = nil
-- 宠物饲料数据
local _itemFeedInfo = nil
local _feedViewBg = nil
local _feedTableView = nil
local _feedPetInfo = nil
local _gid = nil
-- 一键喂养按钮
local _feedByOneBtn = nil
local _nameBg = nil
local _nameLabel = nil
local _advanceLvLabel = nil
local _middleUIPosY = nil
local _lvLabel = nil
local _backItem = nil

function init( ... )
	-- body
	_layer = nil
	_scrollView = nil
	_scrollSize = CCSizeMake(640, 265)
	_layerSize = nil
	_touchBeganPos = nil
	_curPetIndex = nil
    _heroInfoPanel = nil
    _bottomBg = nil
    _itemFeedInfo = nil
    _feedViewBg = nil
	_feedTableView = nil
	_feedPetInfo = nil
	_gid = nil
	_feedByOneBtn = nil
    _nameBg = nil
    _nameLabel = nil
    _advanceLvLabel = nil
    _middleUIPosY = nil
    _lvLabel = nil
    _backItem = nil
end

function createTopUI( ... )
	-- body
	local bulletinLayerSize = BulletinLayer.getLayerFactSize()
	createHeroInfoPanel()
	-- 上面的花边
    local border_filename = "images/recharge/mystery_merchant/border.png"
    local border_top = CCSprite:create(border_filename)
    border_top:setAnchorPoint(ccp(0, 0))
    border_top:setScale(g_fBgScaleRatio)
    border_top:setScaleY(-g_fBgScaleRatio)
    border_top:setVisible(false)
    local border_top_y = _layerSize.height - _heroInfoPanel:getContentSize().height * g_fBgScaleRatio
    border_top:setPosition(0, border_top_y)
    _layer:addChild(border_top)
    _middleUIPosY = border_top_y - border_top:getContentSize().height * g_fBgScaleRatio
    local titleSp = CCSprite:create("images/pet/pet/feedsp.png")
    titleSp:setAnchorPoint(ccp(0.5,1))
    titleSp:setPosition(ccp(_layerSize.width * 0.5,_layerSize.height - (_heroInfoPanel:getContentSize().height + 18) * g_fScaleX))
    titleSp:setScale(g_fScaleX)
    _layer:addChild(titleSp)
    local desSp = CCSprite:create("images/pet/pet/level_up_desc.png")
    desSp:setAnchorPoint(ccp(0.5,1))
    desSp:setPosition(ccpsprite(0.5,-0.2,titleSp))
    titleSp:addChild(desSp)
    -- 返回按钮
    local menu = CCMenu:create()
	menu:setPosition(ccp(0, 0))
	menu:setTouchPriority(_touchPriority - 10)
	_layer:addChild(menu)
	_backItem = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	_backItem:setScale(MainScene.elementScale * 0.9)
    _backItem:registerScriptTapHandler(closeBtnHandler)
    _backItem:setScale(MainScene.elementScale)
    _backItem:setAnchorPoint(ccp(0,1))
    _backItem:setPosition(ccp(_layerSize.width - 100 * MainScene.elementScale, _layerSize.height - (_heroInfoPanel:getContentSize().height + 10) * g_fScaleX))
	menu:addChild(_backItem)
end

function createHeroInfoPanel( ... )
    if _heroInfoPanel then
        _heroInfoPanel:removeFromParentAndCleanup(true)
        _heroInfoPanel = nil
    end
    _heroInfoPanel = PetUtil.createHeroInfoPanel()
    _heroInfoPanel:setAnchorPoint(ccp(0,1))
    _heroInfoPanel:setPosition(ccp(0,_layerSize.height))
    _heroInfoPanel:setScale(g_fScaleX)
    _layer:addChild(_heroInfoPanel)
end

function createScrollView( ... )
	-- body
    local feededPetInfo = PetData.getFeededPetInfo()
    _scrollView= CCScrollView:create()
    _scrollView:setViewSize(CCSizeMake(_scrollSize.width,_scrollSize.height))
    _scrollView:setContentSize(CCSizeMake(_scrollSize.width * table.count(feededPetInfo), _scrollSize.height ))
    _scrollView:setContentOffset(ccp(0,0))
    _scrollView:setScale(g_fBgScaleRatio)
    _scrollView:ignoreAnchorPointForPosition(false)
    _scrollView:setAnchorPoint(ccp(0,1))
    _scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    _scrollView:setPosition((_layerSize.width - _scrollSize.width*g_fBgScaleRatio)/2,_middleUIPosY)
    _layer:addChild(_scrollView,11)
    local scrollLayer = CCLayer:create()
    scrollLayer:setContentSize( CCSizeMake( _scrollSize.width*table.count(feededPetInfo), _scrollSize.height ))
    _scrollView:setContainer(scrollLayer)
    for i,petInfo in ipairs(feededPetInfo) do
        local petTid = nil 
        local petDb = nil
        if(petInfo.petDesc) then 
            petTid= petInfo.petDesc.id
            petDb = DB_Pet.getDataById(petTid)
        end
        local showStatus=  petInfo.showStatus
        local slotIndex= i
        local petSprite =  PetUtil.getPetIMGById(petTid ,showStatus, slotIndex)
        petSprite:setAnchorPoint(ccp(0.5,0))
        local offsetY = 0
        if petDb ~= nil then
            offsetY = petDb.Offset or 0
            if tonumber(offsetY) == 98 or tonumber(offsetY) == 95 then
                offsetY = 40
            end
        end
        petSprite:setPosition(ccp(_scrollSize.width*(i-0.5) ,25 - offsetY))
        petSprite:setScale(0.55)
        scrollLayer:addChild(petSprite,1)
    end
    _scrollView:setContentOffset(ccp(-(_curPetIndex -1)*_scrollSize.width , 0))
end

function createButtomUI( ... )
	-- body
    local menuBar= CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    _layer:addChild(menuBar)
    -- 一键喂养按钮
    _feedByOneBtn= LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(213,73),GetLocalizeStringBy("key_1126"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    _feedByOneBtn:setAnchorPoint(ccp(0.5,0))
    _feedByOneBtn:setPosition(_layerSize.width*0.5,7 * g_fElementScaleRatio )
    _feedByOneBtn:registerScriptTapHandler(feedByOneAction)
    _feedByOneBtn:setScale(g_fElementScaleRatio)
    menuBar:addChild(_feedByOneBtn,1)

	if(_bottomBg~= nil) then
        _bottomBg:removeFromParentAndCleanup(true)
        _bottomBg= nil
    end
    _bottomBg= CCScale9Sprite:create("images/pet/pet/bottom_bg.png")
    _bottomBg:setContentSize(CCSizeMake(640*g_fScaleX, 248*MainScene.elementScale ) )
    _bottomBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:setPosition(_layerSize.width/2, _feedByOneBtn:getContentSize().height * g_fElementScaleRatio + 7 * g_fElementScaleRatio)
    _layer:addChild(_bottomBg,15)
    
    local fullRect = CCRectMake(0,0,95,247)
    local insetRect = CCRectMake(41,57,3,157)
    _feedViewBg= CCScale9Sprite:create("images/pet/pet/feed_bg.png", fullRect, insetRect)
    _feedViewBg:setPreferredSize(CCSizeMake(630,248))
    _feedViewBg:setScale(MainScene.elementScale)
    _feedViewBg:setPosition(_layerSize.width/2, 0)
    _feedViewBg:setAnchorPoint(ccp(0.5,0))
    _bottomBg:addChild(_feedViewBg)

    local lvSp= CCSprite:create("images/common/lv.png")
    lvSp:setPosition(55,213)
    _feedViewBg:addChild(lvSp)

    _feedPetLevel= CCLabelTTF:create(tostring(_feedPetInfo[_curPetIndex].level ),g_sFontPangWa, 18)
    _feedPetLevel:setColor(ccc3(0xff,0xf6,0x00))
    _feedPetLevel:setAnchorPoint(ccp(0,0))
    _feedPetLevel:setPosition(96, 213)
    _feedViewBg:addChild(_feedPetLevel)

    local progressBg= CCScale9Sprite:create(CCRectMake(11, 7, 1, 1) , "images/pet/pet/progress_bg.png")
    progressBg:setPosition(133, 210)
    progressBg:setPreferredSize(CCSizeMake(440,23))
    _feedViewBg:addChild(progressBg)

    _lvProgress= CCScale9Sprite:create( "images/pet/petfeed/exp_progress.png")
    _lvProgress:setAnchorPoint(ccp(0, 0))
    _lvProgress:setPosition(ccp(2,0))

    local expUpgradeID = tonumber(_feedPetInfo[_curPetIndex].petDesc.expUpgradeID)
    local expFeed = _feedPetInfo[_curPetIndex].exp
    print("expUpgradeID is :", expUpgradeID , expFeed)
    local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,expFeed)
    print(" curLv,curExp,needExp  is : ", curLv,curExp,needExp )
    progressBg:addChild(_lvProgress)

    _lvProgress:setPreferredSize(CCSizeMake( 436*math.floor(curExp)/needExp, _lvProgress:getContentSize().height))

    _progressLebel= CCLabelTTF:create("" .. curExp .. "/" .. needExp, g_sFontName,21)
    _progressLebel:setPosition(progressBg:getContentSize().width/2,progressBg:getContentSize().height/2 )
    _progressLebel:setAnchorPoint(ccp(0.5,0.5))
    progressBg:addChild(_progressLebel)

    if(tonumber(_feedPetInfo[_curPetIndex].level)>= UserModel.getHeroLevel()) then
        _progressLebel:setString(GetLocalizeStringBy("key_1976"))
    else
        _progressLebel:setString("" ..  curExp .. "/" .. needExp)
    end
    -- 左边的箭头
    local leftArrow= CCSprite:create("images/formation/btn_left.png")
    leftArrow:setPosition(14,94)
    _feedViewBg:addChild(leftArrow)
    arrowAction(leftArrow)
     -- 右边的箭头
    local rightArrow= CCSprite:create("images/formation/btn_right.png")
    rightArrow:setPosition(567,94)
    _feedViewBg:addChild(rightArrow)
    arrowAction(rightArrow)

    --获得食品的信息，如果食品是空则显示前往商店和竞技功能，否则创建tableView
    --added by Zhang Zihang
    _itemFeedInfo = ItemUtil.getFeedInfos()

    if table.count(_itemFeedInfo) == 0 then
        --隐藏一键喂养和返回按钮
        -- _feedByOneBtn:setVisible(false)
        --创建寻找食物按钮
        createFindFoodFunction()
    else
        createFeedTableView()
    end
end
--[[
    @des    : 箭头的动画
    @param  : 
    @return : 
--]]
function arrowAction( arrow)
    local arrActions_2 = CCArray:create()
    arrActions_2:addObject(CCFadeOut:create(1))
    arrActions_2:addObject(CCFadeIn:create(1))
    local sequence_2 = CCSequence:create(arrActions_2)
    local action_2 = CCRepeatForever:create(sequence_2)
    arrow:runAction(action_2)
end
--[[
    @des    :创建前往商店和前往竞技按钮
    @param  :
    @return :
--]]
--added by Zhang Zihang
function createFindFoodFunction()
    local feedViewMenu = CCMenu:create()
    feedViewMenu:setPosition(ccp(0,0))
    _feedViewBg:addChild(feedViewMenu)

    --前往商店按钮
    local gotoShopMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1408"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1,ccc3(0x00, 0x00, 0x00))
    gotoShopMenuItem:setAnchorPoint(ccp(0.5, 0.5))
    gotoShopMenuItem:setPosition(ccp(_feedViewBg:getContentSize().width*0.3,_feedViewBg:getContentSize().height*0.6))
    gotoShopMenuItem:registerScriptTapHandler(gotoShopCallBack)
    feedViewMenu:addChild(gotoShopMenuItem)

    --前往竞技按钮
    local gotoPKMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_1279"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1,ccc3(0x00, 0x00, 0x00))
    gotoPKMenuItem:setAnchorPoint(ccp(0.5, 0.5))
    gotoPKMenuItem:setPosition(ccp(_feedViewBg:getContentSize().width*0.7,_feedViewBg:getContentSize().height*0.6))
    gotoPKMenuItem:registerScriptTapHandler(gotoPKCallBack)
    feedViewMenu:addChild(gotoPKMenuItem)

    --可前往商店购买，或前往竞技场兑换
    local foodLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1015"),g_sFontPangWa,24,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    foodLabel:setColor(ccc3(0xff,0xff,0xff))
    foodLabel:setAnchorPoint(ccp(0.5,0))
    foodLabel:setPosition(ccp(_feedViewBg:getContentSize().width*0.5,_feedViewBg:getContentSize().height*0.25))
    _feedViewBg:addChild(foodLabel)
end

--[[
    @des    :前往商店回调
    @param  :
    @return :
--]]
--added by Zhang Zihang
function gotoShopCallBack()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    --以下逻辑照抄StarLayer.gotoShopAction

    require "script/model/DataCache"
    if DataCache.getSwitchNodeState(ksSwitchShop) then
        require "script/ui/shop/ShopLayer"
        local  shopLayer = ShopLayer.createLayer(ShopLayer.Tag_Shop_Prop)
        MainScene.changeLayer(shopLayer,"shopLayer",ShopLayer.layerWillDisappearDelegate)
    end
end

--[[
    @des    :前往竞技回调
    @param  :
    @return :
--]]
--added by Zhang Zihang
function gotoPKCallBack()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    --以下逻辑照抄StarLayer.gotoMatchAction
    --为什么要判断物品和武将满，去问程亮

    --判断物品背包是否满
    if ItemUtil.isBagFull() == true then
        return
    end
    -- 判断武将背包是否满
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return
    end
    require "script/model/DataCache"
    local canEnter = DataCache.getSwitchNodeState(ksSwitchArena)
    if(canEnter) then
        require "script/ui/arena/ArenaLayer"
        local arenaLayer = ArenaLayer.createArenaLayer()
        MainScene.changeLayer(arenaLayer,"arenaLayer")
    end
end
--[[
    @des    :宠物饲料的tableView
    @param  :
    @return :
--]]
function createFeedTableView( )
    if (not tolua.isnull(_feedTableView)) then
        _feedTableView:removeFromParentAndCleanup(true)
        _feedTableView = nil
    end
    --下面这一行代码被注释掉是因为挪到createFeedUI()函数createFeedTableView()前面了
    --因为要在没有食品的情况下展示前往商店和前往竞技功能
    --added by Zhang Zihang    
    --_itemFeedInfo = ItemUtil.getFeedInfos()
    -- 按照品质排序，然后经验排序
    local function cmp( k1,k2)
        if( tonumber(k1.itemDesc.quality) > tonumber(k2.itemDesc.quality) ) then
            return true
        else
            if( tonumber(k1.itemDesc.quality) == tonumber(k2.itemDesc.quality) and  tonumber(k1.itemDesc.add_exp) > tonumber(k2.itemDesc.add_exp)) then
                return true
            else
                return false
            end
        end 
    end
    table.sort(_itemFeedInfo,cmp)
    local cellSize = CCSizeMake(128, 119)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = cellSize

        elseif fn == "cellAtIndex" then
            a2 = FeedCell.createCell(_itemFeedInfo[a1+1])
            r = a2
        elseif fn == "numberOfCells" then
            local num = #_itemFeedInfo
            r = num
        elseif fn == "cellTouched" then

            print("a1:getIdx() is ", a1:getIdx())
    
            local curPetId = _feedPetInfo[_curPetIndex].petid
            local item_id = _itemFeedInfo[a1:getIdx()+1].item_id
            local item_tmple_id= tonumber(_itemFeedInfo[a1:getIdx()+1].itemDesc.id)
            _gid = _itemFeedInfo[a1:getIdx()+1].gid

            if(_itemFeedInfo[a1:getIdx()+1].item_num == 0) then
                return
            end
            local expUpgradeID = tonumber(_feedPetInfo[_curPetIndex].petDesc.expUpgradeID)
            local expFeed = _feedPetInfo[_curPetIndex].exp
            local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,expFeed)
            local exp = tonumber (_feedPetInfo[_curPetIndex].exp)
            if( tonumber(_feedPetInfo[_curPetIndex].level)>=  UserModel.getHeroLevel() ) then
                AnimationTip.showTip(GetLocalizeStringBy("key_1251"))
                return
            end
            --喂养物品引导
            if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 6) then
                PetGuide.changLayer()
                PetGuide.show(7, nil)
            end
           PetService.feedPetByItem(curPetId, item_id , item_tmple_id,nil)
        elseif (fn == "scroll") then
            
        end
        return r
    end)

    _feedTableView = LuaTableView:createWithHandler(h, CCSizeMake(512, 119))
    _feedTableView:setBounceable(true)
    _feedTableView:setTouchPriority(-151)
    -- _feedTableView:setAnchorPoint(ccp(0,0.5))
    _feedTableView:setDirection(kCCScrollViewDirectionHorizontal)
    _feedTableView:setPosition(ccp(_feedViewBg:getContentSize().width*0.1, 55))
    _feedTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _feedViewBg:addChild(_feedTableView)
end

function onNodeHandler( eventType )
	-- body
	if eventType == "enter" then
		_layer:registerScriptTouchHandler(onTouchHandler,false,_touchPriority,true)
		_layer:setTouchEnabled(true)
	elseif eventType == "exit" then
		_layer:unregisterScriptTouchHandler()
	end
end

function onTouchHandler( eventType,x,y )
    if eventType == "began" then
        _touchBeganPos = ccp(x,y)
        local beganInNodePos = _scrollView:convertToNodeSpace(ccp(x,y))
        if x > 0 and x < _scrollSize.width * g_fScaleX and beganInNodePos.y > 0 and beganInNodePos.y < _scrollSize.height then
            return true
        end
    elseif eventType == "moved" then
        _scrollView:setContentOffset(ccp(x - _touchBeganPos.x - (_curPetIndex-1) * _scrollSize.width, 0))
    else
        local feededPetInfo = PetData.getFeededPetInfo()
        local xOffset = x - _touchBeganPos.x
        if xOffset < -20 * g_fScaleX then
            setCurPetIndex(_curPetIndex + 1)
        elseif xOffset > 20 * g_fScaleX then
            setCurPetIndex(_curPetIndex - 1)
        end
        _scrollView:setContentOffsetInDuration(ccp(-(_curPetIndex -1)*_scrollSize.width, 0),0.2)
    end
end

-- 宠物喂养的特效 ,通过boolUp来判断宠物是否升级
function feedEffect(boolUp)
    if tolua.isnull(_layer) then
        return
    end
    if(boolUp == nil) then
        boolUp = false
    end
    local img_path = CCString:create("images/pet/effect/chongwuweiyang/chongwuweiyang") 
    local addPetEffect = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
    -- music
    if(file_exists("images/pet/effect/chongwuweiyang.mp3")) then
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("images/pet/effect/chongwuweiyang.mp3")
    end
    addPetEffect:setPosition(ccp(g_winSize.width*0.5,_layerSize.height*0.6))
    addPetEffect:setAnchorPoint(ccp(0.5,0))
    addPetEffect:setFPS_interval(1/60.0)
    --CCDirector:sharedDirector():getRunningScene():addChild(addPetEffect,1000,9999)
    _layer:addChild(addPetEffect,13)


    local delegate = BTAnimationEventDelegate:create()
    --如果宠物升级
    if(boolUp) then
        delegate:registerLayerEndedHandler(function ( ... )
            -- body
            levelUpEffect()
        end)
    end
    addPetEffect:setDelegate(delegate)
end

function levelUpEffect()
    local img_path = CCString:create("images/pet/effect/fazhenbao/fazhenbao")
    local addPetEffect = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
    addPetEffect:setFPS_interval(1/60.0)
    addPetEffect:setPosition((_layerSize.width)/2,_layerSize.height*0.43)
    addPetEffect:setAnchorPoint(ccp(0.5,0))
    _layer:addChild(addPetEffect,4)

    local img_path = CCString:create("images/pet/effect/guangxian/guangxian")
    local addPetEffect_02 = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
    addPetEffect_02:setFPS_interval(1/60.0)
    addPetEffect_02:setPosition((_layerSize.width)/2,_layerSize.height*0.53)
     addPetEffect_02:setAnchorPoint(ccp(0.5,0))
    _layer:addChild(addPetEffect_02,12)
    local feededPetInfo = PetData.getFeededPetInfo()
    if( feededPetInfo[_curPetIndex].level ~= nil ) then 
        LevelUpUtil.showFloatText(GetLocalizeStringBy("key_2693") .. feededPetInfo[_curPetIndex].level .. GetLocalizeStringBy("key_2469"),g_sFontPangWa, rewardTxtColor)
    end
end

--[[
    @des    :设置当前宠物的索引变量
    @param  :
    @return :
--]]
function setCurPetIndex( pValue )
    local feededPetInfo = PetData.getFeededPetInfo()
    if pValue > table.count(feededPetInfo) then
        pValue = table.count(feededPetInfo)
    elseif pValue < 1 then
        pValue = 1
    end
    if _curPetIndex ~= pValue then
        _curPetIndex = pValue
        updateLvProgress()
        createNameUI()
    end
end

function createLayer( ... )
	-- body
	_layer = CCLayer:create()
	_layer:setContentSize(_layerSize)
	_layer:registerScriptHandler(onNodeHandler)
	local bg = CCSprite:create("images/pet/pet_bg_2.jpg")
    bg:setScale(g_fBgScaleRatio)
    bg:setAnchorPoint(ccp(0.5,1))
    bg:setPosition(ccpsprite(0.5,1.1,_layer))
	_layer:addChild(bg)
    createTopUI()
    createMiddleUI()
    createButtomUI()
	return _layer
end

function showLayer( pPetId,pTouchPriority,pZOrder )
	-- body
	init()   
	_feedPetInfo = PetData.getFeededPetInfo() 
	_curPetIndex = PetData.getFeededPetIndex(pPetId) or 1
	_touchPriority = pTouchPriority or -380
	pZOrder = pZOrder or 600
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    local menuLayerSize = MenuLayer.getLayerContentSize()
	_layerSize = CCSizeMake(0,0)
	_layerSize.width= g_winSize.width 
	_layerSize.height = g_winSize.height - (bulletinLayerSize.height + menuLayerSize.height) * g_fScaleX
	local layer = createLayer()
	layer:setPosition(ccp(0,menuLayerSize.height * g_fScaleX))
	MainScene.changeLayer(layer,"PetFeedLayer")
end

function createMiddleUI( ... )
    -- body
    createScrollView()
    createNameUI()
end

function createNameUI( ... )
    -- body
    if _nameBg then
        _nameBg:removeFromParentAndCleanup(true)
        _nameBg = nil
    end
    local petInfo = PetData.getFeededPetInfo()[_curPetIndex]
    -- 名字的背景
    local fullRect = CCRectMake(0,0,111,32)
    local insetRect = CCRectMake(39,15,2,2)
    _nameBg= CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
    _nameBg:setPreferredSize(CCSizeMake(245,35))
    _nameBg:setScale(g_fBgScaleRatio)
    _nameBg:setAnchorPoint(ccp(0.5,0))
    _nameBg:setPosition(_layerSize.width * 0.5 , _scrollView:getPositionY() - _scrollView:getContentSize().height * g_fBgScaleRatio)
    _layer:addChild(_nameBg,17)
    _nameLabel = CCRenderLabel:create(petInfo.petDesc.roleName,g_sFontPangWa,25,1,ccc3(0,0,0),type_shadow)
    -- _nameLabel= CCLabelTTF:create(petInfo.petDesc.roleName,g_sFontPangWa,25 )
    _nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(petInfo.petDesc.quality))
    _nameLabel:setAnchorPoint(ccp(0.5,0))
    _nameLabel:setPosition(ccpsprite(0.5,0,_nameBg))
    _nameBg:addChild(_nameLabel)
    local evolveLevel = petInfo.va_pet.evolveLevel or 0
    _advanceLvLabel = CCRenderLabel:create(GetLocalizeStringBy("syx_1089",evolveLevel),g_sFontPangWa,21,1,ccc3(0,0,0),type_shadow)
    -- _advanceLvLabel = CCLabelTTF:create(GetLocalizeStringBy("syx_1089",_curLv),g_sFontPangWa,25 )
    _advanceLvLabel:setColor(ccc3(0xff,0xf6,0x00))
    _advanceLvLabel:setAnchorPoint(ccp(0,0.5))
    _advanceLvLabel:setPosition(ccpsprite(1,0.5,_nameLabel))
    _nameLabel:addChild(_advanceLvLabel)
    local lvSp= CCSprite:create("images/common/lv.png")
    lvSp:setAnchorPoint(ccp(0,0.5))
    lvSp:setPosition(ccpsprite(0,0.5,_nameBg))
    _nameBg:addChild(lvSp)
    _lvLabel= CCLabelTTF:create(tostring(_feedPetInfo[_curPetIndex].level ),g_sFontPangWa, 18)
    _lvLabel:setColor(ccc3(0xff,0xf6,0x00))
    _lvLabel:setAnchorPoint(ccp(0,0.5))
    _lvLabel:setPosition(ccpsprite(1,0.5,lvSp))
    lvSp:addChild(_lvLabel)
end

function closeBtnHandler( ... )
	if not tolua.isnull(_layer) then
		_layer:removeFromParentAndCleanup(true)
		_layer = nil
        require "script/guide/NewGuide"
        require "script/guide/PetGuide"
        require "script/ui/pet/PetMainLayer"
        if(NewGuide.guideClass ==  ksGuidePet and PetGuide.stepNum == 8) then
            PetGuide.changLayer()
            local layer = PetMainLayer.createLayer(PetMainLayer.getCurPetIndex())
            MainScene.changeLayer(layer,"PetMainLayer")
            -- PetFeedLayer.showLayer(_formationPetInfo[_curPetIndex].petid)
            local button = PetMainLayer.getRealizeItem()
            local rect   = getSpriteScreenRect(button)
            PetGuide.show(9, rect)
        else
            local layer = PetMainLayer.createLayer(PetMainLayer.getCurPetIndex())
            MainScene.changeLayer(layer,"PetMainLayer")
        end
	end
end
-- 一键喂养的回调函数
function feedByOneAction(tag, item)
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    local curPetId = _feedPetInfo[_curPetIndex].petid 
    if(table.isEmpty(_itemFeedInfo)) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1707"))
        return 
    end
    if(curPetId ~= nil) then

        local allExp = 0
        for i=1, table.count(_itemFeedInfo) do
            allExp = allExp + _itemFeedInfo[i].itemDesc.add_exp*_itemFeedInfo[i].item_num
        end

        local expUpgradeID = tonumber(_feedPetInfo[_curPetIndex].petDesc.expUpgradeID)
        local expFeed = tonumber(_feedPetInfo[_curPetIndex].exp) 
        local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,expFeed)


        if( tonumber(_feedPetInfo[_curPetIndex].level)>= UserModel.getHeroLevel() ) then
            AnimationTip.showTip(GetLocalizeStringBy("key_1251"))
            return
        end

         print("allExp is : ", allExp , " and needExp is : ", needExp ," table.count(_itemFeedInfo)  is : ", table.count(_itemFeedInfo))

        local function feedToLimit( isFeed)
            if(isFeed== false) then
                return
            end
            PetService.feedPetByOne( curPetId, nil)
        end

        if(allExp > needExp) then
            AlertTip.showAlert(GetLocalizeStringBy("key_2440"),feedToLimit, true,nil,nil,nil)
        else
            feedToLimit(true)
        end        
    else
        AnimationTip.showTip(GetLocalizeStringBy("key_1858"))
    end
end
--[[
    @des    :更新等级进度
    @param  :
    @return :
--]]
function updateLvProgress( ... )
	-- body
	-- 等级文本
	_feedPetLevel:setString(tostring(_feedPetInfo[_curPetIndex].level))
	local expUpgradeID = tonumber(_feedPetInfo[_curPetIndex].petDesc.expUpgradeID)
    local expFeed = _feedPetInfo[_curPetIndex].exp
    print("expUpgradeID is :", expUpgradeID , expFeed)
    local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,expFeed)
    print(" curLv,curExp,needExp  is : ", curLv,curExp,needExp )
    -- 进度条
    _lvProgress:setPreferredSize(CCSizeMake( 436*math.floor(curExp)/needExp, _lvProgress:getContentSize().height))
    -- 进度文本
    _progressLebel:setString("" .. curExp .. "/" .. needExp)
    _lvLabel:setString(curLv)
end
--[[
    @des    :喂养后刷新
    @param  :
    @return :
--]]
function updateAfterFeeded( ... )
	-- body
    if tolua.isnull(_layer) then
        return
    end
	updateLvProgress()
	_itemFeedInfo = ItemUtil.getFeedInfos()
    if table.count(_itemFeedInfo) == 0 then
        -- _feedByOneBtn:setVisible(false)
        createFindFoodFunction()
    end
	-- refreshFeedView()
    local contentOffset = _feedTableView:getContentOffset()
    _feedTableView:reloadData()
    _feedTableView:setContentOffset(contentOffset)
end
-- 刷新_feedTableView 
function refreshFeedView()
    local function cmp( k1,k2)
        if( tonumber(k1.itemDesc.quality) > tonumber(k2.itemDesc.quality) ) then
            return true
        else
            if( tonumber(k1.itemDesc.quality) == tonumber(k2.itemDesc.quality) and  tonumber(k1.itemDesc.add_exp) > tonumber(k2.itemDesc.add_exp)) then
                return true
            else
                return false
            end
        end 
    end
    table.sort(_itemFeedInfo,cmp)
    local contentOffset = _feedTableView:getContentOffset()
    createFeedTableView()
    _feedTableView:setContentOffset(contentOffset)
end
function getCurFeededItemId( ... )
	-- body
	return _gid
end
-- 得到第一个宠物饲料的cell
function getFirstFoodCell( ... )
    local curCell= tolua.cast(_feedTableView:cellAtIndex(0),"CCTableViewCell")
    local sprite = tolua.cast(curCell:getChildByTag(1),"CCSprite")
    return sprite
end
function getFeedBackItem( ... )
    -- body
    return _backItem
end