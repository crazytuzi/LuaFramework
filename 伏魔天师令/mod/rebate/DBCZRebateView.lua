local DBCZRebateView = classGc(view, function(self,_msg)
    self.Num = 0
    self.msg = _msg
end)

local subCfg = _G.Cfg.sales_sub

local FONTSIZE  = 20
local m_winSize = cc.Director:getInstance():getVisibleSize()
local rightSize = cc.size(622,517)
local iconSize  = cc.size(78,78) 

function DBCZRebateView.create(self,tag,_data)
    print("----->>data",_data.endtime,_data.cmp,_data.count,_data.msg2)
    local endtime = self : getTimeStr(_data.endtime) or ""
    local startime = self : getTimeStr(_data.start) or ""
    local rebateData = _data.msg2
    for k,v in pairs(rebateData) do
        if v.state == 3 then
            self.Num = self.Num + 1
        end
    end
    self.Zong = _data.cmp or 0
	self.m_container = cc.Node:create()

    local endTimeStr = _G.Util : createLabel("活动时间：", FONTSIZE)
    -- endTimeStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    endTimeStr : setPosition(35, 50)
    self.m_container : addChild(endTimeStr)

    local rechargeStr= _G.Util : createLabel("领取次数：", FONTSIZE)
    -- rechargeStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    rechargeStr : setPosition(35, 16)
    self.m_container : addChild(rechargeStr)

    local endTimeLab  = _G.Util : createLabel(string.format("%s~%s",startime,endtime), FONTSIZE)
    endTimeLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    endTimeLab  : setPosition(90, 50)
    endTimeLab  : setAnchorPoint(cc.p(0.0,0.5))
    self.m_container : addChild(endTimeLab)

    self.rechargeLab = _G.Util : createLabel(self.Num.."/"..self.Zong, FONTSIZE)
    self.rechargeLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    self.rechargeLab : setPosition(90, 16)
    self.rechargeLab : setAnchorPoint(cc.p(0.0,0.5))
    self.m_container : addChild(self.rechargeLab)

    local floorSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    floorSpr:setContentSize(cc.size(rightSize.width,rightSize.height-88))
    floorSpr:setPosition(289,-223)
    self.m_container : addChild(floorSpr)

    self : ScrollView(tag,_data)
    return self.m_container
end

function DBCZRebateView.ScrollView(self,_tag,_data)
    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView = ScrollView
    local count = _data.count
    self.oneHeight = (rightSize.height-95)/3
    local viewSize = cc.size(rightSize.width, rightSize.height-95)
    local containerSize = cc.size(rightSize.width, self.oneHeight*count)

    ScrollView : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView : setViewSize(viewSize)
    ScrollView : setContentSize(containerSize)
    ScrollView : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    ScrollView : setPosition(-22, -434)
    print("容器大小：",self.oneHeight*count)
    ScrollView : setBounceable(false)
    ScrollView : setTouchEnabled(true)
    ScrollView : setDelegate()
    self.m_container : addChild(ScrollView)
    
    local barView=require("mod.general.ScrollBar")(ScrollView)
    barView:setPosOff(cc.p(-5,0))
    -- barView:setMoveHeightOff(-7)

    local function sort(m1,m2)
        if m1.id_sub < m2.id_sub then
            print(m1.id_sub,m2.id_sub)
            return true
        end
        return false
    end
    table.sort( _data.msg2, sort )

    self.OneWidget = {}
    local msgdata = {}
    if _data.msg2~=nil then
        for k,v in pairs(_data.msg2) do
            print("bijiao",k,v)
            msgdata[k] = v
        end
    end
    local zongzhi=#_data.msg2
    local index=1
    local function nFun()
        if index>zongzhi then
            self:__removeScheduler()
            return
        end

        if msgdata[index] then 
            local OneReward = self : Widgetreturn(_tag, msgdata[index])
            OneReward : setPosition(cc.p(rightSize.width/2,containerSize.height-self.oneHeight/2-(index-1)*self.oneHeight-1))
            ScrollView : addChild(OneReward)
        end

        index=index+1
    end

    local firstEnd=zongzhi>3 and 3 or zongzhi
    for i=1,firstEnd do
        nFun()
    end
    self.m_mySchedule=_G.Scheduler:schedule(nFun,0)

    -- for k,v in pairs(_data.msg2) do
    --     local OneReward = self : Widgetreturn(_tag,v)
    --     OneReward : setPosition(rightSize.width/2,containerSize.height-self.oneHeight/2-2-(k-1)*self.oneHeight)
    --     ScrollView : addChild(OneReward)
    -- end
end

function DBCZRebateView.Widgetreturn(self,_tag,msg)
    print("===============>>>>>",msg.state,msg.id_sub)
    local Widget = ccui.Scale9Sprite : createWithSpriteFrameName("general_noit.png")
    Widget : setContentSize(cc.size(rightSize.width-10,self.oneHeight-4))

    local RMB = "100"
    local icondata = nil
    for k,v in pairs(self.msg.msg2) do
        if msg.id_sub == v.id_sub then
            print(k,v.id_sub,v.value)
            RMB = v.value
            local tab = {}
            for i=1,#v.msg do
            	tab[i]={v.msg[i].id,v.msg[i].num}
            end
            icondata = tab
        end
    end

    local addupLab = _G.Util : createLabel("单笔充值：", FONTSIZE)
    -- addupLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
    addupLab : setPosition(20, self.oneHeight-23)
    addupLab : setAnchorPoint(cc.p(0.0,0.5))
    Widget : addChild(addupLab)

    local labWidth=addupLab:getContentSize().width
    local numberLab = _G.Util : createLabel(RMB.."钻石", FONTSIZE)
    numberLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    numberLab : setPosition(20+labWidth, self.oneHeight-23)
    numberLab : setAnchorPoint(cc.p(0.0,0.5))
    Widget : addChild(numberLab)

    local roleBg = {1,2,3,4}
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
            -- print("－－－－Position.y",Position.y,m_winSize.height/2+rightSize.height/2-95,m_winSize.height/2-rightSize.height/2-15)
            if Position.y > m_winSize.height/2+rightSize.height/2-95 or
               Position.y < m_winSize.height/2-rightSize.height/2-15 
               or role_tag <= 0 then return end
            local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
        end 
    end

    for j=1, 4 do
        roleBg[j] = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
        roleBg[j] : setPosition(cc.p(60+(j-1)*(iconSize.width+20), self.oneHeight/2-15))
        Widget : addChild(roleBg[j])

        -- local goods = icondata.goods[j]
        if icondata~=nil and icondata[j] ~= nil then
            print("请求物品图片", icondata[j][1],icondata[j][2])
            local goodId      = icondata[j][1]
            local goodCount   = icondata[j][2]
            local goodsdata   = _G.Cfg.goods[goodId]
            if goodsdata ~= nil then
                local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,roleCallBack,goodId,goodCount)
                iconSpr       : setSwallowTouches(false)
                iconSpr       : setPosition(iconSize.width/2, iconSize.height/2)
                roleBg[j]     : addChild(iconSpr)
            end
        end   
    end

    local function onButtonCallBack(sender, eventType)
        self : onBtnCallBack(sender, eventType,_tag)
    end

    local drawBtn = gc.CButton : create("general_btn_gold.png")
    drawBtn : setTitleText("领 取")
    drawBtn : setTag(msg.id_sub)
    drawBtn : setTitleFontName(_G.FontName.Heiti)
    drawBtn : setTitleFontSize(FONTSIZE+4)
    drawBtn : setPosition(cc.p(rightSize.width-95, self.oneHeight/2-10))
    drawBtn : addTouchEventListener(onButtonCallBack)
    --drawBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    Widget  : addChild(drawBtn)

    if msg.state==1 then
        drawBtn : setEnabled(false)
        drawBtn : setBright(false)
    end

    self.OneWidget[msg.id_sub] = {}
    self.OneWidget[msg.id_sub].Btn = drawBtn

    return Widget
end

function DBCZRebateView.onBtnCallBack(self, sender, eventType, _tag)
    if eventType == ccui.TouchEventType.ended then
        local widTag = sender : getTag()
        local Position=sender : getWorldPosition()
        print("点击领取",_tag,widTag)
        -- print("－－－－Position.y",Position.y)
        if Position.y > m_winSize.height/2+rightSize.height/2-95 or
           Position.y < m_winSize.height/2-rightSize.height/2-15 
           or widTag <= 0 then return end

        local msg = REQ_ART_CONSUME_GET()
        msg:setArgs(_tag, widTag)
        _G.Network:send(msg)
    end
end

function DBCZRebateView.tagfullData(self, id_sub,state)
    print("刷新",id_sub,state)
    if state == 1 then
        self.OneWidget[id_sub].Btn : setEnabled(false)
        self.OneWidget[id_sub].Btn : setBright(false)
    end
    self.Num = self.Num + 1
    self.rechargeLab : setString(self.Num.."/"..self.Zong)
end

function DBCZRebateView.getTimeStr( self, _time)
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

function DBCZRebateView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return DBCZRebateView