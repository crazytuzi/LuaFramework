-- ----------------------------
-- 分享排行元素
-- hosr
-- ----------------------------
ShareRankItem = ShareRankItem or BaseClass()

function ShareRankItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function ShareRankItem:__delete()
	self.icon.sprite = nil
end

function ShareRankItem:InitPanel()
	self.transform = self.gameObject.transform

	self.icon = self.transform:Find("Icon"):GetComponent(Image)
	self.server = self.transform:Find("Server"):GetComponent(Text)
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.val = self.transform:Find("Val"):GetComponent(Text)
end

function ShareRankItem:update_my_self(data)
	self.data = data
	self.server.text = BaseUtils.GetServerName(data.platform_1, data.zone_id_1)
	self.name.text = data.name
	self.val.text = data.score
end