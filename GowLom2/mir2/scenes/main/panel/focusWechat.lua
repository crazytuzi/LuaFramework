local item = import("..common.item")
local itemInfo = import("..common.itemInfo")
local focusWechat = class("focusWechat", function ()
	return display.newNode()
end)

table.merge(slot2, {})

focusWechat.ctor = function (self)
	self._supportMove = true
	self.bg = display.newNode():addto(self, 20)
	local newbg = res.get2("pic/panels/bag/newbg.png"):anchor(0, 0):addto(self)

	an.newLabel("关注微信", 22, 0, {
		color = def.colors.Cd2b19c
	}):anchor(0.5, 0.5):pos(newbg.getw(newbg)/2, newbg.geth(newbg) - 28):addto(newbg)
	self.size(self, cc.size(newbg.getContentSize(newbg).width, newbg.getContentSize(newbg).height))
	self.setPosition(self, display.cx/2, display.cy/2 - 50)
	res.get2("pic/panels/activity/pubg.png"):anchor(0, 0):addto(self):pos(20, 20)
	an.newBtn(res.gettex2("pic/common/close10.png"), function ()
		sound.playSound("103")
		self:hidePanel()

		return 
	end, {
		pressImage = res.gettex2("pic/common/close11.png"),
		size = cc.size(64, 64)
	}).anchor(slot2, 1, 1):pos(self.getw(self) - 14, self.geth(self) - 14):addto(self, 20)
	self.showView(self)

	return 
end
focusWechat.showView = function (self)
	local content = json.decode(res.getfile("config/focusWechat.txt"))

	if not content then
		return 
	end

	res.get2("pic/panels/activity/" .. content.APict .. ".png"):anchor(0, 0):addto(self.bg):pos(325, 35)

	local function extractInfo(target, info)
		local desc = {}
		local info_list = string.split(info, "<")

		for i = 1, #info_list, 1 do
			local info_temp = info_list[i]

			if string.find(info_temp, ">") then
				local info_temp_list = string.split(info_temp, ">")
				local info_temp_content_list = string.split(info_temp_list[1], "/")
				local info_temp_content_color = string.upper(info_temp_content_list[2])

				if string.find(info_temp_content_color, "FCOLOR") and string.find(info_temp_content_color, "RED") then
					desc[#desc + 1] = {
						text = info_temp_content_list[1],
						color = display.COLOR_RED
					}
				end

				desc[#desc + 1] = {
					text = info_temp_list[2]
				}
			else
				desc[#desc + 1] = {
					text = info_temp
				}
			end
		end

		for i, v in ipairs(desc) do
			target.addLabel(target, v.text, v.color)
		end

		return 
	end

	local descLabel_1 = an.newLabelM(1000, 20, 1).anchor(slot3, 0, 0.5):pos(55, 266):add2(self.bg)

	extractInfo(descLabel_1, content.ADis1)

	local descLabel_2 = an.newLabelM(1000, 20, 1):pos(55, 222):anchor(0, 0.5):add2(self.bg)

	extractInfo(descLabel_2, content.ADis2)

	local descLabel_3 = an.newLabelM(1000, 20, 1):pos(55, 182):anchor(0, 0.5):add2(self.bg)

	extractInfo(descLabel_3, content.ADis3)

	local award = content.AAward
	local award_list = string.split(award, "|")

	for i = 1, #award_list, 1 do
		local award_temp = string.split(award_list[i], ",")
		local award_name = award_temp[1]
		local award_num = award_temp[2]
		local inode = res.get2("pic/panels/shop/frame.png"):anchor(0, 0):pos((i - 1)*77 + 25, 20):add2(self.bg)
		local finded = false

		for index, stditem in ipairs(_G.def.items) do
			if stditem.name == award_name then
				local baseItem = {
					FIndex = index,
					FDuraMax = stditem.duraMax,
					FItemValueList = {},
					FItemIdent = 1
				}

				setmetatable(baseItem, {
					__index = gItemOp
				})
				baseItem.decodedCallback(baseItem)

				if baseItem.isPileUp(baseItem) then
					baseItem.FDura = ""
				else
					baseItem.FDura = stditem.duraMax
				end

				item.new(baseItem, self, {
					donotMove = true
				}):addTo(inode):anchor(0.5, 0.5):pos(37, 37)

				if 0 < tonumber(award_num) then
					an.newLabel(award_num, 12, 1, {
						color = cc.c3b(0, 255, 0)
					}):anchor(1, 0):pos(60, 10):add2(inode, 2)
				end

				finded = true

				break
			end
		end

		if not finded then
			local special = {
				装备 = 5634,
				银锭 = 5632,
				活力值 = 5636,
				经验 = 1186,
				沙巴克 = 5630,
				宝物 = 5635,
				技能书 = 0,
				精力值 = 5637,
				声望 = 1185,
				金币 = 115,
				信用分 = 5631,
				元宝 = 5633
			}
			local looks = nil

			if special[award_name] then
				looks = special[award_name]
			end

			if looks then
				local itemI = res.get("items", looks):addto(inode):anchor(0.5, 0.5):pos(37, 37)

				if 0 < tonumber(award_num) then
					an.newLabel(award_num, 12, 1, {
						color = cc.c3b(0, 255, 0)
					}):anchor(1, 0):pos(60, 10):add2(inode, 2)
				end

				itemI.setTouchEnabled(itemI, true)
				itemI.setTouchSwallowEnabled(itemI, true)
				itemI.addNodeEventListener(itemI, cc.NODE_TOUCH_EVENT, function (event)
					if event.name == "began" then
						local pos = inode:convertToWorldSpace(cc.p(self.bg:getPositionX() - 200, self.bg:getPositionY() - 10))
						local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")):addto(self.bg):anchor(0.5, 0.5):pos(pos.x, pos.y)
						self.bg.itemInfo = bg
						local infoT = an.newLabel(award_name, 24, 0):addTo(bg):pos(10, 4)

						bg.size(bg, infoT.getw(infoT) + 20, infoT.geth(infoT) + 8)

						return true
					elseif event.name == "ended" and self.bg.itemInfo then
						self.bg.itemInfo:removeSelf()
					end

					return 
				end)
			end
		end
	end

	return 
end

return focusWechat
