-- FileName: ActiveListService.lua 
-- Author: licong 
-- Date: 16/1/11 
-- Purpose: 活动列表接口 


module("ActiveListService", package.seeall)

-- /**
-- * 获得活动置顶信息
-- * 
-- * @return
-- * {
-- * 		'compete' => array 比武
-- * 			{
-- * 				'status' => 'ok'/'invalid'		ok代表有效，需要继续更新extra信息判断/invalid代表功能节点没打开，或者没分组，或者不在有效的时间范围内，extra里的信息不用看啦
-- * 				'extra' => array
-- * 					{
-- * 						'num' => int			剩余比武次数
-- * 					}
-- * 			}
-- * 		'worldcompete' => array 跨服比武
-- * 			{
-- * 				'status' => 'ok'/'invalid'
-- * 				'extra' => array
-- * 					{
-- * 						'num' => int			剩余比武次数
-- * 						'box_reward' => int 	未领宝箱个数
-- * 						'can_worship' => int	可以膜拜次数 
-- * 					}
-- * 			}
-- * 		'pass' => array 过关斩将
-- * 			{
-- * 				'status' => 'ok'/'invalid'
-- * 				'extra' => array
-- * 					{
-- * 						'num' => int			剩余攻打次数
-- * 						'pass' => int 			是否已经通关
-- * 						'curr' => int 			当前是第几关
-- * 					}
-- * 			}
-- * 		'moon' => array 水月之境
-- * 			{
-- * 				'status' => 'ok'/'invalid'
-- * 				'extra' => array
-- * 					{
-- * 						'normal_num' => int			普通剩余攻打次数
-- * 						'nightmare_num' => int		梦魇剩余攻打次数
-- * 					}
-- * 			}
-- * 		'worldpass' => array  炼狱挑战
-- * 			{
-- * 				'status' => 'ok'/'invalid'
-- * 				'extra' => array
-- * 					{
-- * 						'num' => int			剩余攻打次数
-- * 					}
-- * 			}
-- * 		'tower' => array 试练塔
-- * 			{
-- * 				'status' => 'ok'/'invalid'
-- * 				'extra' => array
-- * 					{
-- * 						'reset_num' => int		剩余重置次数
-- * 						'can_fail_num' => int	还能够失败的次数
-- * 					}
-- * 			}
-- * 		'dragon' => array 寻龙
-- * 			{
-- * 				'status' => 'ok'/'invalid'
-- * 				'extra' => array
-- * 					{
-- * 						'num' => int			剩余免费重置次数
-- * 					}
-- * 			}
-- * 		'dart' => array 寻龙
-- * 			{
-- * 				'status' => 'ok'/'invalid'
-- * 				'extra' => array
-- * 					{
-- * 						'num' => int			剩余运送次数
-- * 					}
-- * 			}
-- * 		'helltower' => array 试炼梦魇
-- * 			{
-- * 				'status' => 'ok'/'invalid'
-- * 				'extra' => array
-- * 					{
-- * 						'reset_num' => int		剩余重置次数
-- * 						'can_fail_num' => int	还能够失败的次数
-- * 					}
-- * 			}
-- * }
-- */
function getTopActivityInfo( p_callBack )
	local requestFunc = function(cbFlag,dictData,bRet)
		if(p_callBack ~= nil)then
			p_callBack(dictData)
		end
	end
	Network.rpc(requestFunc,"user.getTopActivityInfo","user.getTopActivityInfo",nil)
end











