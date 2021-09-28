



local _M = { }
_M.__index = _M
local cjson = require "cjson"
local helper = require "Zeus.Logic.Helper"
local VipUtil = require "Zeus.UI.Vip.VipUtil"
local Player = require "Zeus.Model.Player"


GlobalHooks.allDetails = GlobalHooks.allDetails or { }



function _M.GetEquipStrgData(equipPos,strengthPos)
    if strengthPos == nil then
        strengthPos = Player.GetBindPlayeProto().strengthPos or { }
    end
    for i = 1, #(strengthPos) do
        if strengthPos[i].pos == equipPos then
            return strengthPos[i]
        end
    end
    return nil
end

local function GetMainType(db_item)
    local eles = GlobalHooks.DB.Find('ItemTypeConfig', { })
    for _, v in ipairs(eles or { }) do
        for k, vv in pairs(v) do
            if string.sub(k, 1, string.len('SubType')) == 'SubType' then
                if vv == db_item.Type then
                    return ItemData.ToItemType(v.ID)
                end
            end
        end
    end
end

local function GetSecondTypeKey(secondType)
    local ele = GlobalHooks.DB.Find('ItemIdConfig', secondType)
    return ele.ItemType
end

local function GetSecondType(typeKey)
    local ele = unpack(GlobalHooks.DB.Find('ItemIdConfig', { ItemType = typeKey }))
    return(ele and ele.TypeID) or nil
end

local function ItemCode2NetItem(code)
    local ele = GlobalHooks.DB.Find('Items', code)
    if ele then
        return {
            code = code,
            itemType = GetMainType(ele),
            itemSecondType = GetSecondType(ele.Type),
            qColor = ele.Qcolor,
            maxGroupCount = ele.GroupCount,
            groupCount = 1,
            isNew = 0,
            icon = ele.Icon,
            enLevel = 0
        }
    else
        return nil
    end
end

local function GetAttrDesc(attr, numColor)
    local function DescFormat(str, numColor, ...)
        local r = { '{A}', '{B}', '{C}', '{D}', '{E}', '{F}', '{G}', '{H}', '{I}', '{J}', '{K}', '{L}' }
        local params = { ...}
        for i = 1, #params do
            local subText = params[i]
            if numColor then
                subText = string.format('<color=#%s>%s</color>', numColor, subText)
            end
            str = string.gsub(str, r[i], subText)
        end
        return str
    end

    local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)

    
    if attrdata.attParamCount == 1 then
        local v =(attrdata.isFormat == 1 and attr.value / 100) or attr.value
        return DescFormat(attrdata.attDesc, numColor, v or 0)
    elseif attrdata.attParamCount > 1 then
        local params = { }
        for i = 1, attrdata.attParamCount do
            
            if i == 1 and string.find(attrdata.attKey, 'Skill') then
                
                local sd = GlobalHooks.DB.Find('SkillData', attr.param1)
                if sd then
                    table.insert(params, sd.SkillName)
                else
                    table.insert(params, attr['param' .. i] or 0)
                end
            else
                local v =(attrdata.isFormat == 1 and attr['param' .. i] / 100) or attr['param' .. i]
                
                table.insert(params, v or 0)
            end
        end
        return DescFormat(attrdata.attDesc, numColor, unpack(params))
    else
        return attrdata.attDesc
    end
end


local function GetAttrScore(attribute, value)
    return math.floor(value * attribute.ScoreRatio)
end

local function CalcAttrsScore(attrs, lv)
    local score = 0
    local minAttrMag = unpack(GlobalHooks.DB.Find('Attribute', { attKey = 'MinMag' }))
    local maxAttrMag = unpack(GlobalHooks.DB.Find('Attribute', { attKey = 'MaxMag' }))
    local minAttrPhy = unpack(GlobalHooks.DB.Find('Attribute', { attKey = 'MinPhy' }))
    local maxAttrPhy = unpack(GlobalHooks.DB.Find('Attribute', { attKey = 'MaxPhy' }))
    for _, v in ipairs(attrs or { }) do
        lv = lv or 0
        local eleAttr = GlobalHooks.DB.Find('Attribute', v.id)
        if eleAttr then
            local minAttr, maxAttr
            if eleAttr.attKey == 'Mag' then
                minAttr, maxAttr = minAttrMag, maxAttrMag
            elseif eleAttr.attKey == 'Phy' then
                minAttr, maxAttr = minAttrPhy, maxAttrPhy
            end
            if minAttr and maxAttr then
                score = score + GetAttrScore(minAttr, _M.GetStrengthenMinMax(lv, v.minValue))
                score = score + GetAttrScore(maxAttr, _M.GetStrengthenMinMax(lv, v.maxValue))
            else
                score = score + GetAttrScore(eleAttr, _M.GetStrengthenMinMax(lv, v.value))
            end
        end
    end
    return score
end

local function FormatSpecialAttribute(ele)
    local attrs = { }
    local score = 0
    for i = 1, 9 do
        local prop = ele['UProp' .. i]
        if not prop then
            break
        end
        local par = ele['UPar' .. i]
        local min = ele['UMin' .. i]
        local max = ele['UMax' .. i]
        local eleAttr = unpack(GlobalHooks.DB.Find('Attribute', { attName = prop }))
        if eleAttr then
            attrs[eleAttr.attKey] = { attr = eleAttr, par = par, min = min, max = max }
            
            score = score + GetAttrScore(eleAttr, min)
        end
    end
    local ret = { }
    
    for k, v in pairs(attrs) do
        local tmp = { }
        tmp.id = v.attr.ID
        tmp.attKey = v.attr.attKey
        tmp.isFormat = v.attr.isFormat
        tmp.minValue = v.min
        if k == 'MinPhy' then
            tmp.maxValue =(attrs['MaxPhy'] and attrs['MaxPhy'].min) or v.max
            local phyProp = unpack(GlobalHooks.DB.Find('Attribute', { attKey = 'Phy' }))
            tmp.id = phyProp.ID
        elseif k == 'MinMag' then
            tmp.maxValue =(attrs['MaxMag'] and attrs['MaxMag'].min) or v.max
            local phyProp = unpack(GlobalHooks.DB.Find('Attribute', { attKey = 'Mag' }))
            tmp.id = phyProp.ID
        elseif k ~= 'MaxMag' and k ~= 'MaxPhy' then
            tmp.maxValue = v.max
        end
        if tmp.maxValue then
            tmp.param3 = v.par
            tmp.value = tmp.minValue
            
            tmp.minValue =(v.attr.isFormat == 1 and tmp.minValue / 100) or tmp.minValue
            tmp.maxValue =(v.attr.isFormat == 1 and tmp.maxValue / 100) or tmp.maxValue
            table.insert(ret, tmp)
        end
    end
    return ret, score
end




local function FormatAttribute(ele)
    local attrs = { }
    local score = 0
    for i = 1, 9 do
        local prop = ele['Prop' .. i]
        if not prop then
            break
        end
        local par = ele['Par' .. i]
        local min = ele['Min' .. i]
        local max = ele['Max' .. i]
        local eleAttr = unpack(GlobalHooks.DB.Find('Attribute', { attName = prop }))
        if eleAttr then
            attrs[eleAttr.attKey] = { attr = eleAttr, par = par, min = min, max = max }
            
            score = score + GetAttrScore(eleAttr, min)
        end
    end
    local ret = { }
    
    for k, v in pairs(attrs) do
        local tmp = { }
        tmp.id = v.attr.ID
        tmp.attKey = v.attr.attKey
        tmp.isFormat = v.attr.isFormat
        tmp.minValue = v.min
        if k == 'MinPhy' then
            tmp.maxValue =(attrs['MaxPhy'] and attrs['MaxPhy'].min) or v.max
            local phyProp = unpack(GlobalHooks.DB.Find('Attribute', { attKey = 'Phy' }))
            tmp.id = phyProp.ID
        elseif k == 'MinMag' then
            tmp.maxValue =(attrs['MaxMag'] and attrs['MaxMag'].min) or v.max
            local phyProp = unpack(GlobalHooks.DB.Find('Attribute', { attKey = 'Mag' }))
            tmp.id = phyProp.ID
        elseif k ~= 'MaxMag' and k ~= 'MaxPhy' then
            tmp.maxValue = v.max
        end
        if tmp.maxValue then
            tmp.value = tmp.minValue
            
            tmp.minValue =(v.attr.isFormat == 1 and tmp.minValue / 100) or tmp.minValue
            tmp.maxValue =(v.attr.isFormat == 1 and tmp.maxValue / 100) or tmp.maxValue
            table.insert(ret, tmp)
        end
    end
    return ret, score
end

local function AttributeValue2NameValue(attr)
    local format1 = '%s:%d'
    local format2 = '%s:%d-%d'
    local format3 = '%s:%d%%'
    local format4 = '%s:%d%%-%d%%'
    local attrEle = GlobalHooks.DB.Find('Attribute', attr.id)
    if attr.value > 0 then
        local value = attr.value
        if attr.isFormat == 1 then
            value = value/100
            
        
            
        end
        return string.gsub(attrEle.attDesc,'{A}',tostring(value))
    else
        local minValue = attr.minValue
        local maxValue = attr.maxValue
        if attr.isFormat == 1 then
            minValue = attr.minValue/100
            maxValue = attr.maxValue/100
            
        
            
        end
        return string.gsub(attrEle.attDesc,'{A}',tostring(minValue)).."-"..tostring(maxValue).."%"
    end
end

local function GetEquipBaseAttr(ele)
    if ele.ExtendCode and ele.ExtendCode ~= '' then
        local extend_ele = GlobalHooks.DB.Find('Items', ele.ExtendCode)
        
        return GetEquipBaseAttr(extend_ele)
    end
    
    return FormatAttribute(ele)
end

local function GetIdentifyCost(quality)
    local name
    if quality == GameUtil.Quality_Green then
        name = 'Equipment.IdentfyGreen.Count'
    elseif quality == GameUtil.Quality_Blue then
        name = 'Equipment.IdentfyBlue.Count'
    elseif quality == GameUtil.Quality_Purple then
        name = 'Equipment.IdentfyPurple.Count'
    elseif quality == GameUtil.Quality_Orange then
        name = 'Equipment.IdentfyLegend.Count'
    end
    if name then
        local itemNum = GlobalHooks.DB.GetGlobalConfig(name) or 1
        local itemCode = GlobalHooks.DB.GetGlobalConfig('Equipment.IdentfyItem.Code')
        return { code = itemCode, num = itemNum }
    else
        return nil
    end
end

function _M.GetItemStaticDataByCode(code)
    return GlobalHooks.DB.Find('Items', code)
end

local detail_meta = { }
detail_meta.__newindex = function(self, key, value)
    if key == 'bindType' then
        rawset(self, 'bindTypeChanged', true)
    end
    rawset(self, key, value)
end
detail_meta.__index = detail_meta

function _M.ReCalcDetailScore(detail)
    if not detail.equip then return 0 end
    detail.equip.score = CalcAttrsScore(detail.equip.baseAtts, detail.equip.enLevel) +
    CalcAttrsScore(detail.equip.randomAtts) +
    CalcAttrsScore(detail.equip.jewelAtts) +
    CalcAttrsScore(detail.equip.magicAtts)
end

function _M.GetItemDetailByCode(code)
    local ele = GlobalHooks.DB.Find('Items', code)

    if not ele then
        return nil
    else
        local ret = setmetatable( { }, detail_meta)
        ret.static = ele
        ret.itemType = GetMainType(ele)
        ret.itemSecondType = GetSecondType(ele.Type)

        if ele.BindType == 1 then
            ret.bindType = 3
        elseif ele.BindType == 2 then
            ret.bindType = 2
        else
            ret.bindType = 0
        end
        if ret.itemType == nil then
            
            
        end
        local uniqueScore = 0
        if ItemData.CheckIsEquip(ret.itemType) then
            ret.equip = { isIdentfied = ele.isIdentfied, enLevel = 0, score = - 1 }
            local ele_pro = unpack(GlobalHooks.DB.Find('Character', { ProName = ele.Pro }))
            ret.equip.pro = ele_pro and ele_pro.ID
            ret.equip.baseAtts, ret.equip.score = GetEquipBaseAttr(ele)
            ret.equip.uniqueAtts,uniqueScore = FormatSpecialAttribute(ele)
            ret.equip.score = ret.equip.score + uniqueScore
            ret.equip.baseScore = ret.equip.score

            


            
            
            
            
            
            
            
            
            






        end

        return ret
    end
end









function _M.GetItemDetailById(id)
    local ret = GlobalHooks.allDetails[id]
    if not ret then
        local item = _M.GetItemById(id)
        if item then
            ret = _M.GetItemDetailByCode(item.TemplateId)
            GlobalHooks.allDetails[id] = ret
            if ret ~= nil then ret.id = id end
        end
    end
    return ret
end


function _M.GetItemDetailByTempId(templateId, cb)
    if not cb then return end
    local ret = GlobalHooks.allDetails[templateId]
    if not ret then
        
        
        
        Pomelo.ItemHandler.itemTemplateDetailRequest(templateId, function(ex, sjson)
            if not ex then
                local param = sjson:ToData()
                TrySetTempIdCache(param.s2c_item, true)
                cb(param.s2c_item)
            end
        end )
    else
        cb(ret)
    end
end

function _M.GetLocalCompareDetail(itemSecondType)
    local userdata = DataMgr.Instance.UserData
    local cmpItem = userdata.RoleEquipBag:GetItemAt(itemSecondType)
    if cmpItem then
        return _M.GetItemDetailById(cmpItem.Id)
    else
        return nil
    end
end


function _M.GetItemById(id)
    local userdata = DataMgr.Instance.UserData
    local item = userdata.RoleEquipBag:FindItem(id)
    if not item then
        item = userdata.RoleBag:FindItem(id)
    end
    if not item then
        item = userdata.StoreBag:FindItem(id)
    end
    if not item then
        item = userdata.SaleItemBag:FindItem(id)
    end
    return item
end


local function CheckCustomEquipAttr(detail)
    if not detail.equip then return false end
    local check1 = false
    for _, v in ipairs(detail.equip.randomAtts or { }) do
        if v.id ~= 0 then
            check1 = true
            break
        end
    end

    return detail.equip.enLevel > 0 or
    check1 or
    (detail.equip.jewelAtts and #detail.equip.jewelAtts > 0) or
    (detail.equip.magicAtts and #detail.equip.magicAtts > 0)
end

function _M.SellItem(index, num, cb)
    Pomelo.BagHandler.sellItemRequest(index, num, function(ex, sjson)
        if not ex and cb then
            cb()
        end
    end )
end

function _M.UseItemRequest(index, num, cb)
    
        Pomelo.BagHandler.useItemRequest(index, num, function(ex, sjson)
            if not ex and cb then
                local param = sjson:ToData()
                cb(param.s2c_chest)

                
                if (param.is_gain == 2) then
                    EventManager.Fire("Event.ShowRoleRename", {pos = index})
                end
            end
        end )
    

    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
        
    
end

function _M.GetBagItemsByTemplate(template)
    local items = { }
    local rg = DataMgr.Instance.UserData.RoleBag
    local iter = rg.AllData:GetEnumerator()
    while iter:MoveNext() do
        local data = iter.Current.Value
        if data.TemplateId == template then
            table.insert(items, data)
        end
    end
    return items
end

function _M.GetGold()
    return tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD))
end

function _M.GetDiamond()
    return tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.DIAMOND))
end

function _M.EquipItem(index, cb, errorcb)
    local function DoEquip()
        Pomelo.EquipHandler.equipRequest(index, function(ex, sjson)
            if not ex then
                if cb then
                    cb()
                end
            else
                if errorcb then
                    errorcb()
                end
            end
        end )
    end
    DoEquip()
end

function _M.UnEquipItem(index, cb)
    Pomelo.EquipHandler.unEquipRequest(index, function(ex, sjson)
        if not ex then
            if cb then
                cb()
            end
        end
    end )
end

function _M.TransferItemRequest(from, index, to, num, cb)
    Pomelo.BagHandler.transferItemRequest(from, index, to, num, function(ex, sjson)
        if not ex and cb then
            cb()
        end
    end )
end

function _M.quaryItemNewStatus(index)
    Pomelo.ItemHandler.queryItemStatusUpdateNotify(index)
end


function _M.OpenGridRequest(pack_type, num, cb)
    Pomelo.BagHandler.openBagGridRequest(pack_type, num, function(ex, sjson)
        if not ex then
            local param = sjson:ToData()
            local userdata = DataMgr.Instance.UserData
            if pack_type == userdata.RoleBag.PackType then
                userdata.RoleBag:Resize(param.s2c_bagGridCount)
            elseif pack_type == userdata.StoreBag.PackType then
                userdata.StoreBag:Resize(param.s2c_bagGridCount)
            end
            if cb then
                cb()
            end
        end
    end )
end

function _M.PreStrengthenRequest(pos, cb)
    if not cb then return end
    Pomelo.EquipHandler.equipPreStrengthenRequest(pos, function(ex, sjson)
        if not ex then
            local param = sjson:ToData()
            cb(param.s2c_strengthenData)
        end
    end )
end



function _M.OpenEquipHandlerRequest(tag)
    Pomelo.EquipHandler.openEquipHandlerRequest(tag, function(ex, sjson)
    end)
end


function _M.getEnchantInfoRequest(pos, cb)
    if not cb then return end
    Pomelo.EquipHandler.getEquipEnchantInfoRequest(pos, function(ex, sjson)
        if not ex then
            local param = sjson:ToData()
            cb(param.s2c_enchant)
        end
    end )
end

function _M.enchantEquipRequest(pos, gridIndex, diamond, cb)
    if not cb then return end
    Pomelo.EquipHandler.enchantEquipRequest(pos, gridIndex, diamond, function(ex, sjson)
        if not ex then
            cb(sjson:ToData())
        end
    end )
end

function _M.enchantEquipConfirmRequest(pos, cb)
    if not cb then return end
    Pomelo.EquipHandler.confirmEnchantEquipRequest(pos, function(ex, sjson)
        if not ex and cb then
            cb()
        end
    end )
end

function _M.StrengthenRequest(pos, use_diamond, cb)
    if not cb then return end
    Pomelo.EquipHandler.equipStrengthenRequest(pos, use_diamond, function(ex, sjson)
        if not ex then
            local param = sjson:ToData()
            cb(param.s2c_success, param.s2c_strengthenData)
        elseif cb then
            cb(nil)
        end
    end )
end

function _M.IdentifyEquip(pos, cb)
    if not cb then return end
    Pomelo.EquipHandler.identifyEquipRequest(pos, function(ex, sjson)
        if not ex then
            cb()
        end
    end )
end

function _M.FillGem(pos, index, gridIndex, cb)
    if not cb then return end
    Pomelo.EquipHandler.fillGemRequest(pos, index, gridIndex, function(ex, sjson)
        if not ex then
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('xiangqian')
            local param = sjson:ToData()
            cb(param.s2c_index)
        end
    end )
end

function _M.FillAllGems(pos, cb)
    Pomelo.EquipHandler.fillAllGemRequest(pos, function(ex, sjson)
        if not ex and cb then
            cb()
        end
    end )
end

function _M.UnFillGem(pos, index, cb)
    if not cb then return end
    Pomelo.EquipHandler.unFillGemRequest(pos, index, function(ex, sjson)
        if not ex then
            cb()
        end
    end )
end

function _M.UnFillAllGem(pos, cb)
    if not cb then return end
    Pomelo.EquipHandler.unFillAllGemRequest(pos, function(ex, sjson)
        if not ex then
            cb()
        end
    end )
end

function _M.GetSuitInfo(cb)
    if not cb then return end
    Pomelo.EquipHandler.getSuitAttrRequest( function(ex, sjson)
        if not ex then
            local param = sjson:ToData()
            
            cb(param.s2c_data)
        end
    end )
end

function _M.GetSuitDetailView(type, cb)
    if not cb then return end
    Pomelo.EquipHandler.getSuitDetailRequest(type, function(ex, sjson)
        if not ex then
            local param = sjson:ToData()
            cb(param.s2c_data)
        end
    end )
end

function _M.GetInheritInfo(src, target, cb)
    if not cb then return end
    Pomelo.EquipHandler.getInheritInfoRequest(src, target, function(ex, sjon)
        if not ex then
            local param = sjon:ToData()
            cb(param)
        end
    end )
end

function _M.InheritRequest(src, target, magic, gem, refine, cb, c2s_isAuto)
    if not cb then return end
    local isautosell = c2s_isAuto == nil and 0 or c2s_isAuto
    Pomelo.EquipHandler.equipInheritRequest(src, target, magic, gem, refine, isautosell, function(ex, sjon)
        if not ex then
            cb()
        end
    end )
end

function _M.GetCombineFormulaRequest(id, cb)
    if not cb then return end
    Pomelo.ItemHandler.getCombineFormulaRequest(id, function(ex, sjon)
        if not ex then
            local param = sjon:ToData()
            
            cb(param.s2c_data)
        end
    end )
end

function _M.ItemCombineRequest(id, num, opt_index, cb)
    if not cb then return end
    Pomelo.ItemHandler.combineRequest(id, num, opt_index, function(ex, sjon)
        if not ex then
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('xiangqian')
            cb()
        end
    end )
end

function _M.EquipSmeltRequest(indexs, cb)
    Pomelo.EquipHandler.equipMeltRequest(indexs, function(ex, sjon)
        if not ex then
            if not cb then return end
            cb(sjon:ToData())
        end
    end )
end

function _M.ChatEquipDetailRequest(indexs, cb)
    Pomelo.EquipHandler.chatEquipDetailRequest(indexs, function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
        end
    end )
end

function _M.EquipRebornRequest(equipId, cb)
    
    Pomelo.EquipHandler.equipRebornRequest(equipId, function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("xilian") 

        end
    end )
end

function _M.EquipRebuildRequest(equipId, lockids, cb)
    
    Pomelo.EquipHandler.equipRebuildRequest(equipId, lockids, function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("strengthen") 
        end
    end )
end

function _M.EquipSeniorRebuildRequest(equipId, cb)
    
    Pomelo.EquipHandler.equipSeniorRebuildRequest(equipId, function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("strengthen") 
        end
    end )
end

function _M.EquipRefineRequest(equipId, attrkey, cb)
    
    Pomelo.EquipHandler.equipRefineRequest(equipId, attrkey, function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
        end
    end )
end

function _M.EquipRefineLegendRequest(equipId, cb)
    
    Pomelo.EquipHandler.equipRefineLegendRequest(equipId, "0", function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("kaiguang") 
        end
    end )
end

function _M.SaveRebornRequest(equipId, cb)
    
    Pomelo.EquipHandler.saveRebornRequest(equipId, function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
        end
    end )
end

function _M.SaveRebuildRequest(equipId, cb)
    
    Pomelo.EquipHandler.saveRebuildRequest(equipId, function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
        end
    end )
end

function _M.SaveSeniorRebuildRequest(equipId, cb)
    
    Pomelo.EquipHandler.saveSeniorRebuildRequest(equipId, function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
        end
    end )
end

function _M.SaveRefineRequest(equipId, attrkey, cb)
    
    Pomelo.EquipHandler.saveRefineRequest(equipId, attrkey, function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
        end
    end )
end

function _M.SaveRefineLegendRequest(equipId, cb)
    
    Pomelo.EquipHandler.saveRefineLegendRequest(equipId, "0", function(ex, sjon) 
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
        end
    end )
end

function _M.GetRefineExtPropRequest(equipId, cb)
    
    Pomelo.EquipHandler.getRefineExtPropRequest(equipId, function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param.extAtts)
        end
    end )
end

function _M.RefineOneKeyRequest(pos, itemCode, cb)
    Pomelo.EquipHandler.refineOneKeyRequest(pos, itemCode, function(ex, sjon)
        if not ex and cb then
            cb(sjon:ToData())
        end
    end )
end

function _M.RefineResetRequest(pos, attrIndex, cb)
    Pomelo.EquipHandler.refineResetRequest(pos, attrIndex, function(ex, sjon)
        if not ex and cb then
            cb(sjon:ToData())
        end
    end )
end

function _M.SmritiRequest(leftId,rightId, cb)
    
    Pomelo.EquipHandler.smritiRequest(leftId,rightId, function(ex, sjon)
        if not ex then
            if not cb then return end
            local param = sjon:ToData()
            cb(param)
        end
    end )
end



function _M.EquipLevelUpRequest(equippos, mateType, cb)
    Pomelo.EquipHandler.equipLevelUpRequest(equippos, mateType, function(ex, sjon)
        if not ex and cb then
            cb()
        end
    end )
end


function _M.EquipColorUpRequest(equippos, cb)
    Pomelo.EquipHandler.equipColorUpRequest(equippos, function(ex, sjon)
        if not ex and cb then
            cb()
        end
    end )

end

function _M.EquipMakeRequest(targetCode, cb)
    if not cb then return end
    Pomelo.EquipHandler.equipMakeRequest(targetCode, function(ex, sjon)
        if not ex then
            cb(sjon:ToData())
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("strengthen") 
        end
    end )
end

function _M.CheckIsCanUsed(data)
    

    if data.equip == nil or
        data.static.LevelReq > DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
        
        or(data.equip.pro ~= 0 and data.equip.pro ~= DataMgr.Instance.UserData.Pro)
        
    then
        return false
    end
    local itemdata2 = DataMgr.Instance.UserData.RoleEquipBag:GetItemAt(data.itemSecondType)
    
    if itemdata2 ~= nil then
        itemdata2 = _M.GetItemDetailById(itemdata2.Id)
    end

    if itemdata2 == nil then
        return true
    elseif itemdata2.id == data.id then
        return false
    else
        
        
        
        if itemdata2.equip.baseScore < data.equip.baseScore and itemdata2.static.isBothHand == data.static.isBothHand then
            return true
        else
            return false
        end
    end
    return false
end

function GlobalHooks.DynamicPushs.bagNewItemPush(ex, sjson)
    
    if not ex then
        local param = sjson:ToData()
        for i = 1, #param.s2c_data do
            GameAlertManager.Instance:ShowFloatingItem(param.s2c_data[i].icon, tonumber(param.s2c_data[i].qColor), param.s2c_data[i].name, tonumber(param.s2c_data[i].groupCount), 0)
        end
    end
end

function GlobalHooks.DynamicPushs.bagNewItemFromResFubenPush(ex, sjson)
    
    if not ex then
        local param = sjson:ToData()
        if param.s2c_data and #param.s2c_data > 0 then
            EventManager.Fire("Event.UpdateLimitDungeonReards",{data = param.s2c_data})
        end
    end
end

function GlobalHooks.DynamicPushs.bagNewEquipPush(ex, sjson)
    
    if not ex then
        local param = sjson:ToData()
        
        
        for i = 1, #param.s2c_data do
            local localdetail = _M.GetItemDetailById(param.s2c_data[i])
            if _M.CheckIsCanUsed(localdetail) then
                
                local node, lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIGoodItem)
                if lua_obj == nil then
                    node, lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGoodItem, 0)
                end
                lua_obj.InitInfo(localdetail)
            end
        end
    end
end

function GlobalHooks.DynamicPushs.bagGridFullPush(ex, sjson)
    if not ex then
        EventManager.Fire('Event.OnShowFullBagTips', { })
    end
end

function GlobalHooks.DynamicPushs.fishItemPush(ex, sjson)
    if not ex then
        local params = sjson:ToData()
        
        for _, v in ipairs(params.s2c_item) do
            local d = _M.GetItemDetailByCode(v.code)
            GameUtil.ShowPickItemEffect(Vector2.New(-30, -100), d.static.Icon, d.static.Qcolor, v.groupCount)
        end
    end
end

function _M.GetStrengthenValue(enLevel, attr)
    local Util = require 'Zeus.Logic.Util'
    local enProp = GlobalHooks.DB.Find('Enchant', enLevel)
    if enProp then
        return Util.GetRounding(0.5 *(attr.minValue + attr.maxValue) *(enProp.PropPer) / 10000)
    end
end

function _M.GetStrengthenAddValue(enLevelTarget, min, max)
    local Util = require 'Zeus.Logic.Util'
    local enProp = GlobalHooks.DB.Find('Enchant', enLevelTarget)
    if enProp then
        local retmin = min *(enProp.PropPer) / 10000
        local retmax = retmin
        if max then
            retmax = max *(enProp.PropPer) / 10000
        end
        return Util.GetRounding((retmin + retmax) * 0.5)
    end
end

function _M.GetStrengthenMinMax(enLevel, min, max)
    local Util = require 'Zeus.Logic.Util'
    if enLevel <= 0 then
        return min, max
    end
    local retmin, retmax = min, max
    local enProp = GlobalHooks.DB.Find('Enchant', enLevel)
    if enProp then
        retmin = Util.GetRounding(min + min *(enProp.SumPropPer / 10000))
        if max then
            retmax = Util.GetRounding(max + max *(enProp.SumPropPer / 10000))
        end
    end
    return retmin, retmax
end

function _M.GetMaxStrengthenLv()
    local ret = GlobalHooks.DB.Find('Enchant', { })
    return #ret
end













local function ResetThresholdRange(attrMap)
    for _, attr in ipairs(attrMap) do
        if attr.minValue > attr.value then
            attr.minValue = attr.value
        end
        if attr.maxValue < attr.value then
            attr.maxValue = attr.value
        end
    end
end

local function DealAttrThreshold(detail)
    
    local attrMap = detail.equip.randomAtts or {}
    ResetThresholdRange(attrMap)

    local attrMap = detail.equip.baseAtts or {}
    ResetThresholdRange(attrMap)

    local attrMap = detail.equip.tempBaseAtts or {}
    ResetThresholdRange(attrMap)

    local attrMap = detail.equip.tempExtAtts or {}
    ResetThresholdRange(attrMap)

    local attrMap = detail.equip.tempExtAtts_senior or {}
    ResetThresholdRange(attrMap)
end

local function SetDynamicAttrToItemDetail(detail, data)
    local equip_detail = data.equipDetail
    local function DynamicValSet(key)
        if data[key] ~= nil then
            detail[key] = data[key]
        end
    end
    DynamicValSet('bindType')
    DynamicValSet('canTrade')
    DynamicValSet('canAuction')
    DynamicValSet('canDepotRole')
    DynamicValSet('canDepotGuild')
    DynamicValSet('earDetail')
    detail.id = data.id
    if equip_detail then
        if detail.equip == nil then
            detail.equip = { }
        end
        
        detail.equip.isIdentfied = equip_detail.isIdentfied or detail.equip.isIdentfied
        detail.equip.enLevel = equip_detail.enLevel or detail.equip.enLevel
        detail.equip.score = equip_detail.score or detail.equip.score

        detail.equip.randomAtts = equip_detail.randomAtts and helper.copy_table(equip_detail.randomAtts)
        

        detail.equip.jewelAtts = equip_detail.jewelAtts and helper.copy_table(equip_detail.jewelAtts)
        detail.equip.magicAtts = equip_detail.magicAtts and helper.copy_table(equip_detail.magicAtts)
        detail.equip.luckyExp = equip_detail.luckyExp or detail.equip.luckyExp

        detail.equip.baseScore = equip_detail.baseScore or detail.equip.baseScore

        detail.equip.baseAtts = equip_detail.baseAtts or helper.copy_table(equip_detail.baseAtts)
        

        detail.equip.uniqueAtts = equip_detail.uniqueAtts or helper.copy_table(equip_detail.uniqueAtts)
        

        detail.equip.tempBaseAtts = equip_detail.tempBaseAtts or helper.copy_table(equip_detail.tempBaseAtts)
        

        detail.equip.tempExtAtts = equip_detail.tempExtAtts or helper.copy_table(equip_detail.tempExtAtts)
        

        detail.equip.tempExtAtts_senior = equip_detail.tempExtAtts_senior or helper.copy_table(equip_detail.tempExtAtts_senior)
        

        detail.equip.tempUniqueAtts = equip_detail.tempUniqueAtts or helper.copy_table(equip_detail.tempUniqueAtts)
        

        detail.equip.refineAttrId = equip_detail.refineAttrId
        

        detail.equip.tempRefineAttr = equip_detail.tempRefineAttr
        

        detail.equip.remakeScore = equip_detail.remakeScore
        

        detail.equip.tempRemakeScore = equip_detail.tempRemakeScore
        

        detail.equip.starAttr = equip_detail.starAttr
        

        detail.equip.tempstarAttr = equip_detail.tempstarAttr
        

        detail.equip.seniorTempRemakeScore = equip_detail.seniorTempRemakeScore
        
        
        

        DealAttrThreshold(detail)
    end
end

local earCode = GlobalHooks.DB.Find('Parameters', { ParamName = "RewardPK.DropItem" })[1].ParamValue
local function IsEar(detail, data)
    if data.code == earCode then
        if not data.earDetail then data.earDetail = data end
        if data.earDetail.time then
            detail.static.Name = string.gsub(detail.static.Name, "$n", data.earDetail.ownName)
            detail.static.Desc = string.gsub(detail.static.Desc, "$N", DataMgr.Instance.UserData.Name)
            detail.static.Desc = string.gsub(detail.static.Desc, "$n", data.earDetail.ownName)
            detail.static.Desc = string.gsub(detail.static.Desc, "$T", data.earDetail.time)
        end
        
    end
end

local function UpdateDetails(items, event)
    if not items then return end
    GlobalHooks.allDetails = GlobalHooks.allDetails or { }
    for _, v in ipairs(items) do
        local detail = GlobalHooks.allDetails[v.id]
        if not detail then
            detail = _M.GetItemDetailByCode(v.code)
            GlobalHooks.allDetails[v.id] = detail
        end
        SetDynamicAttrToItemDetail(detail, v)
        IsEar(detail, v)
        if event then
            EventManager.Fire("Event.DynamicPushs.itemDetailPush", { id = v.id })
        end
    end
end








function GlobalHooks.DynamicPushs.itemDetailPush(ex, sjson)
    if not ex then
        local param = sjson:ToData()
        UpdateDetails(param.s2c_data, true)
    end
end

function GlobalHooks.DynamicPushs.rewardItemPush(ex, sjson)
    if not ex then
        local param = sjson:ToData()
        EventManager.Fire('Event.OnShowNewItems',{items = param.s2c_item or {}})
    end
end

function GlobalHooks.DynamicPushs.equipInheritPush(ex, sjson)
    
    
    
    
    
    
    
    
end

function GlobalHooks.DynamicPushs.buffPropertyPush(ex, sjson)
    
    if not ex then
        
        local param = sjson:ToData()
        _M.bufList = param.buffList or { }
        EventManager.Fire('Event.Item.BuffPropertyPush', _M.bufList)
    end
end

function GlobalHooks.DynamicPushs.equipStrengthPosPush(ex, sjson)
    if not ex then
        local param = sjson:ToData()
        local strengthPos = Player.GetBindPlayeProto().strengthPos or { }
        for i = 1, #(strengthPos) do
            for j = 1, #(param.strengthInfos) do
                if strengthPos[i].pos == param.strengthInfos[j].pos then
                    strengthPos[i] = param.strengthInfos[j]
                end
            end
        end
    end
end

function _M.InitNetWork()
    Pomelo.GameSocket.bagNewItemPush(GlobalHooks.DynamicPushs.bagNewItemPush)
    Pomelo.GameSocket.bagNewItemFromResFubenPush(GlobalHooks.DynamicPushs.bagNewItemFromResFubenPush)
    Pomelo.GameSocket.bagNewEquipPush(GlobalHooks.DynamicPushs.bagNewEquipPush)
    Pomelo.GameSocket.bagGridFullPush(GlobalHooks.DynamicPushs.bagGridFullPush)
    Pomelo.GameSocket.itemDetailPush(GlobalHooks.DynamicPushs.itemDetailPush)
    Pomelo.GameSocket.rewardItemPush(GlobalHooks.DynamicPushs.rewardItemPush)
    Pomelo.GameSocket.fishItemPush(GlobalHooks.DynamicPushs.fishItemPush)
    Pomelo.GameSocket.equipInheritPush(GlobalHooks.DynamicPushs.equipInheritPush)
    Pomelo.GameSocket.buffPropertyPush(GlobalHooks.DynamicPushs.buffPropertyPush)
    Pomelo.GameSocket.equipStrengthPosPush(GlobalHooks.DynamicPushs.equipStrengthPosPush)
end

local function RequestAllEquipmentDetail()
    
    Pomelo.ItemHandler.getAllEquipDetailsRequest( function(ex, sjson)
        if not ex then
            local param = sjson:ToData()
            
            UpdateDetails(param.s2c_items)
        end
    end )
end

function _M.RequestGuildWereHouseEquipmentDetail(items)
    
    
    UpdateDetails(items)
end

local function SetEarItem(items)
    UpdateDetails(items)
end

local function FirstInitFinish()
    RequestAllEquipmentDetail()
end

function _M.initial()
    EventManager.Subscribe("Event.Scene.FirstInitFinish", FirstInitFinish)

    local ItemData_Metable = getmetatable(ItemData)
    local is_metatable_change = rawget(ItemData_Metable, 'is_metatable_change')
    if not is_metatable_change then
        local func = ItemData_Metable.__index
        rawset(ItemData_Metable, 'is_metatable_change', true)
        ItemData_Metable.__index = function(self, key)
            if key == 'detail' then
                if func(self, 'IsTemplateItem') then
                    return _M.GetItemDetailByCode(self.TemplateId)
                else
                    return _M.GetItemDetailById(self.Id)
                end
            else
                return func(self, key)
            end
        end
    end
end


_M.GetSecondType = GetSecondType
_M.GetSecondTypeKey = GetSecondTypeKey
_M.SetDynamicAttrToItemDetail = SetDynamicAttrToItemDetail
_M.FormatAttribute = FormatAttribute
_M.AttributeValue2NameValue = AttributeValue2NameValue
_M.SetEarItem = SetEarItem
_M.IsEar = IsEar
_M.GetAttrDesc = GetAttrDesc
_M.CheckCustomEquipAttr = CheckCustomEquipAttr
return _M
