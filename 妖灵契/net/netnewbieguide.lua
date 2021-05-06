module(..., package.seeall)

--GS2C--

function GS2CNewbieGuide(pbdata)
	local newbie = pbdata.newbie
	--todo
	--g_GuidanceCtrl:GetGuideId(newbie)
end


--C2GS--

function C2GSSetNewbieGuideId(newbie)
	local t = {
		newbie = newbie,
	}
	g_NetCtrl:Send("newbieguide", "C2GSSetNewbieGuideId", t)
end

