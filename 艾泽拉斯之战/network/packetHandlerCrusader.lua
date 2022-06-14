function CrusaderHandler( units, kingInfo )
	
	-- ´Ó1¿ªÊ¼
	local stageIndex = dataManager.crusadeActivityData:getCurrentStageIndex();
	dataManager.crusadeActivityData:setStageInfo(stageIndex, units, kingInfo);
	
			
end
