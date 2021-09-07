-- @author zyh
-- @date 2017年8月26日
CampaignSecondaryWindow = CampaignSecondaryWindow or BaseClass(BaseWindow)

function CampaignSecondaryWindow:__init(model)

    self.model = model
    self.windowId = WindowConfig.WinID.campaign_secondarywin


     self.resList = {
        {file = AssetConfig.marchevent_window,type = AssetType.Main, holdTime = 5}
         ,{file = AssetConfig.marchevent_texture, type = AssetType.Dep}
        -------------------刮刮乐系列----------
        ,{file = AssetConfig.card_exchange_window,type = AssetType.Main}
        ,{file = AssetConfig.card_exchange_bg1,type = AssetType.Main}
        ,{file = AssetConfig.card_exchange_bg2,type = AssetType.Main}
        ,{file = AssetConfig.card_exchange_bg3,type = AssetType.Main}
        ,{file = AssetConfig.cardexchangetexture,type = AssetType.Dep}
        --------------------------------------

         ,{file = AssetConfig.campaign_icon,type = AssetType.Dep}
         ,{file = AssetConfig.may_textures,type = AssetType.Dep}
         ,{ file =  AssetConfig.textures_campaign, type = AssetType.Dep }
         ,{ file =  AssetConfig.dropicon, type = AssetType.Dep }
    }
  
    self.redPointListener = function() self:CheckRedPoint() end

    self.OnOpenEvent:AddListener(function()
      self:OnOpen()
    end)

    self.OnHideEvent:AddListener(function()
      self:OnHide()
    end)

    self.currentTabIndex = 1
    self.classIndex = 1

    self.tabObjList = {}
    self.tabRedPoint = {}
    self.txtList = {}
    self.contentList = {}


    self.classList = {}
    self.panelList = {}
    self.lastIndex = 0
    self.lastGroupIndex = 0
    self.isInit = false
end

function CampaignSecondaryWindow:InitPanel()
--    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marchevent_window))

   -------------------刮刮乐系列----------
   self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.card_exchange_window))
   --------------------------------------
   
   self.gameObject.name = "CampaignSecondaryWindow"
   self.transform = self.gameObject.transform
   UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)
   self.mainContainer = self.transform:Find("Main").gameObject
   
   -------------------刮刮乐系列----------
   local bg =  GameObject.Instantiate(self:GetPrefab(AssetConfig.card_exchange_bg2))
   UIUtils.AddBigbg(self.transform:Find("Main/zs2"),bg)
   bg.transform.anchoredPosition = Vector2(-256,165)

   bg =  GameObject.Instantiate(self:GetPrefab(AssetConfig.card_exchange_bg2))
   UIUtils.AddBigbg(self.transform:Find("Main/zs2"),bg)
   bg.transform.anchoredPosition = Vector2(349,165)

   bg =  GameObject.Instantiate(self:GetPrefab(AssetConfig.card_exchange_bg1))
   UIUtils.AddBigbg(self.transform:Find("Main/zs2"),bg)
   bg.transform.anchoredPosition = Vector2(-300,208)

   bg =  GameObject.Instantiate(self:GetPrefab(AssetConfig.card_exchange_bg3))
   UIUtils.AddBigbg(self.transform:Find("Main/zs2"),bg)
   bg.transform.anchoredPosition = Vector2(-268,-278)
   -------------------------------------


   self.transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function()
      WindowManager.Instance:CloseWindow(self)
   end)
   
   self.tabListPanel = self.transform:Find("Main/TabListPanel")
   self.tabTemplate = self.tabListPanel:Find("TabButton").gameObject
   self.tabLayout = LuaBoxLayout.New(self.transform:Find("Main/TabListPanel").gameObject, {axis = BoxLayoutAxis.Y, spacing = 0})
   self.tabTemplate:SetActive(false)

   self.title = self.transform:Find("Main/TitleImage/TextImage"):GetComponent(Image)
   self.title.transform.gameObject:SetActive(true)
--    self.title.sprite = self.assetWrapper:GetSprite(AssetConfig.textures_campaign,"HappyCeremonyI18N")   --欢乐盛典
   -------------------刮刮乐系列----------
   self.title.sprite = self.assetWrapper:GetSprite(AssetConfig.cardexchangetexture,"i18ntitle1")
   ----------------------------------------

   self.OnOpenEvent:Fire()
 end

function CampaignSecondaryWindow:OnOpen()
    self:RemoveListeners()
    self.lastGroupIndex = 0
    self.tabRedPoint = {}
    self.secondaryIconType = self.openArgs[1]
    self.secondaryIconId = self.openArgs[2]
    self.openId = self.openArgs[3]
    self:InitClassList()
    self:Layout()
    self.isInit = false

    if  self.openId ~= nil then
        self:SwitchTabs(self.openId)
    else
        self:SwitchTabs(self.classList[1].id)
    end
    self:CheckRedPoint()

    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.camp_red_change,self.redPointListener)
end

function CampaignSecondaryWindow:InitClassList()
    self.classList = {}
    local classesIndex = 1
    local myIndex = DataCampaign.data_list[self.secondaryIconId].index
    for key,main in pairs(CampaignManager.Instance.campaignTree[tonumber(self.secondaryIconType)]) do
        if key == myIndex then
            for k,v in pairs(main.sub) do
                if v.id ~= self.secondaryIconId then
                    self.classList[classesIndex] = {}
                    if self.model.campShowSpriteFuncTab[DataCampaign.data_list[v.id].cond_type] ~= nil then
                        self.classList[classesIndex].spriteFun = self.model.campShowSpriteFuncTab[DataCampaign.data_list[v.id].cond_type]
                    else
                        self.model.campShowSpriteFuncTab[DataCampaign.data_list[v.id].cond_type] = {package = AssetConfig.dropicon,name = tostring(DataCampaign.data_list[v.id].dropicon_id)}
                        self.classList[classesIndex].spriteFun = self.model.campShowSpriteFuncTab[DataCampaign.data_list[v.id].cond_type]
                    end
                    self.classList[classesIndex].id = v.id
                    self.classList[classesIndex].index = DataCampaign.data_list[v.id].index
                    self.classList[classesIndex].group_index = DataCampaign.data_list[v.id].group_index
                    self.classList[classesIndex].name = DataCampaign.data_list[v.id].name
                    self.classList[classesIndex].cond_type = DataCampaign.data_list[v.id].cond_type
                    self.classList[classesIndex].shopId = DataCampaign.data_list[v.id].shop_id
                    classesIndex = classesIndex + 1
                end
            end
        end
    end

     table.sort(self.classList,function(a,b)
               if a.group_index ~= b.group_index then
                    return a.group_index < b.group_index
                else
                    return a.id < b.id
                end
            end)

end


function CampaignSecondaryWindow:Layout()
    for i,v in ipairs(self.classList) do
      if v ~= nil and self.lastGroupIndex ~= v.group_index then
        self.lastGroupIndex = v.group_index
         if self.tabObjList[i] == nil then
            local obj = GameObject.Instantiate(self.tabTemplate)
            self.tabObjList[i] = obj
            self.tabLayout:AddCell(obj)
         end
         self.tabObjList[i].gameObject:SetActive(true)
         self.tabObjList[i].name = tostring(i)
         local t = self.tabObjList[i].transform
         local content = v.name
         self.tabRedPoint[v.id] = t:Find("RedPoint").gameObject
         local txt = t:Find("Text"):GetComponent(Text)
         txt.text = content
         self.tabObjList[i]:GetComponent(Button).onClick:AddListener(function() self:SwitchTabs(v.id) end)


        --  if v.spriteFun ~= nil then
        --     local tab = v.spriteFun
        --     t:Find("Text").anchoredPosition = Vector2(-3.4,8.7200001)
        --     if type(v.spriteFun) == "table" then
        --         local sprite = self.assetWrapper:GetSprite(tab.package,tab.name)
        --         if sprite == nil then
        --             sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, tostring(v.icon))
        --         end
        --         t:Find("Icon"):GetComponent(Image).sprite  = sprite
        --     end
        --     t:Find("Icon").gameObject:SetActive(true)
        --     t:Find("Icon").anchoredPosition = Vector2(-2,28)
        --  else
        --     t:Find("Text").anchoredPosition = Vector2(-3.4,21)
        --     t:Find("Icon").gameObject:SetActive(false)
        --  end

         self.txtList[i] = txt
         self.contentList[i] = content
        end
    end

    if #self.tabObjList > #self.classList then
        for i=#self.classList + 1,#self.tabObjList do
            self.tabObjList[i].gameObject:SetActive(false)
        end
    end
end

function CampaignSecondaryWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.camp_red_change,self.redPointListener)
end


function CampaignSecondaryWindow:SwitchTabs(id)
    local index = nil
    for k,v in pairs(self.classList) do
        if v.id == id then
            index = k
            break
        end
    end

    if self.currentTabIndex == index and self.isInit == true  then
        return
    end
    self.isInit = true
    -- self.txtList[self.currentTabIndex].text = string.format(ColorHelper.TabButton1NormalStr, self.contentList[self.currentTabIndex])
    -- self.txtList[index].text = string.format(ColorHelper.TabButton1SelectStr, self.contentList[index])
    self.txtList[self.currentTabIndex].text = string.format("<color='#BD4815'>%s</color>", self.contentList[self.currentTabIndex])
    self.txtList[index].text = string.format("<color='#7C1B1B'>%s</color>", self.contentList[index])

    self:EnableTab(self.currentTabIndex, false)
    self:EnableTab(index, true)
    self:ChangePanel(index)
    self.currentTabIndex = index
end

function CampaignSecondaryWindow:ChangePanel(index)

    if self.lastIndex == index then
        return
    end

    local type = self.classList[index].cond_type
    local id = self.classList[index].id
    if self.panelList[self.lastIndex] ~= nil then
        self.panelList[self.lastIndex]:Hiden()
    end
    self.lastIndex = index
    local panelId = nil
    if self.panelList[index] == nil then
        if type == CampaignEumn.ShowType.RechargeGift then
            panelId = RechargePackPanel.New(self.model, self)
            panelId.campId = self.classList[index].id
        elseif type == CampaignEumn.ShowType.ToyReward then
            panelId = ToyRewardPanel.New(self.model,self)
            panelId.campId = self.classList[index].id
        elseif type == CampaignEumn.ShowType.MarchEvent then
            panelId = MarchEventPanel.New(self.model, self)
            panelId.campId = self.classList[index].id
        elseif type == CampaignEumn.ShowType.Exchange_Window then
            local datalist = {}
            local lev = RoleManager.Instance.RoleData.lev
            local strList = StringHelper.Split(campaignData.camp_cond_client, ",")
            local exchange_first = tonumber(strList[1]) or 2
            local exchange_second = tonumber(strList[2]) or 26
            for i,v in pairs(ShopManager.Instance.model.datalist[exchange_first][exchange_second]) do
                table.insert(datalist, v)
            end
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = campaignData.reward_title, extString = campaignData.content})
        elseif type == CampaignEumn.ShowType.FlowerOpen then
            panelId = ChildBirthFlowerPanel.New(ChildBirthManager.Instance.model, self)
        elseif type == CampaignEumn.ShowType.FlowerHundred then
            panelId = ChildBirthHundredPanel.New(ChildBirthManager.Instance.model, self)
        elseif type == CampaignEumn.ShowType.DollsRandom then
            panelId = DollsRandomPanel.New(self)
            panelId.campId = self.classList[index].id
        elseif type == CampaignEumn.ShowType.ValentineActiveFirst then
        elseif type == CampaignEumn.ShowType.ScratchCard then
            panelId = ScratchCardPanel.New(CardExchangeManager.Instance.model ,self)
            panelId.campId = self.classList[index].id
        elseif type == CampaignEumn.ShowType.CollectWord then
            panelId = CollectionWordExchangePanel.New(CardExchangeManager.Instance.model ,self.mainContainer)
            panelId.campId = self.classList[index].id
        elseif type == CampaignEumn.ShowType.SurpriseShop then
            panelId = SurpriseDisCountShopPanel.New(CardExchangeManager.Instance.model ,self.mainContainer)
            panelId.campId = self.classList[index].id
        end
        self.panelList[index] = panelId
    end

    if self.panelList[index] ~= nil then
        self.panelList[index]:Show()
    end
end

function CampaignSecondaryWindow:__delete()
    self:RemoveListeners()

    if self.tabLayout ~= nil then
        self.tabLayout:DeleteMe()
        self.tabLayout = nil
    end

    for k,v in pairs(self.panelList) do
        v:DeleteMe()
    end
    self.panelList = {}

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function CampaignSecondaryWindow:OnHide()
    self:RemoveListeners()
    self.model:HideAllPanel()
end

function CampaignSecondaryWindow:CheckRedPoint()
    --BaseUtils.dump(self.tabRedPoint,"二级红点表")
    --BaseUtils.dump(self.model.redPointList,"一级红点表")
    local redPointDic = self.model.redPointList
    local bool = nil
    for k,v in pairs(self.tabRedPoint) do
        if redPointDic[k] ~= nil then
            if redPointDic[k] == true then
                self.tabRedPoint[k].gameObject:SetActive(true)
            else
                self.tabRedPoint[k].gameObject:SetActive(false)
            end
        else
            self.tabRedPoint[k].gameObject:SetActive(false)
        end
    end
end


function CampaignSecondaryWindow:EnableTab(main, bool)

    if bool == true then
        -- self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Select")
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.cardexchangetexture,"bt2")
        -- self.tabObjList[main].transform:Find("Text"):GetComponent(Text).color = 
    else
        -- self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton1Normal")
        self.tabObjList[main].transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.cardexchangetexture,"bt1")
    end
end

