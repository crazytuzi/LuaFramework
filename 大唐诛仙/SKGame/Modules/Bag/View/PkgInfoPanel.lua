PkgInfoPanel = BaseClass(LuaUI)
function PkgInfoPanel:__init()
	self.ui = UIPackage.CreateObject("Pkg","PkgInfoPanel")
	self.bg = self.ui:GetChild("bg")
	self.bgRare = self.ui:GetChild("bgRare")
	self.txtName = self.ui:GetChild("txtName")
	self.txtBind = self.ui:GetChild("txtBind")
	self.txtLev = self.ui:GetChild("txtLev")
	self.txtSubType = self.ui:GetChild("txtSubType")
	self.txtPower = self.ui:GetChild("txtPower")
	self.layer = self.ui:GetChild("layer")
	self.line0 = self.ui:GetChild("line0")
	self.txtSell = self.ui:GetChild("txtSell")
	self.txtPrice = self.ui:GetChild("txtPrice")
	self.iconSell = self.ui:GetChild("iconSell")
	self.btnSell = self.ui:GetChild("btnSell")
	self.btnUse = self.ui:GetChild("btnUse")
	self.uiGroup = self.ui:GetChild("uiGroup")
	self.iconArrow = self.ui:GetChild("iconArrow")
	self.width = self.bg.width
	self:Config()
	self:Layout()
	self:InitEvent()
end

function  PkgInfoPanel:Config()
	self.model = PkgModel:GetInstance()
end

function PkgInfoPanel:InitEvent()
	
end

function PkgInfoPanel:Layout()
	self.icon = PkgCell.New( self.ui)
	self.icon:SetXY(28, 30)
	self.icon:SetNumVisible( false )
	self.icon:AddBind()
	
	self:Clear()
end

-- 更新信息
function PkgInfoPanel:Update( data, cfg )
	local type = 0
	local id = 0
	if data ~= nil then
		id = data.bid
		self.icon:SetVisible(true)
		self.uiGroup.visible = true
		type = data.goodsType
		self.layer:RemoveChildren(0, -1, true)
	else
		self:Clear()
		return
	end
	local role = SceneModel:GetInstance():GetMainPlayer()
	local lev = 0
	if role and role.level then
		lev = role.level
	end
	self.iconArrow.url = nil
	local rare = 1
	local tmp = nil
	local content = ""
	local career = 0
	if id ~= 0 then
		if cfg then
			career = cfg.needJob or 0
			rare = cfg.rare or 1
			local needLev = cfg.level or 0
			local price = cfg.sellPrice or 0
			self.bgRare.url = "Icon/Common/tipbg_r"..rare
			self.txtName.text = cfg.name
			self.txtLev.text = StringFormat("等级:{0}", cfg.level or 0)
			self.txtName.color = newColorByString( GoodsVo.RareColor[rare] )
			self.txtLev.color = newColorByString( lev >= needLev and "ded4fc" or GoodsVo.errorcolor )
			self.txtPower.text = ""
			self.txtPrice.text = price
			self.txtPrice.visible = true
			self.iconSell.url = "Icon/Goods/"..GoodsVo.GoodIcon[3]

			-- 详细信息 物品小类  10任务物品 11礼包 20红药 30蓝药 40复活 50灵石 60随机铭文（普通） 70PK药 80定向铭文（特殊）
			if cfg.tinyType == 10 then
				self.txtSubType.text = "任务物品"
			elseif cfg.tinyType == 11 then
				self.txtSubType.text = "礼包"
			elseif cfg.tinyType == 80 then
				self.txtSubType.text = "铭文"
			elseif cfg.tinyType == 50 then
				self.txtSubType.text = "灵石"
			else
				if type == GoodsVo.GoodType.equipment then
					self.txtSubType.text = GoodsVo.GoodTypeName[type]
				else
					self.txtSubType.text = GoodsVo.GoodTypeName[2]
				end
			end
		end

		-- 中间面板
		local isBind = data.isBinding==1
		self.txtBind.visible = isBind
		
		local offY = 0
		self.btnSell.title = "出售"
		if type == GoodsVo.GoodType.equipment then -- 装备
			self.btnUse.title = "装备"
			self.bgRare.url = "Icon/Common/tipbg_r"..rare
			local info = self.model:GetEquipInfoByGoodsVo(data)
			if info then
				self.txtPower.text = StringFormat("职业: {0}", PropertyConst.JobName[career])
				local isMyJob = (career == 0 or career == role.career)
				local score, equip = self.model:CompareScore(info)
				local color  = newColorByString( "e32222")
				if isMyJob then
					color = newColorByString( "ffa200")
				end
				self.txtPower.color = color
				self.iconArrow.url = nil
				
				-- 职业
				-- content = StringFormat("职业:{0}",PropertyConst.JobName[career])
				-- local isMyJob = (career == 0 or career == role.career)
				-- local color  = newColorByString( "e32222")
				-- if isMyJob then
				-- 	color = newColorByString( "ffa200")
				-- end
				-- offY = self:CreateAttrLabel(content, 0, offY, color, 22, 2, true)

				local isUpPower = nil
				local score, equip = self.model:CompareScore(info)
				if score ~= 0 then
					isUpPower = score > 0 and -1 or 1
				end
				content = StringFormat("评分:{0}", info.score or 0)
				local color  = newColorByString("ffa200")
				tmp, offY = self:CreatePropLabel(color, content, 0, offY+4, isUpPower)
				tmp, offY = self:CreateLine(0, offY, false)

				-- 获取对比的装备信息
				local useCompare = false
				local compareEquipInfo = self.model:GetOnEquipByEquipType(info.equipType)
				local compareEquipCfg = nil
				if compareEquipInfo then
					compareEquipCfg = GoodsVo.GetEquipCfg(compareEquipInfo.bid) or {}
				end
				useCompare = compareEquipInfo ~= nil
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
					if useCompare then
						local attrs = compareAttrs( cfg.baseProperty, compareEquipCfg.baseProperty )
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
								c = "{0} {1}   [color=#ebebeb](--)[/color]"
								isUp = 0
							end
							content = StringFormat(c, attr[1], mgrValue(attr[4], attr[2]), mgrValue(attr[4], attr[3]) )
							tmp, offY = self:CreatePropLabel(newColorByString( "bad4dc"), content, 0, offY+4, isUp)
						end
					else
						for i = 1, #cfg.baseProperty do
							local id = cfg.baseProperty[i][1]
							local value = cfg.baseProperty[i][2]
							local name = RoleVo.GetPropDefine(id).name
							content = StringFormat("{0} {1}", name, mgrValue(id, value))
							tmp, offY = self:CreatePropLabel(newColorByString( "bad4dc"), content, 0, offY+4)
						end
					end
				end
				tmp, offY = self:CreateLine(0, offY, false)
				local hasOtherArrts = false
				-- 附加属性
				local attrs = info.attrs
				if #attrs > 0 then
					if useCompare then
						local result = compareAttrs( attrs, compareEquipInfo.attrs )
						local isUp = 0
						for _,attr in ipairs(result) do
							local c = nil
							if attr[3] > 0 then
								c = "{0} +{1}   " --[color=#3dc476](+{2})[/color]
								isUp = 1
							elseif attr[3] < 0 then
								c = "{0} +{1}   " --[color=#e32321]({2})[/color]
								isUp = -1
							else
								c = "{0} +{1}   " --[color=#ebebeb](--)[/color]
								isUp = 0
							end
							content = StringFormat(c, attr[1], mgrValue(attr[4], attr[2]) ) -- , mgrValue(attr[4], attr[3])
							tmp, offY = self:CreatePropLabel(newColorByString( "54a3d5"), content, 0, offY)--, isUp
							hasOtherArrts = true
						end
					else
						for i = 1, #attrs do
							local id = attrs[i][1]
							local value = attrs[i][2]
							local name = RoleVo.GetPropDefine(id).name
							content = StringFormat("{0} +{1}", name, mgrValue(id, value))
							tmp, offY = self:CreatePropLabel(newColorByString( "54a3d5"), content, 0, offY)
							hasOtherArrts = true
						end
					end
				end
				if hasOtherArrts then
					tmp, offY = self:CreateLine(0, offY, false)
				end
			else
				self.txtPower.text = "评分: 0"
			end
			self.btnUse.visible = true

			if info and info.holeNum and info.holeNum ~= 0 then
				local hole = ""
				for i=1,info.holeNum do
					hole = hole..StringFormat("[img=30,30]{0}[/img]  ", UIPackage.GetItemURL("Common" , "radio"))
				end
				content = StringFormat("斗神印记：{0}", hole)
				offY = self:CreateHold(content, 0, offY+10, newColorByString("eeee22"), 22, 8, true)
			end
		else
			self.btnUse.title = "使用"
			self.txtPower.text = ""
			if cfg then
				self.btnUse.visible = cfg.useType ~= 0
				if cfg.useType == 10 then
					self.btnUse.title = "合成"
				end
			end
		end
		
		if cfg then
			content = StringFormat("{0}", cfg.des or "") -- 描述
			tmp, offY = self:CreateDesc(content, 0, offY+4, cfg.tinyType, cfg.effectValue)
		end
		self.icon:SetData(data)

	else -- 配置出现不确定的物品
		self.bgRare.url = "Icon/Common/tipbg_r"..1
		self.txtName.text = "未知"
		self.txtLev.text = StringFormat("等级:{0}", 0)
		self.txtPower.text = ""
		self.txtBind.visible = false
		self.icon:SetBind(false)
		self.iconSell.url = nil
		self.txtPrice.visible = false
		self.iconArrow.url = nil
	end
end

function PkgInfoPanel:Clear()
	self.bgRare.url = "Icon/Common/tipbg_r1"
	self.icon:SetRare(1)
	self.txtPrice.text = "0"
	self.iconSell.url = nil
	self.txtPower.text = ""
	self.txtLev.text = ""
	self.txtSubType.text = ""

	self.txtName.text = ""
	self.icon:SetBind(false)
	self.layer:RemoveChildren(0, -1, true)

	self.txtName.color = newColorByString( "ffffff" )
	self.txtLev.color = newColorByString( "ffffff" )

	self.icon:SetVisible(false)
	self.uiGroup.visible = false
end

---------------------------------------------------------------------------------------------------------
function PkgInfoPanel:CreateAttrLabel( content, x, y, color, size, offH, drawLine)
	offH = offH or 4
	local txt = createText( content, x, y, 330, nil, size, nil, nil, color, nil, nil, self.layer )
	setTxtAutoSizeType( txt, 3 )
	if drawLine then
		local line = UIPackage.CreateObject("Common" , "line02")
		self.layer:AddChild(line)
		line.x = txt.x
		line.y = y + txt.textHeight + offH
		line.width = 350
		return line.y + offH
	else
		return y + txt.textHeight + offH + 4
	end
end
function PkgInfoPanel:CreateHold( content, x, y, color, size, offH, drawLine)
	offH = offH or 4
	local txt = createRichText1(nil, self.layer, x, y, 0, 24)
	setTxtSize(txt, 22, color)
	setTxtAutoSizeType( txt, 2 )
	txt.width = 300
	setRichTextContent(txt, content)
	if drawLine then
		local line = UIPackage.CreateObject("Common" , "line02")
		self.layer:AddChild(line)
		line.x = txt.x
		line.y = y + txt.textHeight + offH
		line.width = 350
		return line.y + offH
	else
		return y + txt.textHeight + offH + 4
	end
end

-- 增加属性条
function PkgInfoPanel:CreatePropLabel(color, content, x, y, isUp)
	local txt = createRichText1(nil, self.layer, x, y, self.width, 24)
	txt.UBBEnabled = true
	setTxtSize(txt, 20, color)
	setRichTextContent(txt, content)
	local offH = y+txt.textHeight
	if isUp then
		local arrow = UIPackage.CreateObject("Common","CustomSprite0")
		arrow:SetXY(self.width - 150, y+2)
		arrow:SetSize(24, 24)
		self.layer:AddChild(arrow)
		if isUp > 0 then
			arrow.icon = "Icon/Other/arrow_01"
		elseif isUp < 0 then
			arrow.icon = "Icon/Other/arrow_11"
		end
	end
	return txt, offH
end
-- 增加分隔线
function PkgInfoPanel:CreateLine(x, y)
	local line = nil
	line = UIPackage.CreateObject("Common","line02")
	line.width = 350
	self.layer:AddChild(line)
	line:SetXY(x, y+5)
	return line, y+5
end
-- 增加描述
function PkgInfoPanel:CreateDesc(content, x, y, tinyType, effectValue)
	local txt = createRichText1(content, self.layer, x, y, 200, 24)
	setTxtSize(txt, 20, newColorByString( "ded4fc"))
	setTxtAutoSizeType( txt, 2 )
	txt.width = self.width-40
	txt:SetXY(x, y)
	txt.UBBEnabled = true
	if tinyType == GoodsVo.TinyType.gift and effectValue then -- 礼包处理
		local giftCfg = GetCfgData("gift"):Get(effectValue)
		local career = LoginModel:GetInstance():GetLoginRole().career
		if giftCfg and giftCfg.reward then
			local s = ""
			local rewardList = {}
			for i,v in ipairs(giftCfg.reward) do
				if v[1]==0 or v[1]==career then
					table.insert(rewardList, v)
				end
			end
			local list = {}
			for i,v in ipairs(rewardList) do
				local num = v[5]
				local cfg = GoodsVo.GetCfg(v[3], v[4])
				if cfg then
					local c = StringFormat("[color={0}]{1}[/color]x{2}", GoodsVo.RareColor[cfg.rare], cfg.name, num)
					table.insert(list, c)
				end
			end
			content = StringFormatII(content, list)
		end
	end
	txt.text = content
	local offH = y+txt.textHeight+8
	return txt, offH
end


function PkgInfoPanel:__delete()
	if self.icon then
		self.icon:Destroy()
	end
	self.icon = nil
end