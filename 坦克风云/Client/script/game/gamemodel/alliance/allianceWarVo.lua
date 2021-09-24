allianceWarVo={}
function allianceWarVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function allianceWarVo:initWithData(allianceWarTb)
    if allianceWarTb~=nil then
       for i=1,9,1 do
          local str="h"..i
          --
          if allianceWarTb.positionInfo~=nil and allianceWarTb.positionInfo[str]~=nil then
            --占空据点 弹tip
            --判断如果以前的据点为nil 或是 {} 并且aid为自己军团
            if G_isShowTip==true then
              if (self[str]==nil or SizeOfTable(self[str])==0) and allianceWarTb.positionInfo[str].aid==allianceVoApi:getSelfAlliance().aid and allianceWarTb.positionInfo[str].atts~=nil and allianceWarTb.positionInfo[str].atts==3 and allianceWarVoApi:isInAllianceWarDialog() then
                local nameStr=allianceWarTb.positionInfo[str].nickname
                if nameStr==playerVoApi:getPlayerName() then
                   nameStr=getlocal("you")
                end
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_tip1",{nameStr,i,getlocal(allianceWarCfg.stronghold[str].name)}),30)
              end

              --打赢了 弹tip
              --判断如果以前的据点aid跟自己不同 并且aid为自己 则为自己人打赢了 首先看aid~=nil
              if self[str]~=nil and self[str].aid~=nil and allianceWarTb.positionInfo[str]~=nil and allianceWarTb.positionInfo[str].aid~=nil and allianceWarTb.positionInfo[str].aid==allianceVoApi:getSelfAlliance().aid and allianceWarTb.positionInfo[str].atts==1 and allianceWarVoApi:isInAllianceWarDialog() then
                local nameStr=allianceWarTb.positionInfo[str].nickname
                if nameStr==playerVoApi:getPlayerName() then
                   nameStr=getlocal("you")
                end
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_tip1",{nameStr,i,getlocal(allianceWarCfg.stronghold[str].name)}),30)
              end

              --防御成功 弹tip
              --判断aid相同 uid相同但是部队数量不同
              if allianceWarTb.positionInfo[str]~=nil and allianceWarTb.positionInfo[str].oid==playerVoApi:getUid() and allianceWarTb.positionInfo[str].atts~=nil and allianceWarTb.positionInfo[str].atts==2 and allianceWarVoApi:isInAllianceWarDialog() then

                      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_tip2",{i,getlocal(allianceWarCfg.stronghold[str].name)}),30)

              end

              --防御失败 弹tip
              --判断aid不相同 且不为自己的aid 则防守失败 首先看aid~=nil
              if self[str]~=nil and self[str].aid~=nil and allianceWarTb.positionInfo[str]~=nil and allianceWarTb.positionInfo[str].aid~=nil and allianceWarTb.positionInfo[str].aid~=self[str].aid and allianceWarTb.positionInfo[str].aid~=allianceVoApi:getSelfAlliance().aid and self[str].oid==playerVoApi:getUid() and allianceWarVoApi:isInAllianceWarDialog() then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_tip3",{i,getlocal(allianceWarCfg.stronghold[str].name)}),30)

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
              if self[str]~=nil and SizeOfTable(self[str])~=0 and SizeOfTable(allianceWarTb.positionInfo[str])==0 and self[str].aid==allianceVoApi:getSelfAlliance().aid and allianceWarVoApi:isInAllianceWarDialog() then
                local nameStr=self[str].nickname
                if nameStr==playerVoApi:getPlayerName() then
                   nameStr=getlocal("you")
                end
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar_tip4",{nameStr,i,getlocal(allianceWarCfg.stronghold[str].name)}),30)
              end
            end
 
            self[str]=allianceWarTb.positionInfo[str]
          end

       end
       if allianceWarTb.positionInfo~=nil and allianceWarTb.positionInfo.point~=nil then
          self.point=allianceWarTb.positionInfo.point
       end
    end
end

function allianceWarVo:isChange(tb1,tb2)
  local isSame = true
  for k,v in pairs(tb1) do
    if v[1]~=tb2[k][1] or v[2]~=tb2[k][2] or v[3]~=tb2[k][3] then
        isSame=false
        break
    end
  end
  return isSame
end








