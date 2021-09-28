-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_defenceWarBid = i3k_class("wnd_defenceWarBid", ui.wnd_base)

-- 城战竞标
-- [eUIID_DefenceWarBid]	= {name = "defenceWarBid", layout = "chengzhanjb", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_defenceWarBid:ctor()
	self._selectID = nil -- 选中的城池id
end

function wnd_defenceWarBid:configure()
	self:setButtons()
	self:setLabels()
end

function wnd_defenceWarBid:refresh(cityBid, kings, myPrice, bidTimes)
	self._cityBid = cityBid
	self._kings = kings
	self._myPrice = myPrice
	self._bidTimes = bidTimes
	self:setScrolls()
end

function wnd_defenceWarBid:onUpdate(dTime)

end

function wnd_defenceWarBid:onShow()
	self:selectScrollItem(1) -- 默认选中第一个
end

function wnd_defenceWarBid:onHide()

end

function wnd_defenceWarBid:setScrolls()
	local widgets = self._layout.vars
	local citys = i3k_db_defenceWar_city
	self:setScroll_scroll(citys)
end


-- TODO
function wnd_defenceWarBid:setScroll_scroll(list)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/chengzhanjbt")()
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconSign))
		ui.vars.name:setText(v.name)
		local imgID = self:getBidStatusImg(k)
		if imgID then
			ui.vars.doneImg:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
			ui.vars.doneImg:setVisible(true)
		else
			ui.vars.doneImg:setVisible(false)
		end
		ui.vars.selectImg:setVisible(false)
		ui.vars.City:onClick(self, self.onCityBtn, k)
		scroll:addItem(ui)
	end
end

function wnd_defenceWarBid:getBidStatusImg(id)
	local bidState = self._cityBid[id]
	local t =
	{
		[g_DEFENCE_WAR_BID_EMPTY] = 7049,
		[g_DEFENCE_WAR_BID_NONE] = nil,
		[g_DEFENCE_WAR_BID_OTHER] = nil,
		[g_DEFENCE_WAR_BID_MINE] = 7048,
	}
	return t[bidState]
end


function wnd_defenceWarBid:setLabels()
	local widgets = self._layout.vars
	widgets.desc:setText(i3k_get_string(5214))
end

function wnd_defenceWarBid:setImages()
	local widgets = self._layout.vars
	--	widgets.title:setImage()
end

function wnd_defenceWarBid:setButtons()
	local widgets = self._layout.vars
	widgets.Bid:onClick(self, self.onBidBtn)
	widgets.Help:onClick(self, self.onHelpBtn)
	widgets.Close:onClick(self, self.onCloseBtn)
end


function wnd_defenceWarBid:selectScrollItem(id)
	self._selectID = id
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		v.vars.selectImg:setVisible(id == k)
	end
end

function wnd_defenceWarBid:onCityBtn(sender, index)
	self:selectScrollItem(index)
end

function wnd_defenceWarBid:onBidBtn(sender)
	local id = self._selectID
	local cityBid = self._cityBid
	local sects = self._kings
	local myPrice = self._myPrice
	local otherBidState = 0 -- 此字段非0，表示我已经竞标了其它城，id为该城id
	for k, v in pairs(cityBid) do
		if id ~= k and v == g_DEFENCE_WAR_BID_MINE then
			otherBidState = k
		end
	end
	local cityCfg =
	{
		id =  id,
		bidState = cityBid[id],
		king = sects and sects[id] or nil,
		myPrice = myPrice,
		otherBidState = otherBidState,
		bidTimes = self._bidTimes
	}

	g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarBidSure)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarBidSure, cityCfg)
end

function wnd_defenceWarBid:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(5327, i3k_db_defenceWar_cfg.joinCnt))
end

function wnd_defenceWarBid:onCloseBtn(sender)
	self:onCloseUI()
end


function wnd_create(layout, ...)
	local wnd = wnd_defenceWarBid.new()
	wnd:create(layout, ...)
	return wnd;
end
