GloryInfoPanel = GloryInfoPanel or BaseClass(BasePanel)

function GloryInfoPanel:__init(model, gameObject, assetWrapper)
    self.model = model
    self.name = "GloryInfoPanel"
    self.gameObject = gameObject
    self.mgr = GloryManager.Instance

    self.assetWrapper = assetWrapper

    self.updateInfoListener = function() self:Reload() end
    self.timeListener = function() self:UpdateCoolingDown() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.slotList = {}

    self:InitPanel()
end

function GloryInfoPanel:__delete()
    for k,v in pairs(self.slotList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.slotList = nil

    self.OnHideEvent:Fire()
    self.gameObject = nil
    self.assetWrapper = nil
end

function GloryInfoPanel:InitPanel()
    local t = self.gameObject.transform
    self.transform = t

    self.label = t:Find("Label")
    self.ablePanel = self.label:Find("Able")
    self.coolingPanel = self.ablePanel:Find("CoolingPanel")
    self.coolingTimeText = self.coolingPanel:Find("Time"):GetComponent(Text)
    local btn = self.coolingPanel:Find("Button"):GetComponent(Button)
    btn.onClick:AddListener(function() self.mgr:send14404() end)
    self.challengeBtn = self.ablePanel:Find("Challenge"):GetComponent(Button)
    self.challengeBtn.onClick:RemoveAllListeners()
    self.challengeBtn.onClick:AddListener(function() self.mgr:send14401() end)
    btn = self.label:Find("NotOpen"):GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(self.noticeMsg) end)

    self.honorImage = t:Find("Honor/Image"):GetComponent(Image)
    self.honorText = t:Find("Honor/Name"):GetComponent(Text)
    self.attrAlreadyText = t:Find("Attr/Already/Value"):GetComponent(Text)
    self.rewardTitleText = t:Find("RewardPanel/Title/Text"):GetComponent(Text)
    self.attrSkill = t:Find("Attr/AddPanel")

    self.slotContainerList = {nil, nil, nil, nil}
    for i=1,4 do
        self.slotContainerList[i] = t:Find("RewardPanel/Slot"..tostring(i))
    end

    self.honorImage.gameObject:SetActive(false)
    self.honorText.text = ""

    for k,v in pairs(DataSkillPrac.data_skill) do
        self.attrSkill:Find(tostring(k)):GetComponent(Text).text = "["..v.name.."]"
    end

    self.attrSkill:GetComponent(Button).onClick:AddListener(function()
        local textList = {TI18N("可额外增加冒险技能等级，"), TI18N("不受技能等级上限限制，"), TI18N("完成特定关卡后即可获得。")}
        TipsManager.Instance:ShowText({gameObject = self.attrSkill.gameObject, itemData = textList})
    end)

    self.OnOpenEvent:Fire()
end

function GloryInfoPanel:OnInitCompleted()
end

function GloryInfoPanel:OnOpen()
    self:Reload()

    self:RemoveListeners()
    self.mgr.onUpdateInfo:AddListener(self.updateInfoListener)
    self.mgr.onUpdateTime:AddListener(self.timeListener)
end

function GloryInfoPanel:OnHide()
    self:RemoveListeners()
end

function GloryInfoPanel:RemoveListeners()
    self.mgr.onUpdateInfo:RemoveListener(self.updateInfoListener)
    self.mgr.onUpdateTime:RemoveListener(self.timeListener)
end

function GloryInfoPanel:Reload()
    local model = self.model
    if model.title_id == nil then
        return
    end
    local titleData = DataGlory.data_title[model.title_id]
    if titleData == nil then
        self.honorText.text = TI18N("平民")
        self.honorImage.gameObject:SetActive(true)
        self.honorImage.sprite = self.assetWrapper:GetSprite(AssetConfig.glory_textures, "Glory_1")
        self.attrAlreadyText.text = "0"
    else
        self.honorText.text = titleData.title_name
        self.honorImage.gameObject:SetActive(true)
        self.honorImage.sprite = self.assetWrapper:GetSprite(AssetConfig.glory_textures, "Glory_"..titleData.title_icon)
        if model.level_id == nil or model.level_id == 0 then
            self.attrAlreadyText.text = "0"
        else
            self.attrAlreadyText.text = DataGlory.data_level[model.level_id].all_point

            local skillText = nil
            for _,v in pairs(DataGlory.data_level[model.level_id].skill_prac) do
                skillText = self.attrSkill:Find(tostring(v[1])):GetComponent(Text)
                skillText.color = Color(37/255, 240/255, 247/255)
                skillText.text = "["..DataSkillPrac.data_skill[v[1]].name.."]+"..v[2]
            end
        end
    end
    local itemlist = {}

    local data = model.selectData
    if data == nil then
        return
    end

    if data.title ~= nil and data.title > 0 then
        table.insert(itemlist, {data.title, 1})
    end
    if data.skill_prac_lev ~= nil and #data.skill_prac_lev > 0 then
        for i=1,#data.skill_prac_lev do
            table.insert(itemlist, data.skill_prac_lev[i])
        end
    end
    if data.point ~= nil and data.point > 0 then
        table.insert(itemlist, {22616, data.point})
    end

    self.rewardTitleText.text = string.format(TI18N("第%s关奖励"), tostring(data.id))

    local classes = RoleManager.Instance.RoleData.classes
    local sex = RoleManager.Instance.RoleData.sex
    local gain = DataGlory.data_gain[data.id.."_"..classes.."_"..sex]
    if gain == nil then
        gain = DataGlory.data_gain[data.id.."_0_"..sex]
        if gain == nil then
            gain = DataGlory.data_gain[data.id.."_"..classes.."_2"]
        end
        if gain == nil then
            gain = DataGlory.data_gain[data.id.."_0_2"]
        end
    end
    if gain ~= nil then
        for i=1,#gain.gain do
            table.insert(itemlist, {gain.gain[i][1], gain.gain[i][3]})
        end
    end

    for i=1,4 do
        if itemlist[i] ~= nil then
            if self.slotList[i] == nil then
                self.slotList[i] = ItemSlot.New()
            end
            self.slotContainerList[i].gameObject:SetActive(true)
            local itemData = ItemData.New()
            -- print(itemlist[i][1])
            itemData:SetBase(DataItem.data_get[itemlist[i][1]])
            itemData.quantity = itemlist[i][2]
            self.slotList[i]:SetAll(itemData, {inbag = false, nobutton = true})
            NumberpadPanel.AddUIChild(self.slotContainerList[i].gameObject, self.slotList[i].gameObject)
        else
            self.slotContainerList[i].gameObject:SetActive(false)
        end
    end

    if model.level_id >= data.id then     -- 已通关
        self.label:Find("Passed").gameObject:SetActive(true)
        -- self.label:Find("Challenge").gameObject:SetActive(false)
        self.label:Find("NotOpen").gameObject:SetActive(false)
        self.ablePanel.gameObject:SetActive(false)
    else
        if RoleManager.Instance.RoleData.lev >= data.need_lev then        -- 达到等级，已通关前面关卡，可挑战
            if model.level_id + 1 == data.id then
                self.label:Find("Passed").gameObject:SetActive(false)
                -- self.label:Find("Challenge").gameObject:SetActive(true)
                self.label:Find("NotOpen").gameObject:SetActive(false)
                self.ablePanel.gameObject:SetActive(true)
                self:UpdateCoolingDown()
                self.noticeMsg = ""
            else
                self.label:Find("NotOpen/Text"):GetComponent(Text).text = string.format(TI18N("请完成第%s关"), tostring(data.id - 1))
                self.label:Find("NotOpen").gameObject:SetActive(true)
                -- self.label:Find("Challenge").gameObject:SetActive(false)
                self.label:Find("Passed").gameObject:SetActive(false)
                self.ablePanel.gameObject:SetActive(false)
                self.noticeMsg = TI18N("请通关前面关卡")
            end
        else                                            -- 未达到等级
            self.noticeMsg = data.need_lev..TI18N("级再来挑战吧")
            self.label:Find("NotOpen/Text"):GetComponent(Text).text = data.need_lev..TI18N("级开启")
            self.label:Find("NotOpen").gameObject:SetActive(true)
            -- self.label:Find("Challenge").gameObject:SetActive(false)
            self.label:Find("Passed").gameObject:SetActive(false)
            self.ablePanel.gameObject:SetActive(false)
        end
    end
end

function GloryInfoPanel:UpdateCoolingDown()
    local model = self.model
    if model.end_time ~= nil and model.end_time ~= 0 and model.end_time - BaseUtils.BASE_TIME > 0 then
        self.coolingPanel.gameObject:SetActive(true)
        self.challengeBtn.gameObject:SetActive(false)
        self.coolingTimeText.text = os.date("00:%M:%S", model.end_time - BaseUtils.BASE_TIME)
    else
        self.coolingPanel.gameObject:SetActive(false)
        self.challengeBtn.gameObject:SetActive(true)
    end
end

