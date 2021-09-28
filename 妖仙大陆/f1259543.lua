local _M = {}
_M.__index = _M


local cjson             = require "cjson"
local Util              = require 'Zeus.Logic.Util'
local VSAPI             = require "Zeus.Model.VS"
local FriendModel       = require 'Zeus.Model.Friend'

local SocialUtil        = require "Zeus.UI.XmasterSocial.SocialUtil"
local ActivityUtil      = require "Zeus.UI.XmasterActivity.ActivityUtil"

local self = {
    menu = nil,
}

local function ClearAvatarObj()
    if self.avatarList and  #self.avatarList > 0 then
        for i,v in ipairs(self.avatarList) do
            IconGenerator.instance:ReleaseTexture(v.key)
            UnityEngine.Object.DestroyObject(v.obj)
        end
    end
    self.avatarList = {}
end

local function OnClickClose()
    
    ClearAvatarObj()
    
    self.menu:Close()
end

local function ShowAvatar(avatars , cvs_3d, isLastOne)
    local list = ListXmdsAvatarInfo.New()
    for i,v in ipairs(avatars) do
        local info = XmdsAvatarInfo.New()
        GameUtil.setXmdsAvatarInfoTag(info, v.tag)
        
        info.FileName = v.fileName
        info.EffectType = v.effectType
        list:Add(info)
    end

    local filter = bit.lshift(1,  GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
    local avatarObj, avatarKey = GameUtil.Add3DModel(cvs_3d, "", list, nil, filter, true)
    IconGenerator.instance:SetModelPos(avatarKey, Vector3.New(0, -0.8, 3.5))
    
    IconGenerator.instance:SetCameraParam(avatarKey, 0.3, 10, 2)

    IconGenerator.instance:SetLoadOKCallback(avatarKey, function (k)
        IconGenerator.instance:PlayUnitAnimation(avatarKey, 'n_show', WrapMode.Loop, -1, 1, 0, nil, 0)
        
        if isLastOne == true then
            self.menu.mRoot.Visible = true
        end
    end)
    local t = {
        node = cvs_3d,
        move = function (sender,pointerEventData)
            IconGenerator.instance:SetRotate(avatarKey,-pointerEventData.delta.x)
        end, 
        up = function() end
    }
    LuaUIBinding.HZPointerEventHandler(t)
    local a = {obj = avatarObj,  key = avatarKey}
    table.insert(self.avatarList,a)
end

local function OnClickApply( displayNode )
    OnClickClose()
    local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialFriendApply, 0)
end

local function OnClickAddReqest(sender)
    local id = self.applyList[sender.UserTag].id
    FriendModel.friendApplyRequest(id, function(params)
        
        local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PUBLICCFG, "friendAdd")
        GameAlertManager.Instance:ShowNotify(tips)
        self.friendCans[sender.UserTag]:FindChildByEditName("btn_apply"..sender.UserTag, true).Visible = false
        self.friendCans[sender.UserTag]:FindChildByEditName("ib_applyed", true).Visible = true
    end)
end

local function InitFriendAddList()
    ClearAvatarObj()
    local num = #self.applyList
    for i=1,num do
        if i <= 4 then
            SocialUtil.FillSocialFriendCan(self.applyList[i], self.friendCans[i], i)
            local cvs_3d = self.friendCans[i]:FindChildByEditName("cvs_mod"..i, true)
            ShowAvatar(self.applyList[i].avatars,cvs_3d,i==num or i==4)
            self.friendCans[i].Visible = true
            local btn_apply = self.friendCans[i]:FindChildByEditName("btn_apply"..i, true)
            btn_apply.Visible = true

            local ib_applyed = self.friendCans[i]:FindChildByEditName("ib_applyed", true)
            ib_applyed.Visible = false

            btn_apply.UserTag = i
            btn_apply.TouchClick = function (sender)
                OnClickAddReqest(sender)
            end
        end
    end

    if num == 0 then
        self.menu.mRoot.Visible = true
    end
    if num < 4 then
        for i=num+1,4 do
            self.friendCans[i].Visible = false
        end
    end
end

local function OnClickSearch(displayNode)
    if self.search_input.Text ~= "" then
        FriendModel.queryPlayerNameRequest(self.search_input.Text, function(params)
            self.applyList = params.data or {}
            InitFriendAddList()
        end)
    else
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.CHAT, 'input_null'))
    end
end

local function GetAddList()
    FriendModel.addFriendInfoRequest(function(params)
        
        self.applyList = params.data or {}
        InitFriendAddList()
    end)
end

local function OnClickReFresh( displayNode )
    if self.startTime ~= nil then
        local time = math.floor((System.DateTime.Now - self.startTime).TotalSeconds)
        if time < self.refreshInterval then 
            local str = Util.GetText(TextConfig.Type.FRIEND, 'addfriend_refresh')
            GameAlertManager.Instance:ShowNotify("<f>" .. string.gsub(str, "|1|", self.refreshInterval - time) .. "</f>")
            return
        end
    end
    self.startTime = System.DateTime.Now
    GetAddList()
end

local function OnExit()
    ClearAvatarObj()
end

local function OnEnter()
    self.menu.mRoot.Visible = false
    GetAddList()
end

local function InitUI()
    
    local UIName = {
        "btn_close",
        "btn_search",
        "search_box",
        "search_input",

        "btn_lookup",
        "btn_addall",
        "lb_tishi",

        "btn_change",
        "btn_application",

        "ti_input",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.friendCans = {}
    for i=1,4 do
        self.friendCans[i] = self.menu:GetComponent("cvs_information"..i)
        self.friendCans[i].Visible = false
    end

    self.avatarList = {}
end

local function InitCompnent()
    
    InitUI()

    self.refreshInterval = ActivityUtil.ParametersValue("Social.FriendRefresh")
    self.btn_close.TouchClick = OnClickClose

    self.btn_search.TouchClick = OnClickSearch

    self.btn_change.TouchClick = OnClickReFresh
    self.btn_application.TouchClick = OnClickApply

    self.search_input.Input.lineType = UnityEngine.UI.InputField.LineType.MultiLineSubmit
    self.search_input.InputTouchClick = function(displayNode)
        self.lb_tishi.Visible = false  
    end
    self.search_input.event_endEdit = LuaUIBinding.InputValueChangedHandler(function(displayNode)
        if self.search_input.Text ~= "" then
            self.lb_tishi.Visible = false
        else
            self.lb_tishi.Visible = true
        end
    end)

    
    

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function OpenAddFriendUI()
    OnClickApply()
end

local function Init(tag,params)
	self.menu = LuaMenuU.Create("xmds_ui/social/friend_add.gui.xml", GlobalHooks.UITAG.GameUISocialFriendAdd)
    InitCompnent()
    
	return self.menu
end

function _M.Create(tag,params)
	self = {}
	setmetatable(self, _M)
	local node = Init(tag, params)
	return self
end

_M.OpenAddFriendUI = OpenAddFriendUI

return _M
