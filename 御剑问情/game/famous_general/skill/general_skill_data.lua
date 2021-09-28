GeneralSkillData = GeneralSkillData or BaseClass()

function GeneralSkillData:__init()
	GeneralSkillData.Instance = self

	self:InitData()
end

function GeneralSkillData:__delete()
	GeneralSkillData.Instance = nil
end



-----------------------------初始化数据----------------------
function GeneralSkillData:InitData()
	-- 变身技能数据
	self.change_skill_data = {}
	self.change_skill_data.cur_used_seq = -1
	self.change_skill_data.bianshen_end_timestamp = 0
	self.change_skill_data.bianshen_cd = 0
	self.change_skill_data.bianshen_cd_reduce_s = 0
	self.change_skill_data.main_slot_seq = -1
end

----------------------------存储数据------------------------
function GeneralSkillData:SetGreateSoldierOtherInfo(protocol)
	local delay_set_anim = false
	if self.init then
		if self.change_skill_data.main_slot_seq ~= protocol.main_slot_seq then
			delay_set_anim = true
		end
	end
	self.change_skill_data.cur_used_seq = protocol.cur_used_seq
	self.change_skill_data.bianshen_end_timestamp = protocol.bianshen_end_timestamp
	self.change_skill_data.bianshen_cd = protocol.bianshen_cd
	self.change_skill_data.bianshen_cd_reduce_s = protocol.bianshen_cd_reduce_s
	self.change_skill_data.main_slot_seq = protocol.main_slot_seq
	self.init = true
	if delay_set_anim then
		FamousGeneralCtrl.Instance:SetGeneralAnim()
	end
end

----------------------------判断数据-----------------------------
function GeneralSkillData:CheckShowSkill()
	if self.change_skill_data.main_slot_seq ~= -1 then 
		return true
	else
		return false
	end
end

function GeneralSkillData:CheckIsGeneralSkill(skill_id)
	
end

----------------------------获取数据-----------------------------

function GeneralSkillData:GetCurUseSeq()
	return self.change_skill_data.cur_used_seq
end

function GeneralSkillData:GetBianShenCds()
	return self.change_skill_data.bianshen_cd / 1000
end

function GeneralSkillData:GetBianShenTime()
	local now_time = TimeCtrl.Instance:GetServerTime()
	local cd_s = (self.change_skill_data.bianshen_end_timestamp - now_time)
	return cd_s
end

function GeneralSkillData:GetMainSlot()
	return self.change_skill_data.main_slot_seq
end

function GeneralSkillData:IsFightOut(seq)
	local def_value = false
	if seq == nil then
		return def_value
	end
	
	if self.change_skill_data.main_slot_seq == seq then
		return true
	else
		return false
	end
end