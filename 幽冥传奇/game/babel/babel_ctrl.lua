require("scripts/game/babel/babel_success_view")
require("scripts/game/babel/babel_data")
require("scripts/game/babel/babel_fuben_info_view")
require("scripts/game/babel/babel_turntable_view")
BabelCtrl = BabelCtrl or BaseClass(BaseController)

function BabelCtrl:__init()
	if BabelCtrl.Instance then
		ErrorLog("[BabelCtrl] attempt to create singleton twice!")
		return
	end
	BabelCtrl.Instance = self

	self.data = BabelData.New()

	self:RegisterAllProtocols()
	self.babel_fuben_view = BabelFubenInfoView.New(ViewDef.BabelInfo)

	self.babel_win_view = BabelSuccessView.New(ViewDef.BabelWin)

	self.babel_turntable_view = BabelTurnTableView.New(ViewDef.BabelTurnTable)
	--ViewDef.BabelWin 
	self.cur_tower_level = 0
end

function BabelCtrl:__delete()
	BabelCtrl.Instance = nil
	
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.babel_fuben_view then
		self.babel_fuben_view:DeleteMe()
		self.babel_fuben_view = nil 
	end

	self:CancelTimer()
end

function BabelCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCBabelData, "OnBabelData")
	self:RegisterProtocol(SCBabelRankingListData, "OnBabelRankingListData")
	GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnSceneLoadingStateEnter, self))

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.TongTianTaSangdang)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.TongTiantaChouJiang)

-- 	[RemindName.TongTianTaSangdang] = {RemindGroupName.TrialView, RemindGroupName.BabelTabbar},
-- 	[RemindName.TongTiantaChouJiang] = {RemindGroupName.TrialView, RemindGroupName.BabelTabbar},
end


--通天塔操作1:挑战 2:扫荡 3:购买次数 4：抽奖(轮盘) 5：申请排行榜数据
function BabelCtrl:SendOpeateBabel(operate_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenrateBabel)
	protocol.operate_type = operate_type
	protocol:EncodeAndSend()
end


function BabelCtrl:OnBabelData(protocol)
	self.data:SetBabelData(protocol)
	if protocol.is_success == 1 then
		local level = protocol.togguang_level
		local cfg = BabelTowerFubenConfig and BabelTowerFubenConfig.layerlist or {}
		local cur_cfg = cfg[level + 1] or {}
		if Scene.Instance:GetSceneId() == cur_cfg.sceneid then
		
			--打开成功面板
			-- self.cur_tower_level = protocol.togguang_leve

			Scene.Instance:PickAllItemByFly(function(awards) 
				ViewManager.Instance:OpenViewByDef(ViewDef.BabelWin)
				ViewManager.Instance:FlushViewByDef(ViewDef.BabelWin, 0, "reward", {reward = awards})
			end,1)
		end
	end

	RemindManager.Instance:DoRemind(RemindName.TongTianTaSangdang)
	RemindManager.Instance:DoRemind(RemindName.TongTiantaChouJiang)
end


function BabelCtrl:OnBabelRankingListData(protocol)
	self.data:SetBabelRankingListData(protocol)
end


function BabelCtrl:OnSceneLoadingStateEnter(scene_id, scene_type, fuben_id)

	local level = BabelData.Instance:GetTongguangLevel()

	local cfg = BabelTowerFubenConfig and BabelTowerFubenConfig.layerlist or {}
	local cur_cfg = cfg[level + 1] or {}

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
		self.babel_start_time = Status.NowTime
		--self:InitTrialFuBenInfo()

		local delay_time = cur_cfg.boss and cur_cfg.boss.liveTime or 0
		self.timer = GlobalTimerQuest:AddDelayTimer(callback, delay_time)
		self:OnBabelTime(delay_time)
		if ViewManager.Instance:IsOpen(ViewDef.BabelInfo) then
			ViewManager.Instance:FlushViewByDef(ViewDef.BabelInfo)
		end

		--GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true, true)
	else
		-- 退出试炼地图 或 并非进入试炼地图
		self:CancelTimer()

		if ViewManager.Instance:IsOpen(ViewDef.BabelWin) then 
			self.babel_win_view:ClearOther()
			ViewManager.Instance:CloseViewByDef(ViewDef.BabelWin)

		end
	end
end

function BabelCtrl:OnHurtChange(hurt_value)
	if self.timer then
		self.total_hurt = self.total_hurt + hurt_value
	end
end

function BabelCtrl:GetTrialDps()
	local now_time = Status.NowTime
	local start_time = self.babel_start_time or 0
	local total_hurt = self.total_hurt or 0

	return math.floor(total_hurt / (now_time - start_time))
end




function BabelCtrl:OnBabelTime(time)
	local count_down_callback =  function (elapse_time, total_time, view) 
			local num = total_time - math.floor(elapse_time)

			-- if self.trial_fuben_info then
			if ViewManager.Instance:IsOpen(ViewDef.BabelInfo) then
				local daps = self:GetTrialDps()
				ViewManager.Instance:FlushViewByDef(ViewDef.BabelInfo, 0, "miaoshao", {daps = daps})
			end
		end
	self.babel_die = UiInstanceMgr.Instance:AddTimeLeaveView(time, count_down_callback, "vip_boss_tip")
end

function BabelCtrl:CancelTimer()
	if self.babel_die then
		self.babel_die:StopTimeDowner()
		self.babel_die = nil
	end
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	self.babel_start_time = 0
	self.total_hurt = 0
end


function BabelCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.TongTianTaSangdang then
		return self.data:GetCanSweep() and 1 or 0
	elseif remind_name == RemindName.TongTiantaChouJiang then
		return self.data:GetRemianChoujiangNum() > 0 and 1 or 0
	end
end









