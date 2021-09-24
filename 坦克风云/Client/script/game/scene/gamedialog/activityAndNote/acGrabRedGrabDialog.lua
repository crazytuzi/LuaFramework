--require "luascript/script/componet/commonDialog"
acGrabRedGrabDialog={

}
function acGrabRedGrabDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=nil
    self.dialogLayer=nil
    self.bgLayer=nil
    self.closeBtn=nil
    self.normalHeight=170
    self.recodeBg = nil
    return nc
end

function acGrabRedGrabDialog:init(layerNum,redid)
    self.layerNum=layerNum

    local function getArmsRaceRecode(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then            
            if sData and sData.data then
                acGrabRedVoApi:updateLog(sData.data)
                self:initLayer(layerNum)
            end
        end
    end
    
    socketHelper:getRedInformation(redid,getArmsRaceRecode)

end

function acGrabRedGrabDialog:initLayer(layerNum)
 
    base:setWait()
    if G_isIphone5() then
        self.normalHeight=220
    end

    local size=CCSizeMake(640,G_VisibleSize.height)

    self.isTouch=false
    self.isUseAmi=true
    if layerNum then
        self.layerNum=layerNum
    else
        self.layerNum=4
    end
    local rect=size
     
    local function touchHander()

    end
   
    
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",CCRect(168, 86, 10, 10),touchHander)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)

    local function close()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn)

    local titleLb
    if G_getCurChoseLanguage() == "de" or G_getCurChoseLanguage() == "en" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="thai" or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="pt" then
          titleLb = GetTTFLabelWrap(getlocal("activity_grabRed_title"),33,CCSizeMake(dialogBg:getContentSize().width-220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
    else
        titleLb= GetTTFLabel(getlocal("activity_grabRed_title"),40)
    end

    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(dialogBg:getContentSize().width/2, dialogBg:getContentSize().height-40))
    dialogBg:addChild(titleLb)


    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",CCRect(168, 86, 10, 10),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,960)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(0)
    touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(touchDialogBg,1)

    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    self:initContent()
    -- self.bgLayer:setPosition(CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
    sceneGame:addChild(self.bgLayer,self.layerNum)

    self:show()



    --return self.bgLayer
end


--设置对话框里的tableView
function acGrabRedGrabDialog:initContent()
    -- base:addNeedRefresh(self)
    
    local chestIconX = 30
    
    local chestIcon=CCSprite:createWithSpriteFrameName("SeniorBox.png")
    local addX = chestIconX + chestIcon:getContentSize().width

    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),function () do return end end)
    girlDescBg:setContentSize(CCSizeMake(450,300))
    girlDescBg:setAnchorPoint(ccp(0,0))
    girlDescBg:setPosition(addX,self.bgLayer:getContentSize().height/2 + 100)
    self.bgLayer:addChild(girlDescBg,1)

    chestIcon:setAnchorPoint(ccp(0,0.5))
    chestIcon:setPosition(chestIconX, self.bgLayer:getContentSize().height/2 + 250)
    self.bgLayer:addChild(chestIcon)



    local sharer = acGrabRedVoApi:getGrabSharer()
    if sharer ~= nil and SizeOfTable(sharer) == 2 then
        local sharerLb = GetTTFLabel(getlocal("activity_grabRed_sharer",{sharer[2]}), 30)
        sharerLb:setAnchorPoint(ccp(0,1))
        sharerLb:setPosition(ccp(20, girlDescBg:getContentSize().height - 20))
        sharerLb:setColor(G_ColorYellowPro)
        girlDescBg:addChild(sharerLb)

        local desc = getlocal("activity_grabRed_shareDesc",{sharer[2]})
        local chestDesc=GetTTFLabelWrap(desc,25,CCSizeMake(400, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        chestDesc:setAnchorPoint(ccp(0,1))
        chestDesc:setPosition(ccp(20,girlDescBg:getContentSize().height - 40 - sharerLb:getContentSize().height))
        girlDescBg:addChild(chestDesc)
    end

    self:update()
    
end

function acGrabRedGrabDialog:showNoRecodeTitle()
    local noRecode = GetTTFLabel(getlocal("activity_grabRed_noGraber"), 25)
    noRecode:setAnchorPoint(ccp(0.5,0))
    noRecode:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.recodeBg:getContentSize().height/2))
    self.recodeBg:addChild(noRecode)
end


function acGrabRedGrabDialog:update()
    if self.recodeBg ~= nil then
        self.recodeBg:removeFromParentAndCleanup(true)
    end

    local function bgClick(hd,fn,idx)
    end
    self.recodeBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65, 25, 1, 1),bgClick)
    self.recodeBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 40,400))
    self.recodeBg:setAnchorPoint(ccp(0.5,1))
    self.recodeBg:setPosition(ccp(G_VisibleSize.width/2,self.bgLayer:getContentSize().height/2 + 80))
    self.recodeBg:setTouchPriority(0)
    self.bgLayer:addChild(self.recodeBg)

    local grabTitle = GetTTFLabel(getlocal("activity_grabRed_grabRecodeTitle"), 30)
    grabTitle:setAnchorPoint(ccp(0,0))
    grabTitle:setColor(G_ColorGreen)
    grabTitle:setPosition(ccp(30, self.recodeBg:getContentSize().height - 50))
    self.recodeBg:addChild(grabTitle)

    local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSP:setAnchorPoint(ccp(0.5,0.5))
    lineSP:setScaleX(G_VisibleSizeWidth/lineSP:getContentSize().width)
    lineSP:setScaleY(1.2)
    lineSP:setPosition(ccp(self.recodeBg:getContentSize().width/2,self.recodeBg:getContentSize().height - grabTitle:getContentSize().height - 20))
    self.recodeBg:addChild(lineSP)

    local vo = acGrabRedVoApi:getAcVo()
    local isStart = false
    if vo ~= nil then
        isStart = activityVoApi:isStart(vo)
    end

    local recodes = acGrabRedVoApi:getGrabRecode()
    local grabOver = acGrabRedVoApi:checkIfGrabOver() -- 红包是否已经抢完了
    local sharer = acGrabRedVoApi:getGrabSharer()
    local grabed = false
    if sharer ~= nil and SizeOfTable(sharer) == 2 then
        grabed = acGrabRedVoApi:checkIfGrabedByRedid(sharer[1]) -- 我是否抢到了该红包
    end
    local tip = nil
    if recodes ~= nil then
        local len = SizeOfTable(recodes)
        if len > 0 then
            local index = 0
            local singeH = 50
            local totoalH = self.recodeBg:getContentSize().height - 100
            for k,v in pairs(recodes) do
                if v ~= nil then
                    local recode = GetTTFLabel(getlocal("activity_grabRed_grabRecode",{v[1], v[2]}), 25)
                    self.recodeBg:addChild(recode)
                    recode:setAnchorPoint(ccp(0,0))
                    recode:setPosition(ccp(50, totoalH - index * singeH))
                    index = index + 1
                end
            end
            if isStart == false then
            elseif grabOver == true then
                tip = getlocal("activity_grabRed_grabOver")
            elseif grabed == true then
                tip = getlocal("activity_grabRed_grabSuccess")
            end
            

        else   
            self:showNoRecodeTitle()
        end
    else
        self:showNoRecodeTitle()
    end
    if isStart == false then
        tip = getlocal("activity_grabRed_redNotExist")
    end

    if tip ~= nil then
        local grabOverLb = GetTTFLabel(tip, 25)
        grabOverLb:setAnchorPoint(ccp(0.5,0))
        grabOverLb:setPosition(ccp(self.recodeBg:getContentSize().width/2, -50))
        grabOverLb:setColor(G_ColorRed)
        self.recodeBg:addChild(grabOverLb)
    end

    local function onGrab(tag,object)
        local grabOver = acGrabRedVoApi:checkIfGrabOver() -- 红包是否已经抢完了
        local sharer = acGrabRedVoApi:getGrabSharer()
        local grabed = false
        local redid = 0
        if sharer ~= nil and SizeOfTable(sharer) == 2 then
            redid = sharer[1]
            grabed = acGrabRedVoApi:checkIfGrabedByRedid(redid) -- 我是否抢到了该红包
        end

        if grabOver == true or grabed == true then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        else
            local function grabCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    local flag = sData.data.flag
                    local flagTip = nil
                    if flag == 1 then -- 红包抢夺成功
                        flagTip = getlocal("activity_grabRed_grabSuccess")
                    elseif flag == 2 then --已经领取过
                        flagTip = getlocal("activity_grabRed_grabed")
                    elseif flag == 3 then -- 红包不存在
                        flagTip = getlocal("activity_grabRed_redNotExist")
                    elseif flag == 4 then -- 红包派发完了
                        flagTip = getlocal("activity_grabRed_grabOver")
                    end


                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),flagTip,30)
                    acGrabRedVoApi:updateLog(sData.data)
                    local redid = 0
                    if sharer ~= nil and SizeOfTable(sharer) == 2 then
                        redid = sharer[1]
                    end
                    acGrabRedVoApi:updateGrabed(redid)
                    -- 抢到的代币
                    if sData.data.subgems and sData.data.subgems > 0 then
                        acGrabRedVoApi:addCurrentPoint(sData.data.subgems)
                    end
                    self:update()
                end
            end
            if redid > 0 then
                socketHelper:grabRed(redid,grabCallback)
            end
        end
    end
    
    local btnStr
    if grabOver == true or grabed == true then
        btnStr = getlocal("ok")
    else
        btnStr = getlocal("activity_grabRed_grab")
    end

    local grabItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onGrab,nil,btnStr,25)

    grabItem:setAnchorPoint(ccp(0.5,0.5))
    local grabBtn=CCMenu:createWithItem(grabItem)
    grabBtn:setAnchorPoint(ccp(0.5,0.5))
    grabBtn:setPosition(ccp(self.recodeBg:getContentSize().width/2, -100))
    grabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.recodeBg:addChild(grabBtn)
end


function acGrabRedGrabDialog:tick()

end
function acGrabRedGrabDialog:close()

    if hasAnim==nil then
        hasAnim=true
    end
    base.allShowedCommonDialog=base.allShowedCommonDialog-1
    for k,v in pairs(base.commonDialogOpened_WeakTb) do
         if v==self then
            table.remove(base.commonDialogOpened_WeakTb,k)
            break
         end
    end
    if base.allShowedCommonDialog<0 then
        base.allShowedCommonDialog=0
    end
    local function realClose()
        return self:realClose()
    end
    if base.allShowedCommonDialog==0 and storyScene.isShowed==false then
        if portScene.clayer~=nil then
            if sceneController.curIndex==0 then
                portScene:setShow()
            elseif sceneController.curIndex==1 then
                mainLandScene:setShow()
            elseif sceneController.curIndex==2 then
                worldScene:setShow()
            end
            mainUI:setShow()
        end
    end
   -- base:removeFromNeedRefresh(self) --停止刷新
   local fc= CCCallFunc:create(realClose)
   local moveTo=CCMoveTo:create((hasAnim==true and 0.3 or 0),CCPointMake(G_VisibleSize.width/2,-self.bgLayer:getContentSize().height))
   local acArr=CCArray:create()
   acArr:addObject(moveTo)
   acArr:addObject(fc)
   local seq=CCSequence:create(acArr)
   self.bgLayer:runAction(seq)

end
function acGrabRedGrabDialog:realClose()

    self.bgLayer:removeFromParentAndCleanup(true)
    self:dispose()

end
--显示面板,加效果
function acGrabRedGrabDialog:show()
   local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
   local function callBack()
        if portScene.clayer~=nil then
            if sceneController.curIndex==0 then
                portScene:setHide()
            elseif sceneController.curIndex==1 then
                mainLandScene:setHide()
            elseif sceneController.curIndex==2 then
                worldScene:setHide()
            end
            
          
            mainUI:setHide()
            --self:getDataByType() --只有Email使用这个方法
        end
       base:cancleWait()
   end
   base.allShowedCommonDialog=base.allShowedCommonDialog+1
   table.insert(base.commonDialogOpened_WeakTb,self)
   local callFunc=CCCallFunc:create(callBack)
   local seq=CCSequence:createWithTwoActions(moveTo,callFunc)
   self.bgLayer:runAction(seq)
end
function acGrabRedGrabDialog:dispose()
    self.layerNum=nil
    self.dialogLayer=nil
    self.bgLayer=nil
    self.closeBtn=nil
    self.normalHeight=nil
    -- base:removeFromNeedRefresh(self) --停止刷新
    self.recodeBg = nil
    self=nil
end
