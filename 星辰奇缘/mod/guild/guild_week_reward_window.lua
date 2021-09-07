--2016.12.26
--author:zzl
--公会周工资

GuildWeekRewardWindow  =  GuildWeekRewardWindow or BaseClass(BasePanel)

function GuildWeekRewardWindow:__init(model)
    self.name  =  "GuildWeekRewardWindow"
    self.model  =  model
    self.resList  =  {
        {file  =  AssetConfig.guild_week_pay_win, type  =  AssetType.Main}
        ,{file = AssetConfig.stongbg, type = AssetType.Dep}
    }
    self.is_open = false
    return self
end


function GuildWeekRewardWindow:__delete()
    self.is_open = false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildWeekRewardWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_week_pay_win))
    self.gameObject.name  =  "GuildWeekRewardWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseWeekRewardUI() end)

    self.MainCon = self.transform:FindChild("MainCon")
    local CloseButton = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseButton.onClick:AddListener(function() self.model:CloseWeekRewardUI() end)

    self.LeftCon = self.MainCon:FindChild("LeftCon")
    self.LeftCon:FindChild("Imagebg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
    
    self.LUpgradeConTxt = self.LeftCon.transform:FindChild("UpgradeTipsCon/Text"):GetComponent(Text)
    self.LUpgradeConTxt.text = "周工资将于<color='#ffff00'>周日11:50</color>发放\n<color='#13fc60'>(至少参加任意一场公会战或英雄战)</color>"
    self.SlotCon = self.LeftCon:FindChild("SlotCon")
    local cfgData = DataGuild.data_guild_week_reward[string.format("%s_%s", self.model:get_my_guild_post(), self.model.my_guild_data.academy_lev)]
    self.slot = self:CreateEquipSlot(self.SlotCon)
    self.SlotTxtName = self.SlotCon:FindChild("TxtName"):GetComponent(Text)
    self.LeftTxtAcademy = self.LeftCon:FindChild("TxtAcademy"):GetComponent(Text)
    self.LeftTxtAcademy.text = string.format(TI18N("当前研究院：<color='#ffff00'>%s级</color>(工资礼盒数量<color='#00ff00'>+%s</color>)"), self.model.my_guild_data.academy_lev, cfgData.items_extra[1][2])

    self.TxtPos = self.LeftCon:FindChild("TxtPos"):GetComponent(Text)
    self.TxtPos.text = string.format(TI18N("你当前担任公会职位：<color='#ffff00'>%s</color>"), self.model.member_position_names[self.model:get_my_guild_post()])

    -- local coinTxt = self.LeftCon:FindChild("Item1"):FindChild("ImgTxtVal"):FindChild("TxtVal"):GetComponent(Text)
    -- local expTxt = self.LeftCon:FindChild("Item2"):FindChild("ImgTxtVal"):FindChild("TxtVal"):GetComponent(Text)
    -- local coinIcon = self.LeftCon:FindChild("Item1"):FindChild("ImgTxtVal"):FindChild("ImgIcon"):GetComponent(Image)
    -- local expIcon = self.LeftCon:FindChild("Item2"):FindChild("ImgTxtVal"):FindChild("ImgGx"):GetComponent(Image)
    -- coinTxt.text = tostring(cfgData.items[1][2])
    -- expTxt.text = tostring(cfgData.items[2][2])
    -- self.BtnMore = self.LeftCon:FindChild("BtnMore"):GetComponent(Button)

    self.RightCon = self.MainCon:FindChild("RightCon")
    self.RightTxtAcademy = self.RightCon:FindChild("TxtAcademy"):GetComponent(Text)
    self.RightTxtAcademy.text = string.format(TI18N("当前研究院：<color='#ffff00'>%s级</color>(工资礼盒数量<color='#00ff00'>+%s</color>)"), self.model.my_guild_data.academy_lev, cfgData.items_extra[1][2])


    self.showRight = false
    -- self.BtnMore.onClick:AddListener(function()
    --     self:SwitchRight()
    -- end)
    self:SwitchRight()

    self:UpdateInfo()
end

--切换右边是否显示
function GuildWeekRewardWindow:SwitchRight()
    self.showRight = not self.showRight
    self.RightCon.gameObject:SetActive(self.showRight)
    if self.showRight then
        self.LeftCon:GetComponent(RectTransform).anchoredPosition = Vector2(-156, 0)
        self.RightCon:GetComponent(RectTransform).anchoredPosition = Vector2(156, 0)
        self.MainCon:GetComponent(RectTransform).sizeDelta = Vector2(624, 280)
    else
        self.LeftCon:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)
        self.MainCon:GetComponent(RectTransform).sizeDelta = Vector2(312, 280)
    end
end

--更新左边
function GuildWeekRewardWindow:UpdateInfo()
    local cfgData = DataGuild.data_guild_week_reward[string.format("%s_%s", self.model:get_my_guild_post(), self.model.my_guild_data.academy_lev)]
    local baseData = DataItem.data_get[cfgData.items[1][1]]
    self.SlotTxtName.text = ColorHelper.color_item_name(baseData.quality, baseData.name)
    self:SetStoneSlotData(self.slot, baseData)
    self.slot:SetNum(cfgData.items[1][2] + cfgData.items_extra[1][2])
    --右边
    for k, v in pairs(self.model.member_position_names) do
        if k ~= 0 then
            local tempCfgData = DataGuild.data_guild_week_reward[string.format("%s_%s", k, self.model.my_guild_data.academy_lev)]
            local baseData = DataItem.data_get[tempCfgData.items[1][1]]
            local tempNum = tempCfgData.items[1][2] + tempCfgData.items_extra[1][2]
            local txt = self.RightCon:FindChild(string.format("Txt%s", k)):GetComponent(Text)
            local txtValue = self.RightCon:FindChild(string.format("TxtValue%s", k)):GetComponent(Text)
            txt.text = v
            txtValue.text = string.format("<color='#00ff00'>[%s]</color>  <color='#ffff00'>x%s</color>", baseData.name, tempNum)
        end
    end
end

--为每个武器创建slot
function GuildWeekRewardWindow:CreateEquipSlot(SlotCon)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(SlotCon)
    stone_slot.gameObject.transform.localScale = Vector3.one
    stone_slot.gameObject.transform.localPosition = Vector3.zero
    stone_slot.gameObject.transform.localRotation = Quaternion.identity
    local rect = stone_slot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one
    return stone_slot
end

--对slot设置数据
function GuildWeekRewardWindow:SetStoneSlotData(slot, data, _nobutton)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nobutton == nil then
        slot:SetAll(cell, {_nobutton = true})
    else
        slot:SetAll(cell, {nobutton = _nobutton})
    end
end