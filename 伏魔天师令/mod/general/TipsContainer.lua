local TipsContainer = classGc(view, function(self,_good,_addheight,_showtype,_uid)
	self.m_good          = _good
	self.m_addheight     = _addheight
	self.m_showType      = _showtype
	self.m_characterUid  = _uid or 0
end)

local FONT_SIZE = 18
local PRE_LINE_HEIGHT = 23
local PRE_BACKGROUNGD_WIDTH = 340
--距离左边得间距
local LINE_SPACING = 20 

function TipsContainer.create(self)
	self.m_rootContainer=cc.Node:create()
	self:__initView()

	return self.m_rootContainer
end

function TipsContainer.__initView( self )
    local good_type = self.m_good.goods_type
    local baseNode  = self.m_good.goodCnf
    local type_sub  = baseNode.type_sub

    print("TipsContainer.__initView----",self.m_showType)
    if self.m_showType ~=nil and self.m_showType~= _G.Const.CONST_GOODS_SITE_OTHERROLE then
        print("高度减去了50")
        self.m_addheight = self.m_addheight -50
    end

    self.m_centerHeightStart=0
    self.m_centerHeightEnd=0

    --添加字段都是倒叙添加
    if good_type == _G.Const.CONST_GOODS_EQUIP then
        -- print("----Tips_装备武器_内容^^^^^^^^^^")
        --装备，武器  1 
        --基础属性
        self :equipInfo()
    elseif good_type == _G.Const.CONST_GOODS_WEAPON then
        --符文 2
        self :fuwenInfo()
    elseif good_type == _G.Const.CONST_GOODS_MAGIC then
        --神器 5
        -- print("----Tips_神器_内容^^^^^^^^^^")
        self :godInfo()
    else
        --道具 非1 2 5
        -- print("----Tips_物品_内容^^^^^^^^^^")
        self :articleInfo()
    end

    print("FFFFFFFFF=====>>>",self.m_centerHeightStart,self.m_centerHeightEnd)
    if self.m_centerHeightEnd<self.m_centerHeightStart then
        local subHeight=self.m_centerHeightStart-self.m_centerHeightEnd
        local tempSize=cc.size(320,subHeight)
        local tempSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
        tempSpr:setPreferredSize(tempSize)
        tempSpr:setAnchorPoint(cc.p(0.5,1))
        tempSpr:setPosition(PRE_BACKGROUNGD_WIDTH*0.5,-self.m_centerHeightEnd)
        self.m_rootContainer:addChild(tempSpr,-1)
    end
end

function TipsContainer.fuwenInfo(self)
    self.m_goodsContainer = cc.Node : create()
    self.m_rootContainer : addChild(self.m_goodsContainer)

    if self.m_good.goodCnf.f.sell == 1 then
        -- 出售价格
        self.m_goodsContainer : addChild(self : createGood_Price())
    end

    self:returnLine()
    self.m_centerHeightStart=self.m_addheight
    
    -- --基础属性
    self.m_goodsContainer : addChild(self : createGood_BaseAttr())

    self:returnLine()
    self.m_centerHeightEnd=self.m_addheight
    -- -- 图标 名字
    self.m_goodsContainer : addChild(self : createGood_SprAndName())
end

function TipsContainer.equipInfo(self)
    self.m_goodsContainer = cc.Node : create()
    self.m_rootContainer : addChild(self.m_goodsContainer)

    -- 饰品分解材料
    self.m_goodsContainer : addChild(self : createGood_BreakMaterial())
    -- 直线
    -- self.m_goodsContainer : addChild(self : createGood_lineSpr())
    self:returnLine()
    self.m_centerHeightStart=self.m_addheight

    local isHaveGem = false
    -- print("AAAAAAAAAAAAAAAAAAAA>>>>>>>>>>  1")
    if self.m_good.slots_count > 0 then
        -- print("AAAAAAAAAAAAAAAAAAAA>>>>>>>>>>  2")
        for i=1,self.m_good.slots_count do 
            -- print("AAAAAAAAAAAAAAAAAAAA>>>>>>>>>>  3")
            if self.m_good.slot_group[i].pearl_id>0 then
                -- print("AAAAAAAAAAAAAAAAAAAA>>>>>>>>>>  4")
                isHaveGem = true
                break
            end
        end
    end
    
    if isHaveGem then
        --宝石镶嵌
        self.m_goodsContainer : addChild(self : createGood_GemIn())
        -- 直线
        -- self.m_goodsContainer : addChild(self : createGood_lineSpr())
        self:returnLine()
    end

    --附魔
    if self.m_good.fumo ~= nil and self.m_good.fumo > 0 then      
        self.m_goodsContainer : addChild(self : createGood_FuMo())
    end
    -- --基础属性
    self.m_goodsContainer : addChild(self : createGood_BaseAttr())
    -- 直线
    -- self.m_goodsContainer : addChild(self : createGood_lineSpr())
    self:returnLine()
    self.m_centerHeightEnd=self.m_addheight
    -- -- 装备需求
    self.m_goodsContainer : addChild(self : createGood_EquipLv(1))
    -- -- 图标 战力
    self.m_goodsContainer : addChild(self : createGood_SprAndPower())
    -- -- --名字 以及 强化等级
    self.m_goodsContainer : addChild(self : createGood_NameAndStrength())
end

function TipsContainer.articleInfo( self )
    self.m_goodsContainer = cc.Node : create()
    self.m_rootContainer : addChild(self.m_goodsContainer)
    if self.m_good.goodCnf.f.sell == 1 then
        -- 出售价格
        self.m_goodsContainer : addChild(self : createGood_Price())
    end
    -- 直线
    -- self.m_goodsContainer : addChild(self : createGood_lineSpr())
    self:returnLine()
    self.m_centerHeightStart=self.m_addheight

    --描述
    self.m_goodsContainer : addChild(self : createGood_Description())
    -- 直线
    -- self.m_goodsContainer : addChild(self : createGood_lineSpr())
    self:returnLine()
    self.m_centerHeightEnd=self.m_addheight
    -- 使用需求
    self.m_goodsContainer : addChild(self : createGood_EquipLv(2))
    -- 图标 名字
    self.m_goodsContainer : addChild(self : createGood_SprAndName())
end

function TipsContainer.godInfo( self )
    self.m_goodsContainer = cc.Node : create()
    self.m_rootContainer : addChild(self.m_goodsContainer)

    if self.m_good.goodCnf.f.sell == 1 then
        -- 出售价格
        self.m_goodsContainer : addChild(self : createGood_Price())
    end
    -- 直线
    -- self.m_goodsContainer : addChild(self : createGood_lineSpr())
    self:returnLine()
    self.m_centerHeightStart=self.m_addheight

    if self.m_good.plus_msg_no~=nil and #self.m_good.plus_msg_no>0  then
        --洗练属性
        self.m_goodsContainer : addChild(self : createGood_Succinct())
        -- 直线
        -- self.m_goodsContainer : addChild(self : createGood_lineSpr())
        self:returnLine()
    end

    --基础属性
    self.m_goodsContainer : addChild(self : createGood_BaseAttr())
    -- 直线
    -- self.m_goodsContainer : addChild(self : createGood_lineSpr())
    self:returnLine()
    self.m_centerHeightEnd=self.m_addheight
    -- 装备需求
    self.m_goodsContainer : addChild(self : createGood_EquipLv(1))
    -- 图标 战力
    self.m_goodsContainer : addChild(self : createGood_SprAndPower())
    -- --名字 以及 强化等级
    self.m_goodsContainer : addChild(self : createGood_NameAndStrength())
end

function TipsContainer.createGood_Succinct( self )
	local m_Count = #self.m_good.plus_msg_no
    local tempNode = cc.Node : create()
    local baseNode  = self.m_good.goodCnf
    
    local infoLab = _G.Util:createLabel("洗练属性:", FONT_SIZE)
    -- infoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
    infoLab       : setAnchorPoint( cc.p(0.0,0.5) )
    tempNode      : addChild(infoLab)

    local infoLabSize = infoLab : getContentSize()
    for i=1,m_Count do --洗练属性数量
        -- v.plus_type,v.plus_colour,v.plus_current
        local data = self.m_good.plus_msg_no[i]

        local addWidth = LINE_SPACING + infoLabSize.width


        local szType=_G.Lang.type_name[data.plus_type] or "无"
        local l_nameStr = string.format("%s %d",szType,data.plus_current)
        -- local l_addStr  = "(9星)"
        
        local l_nameLab = _G.Util:createLabel(l_nameStr, FONT_SIZE)
        -- local l_addLab  = _G.Util:createLabel(l_addStr, FONT_SIZE)
        -- l_nameLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
        -- l_addLab        : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
        l_nameLab       : setAnchorPoint( cc.p(0.0,0.5) )
        -- l_addLab        : setAnchorPoint( cc.p(0.0,0.5) )
        --属性名

        self.m_addheight = self.m_addheight - PRE_LINE_HEIGHT
        -- local l_nameLabSize  = l_nameLab  : getContentSize()
        -- local l_addLabSize   = l_addLab   : getContentSize()

        l_nameLab   : setPosition(addWidth,-self.m_addheight)
        -- addWidth    = addWidth + l_nameLabSize.width+5
        -- l_addLab    : setPosition(addWidth,-self.m_addheight)

        tempNode: addChild(l_nameLab)
        -- tempNode: addChild(l_addLab)
    end

    infoLab : setPosition(LINE_SPACING,-self.m_addheight)

    return  tempNode    
end

function TipsContainer.createGood_Description( self )
    local baseNode  = self.m_good.goodCnf
    local remark    = baseNode.remark
    print("createGood_Description remark==",remark)

    local infoLab = _G.Util:createLabel(remark, FONT_SIZE)
    -- infoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
    infoLab       : setAnchorPoint( cc.p(0.0,1.0) )
    infoLab       : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    infoLab       : setDimensions(PRE_BACKGROUNGD_WIDTH-40,0)

    local infoLabSize = infoLab : getContentSize()
    self.m_addheight  = self.m_addheight - infoLabSize.height
    infoLab : setPosition(  cc.p( LINE_SPACING, -self.m_addheight+FONT_SIZE/2))

    return infoLab
end

function TipsContainer.createGood_Price( self )
    self.m_addheight = self.m_addheight - PRE_LINE_HEIGHT
    local tempNode = cc.Node : create()

    local m_price  = self.m_good.price

    local infoStr = "出售价格:"
    if self.m_good.goods_type == _G.Const.CONST_GOODS_SALE then
        infoStr = "购回价格:"
    end
    local infoLab = _G.Util:createLabel(infoStr, FONT_SIZE)
    -- infoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
    infoLab       : setAnchorPoint( cc.p(0.0,0.5) )
    infoLab       : setPosition(LINE_SPACING,-self.m_addheight)
    tempNode     : addChild(infoLab)

    local infoLabSize = infoLab : getContentSize()
    local addWidth      = LINE_SPACING + infoLabSize.width+5

    local m_priceLab = _G.Util:createLabel(m_price.."铜钱", FONT_SIZE)
    -- m_priceLab  : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
    m_priceLab  : setAnchorPoint( cc.p(0.0,0.5) )
    m_priceLab  : setPosition(addWidth,-self.m_addheight) 
    tempNode : addChild(m_priceLab)
    return tempNode
end

function TipsContainer.createGood_SprAndName( self )
    local tempNode = cc.Node : create()

    self.m_addheight = self.m_addheight - 90

    local bgSpr = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
    local bgSprSize = bgSpr : getContentSize()

    -- local infobgSpr2  = cc.Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
    -- local infobgSprSize = infobgSpr2 : getContentSize()
    -- infobgSpr2        : setScaleX(300/infobgSprSize.width)
    -- infobgSpr2        : setPosition(bgSprSize.width+230/2-5,infobgSprSize.height/2+5)
    -- bgSpr             : addChild(infobgSpr2,-2)


    tempNode : addChild(bgSpr) 
    bgSpr : setPosition(LINE_SPACING+bgSprSize.width/2,-self.m_addheight-bgSprSize.height/2+10)

    local goods_id  = self.m_good.goods_id
    local baseNode  = self.m_good.goodCnf
    if baseNode ~= nil then
        local iconSpr = _G.ImageAsyncManager:createGoodsSpr(baseNode)
        tempNode : addChild(iconSpr)
        iconSpr  : setPosition(LINE_SPACING+bgSprSize.width/2,-self.m_addheight-bgSprSize.height/2+10)
    end
    
    local nameLab = nil 
    if baseNode == nil then
        nameLab = _G.Util:createLabel("id"..goods_id.."table no found", FONT_SIZE)
    else
        nameLab = _G.Util:createLabel(baseNode.name, FONT_SIZE+2)
        nameLab : setColor(_G.ColorUtil:getRGBA(baseNode.name_color))    
    end
    nameLab  : setAnchorPoint( cc.p(0.0,0.5) )
    local nameLabSize = nameLab : getContentSize()
    bgSpr    : addChild(nameLab)
    nameLab  : setPosition(bgSprSize.width+10,bgSprSize.height/2)

    local time = self.m_good.expiry
    print("time",time)

    if time >0 then
    	local tips = _G.Util:createLabel("有效期:",16)
    	-- tips:setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_LABELBLUE))
    	tips:setPosition(bgSprSize.width+30,bgSprSize.height/2-25)
    	bgSpr:addChild(tips)
    	if time > _G.TimeUtil:getNowSeconds() then
    		time=os.date("*t",time)
    		print(time.year,time.month,time.day,time.hour,time.min,time.sec)
    		local date = _G.Util:createLabel(string.format("%d.%.2d.%.2d %.2d:%.2d:%.2d",time.year,time.month,time.day,time.hour,time.min,time.sec),16)
	    	-- date:setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_LABELBLUE))
	    	date:setAnchorPoint(cc.p(0,0.5))
	    	date:setPosition(bgSprSize.width+60,bgSprSize.height/2-25)
	    	bgSpr:addChild(date)
    	else
    		tips:setString("已过期")
    		-- tips:setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_RED))
    	end
    end
    

    if self.m_showType==_G.Const.CONST_GOODS_SITE_BACKPACK
        or self.m_showType==_G.Const.CONST_GOODS_SITE_PLAYER then
        --展示
        local function l_btnCallBack(sender, eventType)
            self : onbtnCallBack(sender, eventType)
        end
        local showBtn = gc.CButton:create("general_show.png") 
        -- showBtn  : setTitleFontName(_G.FontName.Heiti)
        -- showBtn  : setTitleText("展示")
        -- showBtn  : setTitleFontSize(FONT_SIZE)
        showBtn  : setContentSize(cc.size(50,50))
        showBtn  : addTouchEventListener(l_btnCallBack)
        bgSpr    : addChild(showBtn)
        showBtn  : setPosition(285,bgSprSize.height/2+25)

        local showLab = _G.Util:createLabel("展示",FONT_SIZE)
        -- showLab : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
        showLab : setPosition(25,-5)
        showBtn : addChild(showLab)
    end

    return tempNode
end

function TipsContainer.createGood_GemIn( self )
    local tempNode = cc.Node : create()
    local baseNode  = self.m_good.goodCnf

    local infoLab = _G.Util:createLabel("宝石:",FONT_SIZE)
    -- infoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
    infoLab       : setAnchorPoint( cc.p(0.0,0.5) )
    tempNode     : addChild(infoLab)

    local infoLabSize = infoLab : getContentSize()

    local flagGoods = {}
    local flagCount = 0
    for i=1,self.m_good.slots_count do --宝石属性
        if self.m_good.slot_group[i].pearl_id>0 then
            print("createGood_GemIn=========>>>>>>>",self.m_good.slot_group[i].pearl_id)
            flagCount=flagCount+1
            flagGoods[flagCount]=self.m_good.slot_group[i].pearl_id
        end
    end
    for i=1,flagCount do --宝石属性
        local addWidth = LINE_SPACING + infoLabSize.width

        local gemid = flagGoods[i]
        local gemnode =_G.Cfg.goods[gemid]

        local l_nameStr = ""
        local l_addStr  = ""
        if not gemnode then
            l_nameStr = "node error"
            l_addStr  = "node error"
        else
            l_nameStr = gemnode.name
            l_addStr  = gemnode.remark
        end
        l_nameLab       = _G.Util:createLabel(l_nameStr,  FONT_SIZE)
        l_addLab        = _G.Util:createLabel(l_addStr,   FONT_SIZE)
        l_nameLab       : setColor(_G.ColorUtil:getRGBA(gemnode.name_color))
        -- l_addLab        : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
        l_nameLab       : setAnchorPoint( cc.p(0.0,0.5) )
        l_addLab        : setAnchorPoint( cc.p(0.0,0.5) )
        --属性名

        self.m_addheight = self.m_addheight - PRE_LINE_HEIGHT
        local l_nameLabSize  = l_nameLab  : getContentSize()
        local l_addLabSize   = l_addLab   : getContentSize()

        l_nameLab   : setPosition(addWidth,-self.m_addheight-4)
        addWidth    = addWidth + l_nameLabSize.width+5
        l_addLab    : setPosition(addWidth,-self.m_addheight-4)

        tempNode: addChild(l_nameLab)
        tempNode: addChild(l_addLab)
    end

    infoLab : setPosition(LINE_SPACING,-self.m_addheight-4)

    return tempNode
end

function TipsContainer.createGood_SprAndPower( self )
    local tempNode = cc.Node : create()

    self.m_addheight = self.m_addheight - 90

    local bgSpr = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
    local bgSprSize = bgSpr : getContentSize()

    -- local infobgSpr = ccui.Scale9Sprite:createWithSpriteFrameName( "general_double_line.png" )
    -- local infobgSprSize = infobgSpr:getContentSize()
    -- infobgSpr       : setPreferredSize(cc.size(240,infobgSprSize.height))
    -- infobgSpr       : setPosition(bgSprSize.width+110,bgSprSize.height-infobgSprSize.height/2-75)
    -- bgSpr           : addChild(infobgSpr,-2)

    tempNode : addChild(bgSpr) 
    bgSpr : setPosition(LINE_SPACING+bgSprSize.width/2,-self.m_addheight-bgSprSize.height/2+10)

    local powerful  = self.m_good.powerful 
    local baseNode  = self.m_good.goodCnf
    if baseNode ~= nil then
        local iconSpr = _G.ImageAsyncManager:createGoodsSpr(baseNode)
        tempNode : addChild(iconSpr)
        iconSpr   : setPosition(LINE_SPACING+bgSprSize.width/2,-self.m_addheight-bgSprSize.height/2+10)
    end

    --饰品战力
    local infoLabStr = "战力:"
    local infoLab = _G.Util:createLabel(infoLabStr, FONT_SIZE)
    -- infoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
    infoLab       : setAnchorPoint( cc.p(0.0,0.5) )
    bgSpr         : addChild(infoLab)

    local powerLab = _G.Util:createLabel(powerful or "", FONT_SIZE)
    powerLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORANGE)) 
    powerLab       : setAnchorPoint( cc.p(0.0,0.5) )    
    bgSpr          : addChild(powerLab)

    --星星
    local zizhiLab = _G.Util:createLabel("资质:", FONT_SIZE)
    -- zizhiLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
    zizhiLab       : setAnchorPoint( cc.p(0.0,0.5) )    
    bgSpr          : addChild(zizhiLab)

    local m_starCount = baseNode.star or 0 
    local starLab = _G.Util:createLabel(m_starCount or "", FONT_SIZE)
    starLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORANGE)) 
    starLab       : setAnchorPoint( cc.p(0.0,0.5) )    
    bgSpr         : addChild(starLab)

    local infoLabSize = infoLab : getContentSize()
    infoLab  : setPosition(bgSprSize.width+15,bgSprSize.height*0.5+15)
    powerLab : setPosition(bgSprSize.width+15+infoLabSize.width,bgSprSize.height*0.5+15)
    zizhiLab : setPosition(bgSprSize.width+15,bgSprSize.height*0.5-15)
    starLab  : setPosition(bgSprSize.width+15+infoLabSize.width,bgSprSize.height*0.5-15)

    if self.m_showType==_G.Const.CONST_GOODS_SITE_BACKPACK
        or self.m_showType==_G.Const.CONST_GOODS_SITE_PLAYER then
        --展示
        local function l_btnCallBack(sender, eventType)
            self : onbtnCallBack(sender, eventType)
        end
        local showBtn = gc.CButton:create("general_show.png") 
        -- showBtn  : setTitleFontName(_G.FontName.Heiti)
        -- showBtn  : setTitleText("展示")
        -- showBtn  : setTitleFontSize(FONT_SIZE)
        showBtn  : setContentSize(cc.size(50,50))
        showBtn  : addTouchEventListener(l_btnCallBack)
        bgSpr    : addChild(showBtn)
        showBtn  : setPosition(285,bgSprSize.height/2+50)

        local showLab = _G.Util:createLabel("展示",FONT_SIZE)
        -- showLab : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
        showLab : setPosition(25,-5)
        showBtn : addChild(showLab)
    end

    return tempNode
end
function TipsContainer.onbtnCallBack( self,sender, eventType )
    if eventType==ccui.TouchEventType.ended then
        local btn_tag=sender:getTag()
        _G.TipsUtil:_reset()

        local chatData={
            dataType=_G.Const.kChatDataTypeWP,
            name=self.m_good.goodCnf.name,
            type=self.m_showType,
            id=self.m_characterUid or 0,
            idx=self.m_good.index or self.m_good.goods_id
        }
        local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_ROLE)
        controller :sendCommand( command ) 
        _G.GLayerManager:delayOpenLayer(_G.Const.CONST_FUNC_OPEN_CHATTING,nil,chatData)
    end
end

-- _type 1 : 装备需求 2: 使用需求 仅仅十文字不同
function TipsContainer.createGood_EquipLv( self,_type )
    self.m_addheight = self.m_addheight - PRE_LINE_HEIGHT

    local tempNode = cc.Node:create()
    local baseNode  = self.m_good.goodCnf
    local lv        = baseNode.lv or 0

    local infoStr = "等级:"
    -- if _type == 2 then
    --     infoStr = "使用要求:"
    -- end
    local infoLab = _G.Util:createLabel(infoStr, FONT_SIZE)
    -- infoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
    infoLab       : setAnchorPoint( cc.p(0.0,0.5) )
    infoLab       : setPosition(LINE_SPACING,-self.m_addheight-5)
    tempNode     : addChild(infoLab)

    local infoLabSize = infoLab : getContentSize()
    local addWidth      = LINE_SPACING + infoLabSize.width

    local m_lvLab = _G.Util:createLabel(lv.."级", FONT_SIZE)
    m_lvLab  : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN)) 
    m_lvLab  : setAnchorPoint( cc.p(0.0,0.5) )
    m_lvLab  : setPosition(addWidth,-self.m_addheight-5) 
    tempNode: addChild(m_lvLab)

    local mainplay = _G.GPropertyProxy : getMainPlay()
    local m_lv = mainplay : getLv()  
    if m_lv >= lv then
        -- m_lvLab  : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
    end

    return tempNode
end
function TipsContainer.createGood_BaseAttr( self )
    local tempNode = cc.Node : create()
    local baseNode  = self.m_good.goodCnf
    
    local infoLab = _G.Util:createLabel("属性:", FONT_SIZE)
    -- infoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
    infoLab       : setAnchorPoint( cc.p(0.0,0.5) )
    tempNode     : addChild(infoLab)
    local infoLabSize = infoLab : getContentSize()

    if baseNode.base_type~=nil  then
        local addAttrArray={}
        local addData=self.m_good.attr_data or {}
        print("oOOOOOOOO======>>>",#addData)
        for i=1,#addData do
            addAttrArray[addData[i].attr_base_type]=addData[i].attr_base_value
            print("CCCCCCCCCCCC>>>>>>",addData[i].attr_base_type,addData[i].attr_base_value)
        end

        local count= #baseNode.base_type
        local data = baseNode.base_type
        local attrArray={}
        local baseAttar={}
        for i=1,count do
            local baseValue=data[i].v
            local baseType=data[i].type
            local szType=_G.Lang.type_name[baseType] or "无"
            local addValue=addAttrArray[baseType]
            attrArray[i]={}
            attrArray[i].baseValue=baseValue
            attrArray[i].szType=szType
            attrArray[i].addValue=addValue
            baseAttar[baseType]=baseValue
        end

        if self.m_good.powerful==nil or self.m_good.powerful==0 then
            self.m_good.powerful=_G.Util:getAttrPower(baseAttar)
        end
        baseAttar=nil

        local addWidth = LINE_SPACING + infoLabSize.width
        for i=1,#attrArray do
            self.m_addheight=self.m_addheight-PRE_LINE_HEIGHT

            -- local szContent=attrArray[i].szType..": "..attrArray[i].baseValue
            local nameLab=_G.Util:createLabel(attrArray[i].szType,FONT_SIZE)
            local nameLabSize=nameLab:getContentSize()
            -- nameLab:setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
            nameLab:setAnchorPoint(cc.p(0.0,0.5))
            nameLab:setPosition(addWidth,-self.m_addheight)
            tempNode:addChild(nameLab)

            local numsLab=_G.Util:createLabel(attrArray[i].baseValue,FONT_SIZE)
            local numsLabSize=numsLab:getContentSize()
            -- numsLab:setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
            numsLab:setAnchorPoint(cc.p(0.0,0.5))
            numsLab:setPosition(addWidth+nameLabSize.width+5,-self.m_addheight)
            tempNode:addChild(numsLab)

            if attrArray[i].addValue then
                local szAddValue="("..attrArray[i].addValue..")"
                local addLab=_G.Util:createLabel(szAddValue,FONT_SIZE)
                addLab:setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN)) 
                addLab:setAnchorPoint(cc.p(0.0,0.5))
                addLab:setPosition(addWidth+nameLabSize.width+numsLabSize.width+5,-self.m_addheight)
                tempNode:addChild(addLab)
            end
        end
    end

    infoLab : setPosition(LINE_SPACING,-self.m_addheight)

    return  tempNode
end

function TipsContainer.createGood_FuMo( self )
    self.m_addheight = self.m_addheight - PRE_LINE_HEIGHT
    local fumoz  = self.m_good.fumoz or 0 
    local fumoNode = cc.Node:create()

    local m_fumoLab = _G.Util:createLabel("附魔", FONT_SIZE)
    -- m_fumoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BLUE)) 
    m_fumoLab       : setAnchorPoint( cc.p(0.0,0.5) )
    fumoNode        : addChild(m_fumoLab)

    local m_infoLab = _G.Util:createLabel(string.format("%d%s",fumoz/100,"%"), FONT_SIZE)
    -- m_infoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BLUE)) 
    m_infoLab       : setAnchorPoint( cc.p(0.0,0.5) )
    fumoNode        : addChild(m_infoLab)

    local addWidth = LINE_SPACING + 10
    local m_fumoLabSize = m_fumoLab : getContentSize()
    -- m_fumoLab       : setString("附魔加成: "..tostring(fumoz/100).."%")
    m_fumoLab       : setPosition(addWidth+m_fumoLabSize.width,-self.m_addheight-4) 
    m_infoLab       : setPosition(addWidth+m_fumoLabSize.width+45,-self.m_addheight-4) 

    return fumoNode
end

function TipsContainer.createGood_lineSpr( self )
	local m_lineSpr     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" ) 
	local m_lineSprSize = m_lineSpr : getPreferredSize()
	m_lineSpr           : setPreferredSize( cc.size(PRE_BACKGROUNGD_WIDTH-10,m_lineSprSize.height) )

	self.m_addheight = self.m_addheight - 20
	m_lineSpr : setPosition(PRE_BACKGROUNGD_WIDTH/2,-self.m_addheight)
	return m_lineSpr
end

function TipsContainer.returnLine(self)
    self.m_addheight = self.m_addheight - 20
end

function TipsContainer.createGood_BreakMaterial(self)
	local tempNode = cc.Node : create()
    local baseNode = self.m_good.goodCnf
    self.m_addheight = self.m_addheight-PRE_LINE_HEIGHT

    local infoLab = _G.Util:createLabel("分解:",  FONT_SIZE)
    -- infoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
    infoLab       : setAnchorPoint( cc.p(0.0,0.5) )
    tempNode      : addChild(infoLab)

    local infoLabSize = infoLab:getContentSize()
    local leftWid = LINE_SPACING+infoLabSize.width
    local rightWid= leftWid+105
    if baseNode.split==nil then
        local l_nameLab = _G.Util:createLabel("无", FONT_SIZE)
        -- l_nameLab  : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
        l_nameLab  : setAnchorPoint( cc.p(0.0,0.5) )
        l_nameLab  : setPosition(leftWid,-self.m_addheight)
        tempNode: addChild(l_nameLab)
    else
        local splitArray={}
        for i=1,#baseNode.split do
            splitArray[i]={}
            splitArray[i].id=baseNode.split[i][1]
            splitArray[i].count=baseNode.split[i][2]
        end
        local baseCount=#splitArray
        local splitRow=math.floor(baseCount/2)
        self.m_addheight=self.m_addheight-PRE_LINE_HEIGHT*splitRow
        if self.m_good.fumov>0 then
            local nCount=#splitArray+1
            splitArray[nCount]={}
            splitArray[nCount].id=43000
            splitArray[nCount].count=self.m_good.fumov
        end
        for i=1,#splitArray do
            local splitGoodsCnf=_G.Cfg.goods[splitArray[i].id]
            local goodsCount=splitArray[i].count
            local row=math.floor(i/2)
            local nnnn=i%2
            local nPosX,nPosY
            if nnnn==0 then
                nPosX=rightWid
                row=row-1
            else
                nPosX=leftWid
            end
            nPosY=self.m_addheight+row*PRE_LINE_HEIGHT
            if splitGoodsCnf and goodsCount then
                local l_nameLab=_G.Util:createLabel(splitGoodsCnf.name.."*"..tostring(goodsCount), FONT_SIZE)
                -- l_nameLab:setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)) 
                l_nameLab:setAnchorPoint( cc.p(0.0,0.5) )
                l_nameLab:setPosition(nPosX,-nPosY)
                tempNode:addChild(l_nameLab)
            end
        end
        
    end
	
    infoLab:setPosition(LINE_SPACING,-self.m_addheight)
    return tempNode
end

function TipsContainer.createGood_NameAndStrength( self )
    self.m_addheight = self.m_addheight-PRE_LINE_HEIGHT
    
	local goods_id   = self.m_good.goods_id
    local baseNode   = self.m_good.goodCnf
    local strengthen = self.m_good.strengthen
    local nameLab = nil 
    if baseNode == nil then
        nameLab = _G.Util:createLabel("id"..goods_id.."table no found", FONT_SIZE)
    else
        local str
        -- if strengthen>0 then
        --     str = baseNode.name.."("..strengthen..")"
        -- else
            str = baseNode.name
        -- end
        if strengthen>0 and self.m_good.goods_type == _G.Const.CONST_GOODS_MAGIC then
        	str = baseNode.name.."+"..strengthen
        end
    	nameLab = _G.Util:createLabel(str, FONT_SIZE+2)
    	nameLab : setColor(_G.ColorUtil:getRGBA(baseNode.name_color))    
    end
    nameLab  : setAnchorPoint( cc.p(0.0,0.5) )
    nameLab  : setPosition(LINE_SPACING,-self.m_addheight-4)

    return  nameLab
end



return TipsContainer

