--[[
	func:   V属性加成
	author: houxudong
	date:   2016年11月24日 21:23:36
]]

_G.UIVplanPowerNew = BaseUI:new('UIVplanPowerNew')

function UIVplanPowerNew:Create()
	self:AddSWF("vplanPowerPanelNew.swf",true,nil)
end

function UIVplanPowerNew:OnLoaded(objSwf)

end

function UIVplanPowerNew:OnShow( )
	self:InitMonthData()
	self:InitYearData()
end

-- Vplan月数据
function UIVplanPowerNew:InitMonthData( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local myVLvl = VplanModel:GetVPlanLevel()
	local data = {t_vtype[3],t_vtype[4],t_vtype[5]}
	for i=1,3 do
		local list = AttrParseUtil:Parse(data[i].attr)
		local vo = {}
		local str = ""
		for aa,bb in pairs(list) do 
			local name = enAttrTypeName[bb.type]   --属性名称
			if not vo.str then
				vo.str = ''
			end
			vo.str = vo.str ..' '..name .."+" .. bb.val   
			str = vo.str       
		end
		objSwf["mon_fight_"..i].htmlText = str
		local state = false
		if myVLvl == data[i].level then 
			if VplanModel:GetMonVplan() then 
				state = true
			else
				state = false
			end
		else
			state = false                          --月会员的激活状态
		end
		objSwf["mon_state_"..i]._visible = state
	end
end

-- Vplan年数据
function UIVplanPowerNew:InitYearData( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local myVLvl = VplanModel:GetVPlanLevel()
	local info = t_vtype[2]
	local list = AttrParseUtil:Parse(info.attr)
	local str = ""
	local vo = {}
	for aa,bb in pairs(list) do 
		local name = enAttrTypeName[bb.type]
		if not vo.str then
			vo.str = ''
		end
		vo.str = vo.str ..' '..name .."+" .. bb.val
		str = vo.str
	end
	objSwf.year_fight.htmlText = str
	local state = false
	if myVLvl == info.level then 
		if VplanModel:GetYearVplan() then 
			state = true
		else
			state = false
		end
	else
		state = false                          --年会员的激活状态
	end
	objSwf.year_state._visible = state
end

