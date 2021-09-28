module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleShowExpCoin = i3k_class("wnd_battleShowExpCoin", ui.wnd_base)
function wnd_battleShowExpCoin:ctor()
    self._explist = {}
	self._offlineList = {}
    self._expcooldown = 0
	self._intervalTime = 0
    self._curexpindex = 1
    self.needPos = nil
    self.orignPos = nil
	self.co = nil
	self._recordExp = nil
end
function wnd_battleShowExpCoin:configure()
    --经验显示相关
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

	self._serverTime = 0
	self._recordExp = g_i3k_game_context:GetExp()
    self._widgets = {}
	self._widgets.explist = explist
    self._exp = 0
end

function wnd_battleShowExpCoin:refresh(iexp)
	self._exp = iexp
	self:addExpShow(iexp)
end

function wnd_battleShowExpCoin:onUpdate(dTime)
	local intervalTime = i3k_db_experience_args.args.timeTips
	local maxSaveExperience = i3k_db_experience_args.args.maxSaveExperience
	local iexp = self._explist[1]
	local nowCoin = g_i3k_game_context:GetExperienceCurExpCoin()
	if nowCoin + self._exp >= maxSaveExperience then --历练海满了
		local nowEXP = g_i3k_game_context:GetExp()
		if self._recordExp ~= nowEXP or g_i3k_game_context:GetLevel() >= #i3k_db_exp then --经验变更，或者满级了
			self._recordExp = nowEXP
			local nowServerTime = i3k_integer(i3k_game_get_time())
			if nowServerTime - self._serverTime >= intervalTime then --CD OK
				self._serverTime = nowServerTime --生效，并重记录CD
				self.co = g_i3k_coroutine_mgr:StartCoroutine(function ()
					g_i3k_coroutine_mgr.WaitForNextFrame()
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(438))
				end)
			end
		end
	end
    self:onUpdateExpShow(dTime)
end

function wnd_battleShowExpCoin:addExpShow(iexp)-- InvokeUIFunction
	table.insert(self._explist,iexp)
end

function wnd_battleShowExpCoin:onUpdateExpShow(dTime)
	if #self._explist > 0 then
		self._expcooldown = self._expcooldown - dTime
		if g_i3k_game_context:GetExperienceCurExpCoin() + self._exp >= i3k_db_experience_args.args.maxSaveExperience then
			return
		end
		if self._expcooldown <= 0 then
			local iexp = self._explist[1]
			self._widgets.explist.expbg[self._curexpindex]:setOpacity(255)
			self._widgets.explist.expbg[self._curexpindex]:setVisible(true);
			if not self.orignPos or not self.needPos then
				local pos = self._widgets.explist.expbg[self._curexpindex]:getPosition()
				self.orignPos = {x = pos.x, y = pos.y}
				self.needPos = {x = pos.x, y = pos.y + self._widgets.explist.expbg[self._curexpindex]:getContentSize().height*2}
			end
			local strDesc = string.format("+%s", iexp)
            self._widgets.explist.expbg[self._curexpindex]:stopAllActions()

			self._widgets.explist.exptext[self._curexpindex]:setText(strDesc)
			self._widgets.explist.expbg[self._curexpindex]:setPosition(self.orignPos)
			local move = cc.MoveTo:create(0.8, self.needPos)
			local fadeOut = cc.FadeOut:create(0.4)
			local callbackfun = function ()
                -- if #self._explist == 0 then
				--     g_i3k_ui_mgr:CloseUI(eUIID_BattleShowExpCoin)
                -- end
			end
			local spawn = cc.Sequence:create(move, fadeOut)
			local seq = cc.Sequence:create(spawn, cc.CallFunc:create(callbackfun))
			self._widgets.explist.expbg[self._curexpindex]:runAction(seq)
			self._expcooldown = 0.2
			table.remove(self._explist,1);
			table.remove(self._offlineList, 1)
			self._curexpindex = self._curexpindex % 5 + 1
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_battleShowExpCoin.new();
		wnd:create(layout);
	return wnd;
end
