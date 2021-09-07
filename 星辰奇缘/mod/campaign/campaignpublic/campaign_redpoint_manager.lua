--各种红点逻辑
CampaignRedPointManager = CampaignRedPointManager or BaseClass(BaseManager)

function CampaignRedPointManager:__init()
    if CampaignRedPointManager.Instance ~= nil then
        return
    end

    CampaignRedPointManager.Instance = self
    self.timeShopInit = false
    self.campaignAutumnIsOpen = false
end


----星语星愿活动红点逻辑
function CampaignRedPointManager:CheckWishRedPoint()
    local isRed = false
    if ValentineManager.Instance.model.wishCount ~= nil and ValentineManager.Instance.model.votiveCount ~= nil then
        if 1 - ValentineManager.Instance.model.wishCount == 0 then
            isRed = false
        else
            isRed = isTurnRechargeActive
        end

        if 1 - ValentineManager.Instance.model.wishCount == 0 and 2 - ValentineManager.Instance.model.votiveCount == 2 then
            isRed = true
        elseif 1 - ValentineManager.Instance.model.wishCount == 0 and 2 - ValentineManager.Instance.model.votiveCount ~= 2 then
            isRed = false
        end
    end

    return isRed
end

--累计消费活动
function CampaignRedPointManager:CheckConsumeReturnReturn()
    local isRed = false
    local dataList = {}
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.SummerCarnival] ~= nil then
        self.campaignGroup = CampaignManager.Instance.campaignTree[CampaignEumn.Type.SummerCarnival][CampaignManager.Instance.campaignTree[CampaignEumn.Type.SummerCarnival].index]
        if self.campaignGroup ~= nil then
            for i,v in ipairs(self.campaignGroup.sub) do
                table.insert(dataList,v)
            end
            table.sort(dataList,function (a,b)
                return a.target_val < b.target_val
                -- return a.baseData.group_index < b.baseData.group_index
            end)


            for i=1,#dataList do
                local data = dataList[i]
                if data.status == 1 then
                    isRed = true
                end
            end
        end
    end
    return isRed
end

--百花送福抽奖活动
function CampaignRedPointManager:CheckHundredPanel(id)
    local isRed = false
    local baseTime = BaseUtils.BASE_TIME
    local d = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local m = tonumber(os.date("%m", BaseUtils.BASE_TIME))
    local y = tonumber(os.date("%Y", BaseUtils.BASE_TIME))
    local dailyStart = os.time{year = y, month = m, day = d, hour = 19, min = 0, sec = 0}
    local dailyEnd = os.time{year = y, month = m, day = d, hour = 23, min = 0, sec = 0}

    if baseTime > dailyStart and baseTime < dailyEnd then
        isRed = false
        self.campaignData_cli = DataCampaign.data_list[id]

        if self.campaignData_cli ~= nil then
            self.exchangeBaseId = self.campaignData_cli.loss_items[1][1]
            --print(self.exchangeBaseId)
            if self.exchangeBaseId ~= nil then
                if BackpackManager.Instance:GetItemCount(self.exchangeBaseId) > 0 then
                    isRed = true
                end
            end
        end
    end
    -- print("红点检测22222222222222222222222222222222222222222=========================================================")
    -- print(tostring(isRed))
    return isRed
end

--花开富贵礼盒活动
function CampaignRedPointManager:CheckFlowerPanel()
    local isRed = false
    self.perNum = 9
    local count = c or (ChildBirthManager.Instance.model.flowerData or {}).count or 0
    if count >= 7 * self.perNum then
        isRed = true
    end
    return isRed
end

--（初秋活动)充值礼券红点逻辑
function CampaignRedPointManager:RechargeGift()
    local isRed = false
    local data = BeginAutumnManager.Instance:GetGiftList()
    if data ~= nil then
       for k,v in pairs(data) do
            local hasnum = v.camp_max
            if BeginAutumnManager.Instance.totalList ~= nil and BeginAutumnManager.Instance.totalList[v.id] ~= nil then
                hasnum = v.camp_max - BeginAutumnManager.Instance.totalList[v.id].num
            end
            --local chargeList = RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.dollar)
            local chargeList = BeginAutumnManager.Instance.model.dollar
            --print(hasnum.."   "..chargeList.."   "..v.cost)
            if hasnum > 0 and chargeList >= v.cost then
                isRed = true
            end
        end
    end
    return isRed

end

-- (限时商店逻辑2) 逻辑1只能写在beginautum_manager里
function CampaignRedPointManager:TimeShop2()
    local isRed = false
    if BeginAutumnManager.Instance.shopDataList ~= nil and BeginAutumnManager.Instance.shopDataList.ref_num ~= nil  then
        if BackpackManager.Instance:GetItemCount(20771) > 0 and 5 - BeginAutumnManager.Instance.shopDataList.ref_num > 0 then
           isRed = true
        end
    end

    return isRed
end

--排行榜逻辑(IntiMacyPanel)
function CampaignRedPointManager:CheckIntimacy()
    local red = false

    if CampaignManager.Instance:CheckIntimacy() then
        if IntimacyManager.Instance ~= nil then
            local myIntimacy = IntimacyManager.Instance:GetMyIntimacy()
        if myIntimacy > 0 then
                local tmpList = IntimacyManager.Instance:GetIntimacyPersonalData();
                if tmpList ~= nil then
                    for _,tmp in ipairs(tmpList) do
                        if myIntimacy >= tmp.num then
                            local isGet = IntimacyManager.Instance:CheckIsGetReward(tmp.num);
                            if not isGet then
                                red = true
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    return red
end

--充值巨献
function CampaignRedPointManager:CheckRechargePack(id)
    local red = false
   local data = CampaignManager.Instance.campaignTab[id]
    local isGetReward = nil
    if data ~= nil then
        isGetReward = data.status
    end

    if isGetReward == 1 then
       red = true
    else
        red = false
    end
    return red
end
------------
function CampaignRedPointManager:IsCheckToyReward()
    local red = false
    if self:CalculateTime() == true and self:isCampaignActive() == true then
        if BackpackManager.Instance:GetItemCount(23262) >= 1 then
            red = true
        end
    end
    return red
end

function CampaignRedPointManager:CalculateTime()
    local isStart = false
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginTime = nil
    local endTime = nil
     -- local time = DataCampaign.data_list[3].day_time[1]
    local time = DataCampTurn.data_turnplate[3].day_time[1]
    beginTime = tonumber(os.time{year = y, month = m, day = d, hour = time[1], min = time[2], sec = time[3]})
    endTime = tonumber(os.time{year = y, month = m, day = d, hour = time[4], min = time[5], sec = time[6]})


    if baseTime <= endTime and baseTime >= beginTime then
        isStart = true
    end

    return isStart

end

function CampaignRedPointManager:isCampaignActive()
    local isStart = false
    local baseTime = BaseUtils.BASE_TIME

    local campaignData = DataCampaign.data_list[741]
    local beginTime = nil
    local endTime = nil
    beginTime = tonumber(os.time{year = campaignData.cli_start_time[1][1], month = campaignData.cli_start_time[1][2], day = campaignData.cli_start_time[1][3], hour = campaignData.cli_start_time[1][4], min = campaignData.cli_start_time[1][5], sec = campaignData.cli_start_time[1][6]})
    endTime = tonumber(os.time{year = campaignData.cli_end_time[1][1], month = campaignData.cli_end_time[1][2], day = campaignData.cli_end_time[1][3], hour = campaignData.cli_end_time[1][4], min = campaignData.cli_end_time[1][5], sec = campaignData.cli_end_time[1][6]})
    if baseTime <= endTime and baseTime >= beginTime then
        isStart = true
    end
    return isStart
end

-----累充转盘活动
function CampaignRedPointManager:isTurnRechargeActive()
    local isStart = false
    local hasReward = false

    if TurntabelRechargeManager.Instance.totalItemList ~= nil then
        for i=1,5 do
            if TurntabelRechargeManager.Instance.boxRewardList[i] == nil then return false end
            if TurntabelRechargeManager.Instance.boxRewardList[i].is_reward == 0 then
                if TurntabelRechargeManager.Instance.boxRewardList[i].need_point <= TurntabelRechargeManager.Instance.regPoint then
                    isStart = true
                end
            end
        end



        for i,v in ipairs(TurntabelRechargeManager.Instance.rotationItemList) do
                if v.is_random == 0 then
                    hasReward = true
                end
        end


        if BackpackManager.Instance:GetItemCount(TurntabelRechargeManager.Instance.totalItemList.random_cost[1].item_id) >= TurntabelRechargeManager.Instance.totalItemList.random_cost[1].num and hasReward == true then
            isStart = true
        end
    end
    return isStart
end

function CampaignRedPointManager:IsFlowerPanelActive()
    local isStart = false
    if NationalSecondManager.Instance.flowerAcceptData ~= nil and NationalSecondManager.Instance.flowerAcceptData.final_reward_state ~= nil then
        if NationalSecondManager.Instance.flowerAcceptData.login_reward_state == 1 then
            isStart = true
        end

        if NationalSecondManager.Instance.flowerAcceptData.final_reward_state == 1 and #NationalSecondManager.Instance.flowerGiveData >= 9 then
            isStart = true
        end

        if RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.sunshine) > NationalSecondManager.Instance.flowerAcceptData.roll_cost then
            isStart = true
        end
    end

    return isStart
end

 --砍价活动   CampaignEumn.ShowType.AutumnBargain
function CampaignRedPointManager:CampaignAutumnActive()
    local isStart = false
    if CampaignAutumnManager.Instance.campaignData ~= nil and CampaignAutumnManager.Instance.campaignData.price_info ~= nil then
        for k,v in pairs(CampaignAutumnManager.Instance.campaignData.price_info) do
            if v.type == 1 then
                if v.price <= v.change_price[1].change_price and v.buy_already < v.buy_limit then
                    isStart = true
                end
            end
            if  v.buy_already == 0 and self.campaignAutumnIsOpen == false then
                isStart = true
            end
        end
    end
    return isStart
end




-- function CampaignRedPointManager:AutumnPackage()
--     local isStart = false
--     if RechargePackageManager.Instance.canRecharge == true then
--         isStart = true
--     end
--     print("中秋礼包红点 =====================================================" .. tostring(isStart))
--     return isStart
-- end

-- 包粽子类型的红点
function CampaignRedPointManager:CheckRedZongzi(id)
    -- local cfgData = DataCampaign.data_list[id]
    -- local protoData = CampaignManager.Instance.campaignTab[id]

    -- if protoData.reward_can > 0 then
    --     for _,cost in pairs(cfgData.loss_items) do
    --         if BackpackManager.Instance:GetItemCount(cost[1]) < cost[2] then
    --             return false
    --         end
    --     end
    --     return true
    -- else
    --     return false
    -- end



    -- local CampData = DataCampaign.data_list[id]
    -- local cfgData = nil
    -- if CampData ~= nil then
    --     cfgData = DataCampRiceDumplingData.data_get[tonumber(CampData.reward_content)]
    -- end

    -- local protoData = CampaignManager.Instance.campaignTab[id]
    -- if cfgData.limit == 0 or ((DragonBoatFestivalManager.Instance.model.dumplingTab[id] or {}).times or 0) < cfgData.limit then
    --     for _,cost in pairs(cfgData.cost) do
    --         if BackpackManager.Instance:GetItemCount(cost[1]) < cost[2] then
    --             return false
    --         end
    --     end
    --     return true
    -- else
        return false
    -- end



end

function CampaignRedPointManager:CheckDiscount(id)
    local datalist = ShopManager.Instance.model.datalist[2][31] or {}
    local count = BackpackManager.Instance:GetItemCount(KvData.assets.lucky_knot)
    for _,item in pairs(datalist) do
        if KvData.assets[item.assets_type] == KvData.assets.lucky_knot and math.ceil(item.price * item.discount / 1000) <= count then
            return true
        end
    end
    return false
end

--砸蛋
function CampaignRedPointManager:CheckDolls(id)
    return BackpackManager.Instance:GetItemCount(ValentineManager.Instance.DollsItemId) > 0
        and BaseUtils.TimeToNextDay() > 3600 and BaseUtils.TimeToNextDay()  < 18000
end

--单身狗活动
function CampaignRedPointManager:CheckSingleDog(id)

    local cost = DataCampRiceDumplingData.data_get[1].cost
    local ownCount = 0
    for i=1,3 do
        if cost ~= nil and cost[i] ~= nil then 
            local need = cost[i][2]
            local own = BackpackManager.Instance:GetItemCount(cost[i][1])
            if need < own or need == own then
                ownCount = ownCount + 1
            end
        end
    end

    if ownCount == 3 then
        return true
    end
    return false

end


function CampaignRedPointManager:CheckInquiry(id)
    return CampaignInquiryManager.Instance.isRed
end

function CampaignRedPointManager:CheckRedSummer(id)
    return CampaignManager.Instance.campaignSummerRed
end


function CampaignRedPointManager:CheckSalesPromotion(id)

    return not SalesPromotionManager.Instance.opened and SalesPromotionManager.Instance.left
end

function CampaignRedPointManager:CheckChristmasSnowMan(id)
    local bo = false
    local costItems = DoubleElevenManager.Instance.model:GetSnowManData(id)
    for i,v in ipairs(costItems) do
        if BackpackManager.Instance:GetItemCount(v) > 0 then
            bo = true
            break
        end
    end
    return bo
end

--时装评选面板红点逻辑
function CampaignRedPointManager:CheckFashionSelectionRed()
    local red = false
    if FashionSelectionManager.Instance.fashionData.show_start_time ~= nil and FashionSelectionManager.Instance:IsFashionVoteEnd() == false then
        if FashionSelectionManager.Instance.fashionRoleData ~= nil then
            if FashionSelectionManager.Instance.fashionRoleData.vote_times > 0 then
                red = true
            end
        end
    end
    return red
end

function CampaignRedPointManager:CheckFashionDiscountRed(id)

end



function CampaignRedPointManager:CheckNewYearTurnableRed(id)
    local red = false
    red = (NewYearTurnableManager.Instance.model.freeTime == 1)
    local num = BackpackManager.Instance:GetItemCount(70085)
    if num > 0 then
        red = true
    end
    return red

end

function CampaignRedPointManager:CheckLuckyMoneyRed(id)
    --BaseUtils.dump(SpringFestivalManager.Instance.model.lucky_money_data,"SpringFestivalManager.Instance.model.lucky_money_data")
    local red = false
    for i,v in ipairs(SpringFestivalManager.Instance.model.lucky_money_data) do
        -- if v.status == 1 or v.status == 2 then
        --     red = true
        --     break
        -- end
        if ((v.status == 0 or v.status == 1) and v.index - SpringFestivalManager.Instance.model.day <= 0) or (v.status == 2 and v.round_id * 6 + 1 - SpringFestivalManager.Instance.model.day <= 0 ) then
            red = true
        end
    end

    return red
end

function CampaignRedPointManager:CheckLanternMultiRechargeRed(id)
    local red = false
    --BaseUtils.dump(NewMoonManager.Instance.model.chargeData,"56565656566")
    if NewMoonManager.Instance.model.chargeData ~= nil and NewMoonManager.Instance.model.chargeData.reward ~= nil then
        for _,v in ipairs(NewMoonManager.Instance.model.chargeData.reward) do
            if v.day_status == 1 then
                red = true
            end
        end
    end
    return red
end


--签到抽奖(初春转转乐)
function CampaignRedPointManager:CheckSignDrawRed(id)
    for _,v in ipairs (SignDrawManager.Instance.model.questList) do
        if v.quest_status == 1 then
            return true
        end
    end

    if SignDrawManager.Instance.model.sign.sign_status == 0 then
        return true
    else
        return ( BackpackManager.Instance:GetItemCount(DataCampaign.data_list[id].loss_items[1][1]) > 0 )
    end
end

--大富翁 红点
function CampaignRedPointManager:CheckAprilTreasureRed(id)
    local isRed = false
    local currTimes = AprilTreasureManager.Instance.model.TurnTimes  --已轮回次数
    local ReceivedTurnTimes = AprilTreasureManager.Instance.model.ReceivedTurnTimes
    local turnTotal = {1, 3, 6, 10}
    local index = 0
    for i,v in pairs(turnTotal) do
        if currTimes >= v then
            index = i
        end
    end
    if #ReceivedTurnTimes < index or BackpackManager.Instance:GetItemCount(70027) >= 1 then
        isRed = true
    end
    return isRed
end

--传递花语 红点
function CampaignRedPointManager:CheckPassBlessRed(id)
    local isRed = false
    local flowerData = SignDrawManager.Instance.model.flower_list  --花的数据列表


    local collect = 0
    for i,v in ipairs(flowerData.flower_info) do
        if 1 == v.pass_flag or 2 == v.pass_flag then
            isRed = true
        elseif 3 == v.pass_flag then
            collect = collect + 1
        end
    end

    if collect == 7 and flowerData.gift_flag == 0 then
        isRed = true
    end
    return isRed
end

--幸运贝壳红点
function CampaignRedPointManager:CheckTreasureHuntingRed(id)
    local red = false
    local model = CampaignManager.Instance.model
    if model.cardData ~= nil then
        local times = model.cardData.times + 1
        local activity = RoleManager.Instance.RoleData.naughty
        if model.card_act_cost[times] ~= nil then
            local limit = model.card_act_cost[times]
            if limit.acticity > 0 then
                if limit.acticity <= activity then
                    red = true
                end
            end
        end
    end
    return red
end


--满减商城红点
function CampaignRedPointManager:CheckFullSubtractionShopRed(id)
    local red = false
    local lastTime = PlayerPrefs.GetInt(BaseUtils.Key(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id, MagicEggManager.Instance.FullSubShopTag))

    local lastDay = math.ceil((lastTime + 1) / 86400)
    local thisDay = math.ceil((BaseUtils.BASE_TIME + 1) / 86400)

    return lastDay ~= thisDay
end

function CampaignRedPointManager:CheckFruitPlantRed(id)
    local model = SummerManager.Instance.model
    if model.fruit_plant_data == nil then
        return false
    end
    local state = false
    local count_time = 0
    if model.fruit_plant_data.end_time == 0 then
        --不在冷却之中
        local map_data_list = model.fruit_plant_data.list
        local all_finish = true
        for i=1,#map_data_list do
            local map_data = map_data_list[i]
            if map_data.status == 1 then
                all_finish = false
                local cfg_data = DataCampFruit.data_fruit_base[map_data.id]
                local left_time = map_data.start_time + cfg_data.cd - BaseUtils.BASE_TIME
                if left_time <= 0 then
                    state = true --可收获
                    break
                else
                    --还不可收获
                    if count_time == 0 then
                        count_time = left_time
                    else
                        if left_time < count_time then
                            count_time = left_time
                        end
                    end
                end
            elseif map_data.status == 0 then
                all_finish = false
                --还没种植，检查下是否有足够道具可以种植
                local cfg_data = DataCampFruit.data_fruit_base[map_data.id]
                local has_num = BackpackManager.Instance:GetItemCount(cfg_data.item_id)
                if has_num >= cfg_data.num then
                    state = true --够
                end
            end
        end
        if all_finish then
            state = true --可领奖
        end
    else
        state = false
        --在冷却之中
        local left_time = model.fruit_plant_data.end_time - BaseUtils.BASE_TIME

        count_time = left_time
        if left_time <= 0 then
            state = true
        end
    end
    return state
end

--积分兑换红点
function CampaignRedPointManager:CheckIntegralExchangeRed(id)
   return (RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.score_exchange) > IntegralExchangeManager.Instance.model.integral_min) and IntegralExchangeManager.Instance.model.exchange_flag
end

--惊喜折扣商店
function CampaignRedPointManager:CheckSurpriseDisCountShopRed(id)
    local red = false
    local lastTime = PlayerPrefs.GetInt(BaseUtils.Key(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id, CardExchangeManager.Instance.SurpriseShopTag))

    local lastDay = math.ceil((lastTime + 1) / 86400)
    local thisDay = math.ceil((BaseUtils.BASE_TIME + 1) / 86400)

    return lastDay ~= thisDay
end

--集字兑换活动
function CampaignRedPointManager:CheckCollectionWordExchangeRed(id)
    local collect_word_data = CardExchangeManager.Instance.model.collect_word_data
    if collect_word_data == nil or collect_word_data.plans == nil then return false end
    for _,v in ipairs(collect_word_data.plans) do
        CardExchangeManager.Instance.model.collect_word_redpoint[v.plan_id] = false
        if v.items ~= nil then 
            CardExchangeManager.Instance.model.collect_word_redpoint[v.plan_id] = true
            for __,val in ipairs(v.items) do
                if (v.times == v.all_times) or BackpackManager.Instance:GetItemCount(val.item_base_id) == 0 then 
                    CardExchangeManager.Instance.model.collect_word_redpoint[v.plan_id] = false
                    break
                end
            end
        end
    end
    
    local flag = false
    for _,v in ipairs(CardExchangeManager.Instance.model.collect_word_redpoint) do
        if v then 
            flag = true
            break
        end
    end
    return flag
end


function CampaignRedPointManager:CheckScratchCardRed(id)
    local red = false
    local campData = DataCampaign.data_list[id]
    local consumeId = campData.loss_items[1][1]
    local num = BackpackManager.Instance:GetItemCount(consumeId)
    if num > 0 then
        red = true
    end
    return red
end

--直购礼包活动
function CampaignRedPointManager:CheckDirectPackageRed(id)
    return SignDrawManager.Instance.model:GetDirectPackageRedPointStatus()
end

--幸运树活动
function CampaignRedPointManager:CheckLuckyTreeRed(id)
    local data = CampaignProtoManager.Instance.model.luckytreeData
    local costItemId = data.cost_item

    local have_num = BackpackManager.Instance:GetItemCount(costItemId) 
    local need_num = data.num or 0

    local lastTime = PlayerPrefs.GetInt(BaseUtils.Key(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id, CampaignProtoManager.Instance.LuckyTreeTag))
    local lastDay = math.ceil((lastTime + 1) / 86400)
    local thisDay = math.ceil((BaseUtils.BASE_TIME + 1) / 86400)

    return (not data.finishFlag) and ((have_num >= need_num) or (lastDay ~= thisDay)) 
end

--定制礼包活动
function CampaignRedPointManager:CheckCustomGiftRed(id)
    local key = CampaignProtoManager.Instance.model.customgift_key
    local last_key = CampaignProtoManager.Instance.model.customgift_lastkey
    return key ~= last_key
end


--战令活动
function CampaignRedPointManager:CheckWarOrderRed(id)
    local red1 = CampaignProtoManager.Instance.model:GetWarOrderRedStatus()
    local red2 = CampaignProtoManager.Instance.model:GetWarOrderQuestRedStatus()
    return red1 or red2
end

--祈愿宝阁活动
function CampaignRedPointManager:CheckPrayTreasureRed(id)
    return CampaignProtoManager.Instance.model:GetPrayTreasureMainRedStatus() or CampaignProtoManager.Instance.model:GetPrayTreasureShopRedStatus()
end


