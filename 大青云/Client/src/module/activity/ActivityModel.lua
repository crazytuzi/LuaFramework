--[[
活动Model
lizhuangzhuang
2014年12月4日16:17:47 
]]

_G.ActivityModel = Module:new();

--活动处理类
ActivityModel.classMap = {};
--活动列表
ActivityModel.list = {};
--当前游戏世界等级,记录了游戏中的世界等级，目前通过进入任何一个活动的时候，服务器会通过进入活动协议返回这个等级然后存储在这里。有需要的可以从这里取得  yanghongbin 2016-8-2
ActivityModel.worldLevel = 0;

--注册一个活动处理类
function ActivityModel:RegisterActivityClass(type,clz)
	if self.classMap[type] then
		Debug("Waring:Has find a activity class.type=",type);
		return;
	end
	self.classMap[type] = clz;
end

--获取一个活动处理类
function ActivityModel:GetActivityClass(type)
	return self.classMap[type];
end

--注册一个活动
function ActivityModel:RegisterActivity(activity)
	local id = activity:GetId();
	-- WriteLog(LogType.Normal,true,'-------------houxudongid',id)
	if self.list[id] then
		Debug("Waring:Has find a activity.id=",id);
		return;
	end
	self.list[id] = activity;
end

--获取一个活动
function ActivityModel:GetActivity(id)
	return self.list[id];
end

--获取某个类型的活动
function ActivityModel:GetActivityByType(type)
	local list = {};
	for k,activity in pairs(self.list) do
		if activity:GetType() == type then
			table.push(list,activity);
		end
	end
	return list;
end

--获取活动在哪条线
function ActivityModel:GetActivityLine(id)
	if self.list[id] then
		return self.list[id].line;
	end
	return -1;
end
