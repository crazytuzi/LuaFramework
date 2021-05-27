--角色简介页面
RoleIntroPage = RoleIntroPage or BaseClass()


function RoleIntroPage:__init()
	self.view = nil
	self.is_main_role = true
end	

function RoleIntroPage:__delete()
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
function RoleIntroPage:InitPage(view)
	self.view = view
	--绑定要操作的元素
	
	self.btn_index = 1
	self:InitZhuAttr()
	self:InitFuAttr()
	self:CreateZhuAttrList()
	self:CreateFuAttrList()
	--self:CreateFashionEquip()
	--self:CreateBtn()
	local cap_x, cap_y = self.view.node_tree.layout_role_info.layout_shuxing.jobText.node:getPosition()
	self.role_cap = NumberBar.New()
	self.role_cap:SetRootPath(ResPath.GetCommonPath("big_num_100_"))
	self.role_cap:SetPosition(cap_x - 190, cap_y - 25)
	self.role_cap:SetSpace(-2)
	self.view.node_t_list.layout_role_info.layout_shuxing.node:addChild(self.role_cap:GetView(), 300, 300)
	self:UpdateBattle()
	local job  = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_JOB_LEVEL)
	if job == 1 then
		self.view.node_t_list.layout_role_info.layout_shuxing.jobText.node:setString(Language.HeroGold.nameList[RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)+3])
	else
		self.view.node_t_list.layout_role_info.layout_shuxing.jobText.node:setString(Language.Common.ProfName[RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)])
	end
	self.view.node_t_list.layout_role_info.layout_shuxing.levelText.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) .. Language.Common.Zhuan .. RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) .. Language.Common.Ji)
	--self.view.node_t_list.layout_pk.pk_img_desc.node:setLocalZOrder(999)
	-- XUI.AddClickEventListener(self.view.node_t_list.layout_addition.img_qianghua.node, BindTool.Bind2(self.OpenRuleTips, self, 1))
	-- XUI.AddClickEventListener(self.view.node_t_list.layout_addition.img_gem.node, BindTool.Bind2(self.OpenRuleTips, self, 2))
	XUI.AddClickEventListener(self.view.node_t_list.layout_role_info.layout_shizhuang.btn_open_view.node, BindTool.Bind2(self.OpenViewRuleTips, self))
	-- XUI.AddClickEventListener(self.view.node_t_list.layout_role_info.layout_shuxing.btn_circle.node, BindTool.Bind2(self.OpenCircleView, self))
	self.view.node_t_list.layout_addition.img_qianghua.node:setVisible(false)
	self.view.node_t_list.layout_addition.img_gem.node:setVisible(false)
	self.view.node_t_list.layout_addition.img_equip.node:setVisible(false)
	self.view.node_t_list.btn_gem.node:setVisible(false)
	self.view.node_t_list.btn_suit_tip.node:setVisible(false)
	XUI.AddClickEventListener(self.view.node_t_list.btn_suit_tip.node, BindTool.Bind1(self.OnOpenSuitEquip, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_gem.node, BindTool.Bind1(self.OnOpenGemTip, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_compose.node, BindTool.Bind1(self.OnOpenComposeTip, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_wing.node, BindTool.Bind1(self.OnOpenWingTip, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_shouhun.node, BindTool.Bind1(self.OnOpenShouHunTip, self), true)

	
	-- self.view.node_t_list.layout_role_info.layout_shuxing.btn_circle.node:setVisible(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= 255)
	-- self.view.node_t_list.layout_addition.node:setLocalZOrder(999)
	
	self:InitEvent()
end	

--初始化事件
function RoleIntroPage:InitEvent()
	self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)

	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)			--监听物品数据变化
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)

	self.change_map = GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChangeComplete, self))
end

--移除事件
function RoleIntroPage:RemoveEvent()
	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end	
	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end

	if self.change_map then
		GlobalEventSystem:UnBind(self.change_map)
		self.change_map = nil
	end
end


function RoleIntroPage:UpdateBattle()
	self.role_cap:SetNumber(RoleData.Instance:GetBattle())
end	

function RoleIntroPage:OnSceneChangeComplete()
	self:UpdateBattle()
end

function RoleIntroPage:ItemDataChangeCallback()
	self.view:Flush(TabIndex.role_intro, "change_fashion")
end

--更新视图界面
function RoleIntroPage:UpdateData(data)
	self.view.node_t_list.layout_role_info.layout_shuxing.levelText.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) .. Language.Common.Zhuan .. RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) .. Language.Common.Ji)
	-- self.view.node_t_list.layout_role_info.layout_shuxing.btn_circle.node:setVisible(RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) >= 255)
	--for k,v in pairs(data) do
	
	--end
end	


function RoleIntroPage:RoleDataChangeCallback(key, value)
	local k1 = key
	local v1 = value

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
		end
		if fu_attr_change == true then
			break
		end
	end
	if fu_attr_change then
		self.fu_attr_list:SetDataList(self.fu_attr)
	end

	if k1 == OBJ_ATTR.ACTOR_BATTLE_POWER 
		or k1 == OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MAX 
		or k1 == OBJ_ATTR.CREATURE_MAGIC_ATTACK_MAX
		or k1 == OBJ_ATTR.CREATURE_WIZARD_ATTACK_MAX then

		self:UpdateBattle()
	end

	if k1 == OBJ_ATTR.ACTOR_FASHION_MAN 
		or k1 == OBJ_ATTR.ACTOR_FASHION_WOMEN 
		or k1 == OBJ_ATTR.ACTOR_HUANWU	
		or k1 == OBJ_ATTR.ACTOR_ZUJI 
		or k1 == OBJ_ATTR.ACTOR_ZHENQI 
		or k1 == OBJ_ATTR.ACTOR_USE_FASHION 
		or k1 == OBJ_ATTR.ACTOR_USE_FASHION_2 
		or k1 == OBJ_ATTR.ACTOR_HUANCHI then

		self.view:Flush(TabIndex.role_intro, "change_fashion")
	end
	self.view:Flush(TabIndex.role_intro)
	if k1 == OBJ_ATTR.ACTOR_JOB_LEVEL then
		local job  = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_JOB_LEVEL)
		if job == 1 then
			self.view.node_t_list.layout_role_info.layout_shuxing.jobText.node:setString(Language.HeroGold.nameList[RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)+3])
		else
			self.view.node_t_list.layout_role_info.layout_shuxing.jobText.node:setString(Language.Common.ProfName[RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)])
		end
	end

	-- print("key", key, value)
	-- --self:UpdateAdditionTip()
end

-- function RoleIntroPage:CreateRoleInfoWidget()
-- 	self.role_info_widget = RoleInfoView.New()
-- 	self.role_info_widget:CreateViewByUIConfig(self.view.ph_list.ph_role_info_widget, "equip")
-- 	self.view.root_node:addChild(self.role_info_widget:GetView(), 200) 
-- 	self.role_info_widget:SetRoleData(RoleData.Instance.role_vo)
-- 	-- self:BoolShowEquipOrShiZhuang(self.role_info_widget.btn_switch:isTogglePressed())
-- end

function RoleIntroPage:CreateZhuAttrList()
	self.zhu_attr_list = ListView.New()
	local ph_role_zhuattr_list = self.view.ph_list.ph_role_zhuattr_list
	self.zhu_attr_list:Create(ph_role_zhuattr_list.x, ph_role_zhuattr_list.y, ph_role_zhuattr_list.w, ph_role_zhuattr_list.h, nil, RoleAttrItem, nil, nil, self.view.ph_list.ph_role_attr_item)
	self.view.node_t_list.layout_role_info.layout_shuxing.node:addChild(self.zhu_attr_list:GetView(), 100, 100)
	self.zhu_attr_list:GetView():setAnchorPoint(0,0)
	self.zhu_attr_list:SetItemsInterval(8)
	-- self.zhu_attr_list:SetMargin(5)
	self.zhu_attr_list:SetDataList(self.zhu_attr)
	self.zhu_attr_list:JumpToTop(true)
end

function RoleIntroPage:CreateFuAttrList()
	self.fu_attr_list = ListView.New()
	local ph_role_fuattr_list = self.view.ph_list.ph_role_fuattr_list
	self.fu_attr_list:Create(ph_role_fuattr_list.x, ph_role_fuattr_list.y, ph_role_fuattr_list.w, ph_role_fuattr_list.h, nil, RoleAttrItem, nil, nil, self.view.ph_list.ph_role_attr_item)
	self.view.node_t_list.layout_role_info.layout_shuxing.node:addChild(self.fu_attr_list:GetView(), 100, 100)
	self.fu_attr_list:GetView():setAnchorPoint(0,0)
	self.fu_attr_list:SetItemsInterval(8)
	-- self.fu_attr_list:SetMargin(5)
	self.fu_attr_list:SetDataList(self.fu_attr)
	self.fu_attr_list:JumpToTop(true)
end

function RoleIntroPage:InitZhuAttr()
	self.zhu_attr = {{OBJ_ATTR.CREATURE_HP, OBJ_ATTR.CREATURE_MAX_HP}, {OBJ_ATTR.CREATURE_MP, OBJ_ATTR.CREATURE_MAX_MP}, {OBJ_ATTR.ACTOR_INNER, OBJ_ATTR.ACTOR_MAX_INNER},}
end

function RoleIntroPage:InitFuAttr()
	self.fu_attr = {
						{OBJ_ATTR.CREATURE_PHYSICAL_DEFENCE_MIN, OBJ_ATTR.CREATURE_PHYSICAL_DEFENCE_MAX}, 
						{OBJ_ATTR.CREATURE_MAGIC_DEFENCE_MIN, OBJ_ATTR.CREATURE_MAGIC_DEFENCE_MAX},
						OBJ_ATTR.CREATURE_HIT_RATE, 
						OBJ_ATTR.CREATURE_DOGE_RATE, 
						OBJ_ATTR.ACTOR_CRITRATE,
						OBJ_ATTR.ACTOR_RESISTANCECRIT,
						{OBJ_ATTR.CREATURE_LUCK,OBJ_ATTR.CREATURE_CURSE},
		           }

	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if GameEnum.ROLE_PROF_1 == prof then
		table.insert(self.fu_attr, 1, {OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MIN, OBJ_ATTR.CREATURE_PHYSICAL_ATTACK_MAX})
	elseif GameEnum.ROLE_PROF_2 == prof then
		table.insert(self.fu_attr, 1, {OBJ_ATTR.CREATURE_MAGIC_ATTACK_MIN, OBJ_ATTR.CREATURE_MAGIC_ATTACK_MAX})

	elseif GameEnum.ROLE_PROF_3 == prof then
		table.insert(self.fu_attr, 1, {OBJ_ATTR.CREATURE_WIZARD_ATTACK_MIN, OBJ_ATTR.CREATURE_WIZARD_ATTACK_MAX})
	end
end

function RoleIntroPage:BoolShowEquipOrShiZhuang(bool)
	self.view.node_t_list.layout_role_info.layout_shuxing.node:setVisible(not bool)
	self.view.node_t_list.layout_role_info.layout_shizhuang.node:setVisible(bool)
end

-- function RoleIntroPage:CreateBtn()
-- 	if nil == self.tabbar_fashion then
-- 		self.tabbar_fashion = Tabbar.New()
-- 		self.tabbar_fashion:CreateWithNameList(self.view.node_t_list.layout_role_info.layout_shizhuang.node, 30, 560,
-- 			BindTool.Bind1(self.SelectBtnCallback, self), Language.Role.TabGroup2, false, ResPath.GetCommon("toggle_105"))
-- 		self.tabbar_fashion:SetSpaceInterval(5)
-- 	end	
-- end

-- function RoleIntroPage:SelectBtnCallback(index)
-- 	self.btn_index = index
-- 	self:SetFashionData()
-- end

-- function RoleIntroPage:CreateFashionEquip()
-- 	if self.property_list == nil then
-- 		self.property_list = ListView.New()
-- 		local ph = self.view.ph_list.ph_item_list
-- 		self.property_list:Create(ph.x, ph.y, ph.w, ph.h, nil, FashionItem, nil, nil, self.view.ph_list.ph_panel_item)
-- 		self.view.node_t_list.layout_role_info.layout_shizhuang.node:addChild(self.property_list:GetView(), 100, 100)
-- 		self.property_list:GetView():setAnchorPoint(0,0)
-- 		self.property_list:SetItemsInterval(10)
-- 		self.property_list:SetMargin(5)
-- 		self.property_list:SetJumpDirection(ListView.Top)
-- 	end
-- end

-- function RoleIntroPage:SetFashionData()
-- 	local total_data = RoleData.Instance:GetToTalData()
-- 	self.property_list:JumpToTop(true)
-- 	self.property_list:SetDataList(total_data[self.btn_index] or {})
-- end

function RoleIntroPage:OpenViewRuleTips()
	DescTip.Instance:SetContent(Language.Role.FashionDescContent, Language.Role.FashionDescTitle)
end
-- function RoleIntroPage:OpenCircleView()
-- 	ViewManager.Instance:Open(ViewName.Circle)
-- end

function RoleIntroPage:OnOpenSuitEquip()
	RoleCtrl.Instance:OpenGodSuitView()
end

function RoleIntroPage:OnOpenGemTip()
	ViewManager.Instance:Open(ViewName.UnionProperty)
	ViewManager.Instance:FlushView(ViewName.UnionProperty, 0, "fumo")
end

function RoleIntroPage:OnOpenComposeTip()
	ViewManager.Instance:Open(ViewName.UnionProperty)
	ViewManager.Instance:FlushView(ViewName.UnionProperty, 0, "Compose")
end

function RoleIntroPage:OnOpenWingTip()
	ViewManager.Instance:Open(ViewName.UnionProperty)
	ViewManager.Instance:FlushView(ViewName.UnionProperty, 0, "wing")
end

function RoleIntroPage:OnOpenShouHunTip()
	ViewManager.Instance:Open(ViewName.UnionProperty)
	ViewManager.Instance:FlushView(ViewName.UnionProperty, 0, "shouhun")
end


