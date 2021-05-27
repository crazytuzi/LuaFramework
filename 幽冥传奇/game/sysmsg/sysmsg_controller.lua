require("scripts/config/errorcode")

-- 系统消息
SysMsgCtrl = SysMsgCtrl or BaseClass(BaseController)

function SysMsgCtrl:__init()
	if SysMsgCtrl.Instance then
		ErrorLog("[SysMsgCtrl] Attempt to create singleton twice!")
		return
	end
	SysMsgCtrl.Instance = self

	self:registerAllProtocols()

	self.tips_list = {}
	self.label_list = {}
	self.is_main_role_create = false
	self.system_hint = SystemHint.New()
	self.act_timing_news = ActTimingNews.New()
	self.qte_view = QteView.New()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo, self))
end

function SysMsgCtrl:__delete()
	self.system_hint:DeleteMe()
	self.system_hint = nil
	SysMsgCtrl.Instance = nil
	self.act_timing_news:DeleteMe()
	self.act_timing_news = nil
end

function SysMsgCtrl:registerAllProtocols()
	-- self:RegisterProtocol(SCGMCommand, "OnGMCommand")
	-- self:RegisterProtocol(CSGMCommand)
	-- self:RegisterProtocol(SCNoticeNumAck, "OnNoticeNumAck")
	-- self:RegisterProtocol(SCNoticeNumStr, "OnNoticeNumStr")

	-- self:RegisterProtocol(SCQTEInfo, "OnQTEInfo")
	-- self:RegisterProtocol(CSQTEReq)
end

function SysMsgCtrl:OnRecvMainRoleInfo()
	self.is_main_role_create = true
end

--QTE信息
function SysMsgCtrl:OnQTEInfo(protocol)
	if protocol then
		self.qte_view:Open()
		self.qte_view:SetQteData(protocol)
	end
end

function SysMsgCtrl.SendQTEReq(qte_type, qte_result)
	-- if qte_result == 1 then
	-- 	if qte_type == QteType.QTE_TYPE_JILIAN then
	-- 		UiInstanceMgr.Instance:ShowEffectAnim(3006, 1.5)
	-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.JiLianDoubleReward)
	-- 	elseif qte_type == QteType.QTE_TYPE_GUILD_PARTY then
	-- 		UiInstanceMgr.Instance:ShowEffectAnim(3006, 1.5)
	-- 		SysMsgCtrl.Instance:ErrorRemind(Language.Guild.JiuHuiDoubleReward)
	-- 	end
	-- else
	-- 	SysMsgCtrl.Instance:ErrorRemind("Miss")
	-- end
	-- local protocol = ProtocolPool.Instance:GetProtocol(CSQTEReq)
	-- protocol.qte_type = qte_type
	-- protocol.qte_result = qte_result
	-- protocol:EncodeAndSend()
end

function SysMsgCtrl:RegisterErrNumCallback(err_num, callback_func)

end

function SysMsgCtrl:OnSysMsgCommon(protocol)

end

function SysMsgCtrl:OnGMCommand(protocol)
	Log("OnGMCommand type:" .. protocol.type .. "  result:" .. protocol.result)
end

function SysMsgCtrl.SendGmCommand(type, command)
	-- local protocol = ProtocolPool.Instance:GetProtocol(CSGMCommand)
	-- protocol.type = type
	-- protocol.command = command
	-- protocol:EncodeAndSend()
	-- Log("type:" .. type .. "  command:" .. command)
end

function SysMsgCtrl:OnNoticeNumAck(protocol)	
	local item_id = self:GetErrorTipItemId(protocol.result)
	-- print(">>>>>>>>>>>>>",protocol.result, item_id)
	if item_id ~= 0 then
		GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_LECK_ITEM, item_id)
		return
	end

	if protocol.result == FIX_ERROR_CODE.EN_GOLD_NOT_ENOUGH then			 --元宝不足
		-- UiInstanceMgr.Instance:ShowChongZhiView()
		return
	end

	local str = ErrorInfo[protocol.result]
	if nil == str then
		str = tostring(protocol.result)
	end
	Log("-----------系统提示：", str, protocol.result)
	self:ErrorRemind(str)
end

function SysMsgCtrl:OnNoticeNumStr(protocol)
	self:ErrorRemind(protocol.notice_numstr)
	Log("-----------lua系统提示：", protocol.notice_numstr)
end

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
	elseif code == FIX_ERROR_CODE.EN_SHENGWANG_SHENGWANG_NOT_ENOUGH then	--竞技场声望不足
		item_id = COMMON_CONSTS.VIRTUAL_ITEM_SHENGWANG
	end
	return item_id
end

--提升飘字
function SysMsgCtrl:FloatingText(parent, str, x, y)
	self.system_hint:FloatingText(parent, str, x, y)
end

--右下角系统飘字
function SysMsgCtrl:FloatingLabel(str)
	self.system_hint:FloatingLabel(str)
end

--错误提示
function SysMsgCtrl:ErrorRemind(str, force)
	if str == nil or str == "" then
		return
	end

	if not force and not self.is_main_role_create then
		return
	end
	
	self.system_hint:FloatingLayoutText(str)
end

--右上提示
function SysMsgCtrl:FloatingTopRightText(str)
	self.system_hint:FloatingTopRightText(str)
end

--系统中上部滚动字 从右往左移(内容,优先级,类型)
function SysMsgCtrl:RollingEffect(str, priority, msg_type)
	if str == nil or nil == priority then
		return
	end
	self.system_hint:RollingEffect(str, priority, msg_type)
end
--聊天窗口上部滚动字 从右往左移(内容,优先级,类型)
function SysMsgCtrl:AboveChatWindowRollingEffect(str, priority, msg_type)
	if str == nil or nil == priority then
		return
	end
	self.system_hint:AboveChatWindowRollingEffect(str, priority, msg_type)
end

--boss盾开启
function SysMsgCtrl:textEffect(name)
	if name == nil then
		return
	end
	self.system_hint:textEffect(name)
end


function SysMsgCtrl:FloatingCoustom(num, icon, num_path, icon_path)
	self.system_hint:FloatingRichText(num, icon, num_path, icon_path)
end

-- 寻宝所有服广播 (文字, 优先级, 类型)
function SysMsgCtrl:ExploreAllServerBroadcast(str, priority, msg_type)
	if str == nil then
		return
	end
	self.system_hint:ExploreAllServerBroadcast(str, priority, msg_type)
end
