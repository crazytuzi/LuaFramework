require("game/national_warfare/national_warfare_view")
require("game/national_warfare/national_warfare_data")
require("game/national_warfare/start_citan_view")
require("game/national_warfare/citan_color_view")
require("game/national_warfare/citan_complete_view")
require("game/national_warfare/start_banzhuan_view")
require("game/national_warfare/banzhuan_color_view")
require("game/national_warfare/banzhuan_complete_view")
require("game/national_warfare/other_camp_yunbiao_view")
require("game/national_warfare/camp_war_end_tip")
require("game/national_warfare/yingjiu_task_view")

NationalWarfareCtrl = NationalWarfareCtrl or  BaseClass(BaseController)

function NationalWarfareCtrl:__init()
	if NationalWarfareCtrl.Instance ~= nil then
		ErrorLog("[NationalWarfareCtrl] attempt to create singleton twice!")
		return
	end
	NationalWarfareCtrl.Instance = self

	self.data = NationalWarfareData.New()
	self.view = NationalWarfareView.New(ViewName.NationalWarfare, TabIndex.national_warfare_dart)
	self.start_citan_view = StartCiTanView.New(ViewName.StartCiTanView)
	self.citan_color_view = CiTanColorView.New(ViewName.CiTanColorView)
	self.citan_complete_view = CiTanCompleteView.New(ViewName.CiTanCompleteView)
	self.start_banzhuan_view = StartBanZhuanView.New(ViewName.StartBanZhuanView)
	self.banzhuan_color_view = BanZhuanColorView.New(ViewName.BanZhuanColorView)
	self.banzhuan_complete_view = BanZhuanCompleteView.New(ViewName.BanZhuanCompleteView)
	self.other_yunbiao_view = OtherCampYunBiaoView.New(ViewName.NationalWarfareYunBiao)
	self.camp_war_end_tip = CampWarEndTipView.New()
	self.yingjiu_task_view = YingJiuTaskView.New()
	self.delay_timer = nil
	self.last_task_type = 0
	self.open_citan_warfare = 99
	self.open_banzhuan_warfare = 99

	self:RegisterAllProtocols()
	self:RegisterAllEvents()

	RemindManager.Instance:Register(RemindName.CampWarYingJiu, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.CampWarYingJiu))
	RemindManager.Instance:Register(RemindName.CampWarCiTan, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.CampWarCiTan))
	RemindManager.Instance:Register(RemindName.CampWarBanzhuang, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.CampWarBanzhuang))
	RemindManager.Instance:Register(RemindName.CampWarYunBiao, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.CampWarYunBiao))
	RemindManager.Instance:Register(RemindName.CampWarQiYun, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.CampWarQiYun))
	RemindManager.Instance:Register(RemindName.CampWarDaChen, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.CampWarDaChen))
	RemindManager.Instance:Register(RemindName.CampWarGuoQi, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.CampWarGuoQi))
end

function NationalWarfareCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.start_citan_view ~= nil then
		self.start_citan_view:DeleteMe()
		self.start_citan_view = nil
	end

	if self.citan_color_view ~= nil then
		self.citan_color_view:DeleteMe()
		self.citan_color_view = nil
	end

	if self.citan_complete_view ~= nil then
		self.citan_complete_view:DeleteMe()
		self.citan_complete_view = nil
	end

	if self.start_banzhuan_view ~= nil then
		self.start_banzhuan_view:DeleteMe()
		self.start_banzhuan_view = nil
	end

	if self.banzhuan_color_view ~= nil then
		self.banzhuan_color_view:DeleteMe()
		self.banzhuan_color_view = nil
	end

	if self.banzhuan_complete_view ~= nil then
		self.banzhuan_complete_view:DeleteMe()
		self.banzhuan_complete_view = nil
	end

	if self.other_yunbiao_view ~= nil then
		self.other_yunbiao_view:DeleteMe()
		self.other_yunbiao_view = nil
	end

	if self.camp_war_end_tip ~= nil then
		self.camp_war_end_tip:DeleteMe()
		self.camp_war_end_tip = nil
	end

	GlobalTimerQuest:CancelQuest(self.delay_timer)
	self.delay_timer = nil

	NationalWarfareCtrl.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.CampWarYingJiu)
	RemindManager.Instance:UnRegister(RemindName.CampWarCiTan)
	RemindManager.Instance:UnRegister(RemindName.CampWarBanzhuang)
	RemindManager.Instance:UnRegister(RemindName.CampWarYunBiao)
	RemindManager.Instance:UnRegister(RemindName.CampWarQiYun)
	RemindManager.Instance:UnRegister(RemindName.CampWarDaChen)
	RemindManager.Instance:UnRegister(RemindName.CampWarGuoQi)
end

-- 协议注册
function NationalWarfareCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCampDachenActStatus, "OnSCCampDachenActStatus")
	self:RegisterProtocol(SCKillCampDachen, "OnSCKillCampDachen")
	self:RegisterProtocol(SCCampCitanStatus, "OnSCCampCitanStatus")
	self:RegisterProtocol(SCCampBanzhuanStatus, "OnSCCampBanzhuanStatus")
	self:RegisterProtocol(SCCampYunbiaoUsers, "OnSCCampYunbiaoUsers")
	self:RegisterProtocol(SCCampYingjiuStatus, "OnSCCampYingjiuStatus")
	self:RegisterProtocol(SCSceneRoleCountAck, "OnSCSceneRoleCountAck")
	self:RegisterProtocol(SCCampTaskReward, "OnSCCampTaskReward")
	self:RegisterProtocol(SCCampFlagActStatus, "OnSCCampFlagActStatus")
	self:RegisterProtocol(SCKillCampFlag, "OnSCKillCampFlag")
	self:RegisterProtocol(SCCampTaskBeShared, "OnSCCampTaskBeShared")
	self:RegisterProtocol(SCCampTotemPillarInfo, "OnCampTotemPillarInfo")
	self:RegisterProtocol(SCSceneCampTotemPillarInfo, "OnSceneCampTotemPillarInfo")
end

function NationalWarfareCtrl:RegisterAllEvents()
end

-- 大臣活动状态信息 
function NationalWarfareCtrl:OnSCCampDachenActStatus(protocol)
	self.data:SetCampDachenActStatus(protocol)
	GlobalEventSystem:Fire(ObjectEventType.OBJ_MONSTER_CHANGE)
	self:Flush("flush_dachen_view")
	MainUICtrl.Instance.view:Flush("dachen")

	RemindManager.Instance:Fire(RemindName.CampWarDaChen)
end

-- 击杀大臣奖励
function NationalWarfareCtrl:OnSCKillCampDachen(protocol)
	self.data:SetKillCampDachen(protocol)
	local cell_data = protocol.reward_items
	local camp_type = protocol.camp_type        						 -- 大臣所在国家
	local reward_times = protocol.reward_times
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local asset1 = ""
	local asset2 = ""
	if camp_type and camp_type ~= vo.camp then
		title_asset = "title_dachen1"								 -- 击杀成功
		asset1 = "desc_dachen_1"        		
		asset2 = "desc_reward"        		
	end
	self:ShowEndTip(title_asset, asset1, asset2, cell_data, nil, nil, reward_times)
end

-- 国旗活动状态信息 
function NationalWarfareCtrl:OnSCCampFlagActStatus(protocol)
	self.data:SetCampGuoQiActStatus(protocol)
	GlobalEventSystem:Fire(ObjectEventType.OBJ_MONSTER_CHANGE)
	self:Flush("flush_guoqi_view")
	MainUICtrl.Instance.view:Flush("guoqi")

	RemindManager.Instance:Fire(RemindName.CampWarGuoQi)
end

-- 击杀国旗奖励
function NationalWarfareCtrl:OnSCKillCampFlag(protocol)
	local cell_data = protocol.reward_items
	local camp_type = protocol.camp_type        						 -- 国旗所在国家
	local reward_times = protocol.reward_times
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local asset1 = ""
	local asset2 = ""
	if camp_type and camp_type ~= vo.camp then
		title_asset = "title_guoqi"								 		 -- 击杀成功
		asset1 = "desc_guoqi_1"        		
		asset2 = "desc_reward"        		
	end
	self:ShowEndTip(title_asset, asset1, asset2, cell_data, nil, nil, reward_times)
end


-- 请求场景中玩家数目 1168
function NationalWarfareCtrl.SendSceneRoleCountReq(scene_id,scene_key)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSSceneRoleCountReq)
	send_protocol.scene_id = scene_id
	send_protocol.scene_key = scene_key
	send_protocol:EncodeAndSend()
end

-- 场景中玩家数目信息返回 1169
function NationalWarfareCtrl:OnSCSceneRoleCountAck(protocol)
	self.data:SetSceneRoleCountAck(protocol)
	if self.view:IsOpen() then
		self.view:FlashCampRoleNum()
	end
end

 -- 刺探任务状态
function NationalWarfareCtrl:OnSCCampCitanStatus(protocol)
	self.data:SetCampCitanStatus(protocol)
	self.start_citan_view:Flush()
	if self.citan_color_view:IsOpen() then
		self.citan_color_view:Flush("start", {index = 3})
		if protocol.cur_qingbao_color ~= 0 then
			self.citan_color_view:Flush("start", {index = 2})
			self.citan_color_view:StartRefreshColor()
		end
	else
		self:OperateTask(self.data:GetCitanTaskCfg())
	end
	if self.open_citan_warfare == 0 and protocol.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_ACCEPT then
		ViewManager.Instance:Open(ViewName.NationalWarfare, TabIndex.national_warfare_spy)
	end
	self.open_citan_warfare = protocol.task_phase
	GlobalEventSystem:Fire(OtherEventType.VIRTUAL_TASK_CHANGE)
	GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE)

	if Scene.Instance:GetMainRole() then
		Scene.Instance:GetMainRole():ReloadUILoverName()
		Scene.Instance:GetMainRole():ReloadCiTanEff()
		Scene.Instance:GetMainRole():UpdateTitle()
	end
end

 -- 搬砖任务状态
function NationalWarfareCtrl:OnSCCampBanzhuanStatus(protocol)
	self.data:SetCampBanzhuanStatus(protocol)
	self.start_banzhuan_view:Flush()
	if self.banzhuan_color_view:IsOpen() then
		self.banzhuan_color_view:Flush("start", {index = 3})
		if protocol.cur_color ~= 0 then
			self.banzhuan_color_view:Flush("start", {index = 2})
			self.banzhuan_color_view:StartRefreshColor()
		end
	else
		self:OperateTask(self.data:GetBanZhuanTaskCfg())
	end
	if self.open_banzhuan_warfare == 0 and protocol.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_ACCEPT then
		ViewManager.Instance:Open(ViewName.NationalWarfare, TabIndex.national_warfare_brick)
	end
	self.open_banzhuan_warfare = protocol.task_phase
	GlobalEventSystem:Fire(OtherEventType.VIRTUAL_TASK_CHANGE)
	GlobalEventSystem:Fire(OtherEventType.TASK_CHANGE)

	self.data:SetBanZhuanHasReceive(true)

	if Scene.Instance:GetMainRole() then	
		Scene.Instance:GetMainRole():ReloadUILoverName()
		Scene.Instance:GetMainRole():ReloadBanZhuanEff()
		Scene.Instance:GetMainRole():UpdateTitle()
	end
end

function NationalWarfareCtrl:BanZhuanRewardInfo(give_times, color, rewards_list)
	if rewards_list and next(rewards_list) then
		self:ShowEndTip("title_banzhuan", "desc_banzhuan_1", "desc_banzhuan_2", rewards_list, ("word_color_" .. color), true, give_times)
	end
end

function NationalWarfareCtrl:CiTanRewardInfo(give_times, color, rewards_list)
	if rewards_list and next(rewards_list) then
		self:ShowEndTip("title_citan", "desc_citan_1", "desc_citan_2", rewards_list, ("word_color_" .. color), true, give_times)
	end
end

-- 大臣防守奖励
function NationalWarfareCtrl:DaChenRewardInfo()
	local title_asset = "title_dachen2"
	local asset1 = "desc_dachen_2"
	local asset2 = "desc_reward"
	local rewards_data = self.data:GetDachenFangShouRewardsData()
	if rewards_data and  next(rewards_data) then
		self:ShowEndTip(title_asset, asset1, asset2, rewards_data)
	end
end

-- 国旗防守奖励
function NationalWarfareCtrl:GuoQiRewardInfo()
	local title_asset = "title_dachen2"
	local asset1 = "desc_guoqi_2"
	local asset2 = "desc_reward"
	local rewards_data = self.data:GetGuoQiFangShouRewardsData()
	if rewards_data and next(rewards_data) then
		self:ShowEndTip(title_asset, asset1, asset2, rewards_data)
	end
end

-- 获取运镖玩家信息
function NationalWarfareCtrl:OnSCCampYunbiaoUsers(protocol)
	self.data:SetCampYunbiaoUsers(protocol)
	self:Flush("flush_yunbiao_view")
	if self.other_yunbiao_view:IsOpen() then
		self.other_yunbiao_view:Flush()
	end
end

-- 刷新View方法
function NationalWarfareCtrl:Flush(key, value_t)
	if self.view then
		self.view:Flush(key, value_t)
	end
end

function NationalWarfareCtrl:FlushYingJiuTask()
	if self.yingjiu_task_view then
		self.yingjiu_task_view:Flush()
	end
end

function NationalWarfareCtrl:ShowEndTip(title_asset, desc_asset, cell_data, color_asset, show_color, give_times)
	self.camp_war_end_tip:SetData(title_asset, desc_asset, cell_data, color_asset, show_color, give_times)
	self.camp_war_end_tip:Open()
end

function NationalWarfareCtrl:OnSCCampYingjiuStatus(protocol)
	self.data:SetSCCampYingjiuStatus(protocol)
	GlobalEventSystem:Fire(OtherEventType.VIRTUAL_TASK_CHANGE)
	if protocol.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_INVALID then return end
	if protocol.is_ack == IS_ACK_REQ.YES then return end 					-- 上线时请求所有信息 不需要往后执行

	if protocol.task_phase == CAMP_TASK_PHASE.CAMP_TASK_PHASE_COMPLETE then 
		CampCtrl.Instance:SendCampTaskCommonOpera(CAMP_TASK_OPERA_TYPE.OPERA_TYPE_COMMIT_TASK, CAMP_TASK_TYPE.CAMP_TASK_TYPE_YINGJIU)
		self.last_task_type = CAMP_TASK_YINGJIU_AIM.CAMP_TASK_YINGJIU_AIM_INVALID
		return
	end


	-- 策划说第一个任务不要自动做
	-- if 0 == protocol.task_seq and 0 == protocol.param1 then 
	-- 	return 
	-- end

	-- 完成对话任务之后弹出战事界面
	local taks_cfg = self.data:GetYingJiuTaskInfoBySeq(protocol.task_seq)
	if not taks_cfg or not next(taks_cfg) then return end

	if CAMP_TASK_YINGJIU_AIM.CAMP_TASK_YINGJIU_AIM_TOUCH_NPC == self.last_task_type then
		self.last_task_type = taks_cfg.aim
		ViewManager.Instance:Open(ViewName.NationalWarfare, TabIndex.national_warfare_rescue)
		return
	end

	self.last_task_type = taks_cfg.aim


	function func()
		--if GuajiCache.guaji_type == GuajiType.HalfAuto or GuajiCache.guaji_type == GuajiType.Monster then
			self:OperateTask(self.data:GetYingJiuInfo())
		--end
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	if not self.delay_timer then 
		self.delay_timer = GlobalTimerQuest:AddDelayTimer(func, 1)
	end
end

function NationalWarfareCtrl:OnSCCampTaskReward(protocol)
	if protocol.task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN then --搬砖的结算
		self:BanZhuanRewardInfo(protocol.give_times, protocol.color, protocol.reward_list)
	
	elseif protocol.task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_CITAN then --刺探的结算
		self:CiTanRewardInfo(protocol.give_times, protocol.color, protocol.reward_list)

	elseif protocol.task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_YINGJIU then --营救的结算
		self:ShowYingJiuEndTip(protocol.reward_list, protocol.give_times)	
	end
end

function NationalWarfareCtrl:OpenYingJiuTaskView()
	self.yingjiu_task_view:Open()
	self.yingjiu_task_view:Flush()
end

function NationalWarfareCtrl:ShowYingJiuEndTip(rewards_list, give_times)
	if not rewards_list or not next(rewards_list) then return end
	self:ShowEndTip("title_yingjiu", "desc_yingjiu_1", "desc_reward", rewards_list, "", nil, give_times)
end

function NationalWarfareCtrl:OnSCCampTaskBeShared(protocol)
	if protocol.task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_BANZHUAN then
		ViewManager.Instance:Open(ViewName.BanZhuanColorView, nil, "start", {index = 1})
		self.banzhuan_color_view:StartRefreshColor(true)
	elseif protocol.task_type == CAMP_TASK_TYPE.CAMP_TASK_TYPE_CITAN then
		ViewManager.Instance:Open(ViewName.CiTanColorView, nil, "start", {index = 1})
		self.citan_color_view:StartRefreshColor(true)
	end
end

function NationalWarfareCtrl:OnCampTotemPillarInfo(protocol)
end

function NationalWarfareCtrl:OnSceneCampTotemPillarInfo(protocol)
	self.data:SetHasRelivePillar(protocol.has_relive_pillar)
end

function NationalWarfareCtrl:OperateTask(task_data)
	local task_view = MainUICtrl.Instance:GetView():GetTaskView()
	if task_view and task_data then
		task_view:OperateTask(task_data)
	end
end

function NationalWarfareCtrl:GetGemChangeRemind(remind_type)
	local flag = 0
	if remind_type == RemindName.CampWarYingJiu then
		local open_flag = OpenFunData.Instance:CheckIsHide("national_warfare_rescue")
		local accept_times, buy_times, max_accept_times = NationalWarfareData.GetYingJiuTimes()
		if max_accept_times + buy_times > accept_times and open_flag then
			flag = 1
		end
	elseif remind_type == RemindName.CampWarCiTan then
		local open_flag = OpenFunData.Instance:CheckIsHide("national_warfare_spy")
		if self.data:GetCampCitanDayCount() > 0 and open_flag then
			flag = 1
		end
	elseif remind_type == RemindName.CampWarBanzhuang then
		local open_flag = OpenFunData.Instance:CheckIsHide("national_warfare_brick")
		if self.data:GetCampBanzhuanDayCount() > 0 and open_flag then
			flag = 1
		end
	elseif remind_type == RemindName.CampWarYunBiao then
		local open_flag = OpenFunData.Instance:CheckIsHide("national_warfare_dart")
		if YunbiaoData.Instance:GetHusongRemainTimes() > 0 and open_flag then
			flag = 1
		end
	elseif remind_type == RemindName.CampWarQiYun then
		local open_flag = OpenFunData.Instance:CheckIsHide("national_warfare_luck")
		if ClickOnceRemindList[RemindName.CampWarQiYun] and ClickOnceRemindList[RemindName.CampWarQiYun] == 0 then
			return 0
		end

		if CampData.Instance:GetQiYunRemind() and open_flag then
			flag = 1
		end
	elseif remind_type == RemindName.CampWarDaChen then
		local open_flag = OpenFunData.Instance:CheckIsHide("national_warfare_minister")
		if self.data:GetDaChenStatus() and open_flag then
			flag = 1
		end
	elseif remind_type == RemindName.CampWarGuoQi then
		local open_flag = OpenFunData.Instance:CheckIsHide("national_warfare_flag")
		if self.data:GetGuoQiStatus() and open_flag then
			flag = 1
		end
	end

	return flag
end
