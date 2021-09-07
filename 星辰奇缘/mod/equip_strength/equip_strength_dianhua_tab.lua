EquipStrengthDianhuaTab = EquipStrengthDianhuaTab or BaseClass(BasePanel)

function EquipStrengthDianhuaTab:__init(parent)
    self.parent = parent
    self.resList = {
        {file = AssetConfig.equip_strength_dianhua_con, type = AssetType.Main}
        ,{file = AssetConfig.stongbg, type = AssetType.Dep}
        ,{file = AssetConfig.pet_textures, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20049), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
        ,{file = string.format(AssetConfig.effect, 20144), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }


    self.has_init = false
    self.cur_dianhua_item = nil
    self.last_shenqi_id = 0

    self.star_con_x = {
        [0] = 92,
        [1] = 76,
        [2] = 67,
        [3] = 57,
        [4] = 44,
        [5] = 34
    }
    self.unOpenIndex = 0
    self.lockState = 0
    self.on_dianhua_success = function()
        self:play_success_effect()
    end
    self.dianHuaBuyBtn = nil
    self.guideEffect = nil

    self.changeClassesListener = function() self:ChangeClasses() end
    EventMgr.Instance:AddListener(event_name.change_classes_success, self.changeClassesListener)

    return self
end

function EquipStrengthDianhuaTab:__delete()
    EventMgr.Instance:RemoveListener(event_name.change_classes_success, self.changeClassesListener)
    if self.guideEffect ~= nil then
        self.guideEffect:DeleteMe()
        self.guideEffect = nil
    end
    if self.dianHuaBuyBtn ~= nil then
        self.dianHuaBuyBtn:DeleteMe()
        self.dianHuaBuyBtn = nil
    end
    self.top_slot:DeleteMe()
    self.bottom_slot:DeleteMe()
    self.bottom_lock_slot:DeleteMe()

    self.bigbg.sprite = nil

    self.cur_dianhua_item = nil

    if self.left_item_list ~= nil then
        for i=1,#self.left_item_list do
            local lelf_item = self.left_item_list[i]
            lelf_item:Release()
        end
    end
    self.left_item_list = nil

    EventMgr.Instance:RemoveListener(event_name.equip_item_change, self.on_equip_update)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_item_update)
    EventMgr.Instance:RemoveListener(event_name.equip_dianhua_success, self.on_dianhua_success)


    self.has_init = false
    self.last_shenqi_id = 0

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self.item_list = nil
    self:AssetClearAll()
end

function EquipStrengthDianhuaTab:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_dianhua_con))
    self.gameObject.name = "EquipStrengthDianhuaTab"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.gameObject.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(154, -9, 0)

    self.TitleCon = self.transform:FindChild("TitleCon")
    self.TxtTitle = self.TitleCon:FindChild("TxtTitle"):GetComponent(Text)

    self.LeftCon = self.transform:FindChild("LeftCon")
    self.MaskCon = self.LeftCon:FindChild("MaskCon")
    self.ScrollCon = self.MaskCon:FindChild("ScrollCon")
    self.Container = self.ScrollCon:FindChild("Container")
    self.ImgItem = self.Container:FindChild("ImgItem").gameObject
    self.ImgItem:SetActive(false)

    self.RightCon = self.transform:FindChild("RightCon")
    self.TopCon = self.RightCon:FindChild("TopCon")
    self.LockBtn = self.TopCon:FindChild("LockBtn"):GetComponent(Button)
    self.lockImg = self.TopCon:FindChild("LockBtn"):FindChild("LockImage").gameObject
    self.unLockImg = self.TopCon:FindChild("LockBtn"):FindChild("UnlockImage").gameObject
    self.Right_TitleCon = self.TopCon:FindChild("TitleCon")
    self.Right_TxtTitle = self.Right_TitleCon:FindChild("TxtTitle"):GetComponent(Text)
    self.ButtonLook = self.Right_TitleCon:FindChild("ButtonLook"):GetComponent(Button)

    self.ImgSlotBg = self.TopCon:FindChild("ImgSlotBg")

    -- 大图 hosr
    self.bigbg = self.ImgSlotBg:GetComponent(Image)
    self.bigbg.sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    self.Top_SlotCon = self.ImgSlotBg:FindChild("SlotCon").gameObject
    self.top_slot = self:create_equip_slot(self.Top_SlotCon)
    self.StarCon = self.TopCon:FindChild("StarCon")
    self.star_rect = self.StarCon:GetComponent(RectTransform)
    self.NewStarCon = self.TopCon:FindChild("NewStarCon").gameObject
    self.new_star_rect = self.NewStarCon:GetComponent(RectTransform)
    self.tips = self.TopCon:Find("Tips").gameObject
    self.tipsTxt = self.tips:GetComponent(Text)
    self.tipsTxt.text = ""
    self.tips:SetActive(false)

    self.top_right_effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20049)))
    self.top_right_effect.transform:SetParent(self.Top_SlotCon.transform)
    self.top_right_effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.top_right_effect.transform, "UI")
    self.top_right_effect.transform.localScale = Vector3(0.75, 0.75, 0.75)
    self.top_right_effect.transform.localPosition = Vector3(0, 3, -400)
    self.top_right_effect:SetActive(false)


    self.top_right_effect_2 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20144)))
    self.top_right_effect_2.transform:SetParent(self.Top_SlotCon.transform)
    self.top_right_effect_2.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.top_right_effect_2.transform, "UI")
    self.top_right_effect_2.transform.localScale = Vector3(0.75, 0.75, 0.75)
    self.top_right_effect_2.transform.localPosition = Vector3(0, 3, -400)
    self.top_right_effect_2:SetActive(false)

    self.star_txtdesc = self.StarCon:FindChild("TxtDesc"):GetComponent(Text)
    self.star_list = {}
    for i=1,5 do
        local star = self.StarCon:FindChild(string.format("ImgStar%s", i)):GetComponent(Image)
        star.gameObject:SetActive(false)
        table.insert(self.star_list, star)
    end

    self.new_star_txtdesc = self.NewStarCon.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.new_star_list = {}
    for i = 1, 5 do
        local star = self.NewStarCon.transform:FindChild(string.format("ImgStar%s", i)):GetComponent(Image)
        star.gameObject:SetActive(false)
        table.insert(self.new_star_list, star)
    end
    self.NewStarCon:SetActive(false)

    self.TxtDesc1 = self.TopCon:FindChild("TxtDesc1"):GetComponent(Text)
    self.TxtDesc2 = self.TopCon:FindChild("TxtDesc2"):GetComponent(Text)
    self.BottomCon = self.RightCon:FindChild("BottomCon")
    self.txtExtraProp = self.BottomCon:FindChild("ExtraPropCon"):FindChild("TxtExtraProp"):GetComponent(Text)
    self.BottomCostCon = self.BottomCon:FindChild("CostCon")
    self.Bottom_SlotCon = self.BottomCostCon:FindChild("SlotCon").gameObject
    self.Bottom_LockSlotCon = self.BottomCostCon:FindChild("LockSlotCon").gameObject
    self.Bottom_ImgIcon = self.BottomCostCon:FindChild("SlotCon"):FindChild("ImgIcon"):GetComponent(Image)
    self.Bottom_TxtVal = self.BottomCostCon:FindChild("SlotCon"):FindChild("TxtVal"):GetComponent(Text)
    self.bottom_slot = self:create_equip_slot(self.Bottom_SlotCon)
    self.bottom_lock_slot = self:create_equip_slot(self.Bottom_LockSlotCon)
    self.luckValTxt = self.BottomCon:Find("LuckCon/TxtLuckVal"):GetComponent(Text)
    self.luckTanHaoBtn = self.BottomCon:FindChild("LuckCon"):GetComponent(Button)
    self.TxtName = self.BottomCostCon:FindChild("SlotCon"):FindChild("TxtName"):GetComponent(Text)
    self.LockTxtName = self.BottomCostCon:FindChild("LockSlotCon"):FindChild("TxtName"):GetComponent(Text)
    self.BtnDianhua = self.BottomCon:FindChild("BtnDianhua")
    self.BtnDianhuaRect = self.BtnDianhua:GetComponent(RectTransform)
    self.BtnDianhua_point = self.BtnDianhua:FindChild("ImgPoint").gameObject
    self.BtnDianhua_Text = self.BtnDianhua:FindChild("Text"):GetComponent(Text)
    self.savaBtn = self.BottomCon:Find("SaveBtn").gameObject
    self.savaBtn:GetComponent(Button).onClick:AddListener(function() self:Save() end)

    self.intervalTipsBtn = self.BottomCon:Find("BtnTips")
    self.intervalTipsBtn:GetComponent(Button).onClick:AddListener(function()
            local name_str = EquipStrengthManager.Instance.model.dianhua_name[self.cur_dianhua_item.data.craft]
            local tips = {}
            table.insert(tips, string.format(TI18N("受世界等级影响，<color='#00ff00'>%s</color>精炼消耗降低<color='#00ff00'>%s%%</color>"), name_str, (1- self.percent)*100 ))
            TipsManager.Instance:ShowText({gameObject = self.intervalTipsBtn.gameObject, itemData = tips})
        end)

    self.BtnDianhua_point:SetActive(false)

    self.ButtonLook.onClick:AddListener(function()
        EquipStrengthManager.Instance.model:OpenEquipDianhuaLooksUI(self.cur_selected_data, self.cur_dianhua_item.data.craft)
    end)
    self.luckValTxt.text = string.format("%s:%s", TI18N("幸运值"),0)

    self.luckTanHaoBtn.onClick:AddListener(function()
        local tips = {}
        table.insert(tips, string.format("%s<color='#c3692c'>%s</color>%s", TI18N("精炼次数越多，出现"), TI18N("4★、5★属性"), TI18N("的几率越高")))
        TipsManager.Instance:ShowText({gameObject = self.luckTanHaoBtn.gameObject, itemData = tips})
    end)

    self.click_dianhua = false
    self.show_get_new_shenqi = false

    self.dianHuaBuyBtn = BuyButton.New(self.BtnDianhua, TI18N("精炼"))
    self.dianHuaBuyBtn:Set_btn_img("DefaultButton3")
    self.dianHuaBuyBtn.key = "EquipStrengthDianhua"
    self.dianHuaBuyBtn.protoId = 10617
    self.dianHuaBuyBtn:Show()
    self.onClickDianhua = function()
        self:OnBtnDianhua()
    end
    self.dianHuaCostData = nil
    self.onDianhuaPriceBack = function(prices)
        local data = prices[self.dianHuaCostData.id]
        if data == nil then
            self.Bottom_TxtVal.text = ""
            self.Bottom_ImgIcon.gameObject:SetActive(false)
            self.BtnDianhuaRect.anchoredPosition = Vector2(self.BtnDianhuaRect.anchoredPosition.x, -83)
            self.savaBtn.transform.anchoredPosition = Vector2(self.savaBtn.transform.anchoredPosition.x, -83)
            return
        end
        local allprice = data.allprice
        local price_str = ""
        if allprice >= 0 then
            price_str = string.format("<color='%s'>%s</color>", "#ffffff", allprice)
        else
            price_str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], -allprice)
        end
        self.Bottom_TxtVal.text = price_str
        self.Bottom_ImgIcon.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures,GlobalEumn.CostTypeIconName[data.assets])
        self.Bottom_ImgIcon.gameObject:SetActive(true)
        self.BtnDianhuaRect.anchoredPosition = Vector2(self.BtnDianhuaRect.anchoredPosition.x, -98)
        self.savaBtn.transform.anchoredPosition = Vector2(self.savaBtn.transform.anchoredPosition.x, -98)
    end
    self.LockBtn.onClick:AddListener(function()
        self:OnBtnLock()
    end)

    self.on_equip_update = function(equips)
    end
    self.on_item_update = function()
        if self.cur_selected_item ~= nil then
        end
    end

    self.has_init = true
    self:SetUnShowLock()
    if self.parent.cur_left_selected_data ~= nil then
        self:update_info(self.parent.cur_left_selected_data)
    end


    EventMgr.Instance:AddListener(event_name.equip_dianhua_success, self.on_dianhua_success)
end

--更新显示
function EquipStrengthDianhuaTab:update_info(data, _type, is_item_update)
    if self.has_init == false then
        return
    end

    if data ~= nil and self.cur_selected_data ~= nil then
        if data.type ~= self.cur_selected_data.type then
            self.cur_dianhua_item = nil
            self.last_shenqi_id = data.currLookId
        end
    end

    self.cur_selected_data = data
    self:update_left()
end

--播放点化成功特效
function EquipStrengthDianhuaTab:play_success_effect()
    if self.effectTimeId ~= nil then
        LuaTimer.Delete(self.effectTimeId)
        self.effectTimeId = nil
    end
    self.top_right_effect:SetActive(false)
    self.top_right_effect:SetActive(true)
    self.effectTimeId = LuaTimer.Add(1100, function() self.top_right_effect:SetActive(false) end)
end

--更新左边显示
function EquipStrengthDianhuaTab:update_left()
    --从配置中取出改装备可以电话的品质列表

    self.dianhua_list = EquipStrengthManager.Instance.model:get_equip_dianhua_list(self.cur_selected_data.type, RoleManager.Instance.RoleData.classes)

    if self.left_item_list ~= nil then
        for i=1,#self.left_item_list do
            local lelf_item = self.left_item_list[i]
            lelf_item:set_selected_state(false)
            lelf_item.gameObject:SetActive(false)
        end
    else
        self.left_item_list = {}
    end

    -- 激活是按照品质次序的，从底到高
    local currActIndex = 1 -- 当前已激活的品质次序
    local currCraft = 1 -- 当前已激活的品质

    local has_check_can_dianhua = false

    local roleLev = RoleManager.Instance.RoleData.lev
    if roleLev < 100 and RoleManager.Instance.RoleData.lev_break_times > 0 then
        roleLev = 100
    end

    for i=1,#self.dianhua_list do
        local cfg_data = self.dianhua_list[i]
        local item = self.left_item_list[i]
        if item == nil then
            item = EquipStrengthDianhuaItem.New(self, self.ImgItem, cfg_data, i)
            table.insert(self.left_item_list, item)
        end
        item:set_data(cfg_data)

        if EquipStrengthManager.Instance.model:check_changeclasses_dianhua(self.cur_selected_data, cfg_data.craft) then
            item:set_img_point(true)
        elseif has_check_can_dianhua == false and cfg_data.lev <= roleLev and item.has_dianhua == false then
            local temp_base_data = DataItem.data_get[item.data.loss[1][1]]
            local has_num = BackpackManager.Instance:GetItemCount(temp_base_data.id)
            local cost_num = item.data.loss[1][2]
            if has_num >= cost_num then
                item:set_img_point(true)
                has_check_can_dianhua = true
            end
        end

        if item.has_dianhua then
            currCraft = cfg_data.craft + 1
            currActIndex = i + 1
        end

        if i <= currActIndex then
            item.gameObject:SetActive(true)
        end

        if cfg_data.lev > roleLev then
            break
        end
    end

    local nextItem = self.left_item_list[currActIndex + 1]
    if nextItem ~= nil then
        self.unOpenIndex = currActIndex + 1
        nextItem:UnOpen()
    end

    local temp_name_str2 = self.cur_selected_data.name
    for i=1,#self.cur_selected_data.extra do
         if self.cur_selected_data.extra[i].name == 9 then
            local temp_id = self.cur_selected_data.extra[i].value
            temp_name_str2 = DataItem.data_get[temp_id].name
            break
         end
    end
    local hasOpenAttrList = {}
    for i=1,#self.cur_selected_data.attr do
        if self.cur_selected_data.attr[i].type == 5 then
            table.insert(hasOpenAttrList, self.cur_selected_data.attr[i])
        end
    end
    local last_dianhua_cfg_data = nil
    for i=1,#hasOpenAttrList do
        local temp_has_open_data = hasOpenAttrList[i]
        for j=1,#self.dianhua_list do
            local temp_cfg_data = self.dianhua_list[j]
            if temp_cfg_data.craft ==  temp_has_open_data.flag then
                if last_dianhua_cfg_data == nil then
                    last_dianhua_cfg_data = temp_cfg_data
                elseif last_dianhua_cfg_data.lev < temp_cfg_data.lev then
                    last_dianhua_cfg_data = temp_cfg_data
                end
            end
        end
    end
    if last_dianhua_cfg_data ~= nil then
        local name_str = EquipStrengthManager.Instance.model.dianhua_name[last_dianhua_cfg_data.craft]
        local name_color = EquipStrengthManager.Instance.model.dianhua_color[last_dianhua_cfg_data.craft]
        self.TxtTitle.text = string.format("<color='%s'>%s</color>%s%s", name_color, name_str, TI18N("的"), temp_name_str2)
    else
        self.TxtTitle.text = temp_name_str2
    end

    if self.cur_dianhua_item == nil then
        self.cur_dianhua_item = self.left_item_list[1]
    end
    self:update_right(self.cur_dianhua_item)

    local newH = 58*currActIndex+58
    local rect = self.Container:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(0, newH)
end

--更新右边显示
function EquipStrengthDianhuaTab:update_right(attr_item)
    if self.cur_dianhua_item ~= nil then
        self.cur_dianhua_item:set_selected_state(false)
        if attr_item ~= nil and self.cur_dianhua_item.data.craft ~= attr_item.data.craft then
            self.LockBtn.gameObject:SetActive(false)
            self:SetUnShowLock()
        end
    end

        local txtExtraPropStr = ""
    local craft_cfg_data = nil
    for i=1,#self.dianhua_list do
        if self.dianhua_list[i].craft ==  self.cur_dianhua_item.data.craft then
            craft_cfg_data = self.dianhua_list[i]
            break
        end
    end
    local list = craft_cfg_data.attr_type
    for i=1,#list do
        local cfg_data = list[i]
        if txtExtraPropStr == "" then
            txtExtraPropStr = string.format("%s%s", TI18N("可出现属性:"), KvData.attr_name[cfg_data.attr_name])
        else
            txtExtraPropStr = string.format("%s、%s", txtExtraPropStr, KvData.attr_name[cfg_data.attr_name])
        end
    end
    self.txtExtraProp.text = txtExtraPropStr


    self.cur_dianhua_item = attr_item
    self.cur_dianhua_item:set_selected_state(true)

    local temp_name_str = ColorHelper.color_item_name(self.cur_selected_data.quality, self.cur_selected_data.name)

    local cur_shenqi_id = 0
    for i=1,#self.cur_selected_data.extra do
         if self.cur_selected_data.extra[i].name == 9 then
            cur_shenqi_id = self.cur_selected_data.extra[i].value
            temp_name_str = ColorHelper.color_item_name(DataItem.data_get[cur_shenqi_id].quality, DataItem.data_get[cur_shenqi_id].name)
            break
         end
    end

    if cur_shenqi_id ~= self.last_shenqi_id and cur_shenqi_id ~= 0 and self.show_get_new_shenqi then
        -- EquipStrengthManager.Instance.model:OpenEquipDianhuaGetsUI(cur_shenqi_id)
        self.show_get_new_shenqi = false
    end
    self.last_shenqi_id = cur_shenqi_id

    self.Right_TxtTitle.text = temp_name_str

    --设置顶部神器图标
    self:set_stone_slot_data(self.top_slot, self.cur_selected_data, true)

    --设置星星
    self.StarCon.gameObject:SetActive(true)
    for i=1,#self.star_list do
        local star = self.star_list[i]
        star.gameObject:SetActive(false)
    end

    local star_num = 5
    local fenzi = self.cur_dianhua_item.fenzi
    local fenmu = self.cur_dianhua_item.fenmu

    local new_x = self.star_con_x[star_num]
    self.StarCon.anchoredPosition = Vector2(new_x, -126)

    self.light_star_num = EquipStrengthManager.Instance.model:GetStarCount(fenzi, fenmu, self.cur_dianhua_item.data.looks_active_val)

    self.top_right_effect_2:SetActive(self.light_star_num >= 4)

    self.star_txtdesc.text = string.format("%s%s" , EquipStrengthManager.Instance.model.dianhua_name[self.cur_dianhua_item.data.craft], TI18N("完美度"))
    for i,star in ipairs(self.star_list) do
        star.gameObject:SetActive(true)
        if i <= self.light_star_num then
            star.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "star")
        else
            star.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "Achievement_StarBg")
        end
    end

    local roleLev = RoleManager.Instance.RoleData.lev
    if roleLev < 100 and RoleManager.Instance.RoleData.lev_break_times > 0 then
        roleLev = 100
    end

    --设置属性
    local noSaveAttr = self.cur_selected_data.superCache[self.cur_dianhua_item.data.craft]
    if noSaveAttr ~= nil then
        --有得保存
        self.savaBtn:SetActive(true)
        self.BtnDianhuaRect.anchoredPosition = Vector2(-55, -98)
        self.savaBtn.transform.anchoredPosition = Vector2(55, -98)
        self.BtnDianhua_Text.text = TI18N("精炼")
        -- self.BtnDianhua.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        local attr = EquipStrengthManager.Instance.model:get_equip_dianhua_attr(self.cur_selected_data, self.cur_dianhua_item.data)
        if attr ~= nil then
            self.TxtDesc1.text = string.format(TI18N("<color='#3166ad'>%s</color><color='#248813'>+%s</color><color='#c3692c'>(原属性)</color>"), KvData.attr_name[attr.name], attr.val)
            self.TxtDesc1.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-4, -86.6)
        end
        self.TxtDesc2.text = string.format(TI18N("<color='#3166ad'>%s</color><color='#248813'>+%s</color><color='#c3692c'>(未保存)</color>"), KvData.attr_name[noSaveAttr.name], noSaveAttr.val)

        self.NewStarCon:SetActive(true)
        local new_star_num = EquipStrengthManager.Instance.model:GetStarCount(noSaveAttr.val, fenmu, self.cur_dianhua_item.data.looks_active_val)
        for i,star in ipairs(self.new_star_list) do
            star.gameObject:SetActive(true)
            if i <= new_star_num then
                star.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "star")
            else
                star.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "Achievement_StarBg")
            end
        end
        self.star_txtdesc.text = TI18N("原完美度")
        self.new_star_txtdesc.text = TI18N("新完美度")
        self.star_rect.anchoredPosition = Vector2(12, -126)
        self.new_star_rect.anchoredPosition = Vector2(12, -148)
    else
        self.NewStarCon:SetActive(false)
        self.star_rect.anchoredPosition = Vector2(30, -151)
        self.savaBtn:SetActive(false)
        self.BtnDianhuaRect.anchoredPosition = Vector2(0, -98)

        if EquipStrengthManager.Instance.model:check_changeclasses_dianhua(self.cur_selected_data, self.cur_dianhua_item.data.craft) then
            self.BtnDianhua_Text.text = TI18N("免费重置")
            -- self.BtnDianhua.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        else
            self.BtnDianhua_Text.text = TI18N("精炼")
            -- self.BtnDianhua.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
        end
        self.TxtDesc1.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-4, -105.8)
        self.TxtDesc2.text = ""

        if roleLev >= self.cur_dianhua_item.data.lev then
            self.TxtDesc1.text = string.format("<color='#c7f9ff'>%s</color>", TI18N("可精炼"))
        else
            --未达到开启等级
            if RoleManager.Instance.RoleData.lev_break_times ~= 0 and self.cur_dianhua_item.data.lev >= 95 and self.cur_dianhua_item.data.lev <= 100 then
                --已经突破过
                local currCraft =self.cur_dianhua_item.data.craft - 1
                if currCraft <= 0 then
                    self.TxtDesc1.text = string.format("<color='#c7f9ff'>%s</color>", TI18N("可精炼"))
                else
                    --检查currCraft品阶是否已经精炼过
                    local has_done = EquipStrengthManager.Instance.model:check_craft_has_done(self.parent.cur_left_selected_data, currCraft)
                    if has_done then
                        self.TxtDesc1.text = string.format("<color='#c7f9ff'>%s</color>", TI18N("可精炼"))
                    else
                        local name_str = EquipStrengthManager.Instance.model.dianhua_name[currCraft]
                        local name_color = EquipStrengthManager.Instance.model.dianhua_color[currCraft]
                        self.TxtDesc1.text = string.format(TI18N("精炼至<color='%s'>%s</color>开启"), name_color, name_str)
                    end
                end
            else
                self.TxtDesc1.text = string.format("%s%s", self.cur_dianhua_item.data.lev, TI18N("级开启"))
            end
        end

        for i=1,#self.cur_selected_data.attr do
            local attr_data = self.cur_selected_data.attr[i]
            if attr_data.type == 5 then
                if attr_data.flag == attr_item.data.craft then
                    --已经精炼过
                    self.TxtDesc1.text = string.format(TI18N("<color='#3166ad'>%s</color><color='#248813'>+%s</color><color='#c3692c'>(最大可+%s)</color>"), KvData.attr_name[attr_data.name], attr_data.val, self.cur_dianhua_item.fenmu)
                    break
                end
            end
        end
    end

    --消耗降低区间
    self:ConsumptionReductionInterval()


    --锁逻辑
    if EquipStrengthManager.Instance.model:check_craft_has_done(self.parent.cur_left_selected_data, self.cur_dianhua_item.data.craft) then
        --已经精炼过
        local tempCfgData = EquipStrengthManager.Instance.model:get_equiip_dianhua_data(self.cur_selected_data.type, RoleManager.Instance.RoleData.classes, self.cur_dianhua_item.data.craft)
        if tempCfgData ~= nil and tempCfgData.lockable == 1 then
            --可以锁的
            self.LockBtn.gameObject:SetActive(true)
            if self.lockState == 0 then
                self.lockImg.gameObject:SetActive(false)
                self.unLockImg.gameObject:SetActive(true)
            else
                self.lockImg.gameObject:SetActive(true)
                self.unLockImg.gameObject:SetActive(false)
            end
            local baseData = DataItem.data_get[tempCfgData.lock_loss[1][1]]
            local hasNum = BackpackManager.Instance:GetItemCount(tempCfgData.lock_loss[1][1])
            local lossNum = tempCfgData.lock_loss[1][2]
            lossNum = math.max(math.floor(lossNum*self.percent +0.5), 1)
            self:set_stone_slot_data(self.bottom_lock_slot, baseData, true)
            self.LockTxtName.text = baseData.name
            if EquipStrengthManager.Instance.model:check_changeclasses_dianhua(self.cur_selected_data, self.cur_dianhua_item.data.craft) then
                self.bottom_lock_slot:SetNum(hasNum, 0, true)
            else
                self.bottom_lock_slot:SetNum(hasNum, lossNum)
            end
        else
            self.LockBtn.gameObject:SetActive(false)
            self:SetUnShowLock()
        end
    else
        self.LockBtn.gameObject:SetActive(false)
        self:SetUnShowLock()
    end

    --设置底部消耗
    local base_data = DataItem.data_get[attr_item.data.loss[1][1]]
    local has_num = BackpackManager.Instance:GetItemCount(base_data.id)
    local cost_num = attr_item.data.loss[1][2]
    local lossNum = math.floor(cost_num*self.percent +0.5)
    self.TxtName.text = base_data.name
    self:set_stone_slot_data(self.bottom_slot, base_data, true)
    local needNum = 0
    if EquipStrengthManager.Instance.model:check_changeclasses_dianhua(self.cur_selected_data, self.cur_dianhua_item.data.craft) then
        self.bottom_slot:SetNum(has_num, 0, true)
    else
        needNum = lossNum
        self.bottom_slot:SetNum(has_num, lossNum)
    end
    local buyList = {}

    if DataMarketGold.data_market_gold_exchange[attr_item.data.loss[1][1]] ~= nil then
        local cfgData = DataMarketGold.data_market_gold_exchange[attr_item.data.loss[1][1]]
        if BackpackManager.Instance:GetItemCount(attr_item.data.loss[1][1]) >= needNum then
            buyList = {[attr_item.data.loss[1][1]] = {need = needNum}}
            self.dianHuaCostData = {id = attr_item.data.loss[1][1], num = needNum}
        else
            buyList = {[cfgData.exchange_id] = {need = cfgData.exchange_num*needNum}}
            self.dianHuaCostData = {id = cfgData.exchange_id, num = cfgData.exchange_num*needNum}
        end
    else
        buyList = {[attr_item.data.loss[1][1]] = {need = needNum}}
        self.dianHuaCostData = {id = attr_item.data.loss[1][1], num = needNum}
    end

    self.dianHuaBuyBtn:Layout(buyList, self.onClickDianhua , self.onDianhuaPriceBack)

    self.BtnDianhua_point:SetActive(false)

    local roleLev = RoleManager.Instance.RoleData.lev
    if roleLev < 100 and RoleManager.Instance.RoleData.lev_break_times > 0 then
        roleLev = 100
    end

    for i=1,#self.dianhua_list do
        local cfg_data = self.dianhua_list[i]
        if cfg_data.craft == attr_item.data.craft then
            if cfg_data.lev <= roleLev and attr_item.has_dianhua == false then
                if has_num >= cost_num then
                    self.BtnDianhua_point:SetActive(true)
                end
            end
            break
        end
    end

    self.tips:SetActive(false)
    if self.cur_dianhua_item.data.looks == 0 then
        return
    end

    local nextItemData = DataItem.data_get[self.cur_dianhua_item.data.looks]
    if nextItemData ~= nil then
        self.tips:SetActive(true)
        if self.light_star_num >= 4 then
            self.tipsTxt.text = string.format(TI18N("<color='#c7f9ff'>已激活神器外观:</color>%s"), ColorHelper.color_item_name(nextItemData.quality, nextItemData.name))
        else
            self.tipsTxt.text = string.format(TI18N("<color='#c7f9ff'>4星可激活神器外观:</color>%s"), ColorHelper.color_item_name(nextItemData.quality, nextItemData.name))
        end
    end
end

----------------------辅助函数
--为每个武器创建slot
function EquipStrengthDianhuaTab:create_equip_slot(slot_con)
    local stone_slot = ItemSlot.New()
    stone_slot.gameObject.transform:SetParent(slot_con.transform)
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
function EquipStrengthDianhuaTab:set_stone_slot_data(slot, data, _nobutton)
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

function EquipStrengthDianhuaTab:Save()
    local curBadgeId = EquipStrengthManager.Instance.model:GetCurEquipBadge()
    local noSaveAttr = self.cur_selected_data.superCache[self.cur_dianhua_item.data.craft]
    local fenmu = self.cur_dianhua_item.fenmu
    local new_star_num = 0
    if noSaveAttr ~= nil then
        new_star_num = EquipStrengthManager.Instance.model:GetStarCount(noSaveAttr.val, fenmu, self.cur_dianhua_item.data.looks_active_val)
    end
    local str = ""
    if curBadgeId ~= 0 and new_star_num < 4 and self.cur_dianhua_item.data.craft <= curBadgeId then
        local cfgData = DataEqm.data_dianhua_suit[string.format("%s_%s", curBadgeId, RoleManager.Instance.RoleData.classes)]
        if cfgData.ignore ~= 0 then
            local model = EquipStrengthManager.Instance.model
            str = string.format(TI18N("保存低★属性后，<color='#00ff00'>[%s精炼徽章]</color>将失效，是否保存？<color='#c3692c'>（建议精炼至4★或以上再作保存）</color>"), model.dianhua_name[curBadgeId])
        end
    end
    if str == "" then
        self.show_get_new_shenqi = true
        EquipStrengthManager.Instance:request10618(self.cur_selected_data.id, self.cur_dianhua_item.data.craft, self.light_star_num)
    else
        local confirmData = NoticeConfirmData.New()
        confirmData.type = ConfirmData.Style.Normal
        confirmData.sureLabel = TI18N("保存")
        confirmData.cancelLabel = TI18N("取消")
        confirmData.sureCallback = function()
            self.show_get_new_shenqi = true
            EquipStrengthManager.Instance:request10618(self.cur_selected_data.id, self.cur_dianhua_item.data.craft, self.light_star_num)
        end
        confirmData.content = str
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end

function EquipStrengthDianhuaTab:OnBtnDianhua()
    local roleLev = RoleManager.Instance.RoleData.lev
    if roleLev < 100 and RoleManager.Instance.RoleData.lev_break_times > 0 then
        roleLev = 100
    end

    if self.cur_dianhua_item.data.lev > roleLev then
        NoticeManager.Instance:FloatTipsByString(TI18N("尚未开启"))
        return
    end

    if EquipStrengthManager.Instance.model:check_changeclasses_dianhua(self.cur_selected_data, self.cur_dianhua_item.data.craft) then
            self.click_dianhua = true
            EquipStrengthManager.Instance:request10617(self.cur_selected_data.id, self.cur_dianhua_item.data.craft, self.lockState)
    else
        self.click_dianhua = true
        EquipStrengthManager.Instance:request10617(self.cur_selected_data.id, self.cur_dianhua_item.data.craft, self.lockState)
    end
end

--加锁
function EquipStrengthDianhuaTab:OnBtnLock()
    if self.lockState == 0 then
        local attrName = ""
        local min = 0
        local max = 1
        if self.cur_selected_data ~= nil and self.cur_dianhua_item ~= nil then
            local attr = EquipStrengthManager.Instance.model:get_equip_dianhua_attr(self.cur_selected_data, self.cur_dianhua_item.data)
            if attr ~= nil then
                attrName = KvData.attr_name[attr.name]
                local tempList = EquipStrengthManager.Instance.model:get_equip_dianhua_list(self.cur_selected_data.type, RoleManager.Instance.RoleData.classes)
                for k, v in pairs(tempList) do
                    if v.craft == self.cur_dianhua_item.data.craft then
                        min = v.min_val
                        max = v.max_val
                    end
                end
            end
        end

        local str = string.format(TI18N("消耗<color='#00ff00'>属性原石</color>进行精炼，可以锁定现有的<color='#00ff00'>%s</color>可精炼结果为：<color='#c3692c'>%s %s~%s</color>"), attrName, attrName, min, max)
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = str
        data.sureLabel = TI18N("确定")
        data.sureCallback = function()
            --没锁，变成锁状态
            self.BottomCostCon:GetComponent(RectTransform).anchoredPosition = Vector2(0, -11.3)
            self.lockState = 1
            self.lockImg.gameObject:SetActive(true)
            self.unLockImg.gameObject:SetActive(false)
            self.Bottom_LockSlotCon:SetActive(true)
            self.intervalTipsBtn:GetComponent(RectTransform).anchoredPosition = Vector2(186, -95)
        end
        NoticeManager.Instance:ConfirmTips(data)
    else
        --变成没锁状态
        self.lockImg.gameObject:SetActive(false)
        self.unLockImg.gameObject:SetActive(true)
        self:SetUnShowLock()
    end
end

--切换锁的状态
--切换锁的状态
function EquipStrengthDianhuaTab:SetUnShowLock()
    if self.has_init ~= true then
        return
    end

    --设置属性
    self.TxtDesc1.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-4, -105.8)
    self.TxtDesc2.text = ""
    if self.cur_dianhua_item ~= nil and self.cur_selected_data ~= nil then
        local noSaveAttr = self.cur_selected_data.superCache[self.cur_dianhua_item.data.craft]
        if noSaveAttr ~= nil then
            --有得保存
            local attr = EquipStrengthManager.Instance.model:get_equip_dianhua_attr(self.cur_selected_data, self.cur_dianhua_item.data)
            if attr ~= nil then
                self.TxtDesc1.text = string.format(TI18N("<color='#3166ad'>%s</color><color='#248813'>+%s</color><color='#c3692c'>(原属性)</color>"), KvData.attr_name[attr.name], attr.val)
                self.TxtDesc1.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-4, -86.6)
            end
            self.TxtDesc2.text = string.format(TI18N("<color='#3166ad'>%s</color><color='#248813'>+%s</color><color='#c3692c'>(未保存)</color>"), KvData.attr_name[noSaveAttr.name], noSaveAttr.val)
        end
    end
    self.lockState = 0
    self.Bottom_LockSlotCon:SetActive(false)
    self.BottomCostCon:GetComponent(RectTransform).anchoredPosition = Vector2(50, -11.3)
    self.intervalTipsBtn:GetComponent(RectTransform).anchoredPosition = Vector2(141, -95)
end

function EquipStrengthDianhuaTab:CheckGuidePoint()
    TipsManager.Instance:ShowGuide({gameObject = self.BtnDianhua.gameObject, data = TI18N("点击按钮精炼装备"), forward = TipsEumn.Forward.Up})

    if self.guideEffect == nil then
        self.guideEffect = BibleRewardPanel.ShowEffect(20104,self.BtnDianhua.transform,Vector3(0.9,0.9,1), Vector3(0,0,-400))
    end
    self.guideEffect:SetActive(true)
end

function EquipStrengthDianhuaTab:HideGuideEffect()
    if self.guideEffect ~= nil then
        self.guideEffect:SetActive(false)
    end
end

function EquipStrengthDianhuaTab:ChangeClasses()
    self.dianhua_list = EquipStrengthManager.Instance.model:get_equip_dianhua_list(self.cur_selected_data.type, RoleManager.Instance.RoleData.classes)
end

--神器点化折扣
function EquipStrengthDianhuaTab:ConsumptionReductionInterval()
    local interval = 0 --(0:正常区间, 1:第一档，2:第二档)
    self.percent = 1
    local world_lev = RoleManager.Instance.world_lev
    if world_lev < 90 then return end
    local baseData = DataBacksmith.data_get_comprehend_discount[world_lev]

    local craft = self.cur_dianhua_item.data.craft

    if craft <= baseData.min_craft then
        interval = 1
        self.percent = baseData.min_discount/100.0
    elseif craft > baseData.min_craft and craft <= baseData.max_craft then
        interval = 2
        self.percent = baseData.max_discount/100.0
    end
    self.intervalTipsBtn.gameObject:SetActive(interval ~= 0)
end
