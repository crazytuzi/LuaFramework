------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_world_cup_yazhu = i3k_class("wnd_world_cup_yazhu",ui.wnd_base)

local T1_WIDGETS = "ui/widgets/shijiebeiyzt"
local count = #i3k_db_world_cup_wager
local wagerCoin = i3k_db_world_cup_other.wagerCoin

function wnd_world_cup_yazhu:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.coin:setText('x'..wagerCoin)
end

function wnd_world_cup_yazhu:refresh(countryId)
	self.countryId = countryId or 1
	local widgets = self._layout.vars
	widgets.country:setText(string.format(i3k_db_string[1409], i3k_db_world_cup_team[self.countryId].name))
	self.choices = widgets.content:addChildWithCount(T1_WIDGETS, 1, count, true)
	for i=1,count do
		local tempComp = self.choices[i].vars
		local tempCfg = i3k_db_world_cup_wager[i]
		tempComp.rank:setText(tempCfg.des)
		tempComp.date:setText(string.format(i3k_db_string[1410], tempCfg.data))
		tempComp.coin:setText('x'..tempCfg.reward)
		tempComp.rank = tempCfg.rank
		tempComp.btn:onClick(self, self.onChangeBtnClick, tempComp)
	end
	widgets.wagerBtn:onClick(self, self.onWagerBtnClick)
end

function wnd_world_cup_yazhu:onChangeBtnClick(sender, comp)
	local isCheck = comp.check:isVisible()
	for i = 1, count do
		self.choices[i].vars.check:setVisible(false)
	end
	comp.check:setVisible(not isCheck)
end

function wnd_world_cup_yazhu:onWagerBtnClick()
	g_i3k_ui_mgr:ShowMessageBox2(i3k_db_string[1411],function (bValue)
		if bValue then
			self:CheckIsSelect()
		end
	end)
end

--检测是否选中押注方式
function wnd_world_cup_yazhu:CheckIsSelect()
	for i = 1,count do
		if	self.choices[i].vars.check:isVisible() == true then
			self.selectId = i
			break
		end
	end
	if self.selectId then
		if g_i3k_game_context:GetCommonItemCount(g_BASE_ITEM_DIAMOND) >= wagerCoin then
			self:CheckBetConflict()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_db_string[1412])
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_db_string[1413])
	end
end

--检测是否和其他押注的冲突
function wnd_world_cup_yazhu:CheckBetConflict()
	if  g_i3k_game_context:getWorldCup() then
		for _,v in pairs(g_i3k_game_context:getWorldCup()) do
			if v.countryId ~= self.countryId and v.record == i3k_db_world_cup_wager[self.selectId].rank and i3k_db_world_cup_wager[self.selectId].repeatLimit == 1 then
				g_i3k_ui_mgr:PopupTipMessage(string.format(i3k_db_string[1415],i3k_db_world_cup_team[v.countryId].name,i3k_db_world_cup_wager[self.selectId].des))
				return;
			end
		end
	end
	--所有检查已通过
	i3k_sbean.world_cup_bet(self.countryId, i3k_db_world_cup_wager[self.selectId].rank)
	self:onCloseUI()
end

-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_world_cup_yazhu.new()
	wnd:create(layout,...)
	return wnd
end
