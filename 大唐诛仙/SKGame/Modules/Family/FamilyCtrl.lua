RegistModules("Family/Creat/FamilyCreatePanel")
RegistModules("Family/Creat/FamilySubCreatePanel") 
RegistModules("Family/Creat/FamilyComCreatePanel")

RegistModules("Family/Main/FamilyMainPanel")
RegistModules("Family/Main/FamilyCell")

RegistModules("Family/Main/FamilyGGPanel")

RegistModules("Family/Main/FamilyPWPanel")
RegistModules("Family/Main/FamilyItem")

RegistModules("Family/Main/FamilyHYPanel")
RegistModules("Family/Main/FamilyHYItem")

RegistModules("Family/Main/FamilyYQPanel")
RegistModules("Family/Main/FamilySubPanel")

RegistModules("Family/FamilyModel")
RegistModules("Family/FamilyVo")
RegistModules("Family/FamilyConst")

FamilyCtrl = BaseClass(LuaController)

function FamilyCtrl:GetInstance()
	if FamilyCtrl.inst == nil then
		FamilyCtrl.inst = FamilyCtrl.New()
	end
	return FamilyCtrl.inst
end

function FamilyCtrl:__init()
	self:Config()
	self:RegistProto()
end

function FamilyCtrl:Config(  )
	self.view = nil
	resMgr:AddUIAB("Family")
	self.model = FamilyModel:GetInstance()
end

--注册协议
function FamilyCtrl:RegistProto()
	self:RegistProtocal("S_SynFamilyInfo") 
	self:RegistProtocal("S_CreateFamily") 
	self:RegistProtocal("S_DisbandFamily") 
	self:RegistProtocal("S_SynInviteJoinFamily") 
	self:RegistProtocal("S_ExitFamily") 
	self:RegistProtocal("S_KickFamilyPlayer")
end	

-----------------------------------------------------------------------------------------------------------------------------
--------------------------------------接收消息-------------------------------------------------------------------------------
-- playerFamilyId  家族唯一ID
-- familyName 家族名称
-- familyNotice  家族公告
-- listFamilyPlayer  家族玩家列表
function FamilyCtrl:S_SynFamilyInfo(buffer) -- 获取家族信息  综合同步数据
	local msg = self:ParseMsg(family_pb.S_SynFamilyInfo(), buffer)
	self.model:SynMembers( msg )
	self.model.state = 1
	GlobalDispatcher:Fire(EventName.FAMILY_CHANGE)
end

function FamilyCtrl:S_CreateFamily(buffer) -- 创建家族
	local msg = self:ParseMsg(family_pb.S_CreateFamily(), buffer)
	local str = GetCfgData("notice"):Get(6).msgContent
	UIMgr.Win_FloatTip(StringFormat(str, self.model.familyName))
	GlobalDispatcher:DispatchEvent(EventName.FAMILY_CREATE)
	self.model:DispatchEvent(FamilyConst.FAMILY_HEADNAME)
end

function FamilyCtrl:S_DisbandFamily(buffer) -- 同步在家族内所有玩家，家族解散
	UIMgr.Win_FloatTip(StringFormat("{0}家族已经被解散了", self.model.familyName))
	self.model:Clear()
	GlobalDispatcher:Fire(EventName.FAMILY_DISBAND)
end

function FamilyCtrl:S_SynInviteJoinFamily(buffer) -- 同步邀请消息给所有被邀请的玩家
	-- playerFamilyId  家族唯一ID
	-- familyName  家族名称
	-- playerId  邀请者编号ID
	-- playerName  邀请者名字	
	local msg = self:ParseMsg(family_pb.S_SynInviteJoinFamily(), buffer)
	-- local vo = FamilyInviteVo.New(msg)
	-- self.model:SaveInvitePanel(msg.playerFamilyId, vo)
	self.model.inviteVo = FamilyInviteVo.New(msg)
	self.model:SetRedTips(true)
	local str = "{0}邀请你加入{1}"
	UIMgr.Win_FloatTip(StringFormat(str, msg.playerName, msg.familyName))
	GlobalDispatcher:Fire(EventName.FAMILY_INVITE)
end

function FamilyCtrl:S_ExitFamily(buffer) -- 个人数据删除
	local msg = self:ParseMsg(family_pb.S_ExitFamily(), buffer)
	self.model:Clear()
	GlobalDispatcher:Fire(EventName.FAMILY_DISBAND)
end

function FamilyCtrl:S_KickFamilyPlayer(buffer) -- 推送被踢者
	local msg = self:ParseMsg(family_pb.S_KickFamilyPlayer(), buffer)
	UIMgr.Win_FloatTip(StringFormat("您已被请出了{0}家族", self.model.familyName))
	ChatNewController:GetInstance():AddChannelMsg(ChatNewModel.Channel.Family, "您已经被请出了家族")
	self.model:Clear()
	GlobalDispatcher:Fire(EventName.FAMILY_DISBAND)
end

-----------------------------------------------------------------------------------------------------------------------------
------------------------------------发送消息---------------------------------------------------------------------------------
function FamilyCtrl:C_GetFamilyInfo() -- 获取家族信息
	self:SendEmptyMsg(family_pb, "C_GetFamilyInfo")
end

function FamilyCtrl:C_CreateFamily( familyName ) -- 创建家族 
	local msg = family_pb.C_CreateFamily()
	msg.familyName = familyName
	self:SendMsg("C_CreateFamily", msg)
end

function FamilyCtrl:C_DisbandFamily() -- 解散家族
	self:SendEmptyMsg(family_pb, "C_DisbandFamily")
end

function FamilyCtrl:C_InviteJoinFamily( friendId ) -- 邀请加入家族
	local msg = family_pb.C_InviteJoinFamily()
	msg.friendId = friendId
	-- UIMgr.Win_FloatTip("已发出邀请")
	self:SendMsg("C_InviteJoinFamily", msg)
end

function FamilyCtrl:C_InviteMsgDeal( playerFamilyId, state ) -- 邀请信息处理
	-- playerFamilyId 家族唯一ID	
	-- state 0:拒绝，1:同意
	local msg = family_pb.C_InviteMsgDeal()
	msg.playerFamilyId = playerFamilyId
	msg.state = state
	self:SendMsg("C_InviteMsgDeal", msg)
end

function FamilyCtrl:C_ExitFamily() -- 退出家族
	self:SendEmptyMsg(family_pb, "C_ExitFamily")
	--ChatNewModel:GetInstance():DestroyFamilyItem()
	--ChatNewModel:GetInstance():DestroyFamilyChatMain()
end

function FamilyCtrl:C_ChangeFamilyLeader( newLeaderPlayerId ) -- 族长转让
	local msg = family_pb.C_ChangeFamilyLeader()
	msg.newLeaderPlayerId = newLeaderPlayerId
	self:SendMsg("C_ChangeFamilyLeader", msg)
end

function FamilyCtrl:C_ChangeFamilySortId( list ) -- 切换家族排位
	-- repeated int32 sortId
	if #list == 0 then return end
	local msg = family_pb.C_ChangeFamilySortId()

	for i=1, #list do
		msg.sortId:append(list[i])
	end
	self.model:ClearSortMembers()

	self:SendMsg("C_ChangeFamilySortId", msg)
end

function FamilyCtrl:C_ChangeFamilyNotice( msg ) -- 编辑家族公告
	local send = family_pb.C_ChangeFamilyNotice()
	send.msg = msg
	self:SendMsg("C_ChangeFamilyNotice", send)
	UIMgr.Win_FloatTip("修改成功")
end

function FamilyCtrl:C_KickFamilyPlayer( kickPlayerId ) -- 踢出家族成员
	local msg = family_pb.C_KickFamilyPlayer()
	msg.kickPlayerId = kickPlayerId
	self:SendMsg("C_KickFamilyPlayer", msg)
end

function FamilyCtrl:C_ChangeFamilyPlayerTitle( changePlayerId, title ) -- 修改成员称谓
	local msg = family_pb.C_ChangeFamilyPlayerTitle()
	msg.changePlayerId = changePlayerId
	msg.title = title
	self:SendMsg("C_ChangeFamilyPlayerTitle", msg)
end

-- 聊天窗口打开邀请
	function FamilyCtrl:OpenInvite()
		if not self.friendCommonPanel or not self.friendCommonPanel.isInited then
			self.friendCommonPanel = FriendCommonPanel.New(index)
		end
		self.friendCommonPanel:Open(nil, nil, true)
	end

function FamilyCtrl:__delete( )
	FamilyCtrl.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
end