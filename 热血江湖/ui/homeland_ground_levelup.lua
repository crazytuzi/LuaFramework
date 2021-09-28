--[[-- zengqingfeng
-- 2018/5/18
--eUIID_HomeLandGroundLevelUp --家园土地升级界面
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
wnd_homeland_ground_levelup = i3k_class("homeland_plant_operate", ui.wnd_base)

function wnd_homeland_ground_levelup:ctor()
	self._crop = nil -- 地图上作物的引用
end

function wnd_homeland_ground_levelup:configure()
	local widgets = self._layout.vars

	widgets.countLabel:setText("升级地块")
	widgets.cancel_word:setText("升级")

	widgets.change_btn:onClick(self, self.groundLevelUp)
	widgets.cancel_btn:onClick(self,self.onCloseUI)
	
	self.level_txt = widgets.item_count
end

function wnd_homeland_ground_levelup:onShow()
	
end

function wnd_homeland_ground_levelup:onHide()

end 

function wnd_homeland_ground_levelup:refresh(crop, level)
	if crop then 
		self._crop = crop
	end 
	if not level then 
		level = self._crop._ground.level
	end
	self.level_txt:setText(level)
end 

-- 土地升级
function wnd_homeland_ground_levelup:groundLevelUp()
	if self._crop and self._crop._ground then 
		local homelandCfg = i3k_db_home_land_lvl[g_i3k_game_context:GetHomeLandLevel()]
		if not homelandCfg or self._crop._ground.level >= homelandCfg.landLvlLimit then 
			g_i3k_ui_mgr:PopupTipMessage(string.format("目前家园等级下土地最高%s级", homelandCfg.landLvlLimit))
			return 
		end 
		
		local needItems = self:getLevelUpNeedItems(self._crop._ground.level + 1)
		if g_i3k_game_context:checkNeedCommonItems(needItems, true) then  -- 所需物品数量判断
			i3k_sbean.homeland_ground_uplevel(self._crop._typeid, self._crop._ground.groundIndex, self._crop._ground.level + 1, needItems)	
		end
		
	end 
end 

function wnd_homeland_ground_levelup:getLevelUpNeedItems(targetLevel)
	local cfg = i3k_db_home_land_land_lvl[targetLevel]
	local items = {}
	if cfg and cfg.needItems then 
		for i, value in ipairs(cfg.needItems) do 
			items[value.itemID] = value.itemCount
		end
	end
	return items
end 

function wnd_create(layout,...)
	local wnd = wnd_homeland_ground_levelup.new()
	wnd:create(layout,...)
	return wnd
end




--]]
