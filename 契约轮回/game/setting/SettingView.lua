SettingView = SettingView or class("SettingView", BaseItem)
local SettingView = SettingView

function SettingView:ctor(parent_node, layer)
    self.abName = "autoplay"
    self.assetName = "SettingView"
    self.layer = layer
    self.events = {}

    self.model = SettingModel:GetInstance();
    SettingView.super.Load(self)
end

function SettingView:dctor()
    -- SceneManager:GetInstance():ShowAllMonster(not self.model.isHideMonster);
    -- SceneManager:GetInstance():ShowAllRole();

    SceneManager:GetInstance():UpdateRoleVisibleState()
    SceneManager:GetInstance():SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP,self.model.isHideMonster,SceneManager.SceneObjectVisibleState.SettingVisible)
    SceneManager:GetInstance():SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROLE,not self.model.isShowRole,SceneManager.SceneObjectVisibleState.SettingVisible)
    SceneManager:GetInstance():SetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT,not self.model.isShowRole,SceneManager.SceneObjectVisibleState.SettingVisible)

    SceneManager:GetInstance():ShowAllTitle();

    if self.roleicon then
        self.roleicon:destroy()
    end
    self.resToggleList = nil;
    self.fpsToggleList = nil
end

function SettingView:LoadCallBack()
    self.nodes = {
        "logoutbtn", "role_bg/role_icon", "name_title/name/namaText", "logout_accountbtn", "gamemusic/gamemusicSlider",
        "gamevoice/gamevoiceSlider", "gameroles/role_num", "gameroles/gamerolesSlider", "other/players",
        "other/monster","other/title","other/player_effect","other/shake","other/flower_effect",
        "quality/Togglelow","quality/Togglemiddle","quality/Togglehigh",
        "other/power","name_title/pen",
        "fps/fpshigh","fps/fpsmiddle","fps/fpslow",
        "btn_customer_service","btn_user_center",
    }
    self:GetChildren(self.nodes)
    --self.role_icon = GetImage(self.role_icon)
    self.name_input = GetText(self.namaText)
    --self.id = GetText(self.id)
    --self.musciopen = GetToggle(self.musciopen)
    --self.musicclose = GetToggle(self.musicclose)
    --self.voiceclose = GetToggle(self.voiceclose)
    --self.voiceopen = GetToggle(self.voiceopen)
    self.gamemusicSlider = GetSlider(self.gamemusicSlider)
    self.gamevoiceSlider = GetSlider(self.gamevoiceSlider)

    self.gamerolesSlider = GetSlider(self.gamerolesSlider);
    self.role_num = GetText(self.role_num);

    self.monster = GetToggle(self.monster);
    self.players = GetToggle(self.players);

    self.shake = GetToggle(self.shake);
    self.title = GetToggle(self.title);
    self.player_effect = GetToggle(self.player_effect);
    self.flower_effect = GetToggle(self.flower_effect);

    ---屏幕分辨率高中低(1->3)
    self.highResolution = GetToggle(self.Togglehigh)
    self.midResolution = GetToggle(self.Togglemiddle)
    self.lowResolution = GetToggle(self.Togglelow)
    self.resToggleList = {}
    table.insert(self.resToggleList, self.highResolution)
    table.insert(self.resToggleList, self.midResolution)
    table.insert(self.resToggleList, self.lowResolution)

    -- fps 帧率 设置 1 -3
    self.fpshighToggle = GetToggle(self.fpshigh)
    self.fpsmiddleToggle = GetToggle(self.fpsmiddle)
    self.fpslowToggle = GetToggle(self.fpslow)
    self.fpsToggleList = {}
    table.insert(self.fpsToggleList, self.fpslowToggle)
    table.insert(self.fpsToggleList, self.fpsmiddleToggle)
    table.insert(self.fpsToggleList, self.fpshighToggle)
    self.gamerolesSlider.maxValue = 15

    ---节能模式Toggle
    self.EnergySavingToggle = GetToggle(self.power)

    self:AddEvent()
    self:UpdateView()
    self:SoundInfo()
	self.model:SetData()
    self:SetToggle()

    SetVisible(self.logoutbtn,false)
end

function SettingView:AddEvent()
    local function call_back(target, x, y)
        local function ok_func()
            LoginController.GetInstance():RequestLeaveGame()
        end
        Dialog.ShowTwo(ConfigLanguage.Mix.Tips, "Return to character selection page?", "Confirm", ok_func)
    end
    AddButtonEvent(self.logoutbtn.gameObject, call_back)

    local function call_back(target, x, y)
        local function ok_func()
            if not AppConfig.Debug then
                PlatformManager:GetInstance():logout()
            end
            LoginController.GetInstance():RequestLeaveGame(true)
        end
        Dialog.ShowTwo(ConfigLanguage.Mix.Tips, "Log out and return to the starting page?", "Confirm", ok_func)
    end
    AddButtonEvent(self.logout_accountbtn.gameObject, call_back)

    local function call_back()
        self:SetBackGroundVolume()
    end
    AddValueChange(self.gamemusicSlider.gameObject, call_back)  --声音


    local function call_back()
        self:SetEffVolume()
    end
    AddValueChange(self.gamevoiceSlider.gameObject, call_back) --音效

    local function call_back(go , bool)
        self.model:SetShakeScreen(not bool);
    end

    AddValueChange(self.shake.gameObject , call_back);

    local function call_back(go , bool)
        self.model:SetHideOtherEffect(bool);
    end

    AddValueChange(self.player_effect.gameObject , call_back);

    local function call_back(go , bool)
        self.model:SetShowTitle(not bool);
    end

    AddValueChange(self.title.gameObject , call_back);

    local function call_back(go , bool)
        if bool then
            self.model:SetHideFlower(1)
        else
            self.model:SetHideFlower(0)
        end
    end

    AddValueChange(self.flower_effect.gameObject , call_back);


    --[[local function call_back(go, bool)
        SoundManager:GetInstance():SetEffOnOrOff(not bool)
    end
    AddValueChange(self.voiceopen.gameObject, call_back)

    local function call_back(go, bool)
        SoundManager:GetInstance():SetBackGroundOnOrOff(not bool)
    end

    AddValueChange(self.musciopen.gameObject, call_back)--]]

    local function call_back(go, bool)
        if not self.isAutoSet then
            self.model:SetMonsterHide(bool);
            --print2("SetMonsterShow" .. tostring(bool));
            BrocastModelEvent(SettingEvent.SHOW_ALL_MONSTER, nil, bool);
        end
    end

    AddValueChange(self.monster.gameObject, call_back)

    local function call_back(go, bool)
        if not self.isAutoSet then
            --玩家点击设置
            self.model:SetRoleShow(not bool);
            print2("SetRoleShow" .. tostring(bool));
            BrocastModelEvent(SettingEvent.SHOW_ALL_ROLE, nil, bool);
            self.isAutoSliderSet = true;
            if not bool then
                if self.model.maxShowRoleNum == 0 then
                    self.model.maxShowRoleNum = 15;
                end
                self.gamerolesSlider.value = tonumber(self.model.maxShowRoleNum);
                self.role_num.text = tostring(self.model.maxShowRoleNum) .. "People";
            else
                self.gamerolesSlider.value = 0;
                self.role_num.text = "0 Players";
            end
            self.isAutoSliderSet = false;
        else
        end
    end

    AddValueChange(self.players.gameObject, call_back)

    local function call_back()
        if not self.isAutoSliderSet then
            self:SetRoleNum();
        end
    end
    AddValueChange(self.gamerolesSlider.gameObject, call_back) --显示人物数量

    ---屏幕分辨率 UI注册
    local function call_back(go , bool)
        if(bool) then
            self.model:SetScreenResLevel(1);
        end
    end
    AddValueChange(self.Togglehigh.gameObject , call_back);


    local function call_back(go , bool)
        if(bool) then
            self.model:SetScreenResLevel(2);
        end
    end
    AddValueChange(self.Togglemiddle.gameObject , call_back);

    local function call_back(go , bool)
        if(bool) then
            self.model:SetScreenResLevel(3);
        end
    end
    AddValueChange(self.Togglelow.gameObject , call_back);

    ---fps
    local function call_back(go , bool)
        if(bool) then
            self.model:SetFPSLevel(3);
        end
    end
    AddValueChange(self.fpshigh.gameObject , call_back);


    local function call_back(go , bool)
        if(bool) then
            self.model:SetFPSLevel(2);
        end
    end
    AddValueChange(self.fpsmiddle.gameObject , call_back);

    local function call_back(go , bool)
        if(bool) then
            self.model:SetFPSLevel(1);
        end
    end
    AddValueChange(self.fpslow.gameObject , call_back);


    ---节能模式 UI注册
    local function call_back(go, bool)
        self.model:SetEnergySavingMode(bool);
    end
    AddValueChange(self.power.gameObject, call_back);

    -- 更改名字
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(RoleReNamePanel):Open(2)
    end
    AddButtonEvent(self.pen.gameObject, call_back)

    self.events[#self.events + 1] = GlobalEvent:AddListener(RoleInfoEvent.RoleReName, handler(self, self.RoleReName))

    --用戶中心
    local function call_back(  )
        PlatformManager:GetInstance():ShowUserCenter()
    end
    AddButtonEvent(self.btn_user_center.gameObject,call_back)

    --聯繫客服
    local function call_back(  )
        PlatformManager:GetInstance():ShowCustomerService()
    end
    AddButtonEvent(self.btn_customer_service.gameObject,call_back)

end

function SettingView:SetData(data)

end

SettingView.isAutoSet = false;
SettingView.isAutoSliderSet = false;
function SettingView:UpdateView()
    local name = RoleInfoModel:GetInstance():GetRoleValue("name")
    self.name_input.text = name

    local param = {}
    param['is_can_click'] = false
    param["is_squared"] = true
    param["is_hide_frame"] = true
    param["size"] = 73
    if not self.roleicon then
        self.roleicon = RoleIcon(self.role_icon)
    end
    self.roleicon:SetData(param)
end

function SettingView:SoundInfo()
    local soundVol = SoundManager:GetInstance():GetBackGroundVolume() or 0
    local effVol = SoundManager:GetInstance():GetEffVolume() or 0
    self.gamemusicSlider.value = soundVol * 100
    self.gamevoiceSlider.value = effVol * 100
end

function SettingView:SetToggle()
    --[[if SoundManager:GetInstance():GetBackGroundOnOrOff() then
        self.musciopen.isOn = false
        self.musicclose.isOn = true
    else
        self.musciopen.isOn = true
        self.musicclose.isOn = false
    end--]]

    --[[if SoundManager:GetInstance():GetEffOnOrOff() then
        self.voiceopen.isOn = false
        self.voiceclose.isOn = true
    else
        self.voiceopen.isOn = true
        self.voiceclose.isOn = false
    end--]]

    self.isAutoSet = true;
    self.isAutoSliderSet = true;
    self.players.isOn = not SettingModel:GetInstance().isShowRole;
    self.monster.isOn = SettingModel:GetInstance().isHideMonster;
    self.flower_effect.isOn = self.model:GetHideFlower()
    self.title.isOn = not SettingModel.GetInstance().isShowTitle;
    self.shake.isOn = not SettingModel.GetInstance().isShakeScreen;
    self.player_effect.isOn = SettingModel.GetInstance().isHideOtherEffect;

    if  self.model.isShowRole then
        self.gamerolesSlider.value = tonumber(self.model.maxShowRoleNum);
        self.role_num.text = tonumber(self.model.maxShowRoleNum) .. "People";
    else
        self.gamerolesSlider.value = 0;
        self.role_num.text = "0 Players";
    end

    self.isAutoSet = false;
    self.isAutoSliderSet = false;

    ---屏幕分辨率设置
    local resLevel =  SettingModel:GetInstance().ScreenResLevel
    if(self.resToggleList and self.resToggleList[resLevel]) then
        self.resToggleList[resLevel].isOn = true
    else
        self.resToggleList[1].isOn = true
    end

    -- fps设置
    local count =  SettingModel:GetInstance().fpsLevel
    if(self.fpsToggleList and self.fpsToggleList[count]) then
        self.fpsToggleList[count].isOn = true
    else
        self.fpsToggleList[1].isOn = true
    end


    ---节能模式设置
    self.EnergySavingToggle.isOn = SettingModel:GetInstance().isEnergySavingMode

end


--  修改音乐
function SettingView:SetBackGroundVolume()
    SoundManager:GetInstance():SetBackGroundVolume(self.gamemusicSlider.value / 100)
end
-- 修改音效
function SettingView:SetEffVolume()
    SoundManager:GetInstance():SetEffVolume(self.gamevoiceSlider.value / 100)
end
-- 更改名字
function SettingView:RoleReName(name)
    self.name_input.text = name
end

function SettingView:SetRoleNum()
    local value = self.gamerolesSlider.value;
    self.gamerolesSlider.value = value
    self.role_num.text = tostring(value) .. "People";
    self.model:SetMaxShowRoleNum(value)
    self.isAutoSet = true;
    if value == 0 then
        self.players.isOn = true;
        self.model.isShowRole = false;
    else
        self.players.isOn = false;
        self.model.isShowRole = true;
    end
    self.isAutoSet = false;
end