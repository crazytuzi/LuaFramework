--Author:		bishaoqing
--DateTime:		2016-05-31 11:59:40
--Region:		多人守卫管理
local MultiPlayerCtr = class('MultiPlayerCtr')
-- local MultiPlayerDetailTeam = require("src/layers/fb/newMultiPlayer/MultiPlayerDetailTeam")
-- local MultiPlayerTeam = require("src/layers/fb/newMultiPlayer/MultiPlayerTeam")
local commConst = require("src/config/CommDef")
local MRoleStruct = require("src/layers/role/RoleStruct")
local Arg = require("src/layers/fb/newMultiPlayer/MultiPlayerCfg")

-- local MultiMyTeamPanel = require("src/layers/fb/newMultiPlayer/MultiMyTeamPanel")
-- local MultiTeamPanel = require("src/layers/fb/newMultiPlayer/MultiTeamPanel")
local MultiPlayerMainPanel = require("src/layers/fb/newMultiPlayer/MultiPlayerMainPanel")
-- local MultiInvitePanel = require("src/layers/fb/newMultiPlayer/MultiInvitePanel")
local scheduler = cc.Director:getInstance():getScheduler()

local MultiDB = require("src/config/MultiCopy")
function MultiPlayerCtr:ctor( ... )
	-- body
	self:addEvent()

	-- self.m_nTeamUid = 0
	-- self.m_stAllTeamObj = {}
end

function MultiPlayerCtr:isCanOpenPanel( ... )
	-- body
	return not G_MAINSCENE.map_layer.isfb
end

function MultiPlayerCtr:openMultiPlayerMainPanel( ... )
	-- body
	if not self:isCanOpenPanel() then
		return
	end
	self:getCurLvFromServer()
	local oPanel = MultiPlayerMainPanel.new()

	return oPanel
end

--界面选择的copyid
function MultiPlayerCtr:setCopyId( nCopyId )
	-- body
	self.m_nCopyId = nCopyId
end

function MultiPlayerCtr:getCopyId( ... )
	-- body
	return self.m_nCopyId
end

--进入副本的copyid
function MultiPlayerCtr:setRealCopyId( nCopyId )
	-- body
	self.m_nReayCopyId = nCopyId

    -- 保存到本地，防止断线重连
    setLocalRecordByKey(1, "MultiCarbonId", nCopyId);
end

function MultiPlayerCtr:getRealCopyId( ... )
	-- body
	return self.m_nReayCopyId or -1
end

-- function MultiPlayerCtr:openMultiPlayerAllTeamPanel( nCopyId )
-- 	-- body
-- 	if not self:isCanOpenPanel() then
-- 		return
-- 	end
-- 	-- self:getAllTeamDataFromServer(nCopyId)
-- 	-- GetTeamNetCtr():getTeamList(多人守卫)
-- 	local oPanel = require("src/layers/fb/newMultiPlayer/MultiAllTeamPanel").new(nCopyId)
-- 	return oPanel
-- end

-- function MultiPlayerCtr:GetMyTeamCopyId()
--     if not self.m_oMyTeam then
-- 		return nil;
-- 	end
-- 	return self.m_oMyTeam:getCopyId();
-- end

-- --开启我是队长的多人守卫界面
-- function MultiPlayerCtr:openMultiMyTeamPanel( )
-- 	-- body
-- 	if not self:isCanOpenPanel() then
-- 		return
-- 	end
-- 	if not MultiMyTeamPanel.IsOpened() then
-- 		local oPanel = MultiMyTeamPanel.new()
-- 		return oPanel
-- 	else
-- 		return MultiMyTeamPanel.getInstance()
-- 	end
-- end

-- function MultiPlayerCtr:openMultiTeamPanel( nCopyId )
-- 	-- body
-- 	if not self:isCanOpenPanel() then
-- 		return
-- 	end
-- 	GetMultiPlayerCtr():getTeamDataFromServer(nCopyId)
-- 	if not MultiTeamPanel.IsOpened() then
-- 		local oPanel = MultiTeamPanel.new(nCopyId)
-- 		return oPanel
-- 	else
-- 		return MultiTeamPanel.getInstance()
-- 	end
-- end

-- function MultiPlayerCtr:openInvitePanel( ... )
-- 	-- body
-- 	if not self:isCanOpenPanel() then
-- 		return
-- 	end
-- 	GetFriendCtr():getFriendsFromServer()
-- 	local oPanel = MultiInvitePanel.new(...)
-- 	return oPanel
-- end

-- function MultiPlayerCtr:isTeamPanelOpened( ... )
-- 	-- body
-- 	if not self:isCanOpenPanel() then
-- 		return
-- 	end
-- 	local bRet = false
-- 	if not bRet and MultiMyTeamPanel.IsOpened() then
-- 		bRet = true
-- 	end
-- 	if not bRet and MultiTeamPanel.IsOpened() then
-- 		bRet = true
-- 	end
-- 	return bRet
-- end

-- --根据是否是队长打开不同队伍界面
-- function MultiPlayerCtr:openTeamPanelByMyPosition( ... )
-- 	-- body
-- 	local oMyTeam = self:getMyTeam()
-- 	if not oMyTeam then
-- 		return
-- 	end
-- 	if oMyTeam:isCaptain(userInfo.currRoleId) then
-- 		--如果变成队长，那就换到队长界面
-- 		self:openMultiMyTeamPanel(oMyTeam:getCopyId())
-- 	else
-- 		self:openMultiTeamPanel(oMyTeam:getCopyId())
-- 	end
-- end

-------------------------------------------
-- --获取自己队伍数据
-- function MultiPlayerCtr:getTeamDataFromServer( nCopyId )
-- 	-- body
-- 	local proto = {}
--     proto.copyId = nCopyId
--     g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETTEAMDATA, "CopyGetTeamDataProtocol", proto);
-- end

-- --获取所有队伍数据
-- function MultiPlayerCtr:getAllTeamDataFromServer( nCopyId )
-- 	-- body
-- 	local proto = {}
--     proto.copyId = nCopyId
--     g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_REQ_MULTICOPY_GETALLTEAM, "ReqMultiCopyAllTeamDataProtocol", proto);
-- end



--设置事件监听
function MultiPlayerCtr:addEvent( ... )
	-- body
	-- g_msgHandlerInst:registerMsgHandler(COPY_SC_GETTEAMDATARET, handler(self, self.onTeamDataRet))
	-- g_msgHandlerInst:registerMsgHandler(COPY_SC_GETALLTEAMDATA, handler(self, self.onAllTeamRet))
	g_msgHandlerInst:registerMsgHandler(COPY_SC_MULTICOPY_LV, handler(self, self.onMultiLvRet))


	g_msgHandlerInst:registerMsgHandler(COPY_SC_MULTICOPY_UPLV, handler(self, self.onMultiUpLv))
	-- g_msgHandlerInst:registerMsgHandler(CHAT_SC_CALL_RET, handler(self, self.onChatCallRet))


	
	-- g_msgHandlerInst:registerMsgHandler(COPY_SC_OPER_RES_MULTICOPY, handler(self, self.onOperateRet))

	g_msgHandlerInst:registerMsgHandler(COPY_SC_TEAMCHALLENGE_RES_MULTICOPY, handler(self, self.onTeamChallengeRet))

	Event.Add(EventName.AllReady, self, self.onAllReady)
end

--移除事件监听
function MultiPlayerCtr:removeEvent( ... )
	-- body
	-- g_msgHandlerInst:registerMsgHandler(COPY_SC_GETTEAMDATARET, nil)
	g_msgHandlerInst:registerMsgHandler(COPY_SC_MULTICOPY_LV, nil)
	g_msgHandlerInst:registerMsgHandler(COPY_SC_MULTICOPY_UPLV, nil)
	-- g_msgHandlerInst:registerMsgHandler(COPY_SC_GETALLTEAMDATA, nil)
	-- g_msgHandlerInst:registerMsgHandler(CHAT_SC_CALL_RET, nil)
	-- g_msgHandlerInst:registerMsgHandler(COPY_SC_OPER_RES_MULTICOPY, nil)
	g_msgHandlerInst:registerMsgHandler(COPY_SC_TEAMCHALLENGE_RES_MULTICOPY, nil)

	Event.Remove(EventName.AllReady, self)
end

--取消多人守卫准备状态
function MultiPlayerCtr:resetWait( ... )
	-- body
	GetTeamCtr():clearReadyTag()
	self:stopEntry()
end

function MultiPlayerCtr:onAllReady( ... )
	-- body
	self:resetWait()

	local strTip = string.format("队伍集合完毕，共有^c(orange)%d^名成员，是否开始挑战？", GetTeamCtr():getMyTeam():getMemCnt())

	MessageBoxYesNoEx(nil, strTip, handler(self, self.enterGameFromServer), handler(self, self.cancelEnter), nil, nil, false)
end

function MultiPlayerCtr:cancelEnter( ... )
	-- body
	local proto = {}
    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_CANCEL_ENTERCOPY, "CancelEnterCopyProtocol", proto);
end

function MultiPlayerCtr:checkTeamChallengeFromServer( nCopyId )
	-- body
	print("checkTeamChallengeFromServer", self.m_nCopyId)
	local proto = {}
	proto.copyLevel = nCopyId or self.m_nCopyId
    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_TEAMCHALLENGE_MULTICOPY, "MultiCopyTeamChallengeProtocol", proto);


    print("GetTeamCtr():isCaptain()", GetTeamCtr():isCaptain())



    local nLeftTime = 20		--队长倒计时
    local nDeltaTime = 0.5

    local function checkReady( ... )
    	-- body
    	nLeftTime = nLeftTime - nDeltaTime
    	if nLeftTime <= 0 then
    		self:multiError()
    		return
    	end
    	GetTeamCtr():checkReady()
    end

    if GetTeamCtr():isCaptain() then
    	self:stopEntry()
    	self.m_nEntry = scheduler:scheduleScriptFunc(checkReady, nDeltaTime, false)
    end
end

function MultiPlayerCtr:multiError( ... )
	-- body
	self:resetWait()
	Event.Dispatch(EventName.MultiError)
	self:cancelEnter()
	TIPS({ str =  "等待超时，请重新发起挑战！" })
end

function MultiPlayerCtr:stopEntry( ... )
	-- body
	if self.m_nEntry then
		scheduler:unscheduleScriptEntry(self.m_nEntry)
		self.m_nEntry = nil
	end
end

--[[
// COPY_SC_TEAMCHALLENGE_RES_MULTICOPY 13082
// COPY_SC_TEAMCHALLENGE_RES_MULTICOPY 13082
message MultiCopyTeamChanllengeResProtocol
{
	optional int32 result = 1;	0成功1失败
	repeated int32 memberIds = 2;
	repeated CopyMemberInfo errorMemberInfo = 3;
	repeated int32 errorNum = 4;
}
]]
function MultiPlayerCtr:onTeamChallengeRet( sBuffer )
	-- body
	local proto = g_msgHandlerInst:convertBufferToTable("MultiCopyTeamChanllengeResProtocol", sBuffer)
	
	Event.Dispatch(EventName.TeamChallengeRet, proto)
end

-- --[[
-- // COPY_SC_OPER_RES_MULTICOPY 13080
-- message MultiCopyOperResProtocol
-- {
-- 	optional int32 operation = 1;
-- 	optional bool result = 2;
-- }
-- ]]
-- function MultiPlayerCtr:onOperateRet( sBuffer )
-- 	-- body
-- 	print("onOperateRet!!!")
-- 	local proto = g_msgHandlerInst:convertBufferToTable("MultiCopyOperResProtocol", sBuffer)
-- 	local nOperationId = proto.operation
-- 	local bReult = proto.result

-- 	if bReult then
-- 		if nOperationId == Arg.COPY_MULTI_OPERATOR_CREATETEAM then--创建队伍

-- 		elseif nOperationId == Arg.COPY_MULTI_OPERATOR_LEAVETEAM then--离开队伍
-- 			self:clearMyTeam()
-- 		elseif nOperationId == Arg.COPY_MULTI_OPERATOR_ENTERCOPY then--进入副本

-- 		elseif nOperationId == Arg.COPY_MULTI_OPERATOR_KICKMEMBER then--踢人出队

-- 		elseif nOperationId == Arg.COPY_MULTI_OPERATOR_BEKICKED then--被踢出队

-- 		elseif nOperationId == Arg.COPY_MULTI_OPERATOR_AUTOJOIN then--自动加入

-- 		elseif nOperationId == Arg.COPY_MULTI_OPERATOR_JOINTEAM then--加入队伍
-- 			Event.Dispatch(EventName.CloseChat, true)
-- 		end
-- 	end


-- 	Event.Dispatch(EventName.OperateRet, nOperationId, bReult)
-- end

--chat返回
--[[
//CHAT_SC_CALL_RET 8030
message CallMsgRetProtocol
{
	optional bool callMsgRet = 1;
	optional int32 channel = 2;
}
]]
-- function MultiPlayerCtr:onChatCallRet( sBuffer )
-- 	-- body
-- 	local proto = g_msgHandlerInst:convertBufferToTable("CallMsgRetProtocol", sBuffer)
-- 	local ret = proto.callMsgRet;

-- 	-- Event.Dispatch(EventName.OnChatCallRet, ret)
-- 	print("onChatCallRet",ret)
-- 	if ret then
-- 		local channel = proto.channel
-- 		if channel == commConst.Channel_ID_Area then
-- 			TIPS({ str =  game.getStrByKey("team_hanren2") })
-- 		elseif channel == commConst.Channel_ID_Privacy then
--     		TIPS({ str =  "您已在私聊频道中发出召集邀请，请耐心等待~" })
-- 		end
-- 	end
-- end

-- --创建队伍
-- function MultiPlayerCtr:createTeamFromServer( nCopyId )
-- 	-- body
-- 	local proto = {}
--     proto.copyId = nCopyId
--     -- proto.needBattle = nNeedBattle
--     g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_CREATECOPYTEAM, "CopyCreateTeamProtocol", proto);
-- end

-- --离开队伍
-- function MultiPlayerCtr:leaveTeamFromServer( ... )
-- 	-- body
-- 	if self.m_oMyTeam then
-- 		g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_LEAVECOPYTEAM, "CopyLeaveTeamProtocol", {});
-- 		-- self:clearMyTeam()
-- 	end
-- end

--开始副本
function MultiPlayerCtr:enterGameFromServer( nCopyId )
	-- body
	userInfo.lastFb = nCopyId or self.m_nCopyId
	setLocalRecordByKey(2, "subFbType", "" .. userInfo.lastFb)
	userInfo.lastFbType = commConst.CARBON_MULTI_GUARD
	setLocalRecordByKey(2,"lastFbType","5");

	local proto = {}
    proto.copyId = nCopyId or self.m_nCopyId
	g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTERCOPY, "EnterCopyProtocol", proto)


	self:setRealCopyId(self.m_nCopyId)
end

-- --踢人
-- function MultiPlayerCtr:removeMemFromServer( nTargetId )
-- 	-- body
-- 	local proto = {}
--     proto.targetId = nTargetId
--     g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_REMOVECOPYMEM, "CopyRemoveTeamMemberProtocol", proto)
-- end

--喊话
function MultiPlayerCtr:callMsgFromServer( nSid )
	-- body
	-- local text = "多人副本-%s队伍%s/4人,速来！"
 --    local fbName = MultiDB[GetMultiPlayerCtr():getMyTeam():getCopyId()].Copyname
 --    local oTeam = GetMultiPlayerCtr():getMyTeam()
 --    text = string.format(text, fbName, tostring(oTeam:getMemNum()))
 --    local teamId = oTeam:getTeamId()

	-- local proto = {}
	-- if not nSid then
 --    	proto.channel = commConst.Channel_ID_Area
 --    else
 --    	proto.channel = commConst.Channel_ID_Privacy
 --    end
 --    proto.message = text
 --    proto.area = 1
 --    proto.callType = 1
 --    proto.paramNum = 3
 --    proto.callParams = {
 --        tostring(teamId),
 --        tostring(G_MAINSCENE.map_layer.mapID),
 --        tostring(MRoleStruct:getAttr(PLAYER_LINE))
 --    }
 --    proto.targetRoleId = {nSid or 0}
    
 --    g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_CALL_MSG, "CallMsgProtocol", proto);
 		self:callMsgFromServerEx({nSid})
end

--喊话（多人）
function MultiPlayerCtr:callMsgFromServerEx( vIds )
	-- body
	print("vIds", vIds, type(vIds))
	local text = "多人守卫副本-%s队伍%s/4人,速来！"
    local fbName = MultiDB[GetMultiPlayerCtr():getMyTeam():getCopyId()].Copyname
    local oTeam = GetMultiPlayerCtr():getMyTeam()
    text = string.format(text, fbName, tostring(oTeam:getMemNum()))
    local teamId = oTeam:getTeamId()

	local proto = {}
	if not vIds or #vIds == 0 then
    	proto.channel = commConst.Channel_ID_Team
    else
    	proto.channel = commConst.Channel_ID_Privacy
    end
    proto.message = text
    proto.area = 1
    proto.callType = 1
    proto.paramNum = 3
    proto.callParams = {
        tostring(teamId),
        tostring(G_MAINSCENE.map_layer.mapID),
        tostring(MRoleStruct:getAttr(PLAYER_LINE))
    }
    proto.targetRoleId = vIds or {}
    
    g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_CALL_MSG, "CallMsgProtocol", proto);
end

-- --自动加入队伍
-- function MultiPlayerCtr:autoJoin( nCopyId )
-- 	-- body
-- 	local proto = {}
--     proto.copyId = nCopyId
--     g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_AUTOJOIN, "CopyAutoJoinTeamProtocol", proto)
-- end

-- --准备
-- function MultiPlayerCtr:ready( nCopyId, bReady )
-- 	-- body
-- 	userInfo.lastFb = nCopyId
--     setLocalRecordByKey(2,"subFbType",""..userInfo.lastFb)
--     userInfo.lastFbType = commConst.CARBON_MULTI_GUARD
--     setLocalRecordByKey(2,"lastFbType","5")

-- 	local proto = {};
--     proto.ready = bReady;
--     g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_READY, "CopyTeamReadyProtocol", proto);
-- end

-- --返回自己的队伍信息
-- function MultiPlayerCtr:onTeamDataRet( sBuffer )
-- 	-- body
-- 	local stProto = g_msgHandlerInst:convertBufferToTable("CopyGetTeamDataRetProtocol", sBuffer) 
-- 	if stProto then
-- 		self:resetMyTeam(stProto)
-- 	end

-- 	if not MultiPlayerMainPanel.IsOpened() then
-- 		self:openMultiPlayerMainPanel()
-- 	end

-- 	--如果自己有队伍但是界面没打开就强制打开
-- 	if not self:isTeamPanelOpened() then
-- 		self:openTeamPanelByMyPosition()
-- 	end
-- 	Event.Dispatch(EventName.UpdateMultiPanel)
-- end

-- --刷新特殊team对象，我的team
-- function MultiPlayerCtr:resetMyTeam( stProto )
-- 	-- body
-- 	self:clearMyTeam()

-- 	self.m_oMyTeam = MultiPlayerDetailTeam.new()
-- 	self.m_oMyTeam:reset(stProto)

-- 	if self.m_oMyTeam:getMemNum() <= 0 then
-- 		self.m_oMyTeam:dispose()
-- 		self.m_oMyTeam = nil
-- 	end

-- 	Event.Dispatch(EventName.UpdateMyTeam)
-- end

-- --获取我的队伍对象
-- function MultiPlayerCtr:getMyTeam( ... )
-- 	-- body
-- 	return self.m_oMyTeam
-- end

-- function MultiPlayerCtr:clearMyTeam( ... )
-- 	-- body
-- 	if self.m_oMyTeam then
-- 		self.m_oMyTeam:dispose()
-- 		self.m_oMyTeam = nil
-- 	end
-- end

--返回所有队伍信息
--[[
//COPY_SC_GETALLTEAMDATA 13039
message CopyGetAllTeamDataProtocol
{
	optional int32 copyId = 1;
	optional int32 teamNum = 2;
	repeated CopyTeamInfo info = 3;
}
]]
-- function MultiPlayerCtr:onAllTeamRet( sBuffer )
-- 	-- body
-- 	local stProto = g_msgHandlerInst:convertBufferToTable("CopyGetAllTeamDataProtocol", sBuffer) 

-- 	if stProto then
-- 		self:reset(stProto)
-- 	end

-- 	Event.Dispatch(EventName.UpdateMultiPanel)
-- end

-- --获取所有队伍信息copyid
-- function MultiPlayerCtr:getAllTeamCopyId( ... )
-- 	-- body
-- 	return self.m_nCopyId
-- end

-- --更新信息
-- function MultiPlayerCtr:reset( stInfo )
-- 	-- body
-- 	self.m_stInfo = stInfo

-- 	self.m_nCopyId = stInfo.copyId
-- 	self.m_nTeamNum = stInfo.teamNum

-- 	self:resetAllTeam(stInfo.info)
-- end

-- --刷新所有队伍对象
-- function MultiPlayerCtr:resetAllTeam( info )
-- 	-- body
-- 	self:clearAllTeam()
-- 	for _,stInfo in ipairs(info) do
-- 		local oTeam = self:createTeam(stInfo)
-- 		if oTeam then
-- 			self:addTeamObj(oTeam)
-- 		end
-- 	end
-- end

-- function MultiPlayerCtr:createTeam( stInfo )
-- 	-- body
-- 	self.m_nTeamUid = self.m_nTeamUid + 1
-- 	local oTeam = MultiPlayerTeam.new(self.m_nTeamUid)
-- 	oTeam:reset(stInfo)
-- 	return oTeam
-- end

-- function MultiPlayerCtr:addTeamObj( oTeam )
-- 	-- body
-- 	local nUid = oTeam:getUid()
-- 	self:removeTeamObj(nUid)
-- 	self.m_stAllTeamObj[nUid] = oTeam
-- end

-- function MultiPlayerCtr:removeTeamObj( nUid )
-- 	-- body
-- 	local oTeam = self.m_stAllTeamObj[nUid]
-- 	if oTeam then
-- 		oTeam:dispose()
-- 		self.m_stAllTeamObj[nUid] = nil
-- 	end
-- end

-- function MultiPlayerCtr:clearAllTeam( ... )
-- 	-- body
-- 	for nUid,oTeam in pairs(self.m_stAllTeamObj) do
-- 		self:removeTeamObj(nUid)
-- 	end
-- end

-- function MultiPlayerCtr:getAllTeam( bSort )
-- 	-- body
-- 	local vRet = {}
-- 	for nUid,oTeam in pairs(self.m_stAllTeamObj) do
-- 		table.insert(vRet, oTeam)
-- 	end
-- 	if bSort then
-- 		table.sort(vRet, function( a, b )
-- 			-- body
-- 			local nAMem = a:getMemberCnt()
-- 			local nBMem = b:getMemberCnt()
-- 			if nAMem == nBMem then
-- 				return a:getUid() < b:getUid()
-- 			else
-- 				return nAMem > nBMem
-- 			end
-- 		end)
-- 	end
-- 	return vRet
-- end

--获取多人守卫可打的等级
function MultiPlayerCtr:getCurLvFromServer( ... )
	-- body
	local proto = {}
    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_REQ_MULTICOPY_LV, "ReqMultiCopyLevelProtocol", proto)
end

--[[
// COPY_SC_MULTICOPY_LV 13076
message MultiCopyLvProtocol
{
	optional int32 currentLv = 1;
	repeated int32 todayPassLvs = 2;
}
]]
function MultiPlayerCtr:onMultiLvRet( sBuffer )
	-- body
	local stProto = g_msgHandlerInst:convertBufferToTable("MultiCopyLvProtocol", sBuffer) 
	if stProto then
		self:setCurLv(stProto.currentLv)
		self:setTodayPassed(stProto.todayPassLvs)
	end
	Event.Dispatch(EventName.UpdateMultiPanel)
end

function MultiPlayerCtr:setCurLv( nLv )
	-- body
	self.m_nCurLv = nLv
end

--今日通关的id
function MultiPlayerCtr:setTodayPassed( todayPassLvs )
	-- body
	self.m_stTodayPassed = todayPassLvs
end

function MultiPlayerCtr:getTodayPassed( ... )
	-- body
	return self.m_stTodayPassed or {}
end

--判断副本今日是否已经通关
function MultiPlayerCtr:isTodayPassed( nId )
	-- body
	if not self.m_stTodayPassed then
		return false
	end
	for k,v in pairs(self.m_stTodayPassed) do
		if v == nId then
			return true
		end
	end
	return false
end

function MultiPlayerCtr:getCurLv( ... )
	-- body
	return self.m_nCurLv or 0
end

--[[
// COPY_SC_MULTICOPY_LV 13076
message MultiCopyLvProtocol
{
	optional int32 currentLv = 1;
}
]]
function MultiPlayerCtr:onMultiUpLv( sBuffer )
	-- body
	local stProto = g_msgHandlerInst:convertBufferToTable("MultiCopyLvProtocol", sBuffer) 
	if stProto then
		self:setCurLv(stProto.currentLv)
	end

	Event.Dispatch(EventName.UpdateMultiPanel)
end

-- --加入队伍
-- function MultiPlayerCtr:joinTeam( nTeamId )
-- 	-- body
-- 	local proto = {}
--     proto.teamId = nTeamId
--     g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_JOINCOPYTEAM, "CopyJoinTeamProtocol", proto)
-- end

--析构函数
function MultiPlayerCtr:dispose( ... )
	-- body
	self:removeEvent()
	self:stopEntry()
end

return MultiPlayerCtr