

function AutoPath:LoadSetting()
	local tbPaths = LoadTabFile("Setting/Map/FollowFightPath.tab", "ddss", nil, {"OrgMap", "TargetMap", "Operation", "Param"});
	self.tbFollowFightPaths = {};
	for _, tbPath in pairs(tbPaths) do
		self.tbFollowFightPaths[tbPath.OrgMap] = self.tbFollowFightPaths[tbPath.OrgMap] or {};
		self.tbFollowFightPaths[tbPath.OrgMap][tbPath.TargetMap] = self.tbFollowFightPaths[tbPath.OrgMap][tbPath.TargetMap] or {};
		local tbInfo = self.tbFollowFightPaths[tbPath.OrgMap][tbPath.TargetMap];
		tbInfo.szOperation = tbPath.Operation;

		if tbInfo.szOperation == "GoPos" then
			tbInfo.tbPos = {};
			for _, szPath in ipairs(Lib:SplitStr(tbPath.Param, "|")) do
				local szPosX, szPosY = string.match(szPath, "(%d+)_(%d+)");
				local nPosX, nPosY = tonumber(szPosX), tonumber(szPosY);
				assert(nPosX, nPosY);
				table.insert(tbInfo.tbPos, {nPosX, nPosY});
			end
		else
			tbInfo.szParams = tbPath.Param;
		end
	end

	-- 广度优先遍历，添加所有可达路径
	local tbNewPath = {};
	for nOrgMap, tbPathInfo in pairs(self.tbFollowFightPaths) do
		tbNewPath[nOrgMap]={};
		local tbArray = {};
		for nTargetMap, tbOpInfo in pairs(tbPathInfo) do
			table.insert(tbArray, {nTargetMap, tbOpInfo});
		end

		local nIdx = 1;
		while nIdx <= #tbArray do
			local nTargetMap, tbOpInfo = unpack(tbArray[nIdx]);
			for nOtherTarget, _ in pairs(self.tbFollowFightPaths[nTargetMap] or {}) do
				if not tbPathInfo[nOtherTarget]
					and nOrgMap ~= nOtherTarget 
					and not (tbNewPath[nTargetMap] and tbNewPath[nTargetMap][nOtherTarget])
					then
					tbNewPath[nOrgMap][nOtherTarget] = true;
					tbPathInfo[nOtherTarget] = tbOpInfo;
					table.insert(tbArray, {nOtherTarget, tbOpInfo});
				end
			end
			nIdx = nIdx + 1;
		end
	end
end

AutoPath:LoadSetting();

function AutoPath:GetGoTargetNextActInfo(nTargetMapTemplateId, nOrgMapTemplateId)
	if nTargetMapTemplateId and nOrgMapTemplateId and self.tbFollowFightPaths[nOrgMapTemplateId] then
		return self.tbFollowFightPaths[nOrgMapTemplateId][nTargetMapTemplateId];
	end
end

function AutoPath:IsSameMapId(nMapId1, nMapId2, nMapTemplateId1, nMapTemplateId2)
	if nMapId1 == nMapTemplateId1 and nMapTemplateId2 == nMapTemplateId1 then
		return true
	end

	return IsSameMapId(nMapId1, nMapId2)
end


function AutoPath:GotoAndCall(nMapId, nX, nY, fnCallback, nNearLength, nMapTemplateId, nParam)
	if not nMapId or nMapId <= 0 then
		me.CenterMsg("目标在活动地图不可传送");
		return;
	end
	
	self:ClearGoPath();
	AutoPath:_GotoAndCall(nMapId, nX, nY, fnCallback, nNearLength, nMapTemplateId, nParam)
end

-- 寻到离目标点nNearLength的距离, 则停下调fnCallback
function AutoPath:_GotoAndCall(nMapId, nX, nY, fnCallback, nNearLength, nMapTemplateId, nParam)
	self.fnAfterWalk = fnCallback;
	self.nNearLength = nNearLength or 0;

	if AutoPath:IsSameMapId(nMapId, me.nMapId, nMapTemplateId, me.nMapTemplateId)
		or (nMapId == Kin.Def.nKinMapTemplateId and nMapId == me.nMapTemplateId)
		then
		local _, nMyX, nMyY = me.GetWorldPos();
		if Lib:GetDistance(nX, nY, nMyX, nMyY) <= self.nNearLength then
			self:WalkEnd();
			return;
		end

		if self.fnAfterWalk then
			--这里关闭自动战斗，如果不关闭的话回调不到WalkEnd
			AutoFight:StopAll(true);
		end

		Operation:ClickMapIgnore(nX, nY, false, fnCallback and self.nNearLength or -1);
	else
		AutoFight:StopAll(true);

		local tbPath = nil
		if not self.tbPath then
			tbPath = Map:GetTransmitPath(nMapTemplateId, nMapId, nX, nY, nParam)
		end

		if tbPath and #tbPath > 0 then
			AutoPath:GotoPath(tbPath, fnCallback, nNearLength, nParam)
		else
			self.nTargetMapId = nMapId;
			self.nTargetMapTemplateId = nMapTemplateId;
			self.tbTargetPos = nX and {nX, nY};
			if not self.tbPath then
				Map:SwitchMap(nMapId, nMapTemplateId);
			end
		end
	end
end

--tbPath = {
--		{nMapId, nX, nY, [nMapTemplateId, fnCallBack]},
--		...
--	}

function AutoPath:GotoPath(tbPath, fnCallback, nNearLength, nParam)
	self.tbPath = tbPath;
	self.fnPathEndCallback = fnCallback;

	local function fnFirstPathCallback()
		if self.fnPathCallBack then
			self.fnPathCallBack()
		end
		self.fnPathCallBack = nil

		if not self.tbPath then
			return;
		end

		if not next(self.tbPath) then
			if self.fnPathEndCallback then
				self.fnPathEndCallback();
			end

			self.tbPath = nil;
			self.fnPathEndCallback = nil;
			return;
		end

		local tbFirstPath = table.remove(self.tbPath, 1);
		local nMapId, nX, nY,nMapTemplateId, fnPathCallBack, nParam = unpack(tbFirstPath);
		self.fnPathCallBack = fnPathCallBack

		AutoPath:_GotoAndCall(nMapId, nX, nY, fnFirstPathCallback, next(self.tbPath) and 0 or nNearLength, nMapTemplateId, nParam);
	end

	fnFirstPathCallback();
end

function AutoPath:WalkEnd()
	if self.fnAfterWalk and type(self.fnAfterWalk) == "function" then
		local fnCallback = self.fnAfterWalk;
		self.fnAfterWalk = nil;
		fnCallback();
		Operation:SetPositionEffect(false);
	end
end

function AutoPath:OnEnterMap(nTemplateID, nMapID, nIsLocal)
	if me.bStartAutoPath then
		--为了切换地图时停止c++中的寻路
		local _, nX, nY = me.GetWorldPos();
		me.GotoPosition(nX, nY);
	end
end

function AutoPath:OnMapLoaded(nMapTemplateId)
	if AutoPath:IsSameMapId(self.nTargetMapId or 0, me.nMapId, self.nTargetMapTemplateId or 0, me.nMapTemplateId)
		or (self.nTargetMapId == Kin.Def.nKinMapTemplateId and self.nTargetMapId == me.nMapTemplateId) -- 家族地图处理
		then
		if self.tbTargetPos and self.nNearLength then
			Operation:ClickMapIgnore(self.tbTargetPos[1], self.tbTargetPos[2], false, self.fnAfterWalk and self.nNearLength);
		end
	elseif self.tbPath then
		if self.tbPath[1] and self.tbPath[1][4] == nMapTemplateId then
			AutoPath:GotoPath(self.tbPath, self.fnPathEndCallback, self.nNearLength, self.tbPath[1][5])
		else
			AutoPath:ClearGoPath();
			local _, nX, nY = me.GetWorldPos();
        			me.GotoPosition(nX + 1, nY);
		end
	elseif me.bStartAutoPath then
		AutoPath:ClearGoPath();
		local _, nX, nY = me.GetWorldPos();
		me.GotoPosition(nX + 1, nY);
	end
	self.nTargetMapId = nil;
	self.tbTargetPos = nil;
end

function AutoPath:GetNpcPos(nNpcTemplateId, nMapTemplateId, bRandom)
	local tbMapNpcInfo = Map:GetMapNpcInfoByNpcTemplate(nMapTemplateId, nNpcTemplateId);
	if not tbMapNpcInfo then
		return;
	end

	local tbNpcInfo = tbMapNpcInfo[1];
	if bRandom and #tbMapNpcInfo > 1 then
		tbNpcInfo = tbMapNpcInfo[MathRandom(#tbMapNpcInfo)];
	end

	return tbNpcInfo.XPos, tbNpcInfo.YPos, tbNpcInfo.WalkNearLength;
end

function AutoPath:ClearGoPath()
	self.tbPath = nil
	self.fnPathEndCallback = nil;
end

function AutoPath:AutoPathToNpc(nNpcId, nMapId, nPosX, nPosY, bNotSimpleTap)
	if not nPosX or not nPosY then
	    nPosX, nPosY = AutoPath:GetNpcPos(nNpcId, nMapId)
	end
    local fnCallback = function ()
        local nId = AutoAI.GetNpcIdByTemplateId(nNpcId)
        if nId then
            Operation.SimpleTap(nId)
        end
    end
    if bNotSimpleTap then
    	fnCallback = function () end
    end
    AutoPath:GotoAndCall(nMapId, nPosX, nPosY, fnCallback, Npc.DIALOG_DISTANCE)
end