-- @author hze
-- @date #2019/09/16#
-- 祈愿宝阁
PrayTreasureWindow = PrayTreasureWindow or BaseClass(BaseWindow)

function PrayTreasureWindow:__init(model)
    self.model = model
    self.name = "PrayTreasureWindow"

    self.mgr = CampaignProtoManager.Instance

    self.windowId = WindowConfig.WinID.praytreasurewindow

    -- self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.pray_treasure_window, type = AssetType.Main}
        ,{file = AssetConfig.pray_treasure_bg, type = AssetType.Main}
        ,{file = AssetConfig.praytreasuretextures, type = AssetType.Dep}
    }

    self.curIndex = 0
    self.panelList = {}
    self.buttonList = {}

    self.campId = nil

    self.checkRed = function() self:SetRed() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function PrayTreasureWindow:__delete()
    self.OnHideEvent:Fire()

    if self.panelList ~= nil then
        for _, panel in pairs(self.panelList) do
            if panel ~= nil then
                panel:DeleteMe()
            end
        end
    end
end

function PrayTreasureWindow:OnHide()
    self:RemoveListeners()

    self.openArgs = nil
    -- local panel = self.panelList[self.curIndex]
    -- if panel ~= nil then
    --     panel:Hiden()
    -- end
end

function PrayTreasureWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PrayTreasureWindow:AddListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.checkRed)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.checkRed)
end

function PrayTreasureWindow:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.checkRed)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.checkRed)
end

function PrayTreasureWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pray_treasure_window))
    self.gameObject.name = "PrayTreasureWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    UIUtils.AddBigbg(self.transform:Find("Main/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.pray_treasure_bg)))

    local main = self.transform:Find("Main/Main")

    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindowById(self.windowId) end) 

    self.titleImg = main:Find("TitleText"):GetComponent(Image)
    self.timeTxt = main:Find("TimeText"):GetComponent(Text)

    for i = 1, 4 do
        self.buttonList[i] = main:Find("Button" .. i):GetComponent(Button)
        self.buttonList[i].onClick:AddListener(function() self:ChangeTab(i) end)
    end

    self.tipsBtn = main:Find("TipsBtn"):GetComponent(Button)
    self.tipsBtn.onClick:AddListener(function() self:OnTipsClick() end)

    self.contentTrans = main:Find("Content")
end

function PrayTreasureWindow:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    local index = 1
    if self.openArgs then
        index = self.openArgs.index or 1
        self.campId = self.openArgs.campId
    end

    if #self.openArgs > 0 then
        self.campId = self.openArgs[1]
        index = self.openArgs[2]
    end

    self.campId = self.campId or self.model.prayTreasure_campId
    self.model.prayTreasure_campId = self.campId

    -- BaseUtils.dump(self.openArgs)
    print("campId:" .. self.campId)

    self.campaignData = DataCampaign.data_list[self.campId]
    self:SetCampTimeTxt()

    if self.model:GetFullSelectList() then
        self.buttonList[3].transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.praytreasuretextures, "font4")
    else
        self.buttonList[3].transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.praytreasuretextures, "font2")
    end
    self:SetRed()        
    -- self.mgr:Send21200()
    self:ChangeTab(index)
end

function PrayTreasureWindow:ChangeTab(index)
   if self.curIndex == index then
        return
    end

    if index == 4 then
        if self.model:GetFullSelectList() then
            self.model:OpenPrayTreasureRewardPanel()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请先挑选奖励哦"))
        end
        return
    end

    if self.curIndex and self.panelList[self.curIndex] then
        self.panelList[self.curIndex]:Hiden()
    end

    if index == 1 or index == 2 then
        self.buttonList[index].transform:Find("Select").gameObject:SetActive(true)
        self.buttonList[3 - index].transform:Find("Select").gameObject:SetActive(false)
    else
        self.buttonList[1].transform:Find("Select").gameObject:SetActive(false)
        self.buttonList[2].transform:Find("Select").gameObject:SetActive(false)
    end

    local panel = self.panelList[index]
    if panel == nil then
        if index == 1 then
            panel = PrayTreasureMainPanel.New(self.model, self.contentTrans)
        elseif index == 2 then
            panel = PrayTreasureShopPanel.New(self.model, self.contentTrans)
        elseif index == 3 then
            panel = PrayTreasureRewardPanel.New(self.model, self.contentTrans)
        elseif index == 4 then
            -- self.model:OpenPrayTreasureRewardPanel()
            -- return
        end
        self.panelList[index] = panel
    end

    if panel ~= nil then
        self.curIndex = index
        panel:Show({self.campId})
    end
end

function PrayTreasureWindow:OnTipsClick()
    local campBaseData = DataCampaign.data_list[self.campId]
    TipsManager.Instance:ShowText({gameObject = self.tipsBtn.gameObject, itemData = {campBaseData.cond_desc}, isChance = true})
    -- if self.curIndex == 1 then
        TipsManager.Instance.model:ShowChance({gameObject = self.tipsBtn.gameObject, chanceId = 215, special = true, isMutil = true})
    -- end
end

function PrayTreasureWindow:SetCampTimeTxt(str)
    self.timeTxt.text = TI18N("开业时间：") .. self.model:GetCampaignTimeStr(self.campId, 2)
end

function PrayTreasureWindow:SetRed()
    local red1 = self.model:GetPrayTreasureMainRedStatus()
    local red2 = self.model:GetPrayTreasureShopRedStatus()

    self.buttonList[1].transform:Find("Normal/Red").gameObject:SetActive(red1)
    self.buttonList[1].transform:Find("Select/Red").gameObject:SetActive(red1)
    self.buttonList[2].transform:Find("Normal/Red").gameObject:SetActive(red2)
    self.buttonList[2].transform:Find("Select/Red").gameObject:SetActive(red2)
end