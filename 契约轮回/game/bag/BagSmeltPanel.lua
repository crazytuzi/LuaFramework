BagSmeltPanel = BagSmeltPanel or class("BagSmeltPanel",WindowPanel)
local BagSmeltPanel = BagSmeltPanel
local tableInsert = table.insert
local ceil = math.ceil

local value_2_color = {
	[0] = 6,
	[1] = 5,
	[2] = 4
}
local value_2_order = {
	[0] = 16,
	[1] = 15,
	[2] = 14,
	[3] = 13,
	[4] = 12,
	[5] = 11,
	[6] = 10,
	[7] = 9,
	[8] = 8,
	[9] = 7,
	[10] = 6,
	[11] = 5,
	[12] = 4,
	[13] = 16,
}

local color_key = "bag_smelt_color"
local order_key = "bag_smelt_order"
local star_key = "bag_smelt_star"

function BagSmeltPanel:ctor()
	self.abName = "bag"
	self.assetName = "BagSmeltPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 3								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.table_index = nil
	self.item_list = {}
	self.attr_list = {}
	self.smelt_id = 0
	self.exp = 0
	self.old_exp = 0
	self.select_equips = {}
	self.color = value_2_color[CacheManager:GetInstance():GetInt(color_key, 2)] or enum.COLOR.COLOR_PURPLE
	self.order = value_2_order[CacheManager:GetInstance():GetInt(order_key, 13)] or 16
	self.star = CacheManager:GetInstance():GetInt(star_key, 0)
	self.model = BagModel:GetInstance()
	self.first_color = true
	self.first_order = true
end

function BagSmeltPanel:dctor()
	if self.scrollView then
		self.scrollView:OnDestroy()
		self.scrollView = nil
	end
	self.model = nil
end

function BagSmeltPanel:Open( )
	BagSmeltPanel.super.Open(self)
end

function BagSmeltPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","ScrollView2/Viewport/AttrContent","ScrollView/Viewport",
		"bg2/percent","smeltbtn","bg2/fillball","star_toggle","jie_drop","color_drop","bg2/level","ScrollView",
	}
	self:GetChildren(self.nodes)
	self:SetMask()
	self.percent = GetText(self.percent)
	self.fillball = GetImage(self.fillball)
	self.jie_drop = GetDropDown(self.jie_drop)
	self.color_drop = GetDropDown(self.color_drop)
	self.level = GetText(self.level)
	self:AddEvent()

	self:SetPanelSize(867, 540)
	self:SetTileTextImage("bag_image", "smelt_title")
end

function BagSmeltPanel:AddEvent()
	local function call_back(data)
		local id = data.id
		self.smelt_id = id
		local exp = data.exp
		self.exp = exp
		self.old_exp = exp
		local smelt_item = Config.db_equip_smelt[id]
		local attrs = String2Table(smelt_item.attr)
		for i=1, #attrs do
			local item = self.attr_list[i] or BagSmeltAttrItem(self.AttrContent)
			item:SetData(attrs[i], i)
			self.attr_list[i] = item
		end
		self:UpdateView()
	end
	self.event_id = EquipModel:GetInstance():AddListener(EquipEvent.UpdateSmeltInfo, call_back)

	local function call_back(pitembase)
		self:OnSelect(pitembase)
	end
	self.event_id2 = self.model:AddListener(BagEvent.SmeltItemClick, call_back)

	local function call_back()
		Notify.ShowText("Forged")
		self.select_equips = {}
		EquipController:GetInstance():RequestSmeltInfo()
	end
	self.event_id3 = GlobalEvent:AddListener(EquipEvent.SmeltSuccess, call_back)

	local function call_back(target,x,y)
		local open_level = tonumber(String2Table(Config.db_game["smelt_lv"].val)[1])
		if RoleInfoModel:GetInstance():GetMainRoleLevel() < open_level then
			Notify.ShowText(string.format("Devour unlocks at LV.%d", open_level))
			return
		end
		if Config.db_equip_smelt[self.smelt_id+1] then
			if table.isempty(self.select_equips) then
				Notify.ShowText("Please select the equipment you want to devour")
			else
				EquipController:GetInstance():RequestSmelt(self.select_equips)
			end
		else
			Notify.ShowText("Max Lvl")
		end
	end
	AddClickEvent(self.smeltbtn.gameObject,call_back)

	local function call_back(target, value)
		if value then
			self.star = 1
		else
			self.star = 0
		end
		CacheManager:GetInstance():SetInt(star_key, self.star)
		self:SelectEquips2()
	end
	AddValueChange(self.star_toggle.gameObject, call_back)

	local function call_back(go, value)
		local time = (self.first_order and 0 or 0.3)
		self.order = value_2_order[value]
		CacheManager:GetInstance():SetInt(order_key, value)
		self:SelectEquips2(time)
		self.first_order = false
	end
	AddValueChange(self.jie_drop.gameObject, call_back)

	local function call_back(go, value)
		local time = (self.first_color and 0 or 0.3)
		self.color = value_2_color[value]
		CacheManager:GetInstance():SetInt(color_key, value)
		self:SelectEquips2(time)
		self.first_color = false
	end
	AddValueChange(self.color_drop.gameObject, call_back)

end

function BagSmeltPanel:OpenCallBack()
	EquipController:GetInstance():RequestSmeltInfo()
end

function BagSmeltPanel:UpdateView( )
	self:GetEquips()
	if self.star == 1 then
		self.star_toggle:GetComponent("Toggle").isOn = true
	else
		self.star_toggle:GetComponent("Toggle").isOn = false
	end
	self.level.text = "Level:" .. self.smelt_id
	self.jie_drop.value = CacheManager:GetInstance():GetInt(order_key, 0)
	self.color_drop.value = CacheManager:GetInstance():GetInt(color_key, 2)
	self:UpdateBag()
end

function BagSmeltPanel:CloseCallBack(  )
	self.item_list = nil

	for i=1, #self.attr_list do
		self.attr_list[i]:destroy()
	end
	self.attr_list = nil

	if self.event_id then
		EquipModel:GetInstance():RemoveListener(self.event_id)
	end
	if self.event_id2 then
		self.model:RemoveListener(self.event_id2)
	end
	if self.event_id3 then
		GlobalEvent:RemoveListener(self.event_id3)
	end
	if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function BagSmeltPanel:GetEquips()
	self.model:UpdateCanSmeltEquips()
	self.equips = self.model:GetCanSmeltEquips()
end

function BagSmeltPanel:UpdateBag()
	local num = (math.ceil(#self.equips / 5))*5
	num = (num < 25 and 25 or num)
	if not self.scrollView then
		self:CreateItems(num)
	else
		for i=1, #self.item_list do
			self:UpdateCellCB(self.item_list[i])
		end
	end
	self:UpdateExp(self.exp, 0)
end

function BagSmeltPanel:OnSelect(pitembase)
	local cellid = pitembase.uid
	local itemcfg = Config.db_item[pitembase.id]
	local exp = 0
	if itemcfg.stype == enum.ITEM_STYPE.ITEM_STYPE_BAG_EXP then
		exp = itemcfg.effect * pitembase.num
	else
		exp = Config.db_equip[pitembase.id].exp
	end
	local viplv = RoleInfoModel:GetInstance():GetRoleValue("viplv")
	local percent = tonumber(Config.db_vip_rights[enum.VIP_RIGHTS.VIP_RIGHTS_15]["vip"..viplv] or 0)/10000
	local add_exp = 0
	if self.select_equips[cellid] then
		self.select_equips[cellid] = nil
		add_exp = 0 - exp
	else
		self.select_equips[cellid] = true
		add_exp = exp
	end
	add_exp = ceil(add_exp * (1+percent))
	self.exp = self.exp + add_exp
	self:UpdateExp(self.exp)
end

function BagSmeltPanel:SelectItem(pitembase, selected, time)
	local cellid = pitembase.uid
	local itemcfg = Config.db_item[pitembase.id]
	local exp = 0
	if itemcfg.stype == enum.ITEM_STYPE.ITEM_STYPE_BAG_EXP then
		exp = itemcfg.effect * pitembase.num
	else
		exp = Config.db_equip[pitembase.id].exp
	end
	local viplv = RoleInfoModel:GetInstance():GetRoleValue("viplv")
	local percent = tonumber(Config.db_vip_rights[enum.VIP_RIGHTS.VIP_RIGHTS_15]["vip"..viplv] or 0)/10000
	local add_exp = 0
	if not selected then
		self.select_equips[cellid] = nil
	else
		self.select_equips[cellid] = true
		add_exp = exp
	end
	add_exp = ceil(add_exp * (1+percent))
	self.exp = self.exp + add_exp
	self:UpdateExp(self.exp, time)
end

function BagSmeltPanel:SelectEquips2(time)
	self.exp = self.old_exp
	for i=1, #self.equips do
		local pitembase = self.equips[i]
		local id = pitembase.id
		local uid = pitembase.uid
		local equip = Config.db_equip[id]
		local item = Config.db_item[id]

		if item.stype == enum.ITEM_STYPE.ITEM_STYPE_BAG_EXP then
			self:SelectItem(pitembase, true, time)
		else
			if equip.order <= self.order and item.color <= self.color and equip.star <= self.star then
				self:SelectItem(pitembase, true, time)
			else
				self:SelectItem(pitembase, false, time)
			end
		end
	end
	self:UpdateItems()
end

function BagSmeltPanel:UpdateItems()
	for i=1, #self.item_list do
		if self.item_list[i] then
			local pitembase = self.item_list[i]:GetData()
			if pitembase then
				self.item_list[i]:Select(self.select_equips[pitembase.uid])
			end
		end
	end
end

function BagSmeltPanel:get_next(id, exp)
	local next_item = Config.db_equip_smelt[id+1]
	if not next_item then
		return id
	end
	if exp >= next_item.exp then
		return self:get_next(id+1, exp-next_item.exp)
	else
		return id
	end
end

--更新exp
function BagSmeltPanel:UpdateExp(exp, time)
	time = (time == nil and 0.3 or time)
	local next_item = Config.db_equip_smelt[self.smelt_id+1]
	if not next_item then
		self.percent.text = "Max Lvl"
	else
		local value = exp/next_item.exp
		self.percent.text = string.format("%0.2f", value*100) .. "%"
		cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.fillball)
		local value_action = cc.ValueTo(time, value,self.fillball,"fillAmount")
	    cc.ActionManager:GetInstance():addAction(value_action, self.fillball)
	    local next_id = self:get_next(self.smelt_id, exp)
	    if next_id ~= self.smelt_id then
	    	local smelt_item = Config.db_equip_smelt[next_id]
	    	local attrs = String2Table(smelt_item.attr)
	    	for i=1, #attrs do
	    		local item = self.attr_list[i]
				item:SetUpData(attrs[i])
	    	end
	    else
	    	local smelt_item = Config.db_equip_smelt[next_id]
	    	local attrs = String2Table(smelt_item.attr)
	    	for i=1, #attrs do
	    		local item = self.attr_list[i]
	    		if item then
					item:ClearUpData()
				end
	    	end
	    end
	end
end

function BagSmeltPanel:CreateItems(cellCount)
	local param = {}
	local cellSize = {width = 76,height = 76}
	param["scrollViewTra"] = self.ScrollView
	param["cellParent"] = self.Content
	param["cellSize"] = cellSize
	param["cellClass"] = BagSmeltItem
	param["begPos"] = Vector2(40,-53)
	param["spanX"] = 11.34
	param["spanY"] = 12.25
	param["createCellCB"] = handler(self,self.CreateCellCB)
	param["updateCellCB"] = handler(self,self.UpdateCellCB)
	param["cellCount"] = cellCount
	self.scrollView = ScrollViewUtil.CreateItems(param)
end

function BagSmeltPanel:CreateCellCB(itemCLS)
	self:UpdateCellCB(itemCLS, true)
end

function BagSmeltPanel:UpdateCellCB(itemCLS)
	local index = itemCLS.__item_index
	local item = self.equips[index]
	itemCLS:SetData(item, self:IsSelect(item), self.StencilId)
	if item then
		self.item_list[index] = itemCLS
	end
end

function BagSmeltPanel:IsSelect(pitembase)
	if not pitembase then
		return false
	end
	return self.select_equips[pitembase.uid]
end

function BagSmeltPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end
