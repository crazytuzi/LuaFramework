OpenServerRewardPanel = OpenServerRewardPanel or BaseClass(BasePanel)

function OpenServerRewardPanel:__init(model)
    self.model = model
    self.name = "OpenServerRewardPanel"
    self.Effect = "prefabs/effect/20298.unity3d"
    self.resList = {
        {file = AssetConfig.treasuremazerewardpanel, type = AssetType.Main}
        ,{file = self.Effect, type = AssetType.Main}
        ,{file = AssetConfig.treasuremazetexture, type = AssetType.Dep}
        ,{file = AssetConfig.open_server_textures, type = AssetType.Dep}
        ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
        ,{file  =  AssetConfig.effectbg, type  =  AssetType.Dep}
    }

    self.slot = nil


end

function OpenServerRewardPanel:OnInitCompleted()

end

function OpenServerRewardPanel:__delete()
    if self.rotateID ~= nil then
        Tween.Instance:Cancel(self.rotateID.id)
        self.rotateID = nil
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
    self:AssetClearAll()
end

function OpenServerRewardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.treasuremazerewardpanel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "OpenServerRewardPanel"
    self.transform = self.gameObject.transform

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
    self.itemCon = self.transform:Find("MainCon/ItemCon")
    self:CreatSlot(self.openArgs[1], self.itemCon)
    self.confirmBtnString = self.openArgs[2] or TI18N("确定")
    self.countTime = self.openArgs[3] or 3
    self.confirmText = self.transform:Find("MainCon/ImgConfirmBtn/Text"):GetComponent(Text)
    self.transform:Find("MainCon/ImgConfirmBtn"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseRewardPanel()
    end)

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 1000, function() self:OnTime() end)
    end
end


function OpenServerRewardPanel:CreatSlot(data, parent)
    local slot = ItemSlot.New()
    local info = ItemData.New()
    local base = DataItem.data_get[data.id]
    if base == nil then
        Log.Error("道具id配错():[baseid:" .. tostring(data.id) .. "]")
    end
    self.NameText.text = ColorHelper.color_item_name(base.quality, base.name)
    info:SetBase(base)
    info.quantity = data.num
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    self.slot = slot
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
end

function OpenServerRewardPanel:OnTime()
    if self.countTime <= 0 then
        self.model:CloseRewardPanel()
    else
        self.countTime = self.countTime - 1
        self.confirmText.text = self.confirmBtnString .. string.format("(%ss)", tostring(self.countTime))
    end
end
