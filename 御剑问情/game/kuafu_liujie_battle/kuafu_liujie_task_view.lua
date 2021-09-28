--跨服帮派战排行
KuafuTaskFollowView = KuafuTaskFollowView or BaseClass(BaseView)

local def_id_num = 
{
    [1450] = 1,                     
    [1460] = 2,
    [1461] = 3,
    [1462] = 4,
    [1463] = 5,
    [1464] = 6,
}


function KuafuTaskFollowView:__init()
	self.active_close = false
	self.view_layer = UiLayer.MainUI
	self.ui_config = {"uis/views/kuafuliujie_prefab","KuaFuBattleView"}
end

function KuafuTaskFollowView:ReleaseCallBack()
	for k,v in pairs(self.rank_items) do
		v:DeleteMe()
	end
	for k,v in pairs(self.flag_list) do
		v:DeleteMe()
	end
	if self.kuafu_guild_battle_time then
		CountDown.Instance:RemoveCountDown(self.kuafu_guild_battle_time)
		self.kuafu_guild_battle_time = nil
	end
	if self.show_mode_list_event ~= nil then
		GlobalEventSystem:UnBind(self.show_mode_list_event)
		self.show_mode_list_event = nil
	end
	self.get_all = nil
	self.time = nil
	self.rank_list = nil
	self.rich_own_score = nil
	self.reward_score = nil
	self.reward_obj = nil
	self.battle_info = nil
	self.show_panel = nil
    self.scene_id = nil
    self.title_image_list = nil
end

function KuafuTaskFollowView:LoadCallBack()
	self.scene_id = 0
	self.get_all = self:FindVariable("GetAll")
	self.time = self:FindVariable("Time")
	self.title_image_list = {}
    for i = 1, 6 do
    	self.title_image_list[i] = self:FindVariable("title_image" .. i)
    	self.title_image_list[i]:SetValue(false)
    end

	self.rank_list = self:FindObj("rank_list")
	self:InitRankPanel()

	self.rich_own_score = self:FindVariable("own_score")
	self.reward_score = self:FindVariable("reward_score")
	self.reward_obj = GuildBattleRewardRender.New(self:FindObj("reward_panel"))
	self.battle_info = self:FindObj("battle_list")
	self:InitFlagPanel()
	self.show_panel = self:FindVariable("ShowPanel")

	self:ListenEvent("ClickKuafuGuildBattle", BindTool.Bind1(self.ClickKuafuGuildBattle, self), true)
	self:ListenEvent("OnBattleRankOpen", BindTool.Bind1(self.OnBattleRankOpen, self), true)

	self.show_mode_list_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON, BindTool.Bind(self.OnMainUIModeListChange, self))

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
		self.time:SetValue("00:00")
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
        end
        PrefabPool.Instance:Free(prefab)
        self:Flush()
    end)
end

function KuafuTaskFollowView:InitRankPanel()
    self.rank_items = {}
    PrefabPool.Instance:Load(AssetID("uis/views/kuafuliujie_prefab", "RankItem"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 1, 5 do
            local obj = GameObject.Instantiate(prefab)
            obj.transform:SetParent(self.rank_list.transform, false)
            local info_cell = GuildBattleRankRender.New(obj)
            info_cell:SetIndex(i)
            self.rank_items[i] = info_cell
        end
        PrefabPool.Instance:Free(prefab)
        self:Flush()
    end)
end

function KuafuTaskFollowView:UpdateOpenCountDownTime(elapse_time, total_time)
	if total_time - elapse_time > 0 then
		self.time:SetValue(TimeUtil.FormatSecond(total_time - elapse_time, 2))
	end
end

function KuafuTaskFollowView:OnFlush()
	local rank_info = KuafuGuildBattleData.Instance:GetRankInfo()
	local notify_info = KuafuGuildBattleData.Instance:GetNotifyInfo()
	if rank_info and next(self.rank_items) then
		for i = 1, 5 do
			self.rank_items[i]:SetData(rank_info.rank_list[i])
		end
	end

	if notify_info then
		local reward_item = KuafuGuildBattleData.Instance:GetScoreReward(notify_info.param_1)
		self.rich_own_score:SetValue(string.format(Language.KuafuGuildBattle.KfOwnScore, notify_info.param_1, reward_item.score))
		self.reward_score:SetValue(reward_item.score)
		-- local data = ItemData.Instance:GetItemListInGift(reward_item.reward_item.item_id)
		-- local data = TableCopy(ItemData.Instance:GetItemListInGift(reward_item.reward_item.item_id))
		self.reward_obj:SetData(reward_item)

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

	self.scene_id = rank_info.scene_id or 0
	local num = def_id_num[self.scene_id] or 0
	for i = 1, 6 do
		if i == num then
		    self.title_image_list[i]:SetValue(true)
		else
            self.title_image_list[i]:SetValue(false)
        end
    end
end

function KuafuTaskFollowView:OnBattleRankOpen()
	KuafuGuildBattleCtrl.Instance:OpenBattleRecordPanle()
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
	self.lbl_rank:SetValue(self.index)
	self.lbl_guild_name:SetValue(self.data.guild_name)
	self.lbl_score:SetValue(self.data.score)
	self.lbl_own_num:SetValue(self.data.own_num)
end

function GuildBattleRankRender:SetIndex(index)
	self.index = index
end

function GuildBattleRankRender:SetData(data)
	self.data = data
	self:Flush()
end


-----------奖励item
GuildBattleRewardRender= GuildBattleRewardRender or BaseClass(BaseRender)


function GuildBattleRewardRender:__init()
	self.item_cell = {}
	self.item_parent = {}
	for i=1,3 do
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
	local reward_data = ItemData.Instance:GetGiftItemList(data.reward_item.item_id)
	-- self.item_parent[1].gameObject:SetActive(false)
	if reward_data and next(reward_data)  then
		local data_2 = reward_data[1]
		self.item_cell[2]:SetData(data_2)
		self.item_parent[2].gameObject:SetActive(data_2 ~= nil)
		local data_3 = reward_data[2]
		self.item_cell[3]:SetData(data_3)
		self.item_parent[3].gameObject:SetActive(data_2 ~= nil)
	else
		local data_1 = {item_id = ResPath.CurrencyToIconId.kuafu_jifen[1],num = data.cross_honor}
		local data_2 = {item_id = ResPath.CurrencyToIconId.kuafu_jifen[2], num = data.convert_credit}
		self.item_parent[2].gameObject:SetActive(true)
		self.item_cell[2]:SetData(data_1)
		self.item_parent[3].gameObject:SetActive(true)
		self.item_cell[3]:SetData(data_2)
		self.item_cell[1]:SetData(data.reward_item)
		self.item_parent[1].gameObject:SetActive(true)
	end
end




GuildBattleInfoRender= GuildBattleInfoRender or BaseClass(BaseRender)


function GuildBattleInfoRender:__init()
	self.progress = self:FindVariable("Progress")
	self.image  = self:FindVariable("Image")
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.guild_name = self:FindVariable("GuildName")
	self:ListenEvent("OnClick", BindTool.Bind1(self.OnClick, self))
end

function GuildBattleInfoRender:__delete()
end

function GuildBattleInfoRender:OnFlush()
	if nil == self.data then return end
	if self.data.plat_type ~= -1 and self.data.server_id ~= -1 then
		local color = "#00ffff"
		local name = ToColorStr(self.data.guild_name, color)
		self.guild_name:SetValue(string.format(Language.KuafuGuildBattle.KfBattleOccupy, name))
	else
		self.guild_name:SetValue(string.format(Language.KuafuGuildBattle.KfBattleOccupy, Language.KuafuGuildBattle.KfGuildNot))
	end
	local flag_cfg = KuafuGuildBattleData.Instance:GetSceneFlagCfg(Scene.Instance:GetSceneId(), self.data.monster_id)

	local guild_name = GameVoManager.Instance:GetMainRoleVo().guild_name


	if flag_cfg then
		if self.data.guild_name == guild_name then
			self.icon:SetValue(true)
			self.name:SetValue(ToColorStr(flag_cfg.flag_name,TEXT_COLOR.GREEN1))
		else
			self.icon:SetValue(false)
			self.name:SetValue(ToColorStr(flag_cfg.flag_name,TEXT_COLOR.YELLOW))
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
		self.root_node.toggle.isOn = true
		MoveCache.end_type = MoveEndType.Auto
		MoveCache.param_1 = self.data.monster_id
		GuajiCtrl.Instance:MoveToPos(flag_cfg.scene_id,flag_cfg.monster_x, flag_cfg.monster_y, 10, 10)
	end
end


function GuildBattleInfoRender:SetData(data)
	self.data = data
	self:Flush()
end

function GuildBattleInfoRender:SetIndex(index)
	self.index = index
end