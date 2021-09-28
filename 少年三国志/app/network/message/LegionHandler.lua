--LegionHandler.lua

local HandlerBase = require("app.network.message.HandlerBase")

local LegionHandler = class("LegionHandler", HandlerBase)


function LegionHandler:_onCtor( ... )
	-- body
end

function LegionHandler:initHandler( ... )
	-- 军团列表及管理界面
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpList, self._onGetCorpList, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetJoinCorpList, self._onGetJoinCorpList, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpDetail, self._onGetCorpDetail, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpMember, self._onGetCorpMember, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpHistory, self._onGetCorpHistory, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CreateCorp, self._onCreateCorp, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RequestJoinCorp, self._onRequestJoinCorp, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_DeleteJoinCorp, self._onDeleteJoinCorp, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_QuitCorp, self._onQuitCorp, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SearchCorp, self._onSearchCorp, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ConfirmJoinCorp, self._onConfirmJoinCorp, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ModifyCorp, self._onModifyCorp, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_DismissCorpMember, self._onDismissCorpMember, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpJoin, self._onGetCorpJoinMember, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_DismissCorp, self._onDismissCorp, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CorpStaff, self._onCorpStaff, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpWorship, self._onGetCorpWorship, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CorpContribute, self._onCorpContribute, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ExchangeLeader, self._onExchangeLeader, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpContributeAward, self._onGetCorpContributeAward, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_NotifyCorpDismiss, self._onNotifyCorpDismiss, self)
            uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpTechInfo, self._onGetCorpTechInfo, self)
            uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_DevelopCorpTech, self._onDevelopCorpTech, self)
            uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_LearnCorpTech, self._onLearnCorpTech, self)
            uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CorpUpLevel, self._onCorpUpLevel, self)
            uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_DevelopCorpTechBroadcast, self._onDevelopCorpTechBroadcast, self)
            uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CorpUpLevelBroadcast, self._onCorpUpLevelBroadcast, self)
            uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_MyCorpChangedByCorpLeader, self._onMyCorpChangedByCorpLeader, self)

	--军团副本界面
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpChapter, self._onGetCorpChapter, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpDungeonInfo, self._onGetCorpDungeonInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ExecuteCorpDungeon, self._onExecuteCorpDungeon, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SetCorpChapterId, self._onSetCorpChapterId, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDungeonAwardList, self._onGetDungeonAwardList, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDungeonAward, self._onGetDungeonAward, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDungeonCorpRank, self._onGetDungeonCorpRank, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDungeonCorpMemberRank, self._onGetDungeonCorpMemberRank, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ResetDungeonCount, self._onResetDungeonCount, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDungeonAwardCorpPoint, self._onGetDungeonAwardCorpPoint, self)

    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushCorpDungeon, self._onFlushCorpDungeon, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushDungeonAward, self._onFlushDungeonAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpChapterRank, self._onGetCorpChapterRank, self)

        --新的军团副本
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetNewCorpChapter, self._onGetNewCorpChapter, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetNewCorpDungeonInfo, self._onGetNewCorpDungeonInfo, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ExecuteNewCorpDungeon, self._onExecuteNewCorpDungeon, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetNewDungeonAwardList, self._onGetNewDungeonAwardList, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetNewDungeonAward, self._onGetNewDungeonAward, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetNewDungeonCorpMemberRank, self._onGetNewDungeonCorpMemberRank, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ResetNewDungeonCount, self._onResetNewDungeonCount, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDungeonAwardCorpPoint, self._onGetDungeonAwardCorpPoint, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetNewChapterAward, self._onGetNewChapterAward, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetNewDungeonAwardHint, self._onGetNewDungeonAwardHint, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetNewCorpChapterRank, self._onGetNewCorpChapterRank, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SetNewCorpRollbackChapter, self._onSetNewCorpRollbackChapter, self)

        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushNewCorpDungeon, self._onFlushNewCorpDungeon, self)
        uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushNewDungeonAward, self._onFlushNewDungeonAward, self)
        
    -- 群英战
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpCrossBattleInfo, self._onGetCorpCrossBattleInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ApplyCorpCrossBattle, self._onApplyCorpCrossBattle, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_QuitCorpCrossBattle, self._onQuitCorpCrossBattle, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpCrossBattleList, self._onGetCorpCrossBattleList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossBattleEncourage, self._onGetCrossBattleEncourage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossBattleEncourage, self._onCrossBattleEncourage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossBattleField, self._onGetCrossBattleField, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCrossBattleEnemyCorp, self._onGetCrossBattleEnemyCorp, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ResetCrossBattleChallengeCD, self._onResetCrossBattleChallengeCD, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SetCrossBattleFireOn, self._onSetCrossBattleFireOn, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossBattleMemberRank, self._onCrossBattleMemberRank, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CrossBattleChallengeEnemy, self._onCrossBattleChallengeEnemy, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_BroadCastState, self._onBroadCastStateChange, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpCrossBattleTime, self._onGetCorpCrossBattleTime, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushCorpCrossBattleList, self._onFlushCorpCrossBattleList, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushCorpCrossBattleField, self._onFlushCorpCrossBattleField, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushCorpEncourage, self._onFlushCorpEncourage, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushCorpBattleResult, self._onFlushCorpBattleResult, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushFireOn, self._onFlushFireOn, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FlushBattleMemberInfo, self._onFlushBattleMemberInfo, self)
end

function LegionHandler:unInitHandler( ... )
	-- body
end

-- 获取一定范围的军团列表
function LegionHandler:sendGetCorpList( start_, end_ )
	local buffer = 
    {
    	start = start_,
    	tail = end_
    }

    local msgBuffer = protobuf.encode("cs.C2S_GetCorpList", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpList, msgBuffer)
end

function LegionHandler:_onGetCorpList( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpList", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:updateCorpList(decodeBuffer.start, decodeBuffer.tail, decodeBuffer.corps)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_LIST, nil, false, decodeBuffer.ret, decodeBuffer.start, decodeBuffer.tail)
    end
end

-- 获取申请过的军团列表
function LegionHandler:sendGetJoinCorpList(  )
	local buffer = 
    {

    }
    local msgBuffer = protobuf.encode("cs.C2S_GetJoinCorpList", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetJoinCorpList, msgBuffer)
end

function LegionHandler:_onGetJoinCorpList( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetJoinCorpList", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:updateJoinCorpList(decodeBuffer.corps)
        if type(decodeBuffer.corps) == "table" and #decodeBuffer.corps > 0 then
    	   uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_JOIN_CORP_LIST, nil, false, decodeBuffer.ret)
        end
    end
end

-- 获取当前军团的军团详情
function LegionHandler:sendGetCorpDetail(  )
	local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpDetail", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpDetail, msgBuffer)
end

function LegionHandler:_onGetCorpDetail( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpDetail", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        local initFlag = G_Me.legionData:isCorpInit()
        local hasCorpOld = G_Me.legionData:hasCorp()

    	G_Me.legionData:updateCorpDetailInfo(decodeBuffer.has_corp, decodeBuffer.corp, 
            decodeBuffer.quit_corp_cd, decodeBuffer.join_corp_time)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_DETAIL, nil, false, decodeBuffer.ret)

        local hasCorpNew = G_Me.legionData:hasCorp()
        if initFlag and not hasCorpOld and hasCorpNew then 
            G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_ENTER_LEGION_SUCCESS"))
        end
        if not initFlag and G_Me.legionData:isCorpInit() and G_Me.legionData:hasCorp() then 
            G_HandlersManager.legionHandler:sendGetCorpJoinMember()
        end
        if G_Me.legionData:hasCorp() then
            self:sendGetCorpTechInfo()
        end
    end
end

-- 获取当前军团的军团成员
function LegionHandler:sendGetCorpMember(  )
	local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpMember", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpMember, msgBuffer)
end

function LegionHandler:_onGetCorpMember( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpMember", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:updateCorpMembers(decodeBuffer.members)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_MEMBERLIST, nil, false, decodeBuffer.ret)
    end
end

-- 获取当前军团的军团动态
function LegionHandler:sendGetCorpHistory( start_, end_ )
	local buffer = 
    {
    start = start_,
    tail = end_
    }
    __Log("sendGetCorpHistory:start_:%d, end:%d", start_, end_)
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpHistory", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpHistory, msgBuffer)
end

function LegionHandler:_onGetCorpHistory( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpHistory", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:updateCorpHistory(decodeBuffer.start, decodeBuffer.tail, decodeBuffer.history)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_HISTORY, nil, false, decodeBuffer.ret)
    end
end

-- 创建军团
function LegionHandler:sendCreateCorp( name_, pic_, frame_ )
	local buffer = 
    {
    	name = name_,
    	icon_pic = pic_,
    	icon_frame = frame_,
    }
    local msgBuffer = protobuf.encode("cs.C2S_CreateCorp", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_CreateCorp, msgBuffer)
end

function LegionHandler:_onCreateCorp( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_CreateCorp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	self:sendGetCorpDetail()
        self:sendGetCorpChapter()
    	self:sendGetCorpMember()

        --G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CREATE_CORP_SUCCESS"))
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CREATE_CORP, nil, false, decodeBuffer.ret)
    end
end

-- 申请加入军团
function LegionHandler:sendRequestJoinCorp( corpId )
	local buffer = 
    {
    	id = corpId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_RequestJoinCorp", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_RequestJoinCorp, msgBuffer)
end

function LegionHandler:_onRequestJoinCorp( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_RequestJoinCorp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:updateForApplyCorp(decodeBuffer.id, decodeBuffer.corp)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REQUEST_JOIN_CORP, nil, false, decodeBuffer.ret)
    end
end

-- 删除加入军团的申请
function LegionHandler:sendDeleteJoinCorp( corpId )
    if not self:checkCorpDispose() then 
        return 
    end

	local buffer = 
    {
    	id = corpId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_DeleteJoinCorp", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_DeleteJoinCorp, msgBuffer)
end

function LegionHandler:_onDeleteJoinCorp( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_DeleteJoinCorp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:updateForCancelApplyCorp(decodeBuffer.id, decodeBuffer.corp)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DELETE_JOIN_CORP, nil, false, decodeBuffer.ret)
    end
end

-- 退出军团
function LegionHandler:sendQuitCorp(  )
    if not self:checkCorpDispose() then 
        return 
    end
	local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_QuitCorp", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_QuitCorp, msgBuffer)
end

function LegionHandler:_onQuitCorp( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_QuitCorp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:onDestoryCorp()
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_QUIT_CORP, nil, false, decodeBuffer.ret)
    end
end

-- 查找军团
function LegionHandler:sendSearchCorp( name_ )
	local buffer = 
    {
    	name = name_,
    }
    local msgBuffer = protobuf.encode("cs.C2S_SearchCorp", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_SearchCorp, msgBuffer)
end

function LegionHandler:_onSearchCorp( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_SearchCorp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:updateSearchCorpInfo(decodeBuffer.corp)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SEARCH_CORP, nil, false, decodeBuffer.ret)
    end
end

-- 批准加入军团的申请
function LegionHandler:sendConfirmJoinCorp( userId, flag )
    if not self:checkCorpDispose() then 
        return 
    end
	local buffer = 
    {
    	user_id = userId,
    	confirm = flag and true or false,
    }

    local msgBuffer = protobuf.encode("cs.C2S_ConfirmJoinCorp", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_ConfirmJoinCorp, msgBuffer)
end

function LegionHandler:_onConfirmJoinCorp( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_ConfirmJoinCorp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        local applyFlagOld = G_Me.legionData:hasCorpApply()
    	G_Me.legionData:refreshJoinCorpMember(decodeBuffer.user_id, decodeBuffer.confirm)
    	
        local applyFlagNew = G_Me.legionData:hasCorpApply()
        if applyFlagOld ~= applyFlagNew then 
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_FLAG_HAVE_APPLY, nil, false, applyFlagNew)
        end
    end

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CONFIRM_JOIN_CORP, nil, false, decodeBuffer.ret, decodeBuffer.confirm)
end

-- 修改军团宣言,公告,icon, 边框
function LegionHandler:sendModifyCorp( announce, pic, frame, notify )
    if not self:checkCorpDispose() then 
        return 
    end
	local buffer = 
    {
    	announcement = announce,
    	icon_pic = pic,
    	icon_frame = frame,
    	notification = notify,
    }
    local msgBuffer = protobuf.encode("cs.C2S_ModifyCorp", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_ModifyCorp, msgBuffer)
end

function LegionHandler:_onModifyCorp( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_ModifyCorp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_MODIFY_CORP, nil, false, decodeBuffer.ret)
    end
end

-- 踢出军团中的某个成员
function LegionHandler:sendDissmissCorpMember( userId )
    if not self:checkCorpDispose() then 
        return 
    end
	local buffer = 
    {
    	id = userId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_DismissCorpMember", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_DismissCorpMember, msgBuffer)
end

function LegionHandler:_onDismissCorpMember( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_DismissCorpMember", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:onDismissCorpMember(decodeBuffer.id)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DISMISS_CORP_MEMBER, nil, false, decodeBuffer.ret)
    end
end

-- 获取军团的加入申请列表
function LegionHandler:sendGetCorpJoinMember(  )
	local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpJoin", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpJoin, msgBuffer)
end

function LegionHandler:_onGetCorpJoinMember( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpJoin", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        local applyFlagOld = G_Me.legionData:hasCorpApply()
    	G_Me.legionData:updateForApplyList(decodeBuffer.joins)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_JOIN_MEMBER, nil, false, decodeBuffer.ret)
        local applyFlagNew = G_Me.legionData:hasCorpApply()
        if applyFlagOld ~= applyFlagNew then 
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_FLAG_HAVE_APPLY, nil, false, applyFlagNew)
        end
    end
end

-- 解散军团
function LegionHandler:sendDismissCorp(  )
    if not self:checkCorpDispose() then 
        return 
    end
	local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_DismissCorp", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_DismissCorp, msgBuffer)
end

function LegionHandler:_onDismissCorp( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_DismissCorp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:onDestoryCorp()
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DISMISS_CORP, nil, false, decodeBuffer.ret)
    end
end

-- 给军团成员任职
function LegionHandler:sendCorpStaff( userId, positionId )
    if not self:checkCorpDispose() then 
        return 
    end
	local buffer = 
    {
    	id = userId,
    	position = positionId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_CorpStaff", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_CorpStaff, msgBuffer)
end

function LegionHandler:_onCorpStaff( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_CorpStaff", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:onCorpStaffChange(decodeBuffer.id, decodeBuffer.position)
    	if decodeBuffer.position == 1 then 
    		G_Me.legionData:onCorpStaffChange(G_Me.userData.id, 0)
    		--self:sendGetCorpDetail()
    	end
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_STAFF, nil, false, decodeBuffer.ret, 
            decodeBuffer.id,  decodeBuffer.position)
    end
end

-- 弹劾军团长
function LegionHandler:sendExchangeLeader(  )
    if not self:checkCorpDispose() then 
        return 
    end
	local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_ExchangeLeader", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_ExchangeLeader, msgBuffer)
end

function LegionHandler:_onExchangeLeader( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_ExchangeLeader", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:onCorpStaffChange(decodeBuffer.user_id, 0)
   		G_Me.legionData:onCorpStaffChange(G_Me.userData.id, 1)
   		--self:sendGetCorpDetail()
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EXCHANGE_LEADER, nil, false, decodeBuffer.ret)
    end
end


-- 获取当前军团的祭天进度以及军团贡献等信息
function LegionHandler:sendGetCorpWorship(  )
	local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpWorship", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpWorship, msgBuffer)
end

function LegionHandler:_onGetCorpWorship( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpWorship", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        local flagWorshipOld = G_Me.legionData:canWorship()
        local flagWorshipAwardOld = G_Me.legionData:haveWorshipAward()
    	G_Me.legionData:updateCorpWorship(decodeBuffer)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_WORSHIP, nil, false, decodeBuffer.ret)

        local flagWorshipNew = G_Me.legionData:canWorship()
        local flagWorshipAwardNew = G_Me.legionData:haveWorshipAward()
        if flagWorshipNew ~= flagWorshipOld then 
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_FLAG_CAN_WORSHIP, nil, false, flagWorshipNew)
        end

        if flagWorshipAwardNew ~= flagWorshipAwardOld then 
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_FLAG_HAVE_WORSHIP_AWARD, nil, false, flagWorshipAwardNew)
        end
    end
end

-- 祭天
function LegionHandler:sendGetCorpContribute( contriId )
    if not self:checkCorpDispose() then 
        return 
    end
	local buffer = 
    {
    	id = contriId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_CorpContribute", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_CorpContribute, msgBuffer)
end

function LegionHandler:_onCorpContribute( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_CorpContribute", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:udpateMyContribute(decodeBuffer.id, decodeBuffer.worship_exp, decodeBuffer.corp_point)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_CONTRIBUTE, nil, false, decodeBuffer.ret, 
            decodeBuffer.id, decodeBuffer.worship_crit, decodeBuffer.worship_exp, decodeBuffer.corp_point)
    end
end

-- 获取当前军团的祭天奖励
function LegionHandler:sendGetCorpContributeAward( index_ )
	local buffer = 
    {
    	index = index_,
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpContributeAward", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpContributeAward, msgBuffer)
end

function LegionHandler:_onGetCorpContributeAward( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpContributeAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_CONTRIBUTE_AWARD, nil, false, 
    		decodeBuffer.ret, decodeBuffer.index, decodeBuffer.awards)
    end
end

function LegionHandler:_onNotifyCorpDismiss( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_NotifyCorpDismiss", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.dismiss then
        G_Me.legionData:onDestoryCorp()
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, nil, false, decodeBuffer.dismiss)
    end
end

--军团科技
function LegionHandler:sendGetCorpTechInfo(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpTechInfo", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpTechInfo, msgBuffer)
end

function LegionHandler:_onGetCorpTechInfo( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpTechInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateTechInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_TECH_INFO, nil, false, decodeBuffer)
    end
end

function LegionHandler:_onDevelopCorpTechBroadcast( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_DevelopCorpTechBroadcast", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    G_Me.legionData:updateTechBroadcast(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_TECH_BROADCAST, nil, false, decodeBuffer)
end

function LegionHandler:_onCorpUpLevelBroadcast( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_CorpUpLevelBroadcast", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    G_Me.legionData:onUpLevel(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_LEVEL_BROADCAST, nil, false, decodeBuffer)
end

function LegionHandler:sendDevelopCorpTech( id )
    local buffer = 
    {
        tech_id = id,
    }
    local msgBuffer = protobuf.encode("cs.C2S_DevelopCorpTech", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_DevelopCorpTech, msgBuffer)
end

function LegionHandler:_onDevelopCorpTech( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_DevelopCorpTech", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:onDevelopTech(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_DEVELOP_CORP_TECH, nil, false, decodeBuffer)
    end
end

function LegionHandler:sendLearnCorpTech( id )
    local buffer = 
    {
        tech_id = id,
    }
    local msgBuffer = protobuf.encode("cs.C2S_LearnCorpTech", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_LearnCorpTech, msgBuffer)
end

function LegionHandler:_onLearnCorpTech( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_LearnCorpTech", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:onLearnTech(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_LEARN_CORP_TECH, nil, false, decodeBuffer)
    end
end

function LegionHandler:sendCorpUpLevel(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_CorpUpLevel", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_CorpUpLevel, msgBuffer)
end

function LegionHandler:_onCorpUpLevel( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_CorpUpLevel", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:onUpLevel(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_UPLEVEL, nil, false, decodeBuffer)
    end
end

function LegionHandler:_onMyCorpChangedByCorpLeader( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_MyCorpChangedByCorpLeader", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    self:sendGetCorpDetail()
end

-- 获取军团副本的章节信息sendGetJoinCorpList
function LegionHandler:sendGetCorpChapter(  )
	local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpChapter", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpChapter, msgBuffer)
end

function LegionHandler:_onGetCorpChapter( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpChapter", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        local applyFlagOld = G_Me.legionData:canHitEgg()
    	G_Me.legionData:updateChapterInfo(decodeBuffer)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_CHATER_INFO, nil, false, decodeBuffer.ret)

        local applyFlagNew = G_Me.legionData:canHitEgg()
        if applyFlagNew ~= applyFlagOld then 
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_FLAG_CAN_HIT_EGGS, nil, false, applyFlagNew)
        end
    end
end

-- 获取军团副本的章节怪物信息
function LegionHandler:sendGetCorpDungeonInfo( chapterId )
	local buffer = 
    {
    	chapter_id = chapterId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpDungeonInfo", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpDungeonInfo, msgBuffer)
end

function LegionHandler:_onGetCorpDungeonInfo( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpDungeonInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:updateCorpDungeonInfo(decodeBuffer)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_DUNGEON_INFO, nil, false, decodeBuffer.ret)
    end
end

-- 挑战军团副本
function LegionHandler:sendExecuteCorpDungeon( id_, infoId )
    if not self:checkCorpDispose() then 
        return 
    end
	local buffer = 
    {
    	id = id_,
    	info_id = infoId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_ExecuteCorpDungeon", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_ExecuteCorpDungeon, msgBuffer)
end

function LegionHandler:_onExecuteCorpDungeon( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_ExecuteCorpDungeon", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        self:sendGetCorpDetail()
    	G_Me.legionData:onCorpDungeonExecute(decodeBuffer.dungeon)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EXECUTE_CORP_DUNGEON, nil, false, decodeBuffer)
    end
end

-- 设置第二日要打的副本
function LegionHandler:sendSetCorpChapterId( chapterId )
	local buffer = 
    {
    	id = chapterId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_SetCorpChapterId", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_SetCorpChapterId, msgBuffer)
end

function LegionHandler:_onSetCorpChapterId( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_SetCorpChapterId", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    --if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SET_CORP_CHAPTER_ID, nil, false, decodeBuffer.ret)
    --end
end

-- 获取章节副本奖励列表
function LegionHandler:sendGetDungeonAwardList(  )
	local buffer = 
    {
   
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetDungeonAwardList", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetDungeonAwardList, msgBuffer)
end

function LegionHandler:_onGetDungeonAwardList( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetDungeonAwardList", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        local applyFlagOld = G_Me.legionData:canHitEgg()

    	G_Me.legionData:updateAwardListInfo(decodeBuffer)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_DUNGEON_AWARD_LIST, nil, false, decodeBuffer.ret)
       
        local applyFlagNew = G_Me.legionData:canHitEgg()
        if applyFlagNew ~= applyFlagOld then 
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_FLAG_CAN_HIT_EGGS, nil, false, applyFlagNew)
        end
    end
end

-- 砸蛋并获取奖励
function LegionHandler:sendGetDungeonAward( index_ )
	local buffer = 
    {
     index = index_,
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetDungeonAward", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetDungeonAward, msgBuffer)
end

function LegionHandler:_onGetDungeonAward( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetDungeonAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        local applyFlagOld = G_Me.legionData:canHitEgg()

    	G_Me.legionData:onAddDungeonAward(decodeBuffer.da, true)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_DUNGEON_AWARD, nil, false, decodeBuffer.ret, decodeBuffer.awards)
       
        local applyFlagNew = G_Me.legionData:canHitEgg()
        if applyFlagNew ~= applyFlagOld then 
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_FLAG_CAN_HIT_EGGS, nil, false, applyFlagNew)
        end
    end
end

-- 获取通关章节全军团奖励
function LegionHandler:sendGetDungeonAwardCorpPoint( ... )
    local buffer = {

    }
    local msgBuffer = protobuf.encode("cs.C2S_GetDungeonAwardCorpPoint", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetDungeonAwardCorpPoint, msgBuffer)
end


function LegionHandler:_onGetDungeonAwardCorpPoint( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetDungeonAwardCorpPoint", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:onUpdateDungeonAwardCorpPoint(decodeBuffer.has_point)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_DUNGEON_AWARD_CORP_POINT, nil, false,
         decodeBuffer.ret, decodeBuffer.corp_point, decodeBuffer.has_point)
    end
end

-- 获取全服排名 
function LegionHandler:sendGetDungeonCorpRank(  )
	local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetDungeonCorpRank", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetDungeonCorpRank, msgBuffer)
end

function LegionHandler:_onGetDungeonCorpRank( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetDungeonCorpRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:updateGloabelRank(decodeBuffer)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_DUNGEON_CORP_RANK, nil, false, decodeBuffer.ret)
    end
end

-- 获取军团成员排名 
function LegionHandler:sendGetDungeonCorpMemberRank(  )
	local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetDungeonCorpMemberRank", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetDungeonCorpMemberRank, msgBuffer)
end

function LegionHandler:_onGetDungeonCorpMemberRank( msgId, msg, len )
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetDungeonCorpMemberRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
    	G_Me.legionData:updateLegionRank(decodeBuffer)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_DUNGEON_CORP_MEMBER_RANK, nil, false, decodeBuffer.ret)
    end
end

function LegionHandler:_onFlushCorpDungeon( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushCorpDungeon", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    G_Me.legionData:onCorpDungeonExecute(decodeBuffer.dungeon)
    G_Me.legionData:onChapterHpUpdate(decodeBuffer.hp)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_FLUSH_CORP_DUNGEON, nil, false, decodeBuffer)
end

function LegionHandler:_onFlushDungeonAward( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushDungeonAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    G_Me.legionData:onAddDungeonAward(decodeBuffer.da)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_FLUSH_DUNGEON_AWARD, nil, false)
end

-- 购买军团副本次数
function LegionHandler:sendResetDungeonCount(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_ResetDungeonCount", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_ResetDungeonCount, msgBuffer)
end

function LegionHandler:_onResetDungeonCount( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_ResetDungeonCount", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RESET_DUNGEON_COUNT, nil, false, decodeBuffer.ret)
    end
end

function LegionHandler:disposeCorpDismiss( dismiss )
    if type(dismiss) ~= "number" then 
        return 
    end

    G_MovingTip:showMovingTip(G_lang:get(dismiss == 1 and "LANG_LEGION_NOTIFY_DISMISS_CORP" or "LANG_LEGION_NOTIFY_DISMISS_MEMBER"))
    uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
end


-- 拉取军团副本排行数据
function LegionHandler:sendGetCorpChapterRank(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpChapterRank", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpChapterRank, msgBuffer)
end

function LegionHandler:_onGetCorpChapterRank( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpChapterRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateCorpChapterRank(decodeBuffer.ranks)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_GET_CORP_CHAPER_RANK, nil, false, decodeBuffer.ret)
    end
end

-- 跨服站协议
-- 检查当前是否能进行军团的其它操作
function LegionHandler:checkCorpDispose( ... )
    if G_Me.legionData:hasApply() and (G_Me.legionData:isOnMatch() or  G_Me.legionData:isOnBattle()) then 
        G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_IS_CROSS_BATTLING"))
        return false
    end

    return true
end

-- 获取跨服站状态数据
function LegionHandler:sendGetCorpCrossBattleInfo(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpCrossBattleInfo", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpCrossBattleInfo, msgBuffer)
end

function LegionHandler:_onGetCorpCrossBattleInfo( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpCrossBattleInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateCrossBattleStatus( decodeBuffer.apply, decodeBuffer.state, decodeBuffer.field)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_APPLY_INFO, nil, false, decodeBuffer.ret)
    end
end

-- 申请加入跨服战
function LegionHandler:sendApplyCorpCrossBattle(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_ApplyCorpCrossBattle", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_ApplyCorpCrossBattle, msgBuffer)
end

function LegionHandler:_onApplyCorpCrossBattle( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_ApplyCorpCrossBattle", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateCrossBattleStatus(true)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_APPLY_BATTLE_STATUS_CHANGE, nil, false, decodeBuffer.ret, true)
    end
end

-- 取消申请跨服战
function LegionHandler:sendQuitCorpCrossBattle(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_QuitCorpCrossBattle", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_QuitCorpCrossBattle, msgBuffer)
end

function LegionHandler:_onQuitCorpCrossBattle( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_QuitCorpCrossBattle", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateCrossBattleStatus(false)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_APPLY_BATTLE_STATUS_CHANGE, nil, false, decodeBuffer.ret, false)
    end
end

-- 广播：群英战当前状态改变
function LegionHandler:_onBroadCastStateChange( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_BroadCastState", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    local oldStatus = G_Me.legionData:getCrossStatus() or 0
    G_Me.legionData:changeCrossStatus(decodeBuffer.state)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_BROADCAST_BATTLE_STATUS, nil, false, decodeBuffer.state)

    local newStatus = G_Me.legionData:getCrossStatus() or 0
    if oldStatus ~= newStatus and G_Me.legionData:hasCorpCrossValid() then 
        self:sendGetCorpCrossBattleTime()
    end
end

-- 广播：群英战分区变化
function LegionHandler:_onFlushCorpCrossBattleField( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushCorpCrossBattleField", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    G_Me.legionData:changeBattleField(decodeBuffer.field)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_BROADCAST_BATTLE_FIELD, nil, false, decodeBuffer.field)
end


-- 摘取当前群英战时间段（报名，匹配，开战，结束）
function LegionHandler:sendGetCorpCrossBattleTime(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpCrossBattleTime", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpCrossBattleTime, msgBuffer)
end

function LegionHandler:_onGetCorpCrossBattleTime( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpCrossBattleTime", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateCropCrossBattleTime(decodeBuffer.times)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_TIMES, nil, false, decodeBuffer.ret)
    end
end

-- 获取
function LegionHandler:sendGetCorpCrossBattleList(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpCrossBattleList", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpCrossBattleList, msgBuffer)
end

function LegionHandler:_onGetCorpCrossBattleList( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpCrossBattleList", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateApplyCrossBattleList(decodeBuffer.corps)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_LIST, nil, false, decodeBuffer.ret)
    end
end

-- 主动推送军团的申请/取消申请消息
function LegionHandler:_onFlushCorpCrossBattleList( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushCorpCrossBattleList", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    G_Me.legionData:flushApplyCrossBattleInfo(decodeBuffer.add, decodeBuffer.corp)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_FLUSH_BATTLE_CORP, nil, false)
end

-- 获取鼓舞次数数据
function LegionHandler:sendGetCrossBattleEncourage(  )
    local buffer = 
    {
    
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCrossBattleEncourage", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCrossBattleEncourage, msgBuffer)
end

function LegionHandler:_onGetCrossBattleEncourage( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossBattleEncourage", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:refreshCorpCrossEncourage(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_ENCOURAGE_INFO, nil, false, decodeBuffer.ret)
    end
end

function LegionHandler:_onFlushCorpEncourage( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushCorpEncourage", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    --if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:flushCorpEncourage(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_FLUSH_ENCOURAGE_INFO, nil, false)
   -- end
end

-- 鼓舞
function LegionHandler:sendCrossBattleEncourage( isGongji )
    local buffer = 
    {
    e_type = isGongji and 2 or 1,
    }
    local msgBuffer = protobuf.encode("cs.C2S_CrossBattleEncourage", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_CrossBattleEncourage, msgBuffer)
end

function LegionHandler:_onCrossBattleEncourage( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_CrossBattleEncourage", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:onEncrourageResult(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_ENCOURAGE_BATTLE, nil, false, 
            decodeBuffer.ret, decodeBuffer.e_type, decodeBuffer.success)
    end
end

-- 获取赛区军团详情
function LegionHandler:sendGetCrossBattleField(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCrossBattleField", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCrossBattleField, msgBuffer)
end

function LegionHandler:_onGetCrossBattleField( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossBattleField", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateCrossBattleFieldDetail(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_FIELD, nil, false, decodeBuffer.ret)
    end
end

-- 刷新军团对手
function LegionHandler:sendGetCrossBattleEnemyCorp( sid_, corpId_, refresh_ )
    local buffer = 
    {
        sid = sid_,
        corp_id = corpId_,
        is_refresh = refresh_,
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCrossBattleEnemyCorp", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCrossBattleEnemyCorp, msgBuffer)
end

function LegionHandler:_onGetCrossBattleEnemyCorp( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCrossBattleEnemyCorp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateCrossBattleEnemys(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_ENEMYS, nil, false, 
            decodeBuffer.ret, decodeBuffer.is_refresh, decodeBuffer.is_finish)
    end
end

-- 重置群英战战斗CD时间
function LegionHandler:sendResetCrossBattleChallengeCD(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_ResetCrossBattleChallengeCD", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_ResetCrossBattleChallengeCD, msgBuffer)
end

function LegionHandler:_onResetCrossBattleChallengeCD( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_ResetCrossBattleChallengeCD", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateBattleChallengeCD(decodeBuffer.battle_cd)
        G_Me.legionData:updateBattleCost(decodeBuffer.battle_cost)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_RESET_CHALLENGE_CD, nil, false, decodeBuffer.ret)
    end
end

-- 设置集火目标
function LegionHandler:sendSetCrossBattleFireOn( sid_, corpId )
    local buffer = 
    {
        sid = sid_,
        corp_id = corpId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_SetCrossBattleFireOn", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_SetCrossBattleFireOn, msgBuffer)
end

function LegionHandler:_onSetCrossBattleFireOn( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_SetCrossBattleFireOn", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:udpateFireOnCrossBattle(decodeBuffer.sid, decodeBuffer.corp_id)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_SET_BATTLE_FIRE_ON, nil, false, decodeBuffer.ret)
    end
end

-- 军团战绩排名
function LegionHandler:sendCrossBattleMemberRank(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_CrossBattleMemberRank", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_CrossBattleMemberRank, msgBuffer)
end

function LegionHandler:_onCrossBattleMemberRank( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_CrossBattleMemberRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateCrossBattleMemberRanks(decodeBuffer.ranks)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_MEMBER_RANK, nil, false, decodeBuffer.ret)
    end
end

-- 群英战战斗
function LegionHandler:sendCrossBattleChallengeEnemy( sid_, corpId, userId )
    local buffer = 
    {
    sid = sid_,
    corp_id = corpId, 
    user_id = userId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_CrossBattleChallengeEnemy", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_CrossBattleChallengeEnemy, msgBuffer)
end

function LegionHandler:_onCrossBattleChallengeEnemy( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_CrossBattleChallengeEnemy", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateBattleChallengeCD(decodeBuffer.battle_cd)
    end

    if rawget(decodeBuffer, "user") then
        G_Me.legionData:updateBattleUser(decodeBuffer.sid, decodeBuffer.corp_id, decodeBuffer.user)
    end

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_CHALLENGE_ENEMY, nil, false, decodeBuffer)
end
-- 把战斗结果刷给其它成员
function LegionHandler:_onFlushCorpBattleResult( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushCorpBattleResult", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
        G_Me.legionData:flushCrossBattleCorpInfo(decodeBuffer.corps)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_FLUSH_BATTLE_INFO, nil, false)
end

-- 把集火目标刷给其它成员
function LegionHandler:_onFlushFireOn( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushFireOn", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
        G_Me.legionData:udpateFireOnCrossBattle(decodeBuffer.sid, decodeBuffer.corp_id)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_FLUSH_FIRE_ON, nil, false)
end

-- 把战斗次数刷给其它成员
function LegionHandler:_onFlushBattleMemberInfo( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushBattleMemberInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    
    G_Me.legionData:flushBattleMemberInfo(decodeBuffer.user_id, decodeBuffer.kill_count, decodeBuffer.rob_exp)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_CROSS_FLUSH_MEMBER_INFO, nil, false)
end

--新的军团副本

-- 获取军团副本的章节信息
function LegionHandler:sendGetNewCorpChapter(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetNewCorpChapter", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetNewCorpChapter, msgBuffer)
end

function LegionHandler:_onGetNewCorpChapter( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetNewCorpChapter", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateNewChapterInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_NEW_CORP_CHATER_INFO, nil, false, decodeBuffer.ret)
    end
end

-- 获取军团副本的章节怪物信息
function LegionHandler:sendGetNewCorpDungeonInfo( chapterId )
    local buffer = 
    {
        chapter_id = chapterId,
    }
    --dump(buffer)
    local msgBuffer = protobuf.encode("cs.C2S_GetNewCorpDungeonInfo", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetNewCorpDungeonInfo, msgBuffer)
end

function LegionHandler:_onGetNewCorpDungeonInfo( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetNewCorpDungeonInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateNewCorpDungeonInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_NEW_CORP_DUNGEON_INFO, nil, false, decodeBuffer.ret)
    end
end

-- 挑战军团副本
function LegionHandler:sendExecuteNewCorpDungeon( id_ )
    if not self:checkCorpDispose() then 
        return 
    end
    local buffer = 
    {
        id = id_,
    }
    local msgBuffer = protobuf.encode("cs.C2S_ExecuteNewCorpDungeon", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_ExecuteNewCorpDungeon, msgBuffer)
end

function LegionHandler:_onExecuteNewCorpDungeon( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_ExecuteNewCorpDungeon", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        self:sendGetCorpDetail()
        G_Me.legionData:onNewCorpDungeonExecute(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EXECUTE_NEW_CORP_DUNGEON, nil, false, decodeBuffer)
    end
end

-- 获取章节副本奖励列表
function LegionHandler:sendGetNewDungeonAwardList( id )
    local buffer = 
    {
        dungeon_id = id
    }
    --dump(buffer)
    local msgBuffer = protobuf.encode("cs.C2S_GetNewDungeonAwardList", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetNewDungeonAwardList, msgBuffer)
end

function LegionHandler:_onGetNewDungeonAwardList( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetNewDungeonAwardList", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateNewDungeonAwardList(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_NEW_DUNGEON_AWARD_LIST, nil, false, decodeBuffer.ret)
       
    end
end

-- 砸蛋并获取奖励
function LegionHandler:sendGetNewDungeonAward(id, index_ )
    local buffer = 
    {
        dungeon_id = id,
        index = index_,
    }
    --dump(buffer)
    local msgBuffer = protobuf.encode("cs.C2S_GetNewDungeonAward", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetNewDungeonAward, msgBuffer)
end

function LegionHandler:_onGetNewDungeonAward( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetNewDungeonAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:onAddNewDungeonAward(decodeBuffer.dungeon_id,decodeBuffer.da)
        G_Me.legionData:updateNewHasAward(decodeBuffer.dungeon_id,decodeBuffer.has_award)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_NEW_DUNGEON_AWARD, nil, false, decodeBuffer.ret, decodeBuffer.awards)
    end
end

-- 获取军团成员排名 
function LegionHandler:sendGetNewDungeonCorpMemberRank(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetNewDungeonCorpMemberRank", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetNewDungeonCorpMemberRank, msgBuffer)
end

function LegionHandler:_onGetNewDungeonCorpMemberRank( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetNewDungeonCorpMemberRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateNewLegionRank(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_NEW_DUNGEON_CORP_MEMBER_RANK, nil, false, decodeBuffer.ret)
    end
end

function LegionHandler:_onFlushNewCorpDungeon( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushNewCorpDungeon", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    G_Me.legionData:onNewCorpDungeonExecute(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_FLUSH_NEW_CORP_DUNGEON, nil, false, decodeBuffer)
end

function LegionHandler:_onFlushNewDungeonAward( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FlushNewDungeonAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    G_Me.legionData:onAddNewDungeonAward(decodeBuffer.dungeon_id,decodeBuffer.da)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_FLUSH_NEW_DUNGEON_AWARD, nil, false)
end

-- 购买军团副本次数
function LegionHandler:sendResetNewDungeonCount(  )
    local buffer = 
    {
    }
    local msgBuffer = protobuf.encode("cs.C2S_ResetNewDungeonCount", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_ResetNewDungeonCount, msgBuffer)
end

function LegionHandler:_onResetNewDungeonCount( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_ResetNewDungeonCount", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:addNewBuyTimes(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RESET_NEW_DUNGEON_COUNT, nil, false, decodeBuffer.ret)
    end
end

-- 领取军团副本奖励
function LegionHandler:sendGetNewChapterAward( chapterId )
    local buffer = 
    {
        id = chapterId,
    }
    --dump(decodeBuffer)
    local msgBuffer = protobuf.encode("cs.C2S_GetNewChapterAward", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetNewChapterAward, msgBuffer)
end

function LegionHandler:_onGetNewChapterAward( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetNewChapterAward", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateNewChapterAward(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_NEW_CHAPER_AWARD, nil, false, decodeBuffer)
    end
end

function LegionHandler:sendGetNewDungeonAwardHint(  )
    local buffer = 
    {
    }
    --dump(buffer)
    local msgBuffer = protobuf.encode("cs.C2S_GetNewDungeonAwardHint", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetNewDungeonAwardHint, msgBuffer)
end

function LegionHandler:_onGetNewDungeonAwardHint( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetNewDungeonAwardHint", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateNewDungeonAwardHint(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_NEW_DUNGEON_AWARD_HINT, nil, false, decodeBuffer.ret)
    end
end

function LegionHandler:sendGetNewCorpChapterRank(  )
    local buffer = 
    {
    }
    --dump(buffer)
    local msgBuffer = protobuf.encode("cs.C2S_GetNewCorpChapterRank", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetNewCorpChapterRank, msgBuffer)
end

function LegionHandler:_onGetNewCorpChapterRank( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetNewCorpChapterRank", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:updateCorpChapterRank(decodeBuffer.ranks)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_GET_NEW_CORP_CHAPER_RANK, nil, false, decodeBuffer.ret)
    end
end

function LegionHandler:sendSetNewCorpRollbackChapter( _rollback )
    local buffer = 
    {
        rollback = _rollback,
    }
    --dump(buffer)
    local msgBuffer = protobuf.encode("cs.C2S_SetNewCorpRollbackChapter", buffer) 
    self:sendMsg(NetMsg_ID.ID_C2S_SetNewCorpRollbackChapter, msgBuffer)
end

function LegionHandler:_onSetNewCorpRollbackChapter( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_SetNewCorpRollbackChapter", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.legionData:setRollBack(decodeBuffer.rollback)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CORP_ROLLBACK, nil, false, decodeBuffer.ret)
    end
end

return LegionHandler

