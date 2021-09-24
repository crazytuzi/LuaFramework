local TimeShopView = classGc(view, function(self)
    self.NowPage=1
end)

local FONTSIZE = 20
local R_COUNT  = 6 --总数
local R_ROWNO  = 3 --列数
-- local VIPMAX  = _G.Const.CONST_VIP_MOST_LV --vip最高级
local m_winSize = cc.Director:getInstance():getVisibleSize()
local rightSize = cc.size(622,517)
local iconSize  = cc.size(78,78)
local ORANGE = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
local BRIGHTYELLOW = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW)

function TimeShopView.create(self,_tag,_data)
    print("TimeShopViewdata",_data.endtime,_data.cmp,_data.count,_data.msg2)
    local endtime = self : getTimeStr(_data.endtime) or ""
    local startime = self : getTimeStr(_data.start) or ""

    self.m_container  = cc.Node:create()

    local logoSpr = _G.ImageAsyncManager:createNormalSpr("ui/bg/rebate_logo.png")
    logoSpr : setPosition(289,43)
    self.m_container : addChild(logoSpr)

    local endTimeStr = _G.Util : createLabel("活动时间：", FONTSIZE)
    -- endTimeStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    endTimeStr : setPosition(35, 58)
    self.m_container : addChild(endTimeStr)

    local endTimeLab  = _G.Util : createLabel(string.format("%s~%s",startime,endtime), FONTSIZE)
    endTimeLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    endTimeLab  : setPosition(90, 58)
    endTimeLab  : setAnchorPoint(cc.p(0.0,0.5))
    self.m_container : addChild(endTimeLab)

    local TipsStr = _G.Util : createLabel("活动期间将限时推出特价商品进行限量抢购", FONTSIZE)
    TipsStr : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    TipsStr : setAnchorPoint(cc.p(0.0,0.5))
    TipsStr : setPosition(-8, 33)
    self.m_container : addChild(TipsStr)

    local contentSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    contentSpr       : setPreferredSize(cc.size(622,410))
    contentSpr       : setPosition(289, -188)
    self.m_container : addChild(contentSpr)

    -- local moneySpr   = cc.Sprite : createWithSpriteFrameName("general_hongbao.png")
    -- moneySpr         : setPosition(cc.p(rightSize.width-110, -366))
    -- self.m_container : addChild(moneySpr)

    -- self.moneyLab    = _G.Util:createLabel(_data.cmp or 0, FONTSIZE, ORANGE)
    -- self.moneyLab    : setAnchorPoint(cc.p(0,0.5))
    -- self.moneyLab    : setPosition(rightSize.width-90, -370)
    -- -- self.moneyLab    : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    -- self.m_container : addChild(self.moneyLab)

    -- local moneySize  = self.moneyLab : getContentSize()
    -- print("moneySize",moneySize.width)

    local page_bg  = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
    page_bg        : setPreferredSize(cc.size(70,35))
    page_bg        : setPosition(289, -415)
    self.m_container : addChild(page_bg)

    local pageSize = page_bg : getContentSize()
    -- self.LeftSpr   = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
    -- self.LeftSpr   : setPosition(-15, pageSize.height/2)
    -- self.LeftSpr   : setScale(0.9)
    -- self.LeftSpr   : setVisible(false)
    -- page_bg        : addChild(self.LeftSpr)

    -- self.RightSpr  = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
    -- self.RightSpr  : setPosition(cc.p(pageSize.width+15, pageSize.height/2))
    -- self.RightSpr  : setScale(0.9)
    -- self.RightSpr  : setRotation(180)
    -- page_bg        : addChild(self.RightSpr)

    self.pageLab   = _G.Util : createLabel("", FONTSIZE)
    self.pageLab   : setPosition(pageSize.width/2, pageSize.height/2)
    -- self.pageLab   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    page_bg        : addChild(self.pageLab)

--  初始化
    local shoptype=9010
    if _tag==372 then
        shoptype=9020
    elseif _tag==373 then
        shoptype=9030
    elseif _tag==374 then
        shoptype=9040
    end

    self : PageNetWorkSend(90,shoptype)
    return self.m_container
end

function TimeShopView.TimeShopData(self, _data)     --mediator传过来的数据
    print("_data-->", _data.type,_data.type_bb,_data.count,_data.msg)
    if self.m_PageView~=nil then
        self.m_PageView:removeFromParent(true)
        self.m_PageView=nil
    end
    self.m_PageView = self : ShopPageView(_data.type,_data.type_bb,_data.count,_data.msg)
    print("shoptagNode",self.m_container,self.m_PageView)
    self.m_PageView : setPosition(-19,-500)
    print("self.NowPage",self.NowPage)
    self.m_PageView : scrollToPage(self.NowPage-1)
    self.m_container : addChild(self.m_PageView)
end

function TimeShopView.ShopPageView(self, type, type_bb, pagecount, msg)
    if msg == nil then return end

    local pageView = ccui.PageView : create()
    pageView       : setTouchEnabled(true)
    pageView       : setSwallowTouches(true)
    pageView       : setContentSize(cc.size(rightSize.width-5,rightSize.height))
    -- pageView       : setPosition(cc.p(-5, 0))
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

            self.NowPage=m_nowPageCount
            -- if m_nowPageCount==1 then
            --     self.LeftSpr:setVisible(false)
            --     self.RightSpr:setVisible(true)
            --     if m_pageCount==1 then
            --         self.RightSpr:setVisible(false)
            --     end
            -- elseif m_nowPageCount==m_pageCount then
            --     self.LeftSpr:setVisible(true)
            --     self.RightSpr:setVisible(false)
            -- else
            --     self.LeftSpr:setVisible(true)
            --     self.RightSpr:setVisible(true)
            -- end
        end
    end
    
    pageView : addEventListener(pageViewEvent)

    print("self.m_pageCount:", pagecount,m_pageCount)
    if m_pageCount == nil or m_pageCount < 1 then m_pageCount = 1 end

    self.btnArray = {}
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

function TimeShopView.ShopOneKuang( self,type,type_bb, Num, _data)
    print("创建物品框", Num, _data)
    local goods_id = _data.msg_xxx.goods_id
    local icondata = _G.Cfg.goods[goods_id]
    local idx=_data.idx
    print("ssssss===>>>>",goods_id,icondata)
    if icondata == nil then return end

    local function WidgetCallback(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local m_idx = sender : getTag()
            print("弹出对应的购买框", m_idx)
            if m_idx < 0 then return false end
            self : BuyTipsView(type,type_bb,_data)
        end
    end

    local shopSize = cc.size(203,198)
    local shopSpr  = ccui.Button:create("general_shopkuang.png","general_shopkuang.png","general_shopkuang.png",1)
    shopSpr : addTouchEventListener(WidgetCallback)
    shopSpr : setSwallowTouches(false)
    shopSpr : setTag(idx)
    shopSpr : setScale9Enabled(true)
    shopSpr : setContentSize(shopSize)

    local StrLab = _G.Util : createLabel("剩余", FONTSIZE)
    StrLab : setPosition(shopSize.width-33, shopSize.height/2+10)
    -- StrLab : setAnchorPoint( cc.p(0.0,0.5) )
    -- StrLab : setColor(BRIGHTYELLOW)
    shopSpr : addChild(StrLab)

    local numsLab = _G.Util : createLabel(_data.total_remaider_num, FONTSIZE)
    numsLab : setPosition(shopSize.width-33, shopSize.height/2-13)
    numsLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    -- numsLab : setAnchorPoint( cc.p(0.0,0.5) )
    shopSpr  : addChild(numsLab)

    local hotImg="shop_qiang.png"
    if _data.total_remaider_num<=0 then 
        numsLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
        hotImg="shop_wan.png" 
    end
    local shop_hot = cc.Sprite : createWithSpriteFrameName(hotImg)
    shop_hot : setPosition(36, shopSize.height-29)
    shop_hot : setVisible(false)
    shopSpr  : addChild(shop_hot,10)

    local roleRmb = _data.s_price
    -- if _data.s_price~=_data.v_price then roleRmb = _data.v_price end
    local rolename = icondata.name
    print("物品ID、名、价格、限购次数", goods_id,rolename,roleRmb,_data.state,_data.type)
    -- local goldImg = "general_gold.png"
    -- local jade = cc.Sprite : createWithSpriteFrameName(goldImg)
    -- jade    : setPosition(cc.p(shopSize.width/2-25, 25))
    -- shopSpr : addChild(jade)

    -- local jadeLab = _G.Util : createLabel(roleRmb, FONTSIZE,ORANGE)
    -- jadeLab : setPosition(shopSize.width/2, 25)
    -- jadeLab : setAnchorPoint( cc.p(0.0,0.5) )
    -- shopSpr : addChild(jadeLab)

    local roleLab = _G.Util : createBorderLabel(rolename, FONTSIZE,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    roleLab       : setPosition(shopSize.width/2, shopSize.height-19)
    roleLab       : setColor(BRIGHTYELLOW)
    shopSpr       : addChild(roleLab)

    if roleRmb == _data.v_price then
        -- local ORANGE = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
        local jadeLab = _G.Util : createLabel(roleRmb, FONTSIZE)
        jadeLab : setPosition(shopSize.width/2+13, 19)
        -- jadeLab : setAnchorPoint( cc.p(0.0,0.5) )
        -- jadeLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
        shopSpr : addChild(jadeLab)

        local labWidth = jadeLab:getContentSize().width
        local huobiImg = "general_xianYu.png"
        if _data.type == 3 then
            huobiImg   = "general_gold.png"
        elseif _data.type == 1 then
            huobiImg   = "general_tongqian.png"
        elseif _data.type == 21 then
            huobiImg   = "general_zhizun.png"
        end
        local jade = cc.Sprite : createWithSpriteFrameName(huobiImg)
        jade    : setPosition(cc.p(shopSize.width/2-labWidth/2-7, 20))
        shopSpr : addChild(jade)

        shop_hot:setVisible(true)
    end

    if roleRmb ~= _data.v_price then
        local jadeLab1 = _G.Util : createLabel(_data.v_price, FONTSIZE)
        jadeLab1 : setPosition(shopSize.width/2, 19)
        jadeLab1 : setAnchorPoint( cc.p(1,0.5) )
        jadeLab1 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
        shopSpr  : addChild(jadeLab1)

        local rmbSize  = jadeLab1 : getContentSize()
        local line = cc.DrawNode : create()--绘制线条
        line     : drawLine(cc.p(0,2), cc.p(rmbSize.width+8,2), cc.c4f(0.6,0.2,0.3,1))
        line     : setPosition(shopSize.width/2-rmbSize.width-5, 17)
        line : setAnchorPoint( cc.p(1,0.5) )
        shopSpr  : addChild(line,2)

        -- local ORANGE = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
        local jadeLab2 = _G.Util : createLabel(roleRmb, FONTSIZE)
        jadeLab2 : setPosition(shopSize.width/2+15, 19)
        jadeLab2 : setAnchorPoint( cc.p(0.0,0.5) )
        -- jadeLab2 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
        shopSpr  : addChild(jadeLab2)

        local huobiImg = "general_xianYu.png"
        if _data.type == 3 then
            huobiImg   = "general_gold.png"
        elseif _data.type == 1 then
            huobiImg   = "general_tongqian.png"
        elseif _data.type == 21 then
            huobiImg   = "general_zhizun.png"
        end
        local jade = cc.Sprite : createWithSpriteFrameName(huobiImg)
        jade       : setPosition(cc.p(shopSize.width/2-rmbSize.width-20, 20))
        shopSpr    : addChild(jade)

        local zheNum   = math.floor(roleRmb*10/_data.v_price)
        local zheyuNum = (roleRmb*10/_data.v_price)%zheNum
        local yuNum   = math.floor(zheyuNum*100/10)
        if _data.total_remaider_num>0 then
            local shop_zhe = cc.Sprite : createWithSpriteFrameName("shop_zhe.png")
            shop_zhe : setPosition(cc.p(36, shopSize.height-29))
            shop_zhe : setVisible(false)
            shopSpr  : addChild(shop_zhe)
            
            local shop_num = cc.Sprite : createWithSpriteFrameName("shop_"..zheNum..".png")
            shop_num : setPosition(cc.p(17, shopSize.height-29))
            shop_num : setVisible(false)
            shop_num : setRotation(-45)
            shopSpr  : addChild(shop_num)

            
            print("多少折", zheNum,zheyuNum,yuNum)
            local strSpr = cc.Sprite : createWithSpriteFrameName("shop_zhestr.png")
            strSpr : setVisible(false)
            strSpr : setRotation(-45)
            strSpr : setPosition(cc.p(34, shopSize.height-16))
            shopSpr : addChild(strSpr)

            local shop_dian = cc.Sprite : createWithSpriteFrameName("shop_dian.png")
            shop_dian : setPosition(cc.p(21, shopSize.height-30))
            shop_dian : setVisible(false)
            shop_dian : setRotation(-45)
            shopSpr   : addChild(shop_dian)

            local shop_yu = cc.Sprite : create()
            shop_yu : setPosition(cc.p(23, shopSize.height-22))
            shop_yu : setVisible(false)
            shop_yu : setRotation(-45)
            shopSpr : addChild(shop_yu)

            if yuNum > 0 then
                shop_num  : setPosition(cc.p(13, shopSize.height-33))
                strSpr    : setPosition(cc.p(38, shopSize.height-12))
                shop_dian : setVisible(true)
                shop_yu   : setSpriteFrame("shop_"..yuNum..".png")
                shop_yu   : setVisible(true)
                shop_zhe : setVisible(true)
                shop_num : setVisible(true)
                strSpr   : setVisible(true)
            else 
                shop_zhe : setVisible(true)
                shop_num : setVisible(true)
                strSpr   : setVisible(true)
            end
        else
            shop_hot:setVisible(true)
        end  
    end

    self.btnArray[idx]={}
    self.btnArray[idx].Num=_data.total_remaider_num
    self.btnArray[idx].Lab=numsLab
    self.btnArray[idx].Spr=shop_hot

    local roleBtn = ccui.Scale9Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
    roleBtn  : setPosition(shopSize.width/2, shopSize.height/2)
    shopSpr  : addChild(roleBtn)

    local iconSpr = _G.ImageAsyncManager:createGoodsSpr(icondata)
    iconSpr       : setPosition(cc.p(iconSize.width/2,iconSize.height/2))
    roleBtn       : addChild(iconSpr)

    -- local function BuyCallback(sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         local buytag = sender : getTag()
    --         local Position = sender : getWorldPosition()
    --         print("Position.x",Position.x,m_winSize.width/2-rightSize.width/2)
    --         if Position.x > m_winSize.width/2+rightSize.width/2 or Position.x < m_winSize.width/2-rightSize.width/2
    --         or buytag <= 0 then return end
    --         print("弹出对应的购买框", buytag)
    --         -- local msg = REQ_SHOP_BUY()
    --         -- msg :setArgs(20,2010,idx,buytag,1,_data.type) 
    --         -- _G.Network : send(msg)
    --     end
    -- end

    -- local buyBtn = gc.CButton:create("general_btn_gold.png")
    -- buyBtn : setPosition(shopSize.width/2,26)
    -- buyBtn : addTouchEventListener(BuyCallback)
    -- buyBtn : setTitleText("抢购")
    -- buyBtn : setTitleFontName(_G.FontName.Heiti)
    -- buyBtn : setTitleFontSize(FONTSIZE+6)
    -- buyBtn : setButtonScale(0.8)
    -- --buyBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    -- buyBtn : setSwallowTouches(false)
    -- buyBtn : setTag(goods_id) 
    -- shopSpr : addChild(buyBtn)

    return shopSpr
end

function TimeShopView.BuyTipsView(self,type,type_bb, _data)
    if _data==nil or _data.msg_xxx==nil then return end
    print("_data.msg", _data,_data.msg_xxx)
    local goods_id = _data.msg_xxx.goods_id
    local icondata = _G.Cfg.goods[goods_id]
    if icondata == nil then return end


    local rmbcount = _data.s_price
    self.m_maxNum=1
    print("self.m_maxNum",rmbcount, self.m_maxNum)
    local maxCount = icondata.stack
    if self.m_maxNum > maxCount then
        self.m_maxNum = maxCount
    elseif self.m_maxNum < 1 then
        self.m_maxNum = 1
        self.rmbxhLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    end
    
    local function buyCallBack(sender, eventType)
        local count = self.NumberTipsBox:getBuyNum()
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
    local type=90
    print("_data.type",_data.type)
    if _data.type == 3 then
        type=1050
    elseif _data.type == 1 then
        type=1
    elseif _data.type == 21 then
        type=7010
    end

    self.NumberTipsBox    = require ("mod.general.NumberTipsBox")(goods_id,self.m_maxNum, 1, buyCallBack )
    local tipsBoxContainer = self.NumberTipsBox :create(type,rmbcount)

    print("_data.state",_data.state)
    if _data.state >= 0 then
        self.NumberTipsBox:setStateNum(_data.state)
    end
end

function TimeShopView.onPageCallBack(self, sender, eventType)
    if eventType==ccui.TouchEventType.ended then
        local btnTag = sender : getTag()
        if btnTag == leftTag then
            -- self.rightSpr : setVisible(true)
            self.lvPrivilege = self.lvPrivilege - 1
            if self.lvPrivilege-2 < 0 then
                self.lvPrivilege = 1
            end
            print("左:", self.lvPrivilege)
        elseif btnTag == rightTag then
            self.lvPrivilege = self.lvPrivilege + 1
            if self.lvPrivilege+1 > VIPMAX then
                self.lvPrivilege = VIPMAX
            end
            print("右:", self.lvPrivilege)
        end
    end
end

function TimeShopView.getTimeStr( self, _time)
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

function TimeShopView.PageNetWorkSend(self,_type,_type_bb)
    --向服务器发送页面数据请求
    print("发送商店类型", _type, _type_bb)
    local msg = REQ_SHOP_REQUEST()
    msg : setArgs(_type,_type_bb)
    _G.Network : send(msg)
end

function TimeShopView.SHOP_BUY_SUCC( self )
    -- print("SHOP_BUY_SUCC==>",self.m_idx)
    -- self.btnArray[self.m_idx].Num=self.btnArray[self.m_idx].Num-1
    -- self.btnArray[self.m_idx].Lab:setString(self.btnArray[self.m_idx].Num)
    -- if self.btnArray[self.m_idx].Num<=0 then
    --     self.btnArray[self.m_idx].Spr:setVisible(true)
    --     self.btnArray[self.m_idx].Lab:setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    -- end
    _G.Util:playAudioEffect("ui_receive_awards")
end

function TimeShopView.getPlayerData( self, _type )
    local mainplay = _G.GPropertyProxy : getMainPlay()
    local CharacterValue=nil
    if _type == 3 then
        CharacterValue = mainplay : getBindRmb()
    elseif _type == 2 then
        CharacterValue = mainplay : getRmb()
    elseif _type == 1 then
        CharacterValue = mainplay : getGold()
    elseif _type == 21 then
        CharacterValue = _G.GBagProxy:getGoodsCountById(61000)
    end
    return CharacterValue
end

function TimeShopView.unregister(self)
    if self.pMediator then
       self.pMediator : destroy()
       self.pMediator = nil 
   end
end

function TimeShopView.__removeScheduler(self)
    print("关闭__removeScheduler")
    if self.m_mySchedule~=nil then
        _G.Scheduler:unschedule(self.m_mySchedule)
        self.m_mySchedule=nil
    end
end

return TimeShopView