-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      升星tips
-- <br/>Create: 2020年4月16日
-- --------------------------------------------------------------------
HeroUpgradeStarTipsPanel = HeroUpgradeStarTipsPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local string_format = string.format

function HeroUpgradeStarTipsPanel:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "hero/hero_upgrade_star_tips_panel"
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

end

function HeroUpgradeStarTipsPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
        -- self.background:setSwallowTouches(false)
    end
    self.container = self.root_wnd:getChildByName("main_panel")
    self.star_order_list = {}
    for i=1,4 do
        local star_order = self.container:getChildByName("star_order_"..i)
        if star_order then
            local order = {}
            order.star_order = star_order
            order.index = i
            order.label = star_order:getChildByName("label")
            order.label:setString(string_format(TI18N("星阶%s"), i))
            local x ,y = star_order:getPosition()
            order.desc = createRichLabel(24, cc.c3b(0xEA, 0xB5,0x50), cc.p(0, 1), cc.p(x + 80, y + 50), 5, nil, 300)
            self.container:addChild(order.desc)
            self.star_order_list[i] = order
        end
    end

    self.container:getChildByName("title_label"):setString(TI18N("星阶总加成展示"))
   
end

function HeroUpgradeStarTipsPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, 1)

    registerButtonEventListener(self.goto_btn_1, handler(self, self.onClickGotoBtn1) ,true, 2)
    registerButtonEventListener(self.goto_btn_2, handler(self, self.onClickGotoBtn1) ,true, 2)
    registerButtonEventListener(self.goto_btn_3, handler(self, self.onClickGotoBtn3) ,true, 2)
    registerButtonEventListener(self.goto_btn_4, handler(self, self.onClickGotoBtn4) ,true, 2)
    registerButtonEventListener(self.bottom_btn, handler(self, self.onClickBottomBtn) ,true, 2)


     --宝可梦详细信息
    self:addGlobalEvent(HeroEvent.Hero_Vo_Detailed_info, function(hero_vo)
        if hero_vo and hero_vo.partner_id == self.hero_vo.partner_id then
            self:setData(hero_vo)
        end
    end)
    
end

--关闭
function HeroUpgradeStarTipsPanel:onClickCloseBtn()
    controller:openHeroUpgradeStarTipsPanel(false)
end



function HeroUpgradeStarTipsPanel:openRootWnd(hero_vo, is_my)
    if not hero_vo then return end
    self.hero_vo = hero_vo

    for i=1,4 do
        local order = self.star_order_list[i]
        if order then
            order.desc:setString("随便测试\n随便测试2\n随便测试3\n我的星阶是: "..i)
        end
    end
end


function HeroUpgradeStarTipsPanel:close_callback()
    controller:openHeroUpgradeStarTipsPanel(false)
end