-- FileName: HorseController.lua 
-- Author: llp 
-- Date: 16-3-31
-- Purpose: function description of module 
--金币足不足判断
module ("HorseController", package.seeall)
require "script/ui/horse/HorseService"
require "script/ui/horse/HorseData"
require "script/ui/horse/HorseInfoDialog"
require "script/ui/horse/HorseBattleMiddleLayer"
--[[
	@des 	: 进马车主界面
	@param 	: 
	@return : 
--]]
function enterHorse( ... )
	-- body
	local requestCallback = function( pRetData )
		HorseData.sethorseInfo(pRetData)
		HorseLayer.createSelfHorseItem(pRetData)
		HorseLayer.freshPage(pRetData)
		HorseData.setHorseQuality(pRetData.stage_id)
	end
	HorseService.getHorseInfo(requestCallback)
end

--[[
	@des 	: 查询车辆信息
	@param 	: 
	@return : 
--]]
function lookHorse( pHorseId,pCallBack,pItem )
	-- body
	local requestCallback = function( pRetData )
		if(pCallBack)then
			pCallBack(pRetData,pItem)
		end
	end
	HorseService.lookHorseById(pHorseId,pItem,requestCallback)
end

--[[
	@des 	: 掠夺
	@param 	: 
	@return : 
--]]
function rob( pUid,pIsAngry,pRewardData )
	HorseInfoDialog.closeAction()
	require "script/battle/BattleLayer"
	local requestCallback = function( pRetData )
		if(pRetData=="noBeRobbedNum")then
			AnimationTip.showTip(GetLocalizeStringBy("llp_418"))
			return
		end
		if(table.isEmpty(pRetData))then
			AnimationTip.showTip(GetLocalizeStringBy("llp_428"))
			return
		end

	    -- 战斗播放结束后的回调
	    function afterRob( ... )
	    	-- body
	    	local layer = HorseBattleMiddleLayer.createLayer()
	    	local runningScene = CCDirector:sharedDirector():getRunningScene()
	    		  runningScene:addChild(layer,300,1)
        	performWithDelay(runningScene,fight2,0.1)
	    end
	    function close( ... )
	    	-- body
	    	require "script/battle/BattleLayer"
    		BattleLayer.closeLayer()
    		MainScene.setMainSceneViewsVisible(false,false,false)
	    end
	    require "script/ui/horse/BattleResultDialog"
	    
	    local isWin = false
		function fight2( ... )
			if(not table.isEmpty(pRetData.atkRet2))then
				HorseData.setRobTimes(-1)
				HorseData.setHaveRobNum(1)
				HorseLayer.freshRobNum()
				local resultLayer =  BattleResultDialog.createAfterBattleLayer(pRetData.atkRet2,pRetData.userInfo,pRewardData,close,nil)
				HorseBattleMiddleLayer.closeLayer()
		        BattleLayer.showBattleWithString(pRetData.atkRet2.fightRet,nil,resultLayer,"ducheng.jpg","music11.mp3",nil,nil,nil,false)
		    end
		end
		if(table.isEmpty(pRetData.atkRet2))then
			HorseData.setRobTimes(-1)
			HorseData.setHaveRobNum(1)
			HorseLayer.freshRobNum()
			local resultLayer =  BattleResultDialog.createAfterBattleLayer(pRetData.atkRet1,pRetData.userInfo,pRewardData,close,false)
			BattleLayer.showBattleWithString(pRetData.atkRet1.fightRet,nil,resultLayer,"ducheng.jpg","music11.mp3",nil,nil,nil,false)
		else
			if(table.isEmpty(pRetData.atkRet1))then
				HorseData.setRobTimes(-1)
				HorseData.setHaveRobNum(1)
				HorseLayer.freshRobNum()
				local resultLayer =  BattleResultDialog.createAfterBattleLayer(pRetData.atkRet2,pRetData.userInfo,pRewardData,close,true)
				BattleLayer.showBattleWithString(pRetData.atkRet2.fightRet,nil,resultLayer,"ducheng.jpg","music11.mp3",nil,nil,nil,false)
			else
				BattleLayer.showBattleWithString(pRetData.atkRet1.fightRet,afterRob,nil,"ducheng.jpg","music11.mp3",nil,nil,nil,false)
			end
		end
	end
	HorseService.rob(pUid, pIsAngry, requestCallback)
end

--[[
	@des 	: 购买掠夺次数
	@param 	: 
	@return : 
--]]
function buyRobNum( pNum, pTotalPrice )
	local num = tonumber(pNum)
	local totalPrice = tonumber(pTotalPrice)
	local requestCallback = function( ... )
		-- 扣除金币
		AnimationTip.showTip(GetLocalizeStringBy("lic_1600"))
		UserModel.addGoldNumber(-totalPrice)
		-- 增加购买次数
		HorseData.setRobTimes(num)
		HorseLayer.freshRobNum()
		HorseInfoDialog.freshRobNum()
	end
	HorseService.buyRobNum(num, requestCallback)
end

--[[
	@des 	: 购买掠夺次数
	@param 	: 
	@return : 
--]]
function buyCarryNum( pNum, pTotalPrice )
	local num = tonumber(pNum)
	local totalPrice = tonumber(pTotalPrice)
	local requestCallback = function( ... )
		AnimationTip.showTip(GetLocalizeStringBy("lic_1600"))
		-- 扣除金币
		UserModel.addGoldNumber(-totalPrice)
		-- 增加购买次数
		HorseData.setCarryTimes(num)

		HorseLayer.freshCarryNum()
		CarryDialog.freshGoldNum()
		local dbInfo = DB_Mnlm_rule.getDataById(1)
		local carryTimes = HorseData.getCarryTimes().."/"..dbInfo.free_transport
		CarryDialog.freshLabel(carryTimes)
	end
	HorseService.buyCarryNum(num, requestCallback)
end

--[[
	@des 	: 购买协助次数
	@param 	: 
	@return : 
--]]
function buyHelpNum( pNum, pTotalPrice )
	local num = tonumber(pNum)
	local totalPrice = tonumber(pTotalPrice)
	local requestCallback = function( ... )
		AnimationTip.showTip(GetLocalizeStringBy("lic_1600"))
		-- 扣除金币
		UserModel.addGoldNumber(-totalPrice)
		-- 增加购买次数
		HorseData.setHelpTimes(num)

		HorseLayer.freshHelpNum()
	end
	HorseService.buyHelpNum(num, requestCallback)
end

--[[
	@des 	: 刷新马车
	@param 	: 
	@return : 
--]]
function refreshHorse(pPrice,pInfo,pCallBack)
	local requestCallback = function( cbFlag, dictData, bRet )
		-- 设置马车信息
		local horseQuality = tonumber(pInfo.stage_id)
		if(horseQuality==tonumber(dictData.ret.stage_id))then
			AnimationTip.showTip(GetLocalizeStringBy("llp_430"))
		else
			AnimationTip.showTip(GetLocalizeStringBy("llp_429"))
		end
		HorseData.setHorseQuality(dictData.ret.stage_id)
		-- 减去金币
		if(pPrice~=0)then
			UserModel.addGoldNumber(-pPrice)
		end

		CarryDialog.freshGoldNum()
		if(pCallBack)then
			pCallBack()
		end
	end

	HorseService.refreshHorse(requestCallback)
end

--[[
	@des 	: 狂怒自己和队友
	@param 	: 
	@return : 
--]]
function openRage( pType,pPrice,pCallBack )
	-- body
	local requestCallback = function( pRetData )
		-- 减去金币
		HorseData.setTeamRageByType(pType)
		UserModel.addGoldNumber(-pPrice)
		HorseTeamInfoDialog.rfcTableView()
	end

	HorseService.openRage(pType-1,requestCallback)
end

--[[
	@des 	: 瞭望
	@param 	: 
	@return : 
--]]
function ChargeDartLook( pCallBack, pUid,pPrice )
	-- body
	local requestCallback = function( cbFlag, dictData, bRet )
		if(pCallBack)then
			HorseData.setTeamInfo(dictData.ret)
			pCallBack(dictData.ret)
		end
		-- 减去金币
		if(pPrice~=nil)then
			UserModel.addGoldNumber(-pPrice)
		end
	end

	HorseService.ChargeDartLook(pUid,requestCallback)
end

--[[
	@des 	: 某区某页信息
	@param 	: 
	@return : 
--]]
function lookZoneAndPageInfo( pZone,pPage )
	-- body
	-- body
	local requestCallback = function( pRetData )
		pRetData.stage_id = pZone
		pRetData.page_id = pPage
		HorseLayer.freshSinglePage(pRetData)
	end

	HorseService.lookPageInfo(pZone,pPage,requestCallback)
end

function leaveHorse( pCallBack )
	-- body
	local requestCallback = function( cbFlag, dictData, bRet )
		if(pCallBack)then
			pCallBack(cbFlag, dictData, bRet)
		end
	end

	HorseService.leave(requestCallback)
end

function getOnlineFriend( pCallBack )
	-- body
	local requestCallback = function(cbFlag, dictData, bRet)
		HorseData.setOnlineFriendData(dictData.ret)
		if(pCallBack)then
			pCallBack()
		end
	end

	HorseService.getOnlineFriendRequest(requestCallback)
end

function enterShipPage( pCallBack )
	-- body
	local requestCallback = function(cbFlag, dictData, bRet)
		if(pCallBack)then
			pCallBack(dictData.ret)
		end
	end

	HorseService.enterShipPage(requestCallback)
end

function beginShipping( pZone,pCallBack )
	-- body
	local requestCallback = function(cbFlag, dictData, bRet)
		if(pCallBack)then
			if(dictData.ret=="noRoad")then
				AnimationTip.showTip(GetLocalizeStringBy("llp_424"))
				return
			end
			if(dictData.ret=="hasChanged")then
				AnimationTip.showTip(GetLocalizeStringBy("llp_424"))
				return
			end
			HorseData.setHaveSelf(true)
			local carryNum = HorseData.getCarryTimes()
			if(carryNum>0)then
				HorseData.setCarryTimes(-1)
				HorseData.setShippingNum(1)
			end
			pCallBack(dictData.ret)
		end
	end

	HorseService.beginShipping(pZone,requestCallback)
end

function inviteFriend( pUid,pCallBack )
	-- body
	local function requestCallback( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallBack ~= nil) then
				if(dictData.ret=="noAssistNum")then
					local uname = HorseData.removeInviteByUid(pUid)
					AnimationTip.showTip(GetLocalizeStringBy("llp_423"))
					require "script/ui/horse/HorseInviteDialog"
					HorseInviteDialog.rfcTableView()
					return
				end
				if(dictData.ret=="someoneAccept")then
					local uname = HorseData.removeInviteByUid(pUid)
					AnimationTip.showTip(GetLocalizeStringBy("llp_471"))
					require "script/ui/horse/HorseInviteDialog"
					HorseInviteDialog.closeBtnCb()
					return
				end
				pCallBack(dictData.ret)
			end
		end
	end

	HorseService.inviteFriend(pUid,requestCallback)
end

function acceptInvite( pUid,pFlag,pCallBack )
	-- body
	local function requestCallback( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(pCallBack ~= nil) then
				if(dictData.ret=="noPosition")then
					HorseData.removeOtherDataByUid(pUid)
					HorseReceiveInviteLayer.rfcTableView()
					AnimationTip.showTip(GetLocalizeStringBy("llp_421"))
					return
				end
				if(dictData.ret=="outTime")then
					HorseData.removeOtherDataByUid(pUid)
					HorseReceiveInviteLayer.rfcTableView()
					AnimationTip.showTip(GetLocalizeStringBy("llp_422"))
					return
				end
				if(dictData.ret=="hasBegan")then
					HorseData.removeOtherDataByUid(pUid)
					HorseReceiveInviteLayer.rfcTableView()
					AnimationTip.showTip(GetLocalizeStringBy("llp_453"))
					return
				end
				pCallBack(dictData.ret)
			end
		end
	end

	HorseService.acceptInvite(pUid,pFlag,requestCallback)
end

function finishByGold(pItem,pCallBack,pCost )
	-- body
	local function requestCallback( pItem )
		if(pCallBack ~= nil) then
			if(pCost~=0)then
				UserModel.addGoldNumber(-pCost)
			end
			HorseData.setHorseQuality(1)
			pCallBack(pItem)
		end
	end

	HorseService.quickFinish(pItem,requestCallback)
end

function getStageInfo(pStage,pCallBack )
	-- body
	local function requestCallback( cbFlag, dictData, bRet )
		if(pCallBack ~= nil) then
			pCallBack(dictData.ret)
		end
	end

	HorseService.getStageInfo(pStage,requestCallback)
end

function getAllMyInfo(pCallBack )
	-- body
	local function requestCallback( cbFlag, dictData, bRet )
		if(pCallBack ~= nil) then
			pCallBack(dictData.ret)
		end
	end

	HorseService.getAllMyInfo(requestCallback)
end