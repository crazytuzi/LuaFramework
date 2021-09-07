-- ------------------------------------
-- 幻化手册奖励预览
-- hosr
-- ------------------------------------
HandbookRewardPanel = HandbookRewardPanel or BaseClass(BasePanel)

function HandbookRewardPanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.handbookreward, type = AssetType.Main},
		{file = AssetConfig.stongbg, type = AssetType.Dep},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function HandbookRewardPanel:__delete()
	if self.slot ~= nil then
		self.slot:DeleteMe()
		self.slot = nil
	end
end

function HandbookRewardPanel:OnShow()
	self.data = self.openArgs[1]
	self:SetData()
end

function HandbookRewardPanel:OnHide()
end

function HandbookRewardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.handbookreward))
    self.gameObject.name = "HandbookRewardPanel"
    UIUtils.AddUIChild(self.parent.parent.parent.gameObject, self.gameObject)

   	self.transform = self.gameObject.transform
    self.transform:Find("Main/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
   	self.title = self.transform:Find("Main/Title"):GetComponent(Text)
   	self.title.text = "<color='#00ff00'>收集图鉴后将额外获得以下奖励</color>"

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Main/Slot").gameObject, self.slot.gameObject)

    self.name = self.transform:Find("Main/Name"):GetComponent(Text)
    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() self:ClickClose() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:ClickClose() end)

    self:OnShow()
end

function HandbookRewardPanel:SetData()
	local base = DataItem.data_get[self.data[1]]
	local itemData = ItemData.New()
	itemData:SetBase(base)
	self.slot:SetAll(itemData)
    self.name.text = itemData.name
end

function HandbookRewardPanel:ClickClose()
	self:Hiden()
end