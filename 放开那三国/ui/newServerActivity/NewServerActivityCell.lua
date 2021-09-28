-- FileName: NewServeActivityCell.lua 
-- Author: fuqiongqiong
-- Date: 2016-5-4
-- Purpose: 新服活动Cell

module("NewServerActivityCell",package.seeall)
require "script/ui/newServerActivity/NewServerActivityController"
require "script/ui/newServerActivity/NewServerActivityData"
require "script/ui/newServerActivity/NewServerDef"
require "script/ui/shopall/MysteryShop/MysteryShopLayer"
require "script/ui/shopall/prop/PropLayer"
require "script/model/DataCache"
require "script/ui/shopall/ShoponeLayer"
local _dayNum 
function createCell(pData,pIndex,pTouchpriority,pDay)
    print("cell数据*****")
    print_t(pData)
    _dayNum = pDay
	local cell = CCTableViewCell:create()
	--cell背景
	local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
	local bg = CCScale9Sprite:create("images/common/bg/change_bg.png",fullRect, insetRect)
	bg:setPreferredSize(CCSizeMake(595,182))
    bg:setScale(g_fScaleX)
	cell:addChild(bg)
	local whiteBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
	whiteBg:setContentSize(CCSizeMake(437,125))
	whiteBg:setAnchorPoint(ccp(0,1))
	whiteBg:setPosition(ccp(20,145))
	bg:addChild(whiteBg)
	--任务名称
    local nameLabel = CCRenderLabel:create(pData.desc,g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
    nameLabel:setColor(ccc3(0xff,0xf6,0x00))
    nameLabel:setAnchorPoint(ccp(0,1))
    nameLabel:setPosition(ccp(40,bg:getContentSize().height-10))
    bg:addChild(nameLabel)
	local rewarddata = string.split(pData.reward,",")
	local contentWidth = table.count(rewarddata)*120
	local width = whiteBg:getContentSize().width*0.98
	local scrollView = CCScrollView:create()
    scrollView:setContentSize(CCSizeMake(contentWidth, 180))
    scrollView:setViewSize(CCSizeMake(width, 180))
    scrollView:ignoreAnchorPointForPosition(false)
    scrollView:setAnchorPoint(ccp(0,0))
    scrollView:setPosition(ccp(0,-whiteBg:getContentSize().height*0.45))
    scrollView:setTouchPriority(-455)
    scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    whiteBg:addChild(scrollView)
 
    for k,v in pairs(rewarddata) do
            local rewardInDb = ItemUtil.getItemsDataByStr(rewarddata[k])
            local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -450, 3000, -480,function ( ... )
        end,nil,nil,false)
        icon:setPosition(ccp(25*k+(k-1)*icon:getContentSize().width,85))
        scrollView:addChild(icon)
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
    local data = NewServerActivityData.getInfotaskId()
    if (table.isEmpty(data)) then
        --前往
        local goBtn = CCMenuItemImage:create("images/newserve/qianwang-n.png","images/newserve/qiangwang-h.png")
        goBtn:setAnchorPoint(ccp(1, 0.5))
        goBtn:setPosition(ccp(bg:getContentSize().width-10, bg:getContentSize().height*0.5))
        goBtn:registerScriptTapHandler(goCallBack)
        menuBar:addChild(goBtn, 1, pData.id)
    else
        -- 按钮的3种状态,创建时用（taskid做标识，即id）
        local statues = NewServerActivityData.getTaskStatusByTaskId(pData.id)
        print("statues*****",statues)
        if(NewServerDef.kTaskStausNotAchive == statues)then
            --前往
            local goBtn = CCMenuItemImage:create("images/newserve/qianwang-n.png","images/newserve/qiangwang-h.png")
            goBtn:setAnchorPoint(ccp(1, 0.5))
            goBtn:setPosition(ccp(bg:getContentSize().width-10, bg:getContentSize().height*0.5))
            goBtn:registerScriptTapHandler(goCallBack)
            menuBar:addChild(goBtn, 1, pData.id)
        elseif NewServerDef.kTaskStausCanGet == statues then
            --领取
            local reciveBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("fqq_062"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
            reciveBtn:setAnchorPoint(ccp(1, 0.5))
            reciveBtn:setPosition(ccp(bg:getContentSize().width-10, bg:getContentSize().height*0.5))
            reciveBtn:registerScriptTapHandler(receiveCallBack)
            menuBar:addChild(reciveBtn, 1, pData.id)
        else
            --已领取
            local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
            receive_alreadySp:setPosition(ccp(bg:getContentSize().width-10,bg:getContentSize().height*0.5))
            receive_alreadySp:setAnchorPoint(ccp(1,0.5))
            bg:addChild(receive_alreadySp)
        
        end 
    end
    
    return cell
end
--领取按钮回调
function receiveCallBack( taskId )
    if(tonumber(NewServerActivityData.receiveCountDownTime()) <= 0)then
        --提示活动已结束
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_096"))
        return
    end
    --判断背包
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
	local callBackfunc = function ( ... )
       --改变按钮状态
       NewServerActivityData.setStatues(taskId,2)
       local num = NewServerActivityLayer.getbiaoqianNum()
       --刷新标签红点
       NewServerActivityLayer.refreshLableTip(num)
       --刷新第X天红点
       NewServerActivityLayer.refreshNormalRedTip()
       NewServerActivityLayer.createtableView(true)
       
    end
    NewServerActivityController.obtainReward(taskId,callBackfunc)
end
--前往回调
function goCallBack( taskId )
     print("taskId~~~~~~",taskId)
     -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    if (tonumber(NewServerActivityData.countDownTime()) <= 0)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_092"))
        return
    end
    if(taskId>= 101001 and taskId <= 101999) or(taskId>= 104001 and taskId <= 104999)then
        --跳转到副本
        require "script/ui/copy/CopyLayer"
        local copyLayer = CopyLayer.createLayer()
        MainScene.changeLayer(copyLayer, "copyLayer")
    elseif taskId>= 102001 and taskId <= 102999 then
        --跳转到商城
        if DataCache.getSwitchNodeState(ksSwitchShop) then
            require "script/ui/shop/ShopLayer"
            local  shopLayer = ShopLayer.createLayer(ShopLayer.Tag_Shop_Hero)
            MainScene.changeLayer(shopLayer,"shopLayer",ShopLayer.layerWillDisappearDelegate)
        end
    elseif (taskId>= 103001 and taskId <= 103999) or (taskId>= 105001 and taskId <= 105999) or (taskId>= 106001 and taskId <= 106999) then
        --跳转到阵容
        require("script/ui/formation/FormationLayer")
        local formationLayer = FormationLayer.createLayer()
        MainScene.changeLayer(formationLayer, "formationLayer")
    elseif (taskId >= 107001 and taskId <= 107999) or (taskId >= 108001 and taskId <= 108999) then
        --跳转到活动夺宝界面
        require "script/ui/treasure/TreasureMainView"
        local treasureLayer = TreasureMainView.create()
        MainScene.changeLayer(treasureLayer,"treasureLayer")
    elseif (taskId >= 109001 and taskId <= 109999) or (taskId >= 110001 and taskId <= 110999) then
        --跳转到阵容
        require("script/ui/formation/FormationLayer")
        local formationLayer = FormationLayer.createLayer()
        MainScene.changeLayer(formationLayer, "formationLayer")
    elseif (taskId >= 111001 and taskId <= 111999) or (taskId >= 112001 and taskId <= 112999) then
        --跳转到竞技场
        local canEnter = DataCache.getSwitchNodeState( ksSwitchArena )
        if( canEnter ) then
            require "script/ui/arena/ArenaLayer"
            local arenaLayer = ArenaLayer.createArenaLayer()
            MainScene.changeLayer(arenaLayer, "arenaLayer")
        end 
    elseif (taskId >= 113001 and taskId <= 113999) then
        --跳转神秘商店
        if not (DataCache.getSwitchNodeState(ksSwitchResolve, false))then
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip(GetLocalizeStringBy("fqq_093"))
            return
        end
        ShoponeLayer.createAllShop(ShoponeLayer.ksTagMysteryShop)
        -- local layer = MysteryShopLayer.createCenterLayer
        -- MainScene.changeLayer(layer,"MysteryShopLayer")
    elseif (taskId >= 114001 and taskId <= 114999) then
        --跳转道具商店
        if not (DataCache.getSwitchNodeState(ksSwitchShop, false))then
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip(GetLocalizeStringBy("fqq_094"))
            return
        end
        ShoponeLayer.createAllShop(ShoponeLayer.ksTagPropShop)
        -- local layer = PropLayer.createLayer(nil,true)
        -- MainScene.changeLayer(layer,"PropLayer") 
    elseif (taskId >= 126001 and taskId <= 126999) then
        --跳转到名将
        if not DataCache.getSwitchNodeState(ksSwitchGreatSoldier) then
            return
        end
        require "script/ui/star/StarLayer"
        local starLayer = StarLayer.createLayer()
        MainScene.changeLayer(starLayer, "starLayer")
    elseif (taskId >= 116001 and taskId <= 116999) or (taskId >= 117001 and taskId <= 117999) then
        print("跳转到试练塔")
        --跳转到试练塔
        local canEnter = DataCache.getSwitchNodeState( ksSwitchTower )
        if( canEnter ) then
            require "script/ui/tower/TowerMainLayer"
            local towerMainLayer = TowerMainLayer.createLayer()
            MainScene.changeLayer(towerMainLayer, "towerMainLayer")
        end
    elseif (taskId >= 118001 and taskId <= 118999) or (taskId >= 127001 and taskId <= 127999) then
        --跳转到战魂
        if not DataCache.getSwitchNodeState(ksSwitchBattleSoul) then
            return
        end
        require "script/ui/huntSoul/HuntSoulLayer"
        local layer = HuntSoulLayer.createHuntSoulLayer()
        MainScene.changeLayer(layer, "huntSoulLayer")
    elseif (taskId >= 119001 and taskId <= 119999) then
        --跳转到活动界面
        require "script/ui/active/ActiveList"
        local activeListr = ActiveList.createActiveListLayer()
        MainScene.changeLayer(activeListr, "activeListr")
    elseif (taskId >= 120001 and taskId <= 121999) then
        --跳转到军团主界面,(无军团跳转到创建军团界面)
        if not DataCache.getSwitchNodeState(ksSwitchGuild) then
            return
        end
        require "script/ui/guild/GuildImpl"
        GuildImpl.showLayer()
    elseif (taskId >= 123001 and taskId <= 123999)  then
        --跳转到资源矿
        local canEnter = DataCache.getSwitchNodeState( ksSwitchResource )
        if( canEnter ) then
            require "script/ui/active/mineral/MineralLayer"
            local mineralLayer = MineralLayer.createLayer()
            MainScene.changeLayer(mineralLayer, "mineralLayer")
        end
    elseif (taskId >= 125001 and taskId <= 125999) then
        --跳转到充值界面
        local layer = RechargeLayer.createLayer()
        local scene = CCDirector:sharedDirector():getRunningScene()
        scene:addChild(layer,1111)
    elseif (taskId >= 122001 and taskId <= 122999) then
        --跳转到加军团界面 
        if not DataCache.getSwitchNodeState(ksSwitchGuild) then
            return
        end
        require "script/ui/guild/GuildListLayer"
        local guildListLayer = GuildListLayer.createLayer(false)
        MainScene.changeLayer(guildListLayer, "guildListLayer")
    end
end