--
-- @author: laoy
-- @date:   2019-06-24 20:01:27
-- 可以被继承，小写的方法尽量不要重写

TreeNode = TreeNode or class("TreeNode")

TreeNode.treetype = {
	list = 0,		-- 有序
	map = 1,		-- 无序
}

function TreeNode:ctor(parent_node,pos)
	self.child_list = {}
	self.parent_node = parent_node
	self.pos = pos
	self.seq = parent_node and parent_node.seq + 1 or 1
	self:settreetype(TreeNode.islist(pos) and TreeNode.treetype.list or TreeNode.treetype.map)
end

function TreeNode:dctor()
	self:clear()
end

function TreeNode:clear()
	self.child_list = {}
end

function TreeNode:setdata(data)
	self.data = data
end

function TreeNode:settreetype(tree_type)
	self.tree_type = tree_type
end

function TreeNode.islist(pos)
	return not pos or type(pos) == "number"
end

function TreeNode:addchild(node)
	table.insert(self.child_list,node)
	node.index = #self.child_list
	if not node.pos then
		node.pos = node.index
	end
end

function TreeNode:removechilde(node)
	table.remove(self.child_list,node.index)
	for k,node in pairs(self.child_list) do
		node.index = k
	end
end

function TreeNode:equals(seq,pos)
	if (not seq or seq == self.seq) and self.pos == pos then
		return true
	end
	return false
end

function TreeNode:findchild(seq,pos)
	if seq and self.seq > seq then
		return nil
	end
	local len = #self.child_list
	for i=1,len do
		local node = self.child_list[i]
		if node:equals(seq,pos) then
			return node
		end
		local child = node:findchild(seq,pos)
		if child then
			return child
		end
	end
	return nil
end

function TreeNode:walk(fn,id_depth)
	if id_depth == nil then
		id_depth = true
	end
	local len = #self.child_list
	for i=1,len do
		local node = self.child_list[i]
		fn(node)
		if id_depth then
			node:walk(fn,id_depth)
		end
	end
end