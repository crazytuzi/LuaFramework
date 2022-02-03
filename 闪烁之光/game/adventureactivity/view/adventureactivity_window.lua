--****************
--秘境探险主入口
--****************
AdventureActivityWindow = AdventureActivityWindow or BaseClass(BaseView)

local controller = AdventureActivityController:getInstance()

local table_insert = table.insert
function AdventureActivityWindow:__init()
    self.is_full_screen = true
	self.win_type = WinType.Full
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("adventureactivity", "adventureactivity"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_83", true), type = ResourcesType.single}
	}
	self.layout_name = "adventureactivity/adventureactivity_window"
end

function AdventureActivityWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_83",true), LOADTEXT_TYPE)
		self.background:setScale(display.getMaxScale())
	end
	local main_panel = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_panel, 1)
	self.close_btn = main_panel:getChildByName("close_btn")

	local scroll_list = main_panel:getChildByName("scroll_list")
	local scroll_view_size = scroll_list:getContentSize()
    local setting = {
        item_class = AdventureActivityItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 23,                   -- y方向的间隔
        item_width = 687,               -- 单元的尺寸width
        item_height = 214,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(scroll_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function AdventureActivityWindow:openRootWnd()
	if self.item_scrollview then
        local adventure_data = Config.CrossGroundData.data_adventure_activity
        local list = {}
        for k,v in pairs(adventure_data) do
            table.insert(list, v)
        end
        table.sort( list, function(a,b)
            return a.id < b.id
        end )
		self.item_scrollview:setData(list)
	end
end

function AdventureActivityWindow:register_event()
	registerButtonEventListener(self.close_btn, function ()
		controller:openAdventureActivityMainWindow(false)
	end,false, 2)

    --冒险红点
    self:addGlobalEvent(AdventureEvent.UpdateAdventureForm, function()
        self:updateItemListRedStatus()
    end)
    --秘矿冒险红点
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_RECORD_RED_POINT_EVENT,function()
    --     self:updateItemListRedStatus()
    -- end)
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_LOGIN_RED_POINT_EVENT,function()
    --     self:updateItemListRedStatus()
    -- end)
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_BOX_LIST_EVENT,function()
    --     self:updateItemListRedStatus()
    -- end)
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_RECEIVE_BOX_EVENT,function()
    --     self:updateItemListRedStatus()
    -- end)
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_CHALLEAGE_RED_POINT_EVENT,function()
    --     self:updateItemListRedStatus()
    -- end)

    -- 元素圣殿红点
    self:addGlobalEvent(ElementEvent.Update_Element_Red_Status, function (  )
        self:updateItemListRedStatus()
    end)
    -- 天界副本红点
    self:addGlobalEvent(HeavenEvent.Update_Heaven_Red_Status, function (  )
        self:updateItemListRedStatus()
    end)

    -- 冒险20600协议回来
    self:addGlobalEvent(AdventureEvent.Update_Room_Base_Info, function (  )
        self:updateItemListLockInfo()
    end)
end

function AdventureActivityWindow:updateItemListRedStatus()
	if not self.item_scrollview then return end
	local item_list = self.item_scrollview:getItemList()
    if item_list then
        for k,item in pairs(item_list) do
            item:updateRedStatus()
        end
    end
end


function AdventureActivityWindow:updateItemListLockInfo()
    if not self.item_scrollview then return end
    local item_list = self.item_scrollview:getItemList()
    if item_list then
        for k,item in pairs(item_list) do
            item:updateDesc()
        end
    end
end

function AdventureActivityWindow:close_callback()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	controller:openAdventureActivityMainWindow(false)
end

---------------------------------
--子项
---------------------------------
AdventureActivityItem = class("AdventureActivityItem", function()
    return ccui.Widget:create()
end)

function AdventureActivityItem:ctor()
	self:configUI()
	self:register_event()
end

function AdventureActivityItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("adventureactivity/adventureactivity_item"))
    self:setContentSize(cc.size(687, 214))
    self:addChild(self.root_wnd)
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setSwallowTouches(false)
    self.item_bg = self.main_container:getChildByName("item_bg")
    self.open_desc = self.main_container:getChildByName("open_desc")
    self.open_desc:setVisible(false)
    self.open_desc2 = self.main_container:getChildByName("open_desc_2")
    self.open_desc2:setVisible(false)

    self.join_bg = self.main_container:getChildByName("join_bg")
    self.join_desc = self.main_container:getChildByName("join_desc")
    self.join_desc:setString("")
    self.lock_layer = self.main_container:getChildByName("lock_layer")
    self.award_list = self.main_container:getChildByName("award_list")
    self.award_list:setVisible(false)
    local scroll_view_size = self.award_list:getContentSize()
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
        need_dynamic = true,
        scale = 0.7
    }
    self.award_scrollview = CommonScrollViewLayout.new(self.award_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.award_scrollview:setSwallowTouches(false)
end

function AdventureActivityItem:register_event()
	self.main_container:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.began then
			self.touch_began = sender:getTouchBeganPosition()
		elseif event_type == ccui.TouchEventType.ended then
			self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click then
            	playButtonSound2()
    			if self.data then
                    local is_open = AdventureActivityController:getInstance():isOpenActivity(self.data.id)
                    if is_open == true and not self.is_adventure_mine_lock then
                        controller:onClickGotoAdvenTureAcivity(self.data.id)
                    else
                        message(TI18N("暂未满足开启条件"))
                    end
                end
            end
		end
	end)
end

function AdventureActivityItem:setData(data)
	if not data then return end
    self.data = data
    
    -- 引导需要,这里做修改
    if data._index then
        self.main_container:setName("guildadventure_activity_item_"..data._index)
    end

	-- 背景
	local bg_res = PathTool.getPlistImgForDownLoad("bigbg/adventrueactivity", string.format("txt_cn_adventrueactivity_%d", data.res_id))
	self.bg_load = loadImageTextureFromCDN(self.item_bg, bg_res, ResourcesType.single, self.bg_load)
    self.join_desc:setString(data.item_desc)
    local size = self.join_desc:getContentSize()
    if size.width < 250 then
        size.width = 250
    end 
    self.join_bg:setContentSize(cc.size(size.width+60, size.height))
	-- 奖励数据
	local item_list = {}
	for k,v in pairs(data.award) do
        local vo = {}
        vo.id = v[1]
        vo.quantity = v[2]
        table_insert(item_list, vo)
    end
    self.award_scrollview:setData(item_list)
    self.award_scrollview:addEndCallBack(function()
        local list = self.award_scrollview:getItemList()
        local book_id_cfg = Config.DungeonHeavenData.data_const["heaven_handbook"]
        for k,v in pairs(list) do
            local iData = v:getData()
            local is_special
            if self.data.id == AdventureActivityConst.Ground_Type.heaven and book_id_cfg and iData then
                for n,m in pairs(book_id_cfg.val) do
                    if m == iData.id then
                        is_special = 2
                        break
                    end
                end
            end
            v:setDefaultTip(true, nil, nil, is_special)
        end
    end)

    local is_show = self:updateDesc()
    if is_show then
        local is_open = AdventureActivityController:getInstance():isOpenActivity(data.id)
        if is_open == true then
        	self.lock_layer:setVisible(false)
            self.open_desc:setVisible(false)
            self.award_list:setVisible(true)
        else
        	self.lock_layer:setVisible(true)
            self.open_desc:setString(data.desc)
            self.open_desc:setVisible(true)
            if data.desc2 ~= "" then
                self.open_desc2:setString(data.desc2)
                self.open_desc2:setVisible(true)
            end
            self.award_list:setVisible(false)
        end
    end
    
	self:updateRedStatus()
end

--更新提示 针对于 秘矿冒险的
function AdventureActivityItem:updateDesc( )
    if self.data and self.data.id == AdventureActivityConst.Ground_Type.adventure_mine  then
        self.is_adventure_mine_lock = false
        local base_data = AdventureController:getInstance():getUiModel():getAdventureBaseData() 
        if not base_data then return false end
        local is_open = AdventureActivityController:getInstance():isOpenActivity(self.data.id)
        local  pass_id = base_data.pass_id or 1
        local is_have_layer = pass_id >= 10

        local str_list = {}
        if not is_open then
            table_insert(str_list, self.data.desc)
        end

        if not is_have_layer then
           table_insert(str_list, TI18N("通关神界冒险前九层开启")) 
        end

        if next(str_list) == nil then
            self.lock_layer:setVisible(false)
            self.open_desc:setVisible(false)
            self.award_list:setVisible(true)
        else
            self.is_adventure_mine_lock = true
            self.lock_layer:setVisible(true)
            self.award_list:setVisible(false)

            self.open_desc:setString(str_list[1])
            self.open_desc:setVisible(true)
            if str_list[2] then
                self.open_desc2:setString(str_list[2])
                self.open_desc2:setVisible(true)
            end
        end
        return false
    else
        return true
    end
end

-- 红点刷新
function AdventureActivityItem:updateRedStatus()
	if self.data then
		local red_status = false
		if self.data.id == AdventureActivityConst.Ground_Type.adventure then  -- 冒险
            red_status = AdventureController:getInstance():getUiModel():getAdventureRedPoint()
		elseif self.data.id == AdventureActivityConst.Ground_Type.element then -- 元素
            red_status = ElementController:getInstance():getModel():checkElementRedStatus()
        elseif self.data.id == AdventureActivityConst.Ground_Type.heaven then -- 天界副本
            red_status = HeavenController:getInstance():getModel():getHeavenRedStatus()
        elseif self.data.id == AdventureActivityConst.Ground_Type.adventure_mine then --秘矿冒险
            red_status = AdventureController:getInstance():getUiModel():checkRedPoint(true)
		end
        local is_open = AdventureActivityController:getInstance():isOpenActivity(self.data.id)
        if is_open == false then
            red_status = false
        end
		addRedPointToNodeByStatus(self.main_container, red_status, nil, nil, 99, 2)
	end
end

function AdventureActivityItem:DeleteMe()
    if self.bg_load then
        self.bg_load:DeleteMe()
        self.bg_load = nil
    end
	if self.award_scrollview then
		self.award_scrollview:DeleteMe()
		self.award_scrollview = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end
