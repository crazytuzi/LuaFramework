module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_princessMarryAddScore = i3k_class("wnd_princessMarryAddScore", ui.wnd_base)
function wnd_princessMarryAddScore:ctor()
    self._scorelist = {}
    self._scoreCooldown = 0
    self._curScorepIndex = 1
    self.needPos = nil
    self.orignPos = nil
	self._widgetsList = {}
end
function wnd_princessMarryAddScore:configure()
    local widget = self._layout.vars
	self._widgetsList = {scoreText = {}, scoreBg = {}}

	for i = 1, 5 do
		self._widgetsList.scoreText[i] = widget['exp'..i]
		self._widgetsList.scoreBg[i] = widget['expbg'..i]
		self._widgetsList.scoreText[i]:setText("")
		self._widgetsList.scoreBg[i]:setVisible(false)
	end
end

function wnd_princessMarryAddScore:refresh(score)
	self:addScoreShow(score)
end

function wnd_princessMarryAddScore:onUpdate(dTime)
    self:onUpdateScoreShow(dTime)
end

function wnd_princessMarryAddScore:addScoreShow(score)
	table.insert(self._scorelist, score)
end

function wnd_princessMarryAddScore:onUpdateScoreShow(dTime)
	if #self._scorelist > 0 then
		self._scoreCooldown = self._scoreCooldown - dTime 
		
		if self._scoreCooldown <= 0 then
			self._widgetsList.scoreBg[self._curScorepIndex]:setOpacity(255)
			self._widgetsList.scoreBg[self._curScorepIndex]:setVisible(true);
			
			if not self.orignPos or not self.needPos then
				local pos = self._widgetsList.scoreBg[self._curScorepIndex]:getPosition()
				self.orignPos = {x = pos.x, y = pos.y}
				self.needPos = {x = pos.x, y = pos.y + self._widgetsList.scoreBg[self._curScorepIndex]:getContentSize().height * 5}
			end
		
			local strDesc = string.format("+%s", self._scorelist[1])		
			self._widgetsList.scoreBg[self._curScorepIndex]:stopAllActions()
			self._widgetsList.scoreText[self._curScorepIndex]:setText(strDesc)
			self._widgetsList.scoreBg[self._curScorepIndex]:setPosition(self.orignPos)			
			--[[local callbackFunc = function ()				
			end--]]
			local move = cc.MoveTo:create(0.8, self.needPos)
			local fadeOut = cc.FadeOut:create(0.4)
			local spawn = cc.Sequence:create(move, fadeOut)
            local seq = cc.Sequence:create(spawn, nil) -- cc.CallFunc:create(callbackFunc) 
			self._widgetsList.scoreBg[self._curScorepIndex]:runAction(seq)
			self._scoreCooldown = 0.2
			table.remove(self._scorelist, 1);
			self._curScorepIndex = self._curScorepIndex % 5 + 1
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_princessMarryAddScore.new();
	wnd:create(layout);
	return wnd;
end
