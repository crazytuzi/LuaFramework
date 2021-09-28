require("game/yunbiao/yunbiao_view")
require("game/yunbiao/yunbiao_data")
-- 运镖
YunbiaoCtrl = YunbiaoCtrl or BaseClass(BaseController)

function YunbiaoCtrl:__init()
	if YunbiaoCtrl.Instance ~= nil then
		print_error("[YunbiaoCtrl] attempt to create singleton twice!")
		return
	end
	YunbiaoCtrl.Instance = self

	self.view = YunbiaoView.New(ViewName.YunbiaoView)
	self.data = YunbiaoData.New()

	self.continue_alert = nil

	self.jiu_yuan_alert = nil

	self:RegisterAllProtocols()
end

function YunbiaoCtrl:__delete()
	YunbiaoCtrl.Instance = nil

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function YunbiaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCHusongInfo, "OnHusongInfo")
	self:RegisterProtocol(SCHusongConsumeInfo, "HusongConsumeInfo")
	self:RegisterProtocol(CSRefreshHusongTask)
	self:RegisterProtocol(CSHusongBuyTimes)
	--Remind.Instance:RegisterOneRemind(RemindId.act_husong, BindTool.Bind1(self.CheckRemind, self))
end

function YunbiaoCtrl:CheckRemind(remind_id)
	if remind_id == RemindId.act_husong then
		return TaskData.Instance:GetTaskRemainTimes(GameEnum.TASK_TYPE_HU)
	end
	return 0
end

function YunbiaoCtrl:Open(tab_index, param_t)
	self.view:Open()

	if param_t ~= nil then
		self.view:SetNpcId(param_t.from_npc_id)
	end
end

function YunbiaoCtrl:Close()
	self.view:Close()
end

-- 刷新护送对象
function YunbiaoCtrl:SendRefreshHusongTask(is_autoflush, is_autobuy)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRefreshHusongTask)
	protocol.is_autoflush = is_autoflush
	protocol.is_autobuy = is_autobuy
	protocol.to_color = 5
	protocol:EncodeAndSend()
end

-- 购买次数
function YunbiaoCtrl:SendHusongBuyTimes()
	local protocol = ProtocolPool.Instance:GetProtocol(CSHusongBuyTimes)
	protocol:EncodeAndSend()
end

-- 更新任务的次数
function YunbiaoCtrl:OnLingQuCiShuChangeHandler(value)
	if value then
		local old_data = self.data:GetLingQuCishu()
		if value ~= old_data then
			self.data:SetLingQuCishu(value)
			self.view:Flush()
		end
	end
end

-- 更新购买的次数
function YunbiaoCtrl:OnGouMaiCiShuChangeHandler(value)
	if value then
		local old_data = self.data:GetGouMaiCishu()
		if value ~= old_data then
			self.data:SetGouMaiCishu(value)
			self.view:Flush()
			GlobalEventSystem:Fire(OtherEventType.DAY_COUNT_CHANGE, DAY_COUNT.DAYCOUNT_ID_ACCEPT_HUSONG_TASK_COUNT)
		end
	end
end

-- 更新免费刷新美女的次数
function YunbiaoCtrl:OnChangeRefreshFreeTimeHandler(value)
	if value then
		local old_data = self.data:GetRefreshFreeTime()
		if value ~= old_data then
			self.data:SetRefreshFreeTime(value)
			self.view:Flush()
		end
	end
end

-- 刷新护送对象返回
function YunbiaoCtrl:OnHusongInfo(protocol)
	local role = Scene.Instance:GetRoleByObjId(protocol.obj_id)
	if nil ~= role then
		role:SetAttr("husong_color", protocol.task_color or 0)
		role:SetAttr("husong_taskid", protocol.task_id or 0)
		if role:IsMainRole() then
			self.data:SetAcceptInActivitytime(protocol.accept_in_activitytime)
			self.data:SetIsUseHuDun(protocol.is_use_hudun)
			if MainUICtrl.Instance.view and MainUICtrl.Instance.view.reminding_view then
				MainUICtrl.Instance.view.reminding_view:SetHuDunGray(protocol.is_use_hudun == 1)
			end
			if protocol.notfiy_reason == 1 then			-- 接任务
				TaskCtrl.Instance:DoTask(protocol.task_id)
				self.view:Close()
			--elseif protocol.notfiy_reason == 2 then		-- 任务失败
			elseif protocol.notfiy_reason == 3 then		-- 任务成功
				local describe = string.format(Language.YunBiao.Continue, ( "<color=#0000f1>"..self.data:GetLingQuCishu().."</color>"))
				local yes_func = function() self:MoveToHuShongReceiveNpc(true) end
				TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
			end
		end
	end
	if self.view then
		self.view:Flush()
	end
end

-- 刷新护送对象返回
function YunbiaoCtrl:HusongConsumeInfo(protocol)
	SysMsgCtrl.Instance:ErrorRemind(string.format(Language.YunBiao.XiaoHao, protocol.token_num, protocol.gold_num, protocol.bind_gold_num))
end

-- 求救
function YunbiaoCtrl:QiuJiuHandler()
	local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
	if guild_id > 0 then
		local yes_func = function() self:SendGuildSosReq(0) end
		local describe = string.format(Language.Guild.QIUYUAN2)
		TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Role.NoGuild)
	end
end

function YunbiaoCtrl:SendGuildSosReq(sos_type)
	GuildCtrl.Instance:SendSendGuildSosReq(sos_type)
end

function YunbiaoCtrl:MoveToHuShongReceiveNpc(ignore_vip)
	ignore_vip = true

	-- 为了使切场景的时候自动对话
	TaskData.Instance:SetCurTaskId(YunbiaoData.Instance:GetTaskIdByCamp())

	if self.data:GetIsHuShong() then
		SysMsgCtrl.Instance:ErrorRemind(Language.YunBiao.YunBiaoZhong)
	else
		GuajiCtrl.Instance:MoveToNpc(COMMON_CONSTS.NPC_HUSONG_RECEIVE_ID, YunbiaoData.Instance:GetTaskIdByCamp(), nil, ignore_vip, 0)
	end
end

-- 运送施放护盾
function YunbiaoCtrl:SendHuSongAddShieldReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSHuSongAddShield)
	protocol:EncodeAndSend()
end