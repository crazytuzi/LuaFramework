-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--姻缘破裂ui
-------------------------------------------------------
wnd_marry_marryed_lihun = i3k_class("marry_marryed_lihun", ui.wnd_base)



function wnd_marry_marryed_lihun:ctor()
	
end

function wnd_marry_marryed_lihun:configure()
	local widgets = self._layout.vars

	self.close_btn =  widgets.close_btn 
	self.close_btn:onClick(self, self.onCloseUI)
	
	
	self.divorce_btn = widgets.divorce_btn--离婚
	self.divorce_btn:stateToPressed()
	
	-- self.yinyuan_btn = widgets.yinyuan_btn  --姻缘
	-- self.yinyuan_btn:stateToNormal()
	-- self.yinyuan_btn:onClick(self, self.onYinYuanBtn)
	
	-- self.skills_btn = widgets.skills_btn
	-- self.skills_btn:stateToNormal()
	-- self.skills_btn:onClick(self, self.onskillsBtn)--技能
	
	-- self.achievement_btn = widgets.achievement_btn
	-- self.achievement_btn:stateToNormal()
	-- self.achievement_btn:onClick(self, self.onAchievementBtn)--成就
	
	self.lihun_btn = widgets.lihun_btn
	self.lihun_btn:onClick(self, self.onLihun_btn)
	self.textLabel = widgets.textLabel
	
	self.marryNameLabel = widgets.marryNameLabel
	self.marryName = widgets.marryName

	
end

function wnd_marry_marryed_lihun:refresh()
	--self._layout.vars.achieve_red:setVisible(g_i3k_game_context:GetNoticeState(g_NOTICE_TYPE_MARRY_ACHIEVEMENT))
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_COIN,i3k_game_context:IsFemaleRole()))
	self._layout.vars.label:setText("x"..i3k_db_marry_rules.divorceCost)
	local marriageTime = g_i3k_game_context:getMarryEveryData("marriageTime") --1474455864 --结婚时间
	local curtime = math.modf(i3k_game_get_time())
	local curMarryTime = curtime - marriageTime
	--local havetime = curMarryTime /60
	--local sec = curMarryTime%60
	--local min = havetime  % 60
	--local hour = math.floor(havetime/60%24)
	--local day = math.floor(havetime/3600/24)
	
	local min=(curMarryTime/60)%60
	local hour=(curMarryTime/60)/60%24
	local day=math.floor((curMarryTime-min*60-hour*3600)/86400)+1
	
	local dayStr = ""
	if day ~=0 then
		dayStr = string.format("%d天",day)
	end
	local hourStr = ""
	if hour ~=0 then
		hourStr = string.format("%d时",hour)
	end
	local minStr = ""
	if min ~=0 then
		minStr = string.format("%d分",min)
	end
	local time = dayStr..hourStr..minStr
	local marriageRole = g_i3k_game_context:getMarryEveryData("marriageRole")   --结婚对象
	local divorcePunishmentTime = i3k_db_marry_rules.divorcePunishmentTime/86400 --离婚冷却时间 （秒） 换算成天
	--local other = g_i3k_game_context:GetTeamOtherMembersProfile() 
	local otherUesrName =marriageRole.name
	self.textLabel:setText(i3k_get_string(689,string.format("%s",divorcePunishmentTime),string.format("%s",otherUesrName),string.format("%s",time)))
	self.marryNameLabel:setText(i3k_get_string(690))	--姻缘称谓：
	
	--计算婚姻称谓
	local hourTime = math.floor(curMarryTime/3600)
	local cnt = #i3k_db_marry_levels
	for i ,v in ipairs(i3k_db_marry_levels) do	
		if hourTime <= v.marryTime or i == cnt then
			self.marryName:setText(v.marryName)
			break
		end
	end
end

function wnd_marry_marryed_lihun:onLihun_btn(sender)
	--立即离婚
	local needTime = math.floor(i3k_db_marry_rules.divorcePunishmentTime/3600/24)
	--local needTime = os.date("%d", g_i3k_get_GMTtime(i3k_db_marry_rules.divorcePunishmentTime))
	local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(-g_BASE_ITEM_COIN)
	if canUseCount >= i3k_db_marry_rules.divorceCost then
		local fun = function (isOk)
			if isOk then
				i3k_sbean.marry_liHun()
			end
		end
		local str = i3k_get_string(845, i3k_db_marry_rules.divorceCost, tonumber(needTime))
		g_i3k_ui_mgr:ShowMessageBox2(str, fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(856, i3k_db_marry_rules.divorceCost))
	end
	
end

-- function wnd_marry_marryed_lihun:onYinYuanBtn()
-- 	--姻缘
-- 	g_i3k_logic:OpenMarried_Yinyuan()
-- 	--self:onCloseUI()
-- end

-- function wnd_marry_marryed_lihun:onskillsBtn()
-- 	--技能
-- 	g_i3k_logic:OpenMarried_skills()
-- 	--self:onCloseUI()
-- end

-- function wnd_marry_marryed_lihun:onAchievementBtn(sender)
-- 	g_i3k_logic:OpenMarried_achievement()
-- end

function wnd_marry_marryed_lihun:release()
	
end

function wnd_marry_marryed_lihun:onHide()
	self:release()
end

function wnd_marry_marryed_lihun:onCloseUI(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Marryed_lihun)
end

function wnd_create(layout)
	local wnd = wnd_marry_marryed_lihun.new()
	wnd:create(layout)
	return wnd
end
