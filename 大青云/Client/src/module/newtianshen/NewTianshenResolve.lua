--[[
	新天神
]]

_G.UINewTianshenResolve = BaseUI:new('UINewTianshenResolve');

UINewTianshenResolve.nMaxCount = 5 --最多同时分解5个天神
UINewTianshenResolve.SelectList = {true, true, true, true, true}
UINewTianshenResolve.selectIndex = 0
UINewTianshenResolve.SelectListTianshenList = {}
function UINewTianshenResolve:Create()
	self:AddSWF('newTianShenResolve.swf',true,nil);
end

function UINewTianshenResolve:OnLoaded(objSwf)
	objSwf.godList.change = function()
		
	end
	objSwf.autoBtn.click = function()
		self:AutoSelectTianshen()
	end
	objSwf.resolveBtn.click = function()
		self:AskResolveTianshen()
	end
	for i = 1, 5 do
		objSwf['quality' ..i].click = function()
			self.SelectList[i] = objSwf['quality' ..i].selected
			self:ShowTianshenList()
		end
	end
	for i = 1, 5 do
		objSwf['fight' ..i].itemBtn.click = function()
			self:SelectTianshenClick(i)
		end
	end
end

function UINewTianshenResolve:OnShow()
	self:ShowTianshenList()
	self:ShowSelectInfo()
	self:ShowSelectResolveInfo()
end

--显示选择框
function UINewTianshenResolve:ShowSelectInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	for i = 1, 5 do
		objSwf['quality' ..i].selected = self.SelectList[i]
	end
end

function UINewTianshenResolve:ShowTianshenList()
	self.tianshenList = {}
	for k, v in pairs(NewTianshenModel:GetTianshenList()) do
		if not NewTianshenModel:IsFight(v) then --没出站的天神才能分解
			local quality = v:GetQuality()
			if self.SelectList[quality + 1] then
				local vo = {}
				vo.name = string.format("<font color='%s'>%s</font>", TipsConsts:GetItemQualityColor(quality), v:GetName())
				vo.lv = v:GetLv() .. "级"
				v0.zizhi = "资质：" .. v:GetZizhi()
				vo.fight = v:GetFightValue()
				vo.headUrl = ""
				vo.id = v:GetId()
				table.insert(self.tianshenList, vo)
			end
		end
	end
	objSwf.godList.dataProvider:cleanUp()
	objSwf.godList.dataProvider:push(unpack(self.tianshenList))
	objSwf.godList:invalidateData()
	objSwf.godList.selectedIndex = 0;
end

function UINewTianshenResolve:AutoSelectTianshen()
	if self.tianshenList then
		for k, v in pairs(self.tianshenList) do
			local bHave = false
			for k1, v1 in pairs(self.SelectListTianshenList) do
				if v == v1 then
					bHave = true
				end
			end
			if not bHave then
				table.push(self.SelectListTianshenList, v)
			end
		end
		self:ShowSelectResolveInfo()
	else
		--没有天神
	end
end

function UINewTianshenResolve:ShowSelectResolveInfo()
	for i = 1, 5 do
		local objSwf = self.objSwf['fight' ..i]
		local tianshen = self.SelectListTianshenList[i]
		if tianshen then
			---设置天神显示
			objSwf.addlabel._visible = false
			objSwf.txt_title.htmlText = "天神"
			objSwf.icon.source = ""
			objSwf.txt_name.htmlText = tianshen:GetName()
		else
			objSwf.txt_title.htmlText = ""
			objSwf.icon.source = ""
			objSwf.addlabel._visible = true
			objSwf.txt_name.htmlText = ""
		end
	end
	self:ShowGetItemInfo()
end

function UINewTianshenResolve:SelectTianshenClick(i)
	if self.SelectListTianshenList[i] then
		table.remove(self.SelectListTianshenList, i)
	else
		for k, v in pairs(self.tianshenList) do
			local bHave = false
			for k1, v1 in pairs(self.SelectListTianshenList) do
				if v == v1 then
					bHave = true
				end
			end
			if not bHave then
				table.push(self.SelectListTianshenList, v)
			end
		end
	end
	self:ShowTianshenList()
	self:ShowSelectResolveInfo()
end

function UINewTianshenResolve:AskResolveTianshen()
	-- body
end