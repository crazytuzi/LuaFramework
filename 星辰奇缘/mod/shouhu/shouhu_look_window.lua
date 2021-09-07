ShouhuLookWindow  =  ShouhuLookWindow or BaseClass(BasePanel)

function ShouhuLookWindow:__init(model)
    self.name  =  "ShouhuLookWindow"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.shouhu_look_window, type  =  AssetType.Main}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep}
        ,{file = AssetConfig.shouhu_texture, type = AssetType.Dep}
    }
    self.is_open = false

    self.MainCon = nil
    self.CloseButton = nil

    --右边
    self.pRightCon = nil
    self.prop_list = nil

    --左边
    self.lCon_right = nil
    self.lConDetail = nil
    self.lConDetailTop = nil
    self.modelPreviewContainer = nil
    self.lConDetailMid = nil
    self.lConDetailMidTop = nil
    self.lTxtScore = nil
    self.equipList = nil
    self.ConShouhuEquip0 = nil
    self.ConShouhuEquip1 = nil
    self.ConShouhuEquip2 = nil
    self.ConShouhuEquip3 = nil
    self.ConShouhuEquip4 = nil
    self.ConShouhuEquip5 = nil
    self.lConDetailMidBottom = nil
    self.ScrollCon_rect = nil
    self.lOriginSkillCon = nil
    self.lCon_bottom = nil
    self.lImgItem = nil
    self.lTxtVal = nil
    self.current_dat = nil
    self.pSkillItemList = nil
    self.lRightSkillList = nil

    self.previewComp1 = nil

    return self
end

function ShouhuLookWindow:__delete()
    for i,v in ipairs(self.rightSkillList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.rightSkillList = nil

    if self.prop_list ~= nil then
        for k, v in pairs(self.prop_list) do
            local img_icon = v.transform:FindChild("ImgIcon"):GetComponent(Image)
            img_icon.sprite = nil
        end
    end

    self.MainCon = nil
    self.CloseButton = nil

    --右边
    self.pRightCon = nil
    self.prop_list = nil

    --左边
    self.lCon_right = nil
    self.lConDetail = nil
    self.lConDetailTop = nil
    self.modelPreviewContainer = nil
    self.lConDetailMid = nil
    self.lConDetailMidTop = nil
    self.lTxtScore = nil
    self.equipList = nil
    self.ConShouhuEquip0 = nil
    self.ConShouhuEquip1 = nil
    self.ConShouhuEquip2 = nil
    self.ConShouhuEquip3 = nil
    self.ConShouhuEquip4 = nil
    self.ConShouhuEquip5 = nil
    self.lConDetailMidBottom = nil
    self.ScrollCon_rect = nil
    self.lOriginSkillCon = nil
    self.lCon_bottom = nil
    self.lImgItem = nil
    self.lTxtVal = nil
    self.current_dat = nil
    self.pSkillItemList = nil
    self.lRightSkillList = nil

    -- 记得这里销毁
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end

    self.is_open = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function ShouhuLookWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_look_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ShouhuLookWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.is_open = true

    self.MainCon = self.gameObject.transform:Find("MainCon")
    self.CloseButton = self.gameObject.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function()
        self.model:CloseShouhuLookUI()
    end)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseShouhuLookUI() end)


    self.pRightCon = self.MainCon.transform:FindChild("Con_left").gameObject

    self.prop_list = {}
    for i=1,8 do
        local p = self.pRightCon.transform:FindChild(string.format("Item%s",i)).gameObject
        table.insert(self.prop_list, p)
    end

    --魂石
    self.lCon_right = self.MainCon.transform:FindChild("Con_right").gameObject
    self.lConDetail = self.lCon_right.transform:FindChild("ConDetail").gameObject
    self.lConDetail.transform:Find("midBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.lConDetailTop = self.lConDetail.transform:FindChild("Con_top").gameObject
    self.shouhu_name_txt = self.lConDetailTop.transform:FindChild("TxtTitle"):GetComponent(Text)
    self.lConDetailMid = self.lConDetail.transform:FindChild("Con_mid").gameObject
    self.lConDetailMidTop = self.lConDetailMid.transform:FindChild("ConTop").gameObject
    self.WakeUpCon = self.lConDetail.transform:FindChild("WakeUpCon")
    self.WakeUpCon = self.lConDetail.transform:FindChild("WakeUpCon")
    self.WakeUpCon.gameObject:SetActive(false)
    self.WakeUpIconList = {}
    for i = 1, 3 do
        local wakeUpIcon = self.WakeUpCon:FindChild(string.format("WakeUpIcon%s", i)).gameObject
        wakeUpIcon.transform:GetComponent(Button).onClick:AddListener(function()
            self:OnClickWakeUpStone(i)
        end)
        wakeUpIcon:SetActive(false)
        table.insert(self.WakeUpIconList, wakeUpIcon)
    end

    self.modelPreviewContainer=self.lConDetailMid.transform:FindChild("Preview").gameObject
    --等级，装备
    self.lTxtScore = self.lConDetail.transform:FindChild("ImgScoreBg"):FindChild("TxtScore"):GetComponent(Text)

    self.equipList = {}
    self.ConShouhuEquip0 = self.lConDetailMidTop.transform:FindChild("ConShouhuEquip0").gameObject
    self.ConShouhuEquip1 = self.lConDetailMidTop.transform:FindChild("ConShouhuEquip1").gameObject
    self.ConShouhuEquip2 = self.lConDetailMidTop.transform:FindChild("ConShouhuEquip2").gameObject
    self.ConShouhuEquip3 = self.lConDetailMidTop.transform:FindChild("ConShouhuEquip3").gameObject
    self.ConShouhuEquip4 = self.lConDetailMidTop.transform:FindChild("ConShouhuEquip4").gameObject
    self.ConShouhuEquip5 = self.lConDetailMidTop.transform:FindChild("ConShouhuEquip5").gameObject

    --装备
    self.equipList = {}
    local equip0 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip0, 1)
    local equip1 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip1, 1)
    local equip2 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip2, 1)
    local equip3 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip3, 1)
    local equip4 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip4, 1)
    local equip5 = ShouhuMainTabEquipItem.New(self, self.ConShouhuEquip5, 1)
    table.insert(self.equipList,equip0)
    table.insert(self.equipList,equip1)
    table.insert(self.equipList,equip2)
    table.insert(self.equipList,equip3)
    table.insert(self.equipList,equip4)
    table.insert(self.equipList,equip5)


    --战力

    self.lConDetailMidBottom = self.lConDetail.transform:FindChild("ConBottom").gameObject
    self.SkillItemCon = self.lConDetailMidBottom.transform:FindChild("SkillItemCon").gameObject
    self.ShouhuSkill1 = self.SkillItemCon.transform:FindChild("ShouhuSkill1").gameObject
    self.ShouhuSkill2 = self.SkillItemCon.transform:FindChild("ShouhuSkill2").gameObject
    self.ShouhuSkill3 = self.SkillItemCon.transform:FindChild("ShouhuSkill3").gameObject
    self.ShouhuSkill4 = self.SkillItemCon.transform:FindChild("ShouhuSkill4").gameObject
    self.ShouhuSkill5 = self.SkillItemCon.transform:FindChild("ShouhuSkill5").gameObject
    self.ShouhuSkill6 = self.SkillItemCon.transform:FindChild("ShouhuSkill6").gameObject
    self.ShouhuSkill7 = self.SkillItemCon.transform:FindChild("ShouhuSkill7").gameObject
    self.ShouhuSkill8 = self.SkillItemCon.transform:FindChild("ShouhuSkill8").gameObject

    self.skillItem_list = {}
    table.insert(self.skillItem_list, self.ShouhuSkill1)
    table.insert(self.skillItem_list, self.ShouhuSkill2)
    table.insert(self.skillItem_list, self.ShouhuSkill3)
    table.insert(self.skillItem_list, self.ShouhuSkill4)
    table.insert(self.skillItem_list, self.ShouhuSkill5)
    table.insert(self.skillItem_list, self.ShouhuSkill6)
    table.insert(self.skillItem_list, self.ShouhuSkill7)
    table.insert(self.skillItem_list, self.ShouhuSkill8)


    self.lCon_bottom = self.lCon_right.transform:FindChild("Con_bottom").gameObject
    self.lImgItem = self.lCon_bottom.transform:FindChild("ImgItem").gameObject
    self.lTxtVal = self.lImgItem.transform:FindChild("TxtVal"):GetComponent(Text)
    self:update_view(self.model.shouhu_look_dat)
end

--点击魂石弹出tips
function ShouhuLookWindow:OnClickWakeUpStone(quality)
    local tempStr = ""
    if quality == 1 then
        tempStr = TI18N("蓝")
    elseif quality == 2 then
        tempStr = TI18N("紫")
    elseif quality == 3 then
        tempStr = TI18N("橙")
    end
    local args = {base_id = self.model.shouhu_look_dat.base_id, quality = quality, pointIndex = 0, title = string.format(TI18N("%s色魂石已激活"), tempStr)}
    self.model:OpenWakeupPointTips(args)
end

function ShouhuLookWindow:update_view(dat)
    self.current_dat = dat
    self.model.my_sh_selected_look_data = dat
    self:set_list_rights(dat)
    self:on_update_skill()
    for i=1,#self.WakeUpIconList do
        self.WakeUpIconList[i]:SetActive(false)
    end
    self.WakeUpCon.gameObject:SetActive(true)
    local curWakeUpQuality = self.model.shouhu_look_dat.quality
    local baseQuality = DataShouhu.data_guard_base_cfg[self.model.shouhu_look_dat.base_id].quality
    if curWakeUpQuality > baseQuality then
        local index = curWakeUpQuality - 1
        for i=baseQuality, index do
            if self.WakeUpIconList[i] then
                self.WakeUpIconList[i]:SetActive(true)
            end
        end
    end
    local curPosition = self.WakeUpCon:GetComponent(RectTransform).anchoredPosition
    self.WakeUpCon:GetComponent(RectTransform).anchoredPosition = Vector2(curPosition.x, 3 + (baseQuality-1)*60)
end

--设置守护酒馆右边界面的内容
function ShouhuLookWindow:set_prop(dat)

    local allAttrDic = {}
    allAttrDic[1] = {1,dat.sh_attrs_list.hp_max, "AttrIcon1"} --生命上限
    allAttrDic[2] = {2,dat.sh_attrs_list.mp_max, "AttrIcon2"} --魔法上限
    allAttrDic[53] = {53,dat.sh_attrs_list.atk_speed, "AttrIcon3"} --攻击速度
    allAttrDic[4] = {4,dat.sh_attrs_list.phy_dmg, "AttrIcon4"} --物攻
    allAttrDic[5] = {5,dat.sh_attrs_list.magic_dmg, "AttrIcon5"} --魔攻
    allAttrDic[6] = {6,dat.sh_attrs_list.phy_def, "AttrIcon6"} --物防
    allAttrDic[7] = {7,dat.sh_attrs_list.magic_def, "AttrIcon7"} --魔防
    allAttrDic[43] = {43,dat.sh_attrs_list.heal_val, "AttrIcon1"} --魔防

    for i=1, #dat.sh_attrs_list do
        local aDat = dat.sh_attrs_list[i]
        if allAttrDic[aDat.attr] ~= nil then
            allAttrDic[aDat.attr][2] = allAttrDic[aDat.attr][2]+ aDat.val
        end
    end

    local index = 1
    for k, v in pairs(allAttrDic) do
        local item = self.prop_list[index]
        local txt_name = item.transform:FindChild("TxtDesc"):GetComponent(Text)
        local txt_val = item.transform:FindChild("TxtValue"):GetComponent(Text)
        local img_icon = item.transform:FindChild("ImgIcon"):GetComponent(Image)
        img_icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon,v[3])
        txt_name.text = KvData.attr_name[k]
        txt_val.text = tostring(v[2])
        index = index + 1
    end
end

--设置我的守护右边的信息内容
function ShouhuLookWindow:set_list_rights(dat)
    -- 守护信息
    self.lTxtVal.text = string.format("%s:<color='#C7F9FF'>%s</color>", TI18N("拥有者"), self.current_dat.owner_name)
    self.lTxtScore.text = string.format("%s%s",TI18N("评分:"), dat.score) --评分

    self.shouhu_name_txt.text = ColorHelper.color_item_name(dat.quality , dat.alias)

    -- 更新模型
    self:update_sh_model(dat)

    --装备
    dat.look_type = true
    if dat.equip_list ~= nil then
        for i=1, #dat.equip_list do-- 装备
            local d = dat.equip_list[i]
            local equip = self.equipList[i]
            equip:set_equip_my_sh_data(dat)
            equip:set_sh_equip_item_data(d)
        end
    end

    -- 详细信息
    self:set_prop(dat)
end

--更新技能
function ShouhuLookWindow:on_update_skill()
    ----技能逻辑
    if self.rightSkillList ==nil then
        self.rightSkillList = {}
    end

    for i=1,#self.rightSkillList do
        local skillItem = self.rightSkillList[i]
        skillItem.gameObject:SetActive(false)
    end


    if self.current_dat.actSkillDic  == nil then
        self.current_dat.actSkillDic = self.model:get_skill_data_dic_by_base_id(self.current_dat.base_id)
    end

    for i=1, #self.current_dat.has_get_skill_list do--设置那些已经激活
        local skillId = self.current_dat.has_get_skill_list[i]
        for j=1, #self.current_dat.actSkillDic do
            local temp_data = self.current_dat.actSkillDic[j]
            if temp_data.skill_id == skillId then
                temp_data.hasGet = true
            end
        end
    end

    local index = 1
    for i=1, #self.current_dat.actSkillDic do
        local temp = self.current_dat.actSkillDic[i]

        local skillItem = self.rightSkillList[i]
        if skillItem == nil then
            skillItem = SkillSlot.New()--ShouhuMainTabSkillItem.New(self, self.skillItem_list[i], temp)
            self.rightSkillList[i] = skillItem
            UIUtils.AddUIChild(self.skillItem_list[i], skillItem.gameObject)
        end

        local skillData = DataSkill.data_skill_guard[string.format("%s_1", temp[1])]
        skillItem:SetAll(Skilltype.shouhuskill,{id = skillData.id, icon = skillData.icon, lev = temp[2]})
        skillItem.gameObject:SetActive(true)
        index = index + 1
    end

    local wakeUpSkillList = self.model:get_wakeup_skills(self.current_dat.base_id)
    for i = 1, #wakeUpSkillList do
        local wakeUpData = wakeUpSkillList[i]
        local skillData = DataSkill.data_skill_guard[string.format("%s_1", wakeUpData[1])]
        local skillItem = self.rightSkillList[index]
        if skillItem == nil then
            skillItem = SkillSlot.New()
            self.rightSkillList[index] = skillItem
            UIUtils.AddUIChild(self.skillItem_list[index], skillItem.gameObject)
        end
        skillItem:SetAll(Skilltype.shouhuskill, {id = skillData.id, icon = skillData.icon, quality = wakeUpData[2]})
        skillItem.gameObject:SetActive(true)
        index = index + 1

        if self.current_dat.quality >= wakeUpData[2] then
            BaseUtils.SetGrey(skillItem.skillImg, false)
        else
            BaseUtils.SetGrey(skillItem.skillImg, true)
        end
    end
end

--更新守护模型
function ShouhuLookWindow:update_sh_model(shdata)
    local res_id = shdata.res_id
    local animation_id = shdata.animation_id
    local paste_id = shdata.paste_id
    local wakeUpCfgData = DataShouhu.data_guard_wakeup_upgrade[string.format("%s_%s", shdata.base_id, shdata.quality)]
    if wakeUpCfgData ~= nil and wakeUpCfgData.model ~= 0 then
        res_id = wakeUpCfgData.model
        paste_id = wakeUpCfgData.skin
        animation_id = wakeUpCfgData.animation
    end

    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end
    local setting = {
        name = "Shouhu"
        ,orthographicSize = 0.9
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Shouhu, skinId = paste_id, modelId = res_id, animationId = animation_id, scale = 1}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp1:Reload(modelData, callback)
    end
end

--守护模型加载完成
function ShouhuLookWindow:on_model_build_completed(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.modelPreviewContainer.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end