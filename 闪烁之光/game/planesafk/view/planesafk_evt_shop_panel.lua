-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      位面事件商店
-- <br/> 2020年2月12日
-- --------------------------------------------------------------------
PlanesafkEvtShopPanel = PlanesafkEvtShopPanel or BaseClass(BaseView)

local controller = PlanesafkController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local math_ceil = math.ceil


function PlanesafkEvtShopPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "planesafk/planesafk_evt_shop_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("planes","planes_map"), type = ResourcesType.plist }
    }
    self.dic_other_hero = {}
end

function PlanesafkEvtShopPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("旅行商人"))

    self.scroll_container = self.main_container:getChildByName("scroll_container")


    self.bg_tips = self.main_container:getChildByName("bg_tips")
    
    self.bg_tips:setString(TI18N("看来你的运气不错,这里能买到不少好东西")) 

    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn_label = self.left_btn:getChildByName("label")
    self.left_btn_label:setString(TI18N("前 往"))   

    self.shop_icon = self.main_container:getChildByName("shop_icon")
    local bg_res = PathTool.getPlistImgForDownLoad("planes", "shop_icon")
    self.shop_load = loadSpriteTextureFromCDN(self.shop_icon, bg_res, ResourcesType.single, self.shop_load)
    --底部线
    local line_img = createImage(self.main_container, nil, 0, 0, cc.p(0,0.5), false, 1)
    line_img:setCapInsets(cc.rect(24, 24, 107, 89))
    line_img:setAnchorPoint(0.5,0)
    line_img:setScaleX(0.94)
    line_img:setPosition(cc.p(self.main_container:getContentSize().width/2, 6))

    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/pattern", "pattern_3")
    self.line_load = loadImageTextureFromCDN(line_img, bg_res, ResourcesType.single, self.line_load)
end

function PlanesafkEvtShopPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)

    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnRight) ,true, 1)


    self:addGlobalEvent(PlanesafkEvent.Evt_Shop_Event, function(data)
        if not data then return end
        self.data = data
        self:updateData()
        self:updateListInfo()
    end)
end

--关闭
function PlanesafkEvtShopPanel:onClickBtnClose()
    controller:openPlanesafkEvtShopPanel(false)
end

-- 确定使用
function PlanesafkEvtShopPanel:onClickBtnRight()
    if not self.data then return end
    if self.data.is_select == 1 then
        -- self.left_btn:getChildByName("label"):setString(TI18N("离 开"))   
        controller:sender28600(self.data.line, self.data.index, 1, {{type = PlanesafkConst.Proto_28600._8, val1 = 0, val2 = 0}} )
        self:onClickBtnClose()
    else
        -- self.left_btn:getChildByName("label"):setString(TI18N("前 往"))   
        controller:sender28600(self.data.line, self.data.index, 1, {{type = PlanesafkConst.Proto_28600._6, val1 = 0, val2 = 0}} )
    end
end

-- data 28621协议结构
function PlanesafkEvtShopPanel:openRootWnd(data)
    if not data then return end
    self.data = data

    local evt_data = controller:getMapEvtData(self.data.line, self.data.index)
    if evt_data and evt_data.is_black then
        self.left_btn:setVisible(false)
    end

    self:setData()
    self:updateData()
end

function PlanesafkEvtShopPanel:updateData()
    if not self.data then return end
    local evt_data = controller:getMapEvtData(self.data.line, self.data.index)
    if evt_data and evt_data.is_black then
        self.left_btn:setVisible(false) 
    else
        self.left_btn:setVisible(true) 


        if self.data.is_select == 1 then
            if not self.is_common_1017 then
                self.is_common_1017 = true
                local res = PathTool.getResFrame("common", "common_1017")
                self.left_btn:loadTexture(res, LOADTEXT_TYPE_PLIST)
                self.left_btn_label:enableOutline(Config.ColorData.data_color4[264], 2) --橙色
            end
            self.left_btn_label:setString(TI18N("放 弃"))     
        else
            self.left_btn_label:setString(TI18N("前 往"))  
        end
    end
end

function PlanesafkEvtShopPanel:setData()
    if not self.data then return end

    self.show_list = self.data.item_list
    table_sort(self.show_list, function(a, b) return a.pos < b.pos end)
    self:updateList()
end

function PlanesafkEvtShopPanel:updateListInfo()
    self.show_list = self.data.item_list
    table_sort(self.show_list, function(a, b) return a.pos < b.pos end)
    if self.item_scrollview then
        self.item_scrollview:resetCurrentItems()
    end
end


function PlanesafkEvtShopPanel:updateList()
    if self.item_scrollview == nil then
        local item_width = nil
        if #self.show_list <= 4 then
            item_width = 150
        else
            item_width = 135
        end

        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 2,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = item_width,                -- 单元的尺寸width
            item_height = 200,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        if #self.show_list <= 4 then
            self.item_scrollview:setClickEnabled(false)
        end
    end

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无商店数据")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function PlanesafkEvtShopPanel:createNewCell(width, height)
    -- local height = 122 --高度写死
    local cell = PlanesafkEvtShopItem.new(width, height, self)
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function PlanesafkEvtShopPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function PlanesafkEvtShopPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    cell:setData(data)
end


function PlanesafkEvtShopPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil

    if self.shop_load  then
        self.shop_load:DeleteMe()
    end
    self.shop_load = nil
    if self.line_load  then
        self.line_load:DeleteMe()
    end
    self.line_load = nil
    controller:openPlanesafkEvtShopPanel(false)
end


-- 子项
PlanesafkEvtShopItem = class("PlanesafkEvtShopItem", function()
    return ccui.Widget:create()
end)

function PlanesafkEvtShopItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function PlanesafkEvtShopItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("planesafk/planesafk_evt_shop_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.item_node = self.main_container:getChildByName("item_node")
    self.item = BackPackItem.new(true, true)
    self.item:setDefaultTip()
    self.item_node:addChild(self.item)

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    local btn_size = self.comfirm_btn:getContentSize()
    self.price_label = createRichLabel(24, cc.c3b(255,255,255), cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.comfirm_btn:addChild(self.price_label)

    self.discount = self.main_container:getChildByName("discount")
    self.discount_num = self.discount:getChildByName("discount_num")
end

function PlanesafkEvtShopItem:register_event( )
    registerButtonEventListener(self.comfirm_btn, handler(self, self.showAlert) ,true, 2)
    
end

function PlanesafkEvtShopItem:setData(data, index)
    if not data then return end
    self.data = data

    --测试数据
    local shop_config = Config.PlanesData.data_shop_info[self.data.id]
    if not shop_config then return end
    -- shop_config.base_id = 1
    -- shop_config.discount = 5
    -- shop_config.type = 3
    -- shop_config.price = 1000
    -- shop_config.num = 1000

    self.shop_config = shop_config

    if self.item  then
        self.item:setBaseData(shop_config.base_id, shop_config.num)
    end

    if shop_config.discount > 0 then
        self.discount_num:setString(shop_config.discount..TI18N("折"))
        self.discount:setVisible(true)
    else
        self.discount:setVisible(false)
    end
    if self.parent and self.parent.data and self.parent.data.is_select == 1  then
        if self.data.is_flag == 1 then
            setChildUnEnabled(true, self.comfirm_btn)
            self.comfirm_btn:setTouchEnabled(false)
            self.price_label:setString(TI18N("已售完"))
        else
            self.comfirm_btn:setTouchEnabled(true)
            setChildUnEnabled(false, self.comfirm_btn)
            local pay_type = Config.ItemData.data_assets_label2id[shop_config.type]
            local item_config = Config.ItemData.data_get_data(pay_type)
            if item_config then 
                local res = PathTool.getItemRes(item_config.icon)
                local price = shop_config.price
                local price_str = string.format("<img src='%s' scale=0.3 /><div fontcolor=#FFFFFF outline=2,#764519> %s</div>", res, MoneyTool.GetMoneyString(price))
                self.price_label:setString(price_str)
            end
        end
    else
        local pay_type = Config.ItemData.data_assets_label2id[shop_config.type]
        local item_config = Config.ItemData.data_get_data(pay_type)
        if item_config then 
            local res = PathTool.getItemRes(item_config.icon)
            local price = shop_config.price
            local price_str = string.format("<img src='%s' scale=0.3 /><div fontcolor=#FFFFFF> %s</div>", res, MoneyTool.GetMoneyString(price))
            self.price_label:setString(price_str)
        end
        setChildUnEnabled(true, self.comfirm_btn)
        self.comfirm_btn:setTouchEnabled(false)
    end
end

function PlanesafkEvtShopItem:showAlert()
    if self.parent and self.parent.data and self.parent.data.is_select == 1  then
        if self.data.is_flag == 1 then
            message(TI18N("已售完"))
            return
        end
        self:onBuyItem()
    else
        -- message(TI18N("请先选择前往,方能购买商品"))
    end
end
function PlanesafkEvtShopItem:onBuyItem()
    if not self.shop_config then return end
    --购买实际价格
    local price = self.shop_config.price
    local role_vo = RoleController:getInstance():getRoleVo()
    if not role_vo then return end
    local pay_type = Config.ItemData.data_assets_label2id[self.shop_config.type]
    local cur_num = BackpackController:getInstance():getModel():getItemNumByBid(pay_type)
    if cur_num >= price then
        local item_cfg = Config.ItemData.data_get_data(self.shop_config.base_id)
        local bag_type = BackPackConst.Bag_Code.BACKPACK
        if item_cfg.sub_type == 1 then --背包中装备类型
            bag_type = BackPackConst.Bag_Code.EQUIPS
        end
        local num = BackpackController:getInstance():getModel():getItemNumByBid(self.shop_config.base_id, bag_type)
        local tips_str = string.format(TI18N("是否购买<div fontColor=#289b14 fontsize= 26>%s</div>(拥有:<div fontColor=#289b14 fontsize= 26>%d</div>)？"), item_cfg.name, num)
        CommonAlert.show(tips_str, TI18N("确定"), function()
            if self.parent and self.parent.data and self.data then
                controller:sender28600(self.parent.data.line, self.parent.data.index, 1, {{type = PlanesafkConst.Proto_28600._7, val1 = self.data.pos, val2 = 0}} )
            end
        end, TI18N("取消"), nil, CommonAlert.type.rich)
    else
        local pay_config = nil
        if type(self.shop_config.type) == 'number' then
            pay_config = Config.ItemData.data_get_data(self.shop_config.type)
        else
            pay_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id[self.shop_config.type])
        end
        if pay_config then
            if pay_config.id == Config.ItemData.data_assets_label2id.gold then
                if FILTER_CHARGE then
                    message(TI18N("钻石不足"))
                else
                    local function fun()
                        VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
                        --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
                    end
                    local str = string.format(TI18N('%s不足，是否前往充值？'), pay_config.name)
                    CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
                end
            else
                BackpackController:getInstance():openTipsSource(true, pay_config)
            end
        end
    end
end

function PlanesafkEvtShopItem:setSelectImg()
    -- body
end


function PlanesafkEvtShopItem:DeleteMe()

    self:removeAllChildren()
    self:removeFromParent()
end