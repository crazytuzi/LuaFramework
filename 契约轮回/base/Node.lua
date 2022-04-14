--
-- Author: LaoY
-- Date: 2018-07-02 09:55:04
-- 所有UI相关的基类 层级管理?

TestDestroy = false
if TestDestroy then
	TestDestroyClassList = {}
end

Node = Node or class("Node")

function Node:ctor()
	self.layer_name = "UI"

	self.gameObject = nil
	self.transform = nil
	self.transform_find = nil
	self.is_loaded = false
	self.isVisible = nil
	self.position = nil

	self.auto_order_count = 1
	self.is_ui = true
end

function Node:dctor()
	self.is_loaded = false
	self:DestyoyGameObject()
	self.transform = nil
	self.parent_node = nil
	self.parent = nil
	-- 清除引用
	lua_resMgr:ClearClass(self)
	
	self.transform = nil

	-- if self.layer_tree_node then
	-- 	LayerManager:GetInstance():RemoveLayerNode(self.layer_tree_node)
	-- end

	LayerManager:GetInstance():RemoveOrderIndexByCls(self)

	if self.nodes then
		self:ClearNode(self.nodes)
		self.nodes = nil
	end
end

function Node:DestyoyGameObject()
	if self.gameObject then
		destroy(self.gameObject)
		self.gameObject = nil
	end
end

--[[
	@author LaoY
	@des	用于派生类缓存
--]]
function Node:__clear()
	lua_resMgr:ClearImage(self)
	LayerManager:GetInstance():RemoveOrderIndexByCls(self)
	
	-- 后续一点要删除缓存节点的父节点引用
	self.parent_node = nil
	self.parent = nil

	if is_cache_object_visible then
		self:SetVisible(false)
	end

	local layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.CacheLayer)
	if self.transform then
		self.transform:SetParent(layer)
		SetLocalPosition(self.transform,0,0,0)
	end
end

--[[
	@author LaoY
	@des	用于派生类缓存
--]]
function Node:__reset()
	if is_cache_object_visible then
		self:SetVisible(true)
	end
end

function Node:SetVisible(flag)
	self.isVisible = flag
	if self.is_loaded then
		if IsNil(self.gameObject) then
			return
		end
		if self.gameObject.activeSelf == flag then
            return
        end
		self.gameObject:SetActive(flag)
		if flag then
			self:OnEnable()
		else
			self:OnDisable()
		end
	end
end

--over write
function Node:OnEnable()
end

--over write
function Node:OnDisable()
end

function Node:GetVisible()
	if self.is_loaded then
		return self.gameObject.activeSelf
	else
		return self.isVisible ~= nil and self.isVisible or false
	end
end

-- 后续再改
-- UI界面一般只需要设置XY，如果需要XYZ另外调用SetLocalPosition
function Node:SetPosition(x, y)
	if self.is_loaded then
		SetLocalPosition(self.transform, x, y,0)
	else
		self.position = Vector3(x,y,0)
	end
end

function Node:SetTransformName(tranName)
	if self.is_loaded then
		self.transform.name = tranName
	else
		self.transformName = tranName
	end

end

function Node:GetPosition()
	if self.is_loaded then
		return GetLocalPosition(self.transform)
	else
		if self.position then
			return self.position.x,self.position.y,self.position.z or 0
		else
			return 0,0,0
		end
	end
end

function Node:GetGlobalPosition()
	if not self.is_loaded then
		return 0,0,0
	end
	return GetGlobalPosition(self.transform)
end

function Node:SetSiblingIndex(index)
	self.sibling_index = index
	if self.is_loaded then
		self.transform:SetSiblingIndex(index)
	end
end

function Node:SetScale(scale)
	self.scale = scale
	if self.is_loaded then
		SetLocalScale(self.transform, scale)
	end
end

function Node:SetRotation(angle)
	self.angle = angle
	if self.is_loaded then
		SetLocalRotation(self.transform,0,0,angle)
	end
end

function Node:SetChildLayer(transform,layer)
	transform = transform or self.transform
	SetChildLayer(transform,layer)
end

--[[
    @author LaoY
    @des    返回父节点（溯源找到带canvas为父节点）
    @param1 gameObject
    @return transform,index
--]]
function Node:GetParentOrderIndex()
	local transform = self.parent_node or self.transform.parent
	if not transform then
		return
	end
	return GetParentOrderIndex(transform)
end

--[[
	@author LaoY
	@des	设置OrderIndex为父节点的+1
	@param1 param1
	@return number
--]]
function Node:SetOrderByParentAuto()
	local parent_transform,parent_order_index = self:GetParentOrderIndex()
	if not parent_transform then
		return
	end
	self.order_parent_transform = parent_transform
	local order_index = parent_order_index + self.auto_order_count
	-- self.layer_tree_node = LayerManager:GetInstance():AddLayerNode(parent_transform,self.transform,order_index)
	self:SetOrderIndex(order_index)
end

--[[
	@author LaoY
	@des	设置OrderIndex为父节点中所有子节点最高+1
	@param1 param1
	@return number
--]]
function Node:SetOrderByParentMax()
	local parent_transform,parent_order_index = self:GetParentOrderIndex()
	if not parent_transform then
		return
	end
	self.order_parent_transform = parent_transform
	local order_index = LayerManager:GetInstance():GetMaxOrderIndex(parent_transform)
	order_index = order_index + self.auto_order_count
	self:SetOrderIndex(order_index)
end


-- 设置渲染层级（仅限于和特效层级错乱时使用）
function Node:SetOrderIndex(order_index)
	--print('--调用了Node:SetOrderIndex--，该类为：',self.__name)
    self.order_index = order_index
    if self.gameObject then
  --   	if self.order_parent_transform then
		-- 	self.layer_tree_node = LayerManager:GetInstance():AddLayerNode(self.order_parent_transform,self.transform,order_index,self.is_ui)
		-- end
  --       SetOrderIndex(self.gameObject,true,order_index)

  		if not self.order_parent_transform then
			local parent_transform,parent_order_index = self:GetParentOrderIndex()
  			self.order_parent_transform = parent_transform
  		end
  		local node = LayerManager:GetInstance():AddOrderIndexByCls(self,self.transform,self.order_parent_transform,self.is_ui,order_index)

        -- 有可能 transform 变 RectTransform 必须重新赋值一次
		if tostring(self.transform) == "null" then
			LayerManager:GetInstance():RemoveLayerNode(node)
			self.transform = self.gameObject.transform
			LayerManager:GetInstance():AddOrderIndexByCls(self,self.transform,self.order_parent_transform,self.is_ui,order_index)
		end
    end
end

-- 获取子节点
function Node:GetChild(name)
	if self.transform_find and self.transform then
		return self.transform_find(self.transform,name)
	end
end

-- 获取列表的子节点
-- {"parent/name1","parent/name1"} 得到 self.name1,self.name2两个GameObject
local find = string.find
local gsub = string.gsub
function Node:GetChildren(names)
	if not self.is_loaded then
 		return
	end
	for i=1,#names do
		local key = names[i]
		if key and find(key,"/") then
			key = gsub(key,".+/","")
		end
		assert(self[key] == nil, key .. " already exists")
		if key then
			self[key] = self:GetChild(names[i])
		end
	end
end

function Node:ClearNode(names)
	for i=1,#names do
		local key = names[i]
		if key and find(key,"/") then
			key = gsub(key,".+/","")
		end
		if key then
			self[key] = nil
		end
	end

	if AppConfig.Debug then
		local del_tab
		for k,v in pairs(self) do
			if type(v) == "userdata" then
				del_tab = del_tab or {}
				del_tab[#del_tab+1] = k
			end
		end
		if not table.isempty(del_tab) then
			for k,key in pairs(del_tab) do
				self[key] = nil
			end
		end
	end

	if AppConfig.Debug then
		
		-- 有可能多次gc后会删除
		for k,v in pairs(self) do
			if (type(v) == "table" and (not isClass(v) or not v.is_dctored)) then
				for _,vv in pairs(v) do
					if type(vv) == "userdata" then
						logError(string.format("引用未删除,%s下的%s",self.__cname,k))
						break
					end
				end
			end
		end
	end
end