energyCrystalTab1Dialog={}

function energyCrystalTab1Dialog:new(defaultWeaponID)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=nil
    self.bgLayer=nil;
    self.tipSp=nil
    self.superWeaponListBg=nil--超级武器列表背景框
    self.superWeaponNameLb=nil--超级武器名称文本
    self.selectedCrystalIndex=-1--当前选中的结晶的index
    self.crystalList=nil--能量结晶列表
    self.weaponList={}
    self.showCrystalNum=5
    self.selectedWeaponId=""--默认选中的超级武器id
    self.weaponIconList={}
    self.wearCrystalIcon1=nil--穿戴的结晶1
    self.wearCrystalIcon2=nil
    self.wearCrystalIcon3=nil
    self.suitTb=nil--套装的数据
    self.allCrystalIconSp={}
    self.crystalIconPos1=nil
    self.crystalIconPos2=nil
    self.crystalIconPos3=nil
    nc.defaultWeaponID=defaultWeaponID
    nc.cellHeight=120
    nc.newShowList={}
    local function addPlist()
        spriteController:addPlist("public/swYouhuaUI.plist")
        spriteController:addTexture("public/swYouhuaUI.png")
    end
    G_addResource8888(addPlist)
    return nc
end

function energyCrystalTab1Dialog:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self:initTableView()
    local function onDataChange(event,data)
        self:refreshWeaponlist()
    end
    eventDispatcher:addEventListener("superweapon.data.info",onDataChange)
    self.eventListener=onDataChange
    return self.bgLayer
end

--设置对话框里的tableView
function energyCrystalTab1Dialog:initTableView()
    local function touch()
        return
    end
    self.superWeaponListBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
    self.superWeaponListBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,self.cellHeight-10))
    self.superWeaponListBg:setPosition(ccp(25,self.bgLayer:getContentSize().height-175))
    self.superWeaponListBg:setAnchorPoint(ccp(0,1))
    self:initAllBg()
    local function callBack(handler,fn,idx,cell)
        return self:eventHandler(handler,fn,idx,cell)
    end
    self:refreshWeaponlist()
    local hd2= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd2,CCSizeMake(self.bgLayer:getContentSize().width-70,self.cellHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(10,-5))
    self.superWeaponListBg:addChild(self.tv,self.layerNum)
    self.bgLayer:addChild(self.superWeaponListBg)
    if(self.defaultWeaponID)then
        local index
        for k,v in pairs(self.weaponList) do
            if(v.id==self.defaultWeaponID)then
                index=k
                break
            end
        end
        if(index)then
            self:showSuperWeaponInfo(index)
            self.tv:reloadData()
            local minX=math.max(-(index - 1)*110,G_VisibleSizeWidth - 70 - (#self.weaponList)*110)
            minX=math.min(0,minX)
            self.tv:recoverToRecordPoint(ccp(minX,0))
        end
    end
end

function energyCrystalTab1Dialog:eventHandler(handler,fn,idx,cel)

    if fn=="numberOfCellsInTableView" then
        return #self.newShowList
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.cellHeight,self.cellHeight)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        
        local data=self.weaponList[idx + 1]
        local id=self.newShowList[idx + 1].id
        local function onClick(object,fn,tag)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do return end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                if data then
                    local index=tag - 100 + 1
                    self:showSuperWeaponInfo(index)
                else
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("emblem_noHad"),30)
                end
                
            end
        end
        local iconSp = LuaCCSprite:createWithSpriteFrameName(superWeaponCfg.weaponCfg[id].icon,onClick)
        iconSp:setTag(100 + idx)
        iconSp:setTouchPriority(-(self.layerNum-1)*20-4)
        iconSp:setScale(100/iconSp:getContentSize().height)
        -- iconSp:setAnchorPoint(ccp(0,0))
        iconSp:setPosition(ccp(self.cellHeight/2,self.cellHeight/2))
        self.weaponIconList[idx + 1]=iconSp
        cell:addChild(iconSp)

        if not data then
            iconSp:setOpacity(0)
            local jianyinSp=CCSprite:createWithSpriteFrameName("silhouette_" .. id .. ".png")
            iconSp:addChild(jianyinSp)
            jianyinSp:setPosition(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2)
        end

        local function nilFunc()
        end
        local blackSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
        blackSp:setTouchPriority(-(self.layerNum-1)*20-1)
        local rect=CCSizeMake(100,100)
        blackSp:setContentSize(rect)
        blackSp:setOpacity(180)
        -- blackSp:setAnchorPoint(ccp(0,0))
        blackSp:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2))
        iconSp:addChild(blackSp,2)
        blackSp:setTag(99)

        if self.selectedWeaponId=="" or (data and self.selectedWeaponId==data.id) then
            blackSp:setVisible(false)
            iconSp:setScale(self.cellHeight/iconSp:getContentSize().height)
            -- self.selectedSp = G_addRectFlicker(iconSp,1.4,1.4)
            self:showSuperWeaponInfo(idx+1)
        end
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end


--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function energyCrystalTab1Dialog:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num = math.ceil(SizeOfTable(self.crystalList)/self.showCrystalNum)
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(110,110)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        
        
        local num = self.showCrystalNum
        if (idx+1)==math.ceil(SizeOfTable(self.crystalList)/self.showCrystalNum) then
            num=SizeOfTable(self.crystalList)%self.showCrystalNum
            if num == 0 then
                num = self.showCrystalNum
            end
        end
        for i=1,num do
            local crystalVO = self.crystalList[idx*self.showCrystalNum+i]
            if crystalVO then
                local function selectedIcon(hd,fn,idx)
                    if self and self.tv2 and self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        if self and self.tv and self.tv:getScrollEnable()==false and self.tv:getIsScrolled()==true then
                            return
                        end
                        self:showEnergyCrystalInfo(idx,true)
                        local function callBack( ... )
                            local function callBack(fn,data)
                                local ret,sData=base:checkServerData(data)
                                if ret==true then
                                    if(sData.data.weapon)then
                                        superWeaponVoApi:formatData(sData.data.weapon)
                                        self.suitTb=nil
                                        print("-----dmj------crystalVO.id:"..crystalVO.id.."----crystalVO.btnType.."..crystalVO:getColorType())
                                        if crystalVO:getColorType()==1 and self.wearCrystalIcon1 then
                                            self.wearCrystalIcon1:removeFromParentAndCleanup(true)
                                            self.wearCrystalIcon1=nil
                                        elseif crystalVO:getColorType()==2 and self.wearCrystalIcon2 then
                                            self.wearCrystalIcon2:removeFromParentAndCleanup(true)
                                            self.wearCrystalIcon2=nil
                                        elseif crystalVO:getColorType()==3 and self.wearCrystalIcon3 then
                                            self.wearCrystalIcon3:removeFromParentAndCleanup(true)
                                            self.wearCrystalIcon3=nil
                                        end
                                        self:refreshWearCrystalInfo()
                                        self:doUserHandler()
                                        local recordPoint = self.tv2:getRecordPoint()
                                        self.tv2:reloadData()
                                        self.tv2:recoverToRecordPoint(recordPoint)
                                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("crystal_mosaic_success"),30)
                                    end
                                end
                            end
                            socketHelper:usecrystal(crystalVO.id,self.selectedWeaponId,callBack)
                        end
                        local function touch( ... )
                            -- body
                        end
                        local btnType = 1
                        if self.selectedWeaponId=="" then
                            btnType=-1
                        else
                            local slot = superWeaponCfg.weaponCfg[self.selectedWeaponId].slot
                            local index = 0
                            for k,v in pairs(slot) do
                                print("----mdj-----crystalVO:getColorType():"..crystalVO:getColorType().."--v:"..v.."---k:"..k)
                                if crystalVO:getColorType()==tonumber(v) then
                                    index=tonumber(k)
                                end
                            end
                            local list = superWeaponVoApi:getWeaponList()[self.selectedWeaponId].slots
                            if list["p"..index] then
                                local cVo = superWeaponVoApi:getCrystalVoByCid(list["p"..index])
                                if cVo then
                                    btnType=3
                                end
                            end
                        end
                        
                        smallDialog:showCrystalInfoDilaog(crystalVO:getNameAndLevel(),crystalVO:getIconSp(touch),crystalVO:getAtt(),self.layerNum+1,btnType,callBack,crystalVO:getLevel())
                    end
                end
                local iconSp=crystalVO:getIconSp(selectedIcon)
                iconSp:setAnchorPoint(ccp(0,0))
                local posX = 15+(15+iconSp:getContentSize().width)*(((i-1)%self.showCrystalNum))
                local posY = 10--+iconSp:getContentSize().height*math.floor((idx+1)/3)
                iconSp:setPosition(ccp(posX,posY))
                iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(iconSp)
                iconSp:setTag(idx*self.showCrystalNum+i)

                -- 等级
                local levelLb=GetTTFLabel(tostring(crystalVO:getLevelStr()),20)
                levelLb:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height-5))
                levelLb:setAnchorPoint(ccp(0.5,1));
                iconSp:addChild(levelLb)
                -- 数量
                local numLb=GetTTFLabel(tostring(crystalVO:getNumStr()),20)
                numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
                numLb:setAnchorPoint(ccp(1,0));
                iconSp:addChild(numLb)
                
                table.insert(self.allCrystalIconSp,iconSp)
            end
            
        end
        
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
end

function energyCrystalTab1Dialog:initAllBg()
    local temX = 30
    -- 超级武器名称背景
    self.superWeaponBigBg = CCSprite:create("public/superWeapon/weaponBg.jpg")
    self.superWeaponBigBg:setAnchorPoint(ccp(0,1))
    self.superWeaponBigBg:setPosition(ccp(24,self.superWeaponListBg:getPositionY()-self.superWeaponListBg:getContentSize().height))
    self.bgLayer:addChild(self.superWeaponBigBg)
    self.superWeaponBigBg:setScaleX(self.superWeaponListBg:getContentSize().width/self.superWeaponBigBg:getContentSize().width)
    self.superWeaponBigBg:setScaleY(0.9)
    if self.superweaponNameBgSp==nil then
        local function clickNameBgHandler( ... )
        end 
        self.superweaponNameBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("TrialSquadBox.png",CCRect(20, 20, 10, 10),clickNameBgHandler)
        self.superweaponNameBgSp:setAnchorPoint(ccp(0,1))
        self.superweaponNameBgSp:setContentSize(CCSizeMake(220,60))
        self.superweaponNameBgSp:setPosition(ccp(temX,self.superWeaponListBg:getPositionY()-self.superWeaponListBg:getContentSize().height-35))
        self.bgLayer:addChild(self.superweaponNameBgSp,1)
        self.superweaponNameBgSp:setVisible(false)
    end

    -- 帮助按钮信息
    local function showInfo()
        PlayEffect(audioCfg.mouseClick)

        local td=smallDialog:new()
        local tabStr = {" ",getlocal("crystal_mosaic_tip2"),getlocal("crystal_mosaic_tip1")," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(self.bgLayer:getContentSize().width-60,self.superWeaponListBg:getPositionY()-self.superWeaponListBg:getContentSize().height-infoItem:getContentSize().height/2))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoBtn,2)

    -- 套装属性按钮
    local function showSuitHandler( ... )
        if self.suitTb==nil then
            self.suitTb=superWeaponVoApi:getSuitList(self.selectedWeaponId)
        end            
        smallDialog:showCrystalSuitDilaog(self.suitTb,self.layerNum+1)
    
    end
    local suitSp = LuaCCSprite:createWithSpriteFrameName("sw_11.png",showSuitHandler)
    suitSp:setAnchorPoint(ccp(1,0.5))
    suitSp:setPosition(ccp(infoBtn:getPositionX()-30,infoBtn:getPositionY()))
    suitSp:setScale(infoItem:getContentSize().width*0.8/suitSp:getContentSize().width)
    self.bgLayer:addChild(suitSp,2)
    suitSp:setTouchPriority(-(self.layerNum-1)*20-4)
    self.suitSpPos=ccp(infoBtn:getPositionX()-60,infoBtn:getPositionY()-5)
    -- 超级武器背景
    if self.superweaponBgSp==nil then
        local function clickSuperWeaponBgHandler( ... )
            
        end
        self.superweaponBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("crystalBigBlueBg.png",CCRect(20, 20, 10, 10),clickSuperWeaponBgHandler)
        self.superweaponBgSp:setAnchorPoint(ccp(0,1))
        self.superweaponBgSp:setContentSize(CCSizeMake(220,190))
        self.superweaponBgSp:setPosition(ccp(temX,self.superweaponNameBgSp:getPositionY()-self.superweaponNameBgSp:getContentSize().height-30))
        self.bgLayer:addChild(self.superweaponBgSp,1)
    end

    -- 能量结晶背景，及连线
    local ballSp1 = CCSprite:createWithSpriteFrameName("crystalBall.png")
    ballSp1:setAnchorPoint(ccp(1,1))
    ballSp1:setPosition(ccp(self.superweaponBgSp:getPositionX()+self.superweaponBgSp:getContentSize().width-45,self.superweaponBgSp:getPositionY()))
    self.bgLayer:addChild(ballSp1,2)

    local ballSp2 = CCSprite:createWithSpriteFrameName("crystalBall.png")
    ballSp2:setAnchorPoint(ccp(1,1))
    ballSp2:setPosition(ccp(self.superweaponBgSp:getPositionX()+self.superweaponBgSp:getContentSize().width,self.superweaponBgSp:getPositionY()-85))
    self.bgLayer:addChild(ballSp2,2)

    local ballSp3 = CCSprite:createWithSpriteFrameName("crystalBall.png")
    ballSp3:setAnchorPoint(ccp(1,1))
    ballSp3:setPosition(ccp(self.superweaponBgSp:getPositionX()+self.superweaponBgSp:getContentSize().width,self.superweaponBgSp:getPositionY()-130))
    self.bgLayer:addChild(ballSp3,2)

    -- 线
    local lineSp1 = CCSprite:createWithSpriteFrameName("crystalLine1.png")
    lineSp1:setAnchorPoint(ccp(0,0))
    lineSp1:setPosition(ccp(self.superweaponBgSp:getPositionX()+self.superweaponBgSp:getContentSize().width-65,self.superweaponBgSp:getPositionY()-20))
    self.bgLayer:addChild(lineSp1,2)

    local lineSp2 = CCSprite:createWithSpriteFrameName("crystalLine2.png")
    lineSp2:setAnchorPoint(ccp(0,0))
    lineSp2:setPosition(ccp(self.superweaponBgSp:getPositionX()+self.superweaponBgSp:getContentSize().width-15,self.superweaponBgSp:getPositionY()-104))
    self.bgLayer:addChild(lineSp2,2)

    local lineSp3 = CCSprite:createWithSpriteFrameName("crystalLine3.png")
    lineSp3:setAnchorPoint(ccp(0,0))
    lineSp3:setPosition(ccp(self.superweaponBgSp:getPositionX()+self.superweaponBgSp:getContentSize().width-8,self.superweaponBgSp:getPositionY()-149))
    self.bgLayer:addChild(lineSp3,2)

    -- 连接器
    local connectorSp1=CCSprite:createWithSpriteFrameName("alienTechConnector2.png")
    connectorSp1:setAnchorPoint(ccp(0,0.5))
    connectorSp1:setPosition(ccp(lineSp1:getPositionX()+lineSp1:getContentSize().width-10,lineSp1:getPositionY()+lineSp1:getContentSize().height-4))
    self.bgLayer:addChild(connectorSp1,3)

    local connectorSp2=CCSprite:createWithSpriteFrameName("alienTechConnector2.png")
    connectorSp2:setAnchorPoint(ccp(0,0.5))
    connectorSp2:setPosition(ccp(lineSp2:getPositionX()+lineSp2:getContentSize().width-6,lineSp2:getPositionY()+lineSp2:getContentSize().height-4))
    self.bgLayer:addChild(connectorSp2,3)
    connectorSp2:setRotation(-90)

    local connectorSp3=CCSprite:createWithSpriteFrameName("alienTechConnector2.png")
    connectorSp3:setAnchorPoint(ccp(0,0.5))
    connectorSp3:setPosition(ccp(lineSp3:getPositionX()+lineSp3:getContentSize().width-5,lineSp3:getPositionY()+lineSp3:getContentSize().height-4))
    self.bgLayer:addChild(connectorSp3,3)
    connectorSp3:setRotation(-90)

    -- icon背景
    local function clickIconBgHandler(hd,fn,idx)
        if self.selectedIdx and self.selectedIdx==idx then
            return
        end
        self.selectedIdx=idx
        local function funcA(a,b)
            
            if a and b then
                if a:getColorType()==idx and b:getColorType()==idx  then
                    if a:getLevel()==b:getLevel() then
                        return a:getSortId()>b:getSortId()
                    else
                        return a:getLevel()>b:getLevel()
                    end
                else
                    if a:getColorType()==idx then
                        return a:getColorType()*10>b:getColorType()
                    elseif b:getColorType()==idx then
                        return a:getColorType()>b:getColorType()*10
                    else
                        if a:getLevel()==b:getLevel() then
                            return a:getSortId()>b:getSortId()
                        else
                            return a:getLevel()>b:getLevel()
                        end
                    end
                end
            end    
        end
        if SizeOfTable(self.crystalList) > 0 then
            if self.crystalSortList==nil then
                self.crystalSortList={}
            end
            if self.crystalSortList[idx]==nil then
                self.crystalSortList[idx]=G_clone(self.crystalList)
                table.sort(self.crystalSortList[idx],funcA)
            end
            self.crystalList=self.crystalSortList[idx]
            self.allCrystalIconSp={}
            local recordPoint = self.tv2:getRecordPoint()
            self.tv2:reloadData()
            self.tv2:recoverToRecordPoint(recordPoint)
        end
        
    end

    -- 三个结晶容器坐标
    self.crystalIconPos1=ccp(connectorSp1:getPositionX()+connectorSp1:getContentSize().width+50,connectorSp1:getPositionY()-50)
    self.crystalIconPos2=ccp(connectorSp2:getPositionX()+connectorSp2:getContentSize().width-17,connectorSp2:getPositionY()+10)
    self.crystalIconPos3=ccp(connectorSp3:getPositionX()+connectorSp3:getContentSize().width-17,connectorSp3:getPositionY()+10)


    self.crystalIcon1=CCSprite:createWithSpriteFrameName("alienTechBg2.png")
    self.crystalIcon1:setAnchorPoint(ccp(0.5,0))
    -- self.crystalIcon1:setAnchorPoint(ccp(0,0.5))
    self.crystalIcon1:setPosition(self.crystalIconPos1)
    self.bgLayer:addChild(self.crystalIcon1,4)
    self.crystalIcon1:setScale(0.9)
    self.crystalIcon1:setTag(1)

    local crystalSp1 =LuaCCSprite:createWithSpriteFrameName("crystalIconRedBg.png",clickIconBgHandler)
    crystalSp1:setAnchorPoint(ccp(0.5,0.5))
    crystalSp1:setPosition(ccp(self.crystalIcon1:getContentSize().width/2,self.crystalIcon1:getContentSize().height/2))
    crystalSp1:setScale((self.crystalIcon1:getContentSize().width-40)/crystalSp1:getContentSize().width)
    self.crystalIcon1:addChild(crystalSp1)
    crystalSp1:setTouchPriority(-(self.layerNum-1)*20-4)
    crystalSp1:setTag(1)

    self.crystalIcon2=CCSprite:createWithSpriteFrameName("alienTechBg2.png")
    self.crystalIcon2:setAnchorPoint(ccp(0.5,0))
    self.crystalIcon2:setPosition(self.crystalIconPos2)
    self.bgLayer:addChild(self.crystalIcon2,4)
    self.crystalIcon2:setScale(0.9)
    self.crystalIcon2:setTag(2)

    

    local crystalSp2 =LuaCCSprite:createWithSpriteFrameName("crystalIconYellowBg.png",clickIconBgHandler)
    crystalSp2:setAnchorPoint(ccp(0.5,0.5))
    crystalSp2:setPosition(ccp(self.crystalIcon2:getContentSize().width/2,self.crystalIcon2:getContentSize().height/2))
    crystalSp2:setScale((self.crystalIcon2:getContentSize().width-40)/crystalSp2:getContentSize().width)
    self.crystalIcon2:addChild(crystalSp2)
    crystalSp2:setTouchPriority(-(self.layerNum-1)*20-4)
    crystalSp2:setTag(2)


    self.crystalIcon3=CCSprite:createWithSpriteFrameName("alienTechBg2.png")
    self.crystalIcon3:setAnchorPoint(ccp(0.5,0))
    self.crystalIcon3:setPosition(self.crystalIconPos3)
    self.bgLayer:addChild(self.crystalIcon3,4)
    self.crystalIcon3:setScale(0.9)

    local crystalSp3 =LuaCCSprite:createWithSpriteFrameName("crystalIconBlueBg.png",clickIconBgHandler)
    crystalSp3:setAnchorPoint(ccp(0.5,0.5))
    crystalSp3:setPosition(ccp(self.crystalIcon3:getContentSize().width/2,self.crystalIcon3:getContentSize().height/2))
    crystalSp3:setScale((self.crystalIcon3:getContentSize().width-40)/crystalSp3:getContentSize().width)
    self.crystalIcon3:addChild(crystalSp3)
    self.crystalIcon3:setTag(3)
    crystalSp3:setTag(3)
    crystalSp3:setTouchPriority(-(self.layerNum-1)*20-4)


    

    -- 当前结晶的详细信息区域
    local function clickBottomBgHandler( ... )
    end
    local bottomBgSpH = self.superweaponBgSp:getPositionY()-self.superweaponBgSp:getContentSize().height-50
    -- self.bottomBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),clickBottomBgHandler)
    self.bottomBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),clickBottomBgHandler)
    self.bottomBgSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,bottomBgSpH))
    self.bottomBgSp:setPosition(ccp(G_VisibleSizeWidth/2,35))
    self.bottomBgSp:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(self.bottomBgSp,4)

    self:doUserHandler()
    local function callBack2(...)
       return self:eventHandler2(...)
    end
    local hd= LuaEventHandler:createHandler(callBack2)
    local height=0;
    self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,bottomBgSpH-20),nil)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setPosition(ccp(0,9))
    self.tv2:setAnchorPoint(ccp(0,0))
    self.bottomBgSp:addChild(self.tv2)


end

-- 显示超级武器的能量结晶
function energyCrystalTab1Dialog:showSuperWeaponInfo(index)
    if self.weaponList[index] and self.selectedWeaponId==self.weaponList[index].id then
        return
    end
    self.suitTb=nil
    self.selectedWeaponId=self.weaponList[index].id
    local maxFloor = superWeaponVoApi:getSWChallengeMaxFloor()
    local nameLbSize2 = 16
    local widthSub = 6
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        nameLbSize2 =20
        widthSub = 0
    end
    if superWeaponCfg and superWeaponCfg.weaponCfg and superWeaponCfg.weaponCfg[self.selectedWeaponId] and superWeaponCfg.weaponCfg[self.selectedWeaponId].slot then
        local slot = superWeaponCfg.weaponCfg[self.selectedWeaponId].slot
        for k,v in pairs(slot) do
            self["crystalIcon"..v]:setPosition(self["crystalIconPos"..k])
            local need = superWeaponCfg.unlockCrystal[k]
            if need<=maxFloor then
                if self["unlockLb"..v]~=nil then
                    self["unlockLb"..v]:setString("")
                end
            else
                if self["unlockLb"..v]==nil then
                    self["unlockLb"..v]=GetTTFLabelWrap(getlocal("unlock_crystal_desc",{need}),nameLbSize2,CCSizeMake(self.crystalIcon1:getContentSize().width*0.7-widthSub, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    self["crystalIcon"..v]:addChild(self["unlockLb"..v])
                    self["unlockLb"..v]:setAnchorPoint(ccp(0.5,0.5))
                    self["unlockLb"..v]:setPosition(ccp(self["crystalIcon"..v]:getContentSize().width/2+10,self["crystalIcon"..v]:getContentSize().height/2))
                else
                    self["unlockLb"..v]:setString(getlocal("unlock_crystal_desc",{need}))
                end
            end
        end
    end


    -- if(self and self.selectedSp and self.weaponIconList[index])then
    --     self.selectedSp:removeFromParentAndCleanup(false)
    --     self.selectedSp:setPosition(getCenterPoint(self.weaponIconList[index]))
    --     self.weaponIconList[index]:addChild(self.selectedSp)
    -- end
    -- 选中状态
    for k,v in pairs(self.weaponIconList) do
        local child=tolua.cast(v:getChildByTag(99),"LuaCCScale9Sprite")
        if k==index then
            v:setScale(self.cellHeight/v:getContentSize().width)
            child:setVisible(false)
        else
            v:setScale(100/v:getContentSize().width)
            child:setVisible(true)
        end
    end

    -- 超级武器名称，等级
    local data=self.weaponList[index]
    local superWeaponName=getlocal(data:getConfigData("name"))
    local lvStr=getlocal("fightLevel",{data.lv})
    local nameLbSize = 24
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        nameLbSize =24
    end

    local posX,posY=self.superweaponNameBgSp:getPosition()
    if self.superWeaponNameLb == nil then
        self.superWeaponNameLb=GetTTFLabelWrap(superWeaponName,nameLbSize,CCSizeMake(self.superweaponNameBgSp:getContentSize().width-6,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        self.superWeaponNameLb:setPosition(110+30,posY)
        self.superWeaponNameLb:setAnchorPoint(ccp(0.5,1));
        -- self.superweaponNameBgSp:addChild(self.superWeaponNameLb)
        self.bgLayer:addChild(self.superWeaponNameLb)

        self.lvLb=GetTTFLabel(lvStr,24)
        self.bgLayer:addChild(self.lvLb)
        self.lvLb:setAnchorPoint(ccp(0.5,1))
    else
        self.superWeaponNameLb:setString(superWeaponName)
        self.lvLb:setString(lvStr)
    end
    self.lvLb:setPosition(140,posY-self.superWeaponNameLb:getContentSize().height)
    self.superWeaponNameLb:setColor(superWeaponVoApi:getWeaponColorByQuality(data.id))

    -- 超级武器icon
    if self and self.selectedWeaponIconSp then
        self.selectedWeaponIconSp:removeFromParentAndCleanup(true)
        self.selectedWeaponIconSp=nil
    end
    if self.selectedWeaponIconSp==nil  and self.superweaponBgSp then
        local function onClick( ... )
           superWeaponVoApi:showWeaponDetailDialog(data.id,self.layerNum + 1)
        end
        self.selectedWeaponIconSp = LuaCCSprite:createWithSpriteFrameName(data:getConfigData("bigIcon"),onClick)
        self.selectedWeaponIconSp:setScaleX((self.superweaponBgSp:getContentSize().width-5)/self.selectedWeaponIconSp:getContentSize().width)
        self.selectedWeaponIconSp:setScaleY((self.superweaponBgSp:getContentSize().height-5)/self.selectedWeaponIconSp:getContentSize().height)
        self.selectedWeaponIconSp:setAnchorPoint(ccp(0.5,0.5))
        self.selectedWeaponIconSp:setPosition(ccp(self.superweaponBgSp:getContentSize().width/2,self.superweaponBgSp:getContentSize().height/2))
        self.superweaponBgSp:addChild(self.selectedWeaponIconSp)
        self.selectedWeaponIconSp:setTouchPriority(-(self.layerNum-1)*20-4)
    end

    if self.wearCrystalIcon1 then
        self.wearCrystalIcon1:removeFromParentAndCleanup(true)
        self.wearCrystalIcon1=nil

    end
    if self.wearCrystalIcon2 then
        self.wearCrystalIcon2:removeFromParentAndCleanup(true)
        self.wearCrystalIcon2=nil

    end
    if self.wearCrystalIcon3 then
        self.wearCrystalIcon3:removeFromParentAndCleanup(true)
        self.wearCrystalIcon3=nil

    end

    self:refreshWearCrystalInfo(index)

end

function energyCrystalTab1Dialog:refreshWearCrystalInfo(index)
    local siloList
    if index ==nil then
        siloList=superWeaponVoApi:getWeaponList()[self.selectedWeaponId].slots
    else
        siloList=self.weaponList[index].slots
    end
    
    if SizeOfTable(siloList)>0 then
        for k,v in pairs(siloList) do
            local crystalVO = superWeaponVoApi:getCrystalVoByCid(v)
            if crystalVO then
                local key = tonumber(RemoveFirstChar(k))
                local rtype = superWeaponCfg.weaponCfg[self.selectedWeaponId].slot[key]
                local function showCrystalInfo(hd,fn,idx)
                    if self and self.tv2 and self.tv2:getScrollEnable()==true then
                    -- if self and self.tv2 and self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
                        local function touch( ... )
                            
                        end 
                        local function callBack( ... )
                           local function callBack2(fn,data)
                                local ret,sData=base:checkServerData(data)
                                if ret==true then
                                    if(sData.data.weapon)then
                                        superWeaponVoApi:formatData(sData.data.weapon)
                                        if self["wearCrystalIcon"..rtype] then
                                            self["wearCrystalIcon"..rtype]:removeFromParentAndCleanup(true)
                                            self["wearCrystalIcon"..rtype]=nil
                                        end
                                        -- if idx==1 and self.wearCrystalIcon1 then
                                        --     self.wearCrystalIcon1:removeFromParentAndCleanup(true)
                                        --     self.wearCrystalIcon1=nil
                                        -- elseif idx==2 and self.wearCrystalIcon2 then
                                        --     self.wearCrystalIcon2:removeFromParentAndCleanup(true)
                                        --     self.wearCrystalIcon2=nil
                                        -- elseif idx==3 and self.wearCrystalIcon3 then
                                        --     self.wearCrystalIcon3:removeFromParentAndCleanup(true)
                                        --     self.wearCrystalIcon3=nil
                                        -- end
                                        self:refreshWearCrystalInfo()
                                        self:doUserHandler()
                                        local recordPoint = self.tv2:getRecordPoint()
                                        self.tv2:reloadData()
                                        self.tv2:recoverToRecordPoint(recordPoint)
                                        self.suitTb=nil
                                    end
                                end
                            end
                            socketHelper:uncrystal("p"..(idx),self.selectedWeaponId,callBack2)
                        end
                        local list = superWeaponVoApi:getWeaponList()[self.selectedWeaponId].slots
                        if list["p"..idx] then
                            local cVo = superWeaponVoApi:getCrystalVoByCid(list["p"..idx])
                            if cVo then
                                smallDialog:showCrystalInfoDilaog(cVo:getNameAndLevel(),cVo:getIconSp(touch),cVo:getAtt(),self.layerNum+1,2,callBack,cVo:getLevel())
                            end
                        end
                    end
                end
                
                if self["wearCrystalIcon"..rtype] == nil then
                    self["wearCrystalIcon"..rtype]=crystalVO:getIconSp(showCrystalInfo)
                    self["wearCrystalIcon"..rtype]:setAnchorPoint(ccp(0.5,0.5))
                    self["wearCrystalIcon"..rtype]:setPosition(ccp(self["crystalIcon"..rtype]:getContentSize().width/2,self["crystalIcon"..rtype]:getContentSize().height/2))
                    self["wearCrystalIcon"..rtype]:setScale((self["crystalIcon"..rtype]:getContentSize().width-40)/self["wearCrystalIcon"..rtype]:getContentSize().width)
                    self["crystalIcon"..rtype]:addChild(self["wearCrystalIcon"..rtype])
                    self["wearCrystalIcon"..rtype]:setTouchPriority(-(self.layerNum-1)*20-5)
                    self["wearCrystalIcon"..rtype]:setTag(key)
                    local levelLb=GetTTFLabel(tostring(crystalVO:getLevelStr()),20)
                    if(levelLb)then
                        levelLb:setPosition(self["wearCrystalIcon"..rtype]:getContentSize().width/2,self["wearCrystalIcon"..rtype]:getContentSize().width-15)
                        self["wearCrystalIcon"..rtype]:addChild(levelLb)
                    end
                end


                -- if k=="p1" then
                --     if self.wearCrystalIcon1 == nil then
                --         self.wearCrystalIcon1=crystalVO:getIconSp(showCrystalInfo)
                --         self.wearCrystalIcon1:setAnchorPoint(ccp(0.5,0.5))
                --         self.wearCrystalIcon1:setPosition(ccp(self.crystalIcon1:getContentSize().width/2,self.crystalIcon1:getContentSize().height/2))
                --         self.wearCrystalIcon1:setScale((self.crystalIcon1:getContentSize().width-40)/self.wearCrystalIcon1:getContentSize().width)
                --         self.crystalIcon1:addChild(self.wearCrystalIcon1)
                --         self.wearCrystalIcon1:setTouchPriority(-(self.layerNum-1)*20-5)
                --         self.wearCrystalIcon1:setTag(1)

                --     end
                    
                -- elseif k=="p2" then
                --     if self.wearCrystalIcon2 == nil then
                --         self.wearCrystalIcon2=crystalVO:getIconSp(showCrystalInfo)
                --         self.wearCrystalIcon2:setAnchorPoint(ccp(0.5,0.5))
                --         self.wearCrystalIcon2:setPosition(ccp(self.crystalIcon2:getContentSize().width/2,self.crystalIcon2:getContentSize().height/2))
                --         self.wearCrystalIcon2:setScale((self.crystalIcon2:getContentSize().width-40)/self.wearCrystalIcon2:getContentSize().width)
                --         self.crystalIcon2:addChild(self.wearCrystalIcon2)
                --         self.wearCrystalIcon2:setTag(2)
                --         self.wearCrystalIcon2:setTouchPriority(-(self.layerNum-1)*20-5)
                --     end
                   
                -- elseif k=="p3" then
                --     if self.wearCrystalIcon3 == nil then
                --         self.wearCrystalIcon3=crystalVO:getIconSp(showCrystalInfo)
                --         self.wearCrystalIcon3:setAnchorPoint(ccp(0.5,0.5))
                --         self.wearCrystalIcon3:setPosition(ccp(self.crystalIcon3:getContentSize().width/2,self.crystalIcon3:getContentSize().height/2))
                --         self.wearCrystalIcon3:setScale((self.crystalIcon3:getContentSize().width-40)/self.wearCrystalIcon3:getContentSize().width)
                --         self.crystalIcon3:addChild(self.wearCrystalIcon3)  
                --         self.wearCrystalIcon3:setTag(3)  
                --         self.wearCrystalIcon3:setTouchPriority(-(self.layerNum-1)*20-5)
                --     end  
                   
                -- end
            end
        end
        local result,ifHasSuitEffect=superWeaponVoApi:getSuitList(self.selectedWeaponId)
        print("----dmj-----self.selectedWeaponId:",self.selectedWeaponId)
        if ifHasSuitEffect then
            if self["lightSp"]==nil then
                self["lightSp"] = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                self["lightSp"]:setAnchorPoint(ccp(0.5,0.5))
                self["lightSp"]:setScale(0.6)
                self["lightSp"]:setPosition(self.suitSpPos)
                self.bgLayer:addChild(self["lightSp"],1)
            else
                if self then
                    self["lightSp"]:setVisible(true)
                end
            end
            
        else
            if self and self["lightSp"] then
                self["lightSp"]:setVisible(false)
            end
        end
    else
        if self and self["lightSp"] then
            self["lightSp"]:setVisible(false)
        end
    end
end

function energyCrystalTab1Dialog:refreshWeaponlist()
    
    self.weaponList={}
    
    for k,v in pairs(superWeaponVoApi:getWeaponList()) do
        table.insert(self.weaponList,v)
    end
    local function sortFunc(a,b)
        local id1=tonumber(string.sub(a.id,2))
        local id2=tonumber(string.sub(b.id,2))
        return id1<id2
    end
    table.sort(self.weaponList,sortFunc)

    -- 展示列表，获得未获得的全展示
    self.newShowList={}
    local function isExist(weaponList,id)
        for k,v in pairs(weaponList) do
            if v.id==id then
                return true
            end
        end
        return false
    end
    for k,v in pairs(superWeaponCfg.weaponCfg) do
        if isExist(self.weaponList,k) then
            table.insert(self.newShowList,{id=k,sid=v.sid})
        else
            table.insert(self.newShowList,{id=k,sid=v.sid+1000})
        end
    end
    local function sortShowList(a,b)
        return a.sid<b.sid
    end
    table.sort(self.newShowList, sortShowList)

    if(self and self.tv)then   
        self.weaponIconList={}
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

-- 显示能量结晶的详细信息
function energyCrystalTab1Dialog:showEnergyCrystalInfo(index,ifRefresh)
    if self.selectedCrystalIndex==index then
        return
    end
    local crystalVO = self.crystalList[index]
    if crystalVO then
        self.selectedCrystalIndex=index
        
    end

end

function energyCrystalTab1Dialog:refreshData( ... )
    if self and self.tv2 then
        self:doUserHandler()
        local recordPoint = self.tv2:getRecordPoint()
        self.tv2:reloadData()
        self.tv2:recoverToRecordPoint(recordPoint)
    end
end

--用户处理特殊需求,没有可以不写此方法
function energyCrystalTab1Dialog:doUserHandler()
    self.allCrystalIconSp={}
    self.crystalSortList=nil
    self.selectedIdx=nil
    self.crystalList=superWeaponVoApi:getAllEnergycrastal()
end

function energyCrystalTab1Dialog:tick()

end

function energyCrystalTab1Dialog:dispose()
    eventDispatcher:removeEventListener("superweapon.data.info",self.eventListener)
    self.tipSp=nil
    self.crystalList=nil--能量结晶列表
    self.weaponList={}
    self.superWeaponListBg=nil--超级武器列表背景框
    self.superWeaponNameLb=nil--超级武器名称文本
    self.selectedWeaponId=""
    self.selectedCrystalIndex=-1--当前选中的结晶的index
    self.wearCrystalIcon1=nil--穿戴的结晶1
    self.wearCrystalIcon2=nil
    self.wearCrystalIcon3=nil
    self.crystalIconPos1=nil
    self.crystalIconPos2=nil
    self.crystalIconPos3=nil
    self.allCrystalIconSp={}
    if self.bgLayer ~=nil then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil;
    end
    spriteController:removePlist("public/swYouhuaUI.plist")
    spriteController:removeTexture("public/swYouhuaUI.png")
end




