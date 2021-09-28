require("game/yule/yule_view")

--捕鱼相关
require("game/yule/fish")
require("game/yule/fishing/bullet")
require("game/yule/fishing/fishing_data")
require("game/yule/fishing/fishpond_list_view")
require("game/yule/fishing/yang_fish_view")
require("game/yule/fishing/besteal_record_view")
require("game/yule/fishing/harvest_record_view")

--走棋子
require("game/yule/go_pawn/go_pawn_data")

YuLeCtrl = YuLeCtrl or BaseClass(BaseController)

function YuLeCtrl:__init()
	if YuLeCtrl.Instance ~= nil then
		print_error("[YuLeCtrl] attempt to create singleton twice!")
		return
	end
	YuLeCtrl.Instance = self

	self.view = YuLeView.New(ViewName.YuLeView)

	--捕鱼相关
	self.fish_data = FishingData.New()
	self.fishpond_list_view = FishPondListView.New(ViewName.FishPondListView)
	self.yang_fish_view = YangFishView.New(ViewName.YangFishView)
	self.besteal_record_view = BeStealRecordView.New(ViewName.BeStealRecordView)
	self.harvest_record_view = HarvestRecordView.New(ViewName.HarvestRecordView)

	self.gopawn_data = GoPawnData.New()

	self:RegisterAllProtocols()

	--计算可收获cd
	self.harvest_fish_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.HarvestFishCD, self), 1)
end

function YuLeCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.fish_data ~= nil then
		self.fish_data:DeleteMe()
		self.fish_data = nil
	end

	if self.gopawn_data ~= nil then
		self.gopawn_data:DeleteMe()
		self.gopawn_data = nil
	end

	if self.fishpond_list_view ~= nil then
		self.fishpond_list_view:DeleteMe()
		self.fishpond_list_view = nil
	end

	if self.yang_fish_view ~= nil then
		self.yang_fish_view:DeleteMe()
		self.yang_fish_view = nil
	end

	if self.besteal_record_view ~= nil then
		self.besteal_record_view:DeleteMe()
		self.besteal_record_view = nil
	end

	if self.harvest_record_view ~= nil then
		self.harvest_record_view:DeleteMe()
		self.harvest_record_view = nil
	end

	if self.harvest_fish_time_quest then
		GlobalTimerQuest:CancelQuest(self.harvest_fish_time_quest)
		self.harvest_fish_time_quest = nil
	end

	YuLeCtrl.Instance = nil
end

function YuLeCtrl:RegisterAllProtocols()
	--捕鱼协议
	self:RegisterProtocol(CSFishPoolQueryReq)											-- 操作请求
	self:RegisterProtocol(CSFishPoolStealFish)											-- 偷鱼请求
	self:RegisterProtocol(CSFishPoolBuyBulletReq)										-- 购买子弹请求
	self:RegisterProtocol(CSFishPoolRaiseReq)											-- 请求放鱼
	self:RegisterProtocol(CSFishPoolHarvest)											-- 收获请求
	self:RegisterProtocol(SCFishPoolAllRaiseInfo, "OnFishPoolAllRaiseInfo")				-- 鱼塘鱼儿信息
	self:RegisterProtocol(SCFishPoolCommonInfo, "OnFishPoolCommonInfo")					-- 普通信息
	self:RegisterProtocol(SCUpFishQualityRet, "OnUpFishQualityRet")						-- 提高鱼的品质结果
	self:RegisterProtocol(SCFishPoolChange, "OnFishPoolChange")							-- 鱼的数量变化
	self:RegisterProtocol(SCFishPoolWorldGeneralInfo, "OnFishPoolWorldGeneralInfo")		-- 随机可偷鱼的玩家列表
	self:RegisterProtocol(SCFishPoolStealGeneralInfo, "OnFishPoolStealGeneralInfo")		-- 偷鱼者信息列表
	self:RegisterProtocol(SCFishPoolShouFishRewardInfo, "OnFishPoolShouFishRewardInfo")	-- 收获奖励

	self:RegisterProtocol(SCMoveChessInfo, "OnMoveChessInfo")
	self:RegisterProtocol(SCMoveChessStepRewardInfo, "OnSCMoveChessStepRewardInfo")
	self:RegisterProtocol(SCMoveChessShakePoint, "OnMoveChessShakePoint")
end

function YuLeCtrl:SendFishPoolQueryReq(query_type)
	-- print_error("SendFishPoolQueryReq", query_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFishPoolQueryReq)
	send_protocol.query_type = query_type or 0
	send_protocol:EncodeAndSend()
end

function YuLeCtrl:SendFishPoolStealFish(target_uid, is_fake_pool, quality, fish_type)
	-- print_error("SendFishPoolStealFish", target_uid, is_fake_pool, quality, fish_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFishPoolStealFish)
	send_protocol.target_uid = target_uid or 0
	send_protocol.is_fake_pool = is_fake_pool or 0
	send_protocol.quality = quality or 0
	send_protocol.fish_type = fish_type or 0
	send_protocol:EncodeAndSend()
end

function YuLeCtrl:SendFishPoolBuyBulletReq()
	-- print_error("SendFishPoolRaiseReq")
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFishPoolBuyBulletReq)
	send_protocol:EncodeAndSend()
end

function YuLeCtrl:SendFishPoolRaiseReq()
	-- print_error("SendFishPoolRaiseReq")
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFishPoolRaiseReq)
	send_protocol:EncodeAndSend()
end

function YuLeCtrl:SendFishPoolHarvest()
	-- print_error("SendFishPoolHarvest")
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFishPoolHarvest)
	send_protocol:EncodeAndSend()
end

--只会发给自己
function YuLeCtrl:OnFishPoolAllRaiseInfo(protocol)
	-- print_error("OnFishPoolAllRaiseInfo", protocol)
	self.fish_data:SetMyFishList(protocol)
	local now_uid = self.fish_data:GetNowFishPondUid()
	if now_uid == GameVoManager.Instance:GetMainRoleVo().role_id then
		--是自己的鱼塘才刷新界面
		if self.view:IsOpen() then
			self.view:Flush("fish")
		end
	end
	RemindManager.Instance:Fire(RemindName.Fishing_CanGet)
end

function YuLeCtrl:OnFishPoolCommonInfo(protocol)
	-- print_error("OnFishPoolCommonInfo", protocol)
	self.fish_data:SetCommonInfo(protocol.normal_info)
	if self.view:IsOpen() then
		self.view:Flush("info")
	end
	RemindManager.Instance:Fire(RemindName.Fishing_CanGet)
	RemindManager.Instance:Fire(RemindName.Fishing_CanSteal)
	RemindManager.Instance:Fire(RemindName.Fishing_BeSteal)
end

function YuLeCtrl:OnUpFishQualityRet(protocol)
	-- print_error("OnUpFishQualityRet", protocol)
	self.fish_data:RefreshFishQuailty(protocol.quality)
	if self.yang_fish_view:IsOpen() then
		self.yang_fish_view:Flush()
	end
end

function YuLeCtrl:OnFishPoolChange(protocol)
	-- print_error("OnFishPoolChange", protocol)
	local now_uid = self.fish_data:GetNowFishPondUid()
	if now_uid == protocol.uid then
		self.fish_data:FishPoolChange(protocol)
		if self.view:IsOpen() then
			if protocol.is_steal_succ == STEAL_TYPE.REFRESH then
				--需要刷新该鱼池的数据
				self.view:Flush("enter_other", {false})
			else
				self.view:Flush("fish_num_change", {protocol.is_steal_succ == STEAL_TYPE.SUCC and true or false})
			end
		end
	end
end

function YuLeCtrl:OnFishPoolWorldGeneralInfo(protocol)
	-- print_error("OnFishPoolWorldGeneralInfo", protocol)
	-- for _, v in ipairs(protocol.general_list) do
	-- 	print_error(v)
	-- end
	self.fish_data:SetWorldGeneralInfo(protocol.general_list)
	if not self.fishpond_list_view:IsOpen() then
		self.fishpond_list_view:Open()
	else
		self.fishpond_list_view:Flush()
	end
end

function YuLeCtrl:OnFishPoolStealGeneralInfo(protocol)
	-- print_error("OnFishPoolStealGeneralInfo", protocol)
	self.fish_data:SetStealGeneralInfo(protocol.general_list)
	if self.besteal_record_view:IsOpen() then
		self.besteal_record_view:Flush()
	else
		self.fish_data:SetIsCheckBeSteal(false)
	end
	RemindManager.Instance:Fire(RemindName.Fishing_BeSteal)
end

function YuLeCtrl:OnFishPoolShouFishRewardInfo(protocol)
	-- print_error("OnFishPoolShouFishRewardInfo", protocol)
	self.fish_data:SetShouFishRewardInfo(protocol)
	self.view:Flush("fish_reward")
	-- self.harvest_record_view:Open()
end

--返回走棋子信息
function YuLeCtrl:OnMoveChessInfo(protocol)
	self.gopawn_data:OnMoveChessInfo(protocol)
	local go_pawn_view = GoPawnContentView.Instance

	if go_pawn_view ~= nil then
		if go_pawn_view:GetInitState() then
			go_pawn_view:InitCrapsPos(protocol.move_chess_cur_step)
		end
		go_pawn_view:CheckBtnState()
		go_pawn_view:FlushRemainText(protocol.move_chess_free_times)
		go_pawn_view:FlushRedPoint()
	end
	RemindManager.Instance:Fire(RemindName.HuanJing_XunBao)
end

-- 返回摇骰得到的物品
function YuLeCtrl:OnSCMoveChessStepRewardInfo(protocol)
 	self.gopawn_data:SetStepReward(protocol)
end
 
--摇骰子摇到点数
function YuLeCtrl:OnMoveChessShakePoint(protocol)
	self.gopawn_data:OnSaveShakePoint(protocol)
	local go_pawn_view = GoPawnContentView.Instance
	if go_pawn_view ~= nil then
		if protocol.shake_point ~= 0 then
            --转动骰子
			go_pawn_view:CalTurnCrapsTime()
			
		end
 	end
end

--请求重置骰子
function YuLeCtrl:SendMoveChessResetReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMoveChessResetReq)
	send_protocol:EncodeAndSend()
end

--请求获取走棋子信息
function YuLeCtrl:SendMoveChessFreeInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMoveChessFreeInfo)
	-- send_protocol.is_reqinfo = is_reqinfo  --传1就返回0，否则返回服务器记录的数据
	send_protocol:EncodeAndSend()
end

--请求摇骰子
function YuLeCtrl:SendMoveChessShakeReq(is_use_item, reserve)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMoveChessShakeReq)
	send_protocol.is_use_item = is_use_item    --1使用物品，0不使用
	send_protocol.reserve = reserve
	send_protocol:EncodeAndSend()

end

function YuLeCtrl:HarvestFishCD()
	local fish_list = self.fish_data:GetMyFishList()
	if nil == fish_list then
		return
	end

	if RemindManager.Instance:GetRemind(RemindName.Fishing_CanGet) > 0 then
		return
	end

	local fish_info = self.fish_data:GetFishInfoByQuality(fish_list.fish_quality)
	if nil == fish_info then
		return
	end
	local fang_fish_time = fish_list.fang_fish_time
	if fang_fish_time <= 0 then
		--没有放鱼不计算收获红点
		return
	end
	local need_times = fish_info.need_time
	local server_time = TimeCtrl.Instance:GetServerTime()
	if server_time - fang_fish_time > need_times then
		--可收获了
		RemindManager.Instance:Fire(RemindName.Fishing_CanGet)
	end
end