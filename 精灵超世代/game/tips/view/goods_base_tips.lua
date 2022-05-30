-- User: lfl
-- Date: 2015/2/3
-- Time: 16:05
-- [[文件功能：物品的基础tips部分，用于给物品tips的继承]]
GoodsBaseTips = GoodsBaseTips or BaseClass(CommonUI)
function GoodsBaseTips:__init()
	self.WIDTH = 418  --界面的宽度
	self.title_space = 30--标题偏移量
	self.space_x = 28 --偏移量
	self.arrow_x = 275 -- 对比图表的位置
end


--[[设置物品的数据vo
-- @param vo     数据vo部分
-- ]]
function GoodsBaseTips:setDataVo(vo, is_tabBar, get_num, is_pack_num,partner_id)
	self.vo = vo
	self.goods_vo = goods_vo
	self.partner_id = partner_id
	self:initMainView(vo, is_tabBar, get_num, is_pack_num)
end

function GoodsBaseTips:initMainView(vo, is_tabBar, get_num, is_pack_num)
	
	self:clearMainContainer()
	--创建背景
	self:createBackground()
	--设置描述部分
	self:setDescription(vo)
	--显示基础信息
	self:setBaseMessage(vo, get_num, is_pack_num)
	--设置标题
	self:setTitle()
	--全局调整位置
	self:adjustPosition()
end


--描述
function GoodsBaseTips:setDescription(vo)
	local height = 0
	self.descript_container = ccui.Widget:create()
	self.descript_container:setContentSize(cc.size(self.WIDTH, height))
	self.descript_container:setAnchorPoint(cc.p(0, 0))
	self:getMainContainer():addChild(self.descript_container)
	local item_bid = vo.base_id
	local config, desc = nil, ""
	config = Config.ItemData.data_get_data(item_bid)
	desc = config.desc
	if config == nil then return end
	
	--一般描述
	self.change_desc_label = createRichLabel(20, Config.ColorData.data_color4[27], cc.p(0, 0), cc.p(self.space_x, 62), nil, nil, 350)
	self.change_desc_label:setString(desc)
	--self.change_desc_label:setMaxWidth(350)
	self.descript_container:addChild(self.change_desc_label)
	if self.change_desc_label:getContentSize().height > 0 then
		height = height + self.change_desc_label:getContentSize().height + 2 + 14
		--self.change_desc_label:setPositionY(height)
	end
	
	--有内容的才显示这个
	if height > 0 then
		height = height + 70
	end
	self.descript_container:setContentSize(cc.size(self.WIDTH, height))
end



--显示基础信息
function GoodsBaseTips:setBaseMessage(vo, get_num, is_pack_num)
	local height = 0
	self.msg_container = ccui.Widget:create()
	self.msg_container:setContentSize(cc.size(self.WIDTH, height))
	self.msg_container:setAnchorPoint(cc.p(0, 0))
	self:getMainContainer():addChild(self.msg_container)
	local item_bid = vo.base_id
	local goods_item = BackPackItem.new(false, false, false, 1, false) 
	goods_item:setPosition(30, - 1)
	goods_item:setBaseData(item_bid)
	self.msg_container:addChild(goods_item)

	local offsetX = 147
	local config = Config.ItemData.data_get_data(item_bid)
	local _y = 95
	--名字
	local temp_label = self:createLabel(24, 3, offsetX, _y)
	temp_label:setString(config.name)
	temp_label:setTextColor(BackPackConst.quality_color[config.quality])
	self.msg_container:addChild(temp_label)
	
	local bg = createScale9Sprite(PathTool.getResFrame("common", "common_1016"), 10, _y - 112)
	bg:setContentSize(cc.size(self.WIDTH - 20, 2))
	bg:setAnchorPoint(cc.p(0, 0))
	self.msg_container:addChild(bg, - 1)
	
	if get_num then --表示可以领取的个数
		local get_num_label = self:createLabel(22, 5, temp_label:getPositionX() + temp_label:getContentSize().width + 5, _y)
		get_num_label:setString(string.format("X%s", get_num))
		get_num_label:setTextColor(BackPackConst.quality_color[config.quality + 1])
		self.msg_container:addChild(get_num_label)
	end
	
	_y = _y - 5
	local is_time = false
	
	_y = _y - 29
	--end
	if not CommonGoodsType.isAsset(item_bid) then
		--数量
		temp_label = self:createLabel(20, 27, offsetX, _y-3)
		temp_label:setString(TI18N("拥有："))
		self.msg_container:addChild(temp_label)
		self.own_label = temp_label
		
		--先判断物品是什么类型
		local num = 0
		local backpack_type = vo.type or 1
		if backpack_type ~= BackPackConst.item_type.REFINE then
			num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(item_bid)
		else 
			num = BackpackController:getInstance():getModel():getPackItemNumByBid(BackPackConst.Bag_Code.EQUIP_REFINE,item_bid) or 0
		end
		local num_label = self:createLabel(20, 27, temp_label:getPositionX() + temp_label:getContentSize().width, temp_label:getPositionY())
		num_label:setString(num)
		self.msg_container:addChild(num_label)
		self.num_label = num_label
		--
		temp_label = self:createLabel(20, 27, num_label:getPositionX() + num_label:getContentSize().width, num_label:getPositionY())
		temp_label:setString(TI18N("个"))
		self.msg_container:addChild(temp_label)
		self.own_val_label = temp_label
		
		
	end

    temp_label = self:createLabel(20, 27, offsetX, 25)
    local name = Config.ItemData.data_item_type[config.type] or config.type
    temp_label:setString(name)
    self.msg_container:addChild(temp_label)
    self.type_label = temp_label
	
	height = height + 110
	self.msg_container:setContentSize(cc.size(self.WIDTH, height))
end

function GoodsBaseTips:updateItemType(item_type)
	if not item_type  or not self.type_label then return end
	item_type  = item_type or 1
	local name = Config.ItemData.data_item_type[item_type] or item_type
    self.type_label:setString(name)
end

--更新拥有数量
function GoodsBaseTips:updateGoodsNum(vo)
	local num = 0
	local backpack_type = vo.type or 1
	if self.is_pack_num and backpack_type ~= BackPackConst.item_type.REFINE then
		num = BackpackController:getInstance():getData():getBackPackItemNumByBid(vo.bid)
	else
		num = vo.quantity
	end
	if self.num_label and self.own_val_label then
		self.num_label:setString(num)
		self.own_val_label:setPositionX(self.num_label:getPositionX() + self.num_label:getContentSize().width)
	end
end


function GoodsBaseTips:richtext(msg, color, size)
	local m = msg or ""
	local c = tranformC3bTostr(color)
	local s = size or 26
	local text = string.format("<div fontsize=%s fontcolor=%s>%s</div>", s, c, m)
	return text
end

--标题部分
function GoodsBaseTips:setTitle()
	--容器
	self.title_widget = ccui.Widget:create()
	self.title_widget:setAnchorPoint(cc.p(0, 0))
	self.title_widget:setContentSize(cc.size(self.WIDTH, 45))
	self:getMainContainer():addChild(self.title_widget)
end


--创建背景
function GoodsBaseTips:createBackground()
	--背景界面
	self.background = createScale9Sprite(PathTool.getResFrame("common", "common_1034"), 0, 0)
	self.background:setContentSize(cc.size(self.WIDTH, 269))
	self.background:setAnchorPoint(cc.p(0, 0))
	self.main_container:addChild(self.background)
end

--创建标题栏
function GoodsBaseTips:createTitleByLabel(parent, label, x, y, color_code, offX)
	local widget = ccui.Widget:create()
	widget:setCascadeOpacityEnabled(true)
	widget:setAnchorPoint(cc.p(0, 0))
	widget:setContentSize(cc.size(self.WIDTH, 20))
	widget:setPosition(cc.p(x, y))
	parent:addChild(widget)
	--标题
	local offsetX = offX or 0
	local title_label = self:createLabel(18,(color_code or 6), self.title_space + offsetX, 10)
	title_label:setAnchorPoint(cc.p(0, 0.5))
	title_label:setString(label)
	widget:addChild(title_label)
	return widget, title_label
end

--提供统一创建文本的地方方便统一管理
function GoodsBaseTips:createLabel(font_size, text_color, x, y)
	local label = createLabel(font_size, Config.ColorData.data_color4[text_color], nil, 0, 0, "", nil, nil, cc.p(0, 1))
	if x and y then
		label:setPosition(cc.p(x, y))
	end
	return label
end

--全局调整位置
function GoodsBaseTips:adjustPosition()
	local height = 30
	self.descript_container:setPositionY(0)
	
	height = height + self.descript_container:getContentSize().height
	self.msg_container:setPositionY(height)
	
	height = height + self.msg_container:getContentSize().height
	self.title_widget:setPositionY(height - self.title_widget:getContentSize().height)
	height = height + 5
	
	--容器的高度
	self:getMainContainer():setContentSize(self.WIDTH, height)
	self.background:setContentSize(cc.size(self.WIDTH, height))
	--超出屏幕判定
	if height > display.height then
		local scale = display.height / height - 0.05
		self:getMainContainer():setScale(scale)
	end
	--居中
	self:getMainContainer():setPosition(cc.p(SCREEN_WIDTH / 2, display.height / 2))
end

--判断物品的使用类型是否有类型type
function GoodsBaseTips:isUseType(uses_type, type)
	if uses_type == type then
		return true
	end
	return false
end


function GoodsBaseTips:adjustTipsSize(btn_height)
	local _height = self:getContentSize().height
	local offset_height = btn_height - _height
	local offset_y = 95
	if offset_height > 0 then
		--容器的高度
		self:getMainContainer():setContentSize(self.WIDTH, btn_height)
		self.background:setContentSize(cc.size(self.WIDTH, btn_height))
		self.descript_container:setPositionY(self.descript_container:getPositionY() + offset_height)
		self.msg_container:setPositionY(self.msg_container:getPositionY() + offset_height)
		self.title_widget:setPositionY(self.title_widget:getPositionY() + offset_height)
	end
end


function GoodsBaseTips:getMainContainer()
	return self.main_container
end

function GoodsBaseTips:setPosition(pos)
	self.main_container:setPosition(pos)
end

function GoodsBaseTips:getContentSize()
	return self:getMainContainer():getContentSize()
end

function GoodsBaseTips:clearMainContainer()
	if self:getMainContainer() then
		self:getMainContainer():removeAllChildren()
	end
end

function GoodsBaseTips:getUseBtn()
	return self.use_btn
end

