
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local MoShenConst = require("app.const.MoShenConst")

local RebelBossRankAwardItem = class("RebelBossRankAwardItem", function()
	return CCSItemCellBase:create("ui_layout/moshen_RebelBossRankAwardItem.json")
end)

function RebelBossRankAwardItem:ctor(nMode)
	self._nMode = nMode or MoShenConst.REBEL_BOSS_RANK_MODE.HONOR

	local tAwardTmplList = {}
	for i=1, rebel_boss_rank_info.getLength() do
		local tAwardTmpl = rebel_boss_rank_info.indexOf(i)
		if tAwardTmpl and tAwardTmpl.type == self._nMode then
			table.insert(tAwardTmplList, tAwardTmpl)
		end
	end
	local function sortFunc(tAwardTmpl1, tAwardTmpl2)
		return tAwardTmpl1.rank_min < tAwardTmpl2.rank_min
	end
	table.sort(tAwardTmplList, sortFunc)
	self._tAwardTmplList = tAwardTmplList
end

function RebelBossRankAwardItem:updateItem(nIndex)
	local tAwardTmpl = self._tAwardTmplList[nIndex]

	if tAwardTmpl then
		for i=1, 3 do
			local nType = tAwardTmpl["award_type" .. i]
			local nValue = tAwardTmpl["award_value" .. i]
			local nSize = tAwardTmpl["award_size" .. i]
		    local tGoods = G_Goods.convert(nType, nValue, nSize)
			self:_initGoods(i, tGoods)
		end

		CommonFunc._updateLabel(self, "Label_Rank", {text=G_lang:get("LANG_REBEL_BOSS_RANK", {num=tAwardTmpl.rank_min})})
	end
end

function RebelBossRankAwardItem:_initGoods(nIndex, tGoods)
	local imgBg = self:getImageViewByName("Image_Award" .. nIndex)
	if not tGoods then
		imgBg:setVisible(false)
	else
		imgBg:loadTexture(G_Path.getEquipIconBack(tGoods.quality))
		-- 掉落物品的品质框
		local btnQulaity = self:getButtonByName("Button_QualityFrame" .. nIndex)
		btnQulaity:loadTextureNormal(G_Path.getEquipColorImage(tGoods.quality, tGoods.type))
		btnQulaity:setTag(nIndex)
		btnQulaity._nType = tGoods.type
		btnQulaity._nValue= tGoods.value
		-- 掉落数量 
		local labelDropNum = self:getLabelByName("Label_AwardNum" .. nIndex)
		if labelDropNum then
			labelDropNum:setText("x".. tGoods.size)
			labelDropNum:createStroke(Colors.strokeBrown,1)
		end
		-- 掉落的物品icon
		local imgIcon = self:getImageViewByName("Image_AwardIcon" .. nIndex)
		if imgIcon then
			imgIcon:loadTexture(tGoods.icon)
		end
		-- 绑定点击事件
		self:registerBtnClickEvent("Button_QualityFrame" .. nIndex, handler(self, self._onClickAward))
	end
end

function RebelBossRankAwardItem:_onClickAward(sender)
	local nType = sender._nType
	local nValue = sender._nValue
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
	require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue)
end


return RebelBossRankAwardItem