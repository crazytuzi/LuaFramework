-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_kungfu_full = i3k_class("wnd_kungfu_full", ui.wnd_base)

local LAYER_WGGLT = "ui/widgets/wgglt"

--缠类型的枚举
local chan_enum =
{
	--单体
	[2] = {normal=89,simple=90},
	--圆形
	[3] = {normal=91,simple=92},
	--前方圆形
	[4] = {normal=93,simple=94},
	--扇形
	[5] = {normal=95,simple=96},
	--矩形
	[6] = {normal=97,simple=98},
};
--追类型枚举
local zhui_enum =
{
	--控-眩晕
	[990005] = 99,
	--控-沉睡
	[990008] = 100,
	--控-定身
	[990006] = 101,
	--控-沉默
	[990010] = 102,
	--控-恐惧
	[990009] = 103,
	--控-减速
	[990007] = 104,

	--破-减血量上限
	[990001] = 105,
	--破-减攻击
	[990002] = 106,
	--破-减防御
	[990003] = 107,
	--破-中毒
	[990004] = 108,

	--幻-持续回血
	[990011] = 109,
	--幻-加速
	[990012] = 110,
	--幻-增加气血上限
	[990013] = 111,
	--幻-增加攻击
	[990014] = 112,
	--幻-增加防御
	[990015] = 113,
};

local my_roleAllDiySkills = nil
local my_diySkillShare = nil

function wnd_kungfu_full:ctor()

	self._id = nil  -- 选中的技能 tag
	self._data = {}
end

function wnd_kungfu_full:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	widgets.forget_btn:onClick(self,self.onForget)
	widgets.expandPos_btn:onClick(self,self.onExpand)
end

function wnd_kungfu_full:refresh(roleAllDiySkills,diySkillShare)
    my_roleAllDiySkills = roleAllDiySkills
	my_diySkillShare = diySkillShare
    self:setData()
end

function wnd_kungfu_full:setData() -- 显示技能基本图

	local data = my_roleAllDiySkills.diySkills
	if next(data) == nil then return end
	local item_scroll = self._layout.vars.item_scroll
	if item_scroll then
		item_scroll:removeAllChildren()
		local _index = 0
		self._data = {}
		for k,v in ipairs(data) do
			if v.iconId then -- 存在一个临时变量
				_index = _index + 1
				if v.iconId == 0 then
					break
				end
				if _index == 1 and not self._id then
					self._id = k
				end
				local _layer = require(LAYER_WGGLT)()
				local skill_icon = _layer.vars.skill_icon
				skill_icon:setImage(i3k_db_icons[v.iconId].path)

				local skill_name = _layer.vars.skill_name
				skill_name:setText(v.name)
				skill_name:setTextColor(g_i3k_db.g_i3k_get_color_by_rank(v.diySkillData.gradeId))
				local select_icon = _layer.vars.select_icon
				if self._id == _index  then
					select_icon:show()
				else
					select_icon:hide()
				end
				self._data[k] = select_icon
				local bt = _layer.vars.bt
				bt:setTag(k)
				bt:onClick(self,self.onSelect)

				local skill_score = _layer.vars.skill_score
				skill_score:setImage(i3k_db_icons[i3k_db_create_kungfu_score[v.diySkillData.gradeId].icon].path)
				item_scroll:addItem(_layer)
			end
		end
		self:setAttributeData()
	end
end

function wnd_kungfu_full:onSelect(sender)
	local tag = sender:getTag()
	self._id = tag
	for k,v in pairs(self._data) do
		if k == tag then
			v:show()
		else
			v:hide()
		end
	end
	self:setAttributeData()
end

function wnd_kungfu_full:setAttributeData() -- 根据id显示 右侧技能详细数据
	if not self._id then
		return
	end
	local data = my_roleAllDiySkills.diySkills
	local _data = data[self._id]
	for i =1,7 do
		local tmp_attribute = "attribute"..i
		local attribute = self._layout.vars[tmp_attribute]
		if attribute then
			if i == 1 then
				local hero = i3k_game_get_player_hero()
				local role_id = hero._id
				local args1,args2,args3 = self:chan_args_conv(role_id,_data.diySkillData.skillActionID,_data.diySkillData.scope)
				local id = chan_enum[args1].simple
				attribute:setText(i3k_get_string(id,args2,args3))
			elseif i == 2 then
				local cd = _data.diySkillData.cd/1000
				cd = math.round(cd)
				local addSP = _data.diySkillData.addSP
				attribute:setText(i3k_get_string(88,cd,addSP))
			elseif i == 3 then
				local args1 = (0.2 + _data.diySkillData.atrDecrease)*100
				args1 = math.max(math.round(args1,2),0)
				local args2 = (0.1 + _data.diySkillData.acrDecrease)*100
				args2 = math.max(math.round(args2,2),0)
				attribute:setText(i3k_get_string(85,args1,args2))
			elseif i == 4 then
				local args = _data.diySkillData.damageTimes
				args = math.modf(args)
				attribute:setText(i3k_get_string(86,args))
			elseif i == 5 then
				local args1 =  _data.diySkillData.damageArgs[1]*100
				args1 = math.round(args1,2)
				local args2 =  _data.diySkillData.damageArgs[2]
				args2 = math.modf(args2)
				attribute:setText(i3k_get_string(83,args1,args2))
			elseif i == 6 then
				if _data.diySkillData.buffs then --and _data.diySkillData.buffs.status
					local buff_data = _data.diySkillData.buffs[1];
					if buff_data then
						local buffid = buff_data.status.buffID
						local text_str = zhui_enum[buffid] or 99;
						local args1 = buff_data.status.odds/100 or 100 -- 生效几率
						args1 = math.modf(args1)
						local args2 = buff_data.loopTime/1000 or 5   --持续时间
						args2 = math.modf(args2)
						local args3 = math.abs(buff_data.affectValue or 8)-- 数值
						attribute:setText(i3k_get_string(text_str,args1,args2,args3))
					else
						attribute:setText("")
					end
				else
					attribute:setText("")
				end
			elseif i == 7 then
				if _data.diySkillData.buffs then --and _data.diySkillData.buffs.status
					local buff_data = _data.diySkillData.buffs[2];
					if buff_data then
						local buffid = buff_data.status.buffID
						local text_str = zhui_enum[buffid] or 99
						local args1 = buff_data.status.odds/100 or 100-- 生效几率
						args1 = math.modf(args1)
						local args2 = buff_data.loopTime/1000 or 5    --持续时间
						args2 = math.modf(args2)
						local args3 = math.abs(buff_data.affectValue or 8)-- 数值
						attribute:setText(i3k_get_string(text_str,args1,args2,args3))
					else
						attribute:setText("")
					end
				else
					attribute:setText("")
				end
			end
		end
	end
end

function wnd_kungfu_full:chan_args_conv(role_id,skillid,scope)
	local range_type = math.modf(skillid % 1000 / 100)
	local range_arg1 = 0
	local range_arg2 = 0
	local range = scope[1] or 0
	if role_id == 4 or role_id == 5 or role_id == 7 then
		-- 若是弓手，则对距离进行修正
		if range_type == 2 then
			range_arg1 = (range - 100) * 2 + 200  -- 单体距离 = (原始距离 - 100) * 2 + 200
			range_arg2 = 0
		elseif range_type == 6 then
			range_arg1 = (range - 100) * 2 + 200 -- 矩形距离 = (原始距离 - 100) * 2 + 200
			range_arg2 = 1.5                     --弓手或医生时，矩形宽度只有150厘米
		elseif range_type == 5 then
			range_arg1 = (range - 50) * 2 + 200  -- 扇形距离 = (原始距离 - 50) * 2 + 200
			range_arg2 = 60                      --弓手或医生时，扇形只有60度
		elseif range_type == 3 then              --圆形距离 = 原始距离 + 250
			range_arg1 = range + 250
			range_arg2 = 0
		else
			range_arg1 = range
			range_arg2 = 0
		end
	else
		if range_type == 2 then
			range_arg1 = range                   -- 若不是弓手或医生，则range不变
			range_arg2 = 0
		elseif range_type == 6 then
			range_arg1 = range
			range_arg2 = 2                     -- 若不是弓手或医生，则矩形宽度为200
		elseif range_type == 5 then
			range_arg1 = range
			range_arg2 = 120                     -- 若不是弓手或医生，扇形角度为120
		elseif range_type == 3 then
			range_arg1 = range
			range_arg2 = 0
		else
			range_arg1 = range
			range_arg2 = 0
		end
	end
	return range_type,range_arg1/100,range_arg2
end


function wnd_kungfu_full:onForget(sender)
	local pos = self._id
	local isShare = g_i3k_game_context:isMyShareDIYSkill(my_diySkillShare,my_roleAllDiySkills,self._id)
	local mark_score = i3k_db_kungfu_args.socre_mark.forget_mark
	local _data = my_roleAllDiySkills.diySkills
	local skill_data = _data[pos]
	local score = skill_data.diySkillData.gradeId
	if score >= mark_score then
		local fun = (function(ok)
			if ok then
				if g_i3k_game_context:checkDiyPreFlag(pos) then
					local fun2 = ( function (ok2)
						if ok2 then
							self:sendForget(pos)
						end
					end)
					g_i3k_ui_mgr:ShowMessageBox2("该自创武功位于技能预设中,删除后该技能预设将没有自创武功,是否确认?",fun2)
				else
					self:sendForget(pos)
				end
			end
		end)
		local desc
		if isShare then
			desc = i3k_get_string(333)
		else
			desc = "这是一套上乘功法确定要遗忘吗"
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
		return
	else
		if g_i3k_game_context:checkDiyPreFlag(pos) then
			local fun = ( function (ok)
				if ok then
					self:sendForget(pos)
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2("该自创武功位于技能预设中,删除后该技能预设将没有自创武功,是否确认?",fun)
			return
		end
		self:sendForget(pos)
	end
end

function wnd_kungfu_full:sendForget(pos)
	i3k_sbean.diySkill_discard_skill(pos)
	g_i3k_ui_mgr:CloseUI(eUIID_KungfuFull)
end

--拓展空位
function wnd_kungfu_full:onExpand(sender)
	local currentID = my_roleAllDiySkills.slot
	local money = 0
	if i3k_db_kungfu_slot[currentID + 1] then
		money = i3k_db_kungfu_slot[currentID + 1].money
		local fun = (function(ok)
			if ok then
				if g_i3k_game_context:GetMoneyCanUse(false) < money then
					g_i3k_ui_mgr:PopupTipMessage("铜钱不足无法扩展位置")
					return
				end
				i3k_sbean.diySkill_unlock()
				g_i3k_game_context:UseMoney(money,false,AT_DIYSKILL_SLOT_UNLOCK);
			end
		end)
		local desc = string.format("扩展位置需要花费%d%s",money,"铜钱")
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
    else
        --全部拓展完成了，无法拓展了
		g_i3k_ui_mgr:PopupTipMessage("全部拓展完成，无法扩展位置")
	end
end

--[[function wnd_kungfu_full:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_KungfuFull)
end--]]

function wnd_create(layout)
	local wnd = wnd_kungfu_full.new();
		wnd:create(layout);
	return wnd;
end
