--
-- Author: LaoY
-- Date: 2018-07-12 15:44:47
--
SelectRolePanel = SelectRolePanel or class("SelectRolePanel", BasePanel)
local SelectRolePanel = SelectRolePanel

function SelectRolePanel:ctor()
    self.abName = "login"
    self.image_abName = "login_image"
    self.assetName = "SelectRolePanel"
    self.layer = "UI"

    self.use_background = false
    self.change_scene_close = true
    self.use_open_sound = false

    self.model = LoginModel:GetInstance()
    self.SceneMgr = LoginController:GetInstance():GetCreateRoleSceneMgr()

    self.roleModels = {}
    self.item_list = {}

    if self.open_login_scene_event_id then
        GlobalEvent:RemoveListener(self.open_login_scene_event_id)
        self.open_login_scene_event_id = nil
    end
end

function SelectRolePanel:dctor()

    for _, v in pairs(self.roleModels) do
        v:destroy()
    end
    self.roleModels = nil
    self.SceneMgr = nil
end

function SelectRolePanel:Open()
    BasePanel.Open(self)
end

function SelectRolePanel:LoadCallBack()
    self.nodes = {
        "RoleItemPrefab", "drag_mask",
        "left_con/con", "right_con/btn_enter_game", "right_con/OccupationBG",
        "left_con", "top_con", "right_con", "right_con/returnBtn",
        "right_con/role_text",
    }
    self:GetChildren(self.nodes)
    SetLocalPositionXY(self.con, 133.5, 228.4)
    SetAlignType(self.left_con.transform, bit.bor(AlignType.Left, AlignType.Null))
    SetAlignType(self.right_con.transform, bit.bor(AlignType.Right, AlignType.Null))
    SetAlignType(self.top_con.transform, bit.bor(AlignType.Top, AlignType.Null))

    self.OccupationBG = GetImage(self.OccupationBG)
    self.role_text = GetImage(self.role_text)
    self.itemPrefab = self.RoleItemPrefab.gameObject

    SetVisible(self.RoleItemPrefab, false)

    self:AddEvent()
    SoundManager:GetInstance():PlayById(2)
end

local lastX = 0
function SelectRolePanel:AddEvent()
    local function call_back(target, x, y)
        local roe_data = self.model.login_role_list[self.index]
        if not roe_data then
            return
        end
        local role_id = roe_data.id
        local role_name = roe_data.name
        LoginController:GetInstance():RequestEnterGame(role_id, role_name)
    end
    AddButtonEvent(self.btn_enter_game.gameObject, call_back, nil, nil, 2.0)

    if AppConfig.QuickEnterGame then
        self.index = 1
        local function step()
            if self.is_dctored then
                return
            end
            call_back()
        end
        GlobalSchedule:StartOnce(step, 0.3)
    end

    local function call_back()
        self:Close()
    end
    self.event_id = GlobalEvent:AddListener(EventName.GameStart, call_back)

    local call_back = function(target, x, y)
        if lastX == 0 then
            lastX = x;
            return ;
        end
        local x1 = x - lastX;
        self.roleModels[self.index].transform:Rotate(0, -x1, 0);
        lastX = x;
    end
    AddDragEvent(self.drag_mask.gameObject, call_back);
    --
    local call_back = function(target, x, y)
        lastX = 0;
    end

    AddDragEndEvent(self.drag_mask.gameObject, call_back);

    local function call_back()
        --if not AppConfig.Debug then
        --    PlatformManager:GetInstance():logout()
        --end
        -- LoginController.GetInstance():RequestLeaveGame(true)
        NetManager:GetInstance():StopReConnect()
        AppConfig.GameStart = false
        GlobalEvent:Brocast(EventName.GameReset)
        GlobalEvent:Brocast(LoginEvent.OpenLoginPanel)
        NetManager:GetInstance():CloseConnect()
    end
    AddButtonEvent(self.returnBtn.gameObject, call_back)
end

function SelectRolePanel:OpenCallBack()
    self:UpdateView()
end

function SelectRolePanel:RefreshRole(res_id, lastIndex, index)

    ---将上个角色动画恢复并隐藏
    if (lastIndex and self.roleModels[lastIndex]) then
        local role = self.roleModels[lastIndex]
        self:PlayDefaultAnimation(role)
        role:SetVisible(false)
    end

    if (self.roleModels[index]) then
        SetVisible(self.roleModels[index], true)
        self:PlayShowAnimation(self.roleModels[index])
    else
        local config = LoginConst:GetConfigById(res_id)
        ---默认动画
        local defaultActions = LoginConst:GetDefaultAction(config)
        local role_data = self.model.login_role_list[self.index]
        local model_config = {}
        model_config.is_show_effect = true
        model_config.is_show_wing = true
        model_config.config = config
        local role_info = role_data
        role_info.index = index
        role_info.config = config
        role_info.layer = LayerManager.BuiltinLayer.Terria
        role_info.animation = defaultActions
        --res_id = res_id,
        self.roleModels[index] = UIRoleModel(self.roleContainer, handler(self, self.LoadModelCallBack), role_info, model_config)
    end
end

function SelectRolePanel:LoadModelCallBack(index)

    local role = self.roleModels[index]

    if (role) then
        local config = role.data.config
        local r = role.transform

        SetLocalPosition(r, config.position.x, config.position.y, config.position.z);
        SetLocalRotation(r, 0, 0, 0);
        SetLocalScale(r, 1);

        self:PlayShowAnimation(role)
    end
end

function SelectRolePanel:SelectItemAgain(index)
    local role = self.roleModels[index]

    if (role and role.data.config) then
        ---展示动画最后一个状态名
        local lastShowAction = role.data.config.showActions[#role.data.config.showActions]
        ---选中时会连续播放动画
        ---如果直接切换，可能旧的动画序列会继续播放
        ---故要要检查动画已经播放到最后状态了
        if (role:CheckAnimatorState(lastShowAction)) then
            self:PlayDefaultAnimation(role)
            self:PlayShowAnimation(role)
        end
    end
end

---播放默认动画
function SelectRolePanel:PlayDefaultAnimation(role)
    --if (role and role.data.config) then
    local config = role.data.config
    local defaultAction = config.defaultActions and config.defaultActions[#config.defaultActions] or "idle2"
    role:PlayAnimation(defaultAction, true, defaultAction, 0)
    role:HideAllEffect()
    --end
end

---播放展示动画
function SelectRolePanel:PlayShowAnimation(role)
    --if (role and role.data.config) then
    local function step()
        local showActions = role.data.config.norShowActions
        if self.model.is_showed_one_off_anim then
            showActions = { "idle" }
        else
            self.model.is_showed_one_off_anim = true
        end
        role:PlayAnimationList(showActions, showActions[#showActions])
        role:ShowAllEffect()
    end
    GlobalSchedule:StartOnce(step, 0)
    --end
end

function SelectRolePanel:UpdateView()

    local function callback(index)
        if index == self.index then
            --self:SelectItemAgain(index)
            return
        end
        for k, item in pairs(self.item_list) do
            item:SetSelectState(k == index)
        end
        local lastIndex = self.index
        self.index = index
        local info = clone(self.model.login_role_list[self.index])

        if info then
            local wake = info.wake
            wake = wake or 1
            wake = wake == 0 and 1 or wake
            local icon_str = string.format("role_wake_icon_%d_%d", wake, info.gender)
            SetVisible(self.role_text, true)
            SetVisible(self.OccupationBG, true)
            lua_resMgr:SetImageTexture(self, self.role_text, "iconasset/icon_login", icon_str, true)
            lua_resMgr:SetImageTexture(self, self.OccupationBG, "iconasset/icon_login", 'role_wake_icon_bg_' .. info.gender, true)
            local res_id = info.gender == 1 and 40001 or 40002

            ----创角的Role已经改为整体的了
            --local weapon_res_id = res_id
            --local wing_res_id = 0

            --if info.figure["fashion.clothes"] and info.figure["fashion.clothes"].show then
            --    res_id = info.figure["fashion.clothes"].model
            --end
            --
            --if info.figure.wing and info.figure.wing.show then
            --    wing_res_id = info.figure.wing.model
            --end

            self:RefreshRole(res_id, lastIndex, index)
        end
    end

    local list = self.model.login_role_list
    local max_lv = 0
    local index = 1
    -- for i = 1, 4 do
    for i = 1, 1 do
        local vo = list[i]
        local item = self.item_list[i]
        if not item then
            item = SelectRoleItem(newObject(self.itemPrefab), self.con)
            SetVisible(item.transform, true)
            self.item_list[i] = item
            local x = 0
            local y = (i - 1) * -130
            item:SetPosition(x, y)
            item:SetCallBack(callback)
        end
        item:SetData(i, vo)
        if vo and vo.level > max_lv then
            index = i
            max_lv = vo.level
        end
    end

    callback(index)
end

function SelectRolePanel:CloseCallBack()
    for k, v in pairs(self.item_list) do
        v:destroy()
    end
    self.item_list = {}

    if self.event_id then
        GlobalEvent:RemoveListener(self.event_id)
        self.event_id = nil
    end
end