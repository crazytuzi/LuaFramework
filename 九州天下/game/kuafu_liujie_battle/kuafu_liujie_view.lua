require("game/kuafu_liujie_battle/kuafu_liujie_bossinfo_view")
require("game/kuafu_liujie_battle/kuafu_liujie_showinfo_view")

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
	self:SetMaskBg()
	self.ui_config = {"uis/views/kuafuliujie","KuaFULiuJieView"}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function KuafuGuildBattleView:LoadCallBack()

	self.item_list ={}
	for i=1,6 do
		self.item_list[i] = KuafuGuildItemRender.New(self:FindObj("Item" .. i))
		self.item_list[i]:SetIndex(i)
	end

	self.tips_text = self:FindVariable("tips")
	self.is_show = self:FindVariable("is_show")
	self.in_liu_jie = self:FindVariable("InLiuJie")
	self.score = self:FindVariable("score")
	self.task_pro = self:FindVariable("TaskPro")

	self:ListenEvent("OnEnterCross", BindTool.Bind1(self.OnEnterCross, self), true)

	self:ListenEvent("ClickKfBattleDesc", BindTool.Bind(self.ClickKfBattleDesc, self))

	self.ShowBox = self:FindVariable("ShowBox")
	self.rewards = self:FindObj("Rewards")

	self.boss_info_panel = KuafuLiuJieBossInfoView.New(self:FindObj("BossInfo"))
	self.show_info_panel = KuafuLiuJieShowInfoView.New(self:FindObj("ShowInfo"))
	
	self:ListenEvent("ClickKuafuGuildBattle", BindTool.Bind1(self.ClickKuafuGuildBattle, self), true)
	self:InitData()
	self:ListenEvent("Close",BindTool.Bind(self.CloseWindow,self))
	-- self:ListenEvent("OnClickQuick",BindTool.Bind(self.OnClickQuick,self))
	self:ListenEvent("OnClickTask", BindTool.Bind(self.OnClickTask,self))
	self:ListenEvent("OnClickOpenExchange", BindTool.Bind(self.OnClickOpenExchange, self))

	self.tab_liujie = self:FindObj("Tabliujie")
	self.tab_bossinfo = self:FindObj("TabBoss")
	self.tab_show = self:FindObj("TabShow")
	self.tab_liujie.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, KuafuGuildBattleView.TabIndex.liujie))
	self.tab_bossinfo.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, KuafuGuildBattleView.TabIndex.bossinfo))
	self.tab_show.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, KuafuGuildBattleView.TabIndex.show))

	self.red_point_list = {
		[RemindName.ShowKfBattleRemind] = self:FindVariable("show_task_remind"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function KuafuGuildBattleView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	for k,v in pairs(self.rewards_list) do
		v:DeleteMe()
	end
	self.rewards_list = {}
	self.tips_text = nil
	-- self.img_box = nil
	self.ShowBox = nil
	self.rewards = nil
	self.is_show = nil
	self.score = nil
	self.task_pro = nil
	if self.boss_info_panel then
		self.boss_info_panel:DeleteMe()
		self.boss_info_panel = nil
	end
	if self.show_info_panel then
		self.show_info_panel:DeleteMe()
		self.show_info_panel = nil
	end
	self.tab_liujie = nil
	self.tab_bossinfo = nil
	self.tab_show = nil
	self.in_liu_jie = nil
	self.cur_index = nil
	self.red_point_list = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
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

function KuafuGuildBattleView:ToggleChange(index,isOn)
	if not isOn then
		return
	end
	self:ChangeToIndex(index)
	self.cur_index = index
	self.in_liu_jie:SetValue(false)
	local is_select_boss_enter = false
	if index == KuafuGuildBattleView.TabIndex.bossinfo then
		if self.boss_info_panel then
			is_select_boss_enter = true
			local role_vo = PlayerData.Instance:GetRoleVo()
			local uuid = role_vo.uuid or 0
			CrossServerCtrl.Instance:SendCSCrossCommonOperaReq(CROSS_COMMON_OPERA_REQ.CROSS_COMMON_OPERA_REQ_CROSS_GUILDBATTLE_BOSS_INFO, KuafuGuildBattleData.Instance:GetSceneIdByIndex(), uuid)
		end
	elseif index == KuafuGuildBattleView.TabIndex.show then
		if self.show_info_panel and not self.show_info_panel.root_node.gameObject.activeSelf then
			self.show_info_panel:Flush()
		end
	elseif index == KuafuGuildBattleView.TabIndex.liujie then
		self.in_liu_jie:SetValue(true)
	end
	KuafuGuildBattleData.Instance:SetSelectBoss(is_select_boss_enter)
end

function KuafuGuildBattleView:CloseWindow()
	self:Close()
end

function KuafuGuildBattleView:ClickKfBattleDesc()
	local tips_id = 211
    TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

-- function KuafuGuildBattleView:OnClickQuick()
-- 	local skip_task_consume = KuafuGuildBattleData.Instance:GetotherCfg().skip_task_consume
-- 	local num = KuafuGuildBattleData.Instance:GetTaskNum()
-- 	local gold = num * skip_task_consume
-- 	local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_QYSD], gold, num)
-- 	local ok_callback = function ()
-- 		-- MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_CROSS_GUIDE, -1)
-- 	end
-- 	TipsCtrl.Instance:ShowCommonAutoView("", str, ok_callback, nil, true, nil, nil)
-- end

function KuafuGuildBattleView:ClickKuafuGuildBattle()
	KuafuGuildBattleCtrl.Instance:OpenRecordPanle()
end

function KuafuGuildBattleView:OpenCallBack()
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_INFO)
	KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO)
	self.boss_info_panel:OpenCallBack()
	self:Flush()
end

function KuafuGuildBattleView:OnClickOpenExchange()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_rongyao)
end

function KuafuGuildBattleView:OnFlush()
	local info = KuafuGuildBattleData.Instance:GetGuildBattleInfo()
	if self.item_list and info and info.kf_battle_list then
		local data_list = TableCopy(info.kf_battle_list)
		for i,v in ipairs(self.item_list) do
			v:SetData(data_list[i])
		end
	end
	self.is_show:SetValue(false)
	local score = ExchangeData.Instance:GetScoreByScoreType(EXCHANGE_PRICE_TYPE.LIUJIESCORE)
	self.score:SetValue("<color=#00ff00>" .. score .. "</color>")

	local task_num, task_total_num = KuafuGuildBattleData.Instance:GetFinishTaskNum()
	self.task_pro:SetValue("<color=#00ff00>" .. task_num .. "/" .. task_total_num .. "</color>")
end

-- 进入跨服帮派战
function KuafuGuildBattleView:OnEnterCross()
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_XYJD)
end

function KuafuGuildBattleView:SetRewardRemindNum(num)
	if nil ~= self.redward_remind_sprite then
		self.redward_remind_sprite:SetValue(num > 0)
	end
end

function KuafuGuildBattleView:OnClickTask()
	ClickOnceRemindList[RemindName.ShowKfBattleRemind] = 0
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.ShowKfBattleRemind)
	ViewManager.Instance:Open(ViewName.KuafuTaskRecordView)
end

function KuafuGuildBattleView:ShowIndexCallBack(index)
	if index == TabIndex.kuafu_liujie then
		self.tab_liujie.toggle.isOn = true
	elseif index == TabIndex.liujie_bossinfo then
		self.tab_bossinfo.toggle.isOn = true
	elseif index == TabIndex.liujie_show then
		self.tab_show.toggle.isOn = true
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
	self.img_box = self:FindVariable("BoxImage")   			--宝箱图片
	self.task_rate = self:FindVariable("task_rate")
	self.img_kf_occupy = self:FindVariable("Occupy")  		--是否显示已占领
	self.remind = self:FindVariable("RedPoint")
	-- self.show_ibl_role_name = self:FindVariable("ShowName")
	-- self.gray = self:FindVariable("Gray")
	self:ListenEvent("OnImgBoxHandler",BindTool.Bind1(self.OnImgBoxHandler, self), true)
end

function KuafuGuildItemRender:__delete()
end	

function KuafuGuildItemRender:OnImgBoxHandler()
	if nil == self.data or nil == next(self.data) then return end

	if self.data.index == 1 then
		ViewManager.Instance:Open(ViewName.LianFuServerGroupView)
	else
		local flag_bool = KuafuGuildBattleData.Instance:GetGuildRewardFlag(self.data.index)

		local data = KuafuGuildBattleData.Instance:GetOwnReward(self.data.index - 1)

		local reward_list = ItemData.Instance:GetGiftItemList(data.guild_reward_item.item_id)
		for i=1,3 do
			reward_list[i - 1] = reward_list[i]
		end
		table.insert(reward_list, {item_id = data.title_id})
		KuafuGuildBattleCtrl.Instance:OpenRewardTip(reward_list, false, nil, false, data.title_name)
	end
end

function KuafuGuildItemRender:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	if self.data.guild_id > 0 then 
		self.lbl_role_name:SetValue(string.format(Language.KuafuGuildBattle.KfGuildServe, COLOR[CAMP_BY_STR[self.data.guild_id]], self.data.guild_name, self.data.server_id, self.data.guild_tuanzhang_name))
	else
		self.lbl_role_name:SetValue(Language.KuafuGuildBattle.KfNoOccupy)
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