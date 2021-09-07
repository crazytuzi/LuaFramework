-- ----------------------------
-- 春节活动 主界面
-- hosr
-- ----------------------------
QingMingFestivalPanel = QingMingFestivalPanel or BaseClass(BasePanel)

function QingMingFestivalPanel:__init(main)
    self.main = main
    self.path = "prefabs/ui/springfestival/springfestivalpanel.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
    }

    self.OnHideEvent:Add(function() self:OnHide() end)
    self.OnOpenEvent:Add(function() self:OnShow() end)

    self.growplants = nil
    self.plantssprite = nil
    self.buybuy = nil
    self.killrober = nil
    self.totlelogin = nil

    self.currentPanel = nil
    self.currentIndex = 0

    self.checkRedPointListener = function() self:CheckRedPoint() end
end

function QingMingFestivalPanel:RemoveListener()
    BibleManager.Instance.onUpdateRedPoint:RemoveListener(self.checkRedPointListener)
end

function QingMingFestivalPanel:__delete()
    self.OnHideEvent:Fire()

    if self.growplants ~= nil then
        self.growplants:DeleteMe()
        self.growplants = nil
    end

    if self.plantssprite ~= nil then
        self.plantssprite:DeleteMe()
        self.plantssprite = nil
    end

    if self.buybuy ~= nil then
        self.buybuy:DeleteMe()
        self.buybuy = nil
    end

    if self.killrober ~= nil then
        self.killrober:DeleteMe()
        self.killrober = nil
    end

    if self.totlelogin ~= nil then
        self.totlelogin:DeleteMe()
        self.totlelogin = nil
    end

    if self.tree ~= nil then
        self.tree:DeleteMe()
        self.tree = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function QingMingFestivalPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "QingMingFestivalPanel"
    UIUtils.AddUIChild(self.main.mainContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.leftContainer = self.transform:Find("Main/Left/Container").gameObject
    self.baseItem = self.transform:Find("Main/Left/BaseItem").gameObject

    self.rightContainer = self.transform:Find("Main/Right").gameObject
    self.rightTransform = self.rightContainer.transform
end

function QingMingFestivalPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function QingMingFestivalPanel:InitLeft()
    local dataList = {}
    for k,v in pairs(DataCampaign.data_list) do
        if tonumber(v.iconid) == CampaignManager.Instance.currentFestival then
            if dataList[v.index] == nil then
                dataList[v.index] = {}
            end
            table.insert(dataList[v.index], v)
        end
        -- if tonumber(v.iconid) == CampaignEumn.Type.SpringFestival then
        --     if dataList[v.index] == nil then
        --         dataList[v.index] = {}
        --     end
        --     table.insert(dataList[v.index], v)
        -- end
    end

    local temp = {}
    for type,v in pairs(dataList) do
        table.sort(v, function(a,b) return a.group_index < b.group_index end)
        local main = {label = "", height = 60, subs = {}, type = type, sprite = self.assetWrapper:GetSprite(AssetConfig.springfestival_texture, string.format("SpringIcon%s", 2))}
        -- if type == SpringFestivalEumn.Type.growplants then
        --     for i,campaignData in ipairs(v) do
        --         local index = i
        --         table.insert(main.subs, {label = SpringFestivalEumn.growplantsSubName[i], height = 45, callbackData = {type = type, index = index}, data = campaignData})
        --         if main.label == "" then
        --             main.label = campaignData.reward_title
        --         end
        --     end
        -- else
        --     main.datas = v
        --     main.label = v[1].reward_title
        -- end
        main.datas = v
        main.label = v[1].reward_title
        table.insert(temp, main)
    end
    table.sort(temp, function(a,b) return a.type < b.type end)
    self.dataList = temp
    self.tree:SetData(temp)
end

function QingMingFestivalPanel:OnShow()
    if self.tree == nil then
        self.tree = TreeButton.New(self.leftContainer, self.baseItem, function(data) self:ClickSub(data) end, function(index) self:TabChange(index) end)
        self.tree.canRepeat = false
        self:InitLeft()
    end
    local index = BibleManager.Instance.model.currentSub
    local subIndex = BibleManager.Instance.model.currentTab
    -- self.tree:ClickMain(index)
    print(index.."_"..subIndex)
    self.tree:ClickMain(index, subIndex)

    self:RemoveListener()
    BibleManager.Instance.onUpdateRedPoint:AddListener(self.checkRedPointListener)

    BibleManager.Instance.onUpdateRedPoint:Fire()
end

function QingMingFestivalPanel:OnHide()
    self:RemoveListener()
end

function QingMingFestivalPanel:GetCampaignData(type, index)
    if index == nil then
        return self.dataList[type].datas
    end
    return self.dataList[type].subs[index].data
end

function QingMingFestivalPanel:ClickSub(data)
    local type = data.type
    local index = data.index
    -- if type == SpringFestivalEumn.Type.growplants then
    --     if self.growplants == nil then
    --         self.growplants = growplants.New(self)
    --     end
    --     self.growplants:Show(index)
    -- end
end

function QingMingFestivalPanel:TabChange(index)
    if self.currentPanel ~= nil and self.currentIndex ~= index then
        self.currentPanel:Hiden()
    end
    self.currentIndex = index
    -- if index == SpringFestivalEumn.Type.growplants then
    --     if self.growplants == nil then
    --         self.growplants = growplants.New(self)
    --     end
    --     local openIndex = 1
    --     if BibleManager.Instance.model.openArgs ~= nil and BibleManager.Instance.model.openArgs[3] ~= nil then
    --         openIndex = BibleManager.Instance.model.openArgs[3]
    --     end
    --     self.growplants:Show(openIndex)
    --     self.currentPanel = self.growplants
    -- elseif index == SpringFestivalEumn.Type.BuyBuy then
    --     if self.buybuy == nil then
    --         self.buybuy = BuyBuy.New(self)
    --     end
    --     self.buybuy:Show()
    --     self.currentPanel = self.buybuy
    -- elseif index == SpringFestivalEumn.Type.plantssprite then
    --     if self.plantssprite == nil then
    --         self.plantssprite = plantssprite.New(self)
    --     end
    --     self.plantssprite:Show()
    --     self.currentPanel = self.plantssprite
    -- elseif index == SpringFestivalEumn.Type.killrober then
    --     if self.killrober == nil then
    --         self.killrober = killrober.New(self)
    --     end
    --     self.killrober:Show()
    --     self.currentPanel = self.killrober
    -- end
    if self.buybuy == nil then
        self.buybuy = BuyBuy.New(self)
    end
    self.buybuy:Show()
    self.currentPanel = self.buybuy
end

function QingMingFestivalPanel:CheckRedPoint()
    for index, bool in pairs(BibleManager.Instance.redPointDic[4]) do
        self.tree:RedMain(index, bool)
    end
end
