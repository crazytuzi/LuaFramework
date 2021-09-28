require "Core.Module.Confirm.View.BaseConfirmPanel"
Confirm2Panel = class("Confirm2Panel", BaseConfirmPanel);

local _btnLabel = LanguageMgr.Get("common/ok") .. "(%s)";

function Confirm2Panel:_Init()
	self._luaBehaviour.canPool = true
	self:_InitReference();
	self:_InitListener();
end

function Confirm2Panel:_InitReference()
	self._txt_title = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title");
	self._txt_label = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_label");
	self._btn_ok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_ok");
	self._btn_label = UIUtil.GetChildByName(self._btn_ok, "UILabel", "Label");
	self._timer = Timer.New( function() self:_OnTimerHandler() end, 1, -1, false);
end

function Confirm2Panel:_InitListener()
	self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
	UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
end


function Confirm2Panel:_OnClickBtn_ok()
	-- tangping
	if self.handler ~= nil then
		self.handler(self.data);
	end
	self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM2PANEL);
	
end

-- { title="提示",msg="只能出售品质大于1的物品" }
function Confirm2Panel:SetData(data)
	local title = data.title;
	local msg = data.msg;
	
	self._txt_title.text = title;
	self._txt_label.text = msg;
	
	self.handler = data.hander;
	-- tangping
	self.data = data.data;

	if data.time then
		self._time = data.time;
		self._timer:Start();
		self._btn_label.text = string.format(_btnLabel, self._time);
	end
end

function Confirm2Panel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	
	
	self._txt_title = nil;
	self._txt_label = nil;
	self._btn_ok = nil;
	
	
end

function Confirm2Panel:_DisposeListener()
	UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_ok = nil;
end

function Confirm2Panel:_DisposeReference()
	self._btn_ok = nil;

	if (self._timer) then
        self._timer:Stop()
        self._timer = nil
    end
end

function Confirm2Panel:_OnTimerHandler()
	if self._time then
	    self._time = self._time - 1
	    self._btn_label.text = string.format(_btnLabel, self._time);
	    if (self._time == 0) then
	        self._timer:Stop()
	        self:_OnClickBtn_ok();
	    end
	end
end

