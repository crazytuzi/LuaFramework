-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------
wnd_hegemonyRewardShow = i3k_class("wnd_hegemonyRewardShow", ui.wnd_base)

function wnd_hegemonyRewardShow:ctor()
end

function wnd_hegemonyRewardShow:configure()
	self._layout.vars.btnClose:onClick(self,self.onCloseUI)
end

function wnd_hegemonyRewardShow:refresh()
	self:showReward()
end

--展示奖励
function wnd_hegemonyRewardShow:showReward()
	
	local rewardList = {
		[1] = { cfg = i3k_db_five_contend_hegemony.winReward,  scroll = self._layout.vars.scrollConds},
		[2] = { cfg = i3k_db_five_contend_hegemony.failReward, scroll = self._layout.vars.scrollConds2},	
	}
	local state = g_i3k_db.i3k_db_get_five_Contend_hegemony_state()
	self._layout.vars.npcName:setText(i3k_get_string(17830))
	if state == g_FIVE_CONTEND_HEGEMONY_SHOW then
		local hegemonyInfo = g_i3k_game_context:getFiveHegemonyManagerInfo()
		if hegemonyInfo and hegemonyInfo.npcInfo then
			local npcCfg = i3k_db_five_contend_hegemony.npcRole
			if hegemonyInfo.npcInfo[1].curBlood > hegemonyInfo.npcInfo[2].curBlood then
				self._layout.vars.npcName:setText(i3k_get_string(17831, npcCfg[hegemonyInfo.npcInfo[1].npcID].name))
			elseif hegemonyInfo.npcInfo[1].curBlood < hegemonyInfo.npcInfo[2].curBlood then
				self._layout.vars.npcName:setText(i3k_get_string(17831, npcCfg[hegemonyInfo.npcInfo[2].npcID].name))
			end
		end
	end
	
	for k, v in ipairs(rewardList) do
		self:setItem(v.scroll, v.cfg)
	end
end

--展示item
function wnd_hegemonyRewardShow:setItem(scroll, infos)
	for i, info in ipairs(infos) do
		
		local item = require("ui/widgets/wjzbjlt")()
		--g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(info.id)
		item.vars.root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(info.id))
		item.vars.imgRwd0:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(info.id,g_i3k_game_context:IsFemaleRole()))
		item.vars.txtRwd0Num:setText("×"..info.count)
		item.vars.btnRwd0:onClick(self,function(id) g_i3k_ui_mgr:ShowCommonItemInfo(info.id) end)
		item.vars.imgLock0:setVisible(info.id > 0)
		scroll:addItem(item)
	end
end

function wnd_create(layout)
	local wnd = wnd_hegemonyRewardShow.new()
	wnd:create(layout)
	return wnd
end
