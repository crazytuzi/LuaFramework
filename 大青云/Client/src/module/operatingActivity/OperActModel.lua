--[[
运营活动 Model
2015年3月23日14:25:41
haohu
]]

_G.OperActModel = Module:new();

OperActModel.operActList = {};

function OperActModel:Init()
	for _, operAct in pairs( OperAct.AllOperAct ) do
		OperActModel:AddOperAct(operAct);
	end
end

function OperActModel:GetOperActList()
	return self.operActList;
end

function OperActModel:AddOperAct(operAct)
	self.operActList[operAct:GetId()] = operAct;
end

function OperActModel:GetOperAct( id )
	return self.operActList[id];
end

-- @param id: 运营活动ID
-- @param obtainState: 领取状态
-- @param usedTime: 已用时间
-- @param rewardNum: 返还数量
function OperActModel:SetOperAct( id, obtainState, usedTime, rewardNum )
	local act = self:GetOperAct(id);
	if not act then
		Error("Wrong YunyingHuodong ID from server: "..id);
		return;
	end
	act:SetActive(true); -- 默认为从服务器收到即为激活
	act:SetObtainState( obtainState == 1 ); -- 1:已领取
	act:SetUsedTime( usedTime );
	act:SetRewardNum( rewardNum );
end

function OperActModel:Deactive(id)
	local act = self:GetOperAct(id);
	if not act then
		Error("Wrong YunyingHuodong ID from server: "..id);
		return;
	end
	act:SetActive(false);
end