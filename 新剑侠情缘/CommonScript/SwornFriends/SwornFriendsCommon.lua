function SwornFriends:GetConnectPids(pPlayer)
	if MODULE_GAMESERVER then
		return self:GetFriendsId(pPlayer.dwID)
	else
		return self.tbConnectIds or {}
	end
end

function SwornFriends:IsConnectedState(pPlayer)
	if MODULE_GAMESERVER then
		return self:_GetConnectInfo(pPlayer.dwID)
	else
		return self.bConnected
	end
end

function SwornFriends:GetMemberCountDesc(nMemberCount)
	local tbDesc = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"}
	if version_vn then
		tbDesc = {"壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾"}
	end
	local szRet = tbDesc[nMemberCount]
	if not szRet then
		Log("[x] SwornFriends:GetMemberCountDesc", tostring(nMemberCount))
	end
	return szRet or tostring(nMemberCount)
end