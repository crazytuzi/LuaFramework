require('game/puzzle/puzzle_view')
require('game/puzzle/puzzle_data')
require('game/puzzle/puzzle_fast_flip_view')

PuzzleCtrl = PuzzleCtrl or BaseClass(BaseController)

function PuzzleCtrl:__init()
	if nil ~= PuzzleCtrl.Instance then
		print_error("[PuzzleCtrl] attempt to create singleton twice!")
		return
	end
	PuzzleCtrl.Instance = self
	self.data = PuzzleData.New()
	self.view = PuzzleView.New(ViewName.PuzzleView)
	self.fast_flip_view = FastFlipView.New(ViewName.FastFlipView)

	self:RegisterAllProtocols()
end

function PuzzleCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if nil ~= self.fast_flip_view then
		self.fast_flip_view:DeleteMe()
		self.fast_flip_view = nil
	end

	self:CacleDelayTime()
	self:CacleSendDelayTime()

	PuzzleCtrl.Instance = nil
end

-- 注册协议
function PuzzleCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAFanFanAllInfo, "OnFanFanAllInfo")
	self:RegisterProtocol(SCRAFanFanWordExchangeResult, "OnFanFanExchangeInfo")
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.SendReq, self))
end

-- 更新信息协议处理
function PuzzleCtrl:OnFanFanAllInfo(protocol)
	self.data:UpdateInfoData(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.PuzzleView)
end

-- 更新兑换信息协议处理
function PuzzleCtrl:OnFanFanExchangeInfo(protocol)
	self.data:UpdateExchangeData(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.PuzzleView)
end

-- 兑换奖励
function PuzzleCtrl:ExchangeReward(view)
	self:SendReq(RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_WORD_EXCHANGE, view.data.index)
end

-- 保底兑换
function PuzzleCtrl:SendGetBaoDi(index)
	self:SendReq(RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_LEICHOU_EXCHANGE, index)
end

-- 协议请求
function PuzzleCtrl:SendReq(opera_type, param_1, param_2, param_3)
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN) then
		return
	end
	local parm_t = {
		rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN,
		opera_type = opera_type or RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_QUERY_INFO,
		param_1 = param_1,
		param_2 = param_2,
		param_3 = param_3,
	}
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(parm_t.rand_activity_type, parm_t.opera_type, parm_t.param_1, parm_t.param_2, parm_t.param_3)
end

function PuzzleCtrl:OpenFastFlipView()
	if self.fast_flip_view and not self.fast_flip_view:IsOpen() then
		self.fast_flip_view:Open()
	end
end

function PuzzleCtrl:FlushFastFlipButton()
	if self.view and self.view:IsOpen() then
		self.view:FlushFastFlipButtonText()
	end
end

function PuzzleCtrl:OnFastFilpResult(result)
	self:CacleSendDelayTime()
	self:CacleDelayTime()
	self.data:SetFilpState(false)
	if self.view and self.view:IsOpen() then
		if result == 0 then
			self:EndFastFilp()
		else
			local is_cur_word_list = self:IsCurWordlist()
			if is_cur_word_list then
				self:EndFastFilp()
				return
			end

			local gold_enough = self.data:GoldIsEnough()
			if not gold_enough then
				TipsCtrl.Instance:ShowLackDiamondView()
				self:EndFastFilp()
				return 
			end 

			self.delay_time = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.BeginFastFilp, self), 0.25)
		end
	end
end

function PuzzleCtrl:EndFastFilp()
	self.data:SetFastFilpState(false)
	local list = {}
	self.data:SetSelectWordList(list)
	self:FlushFastFlipButton()
end

function PuzzleCtrl:IsCurWordlist()
	local list = self.data:GetSelectWordList()
	local cur_word_seq = self.data:GetCurWrodGroupIndex()
	local result = false
	for k, v in pairs(list) do
		if v == cur_word_seq then
			result = true
			break
		end
	end

	return result
end

function PuzzleCtrl:BeginFastFilp()
	local cur_word_list = self.data:GetSelectWordList()
	local seq = -1
	for k,v in pairs(cur_word_list) do
		seq = v
		break
	end

	local filp_state = self.data:GetFilpState()
	if seq == -1 or filp_state then return end

	if self.view and self.view:IsOpen() then
		self:SendReq(RA_FANFAN_OPERA_TYPE.RA_FANFAN_OPERA_TYPE_REFRESH, 1, seq)
		self:StartSendDelayTime()
		self.view:SetSelectIndex()
		self.data:SetFilpState(true)
		self.data:SetFastFilpState(true)
		self:FlushFastFlipButton()
	end
end

function PuzzleCtrl:CacleDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function PuzzleCtrl:ClearData()
	self.data:SetFilpState(false)
	self:EndFastFilp()
end

function PuzzleCtrl:StartSendDelayTime()
	self:CacleSendDelayTime()
	self.delay_send_time = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.ClearData, self), 2)
end

function PuzzleCtrl:CacleSendDelayTime()
	if self.delay_send_time then
		GlobalTimerQuest:CancelQuest(self.delay_send_time)
		self.delay_send_time = nil
	end
end
