
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local PetRefineTarget = class("PetRefineTarget", UFCCSModelLayer)
local MergeEquipment = require("app.data.MergeEquipment")
local BagConst = require("app.const.BagConst")

function PetRefineTarget.show( ... )
	local targetLayer = PetRefineTarget.new("ui_layout/petbag_RefineTarget.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(targetLayer, 10)
end

function PetRefineTarget:ctor( ... )
	self.super.ctor(self, ...)
end

function PetRefineTarget:onLayerLoad( _, _, pet )
	self._pet = pet
end

function PetRefineTarget:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_bg"), "smoving_bounce")
	EffectSingleMoving.run(self:getWidgetByName("Image_jixu"), "smoving_wait", nil , {position = true} )

	self:updateView()
end

function PetRefineTarget:updateView()
	local info = pet_info.get(self._pet.base_id)
	local addInfo = pet_addition_info.get(info.addition_id,self._pet.addition_lvl)
	local curTitleLabel = self:getLabelByName("Label_curTitle")
	curTitleLabel:setText(G_lang:get("LANG_PET_ATTR_CUR_REFINE_LEVEL"))
	self:getLabelByName("Label_curLevel"):setText(G_lang:get("LANG_PET_REFINE_JIE",{level=self._pet.addition_lvl}))
	for i = 1 , 2 do
		local level = i == 1 and addInfo.target_level or G_Me.bagData.petData:getMaxRefineLevel()
		local data = pet_addition_info.get(info.addition_id,level)
		local attrAdd = false
		if data then
			self:getLabelByName("Label_title"..i):setText(G_lang:get("LANG_PET_REFINE_LEVEL"..i,{level=level}))
			local refData = {}
			for t = 1 , 6 do 
				if data["type_"..t] > 0 then
					table.insert(refData,#refData+1,{index=t,type=data["type_"..t], value=data["value_"..t]})
				end
			end
			for j = 1 , 7 do 
				local attrLabel = self:getLabelByName("Label_attr"..i.."_"..j)
				if refData[j] then
					local _,_,strtype,strvalue = MergeEquipment.convertPassiveSkillTypeAndValue(refData[j].type, refData[j].value)
					attrLabel:setText(refData[j].index.." "..strtype.."： +"..strvalue)
					attrLabel:setVisible(true)
				elseif not attrAdd then
					attrAdd = true
					attrLabel:setVisible(true)
					local addAttr1,addAttr2 = G_Me.bagData.petData:getAttrAddShow(self._pet.base_id,level)
					if addAttr1 then
						attrLabel:setVisible(true)
						attrLabel:setText(addAttr1..addAttr2)
					else
						attrLabel:setVisible(false)
					end
				else
					attrLabel:setVisible(false)
				end

				self:updateAttrPanel(self:getPanelByName("Panel_icon"..i),data,i)
			end
		end
	end
end


function PetRefineTarget:updateAttrPanel(panel,data,index)
	panel:removeAllChildrenWithCleanup(true)
	for i = 1 , 6 do 
		local img = self:getImageViewByName("heroImg"..index..i)
		local imgList = {"ui/pet/zhanwei-liang.png","ui/pet/zhanwei-hui.png"}
		if not img then
			img = ImageView:create()
			img:loadTexture(data["type_"..i]>0 and imgList[1] or imgList[2])
			-- img:setScale(0.75)
			local label = G_GlobalFunc.createGameLabel( i, 24, Colors.darkColors.DESCRIPTION, Colors.strokeBrown, CCSizeMake(16, 0), true )
			img:addChild(label)
			label:setPosition(ccp(0,0))
			img:setName("heroLabel"..index..i)
			label:setName("heroImg"..index..i)
			panel:addChild(img)
			local size = panel:getSize()
			img:setPosition(ccp((size.width+50)/4*((i-1)%3+1)-25,(size.height+40)/3*(2-math.floor((i-1)/3))-20))
		else
			img:loadTexture(data["type_"..i]>0 and imgList[1] or imgList[2])
		end
	end
end


return PetRefineTarget
