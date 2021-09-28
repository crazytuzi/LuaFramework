local CrossWarBattleScene = class("CrossWarBattleScene", UFCCSBaseScene)

local BattleLayer = require("app.scenes.battle.BattleLayer")

function CrossWarBattleScene:ctor(_, report, enemyData, callback, ...)
	-- save callback
	self._callback = callback
	self.super.ctor(self, ...)

	-- create battle layer
	local pack =
	{
		enemy 		= self._enemyData,
		msg 		= report,
		battleBg 	= G_Path.getDungeonBattleMap(31002),
		battleType 	= BattleLayer.CROSSWAR_BATTLE,
		skip 		= BattleLayer.SkipConst.SKIP_YES
	}

	self._battleLayer = BattleLayer.create(pack, handler(self, self._onBattleEvent))
	self:addChild(self._battleLayer)
end

function CrossWarBattleScene:onSceneEnter(...)
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function CrossWarBattleScene:_onBattleEvent(event)
	if event == BattleLayer.BATTLE_FINISH then
		if self._battleLayer then
			local result = G_GlobalFunc.getBattleResult(self._battleLayer)
			if self._callback then
				self._callback(result)
			end
		end
	end
end

function CrossWarBattleScene:play()
	self._battleLayer:play()
end

return CrossWarBattleScene