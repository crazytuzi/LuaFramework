LoveTeamWindow = LoveTeamWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function LoveTeamWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.loveteamwindow
    self.name = "LoveTeamWindow"
    self.resList = {
        {file = AssetConfig.loveteamwindow, type = AssetType.Main}
        , {file = AssetConfig.heads, type = AssetType.Dep}
        , {file = AssetConfig.chat_window_res, type = AssetType.Dep}
    }

    -----------------------------------------
    self.data = nil
    self.timerId = nil
    -----------------------------------------
    self.listener = function(type) self:Update(type) end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function LoveTeamWindow:__delete()
    self:OnHide()

    self:AssetClearAll()
end

function LoveTeamWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.loveteamwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Main/FriendButton"):GetComponent(Button).onClick:AddListener(function() self:FriendButtonClick() end)
    self.transform:Find("Main/TeamButton"):GetComponent(Button).onClick:AddListener(function() self:TeamButtonClick() end)

    self.transform:Find("Main/bg"):GetComponent(Image).sprite = ChatManager.Instance.model.assetWrapper:GetSprite(AssetConfig.chat_window_res, "ChatItemBg1")
    self.transform:Find("Main/bg"):GetComponent(Image).type = 1

    self:OnShow()
end

function LoveTeamWindow:Close()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    self.model:CloseLoveTeamWindow()
    -- WindowManager.Instance:CloseWindow(self)
end

function LoveTeamWindow:OnShow()
    TeamManager.Instance.OnUpdateRecruitDataList:Add(self.listener)

    self:Update("add")
end

function LoveTeamWindow:OnHide()
    TeamManager.Instance.OnUpdateRecruitDataList:Remove(self.listener)
end

function LoveTeamWindow:Update(type)
    if type == "add" then
        for key, value in pairs(TeamManager.Instance.recruitDataList) do
            self.data = value
            self.transform:Find("Main/Name"):GetComponent(Text).text = value.name
            -- self.transform:Find("Main/TalkText"):GetComponent(Text).text = "丘比特告诉我您曾经请他帮助您物色一名好友，不知我是否有这份荣幸与您认识一下？要是现在一起去做情缘任务就更加完美了^_^"
            self.transform:Find("Main/Head"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.heads, value.classes .. "_" .. value.sex)
            if self.timerId ~= nil then
                LuaTimer.Delete(self.timerId)
                self.timerId = nil
            end
            self.timerId = LuaTimer.Add(120000, 120000, function() self:Close() end)
            return
        end
    elseif type == "del" then
        local del_mark = true
        for key, value in pairs(TeamManager.Instance.recruitDataList) do
            if self.data ~= nil and self.data.id == value.id then
                del_mark = false
            end
        end
        if del_mark then self:Close() end
    end
end

function LoveTeamWindow:FriendButtonClick()
    FriendManager.Instance:Require11804(self.data.rid, self.data.platform, self.data.zone_id)
end

function LoveTeamWindow:TeamButtonClick()
    TeamManager.Instance:Send11704(self.data.rid, self.data.platform, self.data.zone_id)
    self:Close()
end