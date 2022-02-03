----------------------------------
-- @Author: zj@qqg.com
-- @Date:   2019-05-05 10:40:13
-- @Description:	一键出售装备
----------------------------------
BackPackSellEquipWindow = BackPackSellEquipWindow or BaseClass(BaseView)

local string_format = string.format
local table_insert = table.insert
local controller = BackpackController:getInstance()
local model = BackpackController:getInstance():getModel()
local EQUIP_QUALITY = 5 --品质数量
local EQUIP_STAR = 6 	--星级数量

function BackPackSellEquipWindow:__init()
	self.win_type = WinType.Mini
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "backpack/backpack_sell_equip"

    self.quality_btn_list = {}  --品质按钮列表
    self.star_btn_list = {} 	--星级按钮列表
end

function BackPackSellEquipWindow:open_callback()
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

    self.container:getChildByName("img_title_bg_1"):getChildByName("txt_title"):setString(TI18N("装备品级"))
    self.container:getChildByName("img_title_bg_2"):getChildByName("txt_title"):setString(TI18N("装备星级"))

    self.btn_all = self.container:getChildByName("btn_all")
    self.btn_all:getChildByName("name"):setString(TI18N("全选"))
    self.btn_all:setSelected(false)

    for i=1,EQUIP_QUALITY do
    	local btn = self.container:getChildByName(string_format("btn_quality_%d",i))
		btn:setSelected(false)
		btn:getChildByName("name"):setString(BackPackConst.quality_name[i])
		table_insert(self.quality_btn_list, i, btn)
    end

    for i=1,EQUIP_STAR do
    	local btn = self.container:getChildByName(string_format("btn_star_%d",i))
		btn:setSelected(false)
		btn:getChildByName("name"):setString(BackPackConst.star_name[i])
		table_insert(self.star_btn_list, i, btn)
    end
end

function BackPackSellEquipWindow:register_event()
	registerButtonEventListener(self.cancel_btn, function()
		controller:openQuickSellEquipWindow(false)
	end, true, 2)

	registerButtonEventListener(self.confirm_btn, function()
		self:onClickQuickSellBtn()
	end, true, 1)

	self:registerCheckBoxEvent(self.btn_all, "equip_sell_all", BackPackConst.cb_type.all)

	if not self.quality_btn_list then return end
	for i=1,EQUIP_QUALITY do
		local btn = self.quality_btn_list[i]
		local sys_str = string_format("equip_sell_quality_%d",i)
		if btn then
			self:registerCheckBoxEvent(btn, sys_str, BackPackConst.cb_type.quality)
		end
	end

	if not self.star_btn_list then return end
	for i=1,EQUIP_STAR do
		local btn = self.star_btn_list[i]
		local sys_str = string_format("equip_sell_star_%d",i)
		if btn then
			self:registerCheckBoxEvent(btn, sys_str, BackPackConst.cb_type.star)
		end
	end
end

function BackPackSellEquipWindow:openRootWnd()
	self:setData()
end

--每次都按默认规则初始化
function BackPackSellEquipWindow:setData()
    local sell_all_status = SysEnv:getInstance():getBool(SysEnv.keys.equip_sell_all, false)
	self.btn_all:setSelected(sell_all_status)

	for i=1,EQUIP_QUALITY do
		local btn = self.quality_btn_list[i]
		local sys_str = string_format("equip_sell_quality_%d",i)
		if btn then
			local status = false
			if i == 1 then
				status = SysEnv:getInstance():getBool(SysEnv.keys[sys_str], true)
			elseif i == 2 then
				local role_vo = RoleController:getInstance():getRoleVo()
				local limit_lev = Config.PackageData.data_backpack_cost.limit_lev
			    if limit_lev then
					if role_vo.lev >= limit_lev.val then
			    		status = SysEnv:getInstance():getBool(SysEnv.keys[sys_str], "no_val")
			    		if status == "no_val" then
							status = true
							SysEnv:getInstance():set(SysEnv.keys[sys_str], status, false)
						end
			    	else
			    		status = SysEnv:getInstance():getBool(SysEnv.keys[sys_str], false)
			    	end
			    end
			else
				status = SysEnv:getInstance():getBool(SysEnv.keys[sys_str], false)
			end
			btn:setSelected(status)
		end
	end

	for i=1,EQUIP_STAR do
		local btn = self.star_btn_list[i]
		local sys_str = string_format("equip_sell_star_%d",i)
		if btn then
			local status = false
			if i == 1 or i == 2 then
				status = SysEnv:getInstance():getBool(SysEnv.keys[sys_str], "no_val")
				if status == "no_val" then
					status = true
					SysEnv:getInstance():set(SysEnv.keys[sys_str], status, false)
				end
			else
				status = SysEnv:getInstance():getBool(SysEnv.keys[sys_str], false)
			end
			btn:setSelected(status)
		end
	end
end

-- 判断是否可以取消勾选
function BackPackSellEquipWindow:checkIsCanCancelSelect(select_type, is_end_check)
	local temp_count = 0
	local temp_select_status = {}
	is_end_check = is_end_check or false
	if select_type == BackPackConst.cb_type.quality then
		local status = SysEnv:getInstance():getBool(SysEnv.keys.equip_sell_quality_1, true)
		table_insert(temp_select_status, status)
		for i=2,EQUIP_QUALITY do
			local sys_str = string_format("equip_sell_quality_%d",i)
			status = SysEnv:getInstance():getBool(SysEnv.keys[sys_str], false)
			table_insert(temp_select_status, status)
		end
		for k,v in pairs(temp_select_status) do
			if v then
				temp_count = temp_count + 1
			end
		end
		local target_num = 2
		if is_end_check then
			target_num = 1
		end
		if temp_count < target_num then
			message(TI18N("请至少选择一种品级与星级"))
			return false
		end
	elseif select_type == BackPackConst.cb_type.star then
		local status = SysEnv:getInstance():getBool(SysEnv.keys.equip_sell_star_1, true)
		table_insert(temp_select_status, status)
		for i=2,EQUIP_STAR do
			local sys_str = string_format("equip_sell_star_%d",i)
			status = SysEnv:getInstance():getBool(SysEnv.keys[sys_str], false)
			table_insert(temp_select_status, status)
		end
		for k,v in pairs(temp_select_status) do
			if v then
				temp_count = temp_count + 1
			end
		end
		local target_num = 2
		if is_end_check then
			target_num = 1
		end
		if temp_count < target_num then
			message(TI18N("请至少选择一种品级与星级"))
			return false
		end
	end
	return true, temp_select_status, temp_count
end

--全选时设置选项框状态
function BackPackSellEquipWindow:setSpecialBtnSelected(select_type, status, sys_str)
	status = status or false
	if select_type == BackPackConst.cb_type.all then
		if not status then --取消全选，则恢复默认选中状态
			self:setData()
		else
		    for i=1,EQUIP_QUALITY do
				local temp_str = string_format("equip_sell_quality_%d",i)
				self.quality_btn_list[i]:setSelected(status)
				SysEnv:getInstance():set(SysEnv.keys[temp_str], status, false)
			end
			for i=1,EQUIP_STAR do
				local temp_str = string_format("equip_sell_star_%d",i)
				self.star_btn_list[i]:setSelected(status)
				SysEnv:getInstance():set(SysEnv.keys[temp_str], status, false)
			end
		end
	elseif select_type == BackPackConst.cb_type.quality then
		if not status then return end --若为取消选中则不处理
		
		local star_num = 2 --选中星级数量
		local base_status = SysEnv:getInstance():getBool(SysEnv.keys.equip_sell_quality_1, false)
		if not base_status then
			base_status = SysEnv:getInstance():getBool(SysEnv.keys.equip_sell_quality_2, false)
		end
		local purple_status = SysEnv:getInstance():getBool(SysEnv.keys.equip_sell_quality_3, false)

		local temp_select_status
		if sys_str == "equip_sell_quality_3" then
			star_num = 3
			temp_select_status = purple_status
		elseif sys_str == "equip_sell_quality_1" or sys_str == "equip_sell_quality_2" then
			temp_select_status = base_status
		end
		--若为蓝色或绿色，默认选中1、2星；若为紫色，默认选中1、2、3星
		if temp_select_status then
			for i=1,star_num do
				local temp_str = string_format("equip_sell_star_%d",i)
				self.star_btn_list[i]:setSelected(true)
				SysEnv:getInstance():set(SysEnv.keys[temp_str], true, false)
			end
		end
	end
end

--注册选项框事件
function BackPackSellEquipWindow:registerCheckBoxEvent(btn, sys_str, select_type)
	if not btn or not sys_str or not select_type then return end
	btn:addEventListener(function(sender,event_type)
	    if event_type == ccui.CheckBoxEventType.selected then
	        playButtonSound2()
	        SysEnv:getInstance():set(SysEnv.keys[sys_str], true, false)
	        self:setSpecialBtnSelected(select_type, true, sys_str)
	    elseif event_type == ccui.CheckBoxEventType.unselected then 
	        playButtonSound2()
	        local status, _, count = self:checkIsCanCancelSelect(select_type)
	        if not status then
	        	btn:setSelected(true)
	        else
	        	SysEnv:getInstance():set(SysEnv.keys[sys_str], false, false)
	        	self:setSpecialBtnSelected(select_type, false, sys_str)

	        	--如果已经全选后，取消品质/星级任一选择后则取消全选
	        	if count == 2 then return end
		        local _, _, tempcount = self:checkIsCanCancelSelect(select_type)
		        if not tempcount then return end
	        	if (select_type == BackPackConst.cb_type.quality and tempcount < EQUIP_QUALITY) or
	        		(select_type == BackPackConst.cb_type.star and tempcount < EQUIP_STAR) then
	        		local status = SysEnv:getInstance():getBool(SysEnv.keys.equip_sell_all, false)
					if status then
						self.btn_all:setSelected(false)
						SysEnv:getInstance():set(SysEnv.keys.equip_sell_all, false, false)
					end
	        	end
	        end
	    end
    end)
end

function BackPackSellEquipWindow:onClickQuickSellBtn()
	local status, quality_chose_status  = self:checkIsCanCancelSelect(BackPackConst.cb_type.quality, true)
	if not status then return end

	local star_status, star_chose_status = self:checkIsCanCancelSelect(BackPackConst.cb_type.star, true)
	if not star_status then return end

	local exist_specail_item = false --是否存在可售出的红装或橙装
	local sell_equip_list = {}
	local all_equip_list = model:getAllBackPackArray(BackPackConst.item_tab_type.EQUIPS)
	for k,good_vo in pairs(all_equip_list) do
		if star_chose_status[good_vo.eqm_star] and quality_chose_status[good_vo.quality] then
			if good_vo.quality == BackPackConst.quality.orange or good_vo.quality == BackPackConst.quality.red then
				exist_specail_item = true
			end
			table_insert(sell_equip_list, {id = good_vo.id, bid = good_vo.base_id, num = good_vo.quantity})
		end
	end

	--选择橙装或红装需要倒计时提示
	local is_show_tips = false
	if exist_specail_item and (quality_chose_status[BackPackConst.quality.orange] or 
		quality_chose_status[BackPackConst.quality.red]) then
		is_show_tips = true
	end

	--物品数量
	local item_count = 0
	if next(sell_equip_list) ~= nil then
		for k,v in ipairs(sell_equip_list) do
			if v and v.num then
				item_count = item_count + v.num
			end
		end
	end

	if next(sell_equip_list) ~= nil then
		--请求售出获得
		controller:sender10521(BackPackConst.Bag_Code.EQUIPS, sell_equip_list)
		controller:openSellConfirmWindow(true, function()
            --售出装备
            controller:sender10522(BackPackConst.Bag_Code.EQUIPS, sell_equip_list)
        end, BackPackConst.Bag_Code.EQUIPS, is_show_tips, item_count)
        controller:openQuickSellEquipWindow(false)
    else
    	message(TI18N("没有符合要求的装备"))
	end
end

function BackPackSellEquipWindow:close_callback()
	SysEnv:getInstance():save()
	controller:openQuickSellEquipWindow(false)
end