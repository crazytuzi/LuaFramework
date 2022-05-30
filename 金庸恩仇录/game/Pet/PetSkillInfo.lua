local data_pet_skill = require("data.data_petskill_petskill")
local data_item_nature = require("data.data_item_nature")
local data_item_item = require("data.data_item_item")
ccb = ccb or {}
ccb.aniCtrl = {}

local PetSkillInfo = class("PetSkillInfo", function()
	return require("utility.ShadeLayer").new()
end)

function PetSkillInfo:ctor(param)
	self.id = param.id
	self.petObjID = param.objId
	self.lv = param.lv
	if self.petObjID ~= nil then
		local petInfo = PetModel.getPetByObjId(self.petObjID)
		if petInfo then
			for i = 1, #petInfo.skillLevels do
				if petInfo.skills[i] == self.id then
					self.lv = petInfo.skillLevels[i]
					break
				end
			end
		end
	end
	self.lock = param.lock
	self.skillType = param.skillType
	self.updataSkillCallBack = param.updataSkillCallBack
	self.skillLevelUp = false
	self.closeFunc = param.closeFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("pet/pet_skill_info.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self.skillIconTab = {}
	
	--¹Ø±Õ
	self._rootnode.closeBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if self.closeFunc then
			self.closeFunc(self.skillLevelUp)
		end
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	
	--È·¶¨
	self._rootnode.confirmBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		RequestHelper.getPetSkillLvUpRes({
		callback = function(data)
			ResMgr.removeMaskLayer()
			game.player.m_silver = data.silver
			PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			local cellData = PetModel.getPetByObjId(data.pet._id)
			if cellData ~= nil then
				if data.pet.skillLevels ~= nil then
					cellData.skillLevels = data.pet.skillLevels
				end
				for i = 1, #cellData.skillLevels do
					if cellData.skills[i] == self.id then
						self.lv = cellData.skillLevels[i]
						self.skillLevelUp = true
						if self.updataSkillCallBack then
							self.updataSkillCallBack({
							idx = i,
							lv = self.lv
							})
						end
						break
					end
				end
				self:initPetData()
			end
		end,
		id = self.petObjID,
		sklId = self.id
		})
	end,
	CCControlEventTouchUpInside)
	
	self:initPetData()
end

function PetSkillInfo:requestData()
	RequestHelper.getPetUsingItem({
	callback = function(data)
		ResMgr.removeMaskLayer()
		local skillInfo = data_pet_skill[self.id]
		local lvUpSpend = self.lv * self.lv * skillInfo.item2[1] + self.lv * skillInfo.item2[2]
		local objSpend = self.lv * self.lv * skillInfo.item1[1] + self.lv * skillInfo.item1[2]
		local lvupItem = data_item_item[data.sklItemId]
		if lvupItem then
			self._rootnode.spendtype2:setString(lvupItem.name .. ":")
		else
			self._rootnode.spendtype2:setString("")
		end
		self._rootnode.spendtype1:setString(common:getLanguageString("@SilverCoin"))
		self._rootnode.spendvalue1:setString(tostring(lvUpSpend))
		self._rootnode.spendvalue2:setString(data.sklSize .. "/" .. objSpend)
		alignNodesOneByAll({
		self._rootnode.spendtype2,
		self._rootnode.spendvalue2
		}, 10)
		if not ResMgr.isEnoughSilver(lvUpSpend) then
			self._rootnode.spendvalue1:setColor(FONT_COLOR.DARK_RED)
		end
		if objSpend > data.sklSize then
			self._rootnode.spendvalue2:setColor(FONT_COLOR.DARK_RED)
		end
		if not ResMgr.isEnoughSilver(lvUpSpend) or objSpend > data.sklSize then
			self._rootnode.confirmBtn:setEnabled(false)
		end
	end
	})
end

function PetSkillInfo:initPetData()
	local skillInfo = data_pet_skill[self.id]
	local nature = data_item_nature[skillInfo.type]
	local skillvalueAdd = skillInfo.add
	local skillvalueBase = 0
	local skillCurLevel = 0
	local skillNextLevel = 0
	self._rootnode.name_0:setString(skillInfo.name)
	self._rootnode.shuxing:setString(nature.nature .. ":")
	self._rootnode.levelLimit:setString("")
	if self.skillType == 3 or self.lock == 1 then
		skillCurLevel = 1
		skillNextLevel = 2
		skillvalueBase = skillInfo.base
		ccb.aniCtrl.mAnimationManager:runAnimationsForSequenceNamed("panel_2")
	elseif self.skillType == 2 then
		skillCurLevel = self.lv
		skillvalueBase = skillInfo.base + (skillCurLevel - 1) * skillInfo.add
		local petData = PetModel.getPetByObjId(self.petObjID)		
		local maxPetLevel = 40
		if skillCurLevel + 1 <= maxPetLevel then
			skillNextLevel = skillCurLevel + 1
			local lv = skillNextLevel			
			if lv > #skillInfo.levels then
				lv = #skillInfo.levels
			end
			local levelLimit = skillInfo.levels[lv]
			if levelLimit > petData.level then
				self._rootnode.confirmBtn:setEnabled(false)
				self._rootnode.levelLimit:setString(common:getLanguageString("@petlvlow", levelLimit))
			end
			ccb.aniCtrl.mAnimationManager:runAnimationsForSequenceNamed("panel_0")
			self:requestData()
		else
			ccb.aniCtrl.mAnimationManager:runAnimationsForSequenceNamed("panel_1")
			self._rootnode.levelLimit:setString(common:getLanguageString("@petskillLimit"))
		end
	elseif self.skillType == 1 then
		skillCurLevel = self.lv
		skillNextLevel = self.lv
		skillvalueBase = skillInfo.base + (skillCurLevel - 1) * skillInfo.add
		ccb.aniCtrl.mAnimationManager:runAnimationsForSequenceNamed("panel_1")
	end
	local tag = ""
	if skillInfo.addType == 1 then
		tag = "%"
	end
	self._rootnode.shuxingbase:setString(tostring(skillvalueBase) .. tag)
	self._rootnode.shuxingadd:setString("+" .. tostring(skillvalueAdd) .. tag)
	alignNodesOneByAll({
	self._rootnode.shuxing,
	self._rootnode.shuxingbase,
	self._rootnode.shuxingadd
	}, 5)
	if self.skillIconTab.skillName1 == nil then
		self.skillIconTab.skillName1 = PetModel.getPetSkillIcon({
		id = self.id,
		level = skillCurLevel,
		lockType = self.lock
		})
		self.skillIconTab.skillName1:setAnchorPoint(cc.p(0, 0))
		self.skillIconTab.skillName1:setPosition(0, 20)
		self._rootnode.icon1:addChild(self.skillIconTab.skillName1)
	end
	self.skillIconTab.skillName1.lvLable:setString(skillCurLevel)
	if self.skillIconTab.skillName2 == nil then
		self.skillIconTab.skillName2 = PetModel.getPetSkillIcon({
		id = self.id,
		level = skillNextLevel,
		lockType = self.lock
		})
		self.skillIconTab.skillName2:setAnchorPoint(cc.p(0, 0))
		self.skillIconTab.skillName2:setPosition(0, 20)
		self._rootnode.icon2:addChild(self.skillIconTab.skillName2)
	end
	self.skillIconTab.skillName2.lvLable:setString(skillNextLevel)
end

return PetSkillInfo