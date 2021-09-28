--SecondPassManager.lua
--/*-----------------------------------------------------------------
--* Module:  SecondPassManager.lua
--* Author:  zhaofg
--* Modified: 2016年5月24日 
--* Purpose: Implementation of the class SecondPassManager 
-------------------------------------------------------------------*/
require "system.secondpass.SecondPassServlet"

SecondPassManager = class(nil, Singleton)

function SecondPassManager:__init()	
	
	self._UserPassInfo = {} 				--密码和过期时间
	self._UserCheckInfo = {}                --验证结果

	g_listHandler:addListener(self)         --增加接口回调
end

function SecondPassManager:GetRolePasswordInfo(dbid)
	return self._UserPassInfo[dbid];
end

function SecondPassManager:SetRolePasswordInfo( dbid , passinfo)
	self._UserPassInfo[dbid] = passinfo;
	self:CastPassInfoToDb(dbid)
end

function SecondPassManager.IsRoleHasCheckedForCpp( dbid )
	if g_SecondPassMgr:IsRoleHasChecked(dbid) then 
		return 1
	end 	
	local cPlayer = g_entityMgr:getPlayerBySID(dbid)
	if not cPlayer then return end
	g_SecondPassServlet:sendErrMsg2Client(cPlayer:getID(), SECOND_PASS_ERR_INVALID_OP, 0)
	return 0
end

function SecondPassManager:IsRoleHasCheckedForLua( dbid )
	if self:IsRoleHasChecked(dbid) then 
		return 1
	end 	
	local cPlayer = g_entityMgr:getPlayerBySID(dbid)
	if not cPlayer then return end
	g_SecondPassServlet:sendErrMsg2Client(cPlayer:getID(), SECOND_PASS_ERR_INVALID_OP, 0)
	return 0
end

function SecondPassManager:IsRoleHasChecked(dbid)
	local tPassInfo = self:GetRolePasswordInfo(dbid)
	if not tPassInfo then 
		return 1
	end

	--重置且已失效
	if tPassInfo.nInvalidTime > 0 then
		if tPassInfo.nInvalidTime + 3600*24*3 < os.time() then
			return 1
		end 	
	end


	if self._UserPassInfo[dbid] then
		return self._UserCheckInfo[dbid];
	else
		return nil
	end
end

function SecondPassManager:SetRoleHasChecked(dbid)
	self._UserCheckInfo[dbid] = 1;
end

function SecondPassManager:IsPasswordValid(strPassword)
	if #strPassword ~= 6 then
		return nil
	end
	for i=1,#strPassword do

		local curByte = string.byte(strPassword, i)
		local byteFlag = 0

		if curByte >= 48 and curByte <= 57 then
			byteFlag = 1
		elseif curByte >= 65 and curByte <= 90 then
			byteFlag = 1
		elseif curByte >= 97 and curByte <= 122 then
			byteFlag = 1
		end

		if tonumber(byteFlag) ~= 1 then
			return nil
		end 	
	end

	return true
end

--玩家上线
function SecondPassManager:onPlayerLoaded( player )
	if player then
		self:SendSecondPassBaseInfo(player);
	end
end

--发送二次密码基本信息
function SecondPassManager:SendSecondPassBaseInfo( player )
	if player then
		local tPasswordInfo = g_SecondPassMgr:GetRolePasswordInfo(player:getSerialID());

		local ret = {}
		if not tPasswordInfo then
			ret.dwPassStatus = 0
			ret.dwInvalidSeconds = 0
		else
			if tPasswordInfo.nInvalidTime > 0 then
				local nTime = os.time()
				if tPasswordInfo.nInvalidTime + 3600*24*3 > nTime then
					ret.dwPassStatus = 2
					ret.dwInvalidSeconds = tPasswordInfo.nInvalidTime + 3600*24*3 - nTime
				else
					ret.dwPassStatus = 0
					ret.dwInvalidSeconds = 0	
				end
			else
				ret.dwPassStatus = 1
				ret.dwInvalidSeconds = 0		
			end
		end
		fireProtoMessage(player:getID(), ESPASS_SC_PASSWORD_INVALID_SECONDS, "SecondPassGetInvalidSecondsRetProtocol", ret)
		--print("--------------------------------secondpass-----"..tostring(ret.dwPassStatus).."--"..tostring(ret.dwInvalidSeconds).."--"..tostring(player:getSerialID()))
	end
end

--玩家续线
function SecondPassManager:onActivePlayer(player)
	if player then
		self:SendSecondPassBaseInfo(player);
	end
end

--玩家下线
function SecondPassManager:onPlayerOffLine(player)
	if player then
		local roleSID = player:getSerialID()
		local tPassInfo = self:GetRolePasswordInfo(roleSID)
		if tPassInfo then
			--存入数据库
			self:CastPassInfoToDb(roleSID)
			self._UserPassInfo[roleSID] = nil
			self._UserCheckInfo[roleSID] = nil  --不存数据库
		end
	end
end

--存入数据库
function SecondPassManager:CastPassInfoToDb(roleSID)
	local dbStr = {d=self._UserPassInfo[roleSID]}
	local cache_buf = serialize(dbStr)
	g_engine:savePlayerCache(roleSID, FIELD_PLAYESECONDPASS, cache_buf, #cache_buf)	
end

--从数据库加载
function SecondPassManager.loadDBData(player, cacha_buf, roleSid)
	g_SecondPassMgr:loadDBDataImpl(player, cacha_buf, roleSid)
end

--数据库加载回调
function SecondPassManager:loadDBDataImpl(player, cacha_buf, roleSid)
	if not player then return end
	local roleSID = player:getSerialID()

	local data = unserialize(cacha_buf)
	if data.d then
		local dbData = data.d
		self._UserPassInfo[roleSID] = dbData		
	end
end

function SecondPassManager.getInstance()
	return SecondPassManager()
end

g_SecondPassMgr = SecondPassManager.getInstance()