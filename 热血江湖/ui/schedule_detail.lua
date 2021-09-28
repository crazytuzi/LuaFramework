-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_schedule_detail = i3k_class("wnd_schedule_detail", ui.wnd_base)

local l_tag = 1000

local TYPE_SELF = 1
local TYPE_GROUP = 2

function wnd_schedule_detail:ctor()
	self.scheInfo = {}
end

function wnd_schedule_detail:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	self.sroll = widgets.sroll
	self.sroll:setBounceEnabled(false)
end

function wnd_schedule_detail:refresh(info)
	local widgets = self._layout.vars
	self.scheInfo = info

	widgets.icon_img:setImage(g_i3k_db.i3k_db_get_icon_path(info.iconID))
	widgets.name_txt:setText(info.name)
	local typeNum = info.typeNum
	if typeNum == g_SCHEDULE_TYPE_TOWER_DEFENCE 
	or typeNum == g_SCHEDULE_TYPE_ZHENGYIZHIXIN_2
	or typeNum == g_SCHEDULE_TYPE_ZHENGYIZHIXIN
	or typeNum == g_SCHEDULE_TYPE_GROUP then
		widgets.groupTips:setVisible(info.finishTimes >= info.canActNum)
	end
	
	for i=1, 5 do
		local layer = require("ui/widgets/rcbtct")()
		self.des_txt = layer.vars.des_txt
		if i ==1 then
			self.des_txt:setText(i3k_get_string(619).."<c=green>"..info.lvlLimit.."</c>")
		elseif i==2 then
			if not info.isTime and info.timeStr then
			self.des_txt:setTextColor(g_i3k_get_cond_color(false))
			end 
			self.des_txt:setText(i3k_get_string(620).."<c=red>"..(info.timeStr and info.timeStr or "已结束").."</c>")
		elseif i==3 then
			local groupStr
			if info.isGroup == TYPE_SELF then 
				groupStr = i3k_get_string(623)
			else
				groupStr = i3k_get_string(624)
			end 
			self.des_txt:setText(i3k_get_string(622).."<c=green>"..groupStr.."</c>")
		elseif i==4 then
			local valueNow = info.actValue * info.finishTimes
			local valueTotal = info.actValue * info.actNum
			local actValue = (valueNow <= valueTotal and valueNow or valueTotal) .."/"..valueTotal
			self.des_txt:setText(i3k_get_string(668).."<c=green>"..actValue.."</c>")
		elseif i==5 then
			self.des_txt:setText(i3k_get_string(625))
		end
		self.sroll:addItem(layer)
	end
	if info.desc then
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local gzText = require("ui/widgets/rcbtct2")()
			gzText.vars.text:setText(info.desc )
			ui.sroll:addItem(gzText)
			g_i3k_ui_mgr:AddTask(self, {gzText}, function(ui)
				local textUI = gzText.vars.text
				local size = gzText.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				height = size.height > height and size.height or height
				gzText.rootVar:changeSizeInScroll(ui.sroll, width, height, true)
			end, 1)
		end, 1)
	end
	
	for k,v in ipairs(info.reward) do
		local contImg = widgets[string.format("cont_img%s",k)]
		local iconImg = widgets[string.format("icon_img%s",k)]
		local itemBtn = widgets[string.format("item_btn%s",k)]
		if v.rewardID == 0 then 
			contImg:setVisible(false)
			iconImg:setVisible(false)
			itemBtn:setVisible(false)
		else
			contImg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.rewardID))
			iconImg:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.rewardID,i3k_game_context:IsFemaleRole()))
			itemBtn:onClick(self,self.onItemTips,v.rewardID)
		end 
	end
end

function wnd_schedule_detail:onItemTips(sender,args)
	-- body
	g_i3k_ui_mgr:ShowCommonItemInfo(args)
end

function wnd_create(layout,...)
	local wnd = wnd_schedule_detail.new();
		wnd:create(layout,...)
	return wnd;
end
