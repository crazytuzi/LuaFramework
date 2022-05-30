local ZhenShenModel = {}

function ZhenShenModel.setRestNum(num)
	local fubenData = ZhenShenModel.getFubenData()
	fubenData.lastFreeTimes = num
end

function ZhenShenModel.getRestNum()
	local fubenData = ZhenShenModel.getFubenData()
	return fubenData.lastFreeTimes
end

function ZhenShenModel.getBuyCnt()
	local fubenData = ZhenShenModel.getFubenData()
	return fubenData.todayBuyTimes
end

function ZhenShenModel.getCost()
	local fubenData = ZhenShenModel.getFubenData()
	return fubenData.buyMoney
end

function ZhenShenModel.getGold()
	return game.player.m_gold
end

function ZhenShenModel.getFubenData()
	return ZhenShenModel.rawData
end

function ZhenShenModel.refreshGold(num)
	if num ~= nil and game.player.m_gold ~= num then
		game.player.m_gold = num
		PostNotice(NoticeKey.CommonUpdate_Label_Gold)
	end
end

function ZhenShenModel.buySuccess(data)
	dump("buySuccess")
	dump(data)
	local fubenData = ZhenShenModel.getFubenData()
	fubenData.lastFreeTimes = data.surplusCnt
	fubenData.todayBuyTimes = data.buyCnt
	ZhenShenModel.refreshGold(data.gold)
	fubenData.buyMoney = data.spend
end

function ZhenShenModel.startFight(fmtStr, fbInfo, _fbId, npc, callBackFunc, _errback)
	RequestHelper.challengeFuben.rbPveBattle({
	id = _fbId,
	fmt = fmtStr,
	npc = npc,
	errback = function(data)
		if data.errCode ~= nil and data.errCode ~= 0 then
			dump(data)
			ResMgr.showErr(data.errCode)
		end
	end,
	callback = function(data)
		dump(data)
		if data["0"] ~= "" then
			if _errback ~= nil then
				_errback()
			end
			if data.errCode ~= nil and data.errCode ~= 0 then
				dump(data)
				ResMgr.showErr(data.errCode)
			end
		else
			local scene = require("game.Challenge.HuoDongBattleScene").new({
			fubenid = _fbId,
			sysId = fbInfo.sys_id,
			npcLv = 1,
			fmt = fmtStr,
			zhanli = data["8"] or 0,
			viewType = CHALLENGE_TYPE.ZHENSHEN_VIEW,
			data = data,
			errback = function(isError)
				pop_scene()
			end,
			endFunc = function(bIsWin)
				pop_scene()
				pop_scene()
				if bIsWin == true then
					local times = ZhenShenModel.getRestNum() - 1
					ZhenShenModel.setRestNum(times)
					if callBackFunc ~= nil then
						callBackFunc()
					end
				end
			end
			})
			push_scene(scene)
		end
	end
	})
end

function ZhenShenModel.initData(data)
	ZhenShenModel.rawData = data
	if data.gold ~= nil then
		game.player.m_gold = data.gold
	end
end

function ZhenShenModel.getFubenList()
	return ZhenShenModel.rawData.realBodyFBVOList
end

return ZhenShenModel