local CGmCtrl = class("CGmCtrl", CCtrlBase)

function CGmCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_RecordInput = nil
	self.m_Record = nil

	self.m_HelpMsg = nil
end

function CGmCtrl.GetRecord(self)
	if not self.m_Record then
		self.m_Record = IOTools.GetClientData("gm_Record") or {}
	end
end

function CGmCtrl.GetRecordInstruct(self)
	self:GetRecord()
	return self.m_Record.instruct or {}
end

function CGmCtrl.GetRecordTab(self)
	self:GetRecord()
	return self.m_Record.tab or 1
end

function CGmCtrl.SetRecordTab(self, index)
	self:GetRecord()
	if self.m_Record.tab ~= index then
		self.m_Record.tab = index
		IOTools.SetClientData("gm_Record", self.m_Record)
	end
end

function CGmCtrl.SetRecord(self, sParam)
	if sParam then
		self.m_Record.instruct = self:GetRecordInstruct()
		if self.m_Record.instruct then
			local updateIndex = -1
			local splitList = string.split(sParam, ' ')
			local cutName = splitList[1]
			for i,v in ipairs(self.m_Record.instruct) do
				local splitList = string.split(v.name, ' ')
				local oldName = splitList[1]
				if oldName == cutName then
					updateIndex = i
					break
				end
			end

			if updateIndex > 0 then
				table.remove(self.m_Record.instruct, updateIndex)
			else
				if #self.m_Record.instruct == 10 then
					table.remove(self.m_Record.instruct, 1)
				end
			end

			local tInfo = {name = sParam, param = sParam}
			table.insert(self.m_Record.instruct, tInfo)

			self:OnEvent(define.Gm.Event.RefreshLastInfo)
			IOTools.SetClientData("gm_Record", self.m_Record)

		end
	end
end

function CGmCtrl.CleanRecordInstructDic(self)
	self.m_Record = {}

	self:OnEvent(define.Gm.Event.RefreshLastInfo)
	IOTools.SetClientData("gm_Record", self.m_Record)
end

function CGmCtrl.CleanConsoleTip(self)
	self:GS2CGMMessage()
end

function CGmCtrl.TimeEvent(self, oMsg)
	self:OnEvent(define.Gm.Event.RefreshTime, oMsg)
end

function CGmCtrl.GS2CGMMessage(self, msg)
	self.m_HelpMsg = msg
	self:OnEvent(define.Gm.Event.RefreshGmHelpMsg)
end

function CGmCtrl.C2GSGMCmd(self, param)
	self:SetRecord(param)
	netother.C2GSGMCmd(param)
end

function CGmCtrl.ShowItemID(self, isShow)
	self.m_IsShowItemID = isShow
	self:OnEvent(define.Gm.Event.ShowItemId, isShow)
end
return CGmCtrl