expeditionAttackDialog=commonDialog:new()

function expeditionAttackDialog:new(parent,layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.myLayerTab1=nil
    
    self.playerTab2=nil
    self.myLayerTab2=nil

    self.playerTab3=nil
    self.myLayerTab3=nil
    self.parent=parent
    self.isCanTouch=true
    
    self.layerNum=layerNum
    
   self.addBtn=nil
    self.isShowTank=1
     
    return nc
end

--设置或修改每个Tab页签
function expeditionAttackDialog:resetTab()

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
function expeditionAttackDialog:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    --self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
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
    self.playerTab3=tankDialogTab3:new()
    self.myLayerTab3=self.playerTab3:init(self.layerNum)
    self.bgLayer:addChild(self.myLayerTab3);
    self.myLayerTab3:setPosition(ccp(999333,0))
    self.myLayerTab3:setVisible(false)
  

end
function expeditionAttackDialog:initTab1Layer()
    
    local tHeight = G_VisibleSize.height-260
    local function changeHandler(flag)
        self.isShowTank=flag+1
    end
    G_addSelectTankLayer(11,self.myLayerTab1,self.layerNum,changeHandler)

    local function forceDetails()
        if G_checkClickEnable()==false then
            do
                return
            end
        end

        if self.isCanTouch==false then
            do
                return
            end
        end

        require "luascript/script/game/scene/gamedialog/expedition/expeditionWarRecordDialog"
        local dialog=expeditionWarRecordDialog:new()
        local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("forceDetails"),true,self.layerNum+1)
        sceneGame:addChild(layer,self.layerNum+1)

    end
    local forceDetailsItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",forceDetails,nil,getlocal("forceDetails"),25)
    forceDetailsItem:setScale(0.8)
    local forceDetailsBtn=CCMenu:createWithItem(forceDetailsItem)
    forceDetailsBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    forceDetailsBtn:setAnchorPoint(ccp(1,0.5))
    forceDetailsBtn:setPosition(ccp(120-20,80))
    self.myLayerTab1:addChild(forceDetailsBtn)

    local function atk()
        local isEableAttack=true
        local num=0;
        for k,v in pairs(tankVoApi:getTanksTbByType(11)) do
            if SizeOfTable(v)==0 then
                num=num+1;
            end
        end
        if num==6 then
            isEableAttack=false
        end
        
        if isEableAttack==false then
           local function addFlicker()
                if self.addBtn then
                    G_addFlickerByTimes(self.addBtn,4.2,4.2,getCenterPoint(self.addBtn),3)
                end
           end
           smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("needFleet"),nil,9,nil,addFlicker)
           do
             return
           end
        end


        local function fight()

            if G_checkClickEnable()==false then
                do
                    return
                end
            end
            if self.isCanTouch==false then
                do
                    return
                end
            end
             
            local function callback(fn,data)
                local cresult,retTb=base:checkServerData(data)
                --self.isCanTouch=true
                if cresult==true then   
                    if retTb.data~=nil  and retTb.data.report~=nil then
                        local dateTb={}
                        dateTb.data=retTb.data
                        dateTb.isFuben=true
                        dateTb.battleType = 11 --远征军战斗类型
                        battleScene:initData(dateTb)
                        -- if expeditionVoApi:getWin() then
                        --     local message={key="expeditionAnnouncement",param={playerVoApi:getPlayerName()}}
                        --     chatVoApi:sendSystemMessage(message)
                        -- end
                        self:close()
                        self.parent:close()
                    end
                    tankVoApi:clearTanksTbByType(11)
                end

            end
            local atkTb=tankVoApi:getTanksTbByType(11)
            local hTb=nil
            if heroVoApi:isHaveTroops()  then
                hTb = heroVoApi:getMachiningHeroList(atkTb)
            end
            local aitroops=nil
            if AITroopsFleetVoApi:isHaveAITroops() then
                aitroops=AITroopsFleetVoApi:getMatchAITroopsList(atkTb)
            end
            local emblemID = emblemVoApi:getTmpEquip()
            local planePos = planeVoApi:getTmpEquip()
            local airShipId = airShipVoApi:getTempLineupId()
            self.isCanTouch=false
            socketHelper:expeditionBattle(atkTb,hTb,callback,emblemID,planePos,aitroops,airShipId)
        end

        if heroVoApi:isHaveTroops()==false and heroVoApi:isHaveCanFightHeroInExpedition() then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),fight,getlocal("dialog_title_prompt"),getlocal("expeditionunNoHero"),nil,self.layerNum+1)
        else
            fight()
        end

        

        
    end
    local atkItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",atk,nil,getlocal("attackGo"),25)
    atkItem:setScale(0.8)
    local atkBtn=CCMenu:createWithItem(atkItem)
    atkBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    atkBtn:setAnchorPoint(ccp(1,0.5))
    atkBtn:setPosition(ccp(520+20,80))
    self.myLayerTab1:addChild(atkBtn)
    

    local function readCallback(tank,hero)
    end
    local formationMenu=G_getFormationBtn(self.myLayerTab1,self.layerNum,self.isShowTank,11,readCallback,ccp(247,80),nil,0.8)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function expeditionAttackDialog:eventHandler(handler,fn,idx,cel)
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
function expeditionAttackDialog:tabClick(idx)
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
    --self:resetForbidLayer()
end
--用户处理特殊需求,没有可以不写此方法
function expeditionAttackDialog:doUserHandler()

end

--点击了cell或cell上某个按钮
function expeditionAttackDialog:cellClick(idx)
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


function expeditionAttackDialog:tick()
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

    if self.selectedTabIndex==1 then
        self.playerTab2:tick()
    elseif self.selectedTabIndex==2 then
        self.playerTab3:tick()
    end
    
end


function expeditionAttackDialog:clearVar()

    self.tv:reloadData()

end
function expeditionAttackDialog:refreshTab3()
    self.repairTank=tankVoApi:getRepairTanks()
    self.myLayerTab3:removeFromParentAndCleanup(true)
    self:initTab3Layer()
    self.myLayerTab3:setVisible(true)
    self.myLayerTab3:setPosition(ccp(0,0))
    self.tv:reloadData()

end



function expeditionAttackDialog:dispose()
    tankVoApi:clearTanksTbByType(11)
    heroVoApi:clearTroops()

    self.playerTab2:dispose()
    self.playerTab3:dispose()

    self=nil
end

function expeditionAttackDialog:againAssignmentTab()


end




