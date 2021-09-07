-- 宠物召唤
CombatSummonPanel = CombatSummonPanel or BaseClass()

function CombatSummonPanel:__init(mainPanel)
    self.mainPanel = mainPanel
    self.assetWrapper = self.mainPanel.combatMgr.assetWrapper
    self.gameObject = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.combat_summon_path))
    GameObject.DontDestroyOnLoad(self.gameObject)
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.mainPanel.mixPanel.gameObject, self.gameObject)

    self.Text = self.transform:FindChild("Window/LeftPanel/Text").gameObject
    self.Mash = self.transform:FindChild("Panel").gameObject
    self.PetInfoPanel = self.transform:FindChild("Window/LeftPanel/PetInfoPanel").gameObject
    self.Container = self.transform:FindChild("Window/RightPanel/Mash/Container").gameObject
    self.basePetInfo = self.Container.transform:FindChild("PetInfo").gameObject
    self.basePetInfo:SetActive(false)
    self.CloseBut = self.transform:FindChild("Window/CloseBut").gameObject
    self.SummonBut = self.transform:FindChild("Window/SummonBut").gameObject
    self.SummonButImg = self.transform:FindChild("Window/SummonBut"):GetComponent(Image)
    self.cdText = self.transform:FindChild("Window/cdText"):GetComponent(Text)
    self.CountTxt = self.transform:FindChild("Window/Count/CountTxt").gameObject

    self.LeftPanel = self.transform:FindChild("Window/LeftPanel").gameObject
    self.skillNameContainer = self.LeftPanel.transform:FindChild("PetInfoPanel/SkillContainer/Mash/Container").gameObject
    self.baseSkillName = self.skillNameContainer.transform:FindChild("SkillName").gameObject

    self.CloseBut:GetComponent(Button).onClick:AddListener(function() self:OnCloseBtnClick() end )
    self.SummonBut:GetComponent(Button).onClick:AddListener(function() self:OnSummonButClick() end )
    self.Mash:GetComponent(Button).onClick:AddListener(function() self:OnCloseBtnClick() end )
    self.headLoaderList = {}
    self.data10731 = nil

    self.summon_child_isCD = nil
    self.IsInit = false
    self.gameObject:SetActive(false)
    self.selectFrame = nil
end

function CombatSummonPanel:__delete()
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
end

function CombatSummonPanel:InitPanel()
    self.Text:SetActive(true)
    self.PetInfoPanel:SetActive(false)

    local petList = self.data10731.backup_pets
    local childList = self.data10731.backup_childs
    self.summon_child_isCD = nil
    if self.mainPanel.cdList ~= nil then
        for k,v in pairs(self.mainPanel.cdList) do
            if v.skill_id == 1009 then
                self.summon_child_isCD = v.cd_left
            end
        end
    end
    if self.summon_child_isCD then
        self.cdText.text = string.format("子女登场冷却：<color='#2fc823'>%s</color>回合", tostring(self.summon_child_isCD))
    else
        self.cdText.text = ""
    end
    -- local petList = mod_pet.petlist
    for _, data in ipairs(petList) do
        if data.can_summon == 1 then
            local PetInfo = GameObject.Instantiate(self.basePetInfo)
            -- local faceId = data.base.head_id
            local faceId = DataPet.data_pet[data.base_id].head_id
            local HeadImage = PetInfo.transform:FindChild("HeadBg/HeadImage").gameObject
            local Fighting = PetInfo.transform:FindChild("HeadBg/Fighting").gameObject
            local PetName = PetInfo.transform:FindChild("PetName").gameObject
            local Lev = PetInfo.transform:FindChild("Text").gameObject
            local Select = PetInfo.transform:FindChild("Select").gameObject
            -- local sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(faceId), tostring(faceId))
            -- if sprite ~= nil then
            local loaderId = HeadImage.transform:GetComponent(Image).gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(HeadImage.transform:GetComponent(Image).gameObject)
            end
            self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,faceId)
                -- HeadImage.transform:GetComponent(Image).sprite = sprite
            -- end
            Fighting:SetActive(false)
            PetName.transform:GetComponent(Text).text = data.name
            Lev.transform:GetComponent(Text).text = string.format(TI18N("等级 %s"), tostring(data.lev))
            PetInfo.transform:SetParent(self.Container.transform)
            PetInfo.transform.localScale = Vector3(1, 1, 1)
            PetInfo.transform.localPosition = Vector3(0, 0, -100)
            PetInfo:SetActive(true)
            -- event_manager:GetUIEvent(PetInfo).OnClick:AddListener(function() self:OnPetSelectClick(Select, data, faceId) end)
            PetInfo:GetComponent(Button).onClick:AddListener(function()self.cdText.gameObject:SetActive(false) BaseUtils.SetGrey(self.SummonButImg, false) self:OnPetSelectClick(Select, data, faceId) end)
        end
    end
    for _, data in ipairs(childList) do
        if data.can_summon == 1 then
            local PetInfo = GameObject.Instantiate(self.basePetInfo)
            -- local faceId = data.base.head_id
            local faceId = DataChild.data_child[data.base_id].head_id
            local HeadImage = PetInfo.transform:FindChild("HeadBg/HeadImage").gameObject
            local Fighting = PetInfo.transform:FindChild("HeadBg/Fighting").gameObject
            local PetName = PetInfo.transform:FindChild("PetName").gameObject
            local Lev = PetInfo.transform:FindChild("Text").gameObject
            local Select = PetInfo.transform:FindChild("Select").gameObject
            local CD = PetInfo.transform:FindChild("cd"):GetComponent(Image)
            local CDtext = PetInfo.transform:FindChild("cd/Text"):GetComponent(Text)
            local sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.childhead, tostring(faceId))
            if sprite ~= nil then
                HeadImage.transform:GetComponent(Image).sprite = sprite
            end
            if self.summon_child_isCD and self.summon_child_isCD > 0 then
                CD.gameObject:SetActive(true)
                CD.fillAmount = self.summon_child_isCD/5
                CDtext.text = tostring(self.summon_child_isCD)
            else
                CD.gameObject:SetActive(false)
            end
            Fighting:SetActive(false)
            PetName.transform:GetComponent(Text).text = data.name
            Lev.transform:GetComponent(Text).text = string.format(TI18N("等级 %s"), tostring(data.lev))
            PetInfo.transform:SetParent(self.Container.transform)
            PetInfo.transform.localScale = Vector3(1, 1, 1)
            PetInfo.transform.localPosition = Vector3(0, 0, -100)
            PetInfo:SetActive(true)
            -- event_manager:GetUIEvent(PetInfo).OnClick:AddListener(function() self:OnPetSelectClick(Select, data, faceId) end)
            PetInfo:GetComponent(Button).onClick:AddListener(function()self.cdText.gameObject:SetActive(true) BaseUtils.SetGrey(self.SummonButImg, self.summon_child_isCD and self.summon_child_isCD > 0) self:OnChildSelectClick(Select, data, faceId) end)
        end
    end
    self.IsInit = true
end

function CombatSummonPanel:Show()
    -- self.transform:SetParent(self.mainPanel.extendPanel.transform)
    UIUtils.AddUIChild(self.mainPanel.extendPanel.gameObject, self.gameObject)
    if not self.IsInit then
        self:InitPanel()
    else
        self.Text:SetActive(true)
        self.PetInfoPanel:SetActive(false)
        self:RefreshPetPanel()
    end
    if self.data10731 ~= nil then
        self.CountTxt.transform:GetComponent(Text).text = "" .. tostring(self.data10731.summon_num) .. "/4"
    end
    self.summon_child_isCD = nil
    if self.mainPanel.cdList ~= nil then
        for k,v in pairs(self.mainPanel.cdList) do
            if v.skill_id == 1009 then
                self.summon_child_isCD = v.cd_left
            end
        end
    end
    if self.summon_child_isCD then
        self.cdText.text = string.format("子女登场冷却：<color='#2fc823'>%s</color>回合", tostring(self.summon_child_isCD))
    else
        self.cdText.text = ""
    end
    self.gameObject:SetActive(true)
end

function CombatSummonPanel:OnCloseBtnClick()
    self.gameObject:SetActive(false)
end

function CombatSummonPanel:OnPetSelectClick(selectFrame, data, faceId)
    self.Text:SetActive(false)
    self.PetInfoPanel:SetActive(true)

    if self.selectFrame ~= nil
        and self.selectFrame.frame ~= nil
        and not BaseUtils.is_null(self.selectFrame.frame)
        and self.selectFrame.frame.activeSelf then
        self.selectFrame.frame:SetActive(false)
    end
    self.selectFrame = {frame = selectFrame, data = data}
    self.selectFrame.frame:SetActive(true)

    local HeadImage = self.LeftPanel.transform:FindChild("PetInfoPanel/HeadBg/HeadImage").gameObject

    local loaderId = HeadImage.gameObject:GetInstanceID()
    if self.headLoaderList[loaderId] == nil then
        self.headLoaderList[loaderId] = SingleIconLoader.New(HeadImage.gameObject)
    end
    self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,faceId)

    -- local sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(faceId), tostring(faceId))
    if self.headLoaderList[loaderId].image.sprite ~= nil then
        -- HeadImage.transform:GetComponent(Image).sprite = sprite
        HeadImage:SetActive(true)
    end
    local PetName = self.LeftPanel.transform:FindChild("PetInfoPanel/PetName").gameObject
    PetName:GetComponent(Text).text = data.name

    local tcc = self.skillNameContainer.transform.childCount
    local list = {}
    for i = 1, tcc do
        local child = self.skillNameContainer.transform:GetChild(i - 1)
        if child.gameObject.activeSelf then
            table.insert(list, child)
        end
    end
    for _, data2 in ipairs(list) do
        GameObject.Destroy(data2.gameObject)
    end

    local skillList = {}
    local petSkilllist = CombatManager.Instance.enterData.pet_skill_infos
    for _, pskillInfo in ipairs(petSkilllist) do
        if pskillInfo.pet_id == data.id then
            skillList = pskillInfo.pet_skill_infos
        end
    end

    for _, data3 in ipairs(skillList) do
        local skillList = data3.skill_data_2
        local passive = data3.skill_type_2 ~= 0
        for _, data4 in ipairs(skillList) do
            if data4.skill_id_2 > 1004  then
                local key = BaseUtils.Key(data4.skill_id_2, data4.skill_lev_2)
                local skillData = DataSkill.data_petSkill[key]
                if skillData ~= nil then
                    local skillNameObj = GameObject.Instantiate(self.baseSkillName)
                    skillNameObj:SetActive(true)
                    if not passive then
                        skillNameObj:GetComponent(Text).text = string.format("<color='#ffff00'>%s</color>", skillData.name)
                    else
                        skillNameObj:GetComponent(Text).text = skillData.name
                    end
                    skillNameObj.transform:SetParent(self.skillNameContainer.transform)
                    skillNameObj.transform.localScale = Vector3(1, 1, 1)
                end
            end
        end
    end
end


function CombatSummonPanel:OnChildSelectClick(selectFrame, data, faceId)
    self.Text:SetActive(false)
    self.PetInfoPanel:SetActive(true)

    if self.selectFrame ~= nil
        and self.selectFrame.frame ~= nil
        and not BaseUtils.is_null(self.selectFrame.frame)
        and self.selectFrame.frame.activeSelf then
        self.selectFrame.frame:SetActive(false)
    end
    self.selectFrame = {frame = selectFrame, data = data, ischild = true}
    self.selectFrame.frame:SetActive(true)
    local HeadImage = self.LeftPanel.transform:FindChild("PetInfoPanel/HeadBg/HeadImage").gameObject
    local sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.childhead, tostring(faceId))
    if sprite ~= nil then
        HeadImage.transform:GetComponent(Image).sprite = sprite
        HeadImage:SetActive(true)
        sprite = nil
    end
    local PetName = self.LeftPanel.transform:FindChild("PetInfoPanel/PetName").gameObject
    PetName:GetComponent(Text).text = data.name

    local tcc = self.skillNameContainer.transform.childCount
    local list = {}
    for i = 1, tcc do
        local child = self.skillNameContainer.transform:GetChild(i - 1)
        if child.gameObject.activeSelf then
            table.insert(list, child)
        end
    end
    for _, data2 in ipairs(list) do
        GameObject.Destroy(data2.gameObject)
    end

    local skillList = {}
    local childSkilllist = CombatManager.Instance.enterData.child_skill_infos
    for _, cskillInfo in ipairs(childSkilllist) do
        if cskillInfo.child_id == data.id then
            skillList = cskillInfo.child_skill_infos
        end
    end

    for _, data3 in ipairs(skillList) do
        local skillList = data3.skill_data_3
        local passive = data3.skill_type_3 ~= 0
        for _, data4 in ipairs(skillList) do
            if data4.skill_id_3 > 1004  then
                local key = BaseUtils.Key(data4.skill_id_3, data4.skill_lev_3)
                local skillData = DataSkill.data_child_skill[data4.skill_id_3]
                if skillData == nil then
                    skillData = DataSkill.data_child_telent[string.format("%s_1",data4.skill_id_3)]
                end
                if skillData ~= nil then
                    local skillNameObj = GameObject.Instantiate(self.baseSkillName)
                    skillNameObj:SetActive(true)
                    if not passive then
                        skillNameObj:GetComponent(Text).text = string.format("<color='#ffff00'>%s</color>", skillData.name)
                    else
                        skillNameObj:GetComponent(Text).text = skillData.name
                    end
                    skillNameObj.transform:SetParent(self.skillNameContainer.transform)
                    skillNameObj.transform.localScale = Vector3(1, 1, 1)
                end
            end
        end
    end
end


function CombatSummonPanel:SetData10731(data)
    self.data10731 = data
end

function CombatSummonPanel:RefreshPetPanel()
    self.summon_child_isCD = nil
    if self.mainPanel.cdList ~= nil then
        for k,v in pairs(self.mainPanel.cdList) do
            if v.skill_id == 1009 then
                self.summon_child_isCD = v.cd_left
            end
        end
    end
    if self.summon_child_isCD then
        self.cdText.text = string.format("子女登场冷却：<color='#2fc823'>%s</color>回合", tostring(self.summon_child_isCD))
    else
        self.cdText.text = ""
    end
    CombatUtil.DestroyChildActive(self.Container)
    local petList = self.data10731.backup_pets
    local childList = self.data10731.backup_childs
    for _, data in ipairs(petList) do
        if data.can_summon == 1 then
            local PetInfo = GameObject.Instantiate(self.basePetInfo)
            local faceId = DataPet.data_pet[data.base_id].head_id
            local HeadImage = PetInfo.transform:FindChild("HeadBg/HeadImage").gameObject
            local Fighting = PetInfo.transform:FindChild("HeadBg/Fighting").gameObject
            local PetName = PetInfo.transform:FindChild("PetName").gameObject
            local Lev = PetInfo.transform:FindChild("Text").gameObject
            local Select = PetInfo.transform:FindChild("Select").gameObject

            local loaderId = HeadImage.transform:GetComponent(Image).gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(HeadImage.transform:GetComponent(Image).gameObject)
            end
            self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,faceId)

            -- local sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(faceId), tostring(faceId))
            -- if sprite ~= nil then
            --     HeadImage.transform:GetComponent(Image).sprite = sprite
            -- end
            Fighting:SetActive(false)
            PetName.transform:GetComponent(Text).text = data.name
            Lev.transform:GetComponent(Text).text = TI18N("等级 ") .. tostring(data.lev)
            PetInfo.transform:SetParent(self.Container.transform)
            PetInfo.transform.localScale = Vector3(1, 1, 1)
            PetInfo.transform.localPosition = Vector3(0, 0, -100)
            PetInfo:SetActive(true)
            -- event_manager:GetUIEvent(PetInfo).OnClick:AddListener(function() self:OnPetSelectClick(Select, data, faceId) end)
            PetInfo:GetComponent(Button).onClick:AddListener(function() self.cdText.gameObject:SetActive(false) BaseUtils.SetGrey(self.SummonButImg, false) self:OnPetSelectClick(Select, data, faceId) end)
        end
    end
    for _, data in ipairs(childList) do
        if data.can_summon == 1 then
            local PetInfo = GameObject.Instantiate(self.basePetInfo)
            -- local faceId = data.base.head_id
            local faceId = DataChild.data_child[data.base_id].head_id
            local HeadImage = PetInfo.transform:FindChild("HeadBg/HeadImage").gameObject
            local Fighting = PetInfo.transform:FindChild("HeadBg/Fighting").gameObject
            local PetName = PetInfo.transform:FindChild("PetName").gameObject
            local Lev = PetInfo.transform:FindChild("Text").gameObject
            local Select = PetInfo.transform:FindChild("Select").gameObject
            local CD = PetInfo.transform:FindChild("cd"):GetComponent(Image)
            local CDtext = PetInfo.transform:FindChild("cd/Text"):GetComponent(Text)
            local sprite = CombatManager.Instance.assetWrapper:GetSprite(AssetConfig.childhead, tostring(faceId))
            -- local sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(faceId), tostring(faceId))
            local headimg = HeadImage.transform:GetComponent(Image)
            if sprite ~= nil then
                headimg.sprite = sprite
            end
            if self.summon_child_isCD and self.summon_child_isCD > 0 then
                CD.gameObject:SetActive(true)
                CD.fillAmount = self.summon_child_isCD/5
                CDtext.text = tostring(self.summon_child_isCD)
            else
                CD.gameObject:SetActive(false)
            end

            Fighting:SetActive(false)
            PetName.transform:GetComponent(Text).text = data.name
            Lev.transform:GetComponent(Text).text = string.format(TI18N("等级 %s"), tostring(data.lev))
            PetInfo.transform:SetParent(self.Container.transform)
            PetInfo.transform.localScale = Vector3(1, 1, 1)
            PetInfo.transform.localPosition = Vector3(0, 0, -100)
            PetInfo:SetActive(true)
            -- event_manager:GetUIEvent(PetInfo).OnClick:AddListener(function() self:OnPetSelectClick(Select, data, faceId) end)
            PetInfo:GetComponent(Button).onClick:AddListener(function() self.cdText.gameObject:SetActive(true) BaseUtils.SetGrey(self.SummonButImg, self.summon_child_isCD and self.summon_child_isCD > 0) self:OnChildSelectClick(Select, data, faceId) end)
        end
    end
end

function CombatSummonPanel:OnSummonButClick()
    if self.selectFrame ~= nil then
        if self.selectFrame.ischild and self.summon_child_isCD and self.summon_child_isCD > 0 then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s回合后才能召唤子女"), tostring(self.summon_child_isCD)))
            return
        end
        if self.selectFrame.ischild then
            local hpLev = 4
            local hungry = self.selectFrame.data.hungry
            local childHappyData = ChildrenManager.Instance:GetHappinessByHugry(hungry)
            if childHappyData ~= nil then
              hpLev =  childHappyData.happiness
            end

--            local happyDatas = DataChild.data_child_happiness
--            for key,val in pairs(happyDatas) do
--                if hugry >= val.min_val and  hugry <= val.max_val then
--                    hpLev = val.lev
--                    break
--                end
--            end
            if hpLev == 1  then
              local confirmData = NoticeConfirmData.New()
                confirmData.type = ConfirmData.Style.Normal
                confirmData.sureLabel = TI18N("确认")
                confirmData.cancelLabel = TI18N("取消")
                confirmData.sureCallback =
                    function()
                        self:SendSymmon()
                    end
                confirmData.content = string.format(TI18N("宝宝心情低落，召唤只有<color='%s'>50%%</color>几率出战成功？"),ColorHelper.color[1])
                NoticeManager.Instance:ConfirmTips(confirmData)
                return
            end
        end
         self:SendSymmon()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择召唤宠物"))
    end
end

function CombatSummonPanel:SendSymmon()
        self.mainPanel:OnSummonButClick(self.selectFrame.data.id, self.selectFrame.ischild)
        self.gameObject:SetActive(false)
end
