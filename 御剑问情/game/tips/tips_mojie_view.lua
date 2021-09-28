local CommonFunc = require("game/tips/tips_common_func")
TipsMojieView = TipsMojieView or BaseClass(BaseView)

function TipsMojieView:__init()
	self.ui_config = {"uis/views/tips/equiptips_prefab","MojieTip"}
	self.view_layer = UiLayer.Pop

	self.base_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	self.show_cast = false
	self.show_legend = false
	self.effect_obj = nil
	self.is_load_effect = false
	self.play_audio = true
end

function TipsMojieView:__delete()
	self.base_attr_list = {}

	self.button_handle = {}
	self.buttons = {}
	self.stone_item = {}
	self.show_cast = nil
	self.show_legend = nil
	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
end

function TipsMojieView:ReleaseCallBack()
	CommonFunc.DeleteMe()

	for k, v in pairs(self.base_attr_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.base_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.handle_param_t = nil
	self.show_cast = nil
	self.show_legend = nil

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	for k,v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}

	-- 清理变量和对象
	self.button_root = nil
	self.buttons = {}
	self.skill_dec = nil
	self.wear_icon = nil
	self.equip_name = nil
	self.equip_type = nil
	self.equip_prof = nil
	self.quality = nil
	self.qualityline = nil
	self.level = nil
	self.fight_power = nil
	self.scroller_rect = nil
	self.show_storge_score = nil
	self.storge_score = nil
	self.recycle_value = nil
	self.show_recycle = nil
	self.show_base_attr = nil
	self.name_effect = nil
end

function TipsMojieView:CloseCallBack()
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.show_cast = false
	self.show_legend = false
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end

function TipsMojieView:OpenCallBack()
	self.show_cast = false
	self.show_legend = false
end

function TipsMojieView:LoadCallBack()
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))

	self.button_root = self:FindObj("RightBtn")
	for i =1 ,5 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = button:FindObj("Text")
		self.buttons[i] = {btn = button, text = btn_text}
	end

	local base_attrs = self:FindObj("BaseAttrs")
	for i = 1, base_attrs.transform.childCount do
		self.base_attr_list[#self.base_attr_list + 1] = base_attrs:FindObj("BaseAttr"..i)
	end
	local skill_decs = self:FindObj("SkillDecs")
	self.skill_dec = skill_decs:FindObj("SkillAttr1")

	self.wear_icon = self:FindVariable("IsShowWearIcon")

	self.equip_name = self:FindVariable("EquipName")
	self.equip_type = self:FindVariable("EquipType")
	self.equip_prof = self:FindVariable("EquipProf")
	self.quality = self:FindVariable("Quality")
	self.qualityline = self:FindVariable("QualityLine")
	self.level = self:FindVariable("Level")
	self.fight_power = self:FindVariable("FightPower")

	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))

	self.scroller_rect = self:FindObj("Scroller").scroll_rect

	self.show_storge_score = self:FindVariable("ShowStorgeScore")
	self.show_storge_score:SetValue(false)
	self.storge_score = self:FindVariable("StorgeScore")
	self.recycle_value = self:FindVariable("RecycleValue")
	self.show_recycle = self:FindVariable("ShowRecycle")
	self.show_base_attr = self:FindVariable("ShowBaseAttr")

	self.name_effect = self:FindObj("NameEffect")

	self.show_recycle:SetValue(false)
end

function TipsMojieView:HandelAttrs(data, table)
	for i=1,#table do
		table[i].gameObject:SetActive(false)
	end
	local count = 1
	for k,v in ipairs(CommonDataManager.attrview_t) do
		local key = nil
		local value = data[v[2]]
		if value > 0 then
			key = CommonDataManager.GetAttrName(v[2])
		end
		if key ~= nil then
			local attr = table[count]
			if attr then
				attr.gameObject:SetActive(true)
				local obj = attr.gameObject
				local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
				local asset, name = ResPath.GetBaseAttrIcon(v[2])
				image_obj.image:LoadSprite(asset, name)
				attr.text.text = key..": "..ToColorStr(value, TEXT_COLOR.BLACK_1)
				count = count + 1
			else
				break
			end
		end
	end
end

function TipsMojieView:ShowTipContent()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end

	self.wear_icon:SetValue(self.data.mojie_level > 0)

	local name = MojieData.Instance:GetMojieName(self.data.index - 1, self.data.mojie_level)
	local name_str = "<color="..ITEM_TIP_NAME_COLOR[item_cfg.color]..">".. name .."</color>"
	self.equip_name:SetValue(name_str)
	self.equip_type:SetValue(Language.Mojie.Mojie)

	local bundle, sprite = nil, nil
	local color = nil
	bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.color)
	self.quality:SetAsset(bundle, sprite)
	bundle, sprite = ResPath.GetQualityLineBgIcon(item_cfg.color)
	self.qualityline:SetAsset(bundle, sprite)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local level_str = vo.level >= item_cfg.limit_level and item_cfg.limit_level.."级"
	self.level:SetValue(level_str)
	local prof_str = Language.Common.AllProf
	self.equip_prof:SetValue(prof_str)

	self.equip_item:SetData(self.data, true)

	--基础、
	local ring_cfg = MojieData.Instance:GetMojieCfg(self.data.index - 1, self.data.mojie_level) or {}
	self.show_base_attr:SetValue(self.data.mojie_level > 0)
	local base_result = CommonDataManager.GetAttributteByClass(ring_cfg)
	self:HandelAttrs(base_result, self.base_attr_list)
	self.fight_power:SetValue(CommonDataManager.GetCapability(base_result))

	local _, skill_level, skill_id, _ = MojieData.Instance:GetMojieOpenLevel(self.data.index - 1)
	self.skill_dec.text.text = SkillData.RepleCfgContent(skill_id, self.data.mojie_skill_level > 0 and self.data.mojie_skill_level or skill_level)
end

function TipsMojieView:StoneScendAttrString(attr_name, attr_value)
	return string.format("%s+%s", attr_name, attr_value)
end

-- 根据不同情况，显示和隐藏按钮
local function showHandlerBtn(self)
	if self.from_view == nil then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local handler_types = CommonFunc.GetOperationState(self.from_view, self.data, item_cfg, big_type)
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if handler_type == 23 then
			--显示回收值
			self.show_recycle:SetValue(true)
		end

		if tx ~= nil then
			v.btn:SetActive(true)
			v.text.text.text = tx
			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
				self.button_handle[k] = nil
			end
			self.button_handle[k] = self:ListenEvent("Button"..k,
				BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
end

local function showSellViewState(self)
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if not item_cfg then
		return
	end
	local salestate = CommonFunc.IsShowSellViewState(self.from_view)
end

function TipsMojieView:OnFlush(param_t)
	if self.data == nil then
		return
	end
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
	self:ShowTipContent()
	showHandlerBtn(self)
	showSellViewState(self)
end

function TipsMojieView:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	if not CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t) then
		return
	end
	self:Close()
end

--关闭装备Tip
function TipsMojieView:OnClickCloseButton()
	self:Close()
	print("点击“关闭”按钮")
end

--设置显示弹出Tip的相关属性显示
function TipsMojieView:SetData(data, from_view, param_t, close_call_back)
	if not data then
		return
	end
	self.close_call_back = close_call_back
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
		if self.data.param == nil then
			self.data.param = CommonStruct.ItemParamData()
		end
	end
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end