require "Core.Module.Common.UIComponent"
-- require "Core.Module.Pet.View.Item.PetAdvancePropertyItem"
-- require "Core.Module.Pet.View.Item.PetFateItem"
require "Core.Module.Common.StarItem"
require "Core.Module.Common.FloatLabel"
local PetSkillGroupItem = require "Core.Module.Pet.View.Item.PetSkillGroupItem"
local BaseIconItem = require "Core.Module.Common.BaseIconItem"
local BaseNextPropertyItem = require "Core.Module.Common.BaseNextPropertyItem"
local PetFashionEffect = require "Core.Module.Pet.View.Item.PetFashionEffect"
local ItemCountLabel = require "Core.Module.Common.ItemCountLabel"

local floatTime = 0.4

SubPetAdvancePanel = class("SubPetAdvancePanel", UIComponent);
local enable = LanguageMgr.Get("Pet/SubPetAdvancePanel/enable")
local unEnable = LanguageMgr.Get("Pet/SubPetAdvancePanel/unEnable")

local _auto1 = LanguageMgr.Get("Pet/SubPetAdvancePanel/Auto1")
local _auto2 = LanguageMgr.Get("Pet/SubPetAdvancePanel/Auto2")
function SubPetAdvancePanel:New()
	self = {};
	setmetatable(self, {__index = SubPetAdvancePanel});
	return self
end

function SubPetAdvancePanel:_Init()
	self._txtName = UIUtil.GetChildByName(self._transform, "UILabel", "txtName")
	self._txtLevel = UIUtil.GetChildByName(self._transform, "UILabel", "txtLevel")
	self._txtExp = UIUtil.GetChildByName(self._transform, "UILabel", "slider_exp/txtExp")
	self._slider = UIUtil.GetChildByName(self._transform, "UISlider", "slider_exp")
	self._txtRank = UIUtil.GetChildByName(self._transform, "UILabel", "txtRanklevel")
	local txtNum = UIUtil.GetChildByName(self._transform, "UILabel", "item/num")
	self._itemCountLabel = ItemCountLabel:New()
	self._itemCountLabel:Init(txtNum)
	self._roleParent = UIUtil.GetChildByName(self._transform, "imgRole/heroCamera/trsRoleParent")
	self._txtPower = UIUtil.GetChildByName(self._transform, "UILabel", "txtPower")
	
	self._btnAdvance = UIUtil.GetChildByName(self._transform, "UIButton", "btnAdvance")
	self._txtAuto = UIUtil.GetChildByName(self._btnAdvance, "UILabel", "Label")
	self._txtAuto.text = _auto1
	self._imgFight = UIUtil.GetChildByName(self._transform, "UISprite", "imgFight")
	self._goLeft = UIUtil.GetChildByName(self._transform, "imgLeft").gameObject
	self._goRight = UIUtil.GetChildByName(self._transform, "imgRight").gameObject
	
	
	-- self._goFull = UIUtil.GetChildByName(self._transform, "goFull").gameObject
	self._goLock = UIUtil.GetChildByName(self._transform, "goLock").gameObject
	
	self._goHadFight = UIUtil.GetChildByName(self._transform, "hadFight").gameObject
	self._curPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "propertyPhalanx")
	self._curPropertyPhalanx = Phalanx:New()
	self._curPropertyPhalanx:Init(self._curPropertyPhalanxInfo, BasePropertyItem)
	
	self._nextPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "nextpropertyPhalanx")
	self._nextPropertyPhalanx = Phalanx:New()
	self._nextPropertyPhalanx:Init(self._nextPropertyPhalanxInfo, BaseNextPropertyItem)
	
	self._starPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "phalanx")
	self._starPhalanx = Phalanx:New()
	self._starPhalanx:Init(self._starPhalanxInfo, StarItem)
	
	local skillParent = UIUtil.GetChildByName(self._transform, "skillParent")
	self._skillGroup = PetSkillGroupItem:New()
	self._skillGroup:Init(skillParent)	
	local item = UIUtil.GetChildByName(self._transform, "item").gameObject
	self._baseIconItem = BaseIconItem:New()
	self._baseIconItem:Init(item)
	
	
	self._floatTxt = FloatLabel:New()
	self._floatTxt:Init(self._slider.transform, ResID.UI_ADDTXT, floatTime)
	
	local effectBg = UIUtil.GetChildByName(self._transform, "UITexture", "imgRole")
	local effectParent = UIUtil.GetChildByName(self._transform, "effectParent")
	self._effect = UIEffect:New()		
	self._effect:Init(effectParent, effectBg, 4, "ui_partner_update")
	
	
	self._expEffect = UIEffect:New();
	self._expEffect:Init(self._slider.transform, self._slider.foregroundWidget, 3, "ui_refining_1")
	
	local starLabel = UIUtil.GetChildByName(self._transform, "UILabel", "StarLabel")
	self._starEffect = UIEffect:New()
	self._starEffect:Init(self._transform, self._slider.backgroundWidget, 3, "ui_star")
	
	self._timer = FixedTimer.New(function() self:Update(time) end, 0.2, - 1, false)
	self._timer:Start()
	self._timer:Pause(true)
	
	self._levelEffect = PetFashionEffect:New()	
	self._levelEffect:Init(effectParent, effectBg, 0, "", - 1)
	self._effectPath = ""
	self:_AddBtnListen(self._goLeft)
	self:_AddBtnListen(self._goRight)
	self:_AddBtnListen(self._imgFight.gameObject)	
	self:_AddBtnListen(self._btnAdvance.gameObject)
end

function SubPetAdvancePanel:Update()	
	if(self._currentPet:GetCanUpdateStar()) then
		PetProxy.SendPetAdvance()
	else
		self._timer:Pause(true)
		self._txtAuto.text = _auto1
	end
end

function SubPetAdvancePanel:_OnBtnsClick(go)
	if(go == self._goLeft) then
		self:_OnClickBtnLeft()
	elseif go == self._goRight then
		self:_OnClickBtnRight()
	elseif go == self._imgFight.gameObject then
		self:_OnClickBtnFight()
	elseif go == self._btnAdvance.gameObject then
		self:_OnClickAdvance()
	end
end

function SubPetAdvancePanel:_OnClickBtnLeft()
	local data = PetManager.GetLastAdvanceFashionData(self._curPetFashionData:GetId())
	if(data) then
		self._curPetFashionData = data
		self:_UpdateCurFashionData(data)
	end
end

function SubPetAdvancePanel:_OnClickBtnRight()
	local data = PetManager.GetNextAdvanceFashionData(self._curPetFashionData:GetId())
	if(data) then
		self._curPetFashionData = data
		self:_UpdateCurFashionData(data)
	end
end

function SubPetAdvancePanel:_OnClickBtnFight()
	PetProxy.SendPetFight(self._curPetFashionData:GetId())
end

function SubPetAdvancePanel:_OnClickAdvance()	
	if(self._currentPet:GetCanUpdateStar()) then
		self._timer:Pause(false)
		self._txtAuto.text = _auto2
	else
		ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,
		{id = self._currentPet:GetAdvanceNeedItemId(), updateNote = PetNotes.UPDATE_PETPANEL})
	end
end

function SubPetAdvancePanel:_Dispose()
	self._nextPropertyPhalanx:Dispose()
	self._nextPropertyPhalanx = nil
	self._curPropertyPhalanx:Dispose()
	self._curPropertyPhalanx = nil
	
	self._skillGroup:Dispose()
	self._skillGroup = nil
	if(self._uiPetAnimationModel) then
		self._uiPetAnimationModel:Dispose()
		self._uiPetAnimationModel = nil
	end
	self._baseIconItem:Dispose()
	self._baseIconItem = nil
	self._itemCountLabel:Dispose()
	self._itemCountLabel = nil
	self._floatTxt:Dispose()
	self._floatTxt = nil
	
	if self._effect then
		self._effect:Dispose()
		self._effect = nil
	end
	
	if(self._levelEffect) then
		self._levelEffect:Dispose()
		self._levelEffect = nil
	end
	
	if(self._starEffect) then
		self._starEffect:Dispose()
		self._starEffect = nil
		
	end
	
	if(self._expEffect) then
		self._expEffect:Dispose()
		self._expEffect = nil
	end
	
	if(self._timer) then
		self._timer:Stop()
		self._timer = nil		
	end
end

function SubPetAdvancePanel:UpdatePanel()	
	self:UpdateCurFashionData()	
	self:UpdateRank()		
end

local _star = {false, false, false, false, false, false, false, false, false, false}

local blue = ColorDataManager.Get_blue()
local purple = ColorDataManager.Get_purple()
local gold = ColorDataManager.Get_golden()
local orange = ColorDataManager.Get_orange()
local red = ColorDataManager.Get_red()



function SubPetAdvancePanel:UpdateRank()
	self._currentPet = PetManager.GetCurrentPetdata()
	self:UpdateExp()	
	local star = self._currentPet:GetShowStar()
	
	for i = 1, 10 do
		_star[i] = i <= star	
	end
	
	self._starPhalanx:Build(1, 10, _star)
	
	local p = self._currentPet:GetRankAttr():GetPropertyAndDes()
	self._curPropertyPhalanx:Build(#p, 1, p)
	
	local nextConfig = PetManager.GetPetAdvanceConfig(self._currentPet:GetRank() + 1)
	if(nextConfig) then
		local attr = BaseAdvanceAttrInfo:New()
		attr:Init(nextConfig)
		attr:Sub(self._currentPet:GetRankAttr())
		local nextproperty = attr:GetPropertyAndDes()
		self._nextPropertyPhalanx:Build(#nextproperty, 1, nextproperty)
	else
		self._nextPropertyPhalanx:Build(0, 0, {})
	end	
	self._baseIconItem:UpdateItem(self._currentPet:GetAdvanceNeedItem())
	
	local isUpdate = self._curPetFashionData:SetRankLevel(self._currentPet:GetRank())
	if(isUpdate) then	
		local allSkills = self._curPetFashionData:GetAllAddSkills()
		self._skillGroup:UpdateItem(allSkills)
	end
	self._txtPower.text = self._currentPet:GetRankPower()
	
end

function SubPetAdvancePanel:UpdateExp()
	local curPet = PetManager.GetCurrentPetdata()
	self._txtExp.text = curPet:GetRankExp() .. "/" .. curPet:GetRankMaxExp()
	self._slider.value = curPet:GetRankExp() / curPet:GetRankMaxExp()
	self._itemCountLabel:UpdateItemById(self._currentPet:GetAdvanceNeedItemId(), self._currentPet:GetAdvanceNeedItemCount())
end

--更新身体数据
function SubPetAdvancePanel:UpdateCurFashionData()
	local _currentPet = PetManager.GetCurrentPetdata()
	local curUsedata = PetManager.GetPetAdvanceFashionDataById(_currentPet:GetCurRankFashionId())	
	self:_UpdateCurFashionData(curUsedata)		
end

function SubPetAdvancePanel:UpdateFashionData(data)
	self:_UpdateCurFashionData(data)
end

function SubPetAdvancePanel:_UpdateCurFashionData(data)
	if(data) then
		self._curPetFashionData = data
	end
	
	local _currentPet = PetManager.GetCurrentPetdata()
	local allSkills = data:GetAllAddSkills()
	self._skillGroup:UpdateItem(allSkills)
	
	if(self._uiPetAnimationModel == nil) then
		self._uiPetAnimationModel = UIAnimationModel:New(data, self._roleParent, PetModelCreater)
	else
		self._uiPetAnimationModel:ChangeModel(data, self._roleParent)
	end
	
	self._levelEffect:SetByConfig(data:GetEffectConfig())
	self._uiPetAnimationModel:SetScale(data:GetScale())
	
	
	local isPetUsed = self._curPetFashionData:GetId() == PetManager.GetCurUsePetId()
	self._goHadFight:SetActive(isPetUsed)
	
	self._imgFight.gameObject:SetActive(not isPetUsed and _currentPet:GetRankLevel() >= self._curPetFashionData:GetActiveLevel())
	
	
	self._goLock:SetActive(_currentPet:GetRankLevel() < self._curPetFashionData:GetActiveLevel())
	self._txtName.text = self._curPetFashionData:GetName()
	self._txtName.color = ColorDataManager.GetColorByQuality(self._curPetFashionData:GetQuality())
	
	local rank = self._curPetFashionData:GetActiveLevel()
	self._txtRank.text = LanguageMgr.Get("Pet/SubPetAdvancePanel/rank" .. rank)
	local color
	
	if(rank > 0 and rank <= 2) then
		color = blue
	elseif rank <= 5 then
		color = purple
	elseif rank <= 8 then
		color = gold
	elseif rank <= 11 then
		color = orange		
	else
		color = red	
	end	
	self._txtRank.color = color
end

local critExp = LanguageMgr.Get("wing/SubWingPanel/critExp")
function SubPetAdvancePanel:ShowUpdateLevelLabel(value)
	if(value > 0) then
		if(self._floatTxt) then

			if(value > 10) then
				self._floatTxt:Play(critExp .. value)
			else
				self._floatTxt:Play("+" .. value)				
			end
		 
		end
	end
end


function SubPetAdvancePanel:ShowUpdateRankEffect()
	if(self._effect) then
		self._effect:Play()
	end
	if(self._expEffect) then
		self._expEffect:Play()
	end
	
	if(self._timer) then
		self._timer:Pause(true)
		self._txtAuto.text = _auto1
	end
	
	if(self._starEffect) then
		local pet = PetManager.GetCurrentPetdata()
		if(pet:GetShowStar() ~= 0) then
			local item = self._starPhalanx:GetItem(pet:GetShowStar())
			self._starEffect:Play()
			if(item) then
				local pos = item.itemLogic.transform.position
				self._starEffect:SetPos1(pos.x, pos.y)
			end
		end	
	end	
end


function SubPetAdvancePanel:StopAdvanceTimer()
	if(self._timer) then
		self._timer:Pause(true)
		self._txtAuto.text = _auto1
	end
end 