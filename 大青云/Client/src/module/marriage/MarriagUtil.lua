--[[
结婚
wangshuai
]]
_G.MarryUtils = {};

--婚礼巡游步骤
function MarryUtils:MarryTravelStep()
	--print("婚礼巡游步骤")
	--trace(MarriageModel.MarryState)
	--
	--是否在婚礼时间
	local isMyMarry = MarryUtils:GetIsIngMyMarry()
	if not isMyMarry then 
		FloatManager:AddNormal( StrConfig["marriage049"]);
		return 
	end;
	--预约过时间没
	local mytime = MarriageModel:GetMyMarryTime()
	if mytime <= 0 then 
		FloatManager:AddNormal(StrConfig["marriage201"])
		return 
	end;
	--预约婚礼类型
	local myType = MarriageModel:GetMyMarryType()
	if myType == 0 then 
		FloatManager:AddNormal(StrConfig["marriage202"])
		return 
	end;
	--简单婚礼没有巡游
	local myType = MarriageModel:GetMyMarryType()
	if myType == 1 then --简单婚礼
		FloatManager:AddNormal( StrConfig["marriage077"]);
		return 
	end;

	--是否组队
	local isTeam = TeamModel:IsInTeam();
	if not isTeam then 
		FloatManager:AddNormal( StrConfig['marriage094']);
		return 
	end;
	--是否队长
	local mytema = TeamUtils:MainPlayerIsCaptain();
	if not mytema then 
		FloatManager:AddNormal( StrConfig['marriage076']);
		return 
	end;

	--我是否巡游过
	local marryYou = MarriageModel:GetMyMarrySchedule();
	if marryYou == 1 then 
		FloatManager:AddNormal( StrConfig["marriage078"]);
		return 
	end;

	MarriagController:ReqMarryTravel()
end;

--进入婚礼殿堂
function MarryUtils:MarryEnterSceneStep()
	--print("进入婚礼殿堂")
	--trace(MarriageModel.MarryState)
	--
	--是否在婚礼时间
	local isMyMarry = MarryUtils:GetIsIngMyMarry()
	if not isMyMarry then 
		FloatManager:AddNormal( StrConfig["marriage049"]);
		return 
	end;
	--预约过时间没
	local mytime = MarriageModel:GetMyMarryTime()
	if mytime <= 0 then 
		FloatManager:AddNormal(StrConfig["marriage201"])
		return 
	end;
	--预约婚礼类型
	local myType = MarriageModel:GetMyMarryType()
	if myType == 0 then 
		FloatManager:AddNormal(StrConfig["marriage202"])
		return 
	end;

	--是否巡游过
	local marryYou = MarriageModel:GetMyMarrySchedule();
	local myType = MarriageModel:GetMyMarryType()
	if marryYou ~= 1 and myType ~= 1 then 
		FloatManager:AddNormal( StrConfig["marriage084"]);
		return 
	end;
	--
	FashionsController:DressMerryFashions()
	MarriagController:ReqEnterMarryChurch()
end

--邀请玩家，进入婚礼现场
function MarryUtils:MarrySceneInviteStep()
	--print("邀请玩家，进入婚礼现场")
	--print("是这里的--trace吗？")
	--
	--是否在婚礼时间
	local isMyMarry = MarryUtils:GetIsIngMyMarry()
	if not isMyMarry then 
		FloatManager:AddNormal( StrConfig["marriage049"]);
		return 
	end;
	local isMyMarry = MarryUtils:GetIsIngMyMarry()
	if not isMyMarry then 
		FloatManager:AddNormal( StrConfig["marriage042"]);
		return 
	end;
	--是否组队
	local isTeam = TeamModel:IsInTeam();
	if not isTeam then 
		FloatManager:AddNormal( StrConfig['marriage094']);
		return 
	end;

	--是否队长
	local mytema = TeamUtils:MainPlayerIsCaptain();
	if not mytema then 
		FloatManager:AddNormal( StrConfig['marriage076']);
		return 
	end;

	MarriagController:ReqMarryInvite()
end;

--开启婚礼仪式
function MarryUtils:MarryOpenStep() 
	--print("开启婚礼仪式")
	--
	--是否在自己婚礼时间
	local isMyMarry = MarryUtils:GetIsIngMyMarry()
	if not isMyMarry then 
		FloatManager:AddNormal( StrConfig["marriage042"]);
		return 
	end;

	local state = MarriageModel:GetMyMarryState()
	if state == MarriageConsts.marryMarried then 
		FloatManager:AddNormal( StrConfig["marriage074"]);
		return 
	end;
	--是否组队
	local isTeam = TeamModel:IsInTeam();
	if not isTeam then 
		FloatManager:AddNormal( StrConfig['marriage094']);
		return 
	end;
	
	--是否队长
	local mytema = TeamUtils:MainPlayerIsCaptain();
	if not mytema then 
		FloatManager:AddNormal( StrConfig['marriage076']);
		return 
	end;

	--预约过时间没
	local mytime = MarriageModel:GetMyMarryTime()
	if mytime <= 0 then 
		FloatManager:AddNormal(StrConfig["marriage201"])
		return 
	end;
	--预约婚礼类型
	local myType = MarriageModel:GetMyMarryType()
	if myType == 0 then 
		FloatManager:AddNormal(StrConfig["marriage202"])
		return 
	end;

	MarriagController:ReqMarryOpen()
end;

--开启婚礼酒宴
function MarryUtils:MarryOpenFEASTStep()
	--print("开启婚礼酒宴")
	
end;

--迅游完成，是否进入婚礼仪式
function MarryUtils:MarryEnterScene()
	--
	
end;

--得到双方名字
function MarryUtils:GetTitleName()
	local state = MarriageModel:GetMyMarryState()
	if state == MarriageConsts.marrySingle or state == MarriageConsts.marryLeave then --单身 离婚
		return ""
	elseif state == MarriageConsts.marryReserve or state == MarriageConsts.marryMarried then --订婚，结婚
		local roleData = MarriageModel.MymarryPanelInfo
		if roleData and roleData.beRoleName ~= "" then 
			return roleData.beRoleName
		end;
	end;
	return ""
end;

--得到是否显示
function MarryUtils:GetIsShowTitle()
	return true;
end;

--双方同意，播放结婚mv
function MarryUtils:PlayeMarryMv(marryType, naProf, nvProf)
	--print("双方同意，播放mv,哈哈哈哈哈哈")
	--local marryType = MarriageModel:GetMyMarryType() 
	--marryType = 1;
	-- jh1001萝莉男人，jh1002萝莉男魔，jh1003御姐男人，jh1004御姐男魔；高级
	-- jh1005萝莉男人，jh1006萝莉男魔，jh1007御姐男人，jh1008御姐男魔；低级
	if marryType == 1 then 
		if nvProf == 1 and naProf == 3 then 
			--
			StoryController:StoryStartMsg("jh1005", function()
			end)

		elseif nvProf == 4 and naProf == 3 then 
			--jh1006
			StoryController:StoryStartMsg("jh1006", function()
			end)
		elseif nvProf == 1 and naProf == 2 then 
			--jh1007
			StoryController:StoryStartMsg("jh1007", function()
			end)
		elseif nvProf == 4 and naProf == 2 then 
			--jh1008
			StoryController:StoryStartMsg("jh1008", function()
			end)
		else
			--print(naProf,nvProf,"男职业，女职业",debug.--traceback())
		end;
	elseif marryType == 2 then 
		if nvProf == 1 and naProf == 3 then 
			--jh1001
			StoryController:StoryStartMsg("jh1001", function()
			end)
		elseif nvProf == 4 and naProf == 3 then 
			--jh1002
			StoryController:StoryStartMsg("jh1002", function()
			end)
		elseif nvProf == 1 and naProf == 2 then 
			--jh1003
			StoryController:StoryStartMsg("jh1003", function()
			end)
		elseif nvProf == 4 and naProf == 2 then 
			--jh1004
			StoryController:StoryStartMsg("jh1004", function()
			end)
		else
			--print(naProf,nvProf,"男职业，女职业",debug.--traceback())
		end;
	end;
end;

-- MarriageConsts.marrySingle	= 0;-- 单身
-- MarriageConsts.marryReserve = 1;-- 订婚
-- MarriageConsts.marryMarried = 2;-- 已婚
-- MarriageConsts.marryLeave 	= 3;-- 离

--是否在我自己的婚礼时间
function MarryUtils:GetIsIngMyMarry()
	-- do return false end;
	local state = MarriageModel:GetMyMarryState()
	--trace(MarriageModel:GetMyMarryTime(),state)
	if state == MarriageConsts.marryReserve or state == MarriageConsts.marryMarried then 
		local time = MarriageModel:GetMyMarryTime();
		if time <= 0 then 
			return false;
		else
			local now = GetServerTime(); -- 当前服务器时间

			local nowF = CTimeFormat:todate(now, false);
			local timeF = CTimeFormat:todate(time, false);
			--
			local serv = split(nowF," ");  --现在服务器时间
			local serD = split(serv[1],"-");   --得到年月日
			--
			local curd = split(timeF," ");  --婚礼时间
			local curD = split(curd[1],"-");   --得到年月日
			--
			if serD[1] ~= curD[1] or serD[2] ~= curD[2] or serD[3] ~= curD[3] then 
				--不同天
				return false;
			end;
			--
			local mynow = time + 3600; --我的最大时间 

			if now < mynow and now >= time then 
				return true;
			end;
			return false;
		end;
	end;
	return false;
end;


--婚车进入视野
function MarryUtils:EnterSee()
	--在我的婚礼时间，不show
	local isMyMarry = MarryUtils:GetIsIngMyMarry()
	if isMyMarry then 
		return 
	end;
	if not UIMarrySuifengzi:IsShow() then
		UIMarrySuifengzi:Show();
	end;
end;
--婚车退出视野
function MarryUtils:ExitSee()
	if UIMarrySuifengzi:IsShow() then
		UIMarrySuifengzi:Hide();
	end;
end;