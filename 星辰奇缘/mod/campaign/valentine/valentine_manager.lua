ValentineManager = ValentineManager or BaseClass(BaseManager)

ValentineManager.SYSTEM_ID = 335

function ValentineManager:__init()
    if ValentineManager.Instance ~= nil then
        Log.Error("不可重复实例化")
        return
    end

    ValentineManager.Instance = self
    self.model = ValentineModel.New()

    self.menuId = {
        Love = 567,
        -- 情牵一线（许愿）
        Chocolate = 582,
        -- 情意绵绵  (改周年庆登录送礼)
        Spirit = 585,
        CakeExchange = 584,
        -- 周年庆兑换活动
        Recharge = 583,-- 心意连连（连续充值）
                       -- Hand = 545,                 -- 执子之手（结缘打折）
                       -- Exchange = 583              -- 兑换商店 （

    }
    -- 精灵秘钥id
    self.DollsItemId = 29821
    -- 奶油id
    self.CreamItemId = 23231
    --
    self.dollsTimeOpen = false
    self.tickSce = 0
    self.redPointDic = { }
    self.redPointEvent = EventLib.New()
    self.onUpdateWish = EventLib.New()
    self.onUpdateWishData = EventLib.New()
    self.itemCheckFun =
    function(items)
        self:CheckRed()
        --        if #items <= 0 then
        --            return
        --        end
        --        for _, item in pairs(items) do
        --            if item.id == self.DollsItemId or item.id == self.CreamItemId then
        --                self:CheckRed()
        --                break
        --            end
        --        end
    end
    self:InitHandler()
    self:ReSortMenu()

    -----------------------------------------------------------------------------------------------
    self.onUpdateSevenLoginBegin = EventLib.New()

    self.sevenLoginData = nil
    self.onUpdateSevenLogin = EventLib.New()

    self.loveWishReply = EventLib.New()
    self.loveBackWishReply = EventLib.New()

    self.timeUpdate = EventLib.New()
    self.isInitMarchTime = nil
    self.time = 0

end

function ValentineManager:ReSortMenu()
    for k, id in pairs(self.menuId) do
        CampaignEumn.ValentineType[k] = DataCampaign.data_list[id].index
    end
end

function ValentineManager:InitHandler()
    self:AddNetHandler(17828, self.on17828)
    self:AddNetHandler(17829, self.on17829)
    self:AddNetHandler(17830, self.on17830)
    self:AddNetHandler(17831, self.on17831)
    self:AddNetHandler(17832, self.on17832)
    self:AddNetHandler(17837, self.on17837)
    self:AddNetHandler(17843, self.on17843)
    self:AddNetHandler(17844, self.on17844)
    self.redPointEvent:AddListener( function() self:CheckRedMainUI() end)
    EventMgr.Instance:AddListener(event_name.active_point_update, function() self:CheckRed() end)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemCheckFun)
    EventMgr.Instance:AddListener(event_name.role_asset_change, function() self:CheckRed() end)
    EventMgr.Instance:AddListener(event_name.campaign_change, function() self:send17843() self:send17828() end)
end

function ValentineManager:__delete()
end

function ValentineManager:OpenWindow(args)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine] == nil then
        return
    end
    if args == nil then
        --        local id = nil
        --        for cid,v in pairs(self.redPointDic) do
        --            if CampaignManager.Instance.campaignTab[cid] ~= nil and v == true then
        --                id = cid
        --                break
        --            end
        --        end
        --        if id ~= nil then
        --            args = {id}
        --        end
        -- args = { self.menuId.Love }
    end
    self.model:OpenWindow(args)

end

function ValentineManager:CheckValentineOnly()
    return true
    -- local campaignTree = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine]
    -- if campaignTree ~= nil and
    --     (campaignTree[CampaignEumn.ValentineType.Bird] ~= nil or
    --     campaignTree[CampaignEumn.ValentineType.Hand] ~= nil or
    --     campaignTree[CampaignEumn.ValentineType.Chocolate] ~= nil)
    --     then
    --     return true
    -- end
    -- return false
end

function ValentineManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(ValentineManager.SYSTEM_ID)
    -- MainUIManager.Instance:DelAtiveIcon3(328)

    -- BaseUtils.dump(CampaignManager.Instance.campaignTree)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine] == nil then
        return
    end

    self.activeIconData = AtiveIconData.New()
    -- local iconData = DataSystem.data_daily_icon[327]
    -- if self:CheckValentineOnly() then
    --     iconData = DataSystem.data_daily_icon[328]
    -- end
    local iconData = DataSystem.data_daily_icon[ValentineManager.SYSTEM_ID]
    self.activeIconData.id = iconData.id
    -- 335
    self.activeIconData.iconPath = iconData.res_name
    -- 335
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
        -- local count = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine].count
        -- if count == 1 and CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine][CampaignEumn.ValentineType.Exchange] ~= nil then
        --    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.valentine_exchange)
        -- else
        --    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.valentine_window)
        -- end
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.valentine_window)
    end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    -- -
    self:CheckRed()
end

function ValentineManager:CheckRedMainUI()
    local red = false
    if CampaignManager.Instance.campaignTree ~= nil and CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine] ~= nil then
        for k, v in pairs(CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine]) do
            if k ~= "count" then
                for _, sub in ipairs(v.sub) do
                    -- 兑换活动图标的红点判断不需要兑换活动
                    if sub.id ~= self.menuId.CakeExchange then
                        -- 砸蛋两个活动的id需特殊（只去砸蛋的红点）
                        if sub.id == self.menuId.Spirit then
                            local status = false;
                            local redData = MarchEventManager.Instance.redPointDic;
                            if redData ~= nil then
                                red = red or redData[3]
                            end
                        else
                            red = red or(CampaignManager.Instance.campaignTab[sub.id] ~= nil and self.redPointDic[sub.id] == true)
                        end
                    end

                end
            end
        end
    end
    if MainUIManager.Instance.MainUIIconView ~= nil and self.activeIconData ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(self.activeIconData.id, red)
    end
end

function ValentineManager:OpenExchange(args)
    self.model:OpenExchange(args)
end

function ValentineManager:CheckRed()
    local redList = { }
    for id, _ in pairs(self.redPointDic) do
        table.insert(redList, id)
    end
    for _, id in pairs(redList) do
        self.redPointDic[id] = nil
    end
    local campaignDatat = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine]
    if campaignDatat ~= nil then
        if campaignDatat[CampaignEumn.ValentineType.Recharge] ~= nil then
            for _, sub in pairs(campaignDatat[CampaignEumn.ValentineType.Recharge].sub) do
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
        if campaignDatat[CampaignEumn.ValentineType.Chocolate] ~= nil then
            for i, sub in pairs(campaignDatat[CampaignEumn.ValentineType.Chocolate].sub) do
                self.redPointDic[sub.id] =(i == 1 and(sub.status == CampaignEumn.Status.Finish) and(AgendaManager.Instance:GetActivitypoint() >= 100))
            end
        end

        local isOpen = false
        if campaignDatat[CampaignEumn.ValentineType.Spirit] ~= nil then
            for _, item in pairs(campaignDatat[CampaignEumn.ValentineType.Spirit].sub) do
                if item.id == MarchEventManager.Instance.model.panelIdList[3] and self.dollsTimeOpen then
                    isOpen = true
                    break
                end
            end
            if isOpen then
                local status = false
                local itemNum = BackpackManager.Instance:GetItemCount(self.DollsItemId)
                status = itemNum > 0
                MarchEventManager.Instance.redPointDic[3] = status
            end
            self.redPointDic[self.menuId.Spirit] = status or MarchEventManager.Instance.redPointDic[2]
        end
        if campaignDatat[CampaignEumn.ValentineType.CakeExchange] ~= nil then
            local status = false
            local itemNum = RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.cake_exchange)
            if itemNum > 0 then
                local tmpDatas = DataCampExchange.data_camp_exchange_reward
                for _, tmpData in pairs(tmpDatas) do
                    if CakeExchangeManager.Instance:CheckExchangeIsOpen(tmpData) then
                        if itemNum >= tonumber(tmpData.cost[1][2]) then
                            local todayNum = tmpData.max
                            local todayData = CakeExchangeManager.Instance.TodayList[tmpData.id]
                            if todayData ~= nil then
                                todayNum = todayNum - todayData.num
                            end
                            if todayNum > 0 then
                                status = true
                                break
                            end
                        end
                    end
                end
            end
            self.redPointDic[self.menuId.CakeExchange] = status
        end
    end
    local data = self.sevenLoginData
    if data ~= nil then
        if data.flag == 0 and data.num < 7 then
            self.redPointDic[self.menuId.Chocolate] = true
        else
            self.redPointDic[self.menuId.Chocolate] = false
        end
    end





    if self.model.wishCount ~= nil and self.model.votiveCount ~= nil then
        if 1 - self.model.wishCount == 0 then
            self.redPointDic[self.menuId.Love] = false
        else
            self.redPointDic[self.menuId.Love] = true
        end

        if 1 - self.model.wishCount == 0 and 2 - self.model.votiveCount == 2 then
            self.redPointDic[self.menuId.Love] = true
        elseif 1 - self.model.wishCount == 0 and 2 - self.model.votiveCount ~= 2 then
            self.redPointDic[self.menuId.Love] = false
        end
    end

    self.redPointEvent:Fire()
end


function ValentineManager:CheckDollsRandom()
    -- local isOpen = false
    -- local valentDatat = CampaignManager.Instance.campaignTree[CampaignEumn.Type.QiXi]
    -- if valentDatat == nil then
    --     return false
    -- end
    -- BaseUtils.dump(valentDatat,"大活动数据===========================================")
    -- for _, item in pairs(valentDatat) do
    --     if item.sub[1].id == 741 then
    --         isOpen = true
    --         break
    --     end
    -- end
    -- return isOpen
end

function ValentineManager:CheckCakeExchange()
    local isOpen = false
    local ValentineData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Valentine]
    if ValentineData == nil then
        return false
    end
    if ValentineData[CampaignEumn.ValentineType.CakeExchange] ~= nil then
        if CakeExchangeManager.Instance == nil then
            CakeExchangeManager.New()
        end
        CakeExchangeManager.Instance:send17845()
        isOpen = true
    else
        if CakeExchangeManager.Instance ~= nil then
            CakeExchangeManager.Instance:DeleteMe()
        end
        isOpen = false
    end
    return isOpen
end

function ValentineManager:ReqOnConnect()
    AgendaManager.Instance:Require12004()
    -- self:send17828()
end

function ValentineManager:OpenWish()
    self.model:OpenWish()
end

function ValentineManager:OpenWishBack()
    self.model:OpenWishBack()
end


-- ================================= 协议 ===================================

-- 白色情人节数据
function ValentineManager:send17828()
    -- Log.Error("send17828")
    Connection.Instance:send(17828, { })
end

function ValentineManager:on17828(data)
    -- Log.Error("on17828")
    self.model:FillData17828(data)
    self.onUpdateWishData:Fire()



    -- BaseUtils.dump(self.redPointDic, "红点表")
    -- self.redPointDic[] = true
    self:CheckRed()

    -- self.model.wishData = data
end

-- 白色情人节许愿
function ValentineManager:send17829(wish, type)
    -- Log.Error("send17829")
    Connection.Instance:send(17829, { wish = wish, type = type })
end

function ValentineManager:on17829(data)
    -- Log.Error("on17829")
    -- BaseUtils.dump(data, "on17829")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 0 then
        -- 失败
        -- NoticeManager.Instance:FloatTipsByString(data.msg)
    else
        -- NoticeManager.Instance:FloatTipsByString(TI18N("爱神收起你的许愿笺等待有缘人拾取，祝您愿望成真！{face_1,3}"))
        self.loveWishReply:Fire()
        WindowManager.Instance.lastWin = nil
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.love_wish)
    end
end

-- 白色情人节查看许愿笺
function ValentineManager:send17830(itemId)
    self.model.checkWishData = nil
    Connection.Instance:send(17830, { id = itemId })
end


function ValentineManager:on17830(data)

    -- Log.Error("on17830")
    BaseUtils.dump(data, "on17830")
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.love_wish_back)

    self.model.checkWishData = data
    self.onUpdateWish:Fire()

end

-- 白色情人节还愿
function ValentineManager:send17831(index)
    -- Log.Error("send17831")
    Connection.Instance:send(17831, { type = index })
end

function ValentineManager:on17831(data)
    -- Log.Error("on17831")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code ~= 0 then
        -- 成功
        self.loveBackWishReply:Fire()
        WindowManager.Instance.lastWin = nil
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.love_wish_back)
    end
end

-- 白色情人节领取许愿签
function ValentineManager:send17832()
    Connection.Instance:send(17832, { })
end

function ValentineManager:on17832(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 白色情人节领取还愿签
function ValentineManager:send17837()
    Connection.Instance:send(17837, { })
end

function ValentineManager:on17837(data)
    -- BaseUtils.dump(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function ValentineManager:RequestInitData()
    self:send17828()
    self:send17843()
end

----------------------------------------------------------------------------
function ValentineManager:send17843()
    -- Log.Error("send17837")
    Connection.Instance:send(17843, { })
end

function ValentineManager:on17843(data)
    -- Log.Error("on17837")
    -- BaseUtils.dump(data, "协议回调17843")
    -- TODO
    self.sevenLoginData = { }
    for k, v in pairs(data) do
        self.sevenLoginData[k] = v
    end
    self.onUpdateSevenLoginBegin:Fire()
    EventMgr.Instance:Fire(event_name.campaign_get_update, data)
    self:CheckRed()
    -- if data.err_code == 0 then--失败
    --    NoticeManager.Instance:FloatTipsByString(TI18N("缘分天定！打开背包帮助有人缘之人实现愿望还可获得惊喜大礼哦！{face_1,7}"))
    -- end
end

function ValentineManager:send17844()
    -- Log.Error("send17837")
    Connection.Instance:send(17844, { })
end

function ValentineManager:on17844(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.onUpdateSevenLogin:Fire()
    end
end

function ValentineManager:InitDollsCampainTime()
    local campaignTime = DataCampDoll.data_dolls_other_list[1].time[1]
    self.nowyear = os.date("%Y", BaseUtils.BASE_TIME)
    self.nowmonth = os.date("%m", BaseUtils.BASE_TIME)
    self.nowdate = os.date("%d", BaseUtils.BASE_TIME)
    self.BeginTime = tonumber(os.time { year = self.nowyear, month = self.nowmonth, day = self.nowdate, hour = campaignTime[1], min = campaignTime[2], sec = campaignTime[3] })
    self.EndTime = tonumber(os.time { year = self.nowyear, month = self.nowmonth, day = self.nowdate, hour = campaignTime[4], min = campaignTime[5], sec = campaignTime[6] })
end



function ValentineManager:CheckMarchPanel()
    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))
    self.marchBeginTime = nil
    self.marchEndTime = nil
    local beginTimeData = DataCampaign.data_list[585].cli_start_time[1]
    local endTimeData = DataCampaign.data_list[585].cli_end_time[1]
    self.marchBeginTime = tonumber(os.time{year = beginTimeData[1], month = beginTimeData[2], day = beginTimeData[3], hour = beginTimeData[4], min = beginTimeData[5], sec = beginTimeData[6]})
    self.marchEndTime = tonumber(os.time{year = endTimeData[1], month = endTimeData[2], day = endTimeData[3], hour = endTimeData[4], min = endTimeData[5], sec = endTimeData[6]})

    if self.marchBeginTime < baseTime  and baseTime < self.marchEndTime then
      return true
    end

    return false
end

-- 这里关掉，有问题再说
function ValentineManager:OnTick()
   if self.isInitMarchTime == nil then
        self.isInitMarchTime = self:CheckMarchPanel()
   end
   if self.isInitMarchTime == true then
        self.time = self.time + 1
        if self.time % 5 == 0 then
            self.time = 0
            if self.isInitMarchTime == false then
                self:InitMarchTime()
            end
            local baseTime = BaseUtils.BASE_TIME
            local h = nil
            local mm = nil
            local ss = nil
            if self.marchBeginTime < baseTime  and baseTime < self.marchEndTime then
               h = math.floor((self.marchEndTime - baseTime) / 3600)
               mm = math.floor(((self.marchEndTime - baseTime) - (h * 3600)) / 60 )
               ss = math.floor((self.marchEndTime - baseTime) - (h * 3600) - (mm * 60))
               MarchEventManager.Instance.redPointDic[2] = true
            else
               self.eventCountDownText.text = TI18N("活动未开启")
               MarchEventManager.Instance.redPointDic[2] = false
            end
            -- print(h .. mm .. ss)
            self.timeUpdate:Fire(h,mm,ss)
            self:CheckRed()
        end
    end


    if not self:CheckDollsRandom() then
        return
    end
    if self.BeginTime == nil then
        self:InitDollsCampainTime()
    end
    self.tickSce = self.tickSce + 1
    -- 两分钟tick一次
    if self.tickSce % 600 == 0 then
        self.tickSce = 0
        local baseTime = BaseUtils.BASE_TIME
        self.nowyear = os.date("%Y", BaseUtils.BASE_TIME)
        self.nowmonth = os.date("%m", BaseUtils.BASE_TIME)
        self.nowdate = os.date("%d", BaseUtils.BASE_TIME)
        local endTime = 0
        if self.BeginTime <= baseTime and baseTime <= self.EndTime then
            self.dollsTimeOpen = true
        else
            self.dollsTimeOpen = false
        end
        self:CheckRed()
    end
    -- MarchEventManager.Instance.onUpdateRedPoint:Fire()
end