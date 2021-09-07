-- ----------------------------------------
-- 背包扩展界面
-- hosr
-- ----------------------------------------

BackpackExpandPanel = BackpackExpandPanel or BaseClass(BasePanel)

function BackpackExpandPanel:__init()
    self.parent = parent
    self.resList = {
        {file = AssetConfig.backpack_expand, type =  AssetType.Main}
    }
    -- 是否足够
    self.enough = false
    self.baseData = nil
end

function BackpackExpandPanel:__delete()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
end

function BackpackExpandPanel:OnHide()
end

function BackpackExpandPanel:OnShow()
    self:SetData()
end

function BackpackExpandPanel:Close()
    BackpackManager.Instance.mainModel:CloseExpand()
end

function BackpackExpandPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpack_expand))
    self.gameObject.name = "BackpackExpandPanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    local main = self.transform:Find("Main")
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    main:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:Sure() end)
    self.desc = main:Find("Desc"):GetComponent(Text)
    self.desc.text = ""

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(main:Find("Slot").gameObject, self.slot.gameObject)

    self:OnShow()
end

function BackpackExpandPanel:SetData()
    local needItem = DataItem.data_expand[BackpackManager.Instance.openedCount]
    if needItem ~= nil then
        local baseid = needItem.loss[1][1]
        local need = needItem.loss[1][2]
        local data = ItemData.New()
        self.baseData = DataItem.data_get[baseid]
        if self.baseData ~= nil then
            data:SetBase(self.baseData)
        end
        self.slot:SetAll(data)
        local has = BackpackManager.Instance:GetItemCount(baseid)
        self.enough = (has >= need)
        self.slot:SetNum(has, need)
        self.desc.text = string.format(TI18N("消耗<color='#ffff00'>%s个</color>%s可以扩充<color='#ffff00'>5格</color>背包，是否确定？"), need, ColorHelper.color_item_name(data.quality, data.name))
    end
end

function BackpackExpandPanel:Sure()
    if self.enough then
        BackpackManager.Instance:Send10323()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("所需道具不足"))
        TipsManager.Instance:ShowItem({gameObject = nil, itemData = self.baseData})
    end
    self:Close()
end

