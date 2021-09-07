-- @author 黄耀聪
-- @date 2016年5月23日

WingSkillItem = WingSkillItem or BaseClass()

function WingSkillItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.mgr = WingsManager.Instance

    self.openNextGradeString = TI18N("%s阶\n开放")
    self.notopenYetString = TI18N("尚未\n开放")
    self.gradeString = TI18N("八阶\n开放")
    self.awakenString = TI18N("觉醒\n技能")

    local t = self.transform
    self.descText = t:Find("Text"):GetComponent(Text)
    self.iconImage = t:Find("Icon"):GetComponent(Image)
    self.iconBtn = self.iconImage.gameObject:GetComponent(Button)
    self.iconLoader = SingleIconLoader.New(t:Find("Icon").gameObject)

    self.kuang = t:Find("Icon/Kuang")
    if self.kuang ~= nil then
        self.kuang.gameObject:SetActive(false)
    end

    self.addObj = t:Find("Add").gameObject
    self.addBtn = self.addObj:GetComponent(Button)
    self.tagImage = t:Find("Icon/Tag"):GetComponent(Image)

    local lockObj = t:Find("Icon/Lock")
    if lockObj then
        self.lockImage = lockObj:GetComponent(Image)
    end

    if t:Find("Name") ~= nil then
        self.nameText = t:Find("Name"):GetComponent(Text)
        self.nameText.text = ""
    end

    self.skillSlot = nil
    self.addClickState = true
    self.addBtn.onClick:AddListener(function() self:OnClick() end)
    self.iconBtn.onClick:AddListener(function() self:OnClick() end)

    local textButton = t:Find("Text"):GetComponent(Button)
    if textButton ~= nil then
        textButton.onClick:AddListener(function() self:OnClick() end)
    end

    self.clickBreakShowTips = false
end

function WingSkillItem:__delete()
    if self.iconImage ~= nil then
        self.iconImage.sprite = nil
    end
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    if self.skillSlot ~= nil then
        self.skillSlot:DeleteMe()
        self.skillSlot = nil
    end
end

function WingSkillItem:update_my_self(data, index)
    self.clickBreakShowTips = false
    local model = self.model
    self.index = index
    self.data = data
    if self.nameText ~= nil then
        self.nameText.text = ""
    end
    self.addObj:SetActive(false)
    self.tagImage.gameObject:SetActive(false)

    if self.lockImage then
        self.lockImage.gameObject:SetActive(false)
    end

    if data.id ~= nil then
        self.skilldata = DataSkill.data_wing_skill[data.id.."_"..data.lev]
        -- self.skillSlot:SetAll(Skilltype.wingskill, skilldata)
        self.iconImage.gameObject:SetActive(true)
        self.descText.gameObject:SetActive(false)
        -- self.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_skill, tostring(self.skilldata.icon))
        self.iconLoader:SetSprite(SingleIconType.SkillIcon, tostring(self.skilldata.icon))
        if self.nameText ~= nil then
            self.nameText.text = BaseUtils.string_cut_utf8(self.skilldata.name, 4, 3)
        end
        self.descText.text = ""
        self.tagImage.gameObject:SetActive(self.skilldata.cost_anger > 0)

        if data.is_lock and data.is_lock == 1 then
            if self.lockImage then
                self.lockImage.gameObject:SetActive(true)
            end
        end
        if self.kuang ~= nil then
            if DataWing.data_skill_energy[data.id] ~= nil then
                self.kuang.gameObject:SetActive(true)
            else
                self.kuang.gameObject:SetActive(false)
            end
        end
    elseif data.skill_id ~= nil then
        local lev = data.skill_lev
        if lev == 0 then
            lev = 1
        end
        self.skilldata = DataSkill.data_wing_skill[data.skill_id.."_"..lev]
        self.iconImage.gameObject:SetActive(true)
        self.descText.gameObject:SetActive(false)
        -- self.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.wing_skill, tostring(self.skilldata.icon))
        self.iconLoader:SetSprite(SingleIconType.SkillIcon, tostring(self.skilldata.icon))

        if self.nameText ~= nil then
            self.nameText.text = BaseUtils.string_cut_utf8(self.skilldata.name, 4, 3)
        end
        self.descText.text = ""

        if self.kuang ~= nil then
                if DataWing.data_skill_energy[data.skill_id] ~= nil then
                    self.kuang.gameObject:SetActive(true)
                else
                    self.kuang.gameObject:SetActive(false)
                end
        end
        -- self.tagImage.gameObject:SetActive(self.skilldata.cost_anger > 0)
    else
        self.descText.gameObject:SetActive(true)
        local wingData = DataWing.data_base[WingsManager.Instance.wing_id] or {skill_count = 0}
        local skill_count = 0
        for _,v in pairs(DataWing.data_base) do
            if v.grade == WingsManager.Instance.grade then
                skill_count = v.skill_count
            end
        end
        if index <= skill_count then
            -- self.iconImage.gameObject:SetActive(true)
            -- self.iconImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage")
            self.addObj:SetActive(true)
            self.iconImage.gameObject:SetActive(false)
            self.descText.text = ""
        elseif WingsManager.Instance.grade < self.mgr.top_grade then
            self.iconImage.gameObject:SetActive(false)
            if index == 1 then
                self.descText.text = self.gradeString
            elseif index == skill_count + 1 and index ~= 4 then
                local minGrade = 1000
                for _,v in pairs(DataWing.data_base) do
                    if v.skill_count == index then
                        if minGrade >= v.grade then minGrade = v.grade end
                    end
                end
                self.descText.text = string.format(self.openNextGradeString, tostring(minGrade))
                -- self.descText.text = self.openNextGradeString
            elseif WingsManager.Instance.grade >= self.mgr.awaken_grade then
                self.iconImage.gameObject:SetActive(false)
                self.descText.text = self.awakenString
            else
                self.descText.text = self.notopenYetString
            end
        else
            self.iconImage.gameObject:SetActive(false)
            self.descText.text = self.notopenYetString
        end

        if self.kuang ~= nil then
                self.kuang.gameObject:SetActive(false)
        end

        if self.skillSlot ~= nil then
            self.skillSlot.gameObject:SetActive(false)
        end
    end

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

function WingSkillItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function WingSkillItem:OnClick()
    -- BaseUtils.dump(self.data, "wingData")
    if self.data ~= nil and (self.data.id ~= nil or self.data.skill_id ~= nil) then
        if self.data.id ~= nil then
            TipsManager.Instance:ShowSkill({gameObject = self.iconImage.gameObject, skillData = self.skilldata, type = Skilltype.wingskill})
        else
            if self.data.skill_id ~= nil then
                if self.clickBreakShowTips then
                    TipsManager.Instance:ShowSkill({gameObject = self.iconImage.gameObject, skillData = self.skilldata, type = Skilltype.wingskill, extra = { isAwakenSkill = true }})
                else
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.wingawakenwindow)
                end
            elseif self.mgr.grade == self.mgr.awaken_grade then
                NoticeManager.Instance:FloatTipsByString(TI18N("翅膀达到<color='#ffff00'>7阶</color>后开放<color='#ffff00'>觉醒技能</color>，觉醒技能为独立技能，无需重置翅膀技能"))
            end
        end
    else
        local wingData = DataWing.data_base[WingsManager.Instance.wing_id] or {skill_count = 0}
        local skill_count = 0
        for _,v in pairs(DataWing.data_base) do
            if v.grade == WingsManager.Instance.grade then
                skill_count = v.skill_count
            end
        end
        if skill_count >= self.index  then
            if self.addClickState then
                self.model:OpenWingSkillPanel()
            end
        end
    end
end

function WingSkillItem:SetAddClick(state)
    self.addClickState = state
end

