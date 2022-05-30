---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/12/12 17:40:52
-- @description: 位面 雇佣宝可梦item
---------------------------------
PlanesHireHeroItem = class('PlanesHireHeroItem',function()
    return ccui.Widget:create()
end)

function PlanesHireHeroItem:ctor()
    self:configUI()
    self:registerEvent()
end

function PlanesHireHeroItem:configUI()
    self.size = cc.size(597, 141)
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("planes/planes_hire_hero_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    
    self.chose_btn = container:getChildByName("chose_btn")
    self.chose_btn:setSelected(false)
    self.name_txt = container:getChildByName("name_txt")
    self.atk_txt = container:getChildByName("atk_txt")
    self.check_btn = container:getChildByName("check_btn")
end

function PlanesHireHeroItem:registerEvent()
    self.chose_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            if self.callback then
                self.callback(self, true)
            end
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            if self.callback then
                self.callback(self, false)
            end
        end
    end)

    registerButtonEventListener(self.check_btn, handler(self, self.onClickCheckBtn), true)
end

function PlanesHireHeroItem:onClickCheckBtn(  )
    if self.data then
        HeroController:getInstance():openHeroTipsPanel(true, self.data)
    end
end

function PlanesHireHeroItem:setData(data)
    if not data then return end

    local hero_base_cfg = Config.PartnerData.data_partner_base[data.bid]
    if not hero_base_cfg then return end

    self.data = data
    
    if not self.hero_item then
        self.hero_item = HeroExhibitionItem.new(0.9)
        self.hero_item:setPosition(160, 70)
        self.container:addChild(self.hero_item)
    end
    self.hero_item:setData(data)

    self.name_txt:setString(hero_base_cfg.name)
    local power = data.power or 0
    self.atk_txt:setString(changeBtValueForPower(power))
end

function PlanesHireHeroItem:setIsSelect( status )
    self.chose_btn:setSelected(status)
end

function PlanesHireHeroItem:addCallBack( callback )
    self.callback = callback
end

-- 获取宝可梦bid
function PlanesHireHeroItem:getHireHeropos(  )
    if self.data then
        return self.data.pos
    end
end

function PlanesHireHeroItem:DeleteMe()
    if self.hero_item then
        self.hero_item:DeleteMe()
        self.hero_item = nil
    end
    self:removeAllChildren()
	self:removeFromParent()
end