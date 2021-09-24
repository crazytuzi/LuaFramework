local DaemonView = classGc(view,function( self )

	self.m_winSize=cc.Director:getInstance():getWinSize()
end)

local FONT_SIZE = 18
local TAG_RIGHT = 11
local TAG_LEFT  = 12
local TAG_ONE   = 0
local TAG_TEN   = 1
local TAG_EFFECT = 100

function DaemonView.create( self )
	self.m_DaemonView  = require("mod.general.NormalView")()
	self.m_rootLayer   = self.m_DaemonView:create()
	self.m_DaemonView  : setTitle("仙宠灵兽")
	self.m_DaemonView  : showSecondBg()

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

  	self:regMediator()
	self:_initView()

	return tempScene
end

function DaemonView._initView( self )

	local function c(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
            local tag=sender:getTag()
            if tag==TAG_LEFT then
            	self.m_select = self.m_select - 1
            	
            else
            	self.m_select = self.m_select + 1
            end
            self:showData()
        end
	end

	local function f(sender,eventType)
		self:useCallback(sender,eventType)
	end
    local function btn_goodCallback(sender, eventType)
    	if eventType == ccui.TouchEventType.ended then
      		local goodId=sender:getTag()
        	local pos=sender:getWorldPosition()
        	local temp=_G.TipsUtil:createById(goodId,nil,pos)
        	cc.Director:getInstance():getRunningScene():addChild(temp,1000)
    	end
    end

	self.m_array  = _G.Cfg.partner_get
	self.m_proxy  = _G.GPropertyProxy:getMainPlay()
	self.m_select = self:getIndexByLv(self.m_proxy:getLv())

	self.m_mainContainer = cc.Node:create()
	self.m_mainContainer : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
	self.m_rootLayer     : addChild(self.m_mainContainer)

	self.m_rootBgSize    = cc.size(780,450)
	local posX           = self.m_rootBgSize.width/2
	local posY           = self.m_rootBgSize.height/2

	self.m_bgSpr1        = ccui.Scale9Sprite : createWithSpriteFrameName("general_double2.png")
	self.m_bgSpr1        : setPreferredSize(self.m_rootBgSize)
	self.m_bgSpr1        : setPosition(0,-20)
	self.m_mainContainer : addChild(self.m_bgSpr1)

	local dins           = ccui.Scale9Sprite : createWithSpriteFrameName("general_fram_jianbian.png")
	dins                 : setPreferredSize(cc.size(self.m_rootBgSize.width,self.m_rootBgSize.height*0.65))
	dins                 : setPosition(posX,posY+35)
	--dins                 : setOpacity(0.5*255)
	self.m_bgSpr1        : addChild(dins)

	--[[
	local bgSize1        = cc.size(700, 2)
	local bgSpr1         = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
	local lineSprSize 	 = bgSpr1 : getPreferredSize()
	bgSpr1               : setPreferredSize(cc.size(bgSize1.width,lineSprSize.height))
	bgSpr1               : setPosition(posX, posY-100)
	self.m_bgSpr1        : addChild(bgSpr1)
	]]--

	local text1          = _G.Util:createLabel("几率获得：",FONT_SIZE)
	text1                : setPosition(80,54)
	text1                : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	self.m_bgSpr1        : addChild(text1)

	local text2          = _G.Util:createLabel("使用道具：",FONT_SIZE)
	text2                : setPosition(posX+220,54)
  	text2                : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	self.m_bgSpr1        : addChild(text2)

  	self.getSpr = {}
  	self.getSpr[5]       = gc.CButton:create("general_tubiaokuan.png")
  	self.getSpr[5]       : setPosition(posX+300,posY-160)
  	self.getSpr[5]       : addTouchEventListener(btn_goodCallback)
  	self.m_bgSpr1        : addChild(self.getSpr[5])

	self.m_title           = cc.Sprite:createWithSpriteFrameName("daemon_title1.png")
	self.m_title           : setPosition(posX,posY+205)
	self.m_bgSpr1        : addChild(self.m_title)
	
	local bgsize2        = cc.size(334,80)
	local bjSpr1         = cc.Sprite:create("ui/bg/daemon_bg1.jpg")
	bjSpr1               : setPosition(posX-170,posY+35)
	self.m_bgSpr1        : addChild(bjSpr1)

	local  bgKuan1       = ccui.Scale9Sprite:createWithSpriteFrameName("general_input_box.png")
	bgKuan1              : setPosition(bgsize2.width/2,bgsize2.height/2)
	bgKuan1              : setPreferredSize(bgsize2)
	bjSpr1               : addChild(bgKuan1)
	
	self.oneBtn          = gc.CButton : create("general_btn_lv.png")
	self.oneBtn          : setPosition(bgsize2.width/2+100,30)
	self.oneBtn          : setTitleFontSize(FONT_SIZE)
	self.oneBtn          : setTitleFontName(_G.FontName.Heiti)
	self.oneBtn          : setTitleText("抽  取")
	self.oneBtn          : addTouchEventListener(f)
	self.oneBtn          : setTag(TAG_ONE)
	bjSpr1               : addChild(self.oneBtn)

	-- 文本
	self.labelOne        = {}
	for i=1,4 do
	  	self.labelOne[i] = _G.Util:createLabel("",FONT_SIZE)
	  	self.labelOne[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
	  	self.labelOne[i] : setAnchorPoint(0,0.5)
	  	bjSpr1           : addChild(self.labelOne[i])
	end
	self.labelOne[1]    : setString("消耗")
	self.labelOne[2]    : setString("或")
	self.labelOne[3]    : setString("购买")
	self.labelOne[4]    : setString("次")
	self.labelOne[1]    : setPosition(5,bgsize2.height-15)
	self.costOne        = {}
	self.costOne[1]     = _G.Util:createLabel("",FONT_SIZE)
	self.costOne[1]     : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
	self.costOne[1]     : setAnchorPoint(0,0.5)
	bjSpr1              : addChild(self.costOne[1])
	for i=2,3 do
	  	self.costOne[i]   = _G.Util:createLabel("",FONT_SIZE)
	  	self.costOne[i]   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	  	self.costOne[i]   : setAnchorPoint(0,0.5)
	  	bjSpr1            : addChild(self.costOne[i])
	end
	local label1        = _G.Util:createLabel("",FONT_SIZE)
	label1              : setPosition(5,bgsize2.height-40)
	label1              : setAnchorPoint(0,0.5)
	label1              : setString("可以获得：")
	label1              : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
	bjSpr1              : addChild(label1)
	label1              = _G.Util:createLabel("",FONT_SIZE)
	label1              : setPosition(5,15)
	label1              : setAnchorPoint(0,0.5)
	label1              : setString("白色")
	label1              : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE))
	bjSpr1              : addChild(label1)
	label1              = _G.Util:createLabel("",FONT_SIZE)
	label1              : setPosition(42,15)
	label1              : setAnchorPoint(0,0.5)
	label1              : setString("以上灵妖")
	label1              : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
	bjSpr1              : addChild(label1)


  	local bjSpr2        = cc.Sprite:create("ui/bg/daemon_bg2.jpg")
  	bjSpr2              : setPosition(posX+170,posY+35)
  	self.m_bgSpr1       : addChild(bjSpr2)
  	bgKuan1             = ccui.Scale9Sprite:createWithSpriteFrameName("general_input_box.png")
  	bgKuan1             : setPosition(bgsize2.width/2,bgsize2.height/2)
  	bgKuan1             : setPreferredSize(bgsize2)
  	bjSpr2              : addChild(bgKuan1)
  	self.tenBtn         = gc.CButton:create()
  	self.tenBtn         : loadTextures("general_btn_gold.png")
  	self.tenBtn         : setPosition(bgsize2.width/2+100,30)
    self.tenBtn         : setTitleFontSize(FONT_SIZE)
    self.tenBtn         : setTitleFontName(_G.FontName.Heiti)
    self.tenBtn         : setTitleText("抽  取")
    --self.tenBtn 		: enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    self.tenBtn         : addTouchEventListener(f)
    self.tenBtn         : setTag(TAG_TEN)
  	bjSpr2              : addChild(self.tenBtn)

  	-- 文本
  	self.labelTen       = {}
  	for i=1,4 do
	  	self.labelTen[i]= _G.Util:createLabel("",FONT_SIZE)
	  	self.labelTen[i]: setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
	  	self.labelTen[i]: setAnchorPoint(0,0.5)
	  	bjSpr2          : addChild(self.labelTen[i])
  	end
  	self.labelTen[1]    : setString("消耗")
  	self.labelTen[2]    : setString("抽取")
  	self.labelTen[3]    : setString("次")
  	self.labelTen[1]    : setPosition(5,bgsize2.height-15)
  	self.costTen        = {}
  	self.costTen[1]     = _G.Util:createLabel("",FONT_SIZE)
  	self.costTen[1]     : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
  	self.costTen[1]     : setAnchorPoint(0,0.5)
  	bjSpr2              : addChild(self.costTen[1])
  	self.costTen[2]     = _G.Util:createLabel("",FONT_SIZE)
  	self.costTen[2]     : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
  	self.costTen[2]     : setAnchorPoint(0,0.5)
  	bjSpr2              : addChild(self.costTen[2])


  	local scale = 1
  	for i=1,4 do
        self.getSpr[i]   = gc.CButton:create("general_tubiaokuan.png")
        self.getSpr[i]   : addTouchEventListener(btn_goodCallback)
        self.getSpr[i]   : setScale(scale)
        self.m_bgSpr1    : addChild(self.getSpr[i])
        local size       = self.getSpr[i]:getContentSize()
        self.getSpr[i]   : setPosition(170+(size.width*scale+1)*(i-1),posY-160)
    end
    label1              = _G.Util:createLabel("",FONT_SIZE)
  	label1              : setPosition(5,bgsize2.height-40)
  	label1              : setAnchorPoint(0,0.5)
  	label1              : setString("至少获取1个：")
  	label1              : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	bjSpr2              : addChild(label1)

  	label1              = _G.Util:createLabel("",FONT_SIZE)
  	label1              : setPosition(5,15)
  	label1              : setAnchorPoint(0,0.5)
  	label1              : setString("紫色")
  	label1              : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_VIOLET))
  	bjSpr2              : addChild(label1)
  	
  	label1              = _G.Util:createLabel("",FONT_SIZE)
  	label1              : setPosition(42,15)
  	label1              : setAnchorPoint(0,0.5)
  	label1              : setString("以上灵妖")
  	label1              : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
  	bjSpr2              : addChild(label1)


    -- 翻页按钮
    local button        = nil
    button              = gc.CButton:create()
    button              : loadTextures("general_fangye_1.png")
    button              : setPosition(20,posY+20)
    button              : addTouchEventListener(c)
    button              : setTag(TAG_LEFT)
    button              : setScale(1.5)
    self.m_bgSpr1       : addChild(button)
    self.m_leftButton   = button

    button              = gc.CButton:create()
    button              : loadTextures("general_fangye_1.png")
    button              : setPosition(posX*2-20,posY+20)
    button              : addTouchEventListener(c)
    button              : setTag(TAG_RIGHT)
    button              : setScaleX(-1.5)
    button              : setScaleY(1.5)
    -- button:setVisible(false)
    self.m_bgSpr1       : addChild(button)
    self.m_rightButton  = button

	local function closeFun()
		self:closeWindow()
	end

	self.m_DaemonView:addCloseFun(closeFun)


	self : showData()
end

function DaemonView.closeWindow( self )
	if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil

	cc.Director:getInstance():popScene()
	self:destroy()
	
end

function DaemonView.showData( self )


	if self.m_select == 1 then
		self.m_leftButton  : setVisible(false)
	else
		self.m_leftButton  : setVisible(true)
	end
	if self.m_select < self:getIndexByLv(self.m_proxy:getLv()) then
		self.m_rightButton : setVisible(true)
	else 
		self.m_rightButton : setVisible(false)
	end
	if self.m_select > 3 then
		return
	end
	self.m_title : setSpriteFrame(string.format("daemon_title%d.png",self.m_select))
	self : updateDes()
  self : updateGood()
end

function DaemonView.getIndexByLv(self,lv)
	for k,v in ipairs(self.m_array) do
		if v[1].lv > lv then
			key = k - 1
			return key > 0 and key or 1
		end
	end
end

function DaemonView.getLimLv( self )
  return self.m_array[self.m_select][1].lv
end

function DaemonView.updateDes(self)
	local goods           = _G.Cfg.goods[self:getCostType(2)]
	local name            = nil
	if goods ~= nil then
		name = goods.name
	else
		name = "未知"
	end

	local cost            = name
	self.costOne[2]       : setString(cost)
	cost                  = self:getCostNum(3).."钻石"
	self.costOne[1]       : setString(cost)
	self.costOne[3]       : setString("1")
	cost                  = self:getCostNum(4).."钻石"
	self.costTen[1]       : setString(cost)
	self.costTen[2]       : setString("10")

	for i=1,#self.costOne do
		local x,y         = self.labelOne[i] : getPosition()
		local size        = self.labelOne[i] : getContentSize()
		self.costOne[i]   : setPosition(x+size.width,y)
		x,y               = self.costOne[i] : getPosition()
		size              = self.costOne[i] : getContentSize()
		self.labelOne[i+1] : setPosition(x+size.width,y)
	end
	for i=1,#self.costTen do
		x,y               = self.labelTen[i] : getPosition()
		size              = self.labelTen[i] : getContentSize()
		self.costTen[i]   : setPosition(x+size.width,y)
		x,y               = self.costTen[i] : getPosition()
		size              = self.costTen[i] : getContentSize()
		self.labelTen[i+1] : setPosition(x+size.width,y)
	end
end

function DaemonView.updateGood( self )
  local data = self.m_array[self.m_select][2]
  for i,v in ipairs(data.lists) do
    self:showGoodIcon(v[1][1],i)
  end
  self:showGoodIcon(data.cost[1][1],5)
end

function DaemonView.getCostType(self,index)
 	return self.m_array[self.m_select][index].cost[1][1]
end

function DaemonView.getCostNum(self,index)
 	return self.m_array[self.m_select][index].cost[1][2]
end

function DaemonView.regMediator( self )
	self.m_mediator= require("mod.daemon.DaemonMediator")()
	print("daemonMediator")
	self.m_mediator: setView(self)
end

function DaemonView.useCallback( self,sender,eventType )
	if eventType == ccui.TouchEventType.ended then
		local data  = _G.GBagProxy : getPropsList()
		self.m_tag = sender:getTag()
		self.m_costType = nil
    	sender:setTouchEnabled(false)
	    local function buttonCall(  )
	      sender:setTouchEnabled(true)
	    end
    	sender:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(buttonCall)))

	    local function callBack()
	      self:REQ_INN_PARTNER_GET()
	    end

		if self.m_proxy:getLv() < self:getLimLv() then
		    local command = CErrorBoxCommand( 136 )
         	controller : sendCommand(command)
         	return
        end
    	local costMoney = nil
		if self.m_tag == TAG_ONE then
			for _,good in pairs(data) do
				if good.goods_id == self:getCostType(2) and good.goods_num >= self:getCostNum(2) then
					self.m_costType = 1
				end
			end
			if self.m_costType == nil then
				if self.m_proxy:getRmb() >= self:getCostNum(3) then
					self.m_costType = 2
          			costMoney = self:getCostNum(3)
				else
					-- 提示
				    local command = CErrorBoxCommand( 134 )
		         	controller : sendCommand(command)
		         	return
				end
			end
		else
			if self.m_proxy:getRmb() >= self:getCostNum(4) then
				self.m_costType = 3
        		costMoney = self:getCostNum(4)
			else
				-- 提示
			    local command = CErrorBoxCommand( 134 )
	         	controller : sendCommand(command)
		         	
				return
			end
		end
	    if costMoney ~= nil then
	      _G.Util:showTipsBox("花费"..costMoney.."钻石抽取？",callBack)
	    else
	      self:REQ_INN_PARTNER_GET()
	    end
	end
end

function DaemonView.REQ_INN_PARTNER_GET(self)
    local msg = REQ_INN_PARTNER_GET()
    msg:setArgs(self.m_select,self.m_costType,self.m_tag)
    _G.Network:send(msg)
end

function DaemonView.showGoods(self,data )
	if self.layer == nil then
		return
	end
	local count = #data
	local hunCount = 0
	if self.pLayer ~= nil then
		self.pLayer : removeAllChildren(true)
	else 
		self.pLayer = cc.Layer:create()
		self.layer  : addChild(self.pLayer)
	end
	local headSpr = {}
	local pView   = require("mod.partner.PartnerView")()
	local headSize = cc.size(85,85)

	local newData={}
	for i=1,#data do
		newData[{}]=data[i]
	end

	for k,good in pairs(newData) do
			print(good.good_id,"#$$",k)
		local pData   = _G.Cfg.partner_init[good.good_id]
		if pData == nil then
			if hunCount == 0 then
				hunCount = good.count
			else
				hunCount = good.count + hunCount
				count    = count - 1 
			end
			break
		end

		local i = #headSpr + 1
		print(i,"###")
	    headSpr[i]       = pView:createHeadSprite(good.good_id)
	    self.pLayer      : addChild(headSpr[i])
	    local nameLab    = _G.Util:createLabel("",FONT_SIZE)
	    nameLab          : setPosition(42.5,-10)
	    nameLab          : setString(pData.name)
	    _G.ColorUtil:setLabelColor(nameLab,pData.name_color)
	    headSpr[i]       : addChild(nameLab)
	    headSpr[i]       : setVisible(false)
	end
	local distanceX = headSize.width + 40
	local posX = self.m_winSize.width/2 - headSize.width/2 - distanceX*2
	local posY = self.m_winSize.height/2 - 30
	if count <= 5 then
		posX = posX + distanceX * (5- count)/2
		posY = posY - 60
	end
	for i=1,count do
		if i == 6 then
			posX = posX - distanceX*5
			posY = posY - 120
		end
		headSpr[i]   : setPosition(cc.p(self.m_winSize.width/2- headSize.width/2,self.m_winSize.height/2+170))

    local move = cc.MoveTo:create(0.2,cc.p(posX + distanceX*(i-1) ,posY))
    function visible (  )
    	headSpr[i] : setVisible(true)
    end
    function touchabled(  )
      self.m_button : setVisible(true)
    end
    headSpr[i]       : runAction(cc.Sequence:create(cc.CallFunc:create(visible),move,cc.CallFunc:create(touchabled)))
	end

end

function DaemonView.showGet( self,count,data )
	if self.layer ~= nil then
    self:showEffect(data)
		return
	end

	local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_winSize=cc.Director:getInstance():getWinSize()
    self.layer =cc.LayerColor:create(cc.c4b(0,0,0,200))
    self.layer :getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.layer )
	self.m_rootLayer:addChild(self.layer,1000 )

	local function c( sender,eventType )
		if eventType == ccui.TouchEventType.ended then
			self.layer:removeFromParent(true)
			self.layer = nil
			self.pLayer = nil
		end
	end
	local function f( sender,eventType )
		self:useCallback(sender,eventType)
	end

  	local button = gc.CButton : create("general_btn_lv.png")
  	button       : setPosition(self.m_winSize.width/2+100,self.m_winSize.height/2-220)
    button       : setTitleFontSize(FONT_SIZE)
    button       : setTitleFontName(_G.FontName.Heiti)
    button       : setTitleText("返  回")
    button       : addTouchEventListener(c)
  	self.layer   : addChild(button)
  	
  	self.m_button  = gc.CButton : create()
  	self.m_button  : loadTextures("general_btn_gold.png")
  	self.m_button  : setPosition(self.m_winSize.width/2-100,self.m_winSize.height/2-220)
    self.m_button  : setTitleFontSize(FONT_SIZE)
    self.m_button  : setTitleFontName(_G.FontName.Heiti)
    self.m_button  : setTitleText("再抽一次")
    --self.m_button  : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    self.m_button  : addTouchEventListener(f)
    if count == 1 then
    	self.m_button   : setTag(TAG_ONE)
    elseif count == 10 then
    	self.m_button   : setTag(TAG_TEN)
    else
    	self.m_button   : setTag(TAG_ONE)
    end
  	self.layer   : addChild(self.m_button)

    self:showEffect(data)

  	-- self:showGoods(data)
end

function DaemonView.showGoodIcon(self, goodId, index)
	self.getSpr[index] : removeAllChildren(true)
	self.getSpr[index] : setTag(goodId)
	print(goodId)
	local spr      = _G.ImageAsyncManager:createGoodsSpr(_G.Cfg.goods[goodId])
	local size     = self.getSpr[index]:getContentSize()
	spr            : setPosition(size.width/2,size.height/2)
	self.getSpr[index] : addChild(spr)
end

function DaemonView.showEffect(self,data)
  -- self.m_button : setTouchEnabled(false)
	_G.Util:playAudioEffect("ui_draw_partner")
	self.m_button : setVisible(false)
	local effectSpr = self.layer : getChildByTag(TAG_EFFECT)
	if effectSpr ~= nil then
		effectSpr : removeFromParent(true)
	end
	local spr    = cc.Sprite:createWithSpriteFrameName("daemon_close.png")
	spr          : setPosition(self.m_winSize.width/2,self.m_winSize.height/2+170)
	local boxSize = spr:getContentSize()
	spr          : setTag(TAG_EFFECT)
	self.layer   : addChild(spr)
	local time   = cc.DelayTime:create(0.1)
	local function openBox()
		spr:setSpriteFrame("daemon_box.png")
		local effect = cc.Sprite:createWithSpriteFrameName("daemon_effect.png")
		spr          : addChild(effect)
		effect       : setPosition(boxSize.width/2,boxSize.height/2)
		--[[
		math.randomseed(os.time()) 
		for i=1,5 do
			local star = cc.Sprite:createWithSpriteFrameName("general_star2.png")
			spr        : addChild(star)
			local x    = math.random(10)*boxSize.width/10
			local y    = math.random(10)*boxSize.height/10
			star       : setPosition(cc.p(x,y))
			star       : setScale(math.random(0.5,2))
			star       : runAction(cc.RepeatForever:create(cc.Blink:create(1,5)))
		end
		]]--
		local rotaBy=cc.RotateBy:create(1,90)
		effect:runAction(cc.RepeatForever:create(rotaBy))
		self:showGoods(data)
	end
	local func   = cc.CallFunc:create(openBox)
	spr : runAction(cc.Sequence:create(time,func))
end

return DaemonView