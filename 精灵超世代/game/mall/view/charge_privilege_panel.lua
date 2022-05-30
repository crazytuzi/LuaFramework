-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-11-13
-- --------------------------------------------------------------------
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format

ChargePrivilegePanel = ChargePrivilegePanel or BaseClass()

function ChargePrivilegePanel:__init(parent, offset_y)
    self.is_init = true
    self.parent = parent
    self.offset_y = offset_y or 0

    self:loadResListCompleted()
end

function ChargePrivilegePanel:loadResListCompleted( )
	self:createRootWnd()
    self:registerEvent()
    self:setData()
end

function ChargePrivilegePanel:createRootWnd( )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/charge_value_panel"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.main_container = self.root_wnd:getChildByName("main_container")

    local con_size = self.main_container:getContentSize()
    self.vip_tips_txt = createLabel(20, 1, cc.c4b(75,64,111,255), con_size.width - 10, 842, TI18N("均可获得vip积分"), self.main_container, 2, cc.p(1, 0.5))

    self.tips_txt = self.main_container:getChildByName("tips_txt")
    self.tips_txt:setVisible(true)
    self.tips_txt:setString(TI18N("超值强力宝可梦 额外远航特权 免费快速作战"))

    self.item_list = self.main_container:getChildByName("item_list")
    local list_size = self.item_list:getContentSize()
    local scroll_view_size = cc.size(list_size.width+10, list_size.height+130+self.offset_y)
	local setting = {
        start_x = 5,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 680,               -- 单元的尺寸width
        item_height = 174,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(self.item_list, cc.p(-5, -130-self.offset_y) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell)
    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells)
    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex)

    local image_1 = self.main_container:getChildByName("image_1")
    image_1:setContentSize(cc.size(list_size.width+10, list_size.height+self.offset_y+20))
    local image_pos_y = image_1:getPositionY()
    image_1:setPositionY(image_pos_y - self.offset_y)
end

function ChargePrivilegePanel:createNewCell(  )
    local cell = ChargePrivilegeItem.new()
    cell:addCallBack(handler(self, self.onClickCallBack))
	return cell
end

function ChargePrivilegePanel:numberOfCells(  )
    if not self.privilege_data then return 0 end
    return #self.privilege_data
end

function ChargePrivilegePanel:updateCellByIndex( cell, index )
    if not self.privilege_data then return end
    cell.index = index
    local cell_data = self.privilege_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ChargePrivilegePanel:onClickCallBack( charge_id )
    if charge_id then
        self.privilege_charge_id = charge_id
    end
end

function ChargePrivilegePanel:registerEvent( )
    if self.update_privilege == nil then
		self.update_privilege = GlobalEvent:getInstance():Bind(VipEvent.PRIVILEGE_INFO,function ( )
            if self.item_scrollview then
                self.item_scrollview:resetCurrentItems()
            end
		end)
	end
    if self.privilege_charge_data == nil then
        self.privilege_charge_data = GlobalEvent:getInstance():Bind(ActionEvent.Is_Charge_Event,function(data)
            if data and data.status and data.charge_id then
                local charge_config = Config.ChargeData.data_charge_data[data.charge_id]
                if charge_config and data.status == 1 and data.charge_id == self.privilege_charge_id then
                    sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name, charge_config.name)
                end
            end
        end)
    end
end

function ChargePrivilegePanel:setVisibleStatus( status )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end

    if status == true and self.is_init == true then
        self.is_init = false
        VipController:getInstance():getModel():setPrivilegeOpenFlag(true)
    end
end

function ChargePrivilegePanel:setData(  )
    self.privilege_data = {}
    local role_vo = RoleController:getInstance():getRoleVo()
    for k,config in pairs(Config.PrivilegeData.data_privilege_data) do
        if not config.limit_lev or config.limit_lev <= role_vo.lev then
            _table_insert(self.privilege_data, config)
        end
    end
    local sort_func = SortTools.KeyLowerSorter("sort_id")
    _table_sort(self.privilege_data, sort_func)

	self.item_scrollview:reloadData()
end

function ChargePrivilegePanel:addChild( node )
	if not tolua.isnull(self.root_wnd) and not tolua.isnull(node) then
        self.root_wnd:addChild(node)
    end
end

function ChargePrivilegePanel:setPosition( pos )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setPosition(pos)
    end
end

function ChargePrivilegePanel:__delete()
    if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	if self.update_privilege then
        GlobalEvent:getInstance():UnBind(self.update_privilege)
        self.update_privilege = nil
    end
    if self.privilege_charge_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.privilege_charge_data)
        self.privilege_charge_data = nil
    end
end

-----------------------@ item
ChargePrivilegeItem = class("ChargePrivilegeItem", function()
	return ccui.Widget:create()
end)

function ChargePrivilegeItem:ctor()
    self:configUI()
    self:registerEvent()

    self.touch_buy_privilege = true
end

function ChargePrivilegeItem:configUI(  )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("vip/privilege_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(680, 174))
    self:setAnchorPoint(0,0)

    self.container = self.root_wnd:getChildByName("container")
    self.image_title = self.container:getChildByName("image_title")
    self.title_txt = self.container:getChildByName("title_txt")
    self.limit_txt = self.container:getChildByName("limit_txt")
    self.image_icon = self.container:getChildByName("image_icon")
    self.image_icon:ignoreContentAdaptWithSize(true)
    self.image_icon:setScale(0.85)
    self.image_sell_out = self.container:getChildByName("image_sell_out")
    self.image_sell_out:setVisible(false)

    self.buy_btn = self.container:getChildByName("buy_btn")
    local btn_size = self.buy_btn:getContentSize()
    self.buy_btn_label = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.buy_btn:addChild(self.buy_btn_label)

    self.desc_txt = createRichLabel(20, cc.c3b(100,50,35), cc.p(0.5, 1), cc.p(378, 160), 5, nil, 350)
    self.container:addChild(self.desc_txt)

    local good_list = self.container:getChildByName("good_list")
    local scroll_size = good_list:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.7
    }
    self.good_scrollview = CommonScrollViewLayout.new(good_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_size, setting)
    self.good_scrollview:setSwallowTouches(false)
end

function ChargePrivilegeItem:registerEvent(  )
    registerButtonEventListener(self.buy_btn, handler(self, self.onClickItem), true, 1, nil, nil, nil, true)
end

function ChargePrivilegeItem:onClickItem(  )
    if self.srv_data and self.srv_data.status == TRUE then
        message(TI18N("该礼包已售罄"))
        return
    end

    if self.privilege_cfg then
        if self.privilege_cfg.pay_type == 1 then -- 人民币
            if not self.touch_buy_privilege then return end
            if self.buy_privilege_ticket == nil then
                self.buy_privilege_ticket = GlobalTimeTicket:getInstance():add(function()
                    self.touch_buy_privilege = true
                    if self.buy_privilege_ticket ~= nil then
                        GlobalTimeTicket:getInstance():remove(self.buy_privilege_ticket)
                        self.buy_privilege_ticket = nil
                    end
                end,2)
            end
            self.touch_buy_privilege = nil
            local charge_id = self.privilege_cfg.charge_id
            local charge_config = Config.ChargeData.data_charge_data[charge_id or 0]
            if charge_config then
                if self.callback then
                    self.callback(charge_config.id)
                end
                ActionController:getInstance():sender21016(charge_config.id)
            end
        elseif self.privilege_cfg.pay_type == 2 then -- 钻石
            MallController:getInstance():openChargeSureWindow(true, self.privilege_cfg)
        end
    end
end

function ChargePrivilegeItem:addCallBack( callback )
    self.callback = callback
end

function ChargePrivilegeItem:setData( data )
    if not data then return end

    self.privilege_cfg = data
    local srv_data = VipController:getInstance():getModel():getPrivilegeDataById(data.id)
    if not srv_data then
        srv_data = {}
        srv_data.status = 0
        srv_data.expire_time = 0
    end
    self.srv_data = srv_data

    -- 标题
    self.title_txt:setString(self.privilege_cfg.name or "")

    -- 图标
    if self.privilege_cfg.icon_id then
        local icon_res = _string_format("resource/mall_charge_icon/%s.png", self.privilege_cfg.icon_id)
        self.icon_load = loadImageTextureFromCDN(self.image_icon, icon_res, ResourcesType.single, self.icon_load)
    end
    
    -- 描述
    self.desc_txt:setString(self.privilege_cfg.desc or "")

    -- 奖励物品
    local role_vo = RoleController:getInstance():getRoleVo()
    local privilege_award_cfg = Config.PrivilegeData.data_privilege_award[data.id]
    if privilege_award_cfg then
        local award_data = {}
        for k,v in pairs(privilege_award_cfg) do
            if v.min <= role_vo.lev and v.max >= role_vo.lev then
                award_data = deepCopy(v.reward)
                break
            end
        end
        local item_list = {}
        for k,v in pairs(award_data) do
            local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
            if vo then
                vo.quantity = v[2]
                table.insert(item_list,vo)
            end
        end
        self.good_scrollview:setData(item_list)
        self.good_scrollview:addEndCallBack(function (  )
            local list = self.good_scrollview:getItemList()
            for k,v in pairs(list) do
                v:setDefaultTip()
            end
        end)
    end

    -- 限购类型
    if self.privilege_cfg.limit_type == 0 then -- 永久限购
        self.limit_txt:setString(TI18N("永久限购"))
    elseif self.privilege_cfg.limit_day < 2 then -- 每日限购
        self.limit_txt:setString(TI18N("每日限购"))
    elseif self.privilege_cfg.limit_day < 8 then -- 每周限购
        self.limit_txt:setString(TI18N("每周限购"))
    elseif self.privilege_cfg.limit_day < 32 then -- 每月限购
        self.limit_txt:setString(TI18N("每月限购"))
    end

    -- 按钮显示状态
    if srv_data.status == TRUE then
        if self.privilege_cfg.limit_type == 0 then -- 永久限购
            self.image_sell_out:setVisible(true)
            self.buy_btn:setVisible(false)
            if self.left_day_txt then
                self.left_day_txt:setVisible(false)
            end
        else
            self.image_sell_out:setVisible(false)
            self.buy_btn:setVisible(false)
            if not self.left_day_txt then
                self.left_day_txt = createRichLabel(28, cc.c3b(100,50,35), cc.p(1, 0.5), cc.p(652, 44))
                self.container:addChild(self.left_day_txt)
            end
            local cur_time = GameNet:getInstance():getTime()
            local left_time = (srv_data.expire_time or 0) - cur_time
            if left_time < 0 then left_time = 0 end
            local day = TimeTool.GetTimeName(left_time)
            if day < 1 then
                -- 小于1天则显示为小时
                self.left_day_txt:setString(string.format(TI18N("<div fontsize=24>还有</div><div fontsize=24 fontcolor=#249003>%s</div>"), TimeTool.GetTimeFormatTwo(left_time)))
            else
                self.left_day_txt:setString(string.format(TI18N("还有<div fontcolor=#249003>%s</div>天"), tostring(day)))
            end
            self.left_day_txt:setVisible(true)
        end
    else
        self.image_sell_out:setVisible(false)
        self.buy_btn:setVisible(true)
        if self.left_day_txt then
            self.left_day_txt:setVisible(false)
        end
        if self.privilege_cfg.pay_type == 1 then
            self.buy_btn_label:setString(string.format(TI18N("<div outline=2,#764519>%d元</div>"), self.privilege_cfg.loss))
        elseif self.privilege_cfg.pay_type == 2 then
            self.buy_btn_label:setString(string.format("<img src='%s' scale=0.3 /><div outline=2,#764519>%d</div>", PathTool.getItemRes(3), self.privilege_cfg.loss))
        end
    end
end

function ChargePrivilegeItem:DeleteMe(  )
    if self.buy_privilege_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_privilege_ticket)
        self.buy_privilege_ticket = nil
    end
    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end
    if self.icon_load then
        self.icon_load:DeleteMe()
        self.icon_load = nil
    end
    self:removeAllChildren()
	self:removeFromParent()
end