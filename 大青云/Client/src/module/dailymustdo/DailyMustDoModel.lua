--[[DailyMustDoModel
zhangshuhui
2015年3月18日14:50:00
]]

_G.DailyMustDoModel = Module:new();

--今日完成列表
DailyMustDoModel.finishdailylist = {};

--申请时的等级
DailyMustDoModel.ReqLevel = 0;

--添加信息
function DailyMustDoModel:AddDailyVo(dailyvo)
	self.finishdailylist[dailyvo.id]  = dailyvo;
end

--更新信息
function DailyMustDoModel:UpdateDailyVo(dailyvo)
	if self.finishdailylist[dailyvo.id] then
		if dailyvo.todaynum then
			self.finishdailylist[dailyvo.id].todaynum = dailyvo.todaynum;
			
			self:sendNotification(NotifyConsts.JinBiBiZuoUpdata,{id=dailyvo.id, type=DailyMustDoConsts.typetoday});
		end
		
		if dailyvo.runnum then
			self.finishdailylist[dailyvo.id].runnum = dailyvo.runnum;
			
			self:sendNotification(NotifyConsts.JinBiBiZuoUpdata,{id=dailyvo.id, type=DailyMustDoConsts.typeyesterday});
		end
	end
end

--今日必做全部完成
function DailyMustDoModel:ClearTodayDaily()
	local list = {};
	for i,vo in pairs(self.finishdailylist) do
		if vo then
			if vo.todaynum > 0 then
				vo.todaynum = 0;
				table.insert(list ,vo.id);
			end
		end
	end
	
	self:sendNotification(NotifyConsts.JinRiBiZuoListUpdata,{type=DailyMustDoConsts.typetoday,list=list});
end

--昨日追回全部完成
function DailyMustDoModel:ClearRunDaily()
	local list = {};
	for i,vo in pairs(self.finishdailylist) do
		if vo then
			if vo.runnum > 0 then
				vo.runnum = 0;
				table.insert(list ,vo.id);
			end
		end
	end
	
	self:sendNotification(NotifyConsts.JinRiBiZuoListUpdata,{type=DailyMustDoConsts.typeyesterday,list=list});
end

--得到信息列表
function DailyMustDoModel:GetDailyList()
	return self.finishdailylist;
end

--得到活动信息
function DailyMustDoModel:GetDailyVo(id)
	return self.finishdailylist[id];
end

--得到申请时的等级
function DailyMustDoModel:GetReqLevel()
	return self.ReqLevel;
end

--设置申请时的等级
function DailyMustDoModel:SetReqLevel(level)
	self.ReqLevel = level;
end