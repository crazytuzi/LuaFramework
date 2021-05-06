local CQQPluginCtrl = class("CQQPluginCtrl",CCtrlBase)

define.QQPlugin = {
	Event = {
		Refresh = 0,
		gameJoinQQGroup = 1,
		gameBindGroup = 2,
		checkBindGroup = 3,
		unBindGroup = 4,
		shareImageAndTextToQQ = 5,
		shareImageToQQ = 6,
		shareToQzone = 7,
		checkJoinGroup = 8,
		getVipInfo = 9, 
	},
	Relation = {
		QunZhu = 1,
	}
}

function CQQPluginCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_HasJoinQQGroup = false
	self.m_HasBindQQGroup = false
	self.m_Relation = nil
end

function CQQPluginCtrl.OnCallBack(self, sType, iCode, sData)
	if sType == "gameJoinQQGroup" then
		if iCode == 0 then
			self.m_HasJoinQQGroup = true
		end
	elseif sType == "gameBindGroup" then
		if iCode == 0 then
			local dData = decodejson(sData)
			self.m_HasBindQQGroup = (dData.ret == 0)
			if self.m_HasBindQQGroup then
				netorg.C2GSOrgQQAction(1)
			end
		end
	elseif sType == "checkBindGroup" then
		if iCode == 0 then
			local dData = decodejson(sData)
			self.m_HasBindQQGroup = (dData.retCode == 0 and not string.IsNilOrEmpty(dData.group_key))
		else
			self.m_HasBindQQGroup = false
		end
	elseif sType == "unBindGroup" then
		if iCode == 0 then
			self.m_HasBindQQGroup = false
			netorg.C2GSOrgQQAction(0)
		end
	elseif sType == "shareImageAndTextToQQ" then

	elseif sType == "shareImageToQQ" then

	elseif sType == "shareToQzone" then

	elseif sType == "checkJoinGroup" then
		if iCode == 0 then
			local dData = decodejson(sData)
			-- printerror("xxxxxxxxxxxxxxxxxxxxxxx", dData.retCode, dData.relation)
			self.m_Relation = dData.relation
			self.m_HasJoinQQGroup = (dData.retCode == 0) and (dData.relation < 4 and dData.relation > 0)
		else
			self.m_HasJoinQQGroup = false
		end
	elseif sType == "getVipInfo" then

	end
	-- printerror("??????????????????????", sType, self.m_HasBindQQGroup, self.m_HasJoinQQGroup)
	self:OnEvent(define.QQPlugin.Event.Refresh)
end

function CQQPluginCtrl.IsRelation(self, iCmp)
	if self.m_Relation and self.m_Relation == iCmp then
		return true
	end
	return false
end

function CQQPluginCtrl.IsQQLogin(self)
	if Utils.IsAndroid() then
		if main.g_DllVer <= 15 then
			return false
		end
		if g_SdkCtrl:GetChannelId() == "kaopu" then
			if g_AndroidCtrl:GetQQLoginType() == 1 then
				return true
			end
		end
	end 
	return false
end

function CQQPluginCtrl.HasBindQQGroup(self)
	return self.m_HasBindQQGroup
end

function CQQPluginCtrl.HasJoinQQGroup(self)
	return self.m_HasJoinQQGroup
end


function CQQPluginCtrl.ResetQQGroupInfo(self)
	if not self:IsQQLogin() then
		return
	end
	local guildId = tostring(g_AttrCtrl.org_id)
	local guildName = g_AttrCtrl.orgname
	local dServer = g_LoginCtrl:GetConnectServer()
	local zoneId = tostring(g_ServerCtrl:ServerKeyToNumer(dServer.server_id))
	local roleId = tostring(g_AttrCtrl.pid)
	g_AndroidCtrl:CheckBindGroup(guildId, zoneId, roleId)
	g_AndroidCtrl:CheckJoinGroup(guildId, zoneId)
	self:TestEvent()
end


function CQQPluginCtrl.TestEvent(self)
	-- printerror("??????????????????????")
	-- self:OnCallBack("checkBindGroup", 0, [[{"retCode":0, "relation":1}]])
	-- self:OnCallBack("checkJoinGroup", 0, [[{"retCode":0, "relation":0}]])
end

return CQQPluginCtrl