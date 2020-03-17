--[[
运营活动-坐骑首日
2015年3月23日14:17:47
haohu
]]

_G.OperActController = setmetatable( {}, {__index = IController} );
OperActController.name = "OperActController";

function OperActController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_OperAct, self, self.OnOperActRsv );
	MsgManager:RegisterCallBack( MsgType.SC_OperActDeactive, self, self.OnOperActDeactive );
	OperActModel:Init()
end

function OperActController:Update(interval)
	for _, operAct in pairs( OperAct.AllOperAct ) do
		if operAct:GetActive() then
			operAct:Update(interval);
		end
	end
end
----------------------------------------response---------------------------------------------
function OperActController:OnOperActRsv( msg )
	local operActList = msg.list;
	for _, vo in pairs(operActList) do
		OperActModel:SetOperAct( vo.id, vo.state, vo.time, vo.rewardNum );
	end
end

function OperActController:OnOperActDeactive( msg )
	OperActModel:Deactive(msg.id);
end
----------------------------------------request----------------------------------------------
function OperActController:ReqOperActGetReward(id)
	local msg = ReqOperActGetRewardMsg:new();
	msg.id = id;
	MsgManager:Send(msg);
end