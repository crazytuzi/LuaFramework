-- ---------------------------------
-- 聊天大界面，置顶显示面版
-- ljh
-- ---------------------------------
ChatMainTopPanel = ChatMainTopPanel or BaseClass()

function ChatMainTopPanel:__init(model, parent)
    self.model = model
    self.parent = parent

    self.panel = nil
    self.isActive = false
end

function ChatMainTopPanel:SetData(data)
    if self.panel == nil or self.panel.panelType ~= data.panelType then
        if self.panel ~= nil then
            self.panel:DeleteMe()
            self.panel = nil
        end

        if data.panelType == 1 then
            self.panel = TruthordareChatTopPanel.New(self.model, self.parent)
        end
    end
    self.panel:SetData(data)
end

function ChatMainTopPanel:Clean()
    if self.panel ~= nil and self.panel.data ~= nil then
        local msg = self.model:GetTopPanelMsgById(self.panel.data.id)
        if msg == nil then
            self.panel:DeleteMe()
            self.panel = nil
        else
            self:SetActive(false)
        end
    end
end

function ChatMainTopPanel:SetActive(active)
    self.isActive = true
    if self.panel ~= nil then
        self.panel:SetActive(active)
    end
end