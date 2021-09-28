-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_factionBoss = i3k_class("wnd_factionBoss", ui.wnd_base)

function wnd_factionBoss:ctor()
    self._curIndex = 0;
    self._index = 1
    self._config = i3k_db_faction_boss_donation
end

function wnd_factionBoss:configure()
    self.ui = self._layout.vars
    self.ui.upBtn:onClick(self,self.showUp)
    self.ui.downBtn:onClick(self,self.showDown)
    self.ui.closeBtn:onClick(self,self.onClose)
	self.ui.callBossBtn:onClick(self,self.callBoss)
	self.ui.openTime:setText(i3k_get_activity_open_time_desc(i3k_db_faction_garrison.bossOpenTimes))
	self.ui.help:onClick(self,function ()
		local config = self._config[self._index]
		g_i3k_ui_mgr:ShowHelp(
			i3k_get_string(
				16663,
				config.needRatio / 100,
				i3k_db_faction_garrison.factionBoss.limitTime,
				i3k_db_faction_garrison.factionBoss.needTime,
				i3k_db_faction_garrison.factionBoss.awardNeedLvl
			)
		)
	end)
end

function wnd_factionBoss:refresh(data)
    self._data = data
    --self._curIndex = data.id
    --self._index = data.id
    self:show()
end

function wnd_factionBoss:showDown ()
    self._index = (self._index) % (#self._config) + 1
    self:show()
end

function wnd_factionBoss:showUp ()
    self._index = (self._index - 2) % (#self._config) + 1
    self:show()
end

function wnd_factionBoss:show ()
	local config = self._config[self._index]
	self.ui.callDay:setText(i3k_get_activity_open_desc(i3k_db_faction_garrison.factionBoss.openDay))
	self.ui.bgImage:setImage(g_i3k_db.i3k_db_get_icon_path(config.showModelID))
    --ui_set_hero_model(self.ui.bossModule, config.showModelID)

    self.ui.bossName:setText(config.showBossName)
    self.ui.bossLevel:setText("Lv" .. config.showLvl)

    for k, v in ipairs(config.dropShow) do
        self.ui["dropbg" .. k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v))
        self.ui["drop" .. k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v,i3k_game_context:IsFemaleRole()))
        self.ui["dropbtn"..k]:onClick(self,function ()
    		g_i3k_ui_mgr:ShowCommonItemInfo(v)
    	end)
    end

    for  k, v in ipairs(config.donationCfg) do
        self.ui["propnum" .. k]:setText(v.getPower)
		self.ui["prophave" .. k]:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.itemID))
        self.ui["propbg" .. k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemID))
        self.ui["prop" .. k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemID,i3k_game_context:IsFemaleRole()))
        self.ui["propbtn"..k]:onClick(self,function ()
            -- if self._curIndex ~= self._index then
            --     g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16650))
            --     return
            -- end

			local _useTimes = self._data.itemUseTimes[v.itemID] or 0

            g_i3k_ui_mgr:OpenUI(eUIID_FactionGarrisonDonate)
            g_i3k_ui_mgr:RefreshUI(
				eUIID_FactionGarrisonDonate, v.itemID, 
				self._data.process[self._index] or 0, 
				v.getSectMoney, 
				{
					bossId = self._index, 
					config = config,
					power = v.getPower, 
					useTimes = _useTimes, 
					limitTimes = v.limitCount
				}
			)
    	end)
		
		-- if self._curIndex ~= self._index then
		-- 	self.ui["propbg"..k]:disableWithChildren()
		-- else
		-- 	self.ui["propbg"..k]:enableWithChildren()
		-- end
    end

    local process = self._data.process[self._index] or 0
    local needPower = config.needPower
    self.ui.bossProcessNum:setText(process .. "/" .. needPower)
    self.ui.bossProcessBar:setPercent(process / needPower * 100)
	
	-- if self._curIndex ~= self._index then
	-- 	self.ui.callBossBtn:disableWithChildren()
	-- else
	-- 	self.ui.callBossBtn:enableWithChildren()
	-- end
end

function wnd_factionBoss:callBoss()
	local pos = g_i3k_game_context:GetSectPosition()
	if i3k_db_faction_power[pos] and i3k_db_faction_power[pos].callBoss ~= 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16651))
		return
	end
	
	-- if self._curIndex ~= self._index then
	-- 	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16650))
	-- 	return
	-- end

	if not i3k_get_is_in_open_time(i3k_db_faction_garrison.bossOpenTimes) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16652))
		return
	end
	
	if not i3k_get_activity_is_open(i3k_db_faction_garrison.factionBoss.openDay) then
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16652))
		return
    end
	
	if self._data.dayBossTimes >= i3k_db_faction_garrison.factionBoss.limitTime then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16658))
		return
	end
	local config = self._config[self._index]
	
	local process = self._data.process[self._index] or 0
	local needPower = config.needPower
	
	if process / needPower < config.needRatio / 10000 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16653))
		return
	end
		
	if process < needPower then
		local costPower = needPower - process
		local costDiamond = math.ceil(costPower / 100) * config.consumeDiamond
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16654,costDiamond),function (isOk)
			if isOk then
				i3k_sbean.request_sect_zone_boss_open_req (self._index, costDiamond)
			end
		end)
		return
	end
 	i3k_sbean.request_sect_zone_boss_open_req (self._index, 0)
end

function wnd_factionBoss:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_FactionBoss)
end

function wnd_create(layout, ...)
	local wnd = wnd_factionBoss.new()
	wnd:create(layout, ...)
	return wnd
end
