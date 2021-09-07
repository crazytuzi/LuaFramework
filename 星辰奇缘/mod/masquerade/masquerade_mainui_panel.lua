-- @author 黄耀聪
-- @date 2016年7月1日

MasqueradeMainUIPanel = MasqueradeMainUIPanel or BaseClass(BasePanel)

function MasqueradeMainUIPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "MasqueradeMainUIPanel"
    self.mgr = MasqueradeManager.Instance

    self.resList = {
        {file = AssetConfig.masquerade_mainui_panel, type = AssetType.Main},
        {file = AssetConfig.masquerade_textures, type = AssetType.Dep},
    }

    self.looksListener = function() end
    self.progressListener = function() self:UpdateProgess() end
    self.fightListener = function() self:OnFight() end
    self.peaceListener = function() self:OnPeace() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MasqueradeMainUIPanel:__delete()
    self.OnHideEvent:Fire()
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MasqueradeMainUIPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.masquerade_mainui_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.slider = t:Find("Main/Slider"):GetComponent(Slider)
    self.progressText = t:Find("Main/ProgressText"):GetComponent(Text)
    self.iconImage = t:Find("Main/HandleBg/Icon"):GetComponent(Image)
    self.descText = t:Find("Main/Desc/Text"):GetComponent(Text)
    self.descRect = t:Find("Main/Desc"):GetComponent(RectTransform)
    t:Find("Main/Desc"):GetComponent(RectTransform).anchoredPosition = Vector2(-4.6, 11.1)
    t:Find("Main/Desc"):GetComponent(RectTransform).sizeDelta = Vector2(219.77, 26.6)

    self.descText.verticalOverflow = 1
end

function MasqueradeMainUIPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MasqueradeMainUIPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_looks_change, self.looksListener)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.fightListener)
    EventMgr.Instance:AddListener(event_name.end_fight, self.peaceListener)
    self.mgr.onUpdateMy:AddListener(self.progressListener)

    self.iconImage.gameObject:SetActive(false)
    self:UpdateProgess()

    if CombatManager.Instance.isFighting then
        self:OnFight()
    else
        self:OnPeace()
    end

    MasqueradeManager.Instance:send16504()
end

function MasqueradeMainUIPanel:OnHide()
    self:RemoveListeners()
end

function MasqueradeMainUIPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_looks_change, self.looksListener)
    self.mgr.onUpdateMy:RemoveListener(self.progressListener)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.fightListener)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.peaceListener)
end

function MasqueradeMainUIPanel:UpdateProgess()
    local model = self.model
    self.progressText.text = tostring(0) .. "/" .. tostring(model.floorToDiff[1])
    self.slider.value = 0
    if model.myInfo == nil or model.myInfo.map_base_id == nil or DataElf.data_map[model.myInfo.map_base_id] == nil then
        return
    end
    local floor = DataElf.data_map[model.myInfo.map_base_id].id

    local _pre_score = 0
    if DataElf.data_floor[floor - 1] ~= nil then
        _pre_score = DataElf.data_floor[floor - 1].next_score
    end
    -- print("floor="..tostring(floor))
    -- print("_pre_score="..tostring(_pre_score))
    -- print("model.floorToDiff[floor]="..tostring(model.floorToDiff[floor]))
    -- print("model.myInfo.score="..tostring(model.myInfo.score))
    -- if model.floorToDiff[floor] ~= _pre_score then
    if model.myInfo.score >= DataElf.data_floor[model.max_floor].grade_score then
        local diff = model.myInfo.score - DataElf.data_floor[model.max_floor].grade_score   -- 我的分数 - 进阶所需分数
        local total = DataElf.data_floor[model.max_floor].max_score - DataElf.data_floor[model.max_floor].grade_score   -- 第5层分数段
        if total < diff then
            self.slider.value = 1
            self.progressText.text = tostring(total) .. "/" .. tostring(total)
        else
            self.slider.value = diff / total
            self.progressText.text = tostring(diff) .. "/" .. tostring(total)
        end
    else
        self.slider.value = (model.myInfo.score - _pre_score) / (model.floorToDiff[floor])
        self.progressText.text = tostring(model.myInfo.score - _pre_score) .. "/" .. tostring(model.floorToDiff[floor])
    end

    local iconId = DataElf.data_floor[floor].buff_icon_id
    if self.headLoader == nil then
        self.headLoader = SingleIconLoader.New(self.iconImage.gameObject)
    end
    self.headLoader:SetSprite(SingleIconType.Pet,iconId)
    -- self.iconImage.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(iconId), iconId)
    self.iconImage.gameObject:SetActive(true)
end

function MasqueradeMainUIPanel:OnFight()
    local model = self.model
    self.descRect.sizeDelta = Vector2(220, 24)
    if model.myInfo.score >= DataElf.data_floor[model.max_floor].grade_score then
        self.descText.text = DataBuff.data_list[DataElf.data_floor[model.max_floor].grade_buff_id].desc
    else
        self.descText.text = (DataBuff.data_list[(DataElf.data_map[model.myInfo.map_base_id] or {}).buff_id] or {}).desc or TI18N("战胜<color='#00ff00'>匹配对手</color>或<color='#00ff00'>采集</color>可提升进度")
    end
    self.descRect.sizeDelta = Vector2(self.descText.preferredWidth + 15, self.descText.preferredHeight + 8)
end

function MasqueradeMainUIPanel:OnPeace()
    self.descRect.sizeDelta = Vector2(220, 24)
    self.descText.text = TI18N("战胜<color='#00ff00'>匹配对手</color>或<color='#00ff00'>采集</color>可提升进度")
    self.descRect.sizeDelta = Vector2(self.descText.preferredWidth + 20, self.descText.preferredHeight + 10)
end



