	CityCombatVictoryView = CityCombatVictoryView or BaseClass(BaseView)

function CityCombatVictoryView:__init()
	self.ui_config = {"uis/views/citycombatview","CityCombatVictoryView"}
end

function CityCombatVictoryView:ReleaseCallBack()
	if self.reward_list then
		for k,v in pairs(self.reward_list) do
			if v.cell then
				v.cell:DeleteMe()
			end
		end
	end
	self.reward_list = {}
end

function CityCombatVictoryView:ItemManager(list, group_name, item_name, func)
	local obj_group = self:FindObj(group_name)
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, item_name) ~= nil then
			list[count] = {}
			list[count].obj = obj
			list[count].cell = func(obj, count)
			count = count + 1
		end
	end
end

function CityCombatVictoryView:LoadCallBack()
	self:ListenEvent("ExitClick", BindTool.Bind(self.Close, self))
	self.reward_list = {}
	self:ItemManager(self.reward_list, "VictorRewardGroup", "ItemCell", ItemCellReward.New)

	self:Flush()
end

function CityCombatVictoryView:Flush()
	local count = 1
	if self.data.gongxun > 0 then
		local gongxun_reward = {item_id = ResPath.GetCurrencyID("gongxun"), num = self.data.gongxun}
		self.reward_list[count].obj:SetActive(true)
		self.reward_list[count].cell:SetData(gongxun_reward)
		count = count + 1
	end
	if self.data.gold_reward > 0 then
		local gold_reward = {item_id = ResPath.GetCurrencyID("diamond"), num = self.data.gold_reward}
		self.reward_list[count].obj:SetActive(true)
		self.reward_list[count].cell:SetData(gold_reward)
		count = count + 1
	end
	if self.data.shengwang_reward > 0 then
		local shengwang_reward = {item_id = ResPath.GetCurrencyID("shengwang"), num = self.data.shengwang_reward}
		self.reward_list[count].obj:SetActive(true)
		self.reward_list[count].cell:SetData(shengwang_reward)
		count = count + 1
	end
	--½±Àø»ı·Ö
	if self.data.daily_chestshop_score > 0 then
		local daily_chestshop_score = {item_id = ResPath.GetCurrencyID("jifen"), num = self.data.daily_chestshop_score}
		self.reward_list[count].obj:SetActive(true)
		self.reward_list[count].cell:SetData(daily_chestshop_score)
		count = count + 1
	end
	for k,v in pairs(self.data.reward_list) do
		if v.num > 0 then
			if count <= #self.reward_list then
				self.reward_list[count].obj:SetActive(true)
				self.reward_list[count].cell:SetData(v)
				count = count + 1
			end
		end
	end
	if count <= #self.reward_list then
		for i=count,#self.reward_list do
			self.reward_list[i].obj:SetActive(false)
		end
	end
end

function CityCombatVictoryView:SetData(protocol)
	self.data = protocol
end