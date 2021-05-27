-- 在每帧最后清理要remove的节点，防止在回调时清理

NodeCleaner = NodeCleaner or BaseClass()

function NodeCleaner:__init()
	if NodeCleaner.Instance then
		ErrorLog("[NodeCleaner]:Attempt to create singleton twice!")
	end
	NodeCleaner.Instance = self

	self.node_list = {}
	Runner.Instance:AddRunObj(self, 16)
end

function NodeCleaner:__delete()
	NodeCleaner.Instance = nil
	Runner.Instance:RemoveRunObj(self)
end

function NodeCleaner:Update(now_time, elapse_time)
	if #self.node_list <= 0 then
		return
	end
	
	for k, v in pairs(self.node_list) do
		v:removeFromParent()
	end
	self.node_list = {}
end

function NodeCleaner:AddNode(node)
	table.insert(self.node_list, node)
end
