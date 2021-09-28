local ButtonManager = {}
ButtonManager.__index = ButtonManager


----------------------- singleton --------------------

local _instance;
function ButtonManager.getInstance()
    if not _instance then
        _instance = ButtonManager:new()
    end

    return _instance
end

function ButtonManager:getInstanceNotCreate( )
    return _instance
end

function ButtonManager.removeInstance()
	_instance = nil
end

function ButtonManager.Destroy()
    if _instance then 
        require "ui.buttons.buttondlg".DestroyDialog()
        _instance = nil
    end
end
-----------------------------------------------------

function ButtonManager:new()
    local self = {}
    setmetatable(self, ButtonManager)

    self.m_btnList = {}
    self.m_btnList[1] = {}
    self.m_btnList[2] = {}
    self.m_btnList[3] = {}

    self.m_sortFunc = function(a, b) return a.bm_sort < b.bm_sort end
    self.m_dlg = require "ui.buttons.buttondlg"

    return self
end

function ButtonManager:AddButton( button )
    if button.bm_show == 0 then
        button:SetVisible(false)
        return
    end
    for i,v in ipairs(self.m_btnList[button.bm_rowIndex]) do
        if button == v then return end
    end
    print("ButtonManager AddButton "..button:GetLayoutFileName())
    self.m_dlg:getInstance():GetWindow():addChildWindow(button:GetWindow())
 
    button:GetWindow():setProperty("ClippedByParent", "False")

    table.insert(self.m_btnList[button.bm_rowIndex], button)
    self:RefreshPositions(button.bm_rowIndex)
end

function ButtonManager:RemoveButton( button )
    for i,v in ipairs(self.m_btnList[button.bm_rowIndex]) do
        if button == v then
            table.remove(self.m_btnList[button.bm_rowIndex], i)

            self:RefreshPositions(button.bm_rowIndex)
            break
        end
    end
end

function ButtonManager:RefreshPositions( row )
    print("ButtonManager RefreshPositions "..tostring(row))

    for i = row, 3 do
        local currList = self.m_btnList[i]
        if #currList ~= 0 then
            table.sort( currList, self.m_sortFunc )
            
            local currY = self.m_dlg:getInstance():GetY(i)
            local currX = self.m_dlg:getInstance():GetX(i)
            for i,v in ipairs(currList) do
                local width = v:GetWindow():getPixelSize().width + 5
                v:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, currX), CEGUI.UDim(0, currY)))
                -- print("X "..tostring(currX).." Y "..tostring(currY))
                currX = currX - width
            end
        end
    end
end

function ButtonManager:DestroyButtons()
    for i,v in ipairs(self.m_btnList) do
        for j,k in ipairs(v) do
            k.DestroyDialog()
        end
    end
end

return ButtonManager
