-- --------------------------------------------------------------------
-- 批量使用物品界面
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
BackPackBatchView = BackPackBatchView or BaseClass(BaseView)

function BackPackBatchView:__init(ctrl)
    self.ctrl = ctrl
    self.layout_name = "backpack/batchuse_panel_view"
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.MSG_TAG
    self.role_vo = RoleController:getInstance():getRoleVo()
    self.cur_selected_sum = 0                       -- 当前选中消耗的数量
    self.select_goods = nil
end

function BackPackBatchView:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.close_btn = self.main_container:getChildByName("close_btn")

    self.item = BackPackItem.new(self.ctrl, true, false)
    self.item:setPosition(116, 384)
    self.main_container:addChild(self.item)

    self.use_btn = self.main_container:getChildByName("use_btn")    
	self.use_btn:setTitleText(TI18N("使用"))
    self.use_btn.label = self.use_btn:getTitleRenderer()
    if self.use_btn.label ~= nil then
        self.use_btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
    end

    self.handle_container = self.main_container:getChildByName("handle_container")
    self.handle_container_cy = self.handle_container:getContentSize().height * 0.5

    -- 如果不是产出资源类的,这个东西要居中父节点
    self.container = self.handle_container:getChildByName("container")
    self.container_y = self.container:getPositionY()

    self.sub_btn = self.container:getChildByName("sub_btn")                                 -- 减号
    self.add_btn = self.container:getChildByName("add_btn")                                 -- 加号
    self.max_btn = self.container:getChildByName("max_btn")                                 -- 最大值
    self.slider = self.container:getChildByName("slider")                                   -- 滑块
    self.slider:setBarPercent(20, 80)

    self.value = self.container:getChildByName("value")                                 -- 使用数量提示

    self.use_title = self.container:getChildByName("title")                                 -- 使用数量提示
    self.use_title:setString(TI18N("使用数量："))

    self.extend_container = self.handle_container:getChildByName("extend_container")
    self.use_item_title = self.extend_container:getChildByName("use_item_title")
    self.use_item_title:setString("")

    self.use_effect = self.extend_container:getChildByName("use_effect")

    self.title_label = self.main_container:getChildByName("title_label")
    self.title_label:setString(TI18N("批量使用"))
    self.item_name = self.main_container:getChildByName("item_name")
    self.item_own = self.main_container:getChildByName("item_own")
end

function BackPackBatchView:register_event()
    if self.slider ~= nil then
    	self.slider:addEventListener(function ( sender,event_type )
    		if event_type == ccui.SliderEventType.percentChanged then
                self:setCurUseItemInfoByPercent(self.slider:getPercent())
    		end
    	end)
    end
    self.close_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            self.ctrl:openBatchUseItemView(false)
        end
    end)
    self.use_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            if self.item_vo == nil or self.item_vo.config == nil then return end
            self.cur_selected_sum = math.min(self.cur_selected_sum,self.item_vo.quantity)
            if self.cur_selected_sum == 0 then
                message(TI18N("当前数量不能为0"))
                return
            end
            if self.type == ItemConsumeType.use then
                self.ctrl:sender10515(self.item_vo.id, self.cur_selected_sum,self.select_goods)
            else
                --金币市场的物品出售
                if self.select_goods and self.select_goods.type and self.select_goods.type == 1 then 
                    MarketController:getInstance():sender23502( self.item_vo.id,self.cur_selected_sum)
                    self.ctrl:openBatchUseItemView(false)
                    return
                end
                self.ctrl:sender10522(BackPackConst.Bag_Code.BACKPACK, {{id=self.item_vo.id, bid=self.item_vo.base_id,num=self.cur_selected_sum}})
            end
        end
    end)
    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then

        end
    end)
    self.sub_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            if self.item_vo == nil then return end
            local percent = self.slider:getPercent()
            if percent == 0 then return end --已经是最小的了
            if self.cur_selected_sum == 0 then return end
            self.cur_selected_sum = self.cur_selected_sum - 1
            self:setCurUseItemInfoByNum(self.cur_selected_sum)
        end
    end)
    self.add_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            if self.item_vo == nil then return end
            local percent = self.slider:getPercent()
            if percent == 100 then return end --已经是最大的了
            if self.cur_selected_sum >= self.item_vo.quantity then return end
            self.cur_selected_sum = self.cur_selected_sum + 1
            self:setCurUseItemInfoByNum(self.cur_selected_sum)
        end
    end)
    self.max_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            if self.item_vo == nil then return end
            local percent = self.slider:getPercent()
            if percent == 100 then return end --已经是最大的了
            if self.cur_selected_sum >= self.item_vo.quantity then return end
            self.cur_selected_sum = self.item_vo.quantity
            self:setCurUseItemInfoByNum(self.cur_selected_sum)
        end
    end)
end

function BackPackBatchView:openRootWnd(item, type,select_vo)
    self.type = type or ItemConsumeType.use
    self.item_vo = item
    self.select_goods = select_vo
    if self.item_vo == nil or self.item_vo.config == nil then
        self.ctrl:openBatchUseItemView(false)
        return
    end
    if self.type == ItemConsumeType.use then
        self.title_label:setString(TI18N("批量使用")) 
        self.use_title:setString(TI18N("使用数量：")) 
        self.use_btn:setTitleText(TI18N("使用")) 
        self:updateItem()
    elseif self.type == ItemConsumeType.resolve then
        self.title_label:setString(TI18N("批量分解")) 
        self.use_title:setString(TI18N("分解数量：")) 
        self.use_btn:setTitleText(TI18N("分解")) 
        self:updateCellItem()
    else
        self.title_label:setString(TI18N("物品出售")) 
        self.use_title:setString(TI18N("出售数量：")) 
        self.use_btn:setTitleText(TI18N("出售")) 
        self:updateCellItem()
    end
    
end

--==============================--
--desc:针对出售类物品的处理
--time:2018-04-14 06:11:53
--@return 
--==============================--
function BackPackBatchView:updateCellItem()
    if self.item_vo == nil or self.item_vo.config == nil then return end
    self.item:setData(self.item_vo.config)
    self.item_name:setString(self.item_vo.config.name)
    self.item_own:setString(string.format(TI18N("拥有 %s 个"), self.item_vo.quantity))
    self.cur_selected_sum = self.item_vo.quantity
    -- 打开面板的时候,都是默认选中最大数量
    self.value:setString(self.item_vo.quantity)
    -- 设置最大
    self.slider:setPercent(100) 
    local value = self.item_vo.config.value
    if value ~= nil and next(value) ~= nil then     -- 只取第一个
        self.value_config = value[1]
        if self.value_config == nil or self.value_config[1] == nil or type(self.value_config[1]) ~= "number" then return end
       
        local base_id = self.value_config[1]
        local own = 0
        local item_config = Config.ItemData.data_get_data(base_id)
        if item_config == nil then return end
        if self.value_config[1] == Config.ItemData.data_assets_label2id.coin then
            own = self.role_vo.coin 
        elseif self.value_config[1] == Config.ItemData.data_assets_label2id.hero_soul then
            own = self.role_vo.hero_soul 
        end
        
        self:setCurUseItemInfoByPercent(100) 
    end
    if self.select_goods and self.select_goods.type and self.select_goods.type == 1 then 
        self.value_config = self.select_goods.value_list or {}
        self:setCurUseItemInfoByPercent(100) 
    end
end

function BackPackBatchView:updateItem()
    if self.item_vo == nil or self.item_vo.config == nil then return end
    self.item:setData(self.item_vo.config)
    self.item_name:setString(self.item_vo.config.name)
    self.item_own:setString(string.format( TI18N("拥有 %s 个"), self.item_vo.quantity ))
    self.cur_selected_sum = self.item_vo.quantity
    -- 打开面板的时候,都是默认选中最大数量
    self.value:setString(self.item_vo.quantity)
     -- 设置最大
    self.slider:setPercent(100)
    -- 如果是产出资产类的
    if self:isAssetsItem(self.item_vo.config) == true then
        self.container:setPositionY(self.container_y)
        self.extend_container:setVisible(true)
        -- 直接取第一个效果吧
        if self.item_vo.config.effect and next(self.item_vo.config.effect) ~= nil then
            local effect = self.item_vo.config.effect[1]
            if effect ~= nil and self.role_vo ~= nil then
                local own = 0
                if effect.effect_type == BackPackConst.item_effect_type.GOLD then
                    own = self.role_vo.gold
                elseif effect.effect_type == BackPackConst.item_effect_type.COIN then
                    own = self.role_vo.coin
                elseif effect.effect_type == BackPackConst.item_effect_type.PARTNER_EXP then
                    own = self.role_vo.partner_exp_all
                end
            end
        end 
        self:setCurUseItemInfoByPercent(100)
    else
        self.container:setPositionY(self.handle_container_cy)
        self.extend_container:setVisible(false)  
    end
end

--==============================--
--desc:设置当前进度的相关数据
--time:2017-07-05 05:01:59
--@percent:
--@return 
--==============================--
function BackPackBatchView:setCurUseItemInfoByPercent(percent)
    if self.item_vo == nil then return end
    self.cur_selected_sum = math.max(1, math.floor( percent * self.item_vo.quantity * 0.01 ))
    self:setUseInfo(self.cur_selected_sum)
end

function BackPackBatchView:setCurUseItemInfoByNum(num)
    if self.item_vo == nil then return end
    self.cur_selected_sum = math.max(1, num)
    local all_num =math.max(1,self.item_vo.quantity-1)
    local percent = (self.cur_selected_sum-1) / all_num  * 100
    self.slider:setPercent(percent)
    self:setUseInfo(self.cur_selected_sum)
end

function BackPackBatchView:setUseInfo(sum)
    sum = math.min(self.item_vo.quantity,sum)
    self.value:setString(sum)
    if self.type == ItemConsumeType.sell and self.value_config ~= nil then
        local base_value = self.value_config[2] or 0
        local base_id = self.value_config[1]
        if base_id == nil then return end
        local item_config = Config.ItemData.data_get_data(base_id)
        if item_config == nil then return end 
        self.use_item_title:setString(string.format(TI18N("出售后可获得%s："), item_config.name))
        self.use_effect:setString(base_value * sum) 
        self.use_effect:setPositionX(self.use_item_title:getContentSize().width + self.use_item_title:getPositionX()) 
    elseif self.type == ItemConsumeType.resolve and self.value_config ~= nil then
        local base_value = self.value_config[2] or 0
        local base_id = self.value_config[1]
        if base_id == nil then return end
        local item_config = Config.ItemData.data_get_data(base_id)
        if item_config == nil then return end 
        self.use_item_title:setString(string.format(TI18N("分解后可获得%s："), item_config.name))
        self.use_effect:setString(base_value * sum) 
        self.use_effect:setPositionX(self.use_item_title:getContentSize().width + self.use_item_title:getPositionX()) 
    else
        if self.item_vo == nil or self.item_vo.config == nil or self.item_vo.config.effect == nil or next(self.item_vo.config.effect) == nil then return end 
        if self:isAssetsItem(self.item_vo.config) == false then return end
        local effect = self.item_vo.config.effect[1]
        if effect ~= nil then
            self.use_item_title:setString(string.format(TI18N("使用后可获得%s："), Config.ItemData.data_item_effect_type[effect.effect_type]))
            self.use_effect:setString(effect.val * sum)
            self.use_effect:setPositionX(self.use_item_title:getContentSize().width + self.use_item_title:getPositionX()) 
        end
    end
end

--==============================--
--desc:是否是财产类的物品
--time:2017-07-05 04:44:03
--@return 
--==============================--
function BackPackBatchView:isAssetsItem(config)
    if config == nil then 
        return false 
    end
    if config.effect == nil or next(config.effect) == nil then 
        return false
    end
    local is_assets = false
    for i,v in ipairs(config.effect) do
        if v.effect_type == BackPackConst.item_effect_type.GOLD or
           v.effect_type == BackPackConst.item_effect_type.COIN or
           v.effect_type == BackPackConst.item_effect_type.PARTNER_EXP then
           is_assets = true
           break
        end
    end
    return is_assets
end

function BackPackBatchView:close_callback()
    self.ctrl:openBatchUseItemView(false)
end
