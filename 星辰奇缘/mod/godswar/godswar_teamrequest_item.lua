-- ------------------------------------
-- 诸神之战 战队申请元素
-- hosr
-- ------------------------------------
GodsWarTeamRequestItem = GodsWarTeamRequestItem or BaseClass()

function GodsWarTeamRequestItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function GodsWarTeamRequestItem:__delete()
	self.head.sprite = nil
end

function GodsWarTeamRequestItem:InitPanel()
	self.transform = self.gameObject.transform

	self.head = self.transform:Find("Head/Img"):GetComponent(Image)
	self.head.gameObject:SetActive(true)
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.classes = self.transform:Find("Classes"):GetComponent(Text)
	self.lev = self.transform:Find("Lev"):GetComponent(Text)
	self.fight = self.transform:Find("Fight"):GetComponent(Text)

	self.notice = self.transform:Find("Button").gameObject
	self.sure = self.transform:Find("Sure").gameObject
	self.cancel = self.transform:Find("Cancel").gameObject
	self.cancel:GetComponent(Button).onClick:AddListener(function() self:OnCancel() end)
	self.sure:GetComponent(Button).onClick:AddListener(function() self:OnSure() end)
	self.notice:GetComponent(Button).onClick:AddListener(function() self:OnNotice() end)
end

function GodsWarTeamRequestItem:update_my_self(data)
	self.data = data

	self.name.text = self.data.name
	self.lev.text = self.data.lev
	self.classes.text = KvData.classes_name[self.data.classes]
	self.head.sprite = PreloadManager.Instance:GetClassesHeadSprite(self.data.classes, self.data.sex)
	self.fight.text = self.data.fight_capacity

	if GodsWarManager.Instance:IsSelfCaptin() then
		self.notice:SetActive(false)
		self.sure:SetActive(true)
		self.cancel:SetActive(true)
	else
		self.notice:SetActive(true)
		self.sure:SetActive(false)
		self.cancel:SetActive(false)
	end
end

function GodsWarTeamRequestItem:OnSure()
	if self.data ~= nil then
		local func = function() GodsWarManager.Instance:Send17908(self.data.tid, self.data.platform, self.data.zone_id, 1) end
		GodsWarManager.Instance:CheckIn(self.data, func)
	end
end

function GodsWarTeamRequestItem:OnCancel()
	if self.data ~= nil then
		GodsWarManager.Instance:Send17908(self.data.tid, self.data.platform, self.data.zone_id, 0)
	end
end

function GodsWarTeamRequestItem:OnNotice()
	local data = {}
	local captin = GodsWarManager.Instance.captin
	data.id = captin.tid
	data.platform = captin.platform
	data.zone_id = captin.zone_id
	data.name = captin.name
	data.classes = captin.classes
	data.sex = captin.sex
	data.lev = captin.lev
	FriendManager.Instance:TalkToUnknowMan(data)
end