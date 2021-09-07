-- ---------------------------------------
-- 道具系列子界面控制器
-- 管理道具，人物子界面
-- hosr
-- ---------------------------------------
BackpackItemModel = BackpackItemModel or BaseClass(BaseModel)

function BackpackItemModel:__init(mainModel)
    self.mainModel = mainModel
    self.name = "BackpackItemModel"
    self.rolePanel = nil
    self.itemPanel = nil
    self.attrPanel = nil

    self.currentIndex = 1
end

function BackpackItemModel:__delete()
    self:Close()
end

function BackpackItemModel:Close()
    self.currentIndex = 1
    if self.rolePanel ~= nil then
        self.rolePanel:DeleteMe()
        self.rolePanel = nil
    end
    if self.itemPanel ~= nil then
        self.itemPanel:DeleteMe()
        self.itemPanel = nil
    end
    if self.attrPanel ~= nil then
        self.attrPanel:DeleteMe()
        self.attrPanel = nil
    end
    self.mainModel = nil
end

function BackpackItemModel:Show()
    if self.rolePanel == nil then
        self.rolePanel = BackpackRolePanel.New(self)
        self.rolePanel.parent = self.mainModel.mainWindow.gameObject
    end
    self.rolePanel:Show()

    if self.mainModel.mainWindow.openArgs ~= nil then
        local index = self.mainModel.mainWindow.openArgs[2]
        index = index or 1
        self:ChangeSub(index)

        if self.mainModel.mainWindow.openArgs[3] == 1 then
            self:OnOpenRename()
        end
    else
        self:ChangeSub(self.currentIndex)
    end
end
function BackpackItemModel:Hiden()
    if self.rolePanel ~= nil then
        self.rolePanel:Hiden()
    end
    if self.attrPanel ~= nil then
        self.attrPanel:Hiden()
    end
    if self.itemPanel ~= nil then
        self.itemPanel:Hiden()
    end

    local newItemTab = BackpackManager.Instance.mainModel.newItemTab
    local idList = {}
    for id,v in pairs(newItemTab) do
        if v ~= nil then
            table.insert(idList, id)
        end
    end
    for _,id in ipairs(idList) do
        newItemTab[id] = nil
    end
end

function BackpackItemModel:OnHide()
    if self.rolePanel ~= nil then
        self.rolePanel:OnHide()
    end
end

function BackpackItemModel:ChangeSub(index)
    self.currentIndex = index
    if index == 1 then
        if self.itemPanel == nil then
            self.itemPanel = BackpackItemPanel.New(self)
            self.itemPanel.parent = self.mainModel.mainWindow.gameObject
        end
        self.itemPanel:Show()
        if self.attrPanel ~= nil then
            self.attrPanel:Hiden()
        end
    elseif index == 2 then
        if self.attrPanel == nil then
            self.attrPanel = BackpackAttrPanel.New(self)
            self.attrPanel.parent = self.mainModel.mainWindow.gameObject
        end
        self.attrPanel:Show()
        if self.itemPanel ~= nil then
            self.itemPanel:Hiden()
        end
    end
    self.rolePanel:UpdateSwitcher(index)
end

function BackpackItemModel:OpenAddPoint()
    self.mainModel:OpenAddPoint()
end

function BackpackItemModel:OnCloseRename()
    if self.rolePanel ~= nil and self.rolePanel.renamePanel ~= nil then
        self.rolePanel.renamePanel:Hiden()
    end
end

function BackpackItemModel:OnOpenRename()
    if self.rolePanel ~= nil then
        if self.rolePanel.renamePanel == nil then
            self.rolePanel.renamePanel = BackpackRenamePanel.New(self.mainModel.mainWindow, self)
        end
        self.rolePanel.renamePanel:Show()
    end
end

function BackpackItemModel:UnLocakGrid(changeCount)
    if self.itemPanel ~= nil then
        self.itemPanel.gridPanel:UnlockNewSlot(changeCount)
    end
end