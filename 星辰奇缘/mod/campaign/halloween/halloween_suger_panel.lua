HalloweenSugerPanel = HalloweenSugerPanel or BaseClass(BasePanel)

function HalloweenSugerPanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.mgr = OpenServerManager.Instance

    self.resList = {
        {file = AssetConfig.halloweensuger, type = AssetType.Main}
        , {file = AssetConfig.halloween_textures, type = AssetType.Dep}
        , {file = AssetConfig.halloween_i18n_bg2, type = AssetType.Main}
        , {file = AssetConfig.petpartyi18n, type = AssetType.Main}

    }
    self.luckyList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:Reload() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)

    self.protoData = CampaignManager.Instance.campaignTree[114][1]
end

function HalloweenSugerPanel:__delete()
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
    if self.tipsPanel ~= nil then
        self.tipsPanel:DeleteMe()
        self.tipsPanel = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HalloweenSugerPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweensuger))
    self.gameObject.name = "HalloweenSugerPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    self.timeText = t:Find("DescArea/Time"):GetComponent(Text)
    self.cloner = t:Find("MaskLayer/ScrollLayer/Cloner").gameObject
    self.container = t:Find("MaskLayer/ScrollLayer/Container")
    self.quickRechargeBtn = t:Find("CheckArea/Button"):GetComponent(Button)
    self.attentionText = t:Find("CheckArea/Attention/Text"):GetComponent(Text)

    local btn = self.cloner:GetComponent(Button)
    if btn == nil then
        self.cloner:AddComponent(Button)
    end
    
    self.cloner:SetActive(false)
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X})
    local obj = nil
    BaseUtils.dump(self.protoData,"self.protoData")
    for i,v in ipairs(self.protoData.sub) do
        if self.luckyList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            self.layout:AddCell(obj)
            self.luckyList[i] = HalloweenSugerItem.New(self.model, obj, self.assetWrapper, "Cake" .. i)
        end
        self.luckyList[i]:SetData(v,i)
    end

    self.quickRechargeBtn.onClick:AddListener(function() self:OnQuickRecharge() end)

    local basedata = DataCampaign.data_list[self.protoData.sub[1].id]
    local cli_start_time = basedata.cli_start_time[1]
    local cli_end_time = basedata.cli_end_time[1]
    self.timeText.text = string.format(TI18N("活动时间:%s月%s日-%s月%s日"), tostring(cli_start_time[2]), tostring(cli_start_time[3]), tostring(cli_end_time[2]), tostring(cli_end_time[3]))
    self.timeText.transform.anchoredPosition = Vector2(211, -121)

    self.attentionText.text = basedata.content
    self.effect = BibleRewardPanel.ShowEffect(20118, self.quickRechargeBtn.gameObject.transform, Vector3(1.1, 0.8,1), Vector3(-114.7,22.8,-100))
    UIUtils.AddBigbg(t:Find("DescArea/BigBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.petpartyi18n)))
    self.OnOpenEvent:Fire()
end

function HalloweenSugerPanel:OnQuickRecharge()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3,1})
end

function HalloweenSugerPanel:OnOpen()
    self:Reload()

    self:RemoveListeners()
    self.mgr.onUpdateLucky:AddListener(self.updateListener)
end

function HalloweenSugerPanel:Reload()
    self.protoData = CampaignManager.Instance.campaignTree[114][1]
    BaseUtils.dump(self.protoData,"self.protoData")
    for i,v in ipairs(self.protoData.sub) do
        if self.luckyList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            self.layout:AddCell(obj)
            self.luckyList[i] = HalloweenSugerItem.New(self.model, obj, self.assetWrapper)
        end
        self.luckyList[i]:SetData(v, i)
    end
end

function HalloweenSugerPanel:OnHide()
    self:RemoveListeners()
end

function HalloweenSugerPanel:RemoveListeners()
    self.mgr.onUpdateLucky:RemoveListener(self.updateListener)
end

HalloweenSugerItem = HalloweenSugerItem or BaseClass()

function HalloweenSugerItem:__init(model, gameObject, assetWrapper, res)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.effect = nil


    local t = gameObject.transform
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.descText = t:Find("Desc"):GetComponent(Text)
    self.timesText = t:Find("Times"):GetComponent(Text)
    self.luckyImage = t:Find("Image"):GetComponent(Image)
    self.luckyBtn = self.luckyImage:GetComponent(Button)
    self.btn = gameObject:GetComponent(Button)
end

function HalloweenSugerItem:SetData(data, index)
    self.data = data
    local luckyProgress = {data.reward_can, data.reward_max}
    local basedata = DataCampaign.data_list[data.id]
    self.nameText.text = basedata.conds
    self.descText.text = basedata.cond_desc
    self.timesText.text = TI18N("奖励次数:<color=#00FF00>")..tostring(luckyProgress[1]).."</color>/"..tostring(luckyProgress[2])
    self.luckyImage.transform.anchoredPosition = Vector2(0, -127)
    self.luckyImage.transform.pivot = Vector2(0.5,0)
    self.luckyImage.transform.sizeDelta = Vector2(100, 100)
    self.luckyImage.sprite = self.assetWrapper:GetSprite(AssetConfig.halloween_textures, "Cake" .. tostring(index))
    self.btn.onClick:RemoveAllListeners()
    self.btn.onClick:AddListener(function() self:ShowReward() end)
    self.luckyBtn.onClick:RemoveAllListeners()
    self.luckyBtn.onClick:AddListener(function() self:ShowReward() end)
    if index == 3 then
        if self.effect == nil then
            self.effect = BibleRewardPanel.ShowEffect(20195, self.luckyImage.gameObject.transform, Vector3(0.68, 0.65,1), Vector3(-5,59,-400))
        end
    end
end

function HalloweenSugerItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function HalloweenSugerItem:__delete()
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
end

function HalloweenSugerItem:ShowReward()
    if self.data == nil then return end

    local basedata = DataCampaign.data_list[self.data.id]
    --if self.model.window ~= nil then
        -- if self.model.giftPreview == nil then
        --     self.model.giftPreview = GiftPreview.New(self.model.mainWin.gameObject)
        -- end
        -- self.model.giftPreview:Show({reward = basedata.rewardgift, autoMain = true, text = TI18N("随机获得以下道具其中一个"), width = 120, height = 120})
    --end

    if self.tipsPanel == nil then
        self.tipsPanel = SevenLoginTipsPanel.New(self)
    end

    local rewardList = {}

    local roleData = RoleManager.Instance.RoleData

    for _,v in ipairs(basedata.rewardgift) do

        if #v == 7 then
            if (roleData.lev > v[1] or roleData.lev == v[1]) and (roleData.lev < v[2] or roleData.lev == v[2]) and (v[3] == 0 or v[3] == roleData.classes) and (v[4] == 2 or v[4] == roleData.sex) then
                table.insert(rewardList,{v[5],0,v[6],is_effet = v[7]})
            end
        else
            table.insert(rewardList,v)
        end
    end

    self.tipsPanel:Show({rewardList,5,nil,DataCampaign.data_list[self.data.id].cond_rew})
end
