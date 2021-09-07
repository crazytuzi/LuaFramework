ActivityDetailView = ActivityDetailView or BaseClass(BaseView)
local BtnStr = {
	[ACTIVITY_TYPE.HUSONG] = Language.Common.QianWang,
	[ACTIVITY_TYPE.BIG_RICH] = Language.Common.QianWang,
}
function ActivityDetailView:__init()
	self.ui_config = {"uis/views/activityview","ActivityDetailView"}
	self:SetMaskBg()
	self.act_id = 0
	self.play_audio = true

	self.role_display = {}
	self.is_model = {}					-- 剪影是否可见
	self.is_show_name = {}				-- 是否显示名字
	self.model_name = {}				-- 玩家阵营和姓名
	self.role_model = {}				-- 模型
	self.king_role_id = {}
end

function ActivityDetailView:__delete()

end

function ActivityDetailView:ReleaseCallBack()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	
	for k,v in pairs(self.role_model) do
		v:DeleteMe()
	end

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
	
	self.role_model = {}
	
	self.role_display = {}
	self.is_model = {}
	self.is_show_name = {}
	self.model_name = {}

	-- 清理变量和对象
	self.text_left_top = nil
	self.text_left_bottom = nil
	self.text_right_bottom = nil
	self.btn_text = nil
	self.title_time = nil
	self.title_name = nil
	self.explain = nil
	self.show_item_list = nil
	self.activity_bg = nil
	self.is_zhuagui = nil
	self.zhuagui_num = nil
	self.hunli_num = nil
	self.btn2_text = nil
	self.show_btn_2 = nil
	self.is_element = nil
	self.is_guild_fight = nil
	self.show_text_type = nil
	self.text_type_str = nil
	self.show_reward = nil
end

function ActivityDetailView:LoadCallBack()
	--获取变量
	---[[--左下角描述
	self.text_left_top = self:FindVariable("TextLeftTop")
	self.text_left_bottom = self:FindVariable("TextLeftBottom")
	self.text_right_bottom = self:FindVariable("TextRightBottom")
	--]]
	self.btn_text = self:FindVariable("BtnText")				--按钮文本
	self.title_time = self:FindVariable("TitleTime")			--开启时间文本
	self.title_name = self:FindVariable("TitleName")			--活动名字文本
	self.explain = self:FindVariable("Explain")					--说明文本
	self.show_item_list = self:FindVariable("ShowItemList")		--是否展示物品列表
	self.activity_bg = self:FindVariable("ActivityBg")			--活动背景图
	self.is_zhuagui = self:FindVariable("is_zhuagui")			--是否是秘境降魔
	self.zhuagui_num = self:FindVariable("zhuagui_num")			--抓鬼数量
	self.hunli_num = self:FindVariable("hunli_num")				--抓鬼魂力数量
	self.btn2_text = self:FindVariable("BtnText2")				--按钮2文本
	self.show_btn_2 = self:FindVariable("ShowBtn2")				--是否显示按钮2
	self.show_text_type = self:FindVariable("ShowTextType")		--无物品奖励，只有文本
	self.text_type_str = self:FindVariable("TextTypeStr")		--奖励文本

	self.is_element = self:FindVariable("IsElement")			--是否元素战场
	self.is_guild_fight = self:FindVariable("IsGuildFight")		--是否公会争霸
	self.show_reward = self:FindVariable("ShowReward")

	for i = 1, 3 do
		self.role_display[i] = self:FindObj("Display" .. i)		--照相机里面绑定，显示人物模型
		self.is_model[i] = self:FindVariable("IsShowModel" .. i)
		self.model_name[i] = self:FindVariable("ModelName" .. i)
		self.is_show_name[i] = self:FindVariable("IsShowName" .. i)
	end

	-- 初始化人物模型
	self:InitRoleModel()


	--获取组件
	self.item_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:SetData(nil)
		-- item:ListenClick(BindTool.Bind(self.ItemClick, self, i))
		table.insert(self.item_list, item)
	end

	--绑定事件
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("ClickEnter", BindTool.Bind(self.ClickEnter, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))
	self:ListenEvent("ClickBtn2", BindTool.Bind(self.ClickBtn2, self))
	self:ListenEvent("MinghunClick", BindTool.Bind(self.MinghunClick, self))

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
end

function ActivityDetailView:InitRoleModel()
	for i = 1, 3 do
		if not self.role_model[i] and self.role_display[i] then
			self.role_model[i] = RoleModel.New("activity_detail_view")
			self.role_model[i]:SetDisplay(self.role_display[i].ui3d_display)
		end
	end
end

function ActivityDetailView:OpenCallBack()
	if self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU then
		self.is_element:SetValue(true)
		self.is_guild_fight:SetValue(false)
		self:ClearCampKingInfo()
		ActivityCtrl.Instance:SendGetRankInfo()
	elseif self.act_id == ACTIVITY_TYPE.GUILDBATTLE then
		self.is_element:SetValue(true)
		self.is_guild_fight:SetValue(true)
		self:ClearCampKingInfo()
		GuildFightCtrl.Instance:SendGBWinnerInfoReq()
	elseif self.act_id == ACTIVITY_TYPE.ACTIVITY_TYPE_MONSTER_SIEGE then
		CampCtrl.Instance:SendGetCampInfo()
	else
		self.is_element:SetValue(false)
		self.is_guild_fight:SetValue(false)
	end
end

function ActivityDetailView:ItemClick(index)
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	local item_cfg, _ = ItemData.Instance:GetItemConfig(act_info["reward_item" .. index].item_id)

	local item_callback = function ()
		self.item_list[index]:ShowHighLight(false)
	end
	if nil ~= item_cfg then
		self.item_list[index]:ShowHighLight(true)
		TipsCtrl.Instance:OpenItem(act_info["reward_item" .. index],nil ,nil, item_callback)
	end
end

function ActivityDetailView:CloseWindow()
	self:Close()
end

function ActivityDetailView:MinghunClick()
	ViewManager.Instance:Open(ViewName.SpiritView, TabIndex.spirit_soul)
end

function ActivityDetailView:ClickHelp()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end
	TipsCtrl.Instance:ShowHelpTipView(act_info.play_introduction)
end

function ActivityDetailView:ClickBtn2()
	if self.act_id == ACTIVITY_TYPE.ZHUAGUI then
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		local have_team = ScoietyData.Instance:GetTeamState()
		local is_leader = ScoietyData.Instance:IsLeaderById(main_role_id)

		if have_team then
			if is_leader then
				local team_index = ScoietyData.Instance:GetTeamIndex()
				local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
				local invite_str = string.format(Language.Society.ZhuaGuiTeamInvite, team_index, act_info.min_level or 0, "")
				ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, invite_str, CHAT_CONTENT_TYPE.TEXT)
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.WorldInvite)
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.Society.DontInviety)
				return
			end
		else
			local param_t = {}
			param_t.must_check = 0
			param_t.assign_mode = 2
			ScoietyCtrl.Instance:CreateTeamReq(param_t)
			ActivityData.Instance:SetSendZhuaGuiInvite(true)
		end
		-- ViewManager.Instance:Close(ViewName.ActivityDetail)
		return
	end
end

function ActivityDetailView:ClickEnter()
	local act_info = ActivityData.Instance:GetClockActivityByID(self.act_id)
	if not next(act_info) then return end

	if GameVoManager.Instance:GetMainRoleVo().level < act_info.min_level then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Common.JoinEventActLevelLimit, act_info.min_level))
		return
	end
	local scene_id= Scene.Instance:GetSceneId()
	---[[客户端自定义活动
	if self.act_id == ACTIVITY_TYPE.ZHUAGUI then 		-- 秘境降魔
		if scene_id == 106 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongYiZai)
		else
			GuajiCtrl.Instance:FlyToScene(106)
		end
		self:CloseWindow()
		ViewManager.Instance:Close(ViewName.Activity)
		return
	elseif self.act_id == ACTIVITY_TYPE.SHUIJING then
		if not ActivityData.Instance:GetActivityIsOpen(self.act_id) then
			local cfg = ActivityData.Instance:GetClockActivityByID(self.act_id)
			local open_time_tbl = Split(cfg.open_time, "|")
			local end_time_tbl = Split(cfg.end_time, "|")
			local time_str = string.format(" %s-%s , %s-%s", open_time_tbl[1], end_time_tbl[1], open_time_tbl[2], end_time_tbl[2])
			local describe = string.format(Language.Common.ShuiJingShiJian, time_str)
			local yes_func = function()
				ActivityCtrl.Instance:SendActivityEnterReq(self.act_id)
				ViewManager.Instance:CloseAll()
			end
			TipsCtrl.Instance:ShowCommonTip(yes_func, nil, describe)
			return
		end
	end
	--]]
	if not ActivityData.Instance:GetActivityIsOpen(self.act_id) then
		if self.act_id ~= ACTIVITY_TYPE.HUSONG then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
			return
		end
	end

	if self.act_id == DaFuHaoDataActivityId.ID then								-- 大富豪
		 if ActivityData.Instance:GetActivityStatuByType(self.act_id) == nil or
			ActivityData.Instance:GetActivityStatuByType(self.act_id).status ~= ACTIVITY_STATUS.OPEN then
			TipsCtrl.Instance:ShowSystemMsg(Language.Guild.GUILDJIUHUINOOPEN)
			return
		end

		local dafuhao_info = DaFuHaoData.Instance:GetDaFuHaoInfo()
		if dafuhao_info ~= nil then
			local gather_total_times = dafuhao_info.gather_total_times
			if gather_total_times and gather_total_times >= 20 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Activity.CollectIsMax)
				return
			end
		end

		local cfg = DaFuHaoData.Instance:GetDaFuHaoOtherCfg()
		if nil ~= cfg then
			-- local index = math.random(1, #cfg)
			local role_camp = GameVoManager.Instance:GetMainRoleVo().camp
			ActivityCtrl.Instance:SendActivityEnterReq(DaFuHaoDataActivityId.ID)
			MoveCache.scene_id = cfg["scene_id_"..role_camp]
			MoveCache.x = cfg["fly_pos_x_"..role_camp]
			MoveCache.y = cfg["fly_pos_y_"..role_camp]
			GuajiCtrl.Instance:MoveToScenePos(cfg["scene_id_"..role_camp], cfg["fly_pos_x_"..role_camp], cfg["fly_pos_y_"..role_camp], true, 0)
			DaFuHaoCtrl.Instance:SendGetGatherInfoReq()
		end
	elseif self.act_id == ACTIVITY_TYPE.KF_HOT_SPRING 									-- 泳池派对
		or self.act_id == ACTIVITY_TYPE.KF_MINING										-- 跨服挖矿
		or self.act_id == ACTIVITY_TYPE.KF_FISHING then									-- 跨服钓鱼
			CrossServerCtrl.Instance:SendCrossStartReq(self.act_id)
			self:CloseWindow()
	-- elseif self.act_id == ACTIVITY_TYPE.CROSS_SHUIJING then							-- 跨服水晶
	-- 	CrossServerCtrl.Instance:SendCrossStartReq(self.act_id)
	elseif self.act_id == ACTIVITY_TYPE.HUSONG then										-- 运镖
		ViewManager.Instance:CloseAll()
		YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
		return
	elseif self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER then							-- 修罗塔
		if not ActivityData.Instance:GetActivityIsOpen(self.act_id) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		else
			ViewManager.Instance:Open(ViewName.FuXiuLuoTowerBuffView)
		end
	elseif self.act_id == ACTIVITY_TYPE.GUILD_BOSS then
		GuildCtrl.Instance:SendGuildBackToStationReq(GameVoManager.Instance:GetMainRoleVo().guild_id)
	elseif self.act_id == ACTIVITY_TYPE.BANZHUAN then
		ViewManager.Instance:Open(ViewName.NationalWarfare, TabIndex.national_warfare_brick)
		self:CloseWindow()
		return
	elseif self.act_id == ACTIVITY_TYPE.ACTIVITY_TYPE_MONSTER_SIEGE then
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_MONSTER_SIEGE)
		return
	else
		local index = 0
		if self.act_id == ACTIVITY_TYPE.CLASH_TERRITORY and ClashTerritoryData.Instance:GetTerritoryRankById() then
			local rank = ClashTerritoryData.Instance:GetTerritoryRankById()
			index = math.max(math.ceil(rank / 2) - 1, 0)
		end
		ActivityCtrl.Instance:SendActivityEnterReq(self.act_id, index)
	end

	if self.act_id == ACTIVITY_TYPE.KF_HOT_SPRING then
		return
	end
	if self.act_id ~= ACTIVITY_TYPE.KF_XIULUO_TOWER and self.act_id ~= ACTIVITY_TYPE.HUSONG and self.act_id ~= ACTIVITY_TYPE.KF_FISHING then
		ViewManager.Instance:CloseAll()
	end
end

--记录活动id
function ActivityDetailView:SetActivityId(act_id)
	self.act_id = act_id
end

function ActivityDetailView:GetActivityId()
	return self.act_id
end

--活动时间
function ActivityDetailView:SetTitleTime(act_info)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local now_weekday = tonumber(os.date("%w", server_time))
	local server_time_str = os.date("%H:%M", server_time)
	if now_weekday == 0 then now_weekday = 7 end
	local time_str = Language.Activity.YiJieShu

	if ActivityData.Instance:GetActivityIsOpen(act_info.act_id) then
		time_str = Language.Activity.KaiQiZhong
	elseif act_info.is_allday == 1 then
		time_str = Language.Activity.AllDay
	else
		for _, v in ipairs(self.open_day_list) do
			if tonumber(v) == now_weekday then
				local open_time_tbl = Split(act_info.open_time, "|")
				local open_time_str = open_time_tbl[1]
				local end_time_tbl = Split(act_info.end_time, "|")

				-- if #end_time_tbl > 1 then
				-- 	for k2, v2 in ipairs(end_time_tbl) do
				-- 		open_time_str = open_time_tbl[k2]
				-- 		if v2 > server_time_str then
				-- 			break
				-- 		end
				-- 	end
				-- end
				local though_time = true
				for k2, v2 in ipairs(end_time_tbl) do
					if v2 > server_time_str then
						though_time = false
						open_time_str = open_time_tbl[k2]
						-- end_time_str = v2
						break
					end
				end
				if though_time then
					time_str = Language.Activity.YiJieShuDes
				else
					time_str = string.format("%s  %s", open_time_str, Language.Common.Open)
				end
				break
			end
		end
	end
	self.title_time:SetValue(time_str)
end


function ActivityDetailView:GetChineseWeek(act_info)
	local open_time_tbl = Split(act_info.open_time, "|")
	local end_time_tbl = Split(act_info.end_time, "|")

	local time_des = ""

	if #self.open_day_list >= 7 then
		if #open_time_tbl > 1 then
			local time_str = ""
			for i = 1, #open_time_tbl do
				if i == 1 then
					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
				else
					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
				end
			end
			time_des = string.format("%s %s", Language.Activity.EveryDay, time_str)
		else
			time_des = string.format("%s %s-%s", Language.Activity.EveryDay, act_info.open_time, act_info.end_time)
		end
	else
		local week_str = ""
		for k, v in ipairs(self.open_day_list) do
			local day = tonumber(v)
			if k == 1 then
				week_str = string.format("%s%s", Language.Activity.WeekDay, Language.Common.DayToChs[day])
			else
				week_str = string.format("%s、%s", week_str, Language.Common.DayToChs[day])
			end
		end
		if #open_time_tbl > 1 then
			local time_str = ""
			for i = 1, #open_time_tbl do
				if i == 1 then
					time_str = string.format("%s-%s", open_time_tbl[1], end_time_tbl[1])
				else
					time_str = string.format("%s,%s-%s", time_str, open_time_tbl[i], end_time_tbl[i])
				end
			end
			time_des = string.format("%s %s", week_str, time_str)
		else
			time_des = string.format("%s %s-%s", week_str, act_info.open_time, act_info.end_time)
		end
	end
	return time_des
end

--描述
function ActivityDetailView:SetExplain(act_info)
	local min_level = tonumber(act_info.min_level)
	local lv, zhuan = PlayerData.GetLevelAndRebirth(min_level)
	local level_str = string.format(Language.Common.ZhuanShneng, lv, zhuan)
	local time_des = ""

	if act_info.is_allday == 1 then
		time_des = Language.Activity.AllDay
	else
		time_des = self:GetChineseWeek(act_info)
	end

	--搬砖特殊处理
	if self.act_id == ACTIVITY_TYPE.BANZHUAN then
		time_des = Language.Activity.EveryDay .. act_info.open_time
	elseif self.act_id == ACTIVITY_TYPE.SHUIJING then
		time_des = string.format(Language.Activity.DoubleRewardTime, self:GetChineseWeek(act_info))
	elseif self.act_id == ACTIVITY_TYPE.HUSONG then
		time_des = time_des .. Language.Activity.GuoJunKaiQi
	end

	local detailexplain = string.format(Language.Activity.DetailExplain, level_str, time_des, act_info.dec)
	if self.act_id == ACTIVITY_TYPE.CLASH_TERRITORY then
		local guild_id = PlayerData.Instance.role_vo.guild_id or 0
		local match_name = ClashTerritoryData.Instance:GetTerritoryWarMatch(guild_id)
		detailexplain = string.format(Language.Activity.TerritoryWarExplain, level_str, time_des, match_name)
	end
	if self.act_id == ACTIVITY_TYPE.ACTIVITY_TYPE_MONSTER_SIEGE then
		local str = ActivityData.Instance:OtherContryInfo()
		detailexplain = string.format(Language.Activity.DetailExplain, level_str, time_des, str)
	end
	self.explain:SetValue(detailexplain)
end

--设置是否显示奖励
function ActivityDetailView:SetRewardState(act_info)
	if act_info.reward_item1 ~= nil and next(act_info.reward_item1) then
		self.show_item_list:SetValue(true)
		for k, v in ipairs(self.item_list) do
			if act_info["reward_item" .. k] and next(act_info["reward_item" .. k]) and act_info["reward_item" .. k].item_id ~= 0 then
				self.item_list[k].root_node:SetActive(true)
				self.item_list[k]:SetData(act_info["reward_item" .. k])
			else
				self.item_list[k]:SetInteractable(false)
				self.item_list[k].root_node:SetActive(false)
			end
		end
	else
		self.show_item_list:SetValue(false)
		if act_info.reward_str ~= nil and act_info.reward_str ~= "" then
			self.show_text_type:SetValue(true)
			self.text_type_str:SetValue(act_info.reward_str)
			self.show_reward:SetValue(true)
			if self.act_id == ACTIVITY_TYPE.ACTIVITY_TYPE_MONSTER_SIEGE then
				-- CampCtrl.Instance:SendGetCampInfo()
				-- local str,is_defend =  ActivityData.Instance:OtherCamp()
				-- self.text_type_str:SetValue(is_defend and act_info.reward_str or str)
				self.text_type_str:SetValue("")
				self.show_reward:SetValue(false)
			end
		else
			self.show_text_type:SetValue(false)	
		end
	end
end

function ActivityDetailView:OnFlush(param_t)
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	self.open_day_list = Split(act_info.open_day, ":")

	self:SetTitleTime(act_info)
	self:SetRewardState(act_info)
	self:SetExplain(act_info)

	self.is_zhuagui:SetValue(false)

	self.show_btn_2:SetValue(self.act_id == ACTIVITY_TYPE.ZHUAGUI)
	--按钮文字
	local btn_str = Language.Common.EnterScene
	if self.act_id == ACTIVITY_TYPE.ZHUAGUI then
		btn_str = Language.Activity.GoToZhuaGui
		self.is_zhuagui:SetValue(true)
		self.btn2_text:SetValue(Language.Society.WorldInviety)
		local zhuagui_info = ZhuaGuiData.Instance:GetCurDayZhuaGuiInfo()
		-- print_error(zhuagui_info)
		-- if #zhuagui_info ~= 0 then
			-- print_error(">>>>>>>>>")
		self.zhuagui_num:SetValue(zhuagui_info.zhuagui_day_catch_count)
		self.hunli_num:SetValue(zhuagui_info.zhuagui_day_gethunli)
		-- end
	elseif self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU then
		self:FlushRoleModel()
	end

	if BtnStr[self.act_id] then
		btn_str = BtnStr[self.act_id]
	end
	self.btn_text:SetValue(btn_str)

	--活动名字
	self.title_name:SetValue(act_info.act_name)

	--设置活动底图
	self.activity_bg:SetAsset(ResPath.GetActivityBg(self.act_id))

	for k,v in pairs(param_t) do
        if k == "guild_fight_king" then
			self:FlushCampKingModel()
        end
    end
end

function ActivityDetailView:FlushRoleModel()
	local rank_list = ElementBattleData.Instance:GetRankList()
	if not rank_list or not next(rank_list) then return end

	local data_list = {}
	for i = 0, 2 do
		local score = 0
		local data = {}
		for k, v in ipairs(rank_list) do
			if v.score > 0 and  v.side == i and v.score >= score then
				data = v
				score = v.score
			end
		end
		table.insert(data_list, data)
	end
	
--	SortTools.SortAsc(rank_list, "score")

	for k, v in pairs(data_list) do
		if next(v) then
			self.model_name[k]:SetValue(Language.ElementBattleSideName[v.side] ..":"..v.name or "")
			self.is_model[k]:SetValue(false)
			self.role_model[k]:SetModelResInfo(v, false, true, false, false, true, true, false, false)
			self.is_show_name[k]:SetValue(true)
		else
			self.model_name[k]:SetValue("")
			self.is_model[k]:SetValue(true)
			self.role_model[k]:ClearModel()
			self.is_show_name[k]:SetValue(false)
		end
	end
end

function ActivityDetailView:FlushCampKingModel()
	local king_role_info = CheckData.Instance:GetRoleInfoChange()
	if not king_role_info then return end

	local king_role_camp = king_role_info.camp_id
	if not king_role_camp then return end
	
	local index = king_role_info.role_id


	if self.king_role_id[king_role_camp] == nil or index ~= self.king_role_id[king_role_camp] then
		self:GetCampKingListId()
		return
	end

	self.model_name[king_role_camp]:SetValue(king_role_info.guild_name .. "·" .. king_role_info.role_name or "")
	self.is_model[king_role_camp]:SetValue(false)
	self.role_model[king_role_camp]:SetModelResInfo(king_role_info, false, true, false, false, true, true, false, false)
	self.is_show_name[king_role_camp]:SetValue(true)
end

function ActivityDetailView:GetCampKingListId()
    local king_id_Info = GuildFightData.Instance:GetKingIdList()
    self.king_role_id = king_id_Info
    for i = 1, GUILD_BATTLE.CAMP_TYPE_NUM do
        if king_id_Info[i] and king_id_Info[i] ~= 0 then
            CheckCtrl.Instance:SendQueryRoleInfoReq(king_id_Info[i])
        end
    end
end

function ActivityDetailView:ClearCampKingInfo()
	for i = 1, GUILD_BATTLE.CAMP_TYPE_NUM do
		self.model_name[i]:SetValue("")
		self.is_model[i]:SetValue(true)
		self.role_model[i]:ClearModel()
		self.is_show_name[i]:SetValue(false)
	end
end