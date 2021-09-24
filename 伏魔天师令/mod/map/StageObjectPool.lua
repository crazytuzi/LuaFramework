local StageObjectPool=classGc(function(self)
	self.m_isRelease=false
	self.m_freeObjArray={}
	self.m_useObjArray={}
	self.m_gafAssetArray={}
end)

function StageObjectPool.init(self)
	self.m_isRelease=false
end

function StageObjectPool.getObject(self,_szName,_type,_scale)
	if self.m_isRelease then
		return self:addObject(_szName,_type,_scale)
	end

	local tempObj=nil
	for i=1,#self.m_freeObjArray do
		local tempT=self.m_freeObjArray[i]
		if tempT.szName==_szName and tempT.type==_type then
			tempObj=tempT.obj
			if _type==_G.Const.StagePoolTypeSpine then
				tempObj:setToSetupPose()
			end

			if _scale and tempT.scale~=_scale then
				tempObj:setScale(_scale)
			end

			self.m_useObjArray[#self.m_useObjArray+1]=tempT
			table.remove(self.m_freeObjArray,i)
			break
		end
	end
	if not tempObj then
		tempObj=self:addObject(_szName,_type,_scale,true)
	end

	return tempObj
end

function StageObjectPool.freeObject(self,_object)
	for i=1,#self.m_useObjArray do
		local tempT=self.m_useObjArray[i]
		if tempT.obj==_object then
			if _object:getParent() then
				print("SDASDASDASDASDASDSA",tempT.szName,debug.traceback())
			end
			table.remove(self.m_useObjArray,i)
			self.m_freeObjArray[#self.m_freeObjArray+1]=tempT
			return
		end
	end
end

function StageObjectPool.addObject(self,_szName,_type,_scale,_isUse)
	local tempObj=nil
	if _type==_G.Const.StagePoolTypeSpine then
		tempObj=_G.SpineManager.createSpine(_szName,_scale)
	elseif _type==_G.Const.StagePoolTypeGaf then
		local tempGafAsset=self.m_gafAssetArray[_szName]
		if not tempGafAsset then
			tempGafAsset=gaf.GAFAsset:create(_szName)
			if not self.m_isRelease then
				self.m_gafAssetArray[_szName]=tempGafAsset
			end
		end
		
		tempObj=tempGafAsset:createObject()
		if tempObj then
			-- tempObj:setFps(60)
			if _scale then
				tempObj:setScale(_scale)
			end
		end
	elseif _type==_G.Const.StagePoolTypeNode then
		tempObj=cc.Node:create()
	end
	if not tempObj then return false end

	if self.m_isRelease then
		return tempObj
	end

	local tempT={obj=tempObj,szName=_szName,type=_type}
	if _isUse then
		self.m_useObjArray[#self.m_useObjArray+1]=tempT
	else
		self.m_freeObjArray[#self.m_freeObjArray+1]=tempT
	end

	tempObj:retain()
	return tempObj
end

function StageObjectPool.releaseAllObject(self)
	for i=1,#self.m_useObjArray do
		local tempT=self.m_useObjArray[i]
		tempT.obj:release()
	end
	for i=1,#self.m_freeObjArray do
		local tempT=self.m_freeObjArray[i]
		tempT.obj:release()
	end
	self.m_useObjArray={}
	self.m_freeObjArray={}
	self.m_gafAssetArray={}

	self.m_isRelease=true
end

function StageObjectPool.releaseObject(self,_object)
	-- for i=1,#self.m_useObjArray do
	-- 	local tempT=self.m_useObjArray[i]
	-- 	if tempT.obj==_object then
	-- 		tempT.obj:release()
	-- 		table.remove(self.m_useObjArray,i)
	-- 		return
	-- 	end
	-- end
	-- for i=1,#self.m_freeObjArray do
	-- 	local tempT=self.m_freeObjArray[i]
	-- 	if tempT.obj==_object then
	-- 		tempT.obj:release()
	-- 		table.remove(self.m_freeObjArray,i)
	-- 		return
	-- 	end
	-- end
end

function StageObjectPool.printInfo(self)
	print("==========StageObjectPool=========")

	local tempCount,tempArray1,tempArray2=self:getArrayByTotal(true)
	print(string.format("空闲对象,数量=%d",tempCount))
	for k,v in pairs(tempArray1) do
		print(string.format("  空闲对象,name=%s,count=%d,存在问题!!!!!!  正在使用中。。。。",k,v))
	end
	for k,v in pairs(tempArray2) do
		print(string.format("  空闲对象,name=%s,count=%d,空闲中",k,v))
	end

	local tempCount,tempArray1,tempArray2=self:getArrayByTotal(false)
	print(string.format("使用中的对象,数量=%d",tempCount))
	for k,v in pairs(tempArray1) do
		print(string.format("  使用中的对象,name=%s,count=%d,存在问题!!!!!!  空闲中。。。。",k,v))
	end
	for k,v in pairs(tempArray2) do
		print(string.format("  使用中的对象,name=%s,count=%d,使用中",k,v))
	end
end

function StageObjectPool.getArrayByTotal(self,_isFree)
	local objArray=_isFree and self.m_freeObjArray or self.m_useObjArray
	local errorArray={}
	local rightArray={}
	local errorCount=0
	local rightCount=0
	for i=1,#objArray do
		local szName=objArray[i].szName
		if not objArray[i].obj:getParent() then
			if not errorArray[szName] then
				errorArray[szName]=0
			end
			errorArray[szName]=errorArray[szName]+1
			errorCount=errorCount+1
		else
			if not rightArray[szName] then
				rightArray[szName]=0
			end
			rightArray[szName]=rightArray[szName]+1
			rightCount=rightCount+1
		end
	end

	if _isFree then
		local tempArray=errorArray
		errorArray=rightArray
		rightArray=tempArray

		local tempCount=errorCount
		errorCount=rightCount
		rightCount=tempCount
	end

	return #objArray,errorArray,rightArray,errorCount,rightCount
end

_G.StageObjectPool=StageObjectPool()