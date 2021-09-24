
--PartnerTips 计算背景长度以及创建背景 按钮 以及回调逻辑
--TipsContainer 显示tips的内容

local PartnerTips = classGc(function(self)

    self.m_resourcesArray  = {}
end)

local FONT_SIZE = 20
local SKILL_WIDTH = 330
local SKILL_HEIGHT = 180

local ATTR_NAME = {"攻击:","气血:","破甲:","防御:","命中:","闪避:","暴击:","抗暴:"}
local ATTR_INDEX= {"strong_att","hp","defend_down","strong_def","hit","dod","crit","crit_res"}
local prop_img  = {"general_att.png","general_hp.png","general_wreck.png","general_def.png","general_hit.png",
                      "general_dodge.png","general_crit.png","general_crit_res.png"}


function PartnerTips._reset(self)
    ScenesManger.releaseFileArray(self.m_resourcesArray)
    
	if self._layer ~= nil then
		self._layer : removeFromParent(true)
		self._layer = nil 
	end
end

function PartnerTips.createPartner( self,partnerId,lv,position,noListerner)
    self.m_partnerid = partnerId
    self.m_lv        = lv
    self.m_position  = position
    self.m_data      = _G.Cfg.partner_init[partnerId]

    self:_reset()
    self._layer = cc.Node : create()
    self.m_winSize  = cc.Director:getInstance():getVisibleSize()

    local function onTouchBegan() 
        self:_reset()
        return true 
    end
    if noListerner ~= true then
        local listerner=cc.EventListenerTouchOneByOne:create()
        listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        listerner:setSwallowTouches(false)
        self._layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self._layer)
    end
    self :_init()
    return self._layer
end

function PartnerTips._init(self)
	self : initView()
	self : setLayerPosition()
end

function PartnerTips.getBgSize( self )
    return self.m_bgSprSize
end

function PartnerTips.initView( self )
    --容器
    self.m_container = cc.Node:create()
    self._layer      : addChild(self.m_container)
    --底图
    
    self.m_bgSpr     = cc.Sprite:create("ui/bg/partner_tipsbg.jpg") 
    self.m_container : addChild(self.m_bgSpr)
    self.m_bgSprSize = self.m_bgSpr:getContentSize()
    self.m_bgSpr     : setPosition(cc.p( self.m_bgSprSize.width/2, -self.m_bgSprSize.height/2))

    local posY       = self.m_bgSprSize.height

    local scale=0.65
    -- if _G.Cfg.partner_init[self.m_partnerid].scale~=nil then
    --     scale=_G.Cfg.partner_init[self.m_partnerid].scale/10000
    -- end
    local szImg=string.format("painting/a%d.png",self.m_data.skin)
    local tempSpr=_G.ImageAsyncManager:createNormalSpr(szImg)
    tempSpr:setPosition(95,self.m_bgSprSize.height/2+19)
    tempSpr:setScale(scale)
    self.m_bgSpr:addChild(tempSpr)

    local name       = _G.Util:createLabel(self.m_data.name,FONT_SIZE)
    name             : setPosition(12,posY-10)
    name             : setDimensions(25,0)
    name             : setAnchorPoint(0,1)
    name             : setColor(_G.ColorUtil:getRGB(self.m_data.name_colour))
    self.m_bgSpr     : addChild(name)
    -- _G.ColorUtil     : setLabelColor(name,self.m_data.name_color)

    local line  = ccui.Scale9Sprite : createWithSpriteFrameName( "general_view_line.png" )
    line        : setPosition( self.m_bgSprSize.width-140, 120 )
    line        : setPreferredSize( cc.size( 300, 2 ) )
    self.m_bgSpr: addChild( line )

    local skillLab   = _G.Util:createLabel("技能",FONT_SIZE)
    -- skillLab         : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))
    skillLab         : setAnchorPoint(0,0.5)
    skillLab         : setPosition(self.m_bgSprSize.width/2-40,100)
    self.m_bgSpr     : addChild(skillLab)

    for i=1,4 do
        local boxSpr = cc.Sprite : createWithSpriteFrameName("general_skillBox.png")
        self.m_bgSpr : addChild(boxSpr)
        local size   = boxSpr  : getContentSize()
        boxSpr       : setPosition(self.m_bgSprSize.width/2-8+(size.width+8)*(i-1),45)
        local skill  = self.m_data.all_skill
        if skill[i] ~= nil then
            local iconString = _G.Cfg.skill[skill[i][1]].icon
            local spr  = _G.ImageAsyncManager:createSkillSpr(iconString)
            spr       : setPosition(size.width/2,size.height/2)
            boxSpr : addChild(spr)
            if i > self.m_data.skill then
                spr : setGray()
            end

            local sprName = string.format("icon/s%d.png", iconString)
            if self.m_resourcesArray[sprName] == nil then
                self.m_resourcesArray[sprName] = true
            end
            print( " PartnerTips.initView = ", sprName )
        end    
    end

    local attr       = _G.Util:createLabel("属性",FONT_SIZE)
    -- attr             : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))
    attr             : setAnchorPoint(0,0.5)
    attr             : setPosition(self.m_bgSprSize.width/2-40,posY-25)
    self.m_bgSpr     : addChild(attr)
    local attrUp     = _G.Util:createLabel("（成长）",FONT_SIZE)
    -- attrUp           : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))
    attrUp           : setPosition(self.m_bgSprSize.width/2+40,posY-25)
    self.m_bgSpr     : addChild(attrUp)

    local bgSize = cc.size(140,20)
    local x   = nil
    local y   = posY - 28
    self.attrt   = {}
    self.attrVal = {}
    for i=1,8 do
        if i % 2 == 1 then
            x = self.m_bgSprSize.width/2-18 
            y = y - bgSize.height - 13
        else
            x = x + bgSize.width + 2
        end

        -- local spr_ATTR = cc.Sprite:createWithSpriteFrameName( prop_img[i] )
        -- spr_ATTR       : setAnchorPoint( 1, 0.5 )
        -- spr_ATTR       : setPosition( x-22,y )
        -- spr_ATTR       : setScale(0.8)
        -- self.m_bgSpr   : addChild( spr_ATTR )

        local attrt     = _G.Util:createLabel(ATTR_NAME[i],FONT_SIZE-2)
        -- attrt           : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))
        attrt           : setPosition(x,y)
        self.m_bgSpr    : addChild(attrt)

        local attrIndex = ATTR_INDEX[i]
        local attr      = self.m_data.attr[attrIndex] + self.m_data.up[attrIndex] * (self.m_lv - 1)
        local attrVal   = _G.Util:createLabel(attr,FONT_SIZE-2)
        attrVal         : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        attrVal         : setPosition(x+30,y)
        attrVal         : setAnchorPoint(0,0.5)
        self.m_bgSpr    : addChild(attrVal)


        local attrValUP = _G.Util:createLabel("("..self.m_data.up[attrIndex]..")",FONT_SIZE-2)
        attrValUP       : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        attrValUP       : setPosition(x+70,y)
        attrValUP       : setAnchorPoint(0,0.5)
        self.m_bgSpr    : addChild(attrValUP)

    end
    -- local spine = _G.SpineManager.createSpine("spine/goblins")
    -- local x = 3
    -- local function delayFun(_node)
    --     if x == 1 then
    --         spine : setSkin("1")
    --         x=x+1
    --     elseif x == 2 then
    --         spine : setSkin("2")
    --         x=x+1

    --     elseif x == 3 then
    --         spine : setSkin("3")
    --         x=x+1

    --     elseif x == 4 then
    --         spine : setSkin("goblin")
    --         x=x+1
    --     elseif x == 5 then
    --         spine : setSkin("goblingirl")
    --         x=1
    --     end
    --     print(x)
    -- end
    -- spine:setAnimation(0,"walk",true)
    -- spine:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(delayFun))))
    -- self.m_bgSpr : addChild(spine)

end

function PartnerTips.createSkill( self, skillId, position, isdark )
    self.m_skillId   = skillId
    self.m_position  = position
    self.m_isdark    = isdark
    self.m_data      = _G.g_SkillDataManager:getSkillIdToId(skillId)

    self:_reset()
    self._layer = cc.Node : create()
    self.m_winSize  = cc.Director:getInstance():getVisibleSize()

    local function onTouchBegan() 
        print("PartnerTips remove tips")
        self:_reset()
        return true 
    end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(false)
    self._layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self._layer)

    self : initSkillView()
    self : setLayerPosition()
    return self._layer
end

function PartnerTips.initSkillView( self )
    --容器
    self.m_container = cc.Node:create()
    self._layer      : addChild(self.m_container)
    --底图
    self.m_bgSprSize = cc.size(SKILL_WIDTH,SKILL_HEIGHT)
    self.m_bgSpr     = ccui.Scale9Sprite : createWithSpriteFrameName( "general_rolekuang.png" ) 
    self.m_bgSpr     : setPreferredSize(self.m_bgSprSize)
    self.m_container : addChild(self.m_bgSpr)
    self.m_bgSpr     : setPosition(cc.p( self.m_bgSprSize.width/2, -self.m_bgSprSize.height/2))

    local posY       = self.m_bgSprSize.height
    
    local spr        = cc.Sprite:createWithSpriteFrameName("general_skillBox.png")
    local size       = spr:getContentSize()
    spr              : setPosition(45,posY-50)
    self.m_bgSpr     : addChild(spr)

    local iconString = _G.Cfg.skill[self.m_skillId].icon
    local headSpr    = _G.ImageAsyncManager:createSkillSpr(iconString)
    headSpr          : setPosition(size.width/2,size.height/2)
    spr              : addChild(headSpr)

    local name       = _G.Util:createLabel(self.m_data.name,FONT_SIZE)
    name             : setPosition(90,posY-61)
    name             : setAnchorPoint(0,0)
    self.m_bgSpr     : addChild(name)
    -- name             : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GREEN))

    local line1      = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
    local lineY      = line1 : getContentSize().height
    line1            : setPreferredSize( cc.size( 233, lineY ) )
    line1            : setAnchorPoint( 0, 0 )
    line1            : setPosition( 85, posY-80 )
    self.m_bgSpr     : addChild( line1 )

    -- local showLab    = _G.Util : createLabel( "描述：", 20 )
    -- showLab : setPosition( 15, posY-122 )
    -- showLab : setAnchorPoint( 0, 1 )
    -- showLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    -- self.m_bgSpr : addChild( showLab )

    local des        = _G.Util:createLabel(self.m_data.lv[1].remark,FONT_SIZE)
    des              : setPosition(10,posY-122)
    des              : setAnchorPoint(0,1)
    des              : setDimensions( 220,200)
    self.m_bgSpr     : addChild(des)
    des              : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))

    if self.m_data.jihuo ~= nil and self.m_isdark == true then

        local lab = _G.Util : createLabel( "要求：", 20 )
        lab : setAnchorPoint( 0, 0 )
        lab : setPosition( 15, posY-115 )
        lab : setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_PALEGREEN ) )
        self.m_bgSpr : addChild( lab )

        local need        = _G.Util:createLabel(self.m_data.jihuo,FONT_SIZE)
        need             : setPosition(90,posY-115)
        need             : setAnchorPoint(0,0)
        self.m_bgSpr     : addChild(need)
        need             : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))

        local line2      = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
        line2            : setPreferredSize( cc.size( 310, lineY ) )
        line2            : setAnchorPoint( 0, 0 )
        line2            : setPosition( 10, posY-46-70 )
        self.m_bgSpr     : addChild( line2 )
    else
        -- showLab : setPosition( 15, posY-122+31 )
        des     : setPosition( 15, posY-122+31 )
    end
end

--设置Tip的位置 --使其在屏幕内显示
function PartnerTips.setLayerPosition( self )
	local m_winSzie = self.m_winSize
    if self.m_position.x+self.m_bgSprSize.width > m_winSzie.width then
        self.m_position.x = m_winSzie.width - self.m_bgSprSize.width
    end
    if self.m_position.y-self.m_bgSprSize.height < 0 then
        self.m_position.y = self.m_bgSprSize.height
    end
    print(" PartnerTips.setLayerPosition: ",self.m_position.x, self.m_position.y,self.m_bgSprSize.height)
    self._layer : setPosition( cc.p( self.m_position.x, self.m_position.y))
end

function PartnerTips.setLv(self)
    local val = self.m_lv
    local length = string.len(val)
    local spriteWidth,y = self.m_lvSpr:getPosition()
    if self.m_lvNumSpr == nil then
        self.m_lvNumSpr = cc.Node:create()
        self.m_bgSpr : addChild(self.m_lvNumSpr)
    else 
        self.m_lvNumSpr : removeAllChildren()
    end
    for i=1, length do
        local _tempSpr = cc.Sprite:createWithSpriteFrameName( "main_lv_"..string.sub(val,i,i)..".png")
        self.m_lvNumSpr : addChild( _tempSpr )

        local _tempSprSize = _tempSpr : getContentSize()
        spriteWidth        = spriteWidth + _tempSprSize.width / 2+5
        _tempSpr           : setPosition( spriteWidth,y)
    end
end

    
return PartnerTips