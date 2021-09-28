RegistModules("Skill/View/SkillBigItem")
RegistModules("Skill/View/SkillEffect")
RegistModules("Skill/View/SkillEffectItem")
RegistModules("Skill/View/SkillItem")
RegistModules("Skill/View/SkillPanel")
RegistModules("Skill/View/SkillUpgradeConsume")
RegistModules("Skill/View/SkillBook")
RegistModules("Skill/View/SkillMainPanel")

RegistModules("Skill/SkillConst")




RegistModules("Skill/SkillModel")
RegistModules("Skill/SkillView")
RegistModules("Skill/Vo/SkillMsgVo")


SkillController = BaseClass(LuaController)

function SkillController:__init()
	self:Config()
	self:InitEvent()
	self:RegistProto()
end

function SkillController:Config()
	self.model = SkillModel:GetInstance()
end

function SkillController:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED , function()
		self:InitSkillMsgHandle()
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then
			self.model:Reset()
		end
	end)
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function (key, value, pre) self:HandlePlayerLevChange(key ,value , pre) end)
end

function SkillController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
end

function SkillController:InitData( e )
	
end

function SkillController:RegistProto()
	self:RegistProtocal("S_UpgradePlayerSkill", "UpgradePlayerSkillHandle") --升级技能回包处理
	self:RegistProtocal("S_SynPlayerSkill", "SyncSkillMasteryHandle") --同步技能熟练度
	self:RegistProtocal("S_CreatePlayerSkill", "GetPlayerSkill")
end

--升级某个技能
function SkillController:C_UpgradePlayerSkill(skillId)
	if skillId ~= nil then
		local msg = skill_pb.C_UpgradePlayerSkill()
		msg.skillId = skillId
		self:SendMsg("C_UpgradePlayerSkill", msg)
	end
end

-- 获取玩家技能列表
function SkillController:C_GetPlayerSkills()
	self:SendEmptyMsg(skill_pb, "C_GetPlayerSkills")
end

--学习某个技能
function SkillController:C_CreatePlayerSkill(skillId)
	if skillId ~= nil then
		local msg = skill_pb.C_CreatePlayerSkill()
		msg.skillId = skillId
		self:SendMsg("C_CreatePlayerSkill", msg)
	end
end

--使用物品来提升技能熟练度
function SkillController:C_AddSkillMastery(skillId, itemId)
	if skillId and itemId then
		local msg = skill_pb.C_AddSkillMastery()
		msg.skillId = skillId
		msg.itemId = itemId
		self:SendMsg("C_AddSkillMastery" , msg)
	end
end

function SkillController:InitSkillMsgHandle()
	local playerSkillList = LoginModel:GetInstance():GetListPlayerSkills()
	self.model:SetSkillMsg(playerSkillList or {})

	self:CheckRedTips()
end

function SkillController:UpgradePlayerSkillHandle(msgParam)
	local msg = self:ParseMsg(skill_pb.S_UpgradePlayerSkill(), msgParam)
	
	self.model:UpgradeSkillMsg(msg.skillId or -1, msg.newPlayerSkill or {})

	local oldSkillId = self.model:GetPreviousLevSkillId()
	self.model:UpgradeAllSkillMsg(oldSkillId or -1, msg.newPlayerSkill or {})

	local skillId = -1
	if msg.newPlayerSkill.mwSkillId ~= 0 then
		skillId = msg.newPlayerSkill.mwSkillId
	else
		skillId = msg.newPlayerSkill.skillId
	end

	GlobalDispatcher:DispatchEvent(EventName.SkillUpgrade, {oldSkillId = msg.skillId, newSkillId = skillId})

	self:CheckRedTips()
end

function SkillController:SyncSkillMasteryHandle(msgParam)

	local msg = self:ParseMsg(skill_pb.S_SynPlayerSkill(), msgParam)
	

	self.model:SyncSkillMastery(msg.playerSkill or {})
	self.model:SyncAllSkillMastery(msg.playerSkill or {})

	self:CheckRedTips()
	GlobalDispatcher:DispatchEvent(EventName.SyncSkillMastery)
end

function SkillController:OpenSkillPanel(tabIndex)
	if not self.view then
		self.view = SkillView.New()
		
	end
	self.model:InitAllSkillList()
	self.view:OpenSkillPanel(tabIndex)
end

--打开技能面板，默认选中某个技能
function SkillController:OpenSkillPanelById(skillId)
	if not self.view then
		self.view = SkillView.New()
		
	end
	self.model:InitAllSkillList()
	self.view:OpenSkillPanelById(skillId)
end

--打开技能书UI
function SkillController:OpenSkillBookUI()
	if not self.view then
		self.view = SkillView.New()
	end
	self.view:OpenSkillBookUI()
end

--关闭技能书UI
function SkillController:CloseSkillBookUI()
	if not self.view then
		self.view = SkillView.New()
	end
	self.view:CloseSkillBookUI()
end

function SkillController:GetPlayerSkill(msgParam)
	local msg = self:ParseMsg(skill_pb.S_CreatePlayerSkill(), msgParam)
	
	if msg.playerSkill then
		self.model:ActiveSkillMsg(msg.playerSkill)
		
		GlobalDispatcher:DispatchEvent(EventName.SkillUpgrade, {oldSkillId = -1, newSkillId = msg.playerSkill.skillId})
		UIMgr.Win_FloatTip(string.format("恭喜你，学会技能：%s", SkillModel:GetInstance():GetSkillNameById(msg.playerSkill.skillId)))
	end
end

function SkillController:HandlePlayerLevChange(key ,value , pre)
	if key == "level" then
		self:CheckRedTips()		
	end
end

function SkillController:CheckRedTips()
	if self.model:IsAllSkillListEmpty() then
		self.model:InitAllSkillList()
	end
	self.model:ShowSkillRedTips()
end

function SkillController:GetInstance()
	if SkillController.inst == nil then
		SkillController.inst = SkillController.New()
	end
	return SkillController.inst
end

function SkillController:__delete()
	self:CleanEvent()
	SkillController.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
	if self.view then
		self.view:Destroy()
	end
	self.view = nil
end

