ItemShortageTipsView = ItemShortageTipsView or BaseClass(XuiBaseView)
function ItemShortageTipsView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.def_index = 0
	self.texture_path_list[3] = 'res/xui/mainui.png'
	self.config_tab = {
		{"itemtip_ui_cfg", 9, {0}}
	}
	self.item_data_changeback = BindTool.Bind1(self.ItemDataChangeCallback, self)
	self.role_data_changeback = BindTool.Bind1(self.RoleDataChangeCallback,self)	
end

function ItemShortageTipsView:__delete()
end

function ItemShortageTipsView:ReleaseCallBack()
	if self.item_shortage_list then
		self.item_shortage_list:DeleteMe()
		self.item_shortage_list = nil 
	end
end

function ItemShortageTipsView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateItemList()
	end
end

function ItemShortageTipsView:CreateItemList()
	if self.item_shortage_list == nil then
		local ph = self.ph_list.ph_item_list
		self.item_shortage_list = ListView.New()
		self.item_shortage_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ShortageListItem, nil, nil, self.ph_list.ph_list_litem)
		self.node_t_list["layout_shortage_item"].node:addChild(self.item_shortage_list:GetView(), 99)
		self.item_shortage_list:SetMargin(10)
		self.item_shortage_list:SetItemsInterval(5)
		self.item_shortage_list:GetView():setAnchorPoint(0, 0)
		self.item_shortage_list:SelectIndex(1)
		self.item_shortage_list:SetJumpDirection(ListView.Top)
		self.item_shortage_list:SetSelectCallBack(BindTool.Bind1(self.SelectShortageListDataCallBack, self))
	end
end

function ItemShortageTipsView:SelectShortageListDataCallBack()
	
end

function ItemShortageTipsView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function ItemShortageTipsView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_changeback)
	RoleData.Instance:NotifyAttrChange(self.role_data_changeback)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ItemShortageTipsView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			self:FlushItem()
			local data = BagData.Instance:GetWaylist()
			self.item_shortage_list:SetDataList(data)
		elseif k == "close" then
			self:CloseView()
		end
	end
		
end

function ItemShortageTipsView:CloseCallBack()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_changeback)
	RoleData.Instance:UnNotifyAttrChange(self.role_data_changeback)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ItemShortageTipsView:ItemDataChangeCallback()
	self:Flush(0, "close")
end

function ItemShortageTipsView:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_BIND_COIN or key == OBJ_ATTR.ACTOR_BIND_GOLD or key == OBJ_ATTR.ACTOR_GOLD
		or key == OBJ_ATTR.ACTOR_CYCLE_SOUL or key == OBJ_ATTR.ACTOR_MAGIC_SOUL or key == OBJ_ATTR.ACTOR_SHIELD_SPIRIT 
		or key == OBJ_ATTR.ACTOR_GEM_CRYSTAL or key == OBJ_ATTR.ACTOR_PEARL_CHIP or key == OBJ_ATTR.ACTOR_INJECT_POWER
		or key == OBJ_ATTR.ACTOR_BOSS_VALUE or key == OBJ_ATTR.ACTOR_MERITORIOUS_VALUE or key == OBJ_ATTR.ACTOR_ACHIEVE_VALUE then
		self:Flush(0, "close")
	end
end

function ItemShortageTipsView:CloseView()
	local item_type, item_id, comsume_num = BagData.Instance:GetConsumeData()
	local num = 0
	if item_type == 0 then 
		num = ItemData.Instance:GetItemNumInBagById(item_id,nil)
	else
		local key = RoleData.Instance:GetAttrKey(item_type)
		num = RoleData.Instance:GetAttr(key) 
	end
	if num >= comsume_num then
		if self:IsOpen() then
			self:Close()
		end
	end
end

function ItemShortageTipsView:FlushItem()
	local item_type, item_id, comsume_num = BagData.Instance:GetConsumeData()
	if item_type == 0 then
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local had_num = ItemData.Instance:GetItemNumInBagById(item_id,nil)
		if item_cfg == nil then
			return
		end
		local name = item_cfg.name
		local color = item_cfg.color 
		local color = string.format("%06x", item_cfg.color)
		local color_1 = C3b2Str(Str2C3b(color))
		local remian_num = math.abs(comsume_num - had_num)
		local txt = string.format(Language.Bag.ShortListItem, color_1, name, remian_num)
		RichTextUtil.ParseRichText(self.node_t_list.rich_desc.node, txt, 20, COLOR3B.OLIVE)
	else	
		local vir_item_id = tagAwardItemIdDef[item_type]
		local item_cfg = ItemData.Instance:GetItemConfig(vir_item_id)
		if item_cfg == nil then
			return
		end
		local name = item_cfg.name
		local key = RoleData.Instance:GetAttrKey(item_type)
		local num = RoleData.Instance:GetAttr(key)

		local remian_num = math.abs(comsume_num - num)
		local color = item_cfg.color
		local item_color = C3b2Str(Str2C3b(string.format("%06x",color)))
		local txt = string.format(Language.Bag.ShortListItem, item_color, name, remian_num)
		RichTextUtil.ParseRichText(self.node_t_list.rich_desc.node, txt, 20)
	end
end

ShortageListItem = ShortageListItem or BaseClass(BaseRender)
function ShortageListItem:__init()
	
end

function ShortageListItem:__delete()
	
end

function ShortageListItem:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.img_item_bg.node, BindTool.Bind1(self.OpenView, self), true)
end

function ShortageListItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_name.node:setString(self.data.name or "")
	RichTextUtil.ParseRichText(self.node_tree.rich_texy_desc.node, self.data.title or "", 20, COLOR3B.OLIVE)
	self.node_tree.icon_bg.node:loadTexture(ResPath.GetMainui("icon_"..self.data.icon.."_img"))
end

function ShortageListItem:OpenView()
	if self.data == nil then return end 
	if self.data.activityId == nil then
		if self.data.fun and next(self.data.fun) then
			local index = self.data.fun[2]
			local name = self.data.fun[1]
			if name ~= "Shop" then
				if IS_ON_CROSSSERVER then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
					return 
				end
			end
			if index ~= nil then
				ViewManager.Instance:Open(name, index)
			else
				ViewManager.Instance:Open(name)
			end
			if  name == "Shop" then
				ViewManager.Instance:FlushView(name, index or 1, "all", {buy_id = self.data.fun[3]})
			end
		elseif self.data.tele_id then
			Scene.Instance:CommonSwitchTransmitSceneReq(self.data.npc_id)
		end
	else
		if IS_ON_CROSSSERVER then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
			return 
		end
		if self.data.activityId > 0 then
			ActivityCtrl.Instance:SendActiveGuidanceReq(self.data.activityId)
		end
	end
	if ViewManager.Instance:IsOpen(ViewName.ShortageItem) then
		ViewManager.Instance:Close(ViewName.ShortageItem)
	end
end