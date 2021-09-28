-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedSpiritShows = i3k_class("wnd_steedSpiritShows", ui.wnd_base)

local WIDGET_ZQQZHHT = "ui/widgets/zqqzhht"

local BaseMode = 1
local AddMode = 2 

function wnd_steedSpiritShows:ctor()
	self._AllSpiritID = {}
	self._showMode = 0
end

function wnd_steedSpiritShows:configure()
	local widgets = self._layout.vars;
	
	self.scroll = widgets.scroll
	self.isAtuoSkin = widgets.isAtuoSkin;
	self.isHideSkin = widgets.isHideSkin;
	self._showMode = BaseMode
	widgets.baseSkinBtn:onClick(self, self.onChangeShowMode, BaseMode)
	widgets.addSkinBtn:onClick(self, self.onChangeShowMode, AddMode)
	widgets.baseSkinBtn:stateToPressed()
	widgets.addSkinBtn:stateToNormal()
	widgets.isAtuoSkinBtn:onClick(self, self.onIsAtuoSkin)
	widgets.isHideSkinBtn:onClick(self, self.onIsHideSkin)
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_steedSpiritShows:refresh()
	local widgets = self._layout.vars
	self._AllSpiritID[BaseMode], self._AllSpiritID[AddMode] = g_i3k_db.i3k_db_get_all_steed_spiritID()
	if not next(self._AllSpiritID[AddMode]) then
		widgets.addSkinBtn:hide()
	end
	widgets.addSkinRed:setVisible(g_i3k_game_context:canUnlockNewSpirit())
	self:loadIsAutoIcon(g_i3k_game_context:getSteedSpiritIsAutoChange())
	self:loadIsHideIcon(g_i3k_game_context:getSteedSpiritIsHide())
	self:loadShowsScroll()
end

function wnd_steedSpiritShows:loadIsAutoIcon(isAuto)
	self.isAtuoSkin:setVisible(isAuto)
end

function wnd_steedSpiritShows:loadIsHideIcon(isHide)
	self.isHideSkin:setVisible(isHide)
end

function wnd_steedSpiritShows:loadShowsScroll()
	local curShowID = g_i3k_game_context:getSteedSpiritCurShowID()
	local showIDs = g_i3k_game_context:getSteedSpiritShowIDs()
	self.scroll:removeAllChildren()
	for _, v in ipairs(self._AllSpiritID[self._showMode]) do
		local node = require(WIDGET_ZQQZHHT)()
		self:loadScrollWiget(node.vars, v, i3k_db_steed_fight_spirit_show[v], curShowID, showIDs)
		self.scroll:addItem(node)
	end
end

function wnd_steedSpiritShows:loadScrollWiget(widget, i, e, curShowID, showIDs)
	widget.name:setText(e.showName)
	local mcfg = i3k_db_models[e.UIModelID];
	if mcfg then
		widget.modle:setSprite(mcfg.path);
		widget.modle:setSprSize(mcfg.uiscale);
		widget.modle:playAction(i3k_db_steed_fight_base.defaultAction)
	end
	local isHave = showIDs[i] ~= nil
	if self._showMode == BaseMode then
		if not isHave then
			if i3k_db_steed_fight_spirit_rank[e.unlockRank+1] then
				widget.lockTxt:setText(i3k_get_string(1288, i3k_db_steed_fight_spirit_rank[e.unlockRank+1].rankDesc))
			end	
		else
			widget.useText:setText(i == curShowID and i3k_get_string(1289) or i3k_get_string(1290))
			if i == curShowID then
				widget.useBtn:disableWithChildren()
			else
				widget.useBtn:enableWithChildren()
				widget.useBtn:onClick(self, self.onUseBtn, i)
			end
		end
		widget.lockTxt:setVisible(not isHave)
		widget.useBtn:setVisible(isHave)
	end
	
	if self._showMode == AddMode then
		widget.lockTxt:hide()
		widget.useBtn:setVisible(isHave)
		widget.unlockBtn:setVisible(not isHave)
		if not isHave then
			widget.unlockBtn:onClick(self, self.onUnlock, i)
		else
			widget.useText:setText(i == curShowID and i3k_get_string(1289) or i3k_get_string(1290))
			if i == curShowID then
				widget.useBtn:disableWithChildren()
			else
				widget.useBtn:enableWithChildren()
				widget.useBtn:onClick(self, self.onUseBtn, i)
			end
		end
	end
end

function wnd_steedSpiritShows:onUseBtn(sender, showID)
	i3k_sbean.horse_spirit_setshow_request(showID)
end

function wnd_steedSpiritShows:onIsAtuoSkin(sender)
	i3k_sbean.horse_spirit_showauto_request(g_i3k_game_context:getSteedSpiritIsAutoChange() and 0 or 1)
end


function wnd_steedSpiritShows:onIsHideSkin(sender)
	i3k_sbean.horse_spirit_hide_reqest(g_i3k_game_context:getSteedSpiritIsHide() and 0 or 1)
end

function wnd_steedSpiritShows:onChangeShowMode(sender, mode)
	local widgets = self._layout.vars
	if self._showMode ~= mode then
		self._showMode = mode
		if mode == BaseMode then
			widgets.baseSkinBtn:stateToPressed()
			widgets.addSkinBtn:stateToNormal()
		end
		
		if mode == AddMode then
			widgets.baseSkinBtn:stateToNormal()
			widgets.addSkinBtn:stateToPressed()
		end
		self:loadShowsScroll()
	end
end

function wnd_steedSpiritShows:onUnlock(sender, showID)
	g_i3k_ui_mgr:OpenUI(eUIID_UnlockSteedAddSpirit)
	g_i3k_ui_mgr:RefreshUI(eUIID_UnlockSteedAddSpirit, showID)
end

function wnd_create(layout)
	local wnd = wnd_steedSpiritShows.new();
		wnd:create(layout);
	return wnd;
end