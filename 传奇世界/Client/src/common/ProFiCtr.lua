--Author:		bishaoqing
--DateTime:		2016-04-25 19:08:23
--Region:		性能分析
local ProFiCtr = class("ProFiCtr")

function ProFiCtr:ctor( ... )
	-- body
	self.sFileName_ = "C:/perf.txt"
end

function ProFiCtr:StartProFi()
	if nil ~= self.m_ProFi then
		
		return ;
	end
	self.m_nProFiCount = 0;
	self.m_ProFi = require "src/common/ProFi"
    local socket = require('socket')
    self.m_ProFi:setGetTimeMethod( socket.gettime )
    self.m_ProFi:start()
end

function ProFiCtr:StopProFi()
	if nil == self.m_ProFi then
		return ;
	end
	self.m_ProFi:stop()
	self.m_ProFi:writeReport(self.sFileName_)
	self.m_ProFi = nil;
end

return ProFiCtr