-- --------------------------------
-- 诸神之战 战队信息查看元素
-- hosr
-- --------------------------------
GodsWarOtherTeamItem = GodsWarOtherTeamItem or BaseClass()

function GodsWarOtherTeamItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function GodsWarOtherTeamItem:__delete()
	self.img.sprite = nil
	self.classes.sprite = nil
end

function GodsWarOtherTeamItem:InitPanel()
	self.transform = self.gameObject.transform
	self.img = self.transform:Find("Img"):GetComponent(Image)
	self.imgObj = self.img.gameObject
	self.captin = self.transform:Find("Captin").gameObject
	self.noneImg = self.transform:Find("NoneImg").gameObject

	self.info = self.transform:Find("Info").gameObject
	self.name = self.transform:Find("Info/Name/Val"):GetComponent(Text)
	self.lev = self.transform:Find("Info/Lev"):GetComponent(Text)
	self.classes = self.transform:Find("Info/Classes"):GetComponent(Image)

	UIUtils.AddBigbg(self.transform:Find("Bg"), GameObject.Instantiate(self.parent:GetPrefab(AssetConfig.bigatlas_godswarbg0)))

	-- self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
end

function GodsWarOtherTeamItem:Reset()
	self.info:SetActive(false)
	self.imgObj:SetActive(false)
	self.noneImg:SetActive(true)
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
function GodsWarOtherTeamItem:SetData(data)
	self:Reset()
	self.data = data

	if self.data ~= nil then
		self.noneImg:SetActive(false)
		self.img.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.classcardgroup_textures, string.format("%s_%s", self.data.classes, self.data.sex))
		self.classes.sprite = PreloadManager.Instance:GetClassesSprite(self.data.classes)
		self.name.text = self.data.name
		-- self.lev.text = string.format(TI18N("%s级 %s"), self.data.lev, KvData.classes_name[self.data.classes])
		self.lev.text = KvData.classes_name[self.data.classes]
		self.info:SetActive(true)
		self.imgObj:SetActive(true)
		self.captin:SetActive(self.data.position == GodsWarEumn.Position.Captin)
	end
end

function GodsWarOtherTeamItem:ClickSelf()
	if self.data ~= nil then
		local data = {}
		data.id = self.data.tid
		data.platform = self.data.platform
		data.zone_id = self.data.zone_id
		data.classes = self.data.classes
		data.sex = self.data.sex
		data.name = self.data.name
		data.lev = self.data.lev
		TipsManager.Instance:ShowPlayer(data)
	end
end


-- --------------------------------------------------
-- 替补的头像元素
-- hosr
-- --------------------------------------------------
GodsWarOtherTeamHeadItem = GodsWarOtherTeamHeadItem or BaseClass()

function GodsWarOtherTeamHeadItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function GodsWarOtherTeamHeadItem:__delete()
	self.img.sprite = nil
end

function GodsWarOtherTeamHeadItem:InitPanel()
	self.transform = self.gameObject.transform
	self.imgObj = self.transform:Find("Img").gameObject
	self.img = self.imgObj:GetComponent(Image)
	self.transform:Find("Standby").gameObject:SetActive(false)
	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
end

function GodsWarOtherTeamHeadItem:Reset()
	self.imgObj:SetActive(false)
end

function GodsWarOtherTeamHeadItem:SetData(data)
	self:Reset()
	self.data = data

	if self.data ~= nil then
		self.img.sprite = PreloadManager.Instance:GetClassesHeadSprite(self.data.classes, self.data.sex)
		self.imgObj:SetActive(true)
	end
end

function GodsWarOtherTeamHeadItem:ClickSelf()
	if self.data ~= nil then
		local data = {}
		data.id = self.data.tid
		data.platform = self.data.platform
		data.zone_id = self.data.zone_id
		data.classes = self.data.classes
		data.sex = self.data.sex
		data.name = self.data.name
		data.lev = self.data.lev
		TipsManager.Instance:ShowPlayer(data)
	end
end