-- FileName: MyGuildWarInfoController.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  MyGuildWarInfoController 跨服军团战接口模块

module("MyGuildWarInfoController", package.seeall)

require "script/ui/guildWar/guildInfo/MyGuildWarInfoService"
require "script/ui/tip/AnimationTip"
require "script/ui/tip/AlertTip"


--[[
	@desc: 			下场按钮回调
	@p_tag:			按钮的Tag
	@p_menuItem:	按钮
	@return:		nil
--]]
function outCallback( p_tag, p_menuItem )
	if not checkEnterOrOut() then
		return
	end
	local fighterInfoIndex = p_tag
	local fighterInfo = MyGuildWarInfoData.getFighterInfoByIndex(fighterInfoIndex)
	local requestCallback = function ( ... )
		MyGuildWarInfoData.setFighterStatus("0", fighterInfo.uid)
		AnimationTip.showTip(GetLocalizeStringBy("key_8473"))
		MyGuildWarInfoDialog.refreshTableView()
		MyGuildWarInfoDialog.refreshFighterCount()
		MyGuildWarInfoDialog.refershMyFightOrder()
	end
	MyGuildWarInfoService.changeCandidate("0", fighterInfo.uid, requestCallback)
end

--[[
	@desc:			上场按钮回调
	@p_tag:			按钮的Tag
	@p_menuItem:	按钮
	@return:		nil 
--]]
function enterCallback( p_tag, p_menuItem )
	if not checkEnterOrOut() then
		return
	end
	local fighterInfoIndex = p_tag
		print(p_tag)
	local fighterInfo = MyGuildWarInfoData.getFighterInfoByIndex(fighterInfoIndex)
	local requestCallback = function ( ... )
		MyGuildWarInfoData.setFighterStatus("1", fighterInfo.uid)
		AnimationTip.showTip(GetLocalizeStringBy("key_8474"))
		MyGuildWarInfoDialog.refreshTableView()
		MyGuildWarInfoDialog.refreshFighterCount()
		MyGuildWarInfoDialog.refershMyFightOrder()
	end
	MyGuildWarInfoService.changeCandidate("1", fighterInfo.uid, requestCallback)
end

--[[
	@desc:					关闭按钮的回调
	@return:				nil
--]]
function closeCallback( ... )
	local isLeader = GuildDataCache.getMineMemberType() == 1
	if isLeader then
		local enterFightMaxCount = MyGuildWarInfoData.getEnterFightMaxCount()
	  	local enterFightCount = MyGuildWarInfoData.getEnterFighterCount()
	  	if enterFightCount < enterFightMaxCount then
	  		AlertTip.showAlert(GetLocalizeStringBy("key_8475"), closeAlertCallback, true, nil)
	  	else
	  		MyGuildWarInfoDialog.close()
	  	end
  	else
  		MyGuildWarInfoDialog.close()
  	end
end

--[[
	@desc: 					确认关闭
	@return:	nil
--]]
function closeAlertCallback( p_confirm )
    if p_confirm then
    	MyGuildWarInfoDialog.close()
    end
end

--[[
	@desc:			更新战斗力按钮的回调
	@return:		nil
--]]
function updateFightForceCallback( ... )
	if not checkUpdateFightForce() then
		return
	end
	local requestCallback = function ( p_ret )
		if p_ret == "fighting" then
			-- 本轮上一小组已参加过战斗
			AnimationTip.showTip(GetLocalizeStringBy("key_8476"))
		elseif p_ret == "loser" then
			-- 已经战死
			AnimationTip.showTip(GetLocalizeStringBy("key_8477"))
		elseif p_ret == "cd" then
			-- CD中
			AnimationTip.showTip(GetLocalizeStringBy("key_8478"))
		else
			local curTime = TimeUtil.getSvrTimeByOffset(0)
			GuildWarMainData.setLastUpateFmtTime(curTime)
			MyGuildWarInfoData.updateMyFightForce(tonumber(p_ret))
			MyGuildWarInfoDialog.refreshTableView()
			MyGuildWarInfoDialog.refershMyFightOrder()
			MyGuildWarInfoDialog.startRefreshUpdateFightForce()
		end
	end
	MyGuildWarInfoService.updateFormation(requestCallback)
end


--[[
	@desc:			清除更新战斗力的CD
	@return:		nil
--]]
function clearFightForceCallback( ... )
	if not checkUpdateFightForce() then
		return
	end
	AlertTip.showAlert(GetLocalizeStringBy("key_8479"), clearFightForceAlertCallback, true, nil)
end

--[[
	@desc:				清除CD的对话框的回调
	@return:	nil
--]]
function clearFightForceAlertCallback( p_confirm )
	if p_confirm then
		if not checkUpdateFightForce() then
			return
		end
		local requestCallback = function ( ... )
			local _, costCount = MyGuildWarInfoData.getUpdateFormationRemainCDAndCost()
			UserModel.addGoldNumber(-costCount)
			GuildWarMainData.setLastUpateFmtTime(0)
		end
		MyGuildWarInfoService.clearUpdFmtCdByGold(requestCallback)
	end
end

function checkEnterOrOut( ... )
	-- 是否已经结束
    if GuildWarPromotionData.isEnd() then
        AnimationTip.showTip(GetLocalizeStringBy("key_8480"))
        return false
    end
	-- 是否已经被淘汰
	if GuildWarPromotionData.myGuildIsEliminated() then
		AnimationTip.showTip(GetLocalizeStringBy("key_8481"))
		return false
	end
	-- 是否在可调整上下场的时段内
    local updateStatus, timeConfig = MyGuildWarInfoData.getUpdateStatus()
    if updateStatus == MyGuildWarInfoData.UpdateStatus.advancedLimit then
        AnimationTip.showTip(GetLocalizeStringBy("key_8482", timeConfig[2] / 60))
        return false
    elseif updateStatus > MyGuildWarInfoData.UpdateStatus.advancedLimit then
        AnimationTip.showTip(GetLocalizeStringBy("key_8483"))
        return false
    end
    return true
end

function checkUpdateFightForce( ... )
	-- 是否报名
	if not GuildWarMainData.isSignUp() then
		AnimationTip.showTip(GetLocalizeStringBy("key_8484"))
		return false
	end
	-- 是否已经被淘汰
	if GuildWarPromotionData.myGuildIsEliminated() then
		AnimationTip.showTip(GetLocalizeStringBy("key_8485"))
		return false
	end
	-- 是否在更新时段内
	local updateStatus, timeConfig = MyGuildWarInfoData.getUpdateStatus()
	if updateStatus == MyGuildWarInfoData.UpdateStatus.auditionLimit then
		AnimationTip.showTip(GetLocalizeStringBy("key_8486", timeConfig[2] / 60))
		return false
	elseif updateStatus == MyGuildWarInfoData.UpdateStatus.auditionFighting then
		AnimationTip.showTip(GetLocalizeStringBy("key_8487"))
		return false
	elseif updateStatus == MyGuildWarInfoData.UpdateStatus.advancedLimit or updateStatus == MyGuildWarInfoData.UpdateStatus.groupLimit then
		AnimationTip.showTip(GetLocalizeStringBy("key_8488", timeConfig[2] / 60))
		return false
	elseif updateStatus == MyGuildWarInfoData.UpdateStatus.groupFighting then
		AnimationTip.showTip(GetLocalizeStringBy("key_8489"))
		return false
	end
	return true
end
