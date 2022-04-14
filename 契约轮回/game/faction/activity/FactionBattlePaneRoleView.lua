---
--- Created by R2D2.
--- DateTime: 2019/2/21 20:16
---
local FactionBattlePaneRoleView = {}

local lastX = 0

function FactionBattlePaneRoleView:SetUI(roleContainer, nameContent, nameBg, title, name, guildNameBg, guildName, noRole)
    self.RoleContainer = roleContainer
    --self.DragView = dragview
    --self.RoleImage = GetRawImage(roleContainer)

    self.NameContent = nameContent
    self.NameBgImage = GetImage(nameBg)

    self.TitleText = GetText(title)
    self.TitleOutline = title:GetComponent('Outline')
    self.NameText = GetText(name)
    self.NameOutline = name:GetComponent('Outline')

    self.GuildNameBgImage = GetImage(guildNameBg)
    self.GuildNameText = GetText(guildName)

    self.noRole = noRole

    self:InitUI()
end

function FactionBattlePaneRoleView:InitUI()
    -- local call_back = function(target, x, y)
    --     if (self.UIRole == nil or self.RoleImage.enabled == false) then return end

    --     if lastX == 0 then
    --         lastX = x;
    --         return;
    --     end
    --     local x1 = x - lastX;
    --     self.UIRole.transform:Rotate(0, -x1, 0);
    --     lastX = x;
    -- end
    -- AddDragEvent(self.DragView.gameObject, call_back);

    -- local call_back = function(target, x, y)
    --     lastX = 0;
    -- end
    -- AddDragEndEvent(self.DragView.gameObject, call_back);
end

function FactionBattlePaneRoleView:dctor()
    if self.UIRole ~= nil then
        self.UIRole:destroy()
        self.UIRole = nil
    end
end

function FactionBattlePaneRoleView:RefreshRole()
    local role = FactionBattleModel.GetInstance().Dominator


    --local role = FactionModel:GetInstance().members[1].base
    if (role == nil or role.id == 0) then
        self:NoRoleStyle()
    else
        self:ShowRoleInfo(role)
        self:ShowRole(role)
    end
end

function FactionBattlePaneRoleView:ShowRole(role)
    -- local res_id = role.gender == 1 and 11001 or 12001
    -- self.UIRole = UIRoleModel(self.RoleContainer, handler(self, self.LoadModelCallBack), { res_id = res_id });
    local config = {}
    config.trans_x = 500
    config.trans_y = 500
    config.trans_offset = {y = -26.06}
    self.UIRole = UIRoleCamera(self.RoleContainer, nil, role, 1, nil, nil, config)
end

function FactionBattlePaneRoleView:LoadModelCallBack()
    SetLocalPosition(self.UIRole.transform, -2135, -80, 600);--172.2
    SetLocalRotation(self.UIRole.transform, 10, 156.4, -1);
    --self.RoleImage.enabled = true
end

function FactionBattlePaneRoleView:ShowRoleInfo(role)

    local config = self:GetJobTitleConfig(role)
    if  config then
        local r, g, b, a = HtmlColorStringToColor(config.color)
        SetOutLineColor(self.TitleOutline, r, g, b, a)

        self.NameBgImage.enabled = true
        self.TitleText.text = config.name
        self.NameText.text = role.name
        --self.GuildNameBgImage.enabled = true
        --self.GuildNameText.text = ""
        self.GuildNameText.text =  role.gname .. "Guild Leader"
        self:RepositionTitle()

        SetVisible(self.noRole, false)
    else

        self.NameBgImage.enabled = true
        self.TitleText.text = ""
        self.NameText.text = role.name
        --self.GuildNameBgImage.enabled = true
        --self.GuildNameText.text = ""
        self.GuildNameText.text =  role.gname .. "Guild Leader"
        self:RepositionTitle()

        SetVisible(self.noRole, false)
    end

end

function FactionBattlePaneRoleView:RepositionTitle()
    SetSizeDeltaX(self.TitleText.transform, self.TitleText.preferredWidth)
    SetSizeDeltaX(self.NameText.transform, self.NameText.preferredWidth)
    local fullW = self.NameText.preferredWidth + self.TitleText.preferredWidth
    SetSizeDeltaX(self.NameContent, fullW)
    local firstX = (self.TitleText.preferredWidth - fullW) / 2

    SetLocalPositionX(self.TitleText.transform, firstX)
    SetLocalPositionX(self.NameText.transform, firstX + fullW / 2)
end

function FactionBattlePaneRoleView:NoRoleStyle()
    --self.RoleImage.enabled = false
    --self.NameBgImage.enabled = false
    self.TitleText.text = ""
    self.NameText.text = ""
    --self.GuildNameBgImage.enabled = false
    self.GuildNameText.text = "Guild Leader of the S Bracket winner"

    SetVisible(self.noRole, true)
end

function FactionBattlePaneRoleView:GetJobTitleConfig(role)
    local title_id = 0
    if role.figure.jobtitle then
        title_id = role.figure.jobtitle.model
        return Config.db_jobtitle[title_id]
    end
    return nil

end

return FactionBattlePaneRoleView