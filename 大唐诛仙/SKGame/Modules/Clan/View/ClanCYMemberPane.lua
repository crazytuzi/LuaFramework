ClanCYMemberPane = BaseClass(LuaUI)
function ClanCYMemberPane:__init(root)
	self.ui = UIPackage.CreateObject("Duhufu","CYMemberPane")
	self.btnMsg = self.ui:GetChild("btnMsg")
	self.btnExit = self.ui:GetChild("btnExit")
	self.btnExchange = self.ui:GetChild("btnExchange")
	self.txtNum = self.ui:GetChild("txtNum")
	self.listConn = self.ui:GetChild("listConn")
	self.parent = root
	self:Layout()
	self:InitEvent()
end
function ClanCYMemberPane:Layout()
	self:AddTo(self.parent)
	self:SetXY(0, 0)
end
function ClanCYMemberPane:InitEvent()
	self.items = {}
	self.model = ClanModel:GetInstance()
	self.roleVo = SceneModel:GetInstance():GetMainPlayer()
	self.btnExit.onClick:Add(function (e)
		if self.roleVo and self.roleVo.eid == self.model.clanInfo.headerId and #self.model.members>1  then
			UIMgr.Win_FloatTip("操作失败，贵俯尚有其他成员在，您是都护，不能退出！")
			return
		end
		UIMgr.Win_Confirm("提示", "您确定要退出都护府吗？", "退出", "取消", function ()
			ClanCtrl:GetInstance():C_QuitGuild()
		end, nil)
	end)
	self.btnExchange.onClick:Add(function (e)
		print("功能待开发中。。")
	end)
	self.btnMsg.onClick:Add(function (e)
		print("功能待开发中。。")
	end)
end
function ClanCYMemberPane:SetVisible(v, isfirst)
	LuaUI.SetVisible(self, v)

	if v and not isfirst then
		if self.selected then
			self.selected.selected=false
		end
		self.selected = nil
		ClanCtrl:GetInstance():C_GetGuildPlayerList()
	end
end
function ClanCYMemberPane:Update()
	local model = self.model
	local num = #model.members
	local item
	
	for i=1,num do
		local data = model.members[i]
		item = self.items[i]
		if item then
			item:Update(data)
		else
			item = ClanCYMemberItem.New(data)
			item:SetClickCallback(function (target, data)
				if self.selected then
					self.selected.selected=false
				end
				target.selected=true
				self.selected = target
				-- if self.roleVo==nil or self.roleVo.eid == data.playerId then return end -- 自己级不能操作
				if model.job<2 then return end -- 低级不能操作
				if model.job<=data.roleId then return end -- 同级或高级不能操作
				UIMgr.ShowCenterPopup(ClanChangeJobPane.New(data), nil, true)
			end)
			item:AddTo(self.listConn)
		end
		item:SetXY(0, (i-1)*50)
		self.items[i] = item
		self.txtNum.text = model.onlineNum.."/"..num
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

function ClanCYMemberPane:__delete()
	self.selected = nil
	self.roleVo=nil
end