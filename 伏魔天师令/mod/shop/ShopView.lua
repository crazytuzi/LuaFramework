local MONEY_JADE = 1
local MONEY_RMB  = 2
local MONEY_YL=23
local R_ROWNO	 = 3 --列数
local PAGECOUNT  = 6
local SHOPTYPE   = 10
local FONTSIZE 	 = 20
local HOTTAG = _G.Const.CONST_MALL_TYPE_SUB_HOT
local DAOTAG = _G.Const.CONST_MALL_TYPE_SUB_PROPS
local BAOTAG = _G.Const.CONST_MALL_TYPE_SUB_GEM
local LITAG = _G.Const.CONST_MALL_TYPE_SUB_PACKAGE
local YUANTAG = _G.Const.CONST_MALL_TYPE_SUB_INGOT
local ARTITAG = _G.Const.CONST_MALL_TYPE_SUB_MAGICS
local LINGTAG = _G.Const.CONST_MALL_TYPE_SUB_LY
local SELECTALLTAG = 5000000
local m_winSize  = cc.Director:getInstance():getVisibleSize()
local _mainSize  = cc.size(846, 444)
local downSize   = cc.size(626,517)

local ShopView = classGc(view, function(self,_subType)
	self.pMediator = require("mod.shop.ShopMediator")()
    self.pMediator : setView(self)
	self.m_newGoodsArray={}
    self.widArray= {}
    print("_subType==",_subType)
    self.m_selectType=_subType or HOTTAG
end)

-- local SYSID_ARRAY=
-- {
-- 	[HOTTAG]=_G.Const.CONST_FUNC_OPEN_SHOP_HOT,
-- 	[DAOTAG]=_G.Const.CONST_FUNC_OPEN_SHOP_PROP,
-- 	[BAOTAG]=_G.Const.CONST_FUNC_OPEN_SHOP_GEM,
-- 	[LITAG]=_G.Const.CONST_FUNC_OPEN_SHOP_PACKAGE,
-- 	[YUANTAG]=_G.Const.CONST_FUNC_OPEN_SHOP_YUANBAO,
-- }

function ShopView.create(self)
	self.m_normalView=require("mod.general.TabLeftView")()
	self.m_rootLayer=self.m_normalView:create("商 城")

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	local function closeFun()
		self:closeWindow()
	end

	local function tabBtnCallBack(tag)
		print("tabBtnCallBack",tag)
		if tag==ARTITAG and _G.GOpenProxy:showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_SHOP_SHENQI) then return false end
		if tag==LINGTAG and _G.GOpenProxy:showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_SHOP_LINGYAO) then return false end
		self:onShopCallBack(tag)
		return true
	end
	self.m_normalView:addCloseFun(closeFun)
	self.m_normalView:addTabFun(tabBtnCallBack)
	self.m_normalView:addTabButton("热  卖",HOTTAG)
	self.m_normalView:addTabButton("道  具",DAOTAG)
	self.m_normalView:addTabButton("宝  石",BAOTAG)
	self.m_normalView:addTabButton("礼  包",LITAG)
	self.m_normalView:addTabButton("元  宝",YUANTAG)
	self.m_normalView:addTabButton("灵  妖",LINGTAG)
	self.m_normalView:addTabButton("神  器",ARTITAG)
	
	self : updateMoneyTab()
	self : initView()
	self.m_normalView : selectTagByTag(self.m_selectType)
	return tempScene
end

function ShopView.pushData(self, _data)     --mediator传过来的数据
    print("ShopMediator传过来的数据:", _data.type, _data.type_bb,_data.good_id,_data.count)
    	
    self:ShopPageView(_data.type_bb,_data.count,_data.msg)
    self.type = _data.type
    self.dazheId = _data.good_id
end

function ShopView.initView(self)
	self.m_mainNode = cc.Node:create()
	self.m_mainNode : setPosition(m_winSize.width*0.5,m_winSize.height*0.5)
	self.m_rootLayer: addChild(self.m_mainNode)

	local floorSpr  = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
    floorSpr        : setPreferredSize(cc.size(downSize.width-2,downSize.height-40))
    floorSpr        : setPosition(110, -20)
    self.m_mainNode : addChild(floorSpr)

	-- local logoSpr = _G.ImageAsyncManager:createNormalSpr("ui/bg/recharge_zzshop.png")
 --    logoSpr : setPosition(110,182)
 --    self.m_mainNode  : addChild(logoSpr)

	local moneybgSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_friendbg.png")
    moneybgSpr       : setPreferredSize(cc.size(downSize.width+5, 55))
    moneybgSpr       : setPosition(cc.p(110,-270))
    self.m_mainNode : addChild(moneybgSpr) 

	self.shoptagNode = {}

 	self:onShopCallBack(self.m_selectType)
end

-- function ShopView.ShopScrollView( self, type_bb, pagecount, msg )
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

function ShopView.ShopPageView( self, type_bb, pagecount, msg)
    if msg == nil then return end
    if self.shoptagNode[type_bb]==nil then
		self.shoptagNode[type_bb]=cc.Node:create()
		self.shoptagNode[type_bb]:setPosition(-203.5,-245)
		self.m_mainNode : addChild(self.shoptagNode[type_bb])

		if type_bb==6010 then
			local nowHaveLab = _G.Util : createLabel("当前拥有       ：", FONTSIZE)
			-- nowHaveLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
			nowHaveLab : setPosition(downSize.width-240, -30)
			nowHaveLab : setAnchorPoint(cc.p(0,0.5))
			self.shoptagNode[type_bb] : addChild(nowHaveLab)

			local huobiImg= "general_artifact.png"
			local actiSpr = cc.Sprite : createWithSpriteFrameName(huobiImg)
			actiSpr 	  : setPosition(downSize.width-140, -28)
			self.shoptagNode[type_bb] : addChild(actiSpr)

			local count  = _G.GBagProxy:getGoodsCountById(38500)
			self.actiLab = _G.Util : createLabel(count, FONTSIZE)
			self.actiLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
			self.actiLab : setPosition(downSize.width-110, -30)
			self.actiLab : setAnchorPoint(cc.p(0,0.5))
			self.shoptagNode[type_bb] : addChild(self.actiLab)
		elseif type_bb==5010 then
			local nowHaveLab = _G.Util : createLabel("当前拥有       ：", FONTSIZE)
			-- nowHaveLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
			nowHaveLab : setPosition(downSize.width-240, -30)
			nowHaveLab : setAnchorPoint(cc.p(0,0.5))
			self.shoptagNode[type_bb] : addChild(nowHaveLab)

			local huobiImg= "general_yaoling.png"
			local actiSpr = cc.Sprite : createWithSpriteFrameName(huobiImg)
			actiSpr 	  : setPosition(downSize.width-140, -28)
			self.shoptagNode[type_bb] : addChild(actiSpr)

			self.lingyaoLab = _G.Util : createLabel(self.lycount, FONTSIZE)
			self.lingyaoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
			self.lingyaoLab : setPosition(downSize.width-110, -30)
			self.lingyaoLab : setAnchorPoint(cc.p(0,0.5))
			self.shoptagNode[type_bb] : addChild(self.lingyaoLab)
		end

		local kuangSize = cc.size(620,470)
	    local pageView = ccui.PageView : create()
	    pageView : setTouchEnabled(true)
	    pageView : setSwallowTouches(true)
	    pageView : setContentSize(cc.size(kuangSize.width-2,kuangSize.height))
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
		        local posX = self.shopSize.width/2+3+(self.shopSize.width+4)*(addColum-1)
		        local posY = kuangSize.height-self.shopSize.height/2-18-(self.shopSize.height+8)*(addRowNo-1)
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

function ShopView.ShopOneKuang( self,type_bb,Num,_data)
	print("创建物品框", Num, _data, _data.msg_xxx,_data.msg_xxx.goods_id)
	local goods_id = _data.msg_xxx.goods_id
	local icondata = _G.Cfg.goods[goods_id]
	local idx 	   = _data.idx
	print("icondata",icondata)
	if icondata == nil then return end

	local roleWid = ccui.Widget : create()	
	
	local shopSpr  = cc.Sprite : createWithSpriteFrameName("shop_kuang.png")
	-- local shopSize = shopSpr : getContentSize()
	-- shopSpr        : setPreferredSize(cc.size(shopSize.width, shopSize.height-10))
	self.shopSize  = shopSpr : getContentSize()
	print("Size",self.shopSize.width,self.shopSize.height)
	shopSpr : setPosition(cc.p(self.shopSize.width/2, self.shopSize.height/2))
	roleWid : setContentSize(self.shopSize)
	roleWid : setTouchEnabled(true)
	roleWid : setSwallowTouches(false)
	roleWid : setTag(Num)

	self.widArray[idx]={}
	self.widArray[idx].wid=roleWid

	local function WidgetCallback(sender, eventType)
		if eventType==ccui.TouchEventType.began then
            shopSpr:setOpacity(180)
		elseif eventType == ccui.TouchEventType.ended then
			local role_tag = sender : getTag()
			local Position = sender : getWorldPosition()
      		print("Position.x",Position.x,m_winSize.width/2-downSize.width/2+210,m_winSize.width/2+downSize.width/2+10)
      		if Position.x > m_winSize.width/2+downSize.width/2+10 or Position.x < m_winSize.width/2-downSize.width/2+210
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
	local roleLab  = _G.Util : createBorderLabel(rolename, FONTSIZE,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	roleLab : setPosition(self.shopSize.width/2, self.shopSize.height-20)
	roleLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	roleWid : addChild(roleLab)

	local shop_hot = cc.Sprite : createWithSpriteFrameName("shop_hot.png")
	shop_hot : setPosition(cc.p(35, self.shopSize.height-29))
	shop_hot : setVisible(false)
	roleWid  : addChild(shop_hot)

	local shop_xian = cc.Sprite : createWithSpriteFrameName("shop_xian.png")
	shop_xian : setPosition(cc.p(35, self.shopSize.height-29))
	shop_xian : setVisible(false)
	roleWid   : addChild(shop_xian)

	self.widArray[idx].xian = shop_xian

	local shop_wan  = cc.Sprite : createWithSpriteFrameName("shop_wan.png")
	shop_wan  : setPosition(cc.p(35, self.shopSize.height-29))
	shop_wan  : setVisible(false)
	roleWid  	   : addChild(shop_wan)
	self.widArray[idx].wan = shop_wan

	local roleRmb = _data.s_price
	print("物品ID、名、价格", goods_id,rolename,roleRmb,_data.v_price,_data.state,_data.total_remaider_num)
	if roleRmb == _data.v_price or _data.type==19 then
		local ORANGE = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
		local jadeLab = _G.Util : createLabel(roleRmb, FONTSIZE, ORANGE)
		jadeLab : setPosition(self.shopSize.width/2+13, 19)
		-- jadeLab : setAnchorPoint( cc.p(0.0,0.5) )
		-- jadeLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
		roleWid : addChild(jadeLab)

		print("_data.type---->>>>",_data.type)
		local labWidth = jadeLab:getContentSize().width
		local huobiImg = "general_xianYu.png"
		if _data.type == 3 then
            huobiImg   = "general_gold.png"
        elseif _data.type == 1 then
            huobiImg   = "general_tongqian.png"
        elseif _data.type == 21 then
            huobiImg   = "general_zhizun.png"
        elseif _data.type==19 then
           	huobiImg   = "general_artifact.png"
        elseif _data.type==23 then
           	huobiImg   = "general_yaoling.png"
        end
		local jade = cc.Sprite : createWithSpriteFrameName(huobiImg)
		jade 	: setPosition(cc.p(self.shopSize.width/2-labWidth/2-7, 20))
		roleWid : addChild(jade)

		if _data.state == 0 then
			print("售完",type_bb,_data.state)
			shop_wan : setVisible(true)
		elseif _data.state > 0 then
			print("限购",type_bb,_data.state)
			shop_xian : setVisible(true)
		elseif type_bb == 1010 then
			print("热卖",type_bb)
			shop_hot : setVisible(true)
		end

		-- if type_bb == 1010 then
		-- 	shop_hot : setVisible(true)
		-- 	if _data.state >= 0 then
		-- 		shop_hot : setVisible(false)
		-- 		shop_xian : setVisible(true)
		-- 		if _data.state == 0 then
		-- 			shop_xian : setVisible(false)
		-- 			shop_wan : setVisible(true)
		-- 		end
		-- 	end
		-- elseif _data.state >= 0 then
		-- 	shop_xian : setVisible(true)
		-- 	if _data.state == 0 then
		-- 		shop_xian : setVisible(false)
		-- 		shop_wan : setVisible(true)
		-- 	end
		-- end
	elseif roleRmb ~= _data.v_price then
		local jadeLab1 = _G.Util : createLabel(_data.v_price, FONTSIZE)
		jadeLab1 : setPosition(self.shopSize.width/2, 19)
		jadeLab1 : setAnchorPoint( cc.p(1,0.5) )
		jadeLab1 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
		roleWid  : addChild(jadeLab1)

		local rmbSize  = jadeLab1 : getContentSize()
		local line = cc.DrawNode : create()--绘制线条
		line 	 : drawLine(cc.p(0,2), cc.p(rmbSize.width+8,2), cc.c4f(0.6,0.2,0.3,1))
		line     : setPosition(self.shopSize.width/2-rmbSize.width-5, 19)
		line : setAnchorPoint( cc.p(1,0.5) )
		roleWid  : addChild(line,2)

		local ORANGE = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
		local jadeLab2 = _G.Util : createLabel(roleRmb, FONTSIZE,ORANGE)
		jadeLab2 : setPosition(self.shopSize.width/2+15, 19)
		jadeLab2 : setAnchorPoint( cc.p(0.0,0.5) )
		-- jadeLab2 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
		roleWid  : addChild(jadeLab2)

		print("_data.type---->>>>",_data.type)
		local huobiImg = "general_xianYu.png"
		if _data.type == 3 then
            huobiImg   = "general_gold.png"
        elseif _data.type == 1 then
            huobiImg   = "general_tongqian.png"
        elseif _data.type == 21 then
            huobiImg   = "general_zhizun.png"
        end
		local jade = cc.Sprite : createWithSpriteFrameName(huobiImg)
		jade 	   : setPosition(cc.p(self.shopSize.width/2-rmbSize.width-20, 20))
		roleWid    : addChild(jade)

		local zheNum   = math.floor(roleRmb*10/_data.v_price)
		local zheyuNum = (roleRmb*10/_data.v_price)%zheNum
		local yuNum   = math.floor(zheyuNum*100/10)
		local shop_zhe = cc.Sprite : createWithSpriteFrameName("shop_zhe.png")
		shop_zhe : setPosition(cc.p(35, self.shopSize.height-29))
		shop_zhe : setVisible(false)
		roleWid  : addChild(shop_zhe)
		
		local shop_num = cc.Sprite : createWithSpriteFrameName("shop_"..zheNum..".png")
		shop_num : setPosition(cc.p(self.shopSize.width*0.07, self.shopSize.height*0.81))
		shop_num : setVisible(false)
		shop_num : setRotation(-45)
		roleWid  : addChild(shop_num)

		
		print("多少折", zheNum,zheyuNum,yuNum)
		local strSpr = cc.Sprite : createWithSpriteFrameName("shop_zhestr.png")
		strSpr : setVisible(false)
		strSpr : setRotation(-45)
		strSpr : setPosition(cc.p(self.shopSize.width*0.13, self.shopSize.height*0.89))
		roleWid : addChild(strSpr)

		local shop_dian = cc.Sprite : createWithSpriteFrameName("shop_dian.png")
		shop_dian : setPosition(cc.p(self.shopSize.width*0.09, self.shopSize.height*0.78))
		shop_dian : setVisible(false)
		shop_dian : setRotation(-45)
		roleWid   : addChild(shop_dian)

		local shop_yu = cc.Sprite : create()
		shop_yu : setPosition(cc.p(self.shopSize.width*0.09+1, self.shopSize.height*0.84+1))
		shop_yu : setVisible(false)
		shop_yu : setRotation(-45)
		roleWid  : addChild(shop_yu)

		if _data.state == 0 then
			print("售完",type_bb,_data.state)
			shop_wan : setVisible(true)
		elseif _data.state > 0 then
			print("限购",type_bb,_data.state)
			shop_xian : setVisible(true)
		elseif type_bb == 1010 then
			print("热卖",type_bb)
			shop_hot : setVisible(true)
		elseif yuNum > 0 then
			shop_num  : setPosition(cc.p(self.shopSize.width*0.06-2, self.shopSize.height*0.8-3))
			strSpr	  : setPosition(cc.p(35, self.shopSize.height*0.9+1))
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
	end

	local roleImg = ccui.Scale9Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
	roleImg       : setPosition(cc.p(self.shopSize.width/2, self.shopSize.height/2))
	roleWid 	  : addChild(roleImg)

	local roleSize= roleImg : getContentSize()
	local iconSpr = _G.ImageAsyncManager:createGoodsSpr(icondata)
	iconSpr 	  : setPosition(cc.p(roleSize.width/2,roleSize.height/2))
    roleImg       : addChild(iconSpr)

	return roleWid
end

function ShopView.BuyTipsView(self,type_bb, tag, _data)
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
	elseif type_bb == 5010 then
		self.m_maxNum = math.floor(self.lycount/rmbcount)
	elseif type_bb == 6010 then
		local count  = _G.GBagProxy:getGoodsCountById(38500)
		self.m_maxNum = math.floor(count/rmbcount)
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
    local tipsBoxContainer = self.NumberTipsBox :create(type_bb,rmbcount)

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

function ShopView.BUYFailureReturn(self)
	local szMsg="钻石不足，是否前往充值？"
	local function fun1()
		print("跳转到充值界面")
		self:closeWindow()
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_RECHARGE)
	end
	_G.Util:showTipsBox(szMsg,fun1)
end

function ShopView.updateYaoling(self,_rmb)
	if self.lingyaoLab==nil then return end
	self.lingyaoLab:setString(_rmb)
end

function ShopView.SHOP_BUY_SUCC(self,_data)
	print("子商店、索引、限购次数",_data.type_bb,_data.idx,_data.state,_data.good_id)
	local idx = _data.idx
	local _bb = _data.type_bb
	self.m_newGoodsArray[_bb] = {}
	if _data.state >= 0 then
		self.widArray[idx].xian : setVisible(true)
		if _data.state == 0 then
			self.widArray[idx].xian : setVisible(false)
			self.widArray[idx].wan  : setVisible(true)
		end
		print("[_bb][idx].state",_bb,idx,self.m_newGoodsArray[_bb])
		self.m_newGoodsArray[_bb][idx]=self.m_newGoodsArray[_bb][idx] or {}
		self.m_newGoodsArray[_bb][idx].state=_data.state
	end
	local count  = _G.GBagProxy:getGoodsCountById(38500)
	if self.actiLab~=nil then
		self.actiLab:setString(count)
	end

	self.dazheId = _data.good_id

	_G.Util:playAudioEffect("ui_receive_awards")
end

function ShopView.PageNetWorkSend(self,_type,_type_bb)
    --向服务器发送页面数据请求
    local msg = REQ_SHOP_REQUEST()
    msg : setArgs(_type,_type_bb)
    _G.Network : send(msg)
end

function ShopView.onShopCallBack(self, shop_tag)
	if self.shoptagNode[shop_tag]==nil then
		if shop_tag==ARTITAG then
			SHOPTYPE=60
			self : PageNetWorkSend(SHOPTYPE,shop_tag)
		elseif shop_tag==LINGTAG then
			SHOPTYPE=50
			self : PageNetWorkSend(SHOPTYPE,shop_tag)
		else
			SHOPTYPE=10
			self : PageNetWorkSend(SHOPTYPE,shop_tag)
		end
	end
	print("切换到界面", shop_tag)
	local icondata = nil
    icondata = _G.Cfg.mall_class[10]
    if icondata == nil then return end
    if shop_tag==6010 then
    	for k,v in pairs(icondata) do
    		if self.shoptagNode[k]~=nil then
    			self.shoptagNode[k]:setVisible(false)
    		end
    	end
    	if self.shoptagNode[5010]~=nil then
    		self.shoptagNode[5010]:setVisible(false)
    	end
    	if self.shoptagNode[6010]~=nil then
    		self.shoptagNode[6010]:setVisible(true)
    	end
    	return
    end
    if shop_tag==5010 then
    	for k,v in pairs(icondata) do
    		if self.shoptagNode[k]~=nil then
    			self.shoptagNode[k]:setVisible(false)
    		end
    	end
    	if self.shoptagNode[6010]~=nil then
    		self.shoptagNode[6010]:setVisible(false)
    	end
    	if self.shoptagNode[5010]~=nil then
    		self.shoptagNode[5010]:setVisible(true)
    	end
    	return
    end
	for k,v in pairs(icondata) do
		if k ~= shop_tag and self.shoptagNode[k]~=nil then
			print("非选中按钮", k)
	        self.shoptagNode[k] : setVisible(false)
	    elseif self.shoptagNode[k]~=nil then
	        print("选中按钮", k)
	        self.shoptagNode[shop_tag] : setVisible(true)
	    end
	    if self.shoptagNode[6010]~=nil then
    		self.shoptagNode[6010]:setVisible(false)
    	end
    	if self.shoptagNode[5010]~=nil then
    		self.shoptagNode[5010]:setVisible(false)
    	end
	end
end

function ShopView.updateMoneyTab( self )
	self.playrmbs = self : getPlayerData(MONEY_RMB) or 0
    print("playrmbs",self.playrmbs)
    self.playjades = self : getPlayerData(MONEY_JADE) or 0
    print("playjades",self.playjades)
    self.lycount = self : getPlayerData(MONEY_YL) or 0
    print("lycount",self.lycount)
end

function ShopView.getPlayerData( self,_CharacterName )
    local mainplay = _G.GPropertyProxy : getMainPlay()
    local CharacterValue = nil 
    if _CharacterName == MONEY_RMB then
        CharacterValue = mainplay : getBindRmb()
    elseif _CharacterName == MONEY_JADE then
        CharacterValue = mainplay : getRmb()
    elseif _CharacterName == MONEY_YL then
        CharacterValue = mainplay : getYaoLing()
    end

    return CharacterValue
end

function ShopView.closeWindow(self)
	print("关闭商城")
	if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
	self : unregister()
	cc.Director:getInstance():popScene()
end

function ShopView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return ShopView