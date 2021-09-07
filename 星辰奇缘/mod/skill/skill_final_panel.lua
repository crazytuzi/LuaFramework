SkillFinalPanel = SkillFinalPanel or BaseClass(BasePanel)

function SkillFinalPanel:__init(model,parent)
    self.model = model
    --self.windowId = WindowConfig.WinID.skilltalentwindow
    self.parent = parent
    self.name = "SkillFinalPanel"
    self.resList = {
        {file = AssetConfig.skill_final, type = AssetType.Main}
        ,{file = AssetConfig.finalskill_textures, type = AssetType.Dep}
        ,{file = AssetConfig.final_skill_bg, type = AssetType.Dep}
        ,{file = AssetConfig.light_circle, type = AssetType.Dep}
        ,{file = AssetConfig.wingsbookbg, type = AssetType.Dep}
    }

    self.ongetskill = function()
        self:SetSkill()
    end

    self.updateEnergy = function(point)
        self:SetEnergy(point)
    end

    self.showEffect = function()
        self:ShowSkillEffect()
    end

    self.setitem = function()
        self:SetItem()
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.CanLev = true
    self.IsPlayEffect = false
end

function SkillFinalPanel:__delete()
    self.OnHideEvent:Fire()
    if self.skillSlot ~= nil then
        self.skillSlot:DeleteMe()
        self.skillSlot = nil
    end
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    if self.iconLoader2 ~= nil then
        self.iconLoader2:DeleteMe()
        self.iconLoader2 = nil
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
    if self.effect4 ~= nil then
        self.effect4:DeleteMe()
        self.effect4 = nil
    end
    if self.finalSkillPreview ~= nil then
        self.finalSkillPreview:DeleteMe()
        self.finalSkillPreview = nil
    end
    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end
    if self.itemData ~= nil then
        self.itemData:DeleteMe()
        self.itemData = nil
    end
    self:AssetClearAll()
end

function SkillFinalPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skill_final))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform
    local t = self.transform
    t:GetComponent(RectTransform).anchoredPosition = Vector2(120, -7.5)
    t:Find("SkillBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.final_skill_bg,"finalskillbg")
    t:Find("Skillbottom"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg,"wingsbookbg")
    t:Find("LightCircle"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.light_circle,"lightcircle")

    self.skill = t:Find("Skill").gameObject

    self.title = t:Find("Title/Text"):GetComponent(Text)
    self.desc = t:Find("Desc"):GetComponent(Text)


    self.energyVal = t:Find("Energy/Text"):GetComponent(Text)

    t:Find("BtnCharge"):GetComponent(Button).onClick:AddListener(function() self:OnClickCharge() end)

    self.skillId = self.model.finalSkill.skill_unique[1].id
    -- local lev = self.model.finalSkill.skill_unique[1].lev
    t:Find("BtnLookNext"):GetComponent(Button).onClick:AddListener(function()

        if self.finalSkillPreview == nil then
            self.finalSkillPreview = SkillFinalPreview:New(self)
        end
        self.finalSkillPreview:Show()
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end

    end)

    self.lvlup = t:Find("Lvlup")
    self.breakthrough = t:Find("Break")

    self.content = self.lvlup:Find("Point/Content"):GetComponent(RectTransform)
    self.doublePoint = self.lvlup:Find("Point/Content/val"):GetComponent(Text)

    self.lvlup:Find("BtnExercise"):GetComponent(Button).onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.exercise_window)
    end)

    self.lvlup:Find("BtnLvlup"):GetComponent(Button).onClick:AddListener(function()
        if self.model.finalSkill.skill_unique[1].lev == (RoleManager.Instance.RoleData.lev - 60) then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("技能需要达到<color='#ffff00'>%s</color>级时才能继续升级"), RoleManager.Instance.RoleData.lev+1))
        else
            if self.CanLev then
                if self.IsPlayEffect then return end
                if self.effect4 ~= nil then
                    self.effect4:SetActive(false)
                    self.effect4:SetActive(true)
                end
                self.IsPlayEffect = true
                if self.timerId1 ~= nil then
                    LuaTimer.Delete(self.timerId1)
                    self.timerId1 = nil
                end
                self.timerId1 = LuaTimer.Add(2000, function() SkillManager.Instance:Send10830(self.skillId) self.IsPlayEffect = false end)
            else
                SkillManager.Instance:Send10830(self.skillId)
            end
        end
    end)

    self.tips1 = "1、职业绝招可通过<color='#ffff00'>历练值</color>进行升级\n2、职业绝招达到一定级数后可进行<color='#ffff00'>突破</color>，突破后技能效果<color='#ffff00'>增强</color>\n3、历练值可通过完成<color='#ffff00'>悬赏任务</color>或<color='#ffff00'>野外挂机</color>获得\n4、30级后每天会消耗<color='#ffff00'>少量</color>历练值维持职业绝招的威力"

    self.lvlup:Find("NoticeBtn"):GetComponent(Button).onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.lvlup:Find("NoticeBtn").gameObject
            , itemData = {TI18N(self.tips)} })
    end)

    if self.iconLoader == nil then
        self.iconLoader = SingleIconLoader.New(self.lvlup:Find("Point/Content/Icon").gameObject)
    end
    self.iconLoader:SetSprite(SingleIconType.Item, 90055)

    if self.iconLoader2 == nil then
        self.iconLoader2 = SingleIconLoader.New(self.lvlup:Find("BtnExercise/Icon").gameObject)
    end
    self.iconLoader2:SetSprite(SingleIconType.Item, 90055)

    if self.effect == nil then
        self.effect = BaseUtils.ShowEffect(20437, t:Find("Skill"), Vector3(1,1,1), Vector3(0,0,-1000))
        self.effect:SetActive(false)
    end

    self.itemSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.breakthrough:Find("Item"), self.itemSlot.gameObject)

    self.cost = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].learn_cost[1]
    local itemBaseData = BackpackManager.Instance:GetItemBase(self.cost[1])
    self.breakthrough:Find("ItemName"):GetComponent(Text).text = itemBaseData.name
    self.itemData = ItemData.New()
    self.itemData:SetBase(itemBaseData)
    -- self:SetItem()

    self.breakBtn = self.breakthrough:Find("Button"):GetComponent(CustomButton)
    self.breakBtn.onUp:AddListener(function() self:OnUp() end)
    self.breakBtn.onDown:AddListener(function() self:OnDown() end)
    self.breakBtn.onClick:AddListener(function() self:OnClick() end)

    if self.effect2 == nil then
        self.effect2 = BaseUtils.ShowEffect(20438, t:Find("Skill"), Vector3(1,1,1), Vector3(0,0,-1000))
    end
    self.effect2:SetActive(false)

    if self.effect4 == nil then
        self.effect4 = BaseUtils.ShowEffect(20501, t:Find("Skill"), Vector3(1,1,1), Vector3(0,0,-1000))
    end
    self.effect4:SetActive(false)
end

function SkillFinalPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SkillFinalPanel:OnShow()
    self:AddListeners()
    if self.effect3 ~= nil then
        self.effect3:SetActive(false)
    end
    self.IsPlayEffect = false
    if self.effect4 ~= nil then
        self.effect4:SetActive(false)
    end
    SkillManager.Instance:Send10825()
    SkillManager.Instance:Send10833()
end

function SkillFinalPanel:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end
    if self.IsPlayEffect == true then
        SkillManager.Instance:Send10830(self.skillId)
        self.IsPlayEffect = false
    end
    if self.effect3 ~= nil then
        self.effect3:SetActive(false)
    end
    if self.effect4 ~= nil then
        self.effect4:SetActive(false)
    end
end

function SkillFinalPanel:AddListeners()
    -- self:RemoveListeners()
    SkillManager.Instance.OnGetFinalInfo:AddListener(self.ongetskill)
    SkillManager.Instance.OnUpdateSkillEnergy:AddListener(self.updateEnergy)
    SkillManager.Instance.OnHideTips:AddListener(self.showEffect)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.setitem)

end

function SkillFinalPanel:RemoveListeners()
    SkillManager.Instance.OnGetFinalInfo:RemoveListener(self.ongetskill)
    SkillManager.Instance.OnUpdateSkillEnergy:RemoveListener(self.updateEnergy)
    SkillManager.Instance.OnHideTips:RemoveListener(self.showEffect)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.setitem)
end

function SkillFinalPanel:OnClickCharge()
    local checkFun = function(data)
        local id = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].learn_cost[1][1]
        if data.base_id == id then
            return true
        end
        return false
    end
    local button3_callback = function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, { 2, 4 })
    end
    BackpackManager.Instance.mainModel:OpenQuickBackpackWindow({ checkFun = checkFun, showButtonType = 2, button3_callback = button3_callback})
    if self.effect ~= nil then
        self.effect:SetActive(false)
    end
end

function SkillFinalPanel:SetSkill()
    if self.skill == nil then
        return
    end
    if self.model.finalSkill == nil or #self.model.finalSkill.skill_unique == 0 then
        return
    end

    if self.skillSlot == nil then
        self.skillSlot = SkillSlot.New()
        self.skillSlot.gameObject:AddComponent(TransitionButton).scaleRate = 1.1
        UIUtils.AddUIChild(self.skill, self.skillSlot.gameObject)
    end
    local skill = self.model.finalSkill.skill_unique[1].id
    local lev = self.model.finalSkill.skill_unique[1].lev
    local data = DataSkill.data_skill_role[string.format("%s_%s", skill,lev)]
    self.skillSlot:SetAll(Skilltype.roleskill, data, { classes = RoleManager.Instance.RoleData.classes })

    local unique_skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_"..lev]
    local cost = 0
    if DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_"..(lev+1)] then
        cost = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_"..(lev+1)].up_cost[1][2]
    end
    local have = RoleManager.Instance.RoleData.skl_unique_exp

    if lev > 29 then
        self.tips = self.tips1..string.format("\n5、当前等级每天消耗历练值：<color='#00ff00'>%s</color> ",unique_skill.dayly_sq_exp)
    else
        self.tips = self.tips1
    end

    if have < cost then
        self.doublePoint.text = string.format("<color='#df3435'>%s</color>/%s", have , cost )
    else
        self.doublePoint.text = have.."/"..cost
    end
    self.CanLev = (have >= cost)

    self.content.localPosition = Vector2((68-self.doublePoint.preferredWidth)/2,0)

    self:SetItem()

    self.desc.text = unique_skill.desc
    self.title.text = data.name.."     Lv."..lev

    if unique_skill.is_break == 1 then
        self.lvlup.gameObject:SetActive(false)
        self.breakthrough.gameObject:SetActive(true)
    else
        self.lvlup.gameObject:SetActive(true)
        self.breakthrough.gameObject:SetActive(false)
    end
end

function SkillFinalPanel:SetItem()
    if self.itemSlot == nil then
        return
    end
    local lev = self.model.finalSkill.skill_unique[1].lev
    local unique_skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_"..(lev + 1)]
    if unique_skill ~= nil then 
        local cost = unique_skill.up_cost[1][2]
        self.itemData.need = cost
        self.itemData.quantity = BackpackManager.Instance:GetItemCount(self.cost[1])
        self.itemSlot:SetAll(self.itemData, { nobutton = true })
    end
end


function SkillFinalPanel:SetEnergy(point)
    local desc = ""
    if point > 80 then
        desc = "灵气充沛"
    elseif point > 60 then
        desc = "灵气充盈"
    elseif point > 40 then
        desc = "灵气不足"
    else
        desc = "灵气枯竭"
    end
    if self.energyVal == nil then
        return
    end
    if point < 41 then
        self.energyVal.text = string.format("%s:<color='#df3435'>%s</color>/100",desc,point)
    else
        self.energyVal.text = desc..":"..point.."/100"
    end
    if point > 0 then
        self.effect:SetActive(true)
        if self.timerId == nil then
            local temp = 0
            self.timerId = LuaTimer.Add(0, 22, function() self:Float(temp) temp = temp + 1  end)
        end
    else
        self.effect:SetActive(false)
        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end
        self.skill.transform.anchoredPosition = Vector2(0, 96)
    end
end

function SkillFinalPanel:Float(stemp)
    stemp = stemp or 0
    self.skill.transform.anchoredPosition = Vector2(0, 96 + 8 * math.sin(stemp * math.pi / 70, 0))
end

function SkillFinalPanel:ShowSkillEffect()
    if self.effect ~= nil then
        self.effect:SetActive(true)
    end
end


function SkillFinalPanel:OnUp()
    if self.effect2 ~= nil then
        self.effect2:SetActive(false)
    end
    SoundManager.Instance:StopId(232)
    self:StopTime()
end

function SkillFinalPanel:StopTime()
    if self.holdTimeId ~= nil then
        LuaTimer.Delete(self.holdTimeId)
        self.holdTimeId = nil
    end
end

function SkillFinalPanel:OnDown()
    self.hasDone = false

    self.enough = BackpackManager.Instance:GetItemCount(self.cost[1]) > self.itemData.need - 1

    if self.model.finalSkill.skill_unique[1].lev == (RoleManager.Instance.RoleData.lev - 60) then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("技能需要达到<color='#ffff00'>%s</color>级时才能继续升级"), RoleManager.Instance.RoleData.lev+1))
        self.hasDone = true
        return
    end

    if not self.enough then
        self.hasDone = true
        NoticeManager.Instance:FloatTipsByString(TI18N("道具不足"))
        self.itemSlot:SureClick()
        return
    end

    if self.effect2 ~= nil then
        self.effect2:SetActive(false)
        self.effect2:SetActive(true)
    end

    SoundManager.Instance:Play(232)

    self:BeginTime()
end

function SkillFinalPanel:BeginTime()
    self:StopTime()
    self.holdTimeId = LuaTimer.Add(1800, function() self:Beng() end)
end

function SkillFinalPanel:Beng()
    self.hasDone = true
    self:StopTime()
    if self.effect2 ~= nil then
        self.effect2:SetActive(false)
    end
    if self.effect3 == nil then
        self.effect3 = BaseUtils.ShowEffect(20440, self.transform:Find("Skill"), Vector3(1,1,1), Vector3(0,0,-1000))
    end
    self.effect3:SetActive(false)
    self.effect3:SetActive(true)
    SoundManager.Instance:Play(217)
    local skill = self.model.finalSkill.skill_unique[1].id
    SkillManager.Instance:Send10830(skill)
end


function SkillFinalPanel:OnClick()
    if not self.hasDone then
        NoticeManager.Instance:FloatTipsByString(TI18N("请<color='#ffff00'>长按</color>进行职业绝招进阶{face_1,22}"))
    end
end
