--作者:hzf
--02/28/2017 19:31:39
--功能:珍宝迷城事件

TreasureMazeMosterPanel = TreasureMazeMosterPanel or BaseClass(BasePanel)
function TreasureMazeMosterPanel:__init(model)
    self.model = model
    self.Mgr = TreasureMazeManager.Instance
    self.mosterEffect = "prefabs/effect/20281.unity3d"
    self.resList = {
        {file = AssetConfig.mazemosterpanel, type = AssetType.Main},
        {file = self.mosterEffect, type = AssetType.Main},
    }
    --self.OnOpenEvent:Add(function() self:OnOpen() end)
    --self.OnHideEvent:Add(function() self:OnHide() end)
    self.hasInit = false
    self.slotlist = {}
end

function TreasureMazeMosterPanel:__delete()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    if self.previewCom ~= nil then
        self.previewCom:DeleteMe()
        self.previewCom = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function TreasureMazeMosterPanel:OnHide()

end

function TreasureMazeMosterPanel:OnOpen()

end

function TreasureMazeMosterPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mazemosterpanel))
    self.gameObject.name = "TreasureMazeMosterPanel"
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:SetAsFirstSibling()

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseMosterPanel()
    end)
    self.MainCon = self.transform:Find("MainCon")
    self.EffectCon = self.transform:Find("MainCon/Effect")
    self.bg = self.transform:Find("MainCon/bg")
    self.Title = self.transform:Find("MainCon/Title")
    self.TitleText = self.transform:Find("MainCon/Title/Text"):GetComponent(Text)
    self.CancelButton = self.transform:Find("MainCon/CancelButton"):GetComponent(Button)
    self.CancelButton.gameObject:SetActive(true)
    self.CancelButton.onClick:AddListener(function()
        self:OnCancel()
    end)
    self.CancelButtonText = self.transform:Find("MainCon/CancelButton/Text"):GetComponent(Text)
    self.OkButton = self.transform:Find("MainCon/OkButton"):GetComponent(Button)
    self.OkButton.gameObject:SetActive(true)
    self.OkButton.onClick:AddListener(function()
        self:OnOk()
    end)

    self.mosterObj = GameObject.Instantiate(self:GetPrefab(self.mosterEffect))
    self.mosterObj.transform:SetParent(self.EffectCon)
    self.mosterObj.transform.localScale = Vector3(1, 1, 1)
    self.mosterObj.transform.localPosition = Vector3(0, 15, -300)
    Utils.ChangeLayersRecursively(self.mosterObj.transform, "UI")
    self.mosterObj:SetActive(true)
    -- self.transform:Find("MainCon/CancelButton/icon"):GetComponent(Image)
    if self.iconLoader == nil then
        self.iconLoader = SingleIconLoader.New(self.transform:Find("MainCon/CancelButton/icon").gameObject)
    end
    self.iconLoader:SetSprite(SingleIconType.Item, 21220)
    self.OkButtonText = self.transform:Find("MainCon/OkButton/Text"):GetComponent(Text)
    self.Slotbg = self.transform:Find("MainCon/Slotbg")
    -- self.Slot = self.transform:Find("MainCon/Slotbg/Slot")
    self.SlotItem = self.transform:Find("MainCon/Slotbg/SlotItem").gameObject
    self.SlotItem:SetActive(false)
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseMosterPanel()
    end)

    self.data = self.openArgs
    self:LoadData()
end


function TreasureMazeMosterPanel:OnOk()
    TreasureMazeManager.Instance:Send18806(self.data.x, self.data.y)
    self.model:CloseMosterPanel()
end

function TreasureMazeMosterPanel:OnCancel()
    TreasureMazeManager.Instance:Send18816(self.data.x, self.data.y)
    self.model:CloseMosterPanel()
end

function TreasureMazeMosterPanel:LoadData()
    BaseUtils.dump(self.data, "数据")
    self.data.reward = {
        {base_id = 90010, num = self.data.exp, bind = 1},
        {base_id = 90005, num = self.data.pet_exp, bind = 1},
        -- {base_id = 90005, num = 234209, bind = 1},
    }
    local num = #self.data.reward
    if num%2 == 0 then
        for i=1,num do
            local slotCon = GameObject.Instantiate(self.SlotItem)
            slotCon.transform:SetParent(self.Slotbg)
            slotCon.transform.localScale = Vector3.one
            local x = Mathf.Pow(-1, i)*(50+math.floor((i-1)/2)*100)
            print(math.floor(i-1/2))
            slotCon.transform.anchoredPosition3D = Vector3(x, 0, 0)
            self:CreatSlot(self.data.reward[i], slotCon.transform:Find("Slot"), slotCon.transform:Find("NameText"):GetComponent(Text))
            slotCon:SetActive(true)
        end
    else
        for i=1,num do
            local slotCon = GameObject.Instantiate(self.SlotItem)
            slotCon.transform:SetParent(self.Slotbg)
            slotCon.transform.localScale = Vector3.one
            local x = math.floor(i/2)*Mathf.Pow(-1, i+1)*100
            slotCon.transform.anchoredPosition3D = Vector3(x, 0, 0)
            self:CreatSlot(self.data.reward[i], slotCon.transform:Find("Slot"), slotCon.transform:Find("NameText"):GetComponent(Text))
            slotCon:SetActive(true)
        end
    end
end



function TreasureMazeMosterPanel:LoadPreview(base_id)
    local unit_data = DataUnit.data_unit[base_id]
    local setting = {
        name = "TreasureMazeMosterPanel"
        ,orthographicSize = 0.4
        ,width = 256
        ,height = 256
        ,offsetY = -0.4
    }
    if base_id == 73060 then
        setting = {
            name = "TreasureMazeMosterPanel"
            ,orthographicSize = 0.65
            ,width = 256
            ,height = 256
            ,offsetY = -0.4
        }
    end
    local modelData = {type = PreViewType.Npc, skinId = unit_data.skin, modelId = unit_data.res, animationId = unit_data.animation_id, scale = 1}
    self.preview_loaded = function(com)
        self:PreviewLoaded(com)
    end
    if self.previewCom == nil then
        self.previewCom = PreviewComposite.New(self.preview_loaded, setting, modelData)

        -- 有缓存的窗口要写这个
        -- self.OnHideEvent:AddListener(function() self.previewCom:Hide() end)
        -- self.OnOpenEvent:AddListener(function() self.previewCom:Show() end)
    else
        if self.previewCom.modelData.modelId == modelData.modelId and self.previewCom.modelData.skinId == modelData.skinId then
            return
        else
            self.previewCom:Reload(modelData, self.preview_loaded)
        end
    end

end


function TreasureMazeMosterPanel:PreviewLoaded(composite)
    local rawImage = composite.rawImage
    if rawImage ~= nil then
        self.rawImage = rawImage
        rawImage.transform:SetParent(self.transform)
        rawImage.transform.anchoredPosition = Vector3(-289, -121, 0)
        local canvasG = self.rawImage.transform:GetComponent(CanvasGroup) or self.rawImage.transform.gameObject:AddComponent(CanvasGroup)
        canvasG.blocksRaycasts = false
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, 315, 0))
        -- self.preview.texture = rawImage.texture
    end
end


function TreasureMazeMosterPanel:CreatSlot(data, parent, TextCom)
    local slot = ItemSlot.New()
    local info = ItemData.New()
    local base = DataItem.data_get[data.base_id]
    if base == nil then
        Log.Error("道具id配错():[baseid:" .. tostring(data.base_id) .. "]")
    end
    if TextCom then
        TextCom.text = ColorHelper.color_item_name(base.quality, base.name)
    end
    info:SetBase(base)
    info.quantity = data.num
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    table.insert(self.slotlist, slot)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
end