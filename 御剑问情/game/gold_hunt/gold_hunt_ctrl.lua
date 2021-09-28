require("game/gold_hunt/gold_hunt_data")
require("game/gold_hunt/gold_hunt_quick_flush_view")
require("game/gold_hunt/gold_hunt_view")

local AUTO_SPEED = 0.1
GoldHuntCtrl = GoldHuntCtrl or BaseClass(BaseController)
function GoldHuntCtrl:__init()
	if GoldHuntCtrl.Instance then
		print_error("[GoldHuntCtrl] Attemp to create a singleton twice !")
	end
	GoldHuntCtrl.Instance = self
	self.data = GoldHuntData.New()
	self.view = GoldHuntView.New(ViewName.GoldHuntView)
	self.rush_view = HuntQuickView.New(ViewName.HuntQuickView)
	self:RegisterAllProtocols()
	self.main_view_complete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MianUIOpenComlete, self))
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.GOLDHUNT)
end

function GoldHuntCtrl:__delete()
	self.data:DeleteMe()
	self.view:DeleteMe()
	self:CancelQuest()

	GoldHuntCtrl.Instance = nil
	if self.main_view_complete then
    	GlobalEventSystem:UnBind(self.main_view_complete)
        self.main_view_complete = nil
    end

	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.auto_quest then
		GlobalTimerQuest:CancelQuest(self.auto_quest)
		self.auto_quest = nil
	end
end

function GoldHuntCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAMineAllInfo, "OnSCRAMineAllInfo")
end

function GoldHuntCtrl:CancelQuest()
    if self.quest_time then
    	GlobalTimerQuest:CancelQuest(self.quest_time)
    	self.quest_time = nil
    end
end

function GoldHuntCtrl:OnSCRAMineAllInfo(protocol)
	self.data:OnSCRAMineAllInfo(protocol)
	self.view:Flush()
	TipsCtrl.Instance:FlushGoldHuntExchangeView()
	RemindManager.Instance:Fire(RemindName.GOLDHUNT)
	self:CancelQuest()
	if self.auto_quest then
		local select_info = self.data:GetSelect()
		for k,v in pairs(protocol.mine_cur_type_list) do
			if not next(select_info) or select_info[v - 10]then
				self:Restore()
				return
			end
		end
		self:BeginRush()
	end
end

function GoldHuntCtrl:Restore()
    self.view.show_quick_btn:SetValue(true)
    self:AutoQuestSW(false)
end

function GoldHuntCtrl:GetAuto()
    return self.auto_quest
end

function GoldHuntCtrl:BeginRush()
   	local player_had_gold = GameVoManager.Instance:GetMainRoleVo().gold
    if player_had_gold < GoldHuntData.Instance:GetFlushPrice() then
    	self:Restore()
    	TipsCtrl.Instance:ShowLackDiamondView()
    	return
    end
	local cur_list = GoldHuntData.Instance:GetHuntInfo().mine_cur_type_list
	local cur_select = self.data:GetSelect()
	if not cur_list or not next(cur_select) then
		return
	end
	for k,v in pairs(cur_list) do
		if cur_select[v - 10] then -- 服务器说要减10后才是真正的猎场类型
			return
		end
	end
    self.view.show_quick_btn:SetValue(false)
	self:AutoQuestSW(true)
end

function GoldHuntCtrl:AutoQuestSW(state)
	if not state then
		GlobalTimerQuest:CancelQuest(self.auto_quest)
		self.auto_quest = nil
		return
	end
	if self.auto_quest then
		return
	end
	self.auto_quest = GlobalTimerQuest:AddRunQuest(function()
		self:SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_REFRESH)
	end, AUTO_SPEED)
end

--[[
	param_1的传值:
	opera_type==1 //是否使用元宝 1是,0否
	opera_type==2 //矿石的索引
	opera_type==3 //奖励索引
	opera_type==4 //兑换索引
--]]
function GoldHuntCtrl:SendRandActivityOperaReq(rand_activity_type, opera_type, param_1, param_2)
	if opera_type == GOLD_HUNT_OPERA_TYPE.OPERA_REFRESH then
		if self.quest_time then
			return
		end
		if self.auto_quest then
			self.quest_time = GlobalTimerQuest:AddDelayTimer(function()
				self:Restore()
				self:CancelQuest()
			end, 2)
		end
	elseif self.auto_quest then
		self:Restore()
		self:CancelQuest()
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	protocol.rand_activity_type = rand_activity_type or 0 --趣味挖矿编号为2111
	protocol.opera_type = opera_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol:EncodeAndSend()
end

function GoldHuntCtrl:MianUIOpenComlete()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_MINE)
	if is_open then
		self:SendRandActivityOperaReq(GoldHuntData.GOLD_HUNT_ID, GOLD_HUNT_OPERA_TYPE.OPERA_TYPE_QUERY_INFO)
	end
end

function GoldHuntCtrl:RemindChangeCallBack(remind_name, num)
	if remind_name == RemindName.GOLDHUNT then
		ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_MINE, num > 0)
	end
end