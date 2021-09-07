-- @author zhouyijun
-- @date 2017年5月18日

DragonBoatFestivalManager = DragonBoatFestivalManager or BaseClass(BaseManager)

DragonBoatFestivalManager.SYSTEM_ID = 338 --端午活动图标

function DragonBoatFestivalManager:__init()
    if DragonBoatFestivalManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    DragonBoatFestivalManager.Instance = self

    self.model = DragonBoatFestivalModel.New()
    self.redPointEvent = EventLib.New()

    self.redPointDic = {}
    self.getCampaignGetDailyRedFlag = false
    self.isCheckoutLogin = true

    --活动表ID列表
    self.menuId = {
        LoginReward =   593      -- 登录送礼
        ,Boat =         594      -- 赛龙舟
        ,Zongzi =       595      -- 包粽子
        ,Consume =      598      -- 累计消费
    }

    self.dumplingEvent = EventLib.New()
    self.exchangeEvent = EventLib.New()
    self:ReSortMenu()
    self:InitHandler()
end

function DragonBoatFestivalManager:__delete()
end

function DragonBoatFestivalManager:ReSortMenu()
    for k, id in pairs(self.menuId) do
        CampaignEumn.DragonBoatType[k] = DataCampaign.data_list[id].index
    end
end

function DragonBoatFestivalManager:InitHandler()
    self.redPointEvent:AddListener( function() self:CheckRedMainUI() end)

    EventMgr.Instance:AddListener(event_name.intimacy_my_data_update,
        function ()
            self:CheckRed()
            end)
    EventMgr.Instance:AddListener(event_name.intimacy_reward_data_update,
        function ()
            self:CheckRed()
            end)
    EventMgr.Instance:AddListener(event_name.campaign_get_update,
        function (data)
            self:GetCampaignGetDailyData(data)
        -- self:CheckRed()
        end)

    EventMgr.Instance:AddListener(event_name.backpack_item_change, function() self:CheckRed() end)

    self:AddNetHandler(17862, self.on17862)
    self:AddNetHandler(17863, self.on17863)
end




function DragonBoatFestivalManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function DragonBoatFestivalManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(DragonBoatFestivalManager.SYSTEM_ID)
    local tempData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.DragonBoatFestival]
     if tempData == nil then
        return
    end
    local campaignNum = #tempData
    for index,v in pairs(tempData) do
        if index == CampaignEumn.DragonBoatType.LoginReward then
            if self.isCheckoutLogin == false then
                campaignNum = campaignNum - 1
            end
        end
    end

    if campaignNum <= 0 then
        return
    end
    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[DragonBoatFestivalManager.SYSTEM_ID]
    self.activeIconData.id = iconData.id
    -- 335
    self.activeIconData.iconPath = iconData.res_name
    -- 335
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.dragon_boat_festival)
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    -- -
    self:CheckRed()
end

function DragonBoatFestivalManager:GetCampaignGetDailyData(data)

    if data ~= nil then

        if data.flag == 0 and data.num < 7 then
            self.getCampaignGetDailyRedFlag = true
        else
            self.getCampaignGetDailyRedFlag = false
        end


        if data.num >= 7 then
            self.isCheckoutLogin = false
            self:SetIcon()
        else
            self.isCheckoutLogin = true
        end
    end
    self:CheckRed()

end

function DragonBoatFestivalManager:CheckRed()
    local redList = {}
    for id, _ in pairs(self.redPointDic) do
        table.insert(redList, id)
    end
    for _, id in pairs(redList) do
        self.redPointDic[id] = nil
    end

    local campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.DragonBoatFestival]
    if campaignData ~= nil then
        if campaignData[CampaignEumn.DragonBoatType.LoginReward] ~= nil then
            for _, sub in pairs(campaignData[CampaignEumn.DragonBoatType.LoginReward].sub) do
                self.redPointDic[sub.id] = self.getCampaignGetDailyRedFlag
            end
        end
        if campaignData[CampaignEumn.DragonBoatType.Boat] ~= nil then
            for _, sub in pairs(campaignData[CampaignEumn.DragonBoatType.Boat].sub) do
                self.redPointDic[sub.id] =(#DataCampaign.data_list[sub.id].loss_items == 0 and(sub.status == CampaignEumn.Status.Finish))
            end
        end
        if campaignData[CampaignEumn.DragonBoatType.Zongzi] ~= nil then
            for _, sub in pairs(campaignData[CampaignEumn.DragonBoatType.Zongzi].sub) do
                local campaignData = DataCampaign.data_list[sub.id]
                local dumplingData = DataCampRiceDumplingData.data_get[tonumber(campaignData.reward_content)]

                local red = (dumplingData.limit == 0 or ((self.model.dumplingTab[dumplingData.id] or {}).times or 0) < dumplingData.limit)
                for _,v in ipairs(dumplingData.cost) do
                    red = red and (BackpackManager.Instance:GetItemCount(v[1]) >= v[2])
                end
                self.redPointDic[sub.id] = red
            end
        end
        if campaignData[CampaignEumn.DragonBoatType.Consume] ~= nil then
            for _, sub in pairs(campaignData[CampaignEumn.DragonBoatType.Consume].sub) do
                local red = false
                local data = CampaignManager.Instance:GetCampaignDataList(CampaignEumn.Type.DragonBoatFestival) --self:GetDataList()
                for _,v in ipairs(data) do
                    local baseData = DataCampaign.data_list[v.id]
                    if baseData ~= nil and baseData.index == CampaignEumn.DragonBoatType.Consume and v.status == CampaignEumn.Status.Finish then
                        red = true
                        break
                    end
                end
                self.redPointDic[sub.id] = red
            end
        end
    end
    self.redPointEvent:Fire()
end

function DragonBoatFestivalManager:CheckRedMainUI()
    local red = false
    if CampaignManager.Instance.campaignTree ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.DragonBoatFestival] ~= nil then
        for _,v in pairs(self.redPointDic) do
            red = red or (v == true)
        end
    end
    if MainUIManager.Instance.MainUIIconView ~= nil and self.activeIconData ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(self.activeIconData.id, red)
    end
end

function DragonBoatFestivalManager:RequireInitData()
    self:send17863()
end


function DragonBoatFestivalManager:send17862(id, count)
    Connection.Instance:send(17862, {id = id, count = count})
end

function DragonBoatFestivalManager:on17862(data)
    print("on17862")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.dumplingEvent:Fire(data.err_code, data.show)
    self.exchangeEvent:Fire(data.err_code)
end

function DragonBoatFestivalManager:send17863()
    Connection.Instance:send(17863, {})
end

function DragonBoatFestivalManager:on17863(data)
    --print("on17863")
    -- BaseUtils.dump(data, "on17863")
    local idList = {}
    for id,v in pairs(self.model.dumplingTab) do
        if v ~= nil then table.insert(idList, id) end
    end
    for _,id in ipairs(idList) do
        self.model.dumplingTab[id] = nil
    end
    for _,v in pairs(data.list) do
        self.model.dumplingTab[v.id] = v
    end
    self.dumplingEvent:Fire(data)
    if #data.list > 0 then
        DoubleElevenManager.Instance.canGetReward = false
    end
end
