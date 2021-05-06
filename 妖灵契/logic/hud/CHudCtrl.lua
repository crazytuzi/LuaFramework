local CHudCtrl = class("CHudCtrl")
CHudCtrl.g_MaxCached = 10

function CHudCtrl.ctor(self)
	self.m_Root = nil
	self.m_UsedCache = {}
	self.m_UnusedCache = {}
	self.m_LoadingList = {}
	self.m_Panels = {}
end

function CHudCtrl.InitRoot(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Hud/HudRoot.prefab")
	self.m_Root = CPanel.New(obj)
	local oUIRoot = UITools.GetUIRootObj(false)
	self.m_Root:SetParent(oUIRoot:GetTransform())
end

function CHudCtrl.GetHudRoot(self)
	return self.m_Root
end

--~g_HudCtrl:GetParentPanel("A")
function CHudCtrl.GetParentPanel(self, sName)
	local tDepth = {
		CNameHud = 1,
		CTitleHud = 2,
		EmptyHud = 10,
		CStarGridHud = 11,
		CTerraWarHud = 17,
		CBloodHud = 19,
		CLevelHud = 19,
		CWarriorDamageHud = 21,
		CWarriorBuffHud = 20,
		CWarriorMagicHud = 21,
		CWarriorJiHuoHud = 22,
		CWarriorAddSpHud = 23,
		CWarriorCommandHud = 24,
		CTaskChatHud = 44,
		CSocialEmojiHud = 45,
		CChatHud = 50,--聊天放到最前
	}
	local oRoot = self.m_Panels[sName]
	if not oRoot then
		local iDepth = tDepth[sName]
		if iDepth then
			local obj = UnityEngine.GameObject.New()
			obj:AddComponent(classtype.UIPanel)
			local oPanel = CPanel.New(obj)
			oPanel:SetDepth(iDepth)
			oPanel:SetName(sName.."Root")
			if iDepth < 0 then
				oPanel:SetLayer(UnityEngine.LayerMask.NameToLayer("BottomUI"))
			else
				oPanel:SetLayer(self.m_Root:GetLayer())
			end
			oPanel:SetParent(self.m_Root.m_Transform)
			self.m_Panels[sName] = oPanel
			oRoot = oPanel
		end
	end
	if not oRoot then
		oRoot = self.m_Root
	end
	return oRoot
end

function CHudCtrl.SetRootActive(self, bActive)
	do return end
	-- printerror("????????????????????????????", self.m_Root:GetName(), bActive)
	-- self.m_Root:SetActive(bActive)
	self.m_Root.m_GameObject:SetActive(bActive)
end

function CHudCtrl.SetPanelActive(self, sType, bActive)
	local oRoot = self:GetParentPanel(sType)
	if oRoot then
		oRoot:SetActive(bActive)
	end
end

function CHudCtrl.GetEmptyHud(self)
	local gameObject = UnityEngine.GameObject.New()
	local oHud = CHud.New(gameObject)
	oHud:SetName("EmptyHud")
	local oParent = self:GetParentPanel("EmptyHud")
	oHud:SetParent(oParent.m_Transform)
	return oHud
end

function CHudCtrl.GetLoadFunc(self, cls, cb)
	return function(oHud)
		local oParent = self:GetParentPanel(cls.classname)
		oHud:SetParent(oParent.m_Transform)
		self:SetUsed(cls, oHud)
		cb(oHud)
		local idx = table.index(self.m_LoadingList, oHud)
		if idx then
			table.remove(self.m_LoadingList, idx)
		end
	end
end

function CHudCtrl.AddHudByCls(self, cls, cb)
	local oCached = self:GetUnused(cls)
	local f = self:GetLoadFunc(cls, cb)
	if oCached then
		f(oCached)
	else
		local oLoading = cls.New(f)
		table.insert(self.m_LoadingList, oLoading)
	end
end

function CHudCtrl.SetUsed(self, cls, oHud)
	local list = self.m_UsedCache[cls.classname]
	if not list then
		list = {}
	end
	oHud:SetActive(true)
	oHud:SetAutoUpdate(true)
	list[oHud:GetInstanceID()] = oHud
	self.m_UsedCache[cls.classname] = list
end

function CHudCtrl.GetUnused(self, cls)
	local list = self.m_UnusedCache[cls.classname]
	if self.m_UnusedCache[cls.classname] then
		local oHud = list[1]
		table.remove(list, 1)
		self.m_UnusedCache[cls.classname] = list
		return oHud
	end
end

function CHudCtrl.SetUnused(self, oHud)
	local clsname = oHud.classname
	local list = self.m_UnusedCache[clsname]
	if not list then
		list = {}
	end
	self.m_UsedCache[clsname][oHud:GetInstanceID()] = nil
	if #list >= CHudCtrl.g_MaxCached then
		oHud:Destroy()
		return
	end
	oHud:ResetHud()
	oHud:Recycle()
	table.insert(list, oHud)
	self.m_UnusedCache[clsname] = list
end

return CHudCtrl