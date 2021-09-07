TreasureMazeRewardPanel = TreasureMazeRewardPanel or BaseClass(BasePanel)

function TreasureMazeRewardPanel:__init(model)
    self.model = model
    self.name = "TreasureMazeRewardPanel"
    self.Effect = "prefabs/effect/20297.unity3d"
    self.resList = {
        {file = AssetConfig.treasuremazerewardpanel, type = AssetType.Main}
        ,{file = self.Effect, type = AssetType.Main}
        ,{file = AssetConfig.treasuremazetexture, type = AssetType.Dep}
        ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
        ,{file  =  AssetConfig.effectbg, type  =  AssetType.Dep}
    }
    self.slotlist = {}

end

function TreasureMazeRewardPanel:OnInitCompleted()

end

function TreasureMazeRewardPanel:__delete()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    if self.rotateID ~= nil then
        Tween.Instance:Cancel(self.rotateID.id)
        self.rotateID = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function TreasureMazeRewardPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.treasuremazerewardpanel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "TreasureMazeRewardPanel"
    self.transform = self.gameObject.transform
    self.transform:SetAsFirstSibling()

    self.TitleCon = self.transform:Find("MainCon/TitleCon")
    self.effectObj = GameObject.Instantiate(self:GetPrefab(self.Effect))
    self.effectObj.transform:SetParent(self.TitleCon)
    self.effectObj.transform.localScale = Vector3(1, 1, 1)
    self.effectObj.transform.localPosition = Vector3(0, 0, -400)
    Utils.ChangeLayersRecursively(self.effectObj.transform, "UI")
    self.effectObj:SetActive(true)
    self.NameText = self.transform:Find("MainCon/ItemCon/NameText"):GetComponent(Text)
    -- self.transform:Find("Panel"):GetComponent(Button):GetComponent(Button).onClick:AddListener(function() self.model:ClosePanel() end)
    self.transform:Find("MainCon/ItemCon/effect"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.effectbg, "EffectBg")
    if self.rotateID == nil then
        self.rotateID = Tween.Instance:RotateZ(self.transform:Find("MainCon/ItemCon/effect").gameObject, -720, 30, function() end):setLoopClamp()
    end
    self.baseName = self.transform:Find("MainCon/ItemCon/NameText").gameObject
    self.baseName:SetActive(false)
    self.transform:Find("MainCon/ItemCon/slotbg").gameObject:SetActive(false)
    self.itemCon = self.transform:Find("MainCon/ItemCon")
    -- self:CreatSlot(self.openArgs[1], self.itemCon)
    self.itemicon = {}
    self.item_name = {}
    for i,v in ipairs(self.openArgs) do
        local itemslot, namego = self:CreatSlot(v, self.itemCon)
        table.insert(self.itemicon, itemslot)
        table.insert(self.item_name, namego)
    end

    local X = -1
    if #self.itemicon%2 == 0 then
        X = -0.5
        for i,v in ipairs(self.itemicon) do
            local nameobj = self.item_name[i]
            v:SetActive(true)
            nameobj:SetActive(true)
            v.transform.anchoredPosition = Vector2((math.ceil(i/2)*2-1)*74*X, 0)
            nameobj.transform.anchoredPosition3D = Vector2((math.ceil(i/2)*2-1)*74*X, 50, 0)
            X = X*-1
        end
    else
        for i,v in ipairs(self.itemicon) do
            v:SetActive(true)
            v.transform.anchoredPosition = Vector2(math.floor(i/2)*74*X, 0)
            local nameobj = self.item_name[i]
            nameobj:SetActive(true)
            nameobj.transform.anchoredPosition3D = Vector3(math.floor(i/2)*74*X, 50, 0)
            X = X*-1
        end
    end

    self.transform:Find("MainCon/ImgConfirmBtn"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseRewardPanel()
        TreasureMazeManager.Instance:Send18811()
    end)

end


function TreasureMazeRewardPanel:CreatSlot(data, parent)
    local slot = ItemSlot.New()
    local info = ItemData.New()
    local base = DataItem.data_get[data.id]
    local namego = GameObject.Instantiate(self.baseName)
    namego.transform:SetParent(parent)
    namego.transform.localScale = Vector3.one
    namego.transform.anchoredPosition3D = Vector3(0, 50, 0)
    if base == nil then
        Log.Error("道具id配错():[baseid:" .. tostring(data.id) .. "]")
    end
    namego.transform:GetComponent(Text).text = ColorHelper.color_item_name(base.quality, base.name)
    info:SetBase(base)
    info.quantity = data.num
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
    table.insert(self.slotlist, slot)

    return slot.gameObject, namego
end