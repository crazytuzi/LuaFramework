require("game/jinghuahusong/jinghuahusong_data")
-- 护送精华
JingHuaHuSongCtrl = JingHuaHuSongCtrl or BaseClass(BaseController)

function JingHuaHuSongCtrl:__init()
	if JingHuaHuSongCtrl.Instance ~= nil then
		print_error("[JingHuaHuSongCtrl] attempt to create singleton twice!")
		return
	end
	JingHuaHuSongCtrl.Instance = self
	self.data = JingHuaHuSongData.New()
	self:RegisterAllProtocols()

	self.send_commit_req = BindTool.Bind(self.SendCommitReq, self)

end

function JingHuaHuSongCtrl:__delete()
	JingHuaHuSongCtrl.Instance = nil

	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.remain_time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.remain_time_quest)
		self.remain_time_quest = nil
	end

	if self.least_time_timer then
	    CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    self.least_time_timer = nil
	end
end

function JingHuaHuSongCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCJinghuaHusongViewChange, "OnJinghuaHusongViewChange")			--护送状态改变
	self:RegisterProtocol(CSReqCommonOpreate)
end

--继续护送精华
function JingHuaHuSongCtrl:ContinueJingHuaHuSong(jinghua_type)
	jinghua_type = jinghua_type or self.data.cur_jinghua_type
	if self.data:GetMainRoleState() == JH_HUSONG_STATUS.NONE then
		self:MoveToGather(false, jinghua_type)								--前往采集物
	else
		self:MoveToHuShongCommitNpc()										--前往任务提交NPC
	end
end

--精华护送信息
function JingHuaHuSongCtrl:SetJingHuaHuSongInfo(protocol)
	if protocol.param1 == -1  then										-- param1 == -1表示精华采集物刷新。
		if GameVoManager.Instance:GetMainRoleVo().level >= self.data:GetRemindLevel() and not self.data:IsAllCommit() then	-- 如果等级足够且未全部采集完，则提醒玩家
			TipsCtrl.Instance:OpenFocusJingHuaHuSongTip()				-- 弹出提醒框
		end
	else																-- param1 ~= -1存储精华护送信息
		if not self.remain_time_quest then
			self.remain_time_quest = GlobalTimerQuest:AddRunQuest(function() 	-- 护送剩余时间倒计时
				self.data:SetRemainTime(self.data:GetRemainTime() - 1)
				self:SetJingHuaHuSongTime(self.data:GetRemainTime())
			end, 1)
		end
		self.data:SetJingHuaHuSongInfo(protocol)
		GlobalEventSystem:Fire(OtherEventType.VIRTUAL_TASK_CHANGE)
	end
end

--护送状态改变
function JingHuaHuSongCtrl:OnJinghuaHusongViewChange(protocol)
	self:SendGetInfoReq()
	local role = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if nil ~= role then
		role:SetAttr("jinghua_husong_type", protocol.jinghua_husong_type) 		--设置护送类型，以更换护送图标
		role:SetAttr("jinghua_husong_status", protocol.jinghua_husong_status) 	--设置状态，以更换护送图标
		if role:IsMainRole() then
			self.data:SetMainRoleState(protocol.jinghua_husong_status)
			if protocol.jinghua_husong_type and protocol.jinghua_husong_type ~= -1 then
				self.data:SetCurJingHuaType(protocol.jinghua_husong_type)
			end
			local main_role = Scene.Instance:GetMainRole()
			if protocol.jinghua_husong_status ~= JH_HUSONG_STATUS.NONE then
				if main_role then
					main_role:AddBuff(BUFF_TYPE.CHIHUAN)
				end
				self:ContinueJingHuaHuSong(protocol.jinghua_husong_type)
			else
				if main_role then
					main_role:RemoveBuff(BUFF_TYPE.CHIHUAN)
				end
			end
		end
	end
end

--精华采集物数据更变
function JingHuaHuSongCtrl:OnJingHuaGatherChange(gather_id, gather_times, time)
	local gather = Scene.Instance:SelectMinDisGather(gather_id)
	local name = string.format(Language.JingHuaHuSong.JingHuaName, gather_times)

	if gather and gather_id == self.data:GetGatherId(JingHuaHuSongData.JingHuaType.Small) then
		gather:ChangeShowName(Language.JingHuaHuSong.SmallJingHuaName, 1.4, 0)
	end

	if gather and gather_id == self.data:GetGatherId(JingHuaHuSongData.JingHuaType.Big) then

		-- gather_times > 0 代表灵石还有剩余，不需要显示下一批灵石的刷新时间
		if gather_times > 0 then
			if self.least_time_timer then
		    	CountDown.Instance:RemoveCountDown(self.least_time_timer)
		    	self.least_time_timer = nil
		   	end
			gather:ChangeShowName(name)
		else
			if self.least_time_timer then
		    	CountDown.Instance:RemoveCountDown(self.least_time_timer)
		    	self.least_time_timer = nil
		   	end

		   	local next_time = time or 0
		   	local server_time = TimeCtrl.Instance:GetServerTime()
			local rest_time = math.floor(next_time - server_time)

			-- rest_time > 0 代表需要刷新下一批灵石时间
			if rest_time > 0 then
				self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function (elapse_time, total_time)
					local left_time = total_time - elapse_time

					-- 刷新下一批灵石的倒计时开头
					if left_time <= 0 then
						left_time = 0
						if self.least_time_timer then
		    				CountDown.Instance:RemoveCountDown(self.least_time_timer)
		    				self.least_time_timer = nil
		   				end
		   				gather:ChangeShowName(name)
		   			else

						local time = JingHuaHuSongData:GetNextTime(left_time)
						local now_time = string.format(Language.JingHuaHuSong.NextFlushTime, time)
				        gather:ChangeShowName(name .. now_time)
			        end
			        -- 刷新下一批灵石的倒计时结尾

			    end)
			else
			    gather:ChangeShowName(name)
			end
		end
	end
	self.data:SetJingHuaGatherAmount(gather_id, gather_times)
end

--前往提交任务NPC
function JingHuaHuSongCtrl:MoveToHuShongCommitNpc(ignore_vip)
	GuajiCtrl.Instance:MoveToNpc(self.data:GetCommitNpc(), nil, self.data:GetGatherSceneId(), ignore_vip, 0)
end

--前往采集物
function JingHuaHuSongCtrl:MoveToGather(ignore_vip, jinghua_type)
	jinghua_type = jinghua_type or self.data.cur_jinghua_type
	local func = function()
		ViewManager.Instance:CloseAll()
		MoveCache.end_type = MoveEndType.GatherById
		MoveCache.param1 = self.data:GetGatherId(jinghua_type)
		GuajiCtrl.Instance:MoveToPos(self.data:GetGatherSceneId(jinghua_type), self.data:GetGatherPosX(jinghua_type),self.data:GetGatherPosY(jinghua_type), 5, nil, true, 0, self.data.GetTaskId())
	end
	local scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	if scene_key ~= 0 and self.data:GetGatherSceneId(jinghua_type) == Scene.Instance:GetSceneId() then
		TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Activity.JinghuaSceneLineLimit)
	else
		func()
	end
end

--提交物品
function JingHuaHuSongCtrl.SendCommitReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqCommonOpreate)
	protocol.operate_type = COMMON_OPERATE_TYPE.COT_JINGHUA_HUSONG_COMMIT
	protocol.param1 = 0
	protocol.param2 = 0
	protocol.param3 = 0
	protocol:EncodeAndSend()
end

--请求精华护送信息
function JingHuaHuSongCtrl.SendGetInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqCommonOpreate)
	protocol.operate_type = COMMON_OPERATE_TYPE.COT_JINGHUA_HUSONG_COMMIT_OPE
	protocol.param1 = 0
	protocol.param2 = 0
	protocol.param3 = 0
	protocol:EncodeAndSend()
end

--请求购买采集次数
function JingHuaHuSongCtrl.SendBuyGatherTimesReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqCommonOpreate)
	protocol.operate_type = COMMON_OPERATE_TYPE.COT_JINGHUA_HUSONG_BUY_GATHER_TIMES
	protocol.param1 = 0
	protocol.param2 = 0
	protocol.param3 = 0
	protocol:EncodeAndSend()
end

--判断活动是否开启
function JingHuaHuSongCtrl:IsOpen()
	local statu = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.JINGHUA_HUSONG)
	if statu and statu.status == ACTIVITY_STATUS.OPEN then
		return true
	end
	return false
end

--设置主界面护送倒计时
function JingHuaHuSongCtrl:SetJingHuaHuSongTime(time)
	if not MainUIViewChat.Instance then return end
	local time_tab = TimeUtil.Format2TableDHMS(time)
	if self.data:GetMainRoleState() ~= JH_HUSONG_STATUS.NONE then
		MainUIViewChat.Instance:SetJingHuaHuSongTime(time_tab.min..":"..time_tab.s)
	else
		MainUIViewChat.Instance:SetJingHuaHuSongTime("")
	end
	if time <= 0 then
		if self.remain_time_quest ~= nil then
			GlobalTimerQuest:CancelQuest(self.remain_time_quest)
			self.remain_time_quest = nil
			--GlobalEventSystem:Fire(OtherEventType.VIRTUAL_TASK_CHANGE)
		end
		return
	end
end
--是否还有精华采集物
function JingHuaHuSongCtrl:HaveJingHuaInScene()
	local big_gather_id = self.data:GetGatherId(JingHuaHuSongData.JingHuaType.Big)
	local small_gather_id = self.data:GetGatherId(JingHuaHuSongData.JingHuaType.Small)
	if self.data:GetJingHuaGatherAmount(big_gather_id) > 0 or self.data:GetJingHuaGatherAmount(small_gather_id) > 0 then
		return true
	else
		return false
	end
end

--是否能采集精华
function JingHuaHuSongCtrl:CanGatherJingHua(gahter_id)
	if self.data:GetJingHuaGatherAmount(gahter_id) <= 0 or self.data:GetMainRoleState() ~= JH_HUSONG_STATUS.NONE or self.data:IsAllCommit() then
		return false
	else
		return true
	end
end
--打开msgBox询问玩家是否回去采集
function JingHuaHuSongCtrl:CheckAndOpenContinueMessageBox()
	if not self.data:IsAllCommit() then
		TipsCtrl.Instance:ShowCommonAutoView(nil, Language.JingHuaHuSong.AskReturn, function()
			self:MoveToGather(true)
		end)
	end
end