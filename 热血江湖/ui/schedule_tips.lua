-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--日程表tips
local DAILY_TASK = 1
local WEEL_TASK = 2
--定期活动提示
local TIMING_ACTIVITY = 3
--结拜活跃奖励
local SWORN_ACTIVITY = 4
--家园宠物心情领奖
local HOME_PET_MOOD = 5
--试炼周常宝箱
local DAILY_ACTIVITY = 6
--定期活动还愿奖励预览
local TIMING_ACTIVITY_PRAY = 7
-------------------------------------------------------

wnd_schedule_tips = i3k_class("wnd_schedule_tips",ui.wnd_base)

function wnd_schedule_tips:ctor()
	
end

function wnd_schedule_tips:configure()
	local widgets = self._layout.vars
	self.closeBtn = widgets.closeBtn
	self.itemDesc_label = widgets.itemDesc_label  --描述
	
    self.itemName_label = widgets.itemName_label   --道具名称*N
	self.item_bg = widgets.item_bg					--bg
	self.item_icon = widgets.item_icon				--icon
	
	
	self.closeBtn:onClick(self, self.closeButton)
	
end

function wnd_schedule_tips:refresh(data, taskFlag, pos)
	if not data then
		return
	end
	if pos then
		self._layout.vars.root:setPosition(pos.x, pos.y)
	end
	local index 
	if data.lvlClass then
	local heroLvl = g_i3k_game_context:GetLevel()
	local init = 0
	local maxLvl = 0
	for i,v in ipairs(data.lvlClass) do
		maxLvl = v
		if heroLvl >=init and heroLvl<= v then
			index = i
			break
		else
			init = v
		end
	end
	if not index then
		return g_i3k_ui_mgr:PopupTipMessage(string.format("当前奖励最大等级为%s请联系公司配置",maxLvl))
	end
	end
	local mustDropId, mayDropId, mayDropNum
	if taskFlag == TIMING_ACTIVITY_PRAY then
		mustDropId = data.mustDropId
		mayDropNum = data.mayDropNum
	else
		mustDropId = data.mustDrop[index].id
		mayDropId = data.mayDrop[index].id
		mayDropNum =data.mayDrop[index].times
	end
	--随机掉落描述
	if taskFlag == DAILY_TASK then
		self.itemDesc_label:setText(i3k_get_string(781,data.actValue,mayDropNum))
	elseif taskFlag == WEEL_TASK then
		self.itemDesc_label:setText(i3k_get_string(16941,data.needPoints,mayDropNum))
	elseif taskFlag == TIMING_ACTIVITY then
		local activity_id = g_i3k_db.i3k_db_get_timing_activity_id()
		local cfgDb = i3k_db_timing_activity.openday[activity_id]
		if activity_id and activity_id > 0 then
			local cfgDb = i3k_db_timing_activity.openday[activity_id]
			self.itemDesc_label:setText(i3k_get_string(cfgDb.rewardsInfo,data.actValue,mayDropNum))
		end
	elseif taskFlag == SWORN_ACTIVITY then
		self.itemDesc_label:setText(i3k_get_string(781, data.actValue, mayDropNum))
	elseif HOME_PET_MOOD == taskFlag then
		self.itemDesc_label:setText(i3k_get_string(781, data.actValue, mayDropNum))
	elseif taskFlag == DAILY_ACTIVITY then
		self.itemDesc_label:setText(i3k_get_string(5496, data.actValue, mayDropNum))
	elseif taskFlag == TIMING_ACTIVITY_PRAY then
		self.itemDesc_label:setText(i3k_get_string(18281))--mayDropNum))
		self._layout.vars.extra_text:setText(i3k_get_string(5905))
	end

	--通过掉落表获得：
	local itemid = i3k_db_drop_cfg[mustDropId].dropid
	local num =  i3k_db_drop_cfg[mustDropId].dropNumMax
	if itemid and num then
		self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
		self.itemName_label:setText(g_i3k_db.i3k_db_get_common_item_name(itemid).."*"..num)
		local name_color = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid))
		self.itemName_label:setTextColor(name_color)
	end
end

function wnd_schedule_tips:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Schedule_Tips)
end

function wnd_schedule_tips:showSpyStoryReward(cfg, isDayReward)
	local itemid = i3k_db_drop_cfg[cfg.reward].dropid
	local num =  i3k_db_drop_cfg[cfg.reward].dropNumMax
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid, i3k_game_context:IsFemaleRole()))
	self.itemName_label:setText(g_i3k_db.i3k_db_get_common_item_name(itemid) .. "*" .. num)
	self.itemDesc_label:setText(i3k_get_string(isDayReward and 18666 or 18667, cfg.score, cfg.randomNum))
	local name_color = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid))
	self.itemName_label:setTextColor(name_color)
end
function wnd_create(layout)
	local wnd = wnd_schedule_tips.new()
		wnd:create(layout)
	return wnd
end
