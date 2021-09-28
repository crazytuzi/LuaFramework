local PetStrengthLayer = class("PetStrengthLayer",UFCCSNormalLayer)
local EffectNode = require "app.common.effects.EffectNode"
require("app.cfg.pet_info")

function PetStrengthLayer:create(container)
    local layer = PetStrengthLayer.new("ui_layout/petbag_Strength.json",container) 
    return layer
end

function PetStrengthLayer:ctor(json,container)
	self.super.ctor(self,json)
	self._container = container
	self._pet = container:getPet()

	self._box = self:getImageViewByName("Image_choose")
	self._strPanel = self:getPanelByName("Panel_up")
	self._maxLabel = self:getLabelByName("Label_max")
	self._maxLabel:setText(G_lang:get("LANG_PET_STRENGTH_MAXEXP"))
	self._maxLabel:createStroke(Colors.strokeBrown, 1)
	self._autoButton = self:getButtonByName("Button_auto")
	self._strButton = self:getButtonByName("Button_strength")
	self._moneyLabel = self:getLabelByName("Label_money")
	self._expLabel = self:getLabelByName("Label_exp")
	self._expLabel:createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_panelTitle1"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_panelTitle2"):createStroke(Colors.strokeBrown, 1)

	self._acquireExp = 0
	self._itemList = {}
	self._oldLevel = 0
	self._playing = false

	for i = 1 , 5 do 
		self:getWidgetByName("Image_boardBg"..i):setTouchEnabled(true)
		self:registerWidgetClickEvent("Image_boardBg"..i, function ( ... )
			if self._playing then
				return
			end
			self:clickItem(i)
		end)
	end

	self:registerBtnClickEvent("Button_auto", function ( ... )
		if self._playing then
			return
		end
		self:autoAdd()
	end)
	self:registerBtnClickEvent("Button_strength", function ( ... )
		if self._playing then
			return
		end
		self:goStrength()
	end)
end

function PetStrengthLayer:onLayerEnter()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_PET_UPLVL, self._onStrengthResult, self)

	self:updateView()
end

function PetStrengthLayer:enter()
	self._pet = G_Me.bagData.petData:getPetById(self._pet.id) 
	self:_onSelectedItems({},0)
	self._playing = false
	G_flyAttribute._clearFlyAttributes( )
	self:enterViewAnime()
end

function PetStrengthLayer:exit()
	-- self:exitViewAnime(callback)
end

function PetStrengthLayer:adapterLayer()
	local maxHeight = display.height
	self:getPanelByName("Panel_middle"):setPosition(ccp(0,maxHeight*2/3-250))
	self:getPanelByName("Panel_bottom"):setPosition(ccp(0,0))
end

function PetStrengthLayer:updateView()

	self:updateAttr()
	self:updateProgessBar()

	if G_Me.bagData.petData:couldStrength(self._pet) then
		self._box:setVisible(true)
		self._strPanel:setVisible(true)
		self._maxLabel:setVisible(false)
		self:updateBox()
		self:updateButton()
	else
		self._box:setVisible(false)
		self._strPanel:setVisible(false)
		self._maxLabel:setVisible(true)
	end
end

function PetStrengthLayer:updateAttr()
	local info = pet_info.get(self._pet.base_id)
	for i = 1 , 2 do 
		local level = self._pet.level-1+i
		local titleLabel = self:getLabelByName("Label_title"..i)
		local levelLabel = self:getLabelByName("Label_level"..i)
		titleLabel:setText(G_lang:get("LANG_PET_LEVEL"))
		levelLabel:setText(level)
		titleLabel:createStroke(Colors.strokeBrown, 1)
		levelLabel:createStroke(Colors.strokeBrown, 1)

		local data = {G_Me.bagData.petData:getBaseAttr(level, self._pet.base_id,self._pet.addition_lvl)}
		for j = 1 , 4 do 
			local typeLabel = self:getLabelByName("Label_type"..i.."_"..j)
			local valueLabel = self:getLabelByName("Label_value"..i.."_"..j)
			typeLabel:setText(G_lang:get("LANG_PET_ATTR"..j))
			valueLabel:setText(data[j])
			typeLabel:createStroke(Colors.strokeBrown, 1)
			valueLabel:createStroke(Colors.strokeBrown, 1)
		end
	end
end

-- 设置进度条
function PetStrengthLayer:updateProgessBar()

	local curExp = G_Me.bagData.petData:getLeftStrengthExp(self._pet)
	local needExp = G_Me.bagData.petData:getStrengthNextLevelExp(self._pet)
	local addLevel = G_Me.bagData.petData:getStrengthAddLevel(self._pet,self._acquireExp)

	self:getLabelByName("Label_title3"):setText(G_lang:get("LANG_PET_LEVEL"))
	self:getLabelByName("Label_level3"):setText(self._pet.level)
	local addLabel = self:getLabelByName("Label_add")
	addLabel:setVisible(addLevel>0)
	addLabel:setText("+"..addLevel)
	self:_blurLabel("Label_add",addLevel>0)
	
	self._expLabel:setText(G_lang:get("LANG_PET_STRENGTH_GETEXP",{curExp=curExp,totalExp=needExp}))

	local progress = self:getLoadingBarByName("ProgressBar_exp")
	progress:loadModificationTexture("ui/yangcheng/yangcheng_yellow.png", false, UI_TEX_TYPE_LOCAL)


	local percent1 = curExp * 100 / needExp
	progress:setPercent(percent1)

	local percent2 = (self._acquireExp + curExp ) * 100 / needExp

	if percent2 > 0 then 
		progress:setModificationVisible(true)
		progress:blurModification(true)
	else
		progress:setModificationVisible(false)
		progress:blurModification(false)
	end

	if percent2 > 100 then 
	    	progress:setModificationPercent(100)	
	else
	    	progress:setModificationPercent(percent2)
	end
end

function PetStrengthLayer:updateBox()
	for i = 1 , 5 do 
		local item = self._itemList[i]
		local itemImg = self:getImageViewByName("Image_icon"..i)
		local closeImg = self:getImageViewByName("Image_close"..i)
		local boardImg = self:getImageViewByName("Image_board"..i)
		local ballImg = self:getImageViewByName("Image_ball"..i)
		itemImg:setVisible(true)
		if item then
			itemImg:loadTexture(item.icon)
			boardImg:loadTexture(G_Path.getEquipColorImage(item.quality))
			ballImg:loadTexture(G_Path.getEquipIconBack(item.quality))
			boardImg:setVisible(true)
			closeImg:setVisible(true)
			ballImg:setVisible(true)
		else
			itemImg:loadTexture("ui/yangcheng/jia_kezhuangbei.png")
			boardImg:setVisible(false)
			closeImg:setVisible(false)
			ballImg:setVisible(false)
		end
	end
end

function PetStrengthLayer:updateButton()
	local state = GlobalFunc.table_is_empty(self._itemList)
	self._autoButton:setVisible(state)
	self._strButton:setVisible(not state)
	self._moneyLabel:setText(self:getNextMoney())
	if self:getNextMoney() > G_Me.userData.money then
	  	self._moneyLabel:setColor(Colors.lightColors.TIPS_01)
	else
	  	self._moneyLabel:setColor(Colors.lightColors.DESCRIPTION)
	end
end

function PetStrengthLayer:clickItem(index)
	if self._itemList[index] then
		self._itemList[index] = nil
		self:calcExp()
		self:updateView()
	else
		if self._pet.level == G_Me.bagData.petData:getMaxStrengthLevel() then 
			  G_MovingTip:showMovingTip(G_lang:get("LANG_PET_STRENGTH_MAXEXP"))
			  return
		end

		local itemList = G_Me.bagData.petData:getCaiLiaoList()
		if #itemList == 0 then
			require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, 198,
			    GlobalFunc.sceneToPack("app.scenes.pet.develop.PetDevelopeScene", {self._pet,1}))
			return
		end

		-- 弹出选择材料列表
		local PetStrengthChoose = require("app.scenes.pet.develop.PetStrengthChoose")
		PetStrengthChoose.showPetChooseLayer( uf_notifyLayer:getModelNode(), itemList, self._itemList,
		 self._pet, function ( list, acquireExp )
		  	self:_onSelectedItems( list, acquireExp )
		end)
	end
end

function PetStrengthLayer:_onSelectedItems(list, acquireExp)
	self._itemList = list
	self._acquireExp = acquireExp
	self:updateView()
end

function PetStrengthLayer:calcExp()
	self._acquireExp = 0 
	for k , v in pairs(self._itemList) do 
		self._acquireExp = self._acquireExp + v.info.item_value
	end
end

function PetStrengthLayer:autoAdd()
	local foodList = G_Me.bagData.petData:getCaiLiaoList()
	if #foodList == 0 then
		  G_MovingTip:showMovingTip(G_lang:get("LANG_AUTOADD_NONE_FOOD"))
		  return false
	end

	local fitList = {}
	local totalExp = 0
	local maxExp = G_Me.bagData.petData:getStrengthLeftExp(self._pet)
	for key, value in pairs(foodList) do 
		  if value and #fitList < 5 and totalExp < maxExp then
			    table.insert(fitList, #fitList + 1, value)
			    totalExp = totalExp + value.info.item_value
		  end
	end

	self:_onSelectedItems(fitList,totalExp)
end

function PetStrengthLayer:getNextMoney()
	return self._acquireExp
end

function PetStrengthLayer:goStrength()
	local funLevelConst = require("app.const.FunctionLevelConst")
	if not G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.PET_STRENGTH) then
		return
	end
	if self:getNextMoney() > G_Me.userData.money then
		  require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_MONEY, 0,
		      GlobalFunc.sceneToPack("app.scenes.pet.develop.PetDevelopeScene", {self._pet,1}))
	 	 return
	end
	if GlobalFunc.table_is_empty(self._itemList) then
		return
	end

	function goStrength( ... )
		self._oldLevel = self._pet.level
		G_HandlersManager.petHandler:sendPetUpLvl(self._pet.id,  self:_getIdList())
	end

	local maxExp = G_Me.bagData.petData:getStrengthLeftExp(self._pet)
	if self._acquireExp > maxExp then
		local messageBox = require("app.scenes.treasure.TreasureExpMessage")
		messageBox.showYesNoMessage(nil, maxExp ,self._acquireExp, 
			        G_lang:get("LANG_STREAGTH_TOOMUCH"), false, 
			        function ( ... )
			            goStrength()
			        end)
	else
		goStrength()
	end
end

function PetStrengthLayer:_getIdList()
	local idList = {}
	for k , v in pairs(self._itemList) do 
		table.insert(idList,#idList+1,v.info.id)
	end
	return idList
end

function PetStrengthLayer:_onStrengthResult(data)
	if data.ret == 1 then
		-- self._pet = G_Me.bagData.petData:getPetById(self._pet.id) 
		self:_strengthAnime()
		
	end
end

function PetStrengthLayer:_blurLabel( labelName, blur )
	if not labelName then
		return 
	end
	local labelCtrl = self:getWidgetByName(labelName)
	if not labelCtrl then
		return 
	end

	blur = blur or false

	if blur then
		labelCtrl:stopAllActions()
		local fadeInAction = CCFadeIn:create(0.5)
		local fadeOutAction = CCFadeOut:create(0.5)
		local seqAction = CCSequence:createWithTwoActions(fadeInAction, fadeOutAction)
		seqAction = CCRepeatForever:create(seqAction)
		labelCtrl:runAction(seqAction)
	else
		labelCtrl:stopAllActions()
	end
end


function PetStrengthLayer:_flyAttr( deltaAttr,finish_callback)

	G_flyAttribute._clearFlyAttributes()

	local info = pet_info.get(self._pet.base_id)
	local deltaLevel = self._pet.level - self._oldLevel
	local levelTxt = G_lang:get("LANG_PET_STR_MOVE2", {pet=info.name,level=self._pet.level})

	local basePos = ccp(320,200)
	G_flyAttribute.addNormalText(levelTxt,Colors.uiColors.ORANGE, self:getLabelByName("Label_level3"))

	--属性加成
	for k, v in pairs(deltaAttr) do 
	    G_flyAttribute.addAttriChange(v.title, v.value, self:getLabelByName("Label_value1_"..k))
	end

	G_flyAttribute.play(function ( ... )
		if finish_callback then
	    		finish_callback()
	    	end
	end)
end

function PetStrengthLayer:_strengthAnime()
	self._playing = true

	for i = 1 , 5 do 
		self:getImageViewByName("Image_close"..i):setVisible(false)
	end
	local doFly = function ( )
		if self._pet.level > self._oldLevel then
			local attr1 = {G_Me.bagData.petData:getBaseAttr(self._pet.level, self._pet.base_id,self._pet.addition_lvl)}
			local attr2 = {G_Me.bagData.petData:getBaseAttr(self._oldLevel, self._pet.base_id,self._pet.addition_lvl)}
			local attrs = {}
			for i = 1 , 4 do 
				table.insert(attrs,#attrs+1,{title=G_lang:get("LANG_PET_ATTR"..i),value=attr1[i]-attr2[i]})
			end
			self:_flyAttr(attrs,function ( ... )
				self:_onSelectedItems({},0)
				self._playing = false
			end)
		else
			G_MovingTip:showMovingTip(G_lang:get("LANG_PET_STR_MOVE1"))
			self._playing = false
			self:_onSelectedItems({},0)
		end
	end
	self:_flyItemsAnime(self._itemList,doFly)

end

-- 觉醒动画
function PetStrengthLayer:_flyItemsAnime(items, callback)

	local add = false
    for i , v in pairs(items) do

        if v then

            local itemInfo = v

            local imgItem = self:getImageViewByName("Image_boardBg"..i)
            imgItem:removeAllNodes()

            self:getImageViewByName("Image_icon"..i):setVisible(false)
            
            local node = display.newNode()
            imgItem:addNode(node)

            local effectShine = EffectNode.new("effect_juexing_a")
            node:addChild(effectShine)
            effectShine:play()

            local icon = display.newSprite(itemInfo.icon)
            node:addChild(icon)

            local effectStar = EffectNode.new("effect_particle_star")
            node:addChild(effectStar)
            effectStar:setScale(0.5)
            effectStar:play()

            local actionArr = CCArray:create()
            actionArr:addObject(CCEaseElasticOut:create(CCMoveBy:create(1.5, ccp(0, 100)), 0.35))
            node:runAction(CCSequence:create(actionArr))
            
            actionArr = CCArray:create()
            actionArr:addObject(CCDelayTime:create((i-1) * 0.15 + 0.3))
            
            actionArr:addObject(CCMoveTo:create(0.5, node:getParent():convertToNodeSpace(self._container:getEffectNode():convertToWorldSpaceAR(ccp(0, 100)))))
            
            actionArr:addObject(CCCallFunc:create(function()
                if not add then
                	add = true
                    self._container:getEffectNode():removeAllNodes()
                    
                    local effect = EffectNode.new("effect_shoulan_shengji", function(event, frameIndex, _effect)
                        if event == "finish" then
                            _effect:removeFromParent()   
                            if callback then
                                callback("finish")
                            end
                        end
                    end)
                    self._container:getEffectNode():addNode(effect)
                    effect:setPosition(ccp(15,178))
                    effect:setScale(1.1)
                    effect:play()
                end
            end))
            
            actionArr:addObject(CCRemoveSelf:create())
            
            node:runAction(CCSequence:create(actionArr))
        end
    end
    
end

function PetStrengthLayer:enterViewAnime()
	G_GlobalFunc.flyIntoScreenLR( {self:getPanelByName("Panel_left")} ,
	    true, 0.2, 2, 20)
	G_GlobalFunc.flyIntoScreenLR( {self:getPanelByName("Panel_right")} ,
	    false, 0.2, 2, 20)
	G_GlobalFunc.flyIntoScreenTB({self:getPanelByName("Panel_bottom_move")}, 
	    false, 0.2, 2, 20)
end

function PetStrengthLayer:exitViewAnime(callback)
	G_GlobalFunc.flyOutScreenLR( {self:getPanelByName("Panel_left")} ,
	    true, 0.2, 2, 20)
	G_GlobalFunc.flyOutScreenLR( {self:getPanelByName("Panel_right")} ,
	    false, 0.2, 2, 20)
	G_GlobalFunc.flyOutScreenTB({self:getPanelByName("Panel_bottom_move")}, 
	    false, 0.2, 2, 20,callback)
	
end

return PetStrengthLayer