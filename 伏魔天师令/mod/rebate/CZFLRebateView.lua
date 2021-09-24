local CZFLRebateView = classGc(view, function(self,_msg)
	self.msg = _msg
end)

local subCfg = _G.Cfg.sales_sub
local FONTSIZE  = 18
local rightSize = cc.size(622,517)
local iconSize  = cc.size(78,78) 

function CZFLRebateView.create(self,tag,_data)
    print("----->>data",tag)
    self : getStartTimeStr(_data.start)
    local endtime=_data.endtime
    if _G.Cfg.sales_total[tag].type==21 then
        endtime=_data.cmp
    end
    self : getEndTimeStr(endtime)

    print("starttime",self.startyear,self.startmonth,self.startday,self.starthour)
    print("endtime",self.endyear,self.endmonth,self.endday,self.endhour)

    self.m_container = cc.Node:create() 

    self.rightbg = cc.Sprite : create("ui/bg/rebate_czfl.jpg")
    -- self.rightbg : setScale(1.03)
    self.rightbg : setPosition(rightSize.width/2-21,-180)
    self.m_container : addChild(self.rightbg)

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

    start_Year:setPosition(rightSize.width/2-115,rightSize.height/2-12)
    start_Month:setPosition(rightSize.width/2-28,rightSize.height/2-12)
    start_Day:setPosition(rightSize.width/2+30,rightSize.height/2-12)
    start_Hour:setPosition(rightSize.width-227,rightSize.height/2-12)
    start_Min:setPosition(rightSize.width-165,rightSize.height/2-12)
    end_Year:setPosition(rightSize.width/2-138,rightSize.height/2-50)
    end_Month:setPosition(rightSize.width/2-53,rightSize.height/2-50)
    end_Day:setPosition(rightSize.width/2+2,rightSize.height/2-50)
    end_Hour:setPosition(rightSize.width/2+57,rightSize.height/2-50)
    end_Min:setPosition(rightSize.width/2+120,rightSize.height/2-50)

    self.rightbg:addChild(start_Year)
    self.rightbg:addChild(start_Month)
    self.rightbg:addChild(start_Day)
    self.rightbg:addChild(start_Hour)
    self.rightbg:addChild(start_Min)
    self.rightbg:addChild(end_Year)
    self.rightbg:addChild(end_Month)
    self.rightbg:addChild(end_Day)
    self.rightbg:addChild(end_Hour)
    self.rightbg:addChild(end_Min)

    local icondata = nil
    for k,v in pairs(self.msg.msg2) do
        --if v.id == _data.id then
            --print("subCfg",v.id,v.value)
            local tab = {}
            for i=1,#v.msg do
            	tab[i]={v.msg[i].id,v.msg[i].num}
            end
            icondata = tab
        --end
    end

    local _type =_G.Cfg.sales_total[tag].type
    local strSpr = cc.Sprite : createWithSpriteFrameName(string.format("rebate_cz%d.png",_type))
    strSpr : setPosition(rightSize.width/2+30,rightSize.height/2+115)
    self.rightbg : addChild(strSpr)

    local count = icondata[1][2]/10000+1
    local floor1 = math.floor(count*10)
    local gewei = math.fmod(floor1,10)
    print("icondata",icondata[1][2],count,gewei)

    local Width = -4
    local num = 2
    if _type==36 then
        Width = -61
        strSpr : setPosition(rightSize.width/2+55,rightSize.height/2+115)
    elseif _type==21 then
        Width = -95 
        num=1
        strSpr : setPosition(rightSize.width/2+90,rightSize.height/2+118)
        start_Year:setPosition(155,rightSize.height/2-15)
        start_Month:setPosition(rightSize.width/2-65,rightSize.height/2-15)
        start_Day:setPosition(rightSize.width/2-10,rightSize.height/2-15)
        start_Hour:setPosition(rightSize.width/2-22,rightSize.height/2-50)
        end_Year:setPosition(rightSize.width/2+64,rightSize.height/2-15)
        end_Month:setPosition(rightSize.width-157,rightSize.height/2-15)
        end_Day:setPosition(rightSize.width-100,rightSize.height/2-15)
        end_Hour:setPosition(rightSize.width/2+50,rightSize.height/2-50)
        start_Min:setVisible(false)
        end_Min:setVisible(false)
    end

    local timeStrSpr = cc.Sprite:createWithSpriteFrameName( string.format("rebate_time%d.png",num))
    timeStrSpr : setPosition(rightSize.width/2,rightSize.height/2-32)
    self.rightbg : addChild( timeStrSpr )

    local timesSpr1 = cc.Sprite:createWithSpriteFrameName( string.format("beishu_%d.png",count))
    timesSpr1 : setPosition(rightSize.width/2+95+Width,rightSize.height/2+77)
    -- timesSpr1:setScale(1.5)
    self.rightbg : addChild( timesSpr1 )

    local timesSpr2 = cc.Sprite:createWithSpriteFrameName(string.format("beishu_%d.png",gewei))
    timesSpr2 : setPosition(rightSize.width/2+145+Width,rightSize.height/2+77)
    -- timesSpr2:setScale(1.5)
    self.rightbg : addChild( timesSpr2 )

    local dotSpr = cc.Sprite:createWithSpriteFrameName("advert_dot.png")
    dotSpr : setPosition(rightSize.width/2+120+Width,rightSize.height/2+67)
    self.rightbg : addChild( dotSpr )

    --local tipsLab5 = _G.Util : createLabel("提示:本次活动期间不可使用财神卡以及打折卡", FONTSIZE)
    -- tipsLab5 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    --tipsLab5 : setPosition(rightSize.width/2-120,25)
    --tipsLab5 : setAnchorPoint(cc.p(0.0,0.5))
    --self.rightbg : addChild(tipsLab5)

    local function onButtonCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local command=CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_REBATE)
            controller:sendCommand(command) 
            _G.GLayerManager:delayOpenLayer(_G.Const.CONST_FUNC_OPEN_RECHARGE)
        end
    end
    self.e_drawBtn = gc.CButton : create("general_btn_gold.png")
    self.e_drawBtn : setTitleFontName(_G.FontName.Heiti)
    self.e_drawBtn : setTitleText("充 值")
    self.e_drawBtn : setTitleFontSize(FONTSIZE+4)
    self.e_drawBtn : setPosition(rightSize.width/2, 130)
    self.e_drawBtn : addTouchEventListener(onButtonCallBack)
    --self.e_drawBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    self.rightbg : addChild(self.e_drawBtn)

    return self.m_container
end

function CZFLRebateView.getTimeNumSpr( self, _Num )
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

function CZFLRebateView.getStartTimeStr( self, _time)
    local time = os.date("*t",_time)
    print("time",_time)
    self.startyear=time.year
    self.startmonth=time.month < 10 and "0"..time.month or time.month
    self.startday=time.day < 10 and "0"..time.day or time.day
    self.starthour=time.hour < 10 and "0"..time.hour or time.hour
    self.startmin=time.min < 10 and "0"..time.min or time.min
end

function CZFLRebateView.getEndTimeStr( self, _time)
    local time = os.date("*t",_time)
    print("time",_time)
    self.endyear=time.year
    self.endmonth=time.month < 10 and "0"..time.month or time.month
    self.endday=time.day < 10 and "0"..time.day or time.day
    self.endhour=time.hour < 10 and "0"..time.hour or time.hour
    self.endmin=time.min < 10 and "0"..time.min or time.min
end

function CZFLRebateView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return CZFLRebateView