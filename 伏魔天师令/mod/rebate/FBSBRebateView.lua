local FBSBRebateView = classGc(view, function(self,_msg)
	self.msg = _msg
end)

local subCfg = _G.Cfg.sales_sub
local FONTSIZE  = 20
local rightSize = cc.size(622,517)
local iconSize  = cc.size(78,78) 

function FBSBRebateView.create(self,tag,_data)
    print("----->>data",tag)
    self : getStartTimeStr(_data.start)
    local endtime=_data.endtime
    local _type=_G.Cfg.sales_total[tag].type
    self : getEndTimeStr(endtime)

    print("starttime",self.startyear,self.startmonth,self.startday,self.starthour)
    print("endtime",self.endyear,self.endmonth,self.endday,self.endhour)

    self.m_container = cc.Node:create() 

    local bgjpg="ui/bg/rebate_fbfb.jpg"
    if _type==42 then
        bgjpg="ui/bg/rebate_zqfh.jpg"
    elseif _type==43 then
        bgjpg="ui/bg/rebate_cwfh.jpg"
    elseif _type==44 then
        bgjpg="ui/bg/rebate_cbsb.png"
    elseif _type==45 then
        bgjpg="ui/bg/rebate_cbsb.png"
    elseif _type<42 or _type==48 then
        bgjpg="ui/bg/feast_tsbg.jpg"
    elseif _type==46 then
        bgjpg="ui/bg/rebate_yqfb.jpg"
    elseif _type==47 then
        bgjpg="ui/bg/rebate_jjfb.jpg"
    elseif _type==49 then
        bgjpg="ui/bg/rebate_tlfb.jpg"
    end
    self.rightbg = cc.Sprite : create(bgjpg)
    -- self.rightbg : setScale(1.03)
    self.rightbg : setPosition(rightSize.width/2-21,-181)
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

    local timeStrSpr = cc.Sprite:createWithSpriteFrameName("rebate_time2.png")
    timeStrSpr : setPosition(rightSize.width/2,rightSize.height/2-32)
    self.rightbg : addChild( timeStrSpr )

    local _type=_G.Cfg.sales_total[tag].type
    local fbStr=""
    -- local fbStr2=""
    local StrWidth=0
    local StrHeight=146
    local fbimg=""
    local fbMAP=nil
    local fbOPEN=nil
    if _type==38 then
        fbStr="rebate_fbstr.png"
        -- fbStr2="让战斗的热血持续下去"
        fbimg="main_icon_duplicate_2.png"
        fbMAP=_G.Const.CONST_MAP_COPY_NIGHTMARE
        fbOPEN=_G.Const.CONST_FUNC_OPEN_COPY_NIGHTMARE
    elseif _type==39 then
        fbStr="rebate_fbstr.png"
        -- fbStr2="让战斗的热血持续下去"
        fbimg="main_icon_duplicate_3.png"
        fbMAP=_G.Const.CONST_MAP_COPY_HELL
        fbOPEN=_G.Const.CONST_FUNC_OPEN_COPY_HELL
    elseif _type==40 then
        fbStr="rebate_zdstr.png"
        StrWidth=-50
        fbimg="main_icon_duplicate.png"
        fbMAP=_G.Const.CONST_MAP_TEAM
        fbOPEN=_G.Const.CONST_FUNC_OPEN_TEAM
    elseif _type==41 then
        fbStr="rebate_xmstr.png"
        StrWidth=-55
        fbimg="main_icon_Demons.png"
        fbMAP=_G.Const.CONST_MAP_DEMONS
        fbOPEN=_G.Const.CONST_FUNC_OPEN_DEMONS
    elseif _type==42 then
        StrWidth=-50
        fbimg="main_icon_vehicle.png"
        fbMAP=_G.Const.CONST_MAP_MOUNT
        fbOPEN=_G.Const.CONST_FUNC_OPEN_MOUNT
    elseif _type==43 then
        StrWidth=-50
        fbimg="main_icon_soulsoul.png"
        fbMAP=_G.Const.CONST_MAP_WING
        fbOPEN=_G.Const.CONST_FUNC_OPEN_WING
    elseif _type==44 then
        fbStr="rebate_cb44.png"
        StrWidth=-50
        StrHeight=150
        fbimg="main_icon_feather.png"
        fbMAP=_G.Const.CONST_MAP_FEATHER
        fbOPEN=_G.Const.CONST_FUNC_OPEN_FEATHER
    elseif _type==45 then
        fbStr="rebate_cb45.png"
        -- StrWidth=-100
        fbimg="main_icon_feather.png"
        fbMAP=_G.Const.CONST_MAP_FEATHER
        fbOPEN=_G.Const.CONST_FUNC_OPEN_FEATHER
    elseif _type==46 then
        fbStr="rebate_yqstr.png"
        StrWidth=30
        fbimg="main_icon_treasure.png"
        fbMAP=_G.Const.CONST_MAP_LUCKY
        fbOPEN=_G.Const.CONST_FUNC_OPEN_LUCKY
    elseif _type==47 then
        fbStr="rebate_jjstr.png"
        StrWidth=-10
        fbimg="main_icon_combat_2.png"
        fbMAP=_G.Const.CONST_MAP_ARENA
        fbOPEN=_G.Const.CONST_FUNC_OPEN_ARENA
    elseif _type==48 then
        fbStr="rebate_bsstr.png"
        -- fbStr2="打得越痛奖得越多"
        fbimg="main_icon_yaowang.png"
        fbMAP=_G.Const.CONST_MAP_BOSS
        fbOPEN=_G.Const.CONST_FUNC_OPEN_BOSS
    elseif _type==49 then
        fbStr="rebate_tlstr.png"
        fbimg="main_icon_power.png"
        fbMAP=_G.Const.CONST_MAP_ENARGY
        fbOPEN=nil
    end

    if _type~=43 and _type~=42 then
        local strSpr = cc.Sprite:createWithSpriteFrameName(fbStr)
        strSpr : setPosition(rightSize.width/2+30,rightSize.height-150)
        self.rightbg : addChild(strSpr,10)
    end

    print("id,value1,value2===>>>",_data.id,_data.cmp,_data.value2)
    if _type~=38 and _type~=39 and _type~=45 then
        if _type~=43 and _type~=42 and _type~=44 then
            StrWidth=rightSize.width/2-15+StrWidth
            local chengSpr = cc.Sprite:createWithSpriteFrameName("beishu_x.png")
            chengSpr : setPosition(StrWidth,rightSize.height-182)
            self.rightbg : addChild(chengSpr,10)

            local count = _data.cmp+1
            local floor1 = math.floor(count*10)
            local gewei = math.fmod(floor1,10)
            print("floor1==>>",floor1,gewei)

            StrWidth=chengSpr:getContentSize().width+StrWidth
            local timesSpr1 = cc.Sprite:createWithSpriteFrameName( string.format("beishu_%d.png",count))
            timesSpr1 : setPosition(StrWidth,rightSize.height-182)
            -- timesSpr1:setScale(1.5)
            self.rightbg : addChild( timesSpr1 )

            StrWidth=StrWidth+timesSpr1:getContentSize().width-5
            local dotSpr = cc.Sprite:createWithSpriteFrameName("advert_dot.png")
            dotSpr : setPosition(StrWidth,rightSize.height-192)
            self.rightbg : addChild( dotSpr )

            StrWidth=StrWidth+dotSpr:getContentSize().width+5
            local timesSpr2 = cc.Sprite:createWithSpriteFrameName(string.format("beishu_%d.png",gewei))
            timesSpr2 : setPosition(StrWidth,rightSize.height-182)
            -- timesSpr2:setScale(1.5)
            self.rightbg : addChild( timesSpr2 )
        else
            StrWidth=rightSize.width/2-15+StrWidth
            local count=_data.cmp/1000
            local floor1 = math.floor(count*10)
            local gewei = math.fmod(floor1,10)
            local timesSpr1 = cc.Sprite:createWithSpriteFrameName( string.format("beishu_%d.png",count))
            timesSpr1 : setPosition(StrWidth,rightSize.height-StrHeight)
            self.rightbg : addChild( timesSpr1 )

            StrWidth=StrWidth+timesSpr1:getContentSize().width
            local timesSpr2 = cc.Sprite:createWithSpriteFrameName(string.format("beishu_%d.png",gewei))
            timesSpr2 : setPosition(StrWidth,rightSize.height-StrHeight)
            -- timesSpr2:setScale(1.5)
            self.rightbg : addChild( timesSpr2 )


            local Number=tostring(_data.value2)
            local length=string.len(Number)
            local numberNode=cc.Node:create()

            local spriteWidth=StrWidth+45
            for i=1,length do
                local tempSpr=cc.Sprite:createWithSpriteFrameName("beishu_"..string.sub(Number,i,i)..".png")
                numberNode : addChild(tempSpr)

                local tempSprSize=tempSpr:getContentSize()
                spriteWidth=spriteWidth+tempSprSize.width
                tempSpr:setPosition(spriteWidth,rightSize.height-StrHeight-54)
            end
            self.rightbg : addChild( numberNode )
        end
    end

    local function onButtonCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if _G.GOpenProxy:showSysNoOpenTips(fbOPEN) then return false end
            _G.GLayerManager:openLayerByMapOpenId(fbMAP)
            if _type~=49 then 
                local command=CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_REBATE)
                controller:sendCommand(command) 
            end
        end
    end
    self.e_drawBtn = gc.CButton : create(fbimg)
    self.e_drawBtn : setPosition(rightSize.width-90, 70)
    self.e_drawBtn : addTouchEventListener(onButtonCallBack)
    -- self.e_drawBtn : setButtonScale(1.5)
    self.rightbg : addChild(self.e_drawBtn)

    return self.m_container
end

function FBSBRebateView.getTimeNumSpr( self, _Num )
    print("getTimeNumStr-->",_Num)
    local NumSprNode = cc.Node:create()
    local length = string.len(_Num)
    local spriteWidth = 0
    for i=1, length do
        local _tempSpr = cc.Sprite:createWithSpriteFrameName( "advert_"..string.sub(_Num,i,i)..".png")
        NumSprNode : addChild( _tempSpr )

        local _tempSprSize = _tempSpr : getContentSize()
        spriteWidth        = spriteWidth + _tempSprSize.width / 2+5
        _tempSpr           : setPosition( spriteWidth,0)
    end

    return NumSprNode
end

function FBSBRebateView.getStartTimeStr( self, _time)
    local time = os.date("*t",_time)
    print("time",_time)
    self.startyear=time.year
    self.startmonth=time.month < 10 and "0"..time.month or time.month
    self.startday=time.day < 10 and "0"..time.day or time.day
    self.starthour=time.hour < 10 and "0"..time.hour or time.hour
    self.startmin=time.min < 10 and "0"..time.min or time.min
end

function FBSBRebateView.getEndTimeStr( self, _time)
    local time = os.date("*t",_time)
    print("time",_time)
    self.endyear=time.year
    self.endmonth=time.month < 10 and "0"..time.month or time.month
    self.endday=time.day < 10 and "0"..time.day or time.day
    self.endhour=time.hour < 10 and "0"..time.hour or time.hour
    self.endmin=time.min < 10 and "0"..time.min or time.min
end

function FBSBRebateView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return FBSBRebateView