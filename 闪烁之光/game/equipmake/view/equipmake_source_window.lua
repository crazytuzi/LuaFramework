-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      橙装合成的碎片来源
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EquipmakeSourcesWindow = EquipmakeSourcesWindow or BaseClass(BaseView)

local table_insert = table.insert
local table_remove = table.remove
local controller = EquipmakeController:getInstance()
local backpack_model = BackpackController:getInstance():getModel()

function EquipmakeSourcesWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.is_full_screen = false
	self.layout_name = "equipmake/equipmake_source_window"
	self.cur_type = 0
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("equipmake", "equipmake"), type = ResourcesType.plist}
	}
end 

function EquipmakeSourcesWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale(self.root_wnd))

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    container:getChildByName("win_title"):setString(TI18N("获取途径"))
    container:getChildByName("title_1"):setString(TI18N("熔炼橙装")) 
    container:getChildByName("title_2"):setString(TI18N("获取途径")) 

    self.close_btn = container:getChildByName("close_btn")

    self.list_view_1 = container:getChildByName("list_view_1")
    self.list_view_2 = container:getChildByName("list_view_2")

    self.list_item_1 = container:getChildByName("list_item_1")  -- item_name item_lev item_get_result confirm_btn(label)
    self.list_item_2 = container:getChildByName("list_item_2")  -- item_name notice_img confirm_btn

    self.empty_tips = container:getChildByName("empty_tips")
    self.empty_tips:getChildByName("desc"):setString(TI18N("暂无橙装可熔炼"))

    self.container = container
end

function EquipmakeSourcesWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openEquipmakeSourcesWindow(false)
        end
    end) 
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openEquipmakeSourcesWindow(false)
        end
    end)
    if self.sell_goods_event == nil then
        self.sell_goods_event  = GlobalEvent:getInstance():Bind(BackpackEvent.Sell_Goods_Success, function() 
            self:createEquipListSources()
        end)
    end
end

function EquipmakeSourcesWindow:openRootWnd()
    self:createEquipListSources()
    self:createItemListSources()
end

function EquipmakeSourcesWindow:createEquipListSources()
    local equip_list = backpack_model:getBagGoldEquipList()
    if equip_list == nil or next(equip_list) == nil then
        self.empty_tips:setVisible(true)
        if self.equip_list_sources then
            self.equip_list_sources:setVisible(false)
        end
    else
        if self.equip_list_sources == nil then
            local size = self.list_view_1:getContentSize()
            local setting = {
                item_class = EquipmakeSourcesEquipList,
                start_x = 4,
                space_x = 4,
                start_y = 0,
                space_y = - 3,
                item_width = 554,
                item_height = 116,
                row = 0,
                col = 1,
                need_dynamic = true
            }
            self.equip_list_sources = CommonScrollViewLayout.new(self.list_view_1, cc.p(0, 0), nil, nil, cc.size(size.width, size.height), setting) 
        end
        self.empty_tips:setVisible(false)
        self.equip_list_sources:setVisible(true)
        self.equip_list_sources:setData(equip_list, nil, nil, self.list_item_1)
    end
end

function EquipmakeSourcesWindow:createItemListSources()
    local config = Config.PartnerEqmData.data_partner_const.boss_point
    if config == nil then return end
    local item_config = Config.ItemData.data_get_data(config.val)
    if item_config == nil or item_config.source == nil or next(item_config.source) == nil then return end
    local sources_list = {}
    for i,v in ipairs(item_config.source) do
        if v[1] and v[2] then
            table.insert(sources_list, {id=v[1], notice=(v[2]==TRUE)})
        end
    end

    if self.item_list_sources == nil then
        local size = self.list_view_2:getContentSize()
        local setting = {
            item_class = EquipmakeSourcesItemList,
            start_x = 4,
            space_x = 4,
            start_y = 0,
            space_y = - 3,
            item_width = 554,
            item_height = 80,
            row = 0,
            col = 1,
            need_dynamic = true
        }
        self.item_list_sources = CommonScrollViewLayout.new(self.list_view_2, cc.p(0, 0), nil, nil, cc.size(size.width, size.height), setting) 
    end
    self.item_list_sources:setData(sources_list, nil, nil, self.list_item_2)
end

function EquipmakeSourcesWindow:close_callback()
    if self.equip_list_sources then
        self.equip_list_sources:DeleteMe()
        self.equip_list_sources = nil
    end
    if self.item_list_sources then
        self.item_list_sources:DeleteMe()
        self.item_list_sources = nil
    end
    if self.sell_goods_event then
        GlobalEvent:getInstance():UnBind(self.sell_goods_event)
        self.sell_goods_event = nil
    end
    controller:openEquipmakeSourcesWindow(true) 
end



-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      橙装碎片的橙装分解来源item
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EquipmakeSourcesEquipList = class("EquipmakeSourcesEquipList ", function()
	return ccui.Layout:create()
end)

function EquipmakeSourcesEquipList:ctor()
end

--==============================--
--desc:设置扩展参数
--time:2018-07-16 09:40:01
--@data:
--@return 
--==============================--
function EquipmakeSourcesEquipList:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)
		
		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
		self:addChild(self.root_wnd)

        self.item_name = self.root_wnd:getChildByName("item_name")
        self.item_lev = self.root_wnd:getChildByName("item_lev") 
        self.item_get_result = self.root_wnd:getChildByName("item_get_result") 
        self.confirm_btn = self.root_wnd:getChildByName("confirm_btn") 
        self.confirm_btn_label = self.confirm_btn:getChildByName("label") 
        self.confirm_btn_label:setString(TI18N("熔炼"))

        self.item = BackPackItem.new(false, true, false, 0.75, false, true) 
        self.item:setPosition(54, 58)
        self.root_wnd:addChild(self.item)

		self:registerEvent()
	end
end

function EquipmakeSourcesEquipList:registerEvent()
	self.confirm_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data then
				self:checkToSellItems()
			end
		end
	end)
end

--==============================--
--desc:熔炼装备
--time:2018-07-26 08:12:36
--@return 
--==============================--
function EquipmakeSourcesEquipList:checkToSellItems()
    local item_list = {self.data}
    BackpackController:getInstance():openSellWindow(true, BackPackConst.Bag_Code.EQUIPS, item_list) 
end

function EquipmakeSourcesEquipList:setData(data)
	if data then
        self.data = data
        self.item:setData(data)

        if self.data.config then
            local color = BackPackConst.quality_color[self.data.config.quality]
            color = color or Config.ColorData.data_color4[175] 
            self.item_name:setTextColor(color)
            self.item_name:setString(self.data.config.name)
            self.item_lev:setString(string.format(TI18N("%s级"), self.data.config.lev))
            self:setSellShowInfo()
        end
	end
end

function EquipmakeSourcesEquipList:setSellShowInfo()
    if self.data == nil or self.data.config == nil then return end
    local base_config = Config.PartnerEqmData.data_partner_const.boss_point
    if base_config == nil then return end
    local item_config = Config.ItemData.data_get_data(base_config.val) 
    if item_config == nil then return end

    local sum = 0
    for i,v in ipairs(self.data.config.value) do
        if v[1] == base_config.val then
            sum = sum + v[2]
        end
    end

    -- 如果是装备，则还需要判断他的精炼附加
    if self.data.enchant and self.data.enchant ~= 0 then
        local config = Config.PartnerEqmData.data_partner_eqm(getNorKey(self.data.config.type, self.data.enchant))
        if config ~= nil and config.sell ~= nil and next(config.sell) ~= nil then
            for i, value in ipairs(config.sell) do
                if value[1] == base_config.val then
                    sum = sum + value[2] * self.data.quantity 
                end
            end
        end
    end 
    self.item_get_result:setString(string.format("熔炼获得:%s%s", item_config.name, sum)) 
end

function EquipmakeSourcesEquipList:DeleteMe()
    if self.item then
        self.item:DeleteMe()
        self.item = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end 


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--     橙装碎片来源
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EquipmakeSourcesItemList = class("EquipmakeSourcesItemList ", function()
	return ccui.Layout:create()
end)

function EquipmakeSourcesItemList:ctor()
end

--==============================--
--desc:设置扩展参数
--time:2018-07-16 09:40:01
--@data:
--@return 
--==============================--
function EquipmakeSourcesItemList:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)
		
		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5)
		self:addChild(self.root_wnd)

		self.item_name = self.root_wnd:getChildByName("item_name")
		self.notice_img = self.root_wnd:getChildByName("notice_img")
		self.confirm_btn = self.root_wnd:getChildByName("confirm_btn")
		
		self:registerEvent()
	end
end

function EquipmakeSourcesItemList:registerEvent()
	self.confirm_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            if self.data then
                BackpackController:getInstance():gotoItemSources(self.data.evt_type, self.data.extend ) 
            end
		end
	end)
end

function EquipmakeSourcesItemList:setData(data)
	if data and data.id then
		self.data = Config.SourceData.data_source_data[data.id] 
        if self.data then
            self.item_name:setString(self.data.name)
        end
        self.notice_img:setVisible(data.notice==true)
	end
end

function EquipmakeSourcesItemList:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 