

local _M = {}
_M.__index = _M

_M.Status = {
  NONE = -2,
  NEW = -1,
  IN_PROGRESS = 0,
  CAN_FINISH = 1,
  DONE = 2,		
}

function _M.GetState(parent,quest_id)
	local q = DataMgr.Instance.QuestManager:GetQuest(quest_id)
	if not q then
		return _M.NONE
	else
		return GameUtil.TryEnumToInt(q.State)
	end
end

function _M.GetPreState(parent,quest_id)
	local q = DataMgr.Instance.QuestManager:GetQuest(quest_id)
	if not q then
		return _M.NONE
	else
		return GameUtil.TryEnumToInt(q.PreState)
	end
end

function _M.GetProgress(parent,quest_id)
	local q = DataMgr.Instance.QuestManager:GetQuest(quest_id)
	if q then
		return q.Progress
	end	
end

function _M.GetStringParam(parent,quest_id,key)
	local q = DataMgr.Instance.QuestManager:GetQuest(quest_id)
	if q then
		return q:GetStringParam(key)
	end	
end

function _M.GetIntParam(parent,quest_id,key)
	local q = DataMgr.Instance.QuestManager:GetQuest(quest_id)
	if q then
		return q:GetIntParam(key)
	end	
end

function _M.GetDoScene(parent,quest_id)
	local q = DataMgr.Instance.QuestManager:GetQuest(quest_id)
	if q then
		return q:GetIntParam('DoScene')
	end	
end

function _M.GetName(parent,quest_id)
	local q = DataMgr.Instance.QuestManager:GetQuest(quest_id)
	if q then
		return q.Name
	end	
end

function _M.isExistQuest(parent,quest_id)
	local q = DataMgr.Instance.QuestManager:GetQuest(quest_id)
	return q ~= nil
end

function _M.GetMainQuest(parent)
	local q = DataMgr.Instance.QuestManager:GetTrunkQuest()
	if q then
		return q.TemplateID
	end
end

function _M.GetQuestStatic(parent,id)
	return GlobalHooks.DB.Find('Tasks',id)
end

function _M.Seek(parent,id)
	local q = DataMgr.Instance.QuestManager:GetQuest(quest_id)
	if q then
		q:Seek()
	end
end

function _M.Clear(parent)

end

return _M
