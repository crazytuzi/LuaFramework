PrewarPanel = PrewarPanel or BaseClass(BasePanel)

function PrewarPanel:__init(model)
    self.model = model
    self.name = "PrewarPanel"

    self.buffItemObjList = {}

    self.resList = {
        {file = AssetConfig.prewarpanel, type = AssetType.Main}
        ,{file = AssetConfig.notnamedtreasure_textures, type = AssetType.Dep}
        ,{file = AssetConfig.normalbufficon, type = AssetType.Dep}
    }

    self._Update = function() self:Update() end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    --------------------------------------
end

function PrewarPanel:__delete()
    self:OnHide() 

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function PrewarPanel:InitPanel()
    if ImproveManager.Instance.model.improveWin == nil then
        self:AssetClearAll()
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.prewarpanel))
	-- UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    UIUtils.AddUIChild(ImproveManager.Instance.model.improveWin.gameObject, self.gameObject)
    self.transform = self.gameObject.transform

    if CombatManager.Instance.isFighting then
        self.transform.localPosition = Vector3(60, 0, 0)
    else
        -- self.transform.localPosition = Vector3(42, -43, 0)
        local icon = MainUIManager.Instance.MainUIIconView:getbuttonbyid(17)
        self.transform.position = icon.transform.position

        self.transform.localPosition = Vector3(self.transform.localPosition.x + 317, -43, 0)
    end

    -- self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Panel").gameObject:SetActive(false)
    local layoutContainer = self.transform:Find("Main/Mask/ItemGrid")

    self.item1 = layoutContainer:Find("Item1")
    self.item2 = layoutContainer:Find("Item2")
    self.item3 = layoutContainer:Find("Item3")

    --------------------------------------
    self.item1:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:ClickItem1() end)

    --------------------------------------
    self.item2:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:ClickItem2() end)
    
    self.item2:Find("SkillText").gameObject:AddComponent(Button)

    self.transformToggle = self.item2:FindChild("Toggle"):GetComponent(Toggle)
    self.transformToggle.isOn = not SceneManager.Instance.sceneElementsModel.Show_Transform_Mark
    self.transformToggle.onValueChanged:AddListener(function(on) self:onTransformToggleChange(on) end)
    
    --------------------------------------
    self.item3:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:ClickItem3() end)

    --------------------------------------
    self:OnShow()
end

function PrewarPanel:OnShow()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self._Update)
    EventMgr.Instance:AddListener(event_name.buff_update, self._Update)
    GuildManager.Instance:request11192()

    self:Update()
end

function PrewarPanel:OnHide()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._Update)
    EventMgr.Instance:RemoveListener(event_name.buff_update, self._Update)
end

function PrewarPanel:Close()
    self.model:ClosePrewarPanel()
end

function PrewarPanel:Update()
    local glyphsList = {}
    local transform_buff_id = nil
    local rolePrayMark = nil
    local petPrayMark = nil

    for key, buffData in pairs(self.model.buffDic) do
        local glyphs_data = DataBuff.data_prewar[buffData.id]
        if glyphs_data then
            glyphsList[glyphs_data.type] = buffData
        end

        local buffConfig = DataBuff.data_list[buffData.id]
        if buffConfig ~= nil and buffConfig.pvp_limit ~= nil and buffConfig.pvp_limit > 0 then
            transform_buff_id = buffData.id
        end
    end

    if self.model.buffDic[31000] then
        rolePrayMark = true
    end

    if self.model.buffDic[31001] then
        petPrayMark = true
    end

    local roleData = RoleManager.Instance.RoleData
    --------------------------------------
    self:UpdateItem1(glyphsList)

    --------------------------------------
    self:UpdateItem2(transform_buff_id)

    --------------------------------------
    if roleData.lev >= 65 then
        self:UpdateItem3(rolePrayMark, petPrayMark)
    else
        self.item3.gameObject:SetActive(false)
    end

    --------------------------------------
    
    if roleData.lev >= 65 then
        self.item3:Find("Line").gameObject:SetActive(false)
    else
        self.item2:Find("Line").gameObject:SetActive(false)
    end
end

function PrewarPanel:UpdateItem1(glyphsList)
    for i = 1, 7 do
        local imageColor = Color.white
        local textColor = Color.green
        if glyphsList[i] == nil then
            imageColor = Color(143/255, 143/255, 143/255)
            textColor = Color(180/255, 180/255, 180/255)
        else
            local time = (glyphsList[i].duration- BaseUtils.BASE_TIME + glyphsList[i].start_time)
            if time < 1800 then
                textColor = Color.red
            end
        end
        self.item1:Find(string.format("AttrItem%s", i)):GetComponent(Image).color = imageColor
        self.item1:Find(string.format("AttrItem%s/Text", i)):GetComponent(Text).color = textColor
    end
end

function PrewarPanel:UpdateItem2(transform_buff_id)
    if transform_buff_id ~= nil then
        local buffData = self.model.buffDic[transform_buff_id]
        local buffConfig = DataBuff.data_list[transform_buff_id]
        local timeText = ""
        local time = (buffData.duration- BaseUtils.BASE_TIME + buffData.start_time)
        if time < 3600 then
            timeText = string.format(TI18N("剩余%s分钟"), tostring(math.ceil(time/60)))
        elseif time < 3600 * 10 then
            timeText = string.format(TI18N("剩余%s小时%s分钟"), tostring(math.floor(time/3600)),tostring(math.floor(time%3600/60)))
        elseif time < 3600 * 24 then
            timeText = string.format(TI18N("剩余%s小时"), tostring(math.floor(time/3600)))
        else
            timeText = string.format(TI18N("剩余%s天"), tostring(math.floor(time/3600/24)))
        end

        local attrText = ""
        for i,v in ipairs(buffConfig.attr) do
            local name = KvData.attr_name[v.attr_type]
            local value = v.val
            if value > 0 then
                value = string.format("+%s%s", v.val/10, "%")
            else
                value = string.format("%s%s", v.val/10, "%")
            end
            
            if i == 1 then
                attrText = string.format("%s %s", tostring(name), tostring(value))
            else
                attrText = string.format("%s, %s %s", attrText, tostring(name), tostring(value))
            end
        end

        self.item2:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffConfig.icon))
        self.item2:Find("NameText"):GetComponent(Text).text = buffConfig.name
        if #buffConfig.effect > 0 then
            local skillData = DataSkill.data_skill_other[buffConfig.effect[1].val]
            local skillname = skillData.name
            self.item2:Find("SkillText"):GetComponent(Text).text = string.format(TI18N("技能： <color='#00ffff'>[%s]</color>"), skillname)
            local skillTextButton = self.item2:Find("SkillText").gameObject
            local info = {gameObject = skillTextButton, skillData = skillData, type = Skilltype.petskill}
            skillTextButton:GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowSkill(info, true) end)
            skillTextButton:GetComponent(Button).enabled = true
        else
            self.item2:Find("SkillText"):GetComponent(Text).text = TI18N("技能： 无")
            local skillTextButton = self.item2:Find("SkillText").gameObject
            skillTextButton:GetComponent(Button).enabled = false
        end

        self.item2:Find("AttrsText"):GetComponent(Text).text = string.format(TI18N("属性： <color='#00ff00'>%s</color>"), attrText)
        self.item2:Find("LooksTimesText"):GetComponent(Text).text = string.format(TI18N("剩余次数： <color='#00ff00'>%s</color>"), buffConfig.pvp_limit + HomeManager.Instance.model:geteffecttypevalue(15) - buffData.pvped)
        self.item2:Find("TimeText"):GetComponent(Text).text = timeText

        self.item2:Find("Icon").gameObject:SetActive(true)
        self.item2:Find("NameText").gameObject:SetActive(true)
        self.item2:Find("SkillText").gameObject:SetActive(true)
        self.item2:Find("AttrsText").gameObject:SetActive(true)
        self.item2:Find("LooksTimesText").gameObject:SetActive(true)
        self.item2:Find("TimeText").gameObject:SetActive(true)

        self.item2:Find("NoBuffTips").gameObject:SetActive(false)
    else
        self.item2:Find("Icon").gameObject:SetActive(false)
        self.item2:Find("NameText").gameObject:SetActive(false)
        self.item2:Find("SkillText").gameObject:SetActive(false)
        self.item2:Find("AttrsText").gameObject:SetActive(false)
        self.item2:Find("LooksTimesText").gameObject:SetActive(false)
        self.item2:Find("TimeText").gameObject:SetActive(false)

        self.item2:Find("NoBuffTips").gameObject:SetActive(true)
    end
end

function PrewarPanel:UpdateItem3(rolePrayMark, petPrayMark)
    local tempData = GuildManager.Instance.model.prayElementData
    if tempData ~= nil then
        local rolePraEndTime = 0
        local petPraEndTime = 0
        for k, v in pairs(tempData.element_attr) do
            if rolePrayMark and v.effect_obj == 1 then
                rolePraEndTime  = v.end_time - BaseUtils.BASE_TIME
            elseif petPrayMark and v.effect_obj == 2 then
                petPraEndTime  = v.end_time - BaseUtils.BASE_TIME
            end
        end

        local timeText = TI18N("角色祈福：    <color='#b4b4b4'>暂无祈福效果</color>")
        if rolePraEndTime > 2  then
            local time = rolePraEndTime
            
            if time < 3600 then
                timeText = string.format(TI18N("角色祈福：    <color='#00ff00'>剩余%s分钟</color>"), tostring(math.ceil(time/60)))
            elseif time < 3600 * 10 then
                timeText = string.format(TI18N("角色祈福：    <color='#00ff00'>剩余%s小时%s分钟</color>"), tostring(math.floor(time/3600)),tostring(math.floor(time%3600/60)))
            else
                timeText = string.format(TI18N("角色祈福：    <color='#00ff00'>剩余%s小时</color>"), tostring(math.floor(time/3600)))
            end
        end
        self.item3:Find("RoleText"):GetComponent(Text).text = timeText
        self.rolePraEndTime = rolePraEndTime

        timeText = TI18N("宠物祈福：    <color='#b4b4b4'>暂无祈福效果</color>")
        if petPraEndTime > 2  then
            local time = petPraEndTime
            if time < 3600 then
                timeText = string.format(TI18N("宠物祈福：    <color='#00ff00'>剩余%s分钟</color>"), tostring(math.ceil(time/60)))
            elseif time < 3600 * 10 then
                timeText = string.format(TI18N("宠物祈福：    <color='#00ff00'>剩余%s小时%s分钟</color>"), tostring(math.floor(time/3600)),tostring(math.floor(time%3600/60)))
            else
                timeText = string.format(TI18N("宠物祈福：    <color='#00ff00'>剩余%s小时</color>"), tostring(math.floor(time/3600)))
            end
        end
        self.item3:Find("PetText"):GetComponent(Text).text = timeText
        self.petPraEndTime = petPraEndTime
    end
end

function PrewarPanel:ClickItem1()
    local checkFun = function(data) 
        if DataItem.data_quick_backpack[string.format("1_%s", data.base_id)] then
            return true
        end
        return false
    end

    local button3_callback = function() 
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, { 2, 6 })
    end
    BuffPanelManager.Instance.model:OpenGlyphsQuickBackpackWindow({ checkFun = checkFun, showButtonType = 2, button3_callback = button3_callback })
end

function PrewarPanel:ClickItem2()
    local checkFun = function(data) 
        if DataItem.data_quick_backpack[string.format("2_%s", data.base_id)] then
            return true
        end
        return false
    end
    local button1_callback = function() 
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, { 2, 2 })
    end
    local button2_callback = function() 
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop)
    end
    BackpackManager.Instance.mainModel:OpenQuickBackpackWindow({ checkFun = checkFun, showButtonType = 1, button1_callback = button1_callback, button2_callback = button2_callback })
end

function PrewarPanel:onTransformToggleChange(on)
    if on then
        BuffPanelManager.Instance:send12802(0)
    else
        BuffPanelManager.Instance:send12802(1)
    end
end

function PrewarPanel:ClickItem3()
    if GuildManager.Instance.model:has_guild() then
        --有公会
        if RoleManager.Instance.world_lev < 70 then
            NoticeManager.Instance:FloatTipsByString(TI18N("世界等级尚未达到70级"))
        else
            if #GuildManager.Instance.model.my_guild_data.element_info > 0 then
                if self.rolePraEndTime == 0 then
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_pray_window, 1)
                else
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_pray_window, 2)
                end
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("您的公会现在还未开启元素祭坛"))
            end
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("尚未加入公会，无法进行公会祈福"))
    end
end