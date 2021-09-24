oneWarEventDialog=smallDialog:new()

function oneWarEventDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

	self.dialogHeight=400
    self.dialogWidth=550

    -- tabelview对象
    self.refreshData.tableView=nil;
    -- -- 刷新敌军来袭
    -- self.refreshData.enemyTab={}
    -- -- 刷新协防
    -- self.refreshData.helpTab={}

    --敌军来袭相关tabel
    -- self.enemyComingTab={}
    -- 出征相关tabel
    self.tanksSlotTab={}
    self.tickSlotTab=nil
    self.tickSlotBG=nil
    -- 协防相关tabel
    -- self.helpDefendTab={}
    -- self.helpDefendFlag=false

    -- self.enemyTabIndex = 1
    -- self.helpTabIndex = 1
    -- self.enemyLineCount = 1
    self.travelLineCount = 1
    -- self.helpLineCount = 1
    self.tankSlotIndex = nil
    self.singleEventFlag = false
    self.closeCallBack = nil -- 存储回调方法，关闭方法触摸前调用

    self.myEventDialog = nil -- 此类唯一实例，只许存在一个单一行军窗口

    --self.parent=parent
    --self.cityID=cityID
    require "luascript/script/game/scene/gamedialog/warDialog/tankAttackInfoDialog"
    -- require "luascript/script/game/scene/gamedialog/allianceDialog/helpDefenseInfoDialog"
    return nc
end

function oneWarEventDialog:create(layerNum)
    local sd=oneWarEventDialog:new()
    sd:init(layerNum)
    return sd
end

--bgSrc:9宫格背景图片 size:对话框大小 isuseami:是否有动画效果 layerNum:层次 title:标题  slotVo:行军队列的数据vo(行军图标触摸) closeCallBack:触发关闭事件的回调
function oneWarEventDialog:init(bgSrc,size,fullRect,inRect,layerNum,title,slotVo,closeCallBack)
    local function refreshSlot(event,data)
        if self.refreshData and self.refreshData.tableView then
            self.tickSlotBG=nil
            self.tickSlotTab=nil
            self:resetTabIndex()
            local recordPoint=self.refreshData.tableView:getRecordPoint()
            self.refreshData.tableView:reloadData()
            self.refreshData.tableView:recoverToRecordPoint(recordPoint)
        end
    end
    self.refreshSlotListener=refreshSlot
    eventDispatcher:addEventListener("attackTankSlot.refreshSlot",refreshSlot)

    self.isTouch=false
    self.isUseAmi=false

    local function touchHandler() 
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(self.bgSize)
    self:show()

    if slotVo~=nil then
        self.tankSlotIndex = slotVo.slotId
        self.singleEventFlag = true
    end
    if closeCallBack then
        self.closeCallBack = closeCallBack
    end

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(150)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)
    self.dialogLayer:addChild(self.bgLayer,2)

    local upForbidBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
    upForbidBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,(G_VisibleSizeHeight-self.bgSize.height)/2+100))
    upForbidBg:ignoreAnchorPointForPosition(false)
    upForbidBg:setAnchorPoint(CCPointMake(0.5,0))
    upForbidBg:setOpacity(0)
    upForbidBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-100))
    upForbidBg:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(upForbidBg,1)

    local bottomForbidBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
    bottomForbidBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,(G_VisibleSizeHeight-self.bgSize.height)/2+30))
    bottomForbidBg:ignoreAnchorPointForPosition(false)
    bottomForbidBg:setAnchorPoint(CCPointMake(0.5,1))
    bottomForbidBg:setOpacity(0)
    bottomForbidBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,30))
    bottomForbidBg:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(bottomForbidBg,1)

    if title then
        local titleLb=GetTTFLabel(title,40)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
    end

    base:addNeedRefresh(self)
    --self.refreshData.countdownTab={}

    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            local num = 1
            return num
        elseif fn=="tableCellSizeForIndex" then
            local cellWidth=self.bgLayer:getContentSize().width-40
            local cellHeight=140
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local cellWidth=self.bgLayer:getContentSize().width-40
            local cellHeight=140
            if self.tankSlotIndex==nil then
                return cell
            end
            -- 获取出征table 判断是否还有数据没显示
            local slotIndex,slotVo=attackTankSoltVoApi:getSlotIndexById(self.tankSlotIndex)
            if slotVo~=nil then  -- 出征
                travelIdx = attackTankSoltVoApi:getSlotIndexById(self.tankSlotIndex)
                travelIdx = travelIdx - 1
                local rect = CCRect(0, 0, 50, 50)
                local capInSet = CCRect(20, 20, 10, 10)
                local function cellClick(hd,fn,idx)
                end
                local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
                backSprie:setContentSize(CCSizeMake(cellWidth, cellHeight-5))
                backSprie:ignoreAnchorPointForPosition(false)
                backSprie:setAnchorPoint(ccp(0.5,0.5))
                backSprie:setPosition(ccp(cellWidth/2,cellHeight/2))
                backSprie:setTag(1000+travelIdx)
                backSprie:setIsSallow(false)
                backSprie:setTouchPriority((-(layerNum-1)*20-2))
                cell:addChild(backSprie,1)
                local nameStr;
                for k,v in pairs(slotVo) do
                    print(k,v)
                end
                if (slotVo.type>0 and slotVo.type<6) or slotVo.type==7 or slotVo.type == 9 then
                    if slotVo.type == 9 then
                        nameStr = "("..slotVo.targetid[1]..","..slotVo.targetid[2]..")"..getlocal("airShip_worldTroops")
                    else
                        local islandName=G_getIslandName(slotVo.type,nil,slotVo.level or 1,slotVo.rebelIndex or 1,false,slotVo.rebelRpic)
                        nameStr=islandName.." "..getlocal("lower_level").."."..slotVo.level.."("..slotVo.targetid[1]..","..slotVo.targetid[2]..")"
                        if G_getCurChoseLanguage()=="ar" then
                            nameStr=" "..getlocal("lower_level").."."..slotVo.level.."("..slotVo.targetid[1]..","..slotVo.targetid[2]..")"..islandName
                        end
                    end
                else
                    nameStr=slotVo.tName.." "..getlocal("lower_level").."."..slotVo.level
                end
                
                local labName=GetTTFLabelWrap(nameStr,24,CCSizeMake(24*12,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                labName:setAnchorPoint(ccp(0,0.5));
                labName:setPosition(ccp(120,backSprie:getContentSize().height-35))
                backSprie:addChild(labName)
                            
                AddProgramTimer(backSprie,ccp(240,backSprie:getContentSize().height/2-20),9,12,getlocal("attckarrivade"),"TeamTravelBarBg.png","TeamTravelBar.png",11)
                local moneyTimerSprite = tolua.cast(backSprie:getChildByTag(9),"CCProgressTimer")
                self.tickSlotTab = moneyTimerSprite
                
                local cellTankSlot = slotVo
                --判断如果不为采集满 并且不为协防已经到达那种 就显示正确的进度条
                if cellTankSlot.isGather~=3 and cellTankSlot.isGather~=4 and cellTankSlot.isGather~=5 then
                    local lefttime,totaletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId)
                    local per=(totaletime-lefttime)/totaletime*100
                    moneyTimerSprite:setPercentage(per)
                end
                
                local lbPer = tolua.cast(moneyTimerSprite:getChildByTag(12),"CCLabelTTF")
                local iconSp;
                local cityFlag
                if cellTankSlot.type==8 then
                    cityFlag=1
                end
                --情况1 采集中的时候
                if cellTankSlot.isGather==2 and cellTankSlot.bs==nil then
                    iconSp=CCSprite:createWithSpriteFrameName("Icon_BG.png")
                    local iconOccupySp = CCSprite:createWithSpriteFrameName("IconOccupy.png")
                    iconOccupySp:setPosition(getCenterPoint(iconSp))
                    iconSp:addChild(iconOccupySp,1)
                    iconSp:setTag(101)
                    local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotId(cellTankSlot.slotId)
                    local per=nowRes/maxRes*100
                    moneyTimerSprite:setPercentage(per)
                    if nowRes>=maxRes then
                       nowRes=maxRes
                    end
                    if lbPer~=nil then
                        lbPer:setString(getlocal("stayForResource",{FormatNumber(nowRes),FormatNumber(maxRes)}))
                    end
                    local function backTouch()
                        if self.refreshData.tableView:getIsScrolled()==true then
                            do return end
                        end
                        local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotId(cellTankSlot.slotId)
                        if nowRes<maxRes then

                            local function backSure()

                                local function serverBack(fn,data)
                                    --local retTb=OBJDEF:decode(data)
                                    if base:checkServerData(data)==true then
                                        self.tickSlotBG=nil
                                        self.tickSlotTab=nil
                                        local recordPoint=self.refreshData.tableView:getRecordPoint()
                                        self:resetTabIndex()
                                        self.refreshData.tableView:reloadData() 
                                        self.refreshData.tableView:recoverToRecordPoint(recordPoint)       
                                        enemyVoApi:deleteEnemy(cellTankSlot.targetid[1],cellTankSlot.targetid[2])
                                        eventDispatcher:dispatchEvent("worldScene.mineChange",{{x=cellTankSlot.targetid[1],y=cellTankSlot.targetid[2]}})
                                    end
                                 end
                                socketHelper:troopBack(cellTankSlot.slotId,serverBack,nil,cityFlag)
                            end
                            
                            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),backSure,getlocal("dialog_title_prompt"),getlocal("fleetStaying"),nil,layerNum+1)
                        else

                                local function serverBack(fn,data)
                                    --local retTb=OBJDEF:decode(data)
                                    if base:checkServerData(data)==true then
                                        self.tickSlotBG=nil
                                        self.tickSlotTab=nil
                                        local recordPoint=self.refreshData.tableView:getRecordPoint()
                                        self:resetTabIndex()
                                        self.refreshData.tableView:reloadData()      
                                        self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                                        enemyVoApi:deleteEnemy(cellTankSlot.targetid[1],cellTankSlot.targetid[2])
                                        eventDispatcher:dispatchEvent("worldScene.mineChange",{{x=cellTankSlot.targetid[1],y=cellTankSlot.targetid[2]}})
                                    end
                                 end
                                socketHelper:troopBack(cellTankSlot.slotId,serverBack,nil,cityFlag)

                        end

                        
                    end
                    local backItem=GetButtonItem("IconReturnBtn.png","IconReturnBtn_Down.png","IconReturnBtn.png",backTouch,nil,nil,nil)
                    local backMenu=CCMenu:createWithItem(backItem)
                    backMenu:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2))
                    backMenu:setTouchPriority(-(layerNum-1)*20-2);
                    backSprie:addChild(backMenu)
                --情况2 采集满的时候
                elseif cellTankSlot.isGather==3 and cellTankSlot.bs==nil then
                    iconSp=CCSprite:createWithSpriteFrameName("Icon_BG.png")
                    local iconOccupySp = CCSprite:createWithSpriteFrameName("IconOccupy.png")
                    iconOccupySp:setPosition(getCenterPoint(iconSp))
                    iconSp:addChild(iconOccupySp,1)
                    iconSp:setTag(101);
                    local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotId(cellTankSlot.slotId)

                    local per=100
                    moneyTimerSprite:setPercentage(per)
                    if lbPer~=nil then
                        lbPer:setString(getlocal("stayForResource",{FormatNumber(maxRes),FormatNumber(maxRes)}))
                    end
                    local function backTouch()
                    
                        local function serverBack(fn,data)
                            --local retTb=OBJDEF:decode(data)
                            if base:checkServerData(data)==true then
                                self.tickSlotBG=nil
                                self.tickSlotTab=nil
                                local recordPoint=self.refreshData.tableView:getRecordPoint()
                                self:resetTabIndex()
                                self.refreshData.tableView:reloadData()
                                self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                                enemyVoApi:deleteEnemy(cellTankSlot.targetid[1],cellTankSlot.targetid[2])
                                eventDispatcher:dispatchEvent("worldScene.mineChange",{{x=cellTankSlot.targetid[1],y=cellTankSlot.targetid[2]}})
                            end
                         end
                        socketHelper:troopBack(cellTankSlot.slotId,serverBack,nil,cityFlag)
                        
                    end
                    local backItem=GetButtonItem("IconReturnBtn.png","IconReturnBtn_Down.png","IconReturnBtn.png",backTouch,nil,nil,nil)
                    local backMenu=CCMenu:createWithItem(backItem)
                    backMenu:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2))
                    backMenu:setTouchPriority(-(layerNum-1)*20-2)
                    backSprie:addChild(backMenu)
                --情况3 协防正在进行时
                elseif (cellTankSlot.isHelp~=nil and cellTankSlot.bs==nil and cellTankSlot.isGather~=4 and cellTankSlot.isGather~=5) or (cellTankSlot.isDef>0 and cellTankSlot.bs==nil and cellTankSlot.isGather~=5 and cellTankSlot.isGather~=6) then
                    iconSp=CCSprite:createWithSpriteFrameName("Icon_BG.png")
                    local iconAttackSp = CCSprite:createWithSpriteFrameName("IconAttack.png")
                    iconAttackSp:setPosition(getCenterPoint(iconSp))
                    iconSp:addChild(iconAttackSp,1)
                    iconSp:setTag(104)

                    local function touch1()
                        if self.refreshData.tableView:getIsScrolled()==true then
                            do return end
                        end
                        local function cronBack()
                            local function cronAttackCallBack(fn,data)
                                local retTb=G_Json.decode(tostring(data))
                                if base:checkServerData(data)==true then
                                    local vo =activityVoApi:getActivityVo("speedupdisc")
                                    if vo and activityVoApi:isStart(vo) then
                                        local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                        if open and vo.currentCost>0 and vo.rand>0 then
                                            local getTip=getlocal("activity_speedupdisc_realDis",{vo.currentCost,vo.rand})
                                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getTip,28)
                                            vo:resetDiscountAndCost()
                                        end
                                    end
                                    if self.tickSlotTab then
                                        self.tickSlotTab:removeFromParentAndCleanup(true)
                                        self.tickSlotTab=nil
                                    end
                                    local recordPoint=self.refreshData.tableView:getRecordPoint()
                                    self:resetTabIndex()
                                    self.refreshData.tableView:reloadData()
                                    self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                                    if base.heroSwitch==1 then
                                        --请求英雄数据
                                        local function heroGetlistHandler(fn,data)
                                            local ret,sData=base:checkServerData(data)
                                            if ret==true then

                                            end
                                        end
                                        socketHelper:heroGetlist(heroGetlistHandler)
                                    end
                                end
                            end
                            local cronidSend=cellTankSlot.slotId;
                            local targetSend=cellTankSlot.targetid;
                            local attackerSend=playerVoApi:getUid()
                            socketHelper:cronAttack(cronidSend,targetSend,attackerSend,1,cronAttackCallBack);
                        end
    
                        local leftTime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId)                    
                        if leftTime>=0 then
                                local needGemsNum=TimeToGems(leftTime)
                                local needGems=getlocal("speedUp",{needGemsNum})
                             if needGemsNum>playerVoApi:getGems() then --金币不足
                                GemsNotEnoughDialog(nil,nil,needGemsNum-playerVoApi:getGems(),layerNum+1,needGemsNum)
                                do return end
                             else
                                local addContent
                                local vo =activityVoApi:getActivityVo("speedupdisc")
                                if vo and activityVoApi:isStart(vo) then
                                    local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                    if open and vo.speedup and vo.speedup["troop"] then
                                      local speedCfg = vo.speedup["troop"]
                                      addContent=getlocal("activity_speedupdisc_discount",{math.ceil(speedCfg[1]*needGemsNum),math.ceil(speedCfg[2]*needGemsNum)})
                                    end
                                end
                                if addContent then
                                    smallDialog:showSureAndCancle2("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),cronBack,getlocal("dialog_title_prompt"),needGems,addContent,nil,layerNum+1)
                                else
                                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),cronBack,getlocal("dialog_title_prompt"),needGems,nil,layerNum+1)
                                end
                             end
                         end
                    end
                    
                    local menuItem1 = GetButtonItem("BtnRight.png","BtnRight_Down.png","BtnRight_Down.png",touch1,10,nil,nil)
                        local menu1 = CCMenu:createWithItem(menuItem1);
                    menu1:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2));
                    menu1:setTouchPriority(-(layerNum-1)*20-2);
                    backSprie:addChild(menu1,3);

                    local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId))
                    if lbPer~=nil then
                        lbPer:setString(getlocal("attckarrivade",{time}))
                    end
                --情况4 协防已经达到的时候
                elseif (cellTankSlot.isGather==4 or cellTankSlot.isGather==5) and cellTankSlot.bs==nil then
                    iconSp=CCSprite:createWithSpriteFrameName("Icon_BG.png")
                    local iconDefenseSp = CCSprite:createWithSpriteFrameName("IconDefense.png")
                    iconDefenseSp:setPosition(getCenterPoint(iconSp))
                    iconSp:addChild(iconDefenseSp,1)
                    iconSp:setTag(105);
                    local stateStr,backFlag=nil,true
                    if cellTankSlot.isGather==4 then
                        stateStr=getlocal("standbying")
                    elseif cellTankSlot.isGather==5 and cellTankSlot.isDef==0 and cellTankSlot.isHelp==1 then --协防玩家城市
                        stateStr=getlocal("defensing")
                    elseif cellTankSlot.isGather==5 and cellTankSlot.isDef==0 and cellTankSlot.isHelp==nil and cellTankSlot.type==8 then --军团城市战斗中
                        stateStr=getlocal("cityattacking")
                        backFlag=attackTankSoltVoApi:isCanBackTroops(cellTankSlot)
                    elseif cellTankSlot.isGather==5 and cellTankSlot.isDef>0 then --军团城市驻防中
                        stateStr=getlocal("citydefending")
                    end
                    local per=100
                    moneyTimerSprite:setPercentage(per)
                    if lbPer~=nil then
                        lbPer:setString(stateStr)
                    end
                    local function backTouch()
                        local function serverBack(fn,data)
                            --local retTb=OBJDEF:decode(data)
                            if base:checkServerData(data)==true then
                                self.tickSlotBG=nil
                                self.tickSlotTab=nil
                                -- self.tanksSlotTab={}
                                -- self.tanksSlotTab=attackTankSoltVoApi:getAllAttackTankSlots()
                                local recordPoint=self.refreshData.tableView:getRecordPoint()
                                self:resetTabIndex()
                                self.refreshData.tableView:reloadData()
                                self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                                enemyVoApi:deleteEnemy(cellTankSlot.targetid[1],cellTankSlot.targetid[2])
                            end
                         end
                        socketHelper:troopBack(cellTankSlot.slotId,serverBack,nil,cityFlag)
                    end
                    local backItem=GetButtonItem("IconReturnBtn.png","IconReturnBtn_Down.png","IconReturnBtn.png",backTouch,nil,nil,nil)
                    local backMenu=CCMenu:createWithItem(backItem)
                    backMenu:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2))
                    backMenu:setTouchPriority(-(layerNum-1)*20-2)
                    backSprie:addChild(backMenu)
                    backItem:setEnabled(backFlag)
                    backItem:setVisible(backFlag)
                --情况5 返航的时候
                elseif cellTankSlot.bs~=nil then
            
                    local function touch1()
                        if self.refreshData.tableView:getIsScrolled()==true then
                            do return end
                        end
                        local function speedBack()
                            local function troopBackSpeedupCallBack(fn,data)
                                local retTb=G_Json.decode(tostring(data))
                                if base:checkServerData(data)==true then
                                    local vo =activityVoApi:getActivityVo("speedupdisc")
                                    if vo and activityVoApi:isStart(vo) then
                                        local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                        if open and vo.currentCost>0 and vo.rand>0 then
                                            local getTip=getlocal("activity_speedupdisc_realDis",{vo.currentCost,vo.rand})
                                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getTip,28)
                                            vo:resetDiscountAndCost()
                                        end
                                    end
                                    if self.tickSlotTab then
                                        self.tickSlotTab:removeFromParentAndCleanup(true)
                                        self.tickSlotTab=nil
                                    end
                                    self.tickSlotBG=nil
                                    self.tickSlotTab=nil
                                    if(self.refreshData and self.refreshData.tableView and tolua.cast(self.refreshData.tableView,"LuaCCTableView"))then
                                        self:resetTabIndex()
                                        -- 返航时加速结束，则刷新列表
                                        self.refreshData.tableView:reloadData()
                                    end
                                end
                            end
                         if cellTankSlot~=nil then
                                local cidSend=cellTankSlot.slotId
                                socketHelper:troopBackSpeedup(cidSend,troopBackSpeedupCallBack)
                         end
                        end
                        local leftTime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId)
                        
                        if leftTime>=0 then
                                local needGemsNum=TimeToGems(leftTime)
                                local needGems=getlocal("speedUp",{needGemsNum})
                             if needGemsNum>playerVoApi:getGems() then --金币不足
                                GemsNotEnoughDialog(nil,nil,needGemsNum-playerVoApi:getGems(),layerNum+1,needGemsNum)
                                do return end
                             else
                                local addContent
                                local vo =activityVoApi:getActivityVo("speedupdisc")
                                if vo and activityVoApi:isStart(vo) then
                                    local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                    if open and vo.speedup and vo.speedup["troop"] then
                                      local speedCfg = vo.speedup["troop"]
                                      addContent=getlocal("activity_speedupdisc_discount",{math.ceil(speedCfg[1]*needGemsNum),math.ceil(speedCfg[2]*needGemsNum)})
                                    end
                                end
                                if addContent then
                                    smallDialog:showSureAndCancle2("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),speedBack,getlocal("dialog_title_prompt"),needGems,addContent,nil,layerNum+1)
                                else
                                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),speedBack,getlocal("dialog_title_prompt"),needGems,nil,layerNum+1)
                                end
                             end
                         end
                    end
                    
                    local menuItem1 = GetButtonItem("BtnRight.png","BtnRight_Down.png","BtnRight_Down.png",touch1,10,nil,nil)
                    local menu1 = CCMenu:createWithItem(menuItem1);
                    menu1:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2))
                    menu1:setTouchPriority(-(layerNum-1)*20-2)
                    backSprie:addChild(menu1,3)

                    iconSp=CCSprite:createWithSpriteFrameName("Icon_BG.png")
                    local iconReturnSp = CCSprite:createWithSpriteFrameName("IconReturn-.png")
                    iconReturnSp:setPosition(getCenterPoint(iconSp))
                    iconSp:addChild(iconReturnSp,1)
                    iconSp:setTag(102)
                    local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId))
                    if lbPer~=nil then
                        lbPer:setString(getlocal("returnarrivade",{time}))
                    end
                --情况6 部队前行中
                else
                    local function touch1()
                        if self.refreshData.tableView:getIsScrolled()==true then
                            do
                                return
                            end
                        end
                    
                        local function cronBack()
                            local function cronAttackCallBack(fn,data)
                                local retTb=G_Json.decode(tostring(data))
                                if base:checkServerData(data)==true then
                                    local vo =activityVoApi:getActivityVo("speedupdisc")
                                    if vo and activityVoApi:isStart(vo) then
                                        local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                        if open and vo.currentCost>0 and vo.rand>0 then
                                            local getTip=getlocal("activity_speedupdisc_realDis",{vo.currentCost,vo.rand})
                                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getTip,28)
                                            vo:resetDiscountAndCost()
                                        end
                                    end
                                    if self.tickSlotTab then
                                        self.tickSlotTab:removeFromParentAndCleanup(true)
                                        self.tickSlotTab=nil
                                    end
                                    self.tickSlotTab=nil
                                    if(cellTankSlot.targetid[1] and cellTankSlot.targetid[2])then
                                        eventDispatcher:dispatchEvent("worldScene.mineChange",{{x=cellTankSlot.targetid[1],y=cellTankSlot.targetid[2]}})
                                    end
                                    local recordPoint=self.refreshData.tableView:getRecordPoint()
                                    self:resetTabIndex()
                                    self.refreshData.tableView:reloadData()
                                    self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                                    if base.heroSwitch==1 then
                                        --请求英雄数据
                                        local function heroGetlistHandler(fn,data)
                                            local ret,sData=base:checkServerData(data)
                                            if ret==true then

                                            end
                                        end
                                        socketHelper:heroGetlist(heroGetlistHandler)
                                    end
                                end
                            end
                            local cronidSend=cellTankSlot.slotId
                            local targetSend=cellTankSlot.targetid
                            local attackerSend=playerVoApi:getUid()
                            socketHelper:cronAttack(cronidSend,targetSend,attackerSend,1,cronAttackCallBack)
                        end
                        
                        local leftTime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId)
                        
                        if leftTime>=0 then
                                local needGemsNum=TimeToGems(leftTime)
                                local needGems=getlocal("speedUp",{needGemsNum})
                             if needGemsNum>playerVoApi:getGems() then --金币不足
                                print("金币不足，请充值面板")
                                GemsNotEnoughDialog(nil,nil,needGemsNum-playerVoApi:getGems(),layerNum+1,needGemsNum)
                                do return end
                             else
                                print("确定是否加速面板")
                                local addContent
                                local vo =activityVoApi:getActivityVo("speedupdisc")
                                if vo and activityVoApi:isStart(vo) then
                                    local open = acSpeedUpDiscVoApi:checkIfOpen("troop")
                                    if open and vo.speedup and vo.speedup["troop"] then
                                      local speedCfg = vo.speedup["troop"]
                                      addContent=getlocal("activity_speedupdisc_discount",{math.ceil(speedCfg[1]*needGemsNum),math.ceil(speedCfg[2]*needGemsNum)})
                                    end
                                end
                                if addContent then
                                    smallDialog:showSureAndCancle2("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),cronBack,getlocal("dialog_title_prompt"),needGems,addContent,nil,layerNum+1)
                                else
                                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),cronBack,getlocal("dialog_title_prompt"),needGems,nil,layerNum+1)
                                end
                             end
                         end
                    end
                    
                    local menuItem1 = GetButtonItem("BtnRight.png","BtnRight_Down.png","BtnRight_Down.png",touch1,10,nil,nil)
                        local menu1 = CCMenu:createWithItem(menuItem1);
                    menu1:setPosition(ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2))
                    menu1:setTouchPriority(-(layerNum-1)*20-2)
                    backSprie:addChild(menu1,3)

                    local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(cellTankSlot.slotId))
                    iconSp=CCSprite:createWithSpriteFrameName("Icon_BG.png")
                    local iconAttackSp = CCSprite:createWithSpriteFrameName("IconAttack.png")
                    iconAttackSp:setPosition(getCenterPoint(iconSp))
                    iconSp:addChild(iconAttackSp,1)
                    iconSp:setTag(103)
                    if lbPer~=nil then
                        lbPer:setString(getlocal("attckarrivade",{time}))
                    end
                end
                iconSp:setPosition(ccp(50,backSprie:getContentSize().height/2))
                backSprie:addChild(iconSp)
                self.tickSlotBG = iconSp
                local function touch2()
                    if self.refreshData.tableView:getIsScrolled()==true then
                            do
                                return
                            end
                    end
                    local tankInfo = tankAttackInfoDialog:new()
                    local infoBg = tankInfo:init(cellTankSlot,cellTankSlot.troops,layerNum+1)                
                end
                local menuItem2 = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch2,11,nil,nil)
                local menu2 = CCMenu:createWithItem(menuItem2)
                menu2:setPosition(ccp(430,backSprie:getContentSize().height/2))
                menu2:setTouchPriority(-(layerNum-1)*20-2)
                backSprie:addChild(menu2,3)
                self.travelLineCount=self.travelLineCount+1
            end
            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local cellWidth=self.bgLayer:getContentSize().width-40
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgLayer:getContentSize().height-130),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.refreshData.tableView:setPosition(ccp(20,30))
    self.bgLayer:addChild(self.refreshData.tableView,1)
    self.refreshData.tableView:setMaxDisToBottomOrTop(50)


    -- 关闭按钮触发事件
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:newClose()
    end
    -- 关闭按钮
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-5)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,1)

    return self.dialogLayer
end

function oneWarEventDialog:tick()
    if self.refreshData.tableView==nil then
        do return end
    end
    if self.tankSlotIndex~=nil then
        local slotIndex,slotVo = attackTankSoltVoApi:getSlotIndexById(self.tankSlotIndex)
        if slotIndex==nil then
            self:newClose()
            do return end
        end    
        if self.tickSlotTab~=nil then  
            if slotVo.isGather==2 and slotVo.bs==nil then
                if self.tickSlotBG and self.tickSlotBG:getTag()~=101 then
                    self.tickSlotBG=nil
                    self.tickSlotTab=nil
                    self:resetTabIndex()
                    local recordPoint=self.refreshData.tableView:getRecordPoint()
                    self.refreshData.tableView:reloadData()
                    self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                end

                local nowRes,maxRes=attackTankSoltVoApi:getLeftResAndTotalResBySlotId(slotVo.slotId)
                local per=nowRes/maxRes
                self.tickSlotTab:setPercentage(per*100)
                local totleRes=maxRes
                local lbPer = tolua.cast(self.tickSlotTab:getChildByTag(12),"CCLabelTTF")
                if nowRes>=totleRes then
                   nowRes=totleRes
                end
                if lbPer then
                    lbPer:setString(getlocal("stayForResource",{FormatNumber(math.floor(nowRes)),FormatNumber(totleRes)}))
                end
            elseif (slotVo.isHelp~=nil and slotVo.bs==nil and slotVo.isGather~=4 and slotVo.isGather~=5) or (slotVo.isDef>0 and slotVo.bs==nil and slotVo.isGather~=5 and slotVo.isGather~=6) then
                if self.tickSlotBG and self.tickSlotBG:getTag()~=104 then
                    self.tickSlotBG=nil
                    self.tickSlotTab=nil
                    self:resetTabIndex()
                    local recordPoint=self.refreshData.tableView:getRecordPoint()
                    self.refreshData.tableView:reloadData()
                    self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                end
                local lefttime,totletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(slotVo.slotId)
                local per=(totletime-lefttime)/totletime*100
                self.tickSlotTab:setPercentage(per);
                local lbPer = tolua.cast(self.tickSlotTab:getChildByTag(12),"CCLabelTTF")
                if lbPer~=nil then
                    local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(slotVo.slotId))
                    lbPer:setString(getlocal("attckarrivade",{time}))
                end
            elseif (slotVo.isGather==4 or slotVo.isGather==5) and slotVo.bs==nil then
                if self.tickSlotBG and self.tickSlotBG:getTag()~=105 then
                    self.tickSlotBG=nil
                    self.tickSlotTab=nil
                    self:resetTabIndex()
                    local recordPoint=self.refreshData.tableView:getRecordPoint()
                    self.refreshData.tableView:reloadData()
                    self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                end
                self.tickSlotTab:setPercentage(100);
            elseif slotVo.isGather==3 and slotVo.bs==nil then
                if self.tickSlotBG and self.tickSlotBG:getTag()~=101 then
                    self.tickSlotBG=nil
                    self.tickSlotTab=nil
                    self:resetTabIndex()
                    local recordPoint=self.refreshData.tableView:getRecordPoint()
                    self.refreshData.tableView:reloadData()
                    self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                end
                self.tickSlotTab:setPercentage(100)
            elseif slotVo.bs~=nil then
                if self.tickSlotBG and self.tickSlotBG:getTag()~=102 then
                    self.tickSlotBG=nil
                    self.tickSlotTab=nil
                    self:resetTabIndex()
                    local recordPoint=self.refreshData.tableView:getRecordPoint()
                    self.refreshData.tableView:reloadData()
                    self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                end
                local lefttime,totletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(slotVo.slotId)
                local per=(totletime-lefttime)/totletime*100
                self.tickSlotTab:setPercentage(per)
                local lbPer = tolua.cast(self.tickSlotTab:getChildByTag(12),"CCLabelTTF")
                if lbPer~=nil then
                    local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(slotVo.slotId))
                    lbPer:setString(getlocal("returnarrivade",{time}))
                end
                if lefttime<=0 then
                    self.tickSlotTab=nil
                    self:resetTabIndex()
                    self.refreshData.tableView:reloadData()
                end
            else
                if self.tickSlotBG and self.tickSlotBG:getTag()~=103 then
                    self.tickSlotBG=nil
                    self.tickSlotTab=nil
                    self:resetTabIndex()
                    local recordPoint=self.refreshData.tableView:getRecordPoint()
                    self.refreshData.tableView:reloadData()
                    self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                end
                local lefttime,totletime=attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(slotVo.slotId)
                local per=(totletime-lefttime)/totletime*100
                self.tickSlotTab:setPercentage(per);
                local lbPer = tolua.cast(self.tickSlotTab:getChildByTag(12),"CCLabelTTF")
                if lbPer~=nil then
                    local time=GetTimeStr(attackTankSoltVoApi:getLeftTimeAndTotalTimeBySlotId(slotVo.slotId))
                    lbPer:setString(getlocal("attckarrivade",{time}))
                end
                if lefttime<=0 then
                    if slotVo.signState==1 then
                        self.tickSlotBG=nil
                        self.tickSlotTab=nil
                        self:resetTabIndex()
                        self.refreshData.tableView:reloadData()
                    end
                end
            end
        end
    end
end

function oneWarEventDialog:resetTabIndex()
    self.enemyTabIndex = 1
    self.helpTabIndex = 1
    self.enemyLineCount = 1
    self.travelLineCount = 1
    self.helpLineCount = 1
end

-- 新的关闭方法
function oneWarEventDialog:newClose() 
    if self.closeCallBack then
        local newCloseFunc = self.closeCallBack
        newCloseFunc()
    end
    self:close()
    self.myEventDialog = nil
end

-- --bgSrc:9宫格背景图片 size:对话框大小 isuseami:是否有动画效果 layerNum:层次 title:标题  slotVo:行军队列的数据vo(行军图标触摸) closeCallBack:触发关闭事件的回调
function oneWarEventDialog:initDialog(bgSrc,size,fullRect,inRect,layerNum,title,slotVo,closeCallBack)
    if self.myEventDialog==nil then
        self.myEventDialog = self:init(bgSrc,size,fullRect,inRect,layerNum,title,slotVo,closeCallBack)
        return self.myEventDialog
    else
        return nil
    end
end

function oneWarEventDialog:dispose()
    if self.refreshSlotListener then
        eventDispatcher:removeEventListener("attackTankSlot.refreshSlot",self.refreshSlotListener)
        self.refreshSlotListener=nil
    end
    self.dialogHeight=400
    self.dialogWidth=550

    -- tabelview对象
    self.refreshData.tableView=nil
    -- 刷新敌军来袭
    -- self.refreshData.enemyTab=nil
    -- -- 刷新协防
    -- self.refreshData.helpTab=nil

    --敌军来袭相关tabel
    -- self.enemyComingTab=nil
    -- 出征相关tabel
    self.tanksSlotTab=nil
    self.tickSlotTab=nil
    self.tickSlotBG=nil
    -- 协防相关tabel
    -- self.helpDefendTab=nil
    -- self.helpDefendFlag=false

    -- self.enemyTabIndex = 1
    -- self.helpTabIndex = 1
    -- self.enemyLineCount = 1
    self.travelLineCount = 1
    -- self.helpLineCount = 1

    self.singleEventFlag = false
    self.closeCallBack = nil
    self.myEventDialog = nil -- 此类唯一实例，只许存在一个单一行军窗口
    self = nil
end



