-- Filename：	DigCowryLayer.lua
-- Author：		Li Pan
-- Date：		2014-1-8
-- Purpose：		挖宝

module("DigCowryLayer", package.seeall)

require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/utils/BaseUI"

require "script/ui/digCowry/DigCowryData"
require "script/ui/digCowry/DigCowryNet"

require "script/model/utils/ActivityConfig"

--图片路径
local iPath = "images/digCowry/"

--cclayer
local baseLayer = nil
--免费次数label
local normalDesNode1 = nil
--剩余探宝次数
local normalDesNode2 = nil

--每次花费
local digPriceLabel = nil

--剩余时间label
local leftDigTime = nil
local scheduleTag  = nil

--剩余金币
local goldLeftLabel = nil

--挖宝种类,1，表示 一次挖，2 表示多次挖
local digType = nil
--挖10次 需要金币的label
local costGoldLabel = nil

--挖宝cd
local digCD = nil
local maskLayer       = nil 


-- 查看物品信息返回回调 为了显示下排按钮
local function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, false, false)
end

--创建
function createDigCowry( ... )
    local nowTime = BTUtil:getSvrTimeInterval()
    local endTime = ActivityConfig.ConfigCache.robTomb.end_time
    local beginTime = ActivityConfig.ConfigCache.robTomb.start_time 
    if(nowTime < beginTime) or (nowTime > endTime) then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert(GetLocalizeStringBy("key_3368"), nil)
        return
    end
    print("ActivityConfig.ConfigCache.robTomb is >>>>")
    print_t(ActivityConfig.ConfigCache.robTomb)

	baseLayer = CCLayer:create()
    baseLayer:registerScriptHandler(onNodeEvent)

	DigCowryNet.getDigInfo(createUI)


	return  baseLayer
end

function createUI( ... )
	local background = CCScale9Sprite:create("images/digCowry/dig_bg.jpg")
    background:setScale((MainScene.bgScale))
    background:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
    background:setAnchorPoint(ccp(0.5, 0.5))
    baseLayer:addChild(background)

    local title = CCSprite:create(iPath.."dig_title.png")
    baseLayer:addChild(title)
    title:setAnchorPoint(ccp(0.5, 0.5))
    title:setPosition(ccp(g_winSize.width/2, g_winSize.height - 240*g_fElementScaleRatio))
    title:setScale(g_fElementScaleRatio)

--当前金币
    local leftTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1099"), g_sFontName, 21, 1.5, ccc3(0, 0, 0), type_stroke)
    leftTimeLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    leftTimeLabel:setAnchorPoint(ccp(0, 0.5))
    baseLayer:addChild(leftTimeLabel)
    leftTimeLabel:setPosition(ccp(10*g_fElementScaleRatio, g_winSize.height - 200*g_fScaleX))
    leftTimeLabel:setScale(g_fElementScaleRatio)

    local goldIcon = CCSprite:create("images/common/gold.png")
    leftTimeLabel:addChild(goldIcon,1,90904)
    goldIcon:setPosition(ccp(leftTimeLabel:getContentSize().width, leftTimeLabel:getContentSize().height/2))
    goldIcon:setAnchorPoint(ccp(0, 0.5))

    local goldNum = UserModel.getGoldNumber()
    goldLeftLabel = CCLabelTTF:create(goldNum, g_sFontName, 21)
    goldLeftLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    goldLeftLabel:setAnchorPoint(ccp(0, 0.5))
    leftTimeLabel:addChild(goldLeftLabel)
    goldLeftLabel:setPosition(ccp(leftTimeLabel:getContentSize().width + 30, leftTimeLabel:getContentSize().height/2))

--剩余时间
    local leftTimeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3201"), g_sFontName, 21, 1.5, ccc3(0, 0, 0), type_stroke)
    leftTimeLabel:setColor(ccc3(0x00, 0xff, 0x18))
    leftTimeLabel:setAnchorPoint(ccp(0, 0.5))
    baseLayer:addChild(leftTimeLabel)
    leftTimeLabel:setPosition(ccp(g_winSize.width - 150*g_fElementScaleRatio, g_winSize.height - 300*g_fScaleX))
    leftTimeLabel:setScale(g_fElementScaleRatio)

    local nowTime = BTUtil:getSvrTimeInterval()
    local endTime = ActivityConfig.ConfigCache.robTomb.end_time
    local leftTimeData = tonumber(endTime - nowTime)
    leftTimeData = TimeUtil.getTimeString(leftTimeData)
    leftDigTime = CCLabelTTF:create(leftTimeData, g_sFontName, 21)
    leftDigTime:setColor(ccc3(0xff, 0xff, 0xff))
    leftDigTime:setAnchorPoint(ccp(0.5, 1))
    leftTimeLabel:addChild(leftDigTime)
    leftDigTime:setPosition(ccp(leftTimeLabel:getContentSize().width/2, -10))
    scheduleTag = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(changeLeftTime, 1, false)        

   --预览按钮
    local preMenu = CCMenu:create()
    preMenu:setPosition(ccp(0, 0))
    baseLayer:addChild(preMenu)
    local normalSprite  = CCSprite:create(iPath.."cowry_info_1.png")
    local selectSprite  = CCSprite:create(iPath.."cowry_info_2.png")
    local closeButton = CCMenuItemSprite:create(normalSprite,selectSprite)
    closeButton:setPosition(g_winSize.width - 100*g_fElementScaleRatio, g_winSize.height - 230*g_fScaleX)
    closeButton:setAnchorPoint(ccp(0.5, 0.5))
    closeButton:registerScriptTapHandler(prePrize)
    closeButton:setScale(g_fElementScaleRatio)
    preMenu:addChild(closeButton, 9999)
    preMenu:setTouchPriority(- 100)

-- 挖宝按钮 1次
    local dig1Sprite  = CCSprite:create(iPath.."dig_icon2.png")
    local dig2Sprite  = CCSprite:create(iPath.."dig_icon1.png")
    local dig1Item = CCMenuItemSprite:create(dig1Sprite,dig2Sprite)
    dig1Item:setPosition(g_winSize.width*0.2, 300*g_fElementScaleRatio)
    dig1Item:setAnchorPoint(ccp(0.5, 0.5))
    dig1Item:registerScriptTapHandler(digCowry)
    preMenu:addChild(dig1Item, 9999,1)
    dig1Item:setScale(g_fElementScaleRatio)

    --描述label1
    local needGold = ActivityConfig.ConfigCache.robTomb.data[1].GoldCost
    digPriceLabel = CCRenderLabel:create(needGold, g_sFontName, 21, 1.5, ccc3(0, 0, 0), type_stroke)
    digPriceLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    digPriceLabel:setAnchorPoint(ccp(0.5, 0.5))
    dig1Item:addChild(digPriceLabel)
    digPriceLabel:setPosition(ccp(dig1Item:getContentSize().width - 20, - 20))
    digPriceLabel:setVisible(false)

    local goldSp1 = CCSprite:create("images/common/gold.png")
    digPriceLabel:addChild(goldSp1,1,90904)
    goldSp1:setPosition(ccp(-40, digPriceLabel:getContentSize().height/2))
    goldSp1:setAnchorPoint(ccp(0, 0.5))


    local freeLabel = createFreeLabel()
    freeLabel:setAnchorPoint(ccp(0.5, 0.5))
    freeLabel:setPosition(dig1Item:getContentSize().width/2, - 20)
    dig1Item:addChild(freeLabel)
 
--金币挖宝 5次
    local dig3Sprite  = CCSprite:create(iPath.."ten_dig1.png")
    local dig4Sprite  = CCSprite:create(iPath.."ten_dig2.png")
    local dig2Item = CCMenuItemSprite:create(dig3Sprite,dig4Sprite)
    dig2Item:setPosition(g_winSize.width*0.5, 300*g_fElementScaleRatio)
    dig2Item:setAnchorPoint(ccp(0.5, 0.5))
    dig2Item:registerScriptTapHandler(digCowry)
    preMenu:addChild(dig2Item, 9999,2)
    dig2Item:setScale(g_fElementScaleRatio)

    local goldSp = CCSprite:create("images/common/gold.png")
    dig2Item:addChild(goldSp,1,90904)
    goldSp:setPosition(ccp(0, -20))
    goldSp:setAnchorPoint(ccp(0, 0.5))

    local costGoldLabel2 = CCRenderLabel:create(needGold * 5, g_sFontName, 21, 1.5, ccc3(0, 0, 0), type_stroke)
    costGoldLabel2:setColor(ccc3(0xff, 0xf6, 0x00))
    costGoldLabel2:setAnchorPoint(ccp(0, 0.5))
    dig2Item:addChild(costGoldLabel2)
    costGoldLabel2:setPosition(ccp(40, -20))

--金币挖宝 20次
    local dig5Sprite  = CCSprite:create(iPath.."dig_n.png")
    local dig6Sprite  = CCSprite:create(iPath.."dig_h.png")
    local dig3Item = CCMenuItemSprite:create(dig5Sprite,dig6Sprite)
    dig3Item:setPosition(g_winSize.width*0.8, 300*g_fElementScaleRatio)
    dig3Item:setAnchorPoint(ccp(0.5, 0.5))
    dig3Item:registerScriptTapHandler(digCowry)
    preMenu:addChild(dig3Item, 9999,3)
    dig3Item:setScale(g_fElementScaleRatio)

    local goldSp = CCSprite:create("images/common/gold.png")
    dig3Item:addChild(goldSp,1,90904)
    goldSp:setPosition(ccp(0, -20))
    goldSp:setAnchorPoint(ccp(0, 0.5))
    
    local costGoldLabe3 = CCRenderLabel:create(needGold*20, g_sFontName, 21, 1.5, ccc3(0, 0, 0), type_stroke)
    costGoldLabe3:setColor(ccc3(0xff, 0xf6, 0x00))
    costGoldLabe3:setAnchorPoint(ccp(0, 0.5))
    dig3Item:addChild(costGoldLabe3)
    costGoldLabe3:setPosition(ccp(40, -20))

-- 剩余金币挖宝
    local leftGoldLabel = createDigLabel()
    leftGoldLabel:setAnchorPoint(ccp(0.5, 0.5))
    leftGoldLabel:setPosition(g_winSize.width/2, 205*g_fElementScaleRatio)
    baseLayer:addChild(leftGoldLabel)

--活动时间
    local fullRect = CCRectMake(0, 0, 41, 31)
    local insetRect = CCRectMake(20, 15, 1, 1)
    local timeBg = CCScale9Sprite:create("images/common/bg/9s_6.png", fullRect, insetRect)
    timeBg:setPreferredSize(CCSizeMake(570*g_fElementScaleRatio, 50*g_fElementScaleRatio))
    timeBg:setAnchorPoint(ccp(0.5, 0))
    timeBg:setPosition(ccp(g_winSize.width/2, 125*g_fScaleX))
    baseLayer:addChild(timeBg)

    local beginTime = ActivityConfig.ConfigCache.robTomb.start_time 
    require "script/utils/TimeUtil"
        --兼容东南亚英文版
    local beginString
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
        beginString = TimeUtil.getTimeToMin(beginTime)
    else
        beginString = TimeUtil.getTimeForDay(beginTime)
    end

    local endTime = ActivityConfig.ConfigCache.robTomb.end_time
        --兼容东南亚英文版
    local endString
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
        endString = TimeUtil.getTimeToMin(endTime)
    else
        endString = TimeUtil.getTimeForDay(endTime)
    end

    local freeLabels = {}
    freeLabels[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2826"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    freeLabels[1]:setColor(ccc3(0x00, 0xff, 0x18))

    freeLabels[2] = CCRenderLabel:create(beginString..GetLocalizeStringBy("key_2358")..endString, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    freeLabels[2]:setColor(ccc3(0xff, 0xff, 0xff))

    local labels = BaseUI.createHorizontalNode(freeLabels)
    labels:setScale(g_fElementScaleRatio)
    labels:setAnchorPoint(ccp(0, 0.5))
    labels:setPosition(20, timeBg:getContentSize().height/2)
    timeBg:addChild(labels)
end

--剩余免费挖宝
function createFreeLabel( ... )
    local freeLabels = {}
    freeLabels[1] = CCRenderLabel:create(GetLocalizeStringBy("key_1551"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    freeLabels[1]:setColor(ccc3(0xff, 0xff, 0xff))

    local vipArr = DB_Vip.getArrDataByField("level", UserModel.getVipLevel())
    local totalFreeTime = tonumber(vipArr[1].ernieFreeTimes)
    local useTime = tonumber(DigCowryData.digInfo.today_free_num)
    local leftFreeTime = totalFreeTime - useTime
    if(leftFreeTime <= 0) then
        leftFreeTime = 0
    end

    freeLabels[2] = CCRenderLabel:create(leftFreeTime, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    freeLabels[2]:setColor(ccc3(0x00, 0xff, 0x18))

    freeLabels[3] = CCRenderLabel:create(GetLocalizeStringBy("key_3010"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    freeLabels[3]:setColor(ccc3(0xff, 0xff, 0xff))

    local labelPare = nil
    if(normalDesNode1) then    
        labelPare = normalDesNode1:getParent()
        print("the labelPare is >>>>>>",labelPare)
        normalDesNode1:removeFromParentAndCleanup(true)
        normalDesNode1 = nil 
    end
    normalDesNode1 = BaseUI.createHorizontalNode(freeLabels)
    -- normalDesNode1:setScale(g_fElementScaleRatio)
    
    local leftFreeTime = totalFreeTime - useTime
    if(leftFreeTime <= 0) then
        digPriceLabel:setVisible(true)
        normalDesNode1:setVisible(false)
    end

    if(labelPare) then
        print("the labelPare is ")
        return normalDesNode1, labelPare    
    end
    return normalDesNode1
    
end

--剩余金币挖宝
function createDigLabel( ... )
    local vipArr = DB_Vip.getArrDataByField("level", UserModel.getVipLevel())
    local totalGoldTime = vipArr[1].ernieGoldTimes
    local userGoldTime = DigCowryData.digInfo.today_gold_num
    local leftGoldTime = tonumber(totalGoldTime) - tonumber(userGoldTime)
    print("the leftGoldTime is ",leftGoldTime)
    print("the userGoldTime is ",userGoldTime)

    local labelTabel2 = {}
    labelTabel2[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2705"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    labelTabel2[1]:setColor(ccc3(0xff, 0xff, 0xff))

    labelTabel2[2] = CCRenderLabel:create(leftGoldTime, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    labelTabel2[2]:setColor(ccc3(0x00, 0xff, 0x18))

    labelTabel2[3] = CCRenderLabel:create(GetLocalizeStringBy("key_3010"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    labelTabel2[3]:setColor(ccc3(0xff, 0xff, 0xff))

    if(normalDesNode2) then
        print("enter normalDesNode2")
        normalDesNode2:removeFromParentAndCleanup(true)
        normalDesNode2 = nil 
    end

    normalDesNode2 = BaseUI.createHorizontalNode(labelTabel2)
    normalDesNode2:setScale(g_fElementScaleRatio)
    return normalDesNode2
end

--预览
function prePrize( ... )
	local maskLayer = BaseUI.createMaskLayer(-500)
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(maskLayer,999,90901)

    local background = CCScale9Sprite:create("images/common/viewbg1.png")
    background:setContentSize(CCSizeMake(630, 800))
    background:setAnchorPoint(ccp(0.5, 0.5))
    background:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
    maskLayer:addChild(background)
    AdaptTool.setAdaptNode(background)

    --标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
    titlePanel:setAnchorPoint(ccp(0.5, 0.5))
    titlePanel:setPosition(background:getContentSize().width/2, background:getContentSize().height - 7 )
    background:addChild(titlePanel)

    local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2613"), g_sFontPangWa, 33, 1, ccc3(0,0,0))
    titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    local x = (titlePanel:getContentSize().width - titleLabel:getContentSize().width)/2
    local y = titlePanel:getContentSize().height - (titlePanel:getContentSize().height - titleLabel:getContentSize().height)/2
    titleLabel:setPosition(ccp(x , y))
    titlePanel:addChild(titleLabel)

--关闭按钮
    local closeMenu = CCMenu:create()
    closeMenu:setPosition(ccp(0, 0))
    background:addChild(closeMenu)
    local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeButton:setPosition(background:getContentSize().width * 0.95, background:getContentSize().height * 0.96)
    closeButton:setAnchorPoint(ccp(0.5, 0.5))
    closeButton:registerScriptTapHandler(closeButtonCallback)
    closeMenu:addChild(closeButton, 9999)
    closeMenu:setTouchPriority(-501)

    --活动说明
    local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2934"), g_sFontPangWa, 25, 1, ccc3(0xff, 0xff, 0xff))
    tipLabel:setPosition(ccp(background:getContentSize().width/2, background:getContentSize().height - 81))
    tipLabel:setColor(ccc3(0x25, 0x8b, 0x23))
    tipLabel:setAnchorPoint(ccp(0.5, 0))
    background:addChild(tipLabel)

    --提示
    local tipLabel1 = CCLabelTTF:create(GetLocalizeStringBy("key_2135"), g_sFontName, 21)
    tipLabel1:setPosition(ccp(20, background:getContentSize().height - 130))
    tipLabel1:setColor(ccc3(0x78, 0x25, 0x00))
    tipLabel1:setAnchorPoint(ccp(0, 0))
    background:addChild(tipLabel1)

    local tipLabel2 = CCLabelTTF:create(GetLocalizeStringBy("key_3195"), g_sFontName, 21)
    tipLabel2:setPosition(ccp(20, background:getContentSize().height - 160))
    tipLabel2:setColor(ccc3(0x78, 0x25, 0x00))
    tipLabel2:setAnchorPoint(ccp(0, 0))
    background:addChild(tipLabel2)

    -- local tipLabel3 = CCLabelTTF:create(GetLocalizeStringBy("key_2771"), g_sFontName, 21)
    -- tipLabel3:setPosition(ccp(20, background:getContentSize().height - 170))
    -- tipLabel3:setColor(ccc3(0x78, 0x25, 0x00))
    -- tipLabel3:setAnchorPoint(ccp(0, 0))
    -- background:addChild(tipLabel3)

    --bg
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local listBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect, insetRect)
    listBg:setPreferredSize(CCSizeMake(580, 570))
    listBg:setPosition(ccp(25, 45))
    background:addChild(listBg)
  
  --scrollview
    local scrollView = CCScrollView:create()
    scrollView:setViewSize(CCSizeMake(570, 550))
    scrollView:setTouchPriority(-501)
    print("the scrollview contentsize is "..scrollView:getContentSize().height)
   
    scrollView:setBounceable(true)
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setAnchorPoint(ccp(0, 0))
    scrollView:setPosition(ccp(0, 10))
    listBg:addChild(scrollView)

    local bSize = 0
    for i=1,5 do
        local itemInfo = getItemInfo(i)
        if(itemInfo) then
            local number = table.count(itemInfo)
            if(number > 4) then
                number = math.ceil((number - 4)/4)
                bSize = (230 + 140 * number) + bSize
                print("llllll number = ", number)
                print("llllll bSize = ", bSize)
            else
                bSize = 230 + bSize
                print("the bsize = ",bSize)
            end
        end
    end

    -- print("num = ", num)
    scrollView:setContentSize(CCSizeMake(570, bSize))
    scrollView:setContentOffset(ccp(0, scrollView:getViewSize().height - scrollView:getContentSize().height))

    local scrollLayer = CCLayer:create()
    scrollView:addChild(scrollLayer)
    scrollLayer:setPosition(ccp(0, 0))
    print("scrollView:setContentSize = ", scrollView:getContentSize().width, scrollView:getContentSize().height)
    local lastItemY = 0 
    local index = 1
    for i=5,1,-1 do
        local item1 = createPrizeItem(i)
        if(item1) then
            scrollView:addChild(item1)
            item1:setAnchorPoint(ccp(0.5, 0))
            if(index == 1) then
                item1:setPosition(ccp(scrollView:getContentSize().width/2, scrollView:getContentSize().height - item1:getContentSize().height))
                print("first")
            else
                print("is = ",i)
                item1:setPosition(ccp(scrollView:getContentSize().width/2, lastItemY - item1:getContentSize().height))
            end
            lastItemY = item1:getPositionY()

            index = index + 1

            print("+++++++++++++",i)
            print(" scrollView:getContentSize().height  == ",  scrollView:getContentSize().height )

            print("item1:getContentSize().height == ",item1:getContentSize().height)

            print(" lastItemY = ", lastItemY)
        end
    end
end

--得到宝物数量
function getItemInfo(tag)
    local showItemInfo = nil
    local showData = nil
    require "script/utils/LuaUtil"
    -- print("the tag is ",tag)
    if(tag == 1) then
        showData = ActivityConfig.ConfigCache.robTomb.data[1].showItems1
    elseif(tag == 2) then
        showData = ActivityConfig.ConfigCache.robTomb.data[1].showItems2
    elseif(tag == 3) then
        showData = ActivityConfig.ConfigCache.robTomb.data[1].showItems3
    elseif(tag == 4) then
        showData = ActivityConfig.ConfigCache.robTomb.data[1].showItems4
    elseif(tag == 5) then
        showData = ActivityConfig.ConfigCache.robTomb.data[1].showItems5
    end
    print("the showData is ")
    print_t(showData)
    if(not showData) or (showData == "") then
        showItemInfo = nil
    else
        showItemInfo = lua_string_split(showData, ",")    
    end
    -- if(showData) then
    --     showItemInfo = lua_string_split(showData, "|")    
    -- end
    return showItemInfo
end


function createPrizeItem(tag)
-- 设置数据
    local showItemInfo = getItemInfo(tag)
    print("createPrizeItem is ")
    print_t(showItemInfo)
    if(not showItemInfo) or (table.count(showItemInfo) == 0) or (showItemInfo[1] == "") then
        return nil
    end
    local prizeNum = table.count(showItemInfo)

--设置大小
    local bSize = nil
    print("the prizeNum is ",prizeNums)
    if(prizeNum < 5) then
        bSize = CCSizeMake(560, 230)
        cSize = CCSizeMake(520, 150)
        print("enter first")
    else
        local num = math.ceil((prizeNum - 4)/4)
        print("the num is ",num)
        bSize = CCSizeMake(560, 230 + 130 * num)
        cSize = CCSizeMake(520, 150 + 130 * num)
        print("fffff number = ", num)
        print("fffff bSize = ", bSize)
    end

    local fullRect = CCRectMake(0, 0, 116, 124)
    local insetRect = CCRectMake(30, 50, 1, 1)
    local listBg = CCScale9Sprite:create("images/reward/cell_back.png", fullRect, insetRect)
    listBg:setPreferredSize(bSize)

    local starBg = CCSprite:create("images/digCowry/star_bg.png")
    starBg:setAnchorPoint(ccp(0, 1))
    listBg:addChild(starBg)
    starBg:setPosition(ccp(0, listBg:getContentSize().height))


    for i=1,tag do
        local star = CCSprite:create("images/digCowry/star.png")
        starBg:addChild(star)
        star:setAnchorPoint(ccp(0.5, 0.5))
        star:setPosition(ccp(35 + 30*(i - 1), starBg:getContentSize().height/2))
    end

    local itemInfoSpite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
    itemInfoSpite:setContentSize(cSize)
    itemInfoSpite:setPosition(ccp(listBg:getContentSize().width*0.5, listBg:getContentSize().height*0.5 - 10))
    itemInfoSpite:setAnchorPoint(ccp(0.5, 0.5))
    listBg:addChild(itemInfoSpite)

   
    local j = 1
    require "script/ui/item/ItemSprite"
    for k,v in pairs(showItemInfo) do
        --物品 和 英雄
        local sprite = nil
        local heroData = lua_string_split(v, "|")  
        print("the heroData is ")
        print_t(heroData) 

        local itemData = nil
        local nameColor = nil
        local htid = tonumber(heroData[2])
        local htype = tonumber(heroData[1])
        print("the htid is ",heroData[2])
        print("the htype is ",heroData[1])
        require "script/ui/item/ItemSprite"
        if(1 == htype) then
            -- sprite = ItemSprite.getItemSpriteById(htid)
            sprite = ItemSprite.getItemSpriteById(htid,nil,showDownMenu, nil,-502,19001,-503)
            itemData = ItemUtil.getItemById(htid)
            nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
        elseif(2 == htype) then
            -- sprite = ItemSprite.getHeroIconItemByhtid(htid)
            sprite = ItemSprite.getHeroIconItemByhtid(htid,-502,19001,- 503)
            itemData = DB_Heroes.getDataById(htid)
            nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.star_lv)
        end
        itemInfoSpite:addChild(sprite)
        sprite:setAnchorPoint(ccp(0, 0.5))
        sprite:setPosition(ccp(20 + 125*(j-1), itemInfoSpite:getContentSize().height - 70))
        if(j > 4) then
            local num = math.ceil((j - 4)/4)
            local upNum = (j-1)%4
            sprite:setPosition(ccp(20 + 125*upNum, itemInfoSpite:getContentSize().height - 70 - 130 * num))
        end

        local itemNameLabel = CCRenderLabel:create(itemData.name, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        print("the itemData is >>>",itemData)
        print_t(itemData)
        if(htid > 80000 and htid < 90000) then
            local model_id = DB_Heroes.getDataById(tonumber(UserModel.getAvatarHtid())).model_id
            print("the model_id is"..model_id)
            local dressArray = lua_string_split(itemData.name, ",")
            print_t(dressArray)
            for k,v in pairs(dressArray) do
                local array = lua_string_split(v, "|")
                print("the array is")
                print_t(array)
                if(tonumber(array[1]) == tonumber(model_id)) then
                    itemNameLabel:setString(array[2])
                    break
                end
            end
        end
        -- local nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
        itemNameLabel:setColor(nameColor)
        itemNameLabel:setAnchorPoint(ccp(0.5,0.5))
        itemNameLabel:setPosition(ccp(sprite:getContentSize().width*0.5, - 10))
        sprite:addChild(itemNameLabel)

        j = j + 1
    end

    return listBg
end

function closeButtonCallback( ... )
    print("close closeButtonCallback")
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:removeChildByTag(90901, true)
end

--挖宝奖励
function createPrize(tag)
    digCD = 0

    -- 转换数据结构
    local rewardTab = DigCowryData.getRewardData(DigCowryData.DigCowryInfo)
    -- 展示
    require "script/ui/item/ReceiveReward"
    ReceiveReward.showRewardWindow( rewardTab, nil, 1010, -500, GetLocalizeStringBy("lic_1705") )
end

--改变剩余时间
function changeLeftTime( ... )
    local nowTime = BTUtil:getSvrTimeInterval()
    local endTime = ActivityConfig.ConfigCache.robTomb.end_time
    local leftTimeData = TimeUtil.getTimeString(endTime - nowTime)
    leftDigTime:setString(leftTimeData)

    if(tonumber(nowTime - endTime) >= 0) then
        --时间到了怎么办
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleTag)
    end
end

function createEffect( p_num, p_needCost )
    digCD = 1
    local ccDelegate=BTAnimationEventDelegate:create()
    ccDelegate:registerLayerEndedHandler(function (actionName, xmlSprite)
        print("effect end")
        digMoreTimes(p_num,p_needCost)
        if(maskLayer)then 
            maskLayer:removeFromParentAndCleanup(true)
            maskLayer = nil
        end
    end)
    if(maskLayer)then 
        maskLayer:removeFromParentAndCleanup(true)
        maskLayer = nil
    end
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    maskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
    runningScene:addChild(maskLayer, 10000)
    local sImgPath=CCString:create("images/digCowry/effect/chutou")
    local loadEffectSprite = CCLayerSprite:layerSpriteWithNameAndCount(sImgPath:getCString(), 1,CCString:create(""));
    loadEffectSprite:retain()
    loadEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
    loadEffectSprite:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
    baseLayer:addChild(loadEffectSprite, 99999)
    loadEffectSprite:release()
    loadEffectSprite:setScale(g_fBgScaleRatio)
    loadEffectSprite:setDelegate(ccDelegate)
end

--挖宝
function digCowry(tag, sender)
    print("the tag is ", tag) 
    if(digCD == 1) then
        return
    end
--判断时间到了不
    local nowTime = BTUtil:getSvrTimeInterval()
    local endTime = ActivityConfig.ConfigCache.robTomb.end_time
    local beginTime = ActivityConfig.ConfigCache.robTomb.start_time 
    if(nowTime < beginTime) or (nowTime > endTime) then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert(GetLocalizeStringBy("key_2447"), nil)
        return
    end
--判断背包是否满
    -- 物品背包满了
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
    -- 武将满了
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return
    end

    local vipArr = DB_Vip.getArrDataByField("level", UserModel.getVipLevel())
    local totalGoldTime = vipArr[1].ernieGoldTimes
    local userGoldTime = DigCowryData.digInfo.today_gold_num
    local leftGoldTime = tonumber(totalGoldTime) - tonumber(userGoldTime)

    if(tag == 1) then
        -- 点击1次
        digMoreTimesTip(1)
    elseif(tag == 2) then
        -- 点击 5次
        local useNum = 5
        if(leftGoldTime < 5)then
            useNum = leftGoldTime
        end
        digMoreTimesTip(useNum)
    elseif(tag == 3) then
        -- 点击20次
        local useNum = 20
        if(leftGoldTime < 20)then
            useNum = leftGoldTime
        end
        digMoreTimesTip(useNum)
    else
    end
end

--挖宝多次
function digMoreTimesTip( p_num )
    -- 免费次数
    local vipArr = DB_Vip.getArrDataByField("level", UserModel.getVipLevel())
    local totalFreeTime = tonumber(vipArr[1].ernieFreeTimes)
    local useTime = tonumber(DigCowryData.digInfo.today_free_num)
    local leftFreeTime = totalFreeTime - useTime

    -- 金币次数
    local vipArr = DB_Vip.getArrDataByField("level", UserModel.getVipLevel())
    local totalGoldTime = vipArr[1].ernieGoldTimes
    local userGoldTime = DigCowryData.digInfo.today_gold_num
    local leftGoldTime = tonumber(totalGoldTime) - tonumber(userGoldTime)
    local needGold = ActivityConfig.ConfigCache.robTomb.data[1].GoldCost

    -- 判断次数是否足够
    local useFreeNum = 0
    if(leftFreeTime > p_num)then
        useFreeNum = p_num
    else
        useFreeNum = leftFreeTime
    end
    local useGoldNum = p_num - useFreeNum
    -- if( useGoldNum > leftGoldTime ) then
    if( leftGoldTime <= 0 and p_num>1)then
        AlertTip.showAlert(GetLocalizeStringBy("key_2068"))
        return     
    elseif(leftFreeTime==0 and p_num==1)then
        AlertTip.showAlert(GetLocalizeStringBy("key_2068"))
        return
    end

    -- 需要花费的金币 金币是否够
    local needCost = (p_num - leftFreeTime)*needGold
    if( needCost < 0)then
        needCost = 0
    end
    if(UserModel.getGoldNumber() < needCost)then 
        require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
        return
    end

    -- 如果花费金币 进行二次确认
    if(p_num > 1 or needCost > 0 )then
        -- 优先消耗免费次数 您确定花费XX金币 挖XX次吗？
        local yesCallBack = function ( ... )
            createEffect(p_num,needCost)
        end

        local tipNode = CCNode:create()
        tipNode:setContentSize(CCSizeMake(400,100))
        local textInfo = {
                width = 400, -- 宽度
                alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
                labelDefaultFont = g_sFontName,      -- 默认字体
                labelDefaultSize = 25,          -- 默认字体大小
                labelDefaultColor = ccc3(0x78,0x25,0x00),
                linespace = 10, -- 行间距
                defaultType = "CCLabelTTF",
                elements =
                {   
                    {
                        type = "CCLabelTTF", 
                        text = needCost,
                        color = ccc3(0x78,0x25,0x00),
                    },
                    {
                        type = "CCSprite", 
                        image = "images/common/gold.png",
                    },
                    {
                        type = "CCLabelTTF", 
                        text = p_num,
                        color = ccc3(0x78,0x25,0x00),
                    }
                }
            }
        local tipDes = GetLocalizeLabelSpriteBy_2("lic_1704", textInfo)
        tipDes:setAnchorPoint(ccp(0.5, 0.5))
        tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
        tipNode:addChild(tipDes)
        require "script/ui/tip/TipByNode"
        TipByNode.showLayer(tipNode,yesCallBack,CCSizeMake(500,360))
    else
        createEffect(p_num,needCost)
    end
end

function digMoreTimes( p_num, p_needCost )
   
    -- 剩余免费次数
    local vipArr = DB_Vip.getArrDataByField("level", UserModel.getVipLevel())
    local totalFreeTime = tonumber(vipArr[1].ernieFreeTimes)
    local useFreeNum = tonumber(DigCowryData.digInfo.today_free_num)
    local leftFreeTime = totalFreeTime - useFreeNum

   -- 发送请求
    DigCowryNet.digCowry(function ( ... )

        -- 优先使用免费次数
        local useFreeNum = 0
        if(leftFreeTime > p_num)then
            useFreeNum = p_num
        else
            useFreeNum = leftFreeTime
        end

        if( useFreeNum > 0)then
            --修改免费次数
            DigCowryData.digInfo.today_free_num = tonumber(DigCowryData.digInfo.today_free_num) + useFreeNum

             --减次数
            local label,labelPare = createFreeLabel()
            labelPare:addChild(label)
            label:setAnchorPoint(ccp(0.5, 0.5))
            label:setPosition(labelPare:getContentSize().width/2, - 20)
        end

        -- 消耗金币次数
        local useGoldNum = p_num - useFreeNum
        if( useGoldNum > 0)then
            --修改金币次数数据
            local oneNeedGold = ActivityConfig.ConfigCache.robTomb.data[1].GoldCost
            local needGold = oneNeedGold * useGoldNum
            print("useGoldNum is  >>>>>> ",needGold,useGoldNum)
            DigCowryData.digInfo.today_gold_num = tonumber(DigCowryData.digInfo.today_gold_num) + useGoldNum
            UserModel.addGoldNumber(- tonumber(needGold))
            goldLeftLabel:setString(UserModel.getGoldNumber())
            --减次数
            local leftGoldLabel = createDigLabel()
            leftGoldLabel:setAnchorPoint(ccp(0.5, 0.5))
            leftGoldLabel:setPosition(g_winSize.width/2, 205*g_fElementScaleRatio)
            baseLayer:addChild(leftGoldLabel)
        end
        
        --展示界面
        createPrize()

    end, p_num, 2)
end

function onNodeEvent( eventType )
    if(eventType == "exit") then
        closeDig()
    end
end

function closeDig( ... )
    print("close digCowry")
    --图片路径
    iPath = "images/digCowry/"
--cclayer
    baseLayer = nil
--免费次数label
    normalDesNode1 = nil
--剩余探宝次数
    normalDesNode2 = nil
--剩余时间label
    leftDigTime = nil

    digPriceLabel = nil

    goldLeftLabel = nil

    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleTag)
    scheduleTag = nil

    digType = nil
    costGoldLabel = nil

    digCD = nil
end



