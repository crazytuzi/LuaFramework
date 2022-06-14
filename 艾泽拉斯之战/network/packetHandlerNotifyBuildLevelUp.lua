
function NotifyBuildLevelUpHandler( buildType, level )
		local buildData = dataManager.build[buildType] 
		if(buildData)then		
				buildData:setLevel(level)
				eventManager.dispatchEvent({name = global_event.BUILD_ATTR_SYNC,buildType = buildType});	
				
				print("NotifyBuildLevelUpHandler");
				
				if homeland.sceneInitOK then
					homeland.notifyBuildLevelupOK(buildType);
				else
					homeland.playBuildLevelupOK = buildType;
				end
		end				
end
