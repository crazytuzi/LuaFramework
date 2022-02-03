--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-12 21:42:01
-- @description    : 
		-- 圣物进阶总览
---------------------------------
HalidomStepPreView = HalidomStepPreView or BaseClass(BaseView)

local _controller = HalidomController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

function HalidomStepPreView:__init()
    self.is_full_screen = false
	self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "hero/halidom_step_preview"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("halidom", "halidom"), type = ResourcesType.plist},
	}
end

function HalidomStepPreView:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)

	container:getChildByName("title_label"):setString(TI18N("进阶总览"))

	local item_list = container:getChildByName("item_list")
	local scroll_view_size = item_list:getContentSize()
    local setting = {
        item_class = HalidomStepPreItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 550,               -- 单元的尺寸width
        item_height = 130,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(item_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function HalidomStepPreView:openRootWnd( id )
	self:setData(id)
end

function HalidomStepPreView:setData( id )
	if not id then return end
	local all_step_cfg = Config.HalidomData.data_step[id]
	local base_cfg = Config.HalidomData.data_base[id]
	if not all_step_cfg or not base_cfg then return end

	local halidom_vo = _model:getHalidomDataById(id)

	local show_data = {}
	for k,v in pairs(all_step_cfg) do
		if v.step > 0 then
			local temp_data = deepCopy(v)
			temp_data.halidom_name = base_cfg.name
			if halidom_vo and halidom_vo.step then
				if temp_data.step == halidom_vo.step then
					temp_data.step_status = 1 -- 当前
				elseif temp_data.step > halidom_vo.step then
					temp_data.step_status = 2 -- 解锁
				else
					temp_data.step_status = 0 -- 未解锁
				end
			else
				temp_data.step_status = 0 -- 未解锁
			end
			_table_insert(show_data, temp_data)
		end
	end
	local function sortFunc( objA, objB )
		return objA.step < objB.step
	end
	table.sort(show_data, sortFunc)
	self.item_scrollview:setData(show_data)
end

function HalidomStepPreView:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openHalidomStepPreView(false)
	end, false, 2)
end

function HalidomStepPreView:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	_controller:openHalidomStepPreView(false)
end


------------------------@ item
HalidomStepPreItem = class("HalidomStepPreItem", function()
    return ccui.Widget:create()
end)

function HalidomStepPreItem:ctor()
	self:configUI()
	self:register_event()

	self.attr_txt_list = {}
end

function HalidomStepPreItem:configUI(  )
	self.size = cc.size(550, 130)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("hero/halidom_step_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.cur_bg = container:getChildByName("cur_bg")
    self.dis_bg = container:getChildByName("dis_bg")
    self.name_label = container:getChildByName("name_label")
    self.sp_cur = container:getChildByName("sp_cur")
end

function HalidomStepPreItem:register_event(  )
	
end

function HalidomStepPreItem:setData( data )
	if not data then return end

	self.name_label:setString(_string_format(TI18N("%s%d阶"), data.halidom_name, data.step))

	local txt_color = "e0bf98"
	if data.step_status == 0 then
		self.cur_bg:setVisible(false)
		self.dis_bg:setVisible(true)
		self.sp_cur:setVisible(false)
		txt_color = "e0bf98"
	elseif data.step_status == 1 then
		self.cur_bg:setVisible(true)
		self.dis_bg:setVisible(false)
		self.sp_cur:setVisible(true)
		txt_color = "68c74b"
	else
		self.cur_bg:setVisible(false)
		self.dis_bg:setVisible(true)
		self.sp_cur:setVisible(false)
		txt_color = "7a6c5c"
	end

	local attr_data = {}
	for i,v in ipairs(data.dynamic_attr) do
		_table_insert(attr_data, v)
	end
	for i,v in ipairs(data.fixed_attr) do
		_table_insert(attr_data, v)
	end

	for k,v in pairs(self.attr_txt_list) do
		v:setVisible(false)
	end

	for i,v in ipairs(attr_data) do
		local attr_key = v[1]
        local attr_val = v[2] or 0
        local attr_name = Config.AttrData.data_key_to_name[attr_key]
        if attr_name then
        	local attr_text = self.attr_txt_list[i]
            if attr_text == nil then
                attr_text = createRichLabel(22, 1, cc.p(0, 0.5), cc.p(20, 28), nil, nil, 380)
                self.container:addChild(attr_text)
                self.attr_txt_list[i] = attr_text
            end
            local pos_x = 550/2 + 20
            if i%2 == 1 then
            	pos_x = 20
            end
            local pos_y = 58
            if i > 2 then
            	pos_y = 22
            end
            attr_text:setPosition(cc.p(pos_x, pos_y))
            attr_text:setVisible(true)

            local icon = PathTool.getAttrIconByStr(attr_key)
            local is_per = PartnerCalculate.isShowPerByStr(attr_key)
            if is_per == true then
                attr_val = (attr_val/10) .."%"
            end
            local attr_str = _string_format("<img src='%s' scale=1 /> <div fontcolor=#%s>  圣物%s属性+</div><div fontcolor=#%s>%s</div>", PathTool.getResFrame("common", icon), txt_color, attr_name, txt_color, tostring(attr_val))
            attr_text:setString(attr_str)
        end
	end
end

function HalidomStepPreItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end