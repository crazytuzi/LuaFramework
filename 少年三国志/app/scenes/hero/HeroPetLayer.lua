local HeroPetLayer = class("HeroPetLayer", UFCCSNormalLayer)
local MergeEquipment = require("app.data.MergeEquipment")
local EffectNode = require "app.common.effects.EffectNode"
local PetAppearEffect = require("app.scenes.hero.PetAppearEffect")
require("app.cfg.pet_info")
require("app.cfg.pet_addition_info")
require("app.cfg.skill_info")

function HeroPetLayer:create( ... )
	return HeroPetLayer.new("ui_layout/knight_pet.json")
end

function HeroPetLayer:ctor( ... )
	self.super.ctor(self,...)

	local infoLabel = self:getLabelByName("Label_baseInfo")
	local zuheLabel = self:getLabelByName("Label_zuhe")
	infoLabel:setText(G_lang:get("LANG_PET_FORM_BASEINFO"))
	zuheLabel:setText(G_lang:get("LANG_PET_FORM_SKILL"))
	infoLabel:createStroke(Colors.strokeBrown, 2)
	zuheLabel:createStroke(Colors.strokeBrown, 2)
	self._fightLabel = self:getLabelByName("Label_fight")
	self._fightLabel:createStroke(Colors.strokeBrown, 2)

	local dengjiLabel = self:getLabelByName("Label_level_name")
	dengjiLabel:setText(G_lang:get("LANG_INFO_LV"))
	-- dengjiLabel:createStroke(Colors.strokeBrown, 1)
	-- self:getLabelByName("Label_level_value"):createStroke(Colors.strokeBrown, 1)

	self._petPanel = self:getPanelByName("Panel_pet")
	self._lastFightValue = 0

	self:registerBtnClickEvent("Button_change", function()
		require("app.scenes.pet.PetSelectPetLayer").show()
	end)

	-- self:registerWidgetClickEvent("Panel_middle", function()
	-- 	if self._pet  then
	-- 		local tLayer = require("app.scenes.pet.PetInfo").showEquipmentInfo(self._pet , 2,{})
	-- 		tLayer:setTag(10100)
	-- 	else
	-- 		local p = require("app.scenes.pet.PetSelectPetLayer").create()
	-- 		uf_sceneManager:getCurScene():addChild(p)
	-- 	end
	-- end)
end

function HeroPetLayer:onLayerTurn( ... )
	self:updateView()
	self:getPanelByName("Panel_top"):setVisible(true)
	self:getPanelByName("Panel_baseinfo"):setVisible(true)
	self:_enterLayerAnime()
end

function HeroPetLayer:onLayerTurnOut( show)
	local state = self._pet and show
	self:getPanelByName("Panel_attr"):setVisible(state)
	self:getImageViewByName("Image_fight"):setVisible(state)
	self:getPanelByName("Panel_left"):setVisible(show)
	self:getPanelByName("Panel_right"):setVisible(show)
	self:getImageViewByName("Image_baseinfo"):setVisible(show)
	self:getImageViewByName("Image_skill"):setVisible(show)

	self:getPanelByName("Panel_top"):setVisible(state)
	self:getPanelByName("Panel_baseinfo"):setVisible(show)
end

function HeroPetLayer:_enterLayerAnime()
	G_GlobalFunc.flyIntoScreenLR( {self:getPanelByName("Panel_attr")} ,
	    true, 0.2, 2, 100)
	G_GlobalFunc.flyIntoScreenLR( {self:getImageViewByName("Image_fight")} ,
	    true, 0.2, 2, 100)
	G_GlobalFunc.flyIntoScreenLR({self:getPanelByName("Panel_left")}, 
	    true, 0.2, 2, 100)
	G_GlobalFunc.flyIntoScreenLR({self:getPanelByName("Panel_right")}, 
	    false, 0.2, 2, 100)
	G_GlobalFunc.flyIntoScreenLR({self:getImageViewByName("Image_baseinfo")}, 
	    true, 0.2, 2, 100)
	G_GlobalFunc.flyIntoScreenLR({self:getImageViewByName("Image_skill")}, 
	    false, 0.2, 2, 100)
	G_GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_change")}, 
	    false, 0.2, 2, 100)
end

function HeroPetLayer:onLayerEnter( ... )
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_PET_CHANGE, self._onPetChange, self)
	self:updateView()
	self:_setPetPic()

	self:onLayerTurnOut(false)
end

function HeroPetLayer:_onPetChange( data )
	-- self:updateView()
	self:_enterAnime(data)
end

function HeroPetLayer:_enterAnime( data)
	self._petPanel:removeAllNodes()
	if G_Me.bagData.petData:getFightPet() then
		self._petPanel:setVisible(true)
		self:getImageViewByName("Image_default"):setVisible(false)
		local ani = PetAppearEffect.new(G_Me.bagData.petData:getFightPet().base_id, function()
			self._pet = G_Me.bagData.petData:getFightPet()
			self:updateFight()
			self:_attrChangeAnime(data,function ( ... )
				self:updateView()
			end)
		end)
		ani:play()
		self._petPanel:addNode(ani)
	else
		self:updateView()
	end
end

function HeroPetLayer:_attrChangeAnime( data ,callback )
	local petNew = G_Me.bagData.petData:getPetById(data.pet_id)
	local attack1,hp1,phyDefense1,magicDefense1 = G_Me.bagData.petData:getBaseAttr(petNew.level,petNew.base_id,petNew.addition_lvl)
	local attrNew = {attack=attack1,hp=hp1,phyDefense=phyDefense1,magicDefense=magicDefense1}
	local petOld = G_Me.bagData.petData:getPetById(data.old_pet_id)
	local attrOld = {attack=0,hp=0,phyDefense=0,magicDefense=0}
	if petOld then
		local attack2,hp2,phyDefense2,magicDefense2 = G_Me.bagData.petData:getBaseAttr(petOld.level,petOld.base_id,petOld.addition_lvl)
		attrOld = {attack=attack2,hp=hp2,phyDefense=phyDefense2,magicDefense=magicDefense2}
	end

	G_flyAttribute._clearFlyAttributes()

	local levelTxt = G_lang:get("LANG_PET_FORM_PET_CHANGE_SUCCESS")

	G_flyAttribute.addNormalText(levelTxt,Colors.darkColors.DESCRIPTION)

	local ctrList = {}
	for i = 1 , 4 do 
		table.insert(ctrList,#ctrList+1,self:getLabelByName("Label_attrValue"..i))
	end
	-- --属性加成
	-- for i = 1 , #attrNew do 
	--     G_flyAttribute.addAttriChange(G_lang:get("LANG_PET_ATTR"..i), attrNew[i]-attrOld[i], self:getLabelByName("Label_attrValue"..i))
	-- end
	G_flyAttribute.addKnightAttri1Change(attrOld,attrNew,ctrList)

	G_flyAttribute.play(function ( ... )
		if callback then
	    		callback()
	    	end
	end)
end

function HeroPetLayer:_setPetPic( )
	if self._pet then
		local info = pet_info.get(self._pet.base_id)
		self._petPanel:removeAllNodes()
		local petPath2 = G_Path.getPetReadyGuangEffect(info.ready_id)
		self._petImg2 = EffectNode.new(petPath2)
		self._petImg2:setScale(0.65)
		self._petPanel:addNode(self._petImg2)
		self._petImg2:play()
		local petPath = G_Path.getPetReadyEffect(info.ready_id)
		self._petImg = EffectNode.new(petPath)
		self._petPanel:addNode(self._petImg)
		self._petImg:play()
	end
end

function HeroPetLayer:updateView( )
	self._pet = G_Me.bagData.petData:getFightPet()

	self:updateEmpty(self._pet ~= nil)
	if self._pet then
		self:updateAttr()
		self:updateBottom()
		self:updateBaseInfo()
		self:updateFight()
	end
end

function HeroPetLayer:updateEmpty( hasPet )
	self:getImageViewByName("Image_default"):setVisible(not hasPet)
	self:getPanelByName("Panel_stars"):setVisible(hasPet)
	self:getPanelByName("Panel_pet"):setVisible(hasPet)
	self:getPanelByName("Panel_attr"):setVisible(hasPet)
	self:getButtonByName("Button_change"):setVisible(G_Me.bagData.petData:getPetCountExceptFightOne()>0)
	self:getImageViewByName("Image_fight"):setVisible(hasPet)

	self:getPanelByName("Panel_left"):setVisible(true)
	self:getPanelByName("Panel_right"):setVisible(true)
	self:getImageViewByName("Image_baseinfo"):setVisible(true)
	self:getImageViewByName("Image_skill"):setVisible(true)

	if not hasPet then
		self:getLabelByName("Label_name"):setText("")
		self:getLabelByName("Label_level_value"):setText("")
		for i = 1 , 4 do
			self:getLabelByName("Label_attrType"..i):setText(G_lang:get("LANG_PET_ATTR"..i))
			self:getLabelByName("Label_attrValue"..i):setText("")
		end
		self:getLabelByName("Label_skill_1"):setText("")
		self:getLabelByName("Label_skill_2"):setText("")
	end
end

function HeroPetLayer:updateBaseInfo( )
	local info = pet_info.get(self._pet.base_id)
	local nameLabel = self:getLabelByName("Label_name")
	nameLabel:setText(info.name)
	nameLabel:createStroke(Colors.strokeBrown, 1)
	nameLabel:setColor(Colors.getColor(info.quality))

	for index = 1 , 5 do 
	    self:getImageViewByName("Image_start_"..index.."_full"):setVisible(info.star >= index)
	end
	self:getImageViewByName("Image_default"):setVisible(false)

	-- self._petPanel:removeAllNodes()
	-- local petPath = G_Path.getPetReadyEffect(info.ready_id)
	-- self._petImg = EffectNode.new(petPath)
	-- self._petPanel:addNode(self._petImg)
	-- self._petImg:play()
	
end

function HeroPetLayer:updateBottom( )
	self:getLabelByName("Label_level_value"):setText(self._pet.level)
	local info = pet_info.get(self._pet.base_id)
	local data = {G_Me.bagData.petData:getBaseAttr(self._pet.level, self._pet.base_id,self._pet.addition_lvl)}
	for i = 1 , 4 do
		self:getLabelByName("Label_attrType"..i):setText(G_lang:get("LANG_PET_ATTR"..i))
		self:getLabelByName("Label_attrValue"..i):setText(data[i])
	end
	self:getLabelByName("Label_skill_1"):setText(skill_info.get(info.common_id).name)
	self:getLabelByName("Label_skill_2"):setText(skill_info.get(info.active_skill_id).name)
end

function HeroPetLayer:updateAttr()
	self:getPanelByName("Panel_right"):setVisible(true)
	local info = pet_info.get(self._pet.base_id)
	local level = self._pet.addition_lvl
	local i = 1
	local titleLabel = self:getLabelByName("Label_title"..i)
	titleLabel:setText(G_lang:get("LANG_PET_FORM_ADD"))
	titleLabel:createStroke(Colors.strokeBrown, 1)
	local data = pet_addition_info.get(info.addition_id,level)
	if data then
		local refData = {}
		for t = 1 , 6 do 
			if data["type_"..t] > 0 then
				table.insert(refData,#refData+1,{index=t,type=data["type_"..t], value=data["value_"..t]})
			end
		end
		for j = 1 , 6 do 
			if refData[j] then
				local typeLabel = self:getLabelByName("Label_type"..i.."_"..j)
				local valueLabel = self:getLabelByName("Label_value"..i.."_"..j)
				local _,_,strtype,strvalue = MergeEquipment.convertPassiveSkillTypeAndValue(refData[j].type, refData[j].value)
				typeLabel:setText(refData[j].index.." "..strtype)
				valueLabel:setText("+"..strvalue)
				typeLabel:createStroke(Colors.strokeBrown, 1)
				valueLabel:createStroke(Colors.strokeBrown, 1)
				typeLabel:setVisible(true)
				valueLabel:setVisible(true)
			else
				local typeLabel = self:getLabelByName("Label_type"..i.."_"..j)
				local valueLabel = self:getLabelByName("Label_value"..i.."_"..j)
				typeLabel:setVisible(false)
				valueLabel:setVisible(false)
			end
		end

		self:updateAttrPanel(self:getImageViewByName("Image_hero"..i),data,i)
	end
end

function HeroPetLayer:updateAttrPanel(panel,data,index)
	panel:removeAllChildrenWithCleanup(true)
	for i = 1 , 6 do 
		local img = self:getImageViewByName("heroImg"..index..i)
		local imgList = {"ui/pet/zhanwei-liang.png","ui/pet/zhanwei-hui.png"}
		if not img then
			img = ImageView:create()
			img:loadTexture(data["type_"..i]>0 and imgList[1] or imgList[2])
			img:setScale(0.75)
			local label = G_GlobalFunc.createGameLabel( i, 24, Colors.darkColors.DESCRIPTION, Colors.strokeBrown, CCSizeMake(16, 0), true )
			img:addChild(label)
			label:setPosition(ccp(0,0))
			img:setName("heroLabel"..index..i)
			label:setName("heroImg"..index..i)
			panel:addChild(img)
			local size = panel:getSize()
			img:setPosition(ccp((size.width+20)/4*((i-1)%3-1),(size.height+20)/3*(0.5-math.floor((i-1)/3))))
		else
			img:loadTexture(data["type_"..i]>0 and imgList[1] or imgList[2])
		end
	end
end

function HeroPetLayer:updateFight()
    if self._lastFightValue > 0 and self._lastFightValue ~= self._pet.fight_value then
        --增加一个变化动画
        if self._fightValueChanger then
            self._fightValueChanger:stop()
            self._fightValueChanger = nil 
        end
        local NumberScaleChanger = require("app.scenes.common.NumberScaleChanger")
        self._fightValueChanger = NumberScaleChanger.new( self._fightLabel,  self._lastFightValue, self._pet.fight_value ,
            function(value) 
	            	if G_SceneObserver:getSceneName() ~= "HeroScene" then
	            	    return
	            	end
                self:updateFightLabel(value)
            end
        )
    else
        self:updateFightLabel(self._pet.fight_value)
    end
    self._lastFightValue = self._pet.fight_value
end

function HeroPetLayer:updateFightLabel(value)
	self._fightLabel:setText(GlobalFunc.ConvertNumToCharacter(value))
	local fightValueClr = Colors.qualityColors[1]
	-- if value < 10000 then
	--     fightValueClr = Colors.qualityColors[1]
	-- elseif value < 25000 then
	--     fightValueClr = Colors.qualityColors[2]
	-- elseif value < 50000 then
	--     fightValueClr = Colors.qualityColors[3]
	-- elseif value < 100000 then
	--     fightValueClr = Colors.qualityColors[4]
	-- elseif value < 200000 then
	--     fightValueClr = Colors.qualityColors[5]
	-- elseif value < 400000 then
	--     fightValueClr = Colors.qualityColors[6]
	-- else
	--     fightValueClr = Colors.qualityColors[7]
	-- end
	self._fightLabel:setColor(fightValueClr)
end

function HeroPetLayer:onLayerExit( )
	if self._fightValueChanger then
	    self._fightValueChanger:stop()
	    self._fightValueChanger = nil 
	end
end

return HeroPetLayer