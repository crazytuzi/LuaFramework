--[[
VIP 特权列表面板
2015-7-24 16:57:45
haohu
]]
--------------------------------------------------------------

_G.UIVipPrerogative = BaseUI:new("UIVipPrerogative")
UIVipPrerogative.defaultY = 23
UIVipPrerogative.lineHight = 21
function UIVipPrerogative:Create()
	self:AddSWF("vipPrerogativePanel.swf", true, nil)
end

function UIVipPrerogative:OnLoaded( objSwf )
	objSwf.mcList.hitTestDisable = true;
	objSwf.scrollBar.scroll = function () 
		local objSwf = self.objSwf;
		local value = objSwf.scrollBar.position*UIVipPrerogative.lineHight;
		objSwf.mcList._y = UIVipPrerogative.defaultY - value
		
	end;
end

function UIVipPrerogative:OnShow()	
	local objSwf = self.objSwf
	if not objSwf then return end	
	
	objSwf.listPlayer.dataProvider:cleanUp()
	
	local sortArray = {}
	for i,n in pairs(t_vippower) do
		if n.opened ~= 1 then
			local sortVO = {}
			sortVO.id = i
			sortVO.sort = n.sort
			sortArray[#sortArray + 1] = sortVO
		end
	end
	table.sort(sortArray,function(A,B)
					if A.sort < B.sort then
						return true					
					else
						return false
					end		
				end)
	local num1 = 0
	local num2 = 0
	local num3 = 0
	
	for i,n in pairs (sortArray) do		
		local memberVO = {}
		local v = t_vippower[n.id]
		memberVO.txtName = v.desc
		if v.value_type1 == 1 then
			for i = 0, 10 do
				memberVO['txtRight'..i + 1] = v['c_v'..i]/100 .. '%'	
				memberVO['mcRight'..i + 1] = 3					
			end
		elseif v.value_type1 == 2 then
			for i = 0, 10 do
				memberVO['txtRight'..i + 1] = ''									
				if v['c_v'..i] == 1 then
					memberVO['mcRight'..i + 1] = 1
				else
					memberVO['mcRight'..i + 1] = 2
				end
			end
		else
			for i = 0, 10 do
				memberVO['txtRight'..i + 1] = v['c_v'..i]		
				memberVO['mcRight'..i + 1] = 3					
			end
		end
		objSwf.listPlayer.dataProvider:push( UIData.encode(memberVO) )		
		
		if v.type == 1 then
			num1 = num1 + 1
			num2 = num2 + 1
			num3 = num3 + 1
		elseif v.type == 2 then
			num2 = num2 + 1
			num3 = num3 + 1
		elseif v.type == 3 then
			num3 = num3 + 1	
		end
	end
	objSwf.mcList.vipPreroImg1._y = 0
	objSwf.mcList.vipPreroImg2._y = num1*UIVipPrerogative.lineHight
	objSwf.mcList.vipPreroImg3._y = num2*UIVipPrerogative.lineHight
	
	objSwf.mcList.vip1._y = 2
	objSwf.mcList.vip2._y = num1*UIVipPrerogative.lineHight+2
	objSwf.mcList.vip3._y = num2*UIVipPrerogative.lineHight
	
	-- objSwf.mcList.effect_1._y = 0
	-- objSwf.mcList.effect_2._y = num1*UIVipPrerogative.lineHight
	-- objSwf.mcList.effect_3._y = num2*UIVipPrerogative.lineHight
	
	objSwf.mcList.vipPreroTxt1._y = num1*UIVipPrerogative.lineHight/2
	objSwf.mcList.vipPreroTxt2._y = num1*UIVipPrerogative.lineHight + (num2 - num1)*UIVipPrerogative.lineHight/2
	objSwf.mcList.vipPreroTxt3._y = num2*UIVipPrerogative.lineHight + (num3 - num2)*UIVipPrerogative.lineHight/2
	
	
	objSwf.listPlayer:invalidateData()
end

