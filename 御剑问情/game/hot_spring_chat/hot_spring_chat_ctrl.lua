require("game/hot_spring_chat/hot_spring_chat_data")
require("game/hot_spring_chat/hot_info_view")
require("game/hot_spring_chat/question_view")

HotStringChatCtrl = HotStringChatCtrl or BaseClass(BaseController)

function HotStringChatCtrl:__init()
	if HotStringChatCtrl.Instance then
		print_error("[HotStringChatCtrl]:Attempt to create singleton twice!")
	end
	HotStringChatCtrl.Instance = self

	self.data = HotStringChatData.New()
	self.info_view = HotInfoView.New()
	self.question_view = QuestionView.New()

	self:RegisterAllProtocols()
	self:BindGlobalEvent(OtherEventType.GUAJI_TYPE_CHANGE, BindTool.Bind(self.GuajiChange, self))
	self.is_exchange = false
	self.first_uuid = 0
	self.is_follow = false
end

function HotStringChatCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.info_view:DeleteMe()
	self.info_view = nil

	if nil ~= self.question_view then
		self.question_view:DeleteMe()
		self.question_view = nil
	end

	HotStringChatCtrl.Instance = nil
end

function HotStringChatCtrl:GetRankView()
	return self.info_view
end

function HotStringChatCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSHSAddPartnerReq)					-- 添加伙伴请求
	self:RegisterProtocol(CSHSAddPartnerRet)					-- 被添加伙伴对象处理邀请伙伴请求
	self:RegisterProtocol(CSHSDeleteParter)						-- 取消伙伴请求
	self:RegisterProtocol(CSHSUseSkillReq)						-- 玩家请求使用技能

	self:RegisterProtocol(SCHotspringPlayerInfo, "OnSCHotspringPlayerInfo")			-- 温泉里玩家信息
	self:RegisterProtocol(SCHotspringRankInfo, "OnSCHotspringRankInfo")				-- 温泉玩家排名信息
	self:RegisterProtocol(SCHSAddPartnerReqRoute, "OnSCHSAddPartnerReqRoute")		-- 询问被添加伙伴的对象
	self:RegisterProtocol(SCHSSendPartnerInfo, "OnSCHSSendPartnerInfo")				-- 接收伙伴信息
	self:RegisterProtocol(SCHSAddExpInfo, "OnSCHSAddExpInfo")						-- 接收经验信息
	self:RegisterProtocol(SCHSShuangxiuInfo, "OnSCHSShuangxiuInfo")					-- 玩家双修信息
	self:RegisterProtocol(SCHSQAQuestionBroadcast, "OnQuestionInfo")				-- 获取答题内容
	self:RegisterProtocol(SCHSQAnswerResult, "OnQuestionResult")
	self:RegisterProtocol(SCHSQASendFirstPos, "OnFirstPos")
	self:RegisterProtocol(SCHSQARankInfo, "OnQARankInfo")
	self:RegisterProtocol(SCHSNoticeSkillInfo, "OnHSNoticeSkillInfo")				-- 玩家使用技能广播通知
end

function HotStringChatCtrl:OnSCHSShuangxiuInfo(protocol)
	self.data:SetSCHSShuangxiuInfo(protocol)
	local obj1 = Scene.Instance:GetObjectByObjId(protocol.role_1_obj_id)
	if obj1 then
		obj1:SetAttr("special_param", protocol.role_1_partner_obj_id)
	end
	local obj2 = Scene.Instance:GetObjectByObjId(protocol.role_2_obj_id)
	if obj2 then
		obj2:SetAttr("special_param", protocol.role_2_partner_obj_id)
	end
end

function HotStringChatCtrl:OnSCHotspringPlayerInfo(protocol)
	self.data:SetPlayerInfo(protocol)
	self.info_view:Flush()
	self.question_view:Flush("role_info")
	self.info_view:Flush("role_info")
	ViewManager.Instance:FlushView(ViewName.FbIconView, "question")
end

function HotStringChatCtrl:OnSCHotspringRankInfo(protocol)
	self.data:SetRankList(protocol)
	self.info_view:Flush()
end

function HotStringChatCtrl:OnSCHSAddPartnerReqRoute(protocol)

end

function HotStringChatCtrl:OnSCHSSendPartnerInfo(protocol)
	self.data:SetpartnerId(protocol)
	if protocol.partner_id ~= 0 then
		GlobalEventSystem:Fire(OtherEventType.REPAIR_STATE_CHANGE, true)
	else
		GlobalEventSystem:Fire(OtherEventType.REPAIR_STATE_CHANGE, false)
	end
	GuajiCtrl.Instance:StopGuaji()
end

function HotStringChatCtrl:OnSCHSAddExpInfo(protocol)
	self.data:SetJingYan(protocol)
	self.info_view:Flush("jing_yan")
end

function HotStringChatCtrl:AddPartner(obj_id, is_yi_jian)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHSAddPartnerReq)
	protocol.obj_id = obj_id or 0
	protocol.is_yi_jian = is_yi_jian or 1
	protocol:EncodeAndSend()
end

function HotStringChatCtrl:SendPartnerHandle(param_t)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHSAddPartnerRet)
	protocol.req_opera_id = param_t.req_opera_id or 0
	protocol.req_server_id = param_t.req_server_id or 0
	protocol.req_gamename = param_t.req_gamename or ""
	protocol.is_accept = param_t.is_accept or 0
	protocol.reserved = param_t.reserved or 0
	protocol.req_sex = param_t.req_sex or 0
	protocol.req_prof = param_t.req_prof or 0
	protocol:EncodeAndSend()
end

function HotStringChatCtrl:DelPartnerReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSHSDeleteParter)
	protocol:EncodeAndSend()
end

function HotStringChatCtrl:ShowRankView()
	self.info_view:Open()
end

function HotStringChatCtrl:CloseRankView()
	self.info_view:CloseWindow()
end

function HotStringChatCtrl:ShowGiftView()

end

function HotStringChatCtrl:AddTextToInput(text)

end

function HotStringChatCtrl:CloseQuestionView()
	self.question_view:Close()
end

-- 获得题目信息
function HotStringChatCtrl:OnQuestionInfo(protocol)
	if protocol.curr_question_id <= 0 then
		self.data:SetQuestionStartTime(protocol.next_question_start_time)
	else
		if protocol.is_exchange == 0 then
			self.is_exchange = true
			local str = protocol.curr_answer0_desc_str
			protocol.curr_answer0_desc_str = protocol.curr_answer1_desc_str
			protocol.curr_answer1_desc_str = str
		else
			self.is_exchange = false
		end
		self.data:SetQuestionInfo(protocol)
		self.question_view:Open()
		self.question_view:Flush("question")
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic then
			if scene_logic:GetSceneType() == SceneType.HotSpring then
				scene_logic:ClearPos()
			end
		end
		self.info_view:Flush("question")
	end
	ViewManager.Instance:FlushView(ViewName.FbIconView, "question")
end

function HotStringChatCtrl:SendAnswerQuestionReq(is_use_item, choose)
	self.last_choose = choose
	local protocol = ProtocolPool.Instance:GetProtocol(CSHSQAAnswerReq)
	protocol.is_use_item = is_use_item or 0
	if self.is_exchange then
		if choose == 0 then
			choose = 1
		elseif choose == 1 then
			choose = 0
		end
	end
	protocol.choose = choose
	protocol:EncodeAndSend()
end

-- 获得玩家答题结果
function HotStringChatCtrl:OnQuestionResult(protocol)
	if self.is_exchange then
		if protocol.right_result == 0 then
			protocol.right_result = 1
		else
			protocol.right_result = 0
		end
	end
	self.question_view:Flush("result", {result = protocol.result, right_result = protocol.right_result, last_choose = self.last_choose})
	self.info_view:Flush("question")
end

-- 答题排名信息
function HotStringChatCtrl:OnQARankInfo(protocol)
	self.data:SetRankInfo(protocol)
	if self.is_follow then
		if protocol.rank_list[1] then
			local uuid = protocol.rank_list[1].uuid
			if self.first_uuid ~= uuid then
				self:SendFirstPosReq()
			end
		end
	end
	self.info_view:Flush("rank")
end

--返回题榜首的位置
function HotStringChatCtrl:OnFirstPos(protocol)
	-- 如果第一名是自己
	if protocol.obj_id == Scene.Instance:GetMainRole():GetObjId() then
		SysMsgCtrl.Instance:ErrorRemind(Language.HotString.YouAreFirst)
		self.is_follow = false
		GuajiCtrl.Instance:StopGuaji()
	end
	if self.is_follow then
		self.first_uuid = HotStringChatData.Instance:GetRankInfo().rank_list[1].uuid
		MoveCache.param1 = protocol.obj_id
		MoveCache.end_type = MoveEndType.FollowObj
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Follow)
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(),protocol.pos_x, protocol.pos_y, 3, 1)
	end
end

--请求答题榜首的信息
function HotStringChatCtrl:SendFirstPos()
	self.is_follow = true
	self:SendFirstPosReq()
end

function HotStringChatCtrl:SendFirstPosReq()
	MoveCache.param1 = 65535
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Follow)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHSQAFirstPosReq)
	protocol:EncodeAndSend()
end

function HotStringChatCtrl:GuajiChange(guaji_type)
	if guaji_type == GuajiType.None then
		self.is_follow = false
		self.first_uuid = 0
	end
end

function HotStringChatCtrl:CSHSUseSkillReq(obj_id, skill_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHSUseSkillReq)
	protocol.obj_id = obj_id
	protocol.skill_type = skill_type
	protocol:EncodeAndSend()
end

-- 玩家使用技能广播通知
function HotStringChatCtrl:OnHSNoticeSkillInfo(protocol)
	self.data:SetHSNoticeSkillInfo(protocol)
	local deliverer = Scene.Instance:GetObj(protocol.use_obj_id)
	if nil == deliverer or not deliverer:IsCharacter() then
		return
	end

	local target_obj = Scene.Instance:GetObj(protocol.be_use_obj_id)
	if nil == target_obj then
		return
	end
	-- 因为气泡框之前的设计只能同时显示一个，所以这里特殊处理一下
	FollowUi.BUBBLE_VIS = false
	deliverer:GetFollowUi():ShowBubble()

	if protocol.skill_type == HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_THROW_SNOWBALL then
		FollowUi.BUBBLE_VIS = false
		target_obj:GetFollowUi():ShowBubble()
		deliverer:GetFollowUi():ChangeBubble(Language.HotString.SnowBallBigFace, 3)
		target_obj:GetFollowUi():ChangeBubble(string.format(Language.HotString.SnowBallText, deliverer.vo.name, target_obj.vo.name), 3)
		local target_x, target_y = target_obj:GetLogicPos()
		deliverer:DoAttack(VIRTUAL_SKILL_TYPE.THROW_SNOW_BALL, target_x, target_y, protocol.be_use_obj_id)
	elseif protocol.skill_type == HOTSPRING_SKILL_TYPE.HOTSPRING_SKILL_MASSAGE then
		deliverer:GetFollowUi():ChangeBubble(Language.HotString.MassageBigFace, 3)
		Scene.Instance:CreateBoatByCouple(protocol.use_obj_id, protocol.be_use_obj_id, deliverer, HOTSPRING_ACTION_TYPE.MASSAGE)
	end
end