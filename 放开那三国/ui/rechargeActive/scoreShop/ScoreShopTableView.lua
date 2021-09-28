-- Filename：	ScoreShopTableView.lua
-- Author：		DJN
-- Date：		2015-3-3
-- Purpose：    积分商店tableview


module ("ScoreShopTableView", package.seeall)
require "script/ui/rechargeActive/scoreShop/ScoreShopData"
require "script/ui/tip/AnimationTip"
require "script/audio/AudioUtil"
local _rewardTable = {}
local bigCellSize = CCSizeMake(440,320)

function createTableView(p_size)
	local  function rewardTableCallback(fn, t_table, a1, a2)
        _rewardTable = ScoreShopData.getRewardTable()
        local r
        if fn == "cellSize" then
            r = bigCellSize
        elseif fn == "cellAtIndex" then
            a2 = creteCell(a1+1)
            r = a2
        elseif fn == "numberOfCells" then
            r = math.ceil(table.count(_rewardTable)/2)
            --print("numberOfCells r = " ,r)
        elseif fn == "cellTouched" then
                
        end
        return r
    end
    local tableView = LuaTableView:createWithHandler(LuaEventHandler:create(rewardTableCallback), p_size)
    tableView:setBounceable(true)
    tableView:setVerticalFillOrder(kCCTableViewFillTopDown)

    return tableView
end
--创建cell
function creteCell(p_line)
	local tCell = CCTableViewCell:create()
	--tableView嵌套tableView
    local innerTableView = createInnerTableView(p_line)
    innerTableView:ignoreAnchorPointForPosition(false)
    innerTableView:setAnchorPoint(ccp(0,0))
    innerTableView:setPosition(ccp(0,0))
    --require "script/ui/lordWar/reward/LordWarRewardLayer"
    --innerTableView:setTouchPriority(LordWarRewardLayer.getTouchPriority() - 1)
    --innerTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    innerTableView:setDirection(kCCScrollViewDirectionHorizontal)
    -- innerTableView:setBounceable(false)
    innerTableView:setTouchEnabled(false)
    innerTableView:reloadData()
    tCell:addChild(innerTableView)

    return tCell
end
--[[
    @des    :创建内部tableView
    @param  :奖励条目
    @return :创建好的tableView
--]]
function createInnerTableView(p_line)
   
    local h = LuaEventHandler:create(function(fn,p_table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(bigCellSize.width*0.5,bigCellSize.height)
        elseif fn == "cellAtIndex" then
            local index = (p_line-1)*2 + a1+1
  
                a2 = createItemCell(index)
                r = a2

        elseif fn == "numberOfCells" then
            r = 2
        else
            --print("other function")
        end
        return r
    end)

    return LuaTableView:createWithHandler(h, bigCellSize)
end

--[[
    @des    :创建内部cell
    @param  :当前的奖励信息
    @return :创建好的cell
--]]
function createItemCell(p_tag)
    local cellTag = tonumber(p_tag)
    local prizeViewCell = CCTableViewCell:create()
    if(p_tag <= table.count(_rewardTable))then
        --cell大背景
        local bg = CCScale9Sprite:create("images/common/bg/change_bg.png")
        bg:setContentSize(CCSizeMake(bigCellSize.width*0.5,310))
        bg:setAnchorPoint(ccp(0,0))
        bg:setPosition(ccp(0,0))
        prizeViewCell:addChild(bg)
        --二级棕色背景
        require "script/utils/BaseUI"
        local secondBg = BaseUI.createContentBg(CCSizeMake(145,160))
        secondBg:setAnchorPoint(ccp(0.5,0.5))
        secondBg:setPosition(ccpsprite(0.5,0.55,bg))
        bg:addChild(secondBg)
        
      
        local infoForIcon = {}
        table.insert(infoForIcon,_rewardTable[cellTag])
        infoForIcon = ItemUtil.getItemsDataByStr(nil,infoForIcon)

    
        --获取icon和名字
        --local itemSprite = ItemSprite.getItemSpriteById(infoForIcon[1], nil,itemDelegateAction, nil, -600,1000 )
        local itemSprite,goodName = ItemUtil.createGoodsIcon(infoForIcon[1],ScoreShopLayer:getTouchPriority()-9,ScoreShopLayer.getZOrder()+1,
                                                    ScoreShopLayer:getTouchPriority()-20,itemDelegateAction,false,false,false) 
        itemSprite:setAnchorPoint(ccp(0.5,1))
        itemSprite:setPosition(ccpsprite(0.5,0.9,secondBg))
        secondBg:addChild(itemSprite)
        --名字label       
        --local goodNameLabel = CCRenderLabel:create(goodName, g_sFontPangWa, 23,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        local goodNameLabel = CCLabelTTF:create(goodName, g_sFontPangWa, 23)
        secondBg:addChild(goodNameLabel)
        goodNameLabel:setAnchorPoint(ccp(0.5,0))
        goodNameLabel:setPosition(ccpsprite(0.5,1.05,secondBg))
        goodNameLabel:setColor(ccc3(0x94,0x00,0x54))



        ------消耗的积分
        local scoreLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_153",_rewardTable[cellTag].cost), g_sFontName, 18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        secondBg:addChild(scoreLabel)
        scoreLabel:setAnchorPoint(ccp(0.5,0))
        scoreLabel:setPosition(ccpsprite(0.5,0.2,secondBg))
        scoreLabel:setColor(ccc3(0xff,0xff,0xff))

        ------剩余的次数
        local numLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_113",ScoreShopData.getLimitTime(cellTag)), g_sFontName, 18,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        secondBg:addChild(numLabel)
        numLabel:setAnchorPoint(ccp(0.5,1))
        numLabel:setPosition(ccpsprite(0.5,0.18,secondBg))
        numLabel:setColor(ccc3(0xff,0xff,0xff))
        
        

        local btnMenu = CCMenu:create()
        btnMenu:setTouchPriority(ScoreShopLayer:getTouchPriority()-15)
        btnMenu:setAnchorPoint(ccp(0,0))
        btnMenu:setPosition(ccp(0,0))
        bg:addChild(btnMenu)

        local buyMenuItem = LuaCC.create9ScaleMenuItemWithoutLabel("images/common/btn/btn_blue_n.png",
                                    "images/common/btn/btn_blue_h.png","images/common/btn/btn_blue_hui.png",
                             CCSizeMake(120,65))
        buyMenuItem:setAnchorPoint(ccp(0.5,0))
        buyMenuItem:setPosition(ccp(bg:getContentSize().width*0.5,15))
        buyMenuItem:registerScriptTapHandler(buyBtnCb)
        btnMenu:addChild(buyMenuItem,1,cellTag)

        --“兑换”字
        local buyLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2689"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
        buyLabel:setColor(ccc3(0xff,0xe4,0x00))
        buyLabel:setAnchorPoint(ccp(0.5,0.5))
        buyLabel:setPosition(ccp(buyMenuItem:getContentSize().width *0.5,buyMenuItem:getContentSize().height *0.5))
        buyMenuItem:addChild(buyLabel)
        if(ScoreShopData.getLimitTime(cellTag) <= 0)then
            buyMenuItem:setVisible(false)
            -- buyLabel:setColor(ccc3(0x7f,0x7f,0x7f))
            local hasReceiveItem = CCSprite:create("images/common/yiduihuan.png")
            hasReceiveItem:setAnchorPoint(ccp(0.5,0))
            hasReceiveItem:setPosition(ccp(bg:getContentSize().width*0.5,25))
            bg:addChild(hasReceiveItem)
        end
        
    end
    return prizeViewCell
end

function itemDelegateAction( )
    MainScene.setMainSceneViewsVisible(true, false, false)
end
function buyBtnCb(tag)
    print("点击的menu的tag",tag)
    tag = tonumber(tag)
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    -- print("rewardTable")
    -- print_t(_rewardTable)
    

    local scoreTime = ScoreShopData.getScoreTime(tag)
    local limitTime = ScoreShopData.getLimitTime(tag)
    local buyTime = (scoreTime <= limitTime ) and scoreTime or limitTime --可购买的次数
    local confirmTime = 0 --用户最后确认购买的次数

    if(buyTime > 0)then
        
        -- 宠物背包满了
        require "script/ui/pet/PetUtil"
        if PetUtil.isPetBagFull() == true then
            return
        end
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
        --网络发送请求完毕的回调函数
        local endcallfunc = function ( ... )
            --扣积分
            ScoreShopData.addPoint(-confirmTime*_rewardTable[tag].cost)          
            
            --改缓存中购买数量
            ScoreShopData.addBuiedTime(tag,confirmTime)
            --发奖
            local infoForReward = {}
            table.insert(infoForReward,_rewardTable[tag])
            infoForReward = ItemUtil.getItemsDataByStr(nil,infoForReward) 
            infoForReward[1].num = infoForReward[1].num * confirmTime
            ItemUtil.addRewardByTable(infoForReward)
            ScoreShopLayer.refreshUI()
            --恭喜获得****
            ReceiveReward.showRewardWindow(infoForReward,nil,ScoreShopLayer.getZOrder()+2,
                                        ScoreShopLayer.getTouchPriority()-20)
            --刷新UI
            --ScoreShopLayer.refreshUI()
        end
        --购买数量弹板，得到用户确认购买后的回调函数
        local confirmCllFunc = function ( p_num )
            confirmTime = p_num
            require "script/ui/rechargeActive/scoreShop/ScoreShopService"
            ScoreShopService.buyItem(tag,p_num,endcallfunc)
        end
        
        require "script/ui/common/BatchExchangeLayer"
        local infoForName = {}
        table.insert(infoForName,_rewardTable[tag])
        infoForName = ItemUtil.getItemsDataByStr(nil,infoForName)
        local _,goodName = ItemUtil.createGoodsIcon(infoForName[1])
        -- print("infoForName")
        -- print_t(infoForName)

        local p_param = {}
        p_param.title = GetLocalizeStringBy("key_2342")
        p_param.first = GetLocalizeStringBy("key_1438")
        p_param.max   = buyTime
        p_param.name  = goodName or ""
        p_param.need  = {}
        p_param.need[1] = {}
   
        --print_t(_rewardTable[tag])
        p_param.need[1].price = tonumber(_rewardTable[tag].cost)
        p_param.need[1].needName = GetLocalizeStringBy("djn_146")
        p_param.need[1].sprite = nil
        BatchExchangeLayer.showBatchLayer(p_param,confirmCllFunc,ScoreShopLayer.getTouchPriority()-30,
                         ScoreShopLayer.getZOrder()+2)

    elseif(scoreTime <= 0)then
        --提示积分不足
        AnimationTip.showTip(GetLocalizeStringBy("djn_147"))
    elseif(limitTime <= 0)then
        --提示购买次数已经到了上限
        AnimationTip.showTip(GetLocalizeStringBy("key_8119"))
    end

end
