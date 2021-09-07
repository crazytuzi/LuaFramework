-- 2017/6/17
-- zhongyuhan
-- ??活动

CampBoxManager = CampBoxManager or BaseClass(BaseManager)

function CampBoxManager:__init()
    if CampBoxManager.Instance ~= nil then
        return
    end

    CampBoxManager.Instance = self
    self.model = CampBoxModel.New()
    self.OnUpdateRedPoint = EventLib.New()
    self.onUpdateTabRedPoint = EventLib.New()
    self.timer = nil

    self.redPointDic = { }
    self.redTabDic = { }
    self.isInit = false

   self.isLingQu = false

    self.totalCampaignId = 46
    self.campaignGroup = nil
    self:InitHandler()

    self.CampBoxData = nil
    self.FinishedList = { }
    self.DoingList = { }
    self.RewardedList = { }
    self.SumPoint = 0

    self.OnUpdateItemData = EventLib.New()
    self.OnUpdateTextData = EventLib.New()
    self.OnUpdateItemBtn = EventLib.New()

    self.OnSumQuestUpdate = EventLib.New()

    self.OnSumQuestUpdate:AddListener(
    function()
        self:CheckRedPoint()
    end )
    self.OnUpdateItemData:AddListener(
    function()
        self:CheckRedPoint()
    end )

    EventMgr.Instance:AddListener(event_name.backpack_item_change, function() self:send17864() end)
    EventMgr.Instance:AddListener(event_name.quest_update, function() self:CheckRedPoint() end)
    self.openNum = -1
    -- EventMgr.Instance:AddListener(event_name.campaign_change,function() self:CheckRedPoint() end)
    -- EventMgr.Instance:AddListener(event_name.sleepmanager_onresume,function() self:CheckRedPoint() end)
    -- EventMgr.Instance:AddListener(event_name.role_asset_change,function() self:CheckRedPoint() end)
    -- EventMgr.Instance:AddListener(event_name.campaign_change,function() self:CheckRedPoint() end)
    -- EventMgr.Instance:AddListener(event_name.quest_update,function() self:CheckRedPoint() end)
    -- event_name.sleepmanager_onresume
end

function CampBoxManager:InitHandler()
    self:AddNetHandler(17864, self.on17864)
    self:AddNetHandler(17865, self.on17865)
    self:AddNetHandler(17866, self.on17866)
    self:AddNetHandler(17867, self.on17867)

    self:AddNetHandler(10253, self.On10253)
    self:AddNetHandler(10254, self.On10254)
end

function CampBoxManager:RequestInitData()
    -- if self.timer == nil then
    --     self.timer = LuaTimer.Add(1000,2000,function() self:CheckTimer() end)
    -- end
end
function CampBoxManager:OpenMainWindow(args)
    self.model:OpenMainWindow(args)
end

function CampBoxManager:OpenTabWindow(args)
    self.model:OpenTabWindow(args)
end

function CampBoxManager:SetIcon()
    self:CheckSummerDoingPoint()
    local systemIconId = DataCampaign.data_camp_ico[self.totalCampaignId].ico_id
    MainUIManager.Instance:DelAtiveIcon3(systemIconId)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.CampBox] == nil then
        return
    end

    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[systemIconId]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    local temdate = CampaignManager.Instance.campaignTree[CampaignEumn.Type.CampBox]
    local ttdata = { }
    local length = 1
    for k, v in pairs(temdate) do
        if k ~= "count" then
            ttdata[length] = v
            length = length + 1
        end
    end

    BaseUtils.dump(ttdata,"处理后的数据")

    if #ttdata <= 1 and(ttdata[1].index == CampaignEumn.CampBox.CampBox) then
        self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campbox_tab_window) end
    elseif #ttdata <= 1 and(ttdata[1].index == CampaignEumn.CampBox.Exchange) then
        local datalist = { }
        local lev = RoleManager.Instance.RoleData.lev
        if ShopManager.Instance.model.datalist[2][20] ~= nil then
            for i, v in pairs(ShopManager.Instance.model.datalist[2][20]) do
                table.insert(datalist, v)
            end
        end
        self.activeIconData.clickCallBack = function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, { datalist = datalist, title = TI18N("夏日兑换"), extString = "{assets_2,90042}可在夏日翻翻乐活动中获得" }) end

    else
        self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campbox_main_window) end
    end

    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    --if CampaignManager.Instance.campaignTree[CampaignEumn.Type.CampBox][CampaignEumn.CampBox.SummerQuest] ~= nil then
    if CampaignManager.Instance:GetCampaignData(811) ~= nil or CampaignManager.Instance.campaignTree[CampaignEumn.Type.CampBox][CampaignEumn.CampBox.SummerQuest] ~= nil then
        self:Send10253()
        self:send17864()
    end
end

function CampBoxManager:CheckSummerDoingPoint()
    if next(CampaignManager.Instance.model:GetIdsByType(CampaignEumn.ShowType.SummerDoing)) ~= nil then
        self:Send10253()
        self:CheckRedPoint()
    end
end



function CampBoxManager:__delete()
    self.model:DeleteMe()
end


function CampBoxManager:CheckMainUIIconRedPoint()
    if MainUIManager.Instance.MainUIIconView ~= nil then
        self.isInit = true
        local icon_id = DataCampaign.data_camp_ico[self.totalCampaignId].ico_id
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(icon_id, self:IsNeedShowRedPoint())
    end
end

function CampBoxManager:IsNeedShowRedPoint()
    for k, v in pairs(self.redPointDic) do
        if v then
            return v
        end
    end
    return false
end

function CampBoxManager:CheckRedPoint()
    for k, v in pairs(self.redPointDic) do
        self.redPointDic[k] = false
    end
    local isRed = false;
    for _, value in pairs(self.DoingList) do
        local tmp = DataQuestSummer.data_quest_point_list[value.quest_id];
        local questData = QuestManager.Instance:GetQuest(tmp.id)
        if questData ~= nil and questData.finish == QuestEumn.TaskStatus.Finish then
            isRed = true
            break
        end
    end
    if not isRed then
        for _, rewardItem in pairs(DataQuestSummer.data_reward_list) do
            if rewardItem.need_score <= self.SumPoint and not self:ChecSumIsReward(rewardItem.id) then
                isRed = true
                break
            end
        end
    end
    CampaignManager.Instance.campaignSummerRed = isRed
    CampaignManager.Instance.summer_questQuestChange:Fire()
    --self.redPointDic[CampaignEumn.CampBox.SummerQuest] = isRed
    --self.redPointDic[CampaignEumn.ShowType.SummerDoing] = isRed
    --self.redPointDic[CampaignEumn.CampBox.CampBox] = self:CheckCampBoxCanOpen()
    self.onUpdateTabRedPoint:Fire()
    self.OnUpdateRedPoint:Fire()    --summer_quest 更新任务界面显示
    --self:CheckMainUIIconRedPoint()  --主原始界面红点检测

    --EventMgr.Instance:Fire(event_name.camp_red_change)
end


function CampBoxManager:IsCheckCampaignAcive()

end

function CampBoxManager:CheckCampBoxCanOpen()

    local temdate = CampaignManager.Instance.campaignTree[CampaignEumn.Type.CampBox]

    if temdate == nil then
        return false
    end

    local ttdata = { }
    local length = 1
    for k, v in pairs(temdate) do
        if k ~= "count" then
            ttdata[length] = v
            length = length + 1
        end
    end

    local isActive = false
    for k,v in pairs(ttdata) do
        if v.index == CampaignEumn.CampBox.CampBox then
            isActive = true
        end
    end



    if self.openNum == -1 or isActive == false or self:CampBoxOpenTime() == false then
        return false
    end

    local openNum = self.openNum
    local costList = DataCampBox.data_campboxcost;
    local curCostItem;
    if #costList > 0 then
        for _, costItem in pairs(costList) do
            if costItem.min <= self.openNum + 1 and self.openNum + 1 <= costItem.max then
                curCostItem = costItem;
                break
            end
        end
        if curCostItem ~= nil then
            local hasNum = BackpackManager.Instance:GetItemCount(curCostItem.cost[1][1])
            local costNum = curCostItem.cost[1][2]

            if hasNum > costNum then
                return true
            else
                return false
            end
        end
    end
    return false
end


function CampBoxManager:CampBoxOpenTime()
     local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginTime = nil
    local endTime = nil
    -- local time = DataCampaign.data_list[3].time[1]
    local time = DataCampBox.data_campbox[1].day_time[1]
    beginTime = tonumber(os.time { year = y, month = m, day = d, hour = time[1], min = time[2], sec = time[3] })
    endTime = tonumber(os.time { year = y, month = m, day = d, hour = time[4], min = time[5], sec = time[6] })

    if baseTime <= endTime and baseTime >= beginTime then
        return true
    end

    return false
end


function CampBoxManager:send17864()
    -- print("发送协议17864")
    Connection.Instance:send(17864, { })

end

function CampBoxManager:send17865()
    -- print("发送协议17865")
    Connection.Instance:send(17865, { })
end

function CampBoxManager:send17866(posId)
    print(posId)
    local data = { pos = posId }
    -- BaseUtils.dump(data,"发送协议17866")
    Connection.Instance:send(17866, data)
end

function CampBoxManager:send17867()
    -- print("发送协议17867")
    Connection.Instance:send(17867, { })
end

---------------------------------------------

function CampBoxManager:on17864(data)
    -- BaseUtils.dump(data,"协议回调17864")
    self.CampBoxData = data
    self.OnUpdateItemData:Fire(data)
    self:CheckRedPoint()
    self.openNum = #data.pos_list
end

function CampBoxManager:on17865(data)
    -- BaseUtils.dump(data,"协议回调17865")
    if data ~= nil then
        self.OnUpdateTextData:Fire(data)
    end
end

function CampBoxManager:on17866(data)
    -- BaseUtils.dump(data,"协议回调17866")
    if data.err_code == 1 then
        self.OnUpdateItemBtn:Fire(data)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CampBoxManager:on17867(data)
    -- print("协议回调17867")
    if data.err_code == 1 then
        self:send17864()
        self:send17865()
    else
        self.needRefresh = false
    end

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CampBoxManager:Send10253()
    Connection.Instance:send(10253, { })
end

function CampBoxManager:On10253(data)
    self.SumPoint = data.score
    self.FinishedList = data.finish
    self.DoingList = data.doing
    self.RewardedList = data.rewarded
    self.OnSumQuestUpdate:Fire()
    --self:CheckRedPoint()
    --CampaignManager.Instance.model:CheckRedCondType(60) --CampaignEumn.ShowType.SummerDoing
    --CampaignManager.Instance.model:CheckRedCondType(61)
end

function CampBoxManager:Send10254(boxID)
    Connection.Instance:send(10254, { id = boxID })
end

function CampBoxManager:On10254(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CampBoxManager:ChecSumIsReward(tmpID)
    local reward = self.RewardedList[tmpID];
    if reward ~= nil then
        return reward.times > 0
    end
    return false;
end