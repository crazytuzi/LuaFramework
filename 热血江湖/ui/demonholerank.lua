-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_demonhole_rank = i3k_class("wnd_demonhole_rank",ui.wnd_base)

local CUR_FLOOR_STATE	= 1 --当前层
local ALL_STATE			= 2 --所有
local WidgetFbpht = "ui/widgets/fmdpht"
local z_rankImg = {2718, 2719, 2720} --1,2,3 排名图片

function wnd_demonhole_rank:ctor()
	self._type = 1
	self._curFloor = {}
	self._total	= {}
end

function wnd_demonhole_rank:configure()
	local widgets = self._layout.vars
	
	self.scroll = widgets.scroll
	widgets.curFloorBtn:onClick(self, self.onCurFloor)
	widgets.allBtn:onClick(self, self.onAll)
	self.addExp = widgets.addExp
	
	self.scroll = widgets.scroll
	self.typeButton = {widgets.curFloorBtn, widgets.allBtn}
	self.typeButton[1]:stateToPressed()
	for i, e in ipairs(self.typeButton) do
		e:onClick(self, self.onTypeChanged, i)
	end
	
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

-- state：1本层战况，2总战况
function wnd_demonhole_rank:refresh(curFloor, total, addExp, state)
	self._curFloor = curFloor
	self._total = total
	self._type = state
	self:updateScrollData(self._type == CUR_FLOOR_STATE and self._curFloor or self._total)
	self:updateBtnState()
	self.addExp:setText("获得总经验："..addExp)
end

function wnd_demonhole_rank:onTypeChanged(sender, tag)
	self:changeStateImpl(tag)
end

function wnd_demonhole_rank:changeStateImpl(state)
	if self._type ~= state then
		self._type = state
		self:updateScrollData(self._type == CUR_FLOOR_STATE and self._curFloor or self._total)
		self:updateBtnState()
	end
end

function wnd_demonhole_rank:updateScrollData(rank)
	self.scroll:removeAllChildren()
	for i, e in ipairs(rank) do
		local roleOverview = e.role
		local node = require(WidgetFbpht)()
		local widgets = node.vars
		if i <= 3 then
			widgets.rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(z_rankImg[i]))
		else
			widgets.rankLabel:setText(i..".")
		end
		widgets.rankImg:setVisible(i<=3)
		widgets.rankLabel:setVisible(i>3)
		widgets.name:setText(roleOverview.name)
		widgets.lvlLabel:setText(roleOverview.level)
		widgets.killNum:setText(e.kills)
		widgets.killedNum:setText(e.bekills)
		self.scroll:addItem(node)
	end
end

function wnd_demonhole_rank:updateBtnState()
	for _, e in ipairs(self.typeButton) do
		e:stateToNormal()
	end
	self.typeButton[self._type]:stateToPressed()
end

function wnd_create(layout)
	local wnd = wnd_demonhole_rank.new()
	wnd:create(layout)
	return wnd
end
