require "Core.Module.Pattern.Proxy"

SkillProxy = Proxy:New();
local insert = table.insert

function SkillProxy:OnRegister()
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SkillUp, SkillProxy._RspUpgrade);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SkillSetting, SkillProxy._RspSaveSkillSet);
    -- SocketClientLua.Get_ins():AddDataPacketListener(CmdType.TalentPointChg, SkillProxy._RspTalentPointChg);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ActiveTalent, SkillProxy._RspActiveTalent);
    SocketClientLua.Get_ins():AddDataPacketListener(CmdType.SkillTalent, SkillProxy._RspSaveTalent);
end

function SkillProxy:OnRemove()
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SkillUp, SkillProxy._RspUpgrade);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SkillSetting, SkillProxy._RspSaveSkillSet);
    -- SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.TalentPointChg, SkillProxy._RspTalentPointChg);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ActiveTalent, SkillProxy._RspActiveTalent);
    SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.SkillTalent, SkillProxy._RspSaveTalent);
end

function SkillProxy.ReqUpgrade(id)
    SocketClientLua.Get_ins():SendMessage(CmdType.SkillUp, { skill_id = id });
end

function SkillProxy._RspUpgrade(cmd, data)
    if (data == nil or data.errCode ~= nil) then
        return;
    end
    local heroInfo = PlayerManager.GetPlayerInfo();
    local rskillid = SkillManager.RefSkillId(data.skill_id);
    heroInfo:SetSkillLevel(data.skill_id, data.level);
    if (rskillid~= data.skill_id) then
        local sk = heroInfo:GetSkill(rskillid);
        if (sk) then
            sk:SetLevel(data.level)
        end
    end
    -- 升级重新计算战斗力
    PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.SkillPower);

    MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_UPGRADE);

    UISoundManager.PlayUISound(UISoundManager.skill_upgrade);
end


function SkillProxy.ReqSaveSkillSet(set)
    SkillProxy.tmpSet = set;
    SocketClientLua.Get_ins():SendMessage(CmdType.SkillSetting, { skill_set = set });
end

function SkillProxy._RspSaveSkillSet(cmd, data)
    if (data == nil or data.errCode ~= nil) then
        return;
    end

    UISoundManager.PlayUISound(UISoundManager.skill_setting);

    if PlayerManager.hero then
        PlayerManager.GetPlayerInfo():InitSkillSet(SkillProxy.tmpSet);
    end
    MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_SKILL_CHG);
end

function SkillProxy.ReqActiveTalent(id)
    SkillProxy.tmpTalentIdx = id;
    SocketClientLua.Get_ins():SendMessage(CmdType.ActiveTalent, { idx = id });
end

function SkillProxy._RspActiveTalent(cmd, data)
    -- if (data == nil or data.errCode ~= nil) then
    --     return;
    -- end
    -- SkillManager.UpdateTalentIndex(SkillProxy.tmpTalentIdx);
    -- if PlayerManager.hero then
    --     PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Talent);  
    -- end
    -- MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_TALENT_CHG);
    -- MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_SKILL_CHG);
end

function SkillProxy.ReqSaveTalent(idx, data)
    -- local ids = { };
    -- local nums = { };
    -- for i = 1, 4 do
    --     insert(ids, data[i].id);
    --     insert(nums, data[i].lv);
    -- end
    -- SkillProxy.tmpIdx = idx;
    -- SkillProxy.tmpIds = ids;
    -- SkillProxy.tmpLvs = nums;

    -- -- 后端不保存顺序, 要前端自己把顺序去掉.
    -- local toIds = { };
    -- local toNums = { };
    -- for i = 1, 4 do
    --     if ids[i] > 0 then
    --         insert(toIds, ids[i]);
    --         insert(toNums, nums[i]);
    --     end
    -- end

    -- SocketClientLua.Get_ins():SendMessage(CmdType.SkillTalent, { idx = idx, ids = toIds, nums = toNums });
end

function SkillProxy._RspSaveTalent(cmd, data)
    if (data == nil or data.errCode ~= nil) then
        return;
    end
    -- SkillManager.UpdateTalent(SkillProxy.tmpIdx, SkillProxy.tmpIds, SkillProxy.tmpLvs);
    -- MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_TALENT_CHG);
    -- MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_SKILL_CHG);
    -- if PlayerManager.hero then
    --     PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Talent);
    -- end

    -- MsgUtils.ShowTips("skill/talent/save");
end

function SkillProxy._RspTalentPointChg(cmd, data)
    -- SkillManager.UpdateTalentPoint(data.talent);
end