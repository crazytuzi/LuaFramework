local Util = require "Zeus.Logic.Util"


local TabSwitchUIExt = {}
Util.WrapOOPSelf(TabSwitchUIExt)




function TabSwitchUIExt.New(tabs, uis, defalutTab, verifyFunc)
    local o = {}
    setmetatable(o, TabSwitchUIExt)
    o:_init(tabs, uis, defalutTab, verifyFunc)
    return o
end

function TabSwitchUIExt:setTabIdx(idx)
    self._tabs[idx].IsChecked = true
end

function TabSwitchUIExt:onEnter()
    if self.showingUI and not self.showingUI.running then
        self.showingUI:onEnter()
    end
end

function TabSwitchUIExt:onExit()
    if self.showingUI then
        self.showingUI:onExit()
    end
end

function TabSwitchUIExt:onDestroy()
    for _,v in ipairs(self._uis) do
        v:onDestroy()
    end
    self._uis = nil
end

function TabSwitchUIExt:_init(tabs, uis, defalutTab, verifyFunc)
    self._tabs = tabs
    self._uis = uis
    self._verifyFunc = verifyFunc
    self._defalutTab = defalutTab
    self._ignoreFirstTabChange = defalutTab == nil
    self.tabIdx = nil
    self.showingUI = nil
    Util.InitMultiToggleButton(self._self__onTabChange, defalutTab or tabs[1], tabs)
end

function TabSwitchUIExt:_onTabChange(tab)
    if self._ignoreFirstTabChange then
        self._ignoreFirstTabChange = false
        return
    end

    local idx = table.indexOf(self._tabs, tab)
    if not self._verifyFunc or self._verifyFunc(idx) then
        self.tabIdx = idx
        local ui = self._uis[idx]
        if ui ~= self.showingUI then
            if self.showingUI then
                self.showingUI:onExit()
            end
            self.showingUI = ui
            self.showingUI:onEnter()
        end
        return
    end

    
    if self.tabIdx then
        self._ignoreFirstTabChange = true
        self._tabs[self.tabIdx].IsChecked = true
        self._ignoreFirstTabChange = false
    end
end

return TabSwitchUIExt
