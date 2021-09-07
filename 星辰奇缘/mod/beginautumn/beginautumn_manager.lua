-- @author zyh
-- @date 2017年7月28日
BeginAutumnManager = BeginAutumnManager or BaseClass(BaseManager)

function BeginAutumnManager:__init()
    if BeginAutumnManager.Instance ~= nil then
        return
    end

    BeginAutumnManager.Instance = self
    self.model = BeginAutumnModel.New(self)
    self.OnUpdateRedPoint = EventLib.New()
    self.OnUpdateShop = EventLib.New()
    self.OnUpdateShopData = EventLib.New()

    self.OnUpdateShopStatus = EventLib.New()
    self.OnUpdateShopRed = EventLib.New()

    self.totalCampaignId = 47
    self.redPointDic = {}

    self.shopDataList = nil
    self.isInit = false

    self.isInitShop = false
    self.isOpeningShop = false
    self.start = false

    EventMgr.Instance:AddListener(event_name.role_asset_change,function() self:CheckRedPoint() end)
    EventMgr.Instance:AddListener(event_name.backpack_item_change,function() self:CheckRedPoint() end)
    -- EventMgr.Instance:AddListener(event_name.role_attr_option_change,function() self:CheckRedPoint() end)
    -- EventMgr.Instance:AddListener(event_name.backpack_item_change,function() self:CheckRedPoint() end)
    -- EventMgr.Instance:AddListener(event_name.equip_item_change,function() self:CheckRedPoint() end)

    self:InitHandler()
end

function BeginAutumnManager:InitHandler()
    self:AddNetHandler(17846, self.on17846)
    self:AddNetHandler(17845, self.on17845)

    self:AddNetHandler(17871,self.on17871)
    self:AddNetHandler(17872,self.on17872)
    self:AddNetHandler(17873,self.on17873)
    self:AddNetHandler(17874,self.on17874)

end

function BeginAutumnManager:RequestInitData()
    self:send17874()
    self:send17871()
    self:send17845()
end



function BeginAutumnManager:OpenMainWindow(args)
    self.model:OpenMainWindow(args)
end


function BeginAutumnManager:SetIcon()
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
    self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.beginautumn_main_window) end
    -- end

    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    -- if CampaignManager.Instance.campaignTree[CampaignEumn.Type.CampBox][CampaignEumn.CampBox.SummerQuest] ~= nil then
    --     self:Send10253()
    --     self:send17864()
    -- end
    self:CheckRedPoint()
end


function BeginAutumnManager:__delete()
    self.model:DeleteMe()
end


function BeginAutumnManager:CheckMainUIIconRedPoint()
    if MainUIManager.Instance.MainUIIconView ~= nil then
        local icon_id = DataCampaign.data_camp_ico[self.totalCampaignId].ico_id
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(icon_id, self:IsNeedShowRedPoint())
    end
end

function BeginAutumnManager:IsNeedShowRedPoint()
    for k, v in pairs(self.redPointDic) do
        if v then
            -- if k == CampaignEumn.SummerCarnival.Wish then
            --     return false
            -- else
            --     return v
            -- end
            return v
        end
    end
    return false
end

function BeginAutumnManager:CheckRedPoint()

    for k, v in pairs(self.redPointDic) do
        if k ~=  CampaignEumn.BeginAutumn.TimeShop then
            self.redPointDic[k] = false
        end
    end


    -- if self.redPointDic[CampaignEumn.SummerCarnival.Festival] == false then
    --     self.redPointDic[CampaignEumn.SummerCarnival.Festival] = CampaignRedPointManager.Instance:CheckFlowerPanel()
    -- end
    if self.start == false then
        self.redPointDic[CampaignEumn.BeginAutumn.TimeShop] = true
        self.start = true
    end

    self.redPointDic[CampaignEumn.BeginAutumn.RechargeGift] = CampaignRedPointManager.Instance:RechargeGift()

    if self.redPointDic[CampaignEumn.BeginAutumn.TimeShop] ~= true or self.isOpeningShop == true then
        self.redPointDic[CampaignEumn.BeginAutumn.TimeShop] = CampaignRedPointManager.Instance:TimeShop2()
    end
    -- self.onUpdateTabRedPoint:Fire()
    -- self.onUpdateTabSecondRedPoint:Fire()
    self.OnUpdateRedPoint:Fire()
    self:CheckMainUIIconRedPoint()
end



function BeginAutumnManager:send17845()
    local data = { }
    self:Send(17845, data)
end

function BeginAutumnManager:send17846(lev, id)
    local data = { lev = lev, id = id }
    self:Send(17846, data)
end

function BeginAutumnManager:on17845(data)
    --BaseUtils.dump(data,"on17845#######")
    self.lev = data.lev
    self.model.dollar = data.dollar
    self.totalList = { }
    self.todayList = { }
    self.nowDay = data.day
    for _, data in pairs(data.list) do
        self.totalList[data.id] = data
    end
    for _, data in pairs(data.day_list) do
        self.todayList[data.id] = data
    end
    self:GiftList(self.myRechargeData)
    EventMgr.Instance:Fire(event_name.cake_exchange_data_update)
    EventMgr.Instance:Fire(event_name.role_asset_change)
    self:CheckRedPoint()
end



function BeginAutumnManager:GetGiftList()
    return self.todayItemList
end

function BeginAutumnManager:on17846(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end




function BeginAutumnManager:send17871()
    --print("发送17871")
    local data = {}
    self:Send(17871,data)
end

function BeginAutumnManager:on17871(data)
    --print("收到17871")
    --BaseUtils.dump(data,"sdkfjksdjjj==============================================================================================")
    self.shopDataList = data
      table.sort(self.shopDataList.shop_list,function(a,b)
               if a.id ~= b.id then
                    return a.id > b.id
                else
                    return false
                end
            end)
    self.OnUpdateShop:Fire()
    self.OnUpdateShopRed:Fire()
    self:CalculateTime()
    self:CheckRedPoint()
end

function BeginAutumnManager:send17872(index)
    local data = {id = index}
    self:Send(17872,data)
end

function BeginAutumnManager:on17872(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 1 then
        self.OnUpdateShopStatus:Fire()
    end
end

function BeginAutumnManager:send17873()
    local data = {}
    self:Send(17873,data)
end

function BeginAutumnManager:on17873(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function BeginAutumnManager:send17874()
    local data = {}
    self:Send(17874,data)
end

function BeginAutumnManager:on17874(data)
    self.isInit = false
    self.myRechargeData = data
    self:send17845()
end


function BeginAutumnManager:GiftList(data)
    self.todayItemList = {}

    if self.nowDay == nil then
        self.nowDay = 3
    end

    for i,v in ipairs(data.bags_list) do
        if self.nowDay >= v.min_day and self.nowDay <= v.max_day and (RoleManager.Instance.RoleData.sex == v.sex or v.sex == 2) and (RoleManager.Instance.RoleData.lev >= v.min_lev and RoleManager.Instance.RoleData.lev <= v.max_lev)  then
            self.todayItemList[v.id] = v
        end
    end

end


function BeginAutumnManager:CalculateTime()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.shopDataList ~= nil then
        if self.isOpeningShop == false then
            self.isInitShop = false
        end
        local baseTime = BaseUtils.BASE_TIME
        local refreshTime = self.shopDataList.ref_time
        self.timestamp = 0
        if refreshTime > baseTime then
            self.timestamp = refreshTime - baseTime
        end
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end

        self.timerId = LuaTimer.Add(self.timestamp,function() self:TimeEnd() end)
    end
end

function BeginAutumnManager:TimeEnd()
    if self.isOpeningShop == false and self.isInitShop == false then
        self.redPointDic[CampaignEumn.BeginAutumn.TimeShop] = true
    end
end



