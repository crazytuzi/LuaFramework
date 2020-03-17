--[[
地图 controller
haohu
2015年4月2日10:54:46
]]

_G.MapController = setmetatable( {}, {__index = IController} );
MapController.name = "MapController";

MapController.pointPathList  = {}; --自动寻路的显示的点集
MapController.PosMonitor = "MapController";
MapController.sceneChangeCallBacks = nil -- 切场景完成回调,func数组
MapController.lastTeleportReqTime = 0 -- 上一次请求传送的时间

MapController.confirmDisUID = nil
MapController.confirmCostUID = nil

MapController.mapRenderTimer = nil;

function MapController:Create()
    MsgManager:RegisterCallBack( MsgType.SC_MapPlayer, self, self.OnMapPlayerRsv );   --更新地图中玩家,一秒一次
    MsgManager:RegisterCallBack( MsgType.SC_BCJ_MapPlayer, self, self.OnBCJ_MapPlayerRsv );  --更新北仓界中玩家位置
    MsgManager:RegisterCallBack( MsgType.SC_Teleport, self, self.OnTeleportResult );
    MsgManager:RegisterCallBack( MsgType.SC_TeleportFreeTime, self, self.OnTeleportFreeTimeRsv );
	MapModel:Init();
end

function MapController:OnEnterGame()
	self:StartRenderMap()
end

--切换场景完成后的回调
function MapController:OnChangeSceneMap()
	self:StartRenderMap()

	-- 执行回调
	local callBacks = self.sceneChangeCallBacks
	if callBacks then
		for _, cb in pairs( callBacks) do
			cb()
		end
		self.sceneChangeCallBacks = nil
	end
	MapController:CloseConfirmDis()
	MapController:CloseConfirmCost()
	UIAutoBattleTxt:Open();
	WeatherController:OnCheckMapArea()
end

--离开当前场景立即执行
function MapController:OnLeaveSceneMap()
	self:StopRenderMap()
end

function MapController:StartRenderMap()
	self:StopRenderMap()
	self.mapRenderTimer = TimerManager:RegisterTimer( function()
		self:RefreshMonster();
		self:RefreshPlayer();
		self:RefreshNpc();
		self:RefreshActivityMonster();   --@adder:houxudong  purpose:刷新活动地图中怪物的位置 
	end, MapConsts.RefreshMapTime, 0 );
end

function MapController:StopRenderMap()
	if self.mapRenderTimer then
		TimerManager:UnRegisterTimer(self.mapRenderTimer);
		self.mapRenderTimer = nil;
	end
end

-- 添加换场景回调
function MapController:AddSceneChangeCB( cb )
	if not self.sceneChangeCallBacks then
		self.sceneChangeCallBacks = {}
	end
	table.push( self.sceneChangeCallBacks, cb )
end

---------------------------------------------------response-------------------------------------------------------

 --登录游戏 or 切场景
function MapController:OnEnterGameMsg(mapId)
	self:InitCurrMap(mapId);
end

local clearTimer
 --地图上要显示的玩家(帮友，队友等)
function MapController:OnMapPlayerRsv( msg )
	local playerList = msg.mapPlayerList;
	MapRelationModel:UpdateRelationalPlayer( playerList )

	-- 如果超过3s没有收到服务器新的玩家列表，说明当前没有需要显示
	-- 地图图标的玩家，这时清除玩家图标(有需要显示图标的玩家时，服务器每1s推送一次玩家列表)。
	local delTimer = function()
		if clearTimer then
			TimerManager:UnRegisterTimer(clearTimer)
			clearTimer = nil
		end
	end
	delTimer()
	clearTimer = TimerManager:RegisterTimer( function()
		delTimer()
		MapRelationModel:UpdateRelationalPlayer( {} )
	end, 3000, 1)
end

--更新北仓界中玩家的位置信息
function MapController:OnBCJ_MapPlayerRsv( msg )
	local playerList = msg.roleList;
	MapRelationModel:UpdateBcjPlayer( playerList )
end

function MapController:OnQuitBcj()
	MapRelationModel:ClearBCJPlayer()
end

function MapController:OnTeleportResult( msg )
	CPlayerMap.teleportState = false
	local result = msg.result;
	if result == 1 then -- ID错误
		Debug("地图ID错误")
	elseif result == 2 then -- 当前场景错误
		FloatManager:AddCenter( StrConfig['map207'] );
	elseif result == 3 then -- 目标地图错误
		FloatManager:AddCenter( StrConfig['map206'] );
	elseif result == 4 then -- 等级
		FloatManager:AddCenter( StrConfig['map205'] );
	elseif result == 5 then -- 正在pk
		FloatManager:AddCenter( StrConfig['map204'] );
	elseif result == 6 then -- 同地图
		FloatManager:AddCenter( StrConfig['map203'] );
	elseif result == 7 then -- 元宝不足
		FloatManager:AddCenter( StrConfig["map212"] );
	elseif result == 0 then -- success
		self:OnTeleportDone( msg.type )
	elseif result == 9 then --巡游
		FloatManager:AddCenter( StrConfig["marriage214"] );
	end
end

function MapController:OnTeleportDone( teleportType )
	Debug("返回传送类型：", teleportType)
	if teleportType == MapConsts.Teleport_Map then
		self:OnMapTeleportDone();
	elseif teleportType == MapConsts.Teleport_Story then -- 剧情传送
		-- do nothing
		QuestGuideManager:RecoverGuide()
	elseif teleportType == MapConsts.Teleport_DailyQuest or -- 日环飞鞋
		teleportType == MapConsts.Teleport_TrunkQuest or -- 主线飞鞋
		teleportType == MapConsts.Teleport_QuestFree or -- 远距离主线免费传
		teleportType == MapConsts.Teleport_RandomQuest or -- 奇遇
		teleportType == MapConsts.Teleport_TaoFa or --讨伐
		teleportType == MapConsts.Teleport_Agora or --集会所 新悬赏
		teleportType == MapConsts.Teleport_Recommend_Hang or
		teleportType == MapConsts.Teleport_LieMo or
		teleportType == MapConsts.Teleport_Hang then
		QuestController:OnTeleportDone( teleportType )
	elseif teleportType == MapConsts.Teleport_FengYao then
		UIFengYao:OnTeleportDone()
	elseif teleportType == MapConsts.Teleport_WorldBoss then
		UIWorldBoss:OnTeleportDone()
	elseif teleportType == MapConsts.Teleport_QuestWabao then
		UIWaBaoTwo:OnBtnTeleportClick();
	elseif teleportType == MapConsts.Teleport_FieldBoss then
		UIFieldBoss:OnTeleportDone()
	end
	--
	MapController:UpdatePlayerPos()
end

function MapController:OnMapTeleportDone()
	if UIWorldMapOper:IsShow() then
		UIWorldMapOper:Hide();
	end
end

function MapController:OnTeleportFreeTimeRsv(msg)
	local freeTime = msg.time
	MapModel:SetFreeTeleportTime( freeTime )
end

--已从服务器取得npc/portal消息
function MapController:OnCurMapNpcResp()
	self:DrawCurrMap();
end

----------------------------------------------------request-------------------------------------------------------
-- 公共接口
function MapController:Teleport( teleportType, onfootFunc, mapId, x, y )
	-- 时间间隔
	local nowTime = GetCurTime()
	if nowTime - self.lastTeleportReqTime < 1000 then -- 两次传送最小时间间隔
		return
	end
	if not mapId then
		mapId = CPlayerMap:GetCurMapID()
	end
	if not x or not y then
		local birthPoint = MapUtils:GetMapBirthPoint( mapId ) -- _Vector3
		x = birthPoint.x
		y = birthPoint.y
	end
	Debug( "请求传送类型：", teleportType, mapId, x, y )
	if self:CheckTeleportCondition( teleportType, mapId ) then
		self:BeforeTeleportTo( teleportType, onfootFunc, mapId, x, y )
	end
end

function MapController:CheckTeleportCondition( teleportType, mapId )
	-- 如果是副本活动等地图，提示
	if not MapUtils:CanTeleport() then
		FloatManager:AddNormal( StrConfig["map211"] )
		return false
	end
	-- 判断等级是否足够
	if not self:TeleportLevelEnough(mapId) then
		FloatManager:AddNormal( StrConfig["map205"] )
		return false
	end
	-- 判断传送类型(剧情传送和远距主线免费传送不检查花费)
	if teleportType == MapConsts.Teleport_Story or teleportType == MapConsts.Teleport_QuestFree then
		return true
	end
	-- 判断vip及花费
	local fee, itemId, freeVip = MapConsts:GetTeleportCostInfo()
	-- 判断免费使用的vip等级
	if freeVip and freeVip == 1 then
		return true
	end
	-- 判断是否有免费次数
	if MapModel:GetFreeTeleportTime() > 0 then
		return true
	end
	-- 判断是否有传送道具
	if BagModel:GetItemNumInBag( itemId ) > 0 then
		return true
	end
	-- 判断元宝是否足够
	if MainPlayerModel.humanDetailInfo.eaUnBindMoney < fee then
		FloatManager:AddNormal( string.format( StrConfig["map202"], fee ) )
		return false
	end
	return true
end

function MapController:BeforeTeleportTo( teleportType, onfootFunc, mapId, x, y )
	local promptCost = function(cb)
		local needPrompt = self:NeedPromptCost( teleportType )
		return needPrompt and self:PromptCost( teleportType, mapId, x, y, cb ) or cb
	end
	local promptDistance = function(cb)
		local needPrompt = self:NeedPromptDistance( teleportType, mapId, x, y )
		return needPrompt and self:PromptDistance( teleportType, onfootFunc, mapId, x, y, cb ) or cb
	end
	local teleport = function() self:SendTeleport(teleportType, mapId, x, y ) end
	local teleportFunc = promptCost( promptDistance( teleport ) );
	teleportFunc()
end

function MapController:NeedPromptCost( teleportType )
	-- 判断传送类型(剧情传送和远距主线免费传送不提示花费)
	if teleportType == MapConsts.Teleport_Story or teleportType == MapConsts.Teleport_QuestFree then
		return false
	end
	-- 判断设置
	if MapModel.noTeleportCostPrompt then
		return false
	end
	-- 判断vip及花费
	local fee, itemId, freeVip = MapConsts:GetTeleportCostInfo()
	-- 判断免费使用的vip等级
	if freeVip and freeVip == 1 then
		return false
	end
	-- 判断是否有免费次数
	if MapModel:GetFreeTeleportTime() > 0 then
		return false
	end
	-- 判断是否有传送道具
	if BagModel:GetItemNumInBag( itemId ) > 0 then
		return false
	end
	return true
end

-- 传送花费提示
function MapController:PromptCost( teleportType, mapId, x, y, cb )
	local fee = MapConsts:GetTeleportCostInfo()
	local content = string.format( StrConfig['map208'], fee )
	local confirmFunc = function( noPrompt )
		cb()
		MapModel.noTeleportCostPrompt = noPrompt
	end
	return function()
		MapController:CloseConfirmCost()
		MapController.confirmCostUID = UIConfirmWithNoTip:Open( content, confirmFunc )
	end
end

-- 是否传送距离提示
function MapController:NeedPromptDistance( teleportType, mapId, x, y )
	-- 判断传送类型(剧情传送和远距主线免费传送不提示距离)
	if teleportType == MapConsts.Teleport_Story or teleportType == MapConsts.Teleport_QuestFree then
		return false
	end
	-- 判断vip
	local _, _, freeVip = MapConsts:GetTeleportCostInfo()
	if freeVip and freeVip == 1 then
		return false
	end
	-- 判断不提醒设置
	if MapModel.noTeleportDistansePrompt then
		return false
	end
	-- 判断距离
	if teleportType == MapConsts.Teleport_WorldBoss then
		return false
	end
	return self:IsNearby( mapId, x, y )
end

function MapController:IsNearby( mapId, x, y )
	if mapId ~= CPlayerMap:GetCurMapID() then
		return false
	end
	-- lstPathLine ,bFindRes = AreaPathFinder:GetPathLine(vecSrc,vecDes);
	-- return bFindRes and #lstPathLine < 100;
	local distance = MapUtils:GetDistance( MainPlayerController:GetPos(), _Vector3.new( x, y, 0 ) )
	return distance < MapConsts.CriticalDistance
end

function MapController:PromptDistance( teleportType, cancelFunc, mapId, x, y, cb )
	local confirmFunc = function( noPrompt )
		cb()
		MapModel.noTeleportDistansePrompt = noPrompt
	end
	return function()
		MapController:CloseConfirmDis()
		MapController.confirmDisUID = UIConfirmWithNoTip:Open( StrConfig['map215'], confirmFunc, cancelFunc,
				StrConfig['map217'], StrConfig['map213'], nil, true )
		end
end

function MapController:CloseConfirmDis()
	if MapController.confirmDisUID then
		UIConfirmWithNoTip:Close( MapController.confirmDisUID )
		MapController.confirmDisUID = nil
	end
end

function MapController:CloseConfirmCost()
	if MapController.confirmCostUID then
		UIConfirmWithNoTip:Close( MapController.confirmCostUID )
		MapController.confirmCostUID = nil
	end
end

function MapController:SendTeleport( teleportType, mapId, x, y )
	local canTeleport, failFlag = MainPlayerController:IsCanTeleport()
	if not canTeleport then
		local promptStr = PlayerConsts.CannotTeleportRemindDic[ failFlag ]
		if promptStr then
			FloatManager:AddNormal( promptStr )
		end
		return
	end
	MainPlayerController:StopMove()
	CPlayerMap.teleportState = true
	MainPlayerController:ClearPlayerState()
	local msg = ReqTeleportMsg:new()
	msg.type = teleportType
	msg.mapId = mapId
	msg.x = x or 0
	msg.y = y or 0
	MsgManager:Send(msg)
	self.lastTeleportReqTime = GetCurTime()
end

function MapController:TeleportLevelEnough(mapId)
	local cfg = t_map[mapId]
	if not cfg then return end
	local lvlLimit = cfg.limitLv
	if not lvlLimit then
		Error( string.format( "not level limit config in t_map, mapId:%s", mapId ) )
		return false
	end
	if MainPlayerModel.humanDetailInfo.eaLevel < lvlLimit then
		return false
	end
	return true
end

------------------------------------------------------------------------------------------------------------------

function MapController:InitCurrMap( mapId )
	local map = self:GetCurrMap();
	map:SetMap( mapId );
	self:CleanUpCurrMap();
end

function MapController:DrawCurrMap()
	self:AddNpc();
	self:AddPortal();
	self:AddMonsterArea();
	self:AddSpecialElement();
	self:AddMainPlayer();
	self:AddHangPoint();
	self:AddUnionWarBuilding();
	self:AddUnionCityUnits();
	self:AddZhanchangUnits();
	self:AddUnionDiGongWarFlag();
end

function MapController:DrawLocalMap( mapId )
	local map = self:GetLocalMap();
	map:ClearElements();
	map:SetMap( mapId );
	self:AddLocalNpc();
	self:AddLocalPortal();
	self:AddLocalMonsterArea();
	self:AddLocalSpecialElement();
	self:AddLocalHangPoint();
end

function MapController:GetCurrMap()
	return self:GetMap( MapConsts.Type_Curr );
end

function MapController:GetLocalMap()
	return self:GetMap( MapConsts.Type_Local );
end

function MapController:GetMap( mapType )
	if not MapModel:GetModel( mapType ) then
		MapModel:Init();
	end
	return MapModel:GetModel( mapType );
end

function MapController:CleanUpCurrMap()
	local map = self:GetCurrMap();
	map:ClearElements();
	self:DelAutoLine();
	self:RemoveMainPlayer();
end

-- 移动到地图某点
-- @param mapType:当前地图，或当前查看的地图
local vecPosTemp = _Vector3.new(0, 0, 0)
function MapController:MoveToMap( mapType, x, y, onComplete, onFailed )
    vecPosTemp.x = x;
    vecPosTemp.y = y;
    if not onFailed then
		onFailed = function()
			FloatManager:AddNormal( StrConfig['map107'] );  --地图外了
		end
    end
    local map = self:GetMap( mapType );
	if not MainPlayerController:DoAutoRun( map:GetMapId(), vecPosTemp, onComplete ) then
		onFailed();
	end
end



-----------------------------------------  当  前  地  图  --------------------------------------------

local npcExist = {}; -- 已有的小地图npc
function MapController:RefreshNpc()
	-- local newNpcs = NpcModel:GetCurMapNpcList()
	local newNpcs = NpcModel:GetNpcList()
	local list = {};
	for cid, npc in pairs(newNpcs) do
		local npcCfg = npc:GetCfg()
		if not npcCfg.hideInMap and not npc.isHide then
			list[cid] = npc;
		end
	end
	newNpcs = list;
	local currentMap = self:GetCurrMap();
	-- 删除掉本次刷新消失的npc
	for existCid, existUid in pairs( npcExist ) do
		if not newNpcs[existCid] then
			currentMap:RemoveElement( existUid );
		end
	end
	npcExist = {};
	-- 添加本次新增或移动已有的npc
	for newCid, npc in pairs( newNpcs ) do
		local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_NpcS );
		local pos = npc:GetPos();
		local tid = npc:GetNpcId();
		mapElem:Init( tid, newCid, pos.x, pos.y );
		currentMap:AddElement( mapElem );
		npcExist[newCid] = mapElem:ToString();
	end
end

local monsterExist = {}; -- 已有的小地图怪物
function MapController:RefreshMonster()
	local newMonsters = MonsterModel:GetMonsterList()
	local list = {};
	for cid, monster in pairs(newMonsters) do
		if not monster.isHide then
			list[cid] = monster;
		end
	end
	newMonsters = list;
	local currentMap = self:GetCurrMap();
	-- 删除掉本次刷新消失的野怪
	for existCid, existUid in pairs( monsterExist ) do
		if not newMonsters[existCid] then
			currentMap:RemoveElement( existUid );
		end
	end
	monsterExist = {};
	-- 添加本次新增或移动已有的野怪
	for newCid, monster in pairs( newMonsters ) do
		local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Monster );
		local pos = monster:GetPos();
		local tid = monster:GetMonsterId();
		mapElem:Init( tid, newCid, pos.x, pos.y );
		currentMap:AddElement( mapElem );
		monsterExist[newCid] = mapElem:ToString();
	end
end

------------------刷新地图中怪物------------------------
--adder:houxudong date:2016/7/14
local monsterInActivity = {};     --北仓界活动中已有的怪物
function MapController:RefreshActivityMonster()
	local newMonsters = MonsterModel:GetMonsterList()
	local list = {};
	for cid, monster in pairs(newMonsters) do
		if not monster.isHide then  --可见
			list[cid] = monster;
		end
	end
	newMonsters = list;
	local currentMap = self:GetCurrMap();  --获得当前地图
	--先移除之前的怪物，后添加新的怪物
	for existCid, existUid in pairs( monsterInActivity ) do
		if not newMonsters[existCid] then
			currentMap:RemoveElement( existUid );   --当前地图移除怪物
		end
	end
	--添加新的怪物或移动已有的怪物位置
	monsterInActivity = {};
	for newCid, monster in pairs( newMonsters ) do
		local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Monster );
		local pos = monster:GetPos();
		local tid = monster:GetMonsterId();
		mapElem:Init( tid, newCid, pos.x, pos.y );
		currentMap:AddElement( mapElem );
		monsterInActivity[newCid] = mapElem:ToString();
	end
end

-------------------------------------------------------

-----------刷新其他玩家(队友，帮友)------------

local playerExist = {};
function MapController:RefreshPlayer()
	local currentMap = self:GetCurrMap();
	-- print("------------------------新其他玩家")
	-- 删除
	for existRoleId, existUid in pairs(playerExist) do
		currentMap:RemoveElement( existUid );
	end
	playerExist = {};
	-- 添加
	local mainPlayerId = MainPlayerController:GetRoleID();
	local relationPlayers = MapRelationModel:GetRelationPlayers()
	for roleId, player in pairs( relationPlayers ) do
		if roleId ~= mainPlayerId then
			local mapPlayer = CPlayerMap:GetPlayer( roleId )
			local pos = mapPlayer and mapPlayer:GetPos() or player:GetPos() -- 优先使用场景玩家的坐标，较为准确
			local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Player );
			mapElem:Init( roleId, roleId, pos.x, pos.y, nil, player );
			currentMap:AddElement( mapElem );
			playerExist[roleId] = mapElem:ToString();
		end
	end
end


------------寻路点--------------

--设置寻路路线
-- @param listVecs: 向量数组
function MapController:DrawLine( listVecs )
	self:DelAutoLine();
	local numVecs = #listVecs;
	if numVecs < 2 then return end
	for i = 1, numVecs - 1 do
		local vecA = listVecs[i];
		--[[
		trace(listVecs[i])
		trace(listVecs[i+1])
		print("就哈哈哈哈哈哈哈")
		--]]
		local vecB = listVecs[i + 1];
		if not vecA.portal then -- 传送点之间不画路径
			self:DrawSubLine(vecA, vecB);
		end
	end
end

function MapController:DrawSubLine( vecA, vecB )
	local len = MapUtils:Get2dDistance(vecA, vecB);
	-- 两个点之间绘制的寻路点的个数
	local numPointDecimal = len / MapConsts.PathPointDis;
	local numPoint =  toint( numPointDecimal, 0.5 );
	local currentMap = self:GetCurrMap();
	if numPoint == 0 and numPointDecimal > 0.4 then numPoint = 1; end
	for i = 1, numPoint do
		local id = getTableLen( self.pointPathList );
		local x = vecA.x + ( (vecB.x - vecA.x) / numPoint ) * i;
		local y = vecA.y + ( (vecB.y - vecA.y) / numPoint ) * i;
		local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Path );
		mapElem:Init( id, id, x, y, nil, id );
		currentMap:AddElement( mapElem );
		local uid = mapElem:ToString();
		self.pointPathList[uid] = true;
	end
end

--清除自动寻路点
function MapController:DelAutoLine()
	if getTableLen(self.pointPathList) == 0 then
		return;
	end
	local currentMap = self:GetCurrMap();
	for uid, _ in pairs( self.pointPathList ) do
		currentMap:RemoveElement( uid );
	end
	self.pointPathList = {};
end

-------当前地图NPC-------

function MapController:AddNpc()
	local npcList = NpcModel:GetCurMapNpcList();
	local list = {};
	for cid, npc in pairs( npcList ) do
		local npcCfg = npc:GetCfg()
		if not npcCfg.hideInMap and not npc.isHide then
			list[cid] = npc;
		end
	end
	--
	local currentMap = self:GetCurrMap();
	for cid, npc in pairs( list ) do 
		local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Npc );
		local pos = npc:GetPos();
		mapElem:Init( npc:GetNpcId(), cid, pos.x, pos.y );
		currentMap:AddElement( mapElem );
	end
end

--添加指定npc
function MapController:AddNpcById(npcId)
	local npc = NpcModel:GetNpcByNpcId(npcId);
	if not npc then return; end
	local currentMap = self:GetCurrMap();
	local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Npc );
	local pos = npc:GetPos();
	mapElem:Init( npc:GetNpcId(), npc:GetCid(), pos.x, pos.y );
	currentMap:AddElement( mapElem );
end

--删除指定npc
function MapController:RemoveNpcById(npcId)
	local npc = NpcModel:GetNpcByNpcId(npcId)
	if not npc then return end
	local currentMap = self:GetCurrMap()
	local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Npc )
	local pos = npc:GetPos()
	mapElem:Init( npc:GetNpcId(), npc:GetCid(), pos.x, pos.y )
	currentMap:RemoveElement( mapElem:ToString() )
end

-- npc任务状态改变时图标更新
function MapController:OnNpcStateUpdate(npc, state)
	local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Npc );
	local pos = npc:GetPos();
	mapElem:Init( npc:GetNpcId(), npc:GetCid(), pos.x, pos.y );
	local currentMap = self:GetCurrMap();
	currentMap:UpdateElement( mapElem );
end

-------当前地图Portal--------

function MapController:AddPortal()
	local currentMap = self:GetCurrMap();
	local mapPortals = CPlayerMap:GetMapPortals();
	for _, portal in pairs( mapPortals ) do
		local id = portal.id;
		if t_portal[id] then--删掉t_portal[id].type ~= 6，在大地图中显示出秘境夺宝传送门
			local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Portal );
			mapElem:Init( portal.id, portal.cid, portal.x, portal.y );
			currentMap:AddElement( mapElem );
		end
	end
end

------当前地图MonsterArea------

function MapController:AddMonsterArea()
	local exist = {};-- 防止重复: 地图上同id的Monster只显示一个,表示怪区
	local currentMap = self:GetCurrMap();
	local mapId = currentMap:GetMapId();
	local mapPointCfg = MapPoint[mapId];
	local monsterMap = mapPointCfg and mapPointCfg.monster;
	if not monsterMap then return; end
	for key, mapPointMonster in pairs( monsterMap ) do 
		local id = mapPointMonster.id;
		if not exist[id] then --防止多次添加同种id的怪
			exist[id]  = true;
			local visible = QuestController:GetMonsterNeedShow(id)
			if visible then
				local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_MonsterArea );
				local pos = MapUtils:GetMonsterAreaPos( id, mapId );
				mapElem:Init( id, id, pos.x, pos.y );
				currentMap:AddElement( mapElem );
			end
		end
	end
end

--根据怪物id添加怪区
function MapController:AddMonsterAreaById(id)
	local currentMap = self:GetCurrMap();
	local mapId = currentMap:GetMapId();
	local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_MonsterArea );
	local pos = MapUtils:GetMonsterAreaPos( id, mapId );
	if not pos then return; end
	mapElem:Init( id, id, pos.x, pos.y );
	currentMap:AddElement( mapElem );
end

--根据怪物id移除怪区
function MapController:RemoveMonsterAreaById(id)
	local currentMap = self:GetCurrMap();
	local mapId = currentMap:GetMapId();
	local pos = MapUtils:GetMonsterAreaPos( id, mapId );
	if not pos then return end
	local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_MonsterArea );
	mapElem:Init( id, id, pos.x, pos.y );
	currentMap:RemoveElement( mapElem:ToString() );
end


------当前地图特殊点------

function MapController:AddSpecialElement()
	local currentMap = self:GetCurrMap();
	local mapId = currentMap:GetMapId();
	local mapPointCfg = MapPoint[mapId];
	local specialPoints = mapPointCfg and mapPointCfg.specail;
	if not specialPoints then return; end
	for key, mapPointSpecial in pairs( specialPoints ) do 
		local id = mapPointSpecial.id;
		local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Special );
		mapElem:Init( id, id, mapPointSpecial.x, mapPointSpecial.y );
		currentMap:AddElement( mapElem );
	end
end
---------当前地图挂机点---------

function MapController:AddHangPoint()
	local currentMap = self:GetCurrMap();
	local mapId = currentMap:GetMapId();
	local mapPointCfg = MapPoint[mapId];
	local birthPointMap = mapPointCfg and mapPointCfg.birth;
	if not birthPointMap then return; end
	for key, point in pairs( birthPointMap ) do 
		if point.id == 3 or point.id == 4 then -- 3:黄金挂机点 -- 4:安全挂机点
			local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Hang );
			mapElem:Init( key, key, point.x, point.y, nil, point.id );
			currentMap:AddElement( mapElem );
		end
	end
end


---------当前地图帮派战建筑物(图腾、神像、王座)---------
function MapController:AddUnionWarBuilding()
	if not UnionWarModel:GetIsAtUnionActivity() then return end
	local currentMap = self:GetCurrMap();
	local mapPointCfg = UnionWarConfig.building;
	if not mapPointCfg then return; end
	for key, point in pairs( mapPointCfg ) do 
		local vo = {};
		vo.type = point.type;
		vo.state = UnionWarModel:GetWarBuildingIndex(key);
		local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_UnionWarBuilding );
		mapElem:Init( key, key, point.x, point.y, nil, vo );
		currentMap:AddElement( mapElem );
	end
end

---------当前地图帮派王城战单位---------
function MapController:AddUnionCityUnits()
	if not UnionCityWarModel:GetIsAtUnionActivity() then return end
	local currentMap = self:GetCurrMap();
	for index1, point1 in pairs( unionCityWarbuilding ) do 
		local mapElem1 = MapVOFactory:CreateMapElem( MapConsts.Type_UnionCityUnits );
		local flag1 = {}
		flag1.bType = 1; -- 神兽
		flag1.index = index1;
		if index1 <= 4 then 
			local state = UnionCityWarModel:GetLifePointState(index1);
			if state == 1 then --进攻
				flag1.sType = "JGjzw"
			elseif state == 2 then -- 防守
				flag1.sType = "FSjzw"
			end;
		else
			flag1.sType = point1.type;
		end;
		flag1.tipsType = point1.type
		mapElem1:Init( index1, index1, point1.x, point1.y, nil, flag1 );
		currentMap:AddElement( mapElem1 );
	end
	for index2, point2 in pairs( unioncityWarlifePoint ) do 
		local mapElem2 = MapVOFactory:CreateMapElem( MapConsts.Type_UnionCityUnits );
		local flag2 = {}
		flag2.bType = 2; -- 复活点
		flag2.index = index2;
		if index2 <= 4 then 
			local state = UnionCityWarModel:GetLifePointState(point2.index);
			if state == 1 then --进攻
				flag2.sType = "jgp"
			elseif state == 2 then -- 防守
				flag2.sType = "fsp"
			end;
		else
			flag2.sType = point2.type
		end;
		flag2.tipsType = point2.type
		mapElem2:Init( index2, index2, point2.x, point2.y, nil, flag2 );
		currentMap:AddElement( mapElem2 );
	end
end

function MapController:AddZhanchangUnits()
	if not ActivityController:InActivity() then return end;
	if ActivityController:GetCurrId() ~= ActivityConsts.ZhanChang then return end;
	local currentMap = self:GetCurrMap();
	-- 交付点 ------------------------------
	local mycamp = ActivityZhanChang:GetMyCamp();
	local cfg = ZhChFlagUpPoint[6];
	local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_ZhanchangUnits );
	local flag = {}
	flag.unitType = 1; -- 交付点
	flag.camp = 6;
	mapElem:Init( 6, 6, cfg.x, cfg.y, nil, flag );
	currentMap:AddElement( mapElem );

	local cfg = ZhChFlagUpPoint[7];
	local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_ZhanchangUnits );
	local flag = {}
	flag.unitType = 1; -- 交付点
	flag.camp = 7;
	mapElem:Init( 7, 7, cfg.x, cfg.y, nil, flag );
	currentMap:AddElement( mapElem );

	-- 旗子点 ------------------------------
	local scfg = ActivityZhanChang.zcFlagList;
	for index, info in pairs(scfg) do 
		local cfg2 = ZhChFlagConfig[info.idx]
		if info.canPick == 1 then
			local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_ZhanchangUnits );
			local flag = {}
			flag.unitType = 2; -- 旗子点
			flag.camp = cfg2.camp;
			mapElem:Init( cfg2.id, cfg2.id, cfg2.x, cfg2.y, nil, flag );
			currentMap:AddElement( mapElem );
		end
	end
end

---------当前地图帮派地宫争夺战(旗帜)---------
---[[
function MapController:AddUnionDiGongWarFlag()
	if not UnionDiGongModel:GetIsAtUnionActivity() then return end
	local currentMap = self:GetCurrMap();
	
	-- 柱子1 ------------------------------
	local cfg1 = UnionDiGongConsts.DGFlagUpPoint[1];
	local mapElem1 = MapVOFactory:CreateMapElem( MapConsts.Type_UnionDiGongFlag );
	local flag1 = {}
	flag1.unitType = 1;
	flag1.state =  UnionDiGongModel:GetisMyBuState(1);
	mapElem1:Init( 6, 6, cfg1.x, cfg1.y, nil, flag1 );
	currentMap:AddElement( mapElem1 );

	-- 柱子2 ------------------------------
	local cfg = UnionDiGongConsts.DGFlagUpPoint[2];
	local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_UnionDiGongFlag );
	local flag = {}
	flag.unitType = 2;
	flag.state = UnionDiGongModel:GetisMyBuState(2);
	mapElem:Init( 7, 7, cfg.x, cfg.y, nil, flag );
	currentMap:AddElement( mapElem );
	
end
--]]

-------------主玩家----------

--自己
function MapController:AddMainPlayer()
	local player = MainPlayerController:GetPlayer();
	local roleId = player:GetRoleID();
	local pos = player:GetPos();
	local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_MainPlayer );
	mapElem:Init( roleId, roleId, pos.x, pos.y, player:GetDir() );
	local currentMap = self:GetCurrMap();
	if currentMap:AddElement( mapElem ) then
		player:AddPosMonitor( MapController.PosMonitor , self);----监听自己玩家的位置,对应OnPosChange方法
	end
end

function MapController:RemoveMainPlayer()
	local currentMap = self:GetCurrMap();
	local uid = MapUtils:GetMainPlayerMapUid()
	currentMap:RemoveElement( uid );
	local player = MainPlayerController:GetPlayer();
	if player then
		player:DelPosMonitor( MapController.PosMonitor );
	end
end

--MainPlayer位置改变时的处理
function MapController:OnPosChange(player, pos)
	local roleId = player:GetRoleID();
	local currentMap = self:GetCurrMap();
	for uid, _ in pairs ( self.pointPathList ) do
		local mapElem = currentMap:GetElement(uid);
		if math.abs(mapElem.x - pos.x) <= 50 and math.abs(mapElem.y - pos.y) <= 50 then
			currentMap:RemoveElement( uid );
			self.pointPathList[uid] = nil;
		end
	end
	local uid = MapUtils:GetMainPlayerMapUid();
	currentMap:MoveElement( uid, pos.x, pos.y, player:GetDir() );
	WeatherController:OnCheckMapArea()
	CPlayerMap:FieldChange(pos);
end

function MapController:UpdatePlayerPos()
	self:DelAutoLine()
	local currentMap = self:GetCurrMap()
	local uid = MapUtils:GetMainPlayerMapUid();
	local player = MainPlayerController:GetPlayer()
	if not player then return end
	local pos = player:GetPos()
	if not pos then return end
	currentMap:MoveElement( uid, pos.x, pos.y, player:GetDir() )
end

function MapController:OnMainPlayerRevive()
	self:AddMainPlayer();
end

function MapController:OnMainPlayerDie()
	self:RemoveMainPlayer();
end

-----------------------------------------  当  前  查  看  的  地  图  --------------------------------------------

function MapController:AddLocalNpc()
	local map = self:GetLocalMap();
	local mapId = map:GetMapId();
	local points = MapPoint[mapId];
	if not points then return end;
	local npcMap = points.npc;
	for key, point in pairs( npcMap ) do 
		local npcId = point.id;
		local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Npc );
		mapElem:Init( npcId, npcId, point.x, point.y );
		map:AddElement( mapElem );
	end
end

function MapController:AddLocalPortal()
	local map = self:GetLocalMap();
	local mapId = map:GetMapId();
	local points = MapPoint[mapId];
	if not points then return end;
	local portalMap = points.portal;
	for key, point in pairs( portalMap ) do 
		local portalId = point.id;
		local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Portal );
		mapElem:Init( portalId, portalId, point.x, point.y );
		map:AddElement( mapElem );
	end
end

function MapController:AddLocalMonsterArea()
	local exist = {};-- 防止重复: 地图上同id的Monster只显示一个,表示怪区
	local map = self:GetLocalMap();
	local mapId = map:GetMapId();
	local points = MapPoint[mapId];
	if not points then return end;
	local monsterMap = points.monster;
	if not monsterMap then return; end
	for key, point in pairs( monsterMap ) do 
		local id = point.id;
		if not exist[id] then --防止多次添加同种id的怪
			exist[id]  = true;
			local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_MonsterArea );
			local pos = MapUtils:GetMonsterAreaPos( id, mapId );
			mapElem:Init( id, id, pos.x, pos.y );
			map:AddElement( mapElem );
		end
	end
end

function MapController:AddLocalSpecialElement()
	local map = self:GetLocalMap();
	local mapId = map:GetMapId();
	local mapPointCfg = MapPoint[mapId];
	local specialPoints = mapPointCfg and mapPointCfg.specail;
	if not specialPoints then return; end
	for key, mapPointSpecial in pairs( specialPoints ) do 
		local id = mapPointSpecial.id;
		local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Special );
		mapElem:Init( id, id, mapPointSpecial.x, mapPointSpecial.y );
		map:AddElement( mapElem );
	end
end

function MapController:AddLocalHangPoint()
	local map = self:GetLocalMap();
	local mapId = map:GetMapId();
	local points = MapPoint[mapId];
	if not points then return end;
	local birthPointMap = points.birth;
	if not birthPointMap then return; end
	for key, point in pairs( birthPointMap ) do 
		if point.id == 3 or point.id == 4 then -- 3:黄金挂机点 -- 4:安全挂机点
			local mapElem = MapVOFactory:CreateMapElem( MapConsts.Type_Hang );
			mapElem:Init( key, key, point.x, point.y, nil, point.id );
			map:AddElement( mapElem );
		end
	end
end