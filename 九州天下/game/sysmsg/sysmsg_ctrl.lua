
-- 系统消息
SysMsgCtrl = SysMsgCtrl or BaseClass(BaseController)

-- 滚动公告类型AND截断 滚动公告优先级0是最先播放 9999999就是最后播放的意思
GUNDONGYOUXIAN = {
	ACTIVITY_TYPE = 0,				-- 活动公告
	SYSTEM_TYPE = 1000,				-- 系统公告
	HEARSAY_TYPE = 2000,			-- 传闻公告
	CFG_TYPE = 3000,				-- 配置公告

	TRUNCATION = 5,				-- 截断
}

function SysMsgCtrl:__init()
	if SysMsgCtrl.Instance then
		print_error("[SysMsgCtrl] Attempt to create singleton twice!")
		return
	end
	SysMsgCtrl.Instance = self

	self:registerAllProtocols()
end

function SysMsgCtrl:__delete()
	SysMsgCtrl.Instance = nil
end

function SysMsgCtrl:registerAllProtocols()
	self:RegisterProtocol(SCGMCommand, "OnGMCommand")
	self:RegisterProtocol(SCNoticeNumAck, "OnNoticeNumAck")
	-- self:RegisterProtocol(SCNoticeNumStr, "OnNoticeNumStr")
	self:RegisterProtocol(SCQTEInfo, "OnQTEInfo")
end

function SysMsgCtrl:RegisterErrNumCallback(err_num, callback_func)
end

function SysMsgCtrl:OnGMCommand(protocol)
	print_log("OnGMCommand # type:" .. protocol.type .. "  result:" .. protocol.result)
end

function SysMsgCtrl.SendGmCommand(cmd_type, command)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGMCommand)
	protocol.cmd_type = cmd_type
	protocol.command = command
	protocol:EncodeAndSend()
end

function SysMsgCtrl:OnNoticeNumAck(protocol)
	local item_id = self:GetErrorTipItemId(protocol.result)
	if item_id ~= 0 then
		GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_LECK_ITEM, item_id)
		return
	end
	if protocol.result == FIX_ERROR_CODE.EN_GOLD_NOT_ENOUGH then			 --元宝不足
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	local str = ErrorInfo[protocol.result]
	if nil == str then
		str = tostring(protocol.result)
	end
	self:ErrorRemind(str)
	print_log("-----------系统提示：", str, protocol.result)
end

-- function SysMsgCtrl:OnNoticeNumStr(protocol)
-- 	self:ErrorRemind(protocol.notice_numstr)
-- 	print_log("-----------lua系统提示：", protocol.notice_numstr)
-- end

function SysMsgCtrl:GetErrorTipItemId(code)
	local item_id = 0
	if code == FIX_ERROR_CODE.EN_COIN_NOT_ENOUGH then 			 				--铜币不足
		item_id = COMMON_CONSTS.VIRTUAL_ITEM_COIN
	elseif code == FIX_ERROR_CODE.EN_ROLE_ZHENQI_NOT_ENOUGH then 	 			--仙魂不足
		item_id = COMMON_CONSTS.VIRTUAL_ITEM_XIANHUN
	elseif code == FIX_ERROR_CODE.EN_BIND_GOLD_NOT_ENOUGH then 					--绑定元宝不足
		item_id = COMMON_CONSTS.VIRTUAL_ITEM_BINDGOL
	elseif code == FIX_ERROR_CODE.EN_CONVERTSHOP_BATTLE_FIELD_HONOR_LESS then	--战场荣誉不足
		item_id = COMMON_CONSTS.VIRTUAL_ITEM_HORNOR
	elseif code == FIX_ERROR_CODE.EN_SHENGWANG_SHENGWANG_NOT_ENOUGH then		--竞技场声望不足
		item_id = COMMON_CONSTS.VIRTUAL_ITEM_SHENGWANG
	end
	return item_id
end

--提升飘字
function SysMsgCtrl:FloatingText(parent, str, x, y)
end

--右下角系统飘字
function SysMsgCtrl:FloatingLabel(str)
end

--系统中上部飘字
-- speed:飘字滚动的速度系数
function SysMsgCtrl:ErrorRemind(str, speed, is_special)
	TipsCtrl.Instance:ShowSystemMsg(str, speed, is_special)
end

--系统中上部滚动字 从右往左移(内容,优先级,类型)
function SysMsgCtrl:RollingEffect(str, priority, msg_type)
	--暂时用系统漂字
	TipsCtrl.Instance:ShowSystemNotice(str)
end

--QTE信息
function SysMsgCtrl:OnQTEInfo(protocol)
	if protocol then
		self.qte_view:Open()
		self.qte_view:SetQteData(protocol)
	end
end

function SysMsgCtrl.SendQTEReq(qte_type, qte_result)
	local protocol = ProtocolPool.Instance:GetProtocol(CSQTEReq)
	protocol.qte_type = qte_type
	protocol.qte_result = qte_result
	protocol:EncodeAndSend()
end
