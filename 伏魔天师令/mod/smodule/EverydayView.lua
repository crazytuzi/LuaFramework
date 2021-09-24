local EverydayView   = classGc(view,function ( self )
	self.m_winSize       = cc.Director : getInstance() : getVisibleSize()
end)

local FrameSize=cc.size(840,514)
local SecondSize=cc.size(750,450)
local isTrue=false

function EverydayView.create(self)
    self : __init()
 
	self : __createView()

	-- local tempScene=cc.Scene:create()
 --    tempScene:addChild(self.m_rootLayer)

	local msg = REQ_N_CHARGE_REQUEST()
	_G.Network: send(msg)
	
    return self.m_rootLayer
end

function EverydayView.__init(self)
    self : register()
end

function EverydayView.register(self)
    self.pMediator = require("mod.smodule.EverydayMediator")(self)
end
function EverydayView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function EverydayView.__createView( self )
	local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.Layer:create()
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)

    if isTrue==false then
    	local music="sys_topup"
    	math.randomseed(os.time())
    	local random=math.random()
    	print("dafasfas",random)
    	if random>0.5 then
    		music="sys_recharge"
    	end
    	_G.Util:playAudioEffect(music)
    	isTrue=true
    end

    self:__initView()
    return self.m_rootLayer
end

function EverydayView.__initView(self)
	local function c(sender,eventType)
    	if eventType == ccui.TouchEventType.ended then
    		self : __closeWindow()
    	end
	end

    local winSize=cc.Director:getInstance():getWinSize()
    self.m_loaderNode=cc.Node:create()
    self.m_loaderNode:setPosition(winSize.width/2,0)
    self.m_rootLayer:addChild(self.m_loaderNode)

    local framePos=cc.p(0,310)
    local frameSpr=cc.Sprite:create("ui/bg/bg_everyday.png")
    -- frameSpr:setPreferredSize(FrameSize)
    frameSpr:setPosition(framePos)
    self.m_loaderNode:addChild(frameSpr)


    self.m_closeBtn=gc.CButton:create("everyday_close.png")
    self.m_closeBtn:setPosition(winSize.width/2+FrameSize.width*0.5-75,framePos.y+FrameSize.height*0.5-33)
    self.m_closeBtn:addTouchEventListener(c)
    self.m_closeBtn:setSoundPath("bg/ui_sys_clickoff.mp3")
    self.m_closeBtn:ignoreContentAdaptWithSize(false)
    self.m_closeBtn:setContentSize(cc.size(85,85))
    self.m_rootLayer:addChild(self.m_closeBtn,10)

    -- local secondSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_right_dins.png")
    -- secondSpr:setPreferredSize(SecondSize)
    -- secondSpr:setPosition(-20,295)
    -- self.m_loaderNode:addChild(secondSpr)

    self.second_bg=frameSpr

    local function payEvent( sender,eventType )
			if eventType == ccui.TouchEventType.ended then
				_G.GLayerManager :openSubLayer(_G.Const.CONST_FUNC_OPEN_RECHARGE)
			end
		end

	self.rechargeBtn  = gc.CButton : create()
	self.rechargeBtn  : loadTextures("general_btn_gold.png")
	self.rechargeBtn  : setTouchEnabled(true)
	self.rechargeBtn  : addTouchEventListener(payEvent)
	self.rechargeBtn  : setPosition(cc.p(170,200))
	self.rechargeBtn  : setTitleFontSize(22)
	self.rechargeBtn  : setTitleFontName(_G.FontName.Heiti)
	self.rechargeBtn  : setTitleText("立即充值")
	self.m_loaderNode : addChild(self.rechargeBtn)

	local StarsGafAsset=gaf.GAFAsset:create("gaf/sc_xing.gaf")
	local StarsGaf=StarsGafAsset:createObject()
	local nPos=cc.p(70,450)
	StarsGaf:setLooped(true,true)
	StarsGaf:start()
	StarsGaf:setPosition(nPos)
	self.m_loaderNode : addChild(StarsGaf)

	local btnGafAsset=gaf.GAFAsset:create("gaf/sc_kluang.gaf")
	local btnGaf=btnGafAsset:createObject()
	local nPos=cc.p(167,200)
	btnGaf:setLooped(true,true)
	btnGaf:start()
	btnGaf:setPosition(nPos)
	self.m_loaderNode : addChild(btnGaf)

	local HuoGafAsset=gaf.GAFAsset:create("gaf/sc_huoyan.gaf")
	local HuoGaf=HuoGafAsset:createObject()
	local nPos=cc.p(-165,143)
	HuoGaf:setLooped(true,true)
	HuoGaf:start()
	HuoGaf:setPosition(nPos)
	self.m_loaderNode : addChild(HuoGaf)

	local HuoGafAsset1=gaf.GAFAsset:create("gaf/sc_huoyan.gaf")
	local HuoGaf1=HuoGafAsset1:createObject()
	local nPos=cc.p(160,143)
	HuoGaf1:setLooped(true,true)
	HuoGaf1:start()
	HuoGaf1:setPosition(nPos)
	self.m_loaderNode : addChild(HuoGaf1)

	local HuaGafAsset=gaf.GAFAsset:create("gaf/sc_hua.gaf")
	local HuaGaf=HuaGafAsset:createObject()
	local nPos=cc.p(-240,390)
	HuaGaf:setLooped(true,true)
	HuaGaf:start()
	HuaGaf:setPosition(nPos)
	self.m_loaderNode : addChild(HuaGaf)

	--local tipsIcon = cc.Sprite :createWithSpriteFrameName("general_tanhao.png")
	--tipsIcon       : setPosition(160,90)
	--self.m_loaderNode:addChild(tipsIcon)

	--local tips = _G.Util : createLabel("当日仅可领取一次",20)
	--tips       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
	--tips       : setPosition(260,88)
	--self.m_loaderNode:addChild(tips)
end

function EverydayView.initView( self,_msg )
	local day   = _msg.n_day
	
	local state = _msg.state

	self.second_bg:removeAllChildren()

	if day~=nil and (self.day==nil or self.day~=day) then
		self.day = day
		if self.btnArray then
			for k,v in pairs(self.btnArray) do
				v:removeFromParent()
			end
		end
		self.btnArray = {}
		print("day改变")
		for i=1,3 do
			local function btnEvent( sender,eventType )
				if eventType == ccui.TouchEventType.ended then
					local tag = sender:getTag()
					print(string.format("第%d天首充",tag))
					for k,v in pairs(self.btnArray) do
						print("self.btnArray",k)
						if k== tag then
							v : setEnabled(false)
							v : setBright(false)
						else
							v : setEnabled(true)
							v : setBright(true)
						end
					end

					self.select = tag

					local msg = REQ_N_CHARGE_REQUEST_N()
					msg       : setArgs(tag)
					_G.Network: send(msg)
				end
			end
			local btn = gc.CButton : create()
			btn       : loadTextures("everyday_btn_2.png","everyday_btn_1.png","everyday_btn_1.png")
			btn       : setTouchEnabled(true)
			btn 	  : setEnabled(false)
			
			if i== day then
				btn : setBright(false)
			else
				btn : setBright(true)
			end
			
			if day==1 then
				btn   : setVisible(false)
			elseif day > 1 then
				btn   : setVisible(true)
				btn   : setEnabled(true)
				if i > day then
					btn:setEnabled(false)
					btn:setGray()
				end
				self.btnArray[i] = btn
			end
			
			btn       : addTouchEventListener(btnEvent)
			btn       : setTag(i)
			btn       : setTitleFontSize(24)
			--btn       : setTitleText(string.format("第%d天首冲",i))
			btn       : setPosition(cc.p(356,430-(i-1)*115))
			self.m_loaderNode : addChild(btn)

			local title = string.format("%s日充值",_G.Lang.number_Chinese[i])
			if i==1 then
				title = "首日充值"
			end
			local name = _G.Util : createLabel(title,20)
			name       : setAnchorPoint(cc.p(0,0.5))
			name       : setDimensions(20,0)
			name       : setPosition(cc.p(9,btn:getContentSize().height/2))
			btn        : addChild(name)
		end
	end
	
	if self.select==nil then
		self.select=day
	end
	self : updateView(self.select)

	local function payEvent( sender,eventType )
			if eventType == ccui.TouchEventType.ended then
				if state == 0 then
					print("跳转到充值界面")
					_G.GLayerManager :openSubLayer(_G.Const.CONST_FUNC_OPEN_RECHARGE)
				else
					local msg = REQ_N_CHARGE_GET_REWARDS()
					_G.Network: send(msg)
				end
			end
		end

	local payBtn = gc.CButton : create()
	payBtn       : loadTextures("general_btn_gold.png")
	payBtn       : setTouchEnabled(true)
	payBtn       : addTouchEventListener(payEvent)
	payBtn       : setTitleFontSize(22)
	payBtn       : setTitleFontName(_G.FontName.Heiti)
	if state == 0 then
		payBtn   : setTitleText("领  取")
		payBtn   : setTouchEnabled(false)
		payBtn   : setGray()
	elseif state == 1 then
		payBtn   : setTitleText("领  取")
		self.rechargeBtn:setVisible(false)
	elseif state == 2 then
		payBtn   : setTitleText("已 领 取")
		payBtn   : setTouchEnabled(false)
		payBtn   : setGray()
		self.rechargeBtn:setVisible(false)
	end
	payBtn       : setPosition(cc.p(553,122))
	self.second_bg:addChild(payBtn)
	self.btn     = payBtn 
end

function EverydayView.updateView( self,_day )
	-- local _day=3
    local tips1 = cc.Sprite : createWithSpriteFrameName("everyday_tips1.png")
	tips1       : setPosition(cc.p(280,390))
	self.second_bg: addChild(tips1)

	local tips2 = cc.Sprite : createWithSpriteFrameName("everyday_tips2.png")
	tips2       : setPosition(cc.p(560,330))
	self.second_bg: addChild(tips2)

	local _Num=588 
	if _day==2 then
		_Num=688
	elseif _day==3 then
		_Num=888
	end
	local length = string.len(_Num)
    local spriteWidth = 0
    for i=1, length do
        local _tempSpr = cc.Sprite:createWithSpriteFrameName( "everyday_"..string.sub(_Num,i,i)..".png")
        -- _tempSpr:setScale(0.8)
        self.second_bg : addChild( _tempSpr )

        local _tempSprSize = _tempSpr : getContentSize()
        spriteWidth        = spriteWidth + _tempSprSize.width / 2+5
        _tempSpr           : setPosition( 270+spriteWidth,332)
    end

	local posX=0
	local posY=0
	local scgaf="gaf/sc_liehou.gaf"
	local gafPosX=280
	local gafPosY=150
	if _day==2 then
		posX=-10
		posY=38
		gafPosX=115
		gafPosY=175
		scgaf="gaf/sc_jinling.gaf"
	elseif _day==3 then
		posX=215
		posY=25
		gafPosX=397
		gafPosY=178
		scgaf="gaf/sc_long.gaf"
	end
	local tianmaSpr=cc.Sprite:create(string.format("ui/bg/everyday_reward%d.png",_day))
	tianmaSpr : setPosition(cc.p(130+posX,135+posY))
  	self.second_bg : addChild(tianmaSpr)

  	local HuoGafAsset=gaf.GAFAsset:create(scgaf)
	local HuoGaf=HuoGafAsset:createObject()
	local nPos=cc.p(gafPosX,gafPosY)
	HuoGaf:setLooped(true,true)
	HuoGaf:start()
	HuoGaf:setPosition(nPos)
	self.second_bg : addChild(HuoGaf)

	-- local meirenId={50105,50111,50113}
	-- local spine = _G.SpineManager.createSpine("spine/"..meirenId[_day])
	-- spine : setScale(0.9)
	-- spine : setPosition(cc.p(100,0))
 --  	spine : setAnimation(0,"idle",true)
 --  	self.second_bg : addChild(spine)

	local goodsDins=cc.Sprite:createWithSpriteFrameName("everyday_goods_dins.png")
    -- goodsDins:setPreferredSize(cc.size(450,150))
    goodsDins:setPosition(510,235)
    self.second_bg:addChild(goodsDins)

	for i=1,4 do
		local goodsDins = cc.Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
		goodsDins       : setPosition(cc.p(375+(i-1)*90,235))
		self.second_bg  : addChild(goodsDins)
		-- if i==1 then
		-- 	self:__showEffect(goodsDins)
		-- end

		local btnSize = goodsDins:getContentSize() 
		local winSize = cc.Director:getInstance():getVisibleSize()
		local function cFun(sender,eventType)
		  	if eventType==ccui.TouchEventType.ended then
		      	local nTag=sender:getTag()
		      	local nPos=sender:getWorldPosition()
		      	print("Tag",nTag)
		      	local rootBgSize = cc.size(790,412)
		      	if nPos.y>winSize.height/2+rootBgSize.height/2-50 
		        or nPos.y<winSize.height/2-rootBgSize.height/2-25
		        then return end

		      	local bagType=_G.Const.CONST_GOODS_SITE_OTHERROLE
		      	local temp=_G.TipsUtil:createById(nTag,bagType,nPos,self.m_curRoleUid)
		      	cc.Director:getInstance():getRunningScene():addChild(temp,1000)
		  	end
		end

		local subData=_G.Cfg.sales_sub
		local nowday=310+_day
		local tab=nil
		for k,v in pairs(subData) do
			if nowday==v.id then
				tab = v.virtue[i]
			end
		end
		if tab==nil then return end
		local node   = _G.Cfg.goods[tab[1]]

		local iconBtn=_G.ImageAsyncManager:createGoodsBtn(node,cFun,tab[1],tab[2])
    	iconBtn:setPosition(btnSize.width/2,btnSize.height/2)
    	iconBtn:setSwallowTouches(false)
    	goodsDins:addChild(iconBtn)

    	local kuangGafAsset=gaf.GAFAsset:create("gaf/sc_kuang2.gaf")
		local kuangGaf=kuangGafAsset:createObject()
		local nPos=cc.p(btnSize.width/2-7,btnSize.height/2-5)
		kuangGaf:setLooped(true,true)
		kuangGaf:start()
		kuangGaf:setPosition(nPos)
		goodsDins : addChild(kuangGaf)

    	-- local goodsCount=_G.Util:createLabel(tostring(tab[2]),18)
    	-- goodsCount:setAnchorPoint(cc.p(1,0))
    	-- goodsCount:setPosition(cc.p(btnSize.width-10,5))
    	-- goodsDins:addChild(goodsCount)
	end
end

function EverydayView.Success(self)
    _G.Util:playAudioEffect("ui_receive_awards")
end

-- function EverydayView.__showEffect(self,_sender)
--     if _sender==nil then return end

--     local m_scelectSpr=cc.Sprite:create()
--     m_scelectSpr:runAction(cc.RepeatForever:create(_G.AnimationUtil:createAnimateAction("anim/task_recharge.plist","task_recharge_",0.1)))
--     m_scelectSpr:setPosition(85/2,85/2)
--     m_scelectSpr:setScale(0.85)
--     _sender:addChild(m_scelectSpr,20)
-- end

function EverydayView.__closeWindow( self )
	if self.m_rootLayer == nil then return end
	self.m_rootLayer:removeFromParent(true)
    self.m_rootLayer=nil
	-- cc.Director:getInstance():popScene()
	self 			     : unregister()
end

return EverydayView