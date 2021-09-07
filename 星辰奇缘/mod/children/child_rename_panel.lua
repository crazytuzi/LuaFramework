-- ------------------------------------
-- 孩子改名
-- hosr
-- ------------------------------------
ChildRenamePanel = ChildRenamePanel or BaseClass(BasePanel)

function ChildRenamePanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.childrename, type = AssetType.Main},
	}
end

function ChildRenamePanel:__delete()
end

function ChildRenamePanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childrename))
	self.gameObject.name = "ChildRenamePanel"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform

	self.input = self.transform:Find("Main/InputField"):GetComponent(InputField)

	self.sure = self.transform:Find("Main/Confirm").gameObject
	self.sure:GetComponent(Button).onClick:AddListener(function() self:OnSure() end)

	self.sureTxt = self.transform:Find("Main/Confirm/Text").gameObject
	self.goldTxt = self.transform:Find("Main/Confirm/Pay").gameObject
	self.cancel = self.transform:Find("Main/Cancel").gameObject
	self.cancel:GetComponent(Button).onClick:AddListener(function() self:Close() end)

	self.child = self.openArgs

	-- if self.child.name_changed == 0 then
	-- 	self.sureTxt:SetActive(true)
	-- 	self.goldTxt:SetActive(false)
	-- else
		self.sureTxt:SetActive(false)
		self.goldTxt:SetActive(true)
	-- end
end

function ChildRenamePanel:OnSure()
	local name = self.input.text
	local list = StringHelper.ConvertStringTable(name)
	if #list > 6 then
		NoticeManager.Instance:FloatTipsByString(TI18N("名称最长6个字"))
		return
	end
	ChildrenManager.Instance:Require18629(self.child.child_id, self.child.platform, self.child.zone_id, name)
	self:Close()
end

function ChildRenamePanel:Close()
	self.model:CloseRename()
end