--[[
    战斗失败功能引导
]]

local BattleGuideFunction = class("BattleGuideFunction")
    --[[
        1. 招贤纳士：链接至招将界面；
        2. 养成武将：链接至武将列表；
        3. 养成装备：链接至装备列表；
        4. 武将升级：链接至武将列表；
        5. 武将突破：链接至武将列表；
        6. 武将培养：连接至武将列表；
        7. 武将天命：链接至武将列表；
        8. 装备强化：连接至装备列表；
        9. 装备精炼：链接至装备列表；
        10.宝物强化：链接至宝物列表；
        11.宝物精炼：链接至宝物列表；
        12.强化大师：连接至阵容界面。
    ]]
BattleGuideFunction.ZHAO_XIAN_NA_SHI      	= 1   
BattleGuideFunction.YANG_CHENG_WU_JIANG     = 2   
BattleGuideFunction.YANG_CHENG_ZHUANG_BEI   = 3
BattleGuideFunction.WU_JIANG_SHENG_JI     	= 4
BattleGuideFunction.WU_JIANG_TU_PO        	= 5
BattleGuideFunction.WU_JIANG_PEI_YANG     	= 6
BattleGuideFunction.WU_JIANG_TIAN_MING    	= 7
BattleGuideFunction.ZHUANG_BEI_QIANG_HUA  	= 8
BattleGuideFunction.ZHUANG_BEI_JING_LIAN  	= 9
BattleGuideFunction.BAO_WU_QIANG_HUA 		= 10
BattleGuideFunction.BAO_WU_JING_LIAN 		= 11
BattleGuideFunction.QIANG_HUA_DA_SHI 		= 12

BattleGuideFunction.WU_JIANG_SHENG_JI_ADVANCED  	= 35
BattleGuideFunction.HERO_SHANGZHENG_FORTH		  	= 50


function BattleGuideFunction.linkSceneByType(_type)
	_type = _type or 1
	if _type == 1 then
		uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.shop.ShopScene").new())
	elseif _type == 2 then
		uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.herofoster.HeroFosterScene").new(1))
	elseif _type == 3 then
		uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.equipment.EquipmentMainScene").new(1))
	elseif _type == 4 then
		require("app.scenes.common.acquireInfo.AcquireInfoGuide").runGuide(9, 1, 0)
		uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
	elseif _type == 5 then
		require("app.scenes.common.acquireInfo.AcquireInfoGuide").runGuide(9, 2, 0)
		uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
	elseif _type == 6 then
		require("app.scenes.common.acquireInfo.AcquireInfoGuide").runGuide(9, 4, 0)
		uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
	elseif _type == 7 then
		require("app.scenes.common.acquireInfo.AcquireInfoGuide").runGuide(9, 3, 0)
		uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
	elseif _type == 8 then
		require("app.scenes.common.acquireInfo.AcquireInfoGuide").runGuide(10, 1, 0)
		uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new())
	elseif _type == 9 then
		require("app.scenes.common.acquireInfo.AcquireInfoGuide").runGuide(10, 2, 0)
		uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new())
	elseif _type == 10 then
		require("app.scenes.common.acquireInfo.AcquireInfoGuide").runGuide(11, 1, 0)
		uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureMainScene").new())
	elseif _type == 11 then
		require("app.scenes.common.acquireInfo.AcquireInfoGuide").runGuide(11, 2, 0)
		uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureMainScene").new())
	elseif _type == 12 then
		require("app.scenes.common.acquireInfo.AcquireInfoGuide").runGuide(8, 0, 0)
		uf_sceneManager:replaceScene(require("app.scenes.hero.HeroScene").new())
	elseif _type == 35 then
		require("app.scenes.common.acquireInfo.AcquireInfoGuide").runGuide(35, 101, 0)
		uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
	elseif _type == 50 then
		require("app.scenes.common.acquireInfo.AcquireInfoGuide").runGuide(50, 4, 0)
		uf_sceneManager:replaceScene(require("app.scenes.hero.HeroScene").new())
	end
end

return BattleGuideFunction