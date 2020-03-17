--[[
场景（地图）名字，进入新场景时显示
2014年12月24日17:33:45
郝户
]]

_G.UIMapName = BaseUI:new("UIMapName");

UIMapName.mapId = nil;
UIMapName.timer = nil

function UIMapName:Create()
	self:AddSWF("mapName.swf", true, "top");
end

function UIMapName:OnLoaded(objSwf)
	objSwf.hitTestDisable = true;
	objSwf.effect.complete = function() self:OnEffectComplete() end
end

function UIMapName:NeverDeleteWhenHide()
	return true;
end

function UIMapName:OnShow()
	self:UpdateShow()
	self:StopTimer()
end

function UIMapName:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local src = ResUtil:GetSceneNamePicURL( self.mapId );
	objSwf.effect.loader.source = src
	objSwf.effect.hideWhenEnd = false;
	objSwf.effect:playEffect(1)
	-- self:StartTimer()
end

function UIMapName:StartTimer()
	self:StopTimer()
	self.timer = TimerManager:RegisterTimer( function()
		self:StopTimer()
		self:OnTimeUp()
	end, 5000, 1 )
end

function UIMapName:StopTimer()
	if self.timer then
		TimerManager:UnRegisterTimer( self.timer )
		self.timer = nil
	end
end

function UIMapName:OnTimeUp()
	self:Hide()
end

function UIMapName:GetWidth()
	return 111;
end

function UIMapName:GetHeight()
	return 374;
end

function UIMapName:OnEffectComplete()
	self:StartTimer();
end

function UIMapName:Open(mapId)
	self.mapId = mapId;
	self:ShowMapName(mapId)
end

function UIMapName:ShowMapName(mapId)
	local imgUrl = ResUtil:GetSceneNamePicURL(mapId);
	if not imgUrl then return; end
	imgUrl = string.sub(imgUrl, 7);
	local cb = function()
		if self:IsShow() then
			self:UpdateShow();
		else
			self:Show();
		end
	end
	if _sys:fileExist(imgUrl) then
		cb();
	else
		UILoaderManager:LoadList( {imgUrl}, cb );
	end
end