-- -----------------------------
-- 诸神之战 --规则界面
-- hosr
-- -----------------------------

GodsWarRulePanel = GodsWarRulePanel or BaseClass(BasePanel)

function GodsWarRulePanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.godswarrule, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
		{file = AssetConfig.bigatlas_godswarbg1i18n, type = AssetType.Main},
		{file = AssetConfig.bigatlas_taskBg, type = AssetType.Main},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.itemList = {}
end

function GodsWarRulePanel:__delete()
	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil
end

function GodsWarRulePanel:OnShow()
    -- self:UpdateButton()
end

function GodsWarRulePanel:OnHide()
end

function GodsWarRulePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarrule))
    self.gameObject.name = "GodsWarRulePanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.container)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2.zero

    -- self.btn = self.transform:Find("Button").gameObject
    -- self.btn:GetComponent(Button).onClick:AddListener(function() GodsWarManager.Instance:SignUp() end)
    -- self.btnTxt = self.transform:Find("Button/Text"):GetComponent(Text)

    UIUtils.AddBigbg(self.transform:Find("Scroll/Container/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_godswarbg1i18n)))
    UIUtils.AddBigbg(self.transform:Find("Bg2"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_taskBg)))

    self.container = self.transform:Find("Scroll/Container")
    self.containerRect = self.container:GetComponent(RectTransform)
    self.itemBase = self.container:Find("Item").gameObject
    self.itemBase:SetActive(false)

    self:SetData()
    -- self:UpdateButton()
end

function GodsWarRulePanel:SetData()
	local list = DataGodsDuel.data_desc
	local h = 150
	for i,v in ipairs(list) do
		local item = GodsWarRuleItem.New(GameObject.Instantiate(self.itemBase), self)
		table.insert(self.itemList, item)
		item.transform:SetParent(self.container)
		item.transform.localScale = Vector3.one
		item:SetData(v)
		item.rect.anchoredPosition = Vector2(0, -h)
		h = h + item.height + 5
	end
	self.containerRect.sizeDelta = Vector2(690, h)
end

function GodsWarRulePanel:UpdateButton()
	if GodsWarManager.Instance.status < GodsWarEumn.Step.Publicity then
		if GodsWarManager.Instance.myData.qualification == GodsWarEumn.Quality.Sign then
			self.btnTxt.text = TI18N("已报名")
		else
			self.btnTxt.text = TI18N("报名")
		end
		self.btn:SetActive(true)
	else
		self.btn:SetActive(false)
	end
end
