local SkillData = classGc(function( self )
    self.skill_study_list       = {}      --已经学习的技能信息    skill_id, skill_lv
    self.skill_equip_list       = {}     --装备技能信息 equip_pos, skill_id, skill_lv
end)

function SkillData.addEquipSkillData(self,singleSkillData)
    print("SkillData.addEquipSkillData ")

    if singleSkillData==nil then return end

    for k,v in pairs(singleSkillData) do
        print(k,v)
    end

    if singleSkillData.equip_pos<1 or singleSkillData.equip_pos>5 then
        CCLOG("ERROR SkillData.setEquipSkillIdByIndex  _equip_pos=%d",singleSkillData.equip_pos)
        return
    end

    self.skill_equip_list[singleSkillData.equip_pos]=singleSkillData

    -- if singleSkillData.equip_pos<2 then
    --     singleSkillData.equip_pos=1
    --     self.skill_equip_list[1]=singleSkillData

    -- elseif singleSkillData.equip_pos>1 and singleSkillData.equip_pos<3 then
    --     singleSkillData.equip_pos=2
    --     self.skill_equip_list[2]=singleSkillData

    -- elseif singleSkillData.equip_pos>2 and singleSkillData.equip_pos<4 then
    --     singleSkillData.equip_pos=3
    --     self.skill_equip_list[3]=singleSkillData

    -- else
    --     singleSkillData.equip_pos=4
    --     self.skill_equip_list[4]=singleSkillData
    -- end
end

function SkillData.getSkillLvFromEquBySkillID( self, _skillID )
    if self.skill_equip_list == nil then
        return
    end

    for k,singleSkillData in pairs(self.skill_equip_list) do
        if singleSkillData.skill_id==_skillID then
            return singleSkillData
        end
    end
end

function SkillData.getSkillLvBySkillID( self, _skillID )
    if self.skill_study_list == nil then
        return
    end
    return self.skill_study_list[_skillID]
end

return SkillData