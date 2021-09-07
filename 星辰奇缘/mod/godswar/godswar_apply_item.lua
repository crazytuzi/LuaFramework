-- ---------------------------------
-- 诸神之战 邀请列表元素
-- hosr
-- ---------------------------------

GodsWarApplyItem = GodsWarApplyItem or BaseClass()

function GodsWarApplyItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function GodsWarApplyItem:__delete()
	self.img.sprite = nil
end

function GodsWarApplyItem:InitPanel()
	self.transform = self.gameObject.transform

	self.img = self.transform:Find("Head/Img"):GetComponent(Image)
	self.img.gameObject:SetActive(true)
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.lev = self.transform:Find("Lev"):GetComponent(Text)
	self.classes = self.transform:Find("Classes"):GetComponent(Text)
	self.fight = self.transform:Find("Fight"):GetComponent(Text)
	self.offline = self.transform:Find("Offline").gameObject
	self.sure = self.transform:Find("Sure").gameObject
	self.sure:GetComponent(Button).onClick:AddListener(function() self:ClickBtn() end)
end

function GodsWarApplyItem:update_my_self(data)
	self.data = data

	self.name.text = self.data.name
	self.lev.text = self.data.lev
	self.classes.text = KvData.classes_name[self.data.classes]
	self.img.sprite = PreloadManager.Instance:GetClassesHeadSprite(self.data.classes, self.data.sex)
	self.fight.text = self.data.total_fc

	if self.data.online == 1 then
		-- 在线
		self.offline:SetActive(false)
		self.sure:SetActive(true)
	else
		self.offline:SetActive(true)
		self.sure:SetActive(false)
	end
end

function GodsWarApplyItem:ClickBtn()
	if self.data == nil then
		return
	end
	local func = function() GodsWarManager.Instance:Send17905(self.data.fid, self.data.platform, self.data.zone_id) end
	GodsWarManager.Instance:CheckIn(self.data, func)
end