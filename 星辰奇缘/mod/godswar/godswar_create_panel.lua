-- --------------------------------
-- 诸神之战 创建战队界面
-- hosr
-- --------------------------------
GodsWarCreatePanel = GodsWarCreatePanel or BaseClass(BasePanel)

function GodsWarCreatePanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.godswarcreate, type = AssetType.Main},
	}
end

function GodsWarCreatePanel:__delete()
end

function GodsWarCreatePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarcreate))
    self.gameObject.name = "GodsWarCreatePanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.input = self.transform:Find("Main/InputField"):GetComponent(InputField)
    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() self:Create() end)
    self.tips = self.transform:Find("Main/Tips"):GetComponent(Text)
    self.tips.text = TI18N("至少2人组队方可创建")
end

function GodsWarCreatePanel:Create()
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

	GodsWarManager.Instance:Send17901(name)
	self:Close()
end

function GodsWarCreatePanel:Close()
	GodsWarManager.Instance.model:CloseCreate()
end