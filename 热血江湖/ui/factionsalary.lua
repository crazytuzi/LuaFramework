-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_factionSalary = i3k_class("wnd_factionSalary", ui.wnd_base)

function wnd_factionSalary:ctor()

end

function wnd_factionSalary:configure()
	self._layout.vars.closeBtn:onClick(self,self.onClose)
end

function wnd_factionSalary:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_FactionSalary)
end

local checkTime = function ()
	local openDay = i3k_db_faction_salary_cfg.common.openday
	local openTime = {[1]=i3k_db_faction_salary_cfg.time}
	--检查开启时间
	if not i3k_get_activity_is_open_offset(openDay) or not i3k_get_is_in_open_time_offset(openTime) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3210,i3k_db_faction_salary_cfg.time.startTime))
		return true
	end
	return false
end

function wnd_factionSalary:refresh(data)
	local ui = self._layout.vars
	ui.info:setText(i3k_get_string(
						3216,
						i3k_db_faction_salary_cfg.time.startTime,
						i3k_db_faction_salary_cfg.common.activity,
						i3k_db_faction_salary_cfg.exSalary.activity
					))
	ui.vitality_value:setText(data.sectDayVit .. "/" .. i3k_db_faction_salary_cfg.common.activity)
	ui.help:onClick(self,function ()
		g_i3k_ui_mgr:ShowHelp(
			i3k_get_string(
				3217,
				i3k_db_faction_salary_cfg.time.startTime,
				i3k_db_faction_salary_cfg.common.activity,
				i3k_db_faction_salary_cfg.exSalary.activity,
				i3k_db_faction_salary_cfg.reSalary.prop / 100
			)
		)
	end)
	local roleData = data.roleData
	local job_text = {"帮主","副帮主","长老","精英","平民"}
	ui.normal_position:setText(job_text[roleData.position])
	ui.super_position:setText(job_text[roleData.position])
	--普通奖励
	local baseSalayConfig = i3k_db_faction_salary_cfg.baseSalary[roleData.position]
	ui.diamondNum1:setText("X" .. baseSalayConfig.awardNum1)	
	ui.normal_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(baseSalayConfig.awardId1,i3k_game_context:IsFemaleRole()))
	ui.normalScroll:removeAllChildren()
	local normalAward = {}
	local checkAward = {}
	for i=1,4,1 do
		if baseSalayConfig["awardId" .. (i+1)] and baseSalayConfig["awardId" .. (i+1)] ~= 0 then	
			local id = baseSalayConfig["awardId" .. (i+1)]
			local num = baseSalayConfig["awardNum" .. (i+1)]
			local _item = require("ui/widgets/bpflt")()
			_item.vars.normalBg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			_item.vars.normalIcon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
			_item.vars.normalBtn1:onClick(self,function ()
				g_i3k_ui_mgr:ShowCommonItemInfo(id)
			end)
			_item.vars.normalNum1:setText("X" .. num)
			
			table.insert(normalAward,{id=id,count=num})
			checkAward[id] = num
			ui.normalScroll:addItem(_item)
		end
	end
	ui.normalSend:onClick(self,function ()
		if checkTime() then
			return
		end
		if data.sectDayVit < i3k_db_faction_salary_cfg.common.activity then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3213,i3k_db_faction_salary_cfg.common.activity))
			return
		end
		
		if g_i3k_game_context:IsBagEnough(checkAward) then
			i3k_sbean.request_sect_base_salary_take_req(function ()
				g_i3k_ui_mgr:ShowGainItemInfo(normalAward)
			end)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
		end
	end)
	if roleData.baseSalary == 1 then
		ui.normalSend:disableWithChildren()
	end
	
	--特殊奖励
	local superConfig = i3k_db_faction_salary_cfg.exSalary	
	ui.diamondNum2:setText("X" .. superConfig.awardNum1)
	ui.super_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(superConfig.awardId1,i3k_game_context:IsFemaleRole()))
	local superAward = {}
	local checkAward = {}
	ui.superScroll:removeAllChildren()
	for i=1,4,1 do
		if superConfig["awardId" .. (i+1)] and superConfig["awardId" .. (i+1)] ~= 0 then
			local id = superConfig["awardId" .. (i+1)]
			local num = superConfig["awardNum" .. (i+1)]
			local _item = require("ui/widgets/bpflt")()
			_item.vars.normalBg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			_item.vars.normalIcon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
			_item.vars.normalBtn1:onClick(self,function ()
				g_i3k_ui_mgr:ShowCommonItemInfo(id)
			end)
			_item.vars.normalNum1:setText("X" .. num)
			
			table.insert(superAward,{id=id,count=num})
			checkAward[id] = num
			ui.superScroll:addItem(_item)
		end
	end
	ui.superSend:onClick(self,function ()
		if checkTime() then
			return
		end
		if data.sectDayVit < i3k_db_faction_salary_cfg.common.activity then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3213,i3k_db_faction_salary_cfg.common.activity))
			return
		end
		
		local activity = g_i3k_game_context:GetScheduleInfo().activity
		if activity < i3k_db_faction_salary_cfg.exSalary.activity then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3214,i3k_db_faction_salary_cfg.exSalary.activity))
			return
		end
		if g_i3k_game_context:IsBagEnough(checkAward) then
			i3k_sbean.request_sect_activity_salary_take_req(function ()
				g_i3k_ui_mgr:ShowGainItemInfo(superAward)
			end)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
		end
	end)
	
	if roleData.activitySalary == 1 then
		ui.superSend:disableWithChildren()
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_factionSalary.new()
	wnd:create(layout, ...)
	return wnd
end
