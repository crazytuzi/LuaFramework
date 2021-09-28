-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_skill_ly = i3k_class("wnd_skill_ly", ui.wnd_base)


local tmp_num = 0
local pos = {}
local cur_width = 0
local cur_height = 0

local LAYER_JNJMT = "ui/widgets/jnjm2t"
local LAYER_JNDESC = "ui/widgets/jnjm2t2"
--技能攻击范围
local tag_area = {
	[1] = i3k_get_string(935),
	[2] = i3k_get_string(936),
	[3] = i3k_get_string(937),
	[4] = i3k_get_string(938),
	[5] = i3k_get_string(939),
	[6] = i3k_get_string(940),
	[7] = i3k_get_string(941),
}

--最大境界
local MAX_STATE = 4
--普通技能按钮数量
local EQUIP_SKILL_NUM = 4
--技能境界
local STATE = {
	[1] = i3k_get_string(942),
	[2] = i3k_get_string(943),
	[3] = i3k_get_string(944),
	[4] = i3k_get_string(945),
	[5] = i3k_get_string(946),
}

--技能境界图标
local skill_grade = {151,152,153,154,155}

--被动，光环图标
local PASSIVE_ICON = {2554, 4189}

function wnd_skill_ly:ctor()
	self._startX = 0
	self._startY = 0
	self.old_index = 0--标记打开详情的技能
	self._radius = 0
	self._currSKillID = 0
	self._isUniqueSkillOpen = false--绝技列表是否打开
	self._isUniqueId = false
	self._lastSelect = nil
	self._lastSelectList = nil


	self.skill = {}--左侧技能栏控件
	self.skillImg = {}
	self.skillLock = {}
	self.skillRed = {}
	self.skillBtn = {}
	self.addDesc = {}
end

function wnd_skill_ly:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.skillScroll
	self.scroll:setBounceEnabled(false)
	self.skill_menu = widgets.skill_menu
	self.move_btn = widgets.move_btn
	self.unique_red = widgets.unique_red
	--武功(技能)按钮
	self.skill_btn = widgets.skill_btn
	self.skill_btn:onClick(self, self.onSkillBtn)
	--气功(心法)按钮
	self.qigong_btn = widgets.qigong_btn
	self.qigong_btn:onClick(self, self.onQiGongBtn)
	--经脉按钮
	self.meridian_btn = widgets.meridian_btn
	self.meridian_btn:onClick(self,self.onMeridianBtn)
	--武诀按钮
	self.wujue_btn = widgets.wujue_btn
	self.wujue_btn:onClick(self, self.onWujueBtn)
	--帮助按钮
	self.help_btn = widgets.help_btn
	self.help_btn:onClick(self,self.onHelp)
	--绝技按钮
	self.jueji_btn = widgets.unique_btn
	self.jueji_btn:onClick(self, self.onUniqueSkillDetail)
	--武功列表
	self.skill_list_btn = widgets.skill_list_btn
	self.skill_list_btn:onClick(self, self.onOpenSkillList)
	--绝技列表
	self.unique_skill_btn = widgets.unique_skill_btn
	self.unique_skill_btn:onClick(self, self.onJuejiBtn)
	--预设按钮
	self.skillPre_btn = widgets.skillPre_btn
	self.skillPreBtn_txt = widgets.skillPreBtn_txt
	self.skillPre_btn:onClick(self,self.onSkillPreBtn)
	--武功，气功，经脉，武绝红点

	self.red_point_1 = widgets.red_point_1
	self.red_point_2 = widgets.red_point_2
	self.red_point_3 = widgets.red_point_3
	self.red_point_4 = widgets.red_point_4
	--境界追加描述
	self.addDesc = {widgets.state_desc, widgets.qigong_desc, widgets.jade_desc}
	--五转按钮
	self.fiveTrans = widgets.fiveTrans
	self.fiveTrans:onClick(self, self.onFiveTrans)
	--境界按钮
	self.skill_state_btn = widgets.skill_state_btn
	self.skill_state_btn:onClick(self, self.onUpState)
	--解锁按钮
	self.unlock_btn = widgets.unlock_btn
	self.unlock_btn:onClick(self, self.onUnLock)
	--升级按钮
	self.skill_lvl_btn = widgets.skill_lvl_btn
	self.skill_lvl_btn:onClick(self, self.onUpSkill)
	--全部升级按钮
	self.skill_all_lvl_btn = widgets.skill_all_lvl_btn
	self.skill_all_lvl_btn:onClick(self,self.onUpAllSkill)
	--转职预览
	self.trPreviewBtn = widgets.trPreviewBtn
	self.trPreviewBtn:onClick(self,self.openSkillPriview)
	--关闭按钮
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self,self.onCloseUI)
	self:initSkillsBtn()
end

function wnd_skill_ly:refresh(isOpenUnique)
	local roleLevel = g_i3k_game_context:GetLevel()
	if self._lastSelect then
		self._lastSelect:stateToNormal()
		self._lastSelect = nil
	end
	self._isUniqueSkillOpen = false
	self._isUniqueId = false
	self._lastSelectList = nil
	

	local sspos = self.skill[1]:getPosition()
	self._radius = sspos.x

	local role_id = g_i3k_game_context:GetRoleType()
	local skills = i3k_db_generals[role_id].skills
	for i, e in ipairs(skills) do
		self.skillRed[i]:setVisible(g_i3k_game_context:isSkillCanUpdate(e))
		self.skillBtn[i]:setTag(e)
		self.skillLock[i]:setVisible(true)
		self.skillBtn[i]:onClick(self, self.onShowDetailSkill, false)
	end
	self.unique_skill_red:setVisible(false)
	self.unique_lock:setVisible(true)
	self:setSkillPos()
	self:setUniqueSkillPos()
	if isOpenUnique then
		self:openUniqueSkillList()
	else
		self:openSkillList()
	end

	self:showRedPoint()
	self:skillBtnFormat()
	self:qigongBtnFormat(roleLevel)
	self:meridianBtnFormat(roleLevel)
	self:wujueBtnFormat(roleLevel)
	self:fiveTransBtnFormat(roleLevel)
	self:skillPerBtnFormat()
	self:updateModel(roleLevel)
end
function wnd_skill_ly:initSkillsBtn()
	local widgets = self._layout.vars
	--普通技能按钮初始化
	for i=1,EQUIP_SKILL_NUM do
		local BGWidget = string.format("skillBG%s",i)
		local imgWidget = string.format("skill_img%s",i)
		local lockWidget = string.format("skill_lock%s",i)
		local redWidget = string.format("skill_red%s",i)
		local btnWidget = string.format("skillBtn%s",i)
		self.skill[i] = widgets[BGWidget]
		self.skillImg[i] = widgets[imgWidget]
		self.skillLock[i] = widgets[lockWidget]
		self.skillRed[i] = widgets[redWidget]
		self.skillBtn[i] = widgets[btnWidget]
	end
	self.unique_skillBG = widgets.unique_skillBG
	self.unique_img = widgets.unique_img
	self.unique_lock = widgets.unique_lock
	self.unique_skill_red = widgets.unique_skill_red
end
function wnd_skill_ly:showRedPoint()
	self.red_point_1:setVisible(g_i3k_game_context:isShowXinfaRedPoint())
	self.red_point_2:setVisible(g_i3k_game_context:isShowSkillRedPoint() or g_i3k_game_context:isShowUniqueSkillRedPoint())
	self.red_point_3:setVisible(g_i3k_game_context:GetIsMeridianRed())
	self.red_point_4:setVisible(g_i3k_game_context:isShowWujueRedPoint())
	self.unique_red:setVisible(g_i3k_game_context:isShowUniqueSkillRedPoint())
end
function wnd_skill_ly:skillBtnFormat()
	self.skill_btn:stateToPressed()
end
function wnd_skill_ly:qigongBtnFormat(roleLevel)
	local qigongShowLevel = g_i3k_db.i3k_db_get_qigong_level_require()
	self.qigong_btn:setVisible(roleLevel >= qigongShowLevel)
	self.qigong_btn:stateToNormal()
end
function wnd_skill_ly:meridianBtnFormat(roleLevel)
	local meridianShowLevel = g_i3k_db.i3k_db_get_meridian_level_require()
	self.meridian_btn:setVisible(roleLevel >= meridianShowLevel)
	self.meridian_btn:stateToNormal()
end
function wnd_skill_ly:wujueBtnFormat(roleLevel)
	local wujueShowLevel = g_i3k_db.i3k_db_get_wujue_level_require()
	self.wujue_btn:setVisible(roleLevel >= wujueShowLevel)
	self.wujue_btn:stateToNormal()
end
function wnd_skill_ly:fiveTransBtnFormat(roleLevel)
	local fiveTransShowLevel = g_i3k_db.i3k_db_get_five_trans_level_requre()
	self.fiveTrans:setVisible(roleLevel >= fiveTransShowLevel)
end
function wnd_skill_ly:skillPerBtnFormat()
	local limit_transLvl = 1
	local now_transLvl= g_i3k_game_context:GetTransformLvl()
	self.skillPre_btn:setVisible(now_transLvl >= limit_transLvl)
end
function wnd_skill_ly:onSkillBtn(sender)
	return
end
function wnd_skill_ly:onQiGongBtn(sender)
	local roleLevel = g_i3k_game_context:GetLevel()
	local openLvl = i3k_db_common.functionOpen.xinfaOpenLvl
	local now_transLvl= g_i3k_game_context:GetTransformLvl()
	local limit_transLvl = 2
	if roleLevel >= openLvl and now_transLvl >= limit_transLvl then
		self:onCloseUI()
		g_i3k_logic:OpenXinfaUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(712,openLvl))
	end
end
function wnd_skill_ly:onMeridianBtn(sender)
	g_i3k_logic:OpenMeridian(eUIID_SkillLy)
end
function wnd_skill_ly:onJuejiBtn(sender)
	local role_unique_skill = g_i3k_game_context:GetRoleUniqueSkills()
	if next(role_unique_skill) ~= nil then
		self:onOpenUniqueSkillList(sender)
	else
		local desc = i3k_get_string(496,i3k_db_climbing_tower_args.openLvl)
		local callfunc = function (isOk)
			local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
			if tips then
				return g_i3k_ui_mgr:PopupTipMessage(tips)
			end
			if isOk then
				---跳转到活动---爬塔标签
				local fun = function(id)
					local callBack = function()
						g_i3k_ui_mgr:CloseUI(eUIID_SkillLy)
					end
					i3k_sbean.sync_fame_tower(id, nil, callBack)
				end
				g_i3k_logic:OpenTowerUI(nil,fun)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callfunc)
	end
end
function wnd_skill_ly:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(306))
end

function wnd_skill_ly:updateModel( )
	g_i3k_game_context:ResetTestFashionData()
	ui_set_hero_model(self._layout.vars.hero3d, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(),g_i3k_game_context:getIsShowArmor())
end

function wnd_skill_ly:addNextSkillTips()
	local prfValue = g_i3k_game_context:GetRoleType()
	local cfg = i3k_db_zhuanzhi[prfValue]
	local tlvl = g_i3k_game_context:GetTransformLvl()
	local nextCfg = cfg[tlvl + 1]
	if nextCfg then
		if tlvl + 1 == 1 then
			nextCfg = nextCfg[0]
		else
			nextCfg = nextCfg[1]
		end
		local node = require(LAYER_JNJMT)()
		node.id = -1
		node.vars.redPoint:hide()
		node.vars.is_equip:hide()
		node.vars.is_passive:hide()
		node.vars.skill_move:onClick(self, self.onNextSkillTip, nextCfg.tipId)
		self.scroll:addItem(node)
	end
end

function wnd_skill_ly:onNextSkillTip(sender, tipId)
	g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(tipId))
end



function wnd_skill_ly:onSkillPreBtn(sender)
    local diyID = g_i3k_game_context:GetCurrentDIYSkillId()
    if diyID == 0 then
    	self:goSkillSetUI()
    else
    	local diySkillData = g_i3k_game_context:getDiySkillAndBorrowSkill()
		if not diySkillData then
			i3k_sbean.getDiySkillSync(nil, nil, g_SKILLPRE_DIY_FRESHTYPE_SET)
		else
			self:goSkillSetUI()
		end
    end
end

function wnd_skill_ly:goSkillSetUI()
	g_i3k_ui_mgr:OpenUI(eUIID_SkillSet)
	g_i3k_ui_mgr:RefreshUI(eUIID_SkillSet)
end

function wnd_skill_ly:updatePreSkill()
	if self._lastSelectList then
		self._lastSelectList:stateToNormal()
	end
	if self._lastSelect then
		self._lastSelect:stateToNormal()
	end

	if self._isUniqueId then
		self:setUniqueSkillPos()
		if self.jueji_btn:getTag() > 0 then
			self._lastSelectList = nil
			self._lastSelect = nil
			self:onShowDetailSkill(self.jueji_btn, true)
		else
			self._lastSelectList:stateToPressed()
		end
	else
		self._lastSelectList = nil
		self._lastSelect = nil
		self:setSkillPos()
		self:onShowDetailSkill(self.skillBtn[1], false)
	end
	self:ShowEquip()
end

function wnd_skill_ly:updateTransferSkill(base_skill, role_all_skill, useSkill)
	local temp_skill = {}
	for k,v in pairs(role_all_skill) do
		if not base_skill[k] then
			table.insert(temp_skill, v)
		end
	end
	table.sort(temp_skill,function (a,b)
		return a.id < b.id
	end)
	for i, e in ipairs(temp_skill) do
		local id = e.id
		local _layer = require(LAYER_JNJMT)()
		self:setSkillSimple(_layer, role_all_skill, useSkill, e.id)
		_layer.id = id
		self.scroll:addItem(_layer)
	end
end

function wnd_skill_ly:onOpenSkillList(sender)
	self:changeSkillList()
end
function wnd_skill_ly:onOpenUniqueSkillList(sender)
	self:changeSkillList()
	end
function wnd_skill_ly:changeSkillList()
	if self._lastSelectList then
	end
	if self._isUniqueSkillOpen then
	self:openSkillList()
	else
		self:openUniqueSkillList()
	end
end

function wnd_skill_ly:openSkillList()

	self._isUniqueSkillOpen = false
	self.scroll:removeAllChildren()
	self.skill_list_btn:stateToPressed()
	self.unique_skill_btn:stateToNormal()
	local role_all_skill, useSkill = g_i3k_game_context:GetRoleSkills()
	local role_id = g_i3k_game_context:GetRoleType()
	local skills = i3k_db_generals[role_id].skills
	local base_skill = {}
	self._lastSelectList = nil
	for i, e in ipairs(skills) do
		base_skill[e] = 1
		local _layer = require(LAYER_JNJMT)()
		self:setSkillSimple(_layer, role_all_skill, useSkill, e)
		_layer.id = e
		self.scroll:addItem(_layer)
	end

	self:updateTransferSkill(base_skill, role_all_skill, useSkill)
	self:addNextSkillTips()
	if not self._lastSelect then
		self:onShowDetailSkill(self.skillBtn[1], false)
	end
end


function wnd_skill_ly:openUniqueSkillList()
	self._isUniqueSkillOpen = true
	self.scroll:removeAllChildren()
	self.unique_skill_btn:stateToPressed()
	self.skill_list_btn:stateToNormal()
	local role_all_skill,role_use_skill = g_i3k_game_context:GetRoleUniqueSkills()

	if role_use_skill > 0 then
		self:onShowDetailSkill(self.jueji_btn, true)
	else
		if not self._lastSelect then
			self:onShowDetailSkill(self.skillBtn[1], false)
		end
	end

	local temp_skill = {}
	for i, e in pairs(role_all_skill) do
		table.insert(temp_skill, e)
	end
	table.sort(temp_skill,function (a,b)
		return a.sortId < b.sortId
	end)

	self._lastSelectList = nil
	for i, e in pairs(temp_skill) do
		local _layer = require(LAYER_JNJMT)()---需要排序 根据优先级顺序显示绝技
		self:setUniqueSkillSimple(_layer, role_all_skill, role_use_skill, e.id)
		_layer.id = e.id--e
		self.scroll:addItem(_layer)
	end
end

function wnd_skill_ly:onUpdateLayer(skillId)
	self:showDetailSkill(self._currSKillID, self._isUniqueId)
	self:updateSkillPoint()
	self:showRedPoint()
end

function wnd_skill_ly:onUpdateSkillBorder(skillId)
	if not self._isUniqueId then
		self:setSkillPos()
	else
		self:setUniqueSkillPos()
	end

	for i, e in pairs(self.scroll:getAllChildren()) do
		if e.id == skillId then
			local state_lv = 0
			if not self._isUniqueSkillOpen then
				local role_all_skill = g_i3k_game_context:GetRoleSkills()
				state_lv = role_all_skill[skillId].state
			else
				local role_unique_skill = g_i3k_game_context:GetRoleUniqueSkills()
				state_lv = role_unique_skill[skillId].state
			end
			e.vars.borderIcon:setImage(i3k_db_icons[skill_grade[state_lv + 1]].path)
			break
		end
	end
end

function wnd_skill_ly:ChangeSkillClickFuc()
	if self:CanMoveSkill() then
		for i,e in ipairs(self.scroll:getAllChildren()) do
			if e.id > 0 then
				e.vars.skill_move:onTouchEvent(self, self.onSkillMove, e.id)
			end
		end
	end
end

--add by jxw 当人物等级小于20级或者没有全部技能解锁（或当前界面全部解锁）时，不可拖拽
function wnd_skill_ly:CanMoveSkill( )
	local hero_lv = g_i3k_game_context:GetLevel()
	local role_all_skill = g_i3k_game_context:GetRoleSkills()
	local role_id = g_i3k_game_context:GetRoleType()
	local skills = i3k_db_generals[role_id].skills
	local count = 0
	for k, v in ipairs(skills) do
		if role_all_skill[v] then
				count = count + 1
		end
	end
	return hero_lv >= 20 and count == #skills
end


function wnd_skill_ly:setSkillPos()
	local role_all_skill, useSkill = g_i3k_game_context:GetRoleSkills()
	local role_all_unique_skill, useUniqueSkill = g_i3k_game_context:GetRoleUniqueSkills()
	for k,v in ipairs(useSkill) do
		if i3k_db_skills[v] then
			local _skill_data = i3k_db_skills[v]
			self.skillImg[k]:setImage(g_i3k_db.i3k_db_get_icon_path(_skill_data.icon))
			local state = role_all_skill[v].state
			self.skill[k]:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[state + 1]))
			self.skillRed[k]:setVisible(g_i3k_game_context:isSkillCanUpdate(v))
			self.skillLock[k]:hide()
			self.skillBtn[k]:setTag(v)
		end
	end
end

function wnd_skill_ly:onUniqueSkillDetail(sender)
	local unq_skillId = sender:getTag() or -1
	if unq_skillId > 0 then
		self:onShowDetailSkill(sender, true)
	else
		self:onJuejiBtn()
	end
end

function wnd_skill_ly:setUniqueSkillPos()
	local role_unique_skill, useSkill = g_i3k_game_context:GetRoleUniqueSkills()
	self.jueji_btn:setTag(useSkill)
	if useSkill < 0 then
		return
	end

	local iscurrent = false
	for k,e in ipairs (i3k_db_exskills) do ---绝技
		for _,v in pairs (e.skills) do ---绝技
			if v == useSkill then
				iscurrent = true
				local _skill_data = i3k_db_skills[useSkill]
				self.unique_img:setImage(g_i3k_db.i3k_db_get_icon_path(_skill_data.icon))
				local state = role_unique_skill[v].state
				self.unique_skillBG:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[state + 1]))
				self.unique_lock:setVisible(false)
				self.unique_skill_red:setVisible(g_i3k_game_context:isSkillCanUpdate(v,true))
				break
			end
		end
		if iscurrent then
			break
		end
	end
end

function wnd_skill_ly:onUnLock(sender)
	local skillID = self._currSKillID
	g_i3k_game_context:CheakRoleSkillsUnlockAndUsed(skillID)

end
--升级弹窗
function wnd_skill_ly:onUpSkill(sender)
	local skillID = self._currSKillID
	g_i3k_ui_mgr:OpenUI(eUIID_UpSkillTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_UpSkillTips, skillID, eSkillCmd_UpLvl, self._isUniqueId)
end
--境界
function wnd_skill_ly:onUpState(sender)
	local skillID = self._currSKillID
	g_i3k_ui_mgr:OpenUI(eUIID_UpSkillTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_UpSkillTips, skillID, eSkillCmd_Bourn, self._isUniqueId)
end






function wnd_skill_ly:selectUniqueSkill(parent, icon, stateLv, skillID, touchPos)
	local skill1Pos = self.unique_img:getPosition()
	local pos = parent:convertToNodeSpace(self.unique_img:getParent():convertToWorldSpace(skill1Pos))
	touchPos = parent:convertToNodeSpace(touchPos)

	local distance = math.sqrt((touchPos.x - pos.x)*(touchPos.x - pos.x) + (touchPos.y - pos.y)*(touchPos.y - pos.y))

	if distance <= self._radius then
		self.move_btn:setPosition(pos.x, pos.y)
		self.unique_img:setImage(icon.path)
		self.unique_skillBG:setImage(i3k_db_icons[skill_grade[stateLv + 1]].path)
		i3k_sbean.goto_uniqueskill_select( skillID)
		self.move_btn:hide()
	else
		self.move_btn:setPosition(self._startX,self._startY)
		self.move_btn:hide()
	end
end

----移动绝技 装备
function wnd_skill_ly:onUniqueSkillMove(sender,eventType, skillID)
	local role_unique_skill = g_i3k_game_context:GetRoleUniqueSkills()
	local stateLv = role_unique_skill[skillID].state
	self:skillMove(sender, eventType, skillID, stateLv, true)
end

function wnd_skill_ly:skillMove(sender, eventType, skillID, stateLv, isUniqueSkillOpen)

	local _skill_data = i3k_db_skills[skillID]
	local icon = i3k_db_icons[_skill_data.icon]
	self.move_btn:setImage(icon.path,icon.path)
	local parent = self.move_btn:getParent()

	local touchPos = g_i3k_ui_mgr:GetMousePos()
	if parent then
		pos = parent:convertToNodeSpace(cc.p(touchPos.x,touchPos.y))
	end

	if eventType == ccui.TouchEventType.began then
		if self._lastSelectList then
			self._lastSelectList:stateToNormal()
		end
		if self._lastSelect then
			self._lastSelect:stateToNormal()
			self._lastSelect = nil
		end
		sender:stateToPressed()
		self._lastSelectList = sender
		--self.scroll:stateToNoSlip()
		self.move_btn:setPosition(pos)
		self:showDetailSkill(skillID, isUniqueSkillOpen)
		self._startX  = touchPos.x
		self._startY = touchPos.y
	elseif eventType == ccui.TouchEventType.moved then
		--self.scroll:stateToSlip()
		self.move_btn:show()
		self.move_btn:setPosition(pos)
	else
		--self.scroll:stateToSlip()
		if isUniqueSkillOpen then
			self:selectUniqueSkill(parent, icon, stateLv, skillID, touchPos)
		else
			self:selectSkill(parent, icon, stateLv, skillID, touchPos)
		end
	end
end

function wnd_skill_ly:selectSkill(parent, icon, stateLv, skillID, touchPos)
	touchPos = parent:convertToNodeSpace(touchPos)
	for i = 1 , #self.skillImg do
		local wdg = self.skillImg[i]
		local pos = wdg:getParent():convertToWorldSpace(wdg:getPosition())
		pos = parent:convertToNodeSpace(pos)
		local distance = math.sqrt((touchPos.x - pos.x)*(touchPos.x - pos.x) + (touchPos.y - pos.y)*(touchPos.y - pos.y))
		if distance <= self._radius then
			-- TODO 五转技能互斥
			local roleSkills = g_i3k_game_context:GetRoleSelectSkills()
			local isMutex, s2 = g_i3k_db.i3k_db_check_skill_mutex(skillID, i)
			if isMutex then
				local s1Name = i3k_db_skills[skillID].name
				local s2Name = i3k_db_skills[s2].name

				g_i3k_ui_mgr:PopupTipMessage("["..s1Name.."]与["..s2Name.."]技能互斥，无法装备")
				self.move_btn:hide()
				return false
			end
			i3k_sbean.goto_skill_select(i, skillID)
			self.skillImg[i]:setImage(icon.path)
			self.skill[i]:setImage(i3k_db_icons[skill_grade[stateLv + 1]].path)
			self.move_btn:hide()
			return true
		end
	end
	self.move_btn:hide()
end

function wnd_skill_ly:onSkillMove(sender,eventType, skillID)
	local role_all_skill = g_i3k_game_context:GetRoleSkills()
	local stateLv = role_all_skill[skillID].state
	self:skillMove(sender, eventType, skillID, stateLv, false)
end

function wnd_skill_ly:ShowEquip()
	local fun = nil
	if self._isUniqueSkillOpen then
		local _ , useSkill = g_i3k_game_context:GetRoleUniqueSkills()
		fun = function(item)
			if useSkill == item.id then
				item.vars.is_equip:show()
			end
		end

	else
		local _ ,role_all_skill_use= g_i3k_game_context:GetRoleSkills()
		fun = function(item)
			for _,v in ipairs(role_all_skill_use) do
				if v == item.id then
					item.vars.is_equip:show()
					item.vars.lock:hide()
					break
				end
			end
		end

	end
	for _,item in ipairs(self.scroll:getAllChildren()) do
		if item.id > 0 then
			item.vars.is_equip:hide()
			fun(item)
		end
	end
end

--点击技能时控制与其相关的解锁，升级，一键升级，境界等按钮的显隐
function wnd_skill_ly:SetDetailLayer(skillID, now_lv, state_lv, longYin_lv, skill, addDesc, red_lvl, red_state)
	local widget = self._layout.vars
	self._currSKillID = skillID

	local _skill_data = i3k_db_skills[skillID]
	local _skill_data1 = i3k_db_skill_datas[skillID]
	--nil表示当前选中技能未解锁
	if skill then
		widget.unlock_btn:setVisible(false)
		widget.skill_lvl_btn:setVisible(true)
		widget.skill_all_lvl_btn:setVisible(true)
		widget.skill_state_btn:setVisible(true)
		widget.skill_lvl:setText(i3k_get_string(947,now_lv+longYin_lv))----等级role_all_skill[skillID].lvl
		widget.skill_lvl:setTextColor(g_i3k_get_green_color())

		if longYin_lv > 0 then
			widget.skill_lvl:setTextColor("FF029133");
		end
		widget.skill_transfer:setVisible(g_i3k_db.i3k_db_get_skill_info(skillID)~="")
		widget.skill_transfer:setText(g_i3k_db.i3k_db_get_skill_info(skillID))
		local next_lv = now_lv + 1
		local need_lv = _skill_data1[next_lv]~=nil and _skill_data1[next_lv].studyLvl or _skill_data1[now_lv].studyLvl
		if g_i3k_game_context:GetLevel() >= need_lv and _skill_data1[next_lv] then
			widget.skill_lvl_btn:enableWithChildren()
		else
			widget.skill_lvl_btn:disableWithChildren()--disable()
		end
		if now_lv > #i3k_db_exp then
			widget.skill_lvl_btn_lab:setText(i3k_get_string(948))
		end
		if state_lv == MAX_STATE then --境界按钮
			widget.skill_state_btn:disableWithChildren()--disable()
			widget.skill_state_btn_lab:setText(i3k_get_string(949))
		else
			widget.skill_state_btn:enableWithChildren()
			widget.skill_state_btn_lab:setText(i3k_get_string(950))
		end
		widget.skill_lvl_red:setVisible(red_lvl)
		widget.skill_state_red:setVisible(red_state)
		for i,v in ipairs(self.addDesc) do
			if addDesc[i] then
				v:show()
				v:setText(addDesc[i])
			else
				v:hide()
			end
		end
	else
		local hero_lv = g_i3k_game_context:GetLevel()
		local isUnlock = hero_lv >= _skill_data1[1].studyLvl
		widget.unlock_btn:show()
		widget.unlock_red:setVisible(isUnlock)
		widget.unlock_btn:disable()
		widget.skill_lvl_btn:hide()
		widget.skill_state_btn:hide()
		widget.skill_all_lvl_btn:hide()
		widget.skill_transfer:hide()
		widget.skill_lvl:setText(i3k_get_string(951,_skill_data1[1].studyLvl))
		if isUnlock then
			widget.skill_lvl:setTextColor(g_i3k_get_green_color())
		else
			widget.skill_lvl:setTextColor(g_i3k_get_red_color())
		end
		for i,v in ipairs(self.addDesc) do
			v:hide()
		end

		if isUnlock then
			widget.unlock_btn:enable()
		end
	end
	widget.skill_name:setText(_skill_data.name)
	widget.skill_scope:setText(i3k_get_string(952,tag_area[_skill_data.scope.type]))
	widget.skill_time:setVisible(not g_i3k_game_context:GetIsNotDrag(skillID))
	widget.skill_time:setText(i3k_get_string(953,_skill_data1[now_lv].cool/1000))
	widget.skill_state:setText(i3k_get_string(954, STATE[state_lv+1]))
	widget.skill_state:setTextColor(g_i3k_get_color_by_rank(state_lv + 1))
	widget.verseTxt:setText(_skill_data.verse)
	local newSkillCfg = _skill_data1[now_lv+longYin_lv]
	local commonDesc = _skill_data.common_desc
	local tmp_str = string.format(commonDesc, newSkillCfg.spArgs1, newSkillCfg.spArgs2, newSkillCfg.spArgs3, newSkillCfg.spArgs4, newSkillCfg.spArgs5)
	widget.skillDescScroll:removeAllChildren()
	local nodeDesc = require(LAYER_JNDESC)()
	nodeDesc.vars.text:setText(tmp_str)
	widget.skillDescScroll:addItem(nodeDesc)
	g_i3k_ui_mgr:AddTask(self, {nodeDesc}, function(ui)
		local textUI = nodeDesc.vars.text
		local size = nodeDesc.rootVar:getContentSize()
		local height = textUI:getInnerSize().height
		local width = size.width
		height = size.height > height and size.height or height
		nodeDesc.rootVar:changeSizeInScroll(widget.skillDescScroll, width, height, true)--self._layout.vars.skillDescScroll
	end, 1)
	--widget.skill_desc:setText(tmp_str)---效果描述now_lv longyin显示龙印
end

function wnd_skill_ly:setSkillDetail(skillID)
	local passiveSkill, xinfaIDs = g_i3k_game_context:GetRolePassiveSkills()
	local role_all_skill ,_= g_i3k_game_context:GetRoleSkills()

	local skill = role_all_skill[skillID]
	local now_lv = skill and role_all_skill[skillID].lvl or 1
	local state_lv = skill and role_all_skill[skillID].state or 0

	local addDesc = {}

	if  passiveSkill[skillID]~=nil and xinfaIDs[skillID] then
		table.insert(addDesc, i3k_get_string(955,i3k_db_xinfa[xinfaIDs[skillID]].name))
	elseif g_i3k_game_context:GetIsNotDrag(skillID) then
		local desc = g_i3k_db.i3k_db_get_skill_type(skillID) == eSE_PASSIVE and i3k_get_string(1024) or i3k_get_string(1025)
		table.insert(addDesc, desc)
	end

	table.insert(addDesc, i3k_get_string(956,i3k_db_skills[skillID].stateDesc[state_lv+1]))
	local longYin_lv = 0
	local longYinSkills = g_i3k_game_context:GetLongYinSkills()--龙印加持等级
	for i,v in pairs(longYinSkills) do
		if skillID == i then
			longYin_lv = v
			table.insert(addDesc, i3k_get_string(957,longYin_lv))
			break
		end
	end
	local red_lvl = g_i3k_game_context:isSkillCanUpdateLevel(skillID)
	local red_state = g_i3k_game_context:isSkillCanUpdateJingjie(skillID)
	self:SetDetailLayer(skillID, now_lv, state_lv, longYin_lv, skill, addDesc, red_lvl, red_state)
end

function wnd_skill_ly:setUniqueSkillDetail(skillID)
	local role_unique_skill = g_i3k_game_context:GetRoleUniqueSkills()

	local now_lv = role_unique_skill[skillID].lvl
	local state_lv = role_unique_skill[skillID].state
	local addDesc = {}
	table.insert(addDesc, i3k_get_string(956,i3k_db_skills[skillID].stateDesc[state_lv+1]))

	local red_lvl = g_i3k_game_context:isUniqueSkillCanUpdateLevel(skillID)
	local red_state = g_i3k_game_context:isSkillCanUpdateJingjie(skillID, true)
	self:SetDetailLayer(skillID, now_lv, state_lv, 0, role_unique_skill[skillID], addDesc, red_lvl, red_state)
end

function wnd_skill_ly:onShowDetailSkill(sender, isUnique)

	if self._lastSelect == sender then
		return
	end
	--if self._lastSelectList then
	--	self._lastSelectList:stateToNormal()
	--	self._lastSelectList = nil
	--end
	if self._lastSelect then
		self._lastSelect:stateToNormal()
	end
	sender:stateToPressed()
	self._lastSelect = sender
	self:showDetailSkill(sender:getTag(), isUnique)
end

function wnd_skill_ly:onShowDetailSkillList(sender, isUnique)
	if self._lastSelectList == sender then
		return
	end
	if self._lastSelect then
		self._lastSelect:stateToNormal()
		self._lastSelect = nil
	end
	if self._lastSelectList then
		self._lastSelectList:stateToNormal()
	end
	sender:stateToPressed()
	self._lastSelectList = sender
	self:showDetailSkill(sender:getTag(), isUnique)
end

function wnd_skill_ly:showDetailSkill(skillID, isUnique)
	self._isUniqueId = isUnique
	if self._isUniqueId then
		self:setUniqueSkillDetail(skillID)
	else
		self:setSkillDetail(skillID)
	end
end

function wnd_skill_ly:setSkillSimple(_layer, all_skill, skill_use, skillID)
	local state_lv = all_skill[skillID] and all_skill[skillID].state or 0
	local showRed = g_i3k_game_context:isSkillCanUpdate(skillID)
	local haveSkill = all_skill[skillID] and all_skill[skillID].lvl ~= 0

	local passiveSkill = g_i3k_game_context:GetRolePassiveSkills()
	local is_passive = passiveSkill[skillID] ~= nil or g_i3k_game_context:GetIsNotDrag(skillID) --被动图标

	local is_equip = false
	for i,v in ipairs(skill_use) do
		if v == skillID then
			is_equip = true
			break
		end
	end
	self:SetSimplelLayer(_layer, skillID, state_lv, showRed, haveSkill, is_passive, is_equip)
end

function wnd_skill_ly:setUniqueSkillSimple(_layer, unique_skill, useSkill, skillID)
	local state_lv = unique_skill[skillID].state
	local showRed = g_i3k_game_context:isUniqueSkillCanUpdate(skillID)
	local is_equip = skillID == useSkill

	self:SetSimplelLayer(_layer, skillID, state_lv, showRed, true, false, is_equip)
end

function wnd_skill_ly:SetSimplelLayer(_layer, skillID, state_lv, showRed, haveSkill, is_passive, is_equip)
	local widget = _layer.vars

	local _skill_data = i3k_db_skills[skillID]
	local icon = i3k_db_icons[_skill_data.icon]
	local _skill_data1 = i3k_db_skill_datas[skillID]

	widget.skill_icon:setImage(icon.path)
	widget.borderIcon:setImage(i3k_db_icons[skill_grade[state_lv + 1]].path)
	widget.redPoint:setVisible(showRed)

	if haveSkill then
		widget.lock:setVisible(false)

		widget.is_equip:setVisible(is_equip)
		widget.is_passive:setVisible(is_passive)
		local iconID = g_i3k_db.i3k_db_get_skill_type(skillID) == eSE_AURA and PASSIVE_ICON[2] or PASSIVE_ICON[1]
		widget.is_passive:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
		if is_passive then
			local fun = function(hoster, sender, eventType)
				if eventType == ccui.TouchEventType.began then
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(281))
				end
			end
			widget.skill_move:setTag(skillID)
			widget.skill_move:onClick(self, self.onShowDetailSkillList, self._isUniqueSkillOpen)
		else
			if not self._isUniqueSkillOpen then
				if not self:CanMoveSkill() then
					widget.skill_move:setTag(skillID)
					widget.skill_move:onClick(self, self.onShowDetailSkillList, self._isUniqueSkillOpen)
					return
				end
				widget.skill_move:onTouchEvent(self, self.onSkillMove, skillID)
			else
				widget.skill_move:onTouchEvent(self, self.onUniqueSkillMove, skillID)
			end
		end
	else
		widget.lock:show()
		widget.is_passive:hide()
		widget.is_equip:hide()
		-- if hero_lv >= _skill_data1[1].studyLvl then
		-- 	widget.skill_move:onClick(self, self.onUnLock, skillID)
		-- else
			widget.skill_move:setTag(skillID)
			widget.skill_move:onClick(self, self.onShowDetailSkillList, self._isUniqueSkillOpen)
		-- end
	end
end

function wnd_skill_ly:updateSkillPoint()
	local all_child = self.scroll:getAllChildren()
	local widget = self._layout.vars

	for i, e in pairs(all_child) do
		if e.id > 0 then
			if self._isUniqueSkillOpen then
				e.vars.redPoint:setVisible(g_i3k_game_context:isUniqueSkillCanUpdate(e.id))
			else
				e.vars.redPoint:setVisible(g_i3k_game_context:isSkillCanUpdate(e.id))
			end
		end
	end
	--取消红点提示
	for i,v in ipairs(self.skillBtn) do
		self.skillRed[i]:setVisible(g_i3k_game_context:isSkillCanUpdate(v:getTag()))
	end
	local role_unique_skill,use_uniqueSkill = g_i3k_game_context:GetRoleUniqueSkills()
	if use_uniqueSkill ~= 0 then
		widget.unique_skill_red:setVisible(g_i3k_game_context:isSkillCanUpdate(use_uniqueSkill, true))
	end
	if self._isUniqueId then
		widget.skill_lvl_red:setVisible(g_i3k_game_context:isUniqueSkillCanUpdateLevel(self._currSKillID))
		widget.skill_state_red:setVisible(g_i3k_game_context:isSkillCanUpdateJingjie(self._currSKillID, true))
	else
		widget.skill_lvl_red:setVisible(g_i3k_game_context:isSkillCanUpdateLevel(self._currSKillID))
		widget.skill_state_red:setVisible(g_i3k_game_context:isSkillCanUpdateJingjie(self._currSKillID))
	end
end

function wnd_skill_ly:openSkillPriview()
	g_i3k_ui_mgr:OpenUI(eUIID_TransferPreview)
	g_i3k_ui_mgr:RefreshUI(eUIID_TransferPreview)
end

function wnd_skill_ly:onFiveTrans(sender)
	local function callback (ok)
		if ok then
			g_i3k_logic:OpenBattleUI()
			g_i3k_game_context:goToFiveTransNpc()
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1367), callback)
end

function wnd_skill_ly:onWujueBtn(sender)
	g_i3k_logic:OpenWujueUI()
end

function wnd_skill_ly:onCloseUI()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSkillNotice")
	g_i3k_ui_mgr:CloseUI(eUIID_SkillLy)
end

--全部升级
function wnd_skill_ly:onUpAllSkill(sender)
	local skillsList = g_i3k_game_context:getAllSkillUpgradeList()
	local levelUpSkills, need_item = g_i3k_game_context:upgradeAllSkill(skillsList)
	if table.nums(levelUpSkills) > 0 then
		local callback = function (ok)
			if ok then
				i3k_sbean.goto_all_skill_levelup(levelUpSkills,need_item,g_i3k_game_context:GetRoleUniqueSkills())
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18085),callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18149))
	end
end
function wnd_create(layout)
	local wnd = wnd_skill_ly.new()
	wnd:create(layout)
	return wnd
end
