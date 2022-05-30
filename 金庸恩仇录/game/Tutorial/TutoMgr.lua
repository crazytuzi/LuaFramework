local TutoMgr = {}
local TUTO_TAG = 10000
local plotNum = 1
local btnTable = {}
TutoMgr.isBtnLocked = false
local data_tutorial_tutorial = require("data.data_tutorial_tutorial")
local data_tuto_lvl_tuto_lvl = require("data.data_tuto_lvl_tuto_lvl")
local data_sort_tutorial = {}

_G.isTutoExist = false
_G.TUTO_INDEX = 0

for key, tuto in pairs(data_tutorial_tutorial) do
	data_sort_tutorial[tuto.trigger[2]] = tuto
end

function TutoMgr.lockBtn()
	TutoMgr.isBtnLocked = true
end

function TutoMgr.unlockBtn()
	TutoMgr.isBtnLocked = false
end

function TutoMgr.lvlupSet()
	for k, v in ipairs(data_tuto_lvl_tuto_lvl) do
		if v.actLv == game.player.m_level then
			TutoMgr.setPlotNum(v.trigger)
			break
		end
	end
end

function TutoMgr.lockTable()
	PostNotice(NoticeKey.LOCK_TABLEVIEW)
end

function TutoMgr.unlockTable()
	PostNotice(NoticeKey.UNLOCK_TABLEVIEW)
end

function TutoMgr.notLock()
	return not TutoMgr.isBtnLocked
end

function TutoMgr.getServerNum(tutoBack)
	RequestHelper.getGuide({
	callback = function(data)
		local finNum = data["1"]
		plotNum = TutoMgr.getResetPlotNum(finNum)
		if tutoBack ~= nil then
			tutoBack(plotNum)
		end
	end
	})
end

function TutoMgr.getResetPlotNum(num)
	local resetNum = num
	local isGetNum = false
	if data_sort_tutorial[num] then
		resetNum = data_sort_tutorial[num].resetNum
		isGetNum = true
	end
	if isGetNum == false then
		ResMgr.debugBanner(common:getLanguageString("@juqingzhibcz") .. num)
	end
	return resetNum
end

function TutoMgr.setServerNum(param)
	local setNum = param.setNum
	TutoMgr.setPlotNum(setNum)
	RequestHelper.setGuide({
	guide = plotNum,
	callback = function(data)
	end
	})
end

function TutoMgr.isFinish()
	if plotNum > 999999 then
		return true
	else
		return false
	end
end

function TutoMgr.getPlotNum()
	return plotNum
end

function TutoMgr.recordLocalNum(num)
	CCUserDefault:sharedUserDefault():setIntegerForKey("TUTO_NUM", num)
end

function TutoMgr.getLocalNum()
	return CCUserDefault:sharedUserDefault():getIntegerForKey("TUTO_NUM", 0)
end

function TutoMgr.getBtn(key)
	return btnTable[key]
end

function TutoMgr.addBtn(key, btn, notice)
	if btn ~= nil then
		btnTable[key] = btn
		btnTable[key].notice = notice
	else
	end
end

function TutoMgr.removeBtn(key)
	btnTable[key] = nil
end

function TutoMgr.setPlotNum(num)
	if num > plotNum then
		plotNum = num
	end
end

function TutoMgr.isTutoExist()
	return isTutoExist
	--[[
	local layer = game.runningScene:getChildByTag(TUTO_TAG)
	if layer == nil then
		return false
	else
		return true
	end
	]]
end

function TutoMgr.checkActive()
	local isActive = false
	if TutoMgr.isTutoExist() == false then
		dump(common:getLanguageString("@jihuojq") .. plotNum)
		if plotNum < 99999 and data_sort_tutorial[plotNum] and data_sort_tutorial[plotNum].trigger[1] == game.player.m_level then
			return true
		end
	else
	end
	return isActive
end

function TutoMgr.active(cbFunc, fromStr)
	local isActive = false
	if TutoMgr.isTutoExist() == false then
		dump(common:getLanguageString("@jihuojq") .. plotNum)
		if plotNum < 99999 then
			dump("=========================================" .. plotNum)
			if data_sort_tutorial[plotNum] and data_sort_tutorial[plotNum].trigger[1] == game.player.m_level then
				isActive = true
				dump(common:getLanguageString("@chufaxsyd") .. data_sort_tutorial[plotNum].id)
				TutoMgr.runTutoFunc(data_sort_tutorial[plotNum])
			end
		else
			ResMgr.intoSubMap = false
			ResMgr.removeBefLayer()
			PostNotice(NoticeKey.UNLOCK_BOTTOM)
		end
		if isActive == true then
			dump("activeistrue")
			if cbFunc ~= nil then
				cbFunc()
			end
		else
			dump("activeisfalse")
			TutoMgr.unlockBtn()
			TutoMgr.unlockTable()
			ResMgr.removeBefLayer()
			PostNotice(NoticeKey.UNLOCK_BOTTOM)
		end
	else
		PostNotice(NoticeKey.UNLOCK_BOTTOM)
		ResMgr.removeBefLayer()
	end
end

function TutoMgr.runTutoFuncByIndex(index)
	dump("call tuto func index is " .. index)
	local data = data_tutorial_tutorial[index]
	TutoMgr.runTutoFunc(data)
end

function TutoMgr.runTutoFunc(data)
	local actBtn = btnTable[data.btn]
	dump("act btn is " .. data.btn)
	if actBtn ~= nil and actBtn.getContentSize ~= nil then
		local function nextFunc()
			local arrFuncs = data.arr_funcs
			for k, v in ipairs(arrFuncs) do
				dump("v1 is " .. v[1] .. " v2 is " .. v[2])
				if v[1] == 0 then
					dump(common:getLanguageString("@jieshusdjq") .. v[2])
					TutoMgr.setServerNum({
					setNum = v[2]
					})
				elseif v[1] == 1 then
					dump(common:getLanguageString("@diaoyong") .. v[2])
					TutoMgr.runTutoFuncByIndex(v[2])
				elseif v[1] == 2 then
					dump(common:getLanguageString("@diaoyongjqhs") .. v[2])
				end
			end
		end
		if TutoMgr.isTutoExist() == false then
			dump("---------------------创建新手引导 " .. data.id)
			local tutoLayer = require("game.Tutorial.TutoLayer").new({
			btn = actBtn,
			func = nextFunc,
			girlPos = data.pos,
			arrowDir = data.dir,
			isTouch = data.isTouch,
			intro = data.intro,
			delay = data.delay,
			isShowGirl = data.showGirl,
			sizeX = data.sizeX,
			sizeY = data.sizeY,
			tuData = data,
			notice = notice,
			isMask = data.isMask,
			unlockFunc = function()
				ResMgr.intoSubMap = false
				ResMgr.removeBefLayer()
				PostNotice(NoticeKey.UNLOCK_BOTTOM)
				TutoMgr.unlockBtn()
			end
			})
			TUTO_INDEX = TUTO_INDEX + 1
			tutoLayer:setTag(TUTO_TAG)
			game.runningScene:addChild(tutoLayer, TUTO_ZORDER)
		else
			dump(common:getLanguageString("@cunzaixsyd"))
		end
	else
		ResMgr.removeBefLayer()
		PostNotice(NoticeKey.UNLOCK_BOTTOM)
		dump(" btn is nil " .. data.btn)
	end
end

function TutoMgr.runDramaFuncByIndex(index)
	local data_drama_drama = require("data.data_drama_drama")
	local data = data_drama_drama[index]
	TutoMgr.runDramaFunc(data)
end

function TutoMgr.runDramaFunc(data)
	
end

return TutoMgr