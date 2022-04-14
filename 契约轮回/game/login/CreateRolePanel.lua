--
-- Author: LaoY
-- Date: 2018-07-12 20:10:02
--
CreateRolePanel = CreateRolePanel or class("CreateRolePanel", BasePanel)
local CreateRolePanel = CreateRolePanel

function CreateRolePanel:ctor()
    self.abName = "login"
    self.assetName = "CreateRolePanel"
    self.image_abName = "login_image"
    self.layer = "UI"

    self.use_background = false
    self.change_scene_close = true
    self.use_open_sound = false

    self.model = LoginModel:GetInstance()
    self.SceneMgr = LoginController:GetInstance():GetCreateRoleSceneMgr()

    self.roleResIdList = { 40001, 40002 }
    self.currRoleId = 0
    self.index = 2
    self.delaying = true
    self.UIRoles = {}
    self.itemList = {}

    if self.open_login_scene_event_id then
        GlobalEvent:RemoveListener(self.open_login_scene_event_id)
        self.open_login_scene_event_id = nil
    end
end

function CreateRolePanel:dctor()

    self:StopShowSchedule()
    self.SceneMgr:ResetCamera()

    for _, v in pairs(self.UIRoles) do
        v:destroy()
    end

    for _, v in pairs(self.itemList) do
        v:destroy()
    end
    self.itemList = {}

    self.UIRoles = nil
    self.SceneMgr = nil

    SoundManager:GetInstance():StopEffectSound()
end

function CreateRolePanel:Open()
    BasePanel.Open(self)
end

function CreateRolePanel:LoadCallBack()
    self.nodes = {
        "ItemPrefab", "mask",
        "right/OccupationIcon", "left", "left/con", "right/btn_create", "top", "bottom/input_text", "bottom/btn_roll", "right", "bottom","right/btn_return",
    }
    self:GetChildren(self.nodes)

    SetAlignType(self.left.transform, bit.bor(AlignType.Left, AlignType.Null))
    SetAlignType(self.right.transform, bit.bor(AlignType.Right, AlignType.Null))
    SetAlignType(self.top.transform, bit.bor(AlignType.Top, AlignType.Null))
    SetAlignType(self.bottom.transform, bit.bor(AlignType.Bottom, AlignType.Null))

    self.name = self.input_text:GetComponent("InputField")
    self.OccupationIconImage = GetImage(self.OccupationIcon)
    self.itemPrefab = self.ItemPrefab.gameObject
    SetVisible(self.ItemPrefab, false)

    SetVisible(self.bottom, false)

    ---隐藏按钮，避免模型未加载就被点击
    SetVisible(self.btn_return, false)
    --SetVisible(self.btn_create, false)

    self:LoadRoles()
    self:AddEvent()

    SoundManager:GetInstance():PlayById(2)
end

function CreateRolePanel:RefreshReturnBtn()
    if table.isempty(self.model.login_role_list) then
        SetVisible(self.btn_return, false)
    else
        SetVisible(self.btn_return, true)
    end

    SetVisible(self.btn_create, true)
end

function CreateRolePanel:LoadRoles()
    self:LoadRole(self.roleResIdList[2], 2)
    self:LoadRole(self.roleResIdList[1], 1)
end

function CreateRolePanel:LoadRole(res_id, index)
    local config = LoginConst:GetConfigById(res_id)
    local defaultActions = LoginConst:GetDefaultAction(config)

    self.UIRoles[index] = CreateRoleModel(self.roleContainer, handler(self, self.LoadModelCallBack),
            { res_id = res_id, index = index, config = config,
              layer = LayerManager.BuiltinLayer.Terria, animation = defaultActions })
end

function CreateRolePanel:LoadModelCallBack(index)
    local roleTransform = self.UIRoles[index].transform
    local pos = LoginConst.CareerConfig[index].position

    SetLocalPosition(roleTransform, pos.x, pos.y, pos.z);
    SetLocalRotation(roleTransform, 0, 0, 0);
    SetLocalScale(roleTransform, 1);

    if index ~= self.index then
        return
    end
    --[[index = index + 1
    if (index <= #self.roleResIdList) then
        self:LoadRole(self.roleResIdList[index], index)
    else--]]

    local res_Id = self.roleResIdList[self.index]
    self:ShowRole(res_Id)

    ---为避免快速切换使得资源加载失败，必要要等一点时间
    local function step()
        self:RefreshReturnBtn()
    end
    GlobalSchedule:StartOnce(step, 1)
    --end
end

function CreateRolePanel:ResetPos()

    if self.UIRoles == nil or #self.UIRoles == 0 then
        return
    end

    for i = 1, #self.UIRoles do
        if (i ~= self.index) then
            local config = self.UIRoles[i].data.config
            ---默认动画
            local aniName = config.defaultActions[#config.defaultActions]

            self.UIRoles[i]:PlayAnimation(aniName, true, aniName, 0)
            self.UIRoles[i]:HideAllEffect()
            self.SceneMgr:SetEffectVisible(config.showDelayEffect, false)
        end
    end

    self.SceneMgr:ResetCamera()
end

function CreateRolePanel:ShowRole(roleId)

    if (self.currRoleId ~= roleId) then

        self.currRoleId = roleId

        self:ResetPos()

        local role = self.UIRoles[self.index]
        local delay = role.data.config.showDelay
        local soundId = role.data.config.SoundId
        SoundManager:GetInstance():StopEffectSound()
        SoundManager:GetInstance():PlayById(soundId)

        if (delay > 0) then
            --self.delaying = true
            local hidePos = role.data.config.hidePosition
            SetLocalPosition(role.transform, hidePos.x, hidePos.y, hidePos.z)
            self.SceneMgr:SetEffectVisible(role.data.config.showDelayEffect, true)
        end

        local function step()
            if (delay > 0) then
                local pos = role.data.config.position
                SetLocalPosition(role.transform, pos.x, pos.y, pos.z)
            end
            local showActions = role.data.config.showActions
            role:PlayAnimationList(showActions, showActions[#showActions])
            role:ShowAllEffect()
            self.delaying = false
            self.SceneMgr:PlayCameraAnimation(tostring(roleId))
            self:ClickCallBack(self.index)
        end
        step()
        --self.delayShowSchedule = GlobalSchedule:StartOnce(step, delay)
    end
end

function CreateRolePanel:AddEvent()
    local function onCreateRole()
        local name = self.name.text
        -- if #name == 0 then
        --     logWarn("请输入名字")
        --     return
        -- end
        
        -- if not FilterWords:GetInstance():isSafe(name) then
        --     Notify.ShowText(ConfigLanguage.Mix.FeiFaZiFu)
        --     return
        -- end

        local info = LoginConst.CareerConfig[self.index]
        if not info then
            return
        end
        local career = info.career
        local gender = info.gender
        LoginController:GetInstance():RequestCreateRole(career, gender, name)
    end
    AddButtonEvent(self.btn_create.gameObject, onCreateRole)

    local function onRollName()
        self:RollName()
    end
    -- AddButtonEvent(self.btn_roll.gameObject, onRollName)

    local function call_back(target, x, y)
        if table.isempty(self.model.login_role_list) then
            Notify.ShowText("Your character list is empty")
            return
        end
        self:Close()
        GlobalEvent:Brocast(LoginEvent.OpenSelectRolePanel)

    end
    AddButtonEvent(self.btn_return.gameObject, call_back)

    local function call_back(name)
        if #name == 0 or type(name) ~= "string" then
            return
        end
        self.name.text = name
    end
    self.event_id = GlobalEvent:AddListener(LoginEvent.RandomName, call_back)

    local function call_back()
        self:Close()

    end
    self.event_id_2 = GlobalEvent:AddListener(EventName.GameStart, call_back)
end

function CreateRolePanel:OpenCallBack()
    local function step()
        SetVisible(self.mask, false)
    end
    self.delay_hide_mask_event_id = GlobalSchedule:StartOnce(step, 1.5)
    self:UpdateView()
end

function CreateRolePanel:RollName()
    local info = LoginConst.CareerConfig[self.index]
    if not info then
        return
    end
    local gender = info.gender
    LoginController:GetInstance():RequestCreateName(gender)
end

function CreateRolePanel:UpdateView()
    local list = LoginConst.CareerConfig
    for i = 1, #list do
        local item = self.itemList[i]
        if not item then
            --item = CreateRoleItem(self.con, self.layer)
            item = CreateRoleItem(newObject(self.itemPrefab), self.con)
            SetVisible(item.transform, true)
            self.itemList[i] = item
            local x = 0
            local y = (i - 1) * -160
            item:SetPosition(x, y)
            item:SetIdx(i)
            item:SetCallBack(handler(self, self.ClickCallBack))
        end
        item:SetData(i, list[i])
    end

    self:UpdateInfo(true)
end

function CreateRolePanel:ClickCallBack(index)
    if (self.delaying) then
        return
    end
    self.index = index

    for k, item in pairs(self.itemList) do
        item:SetSelectState(k == index)
    end
    self:UpdateInfo()
end

function CreateRolePanel:UpdateInfo(skipShowRole)
    local info = LoginConst.CareerConfig[self.index]
    if not info then
        return
    end
    lua_resMgr:SetImageTexture(self, self.OccupationIconImage, self.image_abName, info.CareerIcon, true)

    self:RollName()

    if (not skipShowRole) then
        self:ShowRole(self.roleResIdList[self.index])
    end
end

function CreateRolePanel:StopShowSchedule()
    if (self.delayShowSchedule) then
        GlobalSchedule:Stop(self.delayShowSchedule)
        self.delayShowSchedule = nil
    end
end

function CreateRolePanel:CloseCallBack()
    if self.delay_hide_mask_event_id then
        GlobalSchedule:Stop(self.delay_hide_mask_event_id)
        self.delay_hide_mask_event_id = nil
    end
    for k, item in pairs(self.itemList) do
        item:destroy()
    end
    self.itemList = {}

    if self.event_id then
        GlobalEvent:RemoveListener(self.event_id)
        self.event_id = nil
    end

    if self.event_id_2 then
        GlobalEvent:RemoveListener(self.event_id_2)
        self.event_id_2 = nil
    end
end