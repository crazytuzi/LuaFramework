ShouhuLookEquipWindow  =  ShouhuLookEquipWindow or BaseClass(BasePanel)

function ShouhuLookEquipWindow:__init(model)
    self.name  =  "ShouhuLookEquipWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.shouhu_look_equip_win, type  =  AssetType.Main}
    }

    self.myData = nil
    self.selectedEquipData = nil
    self.current_equip_index = 0

    self.hasClickUpdate = false--记录是否点击了升级按钮
    self.hasClickReset = false--记录是否点击了重置按钮
    self.leftEquipSlot = nil
    self.rightEquipSlot = nil
    self.is_open = false
    self.myData = nil
    self.current_equip_index = 0
    self.selectedEquipData = nil

    self.right_has_open = false
    self.right_stone_has_open = false
    self.last_opera = 0

    self.show_tips = false

    return self
end

function ShouhuLookEquipWindow:__delete()
    self.leftEquipSlot:DeleteMe()
    self.myData = nil
    self.selectedEquipData = nil
    self.current_equip_index = 0

    self.hasClickUpdate = false--记录是否点击了升级按钮
    self.hasClickReset = false--记录是否点击了重置按钮
    self.leftEquipSlot = nil
    self.rightEquipSlot = nil
    self.is_open = false
    self.myData = nil
    self.current_equip_index = 0
    self.selectedEquipData = nil

    self.is_open = false

    self.right_has_open = false
    self.right_stone_has_open = false
    self.last_opera = 0

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function ShouhuLookEquipWindow:InitPanel()
    self.is_open = true

    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_look_equip_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ShouhuLookEquipWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.Panel_btn = self.transform:FindChild("Panel"):GetComponent(Button)

    self.Panel_btn.onClick:AddListener(function() self.model:CloseShouhuLookEquipUI() end)

    self.MainCon = self.transform:FindChild("MainCon").gameObject

    self.ContentCon = self.MainCon.transform:FindChild("ContentCon").gameObject
    local CloseBtn = self.ContentCon.transform:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseShouhuLookEquipUI() end)

    self.LeftCon = self.ContentCon.transform:FindChild("LeftCon").gameObject
    self.left_tips_con = self.ContentCon.transform:FindChild("TipsCon").gameObject
    self.tips_con_ly = self.left_tips_con.transform:GetComponent(LayoutElement)
    self.tips_prop_list = {}
    self.tips_prop_position_list = {}
    for i=1, 11 do
        local tips_prop = self.left_tips_con.transform:FindChild(string.format("Prop%s", i-1)):GetComponent(Text)
        table.insert(self.tips_prop_position_list, tips_prop.transform:GetComponent(RectTransform).anchoredPosition)
        table.insert(self.tips_prop_list, tips_prop)
    end

    self.TopCon = self.LeftCon.transform:FindChild("TopCon").gameObject
    self.ImgEye = self.TopCon.transform:FindChild("ImgEye"):GetComponent(Button)
    self.HeadCon = self.TopCon.transform:FindChild("HeadCon").gameObject
    self.TxtName = self.TopCon.transform:FindChild("TxtName"):GetComponent(Text)
    self.Txtlev = self.TopCon.transform:FindChild("TxtLev"):GetComponent(Text)

    self.RItem0 = self.LeftCon.transform:FindChild("Item0").gameObject
    self.tProp0=self.RItem0.transform:FindChild("Prop0"):GetComponent(Text)
    self.tProp1=self.RItem0.transform:FindChild("Prop1"):GetComponent(Text)
    self.tProp2=self.RItem0.transform:FindChild("Prop2"):GetComponent(Text)
    self.tProp3=self.RItem0.transform:FindChild("Prop3"):GetComponent(Text)
    self.tProp4=self.RItem0.transform:FindChild("Prop4"):GetComponent(Text)

    self.StonePropCon_Y = {26, 2, -24, -50, -74}
    self.StonePropCon = self.RItem0.transform:FindChild("StonePropCon")
    self.desc11=self.StonePropCon:FindChild("TxtDesc2"):GetComponent(Text)
    self.tProp5=self.StonePropCon:FindChild("Prop5"):GetComponent(Text)
    self.tProp6=self.StonePropCon:FindChild("Prop6"):GetComponent(Text)

    self.desc11.gameObject:SetActive(false)
    self.tProp5.gameObject:SetActive(false)
    self.tProp6.gameObject:SetActive(false)


    -- 注册监听
    self.ImgEye.onClick:AddListener(function() self:on_click_eye_btn() end)

    self:init_view()
end

function ShouhuLookEquipWindow:on_click_eye_btn()
    self.show_tips = not self.show_tips
    self.left_tips_con:SetActive(self.show_tips)
end

function ShouhuLookEquipWindow:init_view()
    self.myData=self.model.my_sh_selected_look_data
    self:update_left(self.model.my_sh_selected_look_equip)
end

-- 更新界面
function ShouhuLookEquipWindow:update_view()
    if self.is_open == false then
        return
    end

    for i=1, #self.myData.equip_list do
        local ed = self.myData.equip_list[i]
        if ed.type==self.selectedEquipData.type then
            self:update_left(ed)
            return
        end
    end
end

---------------------------------------------监听逻辑

function ShouhuLookEquipWindow:update_left(ed)
    if self.is_open == false then
        return
    end
    self.selectedEquipData = ed

    local cfgEqDat = self.model:get_equip_data_by_base_id( self.selectedEquipData.base_id)


    --道具图标
    if self.leftEquipSlot == nil then
        self.leftEquipSlot = ItemSlot.New()
    end
    local cell = ItemData.New()
    local itemData = DataItem.data_get[cfgEqDat.base_id]
    cell:SetBase(itemData)

    self.leftEquipSlot:SetAll(cell, nil)
    self.leftEquipSlot.gameObject.transform:SetParent(self.HeadCon.transform)
    self.leftEquipSlot.gameObject.transform.localScale = Vector3.one
    self.leftEquipSlot.gameObject.transform.localPosition = Vector3.zero
    self.leftEquipSlot.gameObject.transform.localRotation = Quaternion.identity
    local rect = self.leftEquipSlot.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 2)
    rect.localScale = Vector3.one


    self.TxtName.text = itemData.name
    self.Txtlev.text=string.format("%s%s", TI18N("等级："), self.selectedEquipData.lev)

    self.tProp0.text = ""
    self.tProp1.text=""
    self.tProp2.text=""
    self.tProp3.text=""
    self.tProp4.text=""

    self.desc11.gameObject:SetActive(false)
    self.tProp5.gameObject:SetActive(false)
    self.tProp6.gameObject:SetActive(false)

    self:update_left_prop()
end

function ShouhuLookEquipWindow:update_left_prop()
    if self.is_open == false then
        return
    end

    local index_1=0

    local temp_sort = function(a,b)
        return a.name < b.name
    end
    table.sort(self.selectedEquipData.ext_attrs, temp_sort)
    table.sort(self.selectedEquipData.base_attrs, temp_sort)
    table.sort(self.selectedEquipData.eff_attrs, temp_sort)

    --基础属性
    local tips_list = {}
    for k,v in pairs(self.selectedEquipData.base_attrs) do
        local val_str = v.val > 0 and string.format("+%s", v.val) or tostring(v.val)
        local temp_txt = nil
        if index_1 == 0 then
            temp_txt = self.tProp0
        elseif index_1 == 1 then
            temp_txt = self.tProp1
        elseif index_1 == 2 then
            temp_txt = self.tProp2
        end
        if temp_txt ~= nil then
            table.insert(tips_list, v)
            temp_txt.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>%s</color>", KvData.attr_name[v.name], val_str)
            index_1 = index_1 + 1
        end
    end

    ---额外属性
    local has_ext_attrs = false
    for k, v in pairs(self.selectedEquipData.ext_attrs) do
        local val_str = v.val > 0 and string.format("+%s", v.val) or tostring(v.val)
        local str = ""
        local temp_txt = nil
        has_ext_attrs = true
        if index_1 == 1 then
            temp_txt = self.tProp1
        elseif index_1 == 2 then
            temp_txt = self.tProp2
        else
            temp_txt = self.tProp3
        end
        if temp_txt ~= nil then
            table.insert(tips_list, v)
            if str ~= "" then
                temp_txt.text = string.format("%s %s", str, string.format("<color='#23F0F7'>%s%s</color>", KvData.attr_name[v.name], val_str))
            else
                temp_txt.text = string.format("<color='#23F0F7'>%s%s</color> %s", KvData.attr_name[v.name], val_str, temp_txt.text)
            end
            str = temp_txt.text
        end
    end

    -- 特效属性
    if has_ext_attrs then
        index_1 = index_1 + 1
    end
    local has_eff_attrs = false
    for k,v in pairs(self.selectedEquipData.eff_attrs) do
        has_eff_attrs = true
        local str = ""
        local temp_txt = nil
        has_ext_attrs = true
        if index_1 == 1 then
            temp_txt = self.tProp1
        elseif index_1 == 2 then
            temp_txt = self.tProp2
        elseif index_1 == 3 then
            temp_txt = self.tProp3
        elseif index_1 == 4 then
            temp_txt = self.tProp4
        end
        if temp_txt ~= nil then
            local name_str = ""
            if v.name == 100 then
                name_str = string.format("%s", DataSkill.data_skill_effect[v.val].name)
            else
                name_str = KvData.attr_name[v.name]
            end
            if str ~= "" then
                temp_txt.text = string.format("%s %s", str, string.format("<color='#dc83f5'>%s</color>", name_str))
            else
                temp_txt.text = string.format(TI18N("<color='#dc83f5'>特效:%s</color> %s"), name_str, temp_txt.text)
            end
            str = temp_txt.text
        end
    end
    if has_eff_attrs then
        index_1 = index_1 + 1
    end

    --------------tips属性，tips里面不显示宝石属性
    --计算tips的高度
    local new_height_index = #self.selectedEquipData.base_attrs
    local new_height = 0
    if new_height_index == 1 then
        new_height = 106
    elseif new_height_index == 2 then
        new_height = 132
    elseif new_height_index == 3 then
        new_height = 156
    elseif new_height_index == 4 then
        new_height = 186
    end

    --清空上次tips
    for i=1,#self.tips_prop_list do
        self.tips_prop_list[i].text = ""
        self.tips_prop_list[i].transform:GetComponent(RectTransform).sizeDelta = Vector2(195, 25)
        self.tips_prop_list[i].transform:GetComponent(RectTransform).anchoredPosition = self.tips_prop_position_list[i]
    end

    --把配置中的可出现的特效加到tips_list中
    local effect_out_list = self.model:get_can_out_equip_effects(self.selectedEquipData.type, self.selectedEquipData.lev)
    local record_list = {}
    for i=1,#effect_out_list do
        local cfg_data = effect_out_list[i]
        if record_list[cfg_data.val] == nil then
            local temp_data = {type = GlobalEumn.ItemAttrType.effect, name = cfg_data.effect_type, val = cfg_data.val}
            table.insert(tips_list, temp_data)
        end
        record_list[cfg_data.val] = 1
    end

    local tips_index = 1
    local tips_effect_index = 1
    local tips_txt_offset_y = 0
    for i=1,#tips_list do
        local d = tips_list[i]
        local val = self.model.base_prop_vals[string.format("%s_%s", self.selectedEquipData.type, self.selectedEquipData.lev)][d.name]
        local temp_txt = nil
        if val ~= nil then
            --基础属性
            local val_str = d.val > 0 and string.format("+%s", d.val) or tostring(d.val)
            temp_txt = self.tips_prop_list[tips_index]

            if temp_txt ~= nil then
                tips_index = tips_index + 1
                temp_txt.text = string.format("<color='#9DB1B8'>%s</color><color='#ACE92A'>%s</color> %s~%s", KvData.attr_name[d.name], val_str , math.floor(val*0.8), math.floor(val*1.05))
            end
        elseif d.type == GlobalEumn.ItemAttrType.effect then
            local name_str
            --特效属性
            local name_str = ""
            temp_txt = self.tips_prop_list[tips_index]
            if temp_txt ~= nil then
                if tips_effect_index == 1 then
                    tips_index = tips_index + 1
                    name_str = TI18N("<color='#ffff00'>可出现特效:</color>")
                    tips_effect_index = tips_effect_index + 1
                    temp_txt.text = name_str
                end
            end
            temp_txt = self.tips_prop_list[tips_index]
            if temp_txt ~= nil then
                tips_index = tips_index + 1
                local cgf_data = nil
                if d.name == 100 then
                    -- 技能
                    cgf_data = DataSkill.data_skill_effect[d.val]
                elseif d.name == 150 then
                -- 易强化
                    cgf_data = DataSkill.data_skill_effect[81019]
                elseif d.name == 151 then
                -- 易成长
                    cgf_data = DataSkill.data_skill_effect[81020]
                end
                name_str = string.format("<color='#dc83f5'>%s</color>:<color='#23F0F7'>%s</color>", cgf_data.name, cgf_data.desc)

                temp_txt.text = name_str
            end

            --自适应一下
            if temp_txt ~= nil then
                local cur_position = temp_txt.transform:GetComponent(RectTransform).anchoredPosition
                local line_num = 1
                if temp_txt.preferredWidth > 195 then
                    line_num = math.ceil(temp_txt.preferredWidth/195)
                    temp_txt.transform:GetComponent(RectTransform).sizeDelta = Vector2(195, line_num*20)
                else
                    temp_txt.transform:GetComponent(RectTransform).sizeDelta = Vector2(195, 20)
                end
                new_height = new_height + line_num*22
                local new_y = cur_position.y + tips_txt_offset_y
                temp_txt.transform:GetComponent(RectTransform).anchoredPosition = Vector2(cur_position.x, new_y)
                tips_txt_offset_y = tips_txt_offset_y - (line_num-1)*20
            end
        end
    end
    self.tips_con_ly.preferredWidth = 250
    self.tips_con_ly.preferredHeight = 402 --new_height

    -------------宝石属性
    self.StonePropCon:GetComponent(RectTransform).anchoredPosition = Vector2(0, self.StonePropCon_Y[index_1])
    self.desc11.gameObject:SetActive(false)
    self.tProp5.gameObject:SetActive(false)
    self.tProp6.gameObject:SetActive(false)


    if #self.selectedEquipData.gem > 0 then
        self.desc11.gameObject:SetActive(true)
        self.tProp5.gameObject:SetActive(true)
        self.tProp6.gameObject:SetActive(true)
        self.tProp5.text = ""
        self.tProp6.text = ""
    end
    for i=1,#self.selectedEquipData.gem do
        local d = self.selectedEquipData.gem[i]
        local cfg_data = DataShouhu.data_guard_stone_prop[d.base_id]
        if i==1 then
            self.tProp5.text = string.format("<color='#23F0F7'>%s+%s   (%s%s%s)</color>", KvData.attr_name[cfg_data.attrs[1].attr], cfg_data.attrs[1].val, cfg_data.lev, TI18N("级") , cfg_data.name)
        elseif i ==2 then
            self.tProp6.text = string.format("<color='#23F0F7'>%s+%s   (%s%s%s)</color>", KvData.attr_name[cfg_data.attrs[1].attr], cfg_data.attrs[1].val, cfg_data.lev, TI18N("级") , cfg_data.name)
        end
    end
end
