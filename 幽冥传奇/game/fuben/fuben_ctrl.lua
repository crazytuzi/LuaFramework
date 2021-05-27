require("scripts/game/fuben/fuben_data")
-- require("scripts/game/fuben/fuben_render")
-- require("scripts/game/fuben/fuben_view/tf_opt_view")
-- require("scripts/game/fuben/fuben_view/strength_result_view")
-- require("scripts/game/fuben/fuben_view/tafang_result_view")
require("scripts/game/fuben/fuben_view/hhjd_team_view")
require("scripts/game/fuben/fuben_view/fb_jy_scene_tip_view")

FubenCtrl = FubenCtrl or BaseClass(BaseController)

function FubenCtrl:__init()
	if FubenCtrl.Instance then
		error("[FubenCtrl]:Attempt to create singleton twice!")
	end
	FubenCtrl.Instance = self

	self.data = FubenData.New()
	self.hhjd_team_view = HhjdTeamView.New(ViewDef.HhjdTeam)
	self.fb_jy_scene_tip_view = FbJySceneTip.New(ViewDef.FubenCLSceneTip) --经验副本提示

	self:RegisterAllProtocols()

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.PassDayCallBack, self))

	self.scene_change = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnEnterSceneLoading, self))

 

	--keytest
	GlobalEventSystem:Bind(LayerEventType.KEYBOARD_RELEASED, function (key_code, event)
		if cc.KeyCode.KEY_T == key_code and event == cc.Handler.EVENT_KEYBOARD_PRESSED then
			--FubenCtrl.Instance:OnTopTipEnter(FubenZongGuanCfg.fubens[5].fbid)
		end
	end)

	self.skill_num_change = GlobalEventSystem:Bind(ObjectEventType.OBJ_ATTR_CHANGE, BindTool.Bind1(self.OBjAttrChange, self))
	self.skill_num = 0

	self.skill_num_lianyu = 0

	self.had_num = 0
	self.had_buy_num = 0
end

function FubenCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	FubenCtrl.Instance = nil

	-- if self.tf_opt_view then
	-- 	self.tf_opt_view:DeleteMe()
	-- 	self.tf_opt_view = nil
	-- end

	if self.strength_result_view then
		self.strength_result_view:DeleteMe()
		self.strength_result_view = nil
	end

	-- if self.tafang_result_view then
	-- 	self.tafang_result_view:DeleteMe()
	-- 	self.tafang_result_view = nil
	-- end
	if self.skill_num_change then
		GlobalEventSystem:UnBind(self.skill_num_change)
		self.skill_num_change = nil
	end
end


function FubenCtrl:OBjAttrChange( sceneobj, index, value )
	if sceneobj.obj_type == SceneObjType.Monster and Scene.Instance:GetSceneId() == 94 then
		if index == 7 and value == 0 then
			self.skill_num = self.skill_num + 1
			self.data:SetSkillNUM(self.skill_num)
		end
	elseif sceneobj.obj_type == SceneObjType.Monster and Scene.Instance:GetSceneId() ==  PurgatoryFubenConfig.senceid then
		if index == 7 and value == 0 then
			self.skill_num_lianyu = self.skill_num_lianyu + 1
			self.data:SetSkillNumLianyu(self.skill_num_lianyu)
		end
	end
end


function FubenCtrl:RecvMainRoleInfo()
	self.GetFubenEnterInfo()
end

function FubenCtrl:PassDayCallBack()
	self.GetFubenEnterInfo()
end

function FubenCtrl:OnEnterSceneLoading(scene_id, scene_type, fb_id)
	if scene_type == SceneType.Common then 
		self.fb_jy_scene_tip_view:Close()
		self.skill_num = 0
		self.data:SetSkillNUM(self.skill_num)
		self.skill_num_lianyu = 0
		self.data:SetSkillNumLianyu(self.skill_num_lianyu)
	end
end

function FubenCtrl:SetTaskFollow()
	-- GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE, self.data:GetTaskData())
end

function FubenCtrl:SetCallBossTaskFollow()
	GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE, self.data:GetCallBossTaskData())
end

function FubenCtrl:SetFamTaskFollow()
	GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE, self.data:GetFamTaskData())
	GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, MainuiTask.SHOW_TYPE.RIGHT)
end

function FubenCtrl:CloseTaskFollow()
	self.data:InitFubenInfo()
	GlobalEventSystem:Fire(MainUIEventType.TASK_OTHER_DATA_CHANGE)
end

function FubenCtrl:OpenStrengthRV()
	self.strength_result_view = self.strength_result_view or StrengthResultView.New()
	self.strength_result_view:Open()
end

function FubenCtrl:SetStrengthViewData(data)
	self.strength_result_view = self.strength_result_view or StrengthResultView.New()
	self.strength_result_view:SetViewData(data)
end

-- function FubenCtrl:OpenTfRV(data)
-- 	self.tafang_result_view = self.tafang_result_view or TafangResultView.New()
-- 	self.tafang_result_view:SetViewData(data)
-- 	self.tafang_result_view:Open()
-- end

-- function FubenCtrl:CloseTfResultView()
-- 	if self.tafang_result_view and self.tafang_result_view:IsOpen() then
-- 		self.tafang_result_view:Close()
-- 	end
-- end

function FubenCtrl:OpenTfOptView()
	self.tf_opt_view = self.tf_opt_view or TafangOptView.New()
	self.tf_opt_view:Open()
end

function FubenCtrl:CloseTfOptView()
	if self.tf_opt_view then
		self.tf_opt_view:Close()
	end
end

---------------------------------------
-- 下发
---------------------------------------
function FubenCtrl:RegisterAllProtocols()
	--副本场景信息通用
	self:RegisterProtocol(SCEnterFubenInit, "OnEnterFubenInit")
	self:RegisterProtocol(SCFinishFuBen, "OnFinishFuBen")
	self:RegisterProtocol(SCRecFuBenRewardRes, "OnRecFuBenRewardRes")
	-- self:RegisterProtocol(SCFubenMonsterNum, "OnFubenMonsterNum")
	self:RegisterProtocol(SCFuBenEnterInfo, "OnFuBenEnterInfo")

	-- 塔防
	-- self:RegisterProtocol(SCFubenCumulativeExp, "OnFubenCumulativeExp")
	-- self:RegisterProtocol(SCKillMonsterNum, "OnKillMonsterNum")

	-- 召唤令
	self:RegisterProtocol(SCBossCallInfo, "OnBossCallInfo")

	-- 行会禁地副本信息
	self:RegisterProtocol(SCHhjdFbInfo, "OnHhjdFbInfo")
	self:RegisterProtocol(SCHhjdFbLeftTimes, "OnHhjdFbLeftTimes")
	self:RegisterProtocol(SCHhjdFbFinished, "OnHhjdFbFinished")

	--下发经验副本数据

	self:RegisterProtocol(SCJinYanFubenInfo, "OnJinYanFubenInfo")
	self:RegisterProtocol(SCJinYanFubenInfoOnFuben, "OnJinYanFubenInfoOnFuben")

	--下发炼狱副本数据
	self:RegisterProtocol(SCLianyuFuBenData, "OnLianyuFuBenData")

	--下发当前副本数据
	self:RegisterProtocol(SCLianyuFuBenInFuBenData, "OnLianyuFuBenInFuBenData")
end

function FubenCtrl:OnEnterFubenInit(protocol)
	self.data:SetFubenInfo(protocol)
	self:SetTaskFollow()
	GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true)

	if self.data:GetFubenType() == FubenType.Tafang then
		if self.tf_opt_view then
			self.tf_opt_view:Flush()
		end
	end
	--print("<<<<<<<<<<")
    --经验副本 打开副本场景提示-杀怪数提示
   -- self:OnTopTipEnter(protocol.fuben_id)
end

function FubenCtrl:OnFinishFuBen(protocol)
	GlobalEventSystem:Fire(OtherEventType.FINISH_FUBEN, protocol.fuben_id)

	--经验副本 打开副本场景提示-领取奖励
   -- self:OnTopTipExit(protocol.fuben_id)
    -- 行会禁地不退出
    if protocol.fuben_id == FubenData.FubenCfg[FubenType.Hhjd][1].fubenId or protocol.fuben_id == FubenData.FubenCfg[FubenType.Hhjd2][1].FbId then 
    	self.data:ResetFubenType()
    	return 
    end
   
---面板刷新奖励
	if self.data.fuben_id == protocol.fuben_id then
		self.data.is_finish = true
		if self.data:IsInFuben() then

			self.data:ResetFubenType()
			
			--奖励
			local awards
			local static_id 
			for i = 1, #FubenZongGuanCfg.fubens do
				if FubenZongGuanCfg.fubens[i].fbid == protocol.fuben_id then
					awards = FubenZongGuanCfg.fubens[i].award
					static_id = FubenZongGuanCfg.fubens[i].static_id
					break
				end
			end

			-- 完成副本时,取消自动挂机
			-- GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

			if awards then
			-- GlobalTimerQuest:AddDelayTimer(function() 
				-- Scene.Instance:PickAllItemByFly(
					-- function(params_awards)
						-- local temp_awards = #params_awards <= 0 and awards or params_awards
						PracticeCtrl.Instance:ShowWinPanel(awards,5,function() 
							FubenCtrl.OutFubenReq(protocol.fuben_id)
						end)
					-- end)
				end
			-- end,1)
			------------ end
		end
	end
end

function FubenCtrl:OnRecFuBenRewardRes(protocol)
	if protocol.result == 1 then
		local function OutFubenDelay()
			if FubenData.Instance:GetFubenId() == protocol.fuben_id then
				FubenCtrl.OutFubenReq(protocol.fuben_id)
			end
		end
		GlobalTimerQuest:AddDelayTimer(OutFubenDelay, 0)
	end
end

function FubenCtrl:OnFubenMonsterNum(protocol)
	--刷新经验副本怪物、经验数量 
	--self:OnTopTipFlush{fuben_id = protocol.fuben_id, monster = protocol.cur_monster_num}	

  --if self.data:IsInFuben() then
		-- self.data:SetFubenMonsterNum(protocol)
		-- self:SetTaskFollow()
	-- end
end

function FubenCtrl:OnFuBenEnterInfo(protocol)
	self.data:SetFubenEnterInfo(protocol.fuben_list)
	RemindManager.Instance:DoRemind(RemindName.PerBoss)
	-- ViewManager.Instance:FlushView(ViewName.Boss, TabIndex.boss_personal)
end

-- function FubenCtrl:OnFubenCumulativeExp(protocol)
-- 	if self.data:IsInFuben() then
-- 		self.data:SetCumulativeExp(protocol.cumulative_exp, protocol.loss_exp)
-- 		self:SetTaskFollow()
-- 		if self.data:TaFangTaskIsFinish() then
-- 			self:OpenTfRV(
-- 				{
-- 					FubenData.Instance.fuben_other_info.cumulative_exp,
-- 					FubenData.Instance.fuben_other_info.loss_exp,
-- 				}
-- 			)
-- 		end
-- 	end
-- end

-- function FubenCtrl:OnKillMonsterNum(protocol)
-- 	if self.data:IsInFuben() then
-- 		self.data:SetKillMonsterNum(protocol.kill_num)
-- 		self:SetTaskFollow()
-- 	end
-- end

function FubenCtrl:OnBossCallInfo(protocol)
	self.data:SetCallBossData(protocol)
	self:SetCallBossTaskFollow()
end

---------------------------------------
-- 请求
---------------------------------------
function FubenCtrl.EnterFubenReq(fuben_id)
	if BagData.Instance:GetBagGridNum() - BagData.Instance:GetBagItemCount() < 20 then
		local start_alert = Alert.New()
		start_alert:SetLableString(string.format(Language.Fuben.NoEnoughGrid, 20))
		start_alert:SetOkFunc(function()
			ViewManager.Instance:OpenViewByDef(ViewDef.Recycle)
		end)
		-- self.start_alert:SetShowCheckBox(false)
		start_alert:SetOkString(Language.Fuben.GotoRecycle)
		start_alert:Open()
	else
		local protocol = ProtocolPool.Instance:GetProtocol(CSGEnterFubenReq)
		protocol.fuben_id = fuben_id or 0
		protocol:EncodeAndSend()
	end
end

-- 个人boss领取
function FubenCtrl.RecFubenReward(reward_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRecFubenReward)
	protocol.reward_type = reward_type or 1		--1 为单倍奖励，2 为双倍奖励
	protocol:EncodeAndSend()
end

--材料副本领取奖励
function FubenCtrl.RecMaterialFubenReward(reward_type, fuben_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRecMaterialFubenReward)
	protocol.reward_type = reward_type or 1		--1 为单倍奖励，2 为双倍奖励
	protocol.fuben_index = fuben_index or 0
	protocol:EncodeAndSend()
end

-- 退出副本
function FubenCtrl.OutFubenReq(fuben_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOutFubenReq)
	protocol.fuben_id = fuben_id or 0
	protocol:EncodeAndSend()
end

-- 请求获取副本信息
function FubenCtrl.GetFubenEnterInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetFubenEnterInfo)
	protocol:EncodeAndSend()
end

---------------------------
-- 塔防
---------------------------
-- 塔防开始刷怪
function FubenCtrl.TafangStartReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTafangStartReq)
	protocol:EncodeAndSend()
end

---------------------------
-- 行会禁地
---------------------------
-- 行会禁地副本剩余进入次数
function FubenCtrl:OnHhjdFbLeftTimes(protocol)
	self.data:SetLeftHhjdTimes(protocol.times)
end

-- 行会禁地副本信息
function FubenCtrl:OnHhjdFbInfo(protocol)
	self.data:SetHhjdFbInfo(protocol.area_state)
	if protocol.area_state == HHJD_AREA_STATE.WAIT then
		--请求队伍详细信息
		local timer
		local req_times = 0
		timer = GlobalTimerQuest:AddRunQuest(function()
			req_times = req_times + 1
			if req_times > 30 then
				GlobalTimerQuest:CancelQuest(timer)
			end
			local info = FubenMutilData:GetMyTeamInfo(FubenMutilType.Hhjd, FubenMutilLayer.Hhjd1)
			if info then
				GlobalTimerQuest:CancelQuest(timer)
				FubenMutilCtrl.SendGetTeamDetailInfo(FubenMutilType.Hhjd, FubenMutilId.Hhjd1, info.team_id)
			end
		end, 0.5)
	end
	self:SetTaskFollow()
end

-- 完成行会禁地副本
function FubenCtrl:OnHhjdFbFinished(protocol)
	self.data:FinishHhjd()
	self:SetTaskFollow()
end

-- 行会禁地开启请求
function FubenCtrl.StartHhjdReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSStartHhjdReq)
	protocol:EncodeAndSend()
end


function FubenCtrl.CanEnterFuben(fb_id,istips)
	if not fb_id then return end
	local empty_num = BagData.Instance:GetEmptyNum()
	local need_num = EnterFBGrid[fb_id]
	if need_num > 0 and empty_num < need_num then
		if istips then
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Fuben.NoEnoughGrid,need_num))	
		end
		return false
	end
	return true
end

EnterFBGrid = 
{
	[1] = 20,
	[2] = 30,
}


-----------------------------------
--@顶部提示 相关
function FubenCtrl:OnTopTipEnter(top_tip_type)
	if not FbJySceneTip.TOP_TIP_FUBEN[top_tip_type] then return end
    self.fb_jy_scene_tip_view:ShowEXPFubenTip("open") 
end

function FubenCtrl:OnTopTipFlush(data)
	if not FbJySceneTip.TOP_TIP_FUBEN[data.fuben_id] then return end
	self.fb_jy_scene_tip_view:ShowEXPFubenTip("update", data) 
end

function FubenCtrl:OnTopTipExit(top_tip_type)
	if not FbJySceneTip.TOP_TIP_FUBEN[top_tip_type] then return end
    self.fb_jy_scene_tip_view:ShowEXPFubenTip("exit")
end


---===经验副本--------------------

--请求进入经验副本
function FubenCtrl:SendEnterJiYanFuben(level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqEnterJiYanFuben)
	protocol.foor_level = level
	protocol:EncodeAndSend()
end


--请求扫荡副本
function FubenCtrl:SendSweepJIYanFuben(level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSweepJIYanFuben)
	protocol.foor_level = level
	protocol:EncodeAndSend()
end


--领取经验副本倍数
function FubenCtrl:SendGetJinYanFuben(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetJiYanReWard)
	protocol.get_index = index
	protocol:EncodeAndSend()
end


--经验副本
--============
function FubenCtrl:OnJinYanFubenInfo(protocol)
	self.data:SetJiYanFuBenInfo(protocol)
	if protocol.is_saodang == 1 then -- 扫荡打开界面
		ViewManager.Instance:OpenViewByDef(ViewDef.ShowRewardExp)
	end
end


function FubenCtrl:OnJinYanFubenInfoOnFuben(protocol)
	self.data:SendGetJinYanFubenONFuben(protocol)
	self.skill_num = 0  --下发数据清空
	self.data:SetSkillNUM(self.skill_num)
end

--==============炼狱副本

	-- --下发炼狱副本数据
	-- self:RegisterProtocol(SCLianyuFuBenData, "OnLianyuFuBenData")

	-- --下发当前副本数据
	-- self:RegisterProtocol(SCLianyuFuBenInFuBenData, "OnLianyuFuBenInFuBenData")
function FubenCtrl:OnLianyuFuBenData(protocol)
	self.data:SetOnLianyuFuBenData(protocol)
	local bool = true
	if protocol.had_buy_num  > self.had_buy_num  then
		self.had_buy_num = protocol.had_buy_num
		bool = false
	end
	if protocol.is_saodang > 0 and bool then --如果是扫荡--并且不是购买次数的话
		ViewManager.Instance:OpenViewByDef(ViewDef.LianyuReward)
	end
end

function FubenCtrl:OnLianyuFuBenInFuBenData(protocol)
	self.data:SetOnLianyuFuBenInFuBenData(protocol)
	self.skill_num_lianyu = 0
	self.data:SetSkillNumLianyu(self.skill_num_lianyu)
end