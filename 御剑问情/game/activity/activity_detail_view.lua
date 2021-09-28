ActivityDetailView = ActivityDetailView or BaseClass(BaseView)

function ActivityDetailView:__init()
	self.ui_config = {"uis/views/activityview_prefab","ActivityDetailView"}
	self.act_id = 0
	self.play_audio = true
end

function ActivityDetailView:__delete()

end

function ActivityDetailView:ReleaseCallBack()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end

	if self.tower_model ~= nil then
		self.tower_model:DeleteMe()
		self.tower_model = nil
	end
	self.item_list = {}

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
	self.btn3_text = nil
	self.show_btn_3 = nil
	self.show_yizhandaodi_txt = nil
	self.yizhandaodi_name = nil
	self.show_gouyu_butten = nil
	self.duihuan_image = nil
	self.is_shengwang = nil
	self.duihuan_number = nil
	self.show_smallgouyu_button = nil
	self.showxiuluotower = nil
	self.show_shuijing_plane = nil
	self.shuijing_gold = nil
	self.shuijing_mojing = nil
	self.shuijing_shengwang = nil
	self.display = nil
	self.xiuluoname = nil
	self.showxianmorightpanel = nil
	self.xiuluozhanli = nil
	self.is_jinghua_husong = nil
	self.big_jinghua_num = nil
	self.small_jinghua_num = nil
	self.showtimetitle = nil

	self.title_text = nil
	self.title_image = nil
	self.show_title = nil

	for i = 1, 3 do
		self["xiuluota_title" .. i] = nil
		self.text_name[i] = nil
	end

	self.show_xianmo_text = nil

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
	self.btn3_text = self:FindVariable("BtnText3")				--按钮3文本
	self.show_btn_2 = self:FindVariable("ShowBtn2")				--是否显示按钮2
	self.show_btn_3 = self:FindVariable("ShowBtn3")				--是否显示按钮3
	self.show_yizhandaodi_txt = self:FindVariable("ShowYiZhanDaoDiText")		-- 显示一战到底描述
	self.yizhandaodi_name = self:FindVariable("YiZhanDaoDiName")		-- 显示一战人名

	self.show_gouyu_butten = self:FindVariable("ShowGouYuButten")	-- 显示勾玉兑换按钮
	self.duihuan_image = self:FindVariable("DuiHuanImage")
	self.is_shengwang = self:FindVariable("IsShengWang")
	self.duihuan_number = self:FindVariable("DuiHuanNumber")
	self.show_smallgouyu_button = self:FindVariable("ShowSmallGouyuButton")
	self.showxiuluotower = self:FindVariable("ShowxiuluoTower")
	self.display = self:FindObj("Display")
	self.tower_model = RoleModel.New()
	self.tower_model:SetDisplay(self.display.ui3d_display)
	self.xiuluoname = self:FindVariable("xiuluoname")
	self.showxianmorightpanel = self:FindVariable("ShowXianMoRightPanel")
	self.xiuluozhanli = self:FindVariable("xiuluozhanli")
    self.show_xianmo_text = self:FindVariable("show_xianmo_text")
    self.showtimetitle = self:FindVariable("ShowTimeTitle")
    self.text_name = {}
	for i = 1, 3 do
		self["xiuluota_title" .. i] = self:FindVariable("xiuluota_title" .. i)
		self.text_name[i] = self:FindVariable("text" .. i)
	end
	--显示左侧标题
	self.title_text = self:FindVariable("LeftTitleText")
	self.title_image =self:FindVariable("LeftTitleImage")
	self.show_title =self:FindVariable("ShowLeftTitle")

	--水晶幻境面板
	self.show_shuijing_plane = self:FindVariable("ShowShuiJingPlane")
	self.shuijing_gold = self:FindVariable("ShuijingGold")
	self.shuijing_mojing = self:FindVariable("ShuijingMojing")
	self.shuijing_shengwang = self:FindVariable("ShuijingShengwang")

	--精华护送
	self.is_jinghua_husong = self:FindVariable("IsJingHuaHuSong")
	self.big_jinghua_num = self:FindVariable("BigJingHuaNum")
	self.small_jinghua_num = self:FindVariable("SmallJingHuaNum")

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
	self:ListenEvent("ClickBtn3", BindTool.Bind(self.ClickBtn3, self))
	self:ListenEvent("MinghunClick", BindTool.Bind(self.MinghunClick, self))
	self:ListenEvent("ClickDuiHuan", BindTool.Bind(self.ClickDuiHuan, self))
	self:ListenEvent("ClickRiZhi", BindTool.Bind(self.ClickLog, self))
	for i = 1, 3 do
		self:ListenEvent("ClickZhanShenTitle" .. i, BindTool.Bind(self.ClickTitle, self, i))
	end

	ActivityCtrl.Instance:SendQunxianLuandouFirstRankInfo()
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

function ActivityDetailView:ClickDuiHuan()
	local is_xiuluotower = (self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER)
	if is_xiuluotower then
		ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_rongyao)
	else
		ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_shengwang)
	end
end

function ActivityDetailView:ClickLog()
	TipsCtrl.Instance:ShowKFRecordView()
end

function ActivityDetailView:ClickTitle(index)
	local title_cfg = {}
	if self.act_id == ACTIVITY_TYPE.CHAOSWAR then
        title_cfg = ActivityData.Instance:GetZhanShenItemCfg()
        if title_cfg and title_cfg[index] then
		    local data = {item_id = title_cfg[index].item_id, is_bind= 0, num = 1}
		    TipsCtrl.Instance:OpenItem(data)
	    end
	elseif self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU then
    	title_cfg = ActivityData.Instance:GetXianMoItemCfg()
    	local get_index = ActivityData.TitleType[index]
    	if  title_cfg and title_cfg[get_index] then
			local data = {item_id = title_cfg[get_index].item_id, is_bind= 0, num = 1}
			TipsCtrl.Instance:OpenItem(data)
    	end
    end

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
	if self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER then
		if not ActivityData.Instance:GetActivityIsOpen(self.act_id) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		else
			ViewManager.Instance:Open(ViewName.FuXiuLuoTowerBuffView)
		end
	elseif self.act_id == ACTIVITY_TYPE.ZHUAGUI then
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
	elseif self.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG then 						--精华护送
		if JingHuaHuSongCtrl.Instance:IsOpen() then
			--前往采集物
			JingHuaHuSongCtrl.Instance:MoveToGather(false, JingHuaHuSongData.JingHuaType.Small)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		end
		return
	end
end

function ActivityDetailView:ClickBtn3()
	if self.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG then 						--精华护送
		if JingHuaHuSongCtrl.Instance:IsOpen() then
			--前往采集物
			JingHuaHuSongCtrl.Instance:MoveToGather(false, JingHuaHuSongData.JingHuaType.Small)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		end
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
	if self.act_id == ACTIVITY_TYPE.ZHUAGUI then 									-- 秘境降魔
		if scene_id == 106 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongYiZai)
		else
			GuajiCtrl.Instance:FlyToScene(106)
		end
		self:CloseWindow()
		ViewManager.Instance:Close(ViewName.Activity)
		return
	elseif self.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG then 						--精华护送
		if JingHuaHuSongCtrl.Instance:IsOpen() then
			--前往采集物
			JingHuaHuSongCtrl.Instance:MoveToGather(false, JingHuaHuSongData.JingHuaType.Big)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
		end
		return
	elseif self.act_id == ACTIVITY_TYPE.GUILD_MONEYTREE then
		local guild_id = GuildData.Instance.guild_id
		if guild_id and guild_id > 0 then
			GuildCtrl.Instance:SendGuildBackToStationReq(guild_id)
		end
		return
	end
	--]]
	if not ActivityData.Instance:GetActivityIsOpen(self.act_id) then
		if self.act_id ~= ACTIVITY_TYPE.HUSONG then
			SysMsgCtrl.Instance:ErrorRemind(Language.Activity.HuoDongWeiKaiQi)
			return
		end
	end

	if self.act_id == DaFuHaoDataActivityId.ID then									-- 大富豪
		 if ActivityData.Instance:GetActivityStatuByType(self.act_id) == nil or
			ActivityData.Instance:GetActivityStatuByType(self.act_id).status ~= ACTIVITY_STATUS.OPEN then
			TipsCtrl.Instance:ShowSystemMsg(Language.Guild.GUILDJIUHUINOOPEN)
			return
		end
		local cfg = DaFuHaoData.Instance:GetDaFuHaoOtherCfg()
		if nil ~= cfg then
			-- local index = math.random(1, #cfg)
			ActivityCtrl.Instance:SendActivityEnterReq(DaFuHaoDataActivityId.ID)
			-- GuajiCtrl.Instance:MoveToScenePos(cfg.scene_id, cfg.fly_pos_x, cfg.fly_pos_y, true, 0)
			DaFuHaoCtrl.Instance:SendGetGatherInfoReq()
		end
	elseif self.act_id == ACTIVITY_TYPE.KF_HOT_SPRING 									-- 泳池派对
		or self.act_id == ACTIVITY_TYPE.KF_MINING										-- 跨服挖矿
		or self.act_id == ACTIVITY_TYPE.KF_FISHING then									-- 跨服钓鱼
			CrossServerCtrl.Instance:SendCrossStartReq(self.act_id)

			self:CloseWindow()
	elseif self.act_id == ACTIVITY_TYPE.CROSS_SHUIJING then						-- 跨服水晶
		CrossServerCtrl.Instance:SendCrossStartReq(self.act_id)
	elseif self.act_id == ACTIVITY_TYPE.HUSONG then									-- 运镖
		ViewManager.Instance:CloseAll()
		YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
		return
	elseif self.act_id == ACTIVITY_TYPE.GUILD_BONFIRE_OPEN then						-- 仙女赐福
		ViewManager.Instance:CloseAll()
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_activity)
		return
	elseif self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER then						-- 修罗塔
		local state_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_XIULUO_TOWER)
		if state_info ~= nil and state_info.status == 2 then
			KuaFuXiuLuoTowerCtrl.Instance:SendEnterXiuLuoTowerFuBen()
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Activity.HuoDongWeiKaiQi)
		end
	elseif self.act_id == ACTIVITY_TYPE.GUILD_BOSS then
		GuildCtrl.Instance:SendGuildBackToStationReq(GameVoManager.Instance:GetMainRoleVo().guild_id)
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

	if self.act_id == ACTIVITY_TYPE.HUANGCHENGHUIZHAN then
		ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.HUANGCHENGHUIZHAN,1)
	end

	ViewManager.Instance:CloseAll()
end

--记录活动id
function ActivityDetailView:SetActivityId(act_id)
	self.act_id = act_id
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
	local level_str = PlayerData.GetLevelString(min_level)
	local time_des = ""

	if act_info.is_allday == 1 then
		time_des = Language.Activity.AllDay
		if self.act_id == ACTIVITY_TYPE.SHUIJING then
			time_des = time_des .. "," .. string.format(Language.Activity.DoubleRewardTime, act_info.open_time .. "-" .. act_info.end_time)
		end
	else
		time_des = self:GetChineseWeek(act_info)
	end

	local detailexplain = string.format(Language.Activity.DetailExplain, level_str, time_des, act_info.dec)
	if self.act_id == ACTIVITY_TYPE.CLASH_TERRITORY then
		local guild_id = PlayerData.Instance.role_vo.guild_id or 0
		local match_name = ClashTerritoryData.Instance:GetTerritoryWarMatch(guild_id)
		detailexplain = string.format(Language.Activity.TerritoryWarExplain, level_str, time_des, match_name)
	end
	self.explain:SetValue(detailexplain)
end

--设置是否显示奖励
function ActivityDetailView:SetRewardState(act_info)
	if act_info and act_info.reward_item1 and next(act_info.reward_item1) then
		self.show_item_list:SetValue(true)
		for k, v in ipairs(self.item_list) do
			if act_info["reward_item" .. k] and next(act_info["reward_item" .. k]) and act_info["reward_item" .. k].item_id ~= 0 then
				self.item_list[k].root_node:SetActive(true)
				act_info["reward_item" .. k].is_bind = 0
				self.item_list[k]:SetData(act_info["reward_item" .. k])
			else
				self.item_list[k]:SetInteractable(false)
				self.item_list[k].root_node:SetActive(false)
			end
		end
	else
		self.show_item_list:SetValue(false)
	end
end

function ActivityDetailView:SetYiZhanDaoDiInfo()
	local first_info = YiZhanDaoDiData.Instance:GetYiZhanDaoDiLastFirstInfo()
	local first_name = ""
	if nil == first_info.uid or first_info.uid <= 0 then
		first_name = Language.Competition.NoRank
	else
		first_name = first_info.game_name or ""
	end
	self.yizhandaodi_name:SetValue(first_name)
	self.show_yizhandaodi_txt:SetValue(self.act_id == ACTIVITY_TYPE.CHAOSWAR)
end

function ActivityDetailView:SetXianMoInfo()
	local first_info = ActivityData.Instance:GetQunxianLuandouFirstRankInfo()
	for i = 1, 3 do
		local first_name = ""
		if nil == first_info or nil == first_info[i] or "" == first_info[i] then
			first_name = Language.Competition.NoRank
		else
			first_name = Language.Competition.LastGame .. first_info[i] or ""
		end
		self.text_name[i]:SetValue(first_name)
	end
end

function ActivityDetailView:OnFlush()
	local act_info = ActivityData.Instance:GetActivityInfoById(self.act_id)
	if not next(act_info) then return end

	self:SetYiZhanDaoDiInfo()
    self:SetXianMoInfo()
	self.open_day_list = Split(act_info.open_day, ":")

	self:SetTitleTime(act_info)
	self:SetRewardState(act_info)
	self:SetExplain(act_info)

	self.is_zhuagui:SetValue(false)
	self.show_btn_2:SetValue(self.act_id == ACTIVITY_TYPE.ZHUAGUI)
	self.show_btn_3:SetValue(self.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG)
    self.show_xianmo_text:SetValue(self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU)
	--按钮文字
	local btn_str = Language.Common.EnterScene
	if self.act_id == ACTIVITY_TYPE.ZHUAGUI then
		btn_str = Language.Activity.GoToZhuaGui
		self.is_zhuagui:SetValue(true)
		self.btn2_text:SetValue(Language.Society.WorldInviety)
		local zhuagui_info = ZhuaGuiData.Instance:GetCurDayZhuaGuiInfo()

		self.zhuagui_num:SetValue(zhuagui_info.zhuagui_day_catch_count)
		self.hunli_num:SetValue(zhuagui_info.zhuagui_day_gethunli)
		-- end
	elseif self.act_id == ACTIVITY_TYPE.HUSONG then
		btn_str = Language.Common.QianWang
	elseif self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER then
		self.btn2_text:SetValue(Language.Activity.BuyBuff)
	elseif self.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG then
		btn_str = Language.JingHuaHuSong.GatherBigJingHua
	end
	self.btn_text:SetValue(btn_str)

	if self.act_id == ACTIVITY_TYPE.GUILD_MONEYTREE then
		self.showtimetitle:SetValue(false)
	else
		self.showtimetitle:SetValue(true)
	end

	--活动名字
	self.title_name:SetValue(act_info.act_name)

	--设置活动底图
	local bundle, asset = ResPath.GetActivityBg(self.act_id)
	self.activity_bg:SetAsset(bundle, asset)

	-- 显示掉落日志
	if self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER then
		local cfg = KuaFuXiuLuoTowerData.Instance:GetItemID()
		local show_id = cfg.model_show or 0
		local zhanli = cfg.fight_show or 0
		local show_list = Split(show_id, ",")
		local display_name = "kf_xiuluota_pane"
		local bundle, asset = show_list[1], show_list[2]
		self.showxiuluotower:SetValue(true)
		self.tower_model:SetPanelName(display_name)
		self.tower_model:SetMainAsset(bundle, asset)
		self.xiuluozhanli:SetValue(zhanli)
	else
		self.showxiuluotower:SetValue(false)
	end

	if self.act_id == ACTIVITY_TYPE.CHAOSWAR then
		local title_cfg = ActivityData.Instance:GetZhanShenItemCfg()
		self.showxianmorightpanel:SetValue(true)
		for i = 1, 3 do
			if nil ~= title_cfg and nil ~= title_cfg[i] then
				local title_id = Split(title_cfg[i].title_show, ",")
				self["xiuluota_title" .. i]:SetAsset(title_id[1], title_id[2])
			end
		end	
	elseif self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU then
        local title_cfg = ActivityData.Instance:GetXianMoItemCfg()
		self.showxianmorightpanel:SetValue(true)
		for k, v in pairs(ActivityData.TitleType) do
			if nil ~= title_cfg and nil ~= title_cfg[v] then
			    local get_title = title_cfg[v].title_show or ""
				local title_id = Split(get_title, ",")
				local bundle, asset = title_id[1], title_id[2]
				self["xiuluota_title" .. k]:SetAsset(bundle, asset)
		    end
		end
	else
		self.showxianmorightpanel:SetValue(false)
	end

	--水晶幻境面板
	self:SetShuijingPlane()

	--精华护送
	self:SetJingHuaData()

	self:ShowLeftTitle()
	--兑换按钮
	self.show_smallgouyu_button:SetValue(false)
	if self:CanShowDuiHuanButten() then
		if self.act_id == ACTIVITY_TYPE.CHAOSWAR or self.act_id == ACTIVITY_TYPE.SHUIJING or self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU then
			self.show_gouyu_butten:SetValue(false)
			self.show_smallgouyu_button:SetValue(true)
		else
			self.show_gouyu_butten:SetValue(true)
			self.show_smallgouyu_button:SetValue(false)
		end
		local is_xiuluotower = (self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER)
		local bundle, asset = "uis/icons/item/7000_atlas", is_xiuluotower and "Item_7126" or "Item_7026"
		local score_type = is_xiuluotower and EXCHANGE_PRICE_TYPE.RONGYAO or EXCHANGE_PRICE_TYPE.SHENGWANG
		local nume = CommonDataManager.ConverMoney(ExchangeData.Instance:GetCurrentScore(score_type))
		self.duihuan_image:SetAsset(bundle, asset)
		self.is_shengwang:SetValue(not is_xiuluotower)
		self.duihuan_number:SetValue(nume)
	else
		self.show_gouyu_butten:SetValue(false)
	end
end

function ActivityDetailView:CanShowDuiHuanButten()
	if self.act_id == ACTIVITY_TYPE.QUNXIANLUANDOU
		or self.act_id == ACTIVITY_TYPE.CHAOSWAR	
		or self.act_id == ACTIVITY_TYPE.SHUIJING
		or self.act_id == ACTIVITY_TYPE.GONGCHENGZHAN
		or self.act_id == ACTIVITY_TYPE.KF_XIULUO_TOWER then
		return true
	end
	return false
end

function ActivityDetailView:ShowLeftTitle()
	if nil == ActivityData.ShowLeftTitle[self.act_id] then
		self.show_title:SetValue(false)
		return
	end
	
	self.show_title:SetValue(true)
	local data = ActivityData.Instance:GetClockActivityByID(self.act_id)
	self.title_image:SetAsset(ResPath.GetTitleIcon(data.title_id))
	-- self.title_text:SetValue(Language.ShowActivityTitle[self.act_id])
end

function ActivityDetailView:SetShuijingPlane()
	self.show_shuijing_plane:SetValue(self.act_id == ACTIVITY_TYPE.SHUIJING)
	if self.act_id == ACTIVITY_TYPE.SHUIJING then
		local bigshuijing_cfg = CrossCrystalData.Instance:GetMaxBigShuiJingInfoList()
		if bigshuijing_cfg[1] then
			--策划说活动开启时采集奖励都翻倍
			local bind_gold = tonumber(bigshuijing_cfg[1].bind_gold) * 2
			local mojing = tonumber(bigshuijing_cfg[1].mojing) * 2
			local shengwang = tonumber(bigshuijing_cfg[1].shengwang) * 2
			self.shuijing_gold:SetValue(string.format(Language.Rune.AttrDes_shuijing, bind_gold))
			self.shuijing_mojing:SetValue(string.format(Language.Rune.AttrDes_shuijing, mojing))
			self.shuijing_shengwang:SetValue(string.format(Language.Rune.AttrDes_shuijing, shengwang))
		end
	end
end

function ActivityDetailView:SetJingHuaData()
	if self.act_id == ACTIVITY_TYPE.JINGHUA_HUSONG then
		self.is_jinghua_husong:SetValue(true)
		self.big_jinghua_num:SetValue(JingHuaHuSongData.Instance:GetJingHuaGatherAmountByType(JingHuaHuSongData.JingHuaType.Big))
		self.small_jinghua_num:SetValue(JingHuaHuSongData.Instance:GetJingHuaGatherAmountByType(JingHuaHuSongData.JingHuaType.Small))
		self.btn3_text:SetValue(Language.JingHuaHuSong.GatherSmallJingHua)
	else
		self.is_jinghua_husong:SetValue(false)
	end
end