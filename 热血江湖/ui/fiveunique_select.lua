-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_fiveUnique_select = i3k_class("wnd_fiveUnique_select", ui.wnd_base)

local WIDGET_XGT = "ui/widgets/wjxgt"
local RowitemCount = 5 --每行个数


function wnd_fiveUnique_select:ctor()
	
	self._index = 0
end
function wnd_fiveUnique_select:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	
	self.bossTitle = self._layout.vars.bossTitle 
	
end
function wnd_fiveUnique_select:refresh(info)
	
	

	self:updateOnlineGiftInfo(info)
end


function wnd_fiveUnique_select:updateOnlineGiftInfo(info)
	
	
	self:updateLevelsInfo(info.groupId,info.bestFloor,info )
	
end



function wnd_fiveUnique_select:updateLevelsInfo(id,Index,info)
	
	self._layout.vars.scroll:removeAllChildren()
	
	self.bossTitle:setText(string.format("当前试炼：%s试炼",i3k_db_climbing_tower[info.groupId].name))
	self:appendLevelItem(id,Index,info)
	
	--[[同时选中当前层，退出界面后，试炼界面将选中关卡
	if Index then
		PayGiftList:jumpToListPercent(Index)
	else
		
		if next(info.rewards) ~= nil  then
			PayGiftList:jumpToChildWithIndex(self._index )--跳到最近未领奖的控件
		else
			PayGiftList:jumpToListPercent(0)
		end
		--i3k_log("----------------reward = ",i3k_table_length(info.rewards),self._index )----
	end
	]]
	
	
end

function wnd_fiveUnique_select:appendLevelItem(id,Index,info)
	
	--local PayGiftLevelWidgets = require("ui/widgets/wjxgt")()---btn sharder  lvlLabel
	local count = #i3k_db_climbing_tower_datas[id]
	local children = self._layout.vars.scroll:addChildWithCount(WIDGET_XGT, RowitemCount, Index)
	local level = 0
	for i,v in ipairs(children) do
		level = level + 1
		local target = i3k_db_climbing_tower_datas[id][level].target
		local content = string.format("第%s关",target)
		v.vars.lvlLabel:setText(content)
		--v.vars.sharder:setImage(i3k_db_icons[star_icon[pet.starlvl+1]].path)
		local temp_data = {bestFloor = target,dayTimesBuy = info.dayTimesBuy,_layer = info._layer,groupId = info.groupId,dayTimesUsed = info.dayTimesUsed,fbId=info.fbId,finishFloors = info.finishFloors}
		v.vars.btn:onClick(self, self.onClickSelectLevel,temp_data)
		
	end
	
	
end

----选择关卡
function wnd_fiveUnique_select:onClickSelectLevel(sender,needValue)
	--i3k_log("----------------reward = ",needValue.bestFloor )----
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "onClickSelectAndUpdate", needValue)---(info,widget,fbId)
	g_i3k_ui_mgr:CloseUI(eUIID_FiveUniqueSelect)

end



--[[function wnd_fiveUnique_select:closeBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FiveUniqueSelect)
end--]]

function wnd_create(layout)
	local wnd = wnd_fiveUnique_select.new();
	wnd:create(layout);
	return wnd;
end


