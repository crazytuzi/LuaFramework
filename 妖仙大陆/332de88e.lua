local Util = require "Zeus.Logic.Util"


local TabSwitchXMLExt = {}
Util.WrapOOPSelf(TabSwitchXMLExt)




function TabSwitchXMLExt.New(menu, tabs, tags, defalutTab, verifyFunc)
    local o = {}
    setmetatable(o, TabSwitchXMLExt)
    o:_init(menu, tabs, tags, defalutTab, verifyFunc)
    return o
end

function TabSwitchXMLExt:setTabIdx(idx)
    self._tabs[idx].IsChecked = true
end

function TabSwitchXMLExt:getTabIdx()
    return self._tabIdx
end

function TabSwitchXMLExt:getSubMenu()
    return self._subMenu, self._subObj
end

function TabSwitchXMLExt:_reloadMenu(idx)
    local subMenu, subObj = GlobalHooks.CreateUI(self._tags[idx], 0)
    if subMenu then
        self._menu:RemoveAllSubMenu()
        self._subMenu = subMenu
        self._subObj = subObj
        self._tabIdx = idx
        self._menu:AddSubMenu(subMenu)
        return true
    end
end

function TabSwitchXMLExt:onEnter()
    if self._tabIdx and not self._subMenu then
        self:_reloadMenu(self._tabIdx)
    end
end

function TabSwitchXMLExt:onExit()
    self._menu:RemoveAllSubMenu()
    self._subObj = nil
    self._subMenu = nil
end

function TabSwitchXMLExt:onDestroy()
    
    setmetatable(self, nil)
    for k,v in pairs(self) do
        self[k] = nil
    end
end

function TabSwitchXMLExt:_init(menu, tabs, tags, defalutTab, verifyFunc)
    self._menu = menu
    self._tabs = tabs
    self._tags = tags
    self._verifyFunc = verifyFunc
    self._defalutTab = defalutTab
    self._ignoreFirstTabChange = defalutTab == nil
    self._tabIdx = nil
    self._subObj = nil
    self._subMenu = nil
    Util.InitMultiToggleButton(self._self__onTabChange, defalutTab or tabs[1], tabs)
end

function TabSwitchXMLExt:_onTabChange(tab)
    if self._ignoreFirstTabChange then
        self._ignoreFirstTabChange = false
        return
    end

    local idx = table.indexOf(self._tabs, tab)
    if self._tabIdx == idx then return end

    if not self._verifyFunc or self._verifyFunc(idx) then
        if self:_reloadMenu(idx) then
            return
        end
    end

    
    if self._tabIdx then
        self._ignoreFirstTabChange = true
        self._tabs[self._tabIdx].IsChecked = true
        self._ignoreFirstTabChange = false
    end
end

return TabSwitchXMLExt
