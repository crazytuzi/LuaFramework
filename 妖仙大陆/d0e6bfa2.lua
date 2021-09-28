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

local function ShowAvatar(id , cvs_3d)
    VSAPI.requestPlayerInfo(id, function(data)
        local list = ListXmdsAvatarInfo.New()
        for i,v in ipairs(data.avatars) do
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
    end,
    function()
    end) 
end

local function OnClickIgnoreAll(displayNode)
    local ids = {}
    if 0 < #self.applyList then 
        for i = 1, #self.applyList do
            ids[i] = self.applyList[i].id
        end
        FriendModel.friendAllRefuceApplyRequest(ids, function(params)
            EventManager.Fire("Event.Social.applyDealDone", {})
        end)
    end
end

local function OnClickAcceptAll(displayNode)
    local ids = {}
    if 0 < #self.applyList then 
        for i = 1, #self.applyList do
            ids[i] = self.applyList[i].id
        end
        FriendModel.friendAllAgreeApplyRequest(ids, function(params)
            EventManager.Fire("Event.Social.applyDealDone", {})
        end)
    end
end

local function OnClickIgnore(sender)
    local id = self.applyList[sender.UserTag].id
    FriendModel.friendRefuceApplyRequest(id, function(params)
        EventManager.Fire("Event.Social.applyDealDone", {})
    end)
end

local function OnClickAccept(sender)
    local id = self.applyList[sender.UserTag].id
    FriendModel.friendAgreeApplyRequest(id, function(params)
        EventManager.Fire("Event.Social.applyDealDone", {})
    end)
end

function RefreshPageData()
    ClearAvatarObj()
    self.lb_page.Text = self.curPage.."/"..self.totalPage
    local temp = 1+(self.curPage-1)*4
    local count = 1
    for i=temp,self.applyCount do
        if count <= 4 then
            SocialUtil.FillSocialFriendCan(self.applyList[i], self.friendCans[count], count)
            local cvs_3d = self.friendCans[count]:FindChildByEditName("cvs_mod"..count, true)
            ShowAvatar(self.applyList[i].id,cvs_3d)
            self.friendCans[count].Visible = true
            local btn_accept = self.friendCans[count]:FindChildByEditName("btn_accept"..count, true)
            local btn_ignore = self.friendCans[count]:FindChildByEditName("btn_ignore"..count, true)
            btn_accept.UserTag = i
            btn_ignore.UserTag = i
            btn_accept.TouchClick = function (sender)
                OnClickAccept(sender)
            end
            btn_ignore.TouchClick = function (sender)
                OnClickIgnore(sender)
            end
            count = count + 1
        end
    end

    if count <= 4 then
        for i=count,4 do
            self.friendCans[i].Visible = false
        end
    end
end

local function OnClickLeftPage( displayNode )
    if self.curPage > 1 then
        self.curPage = self.curPage - 1
        RefreshPageData()
    end 
end

local function OnClickRightPage(id)
    if self.curPage < self.totalPage then
        self.curPage = self.curPage + 1
        RefreshPageData()
    end 
end

local function InitFriendApplyList()
    self.applyCount = 0
    if self.applyList ~= nil then
        self.applyCount = #self.applyList
    end
    self.cvs_apply.Visible = self.applyCount > 0
    self.cvs_apply_none.Visible = self.applyCount == 0
    self.btn_ignore_all.Visible = self.applyCount > 0
    self.btn_accept_all.Visible = self.applyCount > 0

    self.lb_title_count.Text = Util.GetText(TextConfig.Type.FRIEND,'applyfriend_Num', self.applyCount)

    self.curPage = 1
    if self.applyCount == 0 then
        self.totalPage = 1
    else
        self.totalPage = math.ceil(self.applyCount/4)
    end
    RefreshPageData()
end

local function GetApplyList()
    FriendModel.friendMessageListRequest(function(params)
        self.applyList = params.friendMessageInfos
        InitFriendApplyList()
    end)
end

local function OnExit()
    ClearAvatarObj()
    EventManager.Unsubscribe("Event.Social.applyDealDone", GetApplyList)
end

local function OnEnter()
    self.cvs_apply.Visible = false
    self.cvs_apply_none.Visible = false
    self.applyList = nil
    self.applyCount = 0

    EventManager.Subscribe("Event.Social.applyDealDone", GetApplyList)

    GetApplyList()
end

local function OnClickClose(displayNode)
    
    ClearAvatarObj()
    self.menu:Close()
end

local function InitUI()
    
    local UIName = {
        "btn_close",
        "btn_return",
        "btn_ignore_all",
        "btn_accept_all",

        "btn_left",
        "lb_page",
        "btn_right",

        "lb_title_count",

        "cvs_apply",
        "cvs_apply_none",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.friendCans = {}
    for i=1,4 do
        self.friendCans[i] = self.menu:GetComponent("cvs_information"..i)
        self.friendCans[i].Visible = false
    end
end

local function InitCompnent()
    
    InitUI()

    self.refreshInterval = ActivityUtil.ParametersValue("Social.FriendRefresh")
    self.btn_close.TouchClick = OnClickClose
    self.btn_return.TouchClick = OnClickClose

    self.btn_left.TouchClick = OnClickLeftPage
    self.btn_right.TouchClick = OnClickRightPage

    self.btn_ignore_all.TouchClick = OnClickIgnoreAll
    self.btn_accept_all.TouchClick = OnClickAcceptAll

    
    

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
    self.menu = LuaMenuU.Create("xmds_ui/social/friend_apply.gui.xml", GlobalHooks.UITAG.GameUISocialFriendApply)
    InitCompnent()
    
    return self.menu
end

function _M.Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end

return _M
