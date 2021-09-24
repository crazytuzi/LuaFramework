local UIGMView=classGc()
local TAG=96096
function UIGMView.show(self)
    if _G.GUIGMView~=nil then return end

    _G.GUIGMView=UIGMView()
    local node=_G.GUIGMView:create()
    _G.g_Stage:getScene():addChild(node,_G.Const.CONST_MAP_ZORDER_LAYER,TAG)
end
function UIGMView.create(self)
    self.m_normalView=require("mod.general.NormalView")()
    self.m_rootLayer=self.m_normalView:create()
    self.m_normalView:setTitle("GM命令")

    self:initView()
    return self.m_rootLayer
end
function UIGMView.destory(self)
    if _G.GUIGMView~=nil then
        if _G.g_Stage:getScene():getChildByTag(TAG) then
            _G.g_Stage:getScene():removeChildByTag(TAG)
        end
        _G.GUIGMView=nil
    end
end
function UIGMView.initView(self)
    self.m_winSize=cc.Director:getInstance():getWinSize()
    self.m_mainSize=cc.size(776,350)

    local function close()
        self:destory()
    end
    self.m_normalView:addCloseFun(close)

    local mainSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png",cc.rect(24,24,1,1))
    mainSpr:setPreferredSize(self.m_mainSize)
    mainSpr:setPosition(self.m_winSize.width*0.5,316)
    self.m_rootLayer:addChild(mainSpr)

    local infoLabel=_G.Util:createLabel("",22)
    infoLabel:setAnchorPoint(cc.p(0,1))
    infoLabel:setPosition(15,self.m_mainSize.height+10)
    infoLabel:setDimensions(self.m_mainSize.width-30,0)--self.m_mainSize.height-30
    infoLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    mainSpr:addChild(infoLabel)
    self.m_centerLabel=infoLabel

    local inputSize=cc.size(550,50)
    local inputPos=cc.p(self.m_winSize.width*0.5-self.m_mainSize.width*0.5+inputSize.width*0.5,105)
    local inputSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png",cc.rect(24,24,1,1))
    self.m_textField=ccui.EditBox:create(inputSize,inputSpr)
    self.m_textField:setPosition(inputPos)
    self.m_textField:setFont(_G.FontName.Heiti,20)
    self.m_textField:setPlaceholderFont(_G.FontName.Heiti,20)
    self.m_textField:setPlaceHolder("plz add order!!")
    -- self.m_textField:setMaxLength(20)
    self.m_textField:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.m_rootLayer:addChild(self.m_textField)

    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag=sender:getTag()
            if nTag==1 then
                local szField=self.m_textField:getText()
                self:sendGMMsg(szField)
            elseif nTag==2 then
                self:showToolView()
            end
        end
    end
    local speedBtn=gc.CButton:create()
    speedBtn:loadTextures("general_btn_gold.png")
    speedBtn:addTouchEventListener(c)
    speedBtn:setTitleFontSize(24)
    speedBtn:setTitleText("发 送")
    speedBtn:setTag(1)
    --speedBtn:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    speedBtn:setPosition(inputPos.x+inputSize.width*0.5+100,inputPos.y)
    self.m_rootLayer:addChild(speedBtn)

    local toolBtn=gc.CButton:create()
    toolBtn:loadTextures("general_btn_gold.png")
    toolBtn:addTouchEventListener(c)
    toolBtn:setTitleFontSize(24)
    toolBtn:setTitleText("常 用")
    toolBtn:setTag(2)
    --toolBtn:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    toolBtn:setPosition(inputPos.x+inputSize.width*0.5+150,520)
    self.m_rootLayer:addChild(toolBtn)
end
function UIGMView.sendGMMsg(self,_str)
    local szMsg="@".._str
    print("发送了内容:"..szMsg)

    local msg=REQ_CHAT_GM()
    msg:setArgs(szMsg)
    _G.Network:send(msg)

    self:setCenterInfo(szMsg)
end
function UIGMView.setCenterInfo(self,_str)
    local szInfo=self.m_centerLabel:getString()
    local infoSize=self.m_centerLabel:getContentSize()
    if infoSize.height>self.m_mainSize.height-20 then
        szInfo=""
    end
    self.m_centerLabel:setString(szInfo.."\nsend:".._str)
end

function UIGMView.removeToolView(self)
    if self.m_toolLayer~=nil then
        self.m_toolLayer:removeFromParent(true)
        self.m_toolLayer=nil
    end
end
function UIGMView.showToolView(self)
    self:removeToolView()

    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_toolLayer=cc.Layer:create()
    self.m_toolLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_toolLayer)
    self.m_rootLayer:addChild(self.m_toolLayer)
    
    local bgSize =cc.size(600,400)
    local bgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    bgSpr:setContentSize(bgSize)
    bgSpr:setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    self.m_toolLayer:addChild(bgSpr)

    local scoSize=cc.size(bgSize.width,bgSize.height-80)
    local scoView=cc.ScrollView:create()
    scoView:setDirection(ccui.ScrollViewDir.vertical)
    scoView:setTouchEnabled(true)
    scoView:setBounceable(false)
    scoView:setViewSize(scoSize)
    scoView:setPosition(cc.p(self.m_winSize.width/2-scoSize.width/2,320-scoSize.height+bgSize.height*0.5-10))
    self.m_toolLayer:addChild(scoView)

    local tempArray={}
    local tempCount=0

    tempCount=tempCount+1
    tempArray[tempCount]={szName="加钱:5000块",szCore="gold 5000"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="加钱:5千万",szCore="gold 50000000"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="升级:60",szCore="lv 60"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="VIP:12",szCore="vip 12"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="加体力:200",szCore="energy 200"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="扣体力:200",szCore="energyc 200"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="加声望:2000",szCore="renown 2000"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="加玄晶:2000",szCore="xj 2000"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="加帮贡:10000",szCore="bg 10000"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="开副本:60级",szCore="copylv 60"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="过关斩将:30层",szCore="fighter 30"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="过关斩将:100层",szCore="fighter 100"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="添加所有坐骑",isAddMount=true}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="添加部分灵妖",isAddLingYao=true}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="添加所有宠物",isAddChongWu=true}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="清空背包",szCore="bag"}

    tempCount=tempCount+1
    tempArray[tempCount]={szName="开启秘宝",szCore="mibao 1"}


    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag=sender:getTag()

            local tempT=tempArray[nTag]
            if tempT.isAddLingYao then
                for i=1,6 do
                    local szMsg=string.format("make 1%d101 1",i)
                    self:sendGMMsg(szMsg)
                end
            elseif tempT.isAddMount then
                for i=1,8 do
                    local szMsg=string.format("make %d 1",45105+(i-1)*5)
                    self:sendGMMsg(szMsg)
                end
            elseif tempT.isAddChongWu then
                for i=1,8 do
                    local szMsg=string.format("make %d 1",54105+(i-1)*5)
                    self:sendGMMsg(szMsg)
                end
            else
                local szMsg=tempT.szCore
                self:sendGMMsg(szMsg)
            end
            
        end
    end

    local oneHeight=scoSize.height*0.13
    local allHeight=(tempCount+1)*math.ceil(oneHeight*0.5)
    allHeight=allHeight<scoSize.height and scoSize.height or allHeight
    scoView:setContentSize(cc.size(scoSize.width,allHeight))
    scoView:setContentOffset(cc.p(0,scoSize.height-allHeight))

    local barView=require("mod.general.ScrollBar")(scoView)
    barView:setPosOff(cc.p(-scoSize.width,0))
    barView:setMoveHeightOff(10)

    local curHeight=allHeight-oneHeight*0.5
    local index=0
    local function nAddBtnFun(_t,_tag)
        local szName=_t.szName
        local nnnnn=_tag%2
        local nPosX=nnnnn==1 and scoSize.width*0.25 or scoSize.width*0.75
        
        local tempText=ccui.Text:create()
        tempText:setFontName(_G.FontName.Heiti)
        tempText:setFontSize(20)
        tempText:setString(string.format("【%s】",szName))
        tempText:setTouchScaleChangeEnabled(true)
        tempText:setPosition(nPosX,curHeight)
        tempText:setTouchEnabled(true)
        tempText:setTag(_tag)
        tempText:addTouchEventListener(c)
        scoView:addChild(tempText)

        if nnnnn==0 then
            curHeight=curHeight-oneHeight
        end
    end
    for i=1,tempCount do
        nAddBtnFun(tempArray[i],i)
    end

    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            self:removeToolView()
        end
    end
    local szNormal="general_close.png"
    local button=gc.CButton:create()
    button:setTouchEnabled(true)
    button:loadTextures(szNormal)
    button:setAnchorPoint(cc.p(1,1))
    button:setPosition(cc.p(self.m_winSize.width/2+bgSize.width*0.5,self.m_winSize.height/2+bgSize.height*0.5))
    button:addTouchEventListener(c)
    button:setSoundPath("bg/ui_sys_clickoff.mp3")
    self.m_toolLayer:addChild(button)
end



return UIGMView