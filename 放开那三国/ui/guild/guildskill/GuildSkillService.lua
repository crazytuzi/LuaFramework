-- Filename: GuildSkillService.lua
-- Author: lgx
-- Date: 2016-03-02
-- Purpose: 军团科技网络层

module("GuildSkillService", package.seeall)

--[[
	@desc:	学习/提升军团科技等级
	@param: number pSkillId 军团科技Id
	@param:	number pType 类型(1普通成员/2管理)
	/**
	 * 提升技能
	 *
	 * @param $id 技能id
	 * @param $type 类型，1学习2提升
	 * @return string $ret 		处理结果
	 * 'ok'						成功
	 */
	function promote($id, $type);
--]]
function promote( pSkillId , pType , pCallback )
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallback ~= nil)then
				pCallback(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pSkillId , pType })
	Network.rpc(requestFunc,"guild.promote","guild.promote",args,true)
end