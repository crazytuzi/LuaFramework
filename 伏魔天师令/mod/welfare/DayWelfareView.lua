local DayWelfareView = classGc(view, function(self)
    self.zzzz=1
end)
local m_winSize   = cc.Director:getInstance():getVisibleSize()
local rightbgSize = cc.size(624, 517)
local iconSize    = cc.size(85,85)
local signData 	  = _G.Cfg.sign
local FONTSIZE 	  = 20

function DayWelfareView.create(self)
	print("每日签到")
	self.m_container = cc.Node : create()

	self.DaybonusBg = ccui.Widget : create()
    self.DaybonusBg : setContentSize( rightbgSize )
	self.DaybonusBg : setPosition(100, -20)
	self.m_container : addChild(self.DaybonusBg)

--	初始化
	self : netWork()
	return self.m_container
end

function DayWelfareView.netWork(self)
    local msg  = REQ_REWARD_REQUEST()
	msg : setArgs(2)
    _G.Network : send( msg )
end

function DayWelfareView.DayScrollView( self )
    self.Sc_Container = cc.Node : create()
    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView = ScrollView

    local count=#signData/5

    self.oneSize=cc.size(122,154)
    local viewSize  = cc.size(rightbgSize.width, rightbgSize.height-58)
    self.containerSize = cc.size(rightbgSize.width, self.oneSize.height*count)

    ScrollView : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView : setViewSize(viewSize)
    ScrollView : setContentSize(self.containerSize)
    ScrollView : setContentOffset( cc.p( 0, viewSize.height-self.containerSize.height))
    ScrollView : setPosition(cc.p(10, -15))
    print("容器大小：", self.daysss)
    ScrollView : setBounceable(false)
    ScrollView : setTouchEnabled(true)
    ScrollView : setDelegate()

	-- local neiSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
	-- -- local lineheight=neiSpr:getContentSize().height
 --    neiSpr : setContentSize(rightbgSize.width+2,470)
 --    neiSpr : setPosition(rightbgSize.width/2+10,rightbgSize.height/2-46)
 --    self.Sc_Container  : addChild(neiSpr) 
    
    local logoSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_daybg.png")
    -- local lineheight=logoSpr:getContentSize().height
    logoSpr : setContentSize(rightbgSize.width+5,54)
    logoSpr : setPosition(rightbgSize.width/2+10,rightbgSize.height-51)
    self.Sc_Container  : addChild(logoSpr) 

    self.days  = self : getNowDayNo()
    print("self.days-->>>>", self.days)
    self.daysLab  = {1,2,3}
    self.daysStr  = {"累计签到",self.days,"天"}
    local daysPosX = {rightbgSize.width/2-70,rightbgSize.width/2+25,rightbgSize.width/2+40}
    for i=1,3 do
        self.daysLab[i] = _G.Util:createLabel( self.daysStr[i], FONTSIZE,_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BLACK))
        -- self.daysLab[i] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))  
        self.daysLab[i] : setPosition(daysPosX[i], rightbgSize.height-50)
        self.daysLab[i] : setAnchorPoint( cc.p(0.0,0.5) )
        self.Sc_Container : addChild(self.daysLab[i])
    end
    self.daysLab[2] : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GREEN))
    self.daysLab[2] : setAnchorPoint( cc.p(0.5,0.5) )

    self.Sc_Container : addChild(ScrollView)
    self.DaybonusBg  : addChild(self.Sc_Container)
    
    local barView=require("mod.general.ScrollBar")(ScrollView)
    barView:setPosOff(cc.p(-8,0))

    self : DayBonuscreate()
end

function DayWelfareView.DayBonuscreate(self)
	self.RewardBtn 	= {}
	self.nodrawSpr 	= {}
    self.heiSpr  = {}
	self.iconSpr = {}
	local RewardLab = {1,2,3}

	local onedayPosX= {11,49,66}
	local count=#signData/5
	print("count", count, #signData)
	self.reward = {}
	local posX=-self.oneSize.width/2+8
	local posY=self.containerSize.height+self.oneSize.height/2
	for i=1, #signData do
		print("签到获得")
		if i%5==1 then
			posX=self.oneSize.width/2+8
			posY=posY-self.oneSize.height
		else
			posX=posX+self.oneSize.width
		end

		local function onButtonCallBack(sender, eventType)
			self : onBtnCallBack(sender, eventType)
		end
		self.RewardBtn[i] = gc.CButton : create("main_eat.png")
		self.RewardBtn[i] : setTag(i)
		self.RewardBtn[i] : setEnabled(false)
		self.RewardBtn[i] : setSwallowTouches(false)
		self.RewardBtn[i] : setPosition(posX,posY )
		self.RewardBtn[i] : addTouchEventListener(onButtonCallBack)
		self.m_ScrollView : addChild(self.RewardBtn[i])

		local icondata = _G.Cfg.sign[i]
		self : getGoodsSpr(icondata, i,posX,posY)

        if icondata.vip>0 then
            local vipSpr = cc.Sprite : createWithSpriteFrameName("welfare_jiao.png")
            vipSpr : setPosition(cc.p(17, 52))
            self.iconSpr[i] : addChild(vipSpr,10)
            
            local vips=icondata.vip
            local vipNum = _G.Util:createBorderLabel(string.format("V%d",vips), FONTSIZE-4)
            vipNum : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))  
            vipNum : setPosition(cc.p(13, 31))
            vipNum : setRotation(-48)
            vipSpr : addChild(vipNum)

            local viptwo = _G.Util:createBorderLabel("双倍", FONTSIZE-4)
            viptwo : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD)) 
            viptwo : setPosition(cc.p(31, 51))
            viptwo : setRotation(-48)
            vipSpr : addChild(viptwo)
        end

        local btnSize=self.iconSpr[i]:getContentSize()
        self.heiSpr[i] = ccui.Scale9Sprite : createWithSpriteFrameName("general_voice_dins.png")
        self.heiSpr[i] : setPreferredSize(cc.size(105,137))
        self.heiSpr[i] : setPosition(btnSize.width/2, btnSize.height/2-19)
        self.heiSpr[i] : setOpacity(180)
        self.heiSpr[i] : setVisible(false)
        self.iconSpr[i] : addChild(self.heiSpr[i],5)

        self.nodrawSpr[i] = cc.Sprite : createWithSpriteFrameName("welfare_go.png")
        self.nodrawSpr[i] : setPosition(cc.p(btnSize.width/2, btnSize.height/2))
        self.nodrawSpr[i] : setVisible(false)
        self.iconSpr[i] : addChild(self.nodrawSpr[i],10)

        local str=_G.Lang.number_Chinese[i]
        local dayLab = _G.Util:createLabel(string.format("第%s天",str), FONTSIZE)
        dayLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))   
        dayLab : setPosition(self.RewardBtn[i]:getContentSize().width/2, 25)
        self.RewardBtn[i] : addChild(dayLab)
	end

	local guideId=_G.GGuideManager:getCurGuideId()
	if guideId==_G.Const.CONST_NEW_GUIDE_SYS_SIGN then
		_G.GGuideManager:registGuideData(2,self.RewardBtn[1])
		_G.GGuideManager:runNextStep()
		self.m_ScrollView:setTouchEnabled(false)
	end
end

function DayWelfareView.getGoodsSpr(self,icondata, i,posX,posY)
	if icondata == nil then return end
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
            print("－－－－Position.y",Position.y)
            if Position.y > m_winSize.height/2+rightbgSize.height/2-60 or
               Position.y < m_winSize.height/2-rightbgSize.height/2-15 
               or role_tag <= 0 then return end
            local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
        end 
    end

    local goods = icondata.goods[1]
    local Size = self.RewardBtn[i]:getContentSize()
    if goods~=nil then
        print("请求物品图片", goods.goods_id)
        local goodId      = goods.goods_id
        local goodCount   = goods.count
        local goodsdata   = _G.Cfg.goods[goodId]
        if goodsdata ~= nil then
            self.iconSpr[i] = _G.ImageAsyncManager:createGoodsBtn(goodsdata,roleCallBack,goodId,goodCount)
            self.iconSpr[i] : setSwallowTouches(false)
            self.iconSpr[i] : setPosition(posX, posY+20)
            self.m_ScrollView : addChild(self.iconSpr[i])
        end
    end   
end

function DayWelfareView.onBtnCallBack(self,sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local btn_tag = sender : getTag()
		local Position = sender : getWorldPosition()
		print("BtnPosition.y",Position.y)
       	if Position.y > m_winSize.height/2+rightbgSize.height/2-60 or
        Position.y < m_winSize.height/2-rightbgSize.height/2-15 then return end
		local msg  = REQ_REWARD_DAILY()
		msg : setArgs(btn_tag)
    	_G.Network : send( msg )

    	local msg  = REQ_REWARD_BEGIN()
        _G.Network : send( msg )
	end
end

function DayWelfareView.getNowDayNo( self )
    return self.NowDayNo
end
function DayWelfareView.setNowDayNo( self,_data )
    self.NowDayNo = _data
end

---------------------协议返回-------------------

function DayWelfareView.dailyData(self, _ackMsg)   --mediator传过来的数据
	local day_num    = _ackMsg.day_num	-- 登录天数
    self.day_msg     = _ackMsg.daily_msg	-- 每日领取信息块
    print("协议返回", day_num,self.day_msg)

    if day_num == 0 then
        self : setNowDayNo(1)
    else
        self : setNowDayNo(day_num)
    end

    if self.Sc_Container == nil then
    	self : DayScrollView()
    end

    for k,v in pairs(_G.Cfg.sign) do
    	print("kv,kv:",k, v)
    	if day_num >= k then
	    	print("对比",day_num, k,self.RewardBtn[k])
        	self.RewardBtn[k] : setEnabled(true)
            self:AddselectSpr(self.RewardBtn[k])
        	self.iconSpr[k] : setEnabled(false)
        end
        for kk,vv in pairs(self.day_msg) do
            if vv == k then
            	print("kv,kv:",k, v,kk,vv)
            	print("jjjjjj==", self.RewardBtn[k])
                self.RewardBtn[k] : setEnabled(false)
                -- self.RewardBtn[k] : loadTextures("main_eat.png")
                self.iconSpr[k] : setEnabled(true)
                self.nodrawSpr[k] : setVisible(true)
                self.heiSpr[k]:setVisible(true)
            end
        end
    end

    if self.zzzz~=1 then
        _G.Util:playAudioEffect("ui_receive_awards")
    end
    self.zzzz=self.zzzz+1
 --    if day_num>15 then
 --    	self.m_ScrollView : setContentOffset( cc.p( 0, rightbgSize.height-58-self.containerSize.height+3*self.oneSize.height))
	-- end
end

function DayWelfareView.AddselectSpr(self, _Btn)   --mediator传过来的数据
    -- if self.select~=nil then
    --     self.select:removeFromParent(true)
    --     self.select=nil
    -- end

    local btnSize=_Btn:getContentSize()
    local select=cc.Sprite:createWithSpriteFrameName("main_eats.png")
    select:setPosition(btnSize.width/2,btnSize.height/2)
    _Btn:addChild(select)
end

return DayWelfareView