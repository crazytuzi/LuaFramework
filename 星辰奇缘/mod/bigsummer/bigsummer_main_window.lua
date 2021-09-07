BigSummerMainWindow = BigSummerMainWindow or BaseClass(BaseWindow)


function BigSummerMainWindow:__init(model,manager)
    self.mgr = manager
    self.model = model
    self.name = "BigSummerMainWindow"
    self.cacheMode = CacheMode.Visible
    self.windowId = WindowConfig.WinID.bigsummer_main_window

    self.resList = {
        {file = AssetConfig.summer_gift_main_window, type = AssetType.Main},
        {file = AssetConfig.newmoon_textures, type = AssetType.Dep}
        -- {file = AssetConfig.summergift_main_window_textures,type = AssetType.Main}
        -- {file = AssetConfig.dragonboat_textures, type = AssetType.Dep},
        -- {file = AssetConfig.may_textures, type = AssetType.Dep},
        -- {file = AssetConfig.teamquest, type = AssetType.Dep},
    }

    self.tabList = {}
    self.panelIdList = {}
    self.lastcampaignId = 0

    self.redListener = function() self:CheckRedPoint() end


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.setting = {
         -- 是否默认选中一个
           notAutoSelect = true,
          -- 标签是否支持重复按下监测
          perWidth = 174,
          perHeight = 60,
          offsetHeight = 0,
          --是否垂直
          isVertical = true
     }

     self.tabGroup = nil
     self.redPointList = {}

     EventMgr.Instance:AddListener(event_name.campaign_change,self.redListener)

     self.secondPanel = nil
     self.secondId = 0
     self.campaignId = CampaignEumn.Type.BigSummer

end

function BigSummerMainWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.campaign_change,self.redListener)
    self.OnHideEvent:Fire()

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.panelIdList ~= nil then
        for _,v in pairs(self.panelIdList) do
            if v ~= nil then
                v:DeleteMe()
                if v ~= nil then
                    v = nil
                end
            end
        end
        self.panelIdList = nil
    end


    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BigSummerMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.summer_gift_main_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.titleImg = t:Find("Main/Title/Image"):GetComponent(Image)
    self.titleImg.sprite = self.assetWrapper:GetSprite(AssetConfig.newmoon_textures, "TitleI18N")
    -- self.titleImg.transform.anchoredPosition = Vector2(self.titleImg.anchoredPosition.x,35)

    -- t:Find("Main/Title/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.dragonboat_textures, "i18ndragonboattitle")--"TitleI18N1")
    -- t:Find("Main/Title/Image"):GetComponent(Image):SetNativeSize()

    self.leftContainer = t:Find("Main/Panel/Left/Container").gameObject
    self.baseItem = t:Find("Main/Panel/Left/MainButton").gameObject
    self.baseItem.transform:Find("Notify").gameObject:SetActive(false)
    t:Find("Main/Panel/Left/Arrow").gameObject:SetActive(false)

    self.rightContainer = t:Find("Main/Panel/Right").gameObject
    self.rightTransform = self.rightContainer.transform

    self:OnOpen()
end
function BigSummerMainWindow:OnOpen()
    self.openRebateWin = true
    BigSummerManager.Instance.OnUpdateRedPoint:AddListener(self.redListener)
    self:InitTabList()

    self:CheckRedPoint()

      if self.tabGroup == nil then
        self.tabGroup = CampaignTabGroup.New(self.leftContainer,self.tabList,function(index) self:ChangeTab(index) end,self.setting)
    end

    if self.openArgs ~= nil then
        self.openTab = self.openArgs[1]
        self.tabGroup:ChangeTab(self.openTab)
    end



end
function BigSummerMainWindow:OnHide()
    EventMgr.Instance:RemoveListener(event_name.campaign_change,self.redListener)
    self.mgr.Instance.OnUpdateRedPoint:RemoveListener(self.redListener)
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
end


function BigSummerMainWindow:InitTabList()

        for k,v in pairs(self.tabList) do
            v.active = false
        end

       local temData = CampaignManager.Instance.campaignTree[self.campaignId]
       for index,v in pairs(temData) do
        if index ~= "count" then
            if #v.sub > 1 then
                table.sort(v.sub,function(a,b)
                if a.id ~= b.id then
                    return a.id < b.id
                else
                    return false
                end
                end)
            end

            local obj = nil
            if self.tabList[v.sub[1].id] == nil then
                self.tabList[v.sub[1].id] = {}
                obj = GameObject.Instantiate(self.baseItem)
                obj.transform:SetParent(self.leftContainer.transform)
                obj.transform.localScale = Vector3.one
                self.tabList[v.sub[1].id].obj = obj

            end

            self.tabList[v.sub[1].id].name = DataCampaign.data_list[v.sub[1].id].name
            self.tabList[v.sub[1].id].index = v.index

            self.tabList[v.sub[1].id].icon = self.tabList[v.sub[1].id].obj.transform:Find("Icon")
            self.redPointList[v.sub[1].id] = self.tabList[v.sub[1].id].obj.transform:Find("Notify")
            self.tabList[v.sub[1].id].obj.transform:Find("Select/Text"):GetComponent(Text).text = self.tabList[v.sub[1].id].name
            self.tabList[v.sub[1].id].obj.transform:Find("Normal/Text"):GetComponent(Text).text = self.tabList[v.sub[1].id].name
            self.tabList[v.sub[1].id].active = true
            self.tabList[v.sub[1].id].campaignId = v.sub[1].id

            if v.sub[1].id == CampaignEumn.BigSummer.BigSummer then
                self.tabList[v.sub[1].id].icon:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newmoon_textures, "Icon2")
            elseif v.sub[1].id == CampaignEumn.BigSummer.Grouppurchase then
                self.tabList[v.sub[1].id].icon:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.newmoon_textures, "Icon1")
            end
        end
       end

       self.baseItem.gameObject:SetActive(false)
end


function BigSummerMainWindow:ChangeTab(campaignId)
--    if self.lastcampaignId == index then
--        return
--    end
    if self.lastcampaignId ~= 0 then
        if self.panelIdList[self.lastcampaignId] ~= nil then
            self.panelIdList[self.lastcampaignId]:Hiden()
        end
    end

    local panelId = nil
    local tablist = self.tabList[campaignId]

    if campaignId == CampaignEumn.BigSummer.BigSummer and self.panelIdList[campaignId] == nil then

        panelId = BigSummerPubPanel.New(self.model,self.rightContainer)
        self.panelIdList[campaignId] = panelId

    elseif campaignId == CampaignEumn.BigSummer.Grouppurchase and self.panelIdList[campaignId] == nil then
        DoubleElevenManager.Instance.model.bg = AssetConfig.groupbuybg
        panelId = DoubleElevenGroupBuyPanel.New(DoubleElevenManager.Instance.model,self.rightContainer,self)
        panelId.campId = campaignId
        self.panelIdList[campaignId] = panelId
    end


    -- elseif index == CampaignEumn.SummerGift.SummerGift then
    --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.SummerGift_tab_window)
    -- elseif index == CampaignEumn.SummerGift.Recharge and self.panelIdList[index] == nil then
    --     panel = DoubleElevenFeedbackPanel.New(model, self.rightContainer)
    --     panel.bg = AssetConfig.summer_recharge_big_bg
    --     panel.campaignData = DataCampaign.data_list[689]
    --     panel.target = "44_1"
    --     self.panelIdList[index] = panel
    -- elseif index == CampaignEumn.SummerGift.Exchange then

    --     local datalist = {}
    --     local lev = RoleManager.Instance.RoleData.lev
    --     for i,v in pairs(ShopManager.Instance.model.datalist[2][20]) do
    --         table.insert(datalist, v)
    --     end
    --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = TI18N("夏日兑换"), extString = "{assets_2,90042}可在夏日翻翻乐活动中获得"})
    -- end

    if self.panelIdList[campaignId] ~= nil then
        self.panelIdList[campaignId]:Show()
    end

    self.lastcampaignId = campaignId
end


function BigSummerMainWindow:CheckRedPoint()
    if self.mgr.Instance.redPointDic ~= nil then
        for k,v in pairs(self.mgr.Instance.redPointDic) do
           if self.redPointList[k] ~= nil then
                if v == true then
                    self.redPointList[k].gameObject:SetActive(true)
                else
                    self.redPointList[k].gameObject:SetActive(false)
                end
            end
        end
    end
end
