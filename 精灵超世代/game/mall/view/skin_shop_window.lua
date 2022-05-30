-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      皮肤商店
-- <br/>Create: 2019-11-08
-- --------------------------------------------------------------------
local _controller = MallController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format
local _index_to_camp = {
	[1] = HeroConst.CampType.eNone,  -- 全部
	[2] = HeroConst.CampType.eWater, -- 水
	[3] = HeroConst.CampType.eFire,  -- 火
	[4] = HeroConst.CampType.eWind,  -- 风
	[5] = HeroConst.CampType.eLight, -- 光
	[6] = HeroConst.CampType.eDark   -- 暗
}

SkinShopWindow = SkinShopWindow or BaseClass(BaseView)

function SkinShopWindow:__init()
	self.is_full_screen = true
    self.win_type = WinType.Full    
    self.layout_name = "mall/skin_shop_window" 

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("mall_skin", "mall_skin"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg/mall","skin_bg_1"), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("bigbg/mall","skin_bg_2"), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("bigbg/mall","skin_bg_3"), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("bigbg/mall","txt_cn_skin_banner"), type = ResourcesType.single},
	}

	self.cur_index = 1 -- 当前选中的阵营下标
	self:initAllShopData()
end

function SkinShopWindow:open_callback( )
	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container , 1) 
	self.container_size = self.main_container:getContentSize()
	self.bottom_sp = main_container:getChildByName("bottom_sp")
	self.bottom_image = main_container:getChildByName("bottom_image")
	self.bottom_shadow = main_container:getChildByName("bottom_shadow")
	
	self.top_panel = main_container:getChildByName("top_panel")
	self.scrollCon = self.top_panel:getChildByName("image_bg")--道具背景

	local camp_panel = self.top_panel:getChildByName("camp_panel")
	self.camp_panel = camp_panel
	self.camp_btn_list = {}
	for i = 1, 6 do
		local object = {}
		object.camp_bg_sp = camp_panel:getChildByName("camp_bg_sp_" .. i)
		object.camp_btn = camp_panel:getChildByName("camp_btn_" .. i)
		object.pos_x = object.camp_btn:getPositionX()
		_table_insert(self.camp_btn_list, object)
	end

	self.close_btn = main_container:getChildByName("close_btn")

	self.l_bg = self.top_panel:getChildByName("image_pillar_1")
    self.r_bg = self.top_panel:getChildByName("image_pillar_2")

	self.item_list = self.top_panel:getChildByName("item_list")
	self:adaptationScreen()
	local scroll_view_size = self.item_list:getContentSize()
    local setting = {
        start_x = 13,                  -- 第一个单元的X起点
        space_x = 20,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 50,                   -- y方向的间隔
        item_width = 206,               -- 单元的尺寸width
        item_height = 325,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 3,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.skin_scrollview = CommonScrollViewSingleLayout.new(self.item_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.skin_scrollview:setSwallowTouches(false)

    self.skin_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell)
    self.skin_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells)
    self.skin_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex)
end

--设置适配屏幕
function SkinShopWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.container_size.height - tab_y))

    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(close_btn_y+bottom_y)
    local bottom_bg_y = self.bottom_sp:getPositionY()
    self.bottom_sp:setPositionY(bottom_bg_y+bottom_y)
    local bottom_bg2_y = self.bottom_image:getPositionY()
	self.bottom_image:setPositionY(bottom_bg2_y+bottom_y)
	local bottom_bg3_y = self.bottom_shadow:getPositionY()
    self.bottom_shadow:setPositionY(bottom_bg3_y+bottom_y)
    

    local size = self.scrollCon:getContentSize()
    local height = (top_y - self.container_size.height) - bottom_y
    self.scrollCon:setContentSize(cc.size(size.width, size.height + height))
    local good_cons_size = self.item_list:getContentSize()
    self.item_list:setContentSize(cc.size(good_cons_size.width, good_cons_size.height + height))
    local r_bg_size = self.r_bg:getContentSize()
    self.r_bg:setContentSize(cc.size(r_bg_size.width, r_bg_size.height + height))
    local l_bg_size = self.l_bg:getContentSize()
    self.l_bg:setContentSize(cc.size(l_bg_size.width, l_bg_size.height + height))
end
function SkinShopWindow:createNewCell()
	local cell = SkinShopItem.new()
    return cell
end

function SkinShopWindow:numberOfCells()
	if not self.skin_data then return 0 end
    return #self.skin_data
end

function SkinShopWindow:updateCellByIndex(cell, index)
	if not self.skin_data then return end
    cell.index = index
    local cell_data = self.skin_data[index]
    if not cell_data then return end
	cell:setData(cell_data)
	if index%3 == 1 then
	    cell:createItemBgSprite()
	end
end

function SkinShopWindow:register_event( )
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)

	for i, object in ipairs(self.camp_btn_list) do
		registerButtonEventListener(object.camp_btn, function ()
			self:onClickCampBtn(i)
		end, true)
	end

    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code,temp_list)
        if self.skin_scrollview then
            self.skin_scrollview:resetCurrentItems()
        end
    end)
    -- self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,temp_list)
    --     self:changeTreasureNumber(temp_list)
    -- end)
    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
        if self.skin_scrollview then
            self.skin_scrollview:resetCurrentItems()
        end
    end)
end

-- 初始化配置数据
function SkinShopWindow:initAllShopData()
	-- 按照阵营存数据
	self.all_shop_data = {}
	self.all_camp_data = {}
	for k,config in pairs(Config.ChargeMallData.data_skin_mall) do
		local skin_cfg = Config.PartnerSkinData.data_skin_info[config.skin_id]
		if skin_cfg then
			local partner_cfg = Config.PartnerData.data_partner_base[skin_cfg.bid]
			if partner_cfg then
				if not self.all_shop_data[partner_cfg.camp_type] then
					self.all_shop_data[partner_cfg.camp_type] = {}
				end
				local cfg_object = {}
				cfg_object.mall_cfg = config
				cfg_object.skin_cfg = skin_cfg
				cfg_object.camp_type = partner_cfg.camp_type
				_table_insert(self.all_shop_data[partner_cfg.camp_type], cfg_object)
				_table_insert(self.all_camp_data, cfg_object)
			end
		end
	end
	
	-- 排序
	local function sortFunc( objA, objB )
		if objA.camp_type == objB.camp_type then
			return objA.mall_cfg.sort < objB.mall_cfg.sort
		else
			return objA.camp_type < objB.camp_type
		end
	end
	for k,data_list in pairs(self.all_shop_data) do
		_table_sort(data_list, sortFunc)
	end
	_table_sort(self.all_camp_data, sortFunc)
end

function SkinShopWindow:openRootWnd( )
	self:showLightEffect(true)
	self:onClickCampBtn(1, true)
end

function SkinShopWindow:onClickCampBtn(index, force)
	if not force and self.cur_index == index then return end

	if not self.camp_btn_list or not self.all_shop_data then return end
	local object = self.camp_btn_list[index]
	if not object then return end

	if self.camp_btn_list[self.cur_index] then
		self.camp_btn_list[self.cur_index].camp_bg_sp:setPositionY(50)
		self.camp_btn_list[self.cur_index].camp_btn:setPositionY(51)
	end
	self:showCampEffect(true, object.pos_x)
	object.camp_bg_sp:setPositionY(60)
	object.camp_btn:setPositionY(61)
	self.cur_index = index

	-- 筛选出对应阵营的数据
	local cur_camp_type = _index_to_camp[index]
	if cur_camp_type == HeroConst.CampType.eNone then
		self.skin_data = self.all_camp_data or {}
	else
		self.skin_data = self.all_shop_data[cur_camp_type] or {}
	end
	self.skin_scrollview:reloadData()
	if #self.skin_data > 0 then
		commonShowEmptyIcon(self.skin_scrollview, false)
	else
		commonShowEmptyIcon(self.skin_scrollview, true, {text = TI18N("暂无可购买的皮肤")})
	end
end

function SkinShopWindow:showCampEffect( status, pos )
	if status == true then
		if not tolua.isnull(self.camp_panel) and self.camp_effect == nil then
            self.camp_effect = createEffectSpine(Config.EffectData.data_effect_info[1602], cc.p(pos, 61), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.camp_panel:addChild(self.camp_effect)
		end
		if self.camp_effect and pos then
			self.camp_effect:setPositionX(pos)
		end
	else
		if self.camp_effect then
            self.camp_effect:clearTracks()
            self.camp_effect:removeFromParent()
            self.camp_effect = nil
		end
	end
end

function SkinShopWindow:showLightEffect( status )
	if status == true then
		if not tolua.isnull(self.main_container) and self.light_effect_1 == nil then
            self.light_effect_1 = createEffectSpine(Config.EffectData.data_effect_info[1601], cc.p(21, 882), cc.p(0, 0.5), true, PlayerAction.action)
            self.main_container:addChild(self.light_effect_1)
		end
		if not tolua.isnull(self.main_container) and self.light_effect_2 == nil then
            self.light_effect_2 = createEffectSpine(Config.EffectData.data_effect_info[1601], cc.p(702, 882), cc.p(1, 0.5), true, PlayerAction.action)
			self.light_effect_2:setScaleX(-1)
			self.main_container:addChild(self.light_effect_2)
        end
	else
		if self.light_effect_1 then
            self.light_effect_1:clearTracks()
            self.light_effect_1:removeFromParent()
            self.light_effect_1 = nil
		end
		if self.light_effect_2 then
            self.light_effect_2:clearTracks()
            self.light_effect_2:removeFromParent()
            self.light_effect_2 = nil
        end
	end
end

function SkinShopWindow:onClickCloseBtn()
	_controller:openSkinShopWindow(false)
end

function SkinShopWindow:close_callback( )
	self:showLightEffect(false)
	self:showCampEffect(false)
	if self.skin_scrollview then
		self.skin_scrollview:DeleteMe()
		self.skin_scrollview = nil
	end
	_controller:openSkinShopWindow(false)
end

-----------------------@ item
SkinShopItem = class('SkinShopItem',function()
	return ccui.Layout:create()
end)

function SkinShopItem:ctor()
	self:configUI()
	self:registerEvent()

	self.item_list = {}
end

function SkinShopItem:configUI()
	self.size = cc.size(206, 325)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("mall/skin_shop_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

	local container = self.root_wnd:getChildByName("container")
	container:setSwallowTouches(false)
	self.container = container
	
	self.card_sp = container:getChildByName("card_sp")
	self.card_sp:setScale(0.6)
	self.camp_sp = container:getChildByName("camp_sp")
	self.name_txt = container:getChildByName("name_txt")
	self.buy_btn = container:getChildByName("buy_btn")
	self.price_txt = self.buy_btn:getChildByName("label")
end

function SkinShopItem:registerEvent()
	registerButtonEventListener(self.container, handler(self, self.onClickItem), true, nil, nil, nil, nil, true)
	registerButtonEventListener(self.buy_btn, handler(self, self.onClickBuyBtn), true)
end

function SkinShopItem:onClickItem()
	if self.skin_cfg then
		local item_id = self.skin_cfg.item_id_list[1] -- 取第一个显示(第一个为永久)
		if not item_id then return end
		local item_cfg = Config.ItemData.data_get_data(item_id)
		if item_cfg then
			HeroController:getInstance():openHeroSkinTipsPanel(true, item_cfg)
		end
	end
end

function SkinShopItem:onClickBuyBtn()
	if not self.mall_cfg then return end
	if self.is_have == false then
		local charge_id = self.mall_cfg.charge_id
        local charge_config = Config.ChargeData.data_charge_data[charge_id or 0]
        if charge_config then
            sdkOnPay(charge_config.val, nil, charge_config.id, charge_config.name, charge_config.name)
        end
	else
		message(TI18N("已经拥有该皮肤"))
	end
end

function SkinShopItem:setData(data)
	if not data then return end
	
	self.mall_cfg = data.mall_cfg
	self.skin_cfg = data.skin_cfg
	self.camp_type = data.camp_type

	if self.item_grid_bg then
		self.item_grid_bg:setVisible(false)
	end

	if not self.mall_cfg or not self.skin_cfg or not self.camp_type then
		return
	end

	-- 名称
	self.name_txt:setString(self.skin_cfg.skin_name)
	-- 价格
	self.price_txt:setString(_string_format("￥%s", self.mall_cfg.price))
	-- 阵营
	local camp_path = PathTool.getHeroCampTypeIcon(self.camp_type)
	loadSpriteTexture(self.camp_sp, camp_path, LOADTEXT_TYPE_PLIST)
	-- 卡牌
    local card_res = PathTool.getPlistImgForDownLoad("bigbg/partnercard", "partnercard_" .. self.skin_cfg.head_card_id)
    if self.recrod_res ~= card_res then
        self.recrod_res = card_res
    	self.card_load = loadSpriteTextureFromCDN(self.card_sp, card_res, ResourcesType.single, self.card_load)
    end
	-- 物品
	for k,item in pairs(self.item_list) do
		item:setVisible(false)
	end
	for i,v in ipairs(self.mall_cfg.award or {}) do
		local bid = v[1]
		local num = v[2]
		local item_cfg = Config.ItemData.data_get_data(bid)
		if item_cfg then
			local item_node = self.item_list[i]
			if not item_node then
				item_node = BackPackItem.new(true, true, false, 0.5, true, true)
				self.container:addChild(item_node)
				self.item_list[i] = item_node
			end
			item_node:setVisible(true)
			item_node:setPosition(68+(i-1)*70, 86)
			item_node:setBaseData(bid, num)
		end
	end
	-- 是否已经拥有
	if HeroController:getModel():isUnlockHeroSkin(self.skin_cfg.skin_id, true) or (BackpackController:getInstance():getModel():getItemNumByBid(self.mall_cfg.skin_bid) > 0) then
		self.is_have = true
		self.price_txt:setString(TI18N("已拥有"))
	else
		self.is_have = false
	end
	setChildUnEnabled(self.is_have, self.buy_btn)
end

function SkinShopItem:createItemBgSprite()
	if not self.item_grid_bg then
		self.item_grid_bg = createSprite(PathTool.getPlistImgForDownLoad("bigbg/mall","skin_bg_3"), -14, 20, self, cc.p(0,1), LOADTEXT_TYPE, -1)
	end
	self.item_grid_bg:setVisible(true)
end

function SkinShopItem:DeleteMe()
	if self.card_load then
		self.card_load:DeleteMe()
		self.card_load = nil
	end
	for k,item in pairs(self.item_list) do
		item:DeleteMe()
		item = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end