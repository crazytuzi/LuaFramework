--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/8/22
-- Time: 21:24
-- 
--

local s_moneyInfo = {
    [3] = {count = 0,     szSklName = "v_drop_jinbi_1.skl", szMeshName = "v_drop_jinbi_1_fmt.skn", szAnimaName = "v_drop_jinbi_1_daiji.san", szBornAnimaName = "v_drop_jinbi_1_diaoluo.san"},
    [2] = {count = 5000,  szSklName = "diaoluo_GJbaoxiang.skl", szMeshName = "diaoluo_DJbaoxiang.skn", szAnimaName = "v_drop_jinbi_2_daiji.san", szBornAnimaName = "v_drop_jinbi_2_diaoluo.san"},
    [1] = {count = 15000, szSklName = "diaoluo_GJbaoxiang.skl", szMeshName = "diaoluo_GJbaoxiang.skn", szAnimaName = "v_drop_jinbi_3_daiji.san", szBornAnimaName = "v_drop_jinbi_3_diaoluo.san"},
}

---------------------
_G.classlist['DropItemAvatar'] = 'DropItemAvatar'
_G.DropItemAvatar = {}
DropItemAvatar.objName = 'DropItemAvatar'
setmetatable(DropItemAvatar, {__index = CAvatar})
local metaDropItemAvatar = {__index = DropItemAvatar}

function DropItemAvatar:NewDropItemAvatar(dwItemID, configId, count)
	local obj = DropItemAvatar:new()
    obj.avtName = "dropItemAvatar"
    obj.configId = configId
    obj.dwItemID = dwItemID
    obj.count = count
    return obj
end

function DropItemAvatar:new()
    local obj = CAvatar:new()
    setmetatable(obj, metaDropItemAvatar)
    return obj
end

--手动调用创建和Update
function DropItemAvatar:Create()
    local szSklName, szMeshName, szAnimaName
    local dmeshId = ""
    
    local configId = self.configId
    if t_equip[configId] then
        dmeshId = t_equip[configId].dmeshid
        local list = GetPoundTable(dmeshId)
        szSklName, szMeshName, szAnimaName = list[1], list[2], list[3]
    elseif configId == 10 then
        for k, v in ipairs(s_moneyInfo) do
            if self.count > v.count then
                szSklName = v.szSklName
                szMeshName = v.szMeshName
                szAnimaName = v.szAnimaName
                self.szBornAnimaName = v.szBornAnimaName
                break
            end
        end
    elseif t_item[configId] then
        dmeshId = t_item[configId].dmeshid
        local list = GetPoundTable(dmeshId)
        szSklName, szMeshName, szAnimaName = list[1], list[2], list[3]
    end

    if not szMeshName or szMeshName == "" then
        Error("Get Item Mesh Error", configId)
        return false
    end

    if not szSklName or szSklName == "" then
        Error("Get Item Skl Error", configId)
        return false
    end

    if not szAnimaName or szAnimaName == "" then
        Error("Get Item Anima Error", configId)
        return false
    end

    self:SetPart("Body", szMeshName)
    self:ChangeSkl(szSklName)
    self:SetIdleAction(szAnimaName, true)
    self.objHlBlender = _Blender.new();
	
	local light = Light.GetEntityLight(enEntType.eEntType_Item,CPlayerMap:GetCurMapID());
    self.objHlBlender:highlight( light.hightlight );

    return true
end

function DropItemAvatar:GetItemID()
    return self.dwItemID;
end;

function DropItemAvatar:OnUpdate(e)

end;

--进入地图 位置信息:fXPos,fYPos,fDirValue
function DropItemAvatar:EnterMap(fXPos,fYPos,fDirValue)
    --Debug(debug.traceback())
    local objSceneMap = CPlayerMap:GetSceneMap();

    self:EnterSceneMap(objSceneMap,
        _Vector3.new(fXPos,
            fYPos,
            0
        ),
        fDirValue);

    self.objNode.dwType = enEntType.eEntType_Item;
end;

--离开地图
function DropItemAvatar:ExitMap()
    self:ExitSceneMap();
    self:Destroy();
    self.objHlBlender = nil
    self = nil
end;
--设置高亮状态(true:高亮，false：非高亮)
function DropItemAvatar:SetHighLightState(blState)
    self.blState = blState;
end


