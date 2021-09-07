-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
-- endregion
ConstellationModel = ConstellationModel or BaseClass(BaseModel)
function ConstellationModel:__init()
    self.openProfleHandler =
    function(data)
        if self.profileWin == nil then
            self.profileWin = ConstellationProfileWindow.New(self)
        end
        self.profileWin:Open(data)
    end
    self:AddHandler()
end

function ConstellationModel:__delete()

end

function ConstellationModel:AddHandler()
    EventMgr.Instance:AddListener(event_name.constellation_profile_update, self.openProfleHandler)
end

function ConstellationModel:OpenProfileWindow(args)
    local roldID;
    local platform;
    local zoneID;
    if args ~= nil and #args > 4 then
        roldID = tonumber(args[2])
        platform = tostring(args[3])
        zoneID = tonumber(args[4])
    else
        local roleData = RoleManager.Instance.RoleData;
        roldID = roleData.id
        platform = roleData.platform
        zoneID = roleData.zone_id
    end
    ConstellationManager.Instance:Send15206(roldID, platform, zoneID)
end

function ConstellationModel:CloseProfileWin(arg)
    if self.profileWin ~= nil then
        self.profileWin:OnClose(arg)
    end
end

-- 分享驾照到聊天
function ConstellationModel:OnShareFightScore()
    WindowManager.Instance:CloseCurrentWindow()
    ChatManager.Instance.model:ShowChatWindow()

    if self.chatExtPanel == nil then
        self.chatExtPanel = ChatExtMainPanel.New(self, MsgEumn.ExtPanelType.Chat, { showConstellationGuide = true }, 10)
    end
    self.chatExtPanel:Show( { otherOption = { showConstellationGuide = true }, tab = 10 })
end
function ConstellationModel:OpenHonorWindow(args)
    if self.honorWin == nil then
        self.honorWin = ConstellationHonorWindow.New(self)
    end
    self.honorWin:Open(args)
end

function ConstellationModel:CloseHonorWindow(args)
    if self.honorWin ~= nil then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.constellation_honor_window, false)
        self.honorWin = nil
    end
end

