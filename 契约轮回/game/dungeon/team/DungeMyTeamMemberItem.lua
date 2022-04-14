DungeMyTeamMemberItem = DungeMyTeamMemberItem or class("DungeMyTeamMemberItem",BaseCloneItem)
local DungeMyTeamMemberItem = DungeMyTeamMemberItem

function DungeMyTeamMemberItem:ctor(obj,parent_node,layer)
	DungeMyTeamMemberItem.super.Load(self)
end

function DungeMyTeamMemberItem:dctor()
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
	if self.UIRole ~= nil then
        self.UIRole:destroy()
        self.UIRole = nil
    end
    if self.ui_effect then
        self.ui_effect:destroy()
        self.ui_effect = nil
    end
end

function DungeMyTeamMemberItem:LoadCallBack()
	self.nodes = {
		"member_info/info/level_bg/level",
        "member_info/info/name",
        "member_info/info/vip/vip_1",
        "member_info/power/power_Text",
        "member_info/roleinfo",
        "member_info",
        "nomember",
        "nomember/btn_invite",
        "nomember/invite_tip",
        "member_info/roleModelCon",
        "member_info/info/role_icon",
        "member_info/info/level_bg",
        "member_info/roleModelCon/Camera",
        "member_info/member",
        "nomember/effect",
        "member_info/touch",
	}
	self:GetChildren(self.nodes)
	self.events = {}
	self.model = TeamModel.GetInstance()
	self:AddEvent()
	self.vipTxts = self.vip_1:GetComponent('Text')
    self.role_icon_img = self.role_icon:GetComponent('Image')
    self.level_bg_img = self.level_bg:GetComponent('Image')
    self.member = GetImage(self.member)
end

function DungeMyTeamMemberItem:AddEvent()
	local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(TeamInvitePanel):Open()
    end
    AddClickEvent(self.btn_invite.gameObject, call_back)

    local function call_back(target, x, y)
        if self.data.role.id ~= RoleInfoModel.GetInstance():GetMainRoleId() then
            if faker:GetInstance():is_fake(self.data.role.id) then
                local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.touch)
                panel:Open(self.data.role)
            else
                lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.touch):Open(self.data.role)
            end
        end
    end
    AddClickEvent(self.touch.gameObject, call_back)

    local function call_back()
        if self.model.auto_call then
            if not self.ui_effect then
                self.ui_effect = UIEffect(self.effect, 20426)
            end
        else
            if self.ui_effect then
                self.ui_effect:destroy()
                self.ui_effect = nil
            end
        end
    end
    self.events[#self.events + 1] = self.model:AddListener(TeamEvent.AutoCall, call_back)
end

function DungeMyTeamMemberItem:SetData(data, index)
	self.data = data
    self.index = index
    if self.is_loaded then
        self:UpdateView()
    end
end

function DungeMyTeamMemberItem:UpdateView()
    if self.data then
        SetVisible(self.member_info, true)
        SetVisible(self.nomember, false)
        local role = self.data.role
        local cur_lv, is_under_top = GetLevelShow(role.level)
        local head_str = "Lv"
        if not is_under_top then
            head_str = ""
        end
        cur_lv = head_str .. cur_lv
        self.level:GetComponent('Text').text = cur_lv
        self.power_Text:GetComponent('Text').text = self.model:FormatPower(role.power)

        self.vipTxts.text = string.format(ConfigLanguage.Common.Vip, role.viplv)
        local role_res_id = 11001
        if role.gender == 2 then
            self.name:GetComponent('Text').text = role.name
            lua_resMgr:SetImageTexture(self, self.role_icon_img, "common_image", "sex_icon_2")
            lua_resMgr:SetImageTexture(self, self.level_bg_img, "dungeon_image", "dunge_team_role_bg_2", true)

            role_res_id = 12001
        else
            self.name:GetComponent('Text').text = role.name
            lua_resMgr:SetImageTexture(self, self.role_icon_img, "common_image", "sex_icon_1")
            lua_resMgr:SetImageTexture(self, self.level_bg_img, "dungeon_image", "dunge_team_role_bg_1", true)

            role_res_id = 11001
        end

        if self.data.is_captain == 1 then
            lua_resMgr:SetImageTexture(self, self.member, 'dungeon_image', 'dunge_captain', true)
        else
            lua_resMgr:SetImageTexture(self, self.member, 'dungeon_image', 'dunge_member', true)
        end

        if self.UIRole then
            self.UIRole:destroy()
        end
        --self.UIRole = UIRoleModel(self.roleModelCon , handler(self , self.LoadModelCallBack),{res_id = role_res_id})
        self.UIRole = UIRoleCamera(self.roleModelCon, self.layer, role, 1, nil, self.index)
        if self.ui_effect then
            self.ui_effect:destroy()
            self.ui_effect = nil
        end
    else
        SetVisible(self.member_info, false)
        SetVisible(self.nomember, true)
        local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
        local is_captain = self.model:IsCaptain(main_role_id)
        SetVisible(self.btn_invite, is_captain)
        SetVisible(self.invite_tip, is_captain)

        self.level:GetComponent('Text').text = ""
        self.power_Text:GetComponent('Text').text = ""

        if self.UIRole ~= nil then
            self.UIRole:destroy()
        end

        self.UIRole = nil
        if self.model.auto_call then
            if not self.ui_effect then
                self.ui_effect = UIEffect(self.effect, 20426)
            end
        else
            if self.ui_effect then
                self.ui_effect:destroy()
                self.ui_effect = nil
            end
        end
    end
end