require("scripts/game/society/society_view")
require("scripts/game/society/society_data")
-- require("scripts/game/society/society_friend_view")
-- require("scripts/game/society/society_enemy_view")
-- require("scripts/game/society/society_blacklist_view")
-- require("scripts/game/society/society_apply_list_view")
-- require("scripts/game/society/society_search_add_view")

require("scripts/game/society/trace_dlg_view")

-- 社交
SocietyCtrl = SocietyCtrl or BaseClass(BaseController)

function SocietyCtrl:__init()
	if SocietyCtrl.Instance then
		ErrorLog("[SocietyCtrl] attempt to create singleton twice!")
		return
	end
	SocietyCtrl.Instance =self

	self.data = SocietyData.New()
	self.view = SocietyView.New(ViewDef.Society)
	self.trace_dlg_view = TraceDlgView.New()

	self:RegisterAllProtocals()
end

function SocietyCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if nil ~= self.trace_dlg_view then
		self.trace_dlg_view:DeleteMe()
		self.trace_dlg_view = nil
	end

	SocietyCtrl.Instance = nil
end

function SocietyCtrl:OpenTraceDlgView(data)
	self.trace_dlg_view:SetViewData(data)
end

function SocietyCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCGetRelationshipList, "OnGetRelationshipList")
	self:RegisterProtocol(SCIssueUpdateRelationList, "OnIssueUpdateRelationList")
	self:RegisterProtocol(SCGetSearchResult, "OnGetSearchResult")	
	self:RegisterProtocol(SCAddSomeOneWaitAgree, "OnAddSomeOneWaitAgree")	
	self:RegisterProtocol(SCAddOrDelNeedInfo, "OnAddOrDelNeedInfo")	
	self:RegisterProtocol(SCGetTraceInfo, "OnGetTraceInfo")
	self:RegisterProtocol(SCSendEnemyList, "OnSendEnemyList")
	self:RegisterProtocol(SCHandleEnemyResult, "OnHandleEnemyResult")
	self:RegisterProtocol(SCCurrentMood, "OnCurrentMood")
	self:RegisterProtocol(SCRequestMarry, "OnRequestMarry")

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.AskGetRelationshipList))
end

-- 返回关系列表 总表
function SocietyCtrl:OnGetRelationshipList(protocol)
	self.data:UpdateRelationshipList(protocol)
end

--下发需要更新的关系列表 可能是增加，也可能是更新
function SocietyCtrl:OnIssueUpdateRelationList(protocol)
	self.data:UpdateRelationshipList(protocol)
end

--接收添加好友需要对方同意(41, 1)
function SocietyCtrl:OnAddSomeOneWaitAgree(protocol)
	self.data:SetApplyListData(protocol)
	if SettingData.Instance:GetOneSysSetting(SETTING_TYPE.FRIEND_REQUEST) then
		self:ReplyOppsiteAddAsk(SOCIETY_IS_AGREE_FRIEND.NO, SOCIETY_RELATION_TYPE.FRIEND, protocol.self_id)
		return
	end
	self:CheckFriendApplyTip()
end

--接收添加或删除时需要的信息(41 2)
function SocietyCtrl:OnAddOrDelNeedInfo(protocol)
	self.data:AddOrDelSomeOneData(protocol)
	self:CheckFriendApplyTip()
end

--返回追踪的信息(41 5)
function SocietyCtrl:OnGetTraceInfo(protocol)
	self.data:SetTraceInfoData(protocol)
end

--返回心情(41 7)
function SocietyCtrl:OnCurrentMood(protocol)
	
end

--接收仇人列表(41 16)
function SocietyCtrl:OnSendEnemyList(protocol)
	self.data:SetEnemyListData(protocol)
end

--返回处理仇人结果(41 17)
function SocietyCtrl:OnHandleEnemyResult(protocol)
	if protocol.op_type == SOCIETY_ENEMY_DEAL_TYPE.DEL then		--删除仇人

	end
end

--返回搜索结果(41 18)
function SocietyCtrl:OnGetSearchResult(protocol)
	self.data:SetSearchResultData(protocol)
end


--请求搜索某人(返回 41 18)
function SocietyCtrl.SearchSomeOneByName(search_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSearchSomeOne)
	protocol.search_name = search_name
	protocol:EncodeAndSend()
end

--请求获取关系列表(返回 第一次返回41 3, 第二次后41 8)
function SocietyCtrl.AskGetRelationshipList()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetRelationshipList)
	protocol:EncodeAndSend()
end

--请求添加或删除等(返回41 2)
function SocietyCtrl:AskAddOrDeleteSomeBody(opt_type, relate_column, role_id, role_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSAddOrDelSomeOne)
	protocol.opt_type = opt_type or SOCIETY_OPERATE_TYPE.ADD
	protocol.relate_column = relate_column
	protocol.role_id = role_id
	protocol.role_name = role_name
	protocol:EncodeAndSend()
	self.data:DelSearchResultData(role_id)
end

--是否同意添加请求(返回 41 2)
function SocietyCtrl:ReplyOppsiteAddAsk(answer_result, relate_column, opposite_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSIsAgreeAdd)
	protocol.answer_result = answer_result or SOCIETY_IS_AGREE_FRIEND.NO
	protocol.relate_column = relate_column
	protocol.opposite_id = opposite_id
	protocol:EncodeAndSend()
end

--请求追踪玩家((返回 41 5))
function SocietyCtrl.TraceOtherPlayerReq(beTraced_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTracePlayer)
	protocol.beTraced_name = beTraced_name
	protocol:EncodeAndSend()
end

--获取追踪的信息(返回 41 5)
function SocietyCtrl.GetTraceInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetTraceInfo)
	protocol:EncodeAndSend()
end

--获取仇人列表(返回 41 16)
function SocietyCtrl.GetEnemyListReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetEnemyList)
	protocol:EncodeAndSend()
end

--请求仇人处理(返回 41 17)
function SocietyCtrl.HandleEnemyReq(op_type, kill_time)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRequestHandleEnemy)
	protocol.op_type = op_type or SOCIETY_ENEMY_DEAL_TYPE.CHECK
	protocol.kill_time = kill_time
	protocol:EncodeAndSend()
end

--请求设置心情(返回41 7)
function SocietyCtrl.SetMoodReq(mood_content)
	local protocol = ProtocolPool.Instance:GetProtocol(CSExpressMood)
	protocol.mood_content = mood_content
	protocol:EncodeAndSend() 
end

function SocietyCtrl:CheckFriendApplyTip()
	local apply_list = self.data:GetApplyListData()
	local num = #apply_list
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.SOCIETY, num, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.Society.ApplyList)
		-- self.view:Open(TabIndex.society_apply_list)
	end)
end


-- 是否同意结婚
function SocietyCtrl.SendReplyMarry(reply_result, role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReplyMarry)
	protocol.reply_result = reply_result
	protocol.role_id = role_id
	protocol:EncodeAndSend()

	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.REQUEST_MARRY, 0)
end

-- 下发请求结婚
function SocietyCtrl:OnRequestMarry(protocol)
	self.data:SetRequestMarry(protocol)

	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.REQUEST_MARRY, 1, function()
		self:CreateMarryTips()
	end)
end

function SocietyCtrl:CreateMarryTips()
	local marry_data = self.data.request_marry_list
	if not marry_data or not marry_data.role_id or not marry_data.role_name then return end

	self.marry_alert = self.marry_alert or Alert.New()
	self.marry_alert:SetLableString(string.format(Language.Society.MarryTip, marry_data.role_name))
	self.marry_alert:SetOkFunc(BindTool.Bind(self.SendReplyMarry, 1, marry_data.role_id))
	self.marry_alert:SetCancelFunc(BindTool.Bind(self.SendReplyMarry, 0, marry_data.role_id))
	self.marry_alert:Open()
end