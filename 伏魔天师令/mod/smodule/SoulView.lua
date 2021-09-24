local SoulView = classGc(view,function(self,_pagID,uid)
    self.m_winSize  = cc.Director : getInstance() : getVisibleSize()
    self.m_mainSize = cc.size(830,478)
    self.m_leftSize = cc.size(390,468)
	self.m_rightSize= cc.size(390,468)
	self.m_myProperty=_G.GPropertyProxy:getMainPlay()
	self.role_id    = 0
	self.pagID      = _pagID or _G.Const.CONST_FUNC_OPEN_SHEN
	self.zhanGuaCount=_G.Cfg.vip[_G.GPropertyProxy : getMainPlay() : getVipLv()].douqi_times
	self.itUid      = uid
end)

local ZHAN_BTN      = 1001
local XIANG_BTN     = 1002
local ZHEN_BTN      = 1003
local ZHAN_LAYER    = 1004
local XIANG_LAYER   = 1005
local ZHEN_LAYER    = 1006
local ZHAN_RIGHT    = 1007
local ZHAN_LEFT     = 1008
local ZHAN_MONEY    = 1009
local MONEY_DINS    = 2001
local GUA_XIANG_MSG = 2002
local ZHEN_CHANGE   = 2003
local LAYER_BG      = 2004
local ZHEN_ICON_DINS= 2005
local ZHEN_ICON     = 2006
local ZHEN_NAME     = 2007
local ZHEN_ATTR     = 2008
local ZHEN_NAME_1   = 2009
local ZHEN_ATTR_1   = 3001
local ZHEN_CONSUME  = 3002
local XIANG_CHANGE  = 3003
local ZHEN_ADD      = 3004
local TYPE_XIANG    = 2
local TYPE_ZHEN    = 3

local isBuyTip   = false

function SoulView.create(self)
    self : __init()

    self.m_normalView = require("mod.general.TabUpView")()
	self.m_rootLayer  = self.m_normalView:create()
	self.m_normalView : setTitle("八卦")

    local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)
    
	self  			  : __initView()

    return tempScene
end

function SoulView.__init(self)
    self : register()
end

function SoulView.register(self)
    self.pMediator = require("mod.smodule.SoulMediator")(self)
end

function SoulView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function SoulView.__chuangeTab(self,_tab)
    if _tab==ZHAN_BTN then
        self.rotateIcon   : setPosition(cc.p(self.m_leftSize.width/2+12,self.m_leftSize.height/2+15))
        self : __zhanBtnEvent()
    elseif _tab==XIANG_BTN then
        self.rotateIcon   : setPosition(cc.p(self.m_leftSize.width/2+12,self.m_leftSize.height/2-13))
        self : __xiangBtnEvent()
        if self.m_guide_wait_equip_init then
            self.m_guide_wait_equip_init=nil
            self.m_guide_wait_equip=true
            _G.GGuideManager:registGuideData(4,self.m_guaXiang1[1][1])
            _G.GGuideManager:runNextStep()
        end
    elseif _tab==ZHEN_BTN then
        self.rotateIcon   : setPosition(cc.p(self.m_leftSize.width/2+12,self.m_leftSize.height/2-13))
        self : __zhenBtnEvent()
    end

    if self.m_guideShowTab~=nil then
        if self.m_guideShowTab==ZHAN_BTN then
            if _tab==ZHAN_BTN then
                _G.GGuideManager:showGuideByStep(1)
                _G.GGuideManager:showGuideByStep(2)
            else
                _G.GGuideManager:hideGuideByStep(1)
                _G.GGuideManager:hideGuideByStep(2)
            end
        elseif self.m_guideShowTab==XIANG_BTN then
            if _tab==XIANG_BTN then
                _G.GGuideManager:showGuideByStep(4)
            else
                _G.GGuideManager:hideGuideByStep(4)
            end
        end
    end
end

function SoulView.__initView(self)
    print("两仪八卦")
    local function nCloseFun()
		self : __closeWindow()
	end
	
    local function tabBtnCallBack(tag)
        print("tabBtnCallBack",tag)
        self.isTrue=false
        self:__chuangeTab(tag)
    end
    self.m_normalView : addCloseFun(nCloseFun)
    self.m_normalView:addTabFun(tabBtnCallBack)

    self.m_normalView:addTabButton("占卦知命",ZHAN_BTN)
    self.m_normalView:addTabButton("卦象背包",XIANG_BTN)
    self.m_normalView:addTabButton("卦阵核心",ZHEN_BTN)
    self.m_normalView:selectTagByTag(ZHAN_BTN)

    local signArray=_G.GOpenProxy:getSysSignArray()
    if signArray[_G.Const.CONST_FUNC_OPEN_SHEN_UP] then
        self.m_normalView:addSignSprite(ZHEN_BTN,_G.Const.CONST_FUNC_OPEN_SHEN_UP)
    end    

	local width=self.m_winSize.width/2 - 368
	local height = 527

	local second_bg   = ccui.Scale9Sprite : createWithSpriteFrameName("general_double.png")
	second_bg 	  	  : setPosition(cc.p(self.m_winSize.width/2+2, self.m_winSize.height/2 - 55))
	second_bg	  	  : setPreferredSize(self.m_mainSize)
	second_bg         : setTag(LAYER_BG)
	self.m_rootLayer  : addChild(second_bg,0)

	local leftBG	  = cc.Sprite : create("ui/bg/ui_soul_wuXingZhen.png")
	leftBG 			  : setAnchorPoint(cc.p(0,0))
	leftBG 	          : setPosition(cc.p(10,15))
    leftBG            : setOpacity(50)
	second_bg         : addChild(leftBG,0)

	self.rotateIcon   = cc.Sprite : create("ui/bg/ui_soul_rotate.png")
    self.rotateIcon   : setPosition(cc.p(self.m_leftSize.width/2+12,self.m_leftSize.height/2+15))
	leftBG            : addChild(self.rotateIcon)
	self.rotateIcon   : runAction(cc.RepeatForever : create(cc.RotateBy : create(20,360)))

	local rightBG	  = ccui.Scale9Sprite : createWithSpriteFrameName("general_double2.png")
	rightBG 		  : setAnchorPoint(cc.p(1,0))
	rightBG 	      : setPosition(cc.p(self.m_mainSize.width - 5,5))
	rightBG		      : setPreferredSize(self.m_rightSize)
	second_bg         : addChild(rightBG,1)

    local rightSpr    = cc.Sprite : create("ui/bg/ui_soul_rightbg.png")
    -- rightSpr            : setAnchorPoint(cc.p(0,0))
    rightSpr          : setPosition(cc.p(self.m_rightSize.width/2,self.m_rightSize.height/2))
    rightBG           : addChild(rightSpr,0)

	local zhanLayer   = cc.Layer : create()
    zhanLayer         : setContentSize( self.m_mainSize )
    zhanLayer         : setPosition(cc.p(0,0))
    zhanLayer         : setVisible(true)
    zhanLayer         : setTag(ZHAN_LAYER)

    second_bg  : addChild(zhanLayer,2)

    local xiangLayer  = cc.Layer : create()
    --xiangLayer        : setScale(383/400)
    xiangLayer        : setContentSize( self.m_mainSize )
    xiangLayer        : setPosition(cc.p(0,0))
    xiangLayer        : setVisible(false)
    xiangLayer        : setTag(XIANG_LAYER)
    second_bg  : addChild(xiangLayer,2)

    local zhenLayer   = cc.Layer : create()
    zhenLayer         : setContentSize( self.m_mainSize )
    zhenLayer         : setPosition(cc.p(0,0))
    zhenLayer         : setVisible(false)
    zhenLayer         : setTag(ZHEN_LAYER)
    second_bg  : addChild(zhenLayer,2)

    self.m_secondBgSpr=second_bg

    ---------------------------初始化占卦界面-------------------------
    self : __initZhanGuaLayer()
    ---------------------------初始化卦象界面-------------------------
    self : __initGuaXiangLayer(0,0)  
    ---------------------------初始化卦阵界面-------------------------
    self : __initGuaZhenLayer(0,0)

    if self.pagID == _G.Const.CONST_FUNC_OPEN_SHEN then
        self : __chuangeTab(ZHAN_BTN)

        local guideId=_G.GGuideManager:getCurGuideId()
        if guideId==_G.Const.CONST_NEW_GUIDE_SYS_BAGUA then
            -- local explainView  = require("mod.general.ExplainView")()
            -- local explainLayer = explainView : create(40225)
            local button2=self.m_normalView:getTabBtnByTag(XIANG_BTN)
            local closeBtn=self.m_normalView:getCloseBtn()
            _G.GGuideManager:initGuideView(self.m_rootLayer)
            _G.GGuideManager:registGuideData(1,self.m_normalZhanBtn)
            _G.GGuideManager:registGuideData(2,self.m_pickAllBtn)
            _G.GGuideManager:registGuideData(3,button2)
            _G.GGuideManager:registGuideData(5,closeBtn)
            _G.GGuideManager:runNextStep()
            self.m_guideShowTab=ZHAN_BTN
            self.m_guide_wait_zhanbu=true

            local command=CGuideNoticHide()
            controller:sendCommand(command)
        end
	elseif self.pagID == _G.Const.CONST_FUNC_OPEN_SHEN_UP then
		self : __chuangeTab(XIANG_BTN) 
		if self.itUid then
			local button1    = self.m_rootLayer : getChildByTag(ZHAN_BTN)
			local button2    = self.m_rootLayer : getChildByTag(XIANG_BTN)
			local button3    = self.m_rootLayer : getChildByTag(ZHEN_BTN)

		    button1          : setEnabled(false)
		    button1          : setGray()
		end
	elseif self.pagID == _G.Const.CONST_FUNC_OPEN_SHEN_QUALITY then
		self : __chuangeTab(ZHEN_BTN)
    end
end

function SoulView.updateVipLv( self,_msg )
	print("vip",_msg.vip,"lv",_msg.lv)
	self.m_vip = _msg.vip
	self.m_lv = _msg.lv
	self : __initGuaXiangLayer(_msg.vip,_msg.lv)
    self : __initGuaZhenLayer(_msg.vip,_msg.lv)
end

function SoulView.__initZhanGuaLayer( self )
	local zhanLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(ZHAN_LAYER)
	--初始化left
    local zhanDins = cc.Node : create()
    --zhanDins       : setScale(383/400)
    zhanDins	   : setAnchorPoint(cc.p(0,0))
    zhanDins       : setPosition(cc.p(0,0))
    zhanDins       : setTag(ZHAN_LEFT)
    zhanLayer      : addChild(zhanDins)

    local starIcon = cc.Sprite : createWithSpriteFrameName("ui_soul_guaZhen_star.png")
    starIcon       : setPosition(cc.p(self.m_leftSize.width/2+20,self.m_leftSize.height/2+30))
    zhanDins       : addChild(starIcon,0)

    local moneyDins= ccui.Scale9Sprite : createWithSpriteFrameName("ui_soul_dins.png")
    moneyDins      : setPreferredSize(cc.size(98,35))
    moneyDins      : setPosition(cc.p(self.m_leftSize.width/2+20,self.m_leftSize.height/2-37))
    moneyDins      : setTag(MONEY_DINS)
    zhanDins       : addChild(moneyDins,1)

    local function local_CallBack( obj, eventType )
        if eventType==ccui.TouchEventType.ended then
            local explainView  = require("mod.general.ExplainView")()
            local explainLayer = explainView : create(40225)
        end
    end

    local Btn_Explain  = gc.CButton : create()
    Btn_Explain : loadTextures( "general_help.png")
    Btn_Explain : setPosition( 15, self.m_leftSize.height-7 )
    Btn_Explain : setAnchorPoint( 0, 1 )
    Btn_Explain : addTouchEventListener( local_CallBack )
    zhanDins    : addChild( Btn_Explain )

    self.zhanGuaPoint=
    {
    	cc.p(self.m_leftSize.width/2+20,self.m_leftSize.height-50),
    	cc.p(self.m_leftSize.width-25,self.m_leftSize.height-160),
    	cc.p(self.m_leftSize.width/2+120,143),
    	cc.p(self.m_leftSize.width/2-80,143),
    	cc.p(65,self.m_leftSize.height-160),
    }

    for i=1,5 do
    	local iconDins = cc.Sprite : createWithSpriteFrameName("ui_soul_guaXiang.png")
	    iconDins       : setPosition(self.zhanGuaPoint[i])
	    zhanDins       : addChild(iconDins,1)

    	local icon   = cc.Sprite : createWithSpriteFrameName(string.format("ui_soul_zhanGua_%d.png",i))
	    icon         : setPosition(self.zhanGuaPoint[i])
	    zhanDins     : addChild(icon,2)
    end

    local icon_1   = cc.Sprite : createWithSpriteFrameName("ui_soul_select.png")
    icon_1         : setPosition(self.zhanGuaPoint[1].x,self.zhanGuaPoint[1].y+1)
    icon_1         : setTag(101)
    zhanDins       : addChild(icon_1,1)

    local moneyData= _G.Util : createLabel(tostring(10000),20)
    moneyData      : setAnchorPoint(cc.p(0.5,0))
    moneyData      : setPosition(cc.p(38,5))
    moneyData      : setTag(ZHAN_MONEY)
    moneyDins      : addChild(moneyData)

    local moneyIcon= cc.Sprite : createWithSpriteFrameName("general_tongqian.png")
    moneyIcon      : setAnchorPoint(cc.p(0,0))
    moneyIcon      : setPosition(cc.p(67,3))
    moneyDins      : addChild(moneyIcon)

    local function zhanGuaEvent(send,eventType)
    	self : __zhanGuaEvent(send,eventType)
    end

    -- local zhanBtnDins = cc.Sprite : createWithSpriteFrameName("ui_soul_zhanGua_dins.png")
    -- zhanBtnDins       : setPosition(cc.p(190,215))
    -- zhanDins          : addChild(zhanBtnDins)

    local zhanBtn  = gc.CButton:create()
    zhanBtn        : loadTextures("ui_soul_zhanGua.png","ui_soul_zhanGua1.png")
    zhanBtn        : setPosition(cc.p(self.m_leftSize.width/2+22,self.m_leftSize.height/2+26))
    zhanBtn        : addTouchEventListener(zhanGuaEvent)
    zhanDins       : addChild(zhanBtn,1)
    self.m_normalZhanBtn = zhanBtn

    local function oneClickZhanGua( send,eventType )
    	self : __oneClickZhanGua(send,eventType)
    end

    local oneClickButton = gc.CButton:create()
	oneClickButton : addTouchEventListener(oneClickZhanGua)
	oneClickButton : loadTextures("general_btn_lv.png")
	oneClickButton : setTitleText("一键占卦")
	oneClickButton : setTitleFontSize(24)
	oneClickButton : setTitleFontName(_G.FontName.Heiti)
	--oneClickButton : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	oneClickButton : setPosition(cc.p(self.m_leftSize.width/2-70,46))
	zhanLayer      : addChild(oneClickButton)

	local function highZhanEvent( send,eventType)
		self : __highZhanEvent(send,eventType)
	end 

	local highButton= gc.CButton:create()
	highButton     : addTouchEventListener(highZhanEvent)
	highButton     : loadTextures("general_btn_gold.png")
	highButton     : setTitleText("高级占卦")
	highButton     : setTitleFontSize(24)
	highButton     : setTitleFontName(_G.FontName.Heiti)
	highButton     : setPosition(cc.p(self.m_leftSize.width/2+110,46))
	zhanLayer      : addChild(highButton)

	--初始化right
	local zhanDins1= ccui.Widget : create()
	zhanDins1      : setContentSize(self.m_rightSize)
	zhanDins1      : setAnchorPoint(cc.p(0,0))
	zhanDins1      : setPosition(cc.p(440,60))
	zhanDins1      : setTag(ZHAN_RIGHT)   
	zhanLayer      : addChild(zhanDins1)

	local function oneClickPickEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			send : setEnabled(false)
    		send : setGray()
    		send : runAction(cc.Sequence : create(cc.DelayTime : create(1),cc.CallFunc : create(function ()
    			send : setEnabled(true)
    			send : setDefault()
    		end)))
			self : __oneClickPickEvent()
		end
	end 

	local pickButton= gc.CButton:create()
	pickButton     : addTouchEventListener(oneClickPickEvent)
	pickButton 	   : loadTextures("general_btn_lv.png")
	pickButton     : setTitleText("一键拾取")
	pickButton     : setTitleFontSize(24)
	pickButton     : setTitleFontName(_G.FontName.Heiti)
	--pickButton 	   : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	pickButton     : setPosition(cc.p(542,46))
	zhanLayer      : addChild(pickButton)
    self.m_pickAllBtn = pickButton

	local function swallowEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			send : setEnabled(false)
    		send : setGray()
    		send : runAction(cc.Sequence : create(cc.DelayTime : create(1),cc.CallFunc : create(function ()
    			send : setEnabled(true)
    			send : setDefault()
    		end)))
			local iCount = 0
			for i=1,16 do
				if (self.zhanGoodsArray[i] or 0) >= 4 then
					iCount = iCount + 1
				end
			end
			print("----------------------")
			print("高级卦象的个数：",iCount)
			print("----------------------")
			if iCount > 1 then
				self : __initSwallowTipsBox(0)
			else
				self : __swallowEvent(0)
			end
		end
	end 

	local swallowButton  = gc.CButton:create()
	swallowButton  : addTouchEventListener(swallowEvent)
	swallowButton  : loadTextures("general_btn_gold.png")
	swallowButton  : setTitleText("一键吞噬")
	swallowButton  : setTitleFontSize(24)
	swallowButton  : setTitleFontName(_G.FontName.Heiti)
	swallowButton  : setPosition(cc.p(720,46))
	zhanLayer      : addChild(swallowButton)

	self.goodsPosition = {}

	for i=1,4 do
		for j=1,4 do
			local dins = cc.Sprite : createWithSpriteFrameName("ui_soul_guaXiang.png")
			--dins       : setAnchorPoint(cc.p(0,0))
			dins       : setPosition(cc.p(49+(i-1)*(dins : getContentSize().width+15),350-(j-1)*(dins : getContentSize().height+15)))
			zhanDins1  : addChild(dins,0)
			self.goodsPosition[(j-1)*4 + i] = cc.p(49+(i-1)*(dins : getContentSize().width+15),350-(j-1)*(dins : getContentSize().height+15))
		end
	end
end

function SoulView.__initSwallowTipsBox( self,type)
	local function sure()
		self : __swallowEvent(type)
    end

    local function cancel( ... )
    	print("取消")
    end

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",sure,cancel)
    -- layer 		: setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
    view        : setTitleLabel("提示")

    local layer=view:getMainlayer()
    local lab   = _G.Util : createLabel("有紫色以上卦象,是否一键吞噬?",20)
    lab         : setPosition(cc.p(0,20))
    layer       : addChild(lab)
end

function SoulView.__initGuaXiangLayer( self,_vip,_lv )
	local guaXiangLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(XIANG_LAYER)
	--初始化left
	guaXiangLayer : removeAllChildren()

    local xiangDins = cc.Node : create()
    xiangDins	    : setAnchorPoint(cc.p(0,0))
    xiangDins       : setPosition(cc.p(0,0))
    guaXiangLayer   : addChild(xiangDins,0)

    local roundIcon = cc.Sprite : createWithSpriteFrameName("ui_soul_round.png")
    roundIcon       : setPosition(cc.p(self.m_leftSize.width/2+20,self.m_leftSize.height/2))
    xiangDins       : addChild(roundIcon,0)

    local iconName  = ""
 --    if self.role_id == 0 then
	-- 	iconName = "ui_soul_hero.png"
	-- else
	-- 	iconName = "ui_soul_daemon.png"
	-- end
	-- self.guaXiangIcon = cc.Sprite : createWithSpriteFrameName(iconName)
	-- self.guaXiangIcon : setPosition(cc.p(40,370))
	-- xiangDins         : addChild(self.guaXiangIcon)

    self.guaXiangPoint=
    {
    	cc.p(self.m_leftSize.width/2+25,self.m_leftSize.height-80),
    	cc.p(330,self.m_leftSize.height-130),
    	cc.p(370,self.m_leftSize.height/2),
    	cc.p(330,125),
    	cc.p(self.m_leftSize.width/2+25,80),
    	cc.p(100,125),
    	cc.p(60,self.m_leftSize.height/2),
    	cc.p(100,self.m_leftSize.height-130),
    	cc.p(self.m_leftSize.width/2+25,275),
    	cc.p(self.m_leftSize.width/2+25,185),
    }

    local fontSize  = 20
    local myLv      = _G.GPropertyProxy : getMainPlay() : getLv()
    local myVip	    = _G.GPropertyProxy : getMainPlay() : getVipLv()

    if self.itUid then
    	myLv      = _lv
    	myVip	  = _vip
    end
    self.m_guaXiang = {}
    self.labArr = {}
    self.guaXiangArr = {}
    local iCount = 1
    for i=1,10 do
    	local icon    = cc.Sprite : createWithSpriteFrameName("ui_soul_guaXiang.png")
	    icon          : setPosition(self.guaXiangPoint[i])
	    guaXiangLayer : addChild(icon,1)

	    local guaXiang= cc.Sprite : createWithSpriteFrameName("ui_soul_guaXiang_"..tostring(i)..".png")

	    if i == 9 then
	    	i = 60
	    elseif i == 10 then
	    	i = 61
	    end
	 
	    local lab = 0
	    if i < 60 then
	    	if self.role_id == 0 then
                lab = _G.Util : createLabel("LV."..tostring(_G.Cfg.fight_gas_open[i].open_lv),fontSize)
            else
                lab = _G.Util : createLabel("LV."..tostring(_G.Cfg.fight_gas_open[i].partner_lv),fontSize)
            end
	    else
	    	if self.role_id == 0 then
                lab = _G.Util : createLabel("VIP"..tostring(_G.Cfg.fight_gas_open[i].open_lv),fontSize)
            else
                lab = _G.Util : createLabel("VIP"..tostring(_G.Cfg.fight_gas_open[i].partner_lv),fontSize)
            end
	    end

	    local isOpen = true

	    if (_G.Cfg.fight_gas_open[i].open_lv > myLv and i < 9) or (_G.Cfg.fight_gas_open[i].open_lv > myVip  and i > 59) then
	    	isOpen = false
	    end
	    
	    if i == 60 then
	    	i = 9
	    elseif i == 61 then
	    	i = 10
	    end
	    lab           : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_ORED))
	    lab           : setPosition(self.guaXiangPoint[i])
	    lab           : setVisible(not isOpen)   
	    guaXiangLayer : addChild(lab,3)

	    self.labArr[i]= lab

	    guaXiang      : setPosition(self.guaXiangPoint[i])
	    guaXiangLayer : addChild(guaXiang,2)

	    self.guaXiangArr[i] = guaXiang

	    if not isOpen then
	    	guaXiang  : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GREY))
	    else
		    if i == 9 then
		    	self.m_guaXiang[iCount] = {icon,60}
		    elseif i == 10 then
		    	self.m_guaXiang[iCount] = {icon,61}
		    else
		    	self.m_guaXiang[iCount] = {icon,i}
		    end
	    	iCount = iCount + 1
	    end
    end

	--初始化right
	local xiangDins1= ccui.Widget : create()
	xiangDins1      : setContentSize(self.m_rightSize)
	xiangDins1      : setAnchorPoint(cc.p(0,0))
	xiangDins1      : setPosition(cc.p(440,60))  
	guaXiangLayer   : addChild(xiangDins1,0)

	-- local function switchEvent( send,eventType )
	-- 	if eventType == ccui.TouchEventType.ended then
	-- 		self : __switchEvent(TYPE_XIANG)
	-- 	end
	-- end 
	-- print("<<进来了1>>")
	-- local changeButton= gc.CButton:create()
	-- changeButton     : addTouchEventListener(switchEvent)
	-- changeButton 	 : loadTextures("general_btn_lv.png")
	-- if self.role_id == 0 then
	-- 	changeButton : setTitleText("切换灵妖")
	-- else
	-- 	changeButton : setTitleText("切换主角")
	-- end
	-- changeButton     : setTitleFontSize(24)
	-- changeButton     : setTitleFontName(_G.FontName.Heiti)
	-- --changeButton	 : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	-- changeButton     : setPosition(cc.p(492,46))
	-- changeButton     : setTag(XIANG_CHANGE)
	-- guaXiangLayer    : addChild(changeButton)

	local function swallowEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			send : setEnabled(false)
    		send : setGray()
    		send : runAction(cc.Sequence : create(cc.DelayTime : create(1),cc.CallFunc : create(function ()
    			send : setEnabled(true)
    			send : setDefault()
    		end)))
			local iCount = 0
			for i=1,16 do
				if (self.zhanGoodsArray1[i] or 0) >= 4 then
					iCount = iCount + 1
				end
			end
			if iCount > 1 then
				self : __initSwallowTipsBox(1)
			else
				self : __swallowEvent(1)
			end
		end
	end 

	local swallowButton  = gc.CButton:create()
	swallowButton  : addTouchEventListener(swallowEvent)
	swallowButton  : loadTextures("general_btn_gold.png")
	swallowButton  : setTitleText("一键吞噬")
	swallowButton  : setTitleFontSize(24)
	swallowButton  : setTitleFontName(_G.FontName.Heiti)
	swallowButton  : setPosition(cc.p(635,46))
	guaXiangLayer  : addChild(swallowButton)

	if self.itUid then
		swallowButton : setEnabled(false)
		swallowButton : setGray()
	end

	self.m_guaXiang1   = {}
	self.goodsPosition1 = {}
	local offset = 39

	for i=1,4 do
		for j=1,4 do
			local dins = cc.Sprite : createWithSpriteFrameName("ui_soul_guaXiang.png")
			dins       : setPosition(cc.p(489+(i-1)*(dins : getContentSize().width+15),410-(j-1)*(dins : getContentSize().height+15)))
			guaXiangLayer : addChild(dins,1)
			self.m_guaXiang1[(j-1)*4 + i] = {dins,(j-1)*4 + i + 8}
			self.goodsPosition1[(j-1)*4 + i] = cc.p(489+(i-1)*(dins : getContentSize().width+15),410-(j-1)*(dins : getContentSize().height+15))
		end
	end
end

function SoulView.__updateState( self,_type )
    print("刷新一下",self.role_id)
	local guaXiangLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(XIANG_LAYER)
	if _type==TYPE_ZHEN then
        guaXiangLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(ZHEN_LAYER)
    end

	local fontSize  = 20
    local myLv      = _G.GPropertyProxy : getMainPlay() : getLv()
    local myVip	    = _G.GPropertyProxy : getMainPlay() : getVipLv()

    if self.itUid then
    	myLv      = self.m_lv or 0 
    	myVip	  = self.m_vip or 0
    end

    for k,v in pairs(self.m_guaXiang) do
    	v[1]:removeFromParent()
    end

    for k,v in pairs(self.labArr) do
    	v:removeFromParent()
    end

    for k,v in pairs(self.guaXiangArr) do
    	v:removeFromParent()
    end

    self.m_guaXiang = nil
    self.labArr = nil
    self.guaXiangArr = nil

    self.m_guaXiang = {}
    self.labArr = {}
    self.guaXiangArr = {}

    local iCount = 1
    for i=1,10 do
    	local icon    = cc.Sprite : createWithSpriteFrameName("ui_soul_guaXiang.png")
	    icon          : setPosition(self.guaXiangPoint[i])
	    guaXiangLayer : addChild(icon,1)

	    local guaXiang= cc.Sprite : createWithSpriteFrameName("ui_soul_guaXiang_"..tostring(i)..".png")

	    if i == 9 then
	    	i = 60
	    elseif i == 10 then
	    	i = 61
	    end
	 
	    local lab = 0
	    if i < 60 then
	    	if self.role_id == 0 then
	    		lab = _G.Util : createLabel("LV."..tostring(_G.Cfg.fight_gas_open[i].open_lv),fontSize)
	    	else
	    		lab = _G.Util : createLabel("LV."..tostring(_G.Cfg.fight_gas_open[i].partner_lv),fontSize)
	    	end
	    else
	    	if self.role_id == 0 then
	    		lab = _G.Util : createLabel("VIP"..tostring(_G.Cfg.fight_gas_open[i].open_lv),fontSize)
	    	else
	    		lab = _G.Util : createLabel("VIP"..tostring(_G.Cfg.fight_gas_open[i].partner_lv),fontSize)
	    	end
	    end

	    local isOpen = true

	    if self.role_id == 0 then
            print("aaaaaa====?>>",i,myLv,myVip)
	    	if (_G.Cfg.fight_gas_open[i].open_lv > myLv and i < 9) or (_G.Cfg.fight_gas_open[i].open_lv > myVip  and i > 59) then
		    	isOpen = false
		    end
		else
			if (_G.Cfg.fight_gas_open[i].partner_lv > myLv and i < 9) or (_G.Cfg.fight_gas_open[i].partner_lv > myVip  and i > 59) then
		    	isOpen = false
		    end
	    end
	    
	    if i == 60 then
	    	i = 9
	    elseif i == 61 then
	    	i = 10
	    end
	    lab           : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_ORED))
	    lab           : setPosition(self.guaXiangPoint[i])
	    lab           : setVisible(not isOpen)
	    guaXiangLayer : addChild(lab,3)
	    self.labArr[i]= lab   

	    guaXiang      : setPosition(self.guaXiangPoint[i])
	    guaXiangLayer : addChild(guaXiang,2)

	    self.guaXiangArr[i] = guaXiang 

	    if not isOpen then
	    	guaXiang  : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GREY))
	    else
	    	if i == 9 then
		    	self.m_guaXiang[iCount] = {icon,60}
		    elseif i == 10 then
		    	self.m_guaXiang[iCount] = {icon,61}
		    else
		    	self.m_guaXiang[iCount] = {icon,i}
		    end
	    	iCount = iCount + 1
	    end
    end
end

function SoulView.__initGuaZhenLayer( self,_vip,_lv )
    print("__initGuaZhenLayer111")
	local guaZhenLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(ZHEN_LAYER)
	--初始化left
    guaZhenLayer : removeAllChildren()

    local zhenDins = cc.Node : create()
    zhenDins	   : setAnchorPoint(cc.p(0,0))
    zhenDins       : setPosition(cc.p(0,0))
    zhenDins       : setTag(ZHAN_LEFT)
    guaZhenLayer   : addChild(zhenDins)

    local roundIcon = cc.Sprite : createWithSpriteFrameName("ui_soul_round.png")
    roundIcon       : setPosition(cc.p(self.m_rightSize.width/2+20,self.m_rightSize.height/2))
    zhenDins        : addChild(roundIcon,0)

    local iconName  = ""
 --    if self.role_id == 0 then
	-- 	iconName = "ui_soul_hero.png"
	-- else
	-- 	iconName = "ui_soul_daemon.png"
	-- end
	-- self.guaZhenIcon = cc.Sprite : createWithSpriteFrameName(iconName)
	-- self.guaZhenIcon : setPosition(cc.p(40,370))
	-- zhenDins         : addChild(self.guaZhenIcon)

    self.guaZhenPoint=
    {
    	cc.p(self.m_leftSize.width/2+25,self.m_leftSize.height-80),
        cc.p(330,self.m_leftSize.height-130),
        cc.p(370,self.m_leftSize.height/2),
        cc.p(330,125),
        cc.p(self.m_leftSize.width/2+25,80),
        cc.p(100,125),
        cc.p(60,self.m_leftSize.height/2),
        cc.p(100,self.m_leftSize.height-130),
        cc.p(self.m_leftSize.width/2+25,275),
        cc.p(self.m_leftSize.width/2+25,185),
    }

    local fontSize  = 20
    local myLv      = _G.GPropertyProxy : getMainPlay() : getLv()
    local myVip	    = _G.GPropertyProxy : getMainPlay() : getVipLv()
    if self.itUid then
        myLv      = _lv
        myVip     = _vip
        print("__initGuaZhenLayer",_lv,_vip)
    end

    for i=1,10 do
    	local icon    = cc.Sprite : createWithSpriteFrameName("ui_soul_guaXiang.png")
	    icon          : setPosition(self.guaZhenPoint[i])
	    zhenDins      : addChild(icon,0)

	    local function clickZhenEvent( send,eventType )
			if eventType == ccui.TouchEventType.ended then
				self : __clickZhenEvent(send)
			end
		end 

	    local guaXiang= gc.CButton:create()
	    

	    if i == 9 then
	    	i = 60
	    elseif i == 10 then
	    	i = 61
	    end

	    local lab = 0

	    if i < 60 then
	    	if self.role_id == 0 then
                lab = _G.Util : createLabel("LV."..tostring(_G.Cfg.fight_gas_open[i].open_lv),fontSize)
            else
                lab = _G.Util : createLabel("LV."..tostring(_G.Cfg.fight_gas_open[i].partner_lv),fontSize)
            end
	    else
	    	if self.role_id == 0 then
                lab = _G.Util : createLabel("VIP"..tostring(_G.Cfg.fight_gas_open[i].open_lv),fontSize)
            else
                lab = _G.Util : createLabel("VIP"..tostring(_G.Cfg.fight_gas_open[i].partner_lv),fontSize)
            end
	    end

	    local isOpen = true

	    if (_G.Cfg.fight_gas_open[i].open_lv > myLv and i < 9) or (_G.Cfg.fight_gas_open[i].open_lv > myVip  and i > 59) then
	    	zhenDins     : addChild(lab,2)
	    	isOpen = false
	    end
	    
	    if i == 60 then
	    	i = 9
	    elseif i == 61 then
	    	i = 10
	    end
	    lab           : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_ORED))
	    lab           : setPosition(self.guaZhenPoint[i])  

	    guaXiang      : setTouchEnabled(isOpen)
		guaXiang      : addTouchEventListener(clickZhenEvent)
	    guaXiang      : loadTextures("ui_soul_guaXiang_"..tostring(i)..".png")
	    guaXiang      : setPosition(self.guaZhenPoint[i])
	    guaXiang      : setTag(i)
	    zhenDins      : addChild(guaXiang,1) 
	    if not isOpen then
	    	guaXiang  : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GREY))
	    end
    end
    self.selectTag=1
    self.selectIcon  = cc.Sprite : createWithSpriteFrameName("ui_soul_select.png")
    self.selectIcon  : setPosition(self.guaZhenPoint[1].x,self.guaZhenPoint[1].y+1)
    zhenDins         : addChild(self.selectIcon,3)

    --初始化right
	local zhenDins1= ccui.Widget : create()
	zhenDins1      : setContentSize(self.right)
	zhenDins1      : setAnchorPoint(cc.p(0,0))
	zhenDins1      : setPosition(cc.p(440,60))
	guaZhenLayer   : addChild(zhenDins1)

	-- local function switchEvent( send,eventType )
	-- 	if eventType == ccui.TouchEventType.ended then
	-- 		self : __switchEvent(TYPE_ZHEN)
	-- 	end
	-- end 

	-- local changeButton= gc.CButton:create()
	-- changeButton     : addTouchEventListener(switchEvent)
	-- changeButton 	 : loadTextures("general_btn_lv.png")
	-- if self.role_id == 0 then
	-- 	changeButton : setTitleText("切换灵妖")
	-- else
	-- 	changeButton : setTitleText("切换主角")
	-- end
	
	-- changeButton     : setTitleFontSize(24)
	-- changeButton     : setTitleFontName(_G.FontName.Heiti)
	-- --changeButton	 : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	-- changeButton     : setPosition(cc.p(492,46))
	-- changeButton     : setTag(ZHEN_CHANGE)
	-- guaZhenLayer     : addChild(changeButton)

	local function addLvEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			self : __addLvEvent(send,eventType)
		end
	end 

	local addLvButton= gc.CButton:create()
	addLvButton     : addTouchEventListener(addLvEvent)
	addLvButton 	: loadTextures("general_btn_gold.png")
	addLvButton     : setTitleText("升 级")
	addLvButton     : setTitleFontSize(24)
	addLvButton     : setTitleFontName(_G.FontName.Heiti)
	addLvButton     : setPosition(cc.p(635,46))
	addLvButton     : setTag(ZHEN_ADD)
	guaZhenLayer    : addChild(addLvButton)

    if self.itUid then
        print("bunengdian")
        addLvButton : setEnabled(false)
        addLvButton : setGray()
    end

	local iconDins  = cc.Sprite : createWithSpriteFrameName("ui_soul_guaXiang.png")
	-- iconDins        : setAnchorPoint(cc.p(0,0))
	iconDins        : setPosition(cc.p(635,self.m_rightSize.height-70))
	iconDins        : setTag(ZHEN_ICON_DINS)
	guaZhenLayer    : addChild(iconDins)

	local zhenIcon  = cc.Sprite : createWithSpriteFrameName("ui_soul_guaXiang_1.png")
	zhenIcon        : setPosition(cc.p(40,40))
	zhenIcon        : setTag(ZHEN_ICON)
	iconDins        : addChild(zhenIcon)

	local curName   = _G.Util : createLabel(_G.Cfg.fight_gas_open[1].g_name.._G.Lang.number_Chinese[0].."级",24)
	curName         : setTag(ZHEN_NAME)
	curName         : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
	curName         : setPosition(cc.p(635,self.m_rightSize.height-140))
	guaZhenLayer    : addChild(curName)

	local attrLab   = _G.Util : createLabel("卦象属性增加: ",20)
	attrLab         : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
	attrLab         : setPosition(cc.p(610,self.m_rightSize.height-170))
	guaZhenLayer    : addChild(attrLab)

	local attrData  = _G.Util : createLabel(tostring((_G.Cfg.fight_gas_kong[1].percent or 0)/100).."%",20)
	attrData        : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	attrData        : setAnchorPoint(cc.p(0,0.5))
	attrData        : setPosition(cc.p(680,self.m_rightSize.height-170))
	attrData        : setTag(ZHEN_ATTR)
	guaZhenLayer    : addChild(attrData)

	local addIcon   = cc.Sprite : createWithSpriteFrameName("general_tip_down.png")
    addIcon         : setRotation(90)
	addIcon         : setPosition(cc.p(635,self.m_rightSize.height/2))
	guaZhenLayer    : addChild(addIcon)

	local curName1  = _G.Util : createLabel(_G.Cfg.fight_gas_open[1].g_name.._G.Lang.number_Chinese[0].."级",24)
	curName1        : setTag(ZHEN_NAME_1)
	curName1        : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
	curName1        : setPosition(cc.p(635,self.m_rightSize.height/2-60))
	guaZhenLayer    : addChild(curName1)

	local attrLab1  = _G.Util : createLabel("卦象属性增加: ",20)
	attrLab1        : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
	attrLab1        : setPosition(cc.p(610,145))
	guaZhenLayer    : addChild(attrLab1)

	local attrData1 = _G.Util : createLabel(tostring((_G.Cfg.fight_gas_kong[1].percent or 0)/100).."%",20)
	attrData1       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	attrData1       : setAnchorPoint(cc.p(0,0.5))
	attrData1       : setPosition(cc.p(680,145))
	attrData1       : setTag(ZHEN_ATTR_1)
	guaZhenLayer    : addChild(attrData1)

	local consumeLab= _G.Util : createLabel("消耗".._G.Cfg.goods[_G.Cfg.fight_gas_kong[1].goods_list[1][1]].name..":",20)
	consumeLab      : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN))
	consumeLab      : setPosition(cc.p(610,105))
	guaZhenLayer    : addChild(consumeLab)

	local goodNums = _G.GBagProxy:getGoodsCountById(51000)

	local consumeData= _G.Util : createLabel(goodNums.."/"..tostring(_G.Cfg.fight_gas_kong[1].goods_list[1][2]),20)
	if goodNums < _G.Cfg.fight_gas_kong[1].goods_list[1][2] then
		consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED))
	else
		consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	end
	consumeData     :setAnchorPoint(cc.p(0,0.5))
	consumeData     : setPosition(cc.p(680,105))
	consumeData     : setTag(ZHEN_CONSUME)
	guaZhenLayer    : addChild(consumeData)
end

function SoulView.__zhanGuaEvent( self,send,eventType )
	if eventType == ccui.TouchEventType.ended then
		print("占卦")
		local gold=self.m_myProperty:getGold()
		local goodsCount=self.zhanGoodsArray~=nil and table.nums(self.zhanGoodsArray) or 0
		if gold>=self.money and goodsCount<16 then
			_G.Util:playAudioEffect("ui_divine")
		end
		local msg = REQ_SYS_DOUQI_ASK_START_GRASP()
		msg       : setArgs(1)
		_G.Network: send(msg)
	end
end

function SoulView.__highZhanEvent( self,send,eventType )
	if eventType == ccui.TouchEventType.ended then
		send : setEnabled(false)
		send : setGray()
		send : runAction(cc.Sequence : create(cc.DelayTime : create(1),cc.CallFunc : create(function ()
			send : setEnabled(true)
			send : setDefault()
		end)))
		print("高级占卦")
		if isBuyTip then
			local xianYu=self.m_myProperty:getRmb()
			local goodsCount=self.zhanGoodsArray~=nil and table.nums(self.zhanGoodsArray) or 0
			if xianYu>=200 and goodsCount<16 then
				_G.Util:playAudioEffect("ui_divine")
			end

			local msg = REQ_SYS_DOUQI_ASK_START_GRASP()
			msg       : setArgs(0)
			_G.Network: send(msg)
		else
			if self.zhanGuaCount and self.zhanGuaCount==0 then
				local xianYu=self.m_myProperty:getRmb()
				local goodsCount=self.zhanGoodsArray~=nil and table.nums(self.zhanGoodsArray) or 0
				if xianYu>=200 and goodsCount<16 then
					_G.Util:playAudioEffect("ui_divine")
				end
				local msg = REQ_SYS_DOUQI_ASK_START_GRASP()
				msg       : setArgs(0)
				_G.Network: send(msg)
				return
			end
			self : __initBuyLayer()
		end
	end
end

function SoulView.__initBuyLayer( self )
	print("初始化竞技场购买界面")

	local function buy()
		local xianYu=self.m_myProperty:getRmb()
		local goodsCount=self.zhanGoodsArray~=nil and table.nums(self.zhanGoodsArray) or 0
		if xianYu>=200 and goodsCount<16 then
			_G.Util:playAudioEffect("ui_divine")
		end
		local msg = REQ_SYS_DOUQI_ASK_START_GRASP()
		msg       : setArgs(0)
		_G.Network: send(msg)
    end

    local function cancel( ... )
    	print("取消")
    end

    local topLab    = "花费200元宝购买一次高级占卦"
    local centerLab = _G.Lang.LAB_N[940]
    local downLab   = _G.Lang.LAB_N[416]..": "
    local buyCount  = self.zhanGuaCount
    local rightLab  = _G.Lang.LAB_N[106]

    local szSureBtn = _G.Lang.BTN_N[1]

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",buy,cancel)
    -- layer 		: setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

    local layer=view:getMainlayer()
    view:setTitleLabel("提示")
    if topLab ~= nil then
    	print("top=================>")
        local label =_G.Util : createLabel(topLab,20)
		label 		: setPosition(cc.p(0,60))
		layer 		: addChild(label,88)
    end
    if centerLab ~= nil then
    	print("center=============>")
        local label =_G.Util : createLabel(centerLab,18)
		label 		: setPosition(cc.p(0,30))
		layer 		: addChild(label,88)
    end
    if downLab ~= nil then
    	print("down================>")
        local label =_G.Util : createLabel(downLab,20)
		label 		: setPosition(cc.p(-7,-5))
		layer 		: addChild(label,88)

		local count = _G.Util : createLabel(tostring(buyCount),20)
		count       : setAnchorPoint(cc.p(0,0.5))
		count 		: setPosition(cc.p(-7+label:getContentSize().width/2,-5))
		layer 		: addChild(count,88)

		if buyCount>0 then
			count : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
		else
			count : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
		end
    end
    if rightLab then
    	print("right===========>")
    	local label =_G.Util : createLabel(rightLab,20)
		label 		: setPosition(cc.p(25,-51))
		layer 		: addChild(label,88)
    end
    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("勾选了不再提示",isBuyTip)
            if isBuyTip then
            	isBuyTip = false
            else
            	isBuyTip = true
            end
        end
    end

    local checkbox   = ccui.CheckBox : create()
    checkbox 	     : loadTextures("general_gold_floor.png","general_gold_floor.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox 	     : setPosition(cc.p(-80,-52))
    checkbox 	     : setName("")
    checkbox 	     : addTouchEventListener(c)
    -- checkbox 	     : setAnchorPoint(cc.p(1,0.5))
    layer 			 : addChild(checkbox)
end

function SoulView.__oneClickZhanGua( self,send,eventType )
	if eventType == ccui.TouchEventType.ended then
			send : setEnabled(false)
    		send : setGray()
    		send : runAction(cc.Sequence : create(cc.DelayTime : create(1),cc.CallFunc : create(function ()
    			send : setEnabled(true)
    			send : setDefault()
    		end)))
		print("一键占卦")
		local gold=self.m_myProperty:getGold()
		local goodsCount=self.zhanGoodsArray~=nil and table.nums(self.zhanGoodsArray) or 0
		if gold>=self.money and goodsCount<16 then
			_G.Util:playAudioEffect("ui_divine")
		end
		
		local msg = REQ_SYS_DOUQI_ASK_START_GRASP()
		msg       : setArgs(2)
		_G.Network: send(msg)
	end
end

-- function SoulView.__switchEvent( self,_type )
	-- local guaXiangLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(XIANG_LAYER)
	-- local guaZhenLayer  = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(ZHEN_LAYER)

	-- local changeBtn1    = guaXiangLayer : getChildByTag(XIANG_CHANGE)
	-- local changeBtn2    = guaZhenLayer : getChildByTag(ZHEN_CHANGE)

	-- if self.role_id == 0 then
		-- self.role_id = 1
		-- changeBtn1 : setTitleText("切换主角")
		-- changeBtn2 : setTitleText("切换主角")
		-- local newIcon  = cc.SpriteFrameCache:getInstance():getSpriteFrame("ui_soul_daemon.png")
		-- self.guaXiangIcon : setSpriteFrame(newIcon)
		-- self.guaZhenIcon  : setSpriteFrame(newIcon)
	-- else
		-- self.role_id = 0
		-- changeBtn1 : setTitleText("切换灵妖")
		-- changeBtn2 : setTitleText("切换灵妖")
		-- local newIcon  = cc.SpriteFrameCache:getInstance():getSpriteFrame("ui_soul_hero.png")
		-- self.guaXiangIcon : setSpriteFrame(newIcon)
		-- self.guaZhenIcon  : setSpriteFrame(newIcon)
	-- end

-- 	self : __updateState(_type)

-- 	if self.itUid then
--     	local msg = REQ_SYS_DOUQI_OTHER_USR_GRASP()
--     	msg       : setArgs(self.itUid,self.role_id)
-- 		_G.Network: send(msg) 
--     else
--     	local msg = REQ_SYS_DOUQI_ASK_USR_GRASP()
-- 		_G.Network:send(msg) 
--     end
	
--     if self.itUid then
--         local msg = REQ_SYS_DOUQI_OTHER_CLEAR()
--         msg       : setArgs(self.itUid or myPersonUid,self.role_id)
--         _G.Network: send(msg) 
--     else
--         local msg = REQ_SYS_DOUQI_ASK_CLEAR()
--         msg       : setArgs(self.role_id)
--         _G.Network: send(msg)
--     end
-- end

function SoulView.__addLvEvent( self,send )
	local msg = REQ_SYS_DOUQI_ASK_CLEAR_STORAG()
	msg       : setArgs(self.role_id,self.currentZhen)
	_G.Network: send(msg)
end

function SoulView.__clickZhenEvent( self,send )
	local guaZhenLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(ZHEN_LAYER)
	local zhenDins     = guaZhenLayer : getChildByTag(ZHAN_LEFT)
	print("被点击了一下")
	self.selectIcon : removeFromParent()
    self.tempObj = nil
    self.selectTag=send : getTag()
	self.selectIcon = cc.Sprite : createWithSpriteFrameName("ui_soul_select.png")
	self.selectIcon : setPosition(self.guaZhenPoint[send : getTag()].x,self.guaZhenPoint[send : getTag()].y+1)
	zhenDins        : addChild(self.selectIcon,3)

	local iconDins  = guaZhenLayer : getChildByTag(ZHEN_ICON_DINS)
	local icon      = iconDins : getChildByTag(ZHEN_ICON)
	local newIcon   = cc.SpriteFrameCache:getInstance():getSpriteFrame("ui_soul_guaXiang_"..tostring(send : getTag())..".png")
	icon            : setSpriteFrame(newIcon)

	local curName   = guaZhenLayer : getChildByTag(ZHEN_NAME)
	local attrData  = guaZhenLayer : getChildByTag(ZHEN_ATTR)
	local curName1  = guaZhenLayer : getChildByTag(ZHEN_NAME_1)
	local attrData1 = guaZhenLayer : getChildByTag(ZHEN_ATTR_1)
	local consumeData= guaZhenLayer : getChildByTag(ZHEN_CONSUME)

	local id   = send : getTag()

	if id == 9 then
		id = 60
	elseif id == 10 then
		id = 61
	end

	self.currentZhen = id

	curName    : setString(_G.Cfg.fight_gas_open[id].g_name.._G.Lang.number_Chinese[self.zhenMsg[id]].."级")
	if self.zhenMsg[id] == 0 then
		attrData   : setString("0%")
	else
		attrData   : setString(tostring(_G.Cfg.fight_gas_kong[self.zhenMsg[id]].percent/100).."%")
	end
 
	if self.zhenMsg[id] > #_G.Cfg.fight_gas_kong - 1 then
		curName1   : setString("卦阵等级已满")
		curName1   : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED))
		--attrData1  : setVisible(false)
		--consumeData: setVisible(false)
		attrData1  : setString(tostring((_G.Cfg.fight_gas_kong[self.zhenMsg[id]].percent or 0)/100).."%")
		local goodNums = _G.GBagProxy:getGoodsCountById(51000)
	    consumeData: setString(goodNums.."/"..tostring(_G.Cfg.fight_gas_kong[self.zhenMsg[id]].goods_list[1][2]))
	    if goodNums < _G.Cfg.fight_gas_kong[self.zhenMsg[id]].goods_list[1][2] then
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED))
		else
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
		end

		guaZhenLayer : getChildByTag(ZHEN_ADD) : setGray()
		guaZhenLayer : getChildByTag(ZHEN_ADD) : setEnabled(false)
	else
		--attrData1  : setVisible(true)
		--consumeData: setVisible(true)
		guaZhenLayer : getChildByTag(ZHEN_ADD) : setDefault()
		guaZhenLayer : getChildByTag(ZHEN_ADD) : setEnabled(true)
		curName1   : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
		curName1   : setString(_G.Cfg.fight_gas_open[id].g_name.._G.Lang.number_Chinese[self.zhenMsg[id]+1].."级")
		attrData1  : setString(tostring((_G.Cfg.fight_gas_kong[self.zhenMsg[id]+1].percent or 0)/100).."%")
		local goodNums = _G.GBagProxy:getGoodsCountById(51000)
	    consumeData: setString(goodNums.."/"..tostring(_G.Cfg.fight_gas_kong[self.zhenMsg[id]+1].goods_list[1][2]))
	    if goodNums < _G.Cfg.fight_gas_kong[self.zhenMsg[id]+1].goods_list[1][2] then
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED))
		else
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
		end
	end
end

function SoulView.__oneClickPickEvent( self)
	print("一健拾取")
	local msg = REQ_SYS_DOUQI_ASK_GET_DQ()
	msg       : setArgs(0)
	_G.Network: send(msg)
end

function SoulView.__swallowEvent( self,type )
	print("一健吞噬")
	local msg = REQ_SYS_DOUQI_ASK_EAT()
	msg       : setArgs(type)
	_G.Network: send(msg)
end

function SoulView.updateZhanStyle( self,_msg )
	local zhanLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(ZHAN_LAYER)
	local zhanDins  = zhanLayer : getChildByTag(ZHAN_LEFT)
	local moneyDins = zhanDins : getChildByTag(MONEY_DINS)
	local moneyData = moneyDins : getChildByTag(ZHAN_MONEY)
	if _msg.all_times then
		self.zhanGuaCount = _msg.all_times - _msg.ok_times 
	end
	for i=1,5 do
		local icon = zhanDins : getChildByTag(100+i)
		if icon ~= nil then
			icon : removeFromParent()
		end
	end

    print("dasdasdsada",_msg.type_grasp)
    local grasp=_msg.type_grasp
    if grasp==108 then grasp=101 end
	local icon   = cc.Sprite : createWithSpriteFrameName("ui_soul_select.png")
    icon         : setPosition(self.zhanGuaPoint[grasp-100].x,self.zhanGuaPoint[grasp-100].y+1)
    icon         : setTag(_msg.type_grasp)
    zhanDins     : addChild(icon,2)
    print("需要花费铜钱：",_G.Cfg.fight_gas_grasp[_msg.type_grasp].price)
    moneyData    : setString(tostring(_G.Cfg.fight_gas_grasp[_msg.type_grasp].price))
    self.money = _G.Cfg.fight_gas_grasp[_msg.type_grasp].price

    if self.isTrue then
        if self.zhanbuGaf~=nil then
            self.zhanbuGaf:removeFromParent(true)
            self.zhanbuGaf=nil
        end  
        local tempGafAsset=gaf.GAFAsset:create("gaf/baguazhanbu.gaf")
        self.zhanbuGaf=tempGafAsset:createObject()
        local nPos=cc.p(self.m_leftSize.width/2+22,self.m_leftSize.height/2+26)
        self.zhanbuGaf:setLooped(false,false)
        self.zhanbuGaf:start()
        self.zhanbuGaf:setPosition(nPos)
        zhanDins : addChild(self.zhanbuGaf,1000)
    end
    self.isTrue=true
end

function SoulView.updateZhanGoods( self,_msg )
	local zhanLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(ZHAN_LAYER)
	local zhanDins1 = zhanLayer : getChildByTag(ZHAN_RIGHT)

	if self.zhanGoodsArray then
		self.zhanGoodsArray = nil
	end
	self.zhanGoodsArray = {}
	
	zhanDins1 : removeAllChildren()
	for i=1,4 do
		for j=1,4 do
			local dins = cc.Sprite : createWithSpriteFrameName("ui_soul_guaXiang.png")
			dins       : setPosition(self.goodsPosition[(j-1)*4 + i])
			zhanDins1  : addChild(dins,0)
		end
	end

	for i=1,_msg.count do
		self : showGoods(_msg.dq_msg[i],zhanDins1)
	end

    if self.m_guide_wait_zhanbu and _msg.count>0 then
        self.m_guide_wait_zhanbu=nil
        self.m_guide_wait_pickall=true
        _G.GGuideManager:runNextStep()
    end
end

function SoulView.updateXiangGoods( self,_msg )
	local xiangLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(XIANG_LAYER)

	for i=9,24 do
		local goods = xiangLayer : getChildByTag(i)
		if goods then
			goods : removeFromParent()
		end
	end

	if self.goodArray then
		self.goodArray = nil
        self.removeGaf = nil
	end

	self.goodArray = {}

	if self.zhanGoodsArray1 then
		self.zhanGoodsArray1 = nil
	end
	self.zhanGoodsArray1 = {}

	for i=1,_msg.count do
		local id   = 0
		if _msg.dq_msg[i].dq_lv <10 then
			id = _msg.dq_msg[i].dq_type*10+_msg.dq_msg[i].dq_lv
		else
			id = _msg.dq_msg[i].dq_type*100+_msg.dq_msg[i].dq_lv
		end
		self.zhanGoodsArray1[_msg.dq_msg[i].lan_id-8] = _G.Cfg.fight_gas_total[id].color

		local icon1 = ""
		local icon2 = ""
		local kind  = 0

		if _G.Cfg.fight_gas_total[id] then
			icon1 = string.format("fightgas_%d_1.png",_G.Cfg.fight_gas_total[id].pic1)
			icon2 = string.format("fightgas_%d_2.png",_G.Cfg.fight_gas_total[id].pic2)
			kind  = _G.Cfg.fight_gas_total[id].eff
		else
			icon1 = "fightgas_1251_1.png"
			icon2 = "fightgas_1251_2.png"
			kind  = 3
		end

		local dins = cc.Sprite : createWithSpriteFrameName(icon2)

		local container = ccui.Widget : create()
		container       : setContentSize(dins : getContentSize())
		container       : setTag(_msg.dq_msg[i].lan_id)
		container       : setPosition(self.goodsPosition1[_msg.dq_msg[i].lan_id-8])
		xiangLayer : addChild(container,2)

		if self.itUid then
			container : setVisible(false)
		end

		self.goodArray[_msg.dq_msg[i].lan_id] = {container,_msg.dq_msg[i]}

		dins       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
		container  : addChild(dins,0)
		print("播放动画")

		local inIcon = cc.Sprite : createWithSpriteFrameName(icon1)
		inIcon       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
		container    : addChild(inIcon,2)

		print("播放动画1")

		if kind == 1 then
			dins   : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
			inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))
		
		elseif kind == 2 then
			dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

			local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
			dins1       : setFlippedX(true)
			dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
			container   : addChild(dins1,0)

			dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

			inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(1,1),cc.ScaleTo : create(1,0.9))))
		elseif kind == 3 then
			dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(0.5,0.5),cc.ScaleTo : create(0.5,1.2))))

			inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))

			local inIcon1 = cc.Sprite : createWithSpriteFrameName(icon1)
			inIcon1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
			inIcon1 : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
			container     : addChild(inIcon1,1)
		elseif kind == 4 then
			inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))	
		elseif kind == 5 then
			dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

			local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
			dins1       : setFlippedX(true)
			dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
			container   : addChild(dins1,0)

			dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

			inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.FadeTo : create(1,255),cc.FadeTo : create(1,255*0.7))))	
		end

		local nameDins= ccui.Scale9Sprite : createWithSpriteFrameName("ui_soul_dins.png")
		nameDins      : setPreferredSize(cc.size(80,25))     
		nameDins      : setPosition(cc.p(container : getContentSize().width/2,10))
		container     : addChild(nameDins,2)

		local name = _G.Util : createLabel(_G.Cfg.fight_gas_total[id].gas_name,16)
		name       : setColor(_G.ColorUtil : getRGBA(_G.Cfg.fight_gas_total[id].color))
		name       : setAnchorPoint(cc.p(0.5,0.5))
		name       : setPosition(cc.p(container : getContentSize().width/2,9))
		container  : addChild(name,3)
	end
end

function SoulView.updateZhenMsg( self,_msg )
	print("updateZhenMsg")
	self.zhenMsg = {0,0,0,0,0,0,0,0}
	self.zhenMsg[60] = 0
	self.zhenMsg[61] = 0

	self.currentZhen = 1

	for i=1,_msg.count do
		print("zhenMsg",i)
		self.zhenMsg[_msg.data[i].lan_id] = _msg.data[i].lan_lv
	end

	local guaZhenLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(ZHEN_LAYER)
	local zhenDins  = guaZhenLayer : getChildByTag(ZHAN_LEFT)
	self.selectIcon : removeFromParent()
    self.tempObj = nil
    self.selectTag=1
	self.selectIcon = cc.Sprite : createWithSpriteFrameName("ui_soul_select.png")
	self.selectIcon : setPosition(self.guaZhenPoint[1].x,self.guaZhenPoint[1].y+1)
	zhenDins        : addChild(self.selectIcon,3)

	local curName   = guaZhenLayer : getChildByTag(ZHEN_NAME)
	local attrData  = guaZhenLayer : getChildByTag(ZHEN_ATTR)
	local curName1  = guaZhenLayer : getChildByTag(ZHEN_NAME_1)
	local attrData1 = guaZhenLayer : getChildByTag(ZHEN_ATTR_1)
	local consumeData= guaZhenLayer : getChildByTag(ZHEN_CONSUME)

	curName    : setString(_G.Cfg.fight_gas_open[1].g_name.._G.Lang.number_Chinese[self.zhenMsg[1]].."级")
	if self.zhenMsg[1] == 0 then
		attrData   : setString("0%")
	else
		attrData   : setString(tostring(_G.Cfg.fight_gas_kong[self.zhenMsg[1]].percent/100).."%")
	end

	if self.zhenMsg[1] >#_G.Cfg.fight_gas_kong - 1 then
		curName1   : setString("卦阵等级已满")
		curName1   : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED))
		--attrData1  : setVisible(false)
		--consumeData: setVisible(false)
		attrData1  : setString(tostring((_G.Cfg.fight_gas_kong[self.zhenMsg[1]].percent or 0)/100).."%")
		local goodNums = _G.GBagProxy:getGoodsCountById(51000)
	    consumeData: setString(goodNums.."/"..tostring(_G.Cfg.fight_gas_kong[self.zhenMsg[1]].goods_list[1][2]))
	    if goodNums < _G.Cfg.fight_gas_kong[self.zhenMsg[1]].goods_list[1][2] then
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED))
		else
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
		end

		guaZhenLayer : getChildByTag(ZHEN_ADD) : setGray()
		guaZhenLayer : getChildByTag(ZHEN_ADD) : setEnabled(false)
	else
		--attrData1  : setVisible(true)
		--consumeData: setVisible(true)
        if self.itUid==nil then
    		guaZhenLayer : getChildByTag(ZHEN_ADD) : setDefault()
    		guaZhenLayer : getChildByTag(ZHEN_ADD) : setEnabled(true)
        end
		curName1   : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
		curName1   : setString(_G.Cfg.fight_gas_open[1].g_name.._G.Lang.number_Chinese[self.zhenMsg[1]+1].."级")
		attrData1  : setString(tostring((_G.Cfg.fight_gas_kong[self.zhenMsg[1]+1].percent or 0)/100).."%")
		local goodNums = _G.GBagProxy:getGoodsCountById(51000)
	    consumeData: setString(goodNums.."/"..tostring(_G.Cfg.fight_gas_kong[self.zhenMsg[1]+1].goods_list[1][2]))
	    if goodNums < _G.Cfg.fight_gas_kong[self.zhenMsg[1]+1].goods_list[1][2] then
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED))
		else
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
		end
	end
end

function SoulView.updateAddZhen( self,_msg )
	self.zhenMsg[_msg.lan_id] = _msg.lan_lv
	local guaZhenLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(ZHEN_LAYER)

	local curName   = guaZhenLayer : getChildByTag(ZHEN_NAME)
	local attrData  = guaZhenLayer : getChildByTag(ZHEN_ATTR)
	local curName1  = guaZhenLayer : getChildByTag(ZHEN_NAME_1)
	local attrData1 = guaZhenLayer : getChildByTag(ZHEN_ATTR_1)
	local consumeData= guaZhenLayer : getChildByTag(ZHEN_CONSUME)

	local id   = _msg.lan_id

	curName    : setString(_G.Cfg.fight_gas_open[id].g_name.._G.Lang.number_Chinese[self.zhenMsg[id]].."级")
	if self.zhenMsg[id] == 0 then
		attrData   : setString("0%")
	else
		attrData   : setString(tostring(_G.Cfg.fight_gas_kong[self.zhenMsg[id]].percent/100).."%")
	end

	if (self.zhenMsg[id]+1) >#_G.Cfg.fight_gas_kong then
		curName1   : setString("卦阵等级已满")
		curName1   : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED))
		--attrData1  : setVisible(false)
		--consumeData: setVisible(false)
		attrData1  : setString(tostring((_G.Cfg.fight_gas_kong[self.zhenMsg[id]].percent or 0)/100).."%")
		local goodNums = _G.GBagProxy:getGoodsCountById(51000)
	    consumeData: setString(goodNums.."/"..tostring(_G.Cfg.fight_gas_kong[self.zhenMsg[id]].goods_list[1][2]))
	    if goodNums < _G.Cfg.fight_gas_kong[self.zhenMsg[id]].goods_list[1][2] then
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED))
		else
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
		end

		guaZhenLayer : getChildByTag(ZHEN_ADD) : setGray()
		guaZhenLayer : getChildByTag(ZHEN_ADD) : setEnabled(false)
	else
		--attrData1  : setVisible(true)
		--consumeData: setVisible(true)
		if self.itUid==nil then
            guaZhenLayer : getChildByTag(ZHEN_ADD) : setDefault()
            guaZhenLayer : getChildByTag(ZHEN_ADD) : setEnabled(true)
        end
		curName1   : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD))
		curName1   : setString(_G.Cfg.fight_gas_open[id].g_name.._G.Lang.number_Chinese[self.zhenMsg[id]+1].."级")
		attrData1  : setString(tostring((_G.Cfg.fight_gas_kong[self.zhenMsg[id]+1].percent or 0)/100).."%")
		local goodNums = _G.GBagProxy:getGoodsCountById(51000)
	    consumeData: setString(goodNums.."/"..tostring(_G.Cfg.fight_gas_kong[self.zhenMsg[id]+1].goods_list[1][2]))
	    if goodNums < _G.Cfg.fight_gas_kong[self.zhenMsg[id]+1].goods_list[1][2] then
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED))
		else
			consumeData : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
		end
	end
end

function SoulView.oneClickUpdate( self,_msg )
	local zhanLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(ZHAN_LAYER)
	local zhanDins1 = zhanLayer : getChildByTag(ZHAN_RIGHT)
	print("一键占卜的物品个数：  ",_msg.count)
	
	local scene = cc.Director:getInstance():getRunningScene()

	local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    local m_rootLayer=cc.Layer:create()
    m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,m_rootLayer)

    cc.Director:getInstance():getRunningScene():addChild(m_rootLayer,9999)

	for i=1,_msg.count do
		local function call_fun()
			self : showGoods(_msg.msg_more[i].msg_dq,zhanDins1)
			if i== _msg.count then
				m_rootLayer : removeFromParent()
			end
		end
		scene:runAction(cc.Sequence:create(cc.DelayTime:create(i*0.03),cc.CallFunc:create(call_fun)))
	end

    if self.m_guide_wait_zhanbu then
        self.m_guide_wait_zhanbu=nil
        self.m_guide_wait_pickall=true
        _G.GGuideManager:runNextStep()
    end
end

function SoulView.pickUpdate( self,_msg )
	local zhanLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(ZHAN_LAYER)
	local zhanDins1 = zhanLayer : getChildByTag(ZHAN_RIGHT)
	for i=1,_msg.count do
		zhanDins1 : getChildByTag(_msg.lan_msg[i].lan_id) : removeFromParent()
		self.zhanGoodsArray[_msg.lan_msg[i].lan_id-25] = 0
	end
    if self.m_guide_wait_pickall then
        self.m_guide_wait_pickall=nil
        self.m_guideShowTab=XIANG_BTN
        self.m_guide_wait_equip_init=XIANG_BTN
        _G.GGuideManager:runNextStep()
    end
end

function SoulView.equipUpdate( self,_msg )
	print("有",_msg.count,"   ".._msg.role_msg[1].msg_count,"  ".._msg.role_msg[2].msg_count.."  ".."个装备")
	local xiangLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(XIANG_LAYER)
	for i=1,10 do
		if i == 9  then
			i = 60
		elseif i==10 then
			i = 61
		end
		local icon   = xiangLayer : getChildByTag(i)
		if icon then
			icon : removeFromParent()
		end
		if i == 60  then
			i = 9
		elseif i==61 then
			i = 10
		end
	end
	if self.goodArray1 then
		self.goodArray1 = nil
        self.removeGaf=nil
	end
	self.goodArray1 = {}

	for j=1,_msg.count do
		for i=1,_msg.role_msg[j].msg_count do

			if _msg.role_msg[j].role_id == self.role_id then
				local id   = 0
				if _msg.role_msg[j].msg_storage_xxx[i].dq_lv <10 then
					id = _msg.role_msg[j].msg_storage_xxx[i].dq_type*10+_msg.role_msg[j].msg_storage_xxx[i].dq_lv
				else
					id = _msg.role_msg[j].msg_storage_xxx[i].dq_type*100+_msg.role_msg[j].msg_storage_xxx[i].dq_lv
				end

				local icon1 = ""
				local icon2 = ""
				local kind  = 0

				if _G.Cfg.fight_gas_total[id] then
					icon1 = string.format("fightgas_%d_1.png",_G.Cfg.fight_gas_total[id].pic1)
					icon2 = string.format("fightgas_%d_2.png",_G.Cfg.fight_gas_total[id].pic2)
					kind  = _G.Cfg.fight_gas_total[id].eff
				else
					icon1 = "fightgas_1251_1.png"
					icon2 = "fightgas_1251_2.png"
					kind  = 3
				end

				local dins = cc.Sprite : createWithSpriteFrameName(icon2)

				local container = ccui.Widget : create()
				container       : setContentSize(dins : getContentSize())
				container       : setTag(_msg.role_msg[j].msg_storage_xxx[i].lan_id)

				print("dddddddddd",_msg.role_msg[j].msg_storage_xxx[i].lan_id)

				if _msg.role_msg[j].msg_storage_xxx[i].lan_id == 60 then
					container    : setPosition(self.guaXiangPoint[9])
				elseif _msg.role_msg[j].msg_storage_xxx[i].lan_id == 61 then
					container    : setPosition(self.guaXiangPoint[10])
				else
					container    : setPosition(self.guaXiangPoint[_msg.role_msg[j].msg_storage_xxx[i].lan_id])
				end
				xiangLayer : addChild(container,3)

				dins       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
				container  : addChild(dins,0)

				local inIcon = cc.Sprite : createWithSpriteFrameName(icon1)
				inIcon       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
				container    : addChild(inIcon,2)

				if kind == 1 then
					dins   : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
					inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))
				
				elseif kind == 2 then
					dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

					local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
					dins1       : setFlippedX(true)
					dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
					container   : addChild(dins1,0)

					dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

					inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(1,1),cc.ScaleTo : create(1,0.9))))
				elseif kind == 3 then
					dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(0.5,0.5),cc.ScaleTo : create(0.5,1.2))))

					inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))

					local inIcon1 = cc.Sprite : createWithSpriteFrameName(icon1)
					inIcon1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
					inIcon1 : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
					container     : addChild(inIcon1,1)
				elseif kind == 4 then
					inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))	
				elseif kind == 5 then
					dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

					local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
					dins1       : setFlippedX(true)
					dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
					container   : addChild(dins1,0)

					dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

					inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.FadeTo : create(1,255),cc.FadeTo : create(1,255*0.7))))	
				end

				self.goodArray1[_msg.role_msg[j].msg_storage_xxx[i].lan_id] = {container,_msg.role_msg[j].msg_storage_xxx[i]}

				local nameDins= ccui.Scale9Sprite : createWithSpriteFrameName("ui_soul_dins.png")
				nameDins      : setPreferredSize(cc.size(80,25))
				nameDins      : setPosition(cc.p(container : getContentSize().width/2,10))
				container     : addChild(nameDins,2)

				local name = _G.Util : createLabel(_G.Cfg.fight_gas_total[id].gas_name,16)
				name       : setColor(_G.ColorUtil : getRGBA(_G.Cfg.fight_gas_total[id].color))
				name       : setAnchorPoint(cc.p(0.5,0.5))
				name       : setPosition(cc.p(container : getContentSize().width/2,9))
				container  : addChild(name,3)
			end
		end
	end
end

function SoulView.moveUpdate( self,_msg )
	print("删除旧卦象")
	local xiangLayer = self.m_rootLayer : getChildByTag(LAYER_BG) : getChildByTag(XIANG_LAYER)
	if self.m_isMove then
		local oldGoods =  xiangLayer : getChildByTag(self.endGood[2])
		if oldGoods then
			oldGoods : removeFromParent()
		end
	end
	self.beginGood = nil
	self.endGood   = nil
	self.m_isMove  = false
	local button1    = self.m_rootLayer : getChildByTag(ZHAN_BTN)
	local button3    = self.m_rootLayer : getChildByTag(ZHEN_BTN)
	button1 : setEnabled(true)
	button3 : setEnabled(true)

	if _msg.lanid_start < 9 or _msg.lanid_start >= 60 then
		local icon   = xiangLayer : getChildByTag(_msg.lanid_start)
		if icon then
			self.goodArray1[_msg.lanid_start] = nil
			icon : removeFromParent()
            self.removeGaf=nil
		end
	else
		local icon = xiangLayer : getChildByTag(_msg.lanid_start)
		if icon then
			self.goodArray[_msg.lanid_start] = nil
			self.zhanGoodsArray1[_msg.lanid_start-8] = 0
			icon : removeFromParent()
            self.removeGaf=nil
		end
	end
	if _msg.lanid_end < 9 or _msg.lanid_end >= 60 then
		if self.isEffectPlaying then
			self.isEffectPlaying = nil
		else
			_G.Util:playAudioEffect("ui_equip_change")
		end

        if self.m_guide_wait_equip then
            self.m_guide_wait_equip=nil
            _G.GGuideManager:runNextStep()
        end
		
		for i=1,_msg.count do
			local id   = 0
			if _msg.dq_msg[i].dq_lv <10 then
				id = _msg.dq_msg[i].dq_type*10+_msg.dq_msg[i].dq_lv
			else
				id = _msg.dq_msg[i].dq_type*100+_msg.dq_msg[i].dq_lv
			end

			local icon1 = ""
			local icon2 = ""
			local kind  = 0

			if _G.Cfg.fight_gas_total[id] then
				icon1 = string.format("fightgas_%d_1.png",_G.Cfg.fight_gas_total[id].pic1)
				icon2 = string.format("fightgas_%d_2.png",_G.Cfg.fight_gas_total[id].pic2)
				kind  = _G.Cfg.fight_gas_total[id].eff
			else
				icon1 = "fightgas_1251_1.png"
				icon2 = "fightgas_1251_2.png"
				kind  = 3
			end

			local dins = cc.Sprite : createWithSpriteFrameName(icon2)

			local container = ccui.Widget : create()
			container       : setContentSize(dins : getContentSize())
			container       : setTag(_msg.dq_msg[i].lan_id)
			if _msg.lanid_end == 60 then
				_msg.lanid_end = 9
			elseif _msg.lanid_end == 61 then
				_msg.lanid_end = 10
			end
			container  : setPosition(self.guaXiangPoint[_msg.lanid_end])
			xiangLayer : addChild(container,2)

			if _msg.lanid_end == 9 then
				_msg.lanid_end = 60
			elseif _msg.lanid_end == 10 then
				_msg.lanid_end = 61
			end

		    self.goodArray1[_msg.dq_msg[i].lan_id] = {container,_msg.dq_msg[i]}

			dins       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
			container  : addChild(dins,0)

			local inIcon = cc.Sprite : createWithSpriteFrameName(icon1)
			inIcon       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
			container    : addChild(inIcon,2)

			if kind == 1 then
				dins   : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
				inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))
			
			elseif kind == 2 then
				dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

				local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
				dins1       : setFlippedX(true)
				dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
				container   : addChild(dins1,0)

				dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

				inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(1,1),cc.ScaleTo : create(1,0.9))))
			elseif kind == 3 then
				dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(0.5,0.5),cc.ScaleTo : create(0.5,1.2))))

				inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))

				local inIcon1 = cc.Sprite : createWithSpriteFrameName(icon1)
				inIcon1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
				inIcon1 : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
				container     : addChild(inIcon1,1)
			elseif kind == 4 then
				inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))	
			elseif kind == 5 then
				dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

				local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
				dins1       : setFlippedX(true)
				dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
				container   : addChild(dins1,0)

				dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

				inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.FadeTo : create(1,255),cc.FadeTo : create(1,255*0.7))))	
			end

			local nameDins= ccui.Scale9Sprite : createWithSpriteFrameName("ui_soul_dins.png")
			nameDins      : setPreferredSize(cc.size(80,25))
			nameDins      : setPosition(cc.p(container : getContentSize().width/2,10))
			container     : addChild(nameDins,2)

			local name = _G.Util : createLabel(_G.Cfg.fight_gas_total[id].gas_name,16)
			name       : setColor(_G.ColorUtil : getRGBA(_G.Cfg.fight_gas_total[id].color))
			name       : setAnchorPoint(cc.p(0.5,0.5))
			name       : setPosition(cc.p(container : getContentSize().width/2,9))
			container  : addChild(name,3)
		end
	else
		for i=1,_msg.count do
			local id   = 0
			if _msg.dq_msg[i].dq_lv <10 then
				id = _msg.dq_msg[i].dq_type*10+_msg.dq_msg[i].dq_lv
			else
				id = _msg.dq_msg[i].dq_type*100+_msg.dq_msg[i].dq_lv
			end
			self.zhanGoodsArray1[_msg.dq_msg[i].lan_id-8] = _G.Cfg.fight_gas_total[id].color

			local icon1 = ""
			local icon2 = ""
			local kind  = 0

			if _G.Cfg.fight_gas_total[id] then
				icon1 = string.format("fightgas_%d_1.png",_G.Cfg.fight_gas_total[id].pic1)
				icon2 = string.format("fightgas_%d_2.png",_G.Cfg.fight_gas_total[id].pic2)
				kind  = _G.Cfg.fight_gas_total[id].eff
			else
				icon1 = "fightgas_1251_1.png"
				icon2 = "fightgas_1251_2.png"
				kind  = 3
			end

			local dins = cc.Sprite : createWithSpriteFrameName(icon2)

			local container = ccui.Widget : create()
			container       : setContentSize(dins : getContentSize())
			container       : setTag(_msg.dq_msg[i].lan_id)
			container       : setPosition(self.goodsPosition1[_msg.dq_msg[i].lan_id-8])
			xiangLayer : addChild(container,2)

			if self.itUid then
				container : setVisible(false)
			end

			self.goodArray[_msg.dq_msg[i].lan_id] = {container,_msg.dq_msg[i]}

			dins       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
			container  : addChild(dins,0)

			local inIcon = cc.Sprite : createWithSpriteFrameName(icon1)
			inIcon       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
			container    : addChild(inIcon,2)

			if kind == 1 then
				dins   : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
				inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))
			
			elseif kind == 2 then
				dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

				local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
				dins1       : setFlippedX(true)
				dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
				container   : addChild(dins1,0)

				dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

				inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(1,1),cc.ScaleTo : create(1,0.9))))
			elseif kind == 3 then
				dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(0.5,0.5),cc.ScaleTo : create(0.5,1.2))))

				inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))

				local inIcon1 = cc.Sprite : createWithSpriteFrameName(icon1)
				inIcon1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
				inIcon1 : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
				container     : addChild(inIcon1,1)
			elseif kind == 4 then
				inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))	
			elseif kind == 5 then
				dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

				local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
				dins1       : setFlippedX(true)
				dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
				container   : addChild(dins1,0)

				dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

				inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.FadeTo : create(1,255),cc.FadeTo : create(1,255*0.7))))	
			end

			local nameDins= ccui.Scale9Sprite : createWithSpriteFrameName("ui_soul_dins.png")
			nameDins      : setPreferredSize(cc.size(80,25))
			nameDins      : setPosition(cc.p(container : getContentSize().width/2,10))
			container     : addChild(nameDins,2)

			local name = _G.Util : createLabel(_G.Cfg.fight_gas_total[id].gas_name,16)
			name       : setColor(_G.ColorUtil : getRGBA(_G.Cfg.fight_gas_total[id].color))
			name       : setAnchorPoint(cc.p(0.5,0.5))
			name       : setPosition(cc.p(container : getContentSize().width/2,9))
			container  : addChild(name,3)
		end
	end
    if self.isRemoveTrue then
        print("showRemoveOkEffect===>>>11111",_msg.lanid_end,self.goodArray[_msg.lanid_end])
        if _msg.lanid_end~=nil and self.goodArray[_msg.lanid_end]~=nil then
            local endIcon   = self.goodArray[_msg.lanid_end][1]
            self:showRemoveOkEffect(endIcon)
        end
        if _msg.lanid_end~=nil and self.goodArray1[_msg.lanid_end]~=nil then
            local endIcon   = self.goodArray1[_msg.lanid_end][1]
            self:showRemoveOkEffect(endIcon)
        end
        self.isRemoveTrue=nil
    end
end

function SoulView.__clickGuaXiangEvent( self,type,id,exp,lan_id,dq_id )
	self : __initGuaXiangMsg(type,id,exp,lan_id,dq_id)
end

function SoulView.__initGuaXiangMsg( self,_type,id,exp,lan_id,dq_id )
	local size = cc.Director : getInstance() : getWinSize()

    local function onTouchBegan()
    	print("删除卦象信息界面")
    	if self.SnatchBtn ~= nil then
    		self.SnatchBtn = nil
    	end
    	cc.Director : getInstance() : getRunningScene() : runAction(cc.Sequence : create(cc.DelayTime : create(0.05),cc.CallFunc : create(function (  )
    		cc.Director : getInstance() : getRunningScene() : getChildByTag(GUA_XIANG_MSG) : removeFromParent()
    		print("成功删除背景")
    	end)))
		return true 
	end
	local listerner = cc.EventListenerTouchOneByOne : create()
	listerner 	    : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner 		: setSwallowTouches(true)

	local gxMsgLayer = cc.Layer:create()
	gxMsgLayer 	    : getEventDispatcher() : addEventListenerWithSceneGraphPriority(listerner, gxMsgLayer)
	gxMsgLayer 	    : setPosition(cc.p(size.width/2, size.height/2))
	gxMsgLayer 	    : setTag(GUA_XIANG_MSG)
	cc.Director 	: getInstance() : getRunningScene() : addChild(gxMsgLayer,888)
	
    local kHeight=0
    if _G.Cfg.fight_gas_total[id].attr_two>0 then
        kHeight=40
    end

	local m_bgSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_bagkuang.png")
	m_bgSpr	  	  : setPreferredSize(cc.size(330,280+kHeight))
	m_bgSpr 	  : setPosition(cc.p(0,-20))
	gxMsgLayer    : addChild(m_bgSpr)

	local function bgEvent(  )
		return true
	end

	local label   = ccui.Widget : create()
	label         : setContentSize( cc.size(330,280+kHeight) )
	label 		  : setPosition(cc.p(0,-20))
	label         : setTouchEnabled(true)
	label         : addTouchEventListener(bgEvent)
	gxMsgLayer 	  : addChild(label)

	local fontSize= 20

	local name    = _G.Util : createLabel(string.format("%s    LV.%d",_G.Cfg.fight_gas_total[id].gas_name,_G.Cfg.fight_gas_total[id].lv),fontSize)
	name          : setColor(_G.ColorUtil : getRGB(_G.Cfg.fight_gas_total[id].color))
	name          : setAnchorPoint(cc.p(0,0))
	name          : setPosition(cc.p(15,245+kHeight))
	label         : addChild(name)

	local icon1 = ""
	local icon2 = ""
	local kind  = 0

	if _G.Cfg.fight_gas_total[id] then
		icon1 = string.format("fightgas_%d_1.png",_G.Cfg.fight_gas_total[id].pic1)
		icon2 = string.format("fightgas_%d_2.png",_G.Cfg.fight_gas_total[id].pic2)
		kind  = _G.Cfg.fight_gas_total[id].eff
	else
		icon1 = "fightgas_1251_1.png"
		icon2 = "fightgas_1251_2.png"
		kind  = 3
	end

	local dins = cc.Sprite : createWithSpriteFrameName(icon2)

	local container = ccui.Widget : create()
	container       : setContentSize(dins : getContentSize())
	container       : setAnchorPoint(cc.p(0,0))
	container       : setPosition(cc.p(19,163+kHeight))
	label           : addChild(container,2)

	dins       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
	container  : addChild(dins,0)

	local inIcon = cc.Sprite : createWithSpriteFrameName(icon1)
	inIcon       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
	container    : addChild(inIcon,2)

	if kind == 1 then
		dins   : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
		inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))
	
	elseif kind == 2 then
		dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

		local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
		dins1       : setFlippedX(true)
		dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
		container   : addChild(dins1,0)

		dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

		inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(1,1),cc.ScaleTo : create(1,0.9))))
	elseif kind == 3 then
		dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(0.5,0.5),cc.ScaleTo : create(0.5,1.2))))

		inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))

		local inIcon1 = cc.Sprite : createWithSpriteFrameName(icon1)
		inIcon1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
		inIcon1 : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
		container     : addChild(inIcon1,1)
	elseif kind == 4 then
		inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))	
	elseif kind == 5 then
		dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

		local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
		dins1       : setFlippedX(true)
		dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
		container   : addChild(dins1,0)

		dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

		inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.FadeTo : create(1,255),cc.FadeTo : create(1,255*0.7))))	
	end

	local dins1   = cc.Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
	dins1         : setAnchorPoint(cc.p(0,0))
	dins1         : setPosition(cc.p(15,162+kHeight))
	label         : addChild(dins1,1)

    local expLab  = _G.Util : createLabel("下级所需经验:",fontSize)
	-- expLab        : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
	expLab        : setAnchorPoint(cc.p(0,0))
	expLab        : setPosition(cc.p(105,205+kHeight))
	label         : addChild(expLab)

	local expDins = cc.Sprite : createWithSpriteFrameName("main_exp_2.png")
	expDins       : setAnchorPoint(cc.p(0,0.5))
	expDins       : setScale(220/312)
	expDins       : setPosition(cc.p(105,185+kHeight))
	label         : addChild(expDins,0)

	local loadingBar=ccui.LoadingBar:create()
    loadingBar:loadTexture("main_exp.png",ccui.TextureResType.plistType)
    loadingBar:setPosition(105,185+kHeight)
    loadingBar:setAnchorPoint(cc.p(0,0.5))
    loadingBar:setScale(220/296)
    loadingBar:setPercent((exp/_G.Cfg.fight_gas_total[id].next_lv_exp)*100)
    label:addChild(loadingBar,1)

	local expdata = _G.Util : createLabel(exp.."/".._G.Cfg.fight_gas_total[id].next_lv_exp,16)
	-- expdata       : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
	expdata       : setPosition(cc.p(210,185+kHeight))
	label         : addChild(expdata,3)

    local line1 = ccui.Scale9Sprite : createWithSpriteFrameName("general_voice_dins.png")
    line1       : setPreferredSize( cc.size(310, 80+kHeight) )
    line1       : setAnchorPoint( cc.p(0,0) )
    line1       : setPosition(cc.p(10,75))
    label       : addChild(line1,0)
    
    local attrLab= _G.Util : createLabel("当前属性:  ",fontSize)
	-- attrLab     : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
	attrLab     : setAnchorPoint(cc.p(0,0))
	attrLab     : setPosition(cc.p(30,120))
	label       : addChild(attrLab)

    local willLab= _G.Util : createLabel("下级属性:  ",fontSize)
    -- willLab     : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
    willLab     : setAnchorPoint(cc.p(0,0))
    willLab     : setPosition(cc.p(30,85))
    label       : addChild(willLab)

    local attrWidth = 30+attrLab:getContentSize().width
    local gasData=_G.Cfg.fight_gas_total[id]

    local attrLab1= _G.Util : createLabel((_G.Lang.type_name[gasData.attr_type_one]or" ").." +"..tostring(gasData.attr_one),fontSize)
    attrLab1     : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    attrLab1     : setAnchorPoint(cc.p(0,0))
    attrLab1     : setPosition(cc.p(attrWidth,120))
    label       : addChild(attrLab1)

	if gasData.attr_two >0 then 
        attrLab:setPositionY(160)
        attrLab1:setPositionY(160)
		attrLab2= _G.Util : createLabel((_G.Lang.type_name[gasData.attr_type_two]or" ").." +"..tostring(gasData.attr_two),fontSize)
		attrLab2     : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
		attrLab2     : setAnchorPoint(cc.p(0,0))
		attrLab2     : setPosition(cc.p(attrWidth,135))
		label        : addChild(attrLab2)
	end
	
    if _G.Cfg.fight_gas_total[id+1]~=nil then
        local gasData=_G.Cfg.fight_gas_total[id+1]
        local willLab1= _G.Util : createLabel((_G.Lang.type_name[gasData.attr_type_one]or" ").." +"..tostring(gasData.attr_one),fontSize)
        willLab1     : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_SKYBLUE))
        willLab1     : setAnchorPoint(cc.p(0,0))
        willLab1     : setPosition(cc.p(attrWidth,85))
        label       : addChild(willLab1)

        if gasData.attr_two >0 then
            willLab:setPositionY(110)
            willLab1:setPositionY(110)
            willLab2= _G.Util : createLabel((_G.Lang.type_name[gasData.attr_type_two]or" ").." +"..tostring(gasData.attr_two),fontSize)
            willLab2     : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_SKYBLUE))
            willLab2     : setAnchorPoint(cc.p(0,0))
            willLab2     : setPosition(cc.p(attrWidth,85))
            label        : addChild(willLab2)
        end
    else
        willLab:setString("已达到最高级")
    end

	if _type == 2 then
		if gasData.attr_two >0 then
			if self.zhenMsg[lan_id] > 0 then
                local attrWidth1 = attrWidth+attrLab2:getContentSize().width
                local attrWidth = attrWidth+attrLab1:getContentSize().width
				local lab1= _G.Util : createLabel(string.format("(+%d)",gasData.attr_one * _G.Cfg.fight_gas_kong[self.zhenMsg[lan_id]].percent/10000),fontSize)
				lab1     : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_ORANGE))
				lab1     : setAnchorPoint(cc.p(0,0))
				lab1     : setPosition(cc.p(attrWidth,160))
				label    : addChild(lab1)

				local lab2= _G.Util : createLabel(string.format("(+%d)",gasData.attr_two * _G.Cfg.fight_gas_kong[self.zhenMsg[lan_id]].percent/10000),fontSize)
				lab2     : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_ORANGE))
				lab2     : setAnchorPoint(cc.p(0,0))
				lab2     : setPosition(cc.p(attrWidth1,135))
				label    : addChild(lab2)
			end
		else
			print("id",id,"zhenMsg",self.zhenMsg[lan_id])
			if self.zhenMsg[lan_id] > 0 then
                local attrWidth = attrWidth+attrLab1:getContentSize().width
				local lab1= _G.Util : createLabel(string.format("(+%d)",gasData.attr_one * _G.Cfg.fight_gas_kong[self.zhenMsg[lan_id]].percent/10000),fontSize)
				lab1     : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_ORANGE))
				lab1     : setAnchorPoint(cc.p(0,0))
				lab1     : setPosition(cc.p(attrWidth,120))
				label    : addChild(lab1)
			end
		end
	end

    local function equipEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		self : __equipEvent(lan_id,dq_id)
    	end
	end 

	local function pickEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
    		self : __pickEvent(lan_id)
    	end
	end 

	local equipButton  = gc.CButton:create()
	-- equipButton  : setButtonScale(0.8)
	equipButton  : loadTextures("general_btn_gold.png")
	
	if _type == 1 then
		equipButton  : addTouchEventListener(pickEvent)
		equipButton  : setTitleText("拾 取")
    elseif _type == 2 then
    	equipButton  : addTouchEventListener(equipEvent)
    	equipButton  : setTitleText("卸 下")
    	if self.itUid then
    		equipButton : setEnabled(false)
    		equipButton : setGray()
    	end
    elseif _type == 0 then
    	equipButton  : addTouchEventListener(equipEvent)
    	equipButton  : setTitleText("装 备")
	end
	equipButton  : setTitleFontSize(24)
	equipButton  : setTitleFontName(_G.FontName.Heiti)
	equipButton  : setAnchorPoint(cc.p(0.5,0))
	equipButton  : setPosition(cc.p(160,15))
	label        : addChild(equipButton)
end

function SoulView.__equipEvent( self,lan_id,dq_id )
	local msg = REQ_SYS_DOUQI_ASK_USE_DOUQI()
	print("=====================>",dq_id,"   ",lan_id)
	msg       : setArgs(self.role_id,dq_id,lan_id,0)
	_G.Network: send(msg)
	cc.Director : getInstance() : getRunningScene() : getChildByTag(GUA_XIANG_MSG) : removeFromParent()
end

function SoulView.__pickEvent( self,lan_id )
	_G.Util:playAudioEffect("ui_bagua_pickup")
	local msg = REQ_SYS_DOUQI_ASK_GET_DQ()
	msg       : setArgs(lan_id)
	_G.Network: send(msg)
	cc.Director : getInstance() : getRunningScene() : getChildByTag(GUA_XIANG_MSG) : removeFromParent()
end

function SoulView.__zhanBtnEvent( self )
    if self.itUid then return end
	print("占 卦")
	self : showLayer(ZHAN_BTN)

	local layer2     = self.m_rootLayer : getChildByTag(LAYER_BG): getChildByTag(XIANG_LAYER)

	if self.m_listener then
		layer2 : getEventDispatcher() : removeEventListener(self.m_listener)
		self.m_listener = nil
	end

	local msg = REQ_SYS_DOUQI_ASK_GRASP_DOUQI()
	_G.Network:send(msg)
end

function SoulView.__xiangBtnEvent( self )
	print("卦 象")
	self : showLayer(XIANG_BTN)
	local layer2     = self.m_rootLayer : getChildByTag(LAYER_BG): getChildByTag(XIANG_LAYER)

	local function onTouchBegan(touch, event)
		if self.m_isMove ~= nil then
			if self.m_isMove then
				return false
			end
		end

    	self.m_isMove = false
    	if touch:getLocation().y > 470 then
    		return false
    	end

    	if not self.flag then
    		self.flag = 0
    	end

    	self.flag = self.flag+1
    	
    	if self.flag>1 then
    		return
    	end
    	print("i======>>>>>>",self.flag)

    	local positon = layer2 : convertToNodeSpace(touch : getLocation())
    	self.startLocation = positon

    	if not self.itUid then
    		for i=9,24 do
	    		if self.goodArray[i] and cc.rectContainsPoint(self.goodArray[i][1] : getBoundingBox(),positon) then
	    			self.beginGood = self.goodArray[i]
	    			_G.Util:playAudioEffect("ui_sys_click")
	    			self.beginGoodPositonX = self.beginGood[1] : getPositionX()
	    			self.beginGoodPositonY = self.beginGood[1] : getPositionY()
	    			return true
	    		end
	    	end
    	end

    	for i=1,61 do
    		if self.goodArray1[i] then
    			print(i,self.goodArray1[i][1] : getPositionX())
    		end
    		
    		if self.goodArray1[i] and cc.rectContainsPoint(self.goodArray1[i][1] : getBoundingBox(),positon) then
    			self.beginGood = self.goodArray1[i]
    			_G.Util:playAudioEffect("ui_sys_click")
    			self.beginGoodPositonX = self.beginGood[1] : getPositionX()
    			self.beginGoodPositonY = self.beginGood[1] : getPositionY()
    			return true
    		end
    	end
    	
    	return true
    end

    local function onTouchMoved(touch, event)
    	if not self.beginGood then
    		return
    	end
    	local position = layer2 : convertToNodeSpace(touch : getLocation())
    	if math.abs(self.startLocation.x - position.x) < 40 and math.abs(self.startLocation.y - position.y) < 40 then
    		return
    	end

    	self.m_isMove = true
    	local button1    = self.m_rootLayer : getChildByTag(ZHAN_BTN)
		local button3    = self.m_rootLayer : getChildByTag(ZHEN_BTN)
		button1 : setEnabled(false)
		button3 : setEnabled(false)
    	
    	self.beginGood[1] : setAnchorPoint(cc.p(0.5,0.5))
    	self.beginGood[1] : setLocalZOrder(10)
    	if self.itUid then
    		return	
    	end
    	self.beginGood[1] : setPosition(position)
    end

    local function onTouchEnded(touch, event)
    	self.flag = nil
    	
    	local positon = layer2 : convertToNodeSpace(touch : getLocation())
    	if not self.m_isMove then
    		if not self.itUid then
    			for i=9,24 do
		    		if self.goodArray[i] and cc.rectContainsPoint(self.goodArray[i][1] : getBoundingBox(),positon) then

		    			local id   = 0
						if self.goodArray[i][2].dq_lv <10 then
							id = self.goodArray[i][2].dq_type*10+self.goodArray[i][2].dq_lv
						else
							id = self.goodArray[i][2].dq_type*100+self.goodArray[i][2].dq_lv
						end
						
						self : __clickGuaXiangEvent(0,id,self.goodArray[i][2].dq_exp,self.goodArray[i][2].lan_id,self.goodArray[i][2].dq_id)
						return
		    		end
		    	end
    		end
	    	
	    	for i=1,61 do
	    		if self.goodArray1[i] and cc.rectContainsPoint(self.goodArray1[i][1] : getBoundingBox(),positon) then

	    			local id   = 0
					if self.goodArray1[i][2].dq_lv <10 then
						id = self.goodArray1[i][2].dq_type*10+self.goodArray1[i][2].dq_lv
					else
						id = self.goodArray1[i][2].dq_type*100+self.goodArray1[i][2].dq_lv
					end
					
					self : __clickGuaXiangEvent(2,id,self.goodArray1[i][2].dq_exp,self.goodArray1[i][2].lan_id,self.goodArray1[i][2].dq_id)
					return
	    		end
	    	end
	    else
	    	if not self.itUid then
	    	    for i=1,#self.m_guaXiang do
		    		if cc.rectContainsPoint(self.m_guaXiang[i][1] : getBoundingBox(),positon) then
		    			self.endGood = self.m_guaXiang[i]

		    			if self.m_guaXiang[i][2] == self.beginGood[1] : getTag()  then
		    			else
		    				if layer2 : getChildByTag(self.m_guaXiang[i][2]) then
		    					local id   = 0
								if self.beginGood[2].dq_lv <10 then
									id = self.beginGood[2].dq_type*10+self.beginGood[2].dq_lv
								else
									id = self.beginGood[2].dq_type*100+self.beginGood[2].dq_lv
								end

			    				local data = {self.role_id,self.beginGood[2].dq_id,self.beginGood[1] : getTag(),self.m_guaXiang[i][2]}

			    				self : __initEatTips(id,data)
			    				return
		    				end

		    				local msg = REQ_SYS_DOUQI_ASK_USE_DOUQI()
							msg       : setArgs(self.role_id,self.beginGood[2].dq_id,self.beginGood[1] : getTag(),self.m_guaXiang[i][2])
							_G.Network: send(msg)
			    			return
		    			end
		    		end
		    	end

		    	for i=1,#self.m_guaXiang1 do
		    		if cc.rectContainsPoint(self.m_guaXiang1[i][1] : getBoundingBox(),positon) then
		    			self.endGood = self.m_guaXiang1[i]

		    			if self.m_guaXiang1[i][2] == self.beginGood[1] : getTag()  then
		    			else
			    			if layer2 : getChildByTag(self.m_guaXiang1[i][2]) then
		    					local id  = 0
								if self.beginGood[2].dq_lv <10 then
									id = self.beginGood[2].dq_type*10+self.beginGood[2].dq_lv
								else
									id = self.beginGood[2].dq_type*100+self.beginGood[2].dq_lv
								end

			    				local data = {self.role_id,self.beginGood[2].dq_id,self.beginGood[1] : getTag(),self.m_guaXiang1[i][2]}
			    				self : __initEatTips(id,data)
			    				return
		    				end

		    				local msg = REQ_SYS_DOUQI_ASK_USE_DOUQI()
							msg       : setArgs(self.role_id,self.beginGood[2].dq_id,self.beginGood[1] : getTag(),self.m_guaXiang1[i][2])
							_G.Network: send(msg)
							return
			    		end
		    		end
		    	end
		    	
				self.beginGood[1] : setLocalZOrder(3)
				self.beginGood[1] : setPosition(cc.p(self.beginGoodPositonX,self.beginGoodPositonY))
	    	end   	
    	end
    	self.beginGood = nil
    	self.endGood   = nil
    	self.m_isMove = false
    	local button1    = self.m_rootLayer : getChildByTag(ZHAN_BTN)
		local button3    = self.m_rootLayer : getChildByTag(ZHEN_BTN)
		button1 : setEnabled(true)
		button3 : setEnabled(true)	
    end

    local listener = cc.EventListenerTouchOneByOne:create() -- 创建一个事件监听器
    listener       : setSwallowTouches(true)
    listener       : registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener       : registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener       : registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    
    self.m_listener=listener

    local eventDispatcher = layer2 : getEventDispatcher() -- 得到事件派发器
    eventDispatcher : addEventListenerWithSceneGraphPriority(listener, layer2) -- 将监听器注册到派发器中

    if self.itUid then
    	local msg = REQ_SYS_DOUQI_OTHER_USR_GRASP()
    	msg       : setArgs(self.itUid,self.role_id)
		_G.Network: send(msg) 
    else
    	local msg = REQ_SYS_DOUQI_ASK_USR_GRASP()
		_G.Network:send(msg) 
    end

    local myPersonUid = _G.GPropertyProxy : getMainPlay() : getUid()

    local msg = REQ_SYS_DOUQI_OTHER_CLEAR()
	msg       : setArgs(self.itUid or myPersonUid,self.role_id)
	_G.Network: send(msg) 
end

function SoulView.__zhenBtnEvent( self,sender,eventType )
	print("卦 阵")
	self : showLayer(ZHEN_BTN)

	local layer2     = self.m_rootLayer : getChildByTag(LAYER_BG): getChildByTag(XIANG_LAYER)

	if self.m_listener then
		layer2 : getEventDispatcher() : removeEventListener(self.m_listener)
		self.m_listener = nil
	end

	if self.itUid then
        local msg = REQ_SYS_DOUQI_OTHER_CLEAR()
        msg       : setArgs(self.itUid or myPersonUid,self.role_id)
        _G.Network: send(msg) 
    else
        local msg = REQ_SYS_DOUQI_ASK_CLEAR()
        msg       : setArgs(self.role_id)
        _G.Network: send(msg)
    end
end

function SoulView.showLayer( self,_tag )
	local button1    = self.m_rootLayer : getChildByTag(ZHAN_BTN)
	local button2    = self.m_rootLayer : getChildByTag(XIANG_BTN)
	local button3    = self.m_rootLayer : getChildByTag(ZHEN_BTN)

	local layer1     = self.m_rootLayer : getChildByTag(LAYER_BG): getChildByTag(ZHAN_LAYER)
	local layer2     = self.m_rootLayer : getChildByTag(LAYER_BG): getChildByTag(XIANG_LAYER)
	local layer3     = self.m_rootLayer : getChildByTag(LAYER_BG): getChildByTag(ZHEN_LAYER)

	if _tag == ZHAN_BTN then
		button1          : setEnabled(false)
	    button1          : setBright(false)

	    button2          : setEnabled(true)
	    button2          : setBright(true)

	    button3          : setEnabled(true)
	    button3          : setBright(true)

	    layer1           : setVisible(true)
		layer2           : setVisible(false)
		layer3           : setVisible(false)
	elseif _tag == XIANG_BTN then
        if self.itUid==nil then
    		button1          : setEnabled(true)
    	    button1          : setBright(true)
        end

	    button2          : setEnabled(false)
	    button2          : setBright(false)

	    button3          : setEnabled(true)
	    button3          : setBright(true)

	    layer1           : setVisible(false)
		layer2           : setVisible(true)
		layer3           : setVisible(false)
        self : __updateState(TYPE_XIANG)
	elseif _tag == ZHEN_BTN then
		if self.itUid==nil then
            button1          : setEnabled(true)
            button1          : setBright(true)
        end

	    button2          : setEnabled(true)
	    button2          : setBright(true)

	    button3          : setEnabled(false)
	    button3          : setBright(false)

	    layer1           : setVisible(false)
		layer2           : setVisible(false)
		layer3           : setVisible(true)
        self : __updateState(TYPE_ZHEN)
	end

	if self.m_attrFlyNode~=nil then
		self.m_attrFlyNode:removeFromParent(true)
		self.m_attrFlyNode=nil
	end
	if _tag==XIANG_BTN or _tag==ZHEN_BTN then
		local sprSize=self.m_secondBgSpr:getPreferredSize()
		self.m_attrFlyNode=_G.Util:getLogsView():createAttrLogsNode()
		self.m_attrFlyNode:setPosition(sprSize.width*0.25,sprSize.height*0.5)
		self.m_secondBgSpr:addChild(self.m_attrFlyNode,10)
	end
end

function SoulView.moveError( self )
	print("恢复原来的位置")  		

	self.beginGood[1] : setLocalZOrder(3)
	self.beginGood[1] : setPosition(cc.p(self.beginGoodPositonX,self.beginGoodPositonY))    	

	self.beginGood = nil
	self.endGood   = nil
	self.m_isMove = false
	local button1    = self.m_rootLayer : getChildByTag(ZHAN_BTN)
	local button3    = self.m_rootLayer : getChildByTag(ZHEN_BTN)
	button1 : setEnabled(true)
	button3 : setEnabled(true)
end


function SoulView.__initEatTips( self,id,data )
	print("__initEatTips")

	local size = cc.Director : getInstance() : getWinSize()

	local function sure()
		_G.Util:playAudioEffect("ui_bagua_eat")
		self.isEffectPlaying = true
        self.isRemoveTrue = true
		local msg = REQ_SYS_DOUQI_ASK_USE_DOUQI()
		msg       : setArgs(data[1],data[2],data[3],data[4])
		_G.Network: send(msg)
    end

    local function cancel( ... )
    	print("取消")
  
		self.beginGood[1] : setLocalZOrder(3)
		self.beginGood[1] : setPosition(cc.p(self.beginGoodPositonX,self.beginGoodPositonY))
    	  
    	self.beginGood = nil
    	self.endGood   = nil
    	self.m_isMove = false
    	local button1    = self.m_rootLayer : getChildByTag(ZHAN_BTN)
		local button3    = self.m_rootLayer : getChildByTag(ZHEN_BTN)
		button1 : setEnabled(true)
		button3 : setEnabled(true)
    end

    local view  = require("mod.general.TipsBox")()
    local layer = view : create("",sure,cancel)
    -- layer 		: setPosition(cc.p(size.width/2,size.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)
    view        : setTitleLabel("提示")

    local layer=view:getMainlayer()
	local label = ccui.Widget : create()
	label       : setContentSize( cc.size(260,20) )
	label 		: setPosition(cc.p(50,10))
	layer 		: addChild(label)

	local name  = _G.Util : createLabel(_G.Cfg.fight_gas_total[id].gas_name,20)
	name        : setColor(_G.ColorUtil : getRGB(_G.Cfg.fight_gas_total[id].color))
	name        : setAnchorPoint(cc.p(0,0))
	name        : setPosition(cc.p(0,0))
	label       : addChild(name)

	local lab   =_G.Util : createLabel("将被吞噬!",20)
	-- lab         : setColor(_G.ColorUtil : getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
	lab         : setAnchorPoint(cc.p(0,0))
	lab 	    : setPosition(cc.p(name : getContentSize().width,0))
	label 		: addChild(lab)
end

function SoulView.showGoods( self,_msg,zhanDins1 )
	local x = (_msg.lan_id-25-1)%4+1
	local y = math.floor((_msg.lan_id-25-1)/4)+1

	local function clickGuaXiangEvent( send,eventType )
		print("点击了点("..x..","..y..")")
		local id   = 0
		if _msg.dq_lv <10 then
			id = _msg.dq_type*10+_msg.dq_lv
		else
			id = _msg.dq_type*100+_msg.dq_lv
		end
		if eventType == ccui.TouchEventType.ended then
			self : __clickGuaXiangEvent(1,id,_msg.dq_exp,_msg.lan_id,_msg.dq_id)
		end
	end

	local id   = 0
	if _msg.dq_lv <10 then
		id = _msg.dq_type*10+_msg.dq_lv
	else
		id = _msg.dq_type*100+_msg.dq_lv
	end

	local icon1 = ""
	local icon2 = ""
	local kind  = 0

	if _G.Cfg.fight_gas_total[id] then
		icon1 = string.format("fightgas_%d_1.png",_G.Cfg.fight_gas_total[id].pic1)
		icon2 = string.format("fightgas_%d_2.png",_G.Cfg.fight_gas_total[id].pic2)
		kind  = _G.Cfg.fight_gas_total[id].eff
	else
		icon1 = "fightgas_1251_1.png"
		icon2 = "fightgas_1251_2.png"
		kind  = 3
	end

	local dins = cc.Sprite : createWithSpriteFrameName(icon2)

	local container = ccui.Widget : create()
	container       : setContentSize(dins : getContentSize())
	container       : addTouchEventListener(clickGuaXiangEvent)
	container       : setTouchEnabled(true)
	container       : setTag(_msg.lan_id)
	container       : setPosition(self.goodsPosition[_msg.lan_id-25])
	zhanDins1       : addChild(container,1)

	dins       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
	container  : addChild(dins,0)

	local inIcon = cc.Sprite : createWithSpriteFrameName(icon1)
	inIcon       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
	container    : addChild(inIcon,2)

	if kind == 1 then
		dins   : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
		inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))
	
	elseif kind == 2 then
		dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

		local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
		dins1       : setFlippedX(true)
		dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
		container   : addChild(dins1,0)

		dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

		inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(1,1),cc.ScaleTo : create(1,0.9))))
	elseif kind == 3 then
		dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.ScaleTo : create(0.5,0.5),cc.ScaleTo : create(0.5,1.2))))

		inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))

		local inIcon1 = cc.Sprite : createWithSpriteFrameName(icon1)
		inIcon1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
		inIcon1 : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,-360)))
		container     : addChild(inIcon1,1)
	elseif kind == 4 then
		inIcon : runAction(cc.RepeatForever : create(cc.RotateBy : create(2,360)))	
	elseif kind == 5 then
		dins   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,20),cc.RotateTo : create(1,0))))

		local dins1 = cc.Sprite : createWithSpriteFrameName(icon2)
		dins1       : setFlippedX(true)
		dins1       : setPosition(container : getContentSize().width/2,container : getContentSize().height/2)
		container   : addChild(dins1,0)

		dins1   : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.RotateTo : create(1,-20),cc.RotateTo : create(1,0))))

		inIcon : runAction(cc.RepeatForever : create(cc.Sequence:create(cc.FadeTo : create(1,255),cc.FadeTo : create(1,255*0.7))))	
	end

	self.zhanGoodsArray[_msg.lan_id-25] = _G.Cfg.fight_gas_total[id].color
    print("self.zhanGoodsArray-->>",self.zhanGoodsArray,_msg.lan_id)

	local nameDins= ccui.Scale9Sprite : createWithSpriteFrameName("ui_soul_dins.png")
	nameDins      : setPreferredSize(cc.size(80,25))
	nameDins      : setPosition(cc.p(container : getContentSize().width/2,10))
	container     : addChild(nameDins,2)

	local name = _G.Util : createLabel(_G.Cfg.fight_gas_total[id].gas_name,16)
	name       : setColor(_G.ColorUtil : getRGBA(_G.Cfg.fight_gas_total[id].color))
	name       : setAnchorPoint(cc.p(0.5,0.5))
	name       : setPosition(cc.p(container : getContentSize().width/2,9))
	container  : addChild(name,3)
end

function SoulView.showStrengthOkEffect(self)
	if self.tempObj~=nil then
        self.tempObj:removeFromParent(true)
        self.tempObj=nil
    end
    local sizes = self.guaXiangArr[self.selectTag] : getContentSize ()  
    local tempGafAsset=gaf.GAFAsset:create("gaf/baguashengji.gaf")
    self.tempObj=tempGafAsset:createObject()
    local nPos=cc.p(sizes.width/2,sizes.height/2)
    self.tempObj:setLooped(false,false)
    self.tempObj:start()
    self.tempObj:setPosition(nPos)
    self.guaXiangArr[self.selectTag] : addChild(self.tempObj,1000)
end

function SoulView.showRemoveOkEffect(self,_icon)
    if self.removeGaf~=nil then
        self.removeGaf:removeFromParent(true)
        self.removeGaf=nil
    end
    local sizes = _icon : getContentSize ()  
    local tempGafAsset=gaf.GAFAsset:create("gaf/baguatunshi.gaf")
    self.removeGaf=tempGafAsset:createObject()
    local nPos=cc.p(sizes.width/2,sizes.height/2)
    self.removeGaf:setLooped(false,false)
    self.removeGaf:start()
    self.removeGaf:setPosition(nPos)
    _icon : addChild(self.removeGaf,1000)
end

function SoulView.__closeWindow( self )
    if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
	cc.Director:getInstance():popScene()
	self : unregister()

    if self.m_guideShowTab then
        local command=CGuideNoticShow()
        controller:sendCommand(command)
    end
end

return SoulView