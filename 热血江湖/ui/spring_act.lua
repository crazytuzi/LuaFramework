-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_spring_act = i3k_class("wnd_spring_act", ui.wnd_base)


local ACT_TYPE =
{
	TYPE_TIAOXI = 1,
	TYPE_FEIZAO = 2,
	TYPE_CUOZAO = 3,
}
function wnd_spring_act:ctor()
	self.notShowTips = false
end

function wnd_spring_act:configure()
	local vars = self._layout.vars
	for i = 1, 5 do
		local item = vars['skill' .. i]
		item:onClick(self,self.onSkill, i)

		local mask = vars['mask' .. i]
		mask:setVisible(false)
	end


	vars.buffAll:onClick(self, self.onBuffAll)

	vars.buffSect:onClick(self, self.onBuffSect)

	vars.buffRank:onClick(self, self.onBuffRank)
	vars.help:onClick(self, function ()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(3173, i3k_db_spring.common.weeklyEnter))
	end)

	vars.closeTips:onClick(self,function ()
		self.notShowTips = true
		self._layout.vars.isMax:setVisible(false)
	end)

	vars.cancel4Btn:onClick(self, self.onCancelDouble, 1)
	vars.cancel5Btn:onClick(self, self.onCancelDouble, 2)
end

function wnd_spring_act:onBuffAll(sender)
	local springConfig = i3k_db_spring.common
	local springData = g_i3k_game_context:getSpringData()
	if springData.serverBuffCnt >= #(springConfig.allBuffCost) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3140))
		return
	end

	local cost = springConfig.allBuffCost[springData.serverBuffCnt+1]
	local buff = springConfig.allBuff[springData.serverBuffCnt+1]

	local tips = ""
	if g_i3k_game_context:springBuffIsMax() then
		tips = i3k_get_string(3174, cost)
	else
		tips = i3k_get_string(3136, cost, buff/100)
	end

	local callback = function (isOk)
		if isOk then
			if g_i3k_game_context:GetDiamondCanUse(true) < cost then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3138))
				return
			end
			i3k_sbean.request_hot_spring_use_buff_req(1, function  ()
				g_i3k_game_context:setServerBuff()
				g_i3k_game_context:UseDiamond(cost, true, AT_SPRING_BUFF_SERVER)
			end)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox3(tips, i3k_get_string(3176), callback)
end

function wnd_spring_act:onBuffSect(sender)
	local springConfig = i3k_db_spring.common
	local springData = g_i3k_game_context:getSpringData()
	if springData.sectBuffCnt >= #(springConfig.factionBuffCost) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3141))
		return
	end

	if g_i3k_game_context:GetFactionSectId() == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3139))
		return
	end

	local cost = springConfig.factionBuffCost[springData.sectBuffCnt+1]
	local buff = springConfig.factionBuff[springData.sectBuffCnt+1]

	local tips = ""
	if g_i3k_game_context:springBuffIsMax() then
		tips = i3k_get_string(3175,cost)
	else
		tips = i3k_get_string(3137,cost,buff/100)
	end

	local callback = function (isOk)
		if isOk then
			if g_i3k_game_context:GetDiamondCanUse(true) < cost then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3138))
				return
			end

			i3k_sbean.request_hot_spring_use_buff_req(2, function  ()
				g_i3k_game_context:setSectBuff()
				g_i3k_game_context:UseDiamond(cost, true, AT_SPRING_BUFF_SECT)
			end)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox3(tips, i3k_get_string(3177), callback)
end

--[[
	温泉祝福榜按钮点击事件
	param	sender:gameobject信息
]]--
function wnd_spring_act:onBuffRank(sender)
	i3k_sbean.query_spring_buff_rank(1)
end
function wnd_spring_act:getSkillDistance (type)
	if type == ACT_TYPE.TYPE_TIAOXI then
		return i3k_db_spring.common.tiaoxiLength
	elseif type == ACT_TYPE.TYPE_FEIZAO then
		return i3k_db_spring.common.feizaoLength
	elseif type == ACT_TYPE.TYPE_CUOZAO then
		return i3k_db_spring.common.cuozaoLength
	else
		return i3k_db_spring.common.doubleLength
	end
end

function wnd_spring_act:onSkill(sender, data)
	if g_i3k_game_context:IsOnRide() then
		return g_i3k_ui_mgr:PopupTipMessage("正在双人互动中")
	end
	local hero = i3k_game_get_player_hero()
	if hero then
		local selectData = g_i3k_game_context:GetSelectedRoleData()
		if selectData then
			local world = i3k_game_get_world();
			if world then
				local targetEntity = world:GetEntity(eET_Player, selectData.id)
				if targetEntity then
					local distance = i3k_vec3_dist(hero._curPosE, targetEntity._curPosE)
					--判断距离
					if distance <= self:getSkillDistance(data) then
						self:judgeSkillID(data, targetEntity, selectData, sender)
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3172))
					end
				end
			end
		else
			if data > 3 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3171))
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3170))
			end
		end
	end
end

function wnd_spring_act:judgeSkillID(id, targetEntity, selectData, sender)
	local hero = i3k_game_get_player_hero()
	if id <= 3 then
		self:useSingleAct(id, targetEntity, selectData.id, sender)
	else
		if g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_spring.common.costItem) < 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3160))
			return
		end

		local hero = i3k_game_get_player_hero()
		if id == 4 and not hero:IsInWater() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3157,"水上大黄鸭"))
			return
		end

		if id == 5 and not hero:IsInLand() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3157,"池边小憩"))
			return
		end
		if id == 4 then
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(3158),function  (isOk)
				if isOk then
					--双人互动
					i3k_sbean.request_hot_spring_use_double_act_req(id - table.nums(ACT_TYPE), selectData.id, selectData.name)
				end
			end)
		end
		if id == 5 then
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(3159),function  (isOk)
				if isOk then
					--双人互动
					i3k_sbean.request_hot_spring_use_double_act_req(id - table.nums(ACT_TYPE), selectData.id, selectData.name)
				end
			end)
		end

	end
end

function wnd_spring_act:coolDownAct(type, sender)
	local mask = self._layout.vars["mask" .. type]
	mask:setVisible(true)
	sender:setTouchEnabled(false)
	local progressAction = mask:createProgressAction(i3k_db_spring.common.singleCd, 100, 0)
	mask:runAction(cc.Sequence:create(progressAction, cc.CallFunc:create(function  ()
		sender:setTouchEnabled(true)
	end)))
end

-- 封装一层函数
function wnd_spring_act:useSingleAct(index, targetEntity, selectID, sender)
	--单人互动
	--移动时不能进行单人互动
	local hero = i3k_game_get_player_hero()
	if hero._behavior:Test(eEBMove) then
		g_i3k_ui_mgr:PopupTipMessage("移动中不能进行单人互动")
		return
	end
	--判断单人互动剩余次数
	local leftNum = self:getActLeftNumByType(index)
	if leftNum <= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3161))
		return
	end

	local callback = function ()
		--使用技能后转向目标
		local p1 = hero._curPos;
		local p2 = targetEntity._curPos;
		local rot_y = i3k_vec3_angle1(p2, p1, { x = 1, y = 0, z = 0 });
		hero:SetFaceDir(0, rot_y, 0);
		--g_i3k_game_context:singleAct(index)
		g_i3k_ui_mgr:RefreshUI(eUIID_SpringAct)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpringAct, "coolDownAct", index, sender)
	end

	i3k_sbean.request_hot_spring_use_single_act_req(index, selectID, callback)
end


function wnd_spring_act:setDoubleActNum()
	local vars = self._layout.vars;
	local itemCount = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_spring.common.costItem)
	vars.skill4Num:setText(itemCount)
	vars.skill5Num:setText(itemCount)
end

function wnd_spring_act:getActLeftNumByType(type)
	local springData = g_i3k_game_context:getSpringData();
	local springConfig = i3k_db_spring.common
	local addExpCnt = springData.addExpCnt
	if addExpCnt >= springConfig.addExpTime and not self.notShowTips then
		self._layout.vars.isMax:setVisible(true)
	else
		self._layout.vars.isMax:setVisible(false)
	end
	if type == ACT_TYPE.TYPE_TIAOXI then
		return springConfig.tiaoxiNum - springData.molestCnt
	elseif type == ACT_TYPE.TYPE_FEIZAO then
		return springConfig.feizaoNum - springData.soapCnt
	elseif type == ACT_TYPE.TYPE_CUOZAO then
		return springConfig.cuozaoNum - springData.rubCnt
	end
end

function wnd_spring_act:refresh()
	local vars = self._layout.vars
	local tiaoxiNum = self:getActLeftNumByType(ACT_TYPE.TYPE_TIAOXI)
	vars.skill1Num:setText(tiaoxiNum)
	local feizaoNum = self:getActLeftNumByType(ACT_TYPE.TYPE_FEIZAO)
	vars.skill2Num:setText(feizaoNum)
	local cuozaoNum = self:getActLeftNumByType(ACT_TYPE.TYPE_CUOZAO)
	vars.skill3Num:setText(cuozaoNum)
	
	local springData = g_i3k_game_context:getSpringData()
	if springData.weekEnterCnt > i3k_db_spring.common.weeklyEnter then
		for i = 1, 3 do
			self._layout.vars["skill"..i]:disableWithChildren()
		end
	end

	self:setDoubleActNum()
	self:onDoubleStateChange()
end

function wnd_spring_act:onDoubleStateChange()
	local widgets = self._layout.vars
	local hero = i3k_game_get_player_hero()
	if hero then
		local doubleType = hero:GetSpringDoubleType()
		widgets.skill4:setVisible(doubleType ~= g_SPRING_WATER_TYPE)
		widgets.skill4Num:setVisible(doubleType ~= g_SPRING_WATER_TYPE)
		widgets.cancel4Btn:setVisible(doubleType == g_SPRING_WATER_TYPE)

		widgets.skill5:setVisible(doubleType ~= g_SPRING_LAND_TYPE)
		widgets.skill5Num:setVisible(doubleType ~= g_SPRING_LAND_TYPE)
		widgets.cancel5Btn:setVisible(doubleType == g_SPRING_LAND_TYPE)
	end
end

function wnd_spring_act:onCancelDouble(sender,type)
	if type == 1 then
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(3167),function  (isOk)
			if isOk then
				i3k_sbean.hot_spring_cancel_double_act()
			end
		end)
	else
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(3168),function  (isOk)
			if isOk then
				i3k_sbean.hot_spring_cancel_double_act()
			end
		end)
	end
end

function wnd_spring_act:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_SpringAct)
end

function wnd_create(layout, ...)
	local wnd = wnd_spring_act.new()
		wnd:create(layout, ...)
	return wnd
end
