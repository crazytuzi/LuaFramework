SkillManager = {};
 
-- SkillManager.refTable = {};   --映射表

--技能配置参见
--PlayerInfo:InitSkillSet

function SkillManager.GetTalentCfg(id)
    local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TALENT_MAIN)
    return config[id];
end

function SkillManager.GetTalentDetailCfg(id,level)
    local index = id .. "_" .. level
    local config = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TALENT)
    return config[index];
end

-- function SkillManager.InitTalent(data)
--     SkillManager.talent.point = data.talent;
--     SkillManager.talent.idx = data.idx;
--     SkillManager.talent.t1 = {};
--     SkillManager.talent.t2 = {};
--     for i = 1, 4 do
--         local tmp1 = data.conf1[i] or {0,0};
--         local tmp2 = data.conf2[i] or {0,0};
--         SkillManager.talent.t1[i] = {id = tmp1[1], lv = tmp1[2]};
--         SkillManager.talent.t2[i] = {id = tmp2[1], lv = tmp2[2]};
--     end

--     for i = 1, 4 do 
--         SkillManager.talent.t1[i] = {id = 0, lv = 0};
--         SkillManager.talent.t2[i] = {id = 0, lv = 0};
--     end

--     --后端不返回顺序, 前端自己查表 查某个天赋应该放在哪个位置里.
--     local tmpIdx = 0;
--     for i,v in ipairs(data.conf1) do
--         tmpIdx = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TALENT_MAIN)[v.id].phase;
--         SkillManager.talent.t1[tmpIdx].id = v.id;
--         SkillManager.talent.t1[tmpIdx].lv = v.num;
--     end

--     for i,v in ipairs(data.conf2) do
--         tmpIdx = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TALENT_MAIN)[v.id].phase;
--         SkillManager.talent.t2[tmpIdx].id = v.id;
--         SkillManager.talent.t2[tmpIdx].lv = v.num;
--     end

--     SkillManager.BuildSkillIdRef();
-- end

function SkillManager.UpdateTalent(idx, ids, lvs)
    -- local d = idx == 1 and SkillManager.talent.t1 or SkillManager.talent.t2;

    -- for i = 1,4 do
    --     d[i].id = ids[i];
    --     d[i].lv = lvs[i];
    -- end

    -- SkillManager.BuildSkillIdRef();
end

function SkillManager.UpdateTalentIndex(idx)
    -- SkillManager.talent.idx = idx;
    -- SkillManager.BuildSkillIdRef();
end

function SkillManager.UpdateTalentPoint(p)
    -- SkillManager.talent.point = p;
    -- MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_TALENT_UPDATE);
end

function SkillManager.GetEmptyTalentData()
    local d = {};
    for i = 1, 4 do
        d[i] = {id = 0, lv = 0};
    end
    return d;
end

function SkillManager.GetEmptyTalentPoint()
    -- return SkillManager.talent.point;
end

function SkillManager.GetIdx()
    -- return SkillManager.talent.idx;
end

function SkillManager.GetIdxPoint(idx)
    -- local num = 0;
    -- local d = SkillManager.GetTalentData(idx);
    -- for i = 1, 4 do
    --     num = num + d[i].lv;
    -- end 
    -- return SkillManager.talent.point - num;
end

function SkillManager.GetTalentData(idx)
    -- local t = idx == 1 and SkillManager.talent.t1 or SkillManager.talent.t2;
    -- return t;
end

function SkillManager.GetTalentIds(kind, idx)
    -- local careerCfg = ConfigManager.GetCareerByKind(kind);
    -- return careerCfg["talent"..idx];
end

function SkillManager.GetTalentDesc(cfg)
    -- local param = {
    --         a = cfg.a;
    --         b = cfg.b;
    --         c = cfg.c;
    --         d = cfg.d;
    --         e = cfg.e;
    --         f = cfg.f;
    --     };
    -- return LanguageMgr.ApplyFormat(cfg.descLabel, param, true);
end

function SkillManager.GetSkillRec(id)
    local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILL_RECOMMEND)[id];
end

--获取天赋推荐.
function SkillManager.GetTalentCommend(id)
    -- local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILL_RECOMMEND)[id];
    -- local myinfo = PlayerManager.GetPlayerInfo();
    -- local careerCfg = ConfigManager.GetCareerByKind(myinfo.kind);
    -- local data = {};
    -- local allPoint = SkillManager.GetEmptyTalentPoint();
    -- for i=1,4 do
    --     local tmpId = myinfo.level >= careerCfg.talentLv[i] and cfg.skill[i] or 0;
    --     data[i] = {id = tmpId, lv = 0};
    -- end
    
    -- for i,v in ipairs(cfg.talentIdx) do
    --     if data[v].id > 0 and allPoint > 0 then
    --         local tmpPoint = cfg.talentVal[i];
    --         if allPoint >= tmpPoint then
    --             data[v].lv = tmpPoint;
    --             allPoint = allPoint - tmpPoint;
    --         else
    --             data[v].lv = allPoint;
    --             allPoint = 0;
    --         end
    --     end
    -- end
     
    -- return {
    --     p = allPoint;
    --     d = data;
    -- }
end

--天赋系统的技能映射
function SkillManager.BuildSkillIdRef()
    -- SkillManager.refTable = {};
    -- local data = SkillManager.GetTalentData(SkillManager.talent.idx);
    -- for i = 1,4 do
    --     local tId = data[i].id;
        
    --     if tId > 0 then
    --         local tmpId = tId.."_"..data[i].lv;
    --         local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_TALENT)[tmpId];
    --         if cfg and cfg.result_type == 3 then
    --             --如果天赋是技能映射.则保存到映射表. 技能a -> b
    --             local p = cfg.result_para;
    --             local a = tonumber(p[1]);
    --             local b = tonumber(p[2]);
    --             SkillManager.refTable[a] = b;
    --         end    
    --     end
    -- end

end

--根据天赋系统映射新的技能id
--==============================--
--desc:hdl 去除天赋系统后没有技能映射
--time:2017-08-15 08:28:08
--@skillId:
--@return 
--==============================--
function SkillManager.RefSkillId(skillId)
    -- local refId = skillId;
    return skillId
    -- return SkillManager.refTable[refId] or refId;
end

-- 初始化技能
function SkillManager.InitSkills( sks)
    local heroInfo = PlayerManager.GetPlayerInfo();
    for i, v in ipairs(sks) do
        --local rskillid = SkillManager.RefSkillId(data.skill_id);
        heroInfo:SetSkillLevel(v.skill_id, v.level);
        --[[
        if (rskillid~= data.skill_id) then
            local sk = heroInfo:GetSkill(rskillid);
            if (sk) then
                sk:SetLevel(data.level)
            end
        end
        ]]
    end
end


--根据天赋系统映射新的技能id获取源技能id
--==============================--
--desc:hdl 关闭天赋系统后无需技能映射
--time:2017-08-15 08:29:23
--@refSkillId:
--@return 
--==============================--
function SkillManager.InverseRefSkillId(refSkillId)
    -- for i,v in pairs(SkillManager.refTable) do
    --     if (v == refSkillId) then return i end;
    -- end
    return refSkillId
end

function SkillManager.GetTalentAllAttrs()
    -- local attrs = {};--BaseAdvanceAttrInfo:New()
    -- local td = SkillManager.GetTalentData(SkillManager.GetIdx());
    -- local cfg = nil;
    -- local val = nil;
    -- local att_k = nil;
    -- local att_v = nil;
    -- for i,v in ipairs(td) do
    --     if v.id > 0 then
    --         local cfg = SkillManager.GetTalentDetailCfg(v.id, v.lv);
    --         if cfg.result_type == 1 then
    --             for n, m in ipairs(cfg.result_para) do
    --                 val = string.split(m, "|");
    --                 att_k = val[1];
    --                 att_v = tonumber(val[2]);
    --                 if attrs[att_k] == nil then
    --                     attrs[att_k] = 0;
    --                 end
    --                 attrs[att_k] = attrs[att_k] + att_v;
    --             end
    --         end
    --     end
    -- end
    -- return attrs;
end


function SkillManager.GetRedPoint()
    return SkillManager.GetUpgradeRedPoint() or SkillManager.GetSettingRedPoint() ;
end

--检查技能升级红点
function SkillManager.GetUpgradeRedPoint()
    local heroInfo = PlayerManager.GetPlayerInfo();
    local skills = heroInfo:GetSkills();
    local myLv = heroInfo.level;
    local myVp = MoneyDataManager.Get_money();
    for i,v in ipairs(skills) do
        if v.skill_lv < v.max_lv and v.req_lv <= myLv and v.coin_cost <= myVp then
            return true;
        end
    end
    return false;
end

--技能设置红点
function SkillManager.GetSettingRedPoint()
    local heroInfo = PlayerManager.GetPlayerInfo();

    local v = nil;
    for i = 1, 4 do
        
        if heroInfo.level >= heroInfo.skillslot_open[i] then
            v = heroInfo.skillSet1[i];
            if v == nil then 
                return true;
            end
            v = heroInfo.skillSet2[i];
            if v == nil then 
                return true;
            end
        end
        
    end

    return false;
end

 

--等级变化时检查技能配置, 自动设置技能
function SkillManager.CheckSkillByLevel(oldLevel)
    local playerInfo = PlayerManager.hero.info;
    local level = playerInfo.level;

    --local careerCfg = ConfigManager.GetCareerByKind(PlayerManager.GetPlayerKind());
    local defSkill = playerInfo.default_skill;
    local defSkillReqLv = playerInfo.skillslot_open;

    local chgIndex = 0;
    for i, v in ipairs(defSkillReqLv) do
        if oldLevel < v and level >= v then
            chgIndex = i;
            MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_SKILL_SLOT_OPEN, i);
        end
    end

    if chgIndex > 0 then
        Engine.instance:DoAfter(1, function() 
            local skillSet = playerInfo:GetSkillSet();
            local set = string.split(skillSet, "_");
            set[chgIndex+1] = defSkill[chgIndex];
            set[chgIndex+7] = defSkill[chgIndex];
            skillSet = table.concat(set, "_");

            SkillProxy.ReqSaveSkillSet(skillSet);
        end);
    end

end

function SkillManager.GetSkillPower()
    local val = 0;
    local heroInfo = PlayerManager.hero.info;
    local skills = heroInfo:GetSkills();
    for i, v in ipairs(skills) do
        if v.skill_lv > 1 or heroInfo.level >= v.req_lv then
            val = val + v.zdl_value;
        end
    end
    return val;
end

function SkillManager.GetTalentPower()
    -- local td = SkillManager.GetTalentData(SkillManager.GetIdx());
    -- local cfg = nil;
    -- local val = 0;
    -- for i,v in ipairs(td) do
    --     if v.id > 0 then
    --         local cfg = SkillManager.GetTalentDetailCfg(v.id, v.lv);
    --         val = val + cfg.zdl_value;
    --     end
    -- end
    -- return val;
end


local skillCfg
function SkillManager:GetSkillById(id, lev)
    if not skillCfg then
        skillCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_SKILL)
    end
    if not lev then lev = '1' end
    return skillCfg[id .. "_" .. lev]
end


