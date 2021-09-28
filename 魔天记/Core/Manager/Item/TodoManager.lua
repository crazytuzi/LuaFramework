TodoConst = {};
TodoConst.Type = {
	NORMAL = 0;
	GOTONPC = 1;
}

TodoManager = {};
TodoManager.data = {};
TodoManager.idx = 1;
TodoManager.autoData = nil;

TodoManager.ENV_TODO_CHG = "Todo_Env_Chg";
TodoManager.TODO_START_DO = "TODO_START_DO";

function TodoManager.Clear()
	TodoManager.idx = 1;
	for k, v in pairs(TodoManager.data) do
		TodoManager.Remove(v);
	end
end

function TodoManager._Get(type, data, onComplete)
	local todo = {type = type, data = data, onComplete = onComplete};
	todo.id = TodoManager.idx;
	TodoManager.idx = TodoManager.idx + 1;
	return todo;
end

--[[
新增某一个todo选项
必选参数
*ico 是显示的标识. 新增要修改MianUI里面的UI_PartyAndTaskPanel/taskPanel/taskItem
*label 是显示todo的language字段(所需参数都写入到data里 如x, y);
#desc(非必选) 指定显示的描述内容. 如果没有指定则根据类型去生成显示描述. 
条件参数(必须)
	TodoConst.Type.GOTONPC - npcId(要找的npcid) mapId(要去的地图id) pos(要去的位置).


ex:
--添加一个移动到某个NPC位置的todo
local tmpData = {ico = 20, label = "todo/act/1", x = 2, y = 3, npcId = 130703, mapId = 701000, pos = Vector3.New(-22.49, 0, 42.66)};
local func = function() log("完成.") end;
TodoManager.Add(TodoConst.Type.GOTONPC, tmpData, func);

--添加一个显示描述的todo
local tmpData = {ico = 20, label = "todo/act/2", desc = "123123"};
TodoManager.Add(TodoConst.Type.NORMAL, tmpData);
]]
function TodoManager.Add(type, data, onComplete)
	local todo = TodoManager._Get(type, data, onComplete);
	TodoManager.data[todo.id] = todo;
	MessageManager.Dispatch(TodoManager, TodoManager.ENV_TODO_CHG);
	return todo;
end
--[[
删除某一个todo选项.
]]
function TodoManager.Remove(data)
	if data == nil then
		return;
	end

	if TaskManager._auto.task and TaskManager._auto.task.id == data.id then
		TaskManager._auto:Stop();
	end

	TodoManager.data[data.id] = nil;
	MessageManager.Dispatch(TodoManager, TodoManager.ENV_TODO_CHG);
end
local insert = table.insert
 
function TodoManager.GetTodoList()
	local d = {};
	for k, v in pairs(TodoManager.data) do
		insert(d, v);
	end
	return d;
end

function TodoManager.Auto(data)
	--if TodoManager.autoData == nil or TodoManager.autoData.id ~= data.id then
	--	log("auto - > " .. data.id);
		TaskManager._auto:Start(data);
		TodoManager.autoData = data;

		MessageManager.Dispatch(TodoManager, TodoManager.TODO_START_DO,data);

	--end
end



