require("scripts/game/team/team_view")
require("scripts/game/team/team_data")

------------------------------------------------------------
-- 组队
------------------------------------------------------------

TeamCtrl = TeamCtrl or BaseClass(BaseController)

function TeamCtrl:__init()
	if TeamCtrl.Instance then
		ErrorLog("[TeamCtrl] attempt to create singleton twice!")
		return
	end
	TeamCtrl.Instance =self

	self.data = TeamData.New()
	self.view = TeamView.New(ViewDef.Team)

	self:RegisterAllProtocals()
end

function TeamCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	TeamCtrl.Instance = nil
end

function TeamCtrl:CheckTeamTip()
	local apply_list = self.data:GetTeamApplyList()
	local inivte_list = self.data:GetTeamInivteList()
	local num = #apply_list + #inivte_list
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.TEAM, num, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.Team.TeamApplyList)
	end)
end

function TeamCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCTeamInfo, "OnTeamInfo")
	self:RegisterProtocol(SCAddTeammate, "OnAddTeammate")
	self:RegisterProtocol(SCRemoveTeammate, "OnRemoveTeammate")
	self:RegisterProtocol(SCSetTeamLeader, "OnSetTeamLeader")
	self:RegisterProtocol(SCSetPickUpMode, "OnSetPickUpMode")
	self:RegisterProtocol(SCSetPickUpItemLv, "OnSetPickUpItemLv")
	self:RegisterProtocol(SCTeammateOutline, "OnTeammateOutline")
	self:RegisterProtocol(SCOneTeamApply, "OnOneTeamApply")
	self:RegisterProtocol(SCOneTeamInvite, "OnOneTeamInvite")
	self:RegisterProtocol(SCTeammateDieOrRelive, "OnTeammateDieOrRelive")
	self:RegisterProtocol(SCTeammatePos, "OnTeammatePos")
	self:RegisterProtocol(SCNearbyTeam, "OnNearbyTeam")
end

----------接收----------
-- 组队信息
function TeamCtrl:OnTeamInfo(protocol)
	self.data:SetTeamInfo(protocol)
	self:CheckTeamTip()
end

-- 添加一个成员
function TeamCtrl:OnAddTeammate(protocol)
	self.data:AddTeammate(protocol)
end

-- 删除一个成员
function TeamCtrl:OnRemoveTeammate(protocol)
	self.data:RemoveTeammate(protocol)
end

-- 设置一个人为队长
function TeamCtrl:OnSetTeamLeader(protocol)
	self.data:SetLeaderId(protocol)
end

-- 设置拾取方式
function TeamCtrl:OnSetPickUpMode(protocol)
	self.data:SetPickUpMode(protocol.mode)
end

-- 设置队伍拾取和队伍分配的时候的最低需要Loot的物品等级
function TeamCtrl:OnSetPickUpItemLv(protocol)
	self.data:SetPickUpItemLv(protocol.item_pickup_lv)
end

-- 一个玩家离线
function TeamCtrl:OnTeammateOutline(protocol)
	self.data:SetTeammateOutLine(protocol.role_id)
end

-- 玩家申请加入队伍
function TeamCtrl:OnOneTeamApply(protocol)
	self.data:AddTeamApply(protocol)
	self:CheckTeamTip()
end

-- 邀请加入队伍
function TeamCtrl:OnOneTeamInvite(protocol)
	local organize_type = TeamData.Instance.GetOrganizeType()
	if organize_type == 0 and not self.data:HasTeam() then
		self:SendJoinTeamInviteReply(protocol.invite_info.name, 1, 1)
	elseif organize_type == 2 then
		self:SendJoinTeamInviteReply(protocol.invite_info.name, 0, 1)
	else
		self.data:AddTeamInvite(protocol)
		self:CheckTeamTip()
	end
end

-- 队员死亡或者复活
function TeamCtrl:OnTeammateDieOrRelive(protocol)
	self.data:SetTeammateDie(protocol)
end

-- 角色移动时，广播消息给队友
function TeamCtrl:OnTeammatePos(protocol)
	self.data:SetTeammatePosInfo(protocol)
end

-- 返回附近队伍
function TeamCtrl:OnNearbyTeam(protocol)
	self.data:SetNearTeamList(protocol)
end
----------end----------

----------发送----------

-- 邀请加入队伍
function TeamCtrl.SendInviteJoinTeam(role_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSInviteJoinTeam)
	protocol.role_name = role_name
	protocol:EncodeAndSend()
end

-- 退出队伍
function TeamCtrl.SendQuitTeamReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSQuitTeamReq)
	protocol:EncodeAndSend()
end

-- 申请加入队伍(返回 16 9)
function TeamCtrl.SendApplyJoinTeam(role_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSApplyJoinTeam)
	protocol.role_name = role_name
	protocol:EncodeAndSend()
end

-- 设置一个人为队长
function TeamCtrl.SendSetTeamLeader(role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetTeamLeader)
	protocol.role_id = role_id
	protocol:EncodeAndSend()
end

-- 踢出一个玩家
function TeamCtrl.SendRemoveTeammate(role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRemoveTeammate)
	protocol.role_id = role_id
	protocol:EncodeAndSend()
end

-- 设置拾取的方式
function TeamCtrl.SendSetTeamPickupMode(mode)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetTeamPickupMode)
	protocol.mode = mode
	protocol:EncodeAndSend()
end

-- 设置队伍拾取和队伍分配的时候的最低需要Loot的物品等级(返回 16 6)
function TeamCtrl.SendSetTeamPickupItemLv(item_lv)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetTeamPickupItemLv)
	protocol.item_lv = item_lv
	protocol:EncodeAndSend()
end

-- 队长分配的时候选择物品的分配者
function TeamCtrl.SendSetTeamLeaderChooseBelong(series, role_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetTeamLeaderChooseBelong)
	protocol.series = series
	protocol.role_id = role_id
	protocol:EncodeAndSend()
end

-- 解散队伍
function TeamCtrl.SendDismissTeam()
	local protocol = ProtocolPool.Instance:GetProtocol(CSDismissTeam)
	protocol:EncodeAndSend()
end

-- 回复所有申请入队
function TeamCtrl:AllJoinTeamApplyReply(result)
	local list = self.data:GetTeamApplyList()
	for k,v in pairs(list) do
		self:SendJoinTeamApplyReply(v.role_id, result, true)
	end
	self.data:DeleteOneApply("all")
	self:CheckTeamTip()
end

-- 回复申请入队
function TeamCtrl:SendJoinTeamApplyReply(role_id, result, all)
	if not all then
		self.data:DeleteOneApply(role_id)
		self:CheckTeamTip()
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSJoinTeamApplyReply)
	protocol.role_id = role_id
	protocol.result = result
	protocol:EncodeAndSend()
end

-- 回复所有邀请入队
function TeamCtrl:AllJoinTeamInviteReply(result)
	local list = self.data:GetTeamInivteList()
	for k,v in pairs(list) do
		self:SendJoinTeamInviteReply(v.name, result, 0, true)
	end
	self.data:DeleteOneInvite("all")
	self:CheckTeamTip()

end
-- 回复邀请入队
function TeamCtrl:SendJoinTeamInviteReply(role_name, result, is_auto, all)
	if result == 0 and not all then
		self.data:DeleteOneInvite(role_name)
		self:CheckTeamTip()
	end
	local protocol = ProtocolPool.Instance:GetProtocol(CSJoinTeamInviteReply)
	protocol.role_name = role_name
	protocol.result = result
	protocol.is_auto = is_auto
	protocol:EncodeAndSend()
	RemindManager.Instance:DoRemind(RemindName.TeamApply)
end

-- 召唤队友
function TeamCtrl.SendCallTeammate(role_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCallTeammate)
	protocol.role_name = role_name
	protocol:EncodeAndSend()
end

-- 创建队伍
function TeamCtrl.SendCreateTeamReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateTeamReq)
	protocol:EncodeAndSend()
end

-- 申请获得附近队伍
function TeamCtrl.SendGetNearTeamReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetNearTeamReq)
	protocol:EncodeAndSend()
end

-- 队伍成员信息
function TeamCtrl.SendGetTeamInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetTeamInfo)
	protocol:EncodeAndSend()
end
----------end----------
