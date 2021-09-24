local GrabRedView = classGc(view, function(self)

end)

local FONTSIZE = 20
local R_COUNT  = 6 --总数
local R_ROWNO  = 3 --列数
-- local VIPMAX  = _G.Const.CONST_VIP_MOST_LV --vip最高级
local m_winSize = cc.Director:getInstance():getVisibleSize()
local rightSize = cc.size(622,517)
local iconSize  = cc.size(78,78)

function GrabRedView.create(self,_tag,_data)
    print("GrabRedViewdata",_data.endtime,_data.cmp,_data.count,_data.msg2)
    local endtime = self : getTimeStr(_data.endtime) or ""
    local startime = self : getTimeStr(_data.start) or ""

    self.m_container  = cc.Node:create()

    local logoSpr = _G.ImageAsyncManager:createNormalSpr("ui/bg/rebate_logo.png")
    logoSpr : setPosition(289,43)
    self.m_container : addChild(logoSpr)

    self.zhizuns=_data.cmp
    local endTimeStr = _G.Util : createLabel("活动时间：", FONTSIZE)
    -- endTimeStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    endTimeStr : setPosition(35, 58)
    self.m_container : addChild(endTimeStr)

    local endTimeLab  = _G.Util : createLabel(string.format("%s~%s",startime,endtime), FONTSIZE)
    endTimeLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    endTimeLab  : setPosition(90, 58)
    endTimeLab  : setAnchorPoint(cc.p(0.0,0.5))
    self.m_container : addChild(endTimeLab)

    local TipsStr = _G.Util : createLabel("充值会触发全服红包，红包可用于兑换物品。", FONTSIZE)
    TipsStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    TipsStr : setPosition(190, 33)
    self.m_container : addChild(TipsStr)

    local moneySpr   = cc.Sprite : createWithSpriteFrameName("general_hongbao.png")
    moneySpr         : setPosition(cc.p(rightSize.width-120, -415))
    self.m_container : addChild(moneySpr)

    self.moneyLab    = _G.Util:createLabel(_data.cmp or 0, FONTSIZE)
    self.moneyLab    : setAnchorPoint(cc.p(0,0.5))
    self.moneyLab    : setPosition(rightSize.width-100, -415)
    -- self.moneyLab    : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    self.m_container : addChild(self.moneyLab)

    local page_bg  = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
    page_bg        : setPreferredSize(cc.size(70,35))
    page_bg        : setPosition(289, -415)
    self.m_container : addChild(page_bg)

    local pageSize = page_bg : getContentSize()
    self.pageLab   = _G.Util : createLabel("", FONTSIZE)
    self.pageLab   : setPosition(pageSize.width/2, pageSize.height/2)
    -- self.pageLab   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    page_bg        : addChild(self.pageLab)

    local contentSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    contentSpr       : setPreferredSize(cc.size(622,410))
    contentSpr       : setPosition(289, -188)
    self.m_container : addChild(contentSpr)

--  初始化
    self : PageNetWorkSend(80,8010)
    return self.m_container
end

function GrabRedView.GrabData(self, _data)     --mediator传过来的数据
    print("_data-->", _data.type,_data.type_bb,_data.count,_data.goods_msg_no)
    self.m_PageView = self : ShopPageView(_data.type,_data.type_bb,_data.count,_data.goods_msg_no)
    print("shoptagNode",self.m_container,self.m_PageView)
    self.m_PageView : setPosition(-19,-500)
    self.m_container : addChild(self.m_PageView)
end

function GrabRedView.ShopPageView(self, type, type_bb, pagecount, msg)
    if msg == nil then return end

    local pageView = ccui.PageView : create()
    pageView       : setTouchEnabled(true)
    pageView       : setSwallowTouches(true)
    pageView       : setContentSize(cc.size(rightSize.width-5,rightSize.height))
    -- pageView       : setPosition(cc.p(5, 42))
    pageView       : setCustomScrollThreshold(50)
    pageView       : enableSound()
    local m_pageCount = math.ceil(pagecount/R_COUNT)
    -- if m_pageCount==1 then
    --     self.RightSpr:setVisible(false)
    -- end
    local pageStr = "1/"
    if m_pageCount < 1 then pageStr = "0/" end
    self.pageLab : setString(pageStr..m_pageCount)
    local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local m_nowPageCount = pageView : getCurPageIndex() + 1
            print("m_nowPageCount",m_nowPageCount)
            local pageInfo = string.format(" %d/%d ",m_nowPageCount,m_pageCount)
            self.pageLab : setString(pageInfo)
        end
    end
    pageView : addEventListener(pageViewEvent)

    print("self.m_pageCount:", pagecount,m_pageCount)
    if m_pageCount == nil or m_pageCount < 1 then m_pageCount = 1 end

    local m_goodNo = 0  --物品个数
    local curCount = 0
    for i=1, m_pageCount do
        local addRowNo  = 0 -- 第几行
        local addColum  = 0 -- 第几列
        local layout    = ccui.Layout : create()
        -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        layout : setContentSize(rightSize)
        -- layout:setBackGroundColor(cc.c3b(255, 100, 100))

        for ii=1, R_COUNT do
            curCount=curCount+1
            local goodData = msg[curCount]
            print("创建一页", goodData, msg, curCount)
            m_goodNo = m_goodNo + 1
            if m_goodNo > pagecount then break end
            local m_oneGood = self : ShopOneKuang(type,type_bb,m_goodNo,goodData)

            if ii % R_ROWNO == 1 then
                addColum = 0
                addRowNo = addRowNo + 1
            end
            addColum   = addColum + 1
            local posX = 102+206*(addColum-1)
            local posY = rightSize.height-106-202*(addRowNo-1)
            if m_oneGood == nil then return end
            m_oneGood : setPosition(posX,posY)
            layout : addChild(m_oneGood)
        end

        pageView : addPage(layout)
    end

    return pageView
end

function GrabRedView.ShopOneKuang( self,type,type_bb, Num, _data)
    print("创建物品框", Num, _data)
    local goods_id = _data.msg.goods_id
    local icondata = _G.Cfg.goods[goods_id]
    print("ssssss===>>>>",goods_id,icondata)
    if icondata == nil then return end
    local function WidgetCallback(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local role_tag = sender : getTag()
            print("弹出对应的购买框", role_tag)
            if role_tag < 0 then  return false end
            self : BuyTipsView(type,type_bb,role_tag,_data)
        end
    end

    local shopSize = cc.size(203,198)
    local shopSpr  = ccui.Button : create()
    shopSpr : loadTextures("general_shopkuang.png","general_shopkuang.png","general_shopkuang.png",1)
    shopSpr : setTag(Num)
    shopSpr : addTouchEventListener(WidgetCallback)
    shopSpr : setScale9Enabled(true)
    shopSpr : setContentSize(shopSize)

    local roleRmb = _data.s_price
    local rolename = icondata.name
    print("物品ID、名、价格、限购次数", goods_id,rolename,roleRmb,_data.state)
    local huobiImg = "general_hongbao.png"
    local jade = cc.Sprite : createWithSpriteFrameName(huobiImg)
    jade    : setPosition(cc.p(shopSize.width/2-20, 18))
    shopSpr : addChild(jade)

    local jadeLab = _G.Util : createLabel(roleRmb, FONTSIZE)
    jadeLab : setPosition(shopSize.width/2, 19)
    jadeLab : setAnchorPoint( cc.p(0.0,0.5) )
    shopSpr : addChild(jadeLab)

    local roleLab = _G.Util : createBorderLabel(rolename, FONTSIZE,_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
    roleLab       : setPosition(shopSize.width/2, shopSize.height-19)
    roleLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    shopSpr       : addChild(roleLab)

    local roleImg = ccui.Scale9Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
    roleImg       : setPosition(cc.p(shopSize.width/2, shopSize.height/2))
    shopSpr       : addChild(roleImg)

    local roleSize= roleImg : getContentSize()
    local iconSpr = _G.ImageAsyncManager:createGoodsSpr(icondata)
    iconSpr       : setPosition(cc.p(roleSize.width/2,roleSize.height/2))
    roleImg       : addChild(iconSpr)

    return shopSpr
end

function GrabRedView.BuyTipsView(self,type,type_bb, tag, _data)
    if _data==nil or _data.msg==nil then return end
    print("_data.msg", _data,_data.msg)
    local goods_id = _data.msg.goods_id
    local icondata = _G.Cfg.goods[goods_id]
    if icondata == nil then return end

    local loginStr = icondata.name
    local rolelv   = icondata.lv
    local content  = icondata.remark
    local rmbcount = _data.s_price

    self.m_maxNum  = math.floor(rmbcount/_data.s_price)
    print("self.m_maxNum",_data.s_price, self.m_maxNum)
    local maxCount = icondata.stack
    if self.m_maxNum > maxCount then
        self.m_maxNum = maxCount
    elseif self.m_maxNum < 1 then
        self.m_maxNum = 1
    end
    self.m_Num = 1
    
    local function buyCallBack(sender, eventType)
        print("购买",type,type_bb,_data.idx,goods_id,_data.type)
        local count = self.NumberTipsBox:getBuyNum()
        self.jiazhi = count
        local xhcount = tonumber(count)
        if xhcount == nil then
            local command = CErrorBoxCommand(9)
            controller : sendCommand( command )
            return
        end
        local msg = REQ_SHOP_BUY()
        msg :setArgs(type,type_bb,_data.idx,goods_id,xhcount,_data.type) --type,type_bb,idx,goodsId,Count,ctype
        _G.Network : send(msg)
    end

    self.NumberTipsBox    = require ("mod.general.NumberTipsBox")(goods_id,self.m_maxNum, 1, buyCallBack )
    local tipsBoxContainer = self.NumberTipsBox :create(type,rmbcount)
end

-- function GrabRedView.onPageCallBack(self, sender, eventType)
--     if eventType==ccui.TouchEventType.ended then
--         local btnTag = sender : getTag()
--         if btnTag == leftTag then
--             -- self.rightSpr : setVisible(true)
--             self.lvPrivilege = self.lvPrivilege - 1
--             if self.lvPrivilege-2 < 0 then
--                 self.lvPrivilege = 1
--             end
--             print("左:", self.lvPrivilege)
--         elseif btnTag == rightTag then
--             self.lvPrivilege = self.lvPrivilege + 1
--             if self.lvPrivilege+1 > VIPMAX then
--                 self.lvPrivilege = VIPMAX
--             end
--             print("右:", self.lvPrivilege)
--         end
--     end
-- end

function GrabRedView.getTimeStr( self, _time)
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

function GrabRedView.PageNetWorkSend(self,_type,_type_bb)
    --向服务器发送页面数据请求
    print("发送商店类型", _type, _type_bb)
    local msg = REQ_SHOP_REQUEST()
    msg : setArgs(_type,_type_bb)
    _G.Network : send(msg)
end

function GrabRedView.SHOP_BUY_SUCC( self )
    print("SHOP_BUY_SUCC==>",self.jiazhi,self.zhizuns)
    self.zhizuns=self.zhizuns-self.jiazhi
    self.moneyLab:setString(self.zhizuns)
    _G.Util:playAudioEffect("ui_receive_awards")
end

function GrabRedView.unregister(self)
    if self.pMediator then
       self.pMediator : destroy()
       self.pMediator = nil 
   end
end

function GrabRedView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return GrabRedView