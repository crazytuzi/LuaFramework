local cheatMenuLayer = class("cheatMenuLayer", function()
	return display.newLayer("cheatMenuLayer")
end)
function cheatMenuLayer:ctor(...)
	self:setNodeEventEnabled(true)
	local function onAddItem(tag)
		local editBox = ui.newEditBox({
		image = "#mm_energy_bg.png",
		size = cc.size(250, 50),
		listener = function(param, x, y, z)
		end
		})
		editBox:setPosition(display.width / 2, display.height / 2)
		self:addChild(editBox, 10011)
		local onBtn = require("utility.CommonButton").new({
		img = "#mm_silver.png",
		listener = function()
			if tag == 1 then
				local item = require("data.data_item_item")[checknumber(editBox:getText())]
				if item == nil then
					return
				end
				RequestHelper.gmAdd({
				callback = function(data)
					dump(data)
				end,
				id = editBox:getText(),
				n = 5,
				t = item.type
				})
			elseif tag == 2 then
				RequestHelper.gmAdd({
				callback = function()
				end,
				id = 1,
				n = checkint(editBox:getText()),
				t = 0
				})
			elseif tag == 3 then
				RequestHelper.gmAdd({
				callback = function(data)
					dump(data)
				end,
				id = 2,
				n = checkint(editBox:getText()),
				t = 0
				})
			elseif tag == 4 then
				RequestHelper.gmAdd({
				callback = function(data)
					dump(data)
				end,
				id = checkint(editBox:getText()),
				n = 3,
				t = 8
				})
			elseif tag == 5 then
				RequestHelper.gmAdd({
				callback = function(data)
					dump(data)
				end,
				id = checkint(editBox:getText()),
				n = 1,
				t = 1
				})
			elseif tag == 6 then
				RequestHelper.gmAdd({
				callback = function(data)
					dump(data)
				end,
				id = 3,
				n = checkint(editBox:getText()),
				t = 0
				})
			elseif tag == 7 then
				RequestHelper.gmAdd({
				callback = function(data)
					dump(data)
				end,
				id = checkint(editBox:getText()),
				n = 1,
				t = 6
				})
			elseif tag == 8 then
				RequestHelper.gmAdd({
				callback = function(data)
					dump(data)
				end,
				id = editBox:getText(),
				n = 11,
				t = 5
				})
			elseif tag == 9 then
				RequestHelper.formation.unload({
				callback = function(data)
				end,
				pos = editBox:getText()
				})
			elseif tag == 10 then
				RequestHelper.gmAdd({
				callback = function(data)
					dump(data)
				end,
				id = editBox:getText(),
				n = 20,
				t = 4
				})
			elseif tag == 11 then
				RequestHelper.gmAdd({
				callback = function(data)
					dump(data)
				end,
				id = editBox:getText(),
				n = 1,
				t = 3
				})
			elseif tag == 12 then
			end
			editBox:removeSelf()
		end
		})
		onBtn:setPosition(editBox:getContentSize().width, 0)
		editBox:addChild(onBtn)
	end
	local addBtn = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiawupin"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function(tag)
		onAddItem(tag)
	end,
	tag = 1
	})
	local addGold = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiajinbi"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function(tag)
		onAddItem(tag)
	end,
	tag = 2
	})
	local addSilver = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiayinbi"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function(tag)
		onAddItem(tag)
	end,
	tag = 3
	})
	local addHero = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiawujiang"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function(tag)
		onAddItem(tag)
	end,
	tag = 4
	})
	local addEquip = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiazhuangbei"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function(tag)
		onAddItem(tag)
	end,
	tag = 5
	})
	local addTili = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiatili"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function(tag)
		onAddItem(tag)
	end,
	tag = 6
	})
	local addJingYuan = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiajingyuan"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function(tag)
		onAddItem(tag)
	end,
	tag = 7
	})
	local addherosoul = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@xiakesp"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function(tag)
		onAddItem(tag)
	end,
	tag = 8
	})
	local unloadHero = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@xiazhenyx"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function(tag)
		onAddItem(tag)
	end,
	tag = 9
	})
	local addReward = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiajiangli"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function()
		RequestHelper.getRewardCenter({
		callback = function(data)
			dump(data)
		end
		})
	end
	})
	local addStar = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiaxingxing"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function()
		RequestHelper.gmAddStar({
		callback = function(data)
			dump(data)
		end
		})
	end
	})
	local addSkill = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiawuxue"),
	color = display.COLOR_BLUE,
	size = 26,
	listener = function(tag)
		onAddItem(tag)
	end,
	tag = 10
	})
	local addEquipFragment = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiazhuangbeisp"),
	color = display.COLOR_GREEN,
	size = 26,
	listener = function(tag)
		onAddItem(tag)
	end,
	tag = 11
	})
	local addAllHeros = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@tianjiasuoyouxiake"),
	color = display.COLOR_GREEN,
	size = 26,
	listener = function(tag)
		RequestHelper.gmAddAllCard({
		callback = function(data)
			dump(data)
		end
		})
	end,
	tag = 12
	})
	local resetAllCount = ui.newTTFLabelMenuItem({
	text = common:getLanguageString("@chongzhitzcs"),
	color = display.COLOR_GREEN,
	size = 26,
	listener = function(tag)
		RequestHelper.gmResetAllCounts({
		callback = function(data)
			dump(data)
		end
		})
	end,
	tag = 13
	})
end
function cheatMenuLayer:testFile()
	local errfff = function()
		dump("heheheh")
	end
	local arr = {1, 2}
	local function yeyye()
		dump("arr" .. arr[3])
	end
	local x, err = safe_call(yeyye)
	dump("msgis ")
	dump(x)
end

function cheatMenuLayer:getCellValue(cellData)
	local cellValue = 0
	local isOnline = cellData.isOnline or 0
	local level = cellData.level or 1
	local zhanli = cellData.battlepoint or 0
	cellValue = cellValue + isOnline * 1000000
	cellValue = cellValue + level * 10000
	cellValue = cellValue + zhanli / 100
	return cellValue
end

return cheatMenuLayer