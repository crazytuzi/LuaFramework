-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      共鸣水晶卸下放入的英雄
-- <br/> 2020年3月6日
-- --------------------------------------------------------------------
HeroResonateComfirmLevPanel = HeroResonateComfirmLevPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local math_ceil = math.ceil


function HeroResonateComfirmLevPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "hero/hero_resonate_comfirm_lev_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("planes","planes_map"), type = ResourcesType.plist }
    }
    
end

function HeroResonateComfirmLevPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)  
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("升级"))

    self.lev_key = self.main_container:getChildByName("lev_key")
    self.lev_key:setString(TI18N("等级提升"))

    self.power_key = self.main_container:getChildByName("power_key")
    self.power_key:setString(TI18N("战力提升"))
    self.left_lv = self.main_container:getChildByName("left_lv")
    self.left_lv:setString(TI18N(""))
    self.right_lv = self.main_container:getChildByName("right_lv")
    self.right_lv:setString(TI18N(""))

    self.left_power = createRichLabel(26, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(210,221),nil,nil,600)
    self.main_container:addChild(self.left_power)
    self.right_power = createRichLabel(26, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(460,221),nil,nil,600)
    self.main_container:addChild(self.right_power)

    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("取 消"))
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("确 定"))
    self.cost_bg_list = {}
    for i=1, 3 do
        local cost_bg = self.main_container:getChildByName("cost_bg_"..i)
        self.cost_bg_list[i] = {}
        self.cost_bg_list[i].cost_icon = cost_bg:getChildByName("cost_icon")
        self.cost_bg_list[i].cost_txt = cost_bg:getChildByName("cost_txt")
        self.cost_bg_list[i].cost_txt:setString(0)
    end

    --底部线
    -- local line_img = createImage(self.main_container, nil, 0, 0, cc.p(0,0.5), false, 1)
    -- line_img:setCapInsets(cc.rect(24, 24, 107, 89))
    -- line_img:setAnchorPoint(0.5,0)
    -- line_img:setScaleX(0.94)
    -- line_img:setPosition(cc.p(self.main_container:getContentSize().width/2, -50))

    -- local bg_res = PathTool.getPlistImgForDownLoad("bigbg/pattern", "pattern_3")
    -- self.line_load = loadImageTextureFromCDN(line_img, bg_res, ResourcesType.single, self.line_load)
end

function HeroResonateComfirmLevPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 1)

    self:addGlobalEvent(HeroEvent.Hero_Resonate_Crystal_Power_Event, function(data)
        if not data then return end
        self:setPowerInfo(data.power)
    end)
end

--关闭
function HeroResonateComfirmLevPanel:onClickBtnClose()
    controller:openHeroResonateComfirmLevPanel(false)
end


-- 确定使用
function HeroResonateComfirmLevPanel:onClickBtnRight()
    if self.power then
       controller:sender26430()
    end
    self:onClickBtnClose()
end
--setting
--setting.left_lv 
--setting.right_lv 
--setting.left_power
--setting.right_power

function HeroResonateComfirmLevPanel:openRootWnd(setting)
    controller:sender26431()

    local setting = setting or {}
    local left_lv = setting.left_lv or 0
    local right_lv = setting.right_lv or 0 
    local left_power = setting.left_power or 0
    self.left_lv:setString("Lv."..left_lv)
    self.right_lv:setString("Lv."..right_lv)

    local res = PathTool.getResFrame("common", "common_2016")
    local str = string_format("<img src='%s' scale=1 />%s",res,left_power)
    self.left_power:setString(str)

    self:updateCostInfo(left_lv)
end

function HeroResonateComfirmLevPanel:setPowerInfo(power)
    self.power = power
    local res = PathTool.getResFrame("common", "common_2016")
    local str = string_format("<img src='%s' scale=1 />%s",res,power)
    self.right_power:setString(str)
end

function HeroResonateComfirmLevPanel:updateCostInfo(lev)
    local config = Config.ResonateData.data_crystal_cost[lev]
    if config and next(config.expend) ~= nil then
        for i=1,3 do
            local cost_data = config.expend[i]
            local cost_icon = self.cost_bg_list[i].cost_icon
            local cost_txt = self.cost_bg_list[i].cost_txt
            if cost_data then
                local bid = cost_data[1]
                local num = cost_data[2]
                local item_config = Config.ItemData.data_get_data(bid)
                if item_config then
                    cost_icon:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
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
end


function HeroResonateComfirmLevPanel:close_callback()
    if self.line_load  then
        self.line_load:DeleteMe()
    end
    self.line_load = nil

    if self.left_hero_item then
        self.left_hero_item:DeleteMe()
        self.left_hero_item = nil
    end

    if self.right_hero_item then
        self.right_hero_item:DeleteMe()
        self.right_hero_item = nil
    end

    controller:openHeroResonateComfirmLevPanel(false)
end
