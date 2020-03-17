--[[
顺网平台
wangshuai
2015年11月12日15:24:50
]]

_G.ShunwangContrller = setmetatable({},{__Index = IController});
ShunwangContrller.name = "ShunwangContrller";

function ShunwangContrller:Create()
	MsgManager:RegisterCallBack(MsgType.SC_ShunwangTerrace,self,self.ShunWangReward);  --七日奖励信息
	self:inithahah();
end

function ShunwangContrller:inithahah()
	local vos = {}
	for i=1,5 do 
		local voc = {};
		voc.swlvl = i;
		voc.state = math.random(2) == 1 and 0 or 1;
		table.push(vos,voc)
	end;
end;

function ShunwangContrller:ShunWangReward(msg)
	if msg.result == -1 or msg.result == 0 then 
		ShunwangModel:SetRewardState(msg.rewardList)
		ShunwangModel:SetSwMyVipLvl(msg.swlvl)
		if ShunwangReward:IsShow() then 
			ShunwangReward:OnShowData()
		end;
		UIMainYunYingFunc:DrawLayout();
		if msg.result == 0 then 
			FloatManager:AddNormal(StrConfig["yunying015"]);
		end
	elseif msg.result == -2 then 
		FloatManager:AddNormal(StrConfig["yunying022"]);
	elseif msg.result == -3 then 
		FloatManager:AddNormal(StrConfig["yunying019"]);
	end;
end;

function ShunwangContrller:GetShunwangReward(lvl)
	local msg = ReqShunwangTerraceMsg:new();
	msg.swlvl = lvl;
	ShunwangModel.rewardlist[lvl] = 1;
	MsgManager:Send(msg);
	-- if ShunwangReward:IsShow() then 
	-- 	ShunwangReward:OnShowData()
	-- end;
	-- UIMainYunYingFunc:DrawLayout();
end;

