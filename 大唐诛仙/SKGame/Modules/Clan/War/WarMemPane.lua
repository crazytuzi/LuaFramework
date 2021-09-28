WarMemPane = BaseClass(LuaUI)
function WarMemPane:__init(mems)
	self.mems=mems
	-- v.guildName = 1 // 都护府名
	-- v.unionName = 2 // 联盟名
	-- v.createFlag = 3 // 是否盟主

	local ui = UIPackage.CreateObject("Duhufu","WarMemPane")
	self.ui = ui
	self.listConn = ui:GetChild("listConn")
	self.close = ui:GetChild("close")
	self:Layout()
	self:InitEvent()
end
function WarMemPane:Layout()
	self.items = {}
	local mems = self.mems
	local num = #mems
	local item
	
	for i=1,num do
		local data = mems[i]
		item = self.items[i]
		if item then
			item:Update(data)
		else
			item = WarMemItem.New(data)
			item:AddTo(self.listConn)
		end
		item:SetNum(i)
		item:SetXY(0, (i-1)*36)
		self.items[i] = item
	end
	local more = #self.items - num
	if more > 0 then
		for i=more,1,-1 do
			item = self.items[num+i]
			item:Destroy()
			item = nil
			self.items[num+i]=nil
		end
	end
end

function WarMemPane:InitEvent()
	self.close.onClick:Add(function ()
		UIMgr.HidePopup(self.ui)
	end)
end

function WarMemPane:__delete()
end