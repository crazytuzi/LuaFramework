spriteController=
{
	plistTb={},
	textureTb={},
	textureCache={}
}

--增加一个plist的引用
--param name: plist的路径
function spriteController:addPlist(name)
	if(self.plistTb[name]==nil or self.plistTb[name]==0)then
		self.plistTb[name]=1
	else
		self.plistTb[name]=self.plistTb[name] + 1
	end
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(name)
end

--增加一个texture的引用
--param name: texture的路径
function spriteController:addTexture(name)
	if(self.textureTb[name]==nil)then
		local texture=CCTextureCache:sharedTextureCache():addImage(name)
		self.textureTb[name]=1
		self.textureCache[name]=texture
	else
		self.textureTb[name]=self.textureTb[name] + 1
	end
end

--根据texture的路径获取texture
function spriteController:getTexture(name)
	return tolua.cast(self.textureCache[name],"CCTexture2D")
end

--移除plist引用, 如果plist的引用彻底为0的话，就释放plist
--param name: plist文件的路径
function spriteController:removePlist(name)
	if(self.plistTb[name])then
		self.plistTb[name]=self.plistTb[name] - 1
		if(self.plistTb[name]<=0)then
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(name)
			self.plistTb[name]=nil
		end
	else
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(name)
	end
end

--移除texture引用, 如果texture的引用彻底为0的话，就释放texture
--param name: texture文件的路径
function spriteController:removeTexture(name)
	if(self.textureTb[name])then
		self.textureTb[name]=self.textureTb[name] - 1
		if(self.textureTb[name]<=0)then
			CCTextureCache:sharedTextureCache():removeTextureForKey(name)
			self.textureTb[name]=nil
			self.textureCache[name]=nil
		end
	else
		CCTextureCache:sharedTextureCache():removeTextureForKey(name)
	end
end