--------------------------------------------------------
-- 热血-神格 视图  配置 GodQualityCfg
--------------------------------------------------------

RexueShengeView = RexueShengeView or BaseClass(BaseView)

function RexueShengeView:__init()
	self.texture_path_list[1] = 'res/xui/rexue.png'
	self:SetIsAnyClickClose(true)
	self:SetModal(true)
	self.config_tab = {
		{"rexue_god_equip_ui_cfg", 10, {0}},
	}

	self.shenzhu_lv_max = {}
	self.can_shenge = nil
end

function RexueShengeView:__delete()
end

--释放回调
function RexueShengeView:ReleaseCallBack()
	self.can_shenge = nil
end

--加载回调
function RexueShengeView:LoadCallBack(index, loaded_times)
	self:CreateCells()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self, 2))

	-- 数据监听
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(ReXueGodEquipData.Instance, self):AddEventListener(ReXueGodEquipData.SHENGE_RESULT, BindTool.Bind(self.OnShengeResult, self))
end

function RexueShengeView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RexueShengeView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.shenzhu_lv_max = {}
	self.select_data = nil
	self.can_shenge = nil
end

--显示指数回调
function RexueShengeView:ShowIndexCallBack(index)
	self.select_data = ReXueGodEquipData.Instance:GetShenzhuSelectData() or {}

	-- 可神铸的最大等级 缓存
	local shenzhu_slot = self.select_data and self.select_data.shenzhu_slot or 0
	self.shenzhu_lv_max = ReXueGodEquipData.Instance:GetShenzhuLevelMax(shenzhu_slot)

	self:Flush()
end

function RexueShengeView:OnFlush(index)
	self:FlushCurShow()
end

----------视图函数----------

function RexueShengeView:CreateCells()
	-- 创建 self.equip, self.consume_1, self.consume_2, self.consume_3
	local parent = self.node_t_list["layout_shenge"].node
	local index = 1
	local name_list = {"equip", "consume_1", "consume_2", "consume_3",}
	while(self.ph_list["ph_cell_" .. index] and name_list[index])
	do
		local ph = self.ph_list["ph_cell_" .. index]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetCellBgVis(false)
		parent:addChild(cell:GetView(), 99)
		self[name_list[index]] = cell
		self:AddObj(name_list[index])
		index = index + 1
	end
end

function RexueShengeView:FlushCurShow()
	local _type = ReXueGodEquipData.Instance:GetShenzhuType()
	local path = ResPath.GetWord("word_shenge_" .. _type)
	self:CreateTopTitle(path, nil, 607)

	self.equip:SetData(self.select_data and self.select_data.equip)

	local shenzhu_slot = self.select_data and self.select_data.shenzhu_slot or 0
	local cur_cfg, cur_shenge_level = ReXueGodEquipData.Instance:GetShengeLevelCfg(shenzhu_slot)
	local next_cfg, next_shenge_level = ReXueGodEquipData.Instance:GetShengeLevelCfg(shenzhu_slot, nil, true)

	-- 例: "1阶神格" or "未神格"
	local cur_title = cur_shenge_level > 0 and cur_shenge_level .. Language.ReXueGodEquip.ShenzhuText4 or Language.ReXueGodEquip.ShenzhuText5
	self.node_t_list["lbl_cur_shenge"].node:setString(cur_title)

	-- 例: "1阶神格" or "已满阶"
	local bool = next(next_cfg) ~= nil
	local next_title = bool and next_shenge_level .. Language.ReXueGodEquip.ShenzhuText4 or Language.ReXueGodEquip.ShenzhuText6
	self.node_t_list["lbl_next_shenge"].node:setString(next_title)

	self.can_shenge = bool
	local consumes = next_cfg.consumes or {}
	local index = 1
	while(self["consume_" .. index])
	do
		local consume = consumes[index]
		local consume_cell = self["consume_" .. index]
		if consume then
			local has_count = BagData.Instance:GetItemNumInBagById(consume.id)
			local consume_count = consume.count or 0
			local color = has_count >= consume_count and COLOR3B.GREEN or COLOR3B.RED
			local text = has_count .. "/" .. consume_count

			consume_cell:SetData(ItemData.InitItemDataByCfg(consume))
			consume_cell:SetRightBottomText(text, color)

			self.can_shenge = self.can_shenge and has_count >= consume_count
		else
			consume_cell:SetData()
			consume_cell:SetRightBottomText("")
		end
		index = index + 1
	end

	local btn_title = bool and Language.ReXueGodEquip.ShenzhuText7 or Language.ReXueGodEquip.ShenzhuText6
	self.node_t_list["btn_1"].node:setEnabled(bool)
	self.node_t_list["btn_1"].node:setTitleText(btn_title)

	-- 下一级神格属性
	local next_attr = next_cfg.attrs or {}
	local rich_param = {type_str_color = "c5b49b", value_str_color = "38c711"}
	local next_attr_str = RoleData.Instance.FormatAttrContent(next_attr, rich_param)
	next_attr_str = next_attr_str == "" and Language.Common.No or next_attr_str
	local rich = self.node_t_list["rich_next_attr"].node
	RichTextUtil.ParseRichText(rich, next_attr_str, 20, Str2C3b("c5b49b"))
	rich:refreshView()

	-- 当前神格属性
	local cur_attr = cur_cfg.attrs or {}
	local rich_param = {type_str_color = "c5b49b", value_str_color = "c5b49b"}
	local cur_attr_str = RoleData.Instance.FormatAttrContent(cur_attr, rich_param)
	cur_attr_str = cur_attr_str == "" and Language.Common.No or cur_attr_str
	local rich = self.node_t_list["rich_cur_attr"].node
	RichTextUtil.ParseRichText(rich, cur_attr_str, 20, Str2C3b("c5b49b"))
	rich:refreshView()

	local max_shenzhu_lv = self.shenzhu_lv_max and self.shenzhu_lv_max[next_shenge_level] or 0
	local text = max_shenzhu_lv == 0 and "" or string.format(Language.ReXueGodEquip.ShenzhuText3, next_shenge_level or 0, max_shenzhu_lv)
	self.node_t_list["lbl_tip"].node:setString(text)
end

----------end----------

function RexueShengeView:OnBtn()
	if self.can_shenge then
		local slot = self.select_data and self.select_data.shenzhu_slot or 0
		ReXueGodEquipCtrl.ReqRexueShenge(slot)
	else
		local str = Language.Common.StuffNotEnought
		SystemHint.Instance:FloatingTopRightText(str)
	end
end

function RexueShengeView:OnBagItemChange(event)
	local shenzhu_consume_id = ReXueGodEquipData.Instance:GetShenzhuLevelConsumeId()
	local bool = false
	for i, v in pairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			bool = true
			break
		else
			local item_id = v.data.item_id
			if shenzhu_consume_id[item_id] then
				bool = true
				break
			end
		end
	end
	
	if bool then
		self:Flush()
	end
end


function RexueShengeView:OnShengeResult(slot, level)
	self:Flush()
end

--------------------
