-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_create_kungfu_success = i3k_class("wnd_create_kungfu_success", ui.wnd_base)

local LAYER_WGQMT = "ui/widgets/wgqmt"
local attribute_icon = {245,246,247,248,249,250,251,252,253,254,257,258,259,260,261,262}
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

local zhui_word =
{
[990001]=257,
[990002]=257,
[990003]=257,
[990004]=257,
[990005]=259,
[990006]=259,
[990007]=259,
[990008]=259,
[990009]=259,
[990010]=259,
[990011]=261,
[990012]=261,
[990013]=261,
[990014]=261,
[990015]=261,
}

local headIconID = nil
local my_skill_data = nil
local my_roleAllDiySkills = nil
local my_diySkillShare = nil

function wnd_create_kungfu_success:ctor()
	self._skill_icon = nil
end

function wnd_create_kungfu_success:configure()
    local widgets = self._layout.vars
	widgets.forget_btn:onClick(self,self.onForget)
	widgets.master_btn:onClick(self,self.onMaster)
	widgets.change_skill_icon:onClick(self,self.onChangeSkillIcon)

	self._layout.vars.name_text:setMaxLength(i3k_db_common.inputlen.diyskilllen)
end

function wnd_create_kungfu_success:refresh(tmpSkillData,iconId,roleAllDiySkills,diySkillShare)
	--根据参数不同，有些可能为空
	if tmpSkillData then
    	my_skill_data =  tmpSkillData
		self:setData(tmpSkillData)
	end
	if roleAllDiySkills then
    	my_roleAllDiySkills = roleAllDiySkills
	end
	if diySkillShare then
		my_diySkillShare = diySkillShare
	end
	if iconId then
    	self:setIconID(iconId)
	end
end

function wnd_create_kungfu_success:setIconID(id)
    if id == nil then return end
    local skill_icon = self._layout.vars.skill_icon
    skill_icon:setImage(i3k_db_icons[id].path)
    headIconID = id
end

function wnd_create_kungfu_success:setData(tmpSkillData)
	if not(tmpSkillData) then
		return
	end

	-- 循环播放技能效果
	local equipInfo = g_i3k_game_context:GetWearEquips()
	--local hidefashion = g_i3k_game_context:IsHeroFashionShow()
	g_i3k_game_context:ResetTestFashionData() --清理时装试穿数据
	ui_set_hero_model(self._layout.vars.skillAction, i3k_game_get_player_hero(),equipInfo,g_i3k_game_context:GetIsShwoFashion())
	local skillActionIDString = tostring(tmpSkillData.skillActionID)
	local heroID = tostring(i3k_game_get_player_hero()._id)
	skillActionIDString = tonumber(heroID..string.sub(skillActionIDString,2))
	local actionName = i3k_db_create_kungfu_showargs_new[skillActionIDString].attackActionName
	self._layout.vars.skillAction:playAction(actionName)

    if tmpSkillData then
        local skill_icon = self._layout.vars.skill_icon
        local _total = #i3k_db_kungfu_args.icons.id
		local random_result = math.random(1,_total)
		local id = i3k_db_kungfu_args.icons.id[random_result]
        skill_icon:setImage(i3k_db_icons[id].path)
        headIconID = id
        -- 评级图标
        local iconid =  i3k_db_create_kungfu_score[tmpSkillData.gradeId].icon
        local score_icon = self._layout.vars.score_icon
    	score_icon:setImage(i3k_db_icons[iconid].path)
        -- 右侧技能说明(通用的)
	    local args_scroll = self._layout.vars.args_scroll
        if args_scroll then
            args_scroll:removeAllChildren()
            for i =1,7 do
                local canBeAdd = true
                local mylayer = require(LAYER_WGQMT)()
                local attribute = mylayer.vars.desc -- 描述
                local args_icon = mylayer.vars.args_icon
                local word_icon = mylayer.vars.word_icon
                word_icon:setImage(i3k_db_icons[attribute_icon[i*2-1]].path)
                if attribute then
                    if i == 1  then
                        local args1 = tmpSkillData.damageArgs[1]*100
                        args1 = math.round(args1)
                        local args2 = tmpSkillData.damageArgs[2]
                        args2 = math.modf(args2)
                        attribute:setText(i3k_get_string(83,args1,args2))
                    elseif i == 2 then
                        local args1 = (0.2 + tmpSkillData.atrDecrease)*100
                		args1 = math.max(math.round(args1),0)
                		local args2 = (0.1 + tmpSkillData.acrDecrease)*100
                		args2 = math.max(math.round(args2),0)
                		attribute:setText(i3k_get_string(84,args1,args2))
                    elseif i == 3 then
                        local args = tmpSkillData.damageTimes
                		args = math.modf(args)
                		attribute:setText(i3k_get_string(86,args))
                    elseif i== 4 then
                        local cd = tmpSkillData.cd/1000
                		cd = math.round(cd)
                		local addSP = tmpSkillData.addSP
                		attribute:setText(i3k_get_string(87,cd,addSP))
                    elseif i == 5 then
						local hero = i3k_game_get_player_hero()
						local role_id = hero._id
						local args1,args2,args3 = self:chan_args_conv(role_id,tmpSkillData.skillActionID,tmpSkillData.scope)
						local id = chan_enum[args1].normal
                        attribute:setText(i3k_get_string(id,args2,args3))
                    elseif i == 6 then -- 下面这两个判断没有的话则不显示
                        if tmpSkillData.buffs then
                			local buff_data = tmpSkillData.buffs[1];
                			if buff_data then
                				local buffid = buff_data.status.buffID
                				local text_str = zhui_enum[buffid] or 99;
                				local args1 = buff_data.status.odds/100 or 100 -- 生效几率
                				args1 = math.modf(args1)
                				local args2 = buff_data.loopTime/1000 or 5   --持续时间
                				args2 = math.modf(args2)
						args2 = math.max(args2,1)
                				local args3 = math.abs(buff_data.affectValue or 8)-- 数值
                				attribute:setText(i3k_get_string(text_str,args1,args2,args3))
                				local buff_icon = zhui_word[buffid] or 257
                				word_icon:setImage(i3k_db_icons[buff_icon].path)
                			else
                				attribute:setText("")
                				canBeAdd = false
                			end
                		else
                			attribute:setText("")
							canBeAdd = false
                		end

                    elseif i == 7 then
                        if tmpSkillData.buffs then
            			local buff_data = tmpSkillData.buffs[2];
                			if buff_data then
                				local buffid = buff_data.status.buffID
                				local text_str = zhui_enum[buffid] or 99
                				local args1 = buff_data.status.odds/100 or 100-- 生效几率
                				args1 = math.modf(args1)
                				local args2 = buff_data.loopTime/1000 or 5    --持续时间
                				args2 = math.modf(args2)
                				local args3 = math.abs(buff_data.affectValue or 8)-- 数值
                				attribute:setText(i3k_get_string(text_str,args1,args2,args3))
                				local buff_icon = zhui_word[buffid] or 257
                				word_icon:setImage(i3k_db_icons[buff_icon].path)
                			else
                				attribute:setText("")
                				canBeAdd = false
                			end
                		else
                			attribute:setText("")
	                		canBeAdd = false
                		end
                    end
                end
                if canBeAdd then
                    args_scroll:addItem(mylayer)
                end
            end -- for
        end -- fi
    end
end

function wnd_create_kungfu_success:chan_args_conv(role_id,skillid,scope)
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

function wnd_create_kungfu_success:onForget(sender)
	local mark_score = i3k_db_kungfu_args.socre_mark.forget_mark
	local score = my_skill_data.gradeId or 1
	if score >= mark_score then -- 如果是上承功法
		local fun = (function(ok)
			if ok then
				i3k_sbean.diySkill_discard_skill(0)
				g_i3k_ui_mgr:CloseUI(eUIID_CreateKungfuSuccess)
				return
			end
		end)
		local desc = "这是一套上乘功法确定要遗忘吗"
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
		return
	end
    i3k_sbean.diySkill_discard_skill(0)  -- 0 为临时技能
	g_i3k_ui_mgr:CloseUI(eUIID_CreateKungfuSuccess)
	return
end

function wnd_create_kungfu_success:onMaster(sender)
	local name_text = self._layout.vars.name_text
	local name = name_text:getText()
	if name == "" then
		g_i3k_ui_mgr:PopupTipMessage("请给您自创的武功起个名字吧")
		return
	end
	local stringLength = i3k_get_utf8_len(name)
	if stringLength > i3k_db_common.inputlen.diyskilllen then
		g_i3k_ui_mgr:PopupTipMessage(string.format("名字不能超过%d%s",i3k_db_common.inputlen.diyskilllen,"个汉字"))
		return
	end

    local tmp_data = my_roleAllDiySkills.diySkills
	local tpos = #tmp_data + 1
	if my_roleAllDiySkills.tmpDiySkill then
		tpos = tpos - 1
	end
	local count = my_roleAllDiySkills.slot
	if tpos > count then
		g_i3k_ui_mgr:PopupTipMessage(string.format("您最多掌握%d%s",count,"个自创武功，请遗弃一个自创武功"))
		g_i3k_ui_mgr:OpenUI(eUIID_KungfuFull)
		g_i3k_ui_mgr:RefreshUI(eUIID_KungfuFull, my_roleAllDiySkills,my_diySkillShare)
		return
	end
	local namecount = i3k_get_utf8_len(name)
	if namecount > i3k_db_common.inputlen.diyskilllen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(234))
		return
	end
	-- 检测 武功名称中是否含有非法字符串
	--发送消息 ,已经创建好的技能是不可以更换名字和图标的
    i3k_sbean.diySkill_sava_skill(headIconID,name, my_skill_data.gradeId)

end

function wnd_create_kungfu_success:onChangeSkillIcon(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ChangeSkillIcon)
	g_i3k_ui_mgr:RefreshUI(eUIID_ChangeSkillIcon,1)
end

function wnd_create(layout)
	local wnd = wnd_create_kungfu_success.new();
		wnd:create(layout);
	return wnd;
end
