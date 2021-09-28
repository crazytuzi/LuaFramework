--EmptyLayer.lua

local EmptyLayer = class ("EmptyLayer", UFCCSNormalLayer)
local EmptyLayerConst = require("app.const.EmptyLayerConst")
local FunctionLevelConst = require("app.const.FunctionLevelConst")

function EmptyLayer.create(type,...)
    local layer = EmptyLayer.new("ui_layout/common_EmptyLayer.json",...)
    layer:updateView(type)
    return layer
end

function EmptyLayer.createWithPanel(type,panel,...)
    local layer = EmptyLayer.create(type,...)
    local size = panel:getContentSize()
    layer:adapterWithSize(CCSizeMake(size.width, size.height))
    panel:addNode(layer,100)
    return layer
end

function EmptyLayer:ctor( ... )
	self.super.ctor(self, ...)
	self._type = 0
	self:registerWidgetClickEvent("Panel_way1", function ()
		if not self:checkClick() then
			return
		end
		if self._type == EmptyLayerConst.KNIGHTSP then
			uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new(nil, nil, nil, nil,
				GlobalFunc.sceneToPack("app.scenes.herofoster.HeroFosterScene", {2})))
		elseif self._type == EmptyLayerConst.EQUIPMENT then
			uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new(nil, nil, nil, nil,
			     	GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentMainScene", {1})))
		elseif self._type == EmptyLayerConst.EQUIPMENTSP then
			uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonMainScene").new(nil, nil, nil, nil,
			     	GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentMainScene", {2})))
		elseif self._type == EmptyLayerConst.TREASURE then
			if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TREASURE_COMPOSE) == true then
				uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new(nil, nil, nil, nil,
			            	GlobalFunc.sceneToPack("app.scenes.treasure.TreasureMainScene")))
			end
        elseif self._type == EmptyLayerConst.AWAKENITEM then
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.HARDDUNGEON) == true then
				uf_sceneManager:replaceScene(require("app.scenes.harddungeon.HardDungeonMainScene").new())
			end
		elseif self._type == EmptyLayerConst.PET then
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET_SHOP) == true then
				uf_sceneManager:replaceScene(require("app.scenes.pet.shop.PetShopScene").new(nil, nil, nil, nil,
					GlobalFunc.sceneToPack("app.scenes.pet.bag.PetBagMainScene", {1})))
			end
		elseif self._type == EmptyLayerConst.PET_FRAGMENT then
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET_SHOP) == true then
				uf_sceneManager:replaceScene(require("app.scenes.pet.shop.PetShopScene").new(nil, nil, nil, nil,
					GlobalFunc.sceneToPack("app.scenes.pet.bag.PetBagMainScene", {2})))
			end
		elseif self._type == EmptyLayerConst.SELECT_PET then
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET_SHOP) == true then
				uf_sceneManager:replaceScene(require("app.scenes.pet.shop.PetShopScene").new(nil, nil, nil, nil,
					GlobalFunc.sceneToPack("app.scenes.hero.HeroScene", {7})))
			end
		elseif self._type == EmptyLayerConst.HERO_SOUL then
			if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.HERO_SOUL) then
				if G_SceneObserver:getSceneName() == "HeroSoulScene" then
					uf_sceneManager:getCurScene():goToLayer(require("app.const.HeroSoulConst").TERRACE, true)
				else
					uf_sceneManager:replaceScene(require("app.scenes.herosoul.HeroSoulScene").new(nil, nil, nil, require("app.const.HeroSoulConst").TERRACE))
				end
			end
		end
	end)
	self:registerWidgetClickEvent("Panel_way2", function ( ... )
		if not self:checkClick() then
			return
		end
		if self._type == EmptyLayerConst.KNIGHTSP then

		elseif self._type == EmptyLayerConst.EQUIPMENT then
			if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TOWER_SCENE) == true then
			        uf_sceneManager:replaceScene(require("app.scenes.wush.WushScene").new(nil, nil, nil, nil,
			            GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentMainScene", {1})))
			end
		elseif self._type == EmptyLayerConst.EQUIPMENTSP then
			if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TOWER_SCENE) == true then
			        uf_sceneManager:replaceScene(require("app.scenes.wush.WushScene").new(nil, nil, nil, nil,
			            GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentMainScene", {2})))
			end
		elseif self._type == EmptyLayerConst.TREASURE then
        elseif self._type == EmptyLayerConst.AWAKENITEM then
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.AWAKEN) == true then
				uf_sceneManager:replaceScene(require("app.scenes.awakenshop.AwakenShopScene").new())
			end
		elseif self._type == EmptyLayerConst.HERO_SOUL then
			if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.HERO_SOUL) then
				if G_SceneObserver:getSceneName() == "HeroSoulScene" then
					uf_sceneManager:getCurScene():goToLayer(require("app.const.HeroSoulConst").TRIAL, true)
				else
					uf_sceneManager:replaceScene(require("app.scenes.herosoul.HeroSoulScene").new(nil, nil, nil, require("app.const.HeroSoulConst").TRIAL))
				end
			end
		end
	end)


	--蔡文姬
	local appstoreVersion = (G_Setting:get("appstore_version") == "1")
	local GlobalConst = require("app.const.GlobalConst")
	if appstoreVersion or IS_HEXIE_VERSION  then 
	    knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
	else
	    knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
	end
	if knight then
	    local heroPanel = self:getPanelByName("Panel_caiwenji")
	    local KnightPic = require("app.scenes.common.KnightPic")
	    KnightPic.createKnightPic( knight.res_id, heroPanel, "caiwenji",true )
	    heroPanel:setScale(0.8)
	    if self._smovingEffect == nil then
	        local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
	        self._smovingEffect = EffectSingleMoving.run(heroPanel, "smoving_idle", nil, {})
	    end
	end
end

function EmptyLayer:updateView( type )
	self._type = type
	if self._type == EmptyLayerConst.KNIGHTSP then
		self:getLabelByName("Label_des"):setText(G_lang:get("LANG_FUND_EMPTY_KNIGHTSP"))
		self:getPanelByName("Panel_way1"):setVisible(true)
		self:getPanelByName("Panel_way2"):setVisible(false)
		self:getImageViewByName("Image_icon1"):loadTexture("icon/basic/103.png")
		self:getImageViewByName("Image_txt1"):loadTexture("ui/text/txt/arrow_zhuxianfuben.png")
	elseif self._type == EmptyLayerConst.EQUIPMENT then
		self:getLabelByName("Label_des"):setText(G_lang:get("LANG_FUND_EMPTY_EQUIPMENT"))
		self:getPanelByName("Panel_way1"):setVisible(true)
		self:getPanelByName("Panel_way2"):setVisible(true)
		self:getImageViewByName("Image_icon1"):loadTexture("icon/basic/103.png")
		self:getImageViewByName("Image_txt1"):loadTexture("ui/text/txt/arrow_zhuxianfuben.png")
		self:getImageViewByName("Image_icon2"):loadTexture("icon/basic/117.png")
		self:getImageViewByName("Image_txt2"):loadTexture("ui/text/txt/arrow_sanguowushuang.png")
	elseif self._type == EmptyLayerConst.EQUIPMENTSP then
		self:getLabelByName("Label_des"):setText(G_lang:get("LANG_FUND_EMPTY_EQUIPMENTSP"))
		self:getPanelByName("Panel_way1"):setVisible(true)
		self:getPanelByName("Panel_way2"):setVisible(true)
		self:getImageViewByName("Image_icon1"):loadTexture("icon/basic/103.png")
		self:getImageViewByName("Image_txt1"):loadTexture("ui/text/txt/arrow_zhuxianfuben.png")
		self:getImageViewByName("Image_icon2"):loadTexture("icon/basic/117.png")
		self:getImageViewByName("Image_txt2"):loadTexture("ui/text/txt/arrow_sanguowushuang.png")
	elseif self._type == EmptyLayerConst.TREASURE then
		self:getLabelByName("Label_des"):setText(G_lang:get("LANG_FUND_EMPTY_TREASURE"))
		self:getPanelByName("Panel_way1"):setVisible(true)
		self:getPanelByName("Panel_way2"):setVisible(false)
		self:getImageViewByName("Image_icon1"):loadTexture("res/icon/basic/117.png")
		self:getImageViewByName("Image_txt1"):loadTexture("res/ui/text/txt/arrow_quduobao.png")
    elseif self._type == EmptyLayerConst.AWAKENITEM then
        self:getLabelByName("Label_des"):setText(G_lang:get("LANG_FUND_EMPTY_AWAKENITEM"))
		self:getPanelByName("Panel_way1"):setVisible(true)
		self:getPanelByName("Panel_way2"):setVisible(true)
		self:getImageViewByName("Image_icon1"):loadTexture("icon/basic/103.png")
		self:getImageViewByName("Image_txt1"):loadTexture("ui/text/txt/arrow_jingyingfuben.png")
		self:getImageViewByName("Image_icon2"):loadTexture("icon/basic/136.png")
		self:getImageViewByName("Image_txt2"):loadTexture("ui/text/txt/arrow_juexingshangdian.png")
	elseif self._type == EmptyLayerConst.PET then
	    self:getLabelByName("Label_des"):setText(G_lang:get("LANG_FUND_EMPTY_PET"))
		self:getPanelByName("Panel_way1"):setVisible(true)
		self:getPanelByName("Panel_way2"):setVisible(false)
		self:getImageViewByName("Image_icon1"):loadTexture("icon/basic/158.png")
		self:getImageViewByName("Image_txt1"):loadTexture("ui/text/txt/arrow_zhanchongshangdian.png")
	elseif self._type == EmptyLayerConst.PET_FRAGMENT then
	    self:getLabelByName("Label_des"):setText(G_lang:get("LANG_FUND_EMPTY_PET_FRAGMENT"))
		self:getPanelByName("Panel_way1"):setVisible(true)
		self:getPanelByName("Panel_way2"):setVisible(false)
		self:getImageViewByName("Image_icon1"):loadTexture("icon/basic/158.png")
		self:getImageViewByName("Image_txt1"):loadTexture("ui/text/txt/arrow_zhanchongshangdian.png")
	elseif self._type == EmptyLayerConst.SELECT_PET then
	    self:getLabelByName("Label_des"):setText(G_lang:get("LANG_FUND_EMPTY_PET_FRAGMENT"))
		self:getPanelByName("Panel_way1"):setVisible(true)
		self:getPanelByName("Panel_way2"):setVisible(false)
		self:getImageViewByName("Image_icon1"):loadTexture("icon/basic/158.png")
		self:getImageViewByName("Image_txt1"):loadTexture("ui/text/txt/arrow_zhanchongshangdian.png")
	elseif self._type == EmptyLayerConst.HERO_SOUL then
		self:getLabelByName("Label_des"):setText(G_lang:get("LANG_HERO_SOUL_BAG_EMPTY"))
		self:getPanelByName("Panel_way1"):setVisible(true)
		self:getPanelByName("Panel_way2"):setVisible(true)
		self:getImageViewByName("Image_icon1"):loadTexture("icon/basic/164.png")
		self:getImageViewByName("Image_txt1"):loadTexture("ui/text/txt/arrow_qianwangdianjiang.png")
		self:getImageViewByName("Image_icon2"):loadTexture("icon/basic/103.png")
		self:getImageViewByName("Image_txt2"):loadTexture("ui/text/txt/arrow_mingjiangshilian.png")
	end
end

function EmptyLayer:checkClick( )
	if G_SceneObserver:getSceneName() == "DailyPvpTeamScene" then
	    G_MovingTip:showMovingTip(G_lang:get("LANG_PET_LEAVE_FIRST"))
	    return false
	end
	return true
end

function EmptyLayer:onLayerLoad( ... )
	
end

function EmptyLayer:onLayerEnter( ... )	
end

function EmptyLayer:onLayerExit( ... )
end

return EmptyLayer