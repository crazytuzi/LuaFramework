CardPieceTip = CardPieceTip or BaseClass(BaseView)
local CommonFunc = require("game/tips/tips_common_func")
function CardPieceTip:__init()
	self.ui_config = {"uis/views/cardview_prefab","CardPieceTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function CardPieceTip:__delete()

end

function CardPieceTip:ReleaseCallBack()
	if self.equip_tips then
		self.equip_tips:DeleteMe()
		self.equip_tips = nil
	end
	if self.equip_compare_tips then
		self.equip_compare_tips:DeleteMe()
		self.equip_compare_tips = nil
	end
end

function CardPieceTip:LoadCallBack()
	self.equip_tips = CardPieceLeftTip.New(self:FindObj("EquipTip"), self)
	self.equip_tips.is_mine = true
	self.equip_tips:SetActive(false)
	self.equip_compare_tips = CardPieceLeftTip.New(self:FindObj("EquipCompareTip"), self)
	self:ListenEvent("Close",
	BindTool.Bind(self.OnClickCloseButton, self))
end

function CardPieceTip:CloseCallBack()
	self.equip_tips:CloseCallBack()

	if self.equip_compare_tips ~= nil then
	    self.equip_compare_tips:CloseCallBack()
    end
end

function CardPieceTip:OpenCallBack()
	if self.data_cache then
		self:SetData(self.data_cache.data, self.data_cache.from_view, self.data_cache.param_t, self.data_cache.close_call_back, self.data_cache.gift_id, self.data_cache.is_check_item)
		self.data_cache = nil
		self:Flush()
	end

	-- self.equip_tips:OpenCallBack()
	-- self.equip_compare_tips:OpenCallBack()
end

--关闭装备Tip
function CardPieceTip:OnClickCloseButton()
	self:Close()
end


--设置显示弹出Tip的相关属性显示
function CardPieceTip:SetData(data, from_view, param_t, close_call_back, gift_id, is_check_item)
	if not data then
		return
	end
	from_view = from_view or TipsFormDef.FROM_NORMAL
	if self:IsOpen() and self.equip_compare_tips ~= nil then
		self.equip_compare_tips:SetData(data, from_view, param_t, close_call_back, gift_id, is_check_item, true)
		local item_id = CardData.Instance:GetCardItem(data.item_id)
		if from_view ~= TipsFormDef.FROM_CARD and item_id > 0 then
			self.equip_tips:SetActive(true)
			self.equip_tips:SetData({item_id = item_id, num = 1, is_bind = 0}, TipsFormDef.FROM_CARD)
		else
			self.equip_tips:SetActive(false)
		end
		self:Flush()
	else
		self.data_cache = {data = data, from_view = from_view, param_t = param_t, close_call_back = close_call_back, gift_id = gift_id, is_check_item = is_check_item}
		self:Open()
	end

	self.from_view = from_view
end

function CardPieceTip:OnFlush(param_t)
	self.equip_tips:OnFlush(param_t)

	if self.equip_compare_tips ~= nil then 
	    self.equip_compare_tips:OnFlush(param_t)
	end
end
--=========item====================


CardPieceLeftTip = CardPieceLeftTip or BaseClass(BaseRender)

local UP_ARROW_IMAGE_NAME = "arrow_20"
local DOWN_ARROW_IMAGE_NAME = "arrow_21"
local UP_ARROW_IMAGE_NAME_1 = "arrow_15"
local DOWN_ARROW_IMAGE_NAME_1 = "arrow_16"
function CardPieceLeftTip:__init(instance, parent)
	self.parent = parent
	self.base_attr_list = {}

	self.data = nil
	self.from_view = nil
	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.button_handle = {}
	-- 功能按钮
	self.equip_item = ItemCell.New()
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

	local base_attrs = self:FindObj("BaseAttr")
	for i = 1, base_attrs.transform.childCount do
		self.base_attr_list[#self.base_attr_list + 1] = base_attrs:FindObj("BaseAttr_"..i)
	end

	self.wear_icon = self:FindVariable("IsShowWearIcon")
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
	self.level = self:FindVariable("Level")
	if self.is_mine == nil or self.is_mine == false then
		self.show_legent = self:FindVariable("Show_Legent")
	end

	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))

	self.scroller_rect = self:FindObj("Scroller").scroll_rect
end

function CardPieceLeftTip:__delete()
	self.button_label = nil
	self.base_attr_list = nil
	self.button_handle = nil
	self.buttons = nil
	self.parent = nil

	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end
end

function CardPieceLeftTip:ShowTipContent()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end

	local bundle, sprite = nil, nil
	bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.color)
	self.quality:SetAsset(bundle, sprite)

	local item_name = ToColorStr(item_cfg.name, ITEM_TIP_NAME_COLOR[item_cfg.color])
	self.equip_name:SetValue(item_name)

	local piece_cfg = CardData.Instance:GetCardPieceCfg(self.data.item_id) or {}
	local base_attr_list = CommonDataManager.GetAttributteNoUnderline(piece_cfg)
	local base_capability = CommonDataManager.GetCapability(piece_cfg, true)      							-- 装备基础评分

	self.wear_icon:SetValue(self.is_mine or self.from_view == TipsFormDef.FROM_CARD)
	local my_prof = PlayerData.Instance:GetRoleBaseProf()
	local prof_str = Language.Common.ProfName[item_cfg.limit_prof]
	if item_cfg.limit_prof ~= 5 and item_cfg.limit_prof ~= my_prof then
		prof_str = ToColorStr(prof_str, TEXT_COLOR.RED)
	end
	self.equip_type:SetValue(prof_str)
	local chapter = math.ceil((piece_cfg.card_idx + 1) / 4) - 1
	local max_chapter = CardData.Instance:GetMaxOpenChapter()
	local chapter_cfg = CardData.Instance:GetCardChapterCfg(chapter)
	local chapter_str = chapter_cfg and chapter_cfg.page_name or ""
	if chapter > max_chapter then
		chapter_str = ToColorStr(chapter_str, TEXT_COLOR.RED)
	end
	self.base_score:SetValue(chapter_str)
	self.recyle_text:SetValue(string.format(Language.Card.RecyleTxt, item_cfg.recyclget))

	self.fight_power:SetValue(base_capability)

	-- local level_befor = item_cfg.limit_level > 0 and (math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100) or 0
	-- local level_behind = item_cfg.limit_level > 0 and (math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1) or 0
	local level_zhuan = PlayerData.GetLevelString(item_cfg.limit_level)
	-- local level_zhuan = string.format(Language.Common.Level, math.floor(item_cfg.limit_level))
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)
	self.level:SetValue(level_str)

	self.equip_item:SetData(self.data)
	self.equip_item:SetInteractable(false)

	for i = 1, #self.base_attr_list do
		local obj = self.base_attr_list[i].gameObject
		obj:SetActive(false)
		if self.is_compare then
			local temp_text_obj = U3DObject(obj.transform:GetChild(1).gameObject)
			if temp_text_obj then
				temp_text_obj.gameObject:SetActive(false)
			end
		end
	end

	local temp_base_attr_list = {}
	if self.is_compare and (item_cfg.limit_prof == 5 or item_cfg.limit_prof == my_prof) then
		local item_id = CardData.Instance:GetCardItem(self.data.item_id)
		local mine_piece_cfg = CardData.Instance:GetCardPieceCfg(item_id) or {}
		temp_base_attr_list = CommonDataManager.GetAttributteNoUnderline(mine_piece_cfg)
	end
	-- 基础
	local base_attr_count = 1
	for k, v in pairs(base_attr_list) do
		if v > 0 then
			local obj = self.base_attr_list[base_attr_count].gameObject
			local image_obj = U3DObject(obj.transform:GetChild(0).gameObject)
			if temp_base_attr_list[k] then
				local temp_text_obj = U3DObject(obj.transform:GetChild(1).gameObject)
				if temp_text_obj then
					local diff_value = v - temp_base_attr_list[k]
					local res_str = diff_value > 0 and UP_ARROW_IMAGE_NAME or DOWN_ARROW_IMAGE_NAME
					temp_text_obj.text.text = math.abs(diff_value)

					temp_text_obj.gameObject:SetActive(diff_value ~= 0)
					if diff_value ~= 0 then
						local asset, name = ResPath.GetStarImages(res_str)
						local temp_image_obj = temp_text_obj:FindObj("DiffIcon"..base_attr_count)
						temp_image_obj.image:LoadSprite(asset, name, function()
							temp_image_obj.image:SetNativeSize()
						end)
					end
				end
			end
			self.base_attr_list[base_attr_count].gameObject:SetActive(true)
			self.base_attr_list[base_attr_count].text.text = Language.Common.AttrNameNoUnderline[k]..": "..ToColorStr(v, TEXT_COLOR.BLACK_1)
			base_attr_count = base_attr_count + 1
			local asset, name = ResPath.GetBaseAttrIcon(Language.Common.AttrNameNoUnderline[k])
			image_obj.image:LoadSprite(asset, name, function()
				image_obj.image:SetNativeSize()
			end)
		end
	end

	self.show_special:SetValue(false)
	self.show_random:SetValue(false)

	self.show_storge_score:SetValue(false)
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

		if tx ~= nil and not self.is_mine then
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

function CardPieceLeftTip:OnClickHandle(handler_type)
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
	self.parent:Close()
end

--关闭装备Tip
function CardPieceLeftTip:OnClickCloseButton()
	self.parent:Close()
end

function CardPieceLeftTip:CloseCallBack()
	self.data = nil
	self.from_view = nil

	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end

function CardPieceLeftTip:OnFlush(param_t)
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
function CardPieceLeftTip:SetData(data, from_view, param_t, close_call_back, gift_id, is_check_item, is_compare)
	if not data then
		return
	end
	self.data = data
	self.close_call_back = close_call_back

	self.is_check_item = is_check_item
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self.is_compare = is_compare == true
	self:Flush()
end