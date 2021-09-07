SkillViewTabThree = SkillViewTabThree or BaseClass(BasePanel)

function SkillViewTabThree:__init(parent)
    self.parent = parent
    local args = self.parent.openArgs
    if args ~= nil then
        self.select_item_id = args.id
    end
    self.model = parent.model
    self.name = "SkillViewTabThree"
    self.resList = {
        {file = AssetConfig.skill_life, type = AssetType.Main}
        ,{file = AssetConfig.skill_life_name, type = AssetType.Dep}
        ,{file = AssetConfig.skill_life_icon, type = AssetType.Dep}
        ,{file = AssetConfig.skill_life_shovel_bg, type = AssetType.Dep}
    }



    self.cfg_data_max_lev = 90
    self.current_selected_item = nil
    self.current_more_data_list = nil
    self.current_line_list = nil
    self.more_show = false
    self.item_list = nil
    self.l_item_list = nil
    self.l_item_slots = nil
    self.more_item_slots = nil
    self.is_open = false

    self.lossGuild = false   --记录公会贡献够不够（false 足够）
    self.lossGuildTen = false   --记录公会贡献够不够（10连抽哟）（false 足够）
    self.OnOpenEvent:Add(function() self:OnShow() end)
end

function SkillViewTabThree:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:Release()
        end
    end
    self.Item3_Slot1:DeleteMe()

    if self.l_item_slots ~= nil then
        for k, v in pairs(self.l_item_slots) do
            v:DeleteMe()
        end
    end

    self.ImgName.sprite = nil
    self.ImgShovel.sprite = nil
    self.cfg_data_max_lev = 80
    self.current_selected_item = nil
    self.current_more_data_list = nil
    self.current_line_list = nil
    self.more_show = false
    self.item_list = nil
    self.l_item_list = nil
    self.l_item_slots = nil
    self.more_item_slots = nil
    self.is_open = false

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function SkillViewTabThree:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skill_life))
    self.gameObject.name = "SkillViewTabThree"
    self.transform = self.gameObject.transform

    UIUtils.AddUIChild(self.parent.mainTransform.gameObject, self.gameObject)

    self.Main = self.transform:FindChild("Main").gameObject
    self.LeftCon = self.Main.transform:FindChild("LeftCon").gameObject
    self.MaskLayer = self.LeftCon.transform:FindChild("MaskLayer").gameObject
    self.ScrollLayer = self.MaskLayer.transform:FindChild("ScrollLayer").gameObject
    self.LayoutLayer_Con = self.ScrollLayer.transform:FindChild("LayoutLayer").gameObject
    self.Item = self.LayoutLayer_Con.transform:FindChild("Item").gameObject
    self.Item:SetActive(false)

    self.RightCon = self.Main.transform:FindChild("RightCon").gameObject
    self.TopCon = self.RightCon.transform:FindChild("TopCon").gameObject
    self.ImgTitle = self.TopCon.transform:FindChild("ImgTitle").gameObject
    self.ImgName = self.ImgTitle.transform:FindChild("ImgName"):GetComponent(Image)
    self.TitleTxtName = self.ImgTitle.transform:FindChild("TxtName"):GetComponent(Text)
    self.ImgName.gameObject:SetActive(false)

    self.TxtLev = self.ImgTitle.transform:FindChild("TxtLev"):GetComponent(Text)
    self.TxtDesc = self.TopCon.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.ConDesc = self.TopCon.transform:FindChild("ConDesc").gameObject
    self.ConDesc_txt_1 = self.ConDesc.transform:FindChild("TxtVal1"):GetComponent(Text)
    self.ConDesc_txt_2 = self.ConDesc.transform:FindChild("TxtVal2"):GetComponent(Text)
    self.ConItems = self.TopCon.transform:FindChild("ConItems").gameObject
    self.LayoutLayer = self.ConItems.transform:FindChild("LayoutLayer").gameObject
    self.l_Item1 = self.LayoutLayer.transform:FindChild("Item1").gameObject
    self.l_Item2 = self.LayoutLayer.transform:FindChild("Item2").gameObject
    self.l_Item3 = self.LayoutLayer.transform:FindChild("Item3").gameObject
    self.l_Item4 = self.LayoutLayer.transform:FindChild("Item4").gameObject
    self.l_Item5 = self.LayoutLayer.transform:FindChild("Item5").gameObject
    self.l_Item6 = self.LayoutLayer.transform:FindChild("Item6").gameObject
    self.l_Item7 = self.LayoutLayer.transform:FindChild("Item7").gameObject
    self.l_Item8 = self.LayoutLayer.transform:FindChild("Item8").gameObject
    self.l_Item9 = self.LayoutLayer.transform:FindChild("Item9").gameObject
    self.ItemBtn = self.LayoutLayer.transform:FindChild("ItemBtn"):GetComponent(Button)
    self.l_item_list = {}
    table.insert(self.l_item_list, self.l_Item1)
    table.insert(self.l_item_list, self.l_Item2)
    table.insert(self.l_item_list, self.l_Item3)
    table.insert(self.l_item_list, self.l_Item4)
    table.insert(self.l_item_list, self.l_Item5)
    table.insert(self.l_item_list, self.l_Item6)
    table.insert(self.l_item_list, self.l_Item7)
    table.insert(self.l_item_list, self.l_Item8)
    table.insert(self.l_item_list, self.l_Item9)
    self.l_item_slots = {}
    self.more_item_slots = {}

    self.ConMore = self.TopCon.transform:FindChild("ConMore").gameObject
    self.ConMore_line = self.ConMore.transform:FindChild("LineCon").gameObject
    self.ConMore_item = self.ConMore_line.transform:FindChild("Item").gameObject
    self.ConMore:SetActive(false)
    self.Item1 = self.TopCon.transform:FindChild("Item1").gameObject
    self.ImgTxtVal =  self.Item1.transform:FindChild("ImgTxtVal").gameObject

    self.TxtVal =self.ImgTxtVal.transform:FindChild("TxtVal"):GetComponent(Text)
    self.Item2 = self.TopCon.transform:FindChild("Item2").gameObject
    self.ImgTxtVal2 = self.Item2.transform:FindChild("ImgTxtVal").gameObject
    self.ImgTanHao = self.Item2.transform:FindChild("ImgTanHao"):GetComponent(Button)

    self.Item3 = self.TopCon.transform:FindChild("Item3").gameObject
    self.Item3_SlotCon1 = self.Item3.transform:FindChild("SlotCon1").gameObject
    self.Item3_Slot1 = self:create_slot(self.Item3_SlotCon1)
    self.TxtVal2 = self.ImgTxtVal2.transform:FindChild("TxtVal"):GetComponent(Text)
    self.ImgShovel = self.TopCon.transform:FindChild("ImgShovel"):GetComponent(Image)

    self.ImgShovel.gameObject:SetActive(false)
    self.Item3:SetActive(false)

    self.BtnStudy = self.RightCon.transform:FindChild("BtnCon"):FindChild("BtnStudy"):GetComponent(Button)
    self.BtnOneKey = self.RightCon.transform:FindChild("BtnCon"):FindChild("BtnOneKey"):GetComponent(Button)
    self.BtnProduce = self.RightCon.transform:FindChild("BtnCon"):FindChild("BtnProduce"):GetComponent(Button)
    self.BtnProduce_txt = self.BtnProduce.transform:FindChild("Text"):GetComponent(Text)
    self.BtnProduce_ImgNormal = self.BtnProduce.transform:FindChild("ImgNormal"):GetComponent(Image)
    self.BtnProduce_ImgGrey = self.BtnProduce.transform:FindChild("ImgGrey"):GetComponent(Image)
    self.BtnProduce_button = self.BtnProduce.transform:GetComponent(Button)


    self.BtnProduce.onClick:AddListener(function() self:on_click_produce_btn() end) --BtnRest
    self.ItemBtn.onClick:AddListener(function() self:on_show_more_items() end)
    self.BtnStudy.onClick:AddListener(function() self:on_click_study_btn() end) --BtnRest
    self.BtnOneKey.onClick:AddListener(function() self:on_click_onekey_study_btn() end)

    -- event_manager:GetUIEvent(transform.gameObject).OnClick:AddListener(SkillViewTabThree:on_click_win) --BtnRest

    self.ImgTanHao.onClick:AddListener(function() self:on_click_tanhao() end)
    self.is_open = true

    local args = self.parent.openArgs
    if args ~= nil then
        local coverId = self:ConvertLifeId(self.parent.openArgs[2])
        if coverId ~= 0 then
            self.select_item_id = coverId
        end
    end
    SkillManager.Instance:Send10808()
end

--显示监听
function SkillViewTabThree:OnShow()
    local args = self.parent.openArgs
    if args ~= nil then
        local coverId = self:ConvertLifeId(self.parent.openArgs[2])
        if coverId ~= 0 then
            self.select_item_id = coverId
        end
    end
    self:socket_back_update()
    self.lossGuild = false
    self.lossGuildTen = false
end

--将产出id 转换为生活技能id
function SkillViewTabThree:ConvertLifeId(id)
    local covertId = 0
    for k, v in pairs(DataSkillLife.data_data) do
        for k1, v1 in pairs(v.product) do
            if v1.key == id then
                covertId = v.id
                break
            end
        end
        if covertId ~= 0 then
            break
        end
    end
    return covertId
end

-------------协议返回执行更新
function SkillViewTabThree:socket_back_update()
    if self.item_list ~= nil then
        for i=1,#self.item_list do
            local item = self.item_list[i]
            if item ~= nil then
                item.gameObject:SetActive(false)
            end
        end
    end
    self.item_list = {}

    local temp_item = nil

    local temp_life_skills1 = {}
    local temp_life_skills2 = {}
    for i=1,#self.parent.model.life_skills do
        local temp_data = self.parent.model.life_skills[i]
        if temp_data.id == 10009 then
        elseif temp_data.id == 10008 then
        elseif temp_data.id == 10007 then
            temp_life_skills1[1] = temp_data
        else
            table.insert(temp_life_skills2, temp_data)
        end
    end

    for i=1,#temp_life_skills2 do
        table.insert(temp_life_skills1, temp_life_skills2[i])
    end

    for i=1,#temp_life_skills1 do
        local data = temp_life_skills1[i]
        local item = self.item_list[i]
        if item == nil then
            item = SkillLifeItem.New(self, self.Item, i)
            table.insert(self.item_list, item)
        end
        item:set_item_data(data)

        if self.select_item_id ~= nil then
            if self.select_item_id == data.id then
                temp_item = item
            end
        elseif self.current_selected_item ~= nil and self.current_selected_item.data.id == data.id then
            temp_item = item
        end
    end

    self.select_item_id = nil
    if temp_item == nil then
        temp_item = self.item_list[1]
    end

    self:update_right_con(temp_item)

    local newH = 82*#temp_life_skills1
    local rect = self.LayoutLayer_Con.transform:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(0, newH)
end

-----------------------------------------更新右边界面逻辑
function SkillViewTabThree:update_right_con(item)
    self.lossGuild = false
    self.lossGuildTen = false
    if self.more_show then
        self:on_show_more_items()
    end

    if self.current_selected_item == item then
        return
    end

    if self.current_selected_item ~= nil then
        self.current_selected_item.ImgSelect:SetActive(false)
    end
    self.current_selected_item = item
    self.current_selected_item.ImgSelect:SetActive(true)

    -- self.ImgName.sprite = self.assetWrapper:GetSprite(AssetConfig.skill_life_name, tostring(item.data.id))
    -- self.ImgName:SetNativeSize()
    -- self.ImgName.gameObject:SetActive(true)
    self.TitleTxtName.text = item.data.name
    self.TxtLev.text = string.format("Lv.%s", tostring(item.data.lev))

    local str = item.data.desc
    str = string.gsub(str, "%[attr2%]", item.data.lev+1)
    if item.data.lev > 0 then
        str = string.gsub(str, "%[attr1%]", item.data.lev)
    end
    self.TxtDesc.text = str

    for i=1,#self.l_item_list do
        local itemGo = self.l_item_list[i]
        itemGo:SetActive(false)
    end

    if item.data.id == 10000 then
        self.BtnProduce_txt.text = TI18N("栽 培")
    elseif item.data.id == 10007 then
        self.BtnProduce_txt.text = TI18N("制 作")
    elseif item.data.id == 10001 then
        self.BtnProduce_txt.text = TI18N("研 制")
    elseif item.data.id == 10005 then
        self.BtnProduce_txt.text = TI18N("打 造")
    elseif item.data.id == 10006 then
        self.BtnProduce_txt.text = TI18N("裁 缝")
    end


    local max_lev_key = ""
    if item.data.id == 10004 or item.data.id == 10003 or item.data.id == 10008 then
        max_lev_key = string.format("%s_%s", item.data.id, 50)
    elseif item.data.id == 10000 then
        max_lev_key = string.format("%s_%s", item.data.id, 100)
    elseif item.data.id == 10007 then
        --雕文2特殊处理
        local key = (math.floor(item.data.open_lev/10))*10
        key = key == 0 and 10 or key
        max_lev_key = string.format("%s_%s", item.data.id, key)
    else
        max_lev_key = string.format("%s_%s", item.data.id, self.cfg_data_max_lev)
    end


    local max_lev_cfg_data = nil
    local product_list = nil
    if item.data.id == 10007 then
        max_lev_cfg_data = DataSkillLife.data_diao_wen[max_lev_key]
        product_list = {}
        for i=1,#max_lev_cfg_data.product do
            local data = max_lev_cfg_data.product[i]
            if data.classes == RoleManager.Instance.RoleData.classes then
                table.insert(product_list, data)
            end
        end
    else
        max_lev_cfg_data = DataSkillLife.data_data[max_lev_key]
        product_list = max_lev_cfg_data.product
    end

    if item.data.id == 10002 then
        product_list = {}
        for k, v in pairs(DataSkillLife.data_product_open) do
            if v.type == 3 then
                table.insert(product_list, v)
            end
        end

        local open_lev_sort = function(a, b)
            return a.open_lev < b.open_lev --根据index从小到大排序
        end
        table.sort(product_list, open_lev_sort)
    end

    if #product_list == 0 then
        self.ConItems:SetActive(false)
        self.ConDesc:SetActive(false)
    elseif item.data.id == 10008 then
        self.ConItems:SetActive(false)
        self.ConDesc:SetActive(true)
    else
        self.ConItems:SetActive(true)
        if #product_list > 9 then
            self.ItemBtn.gameObject:SetActive(true)
            self.current_more_data_list = {}
        else
            self.ItemBtn.gameObject:SetActive(false)
        end

        for i=1,#product_list do
            local p = product_list[i]
            if i <= 9 then
                local open_data = DataSkillLife.data_product_open[p.key]
                local it = self.l_item_list[i]
                self:set_slot_item_data(it, i, open_data.base_id, open_data.open_lev)
            else
                table.insert(self.current_more_data_list, p)
            end
        end
        --更新“更多面板”
        self:update_more_slot_items()
    end

    self.Item3:SetActive(false)
    self.Item1:SetActive(false)
    self.Item2:SetActive(true)
    local next_lev = item.data.lev+1
    local next_lev_key = string.format("%s_%s", item.data.id, next_lev)
    local next_lev_cfg_data = nil
    if item.data.id == 10007 then
        next_lev_cfg_data = DataSkillLife.data_diao_wen[next_lev_key]
    else
        next_lev_cfg_data = DataSkillLife.data_data[next_lev_key]
    end

    if next_lev_cfg_data ~= nil then
        local data1 = next_lev_cfg_data.levup_cost[1]
        local data2 = next_lev_cfg_data.levup_cost[2]

        if self.imgLoader == nil then
            local go = self.ImgTxtVal.transform:FindChild("ImgIcon").gameObject
            self.imgLoader = SingleIconLoader.New(go)
        end
        self.imgLoader:SetSprite(SingleIconType.Item, data1[1])


        if next_lev_cfg_data.id == 10008 and next_lev_cfg_data.lev >= 51 then
            self:set_stone_slot_data(self.Item3_Slot1, DataItem.data_get[data2[1]], false)

            local need1 = data1[2]
            local need2 = data2[2]
            local has1 = RoleManager.Instance.RoleData.guild--RoleManager.Instance.RoleData.coin
            local has2 = BackpackManager.Instance:GetItemCount(data2[1])
            self.TxtVal.text = need1 > has1 and string.format("<color='#E7582B'>%s</color><color='#e8faff'>/%s</color>", has1, need1)  or string.format("<color='#13fc60'>%s</color><color='#e8faff'>/%s</color>", has1, need1)

            self.Item3_Slot1:SetNum(has2, need2)

            self.Item3:SetActive(true)
            self.Item1:SetActive(true)
            self.Item2:SetActive(false)

            if data1[1] == 90011 and need1 > has1 then
                self.lossGuild = true
            else
                self.lossGuild = false
            end

            if data1[1] == 90011 and need1 * 10 > has1 then
                self.lossGuildTen = true
            else
                self.lossGuildTen = false
            end

        elseif #next_lev_cfg_data.levup_cost == 1 then
            self.Item1:SetActive(true)
            local has_num1 = 0

            if data1[1] == 90000 then
                has_num1 = data1[2] -- RoleManager.Instance.RoleData.coin
            end
            self.TxtVal.text = has_num1 > RoleManager.Instance.RoleData.coin and tostring(has_num1) or string.format("<color='#13fc60'>%s</color>", has_num1)
            self.TxtVal2.text = "<color='#13fc60'>0</color><color='#e8faff'>/0</color>"
        elseif #next_lev_cfg_data.levup_cost == 2 then
            self.Item1:SetActive(true)
            self.Item2:SetActive(true)
            local has_num1 = 0
            local has_num2 = 0
            if data1[1] == 90000 then
                has_num1 = data1[2] --RoleManager.Instance.RoleData.coin
            end
            if data2[1] == 90011 then
                --公会贡献
                has_num2 = RoleManager.Instance.RoleData.guild
            end

            self.TxtVal.text = has_num1 > RoleManager.Instance.RoleData.coin and tostring(has_num1) or string.format("<color='#13fc60'>%s</color>", has_num1)
            self.TxtVal2.text = data2[2] > has_num2 and string.format("<color='#E7582B'>%s</color><color='#e8faff'>/%s</color>", has_num2, data2[2])  or string.format("<color='#13fc60'>%s</color><color='#e8faff'>/%s</color>", has_num2, data2[2])
            if data2[1] == 90011 and data2[2] > has_num2 then
                self.lossGuild = true
            else
                self.lossGuild = false
            end

            if data2[1] == 90011 and data2[2] * 10 > has_num2 then
                self.lossGuildTen = true
            else
                self.lossGuildTen = false
            end


        end
    end

    self.ImgShovel.sprite = self.assetWrapper:GetSprite(AssetConfig.skill_life_shovel_bg, tostring(item.data.id))

    self.ImgShovel.gameObject:SetActive(true)

    --最高级有产出的就两个按钮，只有附加属性的就只有一个按钮 ， 没产出，就是只有 学习技能
    self.BtnStudy.gameObject:SetActive(false)
    self.BtnProduce.gameObject:SetActive(false)
    self.BtnOneKey.gameObject:SetActive(false)

    if next_lev_cfg_data ~=nil and #next_lev_cfg_data.levup_cost ~= 0 then
        self.BtnStudy.gameObject:SetActive(true) --升级
        self.BtnOneKey.gameObject:SetActive(true)
    end

    self.ConDesc_txt_1.text = ""
    self.ConDesc_txt_2.text = ""
    if item.data.id == 10008 then
        self.ConDesc:SetActive(true)
        if #item.data.attr > 0 then
            local val_1 = item.data.attr[1].val
            self.ConDesc_txt_1.text = string.format("<color='#ffff00'>%s</color>%s<color='#c3692c'>+%s</color>", TI18N("当前效果："), TI18N("角色生命值"),     val_1)

            if next_lev_cfg_data ~= nil then
                local val_2 = next_lev_cfg_data.attr[1].val
                self.ConDesc_txt_2.text = string.format("<color='#ffff00'>%s</color>%s<color='#c3692c'>+%s</color>", TI18N("下级效果："), TI18N("角色生命值"),     val_2)

            end
        elseif #next_lev_cfg_data.attr > 0 then
            local val_1 = next_lev_cfg_data.attr[1].val
            self.ConDesc_txt_1.text = string.format("<color='#ffff00'>%s</color>%s<color='#c3692c'>+%s</color>", TI18N("当前效果："), TI18N("角色生命值"),     val_1)
        end
    end

    if item.data.id == 10004 or item.data.id == 10003 or item.data.id == 10008 then
        self.BtnProduce.gameObject:SetActive(false)
    else
        self.BtnProduce.gameObject:SetActive(true)
        if #item.data.product == 0 then
            self.BtnProduce_button.image.sprite = self.BtnProduce_ImgGrey.sprite
            self.BtnProduce_txt.color = ColorHelper.DefaultButton4
            self.BtnProduce_button.enabled = false
        else
            self.BtnProduce_button.image.sprite = self.BtnProduce_ImgNormal.sprite
            self.BtnProduce_txt.color = ColorHelper.DefaultButton3
            self.BtnProduce_button.enabled = true
        end
    end
end

function SkillViewTabThree:set_slot_item_data(go, index, base_id, open_lev, _type)
    local slot = nil
    if _type == nil then
        slot = self.l_item_slots[index]
    else
        slot = self.more_item_slots[index]
    end

    go:SetActive(true)
    local txtLev = go.transform:FindChild("TxtLev"):GetComponent(Text)
    local imgFrame = go.transform:FindChild("ImgFrame").gameObject
    local cg = txtLev.transform:GetComponent(CanvasGroup)
    cg.blocksRaycasts = false

    local itemData = BaseUtils.copytab(DataItem.data_get[base_id]) --设置数据
    imgFrame.gameObject:SetActive(false)
    txtLev.gameObject:SetActive(false)
    if open_lev > self.current_selected_item.data.lev then
        txtLev.gameObject:SetActive(true)
        txtLev.text = string.format("Lv.%s", open_lev)
        txtLev.transform:SetAsLastSibling()
    else
        local key = string.format("%s_%s", self.current_selected_item.data.lev, base_id)
        local d = DataSkillLife.data_product_frame_lev[key]
        if d ~= nil then
            local step = d.odds[#d.odds].step
            itemData.step = step
            local txtLev = imgFrame.transform:FindChild("TxtLev"):GetComponent(Text)
            txtLev.text = string.format("<color='#ACE92A'>%s</color>", step)
            imgFrame.gameObject:SetActive(true)
        end
    end



    if slot == nil then
        slot = ItemSlot.New()
        slot.gameObject.transform:SetParent(go.transform)
        slot.gameObject.transform.localScale = Vector3.one
        slot.gameObject.transform.localPosition = Vector3.zero
        slot.gameObject.transform.localRotation = Quaternion.identity
        slot.gameObject.transform:SetAsFirstSibling()
        local rect = slot.gameObject:GetComponent(RectTransform)
        rect.anchorMax = Vector2(1, 1)
        rect.anchorMin = Vector2(0, 0)
        rect.localPosition = Vector3(0, 0, 1)
        rect.offsetMin = Vector2(0, 0)
        rect.offsetMax = Vector2(0, 2)
        rect.localScale = Vector3.one

        if _type == nil then
            self.l_item_slots[index] = slot
        else
            self.more_item_slots[index] = slot
        end
    end
    local cell = ItemData.New()
    cell:SetBase(itemData)
    slot:SetAll(cell, { nobutton = true })
end

--更新多余的
function SkillViewTabThree:update_more_slot_items()
    if self.current_line_list ~= nil then
        for k, v in pairs(self.more_item_slots) do
            v:DeleteMe()
            v = nil
        end
        self.more_item_slots = {}

        for i=1,#self.current_line_list do
            local it = self.current_line_list[i]
            if it ~= nil then
                it:SetActive(false)
                GameObject.DestroyImmediate(it)
            end
        end
    end

    self.current_line_list = {}
    if self.current_more_data_list ~= nil and #self.current_more_data_list ~= 0 then
        local current_line_con = nil
        local current_item = nil
        for i=1,#self.current_more_data_list do
            local data = self.current_more_data_list[i]
            if i%2 ~= 0 then --奇数，新开i
                current_line_con = GameObject.Instantiate(self.ConMore_line)
                UIUtils.AddUIChild(self.ConMore_line.transform.parent.gameObject, current_line_con)

                current_item = current_line_con.transform:FindChild("Item").gameObject
                table.insert(self.current_line_list, current_line_con)
            end

            local open_data = DataSkillLife.data_product_open[data.key]
            if open_data == nil then
                open_data = data
            end
            local it = GameObject.Instantiate(current_item)
            UIUtils.AddUIChild(current_item.transform.parent.gameObject, it)
            self:set_slot_item_data(it, i,open_data.base_id, open_data.open_lev, 1)
        end
    end
end


function SkillViewTabThree:create_slot(slot_con)
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

function SkillViewTabThree:set_stone_slot_data(slot, data, nb)
    if slot == nil then
        return
    end
    local cell = ItemData.New()
    cell:SetBase(data)
    if nb == nil then
        slot:SetAll(cell, {_nobutton = true})
    else
        slot:SetAll(cell, {_nobutton = false})
    end
end


----------------------------点击监听逻辑
function SkillViewTabThree:on_show_more_items(g)
    self.more_show = not self.more_show
    self.ConMore:SetActive(self.more_show)
end

function SkillViewTabThree:on_click_win(g)
    if self.more_show == true then
        self.more_show = not self.more_show
        self.ConMore:SetActive(self.more_show)
    end
end

function SkillViewTabThree:on_click_study_btn(g)
    self:on_click_win()
    if self.lossGuild == true then
        local itemData = ItemData.New()
        local basedata = DataItem.data_get[90011]
        itemData:SetBase(basedata)
        TipsManager.Instance:ShowItem({gameObject = nil, itemData = itemData})
    end
    SkillManager.Instance:Send10809(self.current_selected_item.data.id)
end

function SkillViewTabThree:on_click_onekey_study_btn(g)
    self:on_click_win()
    if self.lossGuildTen == true then
        local itemData = ItemData.New()
        local basedata = DataItem.data_get[90011]
        itemData:SetBase(basedata)
        TipsManager.Instance:ShowItem({gameObject = nil, itemData = itemData})
    end
    SkillManager.Instance:Send10815(self.current_selected_item.data.id)
end

function SkillViewTabThree:on_click_produce_btn(g)
    self:on_click_win()
    --打开产出
    self.parent.model.life_produce_data = self.current_selected_item.data
    self.parent.model:OpenSkillLifeProduceWindow()
end

function SkillViewTabThree:on_click_tanhao(g)
    local tips = {}
    table.insert(tips, TI18N("<color='#00ff00'>公会贡献</color>：可通过<color='#00ff00'>公会任务</color>、<color='#00ff00'>公会强盗</color>、<color='#00ff00'>银币兑换贡献</color>以及使用<color='#00ff00'>荣耀徽章</color>获得"))
    -- local t = {trans=g.transform,content=tips}
    -- mod_tips.general_tips(t)
    TipsManager.Instance:ShowText({gameObject =  self.ImgTanHao.gameObject, itemData = tips})
end


