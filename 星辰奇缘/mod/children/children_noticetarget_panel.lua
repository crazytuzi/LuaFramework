--作者:hzf
--17-1-10 下02时45分00秒
--功能:子女功能目标确认框

ChildrenNoticeTargetPanel = ChildrenNoticeTargetPanel or BaseClass(BasePanel)
function ChildrenNoticeTargetPanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.childrennoticetargetpanel, type = AssetType.Main},
		{file = AssetConfig.childrentextures, type = AssetType.Dep}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
end

function ChildrenNoticeTargetPanel:__delete()
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function ChildrenNoticeTargetPanel:OnHide()

end

function ChildrenNoticeTargetPanel:OnOpen()

end

function ChildrenNoticeTargetPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childrennoticetargetpanel))
	self.gameObject.name = "ChildrenNoticeTargetPanel"
	self.data = self.openArgs
	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
		ChildrenManager.Instance.model:CloseNoticeTargetPanel()
	end)
	self.Tips = self.transform:Find("Tips")
	self.bg = self.transform:Find("Tips/bg")
	self.TitleText = self.transform:Find("Tips/Title/Text"):GetComponent(Text)
	self.descText = self.transform:Find("Tips/descText"):GetComponent(Text)
	self.LButton = self.transform:Find("Tips/LButton"):GetComponent(Button)
	self.LButtonText = self.transform:Find("Tips/LButton/Text"):GetComponent(Text)
	self.Icon = self.transform:Find("Tips/LButton/Icon"):GetComponent(Image)
	self.numbg = self.transform:Find("Tips/LButton/numbg")
	self.numbg.gameObject:SetActive(false)
	self.needtext = self.transform:Find("Tips/LButton/numbg/Text"):GetComponent(Text)
	self.LdescText = self.transform:Find("Tips/LdescText"):GetComponent(Text)
	self.OKButton = self.transform:Find("Tips/OKButton"):GetComponent(Button)
	self.OKButton.onClick:AddListener(function()
		self:OnOk()
	end)
	self.OKButtonText = self.transform:Find("Tips/OKButton/Text"):GetComponent(Text)
	self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
		ChildrenManager.Instance.model:CloseNoticeTargetPanel()
	end)

	self:SetData(self.data)
end

function ChildrenNoticeTargetPanel:SetData(data)
	-- {itemid = 20000, need = 1, title = TI18N("天地灵种"), desc = TI18N("购买天地灵种，开启孕育任务"), btntext = TI18N("开启"), enoughCall = nil, buyCall = }
	if data.itemid ~= nil then
		self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures, data.icon)
		self.numbg.gameObject:SetActive(true)
		local has = BackpackManager.Instance:GetItemCount(data.itemid)
		self.needtext.text = string.format("%s/%s", has, data.need)
		self.LdescText.text = data.desc
		self.TitleText.text = data.title
		self.LButtonText.text = data.title
		self.OKButtonText.text = data.btntext
	else
		self.Icon.sprite = self.assetWrapper:GetSprite(AssetConfig.childrentextures, data.icon)
		self.LButtonText.text = data.title
		self.LdescText.text = data.desc
		self.TitleText.text = data.title
	end
end

function ChildrenNoticeTargetPanel:OnOk()
	if self.data.itemid ~= nil then
		local has = BackpackManager.Instance:GetItemCount(self.data.itemid)
		if has >= self.data.need then
			if self.data.enoughCall ~= nil then
				self.data.enoughCall()
			end
		else
			if self.data.buyCall ~= nil then
				self.data.buyCall()
			end
		end
	else
	end
	ChildrenManager.Instance.model:CloseNoticeTargetPanel()
end