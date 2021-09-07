BigSummerManager = BigSummerManager or BaseClass(BaseManager)

function BigSummerManager:__init()
    if BigSummerManager.Instance ~= nil then
        return
    end

    BigSummerManager.Instance = self
    self.model = BigSummerModel.New(self)
    self.OnUpdateRedPoint = EventLib.New()

    self.totalCampaignId = 45
    self.redPointDic = {}

    self.chargeUpdateEvent = EventLib.New()
    self.isOverDay = 0
    -- EventMgr.Instance:AddListener(event_name.campaign_rank_my_data_update,function() self:CheckRedPoint() end)


    self:InitHandler()
end

function BigSummerManager:InitHandler()
    -- self:AddNetHandler(17869, self.on17869)
    -- self:AddNetHandler(17870, self.on17870)
end

-- function BigSummerManager:RequestInitData()
--     self:send17869()
-- end



function BigSummerManager:OpenMainWindow(args)
    self.model:OpenMainWindow(args)
end


function BigSummerManager:SetIcon()
    local systemIconId = DataCampaign.data_camp_ico[self.totalCampaignId].ico_id
    MainUIManager.Instance:DelAtiveIcon3(systemIconId)
    if CampaignManager.Instance.campaignTree[self.totalCampaignId] == nil then
        return
    end

    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[systemIconId]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    local temdate = CampaignManager.Instance.campaignTree[self.totalCampaignId]
    local ttdata = { }
    local length = 1
    for k, v in pairs(temdate) do
        if k ~= "count" then
            ttdata[length] = v
            length = length + 1
        end
    end

    -- if #ttdata <= 1 and(ttdata[1].index == CampaignEumn.CampBox.CampBox) then
    --     self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campbox_tab_window) end
    -- elseif #ttdata <= 1 and(ttdata[1].index == CampaignEumn.CampBox.Exchange) then
    --     local datalist = { }
    --     local lev = RoleManager.Instance.RoleData.lev
    --     if ShopManager.Instance.model.datalist[2][20] ~= nil then
    --         for i, v in pairs(ShopManager.Instance.model.datalist[2][20]) do
    --             table.insert(datalist, v)
    --         end
    --     end
    --     self.activeIconData.clickCallBack = function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, { datalist = datalist, title = TI18N("夏日兑换"), extString = "{assets_2,90042}可在夏日翻翻乐活动中获得" }) end

    -- else
    self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.bigsummer_main_window) end
    -- end

    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    -- if CampaignManager.Instance.campaignTree[CampaignEumn.Type.CampBox][CampaignEumn.CampBox.SummerQuest] ~= nil then
    --     self:Send10253()
    --     self:send17864()
    -- end
    self:CheckRedPoint();
end


function BigSummerManager:__delete()
    self.model:DeleteMe()
end


function BigSummerManager:CheckMainUIIconRedPoint()
    if MainUIManager.Instance.MainUIIconView ~= nil then
        self.isInit = true
        local icon_id = DataCampaign.data_camp_ico[self.totalCampaignId].ico_id
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(icon_id, self:IsNeedShowRedPoint())
    end
end

function BigSummerManager:IsNeedShowRedPoint()
    for k, v in pairs(self.redPointDic) do
        if v then
            return v
        end
    end
    return false
end

function BigSummerManager:CheckRedPoint()

    for k, v in pairs(self.redPointDic) do
        self.redPointDic[k] = false
    end

    -- self:IsRedContinueChargePanel()
    -- self:IsRedHalloweenMoonPanel()
    -- self:IsRedCampaignRankPanel()



    self.OnUpdateRedPoint:Fire()
    self:CheckMainUIIconRedPoint()
end


