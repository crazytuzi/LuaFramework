------------------------------------------------------------
--人物技能View.升级学习相关
------------------------------------------------------------
local SkillView = BaseClass(SubView)
SkillView.SpecialListMaxCount = 2

function SkillView:__init()
	self.title_img_path = ResPath.GetWord("word_skill")
	self.texture_path_list = {}
	self.config_tab = {
		{"skill_ui_cfg", 1, {0}},
	}
	self.auto_skill_change = GlobalEventSystem:Bind(SettingEventType.AUTO_SKILL_CHANGE, BindTool.Bind(self.AutoSkillChange,self))
	self.cur_select_skill_data = nil
end

function SkillView:__delete()
end

function SkillView:LoadCallBack()
	self.select_skill_index = 1
	self.is_select_special_list = false
	self:InitFpDisplay()
	self:InitTextBtn()

	self:CreateSkillList()
	XUI.AddClickEventListener(self.node_t_list["btn_play"].node, BindTool.Bind(self.OnPlay, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_skill_upgrade"].node, BindTool.Bind(self.OnSkillUpgrade, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_rexue_skill_upgrade"].node, BindTool.Bind(self.OnRexueSkillUpgrade, self), true)
	XUI.AddClickEventListener(self.node_t_list["img_skill_tip"].node, BindTool.Bind(self.OnSkillTip, self), true)

	EventProxy.New(SkillData.Instance, self):AddEventListener(SkillData.SKILL_EXP_CHANGE, BindTool.Bind(self.OnSkillExpChange, self))
	EventProxy.New(SkillData.Instance, self):AddEventListener(SkillData.SKILL_DATA_CHANGE, BindTool.Bind(self.Flush, self))
end


function SkillView:OnSkillTip( ... )
	DescTip.Instance:SetContent(Language.DescTip.SKillContent, Language.DescTip.SKillTitle)
end

function SkillView:ReleaseCallBack()
	if self.skill_list then
		self.skill_list:DeleteMe()
		self.skill_list = nil
	end
	
	self.select_skill = nil
	self.select_skill_id = nil
	self.skill_demo_role = nil
	self.skill_demo_effect = nil
end

function SkillView:ShowIndexCallBack()
	self:Flush()
end

function SkillView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			self:CreateSkillList()

			local n_list, s_list = SkillData.Instance:GetShowSkillList()
			self.skill_list:SetDataList(n_list)
			self.skill_list:SelectIndex(self.select_skill_index)
		elseif k == "skill_auto" then
			local n_list, s_list = SkillData.Instance:GetShowSkillList()
			local cell = self.skill_list:GetItemAt(self.select_skill_index)
			if cell then
				cell:SetData(n_list[self.select_skill_index])
			end
		elseif k == "skill_exp" then
			local skill_id = v.skill_id or 1
			local n_list, s_list = SkillData.Instance:GetShowSkillList()
			local index
			for i,v in ipairs(n_list) do
				if v.id == skill_id then
					index = i
				end
			end
			local cell = self.skill_list:GetItemAt(index)
			if cell then
				cell:SetData(n_list[index])
			end
			if v.skill_id == self.select_skill_id then
				self:FlushSkillInfo()
			end
		end
	end
end

function SkillView:AutoSkillChange()
	self:Flush(0, "skill_auto")
end

function SkillView:OnSkillExpChange(skill_id)
	self:Flush(0, "skill_exp", {skill_id = skill_id})
end

function SkillView:OnFlushSkillListView()
	self.skill_list:GetView():setContentSize(cc.size(self.n_size.width, self.n_size.height))

	local n_list, s_list = SkillData.Instance:GetShowSkillList()
	local ph_render = self.ph_list.ph_skill_item
	if nil == n_list or nil == s_list or nil == ph_render then return end
	local h = ph_render.h + 5

	local count = #s_list
	if count <= 0 and self.is_select_special_list then
		self.select_skill_index = 1
		self.is_select_special_list = false
	end
	count = math.min(SkillView.SpecialListMaxCount, count)

	self.skill_list:GetView():setContentSize(cc.size(self.n_size.width, self.n_size.height - count * h))
end

function SkillView:OnClickSkillAuto()
	if nil == self.select_skill_id then return end
	local client_index = SkillData.Instance:GetSkillClientIndex(self.select_skill_id)
	if client_index > 0 then
		SettingCtrl.Instance:ChangeAutoSkillSetting({[client_index] = not vis})
	end
	self:Flush(0, "skill_auto")
end

function SkillView:CreateSkillList()
	if self.skill_list == nil then
		local ph = self.ph_list.ph_skill_list
		self.skill_list = ListView.New()
		self.skill_list:Create(ph.x, ph.y, ph.w, ph.h, nil, SkillListRender, nil, nil, self.ph_list.ph_skill_item)
		self.skill_list:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_role_skill.node:addChild(self.skill_list:GetView(), 100)
		self.skill_list:SetItemsInterval(5)
		self.skill_list:SetJumpDirection(ListView.Top)
		self.skill_list:SetSelectCallBack(BindTool.Bind1(self.SelectSkillCallBack, self))
	end
end

function SkillView:SelectSkillCallBack(item)
	if nil == item or nil == item:GetData() then return end
	local data = item:GetData()

	self.select_skill_index = item:GetIndex()
	self.select_skill_id = data.id

	self:ResetFpDisplay()
	self:FlushSkillInfo()
end

function SkillView:FlushSkillInfo()
	-- self.node_t_list["btn_skill_upgrade"].node:setEnabled(false)
	local client_index = SkillData.Instance:GetSkillClientIndex(self.select_skill_id)
	local skill_info = SkillData.Instance:GetSkill(self.select_skill_id)
	local show_auto_use = skill_info ~= nil and (self.is_select_special_list or SettingData.ShowSkillAutoSetting(self.select_skill_id))
	self.node_t_list.lbl_n_skill_lv_need.node:setColor(Str2C3b("918369"))
	if nil == skill_info then
		skill_info = {skill_level = 1, skill_exp = 0}
	end

	-- 热血神装技能特殊处理
	if self.select_skill_id == 122 or self.select_skill_id == 123 then
		self.node_t_list["layout_rexue_skill_upgrade"].node:setVisible(true)
		self.node_t_list["layout_skill_upgrade"].node:setVisible(false)
	else
		self.node_t_list["layout_rexue_skill_upgrade"].node:setVisible(false)
		self.node_t_list["layout_skill_upgrade"].node:setVisible(true)
	end

	if skill_info then
		local cur_level = skill_info.skill_level + SkillData.Instance:GetRefineSkillLevel(self.select_skill_id)
		local next_level = cur_level + 1
		local lv_cfg = SkillData.GetSkillLvCfg(self.select_skill_id, cur_level)
		RichTextUtil.ParseRichText(self.node_t_list.rich_cur_skill_content.node, Language.Role.SkillInstruct .. lv_cfg.desc)

		local mp = 0
		for k,v in pairs(lv_cfg.spellConds) do
			if v.cond == SkillData.SKILL_CONDITION.MP then
				mp = v.value
			end
		end

		local n_lv_cfg = SkillData.GetSkillLvCfg(self.select_skill_id, next_level)
		local n_mp = 0
		local max_sld = 0
		local consume_id = 0
		local consume_count = 1
		local color = COLOR3B.GREEN
		if n_lv_cfg then
			local n_lv = 0
			for k,v in pairs(n_lv_cfg.trainConds) do
				if v.cond == SkillData.SKILL_CONDITION.LEVEL then
					n_lv = v.value
				end
				if v.cond == SkillData.SKILL_CONDITION.SLD then
					max_sld = v.value
				end
				if v.cond == SkillData.SKILL_CONDITION.SKILL_BOOK then
					consume_id = v.value
					consume_count = v.count
				end
			end
			self.node_t_list.lbl_n_skill_lv_need.node:setString(n_lv .. Language.Common.Ji)
			for k,v in pairs(n_lv_cfg.spellConds) do
				if v.cond == SkillData.SKILL_CONDITION.MP then
					n_mp = v.value
				end
			end
			color = skill_info.skill_exp >= max_sld and COLOR3B.GREEN or COLOR3B.RED
		else
			self.node_t_list.lbl_n_skill_lv_need.node:setString(Language.Role.SKillMaxLevel)
			self.node_t_list.lbl_n_skill_lv_need.node:setColor(Str2C3b("DCD7C4"))
			n_mp = Language.Common.MaxLevel
			max_sld = Language.Common.MaxLevel
		end


		self.node_t_list["lbl_shuliandu"].node:setString(string.format(Language.Role.ShuLianDu, skill_info.skill_exp or 0, max_sld))
		self.node_t_list["lbl_shuliandu"].node:setColor(color)

		local rich = self.node_t_list["rich_consume"].node
		local consume_cfg = ItemData.Instance:GetItemConfig(consume_id)
		local consume_bag_count = BagData.Instance:GetItemNumInBagById(consume_id) or 0
		local color = consume_bag_count >= consume_count and COLORSTR.GREEN or COLORSTR.RED
		local text = string.format("{color;%06x;%s}{color;%s;(%d/%d)}", consume_cfg.color or 0, consume_cfg.name, color, consume_bag_count, consume_count)
		rich = RichTextUtil.ParseRichText(rich, text, 22, COLOR3B.GREEN)
		rich:setVisible(true)
		self.consume_enough = consume_bag_count >= consume_count
		self.consume_id = consume_id
		self.exp_enough = n_lv_cfg and skill_info.skill_exp >= max_sld
	else
		self.node_t_list["lbl_shuliandu"].node:setString(Language.Common.No)
		self.node_t_list["lbl_shuliandu"].node:setColor(COLOR3B.RED)
		RichTextUtil.ParseRichText(self.node_t_list.rich_cur_skill_content.node, "{color;FFFFFFFF;" .. Language.Common.No .. "}")
		local n_lv_cfg = SkillData.GetSkillLvCfg(self.select_skill_id, 1)
		local n_lv = 0
		for k,v in pairs(n_lv_cfg.trainConds) do
			if v.cond == SkillData.SKILL_CONDITION.LEVEL then
				n_lv = v.value
			end
		end
		self.node_t_list.lbl_n_skill_lv_need.node:setString(n_lv .. Language.Common.Ji)
	end
end

function SkillView:InitTextBtn()
	local ph
	local text_btn
	ph = self.ph_list["ph_text_btn_1"]
	text_btn = RichTextUtil.CreateLinkText(Language.Role.SkillTextBtn[1], 19, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	self.node_t_list["layout_skill_upgrade"].node:addChild(text_btn, 9)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self, 1), true)

	ph = self.ph_list["ph_text_btn_2"]
	text_btn = RichTextUtil.CreateLinkText(Language.Role.SkillTextBtn[2], 19, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	self.node_t_list["layout_skill_upgrade"].node:addChild(text_btn, 9)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self, 2), true)
end

function SkillView:OnTextBtn(index)
	if index == 1 then
		if nil == self.select_skill_id then return end
			local item_id = 444
			if BagData.Instance:GetItemNumInBagById(item_id) > 0 then
				SkillCtrl.SendUseSkillDanReq(self.select_skill_id)
			else
				local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
				local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
				TipCtrl.Instance:OpenGetNewStuffTip(item_id)
			end
	else
		if BagData.Instance:GetIsOpenByIndex(3) then
			ViewManager.Instance:OpenViewByDef(ViewDef.MainBagView.ComspoePanel)
			ViewManager.Instance:FlushViewByDef(ViewDef.MainBagView.ComspoePanel, 0, "changeTabbar", {index = ClientComposeType.Cailiao, second_index = ClientSecondComposeType.skill})
			ViewManager.Instance:CloseViewByDef(ViewDef.Skill)
		else
			SysMsgCtrl.Instance:FloatingTopRightText("技能书合成未开放")
		end
	end
end

function SkillView:InitFpDisplay()
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
	self.node_t_list["layout_play"].node:addChild(self.img_role, 1)
	self.node_t_list["layout_play"].node:setClippingEnabled(true)

	self.skill_demo_role = AnimateSprite:create()
	self.skill_demo_role:setPosition(x, y)
	self.skill_demo_role:setScale(0.75)
	self.node_t_list["layout_play"].node:addChild(self.skill_demo_role, 9)
	self.skill_demo_role:addEventListener(function(node, type, index)
		if type == 2 and index ~= 0 then
			if self.play_times > 0 then
				local anim_path, anim_name = ResPath.GetRoleAnimPath(41, "wait", GameMath.DirRight)
				node:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk, false)
			end
		end
	end)

	self.skill_demo_effect = AnimateSprite:create()
	self.skill_demo_effect:setPosition(x, y)
	self.skill_demo_effect:setScale(0.6)
	self.node_t_list["layout_play"].node:addChild(self.skill_demo_effect, 8)
	self.skill_demo_effect:addEventListener(function(node, type, index)
		if type == 2 and index ~= 0 then
			if self.play_times <=0 then
				self.node_t_list["btn_play"].node:setVisible(true)
				self.skill_demo_role:setVisible(false)
				node:setVisible(false)
				self.img_role:setVisible(true)
				self.img_skill:setVisible(true)
			end
		end
	end)

	-- self.skill_demo_wuqi = AnimateSprite:create()
	-- self.skill_demo_wuqi:setPosition(x, y)
	-- self.skill_demo_wuqi:setScale(0.6)
	-- self.node_t_list["layout_play"].node:addChild(self.skill_demo_wuqi, 8)
	-- self.skill_demo_wuqi:addEventListener(function(node, type, index)
	-- 	if type == 2 and index ~= 0 then
	-- 		if self.play_times <=0 then
	-- 			self.node_t_list["btn_play"].node:setVisible(true)
	-- 			self.skill_demo_wuqi:setVisible(false)
	-- 			node:setVisible(false)
	-- 		end
	-- 	end
	-- end)
end

function SkillView:ResetFpDisplay()
	if nil == self.node_t_list["layout_play"] then
		return
	end

	self.is_demo_playing = false

	self.img_role:setVisible(true)
	self.img_skill:setVisible(true)
	self.img_skill:loadTexture(ResPath.GetBigPainting("skill_show_" .. self.select_skill_index))

	self.play_times = 0
	self.skill_demo_role:setStop()
	self.skill_demo_effect:setStop()
	-- self.skill_demo_wuqi:setStop()
	-- self.skill_demo_effect:setVisible(false)
	-- self.skill_demo_role:setVisible(false)

	self.node_t_list["btn_play"].node:setVisible(true)

	GlobalTimerQuest:CancelQuest(self.play_timer)
end

function SkillView:OnPlay()
	if nil == self.select_skill_id then
		return
	end

	self.is_demo_playing = true
	self.node_t_list["btn_play"].node:setVisible(false)
	self.img_role:setVisible(false)
	self.img_skill:setVisible(false)
	self.skill_demo_effect:setVisible(true)
	self.skill_demo_role:setVisible(true)
	-- self.skill_demo_wuqi:setVisible(true)

	local timer_func = function(self)
		local skill_info = SkillData.Instance:GetSkill(self.select_skill_id)
		local skill_level = skill_info and skill_info.skill_level or 1
		local cur_level = skill_level + SkillData.Instance:GetRefineSkillLevel(self.select_skill_id)
		local lv_cfg = SkillData.GetSkillLvCfg(self.select_skill_id, cur_level)

		local layout_size = self.node_t_list["layout_play"].node:getContentSize()
		local x, y = layout_size.width / 2, layout_size.height / 2 - 30
		local res_id
		if self.select_skill_id == 122 then
			res_id = 108
		elseif self.select_skill_id == 123 then
			res_id = 109
			x, y = layout_size.width / 2 + 60, layout_size.height / 2 + 30
		elseif lv_cfg.actRange[1].acts[1].specialEffects[1] then
			local id = lv_cfg.actRange[1].acts[1].specialEffects[1].id
			res_id = id > 10000 and id + GameMath.DirRight or id
		else
			if self.select_skill_id == 9 then
				res_id = 83 --+ GameMath.DirRight
			else
				res_id = lv_cfg.actions[1].effect + GameMath.DirRight
			end						
			--res_id = lv_cfg.actions[1].effect + GameMath.DirRight
		end
		self.skill_demo_effect:setPosition(x, y)

		local anim_path, anim_name = "", ""
		self.skill_demo_role:setStop()
		anim_path, anim_name = ResPath.GetRoleAnimPath(41, "atk1", GameMath.DirRight)
		self.skill_demo_role:setAnimate(anim_path, anim_name, 1, FrameTime.Run, false)
		self.skill_demo_effect:setStop()
		anim_path, anim_name = ResPath.GetEffectAnimPath(res_id)
		self.skill_demo_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)

		-- self.skill_demo_wuqi:setStop()
		-- anim_path, anim_name = ResPath.GetWuqiAnimPath(1, "atk1", GameMath.DirRight)
		-- self.skill_demo_wuqi:setAnimate(anim_path, anim_name, 1, FrameTime.Run, false)
		self.play_times = self.play_times - 1
		if self.play_times == 0 then
			self.skill_demo_role:setStop()
			self.skill_demo_effect:setStop()
		end
	end
	self.play_times = 6
	timer_func(self)
	self.play_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind(timer_func, self), 1, self.play_times)
end

function SkillView:OnSkillUpgrade()
	if nil == self.select_skill_id then return end

	if self.consume_enough and self.exp_enough then
		SkillCtrl.SendUpSkillReq(self.select_skill_id)
	elseif not self.consume_enough then
		local item_id = self.consume_id
		local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
		local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
		if ShopData.GetItemPriceCfg(item_id) then
			TipCtrl.Instance:OpenGetNewStuffTip(item_id)
		else
			TipCtrl.Instance:OpenBuyTip(data)
		end
		
	elseif not self.exp_enough then
		local item_id = 444
		local ways = CLIENT_GAME_GLOBAL_CFG.item_get_ways[item_id]
		local data = string.format("{reward;0;%d;1}", item_id) .. (ways and ways or "")
		if ShopData.GetItemPriceCfg(item_id) then
			TipCtrl.Instance:OpenGetNewStuffTip(item_id)
		else
			TipCtrl.Instance:OpenBuyTip(data)
		end
	end
end

function SkillView:OnRexueSkillUpgrade()
	ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.RexueGodEquip)
	ViewManager.Instance:CloseViewByDef(ViewDef.Skill)
end

----------------------------------------------------------------------------------------------------
-- 技能item
----------------------------------------------------------------------------------------------------
SkillListRender = SkillListRender or BaseClass(BaseRender)
function SkillListRender:__init()
end

function SkillListRender:__delete()
	self.proficiency_bar = nil
end

function SkillListRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
    	self.cache_select = false
    	self:CreateSelectEffect()
	end

	if nil == self.proficiency_bar then
		local x, y = self.node_tree["prog_bg"].node:getPosition()
		self.proficiency_bar = XUI.CreateLoadingBar(x, y, ResPath.GetCommon("prog_122_progress"), XUI.IS_PLIST)
		self.view:addChild(self.proficiency_bar, 3)
	end

	-- XUI.AddClickEventListener(self.node_tree["layout_auto"].node, BindTool.Bind(self.OnAuto, self), true)
end

function SkillListRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.lbl_skill_name.node:setString(self.data.name)
	self.node_tree.img_cur_skill.node:loadTexture(ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(self.data.id)))
	self.node_tree.img_cur_skill.node:setScale(0.7)

	local skill_info = SkillData.Instance:GetSkill(self.data.id)
	local show_auto_use = skill_info ~= nil and SettingData.ShowSkillAutoSetting(self.data.id)
	self.node_tree["layout_auto"].node:setVisible(false and show_auto_use)
	self.node_tree.img_cur_skill.node:setGrey(skill_info == nil)
	if skill_info then
		local refine_level = SkillData.Instance:GetRefineSkillLevel(self.data.id)
		local lv_str = "Lv." .. skill_info.skill_level
		if refine_level > 0 then
			lv_str = lv_str .. " {wordcolor;00ff00;(+" .. refine_level .. ")}"
		end
		RichTextUtil.ParseRichText(self.node_tree.rich_skill_lv.node, lv_str, 22)
		local client_index = SkillData.Instance:GetSkillClientIndex(self.data.id)
		local is_auto = SettingCtrl.Instance:GetAutoSkillSetting(client_index)
		self.node_tree["layout_auto"]["img_open"].node:setVisible(is_auto)
		self.node_tree["layout_auto"]["img_close"].node:setVisible(not is_auto)
		local max_sld = 0
		local skill_n_lv_cfg = SkillData.GetSkillLvCfg(self.data.id, skill_info.skill_level + 1)
		if skill_n_lv_cfg then
			for k,v in pairs(skill_n_lv_cfg.trainConds) do
				if v.cond == SkillData.SKILL_CONDITION.SLD then
					max_sld = v.value
				end
			end
			if max_sld == 0 then
				self.node_tree.lbl_shuliandu.node:setString(string.format(Language.Role.ShuLianDu, 100, 100))
				self.proficiency_bar:setPercent(100)
			else
				self.node_tree.lbl_shuliandu.node:setString(string.format(Language.Role.ShuLianDu, skill_info.skill_exp, max_sld))
				local percent = math.min(skill_info.skill_exp / max_sld * 100, 1)
				self.proficiency_bar:setPercent(skill_info.skill_exp / max_sld * 100)
			end
		else
			local skill_lv_cfg = SkillData.GetSkillLvCfg(self.data.id, skill_info.skill_level)
			for k,v in pairs(skill_lv_cfg.trainConds) do
				if v.cond == SkillData.SKILL_CONDITION.SLD then
					max_sld = v.value
				end
			end
			if max_sld == 0 then
				self.node_tree.lbl_shuliandu.node:setString(string.format(Language.Role.ShuLianDu, 100, 100))
				self.proficiency_bar:setPercent(100)
			else
				self.node_tree.lbl_shuliandu.node:setString(string.format(Language.Role.ShuLianDu, max_sld, max_sld))
				self.proficiency_bar:setPercent(100)
			end
		end
	else
		RichTextUtil.ParseRichText(self.node_tree.rich_skill_lv.node, "Lv.0", 22)
		self.node_tree.lbl_shuliandu.node:setString(string.format(Language.Role.ShuLianDu, 0, 0))
		self.proficiency_bar:setPercent(0)
	end
end

function SkillListRender:OnAuto()
	local client_index = SkillData.Instance:GetSkillClientIndex(self.data.id)
	local is_auto = SettingCtrl.Instance:GetAutoSkillSetting(client_index)
	if client_index > 0 then
		SettingCtrl.Instance:ChangeAutoSkillSetting({[client_index] = not is_auto})
	end
end

-- 创建选中特效
function SkillListRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_285"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end


--------------------------------------
-- 特殊技能
--------------------------------------
SpecialSkillListRender = SpecialSkillListRender or BaseClass(BaseRender)
function SpecialSkillListRender:__init()
	
end

function SpecialSkillListRender:__delete()

end

function SpecialSkillListRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.cache_select and self.is_select then
    	self.cache_select = false
    	self:CreateSelectEffect()
    end

	self.node_tree.rich_skill_lv.node:setHorizontalAlignment(RichHAlignment.HA_RIGHT)
	XUI.AddClickEventListener(self.node_tree["layout_auto"].node, BindTool.Bind(self.OnAuto, self), true)
end

function SpecialSkillListRender:OnFlush()
	if nil == self.data then return end

	self.node_tree.lbl_skill_name.node:setString(self.data.name)
	self.node_tree.img_cur_skill.node:loadTexture(ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(self.data.id)))
	local skill_info = SkillData.Instance:GetSkill(self.data.id)
	local show_auto_use = skill_info ~= nil
	self.node_tree["layout_auto"].node:setVisible(show_auto_use)

	self.node_tree.img_cur_skill.node:setGrey(skill_info == nil)
	if skill_info then
		RichTextUtil.ParseRichText(self.node_tree.rich_skill_lv.node, "Lv." .. skill_info.skill_level, 22)
		local client_index = SkillData.Instance:GetSkillClientIndex(self.data.id)
		local is_auto = SettingCtrl.Instance:GetAutoSkillSetting(client_index) and 1 or 2
		self.node_tree["layout_auto"]["img_open"].node:setVisible(is_auto)
		self.node_tree["layout_auto"]["img_close"].node:setVisible(not is_auto)
		local max_sld = 0
		if skill_info.skill_level + 1 <= 3 then
			local skill_n_lv_cfg = SkillData.GetSkillLvCfg(self.data.id, skill_info.skill_level + 1)
			for k,v in pairs(skill_n_lv_cfg.trainConds) do
				if v.cond == SkillData.SKILL_CONDITION.SLD then
					max_sld = v.value
				end
			end
			if max_sld == 0 then
				self.node_tree.lbl_shuliandu.node:setString(string.format(Language.Role.ShuLianDu, 100, 100))
			else
				self.node_tree.lbl_shuliandu.node:setString(string.format(Language.Role.ShuLianDu, skill_info.skill_exp, max_sld))
			end
		else
			local skill_lv_cfg = SkillData.GetSkillLvCfg(self.data.id, skill_info.skill_level)
			for k,v in pairs(skill_lv_cfg.trainConds) do
				if v.cond == SkillData.SKILL_CONDITION.SLD then
					max_sld = v.value
				end
			end
			if max_sld == 0 then
				self.node_tree.lbl_shuliandu.node:setString(string.format(Language.Role.ShuLianDu, 100, 100))
			else
				self.node_tree.lbl_shuliandu.node:setString(string.format(Language.Role.ShuLianDu, max_sld, max_sld))
			end
		end
	else
		RichTextUtil.ParseRichText(self.node_tree.rich_skill_lv.node, "Lv.0", 22)
		self.node_tree.lbl_shuliandu.node:setString(string.format(Language.Role.ShuLianDu, 0, 100))
	end
end

function SkillListRender:OnAuto()
	local client_index = SkillData.Instance:GetSkillClientIndex(self.data.id)
	local is_auto = SettingCtrl.Instance:GetAutoSkillSetting(client_index)
	if client_index > 0 then
		SettingCtrl.Instance:ChangeAutoSkillSetting({[client_index] = not is_auto})
	end
end

-- 创建选中特效
function SpecialSkillListRender:CreateSelectEffect()
end


return SkillView