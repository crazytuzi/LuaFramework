require "Core.Module.Common.Panel"

local CreateRoleNewPanel = class("CreateRoleNewPanel", Panel);
local _index = {
	101000, 104000, 103000, 102000
}

function CreateRoleNewPanel:New()
	self = {};
	setmetatable(self, {__index = CreateRoleNewPanel});
	return self
end


function CreateRoleNewPanel:_Init()
	self:_InitReference();
	self:_InitListener();
	self._careerData = {}
	for i, v in ipairs(_index) do
		self._careerData[i] = {}
		setmetatable(self._careerData[i], {__index = ConfigManager.GetCareerByKind(v)})
	end
	
	-- math.randomseed(os.time());
	-- local index = math.ceil(math.Random(1, 4))
	-- self:_OnClickToggle(index)
end

function CreateRoleNewPanel:_InitReference()
	
	self.camParentGo = GameObject.Find("trsCam");
	self._camParent = self.camParentGo and self.camParentGo.transform;
	
	if(self._camParent) then
		self._cam = UIUtil.GetChildByName(self._camParent, "Camera", "Camera");
	end
	if(self._cam) then
		self._cam.gameObject:SetActive(false)
	end
	
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnCreate = UIUtil.GetChildInComponents(btns, "btnCreate");
	self._btnRandomName = UIUtil.GetChildInComponents(btns, "btnRandomName");
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
	local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
	self._trsScene = UIUtil.GetChildInComponents(trss, "trsScene");
	self._trsRole = UIUtil.GetChildInComponents(trss, "trsRole");
	self._trsRoleParent = UIUtil.GetChildInComponents(trss, "trsRoleParent");	
	self._toggle = {}
	for i = 1, 4 do
		self._toggle[i] = UIUtil.GetChildByName(self._trsRole, "UIToggle", "imgCareer" .. i)
	end
	self._roleCache = {};
	self._imgAttrIcon = UIUtil.GetChildByName(self._trsRole, "UISprite", "icoAttr/imgAttrIcon");
	self._imgCareerIco = UIUtil.GetChildByName(self._trsRole, "UISprite", "imgCareerIco");
	self._imgCareerName = UIUtil.GetChildByName(self._trsRole, "UISprite", "imgCareerName");
	
	self._txtPlayerName = UIUtil.GetChildByName(self._trsRole, "UIInput", "txtPlayerName");
	self._txtDesc = UIUtil.GetChildByName(self._trsRole, "UILabel", "txtDesc");		
end

function CreateRoleNewPanel:_InitListener()
	self._onClickToggle1 = function(go) self:_OnClickToggle1(self) end
	UIUtil.GetComponent(self._toggle[1], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle1);
	self._onClickToggle2 = function(go) self:_OnClickToggle2(self) end
	UIUtil.GetComponent(self._toggle[2], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle2);
	self._onClickToggle3 = function(go) self:_OnClickToggle3(self) end
	UIUtil.GetComponent(self._toggle[3], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle3);
	self._onClickToggle4 = function(go) self:_OnClickToggle4(self) end
	UIUtil.GetComponent(self._toggle[4], "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickToggle4);
	
	
	
	self._onClickBtnCreate = function(go) self:_OnClickBtnCreate(self) end
	UIUtil.GetComponent(self._btnCreate, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnCreate);
	self._onClickBtnRandomName = function(go) self:_OnClickBtnRandomName(self) end
	UIUtil.GetComponent(self._btnRandomName, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRandomName);
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function CreateRoleNewPanel:_OnClickToggle1()
	
	self:_OnClickToggle(1)
end

function CreateRoleNewPanel:_OnClickToggle2()
	self:_OnClickToggle(2)
end

function CreateRoleNewPanel:_OnClickToggle3()
	self:_OnClickToggle(3)
end

function CreateRoleNewPanel:_OnClickToggle4()
	self:_OnClickToggle(4)
end

function CreateRoleNewPanel:_OnClickToggle(index)
	self._toggle[index].value = true
	self:UpdatePanel(self._careerData[index])	
end

function CreateRoleNewPanel:_OnClickBtnCreate()
	SelectRoleProxy.TryCreateRole(self.data, self._txtPlayerName.value);
end

function CreateRoleNewPanel:_OnClickBtnRandomName()
	if(self.data) then
		SelectRoleProxy.GetRandomName(self.data.sex);
	end
end

function CreateRoleNewPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(SelectRoleNotes.CLOSE_CREATEROLEPANEL);
	local pl = PlayerManager.GetAllPlayerData();
	if pl == nil or table.getCount(pl) == 0 then
		-- 还没有角色, 返回登录
		ModuleManager.SendNotification(LoginNotes.OPEN_LOGIN_PANEL);
	else
		ModuleManager.SendNotification(SelectRoleNotes.OPEN_SELECTROLE_PANEL);
	end
end

function CreateRoleNewPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function CreateRoleNewPanel:_DisposeListener()
	UIUtil.GetComponent(self._toggle[1], "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggle1 = nil;
	UIUtil.GetComponent(self._toggle[2], "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggle2 = nil;
	UIUtil.GetComponent(self._toggle[3], "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggle3 = nil;
	UIUtil.GetComponent(self._toggle[4], "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickToggle4 = nil;
	
	UIUtil.GetComponent(self._btnCreate, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnCreate = nil;
	UIUtil.GetComponent(self._btnRandomName, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnRandomName = nil;
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
end

function CreateRoleNewPanel:_DisposeReference()
	self._btnCreate = nil;
	self._btnRandomName = nil;
	self._btn_close = nil;
	self._txtDesc = nil;
	self._imgRole = nil;
	self._imgAttrIcon = nil;
	self._imgCareerIco = nil;
	
	self._imgCareerName = nil;
	self._trsScene = nil;
	self._trsRole = nil;
	self._trsRoleParent = nil;
	self._careerData = nil
	for k, v in pairs(self._roleCache) do
		Resourcer.Recycle(v, false);
	end
	self._roleCache = nil
	self._showScene = nil
	self._uiModelAni = nil
	
end

function CreateRoleNewPanel:UpdatePanel(data)
	if(self.data ~= nil) then
		if(self.data.id == data.id) then
			return
		end
	end
	 
	self.data = data
	if(self.data) then	
		RenderSettings.fogColor = Color.New(self.data.cr_fog[1] / 255,
		self.data.cr_fog[2] / 255, self.data.cr_fog[3] / 255, self.data.cr_fog[4] / 255)
		RenderSettings.ambientLight = Color.New(self.data.cr_color[1] / 255,
		self.data.cr_color[2] / 255, self.data.cr_color[3] / 255, self.data.cr_color[4] / 255)
		
		local kind = self.data.id
		self._txtDesc.text = self.data.desc
		self._imgAttrIcon.spriteName = "a" .. kind;	
		self._imgCareerIco.spriteName = "ico" .. kind
		self._imgCareerName.spriteName = "career" .. kind
		self:_GetCreateRoleBg(self.data)
		self:_OnClickBtnRandomName()
	end
	
end

function CreateRoleNewPanel:_GetCreateRoleBg(data)
	if(self._showScene) then
		self._showScene:SetActive(false)
	end
	if self._roleCache[data.id] == nil then
		local showGo = Resourcer.Get("Prefabs/CreateRoleBgs", tostring(data.id), self._trsScene);
		self._roleCache[data.id] = showGo;
		self._showScene = showGo;
	else
		self._showScene = self._roleCache[data.id];
	end
	
	if(self._showScene) then
		self._uiModelAni = UIUtil.GetChildByName(self._showScene, "Animator", "role");		
		self._showScene:SetActive(true)
		self._uiModelAni:Play("show", 0, 0)
	end
	
end

function CreateRoleNewPanel:UpdateName(name)
	self._txtPlayerName.value = name
end
return CreateRoleNewPanel 