RideSkillResetPanel  =  RideSkillResetPanel or BaseClass(BasePanel)

function RideSkillResetPanel:__init(parent)
    self.name  =  "RideSkillResetPanel"
    self.parent = parent
    self.model  =  parent.model

    self.resList  =  {
        {file  =  AssetConfig.ridewindow_skill_reset_panel, type  =  AssetType.Main}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.is_open  =  false

    self.last_select_ride_id = nil

    self.bottom_slot = nil

    self.update_ride_info = function()
        self:update_info()
    end

    self.update_select_info = function(id)
        if id == self.last_select_ride_id then
            --选的和当前的一样
            return
        end
        self.last_select_ride_id = id
        self:update_info()
    end

    self.OnOpenEvent:Add(function() self:update_info() end)

    return self
end


function RideSkillResetPanel:__delete()
    if self.bottom_slot ~= nil then
        self.bottom_slot:DeleteMe()
        self.bottom_slot = nil
    end
    
    RideManager.Instance.OnUpdateRide:Remove(self.update_ride_info)

    RideManager.Instance.OnUpdateReset:Remove(self.update_select_info)

    self.last_select_ride_id = nil

    self.bottom_slot = nil

    self.is_open  =  false

    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function RideSkillResetPanel:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.ridewindow_skill_reset_panel))
    self.gameObject.name = "RideSkillResetPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localPosition = Vector3(0, 0, 0)
    self.transform.localScale = Vector3(1, 1, 1)

    self.TopLeftCon = self.transform:FindChild("TopLeftCon")
    self.Left_TopCon = self.TopLeftCon:FindChild("TopCon")
    self.TopCon_Left_ImgReset = self.Left_TopCon:FindChild("ImgReset"):GetComponent("Button")
    self.TopCon_LeftCon = self.Left_TopCon:FindChild("LeftCon")
    self.TopCon_Preview = self.TopCon_LeftCon:FindChild("Preview").gameObject

    self.Left_AttrCon = self.Left_TopCon:FindChild("RightCon")
    self.Left_GrowUpCon = self.Left_AttrCon:FindChild("GrowUpCon")
    self.Left_Grow_TxtVal = self.Left_GrowUpCon:FindChild("ImgBg"):FindChild("TxtNum"):GetComponent("Text")
    self.Left_Grow_TxtVal.text = ""

    self.left_attr_list = {}
    for i=1,4 do
        local item = {}
        item.gameObject = self.Left_AttrCon:FindChild(string.format("Item%s", i)).gameObject
        item.icon = item.gameObject.transform:FindChild("ImgIcon"):GetComponent("Image")
        item.txt_desc = item.gameObject.transform:FindChild("TxtDesc"):GetComponent("Text")
        item.txt_desc.text = ""
        table.insert(self.left_attr_list, item)
    end


    self.Left_BottomCon = self.TopLeftCon:FindChild("BottomCon")
    self.Left_MaskCon = self.Left_BottomCon:FindChild("MaskCon")
    self.Left_ScrollCon = self.Left_MaskCon:FindChild("ScrollCon")
    self.Left_Container = self.Left_ScrollCon:FindChild("Container")

    self.left_skill_list = {}
    for i=1,8 do
        local skill_go = self.Left_Container:FindChild(string.format("SkillItem%s", i))
        table.insert(self.left_skill_list, skill_go)
    end


    self.TopRightCon = self.transform:FindChild("TopRightCon")
    self.Right_TopCon = self.TopRightCon:FindChild("TopCon")
    self.ImgEye = self.Right_TopCon:FindChild("ImgEye"):GetComponent("Button")
    self.Right_AttrCon = self.Right_TopCon:FindChild("LeftCon")
    self.Right_GrowUpCon = self.Right_AttrCon:FindChild("GrowUpCon")
    self.Right_Grow_TxtVal = self.Right_GrowUpCon:FindChild("ImgBg"):FindChild("TxtNum"):GetComponent("Text")
    self.Right_Grow_TxtVal.text = ""

    self.right_attr_list = {}
    for i=1,4 do
        local item = {}
        item.gameObject = self.Right_AttrCon:FindChild(string.format("Item%s", i)).gameObject
        item.icon = item.gameObject.transform:FindChild("ImgIcon"):GetComponent("Image")
        item.img_arrow = item.gameObject.transform:FindChild("ImgArrow"):GetComponent("Image")
        item.txt_change = item.gameObject.transform:FindChild("TxtChange"):GetComponent("Text")
        item.txt_desc = item.gameObject.transform:FindChild("TxtDesc"):GetComponent("Text")
        item.img_arrow.gameObject:SetActive(false)
        item.txt_desc.text = ""
        item.txt_change.text = ""
        table.insert(self.right_attr_list, item)
    end


    self.Right_BottomCon = self.TopRightCon:FindChild("BottomCon")
    self.Right_MaskCon = self.Right_BottomCon:FindChild("MaskCon")
    self.Right_ScrollCon = self.Right_MaskCon:FindChild("ScrollCon")
    self.Right_Container = self.Right_ScrollCon:FindChild("Container")
    self.right_skill_list = {}
    for i=1,8 do
        local skill_go = self.Right_Container:FindChild(string.format("SkillItem%s", i))
        table.insert(self.right_skill_list, skill_go)
    end



    self.BottomCon = self.transform:FindChild("BottomCon")
    self.BottomCon_SlotCon = self.BottomCon:FindChild("RightCon"):FindChild("SlotCon").gameObject
    self.BottomCon_TxtName = self.BottomCon:FindChild("RightCon"):FindChild("TxtName"):GetComponent("Text")
    self.BottomCon_TxtNum = self.BottomCon:FindChild("RightCon"):FindChild("TxtNum"):GetComponent("Text")

    self.BottomCon_ReplaceBtn = self.BottomCon:FindChild("ReplaceBtn"):GetComponent("Button")
    self.BottomCon_UseBtn = self.BottomCon:FindChild("UseBtn"):GetComponent("Button")

    self.BottomCon_UseBtn_txt = self.BottomCon_UseBtn.transform:FindChild("Text"):GetComponent("Text")
    self.BottomCon_UseBtn_txt.text = ""

    self.BottomCon_UseBtn_msg = MsgItemExt.New(self.BottomCon_UseBtn_txt, 131, 18, 23)

    self.TopCon_Left_ImgReset.onClick:AddListener(function() self.parent.model:InitRideSelectUI() end)

    self.ImgEye.onClick:AddListener(function()
        self.model:InitRidePropPreviewUI(1, self.last_select_ride_id)
    end)


    self.BottomCon_ReplaceBtn.onClick:AddListener(function()
        local ride_data = self.model:get_ride_data_by_id(self.last_select_ride_id)
        if ride_data.is_tmp == 1 then
            local rideData = self.model:get_ride_data_by_id(self.last_select_ride_id)
            RideManager.Instance:Send16404(rideData.index)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("当前没有洗髓属性可以替换"))
        end
    end)
    self.BottomCon_UseBtn.onClick:AddListener(function()
        local rideData = self.model:get_ride_data_by_id(self.last_select_ride_id)
        RideManager.Instance:Send16402(rideData.index)
    end)


    RideManager.Instance.OnUpdateRide:Add(self.update_ride_info)

    RideManager.Instance.OnUpdateReset:Add(self.update_select_info)

    self:update_info()
end


---------------------------更新逻辑
--主更新入口
function RideSkillResetPanel:update_info()
    -- self.model.ridelist

    --如果上次没有选中坐骑，则选择当前骑乘的坐骑进来，如果有选中，则选择上次选中的坐骑
    if self.last_select_ride_id == nil then
        self.last_select_ride_id = self.model.ride_mount
        if self.last_select_ride_id == 0 then
            --在坐骑列表中找到一个已经获得且激活的坐骑
            for key,value in pairs(self.model.ridelist) do
                if value.live_status == 2 then
                    self.last_select_ride_id = value.mount_base_id
                    break
                end
            end
        end
    end

    --更新左右属性
    self:update_left_prop()
    self:update_right_prop()

    self:update_bottom()

    --更新模型
    self:update_model_data()
end


--更新模型
function RideSkillResetPanel:update_model_data()
    local rideData = self.model:get_ride_data_by_id(self.last_select_ride_id)

    -- local ride_jewelry1 = 0
    -- local ride_jewelry2 = 0
    -- for _,value in ipairs(rideData.decorate_list) do
    --     if value.decorate_index == 1 then
    --         ride_jewelry1 = value.decorate_base_id
    --     elseif value.decorate_index == 2 then
    --         ride_jewelry2 = value.decorate_base_id
    --     end
    -- end

    -- local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = 0.6, effects = {}}
    -- table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = rideData.base.looks_id })
    -- table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry1, looks_val = ride_jewelry1 })
    -- table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry2, looks_val = ride_jewelry2 })
    local data = self.model:MakeRideLook(rideData)
    
    self.parent:load_preview(self.TopCon_Preview.transform, data)
end

--更新左边属性
function RideSkillResetPanel:update_left_prop()
    -- -- print("-----------------------ddd")
    -- BaseUtils.dump(self.model.ridelist)

    local ride_data = self.model:get_ride_data_by_id(self.last_select_ride_id)

    self.Left_Grow_TxtVal.text = tostring(ride_data.growth)

    for i=1,#self.left_attr_list do
        local item = self.left_attr_list[i]
        item.gameObject:SetActive(false)
    end

    local index = 1
    for i=1,#ride_data.base.attr do
        local attr_data = ride_data.base.attr[i]
        local item = self.left_attr_list[i]
        local attr_val = self.model:count_ride_attr_val(ride_data.base.attr_ratio, attr_data.val1, ride_data.growth)
        item.txt_desc.text = string.format("%s： <color='#C7F9FF'>%s</color>", KvData.attr_name[attr_data.attr_name], attr_val)
        item.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon , string.format("AttrIcon%s", attr_data.attr_name))
        item.gameObject:SetActive(true)
        index = index + 1
    end

    --设置移动速度
    if index <= #self.left_attr_list then
        local item = self.left_attr_list[index]
        local cfg_data = DataMount.data_ride_reset[ride_data.speed_lev]
        local attr_val = 1
        item.txt_desc.text = string.format("%s： <color='#C7F9FF'>%s</color>", TI18N("移动速度"), attr_val)
        item.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon , string.format("AttrIcon%s", 3))
        item.gameObject:SetActive(true)
    end

    for i=1,#self.left_skill_list do

    end
end

--更新右边属性
function RideSkillResetPanel:update_right_prop()

    local ride_data = self.model:get_ride_data_by_id(self.last_select_ride_id)
    local speed_lev = 0
    local growth = 0
    if ride_data.is_tmp == 1 then
        --有未保存的洗髓属性
        speed_lev = ride_data.tmp_speed_lev
        growth = ride_data.tmp_growth
    else
        --没有未保存的洗髓属性
        speed_lev = ride_data.speed_lev
        growth = ride_data.growth
    end

    self.Right_Grow_TxtVal.text = tostring(growth)

    for i=1,#self.right_attr_list do
        local item = self.right_attr_list[i]
        item.gameObject:SetActive(false)
    end

    local index = 1
    for i=1,#ride_data.base.attr do
        local attr_data = ride_data.base.attr[i]
        local item = self.right_attr_list[i]
        local attr_val = ride_data.base.attr_ratio*attr_data.val1*growth
        item.txt_desc.text = string.format("%s： <color='#C7F9FF'>%s</color>", KvData.attr_name[attr_data.attr_name], attr_val)
        item.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon , string.format("AttrIcon%s", attr_data.attr_name))

        item.img_arrow.gameObject:SetActive(false)

        if ride_data.is_tmp == 1 then
            local cur_attr_val = self.model:get_ride_attr_val(self.last_select_ride_id, attr_data.attr_name)
            if cur_attr_val < attr_val then
                item.img_arrow.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures , "buffArrow2") --箭头向上
                item.img_arrow.gameObject:SetActive(true)
            elseif cur_attr_val > attr_val then
                item.img_arrow.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures , "buffArrow1") --箭头向下
                item.img_arrow.gameObject:SetActive(true)
            end
        end

        item.gameObject:SetActive(true)
        index = index + 1
    end

    --设置移动速度
    if index <= #self.right_attr_list then
        local item = self.right_attr_list[index]
        local cfg_data = DataMount.data_ride_reset[speed_lev]
        local attr_val = 1
        item.txt_desc.text = string.format("%s： <color='#C7F9FF'>%s</color>", TI18N("移动速度"), attr_val)
        item.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon , string.format("AttrIcon%s", 3))
        item.img_arrow.gameObject:SetActive(false)

        if ride_data.is_tmp == 1 then
            local cur_attr_val = self.model:get_ride_attr_val(self.last_select_ride_id, 3)
            if cur_attr_val < attr_val then
                item.img_arrow.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures , "buffArrow2") --箭头向上
                item.img_arrow.gameObject:SetActive(true)
            elseif cur_attr_val > attr_val then
                item.img_arrow.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures , "buffArrow1") --箭头向下
                item.img_arrow.gameObject:SetActive(true)
            end
        end

        item.gameObject:SetActive(true)
    end

    for i=1,#self.right_skill_list do

    end
end

--更新底部内容
function RideSkillResetPanel:update_bottom()
    -- self.BottomCon_ReplaceBtn
    -- self.BottomCon_UseBtn

    local rideData = self.model:get_ride_data_by_id(self.last_select_ride_id)

    local cost_cfg_data = DataMount.data_ride_reset_cost[rideData.index]
    if self.bottom_slot == nil then
        self.bottom_slot = self:create_equip_slot(self.BottomCon_SlotCon)
    end

    for i=1,#cost_cfg_data.cost do
        local temp = cost_cfg_data.cost[i]
        if temp[1] == 90000 then
            self.BottomCon_UseBtn_msg:SetData(string.format("%s{assets_2,90002}%s", temp[2], TI18N("刷新")))
        else
            local base_data = DataItem.data_get[temp[1]]
            self:set_stone_slot_data(self.bottom_slot, base_data)
            self.BottomCon_TxtName.text = base_data.name --ColorHelper.color_item_name(base_data.quality , base_data.name)
            local has_num = BackpackManager.Instance:GetItemCount(temp[1])
            local color = has_num >= temp[2] and ColorHelper.color[1] or ColorHelper.color[6]
            self.BottomCon_TxtNum.text = string.format("<color='%s'>%s</color>", color, temp[2])
        end
    end
end


--创建道具图标
function RideSkillResetPanel:create_equip_slot(slot_con)
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
function RideSkillResetPanel:set_stone_slot_data(slot, data, _nobutton)
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