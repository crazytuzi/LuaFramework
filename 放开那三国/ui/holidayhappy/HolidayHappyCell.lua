-- FileName: HolidayHappyCell.lua 
-- Author: fuqiongqiong
-- Date: 2016-5-27
-- Purpose: 节日狂欢Cell

module("HolidayHappyCell",package.seeall)
require "script/ui/holidayhappy/HolidayHappyDef"
require "script/ui/holidayhappy/HolidayHappyData"
require "script/ui/holidayhappy/HolidayHappyController"
require "script/ui/holidayhappy/HolidayHappyBuyLayer"

local _remainNum = nil

function createCell(pData,pIndex,pTouchpriority,pDay)
	local cell = CCTableViewCell:create()
	--cell背景
	local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
	local bg = CCScale9Sprite:create("images/common/bg/change_bg.png",fullRect, insetRect)
	bg:setPreferredSize(CCSizeMake(620,190))
    bg:setScale(g_fScaleX)
	cell:addChild(bg)
	local whiteBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
	whiteBg:setContentSize(CCSizeMake(437,130))
	whiteBg:setAnchorPoint(ccp(0,1))
	whiteBg:setPosition(ccp(20,145))
	bg:addChild(whiteBg)
    local str
    local strReward 
    if(tonumber(pData.bigtype) == HolidayHappyDef.kTypeOfTaskOne)  then
        str = pData.desc
        strReward = pData.reward
    elseif tonumber(pData.bigtype) == HolidayHappyDef.kTypeOfTaskFour then
        str = pData.sihgleDes
        strReward = pData.sihgleReward
    elseif tonumber(pData.bigtype) == HolidayHappyDef.kTypeOfTaskTwo then
        str = ""
        strReward = pData.discount 
    end
	--任务名称
    local nameLabel = CCRenderLabel:create(str,g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
    nameLabel:setColor(ccc3(0xff,0xf6,0x00))
    nameLabel:setAnchorPoint(ccp(0,1))
    nameLabel:setPosition(ccp(40,bg:getContentSize().height-10))
    bg:addChild(nameLabel)
	local rewarddata = string.split(strReward,",")
	local contentWidth = table.count(rewarddata)*120
	local width = whiteBg:getContentSize().width*0.98
	local scrollView = CCScrollView:create()
    scrollView:setContentSize(CCSizeMake(contentWidth, 180))
    scrollView:setViewSize(CCSizeMake(width, 180))
    scrollView:ignoreAnchorPointForPosition(false)
    scrollView:setAnchorPoint(ccp(0,0))
    scrollView:setPosition(ccp(0,-whiteBg:getContentSize().height*0.45))
    scrollView:setTouchPriority(pTouchpriority - 4)
    scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    whiteBg:addChild(scrollView)
    for k,v in pairs(rewarddata) do
            local rewardInDb = ItemUtil.getItemsDataByStr(rewarddata[k])
            local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], pTouchpriority-3, 3000, pTouchpriority-40,function ( ... )
        end,nil,nil,false)
       
        if tonumber(pData.bigtype) == HolidayHappyDef.kTypeOfTaskTwo then
             icon:setPosition(ccp(25*k+(k-1)*icon:getContentSize().width,30))
            whiteBg:addChild(icon)
        else
             icon:setPosition(ccp(25*k+(k-1)*icon:getContentSize().width,85))
             scrollView:addChild(icon)
        end
        local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        icon:addChild(nameLabel)
        nameLabel:setAnchorPoint(ccp(0.5,1))
        nameLabel:setColor(itemColor)
        nameLabel:setPosition(ccp(icon:getContentSize().width*0.57,0)) 
    end 
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(pTouchpriority - 5)
    bg:addChild(menuBar)
    local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
    local statues = HolidayHappyData.getStatusOfButton(pData.bigtype,pData.id,seasonNumOfClick)
     if(tonumber(pData.bigtype) == HolidayHappyDef.kTypeOfTaskOne) or (tonumber(pData.bigtype) == HolidayHappyDef.kTypeOfTaskFour) then
            --判断id在登陆奖励的范围，使这个范围内的东西走另一个判断
            if(tonumber(pData.id)>= 101001 and tonumber(pData.id) <= 101999)then
                --判断是领取按钮，已经领取 还是补签状态
                local buqianStatues = HolidayHappyData.buqianFunc(pData.id,seasonNumOfClick)
                if(buqianStatues == HolidayHappyDef.kTaskStausCanGet)then
                    
                        --可领取按钮
                         local reciveBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("fqq_062"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
                        reciveBtn:setAnchorPoint(ccp(1, 0.5))
                        reciveBtn:setPosition(ccp(bg:getContentSize().width-25, bg:getContentSize().height*0.5))
                        reciveBtn:registerScriptTapHandler(receiveCallBack)
                        menuBar:addChild(reciveBtn, 1, pData.id)
                    
                elseif buqianStatues == HolidayHappyDef.kTaskStausNotAchive then
                    --灰色可领取状态
                     --可领取按钮
                        -- local item = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png","images/common/btn/btn_blue_hui.png",
                        -- CCSizeMake(120,65))
                        -- item:setAnchorPoint(ccp(1,0.5))
                        -- item:setPosition(ccp(bg:getContentSize().width-25,bg:getContentSize().height*0.5))
                        -- bg:addChild(item)
                        -- --“领取”字
                        -- local buyLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_062"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
                        -- buyLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
                        -- buyLabel:setAnchorPoint(ccp(0.5,0.5))
                        -- buyLabel:setPosition(ccp(item:getContentSize().width *0.5,item:getContentSize().height *0.5))
                        -- item:addChild(buyLabel)
                        -- item:setEnabled(false)
                        -- buyLabel:setColor(ccc3(100,100,100))

                        local receiveBg = CCScale9Sprite:create("images/common/btn/btn_blue_hui.png")
                        receiveBg:setContentSize(CCSizeMake(120,65))
                        receiveBg:setAnchorPoint(ccp(1,0.5))
                        receiveBg:setPosition(ccp(bg:getContentSize().width-25,bg:getContentSize().height*0.5))
                        bg:addChild(receiveBg)
                        local buyLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_062"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
                        buyLabel:setColor(ccc3(0xff, 0xff, 0xff))
                        buyLabel:setAnchorPoint(ccp(0.5,0.5))
                        buyLabel:setPosition(ccp(receiveBg:getContentSize().width *0.5,receiveBg:getContentSize().height *0.5))
                        receiveBg:addChild(buyLabel)
                elseif buqianStatues == HolidayHappyDef.kTaskStausGot then
                    --已领取
                     local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
                    receive_alreadySp:setPosition(ccp(bg:getContentSize().width-25,bg:getContentSize().height*0.5))
                    receive_alreadySp:setAnchorPoint(ccp(1,0.5))
                    bg:addChild(receive_alreadySp)
                elseif buqianStatues == HolidayHappyDef.kTaskStausBuQian then
                    --补签
                    local reciveBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("fqq_057"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
                    reciveBtn:setAnchorPoint(ccp(1, 0.5))
                    reciveBtn:setPosition(ccp(bg:getContentSize().width-25, bg:getContentSize().height*0.5))
                    reciveBtn:registerScriptTapHandler(buqianCallBack)
                    menuBar:addChild(reciveBtn, 1, pData.id)
                end
            else

                local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
                local statues = HolidayHappyData.getStatusOfButton(pData.bigtype,pData.id,seasonNumOfClick)
                if(HolidayHappyDef.kTaskStausNotAchive == statues)then
                    --前往
                    local goBtn = CCMenuItemImage:create("images/newserve/qianwang-n.png","images/newserve/qiangwang-h.png")
                    goBtn:setAnchorPoint(ccp(1, 0.5))
                    goBtn:setPosition(ccp(bg:getContentSize().width-25, bg:getContentSize().height*0.5))
                    goBtn:registerScriptTapHandler(goCallBack)
                    menuBar:addChild(goBtn, 1, pData.id)
                elseif HolidayHappyDef.kTaskStausCanGet == statues then
                    --领取
                    local reciveBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("fqq_062"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
                    reciveBtn:setAnchorPoint(ccp(1, 0.5))
                    reciveBtn:setPosition(ccp(bg:getContentSize().width-25, bg:getContentSize().height*0.5))
                    reciveBtn:registerScriptTapHandler(receiveCallBack)
                    menuBar:addChild(reciveBtn, 1, pData.id)
                elseif HolidayHappyDef.kTaskStausGot == statues then
                    --已领取
                    local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
                    receive_alreadySp:setPosition(ccp(bg:getContentSize().width-25,bg:getContentSize().height*0.5))
                    receive_alreadySp:setAnchorPoint(ccp(1,0.5))
                    bg:addChild(receive_alreadySp)
                end 

               
                if(tonumber(pData.bigtype) == HolidayHappyDef.kTypeOfTaskOne)then
                    if(tonumber(pData.typeId) ~= 101)then
                        --任务类型1除了累积登陆的剩余次数显示
                        local str = GetLocalizeStringBy("fqq_116")
                        if(tonumber(pData.typeId) == 106 or tonumber(pData.typeId) == 107)then
                            str = GetLocalizeStringBy("fqq_117")
                        elseif tonumber(pData.typeId) == 108 or tonumber(pData.typeId) == 109 then
                            str = GetLocalizeStringBy("fqq_118")
                        end
                        remainTimes,allTimes = HolidayHappyData.getTaskTimes(pData.id,seasonNumOfClick)
                        local reaminLable = CCLabelTTF:create(str,g_sFontName,20)
                        reaminLable:setColor(ccc3(0x78,0x25,0x00))
                        reaminLable:setAnchorPoint(ccp(0,1))
                        reaminLable:setPosition(ccp(bg:getContentSize().width*0.65,bg:getContentSize().height*0.91))
                        bg:addChild(reaminLable)

                        local remainTimesLabel = CCLabelTTF:create(remainTimes,g_sFontName,21)
                        remainTimesLabel:setColor(ccc3(0x75,0x28,0x00))
                        remainTimesLabel:setAnchorPoint(ccp(0,0.5))
                        remainTimesLabel:setPosition(ccp(reaminLable:getContentSize().width,reaminLable:getContentSize().height*0.5))
                        reaminLable:addChild(remainTimesLabel)

                        local allTimesLabel = CCLabelTTF:create("/"..allTimes,g_sFontName,21)
                        allTimesLabel:setColor(ccc3(0x75,0x28,0x00))
                        allTimesLabel:setAnchorPoint(ccp(0,0.5))
                        allTimesLabel:setPosition(ccp(remainTimesLabel:getContentSize().width,remainTimesLabel:getContentSize().height*0.5))
                        remainTimesLabel:addChild(allTimesLabel)
                    end
                   
                end

                if (tonumber(pData.bigtype) == HolidayHappyDef.kTypeOfTaskFour) then
                    local remainTimes,canReceiveTimes,allTimes = HolidayHappyData.remainTimesOfRecharge(4,tonumber(pData.id),seasonNumOfClick)
                     if(remainTimes < 0)then
                        remainTimes = 0
                     end
                local reaminLable = CCLabelTTF:create(GetLocalizeStringBy("fqq_105"),g_sFontName,20)
                reaminLable:setColor(ccc3(0x78,0x25,0x00))
                reaminLable:setAnchorPoint(ccp(0,1))
                reaminLable:setPosition(ccp(bg:getContentSize().width*0.65,bg:getContentSize().height*0.91))
                bg:addChild(reaminLable)

                local remainTimesLabel = CCLabelTTF:create(remainTimes,g_sFontName,21)
                remainTimesLabel:setColor(ccc3(0x75,0x28,0x00))
                remainTimesLabel:setAnchorPoint(ccp(0,0.5))
                remainTimesLabel:setPosition(ccp(reaminLable:getContentSize().width,reaminLable:getContentSize().height*0.5))
                reaminLable:addChild(remainTimesLabel)

                local allTimesLabel = CCLabelTTF:create("/"..allTimes,g_sFontName,21)
                allTimesLabel:setColor(ccc3(0x75,0x28,0x00))
                allTimesLabel:setAnchorPoint(ccp(0,0.5))
                allTimesLabel:setPosition(ccp(remainTimesLabel:getContentSize().width,remainTimesLabel:getContentSize().height*0.5))
                remainTimesLabel:addChild(allTimesLabel)
                end
            
            end
    elseif  (tonumber(pData.bigtype) == HolidayHappyDef.kTypeOfTaskTwo)then
        local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
        normalSprite:setContentSize(CCSizeMake(120,65))
        local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
        selectSprite:setContentSize(CCSizeMake(120,65))
        local disSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_hui.png")
        disSprite:setContentSize(CCSizeMake(120,65))
        local item = CCMenuItemSprite:create(normalSprite,selectSprite,disSprite)
        item:setAnchorPoint(ccp(1,0.5))
        item:setPosition(ccp(bg:getContentSize().width-25,bg:getContentSize().height*0.5))
        menuBar:addChild(item,1,tonumber(pData.id))
        item:registerScriptTapHandler(buyCallback)
        --“购买”字
        local buyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1523"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
        buyLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
        buyLabel:setAnchorPoint(ccp(0.5,0.5))
        buyLabel:setPosition(ccp(item:getContentSize().width *0.5,item:getContentSize().height *0.5))
        item:addChild(buyLabel)
        local costStr = HolidayHappyData.getMoneyCost(pData.cost)
        --原价
    local richInfo1 = {
        lineAlignment = 2,
        labelDefaultColor = ccc3( 0xff, 0xf6, 0x00),
        labelDefaultFont = g_sFontName,
        labelDefaultSize = 24,
        defaultType = "CCRenderLabel",
        elements = {
            {
                ["type"] = "CCSprite",
                image = "images/common/gold.png",
            },
            {
                text = tonumber(costStr[1]),
                type = "CCRenderLabel",
                color = ccc3( 0xff, 0xf6, 0x00),
            }
        }
    }
    local priceLabel = GetLocalizeLabelSpriteBy_2("fqq_070", richInfo1)
    priceLabel:setAnchorPoint(ccp(0, 1))
    priceLabel:setPosition(ccp(100*1.8,whiteBg:getContentSize().height*0.8))
    whiteBg:addChild(priceLabel)

    
    --现价
    local richInfo2 = {
        lineAlignment = 2,
        labelDefaultColor = ccc3( 0xff, 0xf6, 0x00),
        labelDefaultFont = g_sFontName,
        labelDefaultSize = 24,
        defaultType = "CCRenderLabel",
        elements = {
            {
                ["type"] = "CCSprite",
                image = "images/common/gold.png",
            },
            {
                text = tonumber(costStr[2]),
                type = "CCRenderLabel",
                color = ccc3( 0xff, 0xf6, 0x00),
            }
        }
    }
    local priceLabel2 = GetLocalizeLabelSpriteBy_2("fqq_071", richInfo2)
    priceLabel2:setAnchorPoint(ccp(0, 1))
    priceLabel2:setPosition(ccp(100*1.8,whiteBg:getContentSize().height*0.75 - priceLabel:getContentSize().height))
    whiteBg:addChild(priceLabel2)
     --红色的划线
    local noSprite = CCSprite:create("images/recharge/limit_shop/no_more.png")
    noSprite:setAnchorPoint(ccp(0.5,0.5))
    noSprite:setPosition(ccp(priceLabel:getContentSize().width*0.5,priceLabel:getContentSize().height/2))
    priceLabel:addChild(noSprite)

    --lable可买几次
    local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
    _remainNum = HolidayHappyData.remainTimeOfBuy(pData,seasonNumOfClick)
    local remainTimeLabel1 = CCLabelTTF:create(GetLocalizeStringBy("fqq_102"),g_sFontName, 20)
    remainTimeLabel1:setColor(ccc3(0x78,0x25,0x00))
    remainTimeLabel1:setAnchorPoint(ccp(0,0))
    remainTimeLabel1:setPosition(ccp(item:getContentSize().width*0.2, -item:getContentSize().height*0.23))
    item:addChild(remainTimeLabel1)

    _remainTimeLabel = CCLabelTTF:create(_remainNum,g_sFontName,20)
    _remainTimeLabel:setColor(ccc3(0x78,0x25,0x00))
    _remainTimeLabel:setAnchorPoint(ccp(0,0.5))
    _remainTimeLabel:setPosition(ccp(remainTimeLabel1:getContentSize().width,remainTimeLabel1:getContentSize().height*0.5))
    remainTimeLabel1:addChild(_remainTimeLabel)

    local remainTimeLabel2 = CCLabelTTF:create(GetLocalizeStringBy("fqq_103"),g_sFontName,20)
    remainTimeLabel2:setColor(ccc3(0x78,0x25,0x00))
    remainTimeLabel2:setAnchorPoint(ccp(0,0.5))
    remainTimeLabel2:setPosition(ccp(_remainTimeLabel:getContentSize().width,_remainTimeLabel:getContentSize().height*0.5))
    _remainTimeLabel:addChild(remainTimeLabel2)

        --判断兑换次数是否已经用完
        if(HolidayHappyDef.kTaskStausGot == statues)then
            item:setEnabled(false)
        end
        if(_remainNum == 0)then
            item:setEnabled(false)
            buyLabel:setColor(ccc3(0xff,0xff,0xff))
        end
    end  
    return cell
end

--领取按钮的回调
function receiveCallBack( tag )
	 --判断背包
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
    -- 判断武将满了
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return
    end
    local callback = function ( ... )
        
    end
    HolidayHappyController.taskReward(tag,callback)
end

--前往按钮的回调
function goCallBack( taskId )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local seasonNum = HolidayHappyData.getSeasonNum()
    if(seasonNum == 0)then
        local rewardData = HolidayHappyData.getDataOfFestival_act()
        seasonNum = #rewardData
    end
     local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
    if(seasonNumOfClick > seasonNum)then
        --如果在第一季的时候点击了第二季的按钮，提示第二季活动还未开启
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_101"))
        return
    end
    -- 判断活动时间是否结束，结束的话弹出活动结束提示
    -- local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
    if HolidayHappyData.remineTimeOfSeasonStr(seasonNumOfClick) <= 0 then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_092"))
        return
    end
    if(taskId>= 105001 and taskId <= 105999)then --
        --跳转到比武
        local canEnter = DataCache.getSwitchNodeState( ksSwitchContest )
        if( canEnter ) then
            require "script/ui/match/MatchLayer"
            local matchLayer = MatchLayer.createMatchLayer()
            MainScene.changeLayer(matchLayer, "matchLayer")
        end
    elseif taskId>= 104001 and taskId <= 104999 then--
        --跳转夺宝
        require "script/ui/treasure/TreasureMainView"
        local canEnter = DataCache.getSwitchNodeState( ksSwitchRobTreasure )
        if( canEnter ) then
            local treasureLayer = TreasureMainView.create()
            MainScene.changeLayer(treasureLayer,"treasureLayer")
        end
    elseif taskId>= 102001 and taskId <= 102999 then --
        --跳转到副本
        require "script/ui/copy/CopyLayer"
        local copyLayer = CopyLayer.createLayer()
        MainScene.changeLayer(copyLayer, "copyLayer")

    elseif (taskId>= 103001 and taskId <= 103999) then
       --跳转到精英副本
       
        require "script/ui/copy/CopyLayer"
        if not (DataCache.getSwitchNodeState(  ksSwitchEliteCopy )) then 
            return
        end
        local copyLayer = CopyLayer.createLayer(nil,CopyLayer.Elite_Copy_Tag)
        MainScene.changeLayer(copyLayer, "copyLayer")
    elseif (taskId >= 107001 and taskId <= 107999) or (taskId >= 108001 and taskId <= 108999) or (taskId >= 109001 and taskId <= 109999) or (taskId >= 106001 and taskId <= 106999) then
        --跳转到精彩活动界面
        require "script/ui/rechargeActive/RechargeActiveMain"
        local layer = RechargeActiveMain.create()
       MainScene.changeLayer(layer,"layer")
    elseif (taskId >= 110001 and taskId <= 110999) then -- 
        --跳转到充值界面
        local layer = RechargeLayer.createLayer()
        local scene = CCDirector:sharedDirector():getRunningScene()
        scene:addChild(layer,1111)
    elseif(taskId >= 111001 and taskId <= 111999)then
        --跳转到竞技场
        local canEnter = DataCache.getSwitchNodeState( ksSwitchArena )
        if( canEnter ) then
            require "script/ui/arena/ArenaLayer"
            local arenaLayer = ArenaLayer.createArenaLayer()
            MainScene.changeLayer(arenaLayer, "arenaLayer")
        end 
    elseif(taskId >= 112001 and taskId <= 112999) then
        --跳转到七星台
        local canEnter =  DataCache.getSwitchNodeState(ksSwitchSevenLottery)
        if( canEnter ) then
            require "script/ui/sevenlottery/SevenLotteryLayer"
            local layer = SevenLotteryLayer.showLayer()
            MainScene.changeLayer(layer, "layer")
        end 
    end
end

--购买按钮的回调
function buyCallback( tag )
    local seasonNum = HolidayHappyData.getSeasonNum()
    if(seasonNum == 0)then
        local rewardData = HolidayHappyData.getDataOfFestival_act()
        seasonNum = #rewardData
    end
     local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
    if(seasonNumOfClick > seasonNum)then
        --如果在第一季的时候点击了第二季的按钮，提示第二季活动还未开启
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_101"))
        return
    end
    -- local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
    if tonumber(HolidayHappyData.remineTimeOfSeasonStr(seasonNumOfClick)) <= 0 then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_114"))
        return
    end
   
    --判断当前属于第几季
    local seasonNum = HolidayHappyData.getSeasonNum()
    if(seasonNum ==0)then
        local rewardData = HolidayHappyData.getDataOfFestival_act()
        seasonNum = #rewardData
    end
    --判断当前按钮点击在第一季还是第二季
    local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
    if(seasonNumOfClick < seasonNum)then
         require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_114"))
        return
    end
    HolidayHappyBuyLayer.showPurchaseLayer(tag,1)
end

--刷新商品折扣的次数
function refreshNumOfBuy( num )
    _remainNum = _remainNum - num
    _remainTimeLabel:setString(_remainNum)
end

--补签按钮回调
function buqianCallBack( tag )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

    if 20 > UserModel.getGoldNumber() then
        AnimationTip.showTip(GetLocalizeStringBy("key_1092"))
        return
    end
    --判断背包
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
    -- 判断武将满了
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return
    end     
    local callbackFunc = function ( ... )
       local callback = function ( ... )
            -- body
        end
        HolidayHappyController.signReward(tag,callback)
    end
          local richInfo = {
            elements = {
                
                {
                    text = 20
                },
    
            }
        }   
        local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("fqq_113"),richInfo)  
        local alertCallback = function ( isConfirm, _argsCB )
            if not isConfirm then
                return
            end
            callbackFunc()
        end
        require "script/ui/tip/RichAlertTip"
        RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil, nil, nil, true)  --字是“确定”
    
end