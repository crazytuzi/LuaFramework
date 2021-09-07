ReportModel = ReportModel or BaseClass(BaseModel)

function ReportModel:__init()
    self.window = nil
    self.zoneWindow = nil
end

function ReportModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function ReportModel:OpenWindow(args)
    if self.window == nil then
        self.window = ReportView.New(self)
    end
    self.window:Show(args)
end

function ReportModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function ReportModel:OpenZoneWindow(args)
    if self.zoneWindow == nil then
        self.zoneWindow = ReportViewZone.New(self)
    end
    self.zoneWindow:Show(args)
end

function ReportModel:CloseZoneWindow()
    if self.zoneWindow ~= nil then
        self.zoneWindow:DeleteMe()
        self.zoneWindow = nil
    end
end

--//type:1 为正常聊天举报  2：空间留言举报
function ReportModel:ReportChat(chatData,type)
    self.chatType = type
    if type == 1 then 
        self.chatData = chatData
        if next(chatData) then 
            ReportManager.Instance:Send14705(chatData[1].rid, chatData[1].platform, chatData[1].zone_id)
        end
    elseif type == 2 then
        self.chatData = chatData
        if next(chatData) then 
            ReportManager.Instance:Send14705(chatData.role_id, chatData.platform, chatData.zone_id)
        end
    end
end