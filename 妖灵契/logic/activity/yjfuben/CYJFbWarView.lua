local CYJFbWarView = class("CYJFbWarView", CViewBase)

CYJFbWarView.CloseViewTime = 5

function CYJFbWarView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/YJFuben/YJWarView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
end

function CYJFbWarView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_MainGrid = self:NewUI(2, CGrid)
	self.m_IconBox = self:NewUI(3, CBox)
	self.m_FightGrid = self:NewUI(4, CGrid)
	self.m_FightBox = self:NewUI(5, CBox)
	self:InitContent()
end

function CYJFbWarView.InitContent(self)
	self.m_IconBox:SetActive(false)
	self.m_FightBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CYJFbWarView.RefreshData(self, npcList)
	self.m_MainGrid:Clear()
	local ndata = data.yjfubendata.NPC
	for _, oNpc in ipairs(npcList) do
		local npcid = oNpc.idx
		local box = self.m_IconBox:Clone()
		box.m_Icon = box:NewUI(1, CSprite)
		box.m_Name = box:NewUI(2, CLabel)
		box.m_Icon:SpriteAvatar(oNpc.shape)
		box.m_Name:SetText(oNpc.name)
		box.m_Icon:AddUIEvent("click", callback(self, "OnClickIcon", npcid))
		box:SetActive(true)
		box.m_Icon:SetGroup(self.m_MainGrid:GetInstanceID())
		self.m_MainGrid:AddChild(box)
	end
	local box = self.m_MainGrid:GetChild(1)
	if box then
		box:SetSelected(true)
	end
	self.m_MainGrid:Reposition()
end

function CYJFbWarView.RefreshFight(self, dData)
	self.m_FightGrid:Clear()
	local t = {"首轮战斗", "次轮战斗", "终轮战斗"}
	local bossdata = self:GetBossDessData()
	for i, list in ipairs(dData) do
		local box = self.m_FightBox:Clone()
		box.m_Grid = box:NewUI(1, CGrid)
		box.m_Icon = box:NewUI(2, CSprite)
		box.m_Title = box:NewUI(3, CLabel)

		box.m_Title:SetText(t[i])
		box:SetActive(true)
		box.m_Icon:SetActive(false)
		box.m_Grid:Clear()
		for _, shape in ipairs(list.shapelist) do
			local spr = box.m_Icon:Clone()
			spr:SetActive(true)
			spr:SpriteAvatar(shape)
			local oData = {
				shape = shape,
				desc = bossdata[shape].desc,
				content = bossdata[shape].content,
				name = bossdata[shape].name,
			}
			spr:AddUIEvent("click", callback(self, "OnClickBoss", oData))
			box.m_Grid:AddChild(spr)
		end
		box.m_Grid:Reposition()
		self.m_FightGrid:AddChild(box)
	end
	self.m_FightGrid:Reposition()
end

function CYJFbWarView.GetBossDessData(self)
	local bossdata =data.yjfubendata.BossDesc
	local dict = {}
	for id, oData in pairs(bossdata) do
		dict[oData.shape] = oData
	end
	return dict
end
function CYJFbWarView.OnClickBoss(self, oData)
	CItemTipsPartnerView:ShowView(function (oView)
		oView:RefreshYJBossInfo(oData)
	end)
end

function CYJFbWarView.OnClickIcon(self, npcid)
	nethuodong.C2GSYJFubenView(npcid)
end

return CYJFbWarView