require "Core.Module.Common.EaseUtil"
require "Core.Module.Common.ResID"

Panel = class("Panel")

--[[	Panel的结构为：
	Panel---trsContent
		  |-trsMask
]]
--
--[[Panel = {
    popupTime = 0.15,

    -- _isStarted = false,
    _isInitedComplete = false,
    _homeDepth = nil,
    -- NGUI
    _luaBehaviour = nil,
    _gameObject = nil,
    _transform = nil,
    _trsMask = nil,
    _trsContent = nil,
    _name = nil,
    _num = 0,
};
]]
local _maskSize = nil;
function Panel.GetMaskSize()
	if _maskSize ~= nil then
		return _maskSize;
	end
	
	--[[	local x;
	local y;
	local sw = AspectUtility.screenWidth;
	local sh = AspectUtility.screenHeight;
	local sx = GameConfig.instance.uiSize.x;
	local sy = GameConfig.instance.uiSize.y;
	if sw * sy > sh * sx then
		x = sy * sw / sh;
        y = sy;
	else
		x = sx;
        y = sx * sh / sw;
	end
	_maskSize = Vector3.New(x, y, 1);--]]
	-- local size = GameConfig.instance.uiSize
	_maskSize = Vector3.New(3000, 3000, 1);
	return _maskSize;
end

function Panel:_GetDefaultDepth()
	return - 1
end
--[[
function Panel:_OnStart()
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_START, self._name);
end
function Panel:_OnEnable()

end
function Panel:_OnDisable()

end
]]
function Panel:IsPopup()
	return true;
end

function Panel:HasMask()
	return self._trsMask ~= nil;
end

function Panel:IsFixDepth()
	return false;
end

function Panel:IsOverMainUI()
	return not self:IsFixDepth();
end

function Panel:GetMask()
	return self._trsMask;
end

function Panel:GetContent()
	return self._trsContent;
end

function Panel:GetGameObject()
	return self._gameObject;
end

function Panel:New()
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	return o;
end

function Panel:EnableTouch()
	Scene.disableTouch = false;
end

function Panel:DisableTouch()
	Scene.disableTouch = true;
end

function Panel:_Dispose()
	
end

function Panel:_OnRecycle()
	if not self._isInitedComplete then
		self:EnableTouch();
	end
	
	self:_Dispose();
	self:_RemoveBtnListen()
	if(self:HasMask()) then
		UIUtil.GetComponent(self._trsMask, "LuaUIEventListener"):RemoveDelegate("OnClick");
		self._onClickMask = nil;
	end
	self.uiPanels = nil;
	self._homeDepth = nil;
	-- NGUI
	PanelManager.RemovePanel(self);
	if(self:_GetDefaultDepth() ~= - 1) then
		local uiPanel = UIUtil.GetComponent(self._gameObject, "UIPanel");
		uiPanel.depth = self:_GetDefaultDepth()
	end
	self._gameObject = nil;
	self._transform = nil;
	self._trsMask = nil;
	self._trsContent = nil;
	self._name = nil
	
	if self.subPanels then 
        for i = #self.subPanels, 1, -1 do
            Resourcer.Recycle(self.subPanels[i], false)
        end
        self.subPanels = nil
    end
	if self._mask then Resourcer.Recycle(self._mask) end
	self._mask = nil;
	
	-- self._luaBehaviour:RemoveDelegate("Start");
	-- self._luaBehaviour:RemoveDelegate("OnEnable");
	-- self._luaBehaviour:RemoveDelegate("OnDisable");
	self._luaBehaviour:RemoveDelegate("OnRecycle");
	self._luaBehaviour = nil;
	if(self._corutine) then
		coroutine.stop(self._corutine)
		self._corutine = nil
	end
	
	
	for k, v in pairs(self) do
		self[k] = nil
	end
	
	--collectgarbage("collect");
end

function Panel:_Init()
	
end

function Panel:_Opened()
	
end

function Panel:GetTrsConten()
    return self._trsContent
end

function Panel:_OnOpened()
	self._isInitedComplete = true;
	self:EnableTouch();
	self:_Opened();
	-- Warning(self._name);
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_OPENED, self._name);
end

function Panel:_Popup()
	self._trsContent.localScale = Vector3.one * 0.01;
	local time = 0;
	local scale = 1;
	while time < self.popupTime do
		coroutine.step();
		time = time + Timer.deltaTime;
		scale = EaseUtil.easeInQuad(0, 1, time / self.popupTime)
		self._trsContent.localScale = Vector3.New(scale, scale, 1);
	end
	self._trsContent.localScale = Vector3.one;
	self:_OnOpened();
end

function Panel:SetActive(active)
	if(self._gameObject and self._isActive ~= active) then
		self._gameObject:SetActive(active);
		self._isActive = active;
	end
end
function Panel:GetActive()
	return self._isActive
end
local temp = ""
function Panel:GetUIOpenSoundName()
	return temp
end

function Panel:_OnInit()
	self._btns = {}
	self._onBtnsClickFunc = function(go) self:_OnBtnsClick(go) end
	self:DisableTouch();
	
	self:InitPanels()
	self:UpdateDepth()

	if self:HasMask() then
		local size = Panel.GetMaskSize();
		local sp = UIUtil.GetComponent(self._trsMask.gameObject, "UISprite");
		if(sp) then
			sp.spriteName = "black"
			sp.depth = - 1;
			sp.width = size.x;
			sp.height = size.y;
			sp.color = Color.New(1, 1, 1, 0.7)
		end
		local bc = UIUtil.GetComponent(self._trsMask.gameObject, "BoxCollider");
		if(bc) then
			bc.center = Vector3.zero;
			bc.size = size;
		end
		self._onClickMask = function(go) self:_OnClickMask(self) end
		UIUtil.GetComponent(self._trsMask, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickMask);
	end
	
	
	-- End NGUI
	--[[	--Begin UGUI
	if self:HasMask() then
		local size = UIPanel.GetMaskSize();
		local rt = self._trsMask.rect;
		rt.width = size.x;
		rt.height = size.y;
		self._trsMask.rect = rt;
	end
	--End UGUI
	--]]
	PanelManager.AddPanel(self);
	local openSoundName = self:GetUIOpenSoundName()
	if(openSoundName and openSoundName ~= "") then
		UISoundManager.PlayUISound(openSoundName)
	end
	self:_Init();
	
	if self:IsPopup() then
		self._corutine = coroutine.start(self._Popup, self);
	else
		self:_OnOpened();
	end
end
-- 调整UIPanel的层级
function Panel:InitPanels()
	-- 记录UIPanel的层级
	self.uiPanels = UIUtil.GetComponentsInChildren(self._gameObject, "UIPanel");
	
	local lastIndex = self.uiPanels.Length - 1;
	self._name = self._gameObject.name
	self._homeDepth = {}
	local element = nil
	
	for i = 0, lastIndex, 1 do
		element = self.uiPanels[i];
		self._homeDepth[element] = element.depth;
	end
end

-- 调整UIPanel的层级
function Panel:UpdateDepth(depth)
	local selfMaxDepth = 0;
	if not self:IsFixDepth() then
		local tmpDepth = 0;
		local maxDepth = depth or PanelManager.GetMaxDepth();
		for i, v in pairs(self._homeDepth) do
			tmpDepth = v + maxDepth;
			i.depth = tmpDepth;
			selfMaxDepth = math.max(selfMaxDepth, tmpDepth)
		end
        self.maxDepth = maxDepth
	end
	self.depth = selfMaxDepth;
end

-- 动态增加子UIPanel
function Panel:AddSubPanel(resId, parent)
    local go = UIUtil.GetUIGameObject(resId, parent or self._trsContent)
    if not self.subPanels then self.subPanels = {} end
    table.insert(self.subPanels, go)
    self:RevertPanelDepths(self.maxDepth)
	self:InitPanels()
	self:UpdateDepth(self.maxDepth)
    return go
end
-- 复原UIPanel的层级
function Panel:RevertPanelDepths(maxDepth)
	local lastIndex = self.uiPanels.Length - 1
	for i = 0, lastIndex, 1 do
		element = self.uiPanels[i]
        element.depth = element.depth - maxDepth
	end
end


function Panel:Init(luaBehaviour, useMask)
	self._luaBehaviour = luaBehaviour;
	self.popupTime = 0.15;
	self._isInitedComplete = false;
	self._num = 0;
	self._gameObject = self._luaBehaviour.gameObject;
	self._transform = self._gameObject.transform;
	self._trsContent = UIUtil.GetChildByName(self._gameObject, "Transform", "trsContent");
	self._trsMask = UIUtil.GetChildByName(self._gameObject, "Transform", "trsMask");
	if useMask then self._mask = Resourcer.Get("GUI", "UI_Screen_Mask", self._transform) end
	
	--self._onStart = function() self:_OnStart() end
	--self._luaBehaviour:RegisterDelegate("Start", self._onStart);
	--self._onEnable = function() self:_OnEnable() end
	--self._luaBehaviour:RegisterDelegate("OnEnable", self._onEnable);
	--self._onDisable = function() self:_OnDisable() end
	--self._luaBehaviour:RegisterDelegate("OnDisable", self._onDisable);
	self._onRecycle = function() self:_OnRecycle() end
	self._luaBehaviour:RegisterDelegate("OnRecycle", self._onRecycle);
	
	SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_INIT, self._gameObject.name);
	self:_OnInit();
end

-- 如果需要点击遮罩响应,重写此函数
function Panel:_OnClickMask()
	
end

function Panel:GetTransformByPath(path)
	local tr = UIUtil.GetChildByName(self._transform, "Transform", path);
	return tr;
end

function Panel:SetPanelLayer(enable)
	if(enable) then
		local lastIndex = self.uiPanels.Length - 1
		for i = 0, lastIndex, 1 do
			NGUITools.SetLayer(self.uiPanels[i].gameObject, Layer.UI)
		end
	else
		local lastIndex = self.uiPanels.Length - 1
		for i = 0, lastIndex, 1 do
			NGUITools.SetLayer(self.uiPanels[i].gameObject, Layer.UnActiveUI)
		end
	end
end

function Panel:SetPanelDepth(go)
	local panels = UIUtil.GetComponentsInChildren(go, "UIPanel");
	
	local lastIndex = panels.Length - 1;
	
	local endIndex = lastIndex + panels.Length
	local element = nil
	local count = 0
	for i = lastIndex, endIndex, 1 do
		element = panels[count];
		self._homeDepth[element] = element.depth;
		count = count + 1
	end
	
	
end

function Panel:_AddBtnListen(btn)
	local listen = UIUtil.GetComponent(btn.gameObject, "LuaUIEventListener")
	listen:RegisterDelegate("OnClick", self._onBtnsClickFunc);
	self._btns[btn] = listen
end

function Panel:_RemoveBtnListen()
	if(self._btns and table.getCount(self._btns) > 0) then
		for k, v in pairs(self._btns) do
			if(v) then
				v:RemoveDelegate("OnClick");
			end
		end
	end
	self._onBtnsClickFunc = nil
end


function Panel:_OnBtnsClick(go)
	
end
