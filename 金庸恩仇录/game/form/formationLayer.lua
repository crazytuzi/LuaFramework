local formationLayer = {}
local petSkillIconTag = 5438

function formationLayer.refreshPetSkillIcon(owner, index)
	local skills = {}
	local petData
	local pet = owner._pet[index][1]
	if pet then
		petData = ResMgr.getPetData(pet.resId)
		skills = pet.skills
	end
	for i = 1, 4 do
		local key = "pet_skill_node_" .. tostring(i)
		local petSkillNode = owner._rootnode[key]
		petSkillNode:removeChildByTag(petSkillIconTag)
		if pet then
			local param = {}
			param.lockType = 0
			param.showName = true
			if petData.skills and petData.skills[i] then
				if not skills[i] then
					param.lockType = 1
					param.nameColor = NAME_COLOR[1]
					param.customName = common:getLanguageString("@SkillJinJieUnlock", petData.skillAdd[i])
				end
				param.id = petData.skills[i]
				param.level = pet.skillLevels[i]
			else
				param.lockType = 2
			end
			local s = PetModel.getPetSkillIcon(param)
			petSkillNode:addChild(s, 100, petSkillIconTag)
		end
	end
end

--刷新宠物界面
function formationLayer.formPetRefresh(owner, pet, hero)
	local petPath
	owner._rootnode.petImg:removeAllChildren()
	if pet then
		owner._rootnode.pet_act:setVisible(true)
		owner._rootnode.petunact:setVisible(false)
		local petData = ResMgr.getPetData(pet.resId)
		owner._rootnode.petNameLabel:setString(petData.name)
		owner._rootnode.petNameLabel:setColor(NAME_COLOR[pet.star])
		local clsText = ""
		if pet.cls > 0 then
			clsText = "+" .. pet.cls
		end
		owner._rootnode.petClsLabel:setString(clsText)
		owner._rootnode.petLevelLabel:setString("Lv" .. pet.level)
		alignNodesOneByAllCenterX(owner._rootnode.petNameLabel:getParent(), {
		owner._rootnode.petLevelLabel,
		owner._rootnode.petNameLabel,
		owner._rootnode.petClsLabel
		}, 5)
		owner:refreshFormStar(pet.star)
		local petImg = petData.body
		petPath = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getLargeImage(petImg, ResMgr.PET))
		owner:setPetImgBg(petPath)
		local petSize = owner._rootnode.petImg:getContentSize()
		local bgEffect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "pet_unact_particle",
		isRetain = true
		})
		owner._rootnode.petImg:addChild(bgEffect, -10)
		bgEffect:setPosition(cc.p(petSize.width * 0.5, petSize.height * 0.5))
		if petData.fateType then
			local text = PetModel.getPetYuanFenStrByTabId(pet.resId, pet.cls)
			owner._rootnode.encounter_label:setVisible(true)
			owner._rootnode.encounter_label:setString(text)
			local color = pet.fateState == 0 and ccc3(119, 119, 119) or ccc3(255, 108, 0)
			owner._rootnode.encounter_label:setColor(color)
			owner._rootnode.encounter_title:setVisible(true)
		else
			owner._rootnode.encounter_label:setVisible(false)
			owner._rootnode.encounter_title:setVisible(false)
		end
		alignNodesOneByOne(owner._rootnode.encounter_title, owner._rootnode.encounter_label)
	else
		owner._rootnode.pet_act:setVisible(false)
		owner._rootnode.petunact:setVisible(true)
		owner:refreshFormStar(0)
		petPath = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getLargeImage("pet_large_00", ResMgr.PET))
		owner:setPetImgBg(petPath)
		local petSize = owner._rootnode.petImg:getContentSize()
		local bgEffect = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "pet_unact_particle",
		isRetain = true
		})
		owner._rootnode.petImg:addChild(bgEffect, -10)
		bgEffect:setPosition(cc.p(petSize.width * 0.5, petSize.height * 0.5))
		if owner.isformSelf then
			local addEffect = ResMgr.createArma({
			resType = ResMgr.UI_EFFECT,
			armaName = "pet_unact_add",
			isRetain = true
			})
			owner._rootnode.petImg:addChild(addEffect, 10)
			addEffect:setPosition(cc.p(petSize.width * 0.5, petSize.height * 0.5))
		end
		local petIdTbl = PetModel.getCardFatePet(hero.resId)
		local cardData = ResMgr.getCardData(hero.resId)
		local unactText, heroName
		if owner.isformSelf then
			heroName = HeroModel.getHeroNameByResId(hero.resId)
		else
			heroName = hero.name
		end
		if petIdTbl then
			local petName, fateName, fateDesc
			for key, petId in ipairs(petIdTbl) do
				local petData = ResMgr.getPetData(petId)
				local limit = petData.limit == 0 and 0 or petData.limit
				if key == 1 then
					petName = petData.name
					fateName = petData.fateName
					local str = PetModel.getPetYuanFenStrByTabId(petId, limit, true) .. "%"
					fateDesc = common:getLanguageString("@PetFateInfo", tostring(str))
				else
					petName = common:getLanguageString("@PetFateInfo1", petName .. "(" .. petData.name .. ")")
					local str = "(" .. PetModel.getPetYuanFenStrByTabId(petId, limit, true) .. "%)"
					fateDesc = fateDesc .. common:getLanguageString("@PetFateInfo1", str)
				end
			end
			unactText = common:getLanguageString("@petqingyuan1") .. common:getLanguageString("@petqingyuan2", heroName, petName, fateName, " ") .. fateDesc
		elseif hero.star == 5 then
			unactText = common:getLanguageString("@petqingyuan1") .. common:getLanguageString("@petqingyuan3", heroName)
		else
			unactText = common:getLanguageString("@petqingyuan1")
		end
		local contentNode = owner._rootnode.petunact_bg
		owner._rootnode.petunact_bg:setVisible(true)
		owner._rootnode.petunact_text:removeAllChildren()
		local contentLabel = getRichText(unactText, contentNode:getContentSize().width - 20, hrefHandler)
		contentLabel:setPosition(0 - contentLabel:getContentSize().width * 0.5, contentLabel:getContentSize().height * 0.5 - contentLabel.offset)
		owner._rootnode.petunact_text:addChild(contentLabel)
	end
end

return formationLayer