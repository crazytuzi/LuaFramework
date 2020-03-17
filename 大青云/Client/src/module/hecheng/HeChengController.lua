--[[
道具合成管理
zhangshuhui
2014年12月27日15:20:20
]]
_G.HeChengController = setmetatable({},{__index=IController})

HeChengController.name = "HeChengController";

function HeChengController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_ToolHeCheng,self,self.OnToolHeChengResult);
	MsgManager:RegisterCallBack(MsgType.SC_WingHeCheng,self,self.OnWingHeChengResult);
	MsgManager:RegisterCallBack(MsgType.SC_WingTimePass,self,self.OnWingTimePass);
end

---------------------------以下为客户端发送消息-----------------------------
-- 请求合成道具
function HeChengController:ReqToolHeCheng(ToolId,type,count)
	--print('======请求合成道具')
	--trace(msg)

	local msg = ReqToolHeChengMsg:new()
	msg.Id = ToolId;
	msg.type = type;
	msg.count = count;
	MsgManager:Send(msg)
end

-- 请求合成翅膀
function HeChengController:ReqWingHeCheng(itemid,list)
	local msg = ReqWingHeChengMsg:new()
	msg.wingid = itemid;
	msg.list = list;
	MsgManager:Send(msg)
	
	-- print('======请求合成翅膀')
	-- trace(msg)
end

---------------------------以下为处理服务器返回消息-----------------------------
-- 返回道具合成信息
function HeChengController:OnToolHeChengResult(msg)
	-- print("============返回道具合成信息")
	-- trace(msg)
	
	if msg.result == 0 then
		self:sendNotification(NotifyConsts.ToolHeChengInfo,{Id=msg.Id, type=msg.type});
	end
end

-- 返回翅膀合成信息
function HeChengController:OnWingHeChengResult(msg)
	-- print("============返回翅膀合成信息")
	
	if msg.result == 0 then
		FloatManager:AddNormal( StrConfig["hecheng28"]);
		HeChengModel:ClearRantItemList();
		self:sendNotification(NotifyConsts.ToolHeChengInfo);
	elseif msg.result == 1 then
		FloatManager:AddNormal( StrConfig["hecheng31"]);
	elseif msg.result == 2 then
		FloatManager:AddNormal( StrConfig["hecheng29"]);
	elseif msg.result == 3 then
		FloatManager:AddNormal( StrConfig["hecheng32"]);
	elseif msg.result == 4 then
		FloatManager:AddNormal( StrConfig["hecheng33"]);
	end
end

-- 翅膀过期通知
function HeChengController:OnWingTimePass(msg)
	if 1 then return end
	UIWingPassRenewView:Open(msg.id);
end