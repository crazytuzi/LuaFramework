require "Core.Module.Common.UIComponent"
require "Core.Module.Common.StarItem"
local PetItem = require "Core.Module.Pet.View.Item.PetItem"
local PetSkillGroupItem = require "Core.Module.Pet.View.Item.PetSkillGroupItem"
local BaseIconItem = require "Core.Module.Common.BaseIconItem"
local PetNextAttrItem = require "Core.Module.Pet.View.Item.PetNextAttrItem"
local ItemCountLabel = require "Core.Module.Common.ItemCountLabel"
local PetFashionEffect = require "Core.Module.Pet.View.Item.PetFashionEffect"

local SubPetFashionPanel = class("SubPetFashionPanel", UIComponent);
local _SetUIEnable = SetUIEnable

function SubPetFashionPanel:New()
	self = {};
	setmetatable(self, {__index = SubPetFashionPanel});
	return self
end

function SubPetFashionPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function SubPetFashionPanel:_InitReference()
	
	self._txtPower = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtPower");
	self._txtName = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtName");
	self._trsRoleParent = UIUtil.GetChildByName(self._gameObject, "imgRole/heroCamera/trsRoleParent");
	self._txtNotice = UIUtil.GetChildByName(self._gameObject, "UILabel", "bg/notice")
	self._curPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "propertyPhalanx")
	self._curPropertyPhalanx = Phalanx:New()
	self._curPropertyPhalanx:Init(self._curPropertyPhalanxInfo, BasePropertyItem)
	
	self._nextPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "nextpropertyPhalanx")
	self._nextPropertyPhalanx = Phalanx:New()
	self._nextPropertyPhalanx:Init(self._nextPropertyPhalanxInfo, PetNextAttrItem)
	
	self._roleParent = UIUtil.GetChildByName(self._transform, "imgRole/heroCamera/trsRoleParent")
	
	local skillParent = UIUtil.GetChildByName(self._transform, "skillParent")
	self._skillGroup = PetSkillGroupItem:New()
	self._skillGroup:Init(skillParent)	
	
	
	self._petPhalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "Panel/petPhalanx");
	self._petPhalanx = Phalanx:New();
	self._petPhalanx:Init(self._petPhalanxInfo, PetItem)
	
	self._trsNotActive = UIUtil.GetChildByName(self._gameObject, "NotActive")
	self._trsActive = UIUtil.GetChildByName(self._gameObject, "HadActive")
	
	self._trsCanUpdate = UIUtil.GetChildByName(self._trsActive, "CanUpdate")
	self._trsCantUpdate = UIUtil.GetChildByName(self._trsActive, "CantUpdate")	
	
	
	self._starPhalanxInfo = UIUtil.GetChildByName(self._trsActive, "LuaAsynPhalanx", "phalanx")
	self._starPhalanx = Phalanx:New()
	self._starPhalanx:Init(self._starPhalanxInfo, StarItem)
	
	self._imgFight = UIUtil.GetChildByName(self._trsActive, "UISprite", "imgFight");
	self._goHadFight = UIUtil.GetChildByName(self._trsActive, "hadFight").gameObject
	
	local item = UIUtil.GetChildByName(self._trsNotActive, "item").gameObject
	local _txtActiveItemNum = UIUtil.GetChildByName(item, "UILabel", "num")
	self._itemCountLabel = ItemCountLabel:New()
	self._itemCountLabel:Init(_txtActiveItemNum)
	self._activeItem = BaseIconItem:New()
	self._activeItem:Init(item)	
	self._btnActive = UIUtil.GetChildByName(self._trsNotActive, "UIButton", "btnActive");
	
	item = UIUtil.GetChildByName(self._trsCanUpdate, "item").gameObject
	local _txtUpdateItemNum = UIUtil.GetChildByName(item, "UILabel", "num")
	
	self._updateItemCountLabel = ItemCountLabel:New()
	self._updateItemCountLabel:Init(_txtUpdateItemNum)
	self._updateItem = BaseIconItem:New()
	self._updateItem:Init(item)	
	self._btnUpdate = UIUtil.GetChildByName(self._trsCanUpdate, "UIButton", "btnUpdate");
	
	local effectBg = UIUtil.GetChildByName(self._transform, "UITexture", "imgRole")
	local effectParent = UIUtil.GetChildByName(self._transform, "effectParent")
	self._effect = UIEffect:New()		
	self._effect:Init(effectParent, effectBg, 4, "ui_partner_update")
	
	
	self._levelEffect = PetFashionEffect:New()	
	self._levelEffect:Init(effectParent, effectBg, 0, "",-1)
	self._goNext = UIUtil.GetChildByName(self._transform, 'goNext').gameObject
	
	self._imgPower = UIUtil.GetChildByName(self._transform, "UISprite", "trsPower/imgPower")
end

function SubPetFashionPanel:_InitListener()
	self:_AddBtnListen(self._btnActive.gameObject)
	self:_AddBtnListen(self._btnUpdate.gameObject)
	self:_AddBtnListen(self._imgFight.gameObject)
	
end

function SubPetFashionPanel:_OnBtnsClick(go)
	
	if go == self._btnActive.gameObject then
		self:_OnClickBtnActive()
	elseif go == self._btnUpdate.gameObject then
		self:_OnClickBtnUpdate()
	elseif go == self._imgFight.gameObject then
		self:_OnClickBtnFight()
	end
end

function SubPetFashionPanel:_OnClickBtnFight()
	PetProxy.SendPetFight(self._curSelectdata:GetId())	
end

function SubPetFashionPanel:_OnClickBtnActive()
	
	if(self._curSelectdata:GetCanActive()) then
		PetProxy.SendActivePet(self._curSelectdata:GetId())
	else
		MsgUtils.ShowTips("Pet/SubPetFashionPanel/notice3")
		-- ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,
		-- {id = self._curSelectdata:GetActiveNeedItemId(), updateNote = PetNotes.UPDATE_PETPANEL})
	end
	
end

function SubPetFashionPanel:_OnClickBtnUpdate()
	if(self._curSelectdata:GetCanUpdate()) then
		PetProxy.SendUpdateFashionPet(self._curSelectdata:GetId())
	else
		MsgUtils.ShowTips("Pet/SubPetFashionPanel/notice3")
		-- ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL,
		-- {id = self._curSelectdata:GetFashionNeedItemId(), updateNote = PetNotes.UPDATE_PETPANEL})
	end
end

function SubPetFashionPanel:_Dispose()
	self:_DisposeReference();
	self._itemCountLabel:Dispose()
	self._itemCountLabel = nil
	self._updateItemCountLabel:Dispose()
	self._updateItemCountLabel = nil
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
	self._starPhalanx:Dispose()
	self._starPhalanx = nil
	
	self._petPhalanx:Dispose()
	self._petPhalanx = nil
	
	self._updateItem:Dispose()
	self._updateItem = nil
	
	self._activeItem:Dispose()
	self._activeItem = nil
	
	if(self._effect) then
		self._effect:Dispose()
		self._effect = nil
	end
	
	if(self._levelEffect) then
		self._levelEffect:Dispose()
		self._levelEffect = nil
	end
	
end

local star = {false, false, false, false}
function SubPetFashionPanel:UpdatePanel()
	self:UpdatePetFashionPanel(self._curSelectdata)
end
local notice1 = LanguageMgr.Get("Pet/SubPetFashionPanel/notice1")
local notice2 = LanguageMgr.Get("Pet/SubPetFashionPanel/notice2")

function SubPetFashionPanel:UpdatePetFashionPanel(data)
	local allPetData = PetManager.GetAllPetFashionData()
	self._petPhalanx:Build(#allPetData, 1, allPetData)
	if(data) then
		
		local items = self._petPhalanx:GetItems()
		self._curSelectdata = data	
		for k, v in ipairs(items) do
			if(v.itemLogic.data:GetId() == self._curSelectdata:GetId()) then
				v.itemLogic:SetToggleActive(true, false)
			end
		end
		local isActive = self._curSelectdata:GetIsActive()
		
		self._levelEffect:SetByConfig(self._curSelectdata:GetEffectConfig())
		
		self._imgPower.spriteName = isActive and "fight" or "activePower"
		self._imgPower:MakePixelPerfect()
		self._txtNotice.text = isActive and notice2 or notice1
		self._imgFight.gameObject:SetActive(isActive and(self._curSelectdata:GetId() ~= PetManager.GetCurUsePetId()))
		self._goHadFight:SetActive(self._curSelectdata:GetId() == PetManager.GetCurUsePetId())
		if(self._uiPetAnimationModel == nil) then
			self._uiPetAnimationModel = UIAnimationModel:New(data, self._roleParent, PetModelCreater)
		else
			self._uiPetAnimationModel:ChangeModel(data, self._roleParent)
		end	
		self._txtName.text = self._curSelectdata:GetName()
		self._txtName.color = ColorDataManager.GetColorByQuality(self._curSelectdata:GetQuality())
		
		self._txtPower.text = self._curSelectdata:GetPower()
		local allSkills = data:GetAllAddSkills()
		self._skillGroup:UpdateItem(allSkills)
		
		if(self._uiPetAnimationModel == nil) then
			self._uiPetAnimationModel = UIAnimationModel:New(self._curSelectdata, self._roleParent, PetModelCreater)
		else
			self._uiPetAnimationModel:ChangeModel(self._curSelectdata, self._roleParent)
		end
		self._uiPetAnimationModel:SetScale(self._curSelectdata:GetScale())
		self:UpdateLevel()
	else
		local item = self._petPhalanx:GetItem(1)
		item.itemLogic:SetToggleActive(true, true)
	end
end

function SubPetFashionPanel:UpdateLevel()
	local p = self._curSelectdata:GetAttr():GetPropertyAndDes()
	self._curPropertyPhalanx:Build(2, 2, p)
	local isActive = self._curSelectdata:GetIsActive()
	
	SetUIEnable(self._trsNotActive, not isActive)	
	SetUIEnable(self._trsActive, isActive)	
	
	if(isActive) then
		local nextConfig = PetManager.GetPetTransformConfig(self._curSelectdata:GetId(), self._curSelectdata:GetFashionLev() + 1)
		self._goNext:SetActive(nextConfig ~= nil)
		if(nextConfig) then
			local attr = BaseAdvanceAttrInfo:New()
			attr:Init(nextConfig)
			local nextproperty = attr:GetPropertyAndDes()
			self._nextPropertyPhalanx:Build(2, 2, nextproperty)
		else
			self._nextPropertyPhalanx:Build(0, 0, {})
		end	
		
		local isMax = self._curSelectdata:GetIsMax()		
		SetUIEnable(self._trsCanUpdate, not isMax)	
		SetUIEnable(self._trsCantUpdate, isMax)	
		local curStar = self._curSelectdata:GetFashionLev()
		for i = 1, 4 do
			if(i <= curStar) then
				star[i] = true
			else
				star[i] = false
			end				
		end
		
		self._starPhalanx:Build(1, #star, star)
		if(not isMax) then
			local count = BackpackDataManager.GetProductTotalNumBySpid(self._curSelectdata:GetFashionNeedItemId())
			self._updateItemCountLabel:UpdateItemById(self._curSelectdata:GetFashionNeedItemId(), self._curSelectdata:GetFashionNeedItemCount())
			-- self._txtUpdateItemNum.text =	count .. "/" .. self._curSelectdata:GetFashionNeedItemCount()
			self._updateItem:UpdateItem(self._curSelectdata:GetFashionNeedItem())			
		end	
	else
		self._nextPropertyPhalanx:Build(0, 0, {})
		self._goNext:SetActive(false)
		SetUIEnable(self._trsCanUpdate, false)	
		SetUIEnable(self._trsCantUpdate, false)
		self._starPhalanx:Build(0, 0, {})
		self._activeItem:UpdateItem(self._curSelectdata:GetActiveNeedItem())
		
		self._itemCountLabel:UpdateItemById(self._curSelectdata:GetActiveNeedItemId(), self._curSelectdata:GetActiveNeedItemCount())
		
	end
end

function SubPetFashionPanel:_DisposeReference()
	self._btnActive = nil;
	self._btnUpdate = nil;
	self._txtPower = nil;
	self._txtDes = nil;
	self._txtDes = nil;
	self._txtName = nil;
	self._txtCombine = nil;
	self._imgQuality = nil;
	self._imgSkillIcon = nil;
	self._imgQuality = nil;
	self._imgSkillIcon = nil;
	self._imgQuality = nil;
	self._imgSkillIcon = nil;
	self._imgQuality = nil;
	self._imgSkillIcon = nil;
	self._imgQuality = nil;
	self._imgSkillIcon = nil;
	self._imgFight = nil;
	self._trsRoleParent = nil;
	self._trsPower = nil;
end


function SubPetFashionPanel:ShowFashionEffect()
	if(self._effect) then
		self._effect:Play()
	end
end

return SubPetFashionPanel 