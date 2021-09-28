module("NewActiveService", package.seeall)

 -- /**
 --     * 获取新类型福利活动数据
 --     * @return array
 --     *         [
 --     *             'config' => array                              活动配置
 --     *                         [
 --     *                              'start_time':int
 --     *                              'end_time':int
 --     *                              'data':array
 --     *                                      [
 --     *                                          id:array
 --     *                                              [
 --     *                                                  0 : array
 --     *                                                      [
 --     *                                                          num:int
 --     *                                                          reward:array
 --     *                                                      ]
 --     *                                              ]
 --     *                                      ]
 --     *                         ]
 --     *             'taskInfo' => array                            任务信息
 --     *                         [
 --     *                             num : int                       达成次数
 --     *                             rewarded : array
 --     *                                         [
 --     *                                             rid : int       已领取奖励id(0,1,2,3,……)
 --     *                                         ]
 --     *                         ]
 --     *         ]
 --     */
 --    function getDesactInfo();
function getDesactInfo( p_callbackFunc )
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(cbFlag, dictData, bRet)
			end
		end
	end
	Network.rpc(requestFunc, "desact.getDesactInfo", "desact.getDesactInfo", nil, true)
end

	-- /**
 --     * 领奖
 --     * @param int $id 奖励id(从0开始)
 --     * @return 'ok'
 --    */
 --    function gainReward($id);
 function gainReward( p_id,p_callbackFunc )
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callbackFunc ~= nil) then
				p_callbackFunc(cbFlag, dictData, bRet)
			end
		end
	end
	local args = CCArray:create()	
	args:addObject(CCInteger:create(p_id))
	Network.rpc(requestFunc, "desact.gainReward", "desact.gainReward", args, true)
end