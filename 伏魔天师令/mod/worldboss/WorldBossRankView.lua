local WorldBossRankView = classGc(view, function(self)

end)

local fontSize = 20

function WorldBossRankView.initRankView( self,_name,_msg,_type,_value )
    self.value=_value
	local function onTouchBegan(touch,event)
        return true
    end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)
    cc.Director:getInstance():getRunningScene():addChild(self.m_rootLayer,1001)

    local m_winSize=cc.Director:getInstance():getWinSize()
    local bgSize=cc.size(875,516)
    local tipsSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
    tipsSpr       : setPreferredSize(bgSize)
    tipsSpr       : setPosition(m_winSize.width/2,m_winSize.height/2-20)
    self.m_rootLayer : addChild(tipsSpr)

    local function nCloseFun()
        self.m_rootLayer:removeFromParent(false)
        self.m_rootLayer=nil
        if _type == 1 then
            print("请求退出场景")
            local msg = REQ_SCENE_ENTER_CITY()
            _G.Network:send(msg)
        end
    end

    local Btn_Close = gc.CButton : create("general_close.png")
    Btn_Close   : setPosition( cc.p( bgSize.width-23, bgSize.height-24) )
    Btn_Close   : addTouchEventListener( nCloseFun )
    tipsSpr : addChild( Btn_Close , 8 )

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(bgSize.width/2-135, bgSize.height-28)
    tipsSpr : addChild(tipslogoSpr)

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(bgSize.width/2+130, bgSize.height-28)
    tipslogoSpr : setRotation(180)
    tipsSpr : addChild(tipslogoSpr)

    local m_titleLab=_G.Util:createBorderLabel("排名奖励",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    m_titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    m_titleLab:setPosition(bgSize.width/2,bgSize.height-26)
    tipsSpr:addChild(m_titleLab)

    local di2kuanbg = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    di2kuanbg       : setPreferredSize(cc.size(856,460))
    di2kuanbg       : setPosition(cc.p(bgSize.width/2,bgSize.height/2-18))
    tipsSpr       : addChild(di2kuanbg)

    local rank_Lab1= _G.Util : createLabel("排名", fontSize-2)
    -- rank_Lab1 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab1 : setPosition(cc.p(60,445)) 
    tipsSpr : addChild(rank_Lab1)

    local rank_Lab2= _G.Util : createLabel("玩家名称", fontSize-2)
    -- rank_Lab2 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab2 : setPosition(cc.p(200,445)) 
    tipsSpr : addChild(rank_Lab2)

    local rank_Lab3= _G.Util : createLabel("等级", fontSize-2)
    -- rank_Lab3 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab3 : setPosition(cc.p(340,445)) 
    tipsSpr : addChild(rank_Lab3)

    local rank_Lab4= _G.Util : createLabel("战斗力", fontSize-2)
    -- rank_Lab4 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab4 : setPosition(cc.p(470,445)) 
    tipsSpr : addChild(rank_Lab4)

    local rank_Lab5= _G.Util : createLabel("伤害", fontSize-2)
    -- rank_Lab5 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab5 : setPosition(cc.p(610,445)) 
    tipsSpr : addChild(rank_Lab5)

    local rank_Lab6= _G.Util : createLabel("奖励贡献", fontSize-2)
    -- rank_Lab6 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab6 : setPosition(cc.p(760,445)) 
    tipsSpr : addChild(rank_Lab6)

    self._rankMsgSize = cc.size(bgSize.width,34)

    local lineBg    = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    lineBg          : setPreferredSize( cc.size(self._rankMsgSize.width-20, 2) )
    lineBg          : setAnchorPoint( cc.p(0.0,1) )
    lineBg          : setPosition(cc.p(10,425))
    tipsSpr                 : addChild(lineBg)

    local rankNum = 0
    local flag    = true
    for i=1,#_msg do
        if _msg[i].last_kill==0 then
            rankNum=_msg[i].rank
        elseif _msg[i].last_kill==1 then
            bossWin=2
            rankNum = 12
        elseif _msg[i].last_kill==2 then
            rankNum = 11
            flag = false
        end
        tipsSpr:addChild(self : __createRankLabel(rankNum,_msg[i]))
    end

    if flag then
        local myProperty = _G.GPropertyProxy:getMainPlay()
        local msg = 
        {
            rank     = 0,
            name     = myProperty:getName(),
            lv       = myProperty:getLv(),
            powerful = myProperty:getPowerful(),
            harm     = 0,
            gold     = 0,
            goods_id = 0,
        }
        tipsSpr:addChild(self:__createRankLabel(11,msg))
    end
end

function WorldBossRankView.__createRankLabel( self,i,_msg )
    print(i)
    local rankLab = ccui.Widget : create()
    rankLab       : setContentSize( self._rankMsgSize )
    rankLab       : setAnchorPoint( cc.p(0.0,0.5) )
    rankLab       : setPosition(cc.p(0, 405-(i-1)*(self._rankMsgSize.height)))

    local fontSize  = 20

    if i==11 then
        local star     = cc.Sprite : createWithSpriteFrameName("general_star.png")
        star           : setScale(0.7)
        star           : setPosition(cc.p(35,star:getContentSize().height/2+3))
        rankLab        : addChild(star)
    end

    local color     = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_WHITE)
    if i == 1 then
        color  = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED)
    elseif i == 2 then
        color  = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW)
    elseif i == 3 then
        color  = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BLUE)
    end

    local rank      = _G.Util : createLabel(tostring(_msg.rank), fontSize)
    rank            : setColor(color)
    if i==12 then
        rank        : setString("击杀")
        rank        : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    end
    if _msg.rank==0 then
        rank        : setString("无")
    end
    rank            : setDimensions(50,self._rankMsgSize.height-16)
    rank            : setPosition(cc.p(80,self._rankMsgSize.height/2))
    rankLab         : addChild(rank)

    local name      = _G.Util : createLabel(_msg.name, fontSize)
    name            : setColor(color)
    name            : setPosition(cc.p(200,self._rankMsgSize.height/2))
    rankLab         : addChild(name)

    local lv        = _G.Util : createLabel(tostring(_msg.lv), fontSize)
    lv              : setColor(color)
    lv              : setPosition(cc.p(340,self._rankMsgSize.height/2))
    rankLab         : addChild(lv)

    local power     = _G.Util : createLabel(tostring(_msg.powerful), fontSize)
    power           : setColor(color)
    power           : setPosition(cc.p(470,self._rankMsgSize.height/2))
    rankLab         : addChild(power)

    local harm  = _G.Util : createLabel(tostring(_msg.harm), fontSize)
    harm            : setColor(color)
    harm            : setPosition(cc.p(610,self._rankMsgSize.height/2))
    rankLab         : addChild(harm)

    local award=tostring(_msg.num)
    local money     = _G.Util : createLabel(award, fontSize)
    money           : setColor(color)
    money           : setPosition(cc.p(760,self._rankMsgSize.height/2))
    rankLab         : addChild(money)

    if self.value~=nil then
        local beishuLab=_G.Util:createLabel(string.format("x%d",self.value),fontSize)
        beishuLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
        beishuLab:setPosition(625+money:getContentSize().width/2,self._rankMsgSize.height/2)
        rankLab:addChild(beishuLab)
    end

    if i==11 or i==12 then
        local lineBg    = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
        lineBg          : setPreferredSize( cc.size(self._rankMsgSize.width-20,2) )
        lineBg          : setAnchorPoint( cc.p(0.0,1) )
        lineBg          : setPosition(cc.p(10, self._rankMsgSize.height))
        rankLab         : addChild(lineBg)
    else
        local line  = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
        local lineSprSize = line : getPreferredSize()
        line            : setPreferredSize( cc.size(self._rankMsgSize.width-20, lineSprSize.height) )
        line            : setAnchorPoint( cc.p(0.0,1) )
        line            : setPosition(cc.p(10,2))
        rankLab         : addChild(line)
    end
 
    return rankLab
end

return WorldBossRankView