--[[
帮派：控制器
ly
201411月23日11:32:54
]]

_G.UnionController = setmetatable( {}, {__index = IController} );
UnionController.name = "UnionController"
UnionController.noticeList = {}
function UnionController:Create()
	-- 玩家名 榜排名变化
	MsgManager:RegisterCallBack(MsgType.SC_SCENE_PLAYER_NAME_CHANGE,	self, self.OnScenePlayerNameChangeResult) 
	-- 自己帮派信息返回
	MsgManager:RegisterCallBack(MsgType.WC_QueryMyGuildInfo,			self, self.OnMyGuildInfoResult) 
	-- 7038返回帮派列表
	MsgManager:RegisterCallBack(MsgType.WC_GuildList,					self, self.OnGuildListResult)
	-- 7042返回创建帮派
	MsgManager:RegisterCallBack(MsgType.WC_CreateGuildRet,				self, self.OnCreateGuildRetResult)
	-- 7040返回帮派成员列表
	MsgManager:RegisterCallBack(MsgType.WC_QueryMyGuildMems,			self, self.OnMyGuildMemsResult)
	-- 7048返回帮派申请列表
	MsgManager:RegisterCallBack(MsgType.WC_QueryMyGuildApplys,			self, self.OnMyGuildApplysResult)
	-- 7041返回帮派事件
	MsgManager:RegisterCallBack(MsgType.WC_QueryMyGuildEvent,			self, self.OnMyGuildEventsResult)
	-- 7047返回其他帮派信息
	MsgManager:RegisterCallBack(MsgType.WC_QueryOtherGuildInfo,			self, self.OnOtherGuildInfoResult)
	--修改公告
	MsgManager:RegisterCallBack(MsgType.WC_UpdateGuildNotice,			self, self.OnReqEditNoticeResult)
	-- 7049申请加入返回帮派
	MsgManager:RegisterCallBack(MsgType.WC_ApplyGuild,					self, self.OnReqApplyGuildResult)
	-- 7050审核申请返回
	MsgManager:RegisterCallBack(MsgType.WC_VerifyGuildApply,			self, self.OnVerifyGuildApplyResult)
	-- 7055返回改变职位
	MsgManager:RegisterCallBack(MsgType.WC_ChangeGuildPos,				self, self.OnChangeGuildPosResult)
	-- 7056返回踢出帮派成员
	MsgManager:RegisterCallBack(MsgType.WC_KickGuildMem,				self, self.OnKickGuildMemResult)
	-- 7051返回退出帮派
	MsgManager:RegisterCallBack(MsgType.WC_QuitGuild,					self, self.OnQuitGuildResult)
	-- 7052返回解散帮派
	MsgManager:RegisterCallBack(MsgType.WC_DismissGuild,				self, self.OnDismissGuildResult)
	-- 7057返回禅让帮主
	MsgManager:RegisterCallBack(MsgType.WC_ChangeLeader,				self, self.OnChangeLeaderResult)
	-- 7058返回帮派捐献
	MsgManager:RegisterCallBack(MsgType.WC_GuildContribute,				self, self.OnGuildContributeResult)
	-- 7059返回帮派捐献
	MsgManager:RegisterCallBack(MsgType.WC_LevelUpMyGuildSkill,			self, self.OnLevelUpMyGuildSkillResult)
	-- 7054返回开启某组帮派技能
	MsgManager:RegisterCallBack(MsgType.WC_LvUpGuildSkill,				self, self.OnLvUpGuildSkillResult)
	-- 7053返回升级帮派
	MsgManager:RegisterCallBack(MsgType.WC_LvUpGuild,					self, self.OnLvUpGuildResult)
	-- 7043返回更新帮派信息
	MsgManager:RegisterCallBack(MsgType.WC_UpdateGuildInfo,				self, self.OnUpdateGuildInfoResult)
	-- 7046返回帮派邀请
	MsgManager:RegisterCallBack(MsgType.WC_NotifyBeInvitedGuild,		self, self.OnInvite)
	-- 7066返回申请同盟请求
	MsgManager:RegisterCallBack(MsgType.WC_GuildAliance,				self, self.OnDiplomacyAliance)
	-- 7067返回解散帮派同盟
	MsgManager:RegisterCallBack(MsgType.WC_DismissGuildAliance,			self, self.OnDismissAliance)
	-- 7068返回帮派同盟申请列表
	MsgManager:RegisterCallBack(MsgType.WC_QueryGuildAlianceApplys,		self, self.OnAppDipList)
	-- 7069返回帮派同盟信息
	MsgManager:RegisterCallBack(MsgType.WC_QueryAlianceGuildInfo,		self, self.OnGetDiplomacyPlayerList)
	-- 7070审核帮派同盟返回
	MsgManager:RegisterCallBack(MsgType.WC_GuildAlianceVerify,			self, self.OnBackDipVerify)
	-- 7071返回加持属性
	MsgManager:RegisterCallBack(MsgType.WC_BackAidInfo,					self, self.OnBackAidInfo)
	-- 7072返回洗炼属性
	MsgManager:RegisterCallBack(MsgType.WC_BackAidBapInfo,				self, self.OnBackAidBapInfo)
	-- 7073返回加持升级
	MsgManager:RegisterCallBack(MsgType.WC_BackAidUpLevelInfo,			self, self.BackAidUpLevelInfo)
	-- 7074返回帮派自己的信息
	MsgManager:RegisterCallBack(MsgType.WC_UpdateMyGuildMemInfo,		self, self.UpdateMyGuildMemInfo)

	-- 7129返回仓库操作信息
	MsgManager:RegisterCallBack(MsgType.WC_UnionWareInfomation,			self, self.WareHouseOperInfo)
	-- 7130增加仓库物品列表
	MsgManager:RegisterCallBack(MsgType.WC_UnionWareHouseinfo,			self, self.WareHouseAdditem)
	-- 7131删除仓库物品列表
	MsgManager:RegisterCallBack(MsgType.WC_UnionWareremove,				self, self.WareHouseRemoveItem)
	-- 7164帮派仓库上限次数
	MsgManager:RegisterCallBack(MsgType.WC_UnionWareMyNumInfo,			self, self.WareHouseNumInfo)
	
	-- 7139获得帮派祈福信息
	MsgManager:RegisterCallBack(MsgType.WC_GetUnionPray,				self, self.OnGetUnionPrayInfo)
	-- 7140其他玩家祈福增加帮派祈福信息
	MsgManager:RegisterCallBack(MsgType.WC_UnionPrayAdd,				self, self.OnUnionPrayAdd)
	-- 7141帮派祈福结果
	MsgManager:RegisterCallBack(MsgType.WC_UnionPray,					self, self.OnUnionPrayRet)
	-- 7149 帮派申请人数
	MsgManager:RegisterCallBack(MsgType.WC_GuildReplyCountTip,			self, self.OnGuildReplyCountTip)
	MsgManager:RegisterCallBack(MsgType.WC_UpdateGuildMasterName,		self, self.OnUpdateGuildMasterName)
	
	MsgManager:RegisterCallBack(MsgType.WC_GuildActivityNotice,		self, self.OnGuildActivityNotice)
	-- 7223 返回弹劾权限
	MsgManager:RegisterCallBack(MsgType.WC_GuildTanHeQuanXian,		self, self.OnGuildTanHeQuanXian)
	-- 7224 返回弹劾结果
	MsgManager:RegisterCallBack(MsgType.WC_GuildTanHe,		self, self.OnGuildTanHeQuan)
	-- 7225 返回帮派仓库审批列表
	MsgManager:RegisterCallBack(MsgType.WC_GuildQueryCheckList,		self, self.OnGuildQueryCheckList)
	-- 7226 返回帮派审核操作
	MsgManager:RegisterCallBack(MsgType.WC_GuildQueryCheckOper,		self, self.OnGuildQueryCheckOper)
	-- 7227 返回设置自动审核
	MsgManager:RegisterCallBack(MsgType.WC_GuildSetAutoCheck,		self, self.OnGuildSetAutoCheck)
end

function UnionController:OnEnterGame()
	self:ReqWareHouseItemInfo();
end;
----------------------------------------------Request-----------------------------------------------
-- 2039请求自己帮派信息
function UnionController:ReqMyGuildInfo()
	FPrint('2039请求自己帮派信息')
	
	local msg = ReqMyGuildInfo:new();
	MsgManager:Send(msg);
end

-- 2038请求帮派列表
function UnionController:ReqGuildList(page, onlyAgree)
	FPrint('2038请求帮派列表')
	
	local msg = ReqGuildList:new();
	msg.page = page
	msg.onlyAutoAgree = onlyAgree
	
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2051请求申请加入帮派
function UnionController:ReqApplyGuild(guildId, bApply)
	local level = t_consts[15].val3 or 0
	local mainPlayerLevel = MainPlayerModel.humanDetailInfo.eaLevel;
	--解锁等级
	if mainPlayerLevel < level then 
		FloatManager:AddCenter(StrConfig['unionDiGong026']);
		return;
	end
	
	FPrint('2051请求申请加入帮派'..guildId..'/'..bApply)
		
	local msg = ReqApplyGuild:new();
	msg.guildId = guildId
	msg.bApply = bApply
	
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2056请求其他帮派信息
function UnionController:ReqOtherGuildInfo(guildId)
	FPrint('2056请求其他帮派信息'..guildId)
	
	local msg = ReqOtherGuildInfo:new();
	msg.guildId = guildId
	
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2042请求创建帮派
function UnionController:ReqCreateGuild(name, notice)
	FPrint('2042请求创建帮派'..name..notice)
	
	local msg = ReqCreateGuild:new();
	msg.name = name
	msg.notice = notice
	
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2040请求自己帮派成员列表
function UnionController:ReqMyGuildMems()
	FPrint('2040请求自己帮派成员列表')
	
	local msg = ReqMyGuildMems:new();
	MsgManager:Send(msg);
end

-- 2041请求自己帮派事件
function UnionController:ReqMyGuildEvents()
	FPrint('2041请求自己帮派事件')
	
	local msg = ReqMyGuildEvents:new();
	MsgManager:Send(msg);
end

-- 2057请求自己帮派申请列表
function UnionController:ReqMyGuildApplys()
	FPrint('2057请求自己帮派申请列表')
	
	local msg = ReqMyGuildApplys:new();
	MsgManager:Send(msg);
end

-- 2048请求修改公告
function UnionController:ReqChangeGuildNotice(noticeStr)
	FPrint('2048请求修改公告')
	
	local msg = ReqChangeGuildNotice:new();
	msg.notice = noticeStr
	
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2049请求审核申请
-- @param guildApplyList 帮派成员列表
-- @param verify 是否同意0 - 同意，1 - 拒绝
function UnionController:ReqVerifyGuildApply(guildApplyList, verify)
	FPrint('2049请求审核申请')
	
	local msg = ReqVerifyGuildApply:new();
	msg.verify = verify
	msg.GuildApplyList = {}
	for i, v in pairs(guildApplyList) do
		local applyVO = {}
		applyVO.memGid = v
		table.push(msg.GuildApplyList, applyVO)
	end
	
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2047 请求改变职位
function UnionController:ReqChangeGuildPos(memGid, pos)
	FPrint('2047 请求改变职位')
	
	local msg = ReqChangeGuildPos:new();
	msg.memGid = memGid
	msg.pos = pos
	
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2047请求禅让帮主
function UnionController:ReqChangeLeader(memGid)
	FPrint('2047请求禅让帮主')
	
	local msg = ReqChangeLeader:new();
	msg.memGid = memGid
	
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2050踢出帮派成员
function UnionController:ReqKickGuildMem(memGid)
	FPrint('2050踢出帮派成员')
	
	local msg = ReqKickGuildMem:new();
	msg.memGid = memGid
	
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2043解散帮派
function UnionController:ReqQuitGuild()
	FPrint('2043解散帮派')
	
	local msg = ReqQuitGuild:new();
	MsgManager:Send(msg);
end

-- 2044解散帮派
function UnionController:ReqDismissGuild()
	FPrint('2044解散帮派')
	
	local msg = ReqDismissGuild:new();
	MsgManager:Send(msg);
end

-- 2059请求捐献
function UnionController:ReqGuildContribute(itemId, count)
	FPrint('2059请求捐献')
	
	local msg = ReqGuildContribute:new();
	msg.itemId = itemId
	msg.count = count
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2060升级自身帮派技能
function UnionController:ReqLevelUpMyGuildSkill(groupId)
	FPrint('2060升级自身帮派技能')
	
	local msg = ReqLevelUpMyGuildSkill:new();
	msg.groupId = groupId
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2046开启某组帮派技能
function UnionController:ReqLvUpGuildSkill(groupId)
	FPrint('2046开启某组帮派技能')
	
	local msg = ReqLvUpGuildSkill:new();
	msg.groupId = groupId
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2045升级帮派
function UnionController:ReqLvUpGuild()
	FPrint('2045升级帮派')
	
	local msg = ReqLvUpGuild:new();
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2055设置自动申请审核
function UnionController:ReqSetAutoVerify(bAuto, level)
	if bAuto == 1 then
		if UnionModel.MyUnionInfo.autoagree == level then
			return
		end
	else
		if UnionModel.MyUnionInfo.autoagree == 0 then
			return
		end
	end
	
	FPrint('2055设置自动申请审核')
	if bAuto == 1 then
		UnionModel.MyUnionInfo.autoagree = level
	else
		UnionModel.MyUnionInfo.autoagree = 0
	end
	local msg = ReqSetAutoVerify:new();
	msg.bAuto = bAuto
	msg.level = level
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2061查找帮派
function UnionController:ReqSearchGuild(gtype, name)
	FPrint('2061查找帮派')
	
	local msg = ReqSearchGuild:new();
	msg.type = gtype
	msg.name = name
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2052邀请加入帮派
function UnionController:ReqInviteToGuild(guildId, memName)
	FPrint('2052邀请加入帮派')
	
	local msg = ReqInviteToGuild:new();
	msg.guildId = guildId
	msg.memName = memName
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2053同意拒绝邀请加入帮派
function UnionController:ReqInviteToGuildResult(inviterId, result)
	FPrint('2053同意拒绝邀请加入帮派')
	
	local msg = ReqInviteToGuildResult:new();
	msg.inviterId = inviterId
	msg.result = result
	FTrace(msg)
	MsgManager:Send(msg);
end

-- 2064 请求建立同盟
function UnionController:ReqSendDiplomacyGuild(guild)
	local msg = ReqGuildAlianceMsg:new();
	msg.guildId = guild;
	MsgManager:Send(msg);
end

-- 2065 请求解散同盟
function UnionController:ReqSendDissDiplomacy()
	local msg = ReqDismissGuildAlianceMsg:new(); 
	MsgManager:Send(msg);
end

--2066 请求同盟申请列表列表
function UnionController:ReqSendAppDipList()
	local msg = ReqGuildAlianceApplysMsg:new();
	MsgManager:Send(msg);
end

--2067 请求同门帮派的信息
function UnionController:ReqSendDipPlayerList()
	local msg = ReqAlianceGuildInfo:new();
	MsgManager:Send(msg);
end

--2068 发送自己对于别人请求的操作
function UnionController:ReqSendDipVerify(obj)
	local msg = ReqGuildAlianceVerifyMsg:new();
	msg.verify = obj.verify;
	msg.GuildAlianceApplyList = obj.list;
	MsgManager:Send(msg);
end

--2069 请求清除上次洗炼数据或保存本次
function UnionController:ReqClearBapAidInfo(state)
	local msg = ReqClearBapAidInfoMsg:new();
	msg.state = state;
	MsgManager:Send(msg);
end

--2072 请求加持洗炼
function UnionController:ReqUnionBapAid()
	local msg = ReqUnionBapAidMsg:new();
	MsgManager:Send(msg);
end

--2071 请求加持属性
function UnionController:ReqAidInfo()
	local msg = ReqAidInfoMsg:new();
	MsgManager:Send(msg);
end

--2073 请求加持升级
function UnionController:ReqAidUpLevel()
	local msg = ReqAidUpLevelMsg:new();
	MsgManager:Send(msg);
end

--2200 请求帮主召集活动信息
function UnionController:ReqSendGuildActivityNotice(id,param,text)
	local msg = ReqSendGuildActivityNoticeMsg:new();
	msg.id = id
	msg.param = param
	msg.text = text
	MsgManager:Send(msg);
	
	FTrace(msg,'请求帮主召集活动信息')
end

--2223 请求帮派弹劾权限
function UnionController:ReqGuildTanHeQuanXian()
	local msg = ReqGuildTanHeQuanXianMsg:new();
	FTrace(msg, '请求帮派弹劾权限')	
	MsgManager:Send(msg);
end

--2224 请求帮派弹劾
function UnionController:ReqGuildTanHeMsg()
	local msg = ReqGuildTanHeMsg:new();
	FTrace(msg, '请求帮派弹劾')
	MsgManager:Send(msg);
end

--2225 帮派仓库审核列表
function UnionController:ReqGuildQueryCheckList()
	local msg = ReqGuildQueryCheckListMsg:new();
	FTrace(msg, '帮派仓库审核列表')
	MsgManager:Send(msg);
end

--2226 请求帮派审核操作 1-批准，2-拒绝, 3-撤销
function UnionController:ReqGuildQueryCheckOper(operid, oper)
	local msg = ReqGuildQueryCheckOperMsg:new();
	msg.operid = operid
	msg.oper = oper
	FTrace(msg, '请求帮派审核操作')
	MsgManager:Send(msg);
end

--2227 请求设置自动审核
function UnionController:ReqGuildSetAutoCheck(pos)
	local msg = ReqGuildSetAutoCheckMsg:new();
	msg.pos = pos
	FTrace(msg, '请求设置自动审核')
	MsgManager:Send(msg);
end

----------------------------------------------Response-----------------------------------------------
--帮派申请人数
function UnionController:OnGuildReplyCountTip(msg)
	FTrace(msg, '帮派申请人数')
	UnionModel.applyNum = msg.replyNum
	Notifier:sendNotification(NotifyConsts.ReplyGuildNumChanged)
end

-- 8211服务端通知：场景中玩家显示名字变化
function UnionController:OnScenePlayerNameChangeResult(msg)
	FTrace(msg, '8211服务端通知：场景中玩家显示名字变化')
	
	local player = CharController:GetCharByCid(msg.roleID)
	if player then
		if msg.type == 2 then
			player:SetGuildName(msg.name)
			player.guildNameChanged = true
		elseif msg.type == 1 then
			player.playerInfo[enAttrType.eaName] = msg.name
			player.nameChanged = true
		elseif msg.type == 3 then
			player:SetPartnerName(msg.name)
		end
	end
end

-- 7039返回自己帮派信息
function UnionController:OnMyGuildInfoResult(msg)
	FTrace(msg, '7039返回自己帮派信息')
	
	UnionModel:SetMyUnionInfo(msg)
	UnionController:CheckChatGuildNotice();
	UnionDiGongController:ReqUnionDiGongInfo();
end

function UnionController:CheckChatGuildNotice()
	if not MainPlayerController.isEnter then return; end
	if UnionUtils:CheckMyUnion() then
		if not UIChatGuildNotice:IsShow() then
			UIChatGuildNotice:Show();
		end
	else
		UIChatGuildNotice:Hide();
	end
end

-- 7038返回帮派列表
function UnionController:OnGuildListResult(msg)
	FTrace(msg, '7038返回帮派列表')
	
	UnionModel:SetUnionList(msg)
end

-- 7042返回创建帮派
function UnionController:OnCreateGuildRetResult(msg)
	FTrace(msg, '7042返回创建帮派')
	
	if msg.result == 0 then
		FloatManager:AddSysNotice(2005026);--创建帮派成功
		Notifier:sendNotification(NotifyConsts.CreateGuildSucc)
	end
end

-- 7040返回帮派成员列表
function UnionController:OnMyGuildMemsResult(msg)
	FTrace(msg, '7040返回帮派成员列表')
	
	UnionModel:SetUnionMemberList(msg)
	
end

-- 7041返回帮派事件
function UnionController:OnMyGuildEventsResult(msg)
	FTrace(msg, '7041返回帮派事件')
	
	UnionModel:SetUnionMemEventList(msg)
end

-- 7047返回其他帮派信息
function UnionController:OnOtherGuildInfoResult(msg)
	FTrace(msg, '7047返回其他帮派信息')
	Notifier:sendNotification(NotifyConsts.OtherGuildInfoUpdate, {guildInfo=msg})
end

-- 返回修改公告
function UnionController:OnReqEditNoticeResult(msg)
	FTrace(msg, '返回修改公告')
	UnionModel:UpdateUnionNotice(msg.guildNotice)
	FloatManager:AddSysNotice(2005029);--公告更改成功
	
	
end

-- 7048返回帮派申请列表
function UnionController:OnMyGuildApplysResult(msg)
	FTrace(msg, '7048返回帮派申请列表')
	
	UnionModel:SetUnionApplyList(msg)
end

-- 7049返回申请加入帮派
function UnionController:OnReqApplyGuildResult(msg)
	FTrace(msg, '7049返回申请加入帮派')
	
	UnionModel:SetUnionApplyResult(msg)
end

-- 7050返回审核申请
function UnionController:OnVerifyGuildApplyResult(msg)
	FTrace(msg, '7050返回审核申请')
	
	UnionModel:SetUnionVerifyResult(msg)
end

-- 7055返回改变职位
function UnionController:OnChangeGuildPosResult(msg)
	FTrace(msg, '7055返回改变职位')
	if msg.result == 0 then
		UnionModel:SetChangeGuildPos(msg)
	end
end

-- 7056返回踢出帮派成员
function UnionController:OnKickGuildMemResult(msg)
	FTrace(msg, '7056返回踢出帮派成员')
	
	if msg.result == 0 then
		UnionModel:SetKickGuildMem(msg)
		if msg.memGid == MainPlayerController:GetRoleID() then
			self:OnEnterNoGuideState()
		end
	end
end

-- 主玩家进入无队伍状态时，清除地图帮派相关图标
function UnionController:OnEnterNoGuideState()
	MapRelationModel:ClearGangRelation()
end

-- 7052返回解散帮派
function UnionController:OnDismissGuildResult(msg)
	FTrace(msg, '7052解散帮派')
	
	if msg.result == 0 then
		UnionModel:SetDismissGuild()
		self:OnEnterNoGuideState()
	end
end

-- 7051返回退出帮派
function UnionController:OnQuitGuildResult(msg)
	FTrace(msg, '7051返回退出帮派')
	
	if msg.result == 0 then
		UnionModel:SetQuitGuild()
		self:OnEnterNoGuideState()
	end
end

-- 7057返回禅让帮主
function UnionController:OnChangeLeaderResult(msg)
	FTrace(msg, '7057返回禅让帮主')
	
	if msg.result == 0 then UnionModel:SetChangeLeader(msg) end
end

-- 7058返回帮派捐献
function UnionController:OnGuildContributeResult(msg)
	FTrace(msg, '7058返回帮派捐献')
	
	UnionModel:SetGuildContribute(msg)
end

-- 7059返回升级自身帮派技能
function UnionController:OnLevelUpMyGuildSkillResult(msg)
	FTrace(msg, '7059返回升级自身帮派技能')
	
	if msg.result == 0 then 
		UnionModel:SetLevelUpMyGuildSkill(msg) 
		FloatManager:AddSysNotice(2005044);--技能提升成功
	end
end

-- 7054返回开启某组帮派技能
function UnionController:OnLvUpGuildSkillResult(msg)
	FTrace(msg, '7054返回开启某组帮派技能')
	
	if msg.result == 0 then 
		UnionModel:SetLvUpGuildSkill(msg) 
	end
end

-- 7053返回升级帮派
function UnionController:OnLvUpGuildResult(msg)
	FTrace(msg, '7053返回升级帮派')
	
	if msg.result == 0 then 
		-- UnionModel:SetLvUpGuild(msg) 
		FloatManager:AddSysNotice(2005033);--帮派升级成功
	end
end

-- 7043返回更新帮派信息(如升级后)
function UnionController:OnUpdateGuildInfoResult(msg)
	FTrace(msg, '7043返回更新帮派信息')
	
	UnionModel:UpdateGuildInfo(msg) 
end

--7046收到入帮邀请
function UnionController:OnInvite(msg)
	FTrace(msg, '7046收到入帮邀请')

	local inviterId = msg.inviterId; 	--邀请人id
	if SetSystemModel:GetIsUnion() then -- 如果系统设置中设置了禁止他人帮派邀请,直接返回拒绝
		self:ReqInviteToGuildResult(inviterId, UnionConsts.RejectJoinGuild);
		return;
	end
	local name = msg.name; 				--邀请人名称
	local guildName = msg.guildName		--帮派名称
	local vo = {};
	vo.guildName = guildName;
	vo.inviterId = inviterId;
	vo.name = name;
	RemindController:AddRemind(RemindConsts.Type_GuildInvite, vo );
end

--7066返回同盟申请是否成功
function UnionController:OnDiplomacyAliance(msg)
	UnionModel:OnAddDiplomacy(msg)
end

--7067返回解散同盟是否成功
function UnionController:OnDismissAliance(msg)
	UnionModel:OnRemoveDiplomacy(msg)
end

--7068 返回申请的列表
function UnionController:OnAppDipList(msg)
	local list = msg.GuildAlianceApplysList;
	UnionModel:OnGetAppDipList(list);
end

--7069收到同盟帮派成员的信息
function UnionController:OnGetDiplomacyPlayerList(msg)
	UnionModel:OnGetDipPlayerList(msg);
end

--7070 返回提交决定后的结果
function UnionController:OnBackDipVerify(msg)
	local list = msg.GuildAlianceApplyList;
	UnionModel:OnClearAppList(list);   
end

--7071返回加持属性
function UnionController:OnBackAidInfo(msg)
	UnionModel:OnModelBackAidInfo(msg);
end

--7072返回洗炼属性
function UnionController:OnBackAidBapInfo(msg)
	UnionModel:OnUpDateAidInfo(msg);
end

--7073返回加持升级
function UnionController:BackAidUpLevelInfo(msg)
	UnionModel:onBackAidUpLevelInfo(msg);
end

function UnionController:UpdateMyGuildMemInfo(msg)
	UnionModel:UpdateMyGuildMemInfo(msg)
end

---------帮派仓库

----------------------s to c
-- 仓库操作
function UnionController:WareHouseOperInfo(msg)
	if msg.type == 1 then --updata 
		UnionModel:SetUnionInfomation(msg.infolist,true) 
	elseif msg.type == 2 then --alldata
		UnionModel:SetUnionInfomation(msg.infolist) 
	end;
	
end;
-- 仓库增加item
function UnionController:WareHouseAdditem(msg)
	--新卓越属性，特殊处理
	for pa,pq in ipairs(msg.items) do 
	    for p,vo in  ipairs(pq.newSuperList) do 
	        if vo.id > 0  and vo.wash == 0 then 
	            local cfg = t_zhuoyueshuxing[vo.id];
	            vo.wash = cfg and cfg.val or 0;
	        end;    
	    end;
	end;
    --

	if msg.type == 1 then 
		UnionModel:OnWareHouseItemList(msg.items)
	end;
	if msg.type == 2 then 
		UnionModel:OnWareHouseAddItem(msg.items)
	end;
end;

-- 仓库次数限制
function UnionController:WareHouseNumInfo(msg)
	UnionModel:SetUnionInfoDo(msg.maxIn)
end
-- 仓库移除item
function UnionController:WareHouseRemoveItem(msg)
	UnionModel:OnWareHouseRemoveItem(msg.items)
end;

------------------c to s 
-- 请求仓库操作协议
function UnionController:ReqWareHouseOperInfo()
	local msg = ReqUnionWareInfomationMsg:new()
	MsgManager:Send(msg)

end;
-- 请求仓库物品列表
function UnionController:ReqWareHouseItemInfo()
	local msg = ReqUnionWareHouseinfoMsg:new()
	MsgManager:Send(msg)
end;
--请求熔炼
function UnionController:ReqWareHouseSmeliting(list)
	local msg = ReqUnionWareHouseSmelitingMsg:new()
	msg.infolist = list;
	MsgManager:Send(msg)
end;
-- 请求取出仓库物品
function UnionController:ReqWareHouseTakeItem(id,num)
	local msg = ReqUnionWareHouseTakeMsg:new()
	msg.uid = id;
	msg.num = num or 0;
	MsgManager:Send(msg)
end;
-- 请求存入仓库物品
function UnionController:ReqWareHouseSaveItem(id,num)
	local msg = ReqUnionWareHouseSaveMsg:new()
	msg.uid = id;
	msg.num = num;
	MsgManager:Send(msg)
end;


----------------------------帮派祈福--------------------------
--获得帮派祈福信息
function UnionController:OnGetUnionPrayInfo(msg)
	-- print('==============获得帮派祈福信息')
	-- trace(msg)
	
	UnionModel:SetIsPray1(msg.isPray1);
	UnionModel:SetIsPray2(msg.isPray2);
	UnionModel:SetIsPray3(msg.isPray3);
	local list = {};
	for i,vo in ipairs(msg.praylist) do
		table.push(list,vo);
	end
	table.sort(list,function(A,B)
		if A.time > B.time then
			return true;
		else
			return false;
		end
	end);
	UnionModel:SetPrayList(list);
end;
-- 其他玩家祈福增加帮派祈福信息
function UnionController:OnUnionPrayAdd(msg)
	-- print('==============其他玩家祈福增加帮派祈福信息')
	-- trace(msg)
	
	local list = UnionModel:GetPrayList();
	local vo = {};
	vo.time = msg.time;
	vo.roleName = msg.roleName;
	vo.prayid = msg.prayid;
	table.push(list,vo);
	table.sort(list,function(A,B)
		if A.time > B.time then
			return true;
		else
			return false;
		end
	end);
	
	--只保存5个
	if #list > UnionConsts.PrayListCount then
		for i=#list,1,-1 do
			table.remove(list,i);
			
			if #list <= UnionConsts.PrayListCount then
				break;
			end
		end
	end
	
	UnionModel:SetPrayList(list);
	
	local huoyuedu = UnionUtils:GetAddPrayLiveness(msg.prayid);
	UnionModel:UpdateMyGuildPrayInfo(huoyuedu);
end;
-- 帮派祈福结果
function UnionController:OnUnionPrayRet(msg)
	-- print('==============帮派祈福结果')
	-- trace(msg)
	
	if msg.result == 0 then
		if msg.prayid == 1 then
			UnionModel:SetIsPray1(1);
		elseif msg.prayid == 2 then
			UnionModel:SetIsPray2(1);
		elseif msg.prayid == 3 then
			UnionModel:SetIsPray3(1);
		end
	end
end;
-- 请求获得帮派祈福信息
function UnionController:ReqGetUnionPray()
	local msg = ReqGetUnionPrayMsg:new()
	MsgManager:Send(msg)
	
	-- print('==============请求获得帮派祈福信息')
	-- trace(msg)
end;
-- 请求帮派祈福
function UnionController:ReqUnionPray(prayid)
	local msg = ReqUnionPrayMsg:new()
	msg.prayid = prayid;
	MsgManager:Send(msg)
	
	-- print('==============请求帮派祈福')
	-- trace(msg)
end;

--帮主名称变化
function UnionController:OnUpdateGuildMasterName(msg)
	FTrace(msg, '帮主名称变化')
	UnionModel.MyUnionInfo.guildMasterName = msg.guildMasterName
	Notifier:sendNotification(NotifyConsts.ChangeGuildMasterName)
end

--服务器返回帮主召集活动信息

function UnionController:OnGuildActivityNotice(msg)
	FTrace(msg, '服务器返回帮主召集活动信息')
	
	-- local inviterId = msg.inviterId; 	--邀请人id
	-- if SetSystemModel:GetIsUnion() then -- 如果系统设置中设置了禁止他人帮派邀请,直接返回拒绝
		-- self:ReqInviteToGuildResult(inviterId, UnionConsts.RejectJoinGuild);
		-- return;
	-- end
	-- local name = msg.name; 				--邀请人名称
	-- local guildName = msg.guildName		--帮派名称
	if not msg.NoticeList then return end	
	for k,v in pairs (msg.NoticeList) do
		local isAdd = true
		for i,n in pairs (self.noticeList) do
			if n.id == v.id then
				isAdd = false
				break
			end
		end
		
		if isAdd then
			local vo = {};
			vo.id = v.id;
			vo.param = v.param;
			vo.text = v.text;
			vo.name = v.roleName;
			vo.time = v.time;
			table.push(self.noticeList, vo)		
		end
	end
	
	self:CheckGuildNotice()	
end

function UnionController:CheckGuildNotice()
	if #self.noticeList <= 0 then return; end
	local data = table.remove(self.noticeList, 1);
	if not data.id or data.id <= 0 or not self:CheckIsToday(data.time) then
		self:CheckGuildNotice()
		return
	end
	
	RemindController:AddRemind(RemindConsts.Type_GuildZhaoji, data)	
end

-- sec 秒 UTC
function UnionController:CheckIsToday(sec)
	local year, month, day = CTimeFormat:todate( sec, true )
	local tyear, tmonth, tday = CTimeFormat:todate( GetServerTime(), true )
	return year == tyear and month == tmonth and day == tday
end

-----------------------------帮派弹劾------------------------------
-- 返回弹劾权限
function UnionController:OnGuildTanHeQuanXian(msg)
	FTrace(msg, '返回弹劾权限')
	local btanhe = msg.result --是否可以弹劾(0-不可以，1-可以)
	Notifier:sendNotification(NotifyConsts.GuildTanHeQuanXian, {btanhe = btanhe})
end

-- 返回弹劾结果
function UnionController:OnGuildTanHeQuan(msg)
	FTrace(msg, '返回弹劾结果')
	local btanhe = msg.quanxian --是否可以弹劾(0-不可以，1-可以)
	Notifier:sendNotification(NotifyConsts.GuildTanHeQuanXian, {btanhe = btanhe})
	if msg.result == 0 then
		self:ReqMyGuildMems()
	else
		FloatManager:AddCenter(StrConfig['union80'])
	end
end

-- 返回帮派仓库审批列表
function UnionController:OnGuildQueryCheckList(msg)
	FTrace(msg, '返回帮派仓库审批列表')
	Notifier:sendNotification(NotifyConsts.GuildQueryCheckList, {applyData = msg})
end

-- 返回帮派审核操作
function UnionController:OnGuildQueryCheckOper(msg)
	FTrace(msg, '返回帮派审核操作')
	if msg.result == 0 then
		self:ReqGuildQueryCheckList()
	end
end

-- 返回设置自动审核
function UnionController:OnGuildSetAutoCheck(msg)
	FTrace(msg, '返回设置自动审核')
end