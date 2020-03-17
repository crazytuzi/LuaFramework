_G.CommonMenu = BaseUI:new("CommonMenu")
CommonMenu.params = nil;
CommonMenu.dir = nil;
CommonMenu.parent = nil;

-- Sample   params = {name=button's name,callback=on click back,args=function's params}

function CommonMenu:Create()
	self:AddSWF("commonMenuPanel.swf",true,"center");
end

function CommonMenu:OnLoaded(objSwf)
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
	-- objSwf.list.itemRollOut = function(e) self:Hide(); end
end

function CommonMenu:Open(params,dir,parent, x, y)
	self.params = params;
	self.dir = dir;
	self.parent = parent;
	self.x = x
	self.y = y
	if not params or #params<1 then
		return;
	end
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function CommonMenu:OnListItemClick(e)
	local param = self.params[e.index+1];
	if not param then
		return;
	end
	
	local callback = param.callback;
	if callback then
		callback(param.from,param.args);
	end
	
	self:Hide();
end

function CommonMenu:OnShow()
	local swf = self.objSwf;
	if not swf then
		return;
	end

	local len = #self.params;
	if len <= 0 then
		self:Hide();
		return;
	end
	local height = len*22+10;
	swf.list.height = height;
	-- swf.bg.height = height - 4;
	swf.list.dataProvider:cleanUp();

	for i,param in ipairs(self.params) do
		local vo = {}
		vo.name = param.name
		vo.pfx = param.pfx
		swf.list.dataProvider:push(UIData.encode(vo));
	end
	
	swf.list:invalidateData();

	local pos = _Vector2.new();
	if self.x then
		pos.x = self.x
		pos.y = self.y
	elseif self.parent then
		
		pos = self.parent
	
		pos.y = self.parent._y;
		if dir == 'left' then
			pos.x = self.parent._x - swf.width;
		elseif dir == 'right' then
			pos.x = swf.width;
		end
	else
		pos= _sys:getRelativeMouse();
		local wWidth,wHeight = UIManager:GetWinSize();
		pos.x = pos.x + 15;
		
		pos.y = pos.y - 30;
		if pos.y+height > wHeight then
			pos.y = wHeight-height;
		end
	end
	
	swf._x = pos.x;
	swf._y = pos.y;
	
end

function CommonMenu:OnHide()
	self.params = nil;
	self.objSwf.list.dataProvider:cleanUp();
end

function CommonMenu:HandleNotification(name,body)
	local swf = self.objSwf;
	if not swf then return; end
	if name == NotifyConsts.StageClick then
		local target = string.gsub(swf._target, "/",".");
		if string.find(body.target,target) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end

function CommonMenu:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end





