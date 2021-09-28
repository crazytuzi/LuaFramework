local Tabs = class("Tabs")


--checkCallback 选中回调
function Tabs:ctor(groupId, container, checkCallback, uncheckedCallback)
    self._ctrls = {}
    self._groupId = groupId
    self._container = container
    self._checkCallback = checkCallback
    self._uncheckedCallback = uncheckedCallback
    self._checkBoxList = {}
    self._currentTabName = ""
    
    self._labelViews = {}
    self._labelUnCheckedName = {}
    
    --为了不一次性创建多了view
    self._groupNameList = {}
    self._container:registerCheckBoxGroupEvent(function(groupId, oldName, newName, widget )

        if groupId == self._groupId then
            -- callback
            if self._currentTabName ~= newName then
                --set view visible
                for btnName, _ in pairs(self._groupNameList) do
                    local view = self._ctrls[btnName]
                    if btnName == newName then

                        if type(view) ~= "string" and view ~= nil then
                            view:setVisible(true)   
                        end
                        if self._labelViews[btnName] ~= nil then
                            self._labelViews[btnName]:setVisible(true)
                        end
                        if self._labelUnCheckedName[btnName] then
                            self._labelUnCheckedName[btnName]:setVisible(false)
                        end

                    else
                        if type(view) ~= "string" and view ~= nil then
                            view:setVisible(false)   
                        end
                        if self._labelViews[btnName] ~= nil then
                            self._labelViews[btnName]:setVisible(false)
                        end
                        if self._labelUnCheckedName[btnName] then
                            self._labelUnCheckedName[btnName]:setVisible(true)
                            if self._checkBoxList[btnName]:isTouchEnabled() == false then
                                self._labelUnCheckedName[btnName]:setColor(Colors.TAB_GRAY)
                            else
                                self._labelUnCheckedName[btnName]:setColor(Colors.TAB_NORMAL)
                            end
                        end
                    end
                end
                if self._currentTabName  ~= nil and self._uncheckedCallback ~= nil then
                     self._uncheckedCallback(self._container, self._currentTabName)   
                end
                self._currentTabName = newName
                self._checkCallback(self._container, newName)
            end
        end
    end)
    
end


function Tabs:add(checkBtnName, view,labelName)
    self._ctrls[checkBtnName] = view
    self._checkBoxList[checkBtnName] = self._container:getCheckBoxByName(checkBtnName)
    if self._groupNameList[checkBtnName] == nil then
        self._groupNameList[checkBtnName] = checkBtnName
        self._container:addCheckBoxGroupItem(self._groupId, checkBtnName)
    end
    if labelName ~= nil and type(labelName) == "string" then
        self._labelViews[checkBtnName] = self._container:getLabelByName(labelName)
        self._labelViews[checkBtnName]:setColor(Colors.TAB_DOWN)
        self._container:enableLabelStroke(labelName, Colors.strokeBrown,2)
        self._labelUnCheckedName[checkBtnName] = self._container:getLabelByName(labelName .. "_0")
        if self._labelUnCheckedName[checkBtnName] ~= nil then
            self._labelUnCheckedName[checkBtnName]:setColor(Colors.TAB_NORMAL)
        end
    end
end

function Tabs:updateTab(checkBtnName, view)
    self._ctrls[checkBtnName] = view
end

--选中某个tab
function Tabs:checked(checkBtnName)
    self._container:setCheckStatus(self._groupId, checkBtnName)

end

function Tabs:getCurrentTabName()
    return self._currentTabName
end

return Tabs
