-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_defenceWarBidSure = i3k_class("wnd_defenceWarBidSure", ui.wnd_base)

-- 城战竞标确认
-- [eUIID_DefenceWarBidSure]	= {name = "defenceWarBidSure", layout = "chengzhanjbqr", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_defenceWarBidSure:ctor()

end

function wnd_defenceWarBidSure:configure()
	self:setButtons()
	self:setEditBox()
end


function wnd_defenceWarBidSure:setEditBox()
	local widgets = self._layout.vars
	local callback = function ()
		widgets.inputLabel:hide()
		local text = widgets.editBox:getText()
		if not tonumber(text) then
			widgets.editBox:setText("")
		else
			widgets.editBox:setText(math.floor(tonumber(text)))
		end
	end
	widgets.editBox:addEventListener(callback)
	widgets.editBox:setInputFlag(EDITBOX_INPUT_MODE_DECIMAL)
end

function wnd_defenceWarBidSure:refresh(cfg)
	self._cityID = cfg.id
	local id = cfg.id
	local sectInfo = cfg.king
	local bidState = cfg.bidState
	local myPrice = cfg.myPrice
	local otherBidState = cfg.otherBidState
	self._bidState = bidState
	self._bidTimes = cfg.bidTimes

	self:setCityImages(id)
	self:setLabels(id, sectInfo, bidState, myPrice, otherBidState)
end

function wnd_defenceWarBidSure:onUpdate(dTime)

end

function wnd_defenceWarBidSure:onShow()
	-- local  s = 1
	-- g_i3k_ui_mgr:PopupTipMessage(s)
	-- local level = g_i3k_game_context:GetLevel()
	
	
end

function wnd_defenceWarBidSure:onHide()

end

function wnd_defenceWarBidSure:setButtons()
	local widgets = self._layout.vars
	widgets.imgBK:onClick(self, self.onimgBKBtn)
	widgets.Sure:onClick(self, self.onSureBtn)
	widgets.Close:onClick(self, self.onCloseBtn)
	widgets.City:onClick(self, self.onCityBtn)
end

function wnd_defenceWarBidSure:onimgBKBtn(sender)

end

function wnd_defenceWarBidSure:onSureBtn(sender)
	if self._bidTimes >= i3k_db_defenceWar_cfg.bidTotalTime then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5232))
	end

	local permission = g_i3k_game_context:getDefenceWarSectPermission(g_DEFENCE_WAR_PERMISSION_SIGN_CITY)
	if not permission then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5304)) -- "您没有报名权限"
	end

	local sectLevel = g_i3k_game_context:GetFactionLevel()
	local config = i3k_db_defenceWar_cfg
	if sectLevel < config.factionLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5305, config.factionLvl))-- "帮派等级到达"..config.factionLvl.."可以参与城战")
		return
	end

	local roleLevel = g_i3k_game_context:GetLevel()
	if roleLevel < config.playerLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5306,config.playerLvl))
		return
	end

	local widgets = self._layout.vars
	local text = widgets.editBox:getText()
	if not tonumber(text) or text == "" then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5307))
	end
	local count = tonumber(text) or 0
	local cfg = i3k_db_defenceWar_city[self._cityID]
	if count < cfg.bidLowerPrice then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5308))
	end

	local longjing = g_i3k_game_context:getDragonCrystal()
	if count > longjing then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5309))
	end

	if self._bidState == g_DEFENCE_WAR_BID_EMPTY then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5229))
	end

	if self._bidState == g_DEFENCE_WAR_BID_MINE and self._bidTimes < i3k_db_defenceWar_cfg.bidTotalTime then
		local callback = function(ok)
			if ok then
				i3k_sbean.defenceWarBid(self._cityID, count)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5234, count), callback)
		return
	end


	i3k_sbean.defenceWarBid(self._cityID, count)

end

function wnd_defenceWarBidSure:onCloseBtn(sender)
	self:onCloseUI()
end

function wnd_defenceWarBidSure:onCityBtn(sender)

end

function wnd_defenceWarBidSure:setCityImages(id)
	local widgets = self._layout.vars
	local cfg = i3k_db_defenceWar_city[id]
	widgets.City:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconSign))
end

-- 0无主城池，1没有帮派竞标，2有帮派竞标， 3本帮派已竞标
function wnd_defenceWarBidSure:setLabels(id, sectInfo, bidState, myPrice, otherBidState)
	local widgets = self._layout.vars
	local cfg = i3k_db_defenceWar_city[id]
	--	widgets.no_name:setText("确 定")
	widgets.inputHint:setText(g_i3k_db.i3k_db_get_defence_war_bid_word2(bidState, otherBidState, myPrice))
	widgets.inputLabel:setText(i3k_get_string(5222))
	widgets.cityName:setText(cfg.name)
	widgets.cityName2:setText(cfg.name)
	widgets.size:setText(g_i3k_db.i3k_db_get_defence_war_city_sizeStr_by_grade(cfg.grade))
	local longjing = g_i3k_game_context:getDragonCrystal()
	widgets.price:setText(cfg.bidLowerPrice..i3k_get_string(5310, longjing))
	widgets.state:setText(g_i3k_db.i3k_db_get_defence_war_bid_word(bidState))
	widgets.curSect:setText(sectInfo and (sectInfo.name.."("..math.floor(sectInfo.chiefId / 1000000).."区)" )or i3k_get_string(5311) ) --"未知帮派")
end


function wnd_create(layout, ...)
	local wnd = wnd_defenceWarBidSure.new()
	wnd:create(layout, ...)
	return wnd;
end
