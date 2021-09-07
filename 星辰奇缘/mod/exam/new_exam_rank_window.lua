NewExamRankWindow  =  NewExamRankWindow or BaseClass(BasePanel)

function NewExamRankWindow:__init(model)
    self.name  =  "NewExamRankWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.newexamrankwindow, type  =  AssetType.Main}
        , {file = AssetConfig.exam_res, type = AssetType.Dep}
        , {file = AssetConfig.rolebgnew, type = AssetType.Dep}
        , {file = AssetConfig.rolebgstand, type = AssetType.Dep}
        , {file = AssetConfig.rank_textures, type = AssetType.Dep}
    }

    self.itemList = {}
    self.itemsoltList = {}
    self.itemSolt = nil
    ------------------------------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function NewExamRankWindow:OnHide()
end

function NewExamRankWindow:OnShow()
    self:Update()
end

function NewExamRankWindow:__delete()
    for k,v in pairs(self.itemsoltList) do
        v:DeleteMe()
        v = nil
    end
    if self.itemSolt ~= nil then
        self.itemSolt:DeleteMe()
        self.itemSolt = nil
    end

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function NewExamRankWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.newexamrankwindow))
    self.gameObject.name = "NewExamRankWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    self.closeButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeButton.onClick:AddListener(function() self:OnClose() end)

    self.transform:Find("Main/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
    self.transform:Find("Main/Bg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgstand, "RoleStandBottom")

    self.preview = self.transform:Find("Main/Preview").gameObject

    self.descText = self.transform:Find("Main/DescPanel/DescText"):GetComponent(Text)
    self.titleText = self.transform:Find("Main/NameTitle/NameText"):GetComponent(Text)
    self.nameText = self.transform:Find("Main/Text2"):GetComponent(Text)

    self.myRankItem = self.transform:Find("Main/MyRankItem")

    self.rankPanel = self.transform:Find("Main/Mask/RankPanel")
    self.rankItemClone = self.transform:Find("Main/Mask/RankPanel/RankItem").gameObject
    self.rankItemClone:SetActive(false)

    self:Update()
end

function NewExamRankWindow:OnClose()
    -- WindowManager.Instance:CloseWindow(self)
    self.model:CloseNewExamRank()
end

function NewExamRankWindow:Update()
    local randNum = #self.model.rank_list
    if randNum > 20 then
        randNum = 20
    end
    for i = 1, randNum do
        local item = self.itemList[i]
        if item == nil then
            item = GameObject.Instantiate(self.rankItemClone)
            item:SetActive(true)
            item.transform:SetParent(self.rankPanel)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
        end
        
        self:UpdateItem(item, self.model.rank_list[i], i)
    end

    local honorData = DataHonor.data_get_honor_list[11115]
    self.titleText.text = string.format("<color='#ff00ff'>%s</color>", honorData.name)
    self.descText.text = honorData.cond_desc
    self.nameText.text = string.format("<color='#ffff00'>%s</color>", self.model.rank_list[1].name)

    self:UpdatePreview()

    self.myRankItem:Find("NameText"):GetComponent(Text).text = string.format("<color='#ffff00'>%s</color>", RoleManager.Instance.RoleData.name)
    if self.model.myQuestionData ~= nil then
        self.myRankItem:Find("StarText"):GetComponent(Text).text = string.format("<color='#ffff00'>%s</color>", self.model.myQuestionData.score)
    end

    local myRank = self.model.self_rank
    if myRank > 3 then
        self.myRankItem:Find("RankImage").gameObject:SetActive(false)
        self.myRankItem:Find("RankText").gameObject:SetActive(true)
        self.myRankItem:Find("RankText"):GetComponent(Text).text = tostring(myRank)
    elseif myRank > 0 then
        self.myRankItem:Find("RankImage").gameObject:SetActive(true)
        self.myRankItem:Find("RankText").gameObject:SetActive(false)
        self.myRankItem:Find("RankImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_" .. myRank)
    else
        self.myRankItem:Find("RankImage").gameObject:SetActive(false)
        self.myRankItem:Find("RankText").gameObject:SetActive(true)
        self.myRankItem:Find("RankText"):GetComponent(Text).text = TI18N("未上榜")
    end

    local item_list_client = nil
    for k,v in pairs(DataQuestionMatch.data_rank_reward) do
        if myRank >= v.min_rank and myRank < v.max_rank then
            item_list_client = v.item_list_client
        end
    end

    if item_list_client ~= nil then
        local itemSolt = ItemSlot.New()
        UIUtils.AddUIChild(self.myRankItem.transform:Find("Item").gameObject, itemSolt.gameObject)
        local itembase = BackpackManager.Instance:GetItemBase(item_list_client[1][1])
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        itemData.quantity = item_list_client[1][2]
        itemSolt:SetAll(itemData)

        self.itemSolt = itemSolt
    end
end

function NewExamRankWindow:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "NewExamRankWindow"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 341
        ,offsetY = -0.3
    }
    local winnerData = self.model.rank_list[1]
    local modelData = {type = PreViewType.Role, classes = winnerData.classes, sex = winnerData.sex, looks = winnerData.looks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function NewExamRankWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
end

function NewExamRankWindow:UpdateItem(item, data, index)
    if index % 2 == 1 then
        item:GetComponent(Image).enabled = false
    else
        item:GetComponent(Image).enabled = true
    end

    item.transform:Find("NameText"):GetComponent(Text).text = data.name
    item.transform:Find("StarText"):GetComponent(Text).text = data.score
    if index > 3 then
        item.transform:Find("RankImage").gameObject:SetActive(false)
        item.transform:Find("RankText").gameObject:SetActive(true)
        item.transform:Find("RankText"):GetComponent(Text).text = tostring(index)
    else
        item.transform:Find("RankImage").gameObject:SetActive(true)
        item.transform:Find("RankText").gameObject:SetActive(false)
        item.transform:Find("RankImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_" .. index)
    end

    local item_list_client = nil
    for k,v in pairs(DataQuestionMatch.data_rank_reward) do
        if index >= v.min_rank and index <= v.max_rank then
            item_list_client = v.item_list_client
        end
    end

    if item_list_client ~= nil and item_list_client[1] ~= nil then
        local itemSolt = ItemSlot.New()
        UIUtils.AddUIChild(item.transform:Find("Item").gameObject, itemSolt.gameObject)
        item.transform:Find("Item").localScale = Vector3(0.72, 0.72, 0.72)
        local itembase = BackpackManager.Instance:GetItemBase(item_list_client[1][1])
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        itemData.quantity = item_list_client[1][2]
        itemSolt:SetAll(itemData)

        self.itemsoltList[index] = itemSolt
    end
end