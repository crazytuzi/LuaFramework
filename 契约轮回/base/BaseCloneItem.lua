--
-- @Author: LaoY
-- @Date:   2018-11-23 10:43:13
-- 父节点预制物附带该预制物，父节点加载完后通过GameObject.Instantiate复制的方式生成新的子节点
-- 不需要异步加载
BaseCloneItem = BaseCloneItem or class("BaseCloneItem",Node)

function BaseCloneItem:ctor(obj,parent_node)
	if not obj then
		return
	end
	self.parent_node = parent_node		-- 父节点 不一定需要父节点，如果和复制前的gameobject是同一个父节点就不需要传参数
	if not self.parent_node then
		self.parent_node = obj.transform.parent
	end

	self.is_loaded = true
	self.gameObject = newObject(obj)
	self.transform = self.gameObject.transform
	self.transform_find = self.transform.Find

	self.gameObject:SetActive(true)
	if self.parent_node then
		self.transform:SetParent(self.parent_node)
	end
end

function BaseCloneItem:__reset(obj,parent_node)
	BaseCloneItem.super.__reset(self)
	self.parent_node = parent_node

	self.transform:SetParent(self.parent_node)
	-- builtin_layer = builtin_layer or self.builtin_layer
	-- if builtin_layer and builtin_layer ~= self.builtin_layer then
	-- 	self.builtin_layer = builtin_layer
	-- 	SetChildLayer(self.parent_node,self.builtin_layer)
	-- end
end

function BaseCloneItem:Load()	
	SetLocalScale(self.transform , 1, 1, 1)
	SetLocalPosition(self.transform , 0 , 0 , 0)
	SetLocalRotation(self.transform,0,0,0)

	self:LoadCallBack()

	if self.isVisible ~= nil then
		self:SetVisible(self.isVisible)
	end
	if self.position ~= nil then
		self:SetPosition(self.position.x,self.position.y)
	end
	if self.transformName ~= nil then
		self.transform.name = self.transformName
	end
	if self.sibling_index ~= nil then
		self:SetSiblingIndex(self.sibling_index)
	end
end

-- overwrite
function BaseCloneItem:LoadCallBack()
	logWarn(string.format("%s BaseCloneItem要重写 LoadCallBack方法",self.__cname))
end