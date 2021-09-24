acWpbdTabTwo = {}

function acWpbdTabTwo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
    nc.tv        = nil
    nc.bgLayer   = nil
    nc.isIphone5 = G_isIphone5()

    nc.timeLb       = nil
    nc.bgWidth      = 0
    nc.upPosY       = G_VisibleSizeHeight-160
    nc.upHeight     = 222
    nc.awardTb      = {}
    nc.url  = G_downloadUrl("active/".."acWpbdBg.jpg") or nil
    return nc    
end

function acWpbdTabTwo:dispose( )
    if self.exSelfTankPanel and self.exSelfTankPanel.close then
        self.exSelfTankPanel:close()
    end
    self.url        = nil
    self.upPosY       = nil
    self.upHeight     = nil
    self.timeLb       = nil
    self.bgWidth      = nil
    self.tv           = nil
    self.bgLayer      = nil
    self.layerNum     = nil
    self.isIphone5    = nil
    self.exSelfTankPanel = nil
    self.awardTb   = nil
end
function acWpbdTabTwo:initUrl( )
    local function onLoadIcon(fn,icon)
        icon:setAnchorPoint(ccp(0.5,1))
        icon:setPosition(G_VisibleSizeWidth * 0.5,self.upPosY)
        icon:setScaleX(G_VisibleSizeWidth/icon:getContentSize().width)
        icon:setScaleY(self.upPosY/icon:getContentSize().height)
        self.bgLayer:addChild(icon)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end
function acWpbdTabTwo:init(layerNum)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    self.bgWidth  = self.bgLayer:getContentSize().width-40
    self.cellHeight= G_isAsia and 120 or 150
    -- self:initUrl()
    self:refresh()
    self:initTableView()
    return self.bgLayer
end

function acWpbdTabTwo:chatMessage(propTb)
    local paramTab={}
    paramTab.functionStr="wpbd"
    paramTab.addStr="take_part"
    local chatKey = "activity_yrj_chat"
    local message={key=chatKey,param={playerVoApi:getPlayerName(),propTb.name.." x"..propTb.num,getlocal("activity_wpbd_title")}}
    chatVoApi:sendSystemMessage(message,paramTab)
end
function acWpbdTabTwo:refresh()
    self.awardTb,self.cellNum = acWpbdVoApi:arrayShowTb()
    if self.tv then
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    self:onlyRefrsehScore()
end

function acWpbdTabTwo:onlyRefrsehScore()
    if self.scoreStr then
        self.scoreStr:setString(acWpbdVoApi:getAllScore())
        if self.exchangeMenu then
            self.exchangeMenu:setPositionX(self.scoreStr:getPositionX() + self.scoreStr:getContentSize().width + 5)
        end
    end
end

function acWpbdTabTwo:initTableView( )
    local w=G_VisibleSizeWidth-40 --背景框的宽度

    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function () end)
    backSprie:setContentSize(CCSizeMake(w,120))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.upPosY))
    self.bgLayer:addChild(backSprie,10)
    -- backSprie:setOpacity(0)

    local backSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function () end)
    backSprie2:setContentSize(CCSizeMake(w,120))
    backSprie2:setOpacity(0)
    backSprie2:setTouchPriority(-(self.layerNum-1)*20-4)
    backSprie2:setIsSallow(true)
    backSprie2:setAnchorPoint(ccp(0.5,1))
    backSprie2:setPosition(ccp(G_VisibleSizeWidth * 0.5,self.upPosY))
    self.bgLayer:addChild(backSprie2,9)

    -- local scoreItem = acYrjVoApi:getScoreItem(75,65)
    local useHeight = backSprie:getContentSize().height

    local scoreName = GetTTFLabel(getlocal("serverwar_point")..": ",24,"Helvetica-bold")
    scoreName:setAnchorPoint(ccp(0,0.5))
    scoreName:setPosition(ccp(15,useHeight * 0.7))
    backSprie:addChild(scoreName)
    local useUpPosy = scoreName:getPositionY()

    local scorePic = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png");
    scorePic:setAnchorPoint(ccp(0,0.5))
    scorePic:setScale(0.8)
    scorePic:setPosition(ccp(scoreName:getContentSize().width + 15,useUpPosy))
    backSprie:addChild(scorePic)

    -- print("acWpbdVoApi:getAllScore()=====>>>>",acWpbdVoApi:getAllScore())
    local scoreStr = GetTTFLabel(acWpbdVoApi:getAllScore(),24,"Helvetica-bold")
    scoreStr:setAnchorPoint(ccp(0,0.5))
    scoreStr:setPosition(ccp(scorePic:getPositionX() + scorePic:getContentSize().width * 0.8 + 4,useUpPosy))
    backSprie:addChild(scoreStr)
    self.scoreStr = scoreStr
    local btnUsePosx = scoreStr:getPositionX() + scoreStr:getContentSize().width + 10

    local function exchangeCall( )
        self:exchangeInfoCall() 
    end
    local btnScale,priority = 1,-(self.layerNum-1)*20-5
    local exchangeBtn,exchangeMenu = G_createBotton(backSprie,ccp(btnUsePosx,useUpPosy),nil,"newAddBtn.png","newAddBtn.png","newAddBtn.png",exchangeCall,btnScale,priority,nil,nil,ccp(0,0.5))
    self.exchangeMenu = exchangeMenu

    local upTip2 = GetTTFLabelWrap(getlocal("activity_wpbd_tab2_upTip2"),22,CCSizeMake(self.bgWidth - 150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    upTip2:setAnchorPoint(ccp(0,0.5))
    upTip2:setPosition(ccp(15,useHeight * 0.26))
    backSprie:addChild(upTip2)

    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        acWpbdVoApi:showTipDia(2,self.layerNum + 1)
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,nil,0)
    menuItemDesc:setScale(1)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(w - 40,useHeight * 0.5))
    backSprie:addChild(menuDesc,2)

    self.tvHeight = self.upPosY - useHeight
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setContentSize(CCSizeMake(self.bgWidth,self.tvHeight-10))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(20,10)
    self.bgLayer:addChild(tvBg)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgWidth,self.tvHeight-14),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,10))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acWpbdTabTwo:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.bgWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local exchangeInfoTb = self.awardTb[idx + 1]
        local propTb = FormatItem(exchangeInfoTb.reward)[1]

        local lbNameFontSize,nameSubPosY,desSize2,strPosx = 22,30,20,95
        if G_isAsia() == false then
            lbNameFontSize,nameSubPosY,desSize2= 20,16,15
        end

        local nameLb=GetTTFLabel(propTb.name,lbNameFontSize)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setColor(G_ColorGreen)
        nameLb:setPosition(ccp(strPosx,self.cellHeight-nameSubPosY))
        cell:addChild(nameLb)

        local curExNum = exchangeInfoTb.curExchangeNum > exchangeInfoTb.limitNum and exchangeInfoTb.limitNum or exchangeInfoTb.curExchangeNum
        local limitLb=GetTTFLabel("("..curExNum.."/"..exchangeInfoTb.limitNum..")",lbNameFontSize)
        limitLb:setAnchorPoint(ccp(0,0.5))
        limitLb:setPosition(ccp(2+nameLb:getContentSize().width+5 + nameLb:getPositionX(),nameLb:getPositionY()))
        cell:addChild(limitLb)

        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,propTb,nil,nil,nil,nil,true)
            return false
        end
        local icon,scale=G_getItemIcon(propTb,100,true,self.layerNum+1,showNewPropInfo)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setTouchPriority(-(self.layerNum-1)*20-3)
        icon:setPosition(ccp(10,self.cellHeight*0.5))
        cell:addChild(icon)
        icon:setScale(80/icon:getContentSize().width)

        local curCostNum,colorTb = acWpbdVoApi:getCurCostNum(),{}
        colorTb = curCostNum < exchangeInfoTb.costNum and {nil,G_ColorRed,nil} or {nil,G_ColorYellow,nil}
        curCostNum = curCostNum < exchangeInfoTb.costNum and curCostNum or exchangeInfoTb.costNum

        local adaWidth = 0
        if G_getCurChoseLanguage() == "ar" then
            adaWidth = 100
        end

        local descLb = G_getRichTextLabel(getlocal("activity_wpbd_tab2_exRule",{curCostNum,exchangeInfoTb.costNum}),colorTb,desSize2,self.bgWidth-150,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0,1))
        descLb:setPosition(ccp(strPosx-adaWidth,(self.cellHeight-20)*0.5 + 5))
        cell:addChild(descLb)

        local itemW=icon:getContentSize().width * scale
        local numLb=GetTTFLabel("x"..propTb.num,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(itemW-5,5))
        numLb:setScale(1/icon:getScale())
        icon:addChild(numLb,1)


        local gemIcon=CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png");
        gemIcon:setScale(0.8)
        cell:addChild(gemIcon,2)
        local lbPrice=GetTTFLabel(exchangeInfoTb.p,24)
        
        lbPrice:setAnchorPoint(ccp(0,0.5));
        cell:addChild(lbPrice,2)

        local function touch1(tag,object)
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            self:exchangeFun(tonumber(tag),exchangeInfoTb,propTb)
        end
        local menuItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touch1,idx + 1,getlocal("activity_loversDay_tab2"),35,100)
        menuItem:setScale(0.6)
        menuItem:setEnabled(true);
        local menu3=CCMenu:createWithItem(menuItem);
        menu3:setPosition(ccp(self.bgWidth - menuItem:getContentSize().width*0.5*0.65 - 5,35))
        menu3:setTouchPriority(-(self.layerNum-1)*20-3);
        cell:addChild(menu3,6)

        if exchangeInfoTb.state == 2 then
            menuItem:setEnabled(false)
            menu3:setEnabled(false)
        elseif exchangeInfoTb.state == 1 then
            lbPrice:setColor(G_ColorRed)
        end

        local menu3Posx = menu3:getPositionX()
        if exchangeInfoTb.oldId < 5 then
            numLb:setPositionX(icon:getContentSize().width)
            gemIcon:setPosition(ccp(menu3Posx - menuItem:getContentSize().width * 0.6 * 0.25,self.cellHeight*0.65))
            lbPrice:setPosition(ccp(menu3Posx - 5,self.cellHeight*0.65))
            G_addRectFlicker2(icon,1.7,1.7,3,"y",nil,55)
        else
            gemIcon:setPosition(ccp(menu3Posx -25,self.cellHeight*0.64))
            lbPrice:setPosition(ccp(menu3Posx + 5,self.cellHeight*0.65))
            if numLb and propTb.num >= 10000 and propTb.type ~= "p" then
                numLb:setFontSize(20)
            end
        end

        local line =LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
        line:setContentSize(CCSizeMake(self.bgWidth - 80,line:getContentSize().height))
        line:setPosition(ccp(self.bgWidth * 0.5,0))
        cell:addChild(line,99)
        return cell
    end
end

function acWpbdTabTwo:exchangeFun(tag,shopAllInfoTb,propTb)
    
    PlayEffect(audioCfg.mouseClick)
    if shopAllInfoTb.state == 1 or shopAllInfoTb.state == 3 then
        local tipStr = shopAllInfoTb.state == 1 and getlocal("serverwar_point_not_enough") or getlocal("activity_calls_wrong4")
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,28)
            do return end 
    end
    local function sureClick()
        local function requestHandler(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data then
                    if sData.data.wpbd then
                        acWpbdVoApi:updateSpecialData(sData.data.wpbd)
                        self:refresh()
                        local rewardlist = {}
                        table.insert(rewardlist,propTb)
                        G_addPlayerAward(propTb.type,propTb.key,propTb.id,propTb.num,nil,true)
                        if shopAllInfoTb.oldId < 5 then
                            self:chatMessage(propTb,shopAllInfoTb.oldId)
                        end
                        G_showRewardTip(rewardlist,true)
                    end
                end
            end
        end
        local params = {id="i"..shopAllInfoTb.oldId}
        socketHelper:acWpbdRequest("buy",params,requestHandler)-------------------- we need
    end

    local keyName=acWpbdVoApi:getActiveName().."2"
    local function secondTipFunc(sbFlag)
        
        local sValue=base.serverTime .. "_" .. sbFlag
        G_changePopFlag(keyName,sValue)
    end
    
    local useScore = shopAllInfoTb.p
    local strSize3 = G_isAsia() and 25 or 22
    if G_isPopBoard(keyName) then--
        self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("activity_wpbd_tab2_exSecondTip",{useScore,propTb.name}),true,sureClick,secondTipFunc,nil,{strSize3})
    else
        sureClick()
    end
end

function acWpbdTabTwo:exchangeInfoCall()
    require "luascript/script/game/scene/gamedialog/activityAndNote/reuseSliderPanel"
    local td=reuseSliderPanel:new()
    local exSelfTankPanel=td:init(self.layerNum + 1,self,"wpbd");
    self.exSelfTankPanel = td
    sceneGame:addChild(exSelfTankPanel,self.layerNum + 1)
end
