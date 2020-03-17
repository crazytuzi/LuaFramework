--[[
fumo类
chenyujia
2016-5-18
]]

_G.Fumo = {};

function Fumo:new(id, cfg)
	local obj = setmetatable({}, {__index = self});
	obj.id = id
	obj.lv = -1 --这里初始化-1代表未激活
	obj.cfg = cfg --配置信息
	obj.count = 0 --当前培养进度
	obj.maxLv = nil --最大等级
	return obj;
end

function Fumo:GetId()
	return self.id
end

function Fumo:GetPage()
	return toint(self.cfg.belongTabs)
end

function Fumo:GetLv()
	return self.lv
end

function Fumo:GetShowLv()
	return self.lv + 1
end

function Fumo:SetLv(lv)
	self.lv = lv
end

function Fumo:GetCfg()
	return self.cfg
end

function Fumo:SetCount(count)
	self.count = count
end

function Fumo:GetCount()
	return self.count
end

function Fumo:GetMap()
	return self.cfg.map
end

function Fumo:IsActive()
	return self.lv > -1
end

function Fumo:getMapID()
	return self:GetCfg().mapid
end

function Fumo:GetLvCfg()
	return t_fomolv[self.id * 1000 + self.lv]
end

function Fumo:GetNextLvCfg()
	return t_fomolv[self.id * 1000 + self.lv + 1]
end

function Fumo:bCanLvUp()
	local cfg = self:GetNextLvCfg()
	if not cfg then return false end
	local intemNum = BagModel:GetItemNumInBag(cfg.num)

	if self.lv == -1 then
		return intemNum >= cfg.upgrade, 1
	else
		return intemNum > 0, 2
	end
end

function Fumo:GetPro()
	local cfg = self:GetLvCfg()
	if not cfg then
		cfg = self:GetNextLvCfg()
		local list = AttrParseUtil:Parse(cfg.att)
		for k, v in pairs(list) do
			list[k].val = 0
		end
		return list
	else
		return AttrParseUtil:Parse(cfg.att)
	end
end

function Fumo:GetNextPro()
	local cfg = self:GetNextLvCfg()
	return AttrParseUtil:Parse(cfg.att)
end

function Fumo:GetMaxLv()
	if self.maxLv then
		return self.maxLv
	end
	local lv = 0
	while (t_fomolv[self.id * 1000 + lv + 1]) do
		lv = lv + 1
	end
	self.maxLv = lv + 1
	return self.maxLv
end

function Fumo:GetMaxProVal(i)
	return AttrParseUtil:Parse(t_fomolv[self.id * 1000 + self:GetMaxLv() - 1].att)[i].val
end

function Fumo:AskFumoLvUp()
	local cfg = self:GetNextLvCfg()
	if not cfg then 
		FloatManager:AddNormal(StrConfig['fumo111']);--道具不足
		return false;
	end
	local intemNum = BagModel:GetItemNumInBag(cfg.num)

	if self.lv == -1 then
		if intemNum >= cfg.upgrade then
			FumoController:ReqGetHuoYueReward(1, self.id, cfg.upgrade)
			return true;
		end
		FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
	else
		if intemNum > 0 then
			FumoController:ReqGetHuoYueReward(2, self.id, math.min(intemNum, cfg.upgrade - self.count))
			return true;
		end
		FloatManager:AddNormal(StrConfig["equip507"]);--道具不足
	end
	return false;
end

function Fumo:GetCost()
	local cfg = self:GetNextLvCfg()
	if cfg then
		return cfg.num, BagModel:GetItemNumInBag(cfg.num)
	end
end

function Fumo:GotoTheMonster()
	if not self:IsCanFly() then
		FuncManager:OpenFunc(self:GetCfg().funid)
		return
	end

	local posCfg = split(t_position[self:GetCfg().pos].pos,'|');
	local myPos = posCfg[1];
	
	local point = split(myPos,",");
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MainPlayerController:DoAutoRun(tonumber(point[1]), _Vector3.new(tonumber(point[2]),tonumber(point[3]),0),completeFuc);
end

function Fumo:FlytoTheMonster()
	local posCfg = split(t_position[self:GetCfg().pos].pos,'|');
	local myPos = posCfg[1];
	
	local point = split(myPos,",");
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle();
	end
	MapController:Teleport(MapConsts.Teleport_Map, completeFuc, tonumber(point[1]), tonumber(point[2]), tonumber(point[3]))
end

function Fumo:IsCanFly()
	if self:GetCfg().pos and self:GetCfg().pos ~= 0 then
		return true
	else
		return false
	end
end