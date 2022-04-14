-- 
-- @Author: LaoY
-- @Date:   2018-07-25 15:55:38
-- 

InputManager = InputManager or class("InputManager", BaseManager)

InputManager.OpenGmPanel = "InputManager.OpenGmPanel"

---是否开启的节能模式（屏幕变暗）
InputManager.EnergySavingMode = false
InputManager.IsInEnergySavingMode = false
InputManager.EnergySavingTime = 10
InputManager.tempTimer = 0

function InputManager.OnPress(key_code)
    -- Yzprint('--LaoY InputManager.lua,line 17--',key_code)
    InputManager:GetInstance():OnKeyRelease(key_code)
end

InputManager.KeyCode = {
    Backspace = "Backspace",
    Delete = "Delete",
    Tab = "Tab",
    Clear = "Clear",
    Return = "Return",
    Pause = "Pause",
    Escape = "Escape",
    Space = "Space",
    Keypad0 = "Keypad0",
    Keypad1 = "Keypad1",
    Keypad2 = "Keypad2",
    Keypad3 = "Keypad3",
    Keypad4 = "Keypad4",
    Keypad5 = "Keypad5",
    Keypad6 = "Keypad6",
    Keypad7 = "Keypad7",
    Keypad8 = "Keypad8",
    Keypad9 = "Keypad9",
    KeypadPeriod = "KeypadPeriod",
    KeypadDivide = "KeypadDivide",
    KeypadMultiply = "KeypadMultiply",
    KeypadMinus = "KeypadMinus",
    KeypadPlus = "KeypadPlus",
    KeypadEnter = "KeypadEnter",
    KeypadEquals = "KeypadEquals",
    UpArrow = "UpArrow",
    DownArrow = "DownArrow",
    RightArrow = "RightArrow",
    LeftArrow = "LeftArrow",
    Insert = "Insert",
    Home = "Home",
    End = "End",
    PageUp = "PageUp",
    PageDown = "PageDown",
    F1 = "F1",
    F2 = "F2",
    F3 = "F3",
    F4 = "F4",
    F5 = "F5",
    F6 = "F6",
    F7 = "F7",
    F8 = "F8",
    F9 = "F9",
    F10 = "F10",
    F11 = "F11",
    F12 = "F12",
    F13 = "F13",
    F14 = "F14",
    F15 = "F15",
    A = "A",
    B = "B",
    C = "C",
    D = "D",
    E = "E",
    F = "F",
    G = "G",
    H = "H",
    I = "I",
    J = "J",
    K = "K",
    L = "L",
    M = "M",
    N = "N",
    O = "O",
    P = "P",
    Q = "Q",
    R = "R",
    S = "S",
    T = "T",
    U = "U",
    V = "V",
    W = "W",
    X = "X",
    Y = "Y",
    Z = "Z",
}

function InputManager:ctor()
    InputManager.Instance = self

    self:Reset()
    self:AddEvent()
    -- if AppConfig.Debug then

    -- 输入监听放到c#处理，手机上lua一律不处理输入相关
    if not Application.isMobilePlatform then
        LateUpdateBeat:Add(self.Update, self,1,1)
    end

    -- end
end

function InputManager:AddEvent()

    self.events = {}
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(GMPanel):Open()
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(InputManager.OpenGmPanel, call_back)

    local function call_back(bool)
        bool = toBool(bool)
        self.EnergySavingMode = bool
        self.tempTimer = 0
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.EnergySavingModeEvent, call_back)
end

function InputManager:Reset()

end

function InputManager.GetInstance()
    if InputManager.Instance == nil then
        InputManager()
    end
    return InputManager.Instance
end

function InputManager:Update()
    self:KeyRelease()
    self:KeyPress()

    -- self:EnergySavingCheck()
end

---检查是否进入省电模式
function InputManager:EnergySavingCheck()

    if (Input.anyKey) then
        if(self.IsInEnergySavingMode) then
            self.IsInEnergySavingMode = false
            PlatformManager:GetInstance():SetBrightness(-100)
            --print("---------------> out EnergySavingMode")
        end
        self.tempTimer = 0
        return
    end

    if (self.EnergySavingMode) then
        if (not self.IsInEnergySavingMode) then
            self.tempTimer = self.tempTimer + Time.deltaTime
            if (self.tempTimer >= self.EnergySavingTime) then
                self.IsInEnergySavingMode = true
                PlatformManager:GetInstance():SetBrightness(30)
                --print("---------------> in EnergySavingMode")
            end
        end
    else
        if (self.IsInEnergySavingMode) then
            self.IsInEnergySavingMode = false
            PlatformManager:GetInstance():SetBrightness(-100)
            --print("---------------> out EnergySavingMode")
        end
    end
end


--按下松手
function InputManager:KeyRelease()
    for k, key_code in pairs(InputManager.KeyCode) do
        if Input.GetKeyUp(KeyCode[key_code]) then
            self:OnKeyRelease(key_code)
            return
        end
    end
end

function InputManager:OnKeyRelease(key_code)
    -- Notify.ShowText(key_code)
    -- Yzprint('--LaoY InputManager.lua,line 186--',key_code)
    GlobalEvent:Brocast(EventName.KeyRelease, key_code)
    if InputManager.KeyCode.Escape == key_code then
        print('--LaoY InputManager.lua,line 32-- data=')
        -- Application.Quit()
        PlatformManager:GetInstance():exit()
        return
    end

    if InputManager.KeyCode.Z == key_code then
        --秘籍输入
        GlobalEvent:Brocast(InputManager.OpenGmPanel)
    elseif InputManager.KeyCode.F == key_code then
        

        -- local map = {
        --     "attr.hpmax",
        --     "attr.att",
        --     "attr.def",
        --     "attr.wreck",
        --     "attr.hit",
        --     "attr.miss",
        --     "attr.crit",
        --     "attr.tough",
        --     "attr.holy_att",
        --     "attr.holy_def",
        -- }
        -- local mainrole_data = RoleInfoModel:GetInstance():GetMainRoleData()
        -- cur_power = cur_power or 22000
        -- cur_power = cur_power + 200
        -- mainrole_data:ChangeData("power",cur_power)

        -- cur_attr_tab = cur_attr_tab or {}
        -- for i=1,10 do
        --     local key = math.random(#map)
        --     cur_attr_tab[map[key]] = cur_attr_tab[map[key]] or 1000
        --     cur_attr_tab[map[key]] = cur_attr_tab[map[key]] + 100
        --     mainrole_data:ChangeData(map[key],cur_attr_tab[map[key]])
        -- end

        -- LoginController:GetInstance():RequestGameCheat("level-1")
        -- lua_panelMgr:OpenPanel(PowerChange)

        -- MainIconOpenLink(150,1)

        -- GMPanel:SendGm("buff-310000007-20")

    elseif InputManager.KeyCode.C == key_code then

        -- log("========输出引用开始==========");
        -- DebugManager:GetInstance():OutPutRef()
        -- Notify.ShowText("输出引用完成")

        GlobalEvent:Brocast(RaceEvent.OpenRaceMainPanel)

    elseif InputManager.KeyCode.M == key_code then
        --快捷输入
        -- GlobalEvent:Brocast(MainEvent.OpenMapPanel)
        -- lua_panelMgr:OpenPanel(SkillGetPanel,Config.db_skill[101005])
        --TaskModel:GetInstance():ResumeTask()
        --lua_panelMgr:GetPanelOrCreate(BuyFairyPanel):Open()

        -- local main_role = SceneManager:GetInstance():GetMainRole()
        -- main_role:PlayDeath()
        
    elseif InputManager.KeyCode.R == key_code then
        --快捷输入
        -- local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
        -- local level = main_role_data.level
        -- main_role_data:ChangeData("level",level + 1)
        -- local main_role = SceneManager:GetInstance():GetMainRole()
        -- main_role:Revive()

    elseif InputManager.KeyCode.F1 == key_code then
        -- --秘籍输入
        -- --热更代码
        if self.HU == nil then
            local obj = io.popen("cd")
            local path = obj:read("*all"):sub(1, -2)
            obj:close()
            path = string.format("%s\\Assets\\LuaFramework\\lua", path)
            self.HU = require "common.luahotupdate.luahotupdate"
            self.HU.Init("common.luahotupdate.hotupdatelist", { path })

        end
        self.HU.Update()
        Notify.ShowText("Hotfix successful")
        self.HU = nil
        
    elseif Input.GetKeyUp(KeyCode.F4) then
        dofile("luahotupdate")
    elseif Input.GetKeyUp(KeyCode.F2) then
        -- local _, LuaDebuggee = pcall(require, 'LuaDebuggee')
        -- if LuaDebuggee and LuaDebuggee.StartDebug then
        --     LuaDebuggee.StartDebug('127.0.0.1', 9826)
        -- else
        --     print('Please read the FAQ.pdf')
        -- end
        FashionController:GetInstance():RequestFashionPutOn(41002)

    elseif Input.GetKeyUp(KeyCode.F3) then
        FashionController:GetInstance():RequestFashionPutOn(41003)
    elseif Input.GetKeyUp(KeyCode.F12) then
        --RaceController.GetInstance():RequestMatchStart(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_RACE,0)
    end
end

--按住键盘
function InputManager:KeyPress()
    self.horizontal = 0
    self.vertical = 0
    if not SceneManager then
        return
    end
    local  scene_data = SceneManager:GetInstance():GetSceneInfo()
    if ArenaModel and ArenaModel:GetInstance():IsArenaFight(scene_data.scene) then
        return
    end
    if RaceModel and RaceModel.GetInstance():IsRaceScene(scene_data.scene) then
        return
    end

    if Input.GetKey(KeyCode.A) then
        --方向键
        self.horizontal = self.horizontal - 1
    end
    if Input.GetKey(KeyCode.S) then
        --方向键
        self.vertical = self.vertical - 1
    end
    if Input.GetKey(KeyCode.D) then
        --方向键
        self.horizontal = self.horizontal + 1
    end
    if Input.GetKey(KeyCode.W) then
        --方向键
        self.vertical = self.vertical + 1
    end
    self:UpdateDirection()
end

function InputManager:UpdateDirection()
    if self.horizontal ~= 0 or self.vertical ~= 0 then
        local vec = Vector2(self.horizontal, self.vertical)
        vec:SetNormalize()
        GlobalEvent:Brocast(MainEvent.MoveRocker, vec)
        GlobalEvent:Brocast(MainEvent.RockerVec, vec)
        self.last_move_state = true
    else
        if not self.last_move_state then
            return
        end
        self.last_move_state = false
        GlobalEvent:Brocast(MainEvent.MoveRocker)
        GlobalEvent:Brocast(MainEvent.RockerVec, Vector2(0, 0))
    end
end