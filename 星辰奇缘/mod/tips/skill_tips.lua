-- ------------------------------
-- 技能tips
-- ljh
-- ------------------------------
SkillTips = SkillTips or BaseClass(BaseTips)

function SkillTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_skill, type = AssetType.Main}
    }
    self.mgr = TipsManager.Instance
    self.width = 315
    self.height = 20
    self.buttons = {}
    self.DefaultSize = Vector2(315, 0)

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)
end

function SkillTips:__delete()
    if self.skillSlot ~= nil then
        self.skillSlot:DeleteMe()
    end
    self.skillSlot = nil

    self.mgr = nil
    self.buttons = {}
    self.height = 20
    self:RemoveTime()
end

function SkillTips:RemoveTime()
    self.mgr.updateCall = nil
end

function SkillTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_skill))
    self.gameObject.name = "SkillTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self.model:Closetips() end)

    self.rect = self.gameObject:GetComponent(RectTransform)

    local head = self.transform:Find("HeadArea")
    self.skillSlot = SkillSlot.New(head:Find("SkillSlotContainer/SkillSlot").gameObject)
    self.skillSlot:SetNotips()
    self.skillImage = head:Find("SkillSlotContainer/RoleSkillImage"):GetComponent(Image)
    self.nameTxt = head:Find("Name"):GetComponent(Text)
    self.levTxt = head:Find("Level"):GetComponent(Text)
    self.levLabel = head:Find("I18N_Text").gameObject
    self.levLabelTxt = head:Find("I18N_Text"):GetComponent(Text)

    local mid = self.transform:Find("MidArea")
    self.costObject = mid:Find("Cost").gameObject
    self.costTxt = self.costObject.transform:Find("Text"):GetComponent(Text)
    self.costRect = self.costTxt.gameObject:GetComponent(RectTransform)
    self.coolDownObject = mid:Find("CoolDown").gameObject
    self.coolDownTxt = self.coolDownObject.transform:Find("Text"):GetComponent(Text)
    self.coolDownRect = self.coolDownTxt.gameObject:GetComponent(RectTransform)
    self.Line1 = mid:Find("Line1").gameObject
    self.Line1Rect = self.Line1:GetComponent(RectTransform)
    self.Line2 = mid:Find("Line2").gameObject
    self.Line2Rect = self.Line2:GetComponent(RectTransform)
    self.descTxt = mid:Find("Desc"):GetComponent(Text)
    self.descRect = self.descTxt.gameObject:GetComponent(RectTransform)
    self.desc2Txt = mid:Find("Desc2"):GetComponent(Text)
    self.desc2Rect = self.desc2Txt.gameObject:GetComponent(RectTransform)

    self.midRect = mid.gameObject:GetComponent(RectTransform)

    local bottom = self.transform:Find("ButtonList")
    self.bottomRect = bottom.gameObject:GetComponent(RectTransform)
    self.line3 = bottom:Find("Line3").gameObject
    local lockButton = bottom:Find("LockButton").gameObject
    local unLockButton = bottom:Find("UnLockButton").gameObject

    lockButton:GetComponent(Button).onClick:AddListener(function() self.model:PetSkilllLock(self.itemData, self.extra) end)
    unLockButton:GetComponent(Button).onClick:AddListener(function() self.model:PetSkilllUnLock(self.itemData, self.extra) end)

    self.buttons = {
        [TipsEumn.ButtonType.PetSkillLock] = lockButton
        ,[TipsEumn.ButtonType.PetSkillUnLock] = unLockButton
    }
end

function SkillTips:UnRealUpdate()
    local v2 = nil
    if Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Began then
        local v2 = Input.GetTouch(0).position
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end

    if Input.GetMouseButtonDown(0) then
        local v2 = Input.mousePosition
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end
end

function SkillTips:Default()
    self.height = 20
    self.levTxt.text = ""
    self.nameTxt.text = ""
    self.costTxt.text = ""
    self.coolDownTxt.text = ""
    self.descTxt.text = ""

    for _,button in pairs(self.buttons) do
        button.gameObject:SetActive(false)
    end

    self.rect.sizeDelta = self.DefaultSize
end

-- ------------------------------------
-- 外部调用更新数据
-- 参数说明:
-- info = 道具数据
-- extra = 扩展参数
-- ------------------------------------
function SkillTips:UpdateInfo(type, info, extra)
    self:Default()
    self.itemData = info
    self.extra = extra
    self.nameTxt.text = info.name
    self.levTxt.text = info.lev
    -- self.typeTxt.text = "类型:宠物装备"
    self.levLabelTxt.text = TI18N("等级：")
    self.levTxt.transform.anchoredPosition = Vector2(80,-8)
    self.levTxt.gameObject:SetActive(true)
    self.levLabel:SetActive(true)
    --加上上部分的高度
    self.height = self.height + 90
    self.levTxt:GetComponent(RectTransform).anchoredPosition = Vector2(80, -8)
    if type == Skilltype.roleskill then
        local skill_info = DataSkill.data_skill_role[string.format("%s_%s", info.id, info.lev)]
        self.nameTxt.text = skill_info.name
        self.levTxt.text = string.format("Lv.%s", info.lev)
        self.skillSlot:SetAll(type, info, extra)
        self.skillSlot.gameObject:SetActive(true)
        self.skillImage.gameObject:SetActive(false)

        local height = self.height
        self.Line1.gameObject:SetActive(false)
        self.costObject:SetActive(false)
        self.coolDownObject:SetActive(false)

        self.Line2Rect.anchoredPosition = Vector2(150, height - self.height)
        self.Line2.gameObject:SetActive(true)
        self.height = self.height + 14
        self.descTxt.text = skill_info.desc
        local preferredHeight = self.descTxt.preferredHeight
        self.descRect.sizeDelta = Vector2(250, preferredHeight)
        self.descRect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + preferredHeight
        self.desc2Txt.gameObject:SetActive(false)
        local key = CombatUtil.Key(info.id, info.lev)
        local skillData = DataCombatSkill.data_combat_skill[key]
        if skillData ~= nil and skillData.cooldown ~= nil and skillData.cooldown > 0 then
            self.coolDownObject:SetActive(true)
            self.coolDownTxt.text = string.format(TI18N("%s 回合"), skillData.cooldown)
            self.coolDownObject.transform.anchoredPosition = Vector2(10, height - self.height)
            self.height = self.height + 25
        end
    elseif type == Skilltype.roletalent then
        self.nameTxt.text = info.name
        self.levTxt.text = string.format("Lv.%s", info.lev)
        self.skillSlot:SetAll(type, info)
        self.skillSlot.gameObject:SetActive(true)
        self.skillImage.gameObject:SetActive(false)

        local height = self.height
        self.Line1.gameObject:SetActive(false)
        self.costObject:SetActive(false)
        self.coolDownObject:SetActive(false)

        self.Line2Rect.anchoredPosition = Vector2(150, height - self.height)
        self.Line2.gameObject:SetActive(true)
        self.height = self.height + 14
        self.descTxt.text = info.desc
        local preferredHeight1 = self.descTxt.preferredHeight
        self.descRect.sizeDelta = Vector2(250, preferredHeight1)
        self.descRect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + preferredHeight1 + 10

        if info.open then
            self.desc2Txt.text = TI18N("已开启")
        else
            self.desc2Txt.text = info.desc2
        end
        self.desc2Txt.gameObject:SetActive(true)
        local preferredHeight2 = self.desc2Txt.preferredHeight
        self.desc2Rect.sizeDelta = Vector2(250, preferredHeight2)
        self.desc2Rect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + preferredHeight2 + 10
    elseif type == Skilltype.petskill then
        self.skillSlot:SetAll(type, info)
        self.skillSlot.gameObject:SetActive(true)
        self.skillImage.gameObject:SetActive(false)
        self.levLabel:SetActive(false)
        self.levTxt.gameObject:SetActive(false)

        local height = self.height
        self.Line1.gameObject:SetActive(false)
        self.costObject:SetActive(false)
        self.coolDownObject:SetActive(false)

        self.Line2Rect.anchoredPosition = Vector2(150, height - self.height)
        self.Line2.gameObject:SetActive(true)
        self.height = self.height + 14
        self.descTxt.text = info.desc
        local preferredHeight1 = self.descTxt.preferredHeight
        self.descRect.sizeDelta = Vector2(250, preferredHeight1)
        self.descRect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + self.descTxt.preferredHeight + 10

        if extra ~= nil and extra.source then
            self.desc2Txt.text = TI18N("<color='#00ff00'>该技能通过宠物装备的护符获得</color>")
            self.desc2Txt.gameObject:SetActive(true)
            local preferredHeight2 = self.desc2Txt.preferredHeight
            self.desc2Rect.sizeDelta = Vector2(250, preferredHeight2)
            self.desc2Rect.anchoredPosition = Vector2(155, height - self.height)
            self.height = self.height + preferredHeight2 + 10
        elseif extra ~= nil and extra.skillLock then
            self.desc2Txt.text = TI18N("<color='#00ff00'>锁定后在学习技能时不会被覆盖</color>")
            self.desc2Txt.gameObject:SetActive(true)
            local preferredHeight2 = self.desc2Txt.preferredHeight
            self.desc2Rect.sizeDelta = Vector2(250, preferredHeight2)
            self.desc2Rect.anchoredPosition = Vector2(155, height - self.height)
            self.height = self.height + preferredHeight2 + 10
        else
            self.desc2Txt.gameObject:SetActive(false)
        end
    elseif type == Skilltype.childskill then
        self.skillSlot:SetAll(type, info, extra)
        self.skillSlot.gameObject:SetActive(true)
        self.skillImage.gameObject:SetActive(false)
        self.levLabel:SetActive(false)
        self.levTxt.gameObject:SetActive(false)

        local height = self.height
        self.Line1.gameObject:SetActive(false)
        self.costObject:SetActive(false)
        self.coolDownObject:SetActive(false)

        self.Line2Rect.anchoredPosition = Vector2(150, height - self.height)
        self.Line2.gameObject:SetActive(true)
        self.height = self.height + 14
        self.descTxt.text = info.desc
        local preferredHeight1 = self.descTxt.preferredHeight
        self.descRect.sizeDelta = Vector2(250, preferredHeight1)
        self.descRect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + self.descTxt.preferredHeight + 10

        if extra ~= nil and extra.source then
            self.desc2Txt.text = TI18N("<color='#00ff00'>该技能通过宠物装备的护符获得</color>")
            self.desc2Txt.gameObject:SetActive(true)
            local preferredHeight2 = self.desc2Txt.preferredHeight
            self.desc2Rect.sizeDelta = Vector2(250, preferredHeight2)
            self.desc2Rect.anchoredPosition = Vector2(155, height - self.height)
            self.height = self.height + preferredHeight2 + 10
        elseif extra ~= nil and extra.skillLock then
            self.desc2Txt.text = TI18N("<color='#00ff00'>锁定后在学习技能时不会被覆盖</color>")
            self.desc2Txt.gameObject:SetActive(true)
            local preferredHeight2 = self.desc2Txt.preferredHeight
            self.desc2Rect.sizeDelta = Vector2(250, preferredHeight2)
            self.desc2Rect.anchoredPosition = Vector2(155, height - self.height)
            self.height = self.height + preferredHeight2 + 10
        else
            self.desc2Txt.gameObject:SetActive(false)
        end
    elseif type == Skilltype.shouhuskill then
        local skill_info = DataSkill.data_skill_guard[string.format("%s_1", info.id)]
        self.nameTxt.text = skill_info.name

        self.levLabelTxt.gameObject:SetActive(false)
        self.levTxt:GetComponent(RectTransform).anchoredPosition = Vector2(15, -8)

        if info.quality ~= nil then
            self.levTxt.text = string.format("<color='#6d889a'>%s%s%s</color>", TI18N("进阶"), ShouhuManager.Instance.model.wakeUpQualityName[info.quality], TI18N("色可习得"))
        elseif info.lev ~= nil then
            self.levTxt.text = string.format("<color='#6d889a'>Lv.%s%s</color>", info.lev, TI18N("可习得"))
        end

        self.skillSlot:SetAll(type, info)
        self.skillSlot.gameObject:SetActive(true)
        self.skillImage.gameObject:SetActive(false)

        local height = self.height
        self.Line1.gameObject:SetActive(false)
        self.costObject:SetActive(false)
        self.coolDownObject:SetActive(false)

        self.Line2Rect.anchoredPosition = Vector2(150, height - self.height)
        self.Line2.gameObject:SetActive(true)
        self.height = self.height + 14
        self.descTxt.text = skill_info.desc
        local preferredHeight = self.descTxt.preferredHeight
        self.descRect.sizeDelta = Vector2(250, preferredHeight)
        self.descRect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + preferredHeight + 10
        self.desc2Txt.gameObject:SetActive(false)
    elseif type == Skilltype.marryskill then
        local skill_info = DataSkill.data_marry_skill[string.format("%s_%s", info.id, info.lev)]
        self.nameTxt.text = skill_info.name
        self.levTxt.text = string.format("Lv.%s", info.lev)
        self.skillSlot:SetAll(type, info)
        self.skillSlot.gameObject:SetActive(true)
        self.skillImage.gameObject:SetActive(false)

        local height = self.height
        self.Line1.gameObject:SetActive(false)
        self.costObject:SetActive(false)
        self.coolDownObject:SetActive(false)

        self.Line2Rect.anchoredPosition = Vector2(150, height - self.height)
        self.Line2.gameObject:SetActive(true)
        self.height = self.height + 14
        self.descTxt.text = skill_info.desc2
        local preferredHeight = self.descTxt.preferredHeight
        self.descRect.sizeDelta = Vector2(250, preferredHeight)
        self.descRect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + preferredHeight + 10
        self.desc2Txt.gameObject:SetActive(false)
    elseif type == Skilltype.rideskill then
        self.skillSlot:SetAll(type, info)
        self.skillSlot.gameObject:SetActive(true)
        self.skillImage.gameObject:SetActive(false)
        self.levLabel:SetActive(false)
        self.levTxt.gameObject:SetActive(false)

        local height = self.height
        self.Line1.gameObject:SetActive(false)
        self.costObject:SetActive(false)
        self.coolDownObject:SetActive(false)

        self.Line2Rect.anchoredPosition = Vector2(150, height - self.height)
        self.Line2.gameObject:SetActive(true)
        self.height = self.height + 14
        self.descTxt.text = info.desc
        local preferredHeight1 = self.descTxt.preferredHeight
        self.descRect.sizeDelta = Vector2(250, preferredHeight1)
        self.descRect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + preferredHeight1 + 10

        if extra ~= nil and extra.source then
            self.desc2Txt.text = TI18N("<color='#00ff00'>该技能通过宠物装备的护符获得</color>")
            self.desc2Txt.gameObject:SetActive(true)
            local preferredHeight2 = self.desc2Txt.preferredHeight
            self.desc2Rect.sizeDelta = Vector2(250, preferredHeight2)
            self.desc2Rect.anchoredPosition = Vector2(155, height - self.height)
            self.height = self.height + preferredHeight2 + 10
        else
            self.desc2Txt.gameObject:SetActive(false)
        end
    elseif type == Skilltype.wingskill then
        local skill_info = DataSkill.data_wing_skill[string.format("%s_%s", info.id, info.lev)]
        self.nameTxt.text = skill_info.name
        self.levTxt.transform.anchoredPosition = Vector2(108,-8)
        self.levLabelTxt.text = TI18N("怒气消耗：")
        self.levTxt.text = "<color='#ffff00'>"..tostring(skill_info.cost_anger).."</color>"
        self.levLabelTxt.gameObject:SetActive(true)
        self.levTxt.gameObject:SetActive(true)
        self.skillSlot:SetAll(type, info)
        self.skillSlot.gameObject:SetActive(true)
        self.skillImage.gameObject:SetActive(false)

        if skill_info.cost_anger > 0 then
            self.descTxt.text = TI18N("技能类型：<color=#FFFF00>战斗特技</color>")
        else
            if self.extra == nil or not self.extra.isAwakenSkill then
                self.levTxt.gameObject:SetActive(false)
                self.levLabel:SetActive(false)
                self.descTxt.text = TI18N("技能类型：<color=#FFFF00>被动加成</color>")
            else
                self.levLabelTxt.gameObject:SetActive(false)
                self.levTxt.text = string.format("Lv.%s", info.lev)
                self.levTxt.transform.anchoredPosition = Vector2(16,-8)
                self.descTxt.text = TI18N("技能类型：<color=#FFFF00>被动加成</color>")
            end
        end

        local height = self.height
        self.Line1.gameObject:SetActive(false)
        self.costObject:SetActive(false)
        self.coolDownObject:SetActive(false)

        self.Line2Rect.anchoredPosition = Vector2(150, height - self.height)
        self.Line2.gameObject:SetActive(true)
        self.height = self.height + 14
        self.descTxt.text = skill_info.desc
        local preferredHeight = self.descTxt.preferredHeight
        self.descRect.sizeDelta = Vector2(250, preferredHeight)
        self.descRect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + preferredHeight + 10
        self.desc2Txt.gameObject:SetActive(false)
    elseif type == Skilltype.endlessskill then
        -- local skill_info = DataSkill.data_endless_challenge[info.id]
        self.nameTxt.text = info.name
        self.levTxt.gameObject:SetActive(false)
        self.levLabelTxt.gameObject:SetActive(false)
        self.skillSlot:SetAll(type, info)
        self.skillSlot.gameObject:SetActive(true)
        self.skillImage.gameObject:SetActive(false)

        local height = self.height
        self.Line1.gameObject:SetActive(false)
        self.costObject:SetActive(false)
        self.coolDownObject:SetActive(false)

        self.Line2Rect.anchoredPosition = Vector2(150, height - self.height)
        self.Line2.gameObject:SetActive(true)
        self.height = self.height + 14
        self.descTxt.text = info.desc
        local preferredHeight = self.descTxt.preferredHeight
        self.descRect.sizeDelta = Vector2(250, preferredHeight)
        self.descRect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + preferredHeight + 10
        self.desc2Txt.gameObject:SetActive(false)
        -- if extra ~= nil and extra.source then
        --     -- 孩子砸雪球技能显示来源
        --     self.levLabelTxt.gameObject:SetActive(true)
        --     self.levLabelTxt.text = string.format("<color='#c7f9ff'>%s</color>", tostring(extra.source))
        -- end
    elseif type == Skilltype.swornskill then
        local skill_info = DataSkill.data_skill_other[info.id]
        self.nameTxt.text = skill_info.name
        self.levTxt.text = TI18N("结拜技能")
        self.skillSlot:SetAll(type, info)
        self.skillSlot.gameObject:SetActive(true)
        self.skillImage.gameObject:SetActive(false)

        local height = self.height
        self.Line1.gameObject:SetActive(false)
        self.costObject:SetActive(false)
        self.coolDownObject:SetActive(false)

        self.Line2Rect.anchoredPosition = Vector2(150, height - self.height)
        self.Line2.gameObject:SetActive(true)
        self.height = self.height + 14
        self.descTxt.text = skill_info.desc
        local preferredHeight = self.descTxt.preferredHeight
        self.descRect.sizeDelta = Vector2(250, preferredHeight)
        self.descRect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + preferredHeight + 10
        self.desc2Txt.gameObject:SetActive(false)
    elseif type == Skilltype.talisman then
        local skill_info = DataSkill.data_talisman_skill[string.format("%s_1", info.id)]
        self.nameTxt.text = skill_info.name
        self.levTxt.gameObject:SetActive(false)
        self.levLabelTxt.gameObject:SetActive(false)
        self.skillSlot:SetAll(type, info)
        self.skillSlot.gameObject:SetActive(true)
        self.skillImage.gameObject:SetActive(false)

        local height = self.height
        self.Line1.gameObject:SetActive(false)
        self.costObject:SetActive(false)
        self.coolDownObject:SetActive(false)

        self.Line2Rect.anchoredPosition = Vector2(150, height - self.height)
        self.Line2.gameObject:SetActive(true)
        self.height = self.height + 14
        self.descTxt.text = skill_info.desc
        local preferredHeight1 = self.descTxt.preferredHeight
        self.descRect.sizeDelta = Vector2(250, preferredHeight1)
        self.descRect.anchoredPosition = Vector2(155, height - self.height)
        self.height = self.height + preferredHeight1 + 10
        self.desc2Txt.gameObject:SetActive(false)
    end
    -- 处理按钮
    self:ShowButton(info, extra)
    -- 加上底部间隔高度
    self.height = self.height + 10
    self.rect.sizeDelta = Vector2(self.width, self.height)

    self.mgr.updateCall = self.updateCall
end

-- 处理tips按钮
function SkillTips:ShowButton(info, extra)
    extra = extra or {}
    local options = info.tips_type

    local showList = {}

    if extra.white_list == nil then
       for i,v in ipairs(showList) do
            if self.buttons[v] ~= nil then
                self.buttons[v]:SetActive(true)
            end
        end
    else
        --不根据配置的额外处理部分
        showList = {}
        for i, data in ipairs(extra.white_list) do
            if data.show then
                table.insert(showList, data.id)
            end
            self.buttons[data.id]:SetActive(data.show)
        end
    end

    local count = 0
    local temp  = {}
    table.sort(showList, function(a,b) return a < b end)

    for _,id in ipairs(showList) do
        table.insert(temp, id)
    end
    showList = temp
    temp = nil

    if #showList == 1 then
        count = count + 1
        local rect = self.buttons[showList[1]]:GetComponent(RectTransform)
        rect.anchoredPosition = Vector2(60, 0)
        rect.sizeDelta = Vector2(110, 48)
    else
        for _,id in ipairs(showList) do
            count = count + 1
            local rect = self.buttons[showList[count]]:GetComponent(RectTransform)
            rect.anchoredPosition = Vector2(120*((count-1)%2), -58*(math.ceil(count/2)-1))
            rect.sizeDelta = Vector2(110, 48)
        end
    end

    if count == 0 then
        self.line3:SetActive(false)
    else
        self.line3:SetActive(true)
    end

    self.bottomRect.anchoredPosition = Vector2(0, -self.height-10)
    self.height = self.height + 58 * math.ceil(count / 2) + 5
end
