-- @author zgs
SatiationWindow = SatiationWindow or BaseClass(BasePanel)

function SatiationWindow:__init(model)
    self.model = model
    self.name = "SatiationWindow"
    self.pricePer = 700
    self.topPoint = 200
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
end

function SatiationWindow:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function SatiationWindow:__delete()
    for i,v in ipairs(self.itemListSlot) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.itemListSlot = nil

    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.gaWin = nil
    self.model = nil
end

function SatiationWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.satiation_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
                self:OnClickClose()
            end)

    self.content = self.transform:Find("Main/Content")
    local icon = self.content:Find("DescImage/Icon"):GetComponent(Image)
    icon.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "hungernot")
    icon.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(32, 32)

    self.descText1 = self.content:Find("DescText1"):GetComponent(Text)
    self.descText1.text = TI18N("·每场战斗消耗<color='#ffff00'>1点</color>饱食度")
    self.descText2 = self.content:Find("DescText2"):GetComponent(Text)
    self.descText2.text = TI18N("·野外打怪<color='#ffff00'>50%</color>不消耗")

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

    self.remindText = self.content:Find("Text"):GetComponent(Text)
    self:DoClickPanel()
end

function SatiationWindow:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self.model:CloseMain()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function SatiationWindow:OnClickForGetFull()
    -- body
    local roledata = RoleManager.Instance.RoleData
    if roledata.satiety >=self.topPoint then
        NoticeManager.Instance:FloatTipsByString(TI18N("已经饱了，请珍惜食物。"))
    else
        local roledata = RoleManager.Instance.RoleData
        if roledata.coin < (self.pricePer * (self.topPoint - roledata.satiety)) then
            NoticeManager.Instance:FloatTipsByString(TI18N("银币不足"))
        else
            SatiationManager.Instance:send10012(self.topPoint - roledata.satiety)
        end
    end
end

function SatiationWindow:UpdateItemContent()
    -- body
    if self.itemList == nil then
        return
    end
    local itemDicCanUsed = {}
    for k,v in pairs(BackpackManager.Instance.itemDic) do
        local dataTpl = DataItem.data_get[v.base_id]
        if dataTpl ~= nil then
            if dataTpl.func == TI18N("饱食度") then
                if itemDicCanUsed[v.base_id] == nil then
                    itemDicCanUsed[v.base_id] = {}
                end
                table.insert(itemDicCanUsed[v.base_id],v)
            end
        end
    end

    local i = 1
    for k,v in pairs(itemDicCanUsed) do
        self.itemList[i].gameObject:SetActive(true)

        local slot = ItemSlot.New()
        --local itemdata = ItemData.New()
        --local cell = DataItem.data_get[k]
        --itemdata:SetBase(cell)
        slot:SetAll(v[1], {inbag = false, nobutton = false,white_list = {{id = TipsEumn.ButtonType.Use, show = true}}})
        NumberpadPanel.AddUIChild(self.itemList[i].gameObject, slot.gameObject)
        slot:SetNum(BackpackManager.Instance:GetItemCount(k))
        self.itemListSlot[i] = slot

        i = i + 1
    end
    for k=i,3 do
        self.itemList[k].gameObject:SetActive(false)
    end
end

function SatiationWindow:UpdateCoinContent()
    -- body
    if self.btnText ~= nil then
        local roledata = RoleManager.Instance.RoleData
        local satietyData = DataAgenda.data_get_satiety[roledata.lev]
        self.pricePer = satietyData.coin
        if roledata.satiety >=self.topPoint then
            self.btnText.text = "0"
            self.remindText.text = string.format(TI18N("补充<color='#ffff00'>%d</color>点饱食度"), 0)

            self:OnClickClose()
        else
            self.btnText.text = string.format("%d",(self.pricePer * (self.topPoint - roledata.satiety)))
            self.remindText.text = string.format(TI18N("补充<color='#ffff00'>%d</color>点饱食度"), (self.topPoint - roledata.satiety))
        end
    end
end

function SatiationWindow:UpdateWindow()
    -- body
    self:UpdateItemContent()
    self:UpdateCoinContent()
end

function SatiationWindow:OnClickClose()
    self.model:CloseMain()
end


