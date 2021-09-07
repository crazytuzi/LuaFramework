--------------------------------------------------------
-- 挂机按钮区域
-- ljh 2017.1.10
--------------------------------------------------------
AutoFarmButtonArea  =  AutoFarmButtonArea or BaseClass(BasePanel)

function AutoFarmButtonArea:__init(model)
    self.name  =  "AutoFarmButtonArea"
    self.model  =  model
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.autofarmbuttonarea, type  =  AssetType.Main}
        , {file  =  AssetConfig.autofarm_textures, type  =  AssetType.Dep}
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self._Update = function() self:Update() end

    return self
end

function AutoFarmButtonArea:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function AutoFarmButtonArea:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.autofarmbuttonarea))
    self.gameObject:SetActive(false)
    self.gameObject.name = "AutoFarmButtonArea"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(MainUIManager.Instance.MainUIIconView.transform:FindChild("ButtonPanel2").gameObject, self.gameObject)

    self.rect = self.transform:GetComponent(RectTransform)
    self.rect.anchorMax = Vector2(0, 1)
    self.rect.anchorMin = Vector2(0, 1)
    self.rect.anchoredPosition = Vector3(160, -180, 0)

    self.autoFarmButton = self.transform:FindChild("AutoFarmButton")
    self.ancientDemonsButton = self.transform:FindChild("AncientDemonsButton")

    self.autoFarmFontImage = self.transform:FindChild("AutoFarmButton/Text2").gameObject
    self.ancientDemonsFontImage = self.transform:FindChild("AncientDemonsButton/Text2").gameObject

    self.ancientDemonsNumImage = self.transform:FindChild("AncientDemonsButton/NumImage").gameObject
    self.ancientDemonsNumText = self.transform:FindChild("AncientDemonsButton/NumText"):GetComponent(Text)

    self.autoFarmButton:GetComponent(Button).onClick:AddListener(function() self:OnAutoFarmButtonClick() end)
    self.ancientDemonsButton:GetComponent(Button).onClick:AddListener(function() self:OnAncientDemonsButtonClick() end)

    self:OnShow()
end

function AutoFarmButtonArea:OnShow()
    if self.openArgs then
    	self.autoFarmButton.gameObject:SetActive(false)
    	self.ancientDemonsButton.localPosition = Vector3(40, 0, 0)
        self:Update()
    else
    	self.autoFarmButton.gameObject:SetActive(true)
    	self.ancientDemonsButton.localPosition = Vector3(40, -60, 0)
        self:Update()
    end

    AutoFarmManager.Instance.OnUpdate:Add(self._Update)
    EventMgr.Instance:AddListener(event_name.agenda_update, self._Update)
    if AgendaManager.Instance.model.autoPathFight then
        self:OnAncientDemonsButtonClick()
        AgendaManager.Instance.model.autoPathFight = false
    end
end

function AutoFarmButtonArea:OnHide()
    AutoFarmManager.Instance.OnUpdate:Remove(self._Update)
    EventMgr.Instance:RemoveListener(event_name.agenda_update, self._Update)
end

function AutoFarmButtonArea:Update()
    if AutoFarmManager.Instance.Farming then
        self.autoFarmFontImage:SetActive(true)
    else
        self.autoFarmFontImage:SetActive(false)
    end
    if AutoFarmManager.Instance.FarmingAncientDemons then
        self.ancientDemonsFontImage:SetActive(true)
    else
        self.ancientDemonsFontImage:SetActive(false)
    end

    for k,v in pairs(AgendaManager.Instance.day_list) do
        if v.id == 1014 then
            if v.engaged == v.max_try then
                self.ancientDemonsNumImage:SetActive(false)
                self.ancientDemonsNumText.text = ""
            else
                self.ancientDemonsNumImage:SetActive(true)
                self.ancientDemonsNumText.text = string.format("%s/%s", v.engaged, v.max_try)
            end
        end
    end

    local currmapid = SceneManager.Instance:CurrentMapId()
    local data_map = nil
    for k,v in ipairs(DataTreasure.data_map) do
        if currmapid == v.map_base_id then
            data_map = v
        end
    end
    if data_map ~= nil and data_map.min_lev > RoleManager.Instance.RoleData.lev then
        self.ancientDemonsButton.gameObject:SetActive(false)
    else
        self.ancientDemonsButton.gameObject:SetActive(true)
    end
end

function AutoFarmButtonArea:OnAutoFarmButtonClick()
    if RoleEumn.TeamStatus.Follow == TeamManager.Instance:MyStatus() then
        NoticeManager.Instance:FloatTipsByString(TI18N("您当前处于归队状态，无法开始野外挂机"))
        return
    end
	if RoleManager.Instance.RoleData.cross_type == 1 then
	    NoticeManager.Instance:FloatTipsByString(TI18N("跨服暂不支持巡逻挂机"))
	    return
	end
	if AutoFarmManager.Instance.Farming then
		NoticeManager.Instance:FloatTipsByString(TI18N("野外挂机已结束"))
	    AutoFarmManager.Instance:stopFarm()
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("开始野外挂机"))
	    AutoFarmManager.Instance:startautoFarm()
	end
    self:Update()
end

function AutoFarmButtonArea:OnAncientDemonsButtonClick()
    if RoleEumn.TeamStatus.Follow == TeamManager.Instance:MyStatus() then
        NoticeManager.Instance:FloatTipsByString(TI18N("您当前处于归队状态，无法开始搜寻上古妖魔"))
        return
    end
	if AutoFarmManager.Instance.FarmingAncientDemons then
	    AutoFarmManager.Instance:StopAncientDemons()
	else
	    AutoFarmManager.Instance:StarAncientDemons(true)
	end
    self:Update()
end

