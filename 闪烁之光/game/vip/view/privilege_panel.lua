--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-08 15:42:39
-- @description    : 
		-- VIP-特权礼包
---------------------------------
PrivilegePanel = class("PrivilegePanel", function()
    return ccui.Widget:create()
end)

local _controller = VipController:getInstance()
local _model = _controller:getModel()

function PrivilegePanel:ctor()  
    self.privilege_charge_id = 0
    self:config()
    self:layoutUI()
    self:registerEvents()
    self:setData()
    _model:setPrivilegeOpenFlag(true)
end

function PrivilegePanel:config(  )
	self.size = cc.size(673,661)
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0,0))

    self.root_wnd = createCSBNote(PathTool.getTargetCSB("vip/privilege_panel"))
	self.root_wnd:setPosition(-6.5, -8.5)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
end

function PrivilegePanel:registerEvents(  )
	if self.update_privilege == nil then
		self.update_privilege = GlobalEvent:getInstance():Bind(VipEvent.PRIVILEGE_INFO,function ( )
			self:setData()
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

function PrivilegePanel:layoutUI(  )
	self.main_container = self.root_wnd:getChildByName("main_container")

	local scrollCon = self.main_container:getChildByName("scrollCon")
	local scroll_size = scrollCon:getContentSize()
	local setting = {
        -- item_class = PrivilegeItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = -5,                   -- y方向的间隔
        item_width = 636,               -- 单元的尺寸width
        item_height = 177,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(scrollCon, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_size, setting)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function PrivilegePanel:createNewCell(width, height)
    local cell = PrivilegeItem.new(1, true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function PrivilegePanel:numberOfCells()
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function PrivilegePanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    cell:setData(data)
end
function PrivilegePanel:onCellTouched(cell)
    if cell then
        self.privilege_charge_id = cell:getData().charge_id or 0
    end
end

function PrivilegePanel:setData( )
    self.show_list = {}
    local role_vo = RoleController:getInstance():getRoleVo()
    for k,config in pairs(Config.PrivilegeData.data_privilege_data) do
        if not config.limit_lev or config.limit_lev <= role_vo.lev then
            table.insert(self.show_list, config)
        end
    end
    local sort_func = SortTools.KeyLowerSorter("sort_id")
    table.sort(self.show_list, sort_func)
    self.item_scrollview:reloadData()
end

function PrivilegePanel:setVisibleStatus( status )
	self:setVisible(status)
end

function PrivilegePanel:DeleteMe(  )
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

------------------@ 特权礼包子项
PrivilegeItem = class("PrivilegeItem", function()
    return ccui.Widget:create()
end)

function PrivilegeItem:ctor()
    self.touch_buy_privilege = true
	self:configUI()
	self:register_event()
end

function PrivilegeItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("vip/privilege_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(636, 177))
    self:setAnchorPoint(0,0)

    self.container = self.root_wnd:getChildByName("container")
    self.image_title = self.container:getChildByName("image_title")
    self.title_txt = self.container:getChildByName("title_txt")
    self.limit_txt = self.container:getChildByName("limit_txt")
    self.image_icon = self.container:getChildByName("image_icon")
    self.image_icon:ignoreContentAdaptWithSize(true)
    self.image_sell_out = self.container:getChildByName("image_sell_out")
    self.image_sell_out:setVisible(false)

    self.buy_btn = self.container:getChildByName("buy_btn")
    local btn_size = self.buy_btn:getContentSize()
    self.buy_btn_label = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.buy_btn:addChild(self.buy_btn_label)

    self.desc_txt = createRichLabel(20, cc.c3b(100,50,35), cc.p(0.5, 1), cc.p(354, 160), 5, nil, 350)
    self.container:addChild(self.desc_txt)

    
    local good_list = self.container:getChildByName("good_list")
    local scroll_size = good_list:getContentSize()
    self.good_scrollview = createScrollView(scroll_size.width, scroll_size.height, 0, 0, good_list, ScrollViewDir.horizontal) 
end

function PrivilegeItem:register_event(  )
	registerButtonEventListener(self.buy_btn, handler(self, self._onClickBuyBtn), true)
end

-- 点击购买
function PrivilegeItem:_onClickBuyBtn()
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
                    self:callback()
                end
                ActionController:getInstance():sender21016(charge_config.id)
            end
        elseif self.privilege_cfg.pay_type == 2 then -- 钻石
            _controller:sender24501(self.privilege_cfg.id)
        end
    end
end

function PrivilegeItem:getData()
    return self.privilege_cfg
end
function PrivilegeItem:addCallBack(value)
    self.callback =  value
end

function PrivilegeItem:setData( data )
	if not data then return end

    self.privilege_cfg = data
    local srv_data = _model:getPrivilegeDataById(data.id)
    if not srv_data then
        srv_data = {}
        srv_data.status = 0
        srv_data.expire_time = 0
    end

    -- 标题
    if self.privilege_cfg.title_type == 1 then
        self.image_title:loadTexture(PathTool.getResFrame("vip","vip_image_1"), LOADTEXT_TYPE_PLIST)
    elseif self.privilege_cfg.title_type == 2 then
        self.image_title:loadTexture(PathTool.getResFrame("vip","vip_image_3"), LOADTEXT_TYPE_PLIST)
    elseif self.privilege_cfg.title_type == 3 then
        self.image_title:loadTexture(PathTool.getResFrame("vip","vip_image_7"), LOADTEXT_TYPE_PLIST)
    end
    self.title_txt:setString(self.privilege_cfg.name or "")

    -- 图标,这里用到了 10 11 12
    if self.privilege_cfg.icon_id then
        local res_path = PathTool.getResFrame("vip","vip_icon" .. self.privilege_cfg.icon_id)
        self.image_icon:loadTexture(res_path, LOADTEXT_TYPE_PLIST)
    end

    -- 描述
    self.desc_txt:setString(self.privilege_cfg.desc or "")

    -- 奖励物品
    local role_vo = RoleController:getInstance():getRoleVo()
    local privilege_award_cfg = Config.PrivilegeData.data_privilege_award[data.id]
    if privilege_award_cfg then
        local data_list = {}
        for k,v in pairs(privilege_award_cfg) do
            if v.min <= role_vo.lev and v.max >= role_vo.lev then
                data_list = v.reward
                break
            end
        end
        local setting = {}
        setting.scale = 0.7
        setting.max_count = 3
        setting.is_center = true
        setting.space_x = 10
        -- setting.show_effect_id = 263
        self.item_list = commonShowSingleRowItemList(self.good_scrollview, self.item_list, data_list, setting)
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
                self.left_day_txt = createRichLabel(28, cc.c3b(100,50,35), cc.p(1, 0.5), cc.p(615, 44))
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

function PrivilegeItem:DeleteMe(  )
    if self.buy_privilege_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_privilege_ticket)
        self.buy_privilege_ticket = nil
    end
    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    
	self:removeAllChildren()
	self:removeFromParent()
end