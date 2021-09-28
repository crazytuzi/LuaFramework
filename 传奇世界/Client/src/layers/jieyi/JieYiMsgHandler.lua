local jyCommFunc = require("src/layers/jieyi/JieYiCommFunc")

--[[
SwornAtvOperateType = 
{
	Transmit = 1,		-- 传送
	ReqGather = 2,		-- 请求召唤
	AgreeGather = 3,	-- 同意被召唤
}
]]

local function swornEnterSceneDealer( luaBuffer )
    local retTable = g_msgHandlerInst:convertBufferToTable("EnterSwornSceneRes", luaBuffer)
    if retTable.result then     -- 1 in no team 2 level not enough 3 clicked wrong npc 4 diff jieye
        jyCommFunc.showJieYiErrorCode(retTable.result,retTable.sid)
    end 
end
                        
local function startCeremonyDealer(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("StartSwornCeremony", luaBuffer)
    -- no data in this message
    jyCommFunc.showJieYiConfirmDialog()
end
                        
                        
local function agreeDealer(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("AgreeSwornAction", luaBuffer)
    jyCommFunc.addJieYiMem(retTable.roleId,retTable.done)
end          

local function onZHRecvd(luaBuffer)             -- received zhaohuan msg from server
    local retTable = g_msgHandlerInst:convertBufferToTable("SwornSkillGatherBro", luaBuffer)
    if retTable.sid == userInfo.currRoleStaticId then
        return
    end
    jyCommFunc.showZHRemindLayer(retTable.sid,retTable.name,retTable.map)
end

local function onSecondaryPassStateRece(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("SecondPassGetInvalidSecondsRetProtocol", luaBuffer)
    require("src/layers/setting/SecondaryPassword").setPassState(retTable.dwPassStatus,retTable.dwInvalidSeconds)
    --print("luabuffer receive ...")
end

local function onJieYiDismiss(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("SwornDoActionRet", luaBuffer)
    
    if retTable.type == 1 then
        -- remove mem
        if retTable.target_id == userInfo.currRoleStaticId then
            jyCommFunc.setJYData(0,nil)
            MessageBox(game.getStrByKey("jy_removed"),nil,nil)    
        else
            local soName = jyCommFunc.getJYMemName(retTable.target_id)
            if soName then
                MessageBox( string.format(game.getStrByKey("jy_someone_remove"),soName) ,nil,nil)    
            end
        end
    elseif retTable.type == 2 then
        -- gepaoduanyi
        if retTable.target_id == userInfo.currRoleStaticId then
            jyCommFunc.setJYData(0,nil)
            MessageBox(game.getStrByKey("jy_quit"),nil,nil)    
        else
            local soName = jyCommFunc.getJYMemName(retTable.target_id)
            if soName then
                MessageBox( string.format(game.getStrByKey("jy_someone_quit"),soName) ,nil,nil)    
            end
        end
    elseif retTable.type == 4 then
        jyCommFunc.setJYData(0,nil)
        MessageBox(game.getStrByKey("jy_dismiss"),nil,nil)
    end

end

local function onJieYiBasicInfoRecvd(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("SwornBasicInfoRet", luaBuffer)
    jyCommFunc.setJYData(retTable.sworn_id,retTable.bros)
end

local function onJieYiOnLineRemind(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("SwornBroOnlieStatus", luaBuffer)
    if retTable.sid == userInfo.currRoleStaticId then
        return
    end
    local memData = jyCommFunc.getJYMemData(retTable.sid)
    local name = memData and memData.name or nil
    if name then
        if retTable.online then
            local con = string.format(game.getStrByKey("jy_online_remind"),name)
            TIPS({type=1,str=con})
        else
            local con = string.format(game.getStrByKey("jy_offline_remind"),name)
            TIPS({type=1,str=con})
        end
    end
end

local function onJieYiUpgrade(luaBuffer)
    local retTable = g_msgHandlerInst:convertBufferToTable("NotifySwornRelationLvl", luaBuffer)
    local jyName = jyCommFunc.getJieYiRelationShipNameWithLevel(retTable.relation_lvl)
    if retTable.upgrade then
        -- upgrade
        local con = string.format(game.getStrByKey("jy_upgrade_name"),jyName)
        TIPS({type=1,str=con})
    else
        -- downgrade
        local con = string.format(game.getStrByKey("jy_downgrade_name"),jyName)
        TIPS({type=1,str=con})
    end

end

-- jieyi 
g_msgHandlerInst:registerMsgHandler( SWORN_SC_ENTER_SCENE , swornEnterSceneDealer )
g_msgHandlerInst:registerMsgHandler( SWORN_SC_START_CEREMONY , startCeremonyDealer )
g_msgHandlerInst:registerMsgHandler( SWORN_SC_AGREE_ACTION , agreeDealer )
g_msgHandlerInst:registerMsgHandler( SWORN_SC_SKILL_GATHER_BRO , onZHRecvd )
g_msgHandlerInst:registerMsgHandler( SWORN_SC_BASIC_INFO, onJieYiBasicInfoRecvd )
g_msgHandlerInst:registerMsgHandler( SWORN_SC_BRO_ONLINE_STATUS, onJieYiOnLineRemind )
g_msgHandlerInst:registerMsgHandler( SWORN_SC_RELATION_LVL_RET, onJieYiUpgrade )
-- secondary password
g_msgHandlerInst:registerMsgHandler( ESPASS_SC_PASSWORD_INVALID_SECONDS , onSecondaryPassStateRece )
g_msgHandlerInst:registerMsgHandler( SWORN_SC_DO_ACTION_RET , onJieYiDismiss )