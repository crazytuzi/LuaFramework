require "Core.Role.ModelCreater.BaseModelCreater"
WingCreater = class("WingCreater", BaseModelCreater);

function WingCreater:New(data, parent, onLoadedSource, rolemode)
	self = {};
	setmetatable(self, {__index = WingCreater});
	--todo self.rolemode = rolemode
	self:Init(data, parent);
	return self;
end

--
function WingCreater:_Init(data)
	self.model_id = data.model_id
	self.model_scale = data.model_scale or 1
end

function WingCreater:_GetModern()
	return "Equip/Wings", tostring(self.model_id)
end

function WingCreater:_OnModelLoaded()
	if not IsNil(self._role) then 
		self._transform = self._role.transform;
		self._roleAnimator = self._role:GetComponent("Animator");
        self._transform.localScale = Vector3.New(self.model_scale, self.model_scale, self.model_scale)
		self:_SetSelfLayer()	
		self:_UpdateActive();
		self:_InitAnimator()
		if self.rolemode and self.rolemode.__cname == 'HeroModelCreater' then
			self.rolemode._roleAvtar:ChangeShader(self._role)
		end
	end
end



-- function WingCreater:_InitAvtar()
-- 	-- self:_OnModeInited()
-- 	if self.rolemode and self.rolemode.__cname == 'HeroModelCreater' then
-- 		self.rolemode._roleAvtar:ChangeShader(self._role)
-- 	end
-- end
function WingCreater:_GetAnimDir(anim)
	local m = self.model_id
	local s, e = string.find(m, "_cb")
	--Warning(m.."____" .. s .. ',' .. e .. '=' .. string.sub(m, 0, e))
	return string.sub(m, 0, e)
end
function WingCreater:_IsLoadController()
	return true
end
function WingCreater:_GetControllerDir()
	return "Equip/Wings/ControllerWing/"
end

function WingCreater:GetCheckAnimation()
	return false
end

function WingCreater:_GetModelDefualt()
	return "mxz_cb_01"
end

function WingCreater:_Dispose()
	self.rolemode = nil
end
