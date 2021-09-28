-- Filename: IllustrateLayer.lua
-- Author: zhz.
-- Date: 2013-1-21
-- Purpose: 该文件用于图鉴

module ("IllustrateLayer", package.seeall)

require "script/ui/main/MenuLayer"
require "script/libs/LuaCCMenuItem"
require "script/ui/hero/HeroInfoLayer"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"
require "db/DB_Heroes"
require "script/ui/menu/IllustratUtil"
require "script/model/hero/HeroModel"
require "script/network/RequestCenter"
require "script/ui/menu/CCMenuLayer"
require "script/audio/AudioUtil"
require "script/utils/BaseUI"


local _bgLayer				-- 
local _btnFrameSp			-- 按钮的sprite
local _curMenuItem			-- 当前点击的 menuItem
local _curSecItem           -- 当前点击的 二级按钮

local _curPicIndex          -- 当前是在那个index：1，武将 2，装备 3，宝物

local _layerSize
local _itemBg				-- 整个背景
local _scrowViewBg

------
local _heroBookHtid
local _equiptBookTid
local _treasBookTid

local _oneLineItemNum 
local _scrAddHeight         -- scrowview 自适应是 scrowview 的高度 
local _scrCellHeight

local _maxHeroStarLv        -- 当前英雄最高的星级

local _curMenutag
local _curSectag

local _ksHeroTag= 101
local _ksEquitTag= 102
local _ksTreasTag= 103
local _ksBackTag= 104
local  _illstrateInfo = {
        { name =GetLocalizeStringBy("key_1453"), hasNum= 0, allNum= 0},
        { name =GetLocalizeStringBy("key_2025"), hasNum =0, allNum =0 },
        {name =GetLocalizeStringBy("key_1848"), hasNum =0, allNum =0 },
    }

local function init( )
	_bgLayer= nil
    _curSecItem = nil
    _curMenuItem = nil
    _scrowViewBg= nil
	_btnFrameSp= nil
	_layerSize= nil
	_heroBookHtid = {}        -- tHeroNumByCountry = {wei=18, shu=56, wu=98, qun=99}
    _equiptBookTid= {}
    _treasBookTid= {}
    _oneLineItemNum= 5
    _scrAddHeight= 122 
    _scrCellHeight= 122
    _itemBg= nil
    _curPicIndex =1

end


--创建按钮
local function createMenuSp(  )
    _btnFrameSp = CCScale9Sprite:create("images/common/menubg.png")
    _btnFrameSp:setPreferredSize(CCSizeMake(640, 93))
    _btnFrameSp:setAnchorPoint(ccp(0.5, 1))
    _btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height ))
    _btnFrameSp:setScale(g_fScaleX)
    _bgLayer:addChild(_btnFrameSp, 10)

    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0, 0))
    menuBar:setTouchPriority(-210)
    _btnFrameSp:addChild(menuBar, 10)

    -- 武将的按钮
    local heroButton = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("key_1453"), 36)
    heroButton:setAnchorPoint(ccp(0, 0))
    heroButton:setPosition(ccp(_btnFrameSp:getContentSize().width*0.015, _btnFrameSp:getContentSize().height*0.1))
    heroButton:registerScriptTapHandler(menuCallBack)
    menuBar:addChild(heroButton,1, _ksHeroTag)
    heroButton:selected()
    _curMenuItem = heroButton
    _curMenutag = _ksHeroTag

    -- 装备按钮
    local specialButton = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("key_2025"), 36)
    specialButton:setAnchorPoint(ccp(0, 0))
    specialButton:setPosition(ccp(_btnFrameSp:getContentSize().width*170/640, _btnFrameSp:getContentSize().height*0.1))
    specialButton:registerScriptTapHandler(menuCallBack)
    menuBar:addChild(specialButton,1, _ksEquitTag)


    -- 宝物按钮
    local treasureBtn=  LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("key_1848"), 36)
    treasureBtn:setAnchorPoint(ccp(0, 0))
    treasureBtn:setPosition(ccp(_btnFrameSp:getContentSize().width*330/640, _btnFrameSp:getContentSize().height*0.1))
    treasureBtn:registerScriptTapHandler(menuCallBack)
    menuBar:addChild(treasureBtn,1, _ksTreasTag)

    -- 返回按钮的回调函数
    local backBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    backBtn:setAnchorPoint(ccp(1,0.5))
    backBtn:setPosition(ccp(_btnFrameSp:getContentSize().width-20,_btnFrameSp:getContentSize().height*0.5+6))
    backBtn:registerScriptTapHandler(menuCallBack)
    menuBar:addChild(backBtn,1,_ksBackTag)
end

-- 创建中部得UI 显示为
function createItemBg( )

    if(_itemBg ~= nil ) then
        _itemBg:removeFromParentAndCleanup(true)
        _itemBg=nil
    end
	_itemBg = CCScale9Sprite:create("images/common/bg/bg_ng.png")
    _itemBg:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height -_btnFrameSp:getContentSize().height*g_fScaleX- 52*g_fScaleX ))
    _itemBg:setPosition(_bgLayer:getContentSize().width*0.5,0)
    -- _itemBg:setScale(1/MainScene.elementScale)
    _itemBg:setAnchorPoint(ccp(0.5,0))
    _bgLayer:addChild(_itemBg)

    -- 
    local separatorTopSp= CCSprite:create("images/common/separator_top.png")
    separatorTopSp:setPosition(ccp(_itemBg:getContentSize().width/2, _itemBg:getContentSize().height-2))
    separatorTopSp:setAnchorPoint(ccp(0.5,1))
    separatorTopSp:setScale(g_fScaleX)
    _itemBg:addChild(separatorTopSp)
end

-- 创建 武将 ，装备，宝物 的数量
function createTitleProgress( )

    local height = _layerSize.height- _btnFrameSp:getContentSize().height*g_fScaleX- 13*g_fScaleX
    for i=1, #_illstrateInfo do
        local nameLabel = CCRenderLabel:create(_illstrateInfo[i].name , g_sFontPangWa , 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        nameLabel:setPosition( 32*MainScene.elementScale+ (i-1)*195*MainScene.elementScale  ,height)
        nameLabel:setScale(MainScene.elementScale)
        _bgLayer:addChild(nameLabel)

        -- -- 进度
        local progressBg= CCScale9Sprite:create("images/common/exp_bg.png")
        progressBg:setContentSize(CCSizeMake(130 ,23))
        -- progressBg:setScale(g_fScaleX)
        progressBg:setAnchorPoint(ccp(0,0.5))
        progressBg:setPosition( 4+ nameLabel:getContentSize().width ,nameLabel:getContentSize().height/2 )
        nameLabel:addChild(progressBg)
        
        local progressSp = CCScale9Sprite:create("images/common/exp_progress.png")
        progressSp:setContentSize(CCSizeMake(progressBg:getContentSize().width*_illstrateInfo[i].hasNum/_illstrateInfo[i].allNum ,23))
        progressSp:setPosition(1,progressBg:getContentSize().height/2)
        progressSp:setAnchorPoint(ccp(0,0.5))
        progressBg:addChild(progressSp)
        local progressLabel = CCRenderLabel:create("" .. _illstrateInfo[i].hasNum .."/" ..  _illstrateInfo[i].allNum , g_sFontName,18,1,ccc3(0x0,0x0,0x0),type_stroke)
        progressLabel:setColor(ccc3(0xff,0xff,0xff))
        progressLabel:setPosition(ccp(progressBg:getContentSize().width/2,progressBg:getContentSize().height/2))
        progressLabel:setAnchorPoint(ccp(0.5,0.5))
        progressBg:addChild(progressLabel)
    end

end


-- 创建英雄的UI
function createHeroMiddleUI()  
    -- print("ddddd 00 ")
    createItemBg()
    local menuPath={ "images/illustrate/hero/wei/wei" , "images/illustrate/hero/shu/shu", "images/illustrate/hero/wu/wu", "images/illustrate/hero/qun/qun"} 
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-551)
    _itemBg:addChild(menuBar)

    -- 魏 蜀 吴 群 按钮
    for i=1,4 do 
        local item = CCMenuItemImage:create(menuPath[i] .. "_n.png", menuPath[i] .. "_h.png")
        item:setPosition(_itemBg:getContentSize().width*(0.1+ 0.223*(i-1)), _itemBg:getContentSize().height -17*MainScene.elementScale)
        item:setAnchorPoint(ccp(0,1))
        item:setScale(g_fScaleX)
        item:registerScriptTapHandler( heroMenuAction)
        menuBar:addChild(item, 1, 1000+i )
        if(i==1) then
            item:selected()
            _curSecItem= item 
            _curSectag = 1001
        end
    end
    createScrollView(1)
end

-- 创建装备的UI
function createEuiptMiddleUI( )

    createItemBg()
    local menuPath={ "images/illustrate/equipt/weapon/weapon" , "images/illustrate/equipt/armor/armor", "images/illustrate/equipt/hat/hat", "images/illustrate/equipt/necklace/necklace"} 
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-551)
    _itemBg:addChild(menuBar)

    -- 武器，盔甲，头盔，项链 按钮
    for i=1,4 do 
        local item = CCMenuItemImage:create(menuPath[i] .. "_n.png", menuPath[i] .. "_h.png")
        item:setPosition(_itemBg:getContentSize().width*(0.1+ 0.223*(i-1)), _itemBg:getContentSize().height -15*MainScene.elementScale)
        item:setAnchorPoint(ccp(0,1))
        item:setScale(g_fScaleX)
        item:registerScriptTapHandler( itemMenuAction)
        menuBar:addChild(item, 1, 1000+i )
        if(i==1) then
            item:selected()
            _curSecItem= item 
            _curSectag = 1001
        end
    end

    createItemScrollView(101)
end

-- 创建宝物的UI
function createTreasMiddleUi(  )
    createItemBg()

    local menuPath={ "images/illustrate/treasure/book/book" , "images/illustrate/treasure/horse/horse"}
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-551)
    _itemBg:addChild(menuBar)

    -- 书 和 马
    for i=1,2 do 
        local item = CCMenuItemImage:create(menuPath[i] .. "_n.png", menuPath[i] .. "_h.png")
        item:setPosition(_itemBg:getContentSize().width*(0.306+ 0.296*(i-1)), _itemBg:getContentSize().height -17*MainScene.elementScale)
        item:setAnchorPoint(ccp(0,1))
        item:setScale(g_fScaleX)
        item:registerScriptTapHandler( treasMenuAction)
        menuBar:addChild(item, 1, 3000+i )
        if(i==1) then
            item:selected()
            _curSecItem= item 
            _curSectag = 3001
        end
    end
     createItemScrollView(202)
end


-- 创建
function createScrollView( heroIndex )

    local heroIndex = heroIndex or 1
    _scrowViewBg= CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _scrowViewBg:setContentSize(CCSizeMake(_itemBg:getContentSize().width- 41*MainScene.elementScale, _itemBg:getContentSize().height-115*MainScene.elementScale ))
    _scrowViewBg:setAnchorPoint(ccp(0.5,0))
    _scrowViewBg:setPosition(_itemBg:getContentSize().width/2, 19*MainScene.elementScale)
    _itemBg:addChild(_scrowViewBg)

    local trangleSp = CCSprite:create("images/illustrate/bottom_trangle.png")
    trangleSp:setPosition( 0.117*_scrowViewBg:getContentSize().width, _scrowViewBg:getContentSize().height-1)
    _scrowViewBg:addChild(trangleSp)

    -- 完成度
    local progressBg= CCScale9Sprite:create("images/common/exp_bg.png")
    progressBg:setContentSize(CCSizeMake(580 ,23))
    progressBg:setScale(g_fScaleX)
    progressBg:setAnchorPoint(ccp(0.5,1))
    progressBg:setPosition(_scrowViewBg:getContentSize().width/2,_scrowViewBg:getContentSize().height- 12*MainScene.elementScale )
    _scrowViewBg:addChild(progressBg)
    
    local hasHeroNum = IllustratUtil.getHasHeroNumByIndex(heroIndex)
    local allHeroNum= IllustratUtil.getHeroDataByIndex(heroIndex)
    local progressSp = CCScale9Sprite:create("images/common/exp_progress_blue.png")
    progressSp:setContentSize(CCSizeMake(progressBg:getContentSize().width* hasHeroNum/#allHeroNum ,23))
    progressSp:setPosition(1,progressBg:getContentSize().height/2)
    progressSp:setAnchorPoint(ccp(0,0.5))
    progressBg:addChild(progressSp)
    local progressLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2504") .. hasHeroNum .. "/" ..  #allHeroNum, g_sFontName,18,1,ccc3(0x0,0x0,0x0), type_stroke)
    progressLabel:setPosition(ccp(progressBg:getContentSize().width/2,progressBg:getContentSize().height/2))
    progressLabel:setAnchorPoint(ccp(0.5,0.5))
    progressBg:addChild(progressLabel)

    -- 武将的
    _scrowView = CCScrollView:create()
    _scrowView:setViewSize(CCSizeMake(591 , _scrowViewBg:getContentSize().height/g_fScaleX-44 ))
    _scrowView:setBounceable(true)
    _scrowView:setDirection(kCCScrollViewDirectionVertical)
    _scrowView:setAnchorPoint(ccp(0, 0))
    _scrowView:setTouchPriority(-560)
    _scrowView:setPosition(ccp(2, 4))
    _scrowView:setScale(g_fScaleX)
    _scrowViewBg:addChild(_scrowView)

    local height= 0
    for i=1,9 do
        print("IllustrateLayer", i)
        local heroInfo= IllustratUtil.getStarHeroData(heroIndex,i) 
        if( not table.isEmpty(heroInfo)) then
            local number = table.count(heroInfo)
             if(number > _oneLineItemNum) then
                number = math.ceil((number - _oneLineItemNum)/_oneLineItemNum)
                height = (197 + 122 * number) + height
            else
                height = 197 + height
            end
        end
    end

    _scrowView:setContentSize(CCSizeMake(591  , height))
    _scrowView:setContentOffset(ccp(0, _scrowView:getViewSize().height - _scrowView:getContentSize().height))
    local lastItemY = 0 
    local index = 1
    for i=9, 1,-1 do
        print("IllustrateLayer", i)
        local item1 = getHeroCellBg( heroIndex ,i )
        if(item1) then 
            -- item1:setScale(g_fScaleX)
            _scrowView:addChild(item1)
            item1:setAnchorPoint(ccp(0.5,0))
            if(index == 1) then
                item1:setPosition(ccp(_scrowView:getContentSize().width/2, _scrowView:getContentSize().height - item1:getContentSize().height ))
            else
                item1:setPosition(ccp(_scrowView:getContentSize().width/2, lastItemY - item1:getContentSize().height))
            end
            lastItemY = item1:getPositionY()
            index = index + 1
        end
    end    
end

-- 通过对应的index和星级找到
function getHeroCellBg(index, starLv  )
    local heroTable=  IllustratUtil.getStarHeroData(index, starLv)
    if( not heroTable or (table.count(heroTable) == 0) ) then
        return nil
    end

    local heroNum= table.count(heroTable)

    local height = nil
    if(heroNum < 6) then
        bSize = CCSizeMake(589, 195)
        cSize = CCSizeMake(555, 135)
    else
        local num = math.ceil((heroNum - 5)/5)
        bSize = CCSizeMake(589, 192 + 122 * num)
        cSize = CCSizeMake(555, 133 + 122 * num)
    end

    local fullRect = CCRectMake(0, 0, 116, 124)
    local insetRect = CCRectMake(30, 50, 1, 1)
    local listBg = CCScale9Sprite:create("images/reward/cell_back.png", fullRect, insetRect)
    listBg:setPreferredSize(bSize)

    local starBg = CCScale9Sprite:create("images/digCowry/star_bg.png")
    local starBgWidth = 50+30*starLv
    starBg:setContentSize(CCSizeMake(starBgWidth < 224 and 224 or starBgWidth ,40))
    starBg:setAnchorPoint(ccp(0, 1))
    listBg:addChild(starBg)
    starBg:setPosition(ccp(0, listBg:getContentSize().height))

    for i=1,starLv do
        local star = CCSprite:create("images/digCowry/star.png")
        starBg:addChild(star)
        star:setAnchorPoint(ccp(0.5, 0.5))
        star:setPosition(ccp(35 + 30*(i - 1), starBg:getContentSize().height/2+2))
    end

    local hasStarHeroNum = IllustratUtil.getHasStarHeroNum(index, starLv)
    local hasStarHeroLabel = CCRenderLabel:create( hasStarHeroNum .. "",g_sFontName, 18,1, ccc3(0x00,0x00,0x00), type_stroke)
    hasStarHeroLabel:setColor(ccc3(0x00,0xff,0x18))
    heroNumLabel = CCRenderLabel:create("/" .. heroNum, g_sFontName, 18,1, ccc3(0x0,0x0,0x0), type_stroke)
    local hasHeroNode = BaseUI.createHorizontalNode({hasStarHeroLabel, heroNumLabel})
    hasHeroNode:setPosition(listBg:getContentSize().width*497/585, listBg:getContentSize().height-20)
    hasHeroNode:setAnchorPoint(ccp(0,1))
    listBg:addChild(hasHeroNode)

    local itemInfoSpite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
    itemInfoSpite:setContentSize(cSize)
    itemInfoSpite:setPosition(ccp(listBg:getContentSize().width*0.5, 20))
    itemInfoSpite:setAnchorPoint(ccp(0.5, 0))
    listBg:addChild(itemInfoSpite)

    local menu= BTSensitiveMenu:create()
    if(menu:retainCount()>1)then
        menu:release()
        menu:autorelease()
    end
    menu:setPosition(ccp(0,0))
    itemInfoSpite:addChild(menu)

    local j = 1
    require "script/ui/item/ItemSprite"
    for k,v in pairs(heroTable) do
        local heroItem =  IllustratUtil.getHeroButton(v)  --ItemSprite.getHeroIconItemByhtid(v ,-128)
        menu:addChild(heroItem,1 ,v)
        heroItem:registerScriptTapHandler(heroSpriteCb)
        heroItem:setAnchorPoint(ccp(0, 1))
        heroItem:setPosition(ccp(8 + 111*(j-1), itemInfoSpite:getContentSize().height - 7))
        if(j > _oneLineItemNum) then
            local num = math.ceil((j - _oneLineItemNum)/_oneLineItemNum)
            local upNum = (j-1)%_oneLineItemNum
            heroItem:setPosition(ccp(8+ 111*upNum, itemInfoSpite:getContentSize().height - 7 - 120 * num))
        end
        j = j + 1
    end
    return listBg
end

--  创建物品的scrowView
function createItemScrollView( itemIndex )

    local itemIndex = itemIndex or 1
    _scrowViewBg= CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _scrowViewBg:setContentSize(CCSizeMake(_itemBg:getContentSize().width- 41*MainScene.elementScale, _itemBg:getContentSize().height-118*MainScene.elementScale ))
    _scrowViewBg:setAnchorPoint(ccp(0.5,0))
    _scrowViewBg:setPosition(_itemBg:getContentSize().width/2, 19*MainScene.elementScale)
    _itemBg:addChild(_scrowViewBg)

    local trangleSp = CCSprite:create("images/illustrate/bottom_trangle.png")
    trangleSp:setPosition( 0.105*_scrowViewBg:getContentSize().width, _scrowViewBg:getContentSize().height-1)
    _scrowViewBg:addChild(trangleSp)

    -- 完成度
    local progressBg= CCScale9Sprite:create("images/common/exp_bg.png")
    progressBg:setContentSize(CCSizeMake(580 ,23))
    progressBg:setScale(g_fScaleX)
    progressBg:setAnchorPoint(ccp(0.5,1))
    progressBg:setPosition(_scrowViewBg:getContentSize().width/2,_scrowViewBg:getContentSize().height- 12*MainScene.elementScale )
    _scrowViewBg:addChild(progressBg)
    
    local hasItemNum = IllustratUtil.getHasItemNumByIndex(itemIndex,_curPicIndex )
    print("hasItemNum  is : ", hasItemNum)
    local allItemNum= IllustratUtil.getItemByIndex(itemIndex)
    local progressSp = CCScale9Sprite:create("images/common/exp_progress_blue.png")
    local width= 0
    if( tonumber( hasItemNum)>0) then
        width= progressBg:getContentSize().width*hasItemNum/table.count(allItemNum)
    end
    print("width is : ", width)
    progressSp:setContentSize(CCSizeMake(width,23))
    progressSp:setPosition(1,progressBg:getContentSize().height/2)
    progressSp:setAnchorPoint(ccp(0,0.5))
    progressBg:addChild(progressSp)
    local progressLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2504") .. hasItemNum .. "/" ..  table.count(allItemNum),  g_sFontName,18,1,ccc3(0x0,0x0,0x0), type_stroke)
    progressLabel:setPosition(ccp(progressBg:getContentSize().width/2,progressBg:getContentSize().height/2))
    progressLabel:setAnchorPoint(ccp(0.5,0.5))
    progressBg:addChild(progressLabel)

    -- 物品的 
    local itemSrc = CCScrollView:create()
    itemSrc:setViewSize(CCSizeMake(591 , _scrowViewBg:getContentSize().height/g_fScaleX-44 ))
    itemSrc:setBounceable(true)
    itemSrc:setDirection(kCCScrollViewDirectionVertical)
    itemSrc:setAnchorPoint(ccp(0, 0))
    itemSrc:setPosition(ccp(2, 4))
    -- itemSrc:setTouchPriority(-560)
    itemSrc:setScale(g_fScaleX)
    _scrowViewBg:addChild(itemSrc)
    -- 增加橙装后 分为六个星级等级 by dengjianan
    local height= 0
    for i=1,6 do
        local itemInfo= IllustratUtil.getStarItemData(itemIndex,i) 
        if( not table.isEmpty(itemInfo)) then
            local number = table.count(itemInfo)
             if(number > _oneLineItemNum) then
                number = math.ceil((number - _oneLineItemNum)/_oneLineItemNum)
                height = (197 + 122 * number) + height
            else
                height = 197 + height
            end
        end
    end

    itemSrc:setContentSize(CCSizeMake(591  , height))
    itemSrc:setContentOffset(ccp(0, itemSrc:getViewSize().height - itemSrc:getContentSize().height))
    local lastItemY = 0 
    local index = 1
    --增加橙装后 分为六个星级等级 by dengjianan
    for i=6, 1,-1 do
        local item1 = getItemCellBg( itemIndex ,i )
        if(item1) then 
            -- item1:setScale(g_fScaleX)
            itemSrc:addChild(item1)
            item1:setAnchorPoint(ccp(0.5,0))
            if(index == 1) then
                item1:setPosition(ccp(itemSrc:getContentSize().width/2, itemSrc:getContentSize().height - item1:getContentSize().height ))
            else
                item1:setPosition(ccp(itemSrc:getContentSize().width/2, lastItemY - item1:getContentSize().height))
            end
            lastItemY = item1:getPositionY()
            index = index + 1
        end
    end    
end

function getItemCellBg( itemIndex, starLv )

    local itemTable=  IllustratUtil.getStarItemData(itemIndex, starLv)
    if( not itemTable or (table.count(itemTable) == 0) ) then
        return nil
    end

    local heroNum= table.count(itemTable)

    local height = nil
    if(heroNum < 6) then
        bSize = CCSizeMake(589, 195)
        cSize = CCSizeMake(555, 135)
    else
        local num = math.ceil((heroNum - 5)/5)
        bSize = CCSizeMake(589, 192 + 122 * num)
        cSize = CCSizeMake(555, 132 + 122 * num)
    end

    local fullRect = CCRectMake(0, 0, 116, 124)
    local insetRect = CCRectMake(30, 50, 1, 1)
    local listBg = CCScale9Sprite:create("images/reward/cell_back.png", fullRect, insetRect)
    listBg:setPreferredSize(bSize)

    local starBg = CCSprite:create("images/digCowry/star_bg.png")
    starBg:setAnchorPoint(ccp(0, 1))
    listBg:addChild(starBg)
    starBg:setPosition(ccp(0, listBg:getContentSize().height))

    for i=1,starLv do
        local star = CCSprite:create("images/digCowry/star.png")
        starBg:addChild(star)
        star:setAnchorPoint(ccp(0.5, 0.5))
        star:setPosition(ccp(35 + 30*(i - 1), starBg:getContentSize().height/2+2))
    end

    local hasStarItemNum = IllustratUtil.getHasStarItemNum(itemIndex, starLv,_curPicIndex)
    local hasStarItemLabel = CCRenderLabel:create( hasStarItemNum .. "",g_sFontName, 18,1, ccc3(0x00,0x00,0x00), type_stroke)
    hasStarItemLabel:setColor(ccc3(0x00,0xff,0x18))
    local itemNumLabel = CCRenderLabel:create("/" .. heroNum, g_sFontName, 18,1, ccc3(0x0,0x0,0x0), type_stroke)
    local hasItemNode = BaseUI.createHorizontalNode({hasStarItemLabel, itemNumLabel})
    hasItemNode:setPosition(listBg:getContentSize().width*497/585, listBg:getContentSize().height-20)
    hasItemNode:setAnchorPoint(ccp(0,1))
    listBg:addChild(hasItemNode)

    local itemInfoSpite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
    itemInfoSpite:setContentSize(cSize)
    itemInfoSpite:setPosition(ccp(listBg:getContentSize().width*0.5, 20))
    itemInfoSpite:setAnchorPoint(ccp(0.5, 0))
    listBg:addChild(itemInfoSpite)

    -- local menu= CCMenu:create()
    -- menu:setPosition(ccp(0,0))
    -- itemInfoSpite:addChild(menu)

    local j = 1
    require "script/ui/item/ItemSprite"
    for k,v in pairs(itemTable) do
        local heroItem =  IllustratUtil.getItemButton(v)  --ItemSprite.getHeroIconItemByhtid(v ,-128)
        itemInfoSpite:addChild(heroItem,1 ,v)
        -- heroItem:registerScriptTapHandler(heroSpriteCb)
        heroItem:setAnchorPoint(ccp(0, 1))
        heroItem:setPosition(ccp(8 + 111*(j-1), itemInfoSpite:getContentSize().height - 7))
        if(j > _oneLineItemNum) then
            local num = math.ceil((j - _oneLineItemNum)/_oneLineItemNum)
            local upNum = (j-1)%_oneLineItemNum
            heroItem:setPosition(ccp(8+ 111*upNum, itemInfoSpite:getContentSize().height - 7 - 120 * num))
        end
        j = j + 1
    end
    return listBg
end



function createLayer( )
	init()
	_bgLayer=CCLayer:create()
	MainScene.setMainSceneViewsVisible(true, false, true)

	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	local avatarLayerSize = MainScene.getAvatarLayerContentSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()

	_layerSize = {width= 0, height=0}
	_layerSize.width= g_winSize.width 
	_layerSize.height =g_winSize.height - (bulletinLayerSize.height+menuLayerSize.height)*g_fScaleX

    _bgLayer:setPosition(ccp(0, menuLayerSize.height*g_fScaleX))
    _bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))

	local bg = CCSprite:create("images/main/module_bg.png")
	bg:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bg)

    createMenuSp()
 
    RequestCenter.hero_getHeroBook(getHeroBookAction)

	return _bgLayer
end

------------------------------------------------------- callback -------------------------------------------
-- 最上面一系列按钮的回调函数 
function menuCallBack(tag, item )
    AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

    _curMenuItem:unselected()
    item:selected()
    _curMenuItem= item

    if(_curMenutag == tag) then
        return
    else
        _curMenutag = tag
    end

    -- print("tag is : " , tag)
    if(tag == _ksHeroTag) then
        createHeroMiddleUI()
        _curPicIndex= 1
    elseif(tag == _ksEquitTag) then
        _curPicIndex= 2
        createEuiptMiddleUI()
        
    elseif(tag== _ksTreasTag) then
         _curPicIndex= 3
        createTreasMiddleUi()
    elseif(tag== _ksBackTag) then
        print("leave")
        require "script/ui/menu/CCMenuLayer"
        local ccMenuLayer = CCMenuLayer.createMenuLayer()
        MainScene.changeLayer(ccMenuLayer, "ccMenu")
    end
   
end

-- 武将按钮：魏，蜀，吴
function heroMenuAction(tag, item )
    AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
    _curSecItem:unselected()
    item:selected()
    _curSecItem = item

    if(_curSectag == tag ) then
        return
    else
        _curSectag =tag
    end

    _scrowViewBg:removeFromParentAndCleanup(true)
    _scrowViewBg= nil

    if(tag== 1001) then
        createScrollView(1)
    elseif(tag == 1002) then
        createScrollView(2)
    elseif(tag == 1003) then
        createScrollView(3)
    elseif(tag== 1004) then
        createScrollView(4)
    end

end

-- 装备按钮的回调函数
function itemMenuAction(tag, item)
    AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
    _curSecItem:unselected()
    item:selected()
    _curSecItem = item

    if(_curSectag == tag ) then
        return
    else
        _curSectag =tag
    end

    _scrowViewBg:removeFromParentAndCleanup(true)
    _scrowViewBg= nil

    if(tag== 1001) then
        createItemScrollView(101)
    elseif(tag == 1002) then
        createItemScrollView(102)
    elseif(tag == 1003) then
        createItemScrollView(103)
    elseif(tag== 1004) then
        createItemScrollView(104)
    end


end

function treasMenuAction( tag, item )

    AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
    _curSecItem:unselected()
    item:selected()
    _curSecItem = item

    if(_curSectag == tag ) then
        return
    else
        _curSectag =tag
    end

    _scrowViewBg:removeFromParentAndCleanup(true)
    _scrowViewBg= nil

    if(3001== tag ) then
        createItemScrollView(202)
    elseif(3002 ==  tag) then
        createItemScrollView(201)
    end

end


function heroSpriteCb( tag,menuItem )

    -- 点击这些未开放的武将提示：该武将暂未开放。
    local curCountry = 0 -- 1魏，2蜀，3吴，4群
    if(_curSectag == 1001) then
        curCountry = 1
    elseif(_curSectag == 1002) then
        curCountry = 2
    elseif(_curSectag == 1003) then
        curCountry = 3
    elseif(_curSectag == 1004) then
        curCountry = 4
    end
    if (IllustratUtil.isNotOpenHero(curCountry,tag)) then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lgx_1049"))
        return
    end

    local function getHeroData(htid )
        require "script/model/hero/HeroModel"
        value = {}
        value.htid = htid
        require "db/DB_Heroes"
        local db_hero = DB_Heroes.getDataById(htid)
        value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
        value.name = db_hero.name
        value.level = db_hero.lv
        value.star_lv = db_hero.star_lv
        value.hero_cb = menu_item_tap_handler
        value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
        value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
        value.quality_h = "images/hero/quality/highlighted.png"
        value.type = "HeroFragment"
        value.isRecruited = false
        value.evolve_level = 0
        return value
    end

    local data = getHeroData(tag)
    HeroInfoLayer.createLayer(data, {isPanel=true},this_zOrder,info_priority)
end


-- 获得 heroBook 的网络回调函数
function getHeroBookAction( cbFlag, dictData, bRet )
    if(dictData.err ~= "ok") then
        return
    end
    _heroBookHtid = dictData.ret
    IllustratUtil.setHeroBook(dictData.ret)
    _illstrateInfo[1].hasNum= table.count(_heroBookHtid)
    local allNum = 0
    for i=1, 4 do
        allNum=  allNum+ table.count(IllustratUtil.getHeroDataByIndex(i))
    end
    _illstrateInfo[1].allNum= allNum

    Network.rpc(equiptCallback, "iteminfo.getArmBook","iteminfo.getArmBook", nil, true)


end

-- 装备的回调函数
function equiptCallback(cbFlag, dictData, bRet)
    if(dictData.err ~= "ok") then
        return
    end
    IllustratUtil.setEquiptBook(dictData.ret)
    _equiptBookTid = dictData.ret
    _illstrateInfo[2].hasNum= table.count(_equiptBookTid)

    local allNum= 0
    for i=101,104 do
         allNum=  allNum+ table.count(IllustratUtil.getItemByIndex(i))
    end
     _illstrateInfo[2].allNum= allNum

    Network.rpc(treasCallback, "iteminfo.getTreasBook","iteminfo.getTreasBook", nil, true)
end

-- 宝物的回调函数
function treasCallback(cbFlag, dictData, bRet)
    if(dictData.err ~= "ok") then
        return
    end

    IllustratUtil.setTreasBookTid(dictData.ret)
    _treasBookTid= dictData.ret

    _illstrateInfo[3].hasNum= table.count(_treasBookTid)
    _illstrateInfo[3].allNum= table.count(IllustratUtil.getItemByIndex(201))+ table.count(IllustratUtil.getItemByIndex(202))

    createHeroMiddleUI()
    createTitleProgress()
end


