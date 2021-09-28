-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_arena_rank_best = i3k_class("wnd_arena_rank_best", ui.wnd_base)

local f_rankBestOld

function wnd_arena_rank_best:ctor()
	self._timeTick = 0
end

function wnd_arena_rank_best:configure()
	
end

function wnd_arena_rank_best:refresh(rankBestOld)
	f_rankBestOld = rankBestOld
	local rankBestNow = g_i3k_game_context:GetArenaRankBest()
	self._layout.vars.bestOldLabel:setText(rankBestOld)
	self._layout.vars.bestNowLabel:setText(rankBestNow)
	self._layout.vars.bestRiseLabel:setText(rankBestOld-rankBestNow)
	
	self._layout.vars.okBtn:onClick(self, self.onClose)
	
	
	local light = self._layout.vars.light
	local root = self._layout.vars.root
	root:setScale(0.1)
	root:show()
	local delay = root:createDelayTime(0.1)
	local scaleTo = root:createScaleTo(0.3, 1)
	local scaleBy = root:createScaleBy(0.1, 1.1)
	
	local seq = root:createSequence(delay, scaleTo, scaleBy, scaleBy:reverse())-- cc.CallFunc:create(self.cccc))
	root:runAction(seq)
	
	local scaleBy = light:createScaleBy(0.5, 1.1)
	local seq2 = light:createSequence(scaleBy, scaleBy:reverse())
	local forever = light:createRepeatForever(seq2)
	light:runAction(forever)
	
	
	local rewardTable = {}
	for i,v in pairs(i3k_db_rank_best_reward) do
		table.insert(rewardTable, v)
	end
	table.sort(rewardTable, function (a, b)
			return a.minRank<b.minRank
		end)
	local rewardIndex
	for i,v in pairs(rewardTable) do
		if rankBestNow==v.minRank then
			rewardIndex = i
			break
		elseif rankBestNow>v.minRank then
			if rewardTable[i+1] then
				if rankBestNow<rewardTable[i+1].minRank then
					rewardIndex = i+1
					break
				end
			else
				rewardIndex = i
			end
		end
	end
	local rewardIndexOld
	for i,v in pairs(rewardTable) do
		if f_rankBestOld<=v.minRank then
			rewardIndexOld = i
			break
		end
	end
	
	
	if rewardIndex and rewardIndexOld then
		local oldRankUnder = rewardTable[rewardIndexOld]
		local oldRankHead = rewardTable[rewardIndexOld-1] or oldRankUnder
		local disRank = oldRankUnder.minRank - oldRankHead.minRank
		disRank = disRank==0 and 1 or disRank
		local oldRankDiamond = oldRankUnder.bindDiamond==0 and 0 or (oldRankHead.bindDiamond - oldRankUnder.bindDiamond)*(oldRankUnder.minRank - rankBestOld)/disRank + oldRankUnder.bindDiamond
		local oldRankMoney = oldRankUnder.bindMoney==0 and 0 or (oldRankHead.bindMoney - oldRankUnder.bindMoney)*(oldRankUnder.minRank - rankBestOld)/disRank + oldRankUnder.bindMoney
		
		local nowRankUnder = rewardTable[rewardIndex]
		local nowRankHead = rewardTable[rewardIndex-1] or nowRankUnder
		local disRankNow = nowRankUnder.minRank - nowRankHead.minRank
		disRankNow = disRankNow==0 and 1 or disRankNow
		local nowRankDiamond = (nowRankHead.bindDiamond - nowRankUnder.bindDiamond)*(nowRankUnder.minRank - rankBestNow)/disRankNow + nowRankUnder.bindDiamond
		local nowRankMoney = (nowRankHead.bindMoney - nowRankUnder.bindMoney)*(nowRankUnder.minRank - rankBestNow)/disRankNow + nowRankUnder.bindMoney
		
		local diamondCount = math.ceil(nowRankDiamond) - math.ceil(oldRankDiamond)
		local moneyCount = math.ceil(nowRankMoney) - math.ceil(oldRankMoney)
		if diamondCount~=0 then
			self._layout.vars.diamond:show()
			self._layout.vars.diamondCount:setText(diamondCount)
		else
			self._layout.vars.diamond:hide()
			self._layout.vars.diamondCount:hide()
		end
		if moneyCount~=0 then
			self._layout.vars.money:show()
			self._layout.vars.moneyCount:setText(moneyCount)
		else
			self._layout.vars.money:hide()
			self._layout.vars.moneyCount:hide()
		end
	else
		
	end
end

function wnd_arena_rank_best:onShow()
	
end


function wnd_arena_rank_best:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ArenaRankBest)
end

function wnd_arena_rank_best:onUpdate(dTime)
end

function wnd_create(layout, ...)
	local wnd = wnd_arena_rank_best.new();
		wnd:create(layout, ...);

	return wnd;
end