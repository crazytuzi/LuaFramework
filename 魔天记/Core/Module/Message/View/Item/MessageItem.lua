MessageItem = class("MessageItem");

function MessageItem:ctor(transform)
    self:Init(transform);
end

function MessageItem:Init(transform)
	self.transform = transform;
	self._txtLabel = UIUtil.GetChildByName(self.transform, "UILabel", "txtLabel");
	
	self:_Init();
end
function MessageItem:_Init()

end

function MessageItem:Dispose()
	self:_Dispose();
end
function MessageItem:_Dispose()
	
end

function MessageItem:Update(data)
	self.data = data;
	self:Enable();
	local html = "";
	if data.f then
		--format
		html = LanguageMgr.ApplyFormat(data.f, data.p, true);
	elseif data.l then
		--label
		html = LanguageMgr.Get(data.l, data.p, true);
	else
		html = data.m;
	end

	if data.c then
		html = LanguageMgr.GetColor(data.c, html);
	end

	self._txtLabel.text = html;
end

function MessageItem:Enable()
    self.enabled = true
	self:_Enable();
end
function MessageItem:_Enable()
	
end

function MessageItem:Disable()
    self.enabled = false
	self:_Disable();
end
function MessageItem:_Disable()
	
end

function MessageItem:Show(data)
	self:_Show(data);
end
function MessageItem:_Show(data)

end



