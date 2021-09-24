BossBattleDialogTab3={}

function BossBattleDialogTab3:new( ... )
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.parent=nil
    return nc
end

function BossBattleDialogTab3:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initTableView()
    return self.bgLayer
end

function BossBattleDialogTab3:initTableView()

     self.bossTanks=G_clone(tankVoApi:getTanksTbByType(12))
	 G_addSelectTankLayer(12,self.bgLayer,self.layerNum)

       local function save()
        local isEableAttack=true
        local num=0;
        for k,v in pairs(tankVoApi:getTanksTbByType(12)) do
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

        local tankTb = tankVoApi:getTanksTbByType(12)
        local hTb=nil
        if heroVoApi:isHaveTroops() then
            hTb = heroVoApi:getMachiningHeroList(tankTb)
        end
        local AITroopsTb = AITroopsFleetVoApi:getMatchAITroopsList(tankTb)
        local emblemID = emblemVoApi:getTmpEquip()
        local planePos = planeVoApi:getTmpEquip()
        local airShipId = airShipVoApi:getTempLineupId()
        local function callback(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret==true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("BossBattle_saveOk"),30)
                self.bossTanks=nil
                self.bossTanks={}
                self.bossTanks=G_clone(tankVoApi:getTanksTbByType(12))
                heroVoApi:setBossHeroList(hTb)
                AITroopsFleetVoApi:setBossAITroopsList(AITroopsTb)
                emblemVoApi:setBattleEquip(12,emblemID)
                planeVoApi:setBattleEquip(12,planePos)
                airShipVoApi:setBattleEquip(12, airShipId)
                if sData.data.worldboss then
                    BossBattleVoApi:onRefreshData(sData.data.worldboss)
                end
            end
        end
        local realEmblemId=emblemVoApi:getEquipIdForBattle(emblemID)
        if realEmblemId~=-1 then
            socketHelper:BossBattleSettroops(tankVoApi:getTanksTbByType(12),callback,hTb,BossBattleVoApi:getAttackSelf(),realEmblemId,planePos,AITroopsTb,true,airShipId)
        end
        

    end
    local savetem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",save,nil,getlocal("arena_save"),31)
    savetem:setScale(0.8)
    local saveMenu=CCMenu:createWithItem(savetem);
    saveMenu:setPosition(ccp(520,80))
    saveMenu:setTouchPriority((-(self.layerNum-1)*20-4));
    self.bgLayer:addChild(saveMenu)

end

function BossBattleDialogTab3:judgeFight()
    local bestTab2={}
    local allfight1=0
    local allfight2=0
    for k,v in pairs(self.bossTanks) do
        if SizeOfTable(v)>0 then
            local fight=tankVoApi:getBestTanksFighting(v[1],v[2])
            allfight1=allfight1+fight
        end
    end
    for k,v in pairs(tankVoApi:getTanksTbByType(12)) do
        if SizeOfTable(v)>0 then
            local fight=tankVoApi:getBestTanksFighting(v[1],v[2])
            allfight2=allfight2+fight
        end
    end
    local isLow = false

    if allfight1>allfight2 then
        local tankTb = tankVoApi:getTanksTbByType(12)
        local hTb=nil
            if heroVoApi:isHaveTroops() then
            hTb = heroVoApi:getMachiningHeroList(tankTb)
        end
        local AITroopsTb = AITroopsFleetVoApi:getMatchAITroopsList(tankTb)
        local function gosave()
            local emblemID = emblemVoApi:getTmpEquip()
            local planePos = planeVoApi:getTmpEquip()
            local airShipId = airShipVoApi:getTempLineupId()
            local function callback(fn,data)
                local ret,sData =base:checkServerData(data)
                if ret==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("BossBattle_saveOk"),30)
                    heroVoApi:setBossHeroList(hTb)
                    AITroopsFleetVoApi:setBossAITroopsList(AITroopsTb)
                    self.bossTanks=nil
                    self.bossTanks={}
                    self.bossTanks=G_clone(tankVoApi:getTanksTbByType(12))
                    heroVoApi:setBossHeroList(hTb)
                    emblemVoApi:setBattleEquip(12,emblemID)
                    planeVoApi:setBattleEquip(12,planePos)
                    airShipVoApi:setBattleEquip(12, airShipId)
                    if sData.data.worldboss then
                        BossBattleVoApi:onRefreshData(sData.data.worldboss)
                    end
                    
                end
            end
            socketHelper:BossBattleSettroops(tankVoApi:getTanksTbByType(12),callback,hTb,BossBattleVoApi:getAttackSelf(),emblemID,planePos,AITroopsTb,true,airShipId)
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),gosave,getlocal("dialog_title_prompt"),getlocal("arena_powerLow"),nil,self.layerNum+1)
        isLow = true

    end

    return isLow

end

function BossBattleDialogTab3:clearTouchSp()
    for i=1,6,1 do
        local spA=self.bgLayer:getChildByTag(i):getChildByTag(2)
        if spA~=nil then
            spA:removeFromParentAndCleanup(true)
        end
    end
    for k,v in pairs(tankVoApi:getTanksTbByType(12)) do
        local sp=self.bgLayer:getChildByTag(k)
        if v[1]~=nil and v[2]~=nil then
            G_addTouchSp(12,sp,v[1],v[2],self.layerNum,self.bgLayer,1)
        end
     end

end

function BossBattleDialogTab3:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self.bossTank=nil
    heroVoApi:clearTroops()
    AITroopsFleetVoApi:clearAITroops()
end


