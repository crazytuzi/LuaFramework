--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-28 21:27:06
-- @description    : 
		-- 神装一键出售
---------------------------------
BackPackSellHolyWindow = BackPackSellHolyWindow or BaseClass(BaseView)

local _controller = BackpackController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

function BackPackSellHolyWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini
    self.layout_name = "backpack/backpack_sell_holy"
end

function BackPackSellHolyWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)

    self.cancel_btn = self.container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("取消"))

    self.confirm_btn = self.container:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("一键出售"))

    self.container:getChildByName("win_title"):setString(TI18N("出售"))
    self.container:getChildByName("sell_title"):setString(TI18N("请选择一键出售条件:"))

    self.btn_star_1 = self.container:getChildByName("btn_star_1")
    self.btn_star_1:getChildByName("name"):setString(TI18N("1星"))
    self.btn_star_1:setSelected(false)

    self.btn_star_2 = self.container:getChildByName("btn_star_2")
    self.btn_star_2:getChildByName("name"):setString(TI18N("2星"))
    self.btn_star_2:setSelected(false)

    self.btn_star_3 = self.container:getChildByName("btn_star_3")
    self.btn_star_3:getChildByName("name"):setString(TI18N("3星"))
    self.btn_star_3:setSelected(false)

    self.btn_star_4 = self.container:getChildByName("btn_star_4")
    self.btn_star_4:getChildByName("name"):setString(TI18N("4星"))
    self.btn_star_4:setSelected(false)

    self.btn_star_5 = self.container:getChildByName("btn_star_5")
    self.btn_star_5:getChildByName("name"):setString(TI18N("5星"))
    self.btn_star_5:setSelected(false)

    self.btn_step_1 = self.container:getChildByName("btn_step_1")
    self.btn_step_1:getChildByName("name"):setString(TI18N("凡品"))
    self.btn_step_1:setSelected(false)

    self.btn_step_2 = self.container:getChildByName("btn_step_2")
    self.btn_step_2:getChildByName("name"):setString(TI18N("良品"))
    self.btn_step_2:setSelected(false)

    self.btn_step_3 = self.container:getChildByName("btn_step_3")
    self.btn_step_3:getChildByName("name"):setString(TI18N("极品"))
    self.btn_step_3:setSelected(false)
end

function BackPackSellHolyWindow:register_event(  )
	registerButtonEventListener(self.cancel_btn, function (  )
		_controller:openQuickSellHolyWindow(false)
	end, true, 2)

	registerButtonEventListener(self.confirm_btn, function (  )
		self:onClickQuickSellBtn()
	end, true, 1)

	self.btn_star_1:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_sell_star_1, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            if self:checkIsCanCancelSelect(1) then
            	SysEnv:getInstance():set(SysEnv.keys.holy_sell_star_1, false, false)
            else
            	self.btn_star_1:setSelected(true)
            end
        end
    end)

    self.btn_star_2:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_sell_star_2, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then
            playButtonSound2()
            if self:checkIsCanCancelSelect(1) then
            	SysEnv:getInstance():set(SysEnv.keys.holy_sell_star_2, false, false) 
            else
            	self.btn_star_2:setSelected(true)
            end
        end
    end)

    self.btn_star_3:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_sell_star_3, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            if self:checkIsCanCancelSelect(1) then
            	SysEnv:getInstance():set(SysEnv.keys.holy_sell_star_3, false, false) 
            else
            	self.btn_star_3:setSelected(true)
            end
        end
    end)

    self.btn_star_4:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_sell_star_4, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            if self:checkIsCanCancelSelect(1) then
            	SysEnv:getInstance():set(SysEnv.keys.holy_sell_star_4, false, false) 
            else
            	self.btn_star_4:setSelected(true)
            end
        end
    end)

    self.btn_star_5:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_sell_star_5, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            if self:checkIsCanCancelSelect(1) then
                SysEnv:getInstance():set(SysEnv.keys.holy_sell_star_5, false, false) 
            else
                self.btn_star_5:setSelected(true)
            end
        end
    end)

    self.btn_step_1:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_sell_step_1, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            if self:checkIsCanCancelSelect(2) then
            	SysEnv:getInstance():set(SysEnv.keys.holy_sell_step_1, false, false)
            else
            	self.btn_step_1:setSelected(true)
            end 
        end
    end)

    self.btn_step_2:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_sell_step_2, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            if self:checkIsCanCancelSelect(2) then
            	SysEnv:getInstance():set(SysEnv.keys.holy_sell_step_2, false, false)
            else
            	self.btn_step_2:setSelected(true)
            end 
        end
    end)

    self.btn_step_3:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_sell_step_3, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            if self:checkIsCanCancelSelect(2) then
            	SysEnv:getInstance():set(SysEnv.keys.holy_sell_step_3, false, false)
            else
            	self.btn_step_3:setSelected(true)
            end 
        end
    end)
end

function BackPackSellHolyWindow:openRootWnd(  )
	self:setData()
end

function BackPackSellHolyWindow:setData(  )
	local star_1 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_1, true)
	self.btn_star_1:setSelected(star_1)

	local star_2 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_2, false)
	self.btn_star_2:setSelected(star_2)

	local star_3 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_3, false)
	self.btn_star_3:setSelected(star_3)

	local star_4 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_4, false)
	self.btn_star_4:setSelected(star_4)

    local star_5 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_5, false)
    self.btn_star_5:setSelected(star_5)

	local step_1 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_step_1, true)
	self.btn_step_1:setSelected(step_1)

	local step_2 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_step_2, false)
	self.btn_step_2:setSelected(step_2)

	local step_3 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_step_3, false)
	self.btn_step_3:setSelected(step_3)
end

-- 判断是否可以取消勾选
function BackPackSellHolyWindow:checkIsCanCancelSelect( _type )
	if _type == 1 then
		local temp_list = {}
		local star_1 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_1, true)
		_table_insert(temp_list, star_1)
		local star_2 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_2, false)
		_table_insert(temp_list, star_2)
		local star_3 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_3, false)
		_table_insert(temp_list, star_3)
		local star_4 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_4, false)
		_table_insert(temp_list, star_4)
        local star_5 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_5, false)
        _table_insert(temp_list, star_5)
		local chose_num = 0 
		for k,v in pairs(temp_list) do
			if v then
				chose_num = chose_num + 1
			end
		end
		if chose_num <= 1 then
			message(TI18N("请至少选择一种星数条件"))
			return false
		end
	else
		local temp_list = {}
		local step_1 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_step_1, true)
		_table_insert(temp_list, step_1)
		local step_2 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_step_2, false)
		_table_insert(temp_list, step_2)
		local step_3 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_step_3, false)
		_table_insert(temp_list, step_3)
		local chose_num = 0 
		for k,v in pairs(temp_list) do
			if v then
				chose_num = chose_num + 1
			end
		end
		if chose_num <= 1 then
			message(TI18N("请至少选择一种品质条件"))
			return false
		end
	end
	return true
end

function BackPackSellHolyWindow:onClickQuickSellBtn(  )
	local star_chose_status = {}
	local star_1 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_1, true)
	_table_insert(star_chose_status, star_1)
	local star_2 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_2, false)
	_table_insert(star_chose_status, star_2)
	local star_3 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_3, false)
	_table_insert(star_chose_status, star_3)
	local star_4 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_4, false)
	_table_insert(star_chose_status, star_4)
    local star_5 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_star_5, false)
    _table_insert(star_chose_status, star_5)

	local step_chose_status = {}
	local step_1 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_step_1, true)
	step_chose_status[0] = step_1
	local step_2 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_step_2, false)
	step_chose_status[1] = step_2
	local step_3 = SysEnv:getInstance():getBool(SysEnv.keys.holy_sell_step_3, false)
	step_chose_status[2] = step_3

	local sell_holy_list = {}
	local all_holy_list = BackpackController:getInstance():getModel():getAllBackPackArray(BackPackConst.item_tab_type.HOLYEQUIPMENT)
	for k,good_vo in pairs(all_holy_list) do
		if star_chose_status[good_vo.eqm_star] and step_chose_status[good_vo.eqm_jie] then
			_table_insert(sell_holy_list, {item_id = good_vo.id})
		end
	end
	if next(sell_holy_list) ~= nil then
		local str = string.format(TI18N("本次一共出售<div fontcolor=#b35800>%d</div>件神装，可获得以下资源（已包含返还的60%%的洗练消耗），是否确定出售？"), #sell_holy_list)
        HeroController:getInstance():openHeroResetOfferPanel(true, sell_holy_list, false, function()
                local is_in_plan = false -- 是否在神装方案中
                for k,v in pairs(sell_holy_list) do
                    if HeroController:getInstance():getModel():checkHolyEquipmentPalnByItemID(v.item_id) then
                        is_in_plan = true
                        break
                    end
                end
                if is_in_plan then
                    local tips_str = TI18N("选中的对象中含有<div fontColor=#d95014 >已在方案</div>的神装，继续出售将会清除这些神装在方案中的配置，是否继续？")
                    CommonAlert.show(tips_str, TI18N("确定"), function()
                        HeroController:getInstance():sender11089(sell_holy_list)
                    end, TI18N("取消"), nil, CommonAlert.type.rich)
                else
                    HeroController:getInstance():sender11089(sell_holy_list)
                end
        end, HeroConst.ResetType.eHolyEquipSell, str)
        _controller:openQuickSellHolyWindow(false)
    else
    	message(TI18N("没有符合要求的神装"))
	end
end

function BackPackSellHolyWindow:close_callback(  )
    SysEnv:getInstance():save()
	_controller:openQuickSellHolyWindow(false)
end