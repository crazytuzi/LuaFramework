ltzdzActiveTankSmallDialog=smallDialog:new()

function ltzdzActiveTankSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
    nc.allTabs={}
	return nc
end

-- alreadyUseIdTb 已经激活的坦克id 20005,30005
function ltzdzActiveTankSmallDialog:showTankList(layerNum,istouch,isuseami,callBack,titleStr,alreadyUseIdTb)
	local sd=ltzdzActiveTankSmallDialog:new()
    sd:initTankList(layerNum,istouch,isuseami,callBack,titleStr,alreadyUseIdTb)
    return sd
end

function ltzdzActiveTankSmallDialog:initTankList(layerNum,istouch,isuseami,pCallBack,titleStr,alreadyUseIdTb)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum


    base:removeFromNeedRefresh(self) --停止刷新

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

     local function touchLuaSpr()
        -- PlayEffect(audioCfg.mouseClick)
        -- return self:close()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local bgSize=CCSizeMake(600,800)

    local function closeFunc()
        self:close()
    end
    local dialogBg=G_getNewDialogBg(bgSize,titleStr,25,nil,self.layerNum,true,closeFunc,G_ColorBlue)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.bgLayer=dialogBg

    --  普通坦克和精英坦克的页签
    local function touchItem(idx)
        
        if idx==self.selectedTabIndex then
            return
        end
        PlayEffect(audioCfg.mouseClick)
        self.selectedTabIndex=idx
        return self:tabClick(idx)
    end
    local commonItem = CCMenuItemImage:create("page_dark.png", "page_light.png","page_light.png")
    commonItem:setTag(1)
    commonItem:registerScriptTapHandler(touchItem)
    commonItem:setEnabled(false)
    self.allTabs[1]=commonItem
    local commonMenu=CCMenu:createWithItem(commonItem)
    commonMenu:setPosition(ccp(30+commonItem:getContentSize().width/2,self.bgLayer:getContentSize().height-110))
    commonMenu:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(commonMenu,2)

    local sp1=CCSprite:createWithSpriteFrameName("picked_icon2.png")
    commonItem:addChild(sp1,2)
    sp1:setPosition(commonItem:getContentSize().width/2,commonItem:getContentSize().height/2)

    local pickedItem=CCMenuItemImage:create("page_dark.png", "page_light.png","page_light.png")
    pickedItem:setTag(2)
    pickedItem:registerScriptTapHandler(touchItem)
    self.allTabs[2]=pickedItem
    local pickedMenu=CCMenu:createWithItem(pickedItem)
    pickedMenu:setPosition(ccp(self.bgLayer:getContentSize().width-30-pickedItem:getContentSize().width/2,self.bgLayer:getContentSize().height-110))
    pickedMenu:setTouchPriority(-(layerNum-1)*20-4)
    self.bgLayer:addChild(pickedMenu,2)

    local sp2=CCSprite:createWithSpriteFrameName("picked_icon2.png")
    pickedItem:addChild(sp2,2)
    sp2:setPosition(pickedItem:getContentSize().width/2,pickedItem:getContentSize().height/2)

    local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
    sp2:addChild(pickedIcon)
    pickedIcon:setPosition(sp2:getContentSize().width-10,sp2:getContentSize().height/2)
    pickedIcon:setScale(0.9)

    local function isUsedFunc(id)
        for k,v in pairs(alreadyUseIdTb) do
            if tonumber(id)==tonumber(v) then
                return true
            end
        end
        return false
    end

    local keyTable,tankTable=tankVoApi:getAllTanksInByType(2)
    self.tankTable=tankTable
    if ltzdzVoApi:isQualifying() then
        self.keyTable=G_clone(keyTable)
    else
        self.keyTable=G_clone(ltzdzVoApi:getCanActiveTankBySeg())
    end


    -- self.keyTable=G_clone(keyTable)

    self.keyTable1={}
    self.keyTable2={}

    local ltzdzWarCfg=ltzdzVoApi:getWarCfg()
    local needNum=ltzdzWarCfg.exchange or 20

    local num1=0 -- 普通坦克
    local num2=0 -- 精英坦克
    for i=#self.keyTable,1,-1 do
        local id=self.keyTable[i].key
        -- print("idididididid",id)
        if isUsedFunc(id) then
            table.remove(self.keyTable,i)
        else
            self.keyTable[i].index=i -- 添加index 用于排序
            local haveNum=self:getTankNum(id)
            if haveNum==0 then -- index 大于10000的是不能兑换的
                self.keyTable[i].index=i+100000
            elseif haveNum<needNum then -- index 大于10000的是不能兑换的
                self.keyTable[i].index=i+10000
            end
            if self.keyTable[i].key==G_pickedList(self.keyTable[i].key) then
                num1=num1+1
                self.keyTable1[num1]=self.keyTable[i]
            else
                num2=num2+1
                self.keyTable2[num2]=self.keyTable[i]
            end
        end
    end

    local function sortFunc(a,b)
        return a.index<b.index
    end
    table.sort(self.keyTable1,sortFunc)
    table.sort(self.keyTable2,sortFunc)

    -- for k,v in pairs(self.keyTable1) do
    --     print(k,v)
    --     for kk,vv in pairs(v) do
    --         print(kk,vv)
    --     end
    -- end


    self.selectedTabIndex=1
    self:changeTb(self.selectedTabIndex)
    self.cellHeight=230
    self.cellWidth=600
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,440),nil)
    self.tv:setTableViewTouchPriority((-(self.layerNum-1)*20-3))
    self.tv:setPosition(ccp(0,200))
    self.bgLayer:addChild(self.tv,3)
    self.tv:setMaxDisToBottomOrTop(120)

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("greenBlackBg2.png",CCRect(10,10,12,12),function ()end)
    tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,470))
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setPosition(self.bgLayer:getContentSize().width/2,190)
    self.bgLayer:addChild(tvBg)
    self.tvBg=tvBg

    G_addForbidForSmallDialog2(dialogBg,tvBg,-(self.layerNum-1)*20-3,nil,3)


    local noTankLb = GetTTFLabelWrap("",25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.tvBg:addChild(noTankLb)
    noTankLb:setPosition(self.tvBg:getContentSize().width/2, self.tvBg:getContentSize().height/2)
    noTankLb:setTag(110)
    noTankLb:setVisible(false)
    self:setNoTankLb()

    local noTankLb=tolua.cast(self.tvBg:getChildByTag(110),"CCLabelTTF")
    local noTankStr
    if self.selectedTabIndex==1 then
        noTankStr=getlocal("noCommonTank")
    else
        noTankStr=getlocal("noEliteTank")
    end

    local descLb=GetTTFLabelWrap(getlocal("ltzdz_active_tank_des2"),25,CCSizeMake(self.bgLayer:getContentSize().width - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.bgLayer:addChild(descLb)
    descLb:setPosition(self.bgLayer:getContentSize().width/2,150)
    descLb:setColor(G_ColorYellowPro)

    if ltzdzVoApi:isQualifying() then
        descLb:setVisible(false)
    end

    local btnScale=1
    local btnlbSize=25
    local btnY=30+40
    local function touchOkFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if pCallBack and self.selectTankId then
            local ltzdzWarCfg=ltzdzVoApi:getWarCfg()
            local needNum=ltzdzWarCfg.exchange or 20
            pCallBack(self.selectTankId,needNum)
        end
        self:close()
    end
    local okItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchOkFunc,nil,getlocal("confirm"),btnlbSize/btnScale)
    local okBtn=CCMenu:createWithItem(okItem)
    okBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    okItem:setScale(btnScale)
    okBtn:setPosition(self.bgLayer:getContentSize().width/2+125,btnY)
    self.bgLayer:addChild(okBtn)

    local function touchCancelFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- self:close()
        ltzdzVoApi:showCheckTankActiveDialog(self.layerNum+1)
    end
    local cancelItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchCancelFunc,nil,getlocal("ltzdz_active_detail"),btnlbSize/btnScale)
    local cancelBtn=CCMenu:createWithItem(cancelItem)
    cancelBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    cancelItem:setScale(btnScale)
    cancelBtn:setPosition(self.bgLayer:getContentSize().width/2-125,btnY)
    self.bgLayer:addChild(cancelBtn)


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

function ltzdzActiveTankSmallDialog:getTankNum(id)
    local tankInfo=self.tankTable[id] or {}
    return tankInfo[1] or 0
end

function ltzdzActiveTankSmallDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(self.cellWidth,self.hei*self.cellHeight)
       return tmpSize
   elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        

        if self.keyTable and SizeOfTable(self.keyTable)==0 then
            return cell
        end

        local totalHeight=self.hei*self.cellHeight

        for k,v in pairs(self.keyTable) do
            local bgWidth -- 宽度
            local bgHeight -- 高度

            local numId=k

            local remainder=numId%3 -- 余数
            if remainder==1 then
                bgWidth=self.cellWidth/2-170
            elseif remainder==2 then
                bgWidth=self.cellWidth/2
            else
                bgWidth=self.cellWidth/2+170
            end

            local bussess=math.ceil(numId/3)

            bgHeight=totalHeight-(bussess-1)*self.cellHeight-self.cellHeight/2

            local index=v.index
            local key=v.key

            local backSprie
            local tankIcon
            local function cellClick(hd,fn,tag)
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end

                    if tag==self.selectTankId then
                        return
                    end
                    PlayEffect(audioCfg.mouseClick)

                    self.selectTankId=tag
                    -- local child=tolua.cast(cell:getChildByTag(tag),"LuaCCScale9Sprite")
                    -- if self.selectSp and child then
                        self.selectSp:setPosition(backSprie:getPositionX(),backSprie:getPositionY()+(backSprie:getContentSize().height/2-tankIcon:getContentSize().height/2))
                    -- end
                end
            end

            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
            backSprie:setContentSize(CCSizeMake(150, self.cellHeight-30))
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:setPosition(bgWidth,bgHeight)
            -- print("key",key)
            backSprie:setTag(tonumber(key))
            cell:addChild(backSprie,1)
            backSprie:setOpacity(0)

            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
            lineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70,lineSp:getContentSize().height))
            lineSp:setPosition(ccp(self.cellWidth/2,bgHeight-self.cellHeight/2))
            cell:addChild(lineSp)

            local backSize=backSprie:getContentSize()


            local function showInfoHandler(hd,fn,idx)
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    local id = G_pickedList(key)
                    tankInfoDialog:create(nil,tonumber(id),self.layerNum+1)
                end
            end
            local tipItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfoHandler,nil,nil,nil)
            local spScale=0.7
            tipItem:setScale(spScale)
            local tipMenu = CCMenu:createWithItem(tipItem)
            tipMenu:setPosition(bgWidth+backSize.width/2-10-tipItem:getContentSize().width/2*spScale,bgHeight+backSize.height/2-10-tipItem:getContentSize().height/2*spScale)
            tipMenu:setTouchPriority(-(self.layerNum-1)*20-2)
            cell:addChild(tipMenu,3)

            tankIcon=tankVoApi:getTankIconSp(key)--CCSprite:createWithSpriteFrameName(tankCfg[key].icon)
            backSprie:addChild(tankIcon)
            tankIcon:setPosition(backSize.width/2,backSize.height-tankIcon:getContentSize().height/2)

            if k==1 and index<10000 then
                local function nilFunc()
                end
                self.selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("newSelectKuang.png",CCRect(30, 30, 1, 1),nilFunc)
                cell:addChild(self.selectSp,2)
                self.selectSp:setPosition(backSprie:getPositionX(),backSprie:getPositionY()+(backSize.height/2-tankIcon:getContentSize().height/2))
                self.selectSp:setContentSize(tankIcon:getContentSize())
                self.selectTankId=key
            end

            local nameLb=GetTTFLabelWrap(getlocal(tankCfg[key].name),22,CCSizeMake(24*7,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            nameLb:setAnchorPoint(ccp(0.5,0.5));
            nameLb:setPosition(ccp(backSize.width/2,30));
            backSprie:addChild(nameLb,2)

            local ltzdzWarCfg=ltzdzVoApi:getWarCfg()
            local needNum=ltzdzWarCfg.exchange or 20
            local haveNum=self:getTankNum(key)

            local function nilFunc()
            end
            local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
            -- nameBg:setTouchPriority(-(self.layerNum-1)*20-2)
            nameBg:setContentSize(CCSizeMake(tankIcon:getContentSize().width-10,40))
            nameBg:setScaleY(30/nameBg:getContentSize().height)
            tankIcon:addChild(nameBg)
            nameBg:setAnchorPoint(ccp(0.5,0))
            nameBg:setPosition(tankIcon:getContentSize().width/2,5)

            local numLb1=GetTTFLabel(haveNum,22)
            tankIcon:addChild(numLb1)
            numLb1:setPositionY(15+5)
            numLb1:setColor(G_ColorYellowPro)
            local numLb2=GetTTFLabel("/" .. needNum,22)
            tankIcon:addChild(numLb2)
            numLb2:setPositionY(15+5)
            G_setchildPosX(tankIcon,numLb1,numLb2)

            if self.selectedTabIndex==2 then
                local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                tankIcon:addChild(pickedIcon)
                pickedIcon:setPosition(tankIcon:getContentSize().width*0.7,tankIcon:getContentSize().height*0.5-20)
            end
            
            if index>10000 then
                numLb1:setColor(G_ColorRed)
                numLb2:setColor(G_ColorRed)
                local function nilFunc()
                end
                local coverBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
                coverBg:setTouchPriority(-(self.layerNum-1)*20-2)
                coverBg:setContentSize(backSize)
                cell:addChild(coverBg,5)
                coverBg:setPosition(backSprie:getPosition())

                if  haveNum==0 then
                    nameBg:setVisible(false)
                    numLb1:setVisible(false)
                    numLb2:setVisible(false)

                    local noHaveLb=GetTTFLabelWrap(getlocal("emblem_noHad"),25,CCSizeMake(backSize.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    noHaveLb:setAnchorPoint(ccp(0.5,0.5))
                    coverBg:addChild(noHaveLb)
                    noHaveLb:setPosition(backSize.width/2,backSize.height/2+30)
                    noHaveLb:setColor(G_ColorRed)
                end
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

function ltzdzActiveTankSmallDialog:tabClick(idx)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
         else
            v:setEnabled(true)
         end
    end
    self:changeTb(idx)
    self.tv:reloadData()

end

function ltzdzActiveTankSmallDialog:changeTb(idx)
    if idx==1 then
        self.keyTable=self.keyTable1
    else
        self.keyTable=self.keyTable2
    end
    local totalNum=SizeOfTable(self.keyTable)

    self.hei=math.ceil(totalNum/3)

    self:setNoTankLb()
    -- print("totalNum,self.hei",totalNum,self.hei)
end

function ltzdzActiveTankSmallDialog:setNoTankLb()
    if not self.tvBg then
        return
    end

    local noTankLb=tolua.cast(self.tvBg:getChildByTag(110),"CCLabelTTF")
    if self.keyTable and SizeOfTable(self.keyTable)==0 then
        local noTankStr
        if self.selectedTabIndex==1 then
            noTankStr=getlocal("noCommonTank")
        else
            noTankStr=getlocal("noEliteTank")
        end
        if noTankLb then
            noTankLb:setString(noTankStr)
            noTankLb:setVisible(true)
        end
    else
        if noTankLb then
            noTankLb:setVisible(false)
        end
    end

end


function ltzdzActiveTankSmallDialog:dispose()
    self.allTabs=nil
    self.keyTable1=nil
    self.keyTable2=nil
    self.keyTable=nil
    self.hei=nil
    self.selectTankId=nil
    self.selectedTabIndex=nil
    self.selectSp=nil
    self.tankTable=nil
end