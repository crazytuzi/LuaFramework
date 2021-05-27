SkillSpecialTip = SkillSpecialTip or BaseClass(BaseView)
function SkillSpecialTip:__init( ... )
	self.is_any_click_close = true		
	self.is_modal =true
	self.config_tab = {
		{"itemtip_ui_cfg", 20, {0}}
	}
end

function SkillSpecialTip:__delete( ... )
	-- body
end


function SkillSpecialTip:ReleaseCallBack( ... )
	if self.skill_demo_role then
		self.skill_demo_role:setStop()
		self.skill_demo_role = nil
	end

	if self.skill_demo_effect then
		self.skill_demo_effect:setStop()
		self.skill_demo_effect = nil
	end
	if self.effect then
		for k, v  in pairs(self.effect) do
			v:setStop()
			v = nil
		end
	end
end

function SkillSpecialTip:LoadCallBack( ... )
	self.is_demo_playing = false
	local layout_size = self.node_t_list["layout_play"].node:getContentSize()
	local x, y = layout_size.width / 2, layout_size.height / 2 -30
	
	local bg = XUI.CreateImageView(0, layout_size.height / 2, ResPath.GetBigPainting("foot_print_scene", true))
	bg:setAnchorPoint(0, 0.5)
	self.img_skill = XUI.CreateImageView(x, y, ResPath.GetBigPainting("skill_show_1", false))
	self.img_role = XUI.CreateImageView(x, y, ResPath.GetBigPainting("skill_role_atk", false))
	self.img_role:setScale(0.75)
	self.img_skill:setScale(0.6)
	self.node_t_list["layout_play"].node:addChild(bg, 0)
	self.node_t_list["layout_play"].node:addChild(self.img_skill, 1)
	self.node_t_list["layout_play"].node:addChild(self.img_role, 100)
	self.node_t_list["layout_play"].node:setClippingEnabled(true)

	self.skill_demo_role = AnimateSprite:create()
	self.skill_demo_role:setPosition(x, y)
	self.skill_demo_role:setScale(0.75)
	self.node_t_list["layout_play"].node:addChild(self.skill_demo_role, 9)
	self.skill_demo_role:addEventListener(function(node, type, index)
		-- if type == 2 and index ~= 0 then
		-- 	if self.play_times > 0 then
		-- 		local anim_path, anim_name = ResPath.GetRoleAnimPath(41, "wait", GameMath.DirRight)
		-- 		node:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk, false)
		-- 	end
		-- end
	end)
	self.effect = {}
	local offest = {
		{110, 100},
		{160, 100},
		{210, 100},
		{270, 100},
		{110, 160},
		{290, 160},
		{110, 220},
		{160, 220},
		{210, 220},
		{260, 220},
	}
	for i=1,10 do
		local offestx = offest[i]
		animate =AnimateSprite:create()
		animate:setPosition(offestx[1] , offestx[2])
		animate:setScale(0.5)
		self.node_t_list["layout_play"].node:addChild(animate, 9)
		table.insert(self.effect, animate)
	end

	self.skill_demo_effect = AnimateSprite:create()
	self.skill_demo_effect:setPosition(x, y)
	self.skill_demo_effect:setScale(0.6)
	self.node_t_list["layout_play"].node:addChild(self.skill_demo_effect, 8)
	-- self.skill_demo_effect:addEventListener(function(node, type, index)
	-- 	if type == 2 and index ~= 0 then
	-- 		if self.play_times <=0 then
	-- 			--self.node_t_list["btn_play"].node:setVisible(true)
	-- 			--self.skill_demo_role:setVisible(false)
	-- 			node:setVisible(false)
	-- 			self.img_role:setVisible(true)
	-- 			self.img_skill:setVisible(true)
	-- 		end
	-- 	end
	-- end)
	self.select_skill_id = nil
	self.select_skill_lv = nil

	XUI.AddClickEventListener(self.node_t_list.btn_go.node, BindTool.Bind1(self.OpenView, self))
	--XUI.AddClickEventListener(self.node_t_list["btn_play"].node, BindTool.Bind(self.OnPlay, self), true)

end

function SkillSpecialTip:OnPlay()
	if nil == self.select_skill_id then
		return
	end

	self.is_demo_playing = true
	--self.node_t_list["btn_play"].node:setVisible(false)
	self.img_role:setVisible(false)
	self.img_skill:setVisible(false)
	self.skill_demo_effect:setVisible(false)
	self.skill_demo_role:setVisible(true)
	-- self.skill_demo_wuqi:setVisible(true)

	local timer_func = function(self)
		local skill_info = SkillData.Instance:GetSkill(self.select_skill_id)
		local res_id
		local skill_level = self.select_skill_lv
		local cur_level =  self.select_skill_lv == 0 and 1 or self.select_skill_lv
		--local lv_cfg = SkillData.GetSkillLvCfg(self.select_skill_id, cur_level)

		-- if lv_cfg.actRange[1].acts[1].specialEffects[1] then
		-- 	res_id = lv_cfg.actRange[1].acts[1].specialEffects[1].id
		-- end

		local anim_path, anim_name = "", ""
		self.skill_demo_role:setStop()
		
		for k,v in pairs(self.effect) do
			v:setStop()
		end
		local res_id = 0
		if self.select_skill_id == 122 then

			res_id = 108
			anim_path, anim_name = ResPath.GetRoleAnimPath(41, "stand", GameMath.DirRight)
			self.skill_demo_role:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Run, false)
			self.skill_demo_effect:setVisible(true)
			self.skill_demo_effect:setStop()
			anim_path, anim_name = ResPath.GetEffectAnimPath(res_id)
			self.skill_demo_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		elseif self.select_skill_id == 123 then
			anim_path, anim_name = ResPath.GetRoleAnimPath(41, "atk1", GameMath.DirRight)
			self.skill_demo_role:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Run, false)
			res_id = 109
			for k,v in pairs(self.effect) do
				v:setStop()
				anim_path, anim_name = ResPath.GetEffectAnimPath(res_id)
				v:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			end
		else 
			res_id = 20
			anim_path, anim_name = ResPath.GetRoleAnimPath(41, "atk1", GameMath.DirRight)
			self.skill_demo_role:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Run, false)
			self.skill_demo_effect:setVisible(true)
			self.skill_demo_effect:setStop()
			anim_path, anim_name = ResPath.GetEffectUiAnimPath(res_id)
			self.skill_demo_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		end
		--self.play_times = self.play_times - 1
	end
-- 	self.play_times = 5
	timer_func(self)
-- 	self.play_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind(timer_func, self), 1, self.play_times)
end


function SkillSpecialTip:OpenCallBack( ... )
	-- body
end

function SkillSpecialTip:CloseCallBack( ... )
	-- body
end

function SkillSpecialTip:ShowIndexCallBack(index)
	self:Flush(index)
end

function SkillSpecialTip:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "param1" then
			self.select_skill_id = v.skill_id
			self.select_skill_lv = v.skill_level
			self.suit_type = v.suit_type
			self.suit_level = v.suit_level

			local path = ResPath.GetSkillIcon("sign_had")
			if self.select_skill_lv > 0 then
				path = ResPath.GetSkillIcon("img_had")
			end
			self.node_t_list.img_sign.node:loadTexture(path)

			local path1 = ResPath.GetSkillIcon("skill_name_img")
			local path2 =  ResPath.GetSkillIcon("skill_show_name_img")
			if self.select_skill_id == 123 then
				path1 = ResPath.GetSkillIcon("skill_name_img2")
				path2 =  ResPath.GetSkillIcon("skill_show_name_img2")
			elseif VirtualSkillCfg[self.select_skill_id] then
				path1 = ResPath.GetSkillIcon("skill_name_img3")
				path2 =  ResPath.GetSkillIcon("skill_show_name_img3")
			end

			self.node_t_list.text_name_img.node:loadTexture(path1)
			self.node_t_list.text_name_bg2.node:loadTexture(path2)


			local type_data = RexueSuitEquipName[self.suit_type]
			if VirtualSkillCfg[self.select_skill_id] then
				type_data = HaoZhuangSuitTypeByType[self.suit_type]
			end
			local text2 = "" 
			local text21 = ""
			local text22 = ""
			for k,v in pairs(type_data) do
				local item_type = EquipData.Instance:GetTypeByEquipSlot(v)
				if VirtualSkillCfg[self.select_skill_id] then
					item_type = v
				end
				local name = Language.EquipTypeName[item_type]
				local equip =  EquipData.Instance:GetEquipDataBySolt(v)
				local color = "a6a6a6"
				if equip then
					local itemm_config = ItemData.Instance:GetItemConfig(equip.item_id)
				
					if itemm_config.suitId >= self.suit_level then
						color = "00ff00"
					end
				end
				if k <= 4 then
					text21 = text21 .. string.format(Language.HaoZhuang.active2, color, name) .. " "
				else
					text22 = text22 .. string.format(Language.HaoZhuang.active2, color, name) .. " "
				end
			end
			local text23 = text22 ~= "" and (text22 .."\n") or ""
			local text2 = text21 .. "\n"..text23
			local text_all = string.format(Language.HaoZhuang.active1, text2)
			RichTextUtil.ParseRichText(self.node_t_list.text_had.node, text_all)
			XUI.RichTextSetCenter(self.node_t_list.text_had.node)

			local lv_cfg = SkillData.GetSkillLvCfg(self.select_skill_id, self.select_skill_lv == 0 and 1 or self.select_skill_lv)

			if  VirtualSkillCfg[self.select_skill_id] then
				lv_cfg = VirtualSkillCfg[self.select_skill_id]
			end
			if lv_cfg.desc then
				RichTextUtil.ParseRichText(self.node_t_list.text_desc.node, lv_cfg.desc)
				--XUI.RichTextSetCenter(self.node_t_list.text_desc.node)
			end
			self:OnPlay()
		end
	end
end


function SkillSpecialTip:OpenView( ... )
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore.RareTreasure)
end

-- ViewDef.Explore = {name = "探索宝藏", default_child = "Xunbao", v_open_cond = "CondId24",
-- 	Xunbao 	= {name = "探宝",},
-- 	Fullserpro = {name = "全服进度",},
-- 	RareTreasure = {name = "龙皇秘宝",},
-- 	Exchange = {name = "积分兑换",},
-- 	Rareplace = {name = "龙皇秘境",},
-- 	Storage = {name = "寻宝仓库",},	
-- 	PrizeInfo 	= {name = "奖励详情",},
-- }