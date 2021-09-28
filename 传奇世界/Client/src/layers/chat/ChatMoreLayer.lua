local ChatMoreLayer = class("ChatMoreLayer", function() return cc.Layer:create() end)

local path = "res/chat/"
local commConst = require("src/config/CommDef")

function ChatMoreLayer:ctor(param)
	dump(param)
	self.choseFaceCallBack = param.choseFaceCallBack
	self.choseEquipmentCallBack = param.choseEquipmentCallBack
	self.choseShortCallBack = param.choseShortCallBack
	self.choseTrumpetCallBack = param.choseTrumpetCallBack

	local bg = createScale9Sprite(self, "res/common/scalable/6.png", cc.p(0, 0), cc.size(300, 110), cc.p(1, 0))
	local closeFunc = function()
		removeFromParent(self)
	end

	local function equipmentBtnFunc()
		local function callback(packId, grid)
			dump(self.choseEquipmentCallBack)
			dump(param)
			--if self.choseEquipmentCallBack then
				param.choseEquipmentCallBack(packId, grid)
				--self.choseEquipmentCallBack(grid)
			--end
		end

		local Mreloading = require "src/layers/equipment/equip_reloading"
		local Manimation = require "src/young/animation"
		Manimation:transit(
		{
			node = Mreloading.new(
			{
				--now = { packId = packId, gridId = gridId },
				filtrate = function(packId, grid)
					local MequipOp = require "src/config/equipOp"
					local MpropOp = require "src/config/propOp"
					local Mconvertor = require "src/config/convertor"
					if true then
						return true
					end
					local protoId = MPackStruct.protoIdFromGird(grid)
					-- -- 是否是勋章
					-- local isMedal = protoId >= 30004 and protoId <= 30006
					-- if (MPackStruct.categoryFromGird(grid) == MPackStruct.eEquipment or MpropOp.category(protoId)==20 )and not isMedal then
					-- 	return true
					-- else
					-- 	return false
					-- end
				end,
				handler = function(item)
					dump(item)
					--if self.choseEquipmentCallBack then
						callback(item.packId, item.grid)
					--end
				end,

				onCellLongTouched = function(gv, idx, cell, item)
					log("onCellLongTouched")
					local grid = item.grid
					local Mtips = require "src/layers/bag/tips"
					local actions = {}
					actions[#actions+1] = {
						label = "展示",
						cb = function(act_params)
							local MpropOp = require "src/config/propOp"
							local grid = act_params.grid
							local gridId = MPackStruct.girdIdFromGird(grid)
							local protoId = MPackStruct.protoIdFromGird(grid)
							local num = MPackStruct.overlayFromGird(grid)
							--if self.choseEquipmentCallBack then
								callback(item.packId, grid)
							--end
						end,
					}
					
					Mtips.new({ grid = grid, actions = actions })
				end,
			}),
			sp = g_scrCenter,
			ep = cc.p(750, display.cy),
			--trend = "-",
			zOrder = 200,
			curve = "-",
			swallow = true,
		})

		closeFunc()
	end

	local function shortBtnFunc()
		local layer = require("src/layers/chat/ChatShortLayer").new(self.choseShortCallBack)
		getRunScene():addChild(layer, 200)
		layer:setPosition(cc.p(550, display.cy))

		closeFunc()
	end

	local function faceBtnFunc()
		local layer = require("src/layers/chat/ChatFace").new(self.choseFaceCallBack)
		getRunScene():addChild(layer, 200)
		layer:setPosition(cc.p(550, display.cy))

		closeFunc()
	end

	local function trumpetFunc()
		local function isWithTrumpet()
			local MPackManager = require "src/layers/bag/PackManager"
			local MPackStruct = require "src/layers/bag/PackStruct"
			local bag = MPackManager:getPack(MPackStruct.eBag)
			if bag then
				if bag:countByProtoId(1000) > 0 then
					return true
				end
			end

			return false
		end

		if isWithTrumpet() then
			if self.choseTrumpetCallBack then
				self.choseTrumpetCallBack()
			end
		else
			--TIPS({str = game.getStrByKey("chat_no_trumpet_tip"), type = 1})
			
			-- local luaEventMgr = LuaEventManager:instance()
			-- local buffer = luaEventMgr:getLuaEventExEx(CHAT_CS_SENDCHATMSG)
			-- buffer:writeByFmt("cSic", commConst.Channel_ID_Bugle, "", userInfo.currRoleStaticId, 0)
			-- LuaSocket:getInstance():sendSocket(buffer)
			local t = {}
			t.channel = commConst.Channel_ID_Bugle
			t.message = ""
			g_msgHandlerInst:sendNetDataByTableExEx(CHAT_CS_SENDCHATMSG, "SendChatProtocol", t)	
		end

		closeFunc()
	end

	local x = 40
	local addX = (bg:getContentSize().width - 2 * x) / 3
	local y = bg:getContentSize().height / 2

	local faceBtn = createMenuItem(bg, path.."face.png", cc.p(x+addX*0, y), faceBtnFunc)
	local equipmentBtn = createMenuItem(bg, path.."equipment.png", cc.p(x+addX*1, y), equipmentBtnFunc)
	local shortBtn = createMenuItem(bg, path.."short.png", cc.p(x+addX*2, y), shortBtnFunc)
	local trumpetBtn = createMenuItem(bg, path.."trumpet.png", cc.p(x+addX*3, y), trumpetFunc)
	
	registerOutsideCloseFunc(bg, closeFunc, true)
end

return ChatMoreLayer