-- @author zyh
-- @date 2017年7月25日
SummerCarnivalManager = SummerCarnivalManager or BaseClass(BaseManager)

function SummerCarnivalManager:__init()
    if SummerCarnivalManager.Instance ~= nil then
        return
    end

    SummerCarnivalManager.Instance = self
    self.model = SummerCarnivalModel.New(self)
    self.OnUpdateRedPoint = EventLib.New()

    self.totalCampaignId = 46
    self.redPointDic = {}
    self.onUpdateTabRedPoint = EventLib.New()
    self.onUpdateTabSecondRedPoint = EventLib.New()
    self.chargeUpdateEvent = EventLib.New()
    self.isOverDay = 0
    EventMgr.Instance:AddListener(event_name.role_attr_option_change,function() self:CheckRedPoint() end)
    EventMgr.Instance:AddListener(event_name.backpack_item_change,function() self:CheckRedPoint() end)
    EventMgr.Instance:AddListener(event_name.equip_item_change,function() self:CheckRedPoint() end)

    self:InitHandler()
end

function SummerCarnivalManager:InitHandler()
    -- self:AddNetHandler(17869, self.on17869)
    -- self:AddNetHandler(17870, self.on17870)
end

-- function SummerCarnivalManager:RequestInitData()
--     self:send17869()
-- end



function SummerCarnivalManager:OpenMainWindow(args)
    self.model:OpenMainWindow(args)
end

function SummerCarnivalManager:OpenTabWindow(args)
    self.model:OpenTabWindow(args)
end

function SummerCarnivalManager:OpenTabSecondWindow(args)
    self.model:OpenTabSecondWindow(args)
end

function SummerCarnivalManager:SetIcon()
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
    self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.summercarnival_main_window) end
    -- end

    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    -- if CampaignManager.Instance.campaignTree[CampaignEumn.Type.CampBox][CampaignEumn.CampBox.SummerQuest] ~= nil then
    --     self:Send10253()
    --     self:send17864()
    -- end
    self:CheckRedPoint()
end


function SummerCarnivalManager:__delete()
    self.model:DeleteMe()
end


function SummerCarnivalManager:CheckMainUIIconRedPoint()
    if MainUIManager.Instance.MainUIIconView ~= nil then
        self.isInit = true
        local icon_id = DataCampaign.data_camp_ico[self.totalCampaignId].ico_id
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(icon_id, self:IsNeedShowRedPoint())
    end
end

function SummerCarnivalManager:IsNeedShowRedPoint()
    for k, v in pairs(self.redPointDic) do
        if v then
            if k == CampaignEumn.SummerCarnival.Wish then
                return false
            else
                return v
            end
        end
    end
    return false
end

function SummerCarnivalManager:CheckRedPoint()

    for k, v in pairs(self.redPointDic) do
        self.redPointDic[k] = false
    end

    -- self:IsRedContinueChargePanel()
    -- self:IsRedHalloweenMoonPanel()
    -- self:IsRedCampaignRankPanel()

    self.redPointDic[CampaignEumn.SummerCarnival.Wish] = CampaignRedPointManager.Instance:CheckWishRedPoint()
    self.redPointDic[CampaignEumn.SummerCarnival.Recharge] = CampaignRedPointManager.Instance:CheckConsumeReturnReturn()
    self.redPointDic[CampaignEumn.SummerCarnival.Festival] = CampaignRedPointManager.Instance:CheckHundredPanel()

    if self.redPointDic[CampaignEumn.SummerCarnival.Festival] == false then
        self.redPointDic[CampaignEumn.SummerCarnival.Festival] = CampaignRedPointManager.Instance:CheckFlowerPanel()
    end
    self.onUpdateTabRedPoint:Fire()
    self.onUpdateTabSecondRedPoint:Fire()
    self.OnUpdateRedPoint:Fire()
    self:CheckMainUIIconRedPoint()
end


function SummerCarnivalManager:CheckWishRedPoint()
    local isRed = false
    if ValentineManager.Instance.model.wishCount ~= nil and ValentineManager.Instance.model.votiveCount ~= nil then
        if 1 - ValentineManager.Instance.model.wishCount == 0 then
            isRed = false
        else
            isRed = true
        end

        if 1 - ValentineManager.Instance.model.wishCount == 0 and 2 - ValentineManager.Instance.model.votiveCount == 2 then
            isRed = true
        elseif 1 - ValentineManager.Instance.model.wishCount == 0 and 2 - ValentineManager.Instance.model.votiveCount ~= 2 then
            isRed = false
        end
    end

    return isRed
end

function SummerCarnivalManager:CheckConsumeReturnReturn()
    local isRed = false
    local dataList = {}
    local temData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.SummerCarnival]
    if temData ~= nil then
        for index,v in pairs(temData) do
            if index ~= "count" then
                if v.sub[1].id == CampaignEumn.SummerCarnival.Recharge then
                    self.campaignGroup = CampaignManager.Instance.campaignTree[CampaignEumn.Type.SummerCarnival][v.index]
                    break
                end
            end
        end
    end


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
    return isRed
end

function SummerCarnivalManager:CheckHundredPanel()
    local isRed = false
    self.campaignData_cli = DataCampaign.data_list[CampaignEumn.SummerCarnival.Flowers]
    if self.campaignData_cli ~= nil then
        self.exchangeBaseId = self.campaignData_cli.loss_items[1][1]
        if self.exchangeBaseId ~= nil then
            if BackpackManager.Instance:GetItemCount(self.exchangeBaseId) > 0 then
                isRed = true
            end
        end
    end

    return isRed
end

function SummerCarnivalManager:CheckFlowerPanel()
    print("到我这里了吗？？？")
    local isRed = false
    self.perNum = 9
    local count = c or (ChildBirthManager.Instance.model.flowerData or {}).count or 0
    if count >= 7 * self.perNum then
        isRed = true
    end
    return isRed
end
