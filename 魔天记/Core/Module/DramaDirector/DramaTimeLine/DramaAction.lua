
DramaAction = class("DramaAction", DramaAbs);
local insert = table.insert

function DramaAction:_Init()
    
end

function DramaAction:_Begin(fixed)
    local t = self.config[DramaAbs.EvenType]
    local p1 = self.config[DramaAbs.EvenParam1]
    local p2 = self.config[DramaAbs.EvenParam2]
    if t == DramaEventType.BornNpc then -- 剧情生成战斗角色
        local hpos = self._hero:GetPos()
        local hy = self._hero:GetAngleY()
        local hkind = PlayerManager.GetPlayerKind()
        local data = {}
        local dis = tonumber(p2[1])
        local len = #p1
        local atr = math.pi / 180
        local angle = hy
        local addAngle = 360 / 3
        local addadd = addAngle / 3
        local maxn = 360 / addadd
        --for i=1,10,1 do
        for i=1,len,2 do
            if tonumber(p1[i + 1]) ~= hkind then
                local pos = hpos:Clone()
                local n = 0
                while true do
                    pos.x = pos.x + math.sin(angle * atr) * dis
                    pos.z = pos.z + math.cos(angle * atr) * dis    
                    if GameSceneManager.mpaTerrain:IsWalkRound(pos) or n == maxn then
                        break
                    else
                        angle = (angle + addadd) % 360
                        n = n + 1
                        pos:Set(hpos.x, hpos.y, hpos.z)
                    end
                end
                local d = Convert.PointToServer(pos, hy);
                d.npc = tonumber(p1[i])
                insert(data, d)
                --local go = Resourcer.Get("Roles","m_byd005")go.transform.position = pos go.name = p1[i+1] .. '__' .. angle
                angle = (angle + addAngle) % 360
            end
        end
        --end
        --PrintTable(data,"---BornNpc---",Warning)
        SocketClientLua.Get_ins():SendMessage(CmdType.DRAMA_CREATE_ROLE, { l=data })
    elseif t == DramaEventType.DeleteNpc then -- 剧情删除战斗角色
        local data = {}
        for i=1,#p1,1 do insert(data, tonumber(p1[i])) end
        --PrintTable(data,"---DeleteNpc---",Warning)
        SocketClientLua.Get_ins():SendMessage(CmdType.DRAMA_DELETE_ROLE, { l=data })
    elseif t == DramaEventType.GiveTrump or t == DramaEventType.DeleteTrump then
        local tid = tonumber(p1[1])
        local sid = nil
        if t == DramaEventType.DeleteTrump then tid = 0--触发删除法宝
        else
            sid = NewTrumpManager.GetSkillIdByTrumpId(tid)
            SocketClientLua.Get_ins():SendMessage(CmdType.DRAMA_CREATE_TRUMP)
        end
        --Warning("DramaEventType.GiveTrump,tid=" .. tid .. ",sid=" .. tostring(sid)) --触发赋予法宝
        PlayerManager.GetPlayerInfo():SetTrumpSkill(sid)
        MessageManager.Dispatch(NewTrumpManager, NewTrumpManager.SelfTrumpFollow);
        self._hero.info.dress.t = tid
        self._hero:ChangeTrump()
    elseif t == DramaEventType.GuideStep then
        GuideManager.GuideNovice(tonumber(p1[1]))
    end
end


