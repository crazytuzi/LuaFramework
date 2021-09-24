tankStoryDialog=commonDialog:new()

function tankStoryDialog:new(storyId,fubenId,usePropTab,ecId,swId,robData,equipSid,callBack,isBossFu,params)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.bid=bid
    nc.leftBtn=nil
    nc.expandIdx={}
    nc.myLayerTab1=nil
    
    nc.playerTab2=nil
    nc.myLayerTab2=nil

    nc.playerTab3=nil
    nc.myLayerTab3=nil

    nc.storyId=storyId        --关卡
  nc.addBtn=nil

    nc.fubenId=fubenId        --军团副本
    nc.usePropTab=usePropTab  --军团副本是否使用道具

    nc.ecId=ecId              --配件补给线
    nc.isShowTank=1

    nc.swId=swId              --超级武器攻击神秘组织关卡
    nc.descLb=nil

    nc.robData=robData        --超级武器抢夺数据
    nc.equipSid=equipSid      --装备探索关卡id
    nc.callBack=callBack      --回调函数
    nc.levelTb = {}          -- 再打一次关卡保留的信息
    nc.isBossFu=isBossFu or false
    nc.params = params --该值最好定义为table类型，便于扩展
    return nc
end

--设置或修改每个Tab页签
function tankStoryDialog:resetTab()

    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==2 then
         tabBtnItem:setPosition(520,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

--设置对话框里的tableView
function tankStoryDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    --self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setTableViewTouchPriority(1)
    self.tv:setPosition(ccp(30000,30))
    --self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
    
    self.myLayerTab1=CCLayer:create();
    self.bgLayer:addChild(self.myLayerTab1)
    self:initTab1Layer();
    
    require "luascript/script/game/scene/gamedialog/warDialog/tankDialogTab2"
    self.playerTab2=tankDialogTab2:new()
    self.myLayerTab2=self.playerTab2:init(self,2,self.layerNum)
    self.bgLayer:addChild(self.myLayerTab2);
    self.myLayerTab2:setPosition(ccp(999333,0))
    self.myLayerTab2:setVisible(false)
    
    require "luascript/script/game/scene/gamedialog/warDialog/tankDialogTab3"
    self.playerTab3=tankDialogTab3:new(self.params and self.params.repairStr)
    self.myLayerTab3=self.playerTab3:init(self.layerNum)
    self.bgLayer:addChild(self.myLayerTab3);
    self.myLayerTab3:setPosition(ccp(999333,0))
    self.myLayerTab3:setVisible(false)

    local isShowTip=true
    local dataKey="lastChallengeFleet@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
    local localData=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
    if(localData~=nil and localData~="")then
        local fleetInfo=G_Json.decode(localData)
        local tankTb=fleetInfo.tank
        if tankTb and SizeOfTable(tankTb)>0 then
            for k,v in pairs(tankTb) do
                if v and v[1] and tankVoApi:getTankCountByItemId(v[1])>0 and v[2] and v[2]>0 then
                    isShowTip=false
                end
            end
        end
    end
    if isShowTip==true and playerVoApi:getPlayerLevel()<=15 and newGuidMgr:isNewGuiding()==false then
       local function showTip()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("needFleet"),28,getCenterPoint(sceneGame))
        end
       local delayTime = CCDelayTime:create(0.5);
       local fc= CCCallFunc:create(showTip)
       local acArr=CCArray:create()
       acArr:addObject(delayTime)
       acArr:addObject(fc)
       local seq=CCSequence:create(acArr)
       self.bgLayer:runAction(seq)
   end

   if (self.fubenId and tonumber(self.fubenId)>0) or (self.isBossFu and self.isBossFu==true)then
       G_AllianceDialogTb["tankStoryDialog"]=self
   end

end
function tankStoryDialog:initTab1Layer()
    local function changeHandler(flag)
        self.isShowTank=flag+1
    end
    local curTotalTroops = playerVoApi:getTotalTroops(3,false)
    local dataKey="lastChallengeFleet@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
    local localData=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
    if(localData~=nil and localData~="")then
        local fleetInfo=G_Json.decode(localData)
        local tankTb=fleetInfo.tank
        local heroTb=fleetInfo.hero
        local aitroops=fleetInfo.aitroops
        local emblemID=fleetInfo.emblemID
        local planePos=fleetInfo.planePos
        local airShipId=fleetInfo.airShipId
        if emblemID then
            curTotalTroops=curTotalTroops+emblemVoApi:getTroopsAddById(emblemID)
        end
        if tankTb and SizeOfTable(tankTb)>0 then
            local allTanks=G_clone(tankVoApi:getAllTanks())
            for k,v in pairs(tankTb) do
                local tankId=v[1]
                local hasNum=0
                if allTanks[tankId]~=nil then
                    hasNum=allTanks[tankId][1]
                    if hasNum>0 and v[2]>0 then
                        local num=v[2]
                        if hasNum<v[2] then
                            num=hasNum
                        end
                        if curTotalTroops and curTotalTroops<num then
                            num=curTotalTroops
                        end
                        tankVoApi:setTanksByType(3,k,tankId,num)
                        allTanks[tankId][1]=allTanks[tankId][1]-num
                    end
                end
            end
        end
        if heroTb and SizeOfTable(heroTb)>0 then
            heroVoApi:setTroopsByTb(heroTb)
        end
        if aitroops and SizeOfTable(aitroops)>0 then
            AITroopsFleetVoApi:setAITroopsTb(aitroops)
        end
        -- if emblemID then
            emblemVoApi:setBattleEquip(3,emblemID)
        -- end
        planeVoApi:setBattleEquip(3,planePos)
        
        airShipVoApi:setBattleEquip(3,airShipId)

        -- G_updateSelectTankLayer(3,self.myLayerTab1,self.layerNum,true,tankTb,heroTb)  
    end
    G_addSelectTankLayer(3,self.myLayerTab1,self.layerNum,changeHandler)
    
    local tHeight = G_VisibleSize.height-260

    
    
    local stid=1
    if self.storyId then
        --local defLbNum = GetTTFLabel(getlocal("showDefenceFleetText"),26);
        local str;
        stid=self.storyId-10000
        if stid<10 then
            str="sample_stage_00"..stid
        elseif stid>=10 and stid<100 then
            str="sample_stage_0"..stid
        elseif stid>=100 then
            str="sample_stage_"..stid
        end
        
        -- local defLbNum = GetTTFLabelWrap(getlocal(str),26,CCSize(500,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        -- defLbNum:setAnchorPoint(ccp(0,0.5));
        -- defLbNum:setPosition(ccp(80,tHeight-510));
        -- self.myLayerTab1:addChild(defLbNum,2);

        local tvHeight=G_VisibleSizeHeight-885
        if G_isIphone5()==true then
            tvHeight=G_VisibleSizeHeight-885-70
        end
        local tabelLb=G_LabelTableView(CCSizeMake(450+30,tvHeight),getlocal(str),24,kCCTextAlignmentLeft)
        tabelLb:setPosition(ccp(150-30,120))
        tabelLb:setAnchorPoint(ccp(0,0))
        tabelLb:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
        tabelLb:setMaxDisToBottomOrTop(80)
        self.myLayerTab1:addChild(tabelLb,2)
    end
    
    local function touchFight()
        PlayEffect(audioCfg.mouseClick)
        
        local energyIsEnough=true
        if (self.swId and self.swId>0) or (self.robData and SizeOfTable(self.robData)>0) then
        elseif self.fubenId and self.fubenId>0 then
        elseif self.isBossFu and self.isBossFu==true then
        elseif self.ecId and self.ecId>0 then
            if accessoryVoApi:energyIsEnough()==false then
                energyIsEnough=false
            end
        elseif self.params and self.params.eventType == "personalRebel" then --个人叛军
        elseif playerVoApi:getEnergy()==0 then
            energyIsEnough=false
        end
        if energyIsEnough==false then
            local function buyEnergy()
                    G_buyEnergy(self.layerNum+1)
            end
            -- smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyEnergy,getlocal("dialog_title_prompt"),getlocal("energyis0"),nil,self.layerNum+1)
            smallDialog:showEnergySupplementDialog(self.layerNum+1)
            do
                return
            end
        end
        

        local tab=tankVoApi:getTanksTbByType(3)
        local tankTb={}
        for kk=1,6 do
            if tab[kk]~=nil then
                tankTb[kk]=tab[kk] 
            else
                tankTb[kk]={}
            end
        end
        local fleetInfo={tank=tankTb}
        local hTb=nil
        if heroVoApi:isHaveTroops() then
            hTb = heroVoApi:getMachiningHeroList(tankTb)
            if hTb and SizeOfTable(hTb)>0 then
                fleetInfo={tank=tankTb,hero=hTb}
            end
        end
        local aitroops=nil
        if AITroopsFleetVoApi:isHaveAITroops() then
            aitroops=AITroopsFleetVoApi:getMatchAITroopsList(tankTb)
            fleetInfo.aitroops=aitroops
        end
        local emblemID=emblemVoApi:getTmpEquip()
        if emblemID and emblemID~=0 then
            fleetInfo.emblemID=emblemID
        end
        local planePos=planeVoApi:getTmpEquip()
        if planePos and planePos~=0 then
            fleetInfo.planePos=planePos
        end
        local airShipId=airShipVoApi:getTempLineupId()
        if airShipId then
            fleetInfo.airShipId=airShipId
        end
        local function serverResponse(fn,data)
            local cresult,retTb=base:checkServerData(data)
            if cresult==true then
                    if newGuidMgr:isNewGuiding()==true then
                        newGuidMgr:toNextStep()
                    end
                    -- self.levelTb
                    retTb.levelTb=self.levelTb
                    battleScene:initData(retTb)
                    local dataKey="lastChallengeFleet@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                    CCUserDefault:sharedUserDefault():setStringForKey(dataKey,G_Json.encode(fleetInfo))
                    CCUserDefault:sharedUserDefault():flush()
                    self:close(false)
            end
        end

        local function achallengeBattleCallback(fn,data)
            local cresult,retTb=base:checkServerData(data)
            if cresult==true then
                retTb.isFuben=true
                battleScene:initData(retTb)
                local dataKey="lastChallengeFleet@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                CCUserDefault:sharedUserDefault():setStringForKey(dataKey,G_Json.encode(fleetInfo))
                CCUserDefault:sharedUserDefault():flush()
                if self.usePropTab and SizeOfTable(self.usePropTab)>0 then
                    for k,v in pairs(self.usePropTab) do
                        local pid=tonumber(k) or tonumber(RemoveFirstChar(k))
                        bagVoApi:useItemNumId(pid,tonumber(v))
                    end
                end

                local isAddAexp=true
                if retTb.data.alliData then
                    if retTb.data.alliData.alliance then
                        isAddAexp=false
                        local aData=retTb.data.alliData.alliance
                        local selfAlliance=allianceVoApi:getSelfAlliance()
                        if selfAlliance then
                          local aid=selfAlliance.aid
                          local uid=playerVoApi:getUid()
                          
                          allianceVoApi:apointRefreshData(2,aData)

                          if aData.level and aData.level_point then
                              allianceVoApi:setAllianceLevel(tonumber(aData.level))
                              allianceVoApi:setAllianceExp(tonumber(aData.level_point))

                              local params={uid,nil,nil,0,tonumber(aData.level),tonumber(aData.level_point),-1}
                              chatVoApi:sendUpdateMessage(9,params,aid+1)
                          end

                          if aData.skills then
                              for k,v in pairs(aData.skills) do
                                  if v and tonumber(v[1]) and tonumber(v[2]) then
                                      local skillId=tonumber(k) or tonumber(RemoveFirstChar(k))
                                      allianceSkillVoApi:setSkillLevel(skillId,tonumber(v[1]))
                                      allianceSkillVoApi:setSkillExp(skillId,tonumber(v[2]))
                                      
                                      local params={uid,nil,nil,skillId,tonumber(v[1]),tonumber(v[2]),-1}
                                      chatVoApi:sendUpdateMessage(9,params,aid+1)
                                  end
                              end
                          end

                        end
                    end
                end

                if retTb.data.report.r then
                    local awardTab=FormatItem(retTb.data.report.r)
                    if awardTab and SizeOfTable(awardTab)>0 then
                        for k,v in pairs(awardTab) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,isAddAexp)
                        end
                    end
                end
            
                if retTb.data.report.w then
                    if self.fubenId and self.fubenId>0 and tonumber(retTb.data.report.w)==1 then
                        allianceFubenVoApi:setKillCount(self.fubenId)

                        local isNotice=false
                        local fubenVo=allianceFubenVoApi:getFuben()
                        local oldUnlockId=1
                        if fubenVo and fubenVo.unlockId and fubenVo.unlockId>0 then
                            oldUnlockId=fubenVo.unlockId-1
                        end
                        allianceFubenVoApi:getMaxFubenNum()
                        if tonumber(oldUnlockId)==tonumber(self.fubenId) or tonumber(self.fubenId)==allianceFubenVoApi:getMaxFubenNum() then
                            isNotice=true
                        end

                        local chapterCfg=allianceFubenVoApi:getChapterCfg()
                        local sectionCfg=allianceFubenVoApi:getSectionCfg()
                        local chapter          
                        for k,v in pairs(chapterCfg) do
                            if self.fubenId==k*v.maxNum then
                                chapter=tonumber(k)
                                if k==4 then
                                    isNotice=true
                                end
                            end
                        end
                        -- if isNotice==true and chapter and sectionCfg[self.fubenId] then
                        --     local chapterName=sectionCfg[self.fubenId].name
                        --     local selfAlliance=allianceVoApi:getSelfAlliance()
                        --     if selfAlliance and selfAlliance.name then
                        --         local paramTab={}
                        --         paramTab.functionStr="juntuan"
                        --         paramTab.addStr="go_attack"
                        --         local nameData={key=chapterName,param={}}
                        --         local chatData={selfAlliance.name,playerVoApi:getPlayerName(),chapter,nameData}
                        --         -- chatVoApi:sendSystemMessage(getlocal("chatSystemMessage7",chatData))
                        --         local message={key="chatSystemMessage7",param=chatData}
                        --         chatVoApi:sendSystemMessage(message,paramTab)
                        --     end
                        -- end

                    end
                end
                allianceFubenVoApi:setAttackCount()
                allianceFubenVoApi:setAllFlag()

                self:close(false)
            else
                if retTb.ret==-8040 then
                    local function achallengeGetCallback(fn1,data1)
                        local ret1,sData1=base:checkServerData(data1)
                        if ret1==true then

                            if self and self.bgLayer then
                                local function callbackFunc()
                                    local chapterCfg=allianceFubenVoApi:getChapterCfg()
                                    local minsid
                                    local maxsid   
                                    for k,v in pairs(chapterCfg) do
                                        if self.fubenId>(k-1)*v.maxNum and self.fubenId<=k*v.maxNum then
                                            minsid=(k-1)*v.maxNum+1
                                            maxsid=k*v.maxNum
                                        end
                                    end
                                    if minsid and maxsid then
                                        local function achallengeListCallback(fn,data)
                                            local ret,sData=base:checkServerData(data)
                                            if ret==true then
                                                allianceFubenVoApi:setAllFlag()
                                                self:close(false)
                                            end
                                        end
                                        socketHelper:achallengeList(minsid,maxsid,achallengeListCallback)
                                    end
                                end

                                local delay=CCDelayTime:create(0.5)
                                local callFunc=CCCallFuncN:create(callbackFunc)
                                local acArr=CCArray:create()
                                acArr:addObject(delay)
                                acArr:addObject(callFunc)
                                local seq=CCSequence:create(acArr)
                                self.bgLayer:runAction(seq)
                            end

                        end
                    end
                    socketHelper:achallengeGet(achallengeGetCallback)

                    
                end
            end
        end
        --军团副本中攻打boss副本处理
        local function allianceBossBattleCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                local dataKey="lastChallengeFleet@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                CCUserDefault:sharedUserDefault():setStringForKey(dataKey,G_Json.encode(fleetInfo))
                CCUserDefault:sharedUserDefault():flush()
                local destoryPaotou={}
                if sData.data and sData.data.allianceboss then
                    local oldHp=sData.data.allianceboss[5]
                    local bossHp=sData.data.allianceboss[2]-sData.data.allianceboss[3]
                    destoryPaotou=allianceFubenVoApi:getDestoryPaotouByHP(bossHp,oldHp)
                    local params={}
                    local selfAlliance=allianceVoApi:getSelfAlliance()
                    if selfAlliance then
                        local aid=selfAlliance.aid
                        local uid=playerVoApi:getUid()
                        params.uid=uid
                        if sData.data.allianceboss[3] then
                            params.damage=sData.data.allianceboss[3]
                        end
                        if sData.data.allianceboss[4] then
                            params.lastKillTime=sData.data.allianceboss[4]
                        end
                        params.isKill=0
                        if destoryPaotou and type(destoryPaotou)=="table" and SizeOfTable(destoryPaotou)>0 then
                            local isKill=false
                            local paotouCfg=allianceFubenVoApi:getTankPaotouCfg()
                            for k,v in pairs(destoryPaotou) do
                                if tonumber(paotouCfg[v])==6 then
                                    isKill=true
                                end
                            end
                            if isKill==true then
                                allianceFubenVoApi:setAllianceBossKilCount()
                                params.isKill=1
                                allianceFubenVoApi:setAllFlag()
                            end
                        end
                        chatVoApi:sendUpdateMessage(39,params,aid+1)
                    end      
                end
                local isAddAexp=true
                if sData.data.alliData then
                    if sData.data.alliData.alliance then
                        isAddAexp=false
                        local aData=sData.data.alliData.alliance
                        local selfAlliance=allianceVoApi:getSelfAlliance()
                        if selfAlliance then
                            local aid=selfAlliance.aid
                            local uid=playerVoApi:getUid()
                          
                            allianceVoApi:apointRefreshData(2,aData)

                            if aData.level and aData.level_point then
                                allianceVoApi:setAllianceLevel(tonumber(aData.level))
                                allianceVoApi:setAllianceExp(tonumber(aData.level_point))

                                local params={uid,nil,nil,0,tonumber(aData.level),tonumber(aData.level_point),-1}
                                chatVoApi:sendUpdateMessage(9,params,aid+1)
                            end

                            if aData.skills then
                                for k,v in pairs(aData.skills) do
                                    if v and tonumber(v[1]) and tonumber(v[2]) then
                                        local skillId=tonumber(k) or tonumber(RemoveFirstChar(k))
                                        allianceSkillVoApi:setSkillLevel(skillId,tonumber(v[1]))
                                        allianceSkillVoApi:setSkillExp(skillId,tonumber(v[2]))
                                      
                                        local params={uid,nil,nil,skillId,tonumber(v[1]),tonumber(v[2]),-1}
                                        chatVoApi:sendUpdateMessage(9,params,aid+1)
                                    end
                                end
                            end
                        end
                    end
                end

                --初始化战报数据
                if sData.data.report then
                    if sData.data.report.w and sData.data.report.w==1 then
                        if isAddAexp==true then
                            local selfAlliance=allianceVoApi:getSelfAlliance()
                            local rewards,addexp=allianceFubenVoApi:getBossFubenRewards()
                            local curExp=tonumber(selfAlliance.exp)+tonumber(addexp)
                            allianceVoApi:setAllianceExp(curExp) --添加军团经验
                        end
                        sData.data.report.star=3 --前台写死的胜利星级
                    end
                    require "luascript/script/game/scene/gamedialog/Boss/BossBattleScene"
                    local attackData={data=sData.data,isAttacker=true,isReport=false,destoryPaotou=destoryPaotou}
                    BossBattleScene:initData(attackData,3)
                    --添加副本boss进攻奖励
                    if sData.data.report.r then
                        local awardTab=FormatItem(sData.data.report.r)
                        if awardTab and SizeOfTable(awardTab)>0 then
                            for k,v in pairs(awardTab) do
                                G_addPlayerAward(v.type,v.key,v.id,v.num,isAddAexp)
                            end
                        end
                    end       
                end
                allianceFubenVoApi:setAttackCount()
                self:close()
            end
        end
        local function ecBattleCallback(fn,data)
            local cresult,retTb=base:checkServerData(data)
            if cresult==true then

                retTb.isFuben=true
                battleScene:initData(retTb)
                local dataKey="lastChallengeFleet@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                CCUserDefault:sharedUserDefault():setStringForKey(dataKey,G_Json.encode(fleetInfo))
                CCUserDefault:sharedUserDefault():flush()

                local usedResetNum=accessoryVoApi:getUsedResetNum()
                if usedResetNum==0 then
                    playerVoApi:setValue("energy",playerVoApi:getEnergy()-1)
                end

                local updateData={}
                if retTb.data and retTb.data.report then
                    if retTb.data.report.star then
                        local star=tonumber(retTb.data.report.star)
                        if star>0 then
                            accessoryVoApi:attackUpdate(self.ecId,star)
                        end
                    end
                    if retTb.data.report.r then
                        local awardTab=FormatItem(retTb.data.report.r)
                        if awardTab and SizeOfTable(awardTab)>0 then
                            for k,v in pairs(awardTab) do
                                G_addPlayerAward(v.type,v.key,v.id,v.num)
                            end
                        end
                    end
                end

                --添加配件和碎片、原材料
                if retTb.data and retTb.data.echallengebattle and retTb.data.echallengebattle.reward then
                    local accessory=retTb.data.echallengebattle.reward
                    accessoryVoApi:addNewData(accessory)
                end
                
                accessoryVoApi:setFlag(0)
                self:close(false)
            end
        end

        local function swBattleCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data and sData.data.swchallenge then
                    superWeaponVoApi:setSWChallenge(sData.data.swchallenge)
                end
                if(sData.data and sData.data.weapon)then
                    superWeaponVoApi:formatData(sData.data.weapon)
                end
                if(sData.data.weaponroblog)then
                    local weaponroblog=sData.data.weaponroblog
                    if weaponroblog.maxrows then
                        superWeaponVoApi:setTotalNum(tonumber(weaponroblog.maxrows) or 0)
                    end
                    if weaponroblog.unread then
                        superWeaponVoApi:setUnreadNum(tonumber(weaponroblog.unread) or 0)
                    end
                end
                if sData.data and sData.data.accessory then
                    accessoryVoApi:addNewData(sData.data.accessory)
                end
                if sData.data and sData.data.report then
                    sData.battleType=2
                    sData.swId=self.swId
                    battleScene:initData(sData)
                    local dataKey="lastChallengeFleet@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                    CCUserDefault:sharedUserDefault():setStringForKey(dataKey,G_Json.encode(fleetInfo))
                    CCUserDefault:sharedUserDefault():flush()
                end
                self:close(false)
            end
        end

        local function equipBattleCallback(fn,data)
            local cresult,sData=base:checkServerData(data)
            if cresult==true then
                
                
                -- local usedResetNum=heroEquipChallengeVoApi:getUseEnergyNum()
                -- if usedResetNum==0 then
                --     playerVoApi:setValue("energy",playerVoApi:getEnergy()-1)
                -- end
                if sData and sData.data and sData.data.hchallenge then
                    heroEquipChallengeVoApi:formatData(sData.data.hchallenge)
                end
                if sData and sData.data and sData.data.equip then
                    heroEquipVoApi:formatData(sData.data.equip)
                end
                if sData.data and sData.data.report then
                    sData.battleType=8
                    sData.ecId=self.equipSid
                    battleScene:initData(sData,self.callBack)
                end
                local dataKey="lastChallengeFleet@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                CCUserDefault:sharedUserDefault():setStringForKey(dataKey,G_Json.encode(fleetInfo))
                CCUserDefault:sharedUserDefault():flush()
                self:close(false)
            end
            heroEquipChallengeVoApi:setIfNeedSendECRequest(true)
        end

        local isEableAttack=true
        local num=0;
        for k,v in pairs(tab) do
            if SizeOfTable(v)==0 then
                num=num+1;
            end
        end
        if num==6 then
            isEableAttack=false
        end

        if isEableAttack==false then
            local function addFlicker()
                --G_addFlickerByTimes(self.addBtn,4.2,4.2,getCenterPoint(self.addBtn),3)
            end
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("needFleet"),nil,self.layerNum+1,nil,addFlicker)

        else--向服务器发送请求
             local retTb={}
             for kk=1,6 do
                   if tab[kk]~=nil then
                       retTb[kk]=tab[kk] 
                   else
                       retTb[kk]={}
                   end
             end

             local t1={}
             local hTb=nil
             if heroVoApi:isHaveTroops() then
                hTb = heroVoApi:getMachiningHeroList(retTb)
             end
             local aitroops=nil
             if AITroopsFleetVoApi:isHaveAITroops() then
                aitroops=AITroopsFleetVoApi:getMatchAITroopsList(retTb)
             end
                
             if self.robData and SizeOfTable(self.robData)>0 then
                local emblemID=emblemVoApi:getTmpEquip()
                local planePos=planeVoApi:getTmpEquip()
                local airShipId = airShipVoApi:getTempLineupId()
                local function weaponBattleCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData.data.weapon then
                            superWeaponVoApi:formatData(sData.data.weapon)
                            superWeaponVoApi:setFragmentFlag(0)
                        end
                        if sData.data and sData.data.flop then
                            local award=FormatItem(sData.data.flop) or {}
                            for k,v in pairs(award) do
                                G_addPlayerAward(v.type,v.key,v.id,v.num)
                            end
                        end
                        if sData.data and sData.data.accessory then
                            accessoryVoApi:onRefreshData(sData.data.accessory)
                        end
                        if sData.data and sData.data.report then
                            sData.battleType=3
                            local planePos=planeVoApi:getTmpEquip()
                            sData.callBackParams={target=self.robData.target,fid=self.robData.fid,fleetinfo=retTb,hero=hTb,aitroops=aitroops,equip=emblemID,plane=planePos,ap = airShipId}
                            local signData = {addount = sData.data.addount}
                            sData.robData={targetData=self.robData.targetData, signData = signData}
                            battleScene:initData(sData)
                            local dataKey="lastChallengeFleet@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                            CCUserDefault:sharedUserDefault():setStringForKey(dataKey,G_Json.encode(fleetInfo))
                            CCUserDefault:sharedUserDefault():flush()
                        end
                        self:close(false)
                    end
                end
                t1={target=self.robData.target,fid=self.robData.fid,fleetinfo=retTb,hero=hTb,at=aitroops,equip=emblemID,plane=planePos,ap = airShipId}
                socketHelper:weaponBattle(t1,weaponBattleCallback)
             elseif self.swId and self.swId>0 then
                local cVo=superWeaponVoApi:getSWChallenge()
                local buyCNum=cVo.buyCNum
                local leftChallengeNum=swChallengeCfg.challengeNum+buyCNum-cVo.hasCNum
                if leftChallengeNum<=0 then
                    local buyMaxNum=superWeaponVoApi:getBuyMaxNum()
                    if buyCNum>=buyMaxNum then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_challenge_no_buy_times_desc"),30)
                        do return end
                    end
                    local costGems=swChallengeCfg.challengeNumGems[buyCNum+1]
                    local function onConfirm()
                        if(costGems>playerVoApi:getGems())then
                            GemsNotEnoughDialog(nil,nil,costGems - playerVoApi:getGems(),self.layerNum+1,costGems)
                            do return end
                        end
                        local emblemID=emblemVoApi:getTmpEquip()
                        local planePos=planeVoApi:getTmpEquip()
                        local airShipId = airShipVoApi:getTempLineupId()
                        t1={target=self.swId,buy=true,fleetinfo=retTb,hero=hTb,at=aitroops,equip=emblemID,plane=planePos,ap=airShipId}
                        socketHelper:weaponSWChallenge(t1,swBattleCallback)
                    end
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("super_weapon_challenge_buy_desc",{costGems}),nil,self.layerNum+1)
                else
                    local emblemID=emblemVoApi:getTmpEquip()
                    local planePos=planeVoApi:getTmpEquip()
                    local airShipId = airShipVoApi:getTempLineupId()
                    t1={target=self.swId,buy=false,fleetinfo=retTb,hero=hTb,at=aitroops,equip=emblemID,plane=planePos,ap=airShipId}
                    socketHelper:weaponSWChallenge(t1,swBattleCallback)
                end
             elseif self.ecId and self.ecId>0 then
                local emblemID=emblemVoApi:getTmpEquip()
                local planePos=planeVoApi:getTmpEquip()
                local airShipId = airShipVoApi:getTempLineupId()
                t1={defender="s"..self.ecId,fleetinfo=retTb,hero=hTb,at=aitroops,equip=emblemID,plane=planePos,ap = airShipId}
                socketHelper:echallengeBattle(t1,ecBattleCallback)
             elseif self.fubenId and self.fubenId>0 then
                local emblemID=emblemVoApi:getTmpEquip()
                local planePos=planeVoApi:getTmpEquip()
                local airShipId = airShipVoApi:getTempLineupId()
                t1={defender=self.fubenId,fleetinfo=retTb,hero=hTb,at=aitroops,equip=emblemID,plane=planePos,ap = airShipId}
                if self.usePropTab and SizeOfTable(self.usePropTab)>0 then
                    t1.use=self.usePropTab
                end
                socketHelper:achallengeBattle(t1,achallengeBattleCallback)
             elseif self.isBossFu==true then
                local emblemID=emblemVoApi:getTmpEquip()
                local planePos=planeVoApi:getTmpEquip()
                local airShipId = airShipVoApi:getTempLineupId()
                t1={defender=1,fleetinfo=retTb,hero=hTb,at=aitroops,equip=emblemID,plane=planePos,ap = airShipId}
                socketHelper:allianceBossAttack(t1,allianceBossBattleCallback)
             elseif self.equipSid and self.equipSid>0 then
                local emblemID=emblemVoApi:getTmpEquip()
                local planePos=planeVoApi:getTmpEquip()
                local airShipId = airShipVoApi:getTempLineupId()
                t1={sid=self.equipSid,fleetinfo=retTb,hero=hTb,at=aitroops,equip=emblemID,plane=planePos,ap = airShipId}
                socketHelper:equipbattle(t1,equipBattleCallback)
            elseif self.params and self.params.eventType == "personalRebel" then --个人叛军
                local emblemID=emblemVoApi:getTmpEquip()
                local planePos=planeVoApi:getTmpEquip()
                local airShipId = airShipVoApi:getTempLineupId()
                rebelVoApi:pr_requestBattle(function(sData)
                    sData.personalRebelData = self.params
                    battleScene:initData(sData, nil, nil, self.layerNum)
                    local dataKey="lastChallengeFleet@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
                    CCUserDefault:sharedUserDefault():setStringForKey(dataKey,G_Json.encode(fleetInfo))
                    CCUserDefault:sharedUserDefault():flush()
                    self:close(false)
                end, self.params.position, retTb, hTb, emblemID, planePos, aitroops, airShipId)
             else
                local emblemID=emblemVoApi:getTmpEquip()
                local planePos=planeVoApi:getTmpEquip()
                local airShipId = airShipVoApi:getTempLineupId()
                t1={defender=stid,fleetinfo=retTb,hero=hTb,at=aitroops,equip=emblemID,plane=planePos,ap=airShipId}
                if newGuidMgr:isNewGuiding()==true then
                    t1.isTutorial=1
                end
                self.levelTb={}
                self.levelTb=t1
                socketHelper:startBattleForNPC(t1,serverResponse)
             end
        end
    
    end
    
    local fightItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touchFight,nil,getlocal("attackGo"),25,101)
    -- fightItem:setScale(0.8)
    -- local lb = fightItem:getChildByTag(101)
    -- if lb then
    --     lb = tolua.cast(lb,"CCLabelTTF")
    --     lb:setFontName("Helvetica-bold")
    -- end
    local fightMenu=CCMenu:createWithItem(fightItem);
    fightMenu:setPosition(ccp(520,80))
    fightMenu:setTouchPriority((-(self.layerNum-1)*20-6));
    self.myLayerTab1:addChild(fightMenu)

    newGuidMgr:setGuideStepField(14,fightItem,true)
    

    if self.fubenId==nil and self.ecId==nil and self.storyId then
        local function showInfo()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            
            local detailData=checkPointVoApi:getChapterDetail(self.storyId)
            if detailData==nil then
                local function challengeInfoHandler(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData and sData.data and sData.data.challengeInfo then
                            checkPointVoApi:formatChapterDetail(self.storyId,sData.data.challengeInfo)
                            smallDialog:showCheckPointDetailDialog("PanelHeaderPopup.png",CCSizeMake(550,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,getlocal("check_point_detail"),self.storyId)
                        end
                    end
                end
                local cid=tonumber(self.storyId)-10000
                socketHelper:challengeInfo(cid,challengeInfoHandler)
            else
                smallDialog:showCheckPointDetailDialog("PanelHeaderPopup.png",CCSizeMake(550,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,getlocal("check_point_detail"),self.storyId)
            end
        end

        local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
        infoItem:setScale(0.8)
        infoItem:setAnchorPoint(ccp(0.5,0.5))
        local infoBtn = CCMenu:createWithItem(infoItem)
        -- infoBtn:setPosition(ccp(100,tHeight-530))
        local py=115+(G_VisibleSize.height-850-25)/2
        if G_isIphone5()==true then
            py=80+(G_VisibleSize.height-850-25)/2
        end
        infoBtn:setPosition(ccp(100-30,py))
        infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        self.myLayerTab1:addChild(infoBtn,3)


        -- local dataKey="lastChallengeFleet@"..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID)
        -- local localData=CCUserDefault:sharedUserDefault():getStringForKey(dataKey)
        -- if(localData~=nil and localData~="")then
        --     local fleetInfo=G_Json.decode(localData)
        --     local tankTb=fleetInfo.tank
        --     local heroTb=fleetInfo.hero
        --     if tankTb and SizeOfTable(tankTb)>0 then
        --         for k,v in pairs(tankTb) do
        --             tankVoApi:setTanksByType(3,k,v[1],v[2])
        --         end
        --     end
        --     if heroTb and SizeOfTable(heroTb)>0 then
        --         heroVoApi:setTroopsByTb(heroTb)
        --     end
        --     G_updateSelectTankLayer(3,self.myLayerTab1,self.layerNum,true,tankTb,heroTb)  
        -- end
    end
    
    -- if self.storyId or self.fubenId or self.ecId then
        local tType=3
        local function readCallback(tank,hero)
        end
        local formationMenu=G_getFormationBtn(self.myLayerTab1,self.layerNum,self.isShowTank,tType,readCallback)
    -- end

    if self.swId then
        local scheduleStr=getlocal("super_weapon_challenge_clearance_condition")..superWeaponVoApi:getClearConditionStr(self.swId)
        if G_isIphone5()==true then
            self.lbTv,self.descLb=G_LabelTableView(CCSizeMake(550+10,G_VisibleSizeHeight-885-70),scheduleStr,25,kCCTextAlignmentLeft)
        else
            self.lbTv,self.descLb=G_LabelTableView(CCSizeMake(550+10,G_VisibleSizeHeight-885),scheduleStr,25,kCCTextAlignmentLeft)
        end
        self.lbTv:setPosition(ccp(50-10,120))
        self.lbTv:setAnchorPoint(ccp(0,0))
        self.lbTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
        self.lbTv:setMaxDisToBottomOrTop(80+100)
        self.myLayerTab1:addChild(self.lbTv,2)
        if superWeaponCfg and swChallengeCfg.list and swChallengeCfg.list[self.swId] then
            local cfg=swChallengeCfg.list[self.swId]
            if cfg and cfg.condition and cfg.condition.myUseType and type(cfg.condition.myUseType)=="table" then
                for k,v in pairs(cfg.condition.myUseType) do
                    if v and v[1] and v[2] then
                        local needNum=0
                        needNum=needNum+tonumber(v[2])
                        local sStr=getlocal("super_weapon_challenge_troops_schedule",{0,needNum})
                        self.descLb:setString(scheduleStr..sStr)
                    end
                end
            end
        end
    end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function tankStoryDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
           return 1

   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
        tmpSize=CCSizeMake(600,200)
       return  tmpSize
   elseif fn=="tableCellAtIndex" then
            
        local cell=CCTableViewCell:new()
        cell:autorelease()
        return cell
       
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

--点击tab页签 idx:索引
function tankStoryDialog:tabClick(idx)
        PlayEffect(audioCfg.mouseClick)
        for k,v in pairs(self.allTabs) do
             if v:getTag()==idx then
                v:setEnabled(false)
                self.selectedTabIndex=idx

                self:doUserHandler()
                
                
             else
                v:setEnabled(true)
             end

        end
        if self.selectedTabIndex==0 then
            self.myLayerTab1:setVisible(true)
            self.myLayerTab1:setPosition(ccp(0,0))
            
            self.myLayerTab2:setVisible(false)
            self.myLayerTab2:setPosition(ccp(99999,0))

            self.myLayerTab3:setVisible(false)
            self.myLayerTab3:setPosition(ccp(99999,0))

        elseif self.selectedTabIndex==1 then
            self.myLayerTab1:setVisible(false)
            self.myLayerTab1:setPosition(ccp(10000,0))
            
            self.myLayerTab2:setVisible(true)
            self.myLayerTab2:setPosition(ccp(0,0))

            self.myLayerTab3:setVisible(false)
            self.myLayerTab3:setPosition(ccp(99999,0))


        elseif self.selectedTabIndex==2 then
            self.myLayerTab1:setVisible(false)
            self.myLayerTab1:setPosition(ccp(10000,0))
            
            self.myLayerTab2:setVisible(false)
            self.myLayerTab2:setPosition(ccp(99999,0))

            self.myLayerTab3:setVisible(true)
            self.myLayerTab3:setPosition(ccp(0,0))
        
        end

    self:againAssignmentTab()
--    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function tankStoryDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function tankStoryDialog:cellClick(idx)
    if self.selectedTabIndex==2 then
        return
    end
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
        else
            --self.requires[idx-1000+1]:dispose()
            --self.requires[idx-1000+1]=nil
            --self.allCellsBtn[idx-1000+1]=nil
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end

function tankStoryDialog:refreshTab3()
    self.repairTank=tankVoApi:getRepairTanks()
    self.myLayerTab3:removeFromParentAndCleanup(true)
    self:initTab3Layer()
    self.myLayerTab3:setVisible(true)
    self.myLayerTab3:setPosition(ccp(0,0))
    self.tv:reloadData()

end
function tankStoryDialog:tick()
    local allSlots=SizeOfTable(attackTankSoltVoApi:getAllAttackTankSlots())
    if allSlots>0 then
        self:setTipsVisibleByIdx(true,2,allSlots)
    else
        self:setTipsVisibleByIdx(false,2)
    end
    local repairTanks=SizeOfTable(tankVoApi:getRepairTanks())
    if repairTanks>0 then
        self:setTipsVisibleByIdx(true,3,repairTanks)
    else
        self:setTipsVisibleByIdx(false,3)
    end
    if self.selectedTabIndex==0 then
        if self.swId and self.descLb then
            local scheduleStr=getlocal("super_weapon_challenge_clearance_condition")..superWeaponVoApi:getClearConditionStr(self.swId)
            if superWeaponCfg and swChallengeCfg.list and swChallengeCfg.list[self.swId] then
                local cfg=swChallengeCfg.list[self.swId]
                if cfg and cfg.condition and cfg.condition.myUseType and type(cfg.condition.myUseType)=="table" then
                    for k,v in pairs(cfg.condition.myUseType) do
                        if v and v[1] and v[2] then
                            local tanksTb=tankVoApi:getTanksTbByType(3)
                            local needType=tonumber(v[1])
                            local needNum=tonumber(v[2])
                            local num=0
                            for m,n in pairs(tanksTb) do
                                if n and n[1] and tankCfg[n[1]] then
                                    local tankType=tonumber(tankCfg[n[1]].type)
                                    if tankType==needType then
                                        num=num+1
                                    end
                                end
                            end
                            local sStr=""
                            if num>=needNum then
                                sStr=getlocal("super_weapon_challenge_troops_reach")
                            else
                                sStr=getlocal("super_weapon_challenge_troops_schedule",{num,needNum})
                            end
                            self.descLb:setString(scheduleStr..sStr)
                        end
                    end
                end
            end
        end
    elseif self.selectedTabIndex==1 then
        self.playerTab2:tick()
    elseif self.selectedTabIndex==2 then
        self.playerTab3:tick()
    end
end


function tankStoryDialog:clearVar()

    self.tv:reloadData()

end

function tankStoryDialog:dispose()
    self.isShowTank=1
    G_AllianceDialogTb["tankStoryDialog"]=nil
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()

    self.fubenId=nil
    self.propTab=nil
    tankVoApi:clearTanksTbByType(3)
    self.swId=nil
    self.descLb=nil
    self.robData=nil
    self.levelTb = {} 
    self.playerTab2:dispose()
    self.playerTab3:dispose()

    self=nil
end

function tankStoryDialog:againAssignmentTab()


end




