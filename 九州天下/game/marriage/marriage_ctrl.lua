require("game/marriage/equip/marry_equip_ctrl")
require("game/marriage/marriage_data")
require("game/marriage/marriage_view")
-- require("game/marriage/church_view")
require("game/marriage/wedding_view")
require("game/marriage/wedding_by_view")
require("game/marriage/wedding_fuben_view")
require("game/marriage/wedding_enter_view")
require("game/marriage/wedding_pledge_view")
require("game/marriage/wedding_hunshu_view")
require("game/marriage/wedding_yuyue_view")
-- require("game/marriage/wedding_invite_view")
require("game/marriage/wedding_invites_view")
require("game/marriage/wedding_demand_view")
require("game/marriage/qingyuan_fuben_view")
require("game/marriage/couple_halo")
require("game/marriage/monomer_view")
require("game/marriage/wedding_blessing_view")
require("game/marriage/shengdi/shengdi_fuben_view")
require("game/marriage/marry_question_view")

MarriageCtrl = MarriageCtrl or  BaseClass(BaseController)

function MarriageCtrl:__init()
	if MarriageCtrl.Instance ~= nil then
		print_error("[MarriageCtrl] attempt to create singleton twice!")
		return
	end

	MarriageCtrl.Instance = self
	self:RegisterAllProtocols()

	self.marry_equip_ctrl = MarryEquipCtrl.New()

	self.marriage_view = MarriageView.New(ViewName.Marriage)
	-- self.church_view = ChurchView.New(ViewName.Church)
	self.wedding_view = WeddingView.New(ViewName.Wedding)
	self.wedding_by_view = WeddingByView.New()
	self.wedding_fuben_view = WeddingFuBenView.New(ViewName.FuBenHunYanInfoView)
	self.qingyuan_fuben_view = QingYuanFuBenView.New(ViewName.FuBenQingYuanInfoView)
	self.marriage_data = MarriageData.New()
	self.enter_wedding_view = WeddingEnterView.New(ViewName.WeddingEnterView)
	self.wedding_pledge_view = WeddingPledgeView.New(ViewName.WeddingPledgeView)
	self.wedding_hunshu_view = WeddingHunShuView.New(ViewName.WeddingHunShuView)
	self.wedding_yuyue_view = WeddingYuYueView.New(ViewName.WeddingYuYueView)
	self.wedding_demand_view = WeddingDemandView.New(ViewName.WeddingDemandView)
	-- self.wedding_invite_view = WeddingInviteView.New(ViewName.WeddingInviteView)
	self.wedding_invite_view = WeddingInviteView.New(ViewName.WeddingInviteView)
	self.monomer_view = MonomerView.New()
	self.wedding_blessing_view = WeddingBlessingView.New(ViewName.WeddingBlessing)
	self.shengdi_fuben_view = ShengDiFuBenView.New(ViewName.FuBenShengDiInfoView)
	self.question_view = MarryQuestionView.New(ViewName.HuanyanQuestion)

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))

	--监听物品改变
	self.item_bind_listen = BindTool.Bind(self.ItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_bind_listen)
end

function MarriageCtrl:__delete()
	if self.marry_equip_ctrl then
		self.marry_equip_ctrl:DeleteMe()
		self.marry_equip_ctrl = nil
	end
	if self.wedding_blessing_view then
		self.wedding_blessing_view:DeleteMe()
		self.wedding_blessing_view = nil
	end
	if self.marriage_view then
		self.marriage_view:DeleteMe()
		self.marriage_view = nil
	end
	if self.wedding_view then
		self.wedding_view:DeleteMe()
		self.wedding_view = nil
	end
	if self.wedding_by_view then
		self.wedding_by_view:DeleteMe()
		self.wedding_by_view = nil
	end
	if self.wedding_fuben_view then
		self.wedding_fuben_view:DeleteMe()
		self.wedding_fuben_view = nil
	end
	if self.qingyuan_fuben_view then
		self.qingyuan_fuben_view:DeleteMe()
		self.qingyuan_fuben_view = nil
	end
	if self.marriage_data then
		self.marriage_data:DeleteMe()
		self.marriage_data = nil
	end
	if self.enter_wedding_view then
		self.enter_wedding_view:DeleteMe()
		self.enter_wedding_view = nil
	end
	if self.wedding_pledge_view then
		self.wedding_pledge_view:DeleteMe()
		self.wedding_pledge_view = nil
	end
	if self.wedding_invite_view then
		self.wedding_invite_view:DeleteMe()
		self.wedding_invite_view = nil
	end
	if self.wedding_hunshu_view then
		self.wedding_hunshu_view:DeleteMe()
		self.wedding_hunshu_view = nil
	end
	if self.wedding_yuyue_view then
		self.wedding_yuyue_view:DeleteMe()
		self.wedding_yuyue_view = nil
	end
	if self.wedding_demand_view then
		self.wedding_demand_view:DeleteMe()
		self.wedding_demand_view = nil
	end
	if self.shengdi_fuben_view then
		self.shengdi_fuben_view:DeleteMe()
		self.shengdi_fuben_view = nil
	end
	if self.monomer_view then
		self.monomer_view:DeleteMe()
		self.monomer_view = nil
	end
	if self.question_view then
		self.question_view:DeleteMe()
		self.question_view = nil
	end

	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_bind_listen)

	MarriageCtrl.Instance = nil
end

function MarriageCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCMarryReqRoute, "OnMarryReqRoute")
	self:RegisterProtocol(SCDivorceReqRoute, "OnDivorceReqRoute")
	self:RegisterProtocol(SCQingyuanBlessInfo, "SyncBlessInfo")
	self:RegisterProtocol(SCQingyuanEuipmentInfo, "SyncRingInfo")
	self:RegisterProtocol(SCQingyuanLoverInfo, "OnQingyuanLoverInfo")
	self:RegisterProtocol(SCHunyanInfo, "OnWeddingInfo")
	self:RegisterProtocol(SCMarryHunyanOpera, "OnMarryHunyanOpera")
	self:RegisterProtocol(SCQingyuanHunyanInviteInfo, "OnGetWeddingInvite")
	self:RegisterProtocol(SCQingyuanFBInfo, "OnQingYuanFBInfo")
	self:RegisterProtocol(SCQingyuanInfo, "OnQingyuanInfo")
	self:RegisterProtocol(SCQingyuanCoupleHaloInfo, "OnHaloInfo")
	self:RegisterProtocol(SCIsAcceptMarry, "OnAcceptMarry")
	self:RegisterProtocol(SCQingyuanFBRewardRecordInfo, "OnQingyuanFBRewardRecordInfo")
	self:RegisterProtocol(SCHunyanCommonInfo, "OnSCHunyanCommonInfo")			-- 婚宴人气值
	self:RegisterProtocol(SCHunyanGuestBless, "OnSCHunyanGuestBless")
	self:RegisterProtocol(SCMarrySpecialEffect, "OnMarrySpecialEffect")
	self:RegisterProtocol(SCWeddingBlessingRecordInfo, "OnSCWeddingBlessingRecordInfo")	--祝福

	------------------G22的结婚-------------------
	self:RegisterProtocol(SCMarryRetInfo, "OnSCMarryRetInfo")

	-------------预约------------------------
	self:RegisterProtocol(SCQingYuanAllInfo, "OnSCQingYuanAllInfo")					-- 情缘婚礼信息
	self:RegisterProtocol(SCQingYuanWeddingAllInfo, "OnSCQingYuanWeddingAllInfo")	-- 情缘主人看宾客信息
	self:RegisterProtocol(SCHunYanCurWeddingAllInfo, "OnHunYanCurWeddingAllInfo")	-- 当前婚礼信息
	self:RegisterProtocol(SCWeddingApplicantInfo, "OnSCWeddingApplicantInfo")		-- 申请者信息

	self:RegisterProtocol(SCWeddingRoleInfo, "OnSCWeddingRoleInfo")			-- 婚礼玩家个人信息

	-----------------相思树-------------------------
	self:RegisterProtocol(CSLoveTreeWaterReq)
	self:RegisterProtocol(CSLoveTreeInfoReq)
	self:RegisterProtocol(SCLoveTreeInfo, "OnLoveTreeInfo")

	---------------我要脱单-----------------------
	self:RegisterProtocol(CSTuodanREQ)
	self:RegisterProtocol(CSGetAllTuodanInfo)												--请求全部脱单信息
	self:RegisterProtocol(SCAllTuodanInfo, "OnAllTuodanInfo")
	self:RegisterProtocol(SCSingleTuodanInfo, "OnSingleTuodanInfo")

	-------------情缘装备------------------------
	self:RegisterProtocol(CSQingyuanUpQuality)												-- 情缘装备进阶

	-------------爱情契约------------------------
	self:RegisterProtocol(CSQingyuanLoveContractInfoReq)									-- 请求爱情契约的信息
	self:RegisterProtocol(CSQingyuanBuyLoveContract)										-- 爱情契约请求为Ta祝福
	self:RegisterProtocol(CSQingyuanFetchLoveContract)										-- 爱情契约领取奖励
	self:RegisterProtocol(SCQingyuanLoveContractInfo, "OnQingyuanLoveContractInfo")			-- 爱情契约信息

	---------------------情缘圣地------------------
	self:RegisterProtocol(CSQingYuanShengDiOperaReq)										-- 情缘圣地操作请求
	self:RegisterProtocol(SCQingYuanShengDiTaskInfo, "OnQingYuanShengDiTaskInfo")			-- 情缘圣地任务信息
	self:RegisterProtocol(SCQingYuanShengDiBossInfo, "OnQingYuanShengDiBossInfo")

	---------------------h婚姻答题------------------
	self:RegisterProtocol(SCHunyanQuestionUserInfo, "OnHunyanQuestionUserInfo")
	self:RegisterProtocol(SCHunyanQuestionRankInfo, "OnHunyanQuestionRankInfo")
	self:RegisterProtocol(SCHunyanAnswerResult, "OnHunyanAnswerResult")
end

------------------------------------------------------------------------------
function MarriageCtrl:OnSCWeddingBlessingRecordInfo(protocol)
	self.marriage_data:SetWeddingBlessingRecordInfo(protocol)
	if self.wedding_blessing_view:IsOpen() then
		self.wedding_blessing_view:Flush()
	end
end

function MarriageCtrl:OnSCHunyanCommonInfo(protocol)
	self.marriage_data:SetHunyanRenQiValueInfo(protocol)
	if self.wedding_fuben_view:IsOpen() then
		self.wedding_fuben_view:Flush()
	end
end

function MarriageCtrl:OnSCHunyanGuestBless(protocol)
	local is_open_danmu = self.wedding_fuben_view:GetIsOpenDanMu()
	if is_open_danmu then
		local str = ToColorStr(protocol.name, TEXT_COLOR.YELLOW) .. "：" .. protocol.chat_msg
		RollingBarrageCtrl.Instance:OpenView(str or "")
	end
end

function MarriageCtrl:SendQingyuanBuyLoveContract()
	local protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanBuyLoveContract)
	protocol:EncodeAndSend()
end

function MarriageCtrl:SendQingyuanFetchLoveContract(day_num, love_contract_notice)
	local protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanFetchLoveContract)
	protocol.day_num = day_num
	protocol.love_contract_notice = love_contract_notice
	protocol:EncodeAndSend()
end

function MarriageCtrl:SendQingyuanLoveContractInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanLoveContractInfoReq)
	protocol:EncodeAndSend()
end

function MarriageCtrl:OnQingyuanLoveContractInfo(protocol)
	self.marriage_data:SetQingyuanLoveContractInfo(protocol)
	self.marriage_data:ChangeLoveContentRedPoint()
	RemindManager.Instance:Fire(RemindName.MarryLoveContent)
	self.marriage_view:Flush("love_contract")

	if self.marriage_data:GetQingyuanLoveContractReward() then
		MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.LOVE_CONTENT, {true})
	else
		MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.LOVE_CONTENT, {false})
	end

	self.marriage_data:RingRedPoint()
 	RemindManager.Instance:Fire(RemindName.MarryRing)
end

------------------------------------------------------------------------------

function MarriageCtrl:SendQingyuanUpLevel(item_id, slot)
	-- local protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanEquipUpLevel)
	-- protocol.slot = slot
	-- protocol.stuff_id = item_id
	-- protocol:EncodeAndSend()
end

function MarriageCtrl:OnQingyuanEquipInfo(protocol)
	self.marriage_data:SetQingYuanEquipInfo(protocol.slot_info_list)
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("marry_equip")
	end
end

function MarriageCtrl:OnLoveTreeInfo(protocol)
	self.marriage_data:SetLoveTreeInfo(protocol)
	self:UpDataLoverTreeRedPoint()
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("love_tree")
	end
end

--请求相思树信息
function MarriageCtrl:SendLoveTreeInfoReq(is_self)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLoveTreeInfoReq)
	send_protocol.is_self = is_self or 0
	send_protocol:EncodeAndSend()
end

--请求浇水
function MarriageCtrl:SendLoveTreeWaterReq(is_auto_buy, is_water_other)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLoveTreeWaterReq)
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol.is_water_other = is_water_other or 0
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:OnAllTuodanInfo(protocol)
	self.marriage_data:SetAllTuoDanList(protocol)
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("tuodan")
	end
end

function MarriageCtrl:OnSingleTuodanInfo(protocol)
	self.marriage_data:ChangeTuoDanList(protocol)
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("tuodan")
	end
end

function MarriageCtrl:SendTuodanReq(req_type, notice)
	--删除我自己
	if req_type == 1 then
		self.marriage_data:RemoveTuoDanInfoMySelf()
		if self.marriage_view:IsOpen() then
			self.marriage_view:Flush("tuodan")
		end
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTuodanREQ)
	send_protocol.req_type = req_type or 0
	send_protocol.notice = notice or ""
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:GetAllTuodanInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSGetAllTuodanInfo)
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:ShowMonomerView()
	self.monomer_view:Open()
end

--关闭所有与结婚有关的View
function MarriageCtrl:CloseAllView()
	self.marriage_view:Close()
	self.enter_wedding_view:Close()
end

-----------------光环------------------------------
function MarriageCtrl:OnHaloInfo(protocol)
	self.marriage_data:SetEquipCoupleHaloType(protocol.equiped_couple_halo_type)
	self.marriage_data:SetCoupleHaloLevelList(protocol.couple_halo_level_list)
	self.marriage_data:SetCoupleHaloExpList(protocol.couple_halo_exp_list)
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("halo")
	end
	RemindManager.Instance:Fire(RemindName.MarryCoupHalo)
end

function MarriageCtrl:SendUpgradeSpirit(req_type ,halo_type, spirit_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanCoupleHaloOperaReq)
	send_protocol.req_type = req_type
	send_protocol.param_1 = halo_type
	send_protocol.param_2 = spirit_index or 0
	send_protocol.param_3 = 0
	send_protocol:EncodeAndSend()
end

-----------------结婚/离婚------------------------------
--发送结婚请求
function MarriageCtrl:SendMarryReq(marry_type, target_uid)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMarryReq)
	send_protocol.marry_type = marry_type or 0
	send_protocol.target_uid = target_uid or 0
	send_protocol:EncodeAndSend()
	self.marriage_data:SetWeddingTargetInfo(marry_type, target_uid)
end

--接收结婚请求
function MarriageCtrl:OnMarryReqRoute(protocol)
	if self.wedding_by_view:IsOpen() then
		return
	end
	-- self.req_uid = protocol.req_uid
	-- self:ShowMarryOrNotTips(protocol.GameName)
	self.marriage_data:SetReqWeddingInfo(protocol)
	self.wedding_by_view:Open()
end

--发送结婚回复
function MarriageCtrl:SendMarryRet(marry_type, is_accept, req_uid)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMarryRet)
	send_protocol.marry_type = marry_type or 0
	send_protocol.is_accept = is_accept or 0
	send_protocol.req_uid = req_uid
	send_protocol:EncodeAndSend()
end

--发送离婚请求
function MarriageCtrl:SendDivorceReq(is_forced_divorce)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanDivorceReqCS)
	send_protocol.is_forced_divorce = is_forced_divorce
	send_protocol:EncodeAndSend()
end

--接收离婚请求
function MarriageCtrl:OnDivorceReqRoute(protocol)
	self.req_uid = protocol.req_uid
	self:ShowDivorceOrNotTips()
end

--发送离婚回复
function MarriageCtrl:SendDivorceRet(is_accept)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSDivorceRet)
	send_protocol.is_accept = is_accept
	send_protocol.req_uid = self.req_uid
	send_protocol:EncodeAndSend()
end

--返回对方是否同意结婚请求    1:同意, 0:不同意
function MarriageCtrl:OnAcceptMarry(protocol)
	if protocol.accept_flag == 1 then
		if self.wedding_view:IsOpen() then
			self.wedding_view:Close()
		end
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.AgreeMarryDes)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.DisAgreeMarryDes)
	end
end

--情缘副本结算
function MarriageCtrl:OnQingyuanFBRewardRecordInfo(protocol)
	local data = protocol.reward_list
	if protocol.is_finish then
		if protocol.is_pass == 1 then
			ViewManager.Instance:Open(ViewName.FBVictoryFinishView, nil, "finish", {data = data})
		else
			ViewManager.Instance:Open(ViewName.FBFailFinishView, nil, "fail_tip", {tip_str = Language.Marriage.FbFailTip})
		end
	end
end

function MarriageCtrl:UpDataLoverTreeRedPoint()
	--刷新相思树红点
	self.marriage_data:SetLoveTreeRedPoint()
	RemindManager.Instance:Fire(RemindName.MarryLoveTree)
	if self.marriage_view:IsLoaded() then
		self.marriage_view:SetHaloRedPoint()
	end
end

-----------------蜜月------------------------------
--同步祝福信息
function MarriageCtrl:SyncBlessInfo(protocol)
	self.marriage_data:SyncBlessInfo(protocol)
	self.marriage_data:RingRedPoint()
	self.marriage_data:BlessRedPoint()
	self.marriage_data:ChangeLoveContentRedPoint()
	RemindManager.Instance:Fire(RemindName.MarryRing)
	RemindManager.Instance:Fire(RemindName.MarryBless)
	RemindManager.Instance:Fire(RemindName.MarryLoveContent)
	self.marriage_view:BlessChange()
end

--同步戒指信息
function MarriageCtrl:SyncRingInfo(protocol)
	self.marriage_data:SyncRingInfo(protocol)
	self.marriage_data:RingRedPoint()
	RemindManager.Instance:Fire(RemindName.MarryRing)
	self.marriage_view:RingChange()
end

--同步伴侣信息
function MarriageCtrl:OnQingyuanLoverInfo(protocol)
	self.marriage_data:OnQingyuanLoverInfo(protocol)
	self.marriage_data:RingRedPoint()
	RemindManager.Instance:Fire(RemindName.MarryRing)
	self.marriage_view:RingChange()
end

function MarriageCtrl:FlushHoneyMoonView()
	if self.marriage_view:IsLoaded() then
		self.marriage_view:FlushHoneyMoonView()
	end
end

--升级戒指
function MarriageCtrl:SendUpgradeRing(use_num, is_auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanUpLevel)
	send_protocol.stuff_id = self.marriage_data:GetRingUpgradeItem().stuff_id
	send_protocol.repeat_tiems = use_num or 1
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol:EncodeAndSend()
end

--发送领取祝福奖励
function MarriageCtrl:SendGetBlessReward()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanFetchBlessRewardReq)
	send_protocol:EncodeAndSend()
end

--发送购买祝福
function MarriageCtrl:SendBuyBless()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanAddBlessDaysReq)
	send_protocol:EncodeAndSend()
end
-----------------宴会副本--------------------------
--宴会副本信息
function MarriageCtrl:OnWeddingInfo(protocol)
	self.marriage_data:OnWeddingInfo(protocol)
	MainUICtrl.Instance.view:Flush("wedding")
	if self.wedding_fuben_view:IsOpen() then
		self.wedding_fuben_view:Flush()
	end
end

function MarriageCtrl:OnMarryHunyanOpera(protocol)
	if protocol.opera_type == GameEnum.HUNYAN_OPERA_TYPE_SAXIANHUA then					--撒鲜花
		if self.wedding_fuben_view:IsOpen() then
			self.wedding_fuben_view:Flush("sahua")
		end
	end
end

--宴会行动 邀请、撒花、扔花球
function MarriageCtrl:SendMarryOpera(opera_type, opera_param, id, content, opera_param1, opera_param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMarryHunyanOpera)
	send_protocol.opera_type = opera_type or 0
	send_protocol.opera_param = opera_param or 0
	send_protocol.invited_uid = id or 0
	send_protocol.content = content or ""
	send_protocol.opera_param1 = opera_param1 or 0
	send_protocol.opera_param2 = opera_param2 or 0
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:SendMarryBless()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMarryHunyanBless)
	send_protocol:EncodeAndSend()
end

--宴会邀请函改变
function MarriageCtrl:OnGetWeddingInvite(protocol)
	self.marriage_data:SetGetInviteData(protocol)
	if self.enter_wedding_view:IsOpen() then
		self.enter_wedding_view:Flush()
	end

	if next(protocol.invite_list) then
		MainUICtrl.Instance:ChangeMainUiChatIconList(string.lower(ViewName.Marriage), MainUIViewChat.IconList.WEEDING_GET_INVITE, true)
		-- MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.WEEDING_GET_INVITE, {true})
	else
		if self.enter_wedding_view:IsOpen() then
			self.enter_wedding_view:Close()
		end
		MainUICtrl.Instance:ChangeMainUiChatIconList(string.lower(ViewName.Marriage), MainUIViewChat.IconList.WEEDING_GET_INVITE, false)
		-- MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.WEEDING_GET_INVITE, {false})
	end
end

--请求进入结婚宴会
function MarriageCtrl:SendEnterWeeding(fb_key)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSJoinHunyan)
	send_protocol.fb_key = fb_key or 0
	send_protocol:EncodeAndSend()
end

-----------------情缘副本--------------------------
--接受情缘副本信息
function MarriageCtrl:OnQingYuanFBInfo(protocol)
	self.qingyuan_fuben_view:SetData(protocol)
end

--申请情缘副本进入信息
function MarriageCtrl:SendQingYuanFBInfoReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanReqInfo)
	send_protocol:EncodeAndSend()
end

--接受情缘副本进入信息
function MarriageCtrl:OnQingyuanInfo(protocol)
	self.marriage_data:SetQingYuanFBInfo(protocol)
	self.marriage_view:OnFuBenChange()
	RemindManager.Instance:Fire(RemindName.MarryFuBen)
end

--买BUff
function MarriageCtrl:SendBuyFuBenBuff()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingYuanBuyFBBuff)
	send_protocol:EncodeAndSend()
end

--重置副本
function MarriageCtrl:SendRestFuBenTimes()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanBuyJoinTimes)
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:SendReqEquipInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingyuanReqEquipInfo)
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:MainuiOpen()
	self:GetAllTuodanInfo()
	self:SendQingyuanLoveContractInfoReq()
end

function MarriageCtrl:ItemDataChange(item_id, change_item_index, change_reason)
	local is_lover_tree_item = self.marriage_data:IsLoverTreeItemById(item_id)
	if is_lover_tree_item then
		self:UpDataLoverTreeRedPoint()
		if self.marriage_view:IsOpen() then
			self.marriage_view:Flush("love_tree")
		end
	elseif item_id == 27406 then
		self.marriage_data:RingRedPoint()
		RemindManager.Instance:Fire(RemindName.MarryRing)
	end

	--监听情缘装备变化
	-- local param = MarriageData.Instance:GetGuaJiSettingParam()
	-- if param > 10 and change_reason ~= DATALIST_CHANGE_REASON.REMOVE then
	-- 	local marry_equip_data = self.marriage_data:GetEquipCfgById(item_id)
	-- 	if marry_equip_data then
	-- 		local equip_select, select_index = GameMath.SplitNum(param)
	-- 		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	-- 		if item_cfg then
	-- 			if select_index >= item_cfg.color then
	-- 				local can_up_level = self.marriage_data:CanUpLevelByItemId(equip_select, item_id)
	-- 				if can_up_level then
	-- 					--吸收对应设置的装备
	-- 					self:SendQingyuanUpLevel(item_id, equip_select - 1)
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
end

-----------------Tips提示板--------------------------
--是否结婚提示板
function MarriageCtrl:ShowMarryOrNotTips(name)
	local player_name = name
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local gender_str = Language.Marriage.MarryQuestionFeMale
	if main_role_vo.sex == 1 then
		gender_str = Language.Marriage.MarryQuestionMale
	end
	local str = string.format(gender_str, ToColorStr(player_name, TEXT_COLOR.BLUE))
	local yes_func = BindTool.Bind(self.SendMarryRet, self, 1)
	local no_func = BindTool.Bind(self.SendMarryRet, self, 0)
	-- TipsCtrl.Instance:ShowTwoOptionView(str, yes_func, no_func, Language.Common.Willing, Language.Common.UnWilling)
	TipsCtrl.Instance:ShowCommonAutoView("", str, yes_func, no_func, nil, "愿意", "拒绝")
end

--是否离婚提示板
function MarriageCtrl:ShowDivorceOrNotTips()
	local yes_func = BindTool.Bind(self.SendDivorceRet, self, 1)
	local no_func = BindTool.Bind(self.SendDivorceRet, self, 0)
	TipsCtrl.Instance:ShowCommonAutoView("", Language.Marriage.DivorceQuestion, yes_func, no_func, nil, "同意", "拒绝")
end

--是否购买祝福提示板-伴侣有买时
function MarriageCtrl:ShowBuyBlessTips()
	local yes_func = BindTool.Bind(self.SendBuyBless, self)
	local bless_cfg = self.marriage_data:GetBlessCfg()
	local bless_name = ToColorStr(bless_cfg.bless_name, TEXT_COLOR.BLUE)

	local str = ""

	local lover_bless_days = self.marriage_data:GetLoverBlessDays()
	if lover_bless_days ~= nil and lover_bless_days > 0 then
		local self_bless_days = self.marriage_data:GetSelfBlessDays()
		local cost = 1 / 2 * bless_cfg.bless_price_gold / 30 * (math.abs(lover_bless_days - self_bless_days))
		str = string.format(Language.Marriage.BuyBlessLoverHaveBless, bless_name, ToColorStr(cost, TEXT_COLOR.GOLD))
	else
		str = string.format(Language.Marriage.BuyBlessLoverNoBless, ToColorStr(bless_cfg.bless_price_gold, TEXT_COLOR.GOLD), bless_name)
	end

	-- TipsCtrl.Instance:ShowTwoOptionView(str, yes_func, nil, Language.Common.Confirm, Language.Common.Cancel)
	TipsCtrl.Instance:ShowCommonAutoView("", str, yes_func)
end

--合G22结婚流程
--发送结婚操作
function MarriageCtrl:SendWeedingOperate(ope_type, param1)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMarryOperate)
	protocol.ope_type = ope_type or 0
	protocol.param1 = param1 or 0
	protocol:EncodeAndSend()
end

--情缘操作请求
function MarriageCtrl:SendQingYuanOperate(opera_type, param1, param2)
	local protocol = ProtocolPool.Instance:GetProtocol(CSQingYuanOperaReq)
	protocol.opera_type = opera_type or 0
	protocol.param1 = param1 or 0
	protocol.param2 = param2 or 0
	protocol:EncodeAndSend()
end

function MarriageCtrl:OnSCMarryRetInfo(protocol)
	if protocol.ret_type == MARRY_RET_TYPE.MARRY_AGGRE then
		ViewManager.Instance:Open(ViewName.WeddingPledgeView)

	elseif protocol.ret_type == MARRY_RET_TYPE.MARRY_CHOSE_SHICI then
		self.marriage_data:SetWeddingPledgeInfo(protocol.ret_val)
		ViewManager.Instance:CloseAll()
		ViewManager.Instance:Open(ViewName.WeddingHunShuView)

	elseif protocol.ret_type == MARRY_RET_TYPE.MARRY_PRESS_FINGER and protocol.ret_val == MARRY_RET_TYPE.MARRY_PRESS_FINGER then
		self.wedding_hunshu_view:Flush("finish")
	
	elseif protocol.ret_type == MARRY_RET_TYPE.MARRY_CANCEL and ViewManager.Instance:IsOpen(ViewName.WeddingHunShuView) then
		ViewManager.Instance:Close(ViewName.WeddingHunShuView)

	end
end

function MarriageCtrl:OnSCQingYuanAllInfo(protocol)
	if protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_ROLE_INFO then  -- 玩家信息
		self.marriage_data:SetYuYueRoleInfo(protocol)
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_WEDDING_YUYUE_FLAG then
		self.marriage_data:SetYuYueListInfo(protocol)
		if self.wedding_yuyue_view:IsOpen() then
			self.wedding_yuyue_view:Flush("my_yuyue")
			ViewManager.Instance:Open(ViewName.WeddingInviteView)
		end
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_YUYUE_RET then
		self:OpenYuYueTips(protocol.param_ch1)
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_BAITANG_RET then
		local lover_name = GameVoManager.Instance:GetMainRoleVo().lover_name or ""
		if protocol.param_ch1 == 1 then
			TipsCtrl.Instance:ShowCommonTip(nil, nil, string.format(Language.Marriage.BaiTangTip1, lover_name))		
		else
			local ok_fun = function ()
				MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNUAN_OPERA_TYPE_BAITANG_RET, nil, nil, nil, 1)
			end
			local cancel_fun = function ()
				MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNUAN_OPERA_TYPE_BAITANG_RET, nil, nil, nil, 0)
			end
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, string.format(Language.Marriage.BaiTangTip2, lover_name), nil, cancel_fun)
		end
	elseif protocol.info_type == QINGYUAN_INFO_TYPE.QINGYUAN_INFO_TYPE_GET_BLESSING then
		if protocol.param_ch1 == GameEnum.HUNYAN_OPERA_TYPE_YANHUA then
			local role_obj = Scene.Instance:GetRoleByObjId(protocol.param2)
			if role_obj then
				local pos = role_obj:GetFollowUi().root_obj.transform.position
				if protocol.param_ch2 == 0 then
					for i = 1, 10 do
						local random_num_x = GameMath.Rand(-8, 8)
						local random_num_y = GameMath.Rand(-3, 0)
						EffectManager.Instance:PlayAtTransform("effects2/prefab/misc/effect_yanhua_zise_prefab", "effect_yanhua_zise", role_obj:GetFollowUi().root_obj.transform, 10, Vector3(pos.x + random_num_x * 10, pos.y + random_num_y * 10, pos.z), nil, Vector3(30, 30, 30))
					end
				elseif protocol.param_ch2 == 1 then
					for i = 1, 20 do
						local random_num = GameMath.Rand(1, 3)
						local random_num_x = GameMath.Rand(-8, 8)
						local random_num_y = GameMath.Rand(-3, 0)
						if random_num == 1 then
							EffectManager.Instance:PlayAtTransform("effects2/prefab/misc/effect_yanhua_jinse_prefab", "effect_yanhua_jinse", role_obj:GetFollowUi().root_obj.transform, 10, Vector3(pos.x + random_num_x * 10, pos.y + random_num_y * 10, pos.z), nil, Vector3(30, 30, 30))
						elseif random_num == 2 then
							EffectManager.Instance:PlayAtTransform("effects2/prefab/misc/effect_yanhua_lanse_prefab", "effect_yanhua_lanse", role_obj:GetFollowUi().root_obj.transform, 10, Vector3(pos.x + random_num_x * 10, pos.y + random_num_y * 10, pos.z), nil, Vector3(30, 30, 30))
						else
							EffectManager.Instance:PlayAtTransform("effects2/prefab/misc/effect_yanhua_zise_prefab", "effect_yanhua_zise", role_obj:GetFollowUi().root_obj.transform, 10, Vector3(pos.x + random_num_x * 10, pos.y + random_num_y * 10, pos.z), nil, Vector3(30, 30, 30))
						end	
					end
				end
			end
		end
	end
end

function MarriageCtrl:OnSCQingYuanWeddingAllInfo(protocol)
	self.marriage_data:SetInviteGuests(protocol)
	if self.wedding_invite_view:IsOpen() then
		self.wedding_invite_view:Flush()
	end
end

function MarriageCtrl:OnSCWeddingApplicantInfo(protocol)
	self.marriage_data:SetHaveApplicantInfo(protocol)
	if self.wedding_invite_view:IsOpen() then
		self.wedding_invite_view:Flush()
	end
end

function MarriageCtrl:OpenYuYueTips(seq)
	local yuyue_tips_cfg = MarriageData.Instance:GetYuYueTime(seq)

	local time_table = os.date("*t", TimeCtrl.Instance:GetServerTime())
	local begin1, begin2 = math.modf(yuyue_tips_cfg.begin_time / 100)
	local end1, end2 = math.modf(yuyue_tips_cfg.end_time / 100)
	local begin_time = begin1 .. ":" .. begin2 * 100
	local end_time = end1 .. ":" .. end2 * 100
	local time = begin_time .. "0-" .. end_time
	local str = string.format(Language.Marriage.YuYueConf, time)

	local function ok_callback()
		MarriageCtrl.Instance:SendQingYuanOperate(QINGYUAN_OPERA_TYPE.QINGYUAN_OPERA_TYPE_WEDDING_YUYUE_RESULT, seq, 1)
	end

	TipsCtrl.Instance:ShowCommonAutoView("", str, ok_callback, nil, false, Language.Guild.TONGYI, Language.Guild.JUJUE, nil, true, nil, 1)
end

function MarriageCtrl:OnMarrySpecialEffect(protocol)
	local UILayer = GameObject.Find("GameRoot/UILayer").transform
	if protocol.marry_type >= GameEnum.QINGYUAN_TYPE_2 then
		FlowersCtrl.Instance:PlayerEffect2("effects2/prefab/ui/ui_songhuaxinxing_hong_prefab", "UI_songhuaxinxing_hong")
		FlowersCtrl.Instance:PlayerEffect("effects2/prefab/ui/ui_songhua999_prefab", "UI_songhua999")
	else
		FlowersCtrl.Instance:PlayerEffect2("effects2/prefab/ui/ui_songhuaxinxing_hong_prefab", "UI_songhuaxinxing_hong")
	end
end

function MarriageCtrl:OnSCWeddingRoleInfo(protocol)
	self.marriage_data:SetWeddingRoleInfo(protocol)
	if self.wedding_blessing_view:IsOpen() then
		self.wedding_blessing_view:Flush()
	end
	if self.wedding_fuben_view:IsOpen() then
		self.wedding_fuben_view:Flush("role_info")
	end
	if protocol.is_baitang == 1 then
		if not CgManager.Instance:IsCgIng() then
			CgManager.Instance:Play(BaseCg.New("cg/gz_hy01_prefab", "GZ_Hy01_Cg1"), function() end)
		end
	end
end

function MarriageCtrl:OnHunYanCurWeddingAllInfo(protocol)
	self.marriage_data:SetCurWeddingInfo(protocol)
	if self.wedding_fuben_view:IsOpen() then
		self.wedding_fuben_view:Flush("role_info")
	end
end

---------------------------情缘圣地------------------------------
function MarriageCtrl:SendQingYuanShengDiOperaReq(task_type,param)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSQingYuanShengDiOperaReq)
	send_protocol.opera_type = task_type or 0
	send_protocol.param = param or 0
	send_protocol:EncodeAndSend()
end

function MarriageCtrl:OnQingYuanShengDiTaskInfo(protocol)
	self.marriage_data:SetQingYuanShengDiTaskInfo(protocol)
	RemindManager.Instance:Fire(RemindName.MarryShengDi)
	if self.marriage_view:IsOpen() then
		self.marriage_view:Flush("Shendi")
	end
	if self.shengdi_fuben_view:IsOpen() then
		GlobalEventSystem:Fire(OtherEventType.SHENGDI_FUBEN_INFO_CHANGE)
		self.shengdi_fuben_view:Flush("team_type")
	end
end

function MarriageCtrl:OnQingYuanShengDiBossInfo(protocol)
	self.marriage_data:SetQingYuanShengDiBossInfo(protocol)
	if self.shengdi_fuben_view:IsOpen() then
		self.shengdi_fuben_view:Flush()
	end
end

function MarriageCtrl:FlushShengDiRedPoint()
	self.marriage_view:SetShengDiRedPoint()
end

function MarriageCtrl:SetTreeBg(raw_bunble, raw_asset)
	self.marriage_view:SetTreeBg(raw_bunble, raw_asset)
end

function MarriageCtrl:OnHunyanQuestionUserInfo(protocol)
	self.marriage_data:SetHunyanQuestionUserInfo(protocol)
	self.question_view:Flush()

	local user_info = protocol.user_info
	if user_info.cur_question_idx then
		local fake_npc_list = Scene.Instance:GetFakeNpcList()
		for _, v in pairs(fake_npc_list) do
			local npc_vo = v:GetVo()
			if npc_vo.question_id and user_info.cur_question_idx == npc_vo.npc_idx then
				v:ChangeSpecailTitle(5)
			else
				v:ChangeSpecailTitle(-1)
			end
		end
	end
end

function MarriageCtrl:OnHunyanQuestionRankInfo(protocol)
	self.marriage_data:SetHunyanQuestionRankInfo(protocol)
	self.wedding_fuben_view:Flush("answer_rank")
end

function MarriageCtrl:OnHunyanAnswerResult(protocol)
	self.marriage_data:SetHunyanAnswerResult(protocol)
	self.question_view:Flush()
end

function MarriageCtrl:SetQuestionViewData(index)
	self.question_view:Open()
	self.question_view:SetData(index)
end