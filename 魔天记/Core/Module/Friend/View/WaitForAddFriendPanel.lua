require "Core.Module.Common.Panel"

local WaitForAddFriendPanel = class("WaitForAddFriendPanel", Panel);
function WaitForAddFriendPanel:New()
    self = { };
    setmetatable(self, { __index = WaitForAddFriendPanel });
    return self
end


function WaitForAddFriendPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function WaitForAddFriendPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btn_ok = UIUtil.GetChildInComponents(btns, "btn_ok");
    self._btn_no = UIUtil.GetChildInComponents(btns, "btn_no");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self.roleItems = { };
    self.roleItemNum = 3;

    for i = 1, self.roleItemNum do

        self.roleItems[i] = UIUtil.GetChildByName(self.mainView, "Transform", "roleItem" .. i);

        
    end

end

function WaitForAddFriendPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
    self._onClickBtn_no = function(go) self:_OnClickBtn_no(self) end
    UIUtil.GetComponent(self._btn_no, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_no);
end

function WaitForAddFriendPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(FriendNotes.CLOSE_WAITFORADDFRIENDPANEL);
end

function WaitForAddFriendPanel:_OnClickBtn_ok()

    if self.listData ~= nil then
      
        local t_num = table.getn(self.listData);
        for i = 1, t_num do
            local pid = self.listData[i].pid;

            AddFriendsProxy.TryAddFriend(pid);
        end

    end

      self:_OnClickBtn_close();
end

function WaitForAddFriendPanel:_OnClickBtn_no()
    self:_OnClickBtn_close()
end

--[[
 [ {"n":"\u9F9A\u73EE","pid":"20100368","k":103000,"hp":3211,"p":0,"mp":3583,"l":41,"f":26393} ]
]]
function WaitForAddFriendPanel:SetOpenParam(list)

   
    self.listData = list;

    for i = 1, self.roleItemNum do
        self:SetRoleItemData(i, self.listData[i])
    end

end

function WaitForAddFriendPanel:SetRoleItemData(index, data)

    local tg = self.roleItems[index];

    if data == nil then
        tg.gameObject:SetActive(false);
    else

        local icon = UIUtil.GetChildByName(tg, "UISprite", "icon");
        local name = UIUtil.GetChildByName(tg, "UILabel", "name");
        local level = UIUtil.GetChildByName(tg, "UILabel", "level");

        icon.spriteName = ConfigManager.GetCareerByKind(data.k).icon_id;
        name.text = data.n;
        level.text = data.l .. "";


        tg.gameObject:SetActive(true);
    end

end

function WaitForAddFriendPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function WaitForAddFriendPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_ok = nil;
    UIUtil.GetComponent(self._btn_no, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_no = nil;
end

function WaitForAddFriendPanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_ok = nil;
    self._btn_no = nil;
end
return WaitForAddFriendPanel