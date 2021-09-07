SupremacyView = SupremacyView or BaseClass(BaseView)
MAX_KILL = 0
MAX_DEATH = 1
MAX_HURT_CAMP =2
function SupremacyView:__init()
	self.ui_config = {"uis/views/crossserverview", "CrossServerSupremacy"}
	self.view_layer = UiLayer.MainUILow
	self.active_close = false
	self.fight_info_view = true
	self.is_safe_area_adapter = true
end

function SupremacyView:__delete()
	
end

function SupremacyView:LoadCallBack()
	self.boss_flush = self:FindVariable("bossflush")
	self.boss_hp = self:FindVariable("bosshp")
	self.affiliation = self:FindVariable("affiliation")
	self.max_hurt = self:FindVariable("maxhurt")
	self.max_kill = self:FindVariable("maxkill")
	self.max_death = self:FindVariable("maxdeath")

	self.residue_kill = self:FindVariable("residuekill")

	self.qi_monument = self:FindVariable("qimonument")
	self.chu_monument = self:FindVariable("chumonument")
	self.wei_monument = self:FindVariable("weimonument")
	self.hurt = self:FindVariable("hurt")

	self.destory = self:FindVariable("destory")
	self.kill = self:FindVariable("kill")
	self.death = self:FindVariable("death")
	self.honor = self:FindVariable("honor")
	self.plan = self:FindVariable("plan")
	self.task_name = self:FindVariable("taskname")
	self.item_list = {}
	self.num_list = {}
	self.view_open = self:FindVariable("view_open")
	self.baoxiang_num = self:FindVariable("baoxiang_num")
	self.caiji_num = self:FindVariable("caiji_num")
	for i = 1, 2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("ItemCell" .. i))
		self.item_list[i] = item
		self.num_list[i] = self:FindVariable("num"..i)
	end
	self:ListenEvent("OnClickSwitch", BindTool.Bind(self.OnClickSwitch, self))
	self:ListenEvent("LeaveForBoss", BindTool.Bind(self.LeaveForBoss, self))
	self:ListenEvent("LeaveForSmallMonster", BindTool.Bind(self.LeaveForSmallMonster, self))
	self:SetRewardItem()
	self.is_switch = true
end

function SupremacyView:ReleaseCallBack()
	self.qi_monument = nil
	self.chu_monument = nil
	self.wei_monument = nil
	self.hurt = nil
	self.destory = nil
	self.kill = nil
	self.death = nil
	self.honor = nil
	self.plan = nil
	self.boss_flush = nil
	self.boss_hp = nil
	self.affiliation = nil
	self.max_hurt = nil
	self.max_kill = nil
	self.max_death = nil
	self.residue_kill = nil
	self.task_name = nil
	for i = 1, 2 do
		if self.item_list[i] then
		 	self.item_list[i]:DeleteMe()
		 	self.item_list[i] = nil
		end
	end
	self.num_list = {}
	self.item_list = {}
	self.is_switch = nil
	self.baoxiang_num = nil
	self.caiji_num = nil
	self.view_open = nil
end	

function SupremacyView:OpenCallBack()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
end

function SupremacyView:CloseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function SupremacyView:FlushNextTime()
	local boss_task_list = SupremacyData.Instance:GetBossTaskData()
	local time = boss_task_list.next_refresh_timetamp or 0
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local is_exist = boss_task_list.is_exist or 0
	if time - cur_time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if self.boss_flush then 
		self.boss_flush:SetValue(is_exist > 0 and Language.Honour.Exist or TimeUtil.FormatSecond(time - cur_time,3))
	end
end

function SupremacyView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "boss" then
			self:FlushBossData()
		elseif k == "Mountment" then
			self:FlushMountment()
		elseif k =="SingleInfo" then
			self:FlushInfo()
		elseif k == "hao_li" then
			self:FlushTianJiangHaoLi()
		end
	end
end

--刷新BOSS
function SupremacyView:FlushBossData()
	local boss_task_list = SupremacyData.Instance:GetBossTaskData()
	local boss_info_list = SupremacyData.Instance:GetBossInfoData()
	local belong_camp = boss_task_list.belong_camp or 0
	local hp = boss_info_list.boss_hp or 0
	local max_hurt = boss_task_list.uesr_list[MAX_HURT_CAMP].user_name or ""
	local kill = boss_task_list.uesr_list[MAX_KILL].user_name or ""
	local death = boss_task_list.uesr_list[MAX_DEATH].user_name or ""
	self.boss_hp:SetValue(hp.."%")
	self.affiliation:SetValue(Language.Honour.Camp[belong_camp])
	self.max_hurt:SetValue(max_hurt)
	self.max_kill:SetValue(kill)
	self.max_death:SetValue(death) 
end

--刷新纪念碑
function SupremacyView:FlushMountment()
	local mountment_info = SupremacyData.Instance:GetMonument()
	local qi = mountment_info.monument_list[GameEnum.ROLE_CAMP_1] or 0
	local chu = mountment_info.monument_list[GameEnum.ROLE_CAMP_2] or 0
	local wei = mountment_info.monument_list[GameEnum.ROLE_CAMP_3] or 0
	local vo_camp = GameVoManager.Instance:GetMainRoleVo().camp
	local hurt_num = mountment_info.monument_list[vo_camp] * 10 .. "%"
	self.qi_monument:SetValue(qi)
	self.chu_monument:SetValue(chu)
	self.wei_monument:SetValue(wei)
	self.hurt:SetValue(hurt_num)
	self.baoxiang_num:SetValue(mountment_info.treasure_num)
end

function SupremacyView:FlushInfo()
	local info = SupremacyData.Instance:GetSingleInfo()
	local destory_num = info.dakuafu_kill_jinianbei_num or 0
	local kill_num = info.dakuafu_kill_num or 0
	local death_num = info.dakuafu_dead_num or 0
	local cross_rongyao = info.cross_rongyao or 0
	local cfg,is_finish = SupremacyData.Instance:GetNeedHonour(cross_rongyao)
	local kill_monster = info.guaji_today_remain_num or 0
	self.destory:SetValue(destory_num)
	self.kill:SetValue(kill_num)
	self.death:SetValue(death_num)
	local reward_list = cfg.rewards or {}
	local honour_plan = is_finish > 0 and string.format(Language.Honour.Plan,cross_rongyao,cfg.need_rongyao) or Language.Honour.Finish
	self.honor:SetValue(cross_rongyao)
	self.plan:SetValue(honour_plan)
	self.residue_kill:SetValue(kill_monster)
	for i = 1, 2 do
		if reward_list[i-1] then
			self.num_list[i]:SetValue(string.format(Language.Honour.Num,reward_list[i-1].num))
		end
	end
end

function SupremacyView:SetRewardItem()
	local  cfg = SupremacyData.Instance:GetRewardCfg()
	if not cfg and not cfg[0] then
		return
	end
	for i = 1, 2 do
		self.item_list[i]:SetData(cfg[0].rewards[i-1])
	end
end

function SupremacyView:LeaveForBoss()
	local cfg = SupremacyData.Instance:GetBossPosition()
	if cfg[1] == nil and cfg[2] == nil then return end
	GuajiCache.monster_id = SupremacyData.Instance:GetBossId()
  	MoveCache.end_type = MoveEndType.FightByMonsterId
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), cfg[1], cfg[2])
end

function SupremacyView:LeaveForSmallMonster()
	local main_role = Scene.Instance:GetMainRole()
	local role_pos_x, role_pos_y = main_role:GetLogicPos()
	local cfg = SupremacyData.Instance:GetShortDistance(role_pos_x,role_pos_y)
	GuajiCache.monster_id = SupremacyData.Instance:GetMonsterId()
  	MoveCache.end_type = MoveEndType.FightByMonsterId
	GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), cfg.pos_x, cfg.pos_y,10,10)
end

function SupremacyView:OnClickSwitch()
	self.view_open:SetValue(self.is_switch)
	self.is_switch = not self.is_switch
end

function SupremacyView:FlushTianJiangHaoLi()
	local haoli_data = SupremacyData.Instance:GetHaoLiInfo()
	if haoli_data == nil then return end
	local collect_num = haoli_data.collect_num
	local collect_max = haoli_data.collect_max
	self.caiji_num:SetValue(collect_num .. "/" .. collect_max)
end

