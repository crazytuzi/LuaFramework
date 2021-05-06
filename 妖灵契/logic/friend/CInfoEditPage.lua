local CInfoEditPage = class("CInfoEditPage", CPageBase)

function CInfoEditPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CInfoEditPage.OnInitPage(self)
	self.m_IconBtn = self:NewUI(2, CButton)
	self.m_EquipBtn = self:NewUI(3, CButton)
	self.m_IconPart = self:NewUI(4, CBox)
	self.m_InfoPart = self:NewUI(5, CBox)
	self.m_EquipPart = self:NewUI(6, CBox)
	self:InitContent()
end

function CInfoEditPage.InitContent(self)
	self:InitInfoPart()
	self:InitIconPart()
	self:InitEquipPart()
	self.m_EquipBtn:SetGroup(self.m_EquipBtn:GetInstanceID())
	self.m_IconBtn:SetGroup(self.m_EquipBtn:GetInstanceID())
	self.m_EquipBtn:AddUIEvent("click", callback(self, "ShowEquipPart"))
	self.m_IconBtn:AddUIEvent("click", callback(self, "ShowIconPart"))
	self.m_IconBtn:SetSelected(true)
	self:ShowIconPart()
end

function CInfoEditPage.InitIconPart(self)
	local iconpart = self.m_IconPart
	self.m_IconTexture = iconpart:NewUI(1, CTexture)
	self.m_CustomBtn = iconpart:NewUI(2, CButton)
	--self.m_RecommandBtn = iconpart:NewUI(3, CButton)
	self.m_FrdSetBtb = iconpart:NewUI(4, CButton)
	self.m_PartnerGrid = iconpart:NewUI(5, CGrid)
	self.m_PartnerItem = iconpart:NewUI(6, CBox)
	self.m_ChangeBtn = iconpart:NewUI(7, CButton)
	self.m_RQLabel = iconpart:NewUI(8, CLabel)
	self.m_TipBtn = iconpart:NewUI(9, CButton)
	self.m_TipSpr = iconpart:NewUI(10, CSprite)
	--self.m_NoPartnerLabel = iconpart:NewUI(11, CLabel)
	self.m_RankLabel = iconpart:NewUI(12, CLabel)
	self.m_FrdSetBtb:AddUIEvent("click", callback(self, "OnSetFriend"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnShowTip"))
	self.m_ChangeBtn:AddUIEvent("click", callback(self, "OnChangePartner"))
	self.m_CustomBtn:AddUIEvent("click", callback(self, "OnImage"))
	--self.m_RecommandBtn:AddUIEvent("click", function() g_NotifyCtrl:FloatMsg("该功能暂未开放") end)

	self.m_TipSpr:SetActive(false)
	self.m_PartnerItem:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self.m_TipSpr, callback(self, "OnCloseTips"))
end

function CInfoEditPage.InitInfoPart(self)
	local infopart = self.m_InfoPart
	self.m_NameLabel = infopart:NewUI(1, CLabel)
	self.m_IDLabel = infopart:NewUI(2, CLabel)
	self.m_GradeLabel = infopart:NewUI(3, CLabel)
	self.m_SchoolLabel = infopart:NewUI(4, CLabel)
	self.m_OrgLabel = infopart:NewUI(5, CLabel)
	self.m_StarLabel = infopart:NewUI(6, CLabel)
	self.m_SaveBtn = infopart:NewUI(7, CButton)
	self.m_BirthDayBox = infopart:NewUI(8, CBox)

	self.m_TagGrid = infopart:NewUI(9, CGrid)
	self.m_TagBtn = infopart:NewUI(10, CButton)
	self.m_CancelEditBtn = infopart:NewUI(11, CButton)
	self.m_SexBox = infopart:NewUI(12, CBox)
	self.m_SignInput = infopart:NewUI(13, CInput)
	self.m_SchoolSpr = infopart:NewUI(14, CSprite)
	self.m_CloneBtn = infopart:NewUI(15, CButton)
	self.m_PositionBox = infopart:NewUI(16, CBox)
	self.m_EditMainBtn = infopart:NewUI(17, CButton)
	self.m_EditTagBtn = infopart:NewUI(18, CButton)
	self.m_NoTagLabel = infopart:NewUI(19, CLabel)
	self:InitSexBox()
	self:InitBirthBox()
	self:InitPostionBox()
	self.m_TagBtn:SetActive(false)
	self.m_EditTagBtn:AddUIEvent("click", callback(self, "OnEditTag"))
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnSaveInfo"))
	self.m_CloneBtn:AddUIEvent("click", callback(self, "OnCloneID"))
	self.m_EditMainBtn:AddUIEvent("click", callback(self, "OnEditMain"))
	self.m_CancelEditBtn:AddUIEvent("click", callback(self, "SetReadMode"))
	g_UITouchCtrl:TouchOutDetect(self.m_BirthDayBox, callback(self, "CloseBitrhPop"))
end

function CInfoEditPage.InitEquipPart(self)
	local equippart = self.m_EquipPart
	self.m_ShowEquipBtn = equippart:NewUI(1, CSprite)
	self.m_EquipGrid = equippart:NewUI(2, CGrid)
	self.m_EquipItem = equippart:NewUI(3, CBox)
	self.m_ScoreLabel = equippart:NewUI(4, CLabel)
	self.m_EquipItem:SetActive(false)
	self.m_ShowEquipBtn:AddUIEvent("click", callback(self, "OnShowEquip"))
end

function CInfoEditPage.InitSexBox(self)
	local box = self.m_SexBox
	self.m_MaleBox = box:NewUI(1, CButton)
	self.m_FemaleBox = box:NewUI(2, CButton)
	self.m_SecretBox = box:NewUI(3, CButton)
	self.m_MaleLabel = box:NewUI(4, CLabel)
	
	self.m_MaleBox:SetGroup(self.m_SexBox:GetInstanceID())
	self.m_FemaleBox:SetGroup(self.m_SexBox:GetInstanceID())
	self.m_SecretBox:SetGroup(self.m_SexBox:GetInstanceID())
end

function CInfoEditPage.InitBirthBox(self)
	local box = self.m_BirthDayBox
	box.m_Label = box:NewUI(1, CLabel)
	box.m_ClickObj = box:NewUI(2, CButton)
	box.m_YearBox = box:NewUI(3, CBirthPopupBox)
	box.m_ReadLabel = box:NewUI(6, CLabel)

	box.m_YearBox:SetCallBack(callback(self, "UpdateBirth"))
	box.m_ClickObj:AddUIEvent("click", callback(self, "SwichBirthPop"))
end

function CInfoEditPage.SwichBirthPop(self)
	local popobj = self.m_BirthDayBox.m_YearBox
	if popobj:GetActive() then
		popobj:SetActive(false)
	else
		popobj:SetActive(true)
	end
end

function CInfoEditPage.CloseBitrhPop(self)
	local popobj = self.m_BirthDayBox.m_YearBox
	popobj:SetActive(false)
end

function CInfoEditPage.UpdateBirth(self, dData)
	local timestr = string.format("%s年%s月%s日", dData["year"], dData["month"], dData["day"])
	self.m_BirthDayBox.m_Label:SetText(timestr)
	self.m_BirthDayBox.m_ReadLabel:SetText("生日："..timestr)
	
end

function CInfoEditPage.GetBirth(self)
	return self.m_BirthDayBox.m_YearBox:GetBirthDay()
end

function CInfoEditPage.SetData(self, data, parlist, equip, ph_url)
	self.m_Data = data
	self.m_NameLabel:SetText(data["name"])
	self.m_IDLabel:SetText("ID："..data["pid"])
	self.m_OrgLabel:SetText("公会："..data["orgname"])
	
	local sSign = data["signa"]
	if sSign == "" then
		sSign = "玩家很懒，未设置签名"
	end
	self.m_SignInput:SetText(sSign)
	
	self.m_SchoolSpr:SpriteSchool(data["school"])
	self.m_GradeLabel:SetText("等级："..tostring(data["grade"]))
	local path = string.format("Texture/Friend/frd_%d.png", g_AttrCtrl.model_info.shape)
	self.m_IconTexture:LoadPath(path)

	self.m_SchoolLabel:SetText("职业："..g_AttrCtrl:GetSchoolStr(data["school"]))
	
	if true or data["charm_rank"] == 0 then
		self.m_RQLabel:SetText(string.format("人气：%d", data["charm"]))
		self.m_RankLabel:SetText("不详")
	else
		self.m_RQLabel:SetText(tostring(data["charm"]))
		self.m_RankLabel:SetText(tostring(data["charm_rank"]))
	end
	self.m_RankLabel:SetActive(false)
	
	if data["sex"] == 1 then
		self.m_MaleBox:SetSelected(true)
		self.m_MaleLabel:SetText("男")
	elseif data["sex"] == 2 then
		self.m_FemaleBox:SetSelected(true)
		self.m_MaleLabel:SetText("女")
	else
		self.m_SecretBox:SetSelected(true)
		self.m_MaleLabel:SetText("保密")
	end
	self.m_PartnerList = parlist
	self.m_EquipList = equip
	self:SetPosionData(data["addr"])
	self:SetTagData(data["labal"])
	self:SetShowPartner(parlist)
	self:SetShowEquip(equip)
	self:SetReadMode()
end

function CInfoEditPage.SetBirthData(self, birthdata)
	if birthdata["year"] == 0 then
		birthdata = {year = 1990, month = 1, day = 1}
	end
	self.m_BirthDayBox.m_YearBox:SetActive(true)
	self.m_BirthDayBox.m_YearBox:ScrollTargetLevel(birthdata["year"], birthdata["month"], birthdata["day"])
	self.m_BirthDayBox.m_YearBox:SetActive(false)
	local starstr = self:GetStar(birthdata["month"], birthdata["day"])
	self.m_StarLabel:SetText("星座："..starstr.."座")
end

function CInfoEditPage.InitPostionBox(self)
	self.m_CityLabel = self.m_PositionBox:NewUI(1, CLabel)
	self.m_ProvBox = self.m_PositionBox:NewUI(2, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, nil, true)
	self.m_CityBox = self.m_PositionBox:NewUI(3, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, nil, true)
	self.m_CityBox:SetOffsetHeight(10)
	self.m_ProvBox:SetOffsetHeight(10)
	for k, name in ipairs(data.citydata.ProvData) do
		self.m_ProvBox:AddSubMenu(name)
	end
	self.m_ProvBox:SetCallback(callback(self, "OnProvinceChange"))
	self.m_ProvBox:SetSelectedIndex(1)
	self:OnProvinceChange()
end

function CInfoEditPage.OnProvinceChange(self)
	local menu = self.m_ProvBox:GetSelectedSubMenu()
	if menu then
		local priv = menu.m_Label:GetText()
		local citylist = data.citydata.CityData[priv] or {}
		self.m_CityBox:Clear()
		for k, name in ipairs(citylist) do
			self.m_CityBox:AddSubMenu(name)
		end
		self.m_CityBox:SetSelectedIndex(1)
	end
end

function CInfoEditPage.SetPosionData(self, addr)
	local list = string.split(addr, ",")
	local priv = list[1]
	local city = list[2]
	local providx = table.index(data.citydata.ProvData, priv) or 1
	local cityidx = table.index(data.citydata.CityData[priv], city) or 1
	self.m_ProvBox:SetSelectedIndex(providx)
	self:OnProvinceChange()
	self.m_CityBox:SetSelectedIndex(cityidx)
	if not priv then
		self.m_CityLabel:SetText("位置：不详")
	else
		self.m_CityLabel:SetText("位置："..priv..city)
	end
end

function CInfoEditPage.GetPostionData(self)
	local prov = self.m_ProvBox:GetMenuText()
	local city = self.m_CityBox:GetMenuText()
	return prov..","..city
end

function CInfoEditPage.OpenView(self)
	netfriend.C2GSTakeDocunment(g_AttrCtrl.pid)
end

function CInfoEditPage.OnSaveInfo(self)
	local sex = 1
	if self.m_FemaleBox:GetSelected() then
		sex = 2
	end
	if self.m_SecretBox:GetSelected() then
		sex = 3
	end
	local signa = self.m_SignInput:GetText()
	signa = g_MaskWordCtrl:ReplaceMaskWord(signa)
	local photo = nil
	local birthday = self:GetBirth()
	local privacy = 0
	local addr = self:GetPostionData()
	local updata ={
		pid = self.m_Data["pid"],
		grade = self.m_Data["grade"],
		school = self.m_Data["school"],
		orgname = self.m_Data["orgname"],
		charm = self.m_Data["charm"],
		charm_rank = self.m_Data["charm_rank"],
		name = self.m_Data["name"],
		sex = sex,
		signa = signa,
		photo = photo,
		labal = self.m_TagList,
		birthday = birthday,
		addr = addr,
	}
	netfriend.C2GSEditDocument(updata)
end

function CInfoEditPage.GetStar(self, month, day)
	local starlist = {"摩羯", "水瓶", "双鱼", "白羊", "金牛", "双子", "巨蟹",
	"狮子", "处女", "天枰", "天蝎", "射手", "摩羯"}
	local daylist = {20, 19, 21, 21, 21, 22, 23, 23, 23, 23, 22, 22}
	local idx = month
	if day<daylist[month] then
		idx = month
	else
		idx = month + 1
	end
	return starlist[idx]
end

function CInfoEditPage.SetTagData(self, taglist)
	self.m_TagList = taglist or {}
	self.m_TagGrid:Clear()
	self.m_TagGrid:SetActive(true)
	for _, name in ipairs(self.m_TagList) do
		local btn = self.m_TagBtn:Clone()
		btn:SetText(name)
		btn:SetActive(true)
		btn:AddUIEvent("click", callback(self, "OnEditTag"))
		self.m_TagGrid:AddChild(btn)
	end
	self.m_TagGrid:Reposition()
end

function CInfoEditPage.SetShowPartner(self, parlist)
	self.m_PartnerGrid:Clear()
	for _, v in ipairs(parlist) do
		local box = self.m_PartnerItem:Clone()
		box.m_Icon = box:NewUI(1, CSprite)
		box.m_RareSpr = box:NewUI(2, CSprite)
		box.m_StarGrid = box:NewUI(3, CGrid)
		box.m_StarSpr = box:NewUI(4, CSprite)
		box.m_GradeLabel = box:NewUI(5, CLabel)
		box.m_AwakeSpr = box:NewUI(6, CSprite)
		box.m_StarSpr:SetActive(false)
		local pdata = data.partnerdata.DATA[v.partner_type]
		if pdata then
			local oPartner = g_PartnerCtrl:GetPartner(v.parid)
			local icon = pdata.icon
			if oPartner then
				icon = oPartner:GetIcon()
			end
			box.m_Icon:SpriteAvatar(icon)
			g_PartnerCtrl:ChangeRareBorder(box.m_RareSpr, pdata.rare)
		end
		box.m_StarGrid:Clear()
		box.m_Icon:AddUIEvent("click", callback(self, "OnClickPartner", v.parid))
		for i = 1, 5 do
			local spr = box.m_StarSpr:Clone()
			if v.star >= i then
				spr:SetSpriteName("pic_chouka_dianliang")
			else
				spr:SetSpriteName("pic_chouka_weidianliang")
			end
			spr:SetActive(true)
			box.m_StarGrid:AddChild(spr)
		end
		box.m_AwakeSpr:SetActive(v.awake == 1)
		box.m_GradeLabel:SetText(tostring(v.grade))
		box.m_StarGrid:Reposition()
		box:SetActive(true)
		self.m_PartnerGrid:AddChild(box)
	end
	--self.m_NoPartnerLabel:SetActive(#parlist == 0)
	self.m_PartnerGrid:Reposition()
end

function CInfoEditPage.SetShowEquip(self, equipdata)
	self.m_EquipGrid:Clear()
	for i = 1, 6 do
		local oItem = g_ItemCtrl:GetEquipedByPos(i)
		if oItem then
			local box = self.m_EquipItem:Clone()
			box.m_Icon = box:NewUI(1, CSprite)
			box.m_RareSpr = box:NewUI(2, CSprite)
			box:SetActive(true)
			
			local shape = oItem:GetValue("icon") or 0
			local quality = oItem:GetValue("itemlevel")

			box.m_Icon:SpriteItemShape(shape)
			box.m_RareSpr:SetItemQuality(quality)
			box:AddUIEvent("click", callback(self, "OnGetEquipDesc", oItem))
			self.m_EquipGrid:AddChild(box)
		end
	end
	self.m_EquipGrid:Reposition()
	if self.m_Data["power_rank"] > 0 and self.m_Data["power_rank"] < 100 then
		local str = string.format("战力：%d  排名：%d", self.m_Data["power"], self.m_Data["power_rank"])
		self.m_ScoreLabel:SetText(str)
	else
		local str = string.format("战力：%d  排名：未上榜", self.m_Data["power"])
		self.m_ScoreLabel:SetText(str)
	end
	self.m_ShowEquipBtn:SetSelected(self.m_Data["show_equip"] == 0)
end

function CInfoEditPage.SetEditMode(self)
	self.m_BirthDayBox.m_Label:SetActive(true)
	self.m_BirthDayBox.m_ClickObj:SetActive(true)

	self.m_ProvBox:SetActive(true)
	self.m_CityBox:SetActive(true)

	self.m_MaleBox:SetActive(true)
	self.m_FemaleBox:SetActive(true)
	self.m_SecretBox:SetActive(true)
	self.m_MaleLabel:SetActive(false)

	self.m_SignInput:SetEnabled(true)
	if self.m_Data["signa"] =="" then
		self.m_SignInput:SetText("")
	end
	self.m_TagGrid:SetActive(true)
	self.m_TagGrid:Clear()
	self.m_NoTagLabel:SetActive(false)
	for i = 1, 4 do
		local name = self.m_TagList[i] or "+"
		local btn = self.m_TagBtn:Clone()
		btn:SetText(name)
		btn:SetActive(true)
		btn:AddUIEvent("click", callback(self, "OnEditTag"))
		self.m_TagGrid:AddChild(btn)
	end
	self.m_TagGrid:Reposition()
	self.m_EditMainBtn:SetActive(false)
	self.m_SaveBtn:SetActive(true)
	self.m_CancelEditBtn:SetActive(true)
	--for
end

function CInfoEditPage.SetReadMode(self)
	self.m_BirthDayBox.m_Label:SetActive(false)
	self.m_BirthDayBox.m_ClickObj:SetActive(false)
	self.m_BirthDayBox.m_YearBox:SetActive(false)
	self.m_BirthDayBox.m_ReadLabel:SetActive(true)
	self:SetBirthData(self.m_Data["birthday"])
	self:UpdateBirth(self.m_Data["birthday"])

	self.m_ProvBox:SetActive(false)
	self.m_CityBox:SetActive(false)
	self.m_CityLabel:SetActive(true)

	self.m_MaleBox:SetActive(false)
	self.m_FemaleBox:SetActive(false)
	self.m_SecretBox:SetActive(false)
	self.m_MaleLabel:SetActive(true)

	self.m_SignInput:SetEnabled(false)
	self.m_EditMainBtn:SetActive(true)
	self.m_SaveBtn:SetActive(false)
	self.m_CancelEditBtn:SetActive(false)
	self.m_TagGrid:SetActive(false)
	self.m_NoTagLabel:SetActive(true)
	self.m_TagList = self.m_Data["labal"]
	if #self.m_TagList == 0 then
		self.m_NoTagLabel:SetText("未设置标签")
	else
		self.m_NoTagLabel:SetText(table.concat(self.m_TagList, "、"))
	end
end

function CInfoEditPage.OnSetFriend(self)
	CFriendSetView:ShowView()
end

function CInfoEditPage.OnCloneID(self)
	C_api.Utils.SetClipBoardText(tostring(self.m_Data["pid"]))
	g_NotifyCtrl:FloatMsg("已复制到剪切板")
end

function CInfoEditPage.OnShowTip(self)
	self.m_TipSpr:SetActive(true)
end

function CInfoEditPage.OnCloseTips(self)
	self.m_TipSpr:SetActive(false)
end

function CInfoEditPage.OnEditMain(self)
	self:SetEditMode()
end

function CInfoEditPage.OnShowEquip(self)
	if self.m_ShowEquipBtn:GetSelected() then
		netfriend.C2GSSetShowEquip(0)
	else
		netfriend.C2GSSetShowEquip(1)
	end
end

function CInfoEditPage.OnGetEquipDesc(self, oItem)
	g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(oItem, {isLink = true,})
end

function CInfoEditPage.ShowEquipPart(self)
	self.m_EquipPart:SetActive(true)
	self.m_IconPart:SetActive(false)
end

function CInfoEditPage.ShowIconPart(self)
	self.m_EquipPart:SetActive(false)
	self.m_IconPart:SetActive(true)
end

function CInfoEditPage.OnChangePartner(self)
	CPartnerShowView:ShowView(function(oView)
		oView:RefreshShowPartner(self.m_PartnerList)
	end)
end

function CInfoEditPage.OnEditTag(self)
	CFrdTagView:ShowView(function(oView)
		oView:UpdateSelectTag(table.copy(self.m_TagList))
		oView:SetEditView(true)
		oView:SetCallback(callback(self, "OnFinishTag"))
	end)
end

function CInfoEditPage.OnFinishTag(self, tagList)
	self.m_TagList = tagList
	self.m_TagGrid:Clear()
	for i = 1, 4 do
		local name = self.m_TagList[i] or "+"
		local btn = self.m_TagBtn:Clone()
		btn:SetText(name)
		btn:SetActive(true)
		btn:AddUIEvent("click", callback(self, "OnEditTag"))
		self.m_TagGrid:AddChild(btn)
	end
	self.m_TagGrid:Reposition()
end

function CInfoEditPage.OnImage(self)
	C_api.PhotoReaderManager.Instance:ReadAndCropPhoto("???", 64, 64, function() printc("asdfdf") end)
end

function CInfoEditPage.OnClickPartner(self, iPartnerID)
	CPartnerLinkView:ShowView(function (oView)
		oView:SetOwnerPartner(iPartnerID)
	end)
end

return CInfoEditPage