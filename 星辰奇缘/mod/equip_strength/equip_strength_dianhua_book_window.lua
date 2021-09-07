EquipStrengthDianhuaBookWindow  =  EquipStrengthDianhuaBookWindow or BaseClass(BaseWindow)

function EquipStrengthDianhuaBookWindow:__init(model)
    self.name  =  "EquipStrengthDianhuaBookWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.equip_strength_dianhua_book_win, type  =  AssetType.Main}
        ,{file = AssetConfig.equip_strength_res, type = AssetType.Dep}
        ,{file = AssetConfig.rolebg, type = AssetType.Dep}
    }

    self.width = 315
    self.height = 0

    self.minScale = 0.8
    self.maxScale = 1.05

    self.previewList = {}

    self.txtTab = {}

    self.updataListener = function() self:update_info(1) end

    return self
end


function EquipStrengthDianhuaBookWindow:__delete()
    if self.previewList ~= nil then
        for k,v in pairs(self.previewList) do
            v:DeleteMe()
        end
        self.previewList = nil
    end


    self.is_open  =  false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()

    EventMgr.Instance:RemoveListener(event_name.equip_item_change, self.updataListener)
end


function EquipStrengthDianhuaBookWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_dianhua_book_win))
    self.gameObject.name  =  "EquipStrengthDianhuaBookWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform.localPosition = Vector3(0, 0, -100)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseEquipDianhuaBooksUI() end)

    self.MainCon = self.transform:Find("MainCon")

    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseEquipDianhuaBooksUI() end)

    self.ToggleCon = self.MainCon:Find("ToggleCon")
    self.Toggle = self.ToggleCon:Find("Toggle")
    self.Checkmark  = self.Toggle:FindChild("Background"):FindChild("Checkmark").gameObject

    self.Oncheck = true
    self.Checkmark:SetActive(self.Oncheck)

    self.ToggleCon:GetComponent(Button).onClick:AddListener(function()
        self.Oncheck = not self.Oncheck
        self.Checkmark:SetActive(self.Oncheck)
        self:update_info(1)
    end)

    self.MaskScroll = self.MainCon:Find("MaskScroll")
    self.Container = self.MaskScroll:Find("Container")
    self.Scrollbar = self.MaskScroll:Find("Scrollbar")
    self.Page = self.MaskScroll:Find("Page").gameObject
    self.MaskScroll:GetComponent(ScrollRect).enabled = false

    self.LeftArrowCon = self.MainCon:Find("LeftArrowCon"):GetComponent(Button)
    self.RightArrowCon = self.MainCon:Find("RightArrowCon"):GetComponent(Button)

    self.LeftOkArrow = self.MainCon:Find("LeftArrowCon"):Find("ImageOk").gameObject
    self.LeftNoArrow = self.MainCon:Find("LeftArrowCon"):Find("ImageNo").gameObject

    self.RightOkArrow = self.MainCon:Find("RightArrowCon"):Find("ImageOk").gameObject
    self.RightNoArrow = self.MainCon:Find("RightArrowCon"):Find("ImageNo").gameObject

    self:switch_left_arrow(false)
    self:switch_right_arrow(true)

    self.first_point = 1
    self.last_point = 3
    self.RightArrowCon.onClick:AddListener(function()
        if self.last_point == #self.talent_list then
            return
        end

        local first_item = self.item_list[self.first_point]
        local previewCon = first_item.transform:Find("preview")
        previewCon.gameObject:SetActive(false)

        self.first_point = self.first_point + 1
        self.last_point = self.last_point + 1

        --移位
        local newX = self.page.transform:GetComponent(RectTransform).anchoredPosition.x-200
        self.RightArrowCon.enabled = false
        Tween.Instance:MoveLocalX(self.page, newX, 0.2, function()
            local last_item = self.item_list[self.last_point]
            previewCon = last_item.transform:Find("preview")
            previewCon.gameObject:SetActive(true)
            if self.last_point == #self.talent_list then
                self:switch_right_arrow(false)
                self:switch_left_arrow(true)
            else
                self:switch_right_arrow(true)
            end
            self.RightArrowCon.enabled = true
        end, LeanTweenType.linear)



    end)

    self.LeftArrowCon.onClick:AddListener(function()
        if self.first_point == 1 then
            return
        end

        local last_item = self.item_list[self.last_point]
        local previewCon = last_item.transform:Find("preview")
        previewCon.gameObject:SetActive(false)

        self.first_point = self.first_point - 1
        self.last_point = self.last_point - 1

        --移位
        local newX = self.page.transform:GetComponent(RectTransform).anchoredPosition.x+200
        self.LeftArrowCon.enabled = false
        Tween.Instance:MoveLocalX(self.page, newX, 0.2, function()
            local first_item = self.item_list[self.first_point]
            previewCon = first_item.transform:Find("preview")
            previewCon.gameObject:SetActive(true)

            if self.first_point == 1 then
                self:switch_left_arrow(false)
                self:switch_right_arrow(true)
            else
                self:switch_left_arrow(true)
            end
            self.LeftArrowCon.enabled = true
        end, LeanTweenType.linear)
    end)


    self.OnHideEvent:AddListener(function() self:HidePreview() end)
    self.OnOpenEvent:AddListener(function() self:ShowPreview() end)

    --更新图谱内容
    self:update_info()

    EventMgr.Instance:AddListener(event_name.equip_item_change, self.updataListener)
end

--切换左按钮
function EquipStrengthDianhuaBookWindow:switch_left_arrow(state)
    self.LeftOkArrow:SetActive(state)
    self.LeftNoArrow:SetActive(not state)
end

--切换右按钮
function EquipStrengthDianhuaBookWindow:switch_right_arrow(state)
    self.RightOkArrow:SetActive(state)
    self.RightNoArrow:SetActive(not state)
end

--更新图谱
function EquipStrengthDianhuaBookWindow:update_info(_type)
    if _type == nil then
        self.first_point = 1
        self.last_point = 3
    end

    local weapon_data = nil
    for k,v in pairs(BackpackManager.Instance.equipDic) do
        if v.id == 1 then
            weapon_data = v
            break
        end
    end
    if weapon_data ~= nil then
        self.talent_list = {}
        --加上普通武器到self.talent_list里面

        local equip_type = 1
        for k,v in pairs(BackpackManager.Instance.equipDic) do
            if v.id == 1 then
                equip_type = v.type
                break
            end
        end


        local selected_cfg_base_data = nil
        for key, cfg_base_data in pairs(DataItem.data_equip) do
            if cfg_base_data.classes == RoleManager.Instance.RoleData.classes and cfg_base_data.type == equip_type and cfg_base_data.lev <= math.floor(RoleManager.Instance.RoleData.lev/10)*10 then
                if selected_cfg_base_data == nil then
                    selected_cfg_base_data = DataItem.data_get[key]
                else
                    if  cfg_base_data.lev > selected_cfg_base_data.lev then
                        selected_cfg_base_data = DataItem.data_get[key]
                    end
                end
            end
        end

        table.insert(self.talent_list, selected_cfg_base_data.id)



        local temp_data_list  = self.model:get_equip_dianhua_list(weapon_data.type, RoleManager.Instance.RoleData.classes)

        self.cfg_data_list = {}
        for i=1,#temp_data_list do
            if temp_data_list[i].looks ~= 0 then
                table.insert(self.cfg_data_list, temp_data_list[i])
            end
        end

        local craft_cfg_data = nil
        for i=1,#self.cfg_data_list do
            if craft_cfg_data ~= nil then
                if craft_cfg_data.lev < self.cfg_data_list[i].lev then
                    craft_cfg_data = self.cfg_data_list[i]
                end
            else
                craft_cfg_data = self.cfg_data_list[i]
            end

            if craft_cfg_data.looks ~= 0 then
                table.insert(self.talent_list, craft_cfg_data.looks)
            end
        end

        if #self.talent_list > 3 then
            self.LeftArrowCon.gameObject:SetActive(true)
            self.RightArrowCon.gameObject:SetActive(true)
        else
            self.LeftArrowCon.gameObject:SetActive(false)
            self.RightArrowCon.gameObject:SetActive(false)
        end

        local setting1 = {
            axis = BoxLayoutAxis.X
            ,cspacing = 0
            ,Left = 0
        }
        self.presentLayout = LuaBoxLayout.New(self.Container, setting1)


        self:InitPage(_type)
    end
end


function EquipStrengthDianhuaBookWindow:InitPage(_type)

    self.is_enchant = _type
    if self.item_list == nil then
        self.item_list = {}
    end
    if self.page == nil then
        self.page = GameObject.Instantiate(self.Page)
        self.page.gameObject.name = tostring(1)
        self.presentLayout:AddCell(self.page.gameObject)
    end
    local origin_item = self.page.transform:Find(string.format("Item%s", tostring(1)))

    for sub = 1, #self.talent_list do
        local item = self.item_list[sub]
        if item == nil then
            item = GameObject.Instantiate(origin_item)
            item.transform:SetParent(origin_item.transform.parent)
            item.transform.localScale = Vector3.one

             local newX = 14+(sub-1)*211
            local rect = item.transform:GetComponent(RectTransform)
            rect.anchoredPosition = Vector2(newX, -141)

            table.insert(self.item_list, item)
        end
        local data = self.talent_list[sub]
        self:SetPageitem(item, sub, data)
    end
end


function EquipStrengthDianhuaBookWindow:SetPageitem(item, index, dat)
    item.name = tostring(index)
    local page = math.ceil(index/3)
    item.gameObject:SetActive(true)
    local temp_base_data = DataItem.data_get[dat]

    item.transform:Find("bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebg, "RoleBg")

    item.transform:Find("ImageTitlebg"):Find("TxtTile"):GetComponent(Text).text = temp_base_data.name

    local open_craft = 0
    for i=1,#self.cfg_data_list do
        if self.cfg_data_list[i].looks == dat then
            open_craft = self.cfg_data_list[i].craft
            break
        end

        if open_craft ~= 0 then
            break
        end
    end

    item.transform:Find("TextOpen"):GetComponent(Text).text = ""
    if open_craft ~= 0 then
        local name_str = EquipStrengthManager.Instance.model.dianhua_name[open_craft]
        local name_color = EquipStrengthManager.Instance.model.dianhua_color[open_craft]
        item.transform:Find("TextOpen"):GetComponent(Text).text = string.format("%s<color='#ffff00'>%s</color>%s",  name_str, TI18N("4星"), TI18N("可出现"))
    end


    item.transform:Find("ImgActive").gameObject:SetActive(false)
    local super = BackpackManager.Instance.equipDic[1].super


    -- if index == 1 then
    --     if BackpackManager.Instance.equipDic[1].currLookId == 0 then
    --         item.transform:Find("UseBtn/Text"):GetComponent(Text).text = TI18N("已使用")
    --         item.transform:Find("UseBtn").gameObject:SetActive(false)
    --         item.transform:Find("TextOpen"):GetComponent(Text).text = TI18N("当前使用中")
    --     else
    --         item.transform:Find("UseBtn/Text"):GetComponent(Text).text = TI18N("使用")
    --         item.transform:Find("UseBtn").gameObject:SetActive(true)
    --         item.transform:Find("TextOpen"):GetComponent(Text).text = ""
    --     end
    --     item.transform:Find("ImgActive").gameObject:SetActive(true)
    -- else
    --     local ii = self.cfg_data_list[index - 1]

    --     local active_state = false
    --     if (super[ii.craft] ~= nil and super[ii.craft].val >= ii.looks_active_val and ii.looks_active_val ~= 0) then
    --         item.transform:Find("UseBtn").gameObject:SetActive(true)
    --         item.transform:Find("ImgActive").gameObject:SetActive(true)
    --         active_state = true
    --     else
    --         item.transform:Find("UseBtn").gameObject:SetActive(false)
    --         item.transform:Find("ImgActive").gameObject:SetActive(false)
    --         active_state = false
    --     end

    --     if BackpackManager.Instance.equipDic[1].currLookId == ii.looks then
    --         item.transform:Find("UseBtn/Text"):GetComponent(Text).text = TI18N("已使用")

    --         if active_state then
    --             item.transform:Find("UseBtn").gameObject:SetActive(false)
    --             item.transform:Find("TextOpen"):GetComponent(Text).text = TI18N("当前使用中")
    --         end
    --     else
    --         item.transform:Find("UseBtn/Text"):GetComponent(Text).text = TI18N("使用")

    --         if active_state then
    --             item.transform:Find("TextOpen"):GetComponent(Text).text = ""
    --         end
    --     end

    -- end

    if index == 1 then
        if BackpackManager.Instance.equipDic[1].currLookId == 0 then
            item.transform:Find("TextOpen"):GetComponent(Text).text = TI18N("当前使用中")
        else
            item.transform:Find("TextOpen"):GetComponent(Text).text = "默认武器"
        end
        item.transform:Find("ImgActive").gameObject:SetActive(true)
    else
        local ii = self.cfg_data_list[index - 1]

        local active_state = false
        if (super[ii.craft] ~= nil and super[ii.craft].val >= ii.looks_active_val and ii.looks_active_val ~= 0) then
            item.transform:Find("ImgActive").gameObject:SetActive(true)
            active_state = true
        else
            item.transform:Find("ImgActive").gameObject:SetActive(false)
            active_state = false
        end

        if BackpackManager.Instance.equipDic[1].currLookId == ii.looks then
            if active_state then
                item.transform:Find("UseBtn").gameObject:SetActive(false)
                item.transform:Find("TextOpen"):GetComponent(Text).text = TI18N("当前使用中")
            end
        else
            if active_state then
                item.transform:Find("TextOpen"):GetComponent(Text).text = "已开启"
            end
        end

    end

    item.transform:Find("UseBtn"):GetComponent(Button).onClick:RemoveAllListeners()
    item.transform:Find("UseBtn"):GetComponent(Button).onClick:AddListener(function()
        EquipStrengthManager.Instance:request10619(1, dat)
    end)

    local previewCon = item.transform:Find("preview")
    if self.is_enchant == nil then
        if index > 3 then
            previewCon.gameObject:SetActive(false)
        else
            previewCon.gameObject:SetActive(true)
        end
    end

    local previewcb = function(composite)
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(previewCon)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        if composite.tpose1 ~= nil then
            composite.tpose1.transform:Rotate(Vector3(350, 340, 0))
        end
        if composite.tpose2 ~= nil then
            composite.tpose2.transform:Rotate(Vector3(350, 340, 0))
        end
    end


    self:LoadPreview(temp_base_data.look_id, previewcb)

end

function EquipStrengthDianhuaBookWindow:LoadPreview(baseid, callback)
    local previewComp = nil
    local cb = function(composite)
        callback(composite)
    end
    local setting = {
        name = "EquipStrengthDianhuaBookWindow"..baseid
        ,orthographicSize = 0.48
        ,width = 240
        ,height = 220
        ,offsetY = -0.09
        ,noDrag = true
    }

    local weaponData = DataLook.data_weapon[string.format("%s_12", baseid)]
    if not self.Oncheck then
        weaponData = DataLook.data_weapon[string.format("%s_0", baseid)]
    end

    if weaponData == nil then
        --那就不是神器拉
        weaponData = DataLook.data_nomal_weapon_effect[string.format("%s_12", baseid)]
        if not self.Oncheck then
            weaponData = DataLook.data_nomal_weapon_effect[string.format("%s_9", baseid)]
        end
    end

    local _looks = BaseUtils.copytab(SceneManager.Instance:MyData().looks)
    for k,v in pairs(_looks) do
        if v.looks_type == 1 then
            v.looks_val = baseid
            if weaponData ~= nil then
                v.looks_mode = weaponData.effect_id
            else
                v.looks_mode = 0
            end
            break
        end
    end
    local modelData = {type = PreViewType.Weapon, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = _looks}

    if self.previewList[baseid] == nil then
        previewComp = PreviewComposite.New(cb, setting, modelData)
        self.previewList[baseid] = previewComp
    else
        self.previewList[baseid]:Reload(modelData, cb)
    end
end

function EquipStrengthDianhuaBookWindow:HidePreview()
    for k,v in pairs(self.previewList) do
        v:Hide()
    end
end

function EquipStrengthDianhuaBookWindow:ShowPreview()
    for k,v in pairs(self.previewList) do
        v:Show()
    end
end
