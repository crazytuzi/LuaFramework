--
-- Author: LaoY
-- Date: 2018-06-28 16:05:52
--

BaseController = BaseController or class("BaseController")


-- 网络状态
BaseController.MsgState = {
	Null = 0,
	Verify = 1,
	Select = 2,
	Normal = 3,
}
BaseController.CusMsgState = BaseController.MsgState.Verify
BaseController.LockMsgList = {
	[BaseController.MsgState.Verify] = {
		[1001001] = true,
		[1001005] = true,
		[1000002] = true,
		[1000005] = true,
	},
	[BaseController.MsgState.Select] = {
		[1001001] = true,
		[1001005] = true,
		[1001002] = true,
		[1001003] = true,
		[1001004] = true,
		[1000002] = true,
		[1000005] = true,
		[1000020] = true,
	},
}

function BaseController:ctor()
	-- BaseController.Instance = self
	self.pb_module_name = nil

	local function call_back()
		if self.GameStart then
			self:GameStart()
		end
	end
	GlobalEvent:AddListener(EventName.GameStart, call_back)
end

function BaseController:dctor()
end

function BaseController:GetInstance()
	-- if not BaseController.Instance then
	-- 	BaseController.new()
	-- end
	-- return BaseController.Instance
end

--pb 相关 默认用的是protobuf
function BaseController:GetPbObject(pb_func_name,pb_module_name)
	pb_module_name = pb_module_name or self.pb_module_name
	if not pb_module_name then
		logError(string.format("pb_module_name is nil ,then class is %s,then pb function name is %s",self.__cname,pb_func_name))
	end
	if not _G[pb_module_name] or not _G[pb_module_name][pb_func_name] then
		logError(string.format("then pb function is Non-existent,the name is %s",pb_func_name))
	end
	return _G[pb_module_name][pb_func_name]()
end

-- 添加pblua数组,add()
function BaseController:WriteMsg(proto_id,pb_object)
	-- print("------------BaseController:WriteMsg--------",proto_id)
	local lockMsg = BaseController.LockMsgList[BaseController.CusMsgState]
	if lockMsg and not lockMsg[proto_id] then
		return
	end
	if pb_object then
		local msg = pb_object:SerializeToString()
		-- print("msg______" .. msg)
		NetManager:GetInstance():SendMessage(proto_id,"p",msg)
	else
		NetManager:GetInstance():SendMessage(proto_id)
	end
end

--[[
	@author LaoY
	@des	解析后端返回的protobuf 补充：release版本 测试 use_pb_message 写死true
	@param1 param1
	@param2 use_pb_message 使用pblua生成的结构体，不用转化过后的lua表
	@return number
--]]
function BaseController:ReadMsg(pb_func_name,pb_module_name,use_pb_message)
	if not NetManager.HandleMsg then
		return
	end
	local data = NetManager:GetInstance():ReadMessage("p")
	local pb_object = self:GetPbObject(pb_func_name,pb_module_name)
	pb_object:ParseFromString(data)
	return use_pb_message and pb_object or ProtoStruct2Lua(pb_object)
end

--二进制相关
function BaseController:WriteBinaryMsg(proto_id,fmts,...)
	NetManager:GetInstance():SendMessage(proto_id,fmts,...)
end

function BaseController:ReadBinaryMsg(fmts)
	return NetManager:GetInstance():ReadMessage(fmts)
end

function BaseController:RegisterProtocal(proto_id,class_func)
    NetManager:GetInstance():Register(proto_id,handler(self,class_func))
end

function BaseController:AddEvents()
	
end
