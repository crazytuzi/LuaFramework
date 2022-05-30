--
--                   _ooOoo_
--                  o8888888o
--                  88" . "88
--                  (| -_- |)
--                  O\  =  /O
--               ____/`---'\____
--             .'  \\|     |//  `.
--            /  \\|||  :  |||//  \
--           /  _||||| -:- |||||-  \
--           |   | \\\  -  /// |   |
--           | \_|  ''\---/''  |   |
--           \  .-\__  `-`  ___/-. /
--         ___`. .'  /--.--\  `. . __
--      ."" '<  `.___\_<|>_/___.'  >'"".
--     | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--     \  \ `-.   \_ __\ /__ _/   .-` /  /
--======`-.____`-.___\_____/___.-`____.-'======
--                   `=---='
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
--                 Buddha bless
--
-- 日期：14-8-22
--

RequestState = {
WAITING = 0,
OK = 1,
ERROR = 2
}

local RequestInfo = class("RequestInfo")

function RequestInfo:ctor(param)
	param.param.acc = game.player.m_uid
	self.modulename  = param.modulename
	self.funcname    = param.funcname       -- 请求的函数名字
	self.param       = param.param          -- 参数
	self.oklistener  = param.oklistener     -- 正确数据回调
	self.errlistener = param.errlistener    -- 错误数据回调，没有会默认调用tiplabel
	self.state = RequestState.WAITING
end

return RequestInfo

