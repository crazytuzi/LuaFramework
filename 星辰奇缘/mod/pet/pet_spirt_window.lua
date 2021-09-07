-- ----------------------------------------------------------
-- UI - 宠物皮肤窗口
-- ----------------------------------------------------------
PetSpirtWindow = PetSpirtWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function PetSpirtWindow:__init(model)
    self.model = model
    self.name = "PetSpirtWindow"
    self.windowId = WindowConfig.WinID.petspirtwindow
    self.winLinkType = WinLinkType.Link
    -- self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.petspiritwindow, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.rolebgnew, type = AssetType.Dep}
        , {file = AssetConfig.wingsbookbg, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.playkillbgcycle, type = AssetType.Dep}
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

end

function PetSpirtWindow:__delete()
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

function PetSpirtWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petspiritwindow))
    self.gameObject.name = "PetSpirtWindow"
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
    self.tabGroup2 = TabGroup.New(self.tabGroupObj2, function(index) self:ChangeTab2(index) end, {notAutoSelect = true, perWidth = 90, perHeight = 35})


    self.spirtButton = self.mainTransform:FindChild("Info/TabButtonGroup/SpiritButton"):GetComponent(Button)

    -----------------------------------------------------------------------------

    self.headBar = self.mainTransform:FindChild("HeadBar")
    self.headBarRectTransform = self.headBar.transform:FindChild("HeadBar"):GetComponent(RectTransform)
	self.headBarContainer = self.headBar.transform:FindChild("HeadBar/mask/HeadContainer").gameObject
    self.headBarObject = self.headBarContainer.transform:FindChild("PetHead").gameObject

    self.toggle = self.mainTransform:FindChild("HeadBar/Toggle"):GetComponent(Toggle)
    self.toggle.onValueChanged:AddListener(function(on) self:OnToggleChange(on) end)

    self.headBarTabGroupObj = self.mainTransform:FindChild("HeadBar/TabButtonGroup").gameObject
    self.headBarTabGroup = TabGroup.New(self.headBarTabGroupObj, function(index) self:HeadBarChangeTab(index) end, { notAutoSelect = true })

    self.infoPanel = self.mainTransform:FindChild("Info")

    self.mainPetHead = self.infoPanel:FindChild("MainPetHead/Head")
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

    self.descPanelText.text = TI18N("1、附灵宠物等级≥自身携带等级+5\n2、附灵宠物<color='#00ff00'>携带等级≥75级</color>，且达到一定评分\n3、附灵宠物携带等级不低于<color='#ffff00'>主宠携带等级-20</color>\n4、普通宠物<color='#ffff00'>不能</color>作为神兽/珍兽的附灵宠\n5、附灵宠物<color='#ffff00'>评分和等级</color>越高，增加<color='#ffff00'>属性和附灵技能</color>等级越高")

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

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function PetSpirtWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet)
    -- self.model:ClosePetSpirtWindow()
end

function PetSpirtWindow:OnShow()
    PetManager.Instance.OnUpdatePetList:Add(self._OnUpdate)
    PetManager.Instance.OnPetUpdate:Add(self._OnUpdate)

    if RoleManager.Instance.RoleData.lev >= 75 then
        self.toggle.isOn = self.model.headbarToggleOn
        self.headBarTabGroup:ChangeTab(self.model.headbarTabIndex)

        self.headBarTabGroupObj:SetActive(true)
        self.headBarRectTransform.sizeDelta = Vector2(246, 415)
    else
        self.model.headbarTabIndex = 1

        self.headBarTabGroupObj:SetActive(false)
        self.headBarRectTransform.sizeDelta = Vector2(246, 450)
    end

    self:Update()
end

function PetSpirtWindow:OnHide()
    PetManager.Instance.OnUpdatePetList:Remove(self._OnUpdate)
    PetManager.Instance.OnPetUpdate:Remove(self._OnUpdate)
end

function PetSpirtWindow:Update()
    self.model:CheckTabOpen(self.tabGroup2)
    self.tabGroup2:Layout()
    self.tabGroup2:Select(5)
    
    self:UpdateHeadBar()
end

function PetSpirtWindow:OnUpdate()
    self:Update()
end

function PetSpirtWindow:UpdateHeadBar()
	-- local petlist = {}
	-- for i=1, #self.model.petlist do
	-- 	local petData = self.model.petlist[i]
	-- 	if self.model:GetCanChangeSkin(petData) then
	-- 		table.insert(petlist, petData)
	-- 	end
	-- end
    local petlist = self.model.petlist
    local headnum = self.model.pet_nums
    local headlist = self.headlist
    local headobject = self.headBarObject
    local container = self.headBarContainer
    local data

    -- if not self.toggle.isOn then
    if self.model.headbarTabIndex == 1 then
        petlist = self.model:GetMasterPetList()
    else
        petlist = self.model:GetAttachPetList()

        if #petlist == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("当前没有附灵宠物"))
            self.headBarTabGroup:ChangeTab(1)
            return
        end
    end

    if #self.model:GetAttachPetList() > 0  then
        self.headBarTabGroupObj:SetActive(true)
        self.headBarRectTransform.sizeDelta = Vector2(246, 415)
    else
        self.headBarTabGroupObj:SetActive(false)
        self.headBarRectTransform.sizeDelta = Vector2(246, 450)
    end

    local selectBtn = nil
    for i = 1, #petlist do
        data = petlist[i]
        local headitem = headlist[i]

        if headitem == nil then
            local item = GameObject.Instantiate(headobject)
            item:SetActive(true)
            item.transform:SetParent(container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            headlist[i] = item
            headitem = item

            item.transform:FindChild("Head_78/Head").gameObject:AddComponent(CustomDragButton)
        end

        headitem.name = tostring(data.id)

        headitem.transform:FindChild("NameText"):GetComponent(Text).text = data.name
        headitem.transform:FindChild("LVText"):GetComponent(Text).text = string.format(TI18N("等级：%s"), data.lev)
        headitem.transform:FindChild("Using").gameObject:SetActive(data.status == 1)
        headitem.transform:FindChild("Attach").gameObject:SetActive(data.master_pet_id ~= 0)
        -- headitem.transform:FindChild("Possess").gameObject:SetActive(data.possess_pos > 0)
        local headId = tostring(data.base.head_id)

        local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)
        local loaderId = headImage.gameObject:GetInstanceID()
        if self.headLoaderList[loaderId] == nil then
            self.headLoaderList[loaderId] = SingleIconLoader.New(headImage.gameObject)
        end
        self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
        -- headImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
        -- headImage:SetNativeSize()
        headImage.rectTransform.sizeDelta = Vector2(54, 54)
        -- headImage.gameObject:SetActive(true)

        local headbg = self.model:get_petheadbg(data)
        headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
            = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, headbg)

        local button = headitem:GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener(function() self:onHeadItemClick(headitem) end)

        if self.model:GetCanChangeSkin(data) and self.model:EnoughItemToChangeSkin(data) then
            headitem.transform:FindChild("RedPointImage").gameObject:SetActive(true)
        else
            headitem.transform:FindChild("RedPointImage").gameObject:SetActive(false)
        end

        if #data.attach_pet_ids > 0 then
            headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(true)
            local attach_pet_id = data.attach_pet_ids[1]
            local attach_pet_data = self.model:getpet_byid(attach_pet_id)
            local headId = tostring(attach_pet_data.base.head_id)
            local loaderId = headitem.transform:FindChild("AttachHeadIcon/Image").gameObject:GetInstanceID()
                if self.headLoaderList[loaderId] == nil then
                    self.headLoaderList[loaderId] = SingleIconLoader.New(headitem.transform:FindChild("AttachHeadIcon/Image").gameObject)
                end
                self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,headId)
            -- headitem.transform:FindChild("AttachHeadIcon/Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
        else
            headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)
        end

        if self.model.cur_petdata ~= nil and self.model.cur_petdata.id == data.id then selectBtn = headitem end


        headitem:SetActive(true)

        -- self:RemoveAllDragListener(headImage.gameObject)
        -- self:AddBeginDragListener(headImage.gameObject)
    end

    if not self.toggle.isOn then
        for i = #petlist + 1, self.model.pet_nums do
            local headitem = headlist[i]
            if headitem == nil then
                local item = GameObject.Instantiate(headobject)
                item:SetActive(true)
                item.transform:SetParent(container.transform)
                item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
                headlist[i] = item
                headitem = item

                item.transform:FindChild("Head_78/Head").gameObject:AddComponent(CustomDragButton)
            end

            headitem.name = "lock"

            headitem.transform:FindChild("NameText"):GetComponent(Text).text = ""
            headitem.transform:FindChild("LVText"):GetComponent(Text).text = ""
            headitem.transform:FindChild("Using").gameObject:SetActive(false)
            headitem.transform:FindChild("Attach").gameObject:SetActive(false)
            headitem.transform:FindChild("Possess").gameObject:SetActive(false)

            local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)
            headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage")
            -- headImage:SetNativeSize()
            headImage.rectTransform.sizeDelta = Vector2(32, 36)
            -- headImage.gameObject:SetActive(true)

            headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
                = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")

            local button = headitem:GetComponent(Button)
            button.onClick:RemoveAllListeners()
            button.onClick:AddListener(function() self:onHeadAddClick(headitem) end)

            self:RemoveAllDragListener(headImage.gameObject)
            headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)

            if self.model.headbarTabIndex == 1 then
                headitem:SetActive(true)
            else
                headitem:SetActive(false)
            end
        end
    end

    if self.petnum_max > self.model.pet_nums then
        local headitem = headlist[self.model.pet_nums + 1]
        if headitem == nil then
            local item = GameObject.Instantiate(headobject)
            item:SetActive(true)
            item.transform:SetParent(container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            headlist[self.model.pet_nums + 1] = item
            headitem = item

            item.transform:FindChild("Head_78/Head").gameObject:AddComponent(CustomDragButton)
        end
        headitem.name = "lock"

        headitem.transform:FindChild("NameText"):GetComponent(Text).text = ""
        headitem.transform:FindChild("LVText"):GetComponent(Text).text = ""
        headitem.transform:FindChild("Using").gameObject:SetActive(false)
        headitem.transform:FindChild("Attach").gameObject:SetActive(false)
        headitem.transform:FindChild("Possess").gameObject:SetActive(false)

        local headImage = headitem.transform:FindChild("Head_78/Head"):GetComponent(Image)
        headImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Lock")
        -- headImage:SetNativeSize()
        headImage.rectTransform.sizeDelta = Vector2(36, 40)
        -- headImage.gameObject:SetActive(true)

        headitem.transform:FindChild("Head_78/HeadBg"):GetComponent(Image).sprite
             = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ItemDefault")
        local button = headitem:GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener(function() self:onHeadLockClick(headitem) end)

        self:RemoveAllDragListener(headImage.gameObject)
        headitem.transform:FindChild("AttachHeadIcon").gameObject:SetActive(false)

        if self.model.headbarTabIndex == 1 then
            headitem:SetActive(true)
        else
            headitem:SetActive(false)
        end
    end

    if #petlist > 0 then
        if selectBtn == nil then
            self:onHeadItemClick(headlist[1])
        else
            self:onHeadItemClick(selectBtn)
        end
    end
end

function PetSpirtWindow:UpdateInfo()
    local petData = self.model.cur_petdata

    -- if self.model.cur_petdata.lev < 75 then
    --     WindowManager.Instance:CloseWindow(self)
    --     WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {1})
    --     return
    -- end

    if petData.master_pet_id ~= 0 then -- 自己就是附灵宠物
        local masterPetData = self.model:getpet_byid(petData.master_pet_id)

           if self.headLoader2 == nil then
                self.headLoader2 = SingleIconLoader.New(self.mainPetHead:GetComponent(Image).gameObject)
            end
            self.headLoader2:SetSprite(SingleIconType.Pet, masterPetData.base.head_id)
        -- self.mainPetHead:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(masterPetData.base.head_id), masterPetData.base.head_id)
        self.mainPetHead:GetComponent(Image).rectTransform.sizeDelta = Vector2(54, 54)


        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.head:GetComponent(Image).gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet,petData.base.head_id)

        -- self.head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(petData.base.head_id), petData.base.head_id)
        self.head:GetComponent(Image).rectTransform.sizeDelta = Vector2(54, 54)

        self.cancelButton.gameObject:SetActive(true)

        self.mainPetLevel:SetActive(true)
        self.spritPetLevel:SetActive(true)
        self.mainPetLevelText.text = tostring(masterPetData.lev)
        self.spritPetLevelText.text = tostring(petData.lev)

        self.descPanel:SetActive(false)

        self.descText.gameObject:SetActive(false)
        self.pointText.text = ""
        self.skillPanel:SetActive(true)
        self.attrMaskObj:SetActive(true)
        -- self.descTextObj:SetActive(false)

        self:UpdateSkill(petData)
        self:UpdateAttr(petData)
	elseif petData.attach_pet_ids == nil or #petData.attach_pet_ids == 0 then -- 没有附灵宠物

        if self.headLoader2 == nil then
            self.headLoader2 = SingleIconLoader.New(self.mainPetHead:GetComponent(Image).gameObject)
        end
        self.headLoader2:SetSprite(SingleIconType.Pet, petData.base.head_id)
        -- self.mainPetHead:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(petData.base.head_id), petData.base.head_id)
        self.mainPetHead:GetComponent(Image).rectTransform.sizeDelta = Vector2(54, 54)



        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.head:GetComponent(Image).gameObject)
        end
        self.headLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures,"BidAddImage"))
        -- self.head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage")
        self.head:GetComponent(Image).rectTransform.sizeDelta = Vector2(32, 36)

        self.cancelButton.gameObject:SetActive(false)

        self.mainPetLevel:SetActive(true)
        self.spritPetLevel:SetActive(false)
        self.mainPetLevelText.text = tostring(petData.lev)

        self.descPanel:SetActive(true)

        self.descText.gameObject:SetActive(true)
        self.pointText.text = ""
        self.skillPanel:SetActive(false)
        self.attrMaskObj:SetActive(false)
        -- self.descTextObj:SetActive(true)
        self.noAttrTextObj:SetActive(true)
    else -- 有附灵宠
        local spritPetData = self.model:getpet_byid(petData.attach_pet_ids[1])

        if self.headLoader2 == nil then
            self.headLoader2 = SingleIconLoader.New(self.mainPetHead:GetComponent(Image).gameObject)
        end
        self.headLoader2:SetSprite(SingleIconType.Pet,petData.base.head_id)
        -- self.mainPetHead:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(petData.base.head_id), petData.base.head_id)
        self.mainPetHead:GetComponent(Image).rectTransform.sizeDelta = Vector2(54, 54)


        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.head:GetComponent(Image).gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet,spritPetData.base.head_id)

        -- self.head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(spritPetData.base.head_id), spritPetData.base.head_id)
        self.head:GetComponent(Image).rectTransform.sizeDelta = Vector2(54, 54)

        self.cancelButton.gameObject:SetActive(false)

        self.mainPetLevel:SetActive(true)
        self.spritPetLevel:SetActive(true)
        self.mainPetLevelText.text = tostring(petData.lev)
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

function PetSpirtWindow:UpdateSkill(petData)
    local data_pet_spirt_score = self.model:GetPetSpirtScoreByTalent(petData.base_id, petData.talent)
    local activeSkillMark = true
    if data_pet_spirt_score == nil or #data_pet_spirt_score.skills == 0 then
        data_pet_spirt_score = self.model:GetPetSpirtScoreBySkillLevel(petData.base_id, 0)
        activeSkillMark = false
    end
    -- BaseUtils.dump(data_pet_spirt_score, "data_pet_spirt_score")
    local skillData = DataSkill.data_petSkill[string.format("%s_%s", data_pet_spirt_score.skills[1][1], data_pet_spirt_score.skills[1][2])]

    self.skillPanelText1.text = string.format("<color='#ffff00'>%s</color>", skillData.name)
    self.skillPanelText2.text = skillData.desc
    if activeSkillMark then
        local next_data_pet_spirt_score = self.model:GetPetSpirtScoreBySkillLevel(petData.base_id, data_pet_spirt_score.skill_lev)

        if next_data_pet_spirt_score ~= nil then
            local nextSkillData = DataSkill.data_petSkill[string.format("%s_%s", next_data_pet_spirt_score.skills[1][1], next_data_pet_spirt_score.skills[1][2])]
            self.skillPanelText3.text = string.format(TI18N("达到<color='#00ff00'>%s评分</color>激活下一等级"), next_data_pet_spirt_score.talent_min)
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
        self.skillPanelText3.text = string.format(TI18N("达到<color='#00ff00'>%s评分</color>激活<color='#ffff00'>%s</color>"), data_pet_spirt_score.talent_min, skillData.name)
        -- self.skillPanelText4.text = TI18N("<color='#ff0000'>技能未激活</color>")
        self.skillPanelText4.text = ""

        self.skillPanelSkillIcon:SetAll(Skilltype.petskill, skillData)
        self.skillPanelSkillIcon:SetGrey(true)

        self.nextSkillButton.gameObject:SetActive(true)
        self.nextSkillData = skillData
    end

    self:UpdateSkillEffect()
end

function PetSpirtWindow:onNextSkillButtonClick()
    local info = {gameObject = self.nextSkillButton.gameObject, skillData = self.nextSkillData, type = Skilltype.petskill}
    TipsManager.Instance:ShowSkill(info, true)
end

function PetSpirtWindow:UpdateAttr(petData)
    local data_pet_spirt_score = self.model:GetPetSpirtScoreByTalent(petData.base_id, petData.talent)

    if data_pet_spirt_score == nil or data_pet_spirt_score.attr_ratio == 0 then
        self.attrContainer.gameObject:SetActive(false)
        self.noAttrTextObj:SetActive(true)
    else
        self.attrContainer.gameObject:SetActive(true)
        self.noAttrTextObj:SetActive(false)

        local data_pet_spirt_attr = DataPet.data_pet_spirt_attr[petData.lev]
        local attr_ratio = data_pet_spirt_score.attr_ratio

        local temp = {}
        table.insert(temp, { key = 1, value = BaseUtils.Round(data_pet_spirt_attr.hp_max * attr_ratio / 1000) } )
        table.insert(temp, { key = 2, value = BaseUtils.Round(data_pet_spirt_attr.mp_max * attr_ratio / 1000) } )
        table.insert(temp, { key = 4, value = BaseUtils.Round(data_pet_spirt_attr.phy_dmg * attr_ratio / 1000) } )
        table.insert(temp, { key = 5, value = BaseUtils.Round(data_pet_spirt_attr.magic_dmg * attr_ratio / 1000) } )
        table.insert(temp, { key = 6, value = BaseUtils.Round(data_pet_spirt_attr.phy_def * attr_ratio / 1000) } )
        table.insert(temp, { key = 7, value = BaseUtils.Round(data_pet_spirt_attr.magic_def * attr_ratio / 1000) } )
        table.insert(temp, { key = 3, value = BaseUtils.Round(data_pet_spirt_attr.atk_speed * attr_ratio / 1000) } )

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

function PetSpirtWindow:onHeadItemClick(item)
	self.model.cur_petdata = self.model:getpet_byid(tonumber(item.name))
    if self.model.cur_petdata.genre ==6 then
        NoticeManager.Instance:FloatTipsByString("精灵蛋没有附灵界面")
    else
        self.selectIndex = 0

        local head
        for i = 1, #self.headlist do
            head = self.headlist[i]
            head.transform:FindChild("Select").gameObject:SetActive(false)
        end
        item.transform:FindChild("Select").gameObject:SetActive(true)

        self:UpdateInfo()
    end
end

function PetSpirtWindow:onHeadAddClick()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("你是否要前往宠物图鉴查看可携带宠物？")
    data.sureLabel = TI18N("确认")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() self.model:OpenPetWindow({3})  end
    NoticeManager.Instance:ConfirmTips(data)
end

function PetSpirtWindow:onHeadLockClick(item)
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

function PetSpirtWindow:onStoryButtonClick()
	local data_pet_skin = DataPet.data_pet_skin[string.format("%s_%s", self.model.cur_petdata.base.id, self.selectIndex - 1)]
	if data_pet_skin ~= nil then
		local storyTips = {}
		for i=1, #data_pet_skin.story do
			table.insert(storyTips, data_pet_skin.story[i].line)
		end
		TipsManager.Instance:ShowText({gameObject = self.storyButton.gameObject, itemData = storyTips})
	end
end

function PetSpirtWindow:onOkButtonClick()
    if self.model.cur_petdata.lev < 75 then
        NoticeManager.Instance:FloatTipsByString(TI18N("主宠不足75级，无法附灵"))
        return
    end
    self.model:OpenPetSelecttSpirtWindow()
end

function PetSpirtWindow:onCancelButtonClick()
    local petData = self.model.cur_petdata

    if petData.master_pet_id ~= 0 then -- 自己就是附灵宠物
        PetManager.Instance:Send10562(petData.id)
    elseif petData.attach_pet_ids == nil or #petData.attach_pet_ids == 0 then -- 没有附灵宠物

    else -- 有附灵宠

    end
end

function PetSpirtWindow:ChangeTab(index)
    if index ~= 1 then
        WindowManager.Instance:CloseWindow(self)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {index})
    end
end

function PetSpirtWindow:ChangeTab2(index)
    if index == 5 then return end       --不允许点自己
    WindowManager.Instance:CloseWindow(self)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {1, index})
end

function PetSpirtWindow:OnToggleChange(on)
    self.model.headbarToggleOn = on
    self:UpdateHeadBar()
end

function PetSpirtWindow:HeadBarChangeTab(index)
    self.model.headbarTabIndex = index

    -- if self.model.headbarTabIndex == 2 then
    --     local petlist = self.model:GetAttachPetList()

    --     if #petlist == 0 then
    --         -- WindowManager.Instance:CloseWindow(self)
    --         -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {1, 1})
    --         self.headBarTabGroup:ChangeTab(1)
    --         return
    --     end
    -- end

    if self.model.headbarTabIndex == 2 then
        WindowManager.Instance:CloseWindow(self)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {1})
        return
    end

    self:UpdateHeadBar()
end

function PetSpirtWindow:UpdateSpirtButtonEffect()
    local data = self.model.cur_petdata
    if data ~= nil then
        if #data.attach_pet_ids == 0 then
            -- if self.spirtButtonEffect == nil then
            --     local fun = function(effectView)
            --         local effectObject = effectView.gameObject

            --         effectObject.transform:SetParent(self.spirtButton.transform)
            --         effectObject.transform.localScale = Vector3(0.8, 0.8, 0.8)
            --         effectObject.transform.localPosition = Vector3(63, 15, -400)
            --         effectObject.transform.localRotation = Quaternion.identity

            --         Utils.ChangeLayersRecursively(effectObject.transform, "UI")
            --     end
            --     self.spirtButtonEffect = BaseEffectView.New({effectId = 20122, time = nil, callback = fun})
            -- else
            --     self.spirtButtonEffect:SetActive(true)
            -- end
            self.spirtButton.transform:Find("Arrow").gameObject:SetActive(true)
        elseif self.spirtButtonEffect ~= nil then
            -- self.spirtButtonEffect:SetActive(false)
        else
            self.spirtButton.transform:Find("Arrow").gameObject:SetActive(false)
        end
    elseif self.spirtButtonEffect ~= nil then
        -- self.spirtButtonEffect:SetActive(false)
        self.spirtButton.transform:Find("Arrow").gameObject:SetActive(false)
    end
end

function PetSpirtWindow:UpdateSkillEffect()
    local data = self.model:getpet_byid(self.model.cur_petdata.attach_pet_ids[1])
    if data ~= nil then
        local data_pet_spirt_score = self.model:GetPetSpirtScoreByTalent(data.base_id, data.talent)
        if data_pet_spirt_score ~= nil and #data_pet_spirt_score.skills > 0 then
            if self.skillEffect == nil then
                local fun = function(effectView)
                    local effectObject = effectView.gameObject

                    if BaseUtils.isnull(self.gameObject) then
                        GameObject.Destroy(effectObject)
                        return
                    end

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

function PetSpirtWindow:onHandBookButtonClick()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {1, 3, 2})
end
----------------------------------------------------
---------------------关于拖动-----------------------
----------------------------------------------------
function PetSpirtWindow:AddBeginDragListener(go)
    --添加开始拖动事件
    local cdb = go:GetComponent(CustomDragButton)
    cdb.onBeginDrag:AddListener(function(data) self:on_begin_drag(data, go) end)
    cdb.onDrag:RemoveAllListeners()
    cdb.onEndDrag:RemoveAllListeners()
end

function PetSpirtWindow:AddDragListener(go)
    --添加拖动事件
    local cdb = go:GetComponent(CustomDragButton)
    cdb.onBeginDrag:RemoveAllListeners()
    cdb.onDrag:AddListener(function(data) self:on_drag(data, go) end)
    cdb.onEndDrag:AddListener(function(data) self:do_end_drag(data, go) end)
end

function PetSpirtWindow:RemoveAllDragListener(go)
    --移除所有拖动事件
    local cdb = go:GetComponent(CustomDragButton)
    cdb.onBeginDrag:RemoveAllListeners()
    cdb.onDrag:RemoveAllListeners()
    cdb.onEndDrag:RemoveAllListeners()
end

function PetSpirtWindow:on_begin_drag(data, gameObject)
    local id = tonumber(gameObject.transform.name)
    local petData = self.model:getpet_byid(id)
    if petData == nil then
        return
    end

    self:do_clone_action(gameObject) --执行克隆
end

function PetSpirtWindow:on_drag(data, gameObject)
    local curScreenSpace=Vector3(Input.mousePosition.x*1,Input.mousePosition.y*1,self.screenSpace.z) --执行改变位置
    gameObject.transform.position= ctx.UICamera:ScreenToWorldPoint(curScreenSpace)
end

function PetSpirtWindow:do_end_drag(data, gameObject)
    -- --销毁拖动对象
    local p = gameObject.transform.position
    if math.abs(p.x - self.headPoint.x) < 0.25 and math.abs(p.y - self.headPoint.y) < 0.25 then
        local id = tonumber(gameObject.transform.name)
        local petData = self.model:getpet_byid(id)

        -- local data = NoticeConfirmData.New()
        -- data.type = ConfirmData.Style.Normal
        -- data.content = string.format(TI18N("确定将[%s]附灵到[%s]吗？"), petData.name, self.model.cur_petdata.name)
        -- data.sureLabel = TI18N("确认")
        -- data.cancelLabel = TI18N("取消")
        -- data.sureCallback = function()
        --         PetManager.Instance:Send10561(self.model.cur_petdata.id, petData.id)
        --     end
        -- NoticeManager.Instance:ConfirmTips(data)

        PetManager.Instance:Send10561(self.model.cur_petdata.id, petData.id)
    end
    GameObject.Destroy(gameObject)
end

--执行克隆逻辑
function PetSpirtWindow:do_clone_action(gameObject)
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

----------------------------------------------------
-------------------关于属性滚动---------------------
----------------------------------------------------
-- function PetSpirtWindow:TimeCount()
--     self:TimeStop()
--     self.temp_time2 = Time.time
--     self.runTimeId = LuaTimer.Add(0, 10, function() self:Loop() end)
-- end

-- function PetSpirtWindow:TimeStop()
--     if self.runTimeId ~= 0 then
--         LuaTimer.Delete(self.runTimeId)
--         self.runTimeId = 0
--     end
-- end

-- function PetSpirtWindow:Loop()
--     local timeGap = Time.time - self.temp_time2
--     self.temp_time2 = Time.time
--     local canStop = true
--     for k, v in pairs(self.itemList) do
--         local temp = self:RunAttrItem(v, timeGap)
--         if temp == false then
--             canStop = temp
--         end
--     end
--     if canStop then
--         self:TimeStop()
--         local list = self:GetCurAttrList()
--         for k, v in pairs(self.itemList) do
--             v.AttrTxt2.text = tostring(list[v.data.name].val)
--         end
--     end
-- end