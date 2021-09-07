-- -------------------------------------------------
-- 诸神之战 分组详情
-- hosr
-- -------------------------------------------------
GodsWarFightDetailPanel = GodsWarFightDetailPanel or BaseClass(BasePanel)

function GodsWarFightDetailPanel:__init()
	self.model = model
	self.resList = {
		{file = AssetConfig.godswarfightdetail, type = AssetType.Main},
	}

	self.itemList = {}
end

function GodsWarFightDetailPanel:__delete()
	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil
end

function GodsWarFightDetailPanel:OnShow()
	self.list = self.openArgs.list
	self.index = self.openArgs.index or 1
	self:Update()
end

function GodsWarFightDetailPanel:OnHide()
end

function GodsWarFightDetailPanel:Close()
	GodsWarManager.Instance.model:CloseDetail()
end

function GodsWarFightDetailPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarfightdetail))
    self.gameObject.name = "GodsWarFightDetailPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.title = self.transform:Find("Main/Title"):GetComponent(Text)
    local container = self.transform:Find("Main/Container")
    local len = container.childCount

    for i = 1, len do
    	local item = GodsWarFightDetailItem.New(container:GetChild(i - 1).gameObject, self)
    	table.insert(self.itemList, item)
    end

    self.gameObject:SetActive(true)
    self:OnShow()
end

function GodsWarFightDetailPanel:Update()
	self.title.text = string.format(TI18N("第%s小组"), self.index)
	for i,item in ipairs(self.itemList) do
		item:SetData(self.list[i])
	end
end
