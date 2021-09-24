local TIME_DELAY  = 1.5
local TIME_MOVE   = 1

local __ColorUtil=_G.ColorUtil
local LDel=_G.Const.CONST_LOGS_DEL
local LAdd=_G.Const.CONST_LOGS_ADD
local CWhite=_G.Const.CONST_COLOR_WHITE
local CRed=_G.Const.CONST_COLOR_RED
local CGreen=_G.Const.CONST_COLOR_BROWN

local Logs=classGc(view, function(self)
    self.m_winSize=cc.Director:getInstance():getVisibleSize()

    self:init()
    self:initMarquee()

    local pMediator=require("mod.logs.LogsMediator")(self)
    self.regMediatorAgain=function(self)
        pMediator:regSelfLong()
    end

    self.m_isShowMarqueeIng=true
end)

function Logs.init(self)
    self.m_attrMsgArray   = {}
    self.m_errorTipsArray = {}
    self.m_lLogTime    =0
    self.m_lMarqueeTime=0

    self.m_errorSprArray={}
end
function Logs.initMarquee(self)
    self.m_marqueeList ={}
end
function Logs.showMarquee(self)
    if self.m_marqueeBg==nil then
        self:__initMarqueeView()
    else
        local tempNode=self.m_marqueeScrollView:getContainer()
        if tempNode~=nil then
            tempNode:removeAllChildren(true)
        end
    end

    self.m_isShowMarqueeIng=false

    -- print("showMarquee=============>>>>>>>",#self.m_marqueeList)
    if #self.m_marqueeList==0 then return end

    self:__autoShowMarquee()
end

function Logs.__initMarqueeView(self)
    local function nFun(event)
        if event=="cleanup" then
            print("AFEWWWWWWWWWWWWW=========>>>>")
            self.m_isShowMarqueeIng=false
            local tempNode=self.m_marqueeScrollView:getContainer()
            if tempNode~=nil then
                tempNode:removeAllChildren(true)
            end
        end
    end
    local marqueeSize=cc.size(self.m_winSize.width,34)
    self.m_marqueeBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_fram_gg.png")
    self.m_marqueeBg:setPreferredSize(marqueeSize)
    self.m_marqueeBg:setPosition(self.m_winSize.width*0.5,640-marqueeSize.height*0.5)
    self.m_marqueeBg:retain()
    self.m_marqueeBg:registerScriptHandler(nFun)

    local scoView=cc.ScrollView:create()
    scoView:setDirection(ccui.ScrollViewDir.vertical)
    scoView:setTouchEnabled(false)
    scoView:setViewSize(marqueeSize)
    scoView:setDelegate()
    self.m_marqueeBg:addChild(scoView)
    self.m_marqueeScrollView=scoView
end

function Logs.__autoShowMarquee(self)
    if self.m_isShowMarqueeIng then return end

    self.m_marqueeBg:stopAllActions()
    if #self.m_marqueeList>0 then
        self:__runNextMarquee()
    else
        local function nFun(_node)
            _node:removeFromParent(true)
        end
        self.m_marqueeBg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(nFun)))
    end
end
function Logs.initMarqueeParent(self,_node)
    local isShow=false
    if not self.m_isShowMarqueeIng then
        if #self.m_marqueeList>0 then
            isShow=true
        else
            return
        end
    end

    if self.m_marqueeBg==nil then
        self:__initMarqueeView()
    end

    local curParent=self.m_marqueeBg:getParent()
    if not _node then
        if curParent then
            self.m_marqueeBg:removeFromParent(false)
        end
    else
        if curParent==_node then return end

        if curParent then
            self.m_marqueeBg:removeFromParent(false)
        end
        _node:addChild(self.m_marqueeBg,_G.Const.CONST_MAP_ZORDER_MARQUEE)
    end

    if isShow then
        self:showMarquee()
    end
end
function Logs.__runNextMarquee(self)
    if _G.g_Stage==nil or _G.g_Stage.isRelease then return end

    self.m_isShowMarqueeIng=true

    local curParent=self.m_marqueeBg:getParent()
    if curParent==nil then
        self:initMarqueeParent(cc.Director:getInstance():getRunningScene())
    elseif not curParent:isRunning() then
        self:initMarqueeParent(cc.Director:getInstance():getRunningScene())
    end

    local marMsg=table.remove(self.m_marqueeList,1)
    local contentArray=marMsg.contentArray
    local tempNode=cc.Node:create()
    self.m_marqueeScrollView:addChild(tempNode)

    local tempWidth=0
    local leftPoint=cc.p(0,0.5)
    for i=1,#contentArray do
        local tempLabel=_G.Util:createLabel(contentArray[i].str,18)
        tempLabel:setAnchorPoint(leftPoint)
        tempLabel:setColor(_G.ColorUtil:getRGB(contentArray[i].color or _G.Const.CONST_COLOR_WHITE))
        tempLabel:setPosition(tempWidth,0)
        tempNode:addChild(tempLabel)

        tempWidth=tempWidth+tempLabel:getContentSize().width
    end
    local nodeX=self.m_winSize.width*0.5-tempWidth*0.5
    tempNode:setPosition(nodeX,-30)

    local function nFun1(_node)
        _node:removeFromParent(true)
    end
    local function nFun2(_node)
        self.m_isShowMarqueeIng=false
        self:__autoShowMarquee()
    end

    local dTime
    local nCount=#self.m_marqueeList
    if nCount>5 then
        dTime=2
    elseif nCount>1 then
        dTime=3
    else
        dTime=5
    end

    local nAction=cc.Sequence:create(cc.MoveTo:create(0.3,cc.p(nodeX,15)),
                                    cc.DelayTime:create(dTime),
                                    cc.CallFunc:create(nFun2),
                                    cc.MoveTo:create(0.3,cc.p(nodeX,60)),
                                    cc.CallFunc:create(nFun1))
    tempNode:runAction(nAction)
end

function Logs.pushMarquee(self,_tempData)
    local isIdx=#self.m_marqueeList+1
    for i=1,isIdx-1 do
        if self.m_marqueeList[i].level>_tempData.level then
            isIdx=i
            break
        end
    end
    table.insert(self.m_marqueeList,isIdx,_tempData)

    print("pushMarquee=========>>>>>>",self.m_isShowMarqueeIng,#self.m_marqueeList,_tempData.contentArray,_tempData.level)

    self:__autoShowMarquee()
end

function Logs.pushLog(self,_msg)
    self.m_attrMsgArray[#self.m_attrMsgArray+1]=_msg
end

function Logs.show(self,_nowTime)
    -- local stage=_G.g_Stage
    -- if stage~=nil and not stage.m_finallyInitialize then
    --     if not stage.m_bIsInit then
    --         self:__autoShowNormalLog(_nowTime)
    --     end
    --     return
    -- end

    self:__autoShowNormalLog(_nowTime)
end

function Logs.__autoShowNormalLog(self,_nowTime)
    if self.isFloatOut then
        return
    end
   
    if _G.g_Stage==nil or not _G.g_Stage.m_finallyInitialize then return end
    -- print("__autoShowNormalLog====>>>  1")

    if #self.m_attrMsgArray<=0 then
        self.m_lLogTime=_nowTime
        return
    end

    local len=#self.m_attrMsgArray*30
    if len>330 then
        len=330
    end
    if _nowTime-self.m_lLogTime<=400-len then
        return
    end

    -- print("__autoShowNormalLog>>>>>>",#self.m_attrMsgArray)
    local tempMsg=table.remove(self.m_attrMsgArray,1)
    self:__showAttrLog(tempMsg)
    -- self:__showNormalLog(tempMsg)

    self.m_lLogTime=_nowTime
end

function Logs.showErrorTips(self,_tipsData)
    if not _tipsData then return end

    local runningScene=cc.Director:getInstance():getRunningScene()
    if self.m_preNode~=runningScene then
        if self.m_preNode~=nil then
            if not tolua.isnull(self.m_preNode) then
                for k,v in pairs(self.m_errorTipsArray) do
                    if v.onePan~=nil then
                        v.onePan:removeFromParent(true)
                    end
                end
            end
        end

        self.m_preNode=runningScene
        self.m_errorTipsArray={}
    end

    local tipsBgBtn=ccui.Scale9Sprite:createWithSpriteFrameName("general_box_hint.png")
    tipsBgBtn:setScale(0.01)
    tipsBgBtn:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    runningScene:addChild(tipsBgBtn,_G.Const.CONST_MAP_ZORDER_NOTIC+10)

    local nMinSize=cc.size(52,52)
    local maxWidth=nMinSize.width
    local maxHeight=nMinSize.height
    local childIdx=0
    local childArray={}

    local strArray,faceId
    if type(_tipsData)=="number" then
        local errorCnf=_G.Cfg.errorcode[_tipsData]
        if errorCnf~=nil then
            strArray=errorCnf.t
            faceId=errorCnf.f
        else
            strArray={{t=string.format("未配置错误常量 id=%d",_tipsData)}}
        end
    else
        strArray=_tipsData.t
        faceId=_tipsData.f
    end

    if strArray~=nil then
        local nodeIdx=1
        local nodeArray={}
        local nodeWidth={}
        for k,v in ipairs(strArray) do
            if not(v.t=="br" )then
                -- print("v.t===>",v.t)
                if nodeArray[nodeIdx]==nil then
                    nodeArray[nodeIdx]=cc.Node:create()
                    nodeWidth[nodeIdx]=0
                end
                local tempLabel=_G.Util:createLabel(v.t,18)
                tempLabel:setAnchorPoint(0,0.5)
                tempLabel:setColor(__ColorUtil:getRGB(v.c or CWhite))
                tempLabel:setPosition(nodeWidth[nodeIdx],0)
                nodeArray[nodeIdx]:addChild(tempLabel)

                childIdx=childIdx+1
                childArray[childIdx]=tempLabel

                local nSize=tempLabel:getContentSize()
                nodeWidth[nodeIdx]=nodeWidth[nodeIdx]+nSize.width
            elseif nodeIdx==2 then
                break
            else
                nodeIdx=nodeIdx+1
                maxHeight=60
            end
        end

        local nodeCount=#nodeArray
        if nodeCount>0 then
            if faceId and faceId>0 then
                local nScale=0.5
                local faceStr= string.format("chat_%.2d.png",faceId)
                local smileSpr=cc.Sprite:createWithSpriteFrameName(faceStr)
                local nSize=smileSpr:getContentSize()
                nSize=cc.size(nSize.width*nScale,nSize.height*nScale)
                nodeWidth[nodeCount]=nodeWidth[nodeCount]+nSize.width+5
                smileSpr:setScale(nScale)
                smileSpr:setPosition(nodeWidth[nodeCount]-nSize.width*0.5,0)
                nodeArray[nodeCount]:addChild(smileSpr)

                childIdx=childIdx+1
                childArray[childIdx]=smileSpr
            end

            if nodeCount>1 then
                maxWidth=nodeWidth[1]>nodeWidth[2] and nodeWidth[1] or nodeWidth[2]
                maxWidth=(maxWidth>nMinSize.width and maxWidth or nMinSize.width)+20

                tipsBgBtn:addChild(nodeArray[1])
                tipsBgBtn:addChild(nodeArray[2])
                nodeArray[1]:setPosition(maxWidth*0.5-nodeWidth[1]*0.5,maxHeight*0.5+15)
                nodeArray[2]:setPosition(maxWidth*0.5-nodeWidth[2]*0.5,maxHeight*0.5-15)
            else
                maxWidth=(maxWidth>nodeWidth[1] and maxWidth or nodeWidth[1])+20

                tipsBgBtn:addChild(nodeArray[1])
                nodeArray[1]:setPosition(maxWidth*0.5-nodeWidth[1]*0.5,maxHeight*0.5)
            end
            tipsBgBtn:setContentSize(cc.size(maxWidth,maxHeight))
        end
    end

    local function nFun1(_node)
        _node:removeFromParent(true)
        table.remove(self.m_errorTipsArray,1)
    end

    local nTimes=0.15
    local function nFun2(_node)
        _node:runAction(cc.Sequence:create(cc.FadeTo:create(nTimes,0),cc.CallFunc:create(nFun1)))
        for i=1,#childArray do
            childArray[i]:runAction(cc.FadeTo:create(nTimes,0))
        end
    end
    local actionss=cc.Sequence:create(  cc.ScaleTo:create(0.2,1.1),
                                        cc.ScaleTo:create(0.08,1),
                                        cc.DelayTime:create(TIME_DELAY*2-1),
                                        cc.CallFunc:create(nFun2))
    tipsBgBtn:runAction(actionss)

    tipsBgBtn:setOpacity(0)
    tipsBgBtn:runAction(cc.FadeTo:create(nTimes,255))
    for i=1,#childArray do
        childArray[i]:setOpacity(0)
        childArray[i]:runAction(cc.FadeTo:create(nTimes,255))
    end

    local nTable ={}
    nTable.height=maxHeight+2
    nTable.onePan=tipsBgBtn
    table.insert(self.m_errorTipsArray,nTable)
    if #self.m_errorTipsArray>1 then
        for k,v in pairs(self.m_errorTipsArray) do
            if v.onePan~=nil and k~=#self.m_errorTipsArray then
                local actionss=cc.Sequence:create(cc.MoveBy:create(TIME_MOVE/2,cc.p(0,v.height)))
                v.onePan:runAction(actionss)
            end
        end
    end
end

function Logs.__showNormalLog( self, _tempList )
    -- print("Logs.__showNormalLog===>",_tempList.szString)
    local nodeContainer=cc.Node:create()
    nodeContainer:setPosition(self.m_winSize.width*0.5,480)
    local scene=cc.Director:getInstance():getRunningScene()
    scene:addChild(nodeContainer,_G.Const.CONST_MAP_ZORDER_NOTIC+1000)

    local lpString=_G.Util:createLabel(_tempList.szString,26)
    lpString:setColor(_tempList.szColor)
    nodeContainer:addChild(lpString)

    local function onCallBack()
        nodeContainer:removeFromParent(true)
        nodeContainer=nil
    end

    local actionss=cc.Sequence:create(cc.MoveBy:create(1.5,cc.p(0,130)),cc.CallFunc:create(onCallBack))
    nodeContainer:runAction(actionss)
end
function Logs.__showAttrLog(self,_msg)
    print("__showAttrLog-->",_msg)
    local sybol=_msg.states
    local attrType=_msg.id
    local attrValue=_msg.value
     
     print("_msg.states---->",_msg.states,_msg.id,_msg.value)

    local leftPoint=cc.p(0,0.5)
    local tempNode=cc.Node:create()
    local attrSpr=cc.Sprite:createWithSpriteFrameName(string.format("chat_attr_pow%d.png",sybol))
    attrSpr:setAnchorPoint(leftPoint)
    tempNode:addChild(attrSpr)

    local tempSize=attrSpr:getContentSize()
    local tempWidth=tempSize.width
    local sybolSpr=cc.Sprite:createWithSpriteFrameName(string.format("chat_attr_sybol%d.png",sybol))
    sybolSpr:setAnchorPoint(leftPoint)
    sybolSpr:setPosition(tempWidth,0)
    tempNode:addChild(sybolSpr)
    
    tempWidth=tempWidth+sybolSpr:getContentSize().width
    local strValue=tostring(attrValue)
    local numSprArray={}


    for i=1,string.len(strValue) do
        local num=string.sub(strValue,i,i)
        local szNum=string.format("chat_attr_num%d_%d.png",sybol,num)
        local numSpr=cc.Sprite:createWithSpriteFrameName(szNum)
        numSpr:setAnchorPoint(leftPoint)
        numSpr:setPosition(tempWidth,0)
        tempNode:addChild(numSpr)

        numSprArray[i]=numSpr
        tempWidth=tempWidth+numSpr:getContentSize().width
    end
    numSprArray[#numSprArray+1]=attrSpr
    numSprArray[#numSprArray+1]=sybolSpr

    local endOffX=math.random(0,100)
    local endOffY=math.random(0,40)+80
    endOffX=math.random()<0.5 and -endOffX or endOffX
    endOffY=sybol==_G.Const.CONST_LOGS_DEL and -endOffY or endOffY

    local function nFun2()
        tempNode:removeFromParent(true)
    end
    local function nFun1()
        local nTimes=0.3
        for i=1,#numSprArray do
            numSprArray[i]:runAction(cc.FadeTo:create(nTimes,0))
        end
        local nOffX=endOffX*0.1
        tempNode:runAction(cc.Sequence:create(cc.ScaleTo:create(nTimes,0.8),cc.CallFunc:create(nFun2)))
        tempNode:runAction(cc.MoveBy:create(nTimes,cc.p(nOffX,0)))
    end
    local nTimes=0.6
    tempNode:runAction(cc.Sequence:create(cc.MoveBy:create(nTimes,cc.p(endOffX,endOffY)),
                                          cc.CallFunc:create(nFun1)))
    tempNode:runAction(cc.ScaleTo:create(nTimes,1.15))

    if self.m_attrContainer~=nil then
        tempNode:setPosition(-tempWidth*0.5,0)
        self.m_attrContainer:addChild(tempNode)
        return
    end

    local mainPlayer=_G.g_Stage:getMainPlayer()
    local posX,poxY=mainPlayer:getLocationXY()
    tempNode:setPosition(posX-tempWidth*0.5,poxY+100)
    _G.g_Stage.m_lpCharacterContainer:addChild(tempNode,10)
end
function Logs.createAttrLogsNode(self,_isClear)
    local function onNodeEvent(event)
        if "cleanup"==event then
            self.m_attrContainer=nil
        end
    end
    self.m_attrContainer=cc.Node:create()
    self.m_attrContainer:registerScriptHandler(onNodeEvent)

    if _isClear then
        self.m_attrMsgArray={}
    end
    return self.m_attrContainer
end
--暂停飘消息
function Logs.stopMessageFloatOut( self )
    self.isFloatOut = true
end
--继续飘消息
function Logs.startMessageFloatOut( self )
    self.isFloatOut = false
end

return Logs
