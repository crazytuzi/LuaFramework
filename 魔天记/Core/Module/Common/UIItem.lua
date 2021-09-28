
-- UIItem = {
-- 	data = nil
-- };
UIItem = class("UIItem");
function UIItem:New()
	local o = {};
	setmetatable(o, self);
	self.__index = self;
	return o;
end



function UIItem:Init(gameObject, data)
	self.gameObject = gameObject
	self.transform = gameObject.transform
	self.data = data
	self._btns = {}
	self._onBtnsClickFunc = function(go) self:_OnBtnsClick(go) end
	self:_Init()
end

function UIItem:_Init()
	
end

function UIItem:UpdateItem(data)
	self.data = data
end

function UIItem:Dispose()
	self:_Dispose()
	self:_RemoveBtnListen()
	self.gameObject = nil
	self.transform = nil
	for k, v in pairs(self) do
		self[k] = nil
	end
end

function UIItem:_Dispose()
	
end

local zero = Vector3.zero
local disablePos = Vector3.one * 100000

function UIItem:SetEnable(enable)
	SetUIEnable(self.transform, enable)
end

function UIItem:SetActive(enable)
	if(self.gameObject) then
		self.gameObject:SetActive(enable)
	end
end

function UIItem:_AddBtnListen(go)
	local listen = UIUtil.GetComponent(go, "LuaUIEventListener")
	listen:RegisterDelegate("OnClick", self._onBtnsClickFunc);
	self._btns[go] = listen
end

function UIItem:_RemoveBtnListen()
	if(self._btns and table.getCount(self._btns) > 0) then
		for k, v in pairs(self._btns) do
			if(v) then
				v:RemoveDelegate("OnClick");
			end
		end
	end
	self._onBtnsClickFunc = nil
end


function UIItem:_OnBtnsClick(go)
	
end 