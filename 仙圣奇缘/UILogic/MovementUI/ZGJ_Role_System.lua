RoleSystem = class("RoleSystem")
RoleSystem.__index = RoleSystem

COST = 
{
	YueLi = 1,
	YuanBao = 2,
}

local speed = 300

--起始点坐标
local posX_origin
local posY_origin

function RoleSystem:getBlockPosX(posY)
	if self.bBlocked then
		return self.block_posX - 300 + posY / 1.5
	end
	return 999999
end

function RoleSystem:setBlocked(bBlocked)
	self.bBlocked = bBlocked
	if bBlocked then
		self:resetRole()
	end
end

function RoleSystem:getAutoFight()
	return self.bAutoFight
end

--自动战斗
function RoleSystem:setAutoFight(bAutoFight)
	self.bAutoFight = bAutoFight
	self.Image_Floor:setTouchEnabled(not bAutoFight)
	if not self.role_Me then
		return
	end
	local pos = self.role_Me:getPosition()
	--if bAutoFight and self.tbMonster.nHp > 0 then
	if bAutoFight then
		if self.role_Boss then
			pos = self.role_Boss:getPosition()
		else
			pos = CCPoint(self.border_Right, 320)
		end
		self.role_Me:moveto(pos.x, pos.y)
	else
		self.role_Me:run(false)
	end
	
end

--隐藏其他玩家
function RoleSystem:setHidePlayer(bHidePlayer)
	for k, v in pairs(self.tbRoles) do
		v:setVisible(not bHidePlayer)
	end
	self.role_Me:setVisible(true)
end

--重置玩家
function RoleSystem:resetRole()
	self.role_Me:setPosition(CCPoint(posX_origin, posY_origin))
end

function RoleSystem:getBoss()
	if not self.bInBattle then
		return self.role_Boss
	end
end

function RoleSystem:getBossDestination()
	if self.role_Boss then
		local pos = self.role_Boss:getDestination()
		return CCPoint(pos.x, pos.y)
	else
		return CCPoint(self.border_Right, 200)
	end
end

function RoleSystem:initSceneInfo(sceneID)
	local tbScene = g_DataMgr:getCsvConfigByOneKey("ActivityScence", sceneID)
	self.border_Left = 640
	self.border_Right = tbScene.MeshEndPosX - 640
	self.block_posX = tbScene.BlockEndPosX
	self.MeshEndPosY = tbScene.MeshEndPosY
	Role:static_init(self.Image_Background, self.Image_Floor, self.border_Left, self.border_Right)
end

--玩家进入场景，发送玩家自己再地图中的初始信息 NotifyRoleEnterScene
function RoleSystem:enterSceneResponse(tbMsg)
	local msg = zone_pb.NotifyRoleEnterScene()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	
	self:initSceneInfo(msg.map_id)

	local nCardID = 3001
	if g_Hero:getMasterSex() ~= 1 then
		nCardID = 3002
	end
	if not self.role_Me then
		self.role_Me = Role.new(self.Panel_Player, nCardID, g_Hero:getMasterName(), ROLETYPE.ME)
		self.tbRoles[g_MsgMgr:getUin()] = self.role_Me
	end
	posX_origin = msg.pos.x
	posY_origin = msg.pos.y
	self.role_Me:setPosition(CCPoint(msg.pos.x, msg.pos.y))

	if macro_pb.SceneType_WorldBoss == self.nSceneType or macro_pb.SceneType_GuildBoss == self.nSceneType then --以下处理世界BOSS
		if macro_pb.MoveBlockType_NULL == msg.blockType then
			self.bBlocked = false
		else
			self.bBlocked = true
			if macro_pb.MoveBlockType_DeadCD == msg.blockType then
				cclog("me dead")
				self.role_Me:dead(true)
			end
		end
		--世界BOSS2阻挡
		g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_Block, self.bBlocked)

		self.bInBattle = false
		--激活自动战斗
		self:setAutoFight(self.bAutoFight or false)
	elseif macro_pb.SceneType_Guild == self.nSceneType then
		self.bBlocked = false
		g_WndMgr:openWnd("Game_JiHuiSuo")
	end


end

--转发玩家的移动请求转折点到其视野内的玩家 NotifyMovePointsToNearby
function RoleSystem:nearbyMoveResponse(tbMsg)
	local msg = zone_pb.NotifyMovePointsToNearby()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	local role = self.tbRoles and self.tbRoles[msg.uin]
	if role then
		for key, value in ipairs(msg.move_pos) do
			if key == 1 then
				role:setPosition(CCPoint(value.x, value.y))
			else
				role:moveto(value.x, value.y)
			end
		end
	end
end

-- MSGID_MOVE_NOTIFY_MOVE_STOP = 824;	// 到了目标点移动停止时，通知周围玩家我的位置信息 NotifyMeToNearbyOnMoveStop
function RoleSystem:nearbyStopResponse(tbMsg)
	local msg = zone_pb.NotifyMeToNearbyOnMoveStop()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	local role = self.tbRoles and self.tbRoles[msg.uin]
	if role then
		role:setPosition(CCPoint(msg.pos.x, msg.pos.y))
	end
end

--通知我加入其他玩家到我的视野 MoveNotifyMeAddOther
function RoleSystem:addOthersResponse(tbMsg)
	local msg = zone_pb.MoveNotifyMeAddOther()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	if msg.other then
		for k, v in ipairs(msg.other) do
			if not self.Panel_Player then 
				return
			end
			local panel = self.Panel_Player:clone()
			local role = self.tbRoles and self.tbRoles[msg.uin]
			if not role then
				role = Role.new(panel, v.player_config_id, v.name, ROLETYPE.OTHERS)
				role:addParent(self.Image_Floor)
			end
			--role:setVisible(true)
			role:setDirection(v.dir < macro_pb.DirType_LeftDown)
			
			role:setPosition(CCPoint(v.pos.x, v.pos.y))
			for key, value in ipairs(v.move_pos) do
				if key == 1 then
					role:setPosition(CCPoint(value.x, value.y))
				else
					role:moveto(value.x, value.y)
				end
			end
			self.tbRoles[v.uin] = role
		end
	end
end

--通知我从视野内移除其他玩家 MoveNotifyMeRemoveOther
function RoleSystem:removeOthersResponse(tbMsg)
	local msg = zone_pb.MoveNotifyMeRemoveOther()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	if msg.uin and self.tbRoles then
		for k, v in ipairs(msg.uin) do
            if self.tbRoles[v] ~= nil then
			    self.tbRoles[v]:destroy()
			    self.tbRoles[v] = nil
            end
		end
	end
end

-- 通知其他玩家将我加入到视野内 MoveNotifyOtherAddMe
function RoleSystem:otherAddMeResponse(tbMsg)
	local msg = zone_pb.MoveNotifyOtherAddMe()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	if msg.me then
		local v = msg.me
		if not self.Panel_Player then 
			return
		end
		local panel = self.Panel_Player:clone()
		role = Role.new(panel, v.player_config_id, v.name, ROLETYPE.OTHERS)
		role:addParent(self.Image_Floor)
		role:setPosition(CCPoint(v.pos.x, v.pos.y))
		for key, value in ipairs(v.move_pos) do
			if key == 1 then
				role:setPosition(CCPoint(value.x, value.y))
			else
				role:moveto(value.x, value.y)
			end
		end
		self.tbRoles[v.uin] = role
	end
end

--通知其他玩家将我从视野内移除 MoveNotifyOtherRemoveMe
function RoleSystem:otherRemoveMeResponse(tbMsg)
	local msg = zone_pb.MoveNotifyOtherRemoveMe()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	local role = self.tbRoles and self.tbRoles[msg.uin]
	if role then
		role:destroy()
		self.tbRoles[msg.uin] = nil
	end
end

--通知我加入MONSTER到我的视野  MoveNotifyMeAddMonster
function RoleSystem:addMonsterResponse(tbMsg)
	local msg = zone_pb.MoveNotifyMeAddMonster()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	local tbMonster = msg.monster
	local pos = tbMonster.pos

	if not self.role_Boss then
		if not self.Panel_Player then 
			return
		end
		local panel = self.Panel_Player:clone()
		self.role_Boss = Role.new(panel, tbMonster.monster_config_id, "", ROLETYPE.BOSS)
		self.role_Boss:addParent(self.Image_Floor)
	end
	self.role_Boss:setVisible(true)
	self.role_Boss:setDirection(tbMonster.dir < macro_pb.DirType_LeftDown)
	self.role_Boss:setPosition(CCPoint(pos.x, pos.y))
	self.role_Boss:setDestination(CCPoint(pos.x, pos.y))
	for key, value in ipairs(tbMonster.move_pos) do
		if key == 1 then
			self.role_Boss:setPosition(CCPoint(value.x, value.y))
		else
			self.role_Boss:moveto(value.x, value.y)
		end
	end
end

--通知我从视野内移除MONSTER  MoveNotifyMeRemoveMonster
function RoleSystem:removeMonsterResponse(tbMsg)
	local msg = zone_pb.MoveNotifyMeRemoveMonster()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

    if self.role_Boss then
	    self.role_Boss:setVisible(false)
    end
end

function RoleSystem:bossDead()
	if self.role_Boss then
		self.role_Boss:destroy()
		self.role_Boss = nil
	end
end

--boss 移动
function RoleSystem:bossMoveResponse(tbMsg)
	local msg = zone_pb.NotifyMonsterMovePointsToNearby()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	if self.role_Boss then
		for key, value in ipairs(msg.move_pos) do
			if key == 1 then
				self.role_Boss:setPosition(CCPoint(value.x, value.y))
			else
				self.role_Boss:moveto(value.x, value.y)
			end
		end
	end
end

function RoleSystem:myMove(pos)
	pos.y = math.min(pos.y, self.MeshEndPosY or 640)
	g_FormMsgSystem:PostFormMsg(FormMsg_Movement_Cursor, {bVisible = true, pos = CCPoint(pos.x, pos.y)})
	if self.role_Me then
		self.role_Me:moveto(pos.x, pos.y)
	end
end

--玩家的移动请求	RoleMoveRequest
function RoleSystem:requestMove(startPos, endPos)
    local msg = zone_pb.RoleMoveRequest()
    local start_pos = zone_pb.MapPos()
    start_pos.x = startPos.x
    start_pos.y = startPos.y
    local end_pos = zone_pb.MapPos()
    end_pos.x = endPos.x
    end_pos.y = endPos.y
    table.insert(msg.move_pos, start_pos)
    table.insert(msg.move_pos, end_pos)
    g_MsgMgr:sendMsg(msgid_pb.MSGID_MOVE_REQUEST, msg)
end

--玩家的移动响应 RoleMoveResponse
function RoleSystem:requestMoveResponse(tbMsg)
	local msg = zone_pb.RoleMoveResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	if msg.res ~= macro_pb.MoveResultType_Succ and self.role_Me then
		self.role_Me:setPosition(CCPoint(msg.pos.x, msg.pos.y))
	end
	
end

--进入消息
function RoleSystem:requestEnter(nType)
	local msg = zone_pb.EnterSceneRequest()
	msg.scene_type = nType
	g_MsgMgr:sendMsg(msgid_pb.MSGID_MOVE_ENTER_SCENE_REQUEST, msg)
	self.nSceneType = nType
end

--退出消息
function RoleSystem:requestExit()
    g_MsgMgr:sendMsg(msgid_pb.MSGID_MOVE_EXIT_SCENE_REQUEST, nil)
end

function RoleSystem:requestAttack()
	self.bInBattle = true
	self.Image_Floor:setTouchEnabled(false)
	local wnd = g_WndMgr:getWnd("Game_WorldBossRank")
	if wnd then
		g_WndMgr:closeWnd("Game_WorldBossRank", function ()
			g_WBSystem:requestAttack()
		end)
	else
		g_WBSystem:requestAttack()
	end
end

function RoleSystem:clearCD()
	self.bBlocked = false
	g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_Block, self.bBlocked)
	self.role_Me:dead(false)
end

function RoleSystem:init(widget)
	self.rootWidget = widget
	self.Image_Background = self.rootWidget:getChildAllByName("Image_Background")
	self.Image_Floor = self.rootWidget:getChildAllByName("Image_Floor")
	self.Panel_Player = self.rootWidget:getChildAllByName("Panel_Player")

	self.tbRoles = {}

	--世界BOSS相关
	self.bAutoFight = false
end

function RoleSystem:ctor()
	-- MSGID_MOVE_ENTER_SCENE = 820;			// 玩家进入场景，发送玩家自己再地图中的初始信息 NotifyRoleEnterScene
	-- MSGID_MOVE_REQUEST = 821;	// 玩家的移动请求	RoleMoveRequest
	-- MSGID_MOVE_RESPONSE = 822;	// 玩家的移动响应 RoleMoveResponse
	-- MSGID_MOVE_SYN_MOVE_PATH = 823; //转发玩家的移动请求转折点到其视野内的玩家 NotifyMovePointsToNearby
	-- MSGID_MOVE_NOTIFY_MOVE_STOP = 824;	// 到了目标点移动停止时，通知周围玩家我的位置信息 NotifyMeToNearbyOnMoveStop
	-- MSGID_MOVE_NOTIFY_OTHER_ADD_ME = 824;	//通知其他玩家将我加入到视野内 MoveNotifyOtherAddMe
	-- MSGID_MOVE_NOTIFY_ME_ADD_OTHER = 825;	//通知我加入其他玩家到我的视野 MoveNotifyMeAddOther
	-- MSGID_MOVE_NOTIFY_ME_ADD_MONSTER = 826;	//通知我加入MONSTER到我的视野  MoveNotifyMeAddMonster
	-- MSGID_MOVE_NOTIFY_OTHER_REMOVE_ME = 827;	//通知其他玩家将我从视野内移除 MoveNotifyOtherRemoveMe
	-- MSGID_MOVE_NOTIFY_ME_REMOVE_OTHER = 828;	//通知我从视野内移除其他玩家 MoveNotifyMeRemoveOther
	-- MSGID_MOVE_NOTIFY_ME_REMOVE_MONSTER = 829;	//通知我从视野内移除MONSTER  MoveNotifyMeRemoveMonster

	-- MSGID_MOVE_ACTIVITY_PRE_OPEN = 834;			//通知boss副本3分钟后开启  MoveNotifyBossPre90sOpen
	-- MSGID_MOVE_ACTIVITY_OPEN = 835;			//通知boss副本开启
	-- MSGID_MOVE_ACTIVITY_NOTIFY_FIGHT = 836;		//通知和boss相遇，启动战斗 MoveNotifyHitBoss
	-- MSGID_MOVE_NOTIFY_MONSTER_MOVE_PATH = 837;	// 怪物移动时转发怪物的移动路径点 NotifyMonsterMovePointsToNearby
	-- MSGID_MOVE_NOTIFY_BOSS_HURT_RANK = 838;		// 通知boss伤害排行 NotifyBossHurtRank hurtRankResponse
	-- MSGID_MOVE_BROADCAST_BOSS_HP = 839;			// 广播boss血量到场景中所有玩家 BroadcastBossHpToScene updateBossHpResponse
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_ENTER_SCENE,handler(self,self.enterSceneResponse))
	
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_RESPONSE,handler(self,self.requestMoveResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_SYN_MOVE_PATH,handler(self,self.nearbyMoveResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_NOTIFY_MOVE_STOP,handler(self,self.nearbyStopResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_NOTIFY_OTHER_ADD_ME,handler(self,self.otherAddMeResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_NOTIFY_ME_ADD_OTHER,handler(self,self.addOthersResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_NOTIFY_ME_ADD_MONSTER,handler(self,self.addMonsterResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_NOTIFY_OTHER_REMOVE_ME,handler(self,self.otherRemoveMeResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_NOTIFY_ME_REMOVE_OTHER,handler(self,self.removeOthersResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_NOTIFY_ME_REMOVE_MONSTER,handler(self,self.removeMonsterResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_NOTIFY_MONSTER_MOVE_PATH,handler(self,self.bossMoveResponse))

end
function RoleSystem:destroy()
   	if self.role_Boss then
   		self.role_Boss:destroy()
   	end
   	for k, v in pairs(self.tbRoles) do
   		v:destroy()
   	end
   	self.role_Me = nil
   	self.role_Boss = nil
	self.Panel_Player = nil
	Role:static_destroy()
end   

g_RoleSystem = RoleSystem.new()