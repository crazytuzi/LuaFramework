ClanHDFightPane = BaseClass(LuaUI)
local render_key = "render_clan_fight"
function ClanHDFightPane:__init(root)
	self.ui = UIPackage.CreateObject("Duhufu","HDFightPane")
	self.btn = self.ui:GetChild("btn")
	self.listConn = self.ui:GetChild("listConn")
	self.parent = root
	self.items = {}
	self.model = ClanModel:GetInstance()
	self.btn.visible = self.model.job>=2
	self:Layout()
end

function ClanHDFightPane:Layout()
	self:AddTo(self.parent)
	self.btn.onClick:Add(function ()
		if self.selectedData then
			local model = self.model
			local cost = GetCfgData("constant"):Get(64).value
			if model.clanInfo.money < cost then
				UIMgr.Win_FloatTip("操作失败，都护府资金不足300！")
				return
			end

			local content = StringFormat("您确定消耗 {0} 都护府资金向 {1} 都护府宣战吗？",
				cost, self.selectedData.guildName)
			UIMgr.Win_Confirm("提示", content, "确定", "取消", function ()
				ClanCtrl:GetInstance():C_GuildWar(self.selectedData.guildId)
			end, nil)
		end
	end)
	self.warListChanged = self.model:AddEventListener(ClanConst.warListChanged, function ()
		self:Update()
	end)
end
function ClanHDFightPane:SetVisible(v, isfirst)
	LuaUI.SetVisible(self, v)
	if v and not isfirst then
		ClanCtrl:GetInstance():C_GetGuildWarList()
	end
	if v then
		RenderMgr.AddInterval(function ()
			for i=1,#self.items do
				if self.items[i].data then
					self.items[i]:UpdateTime()
				end
			end
		end, render_key, 1)
	else
		RenderMgr.Realse(render_key)
	end
end
function ClanHDFightPane:Update()
	local model = self.model
	local num = #model.warList
	local item
	self.btn.visible = model.job>=2
	for i=1,num do
		local data = model.warList[i]
		item = self.items[i]
		if item then
			item:Update(data)
		else
			item = ClanHDFightItem.New(data)
			item:SetClickCallback(function (target, v)
				if self.selected then
					self.selected.selected=false
				end
				target.selected=true
				self.selectedData=v
				self.selected = target
			end)
			item:AddTo(self.listConn)
		end
		item:SetXY(0, (i-1)*46)
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

function ClanHDFightPane:__delete()
	self.selected = nil
	self.selectedData = nil
	RenderMgr.Realse(render_key)
	if self.model then
		self.model:RemoveEventListener(self.warListChanged)
		self.model = nil
	end
end