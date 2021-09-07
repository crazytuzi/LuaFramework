-- @author 黄耀聪
-- @date 2017年5月16日

WingsSkillInfo = WingsSkillInfo or BaseClass(BasePanel)

function WingsSkillInfo:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.name = "WingsSkillInfo"
    self.assetWrapper = assetWrapper

    self.propertyList = {}
    self.itemList = {}

    self.isInited = false
    self.optionOpened = false

    self.updateListener = function() self:CheckRed() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WingsSkillInfo:__delete()
    self.OnHideEvent:Fire()
    self.model:CloseWingSkillPanel()
    if self.energyLoader ~= nil then
        self.energyLoader:DeleteMe()
        self.energyLoader = nil
    end
    self.transform:Find("Energy/Bg"):GetComponent(Image).sprite = nil
    if self.energySlot ~= nil then
        self.energySlot:DeleteMe()
        self.energySlot = nil
    end
    if self.energyEffect ~= nil then
        self.energyEffect:DeleteMe()
        self.energyEffect = nil
    end
    self.gameObject = nil
    self.model = nil
    self.assetWrapper = nil
end

function WingsSkillInfo:InitPanel()
    local t = self.transform

    local property = t:Find("Property/Container")
    for i=1,4 do
        local tab = {}
        tab.transform = property:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.nameText = tab.transform:Find("AttrName"):GetComponent(Text)
        tab.valueText = tab.transform:Find("Value"):GetComponent(Text)
        self.propertyList[i] = tab
    end
    self.propertyContainer = property
    self.property = t:Find("Property")

    local skill = t:Find("Skill")
    for i=1,4 do
        self.itemList[i] = WingSkillItem.New(self.model, skill:Find(string.format("SkillItem%s", i)).gameObject)
        self.itemList[i].assetWrapper = self.assetWrapper
    end

    self.resetBtn = t:Find("ResetSkill"):GetComponent(Button)
    self.resetBtn.transform:Find("Text"):GetComponent(Text).text = TI18N("重置技能")
    self.resetBtnRed = t:Find("ResetSkill/NotifyPoint").gameObject
    self.optionBtn = t:Find("OptionSkill"):GetComponent(Button)
    self.optionText = t:Find("OptionSkill/Text"):GetComponent(Text)
    self.optionArrow = t:Find("OptionSkill/Arrow")

    self.option = t:Find("Options")
    self.optionButtonList = {
        t:Find("Options/OpenButton1"):GetComponent(Button),
        t:Find("Options/OpenButton2"):GetComponent(Button),
        t:Find("Options/OpenButton3"):GetComponent(Button),
    }

    local energy = t:Find("Energy")
    energy:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.playkillbgcycle, "PlayKillBgCycle")
    self.energyLoader = SingleIconLoader.New(energy:Find("Bg/Icon").gameObject)
    self.energyText = energy:Find("Bg/Text"):GetComponent(Text)
    self.energySlot = ItemSlot.New()
    NumberpadPanel.AddUIChild(energy:Find("Item"), self.energySlot.gameObject)
    self.energyNameText = energy:Find("Item/Name"):GetComponent(Text)
    self.energyNoticeBtn = energy:Find("Notice"):GetComponent(Button)
    self.energyButton = energy:Find("Button"):GetComponent(Button)
    self.energy = energy

    for i,btn in ipairs(self.optionButtonList) do
        local j = i
        btn.onClick:AddListener(function() self:switch_option(j) end)
    end

    self.option.gameObject:SetActive(false)
    self.optionArrow.localScale = Vector3.one

    self.optionBtn.onClick:AddListener(function() self:ShowOptions() end)
    self.resetBtn.onClick:AddListener(function() self:OnUpgradeSkill() end)
    self.energyButton.onClick:AddListener(function() self:OnEnergy() end)
    self.energyNoticeBtn.onClick:AddListener(function() self:OnEnergyNotice() end)

    self.energy.gameObject:SetActive(false)
    self.isInited = true
    energy:Find("Title/Text"):GetComponent(Text).text = TI18N("翅膀特技能量")
end

function WingsSkillInfo:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WingsSkillInfo:OnOpen()
    if not self.isInited then
        self:InitPanel()
    end
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_wings_change, self.updateListener)

    self:ReloadShow()
    self:ReloadSkill()
    self:CheckRed()
end
function WingsSkillInfo:OnHide()
    self:RemoveListeners()
end

function WingsSkillInfo:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_wings_change, self.updateListener)
end

function WingsSkillInfo:ShowOptions()
    if self.optionOpened == true then
        self.option.gameObject:SetActive(false)
        self.optionArrow.localScale = Vector3.one
    else
        self.option.gameObject:SetActive(true)
        self.optionArrow.localScale = -Vector3.one
    end

    self.optionOpened = not self.optionOpened
end

function WingsSkillInfo:ReloadAttr()
    local attr = DataWing.data_attribute[string.format("%s_%s_%s", RoleManager.Instance.RoleData.classes, WingsManager.Instance.grade, WingsManager.Instance.star)].attr
    for i,v in ipairs(self.propertyList) do
        if attr[i] == nil then
            v.gameObject:SetActive(false)
        else
            v.gameObject:SetActive(true)
            v.nameText.text = KvData.GetAttrName(attr[i].attr_name)
            v.valueText.text = KvData.GetAttrVal(attr[i].attr_name, attr[i].val)
        end
    end
    self.propertyContainer.sizeDelta = Vector2(216, 28 * #attr)
    self.property.gameObject:SetActive(true)
end

function WingsSkillInfo:ReloadSkill()
    local skills = WingsManager.Instance:GetCurrSkillList()

    for i,v in ipairs(self.itemList) do
        v:update_my_self(skills[i] or {}, i)
    end

    if #WingsManager.Instance.break_skills > 0 then
        self.itemList[4]:update_my_self(WingsManager.Instance.break_skills[1], 4)
    end

    self:update_cur_option(WingsManager.Instance.valid_plan)
end

--切换方案
function WingsSkillInfo:switch_option(_index)
    -- 检查限制
    if WingsManager.Instance.grade == 5 and _index == 3 then
        NoticeManager.Instance:FloatTipsByString(TI18N("翅膀升级到<color='#ffff00'>6阶</color>开启"))
        return
    end

    if _index == WingsManager.Instance.valid_plan then
        NoticeManager.Instance:FloatTipsByString(TI18N("已经使用该方案"))
        return
    end

    WingsManager.Instance.target_option = _index

    self.model:OpenOptionConfirmPanel()

    self:ShowOptions()
end

--初始化当前方案
function WingsSkillInfo:update_cur_option(_index)
    local has_active = WingsManager.Instance.valid_plan == _index
    local CurButton_txt_str = ""
    if _index == 1 then
        CurButton_txt_str = TI18N("方案一")
    elseif _index == 2 then
        CurButton_txt_str = TI18N("方案二")
    elseif _index == 3 then
        CurButton_txt_str = TI18N("方案三")
    end

    self.optionText.text = CurButton_txt_str


    local skill_data = nil
    for i=1,#WingsManager.Instance.plan_data do
        if WingsManager.Instance.plan_data[i].index == _index then
            skill_data = WingsManager.Instance.plan_data[i].skills
            break
        end
    end

    for i=1,4 do
        local tab = skill_data[i]
        if tab == nil then
            tab = {}
        end
        self.itemList[i].assetWrapper = self.assetWrapper
        self.itemList[i]:update_my_self(tab, i)
    end

    if #WingsManager.Instance.break_skills > 0 then
        local break_skill_data = WingsManager.Instance.break_skills[1]
        self.itemList[4].assetWrapper = self.assetWrapper
        self.itemList[4]:update_my_self(WingsManager.Instance.break_skills[1], 4)

        -- if break_skill_data.skill_lev == 0 then
        --     self.breakSkillLabel:SetActive(true)
        -- else
        --     self.breakSkillLabel:SetActive(false)
        --     local data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", WingsManager.Instance.grade, break_skill_data.skill_id, break_skill_data.skill_lev)]
        --     local own = BackpackManager.Instance:GetItemCount(data_get_action_break.uplev_loss[1][1])
        --     local need = data_get_action_break.uplev_loss[1][2]
        -- end
    else
        -- self.breakSkillLabel:SetActive(false)
    end

    -- if #skill_data < DataWing.data_base[self.model.wing_id].skill_count then
    --     self.upgradeSkillText.text = string.format(ColorHelper.DefaultButton3Str, self.upgradeText[1])
    --     self.upgradeSkillImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    -- else
    --     if self.model.grade < 4 then
    --         self.upgradeSkillText.text = string.format(ColorHelper.DefaultButton3Str, self.upgradeText[3])
    --     else
    --         self.upgradeSkillText.text = string.format(ColorHelper.DefaultButton3Str, self.upgradeText[2])
    --     end
    --     self.upgradeSkillImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    -- end


    --更新右边内容显示
    -- self.cur_select_option = _index
end

function WingsSkillInfo:OnUpgradeSkill()
    local model = self.model
    local skill_count = 0
    for _,v in pairs(DataWing.data_base) do
        if v.grade == WingsManager.Instance.grade then
            skill_count = v.skill_count
        end
    end
    if skill_count > 0 then
        model:OpenWingSkillPanel()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("技能未开启"))
    end

    if WingsManager.Instance:CheckSkillRed() then
        WingsManager.Instance.isCheckSkillReset = true
    end

    self:CheckRed()
end

function WingsSkillInfo:CheckRed()
    self.resetBtnRed:SetActive(WingsManager.Instance:CheckSkillRed() and not WingsManager.Instance.isCheckSkillReset)
end

function WingsSkillInfo:ReloadEnergy()
    local base_id = 21135
    if WingsManager.Instance.wing_power == 0 then
        self.energyText.text = string.format(TI18N("能量: %s"), "<color='#ff0000'>0</color>/100")
    else
        self.energyText.text = string.format(TI18N("能量: %s"), string.format("<color='#00ff00'>%s</color>/100", WingsManager.Instance.wing_power))
    end

    self.energySlot:SetAll(DataItem.data_get[base_id], {inbag = false, nobutton = true})

    local count = BackpackManager.Instance:GetItemCount(base_id)
    self.energySlot:SetNum(BackpackManager.Instance:GetItemCount(base_id), 1, true)
    if count == 0 then
        self.energySlot.numTxt.text = "<color='#ff0000'>0</color>/1"
    end
    self.energyNameText.text = DataItem.data_get[base_id].name
    self.energy.gameObject:SetActive(true)

    if self.energyEffect ~= nil then
        self.energyEffect:SetActive(true)
    else
        self.energyEffect = BaseUtils.ShowEffect(20431, self.transform:Find("Energy/Bg/Icon"), Vector3.one, Vector3(0, 0, -200))
    end
end

function WingsSkillInfo:OnEnergy()
    local point = WingsManager.Instance.wing_power or 0
    if point < 100 then
        local base_id = 21135
        local itemList = BackpackManager.Instance:GetItemByBaseid(base_id)
        if itemList[1] ~= nil then
            BackpackManager.Instance:Use(itemList[1].id, 1, base_id)
        else
            self.model:OpenEnergy()
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("能量已满，无需补充{face_1,2}"))
    end
end

function WingsSkillInfo:ReloadShow()
    self.energy.gameObject:SetActive(false)
    self.property.gameObject:SetActive(false)
    if WingsManager.Instance:IsNeedEnergy() then
        self:ReloadEnergy()
    else
        self:ReloadAttr()
    end
end

function WingsSkillInfo:OnEnergyNotice()
    TipsManager.Instance:ShowText({gameObject = self.energyNoticeBtn.gameObject, itemData = {
            TI18N("1.战斗中每次使用以下高阶翅膀特技，将消耗<color='#ffff00'>翅膀特技能量</color>"),
            TI18N("2.PVP战斗每次消耗<color='#ffff00'>5点</color>，PVE战斗每次消耗<color='#ffff00'>1点</color>"),
            TI18N("3.战斗中能量不足时，将释放相应的低阶特技"),
            "",
            TI18N("消耗翅膀能量的特技包括："),
            TI18N("<color='#F6A104'>真·无双之刃</color>、<color='#F6A104'>真·烽火连天</color>"),
            TI18N("<color='#F6A104'>真·破碎虚空</color>、<color='#F6A104'>真·神圣净化</color>"),
            TI18N("<color='#F6A104'>真·圣光护佑</color>、<color='#F6A104'>真·圣光辉耀</color>")
        }})
end
