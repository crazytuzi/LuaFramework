-- -----------------------------
-- 诸神之战 修改战队名称
-- hosr
-- -----------------------------
GodsWarRenamePanel = GodsWarRenamePanel or BaseClass(BasePanel)

function GodsWarRenamePanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.godswarcreate, type = AssetType.Main},
	}
end

function GodsWarRenamePanel:__delete()
end

function GodsWarRenamePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarcreate))
    self.gameObject.name = "GodsWarRenamePanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.title = self.transform:Find("Main/Title/Text"):GetComponent(Text)
    self.title.text = TI18N("战队改名")
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.input = self.transform:Find("Main/InputField"):GetComponent(InputField)
    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() self:Create() end)

    self.tips = self.transform:Find("Main/Tips"):GetComponent(Text)
    self.tips.text = TI18N("仅能在报名期间改名")

    self.input.text = GodsWarManager.Instance.myData.name
end

function GodsWarRenamePanel:Create()
	local name = self.input.text
	if name == "" then
		NoticeManager.Instance:FloatTipsByString(TI18N("请输入战队名称"))
		return
	end

	local list = StringHelper.ConvertStringTable(name)
	if #list > 5 then
		NoticeManager.Instance:FloatTipsByString(TI18N("战队名称最长5个字"))
		return
	elseif #list < 2 then
		NoticeManager.Instance:FloatTipsByString(TI18N("战队名称最短2个字"))
		return
	end

	if name ~= GodsWarManager.Instance.myData.name then
		GodsWarManager.Instance:Send17912(name)
	end

	self:Close()
end

function GodsWarRenamePanel:Close()
	GodsWarManager.Instance.model:CloseRename()
end