--[[
冰魂管理
zhangshuhui
2015年9月24日11:09:16
]]
_G.BingHunController = setmetatable({},{__index=IController})
BingHunController.name = "BingHunController";

function BingHunController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_BingHunInfo,self,self.OnBingHunInfoResult);
	MsgManager:RegisterCallBack(MsgType.SC_BingHunVOUpdate,self,self.OnBingHunVOUpdate);
	MsgManager:RegisterCallBack(MsgType.SC_BingHunChangeModel,self,self.OnBingHunChangeModelRet);
end

---------------------------以下为客户端发送消息-----------------------------
-- 请求使用冰魂
function BingHunController:ReqBingHunChangeModel(id)
	local msg = ReqBingHunChangeModelMsg:new()
	msg.id = id;
	MsgManager:Send(msg)
	
	print('===============请求使用冰魂')
	trace(msg)
end

---------------------------以下为处理服务器返回消息-----------------------------
-- 返回冰魂信息
function BingHunController:OnBingHunInfoResult(msg)
	print('===============返回冰魂信息')
	trace(msg)
	BingHunModel:SetBingHunSelect(msg.selectid);
	local list = {};
	for i,binghunvo in pairs(msg.BingHunList) do
		local vo = {};
		vo.id = binghunvo.id;
		vo.time = binghunvo.time;--激活时的时间
		list[vo.id] = vo;
	end
	BingHunModel:SetBingHunList(list);
end

--服务端通知:冰魂到期或者有新的冰魂激活
function BingHunController:OnBingHunVOUpdate(msg)
	print('===============服务端通知:冰魂到期或者有新的冰魂激活')
	trace(msg)
	
	local vo = {};
	vo.id = msg.id;
	vo.time = msg.time;
	BingHunModel:UpdateBingHun(vo);
	
	if msg.time ~= 0 then
		self:ReqBingHunChangeModel(msg.id);
	end
end

--服务器通知:冰魂换模型结果
function BingHunController:OnBingHunChangeModelRet(msg)
	print('===============服务器通知:冰魂换模型结果')
	trace(msg)
	
	if msg.id >= 0 then
		BingHunModel:SetBingHunSelect(msg.id);
	end
end