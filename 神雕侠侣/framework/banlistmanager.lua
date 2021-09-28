--banlistmanager.lua
--It is a manager to manage the ban list ,you can get and set the banlist data by the methods in this file
--create by wuyao in 2014-2-19

--the data of banlist
BanListManager = {}
BanListManager.__index = BanListManager

--For singleton
local _instance;
function BanListManager.getInstance()
	print("enter get BanListManager instance")
    if not _instance then
        _instance = BanListManager:new()
    end
    
    return _instance
end

function BanListManager.getInstanceNotCreate()
    return _instance
end

function BanListManager.Destroy()
	if _instance then 
		print("destroy BanListManager")
		_instance = nil
	end
end

function BanListManager:new()
    local self = {}
	setmetatable(self, BanListManager)

	self.m_vBanList = {}

    return self
end

--Refresh the ban list from a table
--@param blackRolesList : The list with roles info, include roleid,name,level,shape,school
--@return : no return
function BanListManager:RefreshBanList(banlist)
	if banlist == nil then
		print("banlist is nil in BanListManager:RefreshBanList")
	end
	self.m_vBanList = banlist
end

--Add a role to ban list
--@parm roleid : he roleid needs to be add
--@return : no return
function BanListManager:AddRole(roleid)
	if roleid == nil then
		print("roleid is nil in BanListManager:AddRole")
		return
	end

	--the role is in ban list
	if self.m_vBanList[roleid] ~= nil then
		return
	end

	--require add the role in ban list
	require "protocoldef.knight.gsp.pingbi.caddblackrole"
	local req = CAddBlackRole.Create()
	req.roleid = roleid
	LuaProtocolManager.getInstance():send(req)
end

--Remove a role to ban list
--@parm roleid : he roleid needs to be remove
--@return : no return
function BanListManager:RemoveRole(roleid)
	if roleid == nil then
		print("roleid is nil in BanListManager:RemoveRole")
		return
	end

	--require add the role in ban list
	require "protocoldef.knight.gsp.pingbi.cremoveblackrole"
	local req = CRemoveBlackRole.Create()
	req.roleid = roleid
	LuaProtocolManager.getInstance():send(req)
end

--Check whether a roleid is in ban list, used in cpp
--@param roleid : The roleid needs to be check
--@return : If the roleid is in ban list, return 1; otherwise it return 0
function BanListManager.GlobalIsInBanList(roleid)
	if roleid == nil then
		print("roleid is nil in BanListManager.GlobalIsInBanList")
		return 0
	end

	if BanListManager.getInstance():IsInBanList(roleid) == true then
		return 1
	else
		return 0
	end
end

--Check whether a roleid is in ban list, used in lua
--@param roleid : The roleid needs to be check
--@return : If the roleid is in ban list, return true; otherwise it return false
function BanListManager:IsInBanList(roleid)
	if roleid == nil then
		print("roleid is nil in BanListManager:IsInBanList")
		return false
	end

	for k,v in pairs(self.m_vBanList) do
		if v.roleid == roleid then
			return true
		end
	end

	return false
end

--Get the ban list
--return : The ban list table
function BanListManager:GetBanList()
	return self.m_vBanList
end

return BanListManager
