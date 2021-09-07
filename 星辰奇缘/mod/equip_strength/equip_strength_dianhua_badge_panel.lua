--author:zzl
--time:2016/12/9
--徽章

EquipStrengthDianhuaBadgePanel  =  EquipStrengthDianhuaBadgePanel or BaseClass(BasePanel)

function EquipStrengthDianhuaBadgePanel:__init(model)
    self.name  =  "EquipStrengthDianhuaBadgePanel"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.equip_strength_dianhua_badge_panel, type  =  AssetType.Main}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file = AssetConfig.equip_strength_dianhua_badges, type = AssetType.Dep}
        , {file  =  AssetConfig.stongbg, type  =  AssetType.Dep}
    }

    self.is_open = false
    return self
end

function EquipStrengthDianhuaBadgePanel:__delete()
    self.is_open = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function EquipStrengthDianhuaBadgePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_dianhua_badge_panel))
    self.gameObject:SetActive(false)
    self.gameObject.name = "EquipStrengthDianhuaBadgePanel"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseEquipDianhuaBadgeUI() end)
    self.transform.localPosition = Vector3(0, 0, -400)

    self.Main = self.transform:FindChild("Main")
    self.CloseButton = self.Main:FindChild("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseEquipDianhuaBadgeUI() end)

    self.NowPanel = self.Main:FindChild("NowPanel")
    self.ImgArrow = self.NowPanel:FindChild("ImgArrow").gameObject
    self.TipsButton = self.NowPanel:FindChild("TipsButton"):GetComponent(Button)
    self.TipsButton.onClick:AddListener(function()
        local npcBase = BaseUtils.copytab(DataUnit.data_unit[20073])
        MainUIManager.Instance:OpenDialog({baseid = 20073, name = npcBase.name}, {base = npcBase}, true, true)
    end)
    self.NameText= self.NowPanel:FindChild("NameText"):GetComponent(Text)
    self.NowPanel:FindChild("StoneBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
    self.ShareButton = self.NowPanel:FindChild("ShareButton"):GetComponent(Button)
    self.ShareCon = self.NowPanel:FindChild("ShareCon")
    self.BtnFriend = self.ShareCon:FindChild("BtnFriend"):GetComponent(Button)
    self.BtnGuild =  self.ShareCon:FindChild("BtnGuild"):GetComponent(Button)
    self.BtnWorld =  self.ShareCon:FindChild("BtnWorld"):GetComponent(Button)

    self.showShareCon = false
    self.ShareButton.onClick:AddListener(function()
        self.showShareCon = not self.showShareCon
        self.ShareCon.gameObject:SetActive(self.showShareCon)
    end)
    self.BtnFriend.onClick:AddListener(function()
        local curBadgeId = EquipStrengthManager.Instance.model:GetCurEquipBadge()
        -- if GuildManager.Instance.model:check_has_join_guild() then
        --     local role = RoleManager.Instance.RoleData
        --     local newStr = string.format("{dianhua_1,%s,%s,%s,%s,%s}", role.id, role.zone_id, role.platform, role.name, curBadgeId)
        --     ChatManager.Instance:Send10400(MsgEumn.ChatChannel.Guild, newStr)
        --     self.model:CloseEquipDianhuaBadgeUI()
        -- end
    end)
    self.BtnGuild.onClick:AddListener(function()
        if GuildManager.Instance.model:check_has_join_guild() then
            local curBadgeId = EquipStrengthManager.Instance.model:GetCurEquipBadge()
            local role = RoleManager.Instance.RoleData
            local newStr = string.format("{dianhua_1,%s,%s,%s,%s,%s,%s}", role.id, role.zone_id, role.platform, role.name, curBadgeId, role.classes)
            ChatManager.Instance:Send10400(MsgEumn.ChatChannel.Guild, newStr)
            self.model:CloseEquipDianhuaBadgeUI()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("尚未加入公会"))
        end
    end)
    self.BtnWorld.onClick:AddListener(function()
        local curBadgeId = EquipStrengthManager.Instance.model:GetCurEquipBadge()
        local role = RoleManager.Instance.RoleData
        local newStr = string.format("{dianhua_1,%s,%s,%s,%s,%s,%s}", role.id, role.zone_id, role.platform, role.name, curBadgeId, role.classes)
        ChatManager.Instance:Send10400(MsgEumn.ChatChannel.World, newStr)
        self.model:CloseEquipDianhuaBadgeUI()
    end)

    self.NextPanel = self.Main:FindChild("NextPanel")
    self.NextNameText = self.NextPanel:FindChild("NameText"):GetComponent(Text)
    self.NextPanel:FindChild("StoneBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    self.InfoPanel = self.Main:FindChild("InfoPanel")
    self.TitleText = self.InfoPanel:FindChild("TitleText"):GetComponent(Text)

    self:UpatePanel()
end

--更新界面π
function EquipStrengthDianhuaBadgePanel:UpatePanel()
    --本级
    local curBadgeId = EquipStrengthManager.Instance.model:GetCurEquipBadge()

    local maxLevel = 1
    local tempBadgeId = 0
    local classes = RoleManager.Instance.RoleData.classes
    for i = 1, 13 do
        local data = DataEqm.data_dianhua_suit[string.format("%s_%s", i, classes)]
        if data.ignore == 1 then
            maxLevel = i
        end
        if i <= curBadgeId and data.ignore == 1 then
            tempBadgeId = i
        end
    end
    curBadgeId = tempBadgeId
    
    if curBadgeId ~= 0 then
        local cfgData = DataEqm.data_dianhua_suit[string.format("%s_%s", curBadgeId, RoleManager.Instance.RoleData.classes)]
        if cfgData.ignore ~= 0 then
            self.Main:GetComponent(RectTransform).sizeDelta = Vector2(380, 390)
            self.NowPanel.gameObject:SetActive(true)
            self.NowPanel:FindChild("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.equip_strength_dianhua_badges, curBadgeId)
            self.NameText.text = string.format(TI18N("<color='%s'>%s徽章</color>"), self.model.dianhua_color[curBadgeId], self.model.dianhua_name[curBadgeId])
            local attrList = cfgData.attr
            for i = 1, 3 do
                local attr = attrList[i]
                local item = self.NowPanel:FindChild(string.format("AttrItem%s", i))
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
        else
            -- self.Main:GetComponent(RectTransform).sizeDelta = Vector2(380, 250)
            self.NowPanel.gameObject:SetActive(false)
        end
    else
        -- self.Main:GetComponent(RectTransform).sizeDelta = Vector2(380, 250)
        self.NowPanel.gameObject:SetActive(false)
    end

    --下一级
    self.NowPanel:FindChild("UnActiveTxt"):GetComponent(Text).text = ""
    local nextBadgeId = curBadgeId+1
    self.ShareButton.gameObject:SetActive(true)
    self.InfoPanel.gameObject:SetActive(true)
    if curBadgeId == maxLevel then
        --满级
        nextBadgeId = curBadgeId
        self.ImgArrow:SetActive(false)
        self.Main:GetComponent(RectTransform).sizeDelta = Vector2(380, 177.4)
        self.NextPanel.gameObject:SetActive(false)
        self.NowPanel:GetComponent(RectTransform).anchoredPosition = Vector2(190, 93.2)
        self.InfoPanel.gameObject:SetActive(false)
    else
        local nextCfgData = DataEqm.data_dianhua_suit[string.format("%s_%s", nextBadgeId, RoleManager.Instance.RoleData.classes)]
        while nextCfgData.ignore == 0 and nextBadgeId <= maxLevel do
            nextBadgeId = nextBadgeId + 1
            nextCfgData = DataEqm.data_dianhua_suit[string.format("%s_%s", nextBadgeId, RoleManager.Instance.RoleData.classes)]
        end

        -- 没满级
        self.ImgArrow:SetActive(true)
        if curBadgeId ~= 0 then
            local cfgData = DataEqm.data_dianhua_suit[string.format("%s_%s", curBadgeId, RoleManager.Instance.RoleData.classes)]
            if cfgData.ignore ~= 0 then
                self.Main:GetComponent(RectTransform).sizeDelta = Vector2(380, 390)
                self.NowPanel:GetComponent(RectTransform).anchoredPosition = Vector2(190, 308)
                self.NextPanel.gameObject:SetActive(true)
                local starNum = 4
                self.NextPanel:FindChild("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.equip_strength_dianhua_badges, nextBadgeId)
                self.NextNameText.text = string.format(TI18N("下一级 <color='%s'>%s徽章</color>\n(全套装备<color='#FFFF89'>%s★至%s</color>时激活)"), self.model.dianhua_color[nextBadgeId], self.model.dianhua_name[nextBadgeId], starNum, self.model.dianhua_name[nextBadgeId])
                local nextAttrList = DataEqm.data_dianhua_suit[string.format("%s_%s", nextBadgeId, RoleManager.Instance.RoleData.classes)].attr
                for i = 1, 3 do
                    local attr = nextAttrList[i]
                    local item = self.NextPanel:FindChild(string.format("AttrItem%s", i))
                    if attr ~= nil then
                        item.gameObject:SetActive(true)
                        local icon = item:FindChild("AttrIcon"):GetComponent(Image)
                        local txt = item:FindChild("AttrName"):GetComponent(Text)
                        icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", attr.attr_name))
                        txt.text = string.format(TI18N("%s+%s(未激活)"), KvData.attr_name[attr.attr_name], attr.val)
                    else
                        item.gameObject:SetActive(false)
                    end
                end
            else
                --初始状态
                self.ImgArrow:SetActive(false)
                self.ShareButton.gameObject:SetActive(false)
                self.NowPanel:GetComponent(RectTransform).anchoredPosition = Vector2(190, 176.9)
                self.Main:GetComponent(RectTransform).sizeDelta = Vector2(380, 250)
                self.NowPanel.gameObject:SetActive(true)
                self.NextPanel.gameObject:SetActive(false)
                local starNum = 4
                self.NowPanel:FindChild("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.equip_strength_dianhua_badges, nextBadgeId)
                -- \n(全套装备<color='#FFFF89'>%s%s★</color>时激活)//, self.model.dianhua_name[nextBadgeId], starNum
                self.NameText.text = string.format(TI18N("<color='%s'>%s徽章</color>"), self.model.dianhua_color[nextBadgeId], self.model.dianhua_name[nextBadgeId])
                local nextAttrList = DataEqm.data_dianhua_suit[string.format("%s_%s", nextBadgeId, RoleManager.Instance.RoleData.classes)].attr
                for i = 1, 3 do
                    local attr = nextAttrList[i]
                    local item = self.NowPanel:FindChild(string.format("AttrItem%s", i))
                    if attr ~= nil then
                        item.gameObject:SetActive(true)
                        local icon = item:FindChild("AttrIcon"):GetComponent(Image)
                        local txt = item:FindChild("AttrName"):GetComponent(Text)
                        icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", attr.attr_name))
                        txt.text = string.format(TI18N("%s+%s(未激活)"), KvData.attr_name[attr.attr_name], attr.val)
                    else
                        item.gameObject:SetActive(false)
                    end
                end
                self.NowPanel:FindChild("UnActiveTxt"):GetComponent(Text).text =string.format(TI18N("(全套装备<color='#E4E77F'>4★至%s</color>时激活)"), self.model.dianhua_name[nextBadgeId])
            end
        else
            --初始状态
            self.ImgArrow:SetActive(false)
            self.ShareButton.gameObject:SetActive(false)
            self.NowPanel:GetComponent(RectTransform).anchoredPosition = Vector2(190, 176.9)
            self.Main:GetComponent(RectTransform).sizeDelta = Vector2(380, 250)
            self.NowPanel.gameObject:SetActive(true)
            self.NextPanel.gameObject:SetActive(false)
            local starNum = 4
            self.NowPanel:FindChild("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.equip_strength_dianhua_badges, nextBadgeId)
            -- \n(全套装备<color='#FFFF89'>%s%s★</color>时激活)//, self.model.dianhua_name[nextBadgeId], starNum
            self.NameText.text = string.format(TI18N("<color='%s'>%s徽章</color>"), self.model.dianhua_color[nextBadgeId], self.model.dianhua_name[nextBadgeId])
            local nextAttrList = DataEqm.data_dianhua_suit[string.format("%s_%s", nextBadgeId, RoleManager.Instance.RoleData.classes)].attr
            for i = 1, 3 do
                local attr = nextAttrList[i]
                local item = self.NowPanel:FindChild(string.format("AttrItem%s", i))
                if attr ~= nil then
                    item.gameObject:SetActive(true)
                    local icon = item:FindChild("AttrIcon"):GetComponent(Image)
                    local txt = item:FindChild("AttrName"):GetComponent(Text)
                    icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", attr.attr_name))
                    txt.text = string.format(TI18N("%s+%s(未激活)"), KvData.attr_name[attr.attr_name], attr.val)
                else
                    item.gameObject:SetActive(false)
                end
            end
            self.NowPanel:FindChild("UnActiveTxt"):GetComponent(Text).text =string.format(TI18N("(全套装备<color='#E4E77F'>4★至%s</color>时激活)"), self.model.dianhua_name[nextBadgeId])
        end
    end

    --更新底部
    local index = 1
    local tempNum = 0
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        self.InfoPanel:FindChild(string.format("DescText%s", index)):GetComponent(Button).onClick:RemoveAllListeners()
        self.InfoPanel:FindChild(string.format("DescText%s", index)):GetComponent(Button).onClick:AddListener(function()
            self.model:CloseEquipDianhuaBadgeUI()
            EquipStrengthManager.Instance.model.strength_data = {type = v.type}
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.eqmadvance, {5})
        end)
        local txt = self.InfoPanel:FindChild(string.format("DescText%s", index)):FindChild("Text"):GetComponent(Text)
        if self.model:CheckDianhuaCondition(v, nextBadgeId) then
            txt.text = string.format("<color='#00ff00'>%s</color>", self:GetEquipTypeName(v.type))
            tempNum = tempNum + 1
        else
            txt.text = self:GetEquipTypeName(v.type)
        end
        index = index + 1
    end
    local color = "#ff0000"
    if tempNum == 8 then
        color = "#00ff00"
    end
    self.TitleText.text = string.format(TI18N("%s徽章进度：(<color='%s'>%s</color>/8)"), self.model.dianhua_name[nextBadgeId], color, tempNum)
end

--传入装备类型获取装备中文名字
function EquipStrengthDianhuaBadgePanel:GetEquipTypeName(equipType)
    if equipType == 1 or equipType == 2 or equipType == 3 or equipType == 4 or equipType == 5 or equipType == 21 or equipType == 22 then
        return TI18N("武器")
    else
        if equipType == 6 then
            return TI18N("戒指")
        elseif equipType == 7 then
            return TI18N("项链")
        elseif equipType == 9 then
            return TI18N("手镯")
        elseif equipType == 10 then
            return TI18N("衣服")
        elseif equipType == 11 then
            return TI18N("腰带")
        elseif equipType == 12 then
            return TI18N("裤子")
        elseif equipType == 14 then
            return TI18N("鞋子")
        end
    end
    return ""
end







