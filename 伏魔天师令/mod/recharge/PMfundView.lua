local PMfundView = classGc(view, function(self, _panelType)
    self.pMediator = require("mod.recharge.PMfundMediator")()
    self.pMediator : setView(self)
	self.m_panelType = _panelType
    self.lvPrivilege = 1 
end)
-- local TYPE     = self.m_panelType
local leftTag  = 1
local rightTag = 2
local FONTSIZE = 20
local rightbgSize = cc.size(580, 425)
local sprsize  = cc.size(580, 345)

function PMfundView.create(self)
    print("平民基金")
	self.m_container = cc.Node:create()

    local pritdata = _G.Cfg.privilege_type[self.m_panelType]
    local logoImg = "ui/bg/recharge_img3.jpg"
    local rmbnum= 123
    if self.m_panelType==2 then
        logoImg = "ui/bg/recharge_img3.jpg"
        rmbnum= pritdata.b_rmb
    else
        logoImg = "ui/bg/recharge_img4.jpg"
        rmbnum= pritdata.b_rmb
    end
    local logoSpr = _G.ImageAsyncManager:createNormalSpr(logoImg)
    logoSpr : setPosition(rightbgSize.width/2,rightbgSize.height-21)
    self.m_container  : addChild(logoSpr) 

    print("rmbnum--->",rmbnum)
    local spriteWidth   = 105
    local length        = string.len( rmbnum)
    for i=1, length do
        local _tempSpr = cc.Sprite:createWithSpriteFrameName( "advert_"..string.sub(rmbnum,i,i)..".png")
        self.m_container : addChild( _tempSpr )

        local _tempSprSize = _tempSpr : getContentSize()
        spriteWidth        = spriteWidth + _tempSprSize.width / 2+10
        _tempSpr           : setPosition( spriteWidth,rightbgSize.height-48)
    end

    self.tabTittleSpr = ccui.Widget:create()
    self.tabTittleSpr : setPosition(cc.p(rightbgSize.width/2, rightbgSize.height/2-38))
    self.tabTittleSpr : setContentSize(sprsize)
    self.m_container  : addChild(self.tabTittleSpr)

--  初始化
    self : networksend()
    return self.m_container
end

function PMfundView.networksend( self )
    local msg = REQ_PRIVILEGE_REQUEST()
    msg : setArgs( self.m_panelType )
    _G.Network : send( msg)
    print("请求协议")
end

function PMfundView.msgData( self , _data)
    if _data.type ~= self.m_panelType then return end
    print("[msgData]-->",_data.seconds,_data.type,_data.is,_data.bool,_data.acc)

    -- local time = os.date("*t",_data.seconds)
    -- print("time",_data.seconds)
    -- local endtime  = time.year.."-"..time.month.."-"..time.day
    -- print("endtime",endtime)
    -- local fundLab   = {1,2}
    -- local funinfo   = {"平民基金，居家旅行必备!", "活动截止时间："..endtime}
    -- local funPoX    = {15, sprsize.width/2+30}

    -- for i = 1, 2 do
    --     fundLab[i]  = _G.Util : createLabel(funinfo[i], FONTSIZE)
    --     fundLab[i]  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    --     fundLab[i]  : setPosition(funPoX[i], rightbgSize.height-70)
    --     fundLab[i]  : setAnchorPoint( cc.p(0.0,0.5) )
    --     self.tabTittleSpr : addChild(fundLab[i])
    -- end

    self : Scroll(_data)
end

function PMfundView.Scroll(self, _data)
    print("_data.acc",_data.acc)
    -- local count     = 10
    local pritdata = _G.Cfg.privilege_type[self.m_panelType]

    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView = ScrollView

    self.oneHeight = sprsize.height/4
    local viewSize    = sprsize
    local containerSize= cc.size(sprsize.width, self.oneHeight*(pritdata.day+1))

    ScrollView : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView : setViewSize(viewSize)
    ScrollView : setContentSize(containerSize)
    ScrollView : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    ScrollView : setPosition(cc.p(0, 5))
    ScrollView : setBounceable(false)
    ScrollView : setTouchEnabled(true)
    ScrollView : setDelegate()
    
    local BuyTitle = self:PMFundTitle(_data)
    BuyTitle : setPosition(sprsize.width/2,containerSize.height-self.oneHeight/2)
    ScrollView : addChild(BuyTitle)

    self.widArray = {}
    for i=1, pritdata.day do
        local pritdata = _G.Cfg.privilege[self.m_panelType][i]
        print("表数据",pritdata.day,pritdata.gold,pritdata.rmb)
        local m_onefund = self : Onefund(pritdata.day,pritdata.gold,pritdata.rmb,_data.bool,_data.acc)
        m_onefund : setPosition(sprsize.width/2,containerSize.height-self.oneHeight/2-self.oneHeight*i)
        ScrollView : addChild(m_onefund)
    end 
    
    self.tabTittleSpr : addChild(ScrollView)

    local barView=require("mod.general.ScrollBar")(ScrollView)
    barView:setPosOff(cc.p(-4,0))
end

function PMfundView.PMFundTitle(self, _data)
    print("PMFundTitle",_data.is)
    self.oneHeight = sprsize.height/4
    local explainSize = cc.size(sprsize.width-14, self.oneHeight-3)
    local explainSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double2.png" ) 
    -- explainSpr : setPosition(cc.p(sprsize.width/2, sprsize.height-self.oneHeight/2+1))
    explainSpr : setPreferredSize( explainSize)
    -- self.tabTittleSpr : addChild(explainSpr)

    local PMData = _G.Cfg.privilege_type[self.m_panelType]
    local palinLab  = {1,2,3}
    local plaininfo = {"总共可领取", PMData.g_rmb, PMData.g_gold}
    local plainPoX  = {15, 192, explainSize.width/2+30}
    for i = 1, 3 do
        palinLab[i] = _G.Util : createLabel(plaininfo[i], FONTSIZE)
        palinLab[i] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
        palinLab[i] : setPosition(plainPoX[i], explainSize.height/2)
        palinLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
        explainSpr : addChild(palinLab[i])
    end
    palinLab[1] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_WHITE))

    local goldSpr = cc.Sprite : createWithSpriteFrameName("general_xianYu.png")
    goldSpr : setPosition(175, explainSize.height/2+3)
    explainSpr : addChild(goldSpr)

    local moneySpr = cc.Sprite : createWithSpriteFrameName("general_tongqian.png")
    moneySpr : setPosition(explainSize.width/2+15, explainSize.height/2+3)
    explainSpr : addChild(moneySpr)

    print("_data.is——data.bool==>",_data.is,_data.bool)
    local function onButtonCallBack(sender, eventType)
        self : onBtnCallBack(sender, eventType)
    end
    self.PMbuyBtn = gc.CButton : create("general_btn_gold.png")
    self.PMbuyBtn : setTag(1)
    self.PMbuyBtn : setPosition(sprsize.width-85, self.oneHeight/2)
    self.PMbuyBtn : addTouchEventListener(onButtonCallBack)
    local BtnStr = "购 买"
    if _data.is ~= 0 then
        print("已开通")
        self.PMbuyBtn : setBright(false)
        self.PMbuyBtn : setEnabled(false)
        BtnStr = "已购买"
    end
    self.PMbuyBtn : setTitleText(BtnStr)
    self.PMbuyBtn : setTitleFontName(_G.FontName.Heiti)
    self.PMbuyBtn : setTitleFontSize(FONTSIZE+4)
    --self.PMbuyBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    explainSpr : addChild(self.PMbuyBtn)

    return explainSpr
end

function PMfundView.Onefund(self,_day,_gold,_rmb,_bool,_acc)
    print("传入数据", _day,_gold,_rmb)
    local oneSize=cc.size(sprsize.width-10,self.oneHeight-3)
    local oneWid = ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
    oneWid : setContentSize(oneSize)

    local jadeSpr = cc.Sprite : createWithSpriteFrameName("general_xianYu.png")
    jadeSpr : setPosition(175, self.oneHeight/2+3)
    oneWid : addChild(jadeSpr)

    local qianSpr = cc.Sprite : createWithSpriteFrameName("general_tongqian.png")
    qianSpr : setPosition(oneSize.width/2+15, self.oneHeight/2+3)
    oneWid : addChild(qianSpr)

    local days = 1
    local daysLab  = {1,2,3,4,5}

    local daysStr  = {"第".._day.."天",_rmb,_gold}
    local daysPosX = {70,192,oneSize.width/2+30}
    for i=1,3 do
        daysLab[i] = _G.Util:createLabel( daysStr[i], FONTSIZE)
        daysLab[i] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))  
        daysLab[i] : setPosition(daysPosX[i], self.oneHeight/2)
        daysLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
        oneWid : addChild(daysLab[i])
    end
    daysLab[1] : setAnchorPoint( cc.p(0.5,0.5) )
    daysLab[1] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_WHITE))

    local function onButtonCallBack(sender, eventType)
        self : onBtnCallBack(sender, eventType)
    end
    local alreadyBtn = gc.CButton : create("general_btn_gold.png")
    alreadyBtn : setTitleText("领 取")
    alreadyBtn : setTitleFontName(_G.FontName.Heiti)
    alreadyBtn : setTitleFontSize(FONTSIZE+4)
    alreadyBtn : setTag(2)
    --alreadyBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    alreadyBtn : setPosition(oneSize.width-75, oneSize.height/2)
    alreadyBtn : addTouchEventListener(onButtonCallBack)
    alreadyBtn : setBright(false)
    alreadyBtn : setEnabled(false)
    oneWid : addChild(alreadyBtn)

    self.widArray[_day] = {}
    self.widArray[_day].Btn = alreadyBtn

    local haveSpr = cc.Sprite : createWithSpriteFrameName("main_already.png")
    haveSpr : setPosition(oneSize.width-75, self.oneHeight/2)
    haveSpr : setVisible(false)
    oneWid : addChild(haveSpr)

    self.widArray[_day].Spr = haveSpr

    print("dsadasdasda-------...",_bool,_day,_acc)
    if _bool == 1 then
        if _day < _acc then
            alreadyBtn:setVisible(false)
            haveSpr:setVisible(true)
        elseif _day== _acc then
            alreadyBtn : setBright(true)
            alreadyBtn : setEnabled(true)
        end
    elseif  _bool==0 then
        if _day <= _acc then
            alreadyBtn:setVisible(false)
            haveSpr:setVisible(true)
        end
    end

    return oneWid
end

function PMfundView.onBtnCallBack(self, sender, eventType)
	if eventType == ccui.TouchEventType.ended then
        local btntag = sender : getTag() 
		print("获取玩家钻石数，足够弹出确认购买框，不够弹出前往充值框",btntag)
        if btntag == 1 then
    		local msg = REQ_PRIVILEGE_OPEN()
            msg :setArgs(self.m_panelType)
            _G.Network : send(msg)
        elseif btntag == 2 then
            local msg = REQ_PRIVILEGE_GET_REWARDS()
            msg :setArgs(self.m_panelType)
            _G.Network : send(msg)
        end
	end
end

function PMfundView.SUCC(self,_data)
    print("[SUCC]-->",_data.type)
    if _data.type ~= self.m_panelType then return end
    self.PMbuyBtn : setTitleText("已购买")
    self.PMbuyBtn : setBright(false)
    self.PMbuyBtn : setEnabled(false)

    self.widArray[1].Btn:setEnabled(true)
    self.widArray[1].Btn:setBright(true)
end

function PMfundView.ReturnRewards(self,_data)
    print("[ReturnRewards]-->",_data.type,_data.day)
    if _data.type ~= self.m_panelType then return end
    self.widArray[_data.day].Btn : setVisible(false)
    self.widArray[_data.day].Spr : setVisible(true)
    _G.Util:playAudioEffect("ui_receive_awards")
end

function PMfundView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return PMfundView