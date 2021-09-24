local NumberTipsBox = classGc(view,function( self,_goodid, _maxNum, _defaultNum, _sureFun, _cancelFun )
    --物品id
    self.m_goodid = _goodid
    --最大次数
	self.m_maxNum    = _maxNum or 99

    --默认次数
    -- self.m_defaultNum= self.m_maxNum
    -- self.m_defaultNum= (self.m_defaultNum>self.m_maxNum) and self.m_maxNum or self.m_defaultNum

 --    --价格内容
	-- self.m_priceInfo = { 
 --        ["notic"]=(_priceNotic or "one price"),--单价的描述
 --        ["type"]=(_priceTpye or 1),--单价类型  ( Currency_Type_1等  ||  或者物品ID(用物品购买的话) )
 --        ["price"]=(_price or 10)--买一个的单价
 --    }

    --确认回调  会返回一个确认的数量，该干什么自己在回调处理
	self.m_sureFun   = _sureFun

    --取消回调  会返回一个确认的数量，不需要可以不用传
	self.m_cancenFun = _cancelFun

	self.tipsSize = cc.size( 460, 385 )
	self.m_winSize  = cc.Director:getInstance():getVisibleSize()
end)

NumberTipsBox.SURE_TAG     = 2
NumberTipsBox.CANCEL_TAG   = 3
NumberTipsBox.ADD_TAG      = 4
NumberTipsBox.REDUCE_TAG   = 5
NumberTipsBox.EDITBOX_TAG  = 6
NumberTipsBox.MAX_TAG      = 7

NumberTipsBox.FontSize     = 20

NumberTipsBox.LINESPACE    = 25


function NumberTipsBox.create( self, _type,_price )
    self.type=_type
    self.price=_price
    local function onTouchBegan() 
        print("TipsUtil remove tips")
        return true 
      end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)
    cc.Director:getInstance():getRunningScene():addChild(self.m_rootLayer,1000)

	self:__initView()
end

function NumberTipsBox.__initView( self )
	--背景
	local priority  = -_G.Const.CONST_MAP_PRIORITY_NOTIC

    self.tipsBgSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
    self.tipsBgSpr : setPosition(self.m_winSize.width/2, self.m_winSize.height/2-20)
    self.tipsBgSpr : setPreferredSize(self.tipsSize)
    -- self.tipsBgSpr : getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.tipsBgSpr)
    self.m_rootLayer : addChild(self.tipsBgSpr)

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(self.tipsSize.width/2-125, self.tipsSize.height-30)
    -- tipslogoSpr : setPreferredSize(cc.size(self.tipsSize.width-25, self.tipsSize.height-30))
    self.tipsBgSpr : addChild(tipslogoSpr)

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(self.tipsSize.width/2+120, self.tipsSize.height-30)
    tipslogoSpr : setScale(-1)
    self.tipsBgSpr : addChild(tipslogoSpr)

    local title="购 买"
    if self.type==1 then
        title="使 用"
    elseif self.type==2 then
        title="出 售"
    elseif self.type==80 or self.type==6010 or self.type==5010 then
        title="兑 换"
    end

    local logoLab= _G.Util : createBorderLabel(title, 24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    logoLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    logoLab : setPosition(self.tipsSize.width/2, self.tipsSize.height-28)
    -- logoLab : setAnchorPoint( cc.p(0.0,0.5) )
    self.tipsBgSpr  : addChild(logoLab)

    local action1 = cc.ScaleTo :create( 0.1, 0.97 )
    local action2 = cc.ScaleTo :create( 0.2, 1.02 )
    local action3 = cc.ScaleTo :create( 0.1, 0.99 )
    local action4 = cc.ScaleTo :create( 0.05, 1 )
    local action = cc.Sequence:create(action1,action2,action3,action4)
    self.tipsBgSpr :runAction( action )


    local function local_btncallback(sender, eventType) 
        return self : __eventCallBack(sender, eventType)
    end

    --确定 取消按钮
    local szNormal ="general_btn_gold.png"
    local szNormal2="general_btn_lv.png"

    self.m_sureBtn  = gc.CButton : create(szNormal)
    self.m_sureBtn  : setTitleFontName(_G.FontName.Heiti)
    self.m_sureBtn  : setTitleText(_G.Lang.BTN_N[1])
    self.m_sureBtn  : addTouchEventListener(local_btncallback)
    self.m_sureBtn  : setTitleFontSize(NumberTipsBox.FontSize+4)
    self.m_sureBtn  : setTag(self.SURE_TAG)   

    self.m_cancelBtn  = gc.CButton : create(szNormal2)
    self.m_cancelBtn  : setTitleFontName(_G.FontName.Heiti)
    self.m_cancelBtn  : setTitleText(_G.Lang.BTN_N[2])
    self.m_cancelBtn  : addTouchEventListener(local_btncallback)
    self.m_cancelBtn  : setTitleFontSize(NumberTipsBox.FontSize+4)
    self.m_cancelBtn  : setTag(self.CANCEL_TAG) 

    local btnSize = self.m_sureBtn : getContentSize()
    local pos_Y2  = btnSize.height/2+15
    self.tipsBgSpr : addChild(self.m_sureBtn, 10)  
    self.tipsBgSpr : addChild(self.m_cancelBtn, 10) 
    self.m_sureBtn   : setPosition( cc.p( self.tipsSize.width*0.25, 35 ) )
    self.m_cancelBtn : setPosition( cc.p( self.tipsSize.width*0.75, 35 ) )

    --两条直线
    local lineSpr1 = self : createGood_lineSpr() 
    self.tipsBgSpr : addChild(lineSpr1)      
    lineSpr1  : setPosition( cc.p( self.tipsSize.width/2, self.tipsSize.height/2+10 ) )
    --数量选择框 加减按钮 最大按钮

    local m_reduceBtn = gc.CButton:create() 
    m_reduceBtn  : loadTextures("general_btn_reduce.png")
    m_reduceBtn  : addTouchEventListener(local_btncallback)
    m_reduceBtn  : setTitleFontSize(NumberTipsBox.FontSize+4)
    m_reduceBtn  : ignoreContentAdaptWithSize(false)
    m_reduceBtn  : setContentSize(cc.size(80,80))
    m_reduceBtn  : setTag(self.REDUCE_TAG)   
    --输入框
    local m_boxSpr1 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_gold_floor.png" ) 
    local m_boxSpr1Size = m_boxSpr1 : getContentSize()
    m_boxSpr1 : setPreferredSize(cc.size(90,35))
    local m_boxSpr1Size = m_boxSpr1 : getContentSize()
    -- local m_boxSpr2 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_input_box.png" ) 
    -- local m_boxSpr3 = ccui.Scale9Sprite : createWithSpriteFrameName( "general_input_box.png" ) 
    local function textFieldEvent(sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
            self.m_editbox :setString("")
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
            print("3333333")
            local num = self.m_editbox : getString()
            print("--textFieldEvent---",num)
            local nums = string.match(num , "%d*")
            print("--textFieldEvent2222---",nums)
            if tostring(num) ~= tostring(nums) then
                print("重新设置")
                self.m_editbox : setString(tostring(1))
                local command = CErrorBoxCommand(8)
                controller :sendCommand( command )
            end
            if tonumber (nums) > self.m_maxNum then
                nums = tostring(self.m_maxNum)
                self.m_editbox : setString(tostring(nums))
            end
        elseif eventType == ccui.TextFiledEventType.insert_text then
        end
    end
    self.m_editbox = ccui.TextField:create("",_G.FontName.Heiti,NumberTipsBox.FontSize)
    self.m_editbox : setTouchEnabled(true)
    -- self.m_editbox : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.m_editbox : ignoreContentAdaptWithSize(false)
    self.m_editbox : setContentSize(cc.size(m_boxSpr1Size.width,m_boxSpr1Size.height))
    self.m_editbox : setMaxLengthEnabled(true)
    self.m_editbox : setMaxLength(49)
    self.m_editbox : addEventListener(textFieldEvent)
    self.m_editbox : setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER) 

    print("editbox over ok")
    local m_addBtn  = gc.CButton:create() 
    m_addBtn  : loadTextures("general_btn_add.png")
    m_addBtn  : addTouchEventListener(local_btncallback)
    m_addBtn  : setTitleFontSize(NumberTipsBox.FontSize+4)
    m_addBtn  : ignoreContentAdaptWithSize(false)
    m_addBtn  : setContentSize(cc.size(80,80))
    m_addBtn  : setTag(self.ADD_TAG) 

    local m_maxButton  = gc.CButton:create() 
    m_maxButton  : loadTextures("general_max.png")
    -- m_maxButton  : setTitleText("最大")
    -- m_maxButton  : setScale(0.7)
    m_maxButton  : addTouchEventListener(local_btncallback)
    m_maxButton  : setTitleFontSize(NumberTipsBox.FontSize+4)
    m_maxButton  : ignoreContentAdaptWithSize(false)
    m_maxButton  : setContentSize(cc.size(80,80))
    m_maxButton  : setTag(self.MAX_TAG) 

    self.tipsBgSpr      : addChild(m_reduceBtn)
    self.tipsBgSpr      : addChild(m_boxSpr1)
    self.tipsBgSpr      : addChild(self.m_editbox)
    self.tipsBgSpr      : addChild(m_addBtn)
    self.tipsBgSpr      : addChild(m_maxButton)
    local m_posY = 55 
    if self.type==1 then
        m_posY = 70
    end
    
    m_reduceBtn : setPosition(self.tipsSize.width*0.21, self.tipsSize.height/2-m_posY)
    m_boxSpr1   : setPosition(self.tipsSize.width*0.44, self.tipsSize.height/2-m_posY)
    self.m_editbox : setPosition(self.tipsSize.width*0.44, self.tipsSize.height/2-m_posY-5)
    m_addBtn    : setPosition(self.tipsSize.width*0.66, self.tipsSize.height/2-m_posY)
    m_maxButton : setPosition(self.tipsSize.width*0.83, self.tipsSize.height/2-m_posY)

    --拥有数量
    if self.type==1 or self.type==2 then
        local m_NumLab =  _G.Util:createLabel("数量:", NumberTipsBox.FontSize)
        m_NumLab : setPosition(self.LINESPACE,self.tipsSize.height/2-m_posY) 
        m_NumLab       : setAnchorPoint( cc.p(0.0,0.5) )
        self.tipsBgSpr      : addChild(m_NumLab)

        local m_haveNoLab = _G.Util:createLabel("拥有数量:"..self.m_maxNum, NumberTipsBox.FontSize)
        -- m_haveNoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
        -- m_haveNoLab       : setAnchorPoint( cc.p(0.0,0.5) )
        m_haveNoLab       : setPosition(self.tipsSize.width*0.19, self.tipsSize.height/2-10)
        self.tipsBgSpr         : addChild(m_haveNoLab)
    end

    --物品图标名字
    self.m_bgSpr      = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
    self.m_bgSpr      : setPosition(self.tipsSize.width*0.2, self.tipsSize.height-130)
    self.tipsBgSpr         : addChild(self.m_bgSpr,1)

    local rolebgSpr= cc.Sprite : createWithSpriteFrameName("general_rolebg.png")
    rolebgSpr      : setPosition(self.tipsSize.width*0.2, self.tipsSize.height-130)
    self.tipsBgSpr         : addChild(rolebgSpr)

    self : createGood_SprAndName()

    --初始化数量
    self.m_editbox :setString(tostring(1))
end

function NumberTipsBox.createGood_SprAndName( self )
    local m_bgSprSize = self.m_bgSpr : getContentSize()
    local goods_id  = self.m_goodid
    local baseNode  = _G.Cfg.goods[goods_id]
    if baseNode ~= nil then
        local m_iconSpr = _G.ImageAsyncManager:createGoodsSpr(baseNode)
        -- m_Container : addChild(m_iconSpr)
        m_iconSpr   : setPosition(m_bgSprSize.width/2,m_bgSprSize.height/2)
        self.m_bgSpr    : addChild(m_iconSpr)
    end

    local m_nameLab = nil 
    if baseNode == nil then
        m_nameLab = _G.Util:createLabel("id"..goods_id.."table no found", NumberTipsBox.FontSize)
    else
        m_nameLab = _G.Util:createLabel(baseNode.name, NumberTipsBox.FontSize)
        m_nameLab : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_VIOLET))    
    end
    m_nameLab  : setAnchorPoint( cc.p(0.0,0.5) )
    local m_nameLabSize = m_nameLab : getContentSize()
    self.m_bgSpr    : addChild(m_nameLab)
    m_nameLab  : setPosition(self.tipsSize.width*0.3, 93)

    -- local loginStr = baseNode.name
    local rolelv   = baseNode.lv
    local content  = baseNode.remark
    print("self.price===>>>",self.price)
    self.rmbcount = self.price~=nil and self.price or baseNode.price
    print("self.rmbcount===>>>",self.rmbcount)
    if self.type~=1 then
        local Img="general_xianYu.png"
        if self.type==1 or self.type==2 then
            Img="general_tongqian.png"
        elseif self.type==1050 then
            Img="general_gold.png"
            local lab = _G.Util : createLabel( "(元宝不足则消耗钻石)", NumberTipsBox.FontSize-2 )
            lab : setPosition( self.tipsSize.width/2, 82 )
            self.tipsBgSpr : addChild( lab )
        elseif self.type==7010 then
            Img="general_zhizun.png"
        elseif self.type==80 then
            Img="general_hongbao.png"
        elseif self.type==6010 then
            Img="general_artifact.png"
        elseif self.type==5010 then
            Img="general_yaoling.png"
        end
        local jadeSpr = cc.Sprite : createWithSpriteFrameName(Img)
        jadeSpr       : setPosition(self.tipsSize.width/2-62, -self.tipsSize.height/2+78)
        self.m_bgSpr  : addChild(jadeSpr)

        local numsLab  = _G.Util : createLabel("总计:", NumberTipsBox.FontSize)
        -- numsLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
        numsLab  : setPosition(self.tipsSize.width/2-130, -self.tipsSize.height/2+77)
        numsLab  : setAnchorPoint( cc.p(0.0,0.5) )
        self.m_bgSpr    : addChild(numsLab)

        self.rmbxhLab  = _G.Util : createLabel(self.rmbcount, NumberTipsBox.FontSize)
        -- self.rmbxhLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
        self.rmbxhLab  : setPosition(self.tipsSize.width/2-40, -self.tipsSize.height/2+77)
        self.rmbxhLab  : setAnchorPoint( cc.p(0.0,0.5) )
        self.m_bgSpr    : addChild(self.rmbxhLab)
    end

    print("name,lv,content",baseNode.name,rolelv,content)
    local lvstrLab  = _G.Util : createLabel("使用等级: ", NumberTipsBox.FontSize)
    -- lvstrLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    lvstrLab  : setPosition(self.tipsSize.width*0.3, 63)
    lvstrLab  : setAnchorPoint( cc.p(0.0,0.5) )
    self.m_bgSpr    : addChild(lvstrLab)

    local labWidth = lvstrLab:getContentSize().width
    local playlvLab = _G.Util : createLabel(rolelv, NumberTipsBox.FontSize)
    playlvLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
    playlvLab : setPosition(self.tipsSize.width*0.3+labWidth, 63)
    playlvLab : setAnchorPoint( cc.p(0.0,0.5) )
    self.m_bgSpr    : addChild(playlvLab)

    local textLab   = _G.Util : createLabel(content, NumberTipsBox.FontSize)
    -- textLab   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    textLab   : setPosition(self.tipsSize.width*0.3, self.tipsSize.height*(-0.02))
    textLab   : setDimensions(self.tipsSize.width/2+30, 100)
    textLab   : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    textLab   : setAnchorPoint( cc.p(0.0,0.5) )
    self.m_bgSpr    : addChild(textLab)
end
function NumberTipsBox.createGood_lineSpr( self )
    local m_lineSpr     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_di2kuan.png" ) 
    -- local m_lineSprSize = m_lineSpr : getPreferredSize()
    m_lineSpr           : setPreferredSize( cc.size(440,267) )

    return m_lineSpr
end


function NumberTipsBox.__getPriceTypeName( self )
	-- local priceType = tonumber(self.m_priceInfo.type)
	-- if priceType <= 1000 then
	-- 	return _G.Lang["Currency_Type_"..tostring(priceType)],true
	-- else
	-- 	return _G.Cfg.goods[priceType].name,false
	-- end
end


function NumberTipsBox.__eventCallBack( self, sender, eventType )
    if eventType==ccui.TouchEventType.ended then
        local tip_tag = sender : getTag()
        local num = self.m_editbox : getString()
        print("--self.m_editbox---",num)
        num = string.match(num , "%d*")

        if tip_tag == self.REDUCE_TAG then
            print("减1",num)
            num = tonumber( num )
            if num ~= nil and num > 1 then
                self.m_editbox : setString( tostring(num-1) )
                local minusprice = tostring(self.rmbcount*tonumber(num-1))
                print("minusprice", minusprice)
                if self.rmbxhLab~=nil then
                    self.rmbxhLab : setString(minusprice) 
                end                 
            end
        elseif tip_tag == self.ADD_TAG then
            print("加1",num)
            num = tonumber( num )
            if num ~= nil and num < self.m_maxNum then
                self.m_editbox : setString( tostring(num+1) )
                local addprice = tostring(self.rmbcount*tonumber(num+1))
                print("addprice", addprice)
                if self.rmbxhLab~=nil then
                    self.rmbxhLab : setString(addprice) 
                end
            end
        elseif tip_tag == self.MAX_TAG then
            local szMaxNum = tostring(self.m_maxNum)
            self.m_editbox : setString( szMaxNum )
            print("最大", szMaxNum)
            local maxsprice = tostring(self.rmbcount*tonumber(szMaxNum))
            print("maxsprice", maxsprice)
            if self.rmbxhLab~=nil then
                self.rmbxhLab : setString(maxsprice)
            end
        end
        local count = self.m_editbox : getString()
        local xhcount = tonumber(count)
        if tip_tag == self.SURE_TAG then
            print("确定")
            if xhcount == nil then
                local command = CErrorBoxCommand(9)
                controller : sendCommand( command )
                return
            end
            self :__sureCallBack()
        elseif tip_tag == self.CANCEL_TAG then
            print("取消")
            self :__cancelCallBack()
        end 
    end
end

function NumberTipsBox.setStateNum( self,nState )
    if self.cishuLab~=nil then
        self.cishuLab:setString(nState)
    else
        local xiangLab = _G.Util : createLabel("剩余", NumberTipsBox.FontSize-2)
        xiangLab       : setPosition(self.tipsSize.width*0.75, self.tipsSize.height-78)
        -- xiangLab       : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
        self.tipsBgSpr : addChild(xiangLab)

        self.cishuLab  = _G.Util : createLabel(nState, NumberTipsBox.FontSize-2)
        self.cishuLab  : setPosition(self.tipsSize.width*0.75+32, self.tipsSize.height-78)
        self.cishuLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
        if nState == 0 then
            self.cishuLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
        end
        self.tipsBgSpr : addChild(self.cishuLab)

        local cistrLab = _G.Util : createLabel("次", NumberTipsBox.FontSize-2)
        cistrLab  : setPosition(self.tipsSize.width*0.75+53, self.tipsSize.height-78)
        -- cistrLab  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
        self.tipsBgSpr : addChild(cistrLab)
    end
end

function NumberTipsBox.setDazheNow( self,_zheid )
    print("_zheid",_zheid)
    local haszheLab = _G.Util : createLabel("已使用", NumberTipsBox.FontSize-2)
    haszheLab : setPosition(self.tipsSize.width/2+80, self.tipsSize.height-107)
    -- haszheLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW))
    haszheLab : setAnchorPoint( cc.p(0.0,0.5) )
    self.tipsBgSpr : addChild(haszheLab)

    self.rmbxhLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    local rmbSize = self.rmbxhLab : getContentSize()
    local line = cc.DrawNode : create()--绘制线条
    line : drawLine(cc.p(0,2), cc.p(rmbSize.width+8,2), cc.c4f(0.6,0.2,0.3,1))
    line : setPosition(self.tipsSize.width/2+7, 98)
    self.tipsBgSpr : addChild(line,2)

    local zhedata = _G.Cfg.goods[_zheid]
    if zhedata~=nil then
        local zheLabWidth = haszheLab:getContentSize().width
        local goodsLab = _G.Util : createLabel(zhedata.name, NumberTipsBox.FontSize-2)
        goodsLab : setPosition(self.tipsSize.width/2+80+zheLabWidth, self.tipsSize.height-107)
        goodsLab : setColor(_G.ColorUtil : getRGBA(zhedata.name_color))
        goodsLab : setAnchorPoint( cc.p(0.0,0.5) )
        self.tipsBgSpr : addChild(goodsLab)

        local dazheka = zhedata.d
        local dazheNum= dazheka.as1/10000
        local zhecount = math.floor(self.rmbcount*dazheNum)
        print("zhecount",zhecount)
        local rmbzheLab = _G.Util : createLabel(zhecount, NumberTipsBox.FontSize)
        -- rmbzheLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BROWN))
        rmbzheLab : setPosition(self.tipsSize.width/2+90, 100)
        rmbzheLab : setAnchorPoint( cc.p(0.0,0.5) )
        self.tipsBgSpr : addChild(rmbzheLab)
    end
end

function NumberTipsBox.getBuyNum( self )
    local count=self.m_editbox : getString()
    return count
end

function NumberTipsBox.__sureCallBack( self )
    if self.m_sureFun ~= nil then
        local buyNum = tonumber( self.m_editbox :getString() )
        local num = string.match(buyNum , "%d*")
        if num == nil then
            self.m_editbox : setString(tostring(1))
            local command = CErrorBoxCommand(8)
            controller :sendCommand( command )
            return
        end
        num = tonumber( num )
        self.m_sureFun( buyNum )
        _G.Util:playAudioEffect("ui_props")
    end
    self :closeTips()
end

function NumberTipsBox.__cancelCallBack( self )
    if self.m_cancenFun ~= nil then
        local buyNum = tonumber( self.m_editbox :getString() )
        self.m_cancenFun( buyNum )
    end
    self :closeTips()
end


function NumberTipsBox.closeTips( self )
	if self.m_rootLayer ~= nil then
		self.m_rootLayer : removeFromParent(true)
		self.m_rootLayer = nil
	end
end

return NumberTipsBox

