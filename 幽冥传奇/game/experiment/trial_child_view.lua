------------------------------------------------------------
-- 试炼 配置 TrialConfig
------------------------------------------------------------

local TrialChildView = BaseClass(SubView)

function TrialChildView:__init()
	self.texture_path_list = {
		'res/xui/experiment.png'
	}
	self.config_tab = {
		{"trial_ui_cfg", 1, {0}},
	}
end

function TrialChildView:__delete()
end

function TrialChildView:ReleaseCallBack()
	self.boss_eff = nil
	self.role = nil
	self.weapon = nil
	self.auto_fight = nil
	self.skill = nil
	self.fly_icon = nil
	
	if self.fly_timer then
		GlobalTimerQuest:CancelQuest(self.fly_timer)
		self.fly_timer = nil
	end
end

function TrialChildView:LoadCallBack(index, loaded_times)
	self:CreateCheckpointList()
	self:InitTextBtn()

	local cfg = TrialConfig and TrialConfig.diamondsPlus or {}
	local gjtime = 0
	for k,v in pairs(cfg) do
		if v.gjtime > gjtime then
			gjtime = v.gjtime
		end
	end
	gjtime = math.floor(gjtime / 60 / 60)
	local tip_text = string.format(Language.Trial.EarningsMaxTime, gjtime)
	self.node_t_list["lbl_tip_text"].node:setString(tip_text)

	--按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_tip"].node, BindTool.Bind(self.OnTip, self))
	XUI.AddClickEventListener(self.node_t_list["btn_world"].node, BindTool.Bind(self.OnWorld, self))
	XUI.AddClickEventListener(self.node_t_list["btn_challenge"].node, BindTool.Bind(self.OnChallenge, self))
	XUI.AddClickEventListener(self.node_t_list["btn_receive_gj_award"].node, BindTool.Bind(self.OnReceiveGjAward, self))

	-- 数据监听
	EventProxy.New(ExperimentData.Instance, self):AddEventListener(ExperimentData.TRIAL_DATA_CHANGE, BindTool.Bind(self.FlushEarnings, self))
end
function TrialChildView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()

	if self.fly_timer then
		GlobalTimerQuest:CancelQuest(self.fly_timer)
		self.fly_timer = nil
	end
end


--显示索引回调
function TrialChildView:ShowIndexCallBack(index)
	self.add_award_index = nil
	ExperimentCtrl.SendTrialDataReq()
	self.node_t_list["layout_add_award"].node:setVisible(false)
	self.sum = 0
	self:Flush()
end

----------视图函数----------

function TrialChildView:OnFlush()
	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local section_count, floor = ExperimentData.GetSectionAndFloor(guan_index)
	local section, difficult = ExperimentData.GetSectionAndDifficult()
	self.node_t_list["lbl_section"].node:setString(string.format(Language.Trial.SectionTitle, section, floor))

	local path = ResPath.GetExperiment("trial_section_lv_" .. section)
	self.node_t_list["trial_section_lv"].node:loadTexture(path)

	local path = ResPath.GetExperiment("trial_difficult_" .. difficult)
	self.node_t_list["trial_difficult"].node:loadTexture(path)

	self:FlushConditions()
	self:FlushCheckpointList()
	self:FlushAward()
	self:FlushCartoon()
end

function TrialChildView:InitTextBtn()
	local ph
	local text_btn
	local parent = self.node_t_list["layout_trial"].node

	ph = self.ph_list["ph_text_btn"]
	text_btn = RichTextUtil.CreateLinkText("VIP特权", 22, COLOR3B.GREEN)
	text_btn:setPosition(ph.x, ph.y)
	parent:addChild(text_btn, 99)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnTextBtn, self), true)
end

function TrialChildView:CreateCheckpointList()
	local ph = self.ph_list["ph_checkpoint_list"]
	local ph_item = self.ph_list["ph_checkpoint_item"]
	local parent = self.node_t_list["layout_trial"].node
	local render = self.TrialFloorItem
	local callback = BindTool.Bind(self.OnTrialFloor, self)

	self.trial_floor_list = GridScroll.New()
	self.trial_floor_list:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w, render, ScrollDir.Horizontal, false, ph_item)
	self.trial_floor_list:SetSelectCallBack(callback)
	parent:addChild(self.trial_floor_list:GetView(), 20)
	self:AddObj('trial_floor_list')
end

function TrialChildView:FlushAward()
	local title_text = Language.Trial and Language.Trial.GjAwardsTitle or {}

	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local cfg = TrialConfig and TrialConfig.chapters or {}
	local cur_cfg = cfg[cur_trial_floor] or cfg[1] or {}
	local gjawards = cur_cfg.gjawards or {}
	local moneys = cur_cfg.moneys or {}

	for i = 1, 4 do
		if next(gjawards) and next(moneys) then
			local award, count, item
			if i == 1 then
				award = moneys[i] or {id = 0, type = 0, count = 0}
				count = award.count or 0
				count = count * 60 * 60
				item = ItemData.InitItemDataByCfg(award)
				self.fly_icon_id = item.item_id
				self.efficiency = award.count or 0
			else
				award = gjawards[i - 1] or {id = 0, type = 0, count = 0}
				count = (award.count or 0) * 6
				item = ItemData.InitItemDataByCfg(award)
			end
			count = CommonDataManager.ConverMoney(count)

			-- 图标
			item = ItemData.InitItemDataByCfg(award)
			local item_cfg = ItemData.Instance:GetItemConfig(item.item_id)
			local path = ResPath.GetItem(tonumber(item_cfg.icon))
			self.node_t_list["img_total_award_" .. i].node:loadTexture(path)
			self.node_t_list["img_total_award_" .. i].node:setScale(0.35)
			self.node_t_list["img_award_" .. i].node:loadTexture(path)
			self.node_t_list["img_award_" .. i].node:setScale(0.35)
			
			-- 每小时效率
			local text = count .. "/小时"
			self.node_t_list["lbl_award_" .. i].node:setString(text)
			self.node_t_list["lbl_award_title_" .. i].node:setString((title_text[i] or "") .. "：")

			self.node_t_list["img_total_award_" .. i].node:setVisible(true)
			self.node_t_list["img_award_" .. i].node:setVisible(true)
			self.node_t_list["lbl_award_" .. i].node:setVisible(true)
			self.node_t_list["lbl_award_title_" .. i].node:setVisible(true)
		else
			self.node_t_list["img_total_award_" .. i].node:setVisible(false)
			self.node_t_list["img_award_" .. i].node:setVisible(false)
			self.node_t_list["lbl_award_" .. i].node:setVisible(false)
			self.node_t_list["lbl_award_title_" .. i].node:setVisible(false)
		end
	end
end

function TrialChildView:FlushEarnings(data)
	local title_text = Language.Trial and Language.Trial.GjAwardsTitle or {}
	local data = data or ExperimentData.Instance:GetTrialData()
	local awards = data.awards or {}
	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	for i = 1, 4 do
		local num = awards[i] and awards[i].num or 0
		self.node_t_list["lbl_total_award_" .. i].node:setString((title_text[i] or "") .. "：" .. num)
		if i == 1 then
			self.sum = num
		end
	end

	if cur_trial_floor ~= 0 then
		local vip_lv = VipData.Instance:GetVipLevel()
		local cfg = TrialConfig and TrialConfig.diamondsPlus or {}
		local cur_cfg = cfg[vip_lv] or {}
		local all_hang_up_times = data and data.all_hang_up_times or 0
		local gjtime = cur_cfg.gjtime or 0
		if all_hang_up_times < gjtime then
			self:CreateFlyTimer(gjtime - all_hang_up_times)
		end
		self.auto_fight:setVisible(all_hang_up_times < gjtime)
	else
		self.auto_fight:setVisible(false)
	end

	local add_awards_tag = data.add_awards_tag or 100000 -- 已领取的关卡
	local section_count = TrialConfig and TrialConfig.section_count or 1
	local cur_tag_index = math.floor(cur_trial_floor / section_count)
	local guan_num = data.guan_num or 0

	-- 是否有未领取的额外奖励
	local cfg = TrialConfig and TrialConfig.chapters or {}
	self.add_award_index = nil
	for i = (add_awards_tag + 1), guan_num do
		if cfg[i] and cfg[i].addwards then
			self.add_award_index = i
			break
		end
	end

	local title = Language.Trial and Language.Trial.ChallengeTitle or {}
	if self.add_award_index then
		local trial_floor = self.add_award_index
		local cur_cfg = cfg[trial_floor] or {}
		local addwards = cur_cfg.addwards or {}
		self.node_t_list["layout_add_award"].node:setVisible(true)
		local item_id = addwards[1] and addwards[1].id or 0
		local num = addwards[1] and addwards[1].count or 0
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		self.node_t_list["lbl_item_name"].node:setString(item_cfg.name .. "×" .. num)
		local color = Str2C3b(string.format("%06x", item_cfg.color))
		self.node_t_list["lbl_item_name"].node:setColor(color)

		self.node_t_list["btn_challenge"].node:setTitleText(title[1] or "")
	else
		self.node_t_list["btn_challenge"].node:setTitleText(title[2] or "")
		self.node_t_list["layout_add_award"].node:setVisible(false)
	end
end

-- 刷新挑战条件
function TrialChildView:FlushConditions()
	local text = ""
	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local cfg = TrialConfig and TrialConfig.chapters or {}
	local cur_cfg = cfg[cur_trial_floor + 1] or {}
	local conditions = cur_cfg.conditions or {}
	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local wing_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL)
	local wing_jie, _ = WingData.GetWingLevelAndGrade(wing_lv)
	local role_data = {["level"] = role_lv, ["circle"] = circle;["swinglv"] = wing_lv}
	local conditions_key = {
		{"level", Language.Trial.ConditionsText[1]},  -- "{color;%s;等级：%d级}"
		{"circle", Language.Trial.ConditionsText[2]}, -- "  {color;%s;转生：%d转}"
		{"swinglv", Language.Trial.ConditionsText[3]},-- "  {color;%s;翅膀：%d阶}"
	}
	for i,v in ipairs(conditions_key) do
		local key = v[1]
		local conditions_lv = conditions[key] or 0
		if conditions_lv > 0 then
			if not(role_data[key] >= conditions_lv) then
				local color = role_data[key] >= conditions_lv and COLORSTR.GREEN or COLORSTR.RED
				if key == "swinglv" then
					local wing_jie, _ = WingData.GetWingLevelAndGrade(conditions_lv)
					text = text .. string.format(v[2], color, wing_jie)
				else
					text = text .. string.format(v[2], color, conditions_lv)
				end
			end
		end
	end
	RichTextUtil.ParseRichText(self.node_t_list["rich_conditions"].node, text, 20, COLOR3B.GREEN)
	XUI.RichTextSetCenter(self.node_t_list["rich_conditions"].node)
	self.node_t_list["rich_conditions"].node:refreshView()
end

function TrialChildView:FlushCheckpointList()
	local data_list = ExperimentData.Instance:GetCurTrialFloorList()
	self.trial_floor_list:SetDataList(data_list)

	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local index = 1
	for i,v in ipairs(data_list) do
		if v.guan_index == cur_trial_floor then
			index = i
		end
	end
	local view = self.trial_floor_list:GetView()
	local items = self.trial_floor_list:GetItems()
	local item_view = items[index] and items[index]:GetView()
	local ph_item = self.ph_list["ph_checkpoint_item"]
	local x, y = item_view:getPosition()
	view:setScorllDirection(ScrollDir.Horizontal)
	view:jumpToPosition(cc.p(-(x - ph_item.w / 2), y)) -- 跳至当前关卡
end

function TrialChildView:FlushCartoon()
	local ratio = 3

	-- boss外观
	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	local cfg = TrialConfig and TrialConfig.chapters or {}
	local cur_cfg = cfg[cur_trial_floor] or cfg[1] or {}
	local boss = cur_cfg.boss or {}
	local boss_cfg = BossData.GetMosterCfg(boss.monId or 1)
	local entityid = boss_cfg.modelid or 0
	local path, name = ResPath.GetMonsterAnimPath(entityid, SceneObjState.Atk, GameMath.DirRight)
	if nil == self.boss_eff then
		local ph = self.ph_list["ph_boss"]
		self.boss_eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk*7 / ratio, false)
		self.boss_eff:setPosition(ph.x, ph.y)
		self.node_t_list["layout_trial"].node:addChild(self.boss_eff, 999)
		self.boss_eff:setScaleX(-1)
	else
		self.boss_eff:setStop()
		self.boss_eff:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk*7 / ratio, false)
		self.boss_eff:setScaleX(-1)
	end

	-- 人物外观
	local yifu = EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itDressPos) or {}
	local yifu_cfg = ItemData.Instance:GetItemConfig(yifu.item_id)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local yifu_shape = yifu_cfg.shape ~= 0  and yifu_cfg.shape or 10000 + sex
	local ph = self.ph_list["ph_role"]
	local anim_path, anim_name = ResPath.GetRoleAnimPath(yifu_shape, "atk1", GameMath.DirRight)
	if nil == self.role then
		self.role = AnimateSprite:create(anim_path, anim_name, 1 or COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk * 6 / ratio, false)
		self.role:setPosition(ph.x, ph.y)
		self.node_t_list["layout_trial"].node:addChild(self.role, 999)
	else
		self.role:setStop()
		self.role:setAnimate(anim_path, anim_name, 1 or COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk*6 / ratio, false)
	end

	-- 武器外观
	local wuqi = EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itWeaponPos) or {}
	local wuqi_cfg = ItemData.Instance:GetItemConfig(wuqi.item_id)
	local wuqi_shape = wuqi_cfg.shape
	if wuqi_shape ~= 0 then
		local anim_path, anim_name = ResPath.GetWuqiAnimPath(wuqi_shape, "atk1", GameMath.DirRight)
		if nil == self.weapon then
			self.weapon = AnimateSprite:create(anim_path, anim_name, 1 or COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk * 6 / ratio, false)
			self.weapon:setPosition(ph.x, ph.y)
			self.node_t_list["layout_trial"].node:addChild(self.weapon, 999)
		else
			self.weapon:setStop()
			self.weapon:setAnimate(anim_path, anim_name,1 or  COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk*6 / ratio, false)
		end
	end

	-- 自动战斗
	if nil == self.auto_fight then
		local effect_id = 996
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
		self.auto_fight = AnimateSprite:create(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		self.auto_fight:setPosition(ph.x, ph.y - 40)
		self.node_t_list["layout_trial"].node:addChild(self.auto_fight, 999)
	end

	-- 释放技能
	local select_skill_id = 3 -- 写死释放的技能
	local lv_cfg = SkillData.GetSkillLvCfg(select_skill_id, 1)
	if lv_cfg.actRange[1].acts[1].specialEffects[1] then
		local id = lv_cfg.actRange[1].acts[1].specialEffects[1].id
		res_id = id > 10000 and id + GameMath.DirRight or id
	else
		res_id = lv_cfg.actions[1].effect + GameMath.DirRight
	end
	local skill_path, skill_name = ResPath.GetEffectAnimPath(res_id)
	if nil == self.skill then
		self.skill = AnimateSprite:create(skill_path, skill_name, 1 or COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk * 9/ ratio, false)
		self.skill:setPosition(ph.x, ph.y)
		self.node_t_list["layout_trial"].node:addChild(self.skill, 999)
	else
		self.skill:setAnimate(skill_path, skill_name, 1 or COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk*9/ ratio, false)
	end

	self.role:addEventListener(function(node, type, index)
		if type == 2 then
			if wuqi_shape ~= 0 and self.weapon then
				self.weapon:setStop()
				local anim_path, anim_name = ResPath.GetWuqiAnimPath(wuqi_shape, "atk1", GameMath.DirRight)
				self.weapon:setAnimate(anim_path, anim_name, 1 or COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk*6 / ratio, false)
			end
			local anim_path, anim_name = ResPath.GetRoleAnimPath(yifu_shape, "atk1", GameMath.DirRight)
			self.role:setAnimate(anim_path, anim_name, 1 or COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk*6 / ratio, false)
		elseif type == 0 and index == -1 then
			self.skill:setStop()
			self.skill:setAnimate(skill_path, skill_name, 1 or COMMON_CONSTS.MAX_LOOPS, FrameTime.Atk*9/ ratio, false)
		end
	end)
end

function TrialChildView:CreateFlyTimer(times)
	local bg_x, bg_y = self.node_t_list["img9_award_bg"].node:getPosition()
	local ph = self.ph_list["ph_fly_start"] or {x = 0, y = 0}
	local x, y = ph.x, ph.y

	local function callback()
		if self:IsOpen() then
			if nil == self.fly_icon then
				self.fly_icon = self:CreateFlyNode(self.fly_icon_id)
			end
			self.fly_icon:setPosition(x, y)
			self:PlayFly(self.fly_icon)
		else
			if self.fly_timer then
				GlobalTimerQuest:CancelQuest(self.fly_timer)
				self.fly_timer = nil
			end
		end
	end

	if self.fly_timer then
		GlobalTimerQuest:CancelQuest(self.fly_timer)
		self.fly_timer = nil
	end

	callback()
	local delay_time = 1
	self.fly_timer = GlobalTimerQuest:AddTimesTimer(callback, delay_time, times)
end

function TrialChildView:CreateFlyNode(item_id)
	if type(item_id) ~= "number" then
		item_id = 0
	end

	local parent = self.node_t_list["layout_trial"].node
	local ph = self.ph_list["ph_fly_start"] or {x = 0, y = 0}
	local x, y = ph.x, ph.y
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	local path = ResPath.GetItem(item_cfg.icon)
	local node = XUI.CreateImageView(x, y, path, XUI.IS_PLIST)
	parent:addChild(node, 1000)

	return node
end

function TrialChildView:PlayFly(node)
	node:stopAllActions()
	node:setVisible(true)
	local bg_x, bg_y = self.node_t_list["img9_award_bg"].node:getPosition()
	local ph = self.ph_list["ph_fly_start"] or {x = 0, y = 0}
	local x, y = ph.x, ph.y
	local fly_to_pos = cc.p(bg_x, bg_y)
	local move_to =cc.MoveTo:create(0.9, fly_to_pos)
	local spawn = cc.Spawn:create(move_to)
	local callback = cc.CallFunc:create(function()
		local title_text = Language.Trial and Language.Trial.GjAwardsTitle or {}
		local vip_lv = VipData.Instance:GetVipLevel()
		local cfg = TrialConfig and TrialConfig.diamondsPlus or {}
		local rate = cfg[vip_lv] and cfg[vip_lv].rate or 0
		self.sum = self.sum + self.efficiency * (1 + rate)
		self.node_t_list["lbl_total_award_1"].node:setString((title_text[1] or "") .. "：" .. math.floor(self.sum))
		node:setVisible(false)
	end)
	local action = cc.Sequence:create(spawn, callback)
	node:runAction(action)
end

----------end----------

function TrialChildView:OnTextBtn()
	local content = ""
	local cfg = TrialConfig and TrialConfig.diamondsPlus or {}
	for i,v in ipairs(cfg) do
		local time = (v.gjtime or 0) / 60 / 60
		local rate = (v.rate or 0) * 100
		-- 示例:"  VIP1：奖励加成5%  最多累计5小时"
		content = content .. string.format(Language.DescTip.TrialVipPrivilegeContent, i, rate, time)
	end

	DescTip.Instance:SetContent(content, Language.DescTip.TrialVipPrivilegeTitle)
end

function TrialChildView:OnTip()
	DescTip.Instance:SetContent(Language.DescTip.TrialContent, Language.DescTip.TrialTitle)
end

function TrialChildView:OnWorld()
	ViewManager.Instance:OpenViewByDef(ViewDef.Experiment.Trial.TrialWorld)
end

function TrialChildView:OnChallenge()
	if self.add_award_index then
		local section_count = TrialConfig and TrialConfig.section_count or 1
		local guan_num = self.add_award_index
		ExperimentCtrl.SendReceiveTrialAddAwardsReq(guan_num)
	else
		local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
		local cfg = TrialConfig and TrialConfig.chapters or {}
		local cur_cfg = cfg[cur_trial_floor + 1] or {}
		if next(cur_cfg) then
			ExperimentCtrl.SendChallengeTrialReq()
		else
			local str = Language.Trial.Trial_1 --"已成功挑战最后一关"
			SysMsgCtrl.Instance:FloatingTopRightText(str)
		end
	end
end

function TrialChildView:OnReceiveGjAward()
	ExperimentCtrl.SendReceiveTrialAwardsReq()
end

function TrialChildView:OnTrialFloor(item)
	local data = item:GetData()
	local cfg = data.cfg or {}
	local addwards = cfg.addwards
	if addwards then
		ExperimentCtrl.Instance:OpenTrialAddAwardsView(data)
	else
		ExperimentCtrl.Instance:OpenTrialInfoView(data)
	end
end

--------------------

----------------------------------------
-- 关卡item 渲染
----------------------------------------
TrialChildView.TrialFloorItem = BaseClass(BaseRender)
local TrialFloorItem = TrialChildView.TrialFloorItem
function TrialFloorItem:__init()
	--self.item_cell = nil
end

function TrialFloorItem:__delete()
	-- if self.item_cell then
	-- 	self.item_cell:DeleteMe()
	-- 	self.item_cell = nil
	-- end
end

function TrialFloorItem:CreateChild()
	BaseRender.CreateChild(self)

end

function TrialFloorItem:OnFlush()
	if nil == self.data then return end
	local section_count, floor = ExperimentData.GetSectionAndFloor(self.data.guan_index)
	self.node_tree["lbl_guan_num"].node:setString(string.format(Language.Trial.SectionTitle, section_count, floor))

	self.add_awards = self.data.cfg and self.data.cfg.addwards
	if self.add_awards then
		local item_id = self.add_awards[1] and self.add_awards[1].id or 0
		local num = self.add_awards[1] and self.add_awards[1].count or 0
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		self.node_tree["lbl_item_name"].node:setString(item_cfg.name .. "×" .. num)
		local color = Str2C3b(string.format("%06x", item_cfg.color))
		self.node_tree["lbl_item_name"].node:setColor(color)

		self.node_tree["lbl_item_name"].node:setVisible(true)
		self.node_tree["img_item_name_bg"].node:setVisible(true)
		self.node_tree["img_box"].node:setVisible(true)
	else
		self.node_tree["lbl_item_name"].node:setVisible(false)
		self.node_tree["img_item_name_bg"].node:setVisible(false)
		self.node_tree["img_box"].node:setVisible(false)
	end

	local cur_trial_floor = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	if cur_trial_floor > self.data.guan_index then
		local path = ResPath.GetExperiment("trial_6")
		self.node_tree["img_state"].node:loadTexture(path)
		if self.cur_effect then
			self.cur_effect:setVisible(false)
		end
	elseif cur_trial_floor == self.data.guan_index then
		local path = ResPath.GetExperiment("trial_5")
		self.node_tree["img_state"].node:loadTexture(path)
		if self.cur_effect then
			self.cur_effect:setVisible(true)
		else
			self:CreateCurEffect()
		end
	else
		self.node_tree["img_state"].node:setVisible(false)
		if self.cur_effect then
			self.cur_effect:setVisible(false)
		end
	end
end

function TrialFloorItem:CreateCurEffect()
	local size = self.view:getContentSize()
	self.cur_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetExperiment("trial_1_select"), true)
	if nil == self.cur_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.cur_effect, 999)
end

function TrialFloorItem:CreateSelectEffect()
end

return TrialChildView