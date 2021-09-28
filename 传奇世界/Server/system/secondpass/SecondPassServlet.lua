--SecondPassServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  SecondPassServlet.lua
 --* Author:  zhaofg
 --* Modified: 2016年5月24日
 --* Purpose: 二次密码验证
 -------------------------------------------------------------------*/
require "system.secondpass.SecondPassConstant"
SecondPassServlet = class(EventSetDoer, Singleton)

function SecondPassServlet:__init()
	self._doer = {
		[ESPASS_CS_SET_PASSWORD] 				= 	SecondPassServlet.SetPassword,
		[ESPASS_CS_CHANGE_PASSWORD]				=	SecondPassServlet.ChangePassword,
		[ESPASS_CS_RESET_PASSWORD]				=	SecondPassServlet.ResetPassword,
		[ESPASS_CS_CHECK_PASSWORD]				=	SecondPassServlet.CheckPassword,
		[ESPASS_CS_PASSWORD_INVALID_SECONDS]	=	SecondPassServlet.GetInvalidSeconds,
	}
end

function SecondPassServlet:SetPassword(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local dbid   = params[2]
	local cPlayer = g_entityMgr:getPlayerBySID(dbid)
	if not cPlayer then return end
	local req, err = protobuf.decode("SecondPassSetPasswordPrtocol" , buffer)
	if not req then
		print('SecondPassServlet:SetPassword '..tostring(err))
		return
	end
	if not g_SecondPassMgr:IsPasswordValid(req.strPass) then
		self:sendErrMsg2Client(cPlayer:getID(), SECOND_PASS_ERR_PASSFORMAT, 0)
		return;
	end	
	local nTime = os.time();
	local tPasswordInfo = g_SecondPassMgr:GetRolePasswordInfo(dbid);
	if tPasswordInfo then
		if tPasswordInfo.nInvalidTime > 0 then
			if tPasswordInfo.nInvalidTime + 3600*24*3 < nTime then
				local tPassInfo = {}
				tPassInfo.strPass = req.strPass
				tPassInfo.nInvalidTime = 0
				g_SecondPassMgr:SetRolePasswordInfo(dbid,tPassInfo)
			else
				if tPassInfo.strPass ~= req.strPass then
					self:sendErrMsg2Client(cPlayer:getID(), SECOND_PASS_ERR_PASS_ERR, 0)	
					return;
				end
			end
		else
			self:sendErrMsg2Client(cPlayer:getID(), SECOND_PASS_ERR_SET_REPEAT, 0)
			return;
		end	
	else
		local tPassInfo = {}
		tPassInfo.strPass = req.strPass
		tPassInfo.nInvalidTime = 0
		g_SecondPassMgr:SetRolePasswordInfo(dbid,tPassInfo)	
	end
	g_SecondPassMgr:SetRoleHasChecked(dbid)	
	local ret = {}
	fireProtoMessage(cPlayer:getID(), ESPASS_SC_SET_PASSWORD, "SecondPassSetPasswordRetPrtocol", ret)

end

function SecondPassServlet:ChangePassword(buffer1)	
	local params = buffer1:getParams()
	local buffer = params[1]
	local dbid   = params[2]

	local cPlayer = g_entityMgr:getPlayerBySID(dbid)
	if not cPlayer then return end

	local req, err = protobuf.decode("SecondPassChangePasswordProtocol" , buffer)
	if not req then
		print('SecondPassServlet:ChangePassword '..tostring(err))
		return
	end

	local tPasswordInfo = g_SecondPassMgr:GetRolePasswordInfo(dbid);
	if not tPasswordInfo then
		self:sendErrMsg2Client(cPlayer:getID(), SECOND_PASS_ERR_HAS_NOT_SET_PASS, 0)
		return;
	end

	if tPasswordInfo.strPass ~= req.strOldPass then
		self:sendErrMsg2Client(cPlayer:getID(), SECOND_PASS_ERR_OLDPASS_ERR, 0)
		return;
	end

	if not g_SecondPassMgr:IsPasswordValid(req.strNewPass) then
		self:sendErrMsg2Client(cPlayer:getID(), SECOND_PASS_ERR_PASSFORMAT, 0)
		return;
	end	

	tPasswordInfo.strPass = req.strNewPass;
	tPasswordInfo.nInvalidTime = 0;
	g_SecondPassMgr:SetRolePasswordInfo(dbid,tPasswordInfo)	
	g_SecondPassMgr:SetRoleHasChecked(dbid)	

	local ret = {}
	fireProtoMessage(cPlayer:getID(), ESPASS_SC_CHANGE_PASSWORD, "SecondPassChangePasswordRetProtocol", ret)
end

function SecondPassServlet:ResetPassword(buffer1)	
	local params = buffer1:getParams()
	local buffer = params[1]
	local dbid   = params[2]

	local cPlayer = g_entityMgr:getPlayerBySID(dbid)
	if not cPlayer then return end

	local req, err = protobuf.decode("SecondPassResetPasswordProtocol" , buffer)
	if not req then
		print('SecondPassServlet:ResetPassword '..tostring(err))
		return
	end

	local tPasswordInfo = g_SecondPassMgr:GetRolePasswordInfo(dbid);
	if not tPasswordInfo then
		self:sendErrMsg2Client(cPlayer:getID(), SECOND_PASS_ERR_HAS_NOT_SET_PASS, 0)
		return;
	end

	tPasswordInfo.nInvalidTime = os.time();
	g_SecondPassMgr:SetRolePasswordInfo(dbid,tPasswordInfo)	

	local ret = {}
	ret.dwInvalidSeconds = 3600*24*3;
	fireProtoMessage(cPlayer:getID(), ESPASS_SC_RESET_PASSWORD, "SecondPassResetPasswordRetProtocol", ret)
end

function SecondPassServlet:CheckPassword(buffer1)	
	local params = buffer1:getParams()
	local buffer = params[1]
	local dbid   = params[2]

	local cPlayer = g_entityMgr:getPlayerBySID(dbid)
	if not cPlayer then return end

	local req, err = protobuf.decode("SecondPassCheckPasswordProtocol" , buffer)
	if not req then
		print('SecondPassServlet:CheckPassword '..tostring(err))
		return
	end

	local tPasswordInfo = g_SecondPassMgr:GetRolePasswordInfo(dbid);
	if not tPasswordInfo then
		self:sendErrMsg2Client(cPlayer:getID(), SECOND_PASS_ERR_HAS_NOT_SET_PASS, 0)
		return;
	end

	if tPasswordInfo.nInvalidTime == 0 or (tPasswordInfo.nInvalidTime + 3600*24*3 > os.time()) then
		if tPasswordInfo.strPass ~= req.strPass then
			self:sendErrMsg2Client(cPlayer:getID(), SECOND_PASS_ERR_PASS_ERR, 0)
			return;
		end
	end	

	g_SecondPassMgr:SetRoleHasChecked(dbid)	

	local ret = {}
	fireProtoMessage(cPlayer:getID(), ESPASS_SC_CHECK_PASSWORD, "SecondPassCheckPasswordRetProtocol", ret)
end

function SecondPassServlet:GetInvalidSeconds(buffer1)	
	local params = buffer1:getParams()
	local buffer = params[1]
	local dbid   = params[2]

	local cPlayer = g_entityMgr:getPlayerBySID(dbid)
	if not cPlayer then return end

	local req, err = protobuf.decode("SecondPassGetInvalidSecondsProtocol" , buffer)
	if not req then
		print('SecondPassServlet:GetInvalidSeconds '..tostring(err))
		return
	end

	g_SecondPassMgr:SendSecondPassBaseInfo(cPlayer);
end

function SecondPassServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(self:getCurEventID(), roleId, EVENT_SECOND_PASS, errId, paramCount, params)
end

function SecondPassServlet.getInstance()
	return SecondPassServlet()
end

function SecondPassServlet:print_log(strLog)
	print(strLog)
end

g_SecondPassServlet = SecondPassServlet.getInstance()

g_eventMgr:addEventListener(SecondPassServlet.getInstance())