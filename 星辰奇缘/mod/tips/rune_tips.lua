-- ------------------------------
-- 内丹tips
-- hze
-- ------------------------------
RuneTips = RuneTips or BaseClass(BaseTips)

function RuneTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_rune, type = AssetType.Main}
    }
    self.mgr = TipsManager.Instance
    self.width = 315
    self.height = 232
    self.nobuttonHeight = 60
    self.buttons = {}
    self.DefaultSize = Vector2(309, 404)

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:OnHide() self:RemoveTime() end)
end

function RuneTips:__delete()
    if self.itemCell ~= nil then
        self.itemCell:DeleteMe()
        self.itemCell = nil
    end
    self.itemData = nil
    self.mgr = nil
    self.buttons = {}
    self.height = 232
    self:RemoveTime()
end

function RuneTips:RemoveTime()
    self.mgr.updateCall = nil
end

function RuneTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_rune))
    self.gameObject.name = "RuneTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.gameObject:GetComponent(Button).onClick:AddListener(function() EventMgr.Instance:Fire(event_name.tips_cancel_close) self.model:Closetips() end)

    self.rect = self.gameObject:GetComponent(RectTransform)

    local head = self.transform:Find("HeadArea")
    self.itemCell = ItemSlot.New()
    UIUtils.AddUIChild(head:Find("ItemSlot"), self.itemCell.gameObject)
    self.itemCell:SetNotips()
    self.nameTxt = head:Find("Name"):GetComponent(Text)
    self.levTxt = head:Find("Lev"):GetComponent(Text)
    self.statusTxt = head:Find("Status"):GetComponent(Text)

    local mid = self.transform:Find("MidArea")
    self.midRect = mid.gameObject:GetComponent(RectTransform)
    self.text1 = mid:Find("Text1"):GetComponent(Text)
    self.text2 = mid:Find("Text2"):GetComponent(Text)

    self.trect1 = self.text1.gameObject:GetComponent(RectTransform)
    self.trect2 = self.text2.gameObject:GetComponent(RectTransform)

    local descArea = self.transform:Find("BottomArea")
    self.descRect = descArea.gameObject:GetComponent(RectTransform)

    local bottom = self.transform:Find("ButtonList")
    self.bottomRect = bottom.gameObject:GetComponent(RectTransform)
    local forgotten = bottom:Find("ForgottenButton").gameObject
    local comprehension = bottom:Find("ComprehensionButton").gameObject
    local upgrade = bottom:Find("UpgradeButton").gameObject
    local resonance = bottom:Find("ResonanceButton").gameObject

    forgotten:GetComponent(Button).onClick:AddListener(function() self:OnForgotten()  end)
    comprehension:GetComponent(Button).onClick:AddListener(function() self:OnSavvy()  end)
    upgrade:GetComponent(Button).onClick:AddListener(function() self:OnUpgrade()   end)
    resonance:GetComponent(Button).onClick:AddListener(function() self:OnResonance()  end)

    self.buttons = {
        [TipsEumn.ButtonType.Forgotten] = forgotten
        ,[TipsEumn.ButtonType.Comprehension] = comprehension
        ,[TipsEumn.ButtonType.Upgrade] = upgrade
        ,[TipsEumn.ButtonType.Resonance] = resonance
    }

    for _,v in pairs(self.buttons) do
        if v ~= nil then
            v.transform.pivot = Vector2(0.5, 0.5)
        end
    end
end

function RuneTips:UnRealUpdate()
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

function RuneTips:Default()
    -- print("----------3")
    self.height = 232
    self.nameTxt.text = ""
    self.levTxt.text = ""
    self.statusTxt.text = ""

    self.text1.text = ""
    self.text2.text = ""

    for _,button in pairs(self.buttons) do
        button.gameObject:SetActive(false)
    end

    self.rect.sizeDelta = self.DefaultSize
end

-- ------------------------------------
-- 外部调用更新数据
-- 参数说明:
-- info = 内丹数据
-- extra = 扩展参数
-- ---- nobutton = 是否不要任何按钮
-- ------------------------------------
function RuneTips:UpdateInfo(info, extra)
    self.transform:SetAsLastSibling()
    self:Default()  
    extra = extra or {}
    self.extra = extra
    self.itemData = info
    -- BaseUtils.dump(info,"内丹数据")
    if info == nil then return end

    local runeData = DataRune.data_rune[BaseUtils.Key(info.rune_id, info.rune_lev)]
    local nextLev_runeData

    local skillData = DataSkill.data_petSkill[BaseUtils.Key(runeData.skill_id, "1")]
    local nextlev_skillData 

    
    if info.rune_status ~= 3 then 
        nextLev_runeData = DataRune.data_rune[BaseUtils.Key(info.rune_id, info.rune_lev + 1)]
        nextlev_skillData = DataSkill.data_petSkill[BaseUtils.Key(nextLev_runeData.skill_id, "1")]
    else
        if runeData.quality == 1 and info.is_resonance ~= 1 then 
            nextLev_runeData = DataRune.data_rune[BaseUtils.Key(info.rune_id, info.rune_lev + 1)]
            nextlev_skillData = DataSkill.data_petSkill[BaseUtils.Key(nextLev_runeData.skill_id, "1")]
        end 
    end
     
    self.nameTxt.text = ColorHelper.color_item_name(runeData.lev - 1, runeData.name)
    self.levTxt.text = string.format(TI18N("%s级"), runeData.lev)

    local txtString = ""
    if runeData.quality == 1 then 
        if info.rune_status == 1 then
            txtString = TI18N("可领悟")
        elseif info.rune_status == 2 then
            txtString = TI18N("可升级")
        end

        -- if PetManager.Instance.model:JudgeRuneResonancesStatus(info.rune_id) then 
        if PetManager.Instance.model:JudgeStudySmartStatus() then 
            if info.is_resonance == 1 then 
                txtString = txtString .."/"..TI18N("已共鸣")
            else
                txtString = txtString .."/"..TI18N("未共鸣")
            end
        end

        if info.rune_status == 3 then
            if info.is_resonance == 1 then 
                txtString = TI18N("已共鸣")
            else
                txtString = TI18N("未共鸣")
            end
        end
    elseif runeData.quality == 2 then 
        if info.rune_status == 1 then 
            txtString = TI18N("可领悟")
        elseif info.rune_status == 2 then 
            txtString = TI18N("可升级")
        elseif info.rune_status == 3 then 
            txtString = TI18N("最高级")
        end
    end
    self.statusTxt.text = txtString

    local itemdata = ItemData.New()
    itemdata:SetBase(DataItem.data_get[info.rune_id])
    self.itemCell:SetAll(itemdata)
    self.itemCell:ShowNum(false)


    
    local desc1 = skillData.desc
    local desc2 = ""
    if runeData.quality == 1 then 
        if info.rune_status == 3 then
            if info.is_resonance == 1 then 
                desc2 = TI18N("当前已达到最高级效果")
            else
                desc2 = string.format( "%s%s", TI18N("下一等级效果："), nextlev_skillData.desc)
            end
        else
            desc2 = string.format( "%s%s", TI18N("下一等级效果："), nextlev_skillData.desc)
        end
    elseif runeData.quality == 2 then 
        if info.rune_status == 3 then 
            local num = #info.resonances
            for k,v in ipairs(info.resonances) do
                local str = ""
                if v.resonance_id ~= 0 then 
                    local name = DataRune.data_rune[BaseUtils.Key(v.resonance_id,"1")].name
                    if v.rune_index == 0 then
                        if PetManager.Instance.model:JudgeStudyStatus(v.resonance_id) then
                            str = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("已学习"))
                        else
                            str = string.format("<color='%s'>%s</color>", ColorHelper.color[6], TI18N("未学习"))
                        end                        
                    else
                        str = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("已共鸣"))
                    end
                    str = string.format("%s %s", name, str)
                else
                    str = TI18N("未激活")
                end
                str = string.format("%s: %s", TI18N("共鸣"), str)
                desc2 = desc2..str
                if k < num then 
                    desc2 = desc2 .."\n"
                end
            end
        else
            desc2 = string.format( "%s%s", TI18N("下一等级效果："), nextlev_skillData.desc)
        end
    end

    self.text1.text = string.format( "%s%s", TI18N("当前等级效果："), desc1)
    self.text2.text = desc2

    -- 处理描述显示
    local th1 = self.text1.preferredHeight + 3
    self.trect1.sizeDelta = Vector2(250, th1)
    th1 = th1 + 6
    self.trect2.anchoredPosition = Vector2(5, -th1)
    local th2 = self.text2.preferredHeight + 3
    self.trect2.sizeDelta = Vector2(250, th2)

    local th = th1 + th2
    self.midRect.sizeDelta = Vector2(255, th)

    
    self.descRect.anchoredPosition = Vector2(5, -110 - th - 10)

    self.height = self.height + th
    
    -- 处理按钮
    if not extra.nobutton then 
        local showlist = {}
        table.insert( showlist, TipsEumn.ButtonType.Forgotten)
        if info.rune_status == 1 then 
            table.insert( showlist, TipsEumn.ButtonType.Comprehension)
        elseif info.rune_status == 2 then
            table.insert( showlist, TipsEumn.ButtonType.Upgrade)
        elseif info.rune_status == 3 then 
            if runeData.quality == 2 then 
                table.insert( showlist, TipsEumn.ButtonType.Resonance)
            end
        end

        local btn_count = #showlist
        if btn_count == 1 then 
            local btn = self.buttons[showlist[1]]
            btn.gameObject:SetActive(true)
            btn.transform.anchoredPosition = Vector2(self.bottomRect.sizeDelta.x * 0.5, -30)
        else
            local btn = self.buttons[showlist[1]]
            btn.gameObject:SetActive(true)
            btn.transform.anchoredPosition = Vector2(self.bottomRect.sizeDelta.x * 0.25, -30)
            btn = self.buttons[showlist[2]]
            btn.gameObject:SetActive(true)
            btn.transform.anchoredPosition = Vector2(self.bottomRect.sizeDelta.x * 0.75 , -30)
        end
    else
        self.height = self.height - self.nobuttonHeight
    end

    self.rect.sizeDelta = Vector2(self.DefaultSize.x, self.height)
    self.mgr.updateCall = self.updateCall
end

function RuneTips:OnUpgrade()
    -- print("onupgrade")
    self.model:Closetips()
    local upgrade_data = DataRune.data_upgrade_forgotten[BaseUtils.Key(self.itemData.rune_type, self.itemData.rune_lev)]
    local runeData = DataRune.data_rune[BaseUtils.Key(self.itemData.rune_id, self.itemData.rune_lev)]

    local confirmCostData = {}
    confirmCostData.content = string.format( TI18N("将%s提升到%s级，需要消耗以下材料："), runeData.name, runeData.lev + 1)
    confirmCostData.id = self.itemData.rune_id
    confirmCostData.needNum = upgrade_data.update_cost
    confirmCostData.sureCall = function() PetManager.Instance:Send10575(self.itemData.pet_id, self.itemData.rune_index, self.itemData.rune_id) end
    confirmCostData.noGold = false
    confirmCostData.protoId = 10575
    NoticeManager.Instance:ConfirmCostTips(confirmCostData)

    -- PetManager.Instance:Send10575(self.itemData.pet_id, self.itemData.rune_index, self.itemData.rune_id)
end

function RuneTips:OnSavvy()
    self.model:Closetips()
    PetManager.Instance.model:OpenPetSavvyRunePanel(self.itemData)
end

function RuneTips:OnForgotten()
    self.model:Closetips()
    local forgotten_data = DataRune.data_upgrade_forgotten[BaseUtils.Key(self.itemData.rune_type, self.itemData.rune_lev)]
    local runeData = DataRune.data_rune[BaseUtils.Key(self.itemData.rune_id, self.itemData.rune_lev)]

    local content = string.format(TI18N("遗忘<color='#fff000'>%s·%s</color>后不返还材料，并能学习新的内丹，是否遗忘？"), runeData.name, runeData.lev)
    if forgotten_data.unload_gain > 0 then 
        content = string.format(TI18N("遗忘<color='#fff000'>%s·%s</color>后返还<color='#fff000'>%s个%s</color>，并能学习新的内丹，是否遗忘？"), runeData.name, runeData.lev, forgotten_data.unload_gain, runeData.name)
    end

    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = content
    confirmData.sureLabel = TI18N("确 定")
    confirmData.cancelLabel = TI18N("取 消")
    confirmData.sureCallback = function() PetManager.Instance:Send10577(self.itemData.pet_id, self.itemData.rune_index) end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function RuneTips:OnResonance()
    self.model:Closetips()
    PetManager.Instance.model:OpenPetResonanceRunePanel()
end

function RuneTips:OnHide()
    if self.arrowEffect ~= nil then
        self.arrowEffect:SetActive(false)
    end
end

