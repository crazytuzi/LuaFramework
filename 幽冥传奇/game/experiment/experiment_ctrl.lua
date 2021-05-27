require("scripts/game/experiment/experiment_data")
require("scripts/game/experiment/experiment_view")
require("scripts/game/experiment/scene_model")
require("scripts/game/experiment/trial_info_view")
require("scripts/game/experiment/trial_win_view")
require("scripts/game/experiment/trial_lose_view")
require("scripts/game/experiment/trial_add_awards_view")
require("scripts/game/experiment/trial_tip_view")

ExperimentCtrl = ExperimentCtrl or BaseClass(BaseController)

function ExperimentCtrl:__init()
    if ExperimentCtrl.Instance then
        ErrorLog("[ExperimentCtrl]:Attempt to create singleton twice!")
    end
    ExperimentCtrl.Instance = self
    
    self.data = ExperimentData.New()
    self.view = ExperimentView.New(ViewDef.Experiment)

    self.curr_dig_info = nil --当前主角所在的矿位信息

	self.trial_info_view = TrialInfoView.New(ViewDef.TrialInfo)
	self.trial_add_awards_view = TrialAddAwardsView.New(ViewDef.TrialAddAwards)
	self.trial_win_view = TrialWinView.New(ViewDef.TrialWin)
	self.trial_lose_view = TrialLoseView.New(ViewDef.TrialLose)
	self.trial_tip_view = TrialTipView.New(ViewDef.TrialTip)

	self:RegisterAllProtocols()


	self.can_open_trial_tip = true
	self.game_cond_change = GlobalEventSystem:Bind(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
end

function ExperimentCtrl:__delete()
    self.view:DeleteMe()
    self.view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
	self.curr_dig_info = nil

    if self.trial_win_view then
		self.trial_win_view:DeleteMe()
		self.trial_win_view = nil
	end
	
	if self.trial_lose_view then
		self.trial_lose_view:DeleteMe()
		self.trial_lose_view = nil
	end

	if self.trial_info_view then
		self.trial_info_view:DeleteMe()
		self.trial_info_view = nil
	end

	if self.trial_tip_view then
		self.trial_tip_view:DeleteMe()
		self.trial_tip_view = nil
	end

	self:CancelTimer()
	self:DeleteDigAwardTimer()
	ExperimentCtrl.Instance = nil
end

function ExperimentCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCDigOreBaseInfo, "OnDigOreBaseInfo")
    self:RegisterProtocol(SCDigOreSlotInfo, "OnDigOreSlotInfo")
    self:RegisterProtocol(SCDigOreAddSlotInfo, "OnDigOreAddSlotInfo")
    self:RegisterProtocol(SCDigOreDelSlotInfo, "OnDigOreDelSlotInfo")
    self:RegisterProtocol(SCDigOreFireInfo, "OnDigOreFireInfo")
    self:RegisterProtocol(SCDigOreFireSuccesInfo, "OnDigOreFireSuccesInfo")
	self:RegisterProtocol(SCTrialData, "OnTrialData") -- 接收试炼关卡信息(139, 164)

	RemindManager.Instance:RegisterCheckRemind(function ()
	   return self.data:GetRewardRemind()
	end, RemindName.Experiment)
end

function ExperimentCtrl:SetCurrDigInfo(data)
	self.curr_dig_info = data
end

function ExperimentCtrl:CheckCanLingquDigAward()
	return self.data:CheckCanLingquDigAward()
end

function ExperimentCtrl:CheckNeedOpenDigAcountView()
	if self.curr_dig_info then
		ViewManager.Instance:GetView(ViewDef.DigOreAccount):SetData(self.curr_dig_info)
		ViewManager.Instance:OpenViewByDef(ViewDef.DigOreAccount)
		self.curr_dig_info = nil
	end
end

function ExperimentCtrl:IsNeedOpenAwardView()
	if self.data:CheckCanLingquDigAward() then
		ViewManager.Instance:GetView(ViewDef.DigOreAward):SetData({idx = self.data:GetBaseInfo().quality}) 
	    ViewManager.Instance:OpenViewByDef(ViewDef.DigOreAward)
		return true
	end
end

function ExperimentCtrl:FlushDigAwardTimer()
	local update_time_func = function ()
		local time2 = ExperimentData.Instance:GetBaseInfo().start_dig_time + MiningActConfig.finTimes - TimeCtrl.Instance:GetServerTime()
		if time2 <= 0 then
			self:DeleteDigAwardTimer()
			self.data:DispatchEvent(ExperimentData.INFO_CHANGE)
			if self.data:CheckCanLingquDigAward() then
			    ViewManager.Instance:GetView(ViewDef.DigOreAward):SetData({idx = ExperimentData.Instance:GetBaseInfo().quality}) 
			    ViewManager.Instance:OpenViewByDef(ViewDef.DigOreAward)
		    end
		end
	end

	if nil == self.dig_timer and ExperimentData.Instance:IsDiging() then
		self.dig_timer = GlobalTimerQuest:AddRunQuest(function ()
			update_time_func()
		end, 1)
		update_time_func()
	end
end

function ExperimentCtrl:DeleteDigAwardTimer()
	if self.dig_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.dig_timer)
		self.dig_timer = nil
	end
end

function ExperimentCtrl:OnDigOreBaseInfo(protocol)
    self.data:SetViewData(protocol)
    RemindManager.Instance:DoRemindDelayTime(RemindName.Experiment)
    self.data:DispatchEvent(ExperimentData.INFO_CHANGE)

    if self.data:CheckCanLingquDigAward() then
	    ViewManager.Instance:GetView(ViewDef.DigOreAward):SetData({idx = protocol.quality}) 
	    ViewManager.Instance:OpenViewByDef(ViewDef.DigOreAward)
    end

    --本地计时 刷新挖矿奖励
    self:FlushDigAwardTimer()
end

function ExperimentCtrl:OnDigOreSlotInfo(protocol)
    self.data:SetDigSlotData(protocol.digslot_list)
end

function ExperimentCtrl:OnDigOreAddSlotInfo(protocol)
    self.data:AddDigSlotData(protocol.slot_info)
end

function ExperimentCtrl:OnDigOreDelSlotInfo(protocol)
    self.data:DelDigSlotData(protocol.slot)
end

function ExperimentCtrl:OnDigOreFireInfo(protocol)
    self.data:DispatchEvent(ExperimentData.INTO_PK, {
        info = {
            power = protocol.power,
            cloth = protocol.cloth,
            weapon = protocol.weapon,
            sex = protocol.sex,
            HP = protocol.HP,
        }
    })
end

function ExperimentCtrl:OnDigOreFireSuccesInfo(protocol)
    -- self.data:SetFireSuccesData(protocol)
    ViewManager.Instance:GetView(ViewDef.DigOreRobAward):SetData({idx = protocol.quality_idx, rate = protocol.rate}) 
    ViewManager.Instance:OpenViewByDef(ViewDef.DigOreRobAward)
end

function ExperimentCtrl:OnTrialData(protocol)
	self.data:SetTrialData(protocol)

	if self.can_open_trial_tip and protocol.guan_num > 0 then
		ViewManager.Instance:OpenViewByDef(ViewDef.TrialTip)
	end
	self.can_open_trial_tip = false
end

-- 操作请求
function ExperimentCtrl.SendExperimentOptReq(opt_type, idx)
    local protocol = ProtocolPool.Instance:GetProtocol(CSDigOreReq)
    protocol.opt_type = opt_type
    protocol.opt_idx = idx or 0
    protocol:EncodeAndSend()
end

-- 挑战试炼关卡(139, 164)
function ExperimentCtrl.SendChallengeTrialReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSChallengeTrialReq)
	protocol:EncodeAndSend()
end

-- 领取试炼关卡额外奖励(139, 165)
function ExperimentCtrl.SendReceiveTrialAddAwardsReq(guan_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReceiveTrialAddAwardsReq)
	protocol.guan_num = guan_num
	protocol:EncodeAndSend()
end

-- 请求试炼信息(139, 166)
function ExperimentCtrl.SendTrialDataReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTrialDataReq)
	protocol:EncodeAndSend()
end

-- 领取试炼挂机奖励(139, 167)
function ExperimentCtrl.SendReceiveTrialAwardsReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReceiveTrialAwardsReq)
	protocol:EncodeAndSend()
end

-- 打开试炼关卡信息
function ExperimentCtrl:OpenTrialInfoView(data)
	self.trial_info_view:SetData(data)
	ViewManager.Instance:OpenViewByDef(ViewDef.TrialInfo)
end

-- 打开试炼关卡额外奖励
function ExperimentCtrl:OpenTrialAddAwardsView(data)
	self.trial_add_awards_view:SetData(data)
	ViewManager.Instance:OpenViewByDef(ViewDef.TrialAddAwards)
end

function ExperimentCtrl:OnGameCondChange(id, is_all_ok)
	if id == ViewDef.Experiment.Trial.v_open_cond and is_all_ok then
		-- 挑战试炼关卡已开放
		EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_SOUL2, BindTool.Bind(self.OnRoleAttrChange, self))
		GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnSceneLoadingStateEnter, self))
		GlobalEventSystem:UnBind(self.game_cond_change)
		ExperimentCtrl.SendTrialDataReq()
	end
end

function ExperimentCtrl:OnRoleAttrChange(param)
	if param.value > param.old_value then
		-- 挑战试炼关卡-成功
		self:CancelTimer()
		ViewManager.Instance:OpenViewByDef(ViewDef.TrialWin)
	end
end

function ExperimentCtrl:OnSceneLoadingStateEnter(scene_id, scene_type, fuben_id)
	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local cfg = TrialConfig and TrialConfig.chapters or {}
	local cur_cfg = cfg[cur_trial_floor + 1] or {}

	if scene_id == cur_cfg.sceneid and fuben_id == cur_cfg.fbId then
		local callback = function()
			--挑战试炼关卡-失败
			local fuben_id = FubenData.Instance:GetFubenId()
			FubenCtrl.OutFubenReq(fuben_id)
			ViewManager.Instance:OpenViewByDef(ViewDef.TrialLose)
			self:CancelTimer()
		end

		-- 进入试炼地图
		self:CancelTimer()
		self.trial_start_time = Status.NowTime
		self:InitTrialFuBenInfo()

		local delay_time = cur_cfg.boss and cur_cfg.boss.liveTime or 0
		self.timer = GlobalTimerQuest:AddDelayTimer(callback, delay_time)
		self:OnTrialDie(delay_time)

		GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true, true)
	else
		-- 退出试炼地图 或 并非进入试炼地图
		self:CancelTimer()

		if self.trial_fuben_info then
			self.trial_fuben_info:Release()
			self.trial_fuben_info = nil
		end
	end
end

-- 取消计时器和倒计时
function ExperimentCtrl:CancelTimer()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.trial_die then
		self.trial_die:StopTimeDowner()
		self.trial_die = nil
	end

	self.total_hurt = 0
	self.trial_start_time = 0
end

-- 试练倒计时显示
function ExperimentCtrl:OnTrialDie(time)
	local count_down_callback =  function (elapse_time, total_time, view) 
			local num = total_time - math.floor(elapse_time)

			if self.trial_fuben_info then
				self.trial_fuben_info:FlushDps(self:GetTrialDps())
			end
		end

	self.trial_die = UiInstanceMgr.Instance:AddTimeLeaveView(time, count_down_callback, "vip_boss_tip")
end

function ExperimentCtrl:OnHurtChange(hurt_value)
	if self.timer then
		self.total_hurt = self.total_hurt + hurt_value
	end
end

function ExperimentCtrl:GetTrialDps()
	local now_time = Status.NowTime
	local start_time = self.trial_start_time or 0
	local total_hurt = self.total_hurt or 0

	return math.floor(total_hurt / (now_time - start_time))
end

---------------------------------------------------
-- 主界面小部件-试炼副本信息
---------------------------------------------------

function ExperimentCtrl:InitTrialFuBenInfo()
	-- 设置面板数据
	if nil == self.trial_fuben_info then
		local center_left = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.CENTER_LEFT)
		local size = center_left:getContentSize()
		-- 创建布局
		local layout = XUI.CreateLayout(0, size.height / 2 - 185, 0, 0)
		center_left:TextureLayout():addChild(layout, 20)

		self.trial_fuben_info = self.CreateTrialFuBenInfo(layout)
	else
		self.trial_fuben_info:SetVisible(true)
	end
	self.trial_fuben_info:Flush()
end

-- 创建视图
function ExperimentCtrl.CreateTrialFuBenInfo(parent)
	local ph_item = ConfigManager.Instance:GetUiConfig("trial_ui_cfg")[7]
	local node_tree = {}
	local ph_list = {}
	XUI.Parse(ph_item, parent, nil, node_tree, ph_list)

	-----面板刷新-----	

	local view = {}
	function view:Init(node_tree, parent, ph_list)
		self.node_tree = node_tree
		self.parent = parent
		self.ph_list = ph_list
	end

	function view:Flush()
		local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
		local cfg = TrialConfig and TrialConfig.chapters or {}
		local next_cfg = cfg[cur_trial_floor + 1] or {}
		local awards = next_cfg.awards or {}

		----------------------------
		-- 关卡掉落
		----------------------------
		if nil == self.cell_list then
			local ph = self.ph_list["ph_award_list"]
			local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
			local parent = self.parent
			local grid_scroll = GridScroll.New()
			grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, ActBaseCell, ScrollDir.Horizontal, false, ph_item)
			parent:addChild(grid_scroll:GetView(), 99)
			self.cell_list = grid_scroll
		end
		local show_list = {}
		for i,v in ipairs(awards) do
			show_list[#show_list + 1] = ItemData.InitItemDataByCfg(v)
		end
		self.cell_list:SetDataList(show_list)

		-- 居中处理
		local view = self.cell_list:GetView()
		local inner = view:getInnerContainer()
		local size = view:getContentSize()
		local inner_width =(BaseCell.SIZE + 10) * (#show_list) - 10
		local view_width = math.min(self.ph_list["ph_award_list"].w, inner_width + 10)
		view:setContentSize(cc.size(view_width, size.height))
		view:setInnerContainerSize(cc.size(inner_width, size.height))
		view:jumpToTop()
		------------------------------
		-- 关卡掉落end
		------------------------------

		local section_count, floor = ExperimentData.GetSectionAndFloor(cur_trial_floor + 1)
		local section, difficult = ExperimentData.GetSectionAndDifficult(section_count)

		self.node_tree["trial_section_lv"].node:loadTexture(ResPath.GetCommon("trial_section_lv_" .. section))
		self.node_tree["trial_difficult"].node:loadTexture(ResPath.GetCommon("trial_difficult_" .. difficult))
		self.node_tree["lbl_section"].node:setString(section .. "-" .. floor)

		self.recommend_dps = next_cfg.recommend_dps or 0
		local boss_id = next_cfg.boss and next_cfg.boss.monId or 0
		local boss_cfg = BossData.GetMosterCfg(boss_id)
		local boss_name = boss_cfg.name or ""
		self.node_tree["lbl_boss_name"].node:setString(boss_name  .. "×1")
		self.node_tree["lbl_boss_name"].node:setColor(COLOR3B.RED)
		self.node_tree["lbl_dps_1"].node:setString(self.recommend_dps)
		self.node_tree["lbl_dps_2"].node:setString(0)
		self.node_tree["lbl_dps_2"].node:setColor(COLOR3B.RED)
	end

	function view:FlushDps(dps)
		local color = dps >= self.recommend_dps and COLOR3B.GREEN or COLOR3B.RED
		self.node_tree["lbl_dps_2"].node:setString(dps)
		self.node_tree["lbl_dps_2"].node:setColor(color)
	end

	function view:SetVisible(vis) -- 设置面板显示状态
		if nil ~= self.parent then
			self.parent:setVisible(vis)
		end
	end

	function view:Release()
		if self.cell_list then
			self.cell_list:DeleteMe()
			self.cell_list = nil
		end

		if self.parent then
			self.parent:removeFromParent()
			self.parent = nil
		end
	end

	view:Init(node_tree, parent, ph_list)
	return view
end

---------------------------------------------------
-- 试炼副本信息 end
---------------------------------------------------