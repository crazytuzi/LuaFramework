local FCFLRebateView = classGc(view, function(self,_type,_msg)
    self.type=_type
	self.msg =_msg
end)

local subCfg = _G.Cfg.sales_sub
local FONTSIZE  = 20
local R_ROWNO	= 3 --列数
local rightSize = cc.size(622,517)
local iconSize  = cc.size(78,78)

function FCFLRebateView.create(self,tag,_data)
    local endtime = self : getTimeStr(_data.endtime) or ""
    local startime = self : getTimeStr(_data.start) or ""
    print("----->>data",_data.endtime,_data.count,tag)
	self.m_container = cc.Node:create() 

	local rightbg = cc.Sprite : create("ui/bg/rebate_fcfl.jpg")
    -- rightbg : setScale(1.03)
    rightbg : setPosition(rightSize.width/2-21,-181)
    self.m_container : addChild(rightbg)
    
    local timeLab= _G.Util : createLabel("活动时间：", FONTSIZE)
    -- timeLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    timeLab : setPosition(35, 50)
    self.m_container : addChild(timeLab)

    local endTimeLab  = _G.Util : createLabel(string.format("%s~%s",startime,endtime), FONTSIZE)
    endTimeLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    endTimeLab  : setPosition(90, 50)
    endTimeLab  : setAnchorPoint(cc.p(0.0,0.5))
    self.m_container : addChild(endTimeLab)

    local img="rebate_fl61.png"
    if _G.Cfg.sales_total[tag].type==63 then 
        img="rebate_fl63.png"
    end

    local timeStrSpr = cc.Sprite:createWithSpriteFrameName(img)
    timeStrSpr : setPosition(rightSize.width/2-21,-70)
    self.m_container : addChild( timeStrSpr )

    print("----->>value",_data.cmp,_data.value2)
    if _G.Cfg.sales_total[tag].type~=63 then
        local count = _data.cmp/10000
        local floor1 = math.floor(count*10)
        local gewei = math.fmod(floor1,10)
        print("floor1==>>",floor1,gewei)

        local StrWidth=80
        local timesSpr1 = cc.Sprite:createWithSpriteFrameName( string.format("beishu_%d.png",count))
        timesSpr1 : setPosition(StrWidth,-70)
        -- timesSpr1:setScale(1.5)
        self.m_container : addChild( timesSpr1 )

        StrWidth=StrWidth+timesSpr1:getContentSize().width-5
        local dotSpr = cc.Sprite:createWithSpriteFrameName("advert_dot.png")
        dotSpr : setPosition(StrWidth,-82)
        self.m_container : addChild( dotSpr )

        StrWidth=StrWidth+dotSpr:getContentSize().width+5
        local timesSpr2 = cc.Sprite:createWithSpriteFrameName(string.format("beishu_%d.png",gewei))
        timesSpr2 : setPosition(StrWidth,-70)
        -- timesSpr2:setScale(1.5)
        self.m_container : addChild( timesSpr2 )
    else
        local Number=tostring(_data.cmp/100)
        local length=string.len(Number)
        local numberNode=cc.Node:create()

        local spriteWidth=100
        for i=1,length do
            local tempSpr=cc.Sprite:createWithSpriteFrameName("beishu_"..string.sub(Number,i,i)..".png")
            numberNode : addChild(tempSpr)

            local tempSprSize=tempSpr:getContentSize()
            spriteWidth=spriteWidth+tempSprSize.width/2+13
            tempSpr:setPosition(spriteWidth,-105)
        end
        self.m_container : addChild( numberNode )
    end

    local height=192
    for i=1,#_G.Cfg.paly_des[tag].declare do
        local flag  = _G.Util : createLabel(string.format("%d.",i),FONTSIZE)
        flag        : setAnchorPoint(cc.p(0,1))
        flag        : setPosition(cc.p(0,-height))
        self.m_container      : addChild(flag)

        local label = _G.Util : createLabel(_G.Cfg.paly_des[tag].declare[i],FONTSIZE)
        label       : setAnchorPoint(cc.p(0,1))
        label       : setDimensions(575,0)
        label       : setPosition(cc.p(15,-height))
        self.m_container      : addChild(label)

        height = height + label : getContentSize().height+10
    end

    local rechargeStr= _G.Util : createLabel("充值总额：", FONTSIZE)
    -- rechargeStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    rechargeStr : setPosition(40, -375)
    self.m_container : addChild(rechargeStr)

    local awardStr= _G.Util : createLabel("返还钻石：", FONTSIZE)
    -- awardStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    awardStr : setPosition(40, -410)
    self.m_container : addChild(awardStr)

    local floorSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
    floorSpr:setContentSize(cc.size(rightSize.width-50,3))
    floorSpr:setPosition(rightSize.width/2-21,-347)
    self.m_container : addChild(floorSpr)

    local value2={_data.value2,_data.value2*_data.cmp/10000}
    if tag==631 then
        value2={_data.value2,math.ceil(_data.value2*(_data.cmp/10000))}
    end
    for i=1,2 do
        local NumLab= _G.Util : createLabel(value2[i], FONTSIZE)
        NumLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
        NumLab : setPosition(95, -375-(i-1)*35)
        NumLab : setAnchorPoint(cc.p(0,0.5))
        self.m_container : addChild(NumLab)
    end

    if tag~=611 then
        local m_data=nil
        for k,v in pairs(_data.msg2) do
            print(k,v.id_sub,v.state,v.ex_value)
            m_data=v
        end
        local function intensifyEvent( send,eventType )
            if eventType == ccui.TouchEventType.ended then
                if m_data==nil then return end
                local msg = REQ_ART_REWARD()
                msg       : setArgs(tag)
                _G.Network: send(msg)
            end
            return false
        end 

        self.m_button  = gc.CButton:create()
        self.m_button  : addTouchEventListener(intensifyEvent)
        self.m_button  : loadTextures("general_btn_gold.png")
        self.m_button  : setTitleText("领 取")
        self.m_button  : setTitleFontSize(FONTSIZE+2)
        self.m_button  : setTitleFontName(_G.FontName.Heiti)
        self.m_button  : setPosition(cc.p(rightSize.width-120,-395))
        self.m_container : addChild(self.m_button)
        if m_data~=nil and m_data.state==3 then
            self.m_button  : setTitleText("已领取")
            self.m_button  : setBright(false)
            self.m_button  : setEnabled(false)
        end
    end

    return self.m_container
end

function FCFLRebateView.SuccessReward( self)
    self.m_button  : setTitleText("已领取")
    self.m_button  : setBright(false)
    self.m_button  : setEnabled(false)
end

function FCFLRebateView.getTimeStr( self, _time)
    local time = os.date("*t",_time)
    print("time",_time)

    if time.month < 10 then time.month = "0"..time.month end
    if time.day < 10 then time.day = "0"..time.day end
    if time.hour < 10 then time.hour = "0"..time.hour
    elseif time.hour < 0 then time.hour = "00" end
    if time.min < 10 then time.min = "0"..time.min
    elseif time.min < 0 then time.min = "00" end

    local time  = time.year.."/"..time.month.."/"..time.day.." "..time.hour..":"..time.min
    print("endtime",time)

    return time
end

function FCFLRebateView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return FCFLRebateView