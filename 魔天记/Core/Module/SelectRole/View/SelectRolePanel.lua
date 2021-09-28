require "Core.Module.Common.Panel"
 
require "Core.Module.Common.Phalanx"
require "Core.Module.SelectRole.View.CareerItem"
require "Core.Module.SelectRole.SelectRoleProxy"
require "Core.Manager.PlayerManager"
require "Core.Role.ModelCreater.RoleModelCreater"


SelectRolePanel = Panel:New();

SelectRolePanel.ROLEPARENT = "trsRole";
SelectRolePanel.CAMPARENT = "trsCam";
SelectRolePanel.ANI_INTERVAL = 4;
function SelectRolePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SelectRolePanel:GetUIOpenSoundName( )
    return ""
end

function SelectRolePanel:IsPopup( )
    return false
end

function SelectRolePanel:_InitReference()
    GameSceneManager.SetActive(true);
    self._btnEnter = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnEnter");
    self._btnReturn = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnReturn");

    self._imgRole = UIUtil.GetChildByName(self._trsContent, "UISprite", "imgRole");
    self._roleParent = UIUtil.GetChildByName(self._trsContent, "trsRoleParent")

    -- self._roleParentGo = GameObject.Find(SelectRolePanel.ROLEPARENT);
    -- self._roleParent = self._roleParentGo and self._roleParentGo.transform;

    local trsPos = GameObject.Find(SelectRolePanel.ROLEPARENT);
    if trsPos then
        trsPos = trsPos.transform;
        Util.SetPos(self._roleParent, trsPos.position)
        --        self._roleParent.position = trsPos.position;
        self._roleParent.rotation = trsPos.rotation;
        -- local scale = Vector3.New(trsPos.lossyScale.x / self._roleParent.lossyScale.x, trsPos.lossyScale.y / self._roleParent.lossyScale.y, trsPos.lossyScale.z / self._roleParent.lossyScale.z);
        local scale = Vector3.New(360, 360, 360);
        self._roleParent.localScale = scale;
    end

    self.camParentGo = GameObject.Find(SelectRolePanel.CAMPARENT);
    self._camParent = self.camParentGo and self.camParentGo.transform;

    self._cam = UIUtil.GetChildByName(self._camParent, "Camera", "Camera");
    if(self._cam) then
        self._cam.gameObject:SetActive(true)
    end
    -- self._cam:SetActive(true)
    --    AspectUtility.setCameraRect(self._cam);

    self._items = { };

    for i = 1, 4 do
        local itemGo = UIUtil.GetChildByName(self._trsContent, "Transform", "heroItem" .. i);
        local item = CareerItem:New();
        item:Init(itemGo);
        self._items[i] = item;
    end

    self._aniTime = SelectRolePanel.ANI_INTERVAL;
    self._rotY = 0;
    self._canDrag = true;
end

function SelectRolePanel:_InitListener()
    self._onClickBtnEnter = function(go) self:_OnClickBtnEnter(self) end
    UIUtil.GetComponent(self._btnEnter, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnEnter);
    self._onClickBtnReturn = function(go) self:_OnClickBtnReturn(self) end
    UIUtil.GetComponent(self._btnReturn, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReturn);

    self._onImgRoleDrag = function(go, delta) self:_OnImgRoleDrag(go, delta) end;
    UIUtil.GetComponent(self._imgRole, "LuaUIEventListener"):RegisterDelegate("OnDrag", self._onImgRoleDrag);

    UpdateBeat:Add(self.OnUpdate, self);
end

function SelectRolePanel:_OnClickBtnEnter()
    local lev = self._selectInfo.level
    if not AppSplitDownProxy.InGameCheckLoad( function() SelectRoleProxy.TryInGame(self._selectInfo) end, lev) then
        return
        -- 补丁包没下载完
    end
    SelectRoleProxy.TryInGame(self._selectInfo);
end

function SelectRolePanel:_OnClickBtnReturn()
    SocketClientLua.Get_ins():Close();
    ModuleManager.SendNotification(SelectRoleNotes.CLOSE_SELECTROLE_PANEL);
    ModuleManager.SendNotification(LoginNotes.OPEN_GOTOGAME_PANEL);
    -- Reconnect.TryConnect();
end

function SelectRolePanel:UpData()
    local pl = PlayerManager.GetAllPlayerData();

    if pl == nil then
        -- 还没有角色，需要创建
        ModuleManager.SendNotification(SelectRoleNotes.CLOSE_SELECTROLE_PANEL);
        ModuleManager.SendNotification(SelectRoleNotes.OPEN_CREATEROLEPANEL);
    else
        local len = table.getn(pl);
        for i = 1, 4 do
            if i <= len then
                --                self.heros[i]:SetData(pl[i], self._trsContent);
                self._items[i]:SetData(pl[i]);
                -- 创建角色
            else
                self._items[i]:SetForCreateRolePanel();
                -- 创建角色
            end

        end
        -- 显示默认值
        self:SetSelectHero(pl[PlayerManager.GetLastPlayerIndex()]);
    end

    if GameConfig.instance.autoLogin then 
        ModuleManager.SendNotification(NoticeNotes.CLOSE_NOTICE_PANEL)
        ModuleManager.SendNotification(NoticeNotes.CLOSE_NOTICE_PANEL2)
        SelectRoleProxy.TryInGame(self._selectInfo)
    end
end

function SelectRolePanel:SetSelectHero(hinfo)
    if (hinfo == nil or(self._selectInfo and hinfo.id == self._selectInfo.id)) then return end

    self._selectInfo = hinfo;

    if (self._uiAnimationModel == nil) then
        self._uiAnimationModel = UIAnimationModel:New(self._selectInfo, self._roleParent, RoleModelCreater)
    else
        self._uiAnimationModel:ChangeModel(self._selectInfo, self._roleParent)
    end

    for k, v in pairs(self._items) do
        v:SetSelect(v.data == hinfo);
    end

    self._aniTime = SelectRolePanel.ANI_INTERVAL;
end 

function SelectRolePanel:_OnImgRoleDrag(go, delta)
    if not self._canDrag or not self._camParent then
        return;
    end
    local rotTr = self._camParent;
    local bgRot = self._rotY;
    bgRot = bgRot + delta.x / 16;
    bgRot = math.clamp(bgRot, -40, 40);
    rotTr.eulerAngles = Vector3.New(0, bgRot, 0);
    self._rotY = bgRot;
end

function SelectRolePanel:OnUpdate()
    self._aniTime = self._aniTime - Timer.deltaTime;
    if self._aniTime <= 0 then
        self._aniTime = SelectRolePanel.ANI_INTERVAL + 2;

        if (self._uiAnimationModel ~= nil) then
            self._uiAnimationModel:Play(RoleActionName.wait);
        end
    end
end

function SelectRolePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    if (self._uiAnimationModel ~= nil) then
        self._uiAnimationModel:Dispose()
        self._uiAnimationModel = nil
    end

    for k, v in pairs(self._items) do
        v:Dispose();
    end
    self._items = nil

end

function SelectRolePanel:_DisposeListener()
    UIUtil.GetComponent(self._btnEnter, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnEnter = nil;
    UIUtil.GetComponent(self._btnReturn, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReturn = nil;

    UIUtil.GetComponent(self._imgRole, "LuaUIEventListener"):RemoveDelegate("OnDrag");
    self._onImgRoleDrag = nil;

    UpdateBeat:Remove(self.OnUpdate, self);
end

function SelectRolePanel:_DisposeReference()
    self._btnEnter = nil;
    self._btnReturn = nil;

    GameSceneManager.SetActive(false);
end
