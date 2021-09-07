SpringFestivalManager = SpringFestivalManager or BaseClass(BaseManager)

function SpringFestivalManager:__init()
    if SpringFestivalManager.Instance ~= nil then
        Log.Error("不可重复实例化 SpringFestivalManager")
        return
    end
    SpringFestivalManager.Instance = self

    self.model = SpringFestivalModel.New()

    self.redPointDic = {}

    self.onCheckRed = EventLib.New()

    self:InitHandler()

    self.menuId = {
        Recharge = 400,           -- 春节返利
        GroupPurchase = 401,      -- 新春抢购日
        Continue = 402,           -- 感恩连充
        NewYearGoods = 403,       -- 年货
        Snowman = 419,            -- 雪人大挑战
        SnowFight = 420,          -- 欢乐打雪仗
        Pumpkin = 421,            -- 调皮南瓜
        HideAndSeek = 422,        -- 捉迷藏
        Ski = 423,                -- 新春滑雪（改划龙舟）
        LuckyMoney = 424,        -- 压岁钱
        Exchange = 425,          -- 兑换商店
    }

    self.OnUpdateLuckMoney = EventLib.New()
    self.OnUpdateLuckMoneyOpen = EventLib.New()

    self:ReSortMenu()
end

function SpringFestivalManager:ReSortMenu()
    for k,id in pairs(self.menuId) do
        CampaignEumn.SpringFestivalType[k] = DataCampaign.data_list[id].index
    end
end

function SpringFestivalManager:__delete()
    self.OnUpdateLuckMoney:DeleteMe()
    self.OnUpdateLuckMoney = nil
    self.OnUpdateLuckMoneyOpen:DeleteMe()
    self.OnUpdateLuckMoneyOpen = nil
end

function SpringFestivalManager:InitHandler()
    self:AddNetHandler(18700, self.On18700)
    self:AddNetHandler(18701, self.On18701)
    self.onCheckRed:AddListener(function() self:CheckRedMainUI() end)

    EventMgr.Instance:AddListener(event_name.campaign_change, function() self:CheckPumpkin() end)
    EventMgr.Instance:AddListener(event_name.campaign_change, function() self:CampaignChange() end)
end

function SpringFestivalManager:CheckPumpkin()
    EventMgr.Instance:RemoveListener(event_name.scene_load, HalloweenManager.Instance.mapListener)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival] ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival][CampaignEumn.SpringFestivalType.Pumpkin] ~= nil then
        EventMgr.Instance:AddListener(event_name.scene_load, HalloweenManager.Instance.mapListener)
    end
end

function SpringFestivalManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(326)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival] == nil then
        return
    end
    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[326]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
        local count = CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival].count
        if count == 1 and CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival][CampaignEumn.SpringFestivalType.Exchange] ~= nil then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.spring_festival_exchange)
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.spring_festival)
        end
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)

    self:CampaignChange()
end

function SpringFestivalManager:RequestInitData()
    self:CheckPumpkin()
    self:Send18700()

    self.model.round_id = 1
    self.model.day = 1
    self.model.start_time = 0
    self.model.end_time = 0
    self.model.lucky_money_data = {}
end

function SpringFestivalManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function SpringFestivalManager:Send18700()
    Connection.Instance:send(18700, { })
end

function SpringFestivalManager:On18700(data)
    -- print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")print("!")
    -- BaseUtils.dump(data, "On18700")
    self.model.round_id_now = data.round_id_now
    self.model.start_time = data.start_time
    self.model.end_time = data.end_time

    self.model.day = data.day + (data.round_id_now - 1) * 5

    self.model.lucky_money_data = {}
    for _,value in pairs(DataLuckyMoney.data_lucky_money) do -- 没数据的时候初始化数据
        self.model.lucky_money_data[value.id] = { id = value.id, round_id = value.round_id, index = value.index, status = 0}
    end
    for i,value in ipairs(data.lists) do -- 写入服务端数据
        local v = self.model.lucky_money_data[value.id]
        v.id = value.id
        v.round_id = value.round_id
        v.day = value.day
        v.status = value.status
        v.limit = value.limit
        v.assets_type = value.assets_type
        v.assets_value = value.assets_value
        v.init_value = value.init_value
    end
    for i,value in ipairs(self.model.lucky_money_data) do -- 服务端不更新过期数据，只能客户端自己更新
        if value.status == 0 and value.index < self.model.day then
            value.status = 2
            local data_lucky_money = DataLuckyMoney.data_lucky_money[value.id]
            value.assets_type = data_lucky_money.assets_type
            value.init_value = data_lucky_money.assets_value
            value.assets_value = 0
        elseif value.status == 1 and value.index < self.model.day then
            value.status = 2
        end
    end

    -- BaseUtils.dump(self.model.lucky_money_data, "On18700   2")
    local showRed = false
    for i,value in ipairs(self.model.lucky_money_data) do -- 最后根据服务端发来的和客户端自己写的数据计算红点
        if ((value.status == 0 or value.status == 1) and value.index - self.model.day <= 0) or (value.status == 2 and value.round_id * 5 + 1 - self.model.day <= 0 ) then
            showRed = true
        end
    end
    self:SetRed(424, showRed)

    self.OnUpdateLuckMoney:Fire()
end

function SpringFestivalManager:Send18701(id)
    -- print("Send18701")
    -- print(id)
    Connection.Instance:send(18701, { id = id })
end

function SpringFestivalManager:On18701(data)
    -- print("Open18701")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.OnUpdateLuckMoneyOpen:Fire()
    end
end

function SpringFestivalManager:OpenExchange()
    self.model:OpenExchange(args)
end

function SpringFestivalManager:SetRed(id, isRed)
    self.redPointDic[id] = isRed
    self.onCheckRed:Fire()
end

function SpringFestivalManager:CheckRedMainUI()
    local red = false
    if CampaignManager.Instance.campaignTree ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival] ~= nil then
        for k,v in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival]) do
            if k ~= "count" then
                for _,sub in ipairs(v.sub) do
                    red = red or (CampaignManager.Instance.campaignTab[sub.id] ~= nil and self.redPointDic[sub.id] == true)
                end
            end
        end
    end
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(326, red)
    end
end

function SpringFestivalManager:CampaignChange()
    if CampaignManager.Instance.campaignTree ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival] ~= nil then
        -- 年货红点
        if CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival][CampaignEumn.SpringFestivalType.NewYearGoods] ~= nil then
            for _,v in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.SpringFestival][CampaignEumn.SpringFestivalType.NewYearGoods].sub) do
                local campData = DataCampaign.data_list[v.id]
                if #campData.loss_items == 0 then
                    self:SetRed(v.id, v.status == CampaignEumn.Status.Finish)
                end
            end
        end
    end
end
