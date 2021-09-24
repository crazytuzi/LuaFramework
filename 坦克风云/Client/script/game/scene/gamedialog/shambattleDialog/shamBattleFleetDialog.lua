shamBattleFleetDialog = commonDialog:new()

function shamBattleFleetDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function shamBattleFleetDialog:resetTab()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
end

function shamBattleFleetDialog:initTableView()
end

function shamBattleFleetDialog:doUserHandler()
	self:initTabLayer()
end


function shamBattleFleetDialog:initTabLayer()
    local tHeight = G_VisibleSize.height-200
    self.arenaTanks=G_clone(tankVoApi:getTanksTbByType(5))
    -- 
    G_addSelectTankLayer(5,self.bgLayer,self.layerNum,nil,nil,100)

    local function save()
        local isEableAttack=true
        local num=0;
        for k,v in pairs(tankVoApi:getTanksTbByType(5)) do
            if SizeOfTable(v)==0 then
                num=num+1;
            end
        end
        if num==6 then
            isEableAttack=false
        end
        if isEableAttack==false then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("arena_noTroops"),nil,self.layerNum+1,nil)
            do return end
        end

        if self:judgeFight() then
            do
                return
            end
        end
        local tankTb = tankVoApi:getTanksTbByType(5)
        local hTb=nil
        if heroVoApi:isHaveTroops() then
            hTb = heroVoApi:getMachiningHeroList(tankTb)
        end
        local AITroopsTb = AITroopsFleetVoApi:getMatchAITroopsList(tankTb)
        local emblemID = emblemVoApi:getTmpEquip()
        local planePos = planeVoApi:getTmpEquip()
        local airshipId = airShipVoApi:getTempLineupId()
        local function callback(fn,data)
            
            if base:checkServerData(data)==true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("arena_saveOk"),30)
                self.arenaTanks=nil
                self.arenaTanks={}
                self.arenaTanks=G_clone(tankVoApi:getTanksTbByType(5))
                heroVoApi:setArenaHeroList(hTb)
                AITroopsFleetVoApi:setArenaAITroopsList(AITroopsTb)
                emblemID=emblemVoApi:getEquipIdStr(emblemID)
                emblemVoApi:setBattleEquip(5,emblemID)
                planeVoApi:setBattleEquip(5,planePos)
                airShipVoApi:setBattleEquip(5,airshipId)
            end
        end
        local realEmblemId=emblemVoApi:getEquipIdForBattle(emblemID)
        if realEmblemId~=-1 then
            socketHelper:militarySettroops(tankVoApi:getTanksTbByType(5),callback,hTb,realEmblemId,planePos,AITroopsTb,airshipId)
        end
    end
    local savetem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnCancleSmall.png",save,nil,getlocal("arena_save"),25)
    local saveMenu=CCMenu:createWithItem(savetem);
    saveMenu:setPosition(ccp(520,80))
    saveMenu:setTouchPriority((-(self.layerNum-1)*20-4));
    self.bgLayer:addChild(saveMenu)

    local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function () do return end end)
    -- backSprie2:setContentSize(CCSizeMake(600,160))
    backSprie2:setContentSize(CCSizeMake(600,130))
    backSprie2:setAnchorPoint(ccp(0.5,0.5))
    backSprie2:setPosition(self.bgLayer:getContentSize().width/2,(self.bgLayer:getContentSize().height-535-30)/2)
    self.bgLayer:addChild(backSprie2)

    local descLb=GetTTFLabelWrap(getlocal("shamBattle_troops_des"),25,CCSizeMake(self.bgLayer:getContentSize().width-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb:setAnchorPoint(ccp(0.5,0.5))
    descLb:setPosition(ccp(backSprie2:getContentSize().width/2,backSprie2:getContentSize().height/2))
    descLb:setColor(G_ColorYellowPro)
    backSprie2:addChild(descLb,1)



    
end

function shamBattleFleetDialog:judgeFight()
    local bestTab2={}
    local allfight1=0
    local allfight2=0
    for k,v in pairs(self.arenaTanks) do
        if SizeOfTable(v)>0 then
            local fight=tankVoApi:getBestTanksFighting(v[1],v[2])
            allfight1=allfight1+fight
        end
    end
    for k,v in pairs(tankVoApi:getTanksTbByType(5)) do
        if SizeOfTable(v)>0 then
            local fight=tankVoApi:getBestTanksFighting(v[1],v[2])
            allfight2=allfight2+fight
        end
    end
    local isLow = false

    if allfight1>allfight2 then
        local tankTb = tankVoApi:getTanksTbByType(5)
        local hTb=nil
            if heroVoApi:isHaveTroops() then
            hTb = heroVoApi:getMachiningHeroList(tankTb)
        end
        local AITroopsTb = AITroopsFleetVoApi:getMatchAITroopsList(tankTb)

        local function gosave()
            local emblemID = emblemVoApi:getTmpEquip()
            local planePos = planeVoApi:getTmpEquip()
            local airshipId = airShipVoApi:getTempLineupId()
            local function callback(fn,data)
                if base:checkServerData(data)==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("arena_saveOk"),30)
                    heroVoApi:setArenaHeroList(hTb)
                    AITroopsFleetVoApi:setArenaAITroopsList(AITroopsTb)
                    emblemID=emblemVoApi:getEquipIdStr(emblemID)
                    emblemVoApi:setBattleEquip(5,emblemID)
                    planeVoApi:setBattleEquip(5,planePos)
                    airShipVoApi:setBattleEquip(5,airshipId)
                end
            end
            local realEmblemId=emblemVoApi:getEquipIdForBattle(emblemID)
            if realEmblemId~=-1 then
                socketHelper:militarySettroops(tankVoApi:getTanksTbByType(5),callback,hTb,realEmblemId,planePos,AITroopsTb,airshipId)
            end
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),gosave,getlocal("dialog_title_prompt"),getlocal("arena_powerLow"),nil,self.layerNum+1)
        isLow = true

    end

    return isLow

end
function shamBattleFleetDialog:clearTouchSp()
    for i=1,6,1 do
        local spA=self.bgLayer:getChildByTag(i):getChildByTag(2)
        if spA~=nil then
            spA:removeFromParentAndCleanup(true)
        end
    end
    for k,v in pairs(tankVoApi:getTanksTbByType(5)) do
        local sp=self.bgLayer:getChildByTag(k)
        if v[1]~=nil and v[2]~=nil then
            G_addTouchSp(5,sp,v[1],v[2],self.layerNum,self.bgLayer,1)
        end
     end

end


function shamBattleFleetDialog:tick()

end

function shamBattleFleetDialog:dispose()
    if(self and self.bgLayer)then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil;
        self.layerNum=nil;
        self.arenaTanks=nil
    end
    heroVoApi:clearTroops()
    airShipVoApi:setTempLineupId(nil)
end