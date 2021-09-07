-- -------------------------------
-- 幻化信息展示界面
-- hosr
-- -------------------------------
HandbookInfoPanel = HandbookInfoPanel or BaseClass(BasePanel)

function HandbookInfoPanel:__init(parent)
	self.parent = parent

	self.resList = {
		{file = AssetConfig.handbook_info, type = AssetType.Main},
		{file = AssetConfig.handbook_res, type = AssetType.Dep},
		-- {file = AssetConfig.bigatlas_taskBg, type = AssetType.Main},
		{file = AssetConfig.handbookBg, type = AssetType.Dep},
		{file = AssetConfig.attr_icon, type = AssetType.Dep},
		{file = AssetConfig.handbookmatch, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.currIndex = 1

    self.collect = nil
    self.change = nil
    self.currPreviewId = 0
    self.isInit = false
end

function HandbookInfoPanel:__delete()
	if self.previewComp ~= nil then
		self.previewComp:DeleteMe()
		self.previewComp = nil
	end

	if self.collect ~= nil then
		self.collect:DeleteMe()
		self.collect = nil
	end
end

function HandbookInfoPanel:OnShow()
	self.parent:DefaultSelect()
	if self.previewComp ~= nil then
		self.previewComp:Show()
	end
end

function HandbookInfoPanel:OnHide()
	if self.previewComp ~= nil then
		self.previewComp:Hide()
	end
end

function HandbookInfoPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.handbook_info))
    self.gameObject.name = "HandbookInfoPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(-15, 15)

    self.collect = HandbookInfoCollect.New(self.transform:Find("Collect").gameObject, self)
    -- local taskBg = GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_taskBg))
    -- UIUtils.AddBigbg(self.transform:Find("Collect/Bg"), taskBg)
    -- taskBg.transform.localPosition = Vector2(-153, 71.5)

    self.transform:Find("Preview"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.handbookBg, "HandbookBg")
    self.previewName = self.transform:Find("Preview/Name"):GetComponent(Text)
    self.preview = self.transform:Find("Preview/View").gameObject
    self.fight = self.transform:Find("Preview/Fight/Val")
    self.fightTxt = self.fight:GetComponent(Text)
    self.fightRect = self.fight:GetComponent(RectTransform)

    self.callback = function(composite)
	    self:SetRawImage(composite)
	end

    self.setting = {
        name = "Handbook"
        ,orthographicSize = 0.6
        ,width = 200
        ,height = 250
        ,offsetY = -0.3
    }

    self.isInit = true
    self.collect:Show()
   	self:OnShow()
end

function HandbookInfoPanel:Update(data)
	self.data = data
	self:UpdatePreview()
	self:UpdateFight()

	if self.collect.isShow then
		self.collect:Update()
	end
end

function HandbookInfoPanel:UpdateFight()
	self.handbook = HandbookManager.Instance:GetDataById(self.data.id)
	if self.handbook ~= nil then
		if self.handbook.star_step == 1 and self.data.fc1 > 0 then
			self.fightTxt.text = string.format(TI18N("战力:%s"), self.data.fc1)
		elseif self.handbook.star_step == 2 and self.data.fc2 > 0 then
			self.fightTxt.text = string.format(TI18N("战力:%s"), self.data.fc2)
		else
			self.fightTxt.text = string.format(TI18N("战力:%s"), self.data.fc)
		end
	else
		self.fightTxt.text = string.format(TI18N("战力:%s"), self.data.fc)
	end

	local w = self.fightTxt.preferredWidth
	local h = 30
	self.fightRect.sizeDelta = Vector2(w, h)
	self.fightRect.anchoredPosition = Vector2.one
end

function HandbookInfoPanel:UpdatePreview()
	if self.currPreviewId == self.data.preview_id then
		return
	end

	self.currPreviewId = self.data.preview_id
	local modelData = nil
	if self.data.effect_type == HandbookEumn.EffectType.Pet then
		local pet = DataPet.data_pet[self.data.preview_id]
		if pet ~= nil then
			self.previewName.text = pet.name
			modelData = {type = PreViewType.Pet, skinId = pet.skin_id_0, modelId = pet.model_id, animationId = pet.animation_id, effects = pet.effects_0, scale = pet.scale / 100}
		end
		if self.data.preview_id == 20018 then 
			modelData.scale = pet.scale / 150
		end
	elseif self.data.effect_type == HandbookEumn.EffectType.Guard then
		local guard = DataShouhu.data_guard_base_cfg[self.data.preview_id]
		if guard ~= nil then
			self.previewName.text = guard.alias
			modelData = {type = PreViewType.Shouhu, skinId = guard.paste_id, modelId = guard.res_id, animationId = guard.animation_id, scale = guard.scale / 100}
		end
	elseif self.data.effect_type == HandbookEumn.EffectType.NPC then
		local npc = DataUnit.data_unit[self.data.preview_id]
		if npc ~= nil then
			self.previewName.text = npc.name
			modelData = {type = PreViewType.Npc, skinId = npc.skin, modelId = npc.res, animationId = npc.animation_id, scale = npc.scale / 100}
			if self.data.preview_id == 32004 or self.data.preview_id == 32031 then
				--龙王这货太大了
				modelData.scale = npc.scale / 150
			end
		end
	end

	if modelData == nil then
		return
	end

    if self.previewComp == nil then
    	self.previewComp = PreviewComposite.New(self.callback, self.setting, modelData)
    else
    	self.previewComp:Reload(modelData, self.callback)
    end
    self.previewComp:Show()
end

function HandbookInfoPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.identity
    composite.tpose.transform:Rotate(Vector3(0, -30, 0))
    self.preview:SetActive(true)
end
