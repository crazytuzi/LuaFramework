---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/11/22 10:12:54
-- @description: 公会活跃图标选择界面
---------------------------------
local _controller = GuildController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format
local _txt_color_1 = cc.c4b(36, 144, 3, 255)
local _txt_color_2 = cc.c4b(100, 50, 35, 255)
local _txt_color_3 = cc.c4b(186, 28, 12, 255)

GuildActiveIconWindow = GuildActiveIconWindow or BaseClass(BaseView)

function GuildActiveIconWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "guild/guild_active_icon_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guildactive", "guildactive"), type = ResourcesType.plist},
    }
end

function GuildActiveIconWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)

    container:getChildByName("win_title"):setString(TI18N("选择光环"))

    self.close_btn = container:getChildByName("close_btn")
    self.close_btn:getChildByName("label"):setString(TI18N("取消"))

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("幻化"))

    local item_list = container:getChildByName("item_list")
    local scroll_view_size = item_list:getContentSize()
	local setting = {
        item_class = GuildActiveIconItem,      -- 单元类
        start_x = 5,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 139,               -- 单元的尺寸width
        item_height = 169,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 4,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewLayout.new(item_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function GuildActiveIconWindow:onClickCallBack( item )
    if self.cur_icon_item then
        self.cur_icon_item:setIsSelect(false)
    end
    self.cur_icon_item = item
    self.cur_icon_item:setIsSelect(true)
end

function GuildActiveIconWindow:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
    registerButtonEventListener(self.confirm_btn, handler(self, self.onClickConfirmBtn), true)
end

function GuildActiveIconWindow:onClickCloseBtn(  )
    _controller:openGuildActiveIconWindow(false)
end

function GuildActiveIconWindow:onClickConfirmBtn(  )
    if self.cur_icon_item then
        local icon_id = self.cur_icon_item:getIconId()
        if icon_id then
            SysEnv:getInstance():saveGuildActiveIconId(icon_id)
            GlobalEvent:getInstance():Fire(GuildEvent.UpdateActiveIconEvent, icon_id)
        end
        _controller:openGuildActiveIconWindow(false)
    else
        message(TI18N("请先选择一种光环"))
    end
end

function GuildActiveIconWindow:openRootWnd()
    self:setData()
end

function GuildActiveIconWindow:setData(  )
    self.active_icon_data = {}
    local cur_icon_id = SysEnv:getInstance():loadGuildActiveIconId()
    for icon_id,lev in ipairs(Config.GuildQuestData.data_max_lev) do
        local object = {}
        object.icon_id = icon_id
        object.open_lv = lev
        object.is_chose = (icon_id == cur_icon_id)
        _table_insert(self.active_icon_data, object)
    end
    _table_sort(self.active_icon_data, SortTools.KeyLowerSorter("icon_id"))
    self.item_scrollview:setData(self.active_icon_data, handler(self, self.onClickCallBack))
    self.item_scrollview:addEndCallBack(function (  )
        local item_list = self.item_scrollview:getItemList()
        for k,item in pairs(item_list) do
            if item:getIconId() == cur_icon_id then -- 默认选中幻化中的光环
                self:onClickCallBack(item)
                break
            end
        end
    end)
end

function GuildActiveIconWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    _controller:openGuildActiveIconWindow(false)
end

--------------------------@ item
GuildActiveIconItem = class('GuildActiveIconItem',function()
    return ccui.Layout:create()
end)

function GuildActiveIconItem:ctor()
    self:configUI()
    self:registerEvent()
end

function GuildActiveIconItem:configUI()
    self.size = cc.size(139, 169)
    self:setAnchorPoint(cc.p(0, 0))
    self:setTouchEnabled(false)
    self:setCascadeOpacityEnabled(true)
	self:setContentSize(self.size)
    
    self.container = ccui.Layout:create()
    self.container:setContentSize(self.size)
    self.container:setAnchorPoint(cc.p(0.5, 0.5))
    self.container:setPosition(self.size.width*0.5, self.size.height*0.5)
    self.container:setTouchEnabled(true)
    self.container:setSwallowTouches(false)
    self:addChild(self.container)

    self.icon_bg_sp = createSprite(PathTool.getResFrame("guildactive", "guildactive_1002"), self.size.width*0.5, self.size.height*0.5+15, self.container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    self.icon_sp = createSprite(nil, self.size.width*0.5, self.size.height*0.5+15, self.container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)

    self.state_txt = createLabel(22, 274, nil, self.size.width*0.5, 15, "", self.container, nil, cc.p(0.5, 0.5))
end

function GuildActiveIconItem:registerEvent()
    registerButtonEventListener(self.container, handler(self, self.onClickItem), true)
end

function GuildActiveIconItem:addCallBack( callback )
    self.callback = callback
end

function GuildActiveIconItem:onClickItem(  )
    if not self.data or self.select_status == true then return end
    if self.is_lock == true then
        message(_string_format(TI18N("公会活跃等级达到%s级激活"), self.data.open_lv))
        return
    end
    if self.callback then
        self.callback(self)
    end
end

function GuildActiveIconItem:setData(data)
    if not data then return end

    self.data = data

    -- 图标
    local icon_path = PathTool.getResFrame("guildactive", "guildactive_icon_" .. data.icon_id)
    loadSpriteTexture(self.icon_sp, icon_path, LOADTEXT_TYPE_PLIST)

    -- 是否幻化中
    if data.is_chose == true then
        if not self.chose_shadow then
            self.chose_shadow = ccui.Layout:create()
            self.chose_shadow:setAnchorPoint(cc.p(0.5, 0.5))
            self.chose_shadow:setContentSize(cc.size(139, 139))
            self.chose_shadow:setPosition(self.size.width*0.5, self.size.height*0.5+15)
            showLayoutRect(self.chose_shadow, 120)
            self.container:addChild(self.chose_shadow)
            
            local arrow_sp = createSprite(PathTool.getResFrame("common", "common_1043"), 139*0.5, 139*0.5, self.chose_shadow, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
        end
        self.chose_shadow:setVisible(true)
    elseif self.chose_shadow then
        self.chose_shadow:setVisible(false)
    end

    -- 状态
    self.is_lock = false
    local active_lev = _model:getGuildActiveLev()
    if data.is_chose == true then
        self.state_txt:setString(TI18N("幻化中"))
        self.state_txt:setTextColor(_txt_color_1)
    elseif data.open_lv <= active_lev then
        self.state_txt:setString(TI18N("已激活"))
        self.state_txt:setTextColor(_txt_color_2)
    else
        self.is_lock = true
        self.state_txt:setString(TI18N(data.open_lv .. TI18N("级激活")))
        self.state_txt:setTextColor(_txt_color_3)
    end
    setChildUnEnabled(self.is_lock, self.icon_bg_sp)
    setChildUnEnabled(self.is_lock, self.icon_sp)
end

function GuildActiveIconItem:setIsSelect( status )
    self.select_status = status
    if status == true then
        if not self.select_img then
            self.select_img = createImage(self.container, PathTool.getResFrame("common", "common_90019"), self.size.width*0.5, self.size.height*0.5+15, cc.p(0.5, 0.5), true, 1, true)
            self.select_img:setContentSize(cc.size(149, 149))
        end
        self.select_img:setVisible(true)
    elseif self.select_img then
        self.select_img:setVisible(false)
    end
end

function GuildActiveIconItem:getIconId(  )
    if self.data then
        return self.data.icon_id
    end
end

function GuildActiveIconItem:DeleteMe()
    self:removeAllChildren()
	self:removeFromParent()
end