------------------------------------------------------------
--物品tip
------------------------------------------------------------
CardBaseTips = CardBaseTips or BaseClass(XuiBaseView)

local SCROLLVIEWWIDTH = 500
local SCROLLVIEWHEIGHT = 500

local RICHCELLHEIGHT = 20

function CardBaseTips:__init()
	self.is_async_load = false
	self.zorder = COMMON_CONSTS.ZORDER_ITEM_TIPS
	self.is_any_click_close = true
	self.texture_path_list[1] = 'res/xui/equipment.png'
	self.config_tab = {{"itemtip_ui_cfg", 1, {0}}}
	self.is_modal = true

	self.buttons = {}
	self.label_t = Language.Tip.ButtonLabel
	self.num_txt = nil	
	self.handle_param_t = self.handle_param_t or {}
	self.data = CommonStruct.ItemDataWrapper()
	self.attrslist = {}
	self.item_num = 1
	self.fromView = EquipTip.FROM_NORMAL
	self.handle_type = 0
	self.limit_level = 0
	
	self.star_list = {}

	self.alert_window = nil
	self.itemconfig_callback = BindTool.Bind1(self.ItemConfigCallback, self)
end

function CardBaseTips:__delete()
	self.label_t = nil
end

function CardBaseTips:ReleaseCallBack()
	self.buttons = {}
	self.handle_param_t = {}
	self.data = nil
	self.attrslist = {}
	self.equip_stamp = nil

	if nil ~= self.alert_window then
		self.alert_window:DeleteMe()
		self.alert_window = nil
	end
	if nil ~= self.fuling_effect then
		self.fuling_effect:DeleteMe()
		self.fuling_effect = nil
	end
	self.equip_color_bg = nil
	self.scroll_view = nil

	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.contrast_layout = nil
	self.fabao_rich = nil
	self.prop_countdown_rich = nil
	if ItemData.Instance then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.itemconfig_callback)
	end
end

function CardBaseTips:LoadCallBack()
	self.cell = BaseCell.New()
	self.layout_content_top = self.node_t_list.layout_content_top.node
	self.layout_content_top:setAnchorPoint(0.5, 0)
	self.layout_content_top:addChild(self.cell:GetCell(), 200)
	local ph_itemcell = self.ph_list.ph_itemcell --占位符
	self.cell:GetCell():setPosition(ph_itemcell.x, ph_itemcell.y)
	self.cell:SetIsShowTips(false)

	self.buttons = {self.node_t_list.btn_0.node, self.node_t_list.btn_1.node, 
	self.node_t_list.btn_2.node, self.node_t_list.btn_3.node}
	for k, v in pairs(self.buttons) do
		v:addClickEventListener(BindTool.Bind1(self.OperationClickHandler, self))
	end
	self.node_t_list.btn_close_window.node:setLocalZOrder(999)

	ItemData.Instance:NotifyItemConfigCallBack(self.itemconfig_callback)
end

function CardBaseTips:OpenCallBack()
	AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.OpenTip), AudioInterval.Common)
end

function CardBaseTips:ItemConfigCallback(item_config_t)
	self:Flush()
end

function CardBaseTips:ShowIndexCallBack(index)

end

function CardBaseTips:CloseCallBack()
	self.item_num = 1
	ParticleEffectSys.Instance:StopEffect("equipstar", true)
end

function CardBaseTips:OnFlush(param_t)
	self:ShowOperationState()
end

--data = {item_id=100....} 如果背包有的话最好把背包的物品传过来
function CardBaseTips:SetData(data, fromView, param_t)
	if not data then
		return
	end
	
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end
	self:Open()
	self.fromView = fromView or EquipTip.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end

--根据不同的状态出现不同的按钮
function CardBaseTips:ShowOperationState()
	local handle_types = self:GetOperationLabelByType(self.fromView)
	if handle_types then
		for k, v in ipairs(self.buttons) do
			local label = self.label_t[handle_types[k]]	--获得文字内容
			if label ~= nil then
				v:setVisible(true)
				v:setTag(handle_types[k])
				v:setTitleText(label)
			else
				v:setVisible(false)
			end
		end
	end
end

function CardBaseTips:GetOperationLabelByType(fromView)
	local t = {}
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil or IS_ON_CROSSSERVER then	-- 跨服中不能对装备进行操作
		return t
	end

	if fromView == EquipTip.FROM_BAG then							--在背包界面中
		if not item_cfg.flags.denyDestroy then
			if self.data.is_bind == 0 then
				t[#t+1] = EquipTip.HANDLE_DISCARD
			else
				t[#t+1] = EquipTip.HANDLE_DESTROY
			end
		end
		if ItemData.ItMedicaments[self.data.item_id] then
			t[#t+1] = EquipTip.HANDLE_USE
		end
		if StoneData.IsStoneEquip(item_cfg.type) and self.limit_level >= STONE_LEVEL_LIMIT then
			t[#t+1] = EquipTip.HANDLE_INLAY
		end
		t[#t+1] = EquipTip.HANDLE_EQUIP

		if ItemData.GetIsCard(self.data.item_id) then
			t[#t+1] = EquipTip.HANDLE_DECOMPOSE
		end
	elseif fromView == EquipTip.FROM_BAG_EQUIP then

		if not EquipData.CannotTakeOffEquip(item_cfg.type) then
			if item_cfg.type ~= ItemData.ItemType.itPrimitiveRingPos then 
				t[#t+1] = EquipTip.HANDLE_TAKEOFF
			end
		end
		if StoneData.IsStoneEquip(item_cfg.type) and self.limit_level >= STONE_LEVEL_LIMIT then
			t[#t+1] = EquipTip.HANDLE_INLAY
		end
		local hand_pos = QianghuaData.Instance:GetBetterStrengthHandPos(item_cfg.type)
		if QianghuaData.IsStrengthEquip(EquipData:GetEquipIndexByType(item_cfg.type, hand_pos)) then
			t[#t+1] = EquipTip.HANDLE_STRENGTHEN
		end
		if EquipmentData.IsXuelianEquip(EquipData:GetEquipIndexByType(item_cfg.type, hand_pos)) then
			t[#t+1] = EquipTip.HANDLE_XUELIAN
		end
	elseif fromView == EquipTip.FROM_BAG_ON_GUILD_STORAGE then
		if not item_cfg.flags.denyDestroy then
			t[#t+1] = EquipTip.HANDLE_DISCARD
		end
		if ItemData.ItMedicaments[self.data.item_id] then
			t[#t+1] = EquipTip.HANDLE_USE
		end
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_BAG_ON_BAG_STORAGE then
		if not item_cfg.flags.denyDestroy then
			t[#t+1] = EquipTip.HANDLE_DISCARD
		end
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_STORAGE_ON_GUILD_STORAGE then
		if not RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.GUILD_COMMON) then
			-- 除了行会普通成员外，其它职位均可摧毁行会仓库物品
			t[#t+1] = EquipTip.HANDLE_DESTROY
		end
		t[#t+1] = EquipTip.HANDLE_EXCHANGE
	elseif fromView == EquipTip.FROM_STORAGE_ON_BAG_STORAGE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_HERO_EQUIP then
		t[#t+1] = EquipTip.HANDLE_TAKEOFF
	elseif fromView == EquipTip.FROM_BAG_ON_RECYCLE then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_RECYCLE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_CARD_DESCOMPOSE then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_BAG_ON_CARD_DESCOMPOSE then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CONSIGN_ON_SELL then
		t[#t+1] = EquipTip.HANDLE_INPUT
	elseif fromView == EquipTip.FROM_CONSIGN_ON_BUY then
		if not ConsignData.Instance:GetItemSellerIsMe(self.data) then
			t[#t+1] = EquipTip.HANDLE_BUY
		end
	elseif fromView == EquipTip.FROM_XUNBAO_BAG then
		t[#t+1] = EquipTip.HANDLE_TAKEOUT
	elseif fromView == EquipTip.FROM_CHAT_BAG then
		t[#t+1] = EquipTip.HANDLE_SHOW
	elseif fromView == EquipTip.FROM_EXCHANGE_BAG then
		t[#t+1] = EquipTip.HANDLE_INPUT
	end
		
	return t
end

function CardBaseTips:OperationClickHandler(psender)
	if self.data == nil then
		return
	end
	self.handle_type = psender:getTag()
	if self.handle_type == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end

	TipCtrl.Instance:UseItem(self.handle_type, self.data, self.handle_param_t, self.fromView)
 	self:Close()
end
