--技能按键管理类
BtnSkillView =BaseClass()

Slot = {
	pos1 = 1, --槽位1
	pos2 = 2, --槽位2
	pos3 = 3, --槽位3
	pos4 = 4, --槽位4
	pos5 = 5, --槽位5
}

BtnSkillView.SkillCdMap = {}
function BtnSkillView.RecordRunningCd(skillId, cd)
	skillId = BtnSkillView.FilterSamePosSkill(skillId)
	if cd <= 0 then
	 BtnSkillView.SkillCdMap[skillId] = nil
	else
	 BtnSkillView.SkillCdMap[skillId] = cd
	end
end

function BtnSkillView.GetRunningCd(skillId)
	skillId = BtnSkillView.FilterSamePosSkill(skillId)
	return BtnSkillView.SkillCdMap[skillId] or 0
end

--同一个孔用一个cd
function BtnSkillView.FilterSamePosSkill(skillId)
	local newSkillCfg = SkillModel:GetInstance():GetSkillVo(skillId)
	if newSkillCfg then
		local id = BtnSkillView.GetSamePosSkill(newSkillCfg.skillIndex)
		if id then
			skillId = id
		end
	end
	return skillId
end

function BtnSkillView.GetSamePosSkill(skillIndex)
	local cfg = GetCfgData("skill_CellNewSkillCfg")
	if (not cfg) or (not skillIndex) then return nil end
	for k, _ in pairs(BtnSkillView.SkillCdMap) do
		local newCfg = cfg:Get(k)
		if newCfg and newCfg.skillIndex == skillIndex then
			return k
		end
	end
	return nil
end

function BtnSkillView:__init(btnAttack, btnSkill01, btnSkill02, btnSkill03, btnSkill04)
	self.player = SceneController:GetInstance():GetScene():GetMainPlayer()
	self.normalSkillIdList = self.player.normalSkillIdList or {} 
	self.skillIDList = self.player.skillIDlist or {} 
	self.career = self.player.vo.career
	self.defaultSkill = nil
	self.studySkillId = nil
	self.mappingList = nil

	self:InitDefaultSkill()
	self:InitStudySkill()
	self:InitMappingSkill(btnAttack, btnSkill01, btnSkill02, btnSkill03, btnSkill04)

	self.slotSkillList = {}
	self:Init()
	self:AddEvents()

	RenderMgr.Add(function() self:Update() end, self)
end

function BtnSkillView:__delete()
	RenderMgr.Remove(self)
	self:RemoveEvents()

	self.player = nil
	self.normalSkillIdList = nil
	self.skillIDList = nil
	self.career = nil
	self.defaultSkill = nil
	self.studySkillId = nil
	self.mappingList = nil

	for key, value in pairs(self.slotSkillList) do 
		value:Destroy()
		self.slotSkillList[key] = nil
	end
	self.slotSkillList = nil
end

function BtnSkillView:Init()
	local btnSkill = nil
	for key, value in pairs(self.mappingList) do 
		btnSkill = self:MappingSkillBtn(value[1], value[2], value[3])
		self.slotSkillList[key] = btnSkill
	end
end

function BtnSkillView:Reset()
	for k, v in pairs(self.slotSkillList) do
		if not v.isLock then
			v:Reset()
		end
	end
end

function BtnSkillView:InitDefaultSkill()
	self.defaultSkill = {}
	local defaultSkillIds = GetCfgData( "newroleDefaultvalue" ):Get(self.career).initSkills
	for i=1, #defaultSkillIds do
		local skill = SkillManager.GetSkill(self.player, defaultSkillIds[i])
		if skill then
			self.defaultSkill[skill:GetSkillVo().skillIndex] = skill
		end
	end
end

function BtnSkillView:InitStudySkill()
	self.studySkillId = {}
	for i=1, #self.skillIDList do
		local skill = self.player.skillManager:GetSkillById(self.skillIDList[i])
		if skill then
			self.studySkillId[skill:GetSkillVo().skillIndex] = self.skillIDList[i]
		end
	end
end

function BtnSkillView:InitMappingSkill(btnAttack, btnSkill01, btnSkill02, btnSkill03, btnSkill04)
	self.mappingList = {} --self.mappingList[pos] = {skillBtn, 已学习技能id，默认技能id}
	self.mappingList[Slot.pos1] = {btnAttack, self.normalSkillIdList[1], self.defaultSkill[Slot.pos1]} --普攻
	self.mappingList[Slot.pos2] = {btnSkill01, self.studySkillId[Slot.pos2], self.defaultSkill[Slot.pos2]} --技能1
	self.mappingList[Slot.pos3] = {btnSkill02, self.studySkillId[Slot.pos3], self.defaultSkill[Slot.pos3]} --技能2
	self.mappingList[Slot.pos4] = {btnSkill03, self.studySkillId[Slot.pos4], self.defaultSkill[Slot.pos4]} --技能3
	self.mappingList[Slot.pos5] = {btnSkill04, self.studySkillId[Slot.pos5], self.defaultSkill[Slot.pos5]} --技能4
end

function BtnSkillView:GetDefaultSkillId(career, pos)
	return GetCfgData( "newroleDefaultvalue" ):Get(career).initSkills[pos]
end

function BtnSkillView:AddEvents()
	self.handler = GlobalDispatcher:AddEventListener(EventName.ResetSkillManagerComplete, function ( data )
		self:ResetSkillManagerCompleteHandler(data)
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.DizzyStateChange, function ( data )
		self:HandleDizzyState(data)
	end)
end

function BtnSkillView:RemoveEvents()
	GlobalDispatcher:RemoveEventListener(self.handler)
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

--技能学习或升级，更新对应的数据
function BtnSkillView:ResetSkillManagerCompleteHandler(data)
	local oldSkillId = data.oldSkillId
	local newSkillId = data.newSkillId

	local newSkill = self.player.skillManager:GetSkillById(newSkillId)
	local slot = newSkill:GetSkillVo().skillIndex

	if slot < 1 or slot > 5 then
		error("skillIndex 应在1-5之间，当前技能 【"..newSkill:GetSkillVo().un32SkillID.."】的索引为:"..slot)
	end

	local oldSkillBtnUI = self.slotSkillList[slot]
	if oldSkillBtnUI then
		oldSkillBtnUI:Destroy()
		oldSkillBtnUI = nil
	end

	self.slotSkillList[slot] = self:MappingSkillBtn(self.mappingList[slot][1], newSkillId, self.mappingList[slot][3])
	GlobalDispatcher:DispatchEvent(EventName.SkillBtnResetComplete)
end

function BtnSkillView:GetStudySkillBtn()
	local result = {}
	for k, v in pairs(self.slotSkillList) do
		if not v.isLock then
			table.insert(result, v)
		end
	end
	return result
end

function BtnSkillView:MappingSkillBtn(skillBtn, skillId, defaultSkill)
	local btnSkill = nil
	local skill = self.player.skillManager:GetSkillById(skillId)
	local isStudy = nil
	if skill then
		isStudy = true
	else
		isStudy = false
		skill = defaultSkill
	end

	local previewType = skill:GetSkillVo().previewType --施法表现
	if previewType == PreviewType.Nothing then 	--无 
		btnSkill = SkillBtnUI_Base.New(skillBtn, skill)

	elseif previewType == PreviewType.RangeSector360 then --圆  
		btnSkill = SkillBtnUI_360Range.New(skillBtn, skill)

	elseif previewType == PreviewType.RangeSector60 then--范围扇形60°  
		btnSkill = SkillBtnUI_60Range.New(skillBtn, skill)

	elseif previewType == PreviewType.RangeSector90 then--范围扇形90°  
		btnSkill = SkillBtnUI_90Range.New(skillBtn, skill)

	elseif previewType == PreviewType.RangeSector180 then--范围扇形180°  
		btnSkill = SkillBtnUI_180Range.New(skillBtn, skill)

	elseif previewType == PreviewType.GroundAttack then--地面施法  
		btnSkill = SkillBtnUI_GroundAttack.New(skillBtn, skill)

	elseif previewType == PreviewType.ArrowSmall then--箭头 
		btnSkill = SkillBtnUI_ArrowSmall.New(skillBtn, skill)

	elseif previewType == PreviewType.PointToRangeSector60 then--指向扇形60°  
		btnSkill = SkillBtnUI_PointToRangeSector60.New(skillBtn, skill)

	elseif previewType == PreviewType.PointToRangeSector90 then--指向扇形90°  
		btnSkill = SkillBtnUI_PointToRangeSector90.New(skillBtn, skill)

	elseif previewType == PreviewType.PointToRangeSector180 then--指向扇形180°  
		btnSkill = SkillBtnUI_PointToRangeSector180.New(skillBtn, skill)

	elseif previewType == PreviewType.PointToCenterSector90 then--指向扇形中心线单选(90°) 
		btnSkill = SkillBtnUI_PointToCenterSector90.New(skillBtn, skill)

	elseif previewType == PreviewType.ArrowBig then --宽箭头 
		btnSkill = SkillBtnUI_ArrowBig.New(skillBtn, skill)
	end

	if isStudy then
		btnSkill:UnLock()
	else
		btnSkill:Lock()
	end
	
	return btnSkill
end

--技能按键更新
function BtnSkillView:Update()
	for key, value in pairs(self.slotSkillList) do 
		value:_update()
	end
end

function BtnSkillView:HandleDizzyState(data)
	if self.slotSkillList then
		if data and data.isEnter then
			self:SetBtnsShow(self.slotSkillList, true)
		else
			self:SetBtnsShow(self.slotSkillList, false)
		end
	end
end

function BtnSkillView:SetBtnsShow(tab, isShow)
	for _, v in pairs(tab) do
		if v then
			v:ShowNewMask(isShow)
		end
	end
end