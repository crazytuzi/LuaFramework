-- 精灵格子
SpiritCell = SpiritCell or BaseClass(BaseRender)
function SpiritCell:__init()
	self.prefab_path = "uis/widgets"
	self.prefab_name = "XingZuo"

	self.prop = nil
	self.level = nil
	self.number = nil
	self.now_flag = nil
	self.hight_light = nil
	self.is_select = false --是否选中
end

function SpiritCell:__delete()
	self.prop = nil
	self.level = nil
	self.number = nil
	self.now_flag = nil
	self.hight_light = nil
	self.is_select = false --是否选中

	self:ClearData()
end

function SpiritCell:LoadCallBack()
	self.prop = self:Find("Prop")
	self.level = self:Find("Prop/Level")
	self.number = self:Find("Prop/Number")
	self.hight_light = self:Find("BG_Right")
	self.now_flag = self:Find("NowImg")
	self.quality = self.root

	self:ClearAllParts()
end

function SpiritCell:FillData(data)
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

function SpiritCell:ClearData()
	self.wing_name = nil
	self.prof = nil
	self.is_jinghua = nil
	self.is_active = nil
	self.is_special = nil
	self.grade = nil
	self.big_grade = nil
	self.res_id = nil
	self.img_id = nil
	self.desc = nil
	self.item_id = nil
	self.icon_id = nil
end

function SpiritCell:OnFlush()
	if not self:IsUiCreated() then
		return
	end
	self:ClearAllParts()
	local data = self:GetData()
	if nil == data then
		return
	end

	-- self:FillData(data)
	-- self:SetSelect(self.is_select)

	-- -- 阶数
	-- if self.is_special == 1 then
	-- 	self:SetTextTopLeft("")
	-- 	self:SetQualityIcon(0)

	-- 	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.item_id)
	-- 	if item_cfg then
	-- 		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
	-- 		UII.SetAssetBundleImage(self.prop, bundle, asset)
	-- 	end
	-- else
	-- 	self:SetTextTopLeft(Language.Wing.Grade[self.big_grade])
	-- 	self:SetQualityIcon(self.big_grade)

	-- 	local bundle, asset = ResPath.GetItemIcon(self.icon_id)
	-- 	UII.SetAssetBundleImage(self.prop, bundle, asset)
	-- end

	-- self:SetNowFlag(self.is_jinghua)
	self:SetTextNum(self.wing_name)
end

function SpiritCell:SetImgIcon(icon_id)
	local assetBundle, img = ResPath.GetXingXiangIcon(icon_id)
	UII.SetAssetBundleImage(self.prop, assetBundle, img)
end

function SpiritCell:SetImgIconActivity(is_show)
	UII.SetActive(self.prop, is_show)
end

function SpiritCell:SetTextTopLeft(text)
	UII.SetTextStr(self.level, text)
end

--设置数量
function SpiritCell:SetTextNum(text)
	UII.SetTextStr(self.number, text)
end

function SpiritCell:SetSelect(is_show)
	if self.hight_light == nil then
		return
	end
	self.is_select = is_show
	UII.SetActive(self.hight_light, is_show)
end

function SpiritCell:SetNowFlag(is_show)
	if self.now_flag ~= nil then
		UII.SetActive(self.now_flag, is_show)
	end
end

--TODO
--设置右下角图片数字
function SpiritCell:SetRightBottomImageNumText(num)
	if num <= 0 then
		return
	end
	self:SetTextNum("+"..num)
end

--TODO
-- 设置不可用遮罩
function SpiritCell:SetUselessModalVisible(is_visible)
end

--TODO
--设置品质特效
function SpiritCell:SetQualityEffect(effect_id, scale)
end

--TODO
-- 设置品质图标
function SpiritCell:SetQualityIcon(big_grade)

	local icon_id = WING_BIGGRADE_TO_QUALITY[big_grade]
	local assetBundle, img = ResPath.GetQualityIcon(icon_id)
	UII.SetAssetBundleImage(self.quality, assetBundle, img)
end

function SpiritCell:ClearAllParts()
	self:SetSelect(self.is_select)
	self:SetTextNum("")
	self:SetTextTopLeft("")
	self:SetQualityEffect(0)
	self:SetQualityIcon(GameEnum.ITEM_COLOR_WHITE)
	self:SetNowFlag(false)
end
