--[[
打坐 coltroller
郝户
2014年11月11日22:04:57
]]

_G.SitController = setmetatable( {}, {__index = IController} );

_G.SitController.name = "SitController";
SitController.ReqSitState = false
SitController.isAuto = false

function SitController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_SitStatusChange, self, self.OnSitStatusChange );
	MsgManager:RegisterCallBack( MsgType.SC_NearbySit, self, self.OnNearbySitRsv );
	MsgManager:RegisterCallBack( MsgType.SC_SitGain, self, self.OnSitGain );
end


----------------------------------- handle response msg --------------------------------
-- 打坐状态变化
function SitController:OnSitStatusChange(msg)
	SitController.ReqSitState = false
	--print("SitController.ReqSitState", SitController.ReqSitState)
	if msg.flag == 1 then
		self:SitStart(msg);
	else
		self:SitCancel();
	end
end

-- 开始打坐
function SitController:SitStart(msg)
	-- 如果正在自动战斗，先取消
	if AutoBattleController.isAutoHang then
		AutoBattleController:SetAutoHang();
	end
	local sitX = msg.x;
	local sitY = msg.y;
	local id   = msg.id
	local sitRoleList = msg.sitRoleList;
	if #sitRoleList < 1 or #sitRoleList > 4 then
		print( string.format( "### ERROR: resieved bad SIT ROLE NUM: %s", numRole ) );
		print( debug.traceback() )
	end
	SitModel:SetSitState(id, sitRoleList, sitX, sitY);
	UISit:Show();

	local selfRoleId = MainPlayerController:GetRoleID()
	for index, info in pairs(sitRoleList) do
		if info.roleId == selfRoleId then
			self:SetPlayerSitState( id, info.index )
		end
	end
end

function SitController:SetPlayerSitState( id, index )
	local selfPlayer = MainPlayerController:GetPlayer() 
	if selfPlayer then
		selfPlayer:SetSitState(id, index)
	end
end

-- 取消打坐
function SitController:SitCancel()
	SitModel:SitCancel();
	self:SetPlayerSitState( 0, 0 )
	SitController.isAuto = false
	UISit:Hide()
end

-- 获取打坐收益
function SitController:OnSitGain(msg)
	SitModel:Gain( msg.exp, msg.zhenQi );
end

-- 收到附近的打坐阵法列表
function SitController:OnNearbySitRsv(msg)
	Debug('resieve nearby sit list.')
	SitModel:SetNearbySit( msg.nearbySitList );
end


----------------------------------- request msg ----------------------------------------

function SitController:ReqSit( sitId, index, isAuto )
	if FuncManager:GetFuncIsOpen(FuncConsts.Sit) == false then
		return
	end
	-- 判断玩家是否处于战斗中，战斗中无法打坐
	local mainPlayer = MainPlayerController:GetPlayer();
	--if mainPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_INCOMBAT) == 1 then
		--FloatManager:AddCenter( StrConfig['sit201'] );
		--return;
	--end
	-- 当前地图无法打坐
	if CPlayerMap:GetCurrMapIsSit() == false then
		FloatManager:AddCenter( StrConfig['sit202'] );
		return;
	end
	if MainPlayerController:IsCanSit() == false then
		FloatManager:AddCenter( StrConfig['sit205'] )
		return
	end
	MountController:RemoveRideMount()
	MainPlayerController:StopMove()
	SitController:SetReqSitState()
	if isAuto then
		SitController.isAuto = true
	else
		SitController.isAuto = false
	end
	local msg = ReqSitStatusChangeMsg:new();
	msg.oper  = SitConsts.Oper_Join; -- 进入打坐
	msg.id    = sitId or 0;
	msg.index = index or 0;
	MsgManager:Send(msg);
end

function SitController:ReqCancelSit()
	if SitModel:GetSitState() == SitConsts.NoneSit then
		return
	end
	SitController:SetReqSitState()
	local msg = ReqSitStatusChangeMsg:new();
	msg.oper = SitConsts.Oper_Leave; -- 取消打坐
	MsgManager:Send(msg);
	UISit:Hide()
end

function SitController:ReqNearBySit()
	Debug('query nearby sit list')
	MsgManager:Send( ReqNearbySitMsg:new() )
end

----------------------------------------------------------------------------------------

-- 寻路过去结阵打坐
-- @param dexVec: 目标打坐阵坐标(_Vector3)
-- @param sitId: 目标打坐阵id
-- @param index: 序号
function SitController:AutoRunToSit( desVec, sitId, index )
	local completeFunc = function()
		self:ReqSit(sitId, index);
	end
	self:SetPlayerSitState( 0, 0 )
	local result = MainPlayerController:DoAutoRun( MainPlayerController:GetMapId(), desVec, completeFunc )
	if not result then
		completeFunc()
	end
end

function SitController:SetSitList(roleId, oldSitState, newSitState)
	local oldSitId = oldSitState.id
	local newSitId = newSitState.id
	local newSitIndex = newSitState.index
	if oldSitId == newSitId then
		return
	elseif oldSitId == 0 and newSitId ~= 0 then
		if not SitModel.sitList[newSitId] then
			SitModel.sitList[newSitId] = {}
		end
		SitModel.sitList[newSitId][newSitIndex+1] = roleId
		SitController:PlaySitPfx(newSitId)
	elseif oldSitId ~= 0 and newSitId == 0 then
		for index, cid in pairs(SitModel.sitList[oldSitId]) do
			if cid == roleId then
				SitModel.sitList[oldSitId][index] = nil
			end
		end
		if next(SitModel.sitList[oldSitId]) then
			SitController:PlaySitPfx(oldSitId)
		else
			SitModel.sitList[oldSitId] = nil
		end
	end
end

-- 是否在主城打坐区
function SitController:IsInSitArea(cid)
	if MapPath.MainCity ~= CPlayerMap:GetCurMapID() then
		return false
	end
	local sitAreaPos = SitConsts:GetSitAreaPos()
	local myPos = nil
	if not cid then
	 	myPos = MainPlayerController:GetPos()
	else
		local player = CPlayerMap:GetPlayer(cid)
		if not player then
			return
		end
		myPos = player:GetPos()
	end
	if not myPos then return false end
	--local centerPos = { x = sitAreaPos.x, y = sitAreaPos.y }
	return _G.isInCircle( myPos, sitAreaPos, sitAreaPos.r )
end

-- 随机获取打坐区坐标点 _Vector3
function SitController:GetSitAreaVec()
	local sitAreaPos  = SitConsts:GetSitAreaPos()
	local x, y        = sitAreaPos.x, sitAreaPos.y
	local rotation    = math.random( 0, 2 * math.pi )
	local radius      = math.random( sitAreaPos.ri, sitAreaPos.r )
	local projectionX = radius * math.cos(rotation)
	local projectionY = radius * math.sin(rotation)
	local appendVector = _Vector3.new( projectionX, projectionY, 0)
	return _Vector3.new(x, y, 0):add( appendVector )
end

local sitmat1 = _Matrix3D.new()
local sitmat2 = _Matrix3D.new()
local sitmat3 = _Matrix3D.new()
local sitmat4 = _Matrix3D.new()
function SitController:PlaySitPfx(sitId)
	for i = 1, 4 do
		CPlayerMap:GetSceneMap():StopPfxByName(sitId .. "abc" ..i)
	end

	local playerRoleIdList = {}
	for index, cid in pairs(SitModel.sitList[sitId]) do
		table.insert(playerRoleIdList, {cid = cid, index = index})
	end
	table.sort(playerRoleIdList, function(info1, info2)
		return info1.index < info2.index
	end)

	local sitNumber = #playerRoleIdList
	if sitNumber <= 1 then
		return
	elseif sitNumber == 2 then
		local playerRoleId1 = playerRoleIdList[1].cid
		local player1 = CharController:GetCharByCid(playerRoleId1)
		if not player1 then
			return
		end
		local playerRoleId2 = playerRoleIdList[2].cid
		local player2 = CharController:GetCharByCid(playerRoleId2)
		if not player2 then
			return
		end
		local pos1 = player1:GetPos()
		local pos2 = player2:GetPos()
		local selfRoleId = MainPlayerController:GetRoleID()
		if selfRoleId == playerRoleId1 then
			MainPlayerController:ChangeDir(pos2)
		elseif selfRoleId == playerRoleId2 then
			MainPlayerController:ChangeDir(pos1)
		end
        sitmat1:setTranslation(_Vector3.new(pos2.x, pos2.y, pos2.z))
        sitmat1:mulFaceToLeft(1, 0, 0, pos2.x - pos1.x, pos2.y - pos1.y, pos2.z - pos1.z)
		CPlayerMap:GetSceneMap():PlayerPfxByMat(sitId .. "abc1", "dazuo_chuanshu.pfx", sitmat1)
	elseif sitNumber == 3 then
		local playerRoleId1 = playerRoleIdList[1].cid
		local player1 = CharController:GetCharByCid(playerRoleId1)
		if not player1 then
			return
		end
		local playerRoleId2 = playerRoleIdList[2].cid
		local player2 = CharController:GetCharByCid(playerRoleId2)
		if not player2 then
			return
		end
		local playerRoleId3 = playerRoleIdList[3].cid
		local player3 = CharController:GetCharByCid(playerRoleId3)
		if not player3 then
			return
		end

		local pos1 = player1:GetPos()
		local pos2 = player2:GetPos()
		local pos3 = player3:GetPos()

		local selfRoleId = MainPlayerController:GetRoleID()
		if selfRoleId == playerRoleId1 then
			local pos = {}
			pos.x = (pos2.x + pos3.x) / 2
			pos.y = (pos2.y + pos3.y) / 2
			MainPlayerController:ChangeDir(pos)
		elseif selfRoleId == playerRoleId2 then
			local pos = {}
			pos.x = (pos1.x + pos3.x) / 2
			pos.y = (pos1.y + pos3.y) / 2
			MainPlayerController:ChangeDir(pos)
		elseif selfRoleId == playerRoleId3 then
			local pos = {}
			pos.x = (pos1.x + pos2.x) / 2
			pos.y = (pos1.y + pos2.y) / 2
			MainPlayerController:ChangeDir(pos)
		end
        sitmat1:setTranslation(_Vector3.new(pos2.x, pos2.y, pos2.z))
        sitmat1:mulFaceToLeft(1, 0, 0, pos2.x - pos1.x, pos2.y - pos1.y, pos2.z - pos1.z)
		CPlayerMap:GetSceneMap():PlayerPfxByMat(sitId .. "abc1", "dazuo_chuanshu.pfx", sitmat1)
        sitmat2:setTranslation(_Vector3.new(pos3.x, pos3.y, pos3.z))
        sitmat2:mulFaceToLeft(1, 0, 0, pos3.x - pos2.x, pos3.y - pos2.y, pos3.z - pos2.z)
		CPlayerMap:GetSceneMap():PlayerPfxByMat(sitId .. "abc2", "dazuo_chuanshu.pfx", sitmat2)
        sitmat3:setTranslation(_Vector3.new(pos1.x, pos1.y, pos1.z))
        sitmat3:mulFaceToLeft(1, 0, 0, pos1.x - pos3.x, pos1.y - pos3.y, pos1.z - pos3.z)
		CPlayerMap:GetSceneMap():PlayerPfxByMat(sitId .. "abc3", "dazuo_chuanshu.pfx", sitmat3)
	elseif sitNumber == 4 then
		local playerRoleId1 = SitModel.sitList[sitId][1]
		local player1 = CharController:GetCharByCid(playerRoleId1)
		if not player1 then
			return
		end
		local playerRoleId2 = SitModel.sitList[sitId][3]
		local player2 = CharController:GetCharByCid(playerRoleId2)
		if not player2 then
			return
		end
		local playerRoleId3 = SitModel.sitList[sitId][2]
		local player3 = CharController:GetCharByCid(playerRoleId3)
		if not player3 then
			return
		end
		local playerRoleId4 = SitModel.sitList[sitId][4]
		local player4 = CharController:GetCharByCid(playerRoleId4)
		if not player4 then
			return
		end
		local pos1 = player1:GetPos()
		local pos2 = player2:GetPos()
		local pos3 = player3:GetPos()
		local pos4 = player4:GetPos()

		local selfRoleId = MainPlayerController:GetRoleID()
		if selfRoleId == playerRoleId1 then
			MainPlayerController:ChangeDir(pos4)
		elseif selfRoleId == playerRoleId2 then
			MainPlayerController:ChangeDir(pos3)
		elseif selfRoleId == playerRoleId3 then
			MainPlayerController:ChangeDir(pos2)
		elseif selfRoleId == playerRoleId4 then
			MainPlayerController:ChangeDir(pos1)
		end

        sitmat1:setTranslation(_Vector3.new(pos1.x, pos1.y, pos1.z))
        sitmat1:mulFaceToLeft(1, 0, 0, pos1.x - pos4.x, pos1.y - pos4.y, pos1.z - pos4.z)
		CPlayerMap:GetSceneMap():PlayerPfxByMat(sitId .. "abc1", "dazuo_chuanshu.pfx", sitmat1)
        sitmat2:setTranslation(_Vector3.new(pos3.x, pos3.y, pos3.z))
        sitmat2:mulFaceToLeft(1, 0, 0, pos3.x - pos2.x, pos3.y - pos2.y, pos3.z - pos2.z)
		CPlayerMap:GetSceneMap():PlayerPfxByMat(sitId .. "abc2", "dazuo_chuanshu.pfx", sitmat2)

  --       sitmat1:setTranslation(_Vector3.new(pos2.x, pos2.y, pos2.z))
  --       sitmat1:mulFaceToLeft(1, 0, 0, pos2.x - pos1.x, pos2.y - pos1.y, pos2.z - pos1.z)
		-- CPlayerMap:GetSceneMap():PlayerPfxByMat(sitId .. "abc1", "dazuo_chuanshu.pfx", sitmat1)
  --       sitmat2:setTranslation(_Vector3.new(pos3.x, pos3.y, pos3.z))
  --       sitmat2:mulFaceToLeft(1, 0, 0, pos3.x - pos2.x, pos3.y - pos2.y, pos3.z - pos2.z)
		-- CPlayerMap:GetSceneMap():PlayerPfxByMat(sitId .. "abc2", "dazuo_chuanshu.pfx", sitmat2)
  --       sitmat3:setTranslation(_Vector3.new(pos4.x, pos4.y, pos4.z))
  --       sitmat3:mulFaceToLeft(1, 0, 0, pos4.x - pos3.x, pos4.y - pos3.y, pos4.z - pos3.z)
		-- CPlayerMap:GetSceneMap():PlayerPfxByMat(sitId .. "abc3", "dazuo_chuanshu.pfx", sitmat3)
  --       sitmat4:setTranslation(_Vector3.new(pos1.x, pos1.y, pos1.z))
  --       sitmat4:mulFaceToLeft(1, 0, 0, pos1.x - pos4.x, pos1.y - pos4.y, pos1.z - pos4.z)
		-- CPlayerMap:GetSceneMap():PlayerPfxByMat(sitId .. "abc4", "dazuo_chuanshu.pfx", sitmat4)
	end
end

function SitController:IsAutoSit()
	return SitController.isAuto
end

function SitController:SetReqSitState()
	SitController.ReqSitState = true
	if SitController.timePlan then
		TimerManager:UnRegisterTimer(SitController.timePlan)
	end
	SitController.timePlan = TimerManager:RegisterTimer(function()
		SitController.ReqSitState = false	
	end, 3000, 1)
end