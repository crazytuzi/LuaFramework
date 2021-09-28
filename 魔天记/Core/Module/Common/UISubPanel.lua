UISubPanel = class("UISubPanel");

function UISubPanel:ctor(transform)
	if transform then
		self:Init(transform);
	end
end

function UISubPanel:Init(transform)
	self._transform = transform;
	self._gameObject = transform.gameObject;
	self._btns = {}
	self._onBtnsClickFunc = function(go) self:_OnBtnsClick(go) end
	self:_InitReference();
end

function UISubPanel:Dispose()
	self:Disable();
	self:_DisposeReference();
	self:_Dispose();
	
	for k, v in pairs(self) do
		self[k] = nil;
	end
end

function UISubPanel:_Dispose()
	
end

function UISubPanel:Enable()
	if self._enable == nil or self._enable == false then
		--self._transform.gameObject:SetActive(true);
		self:_SetEnable(true);
		self:_InitListener();
	end
	self:_OnEnable();
	self._enable = true;
end

function UISubPanel:Disable()
	if self._enable == nil or self._enable == true then
		--self._transform.gameObject:SetActive(false);
		self:_SetEnable(false);
		self:_DisposeListener();
	end
	self:_OnDisable();
	self._enable = false;
end

function UISubPanel:_OnEnable()
	
end

function UISubPanel:_OnDisable()
	
end


function UISubPanel:Refresh()
	self:_Refresh();
end

function UISubPanel:_Refresh()
	
end

function UISubPanel:_InitReference()
	
end

function UISubPanel:_DisposeReference()
	
end

function UISubPanel:_InitListener()
	
end

function UISubPanel:_DisposeListener()
	
end

function UISubPanel:_SetEnable(enable)
	Util.SetLocalPos(self._transform, enable and uiEnablePos or uiDisablePos)
	
	--    self._transform.localPosition = enable and uiEnablePos or uiDisablePos;
end

function UISubPanel:_AddBtnListen(btn)
	local listen = UIUtil.GetComponent(btn.gameObject, "LuaUIEventListener")
	listen:RegisterDelegate("OnClick", self._onBtnsClickFunc);
	self._btns[btn] = listen
end

function UISubPanel:_RemoveBtnListen()
	if(self._btns and table.getCount(self._btns) > 0) then
		for k, v in pairs(self._btns) do
			if(v) then
				v:RemoveDelegate("OnClick");
			end
		end
	end
	self._onBtnsClickFunc = nil
end

function UISubPanel:_OnBtnsClick(go)
	
end
