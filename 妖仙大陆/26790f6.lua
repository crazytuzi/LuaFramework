


local Util = require "Zeus.Logic.Util"
local WorldLvAPI = require "Zeus.Model.Leaderboard"
local DisplayUtil = require "Zeus.Logic.DisplayUtil"
local Item = require "Zeus.Model.Item"
local _M = {}
_M.__index = _M

local formatStrings = {
    lv = Util.GetText(TextConfig.Type.TEAM, "levelLimit"),
    myLv = Util.GetText(TextConfig.Type.TEAM, "levelLimit"),
    rank = Util.GetText(TextConfig.Type.TEAM, "rank"),
    addExp = Util.GetText(TextConfig.Type.TEAM, "addExp"),
    times = Util.GetText(TextConfig.Type.TEAM, "times"),
    btnSuperText = Util.GetText(TextConfig.Type.TEAM, "btnSuperText"),
}

local ui_names = {
    {name = "cvs_model"},
    {name = "btn_help"},
    {name = "cvs_detail"},
    {name = "lb_player_name"},  
    {name = "lb_level"},        
    {name = "lb_rank"},         
    {name = "lb_guild_name"},   
    {name = "lb_combatpower"},  
    {name = "cvs_deatil"},      
    {name = "lb_lev"},     
    {name = "lb_expp"},   
    {name = "tb_explain"},      
    {name = "cvs_deatil1"},     
    {name = "cvs_reward"},      
    {name = "ib_packs"},        
    {name = "lb_packs_name"},   
    {name = "lb_description"},  
    {name = "ib_packs1"},        
    {name = "lb_packs_name1"},   
    {name = "lb_description1"},  
    {name = "lb_times"},        
    {name = "btn_worship",click = function(self)
        WorldLvAPI.RequestWorship(1, function(awards)
            self.info.worShipTimes = self.info.worShipTimes + 1
            self:updateReward()
            self:showAwards(awards)
        end)
    end},        
    {name = "btn_worship1",click = function(self)
        WorldLvAPI.RequestWorship(0, function(awards)
            self.info.worShipTimes = self.info.worShipTimes + 1
            self:updateReward()
            self:showAwards(awards)
        end)
    end},        
    {name = "cvs_one"},         
    {name = "ib_one_packs"},     
    {name = "lb_one_explain"},  
    {name = "btn_close",click = function(self)
        self:Close()
    end}
    
}

function _M:Close()
    self.menu:Close()
end

function _M:updateOtherManCvs()
    local lv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
    local upLv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.REALM,0)
    self.lb_lev.Text = string.format(formatStrings.myLv,lv)
    if upLv == 0 then
        self.lb_rank.Text = ""
    else
        local txt,rgba = Util.GetUpLvTextAndColorRGBA(upLv)
        self.lb_rank.Text = txt
        self.lb_rank.FontColorRGBA = rgba
    end
    self.lb_expp.Text = string.format(formatStrings.addExp,self.info.addExp) 
    self:updateReward()
end

local function handler_touchCtrlItem(ctrl,detaildata)
    ctrl.Enable = true
    ctrl.IsInteractive = true
    ctrl.event_PointerDown = function()
        Util.ShowItemDetailWithCtrl(ctrl,Item.GetItemDetailByCode(detaildata.static.Code))
    end
    ctrl.event_PointerUp = function (sender)
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISimpleDetail)
    end
end

function _M:updateTopManCvs()
    self:updateTopOneReward()
end

function _M:updateReward()
    self.lb_times.Text = string.format(formatStrings.times,self.info.worShipTimes,self.info.maxWorShipTimes)
    if self.info.worShipTimes == self.info.maxWorShipTimes then
        self.lb_times.FontColor = Util.FontColorRed
    end
    if self.otherManItems == nil then
        self.otherManItems = {}
        local superChestItems = GlobalHooks.DB.GetGlobalConfig("WorldExp.SuperChest.ItemCode")
        local normalChestItems = GlobalHooks.DB.GetGlobalConfig("WorldExp.NormalChest.ItemCode")
        self.otherManItems.super = {static = GlobalHooks.DB.Find("Items", superChestItems)}
        self.otherManItems.normal = {static = GlobalHooks.DB.Find("Items", normalChestItems)}
        self.otherManItems.superNeed = GlobalHooks.DB.GetGlobalConfig("WorldExp.DiamondAdmire.Price")
    end
    handler_touchCtrlItem(self.ib_packs,self.otherManItems.super)
    self.lb_packs_name.Text = self.otherManItems.super.static.Name
    self.lb_packs_name.FontColorRGBA = Util.GetQualityColorRGBA(self.otherManItems.super.static.Qcolor)
    handler_touchCtrlItem(self.ib_packs1,self.otherManItems.normal)
    self.lb_packs_name1.Text = self.otherManItems.normal.static.Name
    self.lb_packs_name1.FontColorRGBA = Util.GetQualityColorRGBA(self.otherManItems.normal.static.Qcolor)
    self.btn_worship.Text = string.format(formatStrings.btnSuperText,self.otherManItems.superNeed)
end

function _M:showAwards(awards)
    if not awards or #awards == 0 then return end

    local static = GlobalHooks.DB.Find("Items", awards[1])
    GameUtil.ShowPickItemEffect(Vector2.New(-30, -100), static.Icon, static.Qcolor, 1)

    if awards[2] then
        local delayAction = DelayAction.New()
        delayAction.Duration = 0.8
        self.menu:AddAction(delayAction)
        delayAction.ActionFinishCallBack = function()
            static = GlobalHooks.DB.Find("Items", awards[2])
            GameUtil.ShowPickItemEffect(Vector2.New(-30, -100), static.Icon, static.Qcolor, 1)
        end
    end
end

function _M:updateTopOneReward()
    if not self.topManItems then
        local items = GlobalHooks.DB.GetGlobalConfig("WorldExp.Winner.ItemList")
        
        items = string.split(items, ',')
        self.topManItems = {}
        for i,v in ipairs(items) do
            table.insert(self.topManItems, {static = GlobalHooks.DB.Find("Items", v)})
        end
    end
    handler_touchCtrlItem(self.ib_one_packs,self.topManItems[1])
end


function _M:updateTopInfo()
    self.lb_player_name.Text = self.info.worldLevelName
    self.lb_level.Text = string.format(formatStrings.lv,self.info.worldLevel)
    local guildText = string.len(self.info.rank1stGuildName) > 0 and self.info.rank1stGuildName or Util.GetText(TextConfig.Type.ATTRIBUTE, 110)
    self.lb_guild_name.Text = guildText
    self.lb_combatpower.Text = self.info.rank1stFight
end

function _M:clearAvatarObj()
    if self.avatarObj then
        IconGenerator.instance:ReleaseTexture(self.avatarKey)
        UnityEngine.Object.DestroyObject(self.avatarObj)
        self.avatarObj = nil
        self.avatarKey = nil
    end
end

function _M:updateAvatar()
    self:clearAvatarObj()
    local list = ListXmdsAvatarInfo.New()
    for i,v in ipairs(self.info.avatars) do
        local info = XmdsAvatarInfo.New()
        GameUtil.setXmdsAvatarInfoTag(info, v.tag)
        
        info.FileName = v.fileName
        info.EffectType = v.effectType
        list:Add(info)
    end

    local filter = bit.lshift(1,  GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
    self.avatarObj, self.avatarKey = GameUtil.Add3DModel(self.cvs_model, "", list, nil, filter, true)
    IconGenerator.instance:SetModelScale(self.avatarKey, Vector3.New(0.85, 0.85, 0.85))
    IconGenerator.instance:SetModelPos(self.avatarKey, Vector3.New(-0.05, -1.15, 2))
    local function onDragAvatar(sender,e)
        if not self.avatarKey then return end

        local deltaX = e.delta.x
        if deltaX ~= 0 then
            
            IconGenerator.instance:SetRotate(self.avatarKey,-deltaX-5)
            print(self.avatarKey)
            print(deltaX)
        end
    end
    self.cvs_model.event_PointerMove = onDragAvatar
    self.cvs_model.EnableOutMove = true
end


function _M:OnEnter()
    self.menu.Visible = true
    
    WorldLvAPI.RequestWorldLv(function(info)
        if self.menu and self.menu.IsRunning then
            
            self.info = info
            self.isMy = info.worldLevelId == DataMgr.Instance.UserData.RoleID
            self.cvs_deatil1.Visible = self.isMy
            self.cvs_reward.Visible = true
            self.cvs_deatil.Visible = not self.isMy
            self.cvs_one.Visible = self.isMy
            if self.isMy then
                self:updateTopManCvs()
            else
                self:updateOtherManCvs()
            end
            self:updateAvatar()
            self:updateTopInfo()
        end
    end)
end

function _M:OnExit()
    self.menu.Visible = false
    self:clearAvatarObj()
end

function _M:OnDestory()
    self.menu = nil
    
    setmetatable(self, nil)
    for k,v in pairs(self) do
        self[k] = nil
    end
end

local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create('xmds_ui/worship/worship.gui.xml',tag)
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.menu:SubscribOnExit( function()
        self:OnExit()
    end )
    self.menu:SubscribOnEnter( function()
        self:OnEnter()
    end )
    self.menu:SubscribOnDestory( function()
        self:OnDestory()
    end )
    
    self.btn_help.event_PointerDown = function()
    self.cvs_detail.Visible = true
    end
    self.btn_help.event_PointerUp = function ()
        self.cvs_detail.Visible = false
    end
end

function _M.Create(tag,param)
    local self = {}
    setmetatable(self,_M)
    InitComponent(self,tag)
    return self
end

return _M

