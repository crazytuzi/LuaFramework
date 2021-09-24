local NFZPRebateView = classGc(view, function(self)
    self.isBuyTip = false
    self.isBuyTru = false
    self : __init()
end)

local goldcount= _G.Const.CONST_HOLIDAY_TABLE_COST
local m_winSize  = cc.Director : getInstance() : getVisibleSize()
local rightSize= cc.size(622,517)
local iconSize = cc.size(78,78)
local fontSize=20
local upIdx=1

function NFZPRebateView.__init(self)
    self : register()
end

function NFZPRebateView.register(self)
    self.pMediator = require("mod.rebate.NFZPRebateMediator")(self)
end
function NFZPRebateView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function NFZPRebateView.create( self, tag,_data )
    print("转盘界面")
    self.m_container = cc.Node:create() 

    self.rightbg = cc.Sprite : create("ui/bg/rebate_nfzp.jpg")
    self.rightbg : setPosition(rightSize.width/2-21,-181)
    self.m_container : addChild(self.rightbg)
    self.kuangSize=self.rightbg:getContentSize()

    self.AcId = tag
    local endtime= self:getTimeStr(_data.endtime) or ""
    local startime = self : getTimeStr(_data.start) or ""

    local timeStrLab=_G.Util:createLabel("活动时间：",fontSize)
    -- timeStrLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
    timeStrLab:setPosition(35, 50)
    self.m_container:addChild(timeStrLab)

    local timeLab=_G.Util:createLabel(string.format("%s~%s",startime,endtime),fontSize)
    timeLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    timeLab:setPosition(90, 50)
    timeLab:setAnchorPoint(0,0.5)
    self.m_container:addChild(timeLab)

    self.m_useNameLab=_G.Util:createLabel("",fontSize)
    -- self.m_useNameLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
    self.m_useNameLab:setPosition(rightSize.width/2-120,-400)
    self.m_useNameLab:setAnchorPoint(0,0.5)
    self.m_container:addChild(self.m_useNameLab)

    self.m_useNumLab=_G.Util:createLabel("0",fontSize)
    self.m_useNumLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.m_useNumLab:setAnchorPoint(0,0.5)
    self.m_container:addChild(self.m_useNumLab)

    local tipsLab=_G.Util:createLabel("已经抽到的物品不会再次抽到",fontSize)
    tipsLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    tipsLab:setPosition(rightSize.width/2-21,-425)
    self.m_container:addChild(tipsLab)

    -- local titleSize=cc.size(180,335)
    -- local titleSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "rebate_title.png" ) 
    -- titleSpr : setContentSize(titleSize)
    -- titleSpr : setPosition(rightSize.width-107,-173)
    -- self.m_container:addChild(titleSpr)

    -- local titleLab=_G.Util : createLabel("游戏规则",fontSize+2)
    -- titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
    -- titleLab:setPosition(titleSize.width/2,titleSize.height-22)
    -- titleSpr:addChild(titleLab)

    -- local content=_G.Cfg.paly_des[40223].declare
    -- local height = 0
    -- for i=1,#content do
    --     local label = _G.Util : createLabel(string.format("%d.%s",i,content[i]),fontSize)
    --     label       : setAnchorPoint(cc.p(0,1))
    --     label       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    --     label       : setDimensions(titleSize.width-25,titleSize.height-30)
    --     label       : setPosition(cc.p(13,titleSize.height-40-height))
    --     titleSpr    : addChild(label)

    --     height = height + 65
    -- end

    self.jiantouSpr = cc.Sprite : createWithSpriteFrameName( "rebate_jiantou.png" ) 
    self.jiantouSpr : setPosition(self.kuangSize.width/2-10,self.kuangSize.height/2+8)
    -- self.jiantouSpr : setAnchorPoint(cc.p(0.5,0))
    self.rightbg : addChild(self.jiantouSpr,10)

    local function onBtnCallback(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
           self : onBtnReturnCallBack(sender,eventType)
        end
    end

    self.lotteryBtn=gc.CButton:create("rebate_btn.png")
    self.lotteryBtn:setPosition(self.kuangSize.width/2-10,self.kuangSize.height/2+8)
    self.lotteryBtn:addTouchEventListener(onBtnCallback)
    self.rightbg :addChild(self.lotteryBtn,11)

    local msg = REQ_ART_ZHUANPAN()
    msg:setArgs(self.AcId)
    _G.Network :send(msg)

    return self.m_container
end

function NFZPRebateView.NFZPData(self,_data)
    for k,v in pairs(_data.msg) do
        print("_data.msg",k)
        self.mengSpr[v.idx]:setVisible(true)
        -- if k>=12 then
        --     self.lotteryBtn:setEnabled(false)
        --     self.lotteryBtn:setBright(false)
        -- end
    end
end

function NFZPRebateView.updateData( self,_msg )	
	if self.AcId == _msg.id then
    	self.msg = _msg.msg
        self.m_useGoodsId=_msg.use_id
        self.m_useGoodsCount=_msg.use_count
		self:createGoodsCell()
    end
end

function NFZPRebateView.createGoodsCell( self )
    print("createGoodsCell",self.AcId)
    --local goodsList = _G.Cfg.zhuanpan
    --self.icondata = goodsList[self.AcId]
    self.icondata = self.msg
    local function cFun(sender,eventType)
        self:cellBtnCallback(sender,eventType)
    end

    local kSize = self.rightbg:getContentSize()
    local posX={self.kuangSize.width/2-10,self.kuangSize.width/2+65,self.kuangSize.width-193,self.kuangSize.width-173,
                self.kuangSize.width-193,self.kuangSize.width/2+65,self.kuangSize.width/2-10,self.kuangSize.width/2-83,
                173,153,173,self.kuangSize.width/2-83}
    local posY={self.kuangSize.height-103,self.kuangSize.height-123,self.kuangSize.height-177,self.kuangSize.height/2+8,
                195,141,121,141,195,self.kuangSize.height/2+8,self.kuangSize.height-177,self.kuangSize.height-123}
    self.havegood = {1,2,3,4,5,6,7,8,9,10,11,12}
    self.mengSpr = {1,2,3,4,5,6,7,8,9,10,11,12}
    self.m_ceilPosXArray={1,2,3,4,5,6,7,8,9,10,11,12}
    self.m_ceilPosYArray={1,2,3,4,5,6,7,8,9,10,11,12}

    for i=1,12 do
        self.havegood[i] = gc.CButton:create("general_tubiaokuan.png")
        -- self.havegood[i] : setContentSize(cc.size(85,85))
        self.havegood[i] : setButtonScale(0.7)
        self.havegood[i] : setRotation((i-1)*30)
        self.havegood[i] : setSwallowTouches(false)
        self.havegood[i] : setPosition(posX[i],posY[i])
        self.havegood[i] : addTouchEventListener(cFun)

        self.rightbg : addChild(self.havegood[i])
        if self.icondata~=nil and self.icondata[i]~=nil then
            print("请求物品图片",self.icondata, self.icondata[i].items_id)
            local goodId    = self.icondata[i].items_id
            local goodCount = self.icondata[i].value
            local goodsdata = _G.Cfg.goods[goodId]
            if goodsdata ~= nil then
                local iconSpr = _G.ImageAsyncManager:createGoodsSpr(goodsdata,goodCount)
                -- iconSpr : setRotation((i-1)*30)
                iconSpr : setPosition(iconSize.width/2,iconSize.height/2)
                self.havegood[i] : addChild(iconSpr)
                self.havegood[i] : setTag(goodId)
            end
        end 

        self.mengSpr[i] = cc.Sprite:createWithSpriteFrameName("rebate_have.png")
        -- self.mengSpr[i] : setContentSize(iconSize)
        self.mengSpr[i] : setPosition(iconSize.width/2,iconSize.height/2)
        self.mengSpr[i] : setVisible(false)
        self.havegood[i] : addChild(self.mengSpr[i])

        self.m_ceilPosXArray[i]=posX[i]+2
        self.m_ceilPosYArray[i]=posY[i]
    end

    self.m_headEffect = cc.Sprite : createWithSpriteFrameName("rebate_select.png")
    self.m_headEffect : setScale(0.7)
    self.m_headEffect : setVisible(false)
    self.rightbg : addChild(self.m_headEffect,100)

    print("self.m_useGoodsId",self.m_useGoodsId)
    local goodsdata=_G.Cfg.goods[self.m_useGoodsId]
    if goodsdata ~= nil then
        self.m_useNameLab: setString(string.format("每次消耗%s：",goodsdata.name))
    end
    local LabWidth=self.m_useNameLab:getContentSize().width
    self.m_useNumLab:setPosition(rightSize.width/2-115+LabWidth,-400)

    self:updateMoneyTab()
    self:Network()
end

function NFZPRebateView.Network( self )
    local msg = REQ_ART_ZHUANPAN_REQUEST_LIMIT()
    msg:setArgs(self.AcId)
    _G.Network :send(msg)
end

function NFZPRebateView.cellBtnCallback(self,sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        local role_tag  = sender : getTag()
        local Position  = sender : getWorldPosition()
        print("－－－－选中role_tag:", role_tag)
        if role_tag <= 0 then return end
        local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
        cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
    end
end

function NFZPRebateView.resetRewardEffectPos(self,_idx)
    _G.Util:playAudioEffect("Dong")
    self.m_headEffect:setPosition(self.m_ceilPosXArray[_idx]-2,self.m_ceilPosYArray[_idx])
    self.m_headEffect:setRotation((_idx-1)*30)
    self.jiantouSpr:setRotation((_idx-1)*30)
end

function NFZPRebateView.runRewardAction(self,_idx)
    print("runRewardAction--->>>",_idx)
    self:updateMoneyTab()
    if self.m_rewardScheduler~=nil then return end
    local curIdx=upIdx
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
            jiangeTimes=jiangeTimes+0.04
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
                self.lotteryBtn:setTouchEnabled(true)
                self.mengSpr[_idx]:setVisible(true)
                upIdx=_idx
                self:__showSysIconMove(_idx)
                _G.Util:playAudioEffect("balance_reward")
                return
            end
        end

        if curIdx==12 then
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

function NFZPRebateView.__showSysIconMove(self,_idx)
    print("__showSysIconMove=====>>>>")
    local openEffect=cc.ParticleSystemQuad:create("particle/sys_open_bomb2.plist")
    openEffect:setPosition(self.m_ceilPosXArray[_idx]-2,self.m_ceilPosYArray[_idx])
    self.rightbg:addChild(openEffect)
end

function NFZPRebateView.removeRewardScheduler(self)
    print("removeRewardScheduler-->1")
    if self.m_rewardScheduler~=nil then
        _G.Scheduler:unschedule(self.m_rewardScheduler)
        self.m_rewardScheduler=nil
    end
    cc.Director:getInstance():getEventDispatcher():setEnabled(true)
end

function NFZPRebateView.onBtnReturnCallBack(self, sender,eventType )
    print("不放回抽奖")
    local msg = REQ_ART_ZHUANPAN_LOTTERY_LIMIT()
    msg:setArgs(self.AcId)
    _G.Network:send(msg)
end

function NFZPRebateView.updateMoneyTab( self )
    local nums = _G.GBagProxy:getGoodsCountById(self.m_useGoodsId)
    print("updateMoneyTab",nums)
    if nums<1 then 
        self.m_useNumLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    end
    self.m_useNumLab : setString(string.format("%d/%d",nums,self.m_useGoodsCount))
end

function NFZPRebateView.getTimeStr( self, _time)
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

function NFZPRebateView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return NFZPRebateView