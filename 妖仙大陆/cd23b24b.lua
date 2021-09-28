

function start(api,...)
	local closed = api.Net.GetClientConfig('guide_closed')
	if closed then
		api.ShowNotify('引导开启')
		api.Net.SetClientConfig('guide_closed',nil)
	else
		api.ShowNotify('引导关闭')
		api.Net.SetClientConfig('guide_closed','true')
	end		
end
