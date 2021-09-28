





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "friendHandler_pb"


Pomelo = Pomelo or {}


Pomelo.FriendHandler = {}

local function friendGetAllFriendsRequestEncoder(msg)
	local input = friendHandler_pb.FriendGetAllFriendsRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendGetAllFriendsRequestDecoder(stream)
	local res = friendHandler_pb.FriendGetAllFriendsResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendGetAllFriendsRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.friendHandler.friendGetAllFriendsRequest", option)
	Socket.Request("area.friendHandler.friendGetAllFriendsRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendGetAllFriendsResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendGetAllFriendsRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendGetAllFriendsRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendGetAllFriendsRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendGetAllFriendsRequestEncoder, friendGetAllFriendsRequestDecoder)
end


local function friendApplyRequestEncoder(msg)
	local input = friendHandler_pb.FriendApplyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendApplyRequestDecoder(stream)
	local res = friendHandler_pb.FriendApplyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendApplyRequest(c2s_toPlayerId,cb,option)
	local msg = {}
	msg.c2s_toPlayerId = c2s_toPlayerId
	Socket.OnRequestStart("area.friendHandler.friendApplyRequest", option)
	Socket.Request("area.friendHandler.friendApplyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendApplyResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendApplyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendApplyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendApplyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendApplyRequestEncoder, friendApplyRequestDecoder)
end


local function friendAllApplyRequestEncoder(msg)
	local input = friendHandler_pb.FriendAllApplyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendAllApplyRequestDecoder(stream)
	local res = friendHandler_pb.FriendAllApplyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendAllApplyRequest(c2s_toPlayerIds,cb,option)
	local msg = {}
	msg.c2s_toPlayerIds = c2s_toPlayerIds
	Socket.OnRequestStart("area.friendHandler.friendAllApplyRequest", option)
	Socket.Request("area.friendHandler.friendAllApplyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendAllApplyResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendAllApplyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendAllApplyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendAllApplyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendAllApplyRequestEncoder, friendAllApplyRequestDecoder)
end


local function friendAgreeApplyRequestEncoder(msg)
	local input = friendHandler_pb.FriendAgreeApplyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendAgreeApplyRequestDecoder(stream)
	local res = friendHandler_pb.FriendAgreeApplyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendAgreeApplyRequest(c2s_requestId,cb,option)
	local msg = {}
	msg.c2s_requestId = c2s_requestId
	Socket.OnRequestStart("area.friendHandler.friendAgreeApplyRequest", option)
	Socket.Request("area.friendHandler.friendAgreeApplyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendAgreeApplyResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendAgreeApplyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendAgreeApplyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendAgreeApplyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendAgreeApplyRequestEncoder, friendAgreeApplyRequestDecoder)
end


local function friendAllAgreeApplyRequestEncoder(msg)
	local input = friendHandler_pb.FriendAllAgreeApplyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendAllAgreeApplyRequestDecoder(stream)
	local res = friendHandler_pb.FriendAllAgreeApplyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendAllAgreeApplyRequest(c2s_requestIds,cb,option)
	local msg = {}
	msg.c2s_requestIds = c2s_requestIds
	Socket.OnRequestStart("area.friendHandler.friendAllAgreeApplyRequest", option)
	Socket.Request("area.friendHandler.friendAllAgreeApplyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendAllAgreeApplyResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendAllAgreeApplyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendAllAgreeApplyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendAllAgreeApplyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendAllAgreeApplyRequestEncoder, friendAllAgreeApplyRequestDecoder)
end


local function friendRefuceApplyRequestEncoder(msg)
	local input = friendHandler_pb.FriendRefuceApplyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendRefuceApplyRequestDecoder(stream)
	local res = friendHandler_pb.FriendRefuceApplyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendRefuceApplyRequest(c2s_requestId,cb,option)
	local msg = {}
	msg.c2s_requestId = c2s_requestId
	Socket.OnRequestStart("area.friendHandler.friendRefuceApplyRequest", option)
	Socket.Request("area.friendHandler.friendRefuceApplyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendRefuceApplyResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendRefuceApplyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendRefuceApplyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendRefuceApplyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendRefuceApplyRequestEncoder, friendRefuceApplyRequestDecoder)
end


local function friendAllRefuceApplyRequestEncoder(msg)
	local input = friendHandler_pb.FriendAllRefuceApplyRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendAllRefuceApplyRequestDecoder(stream)
	local res = friendHandler_pb.FriendAllRefuceApplyResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendAllRefuceApplyRequest(c2s_requestIds,cb,option)
	local msg = {}
	msg.c2s_requestIds = c2s_requestIds
	Socket.OnRequestStart("area.friendHandler.friendAllRefuceApplyRequest", option)
	Socket.Request("area.friendHandler.friendAllRefuceApplyRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendAllRefuceApplyResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendAllRefuceApplyRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendAllRefuceApplyRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendAllRefuceApplyRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendAllRefuceApplyRequestEncoder, friendAllRefuceApplyRequestDecoder)
end


local function friendDeleteRequestEncoder(msg)
	local input = friendHandler_pb.FriendDeleteRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendDeleteRequestDecoder(stream)
	local res = friendHandler_pb.FriendDeleteResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendDeleteRequest(c2s_friendId,cb,option)
	local msg = {}
	msg.c2s_friendId = c2s_friendId
	Socket.OnRequestStart("area.friendHandler.friendDeleteRequest", option)
	Socket.Request("area.friendHandler.friendDeleteRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendDeleteResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendDeleteRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendDeleteRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendDeleteRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendDeleteRequestEncoder, friendDeleteRequestDecoder)
end


local function friendDeleteChouRenRequestEncoder(msg)
	local input = friendHandler_pb.FriendDeleteChouRenRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendDeleteChouRenRequestDecoder(stream)
	local res = friendHandler_pb.FriendDeleteChouRenResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendDeleteChouRenRequest(c2s_chouRenId,cb,option)
	local msg = {}
	msg.c2s_chouRenId = c2s_chouRenId
	Socket.OnRequestStart("area.friendHandler.friendDeleteChouRenRequest", option)
	Socket.Request("area.friendHandler.friendDeleteChouRenRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendDeleteChouRenResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendDeleteChouRenRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendDeleteChouRenRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendDeleteChouRenRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendDeleteChouRenRequestEncoder, friendDeleteChouRenRequestDecoder)
end


local function friendAllDeleteChouRenRequestEncoder(msg)
	local input = friendHandler_pb.FriendAllDeleteChouRenRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendAllDeleteChouRenRequestDecoder(stream)
	local res = friendHandler_pb.FriendAllDeleteChouRenResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendAllDeleteChouRenRequest(c2s_chouRenIds,cb,option)
	local msg = {}
	msg.c2s_chouRenIds = c2s_chouRenIds
	Socket.OnRequestStart("area.friendHandler.friendAllDeleteChouRenRequest", option)
	Socket.Request("area.friendHandler.friendAllDeleteChouRenRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendAllDeleteChouRenResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendAllDeleteChouRenRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendAllDeleteChouRenRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendAllDeleteChouRenRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendAllDeleteChouRenRequestEncoder, friendAllDeleteChouRenRequestDecoder)
end


local function friendAddChouRenRequestEncoder(msg)
	local input = friendHandler_pb.FriendAddChouRenRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendAddChouRenRequestDecoder(stream)
	local res = friendHandler_pb.FriendAddChouRenResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendAddChouRenRequest(c2s_chouRenId,cb,option)
	local msg = {}
	msg.c2s_chouRenId = c2s_chouRenId
	Socket.OnRequestStart("area.friendHandler.friendAddChouRenRequest", option)
	Socket.Request("area.friendHandler.friendAddChouRenRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendAddChouRenResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendAddChouRenRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendAddChouRenRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendAddChouRenRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendAddChouRenRequestEncoder, friendAddChouRenRequestDecoder)
end


local function addFriendInfoRequestEncoder(msg)
	local input = friendHandler_pb.AddFriendInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function addFriendInfoRequestDecoder(stream)
	local res = friendHandler_pb.AddFriendInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.addFriendInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.friendHandler.addFriendInfoRequest", option)
	Socket.Request("area.friendHandler.addFriendInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastAddFriendInfoResponse = res
			Socket.OnRequestEnd("area.friendHandler.addFriendInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.addFriendInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.addFriendInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, addFriendInfoRequestEncoder, addFriendInfoRequestDecoder)
end


local function queryPlayerNameRequestEncoder(msg)
	local input = friendHandler_pb.QueryPlayerNameRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function queryPlayerNameRequestDecoder(stream)
	local res = friendHandler_pb.QueryPlayerNameResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.queryPlayerNameRequest(c2s_strName,cb,option)
	local msg = {}
	msg.c2s_strName = c2s_strName
	Socket.OnRequestStart("area.friendHandler.queryPlayerNameRequest", option)
	Socket.Request("area.friendHandler.queryPlayerNameRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastQueryPlayerNameResponse = res
			Socket.OnRequestEnd("area.friendHandler.queryPlayerNameRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.queryPlayerNameRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.queryPlayerNameRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, queryPlayerNameRequestEncoder, queryPlayerNameRequestDecoder)
end


local function concernFriendRequestEncoder(msg)
	local input = friendHandler_pb.ConcernFriendRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function concernFriendRequestDecoder(stream)
	local res = friendHandler_pb.ConcernFriendResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.concernFriendRequest(c2s_friendId,cb,option)
	local msg = {}
	msg.c2s_friendId = c2s_friendId
	Socket.OnRequestStart("area.friendHandler.concernFriendRequest", option)
	Socket.Request("area.friendHandler.concernFriendRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastConcernFriendResponse = res
			Socket.OnRequestEnd("area.friendHandler.concernFriendRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.concernFriendRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.concernFriendRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, concernFriendRequestEncoder, concernFriendRequestDecoder)
end


local function concernAllFriendRequestEncoder(msg)
	local input = friendHandler_pb.ConcernAllFriendRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function concernAllFriendRequestDecoder(stream)
	local res = friendHandler_pb.ConcernAllFriendResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.concernAllFriendRequest(c2s_friendIds,cb,option)
	local msg = {}
	msg.c2s_friendIds = c2s_friendIds
	Socket.OnRequestStart("area.friendHandler.concernAllFriendRequest", option)
	Socket.Request("area.friendHandler.concernAllFriendRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastConcernAllFriendResponse = res
			Socket.OnRequestEnd("area.friendHandler.concernAllFriendRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.concernAllFriendRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.concernAllFriendRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, concernAllFriendRequestEncoder, concernAllFriendRequestDecoder)
end


local function friendMessageListRequestEncoder(msg)
	local input = friendHandler_pb.FriendMessageListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function friendMessageListRequestDecoder(stream)
	local res = friendHandler_pb.FriendMessageListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.friendMessageListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.friendHandler.friendMessageListRequest", option)
	Socket.Request("area.friendHandler.friendMessageListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastFriendMessageListResponse = res
			Socket.OnRequestEnd("area.friendHandler.friendMessageListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.friendMessageListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.friendMessageListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, friendMessageListRequestEncoder, friendMessageListRequestDecoder)
end


local function deleteAllFriendMessageRequestEncoder(msg)
	local input = friendHandler_pb.DeleteAllFriendMessageRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function deleteAllFriendMessageRequestDecoder(stream)
	local res = friendHandler_pb.DeleteAllFriendMessageResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.deleteAllFriendMessageRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.friendHandler.deleteAllFriendMessageRequest", option)
	Socket.Request("area.friendHandler.deleteAllFriendMessageRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastDeleteAllFriendMessageResponse = res
			Socket.OnRequestEnd("area.friendHandler.deleteAllFriendMessageRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.deleteAllFriendMessageRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.deleteAllFriendMessageRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, deleteAllFriendMessageRequestEncoder, deleteAllFriendMessageRequestDecoder)
end


local function deleteBlackListRequestEncoder(msg)
	local input = friendHandler_pb.DeleteBlackListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function deleteBlackListRequestDecoder(stream)
	local res = friendHandler_pb.DeleteBlackListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.deleteBlackListRequest(c2s_blackListId,cb,option)
	local msg = {}
	msg.c2s_blackListId = c2s_blackListId
	Socket.OnRequestStart("area.friendHandler.deleteBlackListRequest", option)
	Socket.Request("area.friendHandler.deleteBlackListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastDeleteBlackListResponse = res
			Socket.OnRequestEnd("area.friendHandler.deleteBlackListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.deleteBlackListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.deleteBlackListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, deleteBlackListRequestEncoder, deleteBlackListRequestDecoder)
end


local function deleteAllBlackListRequestEncoder(msg)
	local input = friendHandler_pb.DeleteAllBlackListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function deleteAllBlackListRequestDecoder(stream)
	local res = friendHandler_pb.DeleteAllBlackListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.deleteAllBlackListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.friendHandler.deleteAllBlackListRequest", option)
	Socket.Request("area.friendHandler.deleteAllBlackListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastDeleteAllBlackListResponse = res
			Socket.OnRequestEnd("area.friendHandler.deleteAllBlackListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.deleteAllBlackListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.deleteAllBlackListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, deleteAllBlackListRequestEncoder, deleteAllBlackListRequestDecoder)
end


local function addBlackListRequestEncoder(msg)
	local input = friendHandler_pb.AddBlackListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function addBlackListRequestDecoder(stream)
	local res = friendHandler_pb.AddBlackListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.addBlackListRequest(c2s_blackListId,cb,option)
	local msg = {}
	msg.c2s_blackListId = c2s_blackListId
	Socket.OnRequestStart("area.friendHandler.addBlackListRequest", option)
	Socket.Request("area.friendHandler.addBlackListRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastAddBlackListResponse = res
			Socket.OnRequestEnd("area.friendHandler.addBlackListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.addBlackListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.addBlackListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, addBlackListRequestEncoder, addBlackListRequestDecoder)
end


local function getSocialInfoRequestEncoder(msg)
	local input = friendHandler_pb.GetSocialInfoRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getSocialInfoRequestDecoder(stream)
	local res = friendHandler_pb.GetSocialInfoResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.getSocialInfoRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.friendHandler.getSocialInfoRequest", option)
	Socket.Request("area.friendHandler.getSocialInfoRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastGetSocialInfoResponse = res
			Socket.OnRequestEnd("area.friendHandler.getSocialInfoRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.getSocialInfoRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.getSocialInfoRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getSocialInfoRequestEncoder, getSocialInfoRequestDecoder)
end


local function getShopItemListRequestEncoder(msg)
	local input = friendHandler_pb.GetShopItemListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getShopItemListRequestDecoder(stream)
	local res = friendHandler_pb.GetShopItemListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.getShopItemListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.friendHandler.getShopItemListRequest", option)
	Socket.Request("area.friendHandler.getShopItemListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastGetShopItemListResponse = res
			Socket.OnRequestEnd("area.friendHandler.getShopItemListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.getShopItemListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.getShopItemListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getShopItemListRequestEncoder, getShopItemListRequestDecoder)
end


local function exchangeFriendShopItemRequestEncoder(msg)
	local input = friendHandler_pb.ExchangeFriendShopItemRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function exchangeFriendShopItemRequestDecoder(stream)
	local res = friendHandler_pb.ExchangeFriendShopItemResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.exchangeFriendShopItemRequest(c2s_itemId,c2s_num,cb,option)
	local msg = {}
	msg.c2s_itemId = c2s_itemId
	msg.c2s_num = c2s_num
	Socket.OnRequestStart("area.friendHandler.exchangeFriendShopItemRequest", option)
	Socket.Request("area.friendHandler.exchangeFriendShopItemRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastExchangeFriendShopItemResponse = res
			Socket.OnRequestEnd("area.friendHandler.exchangeFriendShopItemRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.exchangeFriendShopItemRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.exchangeFriendShopItemRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, exchangeFriendShopItemRequestEncoder, exchangeFriendShopItemRequestDecoder)
end


local function getRecentChatListRequestEncoder(msg)
	local input = friendHandler_pb.GetRecentChatListRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getRecentChatListRequestDecoder(stream)
	local res = friendHandler_pb.GetRecentChatListResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.getRecentChatListRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.friendHandler.getRecentChatListRequest", option)
	Socket.Request("area.friendHandler.getRecentChatListRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastGetRecentChatListResponse = res
			Socket.OnRequestEnd("area.friendHandler.getRecentChatListRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.getRecentChatListRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.getRecentChatListRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getRecentChatListRequestEncoder, getRecentChatListRequestDecoder)
end


local function getChatMsgRequestEncoder(msg)
	local input = friendHandler_pb.GetChatMsgRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getChatMsgRequestDecoder(stream)
	local res = friendHandler_pb.GetChatMsgResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.getChatMsgRequest(c2s_friendId,cb,option)
	local msg = {}
	msg.c2s_friendId = c2s_friendId
	Socket.OnRequestStart("area.friendHandler.getChatMsgRequest", option)
	Socket.Request("area.friendHandler.getChatMsgRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastGetChatMsgResponse = res
			Socket.OnRequestEnd("area.friendHandler.getChatMsgRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.getChatMsgRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.getChatMsgRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getChatMsgRequestEncoder, getChatMsgRequestDecoder)
end


local function rmChatMsgRequestEncoder(msg)
	local input = friendHandler_pb.RmChatMsgRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function rmChatMsgRequestDecoder(stream)
	local res = friendHandler_pb.RmChatMsgResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.FriendHandler.rmChatMsgRequest(c2s_friendId,cb,option)
	local msg = {}
	msg.c2s_friendId = c2s_friendId
	Socket.OnRequestStart("area.friendHandler.rmChatMsgRequest", option)
	Socket.Request("area.friendHandler.rmChatMsgRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.FriendHandler.lastRmChatMsgResponse = res
			Socket.OnRequestEnd("area.friendHandler.rmChatMsgRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.friendHandler.rmChatMsgRequest decode error!!"
			end
			Socket.OnRequestEnd("area.friendHandler.rmChatMsgRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, rmChatMsgRequestEncoder, rmChatMsgRequestDecoder)
end





return Pomelo
