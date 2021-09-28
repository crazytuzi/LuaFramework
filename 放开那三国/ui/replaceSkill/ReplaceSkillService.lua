-- Filename: ReplaceSkillService.lua
-- Author: zhangqiang
-- Date: 2014-08-11
-- Purpose: 主角更换技能与后端数据通信

module("ReplaceSkillService", package.seeall)
require "script/network/Network"
require "script/ui/replaceSkill/ReplaceSkillData"
--[[
	/**
	 * 切磋
	 * 
	 * @param int $sid
	 * @return array
	 * <code>
	 * {
	 * 		'ret':string
	 * 			'ok'
	 * 			'failed'
	 * 		'atk':							战斗模块返回的数据
	 * 		{								
	 * 			'fightRet' 					战斗字符串
	 * 			'appraisal'					评价
	 * 		}
	 * }
	 */
	public function challenge($sid);

	desc :	开始武艺切磋
	param :	p_sid 挑战的名将id
--]]
function startChallenge( p_curMasterId, p_callBackFunc )
	local callBackFunc = function ( p_cbFlag, p_retData, p_bRet)
		if p_bRet == true then
			print("返回的信息")
			print_t(p_retData)
			if p_callBackFunc ~= nil then
				p_callBackFunc(p_retData.ret.atk.fightRet,p_retData.ret.atk.appraisal)
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_curMasterId))
	Network.rpc(callBackFunc,"star.challenge","star.challenge",args,true)
end

-- --[[
-- 	/**
-- 	 * 洗牌
-- 	 *
-- 	 * @param int $sid
-- 	 * @param array $keys 值范围1-5
-- 	 * @return array
-- 	 * <code>
-- 	 * {
-- 	 * 		0 => 花型，1-9
-- 	 * 		1-5 => $htid
-- 	 * }
-- 	 */
-- 	public function shuffle($sid, $keys);
-- 	param :	p_curMasterId 当前宗师id
-- 			p_keysTable 重新洗牌的索引组
-- 			p_callBackFunc 回调函数

-- --]]
-- function startShuffle( p_curMasterId, p_keysTable, p_callBackFunc )
-- 	local callBackFunc = function ( p_cbFlag, p_retData, p_bRet )
-- 		if p_bRet == true then
-- 			if p_callBackFunc ~= nil then
-- 				p_callBackFunc()
-- 			end
-- 		end
-- 	end
-- 	local keysArray = CCArray:create()
-- 	for _,v in p_keysArray do
-- 		keysArray:addObject(CCInteger:create(tonumber(v)))
-- 	end

-- 	local args = CCArray:create()
-- 	args:addObject(CCInteger:create(tonumber(p_curMasterId)))
-- 	args:addObject(keysArray)
-- 	Network.rpc(callBackFunc, "star.shuffle", "star.shuffle", args, true)
-- end

-- --[[
-- 	/**
-- 	 * 
-- 	 * 领奖
-- 	 * @param int $sid
-- 	 * @return string 'ok'
-- 	 *
-- 	 */
-- 	 public function getReward($sid)
-- --]]
-- function acceptReward(p_curMasterId, p_callBackFunc)
-- 	local callBackFunc = function ( p_cbTag, p_retData, p_bRet )
-- 		if p_bRet == true then
-- 			if p_callBackFunc ~= nil then
-- 				p_callBackFunc()
-- 			end
-- 		end
-- 	end
-- 	local args = CCArray:create()
-- 	args:addObject(CCInteger:create(tonumber(p_curMasterId)))
-- 	Network.rpc(callBackFunc, "star.getReward", "star.getReward", args, true)
-- end


--[[
	/**
	 * 
	 * 升级技能
	 * @param int $sid
	 * @return string 'ok'
	 *
	 */
	 public function upgradeSkill($sid)
--]]
function upgradeSkill(p_curMasterId, p_callBackFunc)
	local callBackFunc = function ( p_cbTag, p_retData, p_bRet )
		if p_bRet == true then
			if p_callBackFunc ~= nil then
				p_callBackFunc()
			end
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(tonumber(p_curMasterId)))
	Network.rpc(callBackFunc, "star.upgradeSkill", "star.upgradeSkill", args, true)
end

-- --[[
-- 	/**
-- 	 * 更换技能
-- 	 * 
-- 	 * @param int $sid 传0就是换回主角自己的技能
-- 	 * @return string 'ok'
-- 	 */
-- 	public function changeSkill($sid);
-- --]]
-- function changeSkill(p_curMasterId, p_callBackFunc)
-- 	local callBackFunc = function ( p_cbTag, p_retData, p_bRet )
-- 		if p_bRet == true then
-- 			if p_callBackFunc ~= nil then
-- 				p_callBackFunc()
-- 			end
-- 		end
-- 	end
-- 	local args = CCArray:create()
-- 	args:addObject(CCInteger:create(tonumber(p_curMasterId)))
-- 	Network.rpc(callBackFunc, "star.changeSkill", "star.changeSkill", args, true)
-- end

-- /**
-- 	 * 翻牌
-- 	 * 
-- 	 * @param int $sid
-- 	 * @return array
-- 	 * <code>
-- 	 * {
-- 	 * 		0 => 花型，1-9
-- 	 * 		1-5 => $htid
-- 	 * }
-- 	 * </code>
-- 	 */
-- 	public function draw($sid);
function draw(p_callBack)
	local drawCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "star.draw" then
			p_callBack(dictData)
		end
	end

	local arg = CCArray:create()
	arg:addObject(CCInteger:create(ReplaceSkillData.getCurMasterInfo().star_id))

	Network.rpc(drawCallBack, "star.draw","star.draw", arg, true)
end

-- /**
-- 	 * 领奖
-- 	 * 
-- 	 * @param int $sid
-- 	 * @return string 'ok'
-- 	 */
-- 	public function getReward($sid);
function getReward(p_callBack)
	local getRewardCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "star.getReward" then
			p_callBack()
			-- ReplaceSkillData.deleteDraw()
		end
	end
	
	local arg = CCArray:create()
	arg:addObject(CCInteger:create(ReplaceSkillData.getCurMasterInfo().star_id))
	Network.rpc(getRewardCallBack, "star.getReward","star.getReward", arg, true)
end

-- /**
-- 	 * 洗牌
-- 	 *
-- 	 * @param int $sid
-- 	 * @param array $keys 值范围1-5
-- 	 * @return array
-- 	 * <code>
-- 	 * {
-- 	 * 		0 => 花型，1-9
-- 	 * 		1-5 => $htid
-- 	 * }
-- 	 * </code>
-- 	 */
-- 	public function shuffle($sid, $keys);
-- function shuffle(p_callBack,p_cardIndexTable,p_kGirlTag)
-- 	local shuffleCallBack = function(cbFlag,dictData,bRet)
-- 		if not bRet then
-- 			return
-- 		end
-- 		if cbFlag == "star.shuffle" then
-- 			p_callBack(dictData.ret)
-- 		end
-- 	end

-- 	local sunArg = CCArray:create()
-- 	for i = 1,#p_cardIndexTable do
-- 		sunArg:addObject(CCInteger:create(p_cardIndexTable[i] - p_kGirlTag))
-- 	end
-- 	local arg = CCArray:create()
-- 	arg:addObject(CCInteger:create(ReplaceSkillData.getCurMasterInfo().star_id))
-- 	arg:addObject(sunArg)
-- 	Network.rpc(shuffleCallBack, "star.shuffle","star.shuffle", arg, true)
-- end

-- /**
-- 	 * 洗牌
-- 	 *
-- 	 * @param int $sid
-- 	 * @param array $keys 值范围1-5
-- 	 * @return array
-- 	 * <code>
-- 	 * {
-- 	 * 		0 => 花型，1-9
-- 	 * 		1-5 => $htid
-- 	 * }
-- 	 * </code>
-- 	 */
function shuffle(p_callBack)
	local shuffleCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "star.shuffle" then
			p_callBack(dictData.ret)
		end
	end
	
	local arg = CCArray:create()
	arg:addObject(CCInteger:create(ReplaceSkillData.getCurMasterInfo().star_id))
	Network.rpc(shuffleCallBack, "star.shuffle","star.shuffle", arg, true)
end
-- /**
-- 	 * 更换技能
-- 	 * 
-- 	 * @param int $sid 传0就是换回主角自己的技能
-- 	 * @return string 'ok'
-- 	 */
--   public function changeSkill($sid)
function changeSkill(star_id,callBackFunc)
	local changeSkillCal = function(cbFlag,dictData,bRet)
		if not bRet then
				return
		end
		if cbFlag == "star.changeSkill" then
			require "script/ui/replaceSkill/ReplaceSkillData"
		    ReplaceSkillData.changePlayerSkill(star_id)
		    print("装备信息修改成功")
		    callBackFunc()
		end	

    end
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(star_id))
    Network.rpc(changeSkillCal, "star.changeSkill","star.changeSkill", arg, true)

end

function quickDraw(callBackFunc)
	local quickDrawCB = function(cbFlag,dictData,bRet)
		if not bRet then
				return
		end
		if cbFlag == "star.quickDraw" then
		    callBackFunc(dictData.ret)
		end	

    end
    print("调用了~~~~~~~~~~~~~~~~~~~~~~~~~~")
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(ReplaceSkillData.getCurMasterInfo().star_id))
    Network.rpc(quickDrawCB, "star.quickDraw","star.quickDraw", arg, true)
end

