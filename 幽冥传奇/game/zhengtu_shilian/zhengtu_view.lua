ZhengtuView = ZhengtuView or BaseClass(BaseView)

function ZhengtuView:__init()
	self.title_img_path = ResPath.GetWord("word_zhengtu")
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/zhengtu_shilian.png',
	}

	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"zhengtu_shilian_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.effect_res_id_list = {
		btn_zt = 280,
		item_1 = {281, 282},
		item_2 = {283, 284},
		item_3 = {285, 286},
		item_4 = {287, 288},
		item_5 = {289, 290},
		item_6 = {291, 292},
		item_7 = {293, 294},
		item_8 = {295, 296},
		item_9 = {297, 298},
		item_10 = {299, 300},
	}
end

function ZhengtuView:ReleaseCallBack()
	self.rounde_view:DeleteMe()
	self.rounde_view = nil

	self.cur_god_attr:DeleteMe()
	self.cur_god_attr = nil

	self.next_god_attr:DeleteMe()
	self.next_god_attr = nil
end

function ZhengtuView:LoadCallBack(index, loaded_times)
	self.rounde_view = self:CreateRoundeView()

	self.cur_god_attr = self:CreateGodEquipAttrView(self.node_t_list.layout_zhengtu.node, self.ph_list.ph_attr1)
	self.cur_god_attr:SetDefTitleText("未突破")

	self.next_god_attr = self:CreateGodEquipAttrView(self.node_t_list.layout_zhengtu.node, self.ph_list.ph_attr2)
	self.next_god_attr:SetDefTitleText("已达到最高级")

	self.btn_zhengtu = RenderUnit.CreateEffect(23, self.node_t_list.btn_zhengtu.node, 1000)

	local act_part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RING_CRYSTAL)
	if act_part_num % 10 == 0 and act_part_num > 0 and act_part_num < 100 then
		self.node_t_list.btn_zhengtu.node:setTitleText("突破")
	else
		self.node_t_list.btn_zhengtu.node:setTitleText("升级")
	end

	XUI.AddClickEventListener(self.node_t_list.btn_zhengtu.node,function () 
			local act_part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RING_CRYSTAL)
			if self.node_t_list.btn_zhengtu.node:getTitleText() == "突破" then
				self.rounde_view.BoomShow()
				self.node_t_list.btn_zhengtu.node:setTitleText("升级")
			else
				ZhengtuShilianCtrl.SendZhengtuUpReq()
			end

		end, true)
end

function ZhengtuView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
end

function ZhengtuView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ZhengtuView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_RING_CRYSTAL then
		if vo.value % 10 == 0 and vo.value > 0 and vo.value < 100 then
			self.node_t_list.btn_zhengtu.node:setTitleText("突破")
		end
		self.rounde_view.FireOne()
		-- self.rounde_view.FlushPartNum()
		self:Flush()

		RenderUnit.PlayEffectOnce(17, self.node_t_list.layout_zhengtu.node, 1000, 700, 240)
	elseif key == OBJ_ATTR.ACTOR_SOUL2 then

	end
end

function ZhengtuView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	-- RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
end

function ZhengtuView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "all" then
		end
	end

	--属性
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local attr_cfg = JourneyAttrsConfig[prof]

	local act_part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RING_CRYSTAL) --每关需手动激活；激活关数 >= 征途 X 10；可激活下一征途
	local zhengtu_num = math.floor(act_part_num / 100)							--征途数

	self.cur_god_attr:SetData(attr_cfg[act_part_num])
	self.next_god_attr:SetData(attr_cfg[act_part_num + 1] and attr_cfg[act_part_num + 1] or nil)
 
	--关卡数
	local part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	self.node_t_list.lbl_part_num.node:setString("当前关卡数: " .. part_num)

	self.btn_zhengtu:setVisible(part_num >= (act_part_num + 1) * 10)
end



function ZhengtuView:CreateGodEquipAttrView(parent_node, ph)
	local attr_view = AttrView.New(300, 25, 20)
	attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	attr_view:GetView():setPosition(ph.x, ph.y)
	attr_view:GetView():setAnchorPoint(0.5, 0.5)
	attr_view:SetContentWH(ph.w, ph.h)
	parent_node:addChild(attr_view:GetView(), 50)
	return attr_view
end

function ZhengtuView:CreateRoundeView()
	local view = {}

	local view_pos = cc.p(440, 340)

	local act_part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RING_CRYSTAL) --每关需手动激活；激活关数 >= 征途 X 10；可激活下一征途
	local now_act_num = (act_part_num % 10 == 0 and act_part_num > 0) and 10 or act_part_num % 10 		--当前征途激活关卡数 1 - 10

	view.show_idx = 1		--展示图标
	view.item_list = {}		--每个可激活的魄
	view.pos_list = {}		--坐标列表
	view.is_act = false

	for index = 1, 10 do
		view.pos_list[index] = self.ph_list["ph_item_" .. index]
	end

	-- 创建item
	local function create_item(index)
		local effect_id = self.effect_res_id_list["item_" .. index] --1 激活后特效  2 激活特效
		local pos_index = index

		local item = BaseRender.New()
		item:SetUiConfig(self.ph_list.ph_item, true)

		--设置UI
		item.node_tree.img_round.node:loadTexture(ResPath.GetZhengTuShiLian(index))
		item.node_tree.layout_tip.img_name.node:loadTexture(ResPath.GetZhengTuShiLian("name_" .. index))
		item.node_tree.img_bg.node:setVisible(index == 1)

  		local bar = NumberBar.New()
  		bar:SetRootPath(ResPath.GetZhengTuShiLian("scene_num_03_"))
  		bar:SetPosition(0, 0)
  		bar:SetSpace(-8)
  		bar:GetView():setScale(0.4)
  		bar:SetGravity(NumberBarGravity.Right)
  		item.node_tree.layout_tip.img_part.node:addChild(bar:GetView(), 300, 300)

		item.effect = RenderUnit.CreateEffect(effect_id[1], item:GetView(), 1000)
		item.effect:setVisible(index <= now_act_num)
		item.effect:setAnchorPoint(0.5, 0.45)


		item:SetPosition(self.ph_list["ph_item_" .. index].x, self.ph_list["ph_item_" .. index].y)

		--根据征途显示关数
		item.SetPartNum = function (idx, is_preview)
			act_part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RING_CRYSTAL) --每关需手动激活；激活关数 >= 征途 X 10；可激活下一征途
			index = idx or index

			local part_num = 0
			if act_part_num % 10 == 0 and act_part_num > 0 then 
				if is_preview then
					part_num = (act_part_num)  * 10 + index * 10
				else
					part_num = (act_part_num - 10)  * 10 + index * 10
				end
			else
				part_num = act_part_num >= 10 and math.floor(act_part_num / 10) * 100 + index * 10 or index * 10
			end
			
			item.node_tree.layout_tip.img_part.node:setPositionX(part_num >= 100 and 80 or 70)
			bar:SetNumber(part_num)
		end

		item.OnFlush = function (item)
			if nil == item.data then return end
			local one_index = item.data.index
			item.effect:removeFromParent()
			item.effect = RenderUnit.CreateEffect(self.effect_res_id_list["item_" .. one_index][1], item:GetView(), 1000)
			item.node_tree.layout_tip.img_name.node:loadTexture(ResPath.GetZhengTuShiLian("name_" .. one_index))
			item.effect:setAnchorPoint(0.5, 0.45)
			item.SetPartNum(one_index)
		end

		item.FlushPos = function (offset)
			if offset <= 0 then return end 
			view.is_act = true
			item.node_tree.layout_tip.node:setVisible(false)

			local num = pos_index + 1000 + offset
			pos_index = num % 10 == 0 and 10 or num % 10 
			
			local scale_to, opacity_to = item.GetMoveParams(view.pos_list[pos_index])

			item:GetView():runAction(cc.Sequence:create(
				cc.Spawn:create(cc.MoveTo:create(0.3, view.pos_list[pos_index]), cc.ScaleTo:create(0.3, scale_to)),
				cc.CallFunc:create(function()
						view.is_act = false
						item.node_tree.layout_tip.node:setVisible(true)
						item:GetView():setOpacity(opacity_to)
					end))
				)
		end


		--缩放系数 
		function item.GetMoveParams(aim_pos)
			-- local min_y = view.pos_list[1].y
			-- local max_y = view.pos_list[10].y

			local min_y = 227
			local max_y = 505

			local min_scale = 0.7
			local min_opacity = 150

			local y = aim_pos and aim_pos.y or math.floor(item:GetView():getPositionY())
			local param = (max_y - y) / (max_y - min_y) --越高 参数越小
			local scale_to = min_scale + param * (1 - min_scale)
			local opacity_to = min_opacity + param * (255 - min_opacity)

			return scale_to, opacity_to
		end

		--更新透视效果 pos_index 的 Y坐标越大效果越明显
		function item.UpdatePerspective()
			local scale_to, opacity_to = item.GetMoveParams()
			item:GetView():setScale(scale_to)
			item:GetView():setOpacity(opacity_to)
		end


		item.PlayBoom = function ()
			view.is_act = true
			item.effect:setVisible(false)
			item.node_tree.layout_tip.node:setVisible(false)
			RenderUnit.PlayEffectOnce(effect_id[2], item:GetView(), 300, 50, 86, true, function ()
						--爆炸后消失
						-- item:GetView():setVisible(false)
					end)

			-- 播放爆炸特效
			item:GetView():runAction(cc.Sequence:create(
				--移动至圆心 act1
				cc.MoveTo:create(1.5, view_pos),
				--移动至圆心后回调 act2
				cc.CallFunc:create(function()
					--爆炸回调
					item:SetPosition(view.pos_list[index].x, view.pos_list[index].y)
					-- item:GetView():setVisible(true)
					-- item.effect:setVisible(index == 1)
					item.node_tree.layout_tip.node:setVisible(true)
					item.node_tree.img_bg.node:setVisible(index == 1)
					item.SetPartNum(nil, true)
					view.is_act = false
				end))
			)
		end


		item.GetPosIdx = function ()
			return	pos_index
		end

		self.node_t_list.layout_zhengtu.node:addChild(item:GetView(), 300)

		--点击事件
		-- item:AddClickEventListener(function ()
		-- 		if view.show_idx ~= index then
		-- 			view.ChangeShowIndex(index)
		-- 		end
		-- 	end)

		return item
	end

	--item创建
	for i = 1, 10 do
		local item = create_item(i)
		item.SetPartNum(i)
		item.UpdatePerspective()
		view.item_list[i] = item
	end

	local ph = self.ph_list.ph_show_item

	local show_item  = create_item(1) 
	show_item:GetView():setPosition(ph.x, ph.y)
	show_item.SetPartNum(1)

	function view.GetIsAct()
		return view.is_act
	end

	function view.FireOne()
		act_part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RING_CRYSTAL) --每关需手动激活；激活关数 >= 征途 X 10；可激活下一征途
		now_act_num = (act_part_num % 10 == 0 and act_part_num > 0) and 10 or act_part_num % 10					--当前征途激活关卡数 1 - 10

		if now_act_num <= 0 then return end

		view.show_idx = now_act_num

		for i,v in ipairs(view.item_list) do
			v.node_tree.img_bg.node:setVisible(i == now_act_num)
			v.effect:setVisible(i <= now_act_num)
		end

		-- if now_act_num == 1 and act_part_num > 1 then
		-- 	view.BoomShow()
		-- else
		-- 	view.ChangeShowIndex(now_act_num)
		-- end
		view.ChangeShowIndex(now_act_num)
	end

	function view.ChangeShowIndex(show_index)
		show_item:SetData({index = show_index})

		local offset = 0
		if nil == view.item_list[show_index] then return end
		offset = view.item_list[show_index].GetPosIdx() - 1
		offset = offset > 0 and 10 - offset or offset

		for i,v in ipairs(view.item_list) do
			v.FlushPos(offset)
		end
	end

	function view.DeleteMe()
		for k,v in pairs(view.item_list) do
			v:DeleteMe()
		end
	end

	function view.FlushPartNum()
		for i,v in ipairs(view.item_list) do
			v.SetPartNum(i)
		end
	end

	function view.BoomShow()
		for i,v in ipairs(view.item_list) do
			v.PlayBoom()
		end
	end

	view.FireOne()
	return view
end