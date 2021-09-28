--HeroDevelopScene.lua


local KnightConst = require("app.const.KnightConst")

local HeroDevelopScene = class ("HeroDevelopScene", UFCCSBaseScene)


function HeroDevelopScene:ctor( style, ... )
	self._mainKnightId = 0
	self._mainBody = nil
	self.super.ctor( self, style,  ...)

end

function HeroDevelopScene:onSceneLoad( style, knightId, itemId, packState, topButtonsPosX, scenePack, ... )
	G_GlobalFunc.savePack(self, scenePack)

	self._mainKnightId = knightId
	self._itemId = itemId -- 觉醒用道具ID
	self._packState = packState -- 觉醒用状态
	self:_onKnightStyleChecked(style)

	self:registerKeypadEvent(true)

    self._headerInfo = G_commonLayerModel:getStrengthenRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()

    self._topBtns = require("app.scenes.herofoster.KnightTopLayer").create()
    self:addUILayerComponent("topbtn", self._topBtns, false)

    self:addUILayerComponent("Header",self._headerInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    self._topBtns:initCheckBtns(style)
    self._topBtns:updatePositionX(topButtonsPosX)
	self:_initCheckBtns(style)

	self._topBtns:registerBtnClickEvent("Button_return", function ( widget )
		self:onBackKeyEvent()			
	end)

	self:adapterLayerHeight(self._headerInfo, nil,nil,0,0)
	self:adapterLayerHeight(self._topBtns, self._headerInfo,nil, -8,0)

	self:adapterLayerHeight(self._mainBody, self._topBtns, self._speedBar, -50, -20)
	self._mainBody:adapterLayer()

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_UPGRADE_KNIGHT, self._onReceiveStrengthRet, self)
end

function HeroDevelopScene:onSceneEnter( ... )
	self:_updateCheckBtns()

	GlobalFunc.flyIntoScreenLR( { self._headerInfo }, true, 0.4, 2, 100)
end

function HeroDevelopScene:onSceneUnload(  )
	uf_eventManager:removeListenerWithTarget(self)
end

function HeroDevelopScene:onBackKeyEvent( ... )
	local callback = function ( ... )
		local scenePack = G_GlobalFunc.createPackScene(self)
        if scenePack then
            uf_sceneManager:replaceScene(scenePack)
		elseif CCDirector:sharedDirector():getSceneCount() > 1 then 
			uf_sceneManager:popScene()
		else
			uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new(1, self._mainKnightId))
		end
	end
	if not self:onSceneSwitch(nil, callback) then 
		callback()
	end

	return true
end

function HeroDevelopScene:onSceneSwitch( param, fun )
	if not self._mainBody or not self._mainBody.onSwitchLayer then 
		return false
	end

	return self._mainBody:onSwitchLayer(param, fun)
end

function HeroDevelopScene:_onReceiveStrengthRet( ret )
    if ret == NetMsg_ERROR.RET_OK  then
        self:_updateCheckBtns()
    end
end

function HeroDevelopScene:_updateCheckBtns(  )
	self._topBtns:enableWidgetByName("CheckBox_strength", G_Me.bagData.knightsData:canKnightStrengthen(self._mainKnightId))
	local notMaxJingjieLevel, canJingjie =  G_Me.bagData.knightsData:canJingJieWithKnightId(self._mainKnightId)
	self._topBtns:enableWidgetByName("CheckBox_jingjie", notMaxJingjieLevel and canJingjie)
	local xilianUnlock, canXilian = G_Me.bagData.knightsData:isKnightCanTraining(self._mainKnightId)
	self._topBtns:enableWidgetByName("CheckBox_xilian", xilianUnlock and canXilian)
	local guanzhiUnlock, canGuanZhi, qualityPermit = G_Me.bagData.knightsData:isKnightGuanghuanOpen(self._mainKnightId)
	self._topBtns:enableWidgetByName("CheckBox_guanzhi", guanzhiUnlock and canGuanZhi and qualityPermit )	
	local awakenUnlock, awakenQualityLimit, awakenLevelValid, notAwakenMaxLevel = G_Me.bagData.knightsData:isKnightAwakenValid(self._mainKnightId)
	self._topBtns:enableWidgetByName("CheckBox_juexing", not(not awakenUnlock or not awakenQualityLimit or not awakenLevelValid or not notAwakenMaxLevel))
	local isGodOpen = G_Me.bagData.knightsData:isGodOpen(self._mainKnightId)
	self._topBtns:enableWidgetByName("CheckBox_God", isGodOpen)
end

function HeroDevelopScene:_initCheckBtns( style )
	-- self._topBtns:addCheckBoxGroupItem(1, "CheckBox_strength")
	-- self._topBtns:addCheckBoxGroupItem(1, "CheckBox_jingjie")
	-- self._topBtns:addCheckBoxGroupItem(1, "CheckBox_guanzhi")
	-- self._topBtns:addCheckBoxGroupItem(1, "CheckBox_xilian")

	-- self._topBtns:enableLabelStroke("Label_strength_check", Colors.strokeBrown, 1 )
 --    self._topBtns:enableLabelStroke("Label_jingjie_check", Colors.strokeBrown, 1 )
 --    self._topBtns:enableLabelStroke("Label_guanzhi_check", Colors.strokeBrown, 1 )
 --    self._topBtns:enableLabelStroke("Label_xilian_check", Colors.strokeBrown, 1 )

	-- self._topBtns:addCheckNodeWithStatus("CheckBox_strength", "Label_strength_check", true)
 --    self._topBtns:addCheckNodeWithStatus("CheckBox_strength", "Label_strength_uncheck", false)

 --    self._topBtns:addCheckNodeWithStatus("CheckBox_jingjie", "Label_jingjie_check", true)
 --    self._topBtns:addCheckNodeWithStatus("CheckBox_jingjie", "Label_jingjie_uncheck", false)

 --    self._topBtns:addCheckNodeWithStatus("CheckBox_guanzhi", "Label_guanzhi_check", true)
 --    self._topBtns:addCheckNodeWithStatus("CheckBox_guanzhi", "Label_guanzhi_uncheck", false)

 --    self._topBtns:addCheckNodeWithStatus("CheckBox_xilian", "Label_xilian_check", true)
 --    self._topBtns:addCheckNodeWithStatus("CheckBox_xilian", "Label_xilian_uncheck", false)

	-- if style == 2 then
	-- 	self._topBtns:setCheckStatus(1, "CheckBox_jingjie")
	-- elseif style == 3 then
	-- 	self._topBtns:setCheckStatus(1, "CheckBox_guanzhi")
	-- elseif style == 4 then
	-- 	self._topBtns:setCheckStatus(1, "CheckBox_xilian")
	-- else
	-- 	self._topBtns:setCheckStatus(1, "CheckBox_strength")
	-- end	

	self:_updateCheckBtns()

	local checkboxEventFunc = function( name, selectType, isCheck ) 

		local topScrollView = self._topBtns:getScrollViewByName("ScrollView_Tab")
		local offsetX = topScrollView:getInnerContainer():getPositionX()

		if name == "CheckBox_strength" then
			if self:onSceneSwitch(nil, function ( ... )
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_STRENGTHEN, self._mainKnightId, nil, nil, offsetX ))
			end) then 
				self._topBtns:setSelectStatus("CheckBox_strength", false)
			else
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_STRENGTHEN, self._mainKnightId, nil, nil, offsetX ))
			end
		elseif name == "CheckBox_jingjie" then
			if self:onSceneSwitch(nil, function ( ... )
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE, self._mainKnightId, nil, nil, offsetX ))
			end) then 
				self._topBtns:setSelectStatus("CheckBox_jingjie", false)
			else
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE, self._mainKnightId, nil, nil, offsetX ))
			end
		elseif name == "CheckBox_xilian" then
			if self:onSceneSwitch(nil, function ( ... )
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_TRAINING, self._mainKnightId, nil, nil, offsetX ))
			end) then 
				self._topBtns:setSelectStatus("CheckBox_xilian", false)
			else
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_TRAINING, self._mainKnightId, nil, nil, offsetX ))
			end
		elseif name == "CheckBox_guanzhi" then
			uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_GUANGHUAN, self._mainKnightId, nil, nil, offsetX ))
		elseif name == "CheckBox_juexing" then
			if self:onSceneSwitch(nil, function ( ... )
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_JUEXING, self._mainKnightId, nil, nil, offsetX ))
			end) then 
				self._topBtns:setSelectStatus("CheckBox_juexing", false)
			else
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_JUEXING, self._mainKnightId, nil, nil, offsetX ))
			end
			
		elseif name == "CheckBox_God" then

			if self:onSceneSwitch(nil, function ()
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_GOD, self._mainKnightId, nil, nil, offsetX))
			end) then
				self._topBtns:setSelectStatus("CheckBox_God", false)
			else
				uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_GOD, self._mainKnightId, nil, nil, offsetX))
			end
		end
	end
	self._topBtns:registerCheckboxEvent("CheckBox_strength", function ( checkbox, selectType, isCheck )
		checkboxEventFunc("CheckBox_strength", selectType, isCheck)
	end)
	self._topBtns:registerCheckboxEvent("CheckBox_jingjie", function ( checkbox, selectType, isCheck )
		checkboxEventFunc("CheckBox_jingjie", selectType, isCheck)
	end)
	self._topBtns:registerCheckboxEvent("CheckBox_guanzhi", function ( checkbox, selectType, isCheck )
		checkboxEventFunc("CheckBox_guanzhi", selectType, isCheck)
	end)
	self._topBtns:registerCheckboxEvent("CheckBox_xilian", function ( checkbox, selectType, isCheck )
		checkboxEventFunc("CheckBox_xilian", selectType, isCheck)
	end)
	self._topBtns:registerCheckboxEvent("CheckBox_juexing", function ( checkbox, selectType, isCheck )
		checkboxEventFunc("CheckBox_juexing", selectType, isCheck)
	end)
	self._topBtns:registerCheckboxEvent("CheckBox_God", function ( checkbox, selectType, isCheck ) 
		checkboxEventFunc("CheckBox_God", SelectType, isCheck)
	end)

	-- self._topBtns:registerCheckBoxGroupEvent(function ( groupId, oldName, newName, checkbox )
	-- 	if groupId ~= 1 then
	-- 		return 
	-- 	end

	-- 	__Log("registerCheckBoxGroupEvent:oldName:%s, newName:%s", oldName, newName)
	-- 	if newName == "CheckBox_strength" then
	-- 		uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_STRENGTHEN, self._mainKnightId ))
	-- 	elseif newName == "CheckBox_jingjie" then
	-- 		uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE, self._mainKnightId ))
	-- 	elseif newName == "CheckBox_xilian" then
	-- 		uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_TRAINING, self._mainKnightId ))
	-- 	elseif newName == "CheckBox_guanzhi" then
	-- 		uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroDevelopScene").new( KnightConst.KNIGHT_TYPE.KNIGHT_GUANGHUAN, self._mainKnightId ))
	-- 	end
	-- end)
end

function HeroDevelopScene:_onKnightStyleChecked( style )
	if self._mainBody == nil then
		if style == KnightConst.KNIGHT_TYPE.KNIGHT_STRENGTHEN then
			local FunctionLevelConst = require("app.const.FunctionLevelConst")
			if not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.OPTIMIZE_LEVEL_UP) then
				self._mainBody = require("app.scenes.herofoster.HeroStrengthenLayer").new("ui_layout/HeroStrengthen_Strengthen.json", self._mainKnightId)
			else
				self._mainBody = require("app.scenes.herofoster.HeroStrengthenLayer2").new("ui_layout/HeroStrengthen_Strengthen2.json", self._mainKnightId)
			end
		elseif style == KnightConst.KNIGHT_TYPE.KNIGHT_JINGJIE then
			self._mainBody = require("app.scenes.herofoster.HeroJingJieLayer").new("ui_layout/HeroShengJie_Main.json", self._mainKnightId)
		elseif style == KnightConst.KNIGHT_TYPE.KNIGHT_TRAINING then
			self._mainBody = require("app.scenes.herofoster.HeroTrainingLayer").create(self._mainKnightId)
		elseif style == KnightConst.KNIGHT_TYPE.KNIGHT_GUANGHUAN then
			self._mainBody = require("app.scenes.herofoster.HeroGuanghuanLayer").create(self._mainKnightId)
		elseif style == KnightConst.KNIGHT_TYPE.KNIGHT_JUEXING then
			self._mainBody = require("app.scenes.herofoster.HeroAwakenLayer").create(self._mainKnightId, self._itemId, self._packState)
		elseif style == KnightConst.KNIGHT_TYPE.KNIGHT_GOD then
			self._mainBody = require("app.scenes.herofoster.god.HeroGodLayer").create(self._mainKnightId)
		else
			__Log("style error! style=%d", style)
		end

		if self._mainBody then
			self:addUILayerComponent("heroDevelopLayer", self._mainBody, true)
		end
	end
end


return HeroDevelopScene

