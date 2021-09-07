OpenServerLuckyPanel = OpenServerLuckyPanel or BaseClass(BasePanel)

function OpenServerLuckyPanel:__init(model, parent, subList)
    self.model = model
    self.parent = parent
    self.subList = subList
    self.mgr = OpenServerManager.Instance

    self.resList = {
        {file = AssetConfig.open_server_lucky, type = AssetType.Main}
        , {file = AssetConfig.open_server_textures, type = AssetType.Dep}
        , {file = AssetConfig.open_server_luckymoney1, type = AssetType.Dep}
        , {file = AssetConfig.open_server_luckymoney2, type = AssetType.Dep}
        , {file = AssetConfig.open_server_luckymoney3, type = AssetType.Dep}
        , {file = AssetConfig.rolebgnew, type = AssetType.Dep}
    }
    self.luckyList = {}

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.updateListener = function() self:Reload() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function OpenServerLuckyPanel:__delete()
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
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerLuckyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_lucky))
    self.gameObject.name = "OpenServerLuckyPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    local t = self.transform

    t:Find("DescArea/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")

    self.titleText = t:Find("DescArea/TitleI18N"):GetComponent(Text)
    self.timeText = t:Find("DescArea/TimeBg/Text"):GetComponent(Text)
    self.cloner = t:Find("MaskLayer/ScrollLayer/Cloner").gameObject
    self.cloner:SetActive(false)
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
    for i,v in ipairs(self.subList) do
        if self.luckyList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            self.layout:AddCell(obj)
            -- self.luckyList[i] = LuckyItem.New(self.model, obj, GameObject.Instantiate(self:GetPrefab(AssetConfig["open_server_luckymoney" .. i])))
            self.luckyList[i] = LuckyItem.New(self.model, obj, self.assetWrapper:GetSprite(AssetConfig["open_server_luckymoney" .. i], "I18NLuckyMoney" .. i), i == 3)
        end
        self.luckyList[i]:SetData(v,i)
    end

    self.quickRechargeBtn.onClick:AddListener(function() self:OnQuickRecharge() end)

    local openTime = CampaignManager.Instance.open_srv_time
    local hour = tonumber(os.date("%H",openTime))*3600
    hour = hour + tonumber(os.date("%M",openTime))*60
    hour = hour + tonumber(os.date("%S",openTime))
    local basedata = DataCampaign.data_list[self.subList[1].id]
    local cli_start_time = basedata.cli_start_time[1]
    local cli_end_time = basedata.cli_end_time[1]
    local beginTime = openTime - hour + cli_start_time[2] * 86400 + cli_start_time[3]
    local endTime = openTime - hour + cli_end_time[2] * 86400 + cli_end_time[3]
    local startMouth = tonumber(os.date("%m", beginTime))
    local startDay = tonumber(os.date("%d", beginTime))
    local endMouth = tonumber(os.date("%m", endTime))
    local endDay = tonumber(os.date("%d", endTime))
    self.timeText.text = string.format(TI18N("活动时间:%s月%s日-%s月%s日"), tostring(startMouth), tostring(startDay), tostring(endMouth), tostring(endDay))

    self.attentionText.text = basedata.content
    self.effect = BibleRewardPanel.ShowEffect(20118, self.quickRechargeBtn.gameObject.transform, Vector3(1.1, 0.8,1), Vector3(-114.7,22.8,-100))

    self.OnOpenEvent:Fire()
end

function OpenServerLuckyPanel:OnQuickRecharge()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3,1})
end

function OpenServerLuckyPanel:OnOpen()
    self:Reload()

    self:RemoveListeners()
    self.mgr.onUpdateLucky:AddListener(self.updateListener)
end

function OpenServerLuckyPanel:Reload()
    for i,v in ipairs(self.subList) do
        local basedata = DataCampaign.data_list[v.id]
        if self.luckyList[i] == nil then
            obj = GameObject.Instantiate(self.cloner)
            obj.name = tostring(i)
            self.layout:AddCell(obj)
            self.luckyList[i] = LuckyItem.New(self.model, obj, self.assetWrapper, i == 3)
        end
        self.luckyList[i]:SetData(basedata, i)
    end
end

function OpenServerLuckyPanel:OnHide()
    self:RemoveListeners()
end

function OpenServerLuckyPanel:RemoveListeners()
    self.mgr.onUpdateLucky:RemoveListener(self.updateListener)
end

