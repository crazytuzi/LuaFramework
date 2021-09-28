local Util = require "Zeus.Logic.Util"

local INDEX_WEIGHT = 1000

local AccordionExt = {}
Util.WrapOOPSelf(AccordionExt)

local function getChildBtn(root, childName)
    if root.EditName == childName then
        return root
    end
    return root:FindChildByEditName(childName, true)
end

function AccordionExt.New(scrollPan, menuCanvas, menuBtnName, itemBtnName, selectFunc, clickLockFunc, isMutexItemMenu, autoSelectFirstItem, isHorizontal, animate)
    local obj = {}
    setmetatable(obj, AccordionExt)
    obj:_initArgs(scrollPan, menuCanvas, menuBtnName, itemBtnName, selectFunc, clickLockFunc, isMutexItemMenu, autoSelectFirstItem, isHorizontal, animate)
    obj:_init()
    return obj
end



function AccordionExt:setData(list)
    self._list = list
    self._selectMenuIdx = nil
    self._selectItemIdx = nil
    self._moving = false

    local y = 0
    for i,v in ipairs(list) do
        local menuData = self._menuList[i]
        if not menuData then
            local menuCanvas = self._menuCanvas:Clone()
            self._scrollPan:AddNormalChild(menuCanvas)
            menuData = {
                isOpen = true,
                node = menuCanvas,
                menuNode = menuCanvas:FindChildByEditName(self._menuNodeName, true),
                itemNodes = {menuCanvas:FindChildByEditName(self._itemNodeName, true)},
            }
            menuData.itemBtns = {getChildBtn(menuData.itemNodes[1], self._itemBtnName)}
            menuData.menuBtn = getChildBtn(menuData.menuNode, self._menuBtnName)
            menuData.menuBtn.TouchClick = self._self__onMenuClick
            table.insert(self._menuList, menuData)
        end
        if self._isHorizontal then
            menuData.node.X = y
            menuData.node.Y = 0
        else
            menuData.node.X = 0
            menuData.node.Y = y
        end
        menuData.idx = i
        self:onInitMenu(menuData.menuNode, menuData.menuBtn, v)
        self:_closeMenu(menuData)
        y = y + menuData.node[self._PH]
        menuData.menuNode.UserTag = i * INDEX_WEIGHT
        menuData.menuBtn.UserTag = i * INDEX_WEIGHT
    end

    for i=#self._menuList, #list + 1, -1  do
        self._menuList[i].node:RemoveFromParent(true)
        table.remove(self._menuList, i)
    end
end

function AccordionExt:getSelectIdx()
    return self._selectMenuIdx, self._selectItemIdx, self._openMenuIdx
end

function AccordionExt:refreshMenuAndItem()
    if not self._list then return end

    local menuData = self._menuList[self._openMenuIdx]
    local data = self._list[self._openMenuIdx]
    self:onRefreshMenu(menuData.menuNode, menuData.menuBtn, data)
    if self._selectItemIdx then
        local itemNode = menuData.itemNodes[self._selectItemIdx]
        local itemBtn = menuData.itemBtns[self._selectItemIdx]
        self:onRefreshItem(itemNode, itemBtn, data.items[self._selectItemIdx])
    end
end


function AccordionExt:selectItem(menuIdx, itemIdx)
    if not menuIdx or menuIdx < 1 or menuIdx > #self._list then return end

    local data = self._list[menuIdx]
    if data.isLock then return end
    if not itemIdx and not self._isMutexItemMenu and self._autoSelectFirstItem and data.items and #data.items > 0 then
        itemIdx = self:_getPreferredItemIdx(data, menuIdx)
    end
    if itemIdx then
        if not data.items or itemIdx < 1 or itemIdx > #data.items then
            return
        end
        if data.items[itemIdx].isLock then
            return
        end
    end
    self._moving = false

    local menuData = self._menuList[menuIdx]
    if self._openMenuIdx and menuIdx ~= self._openMenuIdx then
        self:_closeMenu(self._menuList[self._openMenuIdx])
        self._openMenuIdx = nil
        self._selectMenuIdx = nil
        self._selectItemIdx = nil
    end
    self:_openMenu(menuData)
    self:_adjustMenuPosition(1)
    self._openMenuIdx = menuIdx
    self._selectMenuIdx = menuIdx
    if self._selectItemIdx then
        local oldItemNode = menuData.itemNodes[self._selectItemIdx]
        local oldItemBtn = menuData.itemBtns[self._selectItemIdx]
        self:onUnselectItem(oldItemNode, oldItemBtn, data.items[self._selectItemIdx])
        self._selectItemIdx = nil
    end

    local y = menuData.node[self._PY]
    local selectData = data

    if itemIdx then
        self._selectItemIdx = itemIdx
        local itemNode = menuData.itemNodes[self._selectItemIdx]
        y = y + itemNode[self._PY]
        selectData = data.items[itemIdx]
        self:onSelectItem(itemNode, menuData.itemBtns[itemIdx], selectData)
        if self._isMutexItemMenu then
            self._selectMenuIdx = nil
            self:onUnselectMenu(menuData.menuNode, menuData.menuBtn, self._list[menuIdx])
        end
    end

    local pos = nil
    local scrollable = self._scrollPan.Scrollable
    local min, max, value = nil, nil, y
    if self._isHorizontal then
        min = -scrollable.Container.X
        max = scrollable.Container.X + scrollable.ScrollRect2D.width
        pos = Vector2.New(y, 0)
    else
        min = -scrollable.Container.Y
        max = scrollable.Container.Y + scrollable.ScrollRect2D.height
        pos = Vector2.New(0, y)
    end
    if value < min or value > max then
        self._scrollPan.Scrollable:LookAt(pos, true)
    end
    return selectData, menuIdx, itemIdx
end

function AccordionExt:destroy()
    if self._itemNodeCacheList then
        for _,v in ipairs(self._itemNodeCacheList) do
            v:Dispose()
        end
        self._itemNodeCacheList = nil
    end

    
    setmetatable(self, nil)
    for k,v in pairs(self) do
        self[k] = nil
    end
end

function AccordionExt:_onMenuClick(sender)
    local menuIdx = math.floor(sender.UserTag / INDEX_WEIGHT)
    local data = self._list[menuIdx]
    local menuData = self._menuList[menuIdx]
    if self._selectMenuIdx == menuIdx and self._isMutexItemMenu then
        
        self:onSelectMenu(menuData.menuNode, menuData.menuBtn, data)
        return
    end

    if self._moving then
        if self._selectMenuIdx == menuIdx then
            self:onSelectMenu(menuData.menuNode, menuData.menuBtn, data)
        else
            self:onUnselectMenu(menuData.menuNode, menuData.menuBtn, data)
        end
        return
    end

    if data.isLock then
        self:onUnselectMenu(menuData.menuNode, menuData.menuBtn, data)
        if data.isLock and self._clickLockFunc then
            self._clickLockFunc(data, menuIdx)
        end
        return
    end
    
    
    if self._openMenuIdx and self._selectMenuIdx == menuIdx then
        self:_closeMenu(self._menuList[self._openMenuIdx])
        self._openMenuIdx = nil
        self:_adjustMenuPosition(menuIdx)
        return
    end

    
    if not self._openMenuIdx then
        
        self._selectMenuIdx = nil
        self._selectItemIdx = nil
    end
    local oldIdx = self._openMenuIdx
    if self._openMenuIdx and self._openMenuIdx ~= menuIdx then
        self:_closeMenu(self._menuList[self._openMenuIdx])
        self._selectItemIdx = nil
    end

    
    if self._selectItemIdx then
        local itemNode = menuData.itemNodes[self._selectItemIdx]
        local itemBtn = menuData.itemBtns[self._selectItemIdx]
        local idx = self._selectItemIdx
        self._selectItemIdx = nil
        self:onUnselectItem(itemNode, itemBtn, data.items[idx])
    end

    self._openMenuIdx = menuIdx
    self._selectMenuIdx = menuIdx

    local menuData = self._menuList[menuIdx]
    local selectData = data
    local itemIdx = nil

    if data.items and #data.items > 0 then
        self:_openMenu(menuData, self._animate)
        if self._autoSelectFirstItem then
            if self._isMutexItemMenu then
                
                self._selectMenuIdx = nil
                self:onUnselectMenu(menuData.menuNode, menuData.menuBtn, selectData)
            end
            itemIdx = self:_getPreferredItemIdx(selectData, menuIdx)
            self._selectItemIdx = itemIdx
            selectData = data.items[itemIdx]
            self:onSelectItem(menuData.itemNodes[itemIdx], menuData.itemBtns[itemIdx], selectData)
        end
    end
    self:_adjustMenuPosition(math.min(oldIdx or #self._menuList, menuIdx))
    if self._selectFunc then
        self._selectFunc(selectData, menuIdx, itemIdx)
    end
end

function AccordionExt:_onItemClick(sender)
    local itemIdx = sender.UserTag % INDEX_WEIGHT
    local menuIdx = math.floor(sender.UserTag / INDEX_WEIGHT)
    local data = self._list[menuIdx]
    
    
    local menuData = self._menuList[menuIdx]
    if self._selectItemIdx == itemIdx then
        self:onSelectItem(menuData.itemNodes[itemIdx], menuData.itemBtns[itemIdx], data.items[itemIdx])
        return
    end

    if self._moving then
        self:onUnselectItem(menuData.itemNodes[itemIdx], menuData.itemBtns[itemIdx], data.items[itemIdx])
        return
    end

    if data.items[itemIdx].isLock then
        self:onUnselectItem(menuData.itemNodes[itemIdx], menuData.itemBtns[itemIdx], data.items[itemIdx])
        if self._clickLockFunc then
            self._clickLockFunc(data.items[itemIdx], menuIdx, itemIdx)
        end
        return
    end

    
    if self._isMutexItemMenu and self._selectMenuIdx then
        self._selectMenuIdx = nil
        self:onUnselectMenu(menuData.menuNode, menuData.menuBtn, data)
    end

    if self._selectItemIdx then
        local oldIdx = self._selectItemIdx
        self:onUnselectItem(menuData.itemNodes[oldIdx], menuData.itemBtns[oldIdx], data.items[oldIdx])
    end

    self._selectItemIdx = itemIdx
    if self._selectFunc then
        self._selectFunc(data.items[itemIdx], menuIdx, itemIdx)
    end
end

function AccordionExt:_closeMenu(menuData, tween)
    self:onUnselectMenu(menuData.menuNode, menuData.menuBtn, self._list[menuData.idx])
    if not menuData.isOpen then return end

    for i,v in ipairs(menuData.itemNodes) do
        self:_releaseItemNode(v)
    end
    menuData.itemNodes = {}
    menuData.itemBtns = {}
    menuData.isOpen = false
    menuData.node.Height = menuData.menuNode.Height
end

function AccordionExt:_openMenu(menuData, tween)
    self:onSelectMenu(menuData.menuNode, menuData.menuBtn, self._list[menuData.idx])
    if menuData.isOpen then return end

    menuData.isOpen = true

    local data = self._list[menuData.idx]
    if not data.items or #data.items == 0 then return end

    self._moving = not not tween

    local y = menuData.menuNode[self._PH]
    local originY = y
    for i,v in ipairs(data.items) do
        y = y + self._itemGap
        local itemNode, itemBtn = self:_getItemNode()
        menuData.node:AddChildAt(itemNode, i - 1)
        table.insert(menuData.itemNodes, itemNode)
        table.insert(menuData.itemBtns, itemBtn)
        self:onInitItem(itemNode, itemBtn, v)
        itemNode[self._PY] = y
        itemNode.UserTag = menuData.idx * INDEX_WEIGHT + i
        itemBtn.UserTag = menuData.idx * INDEX_WEIGHT + i
        y = y + itemNode[self._PH]
    end
    menuData.node[self._PH] = y + self._lastItemGap

    if self._moving then
        local time = 0.3
        local action = DelayAction()
        action.Duration = time
        action.ActionFinishCallBack = function()
            self._moving = false
        end
        menuData.node:AddAction(action)

        for i,v in ipairs(menuData.itemNodes) do
            action = MoveAction.New()
            action.TargetX = v.X
            action.TargetY = v.Y
            action.Duration = time
            v[self._PY] = originY
            v:AddAction(action)
        end
    end
end

function AccordionExt:_adjustMenuPosition(startIdx)
    startIdx = startIdx or 1
    local y = self._menuList[startIdx].node[self._PY] + self._menuList[startIdx].node[self._PH]
    for i = startIdx + 1, #self._menuList do
        local node = self._menuList[i].node
        node[self._PY] = y
        y = y + node[self._PH]
    end
end

function AccordionExt:_releaseItemNode(node)
    node:RemoveFromParent(false)
    node.Visible = false
    table.insert(self._itemNodeCacheList, node)
end

function AccordionExt:_getItemNode()
    local node = table.remove(self._itemNodeCacheList)
    if not node then
        node = self._menuCanvas:FindChildByEditName(self._itemNodeName, true):Clone()
    end
    node.Visible = true
    local btn = node
    if self._itemNodeName ~= self._itemBtnName then
        btn = node:FindChildByEditName(self._itemBtnName, true)
    end
    btn.TouchClick = self._self__onItemClick
    return node, btn
end

function AccordionExt:_getPreferredItemIdx(data, menuIdx)
    local itemIdx = 1
    if type(self._autoSelectFirstItem) == "function" then
        itemIdx = self._autoSelectFirstItem(data, menuIdx)
    end
    itemIdx = itemIdx or 1
    if itemIdx < 1 then itemIdx = 1
    elseif itemIdx > #data.items then itemIdx = #data.items
    end
    return itemIdx
end

function AccordionExt:_initGap()
    local menuNode = self._menuCanvas:FindChildByEditName(self._menuNodeName, true)
    local itemNode = self._menuCanvas:FindChildByEditName(self._itemNodeName, true)
    self._itemGap = itemNode[self._PY] - menuNode[self._PY] - menuNode[self._PH]
    self._lastItemGap = self._menuCanvas[self._PH] - itemNode[self._PY] - itemNode[self._PH]
    
    
    
    
    
    
    
end

local function getFirstChildName(root, deepChildName)
    local child = root:FindChildByEditName(deepChildName, true)
    while root ~= child.Parent do
        child = child.Parent
    end
    return child.EditName
end

function AccordionExt:_initArgs(scrollPan, menuCanvas, menuBtnName, itemBtnName, selectFunc, clickLockFunc, isMutexItemMenu, autoSelectFirstItem, isHorizontal, animate)
    local args = {
        scrollPan = scrollPan,
        menuCanvas = menuCanvas or false,
        menuBtnName = menuBtnName or false,
        itemBtnName = itemBtnName or false,
        selectFunc = selectFunc or false,
        clickLockFunc = clickLockFunc or false,
        isMutexItemMenu = isMutexItemMenu or false,
        autoSelectFirstItem = autoSelectFirstItem or false,
        isHorizontal = isHorizontal or false,
        animate = animate or false,
    }

    local tmp = args
    if type(scrollPan) == "table" then
        tmp = scrollPan
    end
    for k,v in pairs(args) do
        self["_" .. k] = tmp[k]
    end
end

function AccordionExt:_init()
    self._PY = self._isHorizontal and "X" or "Y"
    self._PH = self._isHorizontal and "Width" or "Height"
    self._moving = false
    self._menuCanvas.Visible = false

    self._menuNodeName = getFirstChildName(self._menuCanvas, self._menuBtnName)
    self._itemNodeName = getFirstChildName(self._menuCanvas, self._itemBtnName)

    self:_initGap()

    
    self._menuList = {}
    self._itemNodeCacheList = {}
    
    self._list = nil
    self._openMenuIdx = nil
    self._selectMenuIdx = nil
    self._selectItemIdx = nil

    self.onInitMenu = AccordionExt.onInitNode
    self.onSelectMenu = AccordionExt.onSelectNode
    self.onUnselectMenu = AccordionExt.onUnselectNode
    self.onInitItem = AccordionExt.onInitNode
    self.onSelectItem = AccordionExt.onSelectNode
    self.onUnselectItem = AccordionExt.onUnselectNode
    self.onRefreshMenu = AccordionExt.onRefreshNode
    self.onRefreshItem = AccordionExt.onRefreshNode
end


function AccordionExt.onInitNode(self, node, btn, data)
    node.IsGray = not not data.isLock
    btn.Text = data.name
    btn.IsChecked = false
end
function AccordionExt.onSelectNode(self, node, btn, data)
    btn.IsChecked = true
end
function AccordionExt.onUnselectNode(self, node, btn, data)
    btn.IsChecked = false
end

function AccordionExt.onRefreshNode(self, node, btn, data)
end

return AccordionExt
