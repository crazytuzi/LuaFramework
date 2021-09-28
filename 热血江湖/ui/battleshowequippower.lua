module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleShowEquipPower = i3k_class("wnd_battleShowEquipPower", ui.wnd_base)
function wnd_battleShowEquipPower:ctor()
    self._explist = {}
    self._expcooldown = 0
    self._curexpindex = 1
    self.needPos = nil
    self.orignPos = nil
end
function wnd_battleShowEquipPower:configure()
    --装备能量显示相关
	local explist = {}
	explist.exptext =
	{
		self._layout.vars.exp1,
		self._layout.vars.exp2,
		self._layout.vars.exp3,
		self._layout.vars.exp4,
		self._layout.vars.exp5,
	}
	explist.expbg =
	{
		self._layout.vars.expbg1,
		self._layout.vars.expbg2,
		self._layout.vars.expbg3,
		self._layout.vars.expbg4,
		self._layout.vars.expbg5,
	}
	for i = 1, 5 do
		explist.exptext[i]:setText("")
		explist.expbg[i]:setVisible(false)
	end
    self._widgets = {}
	self._widgets.explist = explist
end

function wnd_battleShowEquipPower:refresh(iexp)
	self:addExpShow(iexp)
end

function wnd_battleShowEquipPower:onUpdate(dTime)
    self:onUpdateExpShow(dTime)
end

-- self call function
function wnd_battleShowEquipPower:addExpShow(iexp)
	table.insert(self._explist, iexp)
end

function wnd_battleShowEquipPower:onUpdateExpShow(dTime)
	if #self._explist > 0 then
		self._expcooldown = self._expcooldown - dTime
		if self._expcooldown <= 0 then
			local iexp = self._explist[1]
			self._widgets.explist.expbg[self._curexpindex]:setOpacity(255)
			self._widgets.explist.expbg[self._curexpindex]:setVisible(true);
			if not self.orignPos or not self.needPos then
				local pos = self._widgets.explist.expbg[self._curexpindex]:getPosition()
				self.orignPos = {x = pos.x, y = pos.y}
				self.needPos = {x = pos.x, y = pos.y + self._widgets.explist.expbg[self._curexpindex]:getContentSize().height*5}
			end
			local strDesc = string.format("+%s", iexp)

			self._widgets.explist.expbg[self._curexpindex]:stopAllActions()
			self._widgets.explist.exptext[self._curexpindex]:setText(strDesc)
			self._widgets.explist.expbg[self._curexpindex]:setPosition(self.orignPos)
			local callbackFunc = function ()

			end
			local move = cc.MoveTo:create(0.8, self.needPos)
			local fadeOut = cc.FadeOut:create(0.4)
			local spawn = cc.Sequence:create(move, fadeOut)
            local seq = cc.Sequence:create(spawn, cc.CallFunc:create(callbackFunc) )
            --cc.Spawn的几个动作是同步执行的，cc.Sequence则是顺序执行各个动作的.
            --使用这样的嵌套动作，能在播放完 Spawn 动作之后执行关闭界面的操作
			self._widgets.explist.expbg[self._curexpindex]:runAction(seq)
			self._expcooldown = 0.2
			table.remove(self._explist,1);
			self._curexpindex = self._curexpindex % 5 + 1
		end
	end
end



function wnd_create(layout)
	local wnd = wnd_battleShowEquipPower.new();
		wnd:create(layout);
	return wnd;
end
