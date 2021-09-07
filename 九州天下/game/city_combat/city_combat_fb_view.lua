CityCombatFBView = CityCombatFBView or BaseClass(BaseView)

function CityCombatFBView:__init()
	self.ui_config = {"uis/views/citycombatview","CityCombatFBView"}
	self.view_layer = UiLayer.MainUI
	self.active_close = false
	self.fight_info_view = true
	self.rank_reward_item_list={} --排行奖励物品列表
	self.cell_list={}
	self.rank_cell_list = {}
	self.rank_reward_item_data = {}
	self.def_country_data = {}
	self.time_count = 0
	self.select_rank = 1
	self.is_safe_area_adapter = true
end

function CityCombatFBView:ReleaseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)

	GlobalEventSystem:UnBind(self.enter_fight)
	GlobalEventSystem:UnBind(self.exit_fight)
	if self.buttons then
		self.buttons:ListenEvent("ResZoneClick", nil)
		self.buttons:ListenEvent("FlagClick", nil)
		self.buttons:DeleteMe()
		self.buttons = nil
	end

	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	self.rank_list = {}

	self.item_obj_list = {}

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in pairs(self.rank_cell_list) do
		v:DeleteMe()
	end
	self.rank_cell_list = {}

	self.reward_count = nil
	self.reward = nil
	self.def_country_name = nil
	self.def_guild_time = nil
	self.show_count_down = nil
	self.count_down_num = nil
	self.show_panel = nil
	self.is_atk_side = nil
	self.is_fight_state = nil
	self.show_shoumen = nil
	self.door_is_destroy = nil
	self.show_skill_image = nil
	self.def_country_data = {}
	self:RemoveCountDown()
	self.rank_reward_is_show = {}
	self.person_reward_count = {}
	self.reward_list = nil
	self.list_view_delegate = nil
	self.present_rank = nil
	self.current_achieve = nil
	self.show_no_rank_text = nil
	self.lbl_ranking = nil
	self.lbl_rank = nil
	self.lbl_name = nil
	self.rank_list_view = nil
	self.rank_list_view_delegate = nil
end

function CityCombatFBView:ItemManager(list, group_name, item_name, func)
	local obj_group = self:FindObj(group_name)
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, item_name) ~= nil then
			list[count] = func(obj, count, self)
			count = count + 1
		end
	end
end

function CityCombatFBView:PoChengReset()
	if not self:IsLoaded() then
		return
	end
	self.show_count_down:SetValue(true)
	--控制倒计时时人物不能移动
	--GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	function diff_time_func(elapse_time, total_time)
		local left_time = math.ceil(total_time - elapse_time)
		if elapse_time >= total_time then
			-- GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			self.show_count_down:SetValue(false)
			self:RemoveCountDown()
		end
		self.count_down_num:SetValue(left_time)
	end
	diff_time_func(0, 3)
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(
		3, 1, diff_time_func)
end

function CityCombatFBView:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function CityCombatFBView:LoadCallBack()
	local obj = MainUICtrl.Instance:GetCityCombatButtons()
	obj:SetActive(true)
	self.buttons = BaseRender.New(obj)

	self:ListenEvent("ExitClick", BindTool.Bind(self.ExitClick, self))
	self:ListenEvent("TimeClick", BindTool.Bind(self.ToggleChange, self))
	self:ListenEvent("RewardCloseClick", BindTool.Bind(self.ToggleRankRewardShow, self,false))
	self:ListenEvent("RewardOpenClick", BindTool.Bind(self.ToggleRankRewardShow, self,true))

	self.buttons:ListenEvent("ResZoneClick", BindTool.Bind(self.ToResourceZone, self))
	self.buttons:ListenEvent("FlagClick", BindTool.Bind(self.CutFlag, self))

	-- self:ItemManager(self.rank_list, "ObjGroup", "ListItem", CityCombatRankCell.New)
	self:FlushRank()
	self.rank_list_view = self:FindObj("RankList")
	self.rank_list_view_delegate = self.rank_list_view.list_simple_delegate
	self.rank_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRankNumberOfCells, self)
	self.rank_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRankView, self)

	self.reward_count = self:FindVariable("ZhanGongRewardCount")
	self.current_achieve = self:FindVariable("CurrentAchieve")
	self.reward = self:FindVariable("ZhanGongReward")
	--self.at_present_zhanGong = self:FindVariable("AtPresentZhanGong")
	self.def_country_name = self:FindVariable("DefCountryName") --def_country_name
	self.def_guild_time = self:FindVariable("CuDefGulidTime")
	self.person_reward_count = self:FindVariable("ZhanGongPersonCount")
	self.rank_reward_is_show = self:FindVariable("RankRewardIsShow")
	self.present_rank = self:FindVariable("PresentRank")

	--排名奖励itemlist创建
	self.reward_list = self:FindObj("RankRewardList")
	self.list_view_delegate = self.reward_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)


	self.is_atk_side = self.buttons:FindVariable("IsAtkSide")			--是否攻方
	self.is_fight_state = self.buttons:FindVariable("IsFightState")
	self.show_shoumen = self.buttons:FindVariable("ShowShoumen")		-- 是否置灰守门按钮
	self.door_is_destroy = self.buttons:FindVariable("DoorIsDestroy")	--城门是否已被摧毁
	self.show_skill_image = self.buttons:FindVariable("ShowSkillImage")

	self.show_count_down = self:FindVariable("ShowCountDown")
	self.count_down_num = self:FindVariable("CountDownNumber")

	self.show_panel = self:FindVariable("ShowPanel")

	self.item_list = {}
	self.item_obj_list = {}
	for i = 1, 3 do
		local item_cell = ItemCell.New()
		self.item_obj_list[i] = self:FindObj("Item" .. i)
		item_cell:SetInstanceParent(self.item_obj_list[i])
		item_cell:SetData(nil)
		table.insert(self.item_list, item_cell)
	end

	self.show_no_rank_text = self:FindVariable("ShowNoRankText")
	self.lbl_ranking = self:FindVariable("Ranking")
	self.lbl_rank = self:FindVariable("Rank")
	self.lbl_name = self:FindVariable("Name")

	--self:GetRankRewardItem() --找到所有奖励排名item

	self.is_fight_state:SetValue(Scene.Instance:GetMainRole():IsFightState())
	self.show_shoumen:SetValue(Scene.Instance:GetMainRole():IsFightState())

	self.def_country_name:SetValue("")
	--self.def_country_name:SetValue("")
	self.def_guild_time:SetValue("")
	self.show_count_down:SetValue(false)
	--self.have_def_guild = false
	self.have_def_country = false
	self:Flush()
	self:FlushDefGuildTime()
	--self.rank_reward_is_show:SetValue(false)
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)
	self.enter_fight = GlobalEventSystem:Bind(ObjectEventType.ENTER_FIGHT, BindTool.Bind(self.FightStateChange, self, true))
	self.exit_fight = GlobalEventSystem:Bind(ObjectEventType.EXIT_FIGHT, BindTool.Bind(self.FightStateChange, self, false))
	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
end

function CityCombatFBView:FightStateChange(is_fight)
	self.is_fight_state:SetValue(is_fight)
	self.show_shoumen:SetValue(is_fight)
end

function CityCombatFBView:FlushDefGuildTime()
	if not self:IsLoaded() then
		return
	end
	--local def_guild_data = CityCombatData.Instance:GetGlobalInfo()
	self.def_country_data = CityCombatData.Instance:GetGlobalInfo()
	-- if def_guild_data == nil or def_guild_data.shou_guild_name == nil or def_guild_data.shou_guild_name == "" then
	-- 	self.def_country_name:SetValue(Language.Common.No)
	-- 	self.def_guild_time:SetValue("")
	-- 	self.have_def_guild = false
	-- 	return
	-- end
	
	--def_guild_data防守方的信息
	if self.def_country_data == nil or self.def_country_data.camp_type == nil  then --camp_type守城国家
		self.def_country_name:SetValue(Language.Common.No)
		self.def_guild_time:SetValue("")
		self.have_def_country = false
		return
	end
	
	--self.def_country_name:SetValue(Language.Common.CampName[self.def_country_data.camp_type])
	--self.time_count = def_guild_data.cu_def_guild_time

	self.def_country_name:SetValue(Language.Common.CampName[self.def_country_data.camp_type]) -- def_guild_data.camp_type

	for k,v in pairs(self.def_country_data.rank_list) do
		if v.camp_type == self.def_country_data.camp_type then 								  --当自身的国家类型等于守城的国家类型时
			self.time_count = v.shouchen_time  											      --计算守城国家的守城时长
		end
		
	end
	--self.have_def_guild = true
	self.have_def_country = true
end

function CityCombatFBView:Timer()
	if self.have_def_country then
		self.time_count = self.time_count + 1
		local time_count = TimeUtil.FormatSecond(self.time_count, 2)
		self.def_country_data.current_shou_cheng_time = self.def_country_data.current_shou_cheng_time + 1 
		local def_country_time = TimeUtil.FormatSecond(self.def_country_data.current_shou_cheng_time, 2)
		self.def_guild_time:SetValue(string.format(Language.CityCombat.DefenseTime, ToColorStr(def_country_time, "#32D45EFF")))
		
		CityCombatData.Instance:ReSetRank(self.def_country_data.current_shou_cheng_time)
	end
	self:FlushRank()
end

function CityCombatFBView:NumberForShort(num)
	local text = ""
	if num < 10000 then
		text = num
	else
		text = math.floor(num / 10000)..Language.Common.Wan
	end
	return text
end

function CityCombatFBView:FlushItemList()
	local next_zhangong_reward = CityCombatData.Instance:GetNextZhanGongReward()
	--奖励
	for i = 1, 3 do
		local index = i - 1
		local reward_list = next_zhangong_reward["reward_item"] or {}
		local reward = reward_list[index]
		if reward then
			self.item_obj_list[i]:SetActive(true)
			self.item_list[i]:SetData(reward)
		else
			if next_zhangong_reward.sheng_wang and next_zhangong_reward.sheng_wang > 0 then
				self.item_obj_list[i]:SetActive(true)
				local data = {}
				data.item_id = ResPath.CurrencyToIconId["honor"]
				data.num = next_zhangong_reward.sheng_wang
				self.item_list[i]:SetData(data)
			else
				self.item_obj_list[i]:SetActive(false)
			end
		end
	end
end

function CityCombatFBView:OnFlush()
	if not self:IsLoaded() then
		return
	end
	--战功
	local self_info = CityCombatData.Instance:GetSelfInfo()
	local next_zhangong_reward = CityCombatData.Instance:GetNextZhanGongReward()
	local text = ""
	--local self_zhangong_text = self:NumberForShort(self_info.zhangong)
	local self_zhangong_text = self_info.zhangong
	local next_reward_text = next_zhangong_reward.zhangong
	local self_ranking = CityCombatData.Instance:GetSelfRanking()

	if self.now_max_zhangong ~= next_reward_text then
		self.now_max_zhangong = next_reward_text
		self:FlushItemList()
	end
	self.current_achieve:SetValue(self_zhangong_text)

	if self_info.zhangong > next_zhangong_reward.zhangong then
		text = ToColorStr(self_zhangong_text.." / "..next_reward_text, "#32D45EFF")
	else
		text = ToColorStr(self_zhangong_text, TEXT_COLOR.RED)..ToColorStr(" / "..next_reward_text, "#32D45EFF")
	end
	self.reward_count:SetValue(text)
	self.person_reward_count:SetValue(self_zhangong_text)
	--self.at_present_zhanGong:SetValue(self_zhangong_text)
	--排名
	self:FlushRank()
	self.is_atk_side:SetValue(CityCombatData.Instance:GetIsAtkSide())
	local is_destroy = CityCombatData.Instance:GetwallIsDestroy()
	self.door_is_destroy:SetValue(is_destroy)
	if CityCombatData.Instance:GetIsAtkSide() then
		self.show_skill_image:SetAsset(ResPath.GetRoleSkillIcon("4001"))
	else
		self.show_skill_image:SetAsset(ResPath.GetRoleSkillIcon("4002"))
	end

	if self_ranking > 0 then
		self.show_no_rank_text:SetValue(true)
	else
		self.show_no_rank_text:SetValue(false)
	end

	self.lbl_ranking:SetValue(self_ranking)
	if self_ranking <= 3 and self_ranking > 0 then
		local bundle, asset = ResPath.GetImages("rank_" .. self_ranking)
		self.lbl_rank:SetAsset(bundle, asset)
	end

	self.present_rank:SetValue(self_ranking)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.lbl_name:SetValue(vo.name)
	self.is_fight_state:SetValue(Scene.Instance:GetMainRole():IsFightState())
	self.show_shoumen:SetValue(Scene.Instance:GetMainRole():IsFightState())
end

function CityCombatFBView:FlushRank()
	local rank_data = nil
	if self.select_rank == 1 then
		rank_data = CityCombatData.Instance:GetTimeRankList()
	else
		rank_data = CityCombatData.Instance:GetZhanGongRankList()
	end

	self.rank_list = rank_data

	if self.rank_list_view then
		if self.rank_list_view.scroller.isActiveAndEnabled then
			self.rank_list_view.scroller:RefreshAndReloadActiveCellViews(true)
		else
			self.rank_list_view.scroller:ReloadData(0)
		end
	end
end

function CityCombatFBView:OpenCallBack()
	self.now_max_zhangong = 0
	--self:FlushRankReward()
end

function CityCombatFBView:OnMainUIModeListChange(is_show)
	self.show_panel:SetValue(is_show)
end

function CityCombatFBView:ExitClick()
	local func = function()
		FuBenCtrl.Instance:SendExitFBReq()
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Common.ExitFuBen)
end

function CityCombatFBView:ToggleChange(is_on)
	if is_on then
		self.select_rank = 1
	else
		self.select_rank = 2
	end
	self:FlushRank()
end

function CityCombatFBView:ToggleRankRewardShow(visiable) 	--控制排名奖励的开关
	self.rank_reward_is_show:SetValue(visiable)
end

--寻路至资源区
function CityCombatFBView:ToResourceZone()
	if CityCombatData.Instance:CheckSelfIsInResZone() then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		return
	end
	CityCombatCtrl.Instance:QuickChangePlace(CITY_COMBAT_MOVE_TYPE.ZHIYUAN_PLACE)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	GuajiCtrl.Instance:StopGuaji()
end

--寻路至砍旗
function CityCombatFBView:CutFlag()
	if Scene.Instance:GetMainRole():IsFightState() then
		return
	end
	local door_is_destroy = CityCombatData.Instance:GetwallIsDestroy()
	local is_in_res_zone = CityCombatData.Instance:CheckSelfIsInResZone()
	local x, y = CityCombatData.Instance:GetFlagPosXY()
	local scene_id = Scene.Instance:GetSceneId()
	if CityCombatData.Instance:GetIsAtkSide() then	--判断为资源区时为攻击方时进入							
		 if is_in_res_zone then						
			CityCombatCtrl.Instance:QuickChangePlace(CITY_COMBAT_MOVE_TYPE.ATTACK_PLACE)
		 end
	else														--判断为资源区时为防守方时进入 
		if is_in_res_zone then				
			CityCombatCtrl.Instance:QuickChangePlace(CITY_COMBAT_MOVE_TYPE.DEFENCE_PLACE)
		end				
		if not door_is_destroy then							--防守方进入传送门条件			
			GuajiCtrl.Instance:MoveToPos(scene_id, x, y)
		end
	end			
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
end
--rankrewardlist单条创建
function CityCombatFBView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local rank_reward_cell = self.cell_list[cell]
	if rank_reward_cell == nil then
		rank_reward_cell = CityRankRewardCell.New(cell.gameObject,data_index)  --cell.gameObject
		self.cell_list[cell] = rank_reward_cell
	end
	rank_reward_cell:SetIndex(data_index)
	local data = CityCombatData.Instance:GetZhanGongRankCfg()
	rank_reward_cell:SetData(data[data_index]) --调用Onflush
end

function CityCombatFBView:GetNumberOfCells()
	return #ConfigManager.Instance:GetAutoConfig("gongchengzhan_auto").zhangong_rank or 0 --获得长度
end

function CityCombatFBView:GetRankNumberOfCells()
	return #self.rank_list
end

function CityCombatFBView:RefreshRankView(cell, data_index)
	data_index = data_index + 1

	local rank_cell = self.rank_cell_list[cell]
	if rank_cell == nil then
		rank_cell = CityCombatRankCell.New(cell.gameObject, self)
		self.rank_cell_list[cell] = rank_cell
	end
	rank_cell:SetIndex(data_index)
	rank_cell:SetData(self.rank_list[data_index])
end

function CityCombatFBView:GetSelectRank()
	return self.select_rank or 1
end

----------------------------------------------------------------------------
--CityCombatRankCell 		排名格子
----------------------------------------------------------------------------
CityCombatRankCell = CityCombatRankCell or BaseClass(BaseCell)
function CityCombatRankCell:__init(instance, parent)
	self.parent_view = parent
	self.rank = self:FindVariable("Rank")
	self.name = self:FindVariable("Name")
	self.value = self:FindVariable("Value")
	self.is_self = self:FindVariable("IsSelf")
	self.rank_image = self:FindVariable("RankImage")
	self.is_show_rank_text = self:FindVariable("IsShowRankText")

	self.name_obj = self:FindObj("NameObj")
	self.value_obj = self:FindObj("ValueObj")
end

function CityCombatRankCell:__delete()
	self.parent_view = nil
end

function CityCombatRankCell:OnFlush()
	self.name:SetValue(self.data.name)
	local value = self.data.value
	if self.parent_view.select_rank == 1 then
		value = TimeUtil.FormatSecond(self.data.value, 2)
	end
	self.value:SetValue(value)
	self.is_self:SetValue(self.data.is_self)

	self.rank:SetValue(self.data.rank)
	if self.data.rank <= 3 and self.data.rank > 0 then
		local bundle, asset = ResPath.GetImages("rank_" .. self.data.rank)
		self.rank_image:SetAsset(bundle, asset)
		self.is_show_rank_text:SetValue(false)
	else
		self.is_show_rank_text:SetValue(true)
	end

	if self.parent_view:GetSelectRank() == 1 then
		self.name_obj.text.fontSize = 25
		self.value_obj.text.fontSize = 20
	else
		self.name_obj.text.fontSize = 19
		self.value_obj.text.fontSize = 19
	end

end
-------------------------------------------------------------------------------
--RankRewardCell          排名奖励列表
-------------------------------------------------------------------------------
CityRankRewardCell = CityRankRewardCell or BaseClass(BaseCell)
function CityRankRewardCell:__init(instance,rank_num) --根据排名来获取格子里面该显示什么
	self.rank = rank_num
end

function CityRankRewardCell:__delete()

end

function CityRankRewardCell:LoadCallBack()
	self.rank_reward_list = {}
	self.ranking = self:FindVariable("Ranking")
	for i = 1, 4 do
		self.rank_reward_list[i] = ItemCell.New(self:FindObj("Item" .. i))
		self.rank_reward_list[i]:SetActive(false) 
	end
	self:Flush() 
end

function CityRankRewardCell:ReleaseCallBack()
	for i,v in pairs(self.rank_reward_list) do
		v:DeleteMe()
		v = nil
	end
	self.rank_reward_list = {}
end

function CityRankRewardCell:OnFlush()
	if nil == self.data then return end
	for i = 1, 4 do
		if self.data.reward_item[i - 1] then
			self.rank_reward_list[i]:SetData(self.data.reward_item[i - 1])
			self.rank_reward_list[i]:SetActive(true)
		else
			self.rank_reward_list[i]:SetActive(false) 
		end
	end

	if self.data.rank_show then
		self.ranking:SetValue(self.data.rank_show)
	end
	
end