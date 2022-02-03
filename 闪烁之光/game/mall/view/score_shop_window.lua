-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      积分商店（暂时是复制 mall_window 的代码，后续会调整为全新UI）
-- <br/>Create: 2019-11-09
-- --------------------------------------------------------------------
local _controller = MallController:getInstance()
local _model = _controller:getModel()
local _table_sort = table.sort
local _table_insert = table.insert

ScoreShopWindow = ScoreShopWindow or BaseClass(BaseView)

function ScoreShopWindow:__init()
	self.role_vo = RoleController:getInstance():getRoleVo()
    self.is_full_screen = true
    self.win_type = WinType.Full    
    self.layout_name = "mall/score_shop_window"       	
    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("mall_score","mall_score"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/mall","score_bg_1"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("bigbg/mall","skin_bg_1"), type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("bigbg/mall","skin_bg_3"), type = ResourcesType.single},
        
	}
	
	self.tab_array = {}
	self.tab_list = {}
    self.cur_tab = nil
    --当前选中的商店索引
    self.cur_index = nil
    --当前选中的商店类型
    self.cur_shop_type = nil
    self.data_list = {}
    --商店类型 对应 索引
    self.dicShopTypeIndex = {}
	self.dicSecondMenuIndex = {}
	
	self:initShopData()
end

function ScoreShopWindow:initShopData(  )
	local config_list = Config.ExchangeData.data_shop_list
    if config_list then
        for k,config in pairs(config_list) do
            if config.score_sort > 0 then
				local data = {}
				data.config = config
				data.shop_type = config.id
				data.index = config.score_sort
				data.status = true
                data.subtype = config.subtype
                data.can_touch, data.notice = self:checkBtnIsOpen(config.id, config.limit)
				if not data.notice or data.notice == "" then
					data.notice = TI18N("暂未解锁")
				end
				_table_insert(self.tab_array, data)
            end
        end
        _table_sort( self.tab_array, function(a, b) return a.index < b.index end)
	end
	
	for i,v in ipairs(self.tab_array) do
        if #v.subtype > 0 then
            for _, second_shop_type in ipairs(v.subtype) do
                self.dicSecondMenuIndex[second_shop_type] = i
            end
        end
        self.dicShopTypeIndex[v.shop_type] = i
	end
end

function ScoreShopWindow:checkBtnIsOpen( _type, limit )
    local can_touch = true
    local notice = ""
    if _type == MallConst.MallType.UnionShop then --公会商店特殊处理
        if self.role_vo and self.role_vo.gid ~= 0 then -- 是否加入了公会
            can_touch = true
        else
            can_touch = false
            notice = TI18N("尚未加入公会")
        end
    elseif limit and next(limit) ~= nil then
        can_touch, notice = MainuiController:getInstance():checkIsOpenByActivate(limit)
    end
    return can_touch, notice
end

function ScoreShopWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
 
    
    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer , 1) 
    self.container_size = self.mainContainer:getContentSize()
    self.top_panel = self.mainContainer:getChildByName("top_panel")
    self.tableContainer = self.top_panel:getChildByName("btn_list")
    
    self.titleImage = self.top_panel:getChildByName("titleImage")
    self.btn = self.top_panel:getChildByName("reset_btn")
    self.btn:setVisible(false)

    self.add_btn = self.top_panel:getChildByName("add_btn")
    self.add_btn:setVisible(true)

    self.btn_label = createRichLabel(24,cc.c4b(0xff, 0xff, 0xff,0xff),cc.p(0.5,0.5),cc.p(self.btn:getContentSize().width/2,self.btn:getContentSize().height/2))
    self.btn_label:setString(TI18N("刷新"))
    self.btn_label:setVisible(false)
    self.btn:addChild(self.btn_label)
    self.coin = self.top_panel:getChildByName("item_sp")
    self.count = self.top_panel:getChildByName("count_txt")

    
    self.time_bg = self.top_panel:getChildByName('Image_4')
    self.time_bg:setVisible(false)
    self.tips_btn = self.top_panel:getChildByName('tips_btn')
    self.tips_btn:setVisible(false)
    self.time = createRichLabel(18,cc.c4b(0x9c, 0xd6, 0x7a,0xff),cc.p(0,0.5),cc.p(450,981))
    self.top_panel:addChild(self.time)
    self.time:setVisible(false)
    self.time_down_text = createRichLabel(18,cc.c4b(0xff, 0xed, 0xda,0xff),cc.p(1,0.5),cc.p(710,981))
    self.top_panel:addChild(self.time_down_text)
    self.time_down_text:setVisible(false)
    self.scrollCon = self.top_panel:getChildByName("Image_1")--道具背景
    
    self.l_bg = self.top_panel:getChildByName("l_bg")
    self.r_bg = self.top_panel:getChildByName("r_bg")
    self.good_cons = self.top_panel:getChildByName("item_list")
    self.bottom_bg = self.mainContainer:getChildByName("bottom_bg")
    self.bottom_bg2 = self.mainContainer:getChildByName("bottom_bg2")
    self.close_btn = self.mainContainer:getChildByName("close_btn")
    self:createTitleEffect()
    self:adaptationScreen()
end

--设置适配屏幕
function ScoreShopWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.mainContainer)
    local bottom_y = display.getBottom(self.mainContainer)
    local left_x = display.getLeft(self.mainContainer)
    local right_x = display.getRight(self.mainContainer)

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.container_size.height - tab_y))

    local temp_height = self.top_panel:getPositionY() -self.container_size.height
    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(close_btn_y+bottom_y)
    local bottom_bg_y = self.bottom_bg:getPositionY()
    self.bottom_bg:setPositionY(bottom_bg_y+bottom_y)
    local bottom_bg2_y = self.bottom_bg2:getPositionY()
    self.bottom_bg2:setPositionY(bottom_bg2_y+bottom_y)
    

    local size = self.scrollCon:getContentSize()
    local height = (top_y - self.container_size.height) - bottom_y
    self.scrollCon:setContentSize(cc.size(size.width, size.height + height))
    local good_cons_size = self.good_cons:getContentSize()
    self.good_cons:setContentSize(cc.size(good_cons_size.width, good_cons_size.height + height))
    local r_bg_size = self.r_bg:getContentSize()
    self.r_bg:setContentSize(cc.size(r_bg_size.width, r_bg_size.height + height))
    local l_bg_size = self.l_bg:getContentSize()
    self.l_bg:setContentSize(cc.size(l_bg_size.width, l_bg_size.height + height))
end

function ScoreShopWindow:createTitleEffect()
    if MAKELIFEBETTER == true then return end
    if self.title_effect then return end
	self.title_effect = createEffectSpine("E24129", cc.p(0, 0), cc.p(0.5, 0), true)
    self.titleImage:addChild(self.title_effect)
end 

function ScoreShopWindow:register_event( )
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn) ,true, 2)

    registerButtonEventListener(self.add_btn, function()
		local item_bid = Config.ExchangeData.data_shop_list[self.cur_shop_type].item_bid
        local data = Config.ItemData.data_get_data(item_bid)
        BackpackController:getInstance():openTipsSource( true,data )
    end,true, 1)

	registerButtonEventListener(self.btn, function()
		self:onClickRefreshBtn()
    end,true, 1)

	--获取商品已购买次数(限于购买过的有限购的商品)
	self:addGlobalEvent(MallEvent.Open_View_Event, function ( data )
		if not data then return end
			--目前只有道具商店用这个协议
		local list = self:initGodShopData(data.type, data)
		if list ~= nil then
			data.item_list = list
			self.data_list[data.type] = data
			if self.cur_shop_type == data.type then
				self:updateDataList()
			end
		end
	end)

	--商店购买数量数据返回
	self:addGlobalEvent(MallEvent.Get_Buy_list, function ( data )
		if not data then return end
		self.data_list[data.type] = data
		for i,v in ipairs(data.item_list) do
			v.shop_type = data.type
		end
		if data.type == self.cur_shop_type then
			self:setResetCount(data)
			if self.cur_shop_type == MallConst.MallType.SkillShop or self.cur_shop_type == MallConst.MallType.CrossarenaShop or self.cur_shop_type == MallConst.MallType.GuessShop then
				self:setLessTime(self.data_list[self.cur_shop_type].refresh_time - GameNet:getInstance():getTime())
			end
			self:updateDataList()
		end
	end)

    if self.role_vo then
        if self.role_update_lev_event == nil then
            self.role_update_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE,function(key,value)
                if key == "lev" then
                    --等级发生改变
                    for i,v in ipairs(self.tab_array) do
                        v.can_touch, v.notice = self:checkBtnIsOpen(v.config.id, v.config.limit)
						if not v.notice or v.notice == "" then
							v.notice = TI18N("暂未解锁")
						end
                    end
                    if self.tab_btn_list_view then
                        self.tab_btn_list_view:resetCurrentItems()
                    end
                else
                    local config = Config.ExchangeData.data_shop_list[self.cur_shop_type]
                    if config then
                        local item_bid = config.item_bid
                        if Config.ItemData.data_assets_id2label[item_bid] == key then
                            self.count:setString(MoneyTool.GetMoneyString(self.role_vo[Config.ItemData.data_assets_id2label[item_bid]]))
                        end
                    end
                end
            end)
        end
    end

    registerButtonEventListener(self.tips_btn, function() self:onClickTips(self.tips_btn) end ,true, 2)
   

    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code,temp_list)
       if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            if self.cur_shop_type == MallConst.MallType.SkillShop then
                local item_bid = Config.ExchangeData.data_shop_list[MallConst.MallType.SkillShop].item_bid
                for i,item in pairs(temp_list) do
                    if item.base_id == item_bid then
                        self:updateIconInfo(item_bid)
                        break
                    end
                end
            end
        end
    end)

    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,temp_list)
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
            if self.cur_shop_type == MallConst.MallType.SkillShop then
                local item_bid = Config.ExchangeData.data_shop_list[MallConst.MallType.SkillShop].item_bid
                for i,item in pairs(temp_list) do
                    if item.base_id == item_bid then
                        self:updateIconInfo(item_bid)
                        break
                    end
                end
            end
        end
    end)

    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
        if bag_code ~= BackPackConst.Bag_Code.EQUIPS then
            if self.cur_shop_type == MallConst.MallType.SkillShop then 
                local item_bid = Config.ExchangeData.data_shop_list[MallConst.MallType.SkillShop].item_bid
                for i,item in pairs(temp_list) do
                    if item.base_id == item_bid then
                        self:updateIconInfo(item_bid)
                        break
                    end
                end
            end
        end
    end)
end

function ScoreShopWindow:onClickRefreshBtn(  )
	if self.cur_shop_type == MallConst.MallType.Recovery then
		local asset_cfg = Config.ExchangeData.data_shop_exchage_cost["soul_reset_cost"]
		local bid,num
		if asset_cfg then
			bid = asset_cfg.val[1][1]
			num = asset_cfg.val[1][2]
		end
		if bid and num then
			local str = string.format(TI18N("是否消耗<img src=%s scale=0.3 visible=true /><div>%s</div>进行重置？"),PathTool.getItemRes(Config.ItemData.data_get_data(bid).icon), num)
			local function fun()
				_controller:sender13405(self.cur_shop_type)
			end
			CommonAlert.show(str,TI18N("确认"),fun,TI18N("取消"),nil,CommonAlert.type.rich)
		end
	elseif self.cur_shop_type == MallConst.MallType.SkillShop then
		_controller:sender13405(MallConst.MallType.SkillShop)
	elseif self.cur_shop_type == MallConst.MallType.CrossarenaShop then
		_controller:sender13405(MallConst.MallType.CrossarenaShop)
	elseif self.cur_shop_type == MallConst.MallType.GuessShop then
		local list =  Config.ExchangeData.data_shop_list[MallConst.MallType.GuessShop].cost_list
		if self.role_vo.star_point >= list[1][2] then
			_controller:sender13405(MallConst.MallType.GuessShop)
		else
			message(TI18N("探宝积分不足"))
			BackpackController:getInstance():openTipsSource(true, 18)
		end
    end
    
    -- self.btn:stopAllActions()
    -- self.btn:setRotation(0)
    -- local skewto_1 = cc.RotateTo:create(0.5, 10)
    -- local skewto_2 = cc.RotateTo:create(0.5, -10)
    -- local skewto_3 = cc.RotateTo:create(0.25, 0)
    -- local seq = cc.Sequence:create(skewto_1,skewto_2, skewto_1,skewto_2,skewto_3)
    -- self.btn:runAction(seq)
end

function ScoreShopWindow:onClickTips(sender)
    local str = ""
    if self.cur_shop_type == MallConst.MallType.Recovery then
        if Config.ExchangeData.data_shop_exchage_cost["hero_soul_instruction"] and Config.ExchangeData.data_shop_exchage_cost["hero_soul_instruction"].desc then
            str = Config.ExchangeData.data_shop_exchage_cost["hero_soul_instruction"].desc
        end
    elseif self.cur_shop_type == MallConst.MallType.SkillShop then
        if Config.ExchangeData.data_shop_exchage_cost['secret_instruction'] and Config.ExchangeData.data_shop_exchage_cost['secret_instruction'].desc then
            str = Config.ExchangeData.data_shop_exchage_cost['secret_instruction'].desc
        end
    end
    TipsManager:getInstance():showCommonTips(str,sender:getTouchBeganPosition())
end

--页签滚动列表
function ScoreShopWindow:updateTabBtnList(index)
    if not self.tab_array then return end

    if not self.tab_btn_list_view then
        local size = self.tableContainer:getContentSize()
        local count = self:numberOfCellsTabBtn()
        local item_width = 135
        local item_height = 66
        local position_data_list 
        if count <= 4  then
            position_data_list = {}
            local s_x = 5 --(size.width - count * item_width) * 0.5
            local y = item_height * 0.5
            for i=1,count do
                local x = s_x + item_width * 0.5 + (i -1) * item_width
                position_data_list[i] = cc.p(x, y)
            end
        end
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 5,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = item_width,               -- 单元的尺寸width
            item_height = item_height,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            -- col = 5,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true,
            position_data_list = position_data_list
        }

        self.tab_btn_list_view = CommonScrollViewSingleLayout.new(self.tableContainer, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.horizontal, ScrollViewStartPos.top, size, setting, cc.p(0.5,0.5))
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.createNewCellTabBtn), ScrollViewFuncType.CreateNewCell) --创建cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.numberOfCellsTabBtn), ScrollViewFuncType.NumberOfCells) --获取数量
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndexTabBtn), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.onCellTouchedTabBtn), ScrollViewFuncType.OnCellTouched) --更新cell

        if count <= 4  then
            self.tab_btn_list_view:setClickEnabled(false)
        end
    end
    local index = index or 1
    self.tab_btn_list_view:reloadData(index)
end

function ScoreShopWindow:createNewCellTabBtn(width, height)
    local cell = ccui.Widget:create()
    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/score_shop_btn"))
    cell:addChild(cell.root_wnd)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(cc.p(0.5, 0.5))
    cell:setContentSize(cc.size(width, height))
    cell.tab_btn = cell.root_wnd:getChildByName("tab_btn")
    cell.normal_img = cell.tab_btn:getChildByName("unselect_bg")
    cell.select_img = cell.tab_btn:getChildByName("select_bg")
    cell.select_img:setVisible(false)
    -- cell.setOntouch
    cell.tab_btn:setSwallowTouches(false)
    cell.label = cell.tab_btn:getChildByName("title")
    cell.label:setTextColor(cc.c4b(0xe6,0xc7,0x96,0xff))

    --红点. 暂时没有红点 先隐藏
    cell.red_point = cell.tab_btn:getChildByName("tab_tips")
    cell.red_num = cell.tab_btn:getChildByName("red_num")
    cell.red_point:setVisible(false)
    cell.red_num:setVisible(false)

    registerButtonEventListener(cell.tab_btn, function() self:onCellTouchedTabBtn(cell) end, false, 2, nil, nil, nil, true)
    -- --回收用
    -- cell.DeleteMe = function() 
    -- end
    return cell
end

function ScoreShopWindow:numberOfCellsTabBtn()
    if not self.tab_array then return 0 end
    return #self.tab_array
end

function ScoreShopWindow:updateCellByIndexTabBtn(cell, index)
    cell.index = index
    local tab_data = self.tab_array[index]
    if tab_data then
        cell.label:setString(tab_data.config.name)
        if self.cur_index == index then
            cell.select_img:setVisible(true)
            cell.label:setTextColor(cc.c4b(0xff,0xf3,0xeb,0xff))
        else
            cell.select_img:setVisible(false)
            cell.label:setTextColor(cc.c4b(0xe6,0xc7,0x96,0xff))
        end

        if tab_data.can_touch then
            cell.label:enableOutline(cc.c4b(0x2a, 0x16, 0x0e, 0xff), 2)
            setChildUnEnabled(false, cell.tab_btn)
        else 
            cell.label:disableEffect(cc.LabelEffect.OUTLINE)
            setChildUnEnabled(true, cell.tab_btn)
        end
    end
end

function ScoreShopWindow:onCellTouchedTabBtn(cell)
    local index = cell.index
    local tab_data = self.tab_array[index]
    if tab_data then
        --点击需要判断
        if tab_data.can_touch then
            self:changeTabView(index, true)
        else
            message(TI18N(tab_data.notice))
        end
    end
end

function ScoreShopWindow:changeTabView(index, check_repeat_click)
    if not index then return end
    if check_repeat_click and self.cur_index == index then return end
    local tab_data = self.tab_array[index]
    if not tab_data then return end

    if self.cur_tab ~= nil then
        if self.cur_tab.label and self.cur_tab.index then
            local cur_tab_data = self.tab_array[self.cur_tab.index]
            if cur_tab_data.can_touch then
                self.cur_tab.label:setTextColor(cc.c4b(0xe6,0xc7,0x96,0xff))
            end
        end
        self.cur_tab.select_img:setVisible(false)
    end

    self.cur_index = index
    self.cur_shop_type = tab_data.shop_type

    self.cur_tab =  self.tab_btn_list_view:getCellByIndex(self.cur_index)

    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(cc.c4b(0xff,0xed,0xd6,0xff))
        end
        self.cur_tab.select_img:setVisible(true)
    end

    self.tips_btn:setVisible(false)
    self.time:setVisible(false)
    self.time_down_text:setVisible(false)

    --是否有 子标签
	if #tab_data.config.subtype > 0 then
        local subtype = tab_data.config.subtype
        if not self.son_panel then
            self.son_panel = MallSonPanel.new()
            self.mainContainer:addChild(self.son_panel)
        else
            self.son_panel:setVisibleStatus(true)
        end
        self.son_panel:setList(subtype)
        if self.init_shop_type then
            self.son_panel:openById(self.init_shop_type)
            self.init_shop_type = nil
        else
            self.son_panel:openById(subtype[1])    
        end
        self.good_cons:setVisible(false)
        self.btn:setVisible(false)
        self.btn_label:setVisible(false)
        self.coin:setVisible(false)
        self.count:setVisible(false)
    else
        self.good_cons:setVisible(true)
        self.coin:setVisible(true)
        self.count:setVisible(true)

        if self.cur_shop_type == MallConst.MallType.Recovery then
            --神格商店 
            if not self.data_list[self.cur_shop_type] then
                _controller:sender13403(self.cur_shop_type)
            else
                self:setResetCount(self.data_list[self.cur_shop_type])
            end
            self.btn:setVisible(true)
            self.btn_label:setVisible(true)
            self.tips_btn:setVisible(true)
        elseif self.cur_shop_type == MallConst.MallType.SkillShop then
            --技能商店 
            if not self.data_list[self.cur_shop_type] then
                _controller:sender13403(self.cur_shop_type)
            else
                local time = self.data_list[self.cur_shop_type].refresh_time - GameNet:getInstance():getTime()
                if time > 0 then
                    self:setLessTime(time)
                else
                    self:setTimeFormatString(0)
                    _controller:sender13403(MallConst.MallType.SkillShop)
                end
                self:setResetCount(self.data_list[self.cur_shop_type])
            end

            self.btn:setVisible(true)
            self.btn_label:setVisible(true)
		elseif self.cur_shop_type == MallConst.MallType.GuessShop then
			-- 探宝商城
            if not self.data_list[self.cur_shop_type] then
                _controller:sender13403(self.cur_shop_type)
            else
                local time = self.data_list[self.cur_shop_type].refresh_time - GameNet:getInstance():getTime()
                if time > 0 then
                    self:setLessTime(time)
                else
                    self:setTimeFormatString(0)
                    _controller:sender13403(MallConst.MallType.GuessShop)
                end
                self:setResetCount(self.data_list[self.cur_shop_type])
            end

            self.btn:setVisible(true)
            self.btn_label:setVisible(true)
		elseif self.cur_shop_type == MallConst.MallType.CrossarenaShop then
			-- 跨服竞技场商城
			if not self.data_list[self.cur_shop_type] then
                _controller:sender13403(self.cur_shop_type)
            else
                local time = self.data_list[self.cur_shop_type].refresh_time - GameNet:getInstance():getTime()
                if time > 0 then
                    self:setLessTime(time)
                else
                    self:setTimeFormatString(0)
                    _controller:sender13403(MallConst.MallType.CrossarenaShop)
                end
                self:setResetCount(self.data_list[self.cur_shop_type])
            end

            self.btn:setVisible(true)
            self.btn_label:setVisible(true)
		else
            --道具商店 皮肤商店 (属于没有刷新需求的一类)
			if not self.data_list[self.cur_shop_type] then
                _controller:sender13401(self.cur_shop_type)
            end

            self.btn:setVisible(false)
            self.btn_label:setVisible(false)
        end

        if self.data_list[self.cur_shop_type] then
            self:updateDataList()
        end

        local item_bid = tab_data.config.item_bid
        if self.record_item_bid == nil or self.record_item_bid ~= item_bid then
            self.record_item_bid = item_bid
            loadSpriteTexture(self.coin, PathTool.getItemRes(Config.ItemData.data_get_data(item_bid).icon), LOADTEXT_TYPE)
        end
        self:updateIconInfo(item_bid)

        if self.son_panel then
            self.son_panel:setVisibleStatus(false)
        end
    end
    self:updateTimeBg()
end

function ScoreShopWindow:openRootWnd(shop_type)
	_controller:setFirstLogin(false)

	local shop_type = shop_type or MallConst.MallType.GodShop
    local index = self.dicShopTypeIndex[shop_type]
    if index == nil then
        --一级菜单没有 找二级菜单的
        index = self.dicSecondMenuIndex[shop_type]
        if index == nil then
            index = 1
        else
            self.init_shop_type = shop_type --二级菜单的时候需要
        end
    end

    self:updateTabBtnList(index)
end

function ScoreShopWindow:updateDataList()
    if not self.cur_shop_type then return end
    if not self.data_list[self.cur_shop_type] then return end

    if not self.item_scrollview then
        local scroll_view_size = self.good_cons:getContentSize()
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 30,                  -- 第一个单元的X起点
            space_x = 20,                    -- x方向的间隔
            start_y = 15,                    -- 第一个单元的Y起点
            space_y = 40,                   -- y方向的间隔
            item_width = 195,               -- 单元的尺寸width
            item_height = 236,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            col = 3,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.good_cons, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0,0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.item_scrollview:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    self.show_list = self.data_list[self.cur_shop_type].item_list
    self.item_scrollview:reloadData()
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.good_cons, true, {font_size = 22,scale = 1})
    else
        commonShowEmptyIcon(self.good_cons, false)
    end
end

function ScoreShopWindow:createNewCell(width, height)
    local cell = ScoreShopItem.new()
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end

function ScoreShopWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

function ScoreShopWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    cell:setData(cell_data)
    if index%3 == 1 then
	    cell:createItemBgSprite()
	end
end

function ScoreShopWindow:onCellTouched(cell)
    local index = cell.index
    local cell_data = self.show_list[index]
    if cell_data then
        if cell_data.has_buy == nil then
            if cell_data.ext and cell_data.ext[1] then
                cell_data.has_buy = cell_data.ext[1].val
            else
                cell_data.has_buy = 0
            end
        end

        cell_data.shop_type = self.cur_shop_type
        _controller:openMallBuyWindow(true, cell_data)
    end
end

--设置倒计时
function ScoreShopWindow:setLessTime( less_time )
    if tolua.isnull(self.time) then return end
    self.time:setVisible(true)
    self:updateTimeBg()
    self.time:stopAllActions()
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.time:stopAllActions()
                if self.cur_shop_type == MallConst.MallType.SkillShop then
                    _controller:sender13403(MallConst.MallType.SkillShop)
                end
            else
                self:setTimeFormatString(less_time)
            end
        end)
        )))
    else
        self:setTimeFormatString(less_time)
    end
end

function ScoreShopWindow:setTimeFormatString(time)
    self.rest_time = time
    if time > 0 then
        self.time:setString(string.format(TI18N("免费刷新: %s"),TimeTool.GetTimeFormat(time)))
    else
        self.time:setString(TI18N("免费刷新: 00:00:00"))
    end
end

function ScoreShopWindow:updateIconInfo(item_bid)
    if not item_bid then return end
    self.count:setString(MoneyTool.GetMoneyString(BackpackController:getInstance():getModel():getItemNumByBid(item_bid)))
end

function ScoreShopWindow:setResetCount(data)
    if not data then return end
    local free_count = data.free_count or 0
    local btn_str = TI18N("免费刷新")
    if self.cur_shop_type == MallConst.MallType.Recovery then --神格
        if free_count <= 0 then
            local asset_cfg = Config.ExchangeData.data_shop_exchage_cost["soul_reset_cost"]
            if asset_cfg then
                local bid = asset_cfg.val[1][1]
                local num = asset_cfg.val[1][2]
                btn_str = string.format(TI18N("<img src=%s scale=0.3 visible=true /><div outline=2,#764519>%s重置</div>"), PathTool.getItemRes(Config.ItemData.data_get_data(bid).icon), num)
            end
        end
    elseif self.cur_shop_type == MallConst.MallType.SkillShop then --技能
        if free_count <= 0 then
            local  config = Config.ExchangeData.data_shop_list[MallConst.MallType.SkillShop]
            if config then
                local cost_list = config.cost_list
                local bid = cost_list[1][1]
                local num = cost_list[1][2]
                btn_str = string.format(TI18N("<img src=%s scale=0.3 visible=true /><div outline=2,#764519>%s刷新</div>"), PathTool.getItemRes(Config.ItemData.data_get_data(bid).icon), num)
            end
        else
            local asset_cfg = Config.ExchangeData.data_shop_exchage_cost["skill_refresh_free"] 
            if asset_cfg then
                btn_str = string.format("<div outline=2,#764519>%s(%s/%s)</div>", TI18N("免费刷新"), free_count, asset_cfg.val)
            end
        end
        self.time_down_text:setVisible(true)
        local config = Config.ExchangeData.data_shop_exchage_cost.skill_refresh_number
        local max_count = 0 
        if config then
            max_count = config.val
        end
        local count = data.count or 0
        local text = string.format("(%s：%s/%s)",TI18N("次数"), count, max_count)
		self.time_down_text:setString(text)
	elseif self.cur_shop_type == MallConst.MallType.GuessShop then --探宝
		if free_count <= 0 then
			local config = Config.ExchangeData.data_shop_list[MallConst.MallType.GuessShop]
            if config and config.cost_list then
                local bid = config.cost_list[1][1]
                local num = config.cost_list[1][2]
                btn_str = string.format(TI18N("<img src=%s scale=0.3 visible=true /><div outline=2,#764519>%s刷新</div>"), PathTool.getItemRes(Config.ItemData.data_get_data(bid).icon), num)
            end
        end
	elseif self.cur_shop_type == MallConst.MallType.CrossarenaShop then --跨服竞技场
		if free_count <= 0 then
            local  config = Config.ExchangeData.data_shop_list[MallConst.MallType.CrossarenaShop]
            if config then
                local cost_list = config.cost_list
                local bid = cost_list[1][1]
                local num = cost_list[1][2]
                btn_str = string.format(TI18N("<img src=%s scale=0.3 visible=true /><div outline=2,#764519>%s刷新</div>"), PathTool.getItemRes(Config.ItemData.data_get_data(bid).icon), num)
            end
        else
            local asset_cfg = Config.ExchangeData.data_shop_exchage_cost["cluster_refresh_free"] 
            if asset_cfg then
                btn_str = string.format("<div outline=2,#764519>%s(%s/%s)</div>", TI18N("免费刷新"), free_count, asset_cfg.val)
            end
        end
        self.time_down_text:setVisible(true)
        local config = Config.ExchangeData.data_shop_exchage_cost.cluster_refresh_number
        local max_count = 0 
        if config then
            max_count = config.val
        end
        local count = data.count or 0
        local text = string.format("(%s：%s/%s)",TI18N("次数"), count, max_count)
		self.time_down_text:setString(text)
    end
    self.btn_label:setString(btn_str)
    self:updateTimeBg()
end


function ScoreShopWindow:updateTimeBg()
    local is_visible_down = false
    local is_visible_time = false
    if self.time_down_text and self.time_down_text:isVisible() then
        is_visible_down = true
    end

    if self.time and self.time:isVisible() then
        is_visible_time = true
    end

    if is_visible_down or is_visible_time then
        local width = 284
        local x = 450
        if is_visible_down and is_visible_time then
            width = 284
        elseif is_visible_down then
            width = 114
        elseif is_visible_time then
            width = 180
            x = 550
        end
        self.time:setPositionX(x)
        self.time_bg:setContentSize(cc.size(width,26))
        self.time_bg:setVisible(true)    
    else
        self.time_bg:setVisible(false)    
    end
end

function ScoreShopWindow:initGodShopData(shop_type, data)
	local config_list 

    if shop_type == MallConst.MallType.GodShop then
        config_list = Config.ExchangeData.data_shop_exchage_gold
    elseif shop_type == MallConst.MallType.UnionShop then -- 公会商城
		config_list = Config.ExchangeData.data_shop_exchage_guild
	elseif shop_type == MallConst.MallType.ArenaShop then -- 竞技商城
		config_list = Config.ExchangeData.data_shop_exchage_arena
	elseif shop_type == MallConst.MallType.FriendShop then -- 远征商城
		config_list = Config.ExchangeData.data_shop_exchage_expediton
	elseif shop_type == MallConst.MallType.EliteShop then -- 段位商城
		config_list = Config.ExchangeData.data_shop_exchage_elite
	elseif shop_type == MallConst.MallType.Ladder then -- 天梯商城
		config_list = Config.ExchangeData.data_shop_exchage_ladder
	elseif shop_type == MallConst.MallType.CrosschampionShop then -- 跨服冠军赛商城
		config_list = Config.ExchangeData.data_shop_exchage_crosschampion
    elseif shop_type == MallConst.MallType.PeakchampionShop then -- 巅峰冠军赛商城
        config_list = Config.ExchangeData.data_shop_exchage_peakchampion
	else
		return
    end

    
	local list = {}
    local dic_buys = {}
    for i,v in ipairs(data.item_list) do
        if v.ext and v.ext[1] and v.ext[1].val then
            dic_buys[v.item_id] = v.ext[1].val
        else
            dic_buys[v.item_id] = 0
        end
    end

    if config_list then
        for k,config in pairs(config_list) do
            local data = deepCopy(config)
            if dic_buys[config.id] then
                data.has_buy = dic_buys[config.id]
            else
                data.has_buy = 0
            end
            _table_insert(list, data)
        end
        _table_sort( list, function(a, b) return a.order < b.order end )
    end
    
	return list
end


function ScoreShopWindow:onClickCloseBtn()
	_controller:openScoreShopWindow(false)
end

function ScoreShopWindow:onClickShopBtn()
	
end

function ScoreShopWindow:close_callback( )
    -- if self.btn then
    --     self.btn:stopAllActions()    
    -- end
    if self.title_effect then
        self.title_effect:clearTracks()
        self.title_effect:removeFromParent()
        self.title_effect = nil
    end


	if self.tab_btn_list_view then
		self.tab_btn_list_view:DeleteMe()
		self.tab_btn_list_view = nil
	end

	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    
    if self.son_panel then
        self.son_panel:DeleteMe()
    end

    if self.role_vo then
        if self.role_update_lev_event then
            self.role_vo:UnBind(self.role_update_lev_event)
            self.role_update_lev_event = nil
        end
        self.role_vo = nil
    end
	_controller:openScoreShopWindow(false)
end
