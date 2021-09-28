require("game/kuafu_liujie_battle/kuafu_liujie_bossinfo_view")
require("game/kuafu_liujie_battle/kuafu_liujie_showinfo_view")
require("game/kuafu_liujie_battle/kuafu_tj_boss_view")
require("game/kuafu_liujie_battle/kuafu_sw_boss_view")

KuafuGuildBattleView = KuafuGuildBattleView or BaseClass(BaseView)
--地图信息顺序：1，2，3，4，5，6 2为主城
--任务信息顺序：0，1，2，3，4，5 0为主城
local Task_Map_Index =
{
	[1] = 1,
	[2] = 0,
	[3] = 2,
	[4] = 3,
	[5] = 4,
	[6] = 5,
}

KuafuGuildBattleView.TabIndex = {
	liujie = 1,
	bossinfo = 2,
	show = 3,
}
function KuafuGuildBattleView:__init()
	self.ui_config = {"uis/views/kuafuliujie_prefab","KuaFULiuJieView"}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.def_index = TabIndex.activity_kuafu_liujie
end

function KuafuGuildBattleView:LoadCallBack()

	self.item_list = {}
	for i=1, 6 do
		self.item_list[i] = KuafuGuildItemRender.New(self:FindObj("Item" .. i))
		self.item_list[i]:SetIndex(i)
	end

	self.tips_text = self:FindVariable("tips")
	self.is_show = self:FindVariable("is_show")
	self.in_liu_jie = self:FindVariable("InLiuJIe")
	self.gold = self:FindVariable("gold")
	self.bind_gold = self:FindVariable("bind_gold")
	self.tab_champion = self:FindVariable("tab_champion")

	self:ListenEvent("OnEnterCross", BindTool.Bind1(self.OnEnterCross, self), true)

	self:ListenEvent("ClickKfBattleDesc", BindTool.Bind(self.ClickKfBattleDesc, self))

	self.ShowBox = self:FindVariable("ShowBox")
	self.rewards = self:FindObj("Rewards")

	self.boss_info_panel = KuafuLiuJieBossInfoView.New(self:FindObj("BossInfo"))
	self.show_info_panel = KuafuLiuJieShowInfoView.New(self:FindObj("ShowInfo"))

	self:ListenEvent("ClickKuafuGuildBattle", BindTool.Bind1(self.ClickKuafuGuildBattle, self), true)
	self:InitData()
	self:ListenEvent("Close",BindTool.Bind(self.CloseWindow,self))
	self:ListenEvent("OnClickQuick",BindTool.Bind(self.OnClickQuick,self))
	self:ListenEvent("OnClickTask", BindTool.Bind(self.OnClickTask,self))
	self.score = self:FindVariable("score")
	self:ListenEvent("OnClickDraw", BindTool.Bind(self.OnClickDraw, self))
	self:ListenEvent("AddGold", BindTool.Bind(self.HandleAddGold, self))

	self.tab_liujie = self:FindObj("Tabliujie")
	self.tab_bossinfo = self:FindObj("TabBoss")
	self.tab_show = self:FindObj("TabShow")
	self.tab_tj_boos = self:FindObj("TabTjBoos")
	self.tab_sw_boos = self:FindObj("TabSwBoos")
	self.map = self:FindObj("Map")

	self.tab_liujie.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.activity_kuafu_liujie))
	self.tab_bossinfo.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.activity_kuafu_boss))
	self.tab_show.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.activity_kuafu_show))
	self.tab_tj_boos.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.activity_tj_boss))
	self.tab_sw_boos.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.activity_sw_boss))

	self.tj_boss_panel = self:FindObj("BossTjPanel")
	self.sw_boss_panel = self:FindObj("BossSwPanel")
	--监听系统事件
	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)

	RemindManager.Instance:Bind(self.remind_change, RemindName.ShowKfBattleRemind)
	RemindManager.Instance:Bind(self.remind_change, RemindName.TianjiangRemind)
		self.red_point_list = {
		[RemindName.ShowKfBattleRemind] = self:FindVariable("show_task_remind"),
		[RemindName.TianjiangRemind] = self:FindVariable("tianjiang_red"),
		[RemindName.ShenwuRemind] = self:FindVariable("shenwu_red"),
	}

	for k, v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
		v:SetValue(RemindManager.Instance:GetRemind(k) > 0)
	end

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
end

function KuafuGuildBattleView:InitTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	self.tab_tj_boos:SetActive(open_fun_data:CheckIsHide("activity_tj_boss"))
	self.tab_sw_boos:SetActive(open_fun_data:CheckIsHide("activity_sw_boss"))
end

function KuafuGuildBattleView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.rewards_list) do
		v:DeleteMe()
	end
	if self.tj_boss_view then
		self.tj_boss_view:DeleteMe()
		self.tj_boss_view = nil
	end
	if self.sw_boss_view then
		self.sw_boss_view:DeleteMe()
		self.sw_boss_view = nil
	end
	self.rewards_list = {}
	self.item_list = nil
	self.tips_text = nil
	-- self.img_box = nil
	self.ShowBox = nil
	self.rewards = nil
	self.is_show = nil
	self.score = nil
	self.red_point_list = {}
	self.boss_info_panel = nil
	self.gold = nil
	self.bind_gold = nil
	self.tab_champion = nil

	self.tab_liujie = nil
	self.tab_bossinfo = nil
	self.tab_show = nil
	self.show_info_panel = nil
	self.in_liu_jie = nil
	self.tj_boss_panel = nil
	self.sw_boss_panel = nil
	self.tab_tj_boos = nil
	self.tab_sw_boos = nil
	self.map = nil

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
	if self.money_change_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
		self.money_change_callback = nil
	end

	if nil ~= self.open_trigger_handle then
		GlobalEventSystem:UnBind(self.open_trigger_handle)
		self.open_trigger_handle = nil
	end
end

function KuafuGuildBattleView:InitData()
	self.tips_text:SetValue(Language.KuafuGuildBattle.KfBattleTip)
	self.rewards_list = {}

	local cfg = KuafuGuildBattleData.Instance:GetReward()
	local list = ItemData.Instance:GetGiftItemList(cfg.item_id)
	local length = #list
	for i=1,length do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.rewards)
		item_cell:SetData(list[i])
		table.insert(self.rewards_list,item_cell)
	end
end

function KuafuGuildBattleView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		if self.gold then
			self.gold:SetValue(CommonDataManager.ConverMoney(value))
		end
	end
	if attr_name == "bind_gold" then
		if self.bind_gold then
			self.bind_gold:SetValue(CommonDataManager.ConverMoney(value))
		end
	end
end

function KuafuGuildBattleView:FlushBossInfoView()
	self.boss_info_panel:Flush()
end

function KuafuGuildBattleView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function KuafuGuildBattleView:ToggleChange(index,isOn)
	if not isOn then
		return
	end
	self.in_liu_jie:SetValue(false)
	if index == TabIndex.activity_kuafu_boss then
		self:SetShowGold(false)
		if self.boss_info_panel then
			KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_BOSS_INFO, 1450)
		end
	elseif index == TabIndex.activity_kuafu_show then
		self:SetShowGold(true)
		if self.show_info_panel and not self.show_info_panel.root_node.gameObject.activeSelf then
			self.show_info_panel:Flush()
		end
	elseif index == TabIndex.activity_kuafu_liujie then
		self:SetShowGold(false)
		self.in_liu_jie:SetValue(true)
	elseif index == TabIndex.activity_tj_boss then
		self:SetShowGold(false)
	elseif index == TabIndex.activity_sw_boss then
		self:SetShowGold(false)
	end
	self:ShowIndex(index)
end

function KuafuGuildBattleView:CloseWindow()
	self:Close()
end

function KuafuGuildBattleView:SetShowGold(active)
	self.tab_champion:SetValue(active)
end

function KuafuGuildBattleView:ClickKfBattleDesc()
	local tips_id = 224
    TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function KuafuGuildBattleView:OnClickQuick()
	local skip_task_consume = KuafuGuildBattleData.Instance:GetotherCfg().skip_task_consume
	local num = KuafuGuildBattleData.Instance:GetTaskNum()
	local gold = num * skip_task_consume
	local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_QYSD], gold, num)
	local ok_callback = function ()
		MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_CROSS_GUIDE, -1)
	end
	TipsCtrl.Instance:ShowCommonAutoView("", str, ok_callback, nil, true, nil, nil)
end

function KuafuGuildBattleView:ClickKuafuGuildBattle()
	KuafuGuildBattleCtrl.Instance:OpenRecordPanle()
end

function KuafuGuildBattleView:OpenCallBack()
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_INFO)
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO)

	KuafuGuildBattleCtrl.Instance:SendCrossTianjiangOperatorReq(CROSS_TIANJIANG_BOSS_OPER_TYPE.CROSS_TIANJIANG_BOSS_OPER_TYPE_BOSS_INFO)
	KuafuGuildBattleCtrl.Instance:SendCrossShenWuOperatorReq(CROSS_SHENWU_BOSS_OPER_TYPE.CROSS_SHENWU_BOSS_OPER_TYPE_BOSS_INFO)
	self:Flush()
	self.boss_info_panel:OpenCallBack()
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:InitTab()
end

function KuafuGuildBattleView:OnClickDraw()
	ViewManager.Instance:Open(ViewName.ShenShou, TabIndex.shenshou_huanling)
end

function KuafuGuildBattleView:CloseCallBack()
	if self.tj_boss_view then
		self.tj_boss_view:CloseBossView()
	end

	if self.sw_boss_view then
		self.sw_boss_view:CloseBossView()
	end
end

function KuafuGuildBattleView:OnFlush(param_t)
	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()
	if self.item_list and info and info.kf_battle_list then
		local data_list = TableCopy(info.kf_battle_list)
		for i,v in ipairs(self.item_list) do
			v:SetData(data_list[i])
		end
	end
	self.is_show:SetValue(false)
	local score = ShenShouData.Instance:GetHuanLingScore()
	self.score:SetValue(score)
	for k,v in pairs(param_t) do
		if k == "tj_boss" and self.show_index == TabIndex.activity_tj_boss then
			if self.tj_boss_view then
				self.tj_boss_view:FlushBossView()
			end
		elseif k == "sw_boss" and self.show_index == TabIndex.activity_sw_boss then
			if self.sw_boss_view then
				self.sw_boss_view:FlushBossView()
			end
		end
	end
end

-- 进入跨服帮派战
function KuafuGuildBattleView:OnEnterCross()
	-- 背包满了不让进
	local empty_num = ItemData.Instance:GetEmptyNum()
	if empty_num == 0 then
		TipsCtrl.Instance:ShowSystemMsg(Language.GuildBattle.BagRemind)
		return
	end
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_GUILDBATTLE, KuafuGuildBattleData.Instance:GetSceneIdByIndex())
end

function KuafuGuildBattleView:SetRewardRemindNum(num)
	if nil ~= self.redward_remind_sprite then
		self.redward_remind_sprite:SetValue(num > 0)
	end
end

function KuafuGuildBattleView:OnClickTask()
	ViewManager.Instance:Open(ViewName.KuafuTaskRecordView)
end

function KuafuGuildBattleView:ShowIndexCallBack(index)
	self.show_index = index
	if index == TabIndex.activity_kuafu_liujie then
		self.tab_liujie.toggle.isOn = true
		self.map:SetActive(true)
	elseif index == TabIndex.activity_kuafu_boss then
		self.tab_bossinfo.toggle.isOn = true
		self.map:SetActive(true)
	elseif index == TabIndex.activity_kuafu_show then
		self.tab_show.toggle.isOn = true
	elseif index == TabIndex.activity_tj_boss then
		self.tab_tj_boos.toggle.isOn = true
		self.map:SetActive(false)
		if RemindManager.Instance:GetRemind(RemindName.TianjiangRemind) > 0 then
			RemindManager.Instance:SetTodayDoFlag(RemindName.TianjiangRemind)
		end
		ClickOnceRemindList[RemindName.TianjiangRemind] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.TianjiangRemind)
		if self.tj_boss_view then
			self.tj_boss_view:FlushBoss()
		end
	elseif index == TabIndex.activity_sw_boss then
		self.tab_sw_boos.toggle.isOn = true
		self.map:SetActive(false)
		ClickOnceRemindList[RemindName.ShenwuRemind] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.ShenwuRemind)
	end
	self:AsyncLoadView(index)
end

function KuafuGuildBattleView:AsyncLoadView(index)
	if index == TabIndex.activity_tj_boss and not self.tj_boss_view then
		UtilU3d.PrefabLoad("uis/views/kuafuliujie_prefab", "TjBossPanel",
			function(obj)
				obj.transform:SetParent(self.tj_boss_panel.transform, false)
				obj = U3DObject(obj)
				self.tj_boss_view = KuafuTjBossView.New(obj)
				self:Flush("tj_boss")
			end)
	elseif index == TabIndex.activity_sw_boss and not self.sw_boss_view then
		UtilU3d.PrefabLoad("uis/views/kuafuliujie_prefab", "SwBossPanel",
			function(obj)
				obj.transform:SetParent(self.sw_boss_panel.transform, false)
				obj = U3DObject(obj)
				self.sw_boss_view = KuafuSwBossView.New(obj)
				self:Flush("sw_boss")
			end)
	end

end

function KuafuGuildBattleView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end


-------------------------------------------------------------------------------------------
KuafuGuildItemRender = KuafuGuildItemRender or BaseClass(BaseRender)
function KuafuGuildItemRender:__init()
	self.lbl_role_name = self:FindVariable("Name")			-- 帮主名字
	self.lbl_family_name = self:FindVariable("GuildName") 	-- 帮派名字
	self.img_box = self:FindVariable("BoxImage")   			--宝箱图片
	self.task_rate = self:FindVariable("task_rate")
	self.img_kf_occupy = self:FindVariable("Occupy")  		--是否显示已占领
	self.remind = self:FindVariable("RedPoint")
	self.show_double = self:FindVariable("show_double")
	-- self.show_ibl_role_name = self:FindVariable("ShowName")
	-- self.gray = self:FindVariable("Gray")
	self:ListenEvent("OnImgBoxHandler",BindTool.Bind1(self.OnImgBoxHandler, self), true)
end

function KuafuGuildItemRender:__delete()
end

function KuafuGuildItemRender:OnImgBoxHandler()
	local flag_bool = KuafuGuildBattleData.Instance:GetGuildRewardFlag(self.data.index)

	local data = KuafuGuildBattleData.Instance:GetOwnReward(self.data.index - 1)

	local reward_list = ItemData.Instance:GetGiftItemList(data.guild_reward_item.item_id)
	for i=1,3 do
		reward_list[i - 1] = reward_list[i]
	end
	KuafuGuildBattleCtrl.Instance:OpenRewardTip(reward_list, false, nil, false, data.title_name,self.data.index)
	-- end
end

function KuafuGuildItemRender:OnFlush()
	if nil == self.data and self.data.guild_id then return end

	local guild_id = 0
	local role = GameVoManager.Instance:GetMainRoleVo()

	if role then
		guild_id = role.guild_id or 0
	end

	self.show_double:SetValue((self.data.guild_id > 0) and (self.data.guild_id == guild_id))

	if self.data.guild_id > 0 then
		self.lbl_role_name:SetValue(string.format(Language.KuafuGuildBattle.KfGuildMengzhu, self.data.guild_tuanzhang_name))
		self.lbl_family_name:SetValue(string.format(Language.KuafuGuildBattle.KfGuildServe, self.data.guild_name, self.data.server_id))
	else
		self.lbl_role_name:SetValue(Language.KuafuGuildBattle.KfNoOccupy)
		self.lbl_family_name:SetValue(Language.KuafuGuildBattle.KfNoOccupy)
	end
	local this_bool = KuafuGuildBattleData.Instance:GetCurItemIsthisServer(self.data.index)
	local str = this_bool and "kf_this_occupy" or "kf_he_occupy"
	self.img_kf_occupy:SetValue(self.data.guild_id > 0)

	local flag_bool = KuafuGuildBattleData.Instance:GetGuildRewardFlag(self.data.index)
	local str = 1
	if self:GetIndex() == 2 then
		self.img_box:SetAsset(ResPath.GetKuafuGuildBattle("husong_box5" .. str))
	else
		self.img_box:SetAsset(ResPath.GetKuafuGuildBattle("husong_box4".. str))
	end

	local is_guild_bool = KuafuGuildBattleData.Instance:GetIsGuildOwn(self.data.index)

	self:SetRewardRemindNum(flag_bool and is_guild_bool)

end

function KuafuGuildItemRender:SetRewardRemindNum(bool)
	if nil ~= self.remind_sprite then
		self.remind:SetValue(bool)
	end
end

function KuafuGuildItemRender:SetData(data)
	self.data = data
	self:Flush()
end

function KuafuGuildItemRender:GetIndex()
	return self.index
end

function KuafuGuildItemRender:SetIndex(index)
	self.index = index
end