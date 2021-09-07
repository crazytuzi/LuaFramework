-- ------------------------------
-- 孩子天赋预览 tips
-- hosr
-- ------------------------------

PetChildTelentPreview = PetChildTelentPreview or BaseClass(BasePanel)

function PetChildTelentPreview:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.childtelentpreview, type = AssetType.Main},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
	}
end

function PetChildTelentPreview:__delete()
end

function PetChildTelentPreview:OnShow()
	self.skillid = self.openArgs.skillid
	self.skilllev = self.openArgs.skilllev
	self:Update()
end

function PetChildTelentPreview:OnHide()
end

function PetChildTelentPreview:Close()
	self.model:CloseChildPreview()
end

function PetChildTelentPreview:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childtelentpreview))
    self.gameObject.name = "PetChildTelentPreview"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.normal = self.transform:Find("Normal").gameObject
    self.full = self.transform:Find("Full").gameObject

    self.normalDesc1 = self.transform:Find("Normal/Desc1"):GetComponent(Text)
    self.transform:Find("Normal/Desc1/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon4")
    self.normalDesc2 = self.transform:Find("Normal/Desc2"):GetComponent(Text)
    self.transform:Find("Normal/Desc2/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon4")

    self.fullDesc = self.transform:Find("Full/Desc2"):GetComponent(Text)
    self.transform:Find("Full/Desc2/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon4")

    self:OnShow()
end

function PetChildTelentPreview:Update()
	if self.skilllev == 5 then
		self.full:SetActive(true)
		self.normal:SetActive(false)
		local currSkill = DataSkill.data_child_telent[string.format("%s_%s", self.skillid, self.skilllev)]
		self.fullDesc.text = ""
		if currSkill ~= nil then
			self.fullDesc.text = currSkill.desc
		end
	else
		self.full:SetActive(false)
		self.normal:SetActive(true)
		local currSkill = DataSkill.data_child_telent[string.format("%s_%s", self.skillid, self.skilllev + 1)]
		local maxSkill = DataSkill.data_child_telent[string.format("%s_%s", self.skillid, 5)]
		self.normalDesc1.text = ""
		self.normalDesc2.text = ""

		if currSkill ~= nil then
			self.normalDesc1.text = currSkill.desc
		end

		if maxSkill ~= nil then
			self.normalDesc2.text = maxSkill.desc
		end
	end
end