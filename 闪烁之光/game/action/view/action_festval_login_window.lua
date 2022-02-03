-- --------------------------------------------------------------------
-- @description:
--      节日登录活动面板
-- Create: 2018-09
-- --------------------------------------------------------------------
ActionFestvalLoginWindow = ActionFestvalLoginWindow or BaseClass(BaseView)
local controll = ActionController:getInstance()
local festval_const = Config.FunctionData.data_festval_const

function ActionFestvalLoginWindow:__init( bid )
    self.holiday_bid = bid
    self.is_full_screen = true
    self.win_type = WinType.Big  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "action/action_festval_login_window"    
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("festvallogin","festvallogin"), type = ResourcesType.plist }, 
    }
end

function ActionFestvalLoginWindow:open_callback()
    local bg = self.root_wnd:getChildByName("bg")
    bg:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    local good_cons = self.main_container:getChildByName("good_cons")
    self.close_btn = bg:getChildByName("close_btn")
    self.festvalTime = bg:getChildByName("festval_time")
    self.festvalTime:setString("")

    --默认普通节日状态
    local str = "txt_cn_action_festval_login_bg"
    local return_spr = PathTool.getResFrame("festvallogin","10003")
    if self.holiday_bid == ActionRankCommonType.common_day then --普通节日
        self.festvalTime:setPosition(self.festvalTime:getPositionX() - 185, self.festvalTime:getPositionY() + 64)
    elseif self.holiday_bid == ActionRankCommonType.festval_day then --春节登录
        str = "txt_cn_action_festval_login_bg1"
        return_spr = PathTool.getResFrame("festvallogin","10004")
    elseif self.holiday_bid == ActionRankCommonType.lover_day then --情人节登录
        str = "txt_cn_action_festval_login_bg2"
        return_spr = PathTool.getResFrame("festvallogin","10003")
    end
    local time_data = festval_const[self.holiday_bid]
    if time_data then
        local color = self:colorChangeData(time_data.color)
        self.festvalTime:setColor(color)
        self.festvalTime:setPosition(time_data.pos[1][1],time_data.pos[1][2])
    end

    self.close_btn:loadTexture(return_spr, LOADTEXT_TYPE_PLIST)
    self.close_btn:ignoreContentAdaptWithSize(true)
    self.close_btn:setPositionX(SCREEN_WIDTH-100*display.getMaxScale())
    self.close_btn:setPositionY(SCREEN_HEIGHT-50*display.getMaxScale())
    
    local background = self.root_wnd:getChildByName("background")
    local res = PathTool.getPlistImgForDownLoad("bigbg/action", str)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(background) then
                loadSpriteTexture(background,res,LOADTEXT_TYPE)
                background:setScale(display.getMaxScale())
            end
        end,self.item_load)
    end

	local bgSize = good_cons:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height-8)
    local setting = {
        item_class = ActionFestvalItem,      -- 单元类
        start_x = 8,                  -- 第一个单元的X起点
        space_x = 5,                    -- x方向的间隔
        start_y = 8,                    -- 第一个单元的Y起点
        space_y = 4,                   -- y方向的间隔
        item_width = 679,               -- 单元的尺寸width
        item_height = 172,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end
--颜色转换
function ActionFestvalLoginWindow:colorChangeData(value)
    local r,g,b,a = "ff", "ff", "ff", "ff"
    r = string.sub(value,1,2)
    g = string.sub(value,3,4)
    b = string.sub(value,5,6)
    a = string.sub(value,7,8)
    if r=="" then
        r = "ff"
    end
    if g=="" then
        g = "ff"
    end
    if b=="" then
        b = "ff"
    end
    if a=="" then
        a = "ff"
    end
    return cc.c4b(tonumber("0x"..r), tonumber("0x"..g), tonumber("0x"..b), tonumber("0x"..a))
end

function ActionFestvalLoginWindow:openRootWnd()
	controll:cs16603(self.holiday_bid)
end

function ActionFestvalLoginWindow:register_event()
    registerButtonEventListener(self.close_btn, function()
        controll:openFestvalLoginWindow(false)
    end ,true, 2)

    self:addGlobalEvent(ActionEvent.UPDATE_HOLIDAY_SIGNLE, function(data)
        if data.bid == self.holiday_bid then
            if self.item_scrollview then
                if data.aim_list then
                    controll:getModel():sortItemList(data.aim_list)
                    local special_aim = self:getFirstCanNotReceiveAim(data.aim_list)
                    data.special_aim = special_aim --次日可领的天数
                    self.item_scrollview:setData(data.aim_list,nil,nil,data)

                    if data.args then
                        local time_list = keyfind('args_key', 24, data.args) or nil
                        if time_list then
                            self.festvalTime:setString(time_list.args_str)
                        end
                    end
                end
            end
        end
    end)
end

-- 获取第一个不能领的天数（即为次日可领的天数）
function ActionFestvalLoginWindow:getFirstCanNotReceiveAim( list )
    local aimIndex = 0
    for k,v in ipairs(list) do
        if v.status == 0 then
            aimIndex = v.aim
            break
        end
    end
    return aimIndex
end

function ActionFestvalLoginWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    controll:openFestvalLoginWindow(false)
end

------------------------------------------
-- 节日活动界面子项
ActionFestvalItem = class("ActionFestvalItem", function()
    return ccui.Widget:create()
end)

function ActionFestvalItem:ctor()
	self.ctrl = ActionController:getInstance()

	self:configUI()
	self:register_event()
end

function ActionFestvalItem:configUI(  )
	self.size = cc.size(679,172)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("action/action_festval_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.goods_con = self.main_container:getChildByName("goods_con")
    self.has_bg = self.main_container:getChildByName("has_bg")
    self.tips_label = self.main_container:getChildByName("tips_label")
    self.tips_label:setString(TI18N("未满足条件"))

    self.btn_get = self.main_container:getChildByName("btn_get")
    local btn_label = self.btn_get:getTitleRenderer()
    if btn_label ~= nil then
        btn_label:enableOutline(Config.ColorData.data_color4[278], 2)
    end
    local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 3,                  -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 4,                    -- 第一个单元的Y起点
        space_y = 4,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.85,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.85,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.85,
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
    self.title_txt = createRichLabel(26, 1, cc.p(0, 0.5), cc.p(15, 149))
	self.root_wnd:addChild(self.title_txt)
end

function ActionFestvalItem:setExtendData(data)
    self.extend_data = data
end

function ActionFestvalItem:setData( data )
	self.data = data
    if data.status == 0 then
        if self.extend_data.special_aim and self.extend_data.special_aim == data.aim then
            self.tips_label:setString(TI18N("明日可领"))
            self.tips_label:setTextColor(cc.c3b(40,155,20))
        else
            self.tips_label:setString(TI18N("未满足条件"))
            self.tips_label:setTextColor(cc.c3b(104,69,42))
        end
    end
    self.title_txt:setString(data.aim_str)
    self.tips_label:setVisible(data.status == 0)
	self.btn_get:setVisible(data.status == 1)
	self.has_bg:setVisible(data.status == 2)
	
	local item_list = data.item_list
    local list = {}
    for k, v in pairs(item_list) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.bid))
        vo.quantity = v.num
        table.insert(list, vo)
    end
    self.item_scrollview:setData(list)
    self.item_scrollview:addEndCallBack(function()
        local list = self.item_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
            local data1 = v:getData()
            if data1 and data1.id then
                local bid = data1.id
                local quality = data1.quality
                for a,j in pairs(self.extend_data.item_effect_list) do
                    if bid then
                        if bid == j.bid then
                            if quality >= 4 then
                                v:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
                            else
                                v:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
                            end
                        end
                    end
                end
            end
        end
    end)
end

function ActionFestvalItem:register_event()
    registerButtonEventListener(self.btn_get, function()
        if self.data then
            self.ctrl:cs16604(self.extend_data.bid,self.data.aim)
        end
    end ,true, 1)
end

function ActionFestvalItem:DeleteMe()
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end 
	self:removeAllChildren()
	self:removeFromParent()
end
