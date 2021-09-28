local Util = require "Zeus.Logic.Util"


local DynamicTabsExt = {}
Util.WrapOOPSelf(DynamicTabsExt)




function DynamicTabsExt.New(tab1OrTabs, tab2OrGap, onSelectCb, canCancelSelect, btnName, labelName)
    local o = {}
    setmetatable(o, DynamicTabsExt)
    o:_init(tab1OrTabs, tab2OrGap, onSelectCb, canCancelSelect, btnName, labelName)
    return o
end


function DynamicTabsExt:setTabDatas(list, defalutIdx)
    self._datas = list;
    for i,v in ipairs(list) do
        local tab = self._tabs[i]
        if not tab then
            local oldTab = self._tabs[i - 1]
            tab = oldTab:Clone()
            table.insert(self._tabs, tab)
            tab.Position2D = oldTab.Position2D + self._gap
            self._tabs[1].Parent:AddChildAt(tab, oldTab:GetChildIndex(oldTab) + 1)
        end

        tab.Visible = true
        local text = type(list[i]) == "string" and list[i] or list[i].text
        self.onInitTab(tab, self._btnName, self._labelName, text, list[i])
        self:_unselectTab(i)
        local btn = self._btnName and tab:FindChildByEditName(self._btnName, true) or tab
        btn.TouchClick = self._self__onTabClick
        btn.UserTag = i
    end
    for i = #list + 1, #self._tabs do
        self._tabs[i].Visible = false
    end

    self._tabIdx = nil
    if not self._canCancelSelect then
        defalutIdx = defalutIdx or 1
    end
    self:setTabIdx(defalutIdx)
end

function DynamicTabsExt:getTabs()
    local tabs = {}
    for i,v in ipairs(self._tabs) do
        if v.Visible then
            table.insert(tabs, v)
        end
    end
    return tabs
end

function DynamicTabsExt:getTabIdx()
    return self._tabIdx, self._datas[self._tabIdx]
end

function DynamicTabsExt:setTabIdx(idx)
    idx = idx or 0
    if idx == 0 and self._canCancelSelect then
        
        if self._tabIdx then
            self:_unselectTab(self._tabIdx)
        end
        self._tabIdx = nil
    else
        
        if idx < 1 or idx > #self._datas then return self._tabIdx end

        if self._tabIdx == idx then return self._tabIdx end

        if self._tabIdx then
            self:_unselectTab(self._tabIdx)
        end
        self._tabIdx = idx
        self:_selectTab(self._tabIdx)
    end
    
    return self._tabIdx
end

function DynamicTabsExt:_init(tab1OrTabs, tab2OrGap, onSelectCb, canCancelSelect, btnName, labelName)
    self._tabs = type(tab1OrTabs) == "table" and tab1OrTabs or {tab1OrTabs}
    self._onSelectCb = onSelectCb
    self._canCancelSelect = canCancelSelect
    self._datas = {}
    self._btnName = btnName
    self._labelName = labelName
    if #self._tabs > 1 then
        self._gap = self._tabs[2].Position2D - self._tabs[1].Position2D
    else
        if type(tab2OrGap) == "table" then
            self._gap = tab2OrGap
        else
            table.insert(self._tabs, tab2OrGap)
            self._gap = tab2OrGap.Position2D - self._tabs[1].Position2D
        end
    end
    
    self._tabIdx = nil

    self.onInitTab = DynamicTabsExt.onInitTab
    self.onSelectTab = DynamicTabsExt.onSelectTab
    self.onUnselectTab = DynamicTabsExt.onUnselectTab
end

function DynamicTabsExt:_onTabClick(sender)
    local idx = sender.UserTag
    if self._tabIdx == idx and self._canCancelSelect then
        
        self:_unselectTab(idx)
        idx = 0
    else
        self:_selectTab(idx)
    end
    idx = self:setTabIdx(idx)
    if self._onSelectCb then
        self._onSelectCb(idx, self._datas[idx], self._tabs[idx])
    end
end

function DynamicTabsExt:_selectTab(idx)
    local tab = self._tabs[idx]
    local data = self._datas[idx]
    local text = type(data) == "string" and data or data.text
    self.onSelectTab(tab, self._btnName, self._labelName, text, data)
end

function DynamicTabsExt:_unselectTab(idx)
    local tab = self._tabs[idx]
    local data = self._datas[idx]
    local text = type(data) == "string" and data or data.text
    self.onUnselectTab(tab, self._btnName, self._labelName, text, data)
end

function DynamicTabsExt.onInitTab(cvs, btnName, labelName, text, data)
    local label = labelName and cvs:FindChildByEditName(labelName, true) or cvs
    label.Text = text
end

function DynamicTabsExt.onSelectTab(cvs, btnName, labelName, text, data)
    local btn = btnName and cvs:FindChildByEditName(btnName, true) or cvs
    btn.IsChecked = true
end

function DynamicTabsExt.onUnselectTab(cvs, btnName, labelName, text, data)
    local btn = btnName and cvs:FindChildByEditName(btnName, true) or cvs
    btn.IsChecked = false
end

return DynamicTabsExt
