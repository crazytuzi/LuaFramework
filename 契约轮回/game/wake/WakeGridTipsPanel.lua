WakeGridTipsPanel = WakeGridTipsPanel or class("WakeGridTipsPanel",BasePanel)
local WakeGridTipsPanel = WakeGridTipsPanel

function WakeGridTipsPanel:ctor()
	self.abName = "wake"
	self.assetName = "WakeGridTipsPanel"
	self.layer = "UI"

	--self.use_background = true
	--self.change_scene_close = true
	--self.click_bg_close = true

	self.event_list = {}
	self.model = WakeModel:GetInstance()


end

function WakeGridTipsPanel:dctor()
end

function WakeGridTipsPanel:Open(tipnode)
	WakeGridTipsPanel.super.Open(self)
	self.parentRectTra = tipnode:GetComponent("RectTransform")
	self.parent_node = tipnode.transform
end

function WakeGridTipsPanel:LoadCallBack()
	self.nodes = {
		"bg","bg/name","bg/active","bg/noactive","bg/activebtn","bg/attr/attr_name","bg/attr/attr_name2","bg/attr/attr_name3",
		"bg/attr/attr_name/attr_value","bg/attr/attr_name2/attr_value2","bg/attr/attr_name3/attr_value3","bg/cost_equip",
		"bg/cost_equip/cost_num","bg/cost_exp/cost_exp_num","bg/buybtn","bg/tips","bg/bg2",

		"bg/cost_exp","bg/huo",
	}
	self:GetChildren(self.nodes)

	self.name = GetText(self.name)
	self.attr_name = GetText(self.attr_name)
	self.attr_name2 = GetText(self.attr_name2)
	self.attr_name3 = GetText(self.attr_name3)
	self.attr_value = GetText(self.attr_value)
	self.attr_value2 = GetText(self.attr_value2)
	self.attr_value3 = GetText(self.attr_value3)
	self.cost_equip = GetText(self.cost_equip)
	self.cost_num = GetText(self.cost_num)
	self.cost_exp_num = GetText(self.cost_exp_num)
	self.tips = GetText(self.tips)

	self.attr_name_arr = {self.attr_name, self.attr_name2, self.attr_name3}
	self.attr_value_arr = {self.attr_value, self.attr_value2, self.attr_value3}

	self:AddEvent()

	--SetColor(self.background_img, 0, 0, 0, 0)
	self.viewRectTra = self.transform:GetComponent("RectTransform")
	self:SetPos()
end

function WakeGridTipsPanel:AddEvent()
	local function call_back(target,x,y)
		local cost = String2Table(self.data.cost)[1]
		local item_id = cost[1]
		local item_num = cost[2]
		local item = Config.db_item[item_id]
		self.cost_equip.text = item.name
		local have_num = BagController:GetInstance():GetItemListNum(item_id)
		if self.model.grid_id + 1 ~= self.data.id then
			Notify.ShowText("Please light the previous star sign")
			return
		end
		local cost_exp_tab = String2Table(self.data.cost_exp)
		if have_num < item_num  then
			--物品不足 并且这个格子可以消耗经验点亮 尝试消耗经验
			if cost_exp_tab and #cost_exp_tab > 0 then
				local function ok_func()
					local cost_exp = String2Table(self.data.cost_exp)[1]
					local need_exp = cost_exp[2]
					local have_exp = RoleInfoModel:GetInstance():GetRoleValue("exp")
					if have_exp > need_exp then
						WakeController:GetInstance():RequestActiveGrid(self.data.id)
						self:Close()
					else
						Notify.ShowText("Not enough EXP")
					end
				end
				Dialog.ShowTwo("Tip","Insufficient item, use EXP to light?","Confirm",ok_func,nil,nil,nil,nil,"Don't notice anymore until next time I log in", true, nil, self.__cname)
			else
				Notify.ShowText(WakeThreePanel.Tip1)
			end
			
		else
			WakeController:GetInstance():RequestActiveGrid(self.data.id)
			self:Close()
		end
	end
	AddClickEvent(self.activebtn.gameObject,call_back)

	local function call_back(target,x,y)

		local cost = String2Table(self.data.cost)[1]
		local item_id = cost[1]

		if self.jump1 and self.jump2 then
			lua_panelMgr:GetPanelOrCreate(ShopPanel):Open(self.jump1, self.jump2, item_id,true)
		else
			lua_panelMgr:GetPanelOrCreate(ShopPanel):Open(2, 1, item_id,true)
		end

		self:Close()
	end
	AddClickEvent(self.buybtn.gameObject,call_back)

	local function call_back(target,x,y)
		self:Close()
	end
	AddButtonEvent(self.bg2.gameObject,call_back)

	local function call_back()
		self:UpdateEquipNum()
	end
	self.event_list[#self.event_list+1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)
	self.event_list[#self.event_list+1] = GlobalEvent:AddListener(BagEvent.AddItems, call_back)
end

function WakeGridTipsPanel:OpenCallBack()
	self:UpdateView()
end

function WakeGridTipsPanel:UpdateView( )
	self.name.text = self.data.name
	if self.model.grid_id >= self.data.id then
		SetVisible(self.active, true)
		SetVisible(self.noactive, false)
		SetVisible(self.activebtn, false)
		SetVisible(self.tips, false)
	else
		SetVisible(self.active, false)
		SetVisible(self.noactive, true)
		if self.model.grid_id + 1 == self.data.id then
			SetVisible(self.activebtn, true)
			SetVisible(self.tips, false)
		else
			SetVisible(self.activebtn, false)
			SetVisible(self.tips, true)
			self.tips.text = string.format("Please light %s first", Config.db_wake_grid[self.data.id-1].name)
		end
	end
	local attr = String2Table(self.data.attr)
	for i=1, #attr do
		self:UpdateAttr(i, attr[i])
	end
	self:UpdateEquipNum()
	self:UpdateExp()
end

function WakeGridTipsPanel:CloseCallBack(  )
	for i=1, #self.event_list do
		GlobalEvent:RemoveListener(self.event_list[i])
	end
	self.attr_name_arr = nil
	self.attr_value_arr = nil
end


--data:db_wake_grid
function WakeGridTipsPanel:SetData(data,jump1,jump2)
	self.data = data
	self.jump1 = jump1
	self.jump2 = jump2
end

function WakeGridTipsPanel:SetPos()
    local pos = self.parentRectTra.position
    local x = pos.x
    local y = pos.y

    local width = self.viewRectTra.sizeDelta.x
    local height = self.viewRectTra.sizeDelta.y

    x = x*100 + width/2 + 10
    y = y*100 - height/2 - 10

    local UITransform = LayerManager.Instance:GetLayerByName(self.layer)
    self.transform:SetParent(UITransform)
    SetLocalScale(self.transform, 1, 1, 1)

    local spanY = 0
    if y - height/2 < -ScreenHeight/2 + 10 then
    	spanY = ScreenHeight/2 + y - height/2 - 10
    end
    self.viewRectTra.anchoredPosition = Vector2(x, y-spanY)
end

function WakeGridTipsPanel:UpdateAttr(index, attr)
	if self.attr_name_arr[index] then
		self.attr_name_arr[index].text = GetAttrNameByIndex(attr[1])
		self.attr_value_arr[index].text = attr[2]
	end
end

function WakeGridTipsPanel:UpdateEquipNum()
	local cost = String2Table(self.data.cost)[1]
	local item_id = cost[1]
	local item_num = cost[2]
	local item = Config.db_item[item_id]
	self.cost_equip.text = item.name
	local have_num = BagController:GetInstance():GetItemListNum(item_id)
	if have_num >= item_num then
		self.cost_num.text = string.format(ConfigLanguage.Wake.EnoughTwo, have_num, item_num)
	else
		self.cost_num.text = string.format(ConfigLanguage.Wake.NotEnoughTwo, have_num, item_num)
	end
end

function WakeGridTipsPanel:UpdateExp()
	local cost_exp = String2Table(self.data.cost_exp)

	if not cost_exp or #cost_exp == 0 then
		SetVisible(self.huo,false)
		SetVisible(self.cost_exp,false)
		return
	end

	SetVisible(self.huo,true)
	SetVisible(self.cost_exp,true)

	cost_exp = cost_exp[1]
	local need_exp = cost_exp[2]
	local have_exp = RoleInfoModel:GetInstance():GetRoleValue("exp")
	if have_exp >= need_exp then
		self.cost_exp_num.text = string.format(ConfigLanguage.Wake.EnoughTwo, GetShowNumber(have_exp), GetShowNumber(need_exp))
	else
		self.cost_exp_num.text = string.format(ConfigLanguage.Wake.NotEnoughTwo, GetShowNumber(have_exp), GetShowNumber(need_exp))
	end
end