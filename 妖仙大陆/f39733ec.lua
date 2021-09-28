function start(api,...)
	local caption = 
	{																				
		name = '齐天大圣孙悟空',													
		iconPath = 'dynamic_n/npc_bust/22001.png',									
		wait = 300,																	
		texts = 																	
		{																			
			{text='剧情对话展示',wait=1},											
			{text='<b>粗体哦</b>', wait=1},											
			{text='这是一个神奇的故事, 从前的从前',clean=true,sec=2,wait=3},		
		}
	}
	local sc = api.ShowCaption(caption)												
		api.Sleep(2)																
		api.AddCaptionText(sc, {text='设置剧情摄像头',clean=true})					
		api.Sleep(5)																
		api.AddCaptionText(sc, {text='播放摄像机动画',sec=1,clean=true})
		api.Camera.PlayAnimation('aiwenjun_01_01')
		api.Sleep(12)
		api.CloseCaption()															
		api.Wait()																	
end																					
