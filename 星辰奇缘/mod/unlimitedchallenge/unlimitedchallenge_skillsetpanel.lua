UnlimitedChallengeSkillSetPanel = UnlimitedChallengeSkillSetPanel or BaseClass(BasePanel)


function UnlimitedChallengeSkillSetPanel:__init(parent)
    self.parent = parent
    self.model = model
    self.Mgr = UnlimitedChallengeManager.Instance
    self.Effect = "prefabs/effect/20049.unity3d"
    self.resList = {
        {file = AssetConfig.unlimited_skillsetpanel, type = AssetType.Main}
        ,{file = self.Effect, type = AssetType.Main}
        ,{file  =  AssetConfig.arena_textures, type  =  AssetType.Dep}
        ,{file  =  AssetConfig.unlimited_texture, type  =  AssetType.Dep}
    }
    self.resetSelect = false
    self.selectSlot = 1
    self.selectSkillData = nil
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.updateslot = function()
        self:InitSkillList()
    end
    self.updateass = function()
        self:UpdateAssest()
    end

    self.skillIconList = {}
end

function UnlimitedChallengeSkillSetPanel:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if self.imgLoader2 ~= nil then
        self.imgLoader2:DeleteMe()
        self.imgLoader2 = nil
    end
    for k, v in pairs(self.skillIconList) do
        v.loader:DeleteMe()
        v = nil
    end
    self.skillIconList = nil

    self.Mgr.UnlimitedChallengeUpdate:RemoveListener(self.updateslot)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.updateass)
end
function UnlimitedChallengeSkillSetPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.unlimited_skillsetpanel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "UnlimitedChallengeSkillSetPanel"
    self.transform = self.gameObject.transform
    -- self.transform:SetAsFirstSibling()

    self.transform.localPosition = Vector3(0, 0, -500)
    self.LearnEffect = GameObject.Instantiate(self:GetPrefab(self.Effect))
    self.LearnEffect.transform:SetParent(self.transform)
    self.LearnEffect.transform.localScale = Vector3(1, 1, 1)
    self.LearnEffect.transform.localPosition = Vector3(0, 0, -1000)
    Utils.ChangeLayersRecursively(self.LearnEffect.transform, "UI")
    self.LearnEffect:SetActive(false)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self:Hiden()
    end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
        self:Hiden()
    end)
    self.SelectCon  = self.transform:Find("Main/SelectPanel/MaskScroll/IconCon")
    local infobtn = self.transform:Find("Main/SelectPanel/Button"):GetComponent(Button)
    infobtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = infobtn.gameObject, itemData = {
            TI18N("1、击败无尽挑战每波怪物都可获得{assets_2, 90023}"),
            TI18N("2、消耗{assets_2, 90023}可学习挑战技能"),
            TI18N("3、挑战技能无需升级，学习之后可永久掌握"),
            }})
        end)
    self.BaseSkillIcon = self.SelectCon:Find("BaseIcon")

    self.Slot1 = self.transform:Find("Main/Right/IconCon"):GetChild(0)
    self.Slot2 = self.transform:Find("Main/Right/IconCon"):GetChild(1)
    self.Slot = {}
    for i=1,2 do
        self.Slot[i] = {}
        local transform = self.transform:Find("Main/Right/IconCon"):GetChild(i-1)
        self.Slot[i].Select = transform:Find("select").gameObject
        self.Slot[i].Icon = transform:Find("Icon"):GetComponent(Image)
        transform:GetComponent(CustomButton).onClick:AddListener(function()
            self:SelectSlot(i)
        end)
    end
    self.descIcon = self.transform:Find("Main/Right/DescCon/Icon"):GetComponent(Image)
    self.descName = self.transform:Find("Main/Right/DescCon/Name"):GetComponent(Text)
    self.descText = self.transform:Find("Main/Right/DescCon/MaskScroll/descText"):GetComponent(Text)

    self.LearnCon = self.transform:Find("Main/Right/LearnCon").gameObject

    if self.imgLoader == nil then
        local go = self.transform:Find("Main/SelectPanel/AssIcon").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 90023)

    self.LScoreNum = self.transform:Find("Main/SelectPanel/AssNum"):GetComponent(Text)

    if self.imgLoader2 == nil then
        local go = self.LearnCon.transform:Find("ScoreIcon").gameObject
        self.imgLoader2 = SingleIconLoader.New(go)
    end
    self.imgLoader2:SetSprite(SingleIconType.Item, 90023)

    self.ScoreNum = self.LearnCon.transform:Find("ScoreNum"):GetComponent(Text)
    self.AssIcon = self.LearnCon.transform:Find("AssIcon"):GetComponent(Image)
    self.AssNum = self.LearnCon.transform:Find("AssNum"):GetComponent(Text)
    self.Assbg = self.LearnCon.transform:Find("Assbg"):GetComponent(Image)

    self.UseButton = self.transform:Find("Main/Right/UseButton"):GetComponent(Button)
    self.LearnButton = self.LearnCon.transform:Find("LearnButton"):GetComponent(Button)
    self.LearnButton.onClick:AddListener(function()
        self:OnLearn()
    end)
    self.UseButton.onClick:AddListener(function()
        self:OnUse()
    end)
    self.resetSelect = true
    self.selectSlot = self.openArgs
    self:InitSkillList()
    self:UpdateAssest()
    self.Mgr.UnlimitedChallengeUpdate:AddListener(self.updateslot)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.updateass)
end
function UnlimitedChallengeSkillSetPanel:OnOpen()
    self.resetSelect = true
    self.selectSlot = self.openArgs
    self:SelectSlot()
    self:UpdateSelect()
end

function UnlimitedChallengeSkillSetPanel:OnHide()

end

function UnlimitedChallengeSkillSetPanel:InitSkillList()
    local List = {}
    -- for k,v in pairs(DataSkill.data_endless_challenge) do
    --     table.insert(List, v)
    -- end
    for k,v in pairs(DataEndlessChallenge.data_skill_cost) do
        table.insert(List, v)
    end
    table.sort(List, function(a, b)
        if a.lev < b.lev then
            return true
        elseif a.lev == b.lev then
            if a.skill_id < b.skill_id then
                return true
            else
                return false
            end
        else
            return false
        end
    end)
    for k,cfg in pairs(List) do
        local v = DataSkill.data_endless_challenge[cfg.skill_id]
        local isold = true
        local Item = self.skillIconList[v.id]
        if Item == nil then
            isold = false
            local go = GameObject.Instantiate(self.BaseSkillIcon.gameObject)
            Item.gameObject = go
            Item.transform = go.transform
            Item.loader = SingleIconLoader.New(go.transform:Find("Icon").gameObject)
            self.skillIconList[v.id] = Item
        end
        Item.gameObject.name = tostring(v.id)
        Item.transform:SetParent(self.SelectCon)
        Item.gameObject:SetActive(true)
        Item.transform.localScale = Vector3.one
        -- Item.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_endless, tostring(v.icon))
        Item.loader:SetSprite(SingleIconType.SkillIcon, tostring(v.icon))
        Item.transform:Find("Icon").gameObject:SetActive(true)
        Item.transform:Find("Text"):GetComponent(Text).text = v.name
        local Ican = self.Mgr:IsLearned(v.id)
        if Ican then
            if Item.transform:Find("SkillNameBg").gameObject.activeSelf == true and isold then
                self.LearnEffect.transform:SetParent(Item.transform)
                self.LearnEffect.transform.localScale = Vector3(1, 1, 1)
                self.LearnEffect.transform.localPosition = Vector3(35, -35, -1000)
                self.LearnEffect:SetActive(false)
                self.LearnEffect:SetActive(true)
            end
            Item.transform:Find("SkillNameBg").gameObject:SetActive(false)
            Item.transform:Find("SkillNameTxt").gameObject:SetActive(false)
        else
            Item.transform:Find("SkillNameBg").gameObject:SetActive(true)
            Item.transform:Find("SkillNameTxt").gameObject:SetActive(true)
        end
        Item.transform:GetComponent(CustomButton).onClick:RemoveAllListeners()
        Item.transform:GetComponent(CustomButton).onClick:AddListener(function()
            self:SelectSkill(v, Ican)
        end)
        if self.selectSkillData ~= nil and self.selectSkillData.id == v.id then
            self:SelectSkill(v, Ican)
        elseif self.selectSkillData == nil then
            self:SelectSkill(v, Ican)
        end
    end
    self:UpdateSlotSkill()
    self:SelectSlot()
    self:UpdateSelect()
end

function UnlimitedChallengeSkillSetPanel:SelectSkill(data, Ican)
    if self.selectSkillData ~= nil then
        self.SelectCon:Find(tostring(self.selectSkillData.id)):Find("Select").gameObject:SetActive(false)
    end
    self.selectSkillData = data
    if Ican then
        self.LearnCon:SetActive(false)
        self.UseButton.gameObject:SetActive(true)
    else
        self.LearnCon:SetActive(true)
        self.UseButton.gameObject:SetActive(false)
        local Cost = DataEndlessChallenge.data_skill_cost[data.id].cost
        for i,v in ipairs(Cost) do
            if v[1] == 90023 then
                if v[2] > RoleManager.Instance.RoleData.endless_challenge then
                    self.ScoreNum.text = string.format("<color='#ff0000'>%s</color>", tostring(v[2]))
                else
                    self.ScoreNum.text = string.format("<color='#00ff00'>%s</color>", tostring(v[2]))
                end
            else
                self.AssIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, string.format("Assets%s", tostring(v[1])))
                self.AssNum.text = tostring(v[2])
            end
        end
        self.AssIcon.gameObject:SetActive(#Cost == 2)
        self.AssNum.gameObject:SetActive(#Cost == 2)
        self.Assbg.gameObject:SetActive(#Cost == 2)
    end
    self.SelectCon:Find(tostring(self.selectSkillData.id)):Find("Select").gameObject:SetActive(true)
    self.descIcon.sprite = self.SelectCon:Find(tostring(data.id)):Find("Icon"):GetComponent(Image).sprite
    self.descName.text = data.name
    if Ican then
        self.descText.text = data.desc
    else
        self.descText.text = string.format(TI18N("%s\n<color='#00ff00'>该技能未习得，请先学习后再使用</color>"), data.desc)
    end
end

function UnlimitedChallengeSkillSetPanel:UpdateSelect(data, Ican)
    -- for i,v in ipairs(self.Mgr.skillData.choose_skills) do
    --     print(i,v)
    -- end
end

function UnlimitedChallengeSkillSetPanel:SelectSlot(index)
    if index ~= nil then
        for i,v in ipairs(self.Slot) do
            v.Select:SetActive(index == i)
        end
        self.selectSlot = index
    else
        for i,v in ipairs(self.Slot) do
            v.Select:SetActive(self.selectSlot == i)
        end
    end
    if self.resetSelect then
        self:UpdateSlotSkill()
    end
end

function UnlimitedChallengeSkillSetPanel:UpdateSlotSkill()
    local skillchose = self.Mgr.skillData.choose_skills
    local temp = {}
    for k,v in pairs(skillchose) do
        temp[v.index] = v.skill_id
    end
    for i=1, 2 do
        if temp[i] ~= nil then
            local sprite = self.SelectCon:Find(tostring(temp[i])):Find("Icon"):GetComponent(Image).sprite
            self.Slot[i].Icon.sprite = sprite
            self.Slot[i].Icon.gameObject:SetActive(true)
            if self.resetSelect and self.selectSlot == i then
                self:SelectSkill(DataSkill.data_endless_challenge[temp[i]], true)
                self.resetSelect = false
            end

        else
            self.Slot[i].Icon.gameObject:SetActive(false)
        end
    end
end

function UnlimitedChallengeSkillSetPanel:OnLearn()
    if self.selectSkillData ~= nil then
        self.Mgr:Require17207(self.selectSkillData.id)
    end
end

function UnlimitedChallengeSkillSetPanel:OnUse()
    if self.selectSkillData ~= nil and self.selectSlot ~= nil then
        self.Mgr:Require17203(self.selectSlot, self.selectSkillData.id)
    end
end

function UnlimitedChallengeSkillSetPanel:UpdateAssest()
    self.LScoreNum.text = tostring(RoleManager.Instance.RoleData.endless_challenge)
end