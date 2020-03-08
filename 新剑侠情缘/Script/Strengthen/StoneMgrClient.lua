StoneMgr.tbNullStoneIcon = 
{
  ["lifemax_v"]           = "life_stone";
  ["physical_damage_v"]   = "physcical_damage_stone";
  ["all_series_resist_v"] = "all_resist_stone";
  ["ignore_all_resist_v"] = "ignore_all_resist_stone";
  ["defense_v"]           = "defense_stone";
  ["ignore_defense_v"]    = "ignore_defense_stone";
  ["deadlystrike_v"]      = "deadlystrike_stone";
  ["weaken_deadlystrike_v"]= "weaken_deadlystrike_stone";
  ["add_seriesstate_rate_v"]= "add_seriesstate_stone";
  ["resist_allseriesstate_rate_v"]= "resist_allseriesstate_stone";
};


function StoneMgr:GetNullStoneIcon(szAttrib)
    return self.tbNullStoneIcon[szAttrib], "UI/Atlas/NewAtlas/Icon/Gem/Gem.prefab"
end


function StoneMgr:OnResponseInset(bInseted, nEquipPos, nInsetPos)
    if nEquipPos then
        self:UpdateInsetInfo(me, nEquipPos, true)
    end

	StoneMgr:UpdateInsetAttrib(me)
	UiNotify.OnNotify(UiNotify.emNOTIFY_INSET_RESULT, bInseted, nInsetPos);
    UiNotify.OnNotify(UiNotify.emNOTIFY_CHANGE_ADD_FIGHT_POWER) -- 因为客户端 UpdateEnhAtrrib 更新额外属性也会加战力，所以现在刷新下
end

function StoneMgr:OnResponseCombine()
	UiNotify.OnNotify(UiNotify.emNOTIFY_COMBINE_RESULT);
end

function StoneMgr:CheckInsetUpgradeFlag(nEquipId)
    if me.nLevel < self.MinInsetRoleLevel then
        return false
    end
    local pEquip = KItem.GetItemObj(nEquipId);
    if not pEquip then
        return false
    end
	local tbInset = me.GetInsetInfo(pEquip.nEquipPos);

    local nHasInset = 0;
    for i, nTemplateId in pairs(tbInset) do
        if self:CanQuiklyCombine(nTemplateId, pEquip, i) then
            return true
        end
        if nTemplateId ~= 0 then
            nHasInset = nHasInset + 1;
        end
    end    
    if nHasInset < pEquip.nHoleCount then
        local tbCanInsetStones = self:GetCanInsetStoneIds(pEquip.dwId)
        for i=#tbCanInsetStones, 1, -1 do
            local v = tbCanInsetStones[i]
            if self:CheckSameInsetType(v.InsetType, tbInset) then
                table.remove(tbCanInsetStones, i);
            end
        end
        if next(tbCanInsetStones) then
            return true    
        end
        
    end
    return false;
end

--优先插入替换，然后再是快速合成
function StoneMgr:CanQuiklyCombine(nStoneTemplateId, pEquip, nInsetPos)
    if nStoneTemplateId == 0 then
        return false;
    end

    local nNextTemplateId = StoneMgr:GetNextLevelStone(nStoneTemplateId)
    if nNextTemplateId == 0 then
        return false;
    end

    local tbBaseInfo = KItem.GetItemBaseProp(nNextTemplateId)

    local nInsetLevel = self:GetEquipInsetLevelAndCount(pEquip, me)
    if tbBaseInfo.nLevel > nInsetLevel then
        return false;
    end
    
    local tbTotalStone = StoneMgr:GetCombineStoneNeed(nStoneTemplateId, StoneMgr.COMBINE_COUNT, me, true, pEquip.nEquipPos)
    if tbTotalStone then
        return true
    end

    return false;
end

function StoneMgr:GetCanInsetStoneIds(nEquipId)
    local tbCanInsetStones = {};
    local pEquip = KItem.GetItemObj(nEquipId);
    if not pEquip then
        return
    end

    local nInsetLevel = self:GetEquipInsetLevelAndCount(pEquip, me)
    local szEquipPart = Item.EQUIPTYPE_EN_NAME[pEquip.nItemType];

    local tbStones = self:GetAllStoneInBag(me)
    for nTemplateId,nCount in pairs(tbStones) do
        local tbData = self.tbStoneSetting[nTemplateId];
        if tbData[szEquipPart] == 1 then

            local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId)            
            if tbBaseInfo.nLevel <= nInsetLevel then
                table.insert(tbCanInsetStones, {nTemplateId = nTemplateId, nCount = nCount, nLevel = tbBaseInfo.nLevel, InsetType = tbData.InsetType})
            end
        end
    end

    return tbCanInsetStones
end

--身上是否有更镶嵌或替换的魂石 --TODO 该接口暂时不用了
-- function StoneMgr:GetCanInsetStones(nEquipPos, nInsetPos)
--     local szPosName = Item.EQUIPPOS_EN_NAME[nEquipPos]
--     -- local szAttribType = self.tbInsetPosAttribType[szPosName][nInsetPos]
--     local tbInset = me.GetInsetInfo(nEquipPos);
--     local nCompareLevel = 0;
--     local nExistStoneId = tbInset[nInsetPos] 
--     if nExistStoneId ~= 0 then
--        nCompareLevel = StoneMgr:GetStoneLevel(nExistStoneId);
--     end
    
--     local tbAllStones = StoneMgr:GetAllStoneInBag(me);
--     for nTemplateId, nCount in pairs(tbAllStones) do
--         local tbData = self.tbStoneSetting[nTemplateId];
--         if tbData and tbData[szPosName] == 1 and szAttribType == tbData.AttribType  then
--             local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId)
--             if tbBaseInfo.nRequireLevel <= me.nLevel and  tbBaseInfo.nLevel > nCompareLevel then
--                 return true, nTemplateId
--             end
--         end
--     end
-- end