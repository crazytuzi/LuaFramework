

function start(api,...)

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	local testQuest = 1143
	
	
	
	api.SendChatMsg('@gm discardTask')
	api.Sleep(1)
	
	api.SendChatMsg('@gm acceptTask '..testQuest)
	api.Sleep(1)
	
	api.Sleep(1)
	
	api.Sleep(1)
end
