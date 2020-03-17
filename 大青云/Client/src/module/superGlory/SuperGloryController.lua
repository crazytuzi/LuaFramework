--[[
至尊王城
wangshuai
]]
_G.SuperGloryController = setmetatable({},{__index = IController});
SuperGloryController.name = "SuperGloryController"

function SuperGloryController:Create()
	MsgManager:RegisterCallBack( MsgType.WC_GetSuperGloryinfo, self, self.SuperGloryInfo ) -- 7122
	MsgManager:RegisterCallBack( MsgType.WC_GetSuperGloryRoleinfo, self, self.SuperGloryRoleInfo ) -- 7123
	MsgManager:RegisterCallBack( MsgType.WC_SuperGloryUnionRole, self, self.SuperGloryUnionRoleInfo ) -- 7125
	MsgManager:RegisterCallBack( MsgType.WC_SuperGloryWorshipResult, self, self.SuperGloryWorshipResult ) -- 7125

	MsgManager:RegisterCallBack( MsgType.WC_SuperGlorySendBagUp, self, self.SuperGlorySendBagUpResult ) -- 7126
	MsgManager:RegisterCallBack( MsgType.WC_SuperGlorySetDeputy, self, self.SuperGlorySetDeputyResult ) -- 7128
	SuperGloryModel:InitFun()
end;

--  
function SuperGloryController:SuperGlorySendBagUpResult(msg)
	if msg.result == 0 then 
		FloatManager:AddNormal(StrConfig['SuperGlory821']);
	elseif msg.result == 1 then 
		FloatManager:AddNormal(StrConfig['SuperGlory822']);
	elseif msg.result == 3 then 
		FloatManager:AddNormal(StrConfig['SuperGlory823']);
	end;
end;

function SuperGloryController:SuperGlorySetDeputyResult(msg)
	if msg.result == 0 then 
		FloatManager:AddNormal(StrConfig['SuperGlory824']);
	elseif msg.result == 1 then 
		FloatManager:AddNormal(StrConfig['SuperGlory825']);
	elseif msg.result == 2 then 
		FloatManager:AddNormal(StrConfig['SuperGlory826']);
	elseif msg.result == 3 then 
		FloatManager:AddNormal(StrConfig['SuperGlory827']);
	end;
end;

-- 膜拜结果
function SuperGloryController:SuperGloryWorshipResult(msg)
	SuperGloryModel:WorshipResult(msg)
end;
-- 得到总信息
function SuperGloryController:SuperGloryInfo(msg)
	-- trace(msg)
	-- print("得到总信息")
	SuperGloryModel:SetSuperGloryInfo(msg)
end;
-- 得到帮派成员
function SuperGloryController:SuperGloryUnionRoleInfo(msg)
	 -- trace(msg)
	 -- print("得到帮派成员")
	SuperGloryModel:SetSuperGloryUnionRoleinfo(msg.roleList)
end;
-- 得到人物模型
function SuperGloryController:SuperGloryRoleInfo(msg)
	-- trace(msg)
	-- print("得到人物模型")
	SuperGloryModel:SetSuperGloryRoleInfo(msg.roleList)
end;

---------------------c to w 
-- 请求总信息
function SuperGloryController:ReqSuperGloryRoleinfo()
	-- print("请求总信息")
	local msg = ReqSuperGloryRoleinfoMsg:new();	
	MsgManager:Send(msg)
end;

-- 膜拜城主
function SuperGloryController:ReqSuperGloryWroship()
	-- print("膜拜城主")
	local msg = ReqSuperGloryWroshipMsg:new()
	MsgManager:Send(msg)
end;

-- 得到帮派成员列表，城主分配礼包
function SuperGloryController:ReqSuperGlorySendBag()
	-- print("得到帮派成员列表")
	local msg = ReqSuperGlorySendBagMsg:new();
	MsgManager:Send(msg)
end;

-- 城主提交分配礼包
function SuperGloryController:ReqSuperGlorySendBagUp(list)
	-- print("城主分配礼包")
	local msg = ReqSuperGlorySendBagUpMsg:new()
	local listcc = {};
	for i,info in pairs(list) do 
		if info.num ~= 0 then 
			table.push(listcc,info)
		end;
	end;
	msg.roleList = listcc;
	MsgManager:Send(msg)
end;

--城主请求设置副手
function SuperGloryController:ReqSuperGloryReqSetDeputy()
	-- print("请求设置副手")
	local msg = ReqSuperGloryReqSetDeputyMsg:new()	
	MsgManager:Send(msg)
end;
-- 城主确认设置副手
function SuperGloryController:ReqSuperGlorySetDeputy(roleid)
	-- print("确认设置副手")
	local msg = ReqSuperGlorySetDeputyMsg:new()
	msg.roleID = roleid;
	MsgManager:Send(msg);
end;

