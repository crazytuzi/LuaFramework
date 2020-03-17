--[[
结婚
wangshuai
]]

_G.MarriageModel = Module:new();

--设置自己的婚姻状态
MarriageModel.MarryState = {}
function MarriageModel:SetMarryState(state,marryTime,marryType,marrySchedule,marryDinner)
	self.MarryState.state = state;
	self.MarryState.marryTime = marryTime;
	self.MarryState.marryType = marryType;
	self.MarryState.marrySchedule = marrySchedule;
	self.MarryState.marryDinner = marryDinner;
	self:sendNotification(NotifyConsts.MarryStateChange);
end;

--得到自己的戒指强化属性
function MarriageModel:GetMyStrenLvl()
	return self.MymarryPanelInfo.ringLvl or 0
end;

--得到自己的状态
function MarriageModel:GetMyMarryState()
	return self.MarryState.state;
end;

--得到婚礼时间状态
function MarriageModel:GetMyMarryTime()
	return self.MarryState.marryTime;
end;

--得到婚礼类型状态
function MarriageModel:GetMyMarryType()
	return self.MarryState.marryType;
end;

--得到婚礼迅游状态
function MarriageModel:GetMyMarrySchedule()
	return self.MarryState.marrySchedule;
end;

--得到婚宴状态
function MarriageModel:GetMyMarryDinner()
	return self.MarryState.marryDinner;
end;

--情缘值等级
function MarriageModel:GetQingYuanVal()
	local roleData = self.MymarryPanelInfo
	for i,info in ipairs(t_marryIntimate) do 
		if info.needIntimate > roleData.intimate then 
			return info.level;
		end;
	end;
	return 0
end;

--装备戒指类型
function MarriageModel:GetRingType()
	local roleData = self.MymarryPanelInfo
	for i,info in ipairs(t_marryRing) do 
		if info.itemId == roleData.ringId then
			return info.id;
		end;
	end;
end;


--收到求婚
MarriageModel.BeProposaledData = {}
function MarriageModel:SetBeProposaled(name,loveText,ringId)
	self.BeProposaledData.name = name;
	self.BeProposaledData.loveText = loveText;
	self.BeProposaledData.ringId = ringId;
end;

--婚礼时间预约
MarriageModel.MarryTimeList = {};
MarriageModel.MarryTimeData = 0
function MarriageModel:SetMarryTime(time,list)
	self.MarryTimeList = {};
	self.MarryTimeData = time;
	for i,info in ipairs(list) do 
		local vo = {};
		vo.TimeID = info.TimeID;
		vo.naName = info.naName;
		vo.nvName = info.nvName;
		table.push(self.MarryTimeList,vo)
	end;
end;

--婚礼红包详情
MarriageModel.MarryRedMoney = {};
function MarriageModel:SetMarryRedMoney(list)
	self.MarryRedMoney = {};
	for i,info in ipairs(list) do 
		local vo = {};
		vo.name = info.name;
		vo.num = info.silverNum;
		vo.type = 11;--info.type;
		vo.blessing = info.desc;
		table.push(self.MarryRedMoney,vo)
	end;
end;	

--设置我身上的请柬列表
MarriageModel.MyMarryCardList = {};
function MarriageModel:SetMyMarryCardData(itemId,state,naroleName,nvroleName,naroleprof,nvroleprof,time)
	if not self.MyMarryCardList[itemId] then 
		self.MyMarryCardList[itemId] = {};
	end;
	local vo = {};
	vo.itemId = itemId;
	vo.state = state;
	vo.naroleName = naroleName;
	vo.nvroleName = nvroleName;
	vo.naprof = naroleprof;
	vo.nvprof = nvroleprof;
	vo.time = time;
	self.MyMarryCardList[itemId] = vo;

end

function MarriageModel:GetMarryCardData(itemId)
	--print(itemId,type(itemId))
	--trace(self.MyMarryCardList)
	if self.MyMarryCardList[itemId] then 
		return self.MyMarryCardList[itemId]
	end;
end;

--设置婚礼面板信息
MarriageModel.MymarryPanelInfo = {};
function MarriageModel:SetMyMarryPanelInfo(beRoleName,beUnionName,beProf,lvl,fight,time,MaxDay,intimate,ringId,marryType,ringLvl,newVal)
	self.MymarryPanelInfo.beRoleName = beRoleName
	self.MymarryPanelInfo.beUnionName = beUnionName
	self.MymarryPanelInfo.beProf = beProf
	self.MymarryPanelInfo.lvl = lvl
	self.MymarryPanelInfo.fight = fight
	self.MymarryPanelInfo.time = time
	self.MymarryPanelInfo.MaxDay = MaxDay
	self.MymarryPanelInfo.intimate = intimate
	self.MymarryPanelInfo.ringId = ringId
	self.MymarryPanelInfo.marryType = marryType
	self.MymarryPanelInfo.ringLvl = ringLvl
	self.MymarryPanelInfo.newVal = newVal
end;

--设置婚礼戒指等级
function MarriageModel:SetMarryRingStren(ringLvl,newVal)
	self.MymarryPanelInfo.ringLvl = ringLvl
	self.MymarryPanelInfo.newVal = newVal
end;

--临时玩家婚礼提醒
MarriageModel.BeMarryRemind = {};
function MarriageModel:SetMarryRemind(naroleName,nvroleName,naprof,nvprof)
	self.BeMarryRemind.naroleName = naroleName;
	self.BeMarryRemind.nvroleName = nvroleName;
	self.BeMarryRemind.naprof = naprof;
	self.BeMarryRemind.nvprof = nvprof;
end;

--设置玩家所有戒指信息
MarriageModel.myBagRingList = {}
function MarriageModel:SetMyBagRingInfo(itemId,state)
	if not self.MyMarryCardList[itemId] then 
		self.MyMarryCardList[itemId] = {};
	end;
	local vo = {};
	vo.itemId = itemId;
	vo.state = state;
	self.myBagRingList[itemId] = vo;
end;

--玩家求婚成功，双方显示界面
MarriageModel.ProposaledData = {};
function MarriageModel:SetProposaledData(ringId,naProf,nvProf)
	self.ProposaledData.ringId = ringId;
	self.ProposaledData.naProf = naProf;
	self.ProposaledData.nvProf = nvProf;
end;

--队长开启婚礼仪式
MarriageModel.OpenMarryRoleId = "";
function MarriageModel:SetOpenMarry(roleId)
	self.OpenMarryRoleId = roleId;
end;

--设置自己的结婚信息
MarriageModel.MyCardUseData = {}
function MarriageModel:SetCardUseMyData(beRoleName,time)
	self.MyCardUseData.beRoleName = beRoleName;
	self.MyCardUseData.time = time;
end;