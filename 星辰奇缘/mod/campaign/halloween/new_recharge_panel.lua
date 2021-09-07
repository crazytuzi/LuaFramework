NewRechargePanel = NewRechargePanel or BaseClass(BasePanel)

function NewRechargePanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.mgr = MagicEggManager.Instance

    self.resList = {
        {file = AssetConfig.newrechargepanel, type = AssetType.Main}
        --, {file = AssetConfig.petpartyi18n, type = AssetType.Main}
        , {file = AssetConfig.shop_textures, type = AssetType.Dep}
        , {file = AssetConfig.petpartyTitle1, type = AssetType.Main}
        , {file = AssetConfig.petpartyTitlei18n1, type = AssetType.Main}
        , {file = AssetConfig.halloween_textures, type = AssetType.Dep}
    }
    self.luckyList = {}
    self.showList = {}
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    self.OnHideEvent:Add( function() self:OnHide() end)

    self.updateListener = function() self:Reload() end

    self.protoData = CampaignManager.Instance.campaignTree[114][1]
end

function NewRechargePanel:__delete()
    self.OnHideEvent:Fire()
    if self.luckyList ~= nil then
        for k,v in pairs(self.luckyList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.luckyList = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.showListLayout ~= nil then
        self.showListLayout:DeleteMe()
        self.showListLayout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function NewRechargePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.newrechargepanel))
    self.gameObject.name = "NewRechargePanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    local t = self.transform

    self.quickRechargeBtn = t:Find("CheckArea/Button"):GetComponent(Button)
    self.quickRechargeBtn.onClick:AddListener(function() self:OnQuickRecharge() end)
    self.attentionText = t:Find("CheckArea/Attention/Text"):GetComponent(Text)

    self.cloner = t:Find("MaskLayer/ScrollLayer/Cloner").gameObject
    self.cloner:SetActive(false)
    self.container = t:Find("MaskLayer/ScrollLayer/Container")

    local setting1 = {
        column = 3
        ,cspacing = 3
        ,rspacing = 2
        ,cellSizeX = 186
        ,cellSizeY = 99
        ,bordertop = 2
        ,borderleft = 2
    }
    self.layout = LuaGridLayout.New(self.container, setting1)
    t:Find("DescArea/TimeBg").anchoredPosition = Vector2(-264.7,-72.1)
    t:Find("DescArea/Time").anchoredPosition = Vector2(213.1,-64)
    self.timeText = t:Find("DescArea/TimeBg/Time"):GetComponent(Text)
    local basedata = DataCampaign.data_list[self.protoData.sub[1].id]
    local cli_start_time = basedata.cli_start_time[1]
    local cli_end_time = basedata.cli_end_time[1]
    self.timeText.text = string.format(TI18N("活动时间:%s月%s日-%s月%s日"), tostring(cli_start_time[2]), tostring(cli_start_time[3]), tostring(cli_end_time[2]), tostring(cli_end_time[3]))
    --self.timeText.transform.anchoredPosition = Vector2(150, -75)

    self.attentionText.text = basedata.content
    self.effect = BibleRewardPanel.ShowEffect(20118, self.quickRechargeBtn.gameObject.transform, Vector3(1.1, 0.8,1), Vector3(-114.7,22.8,-100))

    UIUtils.AddBigbg(t:Find("DescArea/BigBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.petpartyTitle1)))
    UIUtils.AddBigbg(t:Find("DescArea/BigTitle"), GameObject.Instantiate(self:GetPrefab(AssetConfig.petpartyTitlei18n1)))

    self.downArea = t:Find("DownArea")
    --self.propName = self.downArea:Find("Name"):GetComponent(Text)
    self.propIconbg = self.downArea:Find("Bg"):GetComponent(Image)
    self.propIcon = self.downArea:Find("Bg/Icon"):GetComponent(Image)
    self.showListContainer = self.downArea:Find("Reward/ScrollRect/Container")
    self.showListLayout = LuaBoxLayout.New(self.showListContainer.gameObject,{axis = BoxLayoutAxis.X,cspacing = 5,border = 5}) 

    self.scrollRect = self.downArea:Find("Reward/ScrollRect"):GetComponent(ScrollRect)
    self.scrollRect.onValueChanged:AddListener(function(value)
        self:OnRectScroll(value)
    end)
    self.OnOpenEvent:Fire()
end

function NewRechargePanel:OnQuickRecharge()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3,1})
end

function NewRechargePanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()
    self:Reload()
    self:SetShowList()
    self:OnRectScroll(0)
end

function NewRechargePanel:Reload()
    self.protoData = CampaignManager.Instance.campaignTree[114][1]
    local obj = nil
    for i,v in ipairs(self.protoData.sub) do
        if self.luckyList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            self.layout:AddCell(obj)
            self.luckyList[i] = NewRechargeItem.New(self.model, obj, self.assetWrapper)
        end
        self.luckyList[i]:SetData(v, i)
    end
end

function NewRechargePanel:OnHide()
    self:RemoveListeners()
end

function NewRechargePanel:AddListeners()
end


function NewRechargePanel:RemoveListeners()
end


function NewRechargePanel:SetShowList()
    if self.protoData ~= nil and self.protoData.sub[1] ~= nil then
        local rewardData = DataCampaign.data_list[self.protoData.sub[1].id].rewardgift
        for i,v in pairs(rewardData) do
            if self.showList[i] == nil then
                local item_data = DataItem.data_get[v[5]]
                local itemData = ItemData.New()
                itemData:SetBase(item_data)
                local ItemSlot = ItemSlot.New()
                ItemSlot:SetAll(itemData,{inbag = false, nobutton = true})
                if v[7] == 1 then
                    ItemSlot:ShowEffect(true,20223)
                end
                self.showListLayout:AddCell(ItemSlot.gameObject)
                self.showList[i] = ItemSlot
            end
        end
    end
end

function NewRechargePanel:OnRectScroll(value)
    local right = 240
    local left = 5
    local state = false
    for k,v in pairs(self.showList) do
        local pos = v.transform.anchoredPosition.x + self.showListContainer.anchoredPosition.x
        
        if pos  < left or pos > right then
            state = false
        else
            state = true
        end
        -- if v.transform:FindChild("ItemImg/Effect") ~= nil then
        --     v.transform:FindChild("ItemImg/Effect").gameObject:SetActive(state)
        -- end
        if v.effect ~= nil then
            v.effect:SetActive(state)
        end
    end
end

NewRechargeItem = NewRechargeItem or BaseClass()

function NewRechargeItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.effect = nil

    local t = gameObject.transform
    self.diaImg = t:Find("Bg/Icon"):GetComponent(Image)   --左下角钻石图标
    self.title = t:Find("Title/Times"):GetComponent(Text)  --充值x元
    self.delayTime = t:Find("DoTimes"):GetComponent(Text)
    self.cNum = t:Find("CNum"):GetComponent(Text)
    self.itemIcon = t:Find("Icon")
end

function NewRechargeItem:SetData(data, index)
    self.data = data
    local luckyProgress = {data.reward_can, data.reward_max}
    local basedata = DataCampaign.data_list[data.id]
    self.title.text = basedata.cond_desc
    local reward_data = basedata.reward[1]
    --BaseUtils.dump(reward_data,"rrrrrrrrr")
    local Querdata = DataItem.data_get[reward_data[1]]
    if self.itemData == nil then
        self.itemData = ItemData.New()
        self.slot = ItemSlot.New()
        NumberpadPanel.AddUIChild(self.itemIcon, self.slot.gameObject)
    end
    self.itemData:SetBase(Querdata)
    self.slot:SetAll(self.itemData, {inbag = false, nobutton = true, noselect = true})
    self.slot:ShowBg(false)
    self.slot:SetItemImgSize(50,50)
    self.delayTime.text = string.format(TI18N("剩<color='#ffff00'> %d </color>次"), data.reward_can)
    self.diaImg.sprite = self.assetWrapper:GetSprite(AssetConfig.shop_textures, "Excharge"..index)
    if index < 4 then
        self.diaImg.transform.sizeDelta = Vector2(90,80)
    end
    self.cNum.text = TI18N("X"..reward_data[2])
    
end

function NewRechargeItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function NewRechargeItem:__delete()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
end
