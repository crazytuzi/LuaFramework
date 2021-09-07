CampaignModel = CampaignModel or BaseClass(BaseModel)

function CampaignModel:__init()
    -- 不想进入通用处理的，都在这里加上
    self.specilIconType = {
        [107] = 1,
        [108] = 1,
        [307] = 1,
        [2] = 1,
        [3] = 1,
        [7] = 1,
        [10] = 1,
        [14] = 1,
        [41] = 1,
        [45] = 1,
        [46] = 1,
        [47] = 1,
        [33] = 1,
        [35] = 1,
    }

    self.campShowSpriteFuncTab = {
        --[CampaignEumn.ShowType.Lantern] = function(loader) loader:SetSprite(SingleIconType.Item,29881) end
        [CampaignEumn.ShowType.Lantern] = {package = AssetConfig.dropicon,name = "62"}
        --
        , [CampaignEumn.ShowType.BuyPackage] = {package = AssetConfig.campaign_icon, name = "Reward"}
        , [CampaignEumn.ShowType.NewFashion] = {package = AssetConfig.textures_campaign, name = "MeshFashion"}
        , [CampaignEumn.ShowType.TreasureHunting] = {package = AssetConfig.campaign_icon, name = "IconOpen"}
        , [CampaignEumn.ShowType.DragonKingSendsBless] = {package = AssetConfig.dropicon,name = "34"}
        , [CampaignEumn.ShowType.SeekChildren] = {package = AssetConfig.campaign_icon, name = "FruitPlantIcon4"}
        , [CampaignEumn.ShowType.Hand] = {package = AssetConfig.campaign_icon, name = "WithYou"}
        ,[CampaignEumn.ShowType.IntiMacy] = {package = AssetConfig.campaign_icon,name = "loveicon"}
        ,[CampaignEumn.ShowType.QiXi] = function(loader) loader:SetSprite(SingleIconType.Item,23274) end
        ,[CampaignEumn.ShowType.BigPicture] = function(loader) loader:SetSprite(SingleIconType.Item,29810) end
        ,[CampaignEumn.ShowType.DoubleElevenGroup] = {package = AssetConfig.dropicon,name = "76"}
        ,[CampaignEumn.ShowType.FlowerOpen] = {package = AssetConfig.campaign_icon, name = "QiqiuIcon"}
        ,[CampaignEumn.ShowType.SkyLantern] = {package = AssetConfig.campaign_icon, name = "SkyLanternIcon"}
        --,[CampaignEumn.ShowType.PoetryChallenge] = {package = AssetConfig.campaign_icon, name = "PoetryChallengeIcon"}
        ,[CampaignEumn.ShowType.FlowerAccept] = {package = AssetConfig.textures_campaign, name = "flowerIcon"}
        -- ,[CampaignEumn.ShowType.SecondaryTop] = function(loader) loader:SetSprite(SingleIconType.Item,29152) end
        ,[CampaignEumn.ShowType.RechargePackage] = function(loader) loader:SetSprite(SingleIconType.Item,22560) end
        ,[CampaignEumn.ShowType.AutumnBargain] = {package = AssetConfig.campaign_icon, name = "ChildFlowerGift"}
        --,[CampaignEumn.ShowType.Exchange_Window] = function(loader) loader:SetSprite(SingleIconType.Item,90063) end
        ,[CampaignEumn.ShowType.KillEvil] = function(loader) loader:SetSprite(SingleIconType.Item,25007) end
        ,[CampaignEumn.ShowType.DiscountHalloween] = {package = AssetConfig.dropicon,name = "71"}
        -- ,[CampaignEumn.ShowType.Consume] = function(loader) loader:SetSprite(SingleIconType.Item,22525) end
        ,[CampaignEumn.ShowType.TalkBubble] = function(loader) loader:SetSprite(SingleIconType.Item,25007) end
        --,[CampaignEumn.ShowType.Zongzi] = function(loader) loader:SetSprite(SingleIconType.Item,25018) end
        -- ,[CampaignEumn.ShowType.Zongzi] = {package = AssetConfig.dropicon,name = "84"}
        ,[CampaignEumn.ShowType.SaveSingleDog] = function(loader) loader:SetSprite(SingleIconType.Item,29970) end
        --,[CampaignEumn.ShowType.Secondary] = {package = AssetConfig.dropicon,name = "80"}
        --,[CampaignEumn.ShowType.MarchEvent] = {package = AssetConfig.dropicon,name = "99"}
        --,[CampaignEumn.ShowType.DollsRandom] = {package = AssetConfig.campaign_icon, name = "dolls_item1"}
        ,[CampaignEumn.ShowType.RebateReward] = {package = AssetConfig.campaign_icon, name = "diamond"}
        -- ,[CampaignEumn.ShowType.SpriteEgg] = {package = AssetConfig.campaign_icon, name = "MagicEgg"}
        ,[CampaignEumn.ShowType.SummerDoing] = function(loader) loader:SetSprite(SingleIconType.Item,29025) end
        --,[CampaignEumn.ShowType.ValentineActiveFirst] = {package = AssetConfig.dropicon,name = "68"}
        -- ,[CampaignEumn.ShowType.ValentineActiveFirst] = {package = AssetConfig.dropicon,name = "97"}
        ,[CampaignEumn.ShowType.SalesPromotion] = function(loader) loader:SetSprite(SingleIconType.Item,29088) end
        ,[CampaignEumn.ShowType.FlowerOpen] = {package = AssetConfig.dropicon,name = "86"}
        -- ,[CampaignEumn.ShowType.FlowerHundred] = {package = AssetConfig.dropicon,name = "88"}
        -- ,[CampaignEumn.ShowType.CuteSnowMan] = {package = AssetConfig.dropicon,name = "74"}
        ,[CampaignEumn.ShowType.SnowFight] = {package = AssetConfig.dropicon,name = "73"}
        ,[CampaignEumn.ShowType.RideShow] = {package = AssetConfig.dropicon,name = "75"}
        ,[CampaignEumn.ShowType.FashionSelection] = {package = AssetConfig.dropicon,name = "79"}
        ,[CampaignEumn.ShowType.ToyReward] = {package = AssetConfig.dropicon,name = "82"}
        ,[CampaignEumn.ShowType.RechargeCoupon] = function(loader) loader:SetSprite(SingleIconType.Item,90044) end
        ,[CampaignEumn.ShowType.LimitTimeStore] = function(loader) loader:SetSprite(SingleIconType.Item,20770) end
        ,[CampaignEumn.ShowType.FashionDiscount] = function(loader) loader:SetSprite(SingleIconType.Item,24004) end
        -- ,[CampaignEumn.ShowType.MulticoloredMountainsAndRivers] = {package = AssetConfig.dropicon,name = "85"}
        ,[CampaignEumn.ShowType.NewYearGoods] = function(loader) loader:SetSprite(SingleIconType.Item,23215) end
        ,[CampaignEumn.ShowType.LuckyMoney] = function(loader) loader:SetSprite(SingleIconType.Item,23213) end
        ,[CampaignEumn.ShowType.NewYearTurnable] = {package = AssetConfig.dropicon,name = "92"}
        ,[CampaignEumn.ShowType.LanternMultiRecharge] = {package = AssetConfig.dropicon,name = "56"}

        ,[CampaignEumn.ShowType.RushTop] = {package = AssetConfig.dropicon,name = "93"}
        -- ,[CampaignEumn.ShowType.SignDraw] = function(loader) loader:SetSprite(SingleIconType.Item,29983) end
        ,[CampaignEumn.ShowType.SweetCake] = {package = AssetConfig.dropicon,name = "96"}
        --,[CampaignEumn.ShowType.ArborShake] = {package = AssetConfig.dropicon,name = "98"}
        -- ,[CampaignEumn.ShowType.SummerCold] = function(loader) loader:SetSprite(SingleIconType.Item,70028) end
        ,[CampaignEumn.ShowType.AprilTreasure] = function(loader) loader:SetSprite(SingleIconType.Item,29183) end
    }

    self.redList = {}
    self.redPointList = {}
    self.iconTypeList = {}

    self.redFun = {}

    self.init = false
    self.isSpecialIcon = false
    self.isSpecialTitle = false


    self.redList = {}
    self.secondaryIconType = nil
    self.secondaryIconIndex = nil
    self.secondaryTopWin = nil


end

function CampaignModel:__delete()
end


function CampaignModel:CreatRedFun(id)
    local fun = nil
    if id ~= nil then
        if self.redFun["checkRed" .. id] == nil then
            self.redFun["checkRed" .. id] = function() self:CheckActiveRed(id) end
        end
        fun = self.redFun["checkRed" .. id]
    else
        fun = self:SetIcon(CampaignManager.Instance.campaignTree)
    end

    if fun ~= nil then
        fun()
    end
end

function CampaignModel:AddListeners()
    self.checkRed = function(id) self:CheckCondType() end
    self.mainUiCheckRed = function(iconType) self:CheckMainIconRed(iconType) end
    EventMgr.Instance:AddListener(event_name.intimacy_my_data_update,self.checkRed)
    EventMgr.Instance:AddListener(event_name.get_campaign_reward_success,self.checkRed)
    EventMgr.Instance:AddListener(event_name.backpack_item_change,self.checkRed)
    EventMgr.Instance:AddListener(event_name.intimacy_reward_data_update,self.checkRed)
    EventMgr.Instance:AddListener(event_name.role_asset_change,self.checkRed)
    EventMgr.Instance:AddListener(event_name.quest_update,self.checkRed)
    NewMoonManager.Instance.chargeUpdateEvent:AddListener(self.checkRed)
    TurntabelRechargeManager.Instance.onUpdateRed:AddListener(self.checkRed)
    CampaignAutumnManager.Instance.onRefreshData:AddListener(self.checkRed)
    NationalSecondManager.Instance.OnUpdateFlowerRed:AddListener(self.checkRed)
    --RechargePackageManager.Instance.onUpdateRed:AddListener(self.checkRed)
    ChildBirthManager.Instance.onFlowerCountEvent:AddListener(self.checkRed)
    --DoubleElevenManager.Instance.closeSingleDog:AddListener(self.checkRed)
    CampaignInquiryManager.Instance.questChange:AddListener(self.checkRed)
    SpringFestivalManager.Instance.OnUpdateLuckMoney:AddListener(self.checkRed)
    CampaignManager.Instance.summer_questQuestChange:AddListener(self.checkRed)

    EventMgr.Instance:AddListener(event_name.camp_red_change,self.mainUiCheckRed)

    SignDrawManager.Instance.OnUpdatePassBlessFlowerRed:AddListener(self.checkRed)
    MagicEggManager.Instance.OnUpdateFullSubtractionRed:AddListener(self.checkRed)
    CardExchangeManager.Instance.OnUpdateCellListEvent:AddListener(self.checkRed)
    CampaignProtoManager.Instance.luckytreeUpdateEvent:AddListener(self.checkRed)
    CampaignProtoManager.Instance.updateCustomGiftEvent:AddListener(self.checkRed)
    CampaignProtoManager.Instance.updateWarOrderEvent:AddListener(self.checkRed)
    CampaignProtoManager.Instance.updateWarOrderQuestEvent:AddListener(self.checkRed)
end


function CampaignModel:SetIcon(tree)
    -- BaseUtils.dump(tree,"协议回调14000==================================================================================================================================")

    self.initTree = false
    self.iconTypeList = {}
    for iconId,v in pairs(self.redList) do
        local activeIconData = DataCampaign.data_camp_ico[iconId]
        if v ~= nil and activeIconData ~= nil then
            MainUIManager.Instance:DelAtiveIcon3(DataCampaign.data_camp_ico[iconId].ico_id)
        end
    end
    self.redList = {}
    local popId = nil
    local red = nil

    for iconType,camp in pairs(tree) do
        local activeIconData = DataCampaign.data_camp_ico[iconType]
        local systemIconData = DataSystem.data_daily_icon[(activeIconData or {}).ico_id or 0]
        if self.specilIconType[iconType] == nil and activeIconData ~= nil and systemIconData ~= nil then
            self.redList[iconType] = self.redList[iconType] or AtiveIconData.New()
            self.redList[iconType].id = systemIconData.id
            self.redList[iconType].iconPath = systemIconData.res_name
            self.redList[iconType].sort = systemIconData.sort
            self.redList[iconType].lev = systemIconData.lev
            self.redList[iconType].campList = self.redList[iconType].campList or {}

            local count = camp.count
            local id = nil
            local icon_type = iconType

            self.redList[iconType].count = 0

            for key,main in pairs(camp) do
                if key ~= "count" then
                    if id == nil or DataCampaign.data_list[main.sub[1].id].index < DataCampaign.data_list[id].index then
                        id = main.sub[1].id
                    end

                    -- if popId == nil and DataCampaign.data_list[main.sub[1].id].cond_type == CampaignEumn.ShowType.NewFashion and RoleManager.Instance.RoleData.lev >= systemIconData.lev then
                    --     popId = main.sub[1].id
                    -- end

                    for _,v in pairs(main.sub) do
                        self.redList[iconType].campList[v.id] = false
                        self:CheckRed(v.id)

                        if self.redPointList[v.id] ~= nil and self.redPointList[v.id] == true then
                            self.redList[iconType].campList[v.id] = self.redPointList[v.id]
                            self.redList[iconType].count = self.redList[iconType].count + 1
                        end

                        if v.id == 760 then
                            self.isSpecialIcon = true
                            self.isSpecialTitle = true
                        end
                    end
                end
            end

            MainUIManager.Instance:AddAtiveIcon3(self.redList[iconType])
            -- if MainUIManager.Instance.MainUIIconView ~= nil then
            --     MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(systemIconData.id,self.redList[iconType])
            -- end


            -- BaseUtils.dump(camp, tostring(iconType))
            self.redList[iconType].clickCallBack = function()
                if count == 1 then
                    if DataCampaign.data_list[id].cond_type == CampaignEumn.ShowType.RebateReward then
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rebatereward_window)
                    elseif DataCampaign.data_list[id].cond_type == CampaignEumn.ShowType.Exchange_Window then
                        local datalist = {}
                        local lev = RoleManager.Instance.RoleData.lev
                        local strList = StringHelper.Split(DataCampaign.data_list[id].camp_cond_client, ",")
                        local exchange_first = tonumber(strList[1]) or 2
                        local exchange_second = tonumber(strList[2]) or 28
                        for i,v in pairs(ShopManager.Instance.model.datalist[exchange_first][exchange_second]) do
                            table.insert(datalist, v)
                        end
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = DataCampaign.data_list[id].reward_title, extString = DataCampaign.data_list[id].content})
                    elseif DataCampaign.data_list[id].cond_type == CampaignEumn.ShowType.DiscountHalloween then
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.discountshopwindow2, {id})
                    elseif DataCampaign.data_list[id].cond_type == CampaignEumn.ShowType.CampaignInquiry then
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_inquiry_window)
                    elseif DataCampaign.data_list[id].cond_type == CampaignEumn.ShowType.WarmHeartGift then
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warmheartgift_window,{campId = id})
                    elseif DataCampaign.data_list[id].cond_type == CampaignEumn.ShowType.FashionSelection then
                        if FashionSelectionManager.Instance:IsFashionVoteEnd() == false then
                                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.fashion_selection_window,{campId = id})
                        elseif FashionSelectionManager.Instance:IsFashionVoteEnd() == true then
                                FashionSelectionManager.Instance:send20414()
                        end
                    elseif DataCampaign.data_list[id].cond_type == CampaignEumn.ShowType.DirectPackage then 
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.directpackagewindow,{campId = id})
                    elseif DataCampaign.data_list[id].cond_type == CampaignEumn.ShowType.WarOrder then 
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.warorderwindow, {index = 1, campId = id})
                    else
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_uniwin, {id})
                    end
                elseif count > 0 then
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_uniwin, {id})
                end
            end

        end

        EventMgr.Instance:Fire(event_name.camp_red_change,iconType)
    end
    self.initTree = true

    if self.init == false then
        self:AddListeners()
        self.init = true
    end
    EventMgr.Instance:Fire(event_name.camp_red_change,iconType)

end

function CampaignModel:CheckCondType()
    -- print("新增活动管理列表==============================================================================================")
    for k,v in pairs(self.iconTypeList) do
        for k2,v2 in pairs(v) do
            self:CheckActiveRed(v2)
        end
    end
end

function CampaignModel:CheckRedCondType(type)   --IconType
    if self.redList[type] ~= nil then
        for id, v in pairs(self.redList[type].campList) do
            if tonumber(id) ~= nil and v ~= nil then
                self:CheckRed(id)
            end
        end
        EventMgr.Instance:Fire(event_name.camp_red_change, type)
    end
end

function CampaignModel:CheckMainIconRed(iconType)
    if iconType ~= nil then
        local activeIconData = DataCampaign.data_camp_ico[iconType]
        local systemIconData = DataSystem.data_daily_icon[(activeIconData or {}).ico_id or 0]

        if self.redList[iconType] ~= nil then
            if MainUIManager.Instance.MainUIIconView ~= nil then
                MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(systemIconData.id,self.redList[iconType].count > 0)
            end
        end
    end
end

function CampaignModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = CampaignWindow.New(self,args)
    end
    self.mainWin:Open(args)
end


function CampaignModel:OpenSecondaryWindow(args)
    if #args < 1 then
        Log.Error("打开次级窗口参数不符合要求")
    end

    if self.redList[args[1]] == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启"))
        return
    end

    if self.redList[args[1]].campList[args[2]]  == nil then

        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启"))
        return
    end

    local id = args[2]
    local campaignData = DataCampaign.data_list[id]
    if campaignData.cond_type == CampaignEumn.ShowType.Exchange_Window then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {id = id,iddatalist = datalist, title = TI18N("七夕兑换"), extString = ""})
    else
        if self.secondaryWin == nil then
            self.secondaryWin = CampaignSecondaryWindow.New(self)
        end
        self.secondaryWin:Open(args)
    end
end


function CampaignModel:OpenSecondaryTopWindow(args)
    if #args < 1 then
        Log.Error("打开次级窗口参数不符合要求")
    end

    if self.redList[args[1]] == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启"))
        return
    end

    if self.redList[args[1]].campList[args[2]] == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启"))
        return
    end

    local id = args[2]
    local campaignData = DataCampaign.data_list[id]

    if self.secondaryTopWin == nil then
        self.secondaryTopWin = CampaignSecondaryTopWindow.New(self)
    end
    self.secondaryTopWin:Open(args)

end
--检查子活动是否显示红点，当子活动显示红点时，将设置redlist里面的count++和对应的bool值
function CampaignModel:CheckActiveRed(id)
    self:CheckRed(id)
    local campaignData = DataCampaign.data_list[id]
    local iconType = tonumber(campaignData.iconid)
    local isRed = true
    if self.redPointList[id] ~= nil and self.redList[iconType] ~= nil then
        if self.redList[iconType].campList[id] == nil or (self.redList[iconType].campList[id] ~= nil and self.redPointList[id] ~= self.redList[iconType].campList[id]) then
            self.redList[iconType].campList[id] = self.redPointList[id]

            if self.redPointList[id] == true then
               self.redList[iconType].count = self.redList[iconType].count + 1
            else
                if self.redList[iconType].count > 0 then
                    self.redList[iconType].count = self.redList[iconType].count - 1
                end
            end
        end
    end


    --根据redlist里面的内容去设置是否显示主ui图标红点
    if self.redList[iconType] ~= nil and self.redList[iconType].campList[id] ~= nil then
        EventMgr.Instance:Fire(event_name.camp_red_change,iconType)
    end
end


function CampaignModel:CheckRed(id)
    local campaignData = DataCampaign.data_list[id]
    local type = campaignData.cond_type
    local protoData = CampaignManager.Instance.campaignTab[id]

    if protoData == nil then
        return
    end

    if campaignData.cond_type == CampaignEumn.ShowType.BuyPackage then
        self.redPointList[id] = (#campaignData.loss_items == 0 and protoData.status == CampaignEumn.Status.Finish)
    elseif campaignData.cond_type == CampaignEumn.ShowType.IntiMacy then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckIntimacy()
    elseif campaignData.cond_type == CampaignEumn.ShowType.RechargeGift then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckRechargePack(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.ToyReward then
        self.redPointList[id] = CampaignRedPointManager.Instance:IsCheckToyReward()
    elseif campaignData.cond_type == CampaignEumn.ShowType.Turntable then
        self.redPointList[id] = CampaignRedPointManager.Instance:isTurnRechargeActive()
    elseif campaignData.cond_type == CampaignEumn.ShowType.FlowerOpen then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckFlowerPanel()
    elseif campaignData.cond_type == CampaignEumn.ShowType.FlowerHundred then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckHundredPanel(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.FlowerAccept then
        self.redPointList[id] = CampaignRedPointManager.Instance:IsFlowerPanelActive()
    elseif campaignData.cond_type == CampaignEumn.ShowType.ValentineActiveFirst then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckRechargePack(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.AutumnBargain then
        self.redPointList[id] = CampaignRedPointManager.Instance:CampaignAutumnActive(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.Zongzi then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckRedZongzi(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.Consume then
        self.redPointList[id] = protoData.status == CampaignEumn.Status.Finish
    elseif campaignData.cond_type == CampaignEumn.ShowType.DiscountHalloween then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckDiscount(id) and CampaignManager.Instance.DiscountShop_show
    elseif campaignData.cond_type == CampaignEumn.ShowType.DollsRandom then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckDolls(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.SaveSingleDog then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckSingleDog(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.CampaignInquiry then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckInquiry(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.SummerDoing then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckRedSummer(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.SalesPromotion then
        self.redPointList[id] = CheckChristmasSnowMan
    elseif campaignData.cond_type == CampaignEumn.ShowType.Lantern then
        self.redPointList[id] = (protoData.status == CampaignEumn.Status.Finish) -- CampaignRedPointManager.Instance:CheckRedLantern(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.RideShow then
        self.redPointList[id] = CampaignManager.Instance.christmas_ride
    elseif campaignData.cond_type == CampaignEumn.ShowType.CuteSnowMan then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckChristmasSnowMan(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.FashionSelection then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckFashionSelectionRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.FashionDiscount then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckFashionDiscountRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.RechargeCoupon then
        self.redPointList[id] = CampaignRedPointManager.Instance:RechargeGift(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.NewYearTurnable then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckNewYearTurnableRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.LuckyMoney then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckLuckyMoneyRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.LanternMultiRecharge then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckLanternMultiRechargeRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.SignDraw then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckSignDrawRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.AprilTreasure then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckAprilTreasureRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.PassBless then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckPassBlessRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.LimitTimeStore then
        --限时商店
        self.redPointList[id] = CampaignRedPointManager.Instance:TimeShop2()
    elseif campaignData.cond_type == CampaignEumn.ShowType.TreasureHunting then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckTreasureHuntingRed()
    elseif campaignData.cond_type == CampaignEumn.ShowType.FullSubtraction then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckFullSubtractionShopRed()
    elseif campaignData.cond_type == CampaignEumn.ShowType.FruitPlant then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckFruitPlantRed()
    elseif campaignData.cond_type == CampaignEumn.ShowType.IntegralExchange then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckIntegralExchangeRed()
    elseif campaignData.cond_type == CampaignEumn.ShowType.SurpriseShop then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckSurpriseDisCountShopRed()
    elseif campaignData.cond_type == CampaignEumn.ShowType.CollectWord then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckCollectionWordExchangeRed()
    elseif campaignData.cond_type == CampaignEumn.ShowType.ScratchCard then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckScratchCardRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.DirectPackage then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckDirectPackageRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.LuckyTree then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckLuckyTreeRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.CustomGift then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckCustomGiftRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.WarOrder then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckWarOrderRed(id)
    elseif campaignData.cond_type == CampaignEumn.ShowType.PrayTreasure then
        self.redPointList[id] = CampaignRedPointManager.Instance:CheckPrayTreasureRed(id)
    end
    if self.initTree == false then
        local isRed = true
        if self.redPointList[id] ~= nil then
        else
            isRed = false
        end

        if isRed == true then
            if self.iconTypeList[campaignData.cond_type] == nil then
                self.iconTypeList[campaignData.cond_type] = {}
            end
            table.insert(self.iconTypeList[campaignData.cond_type],id)
        end
    end


end

function CampaignModel:ReloadIconById(campId)
    local campaignData = DataCampaign.data_list[campId]
    if CampaignManager.Instance.campaignTree[tonumber(campaignData.iconid)] then
        local activeIconData = DataCampaign.data_camp_ico[tonumber(campaignData.iconid)]
        local systemIconData = DataSystem.data_daily_icon[(activeIconData or {}).ico_id or 0]
        if self.specilIconType[campaignData.iconid] == nil and activeIconData ~= nil and systemIconData ~= nil then
            local red = false
            for key,main in pairs(CampaignManager.Instance.campaignTree[tonumber(campaignData.iconid)]) do
                if key ~= "count" then
                    for _,v in pairs(main.sub) do
                        red = red or (self.redPointList[v.id] == true)
                    end
                end
            end
            if MainUIManager.Instance.MainUIIconView ~= nil then
                MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(systemIconData.id, red)
            end
        end
    end
end

function CampaignModel:GetIdsByType(cond_type)
    local list = {}
    for id,v in pairs(CampaignManager.Instance.campaignTab) do
        if v ~= nil and DataCampaign.data_list[id].cond_type == cond_type then
            table.insert(list, id)
        end
    end
    return list
end


function CampaignModel:GetCondTypeById(id)
    local cond_type = 0
    if DataCampaign.data_list[id] then 
        cond_type =  DataCampaign.data_list[id].cond_type
    end
    return cond_type
end

