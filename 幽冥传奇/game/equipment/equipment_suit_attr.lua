EquipmentSuitAttr = EquipmentSuitAttr or BaseClass(BaseView)

function EquipmentSuitAttr:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.texture_path_list = {
		--'res/xui/luxury_equip_tip.png'
	}
	self.config_tab = {
		{"equipment_ui_cfg", 9, {0}},
	}

	self.cur_count = 0 			-- 当前数值
	self.cur_need_count = 0 	-- 当前需要达到的数值
	self.next_need_count = 0 	-- 下一档需要达到的数值
	self.cur_attr = {} 			-- 当前套装属性
	self.next_attr = {} 		-- 下一档套装属性
end

function EquipmentSuitAttr:ReleaseCallBack()
	
end

function EquipmentSuitAttr:LoadCallBack(index, loaded_times)
	
end

function EquipmentSuitAttr:OpenCallBack()

end


function EquipmentSuitAttr:SetType(_type)
	self.type = _type

	-- 初始化参数
	local cur_count = 0
	local cur_need_count = 0
	local next_need_count = 0
	local cur_attr = {}
	local next_attr = {}
	local cur_cfg = {}
	local next_cfg = {}

	if self.type == 1 then -- 强化套装
		local cur_index = QianghuaData.Instance:StarSuitIndex()
		cur_index = cur_index == 0 and 1 or cur_index
		local next_index = cur_index + 1
		cur_attr, cur_need_count = QianghuaData.GetStarSuitAttr(cur_index)
		next_attr, next_need_count = QianghuaData.GetStarSuitAttr(next_index)
		cur_count = QianghuaData.Instance:GetAllStrengthLevel()
	elseif self.type == 2 then -- 精练套装
		local cur_index = AffinageData.Instance:GetSuitLevel()
		cur_index = cur_index == 0 and 1 or cur_index
		local next_index = cur_index + 1
		cur_attr, cur_need_count =  AffinageData.GetStarSuitAttr(cur_index)
		next_attr, next_need_count = AffinageData.GetStarSuitAttr(next_index)
		cur_count = AffinageData.Instance:GetAllAffinageLevel()
	elseif self.type == 3 then -- 鉴定套装 
		local cur_index = AuthenticateData.Instance:StarSuitIndex()
		cur_index = cur_index == 0 and 1 or cur_index
		local next_index = cur_index + 1
		cur_attr, cur_need_count = AuthenticateData.GetStarSuitAttr(cur_index)
		next_attr, next_need_count = AuthenticateData.GetStarSuitAttr(next_index)
		cur_count = AuthenticateData.Instance:GetAllEquipStar()
	elseif self.type == 4 then -- 神装融合套装
		local cur_index
		cur_index, cur_count = EquipmentFusionData.Instance:StarSuitIndex(1)
		cur_index = cur_index == 0 and 1 or cur_index
		local next_index = cur_index + 1
		cur_cfg = EquipmentFusionData.GetStarSuitAttr(1, cur_index)
		cur_attr = cur_cfg.attrs or {}
		cur_need_count = cur_cfg.level or 0

		next_cfg = EquipmentFusionData.GetStarSuitAttr(1, next_index)
		next_attr = next_cfg.attrs or {}
		next_need_count = next_cfg.level or 0
		
		-- cur_count = EquipmentFusionData.Instance:GetCurFusionLevel(1)
	elseif self.type == 5 then -- 热血融合套装
		local cur_index
		cur_index, cur_count = EquipmentFusionData.Instance:StarSuitIndex(2)
		cur_index = cur_index == 0 and 1 or cur_index
		local next_index = cur_index + 1
		cur_cfg = EquipmentFusionData.GetStarSuitAttr(2, cur_index)
		cur_attr = cur_cfg.attrs or {}
		cur_need_count = cur_cfg.level or 0

		next_cfg = EquipmentFusionData.GetStarSuitAttr(2, next_index)
		next_attr = next_cfg.attrs or {}
		next_need_count = next_cfg.level or 0

		-- cur_count = EquipmentFusionData.Instance:GetCurFusionLevel(2)
	elseif self.type == 6 then -- 神装神铸套装
		local cur_index
		cur_index, cur_count = ReXueGodEquipData.Instance:ReXueShenzhuStarSuitIndex(1)
		cur_index = cur_index == 0 and 1 or cur_index
		local next_index = cur_index + 1
		cur_cfg = ReXueGodEquipData.Instance:GetReXueShenzhuStarSuitAttr(1, cur_index)
		cur_attr = cur_cfg.attrs or {}
		cur_need_count = cur_cfg.totalLevel or 0

		next_cfg =  ReXueGodEquipData.Instance:GetReXueShenzhuStarSuitAttr(1, next_index)
		next_attr = next_cfg.attrs or {}
		next_need_count = next_cfg.totalLevel or 0
	elseif self.type == 7 then -- 热血神铸套装
		local cur_index
		cur_index, cur_count = ReXueGodEquipData.Instance:ReXueShenzhuStarSuitIndex(2)
		cur_index = cur_index == 0 and 1 or cur_index
		local next_index = cur_index + 1
		cur_cfg = ReXueGodEquipData.Instance:GetReXueShenzhuStarSuitAttr(2, cur_index)
		cur_attr = cur_cfg.attrs or {}
		cur_need_count = cur_cfg.totalLevel or 0

		next_cfg =  ReXueGodEquipData.Instance:GetReXueShenzhuStarSuitAttr(2, next_index)
		next_attr = next_cfg.attrs or {}
		next_need_count = next_cfg.totalLevel or 0
	elseif self.type == 8 then -- 豪装神铸套装
		local cur_index
		cur_index, cur_count = ReXueGodEquipData.Instance:ReXueShenzhuStarSuitIndex(3)
		cur_index = cur_index == 0 and 1 or cur_index
		local next_index = cur_index + 1
		cur_cfg = ReXueGodEquipData.Instance:GetReXueShenzhuStarSuitAttr(3, cur_index)
		cur_attr = cur_cfg.attrs or {}
		cur_need_count = cur_cfg.totalLevel or 0

		next_cfg =  ReXueGodEquipData.Instance:GetReXueShenzhuStarSuitAttr(3, next_index)
		next_attr = next_cfg.attrs or {}
		next_need_count = next_cfg.totalLevel or 0
	end

	self.cur_count = cur_count
	self.cur_need_count = cur_need_count
	self.next_need_count = next_need_count
	self.cur_attr = cur_attr
	self.next_attr = next_attr

	-- 融合套装标题 or 神铸套装标题
	self.cur_title = cur_cfg.name
	self.next_title = next_cfg.name
end

function EquipmentSuitAttr:ShowIndexCallBack()
	self:Flush()
end

function EquipmentSuitAttr:OnFlush()
	self:FlushShow()
end

function EquipmentSuitAttr:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()

	self.cur_count = 0
	self.cur_need_count = 0
	self.next_need_count = 0
	self.cur_attr = {}
	self.next_attr = {}
end

function EquipmentSuitAttr:FlushShow()
	local str, title = "", ""
	title = Language.Equipment and Language.Equipment.SuitAttrTitle and Language.Equipment.SuitAttrTitle[self.type] or "%d"

	if next(self.cur_attr) then
		local bool = self.cur_count >= self.cur_need_count -- 当前套装是否激活
		if self.cur_title then
			if bool then
				-- 例: 全身热血融合等级达到S级(已激活)
				str = string.format(self.cur_title .. "{wordcolor;55ff00;(%s)}\n", Language.Role.HadActive)
			else
				-- 例: 全身热血融合等级达到S级(0/1)
				str = string.format(self.cur_title .. "{color;ff2828;(%d/%d)}\n", self.cur_count, self.cur_need_count)
			end
		else
			if bool then
				-- 例: 全身洗炼星级达到100星(已激活)
				str = string.format(title .. "{wordcolor;55ff00;(%s)}\n", self.cur_need_count, Language.Role.HadActive)
			else
				-- 例: 全身洗炼星级达到100星(0/100)
				str = string.format(title .. "{color;ff2828;(%d/%d)}\n", self.cur_need_count, self.cur_count, self.cur_need_count)
			end
		end

		-- 拼接属性 已激活时属性颜色为绿色
		local cur_attr_list = RoleData.FormatRoleAttrStr(self.cur_attr)
		local color = bool and COLORSTR.GREEN or COLORSTR.GRAY
		for i,v in ipairs(cur_attr_list) do
			str = str .. string.format("{color;%s;%s：%s}\n",  color, v.type_str, v.value_str)
		end
	else
		-- 异常 默认显示第一级
		str = ""
	end
	local rich = self.node_t_list["rich_cur_text"]
	RichTextUtil.ParseRichText(rich.node, str, 22, COLOR3B.GRAY)
	rich.node:refreshView()


	if next(self.next_attr) then
		if self.next_title then
			-- 例: 全身热血融合等级达到S级(0/1)
			str = string.format(self.next_title .. "{color;ff2828;(%d/%d)}\n", self.cur_count, self.next_need_count)
		else
			-- 例: 全身洗炼星级达到100星(0/100)
			str = string.format(title .. "{color;ff2828;(%d/%d)}\n", self.next_need_count, self.cur_count, self.next_need_count)
		end

		-- 拼接属性 属性颜色为灰色
		local next_attr_list = RoleData.FormatRoleAttrStr(self.next_attr)
		for i,v in ipairs(next_attr_list) do
			str = str .. string.format("%s：%s\n", v.type_str, v.value_str)
		end
	else
		-- 没有下一级时不显示
		str = ""
	end
	local rich = self.node_t_list["rich_next_text"]
	RichTextUtil.ParseRichText(rich.node, str, 22, COLOR3B.GRAY)
	rich.node:refreshView()
end


