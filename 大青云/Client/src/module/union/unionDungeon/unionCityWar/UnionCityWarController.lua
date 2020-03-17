--[[
	活动，帮派王城战
	wangshuai
]]
_G.UnionCityWarController = setmetatable({},{__index = IController})
UnionCityWarController.name = "UnionCityWarController"

UnionCityWarController.isChangeLine = 0;
UnionCityWarController.curlineId = 0;
function UnionCityWarController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_UnionCityWarAllInfo, self, self.SetCityWarAllInfo ) -- 8299
	MsgManager:RegisterCallBack( MsgType.SC_UnionCityWarRolejiSha, self, self.SetCityWarRolejiasha ) -- 8300
	MsgManager:RegisterCallBack( MsgType.SC_UnionCityWarSuperState, self, self.SetCityWarSuperState ) -- 8301
	MsgManager:RegisterCallBack( MsgType.WC_UnionEnterCityWar, self, self.EnterScene ) -- 8302
	MsgManager:RegisterCallBack( MsgType.SC_UnionCityWarSuperResult, self, self.CityWarResult ) -- 8302
	--UnionCityWarModel:TestInfo();
	UnionCityWarModel:TimerInit()
end;
	
function UnionCityWarController:OnChangeSceneMap()
	--print("切换场景成功")
	if self.isChangeLine ~= true then return end;
	self.isChangeLine = false;
	if UIUnionAcitvity:IsShow() then 
			UIUnionAcitvity:Hide() ---  尝试关闭提醒
	end;
	-- UnionCityWarModel:EnterScene()
end;
-- 退出帮派战
function UnionCityWarController:Outwar()
	local msg = ReqQuitGuildCityWarMsg:new();
	MsgManager:Send(msg);
	-- 退出场景执行方法
	UnionCityWarModel:OutScene()
end;
-- 进入帮派战
function UnionCityWarController:EnterWar()
	local msg = ReqEnterGuildCityWarMsg:new();
	msg.MapId = 0;
	MsgManager:Send(msg)
	-- 进入场景执行方法
end; 

-- 进入场景
function UnionCityWarController:EnterScene(msg)
	if msg.isopen ~= 0 then 
		FloatManager:AddNormal(StrConfig["unioncitywar823"]);
		return
	end; 
	if msg.isPass ~= 0 then 
		--帮派没有进入权限
		FloatManager:AddNormal(StrConfig['unioncitywar803']);
		return 
	end;
	self.curlineId = msg.lineID;
	local curline = CPlayerMap:GetCurLineID();
	if curline == self.curlineId then
		self:EnterWar();
	else
		MainPlayerController:ReqChangeLine(self.curlineId);
	end;
end;

-- 换线成功
function UnionCityWarController:OnLineChange()
	if self.isChangeLine ~= true then return end;
	if self.curlineId == 0 then return end;
	-- 进入活动
	self:EnterWar()
	self.isChangeLine = false;
end;
--换线失败
function UnionCityWarController:OnLineChangeFail()
	self.isChangeLine = false;
end

-- 信息总览
function UnionCityWarController:SetCityWarAllInfo(msg)
	UnionCityWarModel:SetCityWarAllinfo(msg.SuperMaxHp,msg.time,msg.mytype,msg.atkUnionName,msg.defUnionName)
	-- TimerManager:RegisterTimer(function()
	-- 	UnionCityWarModel:EnterScene()
	-- end,1000,1);
	UnionCityWarModel:EnterScene()
end;

-- 击杀排名
function UnionCityWarController:SetCityWarRolejiasha(msg)
	UnionCityWarModel:SetRolejishaListRank(msg.list)
end;

-- 神像状态
function UnionCityWarController:SetCityWarSuperState(msg)
	-- trace(msg)
	UnionCityWarModel:SetCurWangzuoHp(msg.SuperHp)
	UnionCityWarModel:SetSuperStateList(msg.list)
	--trace(msg.list)


	MapController:CleanUpCurrMap();  -- 清楚无用点
	MapController:DrawCurrMap(); -- 旗子状态改变，重绘地图

end;

function UnionCityWarController:CityWarResult(msg)
	UnionCityWarModel:SetResult(msg)
end;


----------------------C  To  S 
-- 请求进入
function UnionCityWarController:EnterUnionCityWar()
	self.isChangeLine = true;
	local msg = ReqUnionEnterCityWarMsg:new();
	
	local fun = function() 
		MsgManager:Send(msg);
	end;
	if TeamUtils:RegisterNotice(UIUnionDungeonMain,fun) then 
		return
	end;

	MsgManager:Send(msg);
end;

function UnionCityWarController:GetRewardItem()
	local msg = ReqUnionCityWarGetRewardMsg:new()	
	MsgManager:Send(msg);
end;

------------------------进入活动f
function UnionCityWarController:GOGOGOCityWar()
	local mapCfg = t_map[CPlayerMap:GetCurMapID()];
	if not mapCfg then return end;
	if mapCfg.can_teleport == false then 
		FloatManager:AddSysNotice(2005014);--已达上限
		-- FloatManager:AddNormal(StrConfig["unioncitywar824"]);
		return 
	end;

	local unionlvl = UnionModel:GetMyUnionLevel();
	local cfglvl = t_guildActivity[3].guildlv;
	if unionlvl < cfglvl then 
		FloatManager:AddNormal(StrConfig["unionwar225"]);
		return 
	end;
	UnionCityWarController:EnterUnionCityWar()
end;

