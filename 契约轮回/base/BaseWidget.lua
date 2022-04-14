-- 
-- @Author: LaoY
-- @Date:   2018-07-14 10:23:13
-- 
--
-- Author: LaoY
-- Date: 2018-07-02 09:56:12
-- 基础容器基类 不同于BaseItem，此类用于常用控件类，不做资源释放，常驻内存

BaseWidget = BaseWidget or class("BaseWidget",Node)

function BaseWidget:ctor(parent_node,builtin_layer)
	self.parent_node = parent_node		-- 父节点
	self.builtin_layer = builtin_layer or LayerManager.BuiltinLayer.UI  -- 层级 默认是UI层
end

function BaseWidget:dctor()
	-- 不需要释放
	-- lua_panelMgr:ClearItem(self.abName,self.gameObject)
	if not self.__cache_count then
		if self.gameObject then
			if not (self.abName and self.abName) or  not poolMgr:AddGameObject(self.abName,self.assetName,self.gameObject) then
				destroy(self.gameObject)
			end
			self.gameObject = nil
		end
	end
end

function BaseWidget:__reset(parent_node,builtin_layer)
	BaseWidget.super.__reset(self)
	parent_node = parent_node or self.parent_node
	if parent_node or not IsNil(parent_node) then
		self.parent_node = parent_node	-- 父节点
		if self.transform and not IsNil(self.transform) then
			self.transform:SetParent(self.parent_node)
		else
			if AppConfig.Debug then
				logError("transform is nil")
			end
		end
	end
	builtin_layer = builtin_layer or self.builtin_layer
	if builtin_layer and builtin_layer ~= self.builtin_layer then
		self.builtin_layer = builtin_layer
		SetChildLayer(self.parent_node,self.builtin_layer)
	end
end

function BaseWidget:Load()
	-- local function load_call_back(obj)
	-- 	print('--LaoY BaseWidget.lua,line 24-- data=',data)
	-- 	if self.is_loaded then
	-- 		return
	-- 	end
	-- 	self:CreateItem(obj)
	-- end
	local obj = PreloadManager:GetInstance():CreateWidget(self.abName,self.assetName)
	if obj then
		self:CreateItem(obj)
	end
end

function BaseWidget:CreateItem(obj)
	-- 已经销毁或者加载失败
	if self.is_dctored or obj == nil then
		return
	end
	self.is_loaded = true

	self.gameObject = obj
	self.transform = obj.transform
	self.transform_find = self.transform.Find

	-- 一定要先加入父节点
	self.transform:SetParent(self.parent_node)

	--加入场景的对象要修改这个
	SetChildLayer(self.transform,self.builtin_layer)

	SetLocalScale(self.transform)
	SetLocalPosition(self.transform)

	self:LoadCallBack()

	if self.visible ~= nil then
		self:SetVisible(self.visible)
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

	if self.order_index ~= nil then
        self:SetOrderIndex(self.order_index)
    end
end

-- overwrite
function BaseWidget:LoadCallBack()
	logWarn(string.format("%s 界面要重写 LoadCallBack方法",self.assetName))
end