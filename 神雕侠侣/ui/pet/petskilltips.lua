require "ui.dialog"
require "utils.log"
PetSkillTips = {}
setmetatable(PetSkillTips, Dialog)
PetSkillTips.__index = PetSkillTips

local _instance
function PetSkillTips.getSingleton()
	return _instance
end

function PetSkillTips.getSingletonDialog()
	if _instance == nil then
		_instance = PetSkillTips.new()
	end
	return _instance
end
function PetSkillTips.getSingletonDialogAndShow()
	if _instance == nil then
		_instance = PetSkillTips.new()
	else
		if not _instance:IsVisible() then
			_instance:SetVisible(true)
		end
	end

	return _instance
end

function PetSkillTips.new()
	local t = {}
	setmetatable(t, PetSkillTips)
	t.__index = PetSkillTips
	t:OnCreate()
	t:GetWindow():setAlwaysOnTop(true)
	return t
end

function PetSkillTips:OnCreate()
	LogInsane("PetSkillTips:OnCreate")
	Dialog.OnCreate(self)
	self:InitUI()
	self:InitEvent()
end

function PetSkillTips:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.Name = winMgr:getWindow("petskilltipsrich/name")
	self.Icon = CEGUI.toSkillBox(winMgr:getWindow("petskilltipsrich/back/icon"))
	self.Quality = winMgr:getWindow("petskilltipsrich/back/info")
	self.Score = winMgr:getWindow("petskilltipsrich/back/info1")
	self.Describe = CEGUI.toRichEditbox(winMgr:getWindow("petskilltipsrich/back/info3"))
	self.DiscardButton = winMgr:getWindow("petskilltipsrich/delete")
	self.ImproveButton = winMgr:getWindow("petskilltipsrich/use")
end

function PetSkillTips:InitEvent()
	self.DiscardButton:subscribeEvent("MouseClick", PetSkillTips.HandleDiscardBtnClicked, self)
	self.ImproveButton:subscribeEvent("MouseClick", PetSkillTips.HandleImproveBtnClicked, self)
end

function PetSkillTips:HandleDiscardBtnClicked(e)
	require "ui.pet.petskilldiscard"
	PetSkillDiscard.getSingletonDialogAndShow():setPetkeyAndSkillid(self.petkey, self.skillid)
	self:DestroyDialog()
	return true
end

function PetSkillTips:HandleImproveBtnClicked(e)
	require "ui.pet.petskillqh"
	PetSkillQh.getSingletonDialogAndShow():setPetkeyAndSkillid(self.petkey, self.skillid)
	self:DestroyDialog()
	return true
end

function PetSkillTips:DestroyDialog()
	LogInsane("destory PetSkillTips dialog")
	if self == _instance then
		self:OnClose()
		_instance = nil
	else
		LogInsane("Something class instance?")
	end
end

function PetSkillTips:ShowSkill()
	if self.petkey == -1 then
		self.DiscardButton:setVisible(false)
		self.ImproveButton:setVisible(false)
	end
	local skillconfig = knight.gsp.skill.GetCPetSkillConfigTableInstance():getRecorder(self.skillid)
	self.Name:setText(skillconfig.skillname)
	self.Icon:SetImage(GetIconManager():GetSkillIconByID(skillconfig.icon))
	local qpath = string.format("set:MainControl7 image:%d", skillconfig.color)
	LogInsane("qpath="..qpath)
	local bkimageset = CEGUI.String("BaseControl"..(math.floor((skillconfig.color-1)/4)+1))
    local bkimage = CEGUI.String("SkillInCell"..skillconfig.color)
    self.Icon:SetBackgroundDynamic(true)
    self.Icon:SetBackGroundImage(bkimageset, bkimage)
	self.Quality:setProperty("Image", qpath)
	self.Score:setText(skillconfig.score)
	self.Describe:Clear()
	self.Describe:AppendParseText(CEGUI.String(skillconfig.skilldescribe))
	self.Describe:Refresh()
end	
				 
function PetSkillTips:GetLayoutFileName()
	LogInsane("PetSkillTips:GetLayoutFileName")
	return "petskilltipsrich.layout"
end

function PetSkillTips:SetPetkeyAndSkillid(petkey, skillid)
	LogInsane(string.format("PetSkillTips petkey = %d, skillid = %d", petkey, skillid))
	self.petkey = petkey
	self.skillid = skillid
	self:ShowSkill()
end

return PetSkillTips
