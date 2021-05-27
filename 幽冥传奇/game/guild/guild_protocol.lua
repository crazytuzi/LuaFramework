GuildCtrl = GuildCtrl or BaseClass(BaseController)

function GuildCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCGuildDetailedInfo, "OnGuildDetailedInfo")
	self:RegisterProtocol(SCCreateGuildResult, "OnCreateGuildResult")
	self:RegisterProtocol(SCCurServerGuildList, "OnCurServerGuildList")
	self:RegisterProtocol(SCJoinGuildReqList, "OnJoinGuildReqList")
	self:RegisterProtocol(SCGuildMemberList, "OnGuildMemberList")
	self:RegisterProtocol(SCOpenCallGuildMember, "OnOpenCallGuildMember")
	self:RegisterProtocol(SCQualifiedInvitePlayer, "OnQualifiedInvitePlayer")
	self:RegisterProtocol(SCJoinGuildInvite, "OnJoinGuildInvite")
	self:RegisterProtocol(SCUpdateGuildInfo, "OnUpdateGuildInfo")
	self:RegisterProtocol(SCOnWarGuildList, "OnOnWarGuildList")
	self:RegisterProtocol(SCGuildListUpdate, "OnGuildListUpdate")
	self:RegisterProtocol(SCGuildLeagueReq, "OnGuildLeagueReq")
	self:RegisterProtocol(SCGuildStorageItem, "OnGuildStorageItem")
	self:RegisterProtocol(SCMoveToGuildStorageFromBag, "OnMoveToGuildStorageFromBag")
	self:RegisterProtocol(SCGuildEventList, "OnGuildEventList")
	self:RegisterProtocol(SCGuildDonateVal, "OnGuildDonateVal")
	-- self:RegisterProtocol(SCGuildStorageOptRecord, "OnGuildStorageOptRecord")
	self:RegisterProtocol(SCRobGuildEnvelopeResult, "OnRobGuildEnvelopeResult")
	-- self:RegisterProtocol(SCGuildRedEnvelopeInfo, "OnGuildRedEnvelopeInfo")
	self:RegisterProtocol(SCEditGuildMemberInfo, "OnEditGuildMemberInfo")
	self:RegisterProtocol(SCGuildMemberInfoChange, "OnGuildMemberInfoChange")
	self:RegisterProtocol(SCGuildTitleResult, "OnGuildTitleResult")
	self:RegisterProtocol(SCGuildPositionChange, "OnGuildPositionChange")
	self:RegisterProtocol(SCFeedbackSomebodyReqJoinGuild, "OnFeedbackSomebodyReqJoinGuild")
	self:RegisterProtocol(SCFireSomeMemberResult, "OnFireSomeMemberResult")
	self:RegisterProtocol(SCPlayerHelpReqInfo, "OnPlayerHelpReqInfo")
	self:RegisterProtocol(SCGuildRecInfo, "OnSCGuildRecInfo")
	self:RegisterProtocol(SCSentRedEnvelopeResult, "OnSentRedEnvelopeResult")
	self:RegisterProtocol(SCJoinHandleResult, "OnJoinHandleResult")
	self:RegisterProtocol(SCGuildSuccessResult, "OnGuildSuccessResult")
	self:RegisterProtocol(SCGuildOfferResult, "OnGuildOfferResult")
	self:RegisterProtocol(SCGuildImpeachInfo, "OnGuildImpeachInfo")
	self:RegisterProtocol(SCGuildImpeachVote, "OnGuildImpeachVote")

end

---------------------------------------
-- 下发 begin
---------------------------------------
-- 帮派的详细信息
function GuildCtrl:OnGuildDetailedInfo(protocol)
	self.data:SetGuildInfo(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.GuildRedEnvelope)
end

-- 创建帮派返回
function GuildCtrl:OnCreateGuildResult(protocol)
	GlobalEventSystem:Fire(OtherEventType.GUILD_CREATED)
end

-- 本服内的所有帮派
function GuildCtrl:OnCurServerGuildList(protocol)
	if protocol.cur_page == protocol.total_pages then
		self.data:SetGuildList(protocol)
	end
end

-- 显示用户申请加入的帮派的列表
function GuildCtrl:OnJoinGuildReqList(protocol)
	self.data:SetJoinReqList(protocol.join_req_list)
	self:CheckGuildApplyTip()
end

function GuildCtrl:CheckGuildApplyTip()
	local apply_list = self.data:GetJoinReqList()
	local num = #apply_list
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.GUILD_APPLY, num, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.Guild.GuildView.GuildJoinReqList)
	end)
end

-- 帮派成员列表
function GuildCtrl:OnGuildMemberList(protocol)
	self.data:SetGuildMemberList(protocol.list)
end

-- 返回搜索符合邀请的玩家结果
function GuildCtrl:OnQualifiedInvitePlayer(protocol)
	self.data:SetSearchMemberList(protocol.player_list)
end

-- 通知玩家有人邀请他加入帮派
function GuildCtrl:OnJoinGuildInvite(protocol)
	self.data:AddGuildInvite(protocol)
	self:CheckGuildInviteTip()
end

function GuildCtrl:CheckGuildInviteTip()
	local guild_invite_t = self.data:GetGuildInviteList()
	local num = #guild_invite_t > 0 and 1 or 0
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.GUILD_INVITE, num, function ()
		local data = table.remove(guild_invite_t, 1)
		self.invite_alert = self.invite_alert or Alert.New()
		local content = string.format(Language.Guild.InviteAlert, data.cur_member_num, data.guild_name, data.role_name)
		self.invite_alert:SetLableString(content)
		self.invite_alert:SetOkFunc(function ()
			GuildCtrl.GuildInviteAnswer(1, data.guild_id, data.obj_id)
		end)
		self.invite_alert:SetCancelFunc(function ()
			GuildCtrl.GuildInviteAnswer(0, data.guild_id, data.obj_id)
		end)
		self.invite_alert:SetCloseFunc(function ()
			GuildCtrl.GuildInviteAnswer(0, data.guild_id, data.obj_id)
		end)
		self.invite_alert:SetShowCheckBox(false)
		self.invite_alert:Open()
		self:CheckGuildInviteTip()
	end)
end

-- 发送打开行会集结令的面板
function GuildCtrl:OnOpenCallGuildMember(protocol)
	-- self.data:AddCallGuildMember(protocol)
	self:CheckCallGuildMemberTip(protocol)
end

local guild_member_tip_list = {}
function GuildCtrl:CheckCallGuildMemberTip(data)
	table.insert(guild_member_tip_list, data)
	local call_back = function()
		local data = table.remove(guild_member_tip_list)
		if data then
			self.call_alert = self.call_alert or Alert.New()
			self.call_alert:SetIsAnyClickClose(false)
			local content = string.format(Language.Guild.CallAlert, data.role_name, Language.Guild.CallObject[data.call_type], data.scene_name, data.x .. ":" .. data.y)
			self.call_alert:SetLableString(content)
			self.call_alert:SetOkFunc(function ()
				GuildCtrl.GuildCallAnswer(data.scene_id, data.x, data.y)
				MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.SUMMON, #guild_member_tip_list)
			end)

			self.call_alert:SetCloseBeforeFunc(function ()
				self.call_alert:Close()
				MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.SUMMON, #guild_member_tip_list)
			end)

			self.call_alert:SetShowCheckBox(false)
			self.call_alert:SetAutoCloseTime(60)
			self.call_alert:Open()
		else
			MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.SUMMON, 0)
		end
	end
	
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.SUMMON, #guild_member_tip_list, call_back)
end

-- 更新帮派的信息
function GuildCtrl:OnUpdateGuildInfo()
	GuildCtrl.GetGuildDetailedInfo()
end

-- 下发敌对状态的帮派列表
function GuildCtrl:OnOnWarGuildList(protocol)
	self.data:UpdateGuildList(protocol)
end

-- 通知有更新行会列表
function GuildCtrl:OnGuildListUpdate()
	GuildCtrl.GetGuildList()
end

-- 发送给行会有其他行会请求联盟
function GuildCtrl:OnGuildLeagueReq(protocol)
	self.data:AddGuildLeague(protocol)
	self:CheckGuildLeagueTip()
end

function GuildCtrl:CheckGuildLeagueTip()
	local guild_league_req_t = self.data:GetGuildLeagueList()
	local num = #guild_league_req_t
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.GUILD_LEAGUE, num, function ()
		local data = table.remove(guild_league_req_t, 1)
		self.league_req_alert = self.league_req_alert or Alert.New()
		local content = string.format(Language.Guild.LeagueAlert, data.cur_member_num, data.guild_name, data.role_name)
		self.league_req_alert:SetLableString(content)
		self.league_req_alert:SetOkFunc(function ()
			GuildCtrl.GuildLeaguesAnswer(1, data.guild_id, data.role_id)
		end)
		self.league_req_alert:SetCancelFunc(function ()
			GuildCtrl.GuildLeaguesAnswer(2, data.guild_id, data.role_id)
		end)
		self.league_req_alert:SetCloseFunc(function ()
			GuildCtrl.GuildLeaguesAnswer(2, data.guild_id, data.role_id)
		end)
		self.league_req_alert:SetOkString(Language.Guild.LeagueAlertBtn[1])
		self.league_req_alert:SetCancelString(Language.Guild.LeagueAlertBtn[2])
		self.league_req_alert:SetShowCheckBox(false)
		self.league_req_alert:Open()
		self:CheckGuildLeagueTip()
	end)
end

-- 仓库物品的列表
function GuildCtrl:OnGuildStorageItem(protocol)
	self.data:SetGuildStorageList(protocol.item_list)
end

-- 背包拖动物品到行会仓库 - 操作成功
function GuildCtrl:OnMoveToGuildStorageFromBag()
	GuildCtrl.GetGuildStorageList()
end

-- 下发帮派事件
function GuildCtrl:OnGuildEventList(protocol)
	self.data:SetEventsList(protocol.record_list)
end

function GuildCtrl:OnGuildDonateVal(protocol)
end

-- 下发仓库操作记录
function GuildCtrl:OnGuildStorageOptRecord(protocol)
end

-- 抢帮会红包结果
function GuildCtrl:OnRobGuildEnvelopeResult(protocol)
	RemindManager.Instance:DoRemind(RemindName.GuildRedEnvelope)
	if protocol.result == 1 then
		self.view:Flush(0, "red_envolope_suc")
		GuildCtrl.GetGuildRedEnvelopeInfo()
	end
end

-- 帮会红包信息
function GuildCtrl:OnGuildRedEnvelopeInfo(protocol)
	-- self.data:SetRedEnvelopeInfo(protocol)
	-- self.view:Flush(TabIndex.guild_rob_red_envelope)
end

function GuildCtrl:OnSCGuildRecInfo(protocol)
	self.data:SetGuildHbRecInfo(protocol)
end

-- 下发添加或者删除帮派成员的消息
function GuildCtrl:OnEditGuildMemberInfo(protocol)
	self.data:ChangeGuildMemberList(protocol)
end

-- 广播自己的状态 成员信息改变
function GuildCtrl:OnGuildMemberInfoChange(protocol)
	self.data:FlushGuildMemberInfo(protocol)
end

-- 返回设置封号的结果
function GuildCtrl:OnGuildTitleResult(protocol)
end

-- 行会成员职位改变
function GuildCtrl:OnGuildPositionChange(protocol)
	self.data:FlushGuildMemberPosition(protocol)
end

-- 反馈有人申请加入行会
function GuildCtrl:OnFeedbackSomebodyReqJoinGuild(protocol)
	GuildCtrl.GetJoinGuildReqInfo()
end

--开除成员结果
function GuildCtrl:OnFireSomeMemberResult(protocol)
	if protocol.role_id then
		local g_member_list = self.data:GetGuildMemberList()
		local del_index = nil
		if next(g_member_list) then
			for k,v in pairs(g_member_list) do
				if v.role_id == protocol.role_id then
					del_index = k
					break
				end
			end
		end
		if del_index then
			table.remove(g_member_list, del_index)
			self.view:Flush({TabIndex.guild_member})
		end
	end
end

-- 反馈玩家请求求救的信息
function GuildCtrl:OnPlayerHelpReqInfo(protocol)
end

-- 发帮会红包
function GuildCtrl:OnSentRedEnvelopeResult(protocol)
	self.data:SetGuildHbResult(protocol)
	RemindManager.Instance:DoRemind(RemindName.GuildRedEnvelope)
end

function GuildCtrl:OnJoinHandleResult(protocol)
	self.data:SetJoinHandleResult(protocol.result)
end


function GuildCtrl:OnGuildSuccessResult(protocol)
	ViewManager.Instance:OpenViewByDef(ViewDef.TaskShaChengResultGuide)
	ViewManager.Instance:FlushViewByDef(ViewDef.TaskShaChengResultGuide, 0, "param2", {guild_name = protocol.guild_name, huizhang_name = protocol.guild_huizhang_name, guild_fuhuizhuang_name = protocol.guild_fuhuizhuang_name})
end

function GuildCtrl:OnGuildOfferResult(protocol)
	self.data:SetGuildOfferResult(protocol)

	RemindManager.Instance:DoRemind(RemindName.GuildOfferReward)
end

-- 接收行会弹劾数据(10, 95)
function GuildCtrl:OnGuildImpeachInfo(protocol)
	self.data:SetGuildImpeachInfo(protocol)

	if GuildData.GetGuildImpeachLeftTimes() <= 0 then
		ViewManager.Instance:CloseViewByDef(ViewDef.GuildImpeach)
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.GUILD_APPLY, 0)
	end

	if GuildData.Instance:GetGuildImpeachVote() == 0 and GuildData.GetGuildImpeachLeftTimes() > 0 then
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.GUILD_APPLY, 1, function()
			ViewManager.Instance:OpenViewByDef(ViewDef.GuildImpeach)
			MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.GUILD_APPLY, 0)
		end)
	else
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.GUILD_APPLY, 0)
	end
end

-- 接收玩家投票数据(10, 96)
function GuildCtrl:OnGuildImpeachVote(protocol)
	self.data:SetGuildImpeachVote(protocol)

	-- 主界面小图标
	if GuildData.Instance:GetGuildImpeachVote() == 0 and GuildData.GetGuildImpeachLeftTimes() > 0 then
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.GUILD_APPLY, 1, function()
			ViewManager.Instance:OpenViewByDef(ViewDef.GuildImpeach)
			MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.GUILD_APPLY, 0)
		end)
	else
		MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.GUILD_APPLY, 0)
	end
end

---------------------------------------
-- 下发 end
---------------------------------------

---------------------------------------
-- 请求 begin
---------------------------------------
-- 帮主的审核结果
function GuildCtrl.SentGuildAuditingResult(obj_id, result, role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildAuditingResult)
	protocol.obj_id = obj_id
	protocol.result = result
	protocol.role_id = role_id
	protocol:EncodeAndSend()

	GuildCtrl.GetJoinGuildReqInfo()
end

-- 用户提交加入帮派的申请
function GuildCtrl.SubmitJoinGuildReq(guild_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSubmitJoinGuildReq)
	protocol.guild_id = guild_id or 0
	protocol:EncodeAndSend()
end

-- 请求本帮派的详细信息
function GuildCtrl.GetGuildDetailedInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildDetailedInfoReq)
	protocol:EncodeAndSend()
end

-- 帮派成员列表
function GuildCtrl.GetGuildMemberList()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildMemberList)
	protocol:EncodeAndSend()
end

-- 请求本服内的所有帮派
function GuildCtrl.GetGuildList()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildList)
	protocol:EncodeAndSend()
end

-- 显示用户申请加入的帮派的申请
function GuildCtrl.GetJoinGuildReqInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSJoinGuildReqInfo)
	protocol:EncodeAndSend()
end

-- 创建帮派
function GuildCtrl.CreateGuild(cost_type, guild_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateGuildReq)
	protocol.cost_type = cost_type
	protocol.guild_name = guild_name
	protocol:EncodeAndSend()
end

-- 捐献帮派资金
function GuildCtrl.DonateGuildBankroll(opt_type, donate_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDonateGuildBankroll)
	protocol.opt_type = opt_type or 0
	protocol.donate_num = donate_num or 0
	protocol:EncodeAndSend()
end

-- 召唤帮派成员
function GuildCtrl.CallGuildMember(call_type, obj_id, role_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCallGuildMember)
	protocol.call_type = call_type
	protocol.obj_id = obj_id
	protocol.role_name = role_name
	protocol:EncodeAndSend()
end

-- 被召唤人的回应，是接受还是拒绝
function GuildCtrl.GuildCallAnswer(scene_id, x, y)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildCallAnswer)
	protocol.scene_id = scene_id
	protocol.x = x
	protocol.y = y
	protocol:EncodeAndSend()
end

-- 搜索符合邀请的玩家
function GuildCtrl.SearchGuildQualifiedPlayer(player_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSearchGuildQualifiedPlayer)
	protocol.player_name = player_name
	protocol:EncodeAndSend()
end

-- 邀请加入帮派
function GuildCtrl.InviteJoinGuildReq(role_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSInviteJoinGuildReq)
	protocol.obj_id = 0
	protocol.role_name = role_name
	protocol:EncodeAndSend()
end

-- 玩家拒绝还是接受加入帮派
function GuildCtrl.GuildInviteAnswer(answer, guild_id, obj_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildInviteAnswer)
	protocol.answer = answer
	protocol.guild_id = guild_id
	protocol.obj_id = obj_id
	protocol:EncodeAndSend()
end

-- 设置帮派公告
function GuildCtrl.SetGuildAffiche(type, content)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetGuildAffiche)
	protocol.type = type				--1设置对内的公告, 2设置对外的公告, 3设置行会群公告
	protocol.content = content
	protocol:EncodeAndSend()
end

-- 行会竞价排名
function GuildCtrl.GuildBidRank()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildBidRank)
	protocol:EncodeAndSend()
end

-- 脱离帮派
function GuildCtrl.LeaveGuild()
	local protocol = ProtocolPool.Instance:GetProtocol(CSLeaveGuild)
	protocol:EncodeAndSend()
end

-- 删除帮派
function GuildCtrl.DeleteGuildReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSDeleteGuildReq)
	protocol:EncodeAndSend()
end

-- 开除成员
function GuildCtrl.GuildExpelMember(role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildExpelMember)
	protocol.role_id = role_id
	protocol:EncodeAndSend()
end

-- 升/降职
function GuildCtrl.GuildPositionChange(role_id, position)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildPositionChange)
	protocol.role_id = role_id
	protocol.position = position
	protocol:EncodeAndSend()
end

-- 帮主让位
function GuildCtrl.GuildLeaderYield(role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildLeaderYield)
	protocol.role_id = role_id
	protocol:EncodeAndSend()
end

-- 宣战
function GuildCtrl.GuildDeclarationWar(guild_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildDeclarationWar)
	protocol.guild_id = guild_id
	protocol:EncodeAndSend()
end

-- 设置行会之间的关系
function GuildCtrl.SetGuildRelationship(relationship, guild_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetGuildRelationship)
	protocol.relationship = relationship
	protocol.guild_id = guild_id
	protocol:EncodeAndSend()
end

-- 同意或者拒绝行会同盟
function GuildCtrl.GuildLeaguesAnswer(answer, guild_id, leader_role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildLeaguesAnswer)
	protocol.answer = answer or 2
	protocol.guild_id = guild_id
	protocol.leader_role_id = leader_role_id
	protocol:EncodeAndSend()
end

-- 背包拖动物品到行会仓库
function GuildCtrl.MoveToGuildStorageFromBag(item_guid)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMoveToGuildStorageFromBag)
	protocol.item_guid = item_guid
	protocol:EncodeAndSend()
end

-- 从仓库拖动物品到背包
function GuildCtrl.MoveToBagFromGuildStorage(item_guid)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMoveToBagFromGuildStorage)
	protocol.item_guid = item_guid
	protocol:EncodeAndSend()
end

-- -- 删除仓库物品
-- function GuildCtrl.DelGuildStorageItem(item_guid)
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSDelGuildStorageItem)
-- 	protocol.item_guid = item_guid
-- 	protocol:EncodeAndSend()
-- end

-- 获取仓库物品的列表
function GuildCtrl.GetGuildStorageList()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildStorageList)
	protocol:EncodeAndSend()
end

-- 请求帮派事件
function GuildCtrl.GetGuildEvents()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildEvents)
	protocol:EncodeAndSend()
end

-- 获取仓库操作记录
function GuildCtrl.GetGuildStorageRecord()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildStorageRecord)
	protocol:EncodeAndSend()
end

-- 发红包
function GuildCtrl.SentRedEnvelope(gold_num, num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSentRedEnvelope)
	protocol.gold_num = gold_num
	protocol.num = num
	protocol:EncodeAndSend()
end

-- 抢红包
function GuildCtrl.RobRedEnvelope()
	local protocol = ProtocolPool.Instance:GetProtocol(CSRobRedEnvelope)
	protocol:EncodeAndSend()
end

-- 获取行会红包信息
function GuildCtrl.GetGuildRedEnvelopeInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetGuildRedEnvelopeInfo)
	protocol:EncodeAndSend()
end


-- 发送求救的信息
function GuildCtrl.SentHelpReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSSentHelpReq)
	protocol:EncodeAndSend()
end

function GuildCtrl.SendJoinHandleResultChange(result)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetJoinHandle)
	protocol.handle = result
 	protocol:EncodeAndSend()
end

-- 批量删除仓库物品
function GuildCtrl.SendOnKeyDestroyStorageEq(item_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOnKeyDestroyStorageEq)
	protocol.item_list = item_list or {}
	protocol:EncodeAndSend()
end

-- 行会悬赏
function GuildCtrl.SendGuildOfferReq(type, task_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildOfferReq)
	protocol.offer_type = type
	protocol.task_id = task_id
 	protocol:EncodeAndSend()
end

-- 请求行会弹劾(10, 108)
function GuildCtrl.SendGuildImpeachReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildImpeachReq)
 	protocol:EncodeAndSend()
end

-- 请求弹劾抽票(10, 109) index = 1赞同, 2反对
function GuildCtrl.SendGuildImpeachVoteReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGuildImpeachVoteReq)
	protocol.index = index
 	protocol:EncodeAndSend()
end

---------------------------------------
-- 请求 end
---------------------------------------