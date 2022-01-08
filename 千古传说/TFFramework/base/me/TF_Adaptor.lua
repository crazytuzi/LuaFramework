--
-- Author: MiYu
-- Date: 2014-02-12 17:13:00
--
TFUIBase = TFUIBase or {}

------------------------------------------adapt------------------------------------------------
function me.ShaderCache:purge()
	local func = me.ShaderCache.purge
	CCShaderCache:purgeSharedShaderCache()
	me.ShaderCache = CCShaderCache:sharedShaderCache()
	me.ShaderCache.purge = func
end

function me.TextureCache:print()
	me.TextureCache:dumpCachedTextureInfo()
end

-- function me.MCManager:clear()
-- 	me.MCManager:clear()
-- end

function me.FrameCache:clear()
	me.FrameCache:removeSpriteFrames()
end

function me.TextureCache:clear()
	me.TextureCache:removeAllTextures()
end

function me.FrameCache:clearUnused()
	me.FrameCache:removeUnusedSpriteFrames()
end

function me.TextureCache:clearUnused()
	me.TextureCache:removeUnusedTextures()
end


------------------------------------------TFUIBase Adapt------------------------------------------------

if not ENABLE_ADAPTOR then return end
function TFUIBase:registerStateScriptHandle(handle)
	if not tolua.isnull(self) then
		self:addMEListener(TFWIDGET_ENTER, function(self)
			handle(self, "enter")
		end)
		self:addMEListener(TFWIDGET_EXIT, function(self)
			handle(self, "exit")
		end)
	end
end

function TFUIBase:unRegisterStateScriptHandle(handle)
	if not tolua.isnull(self) then
		self:removeMEListener(TFWIDGET_ENTER)
		self:removeMEListener(TFWIDGET_EXIT)
	end
end

function TFUIBase:registerUpdateScriptHandle(handle)
	if not tolua.isnull(self) then
		self:addMEListener(TFWIDGET_ENTERFRAME, function(self, nDT) handle(nDT) end)
	end
end

function TFUIBase:unRegisterUpdateScriptHandle()
	if not tolua.isnull(self) then
		self:removeMEListener(TFWIDGET_ENTERFRAME)
	end
end

function TFUIBase:disableUpdate()
	if not tolua.isnull(self) then
		self:unscheduleUpdate()
	end
end

function TFUIBase:setWidgetHitType(hitType)
	if not tolua.isnull(self) then
		self:setHitType(hitType)
	end
end

function TFUIBase:setUpdateEnabled(enabled)
	if not tolua.isnull(self) then
		if enabled then
			self:scheduleUpdate()
		else
			self:unscheduleUpdate()
		end
	end
end

function TFUIBase:ignoreContentAdaptWithSize()

end

function TFUIBase:removeAllChildrenAndCleanUp(bIsCleanup)
	if not tolua.isnull(self) then
		self:removeAllChildrenWithCleanup(bIsCleanup)
	end
end

function TFUIBase:getRenderer()
	return self
end

function TFUIBase:setWidgetZOrder(nZ)
	if not tolua.isnull(self) then
		self:setZOrder(nZ)
	end
end

function TFUIBase:getWidgetZOrder()
	if not tolua.isnull(self) then
		return self:getZOrder()
	end
	return 0
end

function TFUIBase:setWidgetTag(nTag)
	if not tolua.isnull(self) then
		self:setTag(nTag)
	end
end

function TFUIBase:getWidgetTag()
	if not tolua.isnull(self) then
		return self:getTag()
	end
	return 0
end

function TFUIBase:getWidgetParent()
	if not tolua.isnull(self) then
		return self:getParent()
	end
end