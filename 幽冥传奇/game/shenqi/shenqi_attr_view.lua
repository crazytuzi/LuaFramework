ShenqiAttrView = ShenqiAttrView or BaseClass(BaseView)
--神器四个属性面板
function ShenqiAttrView:__init()
	self:SetModal(true)
    self:SetIsAnyClickClose(true)

 	self.texture_path_list = {
		"res/xui/shenqi.png",
	}
	self.config_tab = {
		{"shenqi_ui_cfg", 2, {0}},
}
end

function ShenqiAttrView:__delete()
end

function ShenqiAttrView:ReleaseCallBack()
	
end

function ShenqiAttrView:OpenCallBack()
	
end

function ShenqiAttrView:CloseCallBack()
	
end

function ShenqiAttrView:LoadCallBack(index, loaded_times)
	-- 中间展示动画
	local ph = self.ph_list.ph_shenqi
	self.shenqi_eff = RenderUnit.CreateEffect(391, self.node_t_list.layout_shenqi_equip.node, 10, nil, nil, ph.x, ph.y -50)
	CommonAction.ShowJumpAction(self.shenqi_eff, 10)
	self.shenqi_eff.SetAnimateRes = function(node, res_id)
		if nil ~= node.animate_res_id and node.animate_res_id == res_id then
			return
		end

		node.animate_res_id = res_id
		if res_id == 0 then
			node:setStop()
			return
		end

		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(res_id)
		node:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end

	-- 等级数字
	local ph_level_num = self.ph_list.ph_level_num
	self.num_bar = NumberBar.New()
    self.num_bar:Create(ph_level_num.x, ph_level_num.y, 0, 0, ResPath.GetCommon("num_123_"))
    self.num_bar:SetSpace(-2)
    self.node_t_list.layout_shenqi_equip.node:addChild(self.num_bar:GetView(), 101)

	-- -- 星星
	local ph_stars = self.ph_list.ph_stars
	self.start_part = UiInstanceMgr.Instance:CreateStarsUi({x = ph_stars.x, y = ph_stars.y, star_num = 6,
		interval_x = 5, parent = self.node_t_list.layout_shenqi_equip.node, zorder = 99})

	XUI.AddClickEventListener(self.node_t_list.btn_shengji.node, BindTool.Bind(self.OnClickShengJi, self), true)
	EventProxy.New(ShenqiData.Instance, self):AddEventListener(ShenqiData.SHENQI_ATTR_CHANGE, BindTool.Bind(self.OnFlush, self))
	EventProxy.New(ShenqiData.Instance, self):AddEventListener(ShenqiData.MONEY_CHANGE, BindTool.Bind(self.FlushConsume, self))

	self.node_t_list.rich_bonus.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
end

function ShenqiAttrView:OnClickShengJi()
	ShenqiCtrl.Instance.SendShenQiAttrUpgrade(self.type)
end

function ShenqiAttrView:SetData(type)
	self.type = type
end

-- 刷新
function ShenqiAttrView:FlushAttrView()
	local attr1 = ShenqiData.GetShenqiAddAttr(self.type, self.level)
	local attr2 = ShenqiData.GetShenqiAddAttr(self.type, self.level + 1)
	local text1 = self:GetBuffAttrText(attr1, attr2)
	-- local text2 = self:GetBuffAttrText(attr2)

	UiInstanceMgr.FlushAttr(self.node_t_list.rich_bonus.node, text1)
	-- UiInstanceMgr.FlushAttr(self.node_t_list.rich_next_bonus.node, text2)
end

function ShenqiAttrView:GetBuffAttrText(attr_data, next_attr_data)
	local text_desc = ""
	for k, v in pairs (attr_data) do
		if nil ~= Language.ShenQi.AttrName[v.type] then
			if v.value >= 0 then
				text_desc = text_desc ..Language.ShenQi.AttrName[v.type]
				local next_value = 0
				if next_attr_data[k].value > 0 then
					next_value = next_attr_data[k].value
					text_desc = text_desc  .. v.value  / 100 .. "%" .. "{wordcolor;1eff00;↑" ..  (next_value - v.value) / 100  .. "%}\n"
				else
					text_desc = text_desc  .. v.value  / 100 .. "%\n"
				end
			end
		end
	end
	return text_desc
end

function ShenqiAttrView:ShowIndexCallBack(index)
	self:OnFlush()
end

function ShenqiAttrView:OnFlush(param_t, index)
	self.level = ShenqiData.Instance:GetShenqiAttrLevel(self.type)
	local floor = ShenqiData.Instance:GetShenQiJieShu()
	local res_id = 0
	local floor_info = ShenqiData.Instance:GetFloorInfo()
	if floor_info[floor] then
		res_id = floor_info[floor].eff_id
	else
		res_id = floor_info[1].eff_id
	end

	XUI.MakeGrey(self.shenqi_eff, nil == floor_info[floor])
	
	self.shenqi_eff:SetAnimateRes(res_id)
	self.node_t_list.img_name.node:loadTexture(ResPath.GetShenQiResPath("name_attr"..self.type))
	self.num_bar:SetNumber(self.level)

	self:FlushAttrView()
	self:FlushConsume()

	--星星数量
	local star_num = 0
	local per_level = 6
	if self.level > 0 and self.level % per_level == 0 then
		star_num = per_level
	else
		star_num = self.level % per_level
	end

	self.start_part:SetStarActNum(star_num)

	self.node_t_list.lbl_title.node:setString(Language.ShenQi.TableGroup[self.type])
end

function ShenqiAttrView:FlushConsume()
	local level = ShenqiData.Instance:GetShenqiAttrLevel(self.type)
	local cfg = ShenqiData.GetShenqiAttrConsume(self.type, level+1)
	if nil == cfg then cfg = ShenqiData.GetShenqiAttrConsume(self.type, level) end

	local item_id = ItemData.GetVirtualItemId(cfg.type)
	if nil == item_id then
		item_id = cfg.id
	end

	local consume_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_id > 0 then
		self.node_t_list.img_consume.node:loadTexture(ResPath.GetItem(consume_cfg.icon))
		self.node_t_list.img_consume.node:setScale(0.4)
	end

	local have_num = ShenqiData.Instance:GetHaveNumByCfg(cfg)
	local color = have_num > cfg.count and "00ff00" or "ff0000"
	local content = string.format("{wordcolor;%s;%d / %d}",color, have_num, cfg.count)
	RichTextUtil.ParseRichText(self.node_t_list.rich_consume.node, content, 20)
end