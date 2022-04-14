EquipRefineView = EquipRefineView or class("EquipRefineView",BaseItem)
local EquipRefineView = EquipRefineView

function EquipRefineView:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "EquipRefineView"
	self.layer = layer

	self.model = EquipRefineModel:GetInstance()
	self.item_list = {}
	self.attr_list = {}
	self.now_attr_list = {}
	self.lock_tgs = {}
	self.touch_imgs = {}
	self.events = {}
	self.global_events = {}
	self.lock_cost_num = 0
	self.bind_data_events = {}
	self.show_effect = false
	self.ui_effects = {}
	self.ui_effects2 = {}
	EquipRefineView.super.Load(self)
end

function EquipRefineView:dctor()
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
		self.item_list[i] = nil
	end
	for i=1, #self.attr_list do
		self.attr_list[i] = nil
	end
	for i=1, #self.now_attr_list do
		self.now_attr_list[i] = nil
	end
	for i=1, #self.lock_tgs do
		self.lock_tgs[i] = nil
	end
	for i=1, #self.touch_imgs do
		self.touch_imgs[i] = nil
	end
	if self.goodsitem then
		self.goodsitem:destroy()
		self.goodsitem = nil 
	end
	if self.goodsitem1 then
		self.goodsitem1:destroy()
		self.goodsitem1 = nil
	end
	if self.goodsitem2 then
		self.goodsitem2:destroy()
		self.goodsitem2 = nil
	end
	if self.goodsitem3 then
		self.goodsitem3:destroy()
		self.goodsitem3 = nil
	end
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
	for _, v in pairs(self.ui_effects) do
		v:destroy()
	end
	self.ui_effects = nil
	for _, v in pairs(self.ui_effects2) do
		v:destroy()
	end
	self.ui_effects2 = nil
	self.model.select_itemid = 0
	self.model:RemoveTabListener(self.events)
	GlobalEvent:RemoveTabListener(self.global_events)
	for k, v in pairs(self.bind_data_events) do
		RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(v)
	end
end

function EquipRefineView:LoadCallBack()
	self.nodes = {
		"leftInfo/itemScrollView/Viewport/itemContent","leftInfo/itemScrollView/Viewport/itemContent/EquipRefineItem",
		"rightInfo","rightInfoEmpty","rightInfo/Image/icon1","rightInfo/Image/icon2","rightInfo/Image/icon3",
		"rightInfo/icon/equipicon","rightInfo/icon/score","rightInfo/freecount","rightInfo/tips",
		"rightInfo/preattr/Image1/attr1","rightInfo/preattr/Image2/attr2","rightInfo/preattr/Image3/attr3",
		"rightInfo/preattr/Image4/attr4","rightInfo/preattr/Image5/attr5","rightInfo/nowattr/nowImage1/nowattr1",
		"rightInfo/nowattr/nowImage2/nowattr2","rightInfo/nowattr/nowImage3/nowattr3","rightInfo/nowattr/nowImage4/nowattr4",
		"rightInfo/nowattr/nowImage5/nowattr5","rightInfo/locks/lock1","rightInfo/locks/lock2","rightInfo/locks/lock3",
		"rightInfo/locks/lock4","rightInfo/locks/lock5","rightInfo/refinebackbtn","rightInfo/refinebtn",
		"rightInfo/nowattr/nowImage1/touchimage1","rightInfo/nowattr/nowImage2/touchimage2","rightInfo/nowattr/nowImage3/touchimage3",
		"rightInfo/nowattr/nowImage4/touchimage4","rightInfo/nowattr/nowImage5/touchimage5","rightInfo/Image/icon2/noequipbg",
	}
	self:GetChildren(self.nodes)
	self.EquipRefineItem_gameobject = self.EquipRefineItem.gameObject
	SetVisible(self.EquipRefineItem_gameobject, false)
	self.attr1 = GetText(self.attr1)
	self.attr2 = GetText(self.attr2)
	self.attr3 = GetText(self.attr3)
	self.attr4 = GetText(self.attr4)
	self.attr5 = GetText(self.attr5)
	table.insert(self.attr_list, self.attr1)
	table.insert(self.attr_list, self.attr2)
	table.insert(self.attr_list, self.attr3)
	table.insert(self.attr_list, self.attr4)
	table.insert(self.attr_list, self.attr5)
	self.nowattr1 = GetText(self.nowattr1)
	self.nowattr2 = GetText(self.nowattr2)
	self.nowattr3 = GetText(self.nowattr3)
	self.nowattr4 = GetText(self.nowattr4)
	self.nowattr5 = GetText(self.nowattr5)
	table.insert(self.now_attr_list, self.nowattr1)
	table.insert(self.now_attr_list, self.nowattr2)
	table.insert(self.now_attr_list, self.nowattr3)
	table.insert(self.now_attr_list, self.nowattr4)
	table.insert(self.now_attr_list, self.nowattr5)
	self.score = GetText(self.score)
	self.lock1_tg = GetToggle(self.lock1)
	self.lock2_tg = GetToggle(self.lock2)
	self.lock3_tg = GetToggle(self.lock3)
	self.lock4_tg = GetToggle(self.lock4)
	self.lock5_tg = GetToggle(self.lock5)
	table.insert(self.lock_tgs, self.lock1_tg)
	table.insert(self.lock_tgs, self.lock2_tg)
	table.insert(self.lock_tgs, self.lock3_tg)
	table.insert(self.lock_tgs, self.lock4_tg)
	table.insert(self.lock_tgs, self.lock5_tg)
	self.freecount = GetText(self.freecount)
	table.insert(self.touch_imgs, self.touchimage1)
	table.insert(self.touch_imgs, self.touchimage2)
	table.insert(self.touch_imgs, self.touchimage3)
	table.insert(self.touch_imgs, self.touchimage4)
	table.insert(self.touch_imgs, self.touchimage5)

	self:AddEvent()

	self:LoadItems()
	self:UpdateView()
end

function EquipRefineView:AddEvent()
	local function call_back(slot)
		self.select_slot = slot
		self.show_effect = false
		self:UpdateView()
	end
	self.events[#self.events+1] = self.model:AddListener(EquipEvent.SelectRefineItem, call_back)

	local function call_back()
		self:ShowMateria2()
	end
	self.events[#self.events+1] = self.model:AddListener(EquipEvent.SelectRefineMateria, call_back)

	local function call_back()
		self:UpdateView()
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.UpdateRefineInfo, call_back)

	local function call_back()
		self:ShowMateria()
		self:ShowMateria2()
		self:UpdateLockNum()
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

	local function call_back()
    	self:ShowRedDot()
    end
    self.bind_data_events[#self.bind_data_events+1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", call_back)
    self.bind_data_events[#self.bind_data_events+1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("vip", call_back)

	local function call_back(target,x,y)
		self:ActiveHole(1)
	end
	AddClickEvent(self.touchimage1.gameObject,call_back)

	local function call_back(target,x,y)
		self:ActiveHole(2)
	end
	AddClickEvent(self.touchimage2.gameObject,call_back)

	local function call_back(target,x,y)
		self:ActiveHole(3)
	end
	AddClickEvent(self.touchimage3.gameObject,call_back)

	local function call_back(target,x,y)
		self:ActiveHole(4)
	end
	AddClickEvent(self.touchimage4.gameObject,call_back)

	local function call_back(target,x,y)
		self:ActiveHole(5)
	end
	AddClickEvent(self.touchimage5.gameObject,call_back)

	local function call_back(target, value)
		if value then
			if not self:CheckLockHole(self.lock1_tg, 1) then
				return
			end
		end
		self.model:UpdateLock(self.select_slot, 1, value)
		--self:RefresLockToggle()
		self:UpdateLockNum()
	end
	AddValueChange(self.lock1.gameObject, call_back)

	local function call_back(target, value)
		if value then
			if not self:CheckLockHole(self.lock2_tg, 2) then
				return
			end
		end
		self.model:UpdateLock(self.select_slot, 2, value)
		--self:RefresLockToggle()
		self:UpdateLockNum()
	end
	AddValueChange(self.lock2.gameObject, call_back)

	local function call_back(target, value)
		if value then
			if not self:CheckLockHole(self.lock3_tg, 3) then
				return
			end
		end
		self.model:UpdateLock(self.select_slot, 3, value)
		--self:RefresLockToggle()
		self:UpdateLockNum()
	end
	AddValueChange(self.lock3.gameObject, call_back)

	local function call_back(target, value)
		if value then
			if not self:CheckLockHole(self.lock4_tg, 4) then
				return
			end
		end
		self.model:UpdateLock(self.select_slot, 4, value)
		--self:RefresLockToggle()
		self:UpdateLockNum()
	end
	AddValueChange(self.lock4.gameObject, call_back)

	local function call_back(target, value)
		if value then
			if not self:CheckLockHole(self.lock5_tg, 5) then
				return
			end
		end
		self.model:UpdateLock(self.select_slot, 5, value)
		--self:RefresLockToggle()
		self:UpdateLockNum()
	end
	AddValueChange(self.lock5.gameObject, call_back)

	local function call_back(target,x,y)
		lua_panelMgr:GetPanelOrCreate(EquipRefineSelectPanel):Open()
	end
	AddClickEvent(self.noequipbg.gameObject,call_back)

	local function call_back(target,x,y)
		if not self:IsCanRefine() then
			return Notify.ShowText("Not equipped gears yet, fail to polish")
		end
		if self:IsHaveRareAttr() then
			local message = "You have got rare attribute, polish without lock?"
			Dialog.ShowTwo("Tip",message,"Confirm",handler(self,self.EquipRefine), nil, nil, nil, nil, "Don't notice me again today", nil, nil, self.__cname)
		else
			self:EquipRefine()
		end
	end
	AddClickEvent(self.refinebtn.gameObject,call_back)

	local function call_back(target,x,y)
		lua_panelMgr:GetPanelOrCreate(EquipRefineSelectPanel):Open()
	end
	AddClickEvent(self.icon2.gameObject,call_back)

	local function call_back(target,x,y)
		if not self:IsCanRefine() then
			return Notify.ShowText("Not equipped gears yet, fail to restore")
		end
		local prefineslot = self.model.slots[self.select_slot]
		if table.nums(prefineslot.old_holes) == 0 or table.nums(prefineslot.old_holes) ~= table.nums(prefineslot.holes) then
			return Notify.ShowText("There are unpolished slots, unable to reset")
		end
		local name = Config.db_item[self.cost_id].name
		local need_num = 0
		if self.model.free_count >= self.total_count then
		 	need_num = self.cost_num
		else
			need_num = 0
		end
		local message1 = string.format("Are you sure to use %s %s to restore all attributes of this equipment to the previous one?", need_num, name)
		local message2 = "<color=#2cc1ff>(Same items of the last refinery will be used. If you are using advanced refinery, then no advanced refinery gems will be used)</color>"
		--Dialog.ShowTwo("提示",message,"确定",handler(self,self.EquipRefineBack))

		local data  = {}
		data.tip_type = 1
		data.message1 = message1
		data.message2 = message2

		data.ok_func = function()
			self:EquipRefineBack()
		end

		local data_param = {}
		data_param["item_id"] = self.cost_id;
		data_param["can_click"] = true;
	
		--拥有数量
		local have = BagController:GetInstance():GetItemListNum(self.cost_id)
		--拥有文本颜色
		local color = ColorUtil.GetColor(ColorUtil.ColorType.Green)
		if need_num > have then
			color = ColorUtil.GetColor(ColorUtil.ColorType.Red)
		end
		have = string.format("<color=#%s>%s</color>",color,have)
		
		data_param["num"] = have.."/"..need_num
		data.param = data_param

		lua_panelMgr:GetPanelOrCreate(ComIconTip):Open(data);

	end
	AddClickEvent(self.refinebackbtn.gameObject,call_back)

	local function call_back(target,x,y)
		ShowHelpTip(HelpConfig.Equip.EquipRefine, true)
	end
	AddClickEvent(self.tips.gameObject,call_back)
end

function EquipRefineView:IsCanRefine()
	local prefineslot = self.model.slots[self.select_slot]
	local puton = EquipModel:GetInstance():GetEquipBySlot(self.select_slot)
	if not puton or not prefineslot then
		return false
	end
	return true
end

function EquipRefineView:EquipRefine()
	if self.lock_cost_num > 0 then
		local had_num = BagController:GetInstance():GetItemListNum(self.lock_cost_id)
		if had_num < self.lock_cost_num then
			return Notify.ShowText("Insufficient items")
		end
	end
	--免费洗练不允许特殊洗练
	--[[if self.model.free_count < self.total_count then
		if self.model.select_itemid > 0 then
			local num = BagController:GetInstance():GetItemListNum(self.model.select_itemid)
			if num <= 0 then
				return Notify.ShowText("特殊洗练石道具不足")
			end
			return Notify.ShowText("免费洗练次数，不可使用特殊洗练，请先卸下特殊洗练石")
		end
	end--]]
	local had_num = BagController:GetInstance():GetItemListNum(self.cost_id)
	if self.model.free_count >= self.total_count and had_num < self.cost_num then
		return Notify.ShowText("Insufficient items")
	end
	if not self:CheckAttr() then
		return
	end
	local locks = {}
	for i=1, #self.lock_tgs do
		if self.lock_tgs[i].isOn then
			locks[#locks+1] = i
		end
	end
	local prefineslot = self.model.slots[self.select_slot]
	if #locks >= table.nums(prefineslot.holes) then
		return Notify.ShowText("Unable to lock all")
	end
	self.show_effect = true
	EquipController:GetInstance():RequestRefine(self.select_slot, self.model.select_itemid, locks)
end

--是否有珍稀属性，无暇洗练石和珍稀永恒洗练石不需要判断
function EquipRefineView:IsHaveRareAttr()
	local prefineslot = self.model.slots[self.select_slot]
	local holes = prefineslot.holes
	local has_rare = false
	for hole, prefine in pairs(holes) do
		if not self.lock_tgs[hole].isOn and prefine.color >= enum.COLOR.COLOR_ORANGE then
			has_rare = true
			break
		end
	end
	local select_itemid = self.model.select_itemid
	local max_itemid = self.model.red_max_itemid
	local pink_itemid = self.model.pink_itemid
	if has_rare and select_itemid ~= max_itemid and select_itemid ~= pink_itemid then
		return true
	end
	return false
end

--检查属性
function EquipRefineView:CheckAttr()
	local prefineslot = self.model.slots[self.select_slot]
	--洗红满，必须要有红色属性
	if self.model.select_itemid == self.model.red_max_itemid then
		local can_refine = false
		local itemname = Config.db_item[self.model.red_max_itemid].name
		local holes = prefineslot.holes
		local num = 0
		local hole = 0
		for k, prefine in pairs(holes) do
			if prefine.color == enum.COLOR.COLOR_RED then
				can_refine = true
			end
			if not self.lock_tgs[k].isOn then
				hole = k
				num = num + 1
			end
		end
		if can_refine then
			if num ~= 1 or prefineslot.holes[hole].color ~= enum.COLOR.COLOR_RED then
				local message = string.format("%s can only refine a red attribute to the max, please lock other attributes and continue refining", itemname)
				Dialog.ShowOne("Tip",message,"Confirm")
				return false
			end
		else
			Notify.ShowText(string.format("No red attribute was found, fail to use %s", itemname))
			return false
		end
	--洗粉色
	elseif self.model.select_itemid == self.model.pink_itemid then
		local can_refine = false
		local itemname = Config.db_item[self.model.pink_itemid].name
		local holes = prefineslot.holes
		local num = 0
		local hole = 0
		for k, prefine in pairs(holes) do
			if prefine.color == enum.COLOR.COLOR_RED then
				can_refine = true
			end
			if not self.lock_tgs[k].isOn then
				hole = k
				num = num + 1
			end
		end
		if can_refine then
			local prefine = prefineslot.holes[hole]
			if num ~= 1 or prefine.color ~= enum.COLOR.COLOR_RED or prefine.value ~= prefine.max then
				local message = string.format("%s can only refine a red attribute to the max, please lock other attributes and continue refining", itemname)
				Dialog.ShowOne("Tip",message,"Confirm")
				return false
			end
		else
			Notify.ShowText(string.format("No red attribute was found, fail to use %s", itemname))
			return false
		end
	end

	return true
end

function EquipRefineView:EquipRefineBack()
	local had_num = BagController:GetInstance():GetItemListNum(self.cost_id)
	if self.model.free_count >= self.total_count and had_num < self.cost_num then
		return Notify.ShowText("Insufficient items")
	end
	EquipController:GetInstance():RequestRefineBack(self.select_slot)
end

function EquipRefineView:CheckLockHole(toggle, hole)
	local puton = EquipModel:GetInstance():GetEquipBySlot(self.select_slot)
	local prefineslot = self.model.slots[self.select_slot]
	if not puton or not prefineslot or not prefineslot.holes[hole] then
		toggle.isOn = false
		Notify.ShowText("This attribute slot is locked")
		return false
	end
	local num = 0
	for i=1, #self.lock_tgs do
		if self.lock_tgs[i].isOn and prefineslot.holes[i] then
			num = num + 1
		end
	end
	local hole_num = table.nums(prefineslot.holes)
	if num >= hole_num then
		toggle.isOn = false
		Notify.ShowText("Unable to lock all")
		return false
	end
	return true
end

function EquipRefineView:UpdateLockNum()
	local num = 0
	for i=1, #self.lock_tgs do
		if self.lock_tgs[i].isOn then
			num = num + 1
		end
	end
	self:UpdateLockMateria(num)
end

function EquipRefineView:ActiveHole(hole)
	local slot = self.select_slot
	local puton = EquipModel:GetInstance():GetEquipBySlot(slot)
    if not puton then
        return Notify.ShowText("Please equip something first")
    end
    local costs = String2Table(Config.db_equip_refine_other[1].unlock)
    if hole == 5 then
    	local need_vip = costs[hole][2][2]
    	local vip = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
    	local message = string.format("Activating this slot requires VIP%s, activate?", need_vip)
    	local ok_str = "Activate"
    	if vip < need_vip then
    		ok_str = "Upgrade VIP"
    	end
    	local function ok_func()
    		if vip >= need_vip then
    			EquipController:GetInstance():RequestActiveHole(slot, hole)
    		else
    			GlobalEvent:Brocast(VipEvent.OpenVipPanel)
    		end
    	end
    	Dialog.ShowTwo("Tip",message,ok_str,ok_func)
    else
    	local item_id, cost = 0
	    for i=1, #costs do
	    	local v = costs[i]
		    if v[1] == hole then
		    	item_id = v[2][1][1]
		    	cost = v[2][1][2]
		    	break
		    end
	    end
	    local item_name = Config.db_item[item_id].name
	    local message = string.format("Using %s %s to unlock a refinery attribute slot?", cost, item_name)
	    local function ok_func()
	    	local bo = RoleInfoModel:GetInstance():CheckGold(cost, Constant.GoldType.BGold)
	    	if not bo then
	    		return
	    	end
	    	EquipController:GetInstance():RequestActiveHole(slot, hole)
	    end
	    Dialog.ShowTwo("Tip",message,"Confirm",ok_func)
    end
    
end

function EquipRefineView:SetData(data)

end

function EquipRefineView:LoadItems()
	local equipSetTbl = String2Table(Config.db_equip_set[5].slot)
	local slots = {}
	local locks = {}
	local unputon = {}
	for i=1, #equipSetTbl do
		local slot = equipSetTbl[i]
		if self.model.slots[slot] then
			if EquipModel:GetInstance():GetEquipBySlot(slot) then
				slots[#slots+1] = slot
			else
				unputon[#unputon+1] = slot
			end
		else
			locks[#locks+1] = slot
		end
	end
	local function sort_slot(a, b)
		local index1 = Config.db_equip_refine[a].index
		local index2 = Config.db_equip_refine[b].index
		return index1 < index2
	end
	table.sort(locks, sort_slot)
	table.insertto(slots, locks, 0)
	table.insertto(slots, unputon, 0)
	for _, slot in pairs(slots) do
		local item = EquipRefineItem(self.EquipRefineItem_gameobject, self.itemContent)
		item:SetData(slot)
		self.item_list[#self.item_list+1] = item
	end
	self.select_slot = slots[1]
	self.model:Brocast(EquipEvent.SelectRefineItem, slots[1])
end

function EquipRefineView:UpdateView()
	local prefineslot = self.model.slots[self.select_slot]
	local pitem = EquipModel:GetInstance():GetEquipBySlot(self.select_slot)
	if not prefineslot or not pitem then
		self:InitAttr()
	else
		self:ShowEquip()
		self:ShowMateria()
		self:ShowAttrs(prefineslot)
	end
	--self:RefresLockToggle()
	for i=1, #self.lock_tgs do
		if self.model:IsLock(self.select_slot, i) then
			self.lock_tgs[i].isOn = true
		else
			self.lock_tgs[i].isOn = false
		end
	end
	self.total_count = Config.db_equip_refine_other[1].freecount
	self.freecount.text = string.format("%s/%s", self.total_count - self.model.free_count, self.total_count)
	self:ShowRedDot()
end

function EquipRefineView:ShowAttrs(prefineslot)
	local holes = prefineslot.holes
	local old_holes = prefineslot.old_holes
	for i=1, #self.attr_list do
		if old_holes[i] then
			local prefine = old_holes[i]
			local valueinfo = self.model:GetAttrTypeInfo(prefine.attr, prefine.value)
			local attr_name = string.format("%s%s", GetAttrNameByIndex(prefine.attr), valueinfo)
			attr_name = ColorUtil.GetHtmlStr(prefine.color, attr_name)
			local pre_str = self.attr_list[i].text
			local str = ""
			if prefine.value == prefine.max and prefine.color == enum.COLOR.COLOR_RED then
				str = string.format("%s<color=#09b005>(Max)</color>", attr_name)
			else
				local min = self.model:GetAttrTypeInfo2(prefine.attr, prefine.min)
				local max = self.model:GetAttrTypeInfo2(prefine.attr, prefine.max)
				str = string.format("%s<color=#09b005>(%s-%s)</color>", attr_name, min, max)
			end
			if prefine.color >= enum.COLOR.COLOR_ORANGE and pre_str ~= str then
				if self.show_effect then
					if not self.ui_effects[i] then
						local ui_effect = UIEffect(self.attr_list[i].transform, 20428)
						ui_effect:SetConfig({pos={x=4.9,y=-4.5}})
						self.ui_effects[i] = ui_effect
					end
				else
					self:DestroyEffect(i)
				end
			else
				self:DestroyEffect(i)
			end
			self.attr_list[i].text = str
		else
			if i<5 then
				self.attr_list[i].text = "Not refined"
			else
				self.attr_list[i].text = "<color=#e63232>VIP 5 unlocked</color>"
			end
			self:DestroyEffect(i)
		end
	end
	for i=1, #self.now_attr_list do
		if holes[i] then
			local prefine = holes[i]
			local valueinfo = self.model:GetAttrTypeInfo(prefine.attr, prefine.value)
			local attr_name = string.format("%s%s", GetAttrNameByIndex(prefine.attr), valueinfo)
			attr_name = ColorUtil.GetHtmlStr(prefine.color, attr_name)
			local str = ""
			if prefine.value == prefine.max and prefine.color == enum.COLOR.COLOR_RED then
				str = string.format("%s<color=#09b005>(Max)</color>", attr_name)
			else
				local min = self.model:GetAttrTypeInfo2(prefine.attr, prefine.min)
				local max = self.model:GetAttrTypeInfo2(prefine.attr, prefine.max)
				str = string.format("%s<color=#09b005>(%s-%s)</color>", attr_name, min, max)
			end
			local pre_str = self.now_attr_list[i].text
			self.now_attr_list[i].text = str
			SetVisible(self.touch_imgs[i], false)
			SetVisible(self.lock_tgs[i], true)
			if prefine.color >= enum.COLOR.COLOR_ORANGE and pre_str ~= str then
				if self.show_effect then
					if not self.ui_effects2[i] then
						local ui_effect = UIEffect(self.now_attr_list[i].transform, 20428)
						ui_effect:SetConfig({pos={x=4.9,y=-4.5}})
						self.ui_effects2[i] = ui_effect
					end
				else
					self:DestroyEffect2(i)
				end
			else
				self:DestroyEffect2(i)
			end
		else
			SetVisible(self.touch_imgs[i], true)
			if i<5 then
				self.now_attr_list[i].text = "<color=#774E3B>Tap to unlock refinery attribute slot</color>"
			else
				self.now_attr_list[i].text = "<color=#e63232>VIP 5 unlocked</color>"
			end
			SetVisible(self.lock_tgs[i], false)
			self.lock_tgs[i].isOn = false
			self:DestroyEffect2(i)
		end
	end
	local score = 0
	for k, prefine in pairs(holes) do
		score = score + math.floor(prefine.value * Config.db_equip_refine_score[prefine.attr].ratio) 
	end
	self.score.text = string.format("Refinery Rating: %s", score)
end

function EquipRefineView:DestroyEffect(i)
	if self.ui_effects[i] then
		self.ui_effects[i]:destroy()
		self.ui_effects[i] = nil
	end
end

function EquipRefineView:DestroyEffect2(i)
	if self.ui_effects2[i] then
		self.ui_effects2[i]:destroy()
		self.ui_effects2[i] = nil
	end
end

function EquipRefineView:RefresLockToggle()
	local prefineslot = self.model.slots[self.select_slot]
	if prefineslot then
		local holes = prefineslot.holes
		local hole_num = table.nums(holes)
		local lock_num = 0
		local need_hide = false
		for i=1, #self.lock_tgs do
			if self.lock_tgs[i].isOn then
				lock_num = lock_num + 1
			end
			if hole_num - lock_num <= 1 then
				need_hide = true 
				break
			end
		end
		if need_hide then
			for i=1, #self.lock_tgs do
				if not self.lock_tgs[i].isOn then
					SetVisible(self.lock_tgs[i], false)
				else
					SetVisible(self.lock_tgs[i], true)
				end
			end
		else
			for i=1, #self.lock_tgs do
				if holes[i] then
					SetVisible(self.lock_tgs[i], true)
				else
					SetVisible(self.lock_tgs[i], false)
				end
			end
		end
	end
end


function EquipRefineView:ShowEquip( ... )
	local pitem = EquipModel:GetInstance():GetEquipBySlot(self.select_slot)
	if not pitem then
		return
	end
	if not self.goodsitem then
		self.goodsitem = GoodsIconSettorTwo(self.equipicon)
	end
	local param = {}
	param["not_need_compare"] = true
	param["model"] = self.model
	param["p_item"] = pitem
	param["item_id"] = pitem.id
	param["size"] = {x = 80,y=80}
	param["can_click"] = true
	self.goodsitem:SetIcon(param)
end

function EquipRefineView:ShowMateria()
	--显示材料
	local othercfg = Config.db_equip_refine_other[1]
	local cost = String2Table(othercfg.cost)[1]
	if not self.goodsitem1 then
		self.goodsitem1 = GoodsIconSettorTwo(self.icon1)
	end
	local param={}
	param["not_need_compare"] = true
	param["model"] = self.model
	param["item_id"] = cost[1]
	local had_num = BagController:GetInstance():GetItemListNum(cost[1])
	local need_num = cost[2]
	local str = string.format("%s/%s", had_num, need_num)
	if had_num < need_num then
		str = string.format("%s/%s", ColorUtil.GetHtmlStr(enum.COLOR.COLOR_RED, had_num), need_num)
	end
	param["num"] = str
	param["size"] = {x = 70, y=70}
	param["can_click"] = true
	param["bind"] = 2
	self.goodsitem1:SetIcon(param)
	self:UpdateLockNum()
	self.cost_id = cost[1]
	self.cost_num = cost[2]
end

function EquipRefineView:ShowMateria2()
	if self.model.select_itemid == 0 then
		if self.goodsitem2 then
			self.goodsitem2:destroy()
			self.goodsitem2 = nil
		end
		SetVisible(self.noequipbg, true)
	else
		SetVisible(self.noequipbg, false)
		if not self.goodsitem2 then
			self.goodsitem2 = GoodsIconSettorTwo(self.icon2)
		end
		local param = {}
		param["not_need_compare"] = true
		param["model"] = self.model
		param["item_id"] = self.model.select_itemid
		local had_num = BagController:GetInstance():GetItemListNum(self.model.select_itemid)
		param["num"] = string.format("%s/1", had_num)
		param["size"] = {x = 70, y=70}
		param["bind"] = 2
		self.goodsitem2:SetIcon(param)
		if had_num >= 1 then
			self.goodsitem2:SetIconNormal()
		else
			self.goodsitem2:SetIconGray()
		end
	end
end

--更新锁定材料
function EquipRefineView:UpdateLockMateria(num)
	local othercfg = Config.db_equip_refine_other[1]
	local cost = String2Table(othercfg.lock)
	local item_id = cost[1][2][1][1]
	if not self.goodsitem3 then
		self.goodsitem3 = GoodsIconSettorTwo(self.icon3)
	end
	param = {}
	param["not_need_compare"] = true
	param["model"] = self.model
	param["item_id"] = item_id
	local need = 0
	num = num or 0
	for i=1, #cost do
		if cost[i][1] == num then
			need = cost[i][2][1][2]
		end
	end
	param["num"] = string.format("%s/%s", BagController:GetInstance():GetItemListNum(item_id), need)
	param["size"] = {x = 70, y=70}
	param["can_click"] = true
	param["bind"] = 2
	self.goodsitem3:SetIcon(param)
	self.lock_cost_id = item_id
	self.lock_cost_num = need
end

function EquipRefineView:InitAttr()
	for i=1, #self.attr_list do
		if i<5 then
			self.attr_list[i].text = "Not refined"
		else
			self.attr_list[i].text = "<color=#e63232>VIP 5 unlocked</color>"
		end
	end
	for i=1, #self.now_attr_list do
		if i<5 then
			self.now_attr_list[i].text = "<color=#774E3B>Tap to unlock refinery attribute slot</color>"
		else
			self.now_attr_list[i].text = "<color=#e63232>VIP 5 unlocked</color>"
		end
	end
	self.score.text = "Refinery Rating: 0"
	SetVisible(self.touchimage1, true)
	SetVisible(self.touchimage2, true)
	SetVisible(self.touchimage3, true)
	SetVisible(self.touchimage4, true)
	SetVisible(self.touchimage5, true)
	for i=1, #self.lock_tgs do
		SetVisible(self.lock_tgs[i], false)
	end
end

function EquipRefineView:ShowRedDot()
	if self.model:IsHoleCanActive(self.select_slot, 5) then
		if not self.reddot then
			self.reddot = RedDot(self.touchimage5)
			SetLocalPosition(self.reddot.transform, 135, 5)
		end
		SetVisible(self.reddot, true)
	else
		if self.reddot then
			SetVisible(self.reddot, false)
		end
	end
end