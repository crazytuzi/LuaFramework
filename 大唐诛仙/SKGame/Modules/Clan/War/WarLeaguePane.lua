WarLeaguePane = BaseClass(LuaUI)
function WarLeaguePane:__init()
	local ui = UIPackage.CreateObject("Duhufu","WarLeaguePane")
	self.ui = ui
	self.txtName = ui:GetChild("txtName")
	self.btnCreate = ui:GetChild("btnCreate")
	self.close = ui:GetChild("close")
	self.listConn1 = ui:GetChild("listConn1")
	self.label1 = ui:GetChild("label1")
	self.label2 = ui:GetChild("label2")
	self.listConn2 = ui:GetChild("listConn2")
	self.items1 = {}
	self.items2 = {}
	self:Layout()
	self:InitEvent()
	
end
function WarLeaguePane:Layout()
	local model = ClanModel:GetInstance()
	local msg = model.cityWar
	self:Update(model.unionInfo)
end
function WarLeaguePane:Update(info)
	local model = self.model
	-- info.myUnionId --已加入的联盟
	-- info.unions --联盟列表
	-- v.unionId = 1;  // 联盟编号
	-- v.unionName = 2;  // 联盟名
	-- v.applyFlag = 3;   // 是否已申请  1：是
	-- info.applys --联盟列表
	-- v.guildId = 1;  // 都护府编号
	-- v.guildName = 2;  // 都护府名	d
	-- v.agreeFlag = 3;  // 是否有权操作同意 1：是

	local unions = info.unions
	local applys = info.applys
	local num1 = #unions
	local num2 = #applys
	local item

	local num = num1
	local items = self.items1
	for i=1,num do
		local data = unions[i]
		item = items[i]
		if item then
			item:Update(data)
		else
			item = WarLeagueItemI.New(data)
			item:AddTo(self.listConn1)
		end
		item:OnUnion(info.myUnionId)
		item:SetXY(0, (i-1)*45)
		items[i] = item
	end
	local more = #items - num
	if more > 0 then
		for i=more,1,-1 do
			item = items[num+i]
			item:Destroy()
			item = nil
			items[num+i]=nil
		end
	end

	num = num2
	items = self.items2
	for i=1,num do
		local data = applys[i]
		item = items[i]
		if item then
			item:Update(data)
		else
			item = WarLeagueItemII.New(data)
			item:AddTo(self.listConn2)
		end
		item:SetXY(0, (i-1)*45)
		items[i] = item
	end
	local more = #items - num
	if more > 0 then
		for i=more,1,-1 do
			item = items[num+i]
			item:Destroy()
			item = nil
			items[num+i]=nil
		end
	end
end
function WarLeaguePane:InitEvent()
	self.close.onClick:Add(function ()
		UIMgr.HidePopup(self.ui)
	end)
	self.btnCreate.onClick:Add(function ()
		local v = self.txtName.text
		if  string.trim(v) == "" or string.utf8len(v)>4 or #v<4 then
			UIMgr.Win_FloatTip("盟派名称长度不对，应该是4个汉字组成")
			return
		end
		if isExistSensitive(v) then
			UIMgr.Win_FloatTip("盟派名称不合法！")
			return
		end
		ClanCtrl:GetInstance():C_CreateUnion(v)
	end)
end

function WarLeaguePane:__delete()
end