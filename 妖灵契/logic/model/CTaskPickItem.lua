local CTaskPickItem = class("CTaskPickItem", CMapWalker)

function CTaskPickItem.ctor(self)

	CMapWalker.ctor(self)

	self.m_PickInfo = nil -- {pickid, name, pos_info}

	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, 150, 0))
end

function CTaskPickItem.OnTouch(self)
	-- TODO >>> 点到DynamicPick
	CMapWalker.OnTouch(self, self.m_PickInfo.pickid)
end

function CTaskPickItem.Trigger(self)
	-- self:FaceToHero()
	table.print(self.m_PickInfo)
	local pickid = self.m_PickInfo.pickid
	local taskList = g_TaskCtrl:GetPickAssociatedTaskList(pickid)
	table.print(taskList)
	if taskList and #taskList > 0 then
		local oTask = taskList[1]
		g_TaskCtrl:ClickTaskLogic(oTask)
	end
end

return CTaskPickItem