

function start(api,...)
	for _,v in pairs(UITAG) do
		api.CallGlobalFunc('GlobalHooks.ReloadUI',v)
	end
end
