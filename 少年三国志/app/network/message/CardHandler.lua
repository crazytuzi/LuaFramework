--CardHandler.lua

local HandlerBase = require("app.network.message.HandlerBase")
local CardHandler = class ("CardHandler", HandlerBase)

function CardHandler:_onCtor( ... )
	
end

function CardHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FightKnight, self._onReceiveFightKnight, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChangeFormation, self._onReceiveChangeFormation, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ChangeTeamKnight, self._onReceiveChangeTeamFormation, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AddTeamKnight, self._onReceiveAddTeamKnight, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetKnight, self._onReceiveFightInfo, self)
    --uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_OpObject, self._onReceiveKnightChange, self)
end

function CardHandler:_onReceiveFightKnight(  msgId, msg, len )
	local buff = self:_decodeBuf("cs.S2C_FightKnight", msg, len)
    if type(buff) ~= "table" then 
        return 
    end

	if type(buff.first_team) == "table" and type(buff.first_formation) == "table" then
		G_Me.formationData:updateFormation( 1, buff.first_team, buff.first_formation )
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FORMATION_UPDATE, nil, false, 1 )
	else
		__LogError("_onReceiveFightKnight data error ")
	end

	if type(buff.second_team) == "table" and type(buff.second_formation) == "table" then
		G_Me.formationData:updateFormation( 2, buff.second_team, buff.second_formation )
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FORMATION_UPDATE, nil, false, 2 )
	else
		__LogError("_onReceiveFightKnight data error ")
	end

        --排序
        G_Me.bagData.knightsData:sortKnights()
end

--function CardHandler:_onReceiveKnightChange( msgId, msg, len )
--	__Log("CardHandler:_onReceiveKnightChange")
	--local buff = self:_decodeBuf("cs.S2C_OpObject", msg, len)
	--if buff.knight ~= nil then
	--	return 
	--end

--dump(buff)
--	G_Me.bagData.knightsData:addKnightInfo(buff.knight.insert_knights)
--	G_Me.bagData.knightsData:updateKnightInfo(buff.knight.update_knights)
--	G_Me.bagData.knightsData:removeKnightInfo(buff.knight.delete_knights)

--end

function CardHandler:_onReceiveChangeFormation(  msgId, msg, len )
	local buff = self:_decodeBuf("cs.S2C_ChangeFormation", msg, len)
	
    if type(buff) ~= "table" then 
        return 
    end
	--self:_disposeErrorMsg(buff.ret)
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CHANGE_FORMATION, nil, false, buff.ret )
end

function CardHandler:_onReceiveChangeTeamFormation(  msgId, msg, len )
	local buff = self:_decodeBuf("cs.S2C_ChangeTeamKnight", msg, len)
	
    if type(buff) ~= "table" then 
        return 
    end
	--self:_disposeErrorMsg(buff.ret)
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CHANGE_TEAM_FORMATION, nil, false, buff.ret, buff.team, buff.pos, buff.old_knight_id, buff.knight_id)
end

function CardHandler:_onReceiveAddTeamKnight( msgId, msg, len )
	local buff = self:_decodeBuf("cs.S2C_AddTeamKnight", msg, len)
	
    if type(buff) ~= "table" then 
        return 
    end
	--dump(buff)
	--self:_disposeErrorMsg(buff.ret)
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ADD_TEAM_KNIGHT, nil, false, buff.ret, buff.knight_id, buff.pos )
end

function CardHandler:_onReceiveFightInfo( msgId, msg, len )
	local buff = self:_decodeBuf("cs.S2C_GetKnight", msg, len)
    if type(buff) ~= "table" then 
        return 
    end
	if type(buff.knights) ~= "table" then
		__LogError("_onReceiveFightInfo data error ")
		return 
	end
        
	G_Me.bagData.knightsData:resetLocalKnightInfo(buff.knights)
end

function CardHandler:fetchFightKnight(  )
	--local data = 
    --{
   -- }

   -- local msgBuffer = protobuf.encode("cs.C2S_FightKnight", data)
   -- self:sendMsg(NetMsg_ID.ID_C2S_FightKnight, msgBuffer)

end

function CardHandler:changeFormation( teamId, indexTable )
	local data = 
    {
        formation_id = teamId,
        indexs = indexTable,
    }

    local msgBuffer = protobuf.encode("cs.C2S_ChangeFormation", data)
    self:sendMsg(NetMsg_ID.ID_C2S_ChangeFormation, msgBuffer)
end

function CardHandler:changeTeamFormation( teamId, posIndex, knightId )
	local data = 
    {
        team = teamId,
        pos = posIndex,
        knight_id = knightId,
    }
    local msgBuffer = protobuf.encode("cs.C2S_ChangeTeamKnight", data)
    self:sendMsg(NetMsg_ID.ID_C2S_ChangeTeamKnight, msgBuffer)

end

function CardHandler:addTeamKnight( knightId )
	local data = 
    {
        knight_id = knightId,
    }

    local msgBuffer = protobuf.encode("cs.C2S_AddTeamKnight", data)
    self:sendMsg(NetMsg_ID.ID_C2S_AddTeamKnight, msgBuffer)
end


return CardHandler
