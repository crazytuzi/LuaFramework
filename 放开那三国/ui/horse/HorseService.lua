-- FileName: HorseService.lua 
-- Author: llp
-- Date: 16-03-31
-- Purpose: function description of module 

module("HorseService", package.seeall)

require "script/network/Network"

-- /**
--  * 获得基本信息
--  * @return array
--  * { 
--  * 		ret										'ok'/'no'
 -- *      'have_charge_dart'=>int  //当前是否有镖车
 -- *      'shipping_num'=>int     //已用的运送次数
 -- *      'plundering_num'=>int   //已用的掠夺次数
 -- *      'assistance_num'=>int   //已用的协助次数
 -- *      'stage_id'=>int         
 -- *      'page_id'=>int,
 -- *      'page_info'=>array(
 -- *          'road_id'=>array(
 -- *              'uid'=>array(
 -- *                  'uname'
 -- *                  'begin_time'
 -- *                  'be_plundered_num' //被掠夺次数
 -- *                  //'has_rage' //狂怒
 -- *                  'guild_name'
 -- *                  ),
 -- *              ),
 -- *          ),
 -- * }
--  function getHorseInfo();
function getHorseInfo( pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pData.ret)
			end
		end
	end
	Network.rpc(callBack, "chargedart.enterChargeDart", "chargedart.enterChargeDart", nil, true)
end

-- /**
--  * 根据horseId获取车辆具体信息
--  *
--  * @param int $num
--  * @return array
--  * { 
--  * 		ret										'ok'/'no' 为no时代表这个服不在任何分组内,没有以下字段
--  * 		name									
--  * 		horseQuality								
--  * 		robedTime								
--  *		startTime 								
--  *		leftResource							
--  * 		helpName
--  * }
--  */
-- function lookHorseById($Id);
function lookHorseById( pId, pItem, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pData.ret,pItem)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pId})
	Network.rpc(callBack, "chargedart.getChargeDartInfo", "chargedart.getChargeDartInfo", args, true)
end

-- /**
--  * 购买运送次数
--  *
--  * @param int $num
--  * @return string 'ok'
--  */
-- function buyCarryNum($num);
function buyCarryNum( pNum, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		end
	end
	local args = Network.argsHandlerOfTable({pNum})
	Network.rpc(callBack, "chargedart.buyShipNum", "chargedart.buyShipNum", args, true)
end

-- /**
--  * 购买掠夺次数
--  *
--  * @param int $num
--  * @return string 'ok'
--  */
-- function buyRobNum($num);
function buyRobNum( pNum, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		end
	end
	local args = Network.argsHandlerOfTable({pNum})
	Network.rpc(callBack, "chargedart.buyRobNum", "chargedart.buyRobNum", args, true)
end

-- /**
--  * 购买协助次数
--  *
--  * @param int $num
--  * @return string 'ok'
--  */
-- function buyRobNum($num);
function buyHelpNum( pNum, pCallBack )
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		end
	end
	local args = Network.argsHandlerOfTable({pNum})
	Network.rpc(callBack, "chargedart.buyAssistanceNum", "chargedart.buyAssistanceNum", args, true)
end

-- /**
--  * 掠夺
--  * @param bool $isAngry
--  * @return 战斗串
--  */
-- function rob();
function rob( pUid,pIsAngry,pCallBack )
	-- body
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pData.ret)
			end
		end
	end
	if(pIsAngry==true)then
		pIsAngry = 1
	else
		pIsAngry = 0
	end
	local args = Network.argsHandlerOfTable({pIsAngry,pUid})
	Network.rpc(callBack, "chargedart.rob", "chargedart.rob", args, true)
end

-- /**
--  * 邀请协助
--  *
--  * @param int $num
--  * @return string 'ok'
--  */
-- function inviteFriend();
function inviteFriend( pUid, pCallBack )
	-- body
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pFlag, pData, pBool)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pUid})
	Network.rpc(callBack, "chargedart.inviteFriend", "chargedart.inviteFriend", args, true)
end

-- /**
--  * 同意协助
--  *
--  * @param bool $help
--  * @return string 'ok'
--  */
-- function canHelp($help);
--bRet ok or not
function acceptInvite( pUid, pFlag, pCallBack )
	-- body
	local callBack = function ( pLog, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pLog, pData, pBool)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pUid, pFlag})
	Network.rpc(callBack, "chargedart.acceptInvite", "chargedart.acceptInvite", args, true)
end

-- /**
--  * 狂怒
--  *
--  * @param num $hid
--  * @return string 'ok'
--  */
-- function angry($hid);
--bRet ok or not
function openRage( pType, pCallBack )
	-- body
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack()
			end
		end
	end
	local args = Network.argsHandlerOfTable({pType})
	Network.rpc(callBack, "chargedart.openRage", "chargedart.openRage", args, true)
end

-- /**
--  * 刷马
--  * @return string 'ok'
--  */
-- function freshHorse();
function refreshHorse(pCallBack)
	-- body
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pFlag, pData, pBool)
			end
		end
	end
	Network.rpc(callBack, "chargedart.refreshStage", "chargedart.refreshStage", nil, true)
end

-- /**
--  * 急行
--  * @param num $horseId
--  * @return string 'ok'
--  */
-- function quickFinish($horseId);
function quickFinish(pItem,pCallBack)
	-- body
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pItem)
			end
		end
	end
	Network.rpc(callBack, "chargedart.finishByGold", "chargedart.finishByGold", nil, true)
end

-- /**
--  * 查看页信息
--  * @param num $PageNum
--  * @return string 'ok'
--  */
-- function quickFinish($PageNum);
function lookPageInfo(pZone ,pPageNum, pCallBack)
	-- body
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pZone,pPageNum})
	Network.rpc(callBack, "chargedart.getOnePageInfo", "chargedart.getOnePageInfo", args, true)
end

function leave( pCallBack )
	-- body
	local callBack = function ( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(cbFlag, dictData, bRet)
			end
		end
	end

	Network.rpc(callBack, "chargedart.leave", "chargedart.leave", nil, true)
end

function getOnlineFriendRequest( pCallBack )
	-- body
	local callBack = function ( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(cbFlag, dictData, bRet)
			end
		end
	end

	Network.rpc(callBack, "friend.getFriendInfoList", "friend.getFriendInfoList", nil, true)
end

function enterShipPage( pCallBack )
	-- body
	local callBack = function ( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(cbFlag, dictData, bRet)
			end
		end
	end

	Network.rpc(callBack, "chargedart.enterShipPage", "chargedart.enterShipPage", nil, true)
end

function beginShipping( pZone , pCallBack )
	-- body
	local callBack = function ( pFlag, pData, pBool )
		if pData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(pFlag, pData, pBool)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pZone})
	Network.rpc(callBack, "chargedart.beginShipping", "chargedart.beginShipping", args, true)
end

function pushAgreeHelp( cbFlag, dictData, bRet )
	if(dictData.err == "ok")then
		CarryDialog.setHaveFriend()
		CarryDialog.freshItem()
		require "script/ui/horse/HorseInviteDialog"
		HorseInviteDialog.closeBtnCb()
	end
end

function re_agree_help_changed()
	Network.re_rpc(pushAgreeHelp, "push.chargedart.acceptinvite", "push.chargedart.acceptinvite")
end

function remove_agree_help_push()
    Network.remove_re_rpc("push.chargedart.acceptinvite")
end

function ChargeDartLook( pUid,pCallBack )
	-- body
	local callBack = function ( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(cbFlag, dictData, bRet)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pUid})
	Network.rpc(callBack, "chargedart.ChargeDartLook", "chargedart.ChargeDartLook", args, true)
end

function getStageInfo( pStage,pCallBack )
	-- body
	local callBack = function ( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(cbFlag, dictData, bRet)
			end
		end
	end
	local args = Network.argsHandlerOfTable({pStage})
	Network.rpc(callBack, "chargedart.getStageInfo", "chargedart.getStageInfo", args, true)
end

function getAllMyInfo( pCallBack )
	-- body
	local callBack = function ( cbFlag, dictData, bRet )
		if dictData.err == "ok" then
			if ( pCallBack ~= nil ) then
				pCallBack(cbFlag, dictData, bRet)
			end
		end
	end
	Network.rpc(callBack, "chargedart.getAllMyInfo", "chargedart.getAllMyInfo", nil, true)
end