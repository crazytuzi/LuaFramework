XuanBaoManager = {}

local config = {};
local cfgs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_XUANBAO);
local _insert = table.insert;
local _sort = table.sort;

function XuanBaoManager.InitCfg()
	config = {};
	for k, v in pairs(cfgs) do
		if not config[v.type] then config[v.type] = {} end;
		_insert(config[v.type], v);
	end

	for k,v in pairs(config) do
		_sort(v, function(a,b) return a.id < b.id end);
	end
end

XuanBaoManager.hasAward = false;

function XuanBaoManager.SetNotify(data)
	XuanBaoManager.hasAward = data.f > 0;
	MessageManager.Dispatch(XuanBaoNotes, XuanBaoNotes.RSP_AWARD_CHG);
end

local award = {};
local typeSt = {};
function XuanBaoManager.Init(data)
	XuanBaoManager.SetData(data);

	MessageManager.Dispatch(XuanBaoNotes, XuanBaoNotes.RSP_INFO);
end

function XuanBaoManager.SetData(data)
	award = {};
	typeSt = {};

	for i, v in ipairs(data.l) do
		award[v.id] = v;
	end

	for i, v in ipairs(data.dl) do
		typeSt[v.id] = v;
	end


end

function XuanBaoManager.GetAwrad(id)
	return award[id];
end
function XuanBaoManager.GetAwradSt(id)
	return award[id] and award[id].st or 0;
end

function XuanBaoManager.GetTypeAwardSt(id)
	return typeSt[id] and typeSt[id].st or 0;
end

function XuanBaoManager.GetTypeList(type)
	local list = config[type] or {};
	_sort(list, XuanBaoManager.SortFun);
	return list;
end

function XuanBaoManager.SortFun(a, b)
	local st1 = XuanBaoManager.GetAwradSt(a.id);
	local st2 = XuanBaoManager.GetAwradSt(b.id);
	if st1 == 2 then st1 = -1 end
	if st2 == 2 then st2 = -1 end
	if st1 == st2 then
		return a.id < b.id;
	end
	return st1 > st2;
end

function XuanBaoManager.GetRedPoint()
	if XuanBaoManager.hasAward then
		return true;
	end

	for k ,v in pairs(config) do
		if XuanBaoManager.GetTypeRedPoint(k) then
			return true;
		end
	end

	return false;
end

function XuanBaoManager.GetTypeRedPoint(id)
	local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_XUANBAOTYPE)[id];
	
	--未开启
	--Warning(cfg.activation .. " " .. XuanBaoManager.GetTypeAwardSt(cfg.activation))
	if cfg.activation > 0 and XuanBaoManager.GetTypeAwardSt(cfg.activation) <= 1 then
		return false;
	end

	--Warning(XuanBaoManager.GetTypeAwardNum(id));
	return XuanBaoManager.GetTypeAwardNum(id) > 0 or 
	( XuanBaoManager.GetTypeAwardSt(id) < 2 and XuanBaoManager.GetTypeFinishNum(id) >= cfg.num );
end

--获取类型可领取数量
function XuanBaoManager.GetTypeAwardNum(id)
	local num = 0;
	local cfgs = config[id];
	for i,v in ipairs(cfgs) do
		if award[v.id] and award[v.id].st == 1 then
			num = num + 1;
		end
	end
	return num;
end
--获取类型完成数量
function XuanBaoManager.GetTypeFinishNum(id)
	local num = 0;
	local cfgs = config[id];
	for i,v in ipairs(cfgs) do
		if award[v.id] and award[v.id].st > 0 then
			num = num + 1;
		end
	end
	return num;
end
--获取某类型某ID状态
function XuanBaoManager.SetAwardStatus(id, st)
	local item = award[id];

	if item then
		item.st = 2;
		XuanBaoManager.hasAward = false;
		MessageManager.Dispatch(XuanBaoNotes, XuanBaoNotes.RSP_AWARD_CHG);
	end
end
