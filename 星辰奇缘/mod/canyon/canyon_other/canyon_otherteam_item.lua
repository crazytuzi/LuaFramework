-- 峡谷之巅队伍信息Item
-- @author hze
-- @date 2018/07/25

CanYonOtherTeamItem = CanYonOtherTeamItem or BaseClass()

function CanYonOtherTeamItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function CanYonOtherTeamItem:__delete()
	BaseUtils.ReleaseImage(self.img)
	BaseUtils.ReleaseImage(self.classes)
end

function CanYonOtherTeamItem:InitPanel()
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

function CanYonOtherTeamItem:Reset()
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
function CanYonOtherTeamItem:SetData(data)
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
	end
end

function CanYonOtherTeamItem:ClickSelf()
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

