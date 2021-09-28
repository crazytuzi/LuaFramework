
require("app.cfg.corps_technology_info")

local LegionTechCell = class ("LegionTechCell", function (  )
	return CCSItemCellBase:create("ui_layout/legion_TechCell.json")
end)

require("app.cfg.corps_technology_info")
local LegionConst = require("app.const.LegionConst")

function LegionTechCell:ctor(list, index)
	self._roundEffect = nil
	self._showEffect = false
	self._imgUrl = {{normal="ui/text/txt-small-btn/shengji.png",special="ui/text/txt-small-btn/xuexi.png"},{normal="ui/text/txt-small-btn/tisheng.png",special="ui/text/txt-small-btn/kaiqi.png"}}
	self._icon = self:getImageViewByName("Image_icon")
	self._pinji = self:getButtonByName("Button_pinji")
	self._nameLabel = self:getLabelByName("Label_name")
	self._nameLabel:createStroke(Colors.strokeBrown, 1)
	self._learnButton = self:getButtonByName("Button_learn")
	self._goButton = self:getButtonByName("Button_go")
	self._learnImg = self:getImageViewByName("Image_learn")
	self._openImg = self:getImageViewByName("Image_open")
	self._openLabel = self:getLabelByName("Label_open")
	self._levelLabel = self:getLabelByName("Label_level")
	self._levelLabel:createStroke(Colors.strokeBrown, 1)
	self:registerBtnClickEvent("Button_learn", function(widget) 
		self:onLearn()
	    end)
	self:registerBtnClickEvent("Button_go", function(widget) 
		self:onGo()
	    end)
	self:registerBtnClickEvent("Button_pinji", function(widget) 
		local layer = require("app.scenes.legion.LegionTechUpdateLayer").create(self._id,self._type)
		uf_sceneManager:getCurScene():addChild(layer)
	    end)
end

function LegionTechCell:onLearn()
	if self._type == LegionConst.LearnType.DEVELOP and G_Me.legionData:getCorpDetail().position == 0 then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TECH_NOLEVEL"))
	end
	local learnLevel = G_Me.legionData:getTechLearnLevel(self._id)
	local developLevel = G_Me.legionData:getTechDevelopLevel(self._id)
	local level = {learnLevel,developLevel}
	local baseInfo = corps_technology_info.get(self._id,1)
	if self._type == LegionConst.LearnType.LEARN and not corps_technology_info.get(self._id,learnLevel+1) then
	    return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TECH_FULL"))
	end
	if self._type == LegionConst.LearnType.DEVELOP and not corps_technology_info.get(self._id,developLevel+1) then
	    return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TECH_FULL"))
	end

	local learnCost = corps_technology_info.get(self._id,learnLevel+1) and corps_technology_info.get(self._id,learnLevel+1).learn_cost_size or 0
	local developCost = corps_technology_info.get(self._id,developLevel+1) and corps_technology_info.get(self._id,developLevel+1).corpsexp_cost or 0
	local cost = self._type == LegionConst.LearnType.LEARN and learnCost or developCost
	local enough = (self._type == LegionConst.LearnType.LEARN and (G_Me.userData.corp_point >= cost)) or (self._type == LegionConst.LearnType.DEVELOP and (G_Me.legionData:getCorpDetail().exp >= cost))
	if not enough then
		local str = level[self._type] > 0 and "LANG_LEGION_TECH_NO_ENOUGH" or "LANG_LEGION_TECH_NO_ENOUGH_OPEN"
		str =  G_lang:get(str..self._type)
	    return G_MovingTip:showMovingTip(str)
	end

	if self._type == LegionConst.LearnType.LEARN and learnLevel >= developLevel then
	    local str = developLevel > 0 and G_lang:get("LANG_LEGION_TECH_HASMAX1") or G_lang:get("LANG_LEGION_TECH_LEVEL0")
	    return G_MovingTip:showMovingTip(str)
	end

	if self._type == LegionConst.LearnType.DEVELOP and G_Me.legionData:getCorpDetail().level < corps_technology_info.get(self._id,developLevel+1).require_corpslevel then
	    return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TECH_HASMAX2",{level=corps_technology_info.get(self._id,developLevel+1).require_corpslevel}))
	end

	if self._callBack and self._showEffect then
		self._callBack()
	end

	if self._type == LegionConst.LearnType.LEARN then
	    if learnLevel == 0 then
	    	local str = G_lang:get("LANG_LEGION_TECH_LEARN_TIP",{num=learnCost,name=baseInfo.name})
	    	MessageBoxEx.showYesNoMessage(nil,str,false,function()
	    	    G_HandlersManager.legionHandler:sendLearnCorpTech(self._id)
	    	end,nil,nil,MessageBoxEx.OKNOButton.OKNOBtn_Default)
	    else
	        	G_HandlersManager.legionHandler:sendLearnCorpTech(self._id)
	    end
	else
	    if developLevel == 0 then
	    	local str = G_lang:get("LANG_LEGION_TECH_DEVELOP_TIP",{num=developCost,name=baseInfo.name})
		MessageBoxEx.showYesNoMessage(nil,str,false,function()
		    G_HandlersManager.legionHandler:sendDevelopCorpTech(self._id)
		end,nil,nil,MessageBoxEx.OKNOButton.OKNOBtn_Default)
	    else
	        	G_HandlersManager.legionHandler:sendDevelopCorpTech(self._id)
	    end
	end


	-- local layer = require("app.scenes.legion.LegionTechUpdateLayer").create(self._id,self._type)
	-- uf_sceneManager:getCurScene():addChild(layer)
end

function LegionTechCell:onGo()
	if G_Me.legionData:getCorpDetail().position == 0 then
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_TECH_NOLEVEL_NEED"))
	end
	if self._callBack then
		self._callBack(LegionConst.LearnType.DEVELOP,self._id)
	end
end

function LegionTechCell:updateData(list, id,btnName,showCell,callBack)
	self._id = id
	self._container = container
	self._callBack = callBack
	local _type = btnName == "CheckBox_learn" and LegionConst.LearnType.LEARN or LegionConst.LearnType.DEVELOP
	self._type = _type
	self:getPanelByName("Panel_study1"):setVisible(_type==1)
	self:getPanelByName("Panel_study2"):setVisible(_type==2)
	local learnLevel = G_Me.legionData:getTechLearnLevel(id)
	local developLevel = G_Me.legionData:getTechDevelopLevel(id)
	local level = {learnLevel,developLevel}
	local info = corps_technology_info.get(id,level[_type])
	local nextInfo = corps_technology_info.get(id,level[_type]+1)

	local baseInfo = info and info or nextInfo
	local gray1 = _type == LegionConst.LearnType.LEARN and developLevel == 0 
	local gray2 = _type == LegionConst.LearnType.DEVELOP and corps_technology_info.get(id,1).require_corpslevel > G_Me.legionData:getCorpDetail().level
	local gray = gray1 or gray2
	self._icon:loadTexture(G_Path.getLegionTechIcon(baseInfo.icon))
	self._icon:showAsGray(gray)
	self._pinji:loadTextureNormal(G_Path.getEquipColorImage(baseInfo.quality))
	self._pinji:showAsGray(gray)
	self._nameLabel:setText(baseInfo.name)
	local levelTxt = level[_type] > 0 and G_lang:get("LANG_LEGION_TECH_LEVEL",{level=level[_type]}) or G_lang:get("LANG_LEGION_TECH_CLOSED".._type)
	self._levelLabel:setText(levelTxt)
	self._levelLabel:setColor(level[_type] > 0 and Colors.darkColors.TITLE_01 or Colors.darkColors.TIPS_01)
	self._levelLabel:setVisible(_type == LegionConst.LearnType.DEVELOP)

	local levelTxt = ""
	if _type == LegionConst.LearnType.LEARN then
		if learnLevel > 0 then
			levelTxt = learnLevel.."/"..developLevel
		else
			levelTxt = G_lang:get("LANG_LEGION_TECH_HAS_CLOSED"..(developLevel>0 and 1 or 2))
		end
	else
		local needLevelInfo = corps_technology_info.get(id,developLevel+1)
		levelTxt = needLevelInfo and needLevelInfo.require_corpslevel or 0
	end
	self:getLabelByName("Label_maxLevelValue".._type):setText(levelTxt)
	self:getLabelByName("Label_curValue".._type):setText(G_Me.legionData:getTechTxt(id,level[_type],_type))
	self:getLabelByName("Label_nextValue".._type):setText(G_Me.legionData:getTechTxt(id,level[_type]+1,_type))
	local learnCost = corps_technology_info.get(id,learnLevel+1) and corps_technology_info.get(id,learnLevel+1).learn_cost_size or 0
	local developCost = corps_technology_info.get(id,developLevel+1) and corps_technology_info.get(id,developLevel+1).corpsexp_cost or 0
	local cost = _type == LegionConst.LearnType.LEARN and learnCost or developCost
	self:getLabelByName("Label_costValue".._type):setText(G_lang:get("LANG_LEGION_TECH_EXP".._type,{exp=cost}))

	local state = G_Me.legionData:isTechOpen(id)
	local state2 = _type == LegionConst.LearnType.LEARN and developLevel == 0
	self._goButton:setVisible(state and state2)
	self._learnButton:setVisible(state and not state2)
	self._openImg:setVisible(not state)
	self._openLabel:setVisible(not state)
	local openLevel = corps_technology_info.get(id,developLevel+1) and corps_technology_info.get(id,developLevel+1).require_corpslevel or 0
	self._openLabel:setText(G_lang:get("LANG_LEGION_TECH_OPEN_LEVEL",{level=openLevel}))
	local url = level[_type] > 0 and self._imgUrl[_type].normal or self._imgUrl[_type].special
	self._learnImg:loadTexture(url)

	self._showEffect = showCell and showCell.type == _type and showCell.id == id
	if self._showEffect then
		if not self._roundEffect then
			local EffectNode = require "app.common.effects.EffectNode"
			self._roundEffect = EffectNode.new("effect_around2")     
			self._roundEffect:setScale(1.4) 
			self._roundEffect:play()
			self._learnButton:addNode(self._roundEffect)
		end
	else
		if self._roundEffect then
			self._roundEffect:removeFromParentAndCleanup(true)
			self._roundEffect = nil
		end
	end
end

return LegionTechCell