--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-02-15 15:42:20
-- @description    : 
		-- buff总览列表
---------------------------------
BattleBuffListView = BattleBuffListView or BaseClass(BaseView)

local _controller = BattleController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

function BattleBuffListView:__init( )
	self.win_type = WinType.Mini
	self.layout_name = "battle/battle_buff_list_view"
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
end

function BattleBuffListView:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)
    self.arrow_sp = self.container:getChildByName("Sprite_2")
    self.arrow_sp:setVisible(false)

    local list_panel = self.container:getChildByName("list_panel")
	local scroll_view_size = list_panel:getContentSize()
    local setting = {
        item_class = BattleBuffListItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 566,               -- 单元的尺寸width
        item_height = 154,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.buff_scrollview = CommonScrollViewLayout.new(list_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.buff_scrollview:setSwallowTouches(false)
end

function BattleBuffListView:register_event(  )
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)
end

function BattleBuffListView:_onClickCloseBtn(  )
	_controller:openBattleBuffListView(false)
end

function BattleBuffListView:openRootWnd( data, group, partner_bid )
	self.group = group
	self.partner_bid = partner_bid
	self:setData(data)
end

function BattleBuffListView:setData( data )
	self.data = data or {}

	local temp_data = {}
	for i,b_info in ipairs(self.data) do
		for _,v in pairs(b_info.buff_infos) do
			local buff_id = v.buff_id
			local remain_round = v.remain_round or b_info.remain_round
			local buff_config = Config.SkillData.data_get_buff[buff_id]
			if buff_config then
				if temp_data[buff_id] == nil then
					temp_data[buff_id] = {res_id=b_info.res_id, num=0, name=buff_config.name, remain_round=remain_round, desc=buff_config.desc, buff_id = buff_id}
				end
				temp_data[buff_id].num = temp_data[buff_id].num + 1
			end
		end
	end
	local buff_data = {}
	for k,v in pairs(temp_data) do
		_table_insert(buff_data, v)
	end
	table.sort(buff_data,function(a,b)
		if a.res_id == b.res_id then
			return a.buff_id < b.buff_id
		else
			return a.res_id < b.res_id
		end
	end)

	self.arrow_sp:setVisible(#buff_data >= 5)

	self.buff_scrollview:setData(buff_data)
	self.buff_scrollview:addEndCallBack(function (  )
        local list = self.buff_scrollview:getItemList()
        for k,item in pairs(list) do
            item:setLineShow(k~=1)
        end
    end)
end

-- 用于每回合更新数据时检测是否为选中的宝可梦buff列表
function BattleBuffListView:checkIsChosedBuffList( group, partner_bid )
	if self.group == group and self.partner_bid == partner_bid then
		return true
	end
	return false
end

function BattleBuffListView:close_callback(  )
	if self.buff_scrollview then
		self.buff_scrollview:DeleteMe()
		self.buff_scrollview = nil
	end
	_controller:openBattleBuffListView(false)
end

-------------------------@ item
BattleBuffListItem = class("BattleBuffListItem", function()
    return ccui.Widget:create()
end)

function BattleBuffListItem:ctor(dir)
	self:configUI()
	self:register_event()
end

function BattleBuffListItem:configUI(  )
	self.size = cc.size(566, 154)
	self:setTouchEnabled(false)
	--self:setAnchorPoint(cc.p(0, 0))
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("battle/battle_buff_list_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.line = self.container:getChildByName("line")
    self.buff_icon = self.container:getChildByName("buff_icon")
    self.name_label = self.container:getChildByName("name_label")
    self.round_label = self.container:getChildByName("round_label")
end

function BattleBuffListItem:register_event(  )
	
end

function BattleBuffListItem:setData( data )
	self.data = data or {}

	-- 图标
	local buff_path = PathTool.getBigBuffRes(data.res_id)
	if buff_path then
		loadSpriteTexture(self.buff_icon, buff_path, LOADTEXT_TYPE)
	end

	-- 名称
	local name_str = "【" .. (data.name or "") .. "】" .. "*" .. (data.num or 1)
	self.name_label:setString(name_str)

	-- 失效回合(大于30回合表示永久，则不显示)
	if not data.remain_round or data.remain_round > 30 then
		self.round_label:setVisible(false)
	else
		self.round_label:setVisible(true)
		self.round_label:setString(string.format(TI18N("%d回合后失效"), data.remain_round))
	end

	-- 描述
	if not self.buff_desc then
		self.buff_desc = createRichLabel(22, cc.c3b(224, 191, 152), cc.p(0, 1), cc.p(33, 85), 5, nil, 500)
		self.container:addChild(self.buff_desc)
	end
	self.buff_desc:setString(data.desc or "")
end

function BattleBuffListItem:setLineShow( status )
	self.line:setVisible(status)
end

function BattleBuffListItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end