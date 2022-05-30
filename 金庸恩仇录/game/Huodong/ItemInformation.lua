local data_refine_refine = require("data.data_refine_refine")
local data_item_item = require("data.data_item_item")
local ZORDER = 101

local ItemInformation = class("ItemInformation", function()
	return display.newNode()
end)

function ItemInformation:ctor(param)
	local endFunc = param.endFunc
	local id = param.id
	
	--道具详情
	if param.type == ITEM_TYPE.daoju or param.type == ITEM_TYPE.lipin or param.type == ITEM_TYPE.cailiao or param.type == ITEM_TYPE.zhenshen then
		local itemData = data_item_item[id]
		if itemData.effecttype == 9 or itemData.effecttype == 10 then
			local selectBox = require("game.Bag.BagSelectBox").new({
			effecttype = itemData.effecttype,
			isShow = true,
			baseInfo = itemData,
			confirmFunc = function(name)
				if endFunc then
					endFunc()
				end
				self:removeSelf()
			end
			})
			self:addChild(selectBox, ZORDER)
			return
		end
		--普通道具
		local shadeLayer = require("utility.ShadeLayer").new(cc.c4b(0, 0, 0, 0))
		self:addChild(shadeLayer)
		local proxy = CCBProxy:create()
		local subnode = {}
		local node = CCBuilderReaderLoad("reward/item_information.ccbi", proxy, subnode)
		node:setPosition(display.cx, display.cy)
		self:addChild(node)
		--关闭
		subnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
			sender:runAction(transition.sequence({
			CCCallFunc:create(function()
				if endFunc ~= nil then
					endFunc()
				end
				self:removeSelf()
			end)
			}))
		end,
		CCControlEventTouchUpInside)
		local nameColor = ResMgr.getItemNameColor(id)
		nameColor = nameColor or cc.c3b(99, 47, 8)
		local curName = param.name or data_item_item[id].name
		local nameLbl = ui.newTTFLabelWithShadow({
		text = curName,
		size = 22,
		color = nameColor,
		shadowColor = display.COLOR_BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		})
		ResMgr.replaceKeyLableEx(nameLbl, subnode, "itemNameLbl", 0, 0)
		nameLbl:align(display.LEFT_CENTER)
		local curDesc = param.describe or data_item_item[id].describe
		subnode.itemDesLbl:setString(curDesc)
		local itemIcon = subnode.itemIcon
		ResMgr.refreshIcon({
		id = id,
		resType = ResMgr.ITEM,
		itemBg = itemIcon
		})
	elseif param.type == ITEM_TYPE.wuxue or param.type == ITEM_TYPE.neigong_suipian or param.type == ITEM_TYPE.waigong_suipian then
		local resId = id
		if param.type == ITEM_TYPE.neigongsuipian or param.type == ITEM_TYPE.waigong_suipian then
			resId = data_item_item[id].para3
		end
		self:addChild(require("game.Duobao.DuobaoItemInfoLayer").new({
		id = resId,
		confirmListen = function()
			if endFunc ~= nil then
				endFunc()
			end
			self:removeSelf()
		end
		}), ZORDER)
	elseif param.type == ITEM_TYPE.zhuangbei or param.type == ITEM_TYPE.zhuangbei_suipian then
		local resId = id
		local mCurNum, mLimitNum
		if param.type == ITEM_TYPE.zhuangbei_suipian then
			if data_item_item[id].para2 == ITEM_TYPE.shizhuang then
				resId = data_item_item[id].para3 + game.player.getGender()
				mCurNum = param.curNum
				mLimitNum = param.limitNum
				local fashionData = FashionModel.getInitData(resId)
				--dump(fashionData)
				local layer = require("game.shizhuang.FashionInfoLayer").new({
				info = fashionData,
				curNum = mCurNum,
				limitNum = mLimitNum,
				removeListener = function()
					if endFunc ~= nil then
						endFunc()
					end
					self:removeSelf()
				end
				}, 3)
				self:addChild(layer, ZORDER)
				return
			else
				resId = data_item_item[id].para3
				mCurNum = param.curNum
				mLimitNum = param.limitNum
			end
		end
		self:addChild(require("game.Huodong.BaseEquipInfoLayer").new({
		id = resId,
		itemType = param.type,
		curNum = mCurNum,
		limitNum = mLimitNum,
		confirmFunc = function()
			if endFunc ~= nil then
				endFunc()
			end
			self:removeSelf()
		end
		}), ZORDER)
	elseif param.type == ITEM_TYPE.canhun or param.type == ITEM_TYPE.xiake then
		local resId = id
		if param.type == ITEM_TYPE.canhun then
			resId = data_item_item[id].para3
		end
		local mCurNum, mLimitNum
		if param.type == ITEM_TYPE.xiake then
			mCurNum = param.curNum
			mLimitNum = param.limitNum
		end
		self:addChild(require("game.Huodong.BaseHeroInfoLayer").new({
		id = resId,
		curNum = mCurNum,
		limitNum = mLimitNum,
		confirmFunc = function()
			if endFunc ~= nil then
				endFunc()
			end
			self:removeSelf()
		end
		}), ZORDER)
	elseif param.type == ITEM_TYPE.chongwu_suipian or param.type == ITEM_TYPE.chongwu then
		local resId = id
		if param.type == ITEM_TYPE.chongwu_suipian then
			resId = data_item_item[id].para3
		end
		local layer = require("game.Pet.PetInfoLayer").new({
		petId = resId,
		removeListener = function()
			if endFunc ~= nil then
				endFunc()
			end
			self:removeSelf()
			return true
		end
		}, 3)
		self:addChild(layer, ZORDER)
	elseif param.type == ITEM_TYPE.zhenqi then
		local spiritData = {}
		spiritData.resId = id
		local descLayer = require("game.Spirit.SpiritInfoLayer").new(4, spiritData, nil, endFunc)
		self:addChild(descLayer, 2)
	elseif param.type == ITEM_TYPE.shizhuang then
		local fashionData = FashionModel.getInitData(id)
		local layer = require("game.shizhuang.FashionInfoLayer").new({info = fashionData}, 3)
		self:addChild(layer, ZORDER)
	elseif param.type == ITEM_TYPE.cheats or param.type == ITEM_TYPE.xinfa_suipian or param.type == ITEM_TYPE.juexue_suipian then
		local resId = id
		if param.type == ITEM_TYPE.xinfa_suipian or param.type == ITEM_TYPE.juexue_suipian then
			resId = data_item_item[id].para3
		end
		local layer = require("game.Cheats.CheatsInfoLayer").new({
		resId = resId,
		removeListener = function()
			if endFunc ~= nil then
				endFunc()
			end
			self:removeSelf()
		end
		}, 3)
		self:addChild(layer, ZORDER)
	elseif endFunc then
		endFunc()
		self:removeSelf()
	end
end

return ItemInformation