-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      升星分段界面
-- <br/> 2020年4月16日
-- --------------------------------------------------------------------
HeroUpgradeStarUpPanel = HeroUpgradeStarUpPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove

function HeroUpgradeStarUpPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "hero/hero_upgrade_star_up_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single }
    }

    --消耗数据列表
    -- self.item_list = {}

    -- self.title_height = 60 --横条高度
end

function HeroUpgradeStarUpPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 

    self.main_panel = self.main_container:getChildByName("main_panel")
    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("星阶升级"))
    self.close_btn = self.main_panel:getChildByName("close_btn")



    self.star_order_1 = self.main_container:getChildByName("star_order_1")
    self.star_label = self.star_order_1:getChildByName("label") 
    self.star_label:setString(TI18N("星级x"))
    self.cost_key = self.main_container:getChildByName("cost_key")
    self.cost_key:setString(TI18N("激活所需消耗: "))
    self.cost_tips = self.main_container:getChildByName("cost_tips")
    self.cost_tips:setString(TI18N("(二选一) "))



    self.up_btn = self.main_container:getChildByName("up_btn")
    self.up_btn:getChildByName("label"):setString(TI18N("升 级"))

    self.up_tips = self.main_container:getChildByName("up_tips")
    self.up_tips:setString(TI18N("该星阶已激活"))
    self.bottom_tips = self.main_container:getChildByName("bottom_tips")
    self.bottom_tips:setString(TI18N("(100%返还材料英雄升级、进阶消耗的金币、经验和进阶石)"))

    self.cost_bg_list = {}
    for i=1, 1 do
        local cost_bg = self.main_container:getChildByName("cost_bg")
        self.cost_bg_list[i] = {}
        self.cost_bg_list[i].cost_bg = cost_bg
        self.cost_bg_list[i].cost_icon = cost_bg:getChildByName("cost_icon")
        self.cost_bg_list[i].cost_txt = cost_bg:getChildByName("cost_txt")
    end

    self.item_node = {}
    self.item_node[1] = self.main_container:getChildByName("item_node1")
    self.item_node[2] = self.main_container:getChildByName("item_node2")
    
        --底部线
    -- local line_img = createImage(self.main_container, nil, 0, 0, cc.p(0,0.5), false, 1)
    -- -- line_img:setCapInsets(cc.rect(24, 24, 107, 89))
    -- line_img:setAnchorPoint(0.5,0)
    -- line_img:setScaleX(1.82)
    -- line_img:setPosition(cc.p(self.main_container:getContentSize().width/2, 18))

    -- local bg_res = PathTool.getPlistImgForDownLoad("bigbg/pattern", "pattern_1")
    -- self.line_load = loadImageTextureFromCDN(line_img, bg_res, ResourcesType.single, self.line_load)
end

function HeroUpgradeStarUpPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,false,2)

    registerButtonEventListener(self.up_btn, handler(self, self.onClickUpBtn) ,true, 2)

end

--关闭
function HeroUpgradeStarUpPanel:onClickBtnClose()
    controller:openHeroUpgradeStarUpPanel(false)
end

--升星
function HeroUpgradeStarUpPanel:onClickUpBtn()
    -- if self.is_show_tips then
    --     message(self.is_show_tips)
    --     return
    -- end
    -- if self.career then
    --     controller:send23708(self.career)
    --     -- self:onClickBtnClose()
    -- end
end


--职业
function HeroUpgradeStarUpPanel:openRootWnd(setting)
    local setting = setting or {}
    self.hero_vo = setting.hero_vo 
    self.index = setting.index or 1 
    if not self.hero_vo then return end

    local key = getNorKey(self.hero_vo.bid, self.hero_vo.star, self.index)
    local star_order_config = Config.PartnerData.data_partner_star_order(key)
end

--更新升星消耗的 英雄信息
function HeroUpgradeStarUpPanel:updateUpStarHeroInfo(i)
    -- body
end


function HeroUpgradeStarUpPanel:updateCostInfo( cost )
    for i=1,1 do
        local cost_data = cost[i]
        local cost_icon = self.cost_bg_list[i].cost_icon
        local cost_txt = self.cost_bg_list[i].cost_txt
        if cost_data then
            local bid = cost_data[1]
            local num = cost_data[2]
            local have_num = 0
            local item_config = Config.ItemData.data_get_data(bid)
            if item_config then
                cost_icon:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
                have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                cost_txt:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. MoneyTool.GetMoneyString(num))
                if have_num >= num then
                    cost_txt:setTextColor(cc.c3b(255, 246, 228))
                else
                    cost_txt:setTextColor(cc.c3b(0xff,0x8b,0x8b))
                end
            end
        else
            cost_txt:setString("")
        end
    end 
end

function HeroUpgradeStarUpPanel:close_callback()

    -- if self.line_load  then
    --     self.line_load:DeleteMe()
    -- end
    -- self.line_load = nil

    controller:openHeroUpgradeStarUpPanel(false)
end