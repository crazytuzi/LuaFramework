module(..., package.seeall)

--GS2C--

function GS2CNotify(pbdata)
	local cmd = pbdata.cmd
	--todo
	g_NotifyCtrl:FloatMsg(cmd)
end


--C2GS--

