local CTaskChapterFbNpc = class("CTaskChapterFbNpc", CMapWalker)

function CTaskChapterFbNpc.ctor(self)
	CMapWalker.ctor(self)
	self:SetCheckInScreen(true)	
end

function CTaskChapterFbNpc.SetData(self, clientNpc)
	self.m_ClientNpc = clientNpc
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, clientNpc.rotateY or 150, 0))
end


function CTaskChapterFbNpc.OnTouch(self)	
	CMapWalker.OnTouch(self, self.m_ClientNpc.npcid)
	self:SetTouchTipsTag(1)
end

function CTaskChapterFbNpc.Trigger(self)
	self:ShowDialogue()
end

function CTaskChapterFbNpc.Destroy(self)
	CMapWalker.Destroy(self)
end

function CTaskChapterFbNpc.ShowDialogue(self)
	if self.m_ClientNpc.IsMain then		
		self:ShowMainDialogue()
	else
		self:ShowSubDialogue()
	end
end

function CTaskChapterFbNpc.ShowMainDialogue(self)
	local taskId = self.m_ClientNpc.taskId
	local t = data.taskdata.TASK.STORY.DIALOG[taskId]
	if not t then		
		return false
	end
	local cpData = nil
	for i, v in ipairs(t) do
		if v.is_chapter_dialogue ~= 0 then
			cpData = v
			break
		end
	end
	if not cpData then		
		return false
	end
	local client = self.m_ClientNpc
	local info = string.split(cpData.chapter_last_action, ",")
	local d = {}
	local dialog ={}
	dialog[1] = 
	{
		content = cpData.content,
		next = "0",
		pre_id_list = cpData.pre_id_list,
		status = 2,
		subid = cpData.subid,
		type = cpData.type,
		ui_mode = define.Dialogue.Mode.Dialogue,
		voice = 0,
		hide_back_jump = true,
		last_action = 
		{
			[1] = 
			{
				content = info[1] or "挑战他",
				event = "F",
				callback = function ()												
					nethuodong.C2GSFightChapterFb(self.m_ClientNpc.chapter, self.m_ClientNpc.level, define.ChapterFuBen.Type.Simple)
				end,
			},
			[2] = 
			{
				content = info[2] or "考虑一下",
				callback = function ()							
				end,
			}
		},
	}			
	d.dialog = dialog
	d.dialog_id = taskId
	d.npcid = 0
	d.npc_name = client.name
	d.shape = client.model_info.shape
	CDialogueMainView:ShowView(function (oView)
		oView:SetContent(d)
		oView:SetCloseCallBack(callback(self, "ReSetFace"))
		g_DialogueCtrl:OnEvent(define.Dialogue.Event.Dialogue, d)
	end)
	g_MapCtrl:HeroDialoguePosResetByWalker(self)	
	self:FaceToHero()
	return true		
end

function CTaskChapterFbNpc.ShowSubDialogue(self)
	local client = self.m_ClientNpc
	local t = data.npcdata.TASK_NPC[client.dialog_id]
	local text = "有趣，真有趣，呵哈哈哈哈哈……"
	if t then
		text = t.dialogContent1
	end

	local d = 
		{
			dialog = 
			{
				[1] = 
				{	content = text,
					type = 2, --与目标Npc对话
					ui_mode = define.Dialogue.Mode.MainMenu,
					voice = 0,
				}
			},
			dialog_id = 0,
			sessionidx = 0,
			npcid = 0,
			shape = client.model_info.shape,
			npc_name = client.name,
			text = text,
			task_type = 0,
		}
	CDialogueMainView:ShowView(function (oView)
		oView:SetContent(d)
		oView:SetCloseCallBack(callback(self, "ReSetFace"))
		g_DialogueCtrl:OnEvent(define.Dialogue.Event.Dialogue, d)
	end)	
	g_MapCtrl:HeroDialoguePosResetByWalker(self)	
	self:FaceToHero()
	return true			
end

function CTaskChapterFbNpc.ReSetFace(self)
	if not Utils.IsNil(self) then
		self.m_Actor:SetLocalRotation(Quaternion.Euler(0, self.m_ClientNpc.rotateY or 150, 0))
	end
end

return CTaskChapterFbNpc