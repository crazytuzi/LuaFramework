local FZWMRebateView = classGc(view, function(self,_msg)
	self.msg = _msg
end)

local subCfg = _G.Cfg.sales_sub
local FONTSIZE  = 20
local m_winSize = cc.Director:getInstance():getVisibleSize()
local rightSize = cc.size(622,517)
local iconSize  = cc.size(78,78)

function FZWMRebateView.create(self,_tag,_data)
    print("----->>data",_data.endtime,_data.count,_data.cmp)
    local endtime = self : getTimeStr(_data.endtime) or ""
    local startime = self : getTimeStr(_data.start) or ""
	self.m_container = cc.Node:create()	

	local endTimeStr = _G.Util : createLabel("活动时间：", FONTSIZE)
	-- endTimeStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
	endTimeStr : setPosition(35, 50)
	self.m_container : addChild(endTimeStr)

	local rechargeStr= _G.Util : createLabel("我的VIP等级：", FONTSIZE)
	-- rechargeStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
	rechargeStr : setPosition(49,16)
	self.m_container : addChild(rechargeStr)

	local endTimeLab  = _G.Util : createLabel(string.format("%s~%s",startime,endtime), FONTSIZE)
	endTimeLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
	endTimeLab  : setPosition(90, 50)
	endTimeLab  : setAnchorPoint(cc.p(0.0,0.5))
	self.m_container : addChild(endTimeLab)

    local cmp = _data.cmp or 0
	self.rechargeLab = _G.Util : createLabel(cmp, FONTSIZE)
	self.rechargeLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	self.rechargeLab : setPosition(118,16)
	self.rechargeLab : setAnchorPoint(cc.p(0.0,0.5))
	self.m_container : addChild(self.rechargeLab)

    local floorSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    floorSpr:setContentSize(cc.size(rightSize.width,rightSize.height-88))
    floorSpr:setPosition(289,-223)
    self.m_container : addChild(floorSpr)

	self : networksend()
	return self.m_container
end

function FZWMRebateView.networksend( self )
    local msg = REQ_ART_FZTX_REQUEST()
    _G.Network : send( msg)
end

function FZWMRebateView.fzwmData(self,_data)
    print("fzwmData--->>>1",_data.count,_data.msg)
    for k,v in pairs(_data.msg) do
        print("fzwmData---》》2",k,v.count2,v.msg2)
    end
    self : ScrollView(_data)
end

function FZWMRebateView.ScrollView(self,_data)
    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView = ScrollView

    self.oneHeight = (rightSize.height-95)/2
    local viewSize = cc.size(rightSize.width, rightSize.height-95)
    local containerSize = cc.size(rightSize.width, self.oneHeight*_data.count)

    ScrollView : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView : setViewSize(viewSize)
    ScrollView : setContentSize(containerSize)
    ScrollView : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    ScrollView : setPosition(cc.p(-22, -434))
    print("容器大小：",self.oneHeight*_data.count)
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
    table.sort( _data.msg, sort )
    self.OneWidget = {}

    for k,v in pairs(_data.msg) do
    	local OneReward = self : Widgetreturn(v)
    	OneReward : setPosition(cc.p(rightSize.width/2,containerSize.height-self.oneHeight/2-(k-1)*self.oneHeight+1))
    	ScrollView : addChild(OneReward)
    end
end

function FZWMRebateView.Widgetreturn(self,v_data)
    print("Widgetreturn--->>>>",v_data.count2,v_data.id_sub,v_data.msg2)
	local Widget = ccui.Scale9Sprite : createWithSpriteFrameName("general_noit.png")
	Widget : setContentSize(cc.size(rightSize.width-10,self.oneHeight-4))

	local VIPLV = 8
    local icondata = nil
    for k,v in pairs(self.msg.msg2) do
        if v.id_sub == v_data.id_sub then
            print(v.id_sub,v.value)
            local tab = {}
            for i=1,#v.msg do
            	tab[i]={v.msg[i].id,v.msg[i].num}
            end
            icondata = tab
            VIPLV = v.value
        end
    end

    local vipSpr = cc.Sprite:createWithSpriteFrameName("general_vip.png")
    vipSpr : setPosition(40,self.oneHeight/2+22)
	Widget : addChild(vipSpr)

    local lvSpr = self:getTimeNumSpr(VIPLV)
    lvSpr : setPosition(55,self.oneHeight/2+22)
    Widget : addChild(lvSpr)

    local libaoLab = _G.Util : createLabel("礼包", FONTSIZE)
    libaoLab : setPosition(50,self.oneHeight/2-10)
    Widget : addChild(libaoLab)

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
            -- print("－－－－Position.y",Position.y)
            if Position.y > m_winSize.height/2+rightSize.height/2-95 or
               Position.y < m_winSize.height/2-rightSize.height/2-15 
               or role_tag <= 0 then return end
            local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
        end 
    end

    local function sort(m1,m2)
        if m1.idx < m2.idx then
            print("v_data.msg2",m1.idx,m2.idx)
            return true
        end
        return false
    end
    table.sort(v_data.msg2, sort )

    for k,v in pairs(v_data.msg2) do
        print("v_data.msg2",k,v.bool,v.viplv,v.times)
        roleBg[k] = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
        roleBg[k] : setPosition(cc.p(160+(k-1)*(iconSize.width+50), self.oneHeight/2+10))
        Widget : addChild(roleBg[k])

        if icondata~=nil and icondata[k] ~= nil then
            print("请求物品图片", icondata[k][1])
            local goodId      = icondata[k][1]
            -- local goodVip   = icondata[k][2]
            local goodsdata   = _G.Cfg.goods[goodId]
            if goodsdata ~= nil then
                local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,roleCallBack,goodId)
                iconSpr       : setSwallowTouches(false)
                iconSpr       : setPosition(iconSize.width/2, iconSize.height/2)
                roleBg[k]     : addChild(iconSpr)

                local uptipsLab = _G.Util : createLabel("所有人可领", FONTSIZE)
                uptipsLab : setPosition(iconSize.width/2,iconSize.height+30)
                -- uptipsLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_LBLUE))
                roleBg[k] : addChild(uptipsLab)
                if v.viplv>0 then 
                    uptipsLab:setString(string.format("VIP%d可领",v.viplv))
                end
            end
        end

        local function onButtonCallBack(sender, eventType)
            self : onBtnCallBack(sender, eventType,v_data.id_sub)
        end

        local drawBtn = gc.CButton : create("general_btn_gold.png")
        -- drawBtn : setButtonScale(0.8)
        drawBtn : setEnabled(false)
        drawBtn : setBright(false)
        drawBtn : setTag(v.viplv)
        drawBtn : setPosition(iconSize.width/2, -38)
        drawBtn : addTouchEventListener(onButtonCallBack)
        drawBtn : setTitleText(string.format("领 取(%d)",v.times))
        drawBtn : setTitleFontSize(22)
        drawBtn : setTitleFontName(_G.FontName.Heiti)
        roleBg[k] : addChild(drawBtn)

        print("可不可以领取",v.bool,v.times)
        if v.bool>0 and v.times>0 then
            drawBtn:setEnabled(true)
            drawBtn:setBright(true)
        end

        -- local drawSize = drawBtn:getContentSize()
        -- local ORANGE= _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
        -- local rewardLab = _G.Util : createLabel(), FONTSIZE+4)
        -- rewardLab : setPosition(drawSize.width/2,drawSize.height/2)
        -- rewardLab : setAnchorPoint(cc.p(0.0,0.5))
        -- drawBtn : addChild(rewardLab)

        self.OneWidget[v.idx] = {}
        self.OneWidget[v.idx].Btn = drawBtn
        self.OneWidget[v.idx].Lab = rewardLab
        print("self.OneWidget",self.OneWidget[v.idx].Btn,self.OneWidget[v.idx].Lab)
    end

    return Widget
end

function FZWMRebateView.onBtnCallBack(self, sender, eventType, id_sub)
	if eventType == ccui.TouchEventType.ended then
		local widTag = sender : getTag()
    	print("点击领取",id_sub,widTag)
        local Position=sender : getWorldPosition()
    	print("－－－－Position.y",Position.y,m_winSize.height/2+rightSize.height/2-95,m_winSize.height/2-rightSize.height/2-15)
        if Position.y > m_winSize.height/2+rightSize.height/2-95 or
           Position.y < m_winSize.height/2-rightSize.height/2-15 
           or widTag < 0 then return end
        local msg = REQ_ART_GET_FZTX()
        msg:setArgs(id_sub, widTag)
        _G.Network:send(msg)
	end
end

function FZWMRebateView.getTimeNumSpr( self, _Num )
    print("getTimeNumStr-->",_Num)
    local NumSprNode = cc.Node:create()
    local length = string.len(_Num)
    local spriteWidth = 0
    for i=1, length do
        local _tempSpr = cc.Sprite:createWithSpriteFrameName( "general_vipno_"..string.sub(_Num,i,i)..".png")
        NumSprNode : addChild( _tempSpr )

        local _tempSprSize = _tempSpr : getContentSize()
        spriteWidth        = spriteWidth + _tempSprSize.width / 2
        _tempSpr           : setPosition( spriteWidth,0)
    end

    return NumSprNode
end

function FZWMRebateView.fzwmReturnReward(self,idx,times)
    print("刷新",idx,times)
    if self.OneWidget[idx]==nil then return end
    if times <= 0 then
        print("判断次数为0")
        self.OneWidget[idx].Btn:setBright(false)
        self.OneWidget[idx].Btn:setEnabled(false)
        self.OneWidget[idx].Btn:setTitleText("领 取(0)")
    else
        print("判断次数为",times)
        self.OneWidget[idx].Btn:setTitleText(string.format("领 取(%d)",times))
    end
end

function FZWMRebateView.getTimeStr( self, _time)
    local time = os.date("*t",_time)
    print("time",_time)

    if time.month < 10 then time.month = "0"..time.month end
    if time.day < 10 then time.day = "0"..time.day end
    if time.hour < 10 then time.hour = "0"..time.hour
    elseif time.hour < 0 then time.hour = "00" end
    if time.min < 10 then time.min = "0"..time.min
    elseif time.min < 0 then time.min = "00" end

    local time  = time.year.."/"..time.month.."/"..time.day.." "..time.hour..":"..time.min
    print("endtime",endtime)

    return time
end

function FZWMRebateView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return FZWMRebateView