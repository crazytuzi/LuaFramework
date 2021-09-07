Marry_WeddingView = Marry_WeddingView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function Marry_WeddingView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marry_wedding_window
    self.name = "Marry_WeddingView"
    self.resList = {
        {file = AssetConfig.marry_wedding_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
        , {file = AssetConfig.homeTexture, type = AssetType.Dep}
    }

    -----------------------------------------
    self.moneyText1 = nil
    self.moneyText2 = nil

    self.item_list1 = {}
    self.item_list2 = {}

    self.selectWeddingType = 0
    self.selectHome = 0

    self.itemSlotList = {}
    -----------------------------------------

    MarryManager.Instance:Send15024()
end

function Marry_WeddingView:__delete()
    for k,v in pairs(self.itemSlotList) do
        v:DeleteMe()
        v = nil
    end


    self:ClearDepAsset()
end

function Marry_WeddingView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_wedding_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() MarryManager.Instance:Send15008(0, 0, "", 0) end)

    self.mainPanel = self.transform:FindChild("Main").gameObject
    self.subPanel = self.transform:FindChild("Sub").gameObject

    self.moneyText1 = self.transform:FindChild("Main/MoneyText1"):GetComponent(Text)
    self.moneyText2 = self.transform:FindChild("Main/MoneyText2"):GetComponent(Text)

    local btn = nil
    btn = self.transform:FindChild("Main/Button1"):GetComponent(Button)
    btn.onClick:AddListener(function() self:Button1Click() end)

    btn = self.transform:FindChild("Main/Button2"):GetComponent(Button)
    btn.onClick:AddListener(function() self:Button2Click() end)

    self.itemsoltpanel1 = self.transform:FindChild("Main/Mask1/SoltPanel").gameObject
    self.itemsoltpanel2 = self.transform:FindChild("Main/Mask2/SoltPanel").gameObject

    self:Update()
end

function Marry_WeddingView:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.marry_wedding_window)
end

function Marry_WeddingView:Update()
    self.moneyText1.text = "1800000"
    self.moneyText2.text = "1314"
    local baseTime = BaseUtils.BASE_TIME
    local startTime = nil
    local endTime = nil

    if BackendManager.Instance.isEasyMerry ~= true then
        for i=1,2 do
            for _,dat in pairs(DataWedding.data_discount_price) do
                if dat.type == i then
                    if dat.start_time[1][4] == nil then -- 合服
                        startTime = CampaignManager.Instance.merge_srv_time + dat.start_time[1][2] * 86400 + dat.start_time[1][3]
                        endTime = CampaignManager.Instance.merge_srv_time + dat.end_time[1][2] * 86400 + dat.end_time[1][3]
                    else
                        startTime = os.time({year = dat.start_time[1][1], month = dat.start_time[1][2], day = dat.start_time[1][3], hour = dat.start_time[1][4], min = dat.start_time[1][5], sec = dat.start_time[1][6]})
                        endTime = os.time({year = dat.end_time[1][1], month = dat.end_time[1][2], day = dat.end_time[1][3], hour = dat.end_time[1][4], min = dat.end_time[1][5], sec = dat.end_time[1][6]})
                    end
                    if startTime <= BaseUtils.BASE_TIME and BaseUtils.BASE_TIME < endTime then
                        self["moneyText"..i].text = dat.discount_price
                        break
                    end
                end
            end
        end
    else
        -- 后台活动
        local menuData = BackendManager.Instance:GetDataByPanelType(BackendEumn.PanelType.MarryEasy)
        if menuData ~= nil then
            self.moneyText1.text = menuData.camp_list[1].val1
            self.moneyText2.text = menuData.camp_list[1].val2
        end
    end

    local roleData = RoleManager.Instance.RoleData
    local itemList = DataWedding.data_wedding_reward[string.format("%s_%s", 1, roleData.sex)].items_cli
    for _, value in pairs(itemList) do
        local slot = ItemSlot.New()
        UIUtils.AddUIChild(self.itemsoltpanel1, slot.gameObject)

        local itembase = BackpackManager.Instance:GetItemBase(value[1])
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        itemData.quantity = value[3]
        slot:SetAll(itemData)

        table.insert(self.itemSlotList, slot)
    end

    itemList = DataWedding.data_wedding_reward[string.format("%s_%s", 2, roleData.sex)].items_cli
    for _, value in pairs(itemList) do
        local slot = ItemSlot.New()
        UIUtils.AddUIChild(self.itemsoltpanel2, slot.gameObject)

        local itembase = BackpackManager.Instance:GetItemBase(value[1])
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        itemData.quantity = value[3]
        slot:SetAll(itemData)

        table.insert(self.itemSlotList, slot)
    end
end

function Marry_WeddingView:Button1Click()
    self.selectWeddingType = 1
    local home_list = MarryManager.Instance.model.home_list
    if home_list == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("网络不稳定，请稍后再试"))
    else
        -- BaseUtils.dump(home_list)
        if #home_list == 2 then
            self:ShowSubPanel()
        else
            self:Close()
            MarryManager.Instance:Send15008(1, 0, "", 0)
        end
    end
end

function Marry_WeddingView:Button2Click()
    self.selectWeddingType = 2
    local home_list = MarryManager.Instance.model.home_list
    if home_list == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("网络不稳定，请稍后再试"))
    else
        -- BaseUtils.dump(home_list)
        if #home_list == 2 then
            self:ShowSubPanel()
        else
            self:Close()
            MarryManager.Instance:Send15008(2, 0, "", 0)
        end
    end
end

function Marry_WeddingView:ShowSubPanel()
    self.mainPanel:SetActive(false)
    self.subPanel:SetActive(true)
    self:UpdateSubPanel()
end

function Marry_WeddingView:UpdateSubPanel()
    local home_list = MarryManager.Instance.model.home_list
    if home_list == nil or #home_list ~= 2 then return end

    local transform1 = self.transform:FindChild("Sub/bg1")
    local transform2 = self.transform:FindChild("Sub/bg2")

    local home_data = nil
    home_data = DataFamily.data_home_data[home_list[1].lev]
    if home_data ~= nil then
        transform1:FindChild("Text0"):GetComponent(Text).text = home_data.name2
        transform1:FindChild("Text1"):GetComponent(Text).text = home_data.name
        transform1:Find("ModelImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.homeTexture, string.format("home%s", home_data.lev))
    end
    home_data = DataFamily.data_home_data[home_list[2].lev]
    if home_data ~= nil then
        transform2:FindChild("Text0"):GetComponent(Text).text = home_data.name2
        transform2:FindChild("Text1"):GetComponent(Text).text = home_data.name
        transform2:Find("ModelImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.homeTexture, string.format("home%s", home_data.lev))
    end

    transform1:FindChild("Text2"):GetComponent(Text).text = home_list[1].role_name
    transform2:FindChild("Text2"):GetComponent(Text).text = home_list[2].role_name

    self.transform:FindChild("Sub/DescText"):GetComponent(Text).text = TI18N("请选择婚后伴侣二人共同的家园")

    transform1:GetComponent(Button).onClick:AddListener(function() self:SelectHome1() end)
    transform2:GetComponent(Button).onClick:AddListener(function() self:SelectHome2() end)

    self.transform:FindChild("Sub/OkButton"):GetComponent(Button).onClick:AddListener(function() self:SureSelectHome() end)

    self.transform:Find("Sub/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() MarryManager.Instance:Send15008(0, 0, "", 0) end)
end

function Marry_WeddingView:SelectHome1()
    self.selectHome = 1
    self.transform:FindChild("Sub/bg1/Select").gameObject:SetActive(true)
    self.transform:FindChild("Sub/bg2/Select").gameObject:SetActive(false)
end

function Marry_WeddingView:SelectHome2()
    self.selectHome = 2
    self.transform:FindChild("Sub/bg1/Select").gameObject:SetActive(false)
    self.transform:FindChild("Sub/bg2/Select").gameObject:SetActive(true)
end

function Marry_WeddingView:SureSelectHome()
    if self.selectHome ~= 0 then
        self:Close()
        local home_data = MarryManager.Instance.model.home_list[self.selectHome]
        MarryManager.Instance:Send15008(self.selectWeddingType, home_data.fid, home_data.fplatform, home_data.zone_id)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("您还未选择好家园哦"))
    end
end