--****************
-- 难度选择
--****************
ModeChooseWindow = ModeChooseWindow or BaseClass(BaseView)

local controller = HeroExpeditController:getInstance()
function ModeChooseWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "heroexpedit/mode_choose"
end
function ModeChooseWindow:open_callback()
	self.mode_bg = self.root_wnd:getChildByName("bg")
	self.mode_bg:setScale(display.getMaxScale())
	
	local main_container = self.root_wnd:getChildByName("main_container")
	main_container:getChildByName("Text_1"):setString(TI18N("选择难度后，本轮远征无法更改难度"))
	main_container:getChildByName("Image_6"):getChildByName("Text_7"):setString(TI18N("难度选择"))
	local item_cons = main_container:getChildByName("item_cons")
	local scroll_view_size = item_cons:getContentSize()
    local setting = {
        item_class = ModeChooseItem,      -- 单元类
        start_x = 5,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 602,               -- 单元的尺寸width
        item_height = 170,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(item_cons, cc.p(0,0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
    self.item_scrollview:setClickEnabled(false)
end
function ModeChooseWindow:openRootWnd()
	local sign_reward_data = Config.ExpeditionData.data_sign_reward
	if self.item_scrollview then
		self.item_scrollview:setData(sign_reward_data)
	end
end
function ModeChooseWindow:register_event()
	registerButtonEventListener(self.mode_bg, function()
		controller:openModeChooseView(false)
		controller:openHeroExpeditView(false)
    end,false, 2)
end
function ModeChooseWindow:close_callback()
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
	end
	self.item_scrollview = nil
	controller:openModeChooseView(false)
end

------------------------------------------
-- 子项
ModeChooseItem = class("ModeChooseItem", function()
    return ccui.Widget:create()
end)

local table_insert = table.insert
local string_format = string.format
local sign_info = Config.ExpeditionData.data_sign_info
local const_data = Config.ExpeditionData.data_const
function ModeChooseItem:ctor()
	self:configUI()
	self:register_event()
end

function ModeChooseItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("heroexpedit/mode_choose_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(602,170))

    local main_container = self.root_wnd:getChildByName("main_container")
    self.item_bg = main_container:getChildByName("item_bg")
    self.btn_choose = main_container:getChildByName("btn_choose")
    self.btn_choose:setVisible(false)
    self.btn_clear = main_container:getChildByName("btn_clear")
    self.btn_clear:setVisible(false)
    self.open_desc = main_container:getChildByName("open_desc")
    self.open_desc:setString("")
    self.open_desc:setVisible(false)
    self.power_bg = main_container:getChildByName("power_bg")
    self.power_bg:setVisible(false)
    self.fight_label = self.power_bg:getChildByName("power_text")

    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 22,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
        scale = 0.7
    }
    self.award_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.award_scrollview:setSwallowTouches(false)
    self.award_scrollview:setClickEnabled(false)
    self.main_container = main_container

    self.touch_event = false
end
function ModeChooseItem:register_event()
	registerButtonEventListener(self.btn_choose, function()
        if self.data then
            controller:sender24412(self.data.id)
        end
    end,true, 1)
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
                self:setTouchTips()
            end
        end
    end)
end
function ModeChooseItem:setTouchTips()
    if self.data then
        if self.data.id == 1 then
        else
            local max_differ = controller:getMaxDifficulty()
            local role_vo = RoleController:getInstance():getRoleVo()                      
            if max_differ == 0 then
                message(TI18N("全部通关上一难度后开启"))
            elseif max_differ == 1 then
                if self.data.id == 2 then
                    if role_vo.max_power < self.data.power then
                        message(TI18N("战力达到要求后开启"))
                    end
                else
                    message(TI18N("全部通关上一难度后开启"))
                end
            elseif max_differ == 2 then
                if self.data.id == 3 then
                    if role_vo.max_power < self.data.power then
                        message(TI18N("战力达到要求后开启"))
                    end
                end
            end
        end
    end
end
function ModeChooseItem:setData(data)
	if not data then return end
	self.data = data
	local bg_res = PathTool.getPlistImgForDownLoad("heroexpedit/banner",data.desc)
	self.bg_load = loadSpriteTextureFromCDN(self.item_bg, bg_res, ResourcesType.single, self.bg_load)
	
    local role_vo = RoleController:getInstance():getRoleVo()
    
    if data.id == 1 then
        self.btn_choose:setVisible(true)
        self.power_bg:setVisible(false)
    else
        local max = {2,3,4}
        local max_differ = controller:getMaxDifficulty()
        self.fight_label:setString(MoneyTool.GetMoneyString(data.power))
        if role_vo.max_power >= data.power then
            if max[max_differ] then
                if data.id <= max[max_differ] then
                    self.open_desc:setVisible(false)
                    self.btn_choose:setVisible(true)
                    self.power_bg:setVisible(false)
                else
                    self.btn_choose:setVisible(false)
                    self.power_bg:setVisible(true)
                    self.open_desc:setVisible(true)
                end
            else
                self.open_desc:setVisible(true)
                self.power_bg:setVisible(true)
            end
        else
            self.btn_choose:setVisible(false)
            self.power_bg:setVisible(true)
            self.open_desc:setVisible(true)
        end
    end
    
    local str = ""
    if data.id == 2 then
        str = string_format(TI18N("通关普通模式后开启"))
    elseif data.id == 3 then
        str = string_format(TI18N("通关困难模式后开启"))
    end
    self.open_desc:setString(str)

	local item_list = {}
	for k,v in pairs(data.items) do
        local vo = {}
        vo.bid = v[1]
        vo.quantity = v[2]
        table_insert(item_list, vo)
    end
    self.award_scrollview:setData(item_list)
    self.award_scrollview:addEndCallBack(function()
        local list = self.award_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
        end
    end)
end

function ModeChooseItem:DeleteMe()
	if self.award_scrollview then
		self.award_scrollview:DeleteMe()
	end
	self.award_scrollview = nil
	if self.bg_load then 
        self.bg_load:DeleteMe()
        self.bg_load = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end
