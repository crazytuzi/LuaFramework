-- ---------------------------------
-- 诸神之战 战队列表元素
-- hosr
-- ---------------------------------
GodsWarTeamListItem = GodsWarTeamListItem or BaseClass()

function GodsWarTeamListItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self.captin = nil
	self.maxLev = 0
	self.maxFight = 0

	self:InitPanel()
end

function GodsWarTeamListItem:__delete()
	self.img.sprite = nil
end

function GodsWarTeamListItem:InitPanel()
	self.transform = self.gameObject.transform
	self.transformImg = self.gameObject.transform:GetComponent(Image)

	self.img = self.transform:Find("Head/Img"):GetComponent(Image)
	self.img.gameObject:SetActive(true)
	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.teamName = self.transform:Find("TeamName"):GetComponent(Text)
	self.num = self.transform:Find("Num"):GetComponent(Text)
	self.lev = self.transform:Find("Lev"):GetComponent(Text)

	self.select = self.transform:Find("Select").gameObject

	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
end

function GodsWarTeamListItem:update_my_self(data,i)
	self.data = data

	self.teamName.text = self.data.name
	self.num.text = string.format("%s/7", self.data.member_num)

	for i,v in ipairs(data.members) do
		if v.position == GodsWarEumn.Position.Captin then
			self.captin = v
		end
		self.maxLev = math.max(self.maxLev, v.lev)
		self.maxFight = math.max(self.maxFight, v.fight_capacity)
	end

	self.img.sprite = PreloadManager.Instance:GetClassesHeadSprite(self.captin.classes, self.captin.sex)
	self.name.text = self.captin.name
	self.lev.text = GodsWarEumn.GroupName(self.data.lev)
	if i%2 == 0 then
		self.transformImg.color = Color(154/255,198/255,241/255,1)
	else
		self.transformImg.color = Color(127/255,178/255,235/255,1)
	end
end

function GodsWarTeamListItem:Select(bool)
	self.select:SetActive(bool)
end

function GodsWarTeamListItem:ClickSelf()
	if self.parent ~= nil then
		self.parent:Select(self)
	end
end