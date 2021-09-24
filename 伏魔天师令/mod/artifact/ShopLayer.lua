local ShopLayer   = classGc(view,function ( self )

end)

local m_winSize = cc.Director:getInstance():getVisibleSize()
local VIEW_SIZE = cc.size(790,372)
local SHOPID	=_G.Const.CONST_MALL_TYPE_SUB_MAGICS
local m_Num 	= 1
local R_ROWNO	= 4 --列数
local PAGECOUNT = 8
local FONTSIZE  = 20

function ShopLayer.create(self)
    self : __init()

	self.m_rootLayer  = cc.Node : create()
	self  			  : __initView()
	
    return self.m_rootLayer
end

function ShopLayer.__init(self)
    self : register()
end

function ShopLayer.register(self)
    self.pMediator = require("mod.artifact.ShopMediator")(self)
end
function ShopLayer.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function ShopLayer.__initView( self )
	print("..............创建商城面板..............")
	self.shopView    = ccui.Widget:create()
	self.shopView    : setContentSize(VIEW_SIZE)
	self.shopView    : setPosition(0,-19.5)
	self.m_rootLayer : addChild(self.shopView)

	local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
	local lineSprsize = lineSpr : getContentSize()
	lineSpr : setPreferredSize(cc.size(VIEW_SIZE.width,lineSprsize.height))
	lineSpr : setScale(-1)
	lineSpr : setPosition(VIEW_SIZE.width/2,0)
	self.shopView : addChild(lineSpr)

	local huobiImg= "general_artifact.png"
	local actiSpr = cc.Sprite : createWithSpriteFrameName(huobiImg)
	actiSpr 	  : setPosition(VIEW_SIZE.width-100, -22)
	self.shopView : addChild(actiSpr)

	local ORANGE = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
	local huobi  = self:updateMoneyTab() or 0
	self.actiLab = _G.Util : createLabel(huobi, FONTSIZE,ORANGE)
	self.actiLab : setPosition(VIEW_SIZE.width-80, -25)
	self.actiLab : setAnchorPoint(cc.p(0,0.5))
	self.shopView : addChild(self.actiLab)

	self : PageNetWorkSend(60,SHOPID)
end

function ShopLayer.PageNetWorkSend(self,_type,_type_bb)
    --向服务器发送页面数据请求
    local msg = REQ_SHOP_REQUEST()
    msg : setArgs(_type,_type_bb)
    _G.Network : send(msg)
end

function ShopLayer.pushData(self, _data)     --mediator传过来的数据
    print("ShopMediator传过来的数据:", _data.type, _data.type_bb,_data.count)
    	
    self:ShopPageView(_data.type_bb,_data.count,_data.msg)
    self.type = _data.type
end

function ShopLayer.ShopPageView( self, type_bb, pagecount, msg)
    if msg == nil then return end
	local kuangSize = self.shopView : getContentSize()
    local pageView = ccui.PageView : create()
    pageView : setTouchEnabled(true)
    pageView : setSwallowTouches(true)
    pageView : setContentSize(cc.size(kuangSize.width-5,kuangSize.height))
    pageView : setPosition(cc.p(4.5, 0))
    pageView : setCustomScrollThreshold(50)
    pageView : enableSound()
    self.shopView : addChild(pageView)

    local page_bg = cc.Sprite : createWithSpriteFrameName("general_input.png")
	page_bg       : setPosition(VIEW_SIZE.width/2, -22)
	self.shopView : addChild(page_bg)

	local pageSize = page_bg : getContentSize()
	-- local LeftSpr  = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
	-- LeftSpr : setPosition(-15, pageSize.height/2)
	-- page_bg : addChild(LeftSpr)

	-- local RightSpr = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
	-- RightSpr : setPosition(pageSize.width+15, pageSize.height/2)
	-- RightSpr : setScale(-1)
	-- page_bg  : addChild(RightSpr)

	local pageLab = _G.Util : createLabel("", FONTSIZE)
	pageLab : setPosition(pageSize.width/2, pageSize.height/2-2)
	page_bg : addChild(pageLab)

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
	        local posY = kuangSize.height-self.shopSize.height/2-10-(self.shopSize.height+6)*(addRowNo-1)
	        print("Size===>>",posX,posY)
	        m_oneGood : setPosition(posX,posY)
			layout : addChild(m_oneGood)
		end
		pageView : addPage(layout)
	end
	local m_nowPageCount = 1
	pageLab : setString(string.format(" %d/%d ",m_nowPageCount,m_pageCount))
	-- if m_nowPageCount == 1 then
	-- 	LeftSpr:setVisible(false)
	-- 	if m_nowPageCount == m_pageCount then
	--   		RightSpr:setVisible(false)
	-- 	end
	-- end
	local function pageViewEvent(sender, eventType)
	  	if eventType == ccui.PageViewEventType.turning then
	      	local pageView       = sender
	      	local m_nowPageCount = pageView : getCurPageIndex() + 1
	      	local pageInfo       = string.format(" %d/%d ",m_nowPageCount,m_pageCount)
	      	print("翻页", pageInfo)
	      	pageLab : setString(pageInfo)
	   --    	if m_nowPageCount == 1 then
				-- LeftSpr:setVisible(false)
				-- RightSpr:setVisible(true)
				-- if m_nowPageCount == m_pageCount then
	   --        		RightSpr:setVisible(false)
	   --      	end
	   --    	elseif m_nowPageCount == m_pageCount then
	   --      	LeftSpr:setVisible(true)
	   --      	RightSpr:setVisible(false)
	   --    	else
	   --      	LeftSpr:setVisible(true)
	   --      	RightSpr:setVisible(true)
	   --    	end
	  	end
	end
	pageView : addEventListener(pageViewEvent)
end

function ShopLayer.ShopOneKuang( self,type_bb,Num,_data)
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
      		print("Position.y",Position.y,m_winSize.width/2-VIEW_SIZE.width/2,m_winSize.width/2+VIEW_SIZE.width/2)
      		if Position.x > m_winSize.width/2+VIEW_SIZE.width/2 or Position.x < m_winSize.width/2-VIEW_SIZE.width/2
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

function ShopLayer.BuyTipsView(self,type_bb, tag, _data)
	local goods_id = _data.msg_xxx.goods_id
	local icondata = _G.Cfg.goods[goods_id]
	if icondata == nil then return end

	local function onTouchBegan() return true end
	local listerner= cc.EventListenerTouchOneByOne:create()
	listerner 	   : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner 	   : setSwallowTouches(true)

	local buy_bg = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
	buy_bg : setPosition(m_winSize.width/2,m_winSize.height/2)
	buy_bg : setPreferredSize(cc.size(470, 380))
	buy_bg : getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,buy_bg)
	cc.Director:getInstance():getRunningScene() :addChild(buy_bg,1000)

	local buybgSize= buy_bg : getContentSize()
	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(buybgSize.width/2, buybgSize.height-5)
	-- tipslogoSpr : setPreferredSize(cc.size(buybgSize.width-25, buybgSize.height-30))
	buy_bg : addChild(tipslogoSpr)

	local logoLab= _G.Util : createLabel("购买", FONTSIZE)
	-- logoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	logoLab : setPosition(buybgSize.width/2, buybgSize.height-5)
	-- logoLab : setAnchorPoint( cc.p(0.0,0.5) )
	buy_bg  : addChild(logoLab)

	local act2=cc.ScaleTo:create(0.2,1.04)
	local act3=cc.ScaleTo:create(0.1,0.98)
	local act4=cc.ScaleTo:create(0.05,1)
	buy_bg:setScale(0.9)
	buy_bg:runAction(cc.Sequence:create(act2,act3,act4))

	local roleSpr  = cc.Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
	roleSpr 	   : setPosition(buybgSize.width*0.2, buybgSize.height*0.76)
	buy_bg  	   : addChild(roleSpr,1)

	local roleSize= roleSpr : getContentSize()
	local iconSpr = _G.ImageAsyncManager:createGoodsSpr(icondata)
	iconSpr 	  : setPosition(cc.p(roleSize.width/2,roleSize.height/2))
    roleSpr       : addChild(iconSpr)

	local rolebgSpr = cc.Sprite : createWithSpriteFrameName("general_rolebg.png")
	rolebgSpr 	  : setPosition(buybgSize.width*0.2, buybgSize.height*0.76)
	buy_bg  	  : addChild(rolebgSpr)

	local downline= ccui.Scale9Sprite : createWithSpriteFrameName("general_fram_jianbian.png")
	downline 	  : setPosition(buybgSize.width/2, buybgSize.height/2-25)
	downline	  : setPreferredSize(cc.size(buybgSize.width, 60))
	buy_bg  	  : addChild(downline)

	local numSpr  = ccui.Scale9Sprite : createWithSpriteFrameName("general_input.png")
	numSpr 	   	  : setPosition(buybgSize.width*0.42, buybgSize.height/2-25)
	local inputSize = numSpr : getContentSize()
    numSpr 		  : setPreferredSize(cc.size(inputSize.width*2,inputSize.height))
	buy_bg  	  : addChild(numSpr)

	local huobiImg= "general_artifact.png"
	local jadeSpr = cc.Sprite : createWithSpriteFrameName(huobiImg)
	jadeSpr 	  : setPosition(buybgSize.width*0.49, buybgSize.height*0.27)
	buy_bg  	  : addChild(jadeSpr)

	local loginStr= icondata.name
	local rolelv  = icondata.lv
	local content = icondata.remark
	local rmbcount= _data.s_price

	local loginLab= _G.Util : createLabel(loginStr, FONTSIZE)
	loginLab  	  : setColor(_G.ColorUtil : getRGBA(icondata.name_color))
	loginLab  	  : setPosition(buybgSize.width*0.41, buybgSize.height*0.9)
	loginLab  	  : setAnchorPoint( cc.p(0.0,0.5) )
	buy_bg    	  : addChild(loginLab)

	local lvstrLab= _G.Util : createLabel("使用等级:", FONTSIZE-2)
	lvstrLab  	  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	lvstrLab  	  : setPosition(buybgSize.width*0.41, buybgSize.height*0.82)
	lvstrLab  	  : setAnchorPoint( cc.p(0.0,0.5) )
	buy_bg    	  : addChild(lvstrLab)

	local playlvLab = _G.Util : createLabel(rolelv, FONTSIZE-2)
	playlvLab 	  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
	playlvLab 	  : setPosition(buybgSize.width/2+45, buybgSize.height*0.82)
	playlvLab 	  : setAnchorPoint( cc.p(0.0,0.5) )
	buy_bg    	  : addChild(playlvLab)

	local textLab = _G.Util : createLabel(content, FONTSIZE-2)
	textLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	textLab       : setPosition(buybgSize.width*0.41, buybgSize.height*0.63)
	textLab       : setDimensions(buybgSize.width/2, 100)
	textLab       : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	textLab       : setAnchorPoint( cc.p(0.0,0.5) )
	buy_bg        : addChild(textLab)

	local zongLab = _G.Util : createLabel("总计:", FONTSIZE)
	zongLab 	  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	zongLab 	  : setPosition(buybgSize.width*0.35, buybgSize.height*0.27)
	zongLab 	  : setAnchorPoint( cc.p(0.0,0.5) )
	buy_bg  	  : addChild(zongLab)

	self.rmbxhLab = _G.Util : createLabel(rmbcount, FONTSIZE)
	self.rmbxhLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
	self.rmbxhLab : setPosition(buybgSize.width*0.53+2, buybgSize.height*0.27)
	self.rmbxhLab : setAnchorPoint( cc.p(0.0,0.5) )
	buy_bg 		  : addChild(self.rmbxhLab)

	local huobi = self:updateMoneyTab() or 0
	local m_maxNum = math.floor(huobi/rmbcount)

	print("m_maxNum", m_maxNum)
	local maxCount=icondata.stack
	if m_maxNum > maxCount then
		m_maxNum = maxCount
	elseif m_maxNum < 1 then
		m_maxNum = 1
		self.rmbxhLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_RED))
	end
	
	local function buyCallBack(sender, eventType)
	    if eventType == ccui.TouchEventType.ended then
	    	local tip_tag = sender : getTag()
	    	local num = self.numText : getString()
	    	print("--self.numText---",num)
            num = string.match(num , "%d*")

	    	if tip_tag == 1 then
	    		print("减1",num)
	    		num = tonumber( num )
	    		if num ~= nil and num > 1 then
	        		self.numText : setString( tostring(num-1) )
		        	local minusprice = tostring(rmbcount*tonumber(num-1))
			        print("minusprice", minusprice)
			        self.rmbxhLab : setString(minusprice)	        		
	        	end
	    	elseif tip_tag == 2 then
	    		print("加1",num)
	    		num = tonumber( num )
	    		if num ~= nil and num < m_maxNum then
	        		self.numText : setString( tostring(num+1) )
	        		local addprice = tostring(rmbcount*tonumber(num+1))
	            	print("addprice", addprice)
	            	self.rmbxhLab : setString(addprice)	
	        	end
	    	elseif tip_tag == 3 then
		    	local szMaxNum = tostring(m_maxNum)
	            self.numText : setString( szMaxNum )
	    		print("最大", szMaxNum)
	    		local maxsprice = tostring(rmbcount*tonumber(szMaxNum))
	            print("maxsprice", maxsprice)
	            self.rmbxhLab : setString(maxsprice)
	    	end
	    	local count = self.numText : getString()
	    	local xhcount = tonumber(count)
	    	if tip_tag == 4 then
	    		print("购买",type_bb,_data.idx,goods_id,xhcount,_data.type)
		    	if xhcount == nil then
	                local command = CErrorBoxCommand(9)
	                controller : sendCommand( command )
	                return
	            end
				local msg = REQ_SHOP_BUY()
		        msg :setArgs(self.type,type_bb,_data.idx,goods_id,xhcount,_data.type) 
		        _G.Network : send(msg)

		        buy_bg : removeFromParent(true)
        		buy_bg = nil
        		self.cishuLab=nil
		    elseif tip_tag == 5 then
		    	print("取消")
		    	buy_bg : removeFromParent(true)
		    	buy_bg = nil
		    	self.cishuLab=nil
		    end
		end
	end

	local function textFieldEvent(sender, eventType)
        if eventType == ccui.TextFiledEventType.insert_text then
            local num = self.numText : getString()
            print("--textFieldEvent---",num)
            local nums = string.match(num , "%d*")
            
            if tostring(num) ~= tostring(nums) then
                print("重新设置")
                self.numText : setString(tostring(m_Num))
                local command = CErrorBoxCommand(9)
                controller : sendCommand( command )
            end
            print("m_maxNum",m_maxNum)
            if tonumber (nums) > m_maxNum then
            	nums = tostring(m_maxNum)
            	self.numText : setString(tostring(nums))
            end

            m_Num=nums
            local szPrice = tostring(rmbcount*tonumber(nums))
            print("szPrice", szPrice)
            self.rmbxhLab : setString(szPrice)
        end
    end
    local inputSize= numSpr : getContentSize()
	self.numText   = ccui.TextField : create("",_G.FontName.Heiti,FONTSIZE)
    self.numText   : setTouchEnabled(true)
    self.numText   : setMaxLength(5)
    self.numText   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    self.numText   : setPosition(cc.p(buybgSize.width*0.42, buybgSize.height/2-25))
    self.numText   : setString(tostring(1))
    self.numText   : addEventListener(textFieldEvent)
    self.numText   : ignoreContentAdaptWithSize(false)
    self.numText   : setContentSize(cc.size(inputSize.width,inputSize.height))
    self.numText   : setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    buy_bg    	   : addChild(self.numText) 

	local minusSpr = gc.CButton:create()
	minusSpr  	   : loadTextures("general_btn_reduce.png")
	minusSpr 	   : setPosition(buybgSize.width*0.19, buybgSize.height/2-25)
	minusSpr 	   : setTag(1)
	minusSpr	   : addTouchEventListener(buyCallBack)
	minusSpr	   : ignoreContentAdaptWithSize(false)
    minusSpr	   : setContentSize(cc.size(80,80))
	buy_bg  	   : addChild(minusSpr)

	local addSpr   = gc.CButton:create()
	addSpr  	   : loadTextures("general_btn_add.png")
	addSpr 	   	   : setPosition(buybgSize.width*0.64, buybgSize.height/2-25)
	addSpr 	   	   : setTag(2)
	addSpr	  	   : addTouchEventListener(buyCallBack)
	addSpr 		   : ignoreContentAdaptWithSize(false)
    addSpr 		   : setContentSize(cc.size(80,80))
	buy_bg  	   : addChild(addSpr)

	local maxSpr   = gc.CButton:create()
	maxSpr  	   : loadTextures("general_max.png")
	maxSpr 	   	   : setPosition(buybgSize.width*0.81, buybgSize.height/2-25)
	maxSpr 	   	   : setTag(3)
	maxSpr	   	   : addTouchEventListener(buyCallBack)
	maxSpr 	 	   : ignoreContentAdaptWithSize(false)
    maxSpr 		   : setContentSize(cc.size(80,80))
	buy_bg  	   : addChild(maxSpr)

	local buyBtn   = gc.CButton : create("general_btn_gold.png")
	buyBtn 		   : setTitleFontName(_G.FontName.Heiti)
	buyBtn 		   : setTitleText("确定")
	buyBtn 		   : setTitleFontSize(24)
	--buyBtn		   : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	buyBtn         : setPosition(buybgSize.width*0.25, buybgSize.height*0.13)
	buyBtn         : addTouchEventListener(buyCallBack)
	buyBtn		   : setTag(4)
	buy_bg         : addChild(buyBtn)

	local cancelBtn= gc.CButton : create("general_btn_lv.png")
	cancelBtn 	   : setTitleFontName(_G.FontName.Heiti)
	cancelBtn 	   : setTitleText("取消")
	cancelBtn	   : loadTextures("general_btn_lv.png")
	cancelBtn 	   : setTitleFontSize(24)
	cancelBtn      : setPosition(buybgSize.width*0.75, buybgSize.height*0.13)
	cancelBtn      : addTouchEventListener(buyCallBack)
	cancelBtn	   : setTag(5)
	buy_bg    	   : addChild(cancelBtn)
end

function ShopLayer.SHOP_BUY_SUCC(self,_data)
	print("子商店、索引、限购次数",_data.type_bb,_data.idx,_data.state,_data.good_id)
	local huobi = self:updateMoneyTab() or 0
	self.actiLab:setString(huobi)
	_G.Util:playAudioEffect("ui_receive_awards")
end

function ShopLayer.updateMoneyTab( self )
    local count = _G.GBagProxy:getGoodsCountById(38500)

    return count
end

return ShopLayer