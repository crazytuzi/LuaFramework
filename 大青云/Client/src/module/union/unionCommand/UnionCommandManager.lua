--[[
帮派操作命令管理
liyuan
2014年11月25日8:21:55
]]

_G.UnionCommandManager = CSingle:new()
CSingleManager:AddSingle(UnionCommandManager);

UnionCommandManager.CommandList = {}

--获得一个脚本
function UnionCommandManager:GetCommand(operId)
	local operName = UnionUtils:GetOperCommand(operId)
	
	if not operName then return nil end
	
	if not self.CommandList[operName] then
		self:DoFile(operName)
	end
	
	if self.CommandList[operName] then return self.CommandList[operName] end
	return nil
end

--执行一个脚本文件
function UnionCommandManager:DoFile(operName)
	local szSource = ""
	szSource = 'src/module/union/unionCommand/'..operName..'.lua'
	local res,inf = pcall(_dofile,szSource)
	if not res then
		Debug("Error Error Error Error Error Error Error:Script Err:",inf)
	end
end

--插入一个脚本
function UnionCommandManager:AddCommand(operName, unionCommand)
	self.CommandList[operName] = unionCommand
end