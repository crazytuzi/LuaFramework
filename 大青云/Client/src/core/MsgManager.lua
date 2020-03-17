--[[
消息管理器
lizhuangzhuang
2014年8月20日10:42:09
]]

_G.classlist['MsgManager'] = 'MsgManager'
_G.MsgManager = {};
_G.MsgManager.objName = 'MsgManager'
MsgManager.listenMap = {};
MsgManager.excludeMsgId = {[8007]=1, [8008]=1, [8012]=1}
--发送消息
function MsgManager:Send(msg)
	if not msg.msgId then
		print('Error:send msg.Cannot find msgId');
		return;
	end
	if not msg.encode then
		print('Error:send msg.Cannot find encode function');
		return;
	end
	local data = msg:encode();
	if isDebug then
		print('Send Msg:'..msg.msgId);
	end
	ConnManager:send(msg.msgId, data);
	msg = nil
	data = nil
end

--注册消息回调
function MsgManager:RegisterCallBack(msgId,obj,func)
	if not msgId then
		print("Error(严重):注册了一个不存在的消息。");
		print(debug.traceback());
		return;
	end
    if not self.listenMap[msgId] then
		self.listenMap[msgId] = {};
	end
	for k,vo in pairs(self.listenMap[msgId]) do
		if vo.obj==obj and vo.func==func then
			print('Error:不能重复注册消息');
			return;
		end
	end
	local vo = {obj=obj, func=func};
	table.push(self.listenMap[msgId],vo);
end

--取消注册消息回调
function MsgManager:UnRegisterCallBack(msgId,obj,func)
	if not self.listenMap[msgId] then
		print('Error:not find callback. MsgId=' .. msgId);
		return;
	end
	for i=#self.listenMap[msgId],1,-1 do
		local vo = self.listenMap[msgId][i];
		if vo.obj==obj and vo.func==func then
			table.remove(self.listenMap[msgId],i);
			return;
		end
	end
	print('Error:not find callback. MsgId=' .. msgId);
end


--处理服务器返回消息
MsgManager.msgTable = {}
function MsgManager:HandleMsg(msgId,data)
	if not MsgMap[msgId] then
		print('Error:cannot find msg in MsgMap.MsgId=' .. msgId);
		_debug:throwException("MsgManager:HandleMsg error "..msgId .. " MsgBuildVersion " .. _G.MsgBuildVersion);
		return;
	end
	if not self.listenMap[msgId] then
		--print('Error:not find callback. listenMap MsgId=' .. msgId);
		return;
	end
	local msgClass = MsgMap[msgId];
	local msg = msgClass:new();
	msg:ParseData(data);
    if not MsgManager.excludeMsgId[msgId] then
		if isDebug then
			print('Receive Msg.MsgID=' .. msgId);
		end
	end
	for k,vo in pairs(self.listenMap[msgId]) do
		vo.func(vo.obj,msg);
	end
	return true;
end