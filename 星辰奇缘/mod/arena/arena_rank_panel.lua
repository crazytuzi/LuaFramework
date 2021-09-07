ArenaRankPanel = ArenaRankPanel or BaseClass(BasePanel)

function ArenaRankPanel:__init(model, parent)
    self.parent = parent
    self.model = model

    self.mgr = ArenaManager.Instance

    self.resList = {
        {file = AssetConfig.arena_rank_panel, type = AssetType.Main}
        , {file = AssetConfig.rank_textures, type = AssetType.Dep}
        , {file = AssetConfig.arena_textures, type = AssetType.Dep}
        , {file = AssetConfig.half_length, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.guard_head, type = AssetType.Dep}
    }

    self.friendObjList = {}
    self.shouhuObjList = {}
    self.formationNameList = {}
    self.rateObjList = {}
    self.jobObjList = {}
    for _,v in pairs(FormationManager.Instance.formationList) do
        if v ~= nil then
            table.insert(self.formationNameList, DataFormation.data_list[v.id.."_"..v.lev].name.."Lv."..v.lev)
        end
    end

    self.updateRatesListner = function() self:UpdateRates() end
    self.updateJobListner = function() self:UpdateJobs() end
    self.updateCombatForceListner = function() self:UpdateCombatForce() end
    self.updateFriendListner = function() self:UpdateFriends() end
    self.updateMyDataListener = function() self:UpdateMyData() end

    self.guardSelectListener = function(index) self:GuardSelectListener(index) end
    self.formationSelectListener = function(index) self:FormationSelectListener(index) end

    self.OnOpenEvent:AddListener(function () self:OnOpen() end)
    self.OnHideEvent:AddListener(function () self:OnHide() end)
end

function ArenaRankPanel:__delete()
    self.OnHideEvent:Fire()
    if self.cupImage ~= nil then
        BaseUtils.ReleaseImage(self.cupImage)
    end
    if self.petImage ~= nil then
        BaseUtils.ReleaseImage(self.petImage)
    end
    if self.myLookImage ~= nil then
        BaseUtils.ReleaseImage(self.myLookImage)
    end
    if self.friendCupImage ~= nil then
        BaseUtils.ReleaseImage(self.friendCupImage)
    end
    if self.petAttrBgImage ~= nil then
        BaseUtils.ReleaseImage(self.petAttrBgImage)
    end
    --self.cupImage.sprite = nil
    --self.petImage.sprite = nil
    --self.myLookImage.sprite = nil
    --self.friendCupImage.sprite = nil
    --self.petAttrBgImage.sprite = nil
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
    if self.friendObjList ~= nil then
        for k,v in pairs(self.friendObjList) do
            if v ~= nil then
                v:DeleteMe()
                self.friendObjList[k] = nil
            end
        end
        self.friendObjList = nil
    end
    if self.shouhuLayout ~= nil then
        self.shouhuLayout:DeleteMe()
        self.shouhuLayout = nil
    end
    if self.jobLayout ~= nil then
        self.jobLayout:DeleteMe()
        self.jobLayout = nil
    end
    if self.friendLayout ~= nil then
        self.friendLayout:DeleteMe()
        self.friendLayout = nil
    end
    if self.rateLayout ~= nil then
        self.rateLayout:DeleteMe()
        self.rateLayout = nil
    end
    if self.guardSelect ~= nil then
        self.guardSelect:DeleteMe()
        self.guardSelect = nil
    end
    if self.formationSelect ~= nil then
        self.formationSelect:DeleteMe()
        self.formationSelect = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ArenaRankPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.arena_rank_panel))
    self.gameObject.name = "ArenaRankPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.myscoreText = self.transform:Find("Grade/MyScore/Bg/Score"):GetComponent(Text)
    self.myLookImage = self.transform:Find("Grade/MyScore/Image"):GetComponent(Image)
    self.cupImage = self.transform:Find("Grade/MyScore/Bg/Cup"):GetComponent(Image)
    self.helpBtn = self.transform:Find("Grade/MyScore/Help"):GetComponent(Button)
    self.helpBtn.gameObject:SetActive(false)
    self.cupImage.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon1001")
    self.cupImage.gameObject:SetActive(true)

    self.allRateContainer = self.transform:Find("Grade/AllRate/MaskLayer/Container")
    self.allRateCloner = self.transform:Find("Grade/AllRate/MaskLayer/Cloner").gameObject
    self.allRateCloner:SetActive(false)

    self.againstJobContainer = self.transform:Find("Grade/AgainstJob/MaskLayer/Container")
    self.againstJobCloner = self.transform:Find("Grade/AgainstJob/MaskLayer/Cloner").gameObject
    self.againstJobCloner:SetActive(false)

    self.friendContainer = self.transform:Find("Friends/MaskLayer/Container")
    self.friendCloner = self.transform:Find("Friends/MaskLayer/Cloner").gameObject
    self.friendCupImage = self.friendCloner.transform:Find("Cup"):GetComponent(Image)
    self.friendCupImage.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon1001")
    self.friendCloner:SetActive(false)

    self.formationBtn = self.transform:Find("CombatForce/Formation/Format"):GetComponent(Button)
    self.formationText = self.transform:Find("CombatForce/Formation/Format/Text"):GetComponent(Text)
    self.transform:Find("CombatForce/Formation/Title"):GetComponent(Text).text = TI18N("防守阵型")

    self.petBtn = self.transform:Find("CombatForce/Pet/Icon"):GetComponent(Button)
    self.petImage = self.transform:Find("CombatForce/Pet/Icon/Image"):GetComponent(Image)
    self.petBtn.onClick:AddListener(function() self:OnClickPet() end)
    self.petAttrObj = self.transform:Find("CombatForce/Pet/Icon/Attr").gameObject
    self.petAttrBgImage = self.petAttrObj.transform:Find("Image"):GetComponent(Image)
    self.petAttrArrow1 = self.petAttrObj.transform:Find("Arrow1").gameObject
    self.petAttrArrow2 = self.petAttrObj.transform:Find("Arrow2").gameObject
    self.petAttrText = self.petAttrObj.transform:Find("Text"):GetComponent(Text)
    self.petAddObj = self.transform:Find("CombatForce/Pet/Icon/Add").gameObject
    self.petToggle1 = self.transform:Find("CombatForce/Pet/Toggle1"):GetComponent(Toggle)
    self.petToggle2 = self.transform:Find("CombatForce/Pet/Toggle2"):GetComponent(Toggle)
    self.petToggle1.onValueChanged:AddListener(function(on) self:OnPetToggle1Change(on) end)
    self.petToggle2.onValueChanged:AddListener(function(on) self:OnPetToggle2Change(on) end)

    self.shouhuContainer = self.transform:Find("CombatForce/Guild/Container")
    self.shouhuCloner = self.transform:Find("CombatForce/Guild/Icon").gameObject
    self.shouhuCloner:SetActive(false)

    self.formationSelectArea = self.transform:Find("FormatChangeGuard").gameObject
    self.guardSelectArea = self.transform:Find("TeamChangeGuard").gameObject

    self.jumpToFightBtn = self.transform:Find("JumpToFight"):GetComponent(Button)
    self.jumpToFightBtn.gameObject:SetActive(false)

    --------------------------------- 初始化界面的分割线 ------------------------------------

    self.guardSelect = ArenaGuardSelect.New(self.model, self.guardSelectArea, self.assetWrapper, self.guardSelectListener)
    self.formationSelect = ArenaFormationSelect.New(self.model, self.formationSelectArea, self.assetWrapper, self.formationSelectListener)

    if self.model.fellows == nil then
        self.mgr:send12200(function ()
            self:UpdateMyData()
        end)
        self.mgr:send12205()
    else
        self:UpdateMyData()
    end

    self.OnOpenEvent:Fire()
end

function ArenaRankPanel:OnOpen()
    self.mgr.hasNewGuard = false
    self.model.currentSHList = BaseUtils.copytab(ShouhuManager.Instance.model.my_sh_list)
    table.sort(self.model.currentSHList, function(a,b) return a.score > b.score end)

    self.guardSelect:Hiden()
    self.formationSelect:Hiden()

    self.jumpToFightBtn.onClick:RemoveAllListeners()
    self.jumpToFightBtn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arena_window, {1}) end)

    self.formationBtn.onClick:RemoveAllListeners()
    self.formationBtn.onClick:AddListener(function()
        self.guardSelect:Hiden()
        if self.formationSelect.isOpen == true then
            self.formationSelect:Hiden()
        else
            self.formationSelect:Show(FormationManager.Instance.formationList, self.model.formation)
        end
    end)

    self:UpdateCombatForce()
    self:UpdateRates()
    self:UpdateJobs()
    self:UpdateMyData()

    self.mgr:send12206()
    self.mgr:send12208()

    self:RemoveListeners()
    self.mgr.onUpdateJobs:AddListener(self.updateJobListner)
    self.mgr.onUpdatePersonal:AddListener(self.updateRatesListner)
    self.mgr.onUpdateFriends:AddListener(self.updateFriendListner)
    self.mgr.onUpdateCombatForce:AddListener(self.updateCombatForceListner)
    self.mgr.onUpdatePet:AddListener(self.updateCombatForceListner)
    self.mgr.onUpdateMyScore:AddListener(self.updateMyDataListener)

    self.mgr.redPoint[2] = false
    self.mgr.onUpdateRed:Fire()
end

function ArenaRankPanel:SelectCallback(index)
end

function ArenaRankPanel:RemoveListeners()
    self.mgr.onUpdateJobs:RemoveListener(self.updateJobListner)
    self.mgr.onUpdatePersonal:RemoveListener(self.updateRatesListner)
    self.mgr.onUpdateFriends:RemoveListener(self.updateFriendListner)
    self.mgr.onUpdateCombatForce:RemoveListener(self.updateCombatForceListner)
    self.mgr.onUpdatePet:RemoveListener(self.updateCombatForceListner)
    self.mgr.onUpdateMyScore:RemoveListener(self.updateMyDataListener)
end

function ArenaRankPanel:OnHide()
    self:RemoveListeners()
    if self.guardSelect ~= nil then
        self.guardSelect:Hiden()
    end
    if self.formationSelect ~= nil then
        self.formationSelect:Hiden()
    end
end

function ArenaRankPanel:UpdateMyData()
    local model = self.model
    local roledata = RoleManager.Instance.RoleData
    self.myLookImage.gameObject:SetActive(true)
    self.myLookImage.sprite = self.assetWrapper:GetSprite(AssetConfig.half_length, "half_"..roledata.classes..roledata.sex)
    self.myscoreText.text = tostring(model.cup)
end

function ArenaRankPanel:UpdateRates()
    local model = self.model
    if self.rateLayout == nil then
        self.rateLayout = LuaBoxLayout.New(self.allRateContainer, {axis = BoxLayoutAxis.Y, cspacing = 0})
    end
    local obj = nil
    for i,v in ipairs(model.achievements) do
        if self.rateObjList[i] == nil then
            obj = GameObject.Instantiate(self.allRateCloner)
            obj.name = tostring(i)
            self.rateLayout:AddCell(obj)
            self.rateObjList[i] = obj
        end
        obj = self.rateObjList[i]
        local t = obj.transform
        t:Find("Desc"):GetComponent(Text).text = tostring(v.name)..":"
        if v.rate ~= nil then
            t:Find("Text"):GetComponent(Text).text = tostring(v.rate)
        else
            t:Find("Text"):GetComponent(Text).text = ""
        end
    end
end

function ArenaRankPanel:UpdateJobs()
    local model = self.model
    if model.jobList == nil then
        model.jobList = {}
    end
    if self.jobLayout == nil then
        self.jobLayout = LuaBoxLayout.New(self.againstJobContainer, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    end
    local obj = nil
    self.jobLayout:ReSet()
    for i,v in ipairs(model.jobList) do
        if self.jobObjList[i] == nil then
            obj = GameObject.Instantiate(self.againstJobCloner)
            obj.name = tostring(i)
            self.jobLayout:AddCell(obj)
            self.jobObjList[i] = obj
        end
        obj = self.jobObjList[i]
        local t = obj.transform
        t:Find("Job"):GetComponent(Text).text = TI18N("对") ..v.name..":"
        t:Find("Job/Image"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(i))
        if v.rate ~= nil then
            t:Find("Text"):GetComponent(Text).text = tostring(v.rate)
        else
            t:Find("Text"):GetComponent(Text).text = ""
        end
    end
end

function ArenaRankPanel:UpdateFriends()
    local model = self.model

    local friendList = model.rank_list
    if friendList == nil then
        friendList = {}
    end
    local obj = nil
    if self.friendLayout == nil then
        self.friendLayout = LuaBoxLayout.New(self.friendContainer, {axis = BoxLayoutAxis.Y, cspacing = 0})
    end

    for i,v in ipairs(friendList) do
        if self.friendObjList[i] == nil then
            obj = GameObject.Instantiate(self.friendCloner)
            obj.name = tostring(i)
            self.friendLayout:AddCell(obj)
            self.friendObjList[i] = ArenaFriendItem.New(model, obj, self.assetWrapper)
        end
        self.friendObjList[i]:SetData(v, i)
    end

    for i=#friendList + 1, #self.friendObjList do
        self.friendObjList[i]:SetActive(false)
    end
end

function ArenaRankPanel:UpdateCombatForce()
    local model = self.model

    -- 阵营
    local formationId = model.formation
    local formationLev = model.formation_lev
    if formationId == nil or formationLev == nil then
        formationId = FormationManager.Instance.formationId
        formationLev = FormationManager.Instance.formationLev
    end
    local formationData = DataFormation.data_list[formationId.."_"..formationLev]
    if formationData ~= nil then
        self.formationText.text = formationData.name.."Lv."..formationLev
    end

    -- 守护

    if self.shouhuLayout == nil then
        self.shouhuLayout = LuaBoxLayout.New(self.shouhuContainer, {axis = BoxLayoutAxis.X, cspacing = 0, border = 14})
    end
    local obj = nil
    for i=1,4 do
        if self.shouhuObjList[i] == nil then
            obj = GameObject.Instantiate(self.shouhuCloner)
            obj.name = tostring(i)
            self.shouhuObjList[i] = obj
            self.shouhuLayout:AddCell(obj)
            -- local btn = obj.transform:Find("Image"):GetComponent(Button)
            -- btn.onClick:RemoveAllListeners()
            -- btn.onClick:AddListener(function() self:OnClickGuard(i) end)
            -- btn = obj.transform:Find("Add"):GetComponent(Button)
            -- if btn == nil then btn = obj.transform:Find("Add").gameObject:AddComponent(Button) end
            -- btn.onClick:RemoveAllListeners()
            -- btn.onClick:AddListener(function() self:OnClickGuard(i) end)

            local btn = obj:GetComponent(Button)
            -- if btn == nil then btn = obj:AddComponent(Button) end
            btn.onClick:RemoveAllListeners()
            btn.onClick:AddListener(function() self:OnClickGuard(i) end)
        end
    end

    for i=1,4 do
        obj = self.shouhuObjList[i]
        local t = obj.transform
        local image = t:Find("Image"):GetComponent(Image)
        local addObj = t:Find("Add").gameObject
        local attrObj = t:Find("Attr").gameObject
        if model["guardId"..i] ~= nil then
            image.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, model["guardId"..i])
            image.gameObject:SetActive(true)
            addObj:SetActive(false)

            -- 处理属性
            local effects = DataFormation.data_list[formationId.."_"..formationLev]["attr_"..(i + 1)]
            if effects ~= nil then
                -- 属性1
                local attrString = ""
                local effect_data = effects[1]
                local arrow1 = t:Find("Attr/Arrow1").gameObject
                if effect_data == nil then
                    arrow1:SetActive(false)
                else
                    attrString = KvData.attr_name_show[effect_data.attr_name]
                    if effect_data.val > 0 then
                        arrow1:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
                    else
                        arrow1:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
                    end
                    arrow1:SetActive(true)
                end
                -- 属性2
                effect_data = effects[2]
                local arrow2 = t:Find("Attr/Arrow2").gameObject
                if effect_data == nil then
                    arrow2:SetActive(false)
                else
                    attrString = string.format("%s\n%s", attrString, KvData.attr_name_show[effect_data.attr_name])
                    if effect_data.val > 0 then
                        arrow2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
                    else
                        arrow2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
                    end
                    arrow2:SetActive(true)
                end

                t:Find("Attr/Text"):GetComponent(Text).text = attrString

                if #effects == 1 then
                    arrow1.transform.localPosition = Vector2(20.9, 3)
                    t:Find("Attr/Image"):GetComponent(Image).rectTransform.sizeDelta = Vector2(70, 25)
                else
                    arrow1.transform.localPosition = Vector2(20.9, 12.4)
                    t:Find("Attr/Image"):GetComponent(Image).rectTransform.sizeDelta = Vector2(70, 40)
                end
            end

            if effects == nil or #effects == 0 then
                attrObj:SetActive(false)
            else
                attrObj:SetActive(true)
            end
        else
            image.gameObject:SetActive(false)
            addObj:SetActive(true)
            attrObj:SetActive(false)
        end
        obj:SetActive(true)
    end

    -- 宠物
    local petData = PetManager.Instance.model:getpet_byid(self.model.pet_id)
    if petData == nil then
        petData = PetManager.Instance.model.battle_petdata
    end

    local attrObj = self.petAttrObj
    if petData == nil then
        self.petImage.gameObject:SetActive(false)
        self.petAddObj:SetActive(true)
        attrObj:SetActive(false)
    else
        self.petImage.gameObject:SetActive(true)
        local headId = tostring(petData.base.head_id)

        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.petImage.gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet,headId)
        -- self.petImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
        self.petAddObj:SetActive(false)

        -- 处理属性
        local effects = DataFormation.data_list[formationId.."_"..formationLev].pet_attr
        if effects ~= nil then
            -- 属性1
            local attrString = ""
            local effect_data = effects[1]
            local arrow1 = self.petAttrArrow1
            if effect_data == nil then
                arrow1:SetActive(false)
            else
                attrString = KvData.attr_name_show[effect_data.attr_name]
                if effect_data.val > 0 then
                    arrow1:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
                else
                    arrow1:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
                end
                arrow1:SetActive(true)
            end
            -- 属性2
            effect_data = effects[2]
            local arrow2 = self.petAttrArrow2
            if effect_data == nil then
                arrow2:SetActive(false)
            else
                attrString = string.format("%s\n%s", attrString, KvData.attr_name_show[effect_data.attr_name])
                if effect_data.val > 0 then
                    arrow2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow2")
                else
                    arrow2:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "buffArrow1")
                end
                arrow2:SetActive(true)
            end

            self.petAttrText.text = attrString

            if #effects == 1 then
                arrow1.transform.localPosition = Vector2(20.9, 3)
                self.petAttrBgImage.rectTransform.sizeDelta = Vector2(70, 25)
            else
                arrow1.transform.localPosition = Vector2(20.9, 12.4)
                self.petAttrBgImage.rectTransform.sizeDelta = Vector2(70, 40)
            end
        end

        if effects == nil or #effects == 0 then
            attrObj:SetActive(false)
        else
            attrObj:SetActive(true)
        end
    end

    self.petToggle1.onValueChanged:RemoveAllListeners()
    self.petToggle2.onValueChanged:RemoveAllListeners()
    if PetManager.Instance.model:getpet_byid(self.model.pet_id) == nil then
        self.petToggle1.isOn = true
        self.petToggle2.isOn = false
    else
        self.petToggle1.isOn = false
        self.petToggle2.isOn = true
    end
    self.petToggle1.onValueChanged:AddListener(function(on) self:OnPetToggle1Change(on) end)
    self.petToggle2.onValueChanged:AddListener(function(on) self:OnPetToggle2Change(on) end)
end

function ArenaRankPanel:GuardSelectListener(index)
    local model = self.model
    self.guardSelect:Hiden()
    self.formationSelect:Hiden()

    self.guardSelect:UnSelect(self.guardSelect.lastSelect)
    local tab = self.guardSelect.selectTab
    if self.guardSelect.lastSelect == nil then
        tab[index] = true
        self.guardSelect.lastSelect = index
    elseif self.guardSelect.lastSelect == index then
        tab[index] = false
        self.guardSelect.lastSelect = nil
    else
        tab[self.guardSelect.lastSelect] = false
        tab[index] = true
        self.guardSelect.lastSelect = index
    end
    self.guardSelect:Select(self.guardSelect.lastSelect)

    local selectIndex = self.guardSelect:GetSelection()

    local currentSHList = {}
    for i=1,4 do
        currentSHList[i] = model["guardId"..i]
    end
    if selectIndex ~= nil then
        local base_id = model.currentSHList[selectIndex].base_id
        local swap_base_id = model["guardId"..self.guardWarId]
        local swap_index = nil
        for i=1,4 do
            if base_id == model["guardId"..i] then
                swap_index = i
                break
            end
        end
        currentSHList[self.guardWarId] = base_id
        if swap_index ~= nil then
            currentSHList[swap_index] = swap_base_id
        end

        self.mgr:send12207(model.formation, currentSHList[1], currentSHList[2], currentSHList[3], currentSHList[4])
    else
        currentSHList[self.guardWarId] = nil
        NoticeManager.Instance:FloatTipsByString(TI18N("该守护已经上阵"))
    end
end

function ArenaRankPanel:FormationSelectListener(index)
    local model = self.model
    self.guardSelect:Hiden()
    self.formationSelect:Hiden()

    self.formationSelect:UnSelect(self.formationSelect.lastSelect)
    local tab = self.formationSelect.selectTab
    if self.formationSelect.lastSelect ~= nil then
        tab[self.formationSelect.lastSelect] = false
    end
    tab[index] = true
    self.formationSelect.lastSelect = index
    self.formationSelect:Select(self.formationSelect.lastSelect)

    local selectIndex = self.formationSelect:GetSelection()
    if selectIndex ~= nil then
        model["formation"] = FormationManager.Instance.formationList[selectIndex].id
    else
        model["formation"] = nil
    end

    self.mgr:send12207(model.formation, model.guardId1, model.guardId2, model.guardId3, model.guardId4)
end

function ArenaRankPanel:OnClickGuard(index)
    self.formationSelect:Hiden()
    local model = self.model
    if self.guardSelect.isOpen == true then
        self.guardSelect:Hiden()
    else
        self.guardWarId = index
        self.guardSelect:Show(model.currentSHList, index, model["guardId".. index], {id = model.formation, lev = model.formation_lev})
    end
end

function ArenaRankPanel:OnClickPet()
    local exceptionList = {}
    local attachPetList = PetManager.Instance.model:GetAttachPetList()
    for _, value in ipairs(attachPetList) do
        table.insert(exceptionList, value.id)
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, { function() end, function(data) self:SelectPetCallBack(data) end, 1, exceptionList})
end

function ArenaRankPanel:SelectPetCallBack(data)
    if data ~= nil then
        if self.model.pet_id == data.id then
            NoticeManager.Instance:FloatTipsByString(TI18N("当前宠物已出阵"))
        else
            self.mgr:send12217(data.id)

            self.petToggle1.onValueChanged:RemoveAllListeners()
            self.petToggle2.onValueChanged:RemoveAllListeners()
            self.petToggle1.isOn = false
            self.petToggle2.isOn = true
            self.petToggle1.onValueChanged:AddListener(function(on) self:OnPetToggle1Change(on) end)
            self.petToggle2.onValueChanged:AddListener(function(on) self:OnPetToggle2Change(on) end)
        end
    end
end

function ArenaRankPanel:OnPetToggle1Change(on)
    if on then
        self.petToggle2.isOn = false

        local petData = PetManager.Instance.model.battle_petdata
        if petData ~= nil then
            self.mgr:send12217(0)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("当前未设置宠物出战"))
        end
    else
        self.petToggle2.isOn = true
    end
end

function ArenaRankPanel:OnPetToggle2Change(on)
    if on then
        self.petToggle1.isOn = false

        local petData = PetManager.Instance.model.battle_petdata
        if petData ~= nil then
            self.mgr:send12217(petData.id)
        end
    else
        self.petToggle1.isOn = true
    end
end