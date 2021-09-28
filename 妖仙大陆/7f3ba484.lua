





local Socket = require "Xmds.Pomelo.LuaGameSocket"
require "base64"
require "taskHandler_pb"


Pomelo = Pomelo or {}


Pomelo.TaskHandler = {}

local function acceptTaskRequestEncoder(msg)
	local input = taskHandler_pb.AcceptTaskRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function acceptTaskRequestDecoder(stream)
	local res = taskHandler_pb.AcceptTaskResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.acceptTaskRequest(c2s_templateId,c2s_kind,c2s_npcId,cb,option)
	local msg = {}
	msg.c2s_templateId = c2s_templateId
	msg.c2s_kind = c2s_kind
	msg.c2s_npcId = c2s_npcId
	Socket.OnRequestStart("area.taskHandler.acceptTaskRequest", option)
	Socket.Request("area.taskHandler.acceptTaskRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TaskHandler.lastAcceptTaskResponse = res
			Socket.OnRequestEnd("area.taskHandler.acceptTaskRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.taskHandler.acceptTaskRequest decode error!!"
			end
			Socket.OnRequestEnd("area.taskHandler.acceptTaskRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, acceptTaskRequestEncoder, acceptTaskRequestDecoder)
end


local function quickFinishRequestEncoder(msg)
	local input = taskHandler_pb.QuickFinishRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function quickFinishRequestDecoder(stream)
	local res = taskHandler_pb.QuickFinishResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.quickFinishRequest(c2s_templateId,c2s_kind,c2s_npcId,cb,option)
	local msg = {}
	msg.c2s_templateId = c2s_templateId
	msg.c2s_kind = c2s_kind
	msg.c2s_npcId = c2s_npcId
	Socket.OnRequestStart("area.taskHandler.quickFinishRequest", option)
	Socket.Request("area.taskHandler.quickFinishRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TaskHandler.lastQuickFinishResponse = res
			Socket.OnRequestEnd("area.taskHandler.quickFinishRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.taskHandler.quickFinishRequest decode error!!"
			end
			Socket.OnRequestEnd("area.taskHandler.quickFinishRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, quickFinishRequestEncoder, quickFinishRequestDecoder)
end


local function discardTaskRequestEncoder(msg)
	local input = taskHandler_pb.DiscardTaskRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function discardTaskRequestDecoder(stream)
	local res = taskHandler_pb.DiscardTaskResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.discardTaskRequest(c2s_templateId,c2s_kind,cb,option)
	local msg = {}
	msg.c2s_templateId = c2s_templateId
	msg.c2s_kind = c2s_kind
	Socket.OnRequestStart("area.taskHandler.discardTaskRequest", option)
	Socket.Request("area.taskHandler.discardTaskRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TaskHandler.lastDiscardTaskResponse = res
			Socket.OnRequestEnd("area.taskHandler.discardTaskRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.taskHandler.discardTaskRequest decode error!!"
			end
			Socket.OnRequestEnd("area.taskHandler.discardTaskRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, discardTaskRequestEncoder, discardTaskRequestDecoder)
end


local function submitTaskRequestEncoder(msg)
	local input = taskHandler_pb.SubmitTaskRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function submitTaskRequestDecoder(stream)
	local res = taskHandler_pb.SubmitTaskResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.submitTaskRequest(c2s_templateId,c2s_kind,c2s_double,c2s_npcId,cb,option)
	local msg = {}
	msg.c2s_templateId = c2s_templateId
	msg.c2s_kind = c2s_kind
	msg.c2s_double = c2s_double
	msg.c2s_npcId = c2s_npcId
	Socket.OnRequestStart("area.taskHandler.submitTaskRequest", option)
	Socket.Request("area.taskHandler.submitTaskRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TaskHandler.lastSubmitTaskResponse = res
			Socket.OnRequestEnd("area.taskHandler.submitTaskRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.taskHandler.submitTaskRequest decode error!!"
			end
			Socket.OnRequestEnd("area.taskHandler.submitTaskRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, submitTaskRequestEncoder, submitTaskRequestDecoder)
end


local function updateTaskStatusRequestEncoder(msg)
	local input = taskHandler_pb.UpdateTaskStatusRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function updateTaskStatusRequestDecoder(stream)
	local res = taskHandler_pb.UpdateTaskStatusResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.updateTaskStatusRequest(c2s_templateId,c2s_kind,cb,option)
	local msg = {}
	msg.c2s_templateId = c2s_templateId
	msg.c2s_kind = c2s_kind
	Socket.OnRequestStart("area.taskHandler.updateTaskStatusRequest", option)
	Socket.Request("area.taskHandler.updateTaskStatusRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TaskHandler.lastUpdateTaskStatusResponse = res
			Socket.OnRequestEnd("area.taskHandler.updateTaskStatusRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.taskHandler.updateTaskStatusRequest decode error!!"
			end
			Socket.OnRequestEnd("area.taskHandler.updateTaskStatusRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, updateTaskStatusRequestEncoder, updateTaskStatusRequestDecoder)
end


local function refreshSoulTaskRequestEncoder(msg)
	local input = taskHandler_pb.RefreshSoulTaskRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function refreshSoulTaskRequestDecoder(stream)
	local res = taskHandler_pb.RefreshSoulTaskResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.refreshSoulTaskRequest(c2s_taskId,cb,option)
	local msg = {}
	msg.c2s_taskId = c2s_taskId
	Socket.OnRequestStart("area.taskHandler.refreshSoulTaskRequest", option)
	Socket.Request("area.taskHandler.refreshSoulTaskRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TaskHandler.lastRefreshSoulTaskResponse = res
			Socket.OnRequestEnd("area.taskHandler.refreshSoulTaskRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.taskHandler.refreshSoulTaskRequest decode error!!"
			end
			Socket.OnRequestEnd("area.taskHandler.refreshSoulTaskRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, refreshSoulTaskRequestEncoder, refreshSoulTaskRequestDecoder)
end


local function getDailySoulFinNumRequestEncoder(msg)
	local input = taskHandler_pb.GetDailySoulFinNumRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function getDailySoulFinNumRequestDecoder(stream)
	local res = taskHandler_pb.GetDailySoulFinNumResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.getDailySoulFinNumRequest(cb,option)
	local input = nil
	Socket.OnRequestStart("area.taskHandler.getDailySoulFinNumRequest", option)
	Socket.Request("area.taskHandler.getDailySoulFinNumRequest", input, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TaskHandler.lastGetDailySoulFinNumResponse = res
			Socket.OnRequestEnd("area.taskHandler.getDailySoulFinNumRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.taskHandler.getDailySoulFinNumRequest decode error!!"
			end
			Socket.OnRequestEnd("area.taskHandler.getDailySoulFinNumRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, getDailySoulFinNumRequestEncoder, getDailySoulFinNumRequestDecoder)
end


local function taskFuncDeskRequestEncoder(msg)
	local input = taskHandler_pb.TaskFuncDeskRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function taskFuncDeskRequestDecoder(stream)
	local res = taskHandler_pb.TaskFuncDeskResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.taskFuncDeskRequest(c2s_ncpId,cb,option)
	local msg = {}
	msg.c2s_ncpId = c2s_ncpId
	Socket.OnRequestStart("area.taskHandler.taskFuncDeskRequest", option)
	Socket.Request("area.taskHandler.taskFuncDeskRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TaskHandler.lastTaskFuncDeskResponse = res
			Socket.OnRequestEnd("area.taskHandler.taskFuncDeskRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.taskHandler.taskFuncDeskRequest decode error!!"
			end
			Socket.OnRequestEnd("area.taskHandler.taskFuncDeskRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, taskFuncDeskRequestEncoder, taskFuncDeskRequestDecoder)
end


local function acceptLoopTaskRequestEncoder(msg)
	local input = taskHandler_pb.AcceptLoopTaskRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function acceptLoopTaskRequestDecoder(stream)
	local res = taskHandler_pb.AcceptLoopTaskResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.acceptLoopTaskRequest(c2s_npcId,cb,option)
	local msg = {}
	msg.c2s_npcId = c2s_npcId
	Socket.OnRequestStart("area.taskHandler.acceptLoopTaskRequest", option)
	Socket.Request("area.taskHandler.acceptLoopTaskRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TaskHandler.lastAcceptLoopTaskResponse = res
			Socket.OnRequestEnd("area.taskHandler.acceptLoopTaskRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.taskHandler.acceptLoopTaskRequest decode error!!"
			end
			Socket.OnRequestEnd("area.taskHandler.acceptLoopTaskRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, acceptLoopTaskRequestEncoder, acceptLoopTaskRequestDecoder)
end


local function acceptDailyTaskRequestEncoder(msg)
	local input = taskHandler_pb.AcceptDailyTaskRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function acceptDailyTaskRequestDecoder(stream)
	local res = taskHandler_pb.AcceptDailyTaskResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.acceptDailyTaskRequest(c2s_npcId,cb,option)
	local msg = {}
	msg.c2s_npcId = c2s_npcId
	Socket.OnRequestStart("area.taskHandler.acceptDailyTaskRequest", option)
	Socket.Request("area.taskHandler.acceptDailyTaskRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TaskHandler.lastAcceptDailyTaskResponse = res
			Socket.OnRequestEnd("area.taskHandler.acceptDailyTaskRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.taskHandler.acceptDailyTaskRequest decode error!!"
			end
			Socket.OnRequestEnd("area.taskHandler.acceptDailyTaskRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, acceptDailyTaskRequestEncoder, acceptDailyTaskRequestDecoder)
end


local function reachTreasurePointRequestEncoder(msg)
	local input = taskHandler_pb.ReachTreasurePointRequest()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

local function reachTreasurePointRequestDecoder(stream)
	local res = taskHandler_pb.ReachTreasurePointResponse()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.reachTreasurePointRequest(point,cb,option)
	local msg = {}
	msg.point = point
	Socket.OnRequestStart("area.taskHandler.reachTreasurePointRequest", option)
	Socket.Request("area.taskHandler.reachTreasurePointRequest", msg, function(res)
		if(res.s2c_code == 200) then
			Pomelo.TaskHandler.lastReachTreasurePointResponse = res
			Socket.OnRequestEnd("area.taskHandler.reachTreasurePointRequest", true)
			cb(nil,res)
		else
			local ex = {}
			if(res.s2c_code) then
				ex.Code = res.s2c_code
				ex.Message = res.s2c_msg
			else
				ex.Code = 501
				ex.Message = "[LuaXmdsNetClient] area.taskHandler.reachTreasurePointRequest decode error!!"
			end
			Socket.OnRequestEnd("area.taskHandler.reachTreasurePointRequest", false,ex.Code,ex.Message)
			cb(ex,nil)
		end
	end, reachTreasurePointRequestEncoder, reachTreasurePointRequestDecoder)
end


local function cjPlayEndNotifyEncoder(msg)
	local input = taskHandler_pb.CjPlayEndNotify()
	protobuf.FromMessage(input,msg)
	return (input:SerializeToString())
end

function Pomelo.TaskHandler.cjPlayEndNotify(s2c_msg)
	local msg = {}
	msg.s2c_msg = s2c_msg
	Socket.Notify("area.taskHandler.cjPlayEndNotify", msg, cjPlayEndNotifyEncoder)
end


local function taskUpdatePushDecoder(stream)
	local res = taskHandler_pb.TaskUpdatePush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.taskUpdatePush(cb)
	Socket.On("area.taskPush.taskUpdatePush", function(res) 
		Pomelo.TaskHandler.lastTaskUpdatePush = res
		cb(nil,res) 
	end, taskUpdatePushDecoder) 
end


local function taskAutoPushDecoder(stream)
	local res = taskHandler_pb.TaskAutoPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.taskAutoPush(cb)
	Socket.On("area.taskPush.taskAutoPush", function(res) 
		Pomelo.TaskHandler.lastTaskAutoPush = res
		cb(nil,res) 
	end, taskAutoPushDecoder) 
end


local function treasureScenePointPushDecoder(stream)
	local res = taskHandler_pb.TreasureScenePointPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.treasureScenePointPush(cb)
	Socket.On("area.taskPush.treasureScenePointPush", function(res) 
		Pomelo.TaskHandler.lastTreasureScenePointPush = res
		cb(nil,res) 
	end, treasureScenePointPushDecoder) 
end


local function loopResultPushDecoder(stream)
	local res = taskHandler_pb.LoopResultPush()
	res:ParseFromString(stream)
	return res
end

function Pomelo.TaskHandler.loopResultPush(cb)
	Socket.On("area.taskPush.loopResultPush", function(res) 
		Pomelo.TaskHandler.lastLoopResultPush = res
		cb(nil,res) 
	end, loopResultPushDecoder) 
end





return Pomelo
