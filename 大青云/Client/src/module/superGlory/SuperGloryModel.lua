--[[
至尊王城
wangshuai
]]

_G.SuperGloryModel = Module:new()


SuperGloryModel.SuperGloryInfo = {};
SuperGloryModel.SuperGloryRoleInfo = {};
SuperGloryModel.SuperGloryUnionRoleInfo = {};
SuperGloryModel.timerKey = nil;

function SuperGloryModel:SetSuperGloryInfo(msg)
	self.SuperGloryInfo = {};
	local vo = {};
	vo.isDuke = msg.isDuke;
	vo.cont   = msg.cont;
	vo.worship = msg.worship
	vo.atkName = msg.atkName;
	vo.defName = msg.defName;
	vo.lasttime = msg.lasttime;
	vo.curstate = msg.curstate;
	vo.curBagnum = msg.curBagnum;

	self.SuperGloryInfo = vo;

	self:sendNotification(NotifyConsts.SuperGloryAllInfo);

	if  UISuperGloryView:IsShow() then 
		UISuperGloryView:TimerCountdown()
	end;

end;
-- 得到是否城主
function SuperGloryModel:GetIsDuke()
	return self.SuperGloryInfo.isDuke;
end;
-- 得到礼包数量
function SuperGloryModel:GetRewardNum()
	return self.SuperGloryInfo.curBagnum;
end;
-- Get 全部信息
function SuperGloryModel:GetAllSuperInfo()
	return self.SuperGloryInfo;
end;

-- Get 城主信息
function SuperGloryModel:GetSuperManInfo()
	if not self.SuperGloryRoleInfo[1] then return end;
	return self.SuperGloryRoleInfo[1];
end;
-- Get 人物模型信息
function SuperGloryModel:GetSuperRoleInfo()
	return self.SuperGloryRoleInfo;
end;
-- Get 根据人物id 得到人物模型信息
function SuperGloryModel:GetSuperRoleInfoID(id)
	for i,info in pairs(self.SuperGloryRoleInfo) do 
		if info.roleID == id then 
			return info
		end;
	end;
end;
-- Get 下次开启时间
function SuperGloryModel:GetLastTimer()
	return self.SuperGloryInfo.lasttime
end;
-- Get 当前帮派王城站开启状态
function SuperGloryModel:GetUnionCityWarState()
	return self.SuperGloryInfo.curstate;
end;

--  人物模型list
function SuperGloryModel:SetSuperGloryRoleInfo(list)
	self.SuperGloryRoleInfo = {};
	local vo = {};
	for i,info in pairs(list) do 
		vo[info.ranktype] = info;
	end;
	self.SuperGloryRoleInfo = vo;
	self:sendNotification(NotifyConsts.SuperGloryRoleInfo);
end;
--  帮派成员
function SuperGloryModel:SetSuperGloryUnionRoleinfo(list)
	self.SuperGloryUnionRoleInfo = {};
	local vo = {};
	for i,info in ipairs(list) do 
		info.rewardnum = 0;
		vo[i] = info;

	end;
	self.SuperGloryUnionRoleInfo = vo;
	
	self:sendNotification(NotifyConsts.SuperGloryUnionRoleList);
end;

-- 得到帮派成员
function SuperGloryModel:GetSuperGloryUnionRoleinfo()
	return self.SuperGloryUnionRoleInfo;
end;


-- 拆数组
function SuperGloryModel:GetListPage(list,page)
	local vo = {};
	if page == 0 then 
		for i=1,10 do 
			table.push(vo,list[page+i])
		end;
	else
		for i=1,10 do 
			if i==10 then 
				table.push(vo,list[tonumber((page+1).."0")])
			else
				table.push(vo,list[tonumber(page..i)])
			end;
		end;
	end;
	return vo
end;

function SuperGloryModel:GetListLenght(list)
	if not list then return end;
	if #list <= 0 then return 0 end;
	local lenght = #list/10;
	return math.ceil(lenght)-1;
end;


function SuperGloryModel:InitFun()
	-- 注册TimerEvent
	if self.timerKey then 
		TimerManager:UnRegisterTimer(self.timerKey);
		self.timerKey = nil;
	end;
	--self.timerKey = TimerManager:RegisterTimer(self.Ontimer,1000,0);
end;

function SuperGloryModel:Ontimer()
	local lastTime = SuperGloryModel:GetCurTimer()
	if not lastTime then return end;
	SuperGloryModel:SetCurTimer(lastTime - 1);

	local r,t,s,m = CTimeFormat:sec2formatEx(lastTime)

	if lastTime < 0 then 
		return ;
	end;

end;


function SuperGloryModel:WorshipResult(msg)
	if msg.result == 0 then 
		-- 膜拜成功
	else
		-- 今日膜拜次数达上线
		FloatManager:AddNormal(StrConfig['SuperGlory816']);
	end;
end;