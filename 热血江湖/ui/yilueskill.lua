------------------------------------------------------
module(...,package.seeall)

local require = require

require("ui/ui_funcs")

local ui = require('ui/base')
------------------------------------------------------
wnd_yilueSkill = i3k_class("wnd_yilueSkill",ui.wnd_base)

function wnd_yilueSkill:configure()
	self.ui = self._layout.vars
	self.ui.close:onClick(self, self.onCloseUI)

	self.yilueTopList = {}
	self.skillList = {}
	self.wearSkillNum = {}  --各个技能装备数量统计列表

	self._radius = 0
	
	self.ui.helpBtn:onClick(
		self, 
		function()
            local desc = ""
            desc = i3k_get_string(18251)
            g_i3k_ui_mgr:ShowHelp(desc)
        end
	)
	self.ui.bottomDesc:setText(i3k_get_string(18271))
end

function wnd_yilueSkill:refresh()
	self:refreshTopSkillList()
	self:refreshFourList()
	local pos = self.yilueTopList[1].vars.skill_bg:getPosition()
	self._radius = pos.x
end

function wnd_yilueSkill:refreshTopSkillList()
	local equipData = g_i3k_game_context:getEquipDiagrams() --已装备八卦
	local yilueData = g_i3k_game_context:getPartStrength()	--各部位八卦信息
	self.ui.topScroll:removeAllChildren()
	self.yilueTopList = {}
	self.wearSkillNum = {}
	for i,v in ipairs(i3k_db_bagua_part) do
		local item = require("ui/widgets/baguaysjnt")()
		item.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_bagua_info(i).yiueIcon))
		item.zjLevel = 0

		--对每个位置做一个装备技能统计
		local skillId = yilueData[i].changeInfo.equipSkill
		if skillId ~= 0 then
			self.wearSkillNum[skillId] = self.wearSkillNum[skillId] and self.wearSkillNum[skillId] + 1 or 1
		end
		if equipData[i] then
			item.zjLevel = g_i3k_game_context:GetYilueZhuanjingLv(yilueData[i].changeInfo.propPoints)
			local yilueType = g_i3k_game_context:GetYilueType(yilueData[i].changeInfo.propPoints)
			item.vars.skill_icon:hide()
			if skillId ~= 0 then
				item.vars.skill_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_yilue_skill[skillId].iconID))
				item.vars.skill_icon:show()
				item.vars.unWearBtn:onClick(self, self.onUnWearBtnClick, i)
				item.vars.skill_bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_cfg.yilueType[yilueType].skillKuangID))
			end
			item.vars.lock:hide()
			item.vars.skill_bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_cfg.yilueType[yilueType].skillKuangID))
			item.vars.zhuanjing:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_cfg.yilueType[yilueType].lvSmallID))
			item.vars.zhuanjing:show()
			item.vars.kong:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_cfg.yilueType[yilueType].kongID))
			item.isSuo = false
		else
			item.vars.icon:disable()
			item.vars.lock:show()
			item.vars.skill_icon:hide()
			item.isSuo = true
			item.vars.zhuanjing:hide()
		end
		
		item.vars.count:setText(item.zjLevel)
		item.type = g_i3k_game_context:GetYilueType(yilueData[i].changeInfo.propPoints)
		table.insert(self.yilueTopList, item)
		self.ui.topScroll:addItem(item)
	end
end

function wnd_yilueSkill:refreshFourList()
	local sort_cfg = {}
	for k,v in pairs(i3k_db_bagua_yilue_skill) do
		v.id = k
		table.insert(sort_cfg, v)
	end
	table.sort(sort_cfg, function(a,b) return a.id < b.id end)

	local skillData = g_i3k_game_context:GetBaguaYilue().changeSkills
	for i,v in ipairs(sort_cfg) do
		local item = #self.skillList > 0 and  self.skillList[i] or require("ui/widgets/baguaysjnt2")()
		item.vars.name:setText(v.skillName)
		item.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconID))
		item.vars.icon_bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_cfg.yilueType[v.skillType].skillKuangID))
		item.vars.zj_bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_cfg.yilueType[v.skillType].lvSmallID))
		item.vars.desc:setText(v.desc)
		local lv = skillData[v.id]
		v.level = 0
		local skill = {}
		if lv then
			--已激活
			v.level = lv
			skill = i3k_db_bagua_yilue_skill[v.id].skillJie[lv]
			item.vars.lvDesc:setText(skill.jieText)
			local count1 = 0
			item.isMax = false
			if self.wearSkillNum[v.id] then
				count1 = self.wearSkillNum[v.id]
			end
			item.vars.wearNum:setText(i3k_get_string(18240,count1,skill.maxCount))
			if count1 >= skill.maxCount then
				item.vars.wearNum:setTextColor(g_COLOR_VALUE_RED)
				item.isMax = true
			else
				item.vars.wearNum:setTextColor(g_COLOR_VALUE_GREEN)
			end
			if lv == #i3k_db_bagua_yilue_skill[v.id].skillJie then --满级
				item.vars.cfgBtn:hide()
				item.vars.maxIcon:show()
			else
				item.vars.btnName:setText("升阶")
				item.vars.cfgBtn:onClick(self, self.onUplvClick, v)
				item.vars.cfgBtn:show()
				item.vars.maxIcon:hide()
				item.vars.wearNum:show()
			end
			v.isMax = item.isMax
			item.vars.skill_move:onTouchEvent(self, self.onSkillMove, v)
		else
			--未激活
			skill = i3k_db_bagua_yilue_skill[v.id].skillJie[1]
			item.vars.lvDesc:setText("未启动")
			item.vars.btnName:setText("启动")
			item.vars.cfgBtn:onClick(self, self.onJihuoClick, v.id)
			item.vars.wearNum:setText(i3k_get_string(18270, skill.maxCount))
			item.vars.wearNum:setTextColor(g_COLOR_VALUE_GREEN)
			item.vars.maxIcon:hide()
		end
		
		item.vars.level:setText(skill.zhuanJingLv)
		item.vars.desc:setText(skill.skillDesc)
		if #self.skillList < #sort_cfg then
			self.ui.skillScroll:addItem(item)
			table.insert(self.skillList, item) 
		end
	end
end

function wnd_yilueSkill:onSkillMove(sender, eventType, v)
	if v.isMax then
		return
	end
	local icon = i3k_db_bagua_yilue_skill[v.id].iconID
	self.ui.move_btn:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
	local parent = self.ui.move_btn:getParent()

	local touchPos = g_i3k_ui_mgr:GetMousePos()
	local pos = {}
	if parent then
		pos = parent:convertToNodeSpace(cc.p(touchPos.x,touchPos.y))
	end

	if eventType == ccui.TouchEventType.began then
		self.ui.skillScroll:stateToNoSlip()
		self.ui.move_btn:setPosition(pos)
	elseif eventType == ccui.TouchEventType.moved then
		self.ui.move_btn:show()
		self.ui.move_btn:setPosition(pos)
	else
		self:onSelectSkill(parent, icon, v, touchPos)
	end
end

--拖拽释放技能后
function wnd_yilueSkill:onSelectSkill(parent, icon ,info,touchPos)
	touchPos = parent:convertToNodeSpace(touchPos)
	self.ui.move_btn:hide()
	self.ui.skillScroll:stateToSlip()
	for i = 1, #self.yilueTopList do
		local skill = self.yilueTopList[i]
		local pos = skill.vars.skill_bg:getParent():convertToWorldSpace(skill.vars.skill_bg:getPosition())
		pos = parent:convertToNodeSpace(pos)
		local distance = math.sqrt((touchPos.x - pos.x)*(touchPos.x - pos.x) + (touchPos.y - pos.y)*(touchPos.y - pos.y))
		if distance <= self._radius / 2 then
			if skill.isSuo then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18241))
				return false
			end
			if skill.type ~= i3k_db_bagua_yilue_skill[info.id].skillType then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18242))
				return false
			end
			local neadLv = i3k_db_bagua_yilue_skill[info.id].skillJie[info.level].zhuanJingLv
			if skill.zjLevel < neadLv then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18243))
				return false
			end
			if parent.isMax then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18244))
				return false
			end
			i3k_sbean.wearYilueSkill(i, info.id)
		end
	end
end

function wnd_yilueSkill:onUplvClick(sender, info)
	g_i3k_ui_mgr:OpenUI(eUIID_YilueSkillShengjie)
	g_i3k_ui_mgr:RefreshUI(eUIID_YilueSkillShengjie, info.id, info.level)
end

function wnd_yilueSkill:onJihuoClick(sender, id)
	g_i3k_ui_mgr:OpenUI(eUIID_YilueSkillJihuo)
    g_i3k_ui_mgr:RefreshUI(eUIID_YilueSkillJihuo, id, 1)
end

--激活成功
function wnd_yilueSkill:JihuoAndUpSkill(id)
	self:refreshFourList()
	local skillData = g_i3k_game_context:GetBaguaYilue().changeSkills
	if skillData[id] == 1 then
		g_i3k_logic:ShowSuccessAnimation(g_ACTIVE_SUCCESS_ANIMATION)
	else
		g_i3k_logic:ShowSuccessAnimation(g_UPLEVEL_SUCCESS_ANIMATION)
	end
end

function wnd_yilueSkill:ShowSkillJihuoMsg(id)
	local skillData = g_i3k_game_context:GetBaguaYilue().changeSkills
	if skillData[id] then
		g_i3k_ui_mgr:PopupTipMessage("技能升阶失败")
	else
		g_i3k_ui_mgr:PopupTipMessage("技能启动失败")
	end
end

function wnd_yilueSkill:onUnWearBtnClick(sender, part)
	i3k_sbean.unequipYilueSkill(part)
end

---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_yilueSkill.new()
	wnd:create(layout,...)
	return wnd
end
