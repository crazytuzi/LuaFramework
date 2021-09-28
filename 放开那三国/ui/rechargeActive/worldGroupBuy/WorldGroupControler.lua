-- Filename：    WorldGroupControler.lua
-- Author：      DJN
-- Date：        2015-8-3
-- Purpose：    跨服团购控制层


module ("WorldGroupControler", package.seeall)
require "script/libs/LuaCCLabel"
require "script/ui/rechargeActive/worldGroupBuy/WorldGroupPointRewardLayer"
require "script/ui/rechargeActive/worldGroupBuy/WorldGroupBuyRecordLayer"
require "script/ui/rechargeActive/worldGroupBuy/WorldBuyRichTip"
require "script/ui/rechargeActive/worldGroupBuy/WorldBuyDescLayer"
--购买按钮回调
function buyAction( p_tag,p_item )
    if(isInTwelve(true))then
        return
    end
    --先判断是否达到今日购买上限
    local lastNum = WorldGroupData.getCanBuyTimeById(p_tag)
    if(lastNum <=0)then
        AnimationTip.showTip(GetLocalizeStringBy("djn_208"))
        return
    end
    WorldGroupData.initPreviewCrossInfo()
    -- WorldGroupData.addPreviewCrossNumById(p_tag,1)
    -- 选择购买数量
    require "script/utils/SelectNumDialog"
    local dialog = SelectNumDialog:create(610, 670)
    dialog:setTitle(GetLocalizeStringBy("key_1745"))
    dialog:setLimitNum(lastNum)
    dialog:show(WorldGroupLayer.getTouchPriority() - 100, 1010)

    local gold,courpon = WorldGroupData.getTotalPreviewCostByNum(p_tag,1)
     --价格
    local childNodes = {}
    childNodes[1] = CCRenderLabel:create(GetLocalizeStringBy("djn_236"),g_sFontName, 25,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    childNodes[1]:setColor(ccc3(0xff, 0xf6, 0x00))
    childNodes[2] = CCSprite:create("images/common/gold.png")

    -- childNodes[2] = CCSprite:create("images/purgatory/lianyulingsmall.png")

    childNodes[3] = CCRenderLabel:create(gold,g_sFontName, 30, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    childNodes[3]:setColor(ccc3(0xff, 0xf6, 0x00))
    childNodes[4] = CCLabelTTF:create("     ", g_sFontPangWa,30)
    if courpon > 0 then
        childNodes[5] = CCSprite:create("images/recharge/worldGroupBuy/coupon.png" )
        childNodes[6] = CCRenderLabel:create(courpon,g_sFontName, 30, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        childNodes[6]:setColor(ccc3(0xff, 0xf6, 0x00))
    end 

    contentCostNode = BaseUI.createHorizontalNode(childNodes)
    contentCostNode:setAnchorPoint(ccp(0.5,0.5))
    contentCostNode:setPosition(ccpsprite(0.5, 0.3, dialog))
    dialog:addChild(contentCostNode)

    dialog:registerChangeCallback(function ( curTime)
        -- WorldGroupData.initPreviewCrossInfo()
        -- WorldGroupData.addPreviewCrossNumById(p_tag,curTime)
        local gold,courpon = WorldGroupData.getTotalPreviewCostByNum(p_tag,curTime)
        childNodes[3]:setString(gold)
        if(courpon > 0 )then
            if childNodes[6] then
                childNodes[6]:setString(courpon)
            else
                --暂无这种可能 实在想不到有这种可能 除非以后团购券的规则改了 那么这里需要创建chilsNodes[6s]
            end
        end
    end)
    dialog:registerOkCallback(function ( ... )
        WorldBuyRichTip.tipConfirmBuy(p_tag,dialog:getNum())
    end)
    -- WorldBuyRichTip.tipConfirmBuy(p_tag)
end
--确认购买的回调
--p_tag 物品id p_goldNum 金币花费数 p_buyTime 购买次数
function confirmCb(p_tag,p_goldNum,p_buyTime)
    local p_buyTime = tonumber(p_buyTime)
    local curgold = UserModel.getGoldNumber()
    local needGold = tonumber(p_goldNum)
    if(needGold > 0)then
        --金币不够去充值
        if(tonumber(curgold) < needGold)then
            require "script/ui/tip/LackGoldTip"
            LackGoldTip.showTip()
            return              
        end
    end
    if(ItemUtil.isBagFull() == true )then
        return
    end
    -- 武将满了
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return true
    end
    local netCb = function (p_netData )
        -- print("p_netData")
        -- print_t(p_netData)

        if(table.isEmpty(p_netData))then
            return
        end
        --0=>goodId物品id, 1=>num团购数量, 2=>gold花费金币, 3=>coupon券, 4=>buyTime时间
        -- --改缓存 
        local userInfo = WorldGroupData.getUserInfo()

        local activeCache = WorldGroupData.getActiveDataByID(p_netData.goodId)
        if(table.isEmpty(userInfo.his))then
            userInfo.his = {}
        end
        local netCoupon = tonumber(p_netData.coupon)
        local netGold = tonumber(p_netData.gold)
        local addPoint = netGold + netCoupon
        local addCoupon = math.floor(tonumber(activeCache["return_rate"])/10000 * (netGold + netCoupon))
        --加购买记录
        table.insert(userInfo.his,p_netData)
        --加总购买次数缓存
        WorldGroupData.addCrossNumById(p_netData["goodId"],p_buyTime)
        -- --减金币
        UserModel.addGoldNumber(-tonumber(p_netData["gold"]))
        -- --减团购券
        userInfo.coupon = tonumber(userInfo.coupon) - netCoupon
        -- --加积分  获得的积分等于金币加团购券
        userInfo.point = tonumber(userInfo.point) + addPoint
        -- 加获得的团购券
        userInfo.coupon = tonumber(userInfo.coupon) + addCoupon
        -- --发奖 更新本地缓存
        rewardTab = ItemUtil.getItemsDataByStr(activeCache["item"]) 
        for i=1,p_buyTime do
            ItemUtil.addRewardByTable( rewardTab )
        end
        --恭喜获得****
        -- AnimationTip.showTip(GetLocalizeStringBy("djn_209",addPoint,addCoupon))
        WorldBuyRichTip.tipBuySuccess(p_netData["gold"],netCoupon,addPoint,addCoupon)
        --刷新ui
        WorldGroupLayer.refreshUI()

    end
    WorldGroupService.buy(p_tag,p_buyTime,netCb)
end
--购买记录按钮回调
function recordAction( p_tag,p_item )
    --print("recordAction p_tag",p_tag)
    WorldGroupBuyRecordLayer.show(p_tag,WorldGroupLayer.getTouchPriority()-10,WorldGroupLayer.getZorder()+10)
end
--说明回调
function noteMenuCallBack( ... )
    WorldBuyDescLayer.show(WorldGroupLayer.getTouchPriority()-10,WorldGroupLayer.getZorder()+10)
end
--积分奖励回调
function rewardMenuCallBack( ... )
    if(isInTwelve(true))then
        return
    end
    WorldGroupPointRewardLayer.show(WorldGroupLayer.getTouchPriority()-10,WorldGroupLayer.getZorder()+10)
end
--下面团购物品点击回调
function listItemAction(p_tag,p_item)
    WorldGroupLayer.setCurGoodId(p_tag)
    WorldGroupLayer.refreshBuyUI()

end
--点击礼包 展示礼包内容
function goodIconAction( p_tag)
    WorldBuyRichTip.showBagTip(p_tag )
end
--判断当前是否在凌晨12点刷新期间 （留20秒拉数据）这个期间不发网络请求
function isInTwelve( p_ifAlert )
    local contentTime = TimeUtil.getSvrTimeByOffset()
    local zeroTime = TimeUtil.getCurDayZeroTime()
    if (contentTime - zeroTime ) < 20 then
        if(p_ifAlert)then
            AnimationTip.showTip(GetLocalizeStringBy("djn_220"))
        end
        return true
    else
        return false
    end
end