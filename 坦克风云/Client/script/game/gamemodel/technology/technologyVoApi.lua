technologyVoApi={
    allTechTbs={},
    techValueCfg=nil,
}


function technologyVoApi:init(techTb)
    local techCfgLocal=Split(buildingCfg[8].buildPropSids,",")
    local unlockIndex=1
    for kk=2,#techCfgLocal,2 do
        if (tonumber(techCfgLocal[kk])==26 or tonumber(techCfgLocal[kk])==27) then
            if base.allianceHelpSwitch==1 then
                local tvo=technologyVo:new()
                tvo:initWithData(tonumber(techCfgLocal[kk]),(techTb[tonumber(techCfgLocal[kk])]==nil and 0 or techTb[tonumber(techCfgLocal[kk])]))
                -- tvo.unlockIndex=unlockIndex
                tvo.unlockIndex=tonumber(techCfgLocal[kk-1])
                table.insert(self.allTechTbs,tvo)
                unlockIndex=unlockIndex+1
            end
        else
            local tvo=technologyVo:new()
            tvo:initWithData(tonumber(techCfgLocal[kk]),(techTb[tonumber(techCfgLocal[kk])]==nil and 0 or techTb[tonumber(techCfgLocal[kk])]))
            -- tvo.unlockIndex=unlockIndex
            tvo.unlockIndex=tonumber(techCfgLocal[kk-1])
            table.insert(self.allTechTbs,tvo)
            unlockIndex=unlockIndex+1
        end
    end

    if base.ubh==1 then
        for i=#self.allTechTbs,1,-1 do
            local tcfg=techCfg[tonumber(self.allTechTbs[i].id)]
            if tonumber(tcfg.sid)==26 or tonumber(tcfg.sid)==27 then
                table.remove(self.allTechTbs,i)
            end
        end
    end

end

function technologyVoApi:getAllTech()
    return self.allTechTbs
end

function technologyVoApi:update(techTb)
    for k,v in pairs(self.allTechTbs) do
        if techTb[v.id]~=nil then
            v.level=techTb[v.id]
            
        end
        v.status=0
    end
end

function technologyVoApi:resetStatus()
    local slotVo
    for k,v in pairs(self.allTechTbs) do
            slotVo=technologySlotVoApi:getSlotByTid(v.id)
            if slotVo~=nil then
                    v.status=slotVo.status
            else
                v.status=0
            end
    end

end

function technologyVoApi:setIsFinishedUpgrade(id,flag)
    for k,v in pairs(self.allTechTbs) do
        if id and id==v.id then
            self.allTechTbs[k].isFinishedUpgrade=flag
        end
    end
end
function technologyVoApi:getAllInfo(isSort)
    if base.allianceHelpSwitch==1 then
        if isSort==nil then
            isSort=true
        end
        if isSort==true then
            -- 1.建造中（同为建造中按照建造顺序排序）
            -- '2.资源够可建造（同为资源够可建造，按照科技ID排序）
            -- 3.资源不足，但已解锁（同为资源鼓足但已解锁，按照科技ID排序）
            -- 4.未解锁（同为未解锁，按照解锁等级高低排序，先排列优先解锁的）
            -- 5.科技ID
            for k,v in pairs(self.allTechTbs) do
                if v.status==0 then
                    -- local sortId=tonumber(v.id)
                    local isUpgrade=0
                    local isUnlock=0
                    local upgradeInfo,infos=self:getUpgradeInfo(v)
                    if upgradeInfo==true and infos~=-1 then
                        isUnlock=1
                        local result,results,have=self:checkUpgradeRequire(v.id)
                        if result==true then
                            isUpgrade=1
                        end
                    end
                    v.isUnlock=isUnlock
                    v.isUpgrade=isUpgrade
                    -- v.sortId=sortId
                    v.sortStatus=v.status
                    -- print("v.id,v.isUnlock,v.isUpgrade,v.unlockIndex~~~",v.id,v.isUnlock,v.isUpgrade,v.unlockIndex)
                else
                    if v.status==1 then
                        v.sortStatus=2
                    else
                        v.sortStatus=1
                    end
                    local slotVo=technologySlotVoApi:getSlotByTid(v.id)
                    v.sortAddTime=slotVo.addTime
                end
            end
            if self.allTechTbs and SizeOfTable(self.allTechTbs)>0 then
                local function sortFunc(a,b)
                    if a.sortStatus==0 and b.sortStatus==0 then
                        if a.isUnlock==1 and b.isUnlock==1 then
                            if a.isUpgrade and b.isUpgrade and a.isUpgrade~=b.isUpgrade then
                                return a.isUpgrade>b.isUpgrade
                            else
                                return a.id<b.id
                            end
                        elseif a.isUnlock==0 and b.isUnlock==0 then
                            if a.unlockIndex~=b.unlockIndex then
                                return a.unlockIndex<b.unlockIndex
                            else
                                return a.id<b.id
                            end
                        else
                            return a.isUnlock>b.isUnlock
                        end
                    elseif a.sortStatus~=b.sortStatus then
                        return a.sortStatus>b.sortStatus
                    else
                        return a.sortAddTime<b.sortAddTime
                    end
                end
                table.sort(self.allTechTbs,sortFunc)
            end
        end
        local resultTb=G_clone(self.allTechTbs)
        return resultTb
    else
        local techSlots=technologySlotVoApi:getAllSlotSortBySt()

        local resultTb={}  --在升级队列或等待队列里的要排到前面
        
        for k,v in pairs(techSlots) do
            table.insert(resultTb,self:getTechVoByTId(v.tid))
        end

        for k,v in pairs(self.allTechTbs) do
            
            if  v.status==0 then
                table.insert(resultTb,v)
            end
        end

        return resultTb
    end

end

--升级成功调用
function technologyVoApi:upgradeSuccess(id)
    local  tvo
    for k,v in pairs(self.allTechTbs) do
         if v.id==id then
            tvo=v
         end
    end
    if tvo~=nil then
        tvo.level=tvo.level+1
        tvo.status=0
    end
    G_cancelPush("tc"..id,G_TechUpgradeTag)
end


function technologyVoApi:getUpgradeInfo(techVo)
     local techBuildVo =buildingVoApi:getBuildingVoByBtype(8)[1]
     
     local tmpBuildVo
     if techBuildVo==nil then
            tmpBuildVo={level=0}
     else
            tmpBuildVo=techBuildVo
     end
     if (techVo.level>=playerVoApi:getMaxLvByKey("techMaxLevel") or techVo.level>=techCfg[techVo.id].maxLevel or (techCfg[techVo.id].intervalLv and techVo.level*techCfg[techVo.id].intervalLv>=playerVoApi:getMaxLvByKey("techMaxLevel"))) and (techVo.level >= playerVoApi:getHonorInfo())  then
        return true,-1
     end

      --区域战buff
      local buffValue=0
      if localWarVoApi then
          local buffType=2
          local buffTab=localWarVoApi:getSelfOffice()
          if G_getHasValue(buffTab,buffType)==true then
              buffValue=G_getLocalWarBuffValue(buffType)
          end
      end
      --军徽技能提升
      local emblemValue = 0
      if base.emblemSwitch == 1 then
          emblemValue = emblemVoApi:getSkillValue(1)
      end
      --三周活动七重福利所加的buff
      local threeYearAdd=0
      if acThreeYearVoApi then
        threeYearAdd=acThreeYearVoApi:getBuffAdded(7)
      end

    local warStatueBuff=0 --战争塑像的加成
    local battleBuff,skillBuff=warStatueVoApi:getTotalWarStatueAddedBuff("studySpeed")
    warStatueBuff=skillBuff.studySpeed or 0

     local baseTime=tonumber(Split(techCfg[techVo.id].timeConsumeArray,",")[techVo.level+1])
     local tecSpeed=playerCfg.tecSpeed[playerVoApi:getVipLevel()+1]
     local realTime=math.ceil(baseTime/(1+(tmpBuildVo.level-1)*0.05+tecSpeed+buffValue+emblemValue+threeYearAdd+warStatueBuff))
     if techVo.unlockIndex>tmpBuildVo.level then
         return false,realTime
     else
         return true,realTime
     end
end

function technologyVoApi:getTechVoByTId(tid)
    for  k,v in pairs(self.allTechTbs) do
         if v.id==tid then
             do
                return v
             end
         end
    end
    return nil
end
function technologyVoApi:getUpgradeRequire(tid)
          local results={}
          local tvo=self:getTechVoByTId(tid)
          if tvo~=nil then
              local tCfg=techCfg[tid]
              if tvo.level >= playerVoApi:getMaxLvByKey("techMaxLevel") and tvo.level >= techCfg[tvo.id].maxLevel and (tvo.level < playerVoApi:getHonorInfo() or playerVoApi:getHonorInfo() < playerVoApi:getHonorMaxLv()) then
                table.insert(results, playerVoApi:getMaxLvByKey("techMaxLevel"))
              else
                table.insert(results,tvo.level+1)
              end
              local honorLevel=tvo.level+1
              if tCfg.needhonors then
                 local honorTab=Split(tCfg.needhonors,",")
                 local honorPoint=tonumber(honorTab[tvo.level+1])
                 honorLevel=playerVoApi:getHonorInfo(honorPoint)
              end
              table.insert(results,honorLevel)

              local money=tonumber(Split(tCfg.moneyConsumeArray,",")[tvo.level+1])
              if money>0 then
                 table.insert(results,{"money",money})
              end

              local metal=tonumber(Split(tCfg.metalConsumeArray,",")[tvo.level+1])
              if metal>0 then
                 table.insert(results,{"metal",metal})
              end
              
              local oil=tonumber(Split(tCfg.oilConsumeArray,",")[tvo.level+1])
              if oil>0 then
                 table.insert(results,{"oil",oil})
              end
              
              local silicon=tonumber(Split(tCfg.siliconConsumeArray,",")[tvo.level+1])
              if silicon>0 then
                 table.insert(results,{"silicon",silicon})
              end
              
              local uranium=tonumber(Split(tCfg.uraniumConsumeArray,",")[tvo.level+1])
              if uranium>0 then
                 table.insert(results,{"uranium",uranium})
              end
              
              
              return results
          end
          
        return nil
end



function technologyVoApi:checkUpgradeRequire(tid)
    
      local require=technologyVoApi:getUpgradeRequire(tid)
      local results={}
      local result=true
      local have={}
      if require==nil or tonumber(require[1])==nil or buildingVoApi:getBuildingVoByBtype(8)[1].level==nil or require[1]>buildingVoApi:getBuildingVoByBtype(8)[1].level then --科研中心等级
              results[1]=false
              result=false
      else
              results[1]=true
      end
      local honorRank=playerVoApi:getHonorInfo()
      if require[2]>honorRank then --声望等级
           results[2]=false
           result=false
      else
           results[2]=true
      end
      have[1]=buildingVoApi:getBuildingVoByBtype(8)[1].level
      have[2]=honorRank
      
      for i=3,SizeOfTable(require) do
          local curHave
          if require[i][1]=="money" then
                curHave=playerVoApi:getGold()
          elseif require[i][1]=="metal" then
                curHave=playerVoApi:getR1()
          elseif require[i][1]=="oil" then
                curHave=playerVoApi:getR2()
          elseif require[i][1]=="silicon" then
                curHave=playerVoApi:getR3()
          elseif require[i][1]=="uranium" then
                curHave=playerVoApi:getR4()
          end
          if tonumber(require[i][2])>curHave then
              results[i]=false
              result=false
          else
              results[i]=true
          end
          have[i]=curHave
      end
      
      return result,results,have
end

function technologyVoApi:leftTime(tid)
    --local tvo=self:getTechVoByTId(tid)
    local slotVo=technologySlotVoApi:getSlotByTid(tid)
    --return tonumber(Split(techCfg[tvo.id].timeConsumeArray,",")[tvo.level+1])-(base.serverTime-slotVo.st),tonumber(Split(techCfg[tvo.id].timeConsumeArray,",")[tvo.level+1])
    return  slotVo.et-base.serverTime,slotVo.timeConsume
end




function technologyVoApi:cancleUpgrade(tid)
    --退资源
    --[[
    local require=self:getUpgradeRequire(tid)
     local m,o,s,u,g=0,0,0,0,0
     for kk=3,SizeOfTable(require) do
         if require[kk][1]=="metal" then
               m=tonumber(require[kk][2])
         elseif require[kk][1]=="oil" then
            o=tonumber(require[kk][2])
         elseif require[kk][1]=="silicon" then
            s=tonumber(require[kk][2])
         elseif require[kk][1]=="uranium" then
            u=tonumber(require[kk][2])
         elseif require[kk][1]=="money" then
            g=tonumber(require[kk][2])
         end
     end
     local leftTime,totalTime=self:leftTime(tid)
     local rate=leftTime/totalTime
     playerVoApi:useResource(-math.ceil(m*rate),-math.ceil(o*rate),-math.ceil(s*rate),-math.ceil(u*rate),-math.ceil(g*rate),0)
     ]]
    --修改Vo状态   
     local tvo=self:getTechVoByTId(tid)
     if tvo~=nil then
        tvo.status=0
     end
     G_cancelPush("tc"..tid,G_TechUpgradeTag)
    --删除队列
     technologySlotVoApi:cancleByTid(tid)
end

-- notCheckGems:是否不检测金币数量，在免费加速时传true
function technologyVoApi:checkSuperUpgradeBeforeSendServer(tid,notCheckGems)
        local tvo=self:getTechVoByTId(tid)
    if tvo.status==0 then
        do
            return false,1 --已经完成
        end
    end
     local leftTime,totalTime=self:leftTime(tid)

    if notCheckGems and notCheckGems==true then
    else
        if tvo.status==1 then
            local gems=TimeToGems(leftTime)
            if gems>playerVoApi:getGems() then --宝石不足
                 GemsNotEnoughDialog(nil,nil,gems-playerVoApi:getGems(),10,gems)
                 do
                    return false,2
                 end
            end
        end
    end
    return true
end

function technologyVoApi:superUpgrade(tid,showTipsWait)
    --[[
                local leftTime,totalTime=self:leftTime(tid)
                local tvo=self:getTechVoByTId(tid)
                if tvo.status==0 then
                    do
                        return false,1 --已经完成
                    end
                end
                if tvo.status==1 then
                    local gems=TimeToGems(leftTime)
                    if gems>playerVoApi:getGems() then --宝石不足
                         GemsNotEnoughDialog(nil,nil,gems-playerVoApi:getGems(),10,gems)
                         do
                            return false,2
                         end
                    else --加速成功
                         playerVoApi:useResource(0,0,0,0,0,gems) --扣除宝石
                         tvo.status=0 --修改vo状态
                         tvo.isFinishedUpgrade=false
                         tvo.level=tvo.level+1 --升级
                         technologySlotVoApi:cancleByTid(tid) --移除队列
                         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptResearchFinish",{getlocal(techCfg[tvo.id].name)}),28)
                    end
                end
    ]]
    local tvo=self:getTechVoByTId(tid)
    tvo.status=0 --修改vo状态
    tvo.isFinishedUpgrade=true
    --tvo.level=tvo.level+1 --升级
    technologySlotVoApi:cancleByTid(tid) --移除队列
    G_cancelPush("tc"..tid,G_TechUpgradeTag)
    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promptResearchFinish",{getlocal(techCfg[tvo.id].name)}),28,nil,nil,nil,nil,showTipsWait)
    return true
end

function technologyVoApi:checkUpgradeBeforeSendServer(tid)

     local result=self:checkUpgradeRequire(tid)
     if result==false then
         do
             return false,1
         end
     end
     if technologySlotVoApi:checkIsFull()==true then
           
          do
            return false,2
          end
     end
     return true
end

function technologyVoApi:upgrade(tid)
     --[[
             local result=self:checkUpgradeRequire(tid)
             if result==false then
                 do
                     return false,1
                 end
             end
             if technologySlotVoApi:add(tid)==false then
                   
                  do
                    return false,2
                  end
             end
     
             local require=self:getUpgradeRequire(tid)
             local m,o,s,u,g=0,0,0,0,0
             for kk=3,5 do
                 if require[kk][1]=="metal" then
                       m=tonumber(require[kk][2])
                 elseif require[kk][1]=="oil" then
                    o=tonumber(require[kk][2])
                 elseif require[kk][1]=="silicon" then
                    s=tonumber(require[kk][2])
                 elseif require[kk][1]=="uranium" then
                    u=tonumber(require[kk][2])
                 elseif require[kk][1]=="money" then
                    g=tonumber(require[kk][2])
                 end
             end
             playerVoApi:useResource(m,o,s,u,g,0)  --扣资源
     ]]
     local tvo=self:getTechVoByTId(tid) --修改Vo状态
     if tvo~=nil then
         local tslotVo=technologySlotVoApi:getSlotByTid(tid)
         tvo.status=tslotVo.status
         tvo.startTime=tslotVo.st
         tvo.isFinishedUpgrade=false
     end
     return true
end

function technologyVoApi:getAddPerById(tid)
    local tecVo = technologyVoApi:getTechVoByTId(tid)
    if tecVo==nil then
        do
         return 0
        end
    end
    if self.techValueCfg==nil then
        self.techValueCfg=Split(techCfg[tid].value,",")
    end
    local addPer= tonumber(self.techValueCfg[tecVo.level])
    if addPer==nil then
        addPer=0
    end
    return addPer
end

--检查取消升级 返回值 false:已经升级完成
function technologyVoApi:checkCancleUpgradeBeforeServer(tid)
    local tecVo = technologyVoApi:getTechVoByTId(tid)
    if tecVo.status==0 then
        local tsD=smallDialog:new()
        tsD:initSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("indexisfinish"),nil,4)
        do
            return false
        end
    end
    
    return true
end

--是否有10级或以上的科技，钢铁之心活动用
function technologyVoApi:getMaxLevel()
    local allInfo=self:getAllInfo()
    local maxLevel=0
    if allInfo then
        for k,v in pairs(allInfo) do
            if v and v.level then
                if maxLevel<v.level then
                    maxLevel=v.level
                end

            end
        end
    end
    return maxLevel
end

function technologyVoApi:isAllTechnologyMaxLv()
    local isAllMax=true
    for k,v in pairs(self.allTechTbs) do
        if v.level<tonumber(playerVoApi:getMaxLvByKey("techMaxLevel")) and v.level<techCfg[v.id].maxLevel then
            if techCfg[v.id].intervalLv and v.level*techCfg[v.id].intervalLv>=playerVoApi:getMaxLvByKey("techMaxLevel") then
            else
                isAllMax=false
            end
            break
        end
    end
    return isAllMax
end

--检测是不是有可以研究的科技
function technologyVoApi:hasTechCanStudy()
  local techBuildVo=buildingVoApi:getBuildingVoByBtype(8)[1]
  for k,v in pairs(self.allTechTbs) do
    if v.unlockIndex<=techBuildVo.level and v.level<playerVoApi:getMaxLvByKey("techMaxLevel") and v.level<techCfg[v.id].maxLevel and (techCfg[v.id].intervalLv==nil or v.level*techCfg[v.id].intervalLv<playerVoApi:getMaxLvByKey("techMaxLevel")) then
      if self:checkUpgradeRequire(v.id)==true then
        return true
      end
    end
  end
  return false
end

function technologyVoApi:clear()
    self.allTechTbs={}
    self.techValueCfg=nil
end
