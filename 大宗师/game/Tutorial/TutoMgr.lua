

local TutoMgr = {}

local TUTO_TAG = 10000
--新手引导表 等松鹏那边完事后可生成

--剧情表 等松鹏那边完事后 可生成




--剧情值，和级别一起判断是否要进行剧情/新手引导的触发
local plotNum = 1
local btnTable = {}

--进入某些界面前先将其他按钮锁住
TutoMgr.isBtnLocked = false

function TutoMgr.lockBtn()
	TutoMgr.isBtnLocked = true
end

function TutoMgr.unlockBtn()
	TutoMgr.isBtnLocked = false
end

function TutoMgr.lvlupSet(lvlNum)
	--每次升级的时候都重新验证一下级别
	local data_tuto_lvl_tuto_lvl = require("data.data_tuto_lvl_tuto_lvl")

	for k,v in ipairs(data_tuto_lvl_tuto_lvl) do
		if v.actLv == game.player.m_level then
			TutoMgr.setPlotNum(v.trigger)
			break
		end
	end
end

function TutoMgr.lockTable()
	print("tututmgr.locktable")
	PostNotice(NoticeKey.LOCK_TABLEVIEW)
end

function TutoMgr.unlockTable()
	print("ulocktttt")
	PostNotice(NoticeKey.UNLOCK_TABLEVIEW)
end

function TutoMgr.notLock()
	return (not TutoMgr.isBtnLocked)
end

function TutoMgr.getServerNum(tutoBack)
	-- local tutoBack = tutoBack
	RequestHelper.getGuide({
		callback = function(data)
			-- local userNum = TutoMgr.getLocalNum()
			local serNum = data["1"]
			local finNum = data["1"]


			plotNum = TutoMgr.getResetPlotNum(finNum)
			print("login get plotNum"..plotNum)
			if tutoBack ~= nil then
				tutoBack(plotNum)
			end
		end
		})
end

function TutoMgr.getResetPlotNum(num)
	local resetNum = num
	local isGetNum = false
	local data_tutorial_tutorial = require("data.data_tutorial_tutorial")

	for k,v in ipairs(data_tutorial_tutorial) do
		local triNum = v.trigger[2]
		if triNum == num and game.player.m_level == v.trigger[1] then
			if v.resetNum ~= nil then
				resetNum = v.resetNum
				isGetNum = true
				break
			end
		end
	end



	if isGetNum == false then
		ResMgr.debugBanner("从服务器获取的剧情值在表中不存在，剧情值"..num)
	end

	return resetNum

end



function TutoMgr.setServerNum(param)
	local setNum = param.setNum
	-- local callback = param.callback
	TutoMgr.setPlotNum(setNum)
	-- TutoMgr.recordLocalNum(setNum)
	RequestHelper.setGuide({
		guide = setNum,
		callback = function(data)
			-- callback()
			
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
	--获取当前的剧情值
	return plotNum
end

function TutoMgr.recordLocalNum(num)
	CCUserDefault:sharedUserDefault():setIntegerForKey("TUTO_NUM", num)
end

function TutoMgr.getLocalNum()
	return CCUserDefault:sharedUserDefault():getIntegerForKey("TUTO_NUM",0)
end

function TutoMgr.getBtn(key)
	return btnTable[key]
end

function TutoMgr.addBtn(key,btn,notice)
	-- print("加入btn "..key)
	if btn ~= nil then
		btnTable[key] = btn
		btnTable[key].notice = notice
	else
		-- assert(false,"不存在的key")
	end
end

function TutoMgr.removeBtn(key)
	-- print("移除btn "..key)
	btnTable[key] = nil 
end

function TutoMgr.addBtnTable(table)
	for k,v in ipairs(table) do
		btnTable[k] = v
	end
end

function TutoMgr.setPlotNum(num)
	if num > plotNum then
		--赋值
		plotNum = num
	-- else
	-- 	--报错 剧情值只可能增加 不可能减少或不变
	-- 	ResMgr.debugBanner("设置的剧情值小于等于原值，剧情值只可能增加 不可能减少或不变")
	end
end

function TutoMgr.isTutoExist()
	local layer = game.runningScene:getChildByTag(TUTO_TAG)
	if layer == nil then
		return false
	else
		-- print("当前界面已经存在了新手引导界面，不能再激活了")
		-- ResMgr.debugBanner("当前界面已经存在了新手引导界面，不能再激活了")
		return true
	end
end

function TutoMgr.checkActive()
	--如果当前界面不存在新手引导教学
	local isActive = false
	if TutoMgr.isTutoExist() == false then	
		--激活函数，判断当前是否有满足条件的 新手引导/剧情值的函数需要激活 需要激活
		print("激活！剧情值为 "..plotNum)
		if plotNum < 99999 then --剧情值最大为99999，如果大于这个值，则证明新手引导已经走完了		
			local data_tutorial_tutorial = require("data.data_tutorial_tutorial")
			--遍历新手引导表，看看有没有要触发的新手引导
			for k,v in ipairs(data_tutorial_tutorial) do
				local lv = v.trigger[1]
				local plot = v.trigger[2]

				--当玩家级别大于等于触发级别，且剧情值与这个表的值相等时，触发函数
				if game.player.m_level == lv and plot == plotNum then
					return true
					-- if v.isJump == 0 then
					-- 	isActive = false
					-- else
					-- 	isActive = true
					-- end
					-- -- return isActive
					-- break
				end
			end


		end	
	else


	end
	return isActive

end

function TutoMgr.active(cbFunc,fromStr)	
	local isActive = false

	--如果当前界面不存在新手引导教学
	if TutoMgr.isTutoExist() == false then	
		--激活函数，判断当前是否有满足条件的 新手引导/剧情值的函数需要激活 需要激活
		print("激活！剧情值为 "..plotNum)
		if plotNum < 99999 then --剧情值最大为99999，如果大于这个值，则证明新手引导已经走完了
			
			local data_tutorial_tutorial = require("data.data_tutorial_tutorial")
			--遍历新手引导表，看看有没有要触发的新手引导
			for k,v in ipairs(data_tutorial_tutorial) do
				local lv = v.trigger[1]
				local plot = v.trigger[2]

				--当玩家级别大于等于触发级别，且剧情值与这个表的值相等时，触发函数
				if game.player.m_level == lv and plot == plotNum then
					isActive = true
					print("触发新手引导了.."..k)
					TutoMgr.runTutoFunc(v)
					break
				end
			end
		else
			ResMgr.intoSubMap = false
			ResMgr.removeBefLayer()
			PostNotice(NoticeKey.UNLOCK_BOTTOM)

		end

		-- if plotNum == 0 then
		-- 	ResMgr.debugBanner("剧情值为0，未从服务器那边获取到剧情值")
		-- end
		if isActive == true then
			print("activeistrue")
			if cbFunc ~= nil then
				--某些功能会因为新手引导的触发而改变
				cbFunc()
			end
		else
			print("activeisfalse")
			TutoMgr.unlockBtn()
			TutoMgr.unlockTable()
			-- PostNotice(NoticeKey.REV_BEF_TUTO_MASK)
			ResMgr.removeBefLayer()
			-- ResMgr.remove
			PostNotice(NoticeKey.UNLOCK_BOTTOM)
			-- ResMgr.intoSubMap = false
		end
	else
		PostNotice(NoticeKey.UNLOCK_BOTTOM)
		ResMgr.removeBefLayer()

	end
	
	
end

function TutoMgr.runTutoFuncByIndex(index)
	local data_tutorial_tutorial = require("data.data_tutorial_tutorial")
	print("call tuto func index is "..index)
	local data = data_tutorial_tutorial[index]

	TutoMgr.runTutoFunc(data)
end

function TutoMgr.runTutoFunc(data)
	local actBtn = btnTable[data.btn]
	-- local notice = btnTable[data.btn].notice
	print("act btn is "..data.btn)
	if actBtn ~= nil and actBtn.getContentSize ~= nil  then
		local function nextFunc()
			local arrFuncs = data.arr_funcs
			for k,v in ipairs(arrFuncs) do
				print("v1 is "..v[1].." v2 is "..v[2])
				if v[1] == 0 then
					--本次引导结束，设定剧情值
					print("结束，设定剧情"..v[2])
					TutoMgr.setServerNum({setNum = v[2]})
					-- TutoMgr.setPlotNum(v[2])
				elseif v[1] == 1 then
					--调用新手引导函数
					
					print("调用 调用"..v[2])
					TutoMgr.runTutoFuncByIndex(v[2])
				elseif v[1] == 2 then
					--调用剧情函数
					print("调用剧情函数 "..v[2])
				end

			end
		end

		if TutoMgr.isTutoExist() == false then	
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
			 	isMask = data.isMask ,
			 	unlockFunc = function()
			 		ResMgr.intoSubMap = false
			 		-- PostNotice(NoticeKey.REV_BEF_TUTO_MASK)
			 		ResMgr.removeBefLayer()
			 		PostNotice(NoticeKey.UNLOCK_BOTTOM)
			 		TutoMgr.unlockBtn()

			 		-- TutoMgr.unlockTable()
			 	end       
		        })
			 tutoLayer:setTag(TUTO_TAG)
	    	game.runningScene:addChild(tutoLayer,TUTO_ZORDER)
    	else
    		-- ResMgr.intoSubMap = false
    		print("当前界面已经存在了新手引导界面，不能再激活了")
			-- ResMgr.debugBanner("当前界面已经存在了新手引导界面，不能再激活了")    		
    	end
    else
    	ResMgr.removeBefLayer()
    	print(" btn is nil "..data.btn)
	end
	--
end

function TutoMgr.runDramaFuncByIndex(index)
	local data_drama_drama = require("data.data_drama_drama")
	local data = data_drama_drama[index]
	TutoMgr.runDramaFunc(data)
end

function TutoMgr.runDramaFunc(data)
	-- local tutoLayer = require(modname)
end



return TutoMgr