CustomTipLayer = BaseClass(LuaUI)
-- type:TradingConst.itemType.[sysSell(交易行购买按钮)|pkgStall(上架按钮)|shelf(下架按钮)
-- data:需为 goodsVo
function CustomTipLayer:__init(data, useCompare, type, otherInfo)
	self.data = data
	self.type = type
	self.otherInfo = otherInfo -- 其他人信息
	if type == TradingConst.itemType.sysSell then
		self.useCompare = true
	elseif type == TradingConst.itemType.pkgStall then
		self.useCompare = false
	elseif type == TradingConst.itemType.shelf then
		self.useCompare = false
	else
		self.useCompare = useCompare
	end
	self:RegistUI()
	self:Layout()
end
function CustomTipLayer:RegistUI()
	local ui = UIPackage.CreateObject("Common","CustomTipLayer")
	self.ui=ui
	self.bg = ui:GetChild("bg")
	self.bgRare = ui:GetChild("bgRare")
	self.txtName = ui:GetChild("txtName")
	self.txtBind = ui:GetChild("txtBind")
	self.txtLev = ui:GetChild("txtLev")
	self.txtSubType = ui:GetChild("txtSubType")
	self.txtCareer = ui:GetChild("txtCareer")
	self.icon = PkgCell.New(ui, self.data)
	self.icon:SetXY(14, 22)
	self.height = ui.height
	self.width = ui.width
end

function CustomTipLayer:Layout()
	local height = self.height
	local width = self.width
	local offY = height
	local data = self.data
	if not data then return end
	local cfg = data:GetCfgData()
	local goodsType = data.goodsType
	local equipType = cfg.equipType
	self.icon:SetData(data)

	local pkgModel = PkgModel:GetInstance()
	local tradingModel = TradingModel:GetInstance()
	
	self.equipInfo = nil -- 当前装备信息
	self.compareEquipInfo = nil
	self.compareEquipCfg = nil

	local rare = 1
	local tmp = nil
	local color = nil
	local content = ""
	local career = 0
	local role = SceneModel:GetInstance():GetMainPlayer()
	local lev = 0
	if role and role.level then
		lev = role.level
	end
	career = cfg.needJob or 0
	rare = cfg.rare or 1
	local needLev = cfg.level or 0
	self.bgRare.url = "Icon/Common/tipbg_r"..rare
	self.txtName.text = cfg.name
	self.txtName.color = newColorByString( GoodsVo.RareColor[rare] )
	self.txtLev.text = StringFormat("等级需求:{0}", cfg.level or 0)
	self.txtLev.color = newColorByString( lev >= needLev and "ded4fc" or GoodsVo.errorcolor )
	self.txtBind.visible = data.isBinding==1
	-- 详细信息 物品小类  10任务物品 11礼包 20红药 30蓝药 40复活 50灵石 60随机铭文（普通） 70PK药 80定向铭文（特殊）
	if cfg.tinyType == 10 then
		self.txtSubType.text = "任务物品"
	elseif cfg.tinyType == 11 then
		self.txtSubType.text = "礼包"
	elseif cfg.tinyType == 80 then
		self.txtSubType.text = "铭文"
	elseif cfg.tinyType == 50 then
		self.txtSubType.text = "灵石"
	elseif goodsType == GoodsVo.GoodType.equipment then -- 装备类
		self.txtSubType.text = GoodsVo.EquipTypeName[equipType]
		content = StringFormat("所属职业:{0}",PropertyConst.JobName[career])
		local isMyJob = (career == 0 or career == role.career)
		color  = newColorByString( GoodsVo.errorcolor)
		if isMyJob then
			color = newColorByString( "ffa200")
		end
		self.txtCareer.text = content
		self.txtCareer.color = color
	else -- 其他
		self.txtSubType.text = GoodsVo.GoodTypeName[2]
	end

	if goodsType == GoodsVo.GoodType.equipment then -- 装备类
		if self.useCompare then
			self.compareEquipInfo = pkgModel:GetOnEquipByEquipType(equipType) -- 获取对比的装备信息
			if self.compareEquipInfo then
				self.compareEquipCfg = GoodsVo.GetEquipCfg(self.compareEquipInfo.bid) or {}
			end
			self.useCompare = self.compareEquipInfo ~= nil
		end
		
		local info = nil
		if self.type == TradingConst.itemType.sysSell then
			info = tradingModel:GetSysInfoByVo(data)
		elseif self.type == TradingConst.itemType.shelf then
			info = tradingModel:GetMyInfoBy(data)
		elseif self.otherInfo then
			info = self.otherInfo
		else
			info = pkgModel:GetEquipInfoByInfoId(data.equipId) -- GetEquipInfoByGoodsVo(data)
		end
		if info then
			self.equipInfo = info
			if info.state == 2 then
				local yzb = UIPackage.CreateObject("Common","font_yizhuangbei")
				yzb:SetXY(313, 0)
				self.ui:AddChild(yzb)
			end
			content = info.score
			tmp, offY = self:CreatePower(content, 8, self.height, self.useCompare)
			tmp, offY = self:CreateLine(8, offY, false)
			local precentId = {21, 22, 23}
			local function mgrValue( id, value )
				for i,v in ipairs(precentId) do
					if v == id then
						return string.format("%.1f", value*0.01).."%"
					end
				end
				return value
			end
			-- 基本属性
			if #cfg.baseProperty > 0 then
				if self.useCompare then
					local attrs = compareAttrs( cfg.baseProperty, self.compareEquipCfg.baseProperty )
					local isUp = 0
					for _,attr in ipairs(attrs) do
						local c = nil
						if attr[3] > 0 then
							c = "{0} {1}   [color=#3dc476](+{2})[/color]"
							isUp = 1
						elseif attr[3] < 0 then
							c = "{0} {1}   [color=#e32321]({2})[/color]"
							isUp = -1
						else
							c = "{0} {1}"
							isUp = 0
						end
						content = StringFormat(c, attr[1], mgrValue(attr[4], attr[2]), mgrValue(attr[4], attr[3]) )
						tmp, offY = self:CreatePropLabel(newColorByString( "bad4dc"), content, 8, offY, isUp)
					end
				else
					for i = 1, #cfg.baseProperty do
						local id = cfg.baseProperty[i][1]
						local value = cfg.baseProperty[i][2]
						local name = RoleVo.GetPropDefine(id).name
						content = StringFormat("{0} {1}", name, mgrValue(id, value) )
						tmp, offY = self:CreatePropLabel(newColorByString( "bad4dc"), content, 8, offY)
					end
				end
			end
			tmp, offY = self:CreateLine(8, offY, false)
			local hasOtherArrts = false

			-- 附加属性
			local attrs = info.attrs
			if #attrs > 0 then
				if self.useCompare then
					local result = compareAttrs( attrs, self.compareEquipInfo.attrs )
					local isUp = 0
					for _,attr in ipairs(result) do
						local c = nil
						if attr[3] > 0 then
							c = "{0} +{1}   "--[color=#3dc476](+{2})[/color]
							isUp = 1
						elseif attr[3] < 0 then
							c = "{0} +{1}   "--[color=#e32321]({2})[/color]
							isUp = -1
						else
							c = "{0} +{1}   "
							isUp = 0
						end
						content = StringFormat(c, attr[1], mgrValue(attr[4], attr[2]), mgrValue(attr[4], attr[3]) )
						tmp, offY = self:CreatePropLabel(newColorByString( "54a3d5"), content, 8, offY)--, isUp
						hasOtherArrts = true
					end
				else
					for i = 1, #attrs do
						local id =attrs[i][1]
						local value = attrs[i][2]
						local name = RoleVo.GetPropDefine(id).name
						content = StringFormat("{0} +{1}", name, mgrValue(id, value) )
						tmp, offY = self:CreatePropLabel(newColorByString( "54a3d5"), content, 8, offY)
						hasOtherArrts = true
					end
				end
			end
			if hasOtherArrts then
				tmp, offY = self:CreateLine(8, offY, false)
			end
			if info and info.holeNum and info.holeNum ~= 0 then
				local hole = ""
				for i=1,info.holeNum do
					hole = hole..StringFormat("[img=30,30]{0}[/img]  ", UIPackage.GetItemURL("Common" , "radio"))
				end
				content = StringFormat("斗神印记：{0}", hole)
				tmp, offY = self:CreatePropLabel(newColorByString("eeee22"), content, 8, offY+4, nil)
				tmp, offY = self:CreateLine(8, offY, false)
			end
		end
	else
		self.useCompare = false
	end

	content = StringFormat("{0}", cfg.des or "") -- 描述
	tmp, offY = self:CreateDesc(content, 8, offY+4, cfg.tinyType, cfg.effectValue)
	
	if self.type == TradingConst.itemType.sysSell then -- 交易行购买按钮
		tmp, offY = self:CreateLine(8, offY, true)
		tmp, offY = self:CreateBtn("购买", offY)
		tmp.onClick:Add(function ()
			self:Close()
			GlobalDispatcher:Fire(TradingConst.STALL_BUY) 
		end)
	elseif self.type == TradingConst.itemType.shelf then -- 下架按钮
		local tmp1 = nil
		local offY1 = nil
		if data and data.expired then
			--过期后重新上架
			tmp1, offY1 = self:CreateBtn("重新上架", offY, 50)
			tmp, offY = self:CreateBtn("下架", offY, 205)
		else
			tmp, offY = self:CreateLine(8, offY, true)
			tmp, offY = self:CreateBtn("下架", offY)
		end
		tmp.onClick:Add(function ()
			self:Close()
			GlobalDispatcher:Fire(TradingConst.STALL_PUTOFF)
		end)
		if tmp1 then
			tmp1.onClick:Add(function ()
				self:Close()
				GlobalDispatcher:Fire(TradingConst.STALL_RE_PUTON)
			end)
		end
	elseif self.type == TradingConst.itemType.pkgStall then -- 上架按钮
		tmp, offY = self:CreateLine(8, offY, true)
		tmp, offY = self:CreateBtn("上架", offY)
		tmp.onClick:Add(function ()
			self:Close()
			GlobalDispatcher:Fire(TradingConst.STALL_PUTON)
		end)
	end

	if self.useCompare then
		local comp = pkgModel:CreateOnEquipByEquipType(self.compareEquipInfo)
		self.compare = CustomTipLayer.New(comp)
		self.compare:AddTo(self.ui)
		self.compare:SetXY(self.ui.width+10, 0)
		self.ui.width = self.ui.width*2+14
	end
end

-- 增加评分显示
function CustomTipLayer:CreatePower(content, x, y, isCompare)
	local txt = createText0(StringFormat("i{0}", content), self.ui, x, y-2, self.width, 26, "Common", "num_3")
	setTxtSize(txt, 22)
	local offH = y+txt.textHeight-4
	if isCompare then
		local info = self.compareEquipInfo
		local cur = self.equipInfo
		if info and cur then
			local arrow = UIPackage.CreateObject("Common","CustomSprite0")
			arrow:SetXY(self.width - 150, y+6)
			arrow:SetSize(24, 24)
			self.ui:AddChild(arrow)
			if info.score > cur.score then
				arrow.icon = "Icon/Other/arrow_11"
			elseif info.score < cur.score then
				arrow.icon = "Icon/Other/arrow_01"
			end
		end
	end
	self.ui.height = offH
	return txt, offH
end
-- 增加属性条
function CustomTipLayer:CreatePropLabel(color, content, x, y, isUp)
	local txt = createRichText1(nil, self.ui, x, y, self.width, 24)
	txt.UBBEnabled = true
	setTxtSize(txt, 20, color)
	setRichTextContent(txt, content)
	local offH = y+txt.textHeight
	if isUp then
		local arrow = UIPackage.CreateObject("Common","CustomSprite0")
		arrow:SetXY(self.width - 150, y+2)
		arrow:SetSize(24, 24)
		self.ui:AddChild(arrow)
		if isUp > 0 then
			arrow.icon = "Icon/Other/arrow_01"
		elseif isUp < 0 then
			arrow.icon = "Icon/Other/arrow_11"
		end
	end
	self.ui.height = offH
	return txt, offH
end
-- 增加描述
function CustomTipLayer:CreateDesc(content, x, y, tinyType, effectValue)
	local txt = createRichText1(nil, self.ui, x, y, self.width, 24)
	setTxtSize(txt, 20, newColorByString( "ded4fc"))
	setTxtAutoSizeType( txt, 2 )
	txt.width = self.width-30
	txt.UBBEnabled = true
	content = getGiftDesc(content, tinyType, effectValue)
	setRichTextContent(txt, content)
	local offH = y+txt.textHeight+8
	self.ui.height = offH
	return txt, offH
end
-- 增加分隔线
function CustomTipLayer:CreateLine(x, y, isEnd)
	local line = nil
	if isEnd then
		line = UIPackage.CreateObject("Common","line0001")
		self.ui.height = y+14
		line.width = 360
	else
		line = UIPackage.CreateObject("Common","line01")
		self.ui.height = y+7
		line.width = 330
	end
	self.ui:AddChild(line)
	line:SetXY(x, y+5)
	return line, self.ui.height
end
-- 增加按钮
function CustomTipLayer:CreateBtn(label, y, x)
	local btn = UIPackage.CreateObject("Common","CustomButton3")
	btn.title = label
	btn.icon = UIPackage.GetItemURL("Common","btn_001")
	self.ui:AddChild(btn)
	if not x then
		btn:SetXY((self.width-124)*0.5, y+8)
	else
		btn:SetXY(x, y + 8)
	end
	btn:SetSize(124, 58)
	local offH = y+78
	self.ui.height = offH
	return btn, offH
end

function CustomTipLayer:Close()
	GRoot.inst:HidePopup(self.ui)
end
-- data goodsVo 数据 useCompare 启用(装备)对比 type 类型 nil 普通提示， TradingConst.itemType 功能提示
function CustomTipLayer.Show(data, useCompare, type, otherInfo, isUp)
	if not data then return end
	local tip = CustomTipLayer.New(data, useCompare, type, otherInfo)
	if tip.useCompare then
		UIMgr.ShowCenterPopup(tip, nil, true)
	else
		UIMgr.ShowPopup(tip, isUp)
	end
	return tip
end
function CustomTipLayer:__delete()
	self.icon:Destroy()
	self.icon=nil
	if self.compare then
		self.compare:Destroy()
	end
	self.compare = nil
end