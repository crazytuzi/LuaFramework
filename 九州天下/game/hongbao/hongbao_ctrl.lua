require("game/hongbao/hongbao_data")
require("game/hongbao/hongbao_view")
require("game/hongbao/hongbao_kouling_view")

HongBaoCtrl = HongBaoCtrl or BaseClass(BaseController)

function HongBaoCtrl:__init()
	if HongBaoCtrl.Instance then
		print_error("[HongBaoCtrl]:Attempt to create singleton twice!")
	end
	HongBaoCtrl.Instance = self

	self.view = HongBaoView.New()
	self.data = HongBaoData.New()
	self.hongbao_kouling_view = HongBaoKoulingView.New()
	self:RegisterAllProtocols()
end

function HongBaoCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	if self.hongbao_kouling_view then
		self.hongbao_kouling_view:DeleteMe()
		self.hongbao_kouling_view = nil
	end
	HongBaoCtrl.Instance = nil
end

function HongBaoCtrl:RegisterAllProtocols()
	-- 注册接收到的协议
	self:RegisterProtocol(SCRedPaperDetailInfo, "OnRedPaperDetailInfo")
	self:RegisterProtocol(SCRedPaperFetchResult, "OnRedPaperFetchResult")	--红包结果
	self:RegisterProtocol(SCRedPaperRoleInfo, "OnRedPaperRoleInfo")			--获取当天可发送钻石数
	self:RegisterProtocol(SCGuildBossRedBagInfo, "OnGuildBossRedBagInfo")
	self:RegisterProtocol(SCCommandRedPaperSendInfo, "OnCommandRedPaperSendInfo")

	-- 注册发送的协议
	self:RegisterProtocol(CSRedPaperCreateReq)		--创建红包请求
	self:RegisterProtocol(CSRedPaperFetchReq)		--领取红包请求
	self:RegisterProtocol(CSFetchCommandRedPaper)		--领取红包请求

end

function HongBaoCtrl:OnRedPaperRoleInfo(protocol)
	self.data:SetDailyCanSendGold(1000 - protocol.daily_send_gold)
end

function HongBaoCtrl:OnRedPaperDetailInfo(protocol)
	self.data:SetRedPaperDetailInfo(protocol)
	if protocol.notify_reason == RED_PAPER_NOTIFY_REASON.NOTIFY_REASON_HAS_FETCH then
		if protocol.creater_uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
			self.data:SetRedPaperId(protocol.id)
			if protocol.type == RED_PAPER_TYPE.RED_PAPER_TYPE_GLOBAL then --全服红包
				MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.SERVER_HONGBAO, {protocol.id, protocol.type})
			elseif protocol.type == 4 then
				local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
				if protocol.creater_uid ~= role_id then
					self.data:AddKoulingRedPaper(protocol)
				end
				if protocol.notify_reason == 1 then
					if protocol.creater_uid ~= role_id then
						MainUICtrl.Instance.view:Flush("kouling_hongbao")
						if MainUIViewChat and MainUIViewChat.Instance then
							MainUIViewChat.Instance:FlushHongBaoNumValue()
						end
					else
						SysMsgCtrl.Instance:ErrorRemind(Language.RedEnvelopes.Distribute)
					end
				else
					if self.hongbao_kouling_view:IsOpen() then
						self.hongbao_kouling_view:Flush("detail")
					end
				end
			else
				MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.HONGBAO, {protocol.id, protocol.type})
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.RedEnvelopes.Distribute)
		end
	else
		if self.view:IsOpen() then
			self.view:Flush()
		end
	end
	if protocol.log_list then
		local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		if protocol.creater_uid ~= role_id then
			self.data:AddKoulingRedPaper(protocol)
		end
		if self.hongbao_kouling_view:IsOpen() then
			self.hongbao_kouling_view:Flush("detail")
		end
	end
end

function HongBaoCtrl:RecHongBao(id)
	self:SendRedPaperFetchReq(id)
end

function HongBaoCtrl:OnRedPaperFetchResult(protocol)
	if protocol.notify_reason == RED_PAPER_NOTIFY_REASON.NOTIFY_REASON_FAIL or protocol.notify_reason == RED_PAPER_NOTIFY_REASON.NOTIFY_REASON_NO_FETCH_TIMES or protocol.notify_reason == RED_PAPER_NOTIFY_REASON.NOTIFY_REASON_FETCH_SUCC then
		--红包失效了
		local hongbao_type = self.data:RemoveOneHongbao(protocol.red_paper_id)
		if hongbao_type then
			if hongbao_type == RED_PAPER_TYPE.RED_PAPER_TYPE_GLOBAL then
				MainUIViewChat.Instance:FlushServerHongBaoNumValue()
			elseif hongbao_type == 4 then
				if self.hongbao_kouling_view:IsOpen() then
					self.hongbao_kouling_view:Flush("detail")
					HongBaoData.Instance:RemoveKoulingRedPaper(protocol.red_paper_id)
					--MainUIViewChat.Instance:CloseKoulingHongbao()
					MainUIViewChat.Instance:FlushHongBaoNumValue()
				end
			end
			local str = ""
			if protocol.notify_reason == RED_PAPER_NOTIFY_REASON.NOTIFY_REASON_FAIL then
				str = Language.RedEnvelopes.HongBaoIsFail
			elseif protocol.notify_reason == RED_PAPER_NOTIFY_REASON.NOTIFY_REASON_FETCH_SUCC then
				str = Language.RedEnvelopes.GrabSucc
			else
				str = Language.RedEnvelopes.HandSlow
			end
			SysMsgCtrl.Instance:ErrorRemind(str)
		end
		return
	end

	self.data:SetRedPaperFetchResult(protocol)
	self:ShowHongBaoView(GameEnum.HONGBAO_GET, protocol.type, protocol.red_paper_id)
	self:SendRedPaperQueryDetailReq(protocol.red_paper_id)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

-- 查询红包详细信息请求
function HongBaoCtrl:SendRedPaperQueryDetailReq(red_paper_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRedPaperQueryDetailReq)
	protocol.red_paper_id = red_paper_id
	protocol:EncodeAndSend()
end

-- 创建红包请求
function HongBaoCtrl:SendRedPaperCreateReq(type, gold_num, can_fetch_times, currency_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRedPaperCreateReq)
	protocol.type = type
	protocol.currency_type = currency_type or 1
	protocol.gold_num = gold_num
	protocol.can_fetch_times = can_fetch_times
	protocol:EncodeAndSend()
end

-- 领取红包请求
function HongBaoCtrl:SendRedPaperFetchReq(red_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRedPaperFetchReq)
	protocol.red_paper_id = red_id
	protocol:EncodeAndSend()
end

-- 领取口令红包请求
function HongBaoCtrl:SendFetchCommandRedPaper(red_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFetchCommandRedPaper)
	protocol.red_paper_id = red_id
	protocol:EncodeAndSend()
end

-- 查看口令红包信息请求
function HongBaoCtrl:SendCommandRedPaperCheckInfo(red_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCommandRedPaperCheckInfo)
	protocol.red_paper_id = red_id
	protocol:EncodeAndSend()
end


function HongBaoCtrl:ShowHongBaoView(param, types, red_paper_id)
	if not param then
		return
	end
	if GameEnum.HONGBAO_GET == param then
		local hongbao_type = self.data:RemoveOneHongbao(red_paper_id)
		if hongbao_type == nil then
			return
		end
		types = types == 0 and hongbao_type or types
	end
	self.data:SetOpenType(param)
	self.data:SetHongbaoType(types)
	if types == RED_PAPER_TYPE.RED_PAPER_TYPE_GLOBAL then
		MainUIViewChat.Instance:FlushServerHongBaoNumValue()
	else
		MainUIViewChat.Instance:FlushHongBaoNumValue()
	end
	self.view:Open()
end

----------------------------------------------公会Boss红包--------------------------------------------------------

function HongBaoCtrl:OnGuildBossRedBagInfo(protocol)
	local fetch_gold = 0
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	for k,v in pairs(protocol.log_list) do
		if v.uid == main_role_id then
			fetch_gold = v.gold_num
			break
		end
	end
	self.data:SetRedPaperFetchResult({notify_reason = 0, fetch_gold = fetch_gold, creater_name = protocol.creater_name, ["type"] = RED_PAPER_TYPE.RED_PAPER_TYPE_GLOBAL})
	self.data:SetRedPaperDetailInfo(protocol)
	self.data:SetOpenType(GameEnum.HONGBAO_GET)
	self.data:SetHongbaoType(RED_PAPER_TYPE.RED_PAPER_TYPE_RAND)
	self.view:Open()
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

-- 发送红包信息
function HongBaoCtrl:OnCommandRedPaperSendInfo(protocol)
	self.data:SetKoulingRedPaperInfo(protocol)
	self.hongbao_kouling_view:Open()
end

function HongBaoCtrl:CloseKouLingView()
	self.hongbao_kouling_view:Close()
end