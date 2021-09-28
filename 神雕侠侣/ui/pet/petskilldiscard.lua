require "ui.dialog"
require "utils.log"
PetSkillDiscard = {}
setmetatable(PetSkillDiscard, Dialog)
PetSkillDiscard.__index = PetSkillDiscard

local _instance
function PetSkillDiscard.getSingleton()
	return _instance
end

function PetSkillDiscard.getSingletonDialog()
	if _instance == nil then
		_instance = PetSkillDiscard.new()
	end
	return _instance
end
function PetSkillDiscard.getSingletonDialogAndShow()
	if _instance == nil then
		_instance = PetSkillDiscard.new()
	else
		if not _instance:IsVisible() then
			_instance:SetVisible(true)
		end
	end

	return _instance
end

function PetSkillDiscard.new()
	local t = {}
	setmetatable(t, PetSkillDiscard)
	t.__index = PetSkillDiscard
	t.discarditemid = 38004
	t:OnCreate()
	t:GetWindow():setAlwaysOnTop(true)
	return t
end

function PetSkillDiscard:OnCreate()
	LogInsane("PetSkillDiscard:OnCreate") 
	Dialog.OnCreate(self)
	self:InitUI()
	self:InitEvent()
	
	local discarditemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(self.discarditemid)
	self.SkillSpendItem:SetImage(GetIconManager():GetItemIconByID(discarditemattr.icon))
end

function PetSkillDiscard:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.Name = winMgr:getWindow("petskillbookexcise/info0")
	self.SkillName = winMgr:getWindow("petskillbookexcise/info1")
	self.SkillType = winMgr:getWindow("petskillbookexcise/info2")
	self.SkillSpend = winMgr:getWindow("petskillbookexcise/info4")
	self.SkillSpendItem = CEGUI.toItemCell(winMgr:getWindow("petskillbookexcise/item"))
	self.SkillSpendItemName = winMgr:getWindow("petskillbookexcise/info3")
	self.OkButton = CEGUI.toPushButton(winMgr:getWindow("petskillbookexcise/ok"))
	self.CancelButton = CEGUI.toPushButton(winMgr:getWindow("petskillbookexcise/cancel"))
end

function PetSkillDiscard:InitEvent()
	self.OkButton:subscribeEvent("MouseClick", PetSkillDiscard.HandleConfirmDiscard, self)
	self.CancelButton:subscribeEvent("MouseClick", PetSkillDiscard.HandleCancelDiscard, self)
end

function PetSkillDiscard:HandleConfirmDiscard(e)
	if self.isPetBasicSkill then
		local itemnum = GetRoleItemManager():GetItemNumByBaseID(self.discarditemid)
		if itemnum <= 0 then
			LogInsane("Not enough discard item")
            if GetChatManager() then
                GetChatManager():AddTipsMsg(144930)
            end
			CGreenChannel:GetSingletonDialogAndShowIt():SetItem(self.discarditemid)
			return true
		end
	end
	GetNetConnection():send(knight.gsp.pet.CDeductPetSkill(self.petkey, self.skillid))
	self:DestoryDialog()
	return true
end

function PetSkillDiscard:HandleCancelDiscard(e)
	self:DestoryDialog()
	return true
end

function PetSkillDiscard:DestoryDialog()
	LogInsane("destory PetSkillDiscard dialog")
	if self == _instance then
		self:OnClose()
		_instance = nil
	else
		LogInsane("Something class instance?")
	end
end
function PetSkillDiscard:GetLayoutFileName()
	LogInsane("PetSkillDiscard:GetLayoutFileName")
	return "petskillbookexcise.layout"
end
function PetSkillDiscard:setPetkeyAndSkillid(petkey, skillid)
	self.petkey = petkey
	self.skillid = skillid
	local petinfo = GetDataManager():FindMyPetByID(petkey)
	self.isPetBasicSkill = false
	if petinfo then
		self.Name:setText(petinfo.name)
		local petskillconfig = knight.gsp.skill.GetCPetSkillConfigTableInstance():getRecorder(skillid)
		self.SkillName:setText(petskillconfig.skillname)
		for i = 1, petinfo:getSkilllistlen() do
			local petskill = petinfo:getSkill(i)
			LogInsane(string.format("pet skillid=%d, type=%d", petskill.skillid, petskill.skilltype))
			if petskill.skillid == skillid then
				self.isPetBasicSkill = petskill.skilltype == 0
				break
			end
		end
	end
	if self.isPetBasicSkill then
		self.SkillType:setText(MHSD_UTILS.get_resstring(2758))
		self.SkillSpend:setVisible(false)
		self.SkillSpendItem:setVisible(true)
		self.SkillSpendItemName:setVisible(true)
	else
		self.SkillType:setText(MHSD_UTILS.get_resstring(2759))
		self.SkillSpend:setVisible(true)
		self.SkillSpendItem:setVisible(false)
		self.SkillSpendItemName:setVisible(false)
	end
	--self.m_pMainFrame:setPosition()
end
return PetSkillDiscard