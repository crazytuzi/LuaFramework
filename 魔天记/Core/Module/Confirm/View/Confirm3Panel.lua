require "Core.Module.Confirm.View.BaseConfirmPanel"
Confirm3Panel = class("Confirm3Panel", BaseConfirmPanel);

function Confirm3Panel:New()
	self = {};
	setmetatable(self, {__index = Confirm3Panel});
	return self
end


function Confirm3Panel:_Init()
	self._luaBehaviour.canPool = true
	self:_InitReference();
	self:_InitListener();
end

function Confirm3Panel:_InitReference()
	self._txt_title = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title");
	self._txt_label = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_label");
	self._btn_ok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_ok");
	self._btn_cancel = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_cancel");
	
	self.micon = UIUtil.GetChildByName(self._trsContent, "UISprite", "micon");
	
	self._btn_ok_txt = UIUtil.GetChildByName(self._btn_ok, "UILabel", "Label");
	
	self._btn_cancel_txt = UIUtil.GetChildByName(self._btn_cancel, "UILabel", "Label");
	
	self.checkBox = UIUtil.GetChildByName(self._trsContent, "UIButton", "checkBox");
	self.checkBox_select = UIUtil.GetChildByName(self.checkBox, "UISprite", "selectIcon");
	
	self.checkBoxHandler = function(go) self:CheckBoxHandler(self) end
	UIUtil.GetComponent(self.checkBox, "LuaUIEventListener"):RegisterDelegate("OnClick", self.checkBoxHandler);
	
	self.checkBox_select.gameObject:SetActive(false);
	self.acc = 0;
	
end

function Confirm3Panel:_InitListener()
	self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
	UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
	self._onClickBtn_cancel = function(go) self:_OnClickBtn_cancel(self) end
	UIUtil.GetComponent(self._btn_cancel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_cancel);
end

function Confirm3Panel:CheckBoxHandler()
	
	if self.acc == 1 then
		self.acc = 0;
		self.checkBox_select.gameObject:SetActive(false);
		
		-- if self.data ~= nil then
		self.data.checkBoxSelected = false;
		-- end
	else
		self.checkBox_select.gameObject:SetActive(true);
		-- if self.data ~= nil then
		self.data.checkBoxSelected = true;
		-- end
		self.acc = 1;
	end
	
end

function Confirm3Panel:_OnClickBtn_ok()
	if(self.handler) then
		if self.handlerTarget ~= nil then
			if(self.data) then
				self.handler(self.handlerTarget, self.data);
			else
				self.handler(self.handlerTarget);
			end
		else
			if(self.data) then
				self.handler(self.data);
			else
				self.handler();
			end
		end
	end
	self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM3PANEL);
	
end

function Confirm3Panel:_OnClickBtn_cancel()
	if self.handlerTarget ~= nil then
		if self.cancelHandler ~= nil then
			self.cancelHandler(self.handlerTarget, self.data);
		end
	else
		if self.cancelHandler ~= nil then
			self.cancelHandler(self.data);
		end
		
	end
	
	self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM3PANEL);
	
end

-- { title="提示",msg="你确定要出售此装备？", ok_Label="确定", cance_lLabel="放弃",  hander = ProductTipProxy.SToSell,cancelHandler= data = info }
function Confirm3Panel:SetData(data)
	
	self._txt_title.text = data.title;
	self._txt_label.text = data.msg;
	
	self._btn_ok_txt.text = data.ok_Label;
	self._btn_cancel_txt.text = data.cance_lLabel;
	
	self.data = data.data;
	self.handler = data.hander;
	self.cancelHandler = data.cancelHandler;
	self.handlerTarget = data.target;
	
	if self.data == nil then
		self.data = {};
		self.data.checkBoxSelected = false;
	end
	
	if self.data.hideCheckBox then
		self.checkBox.gameObject:SetActive(false);
		
	end
	
end

function Confirm3Panel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
	
	
	self._txt_title = nil;
	self._txt_label = nil;
	self._btn_ok = nil;
	self._btn_cancel = nil;
	
	self.micon = nil;
	
	self._btn_ok_txt = nil;
	
	self._btn_cancel_txt = nil;
	
	self.checkBox = nil;
	self.checkBox_select = nil;
	
	self.checkBoxHandler = nil;
	
end

function Confirm3Panel:_DisposeListener()
	UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_ok = nil;
	UIUtil.GetComponent(self._btn_cancel, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_cancel = nil;
	
	
	UIUtil.GetComponent(self.checkBox, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self.checkBoxHandler = nil;
end

function Confirm3Panel:_DisposeReference()
	self._btn_ok = nil;
	self._btn_cancel = nil;
end

