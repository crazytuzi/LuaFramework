-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      钻石商城
-- <br/>Create: 2019-11-13
-- --------------------------------------------------------------------
local _controller = MallController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort

ChargeDiamondPanel = ChargeDiamondPanel or BaseClass()

function ChargeDiamondPanel:__init(parent, offset_y)
    self.is_init = true
    self.parent = parent
    self.offset_y = offset_y or 0
    self.role_vo = RoleController:getInstance():getRoleVo()

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("vip", "vip"), type = ResourcesType.plist},
    }
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
		self:loadResListCompleted()
	end)
end

function ChargeDiamondPanel:loadResListCompleted( )
	self:createRootWnd()
    self:registerEvent()
    self:updateVipRedStatus()
    VipController:getInstance():sender16700()
end

function ChargeDiamondPanel:createRootWnd( )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/charge_normal_panel"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.titleCon = self.main_container:getChildByName("titleCon")
    self.loadingbar = self.titleCon:getChildByName("loadingbar")
    self.loadingbar:setScale9Enabled(true)
    self.loadingbar:setPercent(0)
    self.exp = self.titleCon:getChildByName("exp")
    self.exp:setString("0/0")

    self.now_vip = CommonNum.new(22, self.titleCon, 1, -2, cc.p(0.5, 0.5))
    self.now_vip:setPosition(36, 130)

    self.next_vip = CommonNum.new(22, self.titleCon, 1, -2, cc.p(0, 0.5))
    self.next_vip:setPosition(480, 194)

    self.charge_num = CommonNum.new(21, self.titleCon, 1, -2, cc.p(0, 0.5))
    self.charge_num:setPosition(95, 192)

    self.vip_btn = self.titleCon:getChildByName("vip_btn")
    self.vip_btn:getChildByName("label"):setString(TI18N("查看特权"))

    self.yuan = self.titleCon:getChildByName("yuan")
    self.Sprite_6 = self.titleCon:getChildByName("Sprite_6")
    self.Sprite_6_0 = self.titleCon:getChildByName("Sprite_6_0")

    self:updateBar()
    self:resetTitlePos()

    self.item_list = self.main_container:getChildByName("item_list")
    if MAKELIFEBETTER == true then
        self.titleCon:setVisible(false)
        local temp_size = self.item_list:getContentSize()
        self.item_list:setContentSize(cc.size(temp_size.width, 1000))
        self.item_list:setAnchorPoint(cc.p(0.5, 1))
        self.item_list:setPositionY(display.getTop()-300)
    end
    local list_size = self.item_list:getContentSize()
    local scroll_view_size = cc.size(list_size.width, list_size.height+self.offset_y)
	local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 10,                    -- 第一个单元的Y起点
        space_y = 15,                   -- y方向的间隔
        item_width = 211,               -- 单元的尺寸width
        item_height = 230,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 3,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(self.item_list, cc.p(0, -self.offset_y) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell)
    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells)
	self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex)
end

function ChargeDiamondPanel:createNewCell(  )
    local cell = ChargeDiamondItem.new()
	return cell
end

function ChargeDiamondPanel:numberOfCells(  )
    if not self.charge_data then return 0 end
    return #self.charge_data
end

function ChargeDiamondPanel:updateCellByIndex( cell, index )
    if not self.charge_data then return end
    cell.index = index
    local cell_data = self.charge_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ChargeDiamondPanel:registerEvent( )
    registerButtonEventListener(self.vip_btn, function (  )
        VipController:getInstance():openVipMainWindow(true)
    end, true)

    if self.role_vo then
        if self.role_update_event == nil then
            self.role_update_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE,function(key,value)
                if key == "vip_lev" or key == "vip_exp" then    
                   self:updateBar()    
                end
            end)
        end
    end

    if self.update_event == nil then
		self.update_event = GlobalEvent:getInstance():Bind(VipEvent.UPDATE_CHARGE_LIST,function(list )
			for k,v in pairs(list) do
				if Config.ChargeData.data_charge_data[v.id] then
					v.sort = Config.ChargeData.data_charge_data[v.id].sort
				end
			end
			_table_sort( list, SortTools.KeyLowerSorter("sort") )
			self:createItemList(list)
		end)
    end
    
    if self.update_vip_red_evetn == nil then
        self.update_vip_red_evetn = GlobalEvent:getInstance():Bind(VipEvent.Update_Gift_Red_state,function( )
			self:updateVipRedStatus()
		end)
    end
end

function ChargeDiamondPanel:updateVipRedStatus(  )
    local is_show_red = VipController:getInstance():getVipRedStatus()
    addRedPointToNodeByStatus(self.vip_btn, is_show_red, 5, 10)
end

function ChargeDiamondPanel:createItemList( list )
    self.charge_data = list or {}
    self.item_scrollview:reloadData(nil, nil, true)
end

function ChargeDiamondPanel:setVisibleStatus( status )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end

    if status == true and self.is_init == true then
        self.is_init = false
    end
end

function ChargeDiamondPanel:updateBar()
    local config = Config.VipData.data_get_reward[self.role_vo.vip_lev]
    local max_lev = Config.VipData.data_get_reward_length-1
    local next_config = Config.VipData.data_get_reward[self.role_vo.vip_lev+1]
    if config then
        if next_config then
            self.loadingbar:setPercent(self.role_vo.vip_exp/next_config.gold*100)
            self.exp:setString(self.role_vo.vip_exp.."/"..next_config.gold)
            self.next_vip:setNum(self.role_vo.vip_lev+1)
            self.charge_num:setNum(next_config.gold-self.role_vo.vip_exp)
        else
            self.loadingbar:setPercent(100)
            self.exp:setString(config.gold.."/"..config.gold)
            self.next_vip:setNum(self.role_vo.vip_lev)
            self.charge_num:setNum(0)
        end
    else
        self.loadingbar:setPercent(100)
        self.exp:setString(Config.VipData.data_get_reward[max_lev].gold.."/"..Config.VipData.data_get_reward[max_lev].gold)
        self.charge_num:setNum(0)
        self.next_vip:setNum(self.role_vo.vip_lev)
    end
    self.charge_num:setCallBack(function()
        self:resetTitlePos()
    end)
    if self.charge_num:getContentSize().width>0 then
        self.yuan:setPositionX(self.charge_num:getPositionX()+self.charge_num:getContentSize().width+10)
    end
    
    self.now_vip:setNum(self.role_vo.vip_lev)

    local num = 1
    if self.role_vo.vip_lev+1 >= max_lev then
        num = max_lev
    else
        num = self.role_vo.vip_lev+1
    end
    if MAKELIFEBETTER == true then 
        return
    end
    if not self.next_vip_desc then
        self.next_vip_desc = createSprite(nil, 295, 123, self.titleCon, cc.p(0.5, 0.5))
    end
    local cur_res = PathTool.getPlistImgForDownLoad("bigbg/vip", string.format("txt_cn_vip_lev_%d",num))
    if self.next_res ~= cur_res then
        self.next_res = cur_res
        if not self.vip_desc_load then
            self.vip_desc_load = createResourcesLoad(cur_res, ResourcesType.single, function()
                if self.next_vip_desc then
                    loadSpriteTexture(self.next_vip_desc, cur_res, LOADTEXT_TYPE)
                end
            end, self.vip_desc_load)
        else
            local res_id = PathTool.getPlistImgForDownLoad("bigbg/vip", string.format("txt_cn_vip_lev_%d",num))
            if self.next_vip_desc then
                loadSpriteTexture(self.next_vip_desc, res_id, LOADTEXT_TYPE)
            end
        end
    end
end

function ChargeDiamondPanel:resetTitlePos()
    self.yuan:setPositionX(self.charge_num:getPositionX()+self.charge_num:getContentSize().width+10)
    self.Sprite_6:setPositionX(self.yuan:getPositionX()+self.yuan:getContentSize().width+5)
    self.Sprite_6_0:setPositionX(self.Sprite_6:getPositionX()+self.Sprite_6:getContentSize().width+10)
    self.next_vip:setPositionX(self.Sprite_6_0:getPositionX()+self.Sprite_6_0:getContentSize().width+5)
end

function ChargeDiamondPanel:addChild( node )
	if not tolua.isnull(self.root_wnd) and not tolua.isnull(node) then
        self.root_wnd:addChild(node)
    end
end

function ChargeDiamondPanel:setPosition( pos )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setPosition(pos)
    end
end

function ChargeDiamondPanel:__delete()
    if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    if self.role_vo then
        if self.role_update_event ~= nil then
            self.role_vo:UnBind(self.role_update_event)
            self.role_update_event = nil
        end
        self.role_vo = nil
    end
    if self.update_event then
        GlobalEvent:getInstance():UnBind(self.update_event)
        self.update_event = nil
    end
    if self.update_vip_red_evetn then
        GlobalEvent:getInstance():UnBind(self.update_vip_red_evetn)
        self.update_vip_red_evetn = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
end

------------------------------@ item
ChargeDiamondItem = class("ChargeDiamondItem", function()
	return ccui.Widget:create()
end)

function ChargeDiamondItem:ctor()
	self:configUI()
end

function ChargeDiamondItem:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("vip/charge_item"))
	
    self:setAnchorPoint(cc.p(0, 0))
    self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(211,230))
	self:setTouchEnabled(true)
	self:setSwallowTouches(false)

    self.main_container = self.root_wnd:getChildByName("main_container")

	self.price_container = self.main_container:getChildByName("price_container")
    self.coin = self.price_container:getChildByName("coin")
    self.price = self.price_container:getChildByName("price")
    self.icon = self.main_container:getChildByName("icon")

    self.tag_icon = self.main_container:getChildByName("tag_icon")
    self.charge_price = self.main_container:getChildByName("charge_price")
    self.charge_price:setPositionY(self.tag_icon:getPositionY())
    self.extra_bg = self.main_container:getChildByName("extra_bg")
    self.extra_bg:setVisible(false)
	self.extra_desc = self.extra_bg:getChildByName("give")
	self.extra_desc:setString(TI18N("赠"))

    self.extra_label = createRichLabel(24, 193, cc.p(0.5,0.5), cc.p(165,82))
    self.main_container:addChild(self.extra_label)

    self.confirm_bg = self.main_container:getChildByName("confirm_bg")
    self.confirm_bg:setVisible(false)
    self.confirm_tips = self.main_container:getChildByName("confirm_tips")
    self.confirm_tips:setLocalZOrder(20)
    self.confirm_tips:setVisible(false)

    self.day_tips = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(105, 30))
	self.day_tips:setVisible(false)
	self.main_container:addChild(self.day_tips)
	self.first_bg = self.main_container:getChildByName("first_bg")
	self.first_bg:setVisible(false)
	self.first_label = self.first_bg:getChildByName("first_label")
	self.first_label:setString(TI18N("首次充值"))
	
	self:registerEvent()
end

function ChargeDiamondItem:setData( data )
	self.data = data
	self.charge_price:setString(data.need_rmb/100)
	self.price:setString(data.get_gold)
	if data.is_first == TRUE then
		self.first_bg:setVisible(true)
	else
		self.first_bg:setVisible(false)
	end

    self.extra_bg:setVisible(false)
    self.extra_label:setVisible(false)
	if data.add_gold > 0 then
    	self.extra_bg:setVisible(true)
		self.extra_desc:setString("赠")
		self.extra_label:setString(string.format(TI18N("<img src=%s scale=0.3 visible=true /><div outline=2,#5b2c06>%s</div>"),PathTool.getItemRes(Config.ItemData.data_get_data(4).icon),data.add_gold))
	    self.extra_label:setVisible(true)
    elseif data.id == 1 or data.id == 2 then -- 1:荣耀月卡 2:至尊月卡
		self.coin:setVisible(false)
		self.price:setString(data.name)
    	self.extra_bg:setVisible(true)
		self.extra_desc:setString("即得")
		self.extra_label:setString(string.format(TI18N("<img src=%s scale=0.3 visible=true /><div outline=2,#5b2c06>%s</div>"), PathTool.getItemRes(Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id.gold).icon), data.get_gold)) 
		self.extra_label:setVisible(true)
        self.icon:setScale(0.8)
		self:updateYuekaInfoData(data)
	end	
	loadSpriteTexture(self.icon, PathTool.getResFrame("common","vip_icon"..data.pic), LOADTEXT_TYPE_PLIST)

	-- 提审不是普通充值不显示上面的标签
	if MAKELIFEBETTER == true and data.get_gold == 0 then
		self.price_container:setVisible(false)
	end
end

function ChargeDiamondItem:updateYuekaInfoData(data)
	if data == nil then return end

	local config = nil
	if data.id == 1 then -- 荣耀越开
		config = Config.ChargeData.data_constant.month_card1_items
	elseif data.id == 2 then
		config = Config.ChargeData.data_constant.month_card2_items
	end
	if config then
		if self.get_desc_label == nil then
			self.get_desc_label = createRichLabel(18, cc.c4b(0x44,0x12,0x02,0xff), cc.p(0.5, 0.5), cc.p(106,172))
			self.main_container:addChild(self.get_desc_label)
		end
		local str = ""
		for i,v in ipairs(config.val) do
			local bid = v[1]
			local num = v[2]
			if bid and num then
				local item_config = Config.ItemData.data_get_data(bid)
				if item_config then
					if str ~= "" then
						str = str..TI18N("和")
					end
					str = str..string.format("%s<img src=%s scale=0.25 visible=true />", num, PathTool.getItemRes(item_config.icon))
				end
			end
			self.get_desc_label:setString(string.format(TI18N("每日领")..str))
		end
	end
end

function ChargeDiamondItem:addCallBack( value )
	self.callback =  value
end

function ChargeDiamondItem:registerEvent(  )
    self:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
				self.touch_end = sender:getTouchEndPosition()
				local is_click = true
				if self.touch_began ~= nil then
					is_click =
						math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
						math.abs(self.touch_end.y - self.touch_began.y) <= 20
				end
				if is_click == true then
					playButtonSound2()

					if self.callback then
						self:callback()
					end
					-- if self.confirm_tips:isVisible() then
						sdkOnPay(self.data.need_rmb / 100, nil, self.data.id, self.data.name) 
						-- self.confirm_tips:setVisible(false)
						-- self.confirm_bg:setVisible(false)
					-- else
						-- self.confirm_tips:setVisible(true)
						-- self.confirm_bg:setVisible(true)
					-- end
				end
			elseif event_type == ccui.TouchEventType.moved then
			elseif event_type == ccui.TouchEventType.began then
				self.touch_began = sender:getTouchBeganPosition()
			elseif event_type == ccui.TouchEventType.canceled then
			end
	end)
end

function ChargeDiamondItem:getData(  )
	return self.data
end

function ChargeDiamondItem:setSeclet( status )
	self.confirm_tips:setVisible(status)
	self.confirm_bg:setVisible(status)
end

function ChargeDiamondItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end