allianceWar2UserVo={}
function allianceWar2UserVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceWar2UserVo:initWithData(warUserData)
    -- if allianceWarUserTb~=nil and SizeOfTable(allianceWarUserTb)>0 then
    if warUserData and warUserData.useralliancewar and SizeOfTable(warUserData.useralliancewar)>0 then
        local allianceWarUserTb=warUserData.useralliancewar
        if allianceWarUserTb.uid~=nil and allianceWarUserTb.uid==playerVoApi:getUid() then
            self.battle_at=allianceWarUserTb.battle_at
            self.b1=allianceWarUserTb.b1
            self.b2=allianceWarUserTb.b2
            self.b3=allianceWarUserTb.b3
            self.b4=allianceWarUserTb.b4
            self.cdtime_at=allianceWarUserTb.cdtime_at
            self.buff_at=allianceWarUserTb.buff_at
            self.task=allianceWarUserTb.task

            local savedTroops={tanks={{},{},{},{},{},{}},hero={0,0,0,0,0,0}}
            if allianceWarUserTb.info then
                local battleType = 32
                local troops=allianceWarUserTb.info.troops
                local hero=allianceWarUserTb.info.hero
                local aitroops=allianceWarUserTb.info.aitroops --AI部队数据
                local emblemID=allianceWarUserTb.info.equip
                local planePos=allianceWarUserTb.info.plane
                local tskin=allianceWarUserTb.info.skin --坦克皮肤数据
                local airshipId = allianceWarUserTb.info.ap --上阵飞艇
                -- print("allianceWarUserTb.info.troops",allianceWarUserTb.info.troops)
                if troops then
                    for k,v in pairs(troops) do
                        if v and v[1] and v[2] then
                            local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
                            local num=tonumber(v[2])
                            tankVoApi:setTanksByType(battleType,k,id,num)
                        else
                            tankVoApi:deleteTanksTbByType(battleType,k)
                        end
                    end
                    savedTroops.tanks=G_clone(tankVoApi:getTanksTbByType(battleType))
                end
                if hero then
                    heroVoApi:setAllianceWar2HeroList(hero)
                    savedTroops.hero=G_clone(hero)
                end
                --AI部队设置
                if aitroops then
                    AITroopsFleetVoApi:setAllianceWar2AITroopsList(aitroops)
                    savedTroops.aitroops=G_clone(aitroops)
                end
                savedTroops.equip=emblemID
                emblemVoApi:setBattleEquip(battleType,emblemID)
                savedTroops.plane=planePos
                planeVoApi:setBattleEquip(battleType,planePos)
                if tskin then
                    tankSkinVoApi:setTankSkinListByBattleType(battleType, G_clone(tskin))
                    savedTroops.tskin=tskin
                end
                airShipVoApi:setBattleEquip(battleType,airshipId)
                savedTroops.airship=airshipId
                allianceWar2VoApi:setSavedTroops(savedTroops)
            end
        end
    end
end