--author:zzl
--time:2016/12/12
--精炼徽章分享

EquipStrengthDianhuaSharePanel  =  EquipStrengthDianhuaSharePanel or BaseClass(BasePanel)

function EquipStrengthDianhuaSharePanel:__init(model)
    self.name  =  "EquipStrengthDianhuaSharePanel"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.equip_strength_dianhua_share_panel, type  =  AssetType.Main}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file = AssetConfig.equip_strength_dianhua_badges, type = AssetType.Dep}
        ,{file = AssetConfig.open_server_textures, type = AssetType.Dep}
        ,{file  =  AssetConfig.stongbg, type  =  AssetType.Dep}
    }

    self.is_open = false
    return self
end

function EquipStrengthDianhuaSharePanel:__delete()
    self.is_open = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function EquipStrengthDianhuaSharePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_dianhua_share_panel))
    self.gameObject:SetActive(false)
    self.gameObject.name = "EquipStrengthDianhuaSharePanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseEquipDianhuaShareUI() end)

    self.main = self.transform:FindChild("Main")
    self.mainNameText = self.main:FindChild("NameText"):GetComponent(Text)
    self.main:FindChild("StoneBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
    -- self.mainIcon = self.main:FindChild("Icon"):GetComponent(Image)
    self.mainPanel1 = self.main:FindChild("Panel1")
    self.AttrItemList = {}
    for i = 1, 3 do
        table.insert(self.AttrItemList, self.mainPanel1:FindChild(string.format("AttrItem%s", i)))
    end

    self.sub = self.transform:FindChild("Sub")
    self.subLabel = self.sub:FindChild("Label").gameObject
    self.subLabel:SetActive(true)
    self.subNameText = self.sub:FindChild("NameText"):GetComponent(Text)
    self.sub:FindChild("StoneBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    self.subPanel2 = self.sub:FindChild("Panel2")
    self.subPanel3 = self.sub:FindChild("Panel3")
    self.BtnGoDianhua = self.subPanel3:FindChild("BtnDianhua"):GetComponent(Button)
    self.subPanel3Txt = self.subPanel3:FindChild("Text"):GetComponent(Text)
    self.subPanel3Txt.text = TI18N("全套装备<color='#ffff00'>优秀4★</color>时激活")
    self.subPanel1 = self.sub:FindChild("Panel1")
    self.subAttrItemList = {}
    for i = 1, 3 do
        table.insert(self.subAttrItemList, self.subPanel1:FindChild(string.format("AttrItem%s", i)))
    end

    self.BtnGoDianhua.onClick:AddListener(function()
        self.model:CloseEquipDianhuaShareUI()
        WindowManager:OpenWindowById(WindowConfig.WinID.eqmadvance, {5})
    end)

    self.is_open = true
    if self.openArgs.zoneId == RoleManager.Instance.RoleData.zone_id and self.openArgs.platform == RoleManager.Instance.RoleData.platform and self.openArgs.roleId == RoleManager.Instance.RoleData.id then
        --分享的是本人
        self:OnShowLeft(false)
        self:UpdateRightInfo()
    else
        local data = {}
        data.craft = self.openArgs.flag
        data.classes = self.openArgs.classes
        self:OnShowLeft(true)
        self:UpdateLeftInfo(data)
        self:UpdateRightInfo()
        -- EquipStrengthManager.Instance:request10333(self.openArgs.roleId, self.openArgs.platform, self.openArgs.zoneId)
    end
end

--协议返回，两个都显示
-- function EquipStrengthDianhuaSharePanel:OnSocketBack(data)
--     if self.is_open == false then
--         return
--     end
-- end

--只显示自己
function EquipStrengthDianhuaSharePanel:OnShowLeft(state)
    self.sub.gameObject:SetActive(true)
    self.main.gameObject:SetActive(state)
    if state then
        self.sub:GetComponent(RectTransform).anchoredPosition = Vector2(120, 0)
    else
        self.sub:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
    end
end

--更新左边
function EquipStrengthDianhuaSharePanel:UpdateLeftInfo(data)

    self.mainNameText.text = string.format(TI18N("<color='%s'>%s精炼徽章</color>"), EquipStrengthManager.Instance.model.dianhua_color[data.craft], EquipStrengthManager.Instance.model.dianhua_name[data.craft])
    self.main:FindChild("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.equip_strength_dianhua_badges, data.craft)
    local attrList = DataEqm.data_dianhua_suit[string.format("%s_%s", data.craft, data.classes)].attr
    for i = 1, 3 do
        local attr = attrList[i]
        local item = self.AttrItemList[i]
        if attr ~= nil then
            item.gameObject:SetActive(true)
            local icon = item:FindChild("AttrIcon"):GetComponent(Image)
            local txt = item:FindChild("AttrName"):GetComponent(Text)
            icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", attr.attr_name))
            txt.text = string.format("%s+%s", KvData.attr_name[attr.attr_name], attr.val)
        else
            item.gameObject:SetActive(false)
        end
    end
end

--更新右边自己的内容
function EquipStrengthDianhuaSharePanel:UpdateRightInfo()
    local badgeId = EquipStrengthManager.Instance.model:GetCurEquipBadge()
    local curBadgeId = badgeId
    curBadgeId = curBadgeId == 0 and 1 or curBadgeId

    local nextCfgData = DataEqm.data_dianhua_suit[string.format("%s_%s", curBadgeId, RoleManager.Instance.RoleData.classes)]
    while nextCfgData.ignore == 0 and curBadgeId <= 10 do
        curBadgeId = curBadgeId + 1
        nextCfgData = DataEqm.data_dianhua_suit[string.format("%s_%s", curBadgeId, RoleManager.Instance.RoleData.classes)]
    end

    self.subNameText.text = string.format(TI18N("<color='%s'>%s精炼徽章</color>"), EquipStrengthManager.Instance.model.dianhua_color[curBadgeId], EquipStrengthManager.Instance.model.dianhua_name[curBadgeId])
    self.sub:FindChild("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.equip_strength_dianhua_badges, curBadgeId)
    local attrList = DataEqm.data_dianhua_suit[string.format("%s_%s", curBadgeId, RoleManager.Instance.RoleData.classes)].attr
    for i = 1, 3 do
        local attr = attrList[i]
        local item = self.subAttrItemList[i]
        if attr ~= nil then
            item.gameObject:SetActive(true)
            local icon = item:FindChild("AttrIcon"):GetComponent(Image)
            local txt = item:FindChild("AttrName"):GetComponent(Text)
            icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", attr.attr_name))
            txt.text = string.format("%s+%s", KvData.attr_name[attr.attr_name], attr.val)
        else
            item.gameObject:SetActive(false)
        end
    end

    self.subPanel1.gameObject:SetActive(false)
    self.subPanel2.gameObject:SetActive(false)
    self.subPanel3.gameObject:SetActive(false)

    BaseUtils.SetGrey(self.sub:FindChild("Icon"):GetComponent(Image), false)
    if RoleManager.Instance.RoleData.lev < 80 then
        self.subPanel2.gameObject:SetActive(true)
        BaseUtils.SetGrey(self.sub:FindChild("Icon"):GetComponent(Image), true)
    else
        --等级满足，检查下是否自己的是否已经达到了这个等级
        if badgeId == 0 then
            self.subPanel3.gameObject:SetActive(true)
        else
            self.subPanel1.gameObject:SetActive(true)
        end
    end
end