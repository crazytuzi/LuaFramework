-- ---------------------------------------
-- 诸神之战 战队分组列表详情元素
-- hosr
-- ---------------------------------------
GodsWarFightDetailItem = GodsWarFightDetailItem or BaseClass()

function GodsWarFightDetailItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function GodsWarFightDetailItem:__delete()
end

function GodsWarFightDetailItem:InitPanel()
	self.transform = self.gameObject.transform

	if self.gameObject:GetComponent(Button) ~= nil then
		self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
	end

	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.server = self.transform:Find("Server"):GetComponent(Text)
	self.state = self.transform:Find("State"):GetComponent(Text)
	self.point = self.transform:Find("Point"):GetComponent(Text)

	self.name.text = ""
	self.server.text = ""
	self.state.text = ""
	self.point.text = ""
end

-- {uint32, tid, "战队ID"}
-- ,{string, platform, "平台标识"}
-- ,{uint16, zone_id, "区号"}
-- ,{string, name, "战队名字"}
-- ,{uint8, lev, "战队等级"}
-- ,{uint8, member_num, "战队人数"}
-- ,{uint8, win_times, "胜利次数"}
-- ,{uint8, loss_times, "失败次数"}
-- ,{uint32, team_group_256, "小组赛组别"}
-- ,{array, gods_duel_team_mate, members, "成员", [
	-- {uint32, tid, "队员ID"}
	-- ,{string, platform, "平台标识"}
	-- ,{uint16, zone_id, "区号"}
	-- ,{string, name, "名字"}
	-- ,{uint8, classes, "职业"}
	-- ,{uint8, sex, "性别"}
	-- ,{uint16, lev, "等级"}
	-- ,{uint8, position, "身份: 0：申请者 1:队长，2：成员，3：替补"}
	-- ,{uint32, fight_capacity, "综合战力"}
-- ]}
function GodsWarFightDetailItem:SetData(data)
	self.data = data
	if data == nil then
		self.name.text = ""
		self.server.text = ""
		self.state.text = ""
		self.point.text = ""
	else
		local myData = GodsWarManager.Instance.myData
		if myData ~= nil and self.data.tid == myData.tid then
			self.name.text = string.format("<color='#ffff00'>%s</color>", data.name)
			self.server.text = string.format("<color='#ffff00'>%s</color>", BaseUtils.GetServerNameMerge(data.platform, data.zone_id))
			self.state.text = string.format("<color='#ffff00'>%s/%s</color>", data.win_times, data.loss_times)
			self.point.text = string.format("<color='#ffff00'>%s</color>", (data.win_times * 3 + data.loss_times * 1))
		else
			self.name.text = data.name
			self.server.text = BaseUtils.GetServerNameMerge(data.platform, data.zone_id)
			self.state.text = string.format("%s/%s", data.win_times, data.loss_times)
			self.point.text = data.win_times * 3 + data.loss_times * 1
		end
	end
end

function GodsWarFightDetailItem:ClickSelf()
	if self.data ~= nil then
		GodsWarManager.Instance.model:OpenTeam(self.data)
	end
end