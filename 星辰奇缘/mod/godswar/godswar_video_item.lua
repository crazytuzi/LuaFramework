-- -------------------------------
-- 诸神之战录像观看元素
-- hosr
-- -------------------------------
GodsWarVideoItem = GodsWarVideoItem or BaseClass()

function GodsWarVideoItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function GodsWarVideoItem:__delete()
end

function GodsWarVideoItem:InitPanel()
	self.transform = self.gameObject.transform
	self.index = self.transform:Find("Index"):GetComponent(Text)
	self.name1 = self.transform:Find("Name1"):GetComponent(Text)
	self.name2 = self.transform:Find("Name2"):GetComponent(Text)
	self.type = self.transform:Find("Type"):GetComponent(Text)
	self.date = self.transform:Find("Date"):GetComponent(Text)
	self.collect = self.transform:Find("Cancel").gameObject
	self.collect:GetComponent(Button).onClick:AddListener(function() self:ClickCollect() end)
	self.replay = self.transform:Find("Sure").gameObject
	self.replay:GetComponent(Button).onClick:AddListener(function() self:ClickWatch() end)
	self.watch = self.transform:Find("Button").gameObject
	self.watch:GetComponent(Button).onClick:AddListener(function() self:ClickWatch() end)
end

-- {uint32, id, "战斗id,用于查看录像用"}
-- ,{uint16,  season_id , "赛季id"}
-- ,{uint8, match_round, "赛季场次 3：16进8 4：8进4 5：半决赛 6：季军赛 7：决赛"}
-- ,{uint8, match_type, "赛程类型1：小组赛 2：淘汰赛"}
-- ,{uint8, combat_type, "战斗类型"}
-- ,{uint8, group_id, "比赛分组"}
-- ,{uint8, is_over, "战斗是否结束 0：未结束 1：已经结束"}
-- ,{string, atk_name, "攻方名字"}
-- ,{string, dfd_name, "守方名字"}
-- ,{uint32,  time, "战斗时间戳"}
function GodsWarVideoItem:update_my_self(data, index)
	self.data = data
	self.index.text = tostring(index)
	if self.data == nil then
		self.gameObject:SetActive(false)
	else
		self.name1.text = self.data.atk_name
		self.name2.text = self.data.dfd_name
		self.date.text = os.date("%Y-%m-%d", self.data.time)

		if self.data.match_type == 1 then
			self.type.text = TI18N("小组赛")
		elseif self.data.match_type == 2 then
			self.type.text = TI18N("淘汰赛")
		elseif self.data.match_type == 3 then
			self.type.text = TI18N("诸神挑战")
		else
			self.type.text = TI18N("诸神之战")
		end

		if self.data.is_over == 1 then
			self.watch:SetActive(false)
			self.collect:SetActive(true)
			self.replay:SetActive(true)
		else
			self.watch:SetActive(true)
			self.collect:SetActive(false)
			self.replay:SetActive(false)
		end
		self.gameObject:SetActive(true)
	end
end

function GodsWarVideoItem:ClickCollect()
	if self.data ~= nil then
		local platform = GodsWarManager.Instance.videoPlatform
		local zone_id = GodsWarManager.Instance.videoZondId
		CombatManager.Instance:Send10750(13, self.data.id, platform, zone_id)
	end
end

function GodsWarVideoItem:ClickWatch()
	if self.data ~= nil then
		if self.data.match_type == 3 then
            GodsWarManager.Instance:Send17959(self.data.id)
		else
			GodsWarManager.Instance:Send17929(self.data.id)
		end
		self.parent:Close(false)
	end
end
