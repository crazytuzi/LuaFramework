local OlineBonusView = classGc(view, function(self)
    
end)

local m_winSize   = cc.Director:getInstance():getVisibleSize()
local rightbgSize = cc.size(624, 517)
local iconSize    = cc.size(78,78)
local FONTSIZE    = 20

function OlineBonusView.create(self)
    local msg  = REQ_REWARD_REQUEST()
    msg : setArgs(1)
    _G.Network : send( msg )
    self.m_container = cc.Node : create()

    self.OlineBonusBg = cc.Node:create()
    -- self.OlineBonusBg : setContentSize( rightbgSize )
    self.OlineBonusBg : setPosition(-202, -301)
    self.m_container  : addChild(self.OlineBonusBg)

    -- local logoSpr = cc.Sprite:create("ui/bg/activity_logo_01.png")
    -- logoSpr : setPosition(rightbgSize.width/2,rightbgSize.height-56)
    -- self.OlineBonusBg  : addChild(logoSpr) 

 --  初始化
    return self.m_container
end

function OlineBonusView.OlineScrollView(self)
    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView = ScrollView
    
    self.oneSize=cc.size(rightbgSize.width,(rightbgSize.height-16)/4)
    local count = #_G.Cfg.online_reward
    self.viewSize  = cc.size(rightbgSize.width, rightbgSize.height-16)
    self.containerSize = cc.size(rightbgSize.width, self.oneSize.height*count)
    local _num = 1
    print("dadadssa",self.id)
    if self.id>=2 then _num=2 end
    ScrollView      : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView      : setViewSize(self.viewSize)
    ScrollView      : setContentSize(self.containerSize)
    ScrollView      : setContentOffset( cc.p( 0, self.viewSize.height-self.containerSize.height+(_num-1)*self.oneSize.height))
    ScrollView      : setPosition(cc.p(0, 8))
    print("容器大小：", self.oneSize.height*count)
    ScrollView      : setBounceable(false)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    
    self.OlineBonusBg  : addChild(ScrollView)

    local barView=require("mod.general.ScrollBar")(ScrollView)
    barView:setPosOff(cc.p(-8,0))
    barView:setMoveHeightOff(-5)

    self : Bonuscreate()
end

function OlineBonusView.Bonuscreate(self)
    self.RewardLab = {}
    self.RewardBg  = {}
    self.RewardBtn = {}
    self.nodrawSpr = {}

    local count = #_G.Cfg.online_reward
    local chazhi = count - self.id
    print("chazhi", chazhi, count, self.id)

    for i=1, count do
        print("签到获得",i, self.id)
        local icondata = nil
        icondata = _G.Cfg.online_reward[i]
        if icondata == nil then return end

        local time = self : getTimeStr(icondata.time)
        print("time2",time)
        self.RewardBg[i] = ccui.Scale9Sprite : createWithSpriteFrameName("general_nothis.png")
        self.RewardBg[i] : setContentSize(cc.size(self.oneSize.width-16,self.oneSize.height-6))
        self.RewardBg[i] : setPosition(rightbgSize.width/2, self.containerSize.height-self.oneSize.height/2-(i-1)*self.oneSize.height)
        self.m_ScrollView : addChild(self.RewardBg[i])

        self.RewardLab[i] = _G.Util : createLabel( time, FONTSIZE)
        self.RewardLab[i] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKORANGE)) 
        self.RewardLab[i] : setPosition(20, self.oneSize.height*0.33)
        self.RewardLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
        self.RewardBg[i]  : addChild(self.RewardLab[i])

        local timeStrLab  = _G.Util : createLabel("剩余时间", FONTSIZE)
        timeStrLab        : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN)) 
        timeStrLab        : setPosition(20, self.oneSize.height*0.57)
        timeStrLab        : setAnchorPoint( cc.p(0.0,0.5) )
        self.RewardBg[i]  : addChild(timeStrLab)

        self : getGoodsSpr(icondata,i)

        local function onButtonCallBack(sender, eventType)
            self : onBtnCallBack(sender, eventType)
        end
        self.RewardBtn[i] = gc.CButton : create("general_btn_gold.png")
        self.RewardBtn[i] : setTitleText("领  取")
        self.RewardBtn[i] : setTitleFontName(_G.FontName.Heiti)
        self.RewardBtn[i] : setTitleFontSize(FONTSIZE+4)
        self.RewardBtn[i] : setTag(i)
        -- self.RewardBtn[i] : setButtonScale(0.9)
        self.RewardBtn[i] : setEnabled(false)
        self.RewardBtn[i] : setBright(false)
        --self.RewardBtn[i] : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
        self.RewardBtn[i] : setPosition(cc.p(self.oneSize.width*0.86, self.oneSize.height/2-3))
        self.RewardBtn[i] : addTouchEventListener(onButtonCallBack)
        self.RewardBg[i]  : addChild(self.RewardBtn[i])

        self.nodrawSpr[i] = cc.Sprite : createWithSpriteFrameName("main_already.png")
        self.nodrawSpr[i] : setPosition(cc.p(self.oneSize.width*0.86, self.oneSize.height/2-3))
        self.nodrawSpr[i] : setVisible(false)
        self.RewardBg[i]  : addChild(self.nodrawSpr[i])
    end

    -- for i=1, self.id-1 do
    --     if self.id-1 ==0 then return end
    --     print("无物品", i, self.id)
    --     local icondata = nil
    --     icondata = _G.Cfg.online_reward[i]
    --     if icondata == nil then return end

    --     local time = self : getTimeStr(icondata.time)
    --     print("time3",time)
    --     self.RewardBg[i] = ccui.Scale9Sprite : createWithSpriteFrameName("general_double2.png")
    --     self.RewardBg[i] : setContentSize(cc.size(self.oneSize.width-16,self.oneSize.height-6))
    --     self.RewardBg[i] : setPosition(rightbgSize.width/2, self.containerSize.height-self.oneSize.height/2-(i+chazhi)*self.oneSize.height)
    --     self.m_ScrollView : addChild(self.RewardBg[i])

    --     self.RewardLab[i] = _G.Util : createLabel( time, FONTSIZE)
    --     self.RewardLab[i] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE)) 
    --     self.RewardLab[i] : setPosition(10, self.oneSize.height*0.33)
    --     self.RewardLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
    --     self.RewardBg[i]  : addChild(self.RewardLab[i])

    --     local timeStrLab  = _G.Util : createLabel("剩余时间", FONTSIZE)
    --     timeStrLab        : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_PBLUE)) 
    --     timeStrLab        : setPosition(10, self.oneSize.height*0.57)
    --     timeStrLab        : setAnchorPoint( cc.p(0.0,0.5) )
    --     self.RewardBg[i]  : addChild(timeStrLab)

    --     self : getGoodsSpr(icondata,i)

    --     local function onButtonCallBack(sender, eventType)
    --         self : onBtnCallBack(sender, eventType)
    --     end
    --     self.RewardBtn[i] = gc.CButton : create("general_btn_gold.png")
    --     self.RewardBtn[i] : setTitleText("领  取")
    --     self.RewardBtn[i] : setTitleFontName(_G.FontName.Heiti)
    --     self.RewardBtn[i] : setVisible(false)
    --     self.RewardBtn[i] : setTitleFontSize(FONTSIZE+6)
    --     self.RewardBtn[i] : setButtonScale(0.9)
    --     self.RewardBtn[i] : setTag(i)
    --     --self.RewardBtn[i] : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    --     self.RewardBtn[i] : setPosition(cc.p(self.oneSize.width*0.86+3, self.oneSize.height/2-3))
    --     self.RewardBtn[i] : addTouchEventListener(onButtonCallBack)
    --     self.RewardBg[i]  : addChild(self.RewardBtn[i])

    --     self.nodrawSpr[i] = cc.Sprite : createWithSpriteFrameName("main_already.png")
    --     self.nodrawSpr[i] : setPosition(cc.p(self.oneSize.width*0.86+3, self.oneSize.height/2-3))
    --     self.RewardBg[i]  : addChild(self.nodrawSpr[i])
    -- end
end

function OlineBonusView.onBtnCallBack(self,sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        local btn_tag = sender : getTag()
        local Position  = sender : getWorldPosition()
        print("~~~~~Position.y = ",Position.y,m_winSize.height/2+rightbgSize.height/2-30)
        if Position.y > m_winSize.height/2+rightbgSize.height/2-30 or
        Position.y < m_winSize.height/2-rightbgSize.height/2-15  then return end
        local msg  = REQ_REWARD_ONLINE()
        _G.Network : send( msg )
        
        _G.Util:playAudioEffect("ui_receive_awards")
        local msg  = REQ_REWARD_BEGIN()
        _G.Network : send( msg )
    end
end

function OlineBonusView.getTimeStr( self, _time)
    _time = _time < 0 and 0 or _time
    local hour   = math.floor(_time/3600)
    local min    = math.floor(_time%3600/60)
    local second = math.floor(_time%60)

    if hour < 10 then hour = "0"..hour
    elseif hour < 0 then hour = "00" end

    if min < 10 then min = "0"..min
    elseif min < 0 then min = "00" end

    if second < 10 then second = "0"..second end
    local time = tostring(hour)..":"..tostring(min)..":"..second

    return time
end

function OlineBonusView.getGoodsSpr(self,icondata, i)
    local roleBg = {1,2,3,4}
    local function roleCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.myMove = sender : getWorldPosition().y
        elseif eventType == ccui.TouchEventType.ended then
            local posY = sender : getWorldPosition().y
            local move = posY - self.myMove
            print( "isMove = ", move, posY, self.myMove )
            if move > 5 or move < -5 then
                return
            end
            local role_tag  = sender : getTag()
            local Position  = sender : getWorldPosition()
            print("－－－－选中role_tag:", role_tag)
            print("－－－－Position.y",Position.y )
            if Position.y > m_winSize.height/2+rightbgSize.height/2-30 or
               Position.y < m_winSize.height/2-rightbgSize.height/2-15 
               or role_tag <= 0 then return end
            local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
        end 
    end

    for j=1, 4 do
        roleBg[j] = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
        roleBg[j] : setPosition(150+(j-1)*(iconSize.width+13), self.oneSize.height/2-3)
        self.RewardBg[i] : addChild(roleBg[j])

        local goods = icondata.goods[j]
        if goods~=nil then
            print("请求物品图片", goods.goods_id)
            local goodId      = goods.goods_id
            local goodCount   = goods.count
            local goodsdata   = _G.Cfg.goods[goodId]
            if goodsdata ~= nil then
                local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,roleCallBack,goodId,goodCount)
                iconSpr       : setSwallowTouches(false)
                iconSpr       : setPosition(iconSize.width/2, iconSize.height/2)
                roleBg[j]     : addChild(iconSpr)
            end
        end   
    end
end

function OlineBonusView.initCountdown(self)
    if not self.timenext or self.id == 0 then
        return
    end
    local m_serverTime = _G.TimeUtil : getServerTimeSeconds()
    self.timenext = self.timenext - 1
    print("m_endTimes", self.timenext,m_serverTime,self.timenext)
    local time = ""
    if self.timenext <= 0 then
        self : uncountdownEvent()
        print("self.id--->>>",self.id)
        local msg  = REQ_REWARD_BEGIN()
        _G.Network : send( msg )
        self.RewardLab[self.id] : setString("00:00:00")
        self.RewardBtn[self.id] : setEnabled(true)
        self.RewardBtn[self.id] : setBright(true)
    else
        time = self : getTimeStr(self.timenext)
        self.RewardLab[self.id] : setString(time)
    end
end

---------------------协议返回-------------------

function OlineBonusView.onlineData(self, _ackMsg)  --mediator传过来的数据
    print("协议---》》》", _ackMsg.id, _ackMsg.time)
    self.id = _ackMsg.id      -- 类型
    self.timenext = _ackMsg.time  -- 时间
    print("协议---》》》", _ackMsg.id, _ackMsg.time)

    -- 时间更新
    if self.timenext == nil or self.timenext < 0 then
        self.timenext = 0 
    end

    if self.m_ScrollView == nil then
        self : OlineScrollView()
    end

    local Count = #_G.Cfg.online_reward
    for i=1,Count do
        if i < self.id or self.id == 0 then
            print("self.id", i,self.id)
            if self.RewardBtn[i] ~= nil then 
                self.RewardBtn[i] : setVisible(false)
                self.nodrawSpr[i] : setVisible(true)
                self : uncountdownEvent()
                self.RewardLab[i] : setString("00:00:00")
            end 
        elseif i >= self.id then
            if not self.m_timeScheduler then
                self : countdownEvent()
            end
        else
            self : uncountdownEvent()
            self.RewardLab[self.id] : setString("00:00:00")
        end
    end
    if self.id <= 0 then
        if self.RewardBtn[self.id]==nil then return end
        self.RewardBtn[i] : setVisible(false)
        self.nodrawSpr[i] : setVisible(true)
        self : uncountdownEvent()
        self.RewardLab[i] : setString("00:00:00")
    end

    local count = 1
    if self.id>=2 then count=2 end
    self.m_ScrollView : setContentOffset( cc.p( 0, self.viewSize.height-self.containerSize.height+(count-1)*self.oneSize.height))
end

function OlineBonusView.countdownEvent( self )
    local function local_scheduler()
        self : initCountdown()
    end
    self.m_timeScheduler =  _G.Scheduler : schedule(local_scheduler, 1)
    self : initCountdown()
end

function OlineBonusView.uncountdownEvent( self )
    if self.m_timeScheduler ~= nil then
        _G.Scheduler : unschedule(self.m_timeScheduler )
        self.m_timeScheduler = nil
    end
end

return OlineBonusView