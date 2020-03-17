_G.EditeController = setmetatable({},{__index = IController});
EditeController.name = "EditeController";
EditeController.indicator = nil;

function EditeController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_SCENE_OBJ_ENTER_NOTIFY,self,self.OnCharAndHandler);
	MsgManager:RegisterCallBack(MsgType.SC_SCENE_OBJ_LEFT_NOTIFY,self,self.OnCharDeleteHandler);
end

function EditeController:OnCharAndHandler(msg)
	
end

function EditeController:OnCharDeleteHandler(msg)

end

function EditeController:Update(interval)
	self:RenderIndicator();
	self:RenderSelected();
end

function EditeController:RenderIndicator()
	if not self.indicator then
		return;
	end
	
	if not self.indicator.entity then
		return;
	end
	
	CPlayerControl.bIsUsable = false;
	self.indicator:draw();
	
end

function EditeController:RenderSelected()

end

function EditeController:OnMouseDown(nButton,nXPos,nYPos)
	local map = CPlayerMap:GetSceneMap();
	if not map then
		self.indicator.entity = nil;
		return;
	end
	
	local picked = 	map:DoEntityPick(nXPos,nYPos);
	if picked then
		local state = self.indicator.state;
		if self:SetSelectEntity(picked.node.entity) then
			state = -1;
			MainPlayerController:StopMove();
		end
		if nButton == 1 then
			state = state + 1;
			if state>2 then
				state = 0;
			end
			self.indicator.state = state;
		end
	end
	
	self.indicator:operStart(nXPos,nYPos);
	
end

function EditeController:OnMouseMove(nXPos,nYPos)
	if self.indicator then
		self.indicator:operMove(nXPos,nYPos);
	end
end

function EditeController:OnMouseUp(nButton,nXPos,nYPos)
	self.indicator:operEnd(nXPos,nYPos);
end

function EditeController:OnKeyDown(code)
	if code == _System.KeyESC then
		if self.indicator.entity then
			self.indicator.entity = nil;
			CPlayerControl.bIsUsable = true;
			return;
		end
		self:SetEnabled(false);
	elseif code == _System.KeyE then
		UIEditeMain:Show();
	end
end

function EditeController:SetSelectEntity(entity)
	local changed = self.indicator.entity ~= entity;
	self.indicator.entity = entity;
	
	if entity and entity.objNode then
		self.indicator.transform = entity.objNode.transform;
	end
	
	if changed then
		self:sendNotification('EditeEntitySelected',entity);
	end
	
	return changed;
end

function EditeController:GetSelectEntity()
	return self.indicator.entity;
end

function EditeController:OnChangeSceneMap()
	local mapid = CPlayerMap:GetCurMapID();
	self:sendNotification('EditeSceneChanged',mapid);
end

function EditeController:SetEnabled(enabled)
	if enabled then
		ToolsController.cameraFree = enabled;
		EditeModel:Init();
		UIEditeMain:Show();
		if not self.indicator then
			self.indicator = _Indicator.new();
		end
    else
		UIEditeMain:Hide();
		if self.indicator then
			self.indicator.entity = nil;
			self.indicator = nil;
		end
    end
	
	CControlBase:RegControl(self,enabled);
end

function EditeController:ToString(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj;
    
	getIndent = function(level)
        return string.rep("\t", level);
    end
    
	quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"';
    end
    
	wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]";
        elseif type(val) == "string" then
            return val;
        else
            return "[" .. tostring(val) .. "]";
        end
    end
    
	wrapVal = function(val, level,color)
        if type(val) == "table" then
            return dumpObj(val, level);
        elseif type(val) == "number" then
			if color then
				return string.format("%#x",val);
			end
			return val;
        elseif type(val) == "string" then
            return quoteStr(val);
        else
            return tostring(val);
        end
    end
	
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj);
        end
        level = level + 1;
        local tokens = {};
        tokens[#tokens + 1] = "{";
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level,k=='color') .. ",";
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}";
        return table.concat(tokens, "\n");
    end
	
    return dumpObj(obj, 0)
end

function EditeController:Save()
	local file = _File:new();
	file:create('config//LightConfig.lua');
	file:write("_G.LightCommon = \n");
	file:write(self:ToString(LightCommon));
	
	file:write("\n");
	file:write("_G.SceneLight = \n");
	file:write(self:ToString(SceneLight));
	
	file:close();
end

function EditeController:ResetLight()
	EditeModel:ResetLight();
end

function EditeController:GetColorRGBA(color)
	local a = _rshift(color,24);
	local r = _rshift(_and(color,0x00ff0000),16);
	local g = _rshift(_and(color,0x0000ff00),8);
	local b = _and(color,0xff);
	return a,r,g,b;
end

function EditeController:GetRGBAColor(r,g,b,a)
	a = _lshift(a,24);
	r = _lshift(r,16);
	g = _lshift(g,8);
	local color = _or(a,r);
	color = _or(color,g);
	color = _or(color,b);
	return color;
end

function EditeController:GetRGBColor(r,g,b,a)
	r = _lshift(r,16);
	g = _lshift(g,8);
	local color = _or(r,g);
	color = _or(color,b);
	local alpha = math.ceil(100*a/0xff);
	return color,alpha;
end

function EditeController:ColorToString(color)
	return string.format("%#x",color);
end




