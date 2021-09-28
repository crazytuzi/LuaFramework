--HeroDetailLayer.lua
local KnightConst = require("app.const.KnightConst")
local funLevelConst = require("app.const.FunctionLevelConst")

local HeroDetailLayer = class("HeroDetailLayer", function (  )
	return CCSItemCellBase:create("ui_layout/HeroStrengthen_detailCell.json")
end)


function HeroDetailLayer.create( scenePack )
	local HeroDetailLayer = require("app.scenes.herofoster.HeroDetailLayer")
	return HeroDetailLayer.new(scenePack)
end

function HeroDetailLayer:ctor( scenePack, ... )
	self._scenePack = scenePack

	self._knightId = 0

	self._canStrengthen = false
	self._notJingJieMaxLevel = true
	self._canJingJie = false
	self._xilianUnlock = false
	self._canXiLian = false
	self._canGod = false

	self._guanzhiUnlock = false
	self._canGuanZhi = false
	self._lowQuality = false
	self._godStatus = nil

	self:registerBtnClickEvent("Button_strength", handler(self, self._onStrengthClick))
	self:registerBtnClickEvent("Button_jingjie", handler(self, self._onJingjieClick))
	self:registerBtnClickEvent("Button_xilian", handler(self,self._onXilianClick))
	self:registerBtnClickEvent("Button_guanzhi", handler(self, self._onGuanzhiClick))
	self:registerBtnClickEvent("Button_shizhuang", handler(self, self._onShiZhuangClick)) -- 时装
    self:registerBtnClickEvent("Button_awaken", handler(self, self._onAwakenClick))     -- 觉醒
    self:registerBtnClickEvent("Button_God", handler(self, self._onGodClick))  -- 化神
        
	-- self:enableLabelStroke("Label_strength", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_jingjie", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_xilian", Colors.strokeBrown, 1 )
	-- self:enableLabelStroke("Label_guanzhi", Colors.strokeBrown, 1 )
	--self:showWidgetByName("Button_guanzhi", false)
end

function HeroDetailLayer:updateDetailWithKnightId( knightId )
	self._knightId = knightId or 0
	if self._knightId == 0 then
		return 
	end

	local mainKnightId = G_Me.formationData:getMainKnightId()
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)		
	local mainKnightInfo = G_Me.bagData.knightsData:getKnightByKnightId(mainKnightId)
	if mainKnightInfo == nil or knightInfo == nil then
		__LogError("main knight or normal knight is invalid!")
		return 
	end
	local level = G_Me.userData.level
         
	self._canStrengthen = G_Me.bagData.knightsData:canKnightStrengthen(self._knightId)
	self._notJingJieMaxLevel, self._canJingJie = G_Me.bagData.knightsData:canJingJieWithKnightId(self._knightId)
	self._xilianUnlock, self._canXiLian = G_Me.bagData.knightsData:isKnightCanTraining(self._knightId)
	self._guanzhiUnlock, self._canGuanZhi, self._lowQuality = G_Me.bagData.knightsData:isKnightGuanghuanOpen(self._knightId)
    -- 觉醒用
    self._awakenUnlock, self._awakenQualityLimit, self._awakenKnightLevelValid, self._noAwakenMaxLevel = G_Me.bagData.knightsData:isKnightAwakenValid(self._knightId)
    -- 化神   
    self._canGod, self._godStatus = G_Me.bagData.knightsData:isGodOpen(self._knightId)

    local dressUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.DRESS)
    self:showWidgetByName("Label_shizhuang", (not dressUnlock and (mainKnightId == knightId) and level >= 35))
	self:showWidgetByName("Label_strength", (not self._canStrengthen) and (mainKnightId ~= knightId))
	self:showWidgetByName("Label_jingjie", not self._canJingJie or not self._notJingJieMaxLevel)
	self:showWidgetByName("Label_xilian", not self._xilianUnlock or not self._canXiLian)
	self:showWidgetByName("Label_guanzhi", (not self._guanzhiUnlock or not self._canGuanZhi or not self._lowQuality) and level >= 10)
    self:showWidgetByName("Label_awaken", (not self._awakenUnlock or not self._awakenQualityLimit or not self._awakenKnightLevelValid or not self._noAwakenMaxLevel) and level >= 35)
    self:showWidgetByName("Label_God", (not self._canGod) and (level >= 35))

    self:showWidgetByName("Button_shizhuang", mainKnightId == knightId and level >= 35)
    if not dressUnlock then 
    	self:showTextWithLabel("Label_shizhuang", G_lang:get("LANG_LEVEL_OPEN", 
			{levelValue = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.DRESS)}))
    end

	self:showWidgetByName("Button_strength", mainKnightId ~= knightId)
	self:showTextWithLabel("Label_strength", G_lang:get(mainKnightId == knightId and "LANG_CANNOT_STRENGTH" or "LANG_MAX_LEVEL"))
	if not self._xilianUnlock then 
		self:showTextWithLabel("Label_xilian", G_lang:get("LANG_LEVEL_OPEN", 
			{levelValue = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.KNIGHT_TRAINING)}))
	elseif not self._canXiLian then 
		self:showTextWithLabel("Label_xilian", G_lang:get("LANG_MAX_VALUE"))
	end
	
	if not self._notJingJieMaxLevel then
		self:showTextWithLabel("Label_jingjie", G_lang:get("LANG_MAX_JIESHU"))
	elseif not self._canJingJie then 
		self:showTextWithLabel("Label_jingjie", G_lang:get("LANG_KNIGH_CANNOT_JINGJIE"))
	end

	self:showWidgetByName("Button_guanzhi", level >= 10)
	if not self._guanzhiUnlock then 
		self:showTextWithLabel("Label_guanzhi", G_lang:get("LANG_LEVEL_OPEN", 
			{levelValue = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.KNIGHT_GUANGHUAN)}))
	elseif not self._canGuanZhi then 
		self:showTextWithLabel("Label_guanzhi", G_lang:get("LANG_MAX_VALUE"))
	elseif not self._lowQuality then
		self:showTextWithLabel("Label_guanzhi", G_lang:get("LANG_LOW_QUALITY"))
	end

	self:showWidgetByName("Button_awaken", level >= 35)
    if not self._awakenQualityLimit then
        self:showTextWithLabel("Label_awaken", G_lang:get("LANG_INVALID_EVOLUTION_DESC"))
    elseif not self._awakenKnightLevelValid then
        self:showTextWithLabel("Label_awaken", G_lang:get("LANG_LEVEL_OPEN", {levelValue = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.AWAKEN)}))
    elseif not self._noAwakenMaxLevel then
        self:showTextWithLabel("Label_awaken", G_lang:get("LANG_MAX_EVOLUTION_LEVEL_DESC"))
    end

    -- 化神
    self:showWidgetByName("Button_God", level >= 35)
    if not self._canGod then
    	if self._godStatus == G_Me.bagData.knightsData.GOD_PINZHI_NOT_ENOUGH then
    		self:showTextWithLabel("Label_God", G_lang:get("LANG_GOD_CANT"))
    	elseif self._godStatus == G_Me.bagData.knightsData.GOD_LEVEL_NOT_ENOUGH then
    		self:showTextWithLabel("Label_God", G_lang:get("LANG_LEVEL_OPEN", {levelValue = G_moduleUnlock:getModuleUnlockLevel(funLevelConst.KNIGHT_GOD)}))
    	elseif self._godStatus == G_Me.bagData.knightsData.GOD_ADVANCED_LEVEL_NOT_ENOUGH then
    		self:showTextWithLabel("Label_God", G_lang:get("LANG_GOD_OPEN", {level = KnightConst.KNIGHT_GOD_TUPO_LEVEL}))
    	elseif self._godStatus == G_Me.bagData.knightsData.GOD_OPENING_SOON then
    		self:showTextWithLabel("Label_God", G_lang:get("LANG_GOD_OPEN_SOON"))
    	elseif self._godStatus == G_Me.bagData.knightsData.GOD_MAX_LEVEL then
    		self:showTextWithLabel("Label_God", G_lang:get("LANG_GOD_MAX_LEVEL"))
    	end
    end
        
end

function HeroDetailLayer:_onStrengthClick( ... )
	local mainKnightId = G_Me.formationData:getMainKnightId()
	if mainKnightId == self._knightId then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_STRENGTH_TIP_MAIN_KNIGHT"))
	end

	if not self._canStrengthen then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_STRENGTH_TIP_LEVEL_EXCEED"))
	end

	uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_STRENGTHEN, self._knightId ))
end

function HeroDetailLayer:_onJingjieClick( ... )
	if not self._notJingJieMaxLevel then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_JINGJIE_TIP_MAX_JIESHU"))
	elseif not self._canJingJie then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGH_CANNOT_JINGJIE"))
	end
	if not self._canJingJie then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_JINGJIE_TIP_MAX_JIESHU"))
	end

	uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE, self._knightId ))
end

function HeroDetailLayer:_onXilianClick( ... )
	if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.KNIGHT_TRAINING) then 
		return 
	end
	if not self._canXiLian then
		if self._xilianUnlock then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRAINING_TIP_FULL_TRAINING"))
		else
			return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_TRAINING_TIP_CANOT_TRAINING"))
		end
	end
	uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_TRAINING, self._knightId ))
end

function HeroDetailLayer:_onGuanzhiClick( ... )
	local funLevelConst = require("app.const.FunctionLevelConst")
	if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.KNIGHT_GUANGHUAN) then 
		return 
	end

	if not self._canGuanZhi then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_GUANZHI_FULL_ATTRIBUTE"))
	elseif not self._lowQuality then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_GUANZHI_LOW_QUALITY"))
	end

	uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_GUANGHUAN, self._knightId ))
end

function HeroDetailLayer:_onAwakenClick( ... )
    
    -- 该武将不可觉醒！
    if not self._awakenQualityLimit then
        return G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_KNIGHT_INVALID_DESC"))
    -- 觉醒功能未解锁
    elseif not self._awakenUnlock then
        -- 这里checkModuleUnlockStatus方法内直接抛错误提示了，不用管了
        return G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.AWAKEN)
    elseif not self._awakenKnightLevelValid then
        return G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_KNIGHT_LEVEL_INVALID_DESC", {level=G_moduleUnlock:getModuleUnlockLevel(funLevelConst.AWAKEN)}))
    elseif not self._noAwakenMaxLevel then
        return G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_KNIGHT_LEVEL_MAX_DESC"))
    end

    uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_JUEXING, self._knightId ))
end

function HeroDetailLayer:_onShiZhuangClick( ... )
    if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.DRESS) then
        uf_sceneManager:pushScene(require("app.scenes.dress.DressMainScene").new())
    end
end

function HeroDetailLayer:_onGodClick( ... )
	-- 化神  
	if self._knightId then
    	self._canGod, self._godStatus = G_Me.bagData.knightsData:isGodOpen(self._knightId)
    end
	if not self._canGod and self._godStatus == G_Me.bagData.knightsData.GOD_PINZHI_NOT_ENOUGH then
		G_MovingTip:showMovingTip(G_lang:get("LANG_GOD_CANT2"))
	elseif not self._canGod and self._godStatus == G_Me.bagData.knightsData.GOD_OPENING_SOON then
		G_MovingTip:showMovingTip(G_lang:get("LANG_GOD_OPEN_SOON"))
	elseif G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.KNIGHT_GOD) then
		if not self._canGod then
			if self._godStatus == G_Me.bagData.knightsData.GOD_ADVANCED_LEVEL_NOT_ENOUGH then
				G_MovingTip:showMovingTip(G_lang:get("LANG_GOD_TUPO_TIPS", {level = KnightConst.KNIGHT_GOD_TUPO_LEVEL}))
			elseif self._godStatus == G_Me.bagData.knightsData.GOD_MAX_LEVEL then
				G_MovingTip:showMovingTip(G_lang:get("LANG_GOD_MAX_LEVEL_DESC"))
			end
		else
			uf_sceneManager:pushScene(require("app.scenes.herofoster.HeroDevelopScene").new(KnightConst.KNIGHT_TYPE.KNIGHT_GOD, self._knightId))
		end
		
	end
end

return HeroDetailLayer
