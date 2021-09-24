local TSLXActivityView = classGc(view, function(self)

end)

local subCfg = _G.Cfg.sales_sub
local FONTSIZE  = 18
local rightSize = cc.size(580,460)
local iconSize  = cc.size(85,85) 

function TSLXActivityView.create(self,tag,_data)
    print("----->>data",tag)
    self : getStartTimeStr(_data.start_time)
    self : getEndTimeStr(_data.end_time)

    print("starttime",self.startyear,self.startmonth,self.startday,self.starthour,self.startmin)
    print("endtime",self.endyear,self.endmonth,self.endday,self.endhour,self.endmin)

    self.m_container = cc.Node:create() 

    local tongshouSpr = cc.Sprite : create("ui/bg/feast_tsbg.jpg")
    -- tongshouSpr : setScaleY(0.995)
    tongshouSpr : setPosition(rightSize.width/2,rightSize.height/2-27)
    self.m_container : addChild(tongshouSpr)

    local start_Year = self:getTimeNumSpr(self.startyear)
    local start_Month = self:getTimeNumSpr(self.startmonth)
    local start_Day = self:getTimeNumSpr(self.startday)
    local start_Hour = self:getTimeNumSpr(self.starthour)
    local start_Min = self:getTimeNumSpr(self.startmin)
    local end_Year = self:getTimeNumSpr(self.endyear)
    local end_Month = self:getTimeNumSpr(self.endmonth)
    local end_Day = self:getTimeNumSpr(self.endday)
    local end_Hour = self:getTimeNumSpr(self.endhour)
    local end_Min = self:getTimeNumSpr(self.endmin)

    local sm_length = string.len(self.startmonth)
    local sd_length = string.len(self.startday)
    local em_length = string.len(self.endmonth)
    local ed_length = string.len(self.endday)
    start_Year:setPosition(rightSize.width/2-95,rightSize.height/2+35)
    start_Month:setPosition(rightSize.width/2-5,rightSize.height/2+35)
    start_Day:setPosition(rightSize.width/2+50,rightSize.height/2+35)
    start_Hour:setPosition(rightSize.width-185,rightSize.height/2+35)
    start_Min:setPosition(rightSize.width-123,rightSize.height/2+35)
    end_Year:setPosition(rightSize.width/2-120,rightSize.height/2-2)
    end_Month:setPosition(rightSize.width/2-37,rightSize.height/2-2)
    end_Day:setPosition(rightSize.width-267,rightSize.height/2-2)
    end_Hour:setPosition(rightSize.width-212,rightSize.height/2-2)
    end_Min:setPosition(rightSize.width-150,rightSize.height/2-2)

    tongshouSpr:addChild(start_Year)
    tongshouSpr:addChild(start_Month)
    tongshouSpr:addChild(start_Day)
    tongshouSpr:addChild(start_Hour)
    tongshouSpr:addChild(start_Min)
    tongshouSpr:addChild(end_Year)
    tongshouSpr:addChild(end_Month)
    tongshouSpr:addChild(end_Day)
    tongshouSpr:addChild(end_Hour)
    tongshouSpr:addChild(end_Min)

    local timeStrSpr = cc.Sprite:createWithSpriteFrameName("rebate_time2.png")
    timeStrSpr : setPosition(rightSize.width/2+20,rightSize.height/2+16)
    tongshouSpr : addChild( timeStrSpr )

    local fbimg="main_iconbig_tiaozhan.png"
    local fbMAP=_G.Const.CONST_MAP_COPY_NIGHTMARE
    local fbOPEN=_G.Const.CONST_FUNC_OPEN_COPY_NIGHTMARE

    local tipsSpr = cc.Sprite:createWithSpriteFrameName("feast_content1.png")
    tipsSpr : setPosition(30,rightSize.height-70)
    tipsSpr : setAnchorPoint(cc.p(0.0,0.5))
    tongshouSpr : addChild(tipsSpr,10)

    local tipsSpr1 = cc.Sprite:createWithSpriteFrameName("feast_tips.png")
    tipsSpr1 : setPosition(rightSize.width/2,85)
    -- tipsSpr1 : setAnchorPoint(cc.p(0.0,0.5))
    tongshouSpr : addChild(tipsSpr1,10)

    local tipsSpr2 = cc.Sprite:createWithSpriteFrameName("feast_finger.png")
    tipsSpr2 : setPosition(rightSize.width/2+130,90)
    -- tipsSpr2 : setAnchorPoint(cc.p(0.0,0.5))
    tongshouSpr : addChild(tipsSpr2,10)

    local function onButtonCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local msg=REQ_COPY_NEW_CREAT()
            msg:setArgs(_G.Const.CONST_HOLIDAY_TONGQIAN)
            _G.Network:send(msg)
        end
    end
    self.e_drawBtn = gc.CButton : create(fbimg)
    self.e_drawBtn : setPosition(rightSize.width-60, 90)
    self.e_drawBtn : addTouchEventListener(onButtonCallBack)
    -- self.e_drawBtn : setButtonScale(1.5)
    tongshouSpr : addChild(self.e_drawBtn)

    local StrLab = _G.Util : createLabel("挑战次数: ", FONTSIZE)
    -- StrLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
    StrLab : setPosition(rightSize.width-80,30)
    -- StrLab : setAnchorPoint(cc.p(0.0,0.5))
    tongshouSpr : addChild(StrLab,10)

    self.tzNumLab = _G.Util : createLabel("", FONTSIZE)
    self.tzNumLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    self.tzNumLab : setPosition(rightSize.width-110+StrLab:getContentSize().width,30)
    self.tzNumLab : setAnchorPoint(cc.p(0.0,0.5))
    tongshouSpr : addChild(self.tzNumLab,10)

    -- self : _showRoleSpine("spine/20731")
    
    local msg=REQ_COPY_MONEY_REQUEST()
    _G.Network:send(msg)

    return self.m_container
end

-- function TSLXActivityView._showRoleSpine( self,_spine )
--     print( "进入：_showRoleSpine !" )
--     if self.spine ~= nil then
--         self.spine : removeFromParent(true)
--         self.spine = nil
--     end
--     local nScale=0.35
--     self.spine=_G.SpineManager.createSpine(_spine,nScale) -- _mountId
--     self.spine:setPosition(cc.p(250,20))
--     self.m_container:addChild(self.spine,3)
--     self.spine:setAnimation(0,"idle",true)
-- end

function TSLXActivityView.uncountdownEvent( self )
    if self.m_Scheduler ~= nil then
        print("unschedule=============")
        _G.Scheduler : unschedule(self.m_Scheduler )
        self.m_Scheduler = nil
    end
end

function TSLXActivityView.COPY_TIME( self, _data )
    self.tzNumLab:setString(string.format("%d/%d",_data.times_all-_data.times,_data.times_all))
end

function TSLXActivityView.getTimeNumSpr( self, _Num )
    print("getTimeNumStr-->",_Num)
    local NumSprNode = cc.Node:create()
    local length = string.len(_Num)
    local spriteWidth = 0
    for i=1, length do
        local _tempSpr = cc.Sprite:createWithSpriteFrameName( "advert_"..string.sub(_Num,i,i)..".png")
        -- _tempSpr:setScale(0.8)
        NumSprNode : addChild( _tempSpr )

        local _tempSprSize = _tempSpr : getContentSize()
        spriteWidth        = spriteWidth + _tempSprSize.width / 2+5
        _tempSpr           : setPosition( spriteWidth,0)
    end

    return NumSprNode
end

function TSLXActivityView.getStartTimeStr( self, _time)
    local time = os.date("*t",_time)
    print("time",_time)
    self.startyear=time.year or 1 
    self.startmonth=time.month<10 and "0"..time.month or time.month
    self.startday=time.day<10 and "0"..time.day or time.day 
    self.starthour=time.hour < 10 and "0"..time.hour or time.hour
    self.startmin=time.min < 10 and "0"..time.min or time.min
end

function TSLXActivityView.getEndTimeStr( self, _time)
    local time = os.date("*t",_time)
    print("time",_time)
    self.endyear=time.year or 1 
    self.endmonth=time.month<10 and "0"..time.month or time.month
    self.endday=time.day<10 and "0"..time.day or time.day 
    self.endhour=time.hour < 10 and "0"..time.hour or time.hour
    self.endmin=time.min < 10 and "0"..time.min or time.min
end

function TSLXActivityView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return TSLXActivityView