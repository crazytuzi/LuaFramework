local ZLPHRebateView = classGc(view, function(self)

end)

local subCfg = _G.Cfg.sales_sub
local FONTSIZE  = 20
local m_winSize = cc.Director:getInstance():getVisibleSize()
local rightSize = cc.size(622,517)
local iconSize  = cc.size(78,78)

function ZLPHRebateView.create(self,tag,_data)
    print("----->>data",_data.count,_data.endtime)
    local endtime = self : getTimeStr(_data.endtime) or ""
    local startime = self : getTimeStr(_data.start) or ""
	self.m_container = cc.Node:create() 

	local MyStr= _G.Util : createLabel("我的排行：", FONTSIZE)
    -- MyStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    MyStr : setPosition(35, 16)
    self.m_container : addChild(MyStr)

    local endTimeStr = _G.Util : createLabel("活动时间：", FONTSIZE)
    -- endTimeStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    endTimeStr : setPosition(35, 50)
    self.m_container : addChild(endTimeStr)

    local TipsStr = _G.Util : createLabel("活动结束后通过邮件发放奖励", FONTSIZE)
    TipsStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    TipsStr : setPosition(rightSize.width/2+125, 16)
    self.m_container : addChild(TipsStr)

    local myNo = _data.selfrank or "100+"
    local cmp = _data.cmp or 0
    if myNo == 0 then myNo = "100+" end
    local MyLab = _G.Util : createLabel(string.format("%s（战力%s）",myNo,cmp), FONTSIZE)
    MyLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    MyLab : setPosition(90, 16)
    MyLab : setAnchorPoint(cc.p(0.0,0.5))
    self.m_container : addChild(MyLab)


    local endTimeLab  = _G.Util : createLabel(string.format("%s~%s",startime,endtime), FONTSIZE)
    endTimeLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    endTimeLab  : setPosition(90, 50)
    endTimeLab  : setAnchorPoint(cc.p(0.0,0.5))
    self.m_container : addChild(endTimeLab)

    local floorSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    floorSpr:setContentSize(cc.size(rightSize.width,rightSize.height-88))
    floorSpr:setPosition(289,-223)
    self.m_container : addChild(floorSpr)

    self : ScrollView(tag,_data)
    return self.m_container
end

function ZLPHRebateView.ScrollView(self,tag,_data)
    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView = ScrollView

    local zongzhi = 0
    local sub_id  = {}
    local msgdata = {}
    for k,v in pairs(subCfg) do
        -- if tag == v.id then
            zongzhi = zongzhi+1
            sub_id[zongzhi] = {}
            sub_id[zongzhi].sub=v.id_sub
            if _data.msg[zongzhi]~=nil then
                msgdata[zongzhi] = _data.msg[zongzhi].name
            end
            print("sdasdasdasd====>>>",zongzhi,sub_id[zongzhi]) 
        -- end
    end
    local function sort(m1,m2)
        if m1.sub < m2.sub then
            print("paixu",m1.sub,m2.sub)
            return true
        end
        return false
    end
    table.sort( sub_id, sort )
    print("zuidazhi",zongzhi)
    self.oneHeight = (rightSize.height-95)/3
    local viewSize = cc.size(rightSize.width, rightSize.height-95)
    local containerSize = cc.size(rightSize.width, self.oneHeight*zongzhi)

    ScrollView : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView : setViewSize(viewSize)
    ScrollView : setContentSize(containerSize)
    ScrollView : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    ScrollView : setPosition(-22, -434)
    print("容器大小：",self.oneHeight*zongzhi)
    ScrollView : setBounceable(false)
    ScrollView : setTouchEnabled(true)
    ScrollView : setDelegate()
    self.m_container : addChild(ScrollView)
    
    local barView=require("mod.general.ScrollBar")(ScrollView)
    barView:setPosOff(cc.p(-5,0))
    
    local index=1
    local function nFun()
        if index>zongzhi then
            self:__removeScheduler()
            return
        end

        if msgdata[index] then 
            local OneReward = self : Widgetreturn(msgdata[index],sub_id[index].sub)
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
    
    -- for i=1,zongzhi do
    --     local OneReward = self : Widgetreturn(msgdata[i],sub_id[i].sub)
    --     OneReward : setPosition(cc.p(rightSize.width/2,containerSize.height-self.oneHeight/2-2-(i-1)*self.oneHeight))
    --     ScrollView : addChild(OneReward)
    -- end
end

function ZLPHRebateView.Widgetreturn(self,name,sub_id)
    local Widget = ccui.Scale9Sprite : createWithSpriteFrameName("general_noit.png")
    Widget : setContentSize(cc.size(rightSize.width-10,self.oneHeight-4))

    local Num = nil
    local icondata = nil
    local exNum  = nil
    local exdata = nil
    for k,v in pairs(subCfg) do
        if sub_id == v.id_sub then
            print("Widgetreturn",k,sub_id,v.id_sub,v.value)
            Num = v.value
            icondata = v.virtue
            exNum = v.ex_value
            exdata= v.ex_virtue
        end
    end

    local roleName = name or "位置暂缺"
    local addupLab = _G.Util : createLabel("战力排行第"..Num.."名：", FONTSIZE)
    addupLab : setPosition(20, self.oneHeight-23)
	addupLab : setAnchorPoint(cc.p(0.0,0.5))
    Widget : addChild(addupLab)

    local labWidth=addupLab:getContentSize().width
    local numberLab = _G.Util : createLabel(roleName, FONTSIZE)
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
            -- print("－－－－Position.y",Position.y)
            if Position.y > m_winSize.height/2+rightSize.height/2-95 or
               Position.y < m_winSize.height/2-rightSize.height/2-15 
               or role_tag <= 0 then return end
            local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
        end 
    end

    for j=1, 4 do
        roleBg[j] = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
        roleBg[j] : setPosition(60+(j-1)*(iconSize.width+20), self.oneHeight/2-15)
        Widget : addChild(roleBg[j])

        if icondata~=nil and icondata[j] ~= nil then
            print("请求物品图片", icondata[j][1])
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

    return Widget
end

function ZLPHRebateView.getTimeStr( self, _time)
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

function ZLPHRebateView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return ZLPHRebateView