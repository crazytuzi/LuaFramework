module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_swordsman_exp_prop = i3k_class("wnd_swordsman_exp_prop", ui.wnd_base)

function wnd_swordsman_exp_prop:ctor()
    self._explist = {}
    self._expcooldown = 0
    self._curexpindex = 1
    self.needPos = nil
    self.orignPos = nil
end

function wnd_swordsman_exp_prop:configure()
	local explist = {}
	explist.root = self._layout.vars.exproot
	local exp1 = self._layout.vars.exp1
	local exp2 = self._layout.vars.exp2
	local exp3 = self._layout.vars.exp3
	local exp4 = self._layout.vars.exp4
	local bg1 = self._layout.vars.bg1
	local bg2 = self._layout.vars.bg2
	local bg3 = self._layout.vars.bg3
	local bg4 = self._layout.vars.bg4
	local expbg1 =  self._layout.vars.expbg1
	local expbg2 =  self._layout.vars.expbg2
	local expbg3 =  self._layout.vars.expbg3
	local expbg4 =  self._layout.vars.expbg4
	explist.exptext = {exp1,exp2,exp3,exp4}
	explist.expbg = {expbg1,expbg2,expbg3,expbg4}
	explist.bg = {bg1,bg2,bg3,bg4}
	for i,v in pairs(explist.exptext) do
		v:setText("");
	end
	for k,v in pairs(explist.expbg) do
		v:setVisible(false)
	end
	self._widgets = {}
	self._widgets.explist = explist
end

function wnd_swordsman_exp_prop:refresh(exp)
	self:addExpShow(exp)
end

function wnd_swordsman_exp_prop:onUpdate(dTime)
	self:onUpdateKillShow(dTime)
end

function wnd_swordsman_exp_prop:addExpShow(exp)-- InvokeUIFunction
	table.insert(self._explist, exp)
end

function wnd_swordsman_exp_prop:onUpdateKillShow(dTime)
	if #self._explist > 0 then
		self._expcooldown = self._expcooldown - dTime
		if self._expcooldown <= 0 then
			self._widgets.explist.expbg[self._curexpindex]:setOpacity(255)
			self._widgets.explist.expbg[self._curexpindex]:setVisible(true);
			if not self.orignPos or not self.needPos then
				local pos = self._widgets.explist.expbg[self._curexpindex]:getPosition()
				self.orignPos = {x = pos.x, y = pos.y}
				self.needPos = {x = pos.x, y = pos.y + self._widgets.explist.expbg[self._curexpindex]:getContentSize().height*2}
			end
			local strDesc = string.format("+%s", self._explist[1])
		    self._widgets.explist.expbg[self._curexpindex]:stopAllActions()
			self._widgets.explist.exptext[self._curexpindex]:setText(strDesc)
			self._widgets.explist.expbg[self._curexpindex]:setPosition(self.orignPos)
			self._widgets.explist.bg[self._curexpindex]:setImage(g_i3k_db.i3k_db_get_icon_path(9402))
			local move = cc.MoveTo:create(0.8, self.needPos)
			local fadeOut = cc.FadeOut:create(0.4)
			local spawn = cc.Sequence:create(move, fadeOut)
			self._widgets.explist.expbg[self._curexpindex]:runAction(spawn)
			self._expcooldown = 0.4
			table.remove(self._explist, 1)
			self._curexpindex = self._curexpindex % 4 + 1
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_swordsman_exp_prop.new();
		wnd:create(layout);
	return wnd;
end
