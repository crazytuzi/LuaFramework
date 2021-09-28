ShenShouEquipTip = ShenShouEquipTip or BaseClass(BaseView)
ShenShouEquipTip.FromView = {
	ShenShouView = 1,
	ShenShouEquipView = 2,
	ShenShouBagView = 3,
	ShenShouComposeView = 4,
}
function ShenShouEquipTip:__init()
	self.ui_config = {"uis/views/shenshouview_prefab","ShenShouEquipTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function ShenShouEquipTip:__delete()

end

function ShenShouEquipTip:ReleaseCallBack()
	if self.equip_tips then
		self.equip_tips:DeleteMe()
		self.equip_tips = nil
	end
	if self.equip_compare_tips then
		self.equip_compare_tips:DeleteMe()
		self.equip_compare_tips = nil
	end
end

function ShenShouEquipTip:LoadCallBack()
	self.equip_tips = ShenshouEquipLeftTip.New(self:FindObj("EquipTip"), self)
	self.equip_tips.is_mine = true
	self.equip_tips:SetActive(false)
	self.equip_compare_tips = ShenshouEquipLeftTip.New(self:FindObj("EquipCompareTip"), self)
	self:ListenEvent("Close",
	BindTool.Bind(self.OnClickCloseButton, self))
end

function ShenShouEquipTip:CloseCallBack()
	self.equip_tips:CloseCallBack()
	self.equip_compare_tips:CloseCallBack()
end

function ShenShouEquipTip:OpenCallBack()
	if self.data_cache then
		self:SetData(self.data_cache.data, self.data_cache.from_view, self.data_cache.shou_id, self.data_cache.close_call_back, self.data_cache.is_tian_sheng)
		self.data_cache = nil
		self:Flush()
	end

	-- self.equip_tips:OpenCallBack()
	-- self.equip_compare_tips:OpenCallBack()
end

--关闭装备Tip
function ShenShouEquipTip:OnClickCloseButton()
	self:Close()
end


--设置显示弹出Tip的相关属性显示
function ShenShouEquipTip:SetData(data, from_view, shou_id, close_call_back, is_tian_sheng)
	if not data then
		return
	end
	from_view = from_view or ShenShouEquipTip.FromView.ShenShouView
	if self:IsOpen() then
		self.equip_compare_tips:SetData(data, from_view, shou_id, close_call_back, is_tian_sheng)

		local equip_cell_data = ShenShouData.Instance:GetOneSlotData(shou_id, data.slot_index)
		if from_view == ShenShouEquipTip.FromView.ShenShouBagView and nil ~= equip_cell_data and equip_cell_data.item_id > 0 then
			self.equip_tips:SetActive(true)
			self.equip_tips:SetData(equip_cell_data, ShenShouEquipTip.FromView.ShenShouEquipView, shou_id)
		else
			self.equip_tips:SetActive(false)
		end
		-- local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
		-- local show_strengthen, show_gemstone = false, false
		-- if item_cfg == nil then
		-- 	return
		-- end
		-- local equip_index = ZhuanShengData.Instance:GetZhuanShengEquipIndex(item_cfg.sub_type)
		-- local my_data = ZhuanShengData.Instance:GetDressEquipList()[equip_index]
		-- if EquipData.IsMarryEqType(item_cfg.sub_type) then
		-- 	equip_index = MarryEquipData.GetMarryEquipIndex(item_cfg.sub_type)
		-- 	my_data = MarryEquipData.Instance:GetMarryEquipInfo()[equip_index]
		-- end
		-- if my_data then
		-- 	self.equip_tips:SetData(my_data)
		-- end
		self:Flush()
	else
		self.data_cache = {data = data, from_view = from_view, shou_id = shou_id, close_call_back = close_call_back, is_tian_sheng = is_tian_sheng,}
		self:Open()
	end

	self.from_view = from_view
end

function ShenShouEquipTip:OnFlush(param_t)
	self.equip_tips:OnFlush(param_t)
	self.equip_compare_tips:OnFlush(param_t)
end
--=========item====================


ShenshouEquipLeftTip = ShenshouEquipLeftTip or BaseClass(BaseRender)

function ShenshouEquipLeftTip:__init(instance, parent)
	self.parent = parent
	self.base_attr_list = {}
	self.special_attr_list = {}
	self.random_attr_list = {}
	self.legent_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.shou_id = 0
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	-- 功能按钮
	self.equip_item = ShenShouEquip.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
	self.button_root = self:FindObj("RightBtn")
	for i =1 ,5 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = self.button_root:FindObj("Btn"..i.."/Text")
		self.buttons[i] = {btn = button, text = btn_text}
	end
	self.show_special = self:FindVariable("show_special")
	self.is_show_the_random = self:FindVariable("ShowTheRandom")
	self.rand_attr_num = self:FindVariable("RandAttrNum")

	for i = 1, 3 do
		self.base_attr_list[i] = {attr_name = self:FindVariable("BaseAttrName"..i), attr_value = self:FindVariable("BaseAttrValue"..i),
									is_show = self:FindVariable("ShowBaseAttr"..i), attr_icon = self:FindVariable("Icon_base"..i)
		}
		self.special_attr_list[i] = {attr_name = self:FindVariable("SpecialAttrName"..i),
									is_show = self:FindVariable("ShowSpecialAttr"..i), attr_icon = self:FindVariable("Icon_base"..i)
		}
		self.random_attr_list[i] = {attr_name = self:FindVariable("RandomName"..i),
									is_show = self:FindVariable("ShowRandomAttr"..i), attr_icon = self:FindVariable("Icon_Randow"..i)
		}
		if self.is_mine == nil or self.is_mine == false then
			self.legent_attr_list[i] = {attr_name = self:FindVariable("LegentName"..i), attr_value = self:FindVariable("LegentValue"..i),
										is_show = self:FindVariable("ShowLegentAttr"..i), attr_icon = self:FindVariable("Icon_Legent"..i)
			}
		end
	end

	self.show_no_trade = self:FindVariable("ShowNoTrade")
	self.equip_name = self:FindVariable("EquipName")
	self.equip_type = self:FindVariable("EquipType")
	self.base_score = self:FindVariable("score")
	self.fight_power = self:FindVariable("FightPower")
	self.quality = self:FindVariable("Quality")
	self.decompose_text = self:FindVariable("DecomposeText")
	self.show_random = self:FindVariable("ShowRandom")
	self.show_decompose = self:FindVariable("ShowDecompose")
	self.show_storge_score = self:FindVariable("ShowStorgeScore")
	self.storge_score = self:FindVariable("StorgeScore")
	self.equip_prof = self:FindVariable("EquipProf")
	self.recyle_text = self:FindVariable("RecyleText")
	self.show_recyle_text = self:FindVariable("ShowRecyleText")
	if self.is_mine == nil or self.is_mine == false then
		self.show_legent = self:FindVariable("Show_Legent")
	end

	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))

	self.scroller_rect = self:FindObj("Scroller").scroll_rect
end

function ShenshouEquipLeftTip:__delete()
	self.button_label = nil
	self.base_attr_list = nil
	self.special_attr_list = nil
	self.random_attr_list = nil
	self.button_handle = nil
	self.buttons = nil
	self.parent = nil

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
end

function ShenshouEquipLeftTip:ShowTipContent()
	local item_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	if item_cfg == nil then
		return
	end

	local bundle, sprite = nil, nil
	local color = nil
	bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.quality + 1)
	self.quality:SetAsset(bundle, sprite)

	local item_name = ToColorStr(item_cfg.name, ITEM_TIP_NAME_COLOR[item_cfg.quality + 1])
	self.equip_name:SetValue(item_name)

	local equip_type = Language.ShenShou.ZhuangBeiLeiXing[item_cfg.slot_index] or ""
	self.equip_type:SetValue(equip_type)

	local attr_list = ShenShouData.Instance:GetShenshouBaseList(item_cfg.slot_index, item_cfg.quality)
	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(attr_list)
	local base_capability = CommonDataManager.GetCapability(attr_list, true)      							-- 装备基础评分
	local qh_shenshou_cfg = ShenShouData.Instance:GetShenshouLevelList(item_cfg.slot_index, self.data.strength_level)
	local qh_attr_struct = CommonDataManager.GetAttributteByClass(qh_shenshou_cfg)
	local strengthen_capability = CommonDataManager.GetCapability(qh_attr_struct, true)   	-- 锻造总评分
	local cur_shou_id = self.shou_id
	local bestattr_capability = 0
	if self.data.attr_list then
		bestattr_capability = ShenShouData.Instance:GetShenShouEqCapability(self.data.attr_list, cur_shou_id, self.data)   -- 极品属性追加总评分
	end
	local zhuangbei_pingfen = base_capability + strengthen_capability  					-- 装备评分
	local zonghe_pingfen = zhuangbei_pingfen + bestattr_capability 						-- 装备综合评分

	self.fight_power:SetValue(zonghe_pingfen)

	self.equip_item:SetData(self.data)
	self.equip_item:SetInteractable(false)

	local had_base_attr = {}

	for k, v in pairs(base_attr_list) do
		if v > 0 then
			table.insert(had_base_attr, {key = k, value = v})
		end
	end
	-- 基础
	if #had_base_attr > 0 then
		for k, v in ipairs(self.base_attr_list) do
			v.is_show:SetValue(had_base_attr[k] ~= nil)
			if had_base_attr[k] ~= nil then
				local add_value = qh_attr_struct[v] and math.floor(qh_attr_struct[v]) or 0
				v.attr_name:SetValue(Language.Common.AttrNameNoUnderline[had_base_attr[k].key])
				local add_str = add_value > 0 and "<color=#00ff00>+" .. Language.Tip.Strength .. "</color>" or ""
				v.attr_value:SetValue(had_base_attr[k].value .. add_str)
				local bundle,asset = ResPath.GetBaseAttrIcon(had_base_attr[k].key)
				v.attr_icon:SetAsset(bundle, asset)
			end
		end
	end

	if self.data.attr_list then
	    --卓越属性
		self.show_special:SetValue(true)
		self.show_random:SetValue(false)
		local spec_index = 1
		if self.data.attr_list then
			for k,v in pairs(self.data.attr_list) do
				if v.attr_type > 0 then
					local add_per_t = {[1] = "%", [2] = "%", [3] = "%", [4] = "%", [5] = "%", [6] = "%", [7] = "%", [8] = "%", [9] = "%"}
					local add_value = add_per_t[v.attr_type] and v.attr_value/100 .. "%" or v.attr_value
					local random_cfg = ShenShouData.Instance:GetRandomAttrCfg(item_cfg.quality, v.attr_type) or {}
					if self.special_attr_list[spec_index] then
						self.special_attr_list[spec_index].is_show:SetValue(true)
						self.special_attr_list[spec_index].attr_name:SetValue(random_cfg.attr_show .. "+" ..  add_value)
						spec_index = spec_index + 1
					end
				end
			end
		end
	else
		-- 随机属性
		self.show_special:SetValue(false)
		self.show_random:SetValue(true)
		local rand_index = 1
		local legend_num = self.data.param and self.data.param.star_level or 0
		local legend_attr_list = ShenShouData.Instance:GetRanAttrList(item_cfg.quality, legend_num)
		self.rand_attr_num:SetValue(legend_num)
		for k,v in pairs(legend_attr_list) do
			if v.attr_type > 0 then
				local add_per_t = {[1] = "%", [2] = "%", [3] = "%", [4] = "%", [5] = "%", [6] = "%", [7] = "%", [8] = "%", [9] = "%"}
				local add_value = add_per_t[v.attr_type] and v.attr_value/100 .. "%" or v.attr_value
				local random_cfg = ShenShouData.Instance:GetRandomAttrCfg(item_cfg.quality, v.attr_type) or {}
				if self.random_attr_list[rand_index] then
					self.random_attr_list[rand_index].is_show:SetValue(true)
					self.random_attr_list[rand_index].attr_name:SetValue(random_cfg.attr_show .. "+" ..  add_value)
					rand_index = rand_index + 1
				end
			end
		end
	end

	self.show_storge_score:SetValue(false)
end

-- 根据不同情况，显示和隐藏按钮
local function showHandlerBtn(self)
	if self.from_view == nil or self.from_view == ShenShouEquipTip.FromView.ShenShouComposeView then
		for k,v in pairs(self.buttons) do
			v.btn:SetActive(false)
		end

		return
	end
	local handler_types = self:GetOperationState()
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if tx ~= nil then
			v.btn:SetActive(true)
			v.text.text.text = tx
			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
			end
			self.button_handle[k] = self:ListenEvent("Button"..k,
				BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
end

function ShenshouEquipLeftTip:GetOperationState()
	local t = {}
	if self.from_view == ShenShouEquipTip.FromView.ShenShouView then
		t[#t+1] = TipsHandleDef.HANDLE_REPLACE
		t[#t+1] = TipsHandleDef.HANDLE_FULING
		t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
	elseif self.from_view == ShenShouEquipTip.FromView.ShenShouEquipView then
		if not self.is_mine then
			t[#t+1] = TipsHandleDef.HANDLE_TAKEOFF
		end
	elseif self.from_view == ShenShouEquipTip.FromView.ShenShouBagView then
		t[#t+1] = TipsHandleDef.HANDLE_EQUIP
	end

	return t
end

function ShenshouEquipLeftTip:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	if nil == shenshou_equip_cfg then return end
	if handler_type == TipsHandleDef.HANDLE_EQUIP then --装备
		ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_PUT_ON, self.shou_id, self.data.index, shenshou_equip_cfg.slot_index)
	elseif handler_type == TipsHandleDef.HANDLE_TAKEOFF then --脱下
		if ShenShouData.Instance:IsShenShouZhuZhan(self.shou_id) then
			local func = function()
				ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_TAKE_OFF, self.shou_id, shenshou_equip_cfg.slot_index)
				self.parent:Close()
			end
			TipsCtrl.Instance:ShowCommonAutoView("", Language.ShenShou.TakeOffEquipTips, func)
			return
		else
			ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_TAKE_OFF, self.shou_id, shenshou_equip_cfg.slot_index)
		end
	elseif handler_type == TipsHandleDef.HANDLE_FULING then
		ShenShouFulingView.CACHE_SHOW_ID = self.shou_id
		ShenShouFulingView.CACHE_SOLT_INDEX = shenshou_equip_cfg.slot_index
		ViewManager.Instance:Open(ViewName.ShenShou, TabIndex.shenshou_fuling)
	elseif handler_type == TipsHandleDef.HANDLE_REPLACE then
		ShenShouCtrl.Instance:OpenShenShouBag(self.shou_id, shenshou_equip_cfg.slot_index + 1)
	end
	self.parent:Close()
end

--关闭装备Tip
function ShenshouEquipLeftTip:OnClickCloseButton()
	self.parent:Close()
end

function ShenshouEquipLeftTip:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.is_tian_sheng = nil
	self.shou_id = 0
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end

function ShenshouEquipLeftTip:OnFlush(param_t)
	if self.data == nil then
		return
	end
	if self.scroller_rect then
		self.scroller_rect.normalizedPosition = Vector2(0, 1)
	end
	self:ShowTipContent()
	showHandlerBtn(self)
end

--设置显示弹出Tip的相关属性显示
function ShenshouEquipLeftTip:SetData(data,from_view, shou_id, close_call_back, is_tian_sheng)
	if not data then
		print("数据等于空")
		return
	end
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end

	self.close_call_back = close_call_back
	self.is_tian_sheng = is_tian_sheng
	self.from_view = from_view
	self.shou_id = shou_id or 0
	self:Flush()
end