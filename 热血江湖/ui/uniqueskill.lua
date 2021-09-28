-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_unique_Skill = i3k_class("wnd_unique_Skill", ui.wnd_base)

LAYER_JNJMT = "ui/widgets/jnjmt"
LAYER_JNJMT1 = "ui/widgets/jnjmt1"

--技能栏 后改名为武功
local tmp_num = 0 
local pos = {}
local cur_width = 0
local cur_height = 0

local tag_area = {
	[1] = "自身",
	[2] = "单体",
	[3] = "自身圆形",
	[4] = "前方圆形",
	[5] = "前方扇形",
	[6] = "前方矩形",
	[7] = "随机圆形区域",
}

local MAX_STATE = 4
local state = {
	[1] = "白露",
	[2] = "绿竹",
	[3] = "蓝田",
	[4] = "紫庭",
	[5] = "橙圃",
}

local skill_grade = {151,152,153,154,155}

function wnd_unique_Skill:ctor()
	self._skillID = {}	
	self._onSelect = nil	
	self._startX = 0
	self._startY = 0
	self.old_index = 0--标记打开详情的技能

end

function wnd_unique_Skill:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	self.skill_menu = widgets.skill_menu
	widgets.jueji_btn:stateToPressed()
	
	
	widgets.skill_btn:stateToNormal()
	self.xinfa_btn = widgets.xinfa_btn
	self.xinfa_btn:stateToNormal()
	self.xinfa_btn:onClick(self, self.onXinfaBtn)
	widgets.skill_btn:onClick(self, self.onSkillBtn)
	widgets.help_btn:onClick(self,self.onHelp)
	
	self.red_point_2 = widgets.red_point_2 
	self.red_point_1 = widgets.red_point_1
	self.red_point_3 = widgets.red_point_3
	self.skill_root = widgets.skill_root
	
	self.skill1 = widgets.skill1
	self.skill1Small = widgets.skill1Small
	
	self.move_btn = widgets.move_btn
	
	
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end


function wnd_unique_Skill:refresh()

	self.scroll:setBounceEnabled(false)
	
	
	local role_unique_skill,use_uniqueSkill = g_i3k_game_context:GetRoleUniqueSkills() ---得到的绝技 
	local role_id = g_i3k_game_context:GetRoleType()
	
	self:updateLeftSkillUI(use_uniqueSkill)

	self.scroll:removeAllChildren()
	local temp_skill = self:sortSkill(role_unique_skill) 
	
	for i, e in pairs(temp_skill) do
	
		--local skillId = i3k_db_exskills[i].skills[role_id]
		self._skillID[i] = e.id--skillId----e
		local _layer = require(LAYER_JNJMT)()---需要排序 根据优先级顺序显示绝技
		
		self:SetSimplelLayer(_layer, e.id, i)
		_layer.id = e.id--e
		self.scroll:addItem(_layer)
	end

	self:showRedPoint()
	self:xinfaBtnFormat()
end

function wnd_unique_Skill:sortSkill( role_unique_skill)
	local base_skill = {} 
	for i, e in pairs(role_unique_skill) do
		table.insert(base_skill, e)
	end
	table.sort(base_skill,function (a,b)
		return a.sortId < b.sortId
	end)
	return base_skill
end
---升级/界时刷新
function wnd_unique_Skill:onUpdateLayer()
	if not self._onSelect then
		return
	end

	local _layer = self.scroll:getChildAtIndex(self._onSelect)
	local skillID = self._skillID[self._onSelect]
	if _layer.vars.state_btn then
		self:SetDetailLayer(_layer, skillID, self._onSelect)
	else
		self:SetSimplelLayer(_layer, skillID, self._onSelect)
	end
	self:showRedPoint()
end

function wnd_unique_Skill:showRedPoint()
	self.red_point_2:setVisible(g_i3k_game_context:isShowSkillRedPoint())
	self.red_point_1:setVisible(g_i3k_game_context:isShowXinfaRedPoint())
	---绝技红点
	self.red_point_3:setVisible(g_i3k_game_context:isShowUniqueSkillRedPoint())
end

--心法按钮的显隐
function wnd_unique_Skill:xinfaBtnFormat()
	local hideLvl = i3k_db_common.functionHide.xinfaHideLvl
	if g_i3k_game_context:GetLevel() < hideLvl then 
		self.xinfa_btn:hide()
	else
		self.xinfa_btn:show()
	end 	
end

--左侧技能栏
function wnd_unique_Skill:updateLeftSkillUI(skills)
	if skills ~= 0 then
		self:setSkillPos()
	end
end


function wnd_unique_Skill:setSkillPos()
	
	
	local role_unique_skill, useSkill = g_i3k_game_context:GetRoleUniqueSkills()
	--local skillId = useSkill[1]
	self._iscurrent = false
	for k,e in ipairs (i3k_db_exskills) do ---绝技
		for _,v in pairs (e.skills) do ---绝技
		
			if v == useSkill then
				self._iscurrent = true
				local _skill_data = i3k_db_skills[useSkill]
				self.skill1Small:show()
				self.skill1Small:setImage(g_i3k_db.i3k_db_get_icon_path(_skill_data.icon))
				local state = role_unique_skill[v].state
				self.skill1:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[state + 1]))
				break
			end
		end
		if self._iscurrent then
			break
		end
	end
end

function wnd_unique_Skill:onOpenDetail(sender, tag)
	local index = self.old_index
	if index ~= 0 then
		local _layer = require(LAYER_JNJMT)()
		_layer.id = self._skillID[index]
		self.scroll:replaceItemAtIndex(_layer, index, true)
		self:SetSimplelLayer(_layer, self._skillID[index], index)
	end
	self.old_index = tag
	local skillID = self._skillID[tag]
	local node = require(LAYER_JNJMT1)()
	node.id = skillID
	self.scroll:replaceItemAtIndex(node, tag)
	self:SetDetailLayer(node, skillID, tag)
end

function wnd_unique_Skill:onCLoseDetail(sender, tag)
	self.old_index = 0
	local skillID = self._skillID[tag]
	local node = require(LAYER_JNJMT)()
	node.id = skillID
	self.scroll:replaceItemAtIndex(node, tag)
	self:SetSimplelLayer(node, skillID, tag)
end


--升级弹窗
function wnd_unique_Skill:onUpSkill(sender, tag)
	local skillID = self._skillID[tag]
	self._onSelect = tag
	g_i3k_ui_mgr:OpenUI(eUIID_UpSkillTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_UpSkillTips, skillID, eSkillCmd_UpLvl,true)
end

--境界弹窗
function wnd_unique_Skill:onUpState(sender, tag)
	local skillID = self._skillID[tag]
	self._onSelect = tag
	g_i3k_ui_mgr:OpenUI(eUIID_UpSkillTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_UpSkillTips, skillID, eSkillCmd_Bourn,true)
end

---武功标签
function wnd_unique_Skill:onSkillBtn(sender)
	self:onCloseUI()
	g_i3k_logic:OpenSkillLyUI()
end

---气功标签
function wnd_unique_Skill:onXinfaBtn(sender)
	local openLvl = i3k_db_common.functionOpen.xinfaOpenLvl
	if g_i3k_game_context:GetLevel() < openLvl or g_i3k_game_context:GetTransformLvl() < 2 then 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(712,openLvl)) --"功系统将于%s级并二转后开启
		return
	end 
	self:onCloseUI()
	g_i3k_logic:OpenXinfaUI()
end

----移动绝技 装备
function wnd_unique_Skill:onSkillMove(sender,eventType)
	
	
	local role_unique_skill = g_i3k_game_context:GetRoleUniqueSkills()
	local tag = sender:getTag()
	local skillID = self._skillID[tag]
	local stateLv = role_unique_skill[skillID].state
	self.move_btn:show()
	
	local skill1SmallPos = self.skill1:getPosition()
	local skill1Pos = self.skill1:getPosition()
	
	local _skill_data = i3k_db_skills[skillID]
	local icon = i3k_db_icons[_skill_data.icon]
	self.move_btn:setImage(icon.path,icon.path)
	local touchPos = g_i3k_ui_mgr:GetMousePos()
	local parent = self.move_btn:getParent()
	if parent then
		pos = parent:convertToNodeSpace(cc.p(touchPos.x,touchPos.y))
	end
	if eventType == ccui.TouchEventType.began then
		self.scroll:stateToNoSlip()
		self.move_btn:setPosition(pos)
		self._startX  = touchPos.x
		self._startY = touchPos.y
	elseif eventType == ccui.TouchEventType.moved then
		self.move_btn:setPosition(pos)
	else
		self.scroll:stateToSlip()
		pos1 = parent:convertToNodeSpace(self.skill1:getParent():convertToWorldSpace(skill1Pos))
		
		touchPos = parent:convertToNodeSpace(touchPos)
		local distance1 = math.sqrt((touchPos.x - pos1.x)*(touchPos.x - pos1.x) + (touchPos.y - pos1.y)*(touchPos.y - pos1.y))
		
		if distance1 - 30 <= skill1SmallPos.x/2 then
			self.move_btn:setPosition(skill1Pos.x,skill1Pos.y)
			self.skill1Small:setImage(icon.path)
			self.skill1:setImage(i3k_db_icons[skill_grade[stateLv + 1]].path)
			i3k_sbean.goto_uniqueskill_select( skillID)
			self.move_btn:hide()
		else
			self.move_btn:setPosition(self._startX,self._startY)
			self.move_btn:hide()
		end
	end
end
function wnd_unique_Skill:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(501))
end

function wnd_unique_Skill:SetDetailLayer(_layer, skillID, tag)
	local widget = _layer.vars
	widget.upLv_btn:onClick(self, self.onUpSkill, tag)
	widget.state_btn:onClick(self, self.onUpState, tag)
	widget.globel_btn:onClick(self, self.onCLoseDetail, tag)
	widget.move_skill:setTag(tag)
	widget.is_passive:hide()
	widget.is_equip:hide()
	
	
	widget.move_skill:onTouchEvent(self, self.onSkillMove)
	local _skill_data = i3k_db_skills[skillID]
	local icon = i3k_db_icons[_skill_data.icon]
	local _skill_data1 = i3k_db_skill_datas[skillID]
	local role_unique_skill = g_i3k_game_context:GetRoleUniqueSkills()
	
	local now_lv = role_unique_skill[skillID].lvl
	local state_lv = role_unique_skill[skillID].state
	local state_color = g_i3k_get_color_by_rank(state_lv + 1)
	
	if role_unique_skill[skillID] then
		widget.skill_level:setText(now_lv .. "级")----等级
		widget.skill_state:setText("境界：")
		--widget.skill_state:setTextColor(state_color)
		widget.value:setText(state[state_lv + 1])
		widget.value:setTextColor(state_color)
		widget.skill_mark:setVisible(g_i3k_db.i3k_db_get_skill_info(skillID)~="")
		widget.skill_mark:setText(g_i3k_db.i3k_db_get_skill_info(skillID))
		--widget.skill_mark:setTextColor(state_color)
		widget.skill_lv_icon:setImage(i3k_db_icons[skill_grade[state_lv+1]].path)
		local next_lv = now_lv + 1
		local need_lv = _skill_data1[next_lv]~=nil and _skill_data1[next_lv].studyLvl or _skill_data1[now_lv].studyLvl
		if g_i3k_game_context:GetLevel() >= need_lv and _skill_data1[next_lv] then
			widget.upLv_btn:enableWithChildren()
		else
			widget.upLv_btn:disableWithChildren()--disable()
		end
		if state_lv == MAX_STATE then --境界按钮
			widget.state_btn:disableWithChildren()--disable()
		end
		widget.redPoint1:setVisible(g_i3k_game_context:isUniqueSkillCanUpdate(skillID))
		widget.redPoint2:setVisible(g_i3k_game_context:isUniqueSkillCanUpdateLevel(skillID))--isSkillCanUpdateLevel
		widget.redPoint3:setVisible(g_i3k_game_context:isSkillCanUpdateJingjie(skillID,true))
	end 
	widget.skill_icon:setImage(icon.path)
	widget.skill_name:setText(_skill_data.name)
	--widget.skill_name:setTextColor(state_color)
	--widget.skill_level:setTextColor(state_color)
	widget.skill_desc1:setText(_skill_data.desc)
	--widget.skill_desc1:setTextColor(state_color)
	widget.tag_type:setText("目标类型：")
	widget.tag_type_value:setText(tag_area[_skill_data.scope.type])
	widget.time_label:setText("冷却时间：")
	widget.time:setText(_skill_data1[now_lv].cool/1000 .. "秒")
	widget.effect:setText("武功效果：")
	--widget.effect_label1:setText(_skill_data1[now_lv].desc)---效果描述 改为拼接字符串形式
	
	local spArgs1 = _skill_data1[now_lv].spArgs1
	local spArgs2 = _skill_data1[now_lv].spArgs2
	local spArgs3 = _skill_data1[now_lv].spArgs3
	local spArgs4 = _skill_data1[now_lv].spArgs4
	local spArgs5 = _skill_data1[now_lv].spArgs5
	local commonDesc = _skill_data.common_desc
	local tmp_str = string.format(commonDesc,spArgs1,spArgs2,spArgs3,spArgs4,spArgs5)
	widget.effect_label1:setText(tmp_str)---效果描述now_lv 改为拼接字符串形式
	
	widget.state_add:setText("境界追加：")
	widget.state_value:setText(i3k_db_skills[skillID].stateDesc[state_lv+1])
	
end

function wnd_unique_Skill:SetSimplelLayer(_layer, skillID, tag)
	local widget = _layer.vars
	local hero_lv = g_i3k_game_context:GetLevel()
	local _skill_data = i3k_db_skills[skillID]
	local icon = i3k_db_icons[_skill_data.icon]
	local _skill_data1 = i3k_db_skill_datas[skillID]
	local role_unique_skill = g_i3k_game_context:GetRoleUniqueSkills() 
	
	widget.is_passive:hide()
	widget.upSkill:onClick(self, self.onUpSkill, tag)
	widget.skill_move:setTag(tag)
	widget.skill_move:setImage(icon.path,icon.path)
	widget.globel_btn:onClick(self, self.onOpenDetail, tag)
	widget.skill_icon:setImage(icon.path)
	widget.skill_name:setText(_skill_data.name)
	widget.skill_desc:setText(_skill_data.desc)
	widget.skill_lv_icon:setImage(i3k_db_icons[skill_grade[1]].path)
	widget.skill_mark:setVisible(g_i3k_db.i3k_db_get_skill_info(skillID)~="")
	widget.skill_mark:setText(g_i3k_db.i3k_db_get_skill_info(skillID))
	widget.is_equip:hide()
	if role_unique_skill[skillID] and role_unique_skill[skillID].lvl ~= 0 then
		local state_lv = role_unique_skill[skillID].state
		local now_lv = role_unique_skill[skillID].lvl--基础等级
		local state_color = g_i3k_get_color_by_rank(state_lv + 1)
		

		widget.btn_label:setText("升 级")
		--widget.skill_desc:setTextColor(state_color)
		--widget.skill_name:setTextColor(state_color)
		widget.skill_lv:setText(now_lv.."级")---等级"Lv"..
		--widget.skill_lv:setTextColor(state_color)
		widget.skill_state:setText("境界：")
		--widget.skill_state:setTextColor(state_color)
		widget.value:setText(state[state_lv + 1])
		widget.value:setTextColor(state_color)
		--widget.skill_mark:setTextColor(state_color)
		widget.skill_lv_icon:setImage(i3k_db_icons[skill_grade[state_lv+1]].path)
		local next_lv = now_lv + 1
		local need_lv = _skill_data1[next_lv]~=nil and _skill_data1[next_lv].studyLvl or _skill_data1[now_lv].studyLvl
		if hero_lv >= need_lv and _skill_data1[next_lv] then
			widget.upSkill:enableWithChildren()
		else
			widget.upSkill:disableWithChildren()
		end
		widget.redPoint1:setVisible(g_i3k_game_context:isUniqueSkillCanUpdate(skillID))
		widget.redPoint2:setVisible(g_i3k_game_context:isUniqueSkillCanUpdateLevel(skillID))-- isSkillCanUpdateLevel
		
		widget.skill_move:onTouchEvent(self, self.onSkillMove)
	
	end
end

function wnd_unique_Skill:updateSkillPoint()
	local all_child = self.scroll:getAllChildren()
	local role_unique_skill = g_i3k_game_context:GetRoleUniqueSkills() 

	for i, e in pairs(all_child) do
		local skillID = e.id
		if e.vars.state_btn then
			e.vars.redPoint1:setVisible(g_i3k_game_context:isUniqueSkillCanUpdate(skillID))       --左侧技能图标的
			e.vars.redPoint2:setVisible(g_i3k_game_context:isUniqueSkillCanUpdateLevel(skillID))  --右侧按钮的
			e.vars.redPoint3:setVisible(g_i3k_game_context:isSkillCanUpdateJingjie(skillID,true))--右侧境界上的
		else
			local _skill_data1 = i3k_db_skill_datas[skillID]
			if role_unique_skill[skillID] and role_unique_skill[skillID].lvl ~= 0 then
				e.vars.redPoint1:setVisible(g_i3k_game_context:isUniqueSkillCanUpdate(skillID))
				e.vars.redPoint2:setVisible(g_i3k_game_context:isUniqueSkillCanUpdateLevel(skillID))--isSkillCanUpdateLevel
			
			end
		end
	end
end

function wnd_unique_Skill:onCloseUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSkillNotice")
	g_i3k_ui_mgr:CloseUI(eUIID_UniqueSkill)
		
end

function wnd_create(layout)
	local wnd = wnd_unique_Skill.new()
	wnd:create(layout)
	return wnd
end
