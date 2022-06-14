
 
cropData =  {}

cropData.config = dataConfig.configs.unitConfig --dataConfig.getConfig("Confcrop")
cropData.data =  dataConfig.configs.BattleFieldConfig --dataConfig.getConfig("testBattle")
--dump(cropData.config )
--cropData.battleField_config =  dataConfig.getConfig("battleField_config")

function cropData:getCropsGonfig(id)
	
 	for i,v in pairs (cropData.config) do	
		if( v.id == id) then return v end 
	end			
	return nil 
	
end	



function cropData:getCropsGroup()
	return cropData.data;
end	

function cropData:getCropsData(id,index)
	return cropData.data[id][index]
end
