--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-09-19 19:06:42
-- @description    : 
		-- 花火大会选择烟花界面
---------------------------------
local _controller = PetardActionController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

PetardSelectItemWindow = PetardSelectItemWindow or BaseClass(BaseView)

function PetardSelectItemWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "petard/petard_select_item_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("actionpetard_chose", "actionpetard_chose"), type = ResourcesType.plist},
	}
end

function PetardSelectItemWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(main_container , 1)

	self.close_btn = main_container:getChildByName("close_btn")
	main_container:getChildByName("win_title"):setString(TI18N("燃放烟花"))
	main_container:getChildByName("tips_txt"):setString(TI18N("请选择要燃放的烟花"))
	main_container:getChildByName("num_title"):setString(TI18N("使用数量："))
	self.num_txt = main_container:getChildByName("num_txt")

	self.confirm_btn = main_container:getChildByName("confirm_btn")
	self.confirm_btn:getChildByName("label"):setString(TI18N("确定燃放"))

	self.item_object_list = {}
	for i=1,2 do
		local item_bg = main_container:getChildByName("item_bg_" .. i)
		if item_bg then
			local object = {}
			object.item_bg = item_bg
			object.select_image = item_bg:getChildByName("select_image")
			object.select_image:setVisible(false)
			object.get_btn = item_bg:getChildByName("get_btn")
			object.get_btn:getChildByName("label"):setString(TI18N("获取"))
			object.name_txt = item_bg:getChildByName("name_txt")
			object.desc_txt = item_bg:getChildByName("desc_txt")
			object.item_node = BackPackItem.new(false, true, nil, nil, nil, true)
			object.item_node:setPosition(cc.p(134, 190))
			item_bg:addChild(object.item_node)
			local item_bid_cfg
			if i == 1 then
				item_bid_cfg = Config.HolidayPetardData.data_const["meteor_bid"]
				local firework_rule1_cfg = Config.HolidayPetardData.data_const["firework_rule1"]
				if firework_rule1_cfg then
					object.desc_txt:setString(firework_rule1_cfg.desc)
				end
			else
				item_bid_cfg = Config.HolidayPetardData.data_const["firework_bid"]
				local firework_rule2_cfg = Config.HolidayPetardData.data_const["firework_rule2"]
				if firework_rule2_cfg then
					object.desc_txt:setString(firework_rule2_cfg.desc)
				end
			end
			if item_bid_cfg then
				local item_cfg = Config.ItemData.data_get_data(item_bid_cfg.val)
				if item_cfg then
					local have_num = BackpackController:getInstance():getModel():getItemNumByBid(item_cfg.id)
					object.item_bid = item_cfg.id
					object.have_num = have_num
					object.item_node:setData(item_cfg)
					object.item_node:setNum2(have_num)
					object.name_txt:setString(item_cfg.name)
				end
			end
			_table_insert(self.item_object_list, object)
		end
	end

	self.slider = main_container:getChildByName("slider")-- 滑块
    self.slider:setBarPercent(10, 90)
    self.plus_btn = main_container:getChildByName("plus_btn")
    self.min_btn = main_container:getChildByName("min_btn")
    self.max_btn = main_container:getChildByName("max_btn")
end

function PetardSelectItemWindow:register_event(  )
	registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)

	for i,object in ipairs(self.item_object_list) do
		if object.get_btn then
			registerButtonEventListener(object.get_btn, handler(self, self.onClickGetBtn), true)
		end
		if object.item_bg then
			registerButtonEventListener(object.item_bg, function (  )
				self:onClickItemBg(i)
			end, false)
		end
	end

	self.slider:addEventListener(function ( sender,event_type )
		if event_type == ccui.SliderEventType.percentChanged then
            self:setChoseItemInfoByPercent(self.slider:getPercent())
		end
	end)

	registerButtonEventListener(self.min_btn, function (  )
		local percent = self.slider:getPercent()
        if percent == 0 then return end --已经是最小的了
        if self.cur_chose_num == 0 then return end
        self.cur_chose_num = self.cur_chose_num - 1
        self:setChoseItemInfoByNum(self.cur_chose_num)
	end, true)

	registerButtonEventListener(self.plus_btn, function (  )
		local percent = self.slider:getPercent()
        if percent == 100 then return end --已经是最大的了
        if self.cur_chose_num >= self.cur_item_max_num then return end
        self.cur_chose_num = self.cur_chose_num + 1
        self:setChoseItemInfoByNum(self.cur_chose_num)
	end, true)

	registerButtonEventListener(self.max_btn, function (  )
		local percent = self.slider:getPercent()
        if percent == 100 then return end --已经是最大的了
        if self.cur_chose_num >= self.cur_item_max_num then return end
        self.cur_chose_num = self.cur_item_max_num
        self:setChoseItemInfoByNum(self.cur_chose_num)
	end, true)

	registerButtonEventListener(self.confirm_btn, function (  )
		self:onClickComfirmBtn()
	end, true)
end

function PetardSelectItemWindow:onClickComfirmBtn(  )
	if not self.cur_index then return end
	local object = self.item_object_list[self.cur_index]
	if not object then return end

	if object.have_num > 0 then
		local firework_bid_cfg = Config.HolidayPetardData.data_const["firework_bid"]
		if firework_bid_cfg and firework_bid_cfg.val == object.item_bid then -- 大烟花要切回主城
			if _model:checkCanUseBigPetard() then -- 大烟花有燃放时间限制
				MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene)
				MainSceneController:getInstance():moveToCenterPos()
				MainSceneController:getInstance():showMainSceneEffect(true, 342, nil, self.cur_chose_num or 1)
				_controller:openSelectItemWindow(false)
			end
		else
			_controller:openPetardEffectWindow(true, self.cur_chose_num or 1)
			_controller:openSelectItemWindow(false)
		end
	else
		message(TI18N("道具数量不足"))
	end
end

function PetardSelectItemWindow:setChoseItemInfoByPercent( percent )
	if not self.cur_item_max_num then return end
    local num = math.floor( percent * self.cur_item_max_num * 0.01 )
    self:setChoseItemInfoByNum(num)
end

function PetardSelectItemWindow:setChoseItemInfoByNum( num )
	self.cur_chose_num = num
    local max_num = self.cur_item_max_num or 1
    
    if self.cur_chose_num < 1 then
        self.cur_chose_num = 1
    elseif self.cur_chose_num > max_num then
        self.cur_chose_num = max_num
    end

    local percent = self.cur_chose_num / max_num * 100
    if percent < 1 then --进度条数值区间[1,100]
    	percent = math.ceil(percent)
    end
    self.slider:setPercent(percent)
    self.num_txt:setString(self.cur_chose_num)
end

function PetardSelectItemWindow:onClickGetBtn(  )
	-- 跳转到 93031 活动界面
    local action_ctrl = ActionController:getInstance()
	local tab_vo = action_ctrl:getActionSubTabVo(ActionRankCommonType.exercise_1)
    if tab_vo and action_ctrl.action_operate and action_ctrl.action_operate.tab_list[tab_vo.bid] then
        action_ctrl.action_operate:handleSelectedTab(action_ctrl.action_operate.tab_list[tab_vo.bid])
        _controller:openSelectItemWindow(false)
    elseif tab_vo then
    	action_ctrl:openActionMainPanel(true, MainuiConst.icon.festival, tab_vo.bid)
    	_controller:openSelectItemWindow(false)
    else
        message(TI18N("该活动已结束"))
    end
end

function PetardSelectItemWindow:onClickItemBg( index )
	if self.cur_index and self.cur_index == index then return end
	for i,object in ipairs(self.item_object_list) do
		if object.select_image then
			object.select_image:setVisible(i == index)
		end
	end

	self.cur_index = index
	self:updateChoseItemInfo()
	self:setChoseItemInfoByNum(1)
end

function PetardSelectItemWindow:updateChoseItemInfo(  )
	if not self.cur_index or not self.item_object_list then return end
	local cur_object = self.item_object_list[self.cur_index]
	if not cur_object then return end

	self.cur_item_max_num = cur_object.have_num
	if not self.cur_item_max_num or self.cur_item_max_num <= 0 then
		self.cur_item_max_num = 1
	end
end

function PetardSelectItemWindow:onClickCloseBtn(  )
	_controller:openSelectItemWindow(false)
end

function PetardSelectItemWindow:openRootWnd(  )
	local default_index = self:getDefaultIndex()
	self:onClickItemBg(default_index)
end

function PetardSelectItemWindow:getDefaultIndex(  )
	local default_index = 1
	local object = self.item_object_list[2]
	if object and object.have_num > 0 then
		default_index = 2
	end
	return default_index
end

function PetardSelectItemWindow:close_callback(  )
	for k,object in pairs(self.item_object_list) do
		if object.item_node then
			object.item_node:DeleteMe()
			object.item_node = nil
		end
	end

	_controller:openSelectItemWindow(false)
end
