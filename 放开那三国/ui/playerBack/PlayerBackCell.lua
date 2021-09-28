-- FileName: PlayerBackCell.lua 
-- Author: fuqiongqiong
-- Date: 2016-8-19
-- Purpose: 老玩家回归活动cell

module("PlayerBackCell",package.seeall)
require "script/ui/playerBack/PlayerBackBuyLayer"
require "script/ui/bag/UseGiftLayer"

function createCell( pData,pIndex,pTouchpriority)
    local cell = CCTableViewCell:create()
    --cell背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local bg = CCScale9Sprite:create("images/common/bg/change_bg.png",fullRect, insetRect)
    bg:setPreferredSize(CCSizeMake(600,182))
    bg:setScale(g_fScaleX)
    cell:addChild(bg)
    local whiteBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
    whiteBg:setContentSize(CCSizeMake(437,130))
    whiteBg:setAnchorPoint(ccp(0,1))
    whiteBg:setPosition(ccp(20,145))
    bg:addChild(whiteBg)
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(pTouchpriority - 5)
    bg:addChild(menuBar)
    local str = ""
    local strReward = pData.reward
    if(tonumber(pData.type) == PlayerBackDef.kTypeOfTaskTwo)  then
        str = pData.desc
        strReward = pData.reward
    elseif tonumber(pData.type) == PlayerBackDef.kTypeOfTaskThree then
        str = pData.rechargedes
        strReward = pData.reward
    elseif tonumber(pData.type) == PlayerBackDef.kTypeOfTaskFour then
        str = ""
        strReward = pData.discountitem 
    end
    --任务名称
    local nameLabel = CCRenderLabel:create(str,g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
    nameLabel:setColor(ccc3(0xff,0xf6,0x00))
    nameLabel:setAnchorPoint(ccp(0,1))
    nameLabel:setPosition(ccp(40,bg:getContentSize().height-13))
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
        if tonumber(pData.bigtype) == PlayerBackDef.kTypeOfTaskFour then
             icon:setPosition(ccp(25*k+(k-1)*icon:getContentSize().width,30))
            whiteBg:addChild(icon)
        else
            if(pData.choice_award == 1)then
                --加or
                local number = #rewarddata
                icon:setPosition(ccp(25*k+(k-1)*icon:getContentSize().width+40*(k-1),85))
                scrollView:addChild(icon)
                if(number > k)then
                    local pictureOr = CCSprite:create("images/recharge/or.png")
                    pictureOr:setPosition(ccp(33*k +icon:getContentSize().width*k +(k-1)*pictureOr:getContentSize().width,110))
                    scrollView:addChild(pictureOr)
                end
                
            else
                icon:setPosition(ccp(25*k+(k-1)*icon:getContentSize().width,85))
                scrollView:addChild(icon) 
            end
            
        end
        local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        icon:addChild(nameLabel)
        nameLabel:setAnchorPoint(ccp(0.5,1))
        nameLabel:setColor(itemColor)
        nameLabel:setPosition(ccp(icon:getContentSize().width*0.5,0)) 
    end 

    -- 按钮显示(包含任务和单笔充值)
    if( tonumber(pData.type) == PlayerBackDef.kTypeOfTaskTwo or tonumber(pData.type) == PlayerBackDef.kTypeOfTaskThree)then
        local statues = PlayerBackData.getButtonStatues(tonumber(pData.id))
         if(PlayerBackDef.kTaskStausNotAchive == statues)then
            --前往
            local goBtn = CCMenuItemImage:create("images/newserve/qianwang-n.png","images/newserve/qiangwang-h.png")
            goBtn:setAnchorPoint(ccp(1, 0.5))
            goBtn:setPosition(ccp(bg:getContentSize().width-25, bg:getContentSize().height*0.5))
            goBtn:registerScriptTapHandler(goCallBack)
            menuBar:addChild(goBtn, 1, pData.id)
        elseif PlayerBackDef.kTaskStausCanGet == statues then
            --领取
            local reciveBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("fqq_062"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
            reciveBtn:setAnchorPoint(ccp(1, 0.5))
            reciveBtn:setPosition(ccp(bg:getContentSize().width-25, bg:getContentSize().height*0.5))
            reciveBtn:registerScriptTapHandler(receiveCallBack)
            menuBar:addChild(reciveBtn, 1, pData.id)
        elseif PlayerBackDef.kTaskStausGot == statues then
            --已领取
            local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
            receive_alreadySp:setPosition(ccp(bg:getContentSize().width-20,bg:getContentSize().height*0.5))
            receive_alreadySp:setAnchorPoint(ccp(1,0.5))
            bg:addChild(receive_alreadySp)
        end 
    end
    --剩余次数的显示规则
    if tonumber(pData.type) ~= PlayerBackDef.kTypeOfTaskFour then

        local str = GetLocalizeStringBy("fqq_105")
        if tonumber(pData.type) ~= PlayerBackDef.kTypeOfTaskThree then
            str = GetLocalizeStringBy("fqq_135")
        end
        local allTimes = PlayerBackData.allTimes(pData.id)
        local remainTimes = PlayerBackData.remainTimes(pData.id)
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
    else
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
        local costStr = PlayerBackData.getMoneyCost(pData.cost)
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
        local remainNum = PlayerBackData.remainTimes(pData.id)
        local remainTimeLabel1 = CCLabelTTF:create(GetLocalizeStringBy("fqq_102"),g_sFontName, 20)
        remainTimeLabel1:setColor(ccc3(0x78,0x25,0x00))
        remainTimeLabel1:setAnchorPoint(ccp(0,0))
        remainTimeLabel1:setPosition(ccp(item:getContentSize().width*0.2, -item:getContentSize().height*0.23))
        item:addChild(remainTimeLabel1)

        local remainTimeLabel = CCLabelTTF:create(remainNum,g_sFontName,20)
        remainTimeLabel:setColor(ccc3(0x78,0x25,0x00))
        remainTimeLabel:setAnchorPoint(ccp(0,0.5))
        remainTimeLabel:setPosition(ccp(remainTimeLabel1:getContentSize().width,remainTimeLabel1:getContentSize().height*0.5))
        remainTimeLabel1:addChild(remainTimeLabel)

        local remainTimeLabel2 = CCLabelTTF:create(GetLocalizeStringBy("fqq_103"),g_sFontName,20)
        remainTimeLabel2:setColor(ccc3(0x78,0x25,0x00))
        remainTimeLabel2:setAnchorPoint(ccp(0,0.5))
        remainTimeLabel2:setPosition(ccp(remainTimeLabel:getContentSize().width,remainTimeLabel:getContentSize().height*0.5))
        remainTimeLabel:addChild(remainTimeLabel2)

        if(remainNum == 0)then
            item:setEnabled(false)
            buyLabel:setColor(ccc3(0xff,0xff,0xff))
        end
    end  
    return cell
end

--领取奖励回调
function receiveCallBack( tag )
    if( PlayerBackData.isPlayerBackOver())then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_114"))
        return
    end
    --判断背包
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
    local pRewardData = PlayerBackData.getRewardInfo(tag)
    --是否需要多选一
    local isChoose = pRewardData.choice_award --0 为不需要  1需要
    if(isChoose == 0)then
         PlayerBackController.gainReward(tonumber(pRewardData.id),0,nil)
     else
        local strReward = pRewardData.reward
        UseGiftLayer.showTipLayer(nil,strReward,function( rewardId )
        PlayerBackController.gainReward(tonumber(pRewardData.id),rewardId,nil)
    end)
    end
     
end

--购买商品回调
function buyCallback( tag )
    if( PlayerBackData.isPlayerBackOver())then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_114"))
        return
    end
    PlayerBackBuyLayer.showPurchaseLayer(tag)
end

--活动前往回调
function goCallBack( taskId )
    --加一个判断条件  活动结束时，加提示 然后return掉
    if( PlayerBackData.isPlayerBackOver())then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_092"))
        return
    end
   local data = PlayerBackData.getRewardInfo(taskId)
   if(tonumber(data.typeId) == 102)then
        --普通副本
        require "script/ui/copy/CopyLayer"
        local copyLayer = CopyLayer.createLayer()
        MainScene.changeLayer(copyLayer, "copyLayer")
    elseif tonumber(data.typeId) == 103 then
        --精英副本
         require "script/ui/copy/CopyLayer"
        if not (DataCache.getSwitchNodeState(  ksSwitchEliteCopy )) then 
            return
        end
        local copyLayer = CopyLayer.createLayer(nil,CopyLayer.Elite_Copy_Tag)
        MainScene.changeLayer(copyLayer, "copyLayer")
    elseif tonumber(data.typeId) == 104 then
        --占星
        if not DataCache.getSwitchNodeState(ksSwitchStar) then
            return
        end
        require "script/ui/astrology/AstrologyLayer"
        local astrologyLayer = AstrologyLayer.createAstrologyLayer()
        MainScene.changeLayer(astrologyLayer, "AstrologyLayer",AstrologyLayer.exitAstro)
    elseif tonumber(data.typeId) == 105 then
        --跳转夺宝
        require "script/ui/treasure/TreasureMainView"
        local canEnter = DataCache.getSwitchNodeState( ksSwitchRobTreasure )
        if( canEnter ) then
            local treasureLayer = TreasureMainView.create()
            MainScene.changeLayer(treasureLayer,"treasureLayer")
        end
    elseif tonumber(data.typeId) == 106 then
         --跳转到竞技场
        local canEnter = DataCache.getSwitchNodeState( ksSwitchArena )
        if( canEnter ) then
            require "script/ui/arena/ArenaLayer"
            local arenaLayer = ArenaLayer.createArenaLayer()
            MainScene.changeLayer(arenaLayer, "arenaLayer")
        end 
    elseif tonumber(data.typeId) == 107 then
        --跳转到资源矿
        local canEnter = DataCache.getSwitchNodeState( ksSwitchResource )
        if( canEnter ) then
            require "script/ui/active/mineral/MineralLayer"
            local mineralLayer = MineralLayer.createLayer()
            MainScene.changeLayer(mineralLayer, "mineralLayer")
        end
    elseif tonumber(data.typeId)>= 108 and tonumber(data.typeId) <= 110 then
         --跳转到充值界面
        local layer = RechargeLayer.createLayer()
        local scene = CCDirector:sharedDirector():getRunningScene()
        scene:addChild(layer,1111)
   end
    
end