-- @author 黄耀聪
WingsEnergy = WingsEnergy or BaseClass(BasePanel)

function WingsEnergy:__init(model)
    self.model = model
    self.name = "WingsEnergy"
    self.pricePer = 60
    self.topPoint = 100
    self.resList = {
        {file = AssetConfig.satiation_window, type = AssetType.Main}
        ,{file = AssetConfig.normalbufficon, type = AssetType.Dep}
        --,{file  =  AssetConfig.FashionBg, type  =  AssetType.Dep}
        --, {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdateWindow()
    end)
    self.itemListSlot = {}

    self.updateListener = function() self:UpdateWindow() end
end

function WingsEnergy:OnInitCompleted()
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.updateListener)
    EventMgr.Instance:AddListener(event_name.role_wings_change, self.updateListener)
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function WingsEnergy:__delete()
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.updateListener)
    self.content:Find("DescImage/Icon"):GetComponent(Image).sprite = nil
    self.content:Find("Button/Image"):GetComponent(Image).sprite = nil
    for i,v in ipairs(self.itemListSlot) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.itemListSlot = nil

    self:AssetClearAll()
    self.model.gaWin = nil
    self.model = nil
end

function WingsEnergy:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.satiation_window))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
                self:OnClickClose()
            end)

    self.content = self.transform:Find("Main/Content")
    local icon = self.content:Find("DescImage/Icon"):GetComponent(Image)
    icon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "wing_energy")
    icon.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(32, 32)

    self.descText1 = self.content:Find("DescText1"):GetComponent(Text)
    self.descText1.text = TI18N("·战斗中每次使用高阶翅膀特技，将消耗晶石能量")
    self.descText2 = self.content:Find("DescText2"):GetComponent(Text)
    self.descText2.text = TI18N("·PVP战斗每次消耗<color='#ffff00'>5</color>点，PVE战斗消耗<color='#ffff00'>1</color>点")

    self.itemList = {
        [1] = self.content:Find("ItemImage1"):GetComponent(Image),
        [2] = self.content:Find("ItemImage2"):GetComponent(Image),
        [3] = self.content:Find("ItemImage3"):GetComponent(Image)
    }

    self.btn = self.content:Find("Button"):GetComponent(Button)
    self.btn.onClick:AddListener(function()
                self:OnClickForGetFull()
            end)
    self.btnText = self.content:Find("Button/Text"):GetComponent(Text)

    self.content:Find("Button/Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90003")

    self.remindText = self.content:Find("Text"):GetComponent(Text)
    self:DoClickPanel()
end

function WingsEnergy:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self:OnClickClose()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function WingsEnergy:OnClickForGetFull()
    local point = (((CombatManager.Instance.controller or {}).enterData or {}).energy) or WingsManager.Instance.wing_power or 0
    if point >=self.topPoint then
        -- NoticeManager.Instance:FloatTipsByString(TI18N("已经饱了，请珍惜食物。"))
    else
        if RoleManager.Instance.RoleData.gold_bind < (self.pricePer * (self.topPoint - point)) then
            NoticeManager.Instance:FloatTipsByString(TI18N("金币不足"))
        else
            WingsManager.Instance:Send11617()
        end
    end
end

function WingsEnergy:UpdateItemContent()
    if self.itemList == nil then
        return
    end
    local itemDicCanUsed = {21135}

    local i = 1
    for _,base_id in pairs(itemDicCanUsed) do
        self.itemList[i].gameObject:SetActive(true)

        local slot = ItemSlot.New()
        --local itemdata = ItemData.New()
        --local cell = DataItem.data_get[k]
        --itemdata:SetBase(cell)
        local list = BackpackManager.Instance:GetItemByBaseid(base_id)
        if list[1] ~= nil then
            slot:SetAll(list[1], {inbag = true, nobutton = false})
            slot:SetGrey(false)
        else
            slot:SetAll(DataItem.data_get[base_id], {inbag = false, nobutton = true})
            slot:SetGrey(true)
        end
        NumberpadPanel.AddUIChild(self.itemList[i].gameObject, slot.gameObject)
        slot:SetNum(BackpackManager.Instance:GetItemCount(base_id))
        self.itemListSlot[i] = slot

        i = i + 1
    end
    for k=i,3 do
        self.itemList[k].gameObject:SetActive(false)
    end
end

function WingsEnergy:UpdateCoinContent()
    local point = (((CombatManager.Instance.controller or {}).enterData or {}).energy) or WingsManager.Instance.wing_power or 0
    self.content:Find("DescImage/Text"):GetComponent(Text).text = string.format(TI18N("翅膀特技能量(%s/%s)"), point, self.topPoint)
    if CombatManager.Instance.isFighting then
        NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>战斗结束后</color>再补充能量吧{face_1,3}"))
        self:OnClickClose()
        return
    end
    if self.btnText ~= nil then
        if point >=self.topPoint then
            -- self.btnText.text = "0"
            -- self.remindText.text = string.format(TI18N("补充<color='#ffff00'>%d</color>点能量"), 0)

            NoticeManager.Instance:FloatTipsByString(TI18N("能量已满，无需补充{face_1,2}"))
            self:OnClickClose()
        else
            self.btnText.text = string.format("%d",(self.pricePer * (self.topPoint - point)))
            self.remindText.text = string.format(TI18N("补充<color='#ffff00'>%d</color>点能量"), (self.topPoint - point))
        end
    end
end

function WingsEnergy:UpdateWindow()
    -- body
    self:UpdateItemContent()
    self:UpdateCoinContent()
end

function WingsEnergy:OnClickClose()
    self.model:CloseEnergy()
end


