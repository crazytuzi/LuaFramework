local FactionBannerLayer = class("FactionBannerLayer", function() return cc.Layer:create() end)

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionBannerLayer:ctor(factionData, bg)
	self.factionData = factionData
	self.bg = bg

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

	self:updateFactionInfo()
end

function FactionBannerLayer:updateFactionInfo()
	local imageBg = createSprite(self.baseNode, path.."1.png", getCenterPos(self.bg), cc.p(0.5, 0.5))

	local infoBg = createSprite(self.baseNode, pathCommon.."bg/infoBg11.png", cc.p(self.bg:getContentSize().width-7, self.bg:getContentSize().height/2), cc.p(1, 0.5))
	createSprite(infoBg, pathCommon.."bg/infoBg11-3.png", cc.p(infoBg:getContentSize().width/2, 426), cc.p(0.5, 0.5))

	if self.factionData.flagLv then
		createLabel(self.baseNode, game.getStrByKey("num_"..self.factionData.flagLv)..game.getStrByKey("faction_tip_flag_level"), cc.p(217, 35), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.yellow)
		local resId = self.factionData.flagLv
		if resId > 5 then
			resId = 5
		end
        createSprite(self.baseNode, path.."banner"..resId..".png", cc.p(217, 66), cc.p(0.5, 0))
	end

	--local titleBg = createSprite(infoBg, pathCommon.."bg/titleBg.png", cc.p(infoBg:getContentSize().width/2, 430), cc.p(0.5, 0.5))
	createLabel(infoBg, game.getStrByKey("faction_banner_menber"), cc.p(infoBg:getContentSize().width/2, 453), cc.p(0.5, 0.5), 20, true)

	-- local record = getConfigItemByKey("SkillLevelCfg", "skillID", 9501*1000+self.factionData.flagLv)
	-- local outLineColor = MColor.lable_outLine
	-- --createLabel(infoBg, level..game.getStrByKey("faction_banner_level"),cc.p(30,400),cc.p(0.0,0.5), 22,nil,nil,nil,cc.c3b(237, 215, 27),nil,nil,outLineColor)
	-- --createLabel(infoBg, game.getStrByKey("faction_banner_menber"),cc.p(50,360),cc.p(0,0), 20, true, nil, nil, MColor.lable_black)
	-- --createLabel(infoBg, game.getStrByKey("faction_banner_hp")..record.sms2,cc.p(50,370),cc.p(0,0), 20, true, nil, nil, MColor.lable_black)
	-- createLabel(infoBg, game.getStrByKey("faction_banner_wugong")..record.wg2.."-"..record.wg21,cc.p(50,370),cc.p(0,0), 20, true, nil, nil, MColor.lable_black)
	-- createLabel(infoBg, game.getStrByKey("faction_banner_mogong")..record.ml2.."-"..record.ml21,cc.p(50,330),cc.p(0,0), 20, true, nil, nil, MColor.lable_black)
	-- createLabel(infoBg, game.getStrByKey("faction_banner_daogong")..record.ds2.."-"..record.ds21,cc.p(50,290),cc.p(0,0), 20, true, nil, nil, MColor.lable_black)
	-- createLabel(infoBg, game.getStrByKey("faction_banner_wufang")..record.wf2.."-"..record.wf21,cc.p(50,250),cc.p(0,0), 20, true, nil, nil, MColor.lable_black)
	-- createLabel(infoBg, game.getStrByKey("faction_banner_mofang")..record.mf2.."-"..record.mf21,cc.p(50,210),cc.p(0,0), 20, true, nil, nil, MColor.lable_black)

	local buffId = getConfigItemByKey("FactionUpdate", "FacLevel", self.factionData.flagLv, "bannerBuffid")
	dump(buffId)
	if buffId then
		local record = getConfigItemByKey("buff", "id", buffId)
		dump(record)
		if record and record.desc_text then
			local richText = require("src/RichText").new(infoBg, cc.p(70, 400), cc.size(200, 30) , cc.p(0, 1), 40, 22,MColor.lable_black)
 			richText:addText(record.desc_text)
  			richText:format()
		end
	end

	local richText = require("src/RichText").new(infoBg, cc.p(30, 130), cc.size(220, 25), cc.p(0, 1), 25, 20, MColor.red)
	richText:addText(game.getStrByKey("faction_banner_tip"))
  	richText:format()

	--createLabel(infoBg, game.getStrByKey("faction_banner_tip_1"), cc.p(infoBg:getContentSize().width/2, 115), cc.p(0.5, 0), 20, true, nil, nil, MColor.red)
    --createLabel(infoBg, game.getStrByKey("faction_banner_tip_2"), cc.p(infoBg:getContentSize().width/2, 90), cc.p(0.5, 0), 20, true, nil, nil, MColor.red)

	-- local function levelUpBtnFunc()
	-- 	local layer = require("src/layers/faction/FactionUpdateLayer").new(self.factionData, 3)
	-- 	Manimation:transit(
	-- 	{
	-- 		ref = self,
	-- 		node = layer,
	-- 		curve = "-",
	-- 		sp = self:convertToNodeSpace(cc.p(display.cx, display.cy)),
	-- 		ep = self:convertToNodeSpace(cc.p(display.cx, display.cy)),
	-- 		swallow = true,
	-- 	})
	-- end
	-- local levelUpBtn = createMenuItem(infoBg, "res/component/button/39.png", cc.p(infoBg:getContentSize().width/2, 50), levelUpBtnFunc)
	-- createLabel(levelUpBtn, game.getStrByKey("faction_btn_level_up"), getCenterPos(levelUpBtn), cc.p(0.5, 0.5), 22, true)
end

return FactionBannerLayer