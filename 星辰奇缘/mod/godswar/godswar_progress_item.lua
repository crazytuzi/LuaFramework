-- ------------------------------------
-- 诸神之战 进度
-- hosr
-- ------------------------------------
GodsWarProgressItem = GodsWarProgressItem or BaseClass()

function GodsWarProgressItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function GodsWarProgressItem:__delete()
	if self.bg ~= nil then
		self.bg.sprite = nil
		self.bg = nil
	end
end

function GodsWarProgressItem:InitPanel()
	self.transform = self.gameObject.transform
	self.bg = self.transform:Find("Image"):GetComponent(Image)
	self.name = self.transform:Find("Name"):GetComponent(Text)

	self:Default()
end

function GodsWarProgressItem:Default()
	self.bg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.godswarres, "GodsWarBg1")
end

function GodsWarProgressItem:Doing()
	self.bg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.godswarres, "GodsWarBg2")
end