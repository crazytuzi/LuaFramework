acWjdcDialog = commonDialog:new()

function acWjdcDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.cellHeightTb={}
    nc.checkSpTb={}
    nc.textTb={}
    nc.textLbTb={}
    nc.editBox={}
    nc.titleBg={}
    nc.openTime=0
    nc.textBgHeight=230
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    return nc
end

function acWjdcDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,G_VisibleSize.height-100))
    self.openTime=base.serverTime
end

function acWjdcDialog:initTableView( )
    local questionData
    if G_curPlatName()=="0" then
        questionData=G_sendHttpRequest("http://192.168.8.213/tankheroclient/webpage/questionnaire/questionnaire.php","")
    else
        questionData=G_sendHttpRequest("http://"..base.serverUserIp.."/tankheroclient/webpage/questionnaire/questionnaire.php","")
    end
    if questionData then
        print("questionData~~~~~",questionData)
        local qtData=G_Json.decode(tostring(questionData))
        if qtData and SizeOfTable(qtData)>0 then
            acWjdcVoApi:setQuestionData(qtData)

        local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function ()end)
        tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-350))
        tvBg:setAnchorPoint(ccp(0.5,0))
        tvBg:setTouchPriority(-(self.layerNum-1)*20-1)
        tvBg:setPosition(ccp(G_VisibleSizeWidth/2,30))
        self.bgLayer:addChild(tvBg)
        local goldLineSprite = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
        goldLineSprite:setAnchorPoint(ccp(0.5,1))
        goldLineSprite:setPosition(ccp(tvBg:getContentSize().width/2,tvBg:getContentSize().height))
        tvBg:addChild(goldLineSprite,1)
        local noticeLb=GetTTFLabelWrap(getlocal("activity_wjdc_notice"),22,CCSizeMake(tvBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noticeLb:setColor(G_ColorRed)
        noticeLb:setPosition(ccp(tvBg:getContentSize().width/2,tvBg:getContentSize().height-45))
        tvBg:addChild(noticeLb,1)


    	local function callback(...)
    		return self:eventHandler(...)
    	end
    	local hd=LuaEventHandler:createHandler(callback)
    	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvBg:getContentSize().width,tvBg:getContentSize().height-75),nil)
    	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    	self.tv:setPosition(20,35)
    	self.bgLayer:addChild(self.tv,2)
    	self.tv:setMaxDisToBottomOrTop(80)
    end
    end
end

function acWjdcDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
        local questionData=acWjdcVoApi:getQuestionData()
		return SizeOfTable(questionData)
	elseif fn=="tableCellSizeForIndex" then
        local cellHight=self:getCellHeight(idx)
		return  CCSizeMake(G_VisibleSizeWidth - 40,cellHight)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

        local cellHight=self:getCellHeight(idx)
		local background=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
		background:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,cellHight-10))
		background:setAnchorPoint(ccp(0,0))
		background:setPosition(ccp(0,5))
		cell:addChild(background)
        background:setOpacity(0)

        local bgWidth,bgHeight=background:getContentSize().width,background:getContentSize().height

        local questionData=acWjdcVoApi:getQuestionData()
        local qNum=SizeOfTable(questionData)
        local cellData=questionData[idx+1]
        if cellData==nil then
            do return cell end
        end

        local id=cellData.id
        local qType=cellData.type
        local title=cellData.q
        local optionTb=cellData.a
        -- print("id,qType,title,optionTb",id,qType,title,optionTb)

        local answerTb=acWjdcVoApi:getAnswerData()
        local answerItem=answerTb[idx+1] or {}
        local selectTb,content
        if answerItem and answerItem[1] then
            selectTb=answerItem[1]
        end
        if answerItem and answerItem[2] then
            content=answerItem[2]
        end

        local titlePy=bgHeight-5
        local function nilFunc()
        end
        local subTitleLb=GetTTFLabelWrap(title,22,CCSizeMake(bgWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        subTitleLb:setColor(G_ColorGreen)
        subTitleLb:setAnchorPoint(ccp(0,1))
        subTitleLb:setPosition(ccp(20,titlePy))
        background:addChild(subTitleLb,1)
        local subTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("questionTitleBg.png",CCRect(105, 16, 1, 1),nilFunc)
        subTitleBg:setContentSize(CCSizeMake(bgWidth-10,32))
        subTitleBg:setAnchorPoint(ccp(0.5,1))
        subTitleBg:setPosition(ccp(bgWidth/2,titlePy+5))
        background:addChild(subTitleBg)
        subTitleBg:setScaleY((subTitleLb:getContentSize().height+10)/subTitleBg:getContentSize().height)
        self.titleBg[idx+1]=subTitleBg

        if self.checkSpTb[idx+1]==nil then
            self.checkSpTb[idx+1]={}
        end
        if self.textTb[idx+1]==nil then
            self.textTb[idx+1]=""
        end

        local cellPosy=bgHeight-(subTitleLb:getContentSize().height+10)-40
        local isText=false
        if qType<3 and optionTb then
            for k,v in pairs(optionTb) do
                if v and v[1] then
                    local function checkClick(object,fn,tag)
                        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end

                            if self.checkSpTb and self.checkSpTb[idx+1] then
                                for m,n in pairs(self.checkSpTb[idx+1]) do
                                    if n then
                                        local sp=tolua.cast(n:getChildByTag(109),"CCSprite")
                                        if sp then
                                            if m==tag then
                                                if sp:isVisible()==true then
                                                    sp:setVisible(false)
                                                else
                                                    sp:setVisible(true)
                                                end
                                            elseif qType==1 then
                                                sp:setVisible(false)
                                            end
                                        end
                                    end
                                end
                            end

                            local answerTb,showContentTb=self:getAnswer()
                            if self.textLbTb and self.textLbTb[idx+1] then
                                local lb=tolua.cast(self.textLbTb[idx+1],"CCLabelTTF")
                                if lb then
                                    if showContentTb and showContentTb[idx+1]==1 then
                                        lb:setColor(G_ColorWhite)
                                    else
                                        lb:setColor(G_ColorGray)
                                    end
                                end
                            end

                            acWjdcVoApi:setAnswerData(answerTb)
                        end
                    end
                    local touchSp=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",checkClick)
                    touchSp:setScale(1.3)
                    touchSp:setPosition(ccp(40,cellPosy-10))
                    touchSp:setTouchPriority(-(self.layerNum-1)*20-2)
                    background:addChild(touchSp)
                    touchSp:setOpacity(0)
                    touchSp:setTag(k)
                    local unCheckSp=CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
                    unCheckSp:setPosition(ccp(40,cellPosy))
                    background:addChild(unCheckSp)
                    local checkSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
                    checkSp:setPosition(getCenterPoint(checkSp))
                    unCheckSp:addChild(checkSp)
                    checkSp:setTag(109)
                    checkSp:setVisible(false)
                    if selectTb then
                        for m,n in pairs(selectTb) do
                            if n==k then
                                checkSp:setVisible(true)
                            end
                        end
                    end
                    self.checkSpTb[idx+1][k]=unCheckSp
                    local optionLb=GetTTFLabel(v[1],22)
                    optionLb:setAnchorPoint(ccp(0,0.5))
                    optionLb:setPosition(ccp(unCheckSp:getPositionX()+unCheckSp:getContentSize().width/2+10,cellPosy))
                    background:addChild(optionLb)
                    cellPosy=cellPosy-unCheckSp:getContentSize().height-10

                    local oType=v[2]
                    if oType and oType==1 then
                        isText=true
                        -- local textBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),writeHandler)
                        -- textBg:setContentSize(CCSizeMake(background:getContentSize().width-30,170))
                        -- textBg:setAnchorPoint(ccp(0.5,1))
                        -- textBg:setPosition(ccp(background:getContentSize().width/2,cellPosy+25))
                        -- textBg:setTouchPriority(-(self.layerNum-1)*20-2)
                        -- background:addChild(textBg)
                    end
                end
            end
        end
        
        if (qType>=3 and qType<5) or isText==true then
            local function writeHandler(hd,fn,idx1)
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    local answerTb,showContentTb=self:getAnswer()
                    if showContentTb and showContentTb[idx+1]==1 then
                        if self.editBox[idx+1] and self.textTb[idx+1] then
                            self.editBox[idx+1]:setVisible(true)
                            self.editBox[idx+1]:setText(self.textTb[idx+1])
                        end
                    end
                end
            end
            local textBg=LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",CCRect(10,10,1,1),writeHandler)
            textBg:setContentSize(CCSizeMake(background:getContentSize().width-30,self.textBgHeight))
            textBg:setAnchorPoint(ccp(0.5,1))
            textBg:setPosition(ccp(background:getContentSize().width/2,cellPosy+25))
            textBg:setTouchPriority(-(self.layerNum-1)*20-2)
            background:addChild(textBg)

            --输入框--------------------------------
            local contentStr=""
            if content then
                contentStr=content
            end
            local textLabel=GetTTFLabelWrap(content,25,CCSizeMake(textBg:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            textLabel:setAnchorPoint(ccp(0,1))
            textLabel:setPosition(ccp(10,textBg:getContentSize().height-10))
            textBg:addChild(textLabel,2)
            self.textLbTb[idx+1]=textLabel

            self.textTb[idx+1]=textLabel:getString()
            if self.textTb[idx+1]==nil then
                self.textTb[idx+1]=""
            end
            local function tthandler()
        
            end
            local function callBackHandler(fn,eB,str,type)
                --if type==0 then  --开始输入
                    --eB:setText(textTb[idx+1])
                if type==1 then  --检测文本内容变化
                    if str==nil then
                        self.textTb[idx+1]=""
                    else
                        self.textTb[idx+1]=str
                        if changeCallback then
                            local txt=changeCallback(fn,eB,str,type)
                            if txt then
                                self.textTb[idx+1]=txt
                                eB:setText(self.textTb[idx+1])
                            end
                        end
                    end
                    textLabel:setString(self.textTb[idx+1])
                elseif type==2 then --检测文本输入结束
                    eB:setVisible(false)
                    --屏蔽字
                    if self.textTb[idx+1]==nil then
                        self.textTb[idx+1]=""
                    end
                    -- self.textTb[idx+1]=keyWordCfg:keyWordsReplace(self.textTb[idx+1])
                    textLabel:setString(self.textTb[idx+1])
                    eB:setText(self.textTb[idx+1])

                    local answerTb=self:getAnswer()
                    acWjdcVoApi:setAnswerData(answerTb)
                end
            end
            
            local winSize=CCEGLView:sharedOpenGLView():getFrameSize()
            local xScale=winSize.width/640
            local yScale=winSize.height/960
            local size=CCSizeMake(textBg:getContentSize().width,50)
            -- local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler)
            local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",CCRect(10,10,1,1),tthandler)
            local editBox=CCEditBox:createForLua(size,xBox,nil,nil,callBackHandler)
            editBox:setFont(textLabel.getFontName(textLabel),yScale*textLabel.getFontSize(textLabel)/2)
            editBox:setMaxLength(100)
            editBox:setText(self.textTb[idx+1])
            editBox:setAnchorPoint(ccp(0,0))
            editBox:setPosition(ccp(0,0))

            editBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsSentence)
            editBox:setInputMode(CCEditBox.kEditBoxInputModeSingleLine)

            editBox:setVisible(false)
            textBg:addChild(editBox,9)
            self.editBox[idx+1]=editBox

            ----------------------------------
        end

        if qNum==idx+1 then
            cellPosy=90
            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setScaleX((background:getContentSize().width-40)/lineSp:getContentSize().width)
            lineSp:setPosition(ccp(background:getContentSize().width/2,cellPosy))
            background:addChild(lineSp)

            cellPosy=cellPosy-50
            local function rewardHandler()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end

                    local function refreshFunc()
                        local answer=self:getAnswer()
                        local answerTb=self:formatAnswer(answer)
                        -- answerTb={choice={q1={1},q2={1},q3={1,3},q4={1},q5={1},q6={1},q7={1},q8={1},q9={1},q10={},q11={1},q12={},},content={q1="",q2="",q3="",q4="",q5="",q6="",q7="",q8="",q9="",q10="sdd",q11="",q12="sadad",}}
                        -- print("answerTb",G_Json.encode(answerTb))
                        -- 平台名G_curplatName(),uid，角色等级，vip等级，服id，昵称，注册时间，已充值金币
                        local httpUrl
                        if G_curPlatName()=="0" then
                            httpUrl="http://192.168.8.213/test_gm_index/GetAnswerApi/getAnswer"
                        else
                            httpUrl="http://gm.rayjoy.com/tank_gm/gm_index/GetAnswerApi/getAnswer"
                        end
                        
                        local costTime=acWjdcVoApi:getCostTime()
                        local time=costTime+base.serverTime-self.openTime
                        local uid,nickname,regdate,server,level,vip,gems,info=playerVoApi:getUid(),playerVoApi:getPlayerName(),playerVoApi:getRegdate(),base.curZoneID,playerVoApi:getPlayerLevel(),playerVoApi:getVipLevel(),playerVoApi:getBuygems(),G_Json.encode(answerTb)
                        local reqStr="uid="..uid.."&nickname="..nickname.."&regdate="..regdate.."&server="..server.."&level="..level.."&vip="..vip.."&gems="..gems.."&time="..time.."&info="..info
                        -- print("httpUrl~~~~~",httpUrl)
                        -- print("reqStr~~~~~",reqStr)
                        local retStr=G_sendHttpRequestPost(httpUrl,reqStr)
                        -- print("retStr~~~~~",retStr)
                        if retStr then
                            local retData=G_Json.decode(retStr)
                            if retData and retData.ret==0 then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_wjdc_commit_success"),30)
                            end
                        end
                        self:close()
                    end
                    local answerTb,showContentTb,canCommit,limitType=self:getAnswer()
                    if canCommit==0 then
                        acWjdcVoApi:socketReward(refreshFunc)
                    else
                        if limitType==1 then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_wjdc_commit_tip"),30)
                        else
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_wjdc_limit_tip"),30)
                        end
                        if self.tv then
                            local recordPoint=self.tv:getRecordPoint()
                            local questionData=acWjdcVoApi:getQuestionData()
                            local qNum=SizeOfTable(questionData)
                            local cellHight=0,0
                            if canCommit and canCommit>1 then
                                for i=1,(canCommit-1) do
                                    cellHight=cellHight+self:getCellHeight(i-1)
                                end
                            end
                            recordPoint.y=cellHight-self.tv:getContentSize().height+(G_VisibleSizeHeight-425)
                            self.tv:recoverToRecordPoint(recordPoint)

                            if self.titleBg[canCommit] then
                                local sp=tolua.cast(self.titleBg[canCommit],"LuaCCScale9Sprite")
                                if sp then
                                    local fadeOut=CCFadeOut:create(0.5)
                                    local fadeIn=CCFadeIn:create(0.5)
                                    local acArr=CCArray:create()
                                    acArr:addObject(fadeOut)
                                    acArr:addObject(fadeIn)
                                    local seq=CCSequence:create(acArr)
                                    sp:runAction(seq)
                                end
                            end
                        end
                    end

                end
            end
            local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",rewardHandler,nil,getlocal("activity_wjdc_commit"),25)
            -- rewardItem:setScale(0.8)
            local rewardBtn=CCMenu:createWithItem(rewardItem);
            rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
            rewardBtn:setPosition(ccp(background:getContentSize().width/2,cellPosy))
            background:addChild(rewardBtn)
            local acVo=acWjdcVoApi:getAcVo()
            if acVo and acVo.v==0 then
                rewardItem:setEnabled(true)
            else
                rewardItem:setEnabled(false)
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

function acWjdcDialog:getAnswer()
    local answerTb,showContentTb,canCommit,limitType={},{},0,0
    local questionData=acWjdcVoApi:getQuestionData()
    if questionData then
        for k,v in pairs(questionData) do
            if answerTb[k]==nil then
                answerTb[k]={{},""}
            end
        end
    end
    if self.checkSpTb then
        for k,v in pairs(self.checkSpTb) do
            if answerTb[k]==nil then
                answerTb[k]={{},""}
            end
            for m,n in pairs(v) do
                if n then
                    local sp=tolua.cast(n:getChildByTag(109),"CCSprite")
                    if sp then
                        if sp:isVisible()==true then
                            table.insert(answerTb[k][1],m)
                        end
                    end
                end
            end
        end
    end

    if self.textTb then
        for k,v in pairs(self.textTb) do
            if answerTb[k]==nil then
                answerTb[k]={{},""}
            end
            local isShowContent=false
            local qItem=questionData[k]
            local qType,optionTb
            if qItem and qItem.type then
                qType=qItem.type
            end
            if qItem and qItem.a then
                optionTb=qItem.a
            end
            if qType<3 then
                local selectTb=answerTb[k][1]
                if selectTb then
                    for m,n in pairs(selectTb) do
                        if n and optionTb and optionTb[n] and optionTb[n][2] then
                            local oType=optionTb[n][2]
                            if oType and oType==1 then
                                isShowContent=true
                                showContentTb[k]=1
                            end
                        end
                    end
                end
            else
                isShowContent=true
                showContentTb[k]=1
            end
            if v and isShowContent==true then
                answerTb[k][2]=v
            end
        end
    end

    for k,v in pairs(answerTb) do
        local qItem=questionData[k]
        local qType,optionTb
        if qItem and qItem.type then
            qType=qItem.type
        end
        if qItem and qItem.a then
            optionTb=qItem.a
        end
        if qType==1 or qType==2 then
            if v then
                if (v[1]==nil or (v[1] and SizeOfTable(v[1])==0)) then
                canCommit=k
                    limitType=1
                else
                    local selectTb=v[1]
                    if selectTb then
                        for m,n in pairs(selectTb) do
                            if n and optionTb and optionTb[n] and optionTb[n][2] then
                                local oType=optionTb[n][2]
                                if oType and oType==1 then
                                    if v[2]==nil or v[2]=="" then
                                        canCommit=k
                                        limitType=2
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if canCommit and canCommit>0 then
                break
            end
        elseif qType==3 then
            if v and (v[2]==nil or v[2]=="") then
                canCommit=k
                limitType=1
                break
        end
    end
    end

    return answerTb,showContentTb,canCommit,limitType
end

function acWjdcDialog:formatAnswer(answerTb)
    local tb={choice={},content={}}
    local questionData=acWjdcVoApi:getQuestionData()
    if questionData then
        for k,v in pairs(questionData) do
            if v and v.type~=5 then
                if tb.choice[tostring(k)]==nil then
                    tb.choice[tostring(k)]={}
                end
                if tb.content[tostring(k)]==nil then
                    tb.content[tostring(k)]=""
                end
            end
        end
    end
    if answerTb then
        for k,v in pairs(answerTb) do
            local qItem=questionData[k]
            local qType
            if qItem and qItem.type then
                qType=qItem.type
            end
            if qType~=5 then
                if tb.choice[tostring(k)]==nil then
                    tb.choice[tostring(k)]={}
                end
                if tb.content[tostring(k)]==nil then
                    tb.content[tostring(k)]=""
                end
                if v then
                    if v[1] then
                        tb.choice[tostring(k)]=v[1]
                    end
                    if v[2] then
                        tb.content[tostring(k)]=v[2]
                    end
                end
            end
        end
    end
    return tb
end

function acWjdcDialog:getCellHeight(idx)
    local index=idx+1
    if self.cellHeightTb==nil then
        self.cellHeightTb={}
    end
    if self.cellHeightTb[index]==nil then
        local questionData=acWjdcVoApi:getQuestionData()
        local qNum=SizeOfTable(questionData)
        local cellData=questionData[idx+1]
        if cellData==nil then
            do return 0 end
        end
        local id=cellData.id
        local qType=cellData.type
        local title=cellData.q
        local optionTb=cellData.a
        local subTitleLb=GetTTFLabelWrap(title,22,CCSizeMake(G_VisibleSizeWidth-40-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        local cellHeight=subTitleLb:getContentSize().height+30
        if qType~=5 then
        if qType<3 and optionTb then
            for k,v in pairs(optionTb) do
                local oType
                if v and v[2] then
                    oType=v[2]
                end
                cellHeight=cellHeight+60
                if oType and oType==1 then
                    cellHeight=cellHeight+self.textBgHeight+10
                end
            end
        else
            cellHeight=cellHeight+self.textBgHeight+10
        end
        end
        if qNum==idx+1 then
            cellHeight=cellHeight+100
        end
        self.cellHeightTb[index]=cellHeight
    end
    return self.cellHeightTb[index]
end

function acWjdcDialog:doUserHandler()
    local headerBgWidth=G_VisibleSizeWidth-35
    local posY=self.bgLayer:getContentSize().height-90
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local headerBg = CCSprite:create("public/serverWarLocal/sceneBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    headerBg:setColor(ccc3(220,220,220))
    headerBg:setAnchorPoint(ccp(0.5,1))
    headerBg:setFlipX(true)
    headerBg:setScaleX((headerBgWidth)/headerBg:getContentSize().width)
    headerBg:setScaleY(230/headerBg:getContentSize().height)
    headerBg:setPosition(ccp(G_VisibleSizeWidth/2,posY))
    self.bgLayer:addChild(headerBg)

    posY=posY-5
    local timeTitle = GetTTFLabel(getlocal("activity_timeLabel"),25)
    timeTitle:setAnchorPoint(ccp(0.5,1))
    timeTitle:setColor(G_ColorGreen)
    timeTitle:setPosition(ccp(self.bgLayer:getContentSize().width/2,posY))
    self.bgLayer:addChild(timeTitle)
    posY=posY-30
    local timeStr = acWjdcVoApi:getTimeStr()
    local timeStrLabel = GetTTFLabel(timeStr,25)
    timeStrLabel:setAnchorPoint(ccp(0.5,1))
    timeStrLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,posY))
    self.bgLayer:addChild(timeStrLabel)

    posY=posY-30
    local desBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
    desBg:setAnchorPoint(ccp(0.5,1))
    desBg:setPosition(ccp(G_VisibleSizeWidth/2,posY))
    self.bgLayer:addChild(desBg)
    desBg:setScaleX(headerBgWidth/desBg:getContentSize().width)
    desBg:setScaleY(150/desBg:getContentSize().height)
    desBg:setOpacity(180)

    posY=posY-30
    local lbPx=G_VisibleSizeWidth-110
    local rewardLb=GetTTFLabelWrap(getlocal("activity_wjdc_reward"),25,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    rewardLb:setColor(G_ColorBlack)
    rewardLb:setPosition(ccp(lbPx+2,posY-2))
    self.bgLayer:addChild(rewardLb)
    local rewardLb1=GetTTFLabelWrap(getlocal("activity_wjdc_reward"),25,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    rewardLb1:setColor(G_ColorYellowPro)
    rewardLb1:setPosition(ccp(lbPx,posY))
    self.bgLayer:addChild(rewardLb1)
    
    posY=posY-70
    local rewardTb=acWjdcVoApi:getRewardCfg()
    local xtb=G_getIconSequencePosx(2,120,lbPx,SizeOfTable(rewardTb) or 0)
    for k,v in pairs(rewardTb) do
        local icon=G_getItemIcon(v,100,true,self.layerNum+1)
        icon:setTouchPriority(-(self.layerNum-1)*20-4)
        icon:setPosition(ccp(xtb[k],posY))
        self.bgLayer:addChild(icon)
        local numLb=GetTTFLabel("x"..v.num,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(icon:getContentSize().width-5,5))
        icon:addChild(numLb)
    end

    posY=posY-55
    local descLb = getlocal("activity_wjdc_desc")
    local desTv, desLabel = G_LabelTableView(CCSizeMake(G_VisibleSizeWidth-250,130),descLb,22,kCCTextAlignmentLeft)
    self.bgLayer:addChild(desTv)
    desTv:setPosition(ccp(50,posY))
    desTv:setAnchorPoint(ccp(0,0))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(80)
end

function acWjdcDialog:tick()
    local acVo = acWjdcVoApi:getAcVo()
    if acVo and activityVoApi:isStart(acVo)==false then
        self:close()
    end
end

function acWjdcDialog:dispose()
    local costTime=acWjdcVoApi:getCostTime()
    local time=costTime+base.serverTime-self.openTime
    acWjdcVoApi:setCostTime(time)

    self.cellHeightTb={}
    self.checkSpTb={}
    self.textTb={}
    self.textLbTb={}
    self.editBox={}
    self.titleBg={}
    self.openTime=0
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
end