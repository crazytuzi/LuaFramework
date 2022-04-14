--
-- @author: laoy
-- @date:   2019-06-24 19:57:19
--

Tree = Tree or class("Tree")

function Tree:ctor(data,pos,node_cls)
	self.node_cls = node_cls or TreeNode
	self.index = 0
	self.top_node = self:addnode(nil,pos,data)
end

function Tree:dctor()
end

function Tree:addnode(parent_node,pos,data)
	parent_node = parent_node or self.top_node
	local node = self.node_cls(parent_node,pos)
	if parent_node then
		parent_node:addchild(node)
	end

	node.id = self.index

	--local seq = node.seq
	--local pos = node.pos
	node:setdata(data)

	self.index = self.index + 1
	return node
end

function Tree:findnode(seq,pos)
	if not seq and TreeNode.islist(pos) then
		assert(false,"tree.findnode param is error,the param is " .. tostring(seq) .. "," .. tostring(pos))
		return nil
	end
	return self.top_node:findchild(seq,pos)
end

function Tree:remove(seq,pos)
	local node = self:findnode(seq,pos)
	self:removenode(node)
end

function Tree:removenode(node)
	local parent_node = node.parent_node
	if parent_node then
		parent_node:removechilde(node)
	else
		node:destroy()
	end
end

function Tree:walk(fn,id_depth)
	self.top_node:walk(fn,id_depth)
end