module(..., package.seeall)

function DrawLine(beginPos, endPos, sName)
	local oEffect = CEffect.New("UI/_Editor/Line.prefab", nil, false, function(oEff)
			oEff.m_Eff:SetLocalScale(Vector3.New(0.01, (endPos-beginPos).magnitude/2, 0.01))
		end)
	oEffect:SetPos((beginPos+endPos)/2)
	oEffect:LookAt(endPos, Vector3.up)
	sName = sName or tostring(beginPos)..tostring(endPos)
	if sName then
		oEffect:SetName(sName)
	end
end

function DrawPos(pos, sName)
	local oEffect = CEffect.New("UI/_Editor/Line.prefab", nil, false, function(oEff)
			oEff.m_Eff:SetLocalScale(Vector3.New(0.1, 0.1, 0.1))
		end)
	oEffect:SetPos(pos)
	if sName then
		oEffect:SetName(sName)
	end
	return oEffect
end
