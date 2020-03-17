--[[
	2016年1月4日11:12:03
	wangyanwei
]]

_G.HallowsController = setmetatable({},{__index=IController});
HallowsController.name = "HallowsController";

function HallowsController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_BackHallows  		,self,self.OnBackHallows);			--服务器返回：圣灵镶嵌信息
	MsgManager:RegisterCallBack(MsgType.SC_InlayHallowsResult   ,self,self.OnInlayHallowsResult);	--圣灵镶嵌返回
	MsgManager:RegisterCallBack(MsgType.SC_PeelHallowsResult  	,self,self.OnPeelHallowsResult);	--圣灵剥离返回
end;

--服务器返回：圣灵镶嵌信息
function HallowsController:OnBackHallows(msg)
	local hallowslist = msg.hallowslist;
	HallowsModel:HallowsData(hallowslist);
	Notifier:sendNotification(NotifyConsts.HallowsUpData);
end

--圣灵镶嵌返回
function HallowsController:OnInlayHallowsResult(msg)
	local result = msg.result;
	if result == -1 then
		FloatManager:AddNormal( StrConfig['hallows1'] );
	elseif result == -2 then
		FloatManager:AddNormal( StrConfig['hallows2'] );
	elseif result == -3 then
		FloatManager:AddNormal( StrConfig['hallows3'] );
	end
end

--圣灵剥离返回
function HallowsController:OnPeelHallowsResult(msg)
	local result = msg.result;
	if result == -1 then
		FloatManager:AddNormal( StrConfig['hallows1'] );
	elseif result == -2 then
		FloatManager:AddNormal( StrConfig['hallows4'] );
	elseif result == -3 then
		FloatManager:AddNormal( StrConfig['hallows5'] );
	end
end

--------      C to S       ---------

--请求信息
function HallowsController:SendHallows()
	local msg = ReqSendHallowsMsg:new();
	MsgManager:Send(msg);
end

--请求镶嵌
function HallowsController:InlayHallows(id,guid)
	local msg = ReqInlayHallowsMsg:new();
	msg.id = id;
	msg.guid = guid;
	MsgManager:Send(msg);
end

--请求剥离
function HallowsController:PeelHallows(id,index)
	local msg = ReqPeelHallowsMsg:new();
	msg.id = id;
	msg.index = index;
	MsgManager:Send(msg);
end