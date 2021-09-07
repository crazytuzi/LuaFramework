-- ---------------------------------
-- 诸神之战 战队信息元素
-- hosr
-- ---------------------------------
GodsWarTeamInfoItem = GodsWarTeamInfoItem or BaseClass()

function GodsWarTeamInfoItem:__init(gameObject, parent, index)
	self.gameObject = gameObject
	self.parent = parent
	self.index = index

	self.isSelf = false
	self:InitPanel()
	self.editing = false
end

function GodsWarTeamInfoItem:__delete()
	self.img.sprite = nil
	self.classes.sprite = nil
end

function GodsWarTeamInfoItem:InitPanel()
	self.transform = self.gameObject.transform

	self.img = self.transform:Find("Head/Img"):GetComponent(Image)

	self.imgObj = self.img.gameObject
	self.addObj = self.transform:Find("Head/Add").gameObject
	self.transform:Find("Head"):GetComponent(Button).onClick:AddListener(function() self:ClickHead() end)

	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.nameObj = self.name.gameObject

	self.lev = self.transform:Find("Lev"):GetComponent(Text)
	self.levObj = self.lev.gameObject

	self.classes = self.transform:Find("Image"):GetComponent(Image)
	self.classesObj = self.classes.gameObject

	self.captin = self.transform:Find("Captin").gameObject
	self.standby = self.transform:Find("Standby").gameObject
	self.standby:SetActive(false)

	self.select = self.transform:Find("Select").gameObject
	self.option = self.transform:Find("Option").gameObject

	self.btn = self.gameObject:GetComponent(CustomButton)
    self.btn.onClick:AddListener(function() self:OnClick() end)
    -- self.btn.onHold:AddListener(function() self:OnHold() end)
    -- self.btn.onUp:AddListener(function() self:OnUp() end)
    -- self.btn.onDown:AddListener(function() self:OnClick() end)
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
function GodsWarTeamInfoItem:SetData(data)
	self.data = data

	if data == nil then
		self.addObj:SetActive(true)
		self.imgObj:SetActive(false)
		self.nameObj:SetActive(true)
		self.levObj:SetActive(false)
		self.classesObj:SetActive(false)
		self.captin:SetActive(false)

		self.name.text = TI18N("点击邀请")
	else
		self.isSelf = (BaseUtils.get_self_id() == string.format("%s_%s_%s", data.platform, data.zone_id, data.tid))
		self.addObj:SetActive(false)
		self.imgObj:SetActive(true)
		self.nameObj:SetActive(true)
		self.levObj:SetActive(true)
		self.classesObj:SetActive(true)
		self.captin:SetActive(self.data.position == GodsWarEumn.Position.Captin)

		self.name.text = self.data.name
		self.lev.text = string.format(TI18N("%s级<color='#00ff00'>%s</color>"), self.data.lev, KvData.classes_name[self.data.classes])
		self.classes.sprite = PreloadManager.Instance:GetClassesSprite(self.data.classes)
		self.img.sprite = PreloadManager.Instance:GetClassesHeadSprite(self.data.classes, self.data.sex)
	end

	self:QuitEditor()
end

function GodsWarTeamInfoItem:Select(bool)
	self.select:SetActive(bool)
end

function GodsWarTeamInfoItem:OnClick()
	if self.data == nil then
		-- 打开邀请界面
		GodsWarManager.Instance.model:OpenApply()
	else
		self.parent:Select(self)
		-- self:OnDown()
	end
end

function GodsWarTeamInfoItem:OnUp()
	self.parent:Up(self)
end

function GodsWarTeamInfoItem:OnDown()
	self.parent:Down(self)
end

function GodsWarTeamInfoItem:OnHold()
	self.parent:Hold(self)
end

function GodsWarTeamInfoItem:EnterEditor()
	if self.data ~= nil and self.data.position ~= 1 then
		self.option:SetActive(true)
		self.editing = true
	end
end

function GodsWarTeamInfoItem:QuitEditor()
	self.editing = false
	self.option:SetActive(false)
end

function GodsWarTeamInfoItem:ClickHead()
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
	else
		GodsWarManager.Instance.model:OpenApply()
	end
end