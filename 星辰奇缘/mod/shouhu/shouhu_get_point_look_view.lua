-- -------------------
-- 获得圆球新守护外观
-- 2016/11/19
-- zzl
-- -------------------
ShouhuGetPointLookView = ShouhuGetPointLookView or BaseClass(BasePanel)

function ShouhuGetPointLookView:__init(model)
    -- self.texture = AssetConfig.getpet_textures

    self.resList = {
        {file = AssetConfig.shouhu_get_point_look_view, type = AssetType.Main},
        {file = AssetConfig.shouhu_texture, type = AssetType.Dep},
        {file  =  AssetConfig.totembg, type  =  AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    self.model = model
    self.listener = function(texture, modleList) self:OnTposeLoad(texture, modleList) end
    self.callback = nil
    self.timerId = 0
    self.rotateId = 0
    self.runTimeId = 0
    self.temp_time2 = 0
    self.itemList = nil
    self.setting = {
        name = "ShouhuGetPointLookViewPreview"
        ,orthographicSize = 0.75
        ,width = 682
        ,height = 600
        ,offsetY = -0.4
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil
    self.hasInit = false
end

function ShouhuGetPointLookView:__delete()
    self.hasInit = false
    if self.rotateId ~= 0 then
        LuaTimer.Delete(self.rotateId)
    end
    if self.timerId ~= 0 then
        LuaTimer.Delete(self.timerId)
    end
    self.itemList = nil
    self.temp_time2 = 0
    self:TimeStop()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function ShouhuGetPointLookView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_get_point_look_view))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform.localPosition = Vector3(0, 0, -800)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseGetWakeUpLookPointWindow() end)
    local Panel1 = self.transform:FindChild("Panel1"):GetComponent(Button)
    Panel1.onClick:AddListener(function()
        self:Destroy()
    end)

    self.title = self.transform:Find("Main/Title").gameObject
    self.halo = self.transform:Find("Main/Halo").gameObject
    self.rawImg = self.transform:Find("Main/RawImage").gameObject
    self.rawImg:SetActive(false)

    self.transform:Find("Main/Halo"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.totembg, "ToTemBg")
    self.halo:SetActive(true)
    self.WakeUpIcon1 = self.transform:Find("Main/WakeUpIcon1").gameObject
    self.WakeUpIcon2 = self.transform:Find("Main/WakeUpIcon2").gameObject
    self.WakeUpIcon3 = self.transform:Find("Main/WakeUpIcon3").gameObject
    self.SlotCon = self.transform:Find("Main/SkillCon/SlotCon")
    self.TxtSkillName = self.transform:Find("Main/SkillCon/TxtSkillName"):GetComponent(Text)
    self.TxtSkillDesc = self.transform:Find("Main/SkillCon/TxtSkillDesc"):GetComponent(Text)
    -- self.classes = self.transform:Find("Main/ImgClasses"):GetComponent(Image)
    self.name = self.transform:Find("Main/Name"):GetComponent(Text)
    self.name.text = ""

    self.AttrItem = self.transform:Find("Main/MaskCon/ScrollCon/Container/AttrItem").gameObject
    self.AttrItem:SetActive(false)
    self.lookData = self.openArgs.data
    self.callback = self.openArgs.callback

    self.WakeUpIcon1:SetActive(false)
    self.WakeUpIcon2:SetActive(false)
    self.WakeUpIcon3:SetActive(false)
    -- if self.lookData.quality == 2 then
    --     self.WakeUpIcon1:SetActive(true)
    -- elseif self.lookData.quality == 3 then
    --     self.WakeUpIcon2:SetActive(true)
    -- elseif self.lookData.quality == 4 then
    --     self.WakeUpIcon3:SetActive(true)
    -- end

    local baseData = DataShouhu.data_guard_base_cfg[self.lookData.base_id]
    self.name.text = ColorHelper.color_item_name(baseData.quality , baseData.name)
    self.transform:Find("Main/ImgClasses"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" .. baseData.classes)

    self:ShowHaloLight()
    self:ShowPreview()

    local levCfgData = DataShouhu.data_guard_lev_prop[string.format("%s_%s", self.lookData.curData.base_id, self.lookData.curData.sh_lev)]
    local wakeUpCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", self.lookData.curData.base_id, self.lookData.curChargeStarIndex - 1, self.lookData.lastData.quality)]
    local growthVal = 0
    if wakeUpCfgData ~= nil then
        growthVal = wakeUpCfgData.growth/1000
    end
    if self.lookData.quality > baseData.quality then
        local lastCfgData = DataShouhu.data_guard_wakeup[string.format("%s_%s_%s", self.lookData.curData.base_id, self.lookData.curChargeStarIndex - 1, self.lookData.lastData.quality - 1)]
        if lastCfgData ~= nil then
            growthVal = growthVal - lastCfgData.growth/1000
        end
    end

    local rightAttrList = {}
    if levCfgData ~= nil and wakeUpCfgData ~= nil then
        for j = 1, #levCfgData.extra_attrs do
            rightAttrList[levCfgData.extra_attrs[j].attr] = levCfgData.extra_attrs[j].val*growthVal
        end
    end
    self.hasInit = true
    LuaTimer.Add(500, function()
        --延迟一下，等新的数据回来
        if self.hasInit == false then
            return
        end

        local list = {
            [2] =  {name = 1, val = self.lookData.lastData.sh_attrs_list.hp_max, icon = "AttrIcon1"} --生命上限
            ,[3] = {name = 6, val = self.lookData.lastData.sh_attrs_list.phy_def, icon = "AttrIcon6"} --物防
            ,[4] = {name = 7, val = self.lookData.lastData.sh_attrs_list.magic_def, icon = "AttrIcon7"} --魔防
            ,[5] = {name = 3, val = self.lookData.lastData.sh_attrs_list.atk_speed, icon = "AttrIcon3"} --攻击速度
        }
        if self.lookData.lastData.classes == 1 or self.lookData.lastData.classes == 3 or self.lookData.lastData.classes == 4 then
            list[1] = {name = 4, val = self.lookData.lastData.sh_attrs_list.phy_dmg, icon = "AttrIcon4"} --物攻
        -- elseif self.lookData.lastData.classes == 5 then
        --     list[1] = {name = 43, val = self.lookData.lastData.sh_attrs_list.heal_val, icon = "AttrIcon1"} --治疗加强
        else
            list[1] = {name = 5, val = self.lookData.lastData.sh_attrs_list.magic_dmg, icon = "AttrIcon5"} --魔攻
        end
        local curAttrlist = self:GetCurAttrList()
        local newH = 30*#list
        local rect = self.transform:Find("Main/MaskCon/ScrollCon/Container"):GetComponent(RectTransform)
        rect.sizeDelta = Vector2(182, newH)
        self.itemList = {}
        for i = 1, #list do
            local data = list[i]
            local item = self:CreateAttrItem(i)
            self:SetAttrItem(item, data, curAttrlist[data.name].val - data.val) --rightAttrList[data.name])
            table.insert(self.itemList, item)
        end
        self:TimeCount()
    end)
end

function ShouhuGetPointLookView:ShowHaloLight()
    self.halo:SetActive(true)
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function ShouhuGetPointLookView:Rotate()
    self.halo.transform:Rotate(Vector3(0, 0, -0.5))
end

function ShouhuGetPointLookView:ShowPreview()
    self.name.text = self.openArgs.name
    local data = {type = PreViewType.Shouhu, skinId = self.lookData.skin, modelId = self.lookData.model, animationId = self.lookData.animation, scale = 0.5}
    self:LoadPreview(data)
end

function ShouhuGetPointLookView:PlayRun()
    if self.animator ~= nil then
        self.animator:Play(string.format("Move%s", DataAnimation.data_npc_data[self.lookData.animation].move_id))
    end
end

function ShouhuGetPointLookView:LoadPreview(modelData)
    self.rawImg:SetActive(false)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

function ShouhuGetPointLookView:SetRawImage(composite)
    SoundManager.Instance:Play(243)
    self.previewComp = composite
    local image = composite.rawImage
    image.transform:SetParent(self.rawImg.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3.zero
    self.previewComp.tpose.transform:Rotate(Vector3(0, -45, 0))
    self.rawImg:SetActive(true)
    self.animator = composite.tpose:GetComponent(Animator)
    self:PlayRun()
end

function ShouhuGetPointLookView:Destroy()
    if self.callback ~= nil then
        self.callback()
    end
    self.model:CloseGetWakeUpLookPointWindow()
end


--创建充能效果属性item
function ShouhuGetPointLookView:CreateAttrItem(index)
    local item = {}
    item.gameObject = GameObject.Instantiate(self.AttrItem)
    item.transform = item.gameObject.transform
    item.transform:SetParent(self.AttrItem.transform.parent)
    item.transform.localScale = Vector3.one

    item.ImgIcon = item.transform:Find("ImgIcon"):GetComponent(Image)
    item.AttrTxt = item.transform:Find("AttrTxt"):GetComponent(Text)
    item.AttrTxt2 = item.transform:Find("AttrTxt2"):GetComponent(Text)
    item.index = index

    local newY = -45*(index - 1)
    local rect = item.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(0, newY)

    item.gameObject:SetActive(true)
    return item
end

function ShouhuGetPointLookView:SetAttrItem(item, data, val)
    item.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, data.icon)
    item.data = data
    if val == nil then
        local nameStr = KvData.attr_name[data.name]
        if data.name == 43 then
            nameStr = TI18N("治疗")
        end
        item.leftNum = data.val
        item.addNum = 0
        item.rightNum = data.val
        item.AttrTxt.text = string.format("%s: <color='#c7f9ff'>%s</color>", nameStr, data.val)
        item.AttrTxt2.text = tostring(math.floor(data.val*1))
    else
        item.leftNum = data.val
        item.addNum = val
        item.rightNum = data.val
        item.AttrTxt.text = string.format("%s: <color='#c7f9ff'>%s</color>", KvData.attr_name[data.name], data.val)
        item.AttrTxt2.text = tostring(math.floor(data.val+val))
    end
end

function ShouhuGetPointLookView:RunAttrItem(item, timeOffset)
    if item.rightNum >= item.leftNum + item.addNum then
        item.AttrTxt2.text = tostring(item.leftNum + item.addNum)
        return true
    end

    item.rightNum = item.rightNum + item.addNum/50
    item.AttrTxt2.text = tostring(math.ceil(item.rightNum))
    return false
end

------滚属性增加
function ShouhuGetPointLookView:TimeCount()
    self:TimeStop()
    self.temp_time2 = Time.time
    self.runTimeId = LuaTimer.Add(0, 10, function() self:Loop() end)
end

function ShouhuGetPointLookView:TimeStop()
    if self.runTimeId ~= 0 then
        LuaTimer.Delete(self.runTimeId)
        self.runTimeId = 0
    end
end

function ShouhuGetPointLookView:Loop()
    local timeGap = Time.time - self.temp_time2
    self.temp_time2 = Time.time
    local canStop = true
    for k, v in pairs(self.itemList) do
        local temp = self:RunAttrItem(v, timeGap)
        if temp == false then
            canStop = temp
        end
    end
    if canStop then
        self:TimeStop()
        local list = self:GetCurAttrList()
        for k, v in pairs(self.itemList) do
            v.AttrTxt2.text = tostring(list[v.data.name].val)
        end
    end
end

--获取当前守护的属性列表
function ShouhuGetPointLookView:GetCurAttrList()
    local shData = self.model:get_my_shouhu_data_by_id(self.lookData.curData.base_id)
    local list = {
        [1] =  {name = 1, val = shData.sh_attrs_list.hp_max, icon = "AttrIcon1"} --生命上限
        ,[6] = {name = 6, val = shData.sh_attrs_list.phy_def, icon = "AttrIcon6"} --物防
        ,[7] = {name = 7, val = shData.sh_attrs_list.magic_def, icon = "AttrIcon7"} --魔防
        ,[3] = {name = 3, val = shData.sh_attrs_list.atk_speed, icon = "AttrIcon3"} --攻击速度
    }
    if shData.classes == 1 or shData.classes == 3 or shData.classes == 4 then
        list[4] = {name = 4, val = shData.sh_attrs_list.phy_dmg, icon = "AttrIcon4"} --物攻
    -- elseif shData.classes == 5 then
    --     list[1] = {name = 43, val = shData.sh_attrs_list.heal_val, icon = "AttrIcon1"} --治疗加强
    else
        list[5] = {name = 5, val = shData.sh_attrs_list.magic_dmg, icon = "AttrIcon5"} --魔攻
    end
    return list
end