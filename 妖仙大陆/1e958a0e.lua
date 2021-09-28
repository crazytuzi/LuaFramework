local ItemCombine = {}

local inited = false


local flagData = DataMgr.Instance.FlagPushData
local itemPack = DataMgr.Instance.UserData.RoleBag
local packFilter = nil







local combineTree = nil

local combineTreeTypeMap = nil

local combineTreeCodeMap = nil

local combineDestCodeMap = nil

local combineSrcCodeMap = nil

local destCanCombineMap = {}
local destCanCombineNum = 0

function ItemCombine.getCombineTree()
    return combineTree
end

function ItemCombine.getCombineByDestCode(destCode)
    return combineDestCodeMap[destCode]
end

local function updateFlagData()
    
    
    
    
    
end

local function updateCanCombineMap(destCode, canCombine, updateFlag)
    local oldValue = destCanCombineMap[destCode] or false
    if oldValue == canCombine then return end

    destCanCombineMap[destCode] = canCombine
    destCanCombineNum = destCanCombineNum + (canCombine and 1 or -1)

    if updateFlag then
        updateFlagData()
    end
end


function ItemCombine.getFirstCombineTreeIdxs()
    for i, v in ipairs(combineTree) do
        if #v.items == 0 and v.combineCodeNum > 0 then
            return i, nil
        end
        for ii,vv in ipairs(v.items) do
            if vv.combineCodeNum > 0 then
                return i, ii
            end
        end
    end
    return nil, nil
end

function ItemCombine.makeStaticCombine()
    if combineSrcCodeMap then return end

    combineSrcCodeMap = {}
    combineDestCodeMap = {}
    combineTreeCodeMap = {}
    local list = GlobalHooks.DB.Find("Combine", {})
    for i,v in ipairs(list) do
        v.packSrcNum = 0
        combineDestCodeMap[v.DestCode] = v
        combineSrcCodeMap[v.SrcCode1] = v
    end
end

local function idSortComp(a, b) return a.data.ID < b.data.ID end
local function parentIdSortComp(a, b) return a.data.ParentID < b.data.ParentID end

function ItemCombine.makeStaticCombineTree()
    if combineTree then return end

    combineTree = {}
    combineTreeTypeMap = {}
    local list = GlobalHooks.DB.Find("CombineType", {})
    for i, v in ipairs(list) do
        if v.ParentID == 0 then
            
            local item = combineTreeTypeMap[v.ID] or {items = {}, codeMap = {}, destItems={}, combineCodeMap = {}, combineCodeNum = 0}
            combineTreeTypeMap[v.ID] = item
            item.name = v.ItemName
            item.data = v
            table.insert(combineTree, item)
        elseif v.ID ~= 0 then
            
            local item = combineTreeTypeMap[v.ID] or {items = {}, codeMap = {}, destItems={}, combineCodeMap = {}, combineCodeNum = 0}
            item.name = v.ItemName
            item.data = v

            combineTreeTypeMap[v.ID] = item
            local parentItem = combineTreeTypeMap[v.ParentID] or {items = {}, codeMap = {}, destItems={}, combineCodeMap = {}, combineCodeNum = 0}
            combineTreeTypeMap[v.ParentID] = parentItem
            table.insert(parentItem.items, item)
        else
            local parentItem = combineTreeTypeMap[v.ParentID] or {items = {}, codeMap = {}, destItems={}, combineCodeMap = {}, combineCodeNum = 0}
            combineTreeTypeMap[v.ParentID] = parentItem
            combineTreeCodeMap[v.TagetCode] = parentItem
            parentItem.codeMap[v.TagetCode] = combineDestCodeMap[v.TagetCode]
            table.insert(parentItem.destItems, GlobalHooks.DB.Find("Items", v.TagetCode))
        end
    end
    
    table.sort(combineTree, idSortComp)
    for i,v in ipairs(combineTree) do
        table.sort(v.items, parentIdSortComp)
    end
end

function ItemCombine.makeCombineTreeAllData()
    for k,v in pairs(combineTreeTypeMap) do
        local count = 0
        v.combineCodeMap = {}
        for code, data in pairs(v.codeMap) do
            local n = itemPack:GetTemplateItemCount(data.SrcCode1)
            
            combineSrcCodeMap[data.SrcCode1].packSrcNum = n
            if n >= data.SrcCount1 then
                count = count + 1
                v.combineCodeMap[code] = true
                updateCanCombineMap(code, true, false)
            end
        end
        v.combineCodeNum = count
    end
end

function ItemCombine.packFilterCB(pack, type, index)
    local item = packFilter:GetItemDataAt(index)
    if not item then return end

    if type ~= ItemPack.NotiFyStatus.UPDATEITEM and 
        type ~= ItemPack.NotiFyStatus.ADDITEM and
        type ~= ItemPack.NotiFyStatus.RMITEM then
        return
    end

    local srcCode = item.TemplateId
    local db = combineSrcCodeMap[srcCode]
    local oldCanCombine = db.packSrcNum >= db.SrcCount1
    local nowNum = itemPack:GetTemplateItemCount(srcCode)
    local nowCanCombine = nowNum >= db.SrcCount1
    db.packSrcNum = nowNum

    local destCode = db.DestCode
    local treeItem = combineTreeCodeMap[destCode]

    
    if oldCanCombine == nowCanCombine then
        EventManager.Fire("Event.ItemCombine.ItemChange", {
            treeId = treeItem.data.ID,
            destCode = destCode, 
            srcCode = srcCode, srcNum = nowNum,
        })
        return
    end

    updateCanCombineMap(destCode, nowCanCombine, true)
    
    
    if treeItem.combineCodeMap[destCode] then
        treeItem.combineCodeMap[destCode] = nil
        treeItem.combineCodeNum = treeItem.combineCodeNum - 1
    else
        treeItem.combineCodeMap[destCode] = true
        treeItem.combineCodeNum = treeItem.combineCodeNum + 1
    end

    local menuLock, itemLock = nil, nil
    local menuId, itemId = nil, nil
    if treeItem.data.ParentID ~= 0 then
        itemId = treeItem.data.ID
        local treeMenu = combineTreeTypeMap[treeItem.data.ParentID]
        menuId = treeMenu.data.ID
    else
        menuId = treeItem.data.ID
    end

    EventManager.Fire("Event.ItemCombine.TreeChange", {
        treeMenuId = menuId, treeItemId = itemId,
        srcCode = srcCode, destCode = destCode,
    })
end

function ItemCombine.initial()
    if inited then return end
    inited = true

    ItemCombine.makeStaticCombine()
    ItemCombine.makeStaticCombineTree()
    ItemCombine.makeCombineTreeAllData()
    updateFlagData()

    packFilter = ItemPack.FilterInfo.New()
    packFilter.CheckHandle = function(item) return combineSrcCodeMap[item.TemplateId] ~= nil end
    packFilter.NofityCB = ItemCombine.packFilterCB
    
    itemPack:AddFilter(packFilter)
end

function ItemCombine.fin(relogin)
    if relogin then
        inited = false
        combineTree = nil
        combineTreeTypeMap = nil
        combineTreeCodeMap = nil
        destCanCombineNum = 0
        destCanCombineMap = {}
        if packFilter then
            itemPack:RemoveFilter(packFilter)
            packFilter = nil
        end
    end
end


return ItemCombine
