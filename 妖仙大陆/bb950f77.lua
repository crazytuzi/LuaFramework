local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local SoloAPI = require "Zeus.Model.Solo"
local ServerTime = require "Zeus.Logic.ServerTime"

local self = {}

local function Release3DModel(self)
    if self.model ~= nil then
        GameObject.Destroy(self.model.obj)
        IconGenerator.instance:ReleaseTexture(self.model.key)
    end
    self.model = nil
end

local function Show3DModel(self,parent,avatars)
    if self.model[parent.UserData] == nil then
        local filter = bit.lshift(1, GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
        local obj, key
        if avatars ~= nil then
            obj, key= GameUtil.Add3DModelLua(parent, "", avatars, "", filter, true)
        else
            obj, key = GameUtil.Add3DModel(parent, "", nil, "", filter, true)
        end
        IconGenerator.instance:SetModelPos(key, Vector3.New(0.1, -1.1, 4.8))
        IconGenerator.instance:SetCameraParam(key, 0.3, 10, 2)
        IconGenerator.instance:SetLoadOKCallback(key, function(k)
            IconGenerator.instance:PlayUnitAnimation(key, 'n_show', WrapMode.Loop, -1, 1, 0, nil, 0)
            
        end )
        self.model[key] = obj
        parent.UserData = key
        obj.transform.sizeDelta = UnityEngine.Vector2.New(320, 640)
        local rawImage = obj:GetComponent("UnityEngine.UI.RawImage")
        rawImage.uvRect = UnityEngine.Rect.New(0.25, 0, 0.5, 1)
        rawImage.raycastTarget = false
        
    end
end

local function Release3DModel(self)
    if self.model ~= nil then
        for key, obj in pairs(self.model) do
            GameObject.Destroy(obj)
            IconGenerator.instance:ReleaseTexture(key)
        end
    end
    self.model = {}
end

local function InitUI()
    local UIName = {
        "cvs_play1",
        "cvs_play2",
        "ib_playpro1",
        "ib_playpro2",
        "lb_playname1",
        "lb_playname2",
        "lb_time",
        "btn_1",
        "btn_2"
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

end


local function OnEnter()
    self.menu.Visible = false
end

local function OnExit()
    Release3DModel(self)
    if self.timer then
        self.timer:Stop()
        self.timer = nil
    end
end

local function requestBattle()
    SoloAPI.requestJoinSoloBattle(function ()
        if self.timer then
            self.timer:Stop()
            self.timer = nil
        end
        if self.menu then
            self.menu:Close()
        end
    end)
end 

local function InitComponent(self, tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/solo/solo_wait.gui.xml',tag)
    InitUI()
    self.model = {}
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function(sender)
        
    end})

    self.btn_1.TouchClick = function ()
        self:setVisible(false)
    end

    self.btn_2.TouchClick = function ()
        requestBattle()
    end
    
    return self.menu
end

function _M:setVsPlayInfo(data)
    self.menu.Visible = true
    print("setVsPlayInfo" .. PrintTable(data))
    self.lb_playname1.Text = DataMgr.Instance.UserData.Name  
    Util.SetIconImagByPro(self.ib_playpro1,DataMgr.Instance.UserData.Pro)
     Show3DModel(self,self.cvs_play1,nil)

    self.lb_playname2.Text = data.s2c_vsPlayerName
    Show3DModel(self,self.cvs_play2,data.s2c_vsPlayerAvatars)
    Util.SetIconImagByPro(self.ib_playpro2,data.s2c_vsPlayerPro)

    self.countDown = data.s2c_waitResponseTimeSec
    self.lb_time.Text = self.countDown
    self.timer = Timer.New(function ()
        self.countDown = self.countDown -1
        if self.countDown < 0 then
            requestBattle()
        end
        self.lb_time.Text = self.countDown
    end,1, -1)
    self.timer:Start()

end

function _M:setVisible(var)
    self.menu.Visible = var

    local menu, obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIActivityHJBoss)
    if obj ~= nil then
        print("setVisible " ..(var and "true" or "false"))
        menu.Visible = not var
        
    end
end


local function Create(tag,params)
    setmetatable(self, _M)
    InitComponent(self,tag, params)
    return self
end

return {Create = Create}
