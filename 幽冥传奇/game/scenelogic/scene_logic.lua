require("scripts/game/scenelogic/base_scene_logic")
require("scripts/game/scenelogic/common_scene_logic")
require("scripts/game/scenelogic/base_fb_logic")
require("scripts/game/scenelogic/fb_scene_logic")
require("scripts/game/scenelogic/tf_fb_logic")
require("scripts/game/scenelogic/cg_fb_logic")
require("scripts/game/scenelogic/fuben_mutil_logic")
require("scripts/game/scenelogic/hhjd_fb_logic")
require("scripts/game/scenelogic/cross_battle_fb_logic")
require("scripts/game/scenelogic/dig_ore_scene_logic")
require("scripts/game/scenelogic/jiyan_fuben_logic")
require("scripts/game/scenelogic/babel_fuben_logic")
require("scripts/game/scenelogic/lianyu_fb_logic")
SceneLogic = SceneLogic or {}

function SceneLogic.Create(scene_type, fb_id, scene_id)
	local scene_logic = nil
	local fuben_type = scene_type == 2 and 2 or 0
	if DigOreSceneId == scene_id then
		scene_type = SceneType.DigOre
	end
	if fb_id > 0 then
		for key, value in pairs(FubenData.FubenCfg) do
			for k, v in pairs(value) do
				if v.fubenId == fb_id then
					fuben_type = key
					break
				end
			end
			if fuben_type ~= 0 then
				break
			end
		end
		if scene_id == expFubenConfig.senceid then
			fuben_type = FubenType.JIYanFuben 
		end
	--	print("ssssssss", scene_id, BabelTowerFubenConfig.layerlist[1].sceneid)
		if scene_id == BabelTowerFubenConfig.layerlist[1].sceneid then
			fuben_type = FubenType.Babel	
		end

		if scene_id == PurgatoryFubenConfig.senceid then
			fuben_type = FubenType.LianYuFuben
		end
		if fuben_type == FubenType.Strength then
			scene_logic = CgFbLogic.New()
		elseif fuben_type == FubenType.Tafang then
			scene_logic = TafangFbLogic.New()
		elseif fb_id == FubenMutilId.Team then
			scene_logic = FubenMutilLogic.New()
			scene_logic:SetFubenId(fb_id)
		elseif fuben_type == FubenType.Hhjd then
			scene_logic = HhjdFbLogic.New()
		elseif fuben_type == FubenType.SixWorld then
			scene_logic = CrossBattleFbLogic.New()
		elseif fuben_type == FubenType.JIYanFuben then
			scene_logic = JIYanFubenLogic.New()
		elseif fuben_type == FubenType.Babel then
			scene_logic = BabelFubenLogic.New()
		elseif fuben_type == FubenType.LianYuFuben then
			scene_logic = LianYuFubenLogic.New()
		else
			scene_logic = FbSceneLogic.New()
		end
		scene_logic:SetFubenId(fb_id)
	else
		if scene_type == SceneType.Common then
			scene_logic = CommonSceneLogic.New()
		elseif scene_type == SceneType.DigOre then
			scene_logic = BaseDigOreLogic.New()
		else
			scene_logic = BaseSceneLogic.New()
		end
	end

	if scene_logic ~= nil then
		scene_logic:SetSceneType(scene_type)
		scene_logic:SetFubenType(fuben_type)
	end

	return scene_logic
end
