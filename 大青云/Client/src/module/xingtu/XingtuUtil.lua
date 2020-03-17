--[[
	星图
	yujia
]]

_G.XingtuUtil = {};

function XingtuUtil:IsDisabledBtn(nPage)
	local info = t_xingtu[((nPage - 1)*7 + 1) *10000 + 101]
	if info.lv > MainPlayerModel.humanDetailInfo.eaLevel then
		return true
	end
	return false
end

function XingtuUtil:getOpenLevByPage(nPage)
	return t_xingtu[((nPage - 1)*7 + 1) *10000 + 101].lv
end

function XingtuUtil:GetProById(id)
	local info = XingtuModel:GetInfoById(id)
	local cfg = t_xingtu[info.id * 10000 + info.nLev * 100 + info.nSize]
	if cfg then
		return AttrParseUtil:Parse(cfg.prop)
	else
		return {}
	end
end

function XingtuUtil:GetAllPro()
	local pro = {}
	for i = 1, 28 do
		pro = PublicUtil:GetFightListPlus(pro, self:GetProById(i))
	end
	return pro
end

function XingtuUtil:GetStrForTips(id, nLev, nSize, nType)
	local curAddPro = self:GetCurStarAddPro(id, nLev, nSize)
	local cfg = t_xingtu[id * 10000 + nLev * 100 + nSize]
	if nType == 1 then
		return string.format(StrConfig["xingtu101"],StrConfig['xingtu' ..(10+ nLev)], nSize, curAddPro[2] .. enAttrTypeName[curAddPro[1]])
	elseif nType == 2 then
		return string.format(StrConfig["xingtu102"], StrConfig['xingtu' ..(10+ nLev)], nSize, curAddPro[2] .. enAttrTypeName[curAddPro[1]], cfg.lv, cfg.success/100, cfg.consume)
	else
		return string.format(StrConfig["xingtu103"], StrConfig['xingtu' ..(10+ nLev)], nSize, curAddPro[2] .. enAttrTypeName[curAddPro[1]], cfg.lv, cfg.success/100, cfg.consume)
	end
end

--- 这里默认只取的到一条属性
function XingtuUtil:GetCurStarAddPro(id, nLev, nSize)
	local cfg = t_xingtu[id * 10000 + nLev * 100 + nSize]
	local prevCfg
	if nSize - 1 == 0 then
		if nLev - 1 == 0 then
			prevCfg = nil
		else
			prevCfg = t_xingtu[id * 10000 + (nLev - 1) * 100 + 7]
		end
	else
		prevCfg = t_xingtu[id * 10000 + nLev * 100 + nSize - 1]
	end
	local pro = AttrParseUtil:Parse(cfg.prop)
	local prevPro = prevCfg and AttrParseUtil:Parse(prevCfg.prop) or {}
	for k, v in pairs(pro) do
		local bHave = false
		for k1, v1 in pairs(prevPro) do
			if v1.type == v.type then
				bHave = true
				if v.val ~= v1.val then
					return {v.type, v.val - v1.val}
				end
			end
		end
		if not bHave then
			if v.val ~= 0 then
				return{v.type, v.val}
			end
		end
	end
end

--- 取下一星级的配置
function XingtuUtil:getNextStarCfg(id)
	local info = XingtuModel:GetInfoById(id)
	if info.nSize < 7 then
		return t_xingtu[info.id * 10000 + info.nLev * 100 + info.nSize + 1], self:GetCurStarAddPro(info.id, info.nLev, info.nSize + 1), info.nLev, info.nSize + 1
	elseif info.nLev < XingtuModel.nMaxLev then
		return t_xingtu[info.id * 10000 + (info.nLev + 1) * 100 + 1], self:GetCurStarAddPro(info.id, info.nLev + 1, 1), info.nLev + 1, 1
	else
		return nil
	end
end

--- 是否可以升
function XingtuUtil:isCanLvUp(id)
	local info = XingtuModel:GetInfoById(id)
	local cfg = self:getNextStarCfg(id)
	if not cfg then --[[这里是满级了]] return -1 end

	if cfg.lv > MainPlayerModel.humanDetailInfo.eaLevel then
		--等级不够
		return -2
	end

	if cfg.consume > MainPlayerModel.humanDetailInfo.eaBindGold then
		-- 消耗不足
		return -3
	end

	return 0
end