-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_shen_bing_talent_info = i3k_class("wnd_shen_bing_talent_info", ui.wnd_base)

function wnd_shen_bing_talent_info:ctor( )
	self.canUseTalentPoint = 1
	self.allPoint = 1
	self.NeedInputPoint = 1
	self.weaponId = 1
	self.talentIndex = 1
end

function wnd_shen_bing_talent_info:configure( )
	local widgets = self._layout.vars
	self.item_bg = widgets.item_bg
	self.item_icon = widgets.item_icon
	self.item_btn = widgets.item_btn
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self,self.onCloseUI)

	self.talent_count = widgets.talent_count
	self.input = widgets.input 
	self.input_name = widgets.input_name
	self.talent_name = widgets.talent_name
	self.precondition = widgets.precondition
	self.talent_effect_now = widgets.talent_effect_now
	self.talent_effect_next = widgets.talent_effect_next
	self.nextEffect = widgets.nextEffect
	self.qianti = widgets.qianti	
	self.verseTxt = widgets.verseTxt
end

function wnd_shen_bing_talent_info:refresh(shenbingId,talentIndex)
	self.shenbingId = shenbingId 
	self.talentIndex = talentIndex
	self:SetShenBingTalentInfo(shenbingId,talentIndex)
end

function wnd_shen_bing_talent_info:SetShenBingTalentInfo(shenbingId,talentIndex)
	local shenbing_talent_data = g_i3k_game_context:GetShenBingTalentData()

	self.allPoint = g_i3k_game_context:GetShenBingAllTalentPoint(shenbingId)

	self.canUseTalentPoint = g_i3k_game_context:GetShenBingCanUseTalentPoint(shenbingId)

	local havePoint = shenbing_talent_data[shenbingId][talentIndex]
	local maxPoint = i3k_db_shen_bing_talent[shenbingId][talentIndex].talentMaxPoint

	local talentName = i3k_db_shen_bing_talent[shenbingId][talentIndex].talentName
	local talentIconId = i3k_db_shen_bing_talent[shenbingId][talentIndex].talentIconId
	local talent_effect_now = i3k_db_shen_bing_talent[shenbingId][talentIndex].talentAttr[havePoint]
	local talent_effect_next = i3k_db_shen_bing_talent[shenbingId][talentIndex].talentAttr[havePoint + 1]
	self.NeedInputPoint = i3k_db_shen_bing_talent[shenbingId][talentIndex].NeedInputPoint

	self.verseTxt:setText(i3k_db_shen_bing_talent[shenbingId][talentIndex].verse)
	self.talent_name:setText(talentName)
	self.item_icon:setImage(g_i3k_db.i3k_db_get_icon_path(talentIconId))
	self.talent_count:setText(havePoint.."/"..maxPoint)
	if self.NeedInputPoint <= self.allPoint then
		self.talent_count:setTextColor(g_i3k_get_green_color())
	else
		self.talent_count:setTextColor(g_i3k_get_red_color())
	end

	if havePoint == 0 then
		self.talent_effect_now:setText("无")
		self.talent_effect_next:setText(talent_effect_next)
	elseif havePoint == maxPoint then
		self.talent_effect_now:setText(talent_effect_now)
		self.talent_effect_next:hide()
		self.nextEffect:hide()
		self.input:disableWithChildren()
		self.input_name:setText("已满")
	else
		self.talent_effect_now:setText(talent_effect_now)
		self.talent_effect_next:setText(talent_effect_next)
	end

	self.input:onClick(self,self.Input)

	local  spr = ""
	spr = "["..self.NeedInputPoint.."]"
	if self.NeedInputPoint == 0 then
		self.qianti:hide()
		self.precondition:hide()
	elseif self.NeedInputPoint <= self.allPoint then
		spr = string.format("<c=green>%s</c>", spr) 
		self.precondition:setText("总投入需要"..spr.."点")
	else
		spr = string.format("<c=red>%s</c>", spr) 
		self.precondition:setText("总投入需要"..spr.."点")
	end
end

function wnd_shen_bing_talent_info:Input(sender)
	if self.NeedInputPoint > self.allPoint then
		g_i3k_ui_mgr:PopupTipMessage("前提不足,无法投入")
	elseif self.canUseTalentPoint <= 0 then
		g_i3k_ui_mgr:PopupTipMessage("点数不足,无法投入")
	else
		i3k_sbean.shen_bing_upTalent(self.shenbingId,self.talentIndex)
	end
end


function wnd_create(layout)
	local wnd = wnd_shen_bing_talent_info.new()
	wnd:create(layout)
	return wnd
end
