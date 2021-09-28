-- Filename: RedPacketService.lua
-- Author: llp
-- Date: 2015-12-25
-- Purpose: 红包跟网络交互Service

module("RedPacketService" , package.seeall)

--[[ 	 
	 /**
     * 拉取红包信息
     * @param int $type 种类(所有/军团/个人)
     * @return array[
     *          'canSendTotal' : num 总共剩余可发金币数
     *          'canSendToday': num  今日剩余可发金币数
     *          'rankList' : array[
     *                          0 : array[
     *                                  'uid' : uid  发红包人的用户id
     *                                  'uname' : uname 发红包人的角色名
     *                                  'eid' : eid 红包id
     *                                  'left' : num 剩余数量
     *                                 ]
     *                          1 : array
     *                      ]
     *          ]
     */
    public function getInfo($uType);
]]
function getInfo( pCallBack, pType )
	-- body
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallBack ~= nil)then
				pCallBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pType })
	Network.rpc(requestFunc,"envelope.getInfo","envelope.getInfo",args,true)
end

--[[    
	 /**
     * 获取单个红包信息
     * @param int $eid
     * @return array[
     *                  'uid' => uid
     *              	'htid' => htid
     *              	'uname' => uname
     *              	'dressInfo' => array[]
     					'shareNum' => num
     *              	'leftNum' => leftNum
     *              	'msg' => msg
     *                  'rankList' : array[
     *                                  0 : array[
     *                                          'uid'   : uid   用户id
     *                                          'uname' : uname 角色名
     *                                          'htid'  : htid
     *                                          'dressInfo' : array[]
     *                                          'gold' : gold   抢到的金币数
     *                                          ]
     *                                  ]
     *              ]
     */
    
    public function getSingleInfo($eid);
]]
function getSingleRedPacketInfo( pCallBack, pEid )
	-- body
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallBack ~= nil)then
				pCallBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pEid })
	Network.rpc(requestFunc,"envelope.getSingleInfo","envelope.getSingleInfo",args,true)
end
--[[    
     /**
     * 获取单个红包的剩余数量
     * @param int $eid
     * @return array[
     *              'uid' => uid
     *              'htid' => htid
     *              'uname' => uname
     *              'dressInfo' => array[]
     *              'leftNum' => leftNum
     *              'msg' => msg
     *          ]
     */
    public function getSingleLeft($eid);
]]
function getLeftRedPacketInfo( pCallBack,pEid )
	-- body
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallBack ~= nil)then
				pCallBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pEid })
	Network.rpc(requestFunc,"envelope.getSingleLeft","envelope.getSingleLeft",args,true)
end
--[[   
     /**
     * 发红包
     * @param int $eType        类型（世界/军团）
     * @param int $goldNum      金币总数
     * @param int $shareNum     份数
     * @param string $msg       附带信息
     * @return 'ok'
     */
    public function send($eType, $goldNum, $shareNum, $msg);
]]
function sendRedPacket( pCallBack, pType, pGoldNum, pShareNum, pMsg )
	-- body
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallBack ~= nil)then
				pCallBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pType, pGoldNum, pShareNum, pMsg })
	Network.rpc(requestFunc,"envelope.send","envelope.send",args,true)
end
--[[   
     /**
     * 拆红包
     * @param int $eid    红包id
     * @return int $num   抢到的金币数（为0则说明没抢到）
     */
    public function open($eid);
]]

function openRedPacket( pCallBack, pEid )
	-- body
	local requestFunc = function(cbFlag,dictData,bRet)
		if dictData.err == "ok" then
			if(pCallBack ~= nil)then
				pCallBack(dictData.ret)
			end
		end
	end
	local args = Network.argsHandlerOfTable({ pEid })
	Network.rpc(requestFunc,"envelope.open","envelope.open",args,true)
end

-- 推送红包全部
function pushRedPacketAllCallback(cbFlag, dictData, bRet)
	if(dictData.err == "ok") then
		require "script/ui/redpacket/RedPacketLayer"
		local _curIndex = tonumber(RedPacketData.getClickTag())
		if(_curIndex==1)then
			RedPacketController.getInfo(RedPacketLayer.freshUI,1)
		else
			RedPacketLayer.selectRadio(1)
		end
	end
end

function regPushRedPacketAll( )
	if(RedPacketData.isRedPacketOpen())then
		Network.re_rpc(pushRedPacketAllCallback, "push.envelope.all", "push.envelope.all")
	end
end
-- 推送红包军团
function pushRedPacketGuildCallback(cbFlag, dictData, bRet)
	if(dictData.err == "ok") then
		require "script/ui/redpacket/RedPacketLayer"
		local _curIndex = tonumber(RedPacketData.getClickTag())
		if(_curIndex==2)then
			RedPacketController.getInfo(RedPacketLayer.freshUI,2)
		else
			RedPacketLayer.selectRadio(2)
		end
	end
end

function regPushRedPacketGuild( )
	if(RedPacketData.isRedPacketOpen())then
		Network.re_rpc(pushRedPacketGuildCallback, "push.envelope.guild", "push.envelope.guild")
	end
end