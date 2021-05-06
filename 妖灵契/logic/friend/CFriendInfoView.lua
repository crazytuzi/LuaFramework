local CFriendInfoView = class("CFriendInfoView", CViewBase)

function CFriendInfoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/friend/FrdInfoView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CFriendInfoView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_IconBtn = self:NewUI(2, CButton)
	self.m_EquipBtn = self:NewUI(3, CButton)
	self.m_IconPart = self:NewUI(4, CBox)
	self.m_InfoPart = self:NewUI(5, CBox)
	self.m_EquipPart = self:NewUI(6, CBox)
	self.m_GreySpr = self:NewUI(7, CSprite)
	self:InitContent()
end

function CFriendInfoView.InitContent(self)
	self:InitInfoPart()
	self:InitIconPart()
	self:InitEquipPart()
	self:ShowIconPart()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CloneBtn:AddUIEvent("click", callback(self, "OnCloneID"))
	self.m_LikeBtn:AddUIEvent("click", callback(self, "OnLike"))
	self.m_EquipBtn:AddUIEvent("click", callback(self, "ShowEquipPart"))
	self.m_IconBtn:AddUIEvent("click", callback(self, "ShowIconPart"))
	self.m_GreySpr:AddUIEvent("click", function() g_NotifyCtrl:FloatMsg("查看失败，该玩家的装备无法查看") end)
	self.m_EquipBtn:SetGroup(self.m_EquipBtn:GetInstanceID())
	self.m_IconBtn:SetGroup(self.m_EquipBtn:GetInstanceID())
	self.m_IconBtn:SetSelected(true)
end

function CFriendInfoView.InitIconPart(self)
	local iconpart = self.m_IconPart
	self.m_IconTexture = iconpart:NewUI(1, CTexture)
	self.m_PartnerGrid = iconpart:NewUI(5, CGrid)
	self.m_PartnerItem = iconpart:NewUI(6, CBox)
	self.m_LikeBtn = iconpart:NewUI(7, CButton)
	self.m_RankLabel = iconpart:NewUI(8, CLabel)
	self.m_PartnerItem:SetActive(false)
end

function CFriendInfoView.InitInfoPart(self)
	local infopart = self.m_InfoPart
	self.m_NameLabel = infopart:NewUI(1, CLabel)
	self.m_IDLabel = infopart:NewUI(2, CLabel)
	self.m_GradeLabel = infopart:NewUI(3, CLabel)
	self.m_SchoolLabel = infopart:NewUI(4, CLabel)
	self.m_OrgLabel = infopart:NewUI(5, CLabel)
	self.m_StarLabel = infopart:NewUI(6, CLabel)

	self.m_BirthLabel = infopart:NewUI(8, CLabel)
	self.m_TagGrid = infopart:NewUI(9, CGrid)
	self.m_TagBtn = infopart:NewUI(10, CButton)
	self.m_PositionLabel = infopart:NewUI(11, CLabel)
	self.m_SexLabel = infopart:NewUI(12, CLabel)
	self.m_SignLabel = infopart:NewUI(13, CLabel)
	self.m_SchoolSpr = infopart:NewUI(14, CSprite)
	self.m_CloneBtn = infopart:NewUI(15, CButton)
	self.m_NoTagLabel = infopart:NewUI(16, CLabel)
	self.m_TagBtn:SetActive(false)
end

function CFriendInfoView.InitEquipPart(self)
	local equippart = self.m_EquipPart
	self.m_EquipGrid = equippart:NewUI(2, CGrid)
	self.m_EquipItem = equippart:NewUI(3, CBox)
	self.m_ScoreLabel = equippart:NewUI(4, CLabel)
	self.m_EquipItem:SetActive(false)
end

function CFriendInfoView.SetData(self, data, parlist, equip, ph_url, is_charm)
	self.m_Data = data
	self:SetBirthData(data["birthday"])
	self.m_NameLabel:SetText(data["name"])
	self.m_IDLabel:SetText("ID："..data["pid"])
	self.m_OrgLabel:SetText("公会："..data["orgname"])
	self.m_GradeLabel:SetText("等级："..tostring(data["grade"]))
	
	local sSign = data["signa"]
	if sSign == "" then
		sSign = "玩家很懒，未设置签名"
	end
	self.m_SignLabel:SetText(sSign)
	self.m_SchoolSpr:SpriteSchool(data["school"])
	self.m_SchoolLabel:SetText("职业："..g_AttrCtrl:GetSchoolStr(data["school"]))
	local path = string.format("Texture/Friend/frd_%d.png", data["shape"])
	self.m_IconTexture:LoadPath(path)
	self.m_LikeBtn:SetEnabled(is_charm == 0)

	if data["charm_rank"] == 0 then
		self.m_RankLabel:SetText(string.format("人气：%d", data["charm"]))
	else
		self.m_RankLabel:SetText(string.format("人气：%d   排名：%d", data["charm"], data["charm_rank"]))
	end
	
	if data["sex"] == 1 then
		self.m_SexLabel:SetText("性别：男")
	elseif data["sex"] == 2 then
		self.m_SexLabel:SetText("性别：女")
	else
		self.m_SexLabel:SetText("性别：保密")
	end
	self.m_GreySpr:SetActive(data["show_equip"] == 0)
	if data["addr"] == "" then
		self.m_PositionLabel:SetText("位置：不详")
	else
		self.m_PositionLabel:SetText("位置："..data["addr"])
	end
	self:SetTagData(data["labal"])
	self:SetShowPartner(parlist)
	self:SetShowEquip(equip)
end

function CFriendInfoView.SetBirthData(self, birthdata)
	local str = ""
	if birthdata["year"] == 0 then
		str = "生日：不详"
		self.m_BirthLabel:SetText(str)
		self.m_StarLabel:SetText("星座：不详")
	else
		str = string.format("生日：%d年%d月%d日", birthdata["year"], birthdata["month"], birthdata["day"])
		local starstr = self:GetStar(birthdata["month"], birthdata["day"])
		self.m_BirthLabel:SetText(str)
		self.m_StarLabel:SetText("星座："..starstr.."座")
	end
end

function CFriendInfoView.GetStar(self, month, day)
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

function CFriendInfoView.SetTagData(self, taglist)
	self.m_TagList = taglist or {}
	self.m_NoTagLabel:SetActive(true)
	if #self.m_TagList == 0 then
		self.m_NoTagLabel:SetText("玩家很懒，未设置标签")
	else
		self.m_NoTagLabel:SetText(table.concat(self.m_TagList, "、"))
	end
end

function CFriendInfoView.SetShowPartner(self, parlist)
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
			box.m_Icon:SpriteAvatar(pdata.icon)
			g_PartnerCtrl:ChangeRareBorder(box.m_RareSpr, pdata.rare)
		end
		box.m_StarGrid:Clear()
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
		box.m_StarGrid:Reposition()
		box.m_GradeLabel:SetText(tostring(v.grade))
		box:SetActive(true)
		box.m_Icon:AddUIEvent("click", callback(self, "OnClickPartner", v.parid, self.m_Data["pid"]))
		box.m_AwakeSpr:SetActive(v.awake == 1)
		self.m_PartnerGrid:AddChild(box)
	end
	self.m_PartnerGrid:Reposition()
end

function CFriendInfoView.SetShowEquip(self, equipdata)
	self.m_EquipGrid:Clear()
	for _, v in ipairs(equipdata) do
		local box = self.m_EquipItem:Clone()
		box.m_Icon = box:NewUI(1, CSprite)
		box.m_RareSpr = box:NewUI(2, CSprite)
		box:SetActive(true)
		local idata = DataTools.GetItemData(v.item)
		box.m_Icon:SpriteItemShape(idata.icon)
		box.m_RareSpr:SetItemQuality(v.quality)
		box:AddUIEvent("click", callback(self, "OnGetEquipDesc", v.pos))
		self.m_EquipGrid:AddChild(box)
	end
	self.m_EquipGrid:Reposition()
	if self.m_Data["power_rank"] > 0 and self.m_Data["power_rank"] < 100 then
		local str = string.format("战力：%d   排名：%d", self.m_Data["power"], self.m_Data["power_rank"])
		self.m_ScoreLabel:SetText(str)
	else
		local str = string.format("战力：%d   排名：未上榜", self.m_Data["power"])
		self.m_ScoreLabel:SetText(str)
	end
end

function CFriendInfoView.OnCloneID(self)
	C_api.Utils.SetClipBoardText(tostring(self.m_Data["pid"]))
	g_NotifyCtrl:FloatMsg("已复制到剪切板")
end

function CFriendInfoView.OnLike(self)
	self.m_LikeBtn:SetEnabled(false)
	self.m_RankLabel:SetText(string.format("人气：%d", self.m_Data["charm"]+1))
	netplayer.C2GSUpvotePlayer(self.m_Data["pid"])
end

function CFriendInfoView.OnGetEquipDesc(self, pos)
	netfriend.C2GSGetEquipDesc(self.m_Data["pid"], pos)
end

function CFriendInfoView.ShowEquipPart(self)
	self.m_EquipPart:SetActive(true)
	self.m_IconPart:SetActive(false)
end

function CFriendInfoView.ShowIconPart(self)
	self.m_EquipPart:SetActive(false)
	self.m_IconPart:SetActive(true)
end

function CFriendInfoView.OnClickPartner(self, iPartnerID, iPid)
	netfriend.C2GSGetShowPartnerInfo(iPartnerID, iPid)
end

return CFriendInfoView