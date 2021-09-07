-- -----------------------------------
-- 诸神之战公告修改界面
-- hosr
-- -----------------------------------

GodsWarNoticePanel = GodsWarNoticePanel or BaseClass(BasePanel)

function GodsWarNoticePanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.godswarnotice, type = AssetType.Main},
	}
	self.isChange = false
end

function GodsWarNoticePanel:__delete()
end

function GodsWarNoticePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarnotice))
    self.gameObject.name = "GodsWarNoticePanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.input = self.transform:Find("Main/InputField"):GetComponent(InputField)
    self.input.onValueChange:AddListener(function() self:TextUpdate() end)
    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() self:Sure() end)

    self.tips = self.transform:Find("Main/Text"):GetComponent(Text)

    self.input.text = GodsWarManager.Instance.myData.declaration
end

function GodsWarNoticePanel:Sure()
	if self.isChange then
		local name = self.input.text
		if name == "" then
			name = TI18N("暂无公告")
		end
		GodsWarManager.Instance:Send17913(name)
	end

	self:Close()
end

function GodsWarNoticePanel:Close()
	self.model:CloseNotice()
end

function GodsWarNoticePanel:TextUpdate()
	self.isChange = true
	local list = StringHelper.ConvertStringTable(self.input.text)

	if #list > 50 then
		local s = ""
		for i = 1, 50 do
			s = s .. list[i]
		end
		self.input.text = s
	end

	local num = math.max(0, 50 - #list)
	self.tips.text = string.format(TI18N("当前还可输入<color='#ffff00'>%s</color>字"), num)
end