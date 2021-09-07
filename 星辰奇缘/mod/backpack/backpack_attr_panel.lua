BackpackAttrPanel = BackpackAttrPanel or BaseClass(BasePanel)

function BackpackAttrPanel:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.backpack_attr, type =  AssetType.Main}
        ,{file = AssetConfig.attr_icon, type = AssetType.Dep}
        ,{file = AssetConfig.ride_texture, type = AssetType.Dep}
    }
    self.parent = nil
    self.gray = Color.grey
    self.white = Color.white

    self.listener = function() self:UpdateAttr() end
    self.listenerLevel = function() self:UpdateAttr() self:UpdateExp() end
    self.helpTxt = {
        TI18N("<color='#00ffff'>[储备经验]</color>"),
        TI18N("1、未完成的日常活动、副本所错过的经验，会按照一定比例转化为储备经验。"),
        TI18N("2、获得经验时，储备经验会转换为人物经验。"),
        -- "3、储备经验的上限随角色等级升高而提升。"
    }


    self.helpNormal = {
        TI18N("1.角色升级、爵位挑战可获得人物属性点"),
        TI18N("2.合理分配属性点可打造最强职业")
    }

    self.greenTxt = "<color='#fffff0'>%s</color>"
    self.blueTxt = "<color='#c7f9ff'>%s</color>"

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.guideEffect = nil
end

function BackpackAttrPanel:OnShow()
    self:CheckGuideBreak()
    self:CheckGuideAddPoint()
end

function BackpackAttrPanel:__delete()
    self:StopShakeButton()
    if self.normalImg ~= nil then
        BaseUtils.ReleaseImage(self.normalImg)
    end
    if self.betterImg ~= nil then
        BaseUtils.ReleaseImage(self.betterImg)
    end
    EventMgr.Instance:RemoveListener(event_name.role_attr_change, self.listener)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.listener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.listenerLevel)
    EventMgr.Instance:RemoveListener(event_name.role_exp_change, self.listenerLevel)
    if self.guideEffect ~= nil then
        self.guideEffect:DeleteMe()
        self.guideEffect = nil
    end
    if self.guideBreak ~= nil then
        self.guideBreak:DeleteMe()
        self.guideBreak = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function BackpackAttrPanel:OnInitCompleted()
    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()
    self:CheckGuideBreak()
    self:CheckGuideAddPoint()
end

function BackpackAttrPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpack_attr))
    self.gameObject.name = "BackpackAttrPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(185, 0, 0)

    self.normalImg = self.transform:Find("NormalButton"):GetComponent(Image)
    self.normalTxt = self.transform:Find("NormalButton/Text"):GetComponent(Text)
    self.betterImg = self.transform:Find("BetterButton"):GetComponent(Image)
    self.normalTxt.supportRichText = true
    self.betterTxt = self.transform:Find("BetterButton/Text"):GetComponent(Text)
    self.betterTxt.supportRichText = true
    self.normalBtn = self.transform:Find("NormalButton"):GetComponent(Button)
    self.betterBtn = self.transform:Find("BetterButton"):GetComponent(Button)
    self.normalBtn.onClick:AddListener(function() self:ChangeTab(1) end)
    self.betterBtn.onClick:AddListener(function() self:ChangeTab(2) end)

    self.egBtn = self.transform:Find("EGButton"):GetComponent(Button)
    self.egBtn.onClick:AddListener(function() self:ClickEnergy() end)

    self.helpBtn = self.transform:Find("HelpButton"):GetComponent(Button)
    self.helpBtn.onClick:AddListener(function() self:ClickHelp() end)
    self.helpBtn1 = self.transform:Find("HelpButton1"):GetComponent(Button)
    self.helpBtn1.gameObject:SetActive(false)
    self.helpBtn1.onClick:AddListener(function() self:ClickHelp() end)
    self.levBreakBtn = self.transform:Find("LevBreakButton")
    self.levBreakBtnText1 = self.transform:Find("LevBreakButton"):GetChild(0):GetComponent(Text)
    self.levBreakBtnText2 = self.transform:Find("LevBreakButton"):GetChild(1):GetComponent(Text)
    self.levBreakBtn.gameObject:SetActive(false)
    self.levBreakBtn:GetComponent(Button).onClick:AddListener(function() self:ClickLevBreak() end)
    self.ExtendButton = self.transform:Find("ExtendButton").gameObject
    self.transform:Find("ExtendButton/JumpButton"):GetComponent(Button).onClick:AddListener(function()
        self.ExtendButton:SetActive(false)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.leveljumpwindow)
    end)
    self.transform:Find("ExtendButton/GetPointButton"):GetComponent(Button).onClick:AddListener(function()
        self.ExtendButton:SetActive(false)
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.exchangepointwindow)
    end)
    self.transform:Find("ExtendButton/bgButton"):GetComponent(Button).onClick:AddListener(function()
        self.ExtendButton:SetActive(false)
    end)
    self.exchangePointBtn = self.transform:Find("ExchangePointButton")
    self.exchangePointBtnText1 = self.transform:Find("ExchangePointButton"):GetChild(0):GetComponent(Text)
    self.exchangePointBtnText2 = self.transform:Find("ExchangePointButton"):GetChild(1):GetComponent(Text)
    self.exchangePointBtn.gameObject:SetActive(false)
    self.exchangePointBtn:GetComponent(Button).onClick:AddListener(function() self:ClickExchangePoint() end)

    self.normal = self.transform:Find("Normal").gameObject
    self.better = self.transform:Find("Better").gameObject

    self.egTxt = self.transform:Find("EG/Value"):GetComponent(Text)
    self.hpTxt = self.transform:Find("HP/Value"):GetComponent(Text)
    self.mpTxt = self.transform:Find("MP/Value"):GetComponent(Text)
    self.paTxt = self.transform:Find("Normal/PhyAttack/Value"):GetComponent(Text)
    self.maTxt = self.transform:Find("Normal/MagicAttack/Value"):GetComponent(Text)
    self.pdTxt = self.transform:Find("Normal/PhyDefense/Value"):GetComponent(Text)
    self.mdTxt = self.transform:Find("Normal/MagicDefense/Value"):GetComponent(Text)
    self.asTxt = self.transform:Find("Normal/AttackSpeed/Value"):GetComponent(Text)
    self.cureTxt = self.transform:Find("Normal/Cure/Value"):GetComponent(Text)
    self.normalHelpBtn = self.transform:Find("Normal/HelpButton"):GetComponent(Button)
    self.normalHelpBtn.onClick:AddListener(function() self:ClickNormalHelp() end)

    self.toughTxt = self.transform:Find("Better/Tough/Value"):GetComponent(Text)
    self.critTxt = self.transform:Find("Better/Crit/Value"):GetComponent(Text)
    self.hitTxt = self.transform:Find("Better/Hit/Value"):GetComponent(Text)
    self.missTxt = self.transform:Find("Better/Miss/Value"):GetComponent(Text)
    self.duTxt = self.transform:Find("Better/DamageUp/Value"):GetComponent(Text)
    self.cuTxt = self.transform:Find("Better/ControllUp/Value"):GetComponent(Text)
    self.drTxt = self.transform:Find("Better/DamageReduce/Value"):GetComponent(Text)
    self.crTxt = self.transform:Find("Better/ControllResist/Value"):GetComponent(Text)

    self.egSlider = self.transform:Find("EG/Slider"):GetComponent(Slider)
    self.hpSlider = self.transform:Find("HP/Slider"):GetComponent(Slider)
    self.mpSlider = self.transform:Find("MP/Slider"):GetComponent(Slider)
    self.expSlider = self.transform:Find("ExpSlider"):GetComponent(Slider)

    self.disTxt = self.transform:Find("Normal/DistributePoint"):GetComponent(Text)
    self.expTxt = self.transform:Find("ExpValue"):GetComponent(Text)
    self.currExpTxt = self.transform:Find("CurrentExp"):GetComponent(Text)

    self.transform:Find("ExpValue"):GetComponent(Button).onClick:AddListener(function() self:ClickHelp() end)
    self.transform:Find("CurrentExp"):GetComponent(Button).onClick:AddListener(function() self:ClickHelp() end)

    self.addButton = self.transform:Find("Normal/AddButton"):GetComponent(Button)
    self.addButton.onClick:AddListener(function() self.model:OpenAddPoint() end)
    self.redPoint = self.transform:Find("Normal/AddButton/AttrRedPoint").gameObject
    self.addBtnObj = self.transform:Find("Normal/AddButton").gameObject

    self:UpdateAttr()
    self:UpdateExp()
    self:ChangeTab(1)
    if (RoleManager.Instance.RoleData.lev == 89 or RoleManager.Instance.RoleData.lev == 109 or RoleManager.Instance.RoleData.lev == 99) then
        self.levBreakBtnText1.text = TI18N("跃升")
        self.levBreakBtnText2.text = TI18N("跃升")
        self:ShakeButton()
    else
        self.levBreakBtnText1.text = TI18N("突破")
        self.levBreakBtnText2.text = TI18N("突破")
        self:StopShakeButton()
    end

    EventMgr.Instance:AddListener(event_name.role_attr_change, self.listener)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.listener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.listenerLevel)
    EventMgr.Instance:AddListener(event_name.role_exp_change, self.listenerLevel)
end

function BackpackAttrPanel:UpdateAttr()
    local role = RoleManager.Instance.RoleData
    self.hpTxt.text = string.format("%s/%s", role.hp, role.hp_max)
    self.hpSlider.value = role.hp/ role.hp_max
    self.mpTxt.text = string.format("%s/%s", role.mp, role.mp_max)
    self.mpSlider.value = role.mp/ role.mp_max

    self.paTxt.text = tostring(role.phy_dmg)
    self.maTxt.text = tostring(role.magic_dmg)
    self.pdTxt.text = tostring(role.phy_def)
    self.mdTxt.text = tostring(role.magic_def)
    self.asTxt.text = tostring(role.atk_speed)
    self.cureTxt.text = tostring(role.heal_val)

    self.toughTxt.text = "+"..tostring(role.tenacity/10).."%"
    self.critTxt.text = "+"..tostring(role.crit/10).."%"
    self.hitTxt.text = "+"..tostring(role.accuracy/10).."%"
    self.missTxt.text = "+"..tostring(role.evasion/10).."%"

    self.duTxt.text = "+"..tostring(math.floor(role.dmg_ratio/10)).."%"
    self.cuTxt.text = "+"..tostring(math.floor(role.enhance_control/10)).."%"
    self.drTxt.text = "+"..tostring(math.floor(role.def_ratio/10)).."%"
    self.crTxt.text = "+"..tostring(math.floor(role.anti_control/10)).."%"

    local point = role.point
    if role.point_data ~= nil then
        for i = 1, #role.point_data do
            if role.point_data[i].index == role.valid_plan then
                point = role.point_data[i].point
                break
            end
        end
    end

    self.disTxt.text = tostring(point)

    self.redPoint:SetActive((point or 0) > 0)
    --print("666666666666666666666666666666666666")
    -- print(RoleManager.Instance.RoleData.lev_break_times)
    if RoleManager.Instance.RoleData.lev_break_times > 0 then
        self.helpBtn.gameObject:SetActive(false)
        self.helpBtn1.gameObject:SetActive(true)
        self.levBreakBtn.gameObject:SetActive(false)
        self.exchangePointBtn.gameObject:SetActive(true)
    else
        if (RoleManager.Instance.RoleData.lev > 98 and RoleManager.Instance.world_lev >= 95) or RoleManager.Instance.RoleData.lev == 89 or RoleManager.Instance.RoleData.lev == 109 then
            self.helpBtn.gameObject:SetActive(false)
            self.helpBtn1.gameObject:SetActive(true)
            self.levBreakBtn.gameObject:SetActive(true)
            self.exchangePointBtn.gameObject:SetActive(true)
        else
            self.helpBtn.gameObject:SetActive(true)
            self.helpBtn1.gameObject:SetActive(false)
            self.levBreakBtn.gameObject:SetActive(false)
            self.exchangePointBtn.gameObject:SetActive(false)
        end
        if (RoleManager.Instance.RoleData.lev == 89 or RoleManager.Instance.RoleData.lev == 109 or RoleManager.Instance.RoleData.lev == 99) then
            self.levBreakBtnText1.text = TI18N("跃升")
            self.levBreakBtnText2.text = TI18N("跃升")
            self:ShakeButton()
        else
            self:StopShakeButton()
            self.levBreakBtnText1.text = TI18N("突破")
            self.levBreakBtnText2.text = TI18N("突破")
        end
    end

    self:UpdateEngine()
end

function BackpackAttrPanel:UpdateEngine()
    local role = RoleManager.Instance.RoleData
    local agendaData = DataAgenda.data_energy_max[role.lev]
    local max = 0
    if agendaData ~= nil then
        max = agendaData.max_energy
        self.egSlider.value = role.energy / max
    else
        self.egSlider.value = 0
    end
    self.egTxt.text = string.format("%s/%s", role.energy, max)
end

function BackpackAttrPanel:UpdateExp()
    local role = RoleManager.Instance.RoleData
    local levup_data = DataLevup.data_levup[role.lev]
    if levup_data ~= nil then
        local maxExp = levup_data.exp
        self.expSlider.value = role.exp / maxExp
        self.expTxt.text = string.format("%s/%s", role.exp, maxExp)
    else
        self.expSlider.value = 1
        self.expTxt.text = string.format(TI18N("%s/满级"), role.exp)
    end
    self.currExpTxt.text = string.format(TI18N("当前储备经验:<color='#205696'>%s</color>"), role.reserve_exp)
    local currlev = RoleManager.Instance.RoleData.lev
    if (currlev == 89 or currlev == 109) then
        self.levBreakBtnText1.text = TI18N("跃升")
        self.levBreakBtnText2.text = TI18N("跃升")
        self.exchangePointBtnText1.text = TI18N("跃升")
        self.exchangePointBtnText2.text = TI18N("跃升")
        self:ShakeButton()
    else
        self.levBreakBtnText1.text = TI18N("突破")
        self.levBreakBtnText2.text = TI18N("突破")
        if currlev == 99 then
            self.exchangePointBtnText1.text = TI18N("跃升")
            self.exchangePointBtnText2.text = TI18N("跃升")
            self:ShakeButton()
        else
            self.exchangePointBtnText1.text = TI18N("兑换")
            self.exchangePointBtnText2.text = TI18N("兑换")
            self:StopShakeButton()
        end
    end
end

function BackpackAttrPanel:ChangeTab(index)
    if index == 1 then
        self.normalImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Select")
        self.betterImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Normal")
        self.normalTxt.text = string.format(self.greenTxt, TI18N("基 础"))
        self.betterTxt.text = string.format(self.blueTxt, TI18N("高 级"))
        self.normal:SetActive(true)
        self.better:SetActive(false)
    else
        self.normalImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Normal")
        self.betterImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TabButton2Select")
        self.normalTxt.text = string.format(self.blueTxt, TI18N("基 础"))
        self.betterTxt.text = string.format(self.greenTxt, TI18N("高 级"))
        self.normal:SetActive(false)
        self.better:SetActive(true)
    end
end

function BackpackAttrPanel:ClickEnergy()
    SkillManager.Instance.model:OpenUseEnergy()
end

function BackpackAttrPanel:ClickHelp()
    local max = DataAgenda.data_exp_max[RoleManager.Instance.RoleData.lev].max_reserve_exp
    local currlev = RoleManager.Instance.RoleData.lev
    local curr = RoleManager.Instance.RoleData.reserve_exp
    local color = (curr == max) and "#ffff00" or "#ffffff"
    local txts = {}
    if currlev == 89 or currlev == 109 or currlev == 99 then
        table.insert(txts, TI18N("<color='#00ffff'>等级跃升</color>"))
        table.insert(txts, string.format(TI18N("1、人物在<color='#ffff00'>%s级</color>且经验达到<color='#ffff00'>100%%</color>时，经验会继续积累，但<color='#ffff00'>不会自动升级</color>"), RoleManager.Instance.RoleData.lev))
        table.insert(txts, TI18N("2、建议战力评分达到推荐水平后，再征战下一等级段"))
    end
    table.insert(txts, string.format(TI18N("<color='#00ffff'>当前可用储备经验：</color><color='%s'>%s/%s</color>"), color, curr, max))
    table.insert(txts, TI18N("拥有足够的储备经验，每次获得经验时将额外得到相等的储备经验"))
    TipsManager.Instance:ShowText({gameObject = self.helpBtn.gameObject, itemData = txts})
    txts = nil
end

function BackpackAttrPanel:ClickLevBreak()
    local currlev = RoleManager.Instance.RoleData.lev
    if currlev == 89 or currlev == 99 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.leveljumpwindow)
    elseif currlev == 109 then
        self.ExtendButton:SetActive(true)
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.levelbreakwindow)
    end
end

function BackpackAttrPanel:ClickExchangePoint()
    local currlev = RoleManager.Instance.RoleData.lev
    if currlev == 109 or currlev == 99 then
        self.ExtendButton:SetActive(true)
    else
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.exchangepointwindow)
    end
end

function BackpackAttrPanel:ClickNormalHelp()
    TipsManager.Instance:ShowText({gameObject = self.normalHelpBtn.gameObject, itemData = self.helpNormal})
end

-- 检查突破属性点兑换引导
function BackpackAttrPanel:CheckGuideBreak()
    if RoleManager.Instance.isGuideBreakFirst then
        -- 本次登陆引导过
        return
    end

    if not RoleManager.Instance:CheckBreakGuide() then
        return
    end

    if self.guideBreak ~= nil then
        self.guideBreak:DeleteMe()
        self.guideBreak = nil
    end

    if self.guideBreak == nil then
        self.guideBreak = GuideBreakPointFirst.New(self)
    end
    self.guideBreak:Show()
end

function BackpackAttrPanel:ShakeButton()
    if self.btntween1 == nil then
        self.levBreakBtn.localScale = Vector3.one*0.9
        self.exchangePointBtn.localScale = Vector3.one*0.9
        self.btntween1 = Tween.Instance:Scale(self.levBreakBtn.gameObject, Vector3(1.1, 1.1, 1.1), 1, function() end, LeanTweenType.easeOutElastic):setLoopPingPong()
        self.btntween2 = Tween.Instance:Scale(self.exchangePointBtn.gameObject, Vector3(1.1, 1.1, 1.1), 1, function() end, LeanTweenType.easeOutElastic):setLoopPingPong()
    end
end

function BackpackAttrPanel:StopShakeButton()
    if self.btntween1 ~= nil then
        Tween.Instance:Cancel(self.btntween1.id)
        Tween.Instance:Cancel(self.btntween2.id)
        self.levBreakBtn.localScale = Vector3.one
        self.exchangePointBtn.localScale = Vector3.one
        self.btntween1 = nil
        self.btntween2 = nil
    end
end

function BackpackAttrPanel:CheckGuideAddPoint()
    -- TipsManager.Instance:HideGuide()
    -- if (RoleManager.Instance.isGuideBreakFirst or not RoleManager.Instance:CheckBreakGuide()) and RoleManager.Instance.RoleData:ExtraPoint() == 0  and RoleManager.Instance.RoleData.point ~= 0 then
    --     if self.guideEffect == nil then
    --         self.guideEffect = BibleRewardPanel.ShowEffect(20104,self.addButton.transform,Vector3(0.8,0.8,1), Vector3(0,0,-400))
    --     end
    --     self.guideEffect:SetActive(true)
    --     TipsManager.Instance:ShowGuide({gameObject = self.addButton.gameObject, data = TI18N("点击分配人物属性点"), forward = TipsEumn.Forward.Left})
    -- else
    --     if self.guideEffect ~= nil then
    --         self.guideEffect:SetActive(false)
    --     end
    -- end
end