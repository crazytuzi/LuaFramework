-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_defenceWarBidRes = i3k_class("wnd_defenceWarBidRes", ui.wnd_base)

-- 城战竞标公示
-- [eUIID_DefenceWarBidRes]	= {name = "defenceWarBidRes", layout = "chengzhangs", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_defenceWarBidRes:ctor()

end

function wnd_defenceWarBidRes:configure()
	self:setButtons()
	self._defaultCity = 1
end

function wnd_defenceWarBidRes:refresh(result, cityInfo)
	self._result = result
	self._cityInfo = cityInfo
	self:setScrolls()
	self:setFirstClick()
end

function wnd_defenceWarBidRes:onUpdate(dTime)

end

function wnd_defenceWarBidRes:onShow()

end

function wnd_defenceWarBidRes:onHide()

end

function wnd_defenceWarBidRes:setFirstClick()
	self:onCityBtn(nil, self._defaultCity)
end

function wnd_defenceWarBidRes:setScrolls()
	local widgets = self._layout.vars
	local citys = i3k_db_defenceWar_city
	self:setScroll_leftScroll(citys)
	local cityID = self._defaultCity
	self:setScroll_scroll(cityID)
end


-- TODO
function wnd_defenceWarBidRes:setScroll_scroll(cityID)
	local list = self._result[cityID] and self._result[cityID].rank or {}
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/chengzhangst2")()
		ui.vars.index:setText(k)
		ui.vars.sectName:setText(v.overView.name)
		-- 角色id / 1000000 为区服id
		local chiefServerID = math.floor(v.overView.chiefId / 1000000)
		ui.vars.server:setText(chiefServerID.."区")
		ui.vars.price:setText(v.price)
		scroll:addItem(ui)
	end
end

function wnd_defenceWarBidRes:setScroll_leftScroll(list)
	local widgets = self._layout.vars
	local scroll = widgets.leftScroll
	scroll:removeAllChildren()
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/chengzhangst1")()
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconBattle))
		ui.vars.name:setText(v.name)
		local imgID = self:getBidStatusImg(k)
		if imgID then
			ui.vars.doneImg:setImage(g_i3k_db.i3k_db_get_icon_path(imgID))
			ui.vars.doneImg:setVisible(true)
		else
			ui.vars.doneImg:setVisible(false)
		end
		ui.vars.City:onClick(self, self.onCityBtn, k)
		scroll:addItem(ui)
	end
end

-- 0无主城池，1没有帮派竞标，2有帮派竞标，3本帮派已中标
function wnd_defenceWarBidRes:getBidStatusImg(id)
	local bidState = self._cityInfo[id]
	local t =
	{
		[g_DEFENCE_WAR_BID_EMPTY] = 7049,
		[g_DEFENCE_WAR_BID_NONE] = 7050, -- 流拍
		[g_DEFENCE_WAR_BID_OTHER] = nil,
		[g_DEFENCE_WAR_BID_MINE] = 7046,
	}
	return t[bidState]
end


function wnd_defenceWarBidRes:setButtons()
	local widgets = self._layout.vars
	widgets.Close:onClick(self, self.onCloseBtn)
	widgets.Help:onClick(self, self.onHelpBtn)
end

function wnd_defenceWarBidRes:selectScrollItem(id)
	local widgets = self._layout.vars
	local scroll = widgets.leftScroll
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		v.vars.selectImg:setVisible(id == k)
	end
end

function wnd_defenceWarBidRes:setCityInfo(id)
	-- local citys = i3k_db_defenceWar_city
	-- local rewards = citys[id].captureReward
end

function wnd_defenceWarBidRes:onCityBtn(sender, index)
	self:selectScrollItem(index)
	self:setCityInfo(index)
	self:setScroll_scroll(index)
end



function wnd_defenceWarBidRes:onCloseBtn(sender)
	self:onCloseUI()
end

function wnd_defenceWarBidRes:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp("帮助信息")
end


function wnd_create(layout, ...)
	local wnd = wnd_defenceWarBidRes.new()
	wnd:create(layout, ...)
	return wnd;
end
