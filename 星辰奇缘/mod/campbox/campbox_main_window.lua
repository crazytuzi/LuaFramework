CampBoxMainWindow = CampBoxMainWindow or BaseClass(BaseWindow)


function CampBoxMainWindow:__init(model)
    self.model = model
    self.name = "CampBoxMainWindow"
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.windowId = WindowConfig.WinID.campbox_main_window

    self.resList = {
        {file = AssetConfig.campbox_main_window, type = AssetType.Main}
        ,{file = AssetConfig.textures_campaign, type = AssetType.Dep}
       ,{file = AssetConfig.campbox_texture, type = AssetType.Dep}
        -- {file = AssetConfig.dragonboat_textures, type = AssetType.Dep},
        -- {file = AssetConfig.may_textures, type = AssetType.Dep},
        -- {file = AssetConfig.teamquest, type = AssetType.Dep},
    }

    self.tabList = {}
    self.panelIdList = {}
    self.lastIndex = 0

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
     self.imgLoaderList = {}

end

function CampBoxMainWindow:__delete()
    self.OnHideEvent:Fire()

    if self.imgLoaderList ~= nil then
        for k,v in pairs(self.imgLoaderList) do
            v:DeleteMe()
        end
    end

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
    if self.panelIdList ~= nil then
        for _,v in pairs(self.panelIdList) do
            if v ~= nil then
                v:DeleteMe()
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

function CampBoxMainWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.campbox_main_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.titleImg = t:Find("Main/Title/Image"):GetComponent(Image)

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
function CampBoxMainWindow:OnOpen()
    print("==================================================================================================")
    BaseUtils.dump(self.openArgs,"传入的参数")
    self.openRebateWin = true
    CampBoxManager.Instance.OnUpdateRedPoint:AddListener(self.redListener)
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
function CampBoxMainWindow:OnHide()
    CampBoxManager.Instance.OnUpdateRedPoint:RemoveListener(self.redListener)
    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
end


function CampBoxMainWindow:InitTabList()

        for k,v in pairs(self.tabList) do
            v.active = false
        end

       local temData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.CampBox]
       for index,v in pairs(temData) do
        if index ~= "count" then
            local obj = nil
            if self.tabList[v.sub[1].id] == nil then
                self.tabList[v.sub[1].id] = {}
                obj = GameObject.Instantiate(self.baseItem)
                obj.transform:SetParent(self.leftContainer.transform)
                obj.transform.localScale = Vector3.one
                obj.transform.localPosition = Vector3.zero
                self.tabList[v.sub[1].id].obj = obj

            end

            self.tabList[v.sub[1].id].name = DataCampaign.data_list[v.sub[1].id].name
            self.tabList[v.sub[1].id].index = v.index

            self.tabList[v.sub[1].id].icon = self.tabList[v.sub[1].id].obj.transform:Find("Icon")
            self.redPointList[self.tabList[v.sub[1].id].index] = self.tabList[v.sub[1].id].obj.transform:Find("Notify")
            self.tabList[v.sub[1].id].obj.transform:Find("Select/Text"):GetComponent(Text).text = self.tabList[v.sub[1].id].name
            self.tabList[v.sub[1].id].obj.transform:Find("Normal/Text"):GetComponent(Text).text = self.tabList[v.sub[1].id].name
            self.tabList[v.sub[1].id].active = true
            self.tabList[v.sub[1].id].campaignId = v.sub[1].id

            if v.sub[1].id == CampaignEumn.CampBox.CampBox then
            self.tabList[v.sub[1].id].icon:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign, "campboxtab2")
            elseif v.sub[1].id == CampaignEumn.CampBox.SummerQuest then
             self.tabList[v.sub[1].id].icon:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign, "tab_quest")
            elseif v.sub[1].id == CampaignEumn.CampBox.Exchange then
             self.tabList[v.sub[1].id].icon:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign, "campboxtab4")
            elseif v.sub[1].id == CampaignEumn.CampBox.Recharge then
                self.imgLoaderList[v.sub[1].id] = SingleIconLoader.New(self.tabList[v.sub[1].id].icon.gameObject)
                self.imgLoaderList[v.sub[1].id]:SetSprite(SingleIconType.Item,90002)
            end
        end
       end

       self.baseItem.gameObject:SetActive(false)
end


function CampBoxMainWindow:ChangeTab(index)
--    if self.lastIndex == index then
--        return
--    end
    if self.lastIndex ~= 0 then
        if self.panelIdList[self.lastIndex] ~= nil then
            self.panelIdList[self.lastIndex]:Hiden()
        end
    end

    local panel = nil
    local tablist = self.tabList[index];
    if index == CampaignEumn.CampBox.SummerQuest and self.panelIdList[index] == nil then
        panel = SummerQuest.New(self.model,self.rightContainer)
        panel.bg = AssetConfig.summer_quest_big_bg
        panel.campId = 685
        self.panelIdList[index] = panel
    elseif index == CampaignEumn.CampBox.CampBox then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campbox_tab_window)
    elseif index == CampaignEumn.CampBox.Recharge and self.panelIdList[index] == nil then
        panel = DoubleElevenFeedbackPanel.New(model, self.rightContainer)
        panel.bg = AssetConfig.summer_recharge_big_bg
        panel.campaignData = DataCampaign.data_list[689]
        panel.target = "44_1"
        self.panelIdList[index] = panel
    elseif index == CampaignEumn.CampBox.Exchange then

        local datalist = {}
        local lev = RoleManager.Instance.RoleData.lev
        for i,v in pairs(ShopManager.Instance.model.datalist[2][20]) do
            table.insert(datalist, v)
        end
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = TI18N("夏日兑换"), extString = "{assets_2,90042}可在夏日翻翻乐活动中获得"})
    end

    if self.panelIdList[index] ~= nil then
        self.panelIdList[index]:Show()
    end

    self.lastIndex = index
end


function CampBoxMainWindow:CheckRedPoint()
    if CampBoxManager.Instance.redPointDic ~= nil then
        for k,v in pairs(CampBoxManager.Instance.redPointDic) do
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
