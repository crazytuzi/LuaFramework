local Util = require "Zeus.Logic.Util"
local FriendAPI = require "Zeus.Model.Friend"

local FriendSelectUI = {
    menu = nil
}
Util.WrapOOPSelf(FriendSelectUI)
Util.WrapCreateUI(FriendSelectUI)



function FriendSelectUI:init(tag, params)
    self.menu = LuaMenuU.Create("xmds_ui/mall/gift.gui.xml", tag)
    self.cell = self.menu:GetComponent("cvs_player_single")
    self.scrollPan = self.menu:GetComponent("sp_gift_all")
    self.cell.Visible = false
    self.scrollPanInited = false
    self.menu.Enable = true
    self.menu.IsInteractive = true
    self.menu.event_PointerClick = function()
        self.menu:Close()
    end
    

    
    self.menu:SubscribOnEnter(self._self_onEnter)
    self.menu:SubscribOnExit(self._self_onExit)
    self.menu:SubscribOnDestory(self._self_onDestroy)
end

function FriendSelectUI:setCallback(cb)
    self.cb = cb
end

local function friendsSortCamp(a, b)
    return a.friendLv > b.friendLv
end

function FriendSelectUI:updateFriendList(friendList)
    self.friendList = friendList or {}
    table.sort(self.friendList, friendsSortCamp)
    

    if self.scrollPanInited then
        self.scrollPan:ResetRowsAndColumns(#self.friendList, 1)
    else
        self.scrollPan:Initialize(self.cell.Width, self.cell.Height,
             #self.friendList, 1, self.cell, self._self_updateCell, self._self_initCell)
        self.scrollPanInited = true
    end
end

function FriendSelectUI:initCell(cell)
    cell:FindChildByEditName("btn_gift", true).TouchClick = self._self_onApplyBtnClick
end

function FriendSelectUI:updateCell(gx, gy, cell)
    local idx = gy + 1
    cell:FindChildByEditName("btn_gift", true).UserTag = idx

    local info = self.friendList[idx]

   
    cell:FindChildByEditName("ib_rank_num", true).Text = tostring(info.level)
    
   








    local headIcon = cell:FindChildByEditName("ib_player_icon", true)
    Util.HZSetImage(headIcon, PublicConst.GetProIcon(info.pro))
    local nameLabel = cell:FindChildByEditName("lb_player_name", true)
    nameLabel.Text = info.name
    nameLabel.FontColor = GameUtil.RGBA2Color(GameUtil.GetProColor(info.pro))
    local guildLabel = cell:FindChildByEditName("lb_union_name", true)
    guildLabel.Text = (info.guildName == "" and Util.GetText(TextConfig.Type.GUILD, "noguild") or info.guildName)
end

function FriendSelectUI:onApplyBtnClick(sender)
    if self.cb then
        self.cb(self.friendList[sender.UserTag])
    end
    self.menu:Close()
end

function FriendSelectUI:onEnter()
    self.menu.Visible = false
    FriendAPI.friendGetAllFriendsRequest(function(data)
        if self.menu and self.menu.IsRunning then
            self.menu.Visible = true
            self:updateFriendList(data.friends)
        end
    end,
    function()
        if self.menu then
            self.menu:Close()
        end
    end)
end

function FriendSelectUI:onExit()
    
end

function FriendSelectUI:onDestroy()
    self.menu = nil
    
    setmetatable(self, nil)
    for k,v in pairs(self) do
        self[k] = nil
    end
end

return FriendSelectUI
