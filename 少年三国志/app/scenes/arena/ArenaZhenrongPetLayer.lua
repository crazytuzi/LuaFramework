local ArenaZhenrongPetLayer = class("ArenaZhenrongPetLayer", UFCCSNormalLayer)
local MergeEquipment = require("app.data.MergeEquipment")
local EffectNode = require "app.common.effects.EffectNode"
local PetAppearEffect = require("app.scenes.hero.PetAppearEffect")
require("app.cfg.pet_info")
require("app.cfg.pet_addition_info")

function ArenaZhenrongPetLayer:create( ... )
	return ArenaZhenrongPetLayer.new("ui_layout/arena_ArenaZhenrongPet.json")
end

function ArenaZhenrongPetLayer:ctor( ... )
	self.super.ctor(self,...)

	self._fightLabel = self:getLabelByName("Label_fight")
	self._fightLabel:createStroke(Colors.strokeBrown, 2)

	self._petPanel = self:getPanelByName("Panel_pet")

end

function ArenaZhenrongPetLayer:onLayerEnter( ... )
	self:updateView()
	self:_setPetPic()
end

function ArenaZhenrongPetLayer:_setPetPic( )
	if self._pet then
		local info = pet_info.get(self._pet.base_id)
		self._petPanel:removeAllNodes()
		local petPath2 = G_Path.getPetReadyGuangEffect(info.ready_id)
		self._petImg2 = EffectNode.new(petPath2)
		self._petImg2:setScale(0.5)
		self._petPanel:addNode(self._petImg2)
		self._petImg2:play()
		local petPath = G_Path.getPetReadyEffect(info.ready_id)
		self._petImg = EffectNode.new(petPath)
		self._petPanel:addNode(self._petImg)
		self._petImg:play()
	end
end

function ArenaZhenrongPetLayer:updateView( pet )
	if not self._pet then
		self._pet = pet
	end

	if self._pet then
		self:updateAttr()
		self:updateBaseInfo()
		self:updateFight()
	end
end

function ArenaZhenrongPetLayer:updateBaseInfo( )
	local info = pet_info.get(self._pet.base_id)
	local nameLabel = self:getLabelByName("Label_name")
	nameLabel:setText(info.name)
	nameLabel:createStroke(Colors.strokeBrown, 1)
	nameLabel:setColor(Colors.getColor(info.quality))

	for index = 1 , 5 do 
	    self:getImageViewByName("Image_start_"..index.."_full"):setVisible(info.star >= index)
	end
	self:getImageViewByName("Image_default"):setVisible(false)

end

function ArenaZhenrongPetLayer:updateAttr()
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

function ArenaZhenrongPetLayer:updateAttrPanel(panel,data,index)
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

function ArenaZhenrongPetLayer:updateFight()
    self:updateFightLabel(self._pet.fight_value)
end

function ArenaZhenrongPetLayer:updateFightLabel(value)
	self._fightLabel:setText(GlobalFunc.ConvertNumToCharacter(value))
	self._fightLabel:setColor(Colors.qualityColors[1])
end

return ArenaZhenrongPetLayer