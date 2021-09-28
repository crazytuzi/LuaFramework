-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_defend_rank = i3k_class("wnd_defend_rank", ui.wnd_base)

local WIDGETS_SHPHBT = "ui/widgets/shphbt"

function wnd_defend_rank:ctor()
	self._info = {}
end

function wnd_defend_rank:configure()
	local widgets = self._layout.vars	
	
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.helpBtn:onClick(self, self.onHelpBtn)
	
	self.scroll = widgets.scroll
	
	self._info = {
		infoRoot 	= widgets.infoRoot,
		btn 		= widgets.btn,
		rankImg 	= widgets.rankImg,
		rankLabel	= widgets.rankLabel,
		nameLabel	= widgets.name,
		powerLabel 	= widgets.powerLabel,
		lvlLabel 	= widgets.lvlLabel,
		scoreLabel	= widgets.scoreLabel,
	}
end

function wnd_defend_rank:refresh(rankData)
	-- TODO ����Լ���������
	self:loadScroll(rankData)
end

function wnd_defend_rank:loadScroll(rankData)
	self.scroll:removeAllChildren()
	for i, e in ipairs(rankData) do
		local node = require(WIDGETS_SHPHBT)()
		self:loadScrollWidget(node.vars, e)
		self.scroll:addItem(node)
	end
	self:loadSelfData()
end

function wnd_defend_rank:loadScrollWidget(widget, data)
	widget.rankImg:setImage()
	widget.rankLabel:setText()
	widget.name:setText()
	widget.lvl:setText()
	widget.power:setText()
	widget.score:setText()
	widget.queryBtn:onClick(self, self.onQuery)
end

function wnd_defend_rank:loadSelfData()

end

function wnd_defend_rank:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(883))
end

function wnd_defend_rank:onQuery(sender, roleId)
	--TODO ��ѯ���������Ϣ
end

function wnd_defend_rank:onUpdate(dTime)

end

function wnd_create(layout)
	local wnd = wnd_defend_rank.new()
	wnd:create(layout)
	return wnd
end
