local FHZPRebateView = classGc(view, function(self)
    self.isBuyTip = false
    self.isBuyTru = false
    self : __init()
end)

local goldcount= _G.Const.CONST_HOLIDAY_TABLE_COST
local m_winSize  = cc.Director : getInstance() : getVisibleSize()
local rightSize= cc.size(622,517)
local iconSize = cc.size(78,78)
local fontSize=20
local ONELOT = 1
local TENLOT = 2

function FHZPRebateView.__init(self)
    self : register()
end

function FHZPRebateView.register(self)
    self.pMediator = require("mod.rebate.FHZPRebateMediator")(self)
end
function FHZPRebateView.unregister(self)
    if self.pMediator then
        self.pMediator : destroy()
        self.pMediator = nil 
    end
end

function FHZPRebateView.create( self, tag,_data )
    print("转盘界面")
	self.m_container = cc.Node:create() 

    local doubleSpr = ccui.Widget:create()
    doubleSpr : setContentSize(cc.size(rightSize.width-4,-190))
    doubleSpr : setPosition(rightSize.width/2,rightSize.height/2)
    self.m_container:addChild(doubleSpr)

    self.AcId = tag

    local endtime= self:getTimeStr(_data.endtime) or ""
    local startime = self:getTimeStr(_data.start) or ""

    local timeStrLab=_G.Util:createLabel("活动时间：",fontSize)
    -- timeStrLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
    timeStrLab:setPosition(35, 50)
    self.m_container:addChild(timeStrLab)

    local timeLab=_G.Util:createLabel(string.format("%s~%s",startime,endtime),fontSize)
    timeLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    timeLab:setPosition(90, 50)
    timeLab:setAnchorPoint(0,0.5)
    self.m_container:addChild(timeLab)

    local tipsLab=_G.Util:createLabel("在精彩活动可获得道具",fontSize)
    tipsLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    tipsLab:setPosition(92, 16)
    self.m_container:addChild(tipsLab)

    self.nameLab=_G.Util:createLabel("",fontSize)
    -- self.nameLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
    self.nameLab:setPosition(rightSize.width/2-100,-410)
    self.nameLab:setAnchorPoint(0,0.5)
    self.m_container:addChild(self.nameLab)

    self.numLab=_G.Util:createLabel("0",fontSize)
    self.numLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.numLab:setAnchorPoint(0,0.5)
    self.m_container:addChild(self.numLab)

	self.turntableSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" ) 
    self.turntableSpr : setContentSize(cc.size(rightSize.width,300))
    self.turntableSpr : setPosition(rightSize.width/2-21,-158)
    self.m_container:addChild(self.turntableSpr)

    local function onBtnCallback(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           self : onBtnReturnCallBack(sender,eventType)
        end
    end

    self.lotteryBtn=gc.CButton:create("general_btn_gold.png")
    self.lotteryBtn:setTitleText("寻 宝")
    self.lotteryBtn:setTitleFontName(_G.FontName.Heiti)
    self.lotteryBtn:setTitleFontSize(fontSize+2)
    self.lotteryBtn:setPosition(rightSize.width/2-120,-360)
    self.lotteryBtn:addTouchEventListener(onBtnCallback)
    self.lotteryBtn:setTag(ONELOT)
    self.m_container :addChild(self.lotteryBtn)

    local TuHaoBtn=gc.CButton:create("general_btn_gold.png")
    TuHaoBtn:setTitleText("寻宝十次")
    TuHaoBtn:setTitleFontName(_G.FontName.Heiti)
    TuHaoBtn:setTitleFontSize(fontSize+2)
    TuHaoBtn:setPosition(rightSize.width/2+100,-360)
    TuHaoBtn:addTouchEventListener(onBtnCallback)
    TuHaoBtn:setTag(TENLOT)
    --TuHaoBtn:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    self.m_container:addChild(TuHaoBtn)

    local msg = REQ_ART_ZHUANPAN()
    msg:setArgs(self.AcId)
    _G.Network :send(msg) 
	return self.m_container
end

function FHZPRebateView.updateData( self,_msg )
    if self.AcId == _msg.id then
    	self.msg = _msg.msg
        self.m_useGoodsId=_msg.use_id
        self.m_useGoodsCount=_msg.use_count
		self:createGoodsCell()
    end	
end

function FHZPRebateView.createGoodsCell( self )
    print("createGoodsCell",self.AcId,#self.msg)
	--local goodsList = _G.Cfg.zhuanpan
    --self.icondata = goodsList[self.AcId]
    self.icondata = self.msg
	local function cFun(sender,eventType)
		self:cellBtnCallback(sender,eventType)
	end

    local kSize = self.turntableSpr:getContentSize()
    local posX=60
    local posY=212
	local cellList = {1,2,3,4,5,6,7,8,9,10}
    self.m_ceilPosXArray={}
    self.m_ceilPosYArray={}
    -- self.m_headEffect={}
    -- self.m_rewardScheduler  self.stopId={}
	for i=1,10 do
        if i%6==0 then
            posX=60
            posY=85
        end
		cellList[i] = cc.Sprite:createWithSpriteFrameName( "general_tubiaokuan.png" )
		cellList[i] : setPosition(posX,posY)
		self.turntableSpr : addChild(cellList[i])

		if self.icondata~=nil and self.icondata[i]~=nil then
            print("请求物品图片",self.icondata, self.icondata[i].items_id)
            local goodId    = self.icondata[i].items_id
            local goodCount = self.icondata[i].value
            local goodsdata = _G.Cfg.goods[goodId]
            local iconSize = cellList[i]:getContentSize()
            if goodsdata ~= nil then
                local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,cFun,goodId,goodCount)
                iconSpr     : setSwallowTouches(false)
                iconSpr     : setPosition(iconSize.width/2, iconSize.height/2)
                cellList[i] : addChild(iconSpr)

                -- local countLab= _G.Util : createLabel(goodCount, fontSize)
                -- countLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
                -- countLab : setPosition(73/2, -23)
                -- iconSpr  : addChild(countLab)
            end
        end
        self.stopId = 1
        self.m_ceilPosXArray[i]=posX+2
        self.m_ceilPosYArray[i]=posY
        posX=posX+125

        self.m_headEffect = cc.Sprite : createWithSpriteFrameName("rebate_select.png")
        self.m_headEffect : setVisible(false)
        self.turntableSpr : addChild(self.m_headEffect,100)
	end    

    print("namedata",self.m_useGoodsId)
    local namedata=_G.Cfg.goods[self.m_useGoodsId]
    self.goodname=namedata.name
    if namedata ~= nil then
        self.nameLab: setString(string.format("每次消耗%s：",namedata.name))
    end
    local LabWidth=self.nameLab:getContentSize().width
    self.numLab : setPosition(rightSize.width/2-95+LabWidth,-410)
    self : updateMoneyTab()
end

function FHZPRebateView.cellBtnCallback(self,sender,eventType)
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

function FHZPRebateView.resetRewardEffectPos(self,_idx,_num)
    print("显示",_idx,_num)
    _G.Util:playAudioEffect("Dong")
    self.m_headEffect:setPosition(self.m_ceilPosXArray[_idx]-2,self.m_ceilPosYArray[_idx])
end

function FHZPRebateView.runRewardAction(self,_idx,_num)
    -- if _type==nil then
    --     for i=1,10 do
    --         self.m_headEffect[i]:setVisible(false)
    --     end
    -- end
    print("runRewardAction--->>>",_idx,_num)
    self:updateMoneyTab()
    if self.m_rewardScheduler~=nil then return end
    local curIdx=self.stopId
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
        if turnTimes>3 then
            if curIdx==_idx then
                self:removeRewardScheduler(_num)
                local goodId = self.icondata[_idx].items_id
                local goodsdata = _G.Cfg.goods[goodId]
                if _type==nil then
                    local command=CErrorBoxCommand({t={ {t=[[获得：]],c=_G.Const.CONST_COLOR_GREEN},
                                            {t=goodsdata.name,c=_G.Const.CONST_COLOR_GREEN},
                                            {t=[[*]],c=_G.Const.CONST_COLOR_GREEN},
                                            {t=self.icondata[_idx].value,c=_G.Const.CONST_COLOR_GREEN},
                                           }
                                        })
                    _G.controller:sendCommand(command)
                end
                self.lotteryBtn:setTouchEnabled(true)
                self.stopId=_idx
                self:__showSysIconMove(_idx)
                _G.Util:playAudioEffect("balance_reward")
                return
            end
        end
        if turnTimes<3 and jiangeTimes>0 then
            jiangeTimes=jiangeTimes-0.05
            jiangeTimes=jiangeTimes>0 and jiangeTimes or 0
        elseif turnTimes>=3 then
            jiangeTimes=jiangeTimes+0.02
        end

        if curIdx==10 then
            curIdx=1
            turnTimes=turnTimes+1
        else
            curIdx=curIdx+1
        end
        self:resetRewardEffectPos(curIdx,_num)
    end

    print("self",self.m_headEffect,self.m_rewardScheduler)
    self.m_headEffect:setVisible(true)
    self:resetRewardEffectPos(curIdx,_num)
    self.m_rewardScheduler=_G.Scheduler:schedule(onFram,0)
end

function FHZPRebateView.__showSysIconMove(self,_idx)
    print("__showSysIconMove=====>>>>")
    local openEffect=cc.ParticleSystemQuad:create("particle/sys_open_bomb2.plist")
    openEffect:setPosition(self.m_ceilPosXArray[_idx]-2,self.m_ceilPosYArray[_idx])
    self.turntableSpr:addChild(openEffect)
end

function FHZPRebateView.removeRewardScheduler(self, _num)
    print("removeRewardScheduler-->1")
    if self.m_rewardScheduler~=nil then
        _G.Scheduler:unschedule(self.m_rewardScheduler)
        self.m_rewardScheduler=nil
    end
    cc.Director:getInstance():getEventDispatcher():setEnabled(true)
end

function FHZPRebateView.FHZPTenData(self,_idx,_num)
    self:TenActionTips()
    self:TipsIconSpr(_idx)
    self:updateMoneyTab()
end

function FHZPRebateView.TenActionTips( self,_idx )
    if self.m_tenLayer~=nil then return end
    if self.m_tenLayer~=nil and self.iii==1 then
        print("在界面内点")
        for k,v in pairs(self.iconSpr) do
            print(k,v)
            v:removeFromParent(true)
            v=nil
        end
        return
    end
    
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

    local logoLab= _G.Util : createBorderLabel("寻宝获得", fontSize,_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
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
end

function FHZPRebateView.TipsIconSpr( self, _idx )
    print("TipsIconSpr",_idx)
    local function cFun(sender,eventType)
        self:cellBtnCallback(sender,eventType)
    end
    
    if self.icondata~=nil and self.icondata[_idx]~=nil then
        -- print("请求物品图片",self.icondata, self.icondata[_idx].items_id)
        local goodId    = self.icondata[_idx].items_id
        local goodCount = self.icondata[_idx].value
        local goodsdata = _G.Cfg.goods[goodId]
        if goodsdata ~= nil then
            self.iconSpr[self.iii] = _G.ImageAsyncManager:createGoodsBtn(goodsdata,cFun,goodId,goodCount)
            self.iconSpr[self.iii] : setPosition(iconSize.width/2, iconSize.height/2)
            self.tenbiao[self.iii] : addChild(self.iconSpr[self.iii])
        end
    end
    self.iii = self.iii+1
end

function FHZPRebateView.onBtnReturnCallBack(self, sender,eventType )
    local m_tag = sender:getTag() 
    if m_tag==ONELOT then
        print("抽奖一次")
        if self.nums<1 then
            local command = CErrorBoxCommand(string.format("%s不足，精彩活动可获得！",self.goodname))
            controller : sendCommand( command )
            return
        end
        local msg = REQ_ART_ZHUANPAN_LOTTERY_UNLIMIT()
        msg:setArgs(self.AcId)
        _G.Network:send(msg)
    else
        print("抽奖10次")
        if self.nums<10 then
            local command = CErrorBoxCommand(string.format("%s不足，精彩活动可获得！",self.goodname))
            controller : sendCommand( command )
            return
        end
        self.iii = 1
        local msg = REQ_ART_ZHUANPAN_LOTTERY_TEN()
        msg:setArgs(self.AcId)
        _G.Network:send(msg)
    end
end

function FHZPRebateView.updateMoneyTab( self )
    self.nums = _G.GBagProxy:getGoodsCountById(self.m_useGoodsId)
    print("updateMoneyTab",self.nums)
    if self.nums<1 then 
        self.numLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    end
    self.numLab : setString(string.format("%d/%d",self.nums,self.m_useGoodsCount))
end

function FHZPRebateView.getTimeStr( self, _time)
    local time = os.date("*t",_time)

    if time.month < 10 then time.month = "0"..time.month end
    if time.day < 10 then time.day = "0"..time.day end
    if time.hour < 10 then time.hour = "0"..time.hour
    elseif time.hour < 0 then time.hour = "00" end
    if time.min < 10 then time.min = "0"..time.min
    elseif time.min < 0 then time.min = "00" end

    local time  = time.year.."/"..time.month.."/"..time.day.." "..time.hour..":"..time.min
    print("dasdasdasd",time)

    return time
end

function FHZPRebateView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return FHZPRebateView