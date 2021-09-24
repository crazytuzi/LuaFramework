local ArenaView = classGc(view,function(self,_isBattle)
    self.m_winSize        = cc.Director : getInstance() : getVisibleSize()
    
    self.person           = {}
    self.defendData       = {}
    self.interval         = 0 
    self.isClickPerson    = false

    self.t_uid            = 0
    self.t_rank        = 0   
    self.m_gold           = 0 
    -- if _isBattle then
    -- else
    --     _G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_LYJJ,false)
    --     _G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_LYJJ+1,false)
    -- end
end)

local isCoolTimeBuyTip       = false
local isBuyTip               = false
local isGoCopy               = false
local ARENA_BG_TAG           = 8888

local PERSON_ONE_NAME_TAG    = 1001
local PERSON_ONE_LV_TAG      = 1002
local PERSON_ONE_POWER_TAG   = 1003
local PERSON_ONE_RANK_TAG    = 1004

local PERSON_TWO_NAME_TAG    = 2001
local PERSON_TWO_LV_TAG      = 2002
local PERSON_TWO_POWER_TAG   = 2003
local PERSON_TWO_RANK_TAG    = 2004

local PERSON_THREE_NAME_TAG  = 3001
local PERSON_THREE_LV_TAG    = 3002
local PERSON_THREE_POWER_TAG = 3003
local PERSON_THREE_RANK_TAG  = 3004

local PERSON_FOUR_NAME_TAG   = 4001
local PERSON_FOUR_LV_TAG     = 4002
local PERSON_FOUR_POWER_TAG  = 4003
local PERSON_FOUR_RANK_TAG   = 4004

local PERSON_FIVE_NAME_TAG   = 5001
local PERSON_FIVE_LV_TAG     = 5002
local PERSON_FIVE_POWER_TAG  = 5003
local PERSON_FIVE_RANK_TAG   = 5004

local SELF_RANK_TAG            = 6001
local SELF_CHALLENGE_COUNT_TAG = 6002
local SELF_COOL_TIME_TAG       = 6003

local RANK_UI_TAG   = 7001
--local BUY_UI_TAG  = 7003

local COUNTDOWN_TIME_TAG = 8001

function ArenaView.create(self)
    self : __init()

    self.m_rootLayer = cc.Scene : create()

    self : __initView()

    return self.m_rootLayer
end

function ArenaView.__init(self)
    self : register()
end

function ArenaView.register(self)
    self.pMediator = require("mod.lingyao.LingYaoMediator")(self)
end
function ArenaView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function ArenaView.__initView(self)
    print("竞技场界面")
    local arenaBG = cc.Sprite : create("ui/bg/lingyao_bg.jpg")
    arenaBG : setTag(ARENA_BG_TAG)
    print("竞技场界面")
    self.m_rootLayer  : addChild(arenaBG,0)
    arenaBG           : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))

    -- local bird=_G.SpineManager.createSpine("map/10501_bf_01",1)
    -- bird : setAnimation(0,"idle",true)
    -- arenaBG : addChild(bird)

    local arenaSize=arenaBG:getContentSize()

    local function rankEvent(send,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("排名奖励")
            self : __initRankLayer()
        end
    end

    local rankButton = gc.CButton:create()
    rankButton       : addTouchEventListener(rankEvent)
    rankButton       : loadTextures("arena_rank.png")
    rankButton       : setPosition(cc.p(arenaSize.width/2 - self.m_winSize.width/2 + 65,600))
    arenaBG          : addChild(rankButton)

    local function couponEvent(send,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("跳转兑换")
            -- local szMsg="前往兑换商城？"
            -- local function fun1()
                _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_SHOP,nil,_G.Const.CONST_MALL_TYPE_SUB_LY)
            -- end
            -- _G.Util:showTipsBox(szMsg,fun1)
        end
    end

    local rankButton = gc.CButton:create()
    rankButton       : addTouchEventListener(couponEvent)
    rankButton       : loadTextures("arena_coupon.png")
    rankButton       : setPosition(cc.p(arenaSize.width/2 - self.m_winSize.width/2 + 60,520))
    arenaBG          : addChild(rankButton)

    local function backEvent(send,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("返回上一个场景")
            _G.Scheduler : unschedule(self.m_timeScheduler)
            self : unregister()

            cc.Director : getInstance() : popScene()

            if self.m_hasGuide then
                local command=CGuideNoticShow()
                controller:sendCommand(command)
            end
        end
    end

    local backButton= gc.CButton:create()
    backButton      :setAnchorPoint(cc.p(1,1))
    backButton     : addTouchEventListener(backEvent)
    backButton     : loadTextures("general_view_close.png")
    backButton     : setSoundPath("bg/ui_sys_clickoff.mp3")
    backButton     : setPosition(cc.p(arenaSize.width/2 + self.m_winSize.width/2+13,self.m_winSize.height+20))
    backButton     : ignoreContentAdaptWithSize(false)
    backButton     : setContentSize(cc.size(120,120))
    arenaBG        : addChild(backButton)

    -- local titleName = _G.Util : createLabel("竞技场",20)
    -- titleName       : setPosition(cc.p(rankIcon:getContentSize().width/2,rankIcon:getContentSize().height/2))
    -- rankIcon     : addChild(titleName)

    local dins = ccui.Scale9Sprite : createWithSpriteFrameName("general_voice_dins.png")
    dins       : setPreferredSize(cc.size(self.m_winSize.width,50))
    dins       : setPosition(cc.p(arenaSize.width/2,25))
    dins       : setOpacity(180)
    arenaBG    : addChild(dins,0)

    local function combatEvent(send,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("战报")
            self : __initCombatLayer()
        end
    end

    local combatButton= gc.CButton:create()
    combatButton      : addTouchEventListener(combatEvent)
    combatButton      : loadTextures("general_wrod_zb.png")
    combatButton      : setPosition(cc.p(arenaSize.width/2 - self.m_winSize.width/2 + 70,25))
    arenaBG           : addChild(combatButton,1)

    local currentRank  = self : __createLabel("当前排名:")
    currentRank        : setPosition(cc.p(arenaSize.width/2 - 260,25))
    arenaBG            : addChild(currentRank,1)

    local currentRankMsg = self : __setMsg("99999")
    currentRankMsg       : setPosition(cc.p(arenaSize.width/2 - 185,25))
    -- currentRankMsg       : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    currentRankMsg       : setTag(SELF_RANK_TAG)
    arenaBG              : addChild(currentRankMsg,1)

    local challengeCount  = self : __createLabel("挑战次数:")
    challengeCount        : setPosition(cc.p(arenaSize.width/2,25))
    arenaBG               : addChild(challengeCount,1)

    local challengeCountMsg = self:__setMsg("99")
    challengeCountMsg       : setPosition(cc.p(arenaSize.width/2 + 60,25))
    challengeCountMsg       : setTag(SELF_CHALLENGE_COUNT_TAG)
    arenaBG                 : addChild(challengeCountMsg,1)

    local coolTime = self : __createLabel("冷却时间:")
    coolTime       : setPosition(cc.p(arenaSize.width/2 + 300,25))
    arenaBG        : addChild(coolTime,1)

    local coolTimeMsg = self : __setMsg("00:00")
    coolTimeMsg       : setPosition(cc.p(arenaSize.width/2 + 380,25))
    coolTimeMsg       : setTag(SELF_COOL_TIME_TAG)
    arenaBG:addChild(coolTimeMsg,1)

    local function addEvent(sender,eventType)
        if eventType==ccui.TouchEventType.ended then
            print("增加挑战次数")
            local tag=sender:getTag()
            if tag==105 then
                if not sendMsg then
                    local msg = REQ_LINGYAO_ARENA_JOIN()
                    msg:setArgs(1)
                    _G.Network : send(msg)
                end
            else
                if isBuyTip then
                    print("直接购买＝＝＝＝＝＝＝＝＝＝不弹出提示框")
                    local msg  = REQ_LINGYAO_ARENA_BUY()
                    msg:setArgs(1)
                    _G.Network : send(msg)
                else
                    self : __buyNetWorkSend()
                end
            end
        end
    end

    local addButton = gc.CButton : create("general_btn_add.png")
    local cBtnSize  = addButton : getContentSize()
    addButton       : setPosition(cc.p(arenaSize.width/2 +100,25))
    addButton       : addTouchEventListener(addEvent)
    addButton       : ignoreContentAdaptWithSize(false)
    addButton       : setContentSize(cc.size(cBtnSize.width+30,cBtnSize.height+30))
    arenaBG         : addChild(addButton,2)

    local newButton = gc.CButton : create("general_btn_gold.png")
    newButton       : setTitleFontName(_G.FontName.Heiti)
    newButton       : setTitleText("刷 新")
    newButton       : setTitleFontSize(24)
    -- newButton       : setButtonScale(0.8)
    newButton       : setPosition(cc.p(arenaSize.width/2 +480,25))
    newButton       : addTouchEventListener(addEvent)
    newButton       : setTag(105)
    newButton       : setVisible(false)
    arenaBG         : addChild(newButton,2)
    self.newBtn=newButton

    -- local countdownDins = cc.Sprite : createWithSpriteFrameName("arena_gold.png")
    -- countdownDins       : setPosition(cc.p(arenaSize.width/2 - self.m_winSize.width/2 + 70,445))
    -- arenaBG             : addChild(countdownDins,0)

    local COLOR_BLACK=_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BLACK)
    -- self.rewardLab = _G.Util : createBorderLabel("", 20,COLOR_BLACK)
    -- self.rewardLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORANGE))
    -- self.rewardLab : setPosition(cc.p(arenaSize.width/2 - self.m_winSize.width/2 + 15,460))
    -- self.rewardLab : setAnchorPoint(cc.p(0,0.5))
    -- arenaBG        : addChild(self.rewardLab,1)

    local countdownLab = _G.Util : createBorderLabel("", 20,COLOR_BLACK)
    countdownLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORANGE))
    countdownLab       : setPosition(cc.p(arenaSize.width/2 - self.m_winSize.width/2 + 60,450))
    -- countdownLab       : setAnchorPoint(cc.p(0,0.5))
    countdownLab       : setTag(COUNTDOWN_TIME_TAG)
    arenaBG            : addChild(countdownLab,1)

    local function rewardEvent(send,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("领取铜钱")
            local msg  = REQ_LINGYAO_ARENA_DRAW_REWARD()
            _G.Network : send(msg)
        end
    end

    self.rewardBtn=gc.CButton:create("arena_ling.png")
    self.rewardBtn:setPosition(arenaSize.width/2 - self.m_winSize.width/2 + 60,445)
    self.rewardBtn:addTouchEventListener(rewardEvent)
    -- self.rewardBtn:setTitleFontName(_G.FontName.Heiti)
    -- self.rewardBtn:setTitleText("领 取")
    -- self.rewardBtn:setTitleFontSize(24)
    -- self.rewardBtn:setButtonScale(0.85)
    arenaBG       : addChild(self.rewardBtn)

    local function TeamCallBack(send,eventType)
        if eventType == ccui.TouchEventType.ended then
            print("防守阵容")
            self:defendView(1)
            local msg = REQ_LINGYAO_REQUEST()
            msg        : setArgs(2)
            _G.Network : send(msg)
            local msg = REQ_LINGYAO_ARENA_DEF()
            msg:setArgs(0)
            _G.Network : send(msg)
        end
    end

    local teamBtn = gc.CButton:create("partner_defend.png")
    teamBtn : setPosition(arenaSize.width/2 - self.m_winSize.width/2 + 60,370)
    teamBtn : addTouchEventListener(TeamCallBack)
    arenaBG : addChild(teamBtn)

    local nowSeconds =_G.TimeUtil : getServerTimeSeconds()
    self.m_second    = math.floor(nowSeconds%60)
    local function local_scheduler()
        self : __initCountdown()
    end
    
    self.m_timeScheduler = _G.Scheduler : schedule(local_scheduler, 1)

    -- self : __loadPersonDins(cc.p(arenaSize.width/2 - 380,200))
    -- self : __loadPersonDins(cc.p(arenaSize.width/2 - 200,280))
    -- self : __loadPersonDins(cc.p(arenaSize.width/2,320))
    -- self : __loadPersonDins(cc.p(arenaSize.width/2 + 200,280))
    -- self : __loadPersonDins(cc.p(arenaSize.width/2 + 380,200))

    local guideId=_G.GGuideManager:getCurGuideId()
    if guideId==_G.Const.CONST_NEW_GUIDE_SYS_LYJJ then
        self.m_guide_wait=true
        self.m_hasGuide=true
        _G.GGuideManager:initGuideView(self.m_rootLayer)
    end

    local msg = REQ_LINGYAO_ARENA_JOIN()
    msg:setArgs(0)
    _G.Network : send(msg)
end

function ArenaView.defendView( self,_type )
    self.type=_type
    self.defendData = {}
    local function onTouchBegan(touch,event) 
        return true
    end

    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.defendLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.defendLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.defendLayer)
    self.m_rootLayer:addChild(self.defendLayer,50)

    local kuangSize=cc.size(861,516)
    local di2kuanSize=cc.size(846,501)
    self.dinsSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
    self.dinsSpr:setPreferredSize(kuangSize)
    self.dinsSpr:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.defendLayer:addChild(self.dinsSpr)

    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.keepBtn~=nil and self.isTrue==true then
                print("确认保存框")
                local function fun1()
                    self:removeLayer()
                end
                _G.Util:showTipsBox("当前阵容尚未保存，是否直接关闭？",fun1)
                return
            end
            self:removeLayer()

            if self.m_guide_layout or self.m_guide_wait_layout_sure or self.m_guide_wait_start then
                _G.GGuideManager:runThisStep(1)
                self.m_guide_layout=true
                self.m_guide_wait_layout_sure=nil
                self.m_guide_wait_start=nil
            end
        end
    end
    local m_closeBtn=gc.CButton:create("general_close.png")
    m_closeBtn:setPosition(kuangSize.width,kuangSize.height+2)
    m_closeBtn:setAnchorPoint(cc.p(1,1))
    m_closeBtn:addTouchEventListener(c)
    m_closeBtn:setSoundPath("bg/ui_sys_clickoff.mp3")
    self.dinsSpr:addChild(m_closeBtn,10)

    local frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    frameSpr:setPreferredSize(di2kuanSize)
    frameSpr:setPosition(kuangSize.width/2,kuangSize.height/2)
    self.dinsSpr:addChild(frameSpr)

    local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_lowline.png")
    lineWidth=lineSpr:getContentSize().width
    lineSpr : setPreferredSize(cc.size(lineWidth,di2kuanSize.height-2))
    lineSpr : setPosition(292,di2kuanSize.height/2)
    frameSpr:addChild(lineSpr)

    local titleSpr     = cc.Sprite:createWithSpriteFrameName( "general_titlebg.png" ) 
    titleSpr           : setPosition(158,kuangSize.height-35)
    self.dinsSpr  : addChild(titleSpr)

    local titleLab1=_G.Util:createLabel( "灵妖列表",24)
    titleLab1:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    titleLab1:setPosition(158,kuangSize.height-37)
    self.dinsSpr:addChild(titleLab1)

    local tipsLab=_G.Util:createLabel( "(将头像拖至我方阵容)",20)
    -- tipsLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    tipsLab:setPosition(158,kuangSize.height-67)
    self.dinsSpr:addChild(tipsLab)

    local ScroViewSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    ScroViewSpr:setPreferredSize(cc.size(282,417))
    ScroViewSpr:setPosition(158,kuangSize.height/2-33)
    self.dinsSpr:addChild(ScroViewSpr)
end

function ArenaView.removeLayer( self )
    if self.defendLayer~=nil then
        self.defendLayer : removeFromParent(true)
        self.defendLayer = nil
        self.partnerHead = nil
        self.keepBtn     = nil
        self.defendData  = nil
    end
end

function ArenaView.createScrollView(self,_data)
    if self.dinsSpr==nil then return end
    local count=_data.count
    self.partnerNum=count
    local viewSize=cc.size( 282, 412 )
    local ScrollHeigh   = viewSize.height/4
    local containerSize = cc.size( 282, count*ScrollHeigh)
    self.ScrollView     = cc.ScrollView : create()
    self.ScrollView  : setDirection(ccui.ScrollViewDir.vertical)
    self.ScrollView  : setViewSize(viewSize)
    self.ScrollView  : setContentSize(containerSize)
    self.ScrollView  : setContentOffset( cc.p(0, viewSize.height-containerSize.height))
    self.ScrollView  : setPosition( 15, 18 )
    self.ScrollView  : setTouchEnabled(true)
    self.ScrollView  : setDelegate()
    self.dinsSpr     : addChild( self.ScrollView)

    if count>4 then
        local barView=require("mod.general.ScrollBar")(self.ScrollView)
        barView:setPosOff(cc.p(-4,0))
    end

    local btnSize=cc.size(80,80)
    local function ButtonCallBack(  obj, eventType )
        if eventType == ccui.TouchEventType.began then
            local tag       = obj : getTag()
            obj : setTouchEnabled(false)
            local function canTouch()
                obj: setTouchEnabled(true)
            end
            obj:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(canTouch)))

            local Position  = obj : getWorldPosition()
            Position.y = Position.y
            local x,y = self.ScrollView:getPosition()
            local pos = self.ScrollView:convertToWorldSpace(cc.p(x,y))
            if not cc.rectContainsPoint(cc.rect(pos.x,pos.y,btnSize.width,btnSize.height),Position) then
                return
            end

            -- self:selectSkill(tag)
        end
    end

    local function onTouchBegan(touch, event)
        print("onTouchBegan===>>>")
        if self.m_HeadIconSpr ~= nil then
            self.m_HeadIconSpr : removeFromParent(true)
            self.m_HeadIconSpr = nil 
        end
        local pos = touch:getLocation()
        for k,btn in pairs(self.Btn_partner) do
            local posBtn = btn:getWorldPosition()
            local x,y = self.ScrollView:getPosition()
            local posSv = self.ScrollView:convertToWorldSpace(cc.p(x,y))
            if not cc.rectContainsPoint(cc.rect(posSv.x-120,posSv.y,self.m_winSize.width,self.m_winSize.height),pos) then
                return
            end
            if cc.rectContainsPoint(cc.rect(posBtn.x-btnSize.width/2,posBtn.y-btnSize.height/2,btnSize.width,btnSize.height),pos) then
                self.nowpartnerId=btn:getTag()
                print("self.nowpartnerId===>>",self.nowpartnerId)
                local headicon = _G.Cfg.partner_init[self.nowpartnerId].head_icon
                self.m_HeadIconSpr = cc.Sprite:createWithSpriteFrameName(string.format("h%d.png",headicon))
                self.m_HeadIconSpr : setPosition(pos)
                self.m_HeadIconSpr : setOpacity(180)
                cc.Director:getInstance():getRunningScene(): addChild(self.m_HeadIconSpr,1111)
                self.m_canRemove = nil
                return true
            end
        end
        for k,btn in pairs(self.defendBtn) do
            local posBtn = btn:getWorldPosition()
            print("进入这里了吗",posBtn.x,posBtn.y)
            if cc.rectContainsPoint(cc.rect(posBtn.x-btnSize.width/2,posBtn.y-btnSize.height/2,btnSize.width,btnSize.height),pos) then
                print("self.defendBtn==>>",k, self.defendData[k])
                if self.defendData[k]==nil then return end
                self.nowpartnerId = self.defendData[k].id
                local headicon = _G.Cfg.partner_init[self.nowpartnerId].head_icon
                self.m_HeadIconSpr = cc.Sprite:createWithSpriteFrameName(string.format("h%d.png",headicon))
                self.m_HeadIconSpr : setPosition(pos)
                self.m_HeadIconSpr : setOpacity(180)
                cc.Director:getInstance():getRunningScene(): addChild(self.m_HeadIconSpr,1111)
                self.m_canRemove = true
                return true
            end
        end
    end
    local function onTouchMoved(touch, event)
        if self.m_HeadIconSpr ~= nil then
            local pos = touch:getLocation()
            self.m_HeadIconSpr : setPosition(pos)
        end
    end
    local function onTouchEnded(touch, event)
        if self.m_HeadIconSpr ~= nil then
            local pos = touch:getLocation()
            for i,btn in pairs(self.defendBtn) do
                -- local x,y = btn:getPosition()
                local posBtn = btn:getWorldPosition()
                if cc.rectContainsPoint(cc.rect(posBtn.x-btnSize.width/2,posBtn.y-btnSize.height/2,btnSize.width,btnSize.height),pos) then
                    print("i===1111",i,self.partnerNum)
                    if (self.partnerNum==1 and i>1) or (self.partnerNum==2 and (i==2 or i>3)) 
                        or (self.partnerNum==3 and (i==2 or i==4 or i==6)) or
                        (self.partnerNum==4 and (i==4 or i==6)) or (self.partnerNum==5 and i==6) then
                        local command = CErrorBoxCommand("获得下一个灵妖可开启该位置")
                        controller : sendCommand( command )
                        break
                    else
                        self : partnerCallBack(i,self.nowpartnerId)
                        break
                    end
                end
                if i>=6 and self.m_canRemove == true then
                    print("i===22222",i)
                    print(self.nowpartnerId,"@#@$@$@$$")
                    self : partnerCallBack(0,self.nowpartnerId)
                end
            end
            self.m_HeadIconSpr : removeFromParent(true)
            self.m_HeadIconSpr = nil 
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
    listener       : setSwallowTouches(true)
    listener       : registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener       : registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener       : registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    
    local node = cc.Node:create()
    self.ScrollView : addChild(node)

    local eventDispatcher = node : getEventDispatcher() -- 得到事件派发器
    eventDispatcher : addEventListenerWithSceneGraphPriority(listener, node) -- 将监听器注册到派发器中

    self.partnerMsg  = _data.msg_xxx
    self.Btn_partner = {}
    self.UpdefendSpr = {}
    for i=1,count do
        local oneSize=cc.size(viewSize.width-10,ScrollHeigh-6)
        local onePartnerSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_noit.png")
        onePartnerSpr:setPreferredSize(oneSize)
        onePartnerSpr:setPosition(viewSize.width/2+2,containerSize.height-ScrollHeigh/2-(i-1)*ScrollHeigh-1)
        self.ScrollView:addChild(onePartnerSpr)

        local partnerRes = "partner_head.png"
        self.Btn_partner[i] = gc.CButton:create(partnerRes)
        -- self.Btn_partner[i] : loadTextures( partnerRes, partnerRes, partnerRes, ccui.TextureResType.plistType)
        self.Btn_partner[i] : setPosition( 60,oneSize.height/2) --121*length-105*i-55-18*x
        self.Btn_partner[i] : addTouchEventListener(ButtonCallBack)
        self.Btn_partner[i] : setTag(_data.msg_xxx[i].id)
        self.Btn_partner[i] : setButtonScale(0.75)
        onePartnerSpr:addChild(self.Btn_partner[i])

        local partnerData=_G.Cfg.partner_init[_data.msg_xxx[i].id]
        local namecolor=partnerData.name_colour
        local headIconSpr = cc.Sprite:createWithSpriteFrameName(string.format("h%d.png",partnerData.head_icon))
        headIconSpr : setPosition(73,57)
        self.Btn_partner[i] : addChild(headIconSpr,-1)

        local fromimg=string.format("partner_frombg%d.png",_data.msg_xxx[i].country)
        local frombgSpr = gc.GraySprite:createWithSpriteFrameName(fromimg)
        frombgSpr : setPosition(45,90)
        self.Btn_partner[i] : addChild(frombgSpr)

        local lvbgSpr = gc.GraySprite:createWithSpriteFrameName("partner_lvbg.png")
        lvbgSpr : setPosition(110,60)
        self.Btn_partner[i] : addChild(lvbgSpr)

        local leavelLab = _G.Util : createLabel(_data.msg_xxx[i].lv,20)
        leavelLab : setPosition( 15, 15 )
        -- leavelLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        lvbgSpr : addChild(leavelLab)

        local nameLab = _G.Util : createLabel(partnerData.name,20)
        nameLab  : setPosition( 65, 15 )
        nameLab  : setColor(_G.ColorUtil:getRGB(namecolor))
        self.Btn_partner[i] : addChild(nameLab)

        local powSpr = cc.Sprite:createWithSpriteFrameName("partner_fight.png")
        powSpr : setPosition( 150, 60 )
        onePartnerSpr : addChild(powSpr)

        local powLab = _G.Util : createLabel(_data.msg_xxx[i].powerful,20)
        powLab : setPosition( 150, 30 )
        powLab : setAnchorPoint(cc.p(0,0.5))
        -- powLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
        onePartnerSpr : addChild(powLab)

        self.UpdefendSpr[_data.msg_xxx[i].id] = gc.GraySprite:createWithSpriteFrameName("partner_up.png")
        self.UpdefendSpr[_data.msg_xxx[i].id] : setPosition(230,oneSize.height/2)
        self.UpdefendSpr[_data.msg_xxx[i].id] : setVisible(false)
        onePartnerSpr : addChild(self.UpdefendSpr[_data.msg_xxx[i].id])
    end 
    if self.type==1 then
        self:RightDefendView()
    else
        self:RightAttackView()

        if self.m_guide_layout then
            self.m_guide_layout=nil

            if self.Btn_partner[1] then
                self.ScrollView:setTouchEnabled(false)
                _G.GGuideManager:registGuideData(2,self.Btn_partner[1])
                _G.GGuideManager:registGuideData(3,self.attackNode:getChildByTag(888))
                _G.GGuideManager:runNextStep()
                self.m_guide_wait_layout_sure=1
            end

        end
    end
    self.defendMsg={}
end

function ArenaView.partnerCallBack( self,pos,id)
    if self.defendData==nil then return end
    for k,v in pairs(self.defendData) do
        print("partnerCallBack====>>>",pos,id,v.id,v.pos,self.defendNum) 
        if id==v.id and pos~=v.pos and not self.m_canRemove then
            print("11111111====>>>",pos,id,v.id,v.pos)
            self.defendData[v.pos]=nil
        elseif id==v.id and pos~=v.pos and self.m_canRemove == true then
            print("222222====>>>",pos,id,v.id,v.pos)
            if self.defendData[pos]~=nil then
            print("333333====>>>",pos,id,v.id,v.pos)
                self.defendData[v.pos]=self.defendData[pos]
                self.defendData[v.pos].pos=v.pos
                -- self.defendData[pos]=nil
                break
            else
                if pos==0 and self.defendNum<2 then
                    local command = CErrorBoxCommand("至少有一个灵妖上阵")
                    controller : sendCommand( command )
                else
                    self.defendData[v.pos]=nil
                end
            end
        end
    end
    if pos~=0 then
        self.defendData[pos]={}
        self.defendData[pos].pos = pos
        self.defendData[pos].id  = id
        for k,v in pairs(self.partnerMsg) do
            if v.id==id then
                self.defendData[pos].lv  = v.lv
                self.defendData[pos].camp= v.country
            end 
        end

        if self.m_guide_wait_layout_sure==pos then
            self.m_guide_wait_layout_sure=nil
            self.m_guide_wait_start=true
            _G.GGuideManager:runNextStep()
        end
    end

    self:updateDefend(self.defendData)
end

function ArenaView.RightDefendView( self )
    self.defendNode=cc.Node:create()
    self.dinsSpr:addChild(self.defendNode)

    local kuangSize=cc.size(861,516)
    local titleSpr   = cc.Sprite:createWithSpriteFrameName( "general_titlebg.png" ) 
    titleSpr         : setPosition(kuangSize.width/2+150,kuangSize.height-43)
    self.defendNode  : addChild(titleSpr)

    local titleLab=_G.Util:createLabel( "防守阵容",24)
    titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    titleLab:setPosition(kuangSize.width/2+150,kuangSize.height-45)
    self.defendNode:addChild(titleLab)

    local lineSpr   = ccui.Scale9Sprite:createWithSpriteFrameName( "general_double_line.png" ) 
    lineSpr         : setPreferredSize(cc.size(440,3))
    lineSpr         : setPosition(kuangSize.width/2+150,kuangSize.height-80)
    self.defendNode : addChild(lineSpr)

    local lineSpr   = ccui.Scale9Sprite:createWithSpriteFrameName( "general_double_line.png" ) 
    lineSpr         : setPreferredSize(cc.size(440,2))
    lineSpr         : setPosition(kuangSize.width/2+150,kuangSize.height/2+65)
    self.defendNode : addChild(lineSpr)

    local lineSpr   = ccui.Scale9Sprite:createWithSpriteFrameName( "general_double_line.png" ) 
    lineSpr         : setPreferredSize(cc.size(440,2))
    lineSpr         : setPosition(kuangSize.width/2+150,kuangSize.height/2-47)
    self.defendNode : addChild(lineSpr)

    local lineSpr   = ccui.Scale9Sprite:createWithSpriteFrameName( "general_double_line.png" ) 
    lineSpr         : setPreferredSize(cc.size(440,3))
    lineSpr         : setPosition(kuangSize.width/2+150,100)
    self.defendNode : addChild(lineSpr)

    -- local function DefendCallBack(  obj, eventType )
    --     if eventType == ccui.TouchEventType.ended then
    --         local tag = obj : getTag()
    --         print("tag==>>",tag)
    --         if self.defendData[tag]==nil then return end
            -- if self.defendNum<2 then
            --     local command = CErrorBoxCommand("至少有一个灵妖上阵")
            --     controller : sendCommand( command )
            -- else
            --     self.defendData[tag]=nil
            --     self:updateDefend(self.defendData)
            -- end
    --     end
    -- end
    self.defendBtn  = {}
    self.noUpSpr    = {}
    self.defendfrom = {}
    self.defendLv   = {}
    self.defendLvLab= {}
    self.defendName = {}
    local posX=500
    local posY=490
    for i=1,6 do
        if i%2==1 then
            posX=500
            posY=posY-112
            local numberSpr   = cc.Sprite:createWithSpriteFrameName( string.format("partner_num%d.png",i-(i-1)/2) ) 
            numberSpr         : setPosition(kuangSize.width/2-40,posY+20)
            self.defendNode : addChild(numberSpr)
        else
            posX=670
        end
        local partnerRes = "partner_head.png"
        self.defendBtn[i] = gc.CButton:create(partnerRes)
        -- self.defendBtn[i] : loadTextures( partnerRes, partnerRes, partnerRes, ccui.TextureResType.plistType)
        self.defendBtn[i] : setPosition( posX, posY ) --121*length-105*i-55-18*x
        -- self.defendBtn[i] : addTouchEventListener(DefendCallBack)
        self.defendBtn[i] : setTag(i)
        self.defendBtn[i] : setButtonScale(0.75)
        self.defendBtn[i] : setTouchEnabled(false)
        self.defendBtn[i] : setVisible(false)
        self.defendNode : addChild(self.defendBtn[i])

        local Img="partner_noup.png"
        if (self.partnerNum==1 and i>1) or (self.partnerNum==2 and (i==2 or i>3)) 
            or (self.partnerNum==3 and (i==2 or i==4 or i==6)) or
            (self.partnerNum==4 and (i==4 or i==6)) or (self.partnerNum==5 and i==6) then
            Img="partner_nodown.png"
        end

        self.noUpSpr[i]=cc.Sprite:createWithSpriteFrameName(Img)
        self.noUpSpr[i]:setPosition(posX, posY)
        self.defendNode:addChild(self.noUpSpr[i])

        self.defendfrom[i]  = cc.Sprite:createWithSpriteFrameName("partner_frombg1.png")
        self.defendfrom[i]  : setPosition(45,90)
        self.defendBtn[i]   : addChild(self.defendfrom[i])

        self.defendLv[i] = gc.GraySprite:createWithSpriteFrameName("partner_lvbg.png")
        self.defendLv[i] : setPosition(110,60)
        self.defendBtn[i] : addChild(self.defendLv[i])

        self.defendLvLab[i] = _G.Util : createLabel("",20)
        self.defendLvLab[i] : setPosition( 15, 15 )
        -- self.defendLvLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        self.defendLv[i] : addChild(self.defendLvLab[i])

        self.defendName[i] = _G.Util : createLabel("",20)
        self.defendName[i] : setPosition( 65, 15 )
        self.defendBtn[i] : addChild(self.defendName[i])
    end

    local function defendCallBack(  obj, eventType )
        if eventType == ccui.TouchEventType.ended then
            print("保存阵容")
            local msg = REQ_LINGYAO_ARENA_BATTLE_SAVE()
            msg:setArgs(1,self.defendNum,self.defendData)
            _G.Network : send(msg)
        end
    end
    self.keepBtn    = gc.CButton : create("general_btn_gold.png")
    self.keepBtn    : setTitleFontName(_G.FontName.Heiti)
    self.keepBtn    : setTitleText("保 存")
    self.keepBtn    : setTitleFontSize(24)
    self.keepBtn    : setPosition(cc.p(kuangSize.width/2+150,55))
    self.keepBtn    : addTouchEventListener(defendCallBack)
    self.keepBtn    : setEnabled(false)
    self.keepBtn    : setBright(false)
    self.defendNode : addChild(self.keepBtn)
end

function ArenaView.RightAttackView( self )
    self.attackNode=cc.Node:create()
    self.dinsSpr:addChild(self.attackNode)

    local kuangSize=cc.size(861,516)
    local titleSpr   = cc.Sprite:createWithSpriteFrameName( "general_titlebg.png" ) 
    titleSpr         : setPosition(kuangSize.width/2+20,kuangSize.height-43)
    self.attackNode  : addChild(titleSpr)

    local titleLab=_G.Util:createLabel( "我方阵容",24)
    titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    titleLab:setPosition(kuangSize.width/2+20,kuangSize.height-45)
    self.attackNode:addChild(titleLab)

    local titleSpr   = cc.Sprite:createWithSpriteFrameName( "general_titlebg.png" ) 
    titleSpr         : setPosition(kuangSize.width/2+280,kuangSize.height-43)
    self.attackNode  : addChild(titleSpr)

    local titleLab=_G.Util:createLabel( "敌方阵容",24)
    titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    titleLab:setPosition(kuangSize.width/2+280,kuangSize.height-45)
    self.attackNode:addChild(titleLab)

    local lineSpr   = ccui.Scale9Sprite:createWithSpriteFrameName( "general_double_line.png" ) 
    lineSpr         : setPreferredSize(cc.size(440,3))
    lineSpr         : setPosition(kuangSize.width/2+150,kuangSize.height-80)
    self.attackNode : addChild(lineSpr)

    local lineSpr   = ccui.Scale9Sprite:createWithSpriteFrameName( "general_double_line.png" ) 
    lineSpr         : setPreferredSize(cc.size(440,2))
    lineSpr         : setPosition(kuangSize.width/2+150,kuangSize.height/2+65)
    self.attackNode : addChild(lineSpr)

    local lineSpr   = ccui.Scale9Sprite:createWithSpriteFrameName( "general_double_line.png" ) 
    lineSpr         : setPreferredSize(cc.size(440,2))
    lineSpr         : setPosition(kuangSize.width/2+150,kuangSize.height/2-47)
    self.attackNode : addChild(lineSpr)

    local lineSpr   = ccui.Scale9Sprite:createWithSpriteFrameName( "general_double_line.png" ) 
    lineSpr         : setPreferredSize(cc.size(440,3))
    lineSpr         : setPosition(kuangSize.width/2+150,100)
    self.attackNode : addChild(lineSpr)

    -- local function DefendCallBack(  obj, eventType )
    --     if eventType == ccui.TouchEventType.ended then
    --         local tag = obj : getTag()
    --         print("tag==>>",tag)
    --         if self.defendData[tag]==nil then return end
    --         if self.defendNum<2 then
    --             local command = CErrorBoxCommand("至少有一个灵妖上阵")
    --             controller : sendCommand( command )
    --         else
    --             self.defendData[tag]=nil
    --             self:updateDefend(self.defendData)
    --         end
    --     end
    -- end
    self.defendBtn  = {}
    self.noUpSpr    = {}
    self.defendfrom = {}
    self.defendLv   = {}
    self.defendLvLab= {}
    self.defendName = {}
    self.difangSpr  = {}
    self.dinoUpSpr  = {}
    local posX=kuangSize.width/2-30
    local posY=490
    for i=1,6 do
        if i%2==1 then
            posX=kuangSize.width/2-30
            posY=posY-112
            local numberSpr   = cc.Sprite:createWithSpriteFrameName( string.format("partner_num%d.png",i-(i-1)/2) ) 
            numberSpr         : setPosition(kuangSize.width/2-90,posY+20)
            self.attackNode : addChild(numberSpr)

            local onebyoneSpr   = cc.Sprite:createWithSpriteFrameName( "partner_vs.png" ) 
            onebyoneSpr         : setPosition(kuangSize.width/2+160,posY)
            self.attackNode : addChild(onebyoneSpr)
        else
            posX=kuangSize.width/2+75
        end
        local partnerRes = "partner_head.png"
        self.defendBtn[i] = gc.CButton:create(partnerRes)
        -- self.defendBtn[i] : loadTextures( partnerRes, partnerRes, partnerRes, ccui.TextureResType.plistType)
        self.defendBtn[i] : setPosition( posX, posY ) --121*length-105*i-55-18*x
        -- self.defendBtn[i] : addTouchEventListener(DefendCallBack)
        self.defendBtn[i] : setTag(i)
        self.defendBtn[i] : setButtonScale(0.75)
        self.defendBtn[i] : setTouchEnabled(false)
        self.defendBtn[i] : setVisible(false)
        self.attackNode:addChild(self.defendBtn[i])

        local Img="partner_noup.png"
        if (self.partnerNum==1 and i>1) or (self.partnerNum==2 and (i==2 or i>3)) 
            or (self.partnerNum==3 and (i==2 or i==4 or i==6)) or
            (self.partnerNum==4 and (i==4 or i==6)) or (self.partnerNum==5 and i==6) then
            Img="partner_nodown.png"
        end
        self.noUpSpr[i]=cc.Sprite:createWithSpriteFrameName(Img)
        self.noUpSpr[i]:setPosition(posX, posY)
        self.attackNode:addChild(self.noUpSpr[i])

        self.defendfrom[i]  = cc.Sprite:createWithSpriteFrameName("partner_frombg1.png")
        self.defendfrom[i]  : setPosition(45,90)
        self.defendBtn[i]   : addChild(self.defendfrom[i])

        self.defendLv[i] = gc.GraySprite:createWithSpriteFrameName("partner_lvbg.png")
        self.defendLv[i] : setPosition(110,60)
        self.defendBtn[i] : addChild(self.defendLv[i])

        self.defendLvLab[i] = _G.Util : createLabel("",20)
        self.defendLvLab[i] : setPosition( 15, 15 )
        -- self.defendLvLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        self.defendLv[i] : addChild(self.defendLvLab[i])

        self.defendName[i] = _G.Util : createLabel("",20)
        self.defendName[i] : setPosition( 65, 15 )
        self.defendBtn[i] : addChild(self.defendName[i])

        self.difangSpr[i] = cc.Sprite:createWithSpriteFrameName("partner_head.png")
        self.difangSpr[i] : setPosition(posX+280, posY)
        self.difangSpr[i] : setScale(0.75)
        self.difangSpr[i] : setVisible(false)
        self.attackNode:addChild(self.difangSpr[i])

        self.dinoUpSpr[i] = cc.Sprite:createWithSpriteFrameName("partner_nodown.png")
        self.dinoUpSpr[i] : setPosition(posX+280, posY)
        self.attackNode : addChild(self.dinoUpSpr[i])
    end

    local function defendCallBack(  obj, eventType )
        if eventType == ccui.TouchEventType.ended then
            local tag=obj:getTag()
            if tag==777 then
                print("替换防守阵容")
                local msg = REQ_LINGYAO_ARENA_DEF()
                msg:setArgs(0)
                _G.Network : send(msg)
            else
                if self.m_guide_wait_start then
                    self.m_guide_wait_start=nil
                    _G.GGuideManager:clearCurGuideNode()
                    self:sendTiaoZhanMsg()
                    return
                end
                if isGoCopy==false then
                    local msgcount=#self.partnerMsg
                    print("开战",msgcount)
                    if msgcount>5 then msgcount=6 end
                    if self.defendNum<msgcount then
                        self:goCopyTipsBox()
                        return
                    else
                        self:sendTiaoZhanMsg()
                    end
                else
                    self:sendTiaoZhanMsg()
                end
            end
        end
    end
    local defendBtn = gc.CButton : create("general_btn_gold.png")
    defendBtn    : setTitleFontName(_G.FontName.Heiti)
    defendBtn    : setTitleText("防守阵容")
    defendBtn    : setTitleFontSize(22)
    defendBtn    : setPosition(cc.p(kuangSize.width/2+10,55))
    defendBtn    : addTouchEventListener(defendCallBack)
    defendBtn    : setTag(777)
    self.attackNode : addChild(defendBtn)

    local attackBtn    = gc.CButton : create("general_btn_gold.png")
    attackBtn    : setTitleFontName(_G.FontName.Heiti)
    attackBtn    : setTitleText("开 战")
    attackBtn    : setTitleFontSize(22)
    attackBtn    : setPosition(cc.p(kuangSize.width/2+290,55))
    attackBtn    : addTouchEventListener(defendCallBack)
    attackBtn    : setTag(888)
    self.attackNode : addChild(attackBtn)
end

function ArenaView.updateDefend( self,_data,_type)
    if _data==nil then return end
    self.isTrue=true
    if _type then
        -- self.firstData=_data
        self.isTrue=false
    end

    for k,v in pairs(_data) do
        self.defendData[v.pos]=v
    end

    if self.keepBtn~=nil then
        self.keepBtn:setEnabled(self.isTrue)
        self.keepBtn:setBright(self.isTrue)
    end

    if self.partnerHead~=nil then
        for k,v in pairs(self.partnerHead) do
            v:removeFromParent(true)
            v=nil

            self.noUpSpr[k]     : setVisible(true)
            self.defendBtn[k]   : setVisible(false)
            self.defendfrom[k]  : setSpriteFrame("partner_frombg1.png")
            self.defendLvLab[k] : setString("")
            self.defendName[k]  : setString("")
        end
    end

    if self.partnerMsg~=nil then
        for k,v in pairs(self.partnerMsg) do
            self.UpdefendSpr[v.id] : setVisible(false)
        end
    end
    self.partnerHead={}
    self.defendNum=0
    for k,v in pairs(_data) do
        print("updateDefend>>",k,v.pos,v.id)
        self.defendNum=self.defendNum+1
        self.UpdefendSpr[v.id] : setVisible(true)
        self.noUpSpr[v.pos]:setVisible(false)
        self.defendBtn[v.pos]:setVisible(true)

        local partnerData=_G.Cfg.partner_init[v.id]
        self.partnerHead[v.pos] = cc.Sprite:createWithSpriteFrameName(string.format("h%d.png",partnerData.head_icon))
        self.partnerHead[v.pos] : setPosition(73,57)
        self.defendBtn[v.pos]   : addChild(self.partnerHead[v.pos],-1)

        local fromimg=string.format("partner_frombg%d.png",v.camp)
        self.defendfrom[v.pos]  : setSpriteFrame(fromimg)
        self.defendLvLab[v.pos] : setString(v.lv)
        self.defendName[v.pos]  : setString(partnerData.name)
        self.defendName[v.pos]  : setColor(_G.ColorUtil:getRGB(partnerData.name_colour))
    end
end

function ArenaView.updateDiFang( self,_data)
    if _data==nil then return end
    for i=1,6 do
        self.difangSpr[i]:setVisible(false)
        self.dinoUpSpr[i]:setVisible(true)
    end
    for k,v in pairs(_data) do
        print("difangSpr==>>",v.pos,v.id)
        self.difangSpr[v.pos]:setVisible(true)
        self.dinoUpSpr[v.pos]:setVisible(false)

        local partnerData=_G.Cfg.partner_init[v.id]
        local difangLvSpr = gc.GraySprite:createWithSpriteFrameName("partner_lvbg.png")
        difangLvSpr : setPosition(110,60)
        self.difangSpr[v.pos] : addChild(difangLvSpr)

        local difangLvLab = _G.Util : createLabel(v.lv,20)
        difangLvLab : setPosition( 15, 15 )
        -- difangLvLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        difangLvSpr : addChild(difangLvLab)

        local fifangNameLab = _G.Util : createLabel(partnerData.name,20)
        fifangNameLab : setColor(_G.ColorUtil:getRGB(partnerData.name_colour))
        fifangNameLab : setPosition( 65, 15 )
        self.difangSpr[v.pos] : addChild(fifangNameLab)

        local difangHead = cc.Sprite:createWithSpriteFrameName(string.format("h%d.png",partnerData.head_icon))
        difangHead : setPosition(73,57)
        self.difangSpr[v.pos] : addChild(difangHead,-1)

        local fromimg=string.format("partner_frombg%d.png",v.camp)
        local difangDrom = gc.GraySprite:createWithSpriteFrameName(fromimg)
        difangDrom : setPosition(45,90)
        self.difangSpr[v.pos] : addChild(difangDrom)  
    end
end

function ArenaView.updateCountdown( self,goods_id,all_count,count,_time)
    print("updateCountdown-->>",goods_id,all_count)
    -- local goodsName=_G.Cfg.goods[goods_id].name
    -- self.rewardLab:setString(goodsName)
    self.countdown=all_count
    self.m_gold=count
    self.m_time=_time
    if self.countdown==0 then
        self.rewardBtn:setBright(false)
        self.rewardBtn:setEnabled(false)
    end
end

function ArenaView.__initCountdown(self)
    if  self.countdown then
        local nowSeconds =_G.TimeUtil : getServerTimeSeconds()
        local State=math.floor((nowSeconds-self.m_time)/3600)
        local m_second    = math.floor(nowSeconds%60)
        -- print("self.m_second==>>",m_second,self.m_gold,self.countdown,State)
        if m_second==0 and self.m_gold~=0 and State<24 then
            self.countdown=self.countdown+self.m_gold
            if self.countdown>0 then 
                self.rewardBtn:setBright(true)
                self.rewardBtn:setEnabled(true)
            end
        end
        self.m_rootLayer : getChildByTag(ARENA_BG_TAG) : getChildByTag(COUNTDOWN_TIME_TAG) : setString(self.countdown)
    end

    if  self.coolTime  then
        self.m_rootLayer : getChildByTag(ARENA_BG_TAG) : getChildByTag(SELF_COOL_TIME_TAG) : setString(self : __getTimeStr(1,self.coolTime - _G.TimeUtil : getServerTimeSeconds()))
        if self : __getTimeStr(1,self.coolTime - _G.TimeUtil : getServerTimeSeconds())=="00:00" then
            self.m_rootLayer : getChildByTag(ARENA_BG_TAG) : getChildByTag(SELF_COOL_TIME_TAG):setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        else
            self.m_rootLayer : getChildByTag(ARENA_BG_TAG) : getChildByTag(SELF_COOL_TIME_TAG):setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_ORED))
        end
        if self.coolTime - _G.TimeUtil : getServerTimeSeconds() == 0 then
            self.coolTime = nil
        end
    end

    if self.interval ~= 0 then
        self.interval = self.interval - 1
    end
end

function ArenaView.__getTimeStr( self, type,_time)
    _time = _time < 0 and 0 or _time
    local hour   = math.floor(_time/3600)
    local min    = math.floor(_time%3600/60)
    local second = math.floor(_time%60)
    local time = tostring(hour)..":"..tostring(min)..":"..second
    if hour < 10 then
        hour = "0"..hour
    elseif hour < 0 then
        hour = "00"
    end
    if min < 10 then
        min = "0"..min
    elseif min < 0 then
        min = "00"
    end
    if second < 10 then
        second = "0"..second
    end

    local time = ""

    if     0 == type then
        time = tostring(hour)..":"..tostring(min)..":"..second
    elseif 1 == type then
        time = tostring(min)..":"..second
    end

    return time
end

-- function ArenaView.__loadPersonDins( self,position )
--     local arenaBG = self.m_rootLayer : getChildByTag(ARENA_BG_TAG)
    
--     local personDins = cc.Sprite : createWithSpriteFrameName("arena_person_dins.png")
--     personDins       : setPosition(position)
--     arenaBG          : addChild(personDins,0)
-- end

function ArenaView.__setPowerNumber(self,number)
    if number == nil then
        number = 1
    end
    --[[
    local numberString  = tostring( number )
    local length        = string.len( numberString)
    local numberNode    = cc.Node : create()
    local spriteWidth   = 0
    for i = 1, length do
        local _tempSpr  = cc.Sprite : createWithSpriteFrameName( "general_"..string.sub(numberString,i,i)..".png")
        numberNode      : addChild( _tempSpr )

        local _tempSprSize = _tempSpr : getContentSize()
        spriteWidth        = spriteWidth + _tempSprSize.width / 2+5
        _tempSpr           : setPosition( cc.p(spriteWidth,0))
    end
    ]]--
    local numberNode = _G.Util : createLabel("战:"..tostring(number),20)
    numberNode       : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_YELLOW))
    return numberNode
end

function ArenaView.__setRankNumber(self,number)
    if number == nil then
        number = 1
    end
    --[[
    local numberString  = tostring( number )
    local length        = string.len( numberString)
    local numberNode    = cc.Node : create()
    local spriteWidth   = 0
    for i = 1, length do
        local _tempSpr = cc.Sprite : createWithSpriteFrameName( "main_lv_"..string.sub(number,i,i)..".png")
        _tempSpr       : setScale(1.2)
        numberNode     : addChild( _tempSpr )

        local _tempSprSize = _tempSpr : getContentSize()
        spriteWidth        = spriteWidth + _tempSprSize.width / 2+5
        _tempSpr           : setPosition( cc.p(spriteWidth,0))
    end
    ]]--
    local numberNode = _G.Util : createBorderLabel(string.format("排名:%d",number),20)
    -- numberNode       : setAnchorPoint(cc.p(0,0.5))
    numberNode       : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    return numberNode
end

function ArenaView.__setLvNumber(self,_name)
    local lvLabel       = _G.Util : createLabel(_name,20)
    --lvLabel           : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_YELLOW))
    return lvLabel
end

function ArenaView.__setName(self,name)
    if name == nil then
        name = "??????"
    end
    CCLOG("名字%s",name)
    local nameLabel = _G.Util : createLabel(name,20)
    nameLabel       : setColor(_G.ColorUtil : getRGB(2))
    return nameLabel
end

function ArenaView.__createLabel(self,_string)
    if _string == nil then
        _string = "??????"
    end
    local textLabel = _G.Util : createLabel(_string,20)
    -- textLabel       : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GOLD))
    return textLabel
end

function ArenaView.__setMsg(self,_string)
    if _string == nil then
        _string = "??????"
    end
    local msgLabel = _G.Util : createLabel(_string,20)
    msgLabel       : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    return msgLabel
end

function ArenaView.updateData(self,_msg)
    if self.personNode then
        self.personNode : removeFromParent()
        self.personNode = nil
    end
    --更新挑战灵妖信息
    print("开始更新灵妖信息",_msg.challage_player_data)
    self.m_personCount = _msg.count
    self.person.count  = _msg.count - 1
    self               : __updatePersonMsg(_msg.challage_player_data)
    print("灵妖信息更新结束")
    self               : __updateSelfData(_msg)
end

function ArenaView.__updateSelfData( self,_msg )
    print("开始更新自己的信息")
    local myPersonUid = _G.GPropertyProxy : getMainPlay() : getUid()
    local arenaBG     = self.m_rootLayer : getChildByTag(ARENA_BG_TAG)

    for i = 1,_msg.count do
        if myPersonUid == _msg.challage_player_data[i].uid then
            print("有没进来")
            arenaBG : getChildByTag(SELF_RANK_TAG) : setString(_msg.challage_player_data[i].rank)
            if _msg.challage_player_data[i].rank<=_G.Const.CONST_ARENA_JJC_SHUAXIN then
                print("有没进来")
                self.newBtn : setVisible(true)
            end
            break
        end
    end
end

function ArenaView.updateSelfChallengeCount( self,_count )
    print("更新挑战次数===================>")
    local arenaBG     = self.m_rootLayer : getChildByTag(ARENA_BG_TAG)
    arenaBG           : getChildByTag(SELF_CHALLENGE_COUNT_TAG) : setString(tostring(_count))

    if self.isClickPerson then
        if self.coolTimeMsg.rmb == 0 then
            _G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_ARENA_THE_ARENA_ID)
            -- self:defendView()
            local msg = REQ_LINGYAO_REQUEST()
            msg        : setArgs(2)
            _G.Network : send(msg)
            local msg          = REQ_LINGYAO_ARENA_RIVAL_REQUEST()
            msg                : setArgs(self.t_uid,self.t_rank)
            _G.Network         : send(msg)
            self.isClickPerson = false

            if self.m_guide_hide then
                self.m_guide_hide=nil
                _G.GGuideManager:hideGuideByStep(1)
            end
        else
            self : __isCleanCoolTime()
        end
    end
end

function ArenaView.isDouble(self,_value)
    self.value=_value
end

function ArenaView.updateSelfCoolTime( self,_time )
    print("更新挑战冷却时间===================>")

    if self.isClickPerson then
        _G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_ARENA_THE_ARENA_ID)
        self:sendTiaoZhanMsg()
        self.isClickPerson = false
    end
    
    print(self: __getTimeStr(1,_time))
    self.coolTime     = _time+_G.TimeUtil : getServerTimeSeconds()
end

function ArenaView.__updatePersonMsg( self,_msg )
    local i           = 1
    local myPersonUid = _G.GPropertyProxy : getMainPlay() : getUid()
    local arenaBG     = self.m_rootLayer : getChildByTag(ARENA_BG_TAG)
    local arenaSize=arenaBG:getContentSize()
    if _msg[i] == nil then
        return 
    end

    if myPersonUid == _msg[i].uid then
        i = i + 1
    end

    if i > self.m_personCount then
        return 
    end
    print("更新－－－－－－第一个灵妖".."排名"..tostring(_msg[i].rank))
    self : __loadPerson(1,1,_msg[i].lingyao_id,cc.p(arenaSize.width/2-150,280))

    --self.personNode : getChildByTag(PERSON_ONE_NAME_TAG) : setString(_msg[i].name)
    self.personNode : getChildByTag(PERSON_ONE_LV_TAG) : setString(_msg[i].name)
    self    : __updateRank(_msg[i].rank,PERSON_ONE_RANK_TAG)
    self    : __updatePower(_msg[i].power,PERSON_ONE_POWER_TAG)

    self.person[1].uid      = _msg[i].uid
    self.person[1].rank  = _msg[i].rank

    i = i + 1

    if _msg[i] == nil then
        return
    end

    if myPersonUid == _msg[i].uid then
        i = i + 1
    end

    if i > self.m_personCount then
        return 
    end
    
    print("更新－－－－－－第二个灵妖")
    self : __loadPerson(2,2,_msg[i].lingyao_id,cc.p(arenaSize.width/2+150,280))
    
    --self.personNode : getChildByTag(PERSON_TWO_NAME_TAG) : setString(_msg[i].name)
    self.personNode : getChildByTag(PERSON_TWO_LV_TAG) : setString(_msg[i].name)
    self    : __updateRank(_msg[i].rank,PERSON_TWO_RANK_TAG)
    self    : __updatePower(_msg[i].power,PERSON_TWO_POWER_TAG)

    self.person[2].uid      = _msg[i].uid
    self.person[2].rank  = _msg[i].rank

    i = i + 1

    if _msg[i] == nil then
        return
    end

    if myPersonUid == _msg[i].uid then
        i = i + 1
    end

    if i > self.m_personCount then
        return 
    end

    print("更新－－－－－－第三个灵妖")
    self : __loadPerson(3,3,_msg[i].lingyao_id,cc.p(arenaSize.width/2-300,20))
    
    --self.personNode : getChildByTag(PERSON_THREE_NAME_TAG) : setString(_msg[i].name)
    self.personNode : getChildByTag(PERSON_THREE_LV_TAG) : setString(_msg[i].name)
    self    : __updateRank(_msg[i].rank,PERSON_THREE_RANK_TAG)
    self    : __updatePower(_msg[i].power,PERSON_THREE_POWER_TAG)

    self.person[3].uid      = _msg[i].uid
    self.person[3].rank  = _msg[i].rank

    i = i + 1

    if _msg[i] == nil then
        return
    end

    if myPersonUid == _msg[i].uid then
        i = i + 1
    end

    if i > self.m_personCount then
        return 
    end

    print("更新－－－－－－第四个灵妖")
    self : __loadPerson(4,4,_msg[i].lingyao_id,cc.p(arenaSize.width/2,20))
    
    --self.personNode : getChildByTag(PERSON_FOUR_NAME_TAG) : setString(_msg[i].name)
    self.personNode : getChildByTag(PERSON_FOUR_LV_TAG):setString(_msg[i].name)
    self    : __updateRank(_msg[i].rank,PERSON_FOUR_RANK_TAG)
    self    : __updatePower(_msg[i].power,PERSON_FOUR_POWER_TAG)

    self.person[4].uid      = _msg[i].uid
    self.person[4].rank  = _msg[i].rank

    i = i + 1

    if _msg[i] == nil then
        return
    end

    if myPersonUid == _msg[i].uid then
        i = i + 1
    end

    if i > self.m_personCount then
        return 
    end

    print("更新－－－－－－第五个灵妖")
    self : __loadPerson(5,5,_msg[i].lingyao_id,cc.p(arenaSize.width/2 + 300,20))

    --self.personNode : getChildByTag(PERSON_FIVE_NAME_TAG) : setString(_msg[i].name)
    self.personNode : getChildByTag(PERSON_FIVE_LV_TAG) : setString(_msg[i].name)
    self    : __updateRank(_msg[i].rank,PERSON_FIVE_RANK_TAG)
    self    : __updatePower(_msg[i].power,PERSON_FIVE_POWER_TAG)

    self.person[5].uid      = _msg[i].uid
    self.person[5].rank  = _msg[i].rank
end

function ArenaView.__loadPerson(self,i,type,partnerId,position)
    print("灵妖模型",partnerId)
    if partnerId==0 then partnerId=11107 end
    local arenaBG    = self.m_rootLayer : getChildByTag(ARENA_BG_TAG)

    if not self.personNode then
        self.personNode = cc.Node:create()
        self.personNode : setPosition(cc.p(0,0))
        arenaBG : addChild(self.personNode,1)
    end

    local scale=0.4
    if _G.Cfg.partner_init[partnerId].showscale~=nil then
        scale=_G.Cfg.partner_init[partnerId].showscale/10000*0.6
    end
    local person    = _G.SpineManager.createPartner(partnerId,scale)
    person          : setPosition(position.x,position.y+50)
    person          : setAnimation(0,"idle",true)
    self.personNode : addChild(person,1)

    -- if wuqiSke then
    --     wuqiSke          : setAnimation(0,"idle",true)
    -- end

    -- if featherSke then
    --     featherSke       : setAnimation(0,string.format("idle_%d",(10000+_pro)),true)
    -- end
    
    local function func(sneder,eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.interval ~= 0 then
                return true
            end
            self.isClickPerson = true
            print("挑战灵妖  ",i,"uid: ",self.person[i].uid," rank: ",self.person[i].rank)
            _G.GPropertyProxy  : setAutoPKSceneId(_G.Const.CONST_ARENA_THE_ARENA_ID)
            self:defendView()
            local msg = REQ_LINGYAO_REQUEST()
            msg        : setArgs(2)
            _G.Network : send(msg)
            local msg     = REQ_LINGYAO_ARENA_RIVAL_REQUEST()
            msg           : setArgs(self.person[i].uid,self.person[i].rank)
            _G.Network    : send(msg)
            self.t_uid    = self.person[i].uid
            self.t_rank   = self.person[i].rank
            self.interval = 1
        end
        return true
    end

    local listerner = cc.EventListenerTouchOneByOne : create()
    listerner : registerScriptHandler(func,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner : setSwallowTouches(true)

    local personLab = ccui.Widget : create()
    personLab       : setContentSize(cc.size(70,250))
    personLab       : setPosition(cc.p(position.x,position.y+170))
    personLab       : setTouchEnabled(true)
    personLab   : addTouchEventListener(func)
    self.personNode         : addChild(personLab,2)

    if self.m_guide_wait then
        self.m_guide_wait=nil
        self.m_guide_layout=true
        _G.GGuideManager:registGuideData(1,personLab)
        _G.GGuideManager:runNextStep()
    end

    self.person[i] = {}
    self.person[i].person = person

    local dataDins = ccui.Scale9Sprite : createWithSpriteFrameName("general_fram_dins.png")
    dataDins       : setPreferredSize(cc.size(210,80))
    dataDins       : setPosition(cc.p(position.x,position.y+265))
    self.personNode        : addChild(dataDins,1)

    --local powerIcon = cc.Sprite : createWithSpriteFrameName("main_fighting_2.png")
    --powerIcon         : setPosition(cc.p(position.x - 35,position.y - 65))
    --self.personNode       : addChild(powerIcon,2)

    local powerNumber = self : __setPowerNumber(99999)
    powerNumber       : setPosition(cc.p(position.x,position.y+240))
    if     1 == type then
        powerNumber : setTag(PERSON_ONE_POWER_TAG)
    elseif 2 == type then
        powerNumber : setTag(PERSON_TWO_POWER_TAG)
    elseif 3 == type then
        powerNumber : setTag(PERSON_THREE_POWER_TAG)
    elseif 4 == type then
        powerNumber : setTag(PERSON_FOUR_POWER_TAG)
    else
        powerNumber : setTag(PERSON_FIVE_POWER_TAG)
    end
    self.personNode         : addChild(powerNumber,2)

    local lvNumber = self : __setLvNumber("小红小小红小")
    lvNumber       : setPosition(cc.p(position.x,position.y+263))
    if     1 == type then
        lvNumber   : setTag(PERSON_ONE_LV_TAG)
    elseif 2 == type then
        lvNumber   : setTag(PERSON_TWO_LV_TAG)
    elseif 3 == type then
        lvNumber   : setTag(PERSON_THREE_LV_TAG)
    elseif 4 == type then
        lvNumber   : setTag(PERSON_FOUR_LV_TAG)
    else
        lvNumber   : setTag(PERSON_FIVE_LV_TAG)
    end
    self.personNode        : addChild(lvNumber,2)
    --[[
    local nameLabel = self : __setName("小红小小红小")
    nameLabel       : setPosition(cc.p(position.x +40,position.y - 45))
    if     1 == type then
        nameLabel   : setTag(PERSON_ONE_NAME_TAG)
    elseif 2 == type then
        nameLabel   : setTag(PERSON_TWO_NAME_TAG)
    elseif 3 == type then
        nameLabel   : setTag(PERSON_THREE_NAME_TAG)
    elseif 4 == type then
        nameLabel   : setTag(PERSON_FOUR_NAME_TAG)
    else
        nameLabel   : setTag(PERSON_FIVE_NAME_TAG)
    end
    self.personNode         : addChild(nameLabel,2)
    
    local rankIcon = cc.Sprite : createWithSpriteFrameName("arena_rank_icon.png")
    rankIcon       : setScale(1.2)
    rankIcon       : setPosition(cc.p(position.x - 30,position.y -15))
    self.personNode: addChild(rankIcon,2)
    ]]--
    -- local rankTips   = _G.Util : createBorderLabel("排名：",20)
    -- rankTips         : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    -- rankTips         : setPosition(cc.p(position.x - 10,position.y -18))
    -- self.personNode  : addChild(rankTips,2)

    local numberNode = self : __setRankNumber(111)
    numberNode       : setPosition(cc.p(position.x,position.y+287))
    if     1 == type then
        numberNode   : setTag(PERSON_ONE_RANK_TAG)
    elseif 2 == type then
        numberNode   : setTag(PERSON_TWO_RANK_TAG)
    elseif 3 == type then
        numberNode   : setTag(PERSON_THREE_RANK_TAG)
    elseif 4 == type then
        numberNode   : setTag(PERSON_FOUR_RANK_TAG)
    else
        numberNode   : setTag(PERSON_FIVE_RANK_TAG)
    end
    self.personNode          : addChild(numberNode,2)
end

function ArenaView.getCoolState( self,_msg )
    print("花费"..tostring(_msg.rmb).."元宝清除冷却时间")
    print("挑战次数"..tostring(_msg.surplus))
    self.coolTimeMsg = _msg
    if _msg.surplus == 0 then
        if isBuyTip then
            print("直接购买＝＝＝＝＝＝＝＝＝＝不弹出提示框")
            local msg  = REQ_LINGYAO_ARENA_BUY()
            msg:setArgs(1)
            _G.Network : send(msg)
        else
            self : __buyNetWorkSend()
        end
    else
        self : __isCleanCoolTime()
    end
end

function ArenaView.__isCleanCoolTime( self )
    local _msg = self.coolTimeMsg
    if isCoolTimeBuyTip then
        print("直接购买冷却＝＝＝＝＝＝＝＝＝＝不弹出提示框")
        local msg  = REQ_LINGYAO_ARENA_CD_CLEAN()
        _G.Network : send(msg)
        
    else
        self : __initTipsBox(_msg.rmb)
    end
end

function ArenaView.sendTiaoZhanMsg(self)
    local tempArray={}
    local tempCount=0
    for pos,v in pairs(self.defendData) do
        tempCount=tempCount+1
        tempArray[tempCount]={id=v.id,pos=pos}
    end
    local msg  = REQ_LINGYAO_ARENA_BATTLE()
    msg        : setArgs(self.t_uid,self.t_rank,nil,tempCount,tempArray)
    _G.Network : send(msg)
end
function ArenaView.goCopyTipsBox( self )
    print("初始化购买消除冷却界面")

    local function go()
        self:sendTiaoZhanMsg()
    end


    local topLab    = "你有队伍没有放置灵妖，是否继续开战？"
    -- local centerLab = _G.Lang.LAB_N[940]
    local rightLab  = _G.Lang.LAB_N[106]

    local szSureBtn = _G.Lang.BTN_N[1]

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",go)
    -- layer       : setPosition(cc.p(-self.m_winSize.width/2,-self.m_winSize.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

    local layer=view:getMainlayer()
    view:setTitleLabel("提示")
    if topLab ~= nil then
        local label =_G.Util : createLabel(topLab,20)
        label       : setPosition(cc.p(0,40))
        layer       : addChild(label,88)
    end
    -- if centerLab ~= nil then
    --     local label =_G.Util : createLabel(centerLab,18)
    --     label       : setPosition(cc.p(0,20))
    --     layer       : addChild(label,88)
    -- end

    if rightLab then
        local label =_G.Util : createLabel(rightLab,20)
        label       : setPosition(cc.p(25,-37))
        layer       : addChild(label,88)
    end
    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("勾选了不再提示",isGoCopy)
            if isGoCopy then
                isGoCopy = false
                -- _G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_LYJJ+1,false)
            else
                isGoCopy = true
                -- _G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_LYJJ+1,true)
            end
        end
    end

    local checkbox   = ccui.CheckBox : create()
    checkbox         : loadTextures("general_gold_floor.png","general_gold_floor.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox         : setPosition(cc.p(-80,-35))
    checkbox         : setName("sdjfgksjdfklgj")
    checkbox         : addTouchEventListener(c)
    -- checkbox         : setAnchorPoint(cc.p(1,0.5))
    layer            : addChild(checkbox)
end

function ArenaView.__initTipsBox( self,_rmb)
    print("初始化购买消除冷却界面")

    local function buy()
        local msg  = REQ_LINGYAO_ARENA_CD_CLEAN()
        _G.Network : send(msg)
    end

    local function cancel( ... )
        print("取消")
        self.isClickPerson = false
    end

    local topLab    = "花费"..tostring(_rmb).."元宝清除冷却时间?"
    local centerLab = _G.Lang.LAB_N[940]
    local rightLab  = _G.Lang.LAB_N[106]

    local szSureBtn = _G.Lang.BTN_N[1]

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",buy,cancel)
    -- layer       : setPosition(cc.p(-self.m_winSize.width/2,-self.m_winSize.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

    local layer=view:getMainlayer()
    view:setTitleLabel("提示")
    if topLab ~= nil then
        local label =_G.Util : createLabel(topLab,20)
        label       : setPosition(cc.p(0,45))
        layer       : addChild(label,88)
    end
    if centerLab ~= nil then
        local label =_G.Util : createLabel(centerLab,18)
        label       : setPosition(cc.p(0,20))
        layer       : addChild(label,88)
    end

    if rightLab then
        local label =_G.Util : createLabel(rightLab,20)
        label       : setPosition(cc.p(25,-37))
        layer       : addChild(label,88)
    end
    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("勾选了不再提示",isCoolTimeBuyTip)
            if isCoolTimeBuyTip then
                isCoolTimeBuyTip = false
                _G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_LYJJ+1,false)
            else
                isCoolTimeBuyTip = true
                _G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_LYJJ+1,true)
            end
        end
    end

    local checkbox   = ccui.CheckBox : create()
    checkbox         : loadTextures("general_gold_floor.png","general_gold_floor.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox         : setPosition(cc.p(-80,-35))
    checkbox         : setName("sdjfgksjdfklgj")
    checkbox         : addTouchEventListener(c)
    -- checkbox         : setAnchorPoint(cc.p(1,0.5))
    layer            : addChild(checkbox)
end

function ArenaView.__updateRank( self,_number,_tag )
    print(_tag)
    local rankNode = self : __setRankNumber(_number)
    local arenaBG  = self.personNode
    rankNode       : setPosition(cc.p(arenaBG : getChildByTag(_tag) : getPosition()))
    arenaBG        : getChildByTag(_tag) : removeFromParent()
    arenaBG        : addChild(rankNode,3)
end

function ArenaView.__updatePower( self,_number,_tag )
    local powerNode = self : __setPowerNumber(_number)
    local arenaBG   = self.personNode
    powerNode       : setPosition(cc.p(arenaBG : getChildByTag(_tag) : getPosition()))
    arenaBG         : getChildByTag(_tag) : removeFromParent()
    arenaBG         : addChild(powerNode,2)
end

--初始化排名奖励UI
function ArenaView.__initRankLayer(self)
    print("初始化排名奖励UI")
    -- self._mainSize    = cc.size(800,525)
    
    self              : __initRankView()
    -- self._mainSize    = cc.size(self.rankBG : getContentSize().width,self.rankBG : getContentSize().height - 100)
    -- self.oneHeight = cc.size(self._mainSize.Width,self._mainSize.height/10.0)
    self              : __rankNetWorkSend()
end

function ArenaView.__onCloseRankUI(self)
    print("关闭排名奖励界面")
    cc.Director : getInstance() : getRunningScene() : getChildByTag(RANK_UI_TAG) : removeFromParent()
end

function ArenaView.__initRankView( self )
    local function onTouchBegan(touch,event)
        return true
    end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rankLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rankLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rankLayer)
    cc.Director:getInstance():getRunningScene():addChild(self.m_rankLayer,1000)

    local rankSize=cc.size(732,517)
    local secondSize=cc.size(712,460)
    local Spr1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_tips_dins.png" )
    Spr1 : setPreferredSize( rankSize )
    Spr1 : setPosition( self.m_winSize.width/2, self.m_winSize.height/2-20 )
    self.m_rankLayer : addChild( Spr1 )

    local function closeFunSetting()
        print( "开始关闭" )
        self.m_rankLayer:removeFromParent(false)
        self.m_rankLayer=nil
    end

    local Btn_Close = gc.CButton : create("general_close.png")
    Btn_Close   : setPosition( cc.p( rankSize.width-23, rankSize.height-24) )
    Btn_Close   : addTouchEventListener( closeFunSetting )
    Spr1 : addChild( Btn_Close , 8 )

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(rankSize.width/2-135, rankSize.height-28)
    Spr1 : addChild(tipslogoSpr)

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(rankSize.width/2+130, rankSize.height-28)
    tipslogoSpr : setRotation(180)
    Spr1 : addChild(tipslogoSpr)

    local m_titleLab=_G.Util:createBorderLabel("排名奖励",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    m_titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    m_titleLab:setPosition(rankSize.width/2,rankSize.height-26)
    Spr1:addChild(m_titleLab)

    local di2kuanbg = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    di2kuanbg       : setPreferredSize(secondSize)
    di2kuanbg       : setPosition(cc.p(rankSize.width/2,rankSize.height/2-18))
    Spr1       : addChild(di2kuanbg)

    local fontSize  = 20
    local height    = 450
    local color     = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW)

    local login_Lab1= _G.Util : createLabel("排名", fontSize)
    -- login_Lab1      : setColor(color)
    login_Lab1      : setPosition(cc.p(65, height)) 
    Spr1     : addChild(login_Lab1)

    local login_Lab2= _G.Util : createLabel("玩家名称", fontSize)
    -- login_Lab2      : setColor(color)
    login_Lab2      : setPosition(cc.p(260, height)) 
    Spr1     : addChild(login_Lab2)

    -- local login_Lab3= _G.Util : createLabel("等级", fontSize)
    -- -- login_Lab3      : setColor(color)
    -- login_Lab3      : setPosition(cc.p(330, height)) 
    -- Spr1     : addChild(login_Lab3)

    local login_Lab4= _G.Util : createLabel("防守阵容战力", fontSize)
    -- login_Lab4      : setColor(color)
    login_Lab4      : setPosition(cc.p(455, height)) 
    Spr1     : addChild(login_Lab4)

    local login_Lab5= _G.Util : createLabel("分钟妖灵", fontSize)
    -- login_Lab5      : setColor(color)
    login_Lab5      : setPosition(cc.p(655, height)) 
    Spr1     : addChild(login_Lab5)

    local lineBg      = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    lineBg            : setPreferredSize( cc.size(rankSize.width-20, 3) )
    lineBg            : setAnchorPoint( cc.p(0.0,0.5) )
    lineBg            : setPosition(cc.p(10,height - 18))
    Spr1       : addChild(lineBg)

    local lineBg1     = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    lineBg1           : setPreferredSize( cc.size(rankSize.width-20, 3) )
    lineBg1           : setAnchorPoint( cc.p(0.0,0.5) )
    lineBg1           : setPosition(cc.p(10,75))
    Spr1       : addChild(lineBg1)

    -- local lineBg2     = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    -- lineBg2           : setPreferredSize( cc.size(rankSize.width-20, 2) )
    -- lineBg2           : setAnchorPoint( cc.p(0.0,0.5) )
    -- lineBg2           : setPosition(cc.p(10,37))
    -- Spr1       : addChild(lineBg2)

    local tipLab = _G.Util : createLabel("每分钟奖励累计超过24小时没有领取将不再增加。", fontSize-2)
    tipLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    tipLab       : setAnchorPoint(cc.p(0,0.5))
    tipLab       : setPosition(cc.p( 70, 26)) 
    Spr1  : addChild(tipLab)

    self.rankBG=Spr1
end

function ArenaView.__rankNetWorkSend( self )
    local msg = REQ_LINGYAO_ARENA_RANK_REQUEST()
    _G.Network : send(msg)
end

function ArenaView.updateRankMsg( self ,_msg)
    print("高手排名信息已经收到")
    if _msg.count2 < 1 then
        return
    end
    self : __rankScrollView(_msg)
end

function ArenaView.__rankScrollView( self ,_msg)
    print("初始化滚动框")
    local secondSize=cc.size(712,355)
    self.oneHeight=secondSize.height/10
    self.Sc_Container = cc.Node : create()
    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView = ScrollView
    
    local count        = 20
    if _msg.count2 <= 10 then
        count = 10
    else
        count = _msg.count2
    end
    local viewSize     = cc.size(secondSize.width, secondSize.height)
    local m_size = cc.size(secondSize.width, self.oneHeight*count)
    
    ScrollView      : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView      : setViewSize(viewSize)
    ScrollView      : setContentSize(m_size)
    ScrollView      : setContentOffset( cc.p( 0, viewSize.height-m_size.height))
    ScrollView      : setPosition(cc.p(10, 64))
    print("容器大小：", m_size.width,self.oneHeight*count)
    ScrollView      : setBounceable(true)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    
    self.Sc_Container : addChild(ScrollView)
    self.Sc_Container : setPosition(cc.p(0,14))
    self.rankBG       : addChild(self.Sc_Container,2)

    local barView = require("mod.general.ScrollBar")(ScrollView)
    barView       : setPosOff(cc.p(-8,0))
    -- barView       : setMoveHeightOff(-5)

    for i=1,_msg.count2 do
        print(i)
        self.m_ScrollView : addChild(self : __createRankLabel(i,_msg.rank_data,0,m_size))
    end

    local myMsg = _G.GPropertyProxy : getMainPlay()

    local myData = {}

    myData[_msg.rank+1] = {
        rank    = _msg.rank,
        name    = myMsg : getName(),
        lv      = myMsg : getLv(),
        powerful= _msg.powerful,
        count   = _msg.count,
        goods_data= _msg.goods_data,
    }
    local myRankLab = self : __createRankLabel(_msg.rank+1,myData,1,m_size)
    myRankLab       : setPosition(cc.p(10,40))

    local star     = cc.Sprite : createWithSpriteFrameName("general_star.png")
    -- star           : setScale(0.7)
    star           : setPosition(cc.p(15,18))
    myRankLab      : addChild(star)
    self.rankBG    : addChild(myRankLab)
end

function ArenaView.__createRankLabel( self,i,_msg,_flag,_size)
    _flag = _flag or 0

    local rankLab = ccui.Widget : create()
    rankLab       : setContentSize( self.oneHeight )
    -- rankLab       : setAnchorPoint( cc.p(0.0,0.5) )
    rankLab       : setPosition(cc.p(0, _size.height-self.oneHeight-(i-1)*(self.oneHeight)))

    local fontSize  = 20

    local color     = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_WHITE)
    if i == 1 then
        color  = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED)
    elseif i == 2 then
        color  = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW)
    elseif i == 3 then
        color  = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BLUE)
    end

    if _flag==1 then
        color = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_WHITE)
    end

    local rank      = _G.Util : createLabel(tostring(_msg[i].rank), fontSize)
    rank            : setColor(color)
    -- rank            : setDimensions(15,self.oneHeight/2)
    -- rank            : setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- rank            : setAnchorPoint( cc.p(0.0,0.5) )
    rank            : setPosition(cc.p(55,self.oneHeight/2))
    rankLab         : addChild(rank)

    local name      = _G.Util : createLabel(_msg[i].name, fontSize)
    name            : setColor(color)
    -- name            : setDimensions(160,self.oneHeight/2)
    -- name            : setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- name            : setAnchorPoint( cc.p(0.0,0.5) )
    name            : setPosition(cc.p(250,self.oneHeight/2))
    rankLab         : addChild(name)

    -- local lv        = _G.Util : createLabel(tostring(_msg[i].lv), fontSize)
    -- lv              : setColor(color)
    -- -- lv              : setDimensions(10,self.oneHeight/2)
    -- -- lv              : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    -- -- lv              : setAnchorPoint( cc.p(0.0,0.5) )
    -- lv              : setPosition(cc.p(320,self.oneHeight/2))
    -- rankLab         : addChild(lv)

    local power     = _G.Util : createLabel(tostring(_msg[i].powerful), fontSize)
    power           : setColor(color)
    -- power           : setDimensions(110,self.oneHeight/2)
    -- power           : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    -- power           : setAnchorPoint( cc.p(0.0,0.5) )
    power           : setPosition(cc.p(445,self.oneHeight/2))
    rankLab         : addChild(power)

    print("_msg[i].count",_msg[i].count)
    local goodsdata=_msg[i].goods_data
    print("goodsdata.goods_id",goodsdata,goodsdata[1].goods_count)
    local m_gold =goodsdata[1].goods_count

    local money     = _G.Util : createLabel(tostring(m_gold), fontSize)
    money           : setColor(color)
    -- money           : setDimensions(110,self.oneHeight/2)
    -- money           : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    -- money           : setAnchorPoint( cc.p(0.0,0.5) )
    money           : setPosition(cc.p(645,self.oneHeight/2))
    rankLab         : addChild(money)

    if self.value~=nil then
        local beishuLab=_G.Util:createLabel(string.format("x%d",self.value),fontSize)
        beishuLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
        -- beishuLab:setAnchorPoint(cc.p(0,0))
        beishuLab:setPosition(658+money:getContentSize().width/2,self.oneHeight/2)
        rankLab:addChild(beishuLab)
    end

    local lineBg    = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    local lineHeight = lineBg : getPreferredSize().height
    if _flag==1 then lineHeight=3 end
    lineBg          : setPreferredSize( cc.size(_size.width, lineHeight) )
    lineBg          : setAnchorPoint( cc.p(0.0,0.0) )
    lineBg          : setPosition(cc.p(0, -2))
    rankLab         : addChild(lineBg)

    return rankLab
end

--初始化战报UI
function ArenaView.__initCombatLayer( self )
    print("初始化战报UI")

    local combatView  = require("mod.general.BattleMsgView")()
    self.combatBG = combatView : create()

    self.m_mainSize = combatView : getSize()
    self : __combatNetWorkSend()
end

function ArenaView.__combatNetWorkSend( self )
    print("发送战报协议")
    local msg  = REQ_LINGYAO_ARENA_REPORT()
    _G.Network : send(msg)
end

function ArenaView.updateCombatMsg( self ,_msg)
    print("战报信息已经收到",_msg.count)
    if _msg.count < 1 then
        print(_msg.count)
        self.monkeySpr = cc.Sprite:createWithSpriteFrameName("general_monkey.png")
        self.monkeySpr : setPosition(self.m_mainSize.width/2,self.m_mainSize.height/2+30)
        self.combatBG : addChild(self.monkeySpr)

        local monkeySize=self.monkeySpr:getContentSize()
        self.nomsgLab = _G.Util : createLabel("暂无战报", 20)
        -- self.nomsgLab : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
        self.nomsgLab : setPosition(monkeySize.width/2,-10)
        self.monkeySpr : addChild(self.nomsgLab)  
        return
    end
    if self.monkeySpr~=nil then
        self.monkeySpr:removeFromParent(true)
        self.monkeySpr=nil

        self.nomsgLab:removeFromParent(true)
        self.nomsgLab=nil
    end
    self._combatMsgSize = cc.size(self.m_mainSize.width,(self.m_mainSize.height+4)/6)
    self                : __combatScrollView(_msg)
end

function ArenaView.__combatScrollView( self ,_msg)
    print("初始化滚动框")

    local Sc_Container = cc.Node : create()
    local ScrollView  = cc.ScrollView : create()
    local count        = 6
    if _msg.count > 6 then
        count = _msg.count
    end
    
    local viewSize  = cc.size(self._combatMsgSize.width,self._combatMsgSize.height*6.0)
    
    local m_size    = cc.size(self._combatMsgSize.width, self._combatMsgSize.height*count)
    
    ScrollView      : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView      : setViewSize(viewSize)
    ScrollView      : setContentSize(m_size)
    ScrollView      : setContentOffset( cc.p( 0, viewSize.height-m_size.height))
    ScrollView      : setPosition(cc.p(5, -23))
    print("容器大小：", m_size.width,self._combatMsgSize.height*count)
    ScrollView      : setBounceable(true)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    
    Sc_Container    : addChild(ScrollView)
    Sc_Container    : setPosition(cc.p(0,27))
    self.combatBG   : addChild(Sc_Container)

    local barView = require("mod.general.ScrollBar")(ScrollView)
    barView       : setPosOff(cc.p(5,0))
    -- barView       : setMoveHeightOff(-5)

    for i=1,_msg.count do
        print("t",_msg.report_data[i].rank,"  ","b",_msg.report_data[i].rank2,"  ","r",_msg.report_data[i].result)
        local combatLab =  self : __createCombatLabel(i,_msg.report_data[i],m_size)
        ScrollView      : addChild(combatLab)
    end 
end

function ArenaView.__createCombatLabel( self,i,_msg,_size )
    local combatLab = ccui.Widget : create()
    combatLab       : setContentSize( self._combatMsgSize )
    combatLab       : setAnchorPoint( cc.p(0.0,0.5) )
    combatLab       : setPosition(cc.p(0, _size.height - (i-1)*self._combatMsgSize.height - self._combatMsgSize.height/2))

    local fontSize  = 20
    local offset    = 12

    local time      = _G.Util : createLabel(self : __combatTime(_msg.time), fontSize)
    -- time            : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
    time            : setAnchorPoint( cc.p(0.0,0.5) )
    time            : setPosition(cc.p(offset,self._combatMsgSize.height/2))
    combatLab       : addChild(time)
    offset          = offset + time : getContentSize().width

    local myPersonUid = _G.GPropertyProxy : getMainPlay() : getUid()

    if myPersonUid == _msg.uid2 then
        print("我是被挑战者")
        local t_nameLab = _G.Util : createLabel(_msg.name, fontSize)
        t_nameLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
        t_nameLab       : setAnchorPoint( cc.p(0.0,0.5) )
        t_nameLab       : setPosition(cc.p(offset,self._combatMsgSize.height/2))
        combatLab       : addChild(t_nameLab)
        offset          = offset + t_nameLab : getContentSize().width

        local b_nameLab = _G.Util : createLabel("挑战您", fontSize)
        -- b_nameLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
        b_nameLab       : setAnchorPoint( cc.p(0.0,0.5) )
        b_nameLab       : setPosition(cc.p(offset,self._combatMsgSize.height/2))
        combatLab       : addChild(b_nameLab)
        offset          = offset + b_nameLab : getContentSize().width
    else
        print("我是挑战者")
        local b_nameLab = _G.Util : createLabel("您挑战", fontSize)
        -- b_nameLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
        b_nameLab       : setAnchorPoint( cc.p(0.0,0.5) )
        b_nameLab       : setPosition(cc.p(offset,self._combatMsgSize.height/2))
        combatLab       : addChild(b_nameLab)
        offset          = offset + b_nameLab : getContentSize().width

        local t_nameLab = _G.Util : createLabel(_msg.name2, fontSize)
        t_nameLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
        t_nameLab       : setAnchorPoint( cc.p(0.0,0.5) )
        t_nameLab       : setPosition(cc.p(offset,self._combatMsgSize.height/2))
        combatLab       : addChild(t_nameLab)
        offset          = offset + t_nameLab : getContentSize().width
    end

    local lab = _G.Util : createLabel(",您", fontSize)
    -- lab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
    lab       : setAnchorPoint( cc.p(0.0,0.5) )
    lab       : setPosition(cc.p(offset,self._combatMsgSize.height/2))
    combatLab : addChild(lab)
    offset    = offset + lab : getContentSize().width

    local resultLab = 0

    if     (_msg.result == 1) and (myPersonUid == _msg.uid2) then
        resultLab = _G.Util : createLabel("完败", fontSize)
        resultLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    elseif (_msg.result == 1) and (myPersonUid == _msg.uid) then
        resultLab = _G.Util : createLabel("完胜", fontSize)
        resultLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
    elseif (_msg.result == 2) and (myPersonUid == _msg.uid2) then
        resultLab = _G.Util : createLabel("失败", fontSize)
        resultLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
    elseif (_msg.result == 2) and (myPersonUid == _msg.uid) then
        resultLab = _G.Util : createLabel("胜利", fontSize)
        resultLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    elseif (_msg.result == 4) and (myPersonUid == _msg.uid2) then
        resultLab = _G.Util : createLabel("胜利", fontSize)
        resultLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
    elseif (_msg.result == 4) and (myPersonUid == _msg.uid) then
        resultLab = _G.Util : createLabel("失败", fontSize)
        resultLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    elseif (_msg.result == 5) and (myPersonUid == _msg.uid2) then
        resultLab = _G.Util : createLabel("完胜", fontSize)
        resultLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
    elseif (_msg.result == 5) and (myPersonUid == _msg.uid) then
        resultLab = _G.Util : createLabel("完败", fontSize)
        resultLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    else
        print("result  ",_msg.result)
        resultLab = _G.Util : createLabel("平局", fontSize)
        resultLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BLUE))
    end

    
    resultLab       : setAnchorPoint( cc.p(0.0,0.5) )
    resultLab       : setPosition(cc.p(offset,self._combatMsgSize.height/2))
    combatLab       : addChild(resultLab)
    offset          = offset + resultLab : getContentSize().width

    local rankLab = 0

    if (myPersonUid == _msg.uid) and (_msg.result == 1 or _msg.result == 2) then
        if _msg.rank < _msg.rank2 then
            rankLab = _G.Util : createLabel("了,排名不变", fontSize)
        else
            rankLab = _G.Util : createLabel("了,排名上升至", fontSize)
        end
    elseif (myPersonUid == _msg.uid) and (_msg.result == 3 or _msg.result == 4 or _msg.result == 5) then
        rankLab   = _G.Util : createLabel("了,排名不变", fontSize)
    elseif (myPersonUid == _msg.uid2) and (_msg.result == 1 or _msg.result == 2) then
        if _msg.rank < _msg.rank2 then
            rankLab = _G.Util : createLabel("了,排名不变", fontSize)
        else
            rankLab = _G.Util : createLabel("了,排名下降至", fontSize)
        end
    elseif (myPersonUid == _msg.uid2) and (_msg.result == 3 or _msg.result == 4 or _msg.result == 5) then
        rankLab   = _G.Util : createLabel("了,排名不变", fontSize)
    end

    -- rankLab         : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
    rankLab         : setAnchorPoint( cc.p(0.0,0.5) )
    rankLab         : setPosition(cc.p(offset,self._combatMsgSize.height/2))
    combatLab       : addChild(rankLab)

    offset          = offset + rankLab : getContentSize().width
    if     (myPersonUid == _msg.uid) and (_msg.result == 1 or _msg.result == 2) then
        if _msg.rank >= _msg.rank2 then
            numberLab = _G.Util : createLabel(tostring(_msg.rank2), fontSize)
            numberLab       : setAnchorPoint( cc.p(0.0,0.5) )
            numberLab       : setPosition(cc.p(offset,self._combatMsgSize.height/2))
            numberLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
            combatLab       : addChild(numberLab)
        end
    elseif (myPersonUid == _msg.uid2) and (_msg.result == 1 or _msg.result == 2) then
        if _msg.rank >= _msg.rank2 then
            rankLab = _G.Util : createLabel(tostring(_msg.rank), fontSize)
            rankLab       : setAnchorPoint( cc.p(0.0,0.5) )
            rankLab       : setPosition(cc.p(offset,self._combatMsgSize.height/2))
            rankLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
            combatLab       : addChild(rankLab)
        end
    end

    local lineBg    = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    local lineSprSize = lineBg : getPreferredSize()
    lineBg          : setPreferredSize( cc.size(_size.width, lineSprSize.height) )
    lineBg          : setAnchorPoint( cc.p(0.0,0.0) )
    lineBg          : setPosition(cc.p(0, 0))
    combatLab       : addChild(lineBg)

    return  combatLab
end

function ArenaView.__combatTime( self,times)
    local nowTime     = _G.TimeUtil:getNowSeconds()
    local offlineTime = nowTime - times
    print(offlineTime)

    local times_str   = os.date("*t", times)
    local nowTime_str = os.date("*t", nowTime)
    print(times_str.day)
    print(nowTime_str.day)
    local temptime = ""
    if math.floor( offlineTime/(86400*30) ) > 0 then --一个月前
        temptime = "[1个月前]"
    elseif math.floor( offlineTime/86400 ) > 0 then  --超过一天
        temptime = "["..math.floor( offlineTime/86400 ).._G.Lang.LAB_N[92].."]"
    else
        if times_str ~= nil and nowTime_str ~= nil then
           if tostring(times_str.day) ~= tostring(nowTime_str.day) then
               temptime  = "[昨天]"
           else
               local min = string.format("%.2d", times_str.min)
               temptime  = "["..times_str.hour ..":".. min.."]"
           end
        else
           temptime = "error"
        end
    end
    return temptime
end

function ArenaView.__buyNetWorkSend( self )
    print("发送购买次数协议")
    local msg  = REQ_LINGYAO_ARENA_BUY()
    msg:setArgs(0)
    _G.Network : send(msg)
end

function ArenaView.updateBuyMsg( self,_times )
    print("接收购买次数协议成功",_times)
    self : __initBuyLayer(_times+1)
end

function ArenaView.__initBuyLayer( self,count )
    print("初始化竞技场购买界面")

    local function buy()
        print("购买挑战次数")
        local msg  = REQ_LINGYAO_ARENA_BUY()
        msg:setArgs(1)
        _G.Network : send(msg)
    end

    local function cancel( ... )
        print("取消")
        self.isClickPerson = false
    end

    local topLab    = "花费"..tostring(count*_G.Const.CONST_ARENA_BUY_RMB).."元宝购买1次挑战次数?"
    local centerLab = _G.Lang.LAB_N[940]
    local downLab   = _G.Lang.LAB_N[416]..": "
    local buyCount  = _G.Const.CONST_ARENA_BUY_MAX_TIMES - count+1
    local rightLab  = _G.Lang.LAB_N[106]

    local szSureBtn = _G.Lang.BTN_N[1]

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",buy,cancel)
    -- layer       : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

    local layer=view:getMainlayer()
    view:setTitleLabel("购买次数")
    if topLab ~= nil then
        local label =_G.Util : createLabel(topLab,20)
        label       : setPosition(cc.p(0,60))
        layer       : addChild(label,88)
    end
    if centerLab ~= nil then
        local label =_G.Util : createLabel(centerLab,18)
        label       : setPosition(cc.p(0,30))
        layer       : addChild(label,88)
    end
    if downLab ~= nil then
        local label =_G.Util : createLabel(downLab,20)
        label       : setPosition(cc.p(-7,-5))
        layer       : addChild(label,88)

        local count = _G.Util : createLabel(tostring(buyCount),20)
        count       : setAnchorPoint(cc.p(0,0.5))
        count       : setPosition(cc.p(-7+label:getContentSize().width/2,-5))
        layer       : addChild(count,88)

        if buyCount>0 then
            count : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
        else
            count : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_RED))
        end
    end
    if rightLab then
        local label =_G.Util : createLabel(rightLab,20)
        label       : setPosition(cc.p(25,-50))
        layer       : addChild(label,88)
    end
    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("勾选了不再提示",isBuyTip)
            if isBuyTip then
                isBuyTip = false
                _G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_LYJJ,false)
            else
                isBuyTip = true
                _G.GSystemProxy:setNeverNotic(_G.Const.CONST_FUNC_OPEN_LYJJ,true)
            end
        end
    end

    local checkbox   = ccui.CheckBox : create()
    checkbox         : loadTextures("general_gold_floor.png","general_gold_floor.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox         : setPosition(cc.p(-80,-51))
    checkbox         : setName("sdjfgksjdfklgj")
    checkbox         : addTouchEventListener(c)
    -- checkbox         : setAnchorPoint(cc.p(1,0.5))
    layer            : addChild(checkbox)
end

return ArenaView