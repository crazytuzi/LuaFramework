--Author:		bishaoqing
--DateTime:		2016-06-01 16:44:46
--Region:		好友管理
local FriendCtr = class("FriendCtr")
local FriendObj = require("src/layers/friend/logic/FriendObj")
--构造函数
function FriendCtr:ctor( ... )
	-- body
	self.m_stAllFriends = {}
	self.m_iFriendUid = 0
	self:AddEvent()
end

--添加监听
function FriendCtr:AddEvent( ... )
	-- body
	g_msgHandlerInst:registerMsgHandler(COPY_SC_GETFRIENDDATARET, handler(self, self.onGetFriendsRet))
end
--删除监听
function FriendCtr:RemoveEvent( ... )
	-- body
	g_msgHandlerInst:registerMsgHandler(COPY_SC_GETFRIENDDATARET, nil)
end

--获取好友
function FriendCtr:getFriendsFromServer( ... )
	-- body
	g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETFRIENDDATA,"CopyGetFriendDataProtocol", {})
end

--获取好友列表返回
function FriendCtr:onGetFriendsRet( sBuffer )
	-- body
	local stInfo = g_msgHandlerInst:convertBufferToTable("CopyGetFriendDataRetProtocol", sBuffer)
	self:reset(stInfo)

	Event.Dispatch(EventName.GetFriendsRet)
end

--重新解析
--[[
message CopyGetFriendDataRetProtocol
{
	optional int32 friendNum = 1;
	repeated CopyFriendInfo info = 2;
}
]]
function FriendCtr:reset( stInfo )
	-- body
	self:Clear()

	self.m_nFriendNum = stInfo.friendNum

	for i,stInfo in ipairs(stInfo.info) do
		local oFriend = self:createFriendObj(stInfo)
		if oFriend then
			self:AddCach(oFriend)
		end
	end
end

function FriendCtr:createFriendObj( stInfo )
	-- body
	if not stInfo then
		return
	end
	self.m_iFriendUid = self.m_iFriendUid + 1
	local oFriend = FriendObj.new(self.m_iFriendUid)
	oFriend:reset(stInfo)
	return oFriend
end

--添加缓存
function FriendCtr:AddCach( oFriend )
	-- body
	if not oFriend then
		return
	end
	local iUid = oFriend:getUid()
	if iUid then
		self.m_stAllFriends[iUid] = oFriend
	end
end

--删除缓存
function FriendCtr:RemoveCach( iUid )
	-- body
	if not iUid then
		return
	end
	local oFriend = self.m_stAllFriends[iUid]
	if oFriend then
		oFriend:dispose()
		self.m_stAllFriends[iUid] = nil
	end
end

--获取缓存
function FriendCtr:GetCach( iUid )
	-- body
	if not iUid then
		return
	end
	return self.m_stAllFriends[iUid]
end

--清空缓存
function FriendCtr:Clear( ... )
	-- body
	for k,v in pairs(self.m_stAllFriends) do
		v:dispose()
		self.m_stAllFriends[k] = nil
	end
end

function FriendCtr:getAllOnline( ... )
	-- body
	local vRet = {}
	if self.m_stAllFriends then
		for iUid,oFriend in pairs(self.m_stAllFriends) do
			if oFriend:isOnline() then
				table.insert(vRet, oFriend)
			end
		end
	end
	return vRet
end

--获取全部缓存(自己的缓存是map，返回出去的是vector)
function FriendCtr:GetAllCach( bSort, funSortFun )
	-- body
	local vRet = {}
	if self.m_stAllFriends then
		for iUid,oFriend in pairs(self.m_stAllFriends) do
			table.insert(vRet, oFriend)
		end
	end
	--如果需要排序就排
	if bSort then
		if funSortFun then
			table.sort(vRet, funSortFun)
		else
			table.sort(vRet, function( a, b )
				-- body
				return a:getUid() < b:getUid()
			end)
		end
	end
	return vRet
end

function FriendCtr:Dispose( ... )
	-- body
	self:RemoveEvent()
end

return FriendCtr