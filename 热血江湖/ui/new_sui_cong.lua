-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_sui_cong = i3k_class("wnd_sui_cong", ui.wnd_base)

local LAYER_SCLBT = "ui/widgets/sclbt"
local LAYER_SCSXT = "ui/widgets/scsxt"
local LAYER_SHENGJI = "ui/widgets/suicongshengji"
local LAYER_SHENGXING = "ui/widgets/suicongshengxing"
local LAYER_SHUXING = "ui/widgets/suicongshuxing"
local LAYER_TUPO = "ui/widgets/suicongtupo"
local LAYER_XIANSUO = "ui/widgets/suicongxiansuo"
local LAYER_ZHUANZHI = "ui/widgets/suicongzhuanzhi"
local LAYER_YUANBAO = "ui/widgets/yuanbaoshengji"
local LAYER_SHENSHI = "ui/widgets/suicongshenshi"
local LAYER_JIESHAO = "ui/widgets/suicongjieshao"
local LAYER_HEXIU	= "ui/widgets/suiconghexiu"
local LAYER_XINFA	= "ui/widgets/suicongxinfa"
local LAYER_XINFAT1 = "ui/widgets/suicongxinfat"
local LAYER_XINFAT2 = "ui/widgets/suicongxinfat2"
local LAYER_XINFAT3 = "ui/widgets/suicongxinfat3"


--佣兵召唤条件
local condition_desc = {
[1] = "完成主线任务",
[2] = "达成战力",
[3] = "通关副本",
[4] = "达成等级",
}
--突破技能属性
local _attribute = {
[1] = "伤害加深",
[2] = "伤害减免",
[3] = "气功继承",
[4] = "神兵继承",
}

local star_icon = {405,409,410,411,412,413}
local tabs_icon = {125,126,136,137,138,139,140}

--是否拥有佣兵 选中效果
local NO_HAVE_PET	= 708
local HAVE_PET		= 707
local SELECT_BG		= 706

local notUsedAwaken = 0;
local usedAwaken	= 1;

--特效显示时间 可改为策划配置
local SHOW_TIME = 0

local HandleTime = 2  --操作频繁限制时间

function wnd_sui_cong:ctor()
	local id = g_i3k_game_context:getPetCanUnlockId() ~= 0 and g_i3k_game_context:getPetCanUnlockId() or  g_i3k_game_context:getFieldPetID()
	self._id = id ~= 0 and id
	self._showData = {}
	self._breakSkill = {}
	self._item = {}
	self._skill = {}
	self._skill_btn = {}
	self._skill_bg = {}
	self._attribute_root = {}

	self.needId = 0
	self._canUse = true
	self._isChange = false
	self._poptick = 0
	self._handleTime = 0
	self.record_time = 0
	self.co = nil
	self.canRefresh = false
	self.recordID = 0
	self.widgets = nil
	self._startChageModle = false;
	self._chageModleId = 0;
	self._chageTime = 0;
	self._awakenWin = false;
	self._awakenTime = 0;
	self._changePowerCo = nil
	
	self.jumpID = 0
end

function wnd_sui_cong:configure()
	local widgets = self._layout.vars

	self.pet_module = widgets.pet_module
	widgets.help_btn:onClick(self, self.onHelp)
   
	self._pet_scroll = widgets.scroll1
	self._play_btn = widgets.play_btn
	self._play_label = widgets.play_lable
	self._rest_btn = widgets.rest_btn
	self._rest_lable = widgets.rest_lable
	self._xiansuo_btn = widgets.xiansuo_btn
	self._xiansuo_icon = widgets.xiansuo_icon
	self._xiansuo_label = widgets.xiansuo_label
	self._desc_btn = widgets.desc_btn
	self._desc_label = widgets.desc_label
	self._attribute_btn = widgets.attribute_btn
	self._attribute_label = widgets.attribute_label
	self.achievement_Btn = widgets.achievement_Btn
	self.backfitBtn = widgets.backfitBtn
	self.achievement_Btn:onClick(self, self.achievementInto)
	for i=1,4 do
		local tmp_skill = string.format("skill%s_btn",i)
		local tmp_skill_bg = string.format("skill%s_bg",i)
		local skill_btn = widgets[tmp_skill]
		local skill_bg = widgets[tmp_skill_bg]
		self._skill_btn[i] = skill_btn
		self._skill_bg[i] = skill_bg
	end
	for i=1,7 do
		local tmp_attribute = string.format("attribute_label%s",i)
		local attribute_label = widgets[tmp_attribute]
		self._attribute_root[i] = attribute_label
	end
	self.c_sj = self._layout.anis.c_sj
	self.c_sx = self._layout.anis.c_sx
	self.c_zh = self._layout.anis.c_zh
	self._battle_power = widgets.battle_power
	self.addIcon = widgets.addIcon
	self.powerValue = widgets.powerValue
	self.power_image = widgets.power_image
	self.new_root = widgets.new_root

	self.red_point1 = widgets.red_point1
	self.red_point2 = widgets.red_point2
	self.global = widgets.global
	self.wakenBtn = widgets.wakenBtn;
	self.wakenBtn:onClick(self, self.onWakenBtn)
	self.wakenTxt = widgets.wakenTxt;
	self.showAwaken = widgets.showAwaken;
	self.awakenMark = widgets.awakenMark;
	self.isUseBtn = widgets.isUseBtn;
	self.isUseBtn:onClick(self, self.isUseWakenBtn)
	widgets.global:onClick(self, self.stopAnimation)
	widgets.xinfaBtn:onClick(self, self.updatePetXinfa)

	self.modifyNameBtn = widgets.modifyNameBtn
	self.modifyNameBtn:onClick(self, self.onModifyNameClick)

	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self._layout.vars.tipsBtn:onClick(self, self.openCommentUI)
	
	self.wuRedPoint = widgets.wuRedPoint --武库红点
	self.xfRedPoint = widgets.xfRedPoint --心法红点
end

function wnd_sui_cong:updateUpLevelAnimation(data)
	for k,v in ipairs(self._attribute_root) do
		local tmp_str = string.format("%s+%s",data.newData[k].name,(data.newData[k].value - data.oldData[k].value))
		v:setText(tmp_str)
	end
	self.c_sj.play()
end

function wnd_sui_cong:updateUpStarAnimation()
	self.c_sx.play()
end

function wnd_sui_cong:updateTransterAnimation()
	for k,v in ipairs(self._attribute_root) do
		v:setText("")
	end
	self.c_sj.play()
end

function wnd_sui_cong:updateCallPetAnimation()
	self.c_zh.play()
	self.global:show()
	self.record_time = i3k_game_get_time()
end

function wnd_sui_cong:stopAnimation(sender)
	self.c_zh.stop()
	self.global:hide()
end

function wnd_sui_cong:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(77))
end

function wnd_sui_cong:ChagePetModule(id)
	self.wakenBtn:hide();
	self._startChageModle = true;
	self._chageModleId = id;
	self.pet_module:playAction("01attack01")
end

function wnd_sui_cong:updatePetModule(id, mode, isAwake)
	local ishave = g_i3k_game_context:IsHavePet(id);
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(id);
	if ishave then
		local isUseAwaken = g_i3k_game_context:getPetWakenUse(id);
		if isUseAwaken then
			cfg = i3k_db_mercenariea_waken_property[id];
		end
	end
	if cfg and cfg.modelID then
		local path = i3k_db_models[cfg.modelID].path
		local uiscale = i3k_db_models[cfg.modelID].uiscale
		self.pet_module:setSprite(path)
		self.pet_module:setSprSize(uiscale)
		self.pet_module:setRotation(2);
		if mode then
			if math.random() <= 0.5 then
				self.pet_module:pushActionList("01attack01", 1)
			else
				self.pet_module:pushActionList("02attack02", 1)
			end
			self.pet_module:pushActionList("stand",-1)
			self.pet_module:playActionList()
		else
			if isAwake then
				self.pet_module:pushActionList(i3k_db_mercenariea_waken_cfg.action, 1)
				self.pet_module:pushActionList("stand",-1)
				self.pet_module:playActionList()
				self.c_sj.play();
			else
				self.pet_module:playAction("stand")
			end
		end
	end
end

function wnd_sui_cong:updateAllPetList(cfg_data)
	self.global:hide()
	self._pet_scroll:removeAllChildren()
	self._showData = {}
	local allYongbing = g_i3k_game_context:GetAllYongBing()
	local mercenariesTb = {}
	local order = 0
	for i, e in ipairs(cfg_data) do
		local id = e.id
		local _layer = require(LAYER_SCLBT)()
		_layer.vars.id = id
		if e.isOpen ~= 0 then
			if allYongbing[id] then
				order = allYongbing[id].level * 1000 + allYongbing[id].starlvl * 100 + 100 - id
			else
				if g_i3k_game_context:isShowXiansuoRedPoint(id) then
					order = 100000 - id
				else
					order = 100 - id
				end
			end
			table.insert(mercenariesTb, {sortid = order, id = id , layer = _layer} )
		end
	end
	table.sort(mercenariesTb, function(a,b)
		return a.sortid > b.sortid
	end)
	local index = 0
	for k, v in pairs(mercenariesTb) do
		self._pet_scroll:addItem(v.layer)
		if self._id == v.id then
			index = k
		end
	end
	if self._id then
		self._pet_scroll:jumpToChildWithIndex(index)
	end
end

function wnd_sui_cong:updateAllPetMsg()
	local allPetLayer = self._pet_scroll:getAllChildren()
	for k, v in ipairs(allPetLayer) do
		local widgets = v.vars
		local id = widgets.id
		if k == 1 and not self._id  then
			self._id = id
			widgets.is_show:show()

		end
		local cfg_data = g_i3k_db.i3k_db_get_pet_cfg(id)
		local petName = g_i3k_game_context:getPetName(id)
		local name = petName ~= "" and petName or cfg_data.name
		widgets.name:setText(name)
		local iconId = cfg_data.icon;
		if g_i3k_game_context:getPetWakenUse(id) then
			iconId = i3k_db_mercenariea_waken_property[id].headIcon;
		end
		widgets.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		widgets.iconBg:setImage(g_i3k_get_icon_frame_path_by_rank(i3k_db_mercenaries[id].rank))
		local starlvl = g_i3k_game_context:getPetStarLvl(id)
		widgets.qlvl:setText(g_i3k_game_context:getPetLevel(id))
		local tmp_str = string.format("%s转", g_i3k_game_context:getPetTransfer(id))
		widgets.attribute:setText(tmp_str)
		widgets.desc:hide()
		widgets.is_select:hide()
		widgets.red_point:setVisible(g_i3k_game_context:isShowPetPoint(id))
		widgets.is_show:hide()
		widgets.select1_btn:onClick(self, self.onSuicongHave, id)
		widgets.slvl:setImage(g_i3k_db.i3k_db_get_icon_path(star_icon[starlvl + 1]))
		self:isShowWakenBtn(g_i3k_game_context:getPetLevel(self._id));
		if not g_i3k_game_context:IsHavePet(id) then
			widgets.select1_btn:onClick(self, self.onSuicongNotHave, id)
			widgets.qlvl_icon1:hide()
			widgets.slvl:hide()
			widgets.qlvl:hide()
			widgets.attribute:hide()
			widgets.desc:setText("尚未获得青睐")
			widgets.desc:show()
			widgets.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(NO_HAVE_PET))
		else
			if k == 1 then
				self.canRefresh = true
			end
			widgets.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(HAVE_PET))
		end
		self._showData[id] = {
			id = id,
			is_show = widgets.is_show,
			qlvl = widgets.qlvl,
			slvl = widgets.slvl,
			attribute = widgets.attribute,
			is_select = widgets.is_select
		}
	end
end

function wnd_sui_cong:updateSelectMarkHide()
	local allPetLayer = self._pet_scroll:getAllChildren()
	for k,v in ipairs(allPetLayer) do
		local id = v.vars.id
		v.vars.is_show:hide()
		if g_i3k_game_context:IsHavePet(id) then
			v.vars.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(HAVE_PET))
		else
			v.vars.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(NO_HAVE_PET))
		end
	end
end

function wnd_sui_cong:updateSelectMarkShow()
	local allPetLayer = self._pet_scroll:getAllChildren()
	local cfg = i3k_db_mercenaries[self._id]
	local flag = true
	for i, e in pairs(allPetLayer) do
		local widgets = e.vars
		if widgets.id == self._id then
			widgets.is_show:show()
			widgets.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(SELECT_BG))
		end
	end
	for i = 1, 4 do
		local lvl = g_i3k_game_context:getPetBreakSkillLvl(self._id,cfg["breakSkill" .. i])
		if i3k_db_suicong_breakdata[cfg["breakSkill" .. i]][lvl + 1] then
			flag = false
		end
	end
	if not g_i3k_game_context:GetCanOpenSpirits(self._id) then
		self._layout.vars.xinfaBtn:hide()
	else
		self._layout.vars.xinfaBtn:show()
	end
	if not g_i3k_game_context:GetCanOpenSpirits() then
		self._layout.vars.wukuBtn:hide()
	else
		self._layout.vars.wukuBtn:show()
		self._layout.vars.wukuBtn:onClick(self, self.updateSpiritsData)
	end
	if flag then
		self._layout.vars.recycle_btn:show()
		self._layout.vars.recycle_btn:onClick(self, self.onRecycle, self._id)                                     --碎片回收入口
	else
	    self._layout.vars.recycle_btn:hide()
	end    
end

function wnd_sui_cong:updateSelectMark()
	self:updateSelectMarkHide()
	self:updateSelectMarkShow()
end

function wnd_sui_cong:updateBattleMatk()
	local allRoot = self._pet_scroll:getAllChildren()
	for i, e in pairs(allRoot) do
		e.vars.is_select:setVisible(g_i3k_game_context:getFieldPetID() == e.vars.id)
	end
end

function wnd_sui_cong:updateSelectData(is_have, transfer, level)
	self:updateSelectMarkShow()
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(self._id)
	self:updatePetModule(self._id)
	if is_have then
		local need_lvl = 0
		local trs_cfg = g_i3k_db.i3k_db_get_pet_transfer_cfg(transfer+1)
		if trs_cfg then
			need_lvl = trs_cfg.maxLvl
		end
		if need_lvl ~= 0 and need_lvl == level then
			self.jumpID = 4
			self:updateSuicongTransferData()
		else
			self:setPetUplvlData()
		end
		self:ShowSKillBtn()
	else
		self:updateXiansuoData()
		self:HideSKillBtn()
	end
	self:onUpdatePetRedPoint()
end

function wnd_sui_cong:HideSKillBtn()
	self._play_btn:hide()
	self._rest_btn:hide()
	self:recordSkillBtn()
	self:refreshBattlePower(false)
end

function wnd_sui_cong:recordSkillBtn()
	local id = self._id
	self._skill = {}
	local nowLvl = g_i3k_game_context:getPetLevel(id)
	for i=1,4 do
		self._skill_btn[i]:show()
		self._skill_bg[i]:show()
		local cfg = g_i3k_db.i3k_db_get_pet_cfg(id)
		local skillid = cfg.skills[i]
		if i == 4 then
			skillid = cfg.ultraSkill
		end
		if i3k_db_skills[skillid] then
			local iconid = i3k_db_skills[skillid].icon
			local  icon_path = g_i3k_db.i3k_db_get_icon_path(iconid)
			local skillLvl = g_i3k_game_context:GetMercenarySkillLevelForIndex(id, i)
			local needLvl, needItemId, needItemCount = g_i3k_game_context:GetPetSkillData(id, i, skillLvl + 1)
			self._layout.vars["up_arrow" .. i]:setVisible(g_i3k_game_context:isEnoughUpPetSkillLevel(needItemId, needItemCount, nowLvl, needLvl))
			self._skill_btn[i]:setTag(i)
			self._skill_btn[i]:setImage(icon_path,icon_path)
			
			self._skill_btn[i]:onClick(self, self.onSKillTips)
			self._skill[i] = skillid
		end
	end
end

function wnd_sui_cong:ShowSKillBtn()
	local maptype = i3k_game_get_map_type()
	self._rest_btn:hide()
	self._play_btn:show()
	self._play_btn:onClick(self, self.onPlayBtn)
	self._play_btn:enableWithChildren()
	local play_id = g_i3k_game_context:getFieldPetID()
	if play_id == self._id then
		self._play_btn:hide()
		self._rest_btn:show()
		self._rest_btn:onClick(self, self.onPlayBtn)
	end
	if self._play_label then
		self._play_label:setText("出 战")
	end
	self:recordSkillBtn()
	self:refreshBattlePower(true)
end

function wnd_sui_cong:onSKillTips(sender)
	local tag = sender:getTag()
	local skillid = self._skill[tag]
	local isLock = g_i3k_game_context:IsHavePet(self._id)
	local skillLevel = g_i3k_game_context:GetMercenarySkillLevelForIndex(self._id, tag)
	local isCanUpLvl, needItemId, needItemCount = g_i3k_game_context:GetPetSkillData(self._id, tag, skillLevel+1)
	if isLock and isCanUpLvl then
		local curr_level = g_i3k_game_context:getPetLevel(self._id);
		if skillLevel == 1 and curr_level < isCanUpLvl then
			g_i3k_ui_mgr:OpenUI(eUIID_SuicongSkillTips)
			g_i3k_ui_mgr:RefreshUI(eUIID_SuicongSkillTips,skillid,self._id,tag,i3k_get_string(828,isCanUpLvl))
		else
			g_i3k_ui_mgr:OpenUI(eUIID_SuicongUpSkillLevel)
			g_i3k_ui_mgr:RefreshUI(eUIID_SuicongUpSkillLevel,skillid,self._id,tag)
		end
	elseif isLock and not isCanUpLvl then
		g_i3k_ui_mgr:OpenUI(eUIID_SuicongMaxSkillLevel)
		g_i3k_ui_mgr:RefreshUI(eUIID_SuicongMaxSkillLevel,skillid,self._id,tag)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_SuicongSkillTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_SuicongSkillTips,skillid,self._id,tag)
	end
end

function wnd_sui_cong:onPlayBtn(sender)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end

	if self._handleTime ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(588))
		return
	end
	local logic = i3k_game_get_logic()
	local world = logic:GetWorld()
	local play_id = g_i3k_game_context:getFieldPetID()
	local state = world._cfg.openType ~= g_FIELD or play_id == self._id
	-- if not state then
		if g_i3k_game_context:IsOnRide() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(633))
			return
		end
	-- end
	if g_i3k_game_context:GetTeamId() ~= 0 then
		-- g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(187))
	end
	self._handleTime = i3k_game_get_time()
	local id = state and 0 or self._id
	if g_i3k_game_context:IsOnHugMode() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17059))
		return
	end
	i3k_sbean.goto_pet_worldmapset(id)
end

function wnd_sui_cong:onWakenBtn(sender)
	local taskID = g_i3k_game_context:getPetWakenTaskId(self._id);
	if self._id > 0 and taskID > 0 then
		local task = i3k_db_mercenariea_waken_task[self._id][taskID];
		local finish = g_i3k_game_context:getPetWakenTaskState(self._id) == g_TaskState2
		if finish then
			i3k_sbean.awakeTaskFinish(self._id, taskID)
			return
		end
		if task and task.taskType then
			if task.taskType == g_TASK_KILL then
				g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenTask1)
				g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenTask1,self._id)
			elseif task.taskType == g_TASK_PASS_FUBEN then
				g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenTask2)
				g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenTask2,self._id)
			elseif task.taskType == g_TASK_SUBMIT_ITEM then
				g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenTask3)
				g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenTask3,self._id)
			end
		end
	else
		g_i3k_ui_mgr:OpenUI(eUIID_SuicongWakenTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_SuicongWakenTips,self._id)
	end
end

function wnd_sui_cong:updateHeadIcon(isUseAwaken)
	local allPetLayer = self._pet_scroll:getAllChildren()
	for k,v in ipairs(allPetLayer) do
		if v.vars.id == self._id then
			local cfg_data = g_i3k_db.i3k_db_get_pet_cfg(self._id)
			local iconId = cfg_data.icon;
			if isUseAwaken then
				iconId = i3k_db_mercenariea_waken_property[self._id].headIcon;
			end
			v.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId, true))
		end
	end
end

function wnd_sui_cong:isUseWakenBtn(sender)
	local isUseAwaken = g_i3k_game_context:getPetWakenUse(self._id)
	if g_i3k_game_context:getFieldPetID() ~= self._id then
		if isUseAwaken then
			self.awakenMark:hide();
			self:updateHeadIcon(false);
			i3k_sbean.petAwakeSet(self._id,notUsedAwaken)
		else
			self.awakenMark:show();
			self:updateHeadIcon(true);
			i3k_sbean.petAwakeSet(self._id,usedAwaken)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16862))
	end
end

function wnd_sui_cong:isShowWakenBtn(level)
	self.wakenBtn:hide();
	self.showAwaken:hide();
	self.modifyNameBtn:hide()
	local wakenCfg = i3k_db_mercenariea_waken_cfg;
	local task = i3k_db_mercenariea_waken_task[self._id];
	local property =  i3k_db_mercenariea_waken_property[self._id];
	if property and property.isOpen and property.isOpen == 1 then
		if task and wakenCfg and wakenCfg.showLvl and property then
			local isWaken = g_i3k_game_context:getPetIsWaken(self._id);
			if isWaken then
				self.showAwaken:show();
				self.modifyNameBtn:show()
				-- self.isUseBtn:onClick(self, self.isUseWakenBtn)
				local isUseAwaken = g_i3k_game_context:getPetWakenUse(self._id)
				if isUseAwaken then
					self.awakenMark:show();
				else
					self.awakenMark:hide();
				end
			elseif level >= wakenCfg.showLvl and not isWaken then
				local nowTask = g_i3k_game_context:getPetWakenTaskId(self._id);
				self.wakenBtn:show();
				self.wakenTxt:show():setText(nowTask.."/"..#task);
				-- self.wakenBtn:onClick(self, self.onWakenBtn)
			end
		end
	end
end

function wnd_sui_cong:updatePetWakenTxt(petID)
	local task = i3k_db_mercenariea_waken_task[petID];
	if task then
		local nowTask = g_i3k_game_context:getPetWakenTaskId(petID);		
		self.wakenTxt:show():setText(nowTask.."/"..#task);
	end
end

function wnd_sui_cong:onSuicongHave(sender, id)
	if self._startChageModle or self._awakenWin then
		return
	end
	if self._id == id then
		return
	end
	self._id = id
	self._isChange = false
	self:updateSelectMark()
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(self._id)
	self:updatePetModule(self._id)
	self:onUpdatePetRedPoint()
	self:updateXinFaRedPoint();
	---------------------设置页签按钮-----------------------
	local level = g_i3k_game_context:getPetLevel(id)
	local transfer = g_i3k_game_context:getPetTransfer(id)
	local starlvl = g_i3k_game_context:getPetStarLvl(id)
	local need_lvl = 0
	local trs_cfg = g_i3k_db.i3k_db_get_pet_transfer_cfg(transfer+1)
	if trs_cfg then
		need_lvl = trs_cfg.maxLvl
	end
	self.canRefresh = true
	self:isShowWakenBtn(level);
	if need_lvl ~= 0 and need_lvl == level then
		self._xiansuo_btn:onClick(self, self.onTransferLayer)
		self._xiansuo_label:setText("转职")
		self.recordID = 1
	else
		self._xiansuo_label:setText("升级")
		self._xiansuo_btn:onClick(self, self.onUpgradeLayer)
	end
	local upstar_cfg = g_i3k_db.i3k_db_get_pet_upstar_cfg(id,starlvl+1)
	if upstar_cfg then
		self._desc_label:setText("升星")
		self._desc_btn:onClick(self, self.onUpStarLayer)
	else
		self._desc_label:setText("突破")
		self._desc_btn:onClick(self, self.onBreakLayer)
	end
	self._attribute_btn:onClick(self, self.onAttributeLayer)
	self._attribute_btn:stateToNormal()
	self._attribute_btn:show()
	self._attribute_label:setText("属性")
	self:ShowSKillBtn()
	self.backfitBtn:onClick(self, self.onShowBackfit)
	self.backfitBtn:hide()
	if level >= i3k_db_common.petBackfit.hexiuHideLvl then
		self.backfitBtn:show()
	end
	if self.jumpID == 1 or self.jumpID == 8 then
		if level then
			if need_lvl ~= 0 and need_lvl == level then
				self:onTransferLayer()
				self._xiansuo_label:setText("转职")
				self.recordID = 1
			else
				self:onUpgradeLayer()
			end
		else
			self:updateXiansuoData()
			self._xiansuo_btn:stateToPressed()
		end
	elseif self.jumpID == 2 or self.jumpID == 4 then
		if need_lvl ~= 0 and need_lvl == level then
			self:onTransferLayer()
			self._xiansuo_label:setText("转职")
			self.recordID = 1
		else
			self:onUpgradeLayer()
			self._xiansuo_label:setText("升级")
		end
	elseif self.jumpID == 3 or self.jumpID == 7 then
		if upstar_cfg then
			self:onUpStarLayer()
			self._desc_label:setText("升星")
		else
			self:onBreakLayer()
			self._desc_label:setText("突破")
		end
	elseif self.jumpID == 5 then
		self:onAttributeLayer()
	elseif self.jumpID == 6 then
		self.backfitBtn:hide()
		if level >= i3k_db_common.petBackfit.hexiuNeedLvl then
			self.backfitBtn:show()
			self:onShowBackfit()
		else
			if need_lvl ~= 0 and need_lvl == level then
				self:onTransferLayer()
				self._xiansuo_label:setText("转职")
				self.recordID = 1
			else
				self:onUpgradeLayer()
			end
		end
	elseif self.jumpID == 9 then
		if not g_i3k_game_context:GetCanOpenSpirits(self._id) then
			--g_i3k_ui_mgr:PopupTipMessage("随从45级开启可学习心法")
			if level then
				if need_lvl ~= 0 and need_lvl == level then
					self:onTransferLayer()
					self._xiansuo_label:setText("转职")
					self.recordID = 1
				else
					self:onUpgradeLayer()
				end
			else
				self:updateXiansuoData()
				self._xiansuo_btn:stateToPressed()
			end
		else
			self:updatePetXinfa()
		end
	elseif self.jumpID == 10 then
		if level then
			if need_lvl ~= 0 and need_lvl == level then
				self:onTransferLayer()
				self._xiansuo_label:setText("转职")
				self.recordID = 1
			else
				self:onUpgradeLayer()
			end
		else
			self:updateXiansuoData()
			self._xiansuo_btn:stateToPressed()
		end
	end

end

function wnd_sui_cong:onSuicongNotHave(sender, id)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SuiCong, "updateSuicongNotHave", id)
end
function wnd_sui_cong:updateSuicongNotHave(id)
	if self._startChageModle or self._awakenWin then
		return
	end
	if self._id == id then
		return
	end
	self._id = id
	self._layout.vars.xinfaBtn:hide()
	self.wakenBtn:hide();
	self.showAwaken:hide();
	self.modifyNameBtn:hide()
	self:updateSelectMark()
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(self._id)
	self:updatePetModule(self._id)
	self:updateXiansuoData()
	self:HideSKillBtn()
end

function wnd_sui_cong:addNewNode(layer)
	self.recordID = 2
	g_i3k_coroutine_mgr:StopCoroutine(self.co)
	local nodeWidth = self.new_root:getContentSize().width
	local nodeHeight = self.new_root:getContentSize().height
	local old_layer = self.new_root:getAddChild()
	if old_layer[1] then
		self.new_root:removeChild(old_layer[1])
	end
	self.new_root:addChild(layer)
	layer.rootVar:setContentSize(nodeWidth, nodeHeight)
end

function wnd_sui_cong:updateXiansuoDataWhenGetItem()
	if self.jumpID == 1 then
		self:updateXiansuoData()
	end
end
function wnd_sui_cong:updateXiansuoData()
	self.jumpID = 1
	local id = self._id
	local is_set = false
	local is_ok1 = true
	local is_ok2 = true
	local is_ok3 = true
	local is_ok4 = true
	local is_ok5 = true
	local is_ok6 = true
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(id)
	local _layer = require(LAYER_XIANSUO)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	for i=1,3 do
		local tmp_title = string.format("task%s_title",i)
		local task_title = widgets[tmp_title]
		local tmp_desc = string.format("task%s_desc",i)
		local task_desc = widgets[tmp_desc]
		local tmp_root = string.format("task%sRoot",i)
		local taskRoot = widgets[tmp_root]
		local tmp_item_root = string.format("itemRoot%s",i)
		local tmp_item = string.format("item%s",i)
		local tmp_btn = string.format("item_btn%s", i)
		local item = widgets[tmp_item]

		local temp_condition = string.format("callCondition%s",i)
		local condition = cfg[temp_condition]
		local tmp_arg = string.format("callArgs%s",i)
		local args =  cfg[tmp_arg]
		widgets[tmp_item_root]:setVisible(condition==0)
		if condition == 0 then
			local itemid = cfg.consumeItem
			widgets[tmp_root]:setVisible(itemid ~= 0 and not is_set)
			if itemid ~= 0 and not is_set then
				is_set = true
				task_title:setText("提交道具")
				local itemCount = cfg.consumeCount
				local have_count = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
				local tmp_des = string.format(" %s %s/%s",g_i3k_db.i3k_db_get_common_item_name(itemid),have_count,itemCount)
				task_desc:setText(tmp_des)
				task_desc:setTextColor(g_i3k_get_cond_color(have_count >= itemCount))
				if have_count < itemCount then
					is_ok1 = false
				end
				item:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
				widgets[tmp_item_root]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
				widgets[tmp_btn]:onClick(self, self.onItemInfo, itemid)
			end
		else
			widgets[tmp_root]:show()
			task_title:setText(condition_desc[condition])
			local desc,colour,is_ok = self:getXiansuoConditionDesc(condition,args)
			task_desc:setText(desc)
			task_desc:setTextColor(colour)
			if condition == 1 then
				is_ok2 = is_ok
			elseif condition == 2 then
				is_ok3 = is_ok
			elseif condition == 3 then
				is_ok4 = is_ok
			elseif condition == 4 then
				is_ok5 = is_ok
			end
		end
		is_ok6 = true
	end
	widgets.call_btn:onClick(self, self.onCallSuicong)
	self:updateXiansuoFriend(_layer)
	if is_ok1 and is_ok2 and is_ok3 and is_ok4 and is_ok5 and is_ok6 then
		widgets.call_btn:enableWithChildren()
	else
		widgets.call_btn:disableWithChildren()
	end
	widgets.addFriend_btn:onClick(self, self.onEnterToTask)
	-------------------设置页签按钮-------------------------------
	self._xiansuo_btn:onClick(self, self.onXiansuoLayer)
	self._xiansuo_btn:stateToPressed()
	self._xiansuo_label:setText("线索")
	self._desc_btn:onClick(self, self.onDescLayer)
	self._desc_btn:stateToNormal()
	self._desc_label:setText("描述")
	self._attribute_btn:hide()
	self.backfitBtn:hide()

	self.red_point1:setVisible(g_i3k_game_context:isShowXiansuoRedPoint(self._id)~=false)
	self.red_point2:hide()
end

function wnd_sui_cong:onItemInfo(sender, itemid)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
end

function wnd_sui_cong:updatePetDesc()
	self.jumpID = 8
	local _layer = require(LAYER_JIESHAO)()
	self:addNewNode(_layer)
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(self._id)
	local tmp_desc = cfg.desc
	_layer.vars.suicong_desc:setText(tmp_desc)
	self.red_point1:setVisible(g_i3k_game_context:isShowXiansuoRedPoint(self._id)~=false)
	self.red_point2:hide()
end

function wnd_sui_cong:updateXiansuoFriend(layer)
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(self._id)
	local friendLvl = g_i3k_game_context:getPetFriendLvl(self._id)
	local friendExp = g_i3k_game_context:getPetFriendExp(self._id)
	local needCount = 0
	local relation_cfg = g_i3k_db.i3k_db_get_pet_relation_cfg(self._id, friendLvl+1)
	local now_relation_cfg = g_i3k_db.i3k_db_get_pet_relation_cfg(self._id, friendLvl)
	if relation_cfg then
		needCount = relation_cfg.needCount
	else
		needCount = now_relation_cfg.needCount
	end
	local friendName = now_relation_cfg.name
	layer.vars.friend_slider1:setPercent(friendExp/needCount*100)
	layer.vars.friend_value1:setText(friendName)
end

function wnd_sui_cong:getXiansuoConditionDesc(condition, args)
	if condition == 1 then
		local main_task_cfg = g_i3k_db.i3k_db_get_main_task_cfg(args)
		local tmp_desc = main_task_cfg.name
		local now_taskid = g_i3k_game_context:getMainTaskIdAndVlaue()
		if  now_taskid > args then
			local tmp_str = string.format("%s(已完成)",tmp_desc)
			return tmp_str,g_i3k_get_green_color(),true
		else
			local tmp_str = string.format("%s(未达成)",tmp_desc)
			return tmp_str,g_i3k_get_red_color(),false
		end
	elseif condition == 2 then
		local logic = i3k_game_get_logic()
		local player = logic:GetPlayer()
		local hero = player:GetHero()
		local power = math.modf(hero:Appraise())
		if power >= args then
			local tmp_str = string.format("%s/%s(已达成)",power,args)
			return tmp_str,g_i3k_get_green_color(),true
		else
			local tmp_str = string.format("%s/%s(未达成)",power,args)
			return tmp_str,g_i3k_get_red_color(),false
		end
	elseif condition == 3 then
		local name = i3k_db_new_dungeon[args].name
		local finishCount = g_i3k_game_context:getDungeonFinishTimes(args)

		if  finishCount > 0 then
			local tmp_str = string.format("%s(已达成)",name)
			return tmp_str,g_i3k_get_green_color(),true
		else
			local tmp_str = string.format("%s(未达成)",name)
			return tmp_str,g_i3k_get_red_color(),false
		end
	elseif condition == 4 then
		local lvl = g_i3k_game_context:GetLevel()
		if lvl >= args then
			local tmp_str = string.format("%s/%s(已达成)",lvl,args)
			return tmp_str,g_i3k_get_green_color(),true
		else
			local tmp_str = string.format("%s/%s(未达成)",lvl,args)
			return tmp_str,g_i3k_get_red_color(),false
		end
	end
end

function wnd_sui_cong:onEnterToTask(sender)
	local friend_lvl = g_i3k_game_context:getPetFriendLvl(self._id)
	if not i3k_db_suicong_relation[self._id][friend_lvl+ 1] then
		g_i3k_ui_mgr:PopupTipMessage("恭喜该宠物喂养度已满")
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_PetTask)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetTask, self._id)
end

function wnd_sui_cong:setPetUplvlData(isRefreshPower)
	local _layer = require(LAYER_SHENGJI)()
	self.widgets = _layer.vars
	self.jumpID = 2
	self:addNewNode(_layer)
	_layer.vars.akey_btn:onClick(self, self.onUseExpAuto)
	_layer.vars.diamondup_btn:onClick(self, self.onUseDiamondUpLvl)
	self:updateSuicongUpLvlData(isRefreshPower)
end

function wnd_sui_cong:updateSuicongUpLvlData(isRefreshPower)
	if self.jumpID ~= 2 or not self.widgets then
		return
	end
	local widgets = self.widgets
	local id = self._id

	local now_lvl = g_i3k_game_context:getPetLevel(id)
	local now_exp = g_i3k_game_context:getPetExp(id)
	local transfer = g_i3k_game_context:getPetTransfer(id)
	local need_exp = 0
	local need_item = {}
	local uplvl_cfg = g_i3k_db.i3k_db_get_pet_uplvl_cfg(now_lvl+1)
	local need_exp = uplvl_cfg.value
	local need_item = uplvl_cfg.itemid
	widgets.level:setText("等级：")
	widgets.value:setText(now_lvl)
	widgets.exp_slider:setPercent(now_exp/need_exp*100)
	local tmp_str = string.format("%s/%s",now_exp,need_exp)
	widgets.exp_value:setText(tmp_str)
	for i=1,6 do
		local temp_bg = string.format("item%s_bg",i)
		local temp_icon = string.format("item%s_icon",i)
		local temp_btn = string.format("item%s_btn",i)
		local temp_count = string.format("item%s_count",i)
		local tempcountBg = string.format("count%sRoot",i)
		local tmp_value = string.format("item%s_value",i)
		widgets[temp_bg]:setVisible(need_item[i] ~= nil and need_item[i] ~= 0)
		widgets[temp_count]:setVisible(need_item[i] ~= nil and need_item[i] ~= 0)
		widgets[tempcountBg]:setVisible(need_item[i] ~= nil and need_item[i] ~= 0)
		if need_item[i] and need_item[i] ~= 0 then
			local itemCount = g_i3k_game_context:GetCommonItemCount(need_item[i])
			local itemid = itemCount > 0 and need_item[i] or -need_item[i]
			local item_cfg = g_i3k_db.i3k_db_get_common_item_cfg(itemid)
			local exp_value = item_cfg.args1
			local count = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
			widgets[temp_bg]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
			widgets[temp_icon]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
			widgets[temp_count]:setText(count)
			widgets[tmp_value]:setText(exp_value)

			widgets[temp_btn]:onTouchEvent(self, self.onUseItem, {itemid = itemid, layer = true, count = count})--长按按钮
		end
	end
	---------------------设置页签按钮-----------------------
	local level = g_i3k_game_context:getPetLevel(id)
	local starlvl = g_i3k_game_context:getPetStarLvl(id)

	local need_lvl = 0
	local trs_cfg = g_i3k_db.i3k_db_get_pet_transfer_cfg(transfer+1)
	if trs_cfg then
		need_lvl = trs_cfg.maxLvl
	end

	if need_lvl ~= 0 and need_lvl == level then
		self._xiansuo_btn:onClick(self, self.onTransferLayer)
		self._xiansuo_btn:stateToPressed()
		self._xiansuo_label:setText("转职")
		self.recordID = 1
	else
		self._xiansuo_btn:onClick(self, self.onUpgradeLayer)
		self._xiansuo_btn:stateToPressed()
		self._xiansuo_label:setText("升级")
	end
	local upstar_cfg = g_i3k_db.i3k_db_get_pet_upstar_cfg(id,starlvl+1)
	if upstar_cfg then
		self._desc_btn:onClick(self, self.onUpStarLayer)
		self._desc_btn:stateToNormal()
		self._desc_label:setText("升星")
	else
		self._desc_btn:onClick(self, self.onBreakLayer)
		self._desc_btn:stateToNormal()
		self._desc_label:setText("突破")
	end
	self._attribute_btn:onClick(self, self.onAttributeLayer)
	self._attribute_btn:stateToNormal()
	self._attribute_btn:show()
	self._attribute_label:setText("属性")
	self.backfitBtn:hide()
	if level >= i3k_db_common.petBackfit.hexiuHideLvl then
		self.backfitBtn:show()
	end
	self:isShowWakenBtn(level);
	self.backfitBtn:stateToNormal()
	self.backfitBtn:onClick(self, self.onShowBackfit)
	----------更新左侧显示等级--------
	for k,v in pairs(self._showData) do
		if (v.id) == id then
			v.qlvl:setText(level)
			local tmp_str = string.format("%s转",transfer)
			v.attribute:setText(tmp_str)
		end
	end
	--更新战斗显示内容
	if isRefreshPower then
		--do nothing
	else
		self:refreshBattlePower(true)
	end
	self:isShowUpLvlRedPoint()
	self:updateUpStarRedPoint()
	self:onUpdatePetRedPoint()
end

function wnd_sui_cong:refreshTransferData()
	local level = g_i3k_game_context:getPetLevel(self._id)
	local transfer = g_i3k_game_context:getPetTransfer(self._id)
	local need_lvl = 0
	local trs_cfg = g_i3k_db.i3k_db_get_pet_transfer_cfg(transfer+1)
	if trs_cfg then
		need_lvl = trs_cfg.maxLvl
	end
	--self.canRefresh = true
	if need_lvl ~= 0 and need_lvl == level and self.canRefresh == true and self.recordID == 1 then
		self.jumpID = 4
		self:updateSuicongTransferData()
	end
end

function wnd_sui_cong:updateSuicongTransferData()
	if self.jumpID ~= 4 then
		return
	end
	local id = self._id
	self._xiansuo_btn:onClick(self, self.onTransferLayer)
	self._xiansuo_btn:stateToPressed()
	local _layer = require(LAYER_ZHUANZHI)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	---------------转职界面数据填充------------------
	local transfer = g_i3k_game_context:getPetTransfer(id)
	local level = g_i3k_game_context:getPetLevel(id)
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(id)
	local name = cfg.name
	local trs_cfg = g_i3k_db.i3k_db_get_pet_transfer_cfg(transfer+1)
	local is_ok1 = false
	local is_ok2 = false
	local is_ok3 = false
	for i=1,3 do
		local tmp_icon = string.format("zitem%s_icon",i)
		local tmp_name = string.format("zitem%s_name",i)
		local tmp_count = string.format("zitem%s_count",i)
		local tmp_bg = string.format("zitem%s_bg",i)
		local tmp_item = string.format("item%sID",i)
		local tmp_btn = string.format("item_btn%s",i)
		local itemid = trs_cfg[tmp_item]
		widgets[tmp_icon]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
		widgets[tmp_name]:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
		widgets[tmp_name]:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
		widgets[tmp_bg]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		widgets[tmp_btn]:onClick(self, self.onItemInfo, itemid)
		local tmpCount = string.format("item%sCount",i)
		local needCount = trs_cfg[tmpCount]
		local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
		local content = string.format("%s/%s", itemCount, needCount)
		if itemid < 65535 then --基本物品则只显示数量
			content = needCount
		end
		widgets[tmp_count]:setText(content)
		widgets[tmp_count]:setTextColor(g_i3k_get_cond_color(needCount <= itemCount))
		if needCount <= itemCount then
			if i == 1 then
				is_ok1 = true
			elseif i == 2 then
				is_ok2 = true
			elseif i == 3 then
				is_ok3 = true
			end
		end
	end
	if is_ok1 and is_ok2 and is_ok3 then
		widgets.transfer_btn:onClick(self, self.onTransferBtn)
		widgets.transfer_btn:enable()
	else
		widgets.transfer_btn:disableWithChildren()
	end
	---------------------设置页签按钮----------------------
	local starlvl = g_i3k_game_context:getPetStarLvl(id)
	local need_lvl = 0
	if trs_cfg then
		need_lvl = trs_cfg.maxLvl
	end
	if need_lvl ~= 0 and need_lvl == level then
		self._xiansuo_btn:onClick(self, self.onTransferLayer)
		self._xiansuo_btn:stateToPressed()
		self._xiansuo_label:setText("转职")
		self.recordID = 1
	else
		self._xiansuo_btn:onClick(self, self.onUpgradeLayer)
		self._xiansuo_btn:stateToPressed()
		self._xiansuo_label:setText("升级")
	end
	local upstar_cfg = g_i3k_db.i3k_db_get_pet_upstar_cfg(id,starlvl+1)
	if upstar_cfg then
		self._desc_btn:onClick(self, self.onUpStarLayer)
		self._desc_btn:stateToNormal()
		self._desc_label:setText("升星")
	else
		self._desc_btn:onClick(self, self.onBreakLayer)
		self._desc_btn:stateToNormal()
		self._desc_label:setText("突破")
	end
	self._attribute_btn:onClick(self, self.onAttributeLayer)
	self._attribute_btn:stateToNormal()
	self._attribute_btn:show()
	self._attribute_label:setText("属性")
	self.backfitBtn:hide()
	if level >= i3k_db_common.petBackfit.hexiuHideLvl then
		self.backfitBtn:show()
	end
	self.backfitBtn:stateToNormal()
	self.backfitBtn:onClick(self, self.onShowBackfit)
	----------更新左侧显示等级--------
	for k,v in pairs(self._showData) do
		if v.id == id then
			v.qlvl:setText(level)
			local tmp_str = string.format("%s转",transfer)
			v.attribute:setText(tmp_str)
		end
	end
	self.red_point1:setVisible(g_i3k_game_context:isShowPetTransferPoint(self._id))
	self:updateUpStarRedPoint()
end

function wnd_sui_cong:updateSuicongBreakData()
	self.jumpID = 7
	local _layer = require(LAYER_TUPO)()
	local widgets = _layer.vars --g_i3k_get_cond_color
	self:addNewNode(_layer)
	-------------------突破界面数据填充----------------------------
	local id = self._id
	local MaxCount = g_i3k_game_context:getCurrentPetCount()
	self._breakSkill = {}
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(id)
	for i=1,4 do
		local tmp_title = string.format("break%s_title",i)
		local tmp_value = string.format("break%s_value",i)
		local tmp_icon = string.format("break%s_icon",i)
		local tmp_attribute = string.format("break%s_attribute",i)
		local tmp_lvl = string.format("break%s_lvl",i)
		local tmp_btn =  string.format("break%s_btn",i)
		local tmp_skill = string.format("breakSkill%s",i)
		local break_skill = cfg[tmp_skill]
		local tmp_condition = string.format("breakSkill%sCondition",i)
		local break_condition = cfg[tmp_condition]
     
		
		local skillLvl =  g_i3k_game_context:getPetBreakSkillLvl(id,break_skill)
		local skillAttribute = i3k_db_suicong_breakdata[break_skill][skillLvl].skillType
		local skillIcon = i3k_db_suicong_breakdata[break_skill][skillLvl].skillIcon

		widgets[tmp_attribute]:setText(_attribute[skillAttribute])
		local tmp_str = string.format("%s名宠物达到9星开放",break_condition)
		widgets[tmp_title]:setText(tmp_str)
		local tmp_str = string.format("%s/%s",MaxCount,break_condition)
		widgets[tmp_value]:setText(tmp_str)
		widgets[tmp_value]:setTextColor(g_i3k_get_cond_color(MaxCount >= break_condition))
		if MaxCount >= break_condition then
			widgets[tmp_btn]:setTag(i)
			widgets[tmp_btn]:onTouchEvent(self, self.onUpBreakSkillLvl)
		else
			widgets[tmp_btn]:onTouchEvent(self, function(hoster, sender, eventType)
				if eventType == ccui.TouchEventType.began then
					g_i3k_ui_mgr:PopupTipMessage("未达到突破条件")
				end
			end)
		end
		widgets[tmp_icon]:setImage(g_i3k_db.i3k_db_get_icon_path(skillIcon))
		local tmp_str = string.format("%s级",skillLvl)
		widgets[tmp_lvl]:setText(tmp_str)
		self._breakSkill[i] = break_skill
		widgets["bg"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(7262))  ---背景
	    widgets["shuxingbg"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(7264))
		------------满级ui替换-------------------
		if not i3k_db_suicong_breakdata[id][skillLvl + 1] then
			widgets["bg"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(7263))
			widgets["shuxingbg"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(7265))
			widgets[tmp_btn]:hide()
			widgets["max"..i]:show()
		end
		
	end
	----------更新左侧显示星级--------
	local starlvl = g_i3k_game_context:getPetStarLvl(id)
	for k,v in pairs(self._showData) do
		if v.id== id then
			v.slvl:setImage(g_i3k_db.i3k_db_get_icon_path(star_icon[starlvl+1]))
		end
	end
	self:refreshBattlePower(true)
	self:updateUpLevelRedPoint()
	self.red_point2:setVisible(g_i3k_game_context:isShowBreakSkillPoint(self._id))
end

--出战 守护灵兽 更新属性
function wnd_sui_cong:updatePetProp()
	if self.jumpID == 5 then
		self:updateSuicongAttributeData()
	end
end
function wnd_sui_cong:updateSuicongAttributeData()
	self.jumpID = 5
	local _layer = require(LAYER_SHUXING)()
	self:addNewNode(_layer)
	--------------属性界面数据填充-----------------------
	local id = self._id
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(id)

	local friendLvl = g_i3k_game_context:getPetFriendLvl(id)
	local friendExp = g_i3k_game_context:getPetFriendExp(id)
	local level = g_i3k_game_context:getPetLevel(id)
	local needCount = 0
	local relation_cfg = g_i3k_db.i3k_db_get_pet_relation_cfg(self._id, friendLvl+1)
	local now_relation_cfg = g_i3k_db.i3k_db_get_pet_relation_cfg(self._id, friendLvl)
	if relation_cfg then
		needCount = relation_cfg.needCount
	else
		needCount = now_relation_cfg.needCount
	end
	_layer.vars.attFriend_title:setVisible(false)
	_layer.vars.attFriend_slider:setVisible(false)
	_layer.vars.attFriend_btn:setVisible(false)
	_layer.vars.attFriend_value:setVisible(false)
	_layer.vars.bg:setVisible(false)
	_layer.vars.bg2:setVisible(false)
	_layer.vars.lab:setVisible(false)
	self:getAttributeValue(level,_layer.vars.attribute_scroll)
	self:updateUpStarRedPoint()
	self:updateUpLevelRedPoint()
end

function wnd_sui_cong:getAttributeValue(lvl, attribute_scroll)
	if attribute_scroll then
		attribute_scroll:removeAllChildren()
	end
	local data = g_i3k_game_context:GetPetAttributeValue(self._id, lvl)
	local spirits = g_i3k_game_context:getPetSpiritsData(self._id)
	local petEqipProps = g_i3k_game_context:GetPetEquipProps(self._id)
	local battleId = g_i3k_game_context:getFieldPetID()
	local petGuardProps = g_i3k_db.i3k_db_pet_guard_pet_props()
	for i, e in pairs(data) do
		local _layer = require(LAYER_SCSXT)()
		for _,v in ipairs(spirits) do
			if v.id ~= 0 then
				local proID, value = g_i3k_game_context:GetMercenarySpirits(self._id, v.id, v.level, 1)
				if proID and e.proID and proID == e.proID then
					e.value = e.value + value
				end
			end
		end

		--宠物装备属性
		for propID, propValue in pairs(petEqipProps) do
			if e.proID == propID then
				e.value = e.value + propValue
			end
		end
		--守护灵兽属性
		for propID, propValue in pairs(petGuardProps) do
			if e.proID == propID then
				if type(e.value) == "string" then--百分比属性
					local numberValue = tonumber(string.sub(e.value, 1, -2))
					e.value = (numberValue + propValue / 100).."%"
				else
					e.value = e.value + propValue
				end
			end
		end

		_layer.vars.propertyName:setText(e.name)
		_layer.vars.propertyValue:setText(e.value)
		local icon
		if i == 8 then
			icon = 1934
		elseif i == 9 then
			icon = 1933
		elseif i == 10 then
			icon = 1018
		elseif i == 11 then
			icon = 1021
		else
			icon = g_i3k_db.i3k_db_get_property_icon(1000 + i)
		end
		_layer.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		if attribute_scroll then
			attribute_scroll:addItem(_layer)
		end
	end
	self:updateWidgetBg(attribute_scroll)
end

function wnd_sui_cong:updateSuicongUpStarData()
	if self.jumpID ~= 3 then
		return
	end
	local _layer = require(LAYER_SHENGXING)()
	local widgets = _layer.vars
	self:addNewNode(_layer)

	local id = self._id

	local starlvl =  g_i3k_game_context:getPetStarLvl(id)
	widgets.upstar_btn:onClick(self, self.onShengxingBtn)

	local old_upstar_cfg = g_i3k_db.i3k_db_get_pet_upstar_cfg(id,starlvl)
	local upstar_cfg = g_i3k_db.i3k_db_get_pet_upstar_cfg(id,starlvl+1)
	if not upstar_cfg then
		return
	end

	local itemid = upstar_cfg.itemid
	local needItemCount = upstar_cfg.itemCount
	local haveItemCount = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
	local replaceItem = upstar_cfg.replaceItem
	local raplceCount = g_i3k_game_context:GetCommonItemCanUseCount(replaceItem)

	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	widgets.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
	widgets.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
	local tmp_str = string.format("%s/%s", haveItemCount, needItemCount)
	widgets.item_count:setText(tmp_str)
	widgets.item_count:setTextColor(g_i3k_get_cond_color(raplceCount + haveItemCount >= needItemCount))
	widgets.item_bg_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	widgets.item_btn1:onClick(self, self.onItemInfo, itemid)
	widgets.replaceItem_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(replaceItem,i3k_game_context:IsFemaleRole()))
	widgets.replaceItem_name:setText(g_i3k_db.i3k_db_get_common_item_name(replaceItem))
	widgets.replaceItem_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(replaceItem)))
	widgets.replaceItem_count:setText(raplceCount)
	widgets.replaceItem_count:setTextColor(g_i3k_get_cond_color(raplceCount + haveItemCount >= needItemCount))
	widgets.item_btn2:onClick(self, self.onItemInfo, replaceItem)
	widgets.replaceItemBgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(replaceItem))
	local attribute1Vlaue = old_upstar_cfg.hurtIncrease /10000
	local attribute1VlaueN = upstar_cfg.hurtIncrease / 10000
	local attribute2Vlaue = old_upstar_cfg.hurtAvoid / 10000
	local attribute2VlaueN = upstar_cfg.hurtAvoid / 10000
	local attribute3Vlaue = old_upstar_cfg.xinfaIncrease
	local attribute3VlaueN = upstar_cfg.xinfaIncrease
	local attribute4Vlaue = old_upstar_cfg.weaponIncrease
	local attribute4VlaueN = upstar_cfg.weaponIncrease

	widgets.attribute1:setText(_attribute[1])
	local tmp_str = string.format("+%s%%",attribute1Vlaue*100)
	widgets.value1:setText(tmp_str)
	local tmp_str = string.format("+%s%%",attribute1VlaueN*100)
	widgets.nextValue1:setText(tmp_str)
	widgets.attribute2:setText(_attribute[2])
	local tmp_str = string.format("+%s%%",attribute2Vlaue*100)
	widgets.value2:setText(tmp_str)
	local tmp_str = string.format("+%s%%",attribute2VlaueN*100)
	widgets.nextValue2:setText(tmp_str)
	widgets.skillName:setText(_attribute[3])
	local tmp_str = string.format("+%s%%",attribute3Vlaue*100)
	widgets.skillValue:setText(tmp_str)
	local tmp_str = string.format("+%s%%",attribute3VlaueN*100)
	widgets.skillNextValue:setText(tmp_str)
	widgets.gradeName:setText(_attribute[4])
	local tmp_str = string.format("+%s%%",attribute4Vlaue*100)
	widgets.gradeValue:setText(tmp_str)
	local tmp_str = string.format("+%s%%",attribute4VlaueN*100)
	widgets.gradeNextValue:setText(tmp_str)
	widgets.get_btn:onTouchEvent(self,self.onGetBtn)
	widgets.buy_btn:onClick(self, self.onBuyBtn)
	for k,v in pairs(self._showData) do
		if (v.id) == id then
			v.slvl:setImage(g_i3k_db.i3k_db_get_icon_path(star_icon[starlvl+1]))
		end
	end
	self:refreshBattlePower(true)
	self:updateUpLevelRedPoint()
	self:onUpdatePetRedPoint()
	self.red_point2:setVisible(g_i3k_game_context:isShowPetUpStarPoint(self._id))
end

function wnd_sui_cong:onShengxingBtn(sender)
	local id = self._id
	local starlvl = g_i3k_game_context:getPetStarLvl(id)
	starlvl = starlvl + 1
	-- 判断是否有足够材料
	local upstar_cfg = g_i3k_db.i3k_db_get_pet_upstar_cfg(id,starlvl)
	if not upstar_cfg then
		return
	end
	local cost_item_id = upstar_cfg.itemid
	local replace_item_id = upstar_cfg.replaceItem
	local cost_item_count = upstar_cfg.itemCount
	local curr_item_count = g_i3k_game_context:GetCommonItemCanUseCount(cost_item_id) + g_i3k_game_context:GetCommonItemCanUseCount(replace_item_id)
	if cost_item_count > curr_item_count then
		-- 材料不足，无法升星
		g_i3k_ui_mgr:PopupTipMessage("材料不足，无法升星")
	else
		local count1 = g_i3k_game_context:GetCommonItemCanUseCount(cost_item_id)
		local count2 = g_i3k_game_context:GetCommonItemCanUseCount(replace_item_id)
		if count1 >= cost_item_count then
			i3k_sbean.goto_pet_starup(id, starlvl, cost_item_count, 0)
		else
			i3k_sbean.goto_pet_starup(id, starlvl, count1, cost_item_count - count1)
		end
	end
end

function wnd_sui_cong:onGetBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_GetTips)
end

function wnd_sui_cong:onBuyBtn(sender,eventType)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyTips)
end

function wnd_sui_cong:onCallSuicong(sender)
	i3k_sbean.pet_make(self._id)
end

function wnd_sui_cong:onXiansuoLayer(sender)
	self.jumpID = 1
	self:updateXiansuoData()
	self._xiansuo_btn:stateToPressed()
	self._desc_btn:stateToNormal()
end

function wnd_sui_cong:onDescLayer(sender)
	self:updatePetDesc()
	self._xiansuo_btn:stateToNormal()
	self._desc_btn:stateToPressed()
end

function wnd_sui_cong:setCanUse(canUse)
	self._canUse = canUse
end

function wnd_sui_cong:onUseItem(sender, eventType, data)
	self.needId = data.itemid
	local itemid = data.itemid
	if eventType == ccui.TouchEventType.began then
		if data.count == 0 then
			g_i3k_ui_mgr:ShowCommonItemInfo(itemid)
			return
		end
		self:onUpLevelPet(data.layer)
		self.co = g_i3k_coroutine_mgr:StartCoroutine(function()
			while true do
				g_i3k_coroutine_mgr.WaitForSeconds(0.5) --延时
				if g_i3k_game_context:GetCommonItemCanUseCount(itemid) <=0 then
					g_i3k_ui_mgr:PopupTipMessage("所需道具不足")
					return false
				end
				if self._canUse then
					self:onUpLevelPet(data.layer)
					self._canUse = false
				end
			end
		end)
	elseif eventType == ccui.TouchEventType.ended then
		g_i3k_coroutine_mgr:StopCoroutine(self.co)
	elseif eventType==ccui.TouchEventType.canceled then
		g_i3k_coroutine_mgr:StopCoroutine(self.co)
	end
end

function wnd_sui_cong:onUpLevelPet(layer)
	local itemid = self.needId
	if g_i3k_game_context:GetCommonItemCanUseCount(itemid) <=0 then
		g_i3k_ui_mgr:PopupTipMessage("所需道具不足")
		return false
	end
	if not  g_i3k_game_context:IsHavePet(self._id) then
		return false
	end
	local lvl = g_i3k_game_context:getPetLevel(self._id)
	local transfer = g_i3k_game_context:getPetTransfer(self._id)
	local transfer_level = 0
	local trs_cfg = g_i3k_db.i3k_db_get_pet_transfer_cfg(transfer+1)
	if trs_cfg then
		transfer_level = trs_cfg.maxLvl
	end
	local now_exp = g_i3k_game_context:getPetExp(self._id)
	local item_cfg = g_i3k_db.i3k_db_get_common_item_cfg(itemid)
	local total_exp = item_cfg.args1
	----------------------
	local _lvl = g_i3k_game_context:GetLevel()
	local up_lvl = lvl
	local is_ok2 = false
	local need_exp = 0
	local uplvl_cfg = g_i3k_db.i3k_db_get_pet_uplvl_cfg(up_lvl+1)
	while uplvl_cfg do
		need_exp = uplvl_cfg.value + need_exp
		if need_exp > now_exp + total_exp then
			need_exp = need_exp - uplvl_cfg.value
			break
		else
			up_lvl = up_lvl + 1
			uplvl_cfg = g_i3k_db.i3k_db_get_pet_uplvl_cfg(up_lvl+1)
			if up_lvl == transfer_level then
				is_ok2 = true
				break
			end
		end
	end
	local last_exp = now_exp + total_exp - need_exp
	if is_ok2 then
		local new_uplvl_cfg = g_i3k_db.i3k_db_get_pet_uplvl_cfg(up_lvl+1)
		if last_exp > new_uplvl_cfg.value then
			last_exp = new_uplvl_cfg.value -1
		end
	end
	local temp_count = 1
	local temp = {}
	temp[itemid] = temp_count

	if _lvl < up_lvl then
		g_i3k_ui_mgr:PopupTipMessage("宠物等级不可超过角色等级")
		return false
	end
	local compare_lvl = {isUpLvl= false,before_lvl=0}
	if up_lvl ~= lvl then
		compare_lvl.isUpLvl = true
		compare_lvl.before_lvl = lvl
	end
	i3k_sbean.goto_pet_levelup(self._id, temp, up_lvl, last_exp, compare_lvl, layer)
end

function wnd_sui_cong:onUseExpAuto(sender)
	if g_i3k_game_context:isEnoughUpPetLevel(self._id) then
		i3k_sbean.goto_pet_levelup(self._id, g_i3k_game_context:isEnoughUpPetLevel(self._id))
	else
		g_i3k_ui_mgr:PopupTipMessage("您不满足升级条件")
	end
end

function wnd_sui_cong:updateDiamondData()
	self.jumpID = 10
	local _layer = require(LAYER_YUANBAO)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	widgets.back:onClick(self, self.backBtn)

	local id = self._id
	local now_lvl = g_i3k_game_context:getPetLevel(id)
	local now_exp = g_i3k_game_context:getPetExp(id)
	local uplvl_cfg = g_i3k_db.i3k_db_get_pet_uplvl_cfg(now_lvl+1)
	local need_exp = uplvl_cfg.value
	widgets.level:setText("等级：")
	widgets.value:setText(now_lvl)
	widgets.exp_slider:setPercent(now_exp/need_exp*100)
	local tmp_str = string.format("%s/%s", now_exp, need_exp)
	widgets.exp_value:setText(tmp_str)
	local needDiamond1 = g_i3k_db.i3k_db_get_pet_need_diamond(id, now_lvl+1)
	local str1 = string.format("%s", needDiamond1)
	str1 = g_i3k_make_color_string(str1, g_i3k_get_cond_color(g_i3k_game_context:GetDiamondCanUse(true) >= needDiamond1))
	widgets.desc1:setText(string.format("消耗[%s]元宝，直接提升1级", str1))
	local maxLvl = g_i3k_db.i3k_db_pet_can_up_level(id)
	local upNum = maxLvl - now_lvl >= 5 and 5 or maxLvl - now_lvl --计算是否可以升级五级
	local needDiamond2 =  g_i3k_db.i3k_db_get_pet_need_diamond(id, now_lvl+upNum)
	local str2 = string.format("%s", needDiamond2)
	str2 = g_i3k_make_color_string(str2, g_i3k_get_cond_color(g_i3k_game_context:GetDiamondCanUse(true) >= needDiamond2))
	widgets.desc2:setText(string.format("消耗[%s]元宝，直接提升%s级", str2, upNum))
	widgets.btn_desc:setText(string.format("升%s级", upNum))
	local needDiamond3 = g_i3k_db.i3k_db_get_pet_need_diamond(id, maxLvl)
	local str3 = string.format("%s", needDiamond3)
	str3 = g_i3k_make_color_string(str3, g_i3k_get_cond_color(g_i3k_game_context:GetDiamondCanUse(true) >= needDiamond3))
	if g_i3k_game_context:GetDiamondCanUse(true) >= needDiamond3 then
		widgets.btn3:enableWithChildren()
	else
		widgets.btn3:disableWithChildren()
	end
	if g_i3k_game_context:GetDiamondCanUse(true) >= needDiamond2 then
		widgets.btn2:enableWithChildren()
	else
		widgets.btn2:disableWithChildren()
	end
	if g_i3k_game_context:GetDiamondCanUse(true) >= needDiamond1 then
		widgets.btn1:enableWithChildren()
	else
		widgets.btn1:disableWithChildren()
	end
	widgets.desc3:setText(string.format("消耗[%s]元宝，升至最大级别", str3))
	widgets.btn1:onClick(self, self.onUseDiamondUpOne, {diamond = needDiamond1, level = now_lvl+1})
	widgets.btn2:onClick(self, self.onUseDiamondUpFive, {diamond = needDiamond2, level = now_lvl+upNum})
	widgets.btn3:onClick(self, self.onUseDiamondUpMax, {diamond = needDiamond3, level = maxLvl})
	----------更新左侧显示等级--------
	for k,v in pairs(self._showData) do
		if (v.id) == id then
			v.qlvl:setText(now_lvl)
			local transfer = g_i3k_game_context:getPetTransfer(id)
			local tmp_str = string.format("%s转",transfer)
			v.attribute:setText(tmp_str)
		end
	end
	--更新战斗显示内容
	self:refreshBattlePower(true)
	self:isShowUpLvlRedPoint()
	self:updateUpStarRedPoint()
end

function wnd_sui_cong:backBtn(sender)
	self:onUpLvlUpdata(isRefreshPower)
end

function wnd_sui_cong:onUseDiamondUpLvl(sender)
	if g_i3k_game_context:getPetLevel(self._id) >= g_i3k_game_context:GetLevel() then
		g_i3k_ui_mgr:PopupTipMessage("宠物已达到最大级别")
		return
	end
	self:updateDiamondData()
end

function wnd_sui_cong:onUseDiamondUpOne(sender, data)
	if g_i3k_game_context:GetDiamondCanUse(true) >= data.diamond then
		i3k_sbean.goto_buylevel(self._id, data.level, data.diamond)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(58))
	end
end

function wnd_sui_cong:onUseDiamondUpFive(sender, data)
	if g_i3k_game_context:GetDiamondCanUse(true) >= data.diamond then
		i3k_sbean.goto_buylevel(self._id, data.level, data.diamond)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(58))
	end
end

function wnd_sui_cong:onUseDiamondUpMax(sender, data)
	if g_i3k_game_context:GetDiamondCanUse(true) >= data.diamond then
		i3k_sbean.goto_buylevel(self._id, data.level, data.diamond)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(58))
	end
end

function wnd_sui_cong:onUpgradeLayer(sender)
	self.jumpID = 2
	self._xiansuo_btn:stateToPressed()
	self._desc_btn:stateToNormal()
	self._attribute_btn:stateToNormal()
	self.backfitBtn:stateToNormal()
	self:setPetUplvlData()
end

function wnd_sui_cong:onTransferLayer(sender)
	self.jumpID = 4
	self._xiansuo_btn:stateToPressed()
	self._desc_btn:stateToNormal()
	self._attribute_btn:stateToNormal()
	self.backfitBtn:stateToNormal()
	self:updateSuicongTransferData()
end

function wnd_sui_cong:onBreakLayer(sender)
	self.jumpID = 7
	self._xiansuo_btn:stateToNormal()
	self._desc_btn:stateToPressed()
	self._attribute_btn:stateToNormal()
	self.backfitBtn:stateToNormal()
	self:updateSuicongBreakData()
end

function wnd_sui_cong:onUpStarLayer(sender)
	self.jumpID = 3
	self._xiansuo_btn:stateToNormal()
	self._desc_btn:stateToPressed()
	self._attribute_btn:stateToNormal()
	self.backfitBtn:stateToNormal()
	self:updateSuicongUpStarData()
end

function wnd_sui_cong:onAttributeLayer(sender)
	self.jumpID = 5
	self._xiansuo_btn:stateToNormal()
	self._desc_btn:stateToNormal()
	self._attribute_btn:stateToPressed()
	self.backfitBtn:stateToNormal()
	self:updateSuicongAttributeData()
end

function wnd_sui_cong:onTransferBtn(sender)
	i3k_sbean.goto_pet_transform(self._id, g_i3k_game_context:getPetTransfer(self._id) + 1)
end

function wnd_sui_cong:onUpBreakSkillLvl(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local tag = sender:getTag()
		local skillid = self._breakSkill[tag]
		local lvl = g_i3k_game_context:getPetBreakSkillLvl(self._id,skillid)
		if not i3k_db_suicong_breakdata[self._id][lvl + 1] then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(59))
			return
		end
		g_i3k_ui_mgr:OpenUI(eUIID_SuicongBreakTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_SuicongBreakTips, self._id, skillid)
	end
end

function wnd_sui_cong:onUpLvlUpdata(isRefreshPower)
	local id = self._id
	local transfer = g_i3k_game_context:getPetTransfer(id)
	local level = g_i3k_game_context:getPetLevel(id)
	local need_lvl = 0
	local trs_cfg = g_i3k_db.i3k_db_get_pet_transfer_cfg(transfer+1)
	if trs_cfg then
		need_lvl = trs_cfg.maxLvl
	end
	if need_lvl ~= 0 and need_lvl == level then
		self._xiansuo_btn:onClick(self, self.onTransferLayer)
		self._xiansuo_btn:stateToPressed()
		self.jumpID = 4
		self:updateSuicongTransferData()
	else
		self._xiansuo_btn:onClick(self, self.onUpgradeLayer)
		self._xiansuo_btn:stateToPressed()
		self:setPetUplvlData(isRefreshPower)
	end
end

function wnd_sui_cong:onUpdataStarLayerOrBreakLayer()
	local id = self._id
	local starlvl = g_i3k_game_context:getPetStarLvl(id)
	local upstar_cfg = g_i3k_db.i3k_db_get_pet_upstar_cfg(id,starlvl+1)
	if upstar_cfg then
		self.jumpID = 3
		self:updateSuicongUpStarData()
		self._desc_btn:onClick(self, self.onUpStarLayer)
		self._desc_label:setText("升星")
	else
		self.jumpID = 7
		self:updateSuicongBreakData()
		self._desc_btn:onClick(self, self.onBreakLayer)
		self._desc_label:setText("突破")
	end
end

function wnd_sui_cong:refresh(id)
	if id then
		self._id = id;
	end
	self:updateAllPetList(i3k_db_mercenaries)
	self:updateAllPetMsg()
	self:updateSelectMark()
	self:updateSelectData(g_i3k_game_context:IsHavePet(self._id), g_i3k_game_context:getPetTransfer(self._id), g_i3k_game_context:getPetLevel(self._id))
	self:updateBattleMatk()
end

function wnd_sui_cong:updateStarDate()
	self:updateAllPetList(i3k_db_mercenaries)
	self:updateSuicongUpStarData()
	self:onUpdataStarLayerOrBreakLayer()
	self:updateAllPetMsg()
	self:updateSelectMark()
	self:updateBattleMatk()
end

function wnd_sui_cong:testRefresh()
	self:updateAllPetList(i3k_db_mercenaries)
	self:updateAllPetMsg()
	self:updateSelectMark()
	self:updateBattleMatk()
end

function wnd_sui_cong:refreshDiamond()
	self:updateAllPetList(i3k_db_mercenaries)
	self:updateAllPetMsg()
	self:updateSelectMark()
	self:updateBattleMatk()
end

function wnd_sui_cong:refreshPetBuyLevel()
	local old_layer = self.new_root:getAddChild()
	if old_layer[1].vars.back then
		self:updateDiamondData()
	end
end

function wnd_create(layout)
	local wnd = wnd_sui_cong.new()
	wnd:create(layout)
	return wnd
end

function wnd_sui_cong:refreshBattlePower(ishave)
	self._battle_power:setVisible(ishave)
	self.power_image:setVisible(ishave)
	self.addIcon:hide()
	self.powerValue:hide()
	if not self._isChange then
		local a,b,friend = g_i3k_game_context:GetAllYongBing()
		if ishave and a[self._id] then
			local power = math.modf(self:getBattlePower())
			local tmp_str = string.format("%s", power)
			self._battle_power:setText(tmp_str)
		end
	end
end

function wnd_sui_cong:getBattlePower(id)
	id = id or (self._id)
	return g_i3k_game_context:getBattlePower(id)
end

function wnd_sui_cong:changeBattlePower(newBattlePower, oldBattlePower)
	self._isChange = true
	self._poptick = 0
	self._target = newBattlePower
	self._base = oldBattlePower
end

function wnd_sui_cong:onUpdate(dTime)--随从战力变化时动画
	if self._isChange then
		self._poptick = self._poptick + dTime
		if self._poptick < 1 then
			local text = self._base + math.floor((self._target - self._base)*self._poptick)
			self._battle_power:setText(text)
			self.addIcon:show()
			self.powerValue:show()
			if self._target >= self._base then
				self.addIcon:setImage(g_i3k_db.i3k_db_get_icon_path(174))
				self.powerValue:setText("+"..self._target - self._base)
			else
				self.addIcon:setImage(g_i3k_db.i3k_db_get_icon_path(175))
				self.powerValue:setText(self._target - self._base)
			end
			self.powerValue:setTextColor(g_i3k_get_cond_color(self._target >= self._base))
		elseif self._poptick >= 1 and self._poptick < 2 then
			self._battle_power:setText(self._target)
			self.addIcon:hide()
			self.powerValue:hide()
		elseif self._poptick > 2 then
			self.addIcon:hide()
			self.powerValue:hide()
			self._isChange = false
		end
	end
	if i3k_game_get_time() - self.record_time >  SHOW_TIME and self.record_time ~= 0 then
		self.c_zh.stop()
		self.global:hide()
		self.record_time = 0
	end
	if i3k_game_get_time() - self._handleTime > HandleTime then
		self._handleTime = 0
	end
	
	if self._startChageModle then
		self._chageTime = self._chageTime  + dTime;
		if self._chageTime > 1 then
			if self._chageModleId > 0 then
				g_i3k_game_context:setPetIsWaken(self._id, 1);
				g_i3k_game_context:setPetWakenUse(self._id, 1);
				self:isShowWakenBtn(g_i3k_game_context:getPetLevel(self._id));
				self:updateHeadIcon(true);
				self:updatePetModule(self._chageModleId, false, true);
				self._startChageModle = false;
				self._awakenWin = true;
			end
		end
	end
	if self._awakenWin then
		self._awakenTime = self._awakenTime  + dTime;
		if self._awakenTime > 3 then
			if not g_i3k_ui_mgr:GetUI(eUIID_SuicongAwakenWin) then
					self._changePowerCo = g_i3k_coroutine_mgr:StartCoroutine(function()
					g_i3k_coroutine_mgr.WaitForNextFrame()
					local oldPower = math.modf(g_i3k_game_context:getBattlePower(self._id))
					g_i3k_ui_mgr:OpenUI(eUIID_SuicongAwakenWin)
					g_i3k_ui_mgr:RefreshUI(eUIID_SuicongAwakenWin, self._id)
					g_i3k_game_context:SetPrePower()
					g_i3k_game_context:RefreshMercenaryRelationProps()
					g_i3k_game_context:ShowPowerChange()
					local afterPower = math.modf(g_i3k_game_context:getBattlePower(self._id))
					self:changeBattlePower(afterPower, oldPower);
					self._changePowerCo  = nil
				end)
				self._awakenWin = false;
			end
		end
	end
end

function wnd_sui_cong:updateUpLevelRedPoint()
	local transfer = g_i3k_game_context:getPetTransfer(self._id)
	local need_lvl
	if i3k_db_suicong_transfer[transfer + 1] then
		need_lvl = i3k_db_suicong_transfer[transfer + 1].maxLvl
	end
	if need_lvl and need_lvl == g_i3k_game_context:getPetLevel(self._id) then
		self.red_point1:setVisible(g_i3k_game_context:isShowPetTransferPoint(self._id))
	else
		self:isShowUpLvlRedPoint()
	end
end

function wnd_sui_cong:isShowUpLvlRedPoint()
	local redPoint = g_i3k_game_context:isEnoughUpPetLevel(self._id)
	local isShow = redPoint and true or false
	self.red_point1:setVisible(isShow)
end

function wnd_sui_cong:updateUpStarRedPoint()
	local starlvl = g_i3k_game_context:getPetStarLvl(self._id)
	if i3k_db_suicong_upstar[self._id][starlvl + 1] then
		self.red_point2:setVisible(g_i3k_game_context:isShowPetUpStarPoint(self._id))
	else
		self.red_point2:setVisible(g_i3k_game_context:isShowBreakSkillPoint(self._id))
	end
end

function wnd_sui_cong:updateWidgetBg(scroll)
	local all_child = scroll:getAllChildren()
	for i, e in pairs(all_child) do
		local color = i%2 ~= 0 and "fff45481" or "ff714e40" --粉色，棕色
		e.vars.diwen:setVisible(i%2 ~= 0)
		e.vars.propertyName:setTextColor(color)
		e.vars.propertyValue:setTextColor(color)
	end
end

--合修界面
function wnd_sui_cong:onShowBackfit(sender)
	self:updateUpStarRedPoint()
	self:updateUpLevelRedPoint()
	self.jumpID = 6
	local level = g_i3k_game_context:getPetLevel(self._id)
	local cfg = g_i3k_db.i3k_db_get_pet_cfg(self._id)
	if level < i3k_db_common.petBackfit.hexiuNeedLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(611,cfg.name, i3k_db_common.petBackfit.hexiuNeedLvl)) --合修将在<c=hlgreen>%s</c>达到%s级后开启
		return
	end
	self._xiansuo_btn:stateToNormal()
	self._desc_btn:stateToNormal()
	self._attribute_btn:stateToNormal()
	self.backfitBtn:stateToPressed()
	local id, value = g_i3k_game_context:getPetTskIdAndValueById(self._id)
	local fromID, lifeValue, reward = g_i3k_game_context:getPetLifeTskIdAndValueById(self._id)
	if fromID == #i3k_db_from_task[self._id] and reward == 1 then
		local _layer = require(LAYER_HEXIU)()
		local widgets = _layer.vars
		self:addNewNode(_layer)
		local friendLvl = g_i3k_game_context:getPetFriendLvl(self._id)
		if friendLvl == 0 then
			friendLvl = 1
		end
		widgets.attFriend_title:setText("喂养等级：" .. friendLvl)
		local info = i3k_db_suicong_relation[self._id][friendLvl]
		local friendExp = g_i3k_game_context:getPetFriendExp(self._id)
		local needCount = 0
		local relation_cfg = g_i3k_db.i3k_db_get_pet_relation_cfg(self._id, friendLvl+1)
		local now_relation_cfg = g_i3k_db.i3k_db_get_pet_relation_cfg(self._id, friendLvl)
		local activeSkill1Lvl = now_relation_cfg.activeSkill1Lvl
		local times = g_i3k_game_context:GetDailyCompleteTask(self._id)
		widgets.attFriend_lab:setText(i3k_get_string(667, i3k_db_common.petBackfit.petTaskMax - times))
		if times == i3k_db_common.petBackfit.petTaskMax then
			widgets.attFriend_btn:disableWithChildren()
			widgets.attFriend_lab:setText(i3k_get_string(667, 0))
		end	
		if relation_cfg then
			needCount = relation_cfg.needCount
			widgets.maxLvl:setVisible(false)
			widgets.attFriend_btn:show()
			widgets.attFriend_value:setVisible(true)
			widgets.attFriend_slider:setPercent(friendExp/needCount*100)
			widgets.max:hide()
		else
			needCount = now_relation_cfg.needCount
			widgets.maxLvl:setVisible(true)
			widgets.attFriend_btn:hide()
			-- widgets.attFriend_lab:setText(i3k_get_string(948))
			widgets.max:show()
			widgets.attFriend_value:setVisible(false)
			widgets.attFriend_slider:setPercent(100)
		end
		
		widgets.attFriend_value:setText(friendExp .. "/" .. needCount)
		widgets.attFriend_btn:onClick(self, self.onEnterToTask)
		widgets.value:setText(activeSkill1Lvl .. "级")
		local propertyID = {
			info.propertyId1,
			info.propertyId2,
			info.propertyId3,
			info.propertyId4,
			info.propertyId5,
			info.propertyId6,
			info.propertyId7,
		}
		local propertyCount = {
			info.propertyCount1,
			info.propertyCount2,
			info.propertyCount3,
			info.propertyCount4,
			info.propertyCount5,
			info.propertyCount6,
			info.propertyCount7,
		}
		widgets.attribute_scroll:removeAllChildren()
		for i=1,#propertyID do
			if propertyID[i] ~= 0 then
				local _layer = require(LAYER_SCSXT)()
				_layer.vars.propertyName:setText(i3k_db_prop_id[propertyID[i]].desc)
				if g_i3k_game_context:getPetStarLvl(self._id) == #i3k_db_suicong_upstar[self._id] and not g_i3k_game_context:getPetIsWaken(self._id) then
					propertyCount[i] = propertyCount[i] * (i3k_db_common.petBackfit.upCount/10000 + 1)
				elseif g_i3k_game_context:getPetStarLvl(self._id) ~= #i3k_db_suicong_upstar[self._id] and g_i3k_game_context:getPetIsWaken(self._id) then
					propertyCount[i] = propertyCount[i] * (i3k_db_mercenariea_waken_property[self._id].upArg/10000 + 1)
				elseif g_i3k_game_context:getPetStarLvl(self._id) == #i3k_db_suicong_upstar[self._id] and g_i3k_game_context:getPetIsWaken(self._id) then
					propertyCount[i] = propertyCount[i] * (i3k_db_mercenariea_waken_property[self._id].upArg/10000 + i3k_db_common.petBackfit.upCount/10000 + 1)
				end
				_layer.vars.propertyValue:setText(i3k_get_prop_show(propertyID[i],propertyCount[i]))
				_layer.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_property_icon_path(propertyID[i]))
				widgets.attribute_scroll:addItem(_layer)
			end
		end
		
	else
		local _layer = require(LAYER_SHENSHI)()
		local widgets = _layer.vars
		self:addNewNode(_layer)
		widgets.call_btn:onClick(self, self.openShenShiExplore)
		local value = fromID - 1 < 0 and 0 or (fromID - 1)
		widgets.friend_slider1:setPercent(value/#i3k_db_from_task[self._id] * 100)
       
	end

end

function wnd_sui_cong:openShenShiExplore(sender)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	local id, value,reward = g_i3k_game_context:getPetLifeTskIdAndValueById(self._id)
	id = id == 0 and 1 or id
	g_i3k_ui_mgr:OpenUI(eUIID_ShenshiExplore)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenshiExplore, self._id, id)
end

--随从成就入口
function wnd_sui_cong:achievementInto()
	g_i3k_ui_mgr:OpenUI(eUIID_PetAchievement)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetAchievement)
end

--随从小红点
function wnd_sui_cong:onUpdatePetRedPoint()
	local isCan = g_i3k_game_context:getIsCompletePetLifeTaskFromID(self._id)
	local is_have = false
	if isCan then
		is_have = g_i3k_game_context:petTaskRedPoint(self._id)
	end
	self._layout.vars.red_point4:setVisible(is_have)
	local allPetLayer = self._pet_scroll:getAllChildren()
	for k, v in ipairs(allPetLayer) do
		local widgets = v.vars
		local id = widgets.id
		if id == self._id then
			widgets.red_point:setVisible(g_i3k_game_context:isShowPetPoint(self._id))
		end
	end
end

function wnd_sui_cong:updateSpiritsData()
	g_i3k_ui_mgr:OpenUI(eUIID_AllSpirits)
	g_i3k_ui_mgr:RefreshUI(eUIID_AllSpirits)
end

function wnd_sui_cong:updatePetXinfa()
	
	self.jumpID = 9
	self._xiansuo_btn:stateToNormal()
	self._desc_btn:stateToNormal()
	self._attribute_btn:stateToNormal()
	self.backfitBtn:stateToNormal()
	local _layer = require(LAYER_XINFA)()
	local widgets = _layer.vars
	self:addNewNode(_layer)
	local exploit = g_i3k_game_context:getPetExploit(self._id)
	widgets.count:setText(exploit)
	widgets.btn:onClick(self, self.exploitDesc)
	widgets.scroll:removeAllChildren()
	
	local spirits = g_i3k_game_context:getPetSpiritsData(self._id)
	local exploitConfig = i3k_db_suicong_exploit[self._id]
	
	for i = 1, #exploitConfig do
		local spirit = spirits[i]
		if spirit and spirit.id ~=0 then
			local cfg = i3k_db_suicong_spirits[spirit.id][spirit.level]
			local layer_1 = require(LAYER_XINFAT1)()
			local widget_1 = layer_1.vars
			widget_1.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_suicong_spirits[spirit.id][1].icon))
			--widget_1.iconBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cfg.icon))
			widget_1.name:setText(i3k_db_suicong_spirits[spirit.id][1].name)
			widget_1.level:setText(spirit.level .. "级")
			widget_1.select:setImage(g_i3k_db.i3k_db_get_icon_path(2987))
			widget_1.btn:onClick(self, self.spiritsTips, {id = cfg.id, level = spirit.level, index = i, petID = self._id, widget = widget_1})
			widgets.scroll:addItem(layer_1)
		else
			local cfg = exploitConfig[i]
			local layer = exploit >= cfg.needExploit and require(LAYER_XINFAT3)() or require(LAYER_XINFAT2)()
			local widget = layer.vars
			widget.select:setImage(g_i3k_db.i3k_db_get_icon_path(2987))
			if widget.label then
				local str = string.format("战绩%s解锁", cfg.needExploit)
				widget.btn:onClick(self, self.exploitDesc, widget.select)
				widget.label:setText(str)
			elseif widget.imageBtn then 
				widget.imageBtn:onClick(self, self.studyXinfa, {id = self._id, index = i, cSelect= widget.select})
			end
			widgets.scroll:addItem(layer)
		end
	end
	
	self:updateXinFaRedPoint();
end

function wnd_sui_cong:studyXinfa(sender, data)
	local item = g_i3k_game_context:getCanStudySpirits(self._id)
	if next(item) then
		data.cSelect:setImage(g_i3k_db.i3k_db_get_icon_path(2988))
		g_i3k_ui_mgr:OpenUI(eUIID_StudySpirit)
		g_i3k_ui_mgr:RefreshUI(eUIID_StudySpirit, data.id, data.index)
	else
		g_i3k_ui_mgr:PopupTipMessage("武库中已无心法可学习")
	end
end

function wnd_sui_cong:exploitDesc(sender, cSelect)
	if cSelect then
		cSelect:setImage(g_i3k_db.i3k_db_get_icon_path(2988))
	end
	g_i3k_ui_mgr:OpenUI(eUIID_ExploitTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_ExploitTips, cSelect)
end

function wnd_sui_cong:spiritsTips(sender, data)
	data.widget.select:setImage(g_i3k_db.i3k_db_get_icon_path(2988))
	g_i3k_ui_mgr:OpenUI(eUIID_SpiritTips1)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpiritTips1, data)
end

function wnd_sui_cong:openCommentUI(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_common.evaluation.openLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15405, i3k_db_common.evaluation.openLvl))
	end
	i3k_sbean.socialmsg_pageinfoReq(1, self._id, 1, 1, i3k_db_common.evaluation.showItemCount)
end

--更新武库红点
function wnd_sui_cong:updateWuKuRedPoint()
	self.wuRedPoint:setVisible(g_i3k_game_context:getWuKuRedPointVisible() or g_i3k_game_context:havePetBooksInBag())
end

--更新心法红点
function wnd_sui_cong:updateXinFaRedPoint()
	self.xfRedPoint:setVisible(g_i3k_game_context:getXinFaRedPointVisible(self._id))
end

--进入碎片回收界面
function wnd_sui_cong:onRecycle(sender, id)
	local upstar_cfg = g_i3k_db.i3k_db_get_pet_upstar_cfg(id,1)
	local itemId = upstar_cfg.itemid
	i3k_sbean.openDebrisRecycle(itemId, g_DEBRIS_PET)
end

--宠物改名
function wnd_sui_cong:onModifyNameClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ModifyPetName)
	g_i3k_ui_mgr:RefreshUI(eUIID_ModifyPetName, self._id)
end

function wnd_sui_cong:updatePetName(id, petName)
	local allPetLayer = self._pet_scroll:getAllChildren()
	for _, v in ipairs(allPetLayer) do
		if v.vars.id == id then
			local cfg_data = g_i3k_db.i3k_db_get_pet_cfg(id)
			local name = petName ~= "" and petName or cfg_data.name
			v.vars.name:setText(name)
		end
	end
end
function  wnd_sui_cong:onHide()
	if self._changePowerCo then
		g_i3k_coroutine_mgr:StopCoroutine(self._changePowerCo)
	 	self._changePowerCo = nil
	 end
end
