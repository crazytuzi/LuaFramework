--[[
 --
 -- add by vicky
 -- 2014.08.06
 --
 --]]

 local data_refine_refine = require("data.data_refine_refine")
 local data_item_item = require("data.data_item_item")


 local ZORDER = 101

 local ItemInformation = class("ItemInformation", function()
 		return display.newNode()
 		-- return require("utility.ShadeLayer").new()
 end)


 function ItemInformation:ctor(param)
 	local endFunc = param.endFunc 
 	local id = param.id
 	if param.type == 7 or param.type == 11 or param.type == 12 then
 		-- 7：可使用物品、11：礼品、12材料
 		local shadeLayer = require("utility.ShadeLayer").new(ccc4(0, 0, 0, 0))
 		self:addChild(shadeLayer)

 		local proxy = CCBProxy:create()
		local subnode = {}
		local node = CCBuilderReaderLoad("reward/item_information.ccbi", proxy, subnode)
		node:setPosition(display.cx, display.cy) 
		self:addChild(node)

		subnode["closeBtn"]:addHandleOfControlEvent(function(eventName,sender)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
	                sender:runAction(transition.sequence({
	                CCCallFunc:create(function()
	                	if endFunc ~= nil then 
	                		endFunc() 
		                end 
	                    self:removeFromParentAndCleanup(true)
	                end)
	            }))
	            end,
	            CCControlEventTouchUpInside) 

		-- 名称 
		local nameColor = ResMgr.getItemNameColor(id)
		nameColor = nameColor or ccc3(99, 47, 8) 
		-- subnode["itemNameLbl"]:setColor(nameColor) 
		-- subnode["itemNameLbl"]:setString(param.name)

		local curName = param.name or data_item_item[id].name 

		local nameLbl = ui.newTTFLabelWithShadow({
            text = curName,
            size = 22,
            color = nameColor,
            -- shadowColor = ccc3(0,0,0),
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
            })
 		
 		nameLbl:setPosition(0, subnode["itemNameLbl"]:getContentSize().height/2) 
	    subnode["itemNameLbl"]:addChild(nameLbl)

	    local curDesc = param.describe or data_item_item[id].describe

	    -- 描述
		subnode["itemDesLbl"]:setString(curDesc)

		local itemIcon = subnode["itemIcon"]
		ResMgr.refreshIcon({id = id, resType = ResMgr.ITEM, itemBg = itemIcon})

	elseif param.type == 4 or param.type == 9 or param.type == 10 then
		-- 4: 内外功、 9：内功碎片、 10：外功碎片 
		local resId = id 
		if param.type == 9 or param.type == 10 then 
			resId = data_item_item[id].para3 
		end 

	    self:addChild(require("game.Duobao.DuobaoItemInfoLayer").new({
	        id = resId, 
	        confirmListen = function()
	        	if endFunc ~= nil then 
            		endFunc() 
                end
		    end
        }), ZORDER)

	elseif param.type == 1 or param.type == 2 or param.type == 3 then
		-- 1：装备、 2：时装、 3：装备碎片 
		local resId = id 
		if param.type == 3 then 
			resId = data_item_item[id].para3 
		end
		print("iiiddididdi  "..param.type)

		self:addChild(require("game.Huodong.BaseEquipInfoLayer").new({
			id = resId, 
			itemType = param.type,
			confirmFunc = function() 
				if endFunc ~= nil then 
            		endFunc() 
                end
			end
			}), ZORDER)
	elseif param.type == 5 or param.type == 8 then 
		-- 5：武将碎片、 8：武将
		local resId = id 
		if param.type == 5 then 
			resId = data_item_item[id].para3 
		end

		self:addChild(require("game.Huodong.BaseHeroInfoLayer").new({
			id = resId, 
			confirmFunc = function() 
				if endFunc ~= nil then 
            		endFunc() 
                end
			end
			}), ZORDER)
 	end 

 end


 return ItemInformation