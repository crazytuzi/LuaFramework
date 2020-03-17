--[[
HuoYueDuUtil
jiayong
2015年2月2日20:51:50
]]

_G.HuoYueDuUtil = {};

function HuoYueDuUtil:GetAttrResource()
	local templist = {}
	for i, info in ipairs(t_xianjielv) do
		local temp = info.ui_sen
		if not templist[temp] then
			templist[temp] = info.lv;
		end;
	end;
	for j, vo in pairs(templist) do
		local obj = {}
		obj.sen = j;
		obj.level = vo;
		table.push(HuoYueDuConsts.GetLevel, obj);
	end

	table.sort(HuoYueDuConsts.GetLevel, function(A, B)
		if A.level < B.level then
			return true;
		else
			return false;
		end
	end);
end

function HuoYueDuUtil:GetAttrIndex(level)
	local temp = 0;
	local str = t_xianjielv[level].ui_sen;
	for i, info in ipairs(HuoYueDuConsts.GetLevel) do
		if info.sen == str then
			temp = i

			break;
		end
	end

	return temp
end

--战斗力
function HuoYueDuUtil:GetAttrMap(level)
	local cfg = t_xianjielv[level]
	if not cfg then return; end
	return AttrParseUtil:ParseAttrToMap(cfg.prop)
end

function HuoYueDuUtil:GetCfgList()
	local cfgList = t_xianjie;
	local templist = {};
	local playerinfo = MainPlayerModel.humanDetailInfo;
	for i, info in ipairs(cfgList) do
		if playerinfo.eaLevel > info.level then
			local vo = {};
			vo.id = info.id
			vo.name = info.name;
			vo.level = info.level;
			vo.count = info.count;
			vo.num = info.num
			vo.level_up = info.level_up;
			vo.plus = info.plus;
			vo.fly = info.fly;
			table.push(templist, vo)
		end
	end
	table.sort(templist, function(A, B)
		if A.id < B.id then
			return true;
		else
			return false;
		end
	end);
	return templist;
end

function HuoYueDuUtil:GetHuoYueDuList()

	local cfgList = self:GetCfgList();
	local uilist = {};
	local playerinfo = MainPlayerModel.humanDetailInfo;

	for i, info in ipairs(cfgList) do

		local vo = {};
		local moneyicon = {};
		vo.level = info.level;
		vo.plus = info.plus;
		local serverData = HuoYueDuModel:GetIndexHuoyuelist(info.id);
		vo.id = info.id;
		vo.type = 1;
		if serverData then
			vo.taskname = string.format(StrConfig['huoyuedu1'], info.name);
			vo.count = serverData.num .. "/" .. info.count;
			vo.num = info.num;
			if serverData.num == info.count then
				vo.type = 0;
			end
		else
			vo.taskname = info.name;
			vo.count = "0/" .. info.count;
			vo.num = info.num;
		end;
		if playerinfo.eaLevel > info.level then
			table.insert(uilist, vo);
		end
	end;

	table.sort(uilist, function(A, B)

		if A.type == B.type then
			if A.level < B.level then
				return true;
			else
				return false;
			end
		else
			if A.type > B.type then
				return true;
			else
				return false;
			end
		end
	end);

	local list = {};
	local index = 0
	for i, vo in pairs(uilist) do
		if vo.type == 0 and index == 0 then
			index = 1
			table.insert(list, UIData.encode({ title = true }))
		end
		table.insert(list, UIData.encode(vo));
	end
	return list;
end

function HuoYueDuUtil:GetMaxModelLevel()
	local level = HuoYueDuModel:GetHuoyueLevel() or 0
	if level < HuoYueDuUtil:GetMaxLevel() then
		return true;
	else
		return false
	end
end

--查找下个模型等级
function HuoYueDuUtil:GetLevelOpenModel()
	local level = math.max(HuoYueDuModel:GetHuoyueLevel(), 1)
	local currentlevel = t_xianjielv[level]

	if not currentlevel then return; end
	for level, info in ipairs(t_xianjielv) do

		if t_xianjielv[level] then
			if currentlevel.title == t_xianjielv[#t_xianjielv].title then
				return nil;
			elseif currentlevel.title < t_xianjielv[level].title then
				return level
			end
		end
	end
end

--- - 仙阶等级上限
local maxlv;
function HuoYueDuUtil:GetMaxLevel()
	if not maxlv then
		maxlv = 0;
		for lv, vo in pairs(t_xianjielv) do
			maxlv = math.max(lv, maxlv)
		end
	end
	return maxlv;
end