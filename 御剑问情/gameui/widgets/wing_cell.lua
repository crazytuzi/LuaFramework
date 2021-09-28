-- 羽翼格子

WingCell = WingCell or BaseClass(BaseCell)
function WingCell:__init()
	self.is_select = false --是否选中

	self.prop = self:FindObj("Prop")
	self.level = self:FindObj("Prop/Level")
	self.number = self:FindObj("Prop/Number")
	self.hight_light = self:FindObj("BG_Right")
	self.now_flag = self:FindObj("NowImg")
	self.quality = self.root_node

	self:ClearAllParts()
end

function WingCell:__delete()
end

function WingCell:FillData(data)
	self.wing_name = data.wing_name
	self.prof = data.prof
	self.is_jinghua = data.is_jinghua
	self.is_active = data.is_active
	self.is_special = data.is_special
	self.grade = data.grade
	self.big_grade = data.big_grade
	self.res_id = data.res_id
	self.img_id = data.img_id
	self.desc = data.dec
	self.item_id = data.item_id
	self.icon_id = data.icon_id
end

function WingCell:OnFlush()
	self:ClearAllParts()
	local data = self:GetData()
	if nil == data then
		return
	end

	self:FillData(data)
	self:SetSelect(self.is_select)

	-- 阶数
	if self.is_special == 1 then
		self:SetTextTopLeft("")
		self:SetQualityIcon(0)

		local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.item_id)
		if item_cfg then
			local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
			self.prop.image:LoadSprite(bundle, asset)
		end
	else
		self:SetTextTopLeft(Language.Wing.Grade[self.big_grade])
		self:SetQualityIcon(self.big_grade)

		local bundle, asset = ResPath.GetItemIcon(self.icon_id)
		self.prop.image:LoadSprite(bundle, asset)
	end

	self:SetNowFlag(self.is_jinghua)
	self:SetTextNum(self.wing_name)
end

function WingCell:SetImgIcon(icon_id)
	local assetBundle, img = ResPath.GetItemIcon(icon_id)
	self.prop.image:LoadSprite(assetBundle, img)
end

function WingCell:SetImgIconActivity(is_show)
	self.prop:SetActive(is_show)
end

function WingCell:SetTextTopLeft(text)
	self.level.text.text = text
end

--设置数量
function WingCell:SetTextNum(text)
	self.number.text.text = text
end

function WingCell:SetSelect(is_show)
	if self.hight_light == nil then
		return
	end
	self.is_select = is_show
	self.hight_light:SetActive(is_show)
end

function WingCell:SetNowFlag(is_show)
	if self.now_flag ~= nil then
		self.now_flag:SetActive(is_show)
	end
end

--TODO
--设置右下角图片数字
function WingCell:SetRightBottomImageNumText(num)
	if num <= 0 then
		return
	end
	self:SetTextNum("+"..num)
end

--TODO
-- 设置不可用遮罩
function WingCell:SetUselessModalVisible(is_visible)
end

--TODO
--设置品质特效
function WingCell:SetQualityEffect(effect_id, scale)
end

--TODO
-- 设置品质图标
function WingCell:SetQualityIcon(big_grade)
	local icon_id = WING_BIGGRADE_TO_QUALITY[big_grade]
	local assetBundle, img = ResPath.GetQualityIcon(icon_id)
	self.quality.image:LoadSprite(assetBundle, img)
end

function WingCell:ClearAllParts()
	self:SetSelect(self.is_select)
	self:SetTextNum("")
	self:SetTextTopLeft("")
	self:SetQualityEffect(0)
	self:SetQualityIcon(GameEnum.ITEM_COLOR_WHITE)
	self:SetNowFlag(false)
end
