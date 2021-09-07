-- 活力使用界面

UseEnergyView = UseEnergyView or BaseClass(BaseWindow)

function UseEnergyView:__init(model)
    self.model = model
    self.name = "UseEnergyView"
    self.windowId = WindowConfig.WinID.skill_use_energy
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.skill_use_energy, type = AssetType.Main}
        , {file = AssetConfig.skill_life_icon, type = AssetType.Dep}
    }

    ------------------------------------------------
    self.transform = nil
    self.Button = nil
    self.txtprobar = nil
    self.bar = nil

    self.data_list = { [1] = {skill_id = 0, icon_id = 0, name = TI18N("打工赚钱"), button = TI18N("打工"), cost = 25, type = 0}
                    , [2] = {skill_id = 10000, icon_id = 10000, name = TI18N("栽培果实"), button = TI18N("栽培"), cost = nil, type = 1}
                    , [3] = {skill_id = 10001, icon_id = 10001, name = TI18N("魔药研制"), button = TI18N("研制"), cost = nil, type = 2}
                    , [4] = {skill_id = 10005, icon_id = 10005, name = TI18N("打造之术"), button = TI18N("打造"), cost = nil, type = 3}
                    , [5] = {skill_id = 10006, icon_id = 10006, name = TI18N("裁缝之术"), button = TI18N("裁缝"), cost = nil, type = 4}
                    , [6] = {skill_id = 10007, icon_id = 10007, name = TI18N("铭刻雕文"), button = TI18N("制作"), cost = nil, type = 5} }
    self.item_list = {}

    ------------------------------------------------
    self._Update = function()
        self:Update()
    end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function UseEnergyView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()

    self:OnHide()
end

function UseEnergyView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.skill_use_energy))
    self.gameObject.name = "UseEnergyView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.Button = self.transform:FindChild("Main/DeseBtn").gameObject
    self.Button:GetComponent(Button).onClick:AddListener( function() self:DeseBtn_Click() end )

 	self.txtprobar = self.transform:FindChild("Main/TxtProBar"):GetComponent(Text)
 	self.bar = self.transform:FindChild("Main/Slider"):GetComponent(Slider)

    local item_object = self.transform:FindChild("Main/Panel/ConItems/Item").gameObject
    local conItems = self.transform:FindChild("Main/Panel/ConItems").gameObject
    local index = 0
    for i = 1, #self.data_list do
    	local item = GameObject.Instantiate(item_object)
        item.transform:SetParent(conItems.transform)
        item.transform.localScale = Vector3.one
        item.transform.localPosition = Vector3(0, 0, 0)
        local rect = item:GetComponent(RectTransform)
        rect.anchorMax = Vector2(0, 1)
        rect.anchorMin = Vector2(0, 1)
        rect.pivot = Vector2(0, 1)
        item:SetActive(false)
    	table.insert(self.item_list, item)

        local btn = item.transform:FindChild("Button").gameObject
        btn:GetComponent(Button).onClick:AddListener(function() self:Button_Click(i) end)
        btn.name = tostring(i)
    end


    ----------------------------------------------

    self:OnShow()
end

function UseEnergyView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function UseEnergyView:OnShow()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self._Update)
    self:Update()
    self:Update_Skill()
end

function UseEnergyView:OnHide()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self._Update)
end

function UseEnergyView:Update()
    if DataAgenda.data_energy_max[RoleManager.Instance.RoleData.lev] == nil then return end

    local max_energy = DataAgenda.data_energy_max[RoleManager.Instance.RoleData.lev].max_energy
    self.txtprobar.text = string.format("%s/%s", RoleManager.Instance.RoleData.energy, max_energy)
    self.bar.value = RoleManager.Instance.RoleData.energy / max_energy
end

function UseEnergyView:Update_Skill()
	local index = 0
    for i = 1, #self.data_list do
    	local item = self.item_list[i]
        -- local rect = item:GetComponent(RectTransform)
        -- rect.anchoredPosition = Vector2(6, -6 - index * 74)
    	table.insert(self.item_list, item)

    	local data = self.data_list[i]
    	if data ~= nil then
    	    local skill_lev = 10000
    	    for _, life_skill in ipairs(self.model.life_skills) do
    	    	if life_skill.id == data.skill_id then
    	    		skill_lev = life_skill.lev
                    if life_skill.producing_cost ~= "" and #life_skill.producing_cost > 0 then
                        data.cost = life_skill.producing_cost[#life_skill.producing_cost][2]
                    end
                    if life_skill.product ~= "" and #life_skill.product > 0 then
                        data.key = life_skill.product[#life_skill.product].key
                    end
    	    	end
    	    end

    	    local lev = 10000
    	    if data.type > 0 then
    	    	for _, data_product_open in pairs(DataSkillLife.data_product_open) do
    	    		if data_product_open.type == data.type and lev > data_product_open.open_lev then
	    	    		lev = data_product_open.open_lev
	    	    	end
    	    	end
    	    end

    	    if skill_lev >= lev then
    	    	index = index + 1
    	    	item:SetActive(true)
    	    else
    	    	item:SetActive(false)
    	    end

            item.transform:FindChild("Image/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.skill_life_icon, tostring(data.icon_id))
            local skill_name = string.format("%s Lv.%s", data.name, skill_lev)
            if data.skill_id == 0 then skill_name = data.name end
            item.transform:FindChild("I18N_Name"):GetComponent(Text).text = skill_name
            item.transform:FindChild("I18N_Desc"):GetComponent(Text).text = string.format(TI18N("消耗活力：%s"), data.cost or 0)
            item.transform:FindChild(i.."/Text"):GetComponent(Text).text = data.button
	    end
    end
end

function UseEnergyView:DeseBtn_Click()
    if self.transform == nil then return end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill, {3})
end

function UseEnergyView:Button_Click(id)
	local id = tonumber(id)
	local data = self.data_list[id]

	if data ~= nil then
		if RoleManager.Instance.RoleData.energy >= data.cost then
			local skill_id = data.skill_id
			if skill_id == 0 then
				AgendaManager.Instance:Require12007()
            elseif skill_id == 10005 or skill_id == 10006 then
                SkillManager.Instance:Send10816(skill_id, data.key)
			else
				SkillManager.Instance:Send10810(skill_id)
			end
		else
            NoticeManager.Instance:FloatTipsByString(TI18N("活力值不足!"))
		end
	end
end