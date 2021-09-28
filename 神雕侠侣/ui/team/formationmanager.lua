FormationManager = {}
FormationManager.__index = FormationManager

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FormationManager.getInstance()
	LogInfo("enter get FormationManager instance")
    if not _instance then
        _instance = FormationManager:new()
    end
    
    return _instance
end

function FormationManager.getInstanceNotCreate()
    return _instance
end

function FormationManager.Destroy()
	if _instance then 
		LogInfo("destroy FormationManager")
		_instance = nil
	end
end

function FormationManager.InitFormation()
	LogInfo("FormationManager init formation")
	local instance = FormationManager.getInstance()
	instance.m_lFormaitonList = {}
	for i = 1, 10 do
		instance.m_lFormaitonList[i] = GetDataManager():getFormation(i - 1)
	end
end


------------------- private: -----------------------------------

function FormationManager:new()
    local self = {}
	setmetatable(self, FormationManager)
	self.m_lFormaitonList = {}
	for i = 1, 10 do
		self.m_lFormaitonList[i] = {}
		self.m_lFormaitonList[i].activetimes = 0
		self.m_lFormaitonList[i].level = 0
	end
	self.m_iMyFormation = 0
	self.m_iTeamFormation = 0
	self.m_iTeamFormationLevel = 1

    return self
end

function FormationManager:updateFormations(formationmap)
	LogInfo("FormationManager update formation")
	for i,v in pairs(formationmap) do
		if self.m_lFormaitonList[i].activetimes ~= v.activetimes or self.m_lFormaitonList[i].level ~= v.level then
			self.m_iLevelChange = nil
			self.m_iActiveChange = nil
			if self.m_lFormaitonList[i].level ~= v.level then
				self.m_iLevelChange = i
			else
				self.m_iActiveChange = i
			end
		end
		self.m_lFormaitonList[i].activetimes = v.activetimes
		self.m_lFormaitonList[i].level = v.level
	end
	local dlg = ZhenfaChooseDlg.getInstanceNotCreate()
	if dlg then
		dlg:updateFormations()
	end
end

function FormationManager:setMyFormation(formation, entersend)
	self.m_iMyFormation = formation
	if entersend == 0 then
		if TeamDialog.getInstanceNotCreate() then
			TeamDialog.getInstanceNotCreate():refreshFormation()
		end	
		if BuzhenXiake.peekInstance() then
			BuzhenXiake.peekInstance():refreshFormation()
		end
		local dlg = ZhenfaChooseDlg.getInstanceNotCreate()
		if dlg then
			dlg:setFormationSelect(dlg.m_iCurSelect)
		end
		local XiaGanYiDanBattleDlg = require "ui.xiaganyidan.xiaganyidanbattledlg"
		if XiaGanYiDanBattleDlg:getInstanceOrNot() then
			XiaGanYiDanBattleDlg:getInstanceOrNot():RefreshZhengFa(self.m_iMyFormation)
		end
	end
end

function FormationManager:setTeamFormation(formation, formationlevel, msg)
	LogInfo("FormationManager set team formation")
	self.m_iTeamFormation = formation
	self.m_iTeamFormationLevel = formationlevel	
	if TeamDialog.getInstanceNotCreate() then
		TeamDialog.getInstanceNotCreate():refreshFormation()
	end
end

return FormationManager
