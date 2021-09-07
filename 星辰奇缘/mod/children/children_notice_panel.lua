--作者:hzf
--17-1-10 下02时44分38秒
--功能:子女功能确认框

ChidldrenNoticePanel = ChidldrenNoticePanel or BaseClass(BasePanel)
function ChidldrenNoticePanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.childrennoticepanel, type = AssetType.Main},
		{file = AssetConfig.childrentextures, type = AssetType.Dep}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
end

function ChidldrenNoticePanel:__delete()
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function ChidldrenNoticePanel:OnHide()

end

function ChidldrenNoticePanel:OnOpen()

end

function ChidldrenNoticePanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childrennoticepanel))
	self.gameObject.name = "ChidldrenNoticePanel"
	self.data = self.openArgs
	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
		ChildrenManager.Instance.model:CloseNoticePanel()
	end)

	self.Title = self.transform:Find("Tips/Title")
	self.TitleText = self.transform:Find("Tips/Title/Text"):GetComponent(Text)
	self.descText = self.transform:Find("Tips/descText"):GetComponent(Text)
	self.Ext = MsgItemExt.New(self.descText, 323.3, 18, 19)
	self.OKButton = self.transform:Find("Tips/OKButton"):GetComponent(Button)
	self.ButtonText = self.transform:Find("Tips/OKButton/Text"):GetComponent(Text)
	self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
		ChildrenManager.Instance.model:CloseNoticePanel()
	end)
	self:SetData()
end

function ChidldrenNoticePanel:SetData()
	if self.data.model == 1 and self.data.flag == 1 then
		self.TitleText.text = TI18N("灵树开花")
	elseif self.data.model == 1 and self.data.flag == 0 then
		self.TitleText.text = TI18N("暂未开花")
	elseif self.data.model == 2 and self.data.flag == 1 then
		self.TitleText.text = TI18N("有喜啦")
	elseif self.data.model == 2 and self.data.flag == 0 then
		self.TitleText.text = TI18N("暂未怀孕")
	end
	self.Ext:SetData(self.data.msg)
end