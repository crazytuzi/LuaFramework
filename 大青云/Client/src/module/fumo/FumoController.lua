--[[
图鉴管理
chenyujia
2016-5-18
]]
_G.FumoController = setmetatable({},{__index=IController})
FumoController.name = "FumoController";

function FumoController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_FuMoUpdate,self,self.OnFumoInfoUpdate);
	MsgManager:RegisterCallBack(MsgType.SC_FuMoOperResult,self,self.OnLvUpResult);
	
	FumoModel:initData()
end

---------------------------以下为客户端发送消息-----------------------------
-- 请求获取奖励
function FumoController:ReqGetHuoYueReward(nType, id, cost_num)
	local msg = ReqFuMoOperMsg:new()
	msg.oper = nType;
	msg.id = id;
	msg.cost_num = cost_num;
	MsgManager:Send(msg)
end

--- 服务器消息返回
function FumoController:OnFumoInfoUpdate(msg)
	--msg.fmlist
	--id
	--lv
	--used_num
	for k, v in pairs(msg.fmlist) do
		FumoModel:UpdataData(v)
	end
	return true
end

--- 激活升级返回
function FumoController:OnLvUpResult(msg)
	--msg.result
	--msg.oper
	--msg.id
	self:sendNotification(NotifyConsts.FumoLvUpResult, {msg.id})

	RemindFuncController:RemoveFailPreshow();
	return true
end