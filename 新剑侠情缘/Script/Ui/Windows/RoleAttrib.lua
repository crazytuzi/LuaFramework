
local tbUi = Ui:CreateClass("RoleAttrib");

local tbAddStateStoneId = {
    [10912] = {56,0};
    [10946] = {0,56};
    [10913] = {80,0};
    [10947] = {0,80};
    [10914] = {112,0};
    [10948] = {0,112};
}
local function GetSpecialStateInfo()
    local nAttackRate = 0
    local nAttackTime = 0
    local tbPos = {Item.EQUIPPOS_BELT, Item.EQUIPPOS_CUFF}
    for _, nPos in ipairs(tbPos) do
        local tbInsetInfo = me.GetInsetInfo(nPos)
        for _, nStoneId in ipairs(tbInsetInfo) do
            local tbAddState = tbAddStateStoneId[nStoneId]
            if tbAddState then
                nAttackRate = nAttackRate + tbAddState[1]
                nAttackTime = nAttackTime + tbAddState[2]
            end
        end
    end
    return nAttackRate, nAttackTime
end

local function _CalcWuXingZhuangTai(nX)
    return nX /(nX + 250)
end

local function _CalcKangXing(nX)
    return nX /(nX + me.nLevel * 5 + 6)
end

local function _GetAllSeriesstateRate()
    local pNpc = me.GetNpc();
    return pNpc.GetAttribValue("add_seriesstate_rate_v", 0);
end

local function _GetAllSeriesstateTime()
    local pNpc = me.GetNpc();
    return pNpc.GetAttribValue("add_seriesstate_time_v", 0);
end

local function _Getignore_all_resist()
    local pNpc = me.GetNpc();
    return pNpc.GetAttribValue("ignore_all_resist", 0), pNpc.GetAttribValue("ignore_all_resist", 1);
end

local function _Getignore_all_resist_v()
     local pNpc = me.GetNpc();
     return pNpc.GetAttribValue("ignore_all_resist_v", 0), pNpc.GetAttribValue("ignore_all_resist_v", 1);
end

local function _Getignore_all_resist_vp()
     local pNpc = me.GetNpc();
     return pNpc.GetAttribValue("ignore_all_resist_vp", 0), pNpc.GetAttribValue("ignore_all_resist_vp", 1);
end

local tbAllArribute = {
    {
        {
            szName = "门派", 
            func = function ()
                return Faction:GetName(me.nFaction);
            end,
        };     
        {
            szName = "五行", 
            func = function ()
                local tbPlayerInfo = KPlayer.GetPlayerInitInfo(me.nFaction, me.nSex);
                return Npc.Series[tbPlayerInfo.nSeries] ;
            end,
        };     
        {
            szName = "恶名值", 
            func = function ()
                return PKValue:GetPKValue(me);
            end,
            fnDesc = function ()
                return "每屠杀一名和平玩家增加[00ff00]1[-]点，每被击成重伤减少[00ff00]1[-]点。恶名值越高，被击成重伤时掉的经验越多"
            end,
        }; 
    };

    {
        {
            szName = "生命", 
            func = function ()
                return me.GetNpc().nMaxLife
            end,
            fnDesc = function ()
                return "生命总值"
            end,
        };  
        {
            szName = "攻击力", 
            func = function ()
                local nMin, nMax = me.GetBaseDamage()
                return math.max(nMin, 1)
            end,
            fnDesc = function ()
                return "攻击力总值"
            end,
        };
        {
            szName = "最终伤害抵消", 
            func = function ()
                local pNpc = me.GetNpc();
                return math.floor(pNpc.GetAttribValue("reduce_final_damage_p", 0)) .. "%"
            end,
            fnDesc = function ()
                local pNpc = me.GetNpc();
                local nVal = math.floor(pNpc.GetAttribValue("reduce_final_damage_p", 0))
                return string.format("受到的伤害除%d%%", 100+nVal)
            end,
        };
        {
            szName = "最终伤害放大", 
            func = function ()
                local pNpc = me.GetNpc();
                return math.floor(pNpc.GetAttribValue("enhance_final_damage_p", 0)) .. "%"
            end,
            fnDesc = function ()
                return "最终伤害放大百分比"
            end,
        };
    };

    {
        {
            szName = "体质", 
            func = function ()
                return me.nVitality
            end,
            fnDesc = function ()
                return "每[00ff00]1[-]点体质，增加[00ff00]20[-]点基础生命上限"
            end,
        };
        {
            szName = "敏捷", 
            func = function ()
                return me.nDexterity
            end,
            fnDesc = function ()
                return "每[00ff00]1[-]点敏捷，增加[00ff00]1[-]点基础闪避\n每[00ff00]4[-]点敏捷，增加[00ff00]1[-]点基础全系抗性"
            end,
        };
        {
            szName = "力量", 
            func = function ()
                return me.nStrength
            end,
            fnDesc = function ()
                return "每[00ff00]1[-]点力量，增加[00ff00]1[-]点基础攻击力"
            end,
        };
        {
            szName = "灵巧", 
            func = function ()
                return me.nEnergy
            end,
            fnDesc = function ()
                return "每[00ff00]1[-]点灵巧，增加[00ff00]2[-]点基础命中\n每[00ff00]2[-]点灵巧，增加[00ff00]1[-]点基础会心几率"
            end,
        };
    };

    {
        {
            szName = "体质成长", 
            func = function ()
                local tbData = me.GetNextLevelFactionPotency()
                return tbData and tbData.nVitality
            end,
            fnDesc = function ()
                return "角色每升[00ff00]1[-]级增加的体质点数"
            end,
        };
       {
            szName = "敏捷成长", 
            func = function ()
                local tbData = me.GetNextLevelFactionPotency()
                return tbData and tbData.nDexterity
            end,
            fnDesc = function ()
                return "角色每升[00ff00]1[-]级增加的敏捷点数"
            end,
        }; 
        {
            szName = "力量成长", 
            func = function ()
                local tbData = me.GetNextLevelFactionPotency()
                return tbData and tbData.nStrength
            end,
            fnDesc = function ()
                return "角色每升[00ff00]1[-]级增加的力量点数"
            end,
        };
        {
            szName = "灵巧成长", 
            func = function ()
                local tbData = me.GetNextLevelFactionPotency()
                return tbData and tbData.nEnergy
            end,
            fnDesc = function ()
                return "角色每升[00ff00]1[-]级增加的灵巧点数"
            end,
        };
 
    };

    {
        {
            szName = "金系抗性", 
            func = function () 
                local nVal = me.nMetalR
                nVal = nVal < 0 and 0 or nVal
                return nVal -- _CalcKangXing(me.nGR) * 100)
            end,
            fnDesc = function ()
                local nVal = me.nMetalR
                nVal = nVal < 0 and 0 or nVal
                return string.format("减少受到金系伤害：[00ff00]%.2f%%[-]", 1 * nVal / (nVal + 20 * me.nLevel + 10) * 100 )   
            end,
        };  
        {
            szName = "木系抗性", 
            func = function ()
                local nVal = me.nWindR
                nVal = nVal < 0 and 0 or nVal
                return nVal
            end,
            fnDesc = function ()
                local nVal = me.nWindR
                nVal = nVal < 0 and 0 or nVal
                return string.format("减少受到木系伤害：[00ff00]%.2f%%[-]", 1 * nVal / (nVal + 20 * me.nLevel + 10) * 100 )   
            end,
        };  
        {
            szName = "水系抗性", 
            func = function ()
                local nVal = me.nWaterR
                nVal = nVal < 0 and 0 or nVal
                return nVal
            end,
            fnDesc = function ()
                local nVal = me.nWaterR
                nVal = nVal < 0 and 0 or nVal
                return string.format("减少受到水系伤害：[00ff00]%.2f%%[-]", 1 * nVal / (nVal + 20 * me.nLevel + 10) * 100 )   
            end,
        };
        {
            szName = "火系抗性", 
            func = function ()
                local nVal = me.nFireR
                nVal = nVal < 0 and 0 or nVal
                return nVal
            end,
            fnDesc = function ()
                local nVal = me.nFireR
                nVal = nVal < 0 and 0 or nVal
                return string.format("减少受到火系伤害：[00ff00]%.2f%%[-]", 1 * nVal / (nVal + 20 * me.nLevel + 10) * 100 )   
            end,
        };   
        {
            szName = "土系抗性", 
            func = function ()
                local nVal = me.nEarthR
                nVal = nVal < 0 and 0 or nVal
                return nVal
            end,
            fnDesc = function ()
                local nVal = me.nEarthR
                nVal = nVal < 0 and 0 or nVal
                return string.format("减少受到土系伤害：[00ff00]%.2f%%[-]", 1 * nVal / (nVal + 20 * me.nLevel + 10) * 100 )   
            end,
        };      
        {
           szName = "", 
            func = function ()
                return ""
            end,
        };
        {
            szName = "忽略全抗", 
            func = function () 
                local _,nVal = _Getignore_all_resist_v()
                return nVal
            end,
            fnDesc = function ()
                return "无视敌人的基础全系抗性点数"
            end,
        };    
       {
            szName = "忽略基础全抗", 
            func = function () 
                local nVal = _Getignore_all_resist_vp()
                return nVal .. "%"
            end,
            fnDesc = function ()
                return "无视敌人的基础全系抗性百分比加成"
            end,
        };    
    };
    
    {
        {
            szName = "命中", 
            func = function ()
            --nAttackRate/(nAttackRate+ me.nLevel * 1.5+10) * 100 逍遥的做法。
                return me.nHitRate
            end,
            fnDesc = function ()
                return string.format("命中几率：[00ff00]%.2f%%[-]",  me.nHitRate / (me.nHitRate + 2 * me.nLevel + 10) * 100 ) 
            end,
        };
        {
            szName = "闪避", 
            func = function ()
                return math.max(me.nMiss, 0)
            end,
            fnDesc = function ()
                local nMiss = math.max(me.nMiss, 0)
                return string.format("闪避几率：[00ff00]%.2f%%[-]", nMiss / (nMiss + 75 * me.nLevel + 1500) * 100)
            end,
        };    
        {
            szName = "忽略闪避", 
            func = function ()
                return math.floor(me.nIgnoreDefense) 
            end,
            fnDesc = function ()
                return "降低目标闪避值"
            end,
        };
        {
            szName = "忽略基础闪避", 
            func = function ()
                local pNpc = me.GetNpc();
                return math.floor(pNpc.GetAttribValue("ignore_defense_vp", 0)) .. "%"
            end,
            fnDesc = function ()
                return "无视敌人的基础闪避百分比加成"
            end,
        };
    };

    {
        {
            szName = "会心几率", 
            func = function ()
            --string.format("%0.2f%%", nDS / (nDS + me.nLevel*18+250) * 100)
                return me.nDeadlyStrike
            end,
            fnDesc = function ()
                return string.format("造成会心的几率：[00ff00]%.2f%%[-]",  0.8 * me.nDeadlyStrike / (me.nDeadlyStrike + 10 * me.nLevel + 1500) * 100 ) 
            end,
        };
        {
            szName = "会心伤害", 
            func = function ()
                return string.format("%d%%", me.nDeadlyStrikeDamagePercent + 180 )
            end,
            fnDesc = function ()
                return "会心时造成的伤害倍数"
            end,
        };
        {
            szName = "抗会心几率", 
            func = function ()
                return me.nWeakenDS
            end,
            fnDesc = function ()
                return "受到攻击时，降低触发会心一击的概率"
            end,
        };
        {
            szName = "会心免伤", 
            func = function ()
                return me.nDSDefense.."%"
            end,
            fnDesc = function ()
                return "减少受到的会心伤害"
            end,
        };    
        {
            szName = "忽略基础会心", 
            func = function ()
                local pNpc = me.GetNpc();
                return math.floor(pNpc.GetAttribValue("ignore_deadlystrike_vp", 0)).. "%"
            end,
            fnDesc = function ()
                return "无视敌人的基础会心百分比加成"
            end,
        };
    };
    
    {
        {
            szName = "生命回复", 
            func = function ()
                return me.nLifeRecoverTotal
            end,
            fnDesc = function ()
                return "每隔5秒，回复的生命点数"
            end,
        };    
        {
            szName = "吸取生命", 
            func = function ()
                return me.GetNpc().nStealLifeRate .. "%"
            end,
            fnDesc = function ()
                return "造成伤害转换成生命回复"
            end,
        };   
        {
            szName = "", 
            func = function ()
                return ""
            end,
        };    
        {
            szName = "吸血抗性", 
            func = function ()
                return me.GetNpc().GetAttribValue("steallife_resist_p", 0) .. "%"
            end,
            fnDesc = function ()
                return "减少被吸取生命值的比例"
            end,
        };   
    };
    {
        {
            szName = "攻击速度", 
            func = function ()
                return me.GetNpc().nAttackSpeed
            end,
            fnDesc = function ()
                return "攻击速度"
            end,
        };    
        {
            szName = "移动速度", 
            func = function ()
                return me.GetNpc().nShowRunSpeed
            end,
            fnDesc = function ()
                return "每10点移动速度发生变化" 
            end,
        };    
    };

    {
        {
            szName = "反弹近程伤害", 
            func = function ()
                return me.GetNpc().GetAttribValue("meleedamagereturn_p", 0) .. "%"
            end,
            fnDesc = function ()
                return "反弹近程伤害百分比"
            end,
        };
        {
            szName = "反弹近程伤害", 
            func = function ()
                return me.GetNpc().GetAttribValue("meleedamagereturn_v", 0)
            end,
            fnDesc = function ()
                return "反弹近程伤害点数"
            end,
        };
        {
            szName = "反弹远程伤害", 
            func = function ()
                return me.GetNpc().GetAttribValue("rangedamagereturn_p", 0) .. "%"
            end,
            fnDesc = function ()
                return "反弹远程伤害百分比"
            end,
        };
        {
            szName = "反弹远程伤害", 
            func = function ()
                return me.GetNpc().GetAttribValue("rangedamagereturn_v", 0)
            end,
            fnDesc = function ()
                return "反弹远程伤害点数"
            end,
        };
        {
            szName = "反弹免伤", 
            func = function ()
                return me.GetNpc().GetAttribValue("return_resist_p", 0) .. "%"
            end,
            fnDesc = function ()
                return "减少被反弹伤害的比例"
            end,
        };

    };
    {
        {
            szName = "受伤几率", 
            func = function ()
                local pNpc = me.GetNpc();
                local nAttackRate = pNpc.GetState(Npc.STATE.HURT).nAttackRate;
                nAttackRate = nAttackRate + _GetAllSeriesstateRate();
                return nAttackRate;
            end,
            fnDesc = function ()
                local pNpc = me.GetNpc();
                local nAttackRate = pNpc.GetState(Npc.STATE.HURT).nAttackRate;
                nAttackRate = nAttackRate + _GetAllSeriesstateRate();
                return string.format("增加造成受伤几率：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(nAttackRate) * 100 ) 
            end,
        };
        {
            szName = "抗受伤几率", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.HURT).nResistRate
            end,
            fnDesc = function ()
                return string.format("减少受到受伤几率：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.HURT).nResistRate) * 100) 
            end,
        };        
        {
            szName = "眩晕几率", 
            func = function ()
                local pNpc = me.GetNpc();
                local nAttackRate = pNpc.GetState(Npc.STATE.STUN).nAttackRate;
                nAttackRate = nAttackRate + _GetAllSeriesstateRate();
                return nAttackRate
                -- return string.format("%0.2f%%", _CalcWuXingZhuangTai(pNpc.GetState(Npc.STATE.STUN).nAttackRate) * 100) 
            end,
            fnDesc = function ()
                local pNpc = me.GetNpc();
                local nAttackRate = pNpc.GetState(Npc.STATE.STUN).nAttackRate;
                nAttackRate = nAttackRate + _GetAllSeriesstateRate();
                return string.format("增加造成眩晕几率：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(nAttackRate) * 100 ) 
            end,
        };
        {
            szName = "抗眩晕几率", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.STUN).nResistRate
                -- return string.format("%0.2f%%", _CalcWuXingZhuangTai(pNpc.GetState(Npc.STATE.STUN).nResistRate) * 100)
            end,
            fnDesc = function ()
                return string.format("减少受到眩晕几率：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.STUN).nResistRate) * 100) 
            end,
        };
        {
            szName = "迟缓几率", 
            func = function ()
                local pNpc = me.GetNpc();
                local nAttackRate = pNpc.GetState(Npc.STATE.SLOWALL).nAttackRate;
                nAttackRate = nAttackRate + _GetAllSeriesstateRate();
                return nAttackRate
                -- return string.format("%0.2f%%", _CalcWuXingZhuangTai(pNpc.GetState(Npc.STATE.SLOWALL).nAttackRate) * 100)
            end,
            fnDesc = function ()
                local pNpc = me.GetNpc();
                local nAttackRate = pNpc.GetState(Npc.STATE.SLOWALL).nAttackRate;
                nAttackRate = nAttackRate + _GetAllSeriesstateRate();
                return string.format("增加造成迟缓几率：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(nAttackRate) * 100) 
            end,
        };
        {
            szName = "抗迟缓几率", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.SLOWALL).nResistRate
                -- return string.format("%0.2f%%", _CalcWuXingZhuangTai(pNpc.GetState(Npc.STATE.SLOWALL).nResistRate) * 100)
            end,
            fnDesc = function ()
                return string.format("减少受到迟缓几率：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.SLOWALL).nResistRate) * 100) 
            end,
        };

        {
            szName = "致缠几率", 
            func = function ()
                local pNpc = me.GetNpc();
                local nAttackRate = pNpc.GetState(Npc.STATE.ZHICAN).nAttackRate;
                nAttackRate = nAttackRate + _GetAllSeriesstateRate();
                return nAttackRate
                -- return string.format("%0.2f%%",_CalcWuXingZhuangTai(pNpc.GetState(Npc.STATE.ZHICAN).nAttackRate) * 100)
            end,
            fnDesc = function ()
                local pNpc = me.GetNpc();
                local nAttackRate = pNpc.GetState(Npc.STATE.ZHICAN).nAttackRate;
                nAttackRate = nAttackRate + _GetAllSeriesstateRate();
                return string.format("增加造成致缠几率：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(nAttackRate) * 100) 
            end,
        };
        {
            szName = "抗致缠几率", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.ZHICAN).nResistRate
                -- return string.format("%0.2f%%", _CalcWuXingZhuangTai(pNpc.GetState(Npc.STATE.ZHICAN).nResistRate) * 100)
            end,
            fnDesc = function ()
                return string.format("减少受到致缠几率：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.ZHICAN).nResistRate) * 100) 
            end,
        };

        {
            szName = "麻痹几率", 
            func = function ()
                local pNpc = me.GetNpc();
                local nAttackRate = pNpc.GetState(Npc.STATE.PALSY).nAttackRate;
                nAttackRate = nAttackRate + _GetAllSeriesstateRate();
                return nAttackRate
                -- return string.format("%0.2f%%", _CalcWuXingZhuangTai(pNpc.GetState(Npc.STATE.PALSY).nAttackRate) * 100)
            end,
            fnDesc = function ()
                local pNpc = me.GetNpc();
                local nAttackRate = pNpc.GetState(Npc.STATE.PALSY).nAttackRate;
                nAttackRate = nAttackRate + _GetAllSeriesstateRate();
                return string.format("增加造成麻痹几率：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(nAttackRate) * 100) 
            end,
        };    
        {
            szName = "抗麻痹几率", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.PALSY).nResistRate
                -- return string.format("%0.2f%%", _CalcWuXingZhuangTai(pNpc.GetState(Npc.STATE.PALSY).nResistRate) * 100)
            end,
            fnDesc = function ()
                return string.format("减少受到麻痹几率：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.PALSY).nResistRate) * 100) 
            end,
        };

    };
    
    {
        {
            szName = "受伤时间", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.HURT).nAttackTime + _GetAllSeriesstateTime(); 
            end,
            fnDesc = function ()
                return string.format("增强受伤触发时间：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.HURT).nAttackTime + _GetAllSeriesstateTime()) * 100) 
            end,
        };    
        {
            szName = "抗受伤时间", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.HURT).nResistTime; 
            end,
            fnDesc = function ()
                return string.format("抵抗受伤触发时间：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.HURT).nResistTime) * 100) 
            end,
        };    
        {
            szName = "眩晕时间", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.STUN).nAttackTime + _GetAllSeriesstateTime(); 
            end,
            fnDesc = function ()
                return string.format("增强眩晕触发时间：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.STUN).nAttackTime + _GetAllSeriesstateTime()) * 100) 
            end,
        };    
        {
            szName = "抗眩晕时间", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.STUN).nResistTime; 
            end,
            fnDesc = function ()
                return string.format("抵抗眩晕触发时间：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.STUN).nResistTime) * 100) 
            end,
        };    
        {
            szName = "迟缓时间", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.SLOWALL).nAttackTime + _GetAllSeriesstateTime(); 
            end,
            fnDesc = function ()
                return string.format("增强迟缓触发时间：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.SLOWALL).nAttackTime + _GetAllSeriesstateTime()) * 100) 
            end,
        };    
        {
            szName = "抗迟缓时间", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.SLOWALL).nResistTime; 
            end,
            fnDesc = function ()
                return string.format("抵抗迟缓触发时间：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.SLOWALL).nResistTime) * 100) 
            end,
        };    
        {
            szName = "致缠时间", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.ZHICAN).nAttackTime + _GetAllSeriesstateTime(); 
            end,
            fnDesc = function ()
                return string.format("增强致缠触发时间：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.ZHICAN).nAttackTime + _GetAllSeriesstateTime()) * 100) 
            end,
        };    
        {
            szName = "抗致缠时间", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.ZHICAN).nResistTime; 
            end,
            fnDesc = function ()
                return string.format("抵抗致缠触发时间：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.ZHICAN).nResistTime) * 100) 
            end,
        };    
        {
            szName = "麻痹时间", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.PALSY).nAttackTime + _GetAllSeriesstateTime(); 
            end,
            fnDesc = function ()
                return string.format("增强麻痹触发时间：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.PALSY).nAttackTime + _GetAllSeriesstateTime()) * 100) 
            end,
        };    
        {
            szName = "抗麻痹时间", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.PALSY).nResistTime; 
            end,
            fnDesc = function ()
                return string.format("抵抗麻痹触发时间：[00ff00]%.2f%%[-]", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.PALSY).nResistTime) * 100) 
            end,
        };    
 

    };
    {
        {
            szName = "负面效果几率", 
            func = function ()
                local nAttackRate = GetSpecialStateInfo()
                return nAttackRate
            end,
            fnDesc = function ()
                local nAttackRate = GetSpecialStateInfo()
                return string.format("负面效果几率：[00ff00]%.2f%%[-]\n增加受到浮空、混乱、击退、灼烧、嘲讽等控制效果的几率", _CalcWuXingZhuangTai(nAttackRate) * 100) 
            end,
        };

        {
            szName = "抗负面效果几率", 
            func = function ()
                local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.NPC_HURT).nResistRate;  --这个是所有状态全加，而玩家是没有NPC_HURT的，所以直接取该值
            end,
            fnDesc = function ()
                return string.format("抗负面效果几率：[00ff00]%.2f%%[-]\n减少受到浮空、混乱、击退、灼烧、嘲讽等控制效果的几率", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.NPC_HURT).nResistRate) * 100) 
            end,
        };    

        {
            szName = "负面效果时间", 
            func = function ()
                local _, nAttackTime = GetSpecialStateInfo()
                return nAttackTime
            end,
            fnDesc = function ()
                local _, nAttackTime = GetSpecialStateInfo()
                return string.format("负面效果时间：[00ff00]%.2f%%[-]\n增加受到浮空、混乱、击退、灼烧、嘲讽等控制效果的时间", _CalcWuXingZhuangTai(nAttackTime) * 100) 
            end,
        }; 

        {
            szName = "抗负面效果时间", 
            func = function ()
              local pNpc = me.GetNpc();
                return pNpc.GetState(Npc.STATE.NPC_HURT).nResistTime;  --这个是所有状态全加，而玩家是没有NPC_HURT的，所以直接取该值
            end,
            fnDesc = function ()
                return string.format("抗负面效果时间：[00ff00]%.2f%%[-]\n减少受到浮空、混乱、击退、灼烧、嘲讽等控制效果的时间", _CalcWuXingZhuangTai(me.GetNpc().GetState(Npc.STATE.NPC_HURT).nResistTime) * 100) 
            end,
        };    
        
    };
};

function tbUi:OnOpen()
    self:SetData();
end

function tbUi:SetData()
    local tbHeight = {};
    local fnSetData = function (itemClass, index)
        if not self.nGridHeight then
            local tbSize = itemClass["Item1"].pPanel:Widget_GetSize("Main")
            self.nGridHeight = tbSize.y
            local tbSize = itemClass.pPanel:Widget_GetSize("Main")
            self.nContainerWidth = tbSize.x
        end
        local tbAttriGroup = tbAllArribute[index]
        
        for i, tbAttri in ipairs(tbAttriGroup) do
            local itemPanel = itemClass["Item" .. i].pPanel
            itemPanel:SetActive("Main", true)
            itemPanel:Label_SetText("lbAttriName", tbAttri.szName)
            itemPanel:Label_SetText("lbAttriVal", tbAttri.func())
            itemPanel.OnTouchEvent = function ()
                if not tbAttri.fnDesc then
                    return
                end
                local tbPos = itemPanel:GetRealPosition("Main");
                Ui:OpenWindowAtPos("AttributeDescription", tbPos.x + 300, tbPos.y, tbAttri.fnDesc(), true);
            end
        end

        for i=#tbAttriGroup + 1,14 do
           itemClass.pPanel:SetActive("Item" .. i, false) 
        end
        local nHeight = math.ceil(#tbAttriGroup /2)
        tbHeight[index] = self.nGridHeight * nHeight + 18
        self.AttributeScrollView:UpdateItemHeight(tbHeight)    
        itemClass.pPanel:Widget_SetSize("Main", self.nContainerWidth, tbHeight[index]);

    end
    self.AttributeScrollView:UpdateItemHeight({30})    
    self.AttributeScrollView:Update(tbAllArribute, fnSetData);
end

-- function tbUi:OnScreenClick(szClickUi)
--     Ui:CloseWindow(self.UI_NAME);
-- end

-- tbUi.tbOnClick = {
--     BtnClose = function (self)
--         Ui:CloseWindow(self.UI_NAME)
--     end,
-- };