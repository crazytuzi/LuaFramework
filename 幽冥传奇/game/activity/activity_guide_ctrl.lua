-- 活动导航
ActivityCtrl = ActivityCtrl or BaseClass(BaseController)

function ActivityCtrl:RegisterGuideProtocols()
	-- self:RegisterProtocol(SCParticipateActivity, "OnParticipateActivity")
	self:RegisterProtocol(SCRefreActivityData, "OnRefreActivityData")
	self:RegisterProtocol(SCExitActivity, "OnExitActivity")
	self:RegisterProtocol(SCBuyInspirResultse, "OnBuyInspirResultse")
	self:RegisterProtocol(SCUpdateWorldBossRanking, "OnUpdateWorldBossRanking")
	self:RegisterProtocol(SCUpdateWorldBossMyScore, "OnUpdateWorldBossMyScore")
	self:RegisterProtocol(SCUpdateGuildBossRanking, "OnUpdateGuildBossRanking")
	self:RegisterProtocol(SCWorldBossDie, "OnWorldBossDie")

	self:RegisterProtocol(SCMoveToEsCarNear, "OnMoveToEsCarNear")
	self:RegisterProtocol(SCQuitEscortResultPost, "OnQuitEscortResultPost")
	self:RegisterProtocol(SCEscortStateChange, "OnEscortStateChange")
	self:RegisterProtocol(SCHuSongCarHpAck, "OnHuSongCarHpAck")

	GlobalEventSystem:Bind(OtherEventType.SUCCESS_ESCORT, BindTool.Bind1(self.OnSuccessEscort, self))
	self:Bind(OtherEventType.ENTER_ESCORT_VALID, BindTool.Bind1(self.OnEnterEscortValid, self))
	self:Bind(OtherEventType.OUT_ESCORT_VALID, BindTool.Bind1(self.OnOutEscortValid, self))
end

-- 参与活动信息
function ActivityCtrl:OnParticipateActivity(protocol)
end

-- 更新活动数据 (145, 21)
function ActivityCtrl:OnRefreActivityData(protocol)
	self.data:SetActData(protocol)
end

-- 退出活动 (145, 22)
function ActivityCtrl:OnExitActivity(protocol)
	ActivityData.Instance:ExitActivity()
end

-- 退出活动请求 (145, 20)
function ActivityCtrl.ExitActivityScene()
	local act_id = ActivityData.Instance:GetActivityID()
	if ActivityData.IsInEscortActivityScene() then
		act_id = DAILY_ACTIVITY_TYPE.YA_SONG
	end
	if nil ~= act_id then
		local protocol = ProtocolPool.Instance:GetProtocol(CSExitActivity)
		protocol.act_id = act_id
		protocol:EncodeAndSend()
	end
end

-- 购买鼓舞次数(145, 28)
function ActivityCtrl.SentBuyInspireReq(act_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyInspireReq)
	protocol.act_id = act_id
	protocol:EncodeAndSend()
end

-- 更新行会BOSS排行榜(26, 92)
function ActivityCtrl:OnUpdateGuildBossRanking(protocol)
	self.data:UpdateBossRanking(protocol)
end

-- 接收已击杀行会boss
function ActivityCtrl:OnGuildBossDie()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local scene_id = main_role_vo.scene_id
	local cfg = StdActivityCfg[DAILY_ACTIVITY_TYPE.HANG_HUI_BOSS] or {}
	if cfg.sceneId ~= scene_id then return end

	local ranking_data = ActivityData.Instance:GetRankingData()
	ranking_data["guild_boss_die"] = 1 -- 行会BOSS被击杀时,禁止主动退出活动
	UiInstanceMgr.Instance:AddTimeLeaveView(cfg.endTimeCD, function (elapse_time, total_time, view) 
			local num = total_time - math.floor(elapse_time)
			--时间为零 退出副本
			if num == 0 then
				view:StopTimeDowner()
				ranking_data["guild_boss_die"] = 0
			end
		end, "act_world_boss_tip")

	SysMsgCtrl.Instance:FloatingTopRightText(string.format("请大家%d秒内不要退出活动,等候发奖励!", cfg.endTimeCD or 8))
end

---------------------------------------------------------------
-- 世界boss
---------------------------------------------------------------

-- 购买鼓舞次数结果(145, 32)
function ActivityCtrl:OnBuyInspirResultse(protocol)
	self.data:SetBossInspireTimes(protocol)
end

-- 更新世界boss排行榜数据(145, 33)
function ActivityCtrl:OnUpdateWorldBossRanking(protocol)
	self.data:UpdateBossRanking(protocol)
end

-- 更新世界boss排行榜自己的积分(145, 34)
function ActivityCtrl:OnUpdateWorldBossMyScore(protocol)
	self.data:SetWorldBossMyScore(protocol)
end

-- 接收已击杀世界boss
function ActivityCtrl:OnWorldBossDie(protocol)
	local ranking_data = ActivityData.Instance:GetRankingData()
	ranking_data["world_boss_die"] = 1 -- 世界BOSS被击杀时,禁止主动退出活动
	local cfg = StdActivityCfg[DAILY_ACTIVITY_TYPE.SHI_JIE_BOSS] or {}
	UiInstanceMgr.Instance:AddTimeLeaveView(cfg.bossDieKickTimes, function (elapse_time, total_time, view) 
			local num = total_time - math.floor(elapse_time)
			--时间为零 退出副本
			if num == 0 then
				view:StopTimeDowner()
				ranking_data["world_boss_die"] = 0
			end
		end, "act_world_boss_tip")

	SysMsgCtrl.Instance:FloatingTopRightText(string.format(cfg.bossDieNotice or "", cfg.bossDieKickTimes or 8))
end

---------------------------------------------------------------
-- 押镖
---------------------------------------------------------------
function ActivityCtrl:OnEnterEscortValid()
	ActivityCtrl.SentChangeEscortStateReq(1)
end

function ActivityCtrl:OnOutEscortValid()
	ActivityCtrl:StopEscort()
end

function ActivityCtrl:OnMainRolePosChange(x, y)
	self:UpdateBiaoche(x, y)
end

function ActivityCtrl:UpdateBiaoche(x, y)
	if MoveCache.end_type ~= MoveEndType.Normal and ActivityData.Instance:IsAutoYabiao() then
		ActivityData.Instance:SetAutoYabiao(false)
	end
	
	local no_find_biaoche = true 	--镖车是否在视野内
	for k, v in pairs(Scene.Instance:GetMonsterList()) do
		if v:IsMainRoleBiaoche() then
			no_find_biaoche = false

			local bc_x, bc_y = v:GetLogicPos()
			local node = v:GetModel():GetLayerNode(39, InnerLayerType.BiaocheCircle)

			-- 创建镖车光圈
			if nil == node then
				local circle_area_img = XUI.CreateImageView(0, 0, "", false)
				circle_area_img:setScale(1)
				v:GetModel():AttachNode(circle_area_img, cc.p(0, 0), 39, InnerLayerType.BiaocheCircle, true)
				node = circle_area_img
			end

			if math.abs(bc_x - x) <= 10 and math.abs(bc_y - y) <= 10 then	-- 主角在镖车有效范围内
				if node then
					node:loadTexture(ResPath.GetBigPainting("biaoche_area_green"), false)
				end

				if not ActivityData.Instance:IsEscort() then
					GlobalEventSystem:Fire(OtherEventType.ENTER_ESCORT_VALID)
				end
			else
				if node then
					node:loadTexture(ResPath.GetBigPainting("biaoche_area_yellow"), false)
				end

				if ActivityData.Instance:IsEscort() then
					GlobalEventSystem:Fire(OtherEventType.OUT_ESCORT_VALID)
				end
			end
			break
		end
	end

	-- 镖车不在视野内
	if no_find_biaoche and ActivityData.Instance:IsEscort() then
		GlobalEventSystem:Fire(OtherEventType.OUT_ESCORT_VALID)
	end

	if ActivityData.Instance:IsAutoYabiao() then
		self:MoveToBiaoche()
	end
end

-- 服务端继续押镖返回镖车坐标
local bc_x, bc_y, bc_scene_id = 0, 0, -1
function ActivityCtrl:OnMoveToEsCarNear(protocol)
	bc_x, bc_y, bc_scene_id = protocol.pos_x, protocol.pos_y, protocol.scene_id
	if self.delay_flush_timer == nil then
		self.delay_flush_timer = GlobalTimerQuest:AddDelayTimer(function()
			self.delay_flush_timer = nil
			if ActivityData.Instance:IsAutoYabiao() then
				-- 自动跟随镖车
				self:MoveToBiaoche()
			end
		end, 0.3)
	end
end

-- 移动或者传送到镖车旁边
local last_move_to_bc_time = 0
function ActivityCtrl:MoveToBiaoche()
	if Status.NowTime < last_move_to_bc_time + 0.8 then
		return
	end
	last_move_to_bc_time = Status.NowTime

	-- 视野内是否有交镖处，如果有则交镖
	for k,v in pairs(Scene.Instance:GetNpcList()) do
		if v.vo and v.vo.npc_id == 82 then
			MainuiTask.OnTaskTalkToNpc({npc = {scene_id = 219, x = v.vo.pos_x, y = v.vo.pos_y, id = v.vo.npc_id}, task_id = 0})
			break
		end
	end

	local can_move_to = false
	local biaoche_obj
	for k, v in pairs(Scene.Instance:GetMonsterList()) do
		if v:IsMainRoleBiaoche() then
			biaoche_obj = v
			break
		end
	end

	if biaoche_obj then
		local target_x, target_y = biaoche_obj:GetLogicPos()
		local x, y = Scene.Instance:GetMainRole():GetLogicPos()
		local distance = GameMath.GetDistance(x, y, target_x, target_y, false)
		if distance < 225 then
			MoveCache.end_type = MoveEndType.Normal
			bc_scene_id = -1
			GuajiCtrl.Instance:MoveToObj(biaoche_obj, 1)
			can_move_to = true

			local bc_dir =  biaoche_obj:GetDirNumber()
			for k, v in pairs(Scene.Instance:GetSpecialObjList()) do
				-- 判断镖车快靠近传送阵时，人物直接往那个传送阵跑
				if EntityType.Transfer == v.vo.entity_type then
					local w = math.abs(target_x - v.logic_pos.x)	-- 镖车离传送阵的距离
					local h = math.abs(target_y - v.logic_pos.y)
					local main_w = math.abs(target_x - x)			-- 镖车离主角的距离
					local main_h = math.abs(target_y - y)
					local move_to_dir = GameMath.GetDirectionNumber(v.logic_pos.x - target_x, v.logic_pos.y - target_y)
					if biaoche_obj:IsMove() and bc_dir == move_to_dir and w < 9 and h < 9 and main_w < 4 and main_h < 4 then
						GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), v.logic_pos.x, v.logic_pos.y, 0, 0)
						break
					end
				end
			end
		end
	end

	-- 离镖车太远请求协议得到镖车的具体位置
	if not can_move_to then
		if bc_scene_id > 0 then
			MoveCache.end_type = MoveEndType.Normal
			GuajiCtrl.Instance:MoveToScenePos(bc_scene_id, bc_x, bc_y)
		else
			if bc_scene_id < 0 then
				-- Scene.Instance:GetMainRole():StopMove()
				ActivityCtrl.SentContinueEscortReq()
			end
		end
	end
end

-- 放弃护送结果
function ActivityCtrl:OnQuitEscortResultPost(protocol)
	if protocol.result == 1 then
		Scene.Instance:GetMainRole():StopMove()
		self:ClearEscortGuide()
	end
end

-- 请求改变押镖状态结果(如果失败无返回)
function ActivityCtrl:OnEscortStateChange(protocol)
	self.data:SetEscortState(protocol.escort_state)
	if protocol.escort_state == 1 then
	else
		MoveCache.param1 = nil
	end
end

function ActivityCtrl:OnHuSongCarHpAck(protocol)
	local node_list = self.data:GetNodeList()
	local node = node_list[DAILY_ACTIVITY_TYPE.YA_SONG]
	if node then
		local car_info = self.data.car_info
		local color = protocol.car_cur_hp < car_info.max_hp and COLORSTR.RED or COLORSTR.WHITE
		local text = string.format(car_info.text, color, protocol.car_cur_hp, car_info.max_hp)
		node = RichTextUtil.ParseRichText(node, text, 22)
		self.data:SetNodeList(DAILY_ACTIVITY_TYPE.YA_SONG, node)
	end
end

-- 成功交镖
function ActivityCtrl:OnSuccessEscort()
	self:ClearEscortGuide()
end

-- 清除镖车导航
function ActivityCtrl:ClearEscortGuide()
	self:StopAutoEscort()
	self:ClearUpdateBiaocheTimer()
end

-- 护送押镖面板请求放弃护送
function ActivityCtrl.SentQuitEscortReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSQuitEscortReq)
	protocol:EncodeAndSend()
end

-- 继续护送
function ActivityCtrl.SentContinueEscortReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSContinueEscortReq)
	protocol:EncodeAndSend()
end

-- 传送到镖车旁边
function ActivityCtrl.SentTransmitToCarReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTransmitToCarReq)
	protocol:EncodeAndSend()
end

-- 停止运镖
function ActivityCtrl:StopEscort()
	if ActivityData.Instance:IsEscort() then
		ActivityCtrl.SentChangeEscortStateReq(2)
	end
end

-- 开始自动运镖
function ActivityCtrl:StartAutoEscort()
	ActivityData.Instance:SetAutoYabiao(true)
	MoveCache.end_type = MoveEndType.Normal
	self:CreateUpdateBiaocheTimer()
end

-- 停止自动运镖
function ActivityCtrl.StopAutoEscort()
	if ActivityData.Instance:IsAutoYabiao() then
		Scene.Instance:GetMainRole():SetFollowObj(nil, 0)
		ActivityData.Instance:SetAutoYabiao(false)
	end
end

function ActivityCtrl:CreateUpdateBiaocheTimer()
	self:ClearUpdateBiaocheTimer()
	local function timer_func()
		ActivityCtrl.Instance:UpdateBiaoche(Scene.Instance:GetMainRole():GetLogicPos())
	end
	timer_func()
	self.update_biaoche_timer = GlobalTimerQuest:AddRunQuest(timer_func, 1)

	self.role_pos_change_event = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind(self.OnMainRolePosChange, self))
end

function ActivityCtrl:ClearUpdateBiaocheTimer()
	if nil ~= self.update_biaoche_timer then
		GlobalTimerQuest:CancelQuest(self.update_biaoche_timer)
		self.update_biaoche_timer = nil
	end
	if nil ~= self.role_pos_change_event then
		GlobalEventSystem:UnBind(self.role_pos_change_event)
		self.role_pos_change_event = nil
	end
end

-- 请求改变押镖状态 1押镖, 2暂停押镖
function ActivityCtrl.SentChangeEscortStateReq(escort_state)
	local protocol = ProtocolPool.Instance:GetProtocol(CSChangeEscortStateReq)
	protocol.escort_state = escort_state
	protocol:EncodeAndSend()
end

---------------------------------------------------------------
-- 押镖 end
---------------------------------------------------------------