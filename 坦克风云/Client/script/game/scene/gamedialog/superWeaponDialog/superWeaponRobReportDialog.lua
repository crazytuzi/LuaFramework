superWeaponRobReportDialog=commonDialog:new()

function superWeaponRobReportDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.normalHeight=140
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        self.normalHeight=110
    end
    -- self.normalHeight=120
    self.writeBtn=nil
    self.deleteBtn=nil
    self.readedAllBtn=nil
    self.unreadLb=nil
    self.readedLb=nil
    self.totalLabel=nil
    self.tvHeight=nil
    self.canClick=false
    self.mailClick=0
    self.noEmailLabel=nil
    
    self.bgLayer=nil
    self.layerNum=nil

    spriteController:addPlist("public/emailNewUI.plist")
    spriteController:addTexture("public/emailNewUI.png")
    
    return nc
end

function superWeaponRobReportDialog:initTableView()
    local function initDialog()
        self.tvWidth=G_VisibleSizeWidth-40
        self.tvHeight=self.bgLayer:getContentSize().height-250

        self.panelLineBg:setContentSize(CCSizeMake(self.tvWidth+40,G_VisibleSize.height-110))
        self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))

        if self.panelLineBg then
            self.panelLineBg:setVisible(false)
        end
        if self.panelTopLine then
            self.panelTopLine:setVisible(true)
            self.panelTopLine:setPositionY(G_VisibleSizeHeight-82)
        end

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function click(hd,fn,idx)
        end
        self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,click)
        self.tvBg:setContentSize(CCSizeMake(self.tvWidth,self.tvHeight+10))
        self.tvBg:ignoreAnchorPointForPosition(false)
        self.tvBg:setAnchorPoint(ccp(0.5,0))
        --self.tvBg:setIsSallow(false)
        --self.tvBg:setTouchPriority(-(self.layerNum-1)*20-2)
        self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,145))
        self.tvBg:setOpacity(0)
        self.bgLayer:addChild(self.tvBg)
        
        self.noEmailLabel=GetTTFLabel(getlocal("alliance_war_no_record"),30)
        self.noEmailLabel:setPosition(getCenterPoint(self.tvBg))
        self.noEmailLabel:setColor(G_ColorGray)
        self.tvBg:addChild(self.noEmailLabel,2)
        self.noEmailLabel:setVisible(false)

        local strSize2Pos=50
        if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="tw" then
            strSize2Pos=0
        end
        local posX=340
        local posY=125

        local function readAllHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            swReportVoApi:readAllReport()
        end
        local readedAllBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",readAllHandler,10,getlocal("email_readedAll"),24/0.8,101)
        readedAllBtn:setScale(0.8)
        local btnLb = readedAllBtn:getChildByTag(101)
        if btnLb then
            btnLb = tolua.cast(btnLb,"CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
        local readedAllBtnMenu=CCMenu:createWithItem(readedAllBtn)
        readedAllBtnMenu:setAnchorPoint(ccp(0,0))
        readedAllBtnMenu:setPosition(ccp(200,60))
        readedAllBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(readedAllBtnMenu)
        self.readedAllBtn=readedAllBtn

        local function deleteAllHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            local function realDeleteAll()
                swReportVoApi:deleteAllReport()   
            end
            local deleteStr=getlocal("report_clear_confirm")    
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),realDeleteAll,getlocal("dialog_title_prompt"),deleteStr,nil,self.layerNum+1)
        end
        local deleteBtn=GetButtonItem("yh_letterBtnDelete.png","yh_letterBtnDelete_Down.png","yh_letterBtnDelete.png",deleteAllHandler,12,nil,nil)
        -- deleteBtn:setScaleX(1.05)
        local deleteSpriteMenu=CCMenu:createWithItem(deleteBtn)
        deleteSpriteMenu:setAnchorPoint(ccp(0,0))
        deleteSpriteMenu:setPosition(ccp(G_VisibleSizeWidth-200,60))
        deleteSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(deleteSpriteMenu,2)
        self.deleteBtn=deleteBtn

        local groupSelf=CCSprite:createWithSpriteFrameName("groupSelf.png")
        groupSelf:setScaleY(40/groupSelf:getContentSize().height)
        groupSelf:setScaleX(5)
        groupSelf:setPosition(ccp(G_VisibleSizeWidth*0.5+20,125))
        groupSelf:ignoreAnchorPointForPosition(false)
        self.bgLayer:addChild(groupSelf)

        local totalNum=superWeaponVoApi:getTotalNum()
        local unreadNum=superWeaponVoApi:getUnreadNum()
        local unreadLb=GetTTFLabel(getlocal("email_unread_num",{unreadNum}),22)
        unreadLb:setAnchorPoint(ccp(1,0.5))
        unreadLb:setPosition(ccp(posX-90-strSize2Pos,posY))
        unreadLb:setColor(G_ColorYellowPro)
        self.bgLayer:addChild(unreadLb,2)
        self.unreadLb=unreadLb

        local readedNum=totalNum-unreadNum
        local readedLb=GetTTFLabel(getlocal("email_readed_num",{readedNum}),22)
        readedLb:setAnchorPoint(ccp(0,0.5))
        readedLb:setPosition(ccp(posX+45+strSize2Pos,posY))
        self.bgLayer:addChild(readedLb,2)
        self.readedLb=readedLb

        self:refresh()
    end

    local flag=superWeaponVoApi:getFlag()
    -- local listNum=superWeaponVoApi:getNum()
    -- local totalNum=superWeaponVoApi:getTotalNum()
    -- if totalNum>listNum then
    if flag==-1 then
        local function weaponGetlogCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data and sData.data.weaponroblog then
                    superWeaponVoApi:addReport(sData.data.weaponroblog)
                    initDialog()
                    self:initTv()
                    if superWeaponVoApi:getNum()==0 and self.noEmailLabel then
                        self.noEmailLabel:setVisible(true)
                    end
                    superWeaponVoApi:setFlag(1)
                end
            end
        end
        local isPage=nil
        -- local minrid,maxrid=superWeaponVoApi:getMinAndMaxRid()
        -- if minrid>0 or maxrid>0 then
        --  isPage=true
        -- end
        local minrid,maxrid=0,0
        socketHelper:weaponGetlog(minrid,maxrid,isPage,weaponGetlogCallback,nil,1)
    else
        initDialog()        
        self:initTv()
        if superWeaponVoApi:getNum()==0 and self.noEmailLabel then
            self.noEmailLabel:setVisible(true)
        end
    end
end

function superWeaponRobReportDialog:initTv()
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp((G_VisibleSizeWidth-self.tvWidth)/2,150))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(self.normalHeight)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function superWeaponRobReportDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num=superWeaponVoApi:getNum()
        local hasMore=superWeaponVoApi:hasMore()
        if hasMore then
            num=num+1
        end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.tvWidth,self.normalHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        
        local hasMore=superWeaponVoApi:hasMore()
        local num=superWeaponVoApi:getNum()

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
            return self:cellClick(idx)
        end
        local backSprie
        if hasMore and idx==num then
            backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(self.tvWidth,self.normalHeight-2))
            backSprie:ignoreAnchorPointForPosition(false);
            backSprie:setAnchorPoint(ccp(0,0));
            backSprie:setTag(idx)
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:setPosition(ccp(0,0));
            -- cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
            cell:addChild(backSprie,1)
            
            local moreLabel=GetTTFLabel(getlocal("showMoreTen"),30)
            moreLabel:setPosition(getCenterPoint(backSprie))
            backSprie:addChild(moreLabel,2)
            
            return cell
        end

        local list=superWeaponVoApi:getReportList()
        local reportVo=list[idx+1] or {}
        local time=reportVo.time
        local enemyName=reportVo.enemyName
        local isRead=reportVo.isRead
        local robSuccess=reportVo.robSuccess
        local isVictory=reportVo.isVictory
        local isAttacker=reportVo.type
        local wid=reportVo.wid
        local wLevel=getlocal("fightLevel",{reportVo.wLevel})
        local fid=reportVo.fid
        local elementNum=reportVo.elementNum
        local wName=""
        local fName=""
        if wid and superWeaponCfg.weaponCfg and superWeaponCfg.weaponCfg[wid] then
            wName=getlocal(superWeaponCfg.weaponCfg[wid].name)
        end
        if fid and superWeaponCfg.fragmentCfg and superWeaponCfg.fragmentCfg[fid] then
            fName=superWeaponVoApi:getFragmentNameAndDesc(fid)
        end
        
        if isRead==1 then
            backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newReadBg.png",CCRect(5,5,1,1),cellClick)
        else
            backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png",CCRect(5,23,1,1),cellClick)
        end
        backSprie:setContentSize(CCSizeMake(self.tvWidth,self.normalHeight-2))
        backSprie:ignoreAnchorPointForPosition(false);
        backSprie:setAnchorPoint(ccp(0,0));
        backSprie:setTag(idx)
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(ccp(0,0));
        -- cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, self.normalHeight))
        cell:addChild(backSprie,1)

        local bgWidth=backSprie:getContentSize().width
        local bgHeight=backSprie:getContentSize().height
        
        local emailIconBg,emailIcon,typeIconName
        if isRead==1 then
            emailIconBg=LuaCCScale9Sprite:createWithSpriteFrameName("emailNewUI_readIconBg.png",CCRect(16,16,2,2),function()end)
            emailIcon=CCSprite:createWithSpriteFrameName("emailNewUI_readIcon.png")
            typeIconName="emailNewUI_fight0.png"
        else
            emailIconBg=LuaCCScale9Sprite:createWithSpriteFrameName("newChat_head_shade.png",CCRect(16,16,2,2),function()end)
            emailIcon=CCSprite:createWithSpriteFrameName("emailNewUI_unReadIcon.png")
            typeIconName="emailNewUI_fight1.png"
        end
        emailIconBg:setContentSize(CCSizeMake(backSprie:getContentSize().height,backSprie:getContentSize().height))
        emailIconBg:setAnchorPoint(ccp(0,0.5))
        emailIconBg:setPosition(0,backSprie:getContentSize().height/2)
        backSprie:addChild(emailIconBg)

        emailIcon:setPosition(getCenterPoint(emailIconBg))
        emailIconBg:addChild(emailIcon)

        if typeIconName then
            local typeIcon=CCSprite:createWithSpriteFrameName(typeIconName)
            typeIcon:setPosition(getCenterPoint(emailIconBg))
            if isRead==1 then
                typeIcon:setPositionY(typeIcon:getPositionY()-10)
            end
            emailIconBg:addChild(typeIcon)
        end

        local challengeStr=""
        local params={}
        if isAttacker==1 then
            if isVictory==1 then
                if robSuccess==1 then
                    if elementNum > 0 then
                        params={enemyName,elementNum}
                        challengeStr=getlocal("super_weapon_rob_report_desc_7",params)
                    else
                        params={enemyName,wLevel,fName}
                        challengeStr=getlocal("super_weapon_rob_report_desc_1",params)
                    end
                else
                    params={enemyName}
                    challengeStr=getlocal("super_weapon_rob_report_desc_2",params)
                end
            else
                params={enemyName}
                challengeStr=getlocal("super_weapon_rob_report_desc_3",params)
            end
        else
            if isVictory==1 then
                params={enemyName}
                challengeStr=getlocal("super_weapon_rob_report_desc_4",params)
            else
                if robSuccess==1 then
                    params={enemyName,wLevel,fName}
                    challengeStr=getlocal("super_weapon_rob_report_desc_6",params)
                else
                    params={enemyName}
                    challengeStr=getlocal("super_weapon_rob_report_desc_5",params)
                end
            end
        end
        local challengeLabel=GetTTFLabelWrap(challengeStr,20,CCSizeMake(bgWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        challengeLabel:setAnchorPoint(ccp(0,0.5))
        cell:addChild(challengeLabel,2)
        challengeLabel:setPosition(emailIconBg:getPositionX()+emailIconBg:getContentSize().width+10,bgHeight/2)

        local function showBattle()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            if battleScene.isBattleing==true then
                do return end
            end

            local function fightAction()
                if reportVo.report==nil or SizeOfTable(reportVo.report)==0 then
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
                else
                    self:showBattleScene(reportVo)
                end
            end

            if reportVo.initReport==nil or reportVo.initReport==false then
                local function callback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData and sData.data and sData.data.content then
                            swReportVoApi:addReportDetail(reportVo.rid,sData.data.content)
                            local reportVoTab=superWeaponVoApi:getReportList()
                            local reportVo=reportVoTab[idx+1]
                            if reportVo==nil then
                                do return end
                            end
                            fightAction()
                        end
                    end
                end
                socketHelper:weaponRead(reportVo.rid,callback)
            else
                fightAction()
            end
        end
        local resultSp
        local scale=0.3
        if isVictory==1 then
            resultSp=LuaCCSprite:createWithSpriteFrameName("SuccessHeader.png",showBattle)
            -- resultSp=CCSprite:createWithSpriteFrameName("SuccessHeader.png")
        else
            resultSp=LuaCCSprite:createWithSpriteFrameName("LoseHeader.png",showBattle)
            -- resultSp=CCSprite:createWithSpriteFrameName("LoseHeader.png")
        end
        resultSp:setScale(scale)
        resultSp:setPosition(ccp(bgWidth-resultSp:getContentSize().width/2*scale-10,45))
        resultSp:setTouchPriority(-(self.layerNum-1)*20-2)
        -- resultSp:setIsSallow(true)
        cell:addChild(resultSp,2)

        local timeStr=G_getDataTimeStr(time)
        local timeLabel=GetTTFLabel(timeStr,22)
        timeLabel:setAnchorPoint(ccp(0.5,0.5))
        timeLabel:setPosition(bgWidth-resultSp:getContentSize().width/2*scale-10,bgHeight-30)
        backSprie:addChild(timeLabel,2)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

--点击了cell或cell上某个按钮
function superWeaponRobReportDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if battleScene.isBattleing==true then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)
        local num=superWeaponVoApi:getNum()
        local hasMore=superWeaponVoApi:hasMore()
        local nextHasMore=false
        if hasMore and tostring(idx)==tostring(num) then
            local function weaponGetlogCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData.data and sData.data.weaponroblog then
                        superWeaponVoApi:addReport(sData.data.weaponroblog)
                    end

                    self.canClick=true
                    local newNum=superWeaponVoApi:getNum()
                    local diffNum=newNum-num
                    local nextHasMore=superWeaponVoApi:hasMore()
                    if nextHasMore then
                        diffNum=diffNum+1
                    end
                    local recordPoint = self.tv:getRecordPoint()
                    self:refresh()
                    recordPoint.y=-(diffNum-1)*self.normalHeight+recordPoint.y
                    self.tv:recoverToRecordPoint(recordPoint)
                    -- emailVoApi:setFlag(self.selectedTabIndex+1,1)
                    superWeaponVoApi:setFlag(1)
                    self.canClick=false
                end
            end
            if self.canClick==false then
                local minrid,maxrid=superWeaponVoApi:getMinAndMaxRid()
                local isPage=nil
                if minrid>0 or maxrid>0 then
                    isPage=true
                end
                socketHelper:weaponGetlog(minrid,maxrid,isPage,weaponGetlogCallback,nil,1)
            end
        else
            if self.mailClick==0 then
                self.mailClick=1
                local reportVoTab=superWeaponVoApi:getReportList()
                local reportVo=reportVoTab[idx+1]
                if reportVo==nil then
                    do return end
                end

                if reportVo.initReport==true then
                    self:checkIsRead(reportVo)
                else
                    local function callback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if sData and sData.data and sData.data.content then
                                -- superWeaponVoApi:addReportHeroAccesoryAndLostship(reportVo.rid,sData.data.content)
                                swReportVoApi:addReportDetail(reportVo.rid,sData.data.content)
                                self:checkIsRead(reportVo)
                            end
                        end
                    end
                    socketHelper:weaponRead(reportVo.rid,callback)
                end
            end
        end
    end
end

function superWeaponRobReportDialog:checkIsRead(reportVo)
    if reportVo.isRead==0 then
        local function callback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                superWeaponVoApi:setIsRead(reportVo.rid)
                if self==nil or self.tv==nil then
                    do return end
                end
                local recordPoint=self.tv:getRecordPoint()
                self:refresh()
                self.tv:recoverToRecordPoint(recordPoint)
                self:showReportDetailDialog(reportVo)
            end
        end
        socketHelper:weaponRead(reportVo.rid,callback)
    else
        self:showReportDetailDialog(reportVo)
    end
end

function superWeaponRobReportDialog:showReportDetailDialog(report)
    if report then
        local layerNum=self.layerNum+1
        -- local td=reportDetailDialog:new(layerNum,report,nil,3,2)
        local td=reportDetailNewDialog:new(layerNum,report,nil,3,2)
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("arena_report_title"),false,layerNum)
        sceneGame:addChild(dialog,layerNum)
    end
end

function superWeaponRobReportDialog:showBattleScene(reportVo)
    if reportVo then
        if reportVo.report==nil or SizeOfTable(reportVo.report)==0 then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
        else
            local isAttacker=false
            if reportVo.type==1 then
                isAttacker=true
            end
            local data={data=reportVo,isAttacker=isAttacker,isReport=true,battleType=3}
            battleScene:initData(data)
        end
    end
end

function superWeaponRobReportDialog:tick()
    if self.mailClick>0 then
        self.mailClick=0
    end
    local flag=superWeaponVoApi:getFlag()
    if flag==0 then
        self:refresh()
        superWeaponVoApi:setFlag(1)
    end
end

function superWeaponRobReportDialog:refresh()
    if self~=nil then
        if self.noEmailLabel then
            if superWeaponVoApi:getNum()==0 then
                self.noEmailLabel:setVisible(true)
            else
                self.noEmailLabel:setVisible(false)
            end
        end
        if self.tv~=nil then
            self.tv:reloadData()
        end
        local totalNum=superWeaponVoApi:getTotalNum()
        local unreadNum=superWeaponVoApi:getUnreadNum()
        local readedNum=totalNum-unreadNum
        if readedNum<0 then
            readedNum=0
        end
        if unreadNum>0 then
            self.readedAllBtn:setEnabled(true)
        else
            self.readedAllBtn:setEnabled(false)
        end
        if totalNum>0 then
            self.deleteBtn:setEnabled(true)
        else
            self.deleteBtn:setEnabled(false)
        end
        self.unreadLb:setString(getlocal("email_unread_num",{unreadNum}))
        self.readedLb:setString(getlocal("email_readed_num",{readedNum}))
    end
end

function superWeaponRobReportDialog:dispose()
    self.mailClick=nil
    self.canClick=nil
    self.normalHeight=nil
    self.writeBtn=nil
    self.deleteBtn=nil
    self.unreadLb=nil
    self.readedLb=nil
    self.totalLabel=nil
    self.tvHeight=nil
    self.noEmailLabel=nil
    self.readedAllBtn=nil
    self.bgLayer=nil
    self.layerNum=nil

    spriteController:removePlist("public/emailNewUI.plist")
    spriteController:removeTexture("public/emailNewUI.png")

end






