--------------------------------------------
-- @Author  : lwc
-- @Editor  : lwc
-- @Date    : 2020年1月19日
-- @description    : 
        -- 单个商店
---------------------------------
local _controller = MallController:getInstance()
local _model = _controller:getModel()

MallSingleShopPanel = MallSingleShopPanel or BaseClass(BaseView)

function MallSingleShopPanel:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.layout_name = "crosschampion/crosschampion_shop_window"

    self.role_vo = RoleController:getInstance():getRoleVo()
end

function MallSingleShopPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:setScale(display.getMaxScale())
    end

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    self:playEnterAnimatianByObj(self.container , 2) 

    self.win_title = container:getChildByName("win_title")
    self.win_title:setString(TI18N("商店"))

    self.close_btn = container:getChildByName("close_btn")

    self.list_panel = container:getChildByName("list_panel")
    self.res_icon = container:getChildByName("res_icon")
    self.res_label = container:getChildByName("res_label")

    local setting = {
        item_class = MallItem,
        start_x = 0, -- 第一个单元的X起点
        space_x = 0, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 2, -- y方向的间隔
        item_width = 306, -- 单元的尺寸width
        item_height = 143, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 2                         -- 列数，作用于垂直滚动类
    }
    self.item_scroll_view = CommonScrollViewLayout.new(self.list_panel, nil, nil, nil, cc.size(self.list_panel:getContentSize().width, self.list_panel:getContentSize().height), setting)
    self.item_scroll_view:setPosition(0, 0)
end

function MallSingleShopPanel:register_event(  )
    registerButtonEventListener(self.close_btn, function (  )
        _controller:openMallSingleShopPanel(false)
    end, true, 2)

    registerButtonEventListener(self.background, function (  )
        _controller:openMallSingleShopPanel(false)
    end, false, 2)

    self:addGlobalEvent(MallEvent.Open_View_Event, function ( data )
        if data.type == self.mall_type then
            local list = self:getConfig(data)
            self.item_scroll_view:setData(list, function(cell)
                MallController:getInstance():openMallBuyWindow(true, cell:getData())
            end)
        end
    end)

    if not self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
            if key and self.coin_name and key == self.coin_name then 
                self:updateResNum()
            end
        end)
    end

    -- 道具数量变化
	self:addGlobalEvent(BackpackEvent.ADD_GOODS, function ( bag_code, data_list )
		self:updateItemNum(bag_code, data_list)
	end)

	self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function ( bag_code, data_list )
		self:updateItemNum(bag_code, data_list)
	end)

	self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function ( bag_code, data_list )
		self:updateItemNum(bag_code, data_list)
	end)
end

function MallSingleShopPanel:getConfig(data)
    local item_list = {}
    -- local config = Config.ExchangeData.data_shop_exchage_crosschampion
    local config = self.config
    if config then
        local list = deepCopy(data.item_list)
        for a, j in pairs(config) do
            if list and next(list or {}) ~= nil  then
                for k, v in pairs(list) do --已经买过的限购物品
                    if j.id == v.item_id then
                        if v.ext[1].val then --不管是什么限购 赋值已购买次数就好了。。
                            j.has_buy = v.ext[1].val
                            table.remove(list, k)
                        end
                        break
                    else
                        j.has_buy = 0
                    end
                end
            else
                j.has_buy = 0
            end
            local is_show = true
            if self.role_vo then
                is_show = self:checkShowLev(j.role_lev)
            end
            if is_show then
                table.insert(item_list, j)
            end
        end
    end
    table.sort(item_list ,function (a,b)
        if a.limit_count and a.limit_count > 0 and a.has_buy >= a.limit_count and (not b.limit_count or b.limit_count == 0 or b.has_buy < b.limit_count) then
            return false
        elseif b.limit_count and b.limit_count > 0 and b.has_buy >= b.limit_count and (not a.limit_count or a.limit_count == 0 or a.has_buy < a.limit_count) then
            return true
        else
            return  a.order < b.order
        end
    end)
    return item_list
end

function MallSingleShopPanel:checkShowLev(role_lev)
    if role_lev ~= nil and next(role_lev) ~= nil then
        for i,v in ipairs(role_lev) do
            if v[1] == "lv" then
                if self.role_vo.lev and self.role_vo.lev < v[2] then
                    return false
                end
            end
        end
    end
    return true
end

function MallSingleShopPanel:updateItemNum( bag_code, data_list )
    if self.item_id and bag_code and data_list then
        if bag_code == BackPackConst.Bag_Code.BACKPACK then
            for i,v in pairs(data_list) do
                if v and v.base_id and self.item_id == v.base_id then
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id)
                    self.res_label:setString(have_num)
                    break
                end
            end
        end
    end
end

function MallSingleShopPanel:updateResNum(  )
    if self.role_vo and self.coin_name then
        self.res_label:setString(self.role_vo[self.coin_name])
    elseif self.item_id then
        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id)
        self.res_label:setString(have_num)
    end
end
--setting
--setting.mall_type  商店类型  
--setting.item_id  道具id  暂时只支持 货币的id 默认 金币
--setting.config    对应商店类型的配置信息
--setting.shop_name  商店名字
function MallSingleShopPanel:openRootWnd(setting)
    local setting = setting or {}
    self.mall_type = setting.mall_type or MallConst.MallType.PeakchampionShop
    self.item_id = setting.item_id or 1
    self.coin_name = Config.ItemData.data_assets_id2label[self.item_id]
    self.config = setting.config
    MallController:getInstance():sender13401(self.mall_type)
    self:updateResNum()

    if setting.shop_name then
        self.win_title:setString(setting.shop_name)
    end
    if self.item_id then
        local item_config = Config.ItemData.data_get_data(self.item_id)
        if not item_config then return end
        local iconsrc = PathTool.getItemRes(item_config.icon)
        loadSpriteTexture(self.res_icon, iconsrc, LOADTEXT_TYPE)
    end
end

function MallSingleShopPanel:close_callback(  )
    if self.item_scroll_view then
        self.item_scroll_view:DeleteMe()
        self.item_scroll_view = nil
    end
    if self.role_lev_event and self.role_vo then
        self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end
    _controller:openMallSingleShopPanel(false)
end