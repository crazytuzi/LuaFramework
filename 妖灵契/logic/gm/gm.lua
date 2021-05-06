CGmFunc = require "logic.gm.CGmFunc"
CGmCtrl = require "logic.gm.CGmCtrl"
CGmView = require "logic.gm.CGmView"
CGmConfig = require "logic.gm.CGmConfig"
CGmCheckView = require "logic.gm.CGmCheckView"
CModelActionView = require "logic.gm.CModelActionView"
CGmWarSimulateView = require "logic.gm.CGmWarSimulateView"
CGmConsoleView = require "logic.gm.CGmConsoleView"

rpcfunc = {
wardebug = function() 
	if g_WarCtrl:IsWar() then
		local action = g_WarCtrl.m_MainActionList[1]
		local sAction = ""
		local varargs = {}
		local vararglen = 1
		if action then
			local func, args, arglen = unpack(action, 1, 3)
			local info = debug.getinfo(func)
			sAction = sAction.." info.linedefined:"..tostring(info.linedefined)
			sAction = sAction.." info.short_src:"..tostring(info.short_src)
			varargs = args
			vararglen = arglen
		end
		return getprintstr(
			"g_WarCtrl.m_ActionFlag:", g_WarCtrl.m_ActionFlag, "\n",
			"g_MagicCtrl:IsExcuteMagic():", g_MagicCtrl:IsExcuteMagic(),"\n",
			"g_WarCtrl:IsAllExcuteFinish():", g_WarCtrl:IsAllExcuteFinish(),"\n",
			sAction, "\n", unpack(varargs, 1, vararglen)
		)
	else
		return "wardebug fail"
	end
end,
uploadwar= function ()
	if g_WarCtrl:IsWar() then
		local sTime = os.date("%y_%m_%d(%H_%M_%S)",g_TimeCtrl:GetTimeS())
		local sKey = string.format("war_pid%d_%s_%s", g_AttrCtrl.pid, sTime, "远程上传录像")
		local path = g_NetCtrl:SaveRecordsToLocal(sKey, {side=g_WarCtrl:GetAllyCamp()})
		g_QiniuCtrl:UploadFile(sKey, path, enum.QiniuType.None, function() end)
		print("rpcfunc.uploadwar", sKey)
	else
		print("rpcfunc.uploadwar", "不在战斗中")
	end
end,
}