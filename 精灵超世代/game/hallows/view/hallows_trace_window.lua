-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      圣印窗体
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
HallowsTraceWindow = HallowsTraceWindow or BaseClass(BaseView)

local controller = HallowsController:getInstance()
local string_format = string.format
local table_insert = table.insert
local backpack_model = BackpackController:getInstance():getModel()

function HallowsTraceWindow:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("hallows", "hallows"), type = ResourcesType.plist},
	}
	self.layout_name = "hallows/hallows_trace_window"
    self.attr_list = {}

    self.cost_config = Config.HallowsData.data_const.id_stone
    self.attr_config = Config.HallowsData.data_const.stone_attribute
    self.this_use_num = 0
end 

function HallowsTraceWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale()) 

    local main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(main_panel, 2)
    main_panel:getChildByName("win_title"):setString(TI18N("球果"))
    main_panel:getChildByName("attr_title"):setString(TI18N("当前属性"))
    main_panel:getChildByName("desc"):setString(TI18N("来源:充值活动"))
 
    self.cost_item = BackPackItem.new(false, true, false, 1, false, true) 
	self.cost_item:setPosition(338, 340)
	main_panel:addChild(self.cost_item)

    self.can_use_label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0.5,0), cc.p(338, 160), nil, nil, 400)
    main_panel:addChild(self.can_use_label)

	self.max_btn = main_panel:getChildByName("max_btn")
    self.plus_btn = main_panel:getChildByName("plus_btn")
	self.min_btn = main_panel:getChildByName("min_btn")
	self.slider = main_panel:getChildByName("slider")-- 滑块
    self.slider:setBarPercent(0, 100)

    self.upgrade_btn = main_panel:getChildByName("upgrade_btn")
    self.upgrade_btn_label = self.upgrade_btn:getChildByName("label")
    self.upgrade_btn_label:setString(TI18N("使用"))
    
    for i=1,2 do
        local attr = main_panel:getChildByName("attr_"..i)
        if attr then
            local object = {}
            object.item = attr
            object.icon = attr:getChildByName("icon")
            object.label = attr:getChildByName("label")
            self.attr_list[i] = object
        end
    end

    self.close_btn = main_panel:getChildByName("close_btn")
end

function HallowsTraceWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openHallowsTraceWindow(false)
		end
	end)
	self.close_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openHallowsTraceWindow(false)
		end
	end)
	self.upgrade_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            if self.data then
                if self.this_use_num == 0 then
                    controller:openHallowsTraceWindow(false)
                else
                    if self.num == 0 then
                        message(TI18N("使用数量不能为0"))
                    else
                        controller:requestUseTraceItem(self.data.id, self.num)
                    end
                end
            end
		end
	end)

	if self.slider ~= nil then
    	self.slider:addEventListener(function ( sender,event_type )
			if event_type == ccui.SliderEventType.percentChanged then
                self:setComposeNumByPercent(self.slider:getPercent())
    		end
    	end)
    end
    self.min_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
        	playButtonSound2()
            local percent = self.slider:getPercent()
            if percent == 0 then return end
            if self.num == 0 then return end
            if self.this_use_num == 0 then return end
            self.num = self.num - 1
            self:setComposeNum(self.num)
        end
    end)
    self.plus_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
        	playButtonSound2()
            local percent = self.slider:getPercent()
            if percent == 100 then return end
            if self.this_use_num == 0 then return end
            if self.num >= self.this_use_num then return end
            self.num = self.num + 1
            self:setComposeNum(self.num)
        end
    end)
    self.max_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
        	playButtonSound2()
            local percent = self.slider:getPercent()
            if percent == 100 then return end --已经是最大的了
            if self.this_use_num == 0 then return end
            self.num = self.this_use_num 
            self:setComposeNum(self.num)
        end
    end) 
end

function HallowsTraceWindow:setComposeNum(num)
    self.num = num
    local percent = 100 * self.num / self.this_use_num
    self.slider:setPercent(percent)
    self:fileNum(num)
end

function HallowsTraceWindow:setComposeNumByPercent(percent)
    self.num = math.floor( percent * self.this_use_num * 0.01 )
    self:fileNum(self.num)
end

function HallowsTraceWindow:fileNum(num)
    if self.had_max_num == nil then return end
    self.cost_item:setNeedNum(num , self.had_max_num)
end

function HallowsTraceWindow:openRootWnd(data)
    self.data = data
    if data and data.vo and self.cost_config then
        self.had_use_num = data.vo.seal             -- 当前使用的数量
        self.use_max_num = self:getUseMaxNum()      -- 当前最高可使用数量

        -- 数据异常
        if self.use_max_num == 0 then return end
        
        local max_step = Config.HallowsData.data_max_lev[self.data.id]
        if max_step == nil then return end

        local step = self.data.vo.step
        -- 没吃满,都显示可以使用的
        if self.had_use_num < self.use_max_num then
            self.can_use_label:setString(string_format(TI18N("当前已使用:%s/%s"), self.had_use_num, self.use_max_num)) 
        else
            if step >= max_step then      -- 已经满级的
                self.can_use_label:setString(string_format(TI18N("已达最大使用数量:%s/%s"), self.had_use_num, self.use_max_num))
            else
                -- 找出下一阶的
                local next_config = Config.HallowsData.data_trace_cost(getNorKey(self.data.id, step+1)) 
                if next_config then
                    self.can_use_label:setString(string_format(TI18N("圣器%s阶可增加使用数量:%s"), step+1, (next_config.num - self.had_use_num) ))
                end
            end
        end

        self.can_use_num = self.use_max_num - self.had_use_num                              -- 当前剩余可使用数量
        if self.can_use_num < 0 then
            self.can_use_num = 0
        end
        -- 当前背包中数量
        self.had_max_num = backpack_model:getBackPackItemNumByBid(self.cost_config.val)     -- 背包中总数量
        self.cost_item:setBaseData(self.cost_config.val, self.had_max_num)
        self.this_use_num = math.min(self.can_use_num, self.had_max_num)                    -- 这次最多可使用的数量
        self.num = self.this_use_num        -- 当前数量
        self:setComposeNum(self.num) 
        self:setBaseAttrList()
    end
end

--==============================--
--desc:设置当前圣印总属性
--time:2018-09-28 10:14:31
--@return 
--==============================--
function HallowsTraceWindow:setBaseAttrList()
    if self.cost_config == nil then return end
    if self.attr_config == nil then return end
    if self.had_use_num == nil then 
        self.had_use_num  = 0
    end

    for i,object in ipairs(self.attr_list) do
        object.item:setVisible(false)
    end

    for i,v in ipairs(self.attr_config.val) do
        local attr_key = v[1]
        local attr_val = v[2] * self.had_use_num
        attr_val = changeBtValueForHeroAttr(attr_val, attr_key)
        local attr_name = Config.AttrData.data_key_to_name[attr_key]
        if attr_name then
            local attr_icon = PathTool.getAttrIconByStr(attr_key)
            local attr_str = string_format(TI18N(" %s +%s"),attr_name, attr_val) 

            local object = self.attr_list[i]
            if object then
                object.item:setVisible(true)
                loadSpriteTexture(object.icon, PathTool.getResFrame("common", attr_icon))
                object.label:setString(attr_str)
            end
        end
    end
end

--==============================--
--desc:返回当前阶数最大可使用的数量的配置表
--time:2018-09-28 09:25:37
--@return 
--==============================--
function HallowsTraceWindow:getUseMaxNum()
    if self.data == nil or self.data.vo == nil then return end
    local trace_cost_config = Config.HallowsData.data_trace_cost(getNorKey(self.data.id, self.data.vo.step))
    if trace_cost_config then
        return trace_cost_config.num
    end
    return 0
end

function HallowsTraceWindow:close_callback()
    if self.cost_item then
        self.cost_item:DeleteMe()
    end
    self.cost_item = nil
    controller:openHallowsTraceWindow(false)
end