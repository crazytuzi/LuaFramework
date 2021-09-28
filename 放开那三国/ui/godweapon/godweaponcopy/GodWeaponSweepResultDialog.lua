-- Filename：	GodWeaponSweepResultDialog.lua
-- Author：		LiuLiPeng
-- Date：		2016-2-2
-- Purpose：		过关斩将扫荡结果面板

module ("GodWeaponSweepResultDialog", package.seeall)

require "script/libs/LuaCCSprite"
require "db/DB_Explore_long"
require "db/DB_Help_tips"
require "db/DB_Overcome_buff"

local _layer
local _dialog
local _curNumber        = 1
local _maxNum           = 0
local _touch_priority   = -600
local _timeLable        = nil
local _chestBgSprite    = nil
local _buffBgSprite     = nil
local _curChooseType    = nil
local _isChoose         = false
local kAddOneTag        = 10001
local kSubOneTag        = 10002
local _itemResult       = {}
local _buffResult       = {}

function init( ... )
    _curNumber          = 1
    _maxNum             = 0
    _isChoose           = false
    _buffResult         = {}
    _itemResult         = {}
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
    _itemResult,_buffResult = GodWeaponCopyData.getSweepResult()
    print("_buffResult")
    print_t(_buffResult)
    print("_buffResult")

    _copyInfo = GodWeaponCopyData.getCopyInfo()
    _layer = CCLayerColor:create(ccc4(0, 0, 0, 100))
    _layer:registerScriptHandler(onNodeEvent)

    local dialog_info = {}
          dialog_info.title = GetLocalizeStringBy("llp_334")
          dialog_info.callbackClose = closeCallback
          dialog_info.size = CCSizeMake(630, 800)
          dialog_info.priority = _touch_priority - 1

    _dialog = LuaCCSprite.createDialog_1(dialog_info)
    _dialog:setAnchorPoint(ccp(0.5, 0.5))
    _dialog:setPosition(ccp(g_winSize.width * 0.5, g_winSize.height * 0.5))
    _dialog:setScale(MainScene.elementScale)
    _layer:addChild(_dialog)

    buyChestTimePart()
    buyBuffPart()
    createNumLabel()
    bottomItemMenu()

    return _layer
end

-- 创建物品图标
function createRewardCell( cellValues )
    local iconBg = nil
    local iconName = nil
    local nameColor = nil
    local tView_menuPriority = -600
    local tView_infoPriority = -601
    local layer_zOrder = 2100
    
    if(cellValues.type == "silver") then
      -- 银币
      iconBg= ItemSprite.getSiliverIconSprite()
      iconName = GetLocalizeStringBy("key_1687")
      local quality = ItemSprite.getSilverQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "soul") then
      -- 将魂
      iconBg= ItemSprite.getSoulIconSprite()
      iconName = GetLocalizeStringBy("key_1616")
      local quality = ItemSprite.getSoulQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "gold") then
      -- 金币
      iconBg= ItemSprite.getGoldIconSprite()
      iconName = GetLocalizeStringBy("key_1491")
      local quality = ItemSprite.getGoldQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "item") then
      -- 物品
      if (tonumber(cellValues.tid) >= 400001 and tonumber(cellValues.tid) <= 500000) then
        -- 特殊需求 点击武魂图标查看武将信息
        iconBg = ItemSprite.getHeroSoulSprite(tonumber(cellValues.tid),tView_menuPriority,layer_zOrder+1,tView_infoPriority)
        local itemData = ItemUtil.getItemById(cellValues.tid)
            iconName = itemData.name
            nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
        else
        -- 物品
        iconBg =  ItemSprite.getItemSpriteById(tonumber(cellValues.tid),nil, nil, nil, tView_menuPriority,2101,tView_infoPriority)
        local itemData = ItemUtil.getItemById(cellValues.tid)
            iconName = ItemUtil.getItemNameByTid(cellValues.tid)
            nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
        end
    elseif(cellValues.type == "hero") then
      -- 英雄
      require "db/DB_Heroes"
      -- iconBg = HeroPublicCC.getCMISHeadIconByHtid(cellValues.tid)
      iconBg = ItemSprite.getHeroIconItemByhtid(cellValues.tid,tView_menuPriority,layer_zOrder+1,tView_infoPriority)
      local heroData = DB_Heroes.getDataById(cellValues.tid)
      iconName = heroData.name
      nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
    elseif(cellValues.type == "prestige") then
      -- 声望
      iconBg= ItemSprite.getPrestigeSprite()
      iconName = GetLocalizeStringBy("key_2231")
      local quality = ItemSprite.getPrestigeQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif(cellValues.type == "jewel") then
      -- 魂玉
      iconBg= ItemSprite.getJewelSprite()
      iconName = GetLocalizeStringBy("key_1510")
      local quality = ItemSprite.getJewelQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif(cellValues.type == "execution") then
      -- 体力
      iconBg= ItemSprite.getExecutionSprite()
      iconName = GetLocalizeStringBy("key_1032")
      local quality = ItemSprite.getExecutionQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif(cellValues.type == "stamina") then
      -- 耐力
      iconBg= ItemSprite.getStaminaSprite()
      iconName = GetLocalizeStringBy("key_2021")
      local quality = ItemSprite.getStaminaQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif(cellValues.type == "honor") then
      -- 荣誉
      iconBg= ItemSprite.getHonorIconSprite()
      iconName = GetLocalizeStringBy("lcy_10040")
      local quality = ItemSprite.getHonorQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif(cellValues.type == "contri") then
      -- 贡献
      iconBg= ItemSprite.getContriIconSprite()
      iconName = GetLocalizeStringBy("lcy_10041")
      local quality = ItemSprite.getContriQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif(cellValues.type == "grain") then
      -- 贡献
      iconBg= ItemSprite.getGrainSprite()
      iconName = GetLocalizeStringBy("lcyx_101")
      local quality = ItemSprite.getGrainQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif(cellValues.type == "coin") then
      -- 神兵令
      iconBg= ItemSprite.getGodWeaponTokenSprite()
      iconName = GetLocalizeStringBy("lcyx_149")
      local quality = ItemSprite.getGodWeaponTokenSpriteQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif(cellValues.type == "zg") then
      -- 战功
      iconBg= ItemSprite.getBattleAchieIcon()
      iconName = GetLocalizeStringBy("lcyx_1819")
      local quality = ItemSprite.getBattleAchieQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif(cellValues.type == "tg_num") then
      -- 天工令
      iconBg= ItemSprite.getTianGongLingIcon()
      iconName = GetLocalizeStringBy("lic_1561")
      local quality = ItemSprite.getTianGongLingQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif(cellValues.type == "wm_num") then
      -- 争霸令
      iconBg= ItemSprite.getWmIcon()
      iconName = GetLocalizeStringBy("lcyx_1912")
      local quality = ItemSprite.getWmQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif(cellValues.type == "hellPoint") then
      -- 炼狱令
      iconBg= ItemSprite.getHellPointIcon()
      iconName = GetLocalizeStringBy("lcyx_1917")
      local quality = ItemSprite.getHellPointQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif ( cellValues.type == "cross_honor" ) then
      -- 跨服比武  add by yangrui 15-10-13
      iconBg = ItemSprite.getKFBWHonorIcon()
      iconName = GetLocalizeStringBy("yr_2002")
      local quality = ItemSprite.getKFBWHonorQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif ( cellValues.type == "fs_exp" ) then
        -- 战魂经验
      iconBg = ItemSprite.getFSExpIconSprite()
      iconName = GetLocalizeStringBy("lic_1736")
      local quality = ItemSprite.getFSExpQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif (cellValues.type == "jh") then
        -- 将星
        iconBg = ItemSprite.getHeroJhIcon()
      iconName = GetLocalizeStringBy("syx_1053")
      local quality = ItemSprite.getHeroJhQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      elseif (cellValues.type == "copoint") then
        -- 国战积分
        iconBg = ItemSprite.getCopointIcon()
      iconName = GetLocalizeStringBy("fqq_015")
      local quality = ItemSprite.getCopointQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
       elseif ( cellValues.type == "tally_point" ) then 
        -- 兵符积分
      iconBg = ItemSprite.getTallyPointIcon()
      iconName = GetLocalizeStringBy("syx_1072")
      local quality = ItemSprite.getTallyPointQuality()
          nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
      else

    end
    -- 物品数量
    if( tonumber(cellValues.num) > 1 )then
      local numberLabel = CCRenderLabel:create(tostring(cellValues.num),g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)-- modified by yangrui at 2015-12-03
      numberLabel:setColor(ccc3(0x00,0xff,0x18))
      numberLabel:setAnchorPoint(ccp(0,0))
      local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
      numberLabel:setPosition(ccp(width,5))
      iconBg:addChild(numberLabel,100)
    end

    --- desc 物品名字
    local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    descLabel:setColor(nameColor)
    descLabel:setAnchorPoint(ccp(0.5,1))
    descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,0))
    iconBg:addChild(descLabel)

    return iconBg
end

function createLastStarNode( itemData,a1 )
    local lastStarSprite = CCSprite:create()
    local lastStarLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_336"),g_sFontName,20)
          lastStarLabel:setAnchorPoint(ccp(0,0))
          lastStarLabel:setPosition(ccp(0,0))
    lastStarSprite:addChild(lastStarLabel)
    local starSprite = CCSprite:create("images/common/star.png")
          starSprite:setAnchorPoint(ccp(0,0))
          starSprite:setPosition(ccp(lastStarLabel:getContentSize().width,0))
    lastStarLabel:addChild(starSprite)
    local lastStarNumLabel = CCLabelTTF:create(itemData[a1+1][3],g_sFontName,21)
          lastStarNumLabel:setAnchorPoint(ccp(0,0))
          lastStarNumLabel:setPosition(ccp(starSprite:getContentSize().width,0))
    starSprite:addChild(lastStarNumLabel)
    lastStarSprite:setContentSize(CCSizeMake(lastStarLabel:getContentSize().width+starSprite:getContentSize().width+lastStarNumLabel:getContentSize().width,starSprite:getContentSize().height))
    return lastStarSprite
end

-- 创建物品列表
-- 参数 物品的列表
function createItemTableView( itemArr_data )
    local itemData = itemArr_data or {} 
    local lineNum = math.ceil(table.count(itemArr_data[1][1])/4)
    local sizeLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_342",1),g_sFontPangWa,21)
    local cellSize = CCSizeMake(575, 140*lineNum+sizeLabel:getContentSize().height*2)
    local h = LuaEventHandler:create(function(fn, table, a1, a2)  --创建
      local r
      if fn == "cellSize" then
        r = cellSize
      elseif fn == "cellAtIndex" then
        local rewardTable = {}
        local itemsTable={}
        local _rewardInfo = itemArr_data[a1+1][1]
        
        for k,v in pairs(_rewardInfo)do
            rewardData = DB_Overcome_chest.getDataById(tonumber(v))
            rewardTable[k] = rewardData.RewardItem
        end

        for i=1,#(rewardTable) do
          local rewardArrySp = ItemUtil.getItemsDataByStr(rewardTable[i])
          itemsTable[i] = rewardArrySp[1]
        end

        local itemNum = #itemsTable
        a2 = CCTableViewCell:create()
        local posArrX = {0.14,0.38,0.62,0.85}
        for i=1,itemNum do
          if(itemsTable[i] ~= nil)then
            local item_sprite = createRewardCell(itemsTable[i])
            item_sprite:setAnchorPoint(ccp(0.5,1))
            local arrNum = i%4
            if(arrNum==0)then
                arrNum = 4
            end
            item_sprite:setPosition(ccp(575*posArrX[arrNum],130*(lineNum+1-math.ceil(i/4))))
            a2:addChild(item_sprite)
          end
        end
        local numberLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_342",itemArr_data[a1+1].baseNum),g_sFontPangWa,23)
              numberLabel:setColor(ccc3(0x00,0xff,0x18))
              numberLabel:setAnchorPoint(ccp(0.5,1))
              numberLabel:setPosition(ccp(575*0.5,140*lineNum+numberLabel:getContentSize().height*2))
        a2:addChild(numberLabel)
        local leftFlower = CCScale9Sprite:create("images/godweaponcopy/longflower.png")
              leftFlower:setAnchorPoint(ccp(0.5,0.5))
              leftFlower:setPosition(ccp(numberLabel:getContentSize().width*0.5,numberLabel:getContentSize().height*0.5))
        numberLabel:addChild(leftFlower)
        local lastStarNode = createLastStarNode(itemData,a1)
              lastStarNode:setAnchorPoint(ccp(0.5,1))
              lastStarNode:setPosition(ccp(575*0.5,140*lineNum+numberLabel:getContentSize().height))
        a2:addChild(lastStarNode)
        r = a2
      elseif fn == "numberOfCells" then
        local num = #itemData
        r = num
        print("num is : ", num)
      elseif fn == "cellTouched" then
        
      elseif (fn == "scroll") then
        
      end
      return r
    end)

    local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(575, 340))
    goodTableView:setBounceable(true)
    goodTableView:setTouchPriority(-602)
    -- 上下滑动
    goodTableView:setDirection(kCCScrollViewDirectionVertical)
    goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)

    return goodTableView
end

function buyChestTimePart( ... )
    --购买宝箱块
    local bg = _dialog:getChildByTag(1)
          bg = tolua.cast(bg, "CCScale9Sprite")

    local title_bg = bg:getChildByTag(2)
          title_bg = tolua.cast(title_bg,"CCScale9Sprite")

    require "script/utils/BaseUI"
    
    --褐色背景
    _chestBgSprite = BaseUI.createContentBg(CCSizeMake(575,350))
    _chestBgSprite:setAnchorPoint(ccp(0.5,1))
    _chestBgSprite:setPosition(ccp(bg:getContentSize().width*0.5,bg:getContentSize().height - 20 - title_bg:getContentSize().height*0.5))
    _dialog:addChild(_chestBgSprite)
    local bgWidth   = _chestBgSprite:getContentSize().width
    local bgHeight  = _chestBgSprite:getContentSize().height

    -- 物品列表
    local myTableView = createItemTableView(_itemResult)
    myTableView:setPosition(ccp(5, 5))
    _chestBgSprite:addChild(myTableView)
end

function createBuffNode( pData,pStarNum)
    -- body
    local buffSprite = CCSprite:create()
          buffSprite:setAnchorPoint(ccp(0,1))
    local buffNameLabel = CCLabelTTF:create(pData.name,g_sFontName,20)
          buffNameLabel:setPosition(ccp(0,0))
    buffSprite:addChild(buffNameLabel)
    --星星图片
    local starSprite = CCSprite:create("images/common/star_big.png")
          starSprite:setAnchorPoint(ccp(0,0.5))
          starSprite:setPosition(ccp(buffNameLabel:getContentSize().width,buffNameLabel:getContentSize().height*0.5))
    buffSprite:addChild(starSprite)
    
    --消耗星星数量
    local starNumLabel = CCRenderLabel:create(pStarNum,g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
          starNumLabel:setColor(ccc3(0xff,0xff,0xff))
          starNumLabel:setAnchorPoint(ccp(0.5,0.5))
          starNumLabel:setPosition(ccp(starSprite:getContentSize().width*0.5,starSprite:getContentSize().height*0.5))
    starSprite:addChild(starNumLabel)
    buffSprite:setContentSize(CCSizeMake(buffNameLabel:getContentSize().width+starSprite:getContentSize().width,buffNameLabel:getContentSize().height))
    return buffSprite
end

-- 创建buff列表
-- 参数 buff的列表
function createBuffTableView( itemArr_data )
    local itemData = itemArr_data or {} 
    local cellSize = CCSizeMake(575, 190)
    local buyBuffLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_337"),g_sFontName,20)
          buyBuffLabelWidth = buyBuffLabel:getContentSize().width
    local posXArry = {buyBuffLabelWidth*2,buyBuffLabelWidth*3.5,buyBuffLabelWidth*2}
    local h = LuaEventHandler:create(function(fn, ptable, a1, a2)  --创建
      local r
      if fn == "cellSize" then
        r = cellSize
      elseif fn == "cellAtIndex" then
        a2 = CCTableViewCell:create()

        local numberLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_342",itemData[a1+1].baseNum),g_sFontPangWa,23)
              numberLabel:setColor(ccc3(0x00,0xff,0x18))
              numberLabel:setAnchorPoint(ccp(0.5,1))
              numberLabel:setPosition(ccp(575*0.5,190))
        a2:addChild(numberLabel)

        local leftFlower = CCScale9Sprite:create("images/godweaponcopy/longflower.png")
              leftFlower:setAnchorPoint(ccp(0.5,0.5))
              leftFlower:setPosition(ccp(numberLabel:getContentSize().width*0.5,numberLabel:getContentSize().height*0.5))
        numberLabel:addChild(leftFlower)

        local buyBuffLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_337"),g_sFontName,20)
              buyBuffLabel:setAnchorPoint(ccp(0,1))
              buyBuffLabel:setPosition(ccp(buyBuffLabelWidth,190-numberLabel:getContentSize().height*2))
        a2:addChild(buyBuffLabel)
        local posYArry = {190-numberLabel:getContentSize().height*2,190-numberLabel:getContentSize().height*2,190-numberLabel:getContentSize().height*4}
        local buffTable = itemData[a1+1][2]

        if(not table.isEmpty(buffTable))then
            for i=1,3 do
                if(buffTable[i]~=nil and buffTable[i]~={})then
                    local buffData = DB_Overcome_buff.getDataById(tonumber(buffTable[i][1]))
                    local buffLabel = createBuffNode(buffData,buffTable[i][2])
                          buffLabel:setPosition(ccp(posXArry[i],posYArry[i]))
                    a2:addChild(buffLabel,1,i)
                else
                    local buffLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_332"),g_sFontName,20)
                          buffLabel:setPosition(ccp(posXArry[i],posYArry[i]))
                          buffLabel:setVisible(false)
                    a2:addChild(buffLabel,1,i)
                end
            end
            local lastStarLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_336"),g_sFontName,20)
                  lastStarLabel:setAnchorPoint(ccp(0,1))
                  lastStarLabel:setPosition(ccp(buyBuffLabelWidth,190-numberLabel:getContentSize().height*5))
            a2:addChild(lastStarLabel)
            local starSprite = CCSprite:create("images/common/star.png")
                  starSprite:setAnchorPoint(ccp(0,1))
                  starSprite:setPosition(ccp(lastStarLabel:getContentSize().width,lastStarLabel:getContentSize().height))
            lastStarLabel:addChild(starSprite)
            local lastStarNumLabel = CCLabelTTF:create(itemData[a1+1][3],g_sFontName,20)
                  lastStarNumLabel:setAnchorPoint(ccp(0,0.5))
                  lastStarNumLabel:setPosition(ccp(starSprite:getContentSize().width,starSprite:getContentSize().height*0.5))
            starSprite:addChild(lastStarNumLabel)
        else
            print("没有buff的时候")
            local noneLabel = CCLabelTTF:create(GetLocalizeStringBy("lic_1223"),g_sFontName,20)
                  noneLabel:setAnchorPoint(ccp(0,0))
                  noneLabel:setPosition(ccp(buyBuffLabel:getContentSize().width,0))
            buyBuffLabel:addChild(noneLabel)
            local lastStarLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_336"),g_sFontName,20)
                  lastStarLabel:setAnchorPoint(ccp(0,1))
                  lastStarLabel:setPosition(ccp(0,-buyBuffLabel:getContentSize().height))
            buyBuffLabel:addChild(lastStarLabel)
            local starSprite = CCSprite:create("images/common/star.png")
                  starSprite:setAnchorPoint(ccp(0,1))
                  starSprite:setPosition(ccp(lastStarLabel:getContentSize().width,lastStarLabel:getContentSize().height))
            lastStarLabel:addChild(starSprite)
            local lastStarNumLabel = CCLabelTTF:create(itemData[a1+1][3],g_sFontName,20)
                  lastStarNumLabel:setAnchorPoint(ccp(0,0.5))
                  lastStarNumLabel:setPosition(ccp(starSprite:getContentSize().width,starSprite:getContentSize().height*0.5))
            starSprite:addChild(lastStarNumLabel)
        end
        r = a2
      elseif fn == "numberOfCells" then
        local num = #itemData
        r = num
        print("num is : ", num)
      elseif fn == "cellTouched" then
        
      elseif (fn == "scroll") then
        
      end
      return r
    end)

    local goodTableView = LuaTableView:createWithHandler(h, CCSizeMake(575, 190))
    goodTableView:setBounceable(true)
    goodTableView:setTouchPriority(-602)
    -- 上下滑动
    goodTableView:setDirection(kCCScrollViewDirectionVertical)
    goodTableView:setVerticalFillOrder(kCCTableViewFillTopDown)

    return goodTableView
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

    -- buff列表
    local myTableView = createBuffTableView(_buffResult)
    myTableView:setPosition(ccp(5, 5))
    _buffBgSprite:addChild(myTableView)
end

function sweepAction( tag,item )
    -- body
    local isBuyBuff = 0
    if(_isChoose)then
        isBuyBuff = 1
    end

    local args = CCArray:create()
          args:addObject(CCInteger:create(tonumber(_curNumber)))
          args:addObject(CCInteger:create(isBuyBuff))
    GodWeaponCopyService.sweep(afterSweep,args)
end

function bottomItemMenu()
    local bg = _dialog:getChildByTag(1)
          bg = tolua.cast(bg, "CCScale9Sprite")
    local menu = CCMenu:create()
          menu:setTouchPriority(_touch_priority - 1)
          menu:setPosition(ccp(0,0))
    bg:addChild(menu)
    --手动按钮
    local acceptItem = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("lic_1097"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
          acceptItem:setAnchorPoint(ccp(0.5,0))
          acceptItem:setPosition(ccp(bg:getContentSize().width*0.5,10))
          acceptItem:registerScriptTapHandler(closeCallback)
    menu:addChild(acceptItem)
end

function createNumLabel( ... )
    local bg = _dialog:getChildByTag(1)
          bg = tolua.cast(bg, "CCScale9Sprite")

    local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_338"),g_sFontName,30)
          tipLabel:setColor(ccc3(0x78,0x25,0x00))
          tipLabel:setAnchorPoint(ccp(0.5,0))
          tipLabel:setPosition(ccp(bg:getContentSize().width*0.5,tipLabel:getContentSize().height*2.6))
    bg:addChild(tipLabel)
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
    require "script/ui/godweapon/godweaponcopy/GodWeaponCopyMainLayer"
    local pLayer = GodWeaponCopyMainLayer.createLayer()
    MainScene.setMainSceneViewsVisible(false,false,false)
    MainScene.changeLayer(pLayer,"GodWeaponCopyMainLayer")
end