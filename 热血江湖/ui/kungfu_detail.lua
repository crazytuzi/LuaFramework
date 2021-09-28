-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_kungfu_detail = i3k_class("wnd_kungfu_detail", ui.wnd_base)

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

local myDiySkillData = nil
local myOtherValue = {}
local my_diySkillShare = nil
local isShare = nil -- 标记是否是分享的技能
local skillmodule = nil

function wnd_kungfu_detail:ctor()
	self._type = nil
	self._pos = nil
	my_diySkillShare = {}
end

function wnd_kungfu_detail:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local flauntBtn = self._layout.vars.xuanyao
	flauntBtn:onClick(self,self.onFlaunt)
    self._type = 1
	skillmodule = self._layout.vars.skillAction -- 3D模型播放动作
end

function wnd_kungfu_detail:refresh(skillData,showType,otherValue)
    myDiySkillData = skillData
	if otherValue then
		myOtherValue = otherValue
	end

	if showType then
		if showType == 1 then
	    	self:setMyDetailData()  -- 遗忘，分享，装备
		elseif showType == 2 then
			self:setShareData() -- 借用，剩余借用次数，借用天数
		elseif showType == 3 then
			self:setMyDetailData() -- 没有按钮（显示技能的宗门和分享者）
		end
	else
		self:onShowDetailData()
	end

end

function wnd_kungfu_detail:setMyDetailData()
	local widgets = self._layout.vars
	widgets.myRoot:show()
	widgets.myTitleRoot:show()
	widgets.shareRoot:hide()
	widgets.shareTitleRoot:hide()
	widgets.showTitleRoot:hide()

	local score = myDiySkillData.diySkillData.gradeId
	local name = myDiySkillData.name

	widgets.myTitleDesc:setText(i3k_db_create_kungfu_score[score].desc)
	widgets.skill_name:setText(name)
	widgets.score_icon:setImage(i3k_db_icons[i3k_db_create_kungfu_score[score].icon].path)
	widgets.forget_btn:onClick(self,self.onForget)
	widgets.share_btn:onClick(self,self.onShare)
	widgets.equip_btn:onClick(self,self.onEquip)

	local equip_label = self._layout.vars.equip_label
	if myOtherValue.isEquip then
		equip_label:setText("取消装备") -- 装备按钮上的文字
	else
		equip_label:setText("装备")
	end

	-- 是否可以分享
	local mark_score = i3k_db_kungfu_args.socre_mark.forget_mark
	widgets.share_btn:setVisible(score >= mark_score)

	if myOtherValue.isShare then
		widgets.shareLabel:setText("取消分享")
	end
	self:setAttributeData()
end
-- 遗忘
function wnd_kungfu_detail:onForget(sender)
	local pos = myDiySkillData.id
	local mark_score = i3k_db_kungfu_args.socre_mark.forget_mark
	local score = myDiySkillData.diySkillData.gradeId
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
		if myOtherValue.isShare then
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

function wnd_kungfu_detail:sendForget(pos)
	i3k_sbean.diySkill_discard_skill(pos, true)
	g_i3k_ui_mgr:CloseUI(eUIID_KungfuDetail)
end
-- 分享 技能
function wnd_kungfu_detail:onShare(sender)
	local pos = myDiySkillData.id
	local maxTime = i3k_db_kungfu_args.times.maxShareTimes
	if myOtherValue.sharedCount <= maxTime then
		if myOtherValue.isShare then
			i3k_sbean.cancelShareDiySkill(pos)
		else
			i3k_sbean.shareDiySkill(pos)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("您同时只能分享2个武功，不可再分享")
		return
	end
end

-- 装备
function wnd_kungfu_detail:onEquip(sender)
	local pos = myDiySkillData.id
	if myOtherValue.isEquip then
		i3k_sbean.diySkill_canceluse(pos)
	else
		i3k_sbean.diyskill_selectuse(pos)
	end
end

-- 借用
function wnd_kungfu_detail:onBorrow(sender)

	if myOtherValue.isMyShareSkill then
		local pos = myDiySkillData.id
		i3k_sbean.cancelShareDiySkill(pos)
	end
	local playerId = myOtherValue.playerId
	local serverId = myOtherValue.serverId
	local skillId = myOtherValue.skillId

	if myOtherValue.isBorrowed then
		g_i3k_ui_mgr:PopupTipMessage("您已借用此武功，无法重复借用")
		return
	end
	i3k_sbean.borrowDiySkill(skillId, playerId)
end

-- 炫耀
function wnd_kungfu_detail:onFlaunt(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_KungfuShowOff)
	g_i3k_ui_mgr:RefreshUI(eUIID_KungfuShowOff,myDiySkillData.id)
end

---------上面几个函数是借用chat.lua 中的

-- 显示分享的数据,可借用
function wnd_kungfu_detail:setShareData()
	local widgets = self._layout.vars
	widgets.myRoot:hide()
	widgets.myTitleRoot:hide()
	widgets.shareRoot:show()
	widgets.shareTitleRoot:show()
	widgets.showTitleRoot:hide()
	widgets.borrow_btn:onClick(self,self.onBorrow)
	local allTimes = i3k_db_kungfu_args.times.borrowTimes
	local saveDays = i3k_db_kungfu_args.times.saveDays
	local count = allTimes - myOtherValue.myShareSkillTimes  -- 最多可领取10次
	local surplusDay = saveDays - myOtherValue.skillSaveTime
	local name = myOtherValue.roleName
	local skillName = myDiySkillData.name
	widgets.skill_name:setText(skillName)
	widgets.count_label:setText(count)
	widgets.day_label:setText(surplusDay)
	widgets.shareName:setText(name)
	widgets.score_icon:setImage(i3k_db_icons[i3k_db_create_kungfu_score[myDiySkillData.diySkillData.gradeId].icon].path)
	-- 如果是自己分享的技能则显示取消分享
	if myOtherValue.isMyShareSkill then
		widgets.borrowLabel:setText("取消分享")
		--widgets.day_label:setText("无限制")
	end

	local flauntBtn = self._layout.vars.xuanyao
	flauntBtn:hide()
	self:setAttributeData()
end

-- 显示武功的创建者和宗门(没有最下面的按钮，只显示一个关闭)
function wnd_kungfu_detail:onShowDetailData(kungfuData)
	local widgets = self._layout.vars
	widgets.myRoot:hide()
	widgets.myTitleRoot:hide()
	widgets.shareRoot:hide()
	widgets.shareTitleRoot:hide()
	self._layout.vars.xuanyao:hide()
	
	widgets.showTitleRoot:show()-- 显示创建者和宗门 temp hide it
	widgets.score_icon:setImage(i3k_db_icons[i3k_db_create_kungfu_score[kungfuData.diySkillData.gradeId].icon].path)
	widgets.createName:setText(kungfuData.fromName)
	self._layout.vars.skill_name:setText(kungfuData.name)
	self:setAttributeData(kungfuData)
end

-- 设置技能的详细数据的通用方法
function wnd_kungfu_detail:setAttributeData(kungfuData)
	local _data = kungfuData and kungfuData or myDiySkillData
	-- 循环播放技能效果
	local equipInfo = g_i3k_game_context:GetWearEquips()
	--local hidefashion = g_i3k_game_context:IsHeroFashionShow()
	g_i3k_game_context:ResetTestFashionData() --清理时装试穿数据
	ui_set_hero_model(skillmodule, i3k_game_get_player_hero(),equipInfo,g_i3k_game_context:GetIsShwoFashion())
	local actionName = i3k_db_create_kungfu_showargs_new[_data.diySkillData.skillActionID].attackActionName
	self._layout.vars.skillAction:playAction(actionName)

	for i=1,7 do
		local tmp = "attribute"..i
		local attribute = self._layout.vars[tmp]
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
				if _data.diySkillData.buffs then
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
				if _data.diySkillData.buffs then
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

function wnd_kungfu_detail:chan_args_conv(role_id,skillid,scope)
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

--[[function wnd_kungfu_detail:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_KungfuDetail)
	my_diySkillShare = {}
	myDiySkillData = {}
	myOtherValue = {}
	isShare = nil
end--]]

function wnd_create(layout)
	local wnd = wnd_kungfu_detail.new();
		wnd:create(layout);
	return wnd;
end
