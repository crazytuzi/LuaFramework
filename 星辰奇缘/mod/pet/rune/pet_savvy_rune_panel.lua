-- @author hze
-- @date #2019/05/15#
-- @宠物内丹领悟界面

PetSavvyRunePanel = PetSavvyRunePanel or BaseClass(BasePanel)

function PetSavvyRunePanel:__init(model)
    self.resList = {
        {file = AssetConfig.petsavvyrunepanel, type = AssetType.Main},
        {file = AssetConfig.mainui_textures, type = Dep},
    }

    self.model = model
    self.name = "PetSavvyRunePanel"

    self.itemList = {}

    local cost1 = DataRune.data_savvy[1].cost[1]
    local cost2 = DataRune.data_savvy[2].cost[1]

    self.dataList = {
        {id = cost1[1], icon = DataItem.data_get[cost1[1]].icon, needTxt = string.format(TI18N("%s*%s"),DataItem.data_get[cost1[1]].name, cost1[2]), btn_call = function() PetManager.Instance:Send10576(self.data.pet_id, self.data.rune_index, 1) end}
        ,{id = cost2[1], icon = DataItem.data_get[cost2[1]].icon, needTxt = string.format(TI18N("%s*%s"),DataItem.data_get[cost2[1]].name, cost2[2]), btn_call = function() PetManager.Instance:Send10576(self.data.pet_id, self.data.rune_index, 2) end}
        ,{id = 0, icon = "I18NAgenda", needTxt = TI18N("日常战斗"), btn_call = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.agendamain) self.model:ClosePetSavvyRunePanel() end}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

end

function PetSavvyRunePanel:__delete()
    self.OnHideEvent:Fire()

    if self.showIconLoader ~= nil then
        self.showIconLoader:DeleteMe()
    end
end

function PetSavvyRunePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petsavvyrunepanel))
    if self.model.window ~= nil and not BaseUtils.isnull(self.model.window.gameObject) then
        UIUtils.AddUIChild(self.model.window.gameObject, self.gameObject)
    else
        UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    end
    
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    self.transform:GetComponent(RectTransform).localPosition = Vector3(0,0,-500)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:ClosePetSavvyRunePanel() end)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:ClosePetSavvyRunePanel() end)
    -- self.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.PetSavvyRunePanel_bg, "PetSavvyRunePanelBg")

    local top = self.transform:Find("Main/Top")
    self.runeItem = top:Find("RuneItem")

    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.runeItem:Find("IconBg").gameObject, self.itemSlot.gameObject)

    self.showNameText = self.runeItem:Find("NameText"):GetComponent(Text)

    self.container = self.transform:Find("Main/HeadChildBar/HeadContainer")
    for i = 1 ,3 do
        self.itemList[i] = self:CreateItem(self.container:Find(string.format("Item%s",i)))
    end
end

function PetSavvyRunePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PetSavvyRunePanel:OnOpen()
    self:RemoveListeners()
    if self.openArgs == nil then return end
    self.data = self.openArgs

    -- BaseUtils.dump(self.data)

    local runedata = DataRune.data_rune[BaseUtils.Key(self.data.rune_id, self.data.rune_lev or "1")]

    local item_data = ItemData.New()
    item_data:SetBase(DataItem.data_get[self.data.rune_id])
    self.itemSlot:SetAll(item_data,{nobutton = true})

    self.showNameText.text = string.format(TI18N("%s(%s级)"), runedata.name, runedata.lev)

    self:Update()
end

function PetSavvyRunePanel:OnHide()
    self:RemoveListeners()
end

function PetSavvyRunePanel:RemoveListeners()
end

function PetSavvyRunePanel:Update()
    for k, v in ipairs(self.dataList) do
        local item = self.itemList[k]
        self:SetItemData(item, v)
    end
end

function PetSavvyRunePanel:CreateItem(transform)
    local item = {}
    item["trans"] = transfrorm
    item["btn"] = transform:Find("Button"):GetComponent(Button)
    item["iconImg"] = transform:Find("IconBg/Icon"):GetComponent(Image)
    item["loader"] = SingleIconLoader.New(item.iconImg.gameObject)
    item["needTxt"] = transform:Find("NeedText"):GetComponent(Text)
    item["iconBtn"] = transform:Find("IconBg"):GetComponent(Button)
    return item
end 

function PetSavvyRunePanel:SetItemData(item, data)
    local sprite = self.assetWrapper:GetSprite(AssetConfig.mainui_textures, data.icon)
    if sprite ~= nil then 
        item.loader:SetOtherSprite(sprite)
    else    
        item.loader:SetSprite(SingleIconType.Item, data.icon)
    end
    
    item.needTxt.text = data.needTxt
    item.btn.onClick:RemoveAllListeners()
    item.btn.onClick:AddListener(data.btn_call)

    if data.id ~= 0 then 
        item.iconBtn.onClick:RemoveAllListeners()
        item.iconBtn.onClick:AddListener(function()
                local itemdata = ItemData.New()
                itemdata:SetBase(BackpackManager.Instance:GetItemBase(data.id))
                TipsManager.Instance:ShowItem({["gameObject"] = item.iconImg.gameObject, ["itemData"] = itemdata})
            end
        )
    end

end 
