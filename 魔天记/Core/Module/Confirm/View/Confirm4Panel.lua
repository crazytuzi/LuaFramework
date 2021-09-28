require "Core.Module.Confirm.View.BaseConfirmPanel"
Confirm4Panel = class("Confirm4Panel", BaseConfirmPanel);

function Confirm4Panel:_Init()
	self._luaBehaviour.canPool = true
	self:_InitReference();
end

function Confirm4Panel:_InitReference()
	self._txt_title = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title");
	self._scrollView = UIUtil.GetChildByName(self._trsContent, "UIScrollView", "scrollView");
	if(self._scrollView) then
		self._txt_label = UIUtil.GetChildByName(self._scrollView.gameObject, "UILabel", "txt_label");
	end
end


function Confirm4Panel:_OnClickMask()
	-- tangping
	if self.handler ~= nil then
		self.handler(self.data);
	end
	self:ClosePanel(ConfirmNotes.CLOSE_CONFIRM4PANEL);
end

-- { title="提示",msg="只能出售品质大于1的物品" }
function Confirm4Panel:SetData(data)
	local title = data.title;
	local msg = data.msg;
	
	self._txt_title.text = title;
	self._txt_label.text = msg;
	
	self.handler = data.hander;
	-- tangping
	self.data = data.data;
	
	if(self._scrollView) then
		-- self._scrollView:Scroll(0);
		self._scrollView:ResetPosition();
	end
end

function Confirm4Panel:_Dispose()
	self._txt_title = nil;
	self._scrollView = nil;
end
