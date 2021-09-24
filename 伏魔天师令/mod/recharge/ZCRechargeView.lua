local ZCRechargeView = classGc(view, function(self, _panelType)
end)

local FONTSIZE = 20
local iconXY = 78

local m_winSize     = cc.Director : getInstance() : getVisibleSize()
local bgSize = cc.size(623, 517)
local viewSize=cc.size(565,130)
local moneyArray = {25,128}

local BUYTAG = false
local yuekaData = _G.Cfg.yueka

function ZCRechargeView.create(self)
	self.m_container = cc.Node:create()

    local zcpxbg = cc.Sprite:create("ui/bg/recharge_zcpx.jpg")
    zcpxbg:setPosition(110,-43)
    self.m_container:addChild(zcpxbg)

    local mainplay = _G.GPropertyProxy : getMainPlay()
    self.playerViplv = tonumber(mainplay : getVipLv()) 
    self.playerlv = tonumber(mainplay : getLv()) 
    self.playerRMB = tonumber(mainplay : getRmb()) 

    local labNode={string.format("VIP4特权购买（当前VIP: %d）",self.playerViplv),"购买倒计时：12天23小时59分","当前等级: ",self.playerlv}
    local posY={bgSize.height-25,bgSize.height-55,143,143}
    for i=1,4 do
        local label = _G.Util : createLabel(labNode[i],FONTSIZE)
        label       : setAnchorPoint(cc.p(0,0.5))
        label       : setPosition(cc.p(15,posY[i]))
        zcpxbg      : addChild(label,88)
        if i==1 then
            label : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
        elseif i==4 then
            label       : setPosition(cc.p(110,posY[i]))
            label : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
        end
        if i==2 then
            self.timeLab=label
        end
    end

    local function local_CallBack(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            local btn_tag = sender : getTag() 
            if btn_tag==1 then
                local explainView  = require("mod.general.ExplainView")()
                local explainLayer = explainView : create(_G.Const.CONST_FUNC_OPEN_RECHARGE_JIJIN)
            else
                if self.playerViplv>=3 and self.playerRMB>=1000 then
                    local szMsg="花费1000钻石购买招财貔貅？"
                    local function fun1()
                        local msg=REQ_WEAGOD_RMB_BUY()
                        _G.Network:send(msg)
                    end
                    _G.Util:showTipsBox(szMsg,fun1)
                else
                    local szMsg="钻石或Vip等级不足，是否前往充值？"
                    local function fun1()
                        print("跳转到充值界面")
                        local command = RechargeViewCommand()
                        controller :sendCommand( command )
                    end
                    _G.Util:showTipsBox(szMsg,fun1)
                end
            end
        end
    end

    local Btn_Explain  = gc.CButton : create()
    Btn_Explain : loadTextures( "general_help.png")
    Btn_Explain : setPosition( bgSize.width-40, bgSize.height-25 )
    Btn_Explain : setTag( 1 )
    Btn_Explain : addTouchEventListener( local_CallBack )
    zcpxbg : addChild( Btn_Explain )

    self.BuyBtn=gc.CButton:create("general_btn_lv.png")
    self.BuyBtn:setTitleText("购 买")
    self.BuyBtn:setTitleFontName(_G.FontName.Heiti)
    self.BuyBtn:setTitleFontSize(FONTSIZE+4)
    self.BuyBtn:setPosition(bgSize.width-100,bgSize.height/2-55)
    self.BuyBtn:addTouchEventListener(local_CallBack)
    self.BuyBtn:setTag(2)
    zcpxbg:addChild(self.BuyBtn)
    
    self.rewardScrollView=cc.ScrollView:create()
    self.rewardScrollView:setPosition(29,5)
    self.rewardScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self.rewardScrollView:setViewSize(viewSize)
    self.rewardScrollView:setBounceable(false)
    self.rewardScrollView:setTouchEnabled(true)
    self.rewardScrollView:setDelegate()
    zcpxbg:addChild(self.rewardScrollView)

    self.LeftSpr = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
    self.LeftSpr : setPosition(20, 60)
    self.LeftSpr : setVisible(false)
    zcpxbg : addChild(self.LeftSpr)

    self.RightSpr = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
    self.RightSpr : setPosition(bgSize.width-20, 60)
    self.RightSpr : setScale(-1)
    zcpxbg  : addChild(self.RightSpr)


    local function onTouchBegan( touch, event ) 
        return true
    end
    local function onTouchMoved( touch, event )
            local moveX = self.rewardScrollView:getContentOffset().x
            print( "moveX = ", moveX, viewSize.width-self.ContainterWidth )
            if moveX <= (viewSize.width-self.ContainterWidth) then
                print( "1111" )
                self.RightSpr : setVisible( false )
                self.LeftSpr : setVisible( true )
            elseif moveX >= -10 then
                print( "2222" )
                self.LeftSpr : setVisible( false )
                self.RightSpr : setVisible( true )
            else
                print( "3333" )
                self.RightSpr : setVisible( true )
                self.LeftSpr : setVisible( true )
            end
        end

    local function onTouchEnded( touch, event )
        print( "End touch:getLocation().x = ", self.rewardScrollView:getContentOffset().x  )
    end

    local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
    listener       : registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener       : registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener       : registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self.rewardScrollView : getEventDispatcher() -- 得到事件派发器
    eventDispatcher : addEventListenerWithSceneGraphPriority(listener, self.rewardScrollView) -- 将监听器注册到派发器中

--  初始化
    local msg = REQ_WEAGOD_RMB_REQUEST()
    _G.Network:send(msg)

    return self.m_container
end

function ZCRechargeView.pushdata(self,_data)
    print("ZCRechargeView")
    self:getZCTimeStr(_data.time)
    self:BuyBtnFlag(_data.flag)

    local function rewardBtnCallBack(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            local btn_tag = sender : getTag()
            local nPos = sender:getWorldPosition()
            print("Tag",btn_tag,nPos.x,m_winSize.width/2+viewSize.width/2+100,m_winSize.width/2-viewSize.width/2+140)
            if nPos.x>m_winSize.width/2+viewSize.width/2+100 
            or nPos.x<m_winSize.width/2-viewSize.width/2+140
            then return end 
            local msg = REQ_WEAGOD_RMB_GIFT_REQUEST()
            msg:setArgs(btn_tag)
            _G.Network:send(msg)
        end
    end

    local weaData=_G.Cfg.weagod_rmb

    self.rewardBtn={}
    local oneWidth=viewSize.width/4
    
    local count=0
    for k,v in pairs(weaData) do
        print(k,v.rmb,v.id)
        self.rewardBtn[k]=gc.CButton:create("vip_gold_3.png")
        self.rewardBtn[k]:setPosition(oneWidth/2+20+(k/10-1)*oneWidth,65)
        self.rewardBtn[k]:addTouchEventListener(rewardBtnCallBack)
        self.rewardBtn[k]:setTag(k)
        self.rewardBtn[k]:setSwallowTouches(false)
        self.rewardScrollView:addChild(self.rewardBtn[k])

        if _data.flag~=1 then
            self.rewardBtn[k]:setBright(false)
            self.rewardBtn[k]:setEnabled(false)
        else
            if self.playerlv >= k then
                self.rewardBtn[k]:setBright(true)
                self.rewardBtn[k]:setEnabled(true)
            else
                self.rewardBtn[k]:setBright(false)
                self.rewardBtn[k]:setEnabled(false)
            end
        end

        local lvbgSpr=cc.Sprite:createWithSpriteFrameName("recharge_lvbg.png")
        lvbgSpr:setPosition(-20,65)
        self.rewardBtn[k]:addChild(lvbgSpr)

        local lvbgSize=lvbgSpr:getContentSize()
        local lvLab = _G.Util : createLabel(k,FONTSIZE)
        lvLab       : setPosition(cc.p(lvbgSize.width/2,lvbgSize.height/2+12))
        lvbgSpr     : addChild(lvLab)

        local lvStrLab = _G.Util : createLabel("级",FONTSIZE)
        lvStrLab       : setPosition(cc.p(lvbgSize.width/2,lvbgSize.height/2-12))
        lvbgSpr     : addChild(lvStrLab)

        local rmbSpr=cc.Sprite:createWithSpriteFrameName("general_xianYu.png")
        rmbSpr:setPosition(15,-10)
        self.rewardBtn[k]:addChild(rmbSpr)

        local NumLab = _G.Util : createLabel(v.rmb,FONTSIZE)
        NumLab       : setAnchorPoint(cc.p(0,0.5))
        NumLab       : setPosition(cc.p(30,-10))
        self.rewardBtn[k] : addChild(NumLab)

        for kk,vv in pairs(_data.msg) do
            if k==vv.id then
                --print("k,_data.count",k,vv.id)
                self.rewardBtn[k]:setEnabled(false)
                local alreadySpr=cc.Sprite:createWithSpriteFrameName("main_already.png")
                alreadySpr:setPosition(30,40)
                self.rewardBtn[k]:addChild(alreadySpr)
            end            
        end
        
        count=count+1
    end
    self.ContainterWidth=oneWidth*count
    self.rewardScrollView:setContentSize(cc.size(self.ContainterWidth,viewSize.height))
    self.rewardScrollView:setContentOffset(cc.p(-(_data.count)*oneWidth))
end

function ZCRechargeView.SuccessBuy( self )
    self:BuyBtnFlag(1)
    local weaData=_G.Cfg.weagod_rmb
    for k,v in pairs(weaData) do
        if self.playerlv >= k then
            self.rewardBtn[k]:setBright(true)
            self.rewardBtn[k]:setEnabled(true)
        else
            self.rewardBtn[k]:setBright(false)
            self.rewardBtn[k]:setEnabled(false)
        end
    end
end

function ZCRechargeView.SuccessReward( self, _id)
    print("SuccessReward--->",_id)
    self.rewardBtn[_id]:setEnabled(false)

    local alreadySpr=cc.Sprite:createWithSpriteFrameName("main_already.png")
    alreadySpr:setPosition(30,40)
    self.rewardBtn[_id]:addChild(alreadySpr)
end

function ZCRechargeView.BuyBtnFlag( self, _flag)
    if _flag==1 then
        self.BuyBtn:setTitleText("已购买")
        self.BuyBtn:setBright(false)
        self.BuyBtn:setEnabled(false)
        self.timeLab:setVisible(false)
    end
end

function ZCRechargeView.getZCTimeStr( self, _time)
    local nowTime     = _G.TimeUtil:getServerTimeSeconds()
    print("getZCTimeStr===>>>",_time,nowTime,_time-nowTime)
    local time = _time-nowTime

    time = time < 0 and 0 or time
    local endday   = math.floor(time/(24*3600))
    local endhour   = math.floor((time-endday*24*3600)/3600)
    local endmin    = math.floor(time%3600/60)
    -- local second = math.floor(time%60)

    local time=string.format("购买倒计时: %d天%d小时%d分",endday,endhour,endmin)

    self.timeLab:setString(time)
end

return ZCRechargeView