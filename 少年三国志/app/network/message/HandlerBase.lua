--HandlerBase.lua

require("app.cfg.net_msg_error")
local HandlerBase = class ("HandlerBase")


function HandlerBase:ctor( ... )    
	self:_onCtor( ... )
    if patchMe and patchMe("handler", self) then return end
end

function HandlerBase:_onCtor( ... )
	-- body
end

function HandlerBase:initHandler( ... )
	-- body
end

function HandlerBase:unInitHandler( ... )
	-- body
end


local function _expand(t)
    if type(t) == "table" then
        for k, v in pairs(t) do  
            if type(v) == "table"  then
                local meta = getmetatable(v)
                if meta and meta.__pairs ~= nil then
                    protobuf.expand(v)
                end
                _expand(v)
            else

            end
        end
    end
end


function HandlerBase:sendMsg(id, buff) 
    G_NetworkManager:sendMsg(id, buff)
end




local _notNeedProcessRet = {
    ["cs.S2C_Login"] = 1,
    ["cs.S2C_SelectCrossBattleGroup"] = 1,
    ["cs.S2C_GetCrossBattleEnemy"] = 1,
    ["cs.S2C_ChallengeCrossBattleEnemy"] = 1,
    ["cs.S2C_CrossCountReset"] = 1,
    ["cs.S2C_GetCrossArenaInfo"] = 1,
    ["cs.S2C_GetCrossArenaBetsAward"] = 1,
    ["cs.S2C_GetCrossArenaRankUser"] = 1,
    ["cs.S2C_GetUserRice"] = 1,
    
    ["cs.S2C_GetCrossPvpSchedule"] = 1,
    ["cs.S2C_GetCrossPvpRole"] = 1,
    ["cs.S2C_GetCrossPvpRank"] = 1,
    ["cs.S2C_GetExpansiveDungeonChapterList"] = 1,
    ["cs.S2C_GetDays7CompInfo"] = 1,
}

function HandlerBase:_decodeBuf(key, buff, len)
    if len == 0 then
        --buffer len =0 , donot need to parse
        return {}
    end
    
    local buff, err = protobuf.decode(key, buff, len)
    _expand(buff)
    
    if buff == false then
        print("buff error " .. key .. ":" .. err)
    else
   --     dump(buff)
        if rawget(buff, "ret") and _notNeedProcessRet[key] == nil then
            self:_disposeErrorMsg(buff.ret)
        end
    end

    return buff
end

function HandlerBase:_disposeErrorMsg( ret )

    if ret ~= NetMsg_ERROR.RET_OK then
        --MessageBoxEx.showOkMessage(nil, G_NetMsgError.getMsg(ret))


        --if ret == 0 then
            --local ReconnectLayer = require("app.scenes.common.ReconnectLayer")
            --ReconnectLayer.show(G_lang:get("LANG_UNKNOWN_ERROR"), {reconnect=false})
           -- return
       -- end

        local errMsg = net_msg_error.get(ret)
        if errMsg == nil then
            errMsg = G_NetMsgError.getMsg(ret) 
            G_MovingTip:showMovingTip(errMsg and errMsg.msg or "Error code:"..(ret or 0) )
        else
            G_MovingTip:showMovingTip(errMsg and errMsg.error_msg or "Error code:"..(ret or 0) )
        end 
    end
end

function HandlerBase.ignore(msg,flag)
    _notNeedProcessRet[msg] = flag and 1 or nil
end

return HandlerBase