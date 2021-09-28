-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_petWakenTips = i3k_class("wnd_petWakenTips",ui.wnd_base)

function wnd_petWakenTips:ctor()
	self._id = 0;
end

function wnd_petWakenTips:configure(...)
	local widgets	= self._layout.vars
	self.lvl		= widgets.lvl;
	self.star		= widgets.star;
	self.feedLvl	= widgets.feedLvl;
	self.wakenBtn	= widgets.wakenBtn
	self.model		= widgets.model;
	self.des		= widgets.des;
	widgets.closeBtn:onClick(self, self.onCloseUI)	
end

function wnd_petWakenTips:refresh(id)
	self:udpateDate(id)
end

function wnd_petWakenTips:onWakenBtn(sender, isCan)
	local petId = g_i3k_game_context:getPetWakening();
	if petId and petId ~= self._id then
		g_i3k_ui_mgr:PopupTipMessage(string.format(i3k_get_string(16837)))
	else
		if isCan and self._id > 0 then
			i3k_sbean.awakeTaskOpen(self._id);
		end
	end
end	

function wnd_petWakenTips:udpateDate(id)
	local cfg = i3k_db_mercenariea_waken_cfg;
	local cfg_data = g_i3k_db.i3k_db_get_pet_cfg(id);
	if cfg and cfg_data then
		self._id= id;
		local level = g_i3k_game_context:getPetLevel(id)
		local star = g_i3k_game_context:getPetStarLvl(id)
		local backfit = g_i3k_game_context:getPetFriendLvl(id);
		self.lvl:setText(level.."/"..cfg.wakenLvl)
		self.lvl:setTextColor(level >= cfg.wakenLvl and g_i3k_get_green_color() or g_i3k_get_red_color())
		self.star:setText(star.."/"..cfg.wakenStar)
		self.star:setTextColor(star >= cfg.wakenStar and g_i3k_get_green_color() or g_i3k_get_red_color())
		self.feedLvl:setText(backfit.."/"..cfg.feedLvl)
		self.feedLvl:setTextColor(backfit >= cfg.feedLvl and g_i3k_get_green_color() or g_i3k_get_red_color())
		self.des:setText(i3k_get_string(16856));
		if level >= cfg.wakenLvl and star >= cfg.wakenStar and backfit >= cfg.feedLvl then
			self.wakenBtn:enable()
			self.wakenBtn:onClick(self, self.onWakenBtn, true);
		else
			self.wakenBtn:disable()
			self.wakenBtn:onClick(self, self.onWakenBtn, false);
		end
		local modelID = i3k_db_mercenariea_waken_property[id] and i3k_db_mercenariea_waken_property[id].modelID or cfg_data.modelID;
		self:showModel(modelID);
	end
end

function wnd_petWakenTips:showModel(modelID)
	local path = i3k_db_models[modelID].path
	local uiscale = i3k_db_models[modelID].uiscale
	self.model:setSprite(path)
	self.model:setSprSize(uiscale)
	self.model:playAction("stand")
	self.model:setRotation(2);
end

function wnd_create(layout)
	local wnd = wnd_petWakenTips.new()
	wnd:create(layout)
	return wnd
end
