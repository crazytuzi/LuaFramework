
--
-- Npc 系统总控制器，
-- 用于系统初始化，提供本系统对外接口
_G.classlist['NpcController'] = 'NpcController'
_G.NpcController = setmetatable({}, {__index = IController})
NpcController.name = "NpcController"
NpcController.objName = 'NpcController'
NpcController.currDialogNpc = nil
NpcController.questNpc = nil
NpcController.FollowDis = 40
NpcController.currDungeonNpcId = 0
NpcController.recallShowDialogTimes = 0;
local Team = {}
local TeamPatrol = {}

function NpcController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_RESP_MAP_OBJ_LIST, self, self.OnCurMapObjList)
	CControlBase:RegControl(self, true)
	CPlayerControl:AddPickListen(self)
	self.bCanUse = true

	return true
end

-- 更新任务状态
function NpcController:UpdateQuestIcon(npcId, state)
	local Npc = NpcModel:GetCurrNpcByNpcId(npcId)
	if Npc then
		Npc.questState = state
		MapController:OnNpcStateUpdate( Npc, state );
	end
end


function NpcController:Update(interval)
	NpcController:CheckCloseDialog()
	NpcController:UpdateQuestNpcPos(interval)
	return true
end

function NpcController:Destroy()
	return true
end

function NpcController:OnEnterGame()
	return true
end

function NpcController:OnChangeSceneMap()
	NpcModel:DeleteAllNpc()
	NpcModel:DeleteCurMapNpcList()
	NpcController:ResetQuestNpcPos()
	NpcController:SetCurrDungeonNpcId(0)
	return true
end

function NpcController:OnLeaveSceneMap()
	NpcModel:DeleteAllNpc()
	NpcModel:DeleteCurMapNpcList()
	NpcController:SetCurrDungeonNpcId(0)
	return true
end

function NpcController:OnLineChange()
	NpcModel:DeleteCurMapNpcList()
end

function NpcController:OnDead()

end

function NpcController:OnPosChange(newPos)

end

function NpcController:OnMouseWheel()
	
end

function NpcController:OnBtnPick(button, type, node)
	self:OnMouseClick(node)
end

function NpcController:OnRollOver(type, node)
	self:OnMouseOver(node)
end

function NpcController:OnRollOut(type, node)
	self:OnMouseOut(node)
end

function NpcController:OnMouseOut(node)
    if node == nil then return; end
	local npcAvatar = node
	local cid = npcAvatar.cid
	local npc = NpcModel:GetNpc(cid)
	if npc and npc.__type and npc.__type == "npc" then
		self:MouseOutNpc(npc)
	end
end

function NpcController:OnMouseOver(node)
    if node == nil then return; end
    local npcAvatar = node
	local cid = npcAvatar.cid
	local npc = NpcModel:GetNpc(cid)
	if npc and npc.__type and npc.__type == "npc" then
		self:MouseOverNpc(npc)
	end
end

function NpcController:OnMouseClick(node)
	local npcAvatar = node
	local cid = npcAvatar.cid
	local npc = NpcModel:GetNpc(cid)
	if npc and npc.__type and npc.__type == "npc" then
		self:GoToTalkWithNpc(npc)
	end
end

function NpcController:GoToTalkWithNpc( npc )
	local completeFuc = function()
		NpcController:ShowDialog(npc.npcId)
		SkillController:ClickLockChar(npc.cid)
	end
	if self:CheckOpenDialogDistance(npc.npcId) then
		completeFuc()
	else
		local config = t_npc[npc.npcId]
		if not config then
			return false
		end
		local config_dis = config.open_dis
		NpcController:RunToTargetNpc(npc, config_dis/2, completeFuc)
	end
end

function NpcController:MouseOverNpc(npc)
	if not self:IsCanClick(npc.npcId) then
		return
	end
	if npc.avatar then
		local light = Light.GetEntityLight(enEntType.eEntType_Npc,CPlayerMap:GetCurMapID());
		npc.avatar:SetHighLight( light.hightlight );
    end
    --CCursorManager:AddState("dialog")
    CCursorManager:AddStateOnChar("dialog", npc.cid)
end

function NpcController:MouseOutNpc(npc)
	if not self:IsCanClick(npc.npcId) then
		return
	end
	if npc.avatar then 
		npc.avatar:DelHighLight()
    end
    CCursorManager:DelState("dialog")
end

--[[
npc info 
id 
x
y
dir
]]

function NpcController:AddNpcToNpcList(npcInfo)
	local npcId = npcInfo.configId
	local cid = npcInfo.charId
	local oldNpc = NpcModel:GetNpc(cid)
    if oldNpc then
    	Debug("npc add: ", cid)
        return
	end
	local x = npcInfo.x
	local y = npcInfo.y
	local faceto = npcInfo.faceto
	local show = true
	if isDebug and _G.isRecordRes then
		_Archive:beginRecord();
	end
	local isNoLoader = false;
	if t_npc[npcId] and t_npc[npcId].isHideLoading==1 then
		isNoLoader = true;
	end
	local npc = Npc:NewNpc(npcId, cid, x, y, faceto, show,0,isNoLoader)
	if not npc then
		return
	end
	NpcController:ShowNpc(npc)
	NpcModel:AddNpc(npc)
	local visible = QuestController:GetNpcNeedShow(npcId);
	npc:HideSelf(not visible);
	
	if visible and StoryController:IsStorying() then
		npc:ShowSelfByStory()
	end
	if isDebug and _G.isRecordRes then
		_Archive:endRecord()
		local recordlist = _Archive:getRecord();
		local file = _File.new();
		file:create("record/npc/"..npcId..".txt" );
		for _,f in ipairs(recordlist) do
			file:write(f .. "\r");
		end
		file:close();
	end
end

-- 大地图中的npc
function NpcController:AddNpcToCurMapNpcList(npcInfo)
	local npcId = npcInfo.id
	local cid = npcInfo.cid
	local x = npcInfo.x
	local y = npcInfo.y
	local faceto = nil
	local show = false
	local npc = Npc:NewNpc(npcId, cid, x, y, faceto, show)
	if not npc then
		return
	end
	NpcModel:AddCurMapNpc(npc)
	local visible = QuestController:GetNpcNeedShow(npcId);
	npc:HideSelf(not visible);
end

function NpcController:DeleteNpcByCfgId(npcId)
	local npc = NpcModel:GetCurrNpcByNpcId(npcId)
    if not npc then
        return
	end
	if not npc.avatar then
		return
	end
	npc.avatar:ExitMap()
	NpcModel:DeleteNpc(npc)
	npc.avatar = nil
	npc = nil
end

function NpcController:DeleteNpc(cid)
	local npc = NpcModel:GetNpc(cid)
    if not npc then
    	Debug("npc delete: ", cid)
        return
	end
	if not npc.avatar then
		return
	end
	local configid = npc:GetNpcId();
	NpcModel:DeleteNpc(npc)
	npc.avatar:ExitMap()
	npc.avatar = nil
	npc = nil
	return configid;
end

function NpcController:UpdateBigMap()

end

function NpcController:ShowNpc(npc)
	--Debug(npc.x, npc.y, npc.faceto)
	npc.avatar:EnterMap(npc.x, npc.y, npc.faceto, npc.offsetZ)
	npc.avatar:ExecIdleAction()
	
	local npcCfg = t_npc[npc.npcId]
	if npcCfg and npcCfg.potrolId and npcCfg.potrolId ~= 0 then
		npc:SetPatrol(StoryScriptManager:GetScript(npc.npcId), npcCfg.potrolId)
	end
	-- self:AddTeamObj(npc.Patrol.dwTeamId,npc)
end

--打开NPC对话面板
function NpcController:ShowDialog(npcId)
	if not self:IsCanDialog(npcId) then
		self.recallShowDialogTimes = self.recallShowDialogTimes + 1;
		--todo 在跨场景后,这里的调用会早于服务器返回的NPC列表，所以延迟重复调用下 yanghongbin
		if self.recallShowDialogTimes <= 1 then
			TimerManager:RegisterTimer(function()
				self:ShowDialog(npcId);
				return;
			end,1000,1);
		end
		return
	end
	self.recallShowDialogTimes = 0;
	local npc = NpcModel:GetCurrNpcByNpcId(npcId)
	--该NPC播放对话动作和音效
	if npc then
		npc:DialogAction()
	end
	if UINpcDialogBox:IsShow() then
		UINpcDialogBox:Hide()
	end
	self.currDialogNpc = npcId
	UINpcDialogBox:Open(npcId)
	--NPC转向
	if NpcController:IsTurn(npcId) then
		NpcController:TurnToPlayer(npcId)
		NpcController:TurnToNpc(npcId)
	end
	CCursorManager:DelState("dialog")
end

function NpcController:TurnToPlayer(npcId)
	local npc = NpcModel:GetCurrNpcByNpcId(npcId)
	if not npc then
		return
	end
    local pos1 = npc:GetPos()
    local pos = MainPlayerController:GetPlayer():GetPos()
    local dir = GetDirTwoPoint(pos1, pos)
    CharController:OnPlayerChangeDir(npc.cid, dir, 300)
end

function NpcController:TurnToNpc(npcId)
	local npc = NpcModel:GetCurrNpcByNpcId(npcId)
	if not npc then
		return
	end
    local pos = npc:GetPos()
    local selfRoleID = MainPlayerController:GetRoleID()
    local pos1 = MainPlayerController:GetPlayer():GetPos()
    local dir = GetDirTwoPoint(pos1, pos)
    CharController:OnPlayerChangeDir(selfRoleID, dir, 300)
end

function NpcController:TurnToDefault(npcId)
	local npc = NpcModel:GetCurrNpcByNpcId(npcId)
	if not npc then
		return
	end
	CharController:OnPlayerChangeDir(npc.cid, npc.faceto, 300)
end

function NpcController:GetNpc(cid)
	return NpcModel:GetNpc(cid)
end

function NpcController:IsCanDialog(npcId)
	if not self:IsCanClick(npcId) then
		return false
	end
	if not self:IsCanOpenDialog(npcId) then
		return false
	end
	if not self:CheckOpenDialogDistance(npcId) then
		return false
	end
	return true
end

function NpcController:IsCanOpenDialog(npcId)
	local config = t_npc[npcId]
	if not config then
		return false
	end
	if config.open_dialog == true then
		return true
	else
		return false
	end
end

function NpcController:IsCanClick(npcId)
	local config = t_npc[npcId]
	if not config then
		return false
	end
	if config.is_click == 2 then
		return true
	else
		return false
	end
end

function NpcController:CheckOpenDialogDistance(npcId)
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return false
	end
	local config = t_npc[npcId]
	if not config then
		return false
	end
	local npc = NpcModel:GetNpcByNpcId(npcId) or NpcModel:GetCurrNpcByNpcId(npcId)
	if not npc then
		return false
	end
	local pos1 = selfPlayer:GetPos()
	local pos2 = npc:GetPos()
	if not pos1 or not pos2 then
		return false
	end
	local config_dis = config.open_dis
	local dis = GetDistanceTwoPoint(pos1, pos2)
	if dis >= config_dis + 1 then
		return false
	end
	return true
end

function NpcController:CheckCloseDialogDistance(npcId)
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		return false
	end
	local config = t_npc[npcId]
	if not config then
		return false
	end
	local npc = NpcModel:GetNpcByNpcId(npcId)
	if not npc then
		return false
	end

	local pos1 = selfPlayer:GetPos()
	local pos2 = npc:GetPos()
	if not pos1 or not pos2 then
		return false
	end
	local config_dis = config.close_dis
	local dis = GetDistanceTwoPoint(pos1, pos2)
	if dis >= config_dis then
		return false
	end
	return true
end

function NpcController:CheckCloseDialog()
	local npcId = self.currDialogNpc
	if not npcId then
		return
	end
	if self:CheckCloseDialogDistance(npcId) then
		return
	end
	
	--关闭掉当前的NPC对话窗口
	if UINpcDialogBox:IsShow() then
		UINpcDialogBox:Hide()
	end
	if UINpcQuestPanel:IsShow() then
		UINpcQuestPanel:Close();
	end
	if UIDungeonDialogBox:IsShow() then
		UIDungeonDialogBox:Hide()
	end
	if UIRandomQuestNpc:IsShow() then
		UIRandomQuestNpc:Hide()
	end
	if UIRandomDungeonNpc:IsShow() then
		UIRandomDungeonNpc:Hide()
	end
	if UIMarryNpcBox:IsShow() then 
		UIMarryNpcBox:Hide();
	end;
	if UITaoFaQuestNpc:IsShow() then
		UITaoFaQuestNpc:Hide();
	end
	if UIAgoraQuestNpc:IsShow() then
		UIAgoraQuestNpc:Hide();
	end

	self:WhenCloseDialog(npcId)
end

--NPC对话窗口关闭时
function NpcController:WhenCloseDialog(npcId)
	self.currDialogNpc = nil
	--恢复原来转向
	self:TurnToDefault(npcId)
end

function NpcController:IsTurn(npcId)
	local config = t_npc[npcId]
	if not config then
		return false
	end
	if config.is_turn == 1 then
		return true
	else
		return false
	end
end

function NpcController:SendGetCurMapObjList(objType)
	local msg = ReqMapObjListMsg:new()
	msg.objType = objType
	MsgManager:Send(msg)
end

function NpcController:OnCurMapObjList(msg)
	local objInfoList = msg.objInfo
	local charType = msg.objType
	if charType == enEntType.eEntType_Npc then
		for i = 1, #objInfoList do
			local npcInfo = objInfoList[i]
			self:AddNpcToCurMapNpcList(npcInfo)
		end
	elseif charType == enEntType.eEntType_Portal then
		CPlayerMap:ClearLocalPortalPfx()
		for i = 1, #objInfoList do
			local portalInfo = objInfoList[i]
	        MainPlayerController:addMapPortalPoint(portalInfo)
		end
	end
	MapController:OnCurMapNpcResp()
end

function NpcController:RunToTargetNpc(npc, distance, stopFucntion)
    if not npc then
    	return
    end

    local npcPos = npc:GetPos()
    if not npcPos then
    	return
    end

    local dir = npc:GetDir()

    local posX, posY = GetPosByDis(npcPos, dir, distance)

    local mapId = CPlayerMap:GetCurMapID()
	MainPlayerController:DoAutoRun(mapId, _Vector3.new(posX, posY, 0), stopFucntion)
end

---------------------------------------------------------------------------
-- npc脚本控制逻辑
---------------------------------------------------------------------------
function NpcController:AddStoryNpc(npcInfo)
	local npcId = npcInfo.configId
	local gid = npcInfo.gid
	local x = npcInfo.x
	local y = npcInfo.y
	local faceto = npcInfo.faceto
	local show = true
	local isNoLoader = true
	-- FTrace(npcInfo)
	local npc = Npc:NewNpc(npcId, gid, x, y, faceto, show, npcInfo.offsetZ, isNoLoader)
	if not npc then
		FPrint('npcCreateFailed')
		return
	end
	npc.isShowHeadBoard = false
	self:ShowNpc(npc)
	NpcModel:AddStoryNpc(gid, npc)
end

function NpcController:DeleteStoryNpc(gid)
	local npc = NpcModel:GetStoryNpc(gid)
    if not npc then
        return
    else
	end
	if not npc.avatar then
		return
	end
	npc.avatar:ExitMap()
	NpcModel:DeleteStoryNpc(npc)
	npc:destroy()
	npc = nil
end

function NpcController:AddTestNpc(npcInfo)
	local npcId = npcInfo.configId
	local gid = npcInfo.gid
	local x = npcInfo.x
	local y = npcInfo.y
	local faceto = npcInfo.faceto
	local show = true
	local npc = Npc:NewNpc(npcId, gid, x, y, faceto, show)
	if not npc then
		FPrint('npcCreateFailed')
		return nil
	end
	self:ShowNpc(npc)
	return npc
end

function NpcController:AddQuestNpc(npcInfo)
	local npcId = npcInfo.configId
	local cid = npcInfo.cid
	local x = npcInfo.x
	local y = npcInfo.y
	local faceto = npcInfo.faceto
	local show = true
	local isNoLoader = true
	local npc = Npc:NewNpc(npcId, cid, x, y, faceto, show, 0, isNoLoader)
	if not npc then
		FPrint('npcCreateFailed')
		return
	end
	local avatar = npc:GetAvatar()
	if not avatar then
		return
	end
	--avatar.dnotDelete = true
	npc.isShowHeadBoard = true
	self:ShowNpc(npc)
	return npc
end

function NpcController:AddQuestNpcByQuestId(questId, isBegin)
	local questInfo = t_quest[questId]
	if not questInfo then
		return
	end
	local npcId = 0
	if isBegin == 1 then
		npcId = questInfo.beginNPC
	else
		npcId = questInfo.endNPC
	end
	if npcId == 1 then
		if not NpcController.questNpc then
			return
		end
		NpcController.questNpc:DeleteSelf()
		NpcController.questNpc = nil
		return
	end
	local cfgNpc = t_npc[npcId]
	if not cfgNpc then
		return
	end
	if NpcController.questNpc then
		return
	end
	local npcInfo = {}
	npcInfo.configId = npcId
	local player = MainPlayerController:GetPlayer()
	if not player then
		return
	end
	local pos = player:GetPos()
	if not pos then
		return
	end
	npcInfo.x = player:GetPos().x
	npcInfo.y = player:GetPos().y
	npcInfo.faceto = player:GetDir()
	NpcController.questNpc = NpcController:AddQuestNpc(npcInfo)
	NpcController.questNpc.talkTime = GetCurTime()
end

function NpcController:UpdateQuestNpcPos(interval)
	local npc = NpcController.questNpc
	if not npc then
		return
	end
	npc:Update(interval)
	if not npc.mwDiff then
		npc.mwDiff = _Vector3.new()
	end
	local pos = MainPlayerController:GetPlayer():GetPos()
	local speed = MainPlayerController:GetPlayer():GetSpeed()
	local npcPos = npc:GetPos()
	_Vector3.sub(pos, npcPos, npc.mwDiff)
	local dis = npc.mwDiff:magnitude()
	if dis > NpcController.FollowDis then
		npc.mwDiff = npc.mwDiff:normalize():mul(dis - NpcController.FollowDis + 0.01)
		_Vector3.add(npc.mwDiff, npcPos, npc.mwDiff)
		npc:GetAvatar():MoveTo(npc.mwDiff, function() end, speed, nil, true)
		npc:GetAvatar():ExecMoveAction()
	else
		npc:GetAvatar():StopMoveAction()
	end
	if npc.talkTime and GetCurTime() - npc.talkTime > 10000 then
		StoryController:ShowBubble(57, npc)
		npc.talkTime = nil
		npc.delayTime = TimerManager:RegisterTimer(function()
			StoryController:RemoveBubble()
		end, 4000, 1)
	end
end

local npcVector = _Vector3.new()
function NpcController:ResetQuestNpcPos()
	local npc = NpcController.questNpc
	if not npc then
		return
	end
	local avatar = npc:GetAvatar()
	if not avatar then
		return
	end
	local player = MainPlayerController:GetPlayer()
	if not player then
		return
	end
	local pos = player:GetPos()
	local dir = player:GetDirValue()
	npcVector.x = pos.x - 20 * math.sin(dir)
	npcVector.y = pos.y + 20 * math.cos(dir)
	avatar:EnterMap(npcVector.x, npcVector.y, dir, 0)
	avatar:ExecIdleAction()
end

function NpcController:DeleteQuestNpc()
	if NpcController.questNpc then
		NpcController.questNpc:DeleteSelf()
		NpcController.questNpc = nil
	end
end

--------客户端根据地编文件自己加载NPC--------
function NpcController:LoadAllLocalNpc()
	local currMapId = CPlayerMap:GetCurMapID()
	local mapInfo = MapPoint[currMapId]
	local npcList = mapInfo.npc
	for index, config in pairs(npcList) do
		local npcInfo = {}
		npcInfo.configId = config.id
		npcInfo.index = index
		npcInfo.x = config.x
		npcInfo.y = config.y
		npcInfo.faceto = config.dir
		self:AddLocalNpc(npcInfo)
	end
end

function NpcController:DeleteAllLocalNpc()
	local currMapId = CPlayerMap:GetCurMapID()
	local mapInfo = MapPoint[currMapId]
	if not mapInfo then return end
	local npcList = mapInfo.npc
	for index, _ in pairs(npcList) do
		self:DeleteLocalNpc(index)
	end
end

function NpcController:AddLocalNpc(npcInfo)
	local npcId = npcInfo.configId
	local index = npcInfo.index
	local x = npcInfo.x
	local y = npcInfo.y
	local faceto = npcInfo.faceto
	local show = true
	local isNoLoader = true
	local npc = Npc:NewNpc(npcId, index, x, y, faceto, show, 0, isNoLoader)
	if not npc then
		return
	end
	self:ShowNpc(npc)
	NpcModel:AddLocalNpc(npc)
end

function NpcController:DeleteLocalNpc(index)
	local npc = NpcModel:GetLocalNpc(index)
    if not npc then
        return
    else
	end
	if not npc.avatar then
		return
	end
	npc.avatar:ExitMap()
	NpcModel:DeleteLocalNpc(npc)
	npc:destroy()
	npc = nil
end

function NpcController:SetCurrDungeonNpcId(id)
	NpcController.currDungeonNpcId = id
end