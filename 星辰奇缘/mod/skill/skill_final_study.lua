SkillFinalStudyPanel = SkillFinalStudyPanel or BaseClass(BasePanel)

function SkillFinalStudyPanel:__init(model,parent)
    self.model = model
    --self.windowId = WindowConfig.WinID.skilltalentwindow
    self.parent = parent
    self.name = "SkillFinalStudyPanel"
    self.resList = {
        {file = AssetConfig.skill_final_study, type = AssetType.Main}
        ,{file = AssetConfig.finalskill_textures, type = AssetType.Dep}
        ,{file = AssetConfig.final_skill_bg, type = AssetType.Dep}
        ,{file = AssetConfig.light_circle, type = AssetType.Dep}
        ,{file = AssetConfig.wingsbookbg, type = AssetType.Dep}
    }

    self.hasDone = false
    self.enough = false

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function SkillFinalStudyPanel:__delete()
    self.OnHideEvent:Fire()
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
    if self.skillSlot ~= nil then
        self.skillSlot:DeleteMe()
        self.skillSlot = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.effect2 ~= nil then
        self.effect2:DeleteMe()
        self.effect2 = nil
    end
    if self.effect3 ~= nil then
        self.effect3:DeleteMe()
        self.effect3 = nil
    end
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end


    self:AssetClearAll()
end

function SkillFinalStudyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skill_final_study))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    local t = self.transform
    t:GetComponent(RectTransform).anchoredPosition = Vector2(120, -7.5)
    t:Find("SkillBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.final_skill_bg,"finalskillbg")
    t:Find("Skillbottom"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg,"wingsbookbg")
    t:Find("LightCircle"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.light_circle,"lightcircle")

    t:Find("Type2"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.agendamain) end)
    t:Find("Type1"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.chief_challenge_window,{1}) end)

    self.skill = t:Find("Skill").gameObject

    self.skillSlot = SkillSlot.New()
    self.skillSlot.gameObject:AddComponent(TransitionButton).scaleRate = 1.1
    UIUtils.AddUIChild(self.skill, self.skillSlot.gameObject)

    local skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].id
    local data = DataSkill.data_skill_role[string.format("%s_1", skill)]
    self.skillSlot:SetAll(Skilltype.roleskill, data, { classes = RoleManager.Instance.RoleData.classes })

    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(t:Find("Item"), self.itemSlot.gameObject)
    self.cost = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].learn_cost[1]
    local itemBaseData = BackpackManager.Instance:GetItemBase(self.cost[1])
    t:Find("ItemName"):GetComponent(Text).text = itemBaseData.name
    self.itemData = ItemData.New()
    self.itemData:SetBase(itemBaseData)
    self.itemData.need = self.cost[2]

    self.upBtn = t:Find("Button"):GetComponent(CustomButton)
    self.upBtn.onUp:AddListener(function() self:OnUp() end)
    self.upBtn.onDown:AddListener(function() self:OnDown() end)
    self.upBtn.onClick:AddListener(function() self:OnClick() end)

    if self.effect == nil then
        self.effect = BaseUtils.ShowEffect(20438, t:Find("Skill"), Vector3(1,1,1), Vector3(0,0,-1000))
    end
    self.effect:SetActive(false)

    if self.effect2 == nil then
        self.effect2 = BaseUtils.ShowEffect(20437, t:Find("Skill"), Vector3(1,1,1), Vector3(0,0,-1000))
    end

end

function SkillFinalStudyPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SkillFinalStudyPanel:OnShow()
    self:AddListeners()
    self:SetItemNum()
    if self.timerId == nil then
        local temp = 0
        self.timerId = LuaTimer.Add(0, 22, function() self:Float(temp) temp = temp + 1  end)
    end
end

function SkillFinalStudyPanel:OnHide()
    self:RemoveListeners()
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function SkillFinalStudyPanel:AddListeners()

end

function SkillFinalStudyPanel:RemoveListeners()

end

function SkillFinalStudyPanel:OnClick()
    if not self.hasDone then
        NoticeManager.Instance:FloatTipsByString(TI18N("请<color='#ffff00'>长按</color>进行职业绝招领悟{face_1,22}"))
    end
end


function SkillFinalStudyPanel:OnDown()
    self.hasDone = false

    self.enough = BackpackManager.Instance:GetItemCount(self.cost[1]) > self.cost[2] - 1

    if not self.enough then
        self.hasDone = true
        NoticeManager.Instance:FloatTipsByString(TI18N("道具不足"))
        self.itemSlot:SureClick()
        return
    end
    if self.effect ~= nil then
        self.effect:SetActive(false)
        self.effect:SetActive(true)
    end
    SoundManager.Instance:Play(232)
    self:BeginTime()
end

function SkillFinalStudyPanel:OnUp()
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
    SoundManager.Instance:StopId(232)
    self:StopTime()
end

function SkillFinalStudyPanel:BeginTime()
    self:StopTime()
    self.holdTimeId = LuaTimer.Add(1800, function() self:Beng() end)
end

function SkillFinalStudyPanel:StopTime()
    if self.holdTimeId ~= nil then
        LuaTimer.Delete(self.holdTimeId)
        self.holdTimeId = nil
    end
end

function SkillFinalStudyPanel:Beng()
    self.hasDone = true
    self:StopTime()
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
    local skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].id

    if self.effect3 == nil then
        self.effect3 = BaseUtils.ShowEffect(20439, self.transform:Find("Skill"), Vector3(1,1,1), Vector3(0,0,-1000))
    end
    self.effect3:SetActive(false)
    self.effect3:SetActive(true)
    SoundManager.Instance:Play(217)

    LuaTimer.Add(1000, function()
        if RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
            NoticeManager.Instance:FloatTipsByString(TI18N("战斗中无法领悟"))
        else
            SkillManager.Instance:Send10829(skill)
            WindowManager.Instance:CloseWindow(self.parent.parent)
        end
    end)
end

function SkillFinalStudyPanel:SetItemNum()
    self.itemData.quantity = BackpackManager.Instance:GetItemCount(self.cost[1])
    self.itemSlot:SetAll(self.itemData, { nobutton = true })
end



function SkillFinalStudyPanel:Float(stemp)
    stemp = stemp or 0
    self.skill.transform.anchoredPosition = Vector2(0, 96 + 8 * math.sin(stemp * math.pi / 70, 0))
end