-- ------------------------------
-- 诸神之战 我的战斗元素
-- hosr
-- ------------------------------
GodsWarFightMyItem = GodsWarFightMyItem or BaseClass()

function GodsWarFightMyItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function GodsWarFightMyItem:__delete()
end

function GodsWarFightMyItem:InitPanel()
	self.transform = self.gameObject.transform
	self.headObj = self.transform:Find("Bg/Img").gameObject
	self.head = self.headObj:GetComponent(Image)
	self.captin = self.transform:Find("Captin").gameObject
	self.lev = self.transform:Find("Lev/Val"):GetComponent(Text)
	self.name = self.transform:Find("Name/Val"):GetComponent(Text)
	self.classes = self.transform:Find("Classes/Val"):GetComponent(Text)

	self.transform:Find("Lev").gameObject:SetActive(false)
end

-- {uint32, tid, "队员ID"}
-- ,{string, platform, "平台标识"}
-- ,{uint16, zone_id, "区号"}
-- ,{string, name, "名字"}
-- ,{uint8, classes, "职业"}
-- ,{uint8, sex, "性别"}
-- ,{uint16, lev, "等级"}
-- ,{uint8, position, "身份: 0：申请者 1:队长，2：成员，3：替补"}
-- ,{uint32, fight_capacity, "综合战力"}
function GodsWarFightMyItem:SetData(data)
	self.data = data
	if data == nil then
		self.name.text = ""
		self.lev.text = ""
		self.classes.text = ""
		self.captin:SetActive(false)
		self.headObj:SetActive(false)
		self.gameObject:SetActive(false)
	else
		self.name.text = self.data.name
		self.head.sprite = PreloadManager.Instance:GetClassesHeadSprite(self.data.classes, self.data.sex)
		self.lev.text = self.data.lev
		self.classes.text = KvData.classes_name[self.data.classes]
		self.captin:SetActive(self.data.position == GodsWarEumn.Position.Captin)
		self.headObj:SetActive(true)
		self.gameObject:SetActive(true)
	end
end
