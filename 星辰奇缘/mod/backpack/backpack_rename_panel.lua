BackpackRenamePanel = BackpackRenamePanel or BaseClass(BasePanel)

function BackpackRenamePanel:__init(parent, model)
    self.parent = parent
    self.model = model
    self.resList = {
        {file = AssetConfig.role_rename_panel, type = AssetType.Main}
    }

    self.openListener = function() self:OnOpen() end
    self.OnOpenEvent:AddListener(self.openListener)
    self.theMoney = 0
    self.cardNum = 0

    self.tipsRenameRules = {TI18N("玩家<40级时，首次改名<color='#00ff00'>免费</color>"),TI18N(string.format("玩家≥40级时，首次改名消耗<color='#00ff00'>%s钻</color>，第2次改名消耗<color='#00ff00'>%s钻</color>", tostring(DataAttr.data_rename_price[0].gold), tostring(DataAttr.data_rename_price[1].gold))), TI18N(string.format("玩家≥40级时，第三次及以后改名需消耗<color='#00ff00'>%s钻</color>", tostring(DataAttr.data_rename_price[2].gold)))}

    self.freeTipsString = TI18N("40级以前玩家拥有<color=#FFFF00>1次</color>免费改名机会")

    self.valueChange = function(msg) self:OnChange(msg) end
end

function BackpackRenamePanel:OnChange(msg)
    local str = ""
    local list = StringHelper.ConvertStringTable(self.inputField.text)
    local change = false
    for i,v in ipairs(list) do
        if Utils.HasCharacter(self.font, v) then
            str = str .. v
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("特殊字符无法显示，请修改"))
            change = true
        end
    end

    if change then
        self.inputField.text = str
    end
end

function BackpackRenamePanel:__delete()
    self.OnOpenEvent:RemoveListener(self.openListener)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BackpackRenamePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.role_rename_panel))
    self.gameObject.name = "Rename"
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t
    self.inputField = t:Find("Main/InputField"):GetComponent(InputField)
    self.font = t:Find("Main/InputField/Text"):GetComponent("Text").font
    self.confirmBtn = t:Find("Main/Confirm"):GetComponent(Button)
    self.confirmText = t:Find("Main/Confirm/Text"):GetComponent(Text)
    self.confirmPayObj = t:Find("Main/Confirm/Pay").gameObject
    self.confirmNum = t:Find("Main/Confirm/Pay/Num"):GetComponent(Text)
    self.cancelBtn = t:Find("Main/Cancel"):GetComponent(Button)
    self.confirmImage = t:Find("Main/Confirm"):GetComponent(Image)
    self.attentionBtn = t:Find("Main/Attention"):GetComponent(Button)
    self.freeTipsText = t:Find("Main/FreeTips"):GetComponent(Text)
    self.freeTipsObj = t:Find("Main/FreeTips").gameObject
    self.mainRect = t:Find("Main"):GetComponent(RectTransform)

    self.confirmPayObj:SetActive(false)
    self.confirmText.gameObject:SetActive(false)

    local btn = t:Find("Panel"):GetComponent(Button)
    if btn == nil then
        btn = t:Find("Panel").gameObject:AddComponent(Button)
    end
    btn.onClick:AddListener(function() self:OnClose() end)
    self.cancelBtn.onClick:AddListener(function() self:OnClose() end)
    self.confirmBtn.onClick:AddListener(function() self:Rename() end)
    self.attentionBtn.onClick:AddListener(function() self:ShowRules() end)

    self.freeTipsText.text = self.freeTipsString

    if VersionCheck.FontContainChar() then
        self.inputField.onEndEdit:AddListener(self.valueChange)
    end

    self.OnOpenEvent:Fire()
end

function BackpackRenamePanel:OnOpen()
    local roleData = RoleManager.Instance.RoleData
    self.transform:SetAsLastSibling()
    self.inputField.text = roleData.name

    self.cardNum = BackpackManager.Instance:GetItemCount(23799)
    if (roleData.lev < 40 and roleData.rename_free == 0) or (string.sub(roleData.name, 1, 1) == "[") then
        -- self.confirmImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.confirmText.gameObject:SetActive(true)
        self.confirmPayObj:SetActive(false)

        self.confirmText.text = TI18N("免费改名")
    elseif self.cardNum > 0 then
        self.confirmText.gameObject:SetActive(true)
        self.confirmPayObj:SetActive(false)

        self.confirmText.text = TI18N("改名卡改名")
    else
        self.confirmText.gameObject:SetActive(false)
        self.confirmPayObj:SetActive(true)
        -- self.confirmImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        
        local time = roleData.rename_unfree
        if time > #DataAttr.data_rename_price then
            time = #DataAttr.data_rename_price
        end
        self.theMoney = DataAttr.data_rename_price[time].gold
        self.confirmNum.text = tostring(DataAttr.data_rename_price[time].gold)
    end

    self:Layout()
end

function BackpackRenamePanel:OnClose()
    self:Hiden()
end

function BackpackRenamePanel:Layout()
    if RoleManager.Instance.RoleData.lev >= 40 then
        self.mainRect.sizeDelta = Vector2(400, 230)
        self.freeTipsObj:SetActive(false)
    else
        self.mainRect.sizeDelta = Vector2(400, 250)
        self.freeTipsObj:SetActive(true)
    end
end

function BackpackRenamePanel:Rename()
    local name = self.inputField.text
    local nameTable = StringHelper.ConvertStringTable(name)
    local model = self.model
    if name ~= nil then
        if #nameTable > 0 and #nameTable < 7 then
            if self.theMoney > 0 then
                local confirmData = NoticeConfirmData.New()
                confirmData.type = ConfirmData.Style.Normal
                confirmData.content = string.format(TI18N("你将花费{assets_1,90002,%s}改名为<color=#00FF00>%s</color>，是否确定？"), tostring(self.theMoney), name)
                confirmData.sureLabel = TI18N("确 定")
                confirmData.cancelLabel = TI18N("取 消")
                confirmData.sureCallback = function() RoleManager.Instance:send10015(name, function() model:OnCloseRename() end) end
                NoticeManager.Instance:ConfirmTips(confirmData)
            elseif self.cardNum > 0 then
                local confirmData = NoticeConfirmData.New()
                confirmData.type = ConfirmData.Style.Normal
                confirmData.content = string.format(TI18N("你将使用<color=#00FF00>改名卡</color>改名为<color=#00FF00>%s</color>，是否确定？"), name)
                confirmData.sureLabel = TI18N("确 定")
                confirmData.cancelLabel = TI18N("取 消")
                confirmData.sureCallback = function() RoleManager.Instance:send10015(name, function() model:OnCloseRename() end) end
                NoticeManager.Instance:ConfirmTips(confirmData)
            else
                RoleManager.Instance:send10015(name, function() model:OnCloseRename() end)
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("名字不能超过6个字"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请输入新名字"))
    end
end

function BackpackRenamePanel:ShowRules()
    TipsManager.Instance:ShowText({gameObject = self.attentionBtn.gameObject, itemData = self.tipsRenameRules})
end
