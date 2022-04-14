EnemyServerItem = EnemyServerItem or class("EnemyServerItem",BaseCloneItem)
local EnemyServerItem = EnemyServerItem

function EnemyServerItem:ctor(obj,parent_node,layer)
	EnemyServerItem.super.Load(self)
end

function EnemyServerItem:dctor()
end

function EnemyServerItem:LoadCallBack()
	self.nodes = {
		"state", "ServerName", "cancelbtn", "enemybtn"
	}
	self:GetChildren(self.nodes)
	self.ServerName = GetText(self.ServerName)
	self:AddEvent()
end

function EnemyServerItem:AddEvent()
	local function call_back(target,x,y)
		FightController.GetInstance():SetEnemy(self.data.suid, 2)
	end
	AddButtonEvent(self.cancelbtn.gameObject,call_back)

	local function call_back(target,x,y)
		local function ok_func( ... )
			FightController.GetInstance():SetEnemy(self.data.suid, 1)
		end
		local message = string.format("After set as enemy, you will Auto-attack S%s players under this mode, continue?", RoleInfoModel:GetInstance():GetServerName(self.data.suid))
		Dialog.ShowTwo("Tip",message, "Confirm", ok_func,nil, nil, nil, nil, "Don't notice me again today", nil, nil, self.__cname)
	end
	AddButtonEvent(self.enemybtn.gameObject,call_back)
end

--data{suid,is_enemy}
function EnemyServerItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function EnemyServerItem:UpdateView()
	self.ServerName.text = string.format("S%s", RoleInfoModel:GetInstance():GetServerName(self.data.suid))
	if self.data.is_enemy then
		SetVisible(self.state, true)
		SetVisible(self.cancelbtn, true)
		SetVisible(self.enemybtn, false)
	else
		SetVisible(self.state, false)
		SetVisible(self.cancelbtn, false)
		SetVisible(self.enemybtn, true)
	end
end