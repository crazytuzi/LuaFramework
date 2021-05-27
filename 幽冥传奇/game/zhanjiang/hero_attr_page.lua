--英雄属性页面
HeroAttrPage = HeroAttrPage or BaseClass()
function HeroAttrPage:__init()
	self.view = nil
end	

function HeroAttrPage:__delete()
	self:RemoveEvent()

	-- if self.role_info_widget then
	-- 	self.role_info_widget:DeleteMe()
	-- 	self.role_info_widget = nil
	-- end
	if self.role_cap then
		self.role_cap:DeleteMe()
		self.role_cap = nil
	end
	if self.zhu_attr_list then
		self.zhu_attr_list:DeleteMe()
		self.zhu_attr_list = nil
	end
	if self.fu_attr_list then
		self.fu_attr_list:DeleteMe()
		self.fu_attr_list = nil
	end

	-- if self.property_list then
	-- 	self.property_list:DeleteMe()
	-- 	self.property_list = nil 
	-- end
	-- if self.tabbar_fashion then
	-- 	self.tabbar_fashion:DeleteMe()
	-- 	self.tabbar_fashion = nil
	-- end
	self.view = nil
end	

--初始化页面接口
function HeroAttrPage:InitPage(view)
	self.view = view
	--绑定要操作的元素
	-- self:CreateRoleInfoWidget()
	self.btn_index = 1
	self:InitZhuAttr()
	self:InitFuAttr()
	self:CreateZhuAttrList()
	self:CreateFuAttrList()
	-- self:CreateFashionEquip()
	-- self:CreateBtn()
	local ph = self.view.ph_list.ph_hero_fp_num
	self.role_cap = NumberBar.New()
	self.role_cap:SetRootPath(ResPath.GetCommonPath("big_num_100_"))
	self.role_cap:SetPosition(ph.x, ph.y)
	self.role_cap:SetSpace(-6)
	self.view.node_t_list.layout_hero_attr.node:addChild(self.role_cap:GetView(), 300, 300)
	self.role_cap:SetNumber(ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER))

	self.view.node_t_list.layout_hero_attr.jobText.node:setString(Language.Common.ProfName[ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) or 0])
	self.view.node_t_list.layout_hero_attr.levelText.node:setString(ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) .. Language.Common.Zhuan .. ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) .. Language.Common.Ji)

	-- XUI.AddClickEventListener(self.view.node_t_list.layout_addition.img_qianghua.node, BindTool.Bind2(self.OpenRuleTips, self, 1))
	-- XUI.AddClickEventListener(self.view.node_t_list.layout_addition.img_gem.node, BindTool.Bind2(self.OpenRuleTips, self, 2))
	-- XUI.AddClickEventListener(self.view.node_t_list.layout_role_info.layout_shizhuang.btn_open_view.node, BindTool.Bind2(self.OpenViewRuleTips, self))
	-- XUI.AddClickEventListener(self.view.node_t_list.layout_hero_attr.btn_circle.node, BindTool.Bind2(self.OpenCircleView, self))
	-- self.view.node_t_list.layout_addition.img_qianghua.node:setVisible(false)
	-- self.view.node_t_list.layout_addition.img_gem.node:setVisible(false)
	-- self.view.node_t_list.layout_addition.img_equip.node:setVisible(false)
	-- self.view.node_t_list.layout_hero_attr.btn_circle.node:setVisible(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= 255)
	-- self.view.node_t_list.layout_addition.node:setLocalZOrder(999)

	self:InitEvent()
	
end	

--初始化事件
function HeroAttrPage:InitEvent()
	self.hero_attr_event = GlobalEventSystem:Bind(HeroDataEvent.HERO_ATTR_CHANGE, BindTool.Bind1(self.HeroAttrChangeCallback, self))
	-- RoleData.Instance:NotifyAttrChange(self.hero_attr_event)

	-- self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)			--监听物品数据变化
	-- ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
end

--移除事件
function HeroAttrPage:RemoveEvent()
	if self.hero_attr_event then
		GlobalEventSystem:UnBind(self.hero_attr_event)
		self.hero_attr_event = nil
	end	
	-- if self.itemdata_change_callback then
	-- 	ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
	-- 	self.itemdata_change_callback = nil 
	-- end
end

function HeroAttrPage:ItemDataChangeCallback()
	-- self.view:Flush(TabIndex.role_intro, "change_fashion")
end

--更新视图界面
function HeroAttrPage:UpdateData(data)
	self.view.node_t_list.layout_hero_attr.levelText.node:setString(ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) .. Language.Common.Zhuan .. ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) .. Language.Common.Ji)
end	

function HeroAttrPage:HeroAttrChangeCallback(key, value)
	local k1 = key
	local v1 = value
	if k1 == OBJ_ATTR.ACTOR_BATTLE_POWER then
		self.role_cap:SetNumber(v1)
	elseif k1 == OBJ_ATTR.CREATURE_LEVEL or k1 == OBJ_ATTR.ACTOR_CIRCLE then
		self.view.node_t_list.layout_hero_attr.levelText.node:setString(ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) .. Language.Common.Zhuan .. ZhanjiangData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) .. Language.Common.Ji)
	elseif k1 ~= OBJ_ATTR.ACTOR_EXP_L and k1 ~= OBJ_ATTR.ACTOR_EXP_H then
		local zhu_attr_change = false
		for k2, v2 in pairs(self.zhu_attr) do
			if type(v2) == "table" then
				for k3,v3 in pairs(v2) do
					if k1 == v3 then
						zhu_attr_change = true
						break
					end
				end
			elseif type(v2) == "number" then
				if v2 == k1 then
					zhu_attr_change = true
					break
				end
			else
				if v2 == k1 then
					zhu_attr_change = true
					break
				end
			end
			if zhu_attr_change == true then
				break
			end
		end
		if zhu_attr_change then
			self.zhu_attr_list:SetDataList(self.zhu_attr)
		end
		local fu_attr_change = false
		for k2, v2 in pairs(self.fu_attr) do
			if type(v2) == "table" then
				for k3,v3 in pairs(v2) do
					if k1 == v3 then
						fu_attr_change = true
						break
					end
				end
			elseif type(v2) == "number" then
				if v2 == k1 then
					fu_attr_change = true
					break
				end
			else
				if v2 == k1 then
					fu_attr_change = true
					break
				end
			end
			if fu_attr_change == true then
				break
			end
		end
		if fu_attr_change then
			self.fu_attr_list:SetDataList(self.fu_attr)
		end
	end
	-- self.view:Flush(TabIndex.hero_intro)
	-- --self:UpdateAdditionTip()
end

function HeroAttrPage:CreateRoleInfoWidget()
	self.role_info_widget = RoleInfoView.New()
	self.role_info_widget:CreateViewByUIConfig(self.view.ph_list.ph_role_info_widget, "equip")
	self.view.node_t_list.layout_role_info.node:addChild(self.role_info_widget:GetView(), 200) 
	self.role_info_widget:SetRoleData(RoleData.Instance.role_vo)
	self:BoolShowEquipOrShiZhuang(self.role_info_widget.btn_switch:isTogglePressed())
end

function HeroAttrPage:CreateZhuAttrList()
	self.zhu_attr_list = ListView.New()
	local ph_role_zhuattr_list = self.view.ph_list.ph_role_zhuattr_list
	self.zhu_attr_list:Create(ph_role_zhuattr_list.x, ph_role_zhuattr_list.y, ph_role_zhuattr_list.w, ph_role_zhuattr_list.h, nil, HeroAttrItem, nil, nil, self.view.ph_list.ph_role_attr_item)
	self.view.node_t_list.layout_hero_attr.node:addChild(self.zhu_attr_list:GetView(), 100, 100)
	self.zhu_attr_list:GetView():setAnchorPoint(0,0)
	self.zhu_attr_list:SetItemsInterval(8)
	self.zhu_attr_list:SetMargin(5)
	self.zhu_attr_list:SetDataList(self.zhu_attr)
	self.zhu_attr_list:JumpToTop(true)
end

function HeroAttrPage:CreateFuAttrList()
	self.fu_attr_list = ListView.New()
	local ph_role_fuattr_list = self.view.ph_list.ph_role_fuattr_list
	self.fu_attr_list:Create(ph_role_fuattr_list.x, ph_role_fuattr_list.y, ph_role_fuattr_list.w, ph_role_fuattr_list.h, nil, HeroAttrItem, nil, nil, self.view.ph_list.ph_role_attr_item)
	self.view.node_t_list.layout_hero_attr.node:addChild(self.fu_attr_list:GetView(), 100, 100)
	self.fu_attr_list:GetView():setAnchorPoint(0,0)
	self.fu_attr_list:SetItemsInterval(8)
	self.fu_attr_list:SetMargin(5)
	self.fu_attr_list:SetDataList(self.fu_attr)
	self.fu_attr_list:JumpToTop(true)
end

function HeroAttrPage:InitZhuAttr()
	self.zhu_attr = {{OBJ_ATTR.CREATURE_HP, OBJ_ATTR.CREATURE_MAX_HP}, {OBJ_ATTR.CREATURE_MP, OBJ_ATTR.CREATURE_MAX_MP},}
	local prof = ZhanjiangData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if prof then
		if GameEnum.ROLE_PROF_1 == prof then
			table.insert(self.zhu_attr,{OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MIN, OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MAX})
		elseif GameEnum.ROLE_PROF_2 == prof then
			table.insert(self.zhu_attr,{OBJ_ATTR.CREATURE_MAGIC_ATTACK_MIN, OBJ_ATTR.CREATURE_MAGIC_ATTACK_MAX})
		elseif GameEnum.ROLE_PROF_3 == prof then
			table.insert(self.zhu_attr,{OBJ_ATTR.CREATURE_WIZARD_ATTACK_MIN, OBJ_ATTR.CREATURE_WIZARD_ATTACK_MAX})
		end
	end
end

function HeroAttrPage:InitFuAttr()
	self.fu_attr = {
						{OBJ_ATTR.CREATURE_PHYSICAL_DEFENCE_MIN, OBJ_ATTR.CREATURE_PHYSICAL_DEFENCE_MAX}, 
						{OBJ_ATTR.CREATURE_MAGIC_DEFENCE_MIN, OBJ_ATTR.CREATURE_MAGIC_DEFENCE_MAX},
						OBJ_ATTR.CREATURE_HIT_RATE, 
						OBJ_ATTR.CREATURE_DOGE_RATE, 
						OBJ_ATTR.ACTOR_CRITRATE,
						OBJ_ATTR.ACTOR_RESISTANCECRIT,
						OBJ_ATTR.CREATURE_LUCK,
						OBJ_ATTR.CREATURE_HP_RENEW,
						"damage_reduction",
		           }

	-- local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	-- if GameEnum.ROLE_PROF_1 == prof then
	-- 	table.insert(self.fu_attr, 1, {OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MIN, OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MAX})
	-- elseif GameEnum.ROLE_PROF_2 == prof then
	-- 	table.insert(self.fu_attr, 1, {OBJ_ATTR.CREATURE_MAGIC_ATTACK_MIN, OBJ_ATTR.CREATURE_MAGIC_ATTACK_MAX})

	-- elseif GameEnum.ROLE_PROF_3 == prof then
	-- 	table.insert(self.fu_attr, 1, {OBJ_ATTR.CREATURE_WIZARD_ATTACK_MIN, OBJ_ATTR.CREATURE_WIZARD_ATTACK_MAX})
	-- end
end

function HeroAttrPage:BoolShowEquipOrShiZhuang(bool)
	self.view.node_t_list.layout_hero_attr.node:setVisible(not bool)
	self.view.node_t_list.layout_role_info.layout_shizhuang.node:setVisible(bool)
end

function HeroAttrPage:CreateBtn()
	-- if nil == self.tabbar_fashion then
	-- 	self.tabbar_fashion = Tabbar.New()
	-- 	self.tabbar_fashion:CreateWithNameList(self.view.node_t_list.layout_role_info.layout_shizhuang.node, 30, 560,
	-- 		BindTool.Bind1(self.SelectBtnCallback, self), Language.Role.TabGroup2, false, ResPath.GetCommon("toggle_105"))
	-- 	self.tabbar_fashion:SetSpaceInterval(5)
	-- end	
end

function HeroAttrPage:SelectBtnCallback(index)
	self.btn_index = index
	self:SetFashionData()
end

function HeroAttrPage:CreateFashionEquip()
	if self.property_list == nil then
		self.property_list = ListView.New()
		local ph = self.view.ph_list.ph_item_list
		self.property_list:Create(ph.x, ph.y, ph.w, ph.h, nil, FashionItem, nil, nil, self.view.ph_list.ph_panel_item)
		self.view.node_t_list.layout_role_info.layout_shizhuang.node:addChild(self.property_list:GetView(), 100, 100)
		self.property_list:GetView():setAnchorPoint(0,0)
		self.property_list:SetItemsInterval(10)
		self.property_list:SetMargin(5)
		self.property_list:SetJumpDirection(ListView.Top)
	end
end

function HeroAttrPage:SetFashionData()
	local total_data = RoleData.Instance:GetToTalData()
	self.property_list:JumpToTop(true)
	self.property_list:SetDataList(total_data[self.btn_index] or {})
end

function HeroAttrPage:OpenViewRuleTips()
	DescTip.Instance:SetContent(Language.Role.FashionDescContent, Language.Role.FashionDescTitle)
end
function HeroAttrPage:OpenCircleView()
	ViewManager.Instance:Open(ViewName.Circle)
end
