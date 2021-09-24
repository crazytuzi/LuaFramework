allianceWar2Vo={}
function allianceWar2Vo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceWar2Vo:initWithData(allianceWarTb)
    if allianceWarTb~=nil then
       for i=1,9,1 do
          local str="h"..i
          --
          if allianceWarTb.positionInfo~=nil and allianceWarTb.positionInfo[str]~=nil then
            --占空据点 弹tip
            --判断如果以前的据点为nil 或是 {} 并且aid为自己军团
            -- print("G_isShowTip",G_isShowTip)
            if G_isShowTip==true then
              if (self[str]==nil or SizeOfTable(self[str])==0) and allianceWarTb.positionInfo[str].aid==allianceVoApi:getSelfAlliance().aid and allianceWarTb.positionInfo[str].atts~=nil and allianceWarTb.positionInfo[str].atts==3 and allianceWar2VoApi:isInAllianceWarDialog() then
                local nameStr=allianceWarTb.positionInfo[str].nickname
                local oid = allianceWarTb.positionInfo[str].oid
                if tonumber(oid)==tonumber(playerVoApi:getUid()) then
                   nameStr=getlocal("you")
                end
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_tip1",{nameStr,i,getlocal(allianceWar2Cfg.stronghold[str].name)}),30)
              end

              -- --打赢了 弹tip
              -- --判断如果以前的据点aid跟自己不同 并且aid为自己 则为自己人打赢了 首先看aid~=nil
              -- if self[str]~=nil and self[str].aid~=nil and allianceWarTb.positionInfo[str]~=nil and allianceWarTb.positionInfo[str].aid~=nil and allianceWarTb.positionInfo[str].aid==allianceVoApi:getSelfAlliance().aid and allianceWarTb.positionInfo[str].atts==1 and allianceWar2VoApi:isInAllianceWarDialog() then
              --   local nameStr=allianceWarTb.positionInfo[str].nickname
              --   if nameStr==playerVoApi:getPlayerName() then
              --      nameStr=getlocal("you")
              --   end
              --   smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_tip1",{nameStr,i,getlocal(allianceWar2Cfg.stronghold[str].name)}),30)
              -- end

              --防御成功 弹tip
              --判断aid相同 uid相同但是部队数量不同
              if allianceWarTb.positionInfo[str]~=nil and allianceWarTb.positionInfo[str].oid==playerVoApi:getUid() and allianceWarTb.positionInfo[str].atts~=nil and allianceWarTb.positionInfo[str].atts==2 and allianceWar2VoApi:isInAllianceWarDialog() then

                      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_tip2",{i,getlocal(allianceWar2Cfg.stronghold[str].name)}),30)

              end

              --防御失败 弹tip
              --判断aid不相同 且不为自己的aid 则防守失败 首先看aid~=nil
              if self[str]~=nil and self[str].aid~=nil and allianceWarTb.positionInfo[str]~=nil and allianceWarTb.positionInfo[str].aid~=nil and allianceWarTb.positionInfo[str].aid~=self[str].aid and allianceWarTb.positionInfo[str].aid~=allianceVoApi:getSelfAlliance().aid and self[str].oid==playerVoApi:getUid() and allianceWar2VoApi:isInAllianceWarDialog() then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_tip3",{i,getlocal(allianceWar2Cfg.stronghold[str].name)}),30)

                  if base.heroSwitch==1 then
                    --请求英雄数据
                    local function heroGetlistHandler(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if base.he==1 and sData and sData.data and sData.data.equip and heroEquipVoApi then
                                heroEquipVoApi:formatData(sData.data.equip)
                                heroEquipVoApi.ifNeedSendRequest=true
                            end
                        end
                    end
                    socketHelper:heroGetlist(heroGetlistHandler)
                  end
              end

              --玩家离开据点 弹tip
              --之前有值现在为空表 判断aid是否为自己人 则为自己人离开了
              if self[str]~=nil and SizeOfTable(self[str])~=0 and SizeOfTable(allianceWarTb.positionInfo[str])==0 and self[str].aid==allianceVoApi:getSelfAlliance().aid and allianceWar2VoApi:isInAllianceWarDialog() then
                local nameStr=self[str].nickname
                local oid = self[str].oid or 0
                if tonumber(oid)==tonumber(playerVoApi:getUid()) then
                   nameStr=getlocal("you")
                end
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_tip4",{nameStr,i,getlocal(allianceWar2Cfg.stronghold[str].name)}),30)
              end
            end
    -- print("allianceWarTb.positionInfo[str].oid",allianceWarTb.positionInfo[str].oid)
            local occupyData=allianceWar2VoApi:getOccupyData()
            if occupyData and occupyData[str] and occupyData[str]==true then
              allianceWar2VoApi:setOccupyData(str,nil)
            end
            if allianceWarTb.positionInfo[str].oid==playerVoApi:getUid() then
              local troops=allianceWarTb.positionInfo[str].troops
              local hero=allianceWarTb.positionInfo[str].heros
              local aitroops=allianceWarTb.positionInfo[str].aitroops --AI部队
              local emblemID=allianceWarTb.positionInfo[str].equip
              local planePos=allianceWarTb.positionInfo[str].plane
              local tskin = allianceWarTb.positionInfo[str].skin --坦克皮肤数据
              local airshipId = allianceWarTb.positionInfo[str].ap --上阵飞艇
              if troops then
                  local tType=31
                  if troops then
                      for k,v in pairs(troops) do
                          if v and v[1] and v[2] then
                              local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
                              local num=tonumber(v[2])
                              tankVoApi:setTanksByType(tType,k,id,num)
                          else
                              tankVoApi:deleteTanksTbByType(tType,k)
                          end
                      end
                  end
                  if hero then
                      heroVoApi:setAllianceWar2CurHeroList(hero)
                  end
                  --设置当前AI部队
                  if aitroops then
                    AITroopsFleetVoApi:setAllianceWar2CurAITroopsList(aitroops)
                  end
                  emblemVoApi:setBattleEquip(tType,emblemID)
                  if planePos and type(planePos)=="string" then
                      local planeVo=planeVoApi:getPlaneVoById(planePos)
                      if planeVo and planeVo.idx then
                          planeVoApi:setBattleEquip(tType,planeVo.idx)
                      else
                          planeVoApi:setBattleEquip(tType,nil)
                      end
                  else
                      planeVoApi:setBattleEquip(tType,planePos)
                  end
                  if tskin then
                    tankSkinVoApi:setTankSkinListByBattleType(tType,G_clone(tskin))
                  end
                  if airshipId then
                    airShipVoApi:setBattleEquip(tType, airshipId)
                  end
                  allianceWar2VoApi:setOccupyData(str,true)
              -- else
              --     local troops=tankVoApi:getTanksTbByType(30)
              --     -- print("troops~~~~~",troops,SizeOfTable(troops))
              --     -- G_dayin(troops)
              --     if troops then
              --         local tType=31
              --         for k,v in pairs(troops) do
              --             if v and v[1] and v[2] then
              --                 local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
              --                 local num=tonumber(v[2])
              --                 tankVoApi:setTanksByType(tType,k,id,num)
              --             else
              --                 tankVoApi:deleteTanksTbByType(tType,k)
              --             end
              --         end
              --     end
              end
            end

            self[str]=allianceWarTb.positionInfo[str]
          end

       end
       if allianceWarTb.positionInfo~=nil and allianceWarTb.positionInfo.point~=nil then
          if self.perPoint==nil then
              self.perPoint={0,0}
          end
          if self.point==nil then
              self.lastPointTime=base.serverTime
          elseif self.lastPointTime and base.serverTime-self.lastPointTime>=10 then
              local oldPoint={0,0}
              local newPoint={0,0}
              if self.point then
                  oldPoint=self.point
              end
              if allianceWarTb.positionInfo.point then
                  newPoint=allianceWarTb.positionInfo.point
              end
              if oldPoint[1] and newPoint[1] then
                  self.perPoint[1]=newPoint[1]-oldPoint[1]
              end
              if oldPoint[2] and newPoint[2] then
                  self.perPoint[2]=newPoint[2]-oldPoint[2]
              end
              self.lastPointTime=base.serverTime
          end
          self.point=allianceWarTb.positionInfo.point
       end
       
       local isOccupied=false
       local occupyData=allianceWar2VoApi:getOccupyData()
       if occupyData then
           for k,v in pairs(occupyData) do
              if v and v==true then
                  isOccupied=true
              end
           end
       end
       -- print("isOccupied",isOccupied)
        if isOccupied==false then
            local troops
            local savedTroops=allianceWar2VoApi:getSavedTroops()
            if savedTroops and savedTroops.tanks then
                troops=savedTroops.tanks
            else
                troops=tankVoApi:getTanksTbByType(32)
            end
            -- print("troops-----")
            -- G_dayin(troops)
            if troops then
                local tType=31
                for k,v in pairs(troops) do
                    if v and v[1] and v[2] then
                        local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
                        local num=tonumber(v[2])
                        tankVoApi:setTanksByType(tType,k,id,num)
                    else
                        tankVoApi:deleteTanksTbByType(tType,k)
                    end
                end
            end
            local hero
            if savedTroops and savedTroops.hero then
                hero=savedTroops.hero
            else
                hero=heroVoApi:getAllianceWar2HeroList()
            end
            if hero then
                heroVoApi:setAllianceWar2CurHeroList(hero)
            end
            local aitroops
            if savedTroops and savedTroops.aitroops then
              aitroops=savedTroops.aitroops
            else
              aitroops=AITroopsFleetVoApi:getAllianceWar2AITroopsList()
            end
            if aitroops then
              AITroopsFleetVoApi:setAllianceWar2CurAITroopsList(aitroops)
            end
            local emblemID 
            if savedTroops and savedTroops.equip then
                emblemID=savedTroops.equip
            else
                emblemID=emblemVoApi:getBattleEquip(32)
            end
            emblemVoApi:setBattleEquip(31,emblemID)
            local planePos 
            if savedTroops and savedTroops.plane then
                planePos=savedTroops.plane
            else
                planePos=planeVoApi:getBattleEquip(32)
            end
            planeVoApi:setBattleEquip(31,planePos)
            local tskin
            if savedTroops and savedTroops.tskin then
              tskin=savedTroops.tskin
            else
              tskin=tankSkinVoApi:getTankSkinListByBattleType(32)
            end
            if tskin then
              tankSkinVoApi:setTankSkinListByBattleType(31, tskin)
            end
            local airshipId
            if savedTroops and savedTroops.airship then
              airshipId = savedTroops.airship
            else
              airshipId = airShipVoApi:getBattleEquip(32)
            end
            airShipVoApi:setBattleEquip(31, airshipId)
        end

       -- print("allianceWarTb.troops",allianceWarTb.troops)
       -- if allianceWarTb.troops then
       --    local troops=allianceWarTb.troops.troops
       --    local hero=allianceWarTb.troops.hero
       --    local tType=31
       --    if troops then
       --        for k,v in pairs(troops) do
       --            if v and v[1] and v[2] then
       --                local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
       --                local num=tonumber(v[2])
       --                tankVoApi:setTanksByType(tType,k,id,num)
       --            else
       --                tankVoApi:deleteTanksTbByType(tType,k)
       --            end
       --        end
       --    end
       --    if hero then
       --        heroVoApi:setAllianceWar2HeroList(hero)
       --    end
       -- else
       --    local troops=tankVoApi:getTanksTbByType(32)
       --    -- print("troops~~~~~",troops,SizeOfTable(troops))
       --    -- G_dayin(troops)
       --    if troops then
       --        local tType=31
       --        for k,v in pairs(troops) do
       --            if v and v[1] and v[2] then
       --                local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
       --                local num=tonumber(v[2])
       --                tankVoApi:setTanksByType(tType,k,id,num)
       --            else
       --                tankVoApi:deleteTanksTbByType(tType,k)
       --            end
       --        end
       --    end
       -- end
    end
end

function allianceWar2Vo:isChange(tb1,tb2)
  local isSame = true
  for k,v in pairs(tb1) do
    if v[1]~=tb2[k][1] or v[2]~=tb2[k][2] or v[3]~=tb2[k][3] then
        isSame=false
        break
    end
  end
  return isSame
end








