--[[npc�ű�������
liyuan
2014��11��10��20:12:32
]]

_G.StoryScriptManager = CSingle:new();
CSingleManager:AddSingle(StoryScriptManager); 

--Ѳ�߽ű�
StoryScriptManager.Patrol = {}

function StoryScriptManager:Create()
	 
	return true;
end;

function StoryScriptManager:Update(dwInterval)
	return true;
end;

function StoryScriptManager:Destroy()
	
end;

local function CopyTable(t)
	local out = {}
	for k,v in pairs(t) do
		if type(v)=="table" then
			out[k] = CopyTable(v)
		else
			out[k] = v
		end
	end
	return out;
end

function StoryScriptManager:GetMyScript()
	return self:GetScript(1)
end

function StoryScriptManager:AddMyScript(tbFun)
	StoryScriptManager:AddScript(1,tbFun)
end


--���һ���ű�
function StoryScriptManager:GetScript(dwId)
	local tbFun = {}
	if not self.Patrol[dwId] then
		self:DoFile(dwId)
	end
	self.Patrol[dwId] = self.Patrol[dwId] or {}
	tbFun = self.Patrol[dwId]
	
	return CopyTable(tbFun or {})
end

--ִ��һ���ű��ļ�
function StoryScriptManager:DoFile(DwId)
	local szSource = ""
	szSource = ClientConfigPath .. 'config/storyconfig/patrol_'..DwId..'.lua'
	local res,inf = pcall(_dofile,szSource)
	Debug(szSource)
	if not res then
		Debug("Error Error Error Error Error Error Error:Script Err:",inf)
	end
end

--����һ���ű�
function StoryScriptManager:AddScript(dwId,tbFun)
	self.Patrol[dwId] = tbFun
end
