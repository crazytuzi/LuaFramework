--------------------------------------------
-- @Author  : lwc
-- @Editor  : lwc
-- @Date    : 2020年1月19日
-- @description    : 
        -- 巅峰冠军赛商店
---------------------------------
local _controller = ArenapeakchampionController:getInstance()
local _model = _controller:getModel()

ArenapeakchampionShopWindow = ArenapeakchampionShopWindow or BaseClass(BaseView)

function ArenapeakchampionShopWindow:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.layout_name = "crosschampion/crosschampion_shop_window"

    self.role_vo = RoleController:getInstance():getRoleVo()
end

function ArenapeakchampionShopWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:setScale(display.getMaxScale())
    end

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)
    self.container = container

    local win_title = container:getChildByName("win_title")
    win_title:setString(TI18N("巅峰商店"))

    self.close_btn = container:getChildByName("close_btn")

    self.list_panel = container:getChildByName("list_panel")
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

function ArenapeakchampionShopWindow:register_event(  )
    registerButtonEventListener(self.close_btn, function (  )
        _controller:openArenapeakchampionShopWindow(false)
    end, true, 2)

    registerButtonEventListener(self.background, function (  )
        _controller:openArenapeakchampionShopWindow(false)
    end, false, 2)

    self:addGlobalEvent(MallEvent.Open_View_Event, function ( data )
        if data.type == MallConst.MallType.PeakchampionShop then
            local list = self:getConfig(data)
            self.item_scroll_view:setData(list, function(cell)
                MallController:getInstance():openMallBuyWindow(true, cell:getData())
            end)
        end
    end)

    if not self.role_lev_event and self.role_vo then
        self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
            if key and key == "cluster_guess_cent" then 
                self:updateResNum()
            end
        end)
    end
end

function ArenapeakchampionShopWindow:getConfig(data)
    local item_list = {}
    local config = Config.ExchangeData.data_shop_exchage_crosschampion
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
            table.insert(item_list, j)
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

function ArenapeakchampionShopWindow:updateResNum(  )
    if self.role_vo then
        self.res_label:setString(self.role_vo.cluster_guess_cent)
    end
end

function ArenapeakchampionShopWindow:openRootWnd(  )
    MallController:getInstance():sender13401(MallConst.MallType.PeakchampionShop)
    self:updateResNum()
end

function ArenapeakchampionShopWindow:close_callback(  )
    if self.item_scroll_view then
        self.item_scroll_view:DeleteMe()
        self.item_scroll_view = nil
    end
    if self.role_lev_event and self.role_vo then
        self.role_vo:UnBind(self.role_lev_event)
        self.role_lev_event = nil
    end
    _controller:openArenapeakchampionShopWindow(false)
end