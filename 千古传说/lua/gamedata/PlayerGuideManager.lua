--
-- Author: Stephen
-- Date: 2015-5-27 11:24:29
--

local PlayerGuideManager = class("PlayerGuideManager")

local tGetTriggerFunction = require('lua.gamedata.TriggerFunction');

local TiaoguoTime = 120;

local tTriggerFunctions = {
	["level"]	 = tGetTriggerFunction.getLevel,									--当前等级
	["minLevel"]	 = tGetTriggerFunction.getMinLevel,								--最低等级
	["maxLevel"]	 = tGetTriggerFunction.getMaxLevel,								--最高等级
	["step"]	 = tGetTriggerFunction.getStep,										--当前步骤
	["maxStep"]	 = tGetTriggerFunction.getMaxStep,									--最大步骤
	["maxArmyRole"]	 = tGetTriggerFunction.getMaxArmyRole,							--最大上阵人数
	["minArmyRole"]	 = tGetTriggerFunction.getMinArmyRole,							--最小上阵人数
	["martial"]	 = tGetTriggerFunction.getMartial,									--装备秘籍数量
	["curMission"]	 = tGetTriggerFunction.getCurMission,							--当前关卡
	["closeMission"]	 = tGetTriggerFunction.getCloseMission,						--关卡是否未开放
	["passMission"]	 = tGetTriggerFunction.getPassMission,							--关卡是否完成
	["maxRoleNum"]	 = tGetTriggerFunction.getMaxRoleNum,							--最大拥有人数满足触发
	["minRoleNum"]	 = tGetTriggerFunction.getMinRoleNum,							--最低拥有人数满足触发
	["roleNum"]	 = tGetTriggerFunction.getRoleNum,									--拥有人数满足触发
	["cycle"]	 = tGetTriggerFunction.getCycle,									--是否循环触发
	["armyIndexHas"]	 = tGetTriggerFunction.getArmyIndexHas,						--是否战阵位置有人
	["armyIndexNo"]	 = tGetTriggerFunction.getArmyIndexNo,							--是否战阵位置没人
	["tiliMax"]	 = tGetTriggerFunction.getMaxTili,									--最大拥有体力
	["tiliMin"]	 = tGetTriggerFunction.getMinTili,									--最少拥有体力
	["special"]	 = tGetTriggerFunction.getSpecial,									--特殊操作
	["notUseEquip"]	 = tGetTriggerFunction.notUseEquipment,							--没有人穿戴了装备
	["useEquip"]	 = tGetTriggerFunction.useEquipment,							--有人已经穿戴了装备
	["hasEquip"]	 = tGetTriggerFunction.hasEquipment,							--是否拥有装备
	["sevenDay"]	 = tGetTriggerFunction.getSevenDay,								--七日是否过期
}

PlayerGuideManager.BUTTON_OPEN = "PlayerGuideManager.BUTTON_OPEN"

function PlayerGuideManager:ctor()
	self.bOpenGuide = false


	self.now_functionId = 0
	self.next_step = 0
	self.now_step =  0
	self.m_guideInfo = {}
	self.isPlayEffect = false
	self.specialGuideId = 0
	self.clickHandleFunction = {}

	self.guideLayers = {}
end

function PlayerGuideManager:initGuideLayers()
	self.guideLayers = {}
	for info in PlayerGuideData:iterator() do
		if info.trigger_layer and not self:isFunctionOpen(info.id) then
			self.guideLayers[info.trigger_layer] = self.guideLayers[info.trigger_layer] or {}
			table.insert(self.guideLayers[info.trigger_layer], info)
		end
	end
end


function PlayerGuideManager:removeGuideLayers( id )
	local guideInfo = PlayerGuideData:objectByID(id)
	if guideInfo == nil then
		return
	end
	if self.guideLayers[guideInfo.trigger_layer] == nil then
		return
	end
	local num = #self.guideLayers[guideInfo.trigger_layer]
	for i=1,num do
		if self.guideLayers[guideInfo.trigger_layer][i].id == id then
			table.remove(self.guideLayers[guideInfo.trigger_layer],i)
			return
		end
	end
end


function PlayerGuideManager:getByLayerName(layer_name)
	return self.guideLayers[layer_name]
end
function PlayerGuideManager:restart()
	if self.nTimerId then
		TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
	end
	if self.buttonTimerId then
		TFDirector:removeTimer(self.buttonTimerId)
        self.buttonTimerId = nil
	end
	if self.moreBtnTimerId then
		TFDirector:removeTimer(self.moreBtnTimerId)
        self.moreBtnTimerId = nil
	end
	self:removePanelBg()
	self.now_functionId = 0
	self.next_step = 0
	self.now_step =  0
	self.m_guideInfo = {}
	-- self.clickHandleFunction = {}
end
function PlayerGuideManager:setSpecialGuideId( id )
	self.specialGuideId = id
end
function PlayerGuideManager:getTopLayer()
	local currentScene = Public:currentScene()
	if currentScene ~= nil and currentScene.getTopLayer then
		return currentScene:getTopLayer()
	else
		return nil
	end
end

function PlayerGuideManager:playEffect( effect , effectTime )
	if self.effectHandle ~= nil then
		TFAudio.stopEffect(self.effectHandle)
	end
	if self.effectTimer then
		TFDirector:removeTimer(self.effectTimer)
		self.effectTimer = nil
	end
	self.effectHandle = TFAudio.playEffect("sound/guide/"..effect,false)
	RoleSoundData:stopEffect()
	if effectTime and effectTime > 0 then
		self.effectTimer = TFDirector:addTimer(effectTime ,1,nil ,function ()
			self.effectTimer = nil
			self.isPlayEffect = false
		end)
		self.isPlayEffect = true
	end
end

function PlayerGuideManager:getWidgetByName( parent ,widget_name )
	if widget_name == nil or widget_name == "" then
		return nil
	end
	local widgetList , length = stringToTable(widget_name,"|")
	if length == 0 then
		return nil
	end
	local widget = parent
	for i=1,length do
		widget = TFDirector:getChildByPath(widget, widgetList[i])
	end
	return widget
end
--通过name获取widget，name最前是layer的name
function PlayerGuideManager:_getWidgetByName( topLayer ,widget_name )
	if topLayer == nil or widget_name == nil or widget_name == "" then
		return nil
	end
	local widgetList , length = stringToTable(widget_name,"|")
	if length == 0 then
		return nil
	end
	local layer_name = widgetList[i]
	if layer_name ~= topLayer.__cname then
		return nil
	end
	local widget = topLayer
	for i=2,length do
		widget = TFDirector:getChildByPath(widget, widgetList[i])
	end
	return widget
end


--对当前界面的按钮置灰操作
function PlayerGuideManager:setButtonDisable(bDisable, guideInfo)
	if guideInfo.widget_Gray == nil or guideInfo.widget_Gray =="" then
		return
	end
	local topLayer = self:getTopLayer()
	if topLayer.__cname ~= guideInfo.trigger_layer then
		return
	end
	local widget = self:getWidgetByName(topLayer, guideInfo.widget_Gray)
	if widget == nil then
		return
	end

	local widgetClassName = widget:getDescription()
	if widgetClassName ~= "TFButton" and widgetClassName ~= "TFTextButton" and widgetClassName ~= "TFImage" then
		return
	end

	if bDisable then
		if self.clickHandleFunction[guideInfo.id] == nil then
			self.clickHandleFunction[guideInfo.id] = widget:getMEListener(TFWIDGET_CLICK)
		end

		widget:setGrayEnabled(true)
		widget:setClickMoveEnabled(true)
		widget:addMEListener(TFWIDGET_CLICK,
		function()
			-- toastMessage("团队等级达到"..guideInfo.open_lev.."级开启")
			toastMessage(stringUtils.format(localizable.common_function_openlevel, guideInfo.open_lev))
		end)
	else
		if self.clickHandleFunction[guideInfo.id] ~= nil then
			widget:setGrayEnabled(false)
			widget:setClickHighLightEnabled(true)
			widget:addMEListener(TFWIDGET_CLICK, self.clickHandleFunction[guideInfo.id])
			self.clickHandleFunction[guideInfo.id] = nil
		end
	end
end

--设置界面点击的按钮状态
function PlayerGuideManager:setButtonState( topLayer )
	local layers = self:getByLayerName(topLayer.__cname)
	if layers == nil then
		print("self:getByLayerName(topLayer.__cname) == nill", topLayer.__cname)
		return
	end
	if topLayer == self.lastTopLayer then
		return
	end
	self.lastTopLayer = topLayer
	for _, guideInfo in pairs(layers) do
		if self:triggerGuide(guideInfo) then
			self:setButtonDisable(true, guideInfo)
		else
			self:setButtonDisable(false, guideInfo)
		end
	end
end

--是否触发
function PlayerGuideManager:triggerGuide( guideInfo)
	if guideInfo.conditions.cycle and guideInfo.conditions.cycle == true then
	else
		if PlayerGuideManager:isGuideFunctionOpen(guideInfo.id) then
			return false
		end
	end
	for i, v in pairs(tTriggerFunctions) do
		if not TFFunction.call(v, nil, guideInfo.conditions) then
			return false
		end
	end
	return true
end

function PlayerGuideManager:setGuideVisible( visible )
	if self.m_guideInfo and self.m_guideInfo.node and self.m_guideInfo.node.guidePanel_bg then
		if not tolua.isnull(self.m_guideInfo.node.guidePanel_bg) then
			self.m_guideInfo.node.guidePanel_bg:setVisible(visible)
		end
	end
end
--通过步骤信息显示指引
function PlayerGuideManager:showGuideLayerByStepId( stepId ,save)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	if not stepId or stepId == 0 then
		print("stepId == 0 or stepId == nil" , stepId )
		return
	end
	if self.now_step == stepId then
		print("self.now_step == stepId = ",stepId)
		return
	end
	local guideStepInfo = PlayerGuideStepData:objectByID(stepId)
	if guideStepInfo == nil then 
		print("guideStepInfo == nil stepId =" ,stepId)
		return 
	end
	if guideStepInfo.layer_name ~= topLayer.__cname then 
		print("guideStepInfo.layer_name ~= topLayer.__cname ",topLayer.__cname)
		return 
	end
	guideStepInfo.guideType = guideStepInfo.guideType or 0
	if guideStepInfo.guideType == 0 then

		if guideStepInfo.widget_name and guideStepInfo.widget_name ~= "" then
			local widget = self:getWidgetByName(topLayer , guideStepInfo.widget_name)
			if widget == nil then
				print("showGuideLayerByStepId widget == nil",topLayer.__cname)
				self:delayShowGuideLayerIfWidgetNil(stepId ,save)
				return
			end
			if topLayer.__cname == "MenuLayer" then
				topLayer:turnChangeTowidget(widget)
			end
		end
		self:showGuideLayer(guideStepInfo,save)
	elseif guideStepInfo.guideType == 1 then
		self:showAnimation(guideStepInfo)
	elseif guideStepInfo.guideType == 2 then
		self:showDrawing(guideStepInfo)
	end
	self.now_step = stepId
end

--每当界面打开或者关闭的时候调用
function PlayerGuideManager:doGuide()
	-- print("PlayerGuideManager:doGuide()")
	if self.bOpenGuide == false then return end
	if MainPlayer.guideList == nil then
		return
	end
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end

	if self.next_step ~= 0 then
		local guideStepInfo = PlayerGuideStepData:objectByID(self.next_step)
		if guideStepInfo ~= nil then
			-- print("guideStepInfo topLayer------------>",guideStepInfo.layer_name, topLayer.__cname)
			if guideStepInfo.layer_name ~= topLayer.__cname then
				local now_guide = PlayerGuideStepData:objectByID(self.now_step)
				if now_guide == nil or now_guide.force  == nil or now_guide.force ~= false then
					self.isUp = true
					self:setGuideVisible(false)
					print("guideStepInfo",guideStepInfo)
					print("fuck daye 11 topLayer.__cname = ",topLayer.__cname)
					return
				end
			end
		end
	end
	if self.isUp == true then
		self:setGuideVisible(true)
		self.isUp = false
	end

	--如果没有下个步骤的情况，遍历是否有可触发
	if self.next_step == 0 then
		local layers = self:getByLayerName(topLayer.__cname)
		if layers == nil then
			print("self:getByLayerName(topLayer.__cname) == nill", topLayer.__cname)
			return
		end
		for _, guideInfo in pairs(layers) do
			if self:triggerGuide(guideInfo) then
				self.now_functionId = guideInfo.id
				-- self.next_step = guideInfo.process
				local save = false
				if guideInfo.name then
					save = true
				end
				self:showGuideLayerByStepId(guideInfo.process,save)
				return
			end
		end
		if self.specialGuideId ~= 0 then
			self:doGuideByGuideID(self.specialGuideId)
		end
	else       ----------------------- 继续下个步骤
		self:showGuideLayerByStepId(self.next_step,false)
	end
end



--功能是否开放
function PlayerGuideManager:isGuideFunctionOpen(functionId)
	-- print("PlayerGuideManager:isGuideFunctionOpen(functionId)",functionId)
	--local functionId = math.floor(guideid/100)
	functionId = "_"..functionId.."_"
	-- print("MainPlayer.guideList",MainPlayer.guideList)
	if string.find(MainPlayer.guideList, functionId) then
		return true  --by zhangren  临时改为false，不调用功能开放
	else
		return false
	end
end
-- 保存功能开放
function PlayerGuideManager:saveFunctionOpenGuide(functionId)
	-- print("PlayerGuideManager:saveFunctionOpenGuide(functionId) == ",functionId)
	if self:isGuideFunctionOpen(functionId) then
		return
	end
	if MainPlayer.guideList == "" then
		MainPlayer.guideList = "_"..functionId.."_"
	end
	MainPlayer.guideList = MainPlayer.guideList..functionId.."_"
	self:removeGuideLayers(functionId)
	TFDirector:send(c2s.UPDATE_BEGINNERS_GUIDE_SETP_REQUEST, {-1, MainPlayer.guideList})
end

-----------------------------暂时未修改---->
--角色升级界面关闭后回调
function PlayerGuideManager:OnMainLevelUpLayerClose()
	if not self.bOpenGuide then
		return
	end

	local openFunction = self:GetOpenFunctionGuideInfo()
	if openFunction ~= nil and openFunction.trigger_layer == "MenuLayer" then
		local layer = require("lua.logic.common.FunctionOpenLayer"):new(openFunction)
    	AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY)
    	AlertManager:show()
	end
end
-- 开启功能指引
function PlayerGuideManager:BeginFunctionOpenGuide()
	local openFunction = self:GetOpenFunctionGuideInfo()
	-- print("BeginFunctionOpenGuide----",openFunction)
	if openFunction ~= nil and openFunction.name ~= nil then
		-- print("BeginFunctionOpenGuide----11111")
		AlertManager:closeAll()
		-- local topLayer = self:getTopLayer()
		-- if topLayer ~= nil and topLayer.__cname == "MenuLayer" then
		-- 	topLayer:turnChangeToIndex(1)
		-- end
		self.now_functionId = openFunction.id		
		self:showGuideLayerByStepId(openFunction.process,true)
		-- self:showGuideLayer(openFunction , true)
	end
end
-- 获得当前等级功能指引信息
function PlayerGuideManager:GetOpenFunctionGuideInfo()
	-- print("GetOpenFunctionGuideInfo() ---1111")
	if not self.bOpenGuide then
		return nil
	end

	for guideInfo in PlayerGuideData:iterator() do
		if guideInfo.name ~= nil and self:triggerGuide(guideInfo) then
			print("GetOpenFunctionGuideInfo() ---222",guideInfo)
			return guideInfo
		end
	end
	-- print("GetOpenFunctionGuideInfo() ---233")
	return nil
end
--              <--------------暂时未修改----
--显示下一步骤
function PlayerGuideManager:showNextGuideStep()
	if self.now_functionId  == nil or  self.now_functionId == 0 then
		return
	end
	if self.now_step == nil or self.now_step == 0 then
		return
	end
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	local guideInfo = PlayerGuideStepData:objectByID(self.now_step)
	self:clickCallBack(guideInfo,topLayer)
	if guideInfo.next_functionId then
		self.now_functionId = guideInfo.next_functionId
	end
	self.next_step = guideInfo.next_step
	self:removePanelBg()
	local next_guideInfo = PlayerGuideStepData:objectByID(guideInfo.next_step)
	if next_guideInfo and next_guideInfo.layer_name == topLayer.__cname then
		self:showGuideLayerByStepId(self.next_step,false)
	end
end


-- 创建指引Panel背景
function PlayerGuideManager:getGuidePanelBg()
	local guidePanel_bg = TFPanel:create()
	guidePanel_bg:setAnchorPoint(ccp(0, 0))
	guidePanel_bg:setSize(CCSize(GameConfig.WS.width , GameConfig.WS.height))
	guidePanel_bg:setZOrder(10000)
	guidePanel_bg:setTouchEnabled(false)
	return guidePanel_bg
end


-- 添加全屏黑层
function PlayerGuideManager:getGuideForcePanelAll()
	local guideForcePanel = TFPanel:create()
	guideForcePanel:setAnchorPoint(ccp(0.5, 0.5))
	guideForcePanel:setSize(CCSize(GameConfig.WS.width , GameConfig.WS.height))
	guideForcePanel:setPosition(ccp(GameConfig.WS.width/2 , GameConfig.WS.height/2))
	guideForcePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	guideForcePanel:setBackGroundColorOpacity(100)
	guideForcePanel:setBackGroundColor(ccc3(0,0,0))
	guideForcePanel:setTouchEnabled(true)
	return guideForcePanel
end
-- 添加中间有白块的黑层(左上)
function PlayerGuideManager:createLeftUpForceLayer( pos_x , pos_y ,width , height )
	-- print("PlayerGuideManager:createLeftUpForceLayer( width , height )",width , height )
	local guideForcePanel = TFPanel:create()
	guideForcePanel:setAnchorPoint(ccp(1, 0))
	guideForcePanel:setSize(CCSize(width+200 , height+200))
	guideForcePanel:setPosition(ccp( pos_x , pos_y))
	guideForcePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	guideForcePanel:setBackGroundColorOpacity(100)
	guideForcePanel:setBackGroundColor(ccc3(0,0,0))
	guideForcePanel:setTouchEnabled(true)
	
	return guideForcePanel
end
-- 添加中间有白块的黑层(左下)
function PlayerGuideManager:createLeftDownForceLayer( pos_x , pos_y ,width , height )
	-- print("PlayerGuideManager:createLeftDownForceLayer( width , height )",width , height )
	local guideForcePanel = TFPanel:create()
	guideForcePanel:setAnchorPoint(ccp(1, 1))
	guideForcePanel:setSize(CCSize(width+200 , height+200))
	guideForcePanel:setPosition(ccp( pos_x , pos_y))
	guideForcePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	guideForcePanel:setBackGroundColorOpacity(100)
	guideForcePanel:setBackGroundColor(ccc3(0,0,0))
	guideForcePanel:setTouchEnabled(true)

	-- local pic = TFImage:create()
	-- pic:setTexture("ui_new/common/guide_kuang.png")
	-- pic:setAnchorPoint(ccp(0,1))
	-- pic:setScaleY(-1.0)
	-- pic:setPosition(ccp( 0, -(height - pos_y)))
	-- guideForcePanel:addChild(pic)
	return guideForcePanel
end
-- 添加中间有白块的黑层(右上)
function PlayerGuideManager:createRightUpForceLayer( pos_x , pos_y ,width , height )
	-- print("PlayerGuideManager:createRightUpForceLayer( width , height )",width , height )
	local guideForcePanel = TFPanel:create()
	guideForcePanel:setAnchorPoint(ccp(0, 0))
	guideForcePanel:setSize(CCSize(width+200 , height+200))
	guideForcePanel:setPosition(ccp( pos_x, pos_y))
	guideForcePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	guideForcePanel:setBackGroundColorOpacity(100)
	guideForcePanel:setBackGroundColor(ccc3(0,0,0))
	guideForcePanel:setTouchEnabled(true)

	-- local pic = TFImage:create()
	-- pic:setTexture("ui_new/common/guide_kuang.png")
	-- pic:setAnchorPoint(ccp(0,1))
	-- pic:setPosition(ccp( -(width -pos_x) , 0))
	-- guideForcePanel:addChild(pic)
	return guideForcePanel
end
-- 添加中间有白块的黑层(右下)
function PlayerGuideManager:createRightDownForceLayer( pos_x , pos_y ,width , height )
	-- print("PlayerGuideManager:createRightDownForceLayer( width , height )",width , height )
	local guideForcePanel = TFPanel:create()
	guideForcePanel:setAnchorPoint(ccp(0, 1))
	guideForcePanel:setSize(CCSize(width+200 , height+200))
	guideForcePanel:setPosition(ccp( pos_x , pos_y))
	guideForcePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	guideForcePanel:setBackGroundColorOpacity(100)
	guideForcePanel:setBackGroundColor(ccc3(0,0,0))
	guideForcePanel:setTouchEnabled(true)

	-- local pic = TFImage:create()
	-- pic:setTexture("ui_new/common/guide_kuang.png")
	-- pic:setAnchorPoint(ccp(0,1))
	-- pic:setPosition(ccp( -(width -pos_x) , 0))
	-- guideForcePanel:addChild(pic)
	return guideForcePanel
end

function PlayerGuideManager:addGuideKuang( pos , anp )
	local pic = TFImage:create()
	pic:setTexture("ui_new/common/guide_kuang.png")
	pic:setAnchorPoint(anp)
	pic:setPosition(pos)
	return pic
end

-- 添加中间有白块的黑层
function PlayerGuideManager:getGuideForcePanelOut(pos_x,pos_y,width,height)
	local win_width = GameConfig.WS.width
	local win_height = GameConfig.WS.height
	local guideForcePanelList = {}
	guideForcePanelList[1] = self:createLeftUpForceLayer(pos_x + width , pos_y + height, pos_x + width , win_height - (pos_y + height))
	guideForcePanelList[5] = self:addGuideKuang(ccp(pos_x + width+15, pos_y + height+15),ccp(0,1))
	guideForcePanelList[5]:setScaleX(-1)

	guideForcePanelList[2] = self:createLeftDownForceLayer( pos_x,pos_y + height ,pos_x , pos_y + height )
	guideForcePanelList[6] = self:addGuideKuang(ccp(pos_x-15,pos_y + height+15),ccp(0,1))

	guideForcePanelList[3] = self:createRightUpForceLayer(pos_x + width, pos_y ,win_width - (pos_x + width) , win_height - pos_y )
	guideForcePanelList[7] = self:addGuideKuang(ccp(pos_x + width+15, pos_y-15),ccp(0,1))
	guideForcePanelList[7]:setScale(-1)

	guideForcePanelList[4] = self:createRightDownForceLayer(pos_x, pos_y,win_width - pos_x , pos_y )
	guideForcePanelList[8] = self:addGuideKuang(ccp(pos_x-15, pos_y-15),ccp(0,1))
	guideForcePanelList[8]:setScaleY(-1)

	return guideForcePanelList
end

-- 添加中间露出控件的黑层
function PlayerGuideManager:getGuideForcePanelWidget(panelBg , widget , guideInfo)
	if widget == nil or panelBg == nil then
		return
	end
	local topLayer = self:getTopLayer()
	local pos = widget:getParent():convertToWorldSpaceAR(widget:getPosition())--ccp(widget:get Position().x,widget:getPosition().y))
	pos = panelBg:convertToNodeSpace(pos);
	local anchorPoint = widget:getAnchorPoint()
	x = pos.x - anchorPoint.x * widget:getSize().width
	y = pos.y - anchorPoint.y * widget:getSize().height

	local offset = {0,0}
	if guideInfo.offset then
		x = x + guideInfo.offset[1]
		y = y + guideInfo.offset[2]
		offset[1] = guideInfo.offset[3] or 0
		offset[2] = guideInfo.offset[4] or 0
	end	
	local guideForcePanelList = self:getGuideForcePanelOut(x,y,widget:getSize().width+offset[1],widget:getSize().height+offset[2])
	for i=1,8 do
		if guideForcePanelList[i] then
			panelBg:addChild(guideForcePanelList[i])
			panelBg.layerList = panelBg.layerList or {}
			panelBg.layerList[#panelBg.layerList+1] = guideForcePanelList[i]
		end
	end
	--return guideForcePanelList
end

--通过widget来添加控件黑层
function PlayerGuideManager:getGuideForcePanelbyWidget( panelBg  , guideInfo )
	local topLayer = self:getTopLayer()
	if guideInfo.widget_name and guideInfo.widget_name ~= "" then
		local widget = self:getWidgetByName(topLayer, guideInfo.widget_name)
		if widget ~= nil then
			self:getGuideForcePanelWidget(panelBg , widget , guideInfo)
		else
			print("widget == nil widget_name ==",guideInfo.widget_name)
			local guideForcePanel = self:getGuideForcePanelAll()
			if guideForcePanel then
				panelBg:addChild(guideForcePanel)
				panelBg.layerList = panelBg.layerList or {}
				panelBg.layerList[#panelBg.layerList+1] = guideForcePanel
			end
		end
		return true
	end
	return false
end
--通过区域来添加控件黑层
function PlayerGuideManager:getGuideForcePanelbyRect(panelBg , guideInfo)
	if panelBg and guideInfo.widget_rect then
		local x = guideInfo.widget_rect[1]
		local y = guideInfo.widget_rect[2]
		local offset = {0,0}
		if guideInfo.offset then
			x = x + guideInfo.offset[1] or 0
			y = y + guideInfo.offset[2] or 0
			offset[1] = guideInfo.offset[3] or 0
			offset[2] = guideInfo.offset[4] or 0
		end	
		local guideForcePanelList = self:getGuideForcePanelOut(x,y,guideInfo.widget_rect[3]+offset[1],guideInfo.widget_rect[4]+offset[2])
		for i=1,8 do
			if guideForcePanelList[i] then
				panelBg:addChild(guideForcePanelList[i])
				panelBg.layerList = panelBg.layerList or {}
				panelBg.layerList[#panelBg.layerList+1] = guideForcePanelList[i]
			end
		end
		return true
	end
	return false
end

-- 创建指引强制黑层Panel
function PlayerGuideManager:getGuideForcePanel(panelBg  , guideInfo)
	if guideInfo == nil then return end
	local topLayer = self:getTopLayer()
	if topLayer == nil then	return end

	if self:getGuideForcePanelbyRect(panelBg , guideInfo) then return end
	if self:getGuideForcePanelbyWidget(panelBg,guideInfo) then return end
	local guideForcePanel = self:getGuideForcePanelAll()
	if guideForcePanel then
		panelBg:addChild(guideForcePanel)
		panelBg.layerList = panelBg.layerList or {}
		panelBg.layerList[#panelBg.layerList+1] = guideForcePanel
	end
end

--显示强制指引黑层
function PlayerGuideManager:showForceLayer(guidePanel_bg ,guideInfo)
	if guideInfo.force == false then

	else
		self:getGuideForcePanel(guidePanel_bg , guideInfo)
	end
end


function PlayerGuideManager:showhandEffect(panelbg, guideInfo ,widget_pos)
	if guideInfo.hand_eff == "no" then
		return
	end
	local effectName = "guide"
	if guideInfo.hand_eff ~= nil then
		effectName = guideInfo.hand_eff
	end
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/"..effectName..".xml")
	local effect = TFArmature:create(effectName.."_anim")
	if effect ~= nil then
		effect:setAnimationFps(GameConfig.ANIM_FPS)
		if guideInfo.hand_index then
			effect:playByIndex(guideInfo.hand_index, -1, -1, 1)
		else
			effect:playByIndex(0, -1, -1, 1)
		end
		if guideInfo.rotation then
			effect:setRotation(guideInfo.rotation)
		end
		local hand_pos = guideInfo.hand_pos or {0,0}
		local effectPosX = widget_pos.x + hand_pos[1]
		local effectPosY = widget_pos.y + hand_pos[2]
		effect:setPosition(ccp(effectPosX, effectPosY))
		effect:setZOrder(11)
		panelbg:addChild(effect)
	end
end

--显示动画或者特效
function PlayerGuideManager:showEffect(panelbg, guideInfo)
	local widgetPos = ccp(0,0)
	if guideInfo.widget_name and guideInfo.widget_name ~= "" then
		local topLayer = self:getTopLayer()
		local widget = self:getWidgetByName(topLayer, guideInfo.widget_name)
		if widget ~= nil then
			local pos = widget:getParent():convertToWorldSpaceAR(widget:getPosition())
			-- local pos = widget:convertToWorldSpace(ccp(0,0))
			widgetPos = panelbg:convertToNodeSpace(pos);
		end
	end
	if guideInfo.widget_rect then
		widgetPos = ccp(guideInfo.widget_rect[1],guideInfo.widget_rect[2])
	end

	if guideInfo.tip ~= nil and guideInfo.tip ~= "" then
		local bgImgName = "ui_new/guide/bigguidebg_l.png"
		-- local textLen = string.utf8len(guideInfo.tip)
		-- if textLen <= 30 then
		-- 	if guideInfo.right then
		-- 		bgImgName = "ui_new/guide/smallguidebg_r.png"
		-- 	else
		-- 		bgImgName = "ui_new/guide/smallguidebg_l.png"
		-- 	end
		-- else			
		-- 	if guideInfo.right then
		-- 		bgImgName = "ui_new/guide/bigguidebg_r.png"
		-- 	else
		-- 		bgImgName = "ui_new/guide/bigguidebg_l.png"
		-- 	end
		-- end

		local textPanel = TFImage:create(bgImgName)
		textPanel:setPosition(ccp(widgetPos.x+guideInfo.tip_pos[1], widgetPos.y+guideInfo.tip_pos[2]))
		textPanel:setZOrder(10)
		textPanel:setTag(100)
		panelbg:addChild(textPanel)

		-- if guideInfo.right then
		-- 	Public:addEffect("xinshouyindao", textPanel, -50, 0, 0.5, 1)
		-- else

		-- end

		local textLabel = TFTextArea:create()
		textLabel:setAnchorPoint(ccp(0.5, 0.5))

		if guideInfo.right then
			local effect = Public:addEffect("xinshouyindao", textPanel, 380, 0, 0.5, 1)
			effect:setRotationY(180)
			textLabel:setTextAreaSize(CCSizeMake(270,95))
	 		textLabel:setPosition(-25, -55)
		else
			Public:addEffect("xinshouyindao", textPanel, -40, 0, 0.5, 1)
			textLabel:setTextAreaSize(CCSizeMake(270,95))
	 		textLabel:setPosition(30, -55)
		end

		-- if textLen <= 30 then
		-- 	if textLen <= 15 then
		-- 		textLabel:setPosition(0, -90)
		-- 	else
		-- 		textLabel:setPosition(0, -80)
		-- 	end
		-- textLabel:setTextAreaSize(CCSizeMake(310,55))
		-- else
		-- 	if textLen <= 45 then
		-- 		textLabel:setPosition(0, -80)
		-- 	else
		-- 		textLabel:setPosition(0, -70)
		-- 	end
		-- textLabel:setTextAreaSize(CCSizeMake(310,95))
	 --    end

	    textLabel:setFontSize(25)
	    textLabel:setColor(ccc3(0,0,0))
	    textLabel:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
	    textLabel:setText(guideInfo.tip)
	    textPanel:addChild(textLabel)
	end
    self:showhandEffect(panelbg, guideInfo,widgetPos)
end

function PlayerGuideManager:clickCallBack(guideInfo,topLayer)
	print("clickCallBack ---",guideInfo.save)
	self:saveGuideStep(guideInfo.save)
	self:endCallBack(guideInfo,topLayer)
end


--移除指引层
function PlayerGuideManager:removePanelBg()
	if self.buttonTimerId then
		TFDirector:removeTimer(self.buttonTimerId)
		self.buttonTimerId = nil
	end
	if self.moreBtnTimerId then
		TFDirector:removeTimer(self.moreBtnTimerId)
        self.moreBtnTimerId = nil
	end
	if self.m_guideInfo.node then
		for k,v in pairs(self.m_guideInfo.node) do
			if not tolua.isnull(v) then
				v:removeFromParent()--AndCleanup(true)
				v = nil
			end
		end
	end
		self.m_guideInfo.node = {}
end

--是否向服务器发送保存
function PlayerGuideManager:saveGuideStep( save )
	if save then
		self:saveFunctionOpenGuide(self.now_functionId)
	end
end

--非强制的事件
function PlayerGuideManager:unForceClick( guideInfo )
	if guideInfo == nil then return end
	local topLayer = self:getTopLayer()
	if topLayer == nil then	return end
	if guideInfo.widget_name ~= "" then
		local widget = self:getWidgetByName(topLayer, guideInfo.widget_name)
		if widget then
			local clickHandleFunction = widget:getMEListener(TFWIDGET_CLICK)
			widget:addMEListener(TFWIDGET_CLICK,
			function()
				if self.now_step ~= 0 then
					self:removePanelBg()
					self:clickCallBack(guideInfo,topLayer)
				end
				TFFunction.call(clickHandleFunction, widget)
				if clickHandleFunction then
					widget:addMEListener(TFWIDGET_CLICK,clickHandleFunction)
				else
					widget:removeMEListener(TFWIDGET_CLICK)
				end
			end)
		end
	end
end

-- 全屏或者白块图片黑层点击处理
function PlayerGuideManager:panelbgClick( guideInfo )
	if self.m_guideInfo.node.guidePanel_bg == nil then
		return
	end
	local topLayer = self:getTopLayer()
	if topLayer == nil then	return end
	local widget = self.m_guideInfo.node.guidePanel_bg
	widget:setTouchEnabled(true)
	if widget.layerList then
		for i,v in ipairs(widget.layerList) do
			v:setTouchEnabled(false)
		end
	end
	widget:addMEListener(TFWIDGET_CLICK,
	function()
		self:clickCallBack(guideInfo,topLayer)
		self.next_step = guideInfo.next_step
		if guideInfo.next_functionId then
			self.now_functionId = guideInfo.next_functionId
		end
		self:removePanelBg()
		local next_guideInfo = PlayerGuideStepData:objectByID(guideInfo.next_step)
		if next_guideInfo and next_guideInfo.layer_name == topLayer.__cname then
			self:showGuideLayerByStepId(self.next_step,false)
		end
	end)
end

--强制的事件
function PlayerGuideManager:forceClick( guideInfo )
	if guideInfo == nil then return end
	local topLayer = self:getTopLayer()
	if topLayer == nil then	return end
	local layer_name = topLayer.__cname
	if guideInfo.widget_name and guideInfo.widget_name ~= "" then
		local widget = self:getWidgetByName(topLayer, guideInfo.widget_name)
		if widget then
			local clickHandleFunction = widget:getMEListener(TFWIDGET_CLICK)
			if clickHandleFunction then
				widget:addMEListener(TFWIDGET_CLICK,
				function()
					print("PlayerGuideManager:forceClick( guideInfo )")
					if self.now_step == 0 then
						TFFunction.call(clickHandleFunction, widget)
						widget:addMEListener(TFWIDGET_CLICK,clickHandleFunction)
						return
					end
					self:removePanelBg()
					self.next_step = guideInfo.next_step
					print("PlayerGuideManager:forceClick( guideInfo 111111111111)",self.next_step)
					if guideInfo.specialCall and guideInfo.specialCall == 6 then
						self:clickCallBack(guideInfo,topLayer)
					end
					widget:addMEListener(TFWIDGET_CLICK,clickHandleFunction)
					TFFunction.call(clickHandleFunction, widget)
					if guideInfo.specialCall == nil or guideInfo.specialCall ~= 6 then
						self:clickCallBack(guideInfo,topLayer)
					end
					if guideInfo.next_functionId then
						self.now_functionId = guideInfo.next_functionId
					end
					local next_guideInfo = PlayerGuideStepData:objectByID(guideInfo.next_step)
					if next_guideInfo and next_guideInfo.layer_name == layer_name then
						self:showGuideLayerByStepId(self.next_step,false)
					end
				end)
				return
			end
			local widgetClassName = widget:getDescription()
			if widgetClassName ~= "TFImage" and widgetClassName ~= "TFLabel" and widgetClassName ~= "TFLabelBMFont" then
				return
			end
		end
	elseif guideInfo.widget_rect then
		self.next_step = guideInfo.next_step
		if guideInfo.next_functionId then
			self.now_functionId = guideInfo.next_functionId
		end
		return
	end
	self:panelbgClick(guideInfo)
end


--设置点击事件
function PlayerGuideManager:setClickEvents(guideInfo)
	-- print("PlayerGuideManager:setClickEvents(guideInfo)")
	if guideInfo.force == false then
		self:unForceClick(guideInfo)
		self.next_step = guideInfo.next_step
		if guideInfo.save~= nil and guideInfo.save == true then
			self:saveGuideStep(true)
		end
		if guideInfo.next_functionId then
			self.now_functionId = guideInfo.next_functionId
		end
	else
		self:forceClick(guideInfo)
	end
end

-- 判断widget是否显示及执行action
function PlayerGuideManager:isWidgetRunning( guideInfo )
	if guideInfo.widget_name and guideInfo.widget_name ~= "" then
		-- print("PlayerGuideManager:isWidgetRunning( guideInfo )")
		local topLayer = self:getTopLayer()
		if topLayer == nil then
			return false
		end
		local widget = self:getWidgetByName(topLayer, guideInfo.widget_name)
		if widget == nil then
			return false
		end
		local num = CCDirector:sharedDirector():getActionManager():numberOfRunningActionsInTarget(widget)
		if num ~= 0 or widget:isVisible() == false then
			return true
		end
	end
	return false
end


-- 延迟指引界面的显示，通过定时器判断widget是否为空
function PlayerGuideManager:delayShowGuideLayerIfWidgetNil(stepId,save)
	if self.nTimerId then
		TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
	end
	self.nTimerId = TFDirector:addTimer(0, -1, nil,
		function()
			self:updateShowIfWidgetNil(stepId,save)
		end)
end
--判断是否取消定时器
function PlayerGuideManager:isCancelUpdateByWidgetNil( stepId )
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return 0
	end
	if not stepId or stepId == 0 then
		return 0
	end
	if self.now_step == stepId then
		return 0
	end
	local guideStepInfo = PlayerGuideStepData:objectByID(stepId)
	if guideStepInfo == nil then 
		return 0
	end
	if guideStepInfo.layer_name ~= topLayer.__cname then
		return 0
	end
	if guideStepInfo.widget_name and guideStepInfo.widget_name ~= "" then
		local widget = self:getWidgetByName(topLayer , guideStepInfo.widget_name)
		if widget == nil then
			return 1
		else
			return 2
		end
	end
	return 0
end

-- 定时器
function PlayerGuideManager:updateShowIfWidgetNil( stepId ,save)
	local num = self:isCancelUpdateByWidgetNil(stepId)
	if num == 1 then
		return
	elseif num == 2 then
		local guideStepInfo = PlayerGuideStepData:objectByID(stepId)
		if self.nTimerId then
			TFDirector:removeTimer(self.nTimerId)
			self.nTimerId = nil
		end
		self.now_step = stepId
		self:showGuideLayer(guideStepInfo,save)
	else
		if self.nTimerId then
			TFDirector:removeTimer(self.nTimerId)
		self.nTimerId = nil
		end
	end
end




-- 延迟指引界面的显示，通过定时器判断widget是否显示或执行action
function PlayerGuideManager:delayShowGuideLayer(guideInfo,save)
	if self.nTimerId then
		TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
	end
	self.nTimerId = TFDirector:addTimer(0, -1, nil,
		function()
			local topLayer = self:getTopLayer()
			if guideInfo.layer_name ~= topLayer.__cname then
				TFDirector:removeTimer(self.nTimerId)
        		self.nTimerId = nil
				return
			end
			self:updateShow(guideInfo,save)
		end)
end

-- 定时器
function PlayerGuideManager:updateShow( guideInfo ,save )
	if self:isWidgetRunning(guideInfo) then
		return
	end
	self:showAll(guideInfo,save)
	if self.nTimerId then
		TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
	end
end

-- 显示指引的所有层
function PlayerGuideManager:showAll( guideInfo ,save)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	local guidePanel_bg = self:getGuidePanelBg()
	topLayer:addChild(guidePanel_bg)
	self.m_guideInfo.node.guidePanel_bg = guidePanel_bg
	self:showForceLayer(guidePanel_bg ,guideInfo)
	self:showEffect(guidePanel_bg ,guideInfo)

	--modify by ZR, 暂时关闭个跳过
	--[[if self.now_functionId  >= 1 and self.now_functionId <= 20 then
		self.buttonTimerId = TFDirector:addTimer(TiaoguoTime*1000, 1, nil,
		function()
			if self:getTopLayer() ~= topLayer then
				if self.buttonTimerId then
					TFDirector:removeTimer(self.buttonTimerId)
					self.buttonTimerId = nil
				end
				return
			end
			local button = TFButton:create()
			guidePanel_bg:addChild(button)
			button:setTextureNormal("ui_new/common/tiaoguo.png")
			button:setAnchorPoint(ccp(1, 1))
			local pos = guidePanel_bg:convertToNodeSpace(ccp(GameConfig.WS.width, GameConfig.WS.height));
			button:setPosition(pos)
			button:setZOrder(100)
			button:addMEListener(TFWIDGET_CLICK,
			function()
				self:removePanelBg()
				self:endCallBack(guideInfo,topLayer)
				self.m_guideInfo.node = {}
				self.now_functionId = 0
				self.now_step = 0
				self.next_step = 0
				self:saveGuideStep_test()
			end)
		end)
		
	end]]--
	if guideInfo.sound and guideInfo.sound ~= "" then
		self:playEffect(guideInfo.sound ,guideInfo.soundTime*1000);
	end
	self:setClickEvents(guideInfo)

	if save then
		self:saveGuideStep(save)
	end
end

-- 显示指引
function PlayerGuideManager:showGuideLayer(guideInfo ,save)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	self:removePanelBg()
	self.m_guideInfo.node = {}
	self:beginCallBack(guideInfo)
	self:saveGuideStep(save)
	if self:isWidgetRunning(guideInfo) then
		self:delayShowGuideLayer(guideInfo,save)
		return
	end
	self:showAll(guideInfo,save)
end

--推图关卡的特殊操作
function PlayerGuideManager:missionLayerSpecial()
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	topLayer:setGuideBlockViisble(true ,true)
end

--推图关卡的特殊操作
function PlayerGuideManager:missionLayerSpecialEnd(topLayer)
	if topLayer and topLayer.__cname == "MissionLayer" then
		topLayer:setGuideBlockViisble(false,true)
	end
end

--推图关卡的特殊操作
function PlayerGuideManager:roleBookHechengLayerSpecial()
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	topLayer:setHechengOutViewScrollView(false)
end

--推图关卡的特殊操作
function PlayerGuideManager:roleBookHechengLayerSpecialEnd(topLayer)
	if topLayer and topLayer.__cname == "RoleBook_OnEquip" then
		topLayer:setHechengOutViewScrollView(true)
	end
end


--上阵的特殊操作
function PlayerGuideManager:armyLayerPutSpecial(guideInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	local num = StrategyManager:getFightRoleNum()
	topLayer:setGuideMode(num)

	local updatePosCallBack = function(event)
	-- print("PlayerGuideManager:armyLayerPutSpecial(guideInfo)")
		TFDirector:removeMEGlobalListener("armyLayerPutSpecial", updatePosCallBack );
        self:armyLayerPutSpecialEnd()
        self.next_step = guideInfo.next_step
		if guideInfo.save then
			self:saveGuideStep(guideInfo.save)
		end
		if guideInfo.next_functionId then
			self.now_functionId = guideInfo.next_functionId
		end
		-- print("self.now_functionId = ",self.now_functionId)
		local next_guideInfo = PlayerGuideStepData:objectByID(guideInfo.next_step)
		if next_guideInfo and next_guideInfo.layer_name == topLayer.__cname then
			self:showGuideLayerByStepId(self.next_step,false)
		end
    end;
    -- print("fick -------------------")
    local nTimerId = TFDirector:addTimer(0, 1, nil,
		function()
			TFDirector:addMEGlobalListener("armyLayerPutSpecial" ,updatePosCallBack ) ;
		end)

    
end

--上阵的特殊操作
function PlayerGuideManager:armyLayerPutSpecialEnd(topLayer)
	local _topLayer = topLayer or self:getTopLayer()
	if _topLayer == nil then
		return
	end
	if _topLayer.__cname ~= "ArmyLayer" then
		-- print("_topLayer.__cname ~= ArmyLayer  == ",_topLayer.__cname)
		return
	end
	_topLayer:setGuideMode(0)
	_topLayer:setChangePosGuide(0, 0)
end


--阵位换人的特殊操作
function PlayerGuideManager:armyLayerMoveSpecial(guideInfo)
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	local cardRole = CardRoleManager:getRoleByPos(4)
	if cardRole == nil or cardRole.outline ~= 2 then
		topLayer:setGuideMode(0)
		topLayer:setChangePosGuide(2, 4)
	end

	local _updatePosCallBack = function(event)
		TFDirector:removeMEGlobalListener("armyLayerMoveSpecial", _updatePosCallBack );
        self:armyLayerPutSpecialEnd()
        self.next_step = guideInfo.next_step
        if guideInfo.save then
			self:saveGuideStep(guideInfo.save)
		end
		if guideInfo.next_functionId then
			self.now_functionId = guideInfo.next_functionId
		end
		local next_guideInfo = PlayerGuideStepData:objectByID(guideInfo.next_step)
		if next_guideInfo and next_guideInfo.layer_name == topLayer.__cname  then
			self:showGuideLayerByStepId(self.next_step,false)
		end
    end;
    TFDirector:addMEGlobalListener("armyLayerMoveSpecial" ,_updatePosCallBack ) ;
end


function PlayerGuideManager:roleInfoSpecial( guideInfo )
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	topLayer:SetGuideMode(true)
end
function PlayerGuideManager:roleInfoSpecialEnd()
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	topLayer:SetGuideMode(false)
end
--成就的特殊操作
function PlayerGuideManager:taskLayerSpecial( guideInfo )
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	topLayer:SetGuideMode(true)
end
function PlayerGuideManager:taskLayerSpecialEnd()
	local topLayer = self:getTopLayer()
	if topLayer.__cname ~= "TaskLayer" then
		return
	end
	topLayer:SetGuideMode(false)
end

function PlayerGuideManager:taskLayerGotoSpecialEnd()
	print("taskLayerGotoSpecialEnd")
	AlertManager:closeAll()
	-- local topLayer = self:getTopLayer()
	-- if topLayer.__cname == nil then
	-- 	return
	-- end
	-- AlertManager:closeAllWithoutSpecial(topLayer.__cname)
end



--新手点击技能特殊操作
function PlayerGuideManager:XinshouEnd()
	self.now_step = 0
	FightManager:OnActionEnd()
end
-- 指引开始前的特殊操作
function PlayerGuideManager:beginCallBack(guideInfo)
	local special = guideInfo.specialCall
	if special == nil then return end
	if special == 1 then                                 --推图的特殊操作
		self:missionLayerSpecial()
	elseif special == 2 then                             --上阵的特殊操作
		self:armyLayerPutSpecial(guideInfo)
	elseif special == 3 then                             --阵位换人的特殊操作
		self:armyLayerMoveSpecial(guideInfo)
	elseif special == 4 then                             --成就的特殊操作
		self:taskLayerSpecial(guideInfo)
	elseif special == 6 then                             --成就的前往操作
		self:taskLayerSpecial(guideInfo)
	elseif special == 7 then                             --武学升阶特殊操作
		self:roleInfoSpecial(guideInfo)
	elseif special == 8 then                             --武学升阶特殊操作
		self:roleBookHechengLayerSpecial()
	end
end

-- 指引结束时的特殊操作
function PlayerGuideManager:endCallBack(guideInfo,topLayer)
	local special = guideInfo.specialCall
	-- print("PlayerGuideManager:endCallBack(guideInfo,topLayer)",special)
	if special == nil then return end
	if special == 1 then
		self:missionLayerSpecialEnd(topLayer)
	elseif special == 2 then                             --上阵的特殊操作
		self:armyLayerPutSpecialEnd()
	elseif special == 3 then                             --阵位换人的特殊操作
		self:armyLayerPutSpecialEnd()
	elseif special == 4 then                             --成就的特殊操作
		self:taskLayerSpecialEnd()
	elseif special == 5 then                             --新手
		self:XinshouEnd()
	elseif special == 6 then                             --成就的特殊操作
		self:taskLayerGotoSpecialEnd()
	elseif special == 7 then                             --武学升阶特殊操作
		self:roleInfoSpecialEnd()
	elseif special == 8 then                             --武学升阶特殊操作
		self:roleBookHechengLayerSpecialEnd(topLayer)
	end
end
--------------------------------------------------------------

function PlayerGuideManager:isFunctionOpen(functionId)
	if not self.bOpenGuide then
		return true
	end
	return self:isGuideFunctionOpen(functionId)
end

function PlayerGuideManager:IsGuidePanelVisible()
	if not self.bOpenGuide then
		return false
	end
	if self.now_step == 0 then
		return false
	end
	return true
end


--获得新手动画战斗信息
function PlayerGuideManager:GetGuideFightInfo()
	return PlayerGuideStepData:objectByID(10001)
end


--  新手指引 播放动画及战斗
function PlayerGuideManager:ShowGameBeginVideo(ui)
	if tolua.isnull(ui) then
		return false
	end
	if not self.bOpenGuide then
		return false
	end

	local guideInfo = self:GetGuideFightInfo()
	if guideInfo == nil then
		return false
	end

	TFAudio.stopMusic()
	if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 then
		FightManager:BeginGuideFight(guideInfo)
		return true
	end

	local armatureIDList = TFArray:new()
	local roleList = guideInfo.role
    for index=1,#roleList do
		local roleid = roleList[index]
		if roleid ~= 0 then
			local roleInfo = RoleData:objectByID(roleid)
			local armatureID = roleInfo.image
			local info = {roleid = roleid , armatureID = armatureID}
			armatureIDList:push(info)
		end
    end

    local npcList = guideInfo.npc
	for i=1,#npcList do
		local npcid = npcList[i]
		if npcid ~= 0 then
			local fightRole = {}
			local npcInfo = NPCData:objectByID(npcid)
			local armatureID = npcInfo.image
			local info = {roleid = npcid , armatureID = armatureID}
			armatureIDList:push(info)
		end
	end


	function loadArmatureID( info )
		armatureID = info.armatureID
		local resPath = "armature/"..armatureID..".xml"
		if TFFileUtil:existFile(resPath) then
			TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
		else
			print(resPath.."not find")
			if bEnemyRole then
				armatureID = 10006
			end
			TFResourceHelper:instance():addArmatureFromJsonFile("armature/"..armatureID..".xml")
		end
		local armature = TFArmature:create(armatureID.."_anim")
		if armature == nil then
			assert(false, "armature"..armatureID.."create error")
			return
		end
		if bEnemyRole then
			GameResourceManager:addEnemy( info.roleid , armature )
		end
	end

	local nTimerId = TFDirector:addTimer(0.5, -1, nil,
		function()
			local info = armatureIDList:pop()
			if info == nil then
				TFDirector:removeTimer(nTimerId)
				nTimerId = nil
				return
			end
			loadArmatureID(info)
			if armatureIDList:length() <= 0 then
				TFDirector:removeTimer(nTimerId)
				nTimerId = nil
			end
		end)

	local nViewHeight = GameConfig.WS.height
    local nViewWidth = GameConfig.WS.width
	local maskPanel = TFPanel:create()
	maskPanel:setSize(ccs(nViewWidth, nViewHeight))
	maskPanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
	maskPanel:setBackGroundColor(ccc3(0, 0, 0))
	maskPanel:setTouchEnabled(true)
	maskPanel:setZOrder(1000)
	ui:addChild(maskPanel)


	local video = TFVideoPlayer:create()
	maskPanel:addChild(video)
	video:setSize(ccs(1136, 640))
	video:setAnchorPoint(ccp(0.5, 0.5))
	video:setPosition(ccp(nViewWidth/2, nViewHeight/2))
	video:setFileName("effect/gamebegin.mp4")
	video:play()
	self.isPlayGuideVideo = true
	video:setTouchEnabled(true)
	video:addMEListener(TFVIDEO_COMPLETE, 
	function()
		if nTimerId then
			TFDirector:removeTimer(nTimerId)
			nTimerId = nil
		end
		self.isPlayGuideVideo = false
		maskPanel:removeFromParent()
		FightManager:BeginGuideFight(guideInfo)
	end)

	-- local button = TFButton:create()
	-- maskPanel:addChild(button)
	-- button:setTextureNormal("ui_new/common/tiaoguo.png")
	-- button:setAnchorPoint(ccp(1, 1))
	-- button:setPosition(ccp(nViewWidth, nViewHeight))
	-- button:setZOrder(10)
	-- button:addMEListener(TFWIDGET_CLICK,
	-- function()
	-- 	if nTimerId then
	-- 		TFDirector:removeTimer(nTimerId)
	-- 		nTimerId = nil
	-- 	end
	-- 	self.isPlayGuideVideo = false
	-- 	maskPanel:removeFromParent()
	-- 	FightManager:BeginGuideFight(guideInfo)
	-- end)
	-- button:setVisible(false)

	local click_exit = 0

	video:addMEListener(TFWIDGET_CLICK,
	function()
		click_exit = click_exit + 1
		if click_exit == 2 then
				if nTimerId then
					TFDirector:removeTimer(nTimerId)
					nTimerId = nil
				end
				self.isPlayGuideVideo = false
				maskPanel:removeFromParent()
				FightManager:BeginGuideFight(guideInfo)
		end
		-- if button:isVisible() == false then
		-- 	button:setVisible(true)
		-- end
	end)
    maskPanel:addMEListener(TFWIDGET_CLICK,
    function()
		click_exit = click_exit + 1
		if click_exit == 2 then
				if nTimerId then
					TFDirector:removeTimer(nTimerId)
					nTimerId = nil
				end
				self.isPlayGuideVideo = false
				maskPanel:removeFromParent()
				FightManager:BeginGuideFight(guideInfo)
		end
		-- if button:isVisible() == false then
		-- 	button:setVisible(true)
		-- end
    end)
	return true
end

--测试
function PlayerGuideManager:saveGuideStep_test()
	--for guide in PlayerGuideData:iterator() do 
	for i=1,35 do
		self:saveFunctionOpenGuide(i)
	end
end


function PlayerGuideManager:getEquipOpenLevel()
	local configure = FunctionOpenConfigure:objectByID(101)
	if configure then
		return configure.level
	end
	return 5
end
--获取功能开放等级
function PlayerGuideManager:getFunctionOpenLevel(id)
	local guide = PlayerGuideData:objectByID(id)
	if guide and guide.conditions and guide.conditions.level then
		return guide.conditions.level
	end
	if guide and guide.conditions and guide.conditions.minLevel then
		return guide.conditions.minLevel
	end
	return 5
end
function PlayerGuideManager:getFunctionOpenLevelByName(name)
	for guide in PlayerGuideData:iterator() do
		if guide.name == name then
			if guide.conditions and guide.conditions.level then
				return guide.conditions.level
			end
			if guide.conditions and guide.conditions.minLevel then
				return guide.conditions.minLevel
			end
		end
	end
	return 0
end
function PlayerGuideManager:isFunctionOpenByName( name )
	if not self.bOpenGuide then
		return true
	end
	for guide in PlayerGuideData:iterator() do
		if guide.name == name then
			return self:isGuideFunctionOpen(guide.id)
		end
	end
	return false
end
function PlayerGuideManager:getGuideByName(name )
	for guide in PlayerGuideData:iterator() do
		if guide.name == name then
			return guide
		end
	end
	return nil
end
function PlayerGuideManager:isGuideNow(id)
	if not self.bOpenGuide then
		return false
	end
	if self.now_step == 0 then
		return false
	end
	if self.next_step == 0 then
		return false
	end
	return self.now_functionId == id
end
function PlayerGuideManager:isGuideNowByName(name)
	if not self.bOpenGuide then
		return false
	end
	local guide  = self:getGuideByName(name)
	if self.now_functionId == guide.id and self.next_step ~= 0 then
		return true
	end
	return false
end

function PlayerGuideManager:addAnimationEffect( effectName ,panelbg,pos)
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/"..effectName..".xml")
	local effect = TFArmature:create(effectName.."_anim")
	if effect ~= nil then
		effect:setAnimationFps(GameConfig.ANIM_FPS)

		effect:setPosition(ccp(pos.x, pos.y))
		panelbg:addChild(effect)
	end
	return effect
end
--使用动画
function PlayerGuideManager:showAnimation( guideInfo )
	-- print("PlayerGuideManager:showAnimation( guideInfo )")
	if guideInfo.widget_name ==nil or guideInfo.widget_name == "" then
		return
	end
	local topLayer = self:getTopLayer()
	local widget = self:getWidgetByName(topLayer , guideInfo.widget_name)
	if widget == nil then
		print("showGuideLayerByStepId widget == nil",topLayer.__cname)
		return
	end
	if guideInfo.picture == nil then
		print("没有展示动画的图片")
		return
	end
	self:removePanelBg()
	self.m_guideInfo.node = {}
	self:beginCallBack(guideInfo)
	self:saveGuideStep(guideInfo.save)
	--透明的touch层
	local guidePanel_bg = self:getGuidePanelBg()
	topLayer:addChild(guidePanel_bg)
	guidePanel_bg:setTouchEnabled(true)
	self.m_guideInfo.node.guidePanel_bg = guidePanel_bg

	local effectPanel = TFPanel:create()
	effectPanel:setAnchorPoint(ccp(0, 0))
	effectPanel:setSize(CCSize(1,1))
	local effect_pos = guideInfo.effect_pos or {0,0}
	effectPanel:setPosition(ccp(GameConfig.WS.width /2+effect_pos[1],GameConfig.WS.height/2+effect_pos[2]))
	guidePanel_bg:addChild(effectPanel)

	local bottom_effect = self:addAnimationEffect("function_open_bottom",effectPanel,{x= 0,y = 0})
	local pic = TFImage:create()
	pic:setTexture(guideInfo.picture)
	pic:setAnchorPoint(ccp(0.5,0.5))
	pic:setPosition(ccp( 0,0))
	effectPanel:addChild(pic)
	local top_effect = self:addAnimationEffect("function_open_top",effectPanel,{x= 0,y = 0})
	TFDirector:addTimer(1,1,nil,function ()
		if top_effect then 
			top_effect:playByIndex(0, -1, -1, 0)
		end
	end)

	if topLayer.__cname == "MenuLayer" then
		TFDirector:dispatchGlobalEventWith(PlayerGuideManager.BUTTON_OPEN, widget);
	end

	-- local pos = widget:getParent():convertToWorldSpaceAR(widget:getPosition())
	-- pos = guidePanel_bg:convertToNodeSpace(pos);
	-- local anchorPoint = widget:getAnchorPoint()
	-- local x = 0 --pos.x -- anchorPoint.x * widget:getSize().width
	-- local y = 0 --pos.y -- anchorPoint.y * widget:getSize().height
	

	-- self.moreBtnTimerId = TFDirector:addTimer(3000 ,1,nil,function ()
	-- 		if self.moreBtnTimerId then
	-- 			TFDirector:removeTimer(self.moreBtnTimerId)
	-- 			self.moreBtnTimerId = nil
	-- 		end
			local pos = widget:getParent():convertToWorldSpaceAR(widget:getPosition())
			pos = guidePanel_bg:convertToNodeSpace(pos);
			local anchorPoint = widget:getAnchorPoint()
			local x = pos.x
			local y = pos.y
			local moveTween = {
				target = effectPanel,
				{
					delay = 9/24,
					duration = 1,
					x = x,
					y = y,
					onComplete = function ()
						widget:setVisible(true)
						self:showNextGuideStep();
					end,
				}
			}
			TFDirector:toTween(moveTween)
		-- end )

	local scaleTween = {
		target = pic,
		{
				duration = 0.125,
				scale = 1.26,
		},
		{
				duration = 0.25,
				scale = 1,
		}
	}

	TFDirector:toTween(scaleTween)
	local alphaTween = {
		target = bottom_effect,
		{
			delay = 0.25,
			onComplete = function ()
				bottom_effect:playByIndex(0, -1, -1, 0)
			end,
		},
		{
			duration = 51/24,
			alpha = 0,
		}
	}

	TFDirector:toTween(alphaTween)

end
--使用原画
function PlayerGuideManager:showDrawing( guideInfo )
	-- print("PlayerGuideManager:showDrawing( guideInfo )")
	local topLayer = self:getTopLayer()
	if guideInfo.picture == nil then
		print("没有展示动画的图片")
		return
	end
	self:removePanelBg()
	self.m_guideInfo.node = {}
	self:beginCallBack(guideInfo)
	self:saveGuideStep(guideInfo.save)

	local guidePanel_bg = self:getGuidePanelBg()
	topLayer:addChild(guidePanel_bg)
	if guideInfo.isgray then
		guidePanel_bg:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
		guidePanel_bg:setBackGroundColorOpacity(80)
		guidePanel_bg:setBackGroundColor(ccc3(0,0,0))
	end
	guidePanel_bg:setTouchEnabled(true)
	self.m_guideInfo.node.guidePanel_bg = guidePanel_bg

	local pic_bg = TFImage:create()
	pic_bg:setTexture("ui_new/guide/bg_haibao.png")
	pic_bg:setAnchorPoint(ccp(0.5,0.5))
	pic_bg:setScale9Enabled(false)
	local bg_size = guideInfo.bg_size or ccs(890,564)
	pic_bg:setSize(bg_size)
	local bg_pos = guideInfo.bg_pos or {0,-30}
	pic_bg:setPosition(ccp(GameConfig.WS.width /2+bg_pos[1],GameConfig.WS.height/2+bg_pos[2]))
	guidePanel_bg:addChild(pic_bg)

	local pic = TFImage:create()
	pic:setTexture(guideInfo.picture)
	pic:setAnchorPoint(ccp(0.5,0.5))
	local pic_pos = guideInfo.pic_pos or {0,0}
	pic:setPosition(ccp(GameConfig.WS.width /2+pic_pos[1],GameConfig.WS.height/2+pic_pos[2]))
	guidePanel_bg:addChild(pic)

	if guideInfo.close_btn then
		local button_close = TFButton:create()
		pic:addChild(button_close)
		button_close:setTextureNormal("ui_new/common/common_close_icon.png")
		button_close:setAnchorPoint(ccp(1, 1))
		button_close:setPosition(ccp(pic:getContentSize().width/2,pic:getContentSize().height/2))
		button_close:addMEListener(TFWIDGET_CLICK,
		function()
			self:showNextGuideStep();
		end)
	end

	local button_goto = TFButton:create()
	pic:addChild(button_goto)
	local goto_file = "ui_new/guide/btn_zhidaole.png"
	if guideInfo.goto_name ~= nil then
		goto_file = guideInfo.goto_name
	end
	button_goto:setTextureNormal(goto_file)
	button_goto:setAnchorPoint(ccp(0.5, 1))
	button_goto:setPosition(ccp(0,-pic:getContentSize().height/2 - 3))
	button_goto:addMEListener(TFWIDGET_CLICK,
	function()
		if guideInfo.taskType then
			local taskData = {}
			taskData.type = guideInfo.taskType
			taskData.target_value = guideInfo.target_value or 0
			TaskManager:CanGoToLayer(taskData, true)
		end
		self:showNextGuideStep();
	end)
end
function PlayerGuideManager:doGuideByGuideID(guideid)
	if not self.bOpenGuide then
		return
	end
	local guideInfo = PlayerGuideData:objectByID(guideid)
	if guideInfo == nil then
		print("guideInfo == nil  id = ",guideid)
		return
	end
	if PlayerGuideManager:isGuideFunctionOpen(guideid) then
		return false
	end
	if self.next_step ~= 0 then
		return
	end
	if self.m_guideInfo and self.m_guideInfo.node and self.m_guideInfo.node.guidePanel_bg then
		if not tolua.isnull(self.m_guideInfo.node.guidePanel_bg) then
			return
		end
	end
	local topLayer = self:getTopLayer()
	if topLayer.__cname ~= guideInfo.trigger_layer then
		return
	end
	self.now_functionId = guideid
	self:showGuideLayerByStepId(guideInfo.process,false)
	self.specialGuideId = 0 
	return
end
function PlayerGuideManager:closeGuideByGuideID(guideid)
	if not self.bOpenGuide then
		return
	end
	if self.now_functionId == guideid then
		self:removePanelBg()
		self.m_guideInfo.node = {}
		self.now_functionId = 0
		self.now_step = 0
		self.next_step = 0
	end
	return
end


function PlayerGuideManager:showNextGuideStep_taskGoto()
	if self.now_functionId  == nil or  self.now_functionId == 0 then
		return
	end
	if self.now_step == nil or self.now_step == 0 then
		return
	end
	local topLayer = self:getTopLayer()
	if topLayer == nil then
		return
	end
	local guideInfo = PlayerGuideStepData:objectByID(self.now_step)
	if guideInfo.specialCall == nil or guideInfo.specialCall ~= 6 then
		return
	end
	self:clickCallBack(guideInfo,topLayer)
	if guideInfo.next_functionId then
		self.now_functionId = guideInfo.next_functionId
	end
	self.next_step = guideInfo.next_step
	self:removePanelBg()
	AlertManager:closeAll()
end
return PlayerGuideManager:new()