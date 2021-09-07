WingInfoWindow = WingInfoWindow or BaseClass(BaseWindow)

function WingInfoWindow:__init()
    self.Mgr = WingsManager.Instance
    self.name = "WingInfoWindow"
    self.resList = {
        {file = AssetConfig.wing_info_window, type = AssetType.Main}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file = AssetConfig.wing_quality_icon, type = AssetType.Dep}
        ,{file = AssetConfig.wing_textures, type = AssetType.Dep}
        ,{file = AssetConfig.wingsbookbg, type = AssetType.Dep}
    }
    self.numberToChinese = {TI18N("一"), TI18N("二"), TI18N("三"), TI18N("四"), TI18N("五"),TI18N("六"),TI18N("七")}
    self.starExpainString = {
        TI18N("1.提升翅膀等级可获得<color='#ffff00'>更高属性</color>、<color='#ffff00'>翅膀技能</color>、<color='#ffff00'>全新外观</color>"),
        TI18N("2.八阶及以上翅膀可<color='#ffff00'>学习技能</color>，技能个数与翅膀等阶有关"),
        TI18N("3.进阶翅膀后，已经获得的翅膀特技将<color='#ffff00'>继续保留</color>，不会被重置"),
    }
    self.explainString = {
        TI18N("1.当翅膀达到<color=#00FF00>八阶</color>后，可获得翅膀技能"),
        TI18N("2.可通过重置翅膀技能获得<color=#00FF00>1个</color>或<color=#00FF00>多个</color>新的翅膀技能"),
        TI18N("3.不同等阶的翅膀最多能够获得的技能个数不同"),
        TI18N("4.翅膀技能按翅膀等阶开放，部分技能须<color=#00FF00>高阶</color>翅膀方可获得"),
        TI18N("5.进阶翅膀后，已经获得的翅膀特技将<color='#ffff00'>继续保留</color>，不会被重置"),
    }
    self.x = 125
    self.y3 = -78.6
    self.y4 = -114.4

    self.wingsIdByGrade = {}
    for k,v in pairs(DataWing.data_base) do
        if self.wingsIdByGrade[v.grade] == nil then
            self.wingsIdByGrade[v.grade] = {}
        end
        table.insert(self.wingsIdByGrade[v.grade], v.wing_id)
    end
    for _,v in pairs(self.wingsIdByGrade) do
        table.sort(v)
    end
    -- openArgs
end

function WingInfoWindow:__delete()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
    end
end

function WingInfoWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.wing_info_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.data = self.openArgs
    self.data.wingsIdByGrade = self.wingsIdByGrade
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self.Mgr:CloseWingInfoWindow()
    end)

    self.preview = self.transform:Find("Main/Preview")
    self:LoadPreView()

    self.qualityIcon = self.transform:Find("Main/Icon"):GetComponent(Image)
    self.qualityIcon.gameObject:SetActive(false)
    -- self.qualityText = self.qualityIcon.transform:Find("Text"):GetComponent(Text)
    -- self.qualityText.transform.anchoredPosition = Vector2(56, 0)
    self.qualityIcon.enabled = false
    self.transform:Find("Main/Show"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")
    self.nameTxt = self.transform:Find("Main/Show/Info/Title/Name"):GetComponent(Text)
    self.levTxt = self.transform:Find("Main/Show/Info/Title/Lev"):GetComponent(Text)
    self.descTxt = self.transform:Find("Main/WingDesc"):GetComponent(Text)
    self.ownerTxt = self.transform:Find("Main/ming"):GetComponent(Text)
    self.Property = self.transform:Find("Main/Property")

    self.Topbtn = self.transform:Find("Main/TopButton"):GetComponent(Button)
    self.Midbtn = self.transform:Find("Main/MidButton"):GetComponent(Button)
    self.slot = {
        [1] = self.transform:Find("Main/SkillSlot/1"),
        [2] = self.transform:Find("Main/SkillSlot/2"),
        [3] = self.transform:Find("Main/SkillSlot/3"),
        [4] = self.transform:Find("Main/SkillSlot/4"),
    }

    self:InitInfo()

    local g = GameObject.Instantiate(self.transform:Find("Main/Wingskilltitle").gameObject)
    g.transform:SetParent(self.transform:Find("Main"))
    g.transform.localScale = Vector3.one
    g.transform.anchoredPosition = Vector2(131, 144)
    g.transform:SetAsFirstSibling()
    g.transform:Find("Text"):GetComponent(Text).text = TI18N("翅膀属性")
end

function WingInfoWindow:LoadPreView()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "wing"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 300
        ,offsetY = -0.1
        , noDrag = true
    }
    local modelData = {type = PreViewType.Wings, looks = {{looks_type = SceneConstData.looktype_wing, looks_val = self.data.wing_id}}}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData, "ModelPreview")
    else
        self.previewComp:Reload(modelData, callback)
    end
end

function WingInfoWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview.gameObject:SetActive(true)
end

function WingInfoWindow:InitInfo()
    local baseData = DataWing.data_base[self.data.wing_id]
    local key = BaseUtils.Key(self.data.classes, self.data.grade, self.data.star)
    local attrData = DataWing.data_attribute[key]
    self.ownerTxt.text = self.data.owner
    -- self.qualityIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_quality_icon, "WingsIcon"..self.data.growth)
    -- self.qualityText.text = string.format(TI18N("等级:<color='#00ff00'>%s级</color>"), self.data.star)
    -- self.qualityText.text = ""
    self.levTxt.text = string.format(TI18N("%s阶"), BaseUtils.NumToChn(self.data.grade))
    self.nameTxt.text = baseData.name
    self.descTxt.text = TI18N("用你给我的翅膀飞，我懂这不是伤悲，再高也不会累，我们都说好了")
    if #attrData.attr > 3 then
        self.Property:Find("3").anchoredPosition = Vector2(self.x,self.y4)
    else
        self.Property:Find("3").anchoredPosition = Vector2(self.x,self.y3)
    end
    for i,v in ipairs(attrData.attr) do
        local item = self.Property:Find(v.attr_name)
        item:Find("Value"):GetComponent(Text).text = tostring(v.val)
        item.gameObject:SetActive(true)
    end

    -- for i=1,4 do
    --     local skData = self.data.skill_data[i]
    --     self.slot[i].gameObject:SetActive(skData ~= nil)
    --     if skData ~= nil then
    --         self:SetSkillSlot(skData,self.slot[i]:Find("Slot").gameObject)
    --     end
    -- end
    self.skillContainer = self.transform:Find("Main/Skill")
    self.skillItemList = {}
    for i=1,4 do
        local tab = self.data.skill_data[i]
        if tab == nil then
            tab = {}
        end
        self.skillItemList[i] = WingSkillItem.New(self.data, self.skillContainer:Find("SkillItem"..i).gameObject)
        self.skillItemList[i].assetWrapper = self.assetWrapper
        self.skillItemList[i]:update_my_self(tab, i)
    end

    if #self.data.break_skills > 0 then
    -- if #WingsManager.Instance.break_skills > 0 then
        local break_skill_data = self.data.break_skills[1]
        if break_skill_data.skill_lev > 0 then
            self.skillItemList[4].assetWrapper = self.assetWrapper
            self.skillItemList[4]:update_my_self(break_skill_data, 4)
            self.skillItemList[4].clickBreakShowTips = true
        end
    end

    if #self.data.skill_data < 1 then
        self:SetNoSkill()
    end

    self.Topbtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.Topbtn.gameObject, itemData = self.starExpainString}) end)
    self.Midbtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.Midbtn.gameObject, itemData = self.explainString}) end)
end

function WingInfoWindow:SetSkillSlot(data, gameObject)
    local nameText = gameObject.transform:Find("Name"):GetComponent(Text)
    -- local descText = gameObject.transform:Find("Text"):GetComponent(Text)
    local iconImage = gameObject.transform:Find("Icon"):GetComponent(Image)
    local iconBtn = iconImage.gameObject:GetComponent(Button)
    local addObj = gameObject.transform:Find("Add").gameObject
    addObj:SetActive(false)
    local tagImage = gameObject.transform:Find("Icon/Tag"):GetComponent(Image)
    tagImage.gameObject:SetActive(false)
    local skilldata = DataSkill.data_wing_skill[data.id.."_"..data.lev]
    if data.id ~= nil then
        -- self.skillSlot:SetAll(Skilltype.wingskill, skilldata)
        iconImage.gameObject:SetActive(true)
        -- descText.gameObject:SetActive(false)
        iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_skill, tostring(skilldata.icon))

        if nameText ~= nil then
            nameText.text = BaseUtils.string_cut(skilldata.name, 12, 9)
        end
        -- descText.text = ""
        tagImage.gameObject:SetActive(skilldata.cost_anger > 0)
    else
        addObj:SetActive(true)
        iconImage.gameObject:SetActive(false)
        -- descText.text = ""
    end
    iconBtn.onClick:AddListener(function() TipsManager.Instance:ShowSkill({gameObject = iconImage.gameObject, skillData = skilldata, type = Skilltype.wingskill}) end)

    -- 翅膀技能开放后去掉这部分代码
    -- self.descText.text = self.notopenYetString
    -- self.iconImage.gameObject:SetActive(false)
    -- if self.skillSlot ~= nil then
    --     GameObject.DestroyImmediate(self.skillSlot.gameObject)
    --     self.skillSlot:DeleteMe()
    --     self.skillSlot = nil
    -- end
    -- self.btn.enabled = false
    -- self.iconBtn.enabled = false
end

function WingInfoWindow:SetNoSkill()
    for i=1,4 do
        self.slot[i].gameObject:SetActive(true)
        local gameObject = self.slot[i]:Find("Slot").gameObject
        gameObject:SetActive(true)
        local nameText = gameObject.transform:Find("Name"):GetComponent(Text)
        -- local descText = gameObject.transform:Find("Text"):GetComponent(Text)
        local iconImage = gameObject.transform:Find("Icon"):GetComponent(Image)
        local iconBtn = iconImage.gameObject:GetComponent(Button)
        local addObj = gameObject.transform:Find("Add").gameObject
        addObj:SetActive(true)
        local tagImage = gameObject.transform:Find("Icon/Tag"):GetComponent(Image)
        tagImage.gameObject:SetActive(false)
        iconImage.gameObject:SetActive(false)
        nameText.gameObject:SetActive(false)
        -- if nameText ~= nil then
        --     if self.data.grade < 4 then
        --         nameText.text = TI18N("四阶开启")
        --     else
        --         nameText.text = TI18N("尚未获得")
        --     end
        -- end
        tagImage.gameObject:SetActive(false)
        iconBtn.onClick:RemoveAllListeners()

    end
end