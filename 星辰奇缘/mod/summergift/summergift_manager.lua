SummerGiftManager = SummerGiftManager or BaseClass(BaseManager)

function SummerGiftManager:__init()
    if SummerGiftManager.Instance ~= nil then
        return
    end

    SummerGiftManager.Instance = self
    self.model = SummerGiftModel.New()
    self.OnUpdateRedPoint = EventLib.New()

    self.totalCampaignId = 44
    self.redPointDic = {}

    self.chargeUpdateEvent = EventLib.New()
    self.isOverDay = 0
    EventMgr.Instance:AddListener(event_name.campaign_rank_my_data_update,function() self:CheckRedPoint() end)


    self:InitHandler()
end

function SummerGiftManager:InitHandler()
    self:AddNetHandler(17869, self.on17869)
    self:AddNetHandler(17870, self.on17870)
end

function SummerGiftManager:RequestInitData()
    self:send17869()
end



function SummerGiftManager:OpenMainWindow(args)
    self.model:OpenMainWindow(args)
end


function SummerGiftManager:SetIcon()
    local systemIconId = DataCampaign.data_camp_ico[self.totalCampaignId].ico_id
    MainUIManager.Instance:DelAtiveIcon3(systemIconId)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.SummerGift] == nil then
        return
    end

    self.activeIconData = AtiveIconData.New()
    local iconData = DataSystem.data_daily_icon[systemIconId]
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    local temdate = CampaignManager.Instance.campaignTree[CampaignEumn.Type.SummerGift]
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
    self.activeIconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.summer_main_window) end
    -- end

    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    -- if CampaignManager.Instance.campaignTree[CampaignEumn.Type.CampBox][CampaignEumn.CampBox.SummerQuest] ~= nil then
    --     self:Send10253()
    --     self:send17864()
    -- end
    self:CheckRedPoint();
end


function SummerGiftManager:__delete()
    self.model:DeleteMe()
end


function SummerGiftManager:CheckMainUIIconRedPoint()
    if MainUIManager.Instance.MainUIIconView ~= nil then
        self.isInit = true
        local icon_id = DataCampaign.data_camp_ico[self.totalCampaignId].ico_id
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(icon_id, self:IsNeedShowRedPoint())
    end
end

function SummerGiftManager:IsNeedShowRedPoint()
    for k, v in pairs(self.redPointDic) do
        if v then
            return v
        end
    end
    return false
end

function SummerGiftManager:CheckRedPoint()

    for k, v in pairs(self.redPointDic) do
        self.redPointDic[k] = false
    end

    self:IsRedContinueChargePanel()
    self:IsRedHalloweenMoonPanel()
    self:IsRedCampaignRankPanel()



    self.OnUpdateRedPoint:Fire()
    self:CheckMainUIIconRedPoint()
end


function SummerGiftManager:IsRedContinueChargePanel()
    local red = false
    if self.model.chargeData ~= nil and self.model.chargeData.reward ~= nil then
        for _,v in ipairs(self.model.chargeData.reward) do
            if v.day_status == 1 then
                red = true
            end
        end
    end

    SummerGiftManager.Instance.redPointDic[CampaignEumn.SummerGift.MindAgain] = red
end

function SummerGiftManager:IsRedHalloweenMoonPanel()
    if CampaignManager.Instance.campaignTree == nil or CampaignManager.Instance.campaignTree[CampaignEumn.Type.SummerGift] == nil then
        return
    end
    local index = DataCampaign.data_list[CampaignEumn.SummerGift.SummerGift].index
    local protoData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.SummerGift][index]

    local red = false
    if protoData ~= nil then
        for i,v in ipairs(protoData.sub) do
            local campData = DataCampaign.data_list[v.id]
            if #campData.loss_items == 0 then
                if v.status == CampaignEumn.Status.Finish then
                    red = true
                end
            end
        end

        if #protoData.sub > 1 then
                table.sort(protoData.sub,function(a,b)
                if a.id ~= b.id then
                    return a.id < b.id
                else
                    return false
                end
                end)
            end
        SummerGiftManager.Instance.redPointDic[protoData.sub[1].id] = red
    end




end


function SummerGiftManager:send17869()
    Connection.Instance:send(17869, {})
end

function SummerGiftManager:on17869(data)
    -- print("=======================================================================================================================")
    -- print('=================================================================================================================================')
    -- BaseUtils.dump(data,"接收协议17869")
    self:CalcularOverDay(data)
   self:ApplyData(data)
   -- BaseUtils.dump(self.model.chargeData,"处理后的数据")
   self.chargeUpdateEvent:Fire()


   self:CheckRedPoint()
end


function SummerGiftManager:send17870(id)
    Connection.Instance:send(17870, {target_day = id})
end
function SummerGiftManager:on17870(data)
    BaseUtils.dump(data,"协议回调17870")
    if data.err_code ~= 1 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

function SummerGiftManager:ApplyData(data)
    self.model.chargeData = {}
    self.model.chargeData.reward = {}

    for i=1,data.day do
        self.model.chargeData.reward[i] = {}
        self.model.chargeData.reward[i].day_status = 1
    end


    for k,v in pairs(data.list) do
        self.model.chargeData.reward[v.id] = {}
        self.model.chargeData.reward[v.id].day_status = 2
    end

    if self.isOverDay == 1 then
        self.model.chargeData.reward[data.day + 1] = {}
        self.model.chargeData.reward[data.day + 1].day_status = 0
    end
end



function SummerGiftManager:CalcularOverDay(data)
    if data.day == 0 then
        self.isOverDay = 1
        return
    end
    if data.day <= 3 then
        local baseTime = BaseUtils.BASE_TIME
        local nowData = tonumber(os.date("%m", baseTime))
        local nowD = tonumber(os.date("%d", baseTime))
        local lastData = 0
        local lastD = 0
        if data.mtime == 0 then
            lastData = tonumber(os.date("%m", data.mtime))
            lastD = tonumber(os.date("%d", baseTime))
        else
            lastData = tonumber(os.date("%m", data.mtime))
            lastD = tonumber(os.date("%d", data.mtime))
        end
        -- print("当前月:" .. nowData .. "当前日" ..nowD)
        -- print("之前月:" .. lastData .. "之前日" .. lastD)

        if lastData == nowData then
            if nowD - lastD >= 1 then
                self.isOverDay = 1
            else
                self.isOverDay = 0
            end
        elseif baseTime > data.mtime and lastData ~= nowData then
            self.isOverDay = 1
        end

    else
        self.isOverDay = 0
    end

end


function SummerGiftManager:IsRedCampaignRankPanel()
    local red = false
    local personalData = WorldLevManager.Instance:GetPersonalTmpByType(CampaignEumn.CampaignRankType.Treasure)
    if personalData ~= nil then
        for _, personal in ipairs(personalData) do

            if personal ~= nil then
                local myIntimacy = WorldLevManager.Instance:GetMyValueByType(CampaignEumn.CampaignRankType.Treasure)
                local curTmpValue = personal.num;
                local scale = myIntimacy / curTmpValue
                local isGet = WorldLevManager.Instance:CheckIsGetRewardByType(CampaignEumn.CampaignRankType.Treasure,curTmpValue);
                if scale >= 1 then
                    if not isGet then
                        red = true
                    end
                end
            end
        end
    end

    SummerGiftManager.Instance.redPointDic[CampaignEumn.SummerGift.Rank] = red
end
