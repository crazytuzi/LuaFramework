require('game.flopGift.RequireFlopGift')
FlopGiftController = FlopGiftController or class("FlopGiftController",BaseController)

function FlopGiftController:ctor()
	FlopGiftController.Instance = self

	self.fg_model = FlopGiftModel:GetInstance()
	self.fg_model_events = {}

	self.global_events = {}

    self:AddEvents()
    
	self:RegisterAllProtocal()

	self.open_lv = Config.db_sysopen["1190@1"].level  --翻牌好礼开启等级

	self.lv_update_event_id = nil --等级刷新监听id

	
end

function FlopGiftController:dctor()
	GlobalEvent:RemoveTabListener(self.global_events)
	self.global_events = {}

	self.fg_model:RemoveTabListener(self.fg_model_events)
	self.fg_model_events = {}

end

function FlopGiftController:GetInstance()
	if not FlopGiftController.Instance then
		FlopGiftController.new()
	end
	return FlopGiftController.Instance
end

function FlopGiftController:GameStart(  )

	local function step(  )
		----logError("GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Low)")
		local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
		if lv > self.open_lv then
			self.request_info_by_enter_game = true  --是否是进入游戏请求的活动信息
			self:RequestInfo()
		end
	end
	
	GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Low)
end

function FlopGiftController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	self.pb_module_name = "pb_1704_flopgift_pb"
	self:RegisterProtocal(proto.FLOPGIFT_INFO, self.HandleInfo)
	self:RegisterProtocal(proto.FLOPGIFT_TURN, self.HandleTurn)
	self:RegisterProtocal(proto.FLOPGIFT_NEXT_ROUND, self.HandleNextRound)
end

function FlopGiftController:AddEvents()
	local function call_back()

		local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
		if lv < self.open_lv then
			--等级不足
			local lv_str = GetLevelShow(self.open_lv)
			local tip = string.format( ConfigLanguage.Daily.DailyShowLimitTwo,lv_str )
			Notify.ShowText(tip)
			return
		end

		local panel = lua_panelMgr:GetPanelOrCreate(FlopGiftPanel)
		panel:Open()
		panel:SetData()
	end
	GlobalEvent:AddListener(FlopGiftEvent.OpenFlopGiftPanel, call_back)

	--等级刷新监听
	local function callback(  )
		----logError("EventName.ChangeLevel")
		--首次开启 显示活动红点 请求活动信息
		local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
		if lv == self.open_lv then
			GlobalEvent:Brocast(MainEvent.ChangeRedDot, "flopGift", true)
			FlopGiftController.GetInstance():RequestInfo()
		end
	end
	self.lv_update_event_id = GlobalEvent:AddListener(EventName.ChangeLevel, callback)
end



--请求信息
function FlopGiftController:RequestInfo(  )
	local pb = self:GetPbObject("m_flopgift_info_tos")
	self:WriteMsg(proto.FLOPGIFT_INFO, pb)

	--logError("FlopGiftController:RequestInfo")
end

--处理信息返回
function FlopGiftController:HandleInfo(  )
	local data = self:ReadMsg("m_flopgift_info_toc")

	local level = data.level --活动处理等级
	local cur_round = data.cur_round
	local flop_round_data = data.flop_round_data --所有轮已抽取到的奖励

	self.fg_model.cur_act_lv = level
	self.fg_model.cur_round = cur_round
	self.fg_model:SetRoundData(flop_round_data)

	--大奖检查
	self.fg_model.is_get_big_reward = self.fg_model:IsGetBigReward()

	if self.request_info_by_enter_game then
		--红点检查
		GlobalEvent:Brocast(MainEvent.ChangeRedDot, "flopGift", self.fg_model:CheckReddot())
		self.request_info_by_enter_game = false
	end


	self.fg_model:Brocast(FlopGiftEvent.HandleInfo)

	--logError("FlopGiftController:HandleInfo,data-" .. Table2String(data))
end

--请求翻牌
function FlopGiftController:RequestTurn(pos)
	local pb = self:GetPbObject("m_flopgift_turn_tos")
	pb.pos = pos  --牌位置

	self:WriteMsg(proto.FLOPGIFT_TURN, pb)

	--logError("FlopGiftController:RequestTurn,pos-"..pos)
end

--处理翻牌返回
function FlopGiftController:HandleTurn(  )
	local data = self:ReadMsg("m_flopgift_turn_toc")
	local flop_data = data.flop_data --翻牌信息

	self.fg_model:UpdateRoundGetData(self.fg_model.cur_round,flop_data)
	self.fg_model:UpdateCardData(flop_data)

	--大奖检查
	self.fg_model.is_get_big_reward = self.fg_model:IsGetBigReward(flop_data.item_id) or self.fg_model.is_get_big_reward

	self.fg_model:Brocast(FlopGiftEvent.HandleTurn,flop_data)

	--logError("FlopGiftController:HandleTurn,data-" .. Table2String(data))
end


--请求刷新轮数
function FlopGiftController:RequestNextRound()
	local pb = self:GetPbObject("m_flopgift_next_round_tos")
	self:WriteMsg(proto.FLOPGIFT_NEXT_ROUND, pb)

	--logError("FlopGiftController:RequestNextRound")
end

--处理刷新轮数返回
function FlopGiftController:HandleNextRound(  )
	local data = self:ReadMsg("m_flopgift_next_round_toc")
	local round = data.round --当前轮数

	self.fg_model.cur_round = round

	--卡牌数据置空
	self.fg_model.card_data = {}
	
	--大奖flag重置掉
	self.fg_model.is_get_big_reward = false

	self.fg_model:Brocast(FlopGiftEvent.HandleNextRound)

	--logError("FlopGiftController:HandleNextRound,data-" .. Table2String(data))
end
