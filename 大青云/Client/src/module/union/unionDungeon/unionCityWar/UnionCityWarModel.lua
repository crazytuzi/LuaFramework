--[[
帮派王城战
wangshuai
]]
_G.UnionCityWarModel = Module:new()

UnionCityWarModel.timerKey = nil;
UnionCityWarModel.cityWarinfo = {};
UnionCityWarModel.cityWarRoleJishaList = {};
UnionCityWarModel.citySuperState = {};
UnionCityWarModel.cityResult = 0;

UnionCityWarModel.isAtCityWarActivity = false;

function UnionCityWarModel:GetIsAtUnionActivity()
	return self.isAtCityWarActivity;
end;

function UnionCityWarModel:TimerInit()
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end;
	self.timerKey = TimerManager:RegisterTimer(self.OnTimer,1000,0)
end;

function UnionCityWarModel:EnterScene()
	-- 进入场景
	if UIUnionAcitvity:IsShow() then 
		UIUnionAcitvity:Hide() ---  尝试关闭提醒
	end;
	if UISuperGloryView:IsShow() then 
		UISuperGloryView:Hide(); 
	end;
	UIUnionManager:Hide();
	ChatController:CloseCampChat();
	UIUnionWarCityRight:Show();
		 -- 开始计时
	 self:TimerInit();
	 MainMenuController:HideRightTop()
	 self.isAtCityWarActivity = true;
end;

function UnionCityWarModel:OutScene()
	-- 退出场景
	UIUnionWarCityRight:Hide();
	MainMenuController:UnhideRightTop()
	self.isAtCityWarActivity = false;
end;

-- 计时器
function UnionCityWarModel:OnTimer()
	if not UnionCityWarModel.cityWarinfo.time then return end;
	local time = UnionCityWarModel.cityWarinfo.time;
	time = time -1 ;
	if time < 0 then 
		time = 0;
	end;
	UnionCityWarModel.cityWarinfo.time = time;
	--  刷新时间
	UIUnionWarCityRight:SetCurLastTimer()
end;

-- 设置一次性数据
function UnionCityWarModel:SetCityWarAllinfo(SuperMaxHp,time,mytype,atkUnionName,defUnionName)
	self.cityWarinfo = {};
	local vo = {};
	vo.superMaxHp = SuperMaxHp;
	vo.time = time;
	vo.mytype = mytype;
	vo.atkUnionName = atkUnionName;
	vo.defUnionName = defUnionName;
	self.cityWarinfo = vo;
	self:sendNotification(NotifyConsts.CityUnionWarAllInfoUpdata);
end;

function  UnionCityWarModel:GetUnionName(type)
	if type == 1 then  
		return self.cityWarinfo.atkUnionName;
	elseif type ==  2 then 
		return self.cityWarinfo.defUnionName;
	end;
end;

-- 设置王座血量
function UnionCityWarModel:SetCurWangzuoHp(vlu)
	self.cityWarinfo.superHp = vlu;
end;

function UnionCityWarModel:SetRolejishaListRank(list)
	self.cityWarRoleJishaList = {};
	for i,info in ipairs(list) do 
		local vo = info;
		self.cityWarRoleJishaList[i] = vo;
		self.cityWarRoleJishaList[i].rank = i;
	end;
	--[[
	local vo = {};
	vo.rank = 100;
	vo.jisha = 999;
	vo.RoleID = "1114120_1425887764";
	vo.type = math.random(2);
	table.push(self.cityWarRoleJishaList,vo)]]
	-- 击杀更新
	self:sendNotification(NotifyConsts.CityUnionWarJishaListUpdata);
end;

-- 根据人物id 取，击杀信息，
function UnionCityWarModel:GetRoleInfo(id)
	for i,info in ipairs(self.cityWarRoleJishaList) do 
		if id == info.RoleID then 
			return info;
		end;
	end;
end;

-- 设置，神像归属，
function UnionCityWarModel:SetSuperStateList(list)
	self.citySuperState = {};
	for i,info in ipairs(list) do 
		local vo ={};
		vo.state = info.state;
		
		vo.unionName = self:GetUnionName(info.state);
		self.citySuperState[i] = vo;
	end;
	-- 建筑物更新
	self:sendNotification(NotifyConsts.CityUnionWarSuperState);
end;

-- 获取神像状态， 1=青龙,2=白虎,3=朱雀,4=玄武 5=王座
function UnionCityWarModel:GetLifePointState(type)
	if not self.citySuperState[type] then return 2 end;
	return self.citySuperState[type].state;
end;

function UnionCityWarModel:GetTime(time)
	local t,s,m,sc = CTimeFormat:sec2formatEx(time);
	
	if t < 10 then
		t= "0"..t;
	end;
	if s < 10 then 
		s = "0"..s;
	end;
	if m < 10 then 
		m = "0"..m;
	end;
	if sc < 10 then 
		sc = "0"..sc;
	end;
	return string.format(StrConfig["unioncitywar806"],s,m,sc)
end;

function UnionCityWarModel:GetLifePointCfg(type)
	for i,info in ipairs(unioncityWarlifePoint) do 
		if info.type == type then 
			return i;
		end;
	end;
end;

function UnionCityWarModel:SetResult(msg)
	-- trace(msg)
	-- print("结果")
	local result = msg.type..msg.result;
	-- 10 进攻方胜利 20 防守方胜利 11 进攻方失败 21 防守方失败
	self.cityResult = result;
	self:sendNotification(NotifyConsts.CityUnionWarResult);
end;

function UnionCityWarModel:GetResult()
	return self.cityResult;
end;