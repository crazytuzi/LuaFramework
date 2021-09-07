-- -------------------------------------------
-- 子女技能
-- hosr
-- -------------------------------------------
PetChildSkillView = PetChildSkillView or BaseClass(BasePanel)

function PetChildSkillView:__init(parent)
	self.parent = parent
    self.name = "PetView_ChildSkill"
    self.resList = {
        {file = AssetConfig.petwindow_childskillpanel, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.headride, type = AssetType.Dep}
    }

    self.sliderList = {}
    self.sliderValList = {}
    self.addImgList = {}
    self.recommendList = {}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.infoListener = function() self:UpdateInfo() end
    self.skillListener = function() self:UpdateSkill() end

    self.conList = {}
    self.skillList = {}

    self.tips = {
        TI18N("1、孩子拥有<color='#ffff00'>3个职业技能</color>，不会被打书所学技能覆盖"),
        TI18N("2、打书可使孩子<color='#ffff00'>额外获得2个技能</color>，超过2个则会<color='#ffff00'>顶替</color>"),
        TI18N("3、佩戴项链将使孩子学会项链上附带的技能"),
        TI18N("4、孩子进阶后，项链技能将融入孩子体内，可被覆盖"),
    }

    self.growthtips = {
        TI18N("成长率影响孩子加点所产生的效果"),
        -- TI18N("可使用<color='#ffff00'>掌上明珠</color>进行提升"),
    }
end

function PetChildSkillView:__delete()
    if self.growIcon ~= nil then
        self.growIcon.sprite = nil
    end

    for i,v in ipairs(self.skillList) do
        v:DeleteMe()
    end
    self.skillList = nil
    self:OnHide()
end

function PetChildSkillView:OnShow()
    ChildrenManager.Instance.OnChildDataUpdate:Add(self.infoListener)
    ChildrenManager.Instance.OnChildAttrUpdate:Add(self.infoListener)
    ChildrenManager.Instance.OnChildSkillUpdate:Add(self.skillListener)
    self:Update()
end

function PetChildSkillView:OnHide()
    ChildrenManager.Instance.OnChildDataUpdate:Remove(self.infoListener)
    ChildrenManager.Instance.OnChildAttrUpdate:Remove(self.infoListener)
    ChildrenManager.Instance.OnChildSkillUpdate:Remove(self.skillListener)
end

function PetChildSkillView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petwindow_childskillpanel))
    self.gameObject.name = "PetView_ChildSkill"
    self.gameObject.transform:SetParent(self.parent.panelContainer)
    self.gameObject.transform.localScale = Vector3.one
    self.gameObject.transform.localPosition = Vector3(-132, 205, 0)

    self.transform = self.gameObject.transform

    for i = 1, 5 do
        local item = self.transform:Find("QualityPanel/ValueSlider" .. i)
        table.insert(self.sliderList, item:Find("Slider"):GetComponent(Slider))
        table.insert(self.sliderValList, item:Find("Text"):GetComponent(Text))
        table.insert(self.addImgList, self.transform:Find("QualityPanel/AddImage" .. i).gameObject)
        table.insert(self.recommendList, self.transform:Find("QualityPanel/Recommend" .. i).gameObject)
    end

    self.transform:Find("QualityPanel"):GetComponent(Button).onClick:AddListener(function() self:ClickFeed() end)
    self.growthVal = self.transform:Find("QualityPanel/GrowthText"):GetComponent(Text)
    self.growIcon = self.transform:Find("QualityPanel/GrowthImage"):GetComponent(Image)
    self.transform:Find("QualityPanel/GrowthImage"):GetComponent(Button).onClick:AddListener(function() self:GrowthTips() end)

    local skill = self.transform:Find("SkillPanel")
    self.descObj = skill:Find("DescButton").gameObject
    self.descObj:GetComponent(Button).onClick:AddListener(function() self:ClickDesc() end)
    skill:Find("LearnSkillButton"):GetComponent(Button).onClick:AddListener(function() self:ClickLearn() end)

    local container = skill:Find("SoltPanel/Container")
    self.containerRect = container:GetComponent(RectTransform)
    for i = 1, 15 do
        if i > 10 then
            container:Find("Solt" .. i).gameObject:SetActive(false)
        else
            local item = container:Find("Solt" .. i).gameObject
            table.insert(self.conList, item)
        end
    end

    container:Find("RecommendSkillButtom").gameObject:SetActive(false)
    -- self.recommendBtn:GetComponent(Button).onClick:AddListener(function() self:ClickRecommend() end)

    self:OnShow()
end

function PetChildSkillView:ClickDesc()
    TipsManager.Instance:ShowText({gameObject = self.descObj, itemData = self.tips})
end

function PetChildSkillView:ClickLearn()
    if self.currData == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有孩子"))
        return
    end

    if self.currData.status == ChildrenEumn.Status.Follow then
        if BaseUtils.get_unique_roleid(self.currData.follow_id, self.currData.f_zone_id, self.currData.f_platform) == BaseUtils.get_self_id() then
            -- PetManager.Instance.model:OpenChildLearnSkill()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
    end

    PetManager.Instance.model:OpenChildLearnSkill()
end

function PetChildSkillView:ClickRecommend()
    if self.currData == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前没有孩子"))
    else
        PetManager.Instance.model:OpenRecommendSkillWindow()
    end
end

function PetChildSkillView:Update()
    self.currData = PetManager.Instance.model.currChild
    if self.currData == nil then
        return
    end
    self:UpdateInfo()
    self:UpdateSkill()
end

function PetChildSkillView:UpdateInfo()
    self.sliderList[1].value = self.currData.phy_aptitude / self.currData.max_phy_aptitude
    self.sliderList[2].value = self.currData.pdef_aptitude / self.currData.max_pdef_aptitude
    self.sliderList[3].value = self.currData.hp_aptitude / self.currData.max_hp_aptitude
    self.sliderList[4].value = self.currData.magic_aptitude / self.currData.max_magic_aptitude
    self.sliderList[5].value = self.currData.aspd_aptitude / self.currData.max_aspd_aptitude

    self.sliderValList[1].text = string.format("%s/%s", self.currData.phy_aptitude, self.currData.max_phy_aptitude)
    self.sliderValList[2].text = string.format("%s/%s", self.currData.pdef_aptitude, self.currData.max_pdef_aptitude)
    self.sliderValList[3].text = string.format("%s/%s", self.currData.hp_aptitude, self.currData.max_hp_aptitude)
    self.sliderValList[4].text = string.format("%s/%s", self.currData.magic_aptitude, self.currData.max_magic_aptitude)
    self.sliderValList[5].text = string.format("%s/%s", self.currData.aspd_aptitude, self.currData.max_aspd_aptitude)

    self.growthVal.text = string.format("%.2f", self.currData.growth / 500)
    self.growIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, string.format("PetGrowth%s", self.currData.growth_type))
end

function PetChildSkillView:UpdateSkill()
    local count = 0

    for i,v in ipairs(self.skillList) do
        v:SetAll(nil)
        v.gameObject:SetActive(false)
    end

    local baseData = DataChild.data_child[self.currData.base_id]
    for i,v in ipairs(baseData.classes_skills) do
        count = count + 1
        local slot = self:GetSkillItem(count)
        local skillData = DataSkill.data_child_skill[v[1]]
        slot:SetAll(Skilltype.childskill, skillData, {classes = self.currData.classes})
        slot.gameObject:SetActive(true)
        self.conList[count]:SetActive(true)
        if self.currData.grade >= v[2] then
            slot:ShowOnOpen(false)
        else
            slot:ShowOnOpen(true, TI18N("<color='#ffff9a'>进阶\n开放</color>"))
        end
    end

    for i,v in ipairs(self.currData.skills) do
        if v.source ~= 2 then
            count = count + 1
            local slot = self:GetSkillItem(count)
            local skillData = DataSkill.data_child_skill[v.id]
            slot:SetAll(Skilltype.petskill, skillData)
            slot.gameObject:SetActive(true)
            self.conList[count]:SetActive(true)

            if v.source == 3 then
                slot:ShowChildState(true)
            else
                slot:ShowChildState(false)
            end
        end
    end


    self.containerRect.sizeDelta = Vector2(320, math.ceil(10 / 5) * 60)
end

function PetChildSkillView:GetSkillItem(index)
    local item = self.skillList[index]
    if item == nil then
        item = SkillSlot.New()
        UIUtils.AddUIChild(self.conList[index], item.gameObject)
        table.insert(self.skillList, item)
    end
    return item
end

function PetChildSkillView:GrowthTips()
    TipsManager.Instance:ShowText({gameObject = self.growIcon.gameObject, itemData = self.growthtips})
end

function PetChildSkillView:ClickFeed()
    local data = PetManager.Instance.model.currChild
    if data.status == ChildrenEumn.Status.Follow then
        if BaseUtils.get_unique_roleid(data.follow_id, data.f_zone_id, data.f_platform) == BaseUtils.get_self_id() then
            -- PetManager.Instance.model:OpenChildLearnSkill()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
    end

    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_child_feed,{PetManager.Instance.model.currChild,1})
end