BossLoot = BossLoot or BaseClass(BaseRender)
function BossLoot:__init()

end

function BossLoot:__delete()

end

function BossLoot:OpenCallBack()
	HefuActivityCtrl.Instance:SendCSAQueryActivityInfo()
	self.kill_boss_count = HefuActivityData.Instance:GetKillBossCount()
	self.rest_time = self:FindVariable("rest_time")
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time = HefuActivityData.Instance:GetCombineActTimeLeft(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS)
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)

	self.is_show_list = {}
	self.item_cell_list = {}
	self.item_cell_obj_list = {}
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self:FindObj("Item_"..i)
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.item_cell_obj_list[i])
		self.is_show_list[i] = self:FindVariable("is_show_"..i)
	end

	self.reward_info = HefuActivityData.Instance:GetBoosLootRewardInfo()
	local reward_list = ItemData.Instance:GetItemConfig(self.reward_info.item_id)
	if nil == reward_list.item_1_id then
		self.item_cell_list[1]:SetData({item_id = reward_list.id , num = 1, is_bind = 1})
		self.is_show_list[1]:SetValue(true)
		for i = 2, 4 do
			self.is_show_list[i]:SetValue(false)
		end
	else
		for i = 1, 4 do
			local reward_item_list = {}
			if nil == reward_list["item_"..i.."_id"] then
				self.is_show_list[i]:SetValue(false)
			else
				self.is_show_list[i]:SetValue(true)
				reward_item_list[i] = {
				item_id = reward_list["item_"..i.."_id"],
				num = reward_list["item_"..i.."_num"],
				is_bind = reward_list["is_bind_"..i],}
				self.item_cell_list[i]:SetData(reward_item_list[i])
			end
		end
	end

	self:ListenEvent("ClickGetReward", BindTool.Bind(self.ClickGetReward, self))
	self:ListenEvent("ClickGoFight", BindTool.Bind(self.ClickGoFight, self))

	self.slider_progress = self:FindVariable("slider_progress")
	self.slider_progress:SetValue(self.kill_boss_count / 3)
	self.kill_count = self:FindVariable("kill_count")
	self.kill_count:SetValue(self.kill_boss_count)
	self.can_get = self:FindVariable("can_get")
	self.can_get:SetValue(self.kill_boss_count >= 3)
end

function BossLoot:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end

end

function BossLoot:SetTime(rest_time)
	local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	local temp = {}
	for k,v in pairs(time_tab) do
		if k ~= "day" then
			if v < 10 then
				v = tostring('0'..v)
			end
		end
		temp[k] = v
	end
	local str = string.format(Language.Activity.DanBiChongZhiRestTime, temp.day, temp.hour, temp.min, temp.s)
	self.rest_time:SetValue(str)
end

function BossLoot:OnFlush()
	self.kill_boss_count = HefuActivityData.Instance:GetKillBossCount()
	self.slider_progress:SetValue(self.kill_boss_count / 3)
	self.kill_count:SetValue(self.kill_boss_count)
	self.can_get:SetValue(self.kill_boss_count >= 3)
end

function BossLoot:ClickGetReward()
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_KILL_BOSS)
end

function BossLoot:ClickGoFight()
	HefuActivityCtrl.Instance.view:Close()
	ViewManager.Instance:OpenByCfg("Boss#miku_boss")
end