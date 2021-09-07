OpenServerManager = OpenServerManager or BaseClass(BaseManager)

function OpenServerManager:__init()
    if OpenServerManager.Instance ~= nil then
        Logger.Error("单例不可重复实例化")
        return
    end
    OpenServerManager.Instance = self

    self.zeroBuyRedPoint = false

    self.model = OpenServerModel.New()

    self.onUpdateLucky = EventLib.New()
    self.onUpdateBaby = EventLib.New()
    self.onUpdatePhoto = EventLib.New()
    self.onUpdateCard = EventLib.New()
    self.onUpdateReward = EventLib.New()
    self.chargeUpdateEvent = EventLib.New()
    self.checkRed = EventLib.New()
    self.rotaryEvent = EventLib.New()
    self.onZeroBuyDataEvent= EventLib.New()                     --开服0元购
    self.rechargeUpdateEvent = EventLib.New()                   --新开服连充活动
    self.directBuyUpdateEvent = EventLib.New()                  --直购礼包活动
    self.valuePackageUpdateEvent = EventLib.New()               --超值礼包活动
    self.accumulativeRechargeUpdateEvent = EventLib.New()       --累积充值活动

    self.updateListener = function() self:SetIcon() end

    self.guildBabyList = {}

    self:InitNetHandler()

end

function OpenServerManager:__delete()
    if self.onZeroBuyDataEvent ~= nil then
        self.onZeroBuyDataEvent = nil
    end
end

function OpenServerManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function OpenServerManager:GetData(data)
    -- BaseUtils.dump(data, "<color=#FF0000>open_server_manager</color>")
    self.model:GetData(data)
end

function OpenServerManager:SetIcon()
    SevendayManager.Instance.onUpdateDiscount:RemoveListener(self.updateListener)

    if CampaignManager.Instance:IsNeedHideRechargeByPlatformChanleId() == true then
        return
    end

    SevendayManager.Instance.onUpdateDiscount:AddListener(self.updateListener)

    if self:IsShowMainUI() then
        self.activeIconData = AtiveIconData.New()
        local iconData = DataSystem.data_daily_icon[301]
        self.activeIconData.id = iconData.id
        self.activeIconData.iconPath = iconData.res_name
        self.activeIconData.sort = iconData.sort
        self.activeIconData.lev = iconData.lev
        self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.open_server_window) end

        MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
        self:CheckRed()
    else
        MainUIManager.Instance:DelAtiveIcon3(301)
    end
end

function OpenServerManager:CompareDate(date1, date2)
    BaseUtils.dump(date1, "date1")
    BaseUtils.dump(date2, "date2")
    if date1[1] < date2[1] then return true
    elseif date1[1] > date2[1] then return false
    else
        if date1[2] < date2[2] then return true
        elseif date1[2] > date2[2] then return false
        else
            if date1[3] < date2[3] then return true
            elseif date1[3] > date2[3] then return false
            else
                if date1[4] < date2[4] then return true
                elseif date1[4] > date2[4] then return false
                else
                    if date1[5] < date2[5] then return true
                    elseif date1[5] > date2[5] then return false
                    else return date1[6] < date2[6]
                    end
                end
            end
        end
    end
end

function OpenServerManager:InitNetHandler()
    self:AddNetHandler(14005, self.on14005)
    self:AddNetHandler(14095, self.on14095)
    self:AddNetHandler(17812, self.on17812)
    self:AddNetHandler(17813, self.on17813)
    self:AddNetHandler(17814, self.on17814)
    self:AddNetHandler(17815, self.on17815)
    self:AddNetHandler(17816, self.on17816)
    self:AddNetHandler(17817, self.on17817)
    self:AddNetHandler(17818, self.on17818)
    self:AddNetHandler(14098, self.On14098)

    self:AddNetHandler(20441, self.on20441)
    self:AddNetHandler(20442, self.on20442)
    self:AddNetHandler(20470, self.on20470)
    self:AddNetHandler(20471, self.on20471)
    self:AddNetHandler(20472, self.on20472)
    self:AddNetHandler(20473, self.on20473)
    self:AddNetHandler(20474, self.on20474)
    self:AddNetHandler(20475, self.on20475)
    self:AddNetHandler(20476, self.on20476)
    self:AddNetHandler(20477, self.on20477)
    self:AddNetHandler(20478, self.on20478)


    EventMgr.Instance:AddListener(event_name.seven_day_charge_upgrade, function() self:SetIcon() end)
    EventMgr.Instance:AddListener(event_name.seven_day_halfprice_upgrade, function() self:SetIcon() end)
    EventMgr.Instance:AddListener(event_name.role_level_change, function() self:SetIcon() end)
end

function OpenServerManager:send14005()
    Connection.Instance:send(14005, {})
end

function OpenServerManager:on14005(data)
    --BaseUtils.dump(data, "接收14005")
    self.guildBabyList = data.list
    table.sort(self.guildBabyList, function(a,b) return a.rank < b.rank end)

    self.onUpdateBaby:Fire()
end

function OpenServerManager:send14095()
    Connection.Instance:send(14095, {})
end

function OpenServerManager:on14095(data)
    self.model.gold_14095 = data.gold
end
-- 开服限时礼包购买列表
function OpenServerManager:send17812()
    Connection.Instance:send(17812, {})
end

function OpenServerManager:on17812(data)
    self.model.rewardData = data
    self.onUpdateReward:Fire()
end
-- 购买开服限时礼包
function OpenServerManager:send17813(id)
    Connection.Instance:send(17813, {id = id})
end

function OpenServerManager:on17813(data)
    if data.op_code == 1 then
        if self.model.rewardData ~= nil then
            table.insert(self.model.rewardData.list, {id = data.id})
        end
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.onUpdateReward:Fire()
end
--请求开服翻牌数据
function OpenServerManager:send17814()
    Connection.Instance:send(17814, {})
end

function OpenServerManager:on17814(data)
    -- self.model.cardData = data
    -- self.onUpdateCard:Fire()

    -- BaseUtils.dump(data, "<color='#00ff00'>开服的翻牌数据啊啊啊啊啊啊啊啊啊啊啊啊</color>")
    local model = self.model

    model.receiveNum = 0
    model.baseIdList = {}
    model.allOpen = true
    model.notOpen = true
    local tab = {}

    for k,v in pairs(data.card_list) do
        if v.flag ~= 0 then
            model.receiveNum = model.receiveNum + 1
            tab[v.flag] = v
        end
        model.allOpen = model.allOpen and (v.flag ~= 0)
        model.notOpen = model.notOpen and (v.flag == 0)
        table.insert(model.baseIdList, v)
    end

    if model.cardData == nil then       -- 登录请求
        model.cardData = model.cardData or {}
        if model.notOpen == true then
            model.cardData.card_list = model.baseIdList
        else
            model.cardData.card_list = tab
        end
        model.cardData.temp_list = data.card_list
        model.cardData.times = data.times
        self.onUpdateCard:Fire(false)
    else
        if #model.cardData.temp_list == 0 and model.notOpen == true then      -- 执行了派牌
            model.cardData.card_list = model.baseIdList
            model.cardData.temp_list = data.card_list
            model.cardData.times = data.times
            self.onUpdateCard:Fire(true)
        elseif #data.card_list == 0 then                                    -- 可认为是0点更新
            model.cardData.card_list = tab
            model.cardData.temp_list = data.card_list
            model.cardData.times = data.times
            self.onUpdateCard:Fire(data.times == 4)
        else
            model.cardData.card_list = tab
            model.cardData.temp_list = data.card_list
            model.cardData.times = data.times
            if #model.cardData.card_list == 0 and data.times == 4 then
                self.onUpdateCard:Fire(true)
            else
                self.onUpdateCard:Fire(false)
            end
        end
    end
    self:CheckRed()
end

function OpenServerManager:send17815()
    Connection.Instance:send(17815, {})
end

function OpenServerManager:on17815(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function OpenServerManager:send17816(order)
    Connection.Instance:send(17816, {order = order})
end

function OpenServerManager:on17816(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function OpenServerManager:RequestInitData()
    self.model.gold_14095 = 0
    NewMoonManager.Instance:send14091()
    self:send14095()
    self:send17812()
    self:send17814()
    self:send17817()
    self:send20441()
    self:send20470()
    self:send20473()
    self:send20475()
end


function OpenServerManager:CheckRed()
    local model = self.model
    local campaignMgr = CampaignManager.Instance

    campaignMgr.redPointDic[374] = false
    local red = false
    local activity = (AgendaManager.Instance.activitypoint or {}).activity or 0
    if model.cardData ~= nil and model.cardData.times < 8 and DataCampaignCard.data_times[model.cardData.times+1] then
        local data = DataCampaignCard.data_times[model.cardData.times+1]
        if (data.need_lev == 0 or data.need_lev <= RoleManager.Instance.RoleData.lev)
            and (data.need_activity == 0 or data.need_activity <= activity) and #data.loss == 0 then
            red = true
        end
    end

    -- 七天乐享
    -- 这是个假活动
    campaignMgr.redPointDic[509] = false
    -- local dataItemList = ((CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer] or {})[CampaignEumn.OpenServerType.Online] or {}).sub or {}
    -- for i,v in ipairs(dataItemList) do
    --     if v.status == CampaignEumn.Status.Finish then
    --         campaignMgr.redPointDic[509] = true
    --         break
    --     end
    -- end
    local id1,id2 = self:CheckSeven()

    if id1 ~= nil then
        campaignMgr.redPointDic[509] = campaignMgr.redPointDic[509] or (DataGoal.data_discount[id1].price == 0 and SevendayManager.Instance:GetRechargeCount() >= DataGoal.data_discount[id1].day_charge and SevendayManager.Instance.model.discountTab[id1] == nil)
        campaignMgr.redPointDic[509] = campaignMgr.redPointDic[509] or (DataGoal.data_discount[id2].price == 0 and SevendayManager.Instance:GetRechargeCount() >= DataGoal.data_discount[id2].day_charge and SevendayManager.Instance.model.discountTab[id2] == nil)
    end

    campaignMgr.redPointDic[374] = red or (CampaignManager.Instance.campaignTab[374] ~= nil and model.cardData ~= nil and #model.cardData.temp_list == 0 and  model.cardData.times == 0)

    -- campaignMgr.redPointDic[81] =

    -- 在线奖励
    campaignMgr.redPointDic[501] = false
    local dataItemList = ((CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer] or {})[CampaignEumn.OpenServerType.Online] or {}).sub or {}
    for i,v in ipairs(dataItemList) do
        if v.status == CampaignEumn.Status.Finish then
            campaignMgr.redPointDic[501] = true
            red = red or true
            break
        end
    end

    --0元购活动
    if RoleManager.Instance.RoleData.lev >= 40 then
        campaignMgr.redPointDic[1010] = self.zeroBuyRedPoint
    else
        campaignMgr.redPointDic[1010] = false
    end

    --消费有礼
    campaignMgr.redPointDic[81] = false
    local consumreturnDataList = self.model:GetConsumeReturnDataList()
    for i,v in ipairs(consumreturnDataList) do
        if v.status == 1 then
            campaignMgr.redPointDic[81] = true
            break
        end
    end

    --连充惊喜
    campaignMgr.redPointDic[1011] = self.model:CheckContinuousRechargeRedPointStatus(self.model.data20471)
    --萌萌喵喵
    campaignMgr.redPointDic[1012] = self.model:CheckDirectBuyRedPointStatus(self.model.data20473)
    --超值礼包2
    campaignMgr.redPointDic[1013] = false
    --累充活动
    campaignMgr.redPointDic[1014] = self.model:CheckAccumulativeRechargeRedPointStatus(self.model.data20477)
    --抽奖活动
    campaignMgr.redPointDic[1015] = self.model:CheckToyRewardRedPointStatus(1015)


    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(301, campaignMgr.redPointDic[374] or campaignMgr.redPointDic[81] or campaignMgr.redPointDic[509] 
            or campaignMgr.redPointDic[501] or campaignMgr.redPointDic[1010] or campaignMgr.redPointDic[81] or campaignMgr.redPointDic[1011] or campaignMgr.redPointDic[1012] 
            or campaignMgr.redPointDic[1013] or campaignMgr.redPointDic[1014] or campaignMgr.redPointDic[1015])
    end

    self.checkRed:Fire()
end

function OpenServerManager:send17817()
    -- print("<color='#00ff00'>send17817</color>")
    Connection.Instance:send(17817, {})
end

function OpenServerManager:on17817(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>on17817</color>")
    self.model.chargeData = self.model.chargeData or {}

    self.model.chargeData.day_now = data.day_now
    self.model.chargeData.first_time = data.first_time
    self.model.chargeData.reward = self.model.chargeData.reward or {}
    for k,_ in pairs(self.model.chargeData.reward) do
        self.model.chargeData.reward[k] = nil
    end
    for i,v in ipairs(data.reward) do
        self.model.chargeData.reward[v.day_id] = v
    end
    self.chargeUpdateEvent:Fire()
    -- self:CheckRedPoint()
    FirstRechargeManager.Instance:SetIcon()
end

function OpenServerManager:send17818(id)
    Connection.Instance:send(17818, {id = id})
end

function OpenServerManager:on17818(data)
    -- BaseUtils.dump(data, "on17818")
    if data.err_code ~= 1 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

-- 检查今天应该显示哪两个七天乐享礼包，返回nil,nil表示不显示
function OpenServerManager:CheckSeven()
    local sevenData = (BibleManager.Instance.servenDayData or {}).seven_day or {}

    local ry = tonumber(os.date("%Y", RoleManager.Instance.RoleData.time_reg))
    local rm = tonumber(os.date("%m", RoleManager.Instance.RoleData.time_reg))
    local rd = tonumber(os.date("%d", RoleManager.Instance.RoleData.time_reg))

    local ty = tonumber(os.date("%Y", BaseUtils.BASE_TIME))
    local tm = tonumber(os.date("%m", BaseUtils.BASE_TIME))
    local td = tonumber(os.date("%d", BaseUtils.BASE_TIME))

    local nowTime = os.time{year = ty, month = tm, day = td, hour = 0, min = 0, sec = 0}
    local regTime = os.time{year = ry, month = rm, day = rd, hour = 0, min = 0, sec = 0}

    if regTime == nil or nowTime == nil or nowTime - regTime < 0 then
        return nil, nil
    end

    --新开服节点不开此活动
    local time_stamp = (DataCampaign.data_new_camp_open[RoleManager.Instance.RoleData.platform] or {}).time_stamp
    if time_stamp and CampaignManager.Instance.open_srv_time >= time_stamp then 
        return nil, nil
    end


    local dis = (nowTime - regTime) / 86400 + 1

    if dis > 7 then
        return nil, nil
    else
        local tab = {}
        for _,v in pairs(DataGoal.data_discount) do
            if v.day == dis and v.id > 7 then
                table.insert(tab, v.id)
            end
        end
        -- BaseUtils.dump(tab, "tab")
        if DataGoal.data_discount[tab[1]].price < DataGoal.data_discount[tab[2]].price then
            return tab[1],tab[2]
        else
            return tab[2],tab[1]
        end
    end
end

-- 是否显示开服活动
function OpenServerManager:IsShowMainUI()
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer] ~= nil or CampaignManager.Instance.campaignTree[CampaignEumn.Type.OpenServer1] ~= nil then
        return true
    elseif RoleManager.Instance.RoleData.time_reg <= CampaignManager.Instance.open_srv_time + 86400 * 14 and self:CheckSeven() ~= nil then
        return true
    else
        return false
    end
end

-- 抽奖
function OpenServerManager:Send14098()
  -- print("发送14098")
    Connection.Instance:send(14098, {})
end

function OpenServerManager:On14098(data)
    -- BaseUtils.dump(data, "On14098")
    self.rotaryEvent:Fire(data)
end

function OpenServerManager:OpenRewardPanel(args)
    self.model:OpenRewardPanel(args)
end

--开服0元购活动
function OpenServerManager:send20441()
    Connection.Instance:send(20441, {})
end

function OpenServerManager:on20441(data)
    if data ~=  nil then
        self.model.zerobuydata = data.list
        self.zeroBuyRedPoint = (data.list[1].list[1].status == 1)
        self.onZeroBuyDataEvent:Fire()
        self:CheckRed()
    end
end

function OpenServerManager:send20442(id,period)
    Connection.Instance:send(20442, {id = id,period = period})
    self:send20441()
end

function OpenServerManager:on20442(data)
    if data ~= nil then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
    --BaseUtils.dump(data, "接收14005")
end

--新开服连充活动
function OpenServerManager:send20470()
    -- print("发送20470")
    Connection.Instance:send(20470, {})
end

function OpenServerManager:on20470(data)
    BaseUtils.dump(data, "接收20470")
    self.model.continuousRechargeData = data or {}
end

--新开服连充活动玩家信息
function OpenServerManager:send20471()
    -- print("发送20471")
    Connection.Instance:send(20471, {})
end

function OpenServerManager:on20471(data)
    -- BaseUtils.dump(data, "接收20471")
    self.rechargeUpdateEvent:Fire(data)
    self.model.data20471 = data
    self:CheckRed()
end

--新开服连充领取奖励
function OpenServerManager:send20472(day)
    -- print("发送20472")
    Connection.Instance:send(20472, {day_id = day})
end

function OpenServerManager:on20472(data)
    BaseUtils.dump(data, "接收20472")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--开服养成直购礼包
function OpenServerManager:send20473()
    -- print("发送20473")
    Connection.Instance:send(20473, {})
end

function OpenServerManager:on20473(data)
    -- BaseUtils.dump(data, "接收20473")
    self.directBuyUpdateEvent:Fire(data)
    self.model.data20473 = data
    self:CheckRed()
end

--开服养成领活跃奖励
function OpenServerManager:send20474()
    -- print("发送20474")
    Connection.Instance:send(20474, {})
end

function OpenServerManager:on20474(data)
    -- BaseUtils.dump(data, "接收20474")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--新开服超值礼包
function OpenServerManager:send20475()
    -- print("发送20475")
    Connection.Instance:send(20475, {})
end

function OpenServerManager:on20475(data)
    -- BaseUtils.dump(data, "接收20475")
    self.valuePackageUpdateEvent:Fire(data)
end

--购买新开服超值礼包
function OpenServerManager:send20476(group_id)
    -- print("发送20476")
    Connection.Instance:send(20476, {group_id = group_id})
end

function OpenServerManager:on20476(data)
    -- BaseUtils.dump(data, "接收20476")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--新开服累充活动
function OpenServerManager:send20477()
    -- print("发送20477")
    Connection.Instance:send(20477, {})
end

function OpenServerManager:on20477(data)
    -- BaseUtils.dump(data, "接收20477")
    self.accumulativeRechargeUpdateEvent:Fire(data)
    self.model.data20477 = data
    self:CheckRed()
end

--领取新开服累充礼包
function OpenServerManager:send20478(group_id)
    -- print("发送20478")
    Connection.Instance:send(20478, {group_id = group_id})
end

function OpenServerManager:on20478(data)
    -- BaseUtils.dump(data, "接收20478")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end