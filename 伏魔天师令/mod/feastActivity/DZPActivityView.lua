local DZPActivityView = classGc(view, function(self)

end)

local goldcount= _G.Const.CONST_HOLIDAY_TABLE_COST
local m_winSize  = cc.Director : getInstance() : getVisibleSize()
local rightSize= cc.size(580,456)
local iconSize = cc.size(79,79)
local fontSize=20
local REWARD = 1
local ONELOT = 2
local TENLOT = 3
local stopId = 1
local isBuyTip = false
local isBuyTru = false

function DZPActivityView.create( self, _id,time )
    print("转盘界面")
	self.m_container = cc.Node:create() 

    local longBgSpr = cc.Sprite : create( "ui/bg/feast_bg.jpg" ) 
    longBgSpr : setPosition(rightSize.width/2,rightSize.height/2-25)
    -- longBgSpr : setScale(2.7)
    self.m_container : addChild(longBgSpr)

    self.AcId = _id
    local endTime= self:getTimeStr(time.end_time) or "2016/5/20 21:00"
    local startTime=self:getTimeStr(time.start_time) or "2016/5/20 21:00"

    local timeStrLab=_G.Util:createLabel("活动时间:",fontSize)
    -- timeStrLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    timeStrLab:setPosition(0,rightSize.height-15)
    timeStrLab:setAnchorPoint(0,0.5)
    self.m_container:addChild(timeStrLab)

    local LabWidth=timeStrLab:getContentSize().width
    local timeLab=_G.Util:createLabel(string.format("%s-%s",startTime,endTime),fontSize)
    timeLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    timeLab:setPosition(LabWidth,rightSize.height-15)
    timeLab:setAnchorPoint(0,0.5)
    self.m_container:addChild(timeLab)

	self.turntableSpr = cc.Node:create()
    self.turntableSpr : setPosition(96,35)
    self.m_container:addChild(self.turntableSpr)

    local msg = REQ_GALATURN_GALATURN()
    msg:setArgs(_id,0)
    _G.Network :send(msg) 

    self : RewardLeft()
	return self.m_container
end

function DZPActivityView.RewardLeft( self )
    print("按钮")
	-- self.rankRewardLab = _G.Util:createLabel("我的排名:无",fontSize)
    -- self.rankRewardLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    -- self.rankRewardLab : setPosition(rightSize.width-155,rightSize.height-50)
    -- self.rankRewardLab : setAnchorPoint(cc.p(0,0.5))
    -- self.m_container : addChild(self.rankRewardLab) 

    -- self.mypointLab = _G.Util:createLabel("我的积分:0",fontSize)
    -- self.mypointLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    -- self.mypointLab : setPosition(rightSize.width-155,rightSize.height-80)
    -- self.mypointLab : setAnchorPoint(cc.p(0,0.5))
    -- self.m_container : addChild(self.mypointLab) 

    self.checkbox={}
    local function onBtnCallback(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
    	   self : onBtnReturnCallBack(sender,eventType)
        end
    end
    
    self.rankRewardBtn = gc.CButton:create("feast_rank_btn.png")
    -- self.rankRewardBtn:setTitleText("排名奖励")
    -- self.rankRewardBtn:setTitleFontName(_G.FontName.Heiti)
    -- self.rankRewardBtn:setTitleFontSize(fontSize+4)
    self.rankRewardBtn:setPosition(rightSize.width-30,rightSize.height-42)
    self.rankRewardBtn:addTouchEventListener(onBtnCallback)
    --self.rankRewardBtn:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    self.rankRewardBtn:setTag(REWARD)
    self.m_container  :addChild(self.rankRewardBtn)

    self.lotteryOneBtn=gc.CButton:create("general_btn_gold.png")
    self.lotteryOneBtn:setTitleText("抽奖1次")
    self.lotteryOneBtn:setTitleFontName(_G.FontName.Heiti)
    self.lotteryOneBtn:setTitleFontSize(fontSize+4)
    self.lotteryOneBtn:setPosition(rightSize.width/2-82,-16)
    self.lotteryOneBtn:addTouchEventListener(onBtnCallback)
    self.lotteryOneBtn:setTag(ONELOT)
    self.m_container :addChild(self.lotteryOneBtn)
    
    self.lotteryTenBtn = gc.CButton:create("general_btn_gold.png")
    self.lotteryTenBtn:setTitleText("抽奖10次")
    self.lotteryTenBtn:setTitleFontName(_G.FontName.Heiti)
    self.lotteryTenBtn:setTitleFontSize(fontSize+4)
    self.lotteryTenBtn:setPosition(rightSize.width/2+82,-16)
    self.lotteryTenBtn:addTouchEventListener(onBtnCallback)
    self.lotteryTenBtn:setTag(TENLOT)
    self.m_container :addChild(self.lotteryTenBtn)
    
    self.lotteryOneLab = _G.Util:createLabel(goldcount.."元宝",fontSize)
    -- self.lotteryOneLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.lotteryOneLab : setPosition(rightSize.width/2-82,22)
    self.m_container : addChild(self.lotteryOneLab) 

    self.lotteryTenLab = _G.Util:createLabel((goldcount*10).."元宝",fontSize)
    -- self.lotteryTenLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.lotteryTenLab : setPosition(rightSize.width/2+82,22)
    self.m_container : addChild(self.lotteryTenLab) 
end

function DZPActivityView.createGoodsCell( self,_msg )
    if self.icondata~=nil then return end
    print("createGoodsCell",self.AcId)
	-- local goodsList = _G.Cfg.gala_turn
    self.icondata = _msg

    local function sort(m1,m2)
        if m1.idx < m2.idx then
            -- print("paixu",m1.idx,m2.idx)
            return true
        end
        return false
    end
    table.sort( _msg, sort )

	local function cFun(sender,eventType)
		self:cellBtnCallback(sender,eventType)
	end

    local kSize = self.turntableSpr:getContentSize()
    local posX={62,148,234,320,320,320,320,234,148,62,62,62,193}
    local posY={323,323,323,323,237,150,65,65,65,65,150,237,195}
	local cellList = {1,2,3,4,5,6,7,8,9,10,11,12,13}

	for i=1,13 do
		cellList[i] = cc.Sprite:createWithSpriteFrameName( "general_tubiaokuan.png" )
		cellList[i] : setPosition(posX[i],posY[i])
		self.turntableSpr : addChild(cellList[i])

		if _msg~=nil and _msg[i]~=nil then
            -- print("请求物品图片",_msg, _msg[i].items_id,_msg[i].idx)
            local goodId    = _msg[i].items_id
            local goodCount = _msg[i].value
            local goodsdata = _G.Cfg.goods[goodId]
            local iconSize = cellList[i]:getContentSize()
            if goodsdata ~= nil then
                local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,cFun,goodId,goodCount)
                iconSpr : setPosition(iconSize.width/2, iconSize.height/2)
                iconSpr : setSwallowTouches(false)
                cellList[i] : addChild(iconSpr)
            end
        end 
	end

    self.m_ceilPosXArray=posX
    self.m_ceilPosYArray=posY

    self.m_headEffect = cc.Sprite : createWithSpriteFrameName("feast_select.png")
    self.m_headEffect : setVisible(false)
    self.turntableSpr : addChild(self.m_headEffect,100)
end

function DZPActivityView.cellBtnCallback(self,sender,eventType)
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
        if role_tag <= 0 then return end
        local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
        cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
    end
end

function DZPActivityView.getDZPdata( self,_data )
    if _data.selfrank==0 then _data.selfrank="无" end 
    -- self.rankRewardLab:setString(string.format("我的排名:%s",_data.selfrank))
    -- self.mypointLab:setString(string.format("我的积分:%s",_data.point))
    self.rank=_data.selfrank
    self.point=_data.point
    if _data.times>0 then
        self.lotteryOneLab:setString("本次免费")
    end
    self.Nums = _data.times

    self:createGoodsCell(_data.msg)
end

function DZPActivityView.DZPReward(self,id_sub,type,id)
    print("DZPReward",type,id_sub,id)
    local msg = REQ_GALATURN_GALATURN()
    msg:setArgs(id,1)
    _G.Network:send(msg)
    if type==1 then
        self.Nums = self.Nums-1
        print("self.Nums",self.Nums)
        if self.Nums>0 then
            self.lotteryOneLab:setString("本次免费")
        else
            self.lotteryOneLab:setString(goldcount.."元宝")
        end
        -- _G.Util:playAudioEffect("ui_gem")
        self:runRewardAction(id_sub)
    elseif type==10 then
        self:TenActionTips()
        self:TipsIconSpr(id_sub)
    end
end

function DZPActivityView.resetRewardEffectPos(self,_idx)
    _G.Util:playAudioEffect("Dong")
    self.m_headEffect:setPosition(self.m_ceilPosXArray[_idx],self.m_ceilPosYArray[_idx])
end

function DZPActivityView.runRewardAction(self,_idx)
    print("runRewardAction--->>>",_idx)
    if self.m_rewardScheduler~=nil then return end
    local curIdx=stopId
    local turnTimes=1
    local jiangeTimes=0.3
    local curTims=0

    cc.Director:getInstance():getEventDispatcher():setEnabled(false)

    local function onFram(_dTimes)
        if jiangeTimes>0 then
            curTims=curTims+_dTimes
            if curTims<jiangeTimes then
                return
            end
            curTims=0
        end
        print("turnTimes-->",turnTimes,jiangeTimes)
        if turnTimes<3 and jiangeTimes>0 then
            jiangeTimes=jiangeTimes-0.05
            jiangeTimes=jiangeTimes>0 and jiangeTimes or 0
        elseif turnTimes>=3 then
            jiangeTimes=jiangeTimes+0.02
        end
        if turnTimes>3 then
            if curIdx==_idx then
                self:removeRewardScheduler()
                local goodId = self.icondata[_idx].items_id
                local goodsdata = _G.Cfg.goods[goodId]
                local command=CErrorBoxCommand({t={ {t=[[获得：]],c=_G.Const.CONST_COLOR_GREEN},
                                        {t=goodsdata.name,c=_G.Const.CONST_COLOR_GREEN},
                                        {t=[[*]],c=_G.Const.CONST_COLOR_GREEN},
                                        {t=self.icondata[_idx].value,c=_G.Const.CONST_COLOR_GREEN},
                                       }
                                    })
                _G.controller:sendCommand(command)
                self.lotteryOneBtn:setTouchEnabled(true)
                stopId=_idx
                self:__showSysIconMove(_idx)
                _G.Util:playAudioEffect("balance_reward")
                return
            end
        end

        if curIdx==13 then
            curIdx=1
            turnTimes=turnTimes+1
        else
            curIdx=curIdx+1
        end
        self:resetRewardEffectPos(curIdx)
    end
    self.m_headEffect:setVisible(true)
    self:resetRewardEffectPos(curIdx)
    self.m_rewardScheduler=_G.Scheduler:schedule(onFram,0)
end

function DZPActivityView.__showSysIconMove(self,_idx)
    print("__showSysIconMove=====>>>>")
    local openEffect=cc.ParticleSystemQuad:create("particle/sys_open_bomb2.plist")
    openEffect:setPosition(self.m_ceilPosXArray[_idx]-2,self.m_ceilPosYArray[_idx])
    self.turntableSpr:addChild(openEffect)
end

function DZPActivityView.removeRewardScheduler(self)
    print("removeRewardScheduler-->1")
    if self.m_rewardScheduler~=nil then
        _G.Scheduler:unschedule(self.m_rewardScheduler)
        self.m_rewardScheduler=nil
    end
    cc.Director:getInstance():getEventDispatcher():setEnabled(true)
end

function DZPActivityView.TenActionTips( self )
    if self.m_tenLayer~=nil and self.iii==1 then
        print("在界面内点")
        for k,v in pairs(self.iconSpr) do
            print(k,v)
            v:removeFromParent(true)
            v=nil
        end
        return
    end
    if self.m_tenLayer~=nil then return end
    local kuangSize=cc.size(566,390)
    local function onTouchBegan(touch,event) 
        return true
    end

    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_tenLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_tenLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_tenLayer)
    cc.Director:getInstance():getRunningScene():addChild(self.m_tenLayer,1000)

    local tentipSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
    tentipSpr : setPreferredSize(kuangSize)
    tentipSpr : setPosition(m_winSize.width/2,m_winSize.height/2)
    self.m_tenLayer:addChild(tentipSpr)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(kuangSize.width/2-135,kuangSize.height-28)
    tentipSpr:addChild(titleSpr,9)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(kuangSize.width/2+130,kuangSize.height-28)
    titleSpr:setRotation(180)
    tentipSpr:addChild(titleSpr,9)

    local logoLab= _G.Util : createLabel("抽奖获得", fontSize,_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
    logoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    logoLab : setPosition(kuangSize.width/2, kuangSize.height-28)
    tentipSpr  : addChild(logoLab)

    local framlineSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
    framlineSpr : setPreferredSize(cc.size(546,270))
    framlineSpr : setPosition(kuangSize.width/2,kuangSize.height/2+15)
    tentipSpr : addChild(framlineSpr)

    local tipsLab = _G.Util:createLabel("恭喜，本次抽奖获得以下物品",fontSize)
    tipsLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    tipsLab:setPosition(kuangSize.width/2,kuangSize.height-70)
    tentipSpr:addChild(tipsLab,1)

    local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
    lineSpr:setPreferredSize(cc.size(kuangSize.width-50,2))
    lineSpr:setPosition(kuangSize.width/2,kuangSize.height-90)
    tentipSpr:addChild(lineSpr,1)

    local function onSure(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            if self.m_tenLayer~=nil then
                self.m_tenLayer:removeFromParent(true)
                self.m_tenLayer=nil
            end
        end
    end
    local sureBtn=gc.CButton:create("general_btn_gold.png")
    sureBtn:setTitleText("确 认")
    sureBtn:setTitleFontName(_G.FontName.Heiti)
    sureBtn:setTitleFontSize(fontSize+2)
    sureBtn:setPosition(kuangSize.width/2-100,40)
    sureBtn:addTouchEventListener(onSure)
    -- sureBtn:setButtonScale(0.85)
    tentipSpr:addChild(sureBtn)

    local function onBtnCallback(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local function actionCallFunc1()
                sender : setTouchEnabled(false)
            end
            local function actionCallFunc2()
                sender : setTouchEnabled(true)
            end
            local delay=cc.DelayTime:create(0.5)
            local func1=cc.CallFunc:create(actionCallFunc1)
            local func2=cc.CallFunc:create(actionCallFunc2)
            sender:runAction(cc.Sequence:create(func1,delay,func2))
            self : onBtnReturnCallBack(sender,eventType)
        end
    end
    local TuHaoBtn=gc.CButton:create("general_btn_lv.png")
    TuHaoBtn:setTitleText("再抽10次")
    TuHaoBtn:setTitleFontName(_G.FontName.Heiti)
    TuHaoBtn:setTitleFontSize(fontSize+2)
    TuHaoBtn:setPosition(kuangSize.width/2+100,40)
    TuHaoBtn:addTouchEventListener(onBtnCallback)
    -- TuHaoBtn:setButtonScale(0.85)
    TuHaoBtn:setTag(TENLOT)
    --TuHaoBtn:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    tentipSpr:addChild(TuHaoBtn)

    self.tenbiao = {}
    self.iconSpr={}
    for i=1,10 do
        self.tenbiao[i] = ccui.Scale9Sprite:createWithSpriteFrameName( "general_tubiaokuan.png" )
        if i<6 then
            self.tenbiao[i] : setPosition(73+(i-1)*105,kuangSize.height/2+50)
        else
            self.tenbiao[i] : setPosition(73+(i-6)*105,135)
        end
        tentipSpr : addChild(self.tenbiao[i])
    end
    
    -- self:TipsIconSpr(id_sub)
end

function DZPActivityView.TipsIconSpr( self, id_sub )
    local function cFun(sender,eventType)
        self:cellBtnCallback(sender,eventType)
    end
    
    if self.icondata~=nil and self.icondata[id_sub]~=nil then
        -- print("请求物品图片",self.icondata, self.icondata[id_sub].items_id)
        local goodId    = self.icondata[id_sub].items_id
        local goodCount = self.icondata[id_sub].value
        local goodsdata = _G.Cfg.goods[goodId]
        if goodsdata ~= nil then
            self.iconSpr[self.iii] = _G.ImageAsyncManager:createGoodsBtn(goodsdata,cFun,goodId,goodCount)
            self.iconSpr[self.iii] : setPosition(iconSize.width/2, iconSize.height/2)
            self.tenbiao[self.iii] : addChild(self.iconSpr[self.iii])
        end
    end
    self.iii = self.iii+1
    -- self.lotteryTenBtn:setTouchEnabled(true)
end

function DZPActivityView.DZPRank(self,rankdata)
    print("DZPRank-->>",rankdata.count2,rankdata.rank_good)
    self : rankScrollView(rankdata.rank_good)
    if rankdata.rank_msg==nil then return end
    
    self.rank = rankdata.selfrank or "无"
    if rankdata.selfrank==0 then rankdata.selfrank="无" end
    self.inviteLab:setString(rankdata.selfrank) 
    for k,v in pairs(rankdata.rank_msg) do
        print("DZPRank",k,v.name,rankdata.selfrank)
        local roleName = v.name or "位置暂缺"
        local playpoint= v.point or 0
        self.playNoLab[k] : setString(string.format("%s(积分:%d)",roleName,playpoint))

        print("self.m_point[k]",self.m_point[k],playpoint)
        if playpoint>=self.m_point[k] then
            self.pointLab[k] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
        else
            self.pointLab[k] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
        end
    end
end

function DZPActivityView.RankingView( self )
    local frameSize=cc.size(732,500)
    local combatView  = require("mod.general.BattleMsgView")()
    self.tipSpr = combatView : create("排行奖励",frameSize)

    local inviteStrLab = _G.Util:createLabel("我的排行: ",fontSize)
    -- inviteStrLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    inviteStrLab:setPosition(20,frameSize.height-80)
    inviteStrLab:setAnchorPoint( cc.p(0.0,0.5) )
    self.tipSpr:addChild(inviteStrLab,10)

    local LabWidth=inviteStrLab:getContentSize().width
    self.inviteLab = _G.Util:createLabel(self.rank,fontSize)
    self.inviteLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.inviteLab:setPosition(20+LabWidth,frameSize.height-80)
    self.inviteLab:setAnchorPoint( cc.p(0.0,0.5) )
    self.tipSpr:addChild(self.inviteLab,10)

    local myjfStrLab = _G.Util:createLabel("我的积分: ",fontSize)
    -- myjfStrLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    myjfStrLab:setPosition(200,frameSize.height-80)
    myjfStrLab:setAnchorPoint( cc.p(0.0,0.5) )
    self.tipSpr:addChild(myjfStrLab,10)

    print("self.point-->>",self.point)
    local LabWidth=myjfStrLab:getContentSize().width
    self.jifenLab = _G.Util:createLabel(self.point,fontSize)
    self.jifenLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.jifenLab:setPosition(200+LabWidth,frameSize.height-80)
    self.jifenLab:setAnchorPoint( cc.p(0.0,0.5) )
    self.tipSpr:addChild(self.jifenLab,10)

    local tipsLab = _G.Util:createLabel("活动结束后通过邮件发放",fontSize)
    tipsLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    tipsLab:setPosition(frameSize.width-160,frameSize.height-80)
    self.tipSpr:addChild(tipsLab,10)

    self.doubleSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    self.doubleSpr:setPreferredSize(cc.size(frameSize.width-20,frameSize.height-100))
    self.doubleSpr:setPosition(frameSize.width/2-9,frameSize.height/2-48)
    self.tipSpr:addChild(self.doubleSpr)
end

function DZPActivityView.rankScrollView(self,rankgood)
    -- if self.m_ScrollView~=nil then
    --     self.m_ScrollView:removeFromParent(true)
    --     self.m_ScrollView=nil
    -- end
    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView = ScrollView

    self.countSize = self.doubleSpr:getContentSize()
    local zongzhi = 10

    print("zuidazhi",zongzhi)
    self.oneHeight = (self.countSize.height-6)/3
    local viewSize = cc.size(self.countSize.width, self.oneHeight*3)
    local containerSize = cc.size(self.countSize.width, self.oneHeight*zongzhi)

    ScrollView : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView : setViewSize(viewSize)
    ScrollView : setContentSize(containerSize)
    ScrollView : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    ScrollView : setPosition(cc.p(0, 3))
    print("容器大小：",self.oneHeight*zongzhi)
    ScrollView : setBounceable(false)
    ScrollView : setTouchEnabled(true)
    ScrollView : setDelegate()
    self.doubleSpr : addChild(ScrollView)
    
    local barView=require("mod.general.ScrollBar")(ScrollView)
    barView:setPosOff(cc.p(-7,0))
    -- barView:setMoveHeightOff(-7)

    self.playNoLab={}
    self.pointLab={}
    self.m_point={}
    for i=1,zongzhi do
        local OneReward = self : Widgetreturn(i,rankgood)
        OneReward : setPosition(cc.p(self.countSize.width/2,containerSize.height-self.oneHeight/2-1-(i-1)*self.oneHeight))
        ScrollView : addChild(OneReward)
    end
end
 
function DZPActivityView.Widgetreturn(self,i,rankgood)
    if rankgood~=nil then
        local function sort(m1,m2)
            if m1.id_sub < m2.id_sub then
                -- print("paixu",m1.id_sub,m2.id_sub)
                return true
            end
            return false
        end
        table.sort( rankgood, sort )
    end

    local Widget = ccui.Scale9Sprite : createWithSpriteFrameName("general_noit.png")
    Widget : setContentSize(cc.size(self.countSize.width-14,self.oneHeight-5))

    local Num = 1
    -- local iconCfg = _G.Cfg.gala_rank[self.AcId]
    local icondata = rankgood[i]
    local icongoods= icondata.msg
    local exNum  = 1
    local exdata = nil

    local NoOneLab = _G.Util : createLabel(string.format("第%d名:",icondata.id_sub), fontSize)
    -- NoOneLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
    NoOneLab : setPosition(28, self.oneHeight-25)
    NoOneLab : setAnchorPoint(cc.p(0.0,0.5))
    Widget : addChild(NoOneLab)

    local LabWidth=NoOneLab:getContentSize().width
    self.playNoLab[i] = _G.Util : createLabel("位置暂缺", fontSize)
    self.playNoLab[i] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    self.playNoLab[i] : setPosition(28+LabWidth, self.oneHeight-25)
    self.playNoLab[i] : setAnchorPoint(cc.p(0.0,0.5))
    Widget : addChild(self.playNoLab[i])

    local roleBg = {1,2,3}
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
            print("－－－－Position.y",Position.y,m_winSize.height/2+self.countSize.height/2-70)
            if Position.y > m_winSize.height/2+self.countSize.height/2-70 or
               Position.y < m_winSize.height/2-self.countSize.height/2-25 
               or role_tag <= 0 then return end
            local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
        end 
    end

    for j=1, 3 do
        roleBg[j] = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
        roleBg[j] : setPosition(cc.p(self.countSize.width*0.12+(j-1)*(iconSize.width+20), self.oneHeight/2-15))
        Widget : addChild(roleBg[j])

        if icongoods~=nil and icongoods[j] ~= nil then
            -- print("请求物品图片", icongoods[j].good_id)
            local goodId      = icongoods[j].good_id
            local goodCount   = icongoods[j].count
            local goodsdata   = _G.Cfg.goods[goodId]
            if goodsdata ~= nil then
                local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,roleCallBack,goodId,goodCount)
                iconSpr       : setPosition(iconSize.width/2, iconSize.height/2)
                iconSpr       : setSwallowTouches(false)
                roleBg[j]     : addChild(iconSpr)
            end
        end   
    end

    local Point = icondata.point or 0
    local addupLab = _G.Util : createLabel(string.format("(%d积分可获得)",Point), fontSize-2)
    addupLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    addupLab : setPosition(self.countSize.width*0.78, self.oneHeight-25)
    Widget : addChild(addupLab)
    self.m_point[i]=Point
    self.pointLab[i]=addupLab

    local goodsBg = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
    goodsBg : setPosition(cc.p(self.countSize.width*0.78, self.oneHeight/2-15))
    Widget  : addChild(goodsBg)

    if icondata.ex_goodid ~=nil and icondata.ex_count~=nil then  
        local goodId      = icondata.ex_goodid
        local goodCount   = icondata.ex_count
        local goodsdata   = _G.Cfg.goods[goodId]
        if goodsdata ~= nil then
            local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,roleCallBack,goodId,goodCount)
            iconSpr       : setPosition(iconSize.width/2, iconSize.height/2)
            iconSpr       : setSwallowTouches(false)
            goodsBg : addChild(iconSpr)
        end
    end

    return Widget
end

function DZPActivityView.BuyCountCallBack( self,_tag )
    print("BuyCountCallBack",_tag)
    local function buy()
        if _tag==ONELOT then
            local msg = REQ_GALATURN_LOTTERY()
            msg:setArgs(1, self.AcId)
            _G.Network:send(msg)
        else
            local msg = REQ_GALATURN_LOTTERY()
            msg:setArgs(2, self.AcId)
            _G.Network:send(msg)
        end
    end

    local topLab = nil
    if _tag==ONELOT then
        topLab    = "花费"..goldcount.."元宝抽奖1次吗?"
    else
        topLab    = "花费"..(goldcount*10).."元宝抽奖10次吗?"
    end
    local centerLab = _G.Lang.LAB_N[940]
    local rightLab  = _G.Lang.LAB_N[106]
    local szSureBtn = _G.Lang.BTN_N[1]

    print("aaaazzz==>",topLab,centerLab,rightLab,szSureBtn)
    local view  = require("mod.general.TipsBox")()
    local tipsNode = view : create("",buy,cancel)
    -- tipsNode     : setPosition(cc.p(m_winSize.width/2,m_winSize.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(tipsNode,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

    local layer=view:getMainlayer()
    view:setTitleLabel("提示")
    if topLab ~= nil then
        local label =_G.Util : createLabel(topLab,20)
        label     : setPosition(cc.p(0,50))
        layer     : addChild(label,88)
    end
    if centerLab ~= nil then
        local label =_G.Util : createLabel(centerLab,20)
        label     : setPosition(cc.p(0,20))
        layer     : addChild(label,88)
    end
    if rightLab then
        local label =_G.Util : createLabel(rightLab,20)
        label     : setPosition(cc.p(25,-42))
        layer     : addChild(label,88)
    end
    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("勾选了不再提示",isBuyTip,isBuyTru)
            if _tag==ONELOT then
                if isBuyTip then
                    isBuyTip = false
                else
                    isBuyTip = true
                end
            else
                if isBuyTru then
                    isBuyTru = false
                else
                    isBuyTru = true
                end
            end
        end
    end

    local checkbox = ccui.CheckBox : create()
    checkbox : loadTextures("general_gold_floor.png","general_gold_floor.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox : setPosition(cc.p(-80,-42))
    checkbox : setName("sdjfgksjdfklgj")
    checkbox : addTouchEventListener(c)
    -- checkbox : setAnchorPoint(cc.p(1,0.5))
    layer    : addChild(checkbox)
end

function DZPActivityView.onBtnReturnCallBack(self, sender,eventType )
    local btnTag = sender:getTag()
    print("dddddddd",btnTag)
    if btnTag==REWARD then
        print("弹出排行奖励面板",self.tipSpr)
        local msg = REQ_GALATURN_RANK()
        msg:setArgs(self.AcId)
        _G.Network:send(msg)
        self:RankingView()
    elseif btnTag==ONELOT then
        print("抽奖一次")
        -- self.lotteryOneBtn:setTouchEnabled(false)
        if isBuyTip or self.Nums>0 then
            print("直接购买＝＝＝＝＝＝＝＝＝＝不弹出提示框")
            local msg = REQ_GALATURN_LOTTERY()
            msg:setArgs(1, self.AcId)
            _G.Network:send(msg)
        else
            self : BuyCountCallBack(ONELOT)
        end

    elseif btnTag==TENLOT then
        print("抽奖十次")
        self.iii = 1
        if isBuyTru then
            print("直接购买＝＝＝＝＝＝＝＝＝＝不弹出提示框")
            local msg = REQ_GALATURN_LOTTERY()
            msg:setArgs(2, self.AcId)
            _G.Network:send(msg)
        else
            self : BuyCountCallBack(TENLOT)
        end
    end
end

function DZPActivityView.getTimeStr( self, _time)
    local time = os.date("*t",_time)

    if time.month < 10 then time.month = "0"..time.month end
    if time.day < 10 then time.day = "0"..time.day end
    if time.hour < 10 then time.hour = "0"..time.hour
    elseif time.hour < 0 then time.hour = "00" end
    if time.min < 10 then time.min = "0"..time.min
    elseif time.min < 0 then time.min = "00" end

    local time  = time.year.."/"..time.month.."/"..time.day.." "..time.hour..":"..time.min

    return time
end

return DZPActivityView