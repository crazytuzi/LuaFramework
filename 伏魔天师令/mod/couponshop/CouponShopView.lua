local MONEY_JADE = 1
local MONEY_RMB  = 2
local R_ROWNO	 = 4 --列数
local PAGECOUNT  = 8
local FONTSIZE 	 = 20
local SHOPTYPE   = 60

local ONETAG = _G.Const.CONST_MALL_TYPE_SUB_MAGICS
-- local DAOTAG = _G.Const.CONST_MALL_TYPE_SUB_PROPS
-- local BAOTAG = _G.Const.CONST_MALL_TYPE_SUB_GEM
-- local LITAG = _G.Const.CONST_MALL_TYPE_SUB_PACKAGE
-- local YUANTAG = _G.Const.CONST_MALL_TYPE_SUB_INGOT
local SELECTALLTAG = 5000000
local m_winSize  = cc.Director:getInstance():getVisibleSize()
local _mainSize  = cc.size(846, 444)
local downSize   = cc.size(846,442)

local CouponShopView = classGc(view, function(self,_subType)
	self.pMediator = require("mod.couponshop.CouponShopMediator")()
    self.pMediator : setView(self)
	self.m_newGoodsArray={}
    self.widArray= {}
    print("_subType==",_subType)
    self.m_selectType=_subType or ONETAG
end)

-- local SYSID_ARRAY=
-- {
-- 	[ONETAG]=_G.Const.CONST_FUNC_OPEN_SHOP_HOT,
-- 	[DAOTAG]=_G.Const.CONST_FUNC_OPEN_SHOP_PROP,
-- 	[BAOTAG]=_G.Const.CONST_FUNC_OPEN_SHOP_GEM,
-- 	[LITAG]=_G.Const.CONST_FUNC_OPEN_SHOP_PACKAGE,
-- 	[YUANTAG]=_G.Const.CONST_FUNC_OPEN_SHOP_YUANBAO,
-- }

function CouponShopView.create(self)
	self.m_normalView=require("mod.general.TabUpView")()
	self.m_rootLayer=self.m_normalView:create("兑换商城",true)

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	local function closeFun()
		self:closeWindow()
	end

	local function tabBtnCallBack(tag)
		print("tabBtnCallBack",tag)
		self:onShopCallBack(tag)
		return true
	end
	self.m_normalView:addCloseFun(closeFun)
	self.m_normalView:addTabFun(tabBtnCallBack)
	self.m_normalView:addTabButton("神  器",ONETAG)
	-- self.m_normalView:addTabButton("道  具",DAOTAG)
	-- self.m_normalView:addTabButton("宝  石",BAOTAG)
	-- self.m_normalView:addTabButton("礼  包",LITAG)
	-- self.m_normalView:addTabButton("元  宝",YUANTAG)

	self.m_normalView : selectTagByTag(self.m_selectType)
	
	self : initView()
	self : updateMoneyTab()
	return tempScene
end

function CouponShopView.pushData(self, _data)     --mediator传过来的数据
    print("ShopMediator传过来的数据:", _data.type, _data.type_bb,_data.good_id,_data.count)
    	
    self:ShopPageView(_data.type_bb,_data.count,_data.msg)
    self.type = _data.type
    self.dazheId = _data.good_id
end

function CouponShopView.initView(self)
	self.m_mainNode = cc.Node:create()
	self.m_mainNode : setPosition(m_winSize.width*0.5,m_winSize.height*0.5)
	self.m_rootLayer: addChild(self.m_mainNode)

	self.up_kuang  = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
	self.up_kuang  : setPosition(0, -30)
	self.up_kuang  : setContentSize(cc.size(downSize.width, downSize.height))
	self.m_mainNode: addChild(self.up_kuang)

	local nowHaveLab = _G.Util : createLabel("当前拥有       ：", FONTSIZE)
	-- nowHaveLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
	nowHaveLab : setPosition(downSize.width-210, -25)
	nowHaveLab : setAnchorPoint(cc.p(0,0.5))
	self.up_kuang : addChild(nowHaveLab)

	local huobiImg= "general_artifact.png"
	local actiSpr = cc.Sprite : createWithSpriteFrameName(huobiImg)
	actiSpr 	  : setPosition(downSize.width-110, -22)
	self.up_kuang : addChild(actiSpr)

	local count  = _G.GBagProxy:getGoodsCountById(38500)
	self.actiLab = _G.Util : createLabel(count, FONTSIZE)
	self.actiLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
	self.actiLab : setPosition(downSize.width-80, -25)
	self.actiLab : setAnchorPoint(cc.p(0,0.5))
	self.up_kuang : addChild(self.actiLab)

	self.shoptagNode = {}
 	self : PageNetWorkSend(SHOPTYPE,self.m_selectType)
end

-- function CouponShopView.ShopScrollView( self, type_bb, pagecount, msg )
-- 	if msg == nil then return end
-- 	if self.shoptagNode[type_bb]==nil then
-- 		self.shoptagNode[type_bb]=cc.Node:create()
-- 		self.up_kuang : addChild(self.shoptagNode[type_bb])
-- 	  	local roleCount = math.ceil(pagecount/PAGECOUNT)

-- 	  	local kuangSize = self.up_kuang : getContentSize()
-- 	  	self.oneHeight = (kuangSize.height)/2
-- 	  	local viewSize = kuangSize
-- 	  	local scrollViewSize = cc.size(kuangSize.width,self.oneHeight*roleCount)

-- 		local contentView = cc.ScrollView:create()
-- 		contentView : setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
-- 		contentView : setViewSize(viewSize)
-- 		contentView : setContentSize(scrollViewSize)
-- 		contentView : setContentOffset( cc.p( 0,viewSize.height-scrollViewSize.height)) -- 设置初始位置
-- 		self.shoptagNode[type_bb] : addChild(contentView)
-- 		local barView=require("mod.general.ScrollBar")(contentView)
-- 		barView:setPosOff(cc.p(-7,0))

-- 		self.m_scrollView = contentView

-- 		local addRowNo = 0 -- 第几行
-- 		local addColum = 0 -- 第几列
-- 		local roleid = 1
-- 		for i=1,roleCount do
-- 		    for j=1,3 do
-- 		    	local goodData = msg[roleid]
-- 				local m_oneGood = self : ShopOneKuang(type_bb,roleid,goodData)
-- 				if j % 3 == 1 then
-- 					addColum = 0
-- 					addRowNo = addRowNo + 1
-- 				end
-- 				addColum = addColum + 1

-- 				if m_oneGood==nil then return end
-- 				local posX = self.shopSize.width/2+11+(self.shopSize.width+8)*(addColum-1)
-- 				local posY = scrollViewSize.height-self.shopSize.height/2-10-(self.shopSize.height+8)*(addRowNo-1)
-- 				m_oneGood : setPosition(posX,posY)
-- 				contentView : addChild(m_oneGood)
-- 				roleid = roleid + 1
-- 		    end
-- 		end
-- 	end
-- end

function CouponShopView.ShopPageView( self, type_bb, pagecount, msg)
    if msg == nil then return end
    if self.shoptagNode[type_bb]==nil then
		self.shoptagNode[type_bb]=cc.Node:create()
		self.up_kuang : addChild(self.shoptagNode[type_bb])
		local kuangSize = self.up_kuang : getContentSize()
	    local pageView = ccui.PageView : create()
	    pageView : setTouchEnabled(true)
	    pageView : setSwallowTouches(true)
	    pageView : setContentSize(cc.size(kuangSize.width-10,kuangSize.height))
	    pageView : setPosition(cc.p(4.5, 0))
	    pageView : setCustomScrollThreshold(50)
	    pageView : enableSound()
	    self.shoptagNode[type_bb] : addChild(pageView)

	    local page_bg = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
	    page_bg		  : setPreferredSize(cc.size(70,40))
		page_bg       : setPosition(downSize.width/2, -28)
		self.shoptagNode[type_bb] : addChild(page_bg)

		local pageSize = page_bg : getContentSize()
		-- local LeftSpr   = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
		-- LeftSpr   : setPosition(-15, pageSize.height/2)
		-- page_bg        : addChild(LeftSpr)

		-- local RightSpr  = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
		-- RightSpr  : setPosition(pageSize.width+15, pageSize.height/2)
		-- RightSpr  : setScale(-1)
		-- page_bg        : addChild(RightSpr)

		local pageLab = _G.Util : createLabel("", FONTSIZE)
		pageLab : setPosition(pageSize.width/2-3, pageSize.height/2-2)
		page_bg: addChild(pageLab)

	    local m_pageCount = math.ceil(pagecount/PAGECOUNT)
	    print("self.m_pageCount:", pagecount,m_pageCount)
	    if m_pageCount == nil or m_pageCount < 1 then m_pageCount = 1 end

	    local m_goodNo    = 0  --物品个数
	    local curCount=0
	    for i=1, m_pageCount do
	    	local addRowNo 	= 0 -- 第几行
	    	local addColum 	= 0 -- 第几列
	    	local layout   = ccui.Layout : create()
	    	-- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		    layout : setContentSize(kuangSize)
		    -- layout:setBackGroundColor(cc.c3b(255, 100, 100))

		    for ii=1, PAGECOUNT do
		    	curCount=curCount+1
		    	local goodData = msg[curCount]
		    	print("创建一页", goodData, msg, curCount)
		    	m_goodNo = m_goodNo + 1
		    	if m_goodNo > pagecount then break end
		    	local m_oneGood = self : ShopOneKuang(type_bb,m_goodNo,goodData)

				if ii % R_ROWNO == 1 then
			        addColum = 0
			        addRowNo = addRowNo + 1
		        end
		        addColum   = addColum + 1

		        if m_oneGood==nil then return end
		        local posX = self.shopSize.width/2+6+(self.shopSize.width+7)*(addColum-1)
		        local posY = kuangSize.height-self.shopSize.height/2-13-(self.shopSize.height+8)*(addRowNo-1)
		        print("Size===>>",posX,posY)
		        m_oneGood : setPosition(posX,posY)
				layout : addChild(m_oneGood)
			end
			pageView : addPage(layout)
		end
		local m_nowPageCount = 1
		pageLab : setString(string.format(" %d/%d ",m_nowPageCount,m_pageCount))
		-- if m_nowPageCount == 1 then
			-- LeftSpr:setVisible(false)
			-- if m_nowPageCount == m_pageCount then
		  		-- RightSpr:setVisible(false)
			-- end
		-- end
		local function pageViewEvent(sender, eventType)
		  	if eventType == ccui.PageViewEventType.turning then
		      	local pageView       = sender
		      	local m_nowPageCount = pageView : getCurPageIndex() + 1
		      	local pageInfo       = string.format(" %d/%d ",m_nowPageCount,m_pageCount)
		      	print("翻页", pageInfo)
		      	pageLab : setString(pageInfo)
		      	-- if m_nowPageCount == 1 then
					-- LeftSpr:setVisible(false)
					-- RightSpr:setVisible(true)
					-- if m_nowPageCount == m_pageCount then
		          		-- RightSpr:setVisible(false)
		        	-- end
		      	-- elseif m_nowPageCount == m_pageCount then
		        	-- LeftSpr:setVisible(true)
		        	-- RightSpr:setVisible(false)
		      	-- else
		        	-- LeftSpr:setVisible(true)
		        	-- RightSpr:setVisible(true)
		      	-- end
		  	end
		end
		pageView : addEventListener(pageViewEvent)
	end
end

function CouponShopView.ShopOneKuang( self,type_bb,Num,_data)
	print("创建物品框", Num, _data, _data.msg_xxx,_data.msg_xxx.goods_id)
	local goods_id = _data.msg_xxx.goods_id
	local icondata = _G.Cfg.goods[goods_id]
	local idx 	   = _data.idx
	print("icondata",icondata)
	if icondata == nil then return end

	local roleWid = ccui.Widget : create()	
	
	local shopSpr  = cc.Sprite : createWithSpriteFrameName("general_shopkuang.png")
	local shopSize = shopSpr : getContentSize()
	-- shopSpr        : setPreferredSize(cc.size(246, shopSize.height))
	self.shopSize  = shopSpr : getContentSize()
	print("Size",self.shopSize.width,self.shopSize.height)
	shopSpr : setPosition(cc.p(self.shopSize.width/2, self.shopSize.height/2))
	roleWid : setContentSize(self.shopSize)
	roleWid : setTouchEnabled(true)
	roleWid : setSwallowTouches(false)
	roleWid : setTag(Num)

	local function WidgetCallback(sender, eventType)
		if eventType==ccui.TouchEventType.began then
            shopSpr:setOpacity(180)
		elseif eventType == ccui.TouchEventType.ended then
			local role_tag = sender : getTag()
			local Position = sender : getWorldPosition()
      		print("Position.y",Position.y,m_winSize.width/2-downSize.width/2,m_winSize.width/2+downSize.width/2)
      		if Position.x > m_winSize.width/2+downSize.width/2 or Position.x < m_winSize.width/2-downSize.width/2
      	  	or role_tag <= 0 then return end
			print("弹出对应的购买框", role_tag)
			shopSpr:setOpacity(255)
			self : BuyTipsView(type_bb,role_tag,_data)
		elseif eventType==ccui.TouchEventType.canceled then
            shopSpr:setOpacity(255)
		end
	end
	roleWid : addTouchEventListener(WidgetCallback)
	roleWid : addChild(shopSpr)

	local rolename = icondata.name
	local roleLab  = _G.Util : createLabel(rolename, FONTSIZE)
	roleLab : setPosition(self.shopSize.width/2, self.shopSize.height-20)
	roleLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	roleWid : addChild(roleLab)

	local roleRmb = _data.s_price
	print("物品ID、名、价格", goods_id,rolename,roleRmb)
	local ORANGE = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
	local jadeLab = _G.Util : createLabel(roleRmb, FONTSIZE, ORANGE)
	jadeLab : setPosition(self.shopSize.width/2+13, 19)
	-- jadeLab : setAnchorPoint( cc.p(0.0,0.5) )
	-- jadeLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
	roleWid : addChild(jadeLab)

	local labWidth = jadeLab:getContentSize().width
	local huobiImg = "general_artifact.png"
	local jade = cc.Sprite : createWithSpriteFrameName(huobiImg)
	jade 	: setPosition(cc.p(self.shopSize.width/2-labWidth/2-7, 20))
	roleWid : addChild(jade)

	local roleImg = ccui.Scale9Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
	roleImg       : setPosition(cc.p(self.shopSize.width/2, self.shopSize.height/2))
	roleWid 	  : addChild(roleImg)

	local roleSize= roleImg : getContentSize()
	local iconSpr = _G.ImageAsyncManager:createGoodsSpr(icondata)
	iconSpr 	  : setPosition(cc.p(roleSize.width/2,roleSize.height/2))
    roleImg       : addChild(iconSpr)

	return roleWid
end

function CouponShopView.BuyTipsView(self,type_bb, tag, _data)
	local goods_id = _data.msg_xxx.goods_id
	local icondata = _G.Cfg.goods[goods_id]
	local nState=_data.state
	local rmbcount= _data.s_price
	if self.m_newGoodsArray[type_bb] then
		print("self.m_newGoodsArray[type_bb]",self.m_newGoodsArray[type_bb][_data.idx])
		if self.m_newGoodsArray[type_bb][_data.idx] then
			nState=self.m_newGoodsArray[type_bb][_data.idx].state
		end
	end
	if icondata == nil then return end
	
	self.m_maxNum = math.floor(self.playjades/rmbcount)
	if type_bb == 1050 then
		self.m_maxNum  = math.floor(self.playrmbs/rmbcount)
	elseif _data.discount == 1 and self.m_maxNum > 1 then
		self.m_maxNum = 1
	end

	print("self.m_maxNum", self.m_maxNum)
	local maxCount=icondata.stack
	if self.m_maxNum > maxCount then
		self.m_maxNum = maxCount
	elseif self.m_maxNum < 1 then
		self.m_maxNum = 1
	end

	if _data.state >= 0 then
		if self.m_maxNum > _data.state then
			self.m_maxNum = _data.state
		end
	end

	local function local_ensureFun( _num )
        local count = self.NumberTipsBox:getBuyNum()
    	local xhcount = tonumber(count)
		print("购买",type_bb,_data.idx,goods_id,xhcount,_data.type)
    	-- if xhcount == nil then
     --        local command = CErrorBoxCommand(9)
     --        controller : sendCommand( command )
     --        return
     --    end
		local msg = REQ_SHOP_BUY()
        msg :setArgs(self.type,type_bb,_data.idx,goods_id,xhcount,_data.type) 
        _G.Network : send(msg)
    end

	self.NumberTipsBox    = require ("mod.general.NumberTipsBox")(goods_id,self.m_maxNum, 1, local_ensureFun )
    local tipsBoxContainer = self.NumberTipsBox :create(self.type,rmbcount)

    print("_data.state",nState)
	if nState >= 0 then
		self.NumberTipsBox:setStateNum(nState)
	end

	print("打折卡优惠中",_data.discount,self.dazheId)
	if _data.discount == 1 and self.dazheId ~= 0 then
		self.NumberTipsBox:setDazheNow(self.dazheId)
	end
	
	-- local function buyCallBack(sender, eventType)
	--     if eventType == ccui.TouchEventType.ended then
	--     	local tip_tag = sender : getTag()
	--     	local num = self.numText : getString()
	--     	print("--self.numText---",num)
 --            num = string.match(num , "%d*")

	--     	if tip_tag == 1 then
	--     		print("减1",num)
	--     		num = tonumber( num )
	--     		if num ~= nil and num > 1 then
	--         		self.numText : setString( tostring(num-1) )
	-- 	        	local minusprice = tostring(rmbcount*tonumber(num-1))
	-- 		        print("minusprice", minusprice)
	-- 		        self.rmbxhLab : setString(minusprice)	        		
	--         	end
	--     	elseif tip_tag == 2 then
	--     		print("加1",num)
	--     		num = tonumber( num )
	--     		if num ~= nil and num < self.m_maxNum then
	--         		self.numText : setString( tostring(num+1) )
	--         		local addprice = tostring(rmbcount*tonumber(num+1))
	--             	print("addprice", addprice)
	--             	self.rmbxhLab : setString(addprice)	
	--         	end
	--     	elseif tip_tag == 3 then
	-- 	    	local szMaxNum = tostring(self.m_maxNum)
	--             self.numText : setString( szMaxNum )
	--     		print("最大", szMaxNum)
	--     		local maxsprice = tostring(rmbcount*tonumber(szMaxNum))
	--             print("maxsprice", maxsprice)
	--             self.rmbxhLab : setString(maxsprice)
	--     	end
	--     	local count = self.numText : getString()
	--     	local xhcount = tonumber(count)
	--     	if tip_tag == 4 then
	--     		print("购买",type_bb,_data.idx,goods_id,xhcount,_data.type)
	-- 	    	if xhcount == nil then
	--                 local command = CErrorBoxCommand(9)
	--                 controller : sendCommand( command )
	--                 return
	--             end
	-- 			local msg = REQ_SHOP_BUY()
	-- 	        msg :setArgs(self.type,type_bb,_data.idx,goods_id,xhcount,_data.type) 
	-- 	        _G.Network : send(msg)

	-- 	        buy_bg : removeFromParent(true)
 --        		buy_bg = nil
 --        		self.cishuLab=nil
	-- 	    elseif tip_tag == 5 then
	-- 	    	print("取消")
	-- 	    	buy_bg : removeFromParent(true)
	-- 	    	buy_bg = nil
	-- 	    	self.cishuLab=nil
	-- 	    end
	-- 	end
	-- end

	-- local function textFieldEvent(sender, eventType)
 --        if eventType == ccui.TextFiledEventType.insert_text then
 --            local num = self.numText : getString()
 --            print("--textFieldEvent---",num)
 --            local nums = string.match(num , "%d*")
            
 --            if tostring(num) ~= tostring(nums) then
 --                print("重新设置")
 --                self.numText : setString(tostring(self.m_Num))
 --                local command = CErrorBoxCommand(9)
 --                controller : sendCommand( command )
 --            end
 --            print("self.m_maxNum",self.m_maxNum)
 --            if tonumber (nums) > self.m_maxNum then
 --            	nums = tostring(self.m_maxNum)
 --            	self.numText : setString(tostring(nums))
 --            end

 --            self.m_Num=nums
 --            local szPrice = tostring(rmbcount*tonumber(nums))
 --            print("szPrice", szPrice)
 --            self.rmbxhLab : setString(szPrice)
 --        end
 --    end
 --    local inputSize= numSpr : getContentSize()
	-- self.numText   = ccui.TextField : create("",_G.FontName.Heiti,FONTSIZE)
 --    self.numText   : setTouchEnabled(true)
 --    self.numText   : setMaxLength(5)
 --    -- self.numText   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
 --    self.numText   : setPosition(cc.p(buybgSize.width*0.42, buybgSize.height/2-50))
 --    self.numText   : setString(tostring(self.m_Num))
 --    self.numText   : addEventListener(textFieldEvent)
 --    self.numText   : ignoreContentAdaptWithSize(false)
 --    self.numText   : setContentSize(cc.size(inputSize.width,inputSize.height))
 --    self.numText   : setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
 --    buy_bg    	   : addChild(self.numText) 

	-- local minusSpr = gc.CButton:create()
	-- minusSpr  	   : loadTextures("general_btn_reduce.png")
	-- minusSpr 	   : setPosition(buybgSize.width*0.19, buybgSize.height/2-45)
	-- minusSpr 	   : setTag(1)
	-- minusSpr	   : addTouchEventListener(buyCallBack)
	-- minusSpr	   : ignoreContentAdaptWithSize(false)
 --    minusSpr	   : setContentSize(cc.size(80,80))
	-- buy_bg  	   : addChild(minusSpr)

	-- local addSpr   = gc.CButton:create()
	-- addSpr  	   : loadTextures("general_btn_add.png")
	-- addSpr 	   	   : setPosition(buybgSize.width*0.64, buybgSize.height/2-45)
	-- addSpr 	   	   : setTag(2)
	-- addSpr	  	   : addTouchEventListener(buyCallBack)
	-- addSpr 		   : ignoreContentAdaptWithSize(false)
 --    addSpr 		   : setContentSize(cc.size(80,80))
	-- buy_bg  	   : addChild(addSpr)

	-- local maxSpr   = gc.CButton:create()
	-- maxSpr  	   : loadTextures("general_max.png")
	-- maxSpr 	   	   : setPosition(buybgSize.width*0.81, buybgSize.height/2-45)
	-- maxSpr 	   	   : setTag(3)
	-- maxSpr	   	   : addTouchEventListener(buyCallBack)
	-- maxSpr 	 	   : ignoreContentAdaptWithSize(false)
 --    maxSpr 		   : setContentSize(cc.size(80,80))
	-- buy_bg  	   : addChild(maxSpr)

	-- local buyBtn   = gc.CButton : create("general_btn_gold.png")
	-- buyBtn 		   : setTitleFontName(_G.FontName.Heiti)
	-- buyBtn 		   : setTitleText("确定")
	-- buyBtn 		   : setTitleFontSize(24)
	-- --buyBtn		   : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	-- buyBtn         : setPosition(buybgSize.width/2-85,35)
	-- buyBtn         : addTouchEventListener(buyCallBack)
	-- buyBtn		   : setTag(4)
	-- buy_bg         : addChild(buyBtn)

	-- local cancelBtn= gc.CButton : create("general_btn_lv.png")
	-- cancelBtn 	   : setTitleFontName(_G.FontName.Heiti)
	-- cancelBtn 	   : setTitleText("取消")
	-- cancelBtn	   : loadTextures("general_btn_lv.png")
	-- cancelBtn 	   : setTitleFontSize(24)
	-- cancelBtn      : setPosition(buybgSize.width/2+85,35)
	-- cancelBtn      : addTouchEventListener(buyCallBack)
	-- cancelBtn	   : setTag(5)
	-- buy_bg    	   : addChild(cancelBtn)
end

function CouponShopView.BUYFailureReturn(self)
	local szMsg="钻石不足，是否前往充值？"
	local function fun1()
		print("跳转到充值界面")
		self:closeWindow()
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_RECHARGE)
	end
	_G.Util:showTipsBox(szMsg,fun1)
end

function CouponShopView.SHOP_BUY_SUCC(self,_data)
	print("子商店、索引、限购次数",_data.type_bb,_data.idx,_data.state,_data.good_id)
	local huobi = self:updateMoneyTab() or 0
	self.actiLab:setString(huobi)
	_G.Util:playAudioEffect("ui_receive_awards")
end

function CouponShopView.PageNetWorkSend(self,_type,_type_bb)
    --向服务器发送页面数据请求
    local msg = REQ_SHOP_REQUEST()
    msg : setArgs(_type,_type_bb)
    _G.Network : send(msg)
end

function CouponShopView.onShopCallBack(self, shop_tag)
	if self.shoptagNode[shop_tag]==nil then
		self : PageNetWorkSend(SHOPTYPE,shop_tag)
	end
	print("切换到界面", shop_tag)
	local icondata = nil
    icondata = _G.Cfg.mall_class[SHOPTYPE]
    if icondata == nil then return end

	for k,v in pairs(icondata) do
		if k ~= shop_tag and self.shoptagNode[k]~=nil then
			print("非选中按钮", k)
	        self.shoptagNode[k] : setVisible(false)
	    elseif self.shoptagNode[k]~=nil then
	        print("选中按钮", k)
	        self.shoptagNode[shop_tag] : setVisible(true)
	    end
	end
end

function CouponShopView.updateMoneyTab( self )
	self.playrmbs = self : getPlayerData(MONEY_RMB) or 0
    print("playrmbs",self.playrmbs)
    self.playjades = self : getPlayerData(MONEY_JADE) or 0
    print("playjades",self.playjades)
end

function CouponShopView.getPlayerData( self,_CharacterName )
    local mainplay = _G.GPropertyProxy : getMainPlay()
    local CharacterValue = nil 
    if _CharacterName == MONEY_RMB then
        CharacterValue = mainplay : getBindRmb()
    elseif _CharacterName == MONEY_JADE then
        CharacterValue = mainplay : getRmb()
    end

    return CharacterValue
end

function CouponShopView.closeWindow(self)
	print("关闭商城")
	if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
	self : unregister()
	cc.Director:getInstance():popScene()
end

function CouponShopView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return CouponShopView