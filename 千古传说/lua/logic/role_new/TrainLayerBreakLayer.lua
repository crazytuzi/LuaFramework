
local TrainLayerBreakLayer = class("TrainLayerBreakLayer", BaseLayer)

--local trainNames = {"带脉","冲脉","任脉","督脉","跷脉","维脉"};
local trainNames = localizable.trainLayer_trainNames;
local acupointCapacity = 6


function TrainLayerBreakLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.role.TrainLayerBreak")

end

function TrainLayerBreakLayer:initUI( ui )

	self.super.initUI(self, ui)

	self.pointBtnTab = {}
	for i=1,acupointCapacity do
		local pointNode = TFDirector:getChildByPath(ui, 'img_acupoint_'..i)
		self.pointBtnTab[i] = {}
		self.pointBtnTab[i].btnNormal = TFDirector:getChildByPath(pointNode, "btn_point")
		self.pointBtnTab[i].level = TFDirector:getChildByPath(ui, "txt_dengji"..i)
	end

	self.btn_close = TFDirector:getChildByPath(ui, 'btn_close')
	self.btn_level_up = TFDirector:getChildByPath(ui, 'btn_level_up')
	self.txt_consume = TFDirector:getChildByPath(ui, 'txt_consume')
	self.img_jiantou = TFDirector:getChildByPath(ui, 'img_jiantou')

	self.currDetail = {}
	self.currDetail.name = TFDirector:getChildByPath(ui, 'lbl_acupoint_lv1')
	self.currDetail.attr = TFDirector:getChildByPath(ui, 'txt_attribute_name2')
	self.currDetail.value = TFDirector:getChildByPath(ui, 'txt_attribute_value2')

	self.nextDetail = {}
	self.nextDetail.name = TFDirector:getChildByPath(ui, 'lbl_acupoint_lv')
	self.nextDetail.attr = TFDirector:getChildByPath(ui, 'txt_attribute_name')
	self.nextDetail.value = TFDirector:getChildByPath(ui, 'txt_attribute_value')

	self.panel_details_1 = TFDirector:getChildByPath(ui, 'panel_details_1')

	self.txt_num = TFDirector:getChildByPath(ui, 'txt_num')

	self.txt_baifen = TFDirector:getChildByPath(ui, 'txt_baifen')
	self.txt_cutdown = TFDirector:getChildByPath(ui, 'txt_cutdown')

	self.btn_help = TFDirector:getChildByPath(ui, 'btn_help')

	self.img_di = TFDirector:getChildByPath(ui, 'img_di')
	local img_shenfa     = TFDirector:getChildByPath(self.img_di, 'img_shenfa')
    local img_kangbao    = TFDirector:getChildByPath(self.img_di, 'img_kangbao')
    local img_shanbi     = TFDirector:getChildByPath(self.img_di, 'img_shanbi')
    local img_baoji      = TFDirector:getChildByPath(self.img_di, 'img_baoji')
    local img_fangyu     = TFDirector:getChildByPath(self.img_di, 'img_fangyu')
    local img_mingzhong  = TFDirector:getChildByPath(self.img_di, 'img_mingzhong')
    self.imgs = {[3]=img_fangyu, [5]=img_shenfa, [12]=img_baoji, [13]=img_kangbao, [14]=img_mingzhong, [15]=img_shanbi}

	self.currChoseIdx = 1
end

function TrainLayerBreakLayer:removeUI()
	
	self.super.removeUI(self)

end

function TrainLayerBreakLayer:dispose()
	self.super.dispose(self)
end

function TrainLayerBreakLayer:onShow()
	self.super.onShow(self)

	local num = MainPlayer:getVesselBreachValue()
	--self.txt_num:setText('(拥有 '..num..')')
	self.txt_num:setText(stringUtils.format(localizable.changetProLayer_have,num))
	
	self:refreshData()
	self:showPointList()
	self:showDetails(self.currChoseIdx)
end

function TrainLayerBreakLayer:refreshUI()
		
end

function TrainLayerBreakLayer:registerEvents()
	self.super.registerEvents(self)

	for i=1,acupointCapacity do
		self.pointBtnTab[i].btnNormal:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onChoseClickHandle),1)
		self.pointBtnTab[i].btnNormal.logic = self
		self.pointBtnTab[i].btnNormal.idx = i
	end
	self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle),1)
	self.btn_close.logic = self
	self.btn_level_up:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onLevelUpClickHandle),1)
	self.btn_level_up.logic = self
	self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHelpClickHandle),1)
	self.btn_help.logic = self


	self.refreshWindowCallBack = function (event)
        self:onShow()
        local data = event.data[1]
        print(data)
        self:setCutDownTimer()
        local pos = data.acupointInfo.position
        local btn = self.pointBtnTab[pos].btnNormal

        if data.success == false then
        	toastMessage(localizable.JINGMAI_SURMOUNT_FAIL)
        	-- self:addResultEffect(btn,'role_trainfail')
        	self:addResultEffect(btn,'lianti8')
        else
        	toastMessage(localizable.JINGMAI_SURMOUNT_SUCCESS)
        	self:addSuccessEffect(btn)
        	-- self:addResultEffect(btn,'equipment_refining')
        	self:addResultEffect(btn,'lianti7')
        end
    end
    TFDirector:addMEGlobalListener(CardRoleManager.ACUPOINT_BREACH_RESULT, self.refreshWindowCallBack)	
    
end

function TrainLayerBreakLayer:removeEvents()
	for i=1,acupointCapacity do
		self.pointBtnTab[i].btnNormal:removeMEListener(TFWIDGET_CLICK)
	end
	self.btn_close:removeMEListener(TFWIDGET_CLICK)
	self.btn_level_up:removeMEListener(TFWIDGET_CLICK)

	TFDirector:removeMEGlobalListener(CardRoleManager.ACUPOINT_BREACH_RESULT, self.refreshWindowCallBack)
	self.refreshWindowCallBack = nil	

	if self.successEffect then
		self.successEffect:removeMEListener(TFARMATURE_COMPLETE)
		self.successEffect:removeFromParent()
		self.successEffect = nil
	end
	
    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end
	self.super.removeEvents(self)
	
end

function TrainLayerBreakLayer:loadData(gmId)
	self.roleGmId = gmId	

	local btn = self.pointBtnTab[self.currChoseIdx].btnNormal
	self:addXuanzhongEffect(btn,"lianti10")

	self:setCutDownTimer()
end

function TrainLayerBreakLayer.onCloseClickHandle( sender )
	AlertManager:close(AlertManager.TWEEN_NONE)
end

function TrainLayerBreakLayer.onChoseClickHandle( sender )
	local self = sender.logic

	self.currChoseIdx = sender.idx
	local btn = self.pointBtnTab[self.currChoseIdx].btnNormal
	self:addXuanzhongEffect(btn,"lianti10")
	self:showDetails(self.currChoseIdx)
end

function TrainLayerBreakLayer.onLevelUpClickHandle( sender )
	local self = sender.logic
	
	local cardRole = CardRoleManager:getRoleByGmid( self.roleGmId )
	if cardRole == nil then
		print('找不到角色 = ',self.roleGmId)
		return
	end
	local extraLianTiInfo = cardRole:getExtraLianTiAttri()
	local currInfo = cardRole:GetAcupointInfo(self.currChoseIdx) or {}
	local breachLevel = currInfo.breachLevel or 0
	local Level = currInfo.level or 0
	local configure = MeridianConfigure:objectByID(cardRole.id)
	local attKey = configure:getAttributeKey(self.currChoseIdx)
	local maxLevel = AcupointBreachData:getMaxLevelByLevel(attKey,Level)
	local nextInfo = AcupointBreachData:getData( attKey, breachLevel+1 )
	if nextInfo then
		if breachLevel >= maxLevel + extraLianTiInfo.breakthrough then
			--toastMessage('该经脉等级不足')
			toastMessage(localizable.trainLayer_not)
			return
		end
		local activity	= string.split(nextInfo.consume,'_')
		local goodsId = tonumber(activity[2])
		local goodsNum = tonumber(activity[3])
		local bagNum = MainPlayer:getVesselBreachValue()
		
		if bagNum < goodsNum then
			toastMessage(localizable.not_enough_jinglu)
	    	return
		end
	end
    CardRoleManager:AcupointInfoLevelUp(self.roleGmId, self.currChoseIdx)
end

function TrainLayerBreakLayer:addXuanzhongEffect( widget , effectName )
    if self.xuanzhong_effect then
        self.xuanzhong_effect:removeFromParentAndCleanup(false)
        self.xuanzhong_effect:playByIndex(0, -1, -1, 1)
    else
        TFResourceHelper:instance():addArmatureFromJsonFile("effect/"..effectName..".xml")
        local effect = TFArmature:create(effectName.."_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:playByIndex(0, -1, -1, 1)
        effect:setScale(0.65)
        effect:setPosition(ccp(-23,39))
        self.xuanzhong_effect = effect
    end
    widget:addChild(self.xuanzhong_effect)
end

function TrainLayerBreakLayer:addSuccessEffect( widget )
	-- if self.successEffect then
	-- 	self.successEffect:removeMEListener(TFARMATURE_COMPLETE)
	-- 	self.successEffect:removeFromParent()
	-- 	self.successEffect = nil
	-- end
	
 --    local resPath = "effect/role_train.xml"
 --    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
 --    local effect = TFArmature:create("role_train_anim")

 --    effect:setAnimationFps(GameConfig.ANIM_FPS)
	-- effect:setPosition(ccp(0,0))
 --    effect:setZOrder(100)
	-- self.successEffect = effect    
 --    self.successEffect:playByIndex(0, -1, -1, 0)
	-- widget:addChild(effect)

 --    effect:addMEListener(TFARMATURE_COMPLETE,function()
 --        effect:removeFromParent()
 --        self.successEffect = nil
 --    end)
	local effect = widget.effect
	if not effect then
	    effect = Public:addEffect("lianti6", widget, 0, 0, 1, 0)
	    effect:setZOrder(100)
	    widget.effect = effect
	else
	    ModelManager:playWithNameAndIndex(effect, "", 0, 0, -1, -1)
	end
end

function TrainLayerBreakLayer:addResultEffect( widget, effectName )	
	-- if self.rightEffect then
	-- 	self.rightEffect:removeMEListener(TFARMATURE_COMPLETE)
	-- 	self.rightEffect:removeFromParent()
	-- 	self.rightEffect = nil
	-- end

 --    TFResourceHelper:instance():addArmatureFromJsonFile("effect/ui/"..effectName..".xml")
 --    local effect = TFArmature:create(effectName.."_anim")
 --    effect:setAnimationFps(GameConfig.ANIM_FPS)
 --    self.panel_details_1:addChild(effect)
 --    effect:setPosition(ccp(90,110))
 --    effect:setScaleX(0.8)
 --    effect:setZOrder(100)
 --    self.rightEffect = effect
 --    self.rightEffect:playByIndex(0, -1, -1, 0)

 --    effect:addMEListener(TFARMATURE_COMPLETE,function()
 --        effect:removeFromParent()
 --        self.rightEffect = nil
 --    end)
	local effect = self.panel_details_1.effect
	if effect then
		self.panel_details_1.effect:removeFromParent()
	end
	self.panel_details_1.effect = Public:addEffect(effectName, self.panel_details_1, 100, 180, 1, 0)
	self.panel_details_1.effect:setZOrder(100)
	if effectName == "lianti7" then
		self.panel_details_1.effect:setScale(1.9)
	end
end

function TrainLayerBreakLayer:showPointList()
	for i=1,acupointCapacity do
		local info = self.dataTab[i] or {}
		local level = info.TupoLevel or 0
		if level > 0 then
			self.pointBtnTab[i].level:setVisible(true)
			self.pointBtnTab[i].level:setText('+'..level)
		else
			self.pointBtnTab[i].level:setVisible(false)
		end
	end
end

function TrainLayerBreakLayer:showDetails(idx)

	local currInfo = self.dataTab[idx]
	if currInfo == nil then
		print('找不到经脉编号：',idx)
		return 
	end

	self.img_jiantou:setVisible(true)
	self.nextDetail.name:setVisible(true)
	self.nextDetail.attr:setVisible(true)
	self.nextDetail.value:setVisible(true)

	if currInfo.TupoLevel > 0 then
		self.currDetail.name:setText(trainNames[currInfo.VesselIdx]..'+'..currInfo.TupoLevel)
	else
		self.currDetail.name:setText(trainNames[currInfo.VesselIdx])
	end	
	--self.currDetail.attr:setText(AttributeTypeStr[currInfo.AttrIdx].."成长")
	self.currDetail.attr:setText(stringUtils.format(localizable.trainLayer_chengzhang, AttributeTypeStr[currInfo.AttrIdx]))
	self.currDetail.value:setText(currInfo.CurrGrowth)

	local consume = 0
	local nextTupo = currInfo.TupoLevel + 1
	self.nextDetail.name:setText(trainNames[currInfo.VesselIdx]..'+'..nextTupo)
	--self.nextDetail.attr:setText(AttributeTypeStr[currInfo.AttrIdx].."成长")
	self.nextDetail.attr:setText(stringUtils.format(localizable.trainLayer_chengzhang, AttributeTypeStr[currInfo.AttrIdx]))
	local info = AcupointBreachData:getData( currInfo.AttrIdx, nextTupo )
	if info then
		self.nextDetail.value:setText(info.value)
		local activity	= string.split(info.consume,'_')
		local goodsId = tonumber(activity[2])
		local goodsNum = tonumber(activity[3])
		consume = goodsNum
	else
		self.img_jiantou:setVisible(false)
		self.nextDetail.name:setVisible(false)
		self.nextDetail.attr:setVisible(false)
		self.nextDetail.value:setVisible(false)
	end

	local level = self.dataTab[idx].TupoLevel
	if level > 0 then
		self.pointBtnTab[idx].level:setVisible(true)
		self.pointBtnTab[idx].level:setText('+'..level)
	else
		self.pointBtnTab[idx].level:setVisible(false)
	end

	self.txt_consume:setText(consume)
end

function TrainLayerBreakLayer:refreshData()
	self.dataTab = {}
	local cardRole = CardRoleManager:getRoleByGmid( self.roleGmId )
	if cardRole == nil then
		print('找不到角色 = ',self.roleGmId)
		return
	end	

	for i,img in pairs(self.imgs) do
        img:setVisible(false)
    end
	for i=1,acupointCapacity do
		self:refreshDataOne(i, cardRole)
	end
end

function TrainLayerBreakLayer:refreshDataOne(idx, cardRole)
	self.dataTab[idx] = {}
	self.dataTab[idx].VesselIdx = idx
	local AcupointInfo = cardRole:GetAcupointInfo(idx) or {}		
	
	self.dataTab[idx].VesselLevel = AcupointInfo.level or 0
	self.dataTab[idx].TupoLevel = AcupointInfo.breachLevel or 0
	local configure = MeridianConfigure:objectByID(cardRole.id)
	local attKey = configure:getAttributeKey(idx)
	self.dataTab[idx].AttrIdx = attKey
	local img = self.imgs[attKey]
    if img then img:setVisible(true) end
	local info = AcupointBreachData:getData( attKey, self.dataTab[idx].TupoLevel )
	self.dataTab[idx].CurrGrowth = info.value	
end

function TrainLayerBreakLayer:getGoodsNumInBag()
	-- local tool = BagManager:getItemById(30052)
	-- local num = 0
	-- if tool then
	-- 	num = tool.num
	-- else
	-- 	print('背包中找不到道具：30052')
	-- end
	-- return num
end

function TrainLayerBreakLayer:setCutDownTimer()

	local totalRate,cutDownTime = CardRoleManager:getBreachCutDownTime()	
	-- print('cutDownTime = ',cutDownTime)
	self.txt_baifen:setText(math.floor(totalRate/100)..'%')

    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end

    local function showCutDownString( times )
	    local str
	    local min = math.floor(times/60)
	    local sec = times%60
		str = string.format("%02d",min)..":"..string.format("%02d",sec)		
		return str
    end

    local timeStr = showCutDownString( cutDownTime )
    -- print('timeStr = ',timeStr)
    self.txt_cutdown:setText(timeStr)
    self.txt_cutdown:setVisible(true)
    if totalRate == 10000 then
    	self.txt_cutdown:setVisible(false)
		return
	end
	self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function () 
		print('cutDownTime = ',cutDownTime)
	    if cutDownTime <= 0 then
	        if self.countDownTimer then
	            TFDirector:removeTimer(self.countDownTimer)
	            self.countDownTimer = nil
	        end
	        local timeStr = showCutDownString( cutDownTime )
    		self.txt_cutdown:setText(timeStr)
	        self:setCutDownTimer()
	    else
	        cutDownTime = cutDownTime - 1
	        local timeStr = showCutDownString( cutDownTime )
    		self.txt_cutdown:setText(timeStr)
	    end
	end)
end

function TrainLayerBreakLayer.onHelpClickHandle( btn )
	CommonManager:showRuleLyaer( 'jingmaitupo' )
end

return TrainLayerBreakLayer