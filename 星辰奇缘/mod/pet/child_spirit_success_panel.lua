-- -------------------
-- 子女附灵成功

-- -------------------
ChildSpiritSuccessPanel = ChildSpiritSuccessPanel or BaseClass(BasePanel)

function ChildSpiritSuccessPanel:__init(model)
    self.texture = AssetConfig.getpet_textures

    self.resList = {
        {file = AssetConfig.petspiritsuccesspanel, type = AssetType.Main},
        {file = AssetConfig.shouhu_texture, type = AssetType.Dep},
        {file = AssetConfig.childhead, type = AssetType.Dep},
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
        name = "ChildSpiritSuccessPanelPreview"
        ,orthographicSize = 1.5
        ,width = 682
        ,height = 600
        ,offsetY = -0.85
    }
    self.previewCallback = function(composite) self:SetRawImage(composite) end
    self.previewComp = nil
    self.hasInit = false

    self.ChildrenData = {
        [11] = BaseUtils.copytab(DataUnit.data_unit[71151]),
        [10] = BaseUtils.copytab(DataUnit.data_unit[71152]),
        [21] = BaseUtils.copytab(DataUnit.data_unit[71153]),
        [20] = BaseUtils.copytab(DataUnit.data_unit[71154]),
        [31] = BaseUtils.copytab(DataUnit.data_unit[71155]),
        [30] = BaseUtils.copytab(DataUnit.data_unit[71156]),
    }
end

function ChildSpiritSuccessPanel:__delete()
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

function ChildSpiritSuccessPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petspiritsuccesspanel))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    self.transform.localPosition = Vector3(0, 0, -800)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseChildSpiritSuccessPanel() end)
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
    self.SlotCon = self.transform:Find("Main/SkillCon/SlotCon")
    self.skillIcon = SkillSlot.New()
    UIUtils.AddUIChild(self.SlotCon.gameObject, self.skillIcon.gameObject)
    self.TxtSkillName = self.transform:Find("Main/SkillCon/TxtSkillName"):GetComponent(Text)
    self.TxtSkillDesc = self.transform:Find("Main/SkillCon/TxtSkillDesc"):GetComponent(Text)
    -- self.classes = self.transform:Find("Main/ImgClasses"):GetComponent(Image)
    self.name = self.transform:Find("Main/Name"):GetComponent(Text)
    self.name.text = ""

    self.AttrItem = self.transform:Find("Main/MaskCon/ScrollCon/Container/AttrItem").gameObject
    self.AttrItem:SetActive(false)
    self.lookData = self.openArgs
    self.callback = self.openArgs.callback

    self.name.text = self.lookData.mainChildData.name

    self:ShowHaloLight()
    self:ShowPreview()

    self.hasInit = true
    LuaTimer.Add(500, function()
        --延迟一下，等新的数据回来
        if self.hasInit == false then
            return
        end

	    local mainChildData = self.lookData.mainChildData
	    local list = {
	        {name = 1, val = mainChildData.hp_max, icon = "AttrIcon1"} --生命上限
			,{name = 4, val = mainChildData.phy_dmg, icon = "AttrIcon4"} --物攻
	        ,{name = 5, val = mainChildData.magic_dmg, icon = "AttrIcon5"} --魔攻
	        ,{name = 6, val = mainChildData.phy_def, icon = "AttrIcon6"} --物防
	        ,{name = 7, val = mainChildData.magic_def, icon = "AttrIcon7"} --魔防
	        -- ,{name = 3, val = mainChildData.atk_speed, icon = "AttrIcon3"} --攻击速度
	    }

        local attach_pet = nil
        local attach_pet_id = self.lookData.mainChildData.attach_pet_ids[1]
        if attach_pet_id ~= nil then -- 如果本来有附灵宠，先把附灵宠属性减去
            attach_pet = self.model:getpet_byid(attach_pet_id)

            local data_child_spirt_score = self.model:GetChildSpirtScoreByTalent(attach_pet.base_id, attach_pet.talent)
            local data_child_spirt_attr = DataPet.data_child_spirt_attr[attach_pet.lev]
            local attr_ratio = data_child_spirt_score.attr_ratio

            list[1].val = list[1].val - BaseUtils.Round(data_child_spirt_attr.hp_max * attr_ratio / 1000)
            list[2].val = list[2].val - BaseUtils.Round(data_child_spirt_attr.phy_dmg * attr_ratio / 1000)
            list[3].val = list[3].val - BaseUtils.Round(data_child_spirt_attr.magic_dmg * attr_ratio / 1000)
            list[4].val = list[4].val - BaseUtils.Round(data_child_spirt_attr.phy_def * attr_ratio / 1000)
            list[5].val = list[5].val - BaseUtils.Round(data_child_spirt_attr.magic_def * attr_ratio / 1000)
        end

        local curAttrlist = self:GetCurAttrList()
        local newH = 30*#list
        local rect = self.transform:Find("Main/MaskCon/ScrollCon/Container"):GetComponent(RectTransform)
        rect.sizeDelta = Vector2(182, newH)
        self.itemList = {}
        for i = 1, #list do
            local data = list[i]
            local item = self:CreateAttrItem(i)
            self:SetAttrItem(item, data, curAttrlist[data.name].val - data.val)
            table.insert(self.itemList, item)
        end
        self:TimeCount()
    end)

    local data_child_spirt_score = self.model:GetChildSpirtScoreByTalent(self.lookData.spritPetData.base_id, self.lookData.spritPetData.talent)
    local activeSkillMark = true
    if data_child_spirt_score == nil or #data_child_spirt_score.skills == 0 then
        data_child_spirt_score = self.model:GetChildSpirtScoreBySkillLevel(self.lookData.spritPetData.base_id, 0)
        activeSkillMark = false
    end
    local skillData = DataSkill.data_petSkill[string.format("%s_%s", data_child_spirt_score.skills[1][1], data_child_spirt_score.skills[1][2])]

    self.TxtSkillName.text = string.format("<color='#ffff00'>%s</color>", skillData.name)
    self.TxtSkillDesc.text = skillData.desc
    if activeSkillMark then
        self.skillIcon:SetAll(Skilltype.petskill, skillData)
        self.skillIcon:SetGrey(false)
    else
        self.skillIcon:SetAll(Skilltype.petskill, skillData)
        self.skillIcon:SetGrey(true)
    end
end

function ChildSpiritSuccessPanel:ShowHaloLight()
    self.halo:SetActive(true)
    self.rotateId = LuaTimer.Add(0, 10, function() self:Rotate() end)
end

function ChildSpiritSuccessPanel:Rotate()
    self.halo.transform:Rotate(Vector3(0, 0, -0.5))
end

function ChildSpiritSuccessPanel:ShowPreview()
    self.name.text = self.lookData.mainChildData.name

    local childData = self.lookData.mainChildData
    self.childModelData = nil

    BaseUtils.dump(childData,"孩子数据")
    BaseUtils.dump(self.ChildrenData,"孩子数据列表")

    local childId = tonumber(childData.classes_type .. childData.sex)
    self.childModelData = self.ChildrenData[childId]


    local data = {type = PreViewType.Npc, skinId = self.childModelData.skin, modelId = self.childModelData.res, animationId = self.childModelData.animation_id, scale = self.childModelData.scale/50, effects = self.childModelData.effects}
    self:LoadPreview(data)
end

function ChildSpiritSuccessPanel:PlayRun()
    if self.animator ~= nil then

        self.animator:Play(string.format("Move%s", DataAnimation.data_npc_data[self.childModelData.animation_id].move_id))
    end
end

function ChildSpiritSuccessPanel:LoadPreview(modelData)
    self.rawImg:SetActive(false)
    if modelData ~= nil then
        if self.previewComp == nil then
            self.previewComp = PreviewComposite.New(self.previewCallback, self.setting, modelData)
        else
            self.previewComp:Reload(modelData, self.previewCallback)
        end
    end
end

function ChildSpiritSuccessPanel:SetRawImage(composite)
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

function ChildSpiritSuccessPanel:Destroy()
    if self.callback ~= nil then
        self.callback()
    end
    self.model:CloseChildSpiritSuccessPanel()
end


--创建充能效果属性item
function ChildSpiritSuccessPanel:CreateAttrItem(index)
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

function ChildSpiritSuccessPanel:SetAttrItem(item, data, val)
    item.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, data.icon)
    item.data = data
    if val == nil then
        local nameStr = KvData.attr_name[data.name]
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

function ChildSpiritSuccessPanel:RunAttrItem(item, timeOffset)
    if item.rightNum >= item.leftNum + item.addNum then
        item.AttrTxt2.text = tostring(item.leftNum + item.addNum)
        return true
    end

    item.rightNum = item.rightNum + item.addNum/50
    item.AttrTxt2.text = tostring(math.ceil(item.rightNum))
    return false
end

------滚属性增加
function ChildSpiritSuccessPanel:TimeCount()
    self:TimeStop()
    self.temp_time2 = Time.time
    self.runTimeId = LuaTimer.Add(0, 10, function() self:Loop() end)
end

function ChildSpiritSuccessPanel:TimeStop()
    if self.runTimeId ~= 0 then
        LuaTimer.Delete(self.runTimeId)
        self.runTimeId = 0
    end
end

function ChildSpiritSuccessPanel:Loop()
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

--获取新的属性列表
function ChildSpiritSuccessPanel:GetCurAttrList()
	-- self.lookData.mainChildData
	-- self.lookData.spritPetData.name

    local mainChildData = self.lookData.mainChildData
    local list = {
        [1] = {name = 1, val = mainChildData.hp_max, icon = "AttrIcon1"} --生命上限
		,[4] = {name = 4, val = mainChildData.phy_dmg, icon = "AttrIcon4"} --物攻
        ,[5] = {name = 5, val = mainChildData.magic_dmg, icon = "AttrIcon5"} --魔攻
        ,[6] = {name = 6, val = mainChildData.phy_def, icon = "AttrIcon6"} --物防
        ,[7] = {name = 7, val = mainChildData.magic_def, icon = "AttrIcon7"} --魔防
        -- ,[3] = {name = 3, val = mainChildData.atk_speed, icon = "AttrIcon3"} --攻击速度
    }

    local data_child_spirt_score = self.model:GetChildSpirtScoreByTalent(self.lookData.spritPetData.base_id, self.lookData.spritPetData.talent)
    local data_child_spirt_attr = DataPet.data_child_spirt_attr[self.lookData.spritPetData.lev]
	local attr_ratio = data_child_spirt_score.attr_ratio

	list[1].val = list[1].val + BaseUtils.Round(data_child_spirt_attr.hp_max * attr_ratio / 1000)
	list[4].val = list[4].val + BaseUtils.Round(data_child_spirt_attr.phy_dmg * attr_ratio / 1000)
	list[5].val = list[5].val + BaseUtils.Round(data_child_spirt_attr.magic_dmg * attr_ratio / 1000)
	list[6].val = list[6].val + BaseUtils.Round(data_child_spirt_attr.phy_def * attr_ratio / 1000)
	list[7].val = list[7].val + BaseUtils.Round(data_child_spirt_attr.magic_def * attr_ratio / 1000)
	-- list[3].val = list[3].val + BaseUtils.Round(data_child_spirt_attr.atk_speed * attr_ratio / 1000)

    local attach_pet = nil
    local attach_pet_id = self.lookData.mainChildData.attach_pet_ids[1]
    if attach_pet_id ~= nil then -- 如果本来有附灵宠，先把附灵宠属性减去
        attach_pet = self.model:getpet_byid(attach_pet_id)

        local data_child_spirt_score = self.model:GetChildSpirtScoreByTalent(attach_pet.base_id, attach_pet.talent)
        local data_child_spirt_attr = DataPet.data_child_spirt_attr[attach_pet.lev]
        local attr_ratio = data_child_spirt_score.attr_ratio

        list[1].val = list[1].val - BaseUtils.Round(data_child_spirt_attr.hp_max * attr_ratio / 1000)
        list[4].val = list[4].val - BaseUtils.Round(data_child_spirt_attr.phy_dmg * attr_ratio / 1000)
        list[5].val = list[5].val - BaseUtils.Round(data_child_spirt_attr.magic_dmg * attr_ratio / 1000)
        list[6].val = list[6].val - BaseUtils.Round(data_child_spirt_attr.phy_def * attr_ratio / 1000)
        list[7].val = list[7].val - BaseUtils.Round(data_child_spirt_attr.magic_def * attr_ratio / 1000)
    end

    return list
end

-- --属性列表减去原有的附灵宠属性
-- function ChildSpiritSuccessPanel:SubOldSpritPetAttrList(list)
--     local attach_pet = nil
--     local attach_pet_id = self.lookData.mainChildData.attach_pet_ids[1]
--     if attach_pet_id ~= nil then -- 如果本来有附灵宠，先把附灵宠属性减去
--         attach_pet = self.model:getpet_byid(attach_pet_id)

--         local data_child_spirt_score = self.model:GetChildSpirtScoreByTalent(attach_pet.base_id, attach_pet.talent)
--         local data_child_spirt_attr = DataPet.data_child_spirt_attr[attach_pet.lev]
--         local attr_ratio = data_child_spirt_score.attr_ratio

--         list[1].val = list[1].val - BaseUtils.Round(data_child_spirt_attr.hp_max * attr_ratio / 1000)
--         list[4].val = list[4].val - BaseUtils.Round(data_child_spirt_attr.phy_dmg * attr_ratio / 1000)
--         list[5].val = list[5].val - BaseUtils.Round(data_child_spirt_attr.magic_dmg * attr_ratio / 1000)
--         list[6].val = list[6].val - BaseUtils.Round(data_child_spirt_attr.phy_def * attr_ratio / 1000)
--         list[7].val = list[7].val - BaseUtils.Round(data_child_spirt_attr.magic_def * attr_ratio / 1000)
--     end

--     return list
-- end