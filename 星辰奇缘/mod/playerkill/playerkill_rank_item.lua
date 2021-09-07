-- -----------------------------
-- 英雄擂台排行榜元素
-- hosr
-- -----------------------------
PlayerkillRankItem = PlayerkillRankItem or BaseClass()

function PlayerkillRankItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function PlayerkillRankItem:__delete()
end

function PlayerkillRankItem:InitPanel()
	self.transform = self.gameObject.transform

	self.rank = self.transform:Find("Rank"):GetComponent(Text)
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.head = self.transform:Find("Head/Image"):GetComponent(Image)
	self.zone = self.transform:Find("Zone"):GetComponent(Text)
	self.star = self.transform:Find("Zone/Val"):GetComponent(Text)
	self.server = self.transform:Find("Server"):GetComponent(Text)
	self.reward = self.transform:Find("Reward/Val"):GetComponent(Text)
end

function PlayerkillRankItem:update_my_self(data, index)
	self.data = data
	if index == 0 then
		self.rank.text = TI18N("榜外")
	else
		self.rank.text = tostring(index)
	end
	self.name.text = data.name
	self.head.sprite = PreloadManager.Instance:GetClassesHeadSprite(data.classes, data.sex)
	local baseData = DataRencounter.data_info[data.rank_lev]
	-- self.zone.text = baseData.title
	self.zone.text = string.format("%s%s", baseData.title, data.star)
	-- self.star.text = string.format("x%s", data.star)
	self.star.text = ""
	self.server.text = BaseUtils.GetServerName(data.plat, data.zone_id)
	if self.parent.index == 1 then
		self.reward.text = PlayerkillEumn.GetRankReward(self.parent.subindex, index)
	else
		self.reward.text = "--"
	end
end