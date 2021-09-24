local DisparkHelper=classGc(function(self)
	self:init()
end)
function DisparkHelper.init(self)
	-- self.m_noReloadFileArray=clone(_G.package.loaded)
end

function DisparkHelper.reloadAllCnf(self)
	local loadedArray=_G.package.loaded
	for fileName,_ in pairs(loadedArray) do
		local searchCnf=string.find(fileName,[[_cnf]])
		if searchCnf then
			loadedArray[fileName]=nil
			require(fileName)
		end
	end
end

function DisparkHelper.clearAllFileLoad(self)
	local loadedArray=_G.package.loaded
	for fileName,_ in pairs(loadedArray) do
		local searchCnf=string.find(fileName,[[_cnf]])
		if not searchCnf then
			loadedArray[fileName]=nil
		end
	end

	require("cfg.Const")
	require("cfg.ConstGc")
	require("cfg.Lang")
	require("mvc.view")
	require("mvc.mediator")
	require("mvc.command")
	require("mvc.commandMsg")
	require("mod.res.ResourceList")

	require("cfg.Msg")
	require("cfg.MsgAck")
	require("cfg.MsgReq")

	require("util.ColorUtil")
	require("util.ShaderUtil")

	
	local function nFun()
		-- if _G.GChatProxy~=nil then
		-- 	_G.GChatProxy.m_mediator:destroy()
		-- 	_G.GChatProxy=nil
		-- end
		
		if _G.TipsUtil then
			_G.TipsUtil:_reset()
		end

		if _G.GMoneyView then
			_G.GMoneyView:destroy()
			_G.GMoneyView=nil
		end
	end
	local status, msg=pcall(nFun)
    if not status then
        __G__TRACKBACK__(msg)
    end
	_G.TipsUtil=require("mod.general.TipsUtil")()
	-- _G.GChatProxy=require("mod.chat.ChatProxy")()

	if _G.ImageAsyncManager then
		_G.ImageAsyncManager:clear()
		require("util.ImageAsyncManager")
	end

	local guideView=require("mod.support.GuideManager")
	for k,v in pairs(guideView) do
		if type(v)=="function" then
			_G.GGuideManager[k]=v
		end
	end
end

return DisparkHelper