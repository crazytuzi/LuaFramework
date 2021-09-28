--Author:		bishaoqing
--DateTime:		2016-05-04 17:32:42
--Region:		记录服务器客户端协议来往
require("src/CommonFunc")
local ProtoWriter = class("ProtoWriter")

function ProtoWriter:ctor( ... )
	-- body
	self.m_nCurSeqID = 0;
	self.m_nSubID = 0;
	self.socket_ = nil
	self.iCurSystemTime_ = nil
	self.stAllProtoStruct_ = {}
end

-- function ProtoWriter:ParseMsgDef( ProtoNameOrProtoId )
-- 	-- body
-- 	if type(ProtoNameOrProtoId) == "string" then
-- 		return _G[ProtoNameOrProtoId]
-- 	elseif type(ProtoNameOrProtoId) == "number" then
-- 		for k,v in pairs(_G) do
-- 			if tonumber(v) == tonumber(ProtoNameOrProtoId) then
-- 				return k
-- 			end
-- 		end
-- 	end
-- end

function ProtoWriter:MakeDir( ... )
	local strDir = "";
    local arg = {...}
	for i=1,#arg do
		if 0 ~= string.len(strDir) then
			strDir = strDir .. "/";
		end
		strDir = strDir .. arg[i];
		CGameFunc:MkDir( strDir );
	end
	return strDir;
end

function ProtoWriter:Id2Str( nID )
	if not nID then
		nID = 0
	end
	local function Do( nID )
		local str = tostring(nID);
		while string.len(str) < 5 do
			str = "0" .. str;
		end
		return str;
	end
	self.m_nSubID = self.m_nSubID + 1;
	if 0 == nID then
		return Do(self.m_nSubID) .. "_" .. Do( self.m_nCurSeqID );
	end
	
	return Do(self.m_nSubID) .. "_" .. Do( nID );
end

function ProtoWriter:GetTickCount()
	if not self.socket_ then
		self.socket_ = require "socket"
	end
    return self.socket_.gettime()*1000
end

function ProtoWriter:LogProto( iMsgID, sProName, stData, sBuffer, bGetMoreData)
	-- body
	-- do log only in win32
	if not IsWin32() then
		return
	end
	if not self:IsActive() then
		return
	end
	
	if not sProName or string.find(sProName, "FrameHeartBeat") then --不记录心跳包
		return
	end
	-- if not iMsgID then
	-- 	iMsgID = self:ParseMsgDef(sProName)
	-- end
	if not stData then
		return
	end

	if not self.iCurSystemTime_ then
		self.iCurSystemTime_ = math.floor(self:GetTickCount())
	end
	local sDirPath = self:MakeDir( "__protoLog__", self.iCurSystemTime_ )
	
	local file = io.open( sDirPath .. "/" .. self:Id2Str(iMsgID) .. "_" .. sProName .. ".log", "wb" );
	if file then
		local function Log( str )
			file:write( str .. "\r\n" );
		end
		file:write( self:GetTickCount() .. "\r\n" );
		file:write("ProtoName:\t".. tostring(sProName) .. "\r\n")
		if bGetMoreData then
			self:GetMoreData(sProName, stData)
		end
		TablePrint({["Data"] = stData}, 0, Log );
		file:close();
	end

end

function ProtoWriter:GetMoreData( sProName, stData )
	-- body
	--pbc中table变量需要取值————index才行
	if not sProName or not stData then
		return
	end
	if not CGameFunc.GetWorkDir then
		return
	end
	local sWorkDir = CGameFunc:GetWorkDir()
	sWorkDir = string.gsub(sWorkDir, "\\", "/")
	if not self.stProtocol_ and cc.FileUtils:getInstance():isFileExist(sWorkDir .. "/protocol.lua") then
		self.stProtocol_ = dofile(sWorkDir .. "/protocol.lua")
	end
    if self.stProtocol_ then
        self:DotIn(self.stProtocol_, sProName, stData)
    end
end

--深入取值
function ProtoWriter:DotIn( sProtocalLua, sProName, stData )
	-- body
	if not sProtocalLua or not sProName or not stData then
		return
	end
	local stStruct = sProtocalLua[sProName]
	if stStruct then
		for key,t in pairs(stStruct) do
			if t[1] == 0 then--普通变量
				local _ = stData[key]
			elseif t[1] == 1 then--repeat普通变量
				local _s = stData[key]
				for i,v in ipairs(_s) do
					local __ = _s[i]
				end
			elseif t[1] == 2 then--table变量
				local stDetailTable = stData[key]
				self:DotIn(sProtocalLua, t[2], stDetailTable)
			elseif t[1] == 3 then--repeattable变量
				local vDetailTables = stData[key]
				if vDetailTables then

					for i,stDetailTable in ipairs(vDetailTables) do
						self:DotIn(sProtocalLua, t[2], stDetailTable)
					end
				else
					print("!!!protocol.proto is not lasted!!!")
				end
			end
		end
	end
end

function ProtoWriter:IsActive( ... )
	-- body
	if not IsWin32() then
		return false
	end
	return GetIniLoader():GetPrivateBool("Main", "ProtoWriter") ~= false
end

return ProtoWriter