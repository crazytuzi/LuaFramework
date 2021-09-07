-- @author 黄耀聪
-- @date 2017年5月12日

MayIOUManager = MayIOUManager or BaseClass(BaseManager)

MayIOUManager.SYSTEM_ID = 337

function MayIOUManager:__init()
    if MayIOUManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    MayIOUManager.Instance = self

    self.model = MayIOUModel.New()
    self.redPointEvent = EventLib.New()

    self.redPointDic = {}

    self.menuId = {
        Recharge = 587         -- 心意相连
        ,Hand = 588         -- 执子之手
        ,Chocolate = 589    -- 情意绵绵
        ,Intimacy = 744       --亲密度排行榜活动
    }

    self:ReSortMenu()
    self:InitHandler()
end

function MayIOUManager:__delete()
end

function MayIOUManager:ReSortMenu()
    for k, id in pairs(self.menuId) do
        CampaignEumn.MayIOUType[k] = DataCampaign.data_list[id].index
    end
end

function MayIOUManager:InitHandler()
    self.redPointEvent:AddListener( function() self:CheckRedMainUI() end)
    EventMgr.Instance:AddListener(event_name.intimacy_my_data_update,
    function ()
        self:CheckRed()
    end)
    EventMgr.Instance:AddListener(event_name.intimacy_reward_data_update,
    function ()
        self:CheckRed()
    end)
end

function MayIOUManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function MayIOUManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(MayIOUManager.SYSTEM_ID)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU] == nil then
        return
    end

    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[MayIOUManager.SYSTEM_ID]
    self.activeIconData.id = iconData.id
    -- 335
    self.activeIconData.iconPath = iconData.res_name
    -- 335
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.may_iou_window)
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    -- -
    self:CheckRed()
end

function MayIOUManager:CheckRed()
    local redList = {}
    for id, _ in pairs(self.redPointDic) do
        table.insert(redList, id)
    end
    for _, id in pairs(redList) do
        self.redPointDic[id] = nil
    end

    local campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU]
    if campaignData ~= nil then
        if campaignData[CampaignEumn.MayIOUType.Chocolate] ~= nil then
            for i, sub in pairs(campaignData[CampaignEumn.MayIOUType.Chocolate].sub) do
                self.redPointDic[sub.id] =(#DataCampaign.data_list[sub.id].loss_items == 0 and(sub.status == CampaignEumn.Status.Finish) and(AgendaManager.Instance:GetActivitypoint() >= 100))
            end
        end

        if campaignData[CampaignEumn.MayIOUType.Recharge] ~= nil then
            for _, sub in pairs(campaignData[CampaignEumn.MayIOUType.Recharge].sub) do
                local red = false
                if NewMoonManager.Instance.model.chargeData ~= nil and NewMoonManager.Instance.model.chargeData.reward ~= nil then
                    for _, v in ipairs(NewMoonManager.Instance.model.chargeData.reward) do
                        if v.day_status == 1 then
                            red = true
                        end
                    end
                end
                self.redPointDic[sub.id] = red
                break
            end
        end
        if CampaignManager.Instance:CheckIntimacy() then
            local red = false
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
            self.redPointDic[MayIOUManager.Instance.menuId.Intimacy] = red
        end
    end
    self.redPointEvent:Fire()
end

function MayIOUManager:CheckRedMainUI()
    local red = false
    if CampaignManager.Instance.campaignTree ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.MayIOU] ~= nil then
        for _,v in pairs(self.redPointDic) do
            red = red or (v == true)
        end
    end
    if MainUIManager.Instance.MainUIIconView ~= nil and self.activeIconData ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(self.activeIconData.id, red)
    end
end
