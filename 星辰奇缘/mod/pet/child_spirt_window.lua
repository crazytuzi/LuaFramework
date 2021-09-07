-- ----------------------------------------------------------
-- 子女附灵
-- ----------------------------------------------------------
ChildSpirtWindow = ChildSpirtWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function ChildSpirtWindow:__init(model)
    self.model = model
    self.name = "ChildSpirtWindow"
    self.windowId = WindowConfig.WinID.childSpirtWindow
    self.winLinkType = WinLinkType.Link
    -- self.cacheMode = CacheMode.Visible
    --
    self.resList = {
        {file = AssetConfig.childspiritwindow, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.rolebgnew, type = AssetType.Dep}
        , {file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.playkillbgcycle, type = AssetType.Dep}
        ,{file = AssetConfig.childhead, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil

    ------------------------------------------------
    self.headlist = {}
    self.headLoaderList = {}
    self.petnum_max = 0

    self.attrItemList = {}

    ------------------------------------------------
    self._OnUpdate = function()
        self:OnUpdate()
    end

    self._onOkButtonClick = function()
        self:onOkButtonClick()
    end
    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.headList = {}
end

function ChildSpirtWindow:__delete()
    self:OnHide()

    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end

    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end

    if self.headLoader2 ~= nil then
        self.headLoader2:DeleteMe()
        self.headLoader2 = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ChildSpirtWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childspiritwindow))
    self.gameObject.name = "ChildSpirtWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.mainTransform:Find("Info/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.playkillbgcycle, "PlayKillBgCycle")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.transform:FindChild("Panel").gameObject:AddComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.tabGroupObj = self.mainTransform:FindChild("TabButtonGroup").gameObject
    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {0, 0, 0, 68},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, tabGroupSetting, { notAutoSelect = true })

    self.tabGroupObj2 = self.mainTransform:FindChild("Info/TabButtonGroup").gameObject
    self.tabGroup2 = TabGroup.New(self.tabGroupObj2, function(index) self:ChangeTab2(index) end, { notAutoSelect = true })

    self.telnetButton = self.mainTransform:FindChild("Info/TelnetButton"):GetComponent(Button)
    self.telnetButton.onClick:AddListener(function()
        if self.lock then
            local info = {child = PetManager.Instance.model.currChild}
            self.model.mySubIndex = 1
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_change_telnet, info)
            return
        else
            self:ChangeTab2(3)
        end
    end)
    self.telnetButton.gameObject:SetActive(true)
    self.telnetButtonRedPoint = self.telnetButton.transform:FindChild("RedPoint").gameObject

    self.spiritButton = self.mainTransform:FindChild("Info/SpiritButton"):GetComponent(Button)

    self.skinButton = self.mainTransform:FindChild("Info/SkinButton"):GetComponent(Button)
    self.skinButton.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ChildSkinWindow) end)
    ----------------------------------------------------------------------------

    self.infoPanel = self.mainTransform:FindChild("Info")

    self.mainChildHead = self.infoPanel:FindChild("MainPetHead/Head")
    self.mainPetLevel = self.infoPanel:FindChild("MainPetLevel").gameObject
    self.mainPetLevelText = self.infoPanel:FindChild("MainPetLevel/Text"):GetComponent(Text)

    self.head = self.infoPanel:FindChild("Head_78/Head")
    self.headPoint = self.head.transform.position
    self.spritPetLevel = self.infoPanel:FindChild("SpirtPetLevel").gameObject
    self.spritPetLevelText = self.infoPanel:FindChild("SpirtPetLevel/Text"):GetComponent(Text)

    self.descText = self.infoPanel:FindChild("DescText"):GetComponent(Text)

    self.cancelButton = self.infoPanel:FindChild("CancelButton"):GetComponent(Button)
    self.cancelButton.onClick:AddListener(function() self:onCancelButtonClick() end)

    self.descPanel = self.infoPanel:FindChild("DescPanel").gameObject
    self.descPanelText = self.infoPanel:FindChild("DescPanel/DescText"):GetComponent(Text)
    self.descPanelText2 = self.infoPanel:FindChild("DescPanel/DescText2"):GetComponent(Text)

    self.descPanelText.text = TI18N("1、玩家达到<color='#ffff00'>80级</color>后可对<color='#ffff00'>子女</color>进行附灵\n2、附灵宠物等级不低于子女<color='#ffff00'>当前等级5级 </color>\n3、附灵宠物<color='#ffff00'>携带等级≥75级</color>，且达到一定评分\n4、附灵宠物<color='#ffff00'>评分和等级</color>越高，增加<color='#ffff00'>属性和附灵技能</color>等级越高\n5、携带后父母双方可<color='#ffff00'>单独</color>对子女附灵，附灵效果<color='#ffff00'>各不影响</color>")
    self.descPanelText2.text = TI18N("宠物附灵后可对该子女提升<color='#00ff00'>属性</color>与<color='#00ff00'>增加技能</color>")

    self.pointText = self.infoPanel:FindChild("PointText"):GetComponent(Text)

    self.skillPanel = self.infoPanel:FindChild("SkillPanel").gameObject
    self.skillPanelText1 = self.skillPanel.transform:FindChild("Text1"):GetComponent(Text)
    self.skillPanelText2 = self.skillPanel.transform:FindChild("Text2"):GetComponent(Text)
    self.skillPanelText3 = self.skillPanel.transform:FindChild("Text3"):GetComponent(Text)
    self.skillPanelText4 = self.skillPanel.transform:FindChild("Text4"):GetComponent(Text)
    self.skillPanelSkillIcon = SkillSlot.New()
    UIUtils.AddUIChild(self.skillPanel.transform:FindChild("SkillIcon").gameObject, self.skillPanelSkillIcon.gameObject)
    self.nextSkillButton = self.skillPanel.transform:FindChild("NextSkillButton"):GetComponent(Button)
    self.nextSkillButton.onClick:AddListener(function() self:onNextSkillButtonClick() end)

    self.attrPanel = self.infoPanel:FindChild("AttrPanel").gameObject
    self.attrObject_Clone = self.attrPanel.transform:FindChild("Mask/Panel/AttrObject").gameObject
    self.attrContainer = self.attrPanel.transform:FindChild("Mask/Panel")
    self.attrMaskObj = self.attrPanel.transform:FindChild("Mask").gameObject
    self.noAttrTextObj = self.attrPanel.transform:FindChild("NoAttrText").gameObject
    -- self.descTextObj = self.attrPanel.transform:FindChild("DescText").gameObject

    --------------------------------
    local btn = self.infoPanel:FindChild("Head_78"):GetComponent(Button)
    btn.onClick:AddListener(function() self:onOkButtonClick() end)
    self.okButton = btn

    self.infoPanel:FindChild("HandBookButton"):GetComponent(Button).onClick:AddListener(function() self:onHandBookButtonClick() end)

    ----------------------------
    for k,v in pairs(DataPet.data_add_pet_nums) do
        if v.pet_nums > self.petnum_max then
            self.petnum_max = v.pet_nums
        end
    end

    self.container = self.mainTransform:Find("HeadChildBar/mask/HeadContainer").gameObject
    self.childHeabarBaseItem = self.container.transform:Find("PetHead").gameObject
    self.childHeabarBaseItem.gameObject:SetActive(false)
    self:InitItem()
    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function ChildSpirtWindow:InitItem()
    for i = 1, 6 do
        local index = i
        local item = PetChildHeadItem.New(GameObject.Instantiate(self.childHeabarBaseItem),self, index)
        item:ShowAdd()
        table.insert(self.headList, item)
    end
end

function ChildSpirtWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet)
    -- self.model:CloseChildSpirtWindow()
end

function ChildSpirtWindow:OnShow()
    PetManager.Instance.OnUpdatePetList:Add(self._OnUpdate)
    PetManager.Instance.OnPetUpdate:Add(self._OnUpdate)
    self.currIndex = 0
    self.tabGroup:ChangeTab(4)
    self:Update()
end

function ChildSpirtWindow:OnHide()
    PetManager.Instance.OnUpdatePetList:Remove(self._OnUpdate)
    PetManager.Instance.OnPetUpdate:Remove(self._OnUpdate)
end

function ChildSpirtWindow:Update()
    self:UpdateHeadBar()
end

function ChildSpirtWindow:OnUpdate()
    self:Update()
end

function ChildSpirtWindow:UpdateHeadBar()
    local childlist = ChildrenManager.Instance.childData
    local list = {}

    for k,v in pairs(childlist) do
        if v.stage == 3 then
            table.insert(list,v)
        end
    end

    table.sort(list, function(a,b)
            if a.stage == b.stage then
                return a.child_id < b.child_id
            else
                return a.stage > b.stage
            end
        end)

    local headnum = self.model.pet_nums
    local headlist = self.headlist
    local data



    local selectBtn = nil
    if #list > 0 then
        for i,item in ipairs(self.headList) do
            local dat = list[i]
            if dat ~= nil then
                dat.attach_pet_ids = {}
                for i = 1, #PetManager.Instance.model.petlist do
                    local data = PetManager.Instance.model.petlist[i]
                    if data.spirit_child_flag == 1 then
                        if data.child_id == dat.child_id and data.platform == dat.platform and data.zone_id == dat.zone_id then
                            table.insert(dat.attach_pet_ids,data.id)
                        end
                    end
                end
                item:SetData(dat)
                if #dat.attach_pet_ids > 0 then
                    item.transform:FindChild("AttachHeadIcon").gameObject:SetActive(true)
                    local attach_pet_id = dat.attach_pet_ids[1]
                    local attach_pet_data = self.model:getpet_byid(attach_pet_id)
                    local headId = tostring(attach_pet_data.base.head_id)
                    local loaderId = item.gameObject:GetInstanceID()
                    if self.headLoaderList[loaderId] == nil then
                        self.headLoaderList[loaderId] = SingleIconLoader.New(item.transform:FindChild("AttachHeadIcon/Image").gameObject)
                    end
                    self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
            -- headitem.transform:FindChild("AttachHeadIcon/Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
                else
                    item.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)
                end

            else
                item:ShowAdd()
            end
        end
    else
    end
    self.currIndex = PetManager.Instance.model.currIndex or 0
    if #list > 0 then
        if self.currIndex == 0 then
            self.currIndex = 1
        end
        self.headList[self.currIndex]:ClickSelf()
    end
end
function ChildSpirtWindow:UpdateTabGroup()
    self.lock = false
    table.sort(self.child.talent_skills, function(a,b) return a.grade < b.grade end)
    if self.child ~= nil and #self.child.talent_skills == 0 then
        self.lock = true
    elseif self.child ~= nil and #self.child.talent_skills >= 1 and self.child.talent_skills[1].id == 0 then
        self.lock = true
    end

    if self.lock then
        self.model.mySubIndex = 1
        self.tabGroup2.cannotSelect = {false, false, true}
    else
        self.tabGroup2.cannotSelect = {false, false, false}
    end
end

function ChildSpirtWindow:UpdateInfo()
    self.child = PetManager.Instance.model.currChild

    local petlist = PetManager.Instance.model.petlist
    self:UpdateTabGroup()
    -- BaseUtils.dump(PetManager.Instance.model.currChild,"当前孩子数据=========================")
    -- BaseUtils.dump(petlist,"宠物列表========================================================")
    PetManager.Instance.model.currChild.attach_pet_ids = {}
    for i = 1, #petlist do
        local data = petlist[i]
        if data.spirit_child_flag == 1 then
            if data.child_id == PetManager.Instance.model.currChild.child_id and data.platform == PetManager.Instance.model.currChild.platform and data.zone_id == PetManager.Instance.model.currChild.zone_id then
                table.insert(PetManager.Instance.model.currChild.attach_pet_ids,data.id)
            end
        end
    end

    local childData = PetManager.Instance.model.currChild






    local sprite = self.assetWrapper:GetSprite(AssetConfig.childhead, string.format("%s%s", childData.classes_type, childData.sex))
    if sprite == nil then
        sprite = PreloadManager.Instance:GetSprite(AssetConfig.childhead, string.format("%s%s", childData.classes_type, childData.sex))
    end

    self.mainChildHead:GetComponent(Image).sprite = sprite
    self.mainChildHead:GetComponent(Image).rectTransform.sizeDelta = Vector2(54, 54)

    if childData.attach_pet_ids == nil or #childData.attach_pet_ids == 0 then -- 没有附灵宠物
        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.head:GetComponent(Image).gameObject)
        end
        self.headLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"BidAddImage"))
        -- self.head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage")
        self.head:GetComponent(Image).rectTransform.sizeDelta = Vector2(32, 36)

        self.cancelButton.gameObject:SetActive(false)

        self.mainPetLevel:SetActive(true)
        self.spritPetLevel:SetActive(false)
        self.mainPetLevelText.text = tostring(childData.lev)

        self.descPanel:SetActive(true)

        self.descText.gameObject:SetActive(true)
        self.pointText.text = ""
        self.skillPanel:SetActive(false)
        self.attrMaskObj:SetActive(false)
        -- self.descTextObj:SetActive(true)
        self.noAttrTextObj:SetActive(true)
    else -- 有附灵宠
        local spritPetData = self.model:getpet_byid(childData.attach_pet_ids[1])
        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.head:GetComponent(Image).gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet,spritPetData.base.head_id)

        -- self.head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(spritPetData.base.head_id), spritPetData.base.head_id)
        self.head:GetComponent(Image).rectTransform.sizeDelta = Vector2(54, 54)

        self.cancelButton.gameObject:SetActive(false)

        self.mainPetLevel:SetActive(true)
        self.spritPetLevel:SetActive(true)
        self.mainPetLevelText.text = tostring(childData.lev)
        self.spritPetLevelText.text = tostring(spritPetData.lev)

        self.descPanel:SetActive(false)

        self.descText.gameObject:SetActive(false)
        self.pointText.text = string.format(TI18N("<color='#ffff88'>评分(%s)</color>"), spritPetData.talent)
        self.skillPanel:SetActive(true)
        self.attrMaskObj:SetActive(true)
        -- self.descTextObj:SetActive(false)

        self:UpdateSkill(spritPetData)
        self:UpdateAttr(spritPetData)
    end

    self:UpdateSpirtButtonEffect()
end

function ChildSpirtWindow:UpdateSkill(petData)
    local data_child_spirt_score = self.model:GetChildSpirtScoreByTalent(petData.base_id, petData.talent)
    local activeSkillMark = true
    if data_child_spirt_score == nil or #data_child_spirt_score.skills == 0 then
        data_child_spirt_score = self.model:GetChildSpirtScoreBySkillLevel(petData.base_id, 0)
        activeSkillMark = false
    end
    -- BaseUtils.dump(data_child_spirt_score, "data_child_spirt_score")
    local skillData = DataSkill.data_petSkill[string.format("%s_%s", data_child_spirt_score.skills[1][1], data_child_spirt_score.skills[1][2])]

    self.skillPanelText1.text = string.format("<color='#ffff00'>%s</color>", skillData.name)
    self.skillPanelText2.text = skillData.desc
    if activeSkillMark then
        local next_data_child_spirt_score = self.model:GetPetSpirtScoreBySkillLevel(petData.base_id, data_child_spirt_score.skill_lev)

        if next_data_child_spirt_score ~= nil then
            local nextSkillData = DataSkill.data_petSkill[string.format("%s_%s", next_data_child_spirt_score.skills[1][1], next_data_child_spirt_score.skills[1][2])]
            self.skillPanelText3.text = string.format(TI18N("达到<color='#00ff00'>%s评分</color>激活下一等级"), next_data_child_spirt_score.talent_min)
            self.nextSkillButton.gameObject:SetActive(true)
            self.nextSkillData = nextSkillData
        else
            self.skillPanelText3.text = TI18N("<color='#ffff00'>已到达最高等级</color>")
            self.nextSkillButton.gameObject:SetActive(false)
        end

        -- self.skillPanelText4.text = TI18N("<color='#00ff00'>技能已激活</color>")
        self.skillPanelText4.text = ""

        self.skillPanelSkillIcon:SetAll(Skilltype.petskill, skillData)
        self.skillPanelSkillIcon:SetGrey(false)
    else
        self.skillPanelText3.text = string.format(TI18N("达到<color='#00ff00'>%s评分</color>激活<color='#ffff00'>%s</color>"), data_child_spirt_score.talent_min, skillData.name)
        -- self.skillPanelText4.text = TI18N("<color='#ff0000'>技能未激活</color>")
        self.skillPanelText4.text = ""

        self.skillPanelSkillIcon:SetAll(Skilltype.petskill, skillData)
        self.skillPanelSkillIcon:SetGrey(true)

        self.nextSkillButton.gameObject:SetActive(true)
        self.nextSkillData = skillData
    end

    self:UpdateSkillEffect()
end

function ChildSpirtWindow:onNextSkillButtonClick()
    local info = {gameObject = self.nextSkillButton.gameObject, skillData = self.nextSkillData, type = Skilltype.petskill}
    TipsManager.Instance:ShowSkill(info, true)
end

function ChildSpirtWindow:UpdateAttr(petData)
    local data_child_spirt_score = self.model:GetChildSpirtScoreByTalent(petData.base_id, petData.talent)

    if data_child_spirt_score == nil or data_child_spirt_score.attr_ratio == 0 then
        self.attrContainer.gameObject:SetActive(false)
        self.noAttrTextObj:SetActive(true)
    else
        self.attrContainer.gameObject:SetActive(true)
        self.noAttrTextObj:SetActive(false)

        local data_child_spirt_attr = DataPet.data_child_spirt_attr[petData.lev]
        local attr_ratio = data_child_spirt_score.attr_ratio

        local temp = {}
        table.insert(temp, { key = 1, value = BaseUtils.Round(data_child_spirt_attr.hp_max * attr_ratio / 1000) } )
        table.insert(temp, { key = 2, value = BaseUtils.Round(data_child_spirt_attr.mp_max * attr_ratio / 1000) } )
        table.insert(temp, { key = 4, value = BaseUtils.Round(data_child_spirt_attr.phy_dmg * attr_ratio / 1000) } )
        table.insert(temp, { key = 5, value = BaseUtils.Round(data_child_spirt_attr.magic_dmg * attr_ratio / 1000) } )
        table.insert(temp, { key = 6, value = BaseUtils.Round(data_child_spirt_attr.phy_def * attr_ratio / 1000) } )
        table.insert(temp, { key = 7, value = BaseUtils.Round(data_child_spirt_attr.magic_def * attr_ratio / 1000) } )
        table.insert(temp, { key = 3, value = BaseUtils.Round(data_child_spirt_attr.atk_speed * attr_ratio / 1000) } )

        local attr_list = {}
        for i=1, #temp do
            if temp[i].value ~= 0 then
                table.insert(attr_list, temp[i])
            end
        end

        if #attr_list ~= 0 then
            self.noAttrTextObj:SetActive(false)
        else
            self.noAttrTextObj:SetActive(true)
        end
        self.attr_list = attr_list

        for i=1, #attr_list do
            local item = self.attrItemList[i]
            if item == nil then
                item = GameObject.Instantiate(self.attrObject_Clone)
                item:SetActive(true)
                item.transform:SetParent(self.attrContainer)
                item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
                self.attrItemList[i] = item
            end

            item:SetActive(true)
            -- if string.len(KvData.GetAttrName(attr_list[i].key)) > 6 then
            --     item.transform:FindChild("ValueText").sizeDelta = Vector2(101, 27)
            --     item.transform:FindChild("ValueText").anchoredPosition = Vector2(97, 0)
            -- else
            --     item.transform:FindChild("ValueText").sizeDelta = Vector2(128.2, 27)
            --     item.transform:FindChild("ValueText").anchoredPosition = Vector2(72.2, 0)
            -- end

            item.transform:FindChild("NameText"):GetComponent(Text).text = string.format("%s:", KvData.GetAttrName(attr_list[i].key))
            item.transform:FindChild("ValueText"):GetComponent(Text).text = math.ceil(attr_list[i].value)

            item.transform:FindChild("Icon"):GetComponent(Image).sprite
                = self.assetWrapper:GetSprite(AssetConfig.attr_icon, string.format("AttrIcon%s", tostring(KvData.attr_icon[attr_list[i].key])))
        end

        if #attr_list < #self.attrItemList then
            for i=#attr_list+1, #self.attrItemList do
                item = self.attrItemList[i]
                if item ~= nil then
                    item:SetActive(false)
                end
            end
        end
    end
end

function ChildSpirtWindow:onHeadItemClick(item)

    self.selectIndex = 0

    local head
    for i = 1, #self.headlist do
        head = self.headlist[i]
        head.transform:FindChild("Select").gameObject:SetActive(false)
    end
    item.transform:FindChild("Select").gameObject:SetActive(true)

    self:UpdateInfo()

end

function ChildSpirtWindow:onHeadAddClick()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("你是否要前往宠物图鉴查看可携带宠物？")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() self.model:OpenPetWindow({3})  end
    NoticeManager.Instance:ConfirmTips(data)
end

function ChildSpirtWindow:onHeadLockClick(item)
    local itembase = BackpackManager.Instance:GetItemBase(DataPet.data_add_pet_nums[self.model.pet_nums].need_item[1].item_id)

    local str = string.format(TI18N("是否消耗%s%s开启宠物栏？")
        , DataPet.data_add_pet_nums[self.model.pet_nums].need_item[1].item_val
        , ColorHelper.color_item_name(itembase.quality, itembase.name))

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = str
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() PetManager.Instance:Send10523()  end
    NoticeManager.Instance:ConfirmTips(data)
end

function ChildSpirtWindow:onStoryButtonClick()
    local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, self.selectIndex - 1)]
    if data_pet_skin ~= nil then
        local storyTips = {}
        for i=1, #data_pet_skin.story do
            table.insert(storyTips, data_pet_skin.story[i].line)
        end
        TipsManager.Instance:ShowText({gameObject = self.storyButton.gameObject, itemData = storyTips})
    end
end

function ChildSpirtWindow:onOkButtonClick()
    self.model:OpenChildSelectSpirtWindow()
end

function ChildSpirtWindow:onCancelButtonClick()
    local petData = self.model.cur_petdata

    if petData.master_pet_id ~= 0 and petData.spirit_child_flag == 1 then -- 自己就是附灵宠物
        ChildrenManager.Instance:Require18641(petData.id)
    elseif petData.attach_pet_ids == nil or #petData.attach_pet_ids == 0 then -- 没有附灵宠物

    else -- 有附灵宠

    end
end

function ChildSpirtWindow:ChangeTab(index)
    if index ~= 4 then

        WindowManager.Instance:CloseWindow(self)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {index})
    end

end

function ChildSpirtWindow:ChangeTab2(index)

    WindowManager.Instance:CloseWindow(self)
    -- print("发送消息=================================================" .. index)
    self.model.childVewIndex = index
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {4, index})

end



function ChildSpirtWindow:HeadBarChangeTab(index)
    self.model.headbarTabIndex = index

    if self.model.headbarTabIndex == 2 then
        WindowManager.Instance:CloseWindow(self)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {1})
        return
    end

    self:UpdateHeadBar()
end

function ChildSpirtWindow:UpdateSpirtButtonEffect()
    local data = self.model.cur_petdata
    if data ~= nil then
        if #data.attach_pet_ids == 0 then

            self.spiritButton.transform:Find("Arrow").gameObject:SetActive(true)
        elseif self.spirtButtonEffect ~= nil then
            -- self.spirtButtonEffect:SetActive(false)
        else
            self.spiritButton.transform:Find("Arrow").gameObject:SetActive(false)
        end
    elseif self.spiritButtonEffect ~= nil then
        -- self.spirtButtonEffect:SetActive(false)
        self.spiritButton.transform:Find("Arrow").gameObject:SetActive(false)
    end
end

function ChildSpirtWindow:UpdateSkillEffect()
    local data = self.model:getpet_byid(self.model.cur_petdata.attach_pet_ids[1])
    if data ~= nil then
        local data_child_spirt_score = self.model:GetChildSpirtScoreByTalent(data.base_id, data.talent)
        if data_child_spirt_score ~= nil and #data_child_spirt_score.skills > 0 then
            if self.skillEffect == nil then
                local fun = function(effectView)
                    local effectObject = effectView.gameObject

                    effectObject.transform:SetParent(self.skillPanel.transform:FindChild("SkillIcon"))
                    effectObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
                    effectObject.transform.localPosition = Vector3(0, 0, -400)
                    effectObject.transform.localRotation = Quaternion.identity

                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                end
                self.skillEffect = BaseEffectView.New({effectId = 20400, time = nil, callback = fun})
            else
                self.skillEffect:SetActive(true)
            end
        elseif self.skillEffect ~= nil then
            self.skillEffect:SetActive(false)
        end
    elseif self.skillEffect ~= nil then
        self.skillEffect:SetActive(false)
    end
end

function ChildSpirtWindow:onHandBookButtonClick()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {1, 3, 2})
end
----------------------------------------------------
---------------------关于拖动-----------------------
----------------------------------------------------
function ChildSpirtWindow:AddBeginDragListener(go)
    --添加开始拖动事件
    local cdb = go:GetComponent(CustomDragButton)
    cdb.onBeginDrag:AddListener(function(data) self:on_begin_drag(data, go) end)
    cdb.onDrag:RemoveAllListeners()
    cdb.onEndDrag:RemoveAllListeners()
end

function ChildSpirtWindow:AddDragListener(go)
    --添加拖动事件
    local cdb = go:GetComponent(CustomDragButton)
    cdb.onBeginDrag:RemoveAllListeners()
    cdb.onDrag:AddListener(function(data) self:on_drag(data, go) end)
    cdb.onEndDrag:AddListener(function(data) self:do_end_drag(data, go) end)
end

function ChildSpirtWindow:RemoveAllDragListener(go)
    --移除所有拖动事件
    local cdb = go:GetComponent(CustomDragButton)
    cdb.onBeginDrag:RemoveAllListeners()
    cdb.onDrag:RemoveAllListeners()
    cdb.onEndDrag:RemoveAllListeners()
end

function ChildSpirtWindow:on_begin_drag(data, gameObject)
    local id = tonumber(gameObject.transform.name)
    local petData = self.model:getpet_byid(id)
    if petData == nil then
        return
    end

    self:do_clone_action(gameObject) --执行克隆
end

function ChildSpirtWindow:on_drag(data, gameObject)
    local curScreenSpace=Vector3(Input.mousePosition.x*1,Input.mousePosition.y*1,self.screenSpace.z) --执行改变位置
    gameObject.transform.position= ctx.UICamera:ScreenToWorldPoint(curScreenSpace)
end

function ChildSpirtWindow:do_end_drag(data, gameObject)
    -- --销毁拖动对象
    local p = gameObject.transform.position
    if math.abs(p.x - self.headPoint.x) < 0.25 and math.abs(p.y - self.headPoint.y) < 0.25 then
        local id = tonumber(gameObject.transform.name)
        local petData = self.model:getpet_byid(id)


        PetManager.Instance:Send10561(self.model.cur_petdata.id, petData.id)
    end
    GameObject.Destroy(gameObject)
end

--执行克隆逻辑
function ChildSpirtWindow:do_clone_action(gameObject)
    gameObject.name = gameObject.transform.parent.parent.name

    self.screenSpace = gameObject.transform.position

    --克隆要拖动的对象
    local temp = GameObject.Instantiate(gameObject)
    temp.name = "Head"
    UIUtils.AddUIChild(gameObject.transform.parent.gameObject, temp)

    self.clone = temp:GetComponent(Image)
    local dragObject = gameObject
    local dragObject_tr = dragObject.transform
    local clone_rect = self.clone:GetComponent(RectTransform)
    local dragObject_rect = dragObject_tr:GetComponent(RectTransform)
    clone_rect.anchorMax=Vector2(0.5,0.5)
    clone_rect.anchorMin=Vector2(0.5,0.5)
    clone_rect.sizeDelta = Vector2(dragObject_rect.rect.width,dragObject_rect.rect.height)
    self.clone.transform:SetAsLastSibling()

    dragObject_tr:SetParent(self.transform) --设置到最顶层容器
    dragObject_rect.anchoredPosition = Vector2(dragObject_rect.anchoredPosition.x,dragObject_rect.anchoredPosition.y - 20)

    --克隆物体添加事件
    self:AddBeginDragListener(self.clone.gameObject)

    self:AddDragListener(gameObject)

end

function ChildSpirtWindow:SelectOne(item)

            -- 正常跳转
        PetManager.Instance.model.currChild = item.data
        PetManager.Instance.model.currIndex = item.index
        if self.currItem ~= nil then
            self.currItem:Select(false)
        end
        self.currItem = item
        self.currIndex = self.currItem.index
        self.currItem:Select(true)
        self:UpdateInfo()


end
