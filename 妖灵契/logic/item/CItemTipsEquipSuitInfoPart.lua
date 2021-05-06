--------------------------------------------------------------------
--装备的套装开启状况显示界面


--------------------------------------------------------------------
local CItemTipsEquipSuitInfoPart = class("CItemTipsEquipSuitInfoPart", CBox)

CItemTipsEquipSuitInfoPart.SuitColor = 
{
	[1] = Color.New(0/255, 245/255,1/255, 255/255),	--"00F501FF", --绿色 
	[2] = Color.New(255/255, 255/255,255/255, 107/255),	--"FFFFFF6B",	--灰色
}

local t = {
	
	[1] = "风水山林",
	[2] = 
	{
		[1] = {"风雷扇子",true},
		[2] = {"烈火吊坠",false},
		[3] = {"林木战甲",false},
		[4] = {"馨龙指环",true},
		[5] = {"疾风鞋",false}

	},
	[3] = 
	{
		[1] = {"(1)套装:攻击力+5%", true},
		[2] = {"(2)套装:防御力+5%，受到伤害时会使用火属性法术反击对方", false}
	} 
}

function CItemTipsEquipSuitInfoPart.ctor(self, obj)
	self.m_SuitItem = nil

	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_SuitAttrTable = self:NewUI(2, CTable)
	self.m_SuitContentCloneBox = self:NewUI(3, CBox)
	self.m_SuitDivCloneBox = self:NewUI(4, CBox)
	self.m_SuitDesCloneBox = self:NewUI(5, CBox)

	self:InitContent()
end

function CItemTipsEquipSuitInfoPart.InitContent(self)
	self.m_SuitContentCloneBox:SetActive(false)
	self.m_SuitDivCloneBox:SetActive(false)
	self.m_SuitDesCloneBox:SetActive(false)

end

function CItemTipsEquipSuitInfoPart.SetInitBox( self ,tItem )

	if not tItem then
		return
	end
	self.m_SuitItem = tItem
	local isActiveCount, unActiveCoujnt = 0, 0

	self.m_SuitAttrTable:Clear()

	--套装列表
	for i = 1, #t[2] do
		local data = t[2][i] 
		if data ~= nil then
			local tBox = self.m_SuitContentCloneBox:Clone()
			tBox:SetActive(true)
			tBox.m_ContentLabel = tBox:NewUI(1, CLabel)
			tBox.m_ContentLabel:SetText(data[1])
			if data[2] == true then
				isActiveCount = isActiveCount + 1
				tBox.m_ContentLabel:SetColor(CItemTipsEquipSuitInfoPart.SuitColor[1])
			else
				unActiveCoujnt = unActiveCoujnt + 1
				tBox.m_ContentLabel:SetColor(CItemTipsEquipSuitInfoPart.SuitColor[2])
			end
			self.m_SuitAttrTable:AddChild(tBox)
		end
	end

	--插入分割行
	local tDivBox = self.m_SuitDivCloneBox:Clone()
	tDivBox:SetActive(true)
	self.m_SuitAttrTable:AddChild(tDivBox)	

	--套装效果列表
	for i = 1, #t[3] do
		local data = t[3][i] 
		if data ~= nil then
			local tBox = self.m_SuitDesCloneBox:Clone()
			tBox:SetActive(true)
			tBox.m_DesLabel = tBox:NewUI(1, CLabel)
			tBox.m_DesLabel:SetText(data[1])
			if data[2] == true then				
				tBox.m_DesLabel:SetColor(CItemTipsEquipSuitInfoPart.SuitColor[1])
			else				
				tBox.m_DesLabel:SetColor(CItemTipsEquipSuitInfoPart.SuitColor[2])
			end
			self.m_SuitAttrTable:AddChild(tBox)
		end
	end

	self.m_NameLabel:SetText(string.format("%s  (%d/%d)",
				 t[1], isActiveCount , isActiveCount + unActiveCoujnt ))

	self:AdjustHeight()
end

function CItemTipsEquipSuitInfoPart.AdjustHeight(self )
	self.m_SuitAttrTable:Reposition()
	local bounds = UITools.CalculateRelativeWidgetBounds(self.m_SuitAttrTable.m_Transform)
	self:SetHeight( self:GetHeight() + bounds.max.y - bounds.min.y)
end

return CItemTipsEquipSuitInfoPart