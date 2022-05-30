--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-06 15:05:40
-- @description    : 
		-- 圣殿挑战item
---------------------------------
ElementEctypeItem = class("ElementEctypeItem", function()
    return ccui.Widget:create()
end)

local _controller = ElementController:getInstance()
local _model = _controller:getModel()

function ElementEctypeItem:ctor()
	self:configUI()
	self:register_event()
end

function ElementEctypeItem:configUI(  )
	self.size = cc.size(720, 132)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("element/element_ectype_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.sp_first = container:getChildByName("sp_first")
    self.index_txt = container:getChildByName("index_txt")
    self.atk_num = container:getChildByName("atk_num")
    self.desc_txt = container:getChildByName("desc_txt")
    self.sp_lock = container:getChildByName("sp_lock")

    self.btn_challenge = container:getChildByName("btn_challenge")
    local challenge_label = self.btn_challenge:getChildByName("label")
    challenge_label:setString(TI18N("挑战"))
    challenge_label:setTextColor(Config.ColorData.data_color4[1])
    --challenge_label:enableOutline(Config.ColorData.data_color4[264], 2)
    self.btn_sweep = container:getChildByName("btn_sweep")
    local sweep_label = self.btn_sweep:getChildByName("label")
    sweep_label:setString(TI18N("扫荡"))
 	sweep_label:setTextColor(Config.ColorData.data_color4[1])
    --sweep_label:enableOutline(Config.ColorData.data_color4[263], 2)

    local item_list = container:getChildByName("item_list")
    local scroll_view_size = item_list:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.6,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.6,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.6
    }
    self.item_scrollview = CommonScrollViewLayout.new(item_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function ElementEctypeItem:register_event(  )
	-- 挑战
	registerButtonEventListener(self.btn_challenge, function (  )
		local extend_data = {}
		extend_data.ele_type = self.ele_type
		extend_data.customs_id = self.customs_id + 1
		extend_data.limit_desc = self.data.limit_desc
		extend_data.limit = self.data.limit
		local form_type
		if self.ele_type == ElementConst.Ele_Type.Water then
			form_type = PartnerConst.Fun_Form.ElementWater
		elseif self.ele_type == ElementConst.Ele_Type.Fire then
			form_type = PartnerConst.Fun_Form.ElementFire
		elseif self.ele_type == ElementConst.Ele_Type.Wind then
			form_type = PartnerConst.Fun_Form.ElementWind
		elseif self.ele_type == ElementConst.Ele_Type.Light then
			form_type = PartnerConst.Fun_Form.ElementLight
		elseif self.ele_type == ElementConst.Ele_Type.Dark then
			form_type = PartnerConst.Fun_Form.ElementDark
		end
		HeroController:getInstance():openFormGoFightPanel(true, form_type, extend_data)
	end, true)

	-- 扫荡
	registerButtonEventListener(self.btn_sweep, function (  )
		if self.ele_type and self.data then
			_controller:checkSweepHeaven( self.ele_type, self.data.id )
		end
	end, true)
end

function ElementEctypeItem:setExtendData( data )
	self.customs_id = data.customs_id
	self.ele_type = data.ele_type
end

function ElementEctypeItem:setData( data )
	if not data then return end

	self.data = data

	--关卡数
	self.index_txt:setString(data.id)
	--推荐战力
	self.atk_num:setString(string.format(TI18N("战力:%d"),changeBtValueForPower(data.power)))
	-- 上阵条件
	self.desc_txt:setString(data.limit_desc)

	-- 按钮
	local award_list = data.auto_reward
	if data.id <= self.customs_id then
		self.sp_first:setVisible(false)
		self.sp_lock:setVisible(false)
		self.btn_challenge:setVisible(false)
		self.btn_sweep:setVisible(true)
		self.desc_txt:setVisible(false)
	elseif data.id == (self.customs_id + 1) then
		award_list = data.first_reward
		self.sp_first:setVisible(true)
		self.sp_lock:setVisible(false)
		self.btn_challenge:setVisible(true)
		self.btn_sweep:setVisible(false)
		self.desc_txt:setVisible(true)
	else
		award_list = data.first_reward
		self.sp_first:setVisible(true)
		self.sp_lock:setVisible(true)
		self.btn_challenge:setVisible(false)
		self.btn_sweep:setVisible(false)
		self.desc_txt:setVisible(false)
	end

	-- 奖励物品
	local temp_list = {}
    for k,v in pairs(award_list) do
    	local bid = v[1]
    	local num = v[2]
        local item_cfg = deepCopy(Config.ItemData.data_get_data(bid))
        item_cfg.quantity = num
        table.insert(temp_list, item_cfg)
    end
    self.item_scrollview:setData(temp_list)
    self.item_scrollview:addEndCallBack(function (  )
    	local list = self.item_scrollview:getItemList()
    	for k,item in pairs(list) do
            item:setDefaultTip()
        end
    end)
end

function ElementEctypeItem:DeleteMe(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end