local CTabGrid = class("CTabGrid", CGrid)

-- 默认样式
CTabGrid.g_TabGridDefStyle = {
	[0] = {
		normal = {
			textColor = Color.New(170/255, 234/255, 224/255, 1),
			textEffectColor = Color.New(53/255, 122/255, 125/255, 1),
			textOffsetPos = Vector2.New(0, -4),
		},
		selected = {
			textColor = Color.New(173/255, 105/255, 68/255, 1),
			textEffectColor = Color.New(246/255, 240/255, 222/255, 1),
			textOffsetPos = Vector2.New(0, -2),
		},
	},
	[1] = {
		normal = {
			textColor = Color.New(173/255, 230/255, 216/255, 1),
			textEffectColor = Color.New(22/255, 107/255, 120/255, 1),
			textOffsetPos = Vector2.New(-5, -6),
		},
		selected = {
			textColor = Color.New(173/255, 105/255, 68/255, 1),
			textEffectColor = Color.New(255/255, 250/255, 236/255, 1),
			textOffsetPos = Vector2.New(0, -6),
		},
	}
}

function CTabGrid.ctor(self, obj, style)
	CGrid.ctor(self, obj)
	self.m_Style = style or CTabGrid.g_TabGridDefStyle[self.m_UIGrid.arrangement]
end

function CTabGrid.InitChild(self, newfunc)
	self:CheckChange()
	local len = #self.m_TransformList
	for i = 1, len do
		local t = self.m_TransformList[i]
		local oTabBtn = newfunc(t.gameObject, i)
		oTabBtn:SetClickSounPath(define.Audio.SoundPath.Tab)
		self.m_LuaObjDict[t.gameObject:GetInstanceID()] = oTabBtn
	end
end

function CTabGrid.SetTabSelect(self, tabBtn)
	if tabBtn then
		tabBtn:SetSelected(true)
		local tabList = self:GetChildList()
		if tabList and #tabList > 0 then
			for _,v in ipairs(tabList) do
				local show = v == tabBtn
				self:ShowHighlight(v, show)
			end
		end
	end
end

function CTabGrid.ShowHighlight(self, tabBtn, show)
	if tabBtn and tabBtn:IsLabelInChild() then
		local key = (show and "selected") or "normal"
		tabBtn:SetTextColor(self.m_Style[key].textColor)
		tabBtn:SetEffectColor(self.m_Style[key].textEffectColor)

		local tabStr = tabBtn:GetText()
		local isLimitLen = string.len(tabStr) < 9
		local fontSize = 23
		if show and isLimitLen then
			fontSize = 28
		end
		local label = tabBtn.m_ChildLabel:GetComponentInChildren(classtype.UILabel)
		label.fontSize = fontSize

		-- 判断横竖样式
		if self.m_UIGrid.arrangement == 1 then
			tabBtn.m_ChildLabel:SetWidth(fontSize)
			tabBtn.m_ChildLabel:MakePixelPerfect()

			local offset = self.m_Style[key].textOffsetPos
			if not isLimitLen then
				offset = offset - Vector2.New(0, offset.y)
			end
			UITools.NearTarget(tabBtn, tabBtn.m_ChildLabel, enum.UIAnchor.Side.Center, offset)
		end
	end
end

return CTabGrid