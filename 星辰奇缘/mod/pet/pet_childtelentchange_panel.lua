-- ----------------------------------------------------------------
-- 子女天赋更换
-- hosr
-- 界面后面调整过的，天翻地覆，参数名来不及改了，不要左右不分了
-- -----------------------------------------------------------------
PetChildTelnetChangePanel = PetChildTelnetChangePanel or BaseClass(BaseWindow)

function PetChildTelnetChangePanel:__init(model)
	self.model = model
    self.windowId = WindowConfig.WinID.pet_change_telnet
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.effect = nil
    self.effectPath = string.format(AssetConfig.effect, 20049)

	self.resList = {
		{file = AssetConfig.petchildchangetelent, type = AssetType.Main},
        {file = AssetConfig.childtelenticon, type = AssetType.Dep},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
        {file = self.effectPath, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.itemList = {}
    self.currItem = nil
    self.currIndex = 0
    self.canUp = false
    self.lev = 1
    self.isChange = false

    self.listener = function() self:ProtoUpdate() end
    self.itemListener = function() self:ItemChange() end
    self.isProto = false
    self.currSkillLev = 1
end

function PetChildTelnetChangePanel:__delete()
    if self.slot ~= nil then
        self.slot:DeleteMe()
        self.slot = nil
    end
    if self.leftIcon ~= nil then
        self.leftIcon.sprite = nil
    end

    if self.rightIcon ~= nil then
        self.rightIcon.sprite = nil
    end

    if self.buyBtn ~= nil then
        self.buyBtn:DeleteMe()
        self.buyBtn = nil
    end

    self:OnHide()
    for i,v in ipairs(self.itemList) do
        v.icon.sprite = nil
        v.img.sprite = nil
    end
    self.itemList = nil
end

function PetChildTelnetChangePanel:OnShow()
    if self.openArgs ~= nil then
        self.child = self.openArgs.child
        self.index = self.openArgs.index
        self.lev = self.openArgs.lev or 1
    end

    self.isProto = false
    ChildrenManager.Instance.OnChildTelentUpdate:Add(self.listener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemListener)
	self:Update()

    if PetManager.Instance.model:CheckChildCanFollow() then
        local child = PetManager.Instance.model.currChild
        ChildrenManager.Instance:Require18624(child.child_id, child.platform, child.zone_id, ChildrenEumn.Status.Follow)
    end
end

function PetChildTelnetChangePanel:OnHide()
    ChildrenManager.Instance.OnChildTelentUpdate:Remove(self.listener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemListener)
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end

function PetChildTelnetChangePanel:OnClose()
    if self.isProto then
        WindowManager.Instance:CloseWindow(self, false)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {4, 3})
    else
        WindowManager.Instance:CloseWindow(self)
    end
end

function PetChildTelnetChangePanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petchildchangetelent))
    self.gameObject.name = "PetChildTelnetChangePanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self.tips = self.transform:Find("Main/Tips"):GetComponent(Text)
    self.tips.text = TI18N("更换技能将按照市场价格继承部分熟练度")

    local right = self.transform:Find("Main/Right")
    self.leftIcon = right:Find("SkillIcon/Icon"):GetComponent(Image)
    self.leftName = right:Find("SkillName"):GetComponent(Text)
    self.leftLev = right:Find("SkillLev1/Val"):GetComponent(Text)
    self.leftDesc = right:Find("Desc"):GetComponent(Text)
    right:Find("SkillLev1/LeftBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickLeft() end)
    right:Find("SkillLev1/RightBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickRight() end)

    right:Find("Desc/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon4")
    self.container = right:Find("Scroll/Container")
    self.containerRect = self.container:GetComponent(RectTransform)
    self.baseItem = self.container:Find("Item").gameObject
    self.baseItem:SetActive(false)

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(right:Find("Slot").gameObject, self.slot.gameObject)
    self.itemName = right:Find("ItemName"):GetComponent(Text)
    self.costtext = right:Find("ItemCost"):GetComponent(Text)
    self.costTextEXT = MsgItemExt.New(self.costtext, 160, 17, 29)
    -- right:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:ClickLearn() end)
    self.btnTxt = right:Find("Button/Text"):GetComponent(Text)
    self.buyBtn = BuyButton.New(right:Find("Button").gameObject, TI18N("更换"))
    self.buyBtn.key = "ChildTalentChange"
    self.buyBtn.protoId = 18620
    self.buyBtn:Show()

    local left = self.transform:Find("Main/Left")
    self.rightIcon = left:Find("Info/SkillIcon/Icon"):GetComponent(Image)
    self.rightName = left:Find("Info/SkillName"):GetComponent(Text)
    self.rightLev = left:Find("Info/SkillLev"):GetComponent(Text)
    self.rightDesc = left:Find("Info/Desc"):GetComponent(Text)
    left:Find("Info/Desc/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon4")

    self.info = left:Find("Info") .gameObject
    self.nothing = left:Find("Nothing").gameObject
    self.nothing:SetActive(false)

    self.slider = left:Find("Normal/Slider"):GetComponent(Slider)
    self.sliderVal = left:Find("Normal/Slider/Val"):GetComponent(Text)
    left:Find("Normal/Preview"):GetComponent(Button).onClick:AddListener(function() self:ClickPreview() end)

    self.full = left:Find("Full").gameObject
    self.fullDesc = left:Find("Full/Text"):GetComponent(Text)
    self.full:SetActive(false)
    self.normal = left:Find("Normal").gameObject

    self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
    self.effect.transform:SetParent(left:Find("Info/SkillIcon").transform)
    self.effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(33, -33, -400)
    self.effect:SetActive(false)

    self:OnShow()
end

function PetChildTelnetChangePanel:GetSkills(lev)
    local classes = 0
    if self.child ~= nil then
        classes = self.child.classes
    end
    self.skillList = {}
    for k,v in pairs(DataSkill.data_child_telent) do
        local ok = false
        for _,val in ipairs(v.classes) do
            if val == classes then
                ok = true
            end
        end

        if v.lev == lev and ok then
            table.insert(self.skillList, v)
        end
    end
end

function PetChildTelnetChangePanel:NewItem(index)
    local item = self.itemList[index]
    if item == nil then
        item = {}
        item.gameObject = GameObject.Instantiate(self.baseItem)
        local transform = item.gameObject.transform
        transform:SetParent(self.container)
        transform.localScale = Vector3.one
        transform.localPosition = Vector3(35 + 73 * (index - 1), 0, 0)
        item.img = transform:GetComponent(Image)
        item.icon = transform:Find("Icon"):GetComponent(Image)
        item.select = transform:Find("Select").gameObject
        transform:Find("Select").gameObject:SetActive(false)
        item.select:SetActive(false)
        item.gameObject:SetActive(true)
        item.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickItem(index) end)
        table.insert(self.itemList, item)
    end
    return item
end

function PetChildTelnetChangePanel:UpdateItem()
    for i,v in ipairs(self.skillList) do
        local item = self:NewItem(i)
        item.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childtelenticon, v.id)
    end

    self.containerRect.sizeDelta = Vector2(73 * #self.skillList, 80)

    if self.currIndex == 0 then
        self:ClickItem(1)
    else
        self:ClickItem(self.currIndex)
    end
end

function PetChildTelnetChangePanel:ClickItem(index)
    if self.currItem ~= nil then
        self.currItem.select:SetActive(false)
    end

    self.currItem = self.itemList[index]
    self.currItem.select:SetActive(true)
    self.currSkill = self.skillList[index]
    self.currIndex = index

    self:UpdateRight()
end

function PetChildTelnetChangePanel:UpdateRight()
    self.leftIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.childtelenticon, self.currSkill.id)
    self.leftName.text = self.currSkill.name
    self.leftLev.text = string.format("%s级效果", self.currSkill.lev)
    self.leftDesc.text = self.currSkill.desc

    -- self.currSkillLev = self.currSkill.lev

    self:UpdateCost()
    self:UpdateDesc(self.currSkillLev)
end

function PetChildTelnetChangePanel:UpdateCost()
    local skill = DataSkill.data_child_telent[string.format("%s_%s", self.currSkill.id, self.currSkill.lev)]
    local id = skill.loss[1][1]
    local num = skill.loss[1][2]
    local has = BackpackManager.Instance:GetItemCount(id)
    local itemdata = DataItem.data_get[id]
    if self.slot ~= nil then
        self.slot:SetAll(itemdata)
        self.slot:SetNum(has, num)
    end
    self.itemName.text = itemdata.name
    self.item_id = id

    local items = {[self.item_id] = {need = 1}}
    self.buyBtn:Layout(items, function() self:ClickLearn() end, function(data) self:SetNeedText(data, has, num) end)
end

function PetChildTelnetChangePanel:Update()
    self:GetSkills(self.lev)
    self:UpdateItem()

    if self.child == nil then
        return
    end
    self:UpdateLeft()
    self:ItemChange()
end

-- 根据上部分更新信息
function PetChildTelnetChangePanel:UpdateLeft()
    local telent = self.child.talent_skills[self.index]
    if telent == nil or telent.id == 0 then
        self.info:SetActive(false)
        self.nothing:SetActive(true)
        self.normal:SetActive(false)
        self.buyBtn.content = TI18N("学习")

        self.slider.value = 1
        self.sliderVal.text = TI18N("未学习")
        self.isChange = false

        self.full:SetActive(false)
        -- self.normal:SetActive(true)
        self.fullDesc.text = ""
    else
        self.isChange = true
        self.info:SetActive(true)
        self.nothing:SetActive(false)
        self.normal:SetActive(true)
        self.buyBtn.content = TI18N("更换")

        local skill = DataSkill.data_child_telent[string.format("%s_%s", telent.id, telent.lev)]
        self.rightIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.childtelenticon, skill.icon)
        self.rightName.text = skill.name
        self.rightLev.text = string.format("%s级", skill.lev)
        self.rightDesc.text = skill.desc

        self.slider.value = telent.exp / skill.max_exp
        self.sliderVal.text = string.format("%s/%s", telent.exp, skill.max_exp)

        if telent.lev == 5 then
            self.full:SetActive(true)
            self.normal:SetActive(false)
            self.fullDesc.text = string.format(TI18N("<color='#ffff9a'>%s</color>已达到最大等级"), skill.name)
        else
            self.full:SetActive(false)
            self.normal:SetActive(true)
            self.fullDesc.text = ""
        end
    end

    local items = {[self.item_id] = {need = 1}}
    self.buyBtn:Layout(items, function() self:ClickLearn() end)
    if self.buyBtn.gameObject == nil then
        return
    end
    if not (telent == nil or telent.id == 0) and telent.id == self.currSkill.id then
        self.buyBtn:Set_btn_txt(TI18N("无需更换"))
        self.buyBtn:EnableBtn(false)
        BaseUtils.SetGrey(self.buyBtn.gameObject.transform:GetComponent(Image), true)
    elseif not (telent == nil or telent.id == 0) then
        self.buyBtn:Set_btn_txt(TI18N("更换"))
        self.buyBtn:EnableBtn(true)
        BaseUtils.SetGrey(self.buyBtn.gameObject.transform:GetComponent(Image), false)
        -- self.buyBtn:ReleaseFrozon()
    else
        BaseUtils.SetGrey(self.buyBtn.gameObject.transform:GetComponent(Image), false)
        self.buyBtn:EnableBtn(true)
        self.buyBtn:Set_btn_txt(TI18N("学习"))
    end
end

function PetChildTelnetChangePanel:ClickLearn()
    if self.child == nil then
        return
    end

    if BaseUtils.get_unique_roleid(self.child.follow_id, self.child.f_zone_id, self.child.f_platform) ~= BaseUtils.get_self_id() then
        NoticeManager.Instance:FloatTipsByString(TI18N("孩子不在跟随中，无法操作"))
        return
    end

    local grade = self.index or 1
    if self.isChange then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("替换天赋技能后，熟练度将按照市场差价换算，天赋<color='#ffff00'>等级有可能下降</color>，是否替换")
        data.sureLabel = TI18N("替换")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() ChildrenManager.Instance:Require18620(self.child.child_id, self.child.platform, self.child.zone_id, self.item_id, grade - 1) end
        NoticeManager.Instance:ConfirmTips(data)
    else
        ChildrenManager.Instance:Require18620(self.child.child_id, self.child.platform, self.child.zone_id, self.item_id, grade - 1)
    end
end

function PetChildTelnetChangePanel:ItemChange()
    self:UpdateCost()
end

function PetChildTelnetChangePanel:ProtoUpdate()
    if self.child == nil then
        return
    end

    self.isProto = true
    self.child = ChildrenManager.Instance:GetChild(self.child.child_id, self.child.platform, self.child.zone_id)
    if self.index == nil then
        self.index = 1
    end
    self:UpdateLeft()

    self.effect:SetActive(false)
    self.effect:SetActive(true)
end

function PetChildTelnetChangePanel:ClickLeft()
    self.currSkillLev = math.max(1, self.currSkillLev - 1)
    self:UpdateDesc(self.currSkillLev)
end

function PetChildTelnetChangePanel:ClickRight()
    self.currSkillLev = math.min(5, self.currSkillLev + 1)
    self:UpdateDesc(self.currSkillLev)
end

function PetChildTelnetChangePanel:UpdateDesc(lev)
    local telent = self.child.talent_skills[self.index]
    local skillData = DataSkill.data_child_telent[string.format("%s_%s", self.currSkill.id, lev)]
    self.leftLev.text = string.format("%s级效果", lev)
    self.leftName.text = skillData.name
    self.leftDesc.text = skillData.desc
    if self.buyBtn.gameObject == nil then
        return
    end
    if not (telent == nil or telent.id == 0) and telent.id == self.currSkill.id then
        self.buyBtn:Set_btn_txt(TI18N("无需更换"))
        self.buyBtn.gameObject:GetComponent(Button).enabled = false
        BaseUtils.SetGrey(self.buyBtn.gameObject.transform:GetComponent(Image), true)
    elseif not (telent == nil or telent.id == 0) then
        self.buyBtn:Set_btn_txt(TI18N("更换"))
        self.buyBtn:EnableBtn(true)
        BaseUtils.SetGrey(self.buyBtn.gameObject.transform:GetComponent(Image), false)
        -- self.buyBtn:ReleaseFrozon()
    else
        BaseUtils.SetGrey(self.buyBtn.gameObject.transform:GetComponent(Image), false)
        self.buyBtn:EnableBtn(true)
        self.buyBtn:Set_btn_txt(TI18N("学习"))
    end
end

function PetChildTelnetChangePanel:ClickPreview()
    local info = {skillid = self.currSkill.id, skilllev = self.currSkill.lev}
    self.model:OpenChildTelentPreview(info)
end


function PetChildTelnetChangePanel:SetNeedText(data, has, need)
    -- BaseUtils.dump(data, "快捷数据")
    if has >= need then
        self.costtext.gameObject:SetActive(false)
    else
        self.costtext.gameObject:SetActive(true)
        for k,v in pairs(data) do
            if v.allprice < 0 then
                self.costTextEXT:SetData(string.format("<color='#df3435'>%s</color>{assets_2,%s}", math.abs(v.allprice), v.assets))
            else
                self.costTextEXT:SetData(string.format("<color='#ffff9a'>%s</color>{assets_2,%s}", v.allprice, v.assets))
            end
        end
    end
    if next(data) == nil then
        self.costtext.gameObject:SetActive(false)
    end
end