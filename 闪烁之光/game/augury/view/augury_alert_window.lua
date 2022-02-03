-- --------------------------------------------------------------------
-- 占卜所有的提示窗口
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
AuguryAlertWindow = AuguryAlertWindow or BaseClass(BaseView)

function AuguryAlertWindow:__init(open_type)
	self.ctrl = AuguryController:getInstance()
	self.is_full_screen = false
	self.layout_name = "augury/augury_alert_window"
	self.cur_type = 0
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("augury", "augury"), type = ResourcesType.plist},
	}
	self.win_type = WinType.Mini
	self.open_type = open_type or 1 --提示类型 ，1.单抽，2.10连抽，3.刷新提示
	
	self.role_vo = RoleController:getInstance():getRoleVo()
end

function AuguryAlertWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background ~= nil then
		self.background:setScale(display.getMaxScale())
	end
	
	self.main_panel = self.root_wnd:getChildByName("main_panel")
	self.close_btn = self.main_panel:getChildByName("close_btn")
	
	self.confirm_btn = self.main_panel:getChildByName("confirm_btn")
	self.confirm_btn:getChildByName("label"):setString(TI18N("确定"))
	
	self.cancel_btn = self.main_panel:getChildByName("cancel_btn")
	self.cancel_btn:getChildByName("label"):setString(TI18N("取消"))
	
	if self.open_type == 1 then
		self:createGoodsCall()
	elseif self.open_type == 2 then
		self:createGoldsCall()
	elseif self.open_type == 3 then
		self:createFlashPanel()
	end
end

function AuguryAlertWindow:register_event()
	self.close_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			self.ctrl:openAlertWidnow(false)
		end
	end)
	self.cancel_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            playCloseSound()
			self.ctrl:openAlertWidnow(false)
		end
	end)
	self.confirm_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
			if self.open_type == 1 then 
			    self.ctrl:sender11331(1,1)
			elseif self.open_type == 2 then 
			    self.ctrl:sender11331(1,10)
			elseif self.open_type == 3 then 
			    self.ctrl:sender11332()
			end
			self.ctrl:openAlertWidnow(false)
		end
	end)
end

--==============================--
--desc:单次抽
--time:2018-09-25 11:58:36
--@return 
--==============================--
function AuguryAlertWindow:createGoodsCall()
	local size = self.main_panel:getContentSize()
	--文字描述
	self.desc_label = createRichLabel(28, Config.ColorData.data_color4[175], cc.p(0.5, 1), cc.p(size.width / 2, 330), 0, 0, 500)
	self.main_panel:addChild(self.desc_label)
	--拥有星魂
	self.have_label = createLabel(28, Config.ColorData.data_color4[175], nil, 130, 130, TI18N("拥有"), self.main_panel, 0, cc.p(0, 0))
	
	local res = PathTool.getResFrame("common", "common_90003")
	local bg = createImage(self.main_panel, res, 300, 130, cc.p(0.5, 0), true, 0, true)
	bg:setCapInsets(cc.rect(20, 15, 1, 1))
	bg:setContentSize(cc.size(177, 33))
	
	self.asset_icon = createImage(self.main_panel, res, 230, 130, cc.p(0.5, 0), false, 0, false)
	self.asset_num = createLabel(28, Config.ColorData.data_color4[175], nil, 310, 130, "0", self.main_panel, 0, cc.p(0.5, 0))

	local notice_desc = createLabel(28, Config.ColorData.data_color4[175], nil, 129, 170, "0", self.main_panel, 0, cc.p(0, 0)) 
	notice_desc:setString(TI18N("每日05:00刷新免费单抽次数"))

	local const_config = Config.StarDivinationData.data_divination_const
	if not const_config then return end
	local asset_val = const_config["divine_change"].val
	if not asset_val then return end
	local one_cost_gold = 0
	local one_cost_icon = ""
	local item_config = Config.ItemData.data_get_data(asset_val[1])
	if item_config then
		local res = PathTool.getItemRes(item_config.icon)
		self.asset_icon:loadTexture(res, LOADTEXT_TYPE)
		self.asset_icon:setScale(0.4)
		
        -- 设置当前拥有的
		if not self.role_vo then return end
		local val_str = Config.ItemData.data_assets_id2label[asset_val[1]] or ""
		local have_num = self.role_vo[val_str] or 0
		if asset_val[1] == 15 then
			have_num = self.role_vo.gold + self.role_vo.red_gold
		end
		self.asset_num:setString(have_num)

        one_cost_icon = res
        one_cost_gold = asset_val[2] or 0
	end

    local asset_val = const_config["divine_buy"].val
    if not asset_val then return end
    local item_config = Config.ItemData.data_get_data (asset_val[1])
    if item_config then 
        local res = PathTool.getItemRes(item_config.icon)
        local num = asset_val[2]
        local desc_str = string.format( TI18N("是否消耗<img src='%s' scale=0.4 />%s购买%s星灵积分？\n(同时附赠1次命格抽取)"),one_cost_icon,one_cost_gold,num)
        self.desc_label:setString(desc_str)
    end
end

--==============================--
--desc:10次抽
--time:2018-09-25 11:58:05
--@return 
--==============================--
function AuguryAlertWindow:createGoldsCall()
	local size = self.main_panel:getContentSize()
	--文字描述
	self.desc_label = createRichLabel(28, Config.ColorData.data_color4[175], cc.p(0.5, 1), cc.p(size.width / 2, 330), 0, 0, 500)
	self.main_panel:addChild(self.desc_label)
	--拥有星魂
	self.have_label = createLabel(28, Config.ColorData.data_color4[175], nil, 130, 130, TI18N("拥有"), self.main_panel, 0, cc.p(0, 0))
	
	local res = PathTool.getResFrame("common", "common_90003")
	local bg = createImage(self.main_panel, res, 300, 130, cc.p(0.5, 0), true, 0, true)
	bg:setCapInsets(cc.rect(20, 15, 1, 1))
	bg:setContentSize(cc.size(177, 33))
	
	self.asset_icon = createImage(self.main_panel, res, 230, 130, cc.p(0.5, 0), false, 0, false)
	self.asset_num = createLabel(28, Config.ColorData.data_color4[175], nil, 310, 130, "0", self.main_panel, 0, cc.p(0.5, 0))
	
	-- self.free_label = createRichLabel(26, Config.ColorData.data_color4[186], cc.p(0,1), cc.p(135,240), 0, 0, 500)
	-- self.main_panel:addChild(self.free_label)
	-- local count = self.ctrl:getModel():getDataGoldCount() or 0
	-- local all_count = Config.StarDivinationData.data_divination_const["divine_times"].val
	-- self.free_label:setString(string.format(TI18N("注：今日还可购买%s/%s次"),all_count-count,all_count))

	local const_config = Config.StarDivinationData.data_divination_const
	if not const_config then return end
	local asset_val = const_config["divine_change10"].val
	if not asset_val then return end
	local one_cost_gold = 0
	local one_cost_icon = ""
	local item_config = Config.ItemData.data_get_data(asset_val[1])
	if item_config then
		local res = PathTool.getItemRes(item_config.icon)
		self.asset_icon:loadTexture(res, LOADTEXT_TYPE)
		self.asset_icon:setScale(0.4)
		
        -- 设置当前拥有的
		if not self.role_vo then return end
		local val_str = Config.ItemData.data_assets_id2label[asset_val[1]] or ""
		local have_num = self.role_vo[val_str] or 0
		if asset_val[1] == 15 then
			have_num = self.role_vo.gold + self.role_vo.red_gold
		end
		self.asset_num:setString(have_num)

        one_cost_icon = res
        one_cost_gold = asset_val[2] or 0
	end

    local asset_val = const_config["divine_buy10"].val
    if not asset_val then return end
    local item_config = Config.ItemData.data_get_data (asset_val[1])
    if item_config then 
        local res = PathTool.getItemRes(item_config.icon)
        local num = asset_val[2]
        local desc_str = string.format( TI18N("是否消耗<img src='%s' scale=0.4 />%s购买%s星灵积分？\n(同时附赠10次命格抽取)"),one_cost_icon,one_cost_gold,num)
        self.desc_label:setString(desc_str)
    end
end

--==============================--
--desc:刷新运势
--time:2018-09-25 11:58:15
--@return 
--==============================--
function AuguryAlertWindow:createFlashPanel()
	local size = self.main_panel:getContentSize()
	--文字描述
	self.desc_label = createRichLabel(28, Config.ColorData.data_color4[175], cc.p(0.5, 1), cc.p(size.width / 2, 330), 0, 0, 500)
	self.main_panel:addChild(self.desc_label)
	
	self.free_label = createRichLabel(26, Config.ColorData.data_color4[186], cc.p(0, 1), cc.p(135, 240), 0, 0, 500)
	self.main_panel:addChild(self.free_label)
	
	self.free_label:setString(TI18N("注：每日05:00将自动刷新运势"))
	
	local config = Config.StarDivinationData.data_divination_flash
	if not config then return end

	local count = self.ctrl:getModel():getFlashCount() or 0
	local max_count = Config.StarDivinationData.data_divination_flash_length or 0
	count = math.min(count + 1, max_count)
	if not config[count] then return end
	local asset_val = config[count].expend[1]
	if not asset_val then return end
	local item_config = Config.ItemData.data_get_data(asset_val[1])
	if item_config then
		local res = PathTool.getItemRes(item_config.icon)
		local num = asset_val[2]
		local str = string.format(TI18N("是否消耗<img src='%s' scale=0.4 />%s来刷新运势？"), res, num)
		self.desc_label:setString(str)
	end
end

function AuguryAlertWindow:openRootWnd(type)
end

function AuguryAlertWindow:setPanelData()
end

function AuguryAlertWindow:close_callback()
	self.ctrl:openAlertWidnow(false)
	
end
