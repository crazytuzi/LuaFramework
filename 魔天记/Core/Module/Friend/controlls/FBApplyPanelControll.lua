FBApplyPanelControll = class("FBApplyPanelControll");

function FBApplyPanelControll:New()
	self = { };
	setmetatable(self, { __index =FBApplyPanelControll });
	return self
end


function FBApplyPanelControll:Init(gameObject)
self.gameObject= gameObject;
end


function FBApplyPanelControll:Show()
    self.gameObject:SetActive(true);


end

function FBApplyPanelControll:Close()
    self.gameObject:SetActive(false);
end

function FBApplyPanelControll:UpData()

end

function FBApplyPanelControll:Dispose()

end

