-- ---------------------------------------
-- 信息系列子界面控制器
-- 管理信息，称号子界面
-- hosr
-- ---------------------------------------
BackpackInfoModel = BackpackInfoModel or BaseClass(BaseModel)

function BackpackInfoModel:__init(mainModel)
    self.mainModel = mainModel

    self.info_panel = nil
    self.character = nil
    self.info_current_index = 0
end

function BackpackInfoModel:__delete()
    self:Close()
end

function BackpackInfoModel:Close()
    if self.info_panel ~= nil then
        self.info_panel:DeleteMe()
        self.info_panel = nil
    end
    if self.character ~= nil then
        self.character:DeleteMe()
        self.character = nil
    end
    self.mainModel = nil
end

function BackpackInfoModel:Show()
    -- print("------------------------------------到了角色信息展示了")
    if self.info_panel == nil then
        self.info_panel = InfoPanel.New(self)
        self.info_panel.parent = self.mainModel.mainWindow.gameObject.transform:Find("Main").gameObject
    else
        -- self.info_panel
    end
    self.info_panel:Show()

    -- if self.character == nil then
    --     self.character = BackpackCharacterPanel.New(self)
    --     self.character.parent = self.mainModel.mainWindow.gameObject
    -- else
    --     self.character:update_info()
    -- end
    -- self.character:Show()
end

function BackpackInfoModel:Hiden()
    if self.info_panel ~= nil then
        self.info_panel:Hiden()
    end

    if self.character ~= nil then
        self.character:Hiden()
    end
end

function BackpackInfoModel:OnHide()
end
