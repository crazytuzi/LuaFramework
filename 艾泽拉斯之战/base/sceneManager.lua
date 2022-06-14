
sceneManager   = {}

sceneManager.scene = nil;

sceneManager.battleField = nil 

sceneManager._battlePlayer = nil 

sceneManager.battledata = {};

sceneManager.flag = false;

function sceneManager.runBattle()

	local createdActors = {};
	
	--dump(battlePrepareScene.unitData);
	
	if battlePlayer.rePlayStatus == true then
		battlePrepareScene.closePrepareScene();
		battlePrepareScene.sceneInitBySceneID();
	else
	
		if battlePlayer.battleType ~= enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE and
			battlePlayer.battleType ~= enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE then
			-- 不释放actor
			for k,v in ipairs(battlePrepareScene.unitData) do
				if v.actor then
					table.insert(createdActors, v.actor);
				end
			end
			
			battlePrepareScene.destroyUnitData(true);
		else
			battlePrepareScene.destroyUnitData();
		end
	end
	
	--dump(createdActors);
		
	sceneManager._battlePlayer = nil;
	sceneManager._battlePlayer = battlePlayer.new();
	sceneManager._battlePlayer:init();
	sceneManager._battlePlayer:runBattle(createdActors);
	
	if battlePlayer.rePlayStatus ~= true then
		-- 开始
		eventManager.dispatchEvent({name = global_event.BATTLEHINT_SHOW, hintType = "battle"});
	end
	
	eventManager.dispatchEvent({name = global_event.CHANGESCENE_OVER});
	
end

function sceneManager.OnTick(dt)
	
	if true == sceneManager.flag then
		sceneManager.battleField:OnTick(dt)		
	else
		if(sceneManager._battlePlayer)then
			sceneManager._battlePlayer:OnTick(dt)
		end	
	end

end			

function sceneManager.closeScene()
	if sceneManager.scene then
		local _sceneManager = LORD.SceneManager:Instance()
		_sceneManager:closeScene()
		sceneManager.scene = nil;
	end
end	
	
function sceneManager.loadScene(sceneFile)
	if sceneManager.scene then
		print("current scene is not closed, and now trying load a new one!");
		sceneManager.closeScene();
		return;
	end
	sceneManager.scene = LORD.SceneManager:Instance():loadScene(sceneFile, 3);
	return sceneManager.scene;
end

function sceneManager.battlePlayer()
	return sceneManager._battlePlayer
end			
 