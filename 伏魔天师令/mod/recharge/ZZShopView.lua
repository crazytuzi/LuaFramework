local ZZShopView = classGc(view, function(self)
    self.pMediator = require("mod.recharge.ZZShopMediator")()
    self.pMediator : setView(self)
    self.lvPrivilege = 1 
end)

local FONTSIZE = 20
local R_COUNT  = 6 --总数
local R_ROWNO  = 3 --列数
local VIPMAX  = _G.Const.CONST_VIP_MOST_LV --vip最高级
local m_winSize  = cc.Director:getInstance():getVisibleSize()
local rightbgSize = cc.size(600, 425)
local rdownSize   = cc.size(620,430)
function ZZShopView.create(self)
    self.m_container  = cc.Node:create()

    local logoSpr = _G.ImageAsyncManager:createNormalSpr("ui/bg/recharge_zzshop.png")
    logoSpr : setPosition(110,182)
    self.m_container  : addChild(logoSpr)

    local floorSpr  = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
    floorSpr        : setPreferredSize(cc.size(rdownSize.width+2,rdownSize.height-25))
    floorSpr        : setPosition(110, -46)
    self.m_container : addChild(floorSpr)

    local moneybgSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_friendbg.png")
    moneybgSpr       : setPreferredSize(cc.size(rdownSize.width+5, 55))
    moneybgSpr       : setPosition(cc.p(110,-270))
    self.m_container : addChild(moneybgSpr) 

    local moneySpr   = cc.Sprite : createWithSpriteFrameName("general_zhizun.png")
    moneySpr         : setPosition(cc.p(rdownSize.width-110, 18))
    moneybgSpr : addChild(moneySpr)

    -- local ORANGE = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
    self.moneyLab    = _G.Util:createLabel("", FONTSIZE )
    self.moneyLab    : setAnchorPoint(cc.p(0,0.5))
    self.moneyLab    : setPosition(rdownSize.width-90, 18)
    -- self.moneyLab    : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    moneybgSpr : addChild(self.moneyLab)

    local page_bg  = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
    page_bg        : setPreferredSize(cc.size(70,35))
    page_bg        : setPosition(rdownSize.width/2, 22)
    moneybgSpr : addChild(page_bg)

    local pageSize = page_bg : getContentSize()

    self.pageLab   = _G.Util : createLabel("", FONTSIZE)
    self.pageLab   : setPosition(pageSize.width/2, pageSize.height/2)
    -- self.pageLab   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
    page_bg        : addChild(self.pageLab)

--  初始化
    self : updateMoneyTab()
    self : PageNetWorkSend(70,7010)
    return self.m_container
end

function ZZShopView.pushData(self, _data)     --mediator传过来的数据
    print("_data-->", _data.type,_data.type_bb,_data.count,_data.goods_msg_no)
    self.m_PageView = self : ShopPageView(_data.type,_data.type_bb,_data.count,_data.goods_msg_no)
    print("shoptagNode",self.m_container,self.m_PageView)
    self.m_container : addChild(self.m_PageView)
end

function ZZShopView.ShopPageView(self, type, type_bb, pagecount, msg)
    if msg == nil then return end

    local pageView = ccui.PageView : create()
    pageView       : setTouchEnabled(true)
    pageView       : setSwallowTouches(true)
    pageView       : setContentSize(cc.size(rdownSize.width-2,rdownSize.height))
    pageView       : setPosition(cc.p(-199, -270))
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
        layout : setContentSize(rdownSize)
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
            local posX = rdownSize.width/4-51+205*(addColum-1)
            local posY = rdownSize.height-110-198*(addRowNo-1)
            if m_oneGood == nil then return end
            m_oneGood : setPosition(posX,posY)
            layout : addChild(m_oneGood)
        end

        pageView : addPage(layout)
    end

    return pageView
end

function ZZShopView.ShopOneKuang( self,type,type_bb, Num, _data)
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

    local shopSpr  = ccui.Button : create("vip_zzshopbg.png","vip_zzshopbg.png","vip_zzshopbg.png",1)
    -- shopSpr : loadTextures("general_shopkuang.png")
    shopSpr : setTag(Num)
    shopSpr : addTouchEventListener(WidgetCallback)
    shopSpr : setScale9Enabled(true)
    self.shopSize = shopSpr : getContentSize()
    -- shopSpr       : setContentSize(cc.size(self.shopSize.width-2, self.shopSize.height))
    shopSpr       : setPosition(cc.p(self.shopSize.width/2, self.shopSize.height/2))

    local roleRmb = _data.s_price
    local rolename = icondata.name
    print("物品ID、名、价格、限购次数", goods_id,rolename,roleRmb,_data.state)
    local huobiImg = "general_zhizun.png"
    local jade = cc.Sprite : createWithSpriteFrameName(huobiImg)
    jade    : setPosition(cc.p(self.shopSize.width/2-20, 18))
    shopSpr : addChild(jade)

    local ORANGE = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
    local jadeLab = _G.Util : createLabel(roleRmb, FONTSIZE,ORANGE)
    jadeLab : setPosition(self.shopSize.width/2, 17)
    jadeLab : setAnchorPoint( cc.p(0.0,0.5) )
    shopSpr : addChild(jadeLab)

    local roleLab = _G.Util : createLabel(rolename, FONTSIZE)
    roleLab       : setPosition(self.shopSize.width/2, self.shopSize.height-18)
    roleLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    shopSpr       : addChild(roleLab)

    local roleImg = ccui.Scale9Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
    roleImg       : setPosition(cc.p(self.shopSize.width/2, self.shopSize.height/2))
    shopSpr       : addChild(roleImg)

    local roleSize= roleImg : getContentSize()
    local iconSpr = _G.ImageAsyncManager:createGoodsSpr(icondata)
    iconSpr       : setPosition(cc.p(roleSize.width/2,roleSize.height/2))
    roleImg       : addChild(iconSpr)

    return shopSpr
end

function ZZShopView.BuyTipsView(self,type,type_bb, tag, _data)
    if _data==nil or _data.msg==nil then return end
    print("_data.msg", _data,_data.msg)
    local goods_id = _data.msg.goods_id
    local icondata = _G.Cfg.goods[goods_id]
    local rmbcount= _data.s_price
    if icondata == nil then return end

    local function local_ensureFun( _num )
        local count = self.NumberTipsBox:getBuyNum()
        local xhcount = tonumber(count)
        print("购买",type_bb,_data.idx,goods_id,xhcount,_data.type)
        local msg = REQ_SHOP_BUY()
        msg :setArgs(type,type_bb,_data.idx,goods_id,xhcount,_data.type) 
        _G.Network : send(msg)
    end

    self.m_maxNum  = math.floor(self.zhizuns/_data.s_price)
    print("self.m_maxNum",self.zhizuns,_data.s_price, self.m_maxNum)
    local maxCount = icondata.stack
    if self.m_maxNum > maxCount then
        self.m_maxNum = maxCount
    elseif self.m_maxNum < 1 then
        self.m_maxNum = 1
    end

    self.NumberTipsBox    = require ("mod.general.NumberTipsBox")(goods_id,self.m_maxNum, 1, local_ensureFun )
    local tipsBoxContainer = self.NumberTipsBox :create(type_bb,rmbcount)
end

function ZZShopView.onPageCallBack(self, sender, eventType)
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

function ZZShopView.PageNetWorkSend(self,_type,_type_bb)
    --向服务器发送页面数据请求
    print("发送商店类型", _type, _type_bb)
    local msg = REQ_SHOP_REQUEST()
    msg : setArgs(_type,_type_bb)
    _G.Network : send(msg)
end

function ZZShopView.updateMoneyTab( self )
    self.zhizuns = _G.GBagProxy:getGoodsCountById(61000)
    self.moneyLab : setString(self.zhizuns)
    print("zhizuns",self.zhizuns)
end

function ZZShopView.SHOP_BUY_SUCC( self )
    self : updateMoneyTab()
    _G.Util:playAudioEffect("ui_receive_awards")
end

function ZZShopView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return ZZShopView