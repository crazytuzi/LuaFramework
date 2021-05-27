------------------------------------------------------------
--人物其它属性
------------------------------------------------------------
RoleOtherAttrView = RoleOtherAttrView or BaseClass(BaseView)

function RoleOtherAttrView:__init()
	self:SetIsAnyClickClose(true)
	self.texture_path_list = {
		'res/xui/role.png',
	}
	self.config_tab = {
		{"common2_ui_cfg", 1, {0}},
		{"role_other_attr_ui_cfg", 1, {0}},
		{"common2_ui_cfg", 2, {0}, nil, 999},
	}
end

function RoleOtherAttrView:__delete()
end

function RoleOtherAttrView:ReleaseCallBack()
	if self.fu_attr_list then
		self.fu_attr_list:DeleteMe()
		self.fu_attr_list = nil
	end
end

function RoleOtherAttrView:LoadCallBack(index, loaded_times)
	self:CreateTopTitle(ResPath.GetRole("role_word_100"), 275, 695)

	self.other_attr_txt = RichTextUtil.CreateLinkText("向下滑动查看更多属性", 20, COLOR3B.GREEN, nil, false)
	self.other_attr_txt:setPosition(self.node_t_list.layout_attr.node:getContentSize().width / 2, 62)
	self.node_t_list.layout_attr.node:addChild(self.other_attr_txt, 10)
	self.other_attr_txt:setVisible(false)

	self.fu_attr = {
		OBJ_ATTR.ACTOR_INNER_REDUCE_DAMAGE_ADD,
		OBJ_ATTR.ACTOR_DIZZY_RATE_ADD,
		OBJ_ATTR.ACTOR_DEF_DIZZY_RATE,
		OBJ_ATTR.ACTOR_HP_DAMAGE_2_MP_DROP_RATE_ADD,
		OBJ_ATTR.ACTOR_BAG_MAX_WEIGHT_ADD,
		OBJ_ATTR.ACTOR_DIE_REFRESH_HP_PRO,
		OBJ_ATTR.ACTOR_BROKEN_RELIVE_RATE,
		OBJ_ATTR.ACTOR_CRITRATE,
		OBJ_ATTR.ACTOR_RESISTANCECRIT,
		OBJ_ATTR.ACTOR_RESISTANCE_CRIT_RATE,
		OBJ_ATTR.ACTOR_RESISTANCECRITRATE,
		OBJ_ATTR.ACTOR_EQUIP_MAX_WEIGHT_ADD,
		OBJ_ATTR.ACTOR_EQUIP_MAX_WEIGHT_POWER,
		OBJ_ATTR.ACTOR_ABSORBHPRATE,
		OBJ_ATTR.ACTOR_ABOSRBHP,
		OBJ_ATTR.ACTOR_DAMAGE_UP,
	}

	self:CreateFuAttrList()

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleAttrChange, self))
end

function RoleOtherAttrView:OpenCallBack()
end

function RoleOtherAttrView:ShowIndexCallBack(index)
	self:Flush(0, "jump_top")
end

function RoleOtherAttrView:OnFlush(param_t, index)
	self.fu_attr_list:SetDataList(self.fu_attr)
	self.fu_attr_list:GetView():refreshView()
	local win_size = self.fu_attr_list:GetView():getContentSize()
	local inner_size = self.fu_attr_list:GetView():getInnerContainerSize()
	self.other_attr_txt:setVisible(inner_size.height > win_size.height)

	if param_t.jump_top then
		self.fu_attr_list:JumpToTop()
	end
end

function RoleOtherAttrView:RoleAttrChange(vo)
	attr_key = vo.key
	local zhu_attr_change = false
	for k2, v2 in pairs(self.fu_attr) do
		if attr_key == v2 then
			zhu_attr_change = true
		end
	end
	if zhu_attr_change then
		self:Flush()
	end
end

function RoleOtherAttrView:CreateFuAttrList()
	self.fu_attr_list = ListView.New()
	local ph_attr = self.ph_list.ph_attr
	self.fu_attr_list:Create(ph_attr.x, ph_attr.y, ph_attr.w, ph_attr.h, nil, RoleAttrItem)
	self.node_t_list.layout_attr.node:addChild(self.fu_attr_list:GetView(), 100, 100)
	self.fu_attr_list:GetView():setAnchorPoint(0.5, 0.5)
	self.fu_attr_list:SetItemsInterval(12)
end
