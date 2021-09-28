require "Core.Module.Common.Panel"
require "Core.Module.Common.Phalanx"
require "Core.Module.SelectRole.View.CreateRoleItem"
require "Core.Module.SelectRole.SelectRoleProxy"
require "Core.Role.ModelCreater.RoleModelCreater"

CreateRolePanel = Panel:New();

CreateRolePanel.Mode = {
    TYPE = 1;
    ROLE = 2;
}

CreateRolePanel.Index = {
    101000,104000,103000,102000
}


function CreateRolePanel:GetUIOpenSoundName( )
    return ""
end 

function CreateRolePanel:IsPopup( )
    return false
end

function CreateRolePanel:_Init()
    self:_InitReference();
    self:_InitListener(); 
    RenderSettings.ambientLight = Color.New(180/255, 180/255, 180/255);
    self._clickBtnCreateTime = 0;
    self:_SetDisplay(CreateRolePanel.Mode.TYPE);
end

function CreateRolePanel:_InitReference()
    
    self._animFx = UIUtil.GetChildByName(self._trsContent, "Transform", "fx");
    self:SetWaterFx(false);
    
    self._trsType = UIUtil.GetChildByName(self._trsContent, "Transform", "trsType");
    self._trsRole = UIUtil.GetChildByName(self._trsContent, "Transform", "trsRole");
    self._trsScene = UIUtil.GetChildByName(self._trsContent, "Transform", "trsScene");
    self._trsFx = UIUtil.GetChildByName(self._trsContent, "Transform", "trsFx");

    self._btnReturn1 = UIUtil.GetChildByName(self._trsType, "UIButton", "btnReturn1");
    self._btnReturn2 = UIUtil.GetChildByName(self._trsRole, "UIButton", "btnReturn2");
    
    --self._typeBg = UIUtil.GetChildByName(self._trsType, "UITexture", "bg");
    self._typeBgPlane = UIUtil.GetChildByName(self._trsType, "Transform", "bgPlane");
    self._typeBgMat = self._typeBgPlane.renderer.material;
    self._typeAnim = false;
    self._typeAnimSize = 0;

    self._btnCreate = UIUtil.GetChildByName(self._trsRole, "UIButton", "btnCreate");
    self._btnRandomName = UIUtil.GetChildByName(self._trsRole, "UIButton", "btnRandomName");
    self._txtPlayerName = UIUtil.GetChildByName(self._trsRole, "UIInput", "txtPlayerName");
    
    self._imgRole = UIUtil.GetChildByName(self._trsRole, "UISprite", "imgRole");
    --self._roleParent = UIUtil.GetChildByName(self._imgRole, "heroCamera/trsRoleParent");
    
    self._ico = UIUtil.GetChildByName(self._trsRole, "UISprite", "ico");
    self._icoBg = UIUtil.GetChildByName(self._trsRole, "UISprite", "ico/icoBg");
    self._icoAttr = UIUtil.GetChildByName(self._trsRole, "UISprite", "icoAttr/icoCurAttr");
    self._txtDesc = UIUtil.GetChildByName(self._trsRole, "UILabel", "txtDesc");

    local data = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_CAREER)
    self.data = { }
    for i,v in ipairs(CreateRolePanel.Index) do
        local tmp = ConfigManager.Clone(data[v]);
        tmp.kind = v
        table.insert(self.data, tmp);
    end

    --初始化职业特效
    self._typeFxs = {};
    for i = 1, 4 do
        local tmpFx = UIUtil.GetChildByName(self._trsFx, "Transform", "fx"..i);
        tmpFx.gameObject:SetActive(false);
        self._typeFxs[i] = tmpFx;
    end
    --初始化职业点击特效
    self._typeClickFxs = {};
    for i = 1, 4 do
        local tmpClickFx = UIUtil.GetChildByName(self._trsFx, "Transform", "fx1"..i);
        tmpClickFx.gameObject:SetActive(false);
        self._typeClickFxs[i] = tmpClickFx;
    end
    --初始化职业sprite
    self.typeRoles = {};
    for i = 1, 4 do
        local roleSpr = UIUtil.GetChildByName(self._trsType, "UISprite", "role"..i);
        self.typeRoles[i] = roleSpr;
    end
    --初始化职业高模
    self.trRoleParent = UIUtil.GetChildByName(self._trsRole, "Transform", "imgRole/heroCamera/trsRoleParent");
    self.roles = {};
    for i = 1, self.trRoleParent.childCount do
        local tr = self.trRoleParent:GetChild(i - 1);
        self.roles[tr.name] = tr;
    end
    self._roleCache = {};
    
    self._playTypeFx = false;
    self._playTypeTime = 0;
    self._rotY = 0;
    self._canDrag = false;

end

function CreateRolePanel:_InitListener()
    UpdateBeat:Add(self.Update, self)

    self._onTypeRoleClick = function(go) self:_OnTypeRoleClick(go); end;
    for k,v in pairs(self.typeRoles) do
        UIUtil.GetComponent(v, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onTypeRoleClick);
    end

    --self._onTypeBgRender = DelegateFactory.UIDrawCall_OnRenderCallback( function(mat) self:_OnTypeBgRender(mat) end);
    --self._typeBg.onRender = self._typeBg.onRender + self._onTypeBgRender;
    
    self._onClickBtnCreate = function(go) self:_OnClickBtnCreate(self) end
    UIUtil.GetComponent(self._btnCreate, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCreate);
    self._onClickBtnReturn = function(go) self:_OnClickBtnReturn(self) end
    UIUtil.GetComponent(self._btnReturn1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReturn);
    UIUtil.GetComponent(self._btnReturn2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReturn);
    self._onClickBtnRandomName = function(go) self:_OnClickBtnRandomName(self) end
    UIUtil.GetComponent(self._btnRandomName, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRandomName);
    
    self._onImgRoleDrag = function (go, delta) self:_OnImgRoleDrag(go,delta) end;
    UIUtil.GetComponent(self._imgRole, "LuaUIEventListener"):RegisterDelegate("OnDrag", self._onImgRoleDrag);

end 

function CreateRolePanel:Update()
    if self._clickBtnCreateTime > 0 then
        self._clickBtnCreateTime = self._clickBtnCreateTime - Time.unscaledTime;
    end

    if self._typeAnim then
        self._typeAnimSize = self._typeAnimSize + 1;
        
        if self._typeAnimSize > 100 then
            self._typeAnimSize = 0;
            self:_OnTypeAnimComplete();
            return;
        end
        self:_OnTypeBgRender(self._typeBgMat);
    end

    if self.mode == CreateRolePanel.Mode.ROLE then 
        if not self._canDrag and self._uiModelAni and self._uiModelAni:GetCurrentAnimatorStateInfo(0):IsName("Base Layer.stand") then
            self._canDrag = true;
        end
    end

    if self._playTypeFx then
        self._playTypeTime = self._playTypeTime + Timer.deltaTime;
        if self._playTypeTime > 0 then
            self:SetTypeFx(true);
            self._playTypeFx = false;
        end
    else
        self._playTypeTime = 0;
    end
end

function CreateRolePanel:_OnTypeBgRender(mat)
    if mat then
        local val = math.max(self._typeAnimSize - 30, 0) / 70 * 10;
        mat:SetFloat("_radius", val);
    end
end

function CreateRolePanel:_OnTypeAnimComplete()
    self._typeAnim = false;
    
    if self.select_data and self.select_data.id == 102000 or self.select_data.id == 103000 then
        self._uiAnimationModel.gameObject:SetActive(true);
    end

    self:_SetDisplay(CreateRolePanel.Mode.ROLE);   
    self:SetWaterFx(false);
    self._trsScene.gameObject:SetActive(true);
end
 
function CreateRolePanel:_OnTypeRoleClick(itemGo)
    if self._typeAnim == false and self.mode == CreateRolePanel.Mode.TYPE then
        local index = tonumber(string.sub(itemGo.name,5));
        self:SetSelect(self.data[index]);
        self:SetTypeClickFx(index);
    end
end

function CreateRolePanel:_SetDisplay(mode)
    if self.mode ~= mode then
        if mode == CreateRolePanel.Mode.TYPE then
            self._trsType.gameObject:SetActive(true);
            self._trsRole.gameObject:SetActive(false);
            --self._trsScene.gameObject:SetActive(false);
            self:ResetToType();
            self:SetWaterFx(true);
            self._playTypeFx = true;
        else
            self._trsRole.gameObject:SetActive(true);
            self._trsType.gameObject:SetActive(false);
            self:DoRoleAction(1);
            self:SetTypeFx(false);
        end
        self.mode = mode;
    end
end

function CreateRolePanel:ResetToType()
    self:DoRoleAction(0);       --人物待机
    self:_OnTypeBgRender(self._typeBgMat);
    if self._showScene then
        self._roleBg.localRotation = Quaternion.identity;               --恢复背景旋转
        self._uiAnimationModel.localRotation = Quaternion.identity;     --恢复人物旋转
        if self._uiModelAniFx then
            self._uiModelAniFx.gameObject:SetActive(false);                 --关闭动作特效
        end
        --UIUtil.RemoveAllChildren(self._trsScene);
        self._showScene.gameObject:SetActive(false);
        self._showScene = nil;   
        self._rotY = 0;                               
    end
    self._canDrag = false;
    self:SetTypeClickFx(0);
end

function CreateRolePanel:SetSelectHero(data)
    
    if self._roleCache[data.id] == nil then
        local showGo = Resourcer.Get("Prefabs/CreateRoleBgs", tostring(data.id), self._trsScene);
        self._roleCache[data.id] = showGo;
        self._showScene = showGo;
    else
        self._showScene = self._roleCache[data.id];
    end
        
    --显示场景
    --self._showScene = UIUtil.GetChildByName(self._trsScene, "Transform", "BG_creatRole_sky");
    self._showScene.gameObject:SetActive(true);
    --场景背景
    self._roleBg = UIUtil.GetChildByName(self._showScene, "Transform", "bg");
    --场景人物
    self._uiAnimationModel = UIUtil.GetChildByName(self._showScene, "Transform", "role");
    --人物动作控制器
    self._uiModelAni = UIUtil.GetChildByName(self._showScene, "Animator", "role");
    --人物特效
    self._uiModelAniFx = UIUtil.GetChildByName(self._uiAnimationModel, "Transform", "showRole");
    if self._uiModelAniFx then
        self._uiModelAniFx.gameObject:SetActive(false);    
    end
    
    --这2个职业要飞, 切模式的时候先隐藏.
    if data.id == 102000 or data.id == 103000 then
        self._uiAnimationModel.gameObject:SetActive(false);
    end

    if (self.select_data == nil or data.id ~= self.select_data.id) then 
        self.select_data = data;
        self:_OnClickBtnRandomName(); 
        self:_UpdateRoleInfo();
    end
    
end 

function CreateRolePanel:SetSelect(data)
    self:SetSelectHero(data);
    self._typeAnim = true;
    self:SetWaterFx(true);
    
end

function CreateRolePanel:_UpdateRoleInfo()
    local kind = self.select_data.kind;
    self._ico.spriteName = "ico"..kind;
    self._ico:MakePixelPerfect();
    self._icoBg.spriteName = "icoBg"..kind;
    self._icoAttr.spriteName = "a"..kind;
    self._txtDesc.text = self.select_data.desc;
end

function CreateRolePanel:_OnClickBtnCreate()
    if self._clickBtnCreateTime <= 0 then
        SelectRoleProxy.TryCreateRole(self.select_data, self._txtPlayerName.value);
        self._clickBtnCreateTime = 1;
    end
end

function CreateRolePanel:_OnClickBtnReturn() 
    if self.mode == CreateRolePanel.Mode.TYPE then
        ModuleManager.SendNotification(SelectRoleNotes.CLOSE_CREATEROLEPANEL);
        local pl = PlayerManager.GetAllPlayerData();
        if pl == nil or table.getCount(pl) == 0 then
        -- 还没有角色, 返回登录
            ModuleManager.SendNotification(LoginNotes.OPEN_LOGIN_PANEL); 
        else
            ModuleManager.SendNotification(SelectRoleNotes.OPEN_SELECTROLE_PANEL);
        end
    else
        self:_SetDisplay(CreateRolePanel.Mode.TYPE);
    end
end

function CreateRolePanel:_OnClickBtnRandomName() 
    local sex = self.select_data.sex; 
    self.getRoldNameHandler = function(name)
        self._txtPlayerName.value = name;
    end 
    SelectRoleProxy.GetRandomName(self.getRoldNameHandler, sex); 
end

function CreateRolePanel:_OnImgRoleDrag(go,delta)
    if not self._canDrag or not self._roleBg then
        return;
    end

    local roleBgTr = self._roleBg;
    local bgRot = self._rotY;
    bgRot = bgRot - delta.x / 16;
    bgRot = math.clamp(bgRot, -40, 40);
    roleBgTr.eulerAngles = Vector3.New(0, bgRot, 0);
    if self._uiAnimationModel then
        local roleTr = self._uiAnimationModel;
        local rotY = bgRot * 150 / 40;
        roleTr.localRotation = Quaternion.Euler(0, rotY, 0);
    end
    self._rotY = bgRot;
end

function CreateRolePanel:DoRoleAction(idx)
    if self._uiAnimationModel and self._uiModelAni then
        self._uiModelAni:Play(idx > 0 and "show" or "stand");
        if self._uiModelAniFx then
            self._uiModelAniFx.gameObject:SetActive(false);
            if idx > 0 then
                self._uiModelAniFx.gameObject:SetActive(true);
            end
        end
    end
end

function CreateRolePanel:SetWaterFx(bool)
    
    if bool then
        self._animFx.gameObject:SetActive(false);
    end
    self._animFx.gameObject:SetActive(bool);
    
end

function CreateRolePanel:SetTypeFx(bool)
    for k,v in pairs(self._typeFxs) do
        if bool then
            v.gameObject:SetActive(false);
        end
        v.gameObject:SetActive(bool);
    end
end

function CreateRolePanel:SetTypeClickFx(idx)
    for k,v in pairs(self._typeClickFxs) do
        v.gameObject:SetActive(k == idx);
    end
end


function CreateRolePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    RenderSettings.ambientLight = Color.New(51/255, 51/255, 51/255);
    --[[
    if (self._uiAnimationModel ~= nil) then
        self._uiAnimationModel:Dispose()
        self._uiAnimationModel = nil
    end
    ]]
    --self.phalanx:Dispose()
end

function CreateRolePanel:_DisposeListener()
    UpdateBeat:Remove(self.Update, self)
    --self._typeBg.onRender = self._typeBg.onRender - self._onTypeBgRender;

    for k,v in pairs(self.typeRoles) do
        UIUtil.GetComponent(v, "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    
    UIUtil.GetComponent(self._btnCreate, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnCreate = nil;
    UIUtil.GetComponent(self._btnReturn1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnReturn2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReturn = nil;
    UIUtil.GetComponent(self._btnRandomName, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnRandomName = nil;

    UIUtil.GetComponent(self._imgRole, "LuaUIEventListener"):RemoveDelegate("OnDrag");
    self._onImgRoleDrag = nil;
end

function CreateRolePanel:_DisposeReference()
    self._btnCreate = nil;
    self._btnReturn1 = nil;
    self._btnReturn2 = nil;
    self._btnRandomName = nil;


    for k,v in pairs(self._roleCache) do
        Resourcer.Recycle(v, false);
    end

end
