--------------------------------------------------------
-- 挖掘boss  配置 DiamondsPetsConfig
--------------------------------------------------------

ExcavateBossView = ExcavateBossView or BaseClass()

function ExcavateBossView:__init(obj_id)
	self.obj_id = obj_id

	GlobalEventSystem:Bind(ObjectEventType.OBJ_ATTR_CHANGE, BindTool.Bind(self.ObjAttrChange, self))
end

function ExcavateBossView:ObjAttrChange(obj, change_type, ascription)
	if change_type == "ascription" then
		if obj.vo.obj_id == self.obj_id then
			local role_vo = GameVoManager.Instance:GetMainRoleVo()
			local role_name = role_vo.name or ""
			if type(ascription) == "table" and ascription[2] == role_name then
				self:Flush()
			end
		end
	end
end

function ExcavateBossView:__delete()
	if self.need_fly then
		self:StartFlyItem()
	else
		for i,v in ipairs(self.diamond_icon_list or {}) do
			v:removeFromParent()
		 end
		self.diamond_icon_list = {}
	end

	if self.main_role_pos_change then
		GlobalEventSystem:UnBind(self.main_role_pos_change)
		self.main_role_pos_change = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

	if self.cell_list then
		self.cell_list:DeleteMe()
		self.cell_list = nil
	end

	if self.progressbar then
		self.progressbar:DeleteMe()
		self.progressbar = nil
	end

	if self.prog_node then
		self.prog_node:removeFromParent()
		self.prog_node = nil
	end

	if self.prog_bg then
		self.prog_bg:removeFromParent()
		self.prog_bg = nil
	end

	if self.eff then
		self.eff:removeFromParent()
		self.eff = nil
	end

	GlobalEventSystem:Fire(OtherEventType.SETTING_GUAJI_TYPE_SHOW, true)

	if self.parent then
		GlobalEventSystem:Fire(OtherEventType.EXCAVATE_BOSS, self.obj_id, "delete")
	end
end

function ExcavateBossView:Flush()
	local obj = Scene.Instance:GetObjectByObjId(self.obj_id)
	if nil == obj then
		ErrorLog("怪物不存在")
		return
	end

	local monster_id = obj.vo.monster_id or 0
	local ascription = obj.vo.ascription or ""
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local role_name = role_vo.name or ""
	local pet_data = DiamondPetData.Instance:GetDiamondPetData()
	local pet_lv = pet_data.pet_lv or 0
	local cfg = DiamondsPetsConfig and DiamondsPetsConfig.level or {}
	local cur_cfg = cfg[pet_lv] or {}
	local max_times = cur_cfg.limit or 0
	if pet_data.excavate_times >= max_times or role_name ~= ascription then
		self:SetVisible(false)
		obj.can_excavate = false
		obj:RefreshAnimation()
		return
	else
		self:SetVisible(true)
	end

	if nil == self.parent then
		-- 创建布局
		self.parent = XUI.CreateLayout(0, 0, 676, 443)
		obj:GetModel():AttachNode(self.parent, cc.p(15, 380), GRQ_SCENE_OBJ, InnerLayerType.ExcavateBoss, true)

		local ph_item = ConfigManager.Instance:GetUiConfig("diamond_pet_ui_cfg")[3]
		self.node_tree = {}
		self.ph_list = {}
		XUI.Parse(ph_item, self.parent, nil, self.node_tree, self.ph_list)

		GlobalEventSystem:Fire(OtherEventType.EXCAVATE_BOSS, self.obj_id, "add")
	end

	----------------------------
	-- 挖掘奖励
	----------------------------
	if nil == self.cell_list then
		local ph = self.ph_list["ph_cells"]
		local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
		local parent = self.parent
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 25, BaseCell, ScrollDir.Horizontal, false, ph_item)
		parent:addChild(grid_scroll:GetView(), 99)
		self.cell_list = grid_scroll
	end
	------------------------------
	-- 挖掘奖励end
	------------------------------

	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1176)
	local x, y = -13, 50 -- 坐标偏移
	obj.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, InnerLayerType.Main, anim_path, anim_name, 
	false, FrameTime.Effect, nil, COMMON_CONSTS.MAX_LOOPS, nil, x, y)

	local cfg = DiamondsPetsConfig and DiamondsPetsConfig.level or {}
	local cur_cfg = cfg[pet_lv] or {}
	local awards = cur_cfg.awards and cur_cfg.awards[1] or {}
	local rate_awards = cur_cfg.rateAwards or {}
	local show_list = {}
	local awards_data = ItemData.InitItemDataByCfg(awards)
	awards_data.num = 1
	show_list[#show_list + 1] = awards_data
	for i,v in ipairs(rate_awards) do
		if v.show_type then
			local item_data = ItemData.InitItemDataByCfg(v)
			show_list[#show_list + 1] = item_data
		end
	end
	self.cell_list:SetDataList(show_list)

	-- 居中处理
	self.cell_list:SetCenter()
	self.cell_list:GetView():jumpToTop()
end

function ExcavateBossView:Excavate() -- 挖掘
	local obj = Scene.Instance:GetObjectByObjId(self.obj_id)
	if nil == self.parent or type(obj) ~= "table" or obj.has_been_excavated then
		return
	end

	DiamondPetCtrl.Instance:SetExcavatState(true)
	GlobalEventSystem:Fire(OtherEventType.SETTING_GUAJI_TYPE_SHOW, false)

	-- 创建钻石动画
	local pet_data = DiamondPetData.Instance:GetDiamondPetData()
	local pet_lv = pet_data.pet_lv or 0
	local cfg = DiamondsPetsConfig and DiamondsPetsConfig.level or {}
	local cur_cfg = cfg[pet_lv] or {}
	local awards = cur_cfg.awards and cur_cfg.awards[1] or {}
	local item_data = ItemData.InitItemDataByCfg(awards) or {}
	local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id or 0)
	local path = ResPath.GetItem(tonumber(item_cfg.icon))
	if nil == self.timer then
		for i,v in ipairs(self.diamond_icon_list or {}) do
			v:removeFromParent()
		end
		self.diamond_icon_list = {}
		self.need_fly = false

		local diamond_max = cur_cfg.diamondMax or 0
		self.need_play_action = pet_data.today_diamond < diamond_max
		self.need_play_count = 20 or math.random(15, 20)
		local function callback(parent)
			local spawn, img
			if self.need_play_action then
				local x = math.random(-125, 125) + 320
				local y = math.random(-62, 62) - 80
				img = XUI.CreateImageView(320, -80, path, XUI.IS_PLIST)
				img:setScale(0)
				self.parent:addChild(img, 99, 99)
				local scale_to = cc.ScaleTo:create(0.8, 1)
				local jump_to = cc.JumpTo:create(0.8, cc.p(x, y), 100, 1)
				spawn = cc.Spawn:create(scale_to, jump_to)

				self.diamond_icon_list[#self.diamond_icon_list + 1] = img
			end

			-- 最后一个增加回调
			self.need_play_count = self.need_play_count - 1
			if self.need_play_count <= 0 then
				local callback = function()
					-- 挖掘成功
					-- 取消人物移动监听
					if self.main_role_pos_change then
						GlobalEventSystem:UnBind(self.main_role_pos_change)
						self.main_role_pos_change = nil
					end
					-- 更改飞行图标父节点
					for i,v in ipairs(self.diamond_icon_list) do
						self:ChangeParent(v)
					end
					self.need_fly = true -- 清理 self.diamond_icon_list 需要执行飞行动作

					if self.timer then
						GlobalTimerQuest:CancelQuest(self.timer)
						self.timer = nil
					end
					DiamondPetCtrl.SendExcavateMonsterCorpseReq(self.obj_id or 0)
				end

				if self.need_play_action then
					spawn = cc.Sequence:create(spawn, cc.CallFunc:create(callback))			
				else
					if self.timer then
						GlobalTimerQuest:CancelQuest(self.timer)
					end
					self.timer = GlobalTimerQuest:AddTimesTimer(callback, 0.8, 1)
				end
			end

			if img then
				img:runAction(spawn)
			end
		end
		self.timer = GlobalTimerQuest:AddTimesTimer(callback, (5-0.8)/self.need_play_count, self.need_play_count)
	end

	local path, name = ResPath.GetEffectUiAnimPath(1177)
	if nil == self.eff then
		self.eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		local x = HandleRenderUnit:GetWidth() / 2 - 260
		local y = HandleRenderUnit:GetHeight() / 2 - 310
		self:ChangeParent(self.eff, x, y)
	else
		self.eff:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end

	if nil == self.progressbar then
		self:CreateProgressbar()
	else
		self.prog_bg:setVisible(true)
		self.prog_node:setVisible(true)
		self.progressbar:SetPercent(0)
	end

	self.progressbar:SetPercent(100, true)

	-- 挖掘完成之前,人物操作移动时,取消挖掘
	if nil == self.main_role_pos_change then
		self.main_role_pos_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, function()
			if self.timer then
				GlobalTimerQuest:CancelQuest(self.timer)
				self.timer = nil
			end

			for i,v in ipairs(self.diamond_icon_list) do
				v:stopAllActions()
				v:removeFromParent()
			end
			self.diamond_icon_list = {}

			if self.progressbar then
				self.progressbar:StopTween()
			end

			DiamondPetCtrl.Instance:SetObjId()
			DiamondPetCtrl.Instance:SetExcavatState(false)
			GlobalEventSystem:Fire(OtherEventType.SETTING_GUAJI_TYPE_SHOW, true)

			GlobalEventSystem:UnBind(self.main_role_pos_change)
			self.main_role_pos_change = nil
		end)
	end
end

function ExcavateBossView:CreateProgressbar()
	self.prog_bg = XUI.CreateImageViewScale9(0, 0, 330, 24, ResPath.GetCommon("prog_125"), XUI.IS_PLIST, cc.rect(8,9,12,5))
	self.prog_node = XUI.CreateLoadingBar(0, 0, ResPath.GetCommon("prog_125_progress"),  XUI.IS_PLIST, nil, true, 320, 14, cc.rect(6,6,5,2))
	self.prog_bg:setAnchorPoint(0.5, 0.5)
	self.prog_node:setAnchorPoint(0.5, 0.5)
	local x = HandleRenderUnit:GetWidth() / 2
	local y = HandleRenderUnit:GetHeight() / 2
	self:ChangeParent(self.prog_bg, x - 160, y - 200)
	self:ChangeParent(self.prog_node, x - 160 + 3, y - 200 + 5)
	self.progressbar = ProgressBar.New()
	self.progressbar:SetView(self.prog_node)
	self.progressbar:SetTailEffect(991, nil, true)
	self.progressbar:SetEffectOffsetX(-20)
	self.progressbar:SetPercent(0)
	self.progressbar:SetTotalTime(5)
	self.progressbar:SetCompleteCallback(function()
		self.eff:setStop()
		local percent = self.progressbar:GetCurPercent()
		if percent >= 100 then
			if self.prog_node then
				self.prog_node:removeFromParent()
				self.prog_node = nil
			end

			if self.prog_bg then
				self.prog_bg:removeFromParent()
				self.prog_bg = nil
			end

			if self.progressbar then
				self.progressbar:DeleteMe()
				self.progressbar = nil
			end
		end
	end)
end

function ExcavateBossView:ChangeParent(fly_icon, x, y)
	local ui_node = HandleRenderUnit:GetUiNode()
	local world_pos = fly_icon:convertToWorldSpace(cc.p(0, 0))

	-- 更改飞行图标父节点
	fly_icon:setAnchorPoint(0, 0)
	fly_icon:retain()
	fly_icon:removeFromParent(false)
	HandleRenderUnit:AddUi(fly_icon, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)
	fly_icon:release()
	fly_icon:setPosition(x or world_pos.x, y or world_pos.y)
end

function ExcavateBossView:StartFlyItem()
	local fly_to_target = ViewManager.Instance:GetUiNode("MainUi", NodeName.MainuiRoleBar)
	local fly_to_pos = fly_to_target:convertToWorldSpace(cc.p(0,0))
	for i,v in ipairs(self.diamond_icon_list) do
		local world_pos = v:convertToWorldSpace(cc.p(0, 0))
		v:setPosition(world_pos.x, world_pos.y)

		local move_to =cc.MoveTo:create(0.8, cc.p(fly_to_pos.x, fly_to_pos.y))
		local spawn = cc.Spawn:create(move_to)
		local callback = cc.CallFunc:create(BindTool.Bind2(self.ItemFlyEnd, self, v))
		local action = cc.Sequence:create(spawn, callback)
		v:runAction(action)
	end
	self.need_fly = false
	local obj = Scene.Instance:GetObjectByObjId(self.obj_id) or {}
	obj.has_been_excavated = true -- 已挖掘过
	DiamondPetCtrl.Instance:SetExcavatState(false)
	DiamondPetCtrl.Instance:SetObjId()
	
	self.diamond_icon_list = {}
end

function ExcavateBossView:ItemFlyEnd(fly_icon)
	if fly_icon then
		fly_icon:removeFromParent()
	end
end

function ExcavateBossView:SetVisible(vis) -- 设置面板显示状态
	if nil ~= self.parent then
		self.parent:setVisible(vis)
	end
end
