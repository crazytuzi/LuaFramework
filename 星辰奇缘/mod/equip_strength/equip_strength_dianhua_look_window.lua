EquipStrengthDianhuaLookWindow  =  EquipStrengthDianhuaLookWindow or BaseClass(BasePanel)

function EquipStrengthDianhuaLookWindow:__init(model)
    self.name  =  "EquipStrengthDianhuaLookWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.equip_strength_dianhua_look_win, type  =  AssetType.Main}
    }

    self.width = 315
    self.height = 0

    self.minScale = 0.8
    self.maxScale = 1.05

    self.txtTab = {}

    return self
end


function EquipStrengthDianhuaLookWindow:__delete()
    self.itemCell:DeleteMe()
    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function EquipStrengthDianhuaLookWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_dianhua_look_win))
    self.gameObject.name  =  "EquipStrengthDianhuaLookWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform.localPosition = Vector3(0, 0, -570)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseEquipDianhuaLooksUI() end)

    self.MainCon = self.transform:Find("MainCon")

    self.rect = self.MainCon:GetComponent(RectTransform)

    local head = self.MainCon:Find("HeadArea")
    self.itemCell = ItemSlot.New(head:Find("ItemSlot").gameObject)
    self.itemCell:SetNotips()
    self.itemCell:ShowEnchant(true)
    self.itemCell:ShowLevel(true)
    self.nameTxt = head:Find("Name"):GetComponent(Text)
    self.levelTxt = head:Find("Level"):GetComponent(Text)


    self.midImgArrow = self.MainCon:Find("ImgArrow").gameObject

    local mid = self.MainCon:Find("MidArea")
    self.midTransform = mid.transform
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.ScrollRect = mid:Find("ScrollRect")
    self.Container = self.ScrollRect:Find("Container")
    self.baseTxt = self.Container:Find("BaseText").gameObject
    self.baseTxt:SetActive(false)

    self:update_info(self.model.dianhua_look_info)
end



function EquipStrengthDianhuaLookWindow:update_info(info)

    self.itemData = info

    local name_str = ColorHelper.color_item_name(info.quality, info.name)
    if info ~= nil and info.extra ~= nil then
        --装备神器图标统一处理
        for i=1,#info.extra do
             if info.extra[i].name == 9 then
                local temp_id = info.extra[i].value
                name_str = ColorHelper.color_item_name(DataItem.data_get[temp_id].quality, DataItem.data_get[temp_id].name)
                break
             end
        end
    end


    self.nameTxt.text = name_str
    self.levelTxt.text = string.format(TI18N("部位:%s"), BackpackEumn.GetEquipNameByType(info.type))
    self.itemCell:SetAll(info)
    self.itemCell:ShowEnchant(true)
    self.itemCell:ShowLevel(true)

    --加上上部分的高度
    self.height = 80

    self:UpdateAttr()

    self.height = self.height + 80

    self.rect.sizeDelta = Vector2(self.width, self.height)
    self.gameObject:SetActive(true)

    -- self.rect.anchoredPosition = Vector2(nx, ny)
end


function EquipStrengthDianhuaLookWindow:UpdateAttr()
    for i,v in ipairs(self.txtTab) do
        v.gameObject:SetActive(false)
    end

    self.midImgArrow:SetActive(false)

    local hasOpenAttrList = {}
    for i=1,#self.itemData.attr do
        if self.itemData.attr[i].type == 5 then
            table.insert(hasOpenAttrList, self.itemData.attr[i])
        end
    end

    local hh = 0
    local temp_talent_h = 0
    local useCount = 0

    --------精炼属性
    useCount = useCount + 1
    local tab = self:GetItem(useCount)
    --string.format("<color='%s'>%s%s:</color>", self.model.dianhua_color[self.model.dianhua_look_craft], self.model.dianhua_name[self.model.dianhua_look_craft], TI18N("属性"))
    tab.txt.text = string.format("<color='%s'>%s%s:</color>", self.model.dianhua_color[self.model.dianhua_look_craft], self.model.dianhua_name[self.model.dianhua_look_craft], TI18N("属性"))
    tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
    tab.rect.anchoredPosition = Vector2(0, -hh)
    hh = hh + 25


    local ok_len = 0
    for i,v in ipairs(hasOpenAttrList) do
        if v.flag == self.model.dianhua_look_craft then
            ok_len = ok_len + 1
            useCount = useCount + 1
            local tab = self:GetItem(useCount)
            tab.txt.text = string.format("<color='#01c0ff'>%s</color><color='#4dd52b'>+%s</color> ",  KvData.attr_name[v.name], v.val)
            tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
            tab.rect.anchoredPosition = Vector2(0, -hh - (ok_len - 1) * 25)
            -- print("----------------------------进来了")
        end
    end
    hh = hh + 25 * ok_len


    local cfg_data_list = self.model:get_equip_dianhua_list(self.itemData.type, RoleManager.Instance.RoleData.classes)
    local craft_cfg_data = nil
    for i=1,#cfg_data_list do
        if cfg_data_list[i].craft == self.model.dianhua_look_craft then
            craft_cfg_data = cfg_data_list[i]
            break
        end
    end



    ---可出现属性：
    local list = craft_cfg_data.attr_type


    if #list > 0 then
        useCount = useCount + 1
        local tab = self:GetItem(useCount)
        tab.txt.text = TI18N("<color='#ffff00'>可出现属性:</color>")
        tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
        tab.rect.anchoredPosition = Vector2(0, -hh)
        hh = hh + 25
    end
    for i=1,#list do
        useCount = useCount + 1
        local temp_data = list[i]
        local tab = self:GetItem(useCount)
        -- tab.txt.fontSize = 16
        tab.txt.text = string.format("<color='#00ffff'>%s %s~%s</color>", KvData.attr_name[temp_data.attr_name] ,craft_cfg_data.min_val, craft_cfg_data.max_val)
        local w = tab.txt.preferredWidth
        local h = 25
        if w > 250 then
            h = math.ceil(w / 250) * 25
            w = 250
        end
        tab.rect.sizeDelta = Vector2(w, h)
        tab.rect.anchoredPosition = Vector2(0, -hh)
        hh = hh + h
    end


    --------------可出现神器外观：
    --如果选中的品阶是当前已精炼最高的则出现该神器外观
    local show_shenqi = true
    local last_dianhua_cfg_data = nil

    --找到当前已精炼的最高等级的品阶
    for i=1,#hasOpenAttrList do
        local temp_has_open_data = hasOpenAttrList[i]
        for j=1,#cfg_data_list do
            local temp_cfg_data = cfg_data_list[j]
            if temp_cfg_data.craft ==  temp_has_open_data.flag then
                if last_dianhua_cfg_data == nil then
                    last_dianhua_cfg_data = temp_cfg_data
                elseif last_dianhua_cfg_data.lev < temp_cfg_data.lev then
                    last_dianhua_cfg_data = temp_cfg_data
                end
            end
        end
    end

    if show_shenqi then
        local talent_list = craft_cfg_data.looks
        if talent_list ~= 0 then
            self.midImgArrow:SetActive(true)
            useCount = useCount + 1
            local tab = self:GetItem(useCount)
            tab.txt.text = TI18N("<color='#ffff00'>可出现神器外观:</color>")
            tab.rect.sizeDelta = Vector2(tab.txt.preferredWidth, 25)
            tab.rect.anchoredPosition = Vector2(0, -hh)
            hh = hh + 25


            temp_talent_h = hh
            useCount = useCount + 1
            local shenqi_tab_str = ""
            local shenqi_tab = self:GetItem(useCount)
            -- shenqi_tab.txt.fontSize = 16
            local temp_base_data = DataItem.data_get[talent_list]

            if shenqi_tab_str ~= "" then
                shenqi_tab_str = string.format("%s <color='#d781f2'>%s</color>", shenqi_tab_str, temp_base_data.name)
            else
                shenqi_tab_str = string.format("<color='#d781f2'>%s</color>", temp_base_data.name)
            end
            shenqi_tab.txt.text = shenqi_tab_str
            local w = shenqi_tab.txt.preferredWidth
            local h = 25
            if w > 250 then
                h = math.ceil(w / 250) * 25
                w = 250
            end
            shenqi_tab.rect.sizeDelta = Vector2(w, h)
            shenqi_tab.rect.anchoredPosition = Vector2(0, -temp_talent_h)
            temp_talent_h = temp_talent_h + h
        end
    end



    --调整总体大小
    self.Container:GetComponent(RectTransform).sizeDelta = Vector2(250, temp_talent_h)
    self.midRect.sizeDelta = Vector2(250, hh+25)
    self.height = self.height + hh
end

function EquipStrengthDianhuaLookWindow:GetItem(index)
    local tab = self.txtTab[index]
    if tab == nil then
        tab = {}
        tab.gameObject = GameObject.Instantiate(self.baseTxt)
        tab.gameObject.name = "Txt"..index
        tab.transform = tab.gameObject.transform
        tab.transform:SetParent(self.Container)
        tab.transform.localScale = Vector3.one
        tab.rect = tab.gameObject:GetComponent(RectTransform)
        tab.txt = tab.gameObject:GetComponent(Text)
        -- tab.txt.fontSize = 18
        table.insert(self.txtTab, tab)
    end
    tab.gameObject:SetActive(true)
    return tab
end
