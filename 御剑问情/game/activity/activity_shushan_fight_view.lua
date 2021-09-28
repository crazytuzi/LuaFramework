ActivityShuShanFightView = ActivityShuShanFightView or BaseClass(BaseView)

function ActivityShuShanFightView:__init()
	self.ui_config = {"uis/views/activityview_prefab","ShuShanFightView"}
	self.view_layer = UiLayer.MainUI
	self.hide = false
	self.monster_t = {}
	self.drop_t = {}
	self.refresh_time = 0
	self.refresh_cfg = ConfigManager.Instance:GetAutoConfig("huangchenghuizhancfg_auto").refresh
	self.need_log_drop_cfg = ConfigManager.Instance:GetAutoConfig("huangchenghuizhancfg_auto").need_log_drop
end

function ActivityShuShanFightView:__delete()

end

function ActivityShuShanFightView:ReleaseCallBack()
	if self.show_or_hide_other_button ~= nil then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end
	if self.quest_time then
		GlobalTimerQuest:CancelQuest(self.quest_time)
	end
	for k,v in pairs(self.drop_t) do
		v:DeleteMe()
	end
	self.drop_t ={}
	self.monster_t = {}

	self.num = nil
	-- self.time = nil
	self.show_time = nil
	self.get_exp = nil
	self.show_panel = nil
end

function ActivityShuShanFightView:LoadCallBack()
	self.num = self:FindVariable("Number")
	-- self.time = self:FindVariable("FlushTime")
	self.show_time = self:FindVariable("ShowTime")
	self.get_exp = self:FindVariable("GetExp")
	self.show_panel = self:FindVariable("ShowPanel")
	self.quest_time = nil
	self.monster_t = {}
	for i=1, 3 do
		self.monster_t[i] = {}
		self.monster_t[i].name = self:FindVariable("MonsterName" .. i)
		self.monster_t[i].num = self:FindVariable("MonsterNum" .. i)
		self:ListenEvent("OnClickMonster" .. i, BindTool.Bind(self.OnClickMonster, self, i))
	end
	self.drop_t = {}
	for i=1,2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:SetShowNumTxtLessNum(-1)
		self.drop_t[i] = item
	end
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))
end

function ActivityShuShanFightView:OnClickMonster(index)
	local monster_ref_cfg =  self.refresh_cfg[index]
	if nil == monster_ref_cfg then return end
	local target_monster = Scene.Instance:SelectMinDisMonster(monster_ref_cfg.monsterid)
	if target_monster then
		MoveCache.end_type = MoveEndType.Auto
		GuajiCtrl.Instance:MoveToObj(target_monster)
	else
		local pos = ActivityData.Instance:GetHzRandMonsterPos(monster_ref_cfg.monsterid)
		if pos then
			GuajiCtrl.Instance:CancelSelect()
			GuajiCtrl.Instance:ClearAllOperate()
			GuajiCtrl.Instance:SetGuajiType(GuajiType.HalfAuto)
			MoveCache.end_type = MoveEndType.Auto
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos.posx, pos.posy, 1, 1)
		end
	end
end

function ActivityShuShanFightView:OpenCallBack()
end

function ActivityShuShanFightView:SwitchButtonState(enable)
	self.show_panel:SetValue(enable)
end


function ActivityShuShanFightView:OnFlush()
	local hz_info = ActivityData.Instance:GetShuShanData()
	self.refresh_time = hz_info.next_refresh_time
	self.num:SetValue(hz_info.boss_num)
	for k,v in pairs(self.monster_t) do
		local monster_ref_cfg =  self.refresh_cfg[k]
		if monster_ref_cfg then
			local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[monster_ref_cfg.monsterid]
			if monster_cfg then
				v.name:SetValue(monster_cfg.name)
			end
			local monster_info = hz_info.monster_list[monster_ref_cfg.monsterid]
			v.num:SetValue(monster_info and monster_info.monster_count or 0)
		end
	end

	local hz_role_info = ActivityData.Instance:GetShuShanRoleData()
	for k,v in pairs(self.drop_t) do
		local drop_cfg = self.need_log_drop_cfg[k]
		if drop_cfg then
			local item_id = drop_cfg.need_log_drop_item_id
			local num = hz_role_info.drop_list[item_id] and hz_role_info.drop_list[item_id].num or 0
			v:SetData({item_id = drop_cfg.need_log_drop_item_id, num = num})
		end
	end

	self.get_exp:SetValue(hz_role_info.add_exp)
	if hz_info.boss_num == 0 then
		if nil == self.quest_time then
			self.quest_time = GlobalTimerQuest:AddRunQuest(
				function()
					if self.show_time then
						self.show_time:SetValue(true)
					end

					local remain_time = self.refresh_time - TimeCtrl.Instance:GetServerTime()
					-- if self.time then
					-- 	self.time:SetValue(remain_time)
					-- end
					
					if remain_time <= 0 then
						if self.show_time then
							self.show_time:SetValue(false)
						end

						if self.quest_time then
							GlobalTimerQuest:CancelQuest(self.quest_time)
							self.quest_time = nil
						end
					end
				end
			,0)
		end
	else
		if self.quest_time then
			GlobalTimerQuest:CancelQuest(self.quest_time)
			self.quest_time = nil
		end
	end

end

