--[[
帮派副本-地宫炼狱 model
2015年1月8日15:14:01
haohu
]]

_G.UnionDungeonHellModel = Module:new();

UnionDungeonHellModel.stratumList = nil;
UnionDungeonHellModel.isInHell = false

function UnionDungeonHellModel:UpdateStratumList( stratumList )
	local list = self:GetStratumList();
	for _, vo in pairs(stratumList) do
		vo.state = vo.state == 0; -- 0: 已过关
		vo.bestPass = tostring(vo.bestPass);
		list[vo.id] = vo;
		self:sendNotification( NotifyConsts.GuildHellStratumUpdate, vo.id );
	end
end

function UnionDungeonHellModel:GetStratumList()
	if not self.stratumList then
		self.stratumList = {};
		for id, _ in pairs(t_guildHell) do
			self.stratumList[id] = self:newStratumVO( id );
		end
	end
	return self.stratumList;
end

function UnionDungeonHellModel:GetStratum( stratum )
	local stratumList = self:GetStratumList();
	return stratumList[stratum];
end

function UnionDungeonHellModel:newStratumVO( stratum )
	return {
		id           = stratum, --id：层数
		state        = false; -- 是否已过关
		passTime     = 0, --过关用时
		numPass      = 0, --本周本帮过关人数
		bestPass     = "", -- 最佳通关玩家名字
		bestPassTime = 0 -- 最佳通关用时
	}
end

-- 获取当前可挑战的层
function UnionDungeonHellModel:GetCurrentStratum()
	local list = self:GetStratumList();
	local vo;
	for i = 1, #list do
		vo = list[i];
		if not vo.state then
			return vo.id;
		end
	end
	return UnionHellConsts:GetNumStratum() + 1
end

function UnionDungeonHellModel:IsInHell()
	return self.isInHell
end

function UnionDungeonHellModel:SetInHellState(inHell)
	self.isInHell = inHell
end