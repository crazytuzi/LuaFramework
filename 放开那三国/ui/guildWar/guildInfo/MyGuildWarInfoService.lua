-- FileName: MyGuildWarInfoService.lua 
-- Author: lichenyang 
-- Date: 13-12-31 
-- Purpose:  MyGuildWarInfoService 跨服军团战接口模块

module("MyGuildWarInfoService", package.seeall)

require "script/ui/guildWar/guildInfo/MyGuildWarInfoData"
-- /**
-- * 获取军团成员列表
-- *
-- * @return array
-- * [
-- * 		{
-- *			uid:							用户Id
-- *			uname:							用户名称
-- *			level:							用户等级
-- *			fight_force:					用户战斗力
-- *			contr_num:						用户贡献值
-- *			state							状态 0未出战|1已出战
-- * 		}
-- * ]
-- */
function getGuildWarMemberList(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		MyGuildWarInfoData.setFighterInfoArray(dictData.ret)
		if(p_callback ~= nil) then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "guildwar.getGuildWarMemberList", "guildwar.getGuildWarMemberList", nil, true)
	-- test
	-- local data = {}
	-- data.ret = {}
	-- for i = 1, 28 do
	-- 	local memberInfo = {}
	-- 	if i == 1 then
	-- 		memberInfo.uid = tostring(UserModel.getUserUid())
	-- 		memberInfo.uname = "你是SB"
	-- 	else
	-- 		memberInfo.uid = tostring(i)
	-- 		memberInfo.uname = "逗比你好"
	-- 	end
	-- 	memberInfo.level = tostring(i)
	-- 	memberInfo.fight_force = tostring(math.random(1, 100000))
	-- 	memberInfo.contr_num = "100"
	-- 	memberInfo.state = tostring(math.random(0, 1))
	-- 	memberInfo.dress = {
	-- 		"80001"
	-- 	}
	-- 	memberInfo.htid = "20001"
	-- 	memberInfo.vip = "7"
	-- 	table.insert(data.ret, memberInfo)
	-- end
	-- requestFunc(nil, data, true)
end

-- /**
-- * 设置上场人员和下场人员
-- * 
-- * @param int p_type							0下场|1上场
-- * @param int p_uid							上场或者下场的uid
-- *
-- * @return 'ok'
-- */
function changeCandidate(p_type, p_uid, p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		MyGuildWarInfoData.setFighterStatus(p_type, p_uid)
		if(p_callback ~= nil) then
			p_callback()
		end
	end
	local args = CCArray:create()
	args:addObject(CCInteger:create(p_type))
	args:addObject(CCInteger:create(p_uid))
	Network.rpc(requestFunc, "guildwar.changeCandidate", "guildwar.changeCandidate", args, true)
	-- test
	--requestFunc(nil, nil, true)
end

-- /**
-- * 更新用户阵型信息
-- *
-- * @return int								更新成功, 返回战斗力，方便前端重新排序
-- *         'fighting':string					更新失败，玩家已经上阵，不能更新
-- *         'loser':string						更新失败，玩家已经死啦，不能更新
-- *         'cd':string						更新失败，玩家处在更新战斗数据cd中，不能更新
-- */
function updateFormation(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		if p_callback ~= nil then
			p_callback(dictData.ret)
		end
	end
	Network.rpc(requestFunc, "guildwar.updateFormation", "guildwar.updateFormation", nil, true)
		-- test
		-- local data = {}
		-- data.ret = tostring(math.random(1, 100000))
		-- requestFunc(nil, data, true)
end

-- /**
-- * 使用金币清除更新cd时间
-- *
-- * @return 	int:							清除cd花的钱
-- */
function clearUpdFmtCdByGold(p_callback)
	local requestFunc = function( cbFlag, dictData, bRet )
		if not bRet then
			return
		end
		if(p_callback ~= nil) then
			p_callback()
		end
	end
	Network.rpc(requestFunc, "guildwar.clearUpdFmtCdByGold", "guildwar.clearUpdFmtCdByGold", nil, true)
	--requestFunc(nil, nil, true)
end
