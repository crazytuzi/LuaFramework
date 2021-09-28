ClanHDContributePane = BaseClass(LuaUI)
function ClanHDContributePane:__init(root)
	self.ui = UIPackage.CreateObject("Duhufu","HDContributePane")
	self.listConn = self.ui:GetChild("listConn")
	self.parent = root
	self.dataList = {}
	self.items = {}
	self:Layout()

	self.model = ClanModel:GetInstance()
	self.donateChanged = self.model:AddEventListener(ClanConst.donateChanged, function ()
		self.dataList = self.model.donateList
		self:Update()
	end)
end

function ClanHDContributePane:Layout()
	self:AddTo(self.parent)
	local cfg = GetCfgData("guilddonate")
	local num = #cfg
	local item
	
	for i=1,num do
		local data = cfg[i]
		item = ClanHDContributeItem.New(data)
		item:AddTo(self.listConn)
		self.items[i] = item
		item:SetXY(8, (i-1)*110+8)
	end
end
function ClanHDContributePane:SetVisible(v, isfirst)
	LuaUI.SetVisible(self, v)
	if v and not isfirst then
		ClanCtrl:GetInstance():C_GetDonateTimes()
	end
end
function ClanHDContributePane:Update()
	local dataList = self.dataList
	local items = self.items
	for i=1,#dataList do
		for j=1,#items do
			local item = items[j]
			if item.data and item.data.id == dataList[i].id then
				if dataList[i].times >= item.data.limitTimes then
					item.btn.title = "已达上限"
					item.limited = true
				else
					item.btn.title = "捐献"
					item.limited = false
				end
			end
		end
	end
end

function ClanHDContributePane:__delete()
	self.cfg = nil
	if self.model then
		self.model:RemoveEventListener(self.donateChanged)
		self.model = nil
	end
end