--跨服帮派战排行
KuafuTaskFollowView= KuafuTaskFollowView or BaseClass(BaseView)

function KuafuTaskFollowView:__init()
	self.active_close = false
	self.is_show_right_left = true
	self.view_layer = UiLayer.MainUI
	self.ui_config = {"uis/views/kuafuliujie","KuaFuBattleView"}
	self.is_safe_area_adapter = true
end

function KuafuTaskFollowView:ReleaseCallBack()
	for k,v in pairs(self.right_info_items) do
		v:DeleteMe()
	end
	for k,v in pairs(self.left_info_items) do
		v:DeleteMe()
	end
	for k,v in pairs(self.rank_items) do
		v:DeleteMe()
	end
	for k,v in pairs(self.flag_list) do
		v:DeleteMe()
	end
	if self.kuafu_guild_battle_time then
		CountDown.Instance:RemoveCountDown(self.kuafu_guild_battle_time)
	end
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	if self.change_scene then
		GlobalEventSystem:UnBind(self.change_scene)
		self.change_scene  = nil
	end
	if self.reward_obj then
		self.reward_obj:DeleteMe()
		self.reward_obj = nil
	end
	if self.right_info_reward_obj then
		self.right_info_reward_obj:DeleteMe()
		self.right_info_reward_obj = nil
	end
	if self.left_info_reward_obj then
		self.left_info_reward_obj:DeleteMe()
		self.left_info_reward_obj = nil
	end

	self.get_all = nil
	self.time = nil
	self.rank_list = nil
	self.right_info_list = nil
	self.left_info_list = nil
	self.rich_own_score = nil
	self.reward_score = nil
	self.battle_info = nil
	self.show_panel = nil
	self.task_toggle = nil
	self.jifen_toggle = nil
	self.task_content = nil
	self.is_show_bg = nil
	self.task_text = nil
	self.rank_text = nil
	self.is_show_right_panel = nil

	if nil ~= self.move_by_click then
		GlobalEventSystem:UnBind(self.move_by_click)
		self.move_by_click = nil
	end
end

function KuafuTaskFollowView:LoadCallBack()
	self.rank_items = {}
	self.right_info_items = {}
	self.left_info_items = {}
	self.left_jie_info_items = {}

	self.reward_obj = GuildBattleRewardRender.New(self:FindObj("reward_panel"))
	self.right_info_reward_obj = GuildBattleRewardRender.New(self:FindObj("RightInfoRewardPanel"))
	self.left_info_reward_obj = GuildBattleRewardRender.New(self:FindObj("LeftInfoRewardPanel"))
	self.left_jie_reward_obj = GuildBattleRewardRender.New(self:FindObj("LeftInfoRePanel"))

	self.get_all = self:FindVariable("GetAll")
	self.time = self:FindVariable("Time")
	self.is_show_right_panel = self:FindVariable("IsShowRightPanle")

	self.task_toggle = self:FindObj("TaskToggle")
	self.jifen_toggle = self:FindObj("JiFenToggle")
	self.task_content = self:FindObj("TaskContent")

	self.rich_own_score = self:FindVariable("own_score")
	self.reward_score = self:FindVariable("reward_score")
	self.is_show_bg = self:FindVariable("IsShowBg")
	self.task_text = self:FindVariable("TaskText")
	self.rank_text = self:FindVariable("RankText")

	self.show_jie = self:FindVariable("ShowJie")

	self.rank_list = self:FindObj("rank_list")
	self.right_info_list = self:FindObj("RightInfoList")
	self.left_info_list = self:FindObj("LeftInfoList")
	self.left_jie_info_list = self:FindObj("LeftRankList")
	self:InitRankPanel(self.rank_items, self.rank_list, false)
	self:InitRankPanel(self.right_info_items, self.right_info_list, true)
	self:InitRankPanel(self.left_info_items, self.left_info_list, true)
	self:InitRankPanel(self.left_jie_info_items, self.left_jie_info_list, true)

	self.battle_info = self:FindObj("battle_list")
	self:InitFlagPanel()
	self.show_panel = self:FindVariable("ShowPanel")
	self:ListenEvent("ClickKuafuGuildBattle", BindTool.Bind1(self.ClickKuafuGuildBattle, self), true)
	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.change_scene = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind1(self.OnSceneChangeComplete, self))

	if self.move_by_click == nil then
		self.move_by_click = GlobalEventSystem:Bind(OtherEventType.MOVE_BY_CLICK, BindTool.Bind(self.OnMoveByClick, self))
	end
end

function KuafuTaskFollowView:OnMoveByClick()
	if self.select_index and self.select_index > 0 then
		self:SetSelectIndex(0)
		self:FlushCellHl()
	end
end

function KuafuTaskFollowView:OpenCallBack()
	local time, next_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.KF_GUILDBATTLE)
	if self.kuafu_guild_battle_time then
		CountDown.Instance:RemoveCountDown(self.kuafu_guild_battle_time)
		self.kuafu_guild_battle_time = nil
	end
	if next_time > TimeCtrl.Instance:GetServerTime() then
		self.kuafu_guild_battle_time = CountDown.Instance:AddCountDown(next_time- TimeCtrl.Instance:GetServerTime(), 1, BindTool.Bind1(self.UpdateOpenCountDownTime, self))
	else
		self.time:SetValue("00:00:00")
	end

	self.jifen_toggle.toggle.isOn = true
	self.task_toggle.gameObject:SetActive(false)
	self.task_content.gameObject:SetActive(false)
	self.is_show_bg:SetValue(false)

	local notify_info = KuafuGuildBattleData.Instance:GetNotifyInfo()
	if notify_info ~= 3150 then	
		self:OnSceneChangeComplete()
	end
end

function KuafuTaskFollowView:OnMainUIModeListChange(is_show)
	self.show_panel:SetValue(is_show)
	if is_show then
		self:Flush()
	end
end

function KuafuTaskFollowView:ClickKuafuGuildBattle()
	KuafuGuildBattleCtrl.Instance:OpenRecordPanle()
end

function KuafuTaskFollowView:OnSceneChangeComplete()
	local scene_id = Scene.Instance:GetSceneId()
	self.rank_text:SetValue(Language.KuafuGuildBattle.RankText[2])
	if scene_id == 3150 then
		self.task_toggle.gameObject:SetActive(false)
		self.task_content.gameObject:SetActive(false)
		self.is_show_bg:SetValue(false)
		self.jifen_toggle.toggle.isOn = true
		self.task_text:SetValue(Language.KuafuGuildBattle.TaskText[2])
	else	
		self.task_toggle.gameObject:SetActive(true)
		self.task_content.gameObject:SetActive(true)	
		self.is_show_bg:SetValue(true)
		self.jifen_toggle.toggle.isOn = false
		self.task_toggle.toggle.isOn = true
		self.task_text:SetValue(Language.KuafuGuildBattle.TaskText[1])
	end
	self:SetSelectIndex(0)
	self:FlushCellHl()
end

function KuafuTaskFollowView:InitFlagPanel()

    self.flag_list = {}
    PrefabPool.Instance:Load(AssetID("uis/views/kuafuliujie_prefab", "GuildFightFlagCell"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 1, 3 do
            local obj = GameObject.Instantiate(prefab)
            obj.transform:SetParent(self.battle_info.transform, false)
            local info_cell = GuildBattleInfoRender.New(obj)
            info_cell:SetIndex(i)
            self.flag_list[i] = info_cell
			self.flag_list[i].mother_view = self
        end
        PrefabPool.Instance:Free(prefab)
        self:Flush()
    end)
end

function KuafuTaskFollowView:InitRankPanel(target_items, target_list, is_show)
	if target_items == nil or target_list == nil then return end

    PrefabPool.Instance:Load(AssetID("uis/views/kuafuliujie_prefab", "RankItem"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 1, 5 do
            local obj = GameObject.Instantiate(prefab)
            obj.transform:SetParent(target_list.transform, false)
            local info_cell = GuildBattleRankRender.New(obj)
            info_cell:SetIndex(i)
            info_cell:SetIsrightleft(is_show)
            target_items[i] = info_cell
        end
        PrefabPool.Instance:Free(prefab)
        self:Flush()
    end)
 

end

function KuafuTaskFollowView:UpdateOpenCountDownTime(elapse_time, total_time)
	if total_time - elapse_time > 0 then
		self.time:SetValue(TimeUtil.FormatSecond(total_time - elapse_time, 3))
	end
end

function KuafuTaskFollowView:OnFlush()
	local rank_info = KuafuGuildBattleData.Instance:GetRankInfo()
	local notify_info = KuafuGuildBattleData.Instance:GetNotifyInfo()
	local scene_id = Scene.Instance:GetSceneId()

	if self.show_jie ~= nil then
		self.show_jie:SetValue(scene_id == 3156)
	end

	local is_flush_items = scene_id == 3050 and next(self.left_info_items) or (next(self.rank_items) and next(self.right_info_items) and next(self.left_jie_info_items))
	if rank_info and is_flush_items then
		for i = 1, 5 do
			if scene_id ~= 3150 then
				self.is_show_right_panel:SetValue(true)
				self.rank_items[i]:SetData(rank_info.rank_list[i])
				if scene_id == 3156 then
					self.left_jie_info_items[i]:SetData(rank_info.first_place_list[i + 1])
				else
					self.right_info_items[i]:SetData(rank_info.first_place_list[i + 1])
				end
			else
				self.is_show_right_panel:SetValue(false)	
				self.left_info_items[i]:SetData(rank_info.first_place_list[i + 1])
			end
		end
	end

	if notify_info then
		local reward_item = KuafuGuildBattleData.Instance:GetScoreReward(notify_info.param_1)
		self.rich_own_score:SetValue(ToColorStr(string.format(Language.KuafuGuildBattle.KfOwnScore, notify_info.param_1, reward_item.score), TEXT_COLOR.YELLOW))
		self.reward_score:SetValue(reward_item.score)
		-- local data = ItemData.Instance:GetItemListInGift(reward_item.reward_item.item_id)
		-- local data = TableCopy(ItemData.Instance:GetItemListInGift(reward_item.reward_item.item_id))
		
		if scene_id == 3150 then
			self.left_info_reward_obj:SetData(reward_item)
		else
			if scene_id == 3156 then
				self.left_jie_reward_obj:SetData(reward_item)
			else
				self.right_info_reward_obj:SetData(reward_item)
			end
			self.reward_obj:SetData(reward_item)
		end 
		
		local yilingwan_bool = KuafuGuildBattleData.Instance:GetMaxScoreReward(notify_info.param_1)
		self.get_all:SetValue(yilingwan_bool)
		-- self.layout_rank.img_yilingwan.node:setLocalZOrder(999)
	end
	if next(self.flag_list) and rank_info then
		-- self.battle_info:SetDataList(rank_info.flag_list)
		for i=1, #rank_info.flag_list do
			self.flag_list[i]:SetData(rank_info.flag_list[i])
		end
	end

end

function KuafuTaskFollowView:SetSelectIndex(index)
	self.select_index = index
end

function KuafuTaskFollowView:GetSelectIndex(index)
	return self.select_index
end

function KuafuTaskFollowView:FlushCellHl()
	for k,v in pairs(self.flag_list) do
		v:FlushHl()
	end
end
----------------------------------------------BaseRender------------------------------------------------------------------------------
GuildBattleRankRender= GuildBattleRankRender or BaseClass(BaseRender)


function GuildBattleRankRender:__init()
	self.lbl_rank = self:FindVariable("rank")
	self.lbl_guild_name = self:FindVariable("guild_name")
	self.lbl_score = self:FindVariable("score")
	self.lbl_own_num = self:FindVariable("own_num")
end

function GuildBattleRankRender:__delete()

end

function GuildBattleRankRender:OnFlush()
	if nil == self.data then
		self.root_node:SetActive(false)
		return
	end
	self.root_node:SetActive(true)
	local scene_id = Scene.Instance:GetSceneId()

	if scene_id ~= nil then
		if self.bool then
			self.lbl_rank:SetValue(KuaFfLiuJieSceneIdName[self.index])
		elseif scene_id >= 3150 and scene_id <= 3154 then
			self.lbl_rank:SetValue(KuaFfLiuJieSceneIdName[scene_id - 3150])
		end
	end
	
	self.lbl_guild_name:SetValue(self.data.server_id ~= -1 and self.data.guild_name .. "_s" .. self.data.server_id or Language.KuafuGuildBattle.NoCamp)
	self.lbl_score:SetValue(self.data.score)
	self.lbl_own_num:SetValue(self.data.own_num)
end

function GuildBattleRankRender:SetIndex(index)
	self.index = index
end

function GuildBattleRankRender:SetIsrightleft(bool)
	self.bool = bool
end

function GuildBattleRankRender:SetData(data)
	self.data = data
	self:Flush()
end


-----------------------------奖励item--------------------------
GuildBattleRewardRender= GuildBattleRewardRender or BaseClass(BaseRender)


function GuildBattleRewardRender:__init()
	self.item_cell = {}
	self.item_parent = {}
	for i = 1, 3 do
		self.item_parent[i] = self:FindObj("item" .. i)
		self.item_cell[i] = ItemCell.New()
		self.item_cell[i]:SetInstanceParent(self.item_parent[i])
	end
end

function GuildBattleRewardRender:__delete()
	for k,v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
end

function GuildBattleRewardRender:SetData(data)
	-- local data_1 = {item_id = ResPath.CurrencyToIconId.exp, num = data.exp}
	-- local reward_data = ItemData.Instance:GetGiftItemList(data.reward_item.item_id)
	-- self.item_parent[1].gameObject:SetActive(false)
	-- if reward_data and next(reward_data)  then
	-- 	local data_2 = reward_data[1]
	-- 	self.item_cell[2]:SetData(data_2)
	-- 	self.item_parent[2].gameObject:SetActive(data_2 ~= nil)
	-- 	local data_3 = reward_data[2]
	-- 	self.item_cell[3]:SetData(data_3)
	-- 	self.item_parent[3].gameObject:SetActive(data_2 ~= nil)
	-- else
	-- 	local data_1 = {item_id = ResPath.CurrencyToIconId.kuafu_jifen, num = data.convert_credit}
	-- 	self.item_parent[2].gameObject:SetActive(true)
	-- 	self.item_cell[2]:SetData(data_1)
	-- 	self.item_parent[3].gameObject:SetActive(false)
	-- 	self.item_cell[1]:SetData(data.reward_item)
	-- 	self.item_parent[1].gameObject:SetActive(true)
	-- end
	self.item_cell[1]:SetData(data.reward_item)
	self.item_parent[2].gameObject:SetActive(false)
	self.item_parent[3].gameObject:SetActive(false)
end


--------------------------------领主item-------------------------------
GuildBattleInfoRender = GuildBattleInfoRender or BaseClass(BaseRender)

function GuildBattleInfoRender:__init()
	self.progress = self:FindVariable("Progress")
	self.image  = self:FindVariable("Image")
	self.name = self:FindVariable("Name")
	self.guild_name = self:FindVariable("GuildName")
	self.show_hl = self:FindVariable("show_hl")
	self:ListenEvent("OnClick", BindTool.Bind1(self.OnClick, self))
end

function GuildBattleInfoRender:__delete()
	self.mother_view = nil
end

function GuildBattleInfoRender:OnFlush()
	if nil == self.data then return end
	local flag_cfg = KuafuGuildBattleData.Instance:GetSceneFlagCfg(Scene.Instance:GetSceneId(), self.data.monster_id)

	if flag_cfg then
		local main_role = GameVoManager.Instance:GetMainRoleVo()
		if main_role.origin_merge_server_id == self.data.server_id and main_role.camp == NAME_TYPE_TO_CAMP[self.data.guild_name] then
			self.name:SetValue(ToColorStr(flag_cfg.flag_name, "#56f562"))
		else
			self.name:SetValue(ToColorStr(flag_cfg.flag_name, "#fffa6d"))
		end

		if self.data.plat_type ~= -1 and self.data.server_id ~= -1 then
			self.guild_name:SetValue(ToColorStr(string.format(Language.KuafuGuildBattle.KfBattleName, self.data.guild_name, self.data.server_id), CAMP_COLOR[self.data.camp_id]))
		else
			self.guild_name:SetValue(Language.KuafuGuildBattle.KfGuildNot)
		end

		self.image:SetValue(flag_cfg.flag_type ~= 0)
	end
 	self.progress:SetValue(self.data.cur_hp / self.data.max_hp * 100)
end

function GuildBattleInfoRender:OnClick()
	
	local flag_cfg = KuafuGuildBattleData.Instance:GetSceneFlagCfg(Scene.Instance:GetSceneId(), self.data.monster_id)
	if nil ~= flag_cfg then
		-- Scene.Instance:ClearAllOperate()
		-- local cache = Scene.Instance:GetMoveToPosCache()
		-- cache.target_obj_type = SceneObjType.Monster
		-- cache.cache_reason = "fly_boss_scene"
		self.mother_view:SetSelectIndex(self.index)
		self.root_node.toggle.isOn = true
		MoveCache.end_type = MoveEndType.Auto
		MoveCache.param_1 = self.data.monster_id
		GuajiCtrl.Instance:MoveToPos(flag_cfg.scene_id,flag_cfg.monster_x, flag_cfg.monster_y, 10, 10)
		self.mother_view:FlushCellHl()
	end
end

function GuildBattleInfoRender:SetData(data)
	self.data = data
	self:Flush()
end

function GuildBattleInfoRender:SetIndex(index)
	self.index = index
end

function GuildBattleInfoRender:FlushHl()
	self.show_hl:SetValue(self.index == self.mother_view:GetSelectIndex())
end
--------------------------------领主item-------------------------------
