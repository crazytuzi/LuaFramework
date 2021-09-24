local ZhaoCaiView = classGc(view, function(self)

	self.m_mediator =require("mod.zhaocai.ZhaoCaiMediator")() 
    self.m_mediator:setView(self) 
end)

local winSize  = cc.Director:getInstance():getVisibleSize()
local mainSize = cc.size(800, 528)
local fontSize = 20  -- 字体size
local count=1 -- 计数
local zcTag=1 -- tag值
local myTable = { [1]="一",[2]="二",[10]="十" }
local gouxuan = 1
function ZhaoCaiView.create( self )
	self.m_normalView = require("mod.general.NormalView")()
	self.mainLayer    = self.m_normalView:create()
	self.m_normalView : setTitle("摇钱树")   
    self.m_normalView : showSecondBg()

    local tempScene=cc.Scene:create()
    tempScene:addChild(self.mainLayer)
    
	self:initView()
    self:networksend()   
	return tempScene
end

function ZhaoCaiView.initView( self )    
	local function closeBtnCallback( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            self : unregister()
            if self.mainLayer == nil then return end
            self.mainLayer=nil
            cc.Director:getInstance():popScene()
            if self.m_hasGuide then
                local command=CGuideNoticShow()
                controller:sendCommand(command)
            end
        end
    end
    local closeBtn = self.m_normalView : getCloseBtn()
    closeBtn:addTouchEventListener(closeBtnCallback)
	local winSize=cc.Director:getInstance():getWinSize()
    
    local mainNode=self.m_normalView:getMainNode(3)
    -- local secondSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png",cc.rect(24,24,1,1))
    -- secondSpr:setPreferredSize(cc.size(776,460))
    -- secondSpr:setPosition(0,300)
    -- mainNode:addChild(secondSpr)
      
	-- local leftBgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
	-- leftBgSpr:setPreferredSize(cc.size(584,452))
	-- leftBgSpr:setPosition(-98,300)
	-- mainNode:addChild(leftBgSpr,2)
    local leftBgSpr=cc.Node:create()
    leftBgSpr:setPosition(-393,74)
    mainNode:addChild(leftBgSpr,2)

    local doubleSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
    doubleSpr:setPreferredSize(cc.size(240,475))
    doubleSpr:setPosition(297,280)
    mainNode:addChild(doubleSpr)

	self.rightBgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
	self.rightBgSpr:setPreferredSize(cc.size(230,465))
	self.rightBgSpr:setPosition(297,279)
	mainNode:addChild(self.rightBgSpr,1)

    local wid_RightBgSpr = self.rightBgSpr : getContentSize().width
    local hei_RightBgSpr = self.rightBgSpr : getContentSize().height
    self.blessingRecord = _G.Util:createLabel("摇钱记录",24)
    self.blessingRecord : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.blessingRecord : setAnchorPoint(cc.p(0.5,1))
    self.blessingRecord : setPosition(wid_RightBgSpr/2,hei_RightBgSpr - 20)
    self.rightBgSpr : addChild(self.blessingRecord) 

    local wid_leftBgSpr = 540
    local hei_leftBgSpr = 410
	local yqsSpr=cc.Sprite:create("ui/bg/yaoqianshu.jpg") -- 摇钱树
	yqsSpr:setPosition(wid_leftBgSpr/2, hei_leftBgSpr/2)
    -- yqsSpr:setScale(1.07)
    leftBgSpr:addChild(yqsSpr)
    self.leftBgSpr = leftBgSpr

    local Spr_myTQ = ccui.Scale9Sprite : createWithSpriteFrameName( "general_input.png" )
    Spr_myTQ : setAnchorPoint( 1, 1 )
    local myHei = Spr_myTQ : getContentSize().height
    Spr_myTQ : setContentSize( 130, myHei )
    Spr_myTQ : setPosition( wid_leftBgSpr - 5, hei_leftBgSpr - 5 )
    leftBgSpr  : addChild( Spr_myTQ )
    Spr_myTQ : setVisible(false)

    local Spr_TQ = cc.Sprite : createWithSpriteFrameName( "general_tongqian.png" )
    Spr_TQ : setAnchorPoint( 0, 0 )
    Spr_TQ : setPosition( 4, -2 )
    Spr_myTQ : addChild( Spr_TQ )

    local myTQ = _G.GPropertyProxy:getMainPlay():getGold()
    self.Lab_myTQ = _G.Util : createLabel( myTQ, 20 )
    self.Lab_myTQ : setPosition( Spr_myTQ:getContentSize().width/2+10, 10 )
    self.Lab_myTQ : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
    Spr_myTQ : addChild( self.Lab_myTQ )

    local Spr_myGold = ccui.Scale9Sprite : createWithSpriteFrameName( "general_input.png" )
    Spr_myGold : setAnchorPoint( 1, 1 )
    Spr_myGold : setContentSize( 130, myHei )
    Spr_myGold : setPosition( wid_leftBgSpr - 150, hei_leftBgSpr - 5 )
    leftBgSpr  : addChild( Spr_myGold )
    Spr_myGold : setVisible(false)

    local Spr_Gold = cc.Sprite : createWithSpriteFrameName( "general_gold.png" )
    Spr_Gold : setAnchorPoint( 0, 0 )
    Spr_Gold : setPosition( 4, -2 )
    Spr_myGold : addChild( Spr_Gold )

    local myGold = _G.GPropertyProxy:getMainPlay():getBindRmb()
    self.Lab_myGold = _G.Util : createLabel( myGold, 20 )
    self.Lab_myGold : setPosition( Spr_myGold:getContentSize().width/2+10, 10 )
    self.Lab_myGold : setColor( _G.ColorUtil:getRGB( _G.Const.CONST_COLOR_DARKORANGE ) )
    Spr_myGold : addChild( self.Lab_myGold )
    
    self.diwenSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_Base.png")    -- 底纹
    self.diwenSpr:setPreferredSize(cc.size(426,76))
    self.diwenSpr:setPosition(wid_leftBgSpr/2,110)
    leftBgSpr:addChild(self.diwenSpr)
    
    local blessingTimes = _G.Util:createLabel("今日剩余摇钱次数:",20)
    -- blessingTimes : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PBLUE))
    blessingTimes : setAnchorPoint(cc.p(0,0))
    blessingTimes : setPosition(120,40)
    blessingTimes : setOpacity(0.9*255)
    self.diwenSpr : addChild(blessingTimes) 

    self.blessingLose = _G.Util:createLabel("本次消耗：",20)
    -- self.blessingLose : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PBLUE))
    self.blessingLose : setAnchorPoint(cc.p(0,0))
    self.blessingLose : setPosition(55,10)
    self.diwenSpr : addChild(self.blessingLose) 

    self.blessingGain = _G.Util:createLabel("获得：",20)
    -- self.blessingGain : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_PBLUE))
    self.blessingGain : setAnchorPoint(cc.p(0,0))
    self.blessingGain : setPosition(270,10)
    self.diwenSpr : addChild(self.blessingGain) 
     
    local yuanbaoIcon=cc.Sprite:createWithSpriteFrameName("general_gold.png")      --元宝
    yuanbaoIcon:setAnchorPoint(cc.p(0,0))
    yuanbaoIcon:setPosition(150,8)
    self.diwenSpr:addChild(yuanbaoIcon)
   
    local goldIcon=cc.Sprite:createWithSpriteFrameName("general_tongqian.png")     --铜钱
    goldIcon:setAnchorPoint(cc.p(0,0))
    goldIcon:setPosition(320,8)
    self.diwenSpr:addChild(goldIcon)


    self.yuanbaoCount = _G.Util:createLabel("",20)
    -- self.yuanbaoCount : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LABELBLUE))
    self.yuanbaoCount : setAnchorPoint(cc.p(0,0))
    self.yuanbaoCount : setPosition(190,10)
    self.diwenSpr : addChild(self.yuanbaoCount) 
    
    self.tongqianCount = _G.Util:createLabel("",20)
    -- self.tongqianCount : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
    self.tongqianCount : setAnchorPoint(cc.p(0,0))
    self.tongqianCount : setPosition(350,10)
    self.diwenSpr : addChild(self.tongqianCount) 

    local width = blessingTimes:getContentSize().width + 5
    self.blessingTimes =  _G.Util:createLabel("",fontSize)
    self.blessingTimes : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.blessingTimes : setPosition(120 + width,40)
    self.blessingTimes : setAnchorPoint(cc.p(0,0))
    self.diwenSpr : addChild(self.blessingTimes,5) 
    self:addBtn(mainNode)  
end
function ZhaoCaiView.setLeftTime( self, freeTimes, sumTimes )  -- 设置（剩余次数/总次数）
    self.beganTimes=sumTimes-freeTimes    
    if self.blessingTimes ~= nil then
        local leftString = (freeTimes or 0).."/"..sumTimes
        print("setLeftTime --->",leftString)
        self.blessingTimes:setString(leftString)
    end
    self:setYuanbao()
    self:setleftTongqian()
end
function ZhaoCaiView.setYuanbao( self ) -- 单次消耗元宝
    -- body
    local consumeyuanbao=_G.Cfg.weagod_buy[self.beganTimes+1].use_rmb
    if self.yuanbaoCount ~= nil then
         self.yuanbaoCount:setString(consumeyuanbao)
    end
end
function ZhaoCaiView.setleftTongqian( self ) -- 单次获得的铜钱
    -- body
    local lv=_G.GPropertyProxy:getMainPlay():getLv()
    local gainTongqian=_G.Cfg.weagod[lv].money
    if self.tongqianCount ~= nil then
        self.tongqianCount:setString(gainTongqian)
    end
    if self.value~=nil then
        local beishuLab=_G.Util:createLabel(string.format("x%d",self.value),20)
        beishuLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
        beishuLab:setAnchorPoint(cc.p(0,0))
        beishuLab:setPosition(350+self.tongqianCount:getContentSize().width,10)
        self.diwenSpr:addChild(beishuLab)
    end
end

function ZhaoCaiView.isDouble(self,_value)
    self.value=_value
end

function ZhaoCaiView.yaoqian( self, num )
    local wid_leftBgSpr = 580
    local hei_leftBgSpr = 452
    if num == 1 then
        local spineOne = _G.SpineManager.createSpine("spine/yao",1)
        self.leftBgSpr : addChild(spineOne,10)

        local function callback1( )
            spineOne : setPosition( wid_leftBgSpr/2+100, -100 )
            spineOne : setAnimation(0,"idle",false)
        end
        local function callback2( )
            if spineOne ~= nil then
                spineOne : removeFromParent( true )
                spineOne = nil
            end
        end

        spineOne : runAction( cc.Sequence:create( cc.CallFunc:create(callback1), cc.DelayTime:create(2), cc.CallFunc:create(callback2) ) )
    else
        print( "10ci " )

        local spine1 =_G.SpineManager.createSpine("spine/yao",1)
        local spine2 =_G.SpineManager.createSpine("spine/yao",1)
        local spine3 =_G.SpineManager.createSpine("spine/yao",1)
        local spine4 =_G.SpineManager.createSpine("spine/yao",1)
        self.leftBgSpr : addChild(spine1,10)
        self.leftBgSpr : addChild(spine2,10)
        self.leftBgSpr : addChild(spine3,10)
        self.leftBgSpr : addChild(spine4,10)
        spine3 : setVisible( false )
        spine4 : setVisible( false )
        local function callback1( )
            spine1 : setPosition( wid_leftBgSpr/2-100, 0 )
            spine1 : setAnimation(0,"idle2",false)
            
            spine2 : setPosition( wid_leftBgSpr/2+300, 0 )
            spine2 : setAnimation(0,"idle2",false)
        end

        local function callback2( )
            spine3 : setVisible( true )
            spine3 : setPosition( wid_leftBgSpr/2-100, 0 )
            spine3 : setAnimation(0,"idle2",false)
            
            spine4 : setVisible( true )
            spine4 : setPosition( wid_leftBgSpr/2+300, 0 )
            spine4 : setAnimation(0,"idle2",false)
        end

        local function SpineRemo( myspine )
            if myspine ~= nil then
                myspine : removeFromParent(true)
                myspine = nil
            end
        end

        local function callback3( )
            SpineRemo( spine1 )
            SpineRemo( spine2 )
            SpineRemo( spine3 )
            SpineRemo( spine4 )
        end

        local myCall1 = cc.CallFunc:create( callback1 )
        local myCall2 = cc.CallFunc:create( callback2 )
        local myCall3 = cc.CallFunc:create( callback3 )

        spine1 : runAction( cc.Sequence:create( 
                                myCall1,
                                cc.DelayTime:create(1),
                                myCall2,
                                cc.DelayTime:create(5),
                                myCall3
                              ))
    end
end

function ZhaoCaiView.addBtn( self ,m_mainNode )      -- 摇钱按钮
    print("添加按钮")
    
    local function blessingOneCallback( sender,eventType )
        if eventType==ccui.TouchEventType.ended then
            print("摇钱一次",gouxuan)
            if gouxuan==1 then
                local consumeyuanbao=_G.Cfg.weagod_buy[self.beganTimes+1].use_rmb
                print("consumeyuanbao",consumeyuanbao)
                if consumeyuanbao==0 then
                    self:getMoneyOneSend()
                    if self.m_guide_wait_touch then
                        self.m_guide_wait_touch=nil

                        _G.GGuideManager:runThisStep(3)
                    end
                    return
                end
                self:PromptBox(1)
            end
            if gouxuan==2 then
                self:getMoneyOneSend()
            end
        end
    end
    local function blessingTenCallback( sender,eventType )
        if eventType==ccui.TouchEventType.ended then
            print("摇钱十次")
            if gouxuan==1 then
                self:PromptBox(10)
            end
            if gouxuan==2 then
                self:getMoneyTenSend()
            end
        end
    end
    self.blessingOneBtn = gc.CButton:create("general_btn_lv.png")
    self.blessingOneBtn:setTitleText("摇钱一次")
    self.blessingOneBtn:setTitleFontName(_G.FontName.Heiti)
    self.blessingOneBtn:setTitleFontSize(22)
    self.blessingOneBtn:setPosition(cc.p(-245,90))
    self.blessingOneBtn:addTouchEventListener(blessingOneCallback)
    m_mainNode:addChild(self.blessingOneBtn,3)
    
    self.blessingTenBtn = gc.CButton:create("general_btn_gold.png")
    self.blessingTenBtn:setTitleText("摇钱十次")
    self.blessingTenBtn:setTitleFontName(_G.FontName.Heiti)
    self.blessingTenBtn:setTitleFontSize(22)
    self.blessingTenBtn:setPosition(cc.p(20,90))
    --self.blessingTenBtn:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    self.blessingTenBtn:addTouchEventListener(blessingTenCallback)
    m_mainNode:addChild(self.blessingTenBtn,3)

    local guideId=_G.GGuideManager:getCurGuideId()
    if guideId==_G.Const.CONST_NEW_GUIDE_SYS_MONEYTREE then
        local closeBtn=self.m_normalView:getCloseBtn()
        _G.GGuideManager:initGuideView(self.mainLayer)
        _G.GGuideManager:registGuideData(1,self.blessingOneBtn)
        _G.GGuideManager:registGuideData(3,closeBtn)
        _G.GGuideManager:runNextStep()

        self.m_guide_wait_touch=true
        self.m_hasGuide=true
        local command=CGuideNoticHide()
        controller:sendCommand(command)

        self.blessingTenBtn:setTouchEnabled(false)
        self.blessingTenBtn:setBright(false)
    end
end
function ZhaoCaiView.setleaveTimes( self ,_leaveTimes )
    -- body
    self:buttonJudge(_leaveTimes)
end
function ZhaoCaiView.buttonJudge( self,lxTimes )  -- 检查摇钱按钮能否点击
    -- body
    if lxTimes<10 then
        self.blessingTenBtn:setTouchEnabled(false)
        self.blessingTenBtn:setBright(false)
    end
    if lxTimes<1 then
        self.blessingOneBtn:setTouchEnabled(false)
        self.blessingOneBtn:setBright(false)
    end
end
function ZhaoCaiView.PromptBox( self,zhaocaiTimes ) --提示框

    local function tipsSure()
        print("进行一次招财",zhaocaiTimes)
        if zhaocaiTimes==1 then
            self:getMoneyOneSend()
        end
        if zhaocaiTimes==10 then
            self:getMoneyTenSend()
        end
    end
    local function cancel()

    end
    local tipsBox = require("mod.general.TipsBox")()
    local tipsLayer = tipsBox :create( "", tipsSure, cancel)
    tipsLayer:setAnchorPoint(0,0)
    self.mainLayer:addChild(tipsLayer)
    tipsBox : setTitleLabel("招财")
    
    local tipsLayer=tipsBox:getMainlayer()
    local consumeyuanbao=0  
    if zhaocaiTimes==1 then
        self.text3="元宝进行1次招财？"
        local beganTimes = self.beganTimes
        if not beganTimes then
            beganTimes = 0
        end
        consumeyuanbao=_G.Cfg.weagod_buy[beganTimes+1].use_rmb
    end
    if zhaocaiTimes==10 then
        self.text3="元宝进行10次招财？"
        for index=1,10 do
             consumeyuanbao=_G.Cfg.weagod_buy[self.beganTimes+index].use_rmb+consumeyuanbao -- 花费元宝配表
        end 
    end
    local text1 = string.format("%s%d%s", "花费", consumeyuanbao, self.text3)
    local text2 = "(元宝不足则消耗钻石)"
    local tipsLab1 = _G.Util : createLabel(text1, 20) 
    tipsLab1 : setPosition(5, 55)
    -- tipsLab1 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE))
    tipsLayer: addChild(tipsLab1)

    local tipsLab2 = _G.Util : createLabel(text2, 18) 
    tipsLab2 : setPosition(0, 25)
    -- tipsLab2 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE))
    tipsLayer: addChild( tipsLab2 )

    function checkBoxCallback( obj, touchEvent )
        print("勾选")
        self : touchEventCallBack( obj, touchEvent )
    end
    local uncheckBox = "general_gold_floor.png"
    local selectBox = "general_check_selected.png"
    local checkBox = ccui.CheckBox : create(uncheckBox, uncheckBox, selectBox, uncheckBox, uncheckBox, ccui.TextureResType.plistType)
    checkBox : addEventListener(checkBoxCallback)
    checkBox : setAnchorPoint(0.5,0)
    checkBox : setPosition(cc.p(-80,-55))
    tipsLayer: addChild(checkBox) 

    local checkLabel = _G.Util : createLabel(_G.Lang.LAB_N[106], 20)
    checkLabel : setAnchorPoint(0.5,0)
    checkLabel : setPosition(25, -50)
    -- checkLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD ))
    tipsLayer  : addChild(checkLabel)  
end
function ZhaoCaiView.touchEventCallBack( self ) -- 是否不在提示
    -- body
    if gouxuan==2 then
        gouxuan=1
    elseif gouxuan==1 then
        gouxuan=2
    end   
end
function ZhaoCaiView.airingLab( self,pPosY,kTag )  --广播招财暴击
    -- body
    local kongSpr=cc.Sprite:create()
    kongSpr:setAnchorPoint(0,0)
    self.rightBgSpr : addChild(kongSpr)
    kongSpr:setTag(kTag)
    local X=10
    local Y=pPosY-10
    -- local Spr_TQ = cc.Sprite : createWithSpriteFrameName( "general_tongqian.png" )
    -- Spr_TQ:setPosition(cc.p(X+55,Y+35))
    -- kongSpr:addChild(Spr_TQ)
    -- Spr_TQ : setVisible( false )
    self.airingCritLab = _G.Util:createLabel("",fontSize)
    self.airingCritLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
    self.airingCritLab : setAnchorPoint(cc.p(0,0))
    self.airingCritLab : setPosition(X+3,Y+20)
    kongSpr : addChild(self.airingCritLab)
    count=count+1
    zcTag=zcTag+1
    
end
function ZhaoCaiView.setRecordMsg( self,_recordData ) -- 最近的记录
    -- body
    self.recordData=_recordData
    self:sortAiringLab(2)
end
function ZhaoCaiView.gainOneTongqian( self,_oneData ) -- 设置单次招财获得的铜钱
    -- body
    self.oneData=_oneData
    self:sortAiringLab(1)
    local myTQ = _G.GPropertyProxy:getMainPlay():getGold()
    self.Lab_myTQ : setString( myTQ )
    local myGold = _G.GPropertyProxy:getMainPlay():getBindRmb()
    self.Lab_myGold : setString( myGold )
end
function ZhaoCaiView.gainTenTongqian( self,_tenData) -- 设置十次招财获得的铜钱
    -- body
    self.tenData=_tenData
    self:sortAiringLab(10)
    local myTQ = _G.GPropertyProxy:getMainPlay():getGold()
    self.Lab_myTQ : setString( myTQ )
    local myGold = _G.GPropertyProxy:getMainPlay():getBindRmb()
    self.Lab_myGold : setString( myGold )
end
function ZhaoCaiView.setRecordTongqian( self,recordTimes)  -- 设置最近的几条记录
    -- body
    gainRightTongqian=myTable[self.recordData[recordTimes].adds].."倍铜钱:"..self.recordData[recordTimes].gold
    -- if self.recordData[recordTimes].adds == 1 then 
    --     gainRightTongqian="一倍    "..self.recordData[recordTimes].gold
    -- else
    --     -- gainRightTongqian=self.recordData[recordTimes].gold..","..self.recordData[recordTimes].adds.."倍铜钱"
    -- end
    if self.airingCritLab~=nil then
        self.airingCritLab:setString(gainRightTongqian)
    end
end
function ZhaoCaiView.setOneGainTongqian( self )
    -- body
    gainRightTongqian=myTable[self.oneData[1].adds].."倍铜钱:"..self.oneData[1].gold
    if self.airingCritLab~=nil then
        self.airingCritLab:setString(gainRightTongqian)
    end
end
function ZhaoCaiView.setTenGainTongqian( self,gainTimes)
    -- body
    gainRightTongqian=myTable[self.tenData[gainTimes].adds].."倍铜钱:"..self.tenData[gainTimes].gold
    if self.airingCritLab~=nil then
        self.airingCritLab:setString(gainRightTongqian)
    end
end
function ZhaoCaiView.sortLab( self )
    -- body
    if zcTag>10 then
        self.rightBgSpr:removeChildByTag(zcTag-10)
        for index=1,9 do
            local x,y=self.rightBgSpr:getChildByTag(zcTag-index):getPosition()
            self.rightBgSpr:getChildByTag(zcTag-index):setPosition(x,y+39)
        end

    end 
end
function ZhaoCaiView.sortAiringLab( self, _zhaocaiTimes)
    -- body
    if _zhaocaiTimes==1 then
        if count>10 then
           count=10
        end
        local posY=360-(count-1)*39
        self:sortLab(zcTag)
        self:airingLab(posY,zcTag) 
        self:setOneGainTongqian(1)
    end
    if _zhaocaiTimes==10 then
        for index=1,10 do
            if count>10 then
               count=10
            end
            local posY=360-(count-1)*39
            self:sortLab(zcTag)
            self:airingLab(posY,zcTag) 
            self:setTenGainTongqian(index)
        end
    end
    if _zhaocaiTimes==2 then
        for index=1,#self.recordData do
            if count>10 then
               count=10
            end
            local posY=360-(count-1)*39
            self:sortLab(zcTag)
            self:airingLab(posY,zcTag) 
            self:setRecordTongqian(index)
        end
    end
end
function ZhaoCaiView.networksend( self )   -- 招财面板请求
    print("发送请求招财面板")
    local msg = REQ_WEAGOD_REQUEST()
    _G.Network :send(msg)  
end
function ZhaoCaiView.getMoneyOneSend( self )  -- 一次摇钱请求
    local msg = REQ_WEAGOD_GET_MONEY()
    _G.Network :send(msg)
    print("发送招财请求")
end
function ZhaoCaiView.getMoneyTenSend( self )  -- 十次摇钱请求
    local msg = REQ_WEAGOD_PL_MONEY()
    _G.Network :send(msg)
    print("发送招财十次请求")
end
function ZhaoCaiView.unregister( self )
   self.m_mediator : destroy()
   self.m_mediator = nil 
   count=1
   zcTag=1
   mainplay=nil
   tenData=nil
end

function ZhaoCaiView.Net_GetMoney( self, _type )
    if _type == 1 then
        print( "返回一次招财" )
        self : yaoqian(1)
    else
        print( "返回多次招财" )
        self : yaoqian(10)
    end
end

return ZhaoCaiView
